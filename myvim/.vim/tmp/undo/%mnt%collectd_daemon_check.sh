Vim�UnDo� �P V	J�'RDw��i���屺`BP��in�8      hostname="01-EF9Q1SG2F0VNL"      
                       R��    _�                        
    ����                                                                                                                                                                                                                                                                                                                                                             R��     �               hostname="01-EF9Q1SG2F0VNL"5�_�                            ����                                                                                                                                                                                                                                                                                                                                                             R��    �                done�                	sleep $interval�                	fi�                F		echo "PUTVAL $hostname/onebip-dbs/gauge-${daemonName}Status $time:0"�                	else�                F		echo "PUTVAL $hostname/onebip-dbs/gauge-${daemonName}Status $time:1"�                	then�                	if [ $? -eq 0 ]�                P	checkDaemonStatus=$($checkDaemonBin $daemonName "$daemonName" > /dev/null 2>&1)�                	currentHour=$(date +%H:%M:%S)�   
             	currentDate=$(date +%F)�   	             	time=$(date +%s)�      
          do�      	          while true;�                 �                -checkDaemonBin="/usr/local/bin/check_proc.sh"�                daemonName="DAEMON_NAME"�                interval=20�                hostname="INSTANCE_ID"�                 �                 #!/bin/bash5��