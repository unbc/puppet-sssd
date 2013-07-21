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
class sssd::homedir {
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

  # We always need to start the sssd service after calling --mkhomedir.
  exec { 'authconfig-mkhomedir':
    command     => '/usr/sbin/authconfig --enablemkhomedir --update',
    refreshonly => true,
    require     => [ Service['messagebus'], Service['oddjobd'] ],
    notify      => Exec[ 'authconfig-sssd' ], 
  }
}
