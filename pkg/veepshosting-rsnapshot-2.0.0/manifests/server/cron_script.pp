class rsnapshot::server::cron_script (
  $backup_hourly_cron  = $rsnapshot::params::backup_hourly_cron,
  $backup_time_minute  = $rsnapshot::params::backup_time_minute,
  $backup_time_hour    = $rsnapshot::params::backup_time_hour,
  $backup_time_weekday = $rsnapshot::params::backup_time_weekday,
  $backup_time_dom     = $rsnapshot::params::backup_time_dom,
  $retain_hourly       = $rsnapshot::params::retain_hourly,
  $retain_daily        = $rsnapshot::params::retain_daily,
  $retain_weekly       = $rsnapshot::params::retain_weekly,
  $retain_monthly      = $rsnapshot::params::retain_monthly,
  $script_path         = $rsnapshot::params::script_path,
  $server_config_path  = $rsnapshot::params::server_config_path,
  $server_user         = $rsnapshot::params::server_user,
) inherits rsnapshot::params {
  assert_private()
  
  file { $script_path:
    ensure => directory,
    group  => root,
    mode   => '0755',
    owner  => root,
  }

  file { "$script_path/rsnapshot_backup.sh":
    content => template('rsnapshot/rsnapshot_backup.sh.erb'),
    ensure  => present,
    group   => root,
    mode    => '0544',
    owner   => root,
    require => File[$script_path],
  }

  if ($retain_hourly > 0) {
    cron { rsnapshot-hourly :
      command => '/etc/rsnapshot/scripts/rsnapshot_backup.sh hourly',
      minute  => $backup_time_minute,
      hour    => $backup_hourly_cron,
      user    => $server_user,
    }
  }

  if ($retain_daily > 0) {
    cron { rsnapshot-daily :
      command => '/etc/rsnapshot/scripts/rsnapshot_backup.sh daily',
      hour    => $backup_time_hour,
      minute  => $backup_time_minute,
      user    => $server_user,
    }
  }

  if ($retain_weekly > 0) {
    cron { rsnapshot-weekly :
      command => '/etc/rsnapshot/scripts/rsnapshot_backup.sh weekly',
      hour    => ($backup_time_hour + 12) % 24,
      minute  => $backup_time_minute,
      user    => $server_user,
      weekday => $backup_time_weekday,
    }
  }

  if ($retain_monthly > 0) {
    cron { rsnapshot-monthly :
      command  => '/etc/rsnapshot/scripts/rsnapshot_backup.sh monthly',
      hour     => ($backup_time_hour + 10) % 24,
      minute   => $backup_time_minute,
      monthday => $backup_time_dom,
      user     => $server_user,
    }
  }

}
