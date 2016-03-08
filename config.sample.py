#!/usr/bin/env python

debug = True
gads_config = "GADSconfig.xml"
google_ldap_new_prod = {
    "ldap_uri": "ldap://ldap.example.org",
    "ldap_base_dn": "ou=theou,dc=example,dc=org",
    "ldap_bind_dn": "cn=Manager,dc=example,dc=org",
    "ldap_bind_pw": "secretpassword",
    "ldap_people_ou": "ou=someou,ou=theou,dc=example,dc=org",
}
