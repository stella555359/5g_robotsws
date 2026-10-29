from robot.libraries.BuiltIn import BuiltIn
import logging

# testsuite.Hangzhou.resources.RAN_PZ_HAZ_34.robot/gnb_classical_hangzhou.robot')
# program = BuiltIn().run_keyword('Get program version based on stream version')
tl = BuiltIn().get_variable_value('${tl}')
# program = BuiltIn().get_variable_value('${PROGRAM}')

NR_CU = 'NRBTS-' + str(tl.gnbs[0].cu.global_bts_id)
NR_CU_CELL_1 = NR_CU + '/NRCELL-2'
NR_CU_CELL_2 = NR_CU + '/NRCELL-3'

NR_DU_1 = 'NRBTS-' + str(tl.gnbs[0].dus[0].global_bts_id)
NR_DU_2 = 'NRBTS-' + str(tl.gnbs[0].dus[1].global_bts_id)
NR_DU_CELL_1 = NR_DU_1 + '/NRCELL-2'
NR_DU_CELL_2 = NR_DU_2 + '/NRCELL-3'

LTE_NAME = 'MRBTS-' + str(tl.enbs[0].instance_id) + '/LNBTS-' + str(tl.enbs[0].global_bts_id)
LTE_CELL_NAME = LTE_NAME + '/LNCEL-1'

# Notice: nidd parameter name is case sensitive
SCF_CU_COMMON = [
    dict(dist_name=NR_CU, p_name='actInterFreqIntraGnbMobilityNSA', value='true'),
    dict(dist_name=NR_CU, list_name='cipherPrefL', p_name='nea0', value='9'),
    dict(dist_name=NR_CU, list_name='cipherPrefL', p_name='nea1_128', value='0'),
    dict(dist_name=NR_CU, list_name='cipherPrefL', p_name='nea2_128', value='0'),
    dict(dist_name=NR_CU, list_name='cipherPrefL', p_name='nea3_128', value='0'),
]

# # CU config for source cell
SCF_CU_SRC_CELL_COMMON = [dict(dist_name=NR_CU_CELL_1, p_name='sMeasConfigSsbRsrp', value='80')]

SCF_CU_SRC_CELL_NEIGH_CELL = [
    dict(dist_name=NR_CU_CELL_1 + '/NRREL-0', p_name='lcrId', value='3'),
    dict(dist_name=NR_CU_CELL_1 + '/NRREL-0', p_name='gNbId', value=str(tl.gnbs[0].global_bts_id)),
    dict(dist_name=NR_CU_CELL_1 + '/NRREL-0', p_name='cellIndividualSsbRsrpOffset', value='0dB'),
    dict(dist_name=NR_CU_CELL_1 + '/NRREL-0', p_name='cellIndividualSsbRsrqOffset', value='0dB'),
    dict(dist_name=NR_CU_CELL_1 + '/NRREL-0', list_name='gnbPlmn', p_name='mcc', value='262'),
    dict(dist_name=NR_CU_CELL_1 + '/NRREL-0', list_name='gnbPlmn', p_name='mnc', value='3'),
    dict(dist_name=NR_CU_CELL_1 + '/NRREL-0', list_name='gnbPlmn', p_name='mncLength', value='2'),
]

SCF_CU_SRC_CELL_NEIGH_CELL_ADD_20B = [
    dict(dist_name=NR_CU_CELL_1 + '/NRREL-0', p_name='nrarfcn', value='2232259'),
    dict(dist_name=NR_CU_CELL_1 + '/NRREL-0', p_name='physCellId', value='415'),
    dict(dist_name=NR_CU_CELL_1 + '/NRREL-0', p_name='cellDepType', value='NSA'),
]

SCF_CU_SRC_CELL_A1_MEAS_CONFIG = [
    dict(dist_name=NR_CU_CELL_1, p_name='a1MeashoEnabled', value='rsrp'),
    dict(dist_name=NR_CU_CELL_1, list_name='a1MeashoSsbRsrp', p_name='a1HysteresishoSsbRsrp', value='0'),
    dict(dist_name=NR_CU_CELL_1, list_name='a1MeashoSsbRsrp', p_name='a1ThresholdhoSsbRsrp', value='100'),
    dict(dist_name=NR_CU_CELL_1, list_name='a1MeashoSsbRsrp', p_name='a1TimeToTriggerhoSsbRsrp', value='ms480'),
    dict(dist_name=NR_CU_CELL_1, list_name='a1MeashoSsbRsrq', p_name='a1HysteresishoSsbRsrq', value='0'),
    dict(dist_name=NR_CU_CELL_1, list_name='a1MeashoSsbRsrq', p_name='a1ThresholdhoSsbRsrq', value='31'),
    dict(dist_name=NR_CU_CELL_1, list_name='a1MeashoSsbRsrq', p_name='a1TimeToTriggerhoSsbRsrq', value='ms480')
]

SCF_CU_SRC_CELL_A2_MEAS_CONFIG = [
    dict(dist_name=NR_CU_CELL_1, p_name='a2MeashoEnabled', value='rsrp'),
    dict(dist_name=NR_CU_CELL_1, list_name='a2MeashoSsbRsrp', p_name='a2HysteresishoSsbRsrp', value='0'),
    dict(dist_name=NR_CU_CELL_1, list_name='a2MeashoSsbRsrp', p_name='a2ThresholdhoSsbRsrp', value='90'),
    dict(dist_name=NR_CU_CELL_1, list_name='a2MeashoSsbRsrp', p_name='a2TimeToTriggerhoSsbRsrp', value='ms480'),
    dict(dist_name=NR_CU_CELL_1, list_name='a2MeashoSsbRsrq', p_name='a2HysteresishoSsbRsrq', value='0'),
    dict(dist_name=NR_CU_CELL_1, list_name='a2MeashoSsbRsrq', p_name='a2ThresholdhoSsbRsrq', value='31'),
    dict(dist_name=NR_CU_CELL_1, list_name='a2MeashoSsbRsrq', p_name='a2TimeToTriggerhoSsbRsrq', value='ms480')
]

SCF_CU_SRC_CELL_HOIF_MEAS_CONFIG = [
    dict(dist_name=NR_CU_CELL_1 + '/NRHOIF-1', p_name='a3MeasEnabled', value='rsrp'),
    dict(dist_name=NR_CU_CELL_1 + '/NRHOIF-1', list_name='a3MeasSsbRsrp', p_name='a3HysteresisSsbRsrp', value='0'),
    dict(dist_name=NR_CU_CELL_1 + '/NRHOIF-1', list_name='a3MeasSsbRsrp', p_name='a3OffsetSsbRsrp', value='10'),
    dict(dist_name=NR_CU_CELL_1 + '/NRHOIF-1', list_name='a3MeasSsbRsrp', p_name='a3TimeToTriggerSsbRsrp',
         value='ms0'),
    dict(dist_name=NR_CU_CELL_1 + '/NRHOIF-1', p_name='a5MeasEnabled', value='rsrp'),
    dict(dist_name=NR_CU_CELL_1 + '/NRHOIF-1', p_name='cellDepType', value='NSA'),
    dict(dist_name=NR_CU_CELL_1 + '/NRHOIF-1', p_name='freqBandIndicatorNR', value='260'),
    dict(dist_name=NR_CU_CELL_1 + '/NRHOIF-1', p_name='ifhoSsbScs', value='240 KHz'),
    dict(dist_name=NR_CU_CELL_1 + '/NRHOIF-1', p_name='ifhoSsbSmtcDuration', value='sf1'),
    dict(dist_name=NR_CU_CELL_1 + '/NRHOIF-1', p_name='ifhoSsbSmtcPeriodicity', value='sf5'),
    dict(dist_name=NR_CU_CELL_1 + '/NRHOIF-1', p_name='scs', value='120 KHz'),
    dict(dist_name=NR_CU_CELL_1 + '/NRHOIF-1', p_name='ssbFrequency', value='2232091')
]

# # CU config for target cell
SCF_CU_TGT_CELL_COMMON = [dict(dist_name=NR_CU_CELL_2, p_name='sMeasConfigSsbRsrp', value='80')]

SCF_CU_TGT_CELL_NEIGH_CELL = [
    dict(dist_name=NR_CU_CELL_2 + '/NRREL-0', p_name='lcrId', value='2'),
    dict(dist_name=NR_CU_CELL_2 + '/NRREL-0', p_name='gNbId', value=str(tl.gnbs[0].global_bts_id)),
    dict(dist_name=NR_CU_CELL_2 + '/NRREL-0', p_name='cellIndividualSsbRsrpOffset', value='0dB'),
    dict(dist_name=NR_CU_CELL_2 + '/NRREL-0', p_name='cellIndividualSsbRsrqOffset', value='0dB'),
    dict(dist_name=NR_CU_CELL_2 + '/NRREL-0', list_name='gnbPlmn', p_name='mcc', value='262'),
    dict(dist_name=NR_CU_CELL_2 + '/NRREL-0', list_name='gnbPlmn', p_name='mnc', value='3'),
    dict(dist_name=NR_CU_CELL_2 + '/NRREL-0', list_name='gnbPlmn', p_name='mncLength', value='2'),
]

SCF_CU_TGT_CELL_NEIGH_CELL_ADD_20B = [
    dict(dist_name=NR_CU_CELL_2 + '/NRREL-0', p_name='nrarfcn', value='2232535'),
    dict(dist_name=NR_CU_CELL_2 + '/NRREL-0', p_name='physCellId', value='416'),
    dict(dist_name=NR_CU_CELL_2 + '/NRREL-0', p_name='cellDepType', value='NSA'),
]

SCF_CU_TGT_CELL_A1_MEAS_CONFIG = [
    dict(dist_name=NR_CU_CELL_2, p_name='a1MeashoEnabled', value='rsrp'),
    dict(dist_name=NR_CU_CELL_2, list_name='a1MeashoSsbRsrp', p_name='a1HysteresishoSsbRsrp', value='0'),
    dict(dist_name=NR_CU_CELL_2, list_name='a1MeashoSsbRsrp', p_name='a1ThresholdhoSsbRsrp', value='60'),
    dict(dist_name=NR_CU_CELL_2, list_name='a1MeashoSsbRsrp', p_name='a1TimeToTriggerhoSsbRsrp', value='ms480')
]

SCF_CU_TGT_CELL_A2_MEAS_CONFIG = [
    dict(dist_name=NR_CU_CELL_2, p_name='a2MeashoEnabled', value='rsrp'),
    dict(dist_name=NR_CU_CELL_2, list_name='a2MeashoSsbRsrp', p_name='a2HysteresishoSsbRsrp', value='0'),
    dict(dist_name=NR_CU_CELL_2, list_name='a2MeashoSsbRsrp', p_name='a2ThresholdhoSsbRsrp', value='34'),
    dict(dist_name=NR_CU_CELL_2, list_name='a2MeashoSsbRsrp', p_name='a2TimeToTriggerhoSsbRsrp', value='ms480')
]

SCF_CU_TGT_CELL_HOIF_MEAS_CONFIG = [
    dict(dist_name=NR_CU_CELL_2 + '/NRHOIF-1', p_name='a3MeasEnabled', value='rsrp'),
    dict(dist_name=NR_CU_CELL_2 + '/NRHOIF-1', list_name='a3MeasSsbRsrp', p_name='a3HysteresisSsbRsrp', value='0'),
    dict(dist_name=NR_CU_CELL_2 + '/NRHOIF-1', list_name='a3MeasSsbRsrp', p_name='a3OffsetSsbRsrp', value='5'),
    dict(dist_name=NR_CU_CELL_2 + '/NRHOIF-1', list_name='a3MeasSsbRsrp', p_name='a3TimeToTriggerSsbRsrp',
         value='ms0'),
    dict(dist_name=NR_CU_CELL_2 + '/NRHOIF-1', p_name='a5MeasEnabled', value='rsrp'),
    dict(dist_name=NR_CU_CELL_2 + '/NRHOIF-1', p_name='cellDepType', value='NSA'),
    dict(dist_name=NR_CU_CELL_2 + '/NRHOIF-1', p_name='freqBandIndicatorNR', value='260'),
    dict(dist_name=NR_CU_CELL_2 + '/NRHOIF-1', p_name='ifhoSsbScs', value='240 KHz'),
    dict(dist_name=NR_CU_CELL_2 + '/NRHOIF-1', p_name='ifhoSsbSmtcDuration', value='sf1'),
    dict(dist_name=NR_CU_CELL_2 + '/NRHOIF-1', p_name='ifhoSsbSmtcPeriodicity', value='sf5'),
    dict(dist_name=NR_CU_CELL_2 + '/NRHOIF-1', p_name='scs', value='120 KHz'),
    dict(dist_name=NR_CU_CELL_2 + '/NRHOIF-1', p_name='ssbFrequency', value='2232667')
]

MODIFY_SCF_CU = SCF_CU_COMMON + SCF_CU_SRC_CELL_COMMON + SCF_CU_SRC_CELL_NEIGH_CELL + SCF_CU_SRC_CELL_A1_MEAS_CONFIG \
                + SCF_CU_SRC_CELL_A2_MEAS_CONFIG + SCF_CU_SRC_CELL_HOIF_MEAS_CONFIG + SCF_CU_TGT_CELL_COMMON + \
                SCF_CU_TGT_CELL_NEIGH_CELL + SCF_CU_TGT_CELL_A1_MEAS_CONFIG + SCF_CU_TGT_CELL_A2_MEAS_CONFIG + \
                SCF_CU_TGT_CELL_HOIF_MEAS_CONFIG

# SCF_SRC_DU_COMMON = [dict(dist_name=NR_DU_1 + '/NRREL-0')]
# SCF_TGT_DU_COMMON = [dict(dist_name=NR_DU_2 + '/NRREL-0')]

SCF_DU_SRC_CELL_HOIF = [
    dict(dist_name=NR_DU_CELL_1 + '/NRHOIF-1', p_name='numberOfTransmittedSsBlocks', value='32 beams'),
    dict(dist_name=NR_DU_CELL_1 + '/NRHOIF-1', p_name='ssBurstSetPeriod', value='20'),
    dict(dist_name=NR_DU_CELL_1 + '/NRHOIF-1', p_name='ssbFrequency', value='2232091'),
]

SCF_DU_SRC_CELL_MEAS_GAP = [
    dict(dist_name=NR_DU_CELL_1, p_name='mgta', value='ms0'),
    dict(dist_name=NR_DU_CELL_1, p_name='gapOffset', value='0'),
    dict(dist_name=NR_DU_CELL_1, p_name='measGapSelection', value='balancedChoice')
]

SCF_DU_TGT_CELL_HOIF = [
    dict(dist_name=NR_DU_CELL_2 + '/NRHOIF-1', p_name='numberOfTransmittedSsBlocks', value='32 beams'),
    dict(dist_name=NR_DU_CELL_2 + '/NRHOIF-1', p_name='ssBurstSetPeriod', value='20'),
    dict(dist_name=NR_DU_CELL_2 + '/NRHOIF-1', p_name='ssbFrequency', value='2232667'),
]

SCF_DU_TGT_CELL_MEAS_GAP = [
    dict(dist_name=NR_DU_CELL_2, p_name='mgta', value='ms0'),
    dict(dist_name=NR_DU_CELL_2, p_name='gapOffset', value='0'),
    dict(dist_name=NR_DU_CELL_2, p_name='measGapSelection', value='balancedChoice')
]

MODIFY_SCF_DU_SRC = SCF_DU_SRC_CELL_HOIF + SCF_DU_SRC_CELL_MEAS_GAP

MODIFY_SCF_DU_TGT = SCF_DU_TGT_CELL_HOIF + SCF_DU_TGT_CELL_MEAS_GAP


# # Part2: online modify via rest api
ENB_DEFAULT_NR_CELL = [dict(dist_name=LTE_CELL_NAME, parameter='defaultLnRelGnbCellId', value='1')]

# # Part 3: handling of different parameters on different branch
# logging.warning("************************* Current program is {} *************************".format(program))
# if program == '20B':
#     MODIFY_SCF_CU = MODIFY_SCF_CU + SCF_CU_SRC_CELL_NEIGH_CELL_ADD_20B + SCF_CU_TGT_CELL_NEIGH_CELL_ADD_20B
# elif program == 'master':
#     pass
# else:
#     raise Exception("Invalid input for program.")
