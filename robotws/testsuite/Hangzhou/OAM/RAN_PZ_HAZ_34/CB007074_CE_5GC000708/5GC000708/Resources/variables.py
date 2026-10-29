from robot.libraries.BuiltIn import BuiltIn

tl = BuiltIn().get_variable_value("${tl}")

__maintainer__ = "Xing Jing"
__team__ = (
    "I_MN_5G_RAN_IV4_LINE_HZG_3_GMS <I_MN_5G_RAN_IV4_LINE_HZG_3@internal.nsn.com>"
)
__email__ = "jing.1.xing@nokia-sbell.com"

_class_name = "com.nokia.srbts.mnl:MPLANENW"

_gnb_id = str(tl.gnbs[0].instance_id)
_MRBTSname = "MRBTS-" + _gnb_id
_NRBTSname = _MRBTSname + "/NRBTS-" + _gnb_id
_NRCELLname = _NRBTSname + "/NRCELL-1"
_NRREDRTname = _NRCELLname + "/NRREDRT-0"
_NRREDRT1name = _NRCELLname + "/NRREDRT-1"

PATH_TO_SCF = ""
PARAM_708_D_010_1 = [
    dict(
        value="rsrpCombined", dist_name=_NRCELLname, parameter="a2MeasRedirectEnabled"
    ),
    dict(value="2", dist_name=_NRREDRT1name, parameter="redirPrio"),
    dict(value="636220", dist_name=_NRREDRT1name, parameter="redirFreqNr"),
    dict(value="9999", dist_name=_NRREDRTname, parameter="redirFreqEutra"),
    dict(
        value=[
            dict(
                a2HysteresisRedirectSsbRsrp="0",
                a2ThresholdRedirectSsbRsrp="110",
                a2TimeToTriggerRedirectSsbRsrp="ms480",
            )
        ],
        dist_name=_NRCELLname,
        parameter="a2MeasRedirectSsbRsrp",
    ),
    dict(
        value=[
            dict(
                a2HysteresisRedirectSsbRsrq="0",
                a2ThresholdRedirectSsbRsrq="110",
                a2TimeToTriggerRedirectSsbRsrq="ms480",
            )
        ],
        dist_name=_NRCELLname,
        parameter="a2MeasRedirectSsbRsrq",
    ),
]
PARAM_708_C_001_1 = [
    dict(value="1", dist_name=_NRREDRTname, parameter="redirPrio"),
    dict(value="9999", dist_name=_NRREDRTname, parameter="redirFreqEutra"),
    dict(value="999999", dist_name=_NRREDRT1name, parameter="redirFreqNr"),
]

PARAM_708_Y_001 = [
    dict(
        new_value="rsrq",
        dist_name=_NRCELLname,
        filter_param="A2 Measurement Configuration for Redirection Enabled",
        abbr="a2MeasRedirectEnabled",
    ),
    dict(
        new_value="120",
        dist_name=_NRCELLname,
        filter_param="A2 Threshold Ssb Rsrp for Redirection",
        abbr="a2ThresholdRedirectSsbRsrp",
    ),
]
PARAM_708_B_001_1 = [
    dict(value="rsrp", dist_name=_NRCELLname, parameter="a2MeasRedirectEnabled"),
    dict(value="2", dist_name=_NRREDRT1name, parameter="redirPrio"),
    dict(value="636220", dist_name=_NRREDRT1name, parameter="redirFreqNr"),
    dict(value="9999", dist_name=_NRREDRTname, parameter="redirFreqEutra"),
    dict(
        value=[
            dict(
                a2HysteresisRedirectSsbRsrp="0",
                a2ThresholdRedirectSsbRsrp="120",
                a2TimeToTriggerRedirectSsbRsrp="ms480",
            )
        ],
        dist_name=_NRCELLname,
        parameter="a2MeasRedirectSsbRsrp",
    ),
]

PARAM_708_C_005_1 = [
    dict(value="1", dist_name=_NRREDRTname, parameter="redirPrio"),
    dict(value="2500", dist_name=_NRREDRTname, parameter="redirFreqEutra"),
]
AMOUNT_OF_CELLS = 1
