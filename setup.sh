#!/bin/bash

rm -rf ~/.vagrant.d
rm -rf ~/VirtualBox\ VMs 

# Create folders in the 1TB storage
mkdir -p /goinfre/$(whoami)/vagrant_home
mkdir -p /goinfre/$(whoami)/virtualbox_vms

# Tell Vagrant to use Goinfre for boxes (the images)
export VAGRANT_HOME="/goinfre/$(whoami)/vagrant_home"

# Tell VirtualBox to use Goinfre for the actual VMs (the hard drives)
# This is a VirtualBox setting that persists
VBoxManage setproperty machinefolder /goinfre/$(whoami)/virtualbox_vms


echo 'export VAGRANT_HOME="/goinfre/$(whoami)/vagrant_home"' >> ~/.zshrc

# source ~/.zshrc


