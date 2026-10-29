"""

Set of PROPSIM Keywords used for setting IN/OUT ports and reading current values.

:copyright: Nokia Networks
:author: I_MN_5GSC_KRK_AUTO
:contact: I_MN_5GSC_KRK_AUTO@internal.nsn.com
:maintainer: I_MN_5GSC_KRK_AUTO
:contact: I_MN_5GSC_KRK_AUTO@internal.nsn.com
"""

import os
from moler.device import DeviceFactory
from moler.exceptions import CommandFailure
from taf.rfrl.utilities.tl_config import load_moler_configuration_from_tl


@load_moler_configuration_from_tl()
def clear_local_logs_directory(log_dir, all_files_in_dir=True):
    """
    Clear rfp logs on local machine

    :param log_dir:             directory path.
    :param all_files_in_dir:    True/False.
    :return: None
    """
    file_path = os.path.join(log_dir, '*') if all_files_in_dir else log_dir
    local_pc = DeviceFactory.get_device(name='UnixLocal')
    rm = local_pc.get_cmd(cmd_name="rm", cmd_params={'file': file_path, 'options': '-rf'})
    rm()


@load_moler_configuration_from_tl()
def make_local_logs_directory(log_dir):
    """
    Make rfp logs directory on local machine

    :param log_dir:       directory path.
    :return: None
    """
    local_pc = DeviceFactory.get_device(name='UnixLocal')
    mkdir = local_pc.get_cmd(cmd_name="mkdir", cmd_params={'path': log_dir, 'options': '-p'})
    mkdir()


@load_moler_configuration_from_tl()
def change_permissions_on_local_pc(file_path, permissions='644'):
    """
    Keyword for changing permissions on the file

    :param file_path:       path to file.
    :param permissions:     permissions, eg 644.
    """

    local_pc = DeviceFactory.get_device(name='UnixLocal')
    chmod = local_pc.get_cmd(cmd_name="chmod", cmd_params={'filename': file_path, 'permission': permissions})
    chmod()


@load_moler_configuration_from_tl()
def change_file_name_on_local_pc(current_name, new_name):
    """
    Keyword for changing permissions on the file

    :param current_name:    Current file name.
    :param new_name:     New file name.
    """

    local_pc = DeviceFactory.get_device(name='UnixLocal')
    change_name = local_pc.get_cmd(cmd_name="mv", cmd_params={'src': current_name, 'dst': new_name})
    change_name()


@load_moler_configuration_from_tl()
def get_list_of_files_on_local_pc(dir_path, options=None):
    local_pc = DeviceFactory.get_device(name='UnixLocal')

    ls = local_pc.get_cmd(cmd_name="ls", cmd_params={'path': dir_path, 'options': options})
    try:
        ls_result = ls()
        files = ls_result['files']
    except CommandFailure:
        files = []

    return files
