#!/bin/bash

for i in {1..10}
do
/usr/bin/wget 192.168.1.2/payload.txt
done

for i in {1..10}
do
/usr/bin/wget 192.168.1.2/random$i.out
done
