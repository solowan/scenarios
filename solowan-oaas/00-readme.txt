VNX Openstack tutorial scenario liberty_4nodes_legacy_openvswitch
scenario-oaas
------------------------------------------------------------------

  This file is part of the Virtual Networks over LinuX (VNX) Project distribution. 
  (www: http://www.dit.upm.es/vnx - e-mail: vnx@dit.upm.es) 

  Author: David Fernandez (david@dit.upm.es)
  Departamento de Ingenieria de Sistemas Telematicos (DIT)
  Universidad Politecnica de Madrid
  SPAIN


This is an Openstack tutorial scenario designed to experiment with Openstack free and open-source 
software platform for cloud-computing. 

The scenario is made of four virtual machines: a controller based on LXC and a network node and two
compute nodes based on KVM. Optionally, a third compute node can be added once the scenario is started.

All virtual machines use Ubuntu 14.04.3 LTS and Openstack Liberty. The deployment scenario is the one named 
"Legacy with Open vSwitch" described in http://docs.openstack.org/networking-guide/scenario_legacy_ovs.html

The scenario has been inspired by the ones developed by Raul Alvarez to test OpenDaylight-Openstack 
integration, but instead of using Devstack to configure Openstack nodes, the configuration is done
by means of commands integrated into the VNX scenario following Openstack installation recipes in 
http://docs.openstack.org/kilo/install-guide/install/apt/content/

The scenario has been improved with an optimization service for Openstack (Optimizer as a Service - OaaS) developed by Carlos Vega


Requirements:
-------------

To use the scenario you need a Linux computer (Ubuntu 14.04 or later recommended) with VNX software 
installed. At least 4Gb of memory are needed to execute the scenario.

See how to install VNX here:  http://vnx.dit.upm.es/vnx/index.php/Vnx-install

If already installed, update VNX to the latest version with:

  vnx_update

To make startup faster, enable one-pass-autoconfiguration for KVM virtual machines in /etc/vnx.conf:

  [libvirt]
  ...
  one_pass_autoconf=yes

Check that KVM nested virtualization is enabled:

  cat /sys/module/kvm_intel/parameters/nested
  Y

If not enabled, check, for example, http://docs.openstack.org/developer/devstack/guides/devstack-with-nested-kvm.html to enable it.


Starting the scenario:
----------------------

Download the scenario with the virtual machines images included and unpack it:

./scenario.sh

Start the scenario and configure it and load an example cirros image with:

  cd openstack_tutorial-liberty_4nodes_legacy_openvswitch-v012/
  vnx -f openstack_tutorial-liberty_4nodes_legacy_openvswitch.xml -v -t
  vnx -f openstack_tutorial-liberty_4nodes_legacy_openvswitch.xml -v -x start-all 
  vnx -f openstack_tutorial-liberty_4nodes_legacy_openvswitch.xml -v -x load-img

Once started, you can connect to Openstack Dashboard (admin/xxxx) starting a browser and pointing it 
to the controller horizon page. For example:

  firefox 10.0.10.11/horizon

Access Dashboard page "Project|Network|Network topology" and create a simple demo scenario inside 
Openstack:

  vnx -f openstack_tutorial-liberty_4nodes_legacy_openvswitch.xml -v -x create-demo-scenario

You should see the simple scenario as it is being created through the Dashboard.

Once created you should be able to access vm1 console, to ping or ssh from the host to the vm1 or the 
opposite (see the floating IP assigned to vm1 in the Dashboard, probably 10.0.10.102).

Finally, to allow external Internet access from vm1 you hace to configure a NAT in the host. You can
easily do it using vnx_config_nat command distributed with VNX. Just find out the name of the public 
network interface of your host (i.e eth0) and execute:

  vnx_config_nat ExtNet eth0

Optimization service:
-------------------------
To install the optimization service you must run the scripts oaasController.sh in controller node(/root) and oaasNetwork in network node (/root) once you have done the previous steps and do:
vnx -f openstack_tutorial-liberty_4nodes_legacy_openvswitch.xml -v -x create-scenario-oaas

You can see further documentation of this service and a use guide in https://github.com/solowan/OaaS

Another scenarios added are:
vnx -f openstack_tutorial-liberty_4nodes_legacy_openvswitch.xml -v -x create-scenario-solowan-simplified
vnx -f openstack_tutorial-liberty_4nodes_legacy_openvswitch.xml -v -x create-scenario-lbaas


Stopping or releasing the scenario:
-----------------------------------

To stop the scenario preserving the configuration and the changes made:

  vnx -f openstack_tutorial-liberty_4nodes_legacy_openvswitch.xml -v --shutdown

To start it again use:

  vnx -f openstack_tutorial-liberty_4nodes_legacy_openvswitch.xml -v --start

To stop the scenario destroying all the configuration and changes made:

  vnx -f openstack_tutorial-liberty_4nodes_legacy_openvswitch.xml -v --destroy

To unconfigure the NAT, just execute:

  vnx_config_nat -d ExtNet eth0


Adding a third compute node (compute3):
---------------------------------------

To add a third compute node to the scenario once it is started you can use the VNX modify capacity:

  vnx -s openstack_tutorial-liberty_4nodes_legacy_openvswitch --modify others/add-compute3.xml -v 
  vnx -s openstack_tutorial-liberty_4nodes_legacy_openvswitch -v -x start-all -M compute3

Once the new node has been joined to the scenario, you must use "-s" option instead of "-f" to manage it 
(if not, the compute3 node will not be considered). For example, 

  vnx -s openstack_tutorial-liberty_4nodes_legacy_openvswitch -v --destroy


Other useful information:
-------------------------

To pack the scenario in a tgz file including the root filesystems use:

  bin/pack-scenario --include-rootfs

To pack the scenario without the root filesystems, just delete the "--include-rootfs" parameter.

