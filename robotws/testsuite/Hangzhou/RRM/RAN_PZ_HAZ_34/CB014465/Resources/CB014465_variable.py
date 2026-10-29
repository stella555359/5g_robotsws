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

CB014465_enable_MulSrsSplSlot = [
    {
        'dist_name': _NRBTSname + '/NRCELL-4',
        'parameter': 'actMulSrsInSplSlot',
        'value': 'true'
    }
]

COUNTERS_10938 = dict(
         UE_CHIPSET_VENDOR_NUM_SUP='M55124C00025',
         UE_CHIPSET_VENDOR_RECV_ERR='M55124C00027',
)

COUNTERS_10938 = [
    dict(
         counter_id='M55124C00025',
         full_path='[TL775_CB012591] ' + _MRBTSname + '/' + _NRBTS_ID + '/NRCELL-4/NRRCC/UE_CHIPSET_VENDOR_NUM_SUP'
         ),
    dict(
         counter_id='M55124C00027',
         full_path='[TL775_CB012591] ' + _MRBTSname + '/' + _NRBTS_ID + '/NRCELL-4/NRRCC/UE_CHIPSET_VENDOR_RECV_ERR'
         )
]
