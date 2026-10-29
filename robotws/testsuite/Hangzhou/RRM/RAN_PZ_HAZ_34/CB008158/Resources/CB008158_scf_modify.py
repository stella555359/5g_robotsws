from robot.libraries.BuiltIn import BuiltIn

tl = BuiltIn().get_variable_value("${tl}")

_gnb_id = str(tl.gnbs[0].global_bts_id)
_bts_id = str(tl.gnbs[0].instance_id)
_MRBTSname = 'MRBTS-'+_gnb_id
_NRBTSname = _MRBTSname+'/NRBTS-'+_bts_id
_NRPMRNL = _NRBTSname+'/NRPMRNL-1'
_PMCADM = _MRBTSname + '/MNL-1' + '/MNLENT-1' + '/PMCADM-1'
MR_NR_CELL_NAME = _NRBTSname + '/NRCELL-1'
MR_NR_BTS_NAME = _NRBTSname

_NRPMQAP7 = _NRPMRNL+'/NRPMQAP-7'
_NRPMQAP4 = _NRPMRNL+'/NRPMQAP-4'
_NRPMQAP17 = _NRPMRNL+'/NRPMQAP-17'
_NRPMQAP1 = _NRPMRNL+'/NRPMQAP-1'
_NRPMQAP2 = _NRPMRNL+'/NRPMQAP-2'
_NRPMQAP8 = _NRPMRNL+'/NRPMQAP-8'
_PMCADM = _MRBTSname+'/MNL-1'+'/MNLENT-1'+'/PMCADM-1'

PARAMETERS_TO_CB008158_SA_enable = [
    dict(
        value='true',
        dist_name=_NRBTSname,
        p_name='actLatencyPmCount'),
    dict(
        value='false',
        dist_name=_NRBTSname,
        p_name='actNrpmqapProfiles'),
    dict(
        value='true',
        dist_name=_NRBTSname,
        p_name='actSACallProcessingDU'),
    dict(
        value='5min',
        dist_name=_NRPMRNL,
        p_name='miNrLowRlcReport'),
    dict(
        value='5min',
        dist_name=_NRPMRNL,
        p_name='miNrHighRlcLatNrpmqap'),
    dict(
        value='5min',
        dist_name=_NRPMRNL,
        p_name='miNrPDCPCell'),
    dict(
        value='5min',
        dist_name=_NRPMRNL,
        p_name='miNrPdcpLatNrpmqap'),
    dict(
        value='5min',
        dist_name=_NRPMRNL,
        p_name='miNrCellUtilization'),
    dict(
        value='5min',
        dist_name=_NRPMRNL,
        p_name='miNrUeStatNrpmqap'),
    dict(
        value='5min',
        dist_name=_NRPMRNL,
        p_name='miNrNgUReport'),
    dict(
        value='5min',
        dist_name=_NRPMRNL,
        p_name='miNrPDCP1Report'),
    dict(
        value='false',
        dist_name=_NRBTSname,
        p_name='actIpThpt'),
    dict(
        value='false',
        dist_name=_NRBTSname,
        p_name='actThpDist'),
    dict(
        value='5min',
        dist_name=_PMCADM,
        p_name='reportingIntervalPm'),
    dict(
        value='5min',
        dist_name=_NRPMRNL,
        p_name='miNrHighRlcCell'),
    dict(
        value='5min',
        dist_name=_NRPMRNL,
        p_name='miNrHighRlcLatNrpmqap'),
]

PARAMETERS_TO_CB008158_NSA_enable = [
    dict(
        value='true',
        dist_name=_NRBTSname,
        p_name='actLatencyPmCount'),
    dict(
        value='true',
        dist_name=_NRBTSname,
        p_name='actNrpmqapProfiles'),
    dict(
        value='false',
        dist_name=_NRBTSname,
        p_name='actSACallProcessingDU'),
    dict(
        value='5min',
        dist_name=_NRPMRNL,
        p_name='miNrLowRlcReport'),
    dict(
        value='5min',
        dist_name=_NRPMRNL,
        p_name='miNrHighRlcLatNrpmqap'),
    dict(
        value='5min',
        dist_name=_NRPMRNL,
        p_name='miNrPDCPCell'),
    dict(
        value='5min',
        dist_name=_NRPMRNL,
        p_name='miNrPdcpLatNrpmqap'),
    dict(
        value='5min',
        dist_name=_NRPMRNL,
        p_name='miNrCellUtilization'),
    dict(
        value='5min',
        dist_name=_NRPMRNL,
        p_name='miNrUeStatNrpmqap'),
    dict(
        value='5min',
        dist_name=_NRPMRNL,
        p_name='miNrNgUReport'),
    dict(
        value='5min',
        dist_name=_NRPMRNL,
        p_name='miNrPDCP1Report'),
    dict(
        value='false',
        dist_name=_NRBTSname,
        p_name='actIpThpt'),
    dict(
        value='false',
        dist_name=_NRBTSname,
        p_name='actThpDist'),
    dict(
        value='5min',
        dist_name=_PMCADM,
        p_name='reportingIntervalPm'),
    dict(
        value='5min',
        dist_name=_NRPMRNL,
        p_name='miNrHighRlcCell'),
    dict(
        value='5min',
        dist_name=_NRPMRNL,
        p_name='miNrHighRlcLatNrpmqap'),
]
PARAMETERS_TO_CB008158_actNrpmqapProfiles_enable = [
    {'dist_name': '_NRBTSname', 'parameter': 'actNrpmqapProfiles', 'value': 'true'},
]
PARAMETERS_TO_CB008158_actNrpmqapProfiles_disable = [
    {'dist_name': '_NRBTSname', 'parameter': 'actNrpmqapProfiles', 'value': 'false'},
]
PARAMETERS_TO_CB008158_pmqap_add_7 = [
    dict(value='true', dist_name=_NRPMQAP7, parameter='actCplaneCounters'),
    dict(value='true', dist_name=_NRPMQAP7, parameter='actUPlaneGroup1Counters'),
    dict(value='true', dist_name=_NRPMQAP7, parameter='actUPlaneGroup2Counters'),
    dict(value='SA', dist_name=_NRPMQAP7, parameter='cfgProfType'),
    dict(value='7', dist_name=_NRPMQAP7, parameter='nrPmqapId'),
    dict(value='2000', dist_name=_NRPMQAP7, parameter='rlcAmSduDlDelayThresh'),
    dict(value='7', dist_name=_NRPMQAP7, parameter='cfg5qiRange'),
]

PARAMETERS_TO_CB008158_pmqap_add_8 = [
    dict(value='true', dist_name=_NRPMQAP8, parameter='actCplaneCounters'),
    dict(value='true', dist_name=_NRPMQAP8, parameter='actUPlaneGroup1Counters'),
    dict(value='true', dist_name=_NRPMQAP8, parameter='actUPlaneGroup2Counters'),
    dict(value='SA', dist_name=_NRPMQAP8, parameter='cfgProfType'),
    dict(value='8', dist_name=_NRPMQAP8, parameter='nrPmqapId'),
    dict(value='2000', dist_name=_NRPMQAP8, parameter='rlcAmSduDlDelayThresh'),
    dict(value='8', dist_name=_NRPMQAP8, parameter='cfg5qiRange'),
]
PARAMETERS_TO_CB008158_pmqap_add_4 = [
    dict(value='true', dist_name=_NRPMQAP4, parameter='actCplaneCounters'),
    dict(value='true', dist_name=_NRPMQAP4, parameter='actUPlaneGroup1Counters'),
    dict(value='true', dist_name=_NRPMQAP4, parameter='actUPlaneGroup2Counters'),
    dict(value='SA', dist_name=_NRPMQAP4, parameter='cfgProfType'),
    dict(value='4', dist_name=_NRPMQAP4, parameter='nrPmqapId'),
    dict(value='2000', dist_name=_NRPMQAP4, parameter='rlcAmSduDlDelayThresh'),
    dict(value='4', dist_name=_NRPMQAP4, parameter='cfg5qiRange'),
]
PARAMETERS_TO_CB008158_pmqap_add_5 = [
    dict(value='true', dist_name=_NRPMQAP4, parameter='actCplaneCounters'),
    dict(value='true', dist_name=_NRPMQAP4, parameter='actUPlaneGroup1Counters'),
    dict(value='true', dist_name=_NRPMQAP4, parameter='actUPlaneGroup2Counters'),
    dict(value='SA', dist_name=_NRPMQAP4, parameter='cfgProfType'),
    dict(value='5', dist_name=_NRPMQAP4, parameter='nrPmqapId'),
    dict(value='2000', dist_name=_NRPMQAP4, parameter='rlcAmSduDlDelayThresh'),
    dict(value='5', dist_name=_NRPMQAP4, parameter='cfg5qiRange'),
]
PARAMETERS_TO_CB008158_pmqap_update_4 = [
    dict(value='7', dist_name=_NRPMQAP4, parameter='cfg5qiRange'),
]
PARAMETERS_TO_CB008158_pmqap_add_2 = [
    dict(value='true', dist_name=_NRPMQAP2, parameter='actCplaneCounters'),
    dict(value='true', dist_name=_NRPMQAP2, parameter='actUPlaneGroup1Counters'),
    dict(value='true', dist_name=_NRPMQAP2, parameter='actUPlaneGroup2Counters'),
    dict(value='SA', dist_name=_NRPMQAP2, parameter='cfgProfType'),
    dict(value='2', dist_name=_NRPMQAP2, parameter='nrPmqapId'),
    dict(value='2000', dist_name=_NRPMQAP2, parameter='rlcAmSduDlDelayThresh'),
    dict(value='1', dist_name=_NRPMQAP2, parameter='cfg5qiRange'),
]
PARAMETERS_TO_CB008158_pmqap_add_17_SBTS00 = [
    dict(value='true', dist_name=_NRPMQAP17, parameter='actCplaneCounters'),
    dict(value='true', dist_name=_NRPMQAP17, parameter='actUPlaneGroup1Counters'),
    dict(value='true', dist_name=_NRPMQAP17, parameter='actUPlaneGroup2Counters'),
    dict(value='NSA', dist_name=_NRPMQAP17, parameter='cfgProfType'),
    dict(value='17', dist_name=_NRPMQAP17, parameter='nrPmqapId'),
    dict(value='2000', dist_name=_NRPMQAP17, parameter='rlcAmSduDlDelayThresh'),
    dict(value='5-9', dist_name=_NRPMQAP17, parameter='cfgQciRange'),
]
PARAMETERS_TO_CB008158_pmqap_add_17_SBTS25R3 = [
    dict(value='true', dist_name=_NRPMQAP17, parameter='actCplaneCounters'),
    dict(value='true', dist_name=_NRPMQAP17, parameter='actUPlaneGroup1Counters'),
    dict(value='true', dist_name=_NRPMQAP17, parameter='actUPlaneGroup2Counters'),
    dict(value='NSA', dist_name=_NRPMQAP17, parameter='cfgProfType'),
    dict(value='17', dist_name=_NRPMQAP17, parameter='nrPmqapId'),
    dict(value='2000', dist_name=_NRPMQAP17, parameter='rlcAmSduDlDelayThresh'),
    dict(value='5-9', dist_name=_NRPMQAP17, parameter='cfgQciRange'),
]
PARAMETERS_TO_CB008158_pmqap_add_17_SBTS25R2 = [
    dict(value='true', dist_name=_NRPMQAP17, parameter='actCplaneCounters'),
    dict(value='true', dist_name=_NRPMQAP17, parameter='actUPlaneGroup1Counters'),
    dict(value='true', dist_name=_NRPMQAP17, parameter='actUPlaneGroup2Counters'),
    dict(value='NSA', dist_name=_NRPMQAP17, parameter='cfgProfType'),
    dict(value='17', dist_name=_NRPMQAP17, parameter='nrPmqapId'),
    dict(value='2000', dist_name=_NRPMQAP17, parameter='rlcAmSduDlDelayThresh'),
    dict(value='5-9', dist_name=_NRPMQAP17, parameter='cfgQciRange'),
]
PARAMETERS_TO_CB008158_pmqap_add_17_SBTS24R3 = [
    dict(value='NSA', dist_name=_NRPMQAP17, parameter='cfgProfType'),
    dict(value='17', dist_name=_NRPMQAP17, parameter='nrPmqapId'),
    dict(value='2000', dist_name=_NRPMQAP17, parameter='rlcAmSduDlDelayThresh'),
    dict(value='5-9', dist_name=_NRPMQAP17, parameter='cfgQciRange'),
]
PARAMETERS_TO_CB008158_pmqap_add_17_SBTS25R1 = [
    dict(value='true', dist_name=_NRPMQAP17, parameter='actCplaneCounters'),
    dict(value='true', dist_name=_NRPMQAP17, parameter='actUPlaneGroup1Counters'),
    dict(value='true', dist_name=_NRPMQAP17, parameter='actUPlaneGroup2Counters'),
    dict(value='NSA', dist_name=_NRPMQAP17, parameter='cfgProfType'),
    dict(value='17', dist_name=_NRPMQAP17, parameter='nrPmqapId'),
    dict(value='2000', dist_name=_NRPMQAP17, parameter='rlcAmSduDlDelayThresh'),
    dict(value='5-9', dist_name=_NRPMQAP17, parameter='cfgQciRange'),
]
PARAMETERS_TO_CB008158_rlcAmSduDlDelayThresh_modify = [
    dict(value='3000000', dist_name=_NRPMQAP7, parameter='rlcAmSduDlDelayThresh'),
    dict(value='0', dist_name=_NRPMQAP8, parameter='rlcAmSduDlDelayThresh'),
]
PARAMETERS_TO_CB008158_pmqap_add_1 = [
    dict(value='true', dist_name=_NRPMQAP1, parameter='actCplaneCounters'),
    dict(value='true', dist_name=_NRPMQAP1, parameter='actUPlaneGroup1Counters'),
    dict(value='true', dist_name=_NRPMQAP1, parameter='actUPlaneGroup2Counters'),
    dict(value='both', dist_name=_NRPMQAP1, parameter='cfgProfType'),
    dict(value='1', dist_name=_NRPMQAP1, parameter='nrPmqapId'),
    dict(value='2000', dist_name=_NRPMQAP1, parameter='rlcAmSduDlDelayThresh'),
    dict(value='1-9', dist_name=_NRPMQAP1, parameter='cfg5qiRange'),
    dict(value='5-9', dist_name=_NRPMQAP1, parameter='cfgQciRange'),
]
PARAMETERS_TO_CB008158_pmqap_delete_0 = [
    {'dist_name': '_NRBTSname/NRPMRNL-1/NRPMQAP-1'},
]

PARAMETERS_TO_CB008158_pmqap_delete_1 = [
    {'dist_name': '_NRBTSname/NRPMRNL-1/NRPMQAP-2'},
]

PARAMETERS_TO_CB008158_pmqap_delete_2 = [
    {'dist_name': '_NRBTSname/NRPMRNL-1/NRPMQAP-3'},
]

PARAMETERS_TO_CB008158_pmqap_delete_3 = [
    {'dist_name': '_NRBTSname/NRPMRNL-1/NRPMQAP-4'},
]

PARAMETERS_TO_CB008158_pmqap_delete_4 = [
    {'dist_name': '_NRBTSname/NRPMRNL-1/NRPMQAP-5'},
]

PARAMETERS_TO_CB008158_pmqap_delete_5 = [
    {'dist_name': '_NRBTSname/NRPMRNL-1/NRPMQAP-6'},
]

PARAMETERS_TO_CB008158_pmqap_delete_6 = [
    {'dist_name': '_NRBTSname/NRPMRNL-1/NRPMQAP-7'},
]

PARAMETERS_TO_CB008158_pmqap_delete_7 = [
    {'dist_name': '_NRBTSname/NRPMRNL-1/NRPMQAP-8'},
]

PARAMETERS_TO_CB008158_pmqap_delete_8 = [
    {'dist_name': '_NRBTSname/NRPMRNL-1/NRPMQAP-9'},
]

PARAMETERS_TO_CB008158_pmqap_delete_9 = [
    {'dist_name': '_NRBTSname/NRPMRNL-1/NRPMQAP-10'},
]

PARAMETERS_TO_CB008158_pmqap_delete_10 = [
    {'dist_name': '_NRBTSname/NRPMRNL-1/NRPMQAP-11'},
]

PARAMETERS_TO_CB008158_pmqap_delete_11 = [
    {'dist_name': '_NRBTSname/NRPMRNL-1/NRPMQAP-12'},
]

PARAMETERS_TO_CB008158_pmqap_delete_12 = [
    {'dist_name': '_NRBTSname/NRPMRNL-1/NRPMQAP-13'},
]

PARAMETERS_TO_CB008158_pmqap_delete_13 = [
    {'dist_name': '_NRBTSname/NRPMRNL-1/NRPMQAP-14'},
]

PARAMETERS_TO_CB008158_pmqap_delete_14 = [
    {'dist_name': '_NRBTSname/NRPMRNL-1/NRPMQAP-15'},
]

PARAMETERS_TO_CB008158_pmqap_delete_15 = [
    {'dist_name': '_NRBTSname/NRPMRNL-1/NRPMQAP-16'},
]

PARAMETERS_TO_CB008158_pmqap_delete_16 = [
    {'dist_name': '_NRBTSname/NRPMRNL-1/NRPMQAP-17'},
]

PARAMETERS_TO_CB008158_pmqap_delete_17 = [
    {'dist_name': '_NRBTSname/NRPMRNL-1/NRPMQAP-18'},
]

PARAMETERS_TO_CB008158_pmqap_delete_18 = [
    {'dist_name': '_NRBTSname/NRPMRNL-1/NRPMQAP-19'},
]

PARAMETERS_TO_CB008158_pmqap_delete_19 = [
    {'dist_name': '_NRBTSname/NRPMRNL-1/NRPMQAP-20'},
]
