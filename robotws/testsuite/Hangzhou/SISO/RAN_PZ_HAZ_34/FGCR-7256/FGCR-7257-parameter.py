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
_AMF1GNB1 = _NRBTSname+'/SERVEDAMF-1'


_gnb2_id = str(tl.gnbs[1].instance_id)
_MRBTSname2 = 'MRBTS-'+_gnb2_id
_NRBTSname2 = _MRBTSname2+'/NRBTS-'+_gnb2_id
_AMF1GNB2 = _NRBTSname2+'/SERVEDAMF-1'
_AMF2GNB2 = _NRBTSname2+'/SERVEDAMF-2'
_AMF3GNB2 = _NRBTSname2+'/SERVEDAMF-3'
_NRBTS2_ID = 'NRBTS-'+_gnb2_id

PARAMS_TO_MODIFY_80M = [
    dict(value='80Mhz', dist_name=_NRCELLname1, p_name='chBw'),
]

Lock_gnb2_AMF1 = [
    dict(value='Locked', dist_name=_AMF1GNB2, parameter='administrativeState'),
]

Unlock_gnb2_AMF1 = [
    dict(value='Unlocked', dist_name=_AMF1GNB2, parameter='administrativeState'),
]
