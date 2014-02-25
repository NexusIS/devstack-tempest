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
    ensure   => latest,
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

  $ovs_dependencies = [ 'debhelper', 'autoconf', 'automake1.10', 'python-all', 'libffi-dev',
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

}


# echo 1 > /proc/sys/net/ipv4/ip_forward
# echo 1 > /proc/sys/net/ipv4/conf/eth0/proxy_arp
# iptables -t nat -A POSTROUTING -o eth0 -j MASQUERADE
# echo "net.ipv4.conf.eth0.proxy_arp = 1
# net.ipv4.ip_forward = 1" >> /etc/sysctl.conf
class ip_masq {
  include firewall

  exec { "ip_forward":
    command => "/bin/echo '1' > /proc/sys/net/ipv4/ip_forward",
  }


  exec { "proxy_arp":
    command => "/bin/echo '1' > /proc/sys/net/ipv4/conf/eth0/proxy_arp",
  }


  file_line { 'permanent_forwarding':
    ensure  => present,
    line    => file('/vagrant/puppet/files/common/sysctl.conf'),
    path    => '/etc/sysctl.conf',
    require => [ Exec["start_devstack"] ],
  }
  
  
  firewall { '100 ip masq':
    chain    => 'POSTROUTING',
    jump     => 'MASQUERADE',
    outiface => "eth0",
    table    => 'nat',
    require  => [
                  Exec["ip_forward"],
                  Exec["proxy_arp"]
                ],
  }

}


node basenode {
  include users
  include base_packages
  include devstack_repo
  include ovs_2
  include ip_masq
}

import 'nodes/*.pp'
