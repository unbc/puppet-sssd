# sssd

####Table of Contents
1. [Overview](#overview)
2. [Module Description - What the module does and why it is useful](#module-description)
3. [Quick Start](#quick-start)
4. [Usage - Configuration options and additional functionality](#usage)
   * [Different attribute schema](#different-attribute-schema)
   * [Automatically create home directories](#automatically-create-home-directories)
   * [Authenticate against multiple domains](#authenticate-against-multiple-domains)
5. [Limitations](#limitations)

## Overview
The SSSD module makes it easy to authenticate against Active Directory with sssd.

## Module Description
The SSSD module manages the sssd service on distributions based on RedHat
Enterprise Linux 5 or 6. It is designed to work with Active Directory, but
can easily be customized to work with other LDAP servers. It also helps
automate home directory creation.

## Quick Start
I just want to login with my network username. What's the minimum I need?

    class { 'sssd':
      domains              => [ 'mydomain.local' ],
    }
    sssd::domain { 'mydomain.local':
      ldap_uri             => 'ldap://mydomain.local',
      ldap_search_base     => 'DC=mydomain,DC=local',
      krb5_realm           => 'MYDOMAIN.LOCAL',
      ldap_default_bind_dn => 'CN=SssdService,DC=mydomain,DC=local',
      ldap_default_authtok => 'My ultra-secret password',
      simple_allow_groups  => ['SssdAdmins'],
    }

## Usage

### Different attribute schema
Most LDAP servers use standard attribute names defined in rfc2307. This
includes Windows Server since 2003 R2. If your directory uses a non-standard
schema for posix accounts, you will need to define a custom attribute mapping.

    sssd::domain { 'mydomain.local':
      ...
      ldap_user_object_class   => 'user',
      ldap_user_name           => 'sAMAccountName',
      ldap_user_principal      => 'userPrincipalName',
      ldap_user_gecos          => 'MSSFU2x-gecos',
      ldap_user_shell          => 'MSSFU2x-loginShell',
      ldap_user_uid_number     => 'MSSFU2x-uidNumber',
      ldap_user_gid_number     => 'MSSFU2x-gidNumber',
      ldap_user_home_directory => 'msSFUHomeDirectory',
      ldap_group_gid_number    => 'MSSFU2x-gidNumber',
    }

### Automatically create home directories
Allow home directories to be created automatically on first logon.
This is very useful when authenticating against a directory!

    class { 'sssd::homedir': }

### Authenticate against multiple domains
Declare a second `sssd::domain` resource.
And ALSO modify the domains parameter for the sssd class.

## Limitations
This module has been built on and tested against these Puppet versions:
  * Puppet 3.2.3
  * Puppet 2.6.18

This module has been tested on the following distributions:
  * Scientific Linux 6.3
  * CentOS release 5.6
