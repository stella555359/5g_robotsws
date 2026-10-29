# -*- encoding: utf-8 -*-
"""
:copyright: Nokia
:author: xxxx
:contact:
"""

from ssh import *
from ute_fsmaccess import ute_fsmaccess
fsmaccess = ute_fsmaccess()


def get_active_bts_sw_version():
    fsmaccess.setup_enb_fsm_access(alias='enb')
    sw_version = fsmaccess.get_enb_sw_version(alias='enb')
    fsmaccess.teardown_enb_fsm_access(alias='enb')
    # sshd = ssh_connect('192.168.255.1', 'toor4nsn', 'oZPS0POrRieRtu')
    # sftpd = sftp_open(sshd)
    # try:
    #     sw_version = ssh_file(sftpd,'/ffs/run/','TargetBD')
    # except Exception, e:
    #     print 'ERROR: ssh_file - %s' % e
    # sftp_close(sftpd)
    # ssh_close(sshd)
    # sw_version = sw_version.split("TargetBD_")[1].split(".xml")[0]
    return sw_version


def get_bbu_type():
    command = 'cat /proc/device-tree/module-identity/unit-id'
    fsmaccess.setup_enb_fsm_access(alias='enb')
    bbu_type = fsmaccess.execute_command_on_enb(cmd=command, alias='enb').strip('\x00')
    fsmaccess.teardown_enb_fsm_access(alias='enb')
    # save_log_dir = '/tmp'
    # bbu_file_name = 'unit-id'
    # bbu_file_path = '/proc/device-tree/module-identity/'
    # save_log_path = os.path.join(save_log_dir, bbu_file_name)
    # sshd = ssh_connect('192.168.255.1', 'toor4nsn', 'oZPS0POrRieRtu')
    # sftpd = sftp_open(sshd)
    # try:
    #     sftp_get(sftpd,os.path.join(bbu_file_path,bbu_file_name),save_log_path)
    # except Exception, e:
    #     print 'ERROR: sftp_get - %s' % e
    # sftp_close(sftpd)
    # ssh_close(sshd)
    # with open(save_log_path, 'r') as f_obj:
    #     bbu_type = f_obj.read().strip('\x00')
    return bbu_type
