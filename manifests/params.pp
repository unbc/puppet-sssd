# == Class: sssd::params
# 
# Set up parameters that vary based on platform or distribution.
# 
# UID_MIN is the lowest uid allowed for use by non-system accounts.
# UID_MIN is often defined in /etc/login.defs
# As of RedHat Enterprise Linux 6, UID_MIN is still 500.
# But in Fedora >= 16, UID_MIN has been changed to 1000.
# https://fedoraproject.org/wiki/Features/1000SystemAccounts
# I'm choosing to set 1000 as the default here, to be safe and
# forward-compatible.
#
# === Examples
#
# class { 'sssd::params': }
#
# === Authors
#
# Nicholas Waller <code@nicwaller.com>
#
# === Copyright
#
# Copyright 2013 Nicholas Waller, unless otherwise noted.
#
class sssd::params {
  case $::osfamily {
    'RedHat': {
      $dist_uid_min = 1000
    }
    default: {
      fail('Unsupported distribution')
    }
  }
}
