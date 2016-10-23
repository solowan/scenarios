#!/bin/bash
for i in 1..6 
do
	wget 192.168.1.2/payload.txt
	sleep 10
done

rm payload.txt*
