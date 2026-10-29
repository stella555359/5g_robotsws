"""
:copyright: Nokia Networks
:author:   Dawid Chuchnowski <dawid.chuchnowski@nokia.com>
:maintainer:   Dawid Chuchnowski <dawid.chuchnowski@nokia.com>
"""

import logging
import paramiko
from pprint import pprint as pp
from taf.sbts.oam.coam.admin import admin


def get_bts_info_json():
    """Returns dictionary with BTS information about configured and runtime objects"""
    api = admin()
    connection = api.connect_to()
    result = connection.get_bts_info(detailed_output=True)
    return result


def verify_that_fpfh_is_detected():
    """Verifies that FPFH runtime object is present"""
    bts_info_json = get_bts_info_json()
    fpfh_runtime_object = bts_info_json['requestMessage']['powerModules'][0]['id']['runtime']
    pp(bts_info_json['requestMessage']['powerModules'])
    assert fpfh_runtime_object, 'FPFH not detected. Runtime object is missing'


def verify_that_fsee_is_detected():
    """Verifies that FSEE runtime object is present"""
    bts_info_json = get_bts_info_json()
    fsee_runtime_object = bts_info_json['requestMessage']['externalAlarmBoxes'][0]['id']['runtime']
    pp(bts_info_json['requestMessage']['externalAlarmBoxes'])
    assert fsee_runtime_object, 'FSEE not detected. Runtime object is missing'


def execute_command_on_rpi(address, username, password, command):
    """
    Establishes SSH connection with RaspberryPi and sends command

    :param  address: IP address of RPi
    :param username: username to be logged on RPi
    :param password: password for selected username
    :param command: command to be sent to RPi (str)
    """
    ssh = paramiko.SSHClient()
    ssh.set_missing_host_key_policy(paramiko.AutoAddPolicy())
    ssh.connect(address, username=username, password=password)
    ssh.exec_command(command)
    logging.info(f"COMMAND SENT: {command}")
    ssh.close()
