__maintainer__ = 'Ding Binmei'
__team__ = 'I_NSB_MN_RAN_RD_VRF_HAZ3_01_S3 '
__email__ = 'binmei.ding@nokia-sbell.com'
from robot.libraries.BuiltIn import BuiltIn
# RMOD id 1: AVQQ
# RMOD id 2: AQQF
RMOD_ID_WITH_7935_ENABLED_RF71_RF62 = ['1', '2']

# Expected cell throughput information for each cell
EXP_CELL_TPUT_INFO = {
    # 101: {'ul_tput': 42, 'dl_tput': 388, 'rmod_id': '1'},
    # 201: {'ul_tput': 42, 'dl_tput': 417, 'rmod_id': '2'}
    101: {'ul_tput': 42, 'dl_tput': 210, 'rmod_id': '1'},
    201: {'ul_tput': 42, 'dl_tput': 210, 'rmod_id': '2'}
}
# TPS info
TPS_OUT_PORTS_PER_RMOD_ID = {
    '1': [2],
    '2': [4]
}


def combine_ports_for_all_rus(tps_out_ports_per_rmod_id):
    """
    Combine ports for all RUs from the given dictionary.
    :param tps_out_ports_per_rmod_id: Dictionary with RMOD IDs as keys and lists of ports as values.
    :return: List of combined ports for all RUs.
    """
    combined_ports = []
    for ports in tps_out_ports_per_rmod_id.values():
        combined_ports.extend(ports)
    return combined_ports


TPS_OUT_PORTS_FOR_ALL_RUS = combine_ports_for_all_rus(TPS_OUT_PORTS_PER_RMOD_ID)

# #############Config for 7-2e case################
# RMOD id 1: AVQQ
RMOD_ID_WITH_7935_ENABLED_7_2E = ['1']
TPS_OUT_PORTS_FOR_7_2E_RUS = TPS_OUT_PORTS_PER_RMOD_ID['1']

MRBTS_ID = str(BuiltIn().get_variable_value('${MRBTS_ID}'))
DN_CABLINK4 = "MRBTS-" + MRBTS_ID + "/EQM-1/HWTOP-1/CABLINK-4"
DN_firstEndPoint = "MRBTS-" + MRBTS_ID + "/EQM-1/APEQM-1/CABINET-1/BBMOD-1"
DN_secondEndPoint = "MRBTS-" + MRBTS_ID + "/EQM-1/APEQM-1/RMOD-" + RMOD_ID_WITH_7935_ENABLED_7_2E[0]
REST_API_ADD_CABLINK_FOR_7_2E_RMOD_AND_BB_WITH_LINKSPEED_eCpri50 = [
    {'dist_name': DN_CABLINK4, 'parameter': 'firstEndpointDN', 'value': DN_firstEndPoint},
    {'dist_name': DN_CABLINK4, 'parameter': 'firstEndpointPortId', 'value': '3'},
    {'dist_name': DN_CABLINK4, 'parameter': 'firstEndpointLabel', 'value': 'OPT'},
    {'dist_name': DN_CABLINK4, 'parameter': 'secondEndpointDN', 'value': DN_secondEndPoint},
    {'dist_name': DN_CABLINK4, 'parameter': 'secondEndpointLabel', 'value': 'OPT'},
    {'dist_name': DN_CABLINK4, 'parameter': 'secondEndpointPortId', 'value': '3'},
    {'dist_name': DN_CABLINK4, 'parameter': 'radioProtocolType', 'value': 'eCPRI'},
    {'dist_name': DN_CABLINK4, 'parameter': 'linkSpeed', 'value': 'eCpri50'},
    {'dist_name': DN_CABLINK4, 'parameter': 'iqCompression', 'value': 'eCPRI IQ9'}
]
# For DC connection with link speed 50G
ruAstHoSyncePortNumber_DC = 3

# For Case: CB010630-SR-B_TC_05
MANUAL_SYNCE_ASSISTED_HO_PERIOD = 1
