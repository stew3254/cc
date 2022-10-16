#!/bin/bash

# Remove it when done
function clean_up() {
  lxc stop $1 && lxc delete $1
}

if [ -z "$1" ]; then
  echo "usage: $0 <project_name>" 1>&2
  exit 1
fi

lxc project switch "$1"
# Spin up the container and get the name
name="$(lxc launch ubuntu: | grep "Instance name" | NF)"
lxc shell $name
clean_up $name &
