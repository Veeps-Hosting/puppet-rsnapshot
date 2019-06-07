# == Class: rsnapshot::client
# === Example
#class { 'rsnapshot::client':
#  exclude_files  => ['var/session'],
#  server         => lookup('rsnapshot_server'),
#}
class rsnapshot::client (
  $backup_hourly_cron   = $rsnapshot::params::backup_hourly_cron,
  $backup_time_dom      = $rsnapshot::params::backup_time_dom,
  $backup_time_hour     = $rsnapshot::params::backup_time_hour,
  $backup_time_minute   = $rsnapshot::params::backup_time_minute,
  $backup_time_weekday  = $rsnapshot::params::backup_time_weekday,
  $client_user          = $rsnapshot::params::client_user,
  $cmd_client_rsync     = $rsnapshot::params::cmd_client_rsync,
  $cmd_client_sudo      = $rsnapshot::params::cmd_client_sudo,
  $cmd_postexec         = $rsnapshot::params::cmd_postexec,
  $cmd_preexec          = $rsnapshot::params::cmd_preexec,
  $cmd_wrapper_postexec = [],
  $cmd_wrapper_preexec  = [],
  $directories          = ['/etc','/home','/root','/var/www','/opt/mysqldumps'],
  $exclude_files        = {},
  $excludes             = {},
  $include_files        = {},
  $includes             = {},
  $one_fs               = $rsnapshot::params::one_fs,
  $push_ssh_key         = $rsnapshot::params::push_ssh_key,
  $retain_daily         = $rsnapshot::params::retain_daily,
  $retain_hourly        = $rsnapshot::params::retain_hourly,
  $retain_monthly       = $rsnapshot::params::retain_monthly,
  $retain_weekly        = $rsnapshot::params::retain_weekly,
  $rsync_long_args      = $rsnapshot::params::rsync_long_args,
  $rsync_short_args     = $rsnapshot::params::rsync_short_args,
  $server,
  $server_user          = $rsnapshot::params::server_user,
  $setup_sudo           = $rsnapshot::params::setup_sudo,
  $ssh_args             = $rsnapshot::params::ssh_args,
  $use_sudo             = $rsnapshot::params::use_sudo,
  $wrapper_path         = $rsnapshot::params::wrapper_path,
) inherits rsnapshot::params {
  $wrapper_path_normalized = regsubst($wrapper_path, '\/$', '')

  # Install
  include rsnapshot::client::install

  # Add User
  class { 'rsnapshot::client::user' :
    client_user  => $client_user,
    push_ssh_key => $push_ssh_key,
    server       => $server,
    server_user  => $server_user,
    setup_sudo   => $setup_sudo,
    use_sudo     => $use_sudo,
    wrapper_path => $wrapper_path_normalized,
  }

  # Add Wrapper Scripts
  class { 'rsnapshot::client::wrappers' :
    cmd_client_rsync => $cmd_client_rsync,
    cmd_client_sudo  => $cmd_client_sudo,
    postexec         => $cmd_wrapper_postexec,
    preexec          => $cmd_wrapper_preexec,
    wrapper_path     => $wrapper_path_normalized,
  }

  # Export client object to get picked up by the server.
  @@rsnapshot::server::config { $::fqdn:
    backup_hourly_cron  => $backup_hourly_cron,
    backup_time_dom     => $backup_time_dom,
    backup_time_hour    => $backup_time_hour,
    backup_time_minute  => $backup_time_minute,
    backup_time_weekday => $backup_time_weekday,
    client_user         => $client_user,
    cmd_postexec        => $cmd_postexec,
    cmd_preexec         => $cmd_preexec,
    directories         => $directories,
    exclude_files       => $exclude_files,
    excludes            => $excludes,
    include_files       => $include_files,
    includes            => $includes,
    one_fs              => $one_fs,
    retain_daily        => $retain_daily,
    retain_hourly       => $retain_hourly,
    retain_monthly      => $retain_monthly,
    retain_weekly       => $retain_weekly,
    rsync_long_args     => $rsync_long_args,
    rsync_short_args    => $rsync_short_args,
    server              => $server,
    ssh_args            => $ssh_args,
    use_sudo            => $use_sudo,
    wrapper_path        => $wrapper_path_normalized,
  }

}
