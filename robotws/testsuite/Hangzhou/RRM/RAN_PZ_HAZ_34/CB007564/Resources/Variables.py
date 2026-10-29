import os
from robot.libraries.BuiltIn import BuiltIn

tl = BuiltIn().get_variable_value("${tl}")
CFG_DIR = os.path.dirname(os.path.abspath(__file__))

__maintainer__ = 'Xing Jing'
__team__ = 'I_MN_5G_RAN_IV4_LINE_HZG_3_GMS <I_MN_5G_RAN_IV4_LINE_HZG_3@internal.nsn.com>'
__email__ = 'jing.1.xing@nokia-sbell.com'


_gnb_id = str(tl.gnbs[0].instance_id)
_MRBTSname_gnb = 'MRBTS-' + _gnb_id
_NRBTSname_gnb = _MRBTSname_gnb + '/NRBTS-' + _gnb_id
_NRCELLname_gnb = _NRBTSname_gnb + '/NRCELL-1'
_NRCELL3name_gnb = _NRBTSname_gnb + '/NRCELL-3'
_NRPMRNL_gnb = _NRBTSname_gnb + '/NRPMRNL-1'
_SERVEDAMF_gnb = _NRBTSname_gnb + '/SERVEDAMF-1'

PARAMS_TO_MODIFY_CB007564 = [
    dict(dist_name=_NRPMRNL_gnb, parameter='miNrNGCC', value='5min'),
    dict(dist_name=_SERVEDAMF_gnb, parameter='administrativeState', value='Locked'),
]
PARAMS_TO_MODIFY_CB007564_recover = [
    dict(dist_name=_NRPMRNL_gnb, parameter='miNrNGCC', value='5min'),
    dict(dist_name=_SERVEDAMF_gnb, parameter='administrativeState', value='Unlocked'),
]
PARAMS_TO_MODIFY_CB007564_04_1 = [
    dict(dist_name=_NRCELLname_gnb, parameter='administrativeState', value='Locked'),
]

PARAMS_TO_MODIFY_CB007564_04_2 = [
    dict(dist_name=_NRCELLname_gnb, parameter='administrativeState', value='Unlocked'),
]

PARAMS_TO_MODIFY_CB007564_05_1 = [
    dict(dist_name=_NRCELLname_gnb, parameter='cbraPreamblesPerSsb', value='n64'),
]
PARAMS_TO_MODIFY_CB007564_001 = [
    dict(dist_name=_NRCELLname_gnb, parameter='cbraPreamblesPerSsb', value='n56'),
]
PARAMS_TO_MODIFY_CB007564_001_recover = [
    dict(dist_name=_NRCELLname_gnb, parameter='cbraPreamblesPerSsb', value='n48'),
]

PARAMS_TO_MODIFY_CB007564_C_001 = [
    dict(dist_name=_NRCELLname_gnb, parameter='cbraPreamblesPerSsb', value='n48'),
]

PARAMS_TO_MODIFY_CB007564_C_001_recover = [
    dict(dist_name=_NRCELLname_gnb, parameter='cbraPreamblesPerSsb', value='n64'),
]

PARAMS_TO_MODIFY_CB007564_C_003 = [
    dict(dist_name=_NRCELLname_gnb, parameter='cbraPreamblesPerSsb', value='n48'),
    dict(dist_name=_NRCELL3name_gnb, parameter='cbraPreamblesPerSsb', value='n48'),
]

PARAMS_TO_MODIFY_CB007564_C_003_recover = [
    dict(dist_name=_NRCELLname_gnb, parameter='cbraPreamblesPerSsb', value='n64'),
    dict(dist_name=_NRCELL3name_gnb, parameter='cbraPreamblesPerSsb', value='n64'),
]


_Trunk_counter_path1 = f'BTS/{_NRBTSname_gnb}/NRCELL-1/NNGCC'
_Trunk_counter_path2 = f'BTS/{_NRBTSname_gnb}/NRCELL-1/NRACH'
_Trunk_counter_path3 = f'BTS/{_NRBTSname_gnb}/NRCELL-3/NRACH'
_Trunk_counter_path4 = f'BTS/{_NRBTSname_gnb}/NRCELL-3/NNGCC'
_counter_path1 = 'BTS/CELLS/NRCELL-1/NNGCC'
_counter_path2 = 'BTS/CELLS/NRCELL-1/NRACH'
_counter_path3 = 'BTS/CELLS/NRCELL-3/NRACH'
_counter_path4 = 'BTS/CELLS/NRCELL-3/NNGCC'

# cases C001####
DED_PREAMBL_SENT_CFRA_INIT = {'gnb_id': 1, 'dic_path': _counter_path1, 'counter_id': 'M55125C09021'}
INIT_MSG2_ACK_CFRA = {'gnb_id': 1, 'dic_path': _counter_path2, 'counter_id': 'M55306C09003'}
DED_PREAMBL_USED_CFRA_INIT = {'gnb_id': 1, 'dic_path': _counter_path2, 'counter_id': 'M55306C09000'}

# cases C003####
DED_PREAMBL_USED_CFRA_MSG1 = {'gnb_id': 1, 'dic_path': _counter_path3, 'counter_id': 'M55306C09001'}
MSG2_ACK_CFRA = {'gnb_id': 1, 'dic_path': _counter_path3, 'counter_id': 'M55306C09004'}
DED_PREAMBL_SENT_CFRA = {'gnb_id': 1, 'dic_path': _counter_path4, 'counter_id': 'M55125C09022'}

# cases  B004####
NG_FLOW_REL_GNB_NG_RESET = {'gnb_id': 1, 'dic_path': _counter_path1, 'counter_id': 'M55125C09001'}
Trunk_NG_FLOW_REL_GNB_NG_RESET = {'gnb_id': 1, 'dic_path': _Trunk_counter_path1, 'counter_id': 'M55125C09001'}

# cases C005####
RA_CB_INIT_RESOLVED = {'gnb_id': 1, 'dic_path': _counter_path2, 'counter_id': 'M55306C09006'}
RA_MSG3_RECEP_INIT = {'gnb_id': 1, 'dic_path': _counter_path2, 'counter_id': 'M55306C09008'}
