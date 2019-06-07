define rsnapshot::server::config (
  $backup_hourly_cron     = $rsnapshot::params::backup_hourly_cron,
  $backup_path            = $rsnapshot::params::server_backup_path,
  $backup_time_dom        = $rsnapshot::params::backup_time_dom,
  $backup_time_hour       = $rsnapshot::params::backup_time_hour,
  $backup_time_minute     = $rsnapshot::params::backup_time_minute,
  $backup_time_weekday    = $rsnapshot::params::backup_time_weekday,
  $client_user            = $rsnapshot::params::client_user,
  $cmd_postexec           = $rsnapshot::params::cmd_postexec,
  $cmd_preexec            = $rsnapshot::params::cmd_preexec,
  $config_path            = $rsnapshot::params::server_config_path,
  $directories            = {},
  $du_args                = $rsnapshot::params::du_args,
  $exclude_files          = {},
  $excludes               = {},
  $fqdn                   = $name,
  $include_files          = {},
  $includes               = {},
  $link_dest              = $rsnapshot::params::link_dest,
  $lock_path              = $rsnapshot::params::lock_path,
  $log_level              = $rsnapshot::params::log_level,
  $log_path               = $rsnapshot::params::server_log_path,
  $no_create_root         = $rsnapshot::params::no_create_root,
  $one_fs                 = $rsnapshot::params::one_fs,
  $retain_daily           = $rsnapshot::params::retain_daily,
  $retain_hourly          = $rsnapshot::params::retain_hourly,
  $retain_monthly         = $rsnapshot::params::retain_monthly,
  $retain_weekly          = $rsnapshot::params::retain_weekly,
  $rsync_long_args        = $rsnapshot::params::rsync_long_args,
  $rsync_numtries         = $rsnapshot::params::rsync_numtries,
  $rsync_short_args       = $rsnapshot::params::rsync_short_args,
  $server                 = $::fqdn,
  $server_user            = $rsnapshot::params::server_user,
  $ssh_args               = $rsnapshot::params::ssh_args,
  $stop_on_stale_lockfile = $rsnapshot::params::stop_on_stale_lockfile,
  $sync_first             = $rsnapshot::params::sync_first,
  $use_lazy_deletes       = $rsnapshot::params::use_lazy_deletes,
  $use_sudo               = false,
  $verbose                = $rsnapshot::params::verbose,
  $wrapper_path           = $rsnapshot::params::wrapper_path,
  $wrapper_rsync_sender   = $rsnapshot::params::wrapper_rsync_sender,
  $wrapper_rsync_ssh      = $rsnapshot::params::wrapper_rsync_ssh,
  $wrapper_sudo           = $rsnapshot::params::wrapper_sudo,
){

  # Remove trailing slashes.
  $log_path_norm = regsubst($log_path, '\/$', '')
  $lock_path_norm = regsubst($lock_path, '\/$', '')
  $config_path_norm = regsubst($config_path, '\/$', '')
  $backup_path_norm = regsubst($backup_path, '\/$', '')
  $wrapper_path_norm = regsubst($wrapper_path, '\/$', '')

  $log_file = "${log_path_norm}/${name}-rsnapshot.log"
  $lock_file = "${lock_path_norm}/${name}-rsnapshot.pid"
  $config_file = "${config_path_norm}/${name}-rsnapshot.conf"
  $snapshot_root = "${backup_path_norm}/${name}"

  if($ssh_args) {
    $ssh_args_processed = "-e 'ssh ${ssh_args}'"
  } else {
    $ssh_args_processed = ''
  }

  if($use_sudo) {
    $rsync_wrapper_processed = "--rsync-path=\"${wrapper_path_norm}/${wrapper_sudo}\""
  } else {
    $rsync_wrapper_processed = "--rsync-path=\"${wrapper_path_norm}/${wrapper_rsync_ssh}\""
  }

  $rsync_long_args_final = strip("${ssh_args_processed} ${rsync_long_args} ${rsync_wrapper_processed}")

  file { $snapshot_root :
    ensure  => directory,
    require => File[$backup_path],
    before  => File[$log_file],
  }

  file { $log_file :
    ensure  => present,
    require => File[$log_path]
  }

  $programs = {
    cmd_cp                 => $rsnapshot::server::cmd_cp,
    cmd_rm                 => $rsnapshot::server::cmd_rm,
    cmd_rsync              => $rsnapshot::server::cmd_rsync,
    cmd_ssh                => $rsnapshot::server::cmd_ssh,
    cmd_logger             => $rsnapshot::server::cmd_logger,
    cmd_du                 => $rsnapshot::server::cmd_du,
    cmd_rsnapshot_diff     => $rsnapshot::server::cmd_rsnapshot_diff,
    linux_lvm_cmd_lvcreate => $rsnapshot::server::linux_lvm_cmd_lvcreate,
    linux_lvm_cmd_lvremove => $rsnapshot::server::linux_lvm_cmd_lvremove,
    linux_lvm_cmd_mount    => $rsnapshot::server::linux_lvm_cmd_mount,
    linux_lvm_cmd_umount   => $rsnapshot::server::linux_lvm_cmd_umount,
  }

  $options = {
    cmd_postexec           => $cmd_postexec,
    cmd_preexec            => $cmd_preexec,
    du_args                => $du_args,
    link_dest              => $link_dest,
    lockfile               => $lock_file,
    logfile                => $log_file,
    loglevel               => $log_level,
    no_create_root         => $no_create_root,
    one_fs                 => $one_fs,
    rsync_long_args        => $rsync_long_args_final,
    rsync_numtries         => $rsync_numtries,
    rsync_short_args       => $rsync_short_args,
    stop_on_stale_lockfile => $stop_on_stale_lockfile,
    sync_first             => $sync_first,
    use_lazy_deletes       => $use_lazy_deletes,
    verbose                => $verbose,
  }

  $lockfile = "${rsnapshot::server::lock_path}${name}"
  $logfile  = "${rsnapshot::server::log_path}${name}"

  # config file
  concat { $config_file :
    group => $server_user,
    mode  => '0644',
    owner => $server_user,
    warn  => true
  }

  concat::fragment { "${config_file}_rsnapshot_header" :
    content => template('rsnapshot/config.erb'),
    order   => 01,
    target  => $config_file,
  }

  Rsnapshot::Server::Backup_config <<| host == $name |>> {
    config_file => $config_file
  }

}
