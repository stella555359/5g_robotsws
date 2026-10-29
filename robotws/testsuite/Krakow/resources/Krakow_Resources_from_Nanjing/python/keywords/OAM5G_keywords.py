# -*- coding: utf-8 -*-
"""
OAM 5G generic Python keywords
"""

__author__ = 'Adam Moszczynski'
__copyright__ = 'Copyright (C) 2019, Nokia'
__email__ = 'adam.1.moszczynski@nokia.com'

import re
import os
import time
from datetime import datetime
from functools import wraps
from moler.device.device import DeviceFactory
from moler.util.moler_test import MolerException
from moler.util.moler_test import MolerTest
from taf.ul.sc.hub import Hub
from taf.ul.sc.gnb.airscale import AirScale
from taf.ul.sc.asimgr import AsiMgr
from taf.ul.sc.gnb.oam.rest import Rest
from taf.ul.sc.gnb.oam.selenium import Selenium
from taf.ul.sc.exceptions import SC5GException
import time
from robot.libraries.BuiltIn import BuiltIn


@MolerTest.raise_background_exceptions(check_steps_end=True)
def compare_hub_build_version_with_asihub_version_from_tagetbd():
    active_hub_version = Hub(autoconnect=True).get_active_hub_build_version()
    hub_version_from_targetbd = AirScale(autoconnect=True).get_asihub_version_from_targetbd()
    if active_hub_version == hub_version_from_targetbd:
        MolerTest.info("Compatible version in TargetBD and ASIHUB: {}".format(active_hub_version))
    else:
        MolerTest.info("Incompatible version in TargetBD and ASIHUB: {} != {}".format(
            hub_version_from_targetbd, active_hub_version))

    MolerTest.steps_end()


@MolerTest.raise_background_exceptions(check_steps_end=True)
def modify_bts_number_in_scf_file(path_to_file):
    mrbts_id = Rest().mrbts_id

    with open(path_to_file, 'r') as scf_file:
        file_content = scf_file.read()
    if not file_content:
        MolerTest.error("SCF file is empty")
    file_content = re.sub(r'MRBTS-\d+', 'MRBTS-{}'.format(mrbts_id), file_content)
    with open(path_to_file, 'w') as scf_file:
        scf_file.write(file_content)
    MolerTest.steps_end()
    MolerTest.info("SCF file has been modified")


@MolerTest.raise_background_exceptions(check_steps_end=True)
def compare_hub_build_version_with_ru_software_version():
    hub = Hub(autoconnect=True)
    hub.device.goto_state("LINUX")

    active_hub_version = hub.get_hub_build_version()
    ru_version = Selenium().get_ru_software_version_via_selenium()
    if active_hub_version == ru_version:
        MolerTest.info("Compatible version in TargetBD and ASIHUB: {}".format(active_hub_version))
    else:
        MolerTest.info("Incompatible version in TargetBD and ASIHUB: {} != {}".format(
            ru_version, active_hub_version))

    MolerTest.steps_end()


def wait_until_function_succeeds(function, timeout_in_seconds, interval_s, *args, **kwargs):
    """
    Wait until given function sucveeds
    :param function: name of function
    :param timeout_in_seconds: int, timeout in seconds
    :param interval_s: int, interval
    :param args: args
    :param kwargs: kwargs
    :return: None
    """
    interval = int(interval_s)
    if 'time_start' in kwargs:
        time_start = kwargs['time_start']
        if time.time() - time_start > timeout_in_seconds:
            MolerTest.error("Timeout calling function {}".format(function.__name__), raise_exception=True)
    else:
        time_start = time.time()
    try:
        result = function(*args)
        MolerTest.info(result)
        if result is False:
            MolerTest.sleep(interval)
            wait_until_function_succeeds(function, timeout_in_seconds, interval, *args, time_start=time_start,
                                         **kwargs)

    except (SC5GException, MolerException):
        MolerTest.sleep(interval)
        wait_until_function_succeeds(function, timeout_in_seconds, interval, *args, time_start=time_start, **kwargs)


def ping_host(device, host, state, packets_to_send=5, expected_packets_received=5):
    """

    :param device: device
    :param host: string, host ip
    :param state: string, device's state
    :param packets_to_send: int, number of packets to be sent
    :param expected_packets_received: int, number of packets to be received
    :return: None
    """
    device.device.goto_state(state=state, rerun=5)

    ping = device.device.get_cmd(cmd_name="ping", cmd_params={
        'destination': host,
        'options': '-c {}'.format(packets_to_send)
    })

    result = ping(timeout=30)

    packets_received = result['packets_received']

    if packets_received == expected_packets_received:
        MolerTest.info("There is '{}' package received as expected.".format(packets_received))
    else:
        MolerTest.error(
            "There is '{}' package received but expected: '{}.'".format(packets_received, expected_packets_received))
        raise Exception("There is not as many packet as expected")


def get_asimgr_version(asir):
    """
    Get asimgr version
    :param asir: device
    :return: string, version of asimgr
    """
    asir.device.goto_state(state="FCT", rerun=5)
    hub_name = "HUB0"

    grep_cmd = asir.device.get_cmd(cmd_name="grep",
                                   cmd_params={"options": "-a ASI /rom/config/ASICNTR/current.adaptation"})
    grep_result = grep_cmd()
    version = None

    for line in grep_result["LINES"]:
        if re.search(r"(ASI\S+)", line):
            version = re.search(r"(ASI\S+)", line).group()

    if version:
        MolerTest.info("Found '{}' version in line '{}'".format(hub_name, version))
    else:
        MolerTest.error("Cannot find '{}' version in grep output: {}".format(hub_name, grep_result["LINES"]))
    return version


def prepare_deltafile_for_lmpport_management(gnb, type_of_operation='lock'):
    """
    Prepare deltafile for lmp management
    :param gnb: device
    :param type_of_operation: string, either lock or unlock
    :return: string, delta for unlock or lock
    """
    deltafile_path = "/home/ute/"

    current_date = datetime.now()
    current_date = current_date.strftime("%Y-%m-%dT%H:%M:%S")
    bts_id = Rest(oam_ip="192.168.255.1").get_bts_info()['mrbtsID']

    lock_lmtport_deltafile_path = os.path.join(deltafile_path, "deltafile1_lock.xml")
    unlock_lmtport_deltafile_path = os.path.join(deltafile_path, "deltafile2_unlock.xml")
    deltafile_lock_unlock_lmtport = '<?xml version="1.0" encoding="UTF-8" standalone="no"?>\n' \
                                    '<raml xmlns="raml21.xsd" version="2.1">\n' \
                                    '<cmData id="3221225472" scope="all" type="plan">\n' \
                                    '<header>\n' \
                                    '<log action="created" appInfo="Nokia ASiR Manager"' \
                                    ' appVersion="{}" dateTime="{}" user="BTSSM"/>\n' \
                                    '</header>\n' \
                                    '<managedObject class="com.nokia.asi:LMTPORT"' \
                                    ' distName="ASI-{}/HUBMOD-1/LMTPORT-1" ' \
                                    'operation="update" version="{}">\n' \
                                    '<p name="administrativeState">{}</p>\n' \
                                    '</managedObject>\n' \
                                    '</cmData>\n' \
                                    '</raml>\n'

    version = get_asimgr_version(asir=gnb)
    if type_of_operation == 'lock':
        return deltafile_lock_unlock_lmtport.format(version, current_date, bts_id, version,
                                                    "locked"), lock_lmtport_deltafile_path

    return deltafile_lock_unlock_lmtport.format(version, current_date, bts_id, version,
                                                "unlocked"), unlock_lmtport_deltafile_path


def check_if_file_exists(path, device=AirScale, state="PROXY_PC"):
    """
    Check if given file exists on system
    :param path: string, path to file
    :param device: name of device, default AirScale
    :param state: string, name of device's state, default PROXY_PC
    :return: boolean, True if file exists, False if not
    """
    gnb = device(autoconnect=True)
    gnb.device.goto_state(state)
    path = path.replace(" ", "\\ ")
    cmd_ls = gnb.device.get_cmd(cmd_name="ls", cmd_params={'options': '{} >> /dev/null 2>&1 && echo yes || echo no'
                                .format(path)})
    cmd_output = cmd_ls()
    cmd_output = [cmd_output['files'][i]['name'] for i in cmd_output['files']][0]
    MolerTest.info(cmd_output)
    if cmd_output == 'yes':
        return True
    else:
        return False


def run_keyword_for_all_devices(device_type, device_name_filter='.*'):
    """
    Run decorated keyword for all devices of device_type.

    :param device_type: device class e.g. Hub
    :param device_name_filter: regex for device name filtering
    :return: wrapped keyword
    """
    def wrapped_with_params(keyword):
        @wraps(keyword)
        def wrapped(*args, **kwargs):
            devices = DeviceFactory.get_devices_by_type(device_type=device_type)
            device_names = [device.name for device in devices if re.search(device_name_filter, device.name)]
            result = dict()
            for name in device_names:
                result.update({
                    name: keyword(device_name=name, *args, **kwargs)
                })
            return result

        return wrapped

    return wrapped_with_params
