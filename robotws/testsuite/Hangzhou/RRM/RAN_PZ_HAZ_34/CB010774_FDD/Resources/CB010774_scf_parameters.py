from robot.libraries.BuiltIn import BuiltIn

tl = BuiltIn().get_variable_value("${tl}")

_gnb_id = str(tl.gnbs[0].global_bts_id)
_bts_id = str(tl.gnbs[0].instance_id)
_MRBTSname = 'MRBTS-'+_gnb_id
_NRBTSname = _MRBTSname+'/NRBTS-'+_bts_id
_LNBTSname = _MRBTSname+'/LNBTS-'+_bts_id
_NRPMRNL = _NRBTSname+'/NRPMRNL-1'
_PMCADM = _MRBTSname + '/MNL-1' + '/MNLENT-1' + '/PMCADM-1'
MR_NR_CELL_NAME_1 = _NRBTSname + '/NRCELL-21'
MR_NR_CELL_NAME_2 = _NRBTSname + '/NRCELL-22'
MR_NR_CELL_NAME_3 = _NRBTSname + '/NRCELL-23'
MR_NR_CELL_NAME_4 = _NRBTSname + '/NRCELL-4'
MR_NR_CELL_NAME_5 = _NRBTSname + '/NRCELL-5'
MR_NR_CELL_NAME_DSS = _NRBTSname + '/NRCELL-5'
MR_NR_BTS_NAME = _NRBTSname
LNCEL_NAME = _LNBTSname+'/LNCEL-11'


TLCommonConfig_0 = {
    "MultiUECFG": {
        "0": {
            "detach_request": "true",
            "power_reset": "true",
            "ue_mode": "SA",
            "apn": "mdrb.nokia.com",
            "iperf_port": "44373",
            "multidrb_QoS_dest": None,
            "dl": {"target_throughput": "260MKbits/sec", "duration": "3600"},
            "ul": {"target_throughput": "10MKbits/sec", "duration": "3600"},
            "target_percent": "0.8",
            "reset_sol": "none",
            "attach_mode": "5G_SA",
            "dt_name": "DT_8",
            "protocol": "udp",
            "connection_type": "app",
            "apn_address": "mdrb.nokia.com",
        },
        "ue_index_for_call": ["0"]
    },
}
TLCommonConfig_1 = {
    "MultiUECFG": {
        "0": {
            "detach_request": "true",
            "power_reset": "true",
            "ue_mode": "SA",
            "apn": "mdrb.nokia.com",
            "iperf_port": "44373",
            "multidrb_QoS_dest": None,
            "dl": {"target_throughput": "260MKbits/sec", "duration": "3600"},
            "ul": {"target_throughput": "10MKbits/sec", "duration": "3600"},
            "target_percent": "0.8",
            "reset_sol": "none",
            "attach_mode": "5G_SA",
            "dt_name": "DT_8",
            "protocol": "udp",
            "connection_type": "app",
            "apn_address": "mdrb.nokia.com",
        },
        "ue_index_for_call": ["1"]
    },
}


Expected_maxNumPagingRecords_value_0 = [12, 12, 5, 12, 5]
Expected_maxNumPagingRecords_value_1 = [12, 12, 5, 12, 5]
Expected_maxNumPagingRecords_value_2 = [1, 1, 1, 1, 1]
Expected_maxNumPagingRecords_value_TL2077_0 = [4, 32, 18]
Expected_maxNumPagingRecords_value_TL2077_1 = [4, 13, 6]
Expected_maxNumPagingRecords_value_TL2077_2 = [1, 1, 1]

PARAMETERS_TO_Modify_0 = [
    dict(
        value='32',
        dist_name=MR_NR_CELL_NAME_1,
        parameter='maxNumPagingRecords'),
    dict(
        value='32',
        dist_name=MR_NR_CELL_NAME_2,
        parameter='maxNumPagingRecords'),
    dict(
        value='32',
        dist_name=MR_NR_CELL_NAME_3,
        parameter='maxNumPagingRecords'),
    dict(
        value='32',
        dist_name=MR_NR_CELL_NAME_4,
        parameter='maxNumPagingRecords'),
    dict(
        value='32',
        dist_name=MR_NR_CELL_NAME_5,
        parameter='maxNumPagingRecords'),
]
PARAMETERS_TO_Modify_1 = [
    dict(
        value='13',
        dist_name=MR_NR_CELL_NAME_1,
        parameter='maxNumPagingRecords'),
    dict(
        value='13',
        dist_name=MR_NR_CELL_NAME_2,
        parameter='maxNumPagingRecords'),
    dict(
        value='6',
        dist_name=MR_NR_CELL_NAME_3,
        parameter='maxNumPagingRecords'),
    dict(
        value='13',
        dist_name=MR_NR_CELL_NAME_4,
        parameter='maxNumPagingRecords'),
    dict(
        value='6',
        dist_name=MR_NR_CELL_NAME_5,
        parameter='maxNumPagingRecords'),
]
PARAMETERS_TO_Modify_2 = [
    dict(
        value='1',
        dist_name=MR_NR_CELL_NAME_1,
        parameter='maxNumPagingRecords'),
    dict(
        value='1',
        dist_name=MR_NR_CELL_NAME_2,
        parameter='maxNumPagingRecords'),
    dict(
        value='1',
        dist_name=MR_NR_CELL_NAME_3,
        parameter='maxNumPagingRecords'),
    dict(
        value='1',
        dist_name=MR_NR_CELL_NAME_4,
        parameter='maxNumPagingRecords'),
    dict(
        value='1',
        dist_name=MR_NR_CELL_NAME_5,
        parameter='maxNumPagingRecords'),
]
PARAMETERS_TO_Modify_TL2077_0 = [
    dict(
        value='32',
        dist_name=MR_NR_CELL_NAME_1,
        parameter='maxNumPagingRecords'),
    dict(
        value='32',
        dist_name=MR_NR_CELL_NAME_2,
        parameter='maxNumPagingRecords'),
    dict(
        value='32',
        dist_name=MR_NR_CELL_NAME_3,
        parameter='maxNumPagingRecords'),
]
PARAMETERS_TO_Modify_TL2077_1 = [
    dict(
        value='13',
        dist_name=MR_NR_CELL_NAME_1,
        parameter='maxNumPagingRecords'),
    dict(
        value='13',
        dist_name=MR_NR_CELL_NAME_2,
        parameter='maxNumPagingRecords'),
    dict(
        value='6',
        dist_name=MR_NR_CELL_NAME_3,
        parameter='maxNumPagingRecords'),
]
PARAMETERS_TO_Modify_TL_2077_2 = [
    dict(
        value='1',
        dist_name=MR_NR_CELL_NAME_1,
        parameter='maxNumPagingRecords'),
    dict(
        value='1',
        dist_name=MR_NR_CELL_NAME_2,
        parameter='maxNumPagingRecords'),
    dict(
        value='1',
        dist_name=MR_NR_CELL_NAME_3,
        parameter='maxNumPagingRecords'),
]
