# == Class: sssd::homedir
# Allow home directories to be created automatically on first logon.
# This is very useful when authenticating against a directory!
# 
# Normally this would be a separate module, but there is a critical
# ordering dependency with authconfig that forces me to include
# the manifest in this module.
#
# === Example
# include sssd::homedir
#
# === Authors
# Nicholas Waller <code@nicwaller.com>
#
# === Copyright
# Copyright 2013 Nicholas Waller, unless otherwise noted.
#
class sssd::homedir {
  $is_rhel = $osfamily == 'RedHat'
  $rhel6plus = $is_rhel and versioncmp($operatingsystemrelease,'6.0') >= 0
  $oddjob_available = $rhel6plus

  if $selinux_enforced == 'true' and $oddjob_available == false {
    fail('Oddjob is required for compatibility with selinux')
  }

  if $oddjob_available {
    $reqs = [ Service['oddjobd'] ]
    $check_mod = 'pam_oddjob_mkhomedir.so'
    service { 'messagebus':
      ensure    => running,
      enable    => true,
      # If hasstatus is not set to true, messagebus will restart EVERY time.
      # Does anyone know why?
      hasstatus => true,
    }
  
    package { 'oddjob-mkhomedir':
      ensure => installed,
    }
  
    service { 'oddjobd':
      ensure  => running,
      enable  => true,
      require => [ Package['oddjob-mkhomedir'], Service['messagebus'] ],
    }
  } else {
    $reqs = []
    $check_mod = 'pam_mkhomedir.so'
  }

  # We always need to start the sssd service after calling --mkhomedir.
  exec { 'authconfig-mkhomedir':
    command     => '/usr/sbin/authconfig --enablemkhomedir --update',
    unless      => "/bin/grep ${check_mod} /etc/pam.d/system-auth",
    require     => $reqs,
    notify      => Exec[ 'authconfig-sssd' ], 
  }
}
