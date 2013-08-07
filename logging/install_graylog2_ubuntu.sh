#! /bin/bash
#Provided by @mrlesmithjr
#EveryThingShouldBeVirtual.com
set -x
#
#
# Ubuntu Install Script
#
# Setup logging
# Logs stderr and stdout to separate files.
mkdir -p ~/graylog2
exec 2> >(tee "./graylog2/install_graylog2.err")
exec > >(tee "./graylog2/install_graylog2.log")

# Apache Settings
# change x.x.x.x to whatever your ip address is of the server you are installing on or let the script auto detect your IP
# which is the default
# SERVERNAME="x.x.x.x"
# SERVERALIAS="x.x.x.x"
#
#
echo "Detecting IP Address"
IPADDY="$( ifconfig | grep -A 1 'eth0' | tail -1 | cut -d ':' -f 2 | cut -d ' ' -f 1)"
echo "Detected IP Address is $IPADDY"

SERVERNAME=$IPADDY
SERVERALIAS=$IPADDY

 apt-get -qq update

# Install Pre-Reqs
apt-get -y install git curl apache2 libcurl4-openssl-dev apache2-prefork-dev libapr1-dev libcurl4-openssl-dev apache2-prefork-dev libapr1-dev build-essential openssl libreadline6 libreadline6-dev curl git-core zlib1g zlib1g-dev libssl-dev libyaml-dev libsqlite3-dev sqlite3 libxml2-dev libxslt-dev autoconf libc6-dev ncurses-dev automake libtool bison subversion pkg-config python-software-properties software-properties-common

# Install Oracle Java 7
echo "Installing Oracle Java 7"
add-apt-repository -y ppa:webupd8team/java
apt-get -qq update
echo oracle-java7-installer shared/accepted-oracle-license-v1-1 select true |  /usr/bin/debconf-set-selections
apt-get -y install oracle-java7-installer

echo "Downloading Elasticsearch"
git clone https://github.com/elasticsearch/elasticsearch-servicewrapper.git
chown -R $USER:$USER /opt
cd /opt
git clone https://github.com/elasticsearch/elasticsearch-servicewrapper.git

# Download Elasticsearch, Graylog2-Server and Graylog2-Web-Interface
echo "Downloading Elastic Search, Graylog2-Server and Graylog2-Web-Interface to /opt"
wget https://download.elasticsearch.org/elasticsearch/elasticsearch/elasticsearch-0.20.6.tar.gz
wget https://github.com/Graylog2/graylog2-server/releases/download/0.12.0/graylog2-server-0.12.0.tar.gz
wget https://github.com/Graylog2/graylog2-web-interface/releases/download/0.12.0/graylog2-web-interface-0.12.0.tar.gz

# Extract files
echo "Extracting Elasticsearch, Graylog2-Server and Graylog2-Web-Interface to /opt"
for f in *.tar.gz
do
tar zxf "$f"
done

# Create Symbolic Links
echo "Creating SymLinks for elasticsearch and graylog2-server"
ln -s elasticsearch-0.20.6/ elasticsearch
#ln -s graylog2-server-0.11.0/ graylog2-server
ln -s graylog2-server-0.12.0/ graylog2-server

# Install elasticsearch
echo "Installing elasticsearch"
mv *servicewrapper*/service elasticsearch/bin/
rm -Rf *servicewrapper*
/opt/elasticsearch/bin/service/elasticsearch install
ln -s `readlink -f elasticsearch/bin/service/elasticsearch` /usr/bin/elasticsearch_ctl
sed -i -e 's|# cluster.name: elasticsearch|cluster.name: graylog2|' /opt/elasticsearch/config/elasticsearch.yml
/etc/init.d/elasticsearch start

# Test elasticsearch
# curl -XGET 'http://localhost:9200/_cluster/health?pretty=true'

# Install mongodb
echo "Installing MongoDB"
apt-key adv --keyserver hkp://keyserver.ubuntu.com:80 --recv 7F0CEB10
echo "deb http://downloads-distro.mongodb.org/repo/ubuntu-upstart dist 10gen" |  tee /etc/apt/sources.list.d/10gen.list
apt-get -qq update
apt-get -y install mongodb-10gen

# Install graylog2-server
echo "Installing graylog2-server"
cd graylog2-server-0.12.0/
cp /opt/graylog2-server/elasticsearch.yml{.example,}
ln -s /opt/graylog2-server/elasticsearch.yml /etc/graylog2-elasticsearch.yml
echo "discovery.zen.ping.multicast.enabled: false" >> /etc/graylog2-elasticsearch.yml
echo "discovery.zen.ping.unicast.hosts: $IPADDY:9300" >> /etc/graylog2-elasticsearch.yml
cp /opt/graylog2-server/graylog2.conf{.example,}
ln -s /opt/graylog2-server/graylog2.conf /etc/graylog2.conf
sed -i -e 's|mongodb_useauth = true|mongodb_useauth = false|' /opt/graylog2-server/graylog2.conf

# Create graylog2-server startup script
echo "Creating /etc/init.d/graylog2-server startup script"
(
cat <<'EOF'
#!/bin/sh
#
# graylog2-server: graylog2 message collector
#
# chkconfig: - 98 02
# description: This daemon listens for syslog and GELF messages and stores them in mongodb
#
CMD=$1
NOHUP=`which nohup`
JAVA_CMD=/usr/bin/java
GRAYLOG2_SERVER_HOME=/opt/graylog2-server
start() {
 echo "Starting graylog2-server ..."
$NOHUP $JAVA_CMD -jar $GRAYLOG2_SERVER_HOME/graylog2-server.jar > /var/log/graylog2.log 2>&1 &
}

stop() {
PID=`cat /tmp/graylog2.pid`
echo "Stopping graylog2-server ($PID) ..."
kill $PID
}

restart() {
echo "Restarting graylog2-server ..."
stop
start
}

case "$CMD" in
start)
start
;;
stop)
stop
;;
restart)
restart
;;
*)
echo "Usage $0 {start|stop|restart}"
RETVAL=1
esac
EOF
) |  tee /etc/init.d/graylog2-server

# Make graylog2-server executable
 chmod +x /etc/init.d/graylog2-server

# Start graylog2-server on bootup
echo "Making graylog2-server startup on boot"
update-rc.d graylog2-server defaults

# Install graylog2 web interface
echo "Installing graylog2-web-interface"
cd /opt/
ln -s graylog2-web-interface-0.12.0 graylog2-web-interface

# Install Ruby
echo "Installing Ruby"
 apt-get -y install libgdbm-dev libffi-dev
\curl -L https://get.rvm.io | bash -s stable
source  /usr/local/rvm/scripts/rvm
rvm install 1.9.3-p448

# Install Ruby Gems
echo "Installing Ruby Gems"
rvm use 1.9.3-p448
cd /opt/graylog2-web-interface
gem install bundler --no-ri --no-rdoc
bundle install

# Set MongoDB Settings
echo "Configuring MongoDB"
echo "
production:
 host: localhost
 port: 27017
 username: grayloguser
 password: password123
 database: graylog2" | tee /opt/graylog2-web-interface/config/mongoid.yml

# Create MongoDB Users and Set Passwords
echo Creating MongoDB Users and Passwords
mongo admin --eval "db.addUser('admin', 'password123')"
mongo admin --eval "db.auth('admin', 'password123')"
mongo graylog2 --eval "db.addUser('grayloguser', 'password123')"
mongo graylog2 --eval "db.auth('grayloguser', 'password123')"

# Test Install
# cd /opt/graylog2-web-interface
# RAILS_ENV=production script/rails server

# Install Apache-passenger
echo Installing Apache-Passenger Modules
rvm use 1.9.3-p448
gem install --version '3.0.18' passenger
passenger-install-apache2-module --auto


# Add passenger modules for Apache2
echo "Adding Apache Passenger modules to /etc/apache2/httpd.conf"
echo  "LoadModule passenger_module /usr/local/rvm/gems/ruby-1.9.3-p448/gems/passenger-3.0.18/ext/apache2/mod_passenger.so" |  tee -a /etc/apache2/mods-available/passenger.load
echo "PassengerRoot /usr/local/rvm/gems/ruby-1.9.3-p448/gems/passenger-3.0.18" |  tee -a /etc/apache2/mods-available/passenger.conf
echo "PassengerRuby /usr/local/rvm/wrappers/ruby-1.9.3-p448/ruby" |  tee -a /etc/apache2/mods-available/passenger.conf

# Enable passenger modules
a2enmod passenger

# Restart Apache2
echo "Restarting Apache2"
/etc/init.d/apache2 restart
# If apache fails and complains about unable to load mod_passenger.so check and verify that your passengerroot version matches

# Configure Apache virtualhost
echo "Configuring Apache VirtualHost"
echo "
<VirtualHost *:80>
ServerName ${SERVERNAME}
ServerAlias ${SERVERALIAS}
DocumentRoot /opt/graylog2-web-interface/public

#Allow from all
Options -MultiViews

ErrorLog /var/log/apache2/error.log
LogLevel warn
CustomLog /var/log/apache2/access.log combined
</VirtualHost>" |  tee /etc/apache2/sites-available/graylog2

# Enable virtualhost
echo "Enabling Apache VirtualHost Settings"
a2dissite 000-default
a2ensite graylog2
service apache2 reload

# Restart apache
echo "Restarting Apache2"
/etc/init.d/apache2 restart

echo "Updating graylog2.conf"
 sed -i -e 's|syslog_listen_port = 514|syslog_listen_port = 10514|' /etc/graylog2.conf
 sed -i -e 's|mongodb_password = 123|mongodb_password = password123|' /etc/graylog2.conf

#Fixing issue with secret_toke in /opt/graylog2-web-interface/config/initializers/secret_token.rb
 sed -i -e "s|Graylog2WebInterface::Application.config.secret_token = 'CHANGE ME'|Graylog2WebInterface::Application.config.secret_token = 'b356d1af93673e37d6e21399d033d77c15354849fdde6d83fa0dca19608aa71f2fcd9d1f2784fb95e9400d8eeaf6dd9584d8d35b8f0b5c231369a70aac5e5777'|" /opt/graylog2-web-interface/config/initializers/secret_token.rb


chown www-data.www-data /opt/graylog2-web-interface/ -R

## flush all rules on iptables!!!!!
iptables -F -v
# Restart All Services
echo "Restarting All Services Required for Graylog2 to work"
service elasticsearch restart
service mongodb restart
service graylog2-server restart
service rsyslog restart
service apache2 restart

# All Done
echo "Installation has completed!!"
echo "Browse to IP address of this Graylog2 Server Used for Installation"
echo "IP Address detected from system is $IPADDY"
echo "Browse to http://$IPADDY"
echo "You Entered $SERVERNAME During Install"
echo "Browse to http://$SERVERNAME If Different"

