#!/usr/bin/env python

import ldap
import os
import sys
import subprocess
import argparse
from config import *

MIN_ACCTS = 2500


def connect(ldap_uri, ldap_bind_dn, ldap_bind_pw):

    ldapc = ldap.initialize(ldap_uri)
    ldapc.protocol_version = ldap.VERSION3
    ldapc.simple_bind(ldap_bind_dn, ldap_bind_pw)

    return ldapc


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
        raise Exception(
            "%d accounts is below minimum of %d" % (count, MIN_ACCTS)
        )


def runGCDS(script_dir, configfile, do_apply):
    sync_cmd = "%s/sync-cmd.sh" % script_dir

    apply_option = ''
    if do_apply:
        apply_option = "--apply"

    print "Executing `%s %s %s`" % (sync_cmd, configfile, apply_option)

    command = [sync_cmd, configfile, apply_option]
    try:
        gcds = subprocess.Popen(command)
    except Exception, e:
        raise Exception("GCDS run returned unsuccessful: %s", e)

    gcds.communicate()

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
        runGCDS(script_dir, gads_config, args.apply)
    except Exception, e:
        print e
        return 3


if __name__ == "__main__":
    ret = main()

    sys.exit(ret)
