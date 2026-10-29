import os
from robot.libraries.BuiltIn import BuiltIn
tl = BuiltIn().get_variable_value('${tl}')
CFG_DIR = os.path.dirname(os.path.abspath(__file__))
MR_NR_BTS_NAME = 'MRBTS-' + \
    str(tl.gnbs[0].instance_id) + '/NRBTS-' + str(tl.gnbs[0].global_bts_id)

PARAMS_TO_MODIFY_B_01 = [
    dict(value='false', dist_name=MR_NR_BTS_NAME, p_name='actCarrierAggregation'),
    dict(value='none', dist_name=MR_NR_BTS_NAME, p_name='caConfigurationSupport')
]
PARAMS_TO_MODIFY_L_01 = [
    dict(value='1', dist_name=MR_NR_BTS_NAME, p_name='maxNumScellsDl'),
    dict(value='0', dist_name=MR_NR_BTS_NAME, p_name='maxNumScellsUl'),
    dict(value='true', dist_name=MR_NR_BTS_NAME, p_name='actCarrierAggregation'),
    dict(value='2CCDL_2CCUL', dist_name=MR_NR_BTS_NAME, p_name='caConfigurationSupport'),
    dict(value='250', dist_name=MR_NR_BTS_NAME + '/NRCELL-1', p_name='maxNumOfUsersPerCell'),
    dict(value='30', dist_name=MR_NR_BTS_NAME + '/NRCELL-2', p_name='maxNumOfUsersPerCell'),
    dict(value='30', dist_name=MR_NR_BTS_NAME + '/NRCELL-3', p_name='maxNumOfUsersPerCell'),
    dict(value='40', dist_name=MR_NR_BTS_NAME + '/NRCELL-4', p_name='maxNumOfUsersPerCell'),
    dict(value='250', dist_name=MR_NR_BTS_NAME + '/NRCELL-1', p_name='maxNumOfSCellAlloc'),
    dict(value='30', dist_name=MR_NR_BTS_NAME + '/NRCELL-2', p_name='maxNumOfSCellAlloc'),
    dict(value='30', dist_name=MR_NR_BTS_NAME + '/NRCELL-3', p_name='maxNumOfSCellAlloc'),
    dict(value='40', dist_name=MR_NR_BTS_NAME + '/NRCELL-4', p_name='maxNumOfSCellAlloc')
]

PARAMS_TO_MODIFY_L_02 = [
    dict(value='2', dist_name=MR_NR_BTS_NAME, p_name='maxNumScellsDl'),
    dict(value='1', dist_name=MR_NR_BTS_NAME, p_name='maxNumScellsUl'),
    dict(value='true', dist_name=MR_NR_BTS_NAME, p_name='actCarrierAggregation'),
    dict(value='2CCDL_2CCUL', dist_name=MR_NR_BTS_NAME, p_name='caConfigurationSupport'),
    dict(value='250', dist_name=MR_NR_BTS_NAME + '/NRCELL-1', p_name='maxNumOfUsersPerCell'),
    dict(value='40', dist_name=MR_NR_BTS_NAME + '/NRCELL-2', p_name='maxNumOfUsersPerCell'),
    dict(value='40', dist_name=MR_NR_BTS_NAME + '/NRCELL-2', p_name='maxNumOfSCellAlloc'),
    dict(value='30', dist_name=MR_NR_BTS_NAME + '/NRCELL-3', p_name='maxNumOfUsersPerCell'),
    dict(value='30', dist_name=MR_NR_BTS_NAME + '/NRCELL-3', p_name='maxNumOfSCellAlloc'),
    dict(value='20', dist_name=MR_NR_BTS_NAME + '/NRCELL-4', p_name='maxNumOfUsersPerCell'),
    dict(value='20', dist_name=MR_NR_BTS_NAME + '/NRCELL-4', p_name='maxNumOfSCellAlloc')
]

PARAMS_TO_MODIFY_L_03 = [
    dict(value='2', dist_name=MR_NR_BTS_NAME, p_name='maxNumScellsDl'),
    dict(value='1', dist_name=MR_NR_BTS_NAME, p_name='maxNumScellsUl'),
    dict(value='true', dist_name=MR_NR_BTS_NAME, p_name='actCarrierAggregation'),
    dict(value='2CCDL_2CCUL', dist_name=MR_NR_BTS_NAME, p_name='caConfigurationSupport'),
    dict(value='250', dist_name=MR_NR_BTS_NAME + '/NRCELL-1', p_name='maxNumOfUsersPerCell'),
    dict(value='30', dist_name=MR_NR_BTS_NAME + '/NRCELL-2', p_name='maxNumOfUsersPerCell'),
    dict(value='30', dist_name=MR_NR_BTS_NAME + '/NRCELL-2', p_name='maxNumOfSCellAlloc'),
    dict(value='40', dist_name=MR_NR_BTS_NAME + '/NRCELL-3', p_name='maxNumOfUsersPerCell'),
    dict(value='40', dist_name=MR_NR_BTS_NAME + '/NRCELL-3', p_name='maxNumOfSCellAlloc'),
    dict(value='20', dist_name=MR_NR_BTS_NAME + '/NRCELL-4', p_name='maxNumOfUsersPerCell'),
    dict(value='20', dist_name=MR_NR_BTS_NAME + '/NRCELL-4', p_name='maxNumOfSCellAlloc'),
]

PARAMS_TO_MODIFY_L_04 = [
    dict(value='2', dist_name=MR_NR_BTS_NAME, p_name='maxNumScellsDl'),
    dict(value='1', dist_name=MR_NR_BTS_NAME, p_name='maxNumScellsUl'),
    dict(value='true', dist_name=MR_NR_BTS_NAME, p_name='actCarrierAggregation'),
    dict(value='4CCDL_2CCUL', dist_name=MR_NR_BTS_NAME, p_name='caConfigurationSupport'),
    dict(value='250', dist_name=MR_NR_BTS_NAME + '/NRCELL-1', p_name='maxNumOfUsersPerCell'),
    dict(value='200', dist_name=MR_NR_BTS_NAME + '/NRCELL-1', p_name='maxNumOfSCellAlloc'),
    dict(value='250', dist_name=MR_NR_BTS_NAME + '/NRCELL-2', p_name='maxNumOfUsersPerCell'),
    dict(value='200', dist_name=MR_NR_BTS_NAME + '/NRCELL-2', p_name='maxNumOfSCellAlloc'),
    dict(value='250', dist_name=MR_NR_BTS_NAME + '/NRCELL-3', p_name='maxNumOfUsersPerCell'),
    dict(value='200', dist_name=MR_NR_BTS_NAME + '/NRCELL-3', p_name='maxNumOfSCellAlloc'),
    dict(value='200', dist_name=MR_NR_BTS_NAME + '/NRCELL-4', p_name='maxNumOfUsersPerCell'),
    dict(value='200', dist_name=MR_NR_BTS_NAME + '/NRCELL-4', p_name='maxNumOfSCellAlloc')
]

PARAMS_TO_MODIFY_L_05 = [
    dict(value='2', dist_name=MR_NR_BTS_NAME, p_name='maxNumScellsDl'),
    dict(value='1', dist_name=MR_NR_BTS_NAME, p_name='maxNumScellsUl'),
    dict(value='true', dist_name=MR_NR_BTS_NAME, p_name='actCarrierAggregation'),
    dict(value='4CCDL_2CCUL', dist_name=MR_NR_BTS_NAME, p_name='caConfigurationSupport'),
    dict(value='250', dist_name=MR_NR_BTS_NAME + '/NRCELL-1', p_name='maxNumOfUsersPerCell'),
    dict(value='200', dist_name=MR_NR_BTS_NAME + '/NRCELL-2', p_name='maxNumOfUsersPerCell'),
    dict(value='250', dist_name=MR_NR_BTS_NAME + '/NRCELL-3', p_name='maxNumOfUsersPerCell'),
    dict(value='250', dist_name=MR_NR_BTS_NAME + '/NRCELL-4', p_name='maxNumOfUsersPerCell'),
    dict(value='200', dist_name=MR_NR_BTS_NAME + '/NRCELL-1', p_name='maxNumOfSCellAlloc'),
    dict(value='100', dist_name=MR_NR_BTS_NAME + '/NRCELL-2', p_name='maxNumOfSCellAlloc'),
    dict(value='200', dist_name=MR_NR_BTS_NAME + '/NRCELL-3', p_name='maxNumOfSCellAlloc'),
    dict(value='200', dist_name=MR_NR_BTS_NAME + '/NRCELL-4', p_name='maxNumOfSCellAlloc')
]

PARAMS_TO_MODIFY_G_01 = [
    dict(value='2', dist_name=MR_NR_BTS_NAME, p_name='maxNumScellsDl'),
    dict(value='1', dist_name=MR_NR_BTS_NAME, p_name='maxNumScellsUl'),
    dict(value='true', dist_name=MR_NR_BTS_NAME, p_name='actCarrierAggregation'),
    dict(value='4CCDL_2CCUL', dist_name=MR_NR_BTS_NAME, p_name='caConfigurationSupport'),
    dict(value='15min', dist_name=MR_NR_BTS_NAME + '/NRPMRNL-1', p_name='miNrF1CD')
]

PARAMS_TO_MODIFY_G_02 = [
    dict(value='2DL2UL', dist_name=MR_NR_BTS_NAME+'/NRCELL-1', p_name='nrCellType'),
    dict(value='2DL0UL', dist_name=MR_NR_BTS_NAME+'/NRCELL-2', p_name='nrCellType'),
    dict(value='2DL0UL', dist_name=MR_NR_BTS_NAME+'/NRCELL-3', p_name='nrCellType'),
    dict(value='2DL0UL', dist_name=MR_NR_BTS_NAME+'/NRCELL-4', p_name='nrCellType'),
    dict(value='1', dist_name=MR_NR_BTS_NAME, p_name='maxNumScellsDl'),
    dict(value='1', dist_name=MR_NR_BTS_NAME, p_name='maxNumScellsUl'),
    dict(value='250', dist_name=MR_NR_BTS_NAME + '/NRCELL-1', p_name='maxNumOfUsersPerCell'),
    dict(value='250', dist_name=MR_NR_BTS_NAME + '/NRCELL-2', p_name='maxNumOfUsersPerCell'),
    dict(value='250', dist_name=MR_NR_BTS_NAME + '/NRCELL-3', p_name='maxNumOfUsersPerCell'),
    dict(value='250', dist_name=MR_NR_BTS_NAME + '/NRCELL-4', p_name='maxNumOfUsersPerCell'),
    dict(value='200', dist_name=MR_NR_BTS_NAME + '/NRCELL-1', p_name='maxNumOfSCellAlloc'),
    dict(value='200', dist_name=MR_NR_BTS_NAME + '/NRCELL-2', p_name='maxNumOfSCellAlloc'),
    dict(value='200', dist_name=MR_NR_BTS_NAME + '/NRCELL-3', p_name='maxNumOfSCellAlloc'),
    dict(value='200', dist_name=MR_NR_BTS_NAME + '/NRCELL-4', p_name='maxNumOfSCellAlloc')
]

scell_id_list1 = ['50', '53']
scell_id_list2 = ['50', '51']
scell_id_list3 = ['50', '52']
scell_id_list4 = ['50', '51', '52']
scell_id_list5 = ['50', '52', '53']
scell_id_list6 = ['50', '51', '52']

scell_480_G_list0 = ['16385', '16386']
scell_480_G_list1 = ['16385', '16387']
scell_480_G_list2 = ['16385', '16388']
scell_480_G_list3 = ['16385', '16388']


filter_value = ['x2ap.protocolIEs == 4']
