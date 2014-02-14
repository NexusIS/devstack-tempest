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
}


class devstack_repo {
  vcsrepo { "/home/stack/devstack":
    ensure   => latest,
    owner    => 'stack',
    group    => 'stack',
    provider => git,
    require  => [ Package["git"] ],
    source   => "https://github.com/openstack-dev/devstack.git",
    revision => 'origin/stable/havana',
  }
}


node basenode {
  include users
  include base_packages
  include devstack_repo
}

import 'nodes/*.pp'
