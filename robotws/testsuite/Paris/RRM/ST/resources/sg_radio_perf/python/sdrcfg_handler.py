# -*- coding: utf-8 -*-
"""
:copyright: Nokia Networks
:author: Annie WONG
:contact: annie.wong@nokia.com
"""

import os.path
from taf.transport.ssh import ssh
from robot.libraries.BuiltIn import BuiltIn

rob = BuiltIn()
ssh_mgt = ssh()


def download_sdrcfg(cnx, local_sdrcfg, remote_sdrcfg):
    """
    :param connection: connection to the remote machine hosting sdrcfg file
    :param sdrcfg_path: full path of sdrcfg file on the remote machine
    :param backup_path: full path of the backup file on the local machine
    """
    ssh_mgt.download_file(remote_sdrcfg, local_sdrcfg, connection=cnx)


def upload_sdrcfg(cnx, local_sdrcfg, remote_sdrcfg):
    """
    :param cnx: connection to the remote machine hosting sdrcfg file
    :param local_sdrcfg: full path of the sdrcfg file on the local machine
    :param sdrcfg_path: full path of the sdrcfg file on the remote machine
    """
    remote_path = os.path.dirname(remote_sdrcfg)
    remote_base = os.path.basename(remote_sdrcfg)
    remote_file = remote_path + '/' + remote_base
    ssh_mgt.upload_file(local_sdrcfg, remote_file, connection=cnx)
