#!/usr/bin/env python

import ldap, os, sys, subprocess
import argparse
from config import *

MIN_ACCTS = 2500

# connect to ldap
def connect(ldap_uri, ldap_bind_dn, ldap_bind_pw):

    l = ldap.initialize(ldap_uri)
    l.protocol_version = ldap.VERSION3
    l.simple_bind(ldap_bind_dn, ldap_bind_pw)

    return l

def checkLdap(ldapdb, basedn):
    count = 0

    ldap_result_id = ldapdb.search(
        basedn,
        ldap.SCOPE_SUBTREE,
        "uid=*",
        None)

    while 1:
        result_type, result_data = ldapdb.result(ldap_result_id, 0)
        if (result_data == []):
            break
        else:
            if result_type == ldap.RES_SEARCH_ENTRY:
                count = count + 1

    if count < MIN_ACCTS:
        raise Exception("%d accounts is below minimum of %d" % (count, MIN_ACCTS))

def runGads(script_dir, configfile, do_apply):
    sync_cmd = "%s/sync-cmd.sh" % script_dir

    apply_option = ''
    if do_apply:
        apply_option = "--apply"

    print "Executing `%s %s %s`" % (sync_cmd, configfile, apply_option)

    command = [ sync_cmd, configfile, apply_option ]
    try:
        gads = subprocess.Popen(command)
    except:
        raise Exception("GADS run returned unsuccessful", stdout=subprocess.PIPE)

    gads.communicate()

    return 0

def main():
    script_path = os.path.abspath(__file__)
    script_dir = os.path.dirname(script_path)

    parser = argparse.ArgumentParser()
    parser.add_argument('--apply', action='store_true')
    args = parser.parse_args()

    # Bind to LDAP server
    try:
        ldapdb = connect(
            google_ldap["ldap_uri"],
            google_ldap["ldap_bind_dn"],
            google_ldap["ldap_bind_pw"]
        )
    except ldap.LDAPError, e:
        print e
        return 1

    try:
        checkLdap(ldapdb, google_ldap["ldap_people_ou"])
    except Exception, e:
        print e
        return 2

    try:
        runGads(script_dir, gads_config, args.apply)
    except Exception, e:
        print e
        return 3

if __name__ == "__main__":
    ret = main()

    sys.exit(ret)
