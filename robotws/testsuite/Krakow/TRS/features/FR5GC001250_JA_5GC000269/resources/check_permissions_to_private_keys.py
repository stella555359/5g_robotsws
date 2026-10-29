"""
author: Damian Muszynski
contact: damian.muszynski.ext@nokia.com
"""
import re


def check_if_private_perms_list(perms):
    perms = perms.split("\n")[1:-1]
    pattern = re.compile(".*[-r][-w][-x][-r]-[-x][-r]-[-x]")
    failures = []
    for i in perms:
        if not pattern.match(i):
            failures.append(i)
    assert failures == [], "Permissions inappropiate in: {}".format(failures)


def check_if_private_perms_assured_by_cryptoagent(perms):
    perms = perms.split("\n")[1:-1]
    pattern = re.compile(".*[-r][-w][-x][-r]-[-x][-r]-[-x]")
    failures = []
    for i in perms:
        if "cryptoagent" in i or "keys.d" in i or "ssh" in i:
            if not pattern.match(i):
                failures.append(i)
    assert failures == [], "Permissions inappropiate in: {}".format(failures)
