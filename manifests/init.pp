# == Class: sssd
# Manage SSSD authentication on RHEL-based systems.
#
# === Parameters
# [*domains*]
# Required. Array. For each sssd::domain type you declare, you SHOULD also
# include the domain name here. This defines the domain lookup order.
#
# [*filter_users*]
# Optional. Array. Default is 'root'. Exclude specific users from being
# fetched using sssd. This is particularly useful for system accounts.
#
# [*filter_groups*]
# Optional. Array. Default is 'root'. Exclude specific groups from being
# fetched using sssd. This is particularly useful for system accounts.
#
# === Requires
# - [ripienaar/concat]
# - [puppetlab/stdlib]
#
# === Example
# class { 'sssd':
#   domains => [ 'uni.adr.unbc.ca' ],
# }
#
# === Authors
# Nicholas Waller <code@nicwaller.com>
#
# === Copyright
# Copyright 2013 Nicholas Waller, unless otherwise noted.
#
class sssd (
  $domains,
  $filter_users    = [ 'root' ],
  $filter_groups   = [ 'root' ]
) {
  validate_array($domains)
  validate_array($filter_users)
  validate_array($filter_groups)

  package { 'sssd':
    ensure      => installed,
  }
  
  concat { 'sssd_conf':
    path        => '/etc/sssd/sssd.conf',
    mode        => '0600',
    # SSSD fails to start if file mode is anything other than 0600
    require     => Package['sssd'],
  }
  
  concat::fragment{ 'sssd_conf_header':
    target  => 'sssd_conf',
    content => template('sssd/header_sssd.conf.erb'),
    order   => 10,
  }

  exec { 'authconfig-sssd':
    command     => '/usr/sbin/authconfig --enablesssd --enablesssdauth --enablelocauthorize --update',
    refreshonly => true,
    subscribe   => Concat['sssd_conf'],
  }
  
  service { 'sssd':
    ensure      => running,
    enable      => true,
    subscribe   => Exec['authconfig-sssd'],
  }
}
