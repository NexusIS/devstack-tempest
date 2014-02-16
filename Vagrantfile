#!/bin/env ruby

Vagrant.configure("2") do |config|

  # CONTROLLER CONFIG
  config.vm.define "controller" do |controller|
    controller.vm.box      = "precise64"
    controller.vm.hostname = "controller"

    controller.vm.network "private_network", ip: "192.168.56.11"

    controller.vm.provider "virtualbox" do |vb|
      vb.customize ["modifyvm", :id, "--memory", 4000]

      # This allows symlinks to be created within the /vagrant root directory,
      # which is something librarian-puppet needs to be able to do. This might
      # be enabled by default depending on what version of VirtualBox is used.
      vb.customize ["setextradata", :id, "VBoxInternal2/SharedFoldersEnableSymlinksCreate/v-root", "1"]
    end

    # Forward the following local ports to the controller
    controller.vm.network "forwarded_port", guest: 35357, host: 35357
    controller.vm.network "forwarded_port", guest: 8776,  host: 8776
    controller.vm.network "forwarded_port", guest: 9292,  host: 9292
    controller.vm.network "forwarded_port", guest: 8774,  host: 8774
    controller.vm.network "forwarded_port", guest: 8773,  host: 8773
    controller.vm.network "forwarded_port", guest: 5000,  host: 5000
    controller.vm.network "forwarded_port", guest: 11181, host: 11181
    controller.vm.network "forwarded_port", guest: 80,    host: 8088

    # This shell provisioner installs librarian-puppet and runs it to install
    # puppet modules. This has to be done before the puppet provisioning so that
    # the modules are available when puppet tries to parse its manifests.
    controller.vm.provision :shell, :path => "shell/main.sh"

    controller.vm.provision "puppet" do |puppet|
      puppet.manifests_path = "puppet/manifests"
      puppet.manifest_file  = "site.pp"
    end
  end


  # COMPUTE CONFIG
  config.vm.define "compute" do |compute|
    compute.vm.box      = "precise64"
    compute.vm.hostname = "compute"

    compute.vm.network "private_network", ip: "192.168.56.12"

    compute.vm.provider "virtualbox" do |vb|
      vb.customize ["modifyvm", :id, "--memory", 2048]
    end

    # This shell provisioner installs librarian-puppet and runs it to install
    # puppet modules. This has to be done before the puppet provisioning so that
    # the modules are available when puppet tries to parse its manifests.
    compute.vm.provision :shell, :path => "shell/main.sh"

    compute.vm.provision "puppet" do |puppet|
      puppet.manifests_path = "puppet/manifests"
      puppet.manifest_file  = "site.pp"
    end
  end

end
