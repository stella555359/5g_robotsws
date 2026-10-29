from robot.libraries.BuiltIn import BuiltIn
tl = BuiltIn().get_variable_value("${tl}")

__maintainer__ = 'Xing Jing'
__team__ = 'I_MN_5G_RAN_IV4_LINE_HZG_3_GMS <I_MN_5G_RAN_IV4_LINE_HZG_3@internal.nsn.com>'
__email__ = 'jing.1.xing@nokia-sbell.com'

_class_name = 'com.nokia.srbts.mnl:MPLANENW'

_gnb_id = str(tl.gnbs[0].global_bts_id)
_MRBTSname = 'MRBTS-'+_gnb_id
_NRBTSname = _MRBTSname+'/NRBTS-'+_gnb_id
_NRCELLname = _NRBTSname+'/NRCELL-1'
_NRREDRTname = _NRCELLname+'/NRREDRT-0'
_NRREDRT1name = _NRCELLname+'/NRREDRT-1'

PATH_TO_SCF = ''

PARAM_708_A_002 = [
    dict(new_value='true', dist_name=_NRBTSname,
         filter_param='Activate RRC Connection Release with redirection', abbr='actRedirect'),
    dict(new_value='rsrq', dist_name=_NRCELLname,
         filter_param='A2 Measurement Configuration for Redirection Enabled', abbr='a2MeasRedirectEnabled'),
    dict(new_value='5', dist_name=_NRCELLname,
         filter_param='A2 Hysteresis Ssb Rsrp for Redirection', abbr='a2HysteresisRedirectSsbRsrp'),
    dict(new_value='60', dist_name=_NRCELLname,
         filter_param='A2 Threshold Ssb Rsrp for Redirection', abbr='a2ThresholdRedirectSsbRsrp'),
    dict(new_value='ms128', dist_name=_NRCELLname,
         filter_param='A2 Time To Trigger Ssb Rsrp for Redirection', abbr='a2TimeToTriggerRedirectSsbRsrp'),
    dict(new_value='1', dist_name=_NRCELLname,
         filter_param='A2 Hysteresis Ssb Rsrq for Redirection', abbr='a2HysteresisRedirectSsbRsrq'),
    dict(new_value='90', dist_name=_NRCELLname,
         filter_param='A2Threshold Ssb Rsrq for Redirection', abbr='a2ThresholdRedirectSsbRsrq'),
    dict(new_value='ms128', dist_name=_NRCELLname,
         filter_param='A2 Time To Trigger Ssb Rsrq for Redirection', abbr='a2TimeToTriggerRedirectSsbRsrq')
]

PARAM_708_A_003 = [
    dict(new_value='true', dist_name=_NRBTSname,
         filter_param='Activate RRC Connection Release with redirection', abbr='actRedirect'),
    dict(new_value='rsrpAndRsrq', dist_name=_NRCELLname,
         filter_param='A2 Measurement Configuration for Redirection Enabled', abbr='a2MeasRedirectEnabled'),
    dict(new_value='7', dist_name=_NRCELLname,
         filter_param='A2 Hysteresis Ssb Rsrp for Redirection', abbr='a2HysteresisRedirectSsbRsrp'),
    dict(new_value='60', dist_name=_NRCELLname,
         filter_param='A2 Threshold Ssb Rsrp for Redirection', abbr='a2ThresholdRedirectSsbRsrp'),
    dict(new_value='ms40', dist_name=_NRCELLname,
         filter_param='A2 Time To Trigger Ssb Rsrp for Redirection', abbr='a2TimeToTriggerRedirectSsbRsrp'),
    dict(new_value='3', dist_name=_NRCELLname,
         filter_param='A2 Hysteresis Ssb Rsrq for Redirection', abbr='a2HysteresisRedirectSsbRsrq'),
    dict(new_value='50', dist_name=_NRCELLname,
         filter_param='A2Threshold Ssb Rsrq for Redirection', abbr='a2ThresholdRedirectSsbRsrq'),
    dict(new_value='ms40', dist_name=_NRCELLname,
         filter_param='A2 Time To Trigger Ssb Rsrq for Redirection', abbr='a2TimeToTriggerRedirectSsbRsrq')
]

PARAM_708_A_004 = [
    dict(new_value='true', dist_name=_NRBTSname,
         filter_param='Activate RRC Connection Release with redirection', abbr='actRedirect'),
    dict(new_value='rsrpCombined', dist_name=_NRCELLname,
         filter_param='A2 Measurement Configuration for Redirection Enabled', abbr='a2MeasRedirectEnabled'),
    dict(new_value='9', dist_name=_NRCELLname,
         filter_param='A2 Hysteresis Ssb Rsrp for Redirection', abbr='a2HysteresisRedirectSsbRsrp'),
    dict(new_value='70', dist_name=_NRCELLname,
         filter_param='A2 Threshold Ssb Rsrp for Redirection', abbr='a2ThresholdRedirectSsbRsrp'),
    dict(new_value='ms480', dist_name=_NRCELLname,
         filter_param='A2 Time To Trigger Ssb Rsrp for Redirection', abbr='a2TimeToTriggerRedirectSsbRsrp'),
    dict(new_value='5', dist_name=_NRCELLname,
         filter_param='A2 Hysteresis Ssb Rsrq for Redirection', abbr='a2HysteresisRedirectSsbRsrq'),
    dict(new_value='55', dist_name=_NRCELLname,
         filter_param='A2Threshold Ssb Rsrq for Redirection', abbr='a2ThresholdRedirectSsbRsrq'),
    dict(new_value='ms480', dist_name=_NRCELLname,
         filter_param='A2 Time To Trigger Ssb Rsrq for Redirection', abbr='a2TimeToTriggerRedirectSsbRsrq')
]

PARAM_708_A_005 = [
    dict(new_value='true', dist_name=_NRBTSname,
         filter_param='Activate RRC Connection Release with redirection', abbr='actRedirect'),
    dict(new_value='rsrqCombined', dist_name=_NRCELLname,
         filter_param='A2 Measurement Configuration for Redirection Enabled', abbr='a2MeasRedirectEnabled'),
    dict(new_value='12', dist_name=_NRCELLname,
         filter_param='A2 Hysteresis Ssb Rsrp for Redirection', abbr='a2HysteresisRedirectSsbRsrp'),
    dict(new_value='70', dist_name=_NRCELLname,
         filter_param='A2 Threshold Ssb Rsrp for Redirection', abbr='a2ThresholdRedirectSsbRsrp'),
    dict(new_value='ms64', dist_name=_NRCELLname,
         filter_param='A2 Time To Trigger Ssb Rsrp for Redirection', abbr='a2TimeToTriggerRedirectSsbRsrp'),
    dict(new_value='8', dist_name=_NRCELLname,
         filter_param='A2 Hysteresis Ssb Rsrq for Redirection', abbr='a2HysteresisRedirectSsbRsrq'),
    dict(new_value='55', dist_name=_NRCELLname,
         filter_param='A2Threshold Ssb Rsrq for Redirection', abbr='a2ThresholdRedirectSsbRsrq'),
    dict(new_value='ms64', dist_name=_NRCELLname,
         filter_param='A2 Time To Trigger Ssb Rsrq for Redirection', abbr='a2TimeToTriggerRedirectSsbRsrq')
]

PARAM_708_A_006 = [
    dict(new_value='false', dist_name=_NRBTSname,
         filter_param='Activate RRC Connection Release with redirection', abbr='actRedirect'),
    dict(new_value='rsrqCombined', dist_name=_NRCELLname,
         filter_param='A2 Measurement Configuration for Redirection Enabled', abbr='a2MeasRedirectEnabled'),
    dict(new_value='14', dist_name=_NRCELLname,
         filter_param='A2 Hysteresis Ssb Rsrp for Redirection', abbr='a2HysteresisRedirectSsbRsrp'),
    dict(new_value='70', dist_name=_NRCELLname,
         filter_param='A2 Threshold Ssb Rsrp for Redirection', abbr='a2ThresholdRedirectSsbRsrp'),
    dict(new_value='ms100', dist_name=_NRCELLname,
         filter_param='A2 Time To Trigger Ssb Rsrp for Redirection', abbr='a2TimeToTriggerRedirectSsbRsrp'),
    dict(new_value='12', dist_name=_NRCELLname,
         filter_param='A2 Hysteresis Ssb Rsrq for Redirection', abbr='a2HysteresisRedirectSsbRsrq'),
    dict(new_value='55', dist_name=_NRCELLname,
         filter_param='A2Threshold Ssb Rsrq for Redirection', abbr='a2ThresholdRedirectSsbRsrq'),
    dict(new_value='ms100', dist_name=_NRCELLname,
         filter_param='A2 Time To Trigger Ssb Rsrq for Redirection', abbr='a2TimeToTriggerRedirectSsbRsrq')
]

PARAM_708_B_002 = [
    dict(new_value='rsrq', dist_name=_NRCELLname,
         filter_param='A2 Measurement Configuration for Redirection Enabled', abbr='a2MeasRedirectEnabled'),
    dict(new_value='90', dist_name=_NRCELLname,
         filter_param='A2Threshold Ssb Rsrq for Redirection', abbr='a2ThresholdRedirectSsbRsrq')
]

PARAM_708_B_003 = [
    dict(new_value='rsrpAndRsrq', dist_name=_NRCELLname,
         filter_param='A2 Measurement Configuration for Redirection Enabled', abbr='a2MeasRedirectEnabled'),
    dict(new_value='75', dist_name=_NRCELLname,
         filter_param='A2Threshold Ssb Rsrq for Redirection', abbr='a2ThresholdRedirectSsbRsrq')
]

PARAM_708_B_004 = [
    dict(new_value='rsrpCombined', dist_name=_NRCELLname,
         filter_param='A2 Measurement Configuration for Redirection Enabled', abbr='a2MeasRedirectEnabled'),
    dict(new_value='87', dist_name=_NRCELLname,
         filter_param='A2Threshold Ssb Rsrq for Redirection', abbr='a2ThresholdRedirectSsbRsrq')
]

PARAM_708_B_005 = [
    dict(new_value='rsrqCombined', dist_name=_NRCELLname,
         filter_param='A2 Measurement Configuration for Redirection Enabled', abbr='a2MeasRedirectEnabled'),
    dict(new_value='87', dist_name=_NRCELLname,
         filter_param='A2Threshold Ssb Rsrq for Redirection', abbr='a2ThresholdRedirectSsbRsrq'),
    dict(new_value='r16', dist_name=_NRCELLname,
         filter_param='Report amount', abbr='reportAmount'),
    dict(new_value='ms10240', dist_name=_NRCELLname,
         filter_param='Report interval', abbr='reportInterval')
]

PARAM_708_C_001 = [
    dict(new_value='9999', dist_name=_NRREDRTname,
         filter_param='E-UTRA frequency for Redirection', abbr='redirFreqEutra'),
    dict(new_value='eutra', dist_name=_NRREDRTname,
         filter_param='RAT for Redirection', abbr='redirRat')
]

PARAM_708_C_002 = [
    dict(new_value='612346', dist_name=_NRREDRTname,
         filter_param='NR frequency for Redirection', abbr='redirFreqNr'),
    dict(new_value='nr', dist_name=_NRREDRTname,
         filter_param='RAT for Redirection', abbr='redirRat')
]

PARAM_708_C_003_1 = [
    dict(new_value='rsrp', dist_name=_NRCELLname,
         filter_param='A2 Measurement Configuration for Redirection Enabled', abbr='a2MeasRedirectEnabled'),
    dict(new_value='518910', dist_name=_NRREDRTname,
         filter_param='NR frequency for Redirection', abbr='redirFreqNr'),
    dict(new_value='nr', dist_name=_NRREDRTname,
         filter_param='RAT for Redirection', abbr='redirRat')
]

PARAM_708_C_003_2 = [
    dict(new_value='612346', dist_name=_NRREDRTname,
         filter_param='NR frequency for Redirection', abbr='redirFreqNr'),
    dict(new_value='nr', dist_name=_NRREDRTname,
         filter_param='RAT for Redirection', abbr='redirRat')
]

PARAM_708_C_004_1 = [
    dict(new_value='rsrq', dist_name=_NRCELLname,
         filter_param='A2 Measurement Configuration for Redirection Enabled', abbr='a2MeasRedirectEnabled'),
    dict(new_value='1350', dist_name=_NRREDRTname,
         filter_param='E-UTRA frequency for Redirection', abbr='redirFreqEutra'),
    dict(new_value='eutra', dist_name=_NRREDRTname,
         filter_param='RAT for Redirection', abbr='redirRat'),
    dict(new_value='r16', dist_name=_NRCELLname,
         filter_param='Report amount', abbr='reportAmount'),
    dict(new_value='ms10240', dist_name=_NRCELLname,
         filter_param='Report interval', abbr='reportInterval')
]

PARAM_708_C_004_2 = [
    dict(new_value='rsrq', dist_name=_NRCELLname,
         filter_param='A2 Measurement Configuration for Redirection Enabled', abbr='a2MeasRedirectEnabled'),
    dict(new_value='9876', dist_name=_NRREDRTname,
         filter_param='E-UTRA frequency for Redirection', abbr='redirFreqEutra'),
    dict(new_value='eutra', dist_name=_NRREDRTname,
         filter_param='RAT for Redirection', abbr='redirRat')
]

PARAM_708_D_010 = [
    dict(new_value='true', dist_name=_NRBTSname,
         filter_param='Activate RRC Connection Release with redirection', abbr='actRedirect'),
    dict(new_value='rsrpCombined', dist_name=_NRCELLname,
         filter_param='A2 Measurement Configuration for Redirection Enabled', abbr='a2MeasRedirectEnabled'),
    dict(new_value='75', dist_name=_NRCELLname,
         filter_param='A2Threshold Ssb Rsrq for Redirection', abbr='a2ThresholdRedirectSsbRsrq')
]

PARAM_708_D_011 = [
    dict(new_value='true', dist_name=_NRBTSname,
         filter_param='Activate RRC Connection Release with redirection', abbr='actRedirect'),
    dict(new_value='rsrpCombined', dist_name=_NRCELLname,
         filter_param='A2 Measurement Configuration for Redirection Enabled', abbr='a2MeasRedirectEnabled'),
    dict(new_value='50', dist_name=_NRCELLname,
         filter_param='A2Threshold Ssb Rsrq for Redirection', abbr='a2ThresholdRedirectSsbRsrq')
]

PARAM_708_D_006 = [
    dict(new_value='false', dist_name=_NRBTSname,
         filter_param='Activate RRC Connection Release with redirection', abbr='actRedirect'),
    dict(new_value='rsrqCombined', dist_name=_NRCELLname,
         filter_param='A2 Measurement Configuration for Redirection Enabled', abbr='a2MeasRedirectEnabled'),
    dict(new_value='75', dist_name=_NRCELLname,
         filter_param='A2Threshold Ssb Rsrq for Redirection', abbr='a2ThresholdRedirectSsbRsrq')
]

PARAM_708_D_007 = [
    dict(new_value='rsrp', dist_name=_NRCELLname,
         filter_param='A2 Measurement Configuration for Redirection Enabled', abbr='a2MeasRedirectEnabled')
]

PARAM_708_D_008 = [
    dict(new_value='rsrq', dist_name=_NRCELLname,
         filter_param='A2 Measurement Configuration for Redirection Enabled', abbr='a2MeasRedirectEnabled'),
    dict(new_value='73', dist_name=_NRCELLname,
         filter_param='A2Threshold Ssb Rsrq for Redirection', abbr='a2ThresholdRedirectSsbRsrq'),
    dict(new_value='r16', dist_name=_NRCELLname,
         filter_param='Report amount', abbr='reportAmount'),
    dict(new_value='ms10240', dist_name=_NRCELLname,
         filter_param='Report interval', abbr='reportInterval')
]

PARAM_708_D_009 = [
    dict(new_value='rsrpAndRsrq', dist_name=_NRCELLname,
         filter_param='A2 Measurement Configuration for Redirection Enabled', abbr='a2MeasRedirectEnabled'),
    dict(new_value='73', dist_name=_NRCELLname,
         filter_param='A2Threshold Ssb Rsrq for Redirection', abbr='a2ThresholdRedirectSsbRsrq'),
    dict(new_value='r16', dist_name=_NRCELLname,
         filter_param='Report amount', abbr='reportAmount'),
    dict(new_value='ms10240', dist_name=_NRCELLname,
         filter_param='Report interval', abbr='reportInterval')
]

PARAM_708_Y_001 = [
    dict(new_value='rsrq', dist_name=_NRCELLname,
         filter_param='A2 Measurement Configuration for Redirection Enabled', abbr='a2MeasRedirectEnabled'),
    dict(new_value='60', dist_name=_NRCELLname,
         filter_param='A2 Threshold Ssb Rsrp for Redirection', abbr='a2ThresholdRedirectSsbRsrp')
]


PARAM_708_B_001_1 = [
    dict(value='rsrp', dist_name=_NRCELLname, parameter='a2MeasRedirectEnabled'),
    dict(value='2', dist_name=_NRREDRT1name, parameter='redirPrio'),
    dict(value=[dict(a2HysteresisRedirectSsbRsrp='0', a2ThresholdRedirectSsbRsrp='80',
                     a2TimeToTriggerRedirectSsbRsrp='ms480')],
         dist_name=_NRCELLname, parameter='a2MeasRedirectSsbRsrp')
]

PARAM_708_C_001_1 = [
    dict(value='1', dist_name=_NRREDRTname, parameter='redirPrio'),
    dict(value='9999', dist_name=_NRREDRTname, parameter='redirFreqEutra'),
    dict(value='999999', dist_name=_NRREDRT1name, parameter='redirFreqNr')
]

PARAM_708_C_005_1 = [
    dict(value='1', dist_name=_NRREDRTname, parameter='redirPrio'),
]

PARAM_708_D_010_1 = [
    dict(value='rsrpCombined', dist_name=_NRCELLname, parameter='a2MeasRedirectEnabled'),
    dict(value='2', dist_name=_NRREDRT1name, parameter='redirPrio'),
    dict(value=[dict(a2HysteresisRedirectSsbRsrp='0', a2ThresholdRedirectSsbRsrp='80',
                     a2TimeToTriggerRedirectSsbRsrp='ms480')],
         dist_name=_NRCELLname, parameter='a2MeasRedirectSsbRsrp')
]

AMOUNT_OF_CELLS = 1
