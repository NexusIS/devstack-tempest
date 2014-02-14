node compute inherits basenode {

	file { '/home/stack/devstack/localrc':
	  ensure 	=> file,
	  content => file('/vagrant/puppet/files/compute/localrc'),
		group   => 'stack',
		owner   => 'stack',
		require => Vcsrepo["/home/stack/devstack"],
	}


	notify { 'running_devstack':
		message => "Now running stack.sh. This can take up to an hour depending on your connection speed. If you need to monitor its progress, please open another terminal, cd to this directory, run `vagrant ssh compute` then `tail -f /home/stack/stack.sh.log`",
		require => [
								 File["/home/stack/devstack/localrc"],
							 ],
	}


	# Stop DevStack in case it's already running
	exec { "stop_devstack":
		command => '/bin/su - stack /home/stack/devstack/unstack.sh',
		cwd     => '/home/stack/devstack',
		require	=> [ Notify["running_devstack"] ],
	}


	# If this is the first time stack.sh has run, it can take
	# up to an hour to finish depending on your bandwidth. So
	# we're disabling the timeout below.
	exec { "start_devstack":
		command   => '/bin/su - stack /home/stack/devstack/stack.sh',
		cwd				=> '/home/stack/devstack',
		logoutput => on_failure,
		timeout		=> 0,
		require		=> [ Exec["stop_devstack"] ],
	}


	# Make stack.sh run in offline mode next time
	file_line { 'offline_stack_sh':
    ensure  => present,
    line    => file('/vagrant/puppet/files/common/offline.txt'),
    path    => '/home/stack/devstack/localrc',
		require => [ Exec["start_devstack"] ],
  }

}
