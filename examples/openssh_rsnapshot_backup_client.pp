# Dependencies: ['puppetlabs-chocolatey','puppetlabs-powershell','puppet-windows_firewall'] & working PuppetDB
class profile::openssh_rsnapshot_backup_client (
  $local_user       = 'Administrator',
  $backup_target    = 'root@backup_target.example.domain',
  $target           = 'C:/ProgramData/ssh/administrators_authorized_keys',
  $directories      = ['/cygdrive/c/Users/','/cygdrive/c/inetpub/'],
  $key_type         = 'ecdsa-sha2-nistp256',
  $retain_daily     = '14',
  $retain_monthly   = '2',
  $retain_weekly    = '8',
  $rsync_long_args  = '--delete --numeric-ids --relative --delete-excluded',
  $rsync_short_args = '-a',
  $rsync_wrapper    = false,
){

  # Source Chocolatey package
  package { 'openssh': ensure => present}

  # Installs the SSH service, after Chocolatey packages in place
  exec { 'install-sshd':
    before    => Service['sshd','ssh-agent'],
    command   => '& "C:/Program Files/OpenSSH-Win64/install-sshd.ps1"',
    onlyif    => 'if (get-service -name sshd){exit 1}',
    provider  => powershell,
    require   => Package['openssh'],
    notify    => Service['sshd','ssh-agent'],
  }

  # Core SSH service
  service { 'sshd':
    enable    => true,
    ensure    => running,
    require   => Exec['install-sshd'],
    subscribe => File[$target],
  }

  # Service that manages public key trust
  service { 'ssh-agent':
    enable    => true,
    ensure    => running,
    require   => Exec['install-sshd'],
    subscribe => File[$target],
  }

  # Get the backup servers public host-key, and open the firewall for SSH to the rsnapshot server

  # Split the backup target into username and destination server
  $parts           = split($backup_target, '@')
  $remote_username = $parts[0]
  $remote_node     = downcase($parts[1])
  # Query PuppetDB to get the destination backup server IP for the Firewall rule
  $remote_ip       = inline_template("<%= Addrinfo.getaddrinfo('${remote_node}', 'ssh', nil, :STREAM).first.ip_address %>")

  # Open the SSH port in the firewall, to the rsnapshot server
  windows_firewall::exception { "SSH from $remote_node":
    action       => 'allow',
    description  => "SSH from $remote_node",
    direction    => 'in',
    display_name => "SSH from $remote_node",
    enabled      => true,
    ensure       => present,
    local_port   => 22,
    protocol     => 'TCP',
    remote_ip    => $remote_ip,
    remote_port  => 'any',
  }

  # Get the destination node via FQDN or Hostname fact, depending on '.' presence
  if $remote_node =~ /\./ {
    $results = query_facts("fqdn=\"${remote_node}\"", ["sshpubkey_${remote_username}"])
  } else {
    $results = query_facts("hostname=\"${remote_node}\"", ["sshpubkey_${remote_username}"])
  }
  if is_hash($results) and has_key($results, $remote_node) {
    $key = $results[$remote_node]["sshpubkey_${remote_username}"]
    # Create source directory before service to ensure no dependency failure loop
    file { 'C:/ProgramData/ssh': ensure => directory, before => File[$target]}
    # Import the host public key from the rsnapshot server and restart services
    file { $target:
      content => inline_template($key),
      notify  => Service['sshd','ssh-agent'],
    }
    # Ensure correct permissions on the public key file so the services can read it
    acl { $target:
      purge       => true,
      permissions => [
       {identity => 'Administrators', rights => ['full'] },
       {identity => 'SYSTEM',         rights => ['full'] }
      ],
      inherit_parent_permissions => false,
      require => File[$target],
      notify  => Service['sshd','ssh-agent'],
    }
  }

  # Inline template for secure sshd_config
  $sshd_config= @(EOF)
  AddressFamily any
  Port 22
  ListenAddress 0.0.0.0
  AcceptEnv LANG LC_*
  AllowTcpForwarding yes
  Banner none
  ChallengeResponseAuthentication no
  ClientAliveCountMax 3
  ClientAliveInterval 0
  Compression delayed
  GSSAPIAuthentication yes
  GSSAPICleanupCredentials yes
  HostKey __PROGRAMDATA__/ssh/ssh_host_ecdsa_key
  HostbasedAuthentication no
  IgnoreRhosts yes
  IgnoreUserKnownHosts no
  LogLevel INFO
  LoginGraceTime 120
  PasswordAuthentication no
  PermitEmptyPasswords no
  PermitRootLogin without-password
  PermitTunnel no
  PrintMotd no
  Protocol 2
  PubkeyAuthentication yes
  StrictModes yes
  Subsystem       sftp    sftp-server.exe
  SyslogFacility AUTH
  TCPKeepAlive yes
  UseDNS no
  X11Forwarding yes
  Match Group administrators
         AuthorizedKeysFile __PROGRAMDATA__/ssh/administrators_authorized_keys
  | EOF
  file { 'C:/ProgramData/ssh/sshd_config':
    content => inline_template($sshd_config),
    notify  => Service['sshd','ssh-agent'],
    require => File['C:/ProgramData/ssh'],
  }

  # Export the backup job to the Rsnapshot server
  @@rsnapshot::server::config { $::fqdn:
    client_user      => $local_user,
    directories      => $directories,
    retain_daily     => $retain_daily,
    retain_monthly   => $retain_monthly,
    retain_weekly    => $retain_weekly,
    rsync_long_args  => $rsync_long_args,
    rsync_short_args => $rsync_short_args,
    rsync_wrapper    => $rsync_wrapper,
    server           => $remote_node,
  }

  # Flatten every name the backup client can be reached via, here only hostname, could also be IP(s)
  $host_aliases = unique(flatten([ $::fqdn, $::hostname]))

  # Export the Host SSH key for collection on the Rsnapshot server
  @@sshkey { "${::fqdn}_${key_type}":
    ensure       => present,
    host_aliases => $host_aliases,
    type         => $key_type,
    key          => $facts['ssh_hostkey'],
  }

}
