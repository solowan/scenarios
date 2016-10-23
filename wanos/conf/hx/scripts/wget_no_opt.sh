#! /bin/bash
wget 192.168.1.2/payload.txt 2>/root/wget_result_no_opt_alpha.txt
wget 192.168.1.2/random.out 2>/root/wget_result_no_opt_random.txt
wget 192.168.1.2/payload.txt 2>>/root/wget_result_no_opt_alpha.txt
wget 192.168.1.2/random.out 2>>/root/wget_result_no_opt_random.txt
rm /payload.txt*
rm /random.txt*
