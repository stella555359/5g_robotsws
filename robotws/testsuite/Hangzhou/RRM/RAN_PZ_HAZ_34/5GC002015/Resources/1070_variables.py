import os
from robot.libraries.BuiltIn import BuiltIn
tl = BuiltIn().get_variable_value('${tl}')
CFG_DIR = os.path.dirname(os.path.abspath(__file__))

MR_NR_CELL_NAME = 'MRBTS-' + str(tl.gnbs[0].global_bts_id) + '/NRBTS-' + str(tl.gnbs[0].global_bts_id) + \
    '/NRCELL-' + str(tl.gnbs[0].instance_id)

MR_NR_CELLGRP_NAME = 'MRBTS-' + str(tl.gnbs[0].global_bts_id) + '/NRBTS-' + str(tl.gnbs[0].global_bts_id) + \
    '/NRCELLGRP-0'

MR_NR_NRSYSINFO_NAME = 'MRBTS-' + str(tl.gnbs[0].global_bts_id) + '/NRBTS-' + str(tl.gnbs[0].global_bts_id) + \
    '/NRSYSINFO_PROFILE-1'

# ------------ swconfig for CNI-46722 feature------------------
# When rdPdcchPrecodingOption4X4 value is '2' (single beam) [0..2]
# rdPdcchPrecodingOption4x4 (0/1/2)
# 0x5800dd=2
# rdPdschClPrecodingOption4x4, (0/1/2/4/5/6) UP_13675(rdPdschPrecodingOption4X4)
# 0x580137=2
# rdCSIRSprecoding4x4 (0/1)
# 0x580199=0
# ######PdschPrecodingOption4X4 in bip= (rdPdschPrecodingOption4X4 + 4 x rdCSIRSprecoding4X4 )
#
# ######rdPortSelectionPattenIdOff
# ######0x58017A=0
# L2PS DL rank, rank1 is 1, rank2 is 2 rank4=4
# 0x580017=2

SWCONFIG_RANK3 = [
    '0x580137=2',
    '0x580199=0',
    '0x5800dd=2',
    '0x580017=3'
]

SWCONFIG_RANK4 = [
    '0x580137=2',
    '0x580199=0',
    '0x5800dd=2',
    '0x580017=4'
]

PARAMS_1070_Z_34 = [
    dict(value='27', dist_name=MR_NR_CELL_NAME, p_name='dllaIniMcs'),
    dict(value='27', dist_name=MR_NR_CELL_NAME, p_name='ullaIniMcs'),
    dict(value='semiStatic', dist_name=MR_NR_CELL_NAME, p_name='frameStructureType'),
    dict(value='2Symbols', dist_name=MR_NR_CELL_NAME, p_name='guardPeriodLength'),
    dict(value='3/7', dist_name=MR_NR_CELL_NAME, p_name='ulDlDataSlotRatio'),
    dict(value='100MHz', dist_name=MR_NR_CELL_NAME, p_name='chBw'),
    dict(value='20', dist_name=MR_NR_CELLGRP_NAME, p_name='ssBurstSetPeriod'),
    dict(value='148', dist_name=MR_NR_CELL_NAME, p_name='prachConfigurationIndex')
]

PARAMS_1070_Z_35 = [
    dict(value='27', dist_name=MR_NR_CELL_NAME, p_name='dllaIniMcs'),
    dict(value='27', dist_name=MR_NR_CELL_NAME, p_name='ullaIniMcs'),
    dict(value='semiStatic', dist_name=MR_NR_CELL_NAME, p_name='frameStructureType'),
    dict(value='2Symbols', dist_name=MR_NR_CELL_NAME, p_name='guardPeriodLength'),
    dict(value='3/7', dist_name=MR_NR_CELL_NAME, p_name='ulDlDataSlotRatio'),
    dict(value='true', dist_name=MR_NR_CELL_NAME, p_name='actDl256Qam'),
    dict(value='100MHz', dist_name=MR_NR_CELL_NAME, p_name='chBw'),
    dict(value='20', dist_name=MR_NR_CELLGRP_NAME, p_name='ssBurstSetPeriod'),
    dict(value='148', dist_name=MR_NR_CELL_NAME, p_name='prachConfigurationIndex')
]

PARAMS_1070_Z_102 = [
    dict(value='27', dist_name=MR_NR_CELL_NAME, p_name='dllaIniMcs'),
    dict(value='27', dist_name=MR_NR_CELL_NAME, p_name='ullaIniMcs'),
    dict(value='semiStatic', dist_name=MR_NR_CELL_NAME, p_name='frameStructureType'),
    dict(value='2Symbols', dist_name=MR_NR_CELL_NAME, p_name='guardPeriodLength'),
    dict(value='3/7', dist_name=MR_NR_CELL_NAME, p_name='ulDlDataSlotRatio'),
    dict(value='100MHz', dist_name=MR_NR_CELL_NAME, p_name='chBw'),
    dict(value='20', dist_name=MR_NR_CELLGRP_NAME, p_name='ssBurstSetPeriod'),
    dict(value='148', dist_name=MR_NR_CELL_NAME, p_name='prachConfigurationIndex')
]

PARAMS_1070_Z_103 = [
    dict(value='27', dist_name=MR_NR_CELL_NAME, p_name='dllaIniMcs'),
    dict(value='27', dist_name=MR_NR_CELL_NAME, p_name='ullaIniMcs'),
    dict(value='semiStatic', dist_name=MR_NR_CELL_NAME, p_name='frameStructureType'),
    dict(value='2Symbols', dist_name=MR_NR_CELL_NAME, p_name='guardPeriodLength'),
    dict(value='3/7', dist_name=MR_NR_CELL_NAME, p_name='ulDlDataSlotRatio'),
    dict(value='100MHz', dist_name=MR_NR_CELL_NAME, p_name='chBw'),
    dict(value='20', dist_name=MR_NR_CELLGRP_NAME, p_name='ssBurstSetPeriod'),
    dict(value='148', dist_name=MR_NR_CELL_NAME, p_name='prachConfigurationIndex')
]

PARAMS_1070_Z_90 = [
    dict(value='27', dist_name=MR_NR_CELL_NAME, p_name='dllaIniMcs'),
    dict(value='27', dist_name=MR_NR_CELL_NAME, p_name='ullaIniMcs'),
    dict(value='semiStatic', dist_name=MR_NR_CELL_NAME, p_name='frameStructureType'),
    dict(value='2Symbols', dist_name=MR_NR_CELL_NAME, p_name='guardPeriodLength'),
    dict(value='beamSet_2', dist_name=MR_NR_CELL_NAME, p_name='basicBeamSet'),
    dict(value='4x4 or 4x2 Closed Loop Spatial Multiplexing', dist_name=MR_NR_CELL_NAME, p_name='dlMimoMode'),
    dict(value='0', dist_name=MR_NR_CELL_NAME, p_name='ssPbchBlockPower'),
    dict(value='slots320', dist_name=MR_NR_CELL_NAME, p_name='csiReportPeriodicity'),
    dict(value='4CCEs', dist_name=MR_NR_CELL_NAME, p_name='aggregationLevel'),
    dict(value='3/7', dist_name=MR_NR_CELL_NAME, p_name='ulDlDataSlotRatio'),
    dict(value='true', dist_name=MR_NR_CELL_NAME, p_name='actDl256Qam'),
    dict(value='100MHz', dist_name=MR_NR_CELL_NAME, p_name='chBw'),
    dict(value='20', dist_name=MR_NR_CELLGRP_NAME, p_name='ssBurstSetPeriod'),
    dict(value='4DL2UL', dist_name=MR_NR_CELL_NAME, p_name='nrCellType'),
    dict(value='379', dist_name=MR_NR_NRSYSINFO_NAME, p_name='systemInformationTargetRate'),
    dict(value='148', dist_name=MR_NR_CELL_NAME, p_name='prachConfigurationIndex')
]

PARAMS_1070_Z_91 = [
    dict(value='27', dist_name=MR_NR_CELL_NAME, p_name='dllaIniMcs'),
    dict(value='27', dist_name=MR_NR_CELL_NAME, p_name='ullaIniMcs'),
    dict(value='semiStatic', dist_name=MR_NR_CELL_NAME, p_name='frameStructureType'),
    dict(value='2Symbols', dist_name=MR_NR_CELL_NAME, p_name='guardPeriodLength'),
    dict(value='beamSet_2', dist_name=MR_NR_CELL_NAME, p_name='basicBeamSet'),
    dict(value='4x4 or 4x2 Closed Loop Spatial Multiplexing', dist_name=MR_NR_CELL_NAME, p_name='dlMimoMode'),
    dict(value='0', dist_name=MR_NR_CELL_NAME, p_name='ssPbchBlockPower'),
    dict(value='4CCEs', dist_name=MR_NR_CELL_NAME, p_name='aggregationLevel'),
    dict(value='3/7', dist_name=MR_NR_CELL_NAME, p_name='ulDlDataSlotRatio'),
    dict(value='true', dist_name=MR_NR_CELL_NAME, p_name='actDl256Qam'),
    dict(value='100MHz', dist_name=MR_NR_CELL_NAME, p_name='chBw'),
    dict(value='20', dist_name=MR_NR_CELLGRP_NAME, p_name='ssBurstSetPeriod'),
    dict(value='4DL2UL', dist_name=MR_NR_CELL_NAME, p_name='nrCellType'),
    dict(value='379', dist_name=MR_NR_NRSYSINFO_NAME, p_name='systemInformationTargetRate'),
    dict(value='148', dist_name=MR_NR_CELL_NAME, p_name='prachConfigurationIndex')
]

PARAMS_1070_case_1 = [
     dict(
         abbr='dllaIniMcs',
         dist_name=MR_NR_CELL_NAME,
         filter_param='Initial MCS for DL transmission',
         new_value='27'),
     dict(
         abbr='ullaIniMcs',
         dist_name=MR_NR_CELL_NAME,
         filter_param='Initial MCS for UL Transmission',
         new_value='27'),
     dict(
         abbr='dlMimoMode',
         dist_name=MR_NR_CELL_NAME,
         filter_param='Downlink MIMO Mode',
         new_value='4x4 or 4x2 Closed Loop Spatial Multiplexing'),
     dict(
         abbr='actDl256Qam',
         dist_name=MR_NR_CELL_NAME,
         filter_param='Activate 256QAM in DL',
         new_value='true'),
     dict(
         abbr='chBw',
         dist_name=MR_NR_CELL_NAME,
         filter_param='Channel bandwidth',
         new_value='100MHz'),
     dict(
         abbr='systemInformationTargetRate',
         dist_name=MR_NR_NRSYSINFO_NAME,
         filter_param='System Information target rate',
         new_value='379')
]

PARAMS_1070_case_2 = [
     dict(
         abbr='dllaIniMcs',
         dist_name=MR_NR_CELL_NAME,
         filter_param='Initial MCS for DL transmission',
         new_value='27'),
     dict(
         abbr='ullaIniMcs',
         dist_name=MR_NR_CELL_NAME,
         filter_param='Initial MCS for UL Transmission',
         new_value='27'),
     dict(
         abbr='dlMimoMode',
         dist_name=MR_NR_CELL_NAME,
         filter_param='Downlink MIMO Mode',
         new_value='4x4 or 4x2 Closed Loop Spatial Multiplexing'),
     dict(
         abbr='actDl256Qam',
         dist_name=MR_NR_CELL_NAME,
         filter_param='Activate 256QAM in DL',
         new_value='false'),
     dict(
         abbr='chBw',
         dist_name=MR_NR_CELL_NAME,
         filter_param='Channel bandwidth',
         new_value='100MHz'),
     dict(
         abbr='systemInformationTargetRate',
         dist_name=MR_NR_NRSYSINFO_NAME,
         filter_param='System Information target rate',
         new_value='379')
]

PARAMS_1070_case_3 = [
     dict(
         abbr='dllaIniMcs',
         dist_name=MR_NR_CELL_NAME,
         filter_param='Initial MCS for DL transmission',
         new_value='27'),
     dict(
         abbr='ullaIniMcs',
         dist_name=MR_NR_CELL_NAME,
         filter_param='Initial MCS for UL Transmission',
         new_value='27'),
     dict(
         abbr='dlMimoMode',
         dist_name=MR_NR_CELL_NAME,
         filter_param='Downlink MIMO Mode',
         new_value='2x2 Closed Loop Spatial Multiplexing'),
     dict(
         abbr='actDl256Qam',
         dist_name=MR_NR_CELL_NAME,
         filter_param='Activate 256QAM in DL',
         new_value='true'),
     dict(
         abbr='chBw',
         dist_name=MR_NR_CELL_NAME,
         filter_param='Channel bandwidth',
         new_value='100MHz'),
     dict(
         abbr='systemInformationTargetRate',
         dist_name=MR_NR_NRSYSINFO_NAME,
         filter_param='System Information target rate',
         new_value='379')
]

PARAMS_1070_case_4 = [
     dict(
         abbr='dllaIniMcs',
         dist_name=MR_NR_CELL_NAME,
         filter_param='Initial MCS for DL transmission',
         new_value='27'),
     dict(
         abbr='ullaIniMcs',
         dist_name=MR_NR_CELL_NAME,
         filter_param='Initial MCS for UL Transmission',
         new_value='27'),
     dict(
         abbr='dlMimoMode',
         dist_name=MR_NR_CELL_NAME,
         filter_param='Downlink MIMO Mode',
         new_value='4x4 or 4x2 Closed Loop Spatial Multiplexing'),
     dict(
         abbr='actDl256Qam',
         dist_name=MR_NR_CELL_NAME,
         filter_param='Activate 256QAM in DL',
         new_value='true'),
     dict(
         abbr='chBw',
         dist_name=MR_NR_CELL_NAME,
         filter_param='Channel bandwidth',
         new_value='80MHz'),
     dict(
         abbr='systemInformationTargetRate',
         dist_name=MR_NR_NRSYSINFO_NAME,
         filter_param='System Information target rate',
         new_value='379')
]

PARAMS_1070_case_5 = [
     dict(
         abbr='dllaIniMcs',
         dist_name=MR_NR_CELL_NAME,
         filter_param='Initial MCS for DL transmission',
         new_value='27'),
     dict(
         abbr='ullaIniMcs',
         dist_name=MR_NR_CELL_NAME,
         filter_param='Initial MCS for UL Transmission',
         new_value='27'),
     dict(
         abbr='dlMimoMode',
         dist_name=MR_NR_CELL_NAME,
         filter_param='Downlink MIMO Mode',
         new_value='4x4 or 4x2 Closed Loop Spatial Multiplexing'),
     dict(
         abbr='actDl256Qam',
         dist_name=MR_NR_CELL_NAME,
         filter_param='Activate 256QAM in DL',
         new_value='true'),
     dict(
         abbr='chBw',
         dist_name=MR_NR_CELL_NAME,
         filter_param='Channel bandwidth',
         new_value='60MHz'),
     dict(
         abbr='systemInformationTargetRate',
         dist_name=MR_NR_NRSYSINFO_NAME,
         filter_param='System Information target rate',
         new_value='379')
]
