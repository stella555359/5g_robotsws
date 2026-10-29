import os
from robot.libraries.BuiltIn import BuiltIn

tl = BuiltIn().get_variable_value("${tl}")
CFG_DIR = os.path.dirname(os.path.abspath(__file__))

_gnb_id = str(tl.gnbs[0].instance_id)
_MRBTSname = 'MRBTS-'+_gnb_id
_NRBTSname = 'MRBTS-'+_gnb_id+'/NRBTS-'+_gnb_id
_NRCELLname = _NRBTSname+'/NRCELL-1'
_NRCELLname1 = _NRBTSname+'/NRCELL-1'
_NRCELLname2 = _NRBTSname+'/NRCELL-2'
_BTSPLMN1 = _NRBTSname+'/NRPLMN-1'
_BTSPLMN2 = _NRBTSname+'/NRPLMN-2'
_NRPMRNL = _NRBTSname+'/NRPMRNL-1'
_CELL2PLMN = _NRCELLname2+'/NRPLMNSET_NSA-1'
_CELL1PLMN = _NRCELLname1+'/NRPLMNSET_NSA-1'

_gnb2_id = str(tl.gnbs[1].instance_id)
_MRBTSname2 = 'MRBTS-'+_gnb2_id
_NRBTSname2 = _MRBTSname2+'/NRBTS-'+_gnb2_id
_AMF1GNB2 = _NRBTSname2+'/SERVEDAMF-1'
_NRBTS2_ID = 'NRBTS-'+_gnb2_id

_enb_id = str(tl.enbs[0].instance_id)
_MRBTSname_enb = 'MRBTS-'+_enb_id
_NRBTSname_enb = _MRBTSname_enb+'/LNBTS-'+_enb_id

Lock_gnb2_AMF1 = [
    dict(value='Locked', dist_name=_AMF1GNB2, parameter='administrativeState'),
]

Unlock_gnb2_AMF1 = [
    dict(value='Unlocked', dist_name=_AMF1GNB2, parameter='administrativeState'),
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

counter_dic_path_B01_trunk = [
    'BTS/' + _NRBTSname2 + '/NRCELL-1/MCC-262/MNC-03/NRANS',
    'BTS/' + _NRBTSname2 + '/NRCELL-1/MCC-262/MNC-03/NRANS'
]

counter_dic_path_B01_1_trunk = [
    'BTS/' + _NRBTSname2 + '/NRCELL-1/MCC-460/MNC-02/NRANS',
    'BTS/' + _NRBTSname2 + '/NRCELL-1/MCC-460/MNC-02/NRANS'
]

counter_dic_path_B01_2_trunk = [
    'BTS/' + _NRBTSname2 + '/NRCELL-1/MCC-460/MNC-02/NRANS',
    'BTS/' + _NRBTSname2 + '/NRCELL-1/MCC-460/MNC-02/NRANS'
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

PARAMS_TO_MODIFY_FEATURE_A004 = [
    dict(value='262', dist_name=_BTSPLMN2, p_name='mcc'),
    dict(value='3', dist_name=_BTSPLMN2, p_name='mnc'),
]

PARAMS_TO_MODIFY_FEATURE_A006 = [
    dict(value='true', dist_name=_NRBTSname, p_name='actIntraFreqIntraGnbMobilityNSA'),
    dict(value='262', dist_name=_BTSPLMN2, p_name='mcc'),
    dict(value='3', dist_name=_BTSPLMN2, p_name='mnc'),
]

PARAMS_TO_MODIFY_FEATURE_A005 = [
    dict(value=_BTSPLMN2, dist_name=_CELL1PLMN, list_name='nrPlmnDNList', index='0'),
]

PARAMS_TO_MODIFY_FEATURE_B001 = [
    dict(value='5min', dist_name=_NRPMRNL, p_name='miNrRANS')
]
