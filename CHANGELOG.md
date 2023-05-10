# Changelog
All notable changes to this project will be documented in this file.

# Release 2.2.1
* Minor maintenance release, 2 new parameters in server.pp to allow an Rsnapshot server to backup Windows nodes.
Hiera example:
rsnapshot::server::platform: 'windows'
rsnapshot::server::target: 'C:/ProgramData/ssh/administrators_authorized_keys'

# Release 2.2.0
* Remove dependency on jtopjian-sshkeys module for public key transfer from server to client. The deprecated sshkeys module relies on dalen-puppetdbquery, and both os these modules seem to be abandon-ware, no updates for 7+ years. The puppetdbquery module doesn't work correctly with puppetserver8, so this functionality was migrated to use concat fragments instead. Both modules can be safely removed from your repos if nothing else depends on them.
* Added a new parameter ''$purge_ssh_keys' to manage the purging of ssh keys upon user creation and management - required to make the above concat fragments work correctly.
* Bumped Puppet requirement to 7 to remain on supported versions, legacy versions such as 5 and 6 will likely still work fine.


# Release 2.1.9
* Change ssh_args to work as part of the options, instead of as an "rsync -e 'ssh <do something' arguement>'", which didn't seem to work as expected
* Ubuntu 22.04 compatibility tested and added

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
