#!/bin/bash	
wget http://idefix.dit.upm.es/vnx/examples/openstack/openstack_tutorial-liberty_4nodes_legacy_openvswitch-v012-with-rootfs.tgz
vnx --unpack openstack_tutorial-liberty_4nodes_legacy_openvswitch-v012-with-rootfs.tgz
mv 00-readme.txt openstack_tutorial-liberty_4nodes_legacy_openvswitch-v012/
mv scripts openstack_tutorial-liberty_4nodes_legacy_openvswitch-v012/
mv openstack_tutorial-liberty_4nodes_legacy_openvswitch.xml openstack_tutorial-liberty_4nodes_legacy_openvswitch-v012/
