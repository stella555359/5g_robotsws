"""
:author: ULM
"""

import json
import logging
from ute_common_abstract_core.aliases_registry import aliases_registry


def get_imsi(ue_alias):
    ueObj = aliases_registry()[ue_alias]
    try:
        return ueObj.get_info("IMSI")
    except Exception as e:
        logging.debug("UE is not accessible!")
        return None


def qualcomm_ue_log_generator(ue_alias):
    """Author: Jing Liang"""
    ueObj = aliases_registry()[ue_alias]
    RED = '\033[31m'
    RESET = '\033[0m'
    logTmp = '\n   Qualcomm \"{}\" Info:'.format(ue_alias)
    try:
        logTmp += "\n     IMSI = {}".format(ueObj.get_info("IMSI"))
    except Exception as e:
        logTmp = logTmp + "\n     IMSI = " + RED + "UE is not accessible!" + RESET + ""
        return logTmp
    try:
        logTmp += "\n     IMEI = {}".format(ueObj.get_info("IMEI"))
    except Exception as e:
        logTmp += "\n     IMEI = " + RED + "N/A <-- UE has no IMEI" + RESET + ""

    logTmp += "\n     SIGNAL_STRENGTH = {}".format(ueObj.get_info("SIGNAL_STRENGTH"))
    logTmp += "\n     DEVICE_MODEL = {}".format(ueObj.get_info("DEVICE_MODEL"))
    logTmp += "\n     UE_OS_VER = {}".format(ueObj.get_info("DEVICE_MODEL"))
    try:
        logTmp += "\n     PCI = {}".format(ueObj.get_info("PCI"))
    except Exception as e:
        logTmp += "\n     PCI = N/A <-- UE not supported"
    try:
        logTmp += "\n     MCC = {}".format(ueObj.get_info("MCC"))
    except Exception as e:
        logTmp += "\n     MCC = N/A <-- UE not supported"
    try:
        logTmp += "\n     MNC = {}".format(ueObj.get_info("MNC"))
    except Exception as e:
        logTmp += "\n     MNC = N/A <-- UE not supported"
    try:
        logTmp += "\n     LAC = {}".format(ueObj.get_info("LAC"))
    except Exception as e:
        logTmp += "\n     LAC = N/A <-- UE not supported"
    try:
        logTmp += "\n     IP = {}".format(ueObj.get_info("IP"))
    except Exception as e:
        logTmp = logTmp + "\n     IP = " + RED + "N/A <-- UE is NOT attached" + RESET + ""
    try:
        logTmp += "\n     CELL_ID = {}".format(ueObj.get_info("CELL_ID"))
    except Exception as e:
        logTmp = logTmp + "\n     CELL_ID = " + RED + "N/A <-- UE is NOT attached" + RESET + ""
    try:
        logTmp += "\n     NodeB_ID = {}".format(ueObj.get_info("ENB_ID"))
    except Exception as e:
        logTmp = logTmp + "\n     NodeB_ID = " + RED + "N/A <-- UE is NOT attached" + RESET + ""
    return logTmp


def create_qualcomm_ue_configuration(config, tl, ue_id=0):
    """Author: Jing Liang
    :param: config : must be ${ABSTRACT_LIB_CONFIG}
    :param: tl : must be ${tl}
    :param  ue_id : (OPTIONAL) the ID of UE, Integer or String"""
    allUesCfgDict = config
    if 'AndroidUePool' not in allUesCfgDict["UE_POOLS"].keys():
        allUesCfgDict["UE_POOLS"]["AndroidUePool"] = {'inline_config': {}}
    ue_id = int(ue_id)
    ueName = "Qualcomm_{}".format(ue_id)
    if ueName not in allUesCfgDict["UE_POOLS"]["AndroidUePool"]["inline_config"].keys():
        if tl.ues[ue_id].serial_com:
            allUesCfgDict["UE_POOLS"]["AndroidUePool"]["inline_config"][ueName] = create_at_dict(tl, ue_id)
            return allUesCfgDict
        allUesCfgDict["UE_POOLS"]["AndroidUePool"]["inline_config"][ueName] = create_qualcomm_dict(tl, ue_id)
    return allUesCfgDict


def create_qualcomm_dict(tl, ue_id):
    """Author: Jing Liang
    :param: tl: must be ${tl}
    :param: ue_id: should be index in tl.ues list"""
    logging.debug("============================== Begin of create_qualcomm_dict()")
    ue = tl.ues[ue_id]
    data_transfer = transform_data_transfer(tl)
    if ue.iperf_details.iperf_path:
        data_transfer.update({"iperf_path": ue.iperf_details.iperf_path})
    if ue.iperf_details.iperf_version:
        data_transfer.update({"iperf_version": ue.iperf_details.iperf_version})
    ueCfgDict = {
        "CAPABILITIES": ue.capabilities + ['UE_{}'.format(ue_id)],
        "CLASS": "AndroidUe",
        "CONSTRUCTOR_PARAMETERS": {
            "configuration": {
                "data_transfer": data_transfer,
                "processes_to_kill": ['adb'],
                "clear_logs": 'yes',
                "clear_server_files": 'yes',
                "diag_cfg_path": ue.diag_cfg_path,
                "login": ue.ssh_connection_details.username,
                "password": ue.ssh_connection_details.password,
                "pyro_port": "9090",
                "qcat_exe_path": ue.qcat_path,
                "server_dir": ue.server_dir,
                "server_python": ue.python_path,
                "ue_pc_ip": ue.ssh_connection_details.addr
            },
            "serial_number": ue.serial_number
        },
        "STARTING_CELL": 1
    }
    logging.debug("create_qualcomm_dict(): ueCfgDict = ")
    logging.debug(json.dumps(ueCfgDict, sort_keys=True, indent=4))
    logging.debug("============================== End of create_qualcomm_dict()")
    return ueCfgDict


def create_at_dict(tl, ue_id):
    """Author: Jing Liang
    :param: tl: must be ${tl}
    :param: ue_id: should be index in tl.ues list"""
    logging.debug("============================== Begin of create_at_dict()")
    ue = tl.ues[ue_id]
    data_transfer = transform_data_transfer(tl)
    if ue.iperf_details.iperf_path:
        data_transfer.update({"iperf_path": ue.iperf_details.iperf_path})
    if ue.iperf_details.iperf_version:
        data_transfer.update({"iperf_version": ue.iperf_details.iperf_version})
    ueCfgDict = {
        "CAPABILITIES": ue.capabilities + ['UE_{}'.format(ue_id)],
        "CLASS": "AtCmdsUe",
        "CONSTRUCTOR_PARAMETERS": {
            "configuration": {
                "serial_com": ue.serial_com,
                "diag_com": ue.diag_com,
                "ue_pc_ip": ue.ssh_connection_details.addr,
                "login": ue.ssh_connection_details.username,
                "password": ue.ssh_connection_details.password,
                "pyro_port": '9090',
                "server_dir": ue.server_dir,
                "server_python": ue.python_path,
                "clear_logs": 'yes',
                "clear_server_files": 'yes',
                "network_mode_switch_method": 'ADB',
                "reset_interface": 'no',
                "enable_disable_cfun": 'yes',
                "processes_to_kill": ['notepad++', 'putty', 'adb', 'iperf', 'QPSTConfig', 'QMITestPro'],
                "data_transfer": data_transfer
            }
        }
    }
    logging.debug("create_qualcomm_dict(): ueCfgDict = ")
    logging.debug(json.dumps(ueCfgDict, sort_keys=True, indent=4))
    logging.debug("============================== End of create_qualcomm_dict()")
    return ueCfgDict


def transform_data_transfer(tl):
    data_transfer = {
        "ping": {
            "allowed_packet_loss": "5",
            "ping_count": "10",
            "ping_host_ip": ''
        }
    }
    app_servers = {}
    try:
        for appserver in tl.appservers:
            app_servers["APP_{}".format(tl.appservers.index(appserver))] = {
                "iperf_interface_ip": appserver.iperf_details.network_interface_address,
                "host": appserver.iperf_details.ssh_connection_details.addr,
                "password": appserver.iperf_details.ssh_connection_details.password,
                "user": appserver.iperf_details.ssh_connection_details.username
            }
    except Exception as e:
        logging.debug("tl.appservers is not configured, please run bootstrap to update taf.config.testline")
        app_servers['APP_0'] = {
            "iperf_interface_ip": tl.appserver.iperf_details.network_interface_address,
            "host": tl.appserver.iperf_details.ssh_connection_details.addr,
            "password": tl.appserver.iperf_details.ssh_connection_details.password,
            "user": tl.appserver.iperf_details.ssh_connection_details.username
        }
    finally:
        data_transfer["ping"].update({"ping_host_ip": app_servers["APP_0"]["host"]})
        data_transfer.update({"app_servers": app_servers})
        return data_transfer


def update_qci(qci_dict, qci, port):
    if qci_dict:
        qci_dict['qci'].update({int(qci): int(port)})
        return qci_dict
    else:
        return {'qci': {int(qci): int(port)}}
