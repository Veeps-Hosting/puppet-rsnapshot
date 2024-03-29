# This class defines the rsnapshot::backup
define rsnapshot::backup (
  $source_path,
  $host    = "${facts['networking']['fqdn']}",
  $options = {},
){
  @@rsnapshot::server::backup_config { "${host}_${source_path}":
    client_user => $::rsnapshot::client::client_user,
    config_file => undef,
    host        => $host,
    options     => $options,
    server      => $::rsnapshot::client::server,
    source_path => $source_path,
  }
}
