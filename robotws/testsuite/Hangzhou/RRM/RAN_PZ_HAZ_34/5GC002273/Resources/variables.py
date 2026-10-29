from robot.libraries.BuiltIn import BuiltIn

tl = BuiltIn().get_variable_value("${tl}")

__maintainer__ = 'zhang qingqing'
__team__ = 'I_MN_5G_RAN_IV4_LINE_HZG_3_GMS <I_MN_5G_RAN_IV4_LINE_HZG_3@internal.nsn.com>'
__email__ = 'qingqing.zhang@nokia-sbell.com'

_gnb_id = str(tl.gnbs[0].instance_id)
_MRBTSname = 'MRBTS-'+_gnb_id
_NRBTSname = _MRBTSname+'/NRBTS-'+_gnb_id

_class_name = 'com.nokia.srbts.mnl:MPLANENW'

PARAMETERS_TO_actDl256Qam_false = [
    {'dist_name': '_MRBTSname/_NRBTSname/NRCELL-1', 'parameter': 'actDl256Qam', 'value': 'false'}
]

PARAMETERS_TO_actDl256Qam_true = [
    {'dist_name': '_MRBTSname/_NRBTSname/NRCELL-1', 'parameter': 'actDl256Qam', 'value': 'true'}
]

PARAMETERS_TO_shutdownNoXnTrafficTmr_default = [
    {'dist_name': '_MRBTSname/_NRBTSname', 'parameter': 'shutdownNoXnTrafficTmr', 'value': '24'}
]
