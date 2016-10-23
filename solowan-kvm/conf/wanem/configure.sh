#!/bin/bash

EMUSCRIPT=/tmp/wanem.sh
WANCONFIG=/tmp/wanem.conf
NETIFS='eth1 eth2'

if [ -e $EMUSCRIPT ]; then 
    mv -v $EMUSCRIPT ${EMUSCRIPT}.backup
fi
touch $EMUSCRIPT
chmod 755 $EMUSCRIPT

echo "#!/bin/bash" >> $EMUSCRIPT

MAXBW=100Mbit
BW=$(grep -v "#" $WANCONFIG | grep BW | cut -d "=" -f 2)
DELAY=$(grep -v "#" $WANCONFIG | grep DELAY | cut -d "=" -f 2)
LOSS=$(grep -v "#" $WANCONFIG | grep LOSS | cut -d "=" -f 2)
DUPLICATION=$(grep -v "#" $WANCONFIG | grep DUPLICATION | cut -d "=" -f 2)
CORRUPTION=$(grep -v "#" $WANCONFIG | grep CORRUPTION | cut -d "=" -f 2)
REORDERING=$(grep -v "#" $WANCONFIG | grep REORDERING | cut -d "=" -f 2)

flag=0
#echo $netem
#for i in $( ifconfig | grep 'eth' | awk '{print $1}' );
for i in $NETIFS;
do
	netem="tc qdisc add dev $i parent 1:1 handle 10: netem"
	echo "tc qdisc del dev $i root > /dev/null 2>&1" >> $EMUSCRIPT
	echo tc qdisc add dev $i root handle 1: htb default 1 >> $EMUSCRIPT

	if [ "$BW" != "" ] && [ "$BW" != " " ]; then
		echo tc class add dev $i parent 1: classid 1:1 htb rate $BW ceil $BW >> $EMUSCRIPT
	else
		echo tc class add dev $i parent 1: classid 1:1 htb rate $MAXBW ceil $MAXBW >> $EMUSCRIPT
	fi

	if [ "$DELAY" != "" ] && [ "$DELAY" != " " ]; then
		netem="$netem delay $DELAY"
		flag=1
        fi
	if [ "$LOSS" != "" ] && [ "$LOSS" != " " ]; then
		netem="$netem loss $LOSS"
		flag=1
        fi
	if [ "$DUPLICATION" != "" ] && [ "$DUPLICATION" != " " ]; then
		netem="$netem duplicate $DUPLICATION"
		flag=1
        fi
	if [ "$CORRUPTION" != "" ] && [ "$CORRUPTION" != " " ]; then
		netem="$netem corrupt $CORRUPTION"
		flag=1
        fi
	if [ "$REORDERING" != "" ] && [ "$REORDERING" != " " ]; then
		netem="$netem reorder $REORDERING"
		flag=1
        fi
        
	if [ $flag -eq 1 ]; then
        	echo $netem >> $EMUSCRIPT
	fi
done

echo -n "Executing wanem.sh..."
$EMUSCRIPT
echo "done"

