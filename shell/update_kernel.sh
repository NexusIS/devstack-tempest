#!/bin/sh

# As per the INSTALL.Debian file in the OVS 2.0 source, these steps are
# necessary to install OVS 2.0. The rest of the steps are managed by Puppet

apt-get update -y
apt-get install linux-image-generic-lts-raring linux-headers-generic-lts-raring -y
