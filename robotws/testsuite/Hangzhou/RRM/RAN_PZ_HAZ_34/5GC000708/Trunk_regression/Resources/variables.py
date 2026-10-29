from robot.libraries.BuiltIn import BuiltIn
tl = BuiltIn().get_variable_value("${tl}")

__maintainer__ = 'Xing Jing'
__team__ = 'I_MN_5G_RAN_IV4_LINE_HZG_3_GMS <I_MN_5G_RAN_IV4_LINE_HZG_3@internal.nsn.com>'
__email__ = 'jing.1.xing@nokia-sbell.com'

_class_name = 'com.nokia.srbts.mnl:MPLANENW'

_gnb_id = str(tl.gnbs[1].instance_id)
_MRBTSname = 'MRBTS-'+_gnb_id
_NRBTSname = _MRBTSname+'/NRBTS-'+_gnb_id
_NRCELLname = _NRBTSname+'/NRCELL-1'
_NRREDRTname = _NRCELLname+'/NRREDRT-0'
_NRREDRT1name = _NRCELLname+'/NRREDRT-1'

_gnb0_id = str(tl.gnbs[0].instance_id)
_MRBTS0name = 'MRBTS-'+_gnb0_id
_NRBTS0name = _MRBTSname+'/NRBTS-'+_gnb0_id
_NRCELL0name = _NRBTS0name+'/NRCELL-1'
_NRCELL1name = _NRBTS0name+'/NRCELL-2'

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

PARAM_708_B_003 = [
    dict(new_value='rsrpAndRsrq', dist_name=_NRCELLname,
         filter_param='A2 Measurement Configuration for Redirection Enabled', abbr='a2MeasRedirectEnabled'),
    dict(new_value='65', dist_name=_NRCELLname,
         filter_param='A2 Threshold Ssb Rsrp for Redirection', abbr='a2ThresholdRedirectSsbRsrp'),
    dict(new_value='120', dist_name=_NRCELLname,
         filter_param='A2Threshold Ssb Rsrq for Redirection', abbr='a2ThresholdRedirectSsbRsrq')
]

PARAM_708_B_004 = [
    dict(new_value='rsrpCombined', dist_name=_NRCELLname,
         filter_param='A2 Measurement Configuration for Redirection Enabled', abbr='a2MeasRedirectEnabled'),
    dict(new_value='65', dist_name=_NRCELLname,
         filter_param='A2 Threshold Ssb Rsrp for Redirection', abbr='a2ThresholdRedirectSsbRsrp'),
    dict(new_value='120', dist_name=_NRCELLname,
         filter_param='A2Threshold Ssb Rsrq for Redirection', abbr='a2ThresholdRedirectSsbRsrq')
]

PARAM_708_C_001 = [
    dict(new_value='9876', dist_name=_NRREDRTname,
         filter_param='E-UTRA frequency for Redirection', abbr='redirFreqEutra'),
    dict(new_value='eutra', dist_name=_NRREDRTname,
         filter_param='RAT for Redirection', abbr='redirRat')
]

PARAM_708_C_002 = [
    dict(new_value='rsrp', dist_name=_NRCELLname,
         filter_param='A2 Measurement Configuration for Redirection Enabled', abbr='a2MeasRedirectEnabled'),
    dict(new_value='120', dist_name=_NRCELLname,
         filter_param='A2Threshold Ssb Rsrq for Redirection', abbr='a2ThresholdRedirectSsbRsrq'),
    dict(new_value='612346', dist_name=_NRREDRTname,
         filter_param='NR frequency for Redirection', abbr='redirFreqNr'),
    dict(new_value='nr', dist_name=_NRREDRTname,
         filter_param='RAT for Redirection', abbr='redirRat')
]

PARAM_708_D_010 = [
    dict(new_value='true', dist_name=_NRBTSname,
         filter_param='Activate RRC Connection Release with redirection', abbr='actRedirect'),
    dict(new_value='rsrpCombined', dist_name=_NRCELLname,
         filter_param='A2 Measurement Configuration for Redirection Enabled', abbr='a2MeasRedirectEnabled'),
    dict(new_value='77', dist_name=_NRCELLname,
         filter_param='A2 Threshold Ssb Rsrp for Redirection', abbr='a2ThresholdRedirectSsbRsrp'),
    dict(new_value='120', dist_name=_NRCELLname,
         filter_param='A2 Threshold Ssb Rsrq for Redirection', abbr='a2ThresholdRedirectSsbRsrq')
]

PARAM_708_D_007 = [
    dict(new_value='rsrp', dist_name=_NRCELLname,
         filter_param='A2 Measurement Configuration for Redirection Enabled', abbr='a2MeasRedirectEnabled'),
    dict(new_value='65', dist_name=_NRCELLname,
         filter_param='A2 Threshold Ssb Rsrp for Redirection', abbr='a2ThresholdRedirectSsbRsrp'),
    dict(new_value='20', dist_name=_NRCELLname,
         filter_param='A2Threshold Ssb Rsrq for Redirection', abbr='a2ThresholdRedirectSsbRsrq')
]

PARAM_708_Y_001 = [
    dict(new_value='rsrq', dist_name=_NRCELLname,
         filter_param='A2 Measurement Configuration for Redirection Enabled', abbr='a2MeasRedirectEnabled'),
    dict(new_value='60', dist_name=_NRCELLname,
         filter_param='A2 Threshold Ssb Rsrp for Redirection', abbr='a2ThresholdRedirectSsbRsrp')
]

PARAM_708_C_005 = [
    dict(value='1', dist_name=_NRREDRTname, parameter='redirPrio'),
    dict(value='5', dist_name=_NRREDRT1name, parameter='redirPrio')
]

PARAMS_TO_MODIFY_LOCKG1 = [
    dict(
        value='Locked',
        dist_name=_NRCELL0name,
        parameter='administrativeState')
]

PARAMS_TO_MODIFY_UNLOCKG1 = [
    dict(
        value='Unlocked',
        dist_name=_NRCELL0name,
        parameter='administrativeState')
]

PARAMS_TO_MODIFY_LOCKG01 = [
    dict(
        value='Locked',
        dist_name=_NRCELL0name,
        parameter='administrativeState'),
    dict(
        value='Locked',
        dist_name=_NRCELL1name,
        parameter='administrativeState')
]

PARAMS_TO_MODIFY_UNLOCKG01 = [
    dict(
        value='Unlocked',
        dist_name=_NRCELL0name,
        parameter='administrativeState'),
    dict(
        value='Unlocked',
        dist_name=_NRCELL1name,
        parameter='administrativeState')
]

AMOUNT_OF_CELLS = 1
