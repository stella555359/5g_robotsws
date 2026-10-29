import os
from robot.libraries.BuiltIn import BuiltIn

tl = BuiltIn().get_variable_value('${tl}')
CFG_DIR = os.path.dirname(os.path.abspath(__file__))

MR_NR_CELL_NAME = 'MRBTS-' + str(tl.gnbs[0].instance_id) + '/NRBTS-' + str(tl.gnbs[0].global_bts_id) + \
    '/NRCELL-' + str(tl.gnbs[0].global_bts_id)
MR_NR_BTS_NAME = 'MRBTS-' + str(tl.gnbs[0].instance_id) + '/NRBTS-' + str(tl.gnbs[0].global_bts_id)
testline_name = str(tl.gnbs[0].instance_id)
NR_CELL_GPR_NAME = 'MRBTS-' + str(tl.gnbs[0].instance_id) + '/NRBTS-' + str(tl.gnbs[0].global_bts_id) + \
    '/NRCELLGRP-0'
MR_NR_CELL2_NAME = 'MRBTS-' + str(tl.gnbs[0].instance_id) + '/NRBTS-' + str(tl.gnbs[0].global_bts_id) + \
    '/NRCELL-2'
MR_NR_CELL3_NAME = 'MRBTS-' + str(tl.gnbs[0].instance_id) + '/NRBTS-' + str(tl.gnbs[0].global_bts_id) + \
    '/NRCELL-3'
MR_NR_CELL4_NAME = 'MRBTS-' + str(tl.gnbs[0].instance_id) + '/NRBTS-' + str(tl.gnbs[0].global_bts_id) + \
    '/NRCELL-4'

PARAMS_TO_MODIFY_100MHz = [
    dict(value='100MHz', dist_name=MR_NR_CELL_NAME, p_name='chBw'),
    dict(value='277', dist_name=MR_NR_CELL_NAME, p_name='frequencyDensityThresNrb1'),
]

PARAMS_TO_MODIFY_actProactUlScheduling_true = [
    dict(value='true', dist_name=NR_CELL_GPR_NAME, p_name='actProactUlScheduling'),
]

PARAMS_TO_MODIFY_actProactUlScheduling_false = [
    dict(value='false', dist_name=NR_CELL_GPR_NAME, p_name='actProactUlScheduling'),
]

PARAMS_TO_MODIFY_csiReportPeriodicity_80 = [
    dict(value='false', dist_name=NR_CELL_GPR_NAME, p_name='actProactUlScheduling'),
    dict(value='43', dist_name=MR_NR_CELL_NAME, p_name='prachConfigurationIndex'),
    dict(value='43', dist_name=MR_NR_CELL2_NAME, p_name='prachConfigurationIndex'),
    dict(value='43', dist_name=MR_NR_CELL3_NAME, p_name='prachConfigurationIndex'),
    dict(value='43', dist_name=MR_NR_CELL4_NAME, p_name='prachConfigurationIndex'),
    dict(value='slots80', dist_name=NR_CELL_GPR_NAME, p_name='csiReportPeriodicity'),
    dict(value='1/4', dist_name=MR_NR_CELL_NAME, p_name='ulDlDataSlotRatio'),
    dict(value='true', dist_name=MR_NR_BTS_NAME, p_name='actEnhancedLinkAdaptation'),
]

PARAMS_TO_MODIFY_csiReportPeriodicity_320 = [
    dict(value='100MHz', dist_name=MR_NR_CELL_NAME, p_name='chBw'),
    dict(value='277', dist_name=MR_NR_CELL_NAME, p_name='frequencyDensityThresNrb1'),
    dict(value='slots320', dist_name=MR_NR_CELL_NAME, p_name='csiReportPeriodicity'),
    dict(value='slots320', dist_name=MR_NR_CELL2_NAME, p_name='csiReportPeriodicity'),
    dict(value='slots320', dist_name=MR_NR_CELL3_NAME, p_name='csiReportPeriodicity'),
    dict(value='slots320', dist_name=MR_NR_CELL4_NAME, p_name='csiReportPeriodicity'),
    dict(value='false', dist_name=MR_NR_BTS_NAME, p_name='actCarrierAggregation'),
    dict(value='none', dist_name=MR_NR_BTS_NAME, p_name='caConfigurationSupport'),
    dict(value='38', dist_name=MR_NR_CELL_NAME, p_name='prachConfigurationIndex'),
    dict(value='38', dist_name=MR_NR_CELL2_NAME, p_name='prachConfigurationIndex'),
    dict(value='38', dist_name=MR_NR_CELL3_NAME, p_name='prachConfigurationIndex'),
    dict(value='38', dist_name=MR_NR_CELL4_NAME, p_name='prachConfigurationIndex'),
]

scell_id_list0 = ['50', '51', '52']
scell_id_list1 = ['50', '52', '53']

element_parameter = ['periodicityAndOffset', 'csi-IM-ResourcesForInterference',
                     'subcarrierLocation-p1', 'symbolLocation-p1', 'startingRB', 'nrofRBs']

exp_element_dic = {'periodicityAndOffset': '13',
                   'csi-IM-ResourcesForInterference': '11',
                   'subcarrierLocation-p1': '1',
                   'startingRB': '0',
                   'nrofRBs': '68'}

element_parameter1 = [['nzp-CSI-RS-ResourceToAddModList', 'csi-IM-ResourceId'],
                      ['nzp-CSI-RS-ResourceSetToAddModList', 'CSI-IM-ResourceSetId']]

element_parameter2 = ['periodicityAndOffset: slots320', 'firstOFDMSymbolInTimeDomain']
