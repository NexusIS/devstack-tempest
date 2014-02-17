# Vagrant + DevStack + Tempest

This project automagically sets up a multi-node DevStack instance in 
your local machine. Tempest is also configured in the controller node.

## Requirements

1. At least 8GB of RAM. The DevStack environment will use ~6GB combined.
1. VirtualBox. Install from https://www.virtualbox.org/wiki/Downloads
1. OS X. May work on other *NIX platform but I've not tested it yet.
1. Vagrant. Install from http://www.vagrantup.com/downloads.html. Try 
   to read through the command line interface documentation at least.
1. The vagrant-vbguest plugin. Install with `vagrant plugin install vagrant-vbguest`
1. Bundler. Install with `gem install bundler`

## Optional but Recommended

1. RVM. Install with `curl -sSL https://get.rvm.io | bash -s stable --ruby`

## Installation

Estimated time for the following steps including automated provisioning: 
1 hour. Time will vary depending on your connection speed since DevStack 
will download all relevant OpenStack packages on first run.

1. Clone this repo and cd to it
1. `bundle install` and wait for all Ruby gems to install
1. `vagrant up` and wait until the nodes are fully provisioned

When the command above completes, Devstack will have been installed and running 
in the nodes. Test it by browsing to `http://192.168.56.11` in your local machine
(username/password is admin/password). Check that the compute node registered 
with the controller by going to Admin > Hypervisors (you should see two hosts). 
Note that Horizon's response might be slow for the first few minutes after 
provisioning (OpenStack is likely still busy initializing some stuff) but should 
be satisfyingly fast soon after that.

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
it's as simple as executing `vagrant up --provision`.

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

Not a problem! Check Vagrantfile for host ports that are currently being
forwarded to the controller node.


**I re-provisioned the controller and now Horizon is broken when I refresh my browser**

This seems to have something to do with how Horizon handles cookies. Try opening an
incognito window using Chrome (Shift-Command-N in OS X, Shift-Ctrl-N in Windows/Linux)
and use that to browse to Horizon.


## Questions?

Don't hesitate to email me at mark.maglana@nexusis.com if you have questions or 
run into a roadblock.
