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
import taf.transport.ssh as ssh
from time import sleep as sleeper


def get_control_para(file_path, control_para_name):
    '''
        get value of control parameter
        :param file_path: the path of excel   e.g. /opt/workspace/SCF/SBTS22R2/TA_para_control.txt
        :param control_para_name: : need to get value of control parameter
                e.g. traffic_direction, HO_times
        '''
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
        sleeper(2)
    except Exception as e:
        print('error: %s' % e)
    else:
        sshconn.send_command(command="ls -l /home/ute/CIENV/ | grep 7_5_ |awk '{print $9}'", connection='ci_ute')
        sleeper(2)
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


def get_partial_ues_sn(file_path):
    """
    get sn of partial ues from file partial_ue_sn.txt
    :param file_path: e.g./opt/workspace/SCF/partial_ue_sn.txt
    :return: sn of partial ues
    """
    with open(file_path, 'r') as f:
        result = f.read()
    return result.strip()
