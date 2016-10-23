opennop-SoloWAN LXC rootfs:
---------------------------

To automatically create the rootfs for this scenario just run: ./create-rootfs

To create it manually:

  - Download a standard VNX rootfs: vnx_download_rootfs -r $BASEROOTFSNAME

  - Modify the rootfs: vnx --modify-rootfs $BASEROOTFSNAME

  Note that you'ĺl probably have to adjust the variables lxc.rootfs and lxc.mount inside rootfs config 
  file before modifying it (a message telling that is hown)