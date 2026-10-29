"""
Module contain functions and input variables for CB008973
"""

from robot.libraries.BuiltIn import BuiltIn
from moler.util.moler_test import MolerTest
from snapshot_analyzer import find_mandatory_files_in_snapshot
import re


@MolerTest.raise_background_exceptions()
def generate_required_rfsw_log_names(gnb_id=0, du_id=0, core_unit_id=0, common_unit_id=0, capacity_unit_id=0,
                                     unit_type="common_unit"):
    tl = BuiltIn().get_variable_value('${{{}}}'.format("tl"), None)
    logs_list = []
    log_template = "BTS.*{}_RMOD_L.*{}"
    mandatory_logs = {
        "APHG":  ["runtime", "UnitOAM_SOAP_Log", "bbox3", "ant_discovery_log",
                  "EID", "RFSW_tx_gain_trace", "Squatch_Dump_Ant", "fault_history", "version",
                  "clock_service", "rfsw_asi5g-tx-cal-cache", "rfsw_asir-rx-cal-cache",
                  "rocal_state", "runtime_sysinfo", "startup", "linux_logs"],
        "AWHQN":  ["runtime", "UnitOAM_SOAP_Log", "frozenFrame", "hlapi", "fault_history", "ptp_log", "startup"],
        "APHA": ["runtime", "UnitOAM_SOAP_Log", "bbox3", "ant_discovery_log",
                 "EID", "RFSW_tx_gain_trace", "Squatch_Dump_Ant", "fault_history", "version",
                 "clock_service",
                 "runtime_sysinfo", "startup", "linux_logs"]
    }

    unit_path = None
    if unit_type == 'core_unit':
        unit_path = tl.gnbs[gnb_id].dus[du_id].airscale.core_units[core_unit_id]
    elif unit_type == 'common_unit':
        unit_path = tl.gnbs[gnb_id].dus[du_id].airscale.common_units[common_unit_id].capacity_units[capacity_unit_id]

    if unit_path:
        for ru in unit_path.rus:
            serial = ru.serial_number
            ru_type = ru.radio_type
            if ru_type in mandatory_logs.keys():
                ru_logs = [log_template.format(serial, log_type) for log_type in mandatory_logs[ru_type]]
                logs_list.extend(ru_logs)
            else:
                MolerTest.error("Detected not supported RU type: '{}'. "
                                "Supported types: '{}'".format(ru_type, mandatory_logs.keys()),
                                raise_exception=True)
    else:
        MolerTest.error("Invalid unit type: '{}'".format(unit_type),
                        raise_exception=True)
    return logs_list


@MolerTest.raise_background_exceptions()
def find_rfsw_logs_in_snapshot(directory, mandatory_logs):
    """
    Search for RFSW files in snapshot
    :param directory: path to directory with snapshot
    :param mandatory_logs: RFSW file names to be searched in snapshot
    :return: None
    """
    file_list = find_mandatory_files_in_snapshot(directory)
    if mandatory_logs is None:
        mandatory_log_list = ["journal", "hlapi", "runtime", "startup", "ps", "fault_history", "RP1OM"]
    else:
        mandatory_log_list = mandatory_logs
    for mandatory_log in mandatory_log_list:
        regex_file_list = re.compile(r'{}'.format(mandatory_log))
        matched = list(filter(regex_file_list.match, file_list))
        if matched:
            MolerTest.info("Found '{}' log files matched to given mandatory_logs regex "
                           "'{}' : '{}'".format(len(matched), mandatory_log, matched))
        else:
            MolerTest.error("Mandatory RFSW file '{}' not matched in snapshot: '{}'".format(mandatory_log, directory),
                            raise_exception=True)
