"""
:copyright: Nokia Networks
:author: Mateusz Matusik <mateusz.matusik@nokia.com>
:maintainer: Mateusz Matusik <mateusz.matusik@nokia.com>
"""

from typing import Iterator, Optional, Union  # noqa: F401
from pprint import pformat  # noqa: F401
from taf.rfrl.bts.devices.du.commissioning import GnbCommissioning
import re
from moler.device import DeviceFactory
from moler.exceptions import WrongUsage
from robot.libraries.BuiltIn import BuiltIn
from taf.rfrl.utilities.robot.general import get_builtin_value
import taf.rfrl.utilities.logger.custom_logger as logger
from taf.rfrl.utilities.tl_config import load_moler_configuration_from_tl
from taf.ul.moler.converter.moler_converter import MolerConverter
from taf.ul.moler.converter.interface import add_device_to_already_loaded_configuration
from taf.rfrl.bts.connections.device_aliases import ssh_bts_du, ssh_bts_du_ru, ssh_cu_unit
from shutil import copyfile

tl = BuiltIn().get_variable_value('${{{}}}'.format("tl"), None)


def verify_if_alarm_is_not_active(fid, sbts_alarms_list):
    alarms_list = [int(alarm['additionalFaultID']) for alarm in sbts_alarms_list]
    for fault in fid.split(','):
        assert int(fault) not in alarms_list, f"FID {fault} present in active alarms list"


def verify_if_alarm_is_active(fid, sbts_alarms_list):
    alarms_list = [int(alarm['additionalFaultID']) for alarm in sbts_alarms_list]
    for fault in fid.split(','):
        assert int(fault) in alarms_list, f"FID {fault} not present in active alarms list"


def trigger_fault_4710():
    delta_fault_4710 = [
        {"distName": "MRBTS-85135/MNL-1/MNLENT-1/FEATCADM-1", "operation": "update", "parameters": [
            {"parameterName": "actIntelligentSynceAssHoTime", "value": "true", "operation": "update"}
        ]},
        {"distName": "MRBTS-85135/MNL-1/MNLENT-1/SYNC-1", "operation": "update", "parameters": [
            {"parameterName": "synceAssistedHoldoverMode", "value": "IntelligentHoldover", "operation": "update"}
        ]},
        {"distName": "MRBTS-85135/MNL-1/MNLENT-1/SYNC-1/CLOCK-1", "operation": "update", "parameters": [
            {"parameterName": "syncInputList", "value": [
                {"syncInputPrio": "1", "syncInputType": "1pps/ToD from external GNSS receiver"},
                {"syncInputPrio": "2", "syncInputType": "SYNCE-1"}
            ], "operation": "update"}
        ]},
        {"distName": "MRBTS-85135/MNL-1/MNLENT-1/SYNC-1/CLOCK-1/SYNCE-1", "operation": "create", "parameters": [
            {"parameterName": "ethlkDN", "value": "MRBTS-85135/TNLSVC-1/TNL-1/ETHSVC-1/ETHLK-1", "operation": "update"},
            {"parameterName": "ssmAcceptanceLevel", "value": "ssmPRCorPRS", "operation": "update"},
            {"parameterName": "ssmEnabled", "value": "true", "operation": "update"},
            {"parameterName": "ssmTimeout", "value": "5", "operation": "update"},
            {"parameterName": "ssmType", "value": "SSM_ITU", "operation": "update"},
            {"parameterName": "synceNtwReAgtForceMajor", "value": "false", "operation": "update"}
        ]}
    ]
    GnbCommissioning().perform_bts_delta_commissioning(delta_fault_4710)


def tc1_p4_suppress_fault_4080():
    delta_suppress_fault_4080 = [
        {"distName": "MRBTS-85135/MNL-1/MNLENT-1/FMCADM-1/ALARMSUPP-1", "operation": "update", "parameters": [
            {"parameterName": "actAlarmsSuppression", "value": "suppressAlarms", "operation": "update"},
            {"parameterName": "suppressedFaultList", "value": [
                {"faultId": "4080", "alarmSeverity": "MINOR"}
            ], "operation": "update"}
        ]}
    ]
    GnbCommissioning().perform_bts_delta_commissioning(delta_suppress_fault_4080)


def tc1_p6_disabled_fault_4080():
    delta_disabled_fault_4080 = [
        {"distName": "MRBTS-85135/MNL-1/MNLENT-1/FMCADM-1/ALARMSUPP-1", "operation": "update", "parameters": [
                {"parameterName": "actAlarmsSuppression", "value": "disabled", "operation": "update"}
        ]}
    ]
    GnbCommissioning().perform_bts_delta_commissioning(delta_disabled_fault_4080)


def tc7_p5_suppress_fault_4080_4710():
    delta_suppress_fault_4080_4710 = [
        {"distName": "MRBTS-85135/MNL-1/MNLENT-1/FMCADM-1/ALARMSUPP-1", "operation": "update", "parameters": [
            {"parameterName": "actAlarmsSuppression", "value": "suppressAlarms", "operation": "update"},
            {"parameterName": "suppressedFaultList", "value": [
                {"faultId": "4080,61623", "alarmSeverity": "MINOR"}
            ], "operation": "update"},
            {"parameterName": "allowedFaultList", "value": [
                {"faultId": "4080,61623", "alarmSeverity": "MINOR"}
            ], "operation": "update"}
        ]}
    ]
    GnbCommissioning().perform_bts_delta_commissioning(delta_suppress_fault_4080_4710)


def tc7_p13_23_disabled_fault_4080_4710():
    delta_disabled_fault_4080_4710 = [
        {"distName": "MRBTS-85135/MNL-1/MNLENT-1/FMCADM-1/ALARMSUPP-1", "operation": "update", "parameters": [
                {"parameterName": "actAlarmsSuppression", "value": "disabled", "operation": "update"}
        ]}
    ]
    GnbCommissioning().perform_bts_delta_commissioning(delta_disabled_fault_4080_4710)


def tc7_p14_suppress_fault_4080_4710():
    delta_suppress_fault_4080_4710 = [
        {"distName": "MRBTS-85135/MNL-1/MNLENT-1/FMCADM-1/ALARMSUPP-1", "operation": "update", "parameters": [
                {"parameterName": "actAlarmsSuppression", "value": "suppressAlarms", "operation": "update"}
        ]}
    ]
    GnbCommissioning().perform_bts_delta_commissioning(delta_suppress_fault_4080_4710)


def tc7_p21_allow_fault_4080_4710():
    delta_allow_fault_4080_4710 = [
        {"distName": "MRBTS-85135/MNL-1/MNLENT-1/FMCADM-1/ALARMSUPP-1", "operation": "update", "parameters": [
                {"parameterName": "actAlarmsSuppression", "value": "allowAlarms", "operation": "update"}
        ]}
    ]
    GnbCommissioning().perform_bts_delta_commissioning(delta_allow_fault_4080_4710)


def tc7_p25_suppress_fault_4080_4710():
    delta_suppress_fault_4080_4710 = [
        {"distName": "MRBTS-85135/MNL-1/MNLENT-1/FMCADM-1/ALARMSUPP-1", "operation": "update", "parameters": [
            {"parameterName": "actAlarmsSuppression", "value": "suppressAlarms", "operation": "update"},
            {"parameterName": "suppressedFaultList", "value": [
                {"faultId": "61623", "alarmSeverity": "MINOR"}
            ], "operation": "update"},
            {"parameterName": "allowedFaultList", "value": [
                {"faultId": "61623", "alarmSeverity": "MINOR"}
            ], "operation": "update"}
        ]}
    ]
    GnbCommissioning().perform_bts_delta_commissioning(delta_suppress_fault_4080_4710)


def tc8_p1_moc_productcode():
    delta_moc_productcode = [
        {"distName": "MRBTS-85135/MNL-1/MNLENT-1/FMCADM-1/ALARMSUPP-1", "operation": "update", "parameters": [
            {"parameterName": "actAlarmsSuppression", "value": "suppressAlarms", "operation": "update"},
            {"parameterName": "suppressedAlarmList", "value": [
                {"alarmId": "0123456789012345678901234567890123456789012345678901234567890123456789012345678901234567\
890123456789",
                 "alarmSeverity": "WARNING"}
            ], "operation": "update"},
            {"parameterName": "suppressedFaultList", "value": [
                {"faultId": "0123456789012345678901234567890123456789012345678901234567890123456789012345678901234567\
890123456789",
                 "alarmSeverity": "MINOR_AND_WARNING"}
            ], "operation": "update"},
            {"parameterName": "suppressAlarmsByMOCList", "value": [
                {"moc": "ABCDEFGHIJABCDEFGHIJABCDEFGHIJABCDEFGHIJABCDEFGHIJABCDEFGHIJABCDEFGHIJABCDEFGHIJABCDEFGHIJAB\
CDEFGHIJABCDEFGHIJABCDEFGHIJABCDEFGHIJABCDEFGHIJABCDEFGHIJABCDEFGHIJABCDEFGHIJABCDEFGHIJABCDEFGHIJABCDEFGHIJ",
                 "productCode": "012345678901234567890123456789012345678901234567890123456789012345678901234567890123\
4567890123456789", "alarmSeverity": "MINOR"}
            ], "operation": "update"}
        ]}
    ]
    GnbCommissioning().perform_bts_delta_commissioning(delta_moc_productcode)


def tc8_p1_mocdn():
    delta_mocdn = [
        {"distName": "MRBTS-85135/MNL-1/MNLENT-1/FMCADM-1/ALARMSUPP-1", "operation": "update", "parameters": [
            {"parameterName": "suppressAlarmsByMOCList", "value": "", "operation": "delete"},
            {"parameterName": "suppressAlarmsByMOCList", "value": [
                {"mocDN": "MRBTS-85135/EQM-1/APEQM-1/RMOD-1", "alarmSeverity": "MINOR"}
            ], "operation": "update"}
        ]}
    ]
    GnbCommissioning().perform_bts_delta_commissioning(delta_mocdn)


def tc8_p5_suppress_fault_4710():
    delta_suppress_fault_4710 = [
        {"distName": "MRBTS-85135/MNL-1/MNLENT-1/FMCADM-1/ALARMSUPP-1", "operation": "update", "parameters": [
            {"parameterName": "suppressedFaultList", "value": [
                {"faultId": "61623,6789012345678901234567890123456789012345678901234567890123456789012345678901234567\
890123456789", "alarmSeverity": "MINOR_AND_WARNING"}
            ], "operation": "update"}
        ]}
    ]
    GnbCommissioning().perform_bts_delta_commissioning(delta_suppress_fault_4710)


def tc8_p7_alarmlist_any():
    delta_alarmlist_any = [
        {"distName": "MRBTS-85135/MNL-1/MNLENT-1/FMCADM-1/ALARMSUPP-1", "operation": "update", "parameters": [
            {"parameterName": "suppressedAlarmList", "value": [
                {"alarmId": "ANY", "alarmSeverity": "MINOR_AND_WARNING"}
            ], "operation": "update"},
        ]}
    ]
    GnbCommissioning().perform_bts_delta_commissioning(delta_alarmlist_any)


def tc8_p9_allow_alarm_7115():
    delta_allow_alarm_7115 = [
        {"distName": "MRBTS-85135/MNL-1/MNLENT-1/FMCADM-1/ALARMSUPP-1", "operation": "update", "parameters": [
            {"parameterName": "actAlarmsSuppression", "value": "allowAlarms", "operation": "update"},
            {"parameterName": "allowedAlarmList", "value": [
                {"alarmId": "7115,56789012345678901234567890123456789012345678901234567890123456789012345678901234567\
890123456789", "alarmSeverity": "MINOR"}
            ], "operation": "update"}
        ]}
    ]
    GnbCommissioning().perform_bts_delta_commissioning(delta_allow_alarm_7115)


def create_sfp_info_agent(gnb_id=0, du_id=0, ru_id=0, run_on_factory_rfsw=True, initial_state=None):
    load_ru_device()
    if initial_state is None:
        device = DeviceFactory.get_device(
            name=ssh_bts_du_ru.format("GNB", gnb_id, du_id, "{}_{}".
                                      format(ru_id, "FACTORY" if run_on_factory_rfsw else "DEFAULT")))
    else:
        device = DeviceFactory.get_device(
            name=ssh_bts_du_ru.format("GNB", gnb_id, du_id,
                                      "{}_{}".format(ru_id, "FACTORY" if run_on_factory_rfsw else "DEFAULT")),
            initial_state="RU")
    command = "\"/ action create SfpInfo /SI\""
    hostname = device.get_cmd(cmd_name="hostname")
    h = hostname()
    logger.log_info_to_console(f"Running command  {h}: {command}", log_hierarchy=2)
    create_sfp_info = device.get_cmd(cmd_name="echo",
                                     cmd_params={
                                         "text": command + " | frmonShellClient 127.0.0.1 2000",
                                         'text_in_quotation': False})
    output = create_sfp_info()
    logger.log_info_to_console(f"Output from creating SFP Info Agent on: {output['RESULT'][1]}", log_hierarchy=3)
    if "ret / action create SfpInfo /SI ==> done ok" not in output['RESULT']:
        logger.log_info_to_console("Cannot Create SfpInfo")


def load_ru_device(factory_device=True, gnb_id=0, du_id=0, ru_id=0):
    if factory_device:
        rfsw_credentials = get_builtin_value("rfsw_credentials")
    else:
        rfsw_credentials = None
    ru_address = get_ru_ip(gnb_id=gnb_id, du_id=du_id, ru_id=ru_id)
    ru_object = get_ru_object(gnb_id=gnb_id, du_id=du_id, ru_id=ru_id)
    mc = MolerConverter()
    all_devices = mc.moler_devices.get_moler_device_config()['DEVICES']
    mc.moler_devices. \
        add_ru_configuration(device_name=ssh_bts_du_ru.format("GNB", gnb_id, du_id,
                                                              "{}_{}".format(ru_id,
                                                                             "FACTORY" if factory_device else
                                                                             "DEFAULT")),
                             host=ru_address,
                             login=rfsw_credentials['username'] if factory_device else
                             ru_object.default_ssh_connection_details.username,
                             password=rfsw_credentials['password'] if factory_device else
                             ru_object.default_ssh_connection_details.password,
                             proxy_pc_host=tl.test_pc.default_ssh_connection_details.addr,
                             proxy_pc_login=tl.test_pc.default_ssh_connection_details.username,
                             proxy_pc_password=tl.test_pc.default_ssh_connection_details.password,
                             bts_host=tl.gnbs[gnb_id].cu.oam_ssh_connection_details.addr,
                             bts_login=tl.gnbs[gnb_id].cu.oam_ssh_connection_details.username,
                             bts_password=tl.gnbs[gnb_id].cu.oam_ssh_connection_details.password)
    try:
        add_device_to_already_loaded_configuration(config=all_devices)
    except WrongUsage:
        device = DeviceFactory.get_device(
            name=ssh_bts_du_ru.format("GNB", gnb_id, du_id,
                                      "{}_{}".format(ru_id, "FACTORY" if factory_device else "DEFAULT")))
        device.ru_ip_address = ru_address


@load_moler_configuration_from_tl()
def get_ru_ip(gnb_id=0, du_id=0, ru_id=0):
    ru_ipaddr = None
    radio_unit = get_ru_object(gnb_id=gnb_id, du_id=du_id, ru_id=ru_id)
    ru_name = radio_unit.radio_type
    ru_serial = radio_unit.serial_number
    pattern_ru_addr = re.compile(r'(\d+\.\d+\.\d+\.\d+);{};{}'.format(ru_serial, ru_name))
    device = DeviceFactory.get_device(name=ssh_bts_du.format("GNB", gnb_id, du_id))
    device.goto_state("FCT")
    rus_info = device.get_cmd(cmd_name='cat',
                              cmd_params={"path": "/rom/config/FRIps.txt"})()['LINES']
    for ru_info in rus_info:
        match_ipaddr = re.search(pattern_ru_addr, ru_info)
        if match_ipaddr:
            ru_ipaddr = match_ipaddr.group(1)
            logger.log_info_to_console("Found ip address of '{}' RU with serial "
                                       "number '{}': '{}'".format(ru_name, ru_serial, ru_ipaddr), log_hierarchy=2)
            return ru_ipaddr
        if not ru_ipaddr:
            logger.log_info_to_console("Not found ip address of '{}' RU with serial number '{}' in "
                                       "'/rom/config/FRIps.txt'".format(ru_name, ru_serial), log_hierarchy=2)


def get_ru_object(gnb_id=0, du_id=0, ru_id=0):
    return tl.gnbs[gnb_id].dus[du_id].airscale.common_units[0].capacity_units[0].rus[ru_id]


def terminate_sfp_info_agent(gnb_id=0, du_id=0, ru_id=0, run_on_factory_rfsw=True):
    load_ru_device()
    device = DeviceFactory.get_device(
        name=ssh_bts_du_ru.format("GNB", gnb_id, du_id, "{}_{}".
                                  format(ru_id, "FACTORY" if run_on_factory_rfsw else "DEFAULT")), initial_state="RU")
    command = "\"/SI action terminate\""
    hostname = device.get_cmd(cmd_name="hostname")
    h = hostname()
    logger.log_info_to_console(f"Running command  {h}: {command}", log_hierarchy=2)
    terminate_sfp_info = device.get_cmd(cmd_name="echo", cmd_params={
        "text": command + " | frmonShellClient 127.0.0.1 2000", 'text_in_quotation': False})
    output = terminate_sfp_info()
    logger.log_info_to_console(f"Output from terminating SFP Info Agent: {output['RESULT'][1]}", log_hierarchy=3)


def sfp_override_memory(gnb_id=0, du_id=0, ru_id=0, run_on_factory_rfsw=True, port_id_on_ru=1, action="PAGE PAGE_1",
                        fault="0x70 DATA 0x01"):
    load_ru_device()
    device = DeviceFactory.get_device(
        name=ssh_bts_du_ru.format("GNB", gnb_id, du_id, "{}_{}".
                                  format(ru_id, "FACTORY" if run_on_factory_rfsw else "DEFAULT")), initial_state="RU")
    command = f"\"/SI action sfp_override_memory {port_id_on_ru} {action} {fault} \""
    hostname = device.get_cmd(cmd_name="hostname")
    h = hostname()
    logger.log_info_to_console(f"Running command  {h}: {command}", log_hierarchy=2)
    sfp_override = device.get_cmd(cmd_name="echo", cmd_params={
        "text": command + " | frmonShellClient 127.0.0.1 2000", 'text_in_quotation': False})
    output = sfp_override()
    logger.log_info_to_console(f"Output from SFP override memory: {output['RESULT'][1]}", log_hierarchy=3)


def cancel_sfp_override_memory(gnb_id=0, du_id=0, ru_id=0, run_on_factory_rfsw=True, port_id_on_ru=1):
    load_ru_device()
    device = DeviceFactory.get_device(
        name=ssh_bts_du_ru.format("GNB", gnb_id, du_id, "{}_{}".
                                  format(ru_id, "FACTORY" if run_on_factory_rfsw else "DEFAULT")), initial_state="RU")
    command = f"\"/SI action sfp_override_memory {port_id_on_ru}\""
    hostname = device.get_cmd(cmd_name="hostname")
    h = hostname()
    logger.log_info_to_console(f"Running command  {h}: {command}", log_hierarchy=2)
    sfp_override = device.get_cmd(cmd_name="echo", cmd_params={
        "text": command + " | frmonShellClient 127.0.0.1 2000", 'text_in_quotation': False})
    output = sfp_override()
    logger.log_info_to_console(f"Output from SFP override memory: {output['RESULT'][1]}", log_hierarchy=3)


def copy_and_modify_swconfig(parameters_list=[],
                             source_path="commissionings/Krakow/swconfig/default_swconfig.txt",
                             target_path="custom_swconfig.txt"):
    copyfile(src=source_path, dst=target_path)
    parameters_list = [parameters_list] if isinstance(parameters_list, str) else parameters_list
    for parameter in parameters_list:
        add_param_to_swconfig(parameter, target_path)


def add_param_to_swconfig(parameter, path):
    with open(path, 'r+') as sw_config:
        raw_param = parameter.split("#", 1)[0].strip(" ")                   # drop comments in file
        logger.log_info_to_console(f"Searching {raw_param} in swconfig...")
        param_found = any([raw_param in line for line in sw_config])
        if not param_found:
            logger.log_info_to_console(f"Not found. Adding new {parameter=} to swconfig")
            sw_config.write(f"\n{parameter}\n")
        else:
            logger.log_info_to_console(f"'{parameter=}' already in swconfig, skipping.")


def convert_sw_version(sw_version):
    if "9999" in str(sw_version):
        build = "SBTS00"
    else:
        build = sw_version.split("_")[0]
    return build
