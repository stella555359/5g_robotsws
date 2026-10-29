# -*- coding: utf-8 -*-
"""
This module provides utilities for cloud analysis in the context of a RAN PZ HAZ 34 test suite.

:copyright: Nokia Networks
:author: Tingting Zhong
:contact: tingting.zhong@nokia-sbell.com
:maintainer: Tingting Zhong
:contact: tingting.zhong@nokia-sbell.com
"""
import logging
import os
from taf.rfrl.cbts.utilities import generic_utils
from taf.rfrl.cbts.connections.rest_conn_vcu import GenericCU
from taf.rfrl.cbts.devices.vcu.base.vcu_ope_base import vCUOPE
from taf.rfrl.cbts.connections.rest_conn_vdu import GenericVDU
from taf.rfrl.cbts.devices.vdu.base.vdu_ope_base import vDUOPE
from taf.rfrl.cbts.devices.vcu.base.vcu_cm_base import vCUCM
from taf.rfrl.cbts.devices.vdu.base.vdu_cm_base import vDUCM
from taf.rfrl.utilities.robot.general import get_builtin_value
from testsuite.Hangzhou.resources.RAN_PZ_HAZ_34.python.scf.scf_analysis import ScfAnalysis

vcu_ope_base = vCUOPE()
vdu_ope_base = vDUOPE()
vcu_gen = GenericCU()
vdu_gen = GenericVDU()
vcucm = vCUCM()
vducm = vDUCM()


def cloud_get_cu_release(gnb_index=0, convert_to_trunk=True):
    """
    This function logs into the CU, gets the software stream version, and then logs out.
    It splits the version string on underscores and checks if the second part starts with '0.'.
    If it does and convert_to_trunk is True, it sets the software stream to 'vDUCNF00'.
    Otherwise, it sets the software stream to the first part of the split version string.

    :param gnb_index: The index of the gNB. Default is 0.
    :param convert_to_trunk: A boolean indicating whether to convert versions starting with '0.' to 'vDUCNF00'.
    Default is True.
    :return: The software stream version of the CU.
    """
    conn_alias = generic_utils.get_unique_id_string()
    vcu_gen.login_rest(gnb_index=gnb_index, alias=conn_alias)
    vcu_sw_version = vcu_ope_base.get_cu_sw_version_from_webem(conn_alias=conn_alias)
    logging.info(f'vCU software version: {vcu_sw_version}')
    split_version = vcu_sw_version.split('_')
    if split_version[1].startswith('0.') and convert_to_trunk:
        vcu_sw_stream = 'vCUCNF00'
    else:
        vcu_sw_stream = split_version[0]
    vcu_gen.logout_rest(conn_alias=conn_alias)
    return vcu_sw_stream


def cloud_get_vdu_release(gnb_index=0, convert_to_trunk=True):
    """
    This function logs into the VDU, gets the software stream version, and then logs out.
    It splits the version string on underscores and checks if the second part starts with '0.'.
    If it does and convert_to_trunk is True, it sets the software stream to 'vDUCNF00'.
    Otherwise, it sets the software stream to the first part of the split version string.

    :param gnb_index: The index of the gNB. Default is 0.
    :param convert_to_trunk: A boolean indicating whether to convert versions starting with '0.' to 'vDUCNF00'.
    Default is True.
    :return: The software stream version of the VDU.
    """
    conn_alias = generic_utils.get_unique_id_string()
    vdu_gen.login_rest(gnb_index=gnb_index, alias=conn_alias)
    vdu_sw_version = vdu_ope_base.get_vdu_sw_version_from_webem(conn_alias=conn_alias)
    logging.info(f'vDU software version: {vdu_sw_version}')
    split_version = vdu_sw_version.split('_')
    if split_version[1].startswith('0.') and convert_to_trunk:
        vdu_sw_stream = 'vDUCNF00'
    else:
        vdu_sw_stream = split_version[0]
    vdu_gen.logout_rest(conn_alias=conn_alias)
    return vdu_sw_stream


def cloud_get_golden_scf_path(
        gnb_index=0,
        cu_or_du='DU',
        cur_relative_dir='testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/robot/siso_common_case/lib'):
    """
    This function gets the path of the golden SCF file.
    :param gnb_index: The index of the gNB. Default is 0.
    :param cu_or_du: The type of the unit. Default is 'DU'.
    :param cur_relative_dir: The current relative directory.
    Default is 'testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/robot/siso_common_case/lib'.
    :return: The path of the golden SCF file.
    """
    scf_relative_dir = 'commissionings/HGZ'
    current_dir = os.path.dirname(__file__)
    scf_base_path = current_dir.replace(cur_relative_dir, scf_relative_dir)
    stream = cloud_get_cu_release(gnb_index) if cu_or_du.lower() == 'cu' else cloud_get_vdu_release(gnb_index)
    gnb_ext = '' if gnb_index == 0 else f'_gnb{gnb_index}'
    # CONFIGURATION and ENB_BUILD are parameters in ute cloud, now no vran env on ute cloud
    configuration = get_builtin_value(param_name='CONFIGURATION')
    enb_build = get_builtin_value(param_name='ENB_BUILD')
    ute_env = configuration is not None and enb_build is not None
    if ute_env:
        testline = configuration.split('.')[-1]
    else:
        testline = get_builtin_value(param_name='testline_name')
    golden_scf_path = os.path.join(scf_base_path, testline, f'SCF_{stream}{gnb_ext}.xml')
    return golden_scf_path


def cloud_perform_cu_full_scf(cu_scf_path, gnb_index=0):
    """
    This function performs a full SCF on the CU.
    :param cu_scf_path: The path of the CU SCF file.
    :param gnb_index: The index of the gNB. Default is 0.
    """
    conn_alias = generic_utils.get_unique_id_string()
    vcu_gen.login_rest(gnb_index=gnb_index, alias=conn_alias)
    stream = cloud_get_cu_release(gnb_index=gnb_index, convert_to_trunk=False)
    if stream == 'vCUCNF25R1':
        vcucm.full_commissioning(stage_plan_file_path=cu_scf_path, conn_alias=conn_alias)
    else:
        vcu_gen.cu.perform_commissioning(scf_file=cu_scf_path, connection=conn_alias)
    vcu_gen.logout_rest(conn_alias=conn_alias)


def cloud_perform_vdu_full_scf(vdu_scf_path, timeout=450, gnb_index=0, vdu_index=0):
    """
    This function performs a full SCF on the VDU.
    :param vdu_scf_path: The path of the VDU SCF file.
    :param gnb_index: The index of the gNB. Default is 0.
    :param vdu_index: The index of the VDU. Default is 0.
    """
    conn_alias = generic_utils.get_unique_id_string()
    vdu_gen.login_rest(vdu_index=vdu_index, gnb_index=gnb_index, alias=conn_alias)
    stream = cloud_get_vdu_release(gnb_index=gnb_index, convert_to_trunk=False)
    if stream == 'vDUCNF25R1':
        vducm.full_commissioning(stage_plan_file_path=vdu_scf_path, conn_alias=conn_alias,
                                 timeout_4_full_commission_finished=timeout)
    else:
        vdu_gen.vdu.perform_commissioning(scf_file=vdu_scf_path, vdu_connection=conn_alias)
    vdu_gen.logout_rest(conn_alias=conn_alias)


def cloud_get_bts_id_from_scf(scf_path):
    """
    This function gets the BTS ID from the SCF file.
    :param scf_path: The path of the SCF file.
    :return: The BTS ID.
    """
    scf_analysis = ScfAnalysis()
    scf_analysis.setup(scf_path=scf_path)
    mrbts_id, nrbts_id = scf_analysis.get_mrbtsid_and_nrbtsid()
    return mrbts_id, nrbts_id
