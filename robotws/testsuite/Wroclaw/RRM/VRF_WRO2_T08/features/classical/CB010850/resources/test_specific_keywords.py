import re
from time import sleep

from robot.libraries.BuiltIn import BuiltIn
from ta_attenuator import ta_attenuator
from taf.collectors.btslog import btslog
from taf.collectors.core import core
from taf.sbts.oam.coam.admin import admin

from testsuite.Wroclaw.RRM.VRF_WRO2_T08.resources.log_verification.pcap_reader import load_pcap
from testsuite.Wroclaw.RRM.resources.log.log import blog
from testsuite.Wroclaw.RRM.VRF_WRO2_T08.resources.common_keywords.file_utils import file_reader

_admin = admin()
core = core()
_btslog = btslog()
_builtin = BuiltIn()
_attenuator = ta_attenuator()

FEATURE_ON = [
    {"parameterName": "actPRBBlanking", "operation": "update", "value": "true"},
    {"parameterName": "nbrOfBlankedPRBsHighEdgeUL", "operation": "update", "value": "26"},
    {"parameterName": "cellBwpList", "operation": "update", "value":
        [{"bwpDN": "MRBTS-50821/NRBTS-50821/BWP_PROFILE-5", "cellBwpId": "0",
          "actPdcchCceFragmentControl": "false", "actUpperThrAckNackFiltering": "false",
          "actUpperThrAckNackHrFiltering": 'false', "pdcchResourcePreference": "peakRate"},
         {"bwpDN": "MRBTS-50821/NRBTS-50821/BWP_PROFILE-34", "cellBwpId": "1",
          "actPdcchCceFragmentControl": "false", "actUpperThrAckNackFiltering": "false",
          "actUpperThrAckNackHrFiltering": 'false', "pdcchResourcePreference": "peakRate"}]
     },
]

FEATURE_OFF = [
    {"parameterName": "actPRBBlanking", "operation": "update", "value": "false"},
    {"parameterName": "nbrOfBlankedPRBsHighEdgeUL", "operation": "update", "value": "0"},
    {"parameterName": "cellBwpList", "operation": "update", "value":
        [{"bwpDN": "MRBTS-50821/NRBTS-50821/BWP_PROFILE-4", "cellBwpId": "0",
          "actPdcchCceFragmentControl": "false", "actUpperThrAckNackFiltering": "false",
          "actUpperThrAckNackHrFiltering": 'false', "pdcchResourcePreference": "peakRate"},
         {"bwpDN": "MRBTS-50821/NRBTS-50821/BWP_PROFILE-33", "cellBwpId": "1",
          "actPdcchCceFragmentControl": "false", "actUpperThrAckNackFiltering": "false",
          "actUpperThrAckNackHrFiltering": 'false', "pdcchResourcePreference": "peakRate"}]
     },
]

HO_SUCCEEDED_MSG = r".*?Update for intra-GNB relation from source cell:832651476 to target cell:832651477.*?" \
    r".*?with PhyCellId:<LOG_SCRAM_11>213</LOG_SCRAM_11>.*?hoSucceeded.*?procedure finished.*?"


def create_syslog_collector(filename: str) -> None:
    """
    Creates a syslog collector using the specified filename for the target log file.

    :param filename: The name of the target log file to be created.
    :type filename: str
    :return: None
    """
    executor = {"host": "10.42.53.76",
                "user": "ute",
                "password": "ute"}
    _btslog.create_btslog_collector(name="btslog", target_file_name=filename,
                                    executor=executor)
    _btslog.setup_collectors("btslog")


def execute_delta_recommissioning(cb010850=True):
    params = FEATURE_ON if cb010850 else FEATURE_OFF
    try:
        _admin.setup_admin()
        _admin.perform_object_recommissioning(dist_name='MRBTS-50821/NRBTS-50821/NRCELL-211',
                                              parameter=params,
                                              operation='update',
                                              skip_parameter_relation_errors=False)
    finally:
        _admin.teardown_admin()


def convert_to_json_and_verify_num_of_prbs(pcap_path, output_json_path, target_num_prb, target_sum_prb):
    tshark_filter = ('UlData_puschReceiveReqGrant_t.numOfPrb', 'UlData_puschReceiveReqGrant_t.startPrb')
    blog(f"Converting pcap to json")
    json_file = load_pcap(pcap_path, tshark_fields=tshark_filter, output_json_file=output_json_path)
    numofprb_list = []
    for msg in json_file:
        if msg['_source']['layers']:
            startprb = int(msg['_source']['layers']['UlData_puschReceiveReqGrant_t.startPrb'][0])
            numofprb = int(msg['_source']['layers']['UlData_puschReceiveReqGrant_t.numOfPrb'][0])
            numofprb_list.append(numofprb)
            assert startprb + numofprb <= int(
                target_sum_prb), f"The sum of startPrb and numOfPrb should be <= {target_sum_prb}"
    num_prb_percent = int((numofprb_list.count(int(target_num_prb)) / len(numofprb_list)) * 100)
    blog(f"Percentage of {target_num_prb} in numOfPrb:{num_prb_percent}%")
    assert num_prb_percent >= 90, f"90% of numOfPrb should be equal to {target_num_prb}. Result = {num_prb_percent}%"


def initialize_attenuator():
    blog("initializing attenuator")
    yaml_file = _builtin.get_variable_value("${ABSTRACT_LIB_CONFIG}")
    _attenuator.load_attenuation_config(yaml_file)
    cells = list(_attenuator.cells_pool.cells_registry.keys())
    _attenuator.require_attenuator_setup_of(cells)
    _attenuator.set_attenuation_for_all_cells('90dB')
    sleep(2)


def release_attenuator():
    blog("releasing attenuator...")
    _attenuator.set_attenuation_for_all_cells('90dB')
    _attenuator.release_attenuator_cell(list(_attenuator.cells_pool.cells_registry.keys()))


def set_attenuation_for_target_cell(cell_alias, attenuation):
    _attenuator.set_attenuation(cell_alias=cell_alias, attenuation_value=attenuation)
    sleep(5)


def perform_intra_gnb_handover(source_cell, target_cell):
    blog("Performing Intra Gnb Handover...")
    _attenuator.set_attenuation(cell_alias=target_cell, attenuation_value="0db")
    _attenuator.execute_single_cell_fading_scenario(cell_alias=source_cell, fading_step="2db", fading_interval="0.5s",
                                                    fading_min="20db", fading_max="30db")


def verify_intra_gnb_handover(btslog_path):
    ho_pattern = re.compile(HO_SUCCEEDED_MSG, re.IGNORECASE)
    for line in file_reader(btslog_path):
        if ho_pattern.match(line):
            blog(f"HO MSG: {ho_pattern.match(line).group(0)}")
            return True
    raise ValueError(f"No HO msg found in syslog.")


def remove_nrrel_object():
    try:
        _admin.setup_admin()
        _admin.perform_object_recommissioning(dist_name='MRBTS-50821/NRBTS-50821/NRCELL-212/NRREL-256',
                                              parameter=[],
                                              operation='delete',
                                              skip_parameter_relation_errors=False)
    except Exception as e:
        blog(f"Nrrel Object has not been removed: {e}")
    finally:
        _admin.teardown_admin()
