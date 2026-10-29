# -*- coding: utf-8 -*-
"""
:author: Jaroslaw Zima
:contact: jaroslaw.zima@nokia.com
:maintainer: I_TADEK_DEVS
:contact: I_TADEK_DEVS@internal.nsn.com
"""
from __future__ import absolute_import
import errno
import os
import shlex
import subprocess
import zipfile
import tarfile

from robot.api import logger

from .connections import Ssh, Telnet

ENB_IP = '192.168.255.129'
ENB_CREDENTIALS = {'user': 'toor4nsn',
                   'password': 'oZPS0POrRieRtu'}
PATH_TO_MODULE_ID = '/proc/device-tree/module-identity/unit-id'
AASHELL_PORT = 15007
AASHELL_PROMPT = 'AaShell> '


def get_fsm_release():
    """ Gets release of used FSM

    :return: release of FSM - FSMF or ASIA
    :rtype: str
    """
    logger.debug('Check FSM release')
    module_identity = Ssh(ENB_IP, authenticator=ENB_CREDENTIALS).execute_command('cat ' + PATH_TO_MODULE_ID)
    logger.debug('FSM release: ' + module_identity)
    return module_identity.strip('\x00')


def get_cell_mapping():
    """ Gets cell mapping from AaShell

    :return: raw output of cell mapping from AaShell
    :rtype: str
    """
    logger.debug('Checking on what node RROMexe is registered')
    rrom_node = _lxcpidof('RROMexe')
    cell_mapping_cmd = 'getCellMapping @RROMexe #' + rrom_node
    logger.debug(
        'Getting cell mapping from AaShell: {}'.format(cell_mapping_cmd)
    )
    with Telnet(ENB_IP, AASHELL_PORT, AASHELL_PROMPT).session() as aashell:
        return aashell.execute_command(cell_mapping_cmd)


def prepare_directory(path):
    """ Prepares directories for given path

    :param str path: path to file
    """
    logger.debug('Creating directories if needed for path: ' + path)
    directories, file_ = os.path.split(path)
    if directories:
        try:
            os.makedirs(directories, 0o755)
        except OSError as exc:
            if exc.errno == errno.EEXIST and os.path.isdir(directories):
                pass
            else:
                raise


def copy_file(source, destination):
    """ Copies file from source to destination

    :param str source:
    :param str destination:
    """
    logger.debug('Copying file from {} to {}'.format(source, destination))
    try:
        subprocess.check_output('sudo cp "{src}" "{dst}"'.format(src=source, dst=destination), shell=True)
    except subprocess.CalledProcessError:
        raise


def extract_file(file_, target_directory):
    """ Extracts package

    :param str file_: path to file that will be extracted
    :param str target_directory: place where package will be extracted
    :return: list of files
    :rtype: list
    """
    prepare_directory(target_directory)
    file_info = __get_file_info(file_).lower()
    if 'gzip' in file_info:
        return extract_tar_file(file_, target_directory, compression='gzip')
    elif 'zip' in file_info:
        return extract_zip_file(file_, target_directory)
    else:
        return extract_tar_file(file_, target_directory)


def extract_tar_file(file_, target_directory, compression='tar'):
    """ Extracts tar package. Supports tar and tar with gzip

    :param str file_: path to file that will be extracted
    :param str target_directory: place where package will be extracted
    :param str compression: compression type, supported values: tar|gzip
    :return: list of files in archive
    :rtype: list
    """
    logger.debug('Extract tar package {} to {}'.format(file_, target_directory))
    modes = {
        'tar': 'r',
        'gzip': 'r:gz'
    }
    tar = tarfile.open(file_, mode=modes[compression])
    files = [member.name + '/' if member.type is tarfile.DIRTYPE else member.name for member in tar.getmembers()]
    tar.extractall(target_directory)
    return files


def extract_zip_file(file_, target_directory):
    """ Extracts zip package

    :param str file_: path to file that will be extracted
    :param str target_directory: place where package will be extracted
    :return: list of files in archive
    :rtype: list
    """
    logger.debug('Unzip {} to {}'.format(file_, target_directory))
    with zipfile.ZipFile(file_) as zf:
        zf.extractall(path=target_directory)
        return zf.namelist()


def __get_file_info(file_):
    """

    :param file_:
    :return:
    :rtype:
    """
    cmd = 'file ' + file_
    output = subprocess.check_output(shlex.split(cmd))
    return output.split(':')[1]


def _lxcpidof(process):
    """Returns first container's name that has *process* running within"""
    fsm = Ssh(ENB_IP, authenticator=ENB_CREDENTIALS)
    for node in fsm.execute_command('lxc-ls --running').splitlines():
        try:
            fsm.execute_command(
                'lxc-attach -n %s -- pidof %s' % (node, process)
            )
        except subprocess.CalledProcessError:
            continue
        return node
    else:
        raise RuntimeError(
            'No process "%s" is running on any lxc container' % process
        )
