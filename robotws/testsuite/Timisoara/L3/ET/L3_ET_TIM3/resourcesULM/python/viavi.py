import json
import logging
from robot.libraries.BuiltIn import BuiltIn
from robot.libraries.String import String


def create_viavi_ue_configuration(config, tl, ue_id=0):
    """Author: Vasileios Papoutsis
    :param: config : must be ${ABSTRACT_LIB_CONFIG}
    :param: tl : must be ${tl}
    :param  ue_id : (OPTIONAL) the ID of UE, Integer or String"""
    allUesCfgDict = config
    suiteSource = BuiltIn().get_variable_value("${SUITE SOURCE}")
    suiteDir, rest = String().split_string_from_right(suiteSource, separator="/", max_split=1)
    if 'ViaviUePool' not in allUesCfgDict["UE_POOLS"].keys():
        allUesCfgDict["UE_POOLS"] = {'ViaviUePool': {}}
    ue_id = int(ue_id)
    ueName = "Viavi_{}".format(ue_id)
    if ueName not in allUesCfgDict["UE_POOLS"]["ViaviUePool"].keys():
        allUesCfgDict["UE_POOLS"]["ViaviUePool"][ueName] = create_viavi_dict(tl.ues[ue_id], suiteDir)
    return allUesCfgDict


def create_viavi_dict(ue, suiteDir):
    """Author: Vasileios Papoutsis, Keyword: Create Viavi Dict"""
    logging.debug("============================== Begin create_viavi_dict()")
    ueCfgDict = {
        "CAPABILITIES": ["REAL_UE", "VIAVI_UE"],
        "CLASS": "ViaviUe",
        "CONSTRUCTOR_PARAMETERS": {
            "hostname": ue.tma_host.addr,
            "port": ue.tma_command_port,
            "script_paths": {
                "attach": suiteDir + "/" + "attach.txt",
                "detach": suiteDir + "/" + "detach.txt",
                "radio_card_config": suiteDir + "/" + "rc_config.txt"
            },
            "data_transfer": {
                "iperf_interface_ip": ue.iperf_details.network_interface_address,
                "ssh": {
                    "host": ue.iperf_details.ssh_connection_details.addr,
                    "password": ue.iperf_details.ssh_connection_details.password,
                    "user": ue.iperf_details.ssh_connection_details.username
                }
            }
        }
    }
    logging.debug("readYamlParameters(): ueCfgDict = ")
    logging.debug(json.dumps(ueCfgDict, sort_keys=True, indent=4))
    logging.debug("============================== End create_viavi_dict()")
    return ueCfgDict
