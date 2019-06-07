# == Class: rsnapshot

class rsnapshot::server(
  $backup_path            = $rsnapshot::params::server_backup_path,
  $config_path            = $rsnapshot::params::server_config_path,
  $du_args                = $rsnapshot::params::du_args,
  $link_dest              = $rsnapshot::params::link_dest,
  $lock_path              = $rsnapshot::params::lock_path,
  $log_level              = $rsnapshot::params::log_level,
  $log_path               = $rsnapshot::params::server_log_path,
  $no_create_root         = $rsnapshot::params::no_create_root,
  $rsync_numtries         = $rsnapshot::params::rsync_numtries,
  $server_user            = $rsnapshot::params::server_user,
  $stop_on_stale_lockfile = $rsnapshot::params::stop_on_stale_lockfile,
  $sync_first             = $rsnapshot::params::sync_first,
  $use_lazy_deletes       = $rsnapshot::params::use_lazy_deletes,
  $verbose                = $rsnapshot::params::verbose,
) inherits rsnapshot::params {

  include rsnapshot::server::install
  include rsnapshot::server::cron_script

  # Auto create root 4096 bit SSH RSA key pair if it doesn't exist
  exec { 'create root ssh key pair':
    command     => 'ssh-keygen -b 4096 -t rsa -f /root/.ssh/id_rsa -q -N ""',
    creates     => ['/root/.ssh/id_rsa','/root/.ssh/id_rsa.pub'],
    path        => $::path,
  }

  $rsnapshot_logrotate = @(EOF)
  <%= @log_path %>/*.log {
    compress
    missingok
    monthly
    rotate 3
  }
  | EOF

  file { '/etc/logrotate.d/rsnapshot':
    backup  => false,
    content => inline_template($rsnapshot_logrotate),
    ensure  => present,
    group   => root,
    owner   => root,
    replace => true,
  }

  file { '/etc/cron.daily/logrotate': ensure => absent}


  # Add logging folder
  file { $log_path :
    ensure => directory,
    group  => $server_user,
    owner  => $server_user,
  }

  # Add config path
  file { $config_path :
    ensure  => directory,
    group   => $server_user,
    owner   => $server_user,
    purge   => true,
    recurse => true,
  }

  # Add logging folder
  file { $backup_path :
    ensure => directory,
    group  => $server_user,
    owner  => $server_user,
  }

  Rsnapshot::Server::Config <<| server == $::fqdn |>> {
    backup_path            => $::rsnapshot::server::backup_path,
    config_path            => $::rsnapshot::server::config_path,
    du_args                => $::rsnapshot::server::du_args,
    link_dest              => $::rsnapshot::server::link_dest,
    lock_path              => $::rsnapshot::server::lock_path,
    loglevel               => $::rsnapshot::server::loglevel,
    log_path               => $::rsnapshot::server::log_path,
    no_create_root         => $::rsnapshot::server::no_create_root,
    require                => File[$config_path],
    rsync_numtries         => $::rsnapshot::server::rsync_numtries,
    server_user            => $server_user,
    stop_on_stale_lockfile => $::rsnapshot::server::stop_on_stale_lockfile,
    sync_first             => $::rsnapshot::server::sync_first,
    use_lazy_deletes       => $::rsnapshot::server::use_lazy_deletes,
    verbose                => $::rsnapshot::server::verbose,
  }

}
