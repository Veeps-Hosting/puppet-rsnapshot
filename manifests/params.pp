# Class: rsnapshot::params
# This class manages parameters for the rsnapshot module
class rsnapshot::params {
  $backup_hourly_cron     = 0
  $backup_time_dom        = 1
  $backup_time_hour       = 22
  $backup_time_minute     = 0
  $backup_time_weekday    = 0
  $backup_weekly_hour     = 18
  $client_packages        = ['rsync']
  $client_user            = 'rsnapshot'
  $cmd_postexec           = undef
  $cmd_preexec            = undef
  $connect_endpoint       = $facts['networking']['fqdn']
  $du_args                = '-csh'
  $link_dest              = 1
  $log_level              = 'warning'
  $no_create_root         = 0
  $one_fs                 = undef
  $push_ssh_key           = true
  $purge_ssh_keys         = false
  $retain_daily           = 14
  $retain_hourly          = undef
  $retain_monthly         = 2
  $retain_weekly          = 8
  $rsync_long_args        = '--delete --numeric-ids --relative --delete-excluded'
  $rsync_numtries         = 2
  $rsync_short_args       = '-aH'
  $script_path            = '/etc/rsnapshot/scripts'
  $server_backup_path     = '/backups'
  $server_config_path     = '/etc/rsnapshot'
  $server_log_path        = '/var/log/rsnapshot'
  $server_packages        = [ 'rsnapshot' ]
  $server_user            = 'root'
  $setup_sudo             = true
  $ssh_args               = undef
  $stop_on_stale_lockfile = 0
  $sync_first             = 0
  $use_lazy_deletes       = 0
  $use_sudo               = true
  $verbose                = 2
  $wrapper_path           = '/opt/rsnapshot_wrappers/'
  $wrapper_rsync_sender   = 'rsync_sender.sh'
  $wrapper_rsync_ssh      = 'rsync_ssh.sh'
  $wrapper_sudo           = 'rsync_sudo.sh'

  case "${facts[os][family]}" {
    debian: {
      $cmd_client_rsync       = '/usr/bin/rsync'
      $cmd_client_sudo        = '/usr/bin/sudo'
      $cmd_cp                 = '/bin/cp'
      $cmd_du                 = '/usr/bin/du'
      $cmd_logger             = '/usr/bin/logger'
      $cmd_rm                 = '/bin/rm'
      $cmd_rsnapshot_diff     = undef
      $cmd_rsnapshot          = '/usr/bin/rsnapshot'
      $cmd_rsync              = '/usr/bin/rsync'
      $cmd_ssh                = '/usr/bin/ssh'
      $linux_lvm_cmd_lvcreate = undef
      $linux_lvm_cmd_lvremove = undef
      $linux_lvm_cmd_mount    = '/bin/mount'
      $linux_lvm_cmd_umount   = '/bin/umount'
      $lock_path              = '/var/run/'
      $log_path               = '/var/log/'
    }
    redhat: {
      $cmd_client_rsync       = '/usr/bin/rsync'
      $cmd_client_sudo        = '/usr/bin/sudo'
      $cmd_cp                 = '/usr/bin/cp'
      $cmd_du                 = '/usr/bin/du'
      $cmd_logger             = '/usr/bin/logger'
      $cmd_rm                 = '/usr/bin/rm'
      $cmd_rsnapshot_diff     = '/usr/bin/rsnapshot-diff'
      $cmd_rsnapshot          = '/usr/bin/rsnapshot'
      $cmd_rsync              = '/usr/bin/rsync'
      $cmd_ssh                = '/usr/bin/ssh'
      $linux_lvm_cmd_lvcreate = undef
      $linux_lvm_cmd_lvremove = undef
      $linux_lvm_cmd_mount    = '/usr/bin/mount'
      $linux_lvm_cmd_umount   = '/usr/bin/umount'
      $lock_path              = '/run/'
      $log_path               = '/var/log/'
    }
    default: {
      $cmd_client_rsync       = '/usr/bin/rsync'
      $cmd_client_sudo        = '/usr/bin/sudo'
      $cmd_cp                 = undef
      $cmd_du                 = undef
      $cmd_logger             = undef
      $cmd_rm                 = undef
      $cmd_rsnapshot_diff     = undef
      $cmd_rsnapshot          = '/usr/local/bin/rsnapshot'
      $cmd_rsync              = '/usr/bin/rsync'
      $cmd_ssh                = undef
      $linux_lvm_cmd_lvcreate = undef
      $linux_lvm_cmd_lvremove = undef
      $linux_lvm_cmd_mount    = undef
      $linux_lvm_cmd_umount   = undef
      $lock_path              = '/var/run/'
      $log_path               = '/var/log/'
    }
  }

}
