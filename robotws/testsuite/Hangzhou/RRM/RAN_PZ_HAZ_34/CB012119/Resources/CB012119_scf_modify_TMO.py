from robot.libraries.BuiltIn import BuiltIn

tl = BuiltIn().get_variable_value("${tl}")

_gnb_id = str(tl.gnbs[0].global_bts_id)
_bts_id = str(tl.gnbs[0].instance_id)
_MRBTSname = 'MRBTS-'+_gnb_id
_NRBTSname = _MRBTSname+'/NRBTS-'+_bts_id
_LNBTSname = _MRBTSname+'/LNBTS-'+_bts_id
_NRPMRNL = _NRBTSname+'/NRPMRNL-1'
_PMCADM = _MRBTSname + '/MNL-1' + '/MNLENT-1' + '/PMCADM-1'
MR_NR_CELL_NAME = _NRBTSname + '/NRCELL-21'
MR_NR_BTS_NAME = _NRBTSname
LNCEL_NAME = _LNBTSname+'/LNCEL-11'

_NRPMQAP7 = _NRPMRNL+'/NRPMQAP-7'
_NRPMQAP4 = _NRPMRNL+'/NRPMQAP-4'
_NRPMQAP17 = _NRPMRNL+'/NRPMQAP-17'
_NRPMQAP1 = _NRPMRNL+'/NRPMQAP-1'
_NRPMQAP2 = _NRPMRNL+'/NRPMQAP-2'
_NRPMQAP8 = _NRPMRNL+'/NRPMQAP-8'
_PMCADM = _MRBTSname+'/MNL-1'+'/MNLENT-1'+'/PMCADM-1'

Disable_UL256QAM = [
    dict(
        value='false',
        dist_name=MR_NR_CELL_NAME,
        parameter='actUl256Qam'),
]

Lock_LNCEL11 = [
    dict(
        value='locked',
        dist_name=LNCEL_NAME,
        parameter='administrativeState'),
]

UnLock_LNCEL11 = [
    dict(
        value='unlocked',
        dist_name=LNCEL_NAME,
        parameter='administrativeState'),
]

ATTENUATION_VALUE_update1 = {
    'atten_value_of_port0': 0,
    'atten_value_of_port1': 0,
    'atten_value_of_port2': 127,
    'atten_value_of_port3': 127,
    'atten_value_of_port4': 127,
    'atten_value_of_port5': 127
}

ATTENUATION_VALUE_update2 = {
    'atten_value_of_port0': 20,
    'atten_value_of_port1': 20,
    'atten_value_of_port2': 50,
    'atten_value_of_port3': 50,
    'atten_value_of_port4': 127,
    'atten_value_of_port5': 127
}

ATTENUATION_VALUE_update3 = {
    'atten_value_of_port0': 20,
    'atten_value_of_port1': 20,
    'atten_value_of_port2': 20,
    'atten_value_of_port3': 20,
    'atten_value_of_port4': 127,
    'atten_value_of_port5': 127
}

ATTENUATION_VALUE_update4 = {
    'atten_value_of_port0': 20,
    'atten_value_of_port1': 20,
    'atten_value_of_port2': 0,
    'atten_value_of_port3': 0,
    'atten_value_of_port4': 127,
    'atten_value_of_port5': 127
}
ATTENUATION_VALUE_update5 = {
    'atten_value_of_port0': 127,
    'atten_value_of_port1': 127,
    'atten_value_of_port2': 0,
    'atten_value_of_port3': 0,
    'atten_value_of_port4': 127,
    'atten_value_of_port5': 127
}
