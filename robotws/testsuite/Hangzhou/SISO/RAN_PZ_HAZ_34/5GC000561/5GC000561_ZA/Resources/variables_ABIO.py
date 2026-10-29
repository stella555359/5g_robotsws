import os
from taf.config.testline.info import info
from robot.libraries.BuiltIn import BuiltIn

tl = BuiltIn().get_variable_value("${tl}")
mr_bts_id = tl.gnbs[0].instance_id
nr_bts_id = tl.gnbs[0].global_bts_id
_MRBTSname = 'MRBTS-' + str(mr_bts_id)
_NRBTSname = _MRBTSname + '/NRBTS-' + str(nr_bts_id)
_NRBTS_ID = 'NRBTS-' + str(nr_bts_id)

PARAM_561_013 = [
    dict(
        dist_name=_MRBTSname + '/MNL-1/MNLENT-1/SYNC-1/ECPRIMASTER-1',
        filter_param='eCpri Master Synchronous Ethernet SSM support network standard',
        p_name='eCpriMasterSsmType'),
    dict(
        dist_name=_MRBTSname + '/MNL-1/MNLENT-1/SYNC-1/CLOCK-1/ECPRIMASTERSTATUS_R-1',
        filter_param='eCPRI Master SSM value',
        p_name='eCpriMasterSsmValue'),
    dict(
        dist_name=_MRBTSname + '/MNL-1/MNLENT-1/SYNC-1/CLOCK-1/ECPRIMASTERSTATUS_R-1',
        filter_param='eCPRI Master clock class',
        p_name='eCpriMasterClockClass'),
    dict(
        dist_name=_MRBTSname + '/MNL-1/MNLENT-1/SYNC-1/CLOCK-1/ECPRIMASTERSTATUS_R-1',
        filter_param='eCPRI Master clock accuracy',
        p_name='eCpriMasterClockAccuracy'),
    dict(
        dist_name=_MRBTSname + '/MNL-1/MNLENT-1/SYNC-1/CLOCK-1/ECPRIMASTERSTATUS_R-1',
        filter_param='eCPRI Master offset scaled log variance',
        p_name='eCpriMasterOffsetScaledLogVariance'),
    dict(
        value='2.048MHz input',
        dist_name=_MRBTSname + '/MNL-1/MNLENT-1/SYNC-1/CLOCK-1',
        filter_param='Sync input type',
        p_name='syncInputType'),
    dict(
        value=['6'],
        dist_name=_MRBTSname + '/MNL-1/MNLENT-1/SYNC-2/CLOCK-1/TOP-1/TOPP-1',
        parameter='acceptedClockClass')
]

PARAM_561_013_RECOVER_ENV = [
    dict(
        value=[{'syncInputPrio': '1', 'syncInputType': '1pps/ToD from external GNSS receiver'}],
        dist_name=_MRBTSname + '/MNL-1/MNLENT-1/SYNC-1/CLOCK-1',
        parameter='syncInputList'),
    dict(
        value='SSM_ITU',
        dist_name=_MRBTSname + '/MNL-1/MNLENT-1/SYNC-1/ECPRIMASTER-1',
        parameter='eCpriMasterSsmType')
]

PARAM_561_ACCEPTEDCLOCKCLASS = [
    dict(
        value=['6'],
        dist_name=_MRBTSname + '/MNL-1/MNLENT-1/SYNC-2/CLOCK-1/TOP-1/TOPP-1',
        parameter='acceptedClockClass')
]

PARAM_561_SSM_ANSI = [
    dict(
        value='SSM_ANSI',
        dist_name=_MRBTSname + '/MNL-1/MNLENT-1/SYNC-1/ECPRIMASTER-1',
        parameter='eCpriMasterSsmType')
]

PARAM_561_SYNCIN_2048 = [
    dict(
        value=[{'syncInputPrio': '1', 'syncInputType': '2.048MHz input'}],
        dist_name=_MRBTSname + '/MNL-1/MNLENT-1/SYNC-1/CLOCK-1',
        parameter='syncInputList')
]

PARAM_561_MASTER_MULTICASTADDRESS = [
    dict(
        value='01-80-C2-00-00-0E',
        dist_name=_MRBTSname + '/MNL-1/MNLENT-1/SYNC-1/ECPRIMASTER-1',
        filter_param='eCPRI Master over Ethernet multicast address',
        parameter='eCpriMasterEthMulticastAddress')
]

PARAM_561_SLAVE_MULTICASTADDRESS = [
    dict(
        value='01-80-C2-00-00-0E',
        dist_name=_MRBTSname + '/MNL-1/MNLENT-1/SYNC-2/CLOCK-1/TOP-1/TOPP-1',
        filter_param='ToP over Ethernet multicast address',
        parameter='topEthMulticastAddress')
]

PARAM_561_DOMAINNUMBER = [
    dict(
        value='24',
        dist_name=_MRBTSname + '/MNL-1/MNLENT-1/SYNC-1/ECPRIMASTER-1',
        filter_param='eCPRI Master domain number',
        p_name='eCpriMasterDomainNumber')
]

PARAM_561_INTERVAL = [
    dict(
        dist_name=_MRBTSname + '/MNL-1/MNLENT-1/PMMNL-1',
        filter_param='SBTS NR eCPRI Master Statistics',
        p_name='eCpriMasterStatisticsInterval')
]

PARAM_561_INTERVAL_OTHER = [
    dict(
        dist_name=_MRBTSname + '/MNL-1/MNLENT-1/PMMNL-1',
        filter_param='SBTS eCPRI Master Statistics',
        p_name='eCpriMasterStatisticsInterval')
]

ALLOWED_FAULT = [
    {'faultId': 61652},
    {'faultId': 61524},
    {'faultId': 61649},
    {'faultId': 9000},
    {'faultId': 4592},
    {'faultId': 4527},
    {'faultId': 1932},
    {'faultId': 4334},
    {'faultId': 61074},
    {'faultId': 61618},
    {'faultId': 4687},
    {'faultId': 4654},
    {'faultId': 4655},
    {'faultId': 8150},
]

ALLOWED_HISTORY_FAULT = [
    {'faultId': 7319},
    {'faultId': 7300},
    {'faultId': 8150},
    {'faultId': 6327},
    {'faultId': 10},
]

ALLOWED_HISTORY_FAULT.extend(ALLOWED_FAULT)
