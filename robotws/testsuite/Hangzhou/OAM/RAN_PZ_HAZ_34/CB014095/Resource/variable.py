from robot.libraries.BuiltIn import BuiltIn
from testsuite.Hangzhou.OAM.RAN_PZ_HAZ_34.libraries.global_vars import *

tl = BuiltIn().get_variable_value("${tl}")

__maintainer__ = 'Han Ruiyu'
__team__ = 'I_MI_MN_RAN_RD_VRF_HAZ_04'
__email__ = 'ruiyu.han@nokia.com'

_gnb_id = str(tl.gnbs[0].instance_id)
_MRBTSname = 'MRBTS-' + _gnb_id
_NRBTSname = _MRBTSname + '/NRBTS-' + _gnb_id

_class_name = 'com.nokia.srbts.mnl:MPLANENW'


PARAMS_blind = {
    'update': [
        dict(value='2_16_UTE5GCLASSICAL3121_blind', dist_name='MRBTS-%s' % (GLOBAL_BTS_ID),
             parameter='btsName'),
        dict(value='blind', dist_name='MRBTS-%s/NRBTS-%s/NRCELL-4/NRREL-1' % (GLOBAL_BTS_ID, MRBTS_ID),
             parameter='sCellAdditionMethod'),
        dict(value='blind', dist_name='MRBTS-%s/NRBTS-%s/NRCELL-4/NRREL-2' % (GLOBAL_BTS_ID, MRBTS_ID),
             parameter='sCellAdditionMethod'),
        dict(value='blind', dist_name='MRBTS-%s/NRBTS-%s/NRCELL-4/NRREL-3' % (GLOBAL_BTS_ID, MRBTS_ID),
             parameter='sCellAdditionMethod'),
        dict(value='blind', dist_name='MRBTS-%s/NRBTS-%s/NRCELL-4/NRREL-5' % (GLOBAL_BTS_ID, MRBTS_ID),
             parameter='sCellAdditionMethod'),
        dict(value='blind', dist_name='MRBTS-%s/NRBTS-%s/NRCELL-4/NRREL-6' % (GLOBAL_BTS_ID, MRBTS_ID),
             parameter='sCellAdditionMethod'),
        dict(value='dlAndUl', dist_name='MRBTS-%s/NRBTS-%s/NRCELL-4/NRREL-1' % (GLOBAL_BTS_ID, MRBTS_ID),
             parameter='sCellOperationalMode'),
        dict(value='dlAndUl', dist_name='MRBTS-%s/NRBTS-%s/NRCELL-4/NRREL-2' % (GLOBAL_BTS_ID, MRBTS_ID),
             parameter='sCellOperationalMode'),
        dict(value='dlAndUl', dist_name='MRBTS-%s/NRBTS-%s/NRCELL-4/NRREL-3' % (GLOBAL_BTS_ID, MRBTS_ID),
             parameter='sCellOperationalMode'),
        dict(value='dlAndUl', dist_name='MRBTS-%s/NRBTS-%s/NRCELL-4/NRREL-5' % (GLOBAL_BTS_ID, MRBTS_ID),
             parameter='sCellOperationalMode'),
        dict(value='dlAndUl', dist_name='MRBTS-%s/NRBTS-%s/NRCELL-4/NRREL-6' % (GLOBAL_BTS_ID, MRBTS_ID),
             parameter='sCellOperationalMode'),
        dict(value="disabled", dist_name='MRBTS-%s/NRBTS-%s' % (GLOBAL_BTS_ID, MRBTS_ID),
             parameter='actBufferBasedSCellAddition'),
    ]
}


PARAMS_A1_ONESHOT = {
    'update': [
        dict(value='2_16_UTE5GCLASSICAL3121_A1ONESHOT', dist_name='MRBTS-%s' % (GLOBAL_BTS_ID),
             parameter='btsName'),
        dict(value='covBasedA1', dist_name='MRBTS-%s/NRBTS-%s/NRCELL-4/NRREL-1' % (GLOBAL_BTS_ID, MRBTS_ID),
             parameter='sCellAdditionMethod'),
        dict(value='covBasedA1', dist_name='MRBTS-%s/NRBTS-%s/NRCELL-4/NRREL-2' % (GLOBAL_BTS_ID, MRBTS_ID),
             parameter='sCellAdditionMethod'),
        dict(value='covBasedA1', dist_name='MRBTS-%s/NRBTS-%s/NRCELL-4/NRREL-3' % (GLOBAL_BTS_ID, MRBTS_ID),
             parameter='sCellAdditionMethod'),
        dict(value='covBasedA1', dist_name='MRBTS-%s/NRBTS-%s/NRCELL-4/NRREL-6' % (GLOBAL_BTS_ID, MRBTS_ID),
             parameter='sCellAdditionMethod'),
        dict(value='covBasedA1', dist_name='MRBTS-%s/NRBTS-%s/NRCELL-4/NRREL-5' % (GLOBAL_BTS_ID, MRBTS_ID),
             parameter='sCellAdditionMethod'),
        dict(value='dlAndUl', dist_name='MRBTS-%s/NRBTS-%s/NRCELL-4/NRREL-1' % (GLOBAL_BTS_ID, MRBTS_ID),
             parameter='sCellOperationalMode'),
        dict(value='dlAndUl', dist_name='MRBTS-%s/NRBTS-%s/NRCELL-4/NRREL-2' % (GLOBAL_BTS_ID, MRBTS_ID),
             parameter='sCellOperationalMode'),
        dict(value='dlAndUl', dist_name='MRBTS-%s/NRBTS-%s/NRCELL-4/NRREL-3' % (GLOBAL_BTS_ID, MRBTS_ID),
             parameter='sCellOperationalMode'),
        dict(value='dlAndUl', dist_name='MRBTS-%s/NRBTS-%s/NRCELL-4/NRREL-5' % (GLOBAL_BTS_ID, MRBTS_ID),
             parameter='sCellOperationalMode'),
        dict(value='dlAndUl', dist_name='MRBTS-%s/NRBTS-%s/NRCELL-4/NRREL-6' % (GLOBAL_BTS_ID, MRBTS_ID),
             parameter='sCellOperationalMode'),
        dict(value='oneShot_DlAndUl_Fr1', dist_name='MRBTS-%s/NRBTS-%s' % (GLOBAL_BTS_ID, MRBTS_ID),
             parameter='actBufferBasedSCellAddition'),
    ]
}


PARAMS_A1_STEPWISE = {
    'update': [
        dict(value='2_16_UTE5GCLASSICAL3121_A1STEPWISE', dist_name='MRBTS-%s' % (GLOBAL_BTS_ID),
             parameter='btsName'),
        dict(value='covBasedA1', dist_name='MRBTS-%s/NRBTS-%s/NRCELL-4/NRREL-1' % (GLOBAL_BTS_ID, MRBTS_ID),
             parameter='sCellAdditionMethod'),
        dict(value='covBasedA1', dist_name='MRBTS-%s/NRBTS-%s/NRCELL-4/NRREL-2' % (GLOBAL_BTS_ID, MRBTS_ID),
             parameter='sCellAdditionMethod'),
        dict(value='covBasedA1', dist_name='MRBTS-%s/NRBTS-%s/NRCELL-4/NRREL-3' % (GLOBAL_BTS_ID, MRBTS_ID),
             parameter='sCellAdditionMethod'),
        dict(value='covBasedA1', dist_name='MRBTS-%s/NRBTS-%s/NRCELL-4/NRREL-5' % (GLOBAL_BTS_ID, MRBTS_ID),
             parameter='sCellAdditionMethod'),
        dict(value='covBasedA1', dist_name='MRBTS-%s/NRBTS-%s/NRCELL-4/NRREL-6' % (GLOBAL_BTS_ID, MRBTS_ID),
             parameter='sCellAdditionMethod'),
        dict(value='dlAndUl', dist_name='MRBTS-%s/NRBTS-%s/NRCELL-4/NRREL-1' % (GLOBAL_BTS_ID, MRBTS_ID),
             parameter='sCellOperationalMode'),
        dict(value='dlAndUl', dist_name='MRBTS-%s/NRBTS-%s/NRCELL-4/NRREL-2' % (GLOBAL_BTS_ID, MRBTS_ID),
             parameter='sCellOperationalMode'),
        dict(value='dlAndUl', dist_name='MRBTS-%s/NRBTS-%s/NRCELL-4/NRREL-3' % (GLOBAL_BTS_ID, MRBTS_ID),
             parameter='sCellOperationalMode'),
        dict(value='dlAndUl', dist_name='MRBTS-%s/NRBTS-%s/NRCELL-4/NRREL-5' % (GLOBAL_BTS_ID, MRBTS_ID),
             parameter='sCellOperationalMode'),
        dict(value='dlAndUl', dist_name='MRBTS-%s/NRBTS-%s/NRCELL-4/NRREL-6' % (GLOBAL_BTS_ID, MRBTS_ID),
             parameter='sCellOperationalMode'),
        dict(value='oneShot_stepWise_Dl_Fr1', dist_name='MRBTS-%s/NRBTS-%s' % (GLOBAL_BTS_ID, MRBTS_ID),
             parameter='actBufferBasedSCellAddition'),
    ]
}

PARAMS_A4_ONESHOT = {
    'update': [
        dict(value='2_16_UTE5GCLASSICAL3121_A4ONESHOT', dist_name='MRBTS-%s' % (GLOBAL_BTS_ID),
             parameter='btsName'),
        dict(value='covBasedA4', dist_name='MRBTS-%s/NRBTS-%s/NRCELL-4/NRREL-1' % (GLOBAL_BTS_ID, MRBTS_ID),
             parameter='sCellAdditionMethod'),
        dict(value='covBasedA4', dist_name='MRBTS-%s/NRBTS-%s/NRCELL-4/NRREL-2' % (GLOBAL_BTS_ID, MRBTS_ID),
             parameter='sCellAdditionMethod'),
        dict(value='covBasedA4', dist_name='MRBTS-%s/NRBTS-%s/NRCELL-4/NRREL-3' % (GLOBAL_BTS_ID, MRBTS_ID),
             parameter='sCellAdditionMethod'),
        dict(value='covBasedA4', dist_name='MRBTS-%s/NRBTS-%s/NRCELL-4/NRREL-5' % (GLOBAL_BTS_ID, MRBTS_ID),
             parameter='sCellAdditionMethod'),
        dict(value='covBasedA4', dist_name='MRBTS-%s/NRBTS-%s/NRCELL-4/NRREL-6' % (GLOBAL_BTS_ID, MRBTS_ID),
             parameter='sCellAdditionMethod'),
        dict(value='dlAndUl', dist_name='MRBTS-%s/NRBTS-%s/NRCELL-4/NRREL-1' % (GLOBAL_BTS_ID, MRBTS_ID),
             parameter='sCellOperationalMode'),
        dict(value='dlAndUl', dist_name='MRBTS-%s/NRBTS-%s/NRCELL-4/NRREL-2' % (GLOBAL_BTS_ID, MRBTS_ID),
             parameter='sCellOperationalMode'),
        dict(value='dlAndUl', dist_name='MRBTS-%s/NRBTS-%s/NRCELL-4/NRREL-3' % (GLOBAL_BTS_ID, MRBTS_ID),
             parameter='sCellOperationalMode'),
        dict(value='dlAndUl', dist_name='MRBTS-%s/NRBTS-%s/NRCELL-4/NRREL-5' % (GLOBAL_BTS_ID, MRBTS_ID),
             parameter='sCellOperationalMode'),
        dict(value='dlAndUl', dist_name='MRBTS-%s/NRBTS-%s/NRCELL-4/NRREL-6' % (GLOBAL_BTS_ID, MRBTS_ID),
             parameter='sCellOperationalMode'),
        dict(value='oneShot_DlAndUl_Fr1', dist_name='MRBTS-%s/NRBTS-%s' % (GLOBAL_BTS_ID, MRBTS_ID),
             parameter='actBufferBasedSCellAddition'),
    ]
}

PARAMS_A4_STEPWISE = {
    'update': [
        dict(value='2_16_UTE5GCLASSICAL3121_A4ONESHOT', dist_name='MRBTS-%s' % (GLOBAL_BTS_ID),
             parameter='btsName'),
        dict(value='covBasedA4', dist_name='MRBTS-%s/NRBTS-%s/NRCELL-4/NRREL-1' % (GLOBAL_BTS_ID, MRBTS_ID),
             parameter='sCellAdditionMethod'),
        dict(value='covBasedA4', dist_name='MRBTS-%s/NRBTS-%s/NRCELL-4/NRREL-2' % (GLOBAL_BTS_ID, MRBTS_ID),
             parameter='sCellAdditionMethod'),
        dict(value='covBasedA4', dist_name='MRBTS-%s/NRBTS-%s/NRCELL-4/NRREL-3' % (GLOBAL_BTS_ID, MRBTS_ID),
             parameter='sCellAdditionMethod'),
        dict(value='covBasedA4', dist_name='MRBTS-%s/NRBTS-%s/NRCELL-4/NRREL-5' % (GLOBAL_BTS_ID, MRBTS_ID),
             parameter='sCellAdditionMethod'),
        dict(value='covBasedA4', dist_name='MRBTS-%s/NRBTS-%s/NRCELL-4/NRREL-6' % (GLOBAL_BTS_ID, MRBTS_ID),
             parameter='sCellAdditionMethod'),
        dict(value='dlAndUl', dist_name='MRBTS-%s/NRBTS-%s/NRCELL-4/NRREL-1' % (GLOBAL_BTS_ID, MRBTS_ID),
             parameter='sCellOperationalMode'),
        dict(value='dlAndUl', dist_name='MRBTS-%s/NRBTS-%s/NRCELL-4/NRREL-2' % (GLOBAL_BTS_ID, MRBTS_ID),
             parameter='sCellOperationalMode'),
        dict(value='dlAndUl', dist_name='MRBTS-%s/NRBTS-%s/NRCELL-4/NRREL-3' % (GLOBAL_BTS_ID, MRBTS_ID),
             parameter='sCellOperationalMode'),
        dict(value='dlAndUl', dist_name='MRBTS-%s/NRBTS-%s/NRCELL-4/NRREL-5' % (GLOBAL_BTS_ID, MRBTS_ID),
             parameter='sCellOperationalMode'),
        dict(value='dlAndUl', dist_name='MRBTS-%s/NRBTS-%s/NRCELL-4/NRREL-6' % (GLOBAL_BTS_ID, MRBTS_ID),
             parameter='sCellOperationalMode'),
        dict(value='oneShot_stepWise_DlAndUl_Fr1', dist_name='MRBTS-%s/NRBTS-%s' % (GLOBAL_BTS_ID, MRBTS_ID),
             parameter='actBufferBasedSCellAddition'),
    ]
}


PARAMS_RM_scell_2 = {
    'delete': [
        dict(dist_name='MRBTS-%s/NRBTS-%s/NRCELL-4/NRREL-2' % (GLOBAL_BTS_ID, MRBTS_ID),
             parameter='sCellAdditionMethod'),
        dict(dist_name='MRBTS-%s/NRBTS-%s/NRCELL-4/NRREL-2' % (GLOBAL_BTS_ID, MRBTS_ID),
             parameter='sCellOperationalMode'),
    ]
}

PARAMS_RM_scell_3 = {
    'delete': [
        dict(dist_name='MRBTS-%s/NRBTS-%s/NRCELL-4/NRREL-3' % (GLOBAL_BTS_ID, MRBTS_ID),
             parameter='sCellAdditionMethod'),
        dict(dist_name='MRBTS-%s/NRBTS-%s/NRCELL-4/NRREL-3' % (GLOBAL_BTS_ID, MRBTS_ID),
             parameter='sCellOperationalMode'),
    ]
}

PARAMS_RM_scell_3_5 = {
    'delete': [
        dict(dist_name='MRBTS-%s/NRBTS-%s/NRCELL-4/NRREL-3' % (GLOBAL_BTS_ID, MRBTS_ID),
             parameter='sCellAdditionMethod'),
        dict(dist_name='MRBTS-%s/NRBTS-%s/NRCELL-4/NRREL-3' % (GLOBAL_BTS_ID, MRBTS_ID),
             parameter='sCellOperationalMode'),
        dict(dist_name='MRBTS-%s/NRBTS-%s/NRCELL-4/NRREL-5' % (GLOBAL_BTS_ID, MRBTS_ID),
             parameter='sCellAdditionMethod'),
        dict(dist_name='MRBTS-%s/NRBTS-%s/NRCELL-4/NRREL-5' % (GLOBAL_BTS_ID, MRBTS_ID),
             parameter='sCellOperationalMode'),
    ]
}

PARAMS_RM_scell_5 = {
    'delete': [
        dict(dist_name='MRBTS-%s/NRBTS-%s/NRCELL-4/NRREL-5' % (GLOBAL_BTS_ID, MRBTS_ID),
             parameter='sCellAdditionMethod'),
        dict(dist_name='MRBTS-%s/NRBTS-%s/NRCELL-4/NRREL-5' % (GLOBAL_BTS_ID, MRBTS_ID),
             parameter='sCellOperationalMode'),
    ]
}


PARAMS_ADD_scell_2 = {
    'update': [
        dict(value='covBasedA1', dist_name='MRBTS-%s/NRBTS-%s/NRCELL-4/NRREL-2' % (GLOBAL_BTS_ID, MRBTS_ID),
             parameter='sCellAdditionMethod'),
        dict(value='dlAndUl', dist_name='MRBTS-%s/NRBTS-%s/NRCELL-4/NRREL-2' % (GLOBAL_BTS_ID, MRBTS_ID),
             parameter='sCellOperationalMode'),
    ]
}

PARAMS_ADD_scell_3 = {
    'update': [
        dict(value='covBasedA1', dist_name='MRBTS-%s/NRBTS-%s/NRCELL-4/NRREL-3' % (GLOBAL_BTS_ID, MRBTS_ID),
             parameter='sCellAdditionMethod'),
        dict(value='dlAndUl', dist_name='MRBTS-%s/NRBTS-%s/NRCELL-4/NRREL-3' % (GLOBAL_BTS_ID, MRBTS_ID),
             parameter='sCellOperationalMode'),
    ]
}
