# Cloud Controller (Name WIP)

## Description

A project to allow people to ssh and be given a linux container / vm.

By logging into user `temp`, a user will be given a temporary linux container with limited resources. The user will be given a command to request 1 port be forwarded through the host controller to access this device publicly. Upon exiting the shell, the instance will be destroyed and the resources reclaimed for future use.

In addition, the project will support other users. At some place, the server will be able to pull a username associated with ssh key pairs. The server will pull these and set up user accounts and authentication in accordance to them. Upon a user logging with with this username, a container would be created if not already done and their corresponding ssh keys will be added. SSH will be enabled, and the container will be given an ip address the user can log into. The ideal would be to make this a public ip space, but a NAT is fine too. All containers in this space can communicate to one another uninhibited by the firewall

## Feature ideas
[ ] Allow a user to request a port forward in a temp vm
[ ] Allow users to specify which type of container they want / vm
[ ] Give users a range of specifications they want to create (bit more ram / extra network)
