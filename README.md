# Vagrant + DevStack + Tempest

This project automagically sets up a DevStack environment in
your local machine. Tempest is also configured in the controller node.

## Requirements

1. At least 8GB of RAM. The DevStack environment will use ~6GB combined.
1. VirtualBox. Install from https://www.virtualbox.org/wiki/Downloads
1. OS X. May work on other *NIX platform but I've not tested it yet.
1. Vagrant v1.4.3. Install from http://www.vagrantup.com/downloads.html. Try
   to read through the command line interface documentation at least.
1. The vagrant-vbguest plugin. Install with `vagrant plugin install vagrant-vbguest`
1. A Host-only Network in VirtualBox with IP of 192.168.42.1 and DHCP disabled.

## Installation

Estimated time for the following steps including automated provisioning:
1 hour. Time will vary depending on your connection speed since DevStack
will download all relevant OpenStack packages on first run.

1. Clone this repo and cd to it
1. `vagrant up controller --provision`, type in your local password when asked, then wait until it is provisioned
1. `vagrant up compute --provision`, type in your local password when asked, and wait until it is provisioned

When the command above completes, Devstack will have been installed and running
in the nodes. Test it by browsing to `http://192.168.42.11` in your local machine
(username/password is admin/password). Check that the compute node registered
with the controller by going to Admin > Hypervisors (you should see only one host).
Note that Horizon's response might be slow during your first access but should
be satisfyingly fast after that.

Also by this time, tempest should already be cloned into `/vagrant/tempest` in
the controller node. SSH to the controller with `vagrant ssh controller`. Note
that since `/vagrant` is actually your local copy of this repo shared via
VirtualBox to the nodes, the same `tempest` dir is also available at the root dir
of your local repo. This will allow you to modify tempest using your favorite
editor (in your local machine) while still have tempest run in a tightly
controlled environment (the controller node).

Do a test run of tempest by executing the following:

    $ vagrant ssh controller
    $ sudo su -
    $ cd /vagrant/tempest
    $ ./run_tests.sh -V -- run tempest.api.compute.servers.test_servers_negative.ServersNegativeTestJSON.test_reboot_non_existent_server

The first time you run the tests, it will try to install a bunch of dependencies.
Subsequent runs should be much faster. The last few lines of the above command
should be:

    setUpClass (tempest.thirdparty.boto.test_ec2_instance_run
    InstanceRunTest)                                                  SKIP  0.00
    tempest.api.compute.servers.test_servers_negative.ServersNegativeTestJSON
    test_reboot_non_existent_server[gate,negative]                    OK  10.75

    Slowest 1 tests took 10.75 secs:
    tempest.api.compute.servers.test_servers_negative.ServersNegativeTestJSON
    test_reboot_non_existent_server[gate,negative]                        10.75

    Ran 2 tests in 82.334s

    OK

The execution times may be different and that's OK. What's important is that all
tests ran succesfully.

## Stopping and starting the VM

To suspend your VM, run `vagrant suspend`. To shut it down, run `vagrant halt`.
Note that if you shut it down, you will need to rerun DevStack again. Luckily
it's as simple as executing `vagrant up <controller or compute> --provision`.
Provisioning should be relatively fast this time around since DevStack is automatically
configured to run in offline mode after the first provision.

## Running all tests

    $ vagrant ssh controller
    $ sudo su -
    $ cd /vargrant/tempest
    $ ./run_tests.sh -V

## Running a single test

    $ vagrant ssh
    $ sudo su -
    $ cd /vagrant/tempest
    $ example: `./run_tests.sh -V -- run --parallel tempest.api.compute.servers.test_servers_negative.ServersNegativeTestJSON.test_reboot_non_existent_server`


## Troubleshooting

**There are instances when I want to restart DevStack but not the node**

You can use `vagrant provision controller` or `vagrant provision compute`.


**I'd like to use localhost instead of 192.168.56.11 to connect**

Not a problem! Check the Vagran documentation at vagrantup.com for instructions
on setting up port forwarding.


**I re-provisioned the controller and now Horizon is broken when I refresh my browser**

This seems to have something to do with how Horizon handles cookies. Try opening an
incognito window using Chrome (Shift-Command-N in OS X, Shift-Ctrl-N in Windows/Linux)
and use that to browse to Horizon.


**I get an error "No module named subunit" when I run the tests**

You probably switched branches and ended up with an incompatible set of python libraries.
Go inside the tempest directory and delte the .venv/, .testrepository/, and .tox/ directories.
If that doesn't work, you probably modified the controller's RAM size to something
smaller than gcc needs to compile some native binaries. Raise it back to
4GB temporarily.


**I'm getting an 'ImportError: cannot import name Full' error when I run tests**

You're likely using OS X with a non-case-sensitive filesystem. Go and open
tempest/.venv/lib/python2.7/site-packages/eventlet/queue.py and add this line
to the top of the file `from __future__ import absolute_import` then save
and run the test(s) again.


**I'm getting errors when VirtualBox attempts to mount the shared folders**

You're probably running into [this bug](https://www.virtualbox.org/ticket/12879).
The fix is in the comments section of that ticket. Basically, ssh to the controller
via `vagrant ssh controller` and run the following command:

    sudo ln -s /opt/VBoxGuestAdditions-4.3.10/lib/VBoxGuestAdditions /usr/lib/VBoxGuestAdditions


**I'm getting an error about Vagrant not able to compile nokogiri**

You're missing developer tools needed to locally compile binaries needed
by nokogiri. In OS X, install the OS X Developer Tools for your OS X version.


## Sample Video

Here's a video of the process of starting up the two nodes. Note that the video is slightly
different in that it imports two local .box files for starting up the nodes. This was originally
made for the workshop participants at the OpenStack 2014 summit where bandwidth for each
individual would be limited. Watch the video [here](http://youtu.be/YjpmImua6mc).

## Questions?

File it here: https://github.com/NexusIS/devstack-tempest/issues
