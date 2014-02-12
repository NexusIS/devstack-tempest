# Vagrant + DevStack + Tempest

This repo automates the setup of DevStack and Tempest in a VM in your local machine.

## Requirements

1. At least 8GB of RAM. The VM will use 4GB.
1. VirtualBox. Install from https://www.virtualbox.org/wiki/Downloads
1. OS X. May work on other *NIX platform but I've not tested it yet.
1. Vagrant. Install from http://www.vagrantup.com/downloads.html. Try to read through the command line interface documentation at least.
1. The vagrant-vbguest plugin. Install with `vagrant plugin install vagrant-vbguest`

## Installation

Estimated time for the following steps including automated provisioning: 1 hour. Time will vary depending on your connection speed since devstack will download all relevant OpenStack packages on first run.

1. Clone this repo and cd to it
1. `vagrant up` and wait until the VM is fully provisioned

By this time, Devstack will have been installed and running in the VM. Test it by browsing to `http://localhost:8088` in your local machine (username/password is admin/password). Note that the response might be slow for the first few minutes after provisioning (OpenStack is likely still busy initializing some stuff) but should be satisfyingly fast soon after that.

There are a bunch of other ports in your local machine that get forwarded to the VM. For an updated list, look inside the Vagrantfile file.

Also by this time, tempest should already be cloned into `/vagrant/tempest` in your VM. Note that since `/vagrant` is actually your local copy of this repo shared via VirtualBox to your VM, the same `tempest` dir is also available at the root dir of your local repo. This will allow you to modify tempest using your favorite editor (in your local machine) while still have tempest run in a tightly controlled environment (the VM).

Do a test run of tempest by executing the following:

    $ vagrant ssh
    $ sudo su -
    $ cd /vagrant/tempest
    $ ./run_tests.sh -V -- run tempest.api.compute.servers.test_servers_negative.ServersNegativeTestJSON.test_reboot_non_existent_server

The output of the last command should be:

    setUpClass (tempest.thirdparty.boto.test_ec2_instance_run
    InstanceRunTest)                                                  SKIP  0.00
    tempest.api.compute.servers.test_servers_negative.ServersNegativeTestJSON
    test_reboot_non_existent_server[gate,negative]                    OK  10.75
    
    Slowest 1 tests took 10.75 secs:
    tempest.api.compute.servers.test_servers_negative.ServersNegativeTestJSON
    test_reboot_non_existent_server[gate,negative]                        10.75
    
    Ran 2 tests in 82.334s
    
    OK

The execution times may be different and that's OK. What's important is that all tests ran succesfully.

## Stopping and starting the VM

To suspend your VM, run `vagrant suspend`. To shut it down, run `vagrant halt`.
Note that if you shut it down, you will need to call `/home/stack/devstack/stack.sh` from within the VM again after your `vagrant up`. This should not take as long as the first time since `OFFLINE=True` will have been appended to `/home/stack/devstack/localrc` by the Vagrant provisioning script. To re-run devstack, execute the following:


    $ vagrant ssh
    $ sudo su - stack
    $ cd devstack
    $ ./stack.sh
		$ exit
		$ cd /vagrant/tempest
    $ cp /opt/stack/tempest/etc/tempest.conf etc/tempest.conf

The `./stack.sh` command should take only roughly 2~3 minutes this time around. The last command re-copies `tempest.conf` since some values will likely have changed after re-running stack.sh (e.g. image ids)

## Running all tests

    $ vagrant ssh
    $ sudo su -
    $ cd /vargrant/tempest
    $ ./run_tests.sh -V

## Running a single test

    $ vagrant ssh
    $ sudo su -
    $ cd /vagrant/tempest
    $ example: `./run_tests.sh -V -- run --parallel tempest.api.compute.servers.test_servers_negative.ServersNegativeTestJSON.test_reboot_non_existent_server`


## Questions?

Don't hesitate to email me at mark.maglana@nexusis.com if you have questions or run into a roadblock.
