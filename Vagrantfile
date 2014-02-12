#!/bin/env ruby

Vagrant.configure("2") do |config|

  config.vm.define "devstack" do |devstack|

    devstack.vm.box      = "precise64"
    devstack.vm.hostname = "devstack"

    # Used by vagrant and the provisioner further down.
    ip_address = "192.168.56.11"

    devstack.vm.network "private_network", ip: ip_address

    # Forward the following local ports to the VM
    config.vm.network "forwarded_port", guest: 35357, host: 35357
    config.vm.network "forwarded_port", guest: 8776,  host: 8776
    config.vm.network "forwarded_port", guest: 9292,  host: 9292
    config.vm.network "forwarded_port", guest: 8774,  host: 8774
    config.vm.network "forwarded_port", guest: 8773,  host: 8773
    config.vm.network "forwarded_port", guest: 5000,  host: 5000
    config.vm.network "forwarded_port", guest: 11181, host: 11181
    config.vm.network "forwarded_port", guest: 80,    host: 8088


    devstack.vm.provider "virtualbox" do |vm|
      vm.customize ["modifyvm", :id, "--memory", 4000]
    end

    devstack.vm.provision "shell", path: 'vagrant/shell/provision.sh', 
                          args: ip_address

  end # config.vm.define :devstack

end
