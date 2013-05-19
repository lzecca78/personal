#!/bin/bash
#
################################################################################
#
#Script created  by Luca Zecca --- l.zecca78@gmail.com
#
################################################################################


##########################################################
#VARIABILI
##########################################################

echo "checking if tomcat connectors exist"

if [ $(ls | grep -c connectors) -eq 0 ]
then 
    echo "please download tomcat-connectors source archive from the link written in the README file"
exit 10
fi


echo "checking last apache 2.4.x version and downloading it"

APACHEVER="$(curl http://httpd.apache.org/download.cgi#apache24 | grep 2.4.* | grep gz | grep -i unix | cut -d= -f2 | cut -d">" -f1 | sed -e 's/"//g' | cut -d"/" -f6)"

wget $(curl http://httpd.apache.org/download.cgi#apache24 | grep 2.4.* | grep gz | grep -i unix | cut -d= -f2 | cut -d">" -f1 | sed -e 's/"//g')

if [ $? -ne 0 ]
then
echo "error while getting last apache source archive, download it manually and change APACHEVER variable value"
exit 11
fi


#APACHEVER="httpd-2.4.4"
JKVER="tomcat-connectors-1.2.37-src"
INITAPACHE="/etc/init.d/httpd2"
INSTALLATION_HOME=$(pwd)
JKPKG="$JKVER.tar.gz"
JKDIR="$JKVER"
APACHEPKG="$APACHEVER"
APACHEDIR="$APACHEVER"



echo "Inizio compilazione di Apache $APACHEVER  con modulo shared di mod_jk $JKVER"
sleep 3


##########################################################
#check del pacchetto $APACHEPKG
##########################################################
if [ -e $APACHEPKG ]

	then
		echo "il file $APACHEPKG esiste, continuo con il processo d'installazione"
	else
		echo "il file $APACHEPKG nella dir $INSTALLATION_HOME non è stato trovato, controlla se esiste o imposta diversamente la variabile \$APACHEVER"
		exit 0
fi

##########################################################
#installazione dei pacchetti necessari alla compilazione
##########################################################

echo "installo i pacchetti necessari per la compilazione"


yum install -y gcc-c++ pcre-devel apr-util apr-util-devel gcc zlib zlib-devel openssl openssl-devel

##########################################################
#controllo la versione del kernel 32/64 bit
##########################################################

if [[ $(uname -p | grep -o 64) = 64 ]]

	then
	
		echo " il server utilizza  un kernel a 64 bit, compilerò apache con le librerie ottimizzate"

		library_compile=lib64
		sleep 2
		
	else
	
		echo " il server utilizza un kernel a 32 bit"

		library_compile=lib
		sleep 2
fi

##########################################################
#creazione della directory dove sarà installato apache
##########################################################

echo "crea la directory di installazione di Apache2"
read root_apache2

if [[ x$root_apache2 != x ]]

then
	mkdir -p $root_apache2

else

	echo "directory non inserita. ciao ciao"
	exit

fi

##########################################################
#Decompressione del tarball di apache 2 
##########################################################

if [ -e $APACHEPKG ]

then 
	echo "decomprimo il file $APACHEPKG"
	tar -xzf $APACHEPKG


else

	echo " Inserisci il nome del tarball (gz) da compilare per apache"
	read tarball2

	##########################################################
	#controllo se  il nome fornito è davvero un file gzip o no
	##########################################################

	CHECKFILEGZIP=$(file $tarball2| grep -o gzip)

		if [[ $CHECKFILEGZIP != 'gzip' ]]

		then
			echo "Il nome del file che stai dando non è un formato gzip corretto"
			exit 1


		else
			echo "Decomprimo il file  $tarball2"
			tar -xzf $tarball2 


		fi

fi

echo "fine decompressione"
sleep 2
##########################################################
#entro nella directory e creo la configurazione di apache
##########################################################

if   [[ -d $APACHEDIR ]]

then 

	echo "entro nella cartella httpd e istanzio i parametri di compilazione"
	cd $APACHEDIR


	
  	OPTIONS_COMPILE="--with-mpm=worker --prefix=$root_apache2 -enable-$library_compile --enable-nonportable-atomics=yes --enable-cgi=shared --libdir=/usr/$library_compile" 

	MODULESNOT="--disable-userdir --disable-include  --disable-auth  --disable-actions --disable-asis  --disable-charset-lite"


	MODULESYES="--enable-cache=static --enable-alias=static --enable-deflate=static --enable-file-cache=static --enable-mem-cache=static --enable-mime-magic=static --enable-rewrite=static --enable-headers=static --enable-ssl=static --with-ssl=/usr/bin/openssl --enable-perl=static --enable-proxy=static --enable-proxy-ajp=static --enable-expires=static --enable-autoindex=static --enable-slotmem-shm=static --enable-slotmem-plain=static --enable-proxy_balancer=static --enable-lbmethod_bybusyness=static --enable-lbmethod_byrequests=static --enable-lbmethod_bytraffic=static --enable-static-support=static"  

	CFLAGS="-O2 -pipe -march=nocona" 


        echo "Sto per compilare apache con i seguenti parametri: $OPTIONS_COMPILE"
        sleep 2
        echo "Sto per compilare apache disabilitando i seguenti moduli:$MODULESNOT"
        sleep 2
        echo "Sto per compilare apache con questi moduli: $MODULESYES"
        sleep 4

##########################################################
#Chiedo conferma  per l'operazione di compilazione e installazione
##########################################################

        echo "Sei sicuro di voler continuare?(y/n)"
        read rispa

   	if [[ $rispa = y ]]


                then
                                
                        ./configure $OPTIONS_COMPILE $MODULESNOT $MODULESYES &&
                        make && make install



        else

                echo "interrompo. ciao ciao"
		exit 4

        fi


else

	echo "Scrivi la directory dove  è stato estratto apache"
	read $dirapache

	cd $dirapache


        OPTIONS_COMPILE="--with-mpm=worker --prefix=$root_apache2 -enable-$library_compile nonportable-atomics=yes --enable-cgi=shared --libdir=$library_compile"

        MODULESNOT="--disable-userdir --disable-include  --disable-auth  --disable-actions --disable-asis  --disable-charset-lite"


	MODULESYES="cache --enable-alias --enable-deflate --enable-file-cache --enable-mem-cache --enable-mime-magic --enable-rewrite --enable-headers --enable-ssl --with-ssl=/usr/bin/openssl --enable-perl --enable-proxy --enable-proxy-ajp --enable-expires --enable-autoindex"

        CFLAGS="-O2 -pipe -march=nocona"



	echo "Sto per compilare apache con i seguenti parametri: $OPTIONS_COMPILE"
	sleep 2
	echo "Sto per compilare apache disabilitando i seguenti moduli:$MODULESNOT"
	sleep 2 
	echo "Sto per compilare apache con questi moduli: $MODULESYES"
	sleep 4

	echo "Sei sicuro di voler continuare?(y/n)"
	read rispa


	if [[ $rispa = y ]]


		then

	        	./configure $OPTIONS_COMPILE $MODULESNOT $MODULESYES

			make && make install



		else

			echo "interrompo. ciao ciao"
			exit 4

	fi
fi





##########################################################
#Chiedo  di creare l'utente che avvierà apache2
##########################################################


echo "inserisci il nome utente che verrà usato per avviare il processo di apache"
read nome_apache

useradd $nome_apache
usermod -s /bin/false $nome_apache

##########################################################
#Modifico i permessi delle directory
##########################################################

echo "modifico i permessi della $root_apache2"

		chown -Rv root.$nome_apache $root_apache2/bin
		chmod  -Rv 700  $root_apache2/bin

		chown -Rv root.$nome_apache $root_apache2/conf
		chmod -Rv 770  $root_apache2/conf

		chown -Rv root.$nome_apache $root_apache2/logs
  		chmod -Rv 755  $root_apache2/logs

echo "aggiungo la $root_apache2/bin nel path"
sleep 2

echo "PATH=$PATH:$root_apache2/bin" >> /etc/profile

source /etc/profile
sleep 2

echo "creo la directory per i virtualhost ($root_apache2/vhosts)"

mkdir -p $root_apache2/vhosts
sleep 2

echo "creo la directory per il pidfile e per il lockfile e per il CGI socket"
mkdir -p $root_apache2/pids
sleep 2
##############################################################################################
#Configurazione del certificato SSL con autenticazione
##############################################################################################
 
 echo "inserisco un file con le direttive per l'autenticazione automatica di certificato SSL"
 
 touch $root_apache2/conf/ssl_password_howto
 /bin/cat  > $root_apache2/conf/ssl_password_howto << SSLPASWDHOWTO
 
 in httpd.conf aggiungere :
 SSLPassPhraseDialog exec:$root_apache2/conf/ssl-passphrase
 
 creare uno script ssl-passphrase con il seguente contenuto
!/bin/bash
echo "$pswd_ssl"

 dare  i permessi di esecuzione allo script appena creato
chmod +x $root_apache2/conf/ssl-passphrase

Riavviare Apache

SSLPASWDHOWTO


#############################################################
#
# Hardening di Apache2
#
#############################################################
echo "aggiungo al file $root_apache2/conf/httpd.conf le direttive per renderlo impenetrabile :D:D:D:D"

echo "ServerSignature Off" >> $root_apache2/conf/httpd.conf
echo "ServerTokens Prod"   >> $root_apache2/conf/httpd.conf
sleep 4


########################################################################################################################
#
# Compilazione mod_jk per apache ( aggiunto il 11-08-2009 )
#
########################################################################################################################
echo " Vuoi compilare anche mod_jk per $APACHEVER  ?"
read jkanswer



if [[ $jkanswer = y ]]

	then

		cd $INSTALLATION_HOME
		tar -xzvf  $JKPKG
		cd $JKDIR/native
		./configure \
		shared=jk \
		--with-apxs=$root_apache2/bin/apxs 

		make && make install


		echo "aggiungo le direttive del mod_jk nel $root_apache2/conf/httpd.conf"

		/bin/cat >> $root_apache2/conf/httpd.conf << INIZIOMODJK



LoadModule jk_module modules/mod_jk.so

JkWorkersFile $root_apache2/conf/workers.properties
JkLogFile $root_apache2/logs/mod_jk.log
JkLogLevel info
JkLogStampFormat "[%a %b %d %H:%M:%S %Y]"
JkRequestLogFormat "%w %V %T"
JkOptions +ForwardKeySize
JkOptions +ForwardURICompatUnparsed
JkOptions +ForwardDirectories
JkShmFile $root_apache2/pids/jk.shm

    <Location /jkstatus/>
        JkMount status
        Order deny,allow
        Deny from all
        Allow from 127.0.0.1
     </Location>

INIZIOMODJK

	echo "Aggiungo un file workers.properties di esempio"
sleep 2
	/bin/cat > $root_apache2/conf/workers.properties << WORKERSAMPLE

# Define list of workers that will be used
# for mapping requests
   worker.list=atlas2wrk,status

# Define atlas2wrk
   worker.atlas2wrk.port=8009
   worker.atlas2wrk.host=127.0.0.1
   worker.atlas2wrk.type=ajp13
   worker.atlas2wrk.lbfactor=1
   #worker.atlas2wrk.local_worker=1 (1)
   worker.atlas2wrk.cachesize=10

# Status worker for managing load balancer
   worker.status.type=status

####### Per tuning timeout

   worker.atlas2wrk.connect_timeout=10000
   worker.atlas2wrk.prepost_timeout=10000
   worker.atlas2wrk.socket_timeout=10
   worker.atlas2wrk.connection_pool_timeout=600


WORKERSAMPLE



	else
		echo "la compilazione del mod_jk non verrà effettuata"
		sleep 4
fi



echo "controllo la versione e i moduli installati"

httpd -V
sleep 3
httpd -D DUMP_MODULES
sleep 3

########################################################################################################################
#
# Modifiche post-installazione richieste a mano - utente/gruppo apache, configurazione e creazione del pid e lockfile, cgisocket
#
########################################################################################################################

/bin/cat >> $root_apache2/conf/httpd.conf << RULEHT
<Directory $root_apache2/htdocs>
 <LimitExcept GET POST>
   deny from all
 </LimitExcept>
 Options -FollowSymLinks -Includes -Indexes -MultiViews
 AllowOverride None
 Order allow,deny
 Allow from all
</Directory>
RULEHT


if [ -e $INITAPACHE ]

then 
	echo "uno script di avvio esiste già,lo rinomino in $INITAPACHE_$(date +%F)"
	mv $INITAPACHE $INITAPACHE_$(date +%F)
	echo "configuro lo script di avvio per la nuova installazione di Apache in $INITAPACHE"
	cat $INSTALLATION_HOME/httpd2 | sed -e "s/ROOT_APACHE=\/opt\/new_apache/ROOT_APACHE=$root_apache2/g" > $INITAPACHE
else
	echo "configuro lo script di avvio per la nuova installazione di Apache in $INITAPACHE"
	cat $INSTALLATION_HOME/httpd2 | sed -e "s/ROOT_APACHE=\/opt\/new_apache/ROOT_APACHE=$root_apache2/g" > $INITAPACHE
fi



echo "Modifica l'utente e il gruppo proprietari di apache con $nome_apache nel file $root_apache2/conf/httpd.conf"
echo "modifica e decommenta il file $root_apache2/conf/extra/httpd-mpm.conf per la directory di creazione del pid [ $root_apache2/pids] e lock file [$root_apache2/pids]"
sleep 2
echo "modifica e decommenta il file $root_apache2/conf/httpd.conf nella direttiva Scriptsock per il cgi socket file [$root_apache2/pids]"
sleep 2
########################################################################################################################
#
# Creazione della entry per il logrotate
#
########################################################################################################################


echo "creazione delle directory di repository dei log di apache (/opt/archivio_log/apache2)"

	mkdir -p /opt/archivio_log/apache2
	mkdir -p $root_apache2/logs/old
	echo "" > /etc/logrotate.d/apache2

echo "creo la directory per i certificati SSL"
	mkdir -p $root_apache2/ssl

echo "inserisco il file per logrotate in /etc/logrotate.d"

	/bin/cat > /etc/logrotate.d/apache2 << INIZIOLOGROTATE

        $root_apache2/logs/*.log {
        daily
       	ifempty
        rotate 2
        compress
        olddir $root_apache2/logs/old
        sharedscripts
        firstaction
        chattr -a $root_apache2/logs/*.log
        endscript
        sharedscripts
        lastaction
        mkdir -p /opt/archivio_log/\$(date +%F) && mv $root_apache2/logs/old/*.gz /opt/archivio_log/\$(date +%F)
        kill -HUP \$(cat $root_apache2/pids/httpd.pid)
        sleep 2
        chattr +a $root_apache2/logs/*.log
        endscript
        }

INIZIOLOGROTATE



