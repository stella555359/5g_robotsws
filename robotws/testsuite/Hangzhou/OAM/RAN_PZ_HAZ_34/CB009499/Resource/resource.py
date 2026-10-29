# copyright: Nokia 5G RAN
# Contact: I_MN_5G_RAN_IV4_LINE_HZG_8_IV@internal.nsn.com
from testsuite.Hangzhou.OAM.RAN_PZ_HAZ_34.libraries.global_vars import *

DICT__param_change = {
    'AZHL': {
        '5GC001208_10MHZ': [
            {'dist_name': 'MRBTS-10566/NRBTS-10566/NRCELL-1',
             'filter_param': 'NR Absolute radio frequency channel number',
             'abbr': 'nrarfcn', 'new_value': '510006'},
            {'dist_name': 'MRBTS-10566/NRBTS-10566/NRCELL-1', 'filter_param': 'Frame Structure Type',
             'abbr': 'frameStructureType', 'new_value': 'semiStatic'},
            {'dist_name': 'MRBTS-10566/NRBTS-10566/NRCELL-1', 'filter_param': 'Guard Period length',
             'abbr': 'guardPeriodLength', 'new_value': '2Symbols'},
            {'dist_name': 'MRBTS-10566/NRBTS-10566/NRCELL-1', 'filter_param': 'LTE to NR frame shift',
             'abbr': 'lteToNrFrameShift', 'new_value': 'NA'},
            {'dist_name': 'MRBTS-10566/NRBTS-10566/NRCELL-1', 'filter_param': 'TDLTE UL-DL configuration',
             'abbr': 'tdLteUlDlConfig', 'new_value': 'NA'},
            {'dist_name': 'MRBTS-10566/NRBTS-10566/NRCELL-1', 'filter_param': 'UL to DL logical data slot ratio',
             'abbr': 'ulDlDataSlotRatio', 'new_value': '1/4'},
            {'dist_name': 'MRBTS-10566/NRBTS-10566/NRCELL-1', 'filter_param': 'Search space configuration Index',
             'abbr': 'type0SearchSpaceConfigurationIndex',
             'new_value': '2'},
            {'dist_name': 'MRBTS-10566/NRBTS-10566/NRCELL-1', 'filter_param': 'Coreset configuration Index',
             'abbr': 'type0CoresetConfigurationIndex', 'new_value': '2'},
            {'dist_name': 'MRBTS-10566/NRBTS-10566/NRCELL-1', 'filter_param': 'PRACH configuration index',
             'abbr': 'prachConfigurationIndex', 'new_value': '98'},
            {'dist_name': 'MRBTS-10566/NRBTS-10566/NRCELL-1', 'filter_param': 'SS PBCH Block Power',
             'abbr': 'ssPbchBlockPower', 'new_value': '10'},
            {'dist_name': 'MRBTS-10566/NRBTS-10566/NRCELL-1', 'filter_param': 'PRACH Frequency start',
             'abbr': 'msg1FrequencyStart', 'new_value': '6'},
            {'dist_name': 'MRBTS-10566/NRBTS-10566/NRCELL-1',
             'filter_param': 'Bandwidth Part Profile distinguished name',
             'abbr': 'bwpDN',
             'new_value': 'MRBTS-10566/NRBTS-10566/BWP_PROFILE-5', 'node_index': 0},
            {'dist_name': 'MRBTS-10566/NRBTS-10566/NRCELL-1',
             'filter_param': 'Bandwidth Part Profile distinguished name',
             'abbr': 'bwpDN',
             'new_value': 'MRBTS-10566/NRBTS-10566/BWP_PROFILE-50', 'node_index': 1}
        ],
        '5GC001070_10MHZ': [
            {'dist_name': 'MRBTS-10566/NRBTS-10566/NRCELL-1',
             'filter_param': 'NR Absolute radio frequency channel number',
             'abbr': 'nrarfcn', 'new_value': '509898'},
            {'dist_name': 'MRBTS-10566/NRBTS-10566/NRCELL-1', 'filter_param': 'Frame Structure Type',
             'abbr': 'frameStructureType', 'new_value': 'semiStatic'},
            {'dist_name': 'MRBTS-10566/NRBTS-10566/NRCELL-1', 'filter_param': 'Guard Period length',
             'abbr': 'guardPeriodLength', 'new_value': '2Symbols'},
            {'dist_name': 'MRBTS-10566/NRBTS-10566/NRCELL-1', 'filter_param': 'LTE to NR frame shift',
             'abbr': 'lteToNrFrameShift', 'new_value': 'NA'},
            {'dist_name': 'MRBTS-10566/NRBTS-10566/NRCELL-1', 'filter_param': 'TDLTE UL-DL configuration',
             'abbr': 'tdLteUlDlConfig', 'new_value': 'NA'},
            {'dist_name': 'MRBTS-10566/NRBTS-10566/NRCELL-1', 'filter_param': 'UL to DL logical data slot ratio',
             'abbr': 'ulDlDataSlotRatio', 'new_value': '3/7'},
            {'dist_name': 'MRBTS-10566/NRBTS-10566/NRCELL-1', 'filter_param': 'Search space configuration Index',
             'abbr': 'type0SearchSpaceConfigurationIndex',
             'new_value': '4'},
            {'dist_name': 'MRBTS-10566/NRBTS-10566/NRCELL-1', 'filter_param': 'Coreset configuration Index',
             'abbr': 'type0CoresetConfigurationIndex', 'new_value': '0'},
            {'dist_name': 'MRBTS-10566/NRBTS-10566/NRCELL-1', 'filter_param': 'PRACH configuration index',
             'abbr': 'prachConfigurationIndex', 'new_value': '98'},
            {'dist_name': 'MRBTS-10566/NRBTS-10566/NRCELL-1', 'filter_param': 'SS PBCH Block Power',
             'abbr': 'ssPbchBlockPower', 'new_value': '10'},
            {'dist_name': 'MRBTS-10566/NRBTS-10566/NRCELL-1', 'filter_param': 'PRACH Frequency start',
             'abbr': 'msg1FrequencyStart', 'new_value': '6'},
            {'dist_name': 'MRBTS-10566/NRBTS-10566/NRCELL-1',
             'filter_param': 'Bandwidth Part Profile distinguished name',
             'abbr': 'bwpDN',
             'new_value': 'MRBTS-10566/NRBTS-10566/BWP_PROFILE-6', 'node_index': 0},
            {'dist_name': 'MRBTS-10566/NRBTS-10566/NRCELL-1',
             'filter_param': 'Bandwidth Part Profile distinguished name',
             'abbr': 'bwpDN',
             'new_value': 'MRBTS-10566/NRBTS-10566/BWP_PROFILE-60',
             'node_index': 1}
        ],
        '5GC001116_0ms_10MHZ': [
            {'dist_name': 'MRBTS-10566/NRBTS-10566/NRCELL-1', 'filter_param': 'Channel bandwidth', 'abbr': 'chBw',
             'new_value': '10MHz'},
            {'dist_name': 'MRBTS-10566/NRBTS-10566/NRCELL-1',
             'filter_param': 'NR Absolute radio frequency channel number',
             'abbr': 'nrarfcn', 'new_value': '510042'},
            {'dist_name': 'MRBTS-10566/NRBTS-10566/NRCELL-1', 'filter_param': 'Frame Structure Type',
             'abbr': 'frameStructureType', 'new_value': 'tdLte'},
            {'dist_name': 'MRBTS-10566/NRBTS-10566/NRCELL-1', 'filter_param': 'Guard Period length',
             'abbr': 'guardPeriodLength', 'new_value': '4Symbols'},
            {'dist_name': 'MRBTS-10566/NRBTS-10566/NRCELL-1', 'filter_param': 'LTE to NR frame shift',
             'abbr': 'lteToNrFrameShift', 'new_value': '0ms'},
            {'dist_name': 'MRBTS-10566/NRBTS-10566/NRCELL-1', 'filter_param': 'TDLTE UL-DL configuration',
             'abbr': 'tdLteUlDlConfig', 'new_value': 'tdLteConfig2'},
            {'dist_name': 'MRBTS-10566/NRBTS-10566/NRCELL-1', 'filter_param': 'UL to DL logical data slot ratio',
             'abbr': 'ulDlDataSlotRatio', 'new_value': '2/8'},
            {'dist_name': 'MRBTS-10566/NRBTS-10566/NRCELL-1', 'filter_param': 'Search space configuration Index',
             'abbr': 'type0SearchSpaceConfigurationIndex',
             'new_value': '9'},
            {'dist_name': 'MRBTS-10566/NRBTS-10566/NRCELL-1', 'filter_param': 'Coreset configuration Index',
             'abbr': 'type0CoresetConfigurationIndex', 'new_value': '1'},
            {'dist_name': 'MRBTS-10566/NRBTS-10566/NRCELL-1', 'filter_param': 'PRACH configuration index',
             'abbr': 'prachConfigurationIndex', 'new_value': '9'},
            {'dist_name': 'MRBTS-10566/NRBTS-10566/NRCELL-1', 'filter_param': 'SS PBCH Block Power',
             'abbr': 'ssPbchBlockPower', 'new_value': '10'},
            {'dist_name': 'MRBTS-10566/NRBTS-10566/NRCELL-1', 'filter_param': 'PRACH Frequency start',
             'abbr': 'msg1FrequencyStart', 'new_value': '6'},
            {'dist_name': 'MRBTS-10566/NRBTS-10566/NRCELL-1', 'filter_param': 'Requested minimum number of PUSCH PRBs',
             'abbr': 'reqMinNumPuschPrb', 'new_value': '12'},
            {'dist_name': 'MRBTS-10566/NRBTS-10566/NRCELL-1',
             'filter_param': 'Bandwidth Part Profile distinguished name',
             'abbr': 'bwpDN',
             'new_value': 'MRBTS-10566/NRBTS-10566/BWP_PROFILE-7', 'node_index': 0},
            {'dist_name': 'MRBTS-10566/NRBTS-10566/NRCELL-1',
             'filter_param': 'Bandwidth Part Profile distinguished name',
             'abbr': 'bwpDN',
             'new_value': 'MRBTS-10566/NRBTS-10566/BWP_PROFILE-70',
             'node_index': 1}
        ],
        '5GC001116_3ms_10MHZ': [
            {'dist_name': 'MRBTS-10566/NRBTS-10566/NRCELL-1',
             'filter_param': 'NR Absolute radio frequency channel number',
             'abbr': 'nrarfcn', 'new_value': '510372'},
            {'dist_name': 'MRBTS-10566/NRBTS-10566/NRCELL-1', 'filter_param': 'Frame Structure Type',
             'abbr': 'frameStructureType', 'new_value': 'tdLte'},
            {'dist_name': 'MRBTS-10566/NRBTS-10566/NRCELL-1', 'filter_param': 'Guard Period length',
             'abbr': 'guardPeriodLength', 'new_value': '4Symbols'},
            {'dist_name': 'MRBTS-10566/NRBTS-10566/NRCELL-1', 'filter_param': 'LTE to NR frame shift',
             'abbr': 'lteToNrFrameShift', 'new_value': '3ms'},
            {'dist_name': 'MRBTS-10566/NRBTS-10566/NRCELL-1', 'filter_param': 'TDLTE UL-DL configuration',
             'abbr': 'tdLteUlDlConfig', 'new_value': 'tdLteConfig2'},
            {'dist_name': 'MRBTS-10566/NRBTS-10566/NRCELL-1', 'filter_param': 'UL to DL logical data slot ratio',
             'abbr': 'ulDlDataSlotRatio', 'new_value': '2/8'},
            {'dist_name': 'MRBTS-10566/NRBTS-10566/NRCELL-1', 'filter_param': 'Search space configuration Index',
             'abbr': 'type0SearchSpaceConfigurationIndex',
             'new_value': '6'},
            {'dist_name': 'MRBTS-10566/NRBTS-10566/NRCELL-1', 'filter_param': 'Coreset configuration Index',
             'abbr': 'type0CoresetConfigurationIndex', 'new_value': '3'},
            {'dist_name': 'MRBTS-10566/NRBTS-10566/NRCELL-1', 'filter_param': 'PRACH configuration index',
             'abbr': 'prachConfigurationIndex', 'new_value': '7'},
            {'dist_name': 'MRBTS-10566/NRBTS-10566/NRCELL-1', 'filter_param': 'SS PBCH Block Power',
             'abbr': 'ssPbchBlockPower', 'new_value': '10'},
            {'dist_name': 'MRBTS-10566/NRBTS-10566/NRCELL-1', 'filter_param': 'PRACH Frequency start',
             'abbr': 'msg1FrequencyStart', 'new_value': '6'},
            {'dist_name': 'MRBTS-10566/NRBTS-10566/NRCELL-1',
             'filter_param': 'Bandwidth Part Profile distinguished name',
             'abbr': 'bwpDN',
             'new_value': 'MRBTS-10566/NRBTS-10566/BWP_PROFILE-8', 'node_index': 0},
            {'dist_name': 'MRBTS-10566/NRBTS-10566/NRCELL-1',
             'filter_param': 'Bandwidth Part Profile distinguished name',
             'abbr': 'bwpDN',
             'new_value': 'MRBTS-10566/NRBTS-10566/BWP_PROFILE-80',
             'node_index': 1}
        ],
        '5GC001116_0ms_100MHZ': [
            {'dist_name': 'MRBTS-10566/NRBTS-10566/NRCELL-1', 'filter_param': 'Channel bandwidth', 'abbr': 'chBw',
             'new_value': '100MHz'},
            {'dist_name': 'MRBTS-10566/NRBTS-10566/NRCELL-1',
             'filter_param': 'NR Absolute radio frequency channel number',
             'abbr': 'nrarfcn', 'new_value': '518598'},
            {'dist_name': 'MRBTS-10566/NRBTS-10566/NRCELL-1', 'filter_param': 'Frame Structure Type',
             'abbr': 'frameStructureType', 'new_value': 'tdLte'},
            {'dist_name': 'MRBTS-10566/NRBTS-10566/NRCELL-1', 'filter_param': 'Guard Period length',
             'abbr': 'guardPeriodLength', 'new_value': '4Symbols'},
            {'dist_name': 'MRBTS-10566/NRBTS-10566/NRCELL-1', 'filter_param': 'LTE to NR frame shift',
             'abbr': 'lteToNrFrameShift', 'new_value': '0ms'},
            {'dist_name': 'MRBTS-10566/NRBTS-10566/NRCELL-1', 'filter_param': 'TDLTE UL-DL configuration',
             'abbr': 'tdLteUlDlConfig', 'new_value': 'tdLteConfig2'},
            {'dist_name': 'MRBTS-10566/NRBTS-10566/NRCELL-1', 'filter_param': 'UL to DL logical data slot ratio',
             'abbr': 'ulDlDataSlotRatio', 'new_value': '2/8'},
            {'dist_name': 'MRBTS-10566/NRBTS-10566/NRCELL-1', 'filter_param': 'Search space configuration Index',
             'abbr': 'type0SearchSpaceConfigurationIndex',
             'new_value': '5'},
            {'dist_name': 'MRBTS-10566/NRBTS-10566/NRCELL-1', 'filter_param': 'Coreset configuration Index',
             'abbr': 'type0CoresetConfigurationIndex',
             'new_value': '10'},
            {'dist_name': 'MRBTS-10566/NRBTS-10566/NRCELL-1', 'filter_param': 'PRACH configuration index',
             'abbr': 'prachConfigurationIndex', 'new_value': '9'},
            {'dist_name': 'MRBTS-10566/NRBTS-10566/NRCELL-1', 'filter_param': 'SS PBCH Block Power',
             'abbr': 'ssPbchBlockPower', 'new_value': '4'},
            {'dist_name': 'MRBTS-10566/NRBTS-10566/NRCELL-1', 'filter_param': 'PRACH Frequency start',
             'abbr': 'msg1FrequencyStart', 'new_value': '0'},
            {'dist_name': 'MRBTS-10566/NRBTS-10566/NRCELL-1', 'filter_param': 'Requested minimum number of PUSCH PRBs',
             'abbr': 'reqMinNumPuschPrb', 'new_value': '225'},
            {'dist_name': 'MRBTS-10566/NRBTS-10566/NRCELL-1',
             'filter_param': 'Bandwidth Part Profile distinguished name',
             'abbr': 'bwpDN',
             'new_value': 'MRBTS-10566/NRBTS-10566/BWP_PROFILE-9', 'node_index': 0},
            {'dist_name': 'MRBTS-10566/NRBTS-10566/NRCELL-1',
             'filter_param': 'Bandwidth Part Profile distinguished name',
             'abbr': 'bwpDN',
             'new_value': 'MRBTS-10566/NRBTS-10566/BWP_PROFILE-99',
             'node_index': 1}
        ]
    },
    'AEHC': {
        '5GC001208_10MHZ': [
            {'dist_name': 'MRBTS-858/NRBTS-858/NRCELL-1', 'filter_param': 'Channel bandwidth', 'abbr': 'chBw',
             'new_value': '10MHz'},
            {'dist_name': 'MRBTS-858/NRBTS-858/NRCELL-1', 'filter_param': 'Frame Structure Type',
             'abbr': 'frameStructureType', 'new_value': 'semiStatic'},
            {'dist_name': 'MRBTS-858/NRBTS-858/NRCELL-1', 'filter_param': 'Guard Period length',
             'abbr': 'guardPeriodLength', 'new_value': '2Symbols'},
            {'dist_name': 'MRBTS-858/NRBTS-858/NRCELL-1', 'filter_param': 'UL to DL logical data slot ratio',
             'abbr': 'ulDlDataSlotRatio', 'new_value': '1/4'},
            {'dist_name': 'MRBTS-858/NRBTS-858/NRCELL-1', 'filter_param': 'Search space configuration Index',
             'abbr': 'type0SearchSpaceConfigurationIndex',
             'new_value': '2'},
            {'dist_name': 'MRBTS-858/NRBTS-858/NRCELL-1', 'filter_param': 'Coreset configuration Index',
             'abbr': 'type0CoresetConfigurationIndex', 'new_value': '3'},
            {'dist_name': 'MRBTS-858/NRBTS-858/NRCELL-1', 'filter_param': 'PRACH configuration index',
             'abbr': 'prachConfigurationIndex', 'new_value': '98'},
            {'dist_name': 'MRBTS-858/NRBTS-858/NRCELL-1', 'filter_param': 'SS PBCH Block Power',
             'abbr': 'ssPbchBlockPower', 'new_value': '25'},
            {'dist_name': 'MRBTS-858/NRBTS-858/NRCELL-1', 'filter_param': 'Basic Beam Set', 'abbr': 'basicBeamSet',
             'new_value': 'beamSet_4'},
            {'dist_name': 'MRBTS-858/NRBTS-858/NRCELLGRP-2',
             'filter_param': 'Number of transmitted Synchronization Signal Blocks',
             'abbr': 'numberOfTransmittedSsBlocks', 'new_value': '4 beams'},
            {'dist_name': 'MRBTS-858/NRBTS-858/NRCELL-1', 'filter_param': 'NR Absolute radio frequency channel number',
             'abbr': 'nrarfcn', 'new_value': '501996'},
            {'dist_name': 'MRBTS-858/NRBTS-858/NRCELL-1', 'filter_param': 'PRACH Frequency start',
             'abbr': 'msg1FrequencyStart', 'new_value': '6'},
            {'dist_name': 'MRBTS-858/NRBTS-858/NRCELL-1', 'filter_param': 'Requested minimum number of PUSCH PRBs',
             'abbr': 'reqMinNumPuschPrb', 'new_value': '12'},
            {'dist_name': 'MRBTS-858/NRBTS-858/NRCELL-1', 'filter_param': 'Bandwidth Part Profile distinguished name',
             'abbr': 'bwpDN',
             'new_value': 'MRBTS-858/NRBTS-858/BWP_PROFILE-5', 'node_index': 0},
            {'dist_name': 'MRBTS-858/NRBTS-858/NRCELL-1', 'filter_param': 'Bandwidth Part Profile distinguished name',
             'abbr': 'bwpDN',
             'new_value': 'MRBTS-858/NRBTS-858/BWP_PROFILE-50',
             'node_index': 1}
        ],
        '5GC001070_10MHZ': [
            {'dist_name': 'MRBTS-858/NRBTS-858/NRCELL-1', 'filter_param': 'Channel bandwidth', 'abbr': 'chBw',
             'new_value': '10MHz'},
            {'dist_name': 'MRBTS-858/NRBTS-858/NRCELL-1', 'filter_param': 'Frame Structure Type',
             'abbr': 'frameStructureType', 'new_value': 'semiStatic'},
            {'dist_name': 'MRBTS-858/NRBTS-858/NRCELL-1', 'filter_param': 'Guard Period length',
             'abbr': 'guardPeriodLength', 'new_value': '2Symbols'},
            {'dist_name': 'MRBTS-858/NRBTS-858/NRCELL-1', 'filter_param': 'UL to DL logical data slot ratio',
             'abbr': 'ulDlDataSlotRatio', 'new_value': '3/7'},
            {'dist_name': 'MRBTS-858/NRBTS-858/NRCELL-1', 'filter_param': 'Search space configuration Index',
             'abbr': 'type0SearchSpaceConfigurationIndex',
             'new_value': '6'},
            {'dist_name': 'MRBTS-858/NRBTS-858/NRCELL-1', 'filter_param': 'Coreset configuration Index',
             'abbr': 'type0CoresetConfigurationIndex', 'new_value': '0'},
            {'dist_name': 'MRBTS-858/NRBTS-858/NRCELL-1', 'filter_param': 'PRACH configuration index',
             'abbr': 'prachConfigurationIndex', 'new_value': '7'},
            {'dist_name': 'MRBTS-858/NRBTS-858/NRCELL-1', 'filter_param': 'SS PBCH Block Power',
             'abbr': 'ssPbchBlockPower', 'new_value': '25'},
            {'dist_name': 'MRBTS-858/NRBTS-858/NRCELL-1', 'filter_param': 'Basic Beam Set', 'abbr': 'basicBeamSet',
             'new_value': 'beamSet_4'},
            {'dist_name': 'MRBTS-858/NRBTS-858/NRCELLGRP-2',
             'filter_param': 'Number of transmitted Synchronization Signal Blocks',
             'abbr': 'numberOfTransmittedSsBlocks', 'new_value': '4 beams'},
            {'dist_name': 'MRBTS-858/NRBTS-858/NRCELL-1', 'filter_param': 'NR Absolute radio frequency channel number',
             'abbr': 'nrarfcn', 'new_value': '501996'},
            {'dist_name': 'MRBTS-858/NRBTS-858/NRCELL-1', 'filter_param': 'PRACH Frequency start',
             'abbr': 'msg1FrequencyStart', 'new_value': '6'},
            {'dist_name': 'MRBTS-858/NRBTS-858/NRCELL-1', 'filter_param': 'Requested minimum number of PUSCH PRBs',
             'abbr': 'reqMinNumPuschPrb', 'new_value': '12'},
            {'dist_name': 'MRBTS-858/NRBTS-858/NRCELL-1', 'filter_param': 'Bandwidth Part Profile distinguished name',
             'abbr': 'bwpDN',
             'new_value': 'MRBTS-858/NRBTS-858/BWP_PROFILE-6', 'node_index': 0},
            {'dist_name': 'MRBTS-858/NRBTS-858/NRCELL-1', 'filter_param': 'Bandwidth Part Profile distinguished name',
             'abbr': 'bwpDN',
             'new_value': 'MRBTS-858/NRBTS-858/BWP_PROFILE-60',
             'node_index': 1}
        ],
        '5GC001116_0ms_10MHZ': [
            {'dist_name': 'MRBTS-858/NRBTS-858/NRCELL-1', 'filter_param': 'Channel bandwidth', 'abbr': 'chBw',
             'new_value': '10MHz'},
            {'dist_name': 'MRBTS-858/NRBTS-858/NRCELL-1', 'filter_param': 'Frame Structure Type',
             'abbr': 'frameStructureType', 'new_value': 'tdLte'},
            {'dist_name': 'MRBTS-858/NRBTS-858/NRCELL-1', 'filter_param': 'Guard Period length',
             'abbr': 'guardPeriodLength', 'new_value': '6Symbols'},
            {'dist_name': 'MRBTS-858/NRBTS-858/NRCELL-1', 'filter_param': 'LTE to NR frame shift',
             'abbr': 'lteToNrFrameShift', 'new_value': '0ms'},
            {'dist_name': 'MRBTS-858/NRBTS-858/NRCELL-1', 'filter_param': 'TDLTE UL-DL configuration',
             'abbr': 'tdLteUlDlConfig', 'new_value': 'tdLteConfig2'},
            {'dist_name': 'MRBTS-858/NRBTS-858/NRCELL-1', 'filter_param': 'UL to DL logical data slot ratio',
             'abbr': 'ulDlDataSlotRatio', 'new_value': '2/8'},
            {'dist_name': 'MRBTS-858/NRBTS-858/NRCELL-1', 'filter_param': 'Search space configuration Index',
             'abbr': 'type0SearchSpaceConfigurationIndex',
             'new_value': '4'},
            {'dist_name': 'MRBTS-858/NRBTS-858/NRCELL-1', 'filter_param': 'Coreset configuration Index',
             'abbr': 'type0CoresetConfigurationIndex', 'new_value': '5'},
            {'dist_name': 'MRBTS-858/NRBTS-858/NRCELL-1', 'filter_param': 'PRACH configuration index',
             'abbr': 'prachConfigurationIndex', 'new_value': '9'},
            {'dist_name': 'MRBTS-858/NRBTS-858/NRCELL-1', 'filter_param': 'SS PBCH Block Power',
             'abbr': 'ssPbchBlockPower', 'new_value': '25'},
            {'dist_name': 'MRBTS-858/NRBTS-858/NRCELL-1', 'filter_param': 'Basic Beam Set', 'abbr': 'basicBeamSet',
             'new_value': 'beamSet_2'},
            {'dist_name': 'MRBTS-858/NRBTS-858/NRCELLGRP-2',
             'filter_param': 'Number of transmitted Synchronization Signal Blocks',
             'abbr': 'numberOfTransmittedSsBlocks', 'new_value': '2 beams'},
            {'dist_name': 'MRBTS-858/NRBTS-858/NRCELL-1', 'filter_param': 'NR Absolute radio frequency channel number',
             'abbr': 'nrarfcn', 'new_value': '501996'},
            {'dist_name': 'MRBTS-858/NRBTS-858/NRCELL-1', 'filter_param': 'PRACH Frequency start',
             'abbr': 'msg1FrequencyStart', 'new_value': '6'},
            {'dist_name': 'MRBTS-858/NRBTS-858/NRCELL-1', 'filter_param': 'Requested minimum number of PUSCH PRBs',
             'abbr': 'reqMinNumPuschPrb', 'new_value': '12'},
            {'dist_name': 'MRBTS-858/NRBTS-858/NRCELL-1', 'filter_param': 'Bandwidth Part Profile distinguished name',
             'abbr': 'bwpDN',
             'new_value': 'MRBTS-858/NRBTS-858/BWP_PROFILE-7', 'node_index': 0},
            {'dist_name': 'MRBTS-858/NRBTS-858/NRCELL-1', 'filter_param': 'Bandwidth Part Profile distinguished name',
             'abbr': 'bwpDN',
             'new_value': 'MRBTS-858/NRBTS-858/BWP_PROFILE-70',
             'node_index': 1}
        ],
        '5GC001116_3ms_10MHZ': [
            {'dist_name': 'MRBTS-858/NRBTS-858/NRCELL-1', 'filter_param': 'Channel bandwidth', 'abbr': 'chBw',
             'new_value': '10MHz'},
            {'dist_name': 'MRBTS-858/NRBTS-858/NRCELL-1', 'filter_param': 'Frame Structure Type',
             'abbr': 'frameStructureType', 'new_value': 'tdLte'},
            {'dist_name': 'MRBTS-858/NRBTS-858/NRCELL-1', 'filter_param': 'Guard Period length',
             'abbr': 'guardPeriodLength', 'new_value': '6Symbols'},
            {'dist_name': 'MRBTS-858/NRBTS-858/NRCELL-1', 'filter_param': 'LTE to NR frame shift',
             'abbr': 'lteToNrFrameShift', 'new_value': '3ms'},
            {'dist_name': 'MRBTS-858/NRBTS-858/NRCELL-1', 'filter_param': 'TDLTE UL-DL configuration',
             'abbr': 'tdLteUlDlConfig', 'new_value': 'tdLteConfig2'},
            {'dist_name': 'MRBTS-858/NRBTS-858/NRCELL-1', 'filter_param': 'UL to DL logical data slot ratio',
             'abbr': 'ulDlDataSlotRatio', 'new_value': '2/8'},
            {'dist_name': 'MRBTS-858/NRBTS-858/NRCELL-1', 'filter_param': 'Search space configuration Index',
             'abbr': 'type0SearchSpaceConfigurationIndex',
             'new_value': '4'},
            {'dist_name': 'MRBTS-858/NRBTS-858/NRCELL-1', 'filter_param': 'Coreset configuration Index',
             'abbr': 'type0CoresetConfigurationIndex', 'new_value': '2'},
            {'dist_name': 'MRBTS-858/NRBTS-858/NRCELL-1', 'filter_param': 'PRACH configuration index',
             'abbr': 'prachConfigurationIndex', 'new_value': '7'},
            {'dist_name': 'MRBTS-858/NRBTS-858/NRCELL-1', 'filter_param': 'SS PBCH Block Power',
             'abbr': 'ssPbchBlockPower', 'new_value': '25'},
            {'dist_name': 'MRBTS-858/NRBTS-858/NRCELL-1', 'filter_param': 'Basic Beam Set', 'abbr': 'basicBeamSet',
             'new_value': 'beamSet_6'},
            {'dist_name': 'MRBTS-858/NRBTS-858/NRCELLGRP-2',
             'filter_param': 'Number of transmitted Synchronization Signal Blocks',
             'abbr': 'numberOfTransmittedSsBlocks', 'new_value': '6 beams'},
            {'dist_name': 'MRBTS-858/NRBTS-858/NRCELL-1', 'filter_param': 'NR Absolute radio frequency channel number',
             'abbr': 'nrarfcn', 'new_value': '501870'},
            {'dist_name': 'MRBTS-858/NRBTS-858/NRCELL-1', 'filter_param': 'PRACH Frequency start',
             'abbr': 'msg1FrequencyStart', 'new_value': '6'},
            {'dist_name': 'MRBTS-858/NRBTS-858/NRCELL-1', 'filter_param': 'Requested minimum number of PUSCH PRBs',
             'abbr': 'reqMinNumPuschPrb', 'new_value': '12'},
            {'dist_name': 'MRBTS-858/NRBTS-858/NRCELL-1', 'filter_param': 'Bandwidth Part Profile distinguished name',
             'abbr': 'bwpDN',
             'new_value': 'MRBTS-858/NRBTS-858/BWP_PROFILE-8', 'node_index': 0},
            {'dist_name': 'MRBTS-858/NRBTS-858/NRCELL-1', 'filter_param': 'Bandwidth Part Profile distinguished name',
             'abbr': 'bwpDN',
             'new_value': 'MRBTS-858/NRBTS-858/BWP_PROFILE-80',
             'node_index': 1}
        ],
        '5GC001116_0ms_100MHZ': [
            {'dist_name': 'MRBTS-858/NRBTS-858/NRCELL-1', 'filter_param': 'Channel bandwidth', 'abbr': 'chBw',
             'new_value': '100MHz'},
            {'dist_name': 'MRBTS-858/NRBTS-858/NRCELL-1', 'filter_param': 'NR Absolute radio frequency channel numberr',
             'abbr': 'nrarfcn', 'new_value': '518598'},
            {'dist_name': 'MRBTS-858/NRBTS-858/NRCELL-1', 'filter_param': 'Frame Structure Type',
             'abbr': 'frameStructureType', 'new_value': 'tdLte'},
            {'dist_name': 'MRBTS-858/NRBTS-858/NRCELL-1', 'filter_param': 'Guard Period length',
             'abbr': 'guardPeriodLength', 'new_value': '4Symbols'},
            {'dist_name': 'MRBTS-858/NRBTS-858/NRCELL-1', 'filter_param': 'LTE to NR frame shift',
             'abbr': 'lteToNrFrameShift', 'new_value': '0ms'},
            {'dist_name': 'MRBTS-858/NRBTS-858/NRCELL-1', 'filter_param': 'TDLTE UL-DL configuration',
             'abbr': 'tdLteUlDlConfig', 'new_value': 'tdLteConfig2'},
            {'dist_name': 'MRBTS-858/NRBTS-858/NRCELL-1', 'filter_param': 'UL to DL logical data slot ratio',
             'abbr': 'ulDlDataSlotRatio', 'new_value': '2/8'},
            {'dist_name': 'MRBTS-858/NRBTS-858/NRCELL-1', 'filter_param': 'Search space configuration Index',
             'abbr': 'type0SearchSpaceConfigurationIndex',
             'new_value': '5'},
            {'dist_name': 'MRBTS-858/NRBTS-858/NRCELL-1', 'filter_param': 'Coreset configuration Index',
             'abbr': 'type0CoresetConfigurationIndex',
             'new_value': '10'},
            {'dist_name': 'MRBTS-858/NRBTS-858/NRCELL-1', 'filter_param': 'PRACH configuration index',
             'abbr': 'prachConfigurationIndex', 'new_value': '9'},
            {'dist_name': 'MRBTS-858/NRBTS-858/NRCELL-1', 'filter_param': 'SS PBCH Block Power',
             'abbr': 'ssPbchBlockPower', 'new_value': '4'},
            {'dist_name': 'MRBTS-858/NRBTS-858/NRCELL-1', 'filter_param': 'PRACH Frequency start',
             'abbr': 'msg1FrequencyStart', 'new_value': '0'},
            {'dist_name': 'MRBTS-858/NRBTS-858/NRCELL-1', 'filter_param': 'Bandwidth Part Profile distinguished name',
             'abbr': 'bwpDN',
             'new_value': 'MRBTS-10566/NRBTS-10566/BWP_PROFILE-9', 'node_index': 0},
            {'dist_name': 'MRBTS-858/NRBTS-858/NRCELL-1', 'filter_param': 'Bandwidth Part Profile distinguished name',
             'abbr': 'bwpDN',
             'new_value': 'MRBTS-10566/NRBTS-10566/BWP_PROFILE-99',
             'node_index': 1}
        ]
    }
}

DICT__L3CALL_Set = {
    'AZHL': {
        '5GC001208_10MHZ': {
            'ue_index': '0',
            'dl_tp_ratio': '1',
            'ul_tp_ratio': '1',
            'peak_tp_dl': '130',
            'peak_tp_ul': '15',
            'duration': '600'
        },
        '5GC001070_10MHZ': {
            'ue_index': '0',
            'dl_tp_ratio': '1',
            'ul_tp_ratio': '1',
            'peak_tp_dl': '112',
            'peak_tp_ul': '22',
            'duration': '600'
        },
        '5GC001116_0ms_10MHZ': {
            'ue_index': '0',
            'dl_tp_ratio': '1',
            'ul_tp_ratio': '1',
            'peak_tp_dl': '130',
            'peak_tp_ul': '13',
            'duration': '600'
        },
        '5GC001116_3ms_10MHZ': {
            'ue_index': '0',
            'dl_tp_ratio': '1',
            'ul_tp_ratio': '1',
            'peak_tp_dl': '130',
            'peak_tp_ul': '13',
            'duration': '600'
        },
        '5GC001116_3ms_100MHZ': {
            'ue_index': '0',
            'dl_tp_ratio': '1',
            'ul_tp_ratio': '1',
            'peak_tp_dl': '100',
            'peak_tp_ul': '20',
            'duration': '600'
        }
    },
    'AEHC': {
        '5GC001208_10MHZ': {
            'ue_index': '0',
            'dl_tp_ratio': '1',
            'ul_tp_ratio': '1',
            'peak_tp_dl': '110',
            'peak_tp_ul': '7.3',
            'duration': '600'
        },
        '5GC001070_10MHZ': {
            'ue_index': '0',
            'dl_tp_ratio': '1',
            'ul_tp_ratio': '1',
            'peak_tp_dl': '92',
            'peak_tp_ul': '10',
            'duration': '600'
        },
        '5GC001116_0ms_10MHZ': {
            'ue_index': '0',
            'dl_tp_ratio': '1',
            'ul_tp_ratio': '1',
            'peak_tp_dl': '100',
            'peak_tp_ul': '6.2',
            'duration': '600'
        },
        '5GC001116_3ms_10MHZ': {
            'ue_index': '0',
            'dl_tp_ratio': '1',
            'ul_tp_ratio': '1',
            'peak_tp_dl': '100',
            'peak_tp_ul': '6.8',
            'duration': '600'
        },
        '5GC001116_3ms_100MHZ': {
            'ue_index': '0',
            'dl_tp_ratio': '1',
            'ul_tp_ratio': '1',
            'peak_tp_dl': '100',
            'peak_tp_ul': '20',
            'duration': '600'
        }
    }
}

DICT__PA_Value = {
    'AEHC': {
        '5GC001208_10MHZ': [20, 20, 20, 20],
        '5GC001070_10MHZ': [20, 20, 20, 20],
        '5GC001116_0ms_10MHZ': [15, 15, 15, 15],
        '5GC001116_3ms_10MHZ': [20, 20, 20, 20],
    },
    'AZHL': {
        '5GC001208_10MHZ': [13, 13, 13, 13],
        '5GC001070_10MHZ': [13, 13, 13, 13],
        '5GC001116_0ms_10MHZ': [13, 13, 13, 13],
        '5GC001116_3ms_10MHZ': [13, 13, 13, 13],
    }
}

LIST__SISO_FAULT_allowed = [
    '4293',
    '4655',
    '4654',
    '61652',
    '61524',
    '4592',
    '61649',
    '49',
    '50',
    '6327',
    '7107',
    '4614',
    '4741',
    '6823',
    '6824',
    '6825',
    '6826',
    '6827',
    '6828',
    '6829',
    '6830',
    '6831',
    '6832',
    '6833',
    '6351',
    '7305',
    '7300',
    '7319',
    '4589',
    '4459',
    '4298',
    '8000',
    '4123',
    '4125',
    '7304',
    '6202',
    '4334',
    '61641',
    '4420'
]

LIST__SYSLOG_ERROR_allowed = [
    'grep -v "findActiveCellPosition() failed"',
    'grep -v "NOT send NetworkPlanUpdateInd!"',
    'grep -v "No active cell with nrCellId"',
    'grep -v "No valid X2 Ipaddress"',
    'grep -v "releasing index failed."',
    'grep -v "Pm Agent fails to register dataset for cplaneCaProfile1SecAgg"',
    'grep -v "Not found CellElement"',
    'grep -v "SCTP connection failed. Error: Connection refused"',
    'grep -v "Invalid value (10 aW) detected consecutively 10 times for fakeUe"',
]

PARAMS_TO_actRATResetEnhancement_false = {
    'update': [
        dict(value='false', dist_name='MRBTS-%s/MNL-1/MNLENT-1/FEATCADM-1' % (GLOBAL_BTS_ID),
             parameter='actRatResetEnhancement'),
        dict(value='false', dist_name='MRBTS-%s/MNL-1/MNLENT-1/FEATCADM-1' % (GLOBAL_BTS_ID),
             parameter='actL1ReconfigImprovement'),
        dict(value='false', dist_name='MRBTS-%s/MNL-1/MNLENT-1/FEATCADM-1' % (GLOBAL_BTS_ID),
             parameter='actBbReconfigImprovement'),
        dict(value='false', dist_name='MRBTS-%s/MNL-1/MNLENT-1/FEATCADM-1' % (GLOBAL_BTS_ID),
             parameter='actL2L3ReconfigImprovement'),
    ]
}

PARAMS_TO_actRATResetEnhancement_true = {
    'update': [
        dict(value='true', dist_name='MRBTS-%s/MNL-1/MNLENT-1/FEATCADM-1' % (GLOBAL_BTS_ID),
             parameter='actRatResetEnhancement'),
        dict(value='true', dist_name='MRBTS-%s/MNL-1/MNLENT-1/FEATCADM-1' % (GLOBAL_BTS_ID),
             parameter='actL1ReconfigImprovement'),
        dict(value='true', dist_name='MRBTS-%s/MNL-1/MNLENT-1/FEATCADM-1' % (GLOBAL_BTS_ID),
             parameter='actBbReconfigImprovement'),
        dict(value='true', dist_name='MRBTS-%s/MNL-1/MNLENT-1/FEATCADM-1' % (GLOBAL_BTS_ID),
             parameter='actL2L3ReconfigImprovement'),
    ]
}

# RULOG_TL = ['89', '289', '295', '842', '863']
BB_ignore_TL = ['89', '290']
RU_ignore_TL = ['99']

RU_CMD_LIST = ["ip addr"]

# RU_CMD_LIST = ["sudo tcpdump -i bond0.257 'ether proto 0x8902 or (vlan and ether proto 0x8902)' -w \
# /ram/cfm_bond0_257.pcap &> /dev/null &\n\
# sudo tcpdump -i bond0.258 'ether proto 0x8902 or (vlan and ether proto 0x8902)' -w /ram/cfm_bond0_258.pcap \
# &> /dev/null &\n\
# sudo tcpdump -i bond0.259 'ether proto 0x8902 or (vlan and ether proto 0x8902)' -w /ram/cfm_bond0_259.pcap \
# &> /dev/null &\n\
# sudo tcpdump -i bond0.260 'ether proto 0x8902 or (vlan and ether proto 0x8902)' -w /ram/cfm_bond0_260.pcap \
# &> /dev/null &\n\
# sudo tcpdump -i arb0p0 'ether proto 0x8902 or (vlan and ether proto 0x8902)' -w /ram/cfm_arbop0.pcap &> /dev/null &"]
#
# RU_THOR_CMD_LIST = ["sudo tcpdump -i rfoe0 'ether proto 0x8902 or (vlan and ether proto 0x8902)' -w \
# /ram/cfm_rfoe0.pcap &> /dev/null &\n\
# sudo tcpdump -i rfoe1 'ether proto 0x8902 or (vlan and ether proto 0x8902)' -w /ram/cfm_rfoe1.pcap &> /dev/null &\n\
# sudo tcpdump -i rfoe2 'ether proto 0x8902 or (vlan and ether proto 0x8902)' -w /ram/cfm_rfoe2.pcap &> /dev/null &\n\
# sudo tcpdump -i rfoe3 'ether proto 0x8902 or (vlan and ether proto 0x8902)' -w /ram/cfm_rfoe3.pcap &> /dev/null &\n\
# sudo tcpdump -i rfoe4 'ether proto 0x8902 or (vlan and ether proto 0x8902)' -w /ram/cfm_rfoe4.pcap &> /dev/null &\n\
# sudo tcpdump -i br_rfoe0 'ether proto 0x8902 or (vlan and ether proto 0x8902)' -w /ram/cfm_br_rfoe0.pcap \
# &> /dev/null &\n\
# sudo tcpdump -i br_rfoe1 'ether proto 0x8902 or (vlan and ether proto 0x8902)' -w /ram/cfm_br_rfoe1.pcap \
# &> /dev/null &\n\
# sudo tcpdump -i br_rfoe2  'ether proto 0x8902 or (vlan and ether proto 0x8902)' -w /ram/cfm_br_rfoe2.pcap \
# &> /dev/null &\n\
# sudo tcpdump -i br_rfoe3  'ether proto 0x8902 or (vlan and ether proto 0x8902)' -w /ram/cfm_br_rfoe3.pcap \
# &> /dev/null &\n\
# sudo tcpdump -i bond0.257 'ether proto 0x8902 or (vlan and ether proto 0x8902)' -w /ram/cfm_thor_bond0_257.pcap\
#  &> /dev/null &\n\
# sudo tcpdump -i bond0.258 'ether proto 0x8902 or (vlan and ether proto 0x8902)' -w /ram/cfm_thor_bond0_258.pcap\
#  &> /dev/null &\n\
# sudo tcpdump -i bond0.259 'ether proto 0x8902 or (vlan and ether proto 0x8902)' -w /ram/cfm_thor_bond0_259.pcap\
#  &> /dev/null &\n\
# sudo tcpdump -i bond0.260 'ether proto 0x8902 or (vlan and ether proto 0x8902)' -w /ram/cfm_thor_bond0_260.pcap\
#  &> /dev/null &"]

RULOG_TL = {
    '89': {'log_check': False, 'site_reset': True, 'ru_reset': True, 'site_reset_withouthwf': True,
           'cell_reset': True, 'cell_lock_unlock': True, 'cell_block_unblock': True,
           'ru_lock_unlock': True, 'bbmod_reset': True, 'bbmod_lock_unlock': True,
           'rat_reset': True, 'rat_block_unblock': True, 'du_lock_unlock': True,
           'commission': True, 'power_reset': True, 'ru_power_reset': True
           },
    '289': {'log_check': False, 'site_reset': True, 'ru_reset': True, 'site_reset_withouthwf': True,
            'cell_reset': True, 'cell_lock_unlock': True, 'cell_block_unblock': True,
            'ru_lock_unlock': True, 'bbmod_reset': True, 'bbmod_lock_unlock': True,
            'rat_reset': True, 'rat_block_unblock': True, 'du_lock_unlock': True,
            'commission': True, 'power_reset': True, 'ru_power_reset': True
            },
    '295': {'log_check': False, 'site_reset': True, 'ru_reset': True, 'site_reset_withouthwf': True,
            'cell_reset': True, 'cell_lock_unlock': True, 'cell_block_unblock': True,
            'ru_lock_unlock': True, 'bbmod_reset': True, 'bbmod_lock_unlock': True,
            'rat_reset': True, 'rat_block_unblock': True, 'du_lock_unlock': True,
            'commission': True, 'power_reset': True, 'ru_power_reset': True
            },
    '502': {'log_check': False, 'site_reset': True, 'ru_reset': True, 'site_reset_withouthwf': True,
            'cell_reset': True, 'cell_lock_unlock': True, 'cell_block_unblock': True,
            'ru_lock_unlock': True, 'bbmod_reset': True, 'bbmod_lock_unlock': True,
            'rat_reset': True, 'rat_block_unblock': True, 'du_lock_unlock': True,
            'commission': True, 'power_reset': True, 'ru_power_reset': True
            },
    '881': {'log_check': False, 'site_reset': True, 'ru_reset': True, 'site_reset_withouthwf': True,
            'cell_reset': True, 'cell_lock_unlock': True, 'cell_block_unblock': True,
            'ru_lock_unlock': True, 'bbmod_reset': True, 'bbmod_lock_unlock': True,
            'rat_reset': True, 'rat_block_unblock': True, 'du_lock_unlock': True,
            'commission': True, 'power_reset': True, 'ru_power_reset': True
            },
    '858': {'log_check': False, 'site_reset': True, 'ru_reset': True, 'site_reset_withouthwf': True,
            'cell_reset': True, 'cell_lock_unlock': True, 'cell_block_unblock': True,
            'ru_lock_unlock': True, 'bbmod_reset': True, 'bbmod_lock_unlock': True,
            'rat_reset': True, 'rat_block_unblock': True, 'du_lock_unlock': True,
            'commission': True, 'power_reset': True, 'ru_power_reset': True
            },
    '846': {'log_check': False, 'site_reset': True, 'ru_reset': True, 'site_reset_withouthwf': True,
            'cell_reset': True, 'cell_lock_unlock': True, 'cell_block_unblock': True,
            'ru_lock_unlock': True, 'bbmod_reset': True, 'bbmod_lock_unlock': True,
            'rat_reset': True, 'rat_block_unblock': True, 'du_lock_unlock': True,
            'commission': True, 'power_reset': True, 'ru_power_reset': True
            },
    '290': {'log_check': False, 'site_reset': True, 'ru_reset': True, 'site_reset_withouthwf': True,
            'cell_reset': True, 'cell_lock_unlock': True, 'cell_block_unblock': True,
            'ru_lock_unlock': True, 'bbmod_reset': True, 'bbmod_lock_unlock': True,
            'rat_reset': True, 'rat_block_unblock': True, 'du_lock_unlock': True,
            'commission': True, 'power_reset': True, 'ru_power_reset': True
            },
    '860': {'log_check': False, 'site_reset': True, 'ru_reset': True, 'site_reset_withouthwf': True,
            'cell_reset': True, 'cell_lock_unlock': True, 'cell_block_unblock': True,
            'ru_lock_unlock': True, 'bbmod_reset': True, 'bbmod_lock_unlock': True,
            'rat_reset': True, 'rat_block_unblock': True, 'du_lock_unlock': True,
            'commission': True, 'power_reset': True, 'ru_power_reset': True
            },
    '94': {'log_check': False, 'site_reset': True, 'ru_reset': True, 'site_reset_withouthwf': True,
           'cell_reset': True, 'cell_lock_unlock': True, 'cell_block_unblock': True,
           'ru_lock_unlock': True, 'bbmod_reset': True, 'bbmod_lock_unlock': True,
           'rat_reset': True, 'rat_block_unblock': True, 'du_lock_unlock': True,
           'commission': True, 'power_reset': True, 'ru_power_reset': True
           },
    '835': {'log_check': False, 'site_reset': True, 'ru_reset': True, 'site_reset_withouthwf': True,
            'cell_reset': True, 'cell_lock_unlock': True, 'cell_block_unblock': True,
            'ru_lock_unlock': True, 'bbmod_reset': True, 'bbmod_lock_unlock': True,
            'rat_reset': True, 'rat_block_unblock': True, 'du_lock_unlock': True,
            'commission': True, 'power_reset': True, 'ru_power_reset': True
            },
}

egen_TL = []
ipcapture_TL = []

L3CALL_TL = {'846': {
    '31': {'ue_index': '0', 'dl_tp_ratio': '1', 'ul_tp_ratio': '1', 'peak_tp_dl': '100', 'peak_tp_ul': '30',
           'duration': '60'},
    '32': {'ue_index': '0', 'dl_tp_ratio': '1', 'ul_tp_ratio': '1', 'peak_tp_dl': '100', 'peak_tp_ul': '60',
           'duration': '60'},
    '33': {'ue_index': '0', 'dl_tp_ratio': '1', 'ul_tp_ratio': '1', 'peak_tp_dl': '100', 'peak_tp_ul': '30',
           'duration': '60'}
}
}

LTE_CELL_NOT_OPERATION_TL = ["4000835"]
