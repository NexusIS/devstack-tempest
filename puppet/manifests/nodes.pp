class users {
  group { "stack":
    ensure => present,
    gid    => 504,
  }

  user { "stack":
    ensure     => present,
    managehome => true,
    shell      => '/bin/bash',
    uid        => 500,
    gid        => 504,
  }

  file_line { 'sudo_priveledge':
    ensure => present,
    line   => 'stack ALL=(ALL) NOPASSWD: ALL',
    path   => '/etc/sudoers',
  }
}


class base_packages {
  package { "git":
    ensure  => installed,
  }


  package { "python-setuptools":
    ensure => installed,
  }
  
  
  # This ensures the python module doesn't get confused
  # when running in Ubuntu
  exec { "symlink_easy_install":
    command => "/bin/ln -s /usr/bin/easy_install /usr/local/bin/easy_install",
    require => Exec["easy_install installer"],
    creates => "/usr/local/bin/easy_install",
  }
  
  package { "python-dev":
    ensure => installed,
  }
}


class devstack_repo {
  vcsrepo { "/home/stack/devstack":
    ensure   => present,
    owner    => 'stack',
    group    => 'stack',
    provider => git,
    require  => [ 
                  Package["git"], 
                  User["stack"] 
                ],
    source   => "https://github.com/openstack-dev/devstack.git",
    revision => 'origin/stable/havana',
  }
}


class ovs_2 {
  package { "build-essential": 
    ensure => installed,
  }

  package { "fakeroot": 
    ensure => installed,
  }
  
  exec { "download_openvswitch_2":
    command => "/usr/bin/wget http://openvswitch.org/releases/openvswitch-2.0.0.tar.gz",
    cwd     => "/root",
    creates => "/root/openvswitch-2.0.0.tar.gz",
  }
  
  exec { "extract_openvswitch_2":
    command => "/bin/tar xvfz openvswitch-2.0.0.tar.gz",
    cwd     => "/root",
    creates => "/root/openvswitch-2.0.0/README",
  }

  $ovs_dependencies = [ 'debhelper', 'autoconf', 'automake1.10', 'python-all', 
                        'python-qt4', 'python-zopeinterface', 'python-twisted-conch' ]
  
  package { $ovs_dependencies: 
    ensure => installed 
  }
  
  exec { "build_ovs_2":
    command     => "/usr/bin/fakeroot debian/rules binary",
    environment => "DEB_BUILD_OPTIONS='parallel=8 nocheck'",
    cwd         => "/root/openvswitch-2.0.0",
    logoutput   => true,
    loglevel    => verbose,
    timeout     => 0,
    require     => [
                     Package["build-essential"],
                     Package["fakeroot"],
                     Package[$ovs_dependencies],
                     Exec["extract_openvswitch_2"]
                   ],
  }
  
  package { "ovs_common":
    name     =>  'openvswitch-common',
    ensure   =>  installed,
    provider =>  dpkg,
    source   =>  "/root/openvswitch-common_2.0.0-1_amd64.deb",
    require  => [ Exec["build_ovs_2"] ],
  }

  package { "ovs_switch":
    name     =>  'openvswitch-switch',
    ensure   =>  installed,
    provider =>  dpkg,
    source   =>  "/root/openvswitch-switch_2.0.0-1_amd64.deb",
    require  => [ Package["ovs_common"] ],
  }

  # Need to update dnsmasq to 2.6 as per
  # http://openstack.redhat.com/forum/discussion/comment/1910#Comment_1910
}

node basenode {
  include users
  include base_packages
  include devstack_repo
  include ovs_2
}

import 'nodes/*.pp'
