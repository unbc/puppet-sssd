# == Define: sssd::domain
#
# This type is used to define one or more domains which SSSD
# will authenticate against.
#
# Currently only supports a default set of providers.
# And only tested with Active Directory.
# id_provider     = ldap
# auth_provider   = krb5
# chpass_provider = krb5
# access_provider = simple
#
# This type has a LOT of parameter options. Most of them are
# passed directly through to the sssd.conf template file.
#
# === Parameters
# TODO: copy notes from my original sssd.conf file
#
# [*param*]
#  (opt1|opt2) - what it does
#
# [*param2*]
#  what it does
#
# === Example
#
# sssd::domain { 'contoso.com':
#   fqdn => 'uni.adr.unbc.ca',
# }
#
define sssd::domain (
  $ldap_domain,
  $ldap_uri,
  $ldap_search_base,
  $krb5_realm,

  $ldap_default_bind_dn,
  $ldap_default_authtok,

  $simple_allow_groups,

  $ldap_user_object_class = 'user',
  $ldap_user_name = 'sAMAccountName',
  $ldap_user_principal = 'userPrincipalName',
  $ldap_user_uid_number = 'MSSFU2x-uidNumber',
  $ldap_user_gid_number = 'MSSFU2x-gidNumber',
  $ldap_user_gecos = 'MSSFU2x-gecos',
  $ldap_user_shell = 'MSSFU2x-loginShell',
  $ldap_user_home_directory = 'msSFUHomeDirectory',

  $ldap_group_object_class = 'group',
  $ldap_group_name = 'cn',
  $ldap_group_member = 'member',
  $ldap_group_gid_number = 'MSSFU2x-gidNumber',

  $ldap_id_use_start_tls = true,
  $ldap_tls_reqcert = 'demand',
  $ldap_tls_cacert = undef,
  $ldap_default_authtok_type = 'password',
  $ldap_schema = 'rfc2307bis',
  $enumerate = false,
  $ldap_force_upper_case_realm = true,
  $ldap_referrals = false,
  $cache_credentials = false,
  $min_id = undef,
  $entry_cache_timeout = 60,
  $krb5_canonicalize = false,
) {
  validate_array($simple_allow_groups)

  include sssd::params
  if $min_id == undef {
    $real_min_id = $sssd::params::dist_uid_min
  } else {
    $real_min_id = $min_id
  }

  concat::fragment { "sssd_domain_${ldap_domain}":
    target  => 'sssd_conf',
    content => template('sssd/domain.conf.erb'),
    order   => 20,
  }
}
