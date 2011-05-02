
class backup {

  # import the various definitions
  Ssh_authorized_key <<| tag == 'backup' |>>

  define service()
  {
    include backup::backup_target

    @@ssh_authorized_key { "root@$fqdn":
      type => ssh-rsa,
      key  => $rootsshkey,
      user => backups,
      tag  => 'backup'
    }
    
  }
  
  class backup_target {

    $backup_server = "isis.in.vpac.org"

    # Make sure bzip2 installed - mainly for the lean debian installs
    package { "bzip2":
      ensure => installed,
    }

    # Do the SSH-keyscan so backup isn't prompted
    exec { "ssh-keyscan":
      command => "/usr/bin/ssh-keyscan -trsa $backup_server >> /root/.ssh/known_hosts",
      path => "/usr/bin:/usr/sbin:/bin:/sbin",
      unless => "grep $backup_server /root/.ssh/known_hosts",
    }

    # Generate a new SSH key, if it doesn't exist
    exec { "generate-new-key":
      command => "ssh-keygen -q -t rsa -f /root/.ssh/id_rsa -N ''",
      path => "/usr/bin:/usr/sbin:/bin:/sbin",
      creates => "/root/.ssh/id_rsa.pub",
    }

    # Install the backup script
    file { "/usr/local/sbin/nightly-backup.sh":
      ensure  => present,
      content => template( "backup/backup-script.erb" ),
      mode   => 744,
      owner  => root,
      group  => root,
    }

    # Backup script will sleep a random number of seconds (0 - 5 hrs) before starting backup process
    cron { backup:
      ensure => present,
      command => "/usr/local/sbin/nightly-backup.sh",
      user => root,
      hour => fqdn_rand(5),
      minute => fqdn_rand(59)
    }
  }

}
