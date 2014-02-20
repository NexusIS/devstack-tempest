#!/usr/bin/env bash

CURRENT_KERNEL_VERSION=`uname -r`

# Kernel 3.8 has the OVS 2.0 modules
EXPECTED_KERNEL_VERSION="3.8"

echo "Checking for kernel version $EXPECTED_KERNEL_VERSION"

if echo $CURRENT_KERNEL_VERSION | grep "^$EXPECTED_KERNEL_VERSION"
then
  echo 'Kernel is the right version.'
else
  echo $CURRENT_KERNEL_VERSION
  echo 'Kernel version is not what was expected.'
  exit 1
fi
