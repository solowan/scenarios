#!/bin/bash
#

#echo "ejecutando gestor..."

	parametro1=`echo $QUERY_STRING | awk -F "&" {'print $1'} | awk -F "=" {'print $1'}`;
	valorParametro1=`echo $QUERY_STRING | awk -F "&" {'print $1'} | awk -F "=" {'print $2'}`;

	parametro2=`echo $QUERY_STRING | awk -F "&" {'print $2'} | awk -F "=" {'print $1'}`;
	valorParametro2=`echo $QUERY_STRING | awk -F "&" {'print $2'} | awk -F "=" {'print $2'}`;
 
	if [ "$valorParametro1" == 'script_vmstat.sh' ]; then
		/opt/dashboard/script_vmstat.sh

	elif [ "$valorParametro1" == 'script_opennop_decom.sh' ]; then
		#./script_opennop2.sh
        	/opt/dashboard/script_opennop_decom.sh

	fi
       	
	
