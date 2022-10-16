#!/bin/bash

# Remove it when done
function clean_up() {
  lxc stop $1 && lxc delete $1
}

if [ -z "$1" ]; then
  echo "usage: $0 <project_name>" 1>&2
  exit 1
fi

echo "Creating temporary container. It will be destroyed upon exiting this shell"
echo "Please be patient, this can take up to a few minutes"
lxc project switch "$1"
# Spin up the container and get the name
name="$(lxc launch ubuntu: | grep "Instance name" | NF)"
screen lxc shell $name
lxc delete -f $name
