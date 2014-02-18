#!/usr/bin/env bash

CURRENT_KERNEL_VERSION=`uname -r`
EXPECTED_KERNEL_VERSION="3.8"

echo "Checking for kernel version $EXPECTED_KERNEL_VERSION"

if echo $CURRENT_KERNEL_VERSION | grep "^$EXPECTED_KERNEL_VERSION"
then
  echo 'Kernel upgraded succesfully.'
else
  echo $CURRENT_KERNEL_VERSION
  echo 'Kernel failed to upgrade. Try restarting the VM'
  echo 'with `vagrant reload controller --provision`.'
  exit 1
fi
