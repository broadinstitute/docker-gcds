#!/usr/bin/env python

import ldap, os, sys
from config import *

GADS_CONFIG_DIR = "/gads/configs"
GADS_DIR = "/gads"
MIN_ACCTS = 1900

# All the GADS commands that can be executed by this script
GADScmds = {
    "Test": {
        "cmd": GADS_DIR + "/" + "sync-cmd",
        "config": GADS_CONFIG_DIR + "/" + "OpenLDAP2GoogleAppsTest.xml"
    },
    "Prod": {
        "cmd": GADS_DIR + "/" + "sync-cmd",
        "config": GADS_CONFIG_DIR + "/" + "OpenLDAP2GoogleAppsProd.xml"
    }
}

# // If any parameters were passed to this script, assume they mean which GADS to run
# $runSelector = NULL;
# if (count($_SERVER["argv"]) > 1) {
#     $args = $_SERVER["argv"];
#     for ($i = 1; $i < count($args); $i++) {
#         $runSelector[] = $args[$i];
#     }
# }

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

def runGads():
    return 0
    # Run through each GADS command
    # foreach ($GADScmds as $name => $cmd) {
    #     $retVal = 0;
    #     $output = NULL;

    #     if ($runSelector) {
    #         if (!in_array($name, $runSelector)) {
    #             // Skip this GADS if we are running this for specific jobs and
    #             // the current name is not one of the selected jobs
    #             continue;
    #         }
    #     }

    #     if (!is_executable($cmd['cmd'])) {
    #         echo "Cannot process GADS '$name':\n";
    #         echo "\tCommand not found: " . $cmd['cmd'] . "\n";
    #         continue;
    #     }

    #     if (!is_readable($cmd['config'])) {
    #         echo "Cannot process GADS '$name':\n";
    #         echo "\tCannot find config file: " . $cmd['config'] . "\n";
    #         continue;
    #     }

    #     $exec_cmd = $cmd['cmd'] . ' -c ' . $cmd['config'] . ' --apply';
    #     exec($exec_cmd, $output, $retVal);
    # /*
    #     // GADS returns '255' for a return value for some reason, so I can't test for '0'
    #     if ($retVal != 0) {
    #         echo "GADS sync for '$name' did not complete successfully ($retVal)!\n";
    #     }
    # */
    #     sleep(5);
    # }


def main():
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
        print "hello"
        # runGads()
    except Exception, e:
        print e
        return 3

if __name__ == "__main__":
    ret = main()

    sys.exit(ret)
