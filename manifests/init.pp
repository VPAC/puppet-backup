
class backup {

  # import the various definitions
  Ssh_authorized_key <<| tag == 'host' |>>

}
  
class backup::target {

  $backup_servers = ['isis.in.vpac.org', 'charles.in.vpac.org']
  
  # Make sure bzip2 installed - mainly for the lean debian installs
  package { "bzip2":
    ensure => installed,
  }
  
  # Install the backup script
  file { "/usr/local/sbin/nightly-backup.sh":
    ensure  => present,
    content => template( "backup/backup-script.erb" ),
    mode    => 750,
    owner   => root,
    group   => root,
  }
  
  # Backup script will sleep a random number of seconds (0 - 5 hrs) before starting backup process
  cron { backup:
    ensure  => present,
    command => "/usr/local/sbin/nightly-backup.sh",
    user    => root,
    hour    => fqdn_rand(5),
    minute  => fqdn_rand(59)
  }
}
