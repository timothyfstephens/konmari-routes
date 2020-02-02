RSpec.describe Konmari::Routes::Loader do
  let(:route_loader) { described_class.new(Konmari::Routes::Configuration.new.tap { |c| c.routes_path = routes_folder}) }
  let(:routes_folder) { Pathname.new(`pwd`.strip) }

  before do
    allow_any_instance_of(described_class).to receive(:build_routes)
  end

  describe "#sorted_childen" do
    let(:folder_path) { Pathname.new("config/routes_spec") }
    let(:children)    { [] }

    before { allow(folder_path).to receive(:children).and_return(children) }

    subject { route_loader.send(:sorted_children, folder_path) }

    context "with priority files" do
      let(:children) { [
        Pathname.new("index.routes"),
        Pathname.new("non-priority.routes"),
        Pathname.new("redirects.routes"),
        Pathname.new("priority.routes")
      ].shuffle }

      it "sorts in order listed in constant" do
        expect(subject.map(&:to_s)).to eq([
          "priority.routes",
          "redirects.routes",
          "index.routes",
          "non-priority.routes"
        ])
      end

      context "only some of them" do
        let(:children) { [
          Pathname.new("index.routes"),
          Pathname.new("non-priority.routes"),
          Pathname.new("redirects.routes")
        ] }

        it "still sorts in order listed in constant" do
          expect(subject.map(&:to_s)).to eq([
            "redirects.routes",
            "index.routes",
            "non-priority.routes"
          ])
        end
      end
    end

    context "with directories and files" do
      let(:directory) { Pathname.new("my_sorted_dir") }
      let(:file)      { Pathname.new("my_file_sorted") }

      let(:children) { [file, directory] }

      before do
        allow(directory).to receive(:directory?).and_return(true)
      end

      it "sorts the directories first" do
        expect(subject.map(&:to_s)).to eq([
          "my_sorted_dir",
          "my_file_sorted"
        ])
      end

      context "and priority files" do
        let(:files) { %w(
          index.routes
          non-priority.routes
          redirects.routes
          priority.routes
          other_file.routes
          abc.routes
        ).map { |f| Pathname.new(f) } }

        let(:directories) { %w(
          directory_a
          my_namespace
          alpha_routes
          omega_routes
        ).map { |d| Pathname.new(d) } }

        let(:children) { (files + directories).shuffle }

        before do
          directories.each do |directory|
            allow(directory).to receive(:directory?).and_return(true)
          end
        end

        it "sorts the priority files, followed by the alphabetized directories, followed by the alphabetized files" do
          expect(subject.map(&:to_s)).to eq %w(
            priority.routes
            redirects.routes
            index.routes
            alpha_routes
            directory_a
            my_namespace
            omega_routes
            abc.routes
            non-priority.routes
            other_file.routes
          )
        end
      end
    end
  end

  describe "#process_file" do
    let(:filepath)      { "test_file.routes" }
    let(:file_contents) { "route_test_method :test_file, hello: :world" }
    let(:router)        { double(described_class.to_s) }

    subject do
      route_loader.instance_variable_set(:@router, router)
      route_loader.send(:process_file, Pathname.new(filepath))
    end

    before do
      File.open(filepath, "w") do |file|
        file.write(file_contents)
      end
    end

    after do
      File.delete filepath
    end

    shared_examples_for "a good routes file" do
      it "receives the correct routes" do
        expect(router).to receive(:route_test_method).with(:test_file, hello: :world)
        subject
      end
    end

    context "when single line, matches expected name" do
      it_behaves_like "a good routes file"
    end

    context "when first line does not match file name" do
      let(:filepath) { "not_a_match.routes" }

      it "raises an error" do
        expect { subject }.to raise_error(Konmari::Routes::FilenameError, "Expected filename to match :test_file for not_a_match.routes")
      end

      context "with an invalid extension" do
        let(:filepath) { "test_file.ruby" }

        it "raises an error" do
          expect { subject }.to raise_error(Konmari::Routes::FilenameError, "Expected filename to match :test_file for test_file.ruby")
        end
      end

      context "and file is a in the priority file list" do
        let(:filepath) { "index.routes" }

        it "does not raise an error" do
          allow(router).to receive(:instance_eval).with anything
          expect { subject }.not_to raise_error
        end

        it_behaves_like "a good routes file"
      end
    end

    context "with multiple comment or blank lines before the first valid line of code" do
      let(:file_contents) {
        <<~ROUTE
          # This is a comment
            # Another comment, starting off indented, followed by a blank line

          route_test_method :test_file, hello: :world
        ROUTE
      }

      it "does not raise an error" do
        allow(router).to receive(:instance_eval).with anything
        expect { subject }.not_to raise_error
      end

      it_behaves_like "a good routes file"
    end
  end

  describe "#handle_path" do
    let(:router) { double(described_class.to_s) }

    subject do
      route_loader.instance_variable_set(:@router, router)
      route_loader.send(:handle_path, filepath)
    end

    context "when path is a directory" do
      let(:filepath) { Pathname.new("my_directory") }
      let(:children) { [Pathname.new("my_child")] }

      before do
        allow(filepath).to receive(:directory?).and_return(true)
        allow(route_loader).to receive(:sorted_children).and_return(children)
      end

      it "sets the namespace correctly" do
        expect(router).to receive(:namespace).with(filepath.to_s.to_sym)
        subject
      end

      it "recursively calls for the children" do
        allow(route_loader).to receive(:handle_path).with(filepath).and_call_original # don't interfere with the original call
        allow(router).to receive(:namespace).and_yield # don't interfere with the namespace block
        expect(route_loader).to receive(:handle_path).with(children[0])
        subject
      end
    end

    context "when path is a file" do
      let(:filepath) { Pathname.new("my_directory") }

      before do
        allow(filepath).to receive(:file?).and_return(true)
      end

      it "passes through to process_file" do
        expect(route_loader).to receive(:process_file).with(filepath)
        subject
      end
    end
  end

  describe "#load_routes" do
    let(:children) { ["child_path_a", "child_path_b"] }

    subject { route_loader.send(:load_routes, :router_test) }

    before do
      allow(route_loader).to receive(:sorted_children).and_return(children)
      allow(route_loader).to receive(:handle_path)
    end

    it "sets the router to the provided router" do
      subject
      expect(route_loader.instance_variable_get(:@router)).to eq(:router_test)
    end

    it "calls handle_path for the children" do
      children.each { |child| expect(route_loader).to receive(:handle_path).with(child) }
      subject
    end

    context "when routes folder doesn't exist" do
      let(:routes_folder) { Pathname.new(`pwd`.strip).join("bad_directory") }

      it "returns before the sorted_children call" do
        expect(route_loader).not_to receive(:sorted_children)
        subject
      end
    end
  end

  describe ".build_routes" do
    let(:app)          { double("RailsApplication") }

    subject do
      described_class.new(Konmari::Routes::Configuration.new.tap do |c|
        c.routes_path = routes_folder
        c.application = app
      end)
    end

    before do
      allow_any_instance_of(described_class).to receive(:build_routes).and_call_original
    end

    it "calls load_routes" do
      allow(app).to receive_message_chain(:routes, :draw).and_yield
      expect_any_instance_of(described_class).to receive(:load_routes)
      subject
    end
  end
end
