
class backup {

  # import the various definitions
  Ssh_authorized_key <<| tag == 'host' |>>

}
  
class backup::target {

  $backup_script = '/usr/local/sbin/nightly-backup.sh'

  # Make sure bzip2 installed - mainly for the lean debian installs
  package { "bzip2":
    ensure => installed,
  }
  
  # Install the backup script
  file { $backup_script:
    ensure  => present,
    content => template( "backup/backup-script.erb" ),
    mode    => '0750',
    owner   => root,
    group   => root,
  }
  
  # Backup script will sleep a random number of seconds (0 - 5 hrs) before starting backup process
  cron { backup:
    ensure  => present,
    command => $backup_script,
    user    => root,
    hour    => fqdn_rand(5),
    minute  => fqdn_rand(59)
  }

  file { '/var/log/backups':
    ensure => directory,
    owner  => root, 
    group  => root,
    mode   => '0750',
  }

}


