from robot.libraries.BuiltIn import BuiltIn

tl = BuiltIn().get_variable_value("${tl}")

__maintainer__ = 'li xiaodan'
__team__ = 'I_MN_5G_RAN_IV4_LINE_HZG_3_GMS <I_MN_5G_RAN_IV4_LINE_HZG_3@internal.nsn.com>'
__email__ = 'xiaodan.li@nokia-sbell.com'

_gnb_id = str(tl.gnbs[0].instance_id)
_gnb2_id = str(tl.gnbs[1].instance_id)
_MRBTSname = 'MRBTS-'+_gnb_id
_NRBTSname = _MRBTSname+'/NRBTS-'+_gnb_id
_MRBTSname2 = 'MRBTS-'+_gnb2_id
_NRBTSname2 = _MRBTSname2+'/NRBTS-'+_gnb2_id

_class_name = 'com.nokia.srbts.mnl:MPLANENW'

parameter_886_D01 = [
    {'dist_name': '_NRBTSname', 'parameter': 'periodicalDataUsageReportTimer', 'value': '0'},
    {'dist_name': '_NRBTSname', 'parameter': 'actSecDataUsageRep', 'value': 'true'}
]

parameter_886_D13 = [
    {'dist_name': '_NRBTSname', 'parameter': 'periodicalDataUsageReportTimer', 'value': '10'},
    {'dist_name': '_NRBTSname', 'parameter': 'actSecDataUsageRep', 'value': 'true'}
]

parameter_886_D13_GNB2 = [
    {'dist_name': '_NRBTSname2', 'parameter': 'periodicalDataUsageReportTimer', 'value': '10'},
    {'dist_name': '_NRBTSname2', 'parameter': 'actSecDataUsageRep', 'value': 'true'}
]

parameter_886_D13_lock_AMF = [
    {'dist_name': '_NRBTSname2/SERVEDAMF-1', 'parameter': 'administrativeState', 'value': 'Locked'}
]

parameter_886_D13_unlock_AMF = [
    {'dist_name': '_NRBTSname2/SERVEDAMF-1', 'parameter': 'administrativeState', 'value': 'Unlocked'}
]
