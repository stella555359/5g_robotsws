#!/bin/python -B
# -*- coding: utf-8 -*-
"""
:copyright: Nokia
:author: Abdrrahmane NEZROUK (Paris Saclay)
:contact: abderrahmane.nezrouk@nokia.com
:maintainer: Abderrahmane Nezrouk (Paris Saclay)
"""

import random
import time
import json
import os
from datetime import datetime, timezone, timedelta
from robot.libraries.BuiltIn import BuiltIn
from robot.api import logger as robot_logger
from taf.rfrl.bts.connections import device_aliases
from taf.internal.aliasing.exceptions import AliasLookupError
from taf.sbts.oam.coam.admin import admin
import paramiko
import pytz


builtin = BuiltIn()

ROBOT_LIBRARY_SCOPE = 'TEST SUITE'


def _perform_cmd_over_ssh(cmd_line, hostname, username, password=None, ssh_key_file_path=None, port=22,
                          timeout=180):
    ssh_client = paramiko.SSHClient()
    ssh_client.set_missing_host_key_policy(paramiko.AutoAddPolicy())
    ssh_client.connect(hostname=hostname, port=port, username=username, key_filename=ssh_key_file_path,
                       password=password, look_for_keys=False,
                       banner_timeout=180,
                       timeout=timeout)
    # cmd_line = cmd_line.encode().decode("unicode-escape").replace('\\', '/')
    stdin, stdout, stderr = ssh_client.exec_command(cmd_line, timeout=timeout)
    err = stderr.read().decode("utf-8").replace('\r', "").replace('\n', "")
    result = stdout.read().decode("utf-8").replace('\r', "").replace('\n', "")
    ssh_client.close()
    return err, result


def check_instance_connection(robot_instance_name, bts_id=0, du_id=0, conn_alias=None):
    py_instance = builtin.get_library_instance(robot_instance_name)
    return _check_instance_connection(py_instance, bts_id=bts_id, du_id=du_id, conn_alias=conn_alias)


def _check_instance_connection(instance_name, bts_id=0, du_id=0, conn_alias=None):
    instance = builtin.get_library_instance(instance_name)
    if not conn_alias:
        conn_alias = device_aliases.rest_bts_du.format("GNB", bts_id, du_id)
    try:
        conn_instance = instance.admin.store.get(conn_alias)
    except AliasLookupError:
        builtin.run_keyword("log", "[{}] Already disconnected".format(conn_alias), "console=no")
        instance.connect(bts_id=bts_id, du_id=du_id)
    return conn_alias


def validation_scf_online(scf_file, bts_id=0, du_id=0):
    null = None
    try:
        api = builtin.get_library_instance('gnbbbu').admin
        conn_alias = device_aliases.rest_bts_du.format("GNB", bts_id, du_id)
        resp = api.validate_scf_online(scf_file, connection=conn_alias)
        pdlValidationResult = resp.get('requestMessage', {}).get('pdlValidationResult', {})
        logs = pdlValidationResult.get("logs", {})
        # builtin.run_keyword("log", f"type: {type(resp)} ==> resp: [{resp}] ", "console=yes")
        # builtin.run_keyword("log", f"pdlValidationResult: [{pdlValidationResult}]", "console=yes")
        # builtin.run_keyword("log", f"logs: [{logs}]", "console=yes")
        if logs and not logs['hardwareErrors'] and not logs['hardwareErrors'] and \
                pdlValidationResult['status'] == 'OK':
            return True
        return False
    except Exception as e:
        builtin.run_keyword("log", f"validate scf online Error: [{e}]", "console=yes")


def perform_commissioning(scf_file, bts_id=0, du_id=0):
    try:
        api = builtin.get_library_instance('gnbbbu').admin
        conn_alias = device_aliases.rest_bts_du.format("GNB", bts_id, du_id)
        return api.perform_commissioning(
            bts_id=0, scf_file=scf_file, skip_parameter_relation_errors=False, should_activate=True,
            timeout=300, connection=conn_alias
        )
    except Exception as e:
        builtin.run_keyword("log", f"gnbbbu perform commissioning Error: [{e}]", "console=no")


def instance_disconnect(robot_instance_name, bts_id=0, du_id=0):
    try:
        api = builtin.get_library_instance(robot_instance_name).admin
        conn_alias = device_aliases.rest_bts_du.format("GNB", bts_id, du_id)
        api.teardown(conn_alias)
    except Exception as e:
        builtin.run_keyword("log", f"{robot_instance_name} Teardown Error: [{e}]", "console=no")


def instance_reset_admin(robot_instance_name, bts_id=0, du_id=0):
    try:
        api = builtin.get_library_instance(robot_instance_name).admin
        conn_alias = device_aliases.rest_bts_du.format("GNB", bts_id, du_id)
        api.reset_admin(conn_alias)
    except Exception as e:
        builtin.run_keyword("log", f"{robot_instance_name} Reset Admin Error: [{e}]", "console=no")


def collect_IMS_file_from_eNB(log_dir, bts_id=0, du_id=0):
    """
    to delete
    :param log_dir:
    :param bts_id:
    :param du_id:
    :return:
    """
    conn_alias = device_aliases.rest_bts_du.format("ENB", bts_id, du_id)
    try:
        api = builtin.get_library_instance('gnbbbu').admin
        now = datetime.now().strftime("%Y%m%d-%H%M%S")
        # sw_ver = api.get_sw_version() # connection=conn_alias)
        # snapshot_file_name = "Log_IMS_{}_{}_{}.{}".format(conn_alias, sw_ver, now, "bin")
        snapshot_file_name = "Log_IMS_{}_{}.{}".format(conn_alias, now, "bin")
        snapshot_path = os.path.join(log_dir, snapshot_file_name)
        api.collect_infomodel_log_from_current_session(snapshot_path)
    except Exception as e:
        builtin.run_keyword("log", "error occurred: [{}]".format(e), "console=no")
    finally:
        api.teardown(conn_alias)
        del api


def get_active_alarms(allowed_alarms=[], bts_id=0, du_id=0):
    not_allowed_alarms = []
    gnb_bbu = builtin.get_library_instance("gnbbbu")
    conn_alias = device_aliases.rest_bts_du.format("GNB", bts_id, du_id)
    alarms = gnb_bbu.admin.get_active_alarms(connection=conn_alias)
    if allowed_alarms:
        for alarm in alarms:
            if str(alarm['additionalFaultID']) not in allowed_alarms:
                not_allowed_alarms.append(alarm)
    return not_allowed_alarms


def save_alarms(alarms_list, directory_path, alarms_prefix=""):
    if alarms_list:
        os.makedirs(directory_path, exist_ok=True)
        json_file_path = os.path.join(
                directory_path,
                f"{alarms_prefix}alarms.json"
            )
        with open(json_file_path, 'w') as jsfile:
            json.dump(alarms_list, jsfile, indent=4, sort_keys=True, default=str)
        return json_file_path


def get_remot_utc_datetime(datetime_format="%Y-%m-%d %H:%M:%S",
                           hostname="192.168.255.129",
                           username="toor4nsn",
                           password="oZPS0POrRieRtu",
                           timeout=30):
    err, date_string = _perform_cmd_over_ssh(
        hostname=hostname,
        username=username,
        password=password,
        cmd_line=f"date -u '+{datetime_format}'",
        timeout=timeout)
    if err and "WARNING" not in err.upper():
        raise AssertionError(err)
    return datetime.strptime(date_string, datetime_format)


def get_start_point_timestamp(kpi_names):
    kpi_params = {}
    for kpi_name in kpi_names:
        kpi_params.update({kpi_name: {'start_point_timestamp': datetime.now(pytz.utc)}})
    return kpi_params


def get_random_choice(choises):
    if isinstance(choises, int):
        return random.choice(range(choises))
    return random.choice(choises)


def upload_swconfig(swconfig_path):
    gnb_bbu = builtin.get_library_instance("gnbbbu")
    gnb_bbu.upload_swconfig(sw_config_path=swconfig_path)


def download_swconfig_file(local_dir, hostname="192.168.255.129", filename="backup_swconfig.txt"):
    ssh_client = paramiko.SSHClient()
    ssh_client.set_missing_host_key_policy(paramiko.AutoAddPolicy())
    ssh_client.connect(
        hostname=hostname, username="toor4nsn", password="oZPS0POrRieRtu"
    )
    localfile = os.path.join(local_dir, filename)
    try:
        sftp = ssh_client.open_sftp()
        sftp.get("/ffs/run/swconfig.txt", localfile)
    except Exception as e:  # pylint: disable=broad-except
        robot_logger.debug(f" Error occured when transfering swconfig file: [{e}]")

    sftp.close()
    ssh_client.close()


def get_psl_version(hostname="192.168.255.129",
                    username="toor4nsn",
                    password="oZPS0POrRieRtu",
                    timeout=15):
    err, version = _perform_cmd_over_ssh(
        hostname=hostname,
        username=username,
        password=password,
        cmd_line=r"cat /etc/*psl_version",
        timeout=timeout)
    if err and "WARNING" not in err.upper():
        robot_logger.debug(f" Error occured when transfering swconfig file: [{err}]")
    return version
