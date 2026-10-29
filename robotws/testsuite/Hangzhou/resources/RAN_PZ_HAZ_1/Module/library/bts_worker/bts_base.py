from robot.libraries.BuiltIn import BuiltIn
from robot.api import logger
import os
import re
import requests
import logging
from taf.transport.ssh import ssh
import json

ssh = ssh()


def download_file_to_test_pc(localFilePath, remoteFilePath="/ffs/run/swconfig.txt", asib_alias="ASIB"):
    ssh.download_file(remote_path=remoteFilePath, local_path=localFilePath, connection=asib_alias)


def get_file_under_directory(directory, connection, file_indicator='*'):
    """
    Description: Get all file names from an existing directory
    :param directory: folder path, example input can be: /XXX/XXX
    :param file_indicator: regular expression to identify the files. Default to list all files.
                           Example input: 5GTtiTrace.bin.[0-9]*{}.csv
    :param connection:
    :return: Return a list which includes all file names
    """
    cmd_list_file_name = "cd {};ls {}".format(directory, file_indicator)
    output = ssh.execute(command=cmd_list_file_name, connection=connection).strip()
    logging.debug("cmd: {}, output: {}".format(cmd_list_file_name, output))
    list_file_names = []
    if output.find('No such file or directory') == -1:
        list_file_names = output.split()
    else:
        logging.info("No file found under folder {}".format(directory))
    return list_file_names


def compare_version_for_bts(indicated_sw_version, sw_version_bts):
    indicated_sw_version_list = indicated_sw_version.split("_")
    sw_version_bts_list = sw_version_bts.split("_")
    if indicated_sw_version_list[3] == sw_version_bts_list[3]:
        if indicated_sw_version_list[-1] < sw_version_bts_list[-1]:
            return True
        else:
            return False
    elif indicated_sw_version_list[3] < sw_version_bts_list[3]:
        return True
    else:
        return False


def verify_trunk_or_branch(sw_version):
    sw_version_list = sw_version.split("_")
    if sw_version_list[2] == "9999":
        return "trunk"
    else:
        return "branch"


def verify_sw_ways(indicated_sw_version, sw_version_active, sw_version_passive):
    flag_return = False
    flag_rollback = False
    flag_configuration = False
    indicated_sw__release = verify_trunk_or_branch(indicated_sw_version)
    sw_active_release = verify_trunk_or_branch(sw_version_active)
    sw_passive_release = verify_trunk_or_branch(sw_version_passive)
    if sw_active_release == "trunk":
        if sw_passive_release == "trunk":
            if indicated_sw__release == "trunk":
                if (compare_version_for_bts(indicated_sw_version, sw_version_active) and
                        compare_version_for_bts(indicated_sw_version, sw_version_passive)):
                    flag_configuration = True
                elif (compare_version_for_bts(indicated_sw_version, sw_version_active) and
                      not compare_version_for_bts(indicated_sw_version, sw_version_passive)):
                    flag_rollback = True
                elif not compare_version_for_bts(indicated_sw_version, sw_version_active):
                    flag_return = True
            else:
                flag_configuration = True
        else:
            if indicated_sw__release == "trunk":
                if not compare_version_for_bts(indicated_sw_version, sw_version_active):
                    flag_return = True
                elif compare_version_for_bts(indicated_sw_version, sw_version_active):
                    flag_rollback = True
            else:
                if compare_version_for_bts(indicated_sw_version, sw_version_passive):
                    flag_configuration = True
                else:
                    flag_rollback = True
    else:
        if sw_passive_release == "trunk":
            if indicated_sw__release == "trunk":
                flag_return = True
            else:
                if compare_version_for_bts(indicated_sw_version, sw_version_active):
                    flag_configuration = True
                else:
                    flag_return = True
        else:
            if indicated_sw__release == "trunk":
                flag_return = True
            else:
                if (compare_version_for_bts(indicated_sw_version, sw_version_active) and
                        compare_version_for_bts(indicated_sw_version, sw_version_passive)):
                    flag_configuration = True
                elif not compare_version_for_bts(indicated_sw_version, sw_version_active):
                    flag_return = True
                elif (compare_version_for_bts(indicated_sw_version, sw_version_active) and
                      not compare_version_for_bts(indicated_sw_version, sw_version_passive)):
                    flag_rollback = True
    return flag_return, flag_rollback, flag_configuration


def get_matching_elements(list_regex, regex):
    pattern = re.compile(regex)
    return [item for item in list_regex if pattern.search(item)]


def get_max_cell_power(json_file, product_name):
    with open(json_file, "r") as f:
        data = json.load(f)
    for key, value in data.items():
        if key == product_name:
            return value['Max Cell Power']


def modify_cell_dstname(input_string, mrbts_id):
    match = re.search(r'.*((NRBTS_R-\d+/NRCELL_R-\d+)|(LNBTS_R-\d+/LNCEL_R-\d+))', input_string)
    if match:
        NRBTS_NRCELL_LNBTS_LNCEL = match.group(1).replace('_R', '')
        return f"MRBTS-{mrbts_id}/" + NRBTS_NRCELL_LNBTS_LNCEL
    else:
        return None
