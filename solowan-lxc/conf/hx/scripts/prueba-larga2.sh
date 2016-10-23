#!/bin/bash

for i in {1..200}
do
for i in {1..10}
do
/usr/bin/wget --progress=dot:mega 192.168.0.2/payload.txt 2>&1
md5sum payload.txt
rm -f payload.txt
done

for i in {1..10}
do
/usr/bin/wget --progress=dot:mega 192.168.0.2/random$i.out 2>&1
md5sum random$i.out
rm -f random$i.out
/usr/bin/wget --progress=dot:mega 192.168.0.2/random$i.out 2>&1
md5sum random$i.out
rm -f random$i.out
/usr/bin/wget --progress=dot:mega 192.168.0.2/random$i.out 2>&1
md5sum random$i.out
rm -f random$i.out
done
done
