import os
from robot.libraries.BuiltIn import BuiltIn

tl = BuiltIn().get_variable_value("${tl}")
CFG_DIR = os.path.dirname(os.path.abspath(__file__))

_gnb_id = str(tl.gnbs[0].instance_id)
_MRBTSname = 'MRBTS-'+_gnb_id
_NRBTSname = 'MRBTS-'+_gnb_id+'/NRBTS-'+_gnb_id
_NRCELLname1 = _NRBTSname+'/NRCELL-1'
_NRCELLname2 = _NRBTSname+'/NRCELL-2'
_BTSPLMN1 = _NRBTSname+'/NRPLMN-1'
_BTSPLMN2 = _NRBTSname+'/NRPLMN-2'
_NRPMRNL = _NRBTSname+'/NRPMRNL-1'
_CELL2PLMN = _NRCELLname2+'/NRPLMNSET_NSA-1'
_CELL1PLMN = _NRCELLname1+'/NRPLMNSET_NSA-1'
_MIFSA = _NRBTSname+'/NRPMRNL-1'
_AMF1GNB1 = _NRBTSname+'/SERVEDAMF-1'
_AMF2GNB1 = _NRBTSname+'/SERVEDAMF-2'
_AMF3GNB1 = _NRBTSname+'/SERVEDAMF-3'

gnb1_Lock_AMF1_Unlock_AMF2 = [
    dict(value='Locked', dist_name=_AMF1GNB1, parameter='administrativeState'),
    dict(value='Unlocked', dist_name=_AMF2GNB1, parameter='administrativeState'),
]

gnb1_Lock_AMF1_Unlock_AMF2_A005 = [
    dict(value='Locked', dist_name=_AMF1GNB1, parameter='administrativeState'),
    dict(value='Unlocked', dist_name=_AMF2GNB1, parameter='administrativeState'),
    dict(value='10', dist_name=_NRBTSname, parameter='amfPlannedRemovalTimer'),
]

gnb1_Lock_AMF1_Unlock_AMF2_B002 = [
    dict(value='Locked', dist_name=_AMF1GNB1, parameter='administrativeState'),
    dict(value='Unlocked', dist_name=_AMF2GNB1, parameter='administrativeState'),
    dict(value='80', dist_name=_NRBTSname, parameter='amfPlannedRemovalTimer'),
]

gnb1_Unlock_AMF3 = [
    dict(value='Unlocked', dist_name=_AMF3GNB1, parameter='administrativeState'),
]

gnb1_recover_AMF = [
    dict(value='Unlocked', dist_name=_AMF1GNB1, parameter='administrativeState'),
    dict(value='Locked', dist_name=_AMF2GNB1, parameter='administrativeState'),
    dict(value='Locked', dist_name=_AMF3GNB1, parameter='administrativeState'),
]

gnb1_Lock_AMF1 = [
    dict(value='Locked', dist_name=_AMF1GNB1, parameter='administrativeState'),
]

gnb1_Unlock_AMF1 = [
    dict(value='Unlocked', dist_name=_AMF1GNB1, parameter='administrativeState'),
]

counter_id_B01 = [
    'M55145C00005', 'M55145C00006'
]

counter_id_B01_1 = [
    'M55145C00111', 'M55145C00006'
]

counter_id_B01_2 = [
    'M5511', 'M55145C00006'
]

counter_dic_path_B01 = [
    'BTS/CELLS/NRCELL-1/MCC-262_MNC-03/NRANS', 'BTS/CELLS/NRCELL-1/MCC-262_MNC-03/NRANS'
]

counter_dic_path_B01_1 = [
    'BTS/CELLS/NRCELL-1/MCC-460_MNC-02/NRANS', 'BTS/CELLS/NRCELL-1/MCC-460_MNC-02/NRANS'
]

counter_dic_path_B01_2 = [
    'BTS/CELLS/NRCELL-1/MCC-460_MNC-02/NRANS', 'BTS/CELLS/NRCELL-1/MCC-460_MNC-02/NRANS'
]

counter_id_B03 = [
    'M55326C00002'
]

counter_dic_path_B03_36012 = [
    'BTS/BTS/NRBTS-36012/MCC-262_MNC-03/NRASU'
]

counter_dic_path_B03_34712 = [
    'BTS/BTS/NRBTS-34712/MCC-262_MNC-03/NRASU'
]

counter_dic_path_B03_23312 = [
    'BTS/BTS/NRBTS-23312/MCC-262_MNC-03/NRASU'
]

counter_id_6999_A003 = [
    'M55155C00001', 'M55155C00002', 'M55155C00003', 'M55155C00004', 'M55155C00005', 'M55155C00006'
]

value_counter_6999_A003 = [
    '1', '0', '1', '1', '0', '1'
]

counter_dic_path_6999_A003 = [
    'BTS/CELLS/NRCELL-1/NGCFB', 'BTS/CELLS/NRCELL-1/NGCFB', 'BTS/CELLS/NRCELL-1/NGCFB',
    'BTS/CELLS/NRCELL-1/NGCFB', 'BTS/CELLS/NRCELL-1/NGCFB', 'BTS/CELLS/NRCELL-1/NGCFB'
]
