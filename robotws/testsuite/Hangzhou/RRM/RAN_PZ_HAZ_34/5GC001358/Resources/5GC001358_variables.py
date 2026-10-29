# -*- coding: utf-8 -*
import os
from robot.libraries.BuiltIn import BuiltIn
tl = BuiltIn().get_variable_value('${tl}')

SWCONFIG_5GC001856_M = [
    '0x460017=2'
]

Variables_CFAM = {
    'AZQG': {
        'Uint_name': 'AZQG',
        'unitType_expect': '<unitType>AZ</unitType>',
        'variant_expect': '<variant>QG</variant>',
        'ProductCode_expect': '<p Name="Visible.Product.Code">474994A</p>',
        'SuppTech_expect': '<list Name="Supported.Technology"><p>5G</p></list>',
        'NRFreqBand_expect': '<list Name="NR.Frequency.Band"><p>78</p><p>78</p></list>',
        'LinkType_expect': '<p Name="Type">CPRI</p>'
    }
}
MR_NAME = 'MRBTS-' + str(tl.gnbs[0].global_bts_id)
MR_NR_NAME = MR_NAME + '/NRBTS-' + str(tl.gnbs[0].global_bts_id)
MR_NR_CELL_NAME = MR_NR_NAME + '/NRCELL-1'
MR_NR_CELLGRP_NAME = MR_NR_NAME + '/NRCELLGRP-0'
MR_MNL_MNL_NET_PMMNL = 'MRBTS-' + str(tl.gnbs[0].global_bts_id) + '/MNL-1/MNLENT-1/PMMNL-1'
MR_MNL_MNL_SYNC_CLOCK_1 = 'MRBTS-' + str(tl.gnbs[0].global_bts_id) + '/MNL-1/MNLENT-1/SYNC-1/CLOCK-1'
MR_NR_NRPGRP_NAME = MR_NR_NAME + '/NRPGRP-1'

DEL_ANTL_3 = dict(
        operate='delete',
        dist_name=MR_NAME + '/EQM-1/APEQM-1/RMOD-1/ANTL-3'
)

DEL_ANTL_4 = dict(
        operate='delete',
        dist_name=MR_NAME + '/EQM-1/APEQM-1/RMOD-1/ANTL-4'
)

DEL_ANTL_5 = dict(
        operate='delete',
        dist_name=MR_NAME + '/EQM-1/APEQM-1/RMOD-1/ANTL-5'
)

DEL_ANTL_6 = dict(
        operate='delete',
        dist_name=MR_NAME + '/EQM-1/APEQM-1/RMOD-1/ANTL-6'
)

DEL_ANTL_7 = dict(
        operate='delete',
        dist_name=MR_NAME + '/EQM-1/APEQM-1/RMOD-1/ANTL-7'
)

DEL_ANTL_8 = dict(
        operate='delete',
        dist_name=MR_NAME + '/EQM-1/APEQM-1/RMOD-1/ANTL-8'
)

DEL_CHANNEL_6 = dict(
        operate='delete',
        dist_name=MR_NAME + '/MNL-1/MNLENT-1/CELLMAPPING-1/LCELNR-1/CHANNELGROUP-1/CHANNEL-6'
)

DEL_CHANNEL_8 = dict(
        operate='delete',
        dist_name=MR_NAME + '/MNL-1/MNLENT-1/CELLMAPPING-1/LCELNR-1/CHANNELGROUP-1/CHANNEL-8'
)

DEL_CHANNEL_9 = dict(
        operate='delete',
        dist_name=MR_NAME + '/MNL-1/MNLENT-1/CELLMAPPING-1/LCELNR-1/CHANNELGROUP-1/CHANNEL-9'
)

DEL_CHANNEL_10 = dict(
        operate='delete',
        dist_name=MR_NAME + '/MNL-1/MNLENT-1/CELLMAPPING-1/LCELNR-1/CHANNELGROUP-1/CHANNEL-10'
)

DEL_CHANNEL_11 = dict(
        operate='delete',
        dist_name=MR_NAME + '/MNL-1/MNLENT-1/CELLMAPPING-1/LCELNR-1/CHANNELGROUP-1/CHANNEL-11'
)

DEL_CHANNEL_12 = dict(
        operate='delete',
        dist_name=MR_NAME + '/MNL-1/MNLENT-1/CELLMAPPING-1/LCELNR-1/CHANNELGROUP-1/CHANNEL-12'
)

DEL_CHANNEL_13 = dict(
        operate='delete',
        dist_name=MR_NAME + '/MNL-1/MNLENT-1/CELLMAPPING-1/LCELNR-1/CHANNELGROUP-1/CHANNEL-13'
)

DEL_CHANNEL_14 = dict(
        operate='delete',
        dist_name=MR_NAME + '/MNL-1/MNLENT-1/CELLMAPPING-1/LCELNR-1/CHANNELGROUP-1/CHANNEL-14'
)

DEL_CHANNEL_15 = dict(
        operate='delete',
        dist_name=MR_NAME + '/MNL-1/MNLENT-1/CELLMAPPING-1/LCELNR-1/CHANNELGROUP-1/CHANNEL-15'
)

DEL_CHANNEL_16 = dict(
        operate='delete',
        dist_name=MR_NAME + '/MNL-1/MNLENT-1/CELLMAPPING-1/LCELNR-1/CHANNELGROUP-1/CHANNEL-16'
)

DEL_4DL2UL_CHANNEL = [
    DEL_CHANNEL_6,
    DEL_CHANNEL_8,
    DEL_CHANNEL_9,
    DEL_CHANNEL_10,
    DEL_CHANNEL_11,
    DEL_CHANNEL_12,
    DEL_CHANNEL_13,
    DEL_CHANNEL_14,
    DEL_CHANNEL_15,
    DEL_CHANNEL_16
    ]

PARA_5GC001961 = DEL_4DL2UL_CHANNEL + [
    dict(
        operate='update',
        dist_name=MR_NR_CELL_NAME,
        p_name='actBeamforming',
        new_value='false'),
    dict(
        operate='update',
        dist_name=MR_NR_CELLGRP_NAME,
        p_name='numberOfTransmittedSsBlocks',
        new_value='1 beam'),
    dict(
        operate='update',
        dist_name=MR_NR_CELL_NAME,
        p_name='actExternalAntennaBF',
        new_value='false'),
    dict(
        operate='update',
        dist_name=MR_NR_CELL_NAME,
        p_name='basicBeamSet',
        new_value='beamSet_1')
]

PARA_5GC001451_2 = [
    dict(
        operate='update',
        dist_name=MR_NR_CELL_NAME,
        p_name='actExternalAntennaBF',
        new_value='false'),
    dict(
        operate='update',
        dist_name=MR_NR_CELL_NAME,
        p_name='numOfSubSectors',
        new_value='2sub-sectors'),
    dict(
        operate='update',
        dist_name=MR_NR_CELLGRP_NAME,
        p_name='numberOfTransmittedSsBlocks',
        new_value='2 beams'),
    dict(
        operate='update',
        dist_name=MR_NR_CELL_NAME,
        p_name='dlMimoMode',
        new_value='4x4 or 4x2 Open Loop Spatial Multiplexing'),
    dict(
        operate='update',
        dist_name=MR_NR_CELL_NAME,
        p_name='basicBeamSet',
        new_value='beamSet_2SS')
]

PARA_5GC001451_2_closeloop = [
    dict(
        operate='update',
        dist_name=MR_NR_CELL_NAME,
        p_name='actExternalAntennaBF',
        new_value='false'),
    dict(
        operate='update',
        dist_name=MR_NR_CELL_NAME,
        p_name='numOfSubSectors',
        new_value='2sub-sectors'),
    dict(
        operate='update',
        dist_name=MR_NR_CELLGRP_NAME,
        p_name='numberOfTransmittedSsBlocks',
        new_value='2 beams'),
    dict(
        operate='update',
        dist_name=MR_NR_CELL_NAME,
        p_name='dlMimoMode',
        new_value='4x4 or 4x2 Closed Loop Spatial Multiplexing'),
    dict(
        operate='update',
        dist_name=MR_NR_CELL_NAME,
        p_name='basicBeamSet',
        new_value='beamSet_2SS')
]

PARA_5GC001451_4 = [
    dict(
        operate='update',
        dist_name=MR_NR_CELL_NAME,
        p_name='actExternalAntennaBF',
        new_value='false'),
    dict(
        operate='update',
        dist_name=MR_NR_CELL_NAME,
        p_name='actDlLowPAPRoptimizedPrecoding',
        new_value='false'),
    dict(
        operate='update',
        dist_name=MR_NR_CELL_NAME,
        p_name='actPdschRmCsirsForTracking',
        new_value='false'),
    dict(
        operate='update',
        dist_name=MR_NR_CELL_NAME,
        p_name='numOfSubSectors',
        new_value='4sub-sectors'),
    dict(
        operate='update',
        dist_name=MR_NR_CELL_NAME,
        p_name='nrCellType',
        new_value='2DL2UL'),
    dict(
        operate='update',
        dist_name=MR_NR_CELLGRP_NAME,
        p_name='numberOfTransmittedSsBlocks',
        new_value='4 beams'),
    dict(
        operate='update',
        dist_name=MR_NR_CELL_NAME,
        p_name='dlMimoMode',
        new_value='2x2 Closed Loop Spatial Multiplexing'),
    dict(
        operate='update',
        dist_name=MR_NR_CELL_NAME,
        p_name='basicBeamSet',
        new_value='beamSet_4SS'),
    dict(
        operate='update',
        dist_name=MR_NR_NAME,
        p_name='actNrLBRTXPowerSaving',
        new_value='false'),
    dict(
        operate='update',
        dist_name=MR_NR_NAME,
        p_name='actNrLBPowerSaving',
        new_value='false'),
    dict(
        operate='update',
        dist_name=MR_NR_NAME,
        p_name='actNrExtCellSOMethod',
        new_value='false'),
    dict(
        operate='update',
        dist_name=MR_NR_NAME,
        p_name='actNrMixedSOMethod',
        new_value='false'),
    dict(
        operate='update',
        dist_name=MR_NR_NRPGRP_NAME,
        p_name='lbpsSOMethod',
        new_value='cell switch off')
]

PARA_5GC001451_4_openloop = [
    dict(
        operate='update',
        dist_name=MR_NR_CELL_NAME,
        p_name='actExternalAntennaBF',
        new_value='false'),
    dict(
        operate='update',
        dist_name=MR_NR_CELL_NAME,
        p_name='actDlLowPAPRoptimizedPrecoding',
        new_value='false'),
    dict(
        operate='update',
        dist_name=MR_NR_CELL_NAME,
        p_name='actPdschRmCsirsForTracking',
        new_value='false'),
    dict(
        operate='update',
        dist_name=MR_NR_CELL_NAME,
        p_name='numOfSubSectors',
        new_value='4sub-sectors'),
    dict(
        operate='update',
        dist_name=MR_NR_CELL_NAME,
        p_name='nrCellType',
        new_value='2DL2UL'),
    dict(
        operate='update',
        dist_name=MR_NR_CELLGRP_NAME,
        p_name='numberOfTransmittedSsBlocks',
        new_value='4 beams'),
    dict(
        operate='update',
        dist_name=MR_NR_CELL_NAME,
        p_name='dlMimoMode',
        new_value='2x2 Open Loop Spatial Multiplexing'),
    dict(
        operate='update',
        dist_name=MR_NR_CELL_NAME,
        p_name='basicBeamSet',
        new_value='beamSet_4SS'),
    dict(
        operate='update',
        dist_name=MR_NR_NAME,
        p_name='actNrLBRTXPowerSaving',
        new_value='false'),
    dict(
        operate='update',
        dist_name=MR_NR_NAME,
        p_name='actNrLBPowerSaving',
        new_value='false'),
    dict(
        operate='update',
        dist_name=MR_NR_NAME,
        p_name='actNrExtCellSOMethod',
        new_value='false'),
    dict(
        operate='update',
        dist_name=MR_NR_NAME,
        p_name='actNrMixedSOMethod',
        new_value='false'),
    dict(
        operate='update',
        dist_name=MR_NR_NRPGRP_NAME,
        p_name='lbpsSOMethod',
        new_value='cell switch off')
]

PARA_5GC001856_L = [
    dict(
        dist_name=MR_NR_CELL_NAME,
        p_name='dlMimoMode',
        new_value='4x4 or 4x2 Closeed Loop Spatial Multiplexing'),
    dict(
        dist_name=MR_NR_CELL_NAME,
        p_name='actBeamforming',
        new_value='true'),
    dict(
        dist_name=MR_NR_CELL_NAME,
        p_name='basicBeamSet',
        new_value='beamSet_2'),
    dict(
        dist_name=MR_NR_CELLGRP_NAME,
        p_name='ssBurstSetPeriod',
        new_value='20'),
    dict(
        dist_name=MR_NR_CELL_NAME,
        p_name='prachConfigurationIndex',
        new_value='198'),
    dict(
        dist_name=MR_NR_CELL_NAME,
        p_name='nrCellType',
        new_value='4DL2UL'),
    dict(
        dist_name=MR_NR_CELLGRP_NAME,
        p_name='numberOfTransmittedSsBlocks',
        new_value='2 beams')
]

PARA_eCPRI_sync_counters_5min = [
    dict(
        dist_name=MR_MNL_MNL_NET_PMMNL,
        abbr='eCpriMasterStatisticsInterval',
        filter_param='eCPRI Master clock statistics measurement interval',
        new_value='5min')
]

PARA_eCPRI_sync_counters_15min = [
    dict(
        dist_name=MR_MNL_MNL_NET_PMMNL,
        abbr='eCpriMasterStatisticsInterval',
        filter_param='eCPRI Master clock statistics measurement interval',
        new_value='15min')
]

PARA_eCPRI_General_SiSo_status_NIDD = [
    dict(
        operate='update',
        dist_name=MR_MNL_MNL_SYNC_CLOCK_1,
        p_name='syncMaster',
        new_value='true')
]

PARA_5GC002538_10 = [
    dict(
        dist_name=MR_NR_NAME,
        operate='update',
        p_name='actFdmEnhancedScheduling',
        new_value='true'),
    dict(
        dist_name=MR_NR_CELL_NAME,
        operate='update',
        p_name='actPdschAtSsbSlots',
        new_value='true'),
    dict(
        dist_name=MR_NR_CELL_NAME,
        operate='update',
        p_name='actPdschRmCsirsForTracking',
        new_value='true'),
    dict(
        dist_name=MR_NR_CELL_NAME,
        operate='update',
        p_name='chBw',
        new_value='90MHz'),
    dict(
        dist_name=MR_NR_CELL_NAME,
        operate='update',
        p_name='nrCellType',
        new_value='4DL2UL'),
    dict(
        dist_name=MR_NR_CELL_NAME,
        operate='update',
        p_name='numberOfRxBeamforming',
        new_value='2Rx'),
    dict(
        dist_name=MR_NR_CELL_NAME,
        operate='update',
        p_name='basicBeamSet',
        new_value='beamSet_2'),
    dict(
        dist_name=MR_NR_CELL_NAME,
        operate='update',
        list_name='csirsForTracking',
        p_name='rbAllocation',
        new_value='BWP'),
    dict(
        dist_name=MR_NR_CELL_NAME,
        operate='update',
        list_name='csirsForTracking',
        p_name='csirsTrackingPeriod',
        new_value='20ms'),
    dict(
        dist_name=MR_NR_CELLGRP_NAME,
        operate='update',
        p_name='numberOfTransmittedSsBlocks',
        new_value='2 beams'),
    dict(
        dist_name=MR_NR_CELL_NAME,
        operate='update',
        p_name='ssPbchBlockPower',
        new_value='12'),
    dict(
        dist_name=MR_NR_CELL_NAME,
        operate='update',
        p_name='pMax',
        new_value='420')
]

PARA_5GC002538_11 = [
    dict(
        dist_name=MR_NR_NAME,
        operate='update',
        p_name='actFdmEnhancedScheduling',
        new_value='true'),
    dict(
        dist_name=MR_NR_CELL_NAME,
        operate='update',
        p_name='actPdschAtSsbSlots',
        new_value='true'),
    dict(
        dist_name=MR_NR_CELL_NAME,
        operate='update',
        p_name='actPdschRmCsirsForTracking',
        new_value='true'),
    dict(
        dist_name=MR_NR_CELL_NAME,
        operate='update',
        p_name='chBw',
        new_value='80MHz'),
    dict(
        dist_name=MR_NR_CELL_NAME,
        operate='update',
        p_name='nrCellType',
        new_value='4DL2UL'),
    dict(
        dist_name=MR_NR_CELL_NAME,
        operate='update',
        p_name='numberOfRxBeamforming',
        new_value='2Rx'),
    dict(
        dist_name=MR_NR_CELL_NAME,
        operate='update',
        p_name='basicBeamSet',
        new_value='beamSet_2'),
    dict(
        dist_name=MR_NR_CELL_NAME,
        operate='update',
        list_name='csirsForTracking',
        p_name='rbAllocation',
        new_value='BWP'),
    dict(
        dist_name=MR_NR_CELL_NAME,
        operate='update',
        list_name='csirsForTracking',
        p_name='csirsTrackingPeriod',
        new_value='20ms'),
    dict(
        dist_name=MR_NR_CELLGRP_NAME,
        operate='update',
        p_name='numberOfTransmittedSsBlocks',
        new_value='2 beams'),
    dict(
        dist_name=MR_NR_CELL_NAME,
        operate='update',
        p_name='ssPbchBlockPower',
        new_value='12'),
    dict(
        dist_name=MR_NR_CELL_NAME,
        operate='update',
        p_name='pMax',
        new_value='420')
]

PARA_5GC002538_12 = [
    dict(
        dist_name=MR_NR_NAME,
        operate='update',
        p_name='actFdmEnhancedScheduling',
        new_value='true'),
    dict(
        dist_name=MR_NR_CELL_NAME,
        operate='update',
        p_name='actPdschAtSsbSlots',
        new_value='true'),
    dict(
        dist_name=MR_NR_CELL_NAME,
        operate='update',
        p_name='actPdschRmCsirsForTracking',
        new_value='true'),
    dict(
        dist_name=MR_NR_CELL_NAME,
        operate='update',
        p_name='chBw',
        new_value='70 MHz'),
    dict(
        dist_name=MR_NR_CELL_NAME,
        operate='update',
        p_name='nrCellType',
        new_value='4DL4UL'),
    dict(
        dist_name=MR_NR_CELL_NAME,
        operate='update',
        p_name='numberOfRxBeamforming',
        new_value='4Rx'),
    dict(
        dist_name=MR_NR_CELL_NAME,
        operate='update',
        p_name='basicBeamSet',
        new_value='beamSet_2'),
    dict(
        dist_name=MR_NR_CELL_NAME,
        operate='update',
        list_name='csirsForTracking',
        p_name='rbAllocation',
        new_value='BWP'),
    dict(
        dist_name=MR_NR_CELL_NAME,
        operate='update',
        list_name='csirsForTracking',
        p_name='csirsTrackingPeriod',
        new_value='80ms'),
    dict(
        dist_name=MR_NR_CELLGRP_NAME,
        operate='update',
        p_name='numberOfTransmittedSsBlocks',
        new_value='2 beams'),
    dict(
        dist_name=MR_NR_CELL_NAME,
        operate='update',
        p_name='ssPbchBlockPower',
        new_value='9'),
    dict(
        dist_name=MR_NR_CELL_NAME,
        operate='update',
        p_name='pMax',
        new_value='420')
]

PARA_5GC001348_13 = [
    dict(
        dist_name=MR_NR_NAME,
        operate='update',
        p_name='actFdmEnhancedScheduling',
        new_value='false'),
    dict(
        dist_name=MR_NR_CELL_NAME,
        operate='update',
        p_name='actPrachMultiplexing',
        new_value='true'),
    dict(
        dist_name=MR_NR_CELL_NAME,
        operate='update',
        p_name='chBw',
        new_value='100MHz'),
    dict(
        dist_name=MR_NR_CELL_NAME,
        operate='update',
        p_name='nrCellType',
        new_value='2DL2UL'),
    dict(
        dist_name=MR_NR_CELL_NAME,
        operate='update',
        p_name='prachConfigurationIndex',
        new_value='191'),
    dict(
        dist_name=MR_NR_CELL_NAME,
        operate='update',
        p_name='msg1FrequencyStart',
        new_value='0'),
    dict(
        dist_name=MR_NR_CELL_NAME,
        operate='update',
        p_name='csiReportPeriodicity',
        new_value='slots20'),
    dict(
        dist_name=MR_NR_CELL_NAME,
        operate='update',
        p_name='frameStructureType',
        new_value='semiStatic'),
    dict(
        dist_name=MR_NR_CELL_NAME,
        operate='update',
        p_name='guardPeriodLength',
        new_value='2Symbols'),
    dict(
        dist_name=MR_NR_CELL_NAME,
        operate='update',
        p_name='ulDlDataSlotRatio',
        new_value='1/4')
]

PARA_5GC001348_14 = [
    dict(
        dist_name=MR_NR_NAME,
        operate='update',
        p_name='actFdmEnhancedScheduling',
        new_value='false'),
    dict(
        dist_name=MR_NR_NAME,
        operate='update',
        p_name='actFdmScheduling',
        new_value='true'),
    dict(
        dist_name=MR_NR_CELL_NAME,
        operate='update',
        p_name='chBw',
        new_value='90MHz'),
    dict(
        dist_name=MR_NR_CELL_NAME,
        operate='update',
        p_name='nrCellType',
        new_value='4DL2UL'),
    dict(
        dist_name=MR_NR_CELL_NAME,
        operate='update',
        p_name='prachConfigurationIndex',
        new_value='97'),
    dict(
        dist_name=MR_NR_CELL_NAME,
        operate='update',
        p_name='msg1FrequencyStart',
        new_value='10'),
    dict(
        dist_name=MR_NR_CELL_NAME,
        operate='update',
        p_name='csiReportPeriodicity',
        new_value='slots20'),
    dict(
        dist_name=MR_NR_CELL_NAME,
        operate='update',
        p_name='frameStructureType',
        new_value='tdLte'),
    dict(
        dist_name=MR_NR_CELL_NAME,
        operate='update',
        p_name='guardPeriodLength',
        new_value='4Symbols'),
    dict(
        dist_name=MR_NR_CELL_NAME,
        operate='update',
        p_name='lteToNrFrameShift',
        new_value='0ms'),
    dict(
        dist_name=MR_NR_CELL_NAME,
        operate='update',
        p_name='ulDlDataSlotRatio',
        new_value='1/4')
]

PARA_5GC001348_15 = [
    dict(
        dist_name=MR_NR_NAME,
        operate='update',
        p_name='actFdmEnhancedScheduling',
        new_value='true'),
    dict(
        dist_name=MR_NR_NAME,
        operate='update',
        p_name='actFdmScheduling',
        new_value='true'),
    dict(
        dist_name=MR_NR_CELL_NAME,
        operate='update',
        p_name='actPrachMultiplexing',
        new_value='true'),
    dict(
        dist_name=MR_NR_CELL_NAME,
        operate='update',
        p_name='chBw',
        new_value='80MHz'),
    dict(
        dist_name=MR_NR_CELL_NAME,
        operate='update',
        p_name='nrCellType',
        new_value='4DL2UL'),
    dict(
        dist_name=MR_NR_CELL_NAME,
        operate='update',
        p_name='prachConfigurationIndex',
        new_value='148'),
    dict(
        dist_name=MR_NR_CELL_NAME,
        operate='update',
        p_name='msg1FrequencyStart',
        new_value='0'),
    dict(
        dist_name=MR_NR_CELL_NAME,
        operate='update',
        p_name='csiReportPeriodicity',
        new_value='slots20'),
    dict(
        dist_name=MR_NR_CELL_NAME,
        operate='update',
        p_name='frameStructureType',
        new_value='semiStatic'),
    dict(
        dist_name=MR_NR_CELL_NAME,
        operate='update',
        p_name='guardPeriodLength',
        new_value='2Symbols'),
    dict(
        dist_name=MR_NR_CELL_NAME,
        operate='update',
        p_name='ulDlDataSlotRatio',
        new_value='3/7')
]

PARA_5GC001856_19 = [
    dict(
        dist_name=MR_NR_CELL_NAME,
        operate='update',
        p_name='chBw',
        new_value='100MHz')
]

PARA_ARFCN_629944 = [
    dict(
        dist_name=MR_NR_CELL_NAME,
        operate='update',
        p_name='nrarfcn',
        new_value='629944'),
    dict(
        dist_name=MR_NR_CELL_NAME,
        operate='update',
        p_name='gscnOrSsPbchArfcn',
        new_value='7811'),
]

PARA_ARFCN_629942 = [
    dict(
        dist_name=MR_NR_CELL_NAME,
        abbr='nrarfcn',
        filter_param='NR Absolute radio frequency channel number',
        new_value='629942')
]

PARA_ARFCN_636722 = [
    dict(
        dist_name=MR_NR_CELL_NAME,
        operate='update',
        p_name='nrarfcn',
        new_value='636722'),
    dict(
        dist_name=MR_NR_CELL_NAME,
        operate='update',
        p_name='gscnOrSsPbchArfcn',
        new_value='7881'),
]

PARA_ARFCN_636724 = [
    dict(
        dist_name=MR_NR_CELL_NAME,
        abbr='nrarfcn',
        filter_param='NR Absolute radio frequency channel number',
        new_value='636724')
]

ATTENUATION_VALUE_1451_DEFAULT = {
    'atten_value_of_port0': 0,
    'atten_value_of_port1': 0,
    'atten_value_of_port2': 0,
    'atten_value_of_port3': 0,
    'atten_value_of_port8': 0,
    'atten_value_of_port9': 0,
    'atten_value_of_port10': 0,
    'atten_value_of_port11': 0
}

ATTENUATION_VALUE_1451_2_1234 = {
    'atten_value_of_port0': 0,
    'atten_value_of_port1': 0,
    'atten_value_of_port2': 0,
    'atten_value_of_port3': 0,
    'atten_value_of_port8': 127,
    'atten_value_of_port9': 127,
    'atten_value_of_port10': 127,
    'atten_value_of_port11': 127
}

ATTENUATION_VALUE_1451_2_mid = {
    'atten_value_of_port0': 30,
    'atten_value_of_port1': 30,
    'atten_value_of_port2': 30,
    'atten_value_of_port3': 30,
    'atten_value_of_port8': 0,
    'atten_value_of_port9': 0,
    'atten_value_of_port10': 0,
    'atten_value_of_port11': 0
}

ATTENUATION_VALUE_1451_2_5678 = {
    'atten_value_of_port0': 127,
    'atten_value_of_port1': 127,
    'atten_value_of_port2': 127,
    'atten_value_of_port3': 127,
    'atten_value_of_port8': 0,
    'atten_value_of_port9': 0,
    'atten_value_of_port10': 0,
    'atten_value_of_port11': 0
}

ATTENUATION_VALUE_1451_4_12 = {
    'atten_value_of_port0': 0,
    'atten_value_of_port1': 0,
    'atten_value_of_port2': 127,
    'atten_value_of_port3': 127,
    'atten_value_of_port8': 127,
    'atten_value_of_port9': 127,
    'atten_value_of_port10': 127,
    'atten_value_of_port11': 127
}

ATTENUATION_VALUE_1451_4_mid = {
    'atten_value_of_port0': 30,
    'atten_value_of_port1': 30,
    'atten_value_of_port2': 127,
    'atten_value_of_port3': 127,
    'atten_value_of_port8': 0,
    'atten_value_of_port9': 0,
    'atten_value_of_port10': 127,
    'atten_value_of_port11': 127
}

ATTENUATION_VALUE_1451_4_56 = {
    'atten_value_of_port0': 127,
    'atten_value_of_port1': 127,
    'atten_value_of_port2': 127,
    'atten_value_of_port3': 127,
    'atten_value_of_port8': 0,
    'atten_value_of_port9': 0,
    'atten_value_of_port10': 127,
    'atten_value_of_port11': 127
}

ATTENUATION_VALUE_2ND_CELL = {
    'atten_value_of_port0': 127,
    'atten_value_of_port1': 127,
    'atten_value_of_port2': 127,
    'atten_value_of_port3': 127,
    'atten_value_of_port8': 0,
    'atten_value_of_port9': 0,
    'atten_value_of_port10': 127,
    'atten_value_of_port11': 127
}

ATTENUATION_VALUE_default = {
    'atten_value_of_port0': 0,
    'atten_value_of_port1': 0,
    'atten_value_of_port2': 0,
    'atten_value_of_port3': 0,
    'atten_value_of_port4': 0,
    'atten_value_of_port5': 0,
    'atten_value_of_port6': 0,
    'atten_value_of_port7': 0
}

ATTENUATION_VALUE_2538_12 = {
    'atten_value_of_port0': 53,
    'atten_value_of_port1': 53,
    'atten_value_of_port2': 40,
    'atten_value_of_port3': 40,
    'atten_value_of_port4': 127,
    'atten_value_of_port5': 127,
    'atten_value_of_port6': 127,
    'atten_value_of_port7': 127
}

ATTENUATION_VALUE_2538_10 = {
    'atten_value_of_port0': 15,
    'atten_value_of_port1': 15,
    'atten_value_of_port2': 15,
    'atten_value_of_port3': 15,
    'atten_value_of_port4': 127,
    'atten_value_of_port5': 127,
    'atten_value_of_port6': 127,
    'atten_value_of_port7': 127
}

ATTENUATION_VALUE_1856_rank1 = {
    'atten_value_of_port0': 18,
    'atten_value_of_port1': 127,
    'atten_value_of_port2': 127,
    'atten_value_of_port3': 127,
    'atten_value_of_port4': 127,
    'atten_value_of_port5': 127,
    'atten_value_of_port6': 127,
    'atten_value_of_port7': 127
}

ATTENUATION_VALUE_1856_rank2 = {
    'atten_value_of_port0': 18,
    'atten_value_of_port1': 18,
    'atten_value_of_port2': 127,
    'atten_value_of_port3': 127,
    'atten_value_of_port4': 127,
    'atten_value_of_port5': 127,
    'atten_value_of_port6': 127,
    'atten_value_of_port7': 127
}

ATTENUATION_VALUE_1856_rank3 = {
    'atten_value_of_port0': 18,
    'atten_value_of_port1': 18,
    'atten_value_of_port2': 18,
    'atten_value_of_port3': 127,
    'atten_value_of_port4': 127,
    'atten_value_of_port5': 127,
    'atten_value_of_port6': 127,
    'atten_value_of_port7': 127
}

ATTENUATION_VALUE_1856_rank4 = {
    'atten_value_of_port0': 18,
    'atten_value_of_port1': 18,
    'atten_value_of_port2': 18,
    'atten_value_of_port3': 18,
    'atten_value_of_port4': 127,
    'atten_value_of_port5': 127,
    'atten_value_of_port6': 127,
    'atten_value_of_port7': 127
}

PARA_5GC002537_01 = [
    dict(
        dist_name=MR_NR_NAME,
        operate='update',
        p_name='actFdmEnhancedScheduling',
        new_value='false'),
    dict(
        dist_name=MR_NR_NAME,
        operate='update',
        p_name='actFdmScheduling',
        new_value='false'),
    dict(
        dist_name=MR_NR_CELL_NAME,
        operate='update',
        p_name='chBw',
        new_value='100MHz')
]

ATTENUATION_VALUE_2537_01 = {
    'atten_value_of_port0': 57,
    'atten_value_of_port1': 56,
    'atten_value_of_port2': 42,
    'atten_value_of_port3': 42,
    'atten_value_of_port4': 127,
    'atten_value_of_port5': 127,
    'atten_value_of_port6': 127,
    'atten_value_of_port7': 127
}
