RSpec.describe Konmari::Routes do
  it "has a version number" do
    expect(Konmari::Routes::VERSION).not_to be nil
  end

  describe ".config" do
    let(:app)          { double("RailsApplication") }

    it "accepts a block to set configuration" do
      allow_any_instance_of(Konmari::Routes::Loader).to receive(:build_routes)
      expect { |spec| described_class.config(&spec) }.to yield_with_args(Konmari::Routes::Configuration)
    end

    it "runs the routes drawer" do
      expect_any_instance_of(Konmari::Routes::Loader).to receive(:build_routes)
      described_class.config do |c|
        c.routes_path = `pwd`.strip
        c.application = app
      end
    end
  end
end
