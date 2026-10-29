from robot.libraries.BuiltIn import BuiltIn
tl = BuiltIn().get_variable_value("${tl}")

__maintainer__ = 'Li Xiaodan'
__team__ = 'I_MN_5G_RAN_IV4_LINE_HZG_3_GMS <I_MN_5G_RAN_IV4_LINE_HZG_3@internal.nsn.com>'
__email__ = 'xiaodan.li@nokia-sbell.com'

_class_name = 'com.nokia.srbts.mnl:MPLANENW'

_gnb_id = str(tl.gnbs[0].instance_id)
_MRBTSname = 'MRBTS-'+_gnb_id
_NNRBTSname = 'NRBTS-'+_gnb_id
_NRBTSname = _MRBTSname+'/NRBTS-'+_gnb_id


parameter_actEnhancedLinkAdaptation_false = [
    {'dist_name': '_NRBTSname', 'parameter': 'actEnhancedLinkAdaptation', 'value': 'false'},
]

parameter_actEnhancedLinkAdaptation_true = [
    {'dist_name': '_NRBTSname', 'parameter': 'actEnhancedLinkAdaptation', 'value': 'true'},
    {'dist_name': '_NRBTSname/NRCELL-1', 'parameter': 'dllaDeltaCqiMax', 'value': '10'},
    {'dist_name': '_NRBTSname/NRCELL-1', 'parameter': 'dllaIniMcs', 'value': '3'},
    {'dist_name': '_NRBTSname/NRCELL-1', 'parameter': 'dllaDeltaCqiStepdown', 'value': '10'}
]

parameter_2200_B_004 = [
    {'dist_name': '_NRBTSname', 'parameter': 'actInterRatHoSA', 'value': 'false'}
]
