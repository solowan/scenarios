#!/bin/bash
cd /root/OpenNOP/opennop-daemon/
kill -9 `ps aux | grep opennop | cut -d " " -f 7 | head -1`
make
./opennopd/opennopd -n > /root/log.log&
