#!/bin/sh

# Directory in which librarian-puppet should manage its modules directory
PUPPET_DIR=/etc/puppet/

if [ ! -d "$PUPPET_DIR" ]; then
  mkdir -p $PUPPET_DIR
fi

cp /vagrant/puppet/Puppetfile $PUPPET_DIR
cd $PUPPET_DIR && librarian-puppet update
