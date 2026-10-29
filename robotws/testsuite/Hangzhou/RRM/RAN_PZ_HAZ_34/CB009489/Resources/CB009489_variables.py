from robot.libraries.BuiltIn import BuiltIn
tl = BuiltIn().get_variable_value("${tl}")

__maintainer__ = 'Ma Keyun'
__team__ = 'I_MN_5G_RAN_IV4_LINE_HZG_3_GMS <I_MN_5G_RAN_IV4_LINE_HZG_3@internal.nsn.com>'
__email__ = 'keyun.ma@nokia.com'

_class_name = 'com.nokia.srbts.mnl:MPLANENW'

_enb_id = str(tl.enbs[0].instance_id)
_gnb_id = str(tl.gnbs[0].instance_id)
_gnb_id2 = str(tl.gnbs[0].instance_id)
_MRBTSname = 'MRBTS-'+_enb_id
_NRBTSname = _MRBTSname+'/NRBTS-'+_gnb_id
_LNBTSname = _MRBTSname+'/LNBTS-'+_enb_id
_NRCELLname = _NRBTSname+'/NRCELL-1'
_NRCELL3name = _NRBTSname+'/NRCELL-3'
_NRDRB15name = _NRBTSname+'/NRDRB-15'
_LNCELLname = _LNBTSname+'/LNCEL-12'
_LNCELL1FDD = _LNCELLname+'/LNCEL_FDD-0'
_NRBTSDUname = _NRBTSname+'/NRDU-1'
_NRBTSDUnameGRPgNB1cell = _NRBTSname+'/NRCELLGRP-1'
_NRPRIOACC_1 = _NRBTSname+'/NRPRIOACC_PROFILE-1'
_SERVEDAMF = _NRBTSname+'/SERVEDAMF-1'

PATH_TO_SCF = ''

PARAMS_TO_MODIFY_CB009489_for_GNB = [
    dict(dist_name=_LNCELLname, parameter='administrativeState', value='locked'),
]
Recover_PARAMS_CB009489 = [
    dict(dist_name=_LNCELLname, parameter='administrativeState', value='unlocked'),
]
