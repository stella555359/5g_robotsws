import os
from robot.libraries.BuiltIn import BuiltIn
tl = BuiltIn().get_variable_value('${tl}')
CFG_DIR = os.path.dirname(os.path.abspath(__file__))

MR_NR_CELL_NAME = 'MRBTS-' + str(tl.gnbs[0].global_bts_id) + '/NRBTS-' + str(tl.gnbs[0].global_bts_id) + \
    '/NRCELL-' + str(tl.gnbs[0].instance_id)

MR_NR_CELLGRP_NAME = 'MRBTS-' + str(tl.gnbs[0].global_bts_id) + '/NRBTS-' + str(tl.gnbs[0].global_bts_id) + \
    '/NRCELLGRP-0'

CHANNEL5 = 'MRBTS-' + str(tl.gnbs[0].global_bts_id)+'/MNL-1/MNLENT-1/CELLMAPPING-1/LCELNR-1/CHANNELGROUP-1/CHANNEL-5'

CHANNEL6 = 'MRBTS-' + str(tl.gnbs[0].global_bts_id)+'/MNL-1/MNLENT-1/CELLMAPPING-1/LCELNR-1/CHANNELGROUP-1/CHANNEL-6'

PHYANT = 'MRBTS-' + str(tl.gnbs[0].global_bts_id)+'/EQM-1/APEQM-1/RMOD-1/PHYANT-1'

PARAMS_1983_ELEMENTS = dict(frameStructureType='tdLte', guardPeriodLength='6Symbols',
                            lteToNrFrameShift='3ms', tdLteUlDlConfig='tdLteConfig2', ulDlDataSlotRatio='3/7')

PARAMS_1983_REMOVE_LIST = [
    dict(dist_name=MR_NR_CELL_NAME, list_name='tddFrameStructure')
]

PARAMS_1983_ADD_LIST = [
    dict(dist_name=MR_NR_CELL_NAME, list_name='tddFrameStructure')
]

PARAMS_1983_ADD_ITEM = [
    dict(dist_name=MR_NR_CELL_NAME, list_name='tddFrameStructure', elements=PARAMS_1983_ELEMENTS)
]

PARAMS_1983_SA_01 = [
    dict(value='tdLte', dist_name=MR_NR_CELL_NAME, p_name='frameStructureType'),
    dict(value='6Symbols', dist_name=MR_NR_CELL_NAME, p_name='guardPeriodLength'),
    dict(value='3ms', dist_name=MR_NR_CELL_NAME, p_name='lteToNrFrameShift'),
    dict(value='tdLteConfig2', dist_name=MR_NR_CELL_NAME, p_name='tdLteUlDlConfig'),
    dict(value='3/7', dist_name=MR_NR_CELL_NAME, p_name='ulDlDataSlotRatio'),
    dict(value='20', dist_name=MR_NR_CELLGRP_NAME, p_name='ssBurstSetPeriod'),
    dict(value='148', dist_name=MR_NR_CELL_NAME, p_name='prachConfigurationIndex')
]

PARAMS_1983_SA_02 = [
    dict(value='tdLte', dist_name=MR_NR_CELL_NAME, p_name='frameStructureType'),
    dict(value='6Symbols', dist_name=MR_NR_CELL_NAME, p_name='guardPeriodLength'),
    dict(value='3ms', dist_name=MR_NR_CELL_NAME, p_name='lteToNrFrameShift'),
    dict(value='tdLteConfig2', dist_name=MR_NR_CELL_NAME, p_name='tdLteUlDlConfig'),
    dict(value='3/7', dist_name=MR_NR_CELL_NAME, p_name='ulDlDataSlotRatio'),
    dict(value='20', dist_name=MR_NR_CELLGRP_NAME, p_name='ssBurstSetPeriod'),
    dict(value='148', dist_name=MR_NR_CELL_NAME, p_name='prachConfigurationIndex')
]

PARAMS_1983_SA_03 = [
    dict(value='tdLte', dist_name=MR_NR_CELL_NAME, p_name='frameStructureType'),
    dict(value='6Symbols', dist_name=MR_NR_CELL_NAME, p_name='guardPeriodLength'),
    dict(value='3ms', dist_name=MR_NR_CELL_NAME, p_name='lteToNrFrameShift'),
    dict(value='tdLteConfig2', dist_name=MR_NR_CELL_NAME, p_name='tdLteUlDlConfig'),
    dict(value='3/7', dist_name=MR_NR_CELL_NAME, p_name='ulDlDataSlotRatio'),
    dict(value='20', dist_name=MR_NR_CELLGRP_NAME, p_name='ssBurstSetPeriod'),
    dict(value='148', dist_name=MR_NR_CELL_NAME, p_name='prachConfigurationIndex')
]

PARAMS_1983_SA_04 = [
    dict(value='tdLte', dist_name=MR_NR_CELL_NAME, p_name='frameStructureType'),
    dict(value='6Symbols', dist_name=MR_NR_CELL_NAME, p_name='guardPeriodLength'),
    dict(value='3ms', dist_name=MR_NR_CELL_NAME, p_name='lteToNrFrameShift'),
    dict(value='tdLteConfig2', dist_name=MR_NR_CELL_NAME, p_name='tdLteUlDlConfig'),
    dict(value='3/7', dist_name=MR_NR_CELL_NAME, p_name='ulDlDataSlotRatio'),
    dict(value='20', dist_name=MR_NR_CELLGRP_NAME, p_name='ssBurstSetPeriod'),
    dict(value='148', dist_name=MR_NR_CELL_NAME, p_name='prachConfigurationIndex')
]

PARAMS_1983_SA_05_CHANL = [
    dict(class_name='com.nokia.srbts.mnl:CHANNEL', dist_name=CHANNEL5, version='MNL5GC19B_1911_003'),
    dict(class_name='com.nokia.srbts.mnl:CHANNEL', dist_name=CHANNEL6, version='MNL5GC19B_1911_003')
]

PARAMS_1983_SA_05_ELEMENT = [
    dict(value='TX', dist_name=CHANNEL5, p_name='direction'),
    dict(value=PHYANT, dist_name=CHANNEL5, p_name='resourceDN'),
    dict(value='TX', dist_name=CHANNEL6, p_name='direction'),
    dict(value=PHYANT, dist_name=CHANNEL6, p_name='resourceDN')
]

PARAMS_1983_SA_05 = [
    dict(value='tdLte', dist_name=MR_NR_CELL_NAME, p_name='frameStructureType'),
    dict(value='6Symbols', dist_name=MR_NR_CELL_NAME, p_name='guardPeriodLength'),
    dict(value='3ms', dist_name=MR_NR_CELL_NAME, p_name='lteToNrFrameShift'),
    dict(value='tdLteConfig2', dist_name=MR_NR_CELL_NAME, p_name='tdLteUlDlConfig'),
    dict(value='3/7', dist_name=MR_NR_CELL_NAME, p_name='ulDlDataSlotRatio'),
    dict(value='4x4 or 4x2 Open Loop Spatial Multiplexing', dist_name=MR_NR_CELL_NAME, p_name='dlMimoMode'),
    dict(value='true', dist_name=MR_NR_CELL_NAME, p_name='actBeamforming'),
    dict(value='beamSet_2', dist_name=MR_NR_CELL_NAME, p_name='basicBeamSet'),
    dict(value='4DL2UL', dist_name=MR_NR_CELL_NAME, p_name='nrCellType'),
    dict(value='2 beams', dist_name=MR_NR_CELLGRP_NAME, p_name='numberOfTransmittedSsBlocks'),
    dict(value='20', dist_name=MR_NR_CELLGRP_NAME, p_name='ssBurstSetPeriod'),
    dict(value='148', dist_name=MR_NR_CELL_NAME, p_name='prachConfigurationIndex')
]

PARAMS_1983_SA_06 = [
    dict(value='tdLte', dist_name=MR_NR_CELL_NAME, p_name='frameStructureType'),
    dict(value='6Symbols', dist_name=MR_NR_CELL_NAME, p_name='guardPeriodLength'),
    dict(value='3ms', dist_name=MR_NR_CELL_NAME, p_name='lteToNrFrameShift'),
    dict(value='tdLteConfig2', dist_name=MR_NR_CELL_NAME, p_name='tdLteUlDlConfig'),
    dict(value='3/7', dist_name=MR_NR_CELL_NAME, p_name='ulDlDataSlotRatio'),
    dict(value='-81', dist_name=MR_NR_CELL_NAME, p_name='p0NominalSrs'),
    dict(value='20', dist_name=MR_NR_CELLGRP_NAME, p_name='ssBurstSetPeriod'),
    dict(value='148', dist_name=MR_NR_CELL_NAME, p_name='prachConfigurationIndex')
]

PARAMS_1983_SA_07 = [
    dict(value='tdLte', dist_name=MR_NR_CELL_NAME, p_name='frameStructureType'),
    dict(value='6Symbols', dist_name=MR_NR_CELL_NAME, p_name='guardPeriodLength'),
    dict(value='3ms', dist_name=MR_NR_CELL_NAME, p_name='lteToNrFrameShift'),
    dict(value='tdLteConfig2', dist_name=MR_NR_CELL_NAME, p_name='tdLteUlDlConfig'),
    dict(value='3/7', dist_name=MR_NR_CELL_NAME, p_name='ulDlDataSlotRatio'),
    dict(value='alpha0', dist_name=MR_NR_CELL_NAME, p_name='alphaSrs'),
    dict(value='20', dist_name=MR_NR_CELLGRP_NAME, p_name='ssBurstSetPeriod'),
    dict(value='148', dist_name=MR_NR_CELL_NAME, p_name='prachConfigurationIndex')
]

PARAMS_1983_SA_08 = [
    dict(value='tdLte', dist_name=MR_NR_CELL_NAME, p_name='frameStructureType'),
    dict(value='6Symbols', dist_name=MR_NR_CELL_NAME, p_name='guardPeriodLength'),
    dict(value='3ms', dist_name=MR_NR_CELL_NAME, p_name='lteToNrFrameShift'),
    dict(value='tdLteConfig2', dist_name=MR_NR_CELL_NAME, p_name='tdLteUlDlConfig'),
    dict(value='3/7', dist_name=MR_NR_CELL_NAME, p_name='ulDlDataSlotRatio'),
    dict(value='false', dist_name=MR_NR_CELL_NAME, p_name='actUlOpenLoopPwrCtrl'),
    dict(value='20', dist_name=MR_NR_CELLGRP_NAME, p_name='ssBurstSetPeriod'),
    dict(value='148', dist_name=MR_NR_CELL_NAME, p_name='prachConfigurationIndex')
]
