from robot.libraries.BuiltIn import BuiltIn
tl = BuiltIn().get_variable_value("${tl}")

__maintainer__ = 'Hu Yifan'
__team__ = 'I_MN_5G_RAN_IV4_LINE_HZG_3_GMS <I_MN_5G_RAN_IV4_LINE_HZG_3@internal.nsn.com>'
__email__ = 'yifan.hu@nokia-sbell.com'

_class_name = 'com.nokia.srbts.mnl:MPLANENW'

_gnb_id = str(tl.gnbs[0].instance_id)
_MRBTSname = 'MRBTS-'+_gnb_id
_NNRBTSname = 'NRBTS-'+_gnb_id
_NRBTSname = _MRBTSname+'/NRBTS-'+_gnb_id


PARAMETERS_TO_UPDATE_pre = [
    {'dist_name': '_NRBTSname', 'parameter': 'srbInactivityTimerSA', 'value': '10'},
    {'dist_name': '_NRBTSname', 'parameter': 'drbInactivityTimerSA', 'value': '10'}
]

PARAMETERS_TO_UPDATE_recover = [
    {'dist_name': '_NRBTSname', 'parameter': 'srbInactivityTimerSA', 'value': '60'},
    {'dist_name': '_NRBTSname', 'parameter': 'drbInactivityTimerSA', 'value': '500'}
]
