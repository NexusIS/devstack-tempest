#!/bin/env ruby


    # enhanced:: Check for OS because Windows doesn't like vbguest.auto_reboot
module OS
    def OS.windows?
        (/cygwin|mswin|mingw|bccwin|wince|emx/ =~ RUBY_PLATFORM) != nil
    end

    def OS.mac?
        (/darwin/ =~ RUBY_PLATFORM) != nil
    end

    def OS.unix?
        !OS.windows?
    end

    def OS.linux?
        OS.unix? and not OS.mac?
    end
end

Vagrant.configure("2") do |config|

  config.vm.box     = "devstackbase-0.0.1"
  config.vm.box_url = "https://dl.dropboxusercontent.com/u/1355795/devstackbase-0.0.1.box"
  config.vm.synced_folder ".", "/vagrant", :nfs => true

  # CONTROLLER CONFIG
  config.vm.define "controller" do |controller|
    controller.vm.hostname = "controller"

    # eth1 (IMPORTANT: This network should not have DCHP)
    controller.vm.network "private_network", ip: "192.168.42.11"

    # When vagrant-vbguest updates the VirtualBox Guest
    # Addition kernel modules, shared folders subsequently
    # are lost and Puppet fails. Auto-rebooting fixes that.
    if !OS.windows?
        controller.vbguest.auto_reboot = true
    end


    controller.vm.provider "virtualbox" do |vb|
      vb.customize ["modifyvm", :id, "--memory", 3072]

      # This allows symlinks to be created within the /vagrant root directory,
      # which is something librarian-puppet needs to be able to do. This might
      # be enabled by default depending on what version of VirtualBox is used.
      vb.customize ["setextradata", :id, "VBoxInternal2/SharedFoldersEnableSymlinksCreate/v-root", "1"]
    end

    controller.vm.provision :shell, :path => "shell/check_kernel_version.sh"
    controller.vm.provision :shell, :path => "shell/install_puppet_modules.sh"

    controller.vm.provision "puppet" do |puppet|
      puppet.manifests_path = "puppet/manifests"
      puppet.manifest_file  = "site.pp"
    end
  end


  # COMPUTE CONFIG
  config.vm.define "compute" do |compute|
    compute.vm.hostname = "compute"

    # eth1
    compute.vm.network "private_network", ip: "192.168.42.12"

    compute.vm.provider "virtualbox" do |vb|
      vb.customize ["modifyvm", :id, "--memory", 2048]
    end

    # When vagrant-vbguest updates the VirtualBox Guest
    # Addition kernel modules, shared folders subsequently
    # are lost and Puppet fails. Auto-rebooting fixes that.
#done: implement OS check & avoid execution on w/ windows
    if !OS.windows?
        controller.vbguest.auto_reboot = true
    end

    compute.vm.provision :shell, :path => "shell/check_kernel_version.sh"
    compute.vm.provision :shell, :path => "shell/install_puppet_modules.sh"

    compute.vm.provision "puppet" do |puppet|
      puppet.manifests_path = "puppet/manifests"
      puppet.manifest_file  = "site.pp"
    end
  end

end
