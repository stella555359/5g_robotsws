from robot.libraries.BuiltIn import BuiltIn
import time
from datetime import datetime
tl = BuiltIn().get_variable_value("${tl}")

__maintainer__ = 'Hu Yifan'
__team__ = 'I_MN_5G_RAN_IV4_LINE_HZG_3_GMS <I_MN_5G_RAN_IV4_LINE_HZG_3@internal.nsn.com>'
__email__ = 'yifan.hu@nokia-sbell.com'

_class_name = 'com.nokia.srbts.mnl:MPLANENW'

_global_bts_id = str(tl.gnbs[0].global_bts_id)
_gnb_id = str(tl.gnbs[0].instance_id)
_MRBTSname = 'MRBTS-'+_global_bts_id
_NNRBTSname = 'NRBTS-'+_gnb_id
_NRBTSname = _MRBTSname+'/NRBTS-'+_gnb_id
_NRCELL11 = _NRBTSname + '/NRCELL-1'
_GNB1AFM1 = _NRBTSname + '/SERVEDAMF-1'
_CHANNELGROUP2 = _MRBTSname + '/MNL-1/MNLENT-1/CELLMAPPING-1/LCELNR-16383/CHANNELGROUP-1/CHANNEL-2'
_CHANNELGROUP4 = _MRBTSname + '/MNL-1/MNLENT-1/CELLMAPPING-1/LCELNR-16383/CHANNELGROUP-1/CHANNEL-4'
_CHANNELGROUP7 = _MRBTSname + '/MNL-1/MNLENT-1/CELLMAPPING-1/LCELNR-16383/CHANNELGROUP-1/CHANNEL-7'
_CHANNELGROUP8 = _MRBTSname + '/MNL-1/MNLENT-1/CELLMAPPING-1/LCELNR-16383/CHANNELGROUP-1/CHANNEL-8'

PARAMETERS_DSM_JSON_FILE = 'PARAMETERS_DSM_JSON_FILE.json'

paras = [
    {
        "distName": _NRBTSname,
        "operation": "update",
        "parameters": [
            {
                "parameterName": "actNrLBRTXPowerSaving",
                "value": "true",
                "operation": "update"
            }
        ]
    },
    {
        "distName": _NRCELL11,
        "operation": "update",
        "parameters": [
            {
                "parameterName": "nrCellType",
                "value": "4DL4UL",
                "operation": "update"
            }
        ]
    },
    {
        "distName": _CHANNELGROUP2,
        "operation": "update",
        "parameters": [
            {
                "parameterName": "antlDN",
                "value": _MRBTSname + '/EQM-1/APEQM-1/RMOD-1/ANTL-1',
                "operation": "update"
            }
        ]
    },
    {
        "distName": _CHANNELGROUP4,
        "operation": "update",
        "parameters": [
            {
                "parameterName": "antlDN",
                "value": _MRBTSname + '/EQM-1/APEQM-1/RMOD-1/ANTL-2',
                "operation": "update"
            }
        ]
    },
    {
        "distName": _CHANNELGROUP7,
        "operation": "create",
        "parameters": [
            {
                "parameterName": "antlDN",
                "value": _MRBTSname + '/EQM-1/APEQM-1/RMOD-1/ANTL-3',
                "operation": "update"
            },
            {
                "parameterName": "channelId",
                "value": "7",
                "operation": "update"
            },
            {
                "parameterName": "direction",
                "value": "RX",
                "operation": "update"
            },
        ]
    },
    {
        "distName": _CHANNELGROUP8,
        "operation": "create",
        "parameters": [
            {
                "parameterName": "antlDN",
                "value": _MRBTSname + '/EQM-1/APEQM-1/RMOD-1/ANTL-4',
                "operation": "update"
            },
            {
                "parameterName": "channelId",
                "value": "8",
                "operation": "update"
            },
            {
                "parameterName": "direction",
                "value": "RX",
                "operation": "update"
            },
        ]
    },
]

PARAMETERS_TO_UPDATE = [
    {'dist_name': '_NRBTSname/NRDRB-4', 'parameter': 'dlFlowControlAlgo', 'value': '3gppFlowControl'},
    {'dist_name': '_NRBTSname/NRDRB-4', 'parameter': 'queuingDelayDiscardEnabled', 'value': 'true'},
    {'dist_name': '_NRBTSname/NRDRB-4', 'parameter': 'queuingDelaySduDiscardThreshold', 'value': '1'},
    {'dist_name': '_NRBTSname/NRDRB-4', 'parameter': 'sduDiscardIntervalTmr', 'value': '500'},
    {'dist_name': '_NRBTSname/NRDRB-4', 'parameter': 'numSduDiscard', 'value': '1'},
    {'dist_name': '_NRBTSname', 'parameter': 'x2LinkSupervisionTmr', 'value': '15'},
    {'dist_name': '_NRBTSname/NRPMRNL-1', 'parameter': 'miNrPDCP2Report', 'value': '5min'}
]

counter_id = [
    'M55320C09007'
]

PARAMETERS_TO_RESTORE = [
    {'dist_name': '_NRBTSname/SERVEDAMF-1', 'parameter': 'administrativeState', 'value': 'Unlocked'},
    dict(value='true', dist_name=_NRBTSname, parameter='actPlmnAwareScheduler'),
    dict(value='true', dist_name=_NRBTSname, parameter='actSliceAwareSchQosFairness'),
]

PARAMETERS_TO_ONLINE_MODIFY_GNB1_AMF_LOCK = [
    {'dist_name': '_NRBTSname/SERVEDAMF-1', 'parameter': 'administrativeState', 'value': 'Locked'}
]

PARAMETERS_TO_ONLINE_MODIFY_GNB1_disable = [
    dict(value='false', dist_name=_NRBTSname, parameter='actPlmnAwareScheduler'),
    dict(value='false', dist_name=_NRBTSname, parameter='actSliceAwareSchQosFairness'),
]

year = time.localtime().tm_year
month = time.localtime().tm_mon
day = time.localtime().tm_mday
date = datetime.date(datetime(year=year, month=month, day=day))
weekday = date.strftime("%a")
now = datetime.now()
hour = now.hour

PARAMETERS_TO_ONLINE_MODIFY_GNB1 = [
    dict(value='true', dist_name=_NRBTSname, parameter='actNrLBRTXPowerSaving'),
    dict(value='true', dist_name=_NRCELL11, parameter='actDtxOptimizedScheduler'),
    dict(value='false', dist_name=_NRCELL11, parameter='actEirpControl'),
    dict(value='5min', dist_name=_NRBTSname + '/NRPMRNL-1', parameter='miNrEirp'),
    dict(value='15min', dist_name=_MRBTSname + '/MNL-1/MNLENT-1/PMMNL-1', parameter='mtSBTSRfmEnergyMonitoring'),
    dict(value='true', dist_name=_MRBTSname + '/MNL-1/MNLENT-1/FEATCADM-1', parameter='actPowerMeter'),
    dict(value='TX switch off', dist_name=_NRBTSname + '/NRPGRP-1', parameter='lbpsSOMethod'),
    dict(value='false', dist_name=_NRBTSname, parameter='actNrLBPowerSaving'),
    dict(value='false', dist_name=_NRBTSname, parameter='actNrExtCellSOMethod'),
    dict(value='false', dist_name=_NRBTSname, parameter='actNrMixedSOMethod'),
    dict(value='disabled', dist_name=_NRBTSname, parameter='actCoordinated4g5gPowerSaving'),
    dict(value='false', dist_name=_NRCELL11, parameter='actEnhDtxOptimizedScheduler'),
    dict(value='false', dist_name=_NRBTSname, parameter='actLbpsCtrlLogicEnh'),
    dict(value=[dict(lbpsDayOfWeek=weekday, lbpsDuration='1440', lbpsStartTimeHour=hour)],
         dist_name=_NRBTSname + '/NRPGRP-1', parameter='lbpsPeriodList'),
    dict(value='false', dist_name=_NRBTSname, parameter='actSliceAwareScheduler'),
    dict(value='false', dist_name=_NRBTSname, parameter='actSliceAwareSchedulerUlAndEnh'),
    dict(value='PA avoidance disabled', dist_name=_NRBTSname, parameter='powerSavingAvoidanceForPACalls'),

]

Delete_Para_Online_GNB1 = [
    dict(dist_name=_NRCELL11, parameter='nrResourceGroupProfileDN'),
]

PARAMETERS_TO_ONLINE_MODIFY_GNB1_004_1 = [
    dict(value='false', dist_name=_NRBTSname, parameter='actNrLBRTXPowerSaving')
]

PARAMETERS_TO_ONLINE_MODIFY_GNB1_004_2 = [
    dict(value='true', dist_name=_NRBTSname, parameter='actNrLBRTXPowerSaving'),
    dict(value='false', dist_name=_NRCELL11, parameter='actDtxOptimizedScheduler'),
    dict(value='Locked', dist_name=_GNB1AFM1, parameter='administrativeState'),
]

PARAMETERS_TO_ONLINE_MODIFY_GNB1_004_3 = [
    dict(value='Unlocked', dist_name=_GNB1AFM1, parameter='administrativeState'),
]

PARAMETERS_TO_ONLINE_MODIFY_GNB1_4T4R = [
    dict(value='true', dist_name=_NRBTSname, parameter='actNrLBRTXPowerSaving'),
    dict(value='4DL4UL', dist_name=_NRCELL11, parameter='nrCellType'),
    dict(value=_MRBTSname + '/EQM-1/APEQM-1/RMOD-1/ANTL-1', dist_name=_CHANNELGROUP2, parameter='antlDN'),
    dict(value=_MRBTSname + '/EQM-1/APEQM-1/RMOD-1/ANTL-2', dist_name=_CHANNELGROUP4, parameter='antlDN'),
]

Add_Mo_Online_GNB1_4T4R = [
    dict(value=_MRBTSname + '/EQM-1/APEQM-1/RMOD-1/ANTL-3', dist_name=_CHANNELGROUP7, parameter='antlDN'),
    dict(value='7', dist_name=_CHANNELGROUP7, parameter='channelId'),
    dict(value='RX', dist_name=_CHANNELGROUP7, parameter='direction'),
    dict(value=_MRBTSname + '/EQM-1/APEQM-1/RMOD-1/ANTL-4', dist_name=_CHANNELGROUP8, parameter='antlDN'),
    dict(value='8', dist_name=_CHANNELGROUP8, parameter='channelId'),
    dict(value='RX', dist_name=_CHANNELGROUP8, parameter='direction'),
]

PARAMETERS_TO_ONLINE_MODIFY_GNB1_ANT13 = [
    dict(value='true', dist_name=_NRBTSname, parameter='actNrLBRTXPowerSaving'),
    dict(value=_MRBTSname + '/EQM-1/APEQM-1/RMOD-1/ANTL-3', dist_name=_CHANNELGROUP4, parameter='antlDN'),
]

PARAMETERS_TO_ONLINE_MODIFY_GNB1_ANT24 = [
    dict(value='true', dist_name=_NRBTSname, parameter='actNrLBRTXPowerSaving'),
    dict(value=_MRBTSname + '/EQM-1/APEQM-1/RMOD-1/ANTL-2', dist_name=_CHANNELGROUP2, parameter='antlDN'),
    dict(value=_MRBTSname + '/EQM-1/APEQM-1/RMOD-1/ANTL-4', dist_name=_CHANNELGROUP4, parameter='antlDN'),
]

counter_id_003_gnb1 = [
    'M40003C4'
]

counter_dic_path_003_gnb1 = [
    'BTS/' + _MRBTSname + '/EQM-1/APEQM-1/RMOD-1/SBTS_RFM_Energy_Monitoring'
]

# counter_dic_path_003_gnb1 = [
#     'BTS/BTS/' + _MRBTSname + '/RMOD-1/SBTS_RFM_Energy_Monitoring'
# ]

counter_id_008_gnb1 = [
    'M55324C00000'
]

counter_dic_path_008_gnb1 = [
    'BTS/' + _NRBTSname + '/NRCELL-3/NREIRP'
]

# counter_dic_path_008_gnb1 = [
#     'BTS/CELLS/NRCELL-3/NREIRP'
# ]

Delete_Mo_Online_GNB1_2RX = [
    {'dist_name': _CHANNELGROUP7},
    {'dist_name': _CHANNELGROUP8},
]

PARAMETERS_TO_Para_MODIFY_GNB1_2RX = [
    dict(value='4DL2UL', dist_name=_NRCELL11, p_name='nrCellType'),
    ]

PARAMETERS_TO_list_MODIFY_GNB1_2RX = [
    dict(dist_name=_NRCELL11, list_name='ulSuMimoEnh',
         elements=[
                dict(p_name='enhRankSelectIrcGain', value='false', index=0),
                dict(p_name='enhRankSelectIrcGainMethod', value='longTermDiff', index=0),
                dict(p_name='enhRankSelectSe', value='false', index=0),]),
    ]
