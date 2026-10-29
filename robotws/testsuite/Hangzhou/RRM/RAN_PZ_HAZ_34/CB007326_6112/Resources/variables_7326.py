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

parameter_CB006112_B_07 = [
    dict(value=[dict(drxInactivityTimer='80ms', drxLongCycle='160ms', drxOnDurationTimer='10ms')],
         dist_name=_NRBTSname+'/NRCELL-1', parameter='drxProfile1'),
    {'dist_name': '_NRBTSname/NRCELL-1', 'parameter': 'actDlLowPAPRoptimizedPrecoding', 'value': 'false'},
    {'dist_name': '_NRBTSname/NRCELL-2', 'parameter': 'actDlLowPAPRoptimizedPrecoding', 'value': 'false'}
]

parameter_CB006112_C_14 = [
    {'dist_name': '_NRBTSname', 'parameter': 'actInterFreqHoSA', 'value': 'true'},
    {'dist_name': '_NRBTSname/NRCELL-1', 'parameter': 'actVoNrMobilityThresholds', 'value': 'VoNrMobilityThresholds'},
    {'dist_name': '_NRBTSname/NRCELL-2', 'parameter': 'actVoNrMobilityThresholds', 'value': 'VoNrMobilityThresholds'},
    dict(value=[dict(a2ThresholdhoSsbRsrpSA='100', a2ThresholdHoSsbRsrpVoNr='100')],
         dist_name=_NRBTSname+'/NRCELL-1', parameter='a2MeashoSsbRsrpSA'),
    {'dist_name': '_NRBTSname/NRCELL-1', 'parameter': 'freqBandIndicatorNR', 'value': '77'},
    {'dist_name': '_NRBTSname/NRCELL-2', 'parameter': 'freqBandIndicatorNR', 'value': '77'},
    {'dist_name': '_NRBTSname/NRCELL-1', 'parameter': 'nrarfcn', 'value': '650000'},
    {'dist_name': '_NRBTSname/NRCELL-2', 'parameter': 'nrarfcn', 'value': '656666'},
    {'dist_name': '_NRBTSname/NRCELL-1', 'parameter': 'gscnOrSsPbchArfcn', 'value': '8020'},
    {'dist_name': '_NRBTSname/NRCELL-2', 'parameter': 'gscnOrSsPbchArfcn', 'value': '8089'},
    {'dist_name': '_NRBTSname/NRCELL-1/NRHOIF-1', 'parameter': 'freqBandIndicatorNR', 'value': '77'},
    {'dist_name': '_NRBTSname/NRCELL-2/NRHOIF-1', 'parameter': 'freqBandIndicatorNR', 'value': '77'},
    {'dist_name': '_NRBTSname/NRCELL-1/NRHOIF-1', 'parameter': 'ssbFrequency', 'value': '656640'},
    {'dist_name': '_NRBTSname/NRCELL-2/NRHOIF-1', 'parameter': 'ssbFrequency', 'value': '650016'}
]

parameter_CB006112_C_20 = [
    {'dist_name': '_NRBTSname/NRCELL-1', 'parameter': 'pMax', 'value': '300'},
    {'dist_name': '_NRBTSname/NRCELL-1', 'parameter': 'dlQam256PowerBackoffSub6', 'value': '30'},
    {'dist_name': '_NRBTSname/NRCELL-2', 'parameter': 'actDlLowPAPRoptimizedPrecoding', 'value': 'false'}
]
