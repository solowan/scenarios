#!/bin/bash

for i in {1..10}
do
dd if=/dev/urandom of=/var/www/random$i.out bs=10M count=2
done

