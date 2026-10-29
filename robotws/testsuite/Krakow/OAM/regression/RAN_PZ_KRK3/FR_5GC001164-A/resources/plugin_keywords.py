# -*- coding: utf-8 -*-
"""
:copyright: Nokia Networks
:author: Krzysztof Domino
:contact: krzysztof.domino@nokia.com
"""

from taf.transport.ssh import ssh
from taf.rfrl.utilities.robot.general import get_builtin_value

tl = get_builtin_value(param_name="tl")
hostname = tl.gnbs[0].dus[0].airscale.common_units[0].lmp_connection.addr
username = tl.gnbs[0].dus[0].airscale.common_units[0].lmp_connection.username
password = tl.gnbs[0].dus[0].airscale.common_units[0].lmp_connection.password
ssh = ssh()


def copy_bpf_AEQE_22R2():
    ssh_command_on_asix('FILE=$(ls /rom/swpool/OAM/BpfP*.tgz); cp $FILE $FILE.copy;')


def copy_bpf_AEQE_22R3():
    ssh_command_on_asix('FILE=$(ls /rom/swpool/OAM/sm6-snowfish/BpfP*.tgz); cp $FILE $FILE.copy;')


def restore_bpf_AEQE_22R2():
    ssh.connect_to(hostname, username, password)
    file_path = ssh.execute("ls /rom/swpool/OAM/BpfP*.tgz")
    file_copy_path = ssh.execute("ls /rom/swpool/OAM/BpfP*.tgz.copy")
    restore_bpf(file_path, file_copy_path)
    ssh.disconnect()


def restore_bpf_AEQE_22R3():
    ssh.connect_to(hostname, username, password)
    file_path = ssh.execute("ls /rom/swpool/OAM/sm6-snowfish/BpfP*.tgz")
    file_copy_path = ssh.execute("ls /rom/swpool/OAM/sm6-snowfish/BpfP*.tgz.copy")
    restore_bpf(file_path, file_copy_path)
    ssh.disconnect()


def restore_bpf(file_path, file_copy_path):
    ssh.execute(
        'cp {} {};crasign $FILE;rm -rf {};rm -f /rom/HashContainer*;\
        rm -rf /ffs/run/config/rfmplugin;rm -f /rom/TargetBD_RFM*;'.format(file_copy_path, file_path, file_copy_path))


def modify_bpf_AEQE_22R2():
    ssh.connect_to(hostname, username, password)
    file_path = ssh.execute("ls /rom/swpool/OAM/BpfP*.tgz").replace("\r\n", "")
    archive_path = ssh.execute("tar -tf {} | grep AE_QE.gz".format(file_path)).rstrip()
    modify_bpf(file_path, archive_path)
    ssh.disconnect()


def modify_bpf_AEQE_22R3():
    ssh.connect_to(hostname, username, password)
    file_path = ssh.execute("ls /rom/swpool/OAM/sm6-snowfish/BpfP*.tgz").replace("\r\n", "")
    archive_path = ssh.execute("tar -tf {} | grep AE_QE.gz".format(file_path)).rstrip()
    modify_bpf(file_path, archive_path)
    ssh.disconnect()


def modify_bpf(file_path, archive_path):
    ssh.execute("tar xzvf  {}; rm -f {}; tar czf new_archive.tgz tmp;cp new_archive.tgz {}; crasign {};\
    rm -f /rom/HashContainer*;".format(file_path, archive_path, file_path, file_path))


def remove_rf_plugin_folder_from_bts():
    ssh_command_on_asix('ls /ffs/run/config/rfmplugin; rm -rf /ffs/run/config/rfmplugin')


def remove_targetbd_rfm_from_bts():
    ssh_command_on_asix('rm /rom/TargetBD_RFM*')


def list_targetbd_rfm_from_bts():
    ssh_output = ssh_command_on_asix('ls /rom/TargetBD_RFM* 2>/dev/null | wc -l')
    ssh_output = ssh_output.replace("\r\n", "")
    return ssh_output


def ssh_command_on_asix(cmd):
    ssh.connect_to(hostname, username, password)
    ssh_output = ssh.execute(cmd)
    ssh.disconnect()
    return ssh_output
