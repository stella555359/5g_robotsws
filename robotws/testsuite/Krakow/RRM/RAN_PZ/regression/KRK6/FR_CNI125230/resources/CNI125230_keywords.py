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


def verify_if_fpfhs_are_detected():
    """Verifies that FPFH runtime objects are present"""
    bts_info_json = get_bts_info_json()
    fpfh_runtime_object = bts_info_json['requestMessage']['powerModules'][0]['id']['runtime']
    pp(bts_info_json['requestMessage']['powerModules'])
    assert fpfh_runtime_object, 'FPFH not detected. Runtime object is missing'


def verify_if_fsee_is_detected():
    """Verifies that FSEE runtime object is present"""
    bts_info_json = get_bts_info_json()
    fsee_runtime_object = bts_info_json['requestMessage']['externalAlarmBoxes'][0]['id']['runtime']
    pp(bts_info_json['requestMessage']['externalAlarmBoxes'])
    assert fsee_runtime_object, 'FSEE not detected. Runtime object is missing'
