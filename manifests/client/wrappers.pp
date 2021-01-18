# Defined class rsnapshot::client::wrappers
class rsnapshot::client::wrappers (
  $cmd_client_rsync     = $rsnapshot::params::cmd_client_rsync,
  $cmd_client_sudo      = $rsnapshot::params::cmd_client_sudo,
  $postexec             = [],
  $preexec              = [],
  $wrapper_path         = $rsnapshot::params::wrapper_path,
  $wrapper_rsync_sender = $rsnapshot::params::wrapper_rsync_sender,
  $wrapper_rsync_ssh    = $rsnapshot::params::wrapper_rsync_ssh,
  $wrapper_sudo         = $rsnapshot::params::wrapper_sudo,
) inherits rsnapshot::params {
  assert_private()

  file { $wrapper_path :
    ensure => directory,
    before => File["${wrapper_path}/${wrapper_rsync_sender}"],
    group  => 'root',
    mode   => '0744',
    owner  => 'root',
  }

  file { "${wrapper_path}/${wrapper_rsync_sender}" :
    ensure  => present,
    before  => File["${wrapper_path}/${wrapper_rsync_ssh}"],
    content => template("rsnapshot/${wrapper_rsync_sender}.erb"),
    group   => 'root',
    mode    => '0755',
    owner   => 'root',
  }

  file { "${wrapper_path}/${wrapper_rsync_ssh}" :
    ensure  => present,
    before  => File["${wrapper_path}/${wrapper_sudo}"],
    content => template("rsnapshot/${wrapper_rsync_ssh}.erb"),
    group   => 'root',
    mode    => '0755',
    owner   => 'root',
  }

  file { "${wrapper_path}/${wrapper_sudo}" :
    ensure  => present,
    content => template("rsnapshot/${wrapper_sudo}.erb"),
    group   => 'root',
    mode    => '0755',
    owner   => 'root',
  }

}
