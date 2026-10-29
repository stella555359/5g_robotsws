# -*- coding: utf-8 -*
import os
from robot.libraries.BuiltIn import BuiltIn
tl = BuiltIn().get_variable_value('${tl}')

CFG_DIR = os.path.dirname(os.path.abspath(__file__))
MR_BTS_NAME = 'MRBTS-' + str(tl.gnbs[0].instance_id)
MR_NR_BTS_NAME = MR_BTS_NAME + '/NRBTS-' + str(tl.gnbs[0].global_bts_id)
MR_NR_CELL_NAME = MR_NR_BTS_NAME + '/NRCELL-1'
MR_NR_CELL_GROUP_NAME = MR_NR_BTS_NAME + '/NRCELLGRP-0'

MODIFY_SCF_A_1 = [
    # 1116 frame structure
    dict(
        value='tdLte',
        dist_name=MR_NR_CELL_NAME,
        p_name='frameStructureType'),
    dict(
        value='4Symbols',
        dist_name=MR_NR_CELL_NAME,
        p_name='guardPeriodLength'),
    dict(
        value='3ms',
        dist_name=MR_NR_CELL_NAME,
        p_name='lteToNrFrameShift'),
]
MODIFY_SCF_A_5 = [
    # 1116 frame structure
    dict(
        value='102',
        dist_name=MR_NR_CELL_NAME,
        p_name='prachConfigurationIndex'),
    dict(
        value='false',
        dist_name=MR_NR_CELL_NAME,
        p_name='actDlMuMimo'),
    dict(
        value='4x4 or 4x2 Open Loop Spatial Multiplexing',
        dist_name=MR_NR_CELL_NAME,
        p_name='dlMimoMode'),
    dict(
        value='true',
        dist_name=MR_NR_CELL_NAME,
        p_name='actDl256Qam'),
    dict(
        value='80MHz',
        dist_name=MR_NR_CELL_NAME,
        p_name='chBw'),
    dict(
        value='tdLte',
        dist_name=MR_NR_CELL_NAME,
        p_name='frameStructureType'),
    dict(
        value='4Symbols',
        dist_name=MR_NR_CELL_NAME,
        p_name='guardPeriodLength'),
    dict(
        value='0ms',
        dist_name=MR_NR_CELL_NAME,
        p_name='lteToNrFrameShift'),
    dict(
        value='1/4',
        dist_name=MR_NR_CELL_NAME,
        p_name='ulDlDataSlotRatio'),
    dict(
        value='2sub-sectors',
        dist_name=MR_NR_CELL_NAME,
        p_name='numOfSubSectors'),
    dict(
        value='beamSet_2SS',
        dist_name=MR_NR_CELL_NAME,
        p_name='basicBeamSet'),
    dict(
        value='2 beams',
        dist_name=MR_NR_CELL_GROUP_NAME,
        p_name='numberOfTransmittedSsBlocks'),
    dict(
        value='false',
        dist_name=MR_NR_CELL_NAME,
        p_name='actExternalAntennaBF'),
    dict(
        value='4DL2UL',
        dist_name=MR_NR_CELL_NAME,
        p_name='nrCellType'),
    dict(
        value='2Rx',
        dist_name=MR_NR_CELL_NAME,
        p_name='numberOfRxBeamforming'),
]
MODIFY_SCF_B_01 = [
    # 1116 frame structure
    dict(
        value='104',
        dist_name=MR_NR_CELL_NAME,
        p_name='prachConfigurationIndex'),
    dict(
        value='4x4 or 4x2 Closed Loop Spatial Multiplexing',
        dist_name=MR_NR_CELL_NAME,
        p_name='dlMimoMode'),
    dict(
        value='true',
        dist_name=MR_NR_CELL_NAME,
        p_name='actDl256Qam'),
    dict(
        value='40MHz',
        dist_name=MR_NR_CELL_NAME,
        p_name='chBw'),
    dict(
        value='tdLte',
        dist_name=MR_NR_CELL_NAME,
        p_name='frameStructureType'),
    dict(
        value='4Symbols',
        dist_name=MR_NR_CELL_NAME,
        p_name='guardPeriodLength'),
    dict(
        value='3ms',
        dist_name=MR_NR_CELL_NAME,
        p_name='lteToNrFrameShift'),
    dict(
        value='1/4',
        dist_name=MR_NR_CELL_NAME,
        p_name='ulDlDataSlotRatio'),
]
MODIFY_SCF_B_02 = [
    dict(
        value='102',
        dist_name=MR_NR_CELL_NAME,
        p_name='prachConfigurationIndex'),
    dict(
        value='false',
        dist_name=MR_NR_CELL_NAME,
        p_name='actDlMuMimo'),
    dict(
        value='4x4 or 4x2 Open Loop Spatial Multiplexing',
        dist_name=MR_NR_CELL_NAME,
        p_name='dlMimoMode'),
    dict(
        value='true',
        dist_name=MR_NR_CELL_NAME,
        p_name='actDl256Qam'),
    dict(
        value='100MHz',
        dist_name=MR_NR_CELL_NAME,
        p_name='chBw'),
    dict(
        value='tdLte',
        dist_name=MR_NR_CELL_NAME,
        p_name='frameStructureType'),
    dict(
        value='4Symbols',
        dist_name=MR_NR_CELL_NAME,
        p_name='guardPeriodLength'),
    dict(
        value='0ms',
        dist_name=MR_NR_CELL_NAME,
        p_name='lteToNrFrameShift'),
    dict(
        value='1/4',
        dist_name=MR_NR_CELL_NAME,
        p_name='ulDlDataSlotRatio'),
    dict(
        value='2sub-sectors',
        dist_name=MR_NR_CELL_NAME,
        p_name='numOfSubSectors'),
    dict(
        value='beamSet_2SS',
        dist_name=MR_NR_CELL_NAME,
        p_name='basicBeamSet'),
    dict(
        value='2 beams',
        dist_name=MR_NR_CELL_GROUP_NAME,
        p_name='numberOfTransmittedSsBlocks'),
    dict(
        value='false',
        dist_name=MR_NR_CELL_NAME,
        p_name='actExternalAntennaBF'),
    dict(
        value='4DL2UL',
        dist_name=MR_NR_CELL_NAME,
        p_name='nrCellType'),
    dict(
        value='2Rx',
        dist_name=MR_NR_CELL_NAME,
        p_name='numberOfRxBeamforming'),
    dict(
        value='false',
        dist_name=MR_NR_CELL_NAME,
        p_name='actDlLowPAPRoptimizedPrecoding'),
]
MODIFY_SCF_B_03 = [
    dict(
        value='148',
        dist_name=MR_NR_CELL_NAME,
        p_name='prachConfigurationIndex'),
    dict(
        value='false',
        dist_name=MR_NR_CELL_NAME,
        p_name='actDlMuMimo'),
    dict(
        value='2x2 Open Loop Spatial Multiplexing',
        dist_name=MR_NR_CELL_NAME,
        p_name='dlMimoMode'),
    dict(
        value='true',
        dist_name=MR_NR_CELL_NAME,
        p_name='actDl256Qam'),
    dict(
        value='20MHz',
        dist_name=MR_NR_CELL_NAME,
        p_name='chBw'),
    dict(
        value='semiStatic',
        dist_name=MR_NR_CELL_NAME,
        p_name='frameStructureType'),
    dict(
        value='2Symbols',
        dist_name=MR_NR_CELL_NAME,
        p_name='guardPeriodLength'),
    dict(
        value='0ms',
        dist_name=MR_NR_CELL_NAME,
        p_name='lteToNrFrameShift'),
    dict(
        value='3/7',
        dist_name=MR_NR_CELL_NAME,
        p_name='ulDlDataSlotRatio'),
    dict(
        value='4sub-sectors',
        dist_name=MR_NR_CELL_NAME,
        p_name='numOfSubSectors'),
    dict(
        value='beamSet_4SS',
        dist_name=MR_NR_CELL_NAME,
        p_name='basicBeamSet'),
    dict(
        value='4 beams',
        dist_name=MR_NR_CELL_GROUP_NAME,
        p_name='numberOfTransmittedSsBlocks'),
    dict(
        value='false',
        dist_name=MR_NR_CELL_NAME,
        p_name='actExternalAntennaBF'),
    dict(
        value='2DL2UL',
        dist_name=MR_NR_CELL_NAME,
        p_name='nrCellType'),
    dict(
        value='2Rx',
        dist_name=MR_NR_CELL_NAME,
        p_name='numberOfRxBeamforming'),
    dict(
        value='false',
        dist_name=MR_NR_CELL_NAME,
        p_name='actDlLowPAPRoptimizedPrecoding'),
    dict(
        value='false',
        dist_name=MR_NR_CELL_NAME,
        p_name='actPdschRmCsirsForTracking'),
]
MODIFY_SCF_B_04 = [
    dict(
        value='3/7',
        dist_name=MR_NR_CELL_NAME,
        p_name='ulDlDataSlotRatio'),
]
MODIFY_SCF_C_05 = [
    dict(
        value='148',
        dist_name=MR_NR_CELL_NAME,
        p_name='prachConfigurationIndex'),
    dict(
        value='false',
        dist_name=MR_NR_CELL_NAME,
        p_name='actDlMuMimo'),
    dict(
        value='2x2 Open Loop Spatial Multiplexing',
        dist_name=MR_NR_CELL_NAME,
        p_name='dlMimoMode'),
    dict(
        value='true',
        dist_name=MR_NR_CELL_NAME,
        p_name='actDl256Qam'),
    dict(
        value='80MHz',
        dist_name=MR_NR_CELL_NAME,
        p_name='chBw'),
    dict(
        value='semiStatic',
        dist_name=MR_NR_CELL_NAME,
        p_name='frameStructureType'),
    dict(
        value='2Symbols',
        dist_name=MR_NR_CELL_NAME,
        p_name='guardPeriodLength'),
    dict(
        value='0ms',
        dist_name=MR_NR_CELL_NAME,
        p_name='lteToNrFrameShift'),
    dict(
        value='3/7',
        dist_name=MR_NR_CELL_NAME,
        p_name='ulDlDataSlotRatio'),
    dict(
        value='0sub-sector',
        dist_name=MR_NR_CELL_NAME,
        p_name='numOfSubSectors'),
    dict(
        value='beamSet_4',
        dist_name=MR_NR_CELL_NAME,
        p_name='basicBeamSet'),
    dict(
        value='4 beams',
        dist_name=MR_NR_CELL_GROUP_NAME,
        p_name='numberOfTransmittedSsBlocks'),
    dict(
        value='true',
        dist_name=MR_NR_CELL_NAME,
        p_name='actExternalAntennaBF'),
    dict(
        value='4DL4UL',
        dist_name=MR_NR_CELL_NAME,
        p_name='nrCellType'),
    dict(
        value='4Rx',
        dist_name=MR_NR_CELL_NAME,
        p_name='numberOfRxBeamforming'),
    dict(
        value='155',
        dist_name=MR_NR_CELL_NAME,
        p_name='reqMinNumPuschPrb'),
]

ultp_100MHz = 55
dltp_2DL_64QAM_100MHz = 530
dltp_2DL_256QAM_100MHz = 720
dltp_4DL_64QAM_100MHz = 1000
dltp_4DL_256QAM_100MHz = 1450
dldata_2DL_64QAM_100MHz = '560M'
dldata_2DL_256QAM_100MHz = '760M'
dldata_4DL_64QAM_100MHz = '1200M'
dldata_4DL_256QAM_100MHz = '1550M'
uldata_100MHz = '60M'
ultp_90MHz = 75
dltp_2DL_64QAM_90MHz = 455
dltp_2DL_256QAM_90MHz = 200
dltp_4DL_64QAM_90MHz = 200
dltp_4DL_256QAM_90MHz = 400
dldata_2DL_64QAM_90MHz = '500M'
dldata_2DL_256QAM_90MHz = '670'
dldata_4DL_64QAM_90MHz = '1100M'
dldata_4DL_256QAM_90MHz = '1400M'
uldata_90MHz = '80M'
ultp_70MHz = 30
dltp_2DL_64QAM_70MHz = 450
dltp_2DL_256QAM_70MHz = 540
dltp_4DL_64QAM_70MHz = 740
dltp_4DL_256QAM_70MHz = 975
dldata_2DL_64QAM_70MHz = '540M'
dldata_2DL_256QAM_70MHz = '560M'
dldata_4DL_64QAM_70MHz = '1200M'
dldata_4DL_256QAM_70MHz = '1400M'
uldata_70MHz = '60M'
ultp_50MHz = 21
dltp_2DL_64QAM_50MHz = 100
dltp_2DL_256QAM_50MHz = 200
dltp_4DL_64QAM_50MHz = 200
dltp_4DL_256QAM_50MHz = 620
dldata_2DL_64QAM_50MHz = '300M'
dldata_2DL_256QAM_50MHz = '450M'
dldata_4DL_64QAM_50MHz = '500M'
dldata_4DL_256QAM_50MHz = '700M'
uldata_50MHz = '50M'
uldata_20MHz = '20M'
ultp_20MHz = 8
dldata_20MHz = '300M'
dltp_20MHz = 220

uldata_40MHz = '30M'
ultp_40MHz = 25
dldata_40MHz = '600M'
dltp_40MHz = 500

uldata_60MHz = '60M'
ultp_60MHz = 50
dldata_60MHz = '800M'
dltp_60MHz = 660

uldata_80MHz = '50M'
ultp_80MHz = 35
dldata_80MHz = '1300M'
dltp_80MHz = 1000
ATTENUATION_VALUE_50M_01 = {
    'atten_value_of_port0': 20,
    'atten_value_of_port1': 20,
    'atten_value_of_port2': 20,
    'atten_value_of_port3': 20,
    'atten_value_of_port4': 20,
    'atten_value_of_port5': 20,
    'atten_value_of_port6': 20,
    'atten_value_of_port7': 20
}
ATTENUATION_VALUE_90M_01 = {
    'atten_value_of_port0': 20,
    'atten_value_of_port1': 20,
    'atten_value_of_port2': 20,
    'atten_value_of_port3': 20,
    'atten_value_of_port4': 20,
    'atten_value_of_port5': 20,
    'atten_value_of_port6': 20,
    'atten_value_of_port7': 20
}
ATTENUATION_VALUE_70M_01 = {
    'atten_value_of_port0': 20,
    'atten_value_of_port1': 20,
    'atten_value_of_port2': 20,
    'atten_value_of_port3': 20,
    'atten_value_of_port4': 127,
    'atten_value_of_port5': 127,
    'atten_value_of_port6': 127,
    'atten_value_of_port7': 127
}
RU_Stability = [
    dict(
        value='430',
        dist_name=MR_NR_CELL_NAME,
        p_name='pMax'),
    dict(
        value='100',
        dist_name=MR_NR_CELL_NAME,
        p_name='targetTotalLoad'),
]
