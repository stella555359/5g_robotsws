import os
from robot.libraries.BuiltIn import BuiltIn
tl = BuiltIn().get_variable_value('${tl}')
CFG_DIR = os.path.dirname(os.path.abspath(__file__))


MR_BTS_NAME1 = 'MRBTS-' + str(tl.gnbs[0].instance_id)
MR_NR_BTS_NAME1 = MR_BTS_NAME1 + '/NRBTS-' + str(tl.gnbs[0].global_bts_id)
NR_NAME1 = 'NRBTS-' + str(tl.gnbs[0].global_bts_id)
FEATCADM_1_NAME = MR_BTS_NAME1 + '/MNL-1/MNLENT-1/FEATCADM-1'
TRBLCADM_1_NAME = MR_BTS_NAME1 + '/MNL-1/MNLENT-1/TRBLCADM-1'
FMCADM_1_NAME = MR_BTS_NAME1 + '/MNL-1/MNLENT-1/FMCADM-1'
BBMOD_R_DN = MR_BTS_NAME1 + '/EQM_R-1/APEQM_R-1/CABINET_R-1/BBMOD_R-2'
cell_R_DN = MR_NR_BTS_NAME1 + '/NRCELL-2'
NRPMRNL_1 = MR_NR_BTS_NAME1 + '/NRPMRNL-1'

FEATCADM_1 = [
    dict(operation='update', parameter='actAutRachBasedSlCellDetRec', value='true')]

FEATCADM_1_teardown = [
    dict(operation='update', parameter='actAutRachBasedSlCellDetRec', value='false')]

FMCADM_1 = [
    dict(operation='update', parameter='actForceAutoReset', value='true')]

case1_gNB = [
    dict(operation='update', parameter='actAutRachBasedSlCellDetRec', value='true'),
    dict(dist_name=TRBLCADM_1_NAME, parameter='autRachBasedSlCellDetHCheckFreq', value='300'),
    dict(dist_name=TRBLCADM_1_NAME, parameter='autRachBasedSlCellRachAtmpThr', value='1'),
    dict(dist_name=TRBLCADM_1_NAME, parameter='autRachBasedSlCellRachMsg3Thr', value='1'),
    dict(dist_name=TRBLCADM_1_NAME, parameter='autRachBasedSlCellRecPh1Timer', value='350'),
    dict(dist_name=TRBLCADM_1_NAME, parameter='autRachBasedSlCellRecPhase1Act', value='true'),
    dict(dist_name=TRBLCADM_1_NAME, parameter='faultSnapshotTriggers', value='faultSnapshotTriggers_1'),
]

case2_TRBLCADM_1 = [
    dict(operation='create', parameter='autRachBasedSlCellDetHCheckFreq', value='180'),
    dict(operation='create', parameter='autRachBasedSlCellRachAtmpThr', value='1'),
    dict(operation='create', parameter='autRachBasedSlCellRachMsg3Thr', value='1'),
    dict(operation='create', parameter='autRachBasedSlCellRecPh1Timer', value='200'),
    dict(operation='create', parameter='autRachBasedSlCellRecPhase2Act', value='true'),
    dict(operation='create', parameter='faultSnapshotTriggers', value='2')
]

case3_TRBLCADM_1 = [
    dict(operation='create', parameter='autRachBasedSlCellDetHCheckFreq', value='180'),
    dict(operation='create', parameter='autRachBasedSlCellRachAtmpThr', value='1'),
    dict(operation='create', parameter='autRachBasedSlCellRachMsg3Thr', value='1'),
    dict(operation='create', parameter='autRachBasedSlCellRecPh3Timer', value='190'),
    dict(operation='create', parameter='autRachBasedSlCellRecPhase3Act', value='true'),
    dict(operation='create', parameter='maxNumSlCellRecActForBbuPerDay', value='2')
]

faultSnapshotTriggers_1 = {"faultNumber": '4547', "triggerType": 'onFaultDetection'}
