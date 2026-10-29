import os
from robot.libraries.BuiltIn import BuiltIn
tl = BuiltIn().get_variable_value('${tl}')

CFG_DIR = os.path.dirname(os.path.abspath(__file__))

# SCF parameters to modify
MR_BTS_NAME = 'MRBTS-' + str(tl.gnbs[0].instance_id)
MR_NR_BTS_NAME = MR_BTS_NAME + '/NRBTS-' + str(tl.gnbs[0].global_bts_id)
MR_NR_CELL_NAME = MR_NR_BTS_NAME + '/NRCELL-1'
MR_NR_CELLGRP_NAME = MR_NR_BTS_NAME + '/NRCELLGRP-0'

MODIFY_PARA_256QAM_4x4_Beamset3_1 = [
    dict(
        new_value='tdLte',
        dist_name=MR_NR_CELL_NAME,
        filter_param='Frame Structure Type',
        abbr='frameStructureType'),
    dict(
        new_value='4Symbols',
        dist_name=MR_NR_CELL_NAME,
        filter_param='Guard Period length',
        abbr='guardPeriodLength'),
    dict(
        new_value='0ms',
        dist_name=MR_NR_CELL_NAME,
        filter_param='LTE to NR frame shift',
        abbr='lteToNrFrameShift'),
    dict(
        new_value='2/8',
        dist_name=MR_NR_CELL_NAME,
        filter_param='UL to DL logical data slot ratio',
        abbr='ulDlDataSlotRatio'),
    dict(
        dist_name=MR_NR_CELL_NAME,
        abbr='basicBeamSet',
        filter_param='Basic Beam Set',
        new_value='beamSet_3_1'),
    dict(
        dist_name=MR_NR_CELL_NAME,
        abbr='actDl256Qam',
        filter_param='Activate 256QAM in DL',
        new_value='true'),
    dict(
        dist_name=MR_NR_CELL_NAME,
        abbr='actBeamforming',
        filter_param='Activate Beamforming',
        new_value='true'),
    dict(
        dist_name=MR_NR_CELLGRP_NAME,
        abbr='numberOfTransmittedSsBlocks',
        filter_param='Number of transmitted Synchronization Signal Blocks',
        new_value='4 beams'),
    dict(
        dist_name=MR_NR_CELL_NAME,
        abbr='nrCellType',
        filter_param='NR Cell type',
        new_value='4DL2UL'),
    dict(
        dist_name=MR_NR_CELL_NAME,
        abbr='dlMimoMode',
        filter_param='Downlink MIMO Mode',
        new_value='4x4 or 4x2 Closed Loop Spatial Multiplexing')
]

MODIFY_PARA_256QAM_4x4_Beamset5_1 = [
    dict(
        dist_name=MR_NR_CELL_NAME,
        parameter='beamSet',
        value=[{'basicBeamSet': 'beamSet_5_1'}]),
    dict(
        dist_name=MR_NR_CELL_NAME,
        parameter='actBeamforming',
        value='true'),
    dict(
        dist_name=MR_NR_CELLGRP_NAME,
        parameter='numberOfTransmittedSsBlocks',
        value='6 beams'),
    dict(
        dist_name=MR_NR_CELLGRP_NAME,
        parameter='ssBurstSetPeriod',
        value='20'),
    dict(
        dist_name=MR_NR_CELL_NAME,
        parameter='nrCellType',
        value='4DL2UL'),
    dict(
        dist_name=MR_NR_CELL_NAME,
        parameter='dlMimoMode',
        value='4x4 or 4x2 Closed Loop Spatial Multiplexing')
]

MODIFY_PARA_256QAM_4x4_Beamset6 = [
    dict(
        new_value='tdLte',
        dist_name=MR_NR_CELL_NAME,
        filter_param='Frame Structure Type',
        abbr='frameStructureType'),
    dict(
        new_value='4Symbols',
        dist_name=MR_NR_CELL_NAME,
        filter_param='Guard Period length',
        abbr='guardPeriodLength'),
    dict(
        new_value='0ms',
        dist_name=MR_NR_CELL_NAME,
        filter_param='LTE to NR frame shift',
        abbr='lteToNrFrameShift'),
    dict(
        new_value='2/8',
        dist_name=MR_NR_CELL_NAME,
        filter_param='UL to DL logical data slot ratio',
        abbr='ulDlDataSlotRatio'),
    dict(
        dist_name=MR_NR_CELL_NAME,
        abbr='basicBeamSet',
        filter_param='Basic Beam Set',
        new_value='beamSet_6'),
    dict(
        dist_name=MR_NR_CELL_NAME,
        abbr='actDl256Qam',
        filter_param='Activate 256QAM in DL',
        new_value='true'),
    dict(
        dist_name=MR_NR_CELL_NAME,
        abbr='actBeamforming',
        filter_param='Activate Beamforming',
        new_value='true'),
    dict(
        dist_name=MR_NR_CELLGRP_NAME,
        abbr='numberOfTransmittedSsBlocks',
        filter_param='Number of transmitted Synchronization Signal Blocks',
        new_value='6 beams'),
    dict(
        dist_name=MR_NR_CELL_NAME,
        abbr='nrCellType',
        filter_param='NR Cell type',
        new_value='4DL2UL'),
    dict(
        dist_name=MR_NR_CELL_NAME,
        abbr='dlMimoMode',
        filter_param='Downlink MIMO Mode',
        new_value='4x4 or 4x2 Closed Loop Spatial Multiplexing')
]

MODIFY_PARA_CloseLoop_64QAM = [
    dict(
        new_value='tdLte',
        dist_name=MR_NR_CELL_NAME,
        filter_param='Frame Structure Type',
        abbr='frameStructureType'),
    dict(
        new_value='4Symbols',
        dist_name=MR_NR_CELL_NAME,
        filter_param='Guard Period length',
        abbr='guardPeriodLength'),
    dict(
        new_value='0ms',
        dist_name=MR_NR_CELL_NAME,
        filter_param='LTE to NR frame shift',
        abbr='lteToNrFrameShift'),
    dict(
        new_value='2/8',
        dist_name=MR_NR_CELL_NAME,
        filter_param='UL to DL logical data slot ratio',
        abbr='ulDlDataSlotRatio'),
    dict(
        dist_name=MR_NR_CELL_NAME,
        abbr='actDl256Qam',
        filter_param='Activate 256QAM in DL',
        new_value='false'),
    dict(
        dist_name=MR_NR_CELL_NAME,
        abbr='nrCellType',
        filter_param='NR Cell type',
        new_value='2DL2UL'),
    dict(
        dist_name=MR_NR_CELL_NAME,
        abbr='basicBeamSet',
        filter_param='Basic Beam Set',
        new_value='beamSet_1'),
    dict(
        dist_name=MR_NR_CELLGRP_NAME,
        abbr='numberOfTransmittedSsBlocks',
        filter_param='Number of transmitted Synchronization Signal Blocks',
        new_value='1 beam'),
    dict(
        dist_name=MR_NR_CELL_NAME,
        abbr='dlMimoMode',
        filter_param='Downlink MIMO Mode',
        new_value='2x2 Closed Loop Spatial Multiplexing')
]

MODIFY_PARA_CloseLoop_256QAM = [
    dict(
        new_value='tdLte',
        dist_name=MR_NR_CELL_NAME,
        filter_param='Frame Structure Type',
        abbr='frameStructureType'),
    dict(
        new_value='4Symbols',
        dist_name=MR_NR_CELL_NAME,
        filter_param='Guard Period length',
        abbr='guardPeriodLength'),
    dict(
        new_value='0ms',
        dist_name=MR_NR_CELL_NAME,
        filter_param='LTE to NR frame shift',
        abbr='lteToNrFrameShift'),
    dict(
        new_value='2/8',
        dist_name=MR_NR_CELL_NAME,
        filter_param='UL to DL logical data slot ratio',
        abbr='ulDlDataSlotRatio'),
    dict(
        dist_name=MR_NR_CELL_NAME,
        abbr='actDl256Qam',
        filter_param='Activate 256QAM in DL',
        new_value='true'),
    dict(
        dist_name=MR_NR_CELL_NAME,
        abbr='nrCellType',
        filter_param='NR Cell type',
        new_value='2DL2UL'),
    dict(
        dist_name=MR_NR_CELL_NAME,
        abbr='basicBeamSet',
        filter_param='Basic Beam Set',
        new_value='beamSet_1'),
    dict(
        dist_name=MR_NR_CELLGRP_NAME,
        abbr='numberOfTransmittedSsBlocks',
        filter_param='Number of transmitted Synchronization Signal Blocks',
        new_value='1 beam'),
    dict(
        dist_name=MR_NR_CELL_NAME,
        abbr='dlMimoMode',
        filter_param='Downlink MIMO Mode',
        new_value='2x2 Closed Loop Spatial Multiplexing')
]

MODIFY_PARA_1116_0ms_GP6 = [
    dict(
        new_value='tdLte',
        dist_name=MR_NR_CELL_NAME,
        filter_param='Frame Structure Type',
        abbr='frameStructureType'),
    dict(
        new_value='6Symbols',
        dist_name=MR_NR_CELL_NAME,
        filter_param='Guard Period length',
        abbr='guardPeriodLength'),
    dict(
        new_value='0ms',
        dist_name=MR_NR_CELL_NAME,
        filter_param='LTE to NR frame shift',
        abbr='lteToNrFrameShift'),
    dict(
        new_value='2/8',
        dist_name=MR_NR_CELL_NAME,
        filter_param='UL to DL logical data slot ratio',
        abbr='ulDlDataSlotRatio'),
    dict(
        dist_name=MR_NR_CELL_NAME,
        abbr='actDl256Qam',
        filter_param='Activate 256QAM in DL',
        new_value='true')
]

MODIFY_PARA_1116_PTRS_80ms = [
    dict(
        new_value='80ms',
        dist_name=MR_NR_CELL_NAME,
        filter_param='CSI-RS Tracking Period',
        abbr='csirsTrackingPeriod'),
    dict(
        new_value='tdLte',
        dist_name=MR_NR_CELL_NAME,
        filter_param='Frame Structure Type',
        abbr='frameStructureType'),
    dict(
        new_value='4Symbols',
        dist_name=MR_NR_CELL_NAME,
        filter_param='Guard Period length',
        abbr='guardPeriodLength'),
    dict(
        new_value='0ms',
        dist_name=MR_NR_CELL_NAME,
        filter_param='LTE to NR frame shift',
        abbr='lteToNrFrameShift'),
    dict(
        new_value='2/8',
        dist_name=MR_NR_CELL_NAME,
        filter_param='UL to DL logical data slot ratio',
        abbr='ulDlDataSlotRatio'),
    dict(
        dist_name=MR_NR_CELL_NAME,
        abbr='actDl256Qam',
        filter_param='Activate 256QAM in DL',
        new_value='true')
]

MODIFY_PARA_1116_PTRS_40ms = [
    dict(
        new_value='40ms',
        dist_name=MR_NR_CELL_NAME,
        filter_param='CSI-RS Tracking Period',
        abbr='csirsTrackingPeriod'),
    dict(
        new_value='tdLte',
        dist_name=MR_NR_CELL_NAME,
        filter_param='Frame Structure Type',
        abbr='frameStructureType'),
    dict(
        new_value='4Symbols',
        dist_name=MR_NR_CELL_NAME,
        filter_param='Guard Period length',
        abbr='guardPeriodLength'),
    dict(
        new_value='0ms',
        dist_name=MR_NR_CELL_NAME,
        filter_param='LTE to NR frame shift',
        abbr='lteToNrFrameShift'),
    dict(
        new_value='2/8',
        dist_name=MR_NR_CELL_NAME,
        filter_param='UL to DL logical data slot ratio',
        abbr='ulDlDataSlotRatio'),
    dict(
        dist_name=MR_NR_CELL_NAME,
        abbr='actDl256Qam',
        filter_param='Activate 256QAM in DL',
        new_value='true')
]
