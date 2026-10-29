from taf.transport.ssh import interface
ssh = interface.ssh()

ls_command = 'ls -la /etc/'


def check_permission_to_etc_subset(subset, connection, perm=None, grep_perm=None):
    result_perm = ssh.execute(
        command=ls_command+subset+("" if not grep_perm else "".join([" | grep ", grep_perm])),
        connection=connection)

    failures = []
    if perm:
        if perm not in result_perm:
            failures.append("Permission '{}' does not fit result '{}'".format(perm, result_perm))
    else:
        if not "w" != result_perm:
            failures.append("Permission grepped '{}' != '{}'".format(grep_perm, result_perm))

    assert failures == [], failures
