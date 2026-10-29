from robot.libraries.BuiltIn import BuiltIn
import time
from datetime import datetime

tl = BuiltIn().get_variable_value("${tl}")

__maintainer__ = 'Li Xiaodan'
__team__ = 'I_MN_5G_RAN_IV4_LINE_HZG_3_GMS <I_MN_5G_RAN_IV4_LINE_HZG_3@internal.nsn.com>'
__email__ = 'xiaodan.li@nokia-sbell.com'

_class_name = 'com.nokia.srbts.mnl:MPLANENW'

_gnb2_id = str(tl.gnbs[1].instance_id)
_MRBTSname2 = 'MRBTS-' + _gnb2_id
_NRBTSnames2 = 'NRBTS-' + _gnb2_id
_NRBTSname2 = _MRBTSname2 + '/NRBTS-' + _gnb2_id

_NRCELL22 = _NRBTSname2 + '/NRCELL-2'
_NRCELL23 = _NRBTSname2 + '/NRCELL-3'
_RMOD3 = _MRBTSname2 + '/EQM-1/APEQM-1/RMOD-3'
_NRPGRP1 = _NRBTSname2 + '/NRPGRP-1'
_NRPGRP2 = _NRBTSname2 + '/NRPGRP-2'

year = time.localtime().tm_year
month = time.localtime().tm_mon
day = time.localtime().tm_mday
date = datetime.date(datetime(year=year, month=month, day=day))
weekday = date.strftime("%a")
_CHANNELGROUP2 = _MRBTSname2 + '/MNL-1/MNLENT-1/CELLMAPPING-1/LCELNR-3/CHANNELGROUP-1/CHANNEL-2'
_CHANNELGROUP4 = _MRBTSname2 + '/MNL-1/MNLENT-1/CELLMAPPING-1/LCELNR-3/CHANNELGROUP-1/CHANNEL-4'
_CHANNELGROUP6 = _MRBTSname2 + '/MNL-1/MNLENT-1/CELLMAPPING-1/LCELNR-3/CHANNELGROUP-1/CHANNEL-6'
_CHANNELGROUP8 = _MRBTSname2 + '/MNL-1/MNLENT-1/CELLMAPPING-1/LCELNR-3/CHANNELGROUP-1/CHANNEL-8'

LIST_TO_MODIFY_GNB2 = [
    dict(dist_name=_NRBTSname2 + '/NRPGRP-1', list_name='lbpsPeriodList',
         elements=[dict(p_name='lbpsDayOfWeek', value=weekday, index=0),
                   dict(p_name='lbpsDuration', value='1440', index=0),
                   dict(p_name='lbpsStartTimeHour', value='0', index=0),
                   dict(p_name='lbpsStartTimeMinute', value='0', index=0),
                   dict(p_name='lbpsSuspended', value='notSuspended', index=0)])
]

# LIST_TO_MODIFY_GNB2_005 = [
#     dict(dist_name=_NRBTSname2 + '/NRPGRP-1', list_name='lbpsPeriodList',
#          elements=[dict(p_name='lbpsDayOfWeek', value=weekday, index=0),
#                    dict(p_name='lbpsDuration', value='1440', index=0),
#                    dict(p_name='lbpsStartTimeHour', value='0', index=0),
#                    dict(p_name='lbpsStartTimeMinute', value='0', index=0),
#                    dict(p_name='lbpsSuspended', value='notSuspended', index=0)]),
#     dict(dist_name=_NRBTSname2 + '/NRPGRP-2', list_name='lbpsCellPeriodList',
#          elements=[dict(p_name='lbpsCellDayOfWeek', value=weekday, index=0),
#                    dict(p_name='lbpsCellDuration', value='1440', index=0),
#                    dict(p_name='lbpsCellSOMethod', value='TX switch off', index=0),
#                    dict(p_name='lbpsCellStartTimeHour', value='0', index=0),
#                    dict(p_name='lbpsCellStartTimeMinute', value='0', index=0),
#                    dict(p_name='nrCellId', value='31', index=0)])
# ]

PARAMETERS_TO_MODIFY_GNB2 = [
    dict(value='5min', dist_name=_NRBTSname2 + '/NRPMRNL-1', p_name='miNrEirp'),
    dict(value='15min', dist_name=_NRBTSname2 + '/NRPMRNL-1', p_name='mtSBTSRfmEnergyMonitoring'),
    dict(value='true', dist_name=_MRBTSname2 + '/MNL-1/MNLENT-1/FEATCADM-1', p_name='actPowerMeter'),
    dict(value='false', dist_name=_NRBTSname2, p_name='actMicroDTX'),
    dict(value='false', dist_name=_NRBTSname2, p_name='actMicroDTXAdvanced'),
    dict(value='false', dist_name=_NRBTSname2, p_name='actNrLBmMimoRTXPowerSaving'),
    dict(value='false', dist_name=_NRBTSname2, p_name='actNrLBRTXPowerSaving'),
    dict(value='PA avoidance disabled', dist_name=_NRBTSname2, p_name='powerSavingAvoidanceForPACalls'),
    dict(value='false', dist_name=_NRCELL23, p_name='actEirpControl'),
    dict(value='false', dist_name=_NRCELL23, p_name='actDtxOptimizedScheduler'),
    dict(value='false', dist_name=_NRCELL23, p_name='actEnhDtxOptimizedScheduler'),
    dict(value='false', dist_name=_NRBTSname2, p_name='actNrLBPowerSaving'),
    dict(value='false', dist_name=_NRBTSname2, p_name='actNrMixedSOMethod'),
    dict(value='TX switch off', dist_name=_NRBTSname2 + '/NRPGRP-1', p_name='lbpsSOMethod'),
    dict(value='false', dist_name=_NRBTSname2, p_name='actNrExtCellSOMethod')
]

# PARAMETERS_TO_MODIFY_GNB1_005 = [
#     dict(value='5min', dist_name=_NRBTSname + '/NRPMRNL-1', p_name='miNrEirp'),
#     dict(value='15min', dist_name=_NRBTSname + '/NRPMRNL-1', p_name='mtSBTSRfmEnergyMonitoring'),
#     dict(value='true', dist_name=_MRBTSname + '/MNL-1/MNLENT-1/FEATCADM-1', p_name='actPowerMeter'),
#     dict(value='false', dist_name=_NRBTSname, p_name='actNrLBRTXPowerSaving'),
#     dict(value='false', dist_name=_NRCELL13, p_name='actEirpControl'),
#     dict(value='false', dist_name=_NRCELL13, p_name='actDtxOptimizedScheduler'),
#     dict(value='false', dist_name=_NRBTSname, p_name='actNrLBPowerSaving'),
#     dict(value='false', dist_name=_NRBTSname, p_name='actNrMixedSOMethod')
# ]

PARAMETERS_TO_ONLINE_MODIFY_GNB2_004 = [
    dict(value='true', dist_name=_NRBTSname2, parameter='actNrLBRTXPowerSaving'),
    dict(value='true', dist_name=_NRCELL23, parameter='actDtxOptimizedScheduler')
]

PARAMETERS_TO_ONLINE_MODIFY_GNB2_004_1 = [
    dict(value='false', dist_name=_NRBTSname2, parameter='actNrLBRTXPowerSaving')
]

PARAMETERS_TO_ONLINE_MODIFY_GNB2_004_ANT13 = [
    dict(value='true', dist_name=_NRBTSname2, parameter='actNrLBRTXPowerSaving'),
    dict(value=_MRBTSname2 + '/EQM-1/APEQM-1/RMOD-3/ANTL-3', dist_name=_CHANNELGROUP4, parameter='antlDN'),
]

PARAMETERS_TO_ONLINE_MODIFY_GNB2_004_ANT24 = [
    dict(value='true', dist_name=_NRBTSname2, parameter='actNrLBRTXPowerSaving'),
    dict(value=_MRBTSname2 + '/EQM-1/APEQM-1/RMOD-3/ANTL-2', dist_name=_CHANNELGROUP2, parameter='antlDN'),
    dict(value=_MRBTSname2 + '/EQM-1/APEQM-1/RMOD-3/ANTL-4', dist_name=_CHANNELGROUP4, parameter='antlDN'),
]

PARAMETERS_TO_ONLINE_MODIFY_GNB2_004_4T2R = [
    dict(value='4DL2UL', dist_name=_NRCELL23, parameter='nrCellType'),
]

# Add_Mo_Online_GNB2_004_4T4R = [
#     dict(value=_MRBTSname2 + '/EQM-1/APEQM-1/RMOD-3/ANTL-3', dist_name=_CHANNELGROUP7, parameter='antlDN'),
#     dict(value='7', dist_name=_CHANNELGROUP7, parameter='channelId'),
#     dict(value='RX', dist_name=_CHANNELGROUP7, parameter='direction'),
#     dict(value=_MRBTSname2 + '/EQM-1/APEQM-1/RMOD-3/ANTL-4', dist_name=_CHANNELGROUP8, parameter='antlDN'),
#     dict(value='8', dist_name=_CHANNELGROUP8, parameter='channelId'),
#     dict(value='RX', dist_name=_CHANNELGROUP8, parameter='direction'),
# ]

PARAMETERS_TO_ONLINE_MODIFY_GNB2_004_2 = [
    dict(value='false', dist_name=_NRCELL23, parameter='actDtxOptimizedScheduler'),
    dict(value='true', dist_name=_NRBTSname2, parameter='actNrLBRTXPowerSaving'),
]

PARAMETERS_TO_ONLINE_RECOVERY_GNB2_004 = [
    dict(value='false', dist_name=_NRBTSname2, parameter='actNrLBRTXPowerSaving'),
    dict(value='false', dist_name=_NRCELL23, parameter='actDtxOptimizedScheduler')
]

# PARAMETERS_TO_ONLINE_RECOVERY_GNB1_008 = [
#     dict(value='true', dist_name=_NRBTSname, parameter='actNrLBRTXPowerSaving'),
#     dict(value='true', dist_name=_NRCELL13, parameter='actDtxOptimizedScheduler'),
#
# ]

Delete_Mo_Online_GNB2_004 = [
    dict(dist_name=_CHANNELGROUP6),
    dict(dist_name=_CHANNELGROUP8),
]

# PARAMETERS_TO_ONLINE_MODIFY_GNB1_005 = [
#     dict(value='true', dist_name=_NRBTSname, parameter='actNrLBRTXPowerSaving'),
#     dict(value='true', dist_name=_NRBTSname, parameter='actNrLBPowerSaving'),
#     dict(value='true', dist_name=_NRBTSname, parameter='actNrMixedSOMethod'),
#     dict(value=[dict(lbpsDayOfWeek=weekday, lbpsDuration=1440)],
#          dist_name=_NRBTSname + '/NRPGRP-1', parameter='lbpsPeriodList'),
#     dict(value=[dict(lbpsDayOfWeek=weekday, lbpsDuration=1440)],
#          dist_name=_NRBTSname + '/NRPGRP-2', parameter='lbpsPeriodList')
# ]
#
# PARAMETERS_TO_ONLINE_MODIFY_GNB1_005_Recover = [
#     dict(value='true', dist_name=_NRBTSname, parameter='actNrLBRTXPowerSaving'),
#     dict(value='true', dist_name=_NRBTSname, parameter='actNrLBPowerSaving'),
#     dict(value='true', dist_name=_NRBTSname, parameter='actNrMixedSOMethod'),
#     dict(value=[dict(lbpsDuration=1)],
#          dist_name=_NRBTSname + '/NRPGRP-1', parameter='lbpsPeriodList'),
#     dict(value=[dict(lbpsDuration=1)],
#          dist_name=_NRBTSname + '/NRPGRP-2', parameter='lbpsPeriodList')
# ]
#
# PARAMETERS_TO_ONLINE_MODIFY_GNB1_10683_Recover = [
#     dict(value='true', dist_name=_NRBTSname, parameter='actNrLBRTXPowerSaving'),
#     dict(value='true', dist_name=_NRBTSname, parameter='actNrLBPowerSaving'),
#     dict(value='true', dist_name=_NRBTSname, parameter='actNrMixedSOMethod'),
#     dict(value=[dict(lbpsDuration=1)],
#          dist_name=_NRBTSname + '/NRPGRP-1', parameter='lbpsPeriodList')
# ]
#
# PARAMETERS_TO_ONLINE_MODIFY_GNB1_008 = [
#     dict(value='true', dist_name=_NRBTSname, parameter='actNrLBRTXPowerSaving'),
#     dict(value='true', dist_name=_NRCELL13, parameter='actEirpControl')
# ]
#
# PARAMETERS_TO_ONLINE_MODIFY_GNB1_009 = [
#     dict(value='Locked', dist_name=_NRCELL13, parameter='administrativeState')
# ]
#
# PARAMETERS_TO_ONLINE_MODIFY_GNB1_009_1 = [
#     dict(value='Unlocked', dist_name=_NRCELL13, parameter='administrativeState')
# ]
#
# PARAMETERS_TO_ONLINE_MODIFY_GNB1_009_2 = [
#     dict(value='Locked', dist_name=_RMOD3, parameter='administrativeState')
# ]
#
# PARAMETERS_TO_ONLINE_MODIFY_GNB1_009_3 = [
#     dict(value='Unlocked', dist_name=_RMOD3, parameter='administrativeState')
# ]

counter_id_003_gnb1 = [
    'M40003C4'
]

counter_dic_path_003_gnb1_Trunk = [
    'BTS/' + _MRBTSname2 + '/EQM-1/APEQM-1/RMOD-3/SBTS_RFM_Energy_Monitoring'
]

counter_dic_path_003_gnb1 = [
    'BTS/BTS/' + _MRBTSname2 + '/RMOD-3/SBTS_RFM_Energy_Monitoring'
]

# counter_id_008_gnb1 = [
#     'M55324C00000'
# ]

# counter_dic_path_008_gnb1_Trunk = [
#     'BTS/' + _NRBTSname2 + '/NRCELL-3/NREIRP'
# ]
#
# counter_dic_path_008_gnb1 = [
#     'BTS/CELLS/NRCELL-3/NREIRP'
# ]
#
# DELETE_MO_ONLINE_GNB1_10683 = [
#     {'dist_name': _NRPGRP1},
#     {'dist_name': _NRPGRP2}
# ]

# PARAMETERS_TO_ONLINE_MODIFY_GNB1_10683 = [
#     dict(value='true', dist_name=_NRBTSname, parameter='actNrLBPowerSaving'),
#     dict(value='true', dist_name=_NRBTSname, parameter='actNrLBRTXPowerSaving'),
#     dict(value='true', dist_name=_NRBTSname, parameter='actNrExtCellSOMethod')
# ]
#
# PARAMETERS_TO_ONLINE_MODIFY_GNB1_10683_1 = [
#     dict(value=[dict(lbpsCellSOMethod='cell switch off'), dict(lbpsCellSOMethod='TX switch off')],
#          dist_name=_NRPGRP1, parameter='lbpsCellPeriodList'),
# ]
#
# PARAMETERS_TO_ONLINE_MODIFY_GNB1_10683_2 = [
#     dict(value=[dict(lbpsCellSOMethod='TX switch off'), dict(lbpsCellSOMethod='TX switch off')],
#          dist_name=_NRPGRP1, parameter='lbpsCellPeriodList'),
# ]
#
# ADD_MO_ONLINE_GNB1_10683 = [
#     dict(value=[dict(lbpsCellSOOrder='1', lbpsUseExtConfig='true', nrCellId='3'),
#                 dict(lbpsCellSOOrder='2', lbpsUseExtConfig='true', nrCellId='31')],
#          dist_name=_NRPGRP1, parameter='lbpsCellList'),
#     dict(value=[dict(lbpsCellDayOfWeek=weekday, lbpsCellDuration='1440', lbpsCellSOMethod='TX switch off',
#                      lbpsCellStartTimeHour='0', lbpsCellStartTimeMinute='0', nrCellId='3'),
#                 dict(lbpsCellDayOfWeek=weekday, lbpsCellDuration='1440', lbpsCellSOMethod='cell switch off',
#                      lbpsCellStartTimeHour='0', lbpsCellStartTimeMinute='0', nrCellId='31')],
#          dist_name=_NRPGRP1, parameter='lbpsCellPeriodList'),
#     dict(value='true', dist_name=_NRPGRP1, parameter='lbpsCSONCtlEnabled'),
#     dict(value='20', dist_name=_NRPGRP1, parameter='lbpsLastCellMinLoad'),
#     dict(value='20', dist_name=_NRPGRP1, parameter='lbpsLastCellRTXMinLoad'),
#     dict(value='true', dist_name=_NRPGRP1, parameter='lbpsLastCellSOEnabled'),
#     dict(value='60', dist_name=_NRPGRP1, parameter='lbpsMaxLoad'),
#     dict(value='20', dist_name=_NRPGRP1, parameter='lbpsMinLoad'),
#     dict(value='4', dist_name=_NRPGRP1, parameter='lbpsPdcchLoadOffset'),
#     dict(value=[dict(lbpsDayOfWeek=weekday, lbpsDuration='1440', lbpsStartTimeHour='0', lbpsStartTimeMinute='0',
#                      lbpsSuspended='notSuspended')],
#          dist_name=_NRPGRP1, parameter='lbpsPeriodList'),
#     dict(value='70', dist_name=_NRPGRP1, parameter='lbpsRTXCellCapOffset'),
#     dict(value='60', dist_name=_NRPGRP1, parameter='lbpsRTXMaxLoad'),
#     dict(value='20', dist_name=_NRPGRP1, parameter='lbpsRTXMinLoad'),
#     dict(value='30', dist_name=_NRPGRP1, parameter='lbpsRTXSOffTime'),
#     dict(value='30', dist_name=_NRPGRP1, parameter='lbpsRTXSOnTime'),
#     dict(value='TX switch off', dist_name=_NRPGRP1, parameter='lbpsSOMethod'),
#     dict(value='1', dist_name=_NRPGRP1, parameter='nrPGrpId')
# ]
