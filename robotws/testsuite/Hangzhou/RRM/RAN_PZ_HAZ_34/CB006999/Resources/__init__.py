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
_MIFSA = _NRBTSname+'/NRPMRNL-1'

_gnb2_id = str(tl.gnbs[1].instance_id)
_MRBTSname2 = 'MRBTS-'+_gnb2_id
_NRBTSname2 = _MRBTSname2+'/NRBTS-'+_gnb2_id
_AMF1GNB2 = _NRBTSname2+'/SERVEDAMF-1'
_AMF2GNB2 = _NRBTSname2+'/SERVEDAMF-2'
_AMF3GNB2 = _NRBTSname2+'/SERVEDAMF-3'
_NRBTS2_ID = 'NRBTS-'+_gnb2_id

gnb2_Lock_AMF1_Unlock_AMF2 = [
    dict(value='Locked', dist_name=_AMF1GNB2, parameter='administrativeState'),
    dict(value='Unlocked', dist_name=_AMF2GNB2, parameter='administrativeState'),
]

gnb2_Lock_AMF1_Unlock_AMF2_OFF = [
    dict(value='Locked', dist_name=_AMF1GNB2, parameter='administrativeState'),
    dict(value='Unlocked', dist_name=_AMF2GNB2, parameter='administrativeState'),
    dict(value='false', dist_name=_NRBTSname2, parameter='actAmfPlannedRemoval'),
]

gnb2_Unlock_AMF3 = [
    dict(value='Unlocked', dist_name=_AMF3GNB2, parameter='administrativeState'),
]

gnb2_recover_AMF = [
    dict(value='Unlocked', dist_name=_AMF1GNB2, parameter='administrativeState'),
    dict(value='Locked', dist_name=_AMF2GNB2, parameter='administrativeState'),
    dict(value='Locked', dist_name=_AMF3GNB2, parameter='administrativeState'),
]

PARAMS_TO_MODIFY_CB006999_true = [
    dict(value='true', dist_name=_NRBTSname, p_name='actAmfPlannedRemoval'),
    dict(value='0', dist_name=_NRBTSname, p_name='amfPlannedRemovalTimer'),
    dict(value='true', dist_name=_NRBTSname, p_name='actNgcFlexSaMode'),
    dict(value='5min', dist_name=_MIFSA, p_name='miNrNgcFlexInterface'),
    dict(value='5min', dist_name=_MIFSA, p_name='miNrNgInterface'),
]

PARAMS_TO_MODIFY_CB006999_false = [
    dict(value='false', dist_name=_NRBTSname, p_name='actAmfPlannedRemoval'),
    dict(value='0', dist_name=_NRBTSname, p_name='amfPlannedRemovalTimer'),
    dict(value='true', dist_name=_NRBTSname, p_name='actNgcFlexSaMode'),
]

counter_dic_path_6999_A003 = [
    'BTS/CELLS/NRCELL-1/NGCFB', 'BTS/CELLS/NRCELL-1/NGCFB', 'BTS/CELLS/NRCELL-1/NGCFB',
    'BTS/CELLS/NRCELL-1/NGCFB', 'BTS/CELLS/NRCELL-1/NGCFB', 'BTS/CELLS/NRCELL-1/NGCFB'
]
value_counter_6999_A003 = [
    '1', '0', '1', '1', '0', '1'
]
counter_id_6999_A003 = [
    'M55155C00001', 'M55155C00002', 'M55155C00003', 'M55155C00004', 'M55155C00005', 'M55155C00006'
]
