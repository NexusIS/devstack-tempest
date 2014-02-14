class users {
	group { "stack":
    ensure => present,
    gid 	 => 504,
  }

  user { "stack":
		ensure 		 => present,
		managehome => true,
		shell			 => '/bin/bash',
		uid 	 		 => 500,
		gid  	 		 => 504,
  }

	file_line { 'sudo_priveledge':
    ensure => present,
    line   => 'stack ALL=(ALL) NOPASSWD: ALL',
    path   => '/etc/sudoers',
  }
}


class base_packages {
	package { "git":
		ensure 	=> installed,
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
