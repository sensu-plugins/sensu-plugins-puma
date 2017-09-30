# Change Log
This project adheres to [Semantic Versioning](http://semver.org/).

This CHANGELOG follows the format listed listed [here](https://github.com/sensu-plugins/community/blob/master/HOW_WE_CHANGELOG.md)

## [Unreleased]

## [2.0.0] - 2017-09-30
### Breaking Change
- updated `sensu-plugin` dependency to 2.x (@majormoses)

### Changed
- updated changelog guideline location (@majormoses)

### Fixed
- pr template spelling (@majormoses)

### Added
- Support for Puma v3 state files (@dnd)
- Parsing of stats output with multiple workers (@dnd)
- Ability to pass `--control-url` and `--auth-token` directly instead of state file (@dnd)
- Support for connecting to control servers running on TCP ports (@dnd)
- Add `--gc-stats` flag to allow collecting GC stats (@dnd)

### Removed
- Dependency on `puma`

## [1.0.0] - 2017-06-25
### Added
- Support for Ruby 2.3 and 2.4 (@eheydrick)

### Removed
- Support for Ruby < 2 (@eheydrick)

### Changed
- Loosen `sensu-plugin` dependency to `~> 1.2` (@mattyjones)
- Update to Rubocop `0.40` and cleanup (@eheydrick)

## [0.0.3] - 2015-07-14
### Changed
- updated sensu-plugin gem to 1.2.0

## [0.0.2] - 2015-06-03
### Fixed
- added binstubs

### Changed
- removed cruft from /lib

## 0.0.1 - 2015-04-30
### Added
- initial release

[Unreleased]: https://github.com/sensu-plugins/sensu-plugins-puma/compare/2.0.0...HEAD
[2.0.0]: https://github.com/sensu-plugins/sensu-plugins-puma/compare/1.0.0...2.0.0
[1.0.0]: https://github.com/sensu-plugins/sensu-plugins-puma/compare/0.0.3...1.0.0
[0.0.3]: https://github.com/sensu-plugins/sensu-plugins-puma/compare/0.0.2...0.0.3
[0.0.2]: https://github.com/sensu-plugins/sensu-plugins-puma/compare/0.0.1...0.0.2
