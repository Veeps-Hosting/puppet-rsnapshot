# Changelog
All notable changes to this project will be documented in this file.

# Release 2.1.8
* Minor fix to ensure different types of backups (daily, weekly, monthly) don't interfere with each other, by adding a retry loop in BASH. Add new Ubuntu LTS support.

# Release 2.1.6
* Minor bugfix to Client config log_level (5=warning)

# Release 2.1.4
* Merged change from contributor dmaes to fix the backup_point template (https://github.com/Veeps-Hosting/puppet-rsnapshot/commit/0ecd8ef49da314c1dc4728dae6833314daab0587)
* Fixed variable 'log_level' with a default setting of 'warning'
* Remove defunct and deprecated OS and Puppet versions / options

# Release 2.1.2
* Allow multiple values for "hourly" backups, once per day is not useful in the context it's intended
* Weekly backup hour moved to a parameter

# Release 2.1.0
* Added rsync_wrappers parameter, to support:
* Added example Windows client profile class

# Release 2.0.4
* Minor bugfix to preserve hardlinks

# Release 2.0.2
* Module made PDK compatible
* Module defaults to "preserving hard links" from source, saving backup target space
* Module has been thoroughly tested on Ubuntu 20.04 and is fully compatible
* Module has been thoroughly tested on Puppet 7

## Release 2.0.1
Open source initial release of internal module, forked from upstream, with documented improvements.
**Features**

**Bugfixes**

**Known Issues**
