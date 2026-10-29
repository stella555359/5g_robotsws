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

ENB_BRANCH = BuiltIn().get_variable_value("${target_version.split('_', )[0]}")


CB009510_update_pamater = [
    {
        'dist_name': _NRBTSname + '/NRCELL-4',
        'parameter': 'periodicCsiAcquisition',
        'value': [{
            'csiReportPeriodicity': 'slots40',
            'csirsNumberWithinReportPeriod_Set1': '2',
            'csirsPower': '8',
            'maxCsirsNumber': '4',
            'scramblingIdStep': '3'
        }],
    },
    {
        'dist_name': _NRBTSname + '/NRCELL-4',
        'parameter': 'ssPbchBlockPower',
        'value': '8'
    }
]
CB009510_recovery_update_pamater = [
    {
        'dist_name': _NRBTSname + '/NRCELL-4',
        'parameter': 'periodicCsiAcquisition',
        'value': [{
            'csiReportPeriodicity': 'slots40',
            'csirsNumberWithinReportPeriod_Set1': '2',
            'csirsPower': '8',
            'maxCsirsNumber': '4',
            'scramblingIdStep': '3'
        }],
    },
    {
        'dist_name': _NRBTSname + '/NRCELL-4',
        'parameter': 'ssPbchBlockPower',
        'value': '5'
    }
]

CB009510_B_03_update_pamater = [
    {
        'dist_name': _NRBTSname + '/NRCELL-4',
        'parameter': 'periodicCsiAcquisition',
        'value': [{
            'csiReportPeriodicity': 'slots40',
            'csirsNumberWithinReportPeriod_Set1': '2',
            'csirsPower': '11',
            'maxCsirsNumber': '4',
            'scramblingIdStep': '3'
        }],
    }
]

CB009510_B_03_recovery_update_pamater = [
    {
        'dist_name': _NRBTSname + '/NRCELL-4',
        'parameter': 'periodicCsiAcquisition',
        'value': [{
            'csiReportPeriodicity': 'slots40',
            'csirsNumberWithinReportPeriod_Set1': '2',
            'csirsPower': '8',
            'maxCsirsNumber': '4',
            'scramblingIdStep': '3'
        }],
    }
]

CB009510_B_06_update_pamater = [
    {
        'dist_name': _NRBTSname + '/NRCELL-1',
        'parameter': 'actPdschRmCsirsForTracking',
        'value': 'true'
    },
    {
        'dist_name': _NRBTSname + '/NRCELL-1',
        'parameter': 'actPdschAtSsbSlots',
        'value': 'true'
    },
    {
        'dist_name': _NRBTSname + '/NRCELL-1',
        'parameter': 'actPdschAllocAroundSsb',
        'value': 'true'
    },
    {
        'dist_name': _NRBTSname + '/NRCELL-11',
        'parameter': 'actPdschRmCsirsForTracking',
        'value': 'true'
    },
    {
        'dist_name': _NRBTSname + '/NRCELL-11',
        'parameter': 'actPdschAtSsbSlots',
        'value': 'true'
    },
    {
        'dist_name': _NRBTSname + '/NRCELL-11',
        'parameter': 'actPdschAllocAroundSsb',
        'value': 'true'
    },
    {
        'dist_name': _NRBTSname + '/NRCELL-3',
        'parameter': 'actPdschRmCsirsForTracking',
        'value': 'true'
    },
    {
        'dist_name': _NRBTSname + '/NRCELL-3',
        'parameter': 'actPdschAtSsbSlots',
        'value': 'true'
    },
    {
        'dist_name': _NRBTSname + '/NRCELL-3',
        'parameter': 'actPdschAllocAroundSsb',
        'value': 'true'
    },
    {
        'dist_name': _NRBTSname + '/NRCELL-31',
        'parameter': 'actPdschRmCsirsForTracking',
        'value': 'true'
    },
    {
        'dist_name': _NRBTSname + '/NRCELL-31',
        'parameter': 'actPdschAtSsbSlots',
        'value': 'true'
    },
    {
        'dist_name': _NRBTSname + '/NRCELL-31',
        'parameter': 'actPdschAllocAroundSsb',
        'value': 'true'
    },
    {
        'dist_name': _NRBTSname + '/NRCELL-4',
        'parameter': 'actPdschRmCsirsForTracking',
        'value': 'true'
    },
    {
        'dist_name': _NRBTSname + '/NRCELL-4',
        'parameter': 'actPdschAtSsbSlots',
        'value': 'true'
    },
    {
        'dist_name': _NRBTSname + '/NRCELL-4',
        'parameter': 'actPdschAllocAroundSsb',
        'value': 'true'
    },
    {
        'dist_name': _NRBTSname + '/NRCELL-41',
        'parameter': 'actPdschRmCsirsForTracking',
        'value': 'true'
    },
    {
        'dist_name': _NRBTSname + '/NRCELL-41',
        'parameter': 'actPdschAtSsbSlots',
        'value': 'true'
    },
    {
        'dist_name': _NRBTSname + '/NRCELL-41',
        'parameter': 'actPdschAllocAroundSsb',
        'value': 'true'
    }
]

CB009510_B_06_recovery_pamater = [
    {
        'dist_name': _NRBTSname + '/NRCELL-1',
        'parameter': 'actPdschRmCsirsForTracking',
        'value': 'false'
    },
    {
        'dist_name': _NRBTSname + '/NRCELL-1',
        'parameter': 'actPdschAtSsbSlots',
        'value': 'false'
    },
    {
        'dist_name': _NRBTSname + '/NRCELL-1',
        'parameter': 'actPdschAllocAroundSsb',
        'value': 'false'
    },
    {
        'dist_name': _NRBTSname + '/NRCELL-11',
        'parameter': 'actPdschRmCsirsForTracking',
        'value': 'false'
    },
    {
        'dist_name': _NRBTSname + '/NRCELL-11',
        'parameter': 'actPdschAtSsbSlots',
        'value': 'false'
    },
    {
        'dist_name': _NRBTSname + '/NRCELL-11',
        'parameter': 'actPdschAllocAroundSsb',
        'value': 'false'
    },
    {
        'dist_name': _NRBTSname + '/NRCELL-3',
        'parameter': 'actPdschRmCsirsForTracking',
        'value': 'false'
    },
    {
        'dist_name': _NRBTSname + '/NRCELL-3',
        'parameter': 'actPdschAtSsbSlots',
        'value': 'false'
    },
    {
        'dist_name': _NRBTSname + '/NRCELL-3',
        'parameter': 'actPdschAllocAroundSsb',
        'value': 'false'
    },
    {
        'dist_name': _NRBTSname + '/NRCELL-31',
        'parameter': 'actPdschRmCsirsForTracking',
        'value': 'false'
    },
    {
        'dist_name': _NRBTSname + '/NRCELL-31',
        'parameter': 'actPdschAtSsbSlots',
        'value': 'false'
    },
    {
        'dist_name': _NRBTSname + '/NRCELL-31',
        'parameter': 'actPdschAllocAroundSsb',
        'value': 'false'
    },
    {
        'dist_name': _NRBTSname + '/NRCELL-4',
        'parameter': 'actPdschRmCsirsForTracking',
        'value': 'false'
    },
    {
        'dist_name': _NRBTSname + '/NRCELL-4',
        'parameter': 'actPdschAtSsbSlots',
        'value': 'false'
    },
    {
        'dist_name': _NRBTSname + '/NRCELL-4',
        'parameter': 'actPdschAllocAroundSsb',
        'value': 'false'
    },
    {
        'dist_name': _NRBTSname + '/NRCELL-41',
        'parameter': 'actPdschRmCsirsForTracking',
        'value': 'false'
    },
    {
        'dist_name': _NRBTSname + '/NRCELL-41',
        'parameter': 'actPdschAtSsbSlots',
        'value': 'false'
    },
    {
        'dist_name': _NRBTSname + '/NRCELL-41',
        'parameter': 'actPdschAllocAroundSsb',
        'value': 'false'
    }
]
