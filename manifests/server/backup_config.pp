# Defines rsnapshot::server::backup_config
define rsnapshot::server::backup_config (
  $config_file,
  $host,
  $server,
  $source_path,
  $client_user = $rsnapshot::params::client_backup_user,
  $options = {},
){
  assert_private()
  concat::fragment { "${config_file}_entry_${source_path}" :
    content => template('rsnapshot/backup_point.erb'),
    order   => 20,
    target  => $config_file,
  }
}
