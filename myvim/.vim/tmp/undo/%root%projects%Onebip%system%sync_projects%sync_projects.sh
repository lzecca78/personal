Vim�UnDo� �K��]G��S)��R� �L����y��
�u�   7   	echo $value                             R3"F    _�                             ����                                                                                                                                                                                                                                                                                                                                                             R3"7     �                 5�_�                            ����                                                                                                                                                                                                                                                                                                                                                             R3":     �         7      
	echo $key5�_�                            ����                                                                                                                                                                                                                                                                                                                                                             R3";     �         7      	echo $key5�_�                           ����                                                                                                                                                                                                                                                                                                                                                             R3"<     �         7      	value=${arrayProject["$key"]}5�_�                           ����                                                                                                                                                                                                                                                                                                                                                             R3"=     �         7          echo $key5�_�                           ����                                                                                                                                                                                                                                                                                                                                                             R3"@     �         7      	echo $value5�_�                     7       ����                                                                                                                                                                                                                                                                                                                                                             R3"E    �   6   8          rsyncProject�   5   7           �   4   6          fi�   3   5          
    exit 1�   2   4          G    echo "no server Aws found on rightscali api file,find why, exiting"�   1   3          then�   0   2          if [ -z $masterAws ]�   /   1           �   .   0          }�   -   /          done�   ,   .          �rsync -az -e " ssh -o StrictHostKeyChecking=no -o UserKnownHostsFile=/dev/null -i $rsyncKey"  root@$masterAws:${arrayDir[$dir]} /var/www�   +   -          do�   *   ,          for dir in $mandatoryDir�   )   +           �   (   *          done�   '   )          5    ln -s ${arrayProject[$project]} /var/www/$project�   &   (          <    echo "ln -s ${arrayProject[$project]} /var/www/$project"�   %   '              fi�   $   &                  exit 2�   #   %          3        echo "rsync error during transfer $project"�   "   $              then�   !   #              if [ $? -ne 0 ]�       "          �    rsync -az -e " ssh -o StrictHostKeyChecking=no -o UserKnownHostsFile=/dev/null -i $rsyncKey" root@$masterAws:${arrayProject[$project]} /var/www�      !          do�                 for project in $projectList�                 �                function rsyncProject() {�                 �                 �                done�                    echo $value�                !    value=${arrayProject["$key"]}�                    echo $key�                do�                !for key in  "${!arrayProject[@]}"�                 �                 �                 �                done�                ,    declare  -A arrayDir[$dir]=/var/www/$dir�                do�                for dir in $mandatoryDir�                 �                done�   
             � 	declare  -A arrayProject[$link]=$(ssh -o StrictHostKeyChecking=no -o UserKnownHostsFile=/dev/null -i $rsyncKey $masterAws "readlink /var/www/$link")�   	             do�      
          for link in $projectList�      	           �                 �                (mandatoryDir="bin data zf memcacheAdmin"�                /projectList="onebip onebip-ultimate rest front"�                0masterAws=$(head -n1 $gitRoot/prsync/hosts_file)�                rsyncKey="/root/onebip_default"�                gitRoot="/tmp/git"�                 #!/bin/bash5��