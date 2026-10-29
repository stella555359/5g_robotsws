import os
from taf.config.testline.info import info
from robot.libraries.BuiltIn import BuiltIn
import time
from datetime import datetime

tl = BuiltIn().get_variable_value("${tl}")
mr_bts_id = tl.gnbs[0].instance_id
nr_bts_id = tl.gnbs[0].global_bts_id
_MRBTSname = 'MRBTS-' + str(mr_bts_id)
_NRBTSname = _MRBTSname + '/NRBTS-' + str(nr_bts_id)
_NRBTS_ID = 'NRBTS-' + str(nr_bts_id)

ENB_BRANCH = BuiltIn().get_variable_value("${ENB_BRANCH}")

current_time = time.localtime(time.time() + 28800)
year = current_time.tm_year
month = current_time.tm_mon
day = current_time.tm_mday
date = datetime.date(datetime(year=year, month=month, day=day))
weekday = date.strftime("%a")

CB011016_lbpsPeriod_List = [
    {
        'dist_name': _NRBTSname + '/NRPGRP-1',
        'parameter': 'lbpsPeriodList',
        'value': [{
            'lbpsDayOfWeek': weekday,
            'lbpsDuration': '1440',
            'lbpsStartTimeHour': '0',
            'lbpsStartTimeMinute': '0',
            'lbpsSuspended': 'notSuspended'
        }]
    },
    {
        'dist_name': _NRBTSname + '/NRPGRP-2',
        'parameter': 'lbpsPeriodList',
        'value': [{
            'lbpsDayOfWeek': weekday,
            'lbpsDuration': '1440',
            'lbpsStartTimeHour': '0',
            'lbpsStartTimeMinute': '0',
            'lbpsSuspended': 'notSuspended'
        }]
    }
]

CB011016_5GC000431_Enable_Flag = [
    {
        'dist_name': _NRBTSname,
        'parameter': 'actNrLBRTXPowerSaving',
        'value': 'true'
    },
    {
        'dist_name': _NRBTSname,
        'parameter': 'actNrLBPowerSaving',
        'value': 'true'
    }
]

CB011016_5GC000431_Disable_Flag = [
    {
        'dist_name': _NRBTSname,
        'parameter': 'actNrLBRTXPowerSaving',
        'value': 'false'
    },
    {
        'dist_name': _NRBTSname,
        'parameter': 'actNrLBPowerSaving',
        'value': 'false'
    }
]

CB011016_Enable_Flag = [
    {
        'dist_name': _NRBTSname,
        'parameter': 'actNrLBRTXPowerSaving',
        'value': 'true'
    }
]

CB011016_Disable_Flag = [
    {
        'dist_name': _NRBTSname,
        'parameter': 'actNrLBRTXPowerSaving',
        'value': 'false'
    }
]

CB011016_Lock_Cell = [
    {
        'dist_name': _NRBTSname + '/NRCELL-1',
        'parameter': 'administrativeState',
        'value': 'Locked'
    }
]

CB011016_Unlock_Cell = [
    {
        'dist_name': _NRBTSname + '/NRCELL-1',
        'parameter': 'administrativeState',
        'value': 'Unlocked'
    }
]

CB011016_Lock_RMOD = [
    {
        'dist_name': _MRBTSname + '/EQM-1/APEQM-1/RMOD-1',
        'parameter': 'administrativeState',
        'value': 'Locked'
    }
]

CB011016_Unlock_RMOD = [
    {
        'dist_name': _MRBTSname + '/EQM-1/APEQM-1/RMOD-1',
        'parameter': 'administrativeState',
        'value': 'Unlocked'
    }
]

if ENB_BRANCH == 'SBTS23R4' or ENB_BRANCH == 'SBTS24R1':
    CB011016_Counter_Path = [
        'BTS/BTS/' + _MRBTSname + '/RMOD-1/SBTS_RFM_Energy_Monitoring'
    ]
else:
    CB011016_Counter_Path = [
        'BTS/' + _MRBTSname + '/EQM-1/APEQM-1/RMOD-1/SBTS_RFM_Energy_Monitoring'
    ]


CB010683_lbpsPeriod_List = [
    {
        'dist_name': _NRBTSname + '/NRPGRP-1',
        'parameter': 'lbpsPeriodList',
        'value': [{
            'lbpsDayOfWeek': weekday,
            'lbpsDuration': '1440',
            'lbpsStartTimeHour': '0',
            'lbpsStartTimeMinute': '0',
            'lbpsSuspended': 'notSuspended'
        }]
    },
    {
        'dist_name': _NRBTSname + '/NRPGRP-1',
        'parameter': 'lbpsCellPeriodList',
        'value': [{
            'lbpsCellDayOfWeek': weekday,
            'lbpsCellDuration': '1440',
            'lbpsCellSOMethod': 'cell switch off',
            'lbpsCellStartTimeHour': '0',
            'lbpsCellStartTimeMinute': '0',
            'nrCellId': '2'
            },
            {
            'lbpsCellDayOfWeek': weekday,
            'lbpsCellDuration': '1440',
            'lbpsCellSOMethod': 'TX switch off',
            'lbpsCellStartTimeHour': '0',
            'lbpsCellStartTimeMinute': '0',
            'nrCellId': '3'
            }
        ]
    }
]

CB010683_lbpsCellPeriod_List_Update = [
    {
        'dist_name': _NRBTSname + '/NRPGRP-1',
        'parameter': 'lbpsCellPeriodList',
        'value': [{
            'lbpsCellDayOfWeek': weekday,
            'lbpsCellDuration': '1440',
            'lbpsCellSOMethod': 'TX switch off',
            'lbpsCellStartTimeHour': '0',
            'lbpsCellStartTimeMinute': '0',
            'nrCellId': '2'
            },
            {
            'lbpsCellDayOfWeek': weekday,
            'lbpsCellDuration': '1440',
            'lbpsCellSOMethod': 'cell switch off',
            'lbpsCellStartTimeHour': '0',
            'lbpsCellStartTimeMinute': '0',
            'nrCellId': '3'
            }
        ]
    }
]
