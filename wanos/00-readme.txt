Scenario to test wanos optimizer (http://wanos.co)
-------------------------------------------------

Before starting the scenario:
- download wanos-2.0.X-ova.zip from http://wanos.co and copy it to filesystems dir
- create rootfs:
    cd filesystems
    ./create-rootfs64
    ./create-rootfs-wanos

To start it:

  vnx -f wanos.xml -t
  vnx -f wanos.xml -x start-all

To start the management consoles:

  vnx -f wanos.xml -x start-mgmt-chrome   # to use chrome
  vnx -f wanos.xml -x start-mgmt-firefox  # to use firefox

Use wanos/wanos as user/password to access management consoles

Notes about wanos:

- User/passord to access optimizer consoles: tc/ChangeM3

- To manually configure o1, execute "wanos-cfg" with the following parameters 
     IP address: 192.168.0.10
     Mask: 24
     Gateway: 192.168.0.1 
     mode: edge
 
  or, alternatively, execute:
     /tce/etc/wanos/makewanoscfg.sh -cli 192.168.0.10 24 192.168.0.0 192.168.0.1 Core &
     sudo /tce/etc/wanos/wanos reconfigure >> /wanos/wanos.log

- To manually configure o2, execute "wanos-cfg" with the following parameters 
     IP address: 192.168.1.10
     Mask: 24
     Gateway: 192.168.1.1 
     mode: core

  or, alternatively, execute:
     /tce/etc/wanos/makewanoscfg.sh -cli 192.168.1.10 24 192.168.1.0 192.168.1.1 Core &
     sudo /tce/etc/wanos/wanos reconfigure >> /wanos/wanos.log

- To access optimizers management web pages, start navigator from the host to 192.168.0.10 and 192.168.1.10 (user/passwd -> wanos/wanos)

- wanos config scripts: /usr/bin/wanos-cfg, that calls /tce/etc/wanos/makewanoscfg.sh, that modifies config file /tce/etc/wanos/wanos.conf

