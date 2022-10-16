#!/bin/bash

function gen_sshd_config() {
	echo -e "\nMatch User temp"
	echo -e "\tPasswordAuthentication yes"
	echo -e "\tPermitTTY yes"
	echo -e "\tForceCommand /usr/local/share/cc/shell ephemeral"
}

function create_project() {
  proj="$1"
  net="$2"
  cpu=$3
  mem="$4"
  disk="$5"

  if [ -z "$1" ] || [ -z "$2" ]; then
    echo "You must supply project name and network name" 1>&2
    return 1
  fi

  if [ -z "$cpu" ]; then
    cpu=2
  fi

  if [ -z "$mem" ]; then
    mem="1GiB"
  fi

  # See if lxd is set up already
  if [ -n "$(lxc project ls -f compact | grep $proj)" ]; then
    return
  fi

  # Don't namespace images so they can be shared between projects
  lxc project create $proj -c features.images=false 
  lxc project switch $proj

  # No need to use anything but default profile
  # Set some resource limits
  lxc profile set default limits.cpu $cpu
  lxc profile set default limits.memory $mem
  lxc profile set default limits.memory $mem

  # See if it does we're good to go
  if [ -n "$(lxc network ls -f compact | grep $net)" ]; then
    return
  fi

  # Create the network
  lxc network create $net
  lxc network set $net ipv4.firewall=false
  lxc network set $net ipv6.firewall=false

  # Add to the default profile for vms
  lxc network attach-profile $net default

  # See if the storage has already been created
  if [ -z "$(lxc storage list | grep cc)" ]; then
    # Make the storage device
    if [ -n "$disk" ]; then
      lxc storage create cc zfs size=$disk
    else
      # Create a pool with automatic sizing
      lxc storage create cc zfs
    fi
  fi

  # Add the root path to the pool
  lxc profile device add default root disk path=/ pool=cc
}

function lxd_init() {
  create_project ephemeral ccebr0
  # TODO In the future will add other users with ssh keys
}

mkdir -p /usr/local/share/cc
cp "$PWD/shell.sh" /usr/local/share/cc/shell
chmod +x /usr/local/share/cc/shell

# Create the temp user
if [ -z "$(id -u temp 2>&1 | grep -E '^[0-9]+$')" ]; then
  useradd -rmG lxd temp 
  # Hack because idk how to do better
  echo -e "temp\ntemp" | passwd temp &>/dev/null
fi

# Add the config to the ssh server
if [ -z "$(grep "Match User temp" /etc/ssh/sshd_config)" ]; then
  gen_sshd_config >> /etc/ssh/sshd_config
fi

# Enable and restart ssh to get our config running
systemctl enable ssh &>/dev/null
systemctl restart ssh

# Set up LXD if not already configured
lxd_init
