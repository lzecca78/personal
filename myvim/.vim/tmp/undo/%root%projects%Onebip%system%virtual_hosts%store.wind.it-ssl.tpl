Vim�UnDo� {�DD���s�d#�~��,-��H�H/B��	�k��   C   7	RewriteRule ^/(.*)$  http://maintenance.onebip.com [L]      6                       R\��    _�                        6    ����                                                                                                                                                                                                                                                                                                                                                             R\�t     �         C      7	RewriteRule ^/(.*)$  http://maintenance.onebip.com [L]5�_�                        ;    ����                                                                                                                                                                                                                                                                                                                                                             R\��    �   B   D          </VirtualHost>�   A   C           �   @   B           �   ?   A          R    CustomLog /var/log/apache2/robots.log combined_with_time_taken env=robot-agent�   >   @          d    #CustomLog /var/log/apache2/__SERVER_NAME__.access.log combined_with_time_taken env=!robot-agent�   =   ?          �    CustomLog "|/usr/bin/tee -a /var/log/apache2/__SERVER_NAME__.access.log |/usr/bin/logger_compiled -t __SERVER_NAME__.access-ssl.log -plocal5.info" combined_with_time_taken env=!robot-agent�   <   >              LogFormat "%{X-Forwarded-For}i %h %l %u %t \"%r\" %>s %b \"%{Referer}i\" \"%{User-Agent}i\" %T/%D" combined_with_time_taken�   ;   =          K    SetenvIf User-Agent "Amazon Route 53 Health Check Service"  robot-agent�   :   <              LogLevel warn�   9   ;              # alert, emerg.�   8   :          F    # Possible values include: debug, info, notice, warn, error, crit,�   7   9           �   6   8          8    #ErrorLog /var/log/apache2/__SERVER_NAME__.error.log�   5   7          �    ErrorLog "|/usr/bin/tee -a /var/log/apache2/__SERVER_NAME__.error.log |/usr/bin/logger_compiled -t __SERVER_NAME__.error-ssl.log -plocal5.error"�   4   6           �   3   5           �   2   4          7        BrowserMatch "MSIE [17-9]" ssl-unclean-shutdown�   1   3          :        # MSIE 7 and newer should be able to use keepalive�   0   2          0                downgrade-1.0 force-response-1.0�   /   1          2                nokeepalive ssl-unclean-shutdown \�   .   0          "       BrowserMatch "MSIE [2-6]" \�   -   /           �   ,   .                  </Directory>�   +   -          &                SSLOptions +StdEnvVars�   *   ,          $        <Directory /usr/lib/cgi-bin>�   )   +                  </FilesMatch>�   (   *          &                SSLOptions +StdEnvVars�   '   )          /        <FilesMatch "\.(cgi|shtml|phtml|php)$">�   &   (           �   %   '          ?    SSLCACertificateFile /etc/apache2/ssl/wind/sureserversv.crt�   $   &          A    SSLCertificateKeyFile /etc/apache2/ssl/wind/store.wind.it.key�   #   %          >    SSLCertificateFile /etc/apache2/ssl/wind/store.wind.it.crt�   "   $              SSLEngine on�   !   #           �       "           �      !              </Directory>�                         allow from all�                        Order allow,deny�                        AllowOverride All�                1        Options Indexes FollowSymLinks MultiViews�                    <Directory /var/www>�                    </Directory>�                        AllowOverride None�                        Options FollowSymLinks�                    <Directory />�                 �                    #### End Maintenance Rules�                =	RewriteRule ^/(.*)$  http://maintenance.onebip.com [L,R=503]�                .	RewriteCond %{REMOTE_ADDR} !^54\.(2[0-9]+)\. �                	# amazon route53 check page�                ,	RewriteCond %{REMOTE_ADDR} !^10\.0\.2\.187 �                ,	RewriteCond %{REMOTE_ADDR} !^10\.0\.0\.127 �                	# haproxy lb check page�                &	RewriteCond %{REMOTE_ADDR} !^10\.0\.3�                &	RewriteCond %{REMOTE_ADDR} !^10\.0\.1�                !	# ipaddress ws-a , ws-b internal�   
             *	RewriteCond %{REMOTE_ADDR} !^127\.0\.0\.1�   	             *	RewriteCond %{REMOTE_ADDR} !^10\.1\.99\. �      
          	 # openvpn ipaddress subnet�      	          )	RewriteCond /var/www/maintenance.html -f�                	RewriteEngine on�                    #### Maintenance Rules�                 �                "    DocumentRoot __DOCUMENT_ROOT__�                    ServerName __SERVER_NAME__�                     ServerAdmin __SERVER_ADMIN__�                 <VirtualHost *:443>5��