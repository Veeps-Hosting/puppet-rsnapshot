# Defined class rsnapshot::client::user
class rsnapshot::client::user (
  $client_user          = '',
  $push_ssh_key         = true,
  $purge_ssh_keys       = false,
  $server               = '',
  $server_user          = '',
  $setup_sudo           = true,
  $use_sudo             = true,
  $wrapper_path         = '',
  $wrapper_rsync_sender = $rsnapshot::params::wrapper_rsync_sender,
  $wrapper_rsync_ssh    = $rsnapshot::params::wrapper_rsync_ssh,
  $wrapper_sudo         = $rsnapshot::params::wrapper_sudo,
){
  assert_private()

  $wrapper_path_norm = regsubst($wrapper_path, '\/$', '')
  if($use_sudo) {
    $allowed_command = "${wrapper_path_norm}/${wrapper_sudo}"
  } else {
    $allowed_command = "${wrapper_path_norm}/${wrapper_rsync_ssh}"
  }

  ## Setup Group
  group { $client_user :
    ensure => present,
    before => User[$client_user],
  }

  ## Setup User
  user { $client_user :
    ensure         => present,
    gid            => $client_user,
    home           => "/home/${client_user}",
    managehome     => true,
    purge_ssh_keys => $purge_ssh_keys,
    shell          => '/bin/bash',
  }

  ## Setup a public key trust from the rsnapshot servers root user
  if $push_ssh_key == true {
    concat {"/home/${client_user}/.ssh/authorized_keys":
      ensure => present,
      mode   => '0600',
      owner  => $client_user,
      group  => $client_user,
    }
    Concat::Fragment <<|tag=="${server}_rsnapshot_server_key"|>>
  }

  ## Add sudo config if needed.
  if $use_sudo and $setup_sudo {
    sudo::conf { 'backup_user':
      content  => "${client_user} ALL= NOPASSWD: ${wrapper_path}/rsync_sender.sh",
      priority => 99,
      require  => User[$client_user]
    }
  }
}
