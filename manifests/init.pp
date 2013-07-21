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
class sssd (
  $domains,
  $filter_users    = [ 'root' ],
  $filter_groups   = [ 'root' ]
) {
  validate_array($domains)
  validate_array($filter_users)
  validate_array($filter_groups)

  concat::fragment{ 'sssd_conf_header':
    target  => 'sssd_conf',
    content => template('sssd/header_sssd.conf.erb'),
    order   => 10,
  }

  package { 'sssd':
    ensure      => installed,
  } -> concat { 'sssd_conf':
    path        => '/etc/sssd/sssd.conf',
    mode        => 400,
  } ~> exec { 'authconfig-sssd':
    command     => '/usr/sbin/authconfig --enablesssd --enablesssdauth --enablelocauthorize --update',
    refreshonly => true,
  } ~> service { 'sssd':
    ensure      => running,
    enable      => true,
  }
}