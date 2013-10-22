Redis Module for Puppet
=======================
This module install and manages the Redis server version 2.6.7+. All redis.conf options are accepted in the parameterized class.

Operating System
----------------
Tested on CentOS 6.4.

Quick Start
-----------
Use the default parameters:

    class { 'redis': }

To change the port and listening network interface:

    class { 'redis':
      conf_port => '6379',
      conf_bind => '0.0.0.0',
    }

Parameters
----------

Check the [init.pp](https://github.com/danielredoak/puppet-redis/blob/master/manifests/init.pp) file for a list of parameters accepted.

Author
------
Original Implementation - Felipe Salum <fsalum@gmail.com>
Updated for 2.6+ - Ryan O'Keeffe <danielredoak@gmail.com>
