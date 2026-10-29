import os
from robot.libraries.BuiltIn import BuiltIn
tl = BuiltIn().get_variable_value('${tl}')
CFG_DIR = os.path.dirname(os.path.abspath(__file__))

MR_NR_CELL_NAME = 'MRBTS-' + str(tl.gnbs[0].global_bts_id) + '/NRBTS-' + str(tl.gnbs[0].global_bts_id) + \
    '/NRCELL-4'

MR_NR_CELLGRP_NAME = 'MRBTS-' + str(tl.gnbs[0].global_bts_id) + '/NRBTS-' + str(tl.gnbs[0].global_bts_id) + \
    '/NRCELLGRP-3'

MR_NR_BTS_NAME = 'MRBTS-' + str(tl.gnbs[0].global_bts_id) + '/NRBTS-' + str(tl.gnbs[0].global_bts_id)

CB009510_update_pamater = [
    {
        'dist_name': MR_NR_CELL_NAME,
        'parameter': 'periodicCsiAcquisition',
        'value': [{
            'csiReportPeriodicity': 'slots320',
            'csirsNumberWithinReportPeriod_Set1': '1',
            'csirsPower': '15',
            'maxCsirsNumber': '4',
            'scramblingIdStep': '3'
        }],
    },
    {
        'dist_name': MR_NR_CELL_NAME,
        'parameter': 'ssPbchBlockPower',
        'value': '15'
    }
]
CB009510_recovery_update_pamater = [
    {
        'dist_name': MR_NR_CELL_NAME,
        'parameter': 'periodicCsiAcquisition',
        'value': [{
            'csiReportPeriodicity': 'slots320',
            'csirsNumberWithinReportPeriod_Set1': '1',
            'csirsPower': '12',
            'maxCsirsNumber': '4',
            'scramblingIdStep': '3'
        }],
    },
    {
        'dist_name': MR_NR_CELL_NAME,
        'parameter': 'ssPbchBlockPower',
        'value': '12'
    }
]

CB009510_A_01_update_pamater = [
    {
        'dist_name': MR_NR_CELL_NAME,
        'parameter': 'ssPbchBlockPower',
        'value': '6'
    }
]

CB009510_A_01_recovery_pamater = [
    {
        'dist_name': MR_NR_CELL_NAME,
        'parameter': 'ssPbchBlockPower',
        'value': '12'
    }
]

CB009510_B_03_recovery_update_pamater = [
    {
        'dist_name': MR_NR_CELL_NAME,
        'parameter': 'periodicCsiAcquisition',
        'value': [{
            'csiReportPeriodicity': 'slots320',
            'csirsNumberWithinReportPeriod_Set1': '1',
            'csirsPower': '12',
            'maxCsirsNumber': '4',
            'scramblingIdStep': '3'
        }],
    }
]

CB009510_B_03_update_pamater = [
    {
        'dist_name': MR_NR_CELL_NAME,
        'parameter': 'periodicCsiAcquisition',
        'value': [{
            'csiReportPeriodicity': 'slots320',
            'csirsNumberWithinReportPeriod_Set1': '1',
            'csirsPower': '15',
            'maxCsirsNumber': '4',
            'scramblingIdStep': '3'
        }],
    }
]

CB009510_B_06_update_pamater = [
    {
        'dist_name': MR_NR_CELL_NAME,
        'parameter': 'actPdschRmCsirsForTracking',
        'value': 'true'
    },
    {
        'dist_name': MR_NR_CELL_NAME,
        'parameter': 'actPdschAtSsbSlots',
        'value': 'true'
    },
    {
        'dist_name': MR_NR_CELL_NAME,
        'parameter': 'actPdschAllocAroundSsb',
        'value': 'true'
    }
]

CB009510_B_06_recovery_pamater = [
    {
        'dist_name': MR_NR_CELL_NAME,
        'parameter': 'actPdschRmCsirsForTracking',
        'value': 'false'
    },
    {
        'dist_name': MR_NR_CELL_NAME,
        'parameter': 'actPdschAtSsbSlots',
        'value': 'false'
    },
    {
        'dist_name': MR_NR_CELL_NAME,
        'parameter': 'actPdschAllocAroundSsb',
        'value': 'true'
    }
]
