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
NRCELL_FDD = '[TL37215_CB012149] MRBTS-37215/NRBTS-37215/[FDD-Cell01] NRCELL-4'
NRCELL_TDD = '[TL37215_CB012149] MRBTS-37215/NRBTS-37215/NRCELL-1'

CB012149_enable_ulTxSwitching = [
    {
        'dist_name': _NRBTSname + '/NRDU-1',
        'parameter': 'ulTxSwitchingSupportList',
        'value': ['ca_Fr1T_F_Sa_switchedUl']
    }
]

CB012149_disable_ulTxSwitching = [
    {
        'dist_name': _NRBTSname + '/NRDU-1',
        'parameter': 'ulTxSwitchingSupportList',
        'value': ['none']
    }
]

CB012149_enable_UlCaUeParallelTx = [
    {
        'dist_name': _NRBTSname + '/NRCELL-1',
        'parameter': 'maxNumOfUlCaUeParallelTx',
        'value': 1
    }
]

CB012149_legacy_ULCA = [
    {
        'dist_name': _NRBTSname + '/NRDU-1',
        'parameter': 'ulTxSwitchingSupportList',
        'value': ['none']
    },
    {
        'dist_name': _NRBTSname + '/NRCELL-1',
        'parameter': 'maxNumOfUlCaUeParallelTx',
        'value': 0
    }
]

COUNTERS_CB008709_FDD = [
    dict(
         counter_id='M55308C10013',
         full_path=NRCELL_FDD + '/NCELA/DL_PRB_AVAIL_SAS'
         ),
    dict(
         counter_id='M55910C00001',
         full_path=NRCELL_FDD + '/NRRESOURCEGROUP-32/NCUPNRG/DL_PRB_USED_DATA_NRG'
         ),
    dict(
         counter_id='M55910C00002',
         full_path=NRCELL_FDD + '/NRRESOURCEGROUP-32/NCUPNRG/DL_PRB_UTIL_SLOT_MAX_NRG'
         ),
    dict(
         counter_id='M55308C10012',
         full_path=NRCELL_FDD + '/NCELA/UL_PRB_AVAIL_SAS'
         ),
    dict(
         counter_id='M55910C00003',
         full_path=NRCELL_FDD + '/NRRESOURCEGROUP-32/NCUPNRG/UL_PRB_USED_DATA_NRG'
         ),
    dict(
         counter_id='M55910C00004',
         full_path=NRCELL_FDD + '/NRRESOURCEGROUP-32/NCUPNRG/UL_PRB_UTIL_SLOT_MAX_NRG'
         )
]

COUNTERS_CB008709_TDD = [
    dict(
         counter_id='M55308C10013',
         full_path=NRCELL_TDD + '/NCELA/DL_PRB_AVAIL_SAS'
         ),
    dict(
         counter_id='M55910C00001',
         full_path=NRCELL_TDD + '/NRRESOURCEGROUP-1/NCUPNRG/DL_PRB_USED_DATA_NRG'
         ),
    dict(
         counter_id='M55910C00002',
         full_path=NRCELL_TDD + '/NRRESOURCEGROUP-1/NCUPNRG/DL_PRB_UTIL_SLOT_MAX_NRG'
         ),
    dict(
         counter_id='M55308C10012',
         full_path=NRCELL_TDD + '/NCELA/UL_PRB_AVAIL_SAS'
         ),
    dict(
         counter_id='M55910C00003',
         full_path=NRCELL_TDD + '/NRRESOURCEGROUP-1/NCUPNRG/UL_PRB_USED_DATA_NRG'
         ),
    dict(
         counter_id='M55910C00004',
         full_path=NRCELL_TDD + '/NRRESOURCEGROUP-1/NCUPNRG/UL_PRB_UTIL_SLOT_MAX_NRG'
         )
]
