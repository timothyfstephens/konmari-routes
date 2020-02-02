# Konmari::Routes

Inspired by thousand-line routes files, KonmariRoutes aims to make routes more manageable by enabling
a routing structure that mirrors the controller file structure of a standard web application, powered by one guiding principle:

Keep only what makes you happy.


This is largely inspired by two articles:

- [Keep your rails routes clean and organized](https://blog.lelonek.me/keep-your-rails-routes-clean-and-organized-83e78f2c11f2)
- [How to split routes.rb into smaller parts](https://blog.arkency.com/2015/02/how-to-split-routes-dot-rb-into-smaller-parts/)

## Installation

Add this line to your application's Gemfile:

```ruby
gem 'konmari-routes'
```

And then execute:

    $ bundle

Or install it yourself as:

    $ gem install konmari-routes

## Usage

To start using `konmari-routes` you simply need to add a configuration block to your `config/routes.rb` file, outside the standard `routes.draw` block. (Suggest putting at the very top, but bottom works too.  Note that where you put it is where the routes will be rendered.)

```
  Konmari::Routes.config do |c|
    c.routes_path = Rails.root.join("config/routes")
  end
```

This will recursively load all files in `config/routes`, using the folder names to make namespaces for the resources in the files contained in each directory.

As a start, it is recommended to just move each top level namespace into on `index.routes` file contained in a folder matching that namespace - you can use any standard `namespace`/`resource`/`etc` block in any file, as long the first line matches the filename.

It is also recommended that before/during this process you ensure that you have all routes spec'd properly, as this will provide substantial peace of mind during the transition process, and after all, peace of mind, tranquility, and cleanliness is what we are aiming to acheive.

## Development

After checking out the repo, run `bin/setup` to install dependencies. Then, run `rake spec` to run the tests. You can also run `bin/console` for an interactive prompt that will allow you to experiment.

To install this gem onto your local machine, run `bundle exec rake install`. To release a new version, update the version number in `version.rb`, and then run `bundle exec rake release`, which will create a git tag for the version, push git commits and tags, and push the `.gem` file to [rubygems.org](https://rubygems.org).

## Contributing

Bug reports and pull requests are welcome on GitHub at https://github.com/timothyfstephens/konmari-routes. This project is intended to be a safe, welcoming space for collaboration, and contributors are expected to adhere to the [Contributor Covenant](http://contributor-covenant.org) code of conduct.

## License

The gem is available as open source under the terms of the [MIT License](https://opensource.org/licenses/MIT).

## Code of Conduct

Everyone interacting in the Konmari::Routes project’s codebases, issue trackers, chat rooms and mailing lists is expected to follow the [code of conduct](https://github.com/timothyfstephens/konmari-routes/blob/master/CODE_OF_CONDUCT.md).
