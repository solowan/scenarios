#!/bin/bash
#

#echo "ejecutando script_vmstat..."

vmstat -n 2 | sed -u -e 's/memory/memory_com/' -e 's/cpu/cpu_com/' -e 's/swpd/swpd_com/' -e 's/free/free_com/' -e 's/buff/buff_com/' -e 's/cache/cache_com/' -e 's/us/us_com/' -e 's/sy/sy_com/' -e 's/id/id_com/' -e 's/wa/wa_com/' -e 's/swa_decp/swap/' -e 's/sy_decstem/system/'
