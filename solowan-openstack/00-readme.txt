
Core scenario (h1,o1,wanem,o2,h2)
---------------------------------

- Start central scenario with:

  vnx -f solowan-core.xml -v -t

- Configure h1, h2 an wanem with:

  vnx -f solowan-core.xml -v -x start-all -M h1,h2,wanem

- Once started, Solowan private and public repositories are available from inside o1/o2 in directories:

  /root/solowan-priv  
  /root/solowan-pub  
  
  By default, /root/opennop link points to solowan-priv. But the link can be changed with: 

  vnx -f solowan-core.xml -x set-solowan-priv
  vnx -f solowan-core.xml -x set-solowan-pub

- To compile and start the optimizers in o1/o2:

  vnx -f solowan-core.xml -v -x start-all -M o1,o2

  Use "-M o1" or "-M o2" to start solowan in only one optimizer.

- Once the optimizers are started, you can access o1/o2 and execute:

  solowan_monitor -> to monitorize opennop
  solowan_update -> to update the repositories with the latest version
  solowan_make -> to compile and install the solowan version pointed by /root/opennop link
  service solowan start/stop/restart/status -> to manage the solowan daemon

Solowan Openstack A scenario:
-----------------------------

- Start Openstack A scenario:

  vnx -f solowan-openstack-A.xml -v -t
  vnx -f solowan-openstack-A.xml -v -x start-all
  vnx -f solowan-openstack-A.xml -v -x create-solowan-scenario 

- Access Openstack Dashboard in http://192.168.0.11/horizon

- Access h1 from the host:

  slogin 192.168.0.102

- Start solowan inside h1:

  service solowan start
  

NAT commands:
-------------

To enable/disable NAT in both o1/o2:

  vnx -f solowan-core.xml -x enable-nat
  vnx -f solowan-core.xml -x disable-nat

To  enable/disable only in o1:

  vnx -f solowan-core.xml -x enable-nat  -M o1
  vnx -f solowan-core.xml -x disable-nat -M o1


Other useful information:
-------------------------

To pack the scenario in a tgz file including the root filesystems use:

  bin/pack-scenario --include-rootfs

To pack the scenario without the root filesystems, just delete the "--include-rootfs" parameter.

