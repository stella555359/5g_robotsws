from taf.transport.ssh import interface
from robot.api import logger
import re
import Keywords

ssh = interface.ssh()

paths_on_classical = [
    '/usr/bin/busybox',
    '/usr/bin/chage',
    '/usr/bin/chfn',
    '/usr/bin/chsh',
    '/usr/bin/expiry',
    '/usr/bin/fusermount',
    '/usr/bin/gpasswd',
    '/usr/bin/mount',
    '/usr/bin/newgidmap',
    '/usr/bin/newgrp',
    '/usr/bin/newuidmap',
    '/usr/bin/passwd',
    '/usr/bin/rcp',
    '/usr/bin/rlogin',
    '/usr/bin/rsh',
    '/usr/bin/su',
    '/usr/bin/traceroute',
    '/usr/bin/umount',
    '/usr/sbin/netserver',
    '/usr/lib/lxc/lxc-user-nic',
    '/usr/lib/ssh/ssh-keysign',
    '/usr/sbin/mount.nfs',
    '/usr/libexec/dbus-daemon-launch-helper',
    '/usr/sbin/unix_chkpwd',
    '/usr/bin/chfn.shadow',
    '/usr/bin/chsh.shadow',
    '/usr/bin/mount.util-linux',
    '/usr/bin/newgrp.shadow',
    '/usr/bin/passwd.shadow',
    '/usr/bin/ping.iputils',
    '/usr/bin/su.util-linux',
    '/usr/bin/netperf',
    '/usr/bin/umount.util-linux',
    '/usr/libexec/lxc/lxc-user-nic',
    '/usr/libexec/ssh/ssh-keysign']

files_with_permissions = {'passwd': '644', 'group': '644',
                          'shadow': '600', 'fstab': '644', 'inittab': '644'}


def check_suid_sgid(connection):
    output = ssh.execute(
        command='ls -la $(find / -xdev \\( -perm -4000 -o -perm -2000 \\) -type f -print)',
        connection=connection).split('\n')[
        :-1]
    logger.console(output)
    file_to_check = [x.split()[-1] for x in output]
    if output:
        assert all(item in paths_on_classical for item in file_to_check), 'Wrong permissions for paths: {}'.\
            format([x for x in file_to_check if x not in paths_on_classical])


def check_user_owner(output, file):
    assert output[2] == 'root', 'root is not owner {} file'.format(file)


def check_group_owner(output, file):
    assert output[3] == 'root', 'group for {} file is not root'.format(file)


def check_file_permission(file, connection):
    if file in ['hosts', 'issue', 'services']:
        output = ssh.execute(command='ls -la /etc/{}'.format(file),
                             connection=connection).split()[0][-2]
        assert output == '-', 'File /etc/{} has set write permision for other'.format(
            file)
    else:
        output = ssh.execute(
            command='stat -c "%a %n" /etc/{}'.format(file),
            connection=connection).split()[0]
        assert files_with_permissions['{}'.format(file)] == output, 'file {} has wrong permission: {}, should be: {}'.\
            format(file, output, files_with_permissions['{}'.format(file)])


def check_file_permission_rules(file, connection):
    exist = check_if_file_exist_in_enb(file, connection)
    if exist:
        logger.console(file)
        output = ssh.execute(
            command='ls -la /etc/{}'.format(file),
            connection=connection).split()
        check_user_owner(output, file)
        check_file_permission(file, connection)


def check_if_file_exist_in_enb(file, connection):
    output = ssh.execute(command='ls /etc/{}'.format(file),
                         connection=connection)
    return False if 'No such file or directory' in output else True


def check_unauthorized_for_files(output):
    output = output.split('\n')[:-1]
    file_to_check = [x.split()[-1] for x in output]
    for item in file_to_check:
        assert re.findall("/etc/ftm_strongswan_patch",
                          item), "Find unauthorized files {}".format(item)


def check_for_unauthorized_file_on_gnb(command, connection):
    output = ssh.execute(command='{}'.format(command),
                         connection=connection)
    check_unauthorized_for_files(output)
