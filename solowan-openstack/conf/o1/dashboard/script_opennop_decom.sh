#!/bin/bash
#

echo "Optimizer Decompressor 1-2  Optimizer Compressor 2-1"
echo "total_input_bytes_dec_1-2  total_output_bytes_dec_1-2 total_input_bytes_com_2-1  total_output_bytes_com_2-1"

	variableAnterior1=`/root/opennop/opennop-daemon/opennop/opennop show stats out_dedup | grep -v '-' | grep 'total_input' | awk '{print $2}'`
	
	variableAnterior2=`/root/opennop/opennop-daemon/opennop/opennop show stats out_dedup | grep -v '-' | grep 'total_output' | awk '{print $2}'`

	variableAnterior1_2=`/root/opennop/opennop-daemon/opennop/opennop show stats in_dedup | grep -v '-' | grep 'total_input' | awk '{print $2}'`
	
	variableAnterior2_2=`/root/opennop/opennop-daemon/opennop/opennop show stats in_dedup | grep -v '-' | grep 'total_output' | awk '{print $2}'`
 
	periodo=2

while true
do
	
	sleep $periodo
	
	variable1=`/root/opennop/opennop-daemon/opennop/opennop show stats out_dedup | grep -v '-' | grep 'total_input' | awk '{print $2}'`
	
	variable2=`/root/opennop/opennop-daemon/opennop/opennop show stats out_dedup | grep -v '-' | grep 'total_output' | awk '{print $2}'`

	variable1_2=`/root/opennop/opennop-daemon/opennop/opennop show stats in_dedup | grep -v '-' | grep 'total_input' | awk '{print $2}'`
	
	variable2_2=`/root/opennop/opennop-daemon/opennop/opennop show stats in_dedup | grep -v '-' | grep 'total_output' | awk '{print $2}'`

	valor1=$((($variable1-$variableAnterior1)/$periodo))
	valor2=$((($variable2-$variableAnterior2)/$periodo))

	valor1_2=$((($variable1_2-$variableAnterior1_2)/$periodo))
	valor2_2=$((($variable2_2-$variableAnterior2_2)/$periodo))

	variableAnterior1=$variable1
	variableAnterior2=$variable2

	variableAnterior1_2=$variable1_2
	variableAnterior2_2=$variable2_2

	echo $valor1 $valor2 $valor1_2 $valor2_2

done
 
 
