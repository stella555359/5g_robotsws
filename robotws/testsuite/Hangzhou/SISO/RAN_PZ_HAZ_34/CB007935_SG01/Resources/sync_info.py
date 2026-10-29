# -*- coding: utf-8 -*-
"""
Author:         Ding Binmei
Contact Mail:   binmei.ding@nokia-sbell.com
Description:    Get sync related info

"""
from taf.sbts.oam.coam.admin import admin
import logging
import re

coam = admin()

__all__ = ["get_sync_info_for_all_rus", "get_sync_info_based_on_rmod_ids"]


def get_sync_info_for_all_rus(timeout=60, connection_alias="GNB_OAM"):
    """
    :param timeout: timeout for get_managed_objects
    :param connection_alias: connection_alias for ssl connection
    Get sync info for all RUs
    Return a dict with rmod_id as key and sync info as value.
        sync info includes: clock_info/syncE_config_info/syncE_R_info/...
    Example output:
    {'1':
        {'sync_id' : '2',
        'sync_config_info':{'distName': '/XXX/SYNC_A-2',
                          'parameters': {'actEcpriMasterClock': None,
                                         'actIntelligentSynceAssHoTime': None,
                                         'actRuIntelligentSynceAstHoTime': True,
                                         'btsSyncMode': None,
                                         'instanceOwnedByBTS': None,
                                         'manualFrameTimingAdjustment': None,
                                         'manualSynceAssistedHoPeriod': None,
                                         'maxPtpNetworkTimeErrorRuIn': 1500,
                                         'maximumRuTimeErrorAstHoEnd': 2500,
                                         'phaseErrorRecoveryThreshold': None,
                                         'profileType': 'RU',
                                         'synceAssistedHoldoverMode': 'IntelligentHoldover',
                                         'targetDNList': ['XXX/APEQM_A-1/RMOD_A-1'],
                                         'userLabel': None}}
        'clock_info': {'distName': 'XXX/SYNC_CONF_M-2/CLOCK_CONF_M-1/CLOCK_R-1',
                        'parameters': {'activeSyncMode': None,
                                         'activeTimeSource': None,
                                         'autoDetectTotalDelayFromSHM': None,
                                         'ruAssistedHoPeriod': 65535,
                                         'selectedSyncInput': None,
                                         'syncStatus': 'Locked',
                                         'synceAssistedHoModeSelected': None,
                                         'targetDN': 'XXX/APEQM_A-1/RMOD_A-1'}},
       'syncE_R_info': {'distName': 'XXX/SYNC_CONF_M-2/CLOCK_CONF_M-1/SYNCE_CONF_M-1/SYNCE_R-1',
                        'parameters': {'lockState': 'OutOfLock',
                                       'ssmValue': 'ssmPRC',
                                       'synceAstHoNotSupported': None,
                                       'synceExtendedQlTlv': {'mixedClock': 'Mixed EEC/eEEC',
                                                              'numberCascadedEECsFromSsuPrc': 0,
                                                              'numberCascadedeEECsFromSsuPrc': 1,
                                                              'partialChain': True,
                                                              'synceOriginatorClockIdentity': '0x089c86b01f28ff01'},
                                       'synceStatus': 'OK',
                                       'targetDN': 'XXX/APEQM_A-1/RMOD_A-1'}},
       'syncE_config_info': {'distName': 'XXX/SYNC_A-2/CLOCK_A-1/SYNCE_A-1',
                             'parameters': {'ethlkDN': None,
                                            'ruAstHoSyncePortNumber': 1,
                                            'ssmAcceptanceLevel': 'ssmPRCorPRS',
                                            'ssmEnabled': False,
                                            'ssmTimeout': 5,
                                            'ssmType': 'SSM_ITU',
                                            'syncESsmList': [],
                                            'synceNtwReAgtForceMajor': False}}}
    }
    """
    dict_sync_info_for_rus = {}
    list_all_clock_r_mo_info = coam.get_managed_objects(
        class_name="CLOCK_R", timeout=timeout, connection=connection_alias)
    logging.debug(f"list_all_clock_r_mo_info: {list_all_clock_r_mo_info}")
    dict_syncE_R_info = get_syncE_runtime_info_for_all_rus(timeout=timeout, connection_alias=connection_alias)
    dict_syncE_config_info = get_syncE_config_info_for_all_sync_id(
        timeout=timeout, connection_alias=connection_alias)
    dict_sync_conf_info = get_sync_config_info_for_all_rus(timeout=timeout, connection_alias=connection_alias)
    logging.info(f"dict_syncE_R_info: {dict_syncE_R_info}")
    logging.info(f"dict_syncE_config_info: {dict_syncE_config_info}")
    logging.info(f"dict_sync_conf_info: {dict_sync_conf_info}")
    for clock_r_mo_info in list_all_clock_r_mo_info:
        clock_dn = clock_r_mo_info["distName"]
        target_dn = clock_r_mo_info["parameters"]["targetDN"]
        if target_dn is None:
            logging.info(f"Clock {clock_dn} has no targetDN, skip")
            continue
        else:
            rmod_id = re.match(r".*RMOD_A-(\d+)", target_dn).group(1)
            sync_id = re.match(r".*SYNC_CONF_M-(\d+)", clock_dn).group(1)
            dict_sync_info_for_rus[rmod_id] = {}
            dict_sync_info_for_rus[rmod_id]["sync_id"] = sync_id
            dict_sync_info_for_rus[rmod_id]["sync_config_info"] = dict_sync_conf_info[rmod_id]
            dict_sync_info_for_rus[rmod_id]["syncE_R_info"] = dict_syncE_R_info[rmod_id]
            dict_sync_info_for_rus[rmod_id]["syncE_config_info"] = dict_syncE_config_info[sync_id]
            dict_sync_info_for_rus[rmod_id]["clock_info"] = clock_r_mo_info
    return dict_sync_info_for_rus


def get_sync_info_based_on_rmod_ids(rmod_ids, timeout=60, connection_alias="GNB_OAM"):
    """
    Get sync info based on a list of rmod_ids
    Return a dict with rmod_id as key and sync info as value.
    """
    if not isinstance(rmod_ids, list):
        rmod_ids = [rmod_ids]
    dict_sync_info_for_rus = get_sync_info_for_all_rus(timeout=timeout, connection_alias=connection_alias)
    result = {}
    for rmod_id in rmod_ids:
        result[rmod_id] = dict_sync_info_for_rus.get(rmod_id)
    return result


def get_syncE_runtime_info_for_all_rus(timeout=60, connection_alias="GNB_OAM"):
    """
    Get syncE runtime info for all RUs
    Return a dict with rmod_id as key and syncE runtime info as value.
    """
    list_all_syncE_R_mo_info = coam.get_managed_objects(
        class_name="SYNCE_R", timeout=timeout, connection=connection_alias)
    dict_syncE_R_info = {}
    for syncE_mo_info in list_all_syncE_R_mo_info:
        target_dn = syncE_mo_info["parameters"]["targetDN"]
        if target_dn is not None:
            rmod_id = re.match(r".*RMOD_A-(\d+)", target_dn).group(1)
            dict_syncE_R_info[rmod_id] = syncE_mo_info
    return dict_syncE_R_info


def get_syncE_config_info_for_all_sync_id(timeout=60, connection_alias="GNB_OAM"):
    """
    Get syncE config info for all sync_id
    Return a dict with sync_id as key and syncE config info as value.
    """
    list_all_syncE_A_mo_info = coam.get_managed_objects(
        class_name="SYNCE_A", timeout=timeout, connection=connection_alias)
    dict_syncE_config_info = {}
    for syncE_mo_info in list_all_syncE_A_mo_info:
        sync_id = re.match(r".*SYNC_A-(\d+)", syncE_mo_info["distName"]).group(1)
        dict_syncE_config_info[sync_id] = syncE_mo_info
    return dict_syncE_config_info


def get_sync_config_info_for_all_rus(timeout=60, connection_alias="GNB_OAM"):
    """
    Get sync config info for all RUs
    Return a dict with rmod_id as key and sync config info as value.
    """
    list_all_sync_conf_mo_info = coam.get_managed_objects(
        class_name="SYNC_A", timeout=timeout, connection=connection_alias)
    dict_sync_conf_info = {}
    for sync_conf_mo_info in list_all_sync_conf_mo_info:
        target_dn_list = sync_conf_mo_info["parameters"]["targetDNList"]
        for target_dn in target_dn_list:
            rmod_id = re.match(r".*RMOD_A-(\d+)", target_dn).group(1)
            dict_sync_conf_info[rmod_id] = sync_conf_mo_info
    return dict_sync_conf_info
