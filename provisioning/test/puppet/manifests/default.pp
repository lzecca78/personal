# puppet/manifests/base.pp
#
class repository {
  # We need cURL installed to import the key
  package { 'curl':
    ensure => installed
}

package { 'python-software-properties':
    name => 'python-software-properties',
    ensure => installed,
}

  # Installs the GPG key
  exec { 'import-key':
    path    => '/bin:/usr/bin',
    command => 'curl http://repos.servergrove.com/servergrove-ubuntu-precise/servergrove-ubuntu-precise.gpg.key | apt-key add -',
    unless  => 'apt-key list | grep servergrove-ubuntu-precise',
    require => Package['curl'],
  }

  # Creates the source file for the ServerGrove repository
  file { 'servergrove.repo':
    path    => '/etc/apt/sources.list.d/servergrove.list',
    ensure  => present,
    content => 'deb http://repos.servergrove.com/servergrove-ubuntu-precise precise main',
    require => Exec['import-key'],
  }


exec { 'ondrej_repo':
    path  => '/bin:/usr/bin',
    command => 'add-apt-repository ppa:ondrej/php5',
    require => Package['python-software-properties'],
}




  # Refreshes the list of packages
  exec { 'apt-get-update':
    command => 'apt-get update',
    path    => ['/bin', '/usr/bin'],
    require => File['servergrove.repo'],
  }
}
# ...

stage { pre:
    before => Stage[main]
}

class { 'repository':
  # Forces the repository to be configured before executing any other task
  stage => pre
}

#define class apache for apache installation

class apache {
  # Ensures Apache2 is installed
  package { 'apache2':
    name => 'apache2-mpm-prefork', # httpd if CentOS
    ensure => installed,
  }

  # Ensures the Apache service is running
  service { 'apache2':
    ensure  => running,
    require => Package['apache2'],
  }
}
include apache

#class mysql for mysql installation

class mysql {
  # Installs the MySQL server and MySQL client
  package { ['mysql-server', 'mysql-client']: ensure => installed, }

  # Ensures the Apache service is running
  service { 'mysql':
    ensure  => running,
    require => Package['mysql-server'],
  }
}

include mysql

class php {
  # Installs PHP and restarts Apache to load the module
  package { ['php5', 'php5-curl','php-pear', 'php5-mysql', 'php5-cli', 'php5-common']:
    ensure  => installed,
    notify  => Service['apache2'],
    require => [File['servergrove.repo'], Package['mysql-client'], Package['apache2'], Package['python-software-properties'], Exec['ondrej_repo']],
  }
}

include php




