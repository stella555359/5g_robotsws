"""
Debug script for syslog_data_extraction library
Author: Aberrahmane NEZROUK
Date: 2025-08-13
"""

import testsuite.Paris.RRM.ET.resources.vrf_nps2.python.syslog_operations as syslog_operations


def cell_mapping_info(syslog_path):
    # Set the path to a sample syslog file
    pattern_list = ['cprt::cm::CellMappingReq:', 'dlSubcellList']
    csv_columns = ["nrCellIdentity", "dlSubcellId", "l2PoolId", "l2SubpoolId", "l1PoolId", "l1SubpoolId"]

    try:
        result = syslog_operations.syslog_data_extraction(syslog_path, pattern_list, csv_columns)
        return syslog_operations.group_by_keys("l2SubpoolId", result)
    except Exception as e:
        print(f"Error: {e}")


def cell_setup_info(syslog_path):
    # Set the path to a sample syslog file
    pattern_list = [' CellSetupReq:', 'physCellId']
    csv_columns = ['nrCellIdentity', 'nrCellGrpId', 'lcrId', 'physCellId', 'actEcpri72e', 'belowAbove6GhzFlag',
                   'ssbScs', 'freqBandIndicatorNR', 'cellDepType', 'actTdraFallback']

    try:
        result = syslog_operations.syslog_data_extraction(syslog_path, pattern_list, csv_columns)
        return syslog_operations.group_by_keys("nrCellGrpId", result)
    except Exception as e:
        print(f"Error: {e}")


def multiK2_state_machine(syslog_path):
    # Set the path to a sample syslog file
    pattern_list = ["slot:15 nrCellGrpId: 0", "MultiK2StateMachine", "getGuardResult"]
    csv_columns = ["sfn", "slot", "nrCellIdentity", "bwpIdx", "isK2Load", "is4SlotsNeeded"]
    try:
        result = syslog_operations.syslog_data_extraction(syslog_path, pattern_list, csv_columns)
        return syslog_operations.get_key_percent_distributions(result, ["isK2Load", "is4SlotsNeeded"])
    except Exception as e:
        print(f"Error: {e}")


def dynamic_switch_reqSender(syslog_path):
    pattern_list = ["l2SubPoolId", "DynamicSwitchReqSender"]
    csv_columns = ["l2SubPoolId", "physicalCellId", "k2Cell", "targetTimingPattern", "patternSwitchingCause"]

    try:
        result = syslog_operations.syslog_data_extraction(syslog_path, pattern_list, csv_columns)
        return syslog_operations.get_key_percent_distributions(result, ["targetTimingPattern", "patternSwitchingCause"])
    except Exception as e:
        print(f"Error: {e}")
