# == Class: redis
#
# Install and configure a Redis server
#
# === Parameters
#
# All the redis.conf parameters can be passed to the class.
# Check the README.md file
#
# === Variables
#
# Here you should define a list of variables that this module would require.
#
# === Examples
#
#  class { redis:
#    $conf_port => '6380',
#    $conf_bind => '0.0.0.0',
#  }
#
# === Authors
#
# Felipe Salum <fsalum@gmail.com>
# Ryan O'Keeffe <danielredoak@gmail.com> Updated for 2.6+
#
# === Copyright
#
# Copyright 2013 Felipe Salum, unless otherwise noted.
#
class redis (
  $package_ensure                         = 'present',
  $service_ensure                         = 'running',
  $service_enable                         = true,
  $conf_daemonize                         = 'yes',
  $conf_pidfile                           = UNSET,
  $conf_port                              = '6379',
  $conf_bind                              = '127.0.0.1',
  $conf_timeout                           = '0',
  $conf_loglevel                          = 'notice',
  $conf_logfile                           = UNSET,
  $conf_syslog_enabled                    = UNSET,
  $conf_syslog_ident                      = UNSET,
  $conf_syslog_facility                   = UNSET,
  $conf_databases                         = '16',
  $conf_save                              = UNSET,
  $conf_nosave                            = UNSET,
  $conf_rdbcompression                    = 'yes',
  $conf_dbfilename                        = 'dump.rdb',
  $conf_dir                               = '/var/lib/redis/',
  $conf_slaveof                           = UNSET,
  $conf_masterauth                        = UNSET,
  $conf_slave_server_stale_data           = 'yes',
  $conf_repl_ping_slave_period            = '10',
  $conf_repl_timeout                      = '60',
  $conf_requirepass                       = UNSET,
  $conf_maxclients                        = UNSET,
  $conf_maxmemory                         = UNSET,
  $conf_maxmemory_policy                  = UNSET,
  $conf_maxmemory_samples                 = UNSET,
  $conf_appendonly                        = 'no',
  $conf_appendfilename                    = UNSET,
  $conf_appendfsync                       = 'everysec',
  $conf_no_appendfsync_on_rewrite         = 'no',
  $conf_auto_aof_rewrite_percentage       = '100',
  $conf_auto_aof_rewrite_min_size         = '64mb',
  $conf_slowlog_log_slower_than           = '10000',
  $conf_slowlog_max_len                   = '1024',
  $conf_hash_max_zipmap_entries           = '512',
  $conf_hash_max_zipmap_value             = '64',
  $conf_list_max_ziplist_entries          = '512',
  $conf_list_max_ziplist_value            = '64',
  $conf_set_max_intset_entries            = '512',
  $conf_zset_max_ziplist_entries          = '128',
  $conf_zset_max_ziplist_value            = '64',
  $conf_activerehashing                   = 'yes',
  $conf_include                           = UNSET,
  $conf_stopwrite_bgsaveerror             = 'yes',
  $conf_rdbchecksum                       = 'yes',
  $conf_slave_read_only                   = 'yes',
  $conf_repl_disable_tcp_nodelay          = 'no',
  $conf_slave_priority                    = '100',
  $conf_lua_time_limit                    = '5000',
  $conf_client_output_buffer_limit_normal = '0 0 0',
  $conf_client_output_buffer_limit_slave  = '256mb 64mb 60',
  $conf_client_output_buffer_limit_pubsub = '32mb 8mb 60',
  $conf_hz                                = '10',
  $conf_aof_rewrite_incremental_fsync     = 'yes',
  $conf_tcp_keepalive                     = '0',
) {

  include redis::params

  $conf_template  = $redis::params::conf_template
  $conf_redis     = $redis::params::conf
  $conf_logrotate = $redis::params::conf_logrotate
  $package        = $redis::params::package
  $service        = $redis::params::service

  $conf_pidfile_real = $conf_pidfile ? {
    'UNSET' => $::redis::params::pidfile,
    default => $conf_pidfile,
  }

  $conf_logfile_real = $conf_logfile ? {
    'UNSET' => $::redis::params::logfile,
    default => $conf_logfile,
  }

  package { 'redis':
    ensure => $package_ensure,
    name   => $package,
  }

  service { 'redis':
    ensure     => $service_ensure,
    name       => $service,
    enable     => $service_enable,
    hasrestart => true,
    hasstatus  => true,
    require    => Package['redis'],
  }

  file { $conf_redis:
    path    => $conf_redis,
    content => template("redis/${conf_template}"),
    owner   => root,
    group   => root,
    mode    => '0644',
    require => Package['redis'],
    notify  => Service['redis'],
  }

  file { $conf_logrotate:
    path    => $conf_logrotate,
    content => template('redis/redis.logrotate.erb'),
    owner   => root,
    group   => root,
    mode    => '0644',
  }

  exec { $conf_dir:
    path    => '/bin:/usr/bin:/sbin:/usr/sbin',
    command => "mkdir -p ${conf_dir}",
    user    => root,
    group   => root,
    creates => $conf_dir,
    before  => Service['redis'],
    require => Package['redis'],
    notify  => Service['redis'],
  }

  file { $conf_dir:
    ensure  => directory,
    owner   => redis,
    group   => redis,
    before  => Service['redis'],
    require => Exec[$conf_dir],
  }

}
