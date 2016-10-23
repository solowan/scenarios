#!/bin/bash
#

#echo "ejecutando script_vmstat..."

vmstat -n 2 | sed -u -e 's/memory/memory_dec/' -e 's/cpu/cpu_dec/' -e 's/swpd/swpd_dec/' -e 's/free/free_dec/' -e 's/buff/buff_dec/' -e 's/cache/cache_dec/' -e 's/us/us_dec/' -e 's/sy/sy_dec/' -e 's/id/id_dec/' -e 's/wa/wa_dec/' -e 's/swa_decp/swap/' -e 's/sy_decstem/system/'
