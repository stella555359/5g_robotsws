import os
from robot.libraries.BuiltIn import BuiltIn
tl = BuiltIn().get_variable_value('${tl}')
CFG_DIR = os.path.dirname(os.path.abspath(__file__))

MR_NR_CELL_NAME = 'MRBTS-' + str(tl.gnbs[0].instance_id) + '/NRBTS-' + str(tl.gnbs[0].global_bts_id) + \
    '/NRCELL-' + str(tl.gnbs[0].global_bts_id)
MR_NR_BTS_NAME = 'MRBTS-' + \
    str(tl.gnbs[0].instance_id) + '/NRBTS-' + str(tl.gnbs[0].global_bts_id)

PARAMS_TO_MODIFY_100MHz = [
    dict(value='100MHz', dist_name=MR_NR_CELL_NAME, p_name='chBw'),
    dict(value='277', dist_name=MR_NR_CELL_NAME,
         p_name='frequencyDensityThresNrb1'),
]

PARAMS_TO_MODIFY_L_01 = [
    dict(
        value='false',
        dist_name=MR_NR_BTS_NAME,
        p_name='actCarrierAggregation'),
]

PARAMS_TO_MODIFY_L_02 = [
    dict(
        value='true',
        dist_name=MR_NR_BTS_NAME,
        p_name='actCarrierAggregation'),
]

PARAMS_TO_MODIFY_AA_01 = [
    dict(value='1', dist_name=MR_NR_BTS_NAME, p_name='maxNumScellsDl'),
    dict(value='1', dist_name=MR_NR_BTS_NAME, p_name='maxNumScellsUl'),
    dict(value='2CCDL_2CCUL', dist_name=MR_NR_BTS_NAME, p_name='caConfigurationSupport'),
    dict(value='bufferBased', dist_name=MR_NR_BTS_NAME, p_name='sCellActivationMethod'),
    dict(value='true', dist_name=MR_NR_BTS_NAME, p_name='actCarrierAggregation'),
    dict(value='250', dist_name=MR_NR_BTS_NAME + '/NRCELL-1', p_name='maxNumOfUsersPerCell'),
    dict(value='250', dist_name=MR_NR_BTS_NAME + '/NRCELL-2', p_name='maxNumOfUsersPerCell'),
    dict(value='200', dist_name=MR_NR_BTS_NAME + '/NRCELL-3', p_name='maxNumOfUsersPerCell'),
    dict(value='200', dist_name=MR_NR_BTS_NAME + '/NRCELL-4', p_name='maxNumOfUsersPerCell'),
    dict(value='200', dist_name=MR_NR_BTS_NAME + '/NRCELL-1', p_name='maxNumOfSCellAlloc'),
    dict(value='200', dist_name=MR_NR_BTS_NAME + '/NRCELL-2', p_name='maxNumOfSCellAlloc'),
    dict(value='200', dist_name=MR_NR_BTS_NAME + '/NRCELL-3', p_name='maxNumOfSCellAlloc'),
    dict(value='200', dist_name=MR_NR_BTS_NAME + '/NRCELL-4', p_name='maxNumOfSCellAlloc')
]

PARAMS_TO_MODIFY_AA_02 = [
    dict(value='1', dist_name=MR_NR_BTS_NAME, p_name='maxNumScellsDl'),
    dict(value='1', dist_name=MR_NR_BTS_NAME, p_name='maxNumScellsUl'),
    dict(value='2CCDL_2CCUL', dist_name=MR_NR_BTS_NAME, p_name='caConfigurationSupport'),
    dict(value='blind', dist_name=MR_NR_BTS_NAME, p_name='sCellActivationMethod'),
    dict(value='true', dist_name=MR_NR_BTS_NAME, p_name='actCarrierAggregation'),
    dict(value='250', dist_name=MR_NR_BTS_NAME + '/NRCELL-1', p_name='maxNumOfUsersPerCell'),
    dict(value='250', dist_name=MR_NR_BTS_NAME + '/NRCELL-2', p_name='maxNumOfUsersPerCell'),
    dict(value='200', dist_name=MR_NR_BTS_NAME + '/NRCELL-3', p_name='maxNumOfUsersPerCell'),
    dict(value='200', dist_name=MR_NR_BTS_NAME + '/NRCELL-4', p_name='maxNumOfUsersPerCell'),
    dict(value='200', dist_name=MR_NR_BTS_NAME + '/NRCELL-1', p_name='maxNumOfSCellAlloc'),
    dict(value='200', dist_name=MR_NR_BTS_NAME + '/NRCELL-2', p_name='maxNumOfSCellAlloc'),
    dict(value='200', dist_name=MR_NR_BTS_NAME + '/NRCELL-3', p_name='maxNumOfSCellAlloc'),
    dict(value='200', dist_name=MR_NR_BTS_NAME + '/NRCELL-4', p_name='maxNumOfSCellAlloc')
]

PARAMS_TO_MODIFY_AA_03 = [
    dict(value='1', dist_name=MR_NR_BTS_NAME, p_name='maxNumScellsDl'),
    dict(value='1', dist_name=MR_NR_BTS_NAME, p_name='maxNumScellsUl'),
    dict(value='none', dist_name=MR_NR_BTS_NAME, p_name='caConfigurationSupport'),
    dict(value='blind', dist_name=MR_NR_BTS_NAME, p_name='sCellActivationMethod'),
    dict(value='false', dist_name=MR_NR_BTS_NAME, p_name='actCarrierAggregation'),
    dict(value='infinity', dist_name=MR_NR_BTS_NAME + '/NRCELL-1', p_name='sCellDeactivationTimerGNB'),
    dict(value='infinity', dist_name=MR_NR_BTS_NAME + '/NRCELL-2', p_name='sCellDeactivationTimerGNB'),
    dict(value='infinity', dist_name=MR_NR_BTS_NAME + '/NRCELL-3', p_name='sCellDeactivationTimerGNB'),
    dict(value='infinity', dist_name=MR_NR_BTS_NAME + '/NRCELL-4', p_name='sCellDeactivationTimerGNB'),
    dict(value='250', dist_name=MR_NR_BTS_NAME + '/NRCELL-1', p_name='maxNumOfUsersPerCell'),
    dict(value='250', dist_name=MR_NR_BTS_NAME + '/NRCELL-2', p_name='maxNumOfUsersPerCell'),
    dict(value='200', dist_name=MR_NR_BTS_NAME + '/NRCELL-3', p_name='maxNumOfUsersPerCell'),
    dict(value='200', dist_name=MR_NR_BTS_NAME + '/NRCELL-4', p_name='maxNumOfUsersPerCell'),
    dict(value='200', dist_name=MR_NR_BTS_NAME + '/NRCELL-1', p_name='maxNumOfSCellAlloc'),
    dict(value='200', dist_name=MR_NR_BTS_NAME + '/NRCELL-2', p_name='maxNumOfSCellAlloc'),
    dict(value='200', dist_name=MR_NR_BTS_NAME + '/NRCELL-3', p_name='maxNumOfSCellAlloc'),
    dict(value='200', dist_name=MR_NR_BTS_NAME + '/NRCELL-4', p_name='maxNumOfSCellAlloc')
]

PARAMS_TO_MODIFY_AA_03_true = [
    dict(value='1', dist_name=MR_NR_BTS_NAME, p_name='maxNumScellsDl'),
    dict(value='1', dist_name=MR_NR_BTS_NAME, p_name='maxNumScellsUl'),
    dict(
        value='2CCDL_2CCUL',
        dist_name=MR_NR_BTS_NAME,
        p_name='caConfigurationSupport'),
    dict(
        value='blind',
        dist_name=MR_NR_BTS_NAME,
        p_name='sCellActivationMethod'),
    dict(
        value='true',
        dist_name=MR_NR_BTS_NAME,
        p_name='actCarrierAggregation'),
    dict(value='250', dist_name=MR_NR_BTS_NAME + '/NRCELL-1', p_name='maxNumOfUsersPerCell'),
    dict(value='250', dist_name=MR_NR_BTS_NAME + '/NRCELL-2', p_name='maxNumOfUsersPerCell'),
    dict(value='200', dist_name=MR_NR_BTS_NAME + '/NRCELL-3', p_name='maxNumOfUsersPerCell'),
    dict(value='200', dist_name=MR_NR_BTS_NAME + '/NRCELL-4', p_name='maxNumOfUsersPerCell'),
    dict(value='infinity', dist_name=MR_NR_BTS_NAME + '/NRCELL-1', p_name='sCellDeactivationTimerGNB'),
    dict(value='infinity', dist_name=MR_NR_BTS_NAME + '/NRCELL-2', p_name='sCellDeactivationTimerGNB'),
    dict(value='infinity', dist_name=MR_NR_BTS_NAME + '/NRCELL-3', p_name='sCellDeactivationTimerGNB'),
    dict(value='infinity', dist_name=MR_NR_BTS_NAME + '/NRCELL-4', p_name='sCellDeactivationTimerGNB'),
    dict(value='200', dist_name=MR_NR_BTS_NAME + '/NRCELL-1', p_name='maxNumOfSCellAlloc'),
    dict(value='200', dist_name=MR_NR_BTS_NAME + '/NRCELL-2', p_name='maxNumOfSCellAlloc'),
    dict(value='200', dist_name=MR_NR_BTS_NAME + '/NRCELL-3', p_name='maxNumOfSCellAlloc'),
    dict(value='200', dist_name=MR_NR_BTS_NAME + '/NRCELL-4', p_name='maxNumOfSCellAlloc')
]

PARAMS_TO_MODIFY_AA_04 = [
    dict(value='2', dist_name=MR_NR_BTS_NAME, p_name='maxNumScellsDl'),
    dict(value='0', dist_name=MR_NR_BTS_NAME, p_name='maxNumScellsUl'),
    dict(value='bufferBased', dist_name=MR_NR_BTS_NAME, p_name='sCellActivationMethod'),
    dict(value='true', dist_name=MR_NR_BTS_NAME, p_name='actCarrierAggregation'),
    dict(value='2x2 Closed Loop Spatial Multiplexing', dist_name=MR_NR_BTS_NAME + '/NRCELL-1', p_name='dlMimoMode'),
    dict(value='2x2 Closed Loop Spatial Multiplexing', dist_name=MR_NR_BTS_NAME + '/NRCELL-2', p_name='dlMimoMode'),
    dict(value='2x2 Closed Loop Spatial Multiplexing', dist_name=MR_NR_BTS_NAME + '/NRCELL-3', p_name='dlMimoMode'),
    dict(value='2x2 Closed Loop Spatial Multiplexing', dist_name=MR_NR_BTS_NAME + '/NRCELL-4', p_name='dlMimoMode')
]

PARAMS_TO_MODIFY_AA_05 = [
    dict(value='2', dist_name=MR_NR_BTS_NAME, p_name='maxNumScellsDl'),
    dict(value='1', dist_name=MR_NR_BTS_NAME, p_name='maxNumScellsUl'),
    dict(value='blind', dist_name=MR_NR_BTS_NAME, p_name='sCellActivationMethod'),
    dict(value='true', dist_name=MR_NR_BTS_NAME, p_name='actCarrierAggregation'),
    dict(value='250', dist_name=MR_NR_BTS_NAME + '/NRCELL-1', p_name='maxNumOfUsersPerCell'),
    dict(value='250', dist_name=MR_NR_BTS_NAME + '/NRCELL-2', p_name='maxNumOfUsersPerCell'),
    dict(value='200', dist_name=MR_NR_BTS_NAME + '/NRCELL-3', p_name='maxNumOfUsersPerCell'),
    dict(value='200', dist_name=MR_NR_BTS_NAME + '/NRCELL-4', p_name='maxNumOfUsersPerCell'),
    dict(value='200', dist_name=MR_NR_BTS_NAME + '/NRCELL-1', p_name='maxNumOfSCellAlloc'),
    dict(value='200', dist_name=MR_NR_BTS_NAME + '/NRCELL-2', p_name='maxNumOfSCellAlloc'),
    dict(value='200', dist_name=MR_NR_BTS_NAME + '/NRCELL-3', p_name='maxNumOfSCellAlloc'),
    dict(value='200', dist_name=MR_NR_BTS_NAME + '/NRCELL-4', p_name='maxNumOfSCellAlloc')
]

PARAMS_TO_MODIFY_AA_05_1 = [
    dict(value='1', dist_name=MR_NR_BTS_NAME, p_name='maxNumScellsDl'),
    dict(value='1', dist_name=MR_NR_BTS_NAME, p_name='maxNumScellsUl'),
    dict(value='bufferBased', dist_name=MR_NR_BTS_NAME, p_name='sCellActivationMethod'),
    dict(value='true', dist_name=MR_NR_BTS_NAME, p_name='actCarrierAggregation'),
    dict(value='2CCDL_2CCUL', dist_name=MR_NR_BTS_NAME, p_name='caConfigurationSupport'),
    dict(value='250', dist_name=MR_NR_BTS_NAME + '/NRCELL-1', p_name='maxNumOfUsersPerCell'),
    dict(value='250', dist_name=MR_NR_BTS_NAME + '/NRCELL-2', p_name='maxNumOfUsersPerCell'),
    dict(value='250', dist_name=MR_NR_BTS_NAME + '/NRCELL-3', p_name='maxNumOfUsersPerCell'),
    dict(value='250', dist_name=MR_NR_BTS_NAME + '/NRCELL-4', p_name='maxNumOfUsersPerCell'),
    dict(value='200', dist_name=MR_NR_BTS_NAME + '/NRCELL-1', p_name='maxNumOfSCellAlloc'),
    dict(value='200', dist_name=MR_NR_BTS_NAME + '/NRCELL-2', p_name='maxNumOfSCellAlloc'),
    dict(value='200', dist_name=MR_NR_BTS_NAME + '/NRCELL-3', p_name='maxNumOfSCellAlloc'),
    dict(value='200', dist_name=MR_NR_BTS_NAME + '/NRCELL-4', p_name='maxNumOfSCellAlloc')
]

PARAMS_TO_MODIFY_maxnumscell_01 = [
    dict(value='2', dist_name=MR_NR_BTS_NAME, p_name='maxNumScellsDl'),
    dict(value='1', dist_name=MR_NR_BTS_NAME, p_name='maxNumScellsUl'),
    dict(value='true', dist_name=MR_NR_BTS_NAME, p_name='actCarrierAggregation'),
]

PARAMS_TO_MODIFY_maxnumscell_empty = [
    dict(value='0', dist_name=MR_NR_BTS_NAME, p_name='maxNumScellsDl'),
    dict(value='0', dist_name=MR_NR_BTS_NAME, p_name='maxNumScellsUl'),
    dict(value='true', dist_name=MR_NR_BTS_NAME, p_name='actCarrierAggregation'),
]

scell_id_list0 = ['50', '51']
scell_id_list1 = ['50']

parameter_list1 = ['maxNumScellsDl', 'maxNumScellsUl']

filter_value = ['x2ap.protocolIEs == 4']
