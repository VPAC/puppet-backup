Overview
========
Puppet module to backup a file system and send it to a remote server via SSH

Variables needed
================

Required
--------
# List of backup server to use
$backup_servers = ['server1', 'server2']
# Mounts to exclude, separated by a pipe
$backup_exclude_mounts_regex = 'home|backups'
# File patterns to exclude, space separated
$backup_exclude_files = '/tmp/* /var/tmp/*'
# number of days backups to keep
$backup_days_to_keep = 3
# SSH user on backup host
$backup_username = 'backups'
# Don't backup filesystems greater than (in GB)
$backup_max_fs_size = 249


Set up
======

Backup server
-------------

node 'backupserver.mydomain' {
     include backup
}

Backup target
-------------
node 'host-needing-backup.mydomain {
     include backup::target
}


SSH Keys
--------
The backup class depends on the following being defined *somewhere*
It needs to be on every node that you are backing up.

  # Define root's ssh key
  @@ssh_authorized_key { "root@$fqdn":
    type => ssh-rsa,
    key  => $rootsshkey,
    user => $backup_username,
    tag  => 'host',
  }

  # Generate a new SSH key, if it doesn't exist
  exec { "generate-new-key":
    command => "ssh-keygen -q -t rsa -f /root/.ssh/id_rsa -N ''",
    path => "/usr/bin:/usr/sbin:/bin:/sbin",
    creates => "/root/.ssh/id_rsa.pub",
  }
