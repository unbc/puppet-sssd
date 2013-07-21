# == Class: sssd::homedir
#
# Allow home directories to be created automatically on first logon.
# This is very useful when authenticating against a directory!
# 
# Normally this would be a separate module, but there is a critical
# ordering dependency with authconfig that forces me to include
# the manifest in this module.
#
# === Example
#
# include sssd::homedir
#
class sssd::homedir {
  # messagebus required for centos6 that appears to not start it by default
  package { 'oddjob-mkhomedir':
    ensure  => installed,
    notify  => Exec['authconfig-mkhomedir'],
  } -> service { 'messagebus':
    ensure  => running,
    # I don't normally use hasstatus, but messagebus will restart on EVERY run
    # if it isn't included here. (Anybody know why? Add a comment!)
    hasstatus => true,
    enable  => true,
  } -> service { 'oddjobd':
    ensure  => running,
    enable  => true,
  }

  exec { 'authconfig-mkhomedir':
    command     => '/usr/sbin/authconfig --enablemkhomedir --update',
    refreshonly => true,
    require     => [ Service['messagebus'], Service['oddjobd'] ],
    notify      => Exec[ 'authconfig-sssd' ],
  }

  # According to research by pohl/nwaller, if you run --enablemkhomedir BEFORE turning on
  # SSSD, the setting will stick wtihout breaking anything. If you run it afterwards or
  # simultaneously then it disables SSSD.
}
