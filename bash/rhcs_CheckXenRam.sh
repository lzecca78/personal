#!/bin/bash

NODES="blade1ws blade2ws blade3ws blade4ws blade5ws blade6ws blade7ws"
TOTALRAM=49140

for i in $NODES

        do

        ping -W1 -c2 $i > /dev/null 2>&1

        if [ $? = 0 ]

                then

                        FREEMEM=$(ssh $i  "xm info" | grep free_memory | cut -d":" -f2)
			VMNUMBER=$(ssh $i "xm list | grep -v Domain-0 | grep "-"| wc -l")
			VMLIST=$(ssh $i "xm list | cut -d' ' -f1 | grep -v Domain-0 | grep -v Name")
			PERCENTAGE=$(echo "$FREEMEM * 100 / 48000" | bc)		
			PRINTPERCENTAGE=$(printf "%4s%%" $PERCENTAGE)
			GBFREE=$(echo "$FREEMEM / 1000" | bc)

			TOTALVCPUS=0

			for k in $VMLIST

				do 
					COUNTVCPUS=$(cat /gfs1/$k/$k | grep vcpus | cut -d"=" -f2)
					let TOTALVCPUS=TOTALVCPUS+$(echo $COUNTVCPUS)
				done



			echo "il nodo $i ha una quantità libera di ram pari a :$PRINTPERCENTAGE | $GBFREE GB liberi | vm attive : $VMNUMBER | VCPUS usate : $TOTALVCPUS"




        fi

done
