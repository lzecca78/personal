#!/bin/bash
NODES="blade1ws blade2ws blade3ws blade4ws blade5ws blade6ws blade7ws"
ROOTCALC=/root/operations
echo "" > $ROOTCALC/ram_value
mkdir -p $ROOTCALC


clustat | grep -v started
echo -e  "inserisci la macchina virtuale ( \033[1mescluso il vm:\033[0m ) che desideri avviare tra le seguenti non ancora avviate"
read vmname

VMMAXMEM=$(cat /gfs1/$vmname/$vmname | grep "maxmem" | cut -d"=" -f2)
VMVCPUS=$(cat /gfs1/$vmname/$vmname | grep vcpus | cut -d"=" -f2)

for blade in  $NODES

do

        FREEMEMBLADE=$(ssh $blade  "xm info" | grep free_memory | cut -d":" -f2)
	FREEMEMVM=$( echo "$FREEMEMBLADE - $VMMAXMEM" | bc)
 	echo "$blade:$FREEMEMVM" >> $ROOTCALC/ram_value
done 

HIGHERVALUE=$(cat $ROOTCALC/ram_value	| cut -d":" -f2 |sort |tail -n1)

BETTERBLADE=$(cat $ROOTCALC/ram_value | grep $HIGHERVALUE | cut -d":" -f1| head -n1)

echo " la macchina virtuale $vmname a seguito del calcolo , verrà avviata su $BETTERBLADE, proseguire? (y|n)"
read risposta

if [ $risposta = y ]

	then
		clusvcadm -e vm:$vmname -m $BETTERBLADE.webscience.it
	else
		echo "la macchina virtuale NON è stata avviata"
fi


			
