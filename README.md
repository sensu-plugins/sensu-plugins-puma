## Sensu-Plugins-puma

[![Build Status](https://travis-ci.org/sensu-plugins/sensu-plugins-puma.svg?branch=master)](https://travis-ci.org/sensu-plugins/sensu-plugins-puma)
[![Gem Version](https://badge.fury.io/rb/sensu-plugins-puma.svg)](http://badge.fury.io/rb/sensu-plugins-puma)
[![Code Climate](https://codeclimate.com/github/sensu-plugins/sensu-plugins-puma/badges/gpa.svg)](https://codeclimate.com/github/sensu-plugins/sensu-plugins-puma)
[![Test Coverage](https://codeclimate.com/github/sensu-plugins/sensu-plugins-puma/badges/coverage.svg)](https://codeclimate.com/github/sensu-plugins/sensu-plugins-puma)
[![Dependency Status](https://gemnasium.com/sensu-plugins/sensu-plugins-puma.svg)](https://gemnasium.com/sensu-plugins/sensu-plugins-puma)

## Functionality

## Files
 * bin/metrics-puma

## Usage

## Installation

Add the public key (if you haven’t already) as a trusted certificate

```
gem cert --add <(curl -Ls https://raw.githubusercontent.com/sensu-plugins/sensu-plugins.github.io/master/certs/sensu-plugins.pem)
gem install sensu-plugins-puma -P MediumSecurity
```

You can also download the key from /certs/ within each repository.

#### Rubygems

`gem install sensu-plugins-puma`

#### Bundler

Add *sensu-plugins-disk-checks* to your Gemfile and run `bundle install` or `bundle update`

#### Chef

Using the Sensu **sensu_gem** LWRP
```
sensu_gem 'sensu-plugins-puma' do
  options('--prerelease')
  version '0.0.1.alpha.4'
end
```

Using the Chef **gem_package** resource
```
gem_package 'sensu-plugins-puma' do
  options('--prerelease')
  version '0.0.1.alpha.4'
end
```

## Notes

[1]:[https://travis-ci.org/sensu-plugins/sensu-plugins-puma]
[2]:[http://badge.fury.io/rb/sensu-plugins-puma]
[3]:[https://codeclimate.com/github/sensu-plugins/sensu-plugins-puma]
[4]:[https://codeclimate.com/github/sensu-plugins/sensu-plugins-puma]
[5]:[https://gemnasium.com/sensu-plugins/sensu-plugins-puma]