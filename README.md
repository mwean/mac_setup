# MacSetup

This is a tool for setting up a new Mac and keeping it up to date. It uses Homebrew to install formulas and applications (using Homebrew casks).

[![Build Status](https://img.shields.io/travis/mwean/mac_setup.svg)](https://travis-ci.org/mwean/mac_setup) [![Code Climate](https://img.shields.io/codeclimate/github/mwean/mac_setup.svg)](https://codeclimate.com/github/mwean/mac_setup) [![Coverage Status](https://img.shields.io/codeclimate/coverage/github/mwean/mac_setup.svg)](https://codeclimate.com/github/mwean/mac_setup/coverage) ![Gem Version](https://img.shields.io/gem/v/mac_setup.svg)

## Installation

    $ gem install mac_setup

## Usage

Create a config file at `~/.mac_setup.yml` and run `mac_setup`.

You can also specify the config file location:

    $ mac_setup ~/path/to/config.yml

## Config File Format

```yaml
taps:
  - caskroom/fonts
  - homebrew/dupes
  - homebrew/versions

formulas:
  - git
  - openssl
  - postgresql
  - redis
  - zsh

casks:
  - google-chrome
  - slack

launch_agents:
  - postgresql
  - redis
```

## Development

After checking out the repo, run `bin/setup` to install dependencies. Then, run `rake spec` to run the tests. You can also run `bin/console` for an interactive prompt that will allow you to experiment. Run `bundle exec mac_setup` to use the gem in this directory, ignoring other installed copies of this gem.

To install this gem onto your local machine, run `bundle exec rake install`. To release a new version, update the version number in `version.rb`, and then run `bundle exec rake release`, which will create a git tag for the version, push git commits and tags, and push the `.gem` file to [rubygems.org](https://rubygems.org).

## Contributing

Bug reports and pull requests are welcome on GitHub at https://github.com/mwean/mac_setup. This project is intended to be a safe, welcoming space for collaboration, and contributors are expected to adhere to the [Contributor Covenant](contributor-covenant.org) code of conduct.


## License

The gem is available as open source under the terms of the [MIT License](http://opensource.org/licenses/MIT).

