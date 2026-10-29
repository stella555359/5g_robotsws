# -*- coding: utf-8 -*-
"""
:copyright: Nokia Networks
:author: Yves Gorjux (I&V)
:contact: yves.gorjux@nokia.com
"""

import os.path
from taf.transport.ssh import ssh
from robot.libraries.BuiltIn import BuiltIn

rob = BuiltIn()
ssh_mgt = ssh()

_flag_template = "{flag}={value}"


def backup_swconfig(connection, swconfig_path, backup_path):
    """
    Download the swconfig.txt file to local machine for backup
    :param connection: connection to the remote machine hosting swconfig.txt file
    :param swconfig_path: full path of the swconfig.txt file on the remote machine
    :param backup_path: full path of the backup file on the local machine
    """
    # Download the current swconfig.txt file on local machine
    ssh_mgt.download_file(swconfig_path, backup_path, connection=connection)


def set_swconfig(cnx, local_conf_file, swconfig_path):
    """
    Upload the swconfig.txt file to the remote machine and check if the swconfig.txt is the same as the current one.
    If it is the same, there is no need for reset site.
    :param cnx: connection to the remote machine hosting swconfig.txt file
    :param local_conf_file: full path of the swconfig file on the local machine
    :param swconfig_path: full path of the swconfig.txt file on the remote machine
    :return: 0 if there is no need to reset site. 1 otherwise.
    """
    # Upload the swconfig file to the ASIK
    remote_path = os.path.dirname(swconfig_path)
    remote_conf_file = remote_path + '/new_swconfig.txt'
    ssh_mgt.upload_file(local_conf_file, remote_conf_file, connection=cnx)
    # Check if the new uploaded file is different from the existing one
    cmd = 'diff -sq {} {}'.format(swconfig_path, remote_conf_file)
    result = ssh_mgt.execute(cmd, connection=cnx)
    rob.log('Check if the target conf is the same as the current one: {}'.format(result), 'DEBUG')
    differ = 0  # No reset site is required
    if 'differ' in result:
        # The target conf is not the current one
        # Copy the target conf
        cmd = 'cp {} {}'.format(remote_conf_file, swconfig_path)
        result = ssh_mgt.execute(cmd, connection=cnx)
        rob.log('Replace the current conf by the target one: {}'.format(result), 'DEBUG')
        differ = 1  # A reset site is required
    return differ


def set_flag(connection, swconfig_path, flag, value):
    """
    Sets flag in file. Modifies flag if it already exists, adds flag if not.
    adds "flag=value" in swconfig file. Crasigns file after flag setting.
    :param connection: connection to the remote machine hosting swconfig.txt file
    :param swconfig_path: full path of the swconfig.txt file on the remote machine
    :param flag: flag to be set e.g "0x123"
    :param value: value
    """
    flag_exists = _check_if_flag_exists(connection, swconfig_path, flag)
    if flag_exists:
        _modify_flag(connection, swconfig_path, flag, value)
    else:
        _add_flag(connection, swconfig_path, flag, value)
    _crasign_file(connection, swconfig_path)


def _check_if_flag_exists(_connection, _swconfig_path, flag):
    output = _connection.execute('grep {} {}'.format(flag, _swconfig_path))
    rob.log('Result of the grep: {}'.format(output), 'DEBUG')
    if not output:
        flag_exists = False
    else:
        flag_exists = False
        for line in output.split('\n'):
            if flag in line and not line.startswith('#'):
                flag_exists = True
    rob.log('Flag exists in current swconfig.txt: {}'.format(flag_exists), 'INFO')
    return flag_exists


def _add_flag(_connection, _swconfig_path, flag, value):
    flag_value = _flag_template.format(flag=flag, value=value)
    rob.log('Flag to add: '.format(flag_value), 'INFO')
    _connection.execute("echo {flag} >> {path}".format(flag=flag_value, path=_swconfig_path))


def _modify_flag(_connection, _swconfig_path, flag, value):
    flag_value = _flag_template.format(flag=flag, value=value)
    rob.log('Flag to modify: '.format(flag_value), 'INFO')
    cmd = 'sed -i "s/^{flag}=.*/{flag_value}/" {path}'.format(flag=flag, flag_value=flag_value,
                                                              path=_swconfig_path)
    _connection.execute(cmd)


def _crasign_file(_connection, _swconfig_path):
    _connection.execute('crasign {}'.format(_swconfig_path))
