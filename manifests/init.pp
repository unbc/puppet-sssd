# == Class: sssd
#
# Manage SSSD authentication on RHEL-based systems.
#
# === Parameters
# 
# [*domains*]
#   For each sssd::domain type you use, you ALSO need to specify it here.
#   This determines the order in which domains are used for lookups.
# 
# === Example
# 
# class { 'sssd':
#   domains => [ 'uni.adr.unbc.ca' ],
# }
#
class sssd (
  $domains,
  $filter_groups   = 'root',
  $filter_users    = 'root'
) {
	# FIXME: there's a bug in this manifest right now. On the first run, sssd.conf
	# is APPENDED instead of being REPLACED. This causes problems! - nwaller
	# Subsequent runs appear to fix the issue, but why doesn't it work right away?

	# It might be necessary to introduce the anchor pattern here... ?
	# https://github.com/puppetlabs/puppetlabs-stdlib/blob/master/lib/puppet/type/anchor.rb

	validate_array($domains)

	concat::fragment{ 'sssd_conf_header':
		target  => 'sssd_conf',
		content => template('sssd/header_sssd.conf.erb'),
		order   => 10,
	}

	package { 'sssd':
		ensure  => installed,
	} -> concat { 'sssd_conf':
		path	=> '/etc/sssd/sssd.conf',
		mode	=> 600,
	} ~> exec { 'authconfig-sssd':
		command	=> '/usr/sbin/authconfig --enablesssd --enablesssdauth --enablelocauthorize --update',
		refreshonly	=> true,
	} ~> service { 'sssd':
		ensure	=> running,
		enable	=> true,
	}
	# Originally there was a notify => Exec[] directive here, but I
	# had a weird problem with pg-uni-cups-01 where if SSSD was stopped,
	# puppet would fail to bring it back online. Only by moving the notify
	# out of the "service" stanza would it work correctly. - nwaller May 2013
}
