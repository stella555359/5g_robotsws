from robot.libraries.BuiltIn import BuiltIn
tl = BuiltIn().get_variable_value("${tl}")

__maintainer__ = 'zhang qingqing'
__team__ = 'I_MN_5G_RAN_IV4_LINE_HZG_3_GMS <I_MN_5G_RAN_IV4_LINE_HZG_3@internal.nsn.com>'
__email__ = 'yifan.hu@nokia-sbell.com'

_class_name = 'com.nokia.srbts.mnl:MPLANENW'

_gnb_id = str(tl.gnbs[0].instance_id)
_MRBTSname = 'MRBTS-'+_gnb_id
_NNRBTSname = 'NRBTS-'+_gnb_id
_NRBTSname = _MRBTSname+'/NRBTS-'+_gnb_id


PARAMETERS_TO_UPDATE_pre = [
    {'dist_name': '_NRBTSname/NRCELL-2', 'parameter': 'maxNumOfCaUsersNRCell', 'value': '1'},
    {'dist_name': '_NRBTSname/NRCELL-2', 'parameter': 'maxNumOfRrcSA', 'value': '1'},
    {'dist_name': '_NRBTSname/NRCELL-2', 'parameter': 'maxNumOfSCellAlloc', 'value': '1'},
    {'dist_name': '_NRBTSname/NRCELL-2', 'parameter': 'maxNumOfUsersNRCell', 'value': '1'},
    {'dist_name': '_NRBTSname/NRCELL-2', 'parameter': 'maxNumOfUsersPerCell', 'value': '1'},
    {'dist_name': '_NRBTSname/NRCELLGRP-1', 'parameter': 'maxNumOfRrcCGRPSA', 'value': '1'}
]

PARAMETERS_TO_UPDATE_recover = [
    {'dist_name': '_NRBTSname/NRCELL-2', 'parameter': 'maxNumOfCaUsersNRCell', 'value': '250'},
    {'dist_name': '_NRBTSname/NRCELL-2', 'parameter': 'maxNumOfRrcSA', 'value': '275'},
    {'dist_name': '_NRBTSname/NRCELL-2', 'parameter': 'maxNumOfSCellAlloc', 'value': '250'},
    {'dist_name': '_NRBTSname/NRCELL-2', 'parameter': 'maxNumOfUsersNRCell', 'value': '275'},
    {'dist_name': '_NRBTSname/NRCELL-2', 'parameter': 'maxNumOfUsersPerCell', 'value': '275'},
    {'dist_name': '_NRBTSname/NRCELLGRP-1', 'parameter': 'maxNumOfRrcCGRPSA', 'value': '275'}
]

PARAMETERS_TO_UPDATE_b12 = [
    {'dist_name': '_NRBTSname', 'parameter': 'actRedirect', 'value': 'true'},
    {'dist_name': '_NRBTSname', 'parameter': 'actNormVCFallback', 'value': 'true'},
    {'dist_name': '_NRBTSname/NRCELL-1', 'parameter': 'voiceFBMode', 'value': 'redirection'},
    {'dist_name': '_NRBTSname/NRCELL-1/NRREDRT-1', 'parameter': 'redirRat', 'value': 'eutra'}
]

PARAMETERS_TO_UPDATE_b12_recover = [
    {'dist_name': '_NRBTSname', 'parameter': 'actRedirect', 'value': 'false'},
    {'dist_name': '_NRBTSname', 'parameter': 'actNormVCFallback', 'value': 'false'},
    {'dist_name': '_NRBTSname/NRCELL-1', 'parameter': 'voiceFBMode', 'value': 'disabled'}
]
