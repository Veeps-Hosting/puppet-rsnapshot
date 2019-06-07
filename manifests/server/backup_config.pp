define rsnapshot::server::backup_config (
  $client_user = $rsnapshot::params::client_backup_user,
  $config_file,
  $host,
  $options = {},
  $server,
  $source_path,
){
  assert_private()
  concat::fragment { "${config_file}_entry_${source_path}" :
    content => template('rsnapshot/backup_point.erb'),
    order   => 20,
    target  => $config_file,
  }
}
