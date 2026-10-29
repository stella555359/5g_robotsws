# coding = utf-8


"""
:copyright: Nokia Networks
:author: Shi Ming
:contact: ming.shi@nokia-sbell.com
:maintainer: Ming Shi
:contact: Ming Shi
"""

import os
import pexpect
import sys
import time
import json
from taf.transport.ssh import ssh
from robot.libraries.BuiltIn import BuiltIn
from robot.libraries.OperatingSystem import OperatingSystem

builtin_obj = BuiltIn()
os_obj = OperatingSystem()
log_path = '/opt/workspace/CIT/Master/Case_Logs'


def get_control_para(file_path, control_para_name):
    """
        get value of control parameter
        :param file_path: the path of excel   e.g. /opt/workspace/SCF/SBTS22R2/TA_para_control.txt
        :param control_para_name: : need to get value of control parameter
                e.g. traffic_direction, HO_times
        """
    with open(file_path, 'r') as file:
        result = file.read().split(',')
    para_name = []
    para_value = []
    for i in result:
        para_name.append(i.split(':')[0])
        para_value.append(i.split(':')[1])
    para_dict = dict(zip(para_name, para_value))
    print(para_dict)
    value = para_dict.get(control_para_name)
    return value


def start_hanging_resource_file(ip, username, password, tl_cienv_name, file_name):
    """
    run hanging_check_4G_5G.py and check result if there is hanging resource or not
    para ip: ute ip
    para username: ute username
    para password: ute password
    para tl_cienv_name: tl cienv name, e.g. 7_5_UTE5G402T335
    para file_name: which file need to run e.g. hanging_check_4G_5G.py
    """
    try:
        f = open('result.txt', 'wb')
    except Exception as e:
        print(e)
    else:
        child = pexpect.spawn('ssh {}@{}'.format(username, ip), logfile=f)
        child.expect('password:')
        child.sendline('{}'.format(password))
        child.expect('ute@')
        child.sendline("source CIENV/{}/bin/activate".format(tl_cienv_name))
        child.expect('({})'.format(tl_cienv_name))
        child.sendline('python {}'.format(file_name))
        time.sleep(10)
        child.expect('connection successful')
        child.expect('Checked processes:')
        child.expect('No hanging resources')
    finally:
        f.close()


def get_ci_env_name(ute_ip, username, password):
    """
        get ci env name from ute
        para ute_ip: ute ip
        para username: ute username
        para password: ute password
        return: ci_env_name
        """
    try:
        sshconn = ssh.ssh()
        sshconn.connect_to(hostname=ute_ip, username=username, password=password, alias='ci_ute', timeout=60)
        time.sleep(2)
    except Exception as e:
        print('error: %s' % e)
    else:
        sshconn.send_command(command="ls -l /home/ute/CIENV/ | grep 7_5_ |awk '{print $9}'", connection='ci_ute')
        time.sleep(2)
        result = sshconn.read_output(connection='ci_ute')
        for i in result.split():
            if i.startswith('7_5_'):
                ci_env_name = i
    finally:
        try:
            sshconn.disconnect(connection='ci_ute')
        except UnboundLocalError:
            print('close failed')
    return ci_env_name


def replace_value_from_list(list_name, replace_value='NA'):
    for index, item in enumerate(list_name):
        if item is None:
            list_name[index] = replace_value
    return list_name


def get_partial_ues_sn(file_path):
    """
    get sn of partial ues from file partial_ue_sn.txt
    :param file_path: e.g./opt/workspace/SCF/partial_ue_sn.txt
    :return: sn of partial ues
    """
    with open(file_path, 'r') as f:
        result = f.read()
    return result.strip()


def check_resources_leakage_aic():
    """
    refer to https://confluence.ext.net.nokia.com/display/5GHAN/CNI-68640
    """
    #
    # # prepare log_dir
    log_dir = builtin_obj.get_variable_value("${TS_LOG_PATH_BASE}")
    log_dir = os.path.join(log_dir, "hanging_resource_logs")
    if not os.path.exists(log_dir):
        os.mkdir(log_dir)
    #
    # # run hanging_check_4G_5G.py and copy log
    # self._execute_cmd_on_pc("pwd")
    # self._execute_cmd_on_pc("rm -rf hanging_resource_check_*")
    cwd = os.path.dirname(__file__)

    # get vcu/vdu info
    cu_num = len(builtin_obj.get_variable_value("${tl.gnbs}"))
    cu1_du_num = len(builtin_obj.get_variable_value("${tl.gnbs[0].dus}"))
    cu_ip = builtin_obj.get_variable_value("${tl.gnbs[0].cu.oam_ssh_connection_details.addr}")
    cu_usr = builtin_obj.get_variable_value("${tl.gnbs[0].cu.oam_ssh_connection_details.username}")
    cu_pwd = builtin_obj.get_variable_value("${tl.gnbs[0].cu.oam_ssh_connection_details.password}")
    cu_ns = builtin_obj.get_variable_value("${tl.gnbs[0].cloud_deployment.cloud_hosting.namespace}")
    cu_info = json.dumps(
        {"ip": "%s" % cu_ip, "user": "%s" % cu_usr, "pwd": "%s" % cu_pwd, "ns": "%s" % cu_ns})
    cu1_du_ip = builtin_obj.get_variable_value("${tl.gnbs[0].dus[0].cloud_deployment.cloud_hosting.master_node"
                                               ".ssh_connection_details.addr}")
    cu1_du_usr = builtin_obj.get_variable_value("${tl.gnbs[0].dus[0].cloud_deployment.cloud_hosting.master_node"
                                                ".ssh_connection_details.username}")
    cu1_du_pwd = builtin_obj.get_variable_value("${tl.gnbs[0].dus[0].cloud_deployment.cloud_hosting.master_node"
                                                ".ssh_connection_details.password}")
    cu1_du_ns = builtin_obj.get_variable_value("${tl.gnbs[0].dus[0].cloud_deployment.cloud_hosting.namespace}")
    cu1_du_info = json.dumps(
        {"ip": "%s" % cu1_du_ip, "user": "%s" % cu1_du_usr, "pwd": "%s" % cu1_du_pwd, "ns": "%s" % cu1_du_ns})
    cmd = "python {}/hanging_check_aic.py '{}' '{}'".format(cwd, cu_info, cu1_du_info)
    if cu1_du_num >= 2:
        cu1_du2_ip = builtin_obj.get_variable_value("${tl.gnbs[0].dus[1].cloud_deployment.cloud_hosting.master_node"
                                                    ".ssh_connection_details.addr}")
        cu1_du2_usr = builtin_obj.get_variable_value("${tl.gnbs[0].dus[1].cloud_deployment.cloud_hosting.master_node"
                                                     ".ssh_connection_details"
                                                     ".username}")
        cu1_du2_pwd = builtin_obj.get_variable_value("${tl.gnbs[0].dus[1].cloud_deployment.cloud_hosting.master_node"
                                                     ".ssh_connection_details.password}")
        cu1_du2_ns = builtin_obj.get_variable_value("${tl.gnbs[0].dus[1].cloud_deployment.cloud_hosting.namespace}")
        cu1_du2_info = json.dumps(
            {"ip": "%s" % cu1_du2_ip, "user": "%s" % cu1_du2_usr, "pwd": "%s" % cu1_du2_pwd, "ns": "%s" % cu1_du2_ns})
        cmd = "python {}/hanging_check_aic.py '{}' '{}' '{}'".format(cwd, cu_info, cu1_du_info, cu1_du2_info)
    output = os_obj.run(cmd)
    print(output)
    os_obj.run('mv hanging_resource_check_* {}'.format(log_dir))
    if 'There were hanging resources' in output:
        raise Exception("Resource Not Released")
    if cu_num >= 2:
        cu2_du_num = len(builtin_obj.get_variable_value("${tl.gnbs[1].dus}"))
        cu2_ip = builtin_obj.get_variable_value("${tl.gnbs[1].cu.oam_ssh_connection_details.addr}")
        cu2_usr = builtin_obj.get_variable_value("${tl.gnbs[1].cu.oam_ssh_connection_details.username}")
        cu2_pwd = builtin_obj.get_variable_value("${tl.gnbs[1].cu.oam_ssh_connection_details.password}")
        cu2_ns = builtin_obj.get_variable_value("${tl.gnbs[1].cloud_deployment.cloud_hosting.namespace}")
        cu2_info = json.dumps(
            {"ip": "%s" % cu2_ip, "user": "%s" % cu2_usr, "pwd": "%s" % cu2_pwd, "ns": "%s" % cu2_ns})
        cu2_du_ip = builtin_obj.get_variable_value("${tl.gnbs[1].dus[0].cloud_deployment.cloud_hosting.master_node"
                                                   ".ssh_connection_details.addr}")
        cu2_du_usr = builtin_obj.get_variable_value("${tl.gnbs[1].dus[0].cloud_deployment.cloud_hosting.master_node"
                                                    ".ssh_connection_details.username}")
        cu2_du_pwd = builtin_obj.get_variable_value("${tl.gnbs[1].dus[0].cloud_deployment.cloud_hosting.master_node"
                                                    ".ssh_connection_details.password}")
        cu2_du_ns = builtin_obj.get_variable_value("${tl.gnbs[1].dus[0].cloud_deployment.cloud_hosting.namespace}")
        cu2_du_info = json.dumps(
            {"ip": "%s" % cu2_du_ip, "user": "%s" % cu2_du_usr, "pwd": "%s" % cu2_du_pwd, "ns": "%s" % cu2_du_ns})
        cmd = "python {}/hanging_check_aic.py '{}' '{}'".format(cwd, cu2_info, cu2_du_info)
        if cu2_du_num >= 2:
            cu2_du2_ip = builtin_obj.get_variable_value("${tl.gnbs[1].dus[1].cloud_deployment.cloud_hosting"
                                                        ".master_node.ssh_connection_details.addr}")
            cu2_du2_usr = builtin_obj.get_variable_value("${tl.gnbs[1].dus[1].cloud_deployment.cloud_hosting"
                                                         ".master_node.ssh_connection_details.username}")
            cu2_du2_pwd = builtin_obj.get_variable_value("${tl.gnbs[1].dus[1].cloud_deployment.cloud_hosting"
                                                         ".master_node.ssh_connection_details.password}")
            cu2_du2_ns = builtin_obj.get_variable_value("${tl.gnbs[1].dus[1].cloud_deployment"
                                                        ".cloud_hosting.namespace}")
            cu2_du2_info = json.dumps(
                {
                    "ip": "%s" % cu2_du2_ip,
                    "user": "%s" % cu2_du2_usr,
                    "pwd": "%s" % cu2_du2_pwd,
                    "ns": "%s" % cu2_du2_ns
                })
            cmd = "python {}/hanging_check_aic.py '{}' '{}' '{}'".format(cwd, cu2_info, cu2_du_info, cu2_du2_info)
        output1 = os_obj.run(cmd)
        print(output1)
        os_obj.run('mv hanging_resource_check_* {}'.format(log_dir))
        if 'There were hanging resources' in output1:
            raise Exception("Resource Not Released")
