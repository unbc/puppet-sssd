# sssd
This is a [Puppet](https://puppetlabs.com/) module that installs, configures,
and manages the [SSSD](https://fedorahosted.org/sssd/) service.

## Module Description
This SSSD module is compatible with distributions based on RedHat Enterprise
Linux, including CentOS and Scientific Linux. It works best when connecting
to Active Directory LDAP domains.

This module has been built on and tested against Puppet 3.2.

## Quick Start
I just want to login with my network username. What's the minimum I need?

```
class { 'sssd':
  domains              => [ 'mydomain.local' ],
}
sssd::domain { 'mydomain.local':
  ldap_domain          => 'mydomain.local',
  ldap_uri             => 'ldaps://mydomain.local',
  ldap_search_base     => 'DC=mydomain,DC=local',
  krb5_realm           => 'MYDOMAIN.LOCAL',
  ldap_default_bind_dn => 'CN=SssdService,DC=mydomain,DC=local',
  ldap_default_authtok => 'My ultra-secret password',
  simple_allow_groups  => 'SssdAdmins',
}
```

## Usage

### Different attribute schema
This module tries to use defaults that work with the most recent version of
Active Directory. If you're using something else, you might need to specify
your own custom attribute mapping. This is defined per-domain.

```
ldap_user_uid_number => 'MSSFU2x-uidNumber',
ldap_user_gid_number => 'MSSFU2x-gidNumber',
```

### Managing sudo access

```
class { 'sssd::sudo':
  sudo_groups => 'SssdAdmins',
}
```

### Automatically create home directories

```
class { 'sssd::homedir': }
```

### Authenticate against multiple domains
Just add a second `sssd::domain` resource.
