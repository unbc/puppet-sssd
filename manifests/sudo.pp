# == Class: sssd::sudo
#
# This is an optional helper class for defining system groups that
# are allowed to use sudo.
#
# If you have more specific needs, you might want to use a real sudo
# module instead.
#
# === Parameters
# 
# [*sudo_groups*]
#   An array of LDAP groups that contain users who are permitted
#   unlimited use of the sudo command. The LDAP groups MUST have
#   a numeric group ID (eg. gidNumber) defined to be usable.
#
# === Example
# 
# class { 'sssd::sudo':
#   sudo_groups => 'Administrators',
# }
# 
class sssd::sudo (
  $sudo_groups
) {
  validate_array($sudo_groups)

  file { '/etc/sudoers.d/sssd':
    ensure  => file,
    mode  => 440,
    content  => template('sssd/sudoers.erb'),
  }
}
