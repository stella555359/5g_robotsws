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
MR_NR_CELL_NAME_2 = _NRBTSname + '/NRCELL-2'
_NRPMQAP7 = _NRPMRNL+'/NRPMQAP-7'
_NRPMQAP4 = _NRPMRNL+'/NRPMQAP-4'
_NRPMQAP17 = _NRPMRNL+'/NRPMQAP-17'
_NRPMQAP1 = _NRPMRNL+'/NRPMQAP-1'
_NRPMQAP2 = _NRPMRNL+'/NRPMQAP-2'
_NRPMQAP8 = _NRPMRNL+'/NRPMQAP-8'
_PMCADM = _MRBTSname+'/MNL-1'+'/MNLENT-1'+'/PMCADM-1'

PARAMETERS_TO_CB006457_SA_enable = [
    dict(
        value='false',
        dist_name=_NRBTSname,
        p_name='actNrpmqapProfiles'),
    dict(
        value='true',
        dist_name=_NRBTSname,
        p_name='actNonGbrServiceDiff'),
    dict(
        value='true',
        dist_name=_NRBTSname,
        p_name='actSACallProcessingDU'),
    dict(
        value='5min',
        dist_name=_NRPMRNL,
        p_name='miNrHighRlcCellNrpmqap'),
    dict(
        value='5min',
        dist_name=_NRPMRNL,
        p_name='miNrHighRlcCell'),
    dict(
        value='5min',
        dist_name=_NRPMRNL,
        p_name='miNrMacSduReport'),
    dict(
        value='5min',
        dist_name=_NRPMRNL,
        p_name='miNrPdcpCellNrpmqap'),
    dict(
        value='true',
        dist_name=_NRBTSname,
        p_name='actIpThpt'),
    dict(
        value='true',
        dist_name=_NRBTSname,
        p_name='actMacUserThpt'),
    dict(
        value='5min',
        dist_name=_PMCADM,
        p_name='reportingIntervalPm'),
]

PARAMETERS_TO_CB006457_NSA_enable = [
    dict(
        value='false',
        dist_name=_NRBTSname,
        p_name='actSACallProcessingDU'),
    dict(
        value='false',
        dist_name=_NRBTSname,
        p_name='actNrpmqapProfiles'),
    dict(
        value='true',
        dist_name=_NRBTSname,
        p_name='actNonGbrServiceDiff'),
    dict(
        value='5min',
        dist_name=_PMCADM,
        p_name='reportingIntervalPm'),
    dict(
        value='true',
        dist_name=_NRBTSname,
        p_name='actMacUserThpt'),
    dict(
        value='true',
        dist_name=_NRBTSname,
        p_name='actIpThpt'),
    dict(
        value='5min',
        dist_name=_NRPMRNL,
        p_name='miNrHighRlcCellNrpmqap'),
    dict(
        value='5min',
        dist_name=_NRPMRNL,
        p_name='miNrHighRlcCell'),
    dict(
        value='5min',
        dist_name=_NRPMRNL,
        p_name='miNrMacSduReport'),
    dict(
        value='5min',
        dist_name=_NRPMRNL,
        p_name='miNrPdcpCellNrpmqap'),
]

PARAMETERS_TO_CB006457_actNrpmqapProfiles_enable = [
    {'dist_name': '_NRBTSname', 'parameter': 'actNrpmqapProfiles', 'value': 'true'},
]

PARAMETERS_TO_CB006457_actNrpmqapProfiles_disable = [
    {'dist_name': '_NRBTSname', 'parameter': 'actNrpmqapProfiles', 'value': 'false'},
]

PARAMETERS_TO_CB006457_enable = [
    {'dist_name': '_NRBTSname', 'parameter': 'actArpBasedQosScaling', 'value': 'true'},
]

PARAMETERS_TO_CB006457_disable = [
    {'dist_name': '_NRBTSname', 'parameter': 'actArpBasedQosScaling', 'value': 'false'},
]

PARAMETERS_TO_CB006457_pmqap_add_1 = [
    dict(value='both', dist_name=_NRPMQAP1, parameter='cfgProfType'),
    dict(value='1', dist_name=_NRPMQAP1, parameter='nrPmqapId'),
    dict(value='2000', dist_name=_NRPMQAP1, parameter='rlcAmSduDlDelayThresh'),
    dict(value='7', dist_name=_NRPMQAP1, parameter='cfg5qiRange'),
    dict(value='7', dist_name=_NRPMQAP1, parameter='cfgQciRange'),
]

PARAMETERS_TO_CB006457_pmqap_add_2 = [
    dict(value='both', dist_name=_NRPMQAP2, parameter='cfgProfType'),
    dict(value='2', dist_name=_NRPMQAP2, parameter='nrPmqapId'),
    dict(value='2000', dist_name=_NRPMQAP2, parameter='rlcAmSduDlDelayThresh'),
    dict(value='8', dist_name=_NRPMQAP2, parameter='cfg5qiRange'),
    dict(value='8', dist_name=_NRPMQAP2, parameter='cfgQciRange'),
]

PARAMETERS_TO_CB006457_pmqap_add_SA_1 = [
    dict(value='SA', dist_name=_NRPMQAP1, parameter='cfgProfType'),
    dict(value='1', dist_name=_NRPMQAP1, parameter='nrPmqapId'),
    dict(value='2000', dist_name=_NRPMQAP1, parameter='rlcAmSduDlDelayThresh'),
    dict(value='7', dist_name=_NRPMQAP1, parameter='cfg5qiRange'),
]

PARAMETERS_TO_CB006457_pmqap_add_SA_2 = [
    dict(value='SA', dist_name=_NRPMQAP2, parameter='cfgProfType'),
    dict(value='2', dist_name=_NRPMQAP2, parameter='nrPmqapId'),
    dict(value='2000', dist_name=_NRPMQAP2, parameter='rlcAmSduDlDelayThresh'),
    dict(value='8', dist_name=_NRPMQAP2, parameter='cfg5qiRange'),
]

PARAMETERS_TO_CB006457_pmqap_add_SA_4 = [
    dict(value='SA', dist_name=_NRPMQAP4, parameter='cfgProfType'),
    dict(value='4', dist_name=_NRPMQAP4, parameter='nrPmqapId'),
    dict(value='2000', dist_name=_NRPMQAP4, parameter='rlcAmSduDlDelayThresh'),
    dict(value='4', dist_name=_NRPMQAP4, parameter='cfg5qiRange'),
]

PARAMETERS_TO_CB006457_pmqap_delete_0 = [
    {'dist_name': '_NRBTSname/NRPMRNL-1/NRPMQAP-1'},
]

PARAMETERS_TO_CB006457_pmqap_delete_1 = [
    {'dist_name': '_NRBTSname/NRPMRNL-1/NRPMQAP-2'},
]

PARAMETERS_TO_CB006457_pmqap_delete_2 = [
    {'dist_name': '_NRBTSname/NRPMRNL-1/NRPMQAP-3'},
]

PARAMETERS_TO_CB006457_pmqap_delete_3 = [
    {'dist_name': '_NRBTSname/NRPMRNL-1/NRPMQAP-4'},
]

PARAMETERS_TO_CB006457_pmqap_delete_4 = [
    {'dist_name': '_NRBTSname/NRPMRNL-1/NRPMQAP-5'},
]

PARAMETERS_TO_CB006457_pmqap_delete_5 = [
    {'dist_name': '_NRBTSname/NRPMRNL-1/NRPMQAP-6'},
]

PARAMETERS_TO_CB006457_pmqap_delete_6 = [
    {'dist_name': '_NRBTSname/NRPMRNL-1/NRPMQAP-7'},
]

PARAMETERS_TO_CB006457_pmqap_delete_7 = [
    {'dist_name': '_NRBTSname/NRPMRNL-1/NRPMQAP-8'},
]

PARAMETERS_TO_CB006457_pmqap_delete_8 = [
    {'dist_name': '_NRBTSname/NRPMRNL-1/NRPMQAP-9'},
]

PARAMETERS_TO_CB006457_pmqap_delete_9 = [
    {'dist_name': '_NRBTSname/NRPMRNL-1/NRPMQAP-10'},
]

PARAMETERS_TO_CB006457_pmqap_delete_10 = [
    {'dist_name': '_NRBTSname/NRPMRNL-1/NRPMQAP-11'},
]

PARAMETERS_TO_CB006457_pmqap_delete_11 = [
    {'dist_name': '_NRBTSname/NRPMRNL-1/NRPMQAP-12'},
]

PARAMETERS_TO_CB006457_pmqap_delete_12 = [
    {'dist_name': '_NRBTSname/NRPMRNL-1/NRPMQAP-13'},
]

PARAMETERS_TO_CB006457_pmqap_delete_13 = [
    {'dist_name': '_NRBTSname/NRPMRNL-1/NRPMQAP-14'},
]

PARAMETERS_TO_CB006457_pmqap_delete_14 = [
    {'dist_name': '_NRBTSname/NRPMRNL-1/NRPMQAP-15'},
]

PARAMETERS_TO_CB006457_pmqap_delete_15 = [
    {'dist_name': '_NRBTSname/NRPMRNL-1/NRPMQAP-16'},
]

PARAMETERS_TO_CB006457_pmqap_delete_16 = [
    {'dist_name': '_NRBTSname/NRPMRNL-1/NRPMQAP-17'},
]

PARAMETERS_TO_CB006457_pmqap_delete_17 = [
    {'dist_name': '_NRBTSname/NRPMRNL-1/NRPMQAP-18'},
]

PARAMETERS_TO_CB006457_pmqap_delete_18 = [
    {'dist_name': '_NRBTSname/NRPMRNL-1/NRPMQAP-19'},
]

PARAMETERS_TO_CB006457_pmqap_delete_19 = [
    {'dist_name': '_NRBTSname/NRPMRNL-1/NRPMQAP-20'},
]

SA_HBTE = {
    'atten_value_of_port4': 0,
    'atten_value_of_port5': 0,
    'atten_value_of_port6': 0,
    'atten_value_of_port7': 0,
    'atten_value_of_port8': 127,
    'atten_value_of_port9': 127,
    'atten_value_of_port10': 127,
    'atten_value_of_port11': 127,
}

NSA_HBTE = {
    'atten_value_of_port4': 127,
    'atten_value_of_port5': 127,
    'atten_value_of_port6': 127,
    'atten_value_of_port7': 127,
    'atten_value_of_port8': 0,
    'atten_value_of_port9': 0,
    'atten_value_of_port10': 0,
    'atten_value_of_port11': 0,
}
PARAMETERS_TO_Handover_enable = [
    dict(
        value='636666',
        dist_name=MR_NR_CELL_NAME_2,
        p_name='nrarfcn'),
]

ATTENUATION_VALUE_Normal_1 = {
    'atten_value_of_port1': 20,
    'atten_value_of_port2': 20,
    'atten_value_of_port3': 20,
    'atten_value_of_port4': 20,
    'atten_value_of_port5': 120,
    'atten_value_of_port6': 120,
    'atten_value_of_port7': 120,
    'atten_value_of_port8': 120,
    'atten_value_of_port9': 20,
    'atten_value_of_port10': 20,
    'atten_value_of_port11': 20,
    'atten_value_of_port12': 20
}
ATTENUATION_VALUE_CA_1 = {
    'atten_value_of_port1': 20,
    'atten_value_of_port2': 20,
    'atten_value_of_port3': 20,
    'atten_value_of_port4': 20,
    'atten_value_of_port5': 20,
    'atten_value_of_port6': 20,
    'atten_value_of_port7': 20,
    'atten_value_of_port8': 20,
    'atten_value_of_port9': 20,
    'atten_value_of_port10': 20,
    'atten_value_of_port11': 20,
    'atten_value_of_port12': 20
}
ATTENUATION_VALUE_HO_1 = {
    'atten_value_of_port1': 20,
    'atten_value_of_port2': 20,
    'atten_value_of_port3': 20,
    'atten_value_of_port4': 20,
    'atten_value_of_port5': 127,
    'atten_value_of_port6': 127,
    'atten_value_of_port7': 127,
    'atten_value_of_port8': 127,
    'atten_value_of_port9': 20,
    'atten_value_of_port10': 20,
    'atten_value_of_port11': 20,
    'atten_value_of_port12': 20
}
ATTENUATION_VALUE_HO_2 = {
    'atten_value_of_port1': 40,
    'atten_value_of_port2': 40,
    'atten_value_of_port3': 40,
    'atten_value_of_port4': 40,
    'atten_value_of_port5': 50,
    'atten_value_of_port6': 50,
    'atten_value_of_port7': 50,
    'atten_value_of_port8': 50,
    'atten_value_of_port9': 40,
    'atten_value_of_port10': 40,
    'atten_value_of_port11': 40,
    'atten_value_of_port12': 40
}
ATTENUATION_VALUE_HO_2 = {
    'atten_value_of_port1': 60,
    'atten_value_of_port2': 60,
    'atten_value_of_port3': 60,
    'atten_value_of_port4': 60,
    'atten_value_of_port5': 30,
    'atten_value_of_port6': 30,
    'atten_value_of_port7': 30,
    'atten_value_of_port8': 30,
    'atten_value_of_port9': 30,
    'atten_value_of_port10': 60,
    'atten_value_of_port11': 60,
    'atten_value_of_port12': 60
}
ATTENUATION_VALUE_HO_3 = {
    'atten_value_of_port1': 127,
    'atten_value_of_port2': 127,
    'atten_value_of_port3': 127,
    'atten_value_of_port4': 127,
    'atten_value_of_port5': 20,
    'atten_value_of_port6': 20,
    'atten_value_of_port7': 20,
    'atten_value_of_port8': 20,
    'atten_value_of_port9': 127,
    'atten_value_of_port10': 127,
    'atten_value_of_port11': 127,
    'atten_value_of_port12': 127
}
