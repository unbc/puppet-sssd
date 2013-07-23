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
  if $osfamily == 'RedHat' and versioncmp($operatingsystemrelease,'6.0') >= 0 {
    $reqs = [ Service['messagebus'], Service['oddjobd'] ]
    # In RHEL6, messagebus is not started by default.  
    service { 'messagebus':
      ensure    => running,
      enable    => true,
      # If hasstatus is not set to true, messagebus will restart EVERY time.
      # Does anyone know why?
      hasstatus => true,
    }
  
    package { 'oddjob-mkhomedir':
      ensure => installed,
      notify => Exec['authconfig-mkhomedir'],
    }
  
    service { 'oddjobd':
      ensure  => running,
      enable  => true,
      require => [ Package['oddjob-mkhomedir'], Service['messagebus'] ],
    }
  } elsif $osfamily == 'RedHat' and versioncmp($operatingsystemrelease,'6.0') < 0 {
    # pam_mkhomedir.so is already installed as part of pam.
    # facter is true if selinux is enabled, EVEN in permissive mode
    if $selinux == 'true' {
      fail('pam_mkhomedir.so required when using RHEL < 6, but pam_mkhomedir.so is not compatible with selinux.')
    }
  }

  # We always need to start the sssd service after calling --mkhomedir.
  exec { 'authconfig-mkhomedir':
    command     => '/usr/sbin/authconfig --enablemkhomedir --update',
    refreshonly => true,
    require     => $reqs,
    notify      => Exec[ 'authconfig-sssd' ], 
  }
}
