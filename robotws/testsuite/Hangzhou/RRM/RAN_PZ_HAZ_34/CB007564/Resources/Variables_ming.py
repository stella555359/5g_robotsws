import os
from robot.libraries.BuiltIn import BuiltIn

tl = BuiltIn().get_variable_value("${tl}")
CFG_DIR = os.path.dirname(os.path.abspath(__file__))

__maintainer__ = 'Xing Jing'
__team__ = 'I_MN_5G_RAN_IV4_LINE_HZG_3_GMS <I_MN_5G_RAN_IV4_LINE_HZG_3@internal.nsn.com>'
__email__ = 'jing.1.xing@nokia-sbell.com'

_enb_id = str(tl.enbs[0].instance_id)
_gnb_id = str(tl.gnbs[0].instance_id)
_global_id = str(tl.gnbs[0].global_bts_id)
_MRBTSname_gnb = 'MRBTS-' + _global_id
_NRBTSname_gnb = _MRBTSname_gnb + '/NRBTS-' + _gnb_id
_MRBTSname_enb = 'MRBTS-' + _global_id
_LNBTSname = _MRBTSname_enb + '/LNBTS-' + _enb_id
_NRCELLname_gnb = _NRBTSname_gnb + '/NRCELL-1'
_NRCELL3name_gnb = _NRBTSname_gnb + '/NRCELL-3'
_NRCELL2name_gnb = _NRBTSname_gnb + '/NRCELL-2'
_NRCELL4name_gnb = _NRBTSname_gnb + '/NRCELL-4'

_NRCELL400name = _NRBTSname_gnb + '/NRCELL-400'
_NRCELL410name = _NRBTSname_gnb + '/NRCELL-410'
_NRCELL544name = _NRBTSname_gnb + '/NRCELL-544'
_NRCELL545name = _NRBTSname_gnb + '/NRCELL-545'
_NRCELL644name = _NRBTSname_gnb + '/NRCELL-644'
_NRCELL645name = _NRBTSname_gnb + '/NRCELL-645'
_NRCELL700name = _NRBTSname_gnb + '/NRCELL-700'
_NRCELL701name = _NRBTSname_gnb + '/NRCELL-701'

_LTECELL48040name = _LNBTSname + '/LNCEL-48040'
_LTECELL48041name = _LNBTSname + '/LNCEL-48041'
_LTECELL48042name = _LNBTSname + '/LNCEL-48042'
_LTECELL48043name = _LNBTSname + '/LNCEL-48043'
_LTECELL48044name = _LNBTSname + '/LNCEL-48044'
_LTECELL48045name = _LNBTSname + '/LNCEL-48045'
_LTECELL48046name = _LNBTSname + '/LNCEL-48046'
_LTECELL48047name = _LNBTSname + '/LNCEL-48047'
_LTECELL48048name = _LNBTSname + '/LNCEL-48048'
_LTECELL48049name = _LNBTSname + '/LNCEL-48049'

_NRPMRNL_gnb = _NRBTSname_gnb + '/NRPMRNL-1'
_SERVEDAMF_gnb = _NRBTSname_gnb + '/SERVEDAMF-1'

PARAMS_TO_MODIFY_CB007564 = [
    dict(dist_name=_NRPMRNL_gnb, parameter='miNrNGCC', value='5min'),
    dict(dist_name=_SERVEDAMF_gnb, parameter='administrativeState', value='Locked'),
]
PARAMS_TO_MODIFY_CB007564_348_WA = [
    dict(dist_name=_NRCELL4name_gnb, parameter='administrativeState', value='Locked'),
]
PARAMS_TO_MODIFY_CB007564_recover = [
    dict(dist_name=_NRPMRNL_gnb, parameter='miNrNGCC', value='5min'),
    dict(dist_name=_SERVEDAMF_gnb, parameter='administrativeState', value='Unlocked'),
]
PARAMS_TO_MODIFY_CB007564_recover_348_WA = [
    dict(dist_name=_NRCELL4name_gnb, parameter='administrativeState', value='Unlocked'),
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

PARAMS_TO_MODIFY_CB007564_C_003_348 = [
    dict(dist_name=_NRCELL400name, parameter='cbraPreamblesPerSsb', value='n48'),
    dict(dist_name=_NRCELL700name, parameter='cbraPreamblesPerSsb', value='n48'),
    dict(dist_name=_NRCELL700name, parameter='nbrOfSsbPerRachOccasion', value='one'),
    dict(value='locked', dist_name=_LTECELL48040name, parameter='administrativeState'),
    dict(value='locked', dist_name=_LTECELL48043name, parameter='administrativeState'),
    dict(value='locked', dist_name=_LTECELL48044name, parameter='administrativeState'),
    dict(value='locked', dist_name=_LTECELL48045name, parameter='administrativeState'),
    dict(value='Locked', dist_name=_NRCELL544name, parameter='administrativeState'),
    dict(value='Locked', dist_name=_NRCELL644name, parameter='administrativeState'),
    dict(value='Locked', dist_name=_NRCELL701name, parameter='administrativeState'),
]

PARAMS_TO_MODIFY_CB007564_C_003_recover_348 = [
    dict(dist_name=_NRCELL400name, parameter='cbraPreamblesPerSsb', value='n64'),
    dict(dist_name=_NRCELL700name, parameter='cbraPreamblesPerSsb', value='n32'),
    dict(dist_name=_NRCELL700name, parameter='nbrOfSsbPerRachOccasion', value='two'),
    dict(value='unlocked', dist_name=_LTECELL48040name, parameter='administrativeState'),
    dict(value='unlocked', dist_name=_LTECELL48043name, parameter='administrativeState'),
    dict(value='unlocked', dist_name=_LTECELL48044name, parameter='administrativeState'),
    dict(value='unlocked', dist_name=_LTECELL48045name, parameter='administrativeState'),
    dict(value='Unlocked', dist_name=_NRCELL544name, parameter='administrativeState'),
    dict(value='Unlocked', dist_name=_NRCELL644name, parameter='administrativeState'),
    dict(value='Unlocked', dist_name=_NRCELL701name, parameter='administrativeState'),
]
PARAMS_TO_MODIFY_CB007564_C_003_383 = [
    dict(dist_name=_NRCELLname_gnb, parameter='cbraPreamblesPerSsb', value='n48'),
    dict(dist_name=_NRCELL2name_gnb, parameter='cbraPreamblesPerSsb', value='n48'),
    dict(value='Locked', dist_name=_NRCELL3name_gnb, parameter='administrativeState'),
]
PARAMS_TO_MODIFY_CB007564_C_003_25R3_383 = [
    dict(dist_name=_NRCELLname_gnb, parameter='cbraPreamblesPerSsb', value='n48'),
    dict(dist_name=_NRCELL2name_gnb, parameter='cbraPreamblesPerSsb', value='n48'),
    dict(dist_name=_NRCELL2name_gnb, parameter='nbrOfSsbPerRachOccasion', value='one'),
    dict(value='Locked', dist_name=_NRCELL3name_gnb, parameter='administrativeState'),
]

PARAMS_TO_MODIFY_CB007564_C_003_recover_383 = [
    dict(dist_name=_NRCELLname_gnb, parameter='cbraPreamblesPerSsb', value='n64'),
    dict(dist_name=_NRCELL2name_gnb, parameter='cbraPreamblesPerSsb', value='n64'),
    dict(value='Unlocked', dist_name=_NRCELL3name_gnb, parameter='administrativeState'),
]
PARAMS_TO_MODIFY_CB007564_C_003_recover_25R3_383 = [
    dict(dist_name=_NRCELLname_gnb, parameter='cbraPreamblesPerSsb', value='n64'),
    dict(dist_name=_NRCELL2name_gnb, parameter='cbraPreamblesPerSsb', value='n32'),
    dict(dist_name=_NRCELL2name_gnb, parameter='nbrOfSsbPerRachOccasion', value='two'),
    dict(value='Unlocked', dist_name=_NRCELL3name_gnb, parameter='administrativeState'),
]

_counter_path1 = 'BTS/CELLS/NRCELL-1/NNGCC'
_counter_path2 = 'BTS/CELLS/NRCELL-1/NRACH'
_counter_path3_348 = 'BTS/CELLS/NRCELL-700/NRACH'
_counter_path3_383 = 'BTS/CELLS/NRCELL-2/NRACH'
_counter_path4_348 = 'BTS/CELLS/NRCELL-700/NNGCC'
_counter_path4_383 = 'BTS/CELLS/NRCELL-2/NNGCC'

_counter_path1_trunk = f'BTS/{_NRBTSname_gnb}/NRCELL-1/NNGCC'
_counter_path2_trunk = f'BTS/{_NRBTSname_gnb}/NRCELL-1/NRACH'
_counter_path3_trunk_348 = f'BTS/{_NRBTSname_gnb}/NRCELL-700/NRACH'
_counter_path3_trunk_383 = f'BTS/{_NRBTSname_gnb}/NRCELL-2/NRACH'
_counter_path4_trunk_348 = f'BTS/{_NRBTSname_gnb}/NRCELL-700/NNGCC'
_counter_path4_trunk_383 = f'BTS/{_NRBTSname_gnb}/NRCELL-2/NNGCC'

# cases C001####
DED_PREAMBL_SENT_CFRA_INIT = {'gnb_id': 1, 'dic_path': _counter_path1, 'counter_id': 'M55125C09021'}
INIT_MSG2_ACK_CFRA = {'gnb_id': 1, 'dic_path': _counter_path2, 'counter_id': 'M55306C09003'}
DED_PREAMBL_USED_CFRA_INIT = {'gnb_id': 1, 'dic_path': _counter_path2, 'counter_id': 'M55306C09000'}

# cases C003####
DED_PREAMBL_USED_CFRA_MSG1 = {'gnb_id': 1, 'dic_path': _counter_path3_348, 'counter_id': 'M55306C09001'}
MSG2_ACK_CFRA = {'gnb_id': 1, 'dic_path': _counter_path3_348, 'counter_id': 'M55306C09004'}
DED_PREAMBL_SENT_CFRA = {'gnb_id': 1, 'dic_path': _counter_path4_348, 'counter_id': 'M55125C09022'}

DED_PREAMBL_USED_CFRA_MSG1_383 = {'gnb_id': 1, 'dic_path': _counter_path3_383, 'counter_id': 'M55306C09001'}
MSG2_ACK_CFRA_383 = {'gnb_id': 1, 'dic_path': _counter_path3_383, 'counter_id': 'M55306C09004'}
DED_PREAMBL_SENT_CFRA_383 = {'gnb_id': 1, 'dic_path': _counter_path4_383, 'counter_id': 'M55125C09022'}

DED_PREAMBL_USED_CFRA_MSG1_trunk = {'gnb_id': 1, 'dic_path': _counter_path3_trunk_348, 'counter_id': 'M55306C09001'}
MSG2_ACK_CFRA_trunk = {'gnb_id': 1, 'dic_path': _counter_path3_trunk_348, 'counter_id': 'M55306C09004'}
DED_PREAMBL_SENT_CFRA_trunk = {'gnb_id': 1, 'dic_path': _counter_path4_trunk_348, 'counter_id': 'M55125C09022'}

DED_PREAMBL_USED_CFRA_MSG1_trunk_383 = {'gnb_id': 1, 'dic_path': _counter_path3_trunk_383, 'counter_id': 'M55306C09001'}
MSG2_ACK_CFRA_trunk_383 = {'gnb_id': 1, 'dic_path': _counter_path3_trunk_383, 'counter_id': 'M55306C09004'}
DED_PREAMBL_SENT_CFRA_trunk_383 = {'gnb_id': 1, 'dic_path': _counter_path4_trunk_383, 'counter_id': 'M55125C09022'}

# cases  B004####
NG_FLOW_REL_GNB_NG_RESET = {'gnb_id': 1, 'dic_path': _counter_path1, 'counter_id': 'M55125C09001'}

# cases C005####
RA_CB_INIT_RESOLVED = {'gnb_id': 1, 'dic_path': _counter_path2, 'counter_id': 'M55306C09006'}
RA_MSG3_RECEP_INIT = {'gnb_id': 1, 'dic_path': _counter_path2, 'counter_id': 'M55306C09008'}
