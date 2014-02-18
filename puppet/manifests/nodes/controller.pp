include python

node controller inherits basenode {

  # Make sure the eventlet package is installed in the VM (global) and not on the
  # NFS mounted shared dir (virtualenv) to avoid this bug:
  # https://bitbucket.org/eventlet/eventlet/issue/81/stdlib-queue-not-found-from-within
  pymod { "eventlet":
    name    => "eventlet",
    require => [ 
                 Exec["symlink_easy_install"], 
                 Package["python-dev"]
               ]
  }


  file { '/home/stack/devstack/localrc':
    ensure  => file,
    content => file('/vagrant/puppet/files/controller/localrc'),
    group   => 'stack',
    owner   => 'stack',
    require => Vcsrepo["/home/stack/devstack"],
  }


  file { '/home/stack/devstack/local.sh':
    ensure  => file,
    content => file('/vagrant/puppet/files/controller/local.sh'),
    group   => 'stack',
    owner   => 'stack',
  }


  notify { 'running_devstack':
    message => "Now running stack.sh. This can take up to an hour depending on your connection speed. If you need to monitor its progress, please open another terminal, cd to this directory, run `vagrant ssh controller` then `tail -f /opt/stack/logs/stack.sh.log`",
    require => [
                 File["/home/stack/devstack/localrc"],
                 File["/home/stack/devstack/local.sh"]
               ],
  }


  # Stop DevStack in case it's already running
  exec { "stop_devstack":
    command => '/bin/su - stack /home/stack/devstack/unstack.sh',
    cwd     => '/home/stack/devstack',
    require => [ Notify["running_devstack"] ],
  }


  # If this is the first time stack.sh has run, it can take
  # up to an hour to finish depending on your bandwidth. So
  # we're disabling the timeout below.
  exec { "start_devstack":
    command   => '/bin/su - stack /home/stack/devstack/stack.sh',
    cwd       => '/home/stack/devstack',
    logoutput => on_failure,
    timeout   => 0,
    require   => [ 
                   Exec["stop_devstack"],
                   Package["ovs_switch"] 
                 ],
  }


  # Make stack.sh run in offline mode next time
  file_line { 'offline_stack_sh':
    ensure  => present,
    line    => file('/vagrant/puppet/files/common/offline.txt'),
    path    => '/home/stack/devstack/localrc',
    require => [ Exec["start_devstack"] ],
  }


  vcsrepo { "/vagrant/tempest":
    ensure   => latest,
    provider => git,
    source   => "https://github.com/openstack/tempest",
    revision => 'origin/stable/havana',
    require  => [
                  Package["git"],
                  Exec["start_devstack"]
                ],
  }


  exec { "copy_tempest_conf":
    command => '/bin/cp /opt/stack/tempest/etc/tempest.conf etc/tempest.conf',
    cwd     => '/vagrant/tempest',
    require => [
                 Vcsrepo["/vagrant/tempest"],
                 Exec["start_devstack"]
               ],
  }

}
