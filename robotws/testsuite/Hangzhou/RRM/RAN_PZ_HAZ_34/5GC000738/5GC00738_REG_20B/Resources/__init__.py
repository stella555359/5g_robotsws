import os
from robot.libraries.BuiltIn import BuiltIn

tl = BuiltIn().get_variable_value("${tl}")
CFG_DIR = os.path.dirname(os.path.abspath(__file__))

_gnb_id = str(tl.gnbs[0].instance_id)
_MRBTSname = 'MRBTS-'+_gnb_id
_NRBTSname = 'MRBTS-'+_gnb_id+'/NRBTS-1'
_NRCELLname = _NRBTSname+'/NRCELL-1'
_BTSPLMN1 = _NRBTSname+'/NRPLMN-1'
_BTSPLMN2 = _NRBTSname+'/NRPLMN-2'
_NRPMRNL = _NRBTSname+'/NRPMRNL-1'
_PLMN = _NRCELLname+'/NRPLMNSET_NSA-1'

PARAMS_TO_MODIFY_FEATURE_A005_20B = [
    dict(value=_BTSPLMN2, dist_name=_PLMN, list_name='nrPlmnDNList', index='0'),
]

PARAMS_TO_MODIFY_FEATURE_B001_19B = [
    dict(value='5min', dist_name=_NRPMRNL, p_name='miNrRANS'),
]
