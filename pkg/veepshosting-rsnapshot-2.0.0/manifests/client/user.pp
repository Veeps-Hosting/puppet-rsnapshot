class rsnapshot::client::user (
  $client_user          = '',
  $push_ssh_key         = true,
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

  # Setup Group
  group { $client_user :
    before => User[$client_user],
    ensure => present,
  }

  # Setup User
  user { $client_user :
    ensure         => present,
    gid            => $client_user,
    home           => "/home/${client_user}",
    managehome     => true,
    purge_ssh_keys => true,
    shell          => '/bin/bash',
  }

  ## Get Key for remote backup user
  if $push_ssh_key {
    $backup_server_ip     = inline_template("<%= Addrinfo.getaddrinfo('${server}', 'ssh', nil, :STREAM).first.ip_address %>")
    $server_user_exploded = "${server_user}@${server}"

    sshkeys::set_authorized_key { "${server_user_exploded} to ${client_user}":
      local_user  => $client_user,
      options     => [
        "command=\"${allowed_command}\"",
        'no-port-forwarding',
        'no-agent-forwarding',
        'no-X11-forwarding',
        'no-pty',
        "from=\"${backup_server_ip},${server}\""
      ],
      remote_user => $server_user_exploded,
      require     => User[$client_user],
      target      => "/home/${client_user}/.ssh/authorized_keys",

    }
  }

  # Add sudo config if needed.
  if $use_sudo and $setup_sudo {
    sudo::conf { 'backup_user':
      content  => "${client_user} ALL= NOPASSWD: ${wrapper_path}/rsync_sender.sh",
      priority => 99,
      require  => User[$client_user]
    }
  }
}
