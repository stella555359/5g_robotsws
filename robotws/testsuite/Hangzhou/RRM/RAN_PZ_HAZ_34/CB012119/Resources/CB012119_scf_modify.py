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

ATTENUATION_VALUE_update6 = {
    'atten_value_of_port0': 10,
    'atten_value_of_port1': 10,
    'atten_value_of_port2': 10,
    'atten_value_of_port3': 10,
    'atten_value_of_port4': 25,
    'atten_value_of_port5': 25,
    'atten_value_of_port6': 25,
    'atten_value_of_port7': 25,
    'atten_value_of_port8': 10,
    'atten_value_of_port9': 10,
    'atten_value_of_port10': 10,
    'atten_value_of_port11': 10
}
