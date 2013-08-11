#!/bin/bash
mkdir -p /var/log/onebip/{onebip,rest,front}/old_logs
mkdir -p /var/log/apache2/old_logs

logrotate -v -f apache2 > /tmp/my_logrotate.log 2>&1

