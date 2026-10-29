import os
import time
import socket
from taf.config.scf import scf
from taf.sbts.oam.coam.admin import admin as coam
from testsuite.Wroclaw.RRM.VRF_WRO2_T07.resources.log import blog
from testsuite.Wroclaw.RRM.VRF_WRO2_T07.resources.tl_config import tl
import testsuite.Wroclaw.RRM.VRF_WRO2_T07.resources.logs.pm_counters as pm
from testsuite.Wroclaw.RRM.VRF_WRO2_T07.resources.logs.gnb_mirroring import L1L2
from testsuite.Wroclaw.RRM.VRF_WRO2_T07.resources.attenuator import Attenuator
import testsuite.Wroclaw.RRM.VRF_WRO2_T07.resources.rue.attach_utils as rue_utils
from testsuite.Wroclaw.RRM.VRF_WRO2_T07.resources.decorators import logged_keyword
from testsuite.Wroclaw.RRM.VRF_WRO2_T07.resources.admin_api.admin_utils import AdminUtils
from testsuite.Wroclaw.RRM.VRF_WRO2_T07.resources.log_analyzer.log_helper import LogHelper, log_finder
from testsuite.Wroclaw.RRM.VRF_WRO2_T07.resources.logs.tcpdump.tcpdump_smod import TcpdumpSmod
from testsuite.Wroclaw.RRM.resources.decorators import wait_until_function_succeeds
from testsuite.Wroclaw.RRM.VRF_WRO2_T07.resources.log_analyzer.matchers import TTIMessageMatcher
from testsuite.Wroclaw.RRM.VRF_WRO2_T07.resources.admin_api.DeltaStore import DeltaStore
from testsuite.Wroclaw.RRM.VRF_WRO2_T07.classical.feature_CB008238.A.resources.test_specific_keywords import \
    extract_dl_pre_sched_data_from_tti
from testsuite.Wroclaw.RRM.VRF_WRO2_T07.classical.feature_5GC007949.resources.test_specific_keywords import \
    set_relations, get_all_cells_relations_dist_list, \
    get_cell_dist, verify_on_air, get_used_relations_list
from testsuite.Wroclaw.RRM.VRF_WRO2_T07.resources.testline_preparation import get_config_dir, get_sw_release_name, \
    get_bts_id
from testsuite.Wroclaw.RRM.VRF_WRO2_T07.resources.common import backup_current_scf as backup_scf

taf_ue = rue_utils.get_library_instance('taf.ue')

l1l2 = L1L2()
tcpdump = TcpdumpSmod()
scf = scf()
atten = Attenuator(with_initialisation=False)
au = AdminUtils()
api = coam()

NRBTS_ID = tl.gnbs[0].instance_id
MRBTS_ID = tl.gnbs[0].global_bts_id

NONCA = 'NONCA'
PCELL = 'PCELL'
SCELL = 'SCELL'
MULTICELLSYNCSLOT = 'MULTICELLSYNCSLOT'
ENTRYNONNULLBUFFER = 'ENTRYNONNULLBUFFER'
SKIP_REL_ERR = False
SCF_TIMEOUT_SECONDS = 600
FIRST_CELL_ATTENUATOR_PORTS = [1, 2]
SECOND_CELL_ATTENUATOR_PORTS = [3, 4]
CONDITIONAL_RELEASE = int('SBTS24R1'[4:].replace('R', ''))
CONDITIONAL_RELEASE_2 = int('SBTS23R2'[4:].replace('R', ''))
CONDITIONAL_RELEASE_3 = int('SBTS24R3'[4:].replace('R', ''))
CONDITIONAL_RELEASE_4 = int('SBTS25R1'[4:].replace('R', ''))
CONDITIONAL_RELEASE_TTI_CLASS = int('SBTS25R2'[4:].replace('R', ''))
CONDITIONAL_RELEASE_TTI_CLASS_26R2 = int('SBTS26R2'[4:].replace('R', ''))
DRXPROFILE1_PARAMS_BELOW_24R1 = {
    'drxInactivityTimer': '80ms',
    'drxLongCycle': '160ms',
    'drxOnDurationTimer': '10ms',
    'drxRetransTimerDl': '16slot',
    'drxRetransTimerUl': '16slot',
}
DRXPROFILE1_PARAMS_FROM_24R1 = {
    'drxHarqRttTimerDl': '0symbols',
    'drxHarqRttTimerUl': '0symbols',
    'drxInactivityTimer': '80ms',
    'drxLongCycle': '160ms',
    'drxOnDurationTimer': '10ms',
    'drxRetransTimerDl': '16slot',
    'drxRetransTimerUl': '16slot'
}
CLASS_BRANCH = ['15', '18']
CLASS_25R2 = ['18', '21']
CLASS_26R2 = ['19', '22']
CLASS_TRUNK = ['28', '31', '32']


@logged_keyword
def check_preconditions_c3(cells_used_in_tc):
    bts_sw_release = int(get_sw_release_name()[4:8].replace('R', ''))
    bts_id = 51701
    nrbts_object = f'MRBTS-{bts_id}/NRBTS-{bts_id}'
    ds = DeltaStore()
    ds.initialise_delta_store()
    set_relations(ds, cells_used_in_tc, 'covBasedA1', 'dlOnly')
    ds.add_param_to_delta(
        'MRBTS-{mrbts_id}/NRBTS-{nrbts_id}'.format(mrbts_id=MRBTS_ID, nrbts_id=NRBTS_ID),
        'sCellActivationMethod', 'bufferBased')

    ds.add_param_to_delta(get_cell_dist(cells_used_in_tc[0]),
                          'sCellDeactivationTimerGNB', 'ms1280')
    ds.add_param_to_delta(get_cell_dist(cells_used_in_tc[1]),
                          'sCellDeactivationTimerGNB', 'ms1280')
    ds.add_param_to_delta(get_cell_dist(cells_used_in_tc[2]),
                          'sCellDeactivationTimerGNB', 'ms1280')

    ds.add_param_to_delta(get_cell_dist(cells_used_in_tc[0]),
                          'actPdschAtSsbSlots', 'false')
    ds.add_param_to_delta(get_cell_dist(cells_used_in_tc[1]),
                          'actPdschAtSsbSlots', 'false')
    ds.add_param_to_delta(get_cell_dist(cells_used_in_tc[2]),
                          'actPdschAtSsbSlots', 'false')

    ds.add_param_to_delta(nrbts_object + '/NRCELL-5',
                          'qRxLevMin', '-22')
    ds.add_param_to_delta(nrbts_object + '/NRCELL-6',
                          'qRxLevMin', '-22')
    ds.add_param_to_delta(nrbts_object + '/NRCELL-2',
                          'qRxLevMin', '-60')

    ds.add_param_to_delta(get_cell_dist(cells_used_in_tc[0]),
                          'actPdschRmCsirsForTracking', 'false')
    ds.add_param_to_delta(get_cell_dist(cells_used_in_tc[1]),
                          'actPdschRmCsirsForTracking', 'false')
    ds.add_param_to_delta(get_cell_dist(cells_used_in_tc[2]),
                          'actPdschRmCsirsForTracking', 'false')

    if bts_sw_release < CONDITIONAL_RELEASE_4:
        ds.add_param_to_delta('MRBTS-{mrbts_id}/NRBTS-{nrbts_id}'
                              .format(mrbts_id=MRBTS_ID, nrbts_id=NRBTS_ID),
                              'actMicroDTX', 'true')
    if bts_sw_release >= CONDITIONAL_RELEASE_4:
        ds.add_param_to_delta(get_cell_dist(cells_used_in_tc[0]),
                              'actPdschAllocAroundSsb', 'false')
        ds.add_param_to_delta(get_cell_dist(cells_used_in_tc[0]),
                              'actTrsPdschAvgCqiRatio', 'false')

    ds.add_complex_item_to_delta(get_cell_dist(cells_used_in_tc[0]), 'dtxOptimizedScheduler',
                                 dtxDelaySinceLastScheduling='0',
                                 dtxMaxRetentionDelay='10',
                                 dtxPrbThreshold='100',
                                 caSupportEnabled='false',
                                 drxSupportEnabled='false',
                                 multiCellSyncEnabled='false',
                                 drbDifferentiationEnabled='false',
                                 rlcStatusPduSupportEnabled='false')

    ds.add_complex_item_to_delta(get_cell_dist(cells_used_in_tc[1]), 'dtxOptimizedScheduler',
                                 dtxDelaySinceLastScheduling='0',
                                 dtxMaxRetentionDelay='10',
                                 dtxPrbThreshold='100',
                                 caSupportEnabled='true',
                                 drxSupportEnabled='false',
                                 multiCellSyncEnabled='false',
                                 drbDifferentiationEnabled='false',
                                 rlcStatusPduSupportEnabled='false')

    ds.add_complex_item_to_delta(get_cell_dist(cells_used_in_tc[2]), 'dtxOptimizedScheduler',
                                 dtxDelaySinceLastScheduling='0',
                                 dtxMaxRetentionDelay='10',
                                 dtxPrbThreshold='100',
                                 caSupportEnabled='true',
                                 drxSupportEnabled='false',
                                 multiCellSyncEnabled='false',
                                 drbDifferentiationEnabled='false',
                                 rlcStatusPduSupportEnabled='false')

    ds.add_param_to_delta(get_cell_dist(cells_used_in_tc[0]),
                          'actDtxOptimizedScheduler', 'false')
    ds.add_param_to_delta(get_cell_dist(cells_used_in_tc[1]),
                          'actDtxOptimizedScheduler', 'true')
    ds.add_param_to_delta(get_cell_dist(cells_used_in_tc[2]),
                          'actDtxOptimizedScheduler', 'true')

    ds.add_param_to_delta(get_cell_dist(cells_used_in_tc[0]),
                          'actEnhDtxOptimizedScheduler', 'false')
    ds.add_param_to_delta(get_cell_dist(cells_used_in_tc[1]),
                          'actEnhDtxOptimizedScheduler', 'true')
    ds.add_param_to_delta(get_cell_dist(cells_used_in_tc[2]),
                          'actEnhDtxOptimizedScheduler', 'true')

    ds.add_param_to_delta(get_cell_dist(cells_used_in_tc[0]),
                          'sCellActivationMinDataThreshold', '6000')
    ds.add_param_to_delta(get_cell_dist(cells_used_in_tc[1]),
                          'sCellActivationMinDataThreshold', '6000')
    ds.add_param_to_delta(get_cell_dist(cells_used_in_tc[2]),
                          'sCellActivationMinDataThreshold', '6000')

    nrdu_dist_name = 'MRBTS-{mrbts_id}/NRBTS-{nrbts_id}/NRDU-1'.format(mrbts_id=MRBTS_ID, nrbts_id=NRBTS_ID)
    ds.add_param_to_delta(nrdu_dist_name, 'carrierAggregationSupportList',
                          ['ca_Fr1Tdd_Sa', 'ca_Fr1Tdd_Fdd_Sa', 'ca_Fr1Tdd_Any_Sa'])
    ds.validate_scf(skip_parameter_relation_errors=SKIP_REL_ERR)
    delta = ds.collect_delta_store()
    ds.perform_delta_recommissioning(delta, skip_parameter_relation_errors=SKIP_REL_ERR)
    verify_on_air()
    blog("Preconditions fulfilled")


@logged_keyword
def check_preconditions_c6(cells_used_in_tc):
    bts_sw_release = int(get_sw_release_name()[4:8].replace('R', ''))
    ds = DeltaStore()
    ds.initialise_delta_store()
    bts_id = 51701
    nrbts_object = f'MRBTS-{bts_id}/NRBTS-{bts_id}'
    set_relations(ds, cells_used_in_tc, 'covBasedA1', 'dlOnly')
    ds.add_param_to_delta(
        'MRBTS-{mrbts_id}/NRBTS-{nrbts_id}'.format(mrbts_id=MRBTS_ID, nrbts_id=NRBTS_ID),
        'sCellActivationMethod', 'bufferBased')
    #
    ds.add_param_to_delta(get_cell_dist(cells_used_in_tc[0]),
                          'sCellDeactivationTimerGNB', 'ms1280')
    ds.add_param_to_delta(get_cell_dist(cells_used_in_tc[1]),
                          'sCellDeactivationTimerGNB', 'ms1280')
    ds.add_param_to_delta(get_cell_dist(cells_used_in_tc[2]),
                          'sCellDeactivationTimerGNB', 'ms1280')
    #
    ds.add_param_to_delta(get_cell_dist(cells_used_in_tc[0]),
                          'actPdschAtSsbSlots', 'false')
    ds.add_param_to_delta(get_cell_dist(cells_used_in_tc[1]),
                          'actPdschAtSsbSlots', 'false')
    ds.add_param_to_delta(get_cell_dist(cells_used_in_tc[2]),
                          'actPdschAtSsbSlots', 'false')
    #
    ds.add_param_to_delta(get_cell_dist(cells_used_in_tc[0]),
                          'actPdschRmCsirsForTracking', 'false')
    ds.add_param_to_delta(get_cell_dist(cells_used_in_tc[1]),
                          'actPdschRmCsirsForTracking', 'false')
    ds.add_param_to_delta(get_cell_dist(cells_used_in_tc[2]),
                          'actPdschRmCsirsForTracking', 'false')
    ds.add_param_to_delta(nrbts_object + '/NRCELL-5',
                          'qRxLevMin', '-22')
    ds.add_param_to_delta(nrbts_object + '/NRCELL-6',
                          'qRxLevMin', '-22')
    ds.add_param_to_delta(nrbts_object + '/NRCELL-2',
                          'qRxLevMin', '-60')
    if bts_sw_release < CONDITIONAL_RELEASE_4:
        ds.add_param_to_delta('MRBTS-{mrbts_id}/NRBTS-{nrbts_id}'
                              .format(mrbts_id=MRBTS_ID, nrbts_id=NRBTS_ID),
                              'actMicroDTX', 'true')
    if bts_sw_release >= CONDITIONAL_RELEASE_4:
        ds.add_param_to_delta(get_cell_dist(cells_used_in_tc[0]),
                              'actPdschAllocAroundSsb', 'false')
        ds.add_param_to_delta(get_cell_dist(cells_used_in_tc[0]),
                              'actTrsPdschAvgCqiRatio', 'false')

    ds.add_complex_item_to_delta(get_cell_dist(cells_used_in_tc[0]), 'dtxOptimizedScheduler',
                                 dtxDelaySinceLastScheduling='0',
                                 dtxMaxRetentionDelay='10',
                                 dtxPrbThreshold='100',
                                 caSupportEnabled='true',
                                 drxSupportEnabled='false',
                                 multiCellSyncEnabled='false',
                                 drbDifferentiationEnabled='false',
                                 rlcStatusPduSupportEnabled='false')

    ds.add_complex_item_to_delta(get_cell_dist(cells_used_in_tc[1]), 'dtxOptimizedScheduler',
                                 dtxDelaySinceLastScheduling='0',
                                 dtxMaxRetentionDelay='10',
                                 dtxPrbThreshold='100',
                                 caSupportEnabled='false',
                                 drxSupportEnabled='false',
                                 multiCellSyncEnabled='false',
                                 drbDifferentiationEnabled='false',
                                 rlcStatusPduSupportEnabled='false')

    ds.add_complex_item_to_delta(get_cell_dist(cells_used_in_tc[2]), 'dtxOptimizedScheduler',
                                 dtxDelaySinceLastScheduling='0',
                                 dtxMaxRetentionDelay='10',
                                 dtxPrbThreshold='100',
                                 caSupportEnabled='false',
                                 drxSupportEnabled='false',
                                 multiCellSyncEnabled='false',
                                 drbDifferentiationEnabled='false',
                                 rlcStatusPduSupportEnabled='false')

    ds.add_param_to_delta(get_cell_dist(cells_used_in_tc[0]),
                          'actDtxOptimizedScheduler', 'true')
    ds.add_param_to_delta(get_cell_dist(cells_used_in_tc[1]),
                          'actDtxOptimizedScheduler', 'false')
    ds.add_param_to_delta(get_cell_dist(cells_used_in_tc[2]),
                          'actDtxOptimizedScheduler', 'false')

    ds.add_param_to_delta(get_cell_dist(cells_used_in_tc[0]),
                          'actEnhDtxOptimizedScheduler', 'true')
    ds.add_param_to_delta(get_cell_dist(cells_used_in_tc[1]),
                          'actEnhDtxOptimizedScheduler', 'false')
    ds.add_param_to_delta(get_cell_dist(cells_used_in_tc[2]),
                          'actEnhDtxOptimizedScheduler', 'false')

    ds.add_param_to_delta(get_cell_dist(cells_used_in_tc[0]),
                          'sCellActivationMinDataThreshold', '6000')
    ds.add_param_to_delta(get_cell_dist(cells_used_in_tc[1]),
                          'sCellActivationMinDataThreshold', '6000')
    ds.add_param_to_delta(get_cell_dist(cells_used_in_tc[2]),
                          'sCellActivationMinDataThreshold', '6000')

    nrdu_dist_name = 'MRBTS-{mrbts_id}/NRBTS-{nrbts_id}/NRDU-1'.format(mrbts_id=MRBTS_ID, nrbts_id=NRBTS_ID)
    ds.add_param_to_delta(nrdu_dist_name, 'carrierAggregationSupportList',
                          ['ca_Fr1Tdd_Sa', 'ca_Fr1Tdd_Fdd_Sa', 'ca_Fr1Tdd_Any_Sa'])
    ds.validate_scf(skip_parameter_relation_errors=SKIP_REL_ERR)
    delta = ds.collect_delta_store()
    ds.perform_delta_recommissioning(delta, skip_parameter_relation_errors=SKIP_REL_ERR)
    verify_on_air()
    blog("Preconditions fulfilled")


@logged_keyword
def check_preconditions_9333_d1(cells_used_in_tc):
    bts_sw_release = int(get_sw_release_name()[4:8].replace('R', ''))
    ds = DeltaStore()
    ds.initialise_delta_store()

    ds.add_param_to_delta('MRBTS-{mrbts_id}/NRBTS-{nrbts_id}/NRPMRNL-1'
                          .format(mrbts_id=MRBTS_ID, nrbts_id=NRBTS_ID),
                          'miNrCellUtilization', '5min')

    ds.add_param_to_delta(get_cell_dist(cells_used_in_tc[0]),
                          'actPdschAtSsbSlots', 'false')

    ds.add_param_to_delta(get_cell_dist(cells_used_in_tc[0]),
                          'actPdschRmCsirsForTracking', 'false')
    if bts_sw_release < CONDITIONAL_RELEASE_4:
        ds.add_param_to_delta('MRBTS-{mrbts_id}/NRBTS-{nrbts_id}'
                              .format(mrbts_id=MRBTS_ID, nrbts_id=NRBTS_ID),
                              'actMicroDTX', 'true')
    if bts_sw_release >= CONDITIONAL_RELEASE_4:
        ds.add_param_to_delta(get_cell_dist(cells_used_in_tc[0]),
                              'actPdschAllocAroundSsb', 'false')

    ds.add_complex_item_to_delta(get_cell_dist(cells_used_in_tc[0]), 'dtxOptimizedScheduler',
                                 dtxDelaySinceLastScheduling='0',
                                 dtxMaxRetentionDelay='50',
                                 dtxPrbThreshold='80',
                                 caSupportEnabled='false',
                                 drxSupportEnabled='true',
                                 multiCellSyncEnabled='false',
                                 drbDifferentiationEnabled='false',
                                 rlcStatusPduSupportEnabled='false')
    if CONDITIONAL_RELEASE_2 < bts_sw_release < CONDITIONAL_RELEASE:
        ds.add_complex_item_to_delta(get_cell_dist(cells_used_in_tc[0]), 'drxProfile1', **DRXPROFILE1_PARAMS_BELOW_24R1)
        ds.add_param_to_delta(get_cell_dist(cells_used_in_tc[0]),
                              'actDtxOptimizedScheduler', 'true')

        ds.add_param_to_delta(get_cell_dist(cells_used_in_tc[0]),
                              'actCDrx', 'true')

        ds.add_param_to_delta(get_cell_dist(cells_used_in_tc[0]),
                              'actEnhDtxOptimizedScheduler', 'true')
    elif bts_sw_release == CONDITIONAL_RELEASE_2:
        ds.add_complex_item_to_delta(get_cell_dist(cells_used_in_tc[0]), 'drxProfile1', **DRXPROFILE1_PARAMS_BELOW_24R1)

        ds.add_param_to_delta(get_cell_dist(cells_used_in_tc[0]),
                              'actDtxOptimizedScheduler', 'true')

        ds.add_param_to_delta(get_cell_dist(cells_used_in_tc[0]),
                              'actCDrx', 'true')

        ds.add_param_to_delta(get_cell_dist(cells_used_in_tc[0]),
                              'actEnhDtxOptimizedScheduler', 'false')
    elif CONDITIONAL_RELEASE < bts_sw_release < CONDITIONAL_RELEASE_3:
        ds.add_complex_item_to_delta(get_cell_dist(cells_used_in_tc[0]), 'drxProfile1', **DRXPROFILE1_PARAMS_FROM_24R1)

        ds.add_param_to_delta(get_cell_dist(cells_used_in_tc[0]),
                              'actDtxOptimizedScheduler', 'true')

        ds.add_param_to_delta(get_cell_dist(cells_used_in_tc[0]),
                              'actCDrx', 'true')

        ds.add_param_to_delta(get_cell_dist(cells_used_in_tc[0]),
                              'actEnhDtxOptimizedScheduler', 'true')
    elif bts_sw_release >= CONDITIONAL_RELEASE_3:
        ds.add_param_to_delta("MRBTS-{}/NRBTS-{}/NRDRX-1".format(MRBTS_ID, NRBTS_ID), 'drxHarqRttTimerDl', '0symbols')
        ds.add_param_to_delta("MRBTS-{}/NRBTS-{}/NRDRX-1".format(MRBTS_ID, NRBTS_ID), 'drxHarqRttTimerUl', '0symbols')
        ds.add_param_to_delta("MRBTS-{}/NRBTS-{}/NRDRX-1".format(MRBTS_ID, NRBTS_ID), 'drxInactivityTimer', '80ms')
        ds.add_param_to_delta("MRBTS-{}/NRBTS-{}/NRDRX-1".format(MRBTS_ID, NRBTS_ID), 'drxLongCycle', '160ms')
        ds.add_param_to_delta("MRBTS-{}/NRBTS-{}/NRDRX-1".format(MRBTS_ID, NRBTS_ID), 'drxOnDurationTimer', '10ms')
        ds.add_param_to_delta("MRBTS-{}/NRBTS-{}/NRDRX-1".format(MRBTS_ID, NRBTS_ID), 'drxPriority', '32')
        ds.add_param_to_delta("MRBTS-{}/NRBTS-{}/NRDRX-1".format(MRBTS_ID, NRBTS_ID), 'drxRetransTimerDl', '16slot')
        ds.add_param_to_delta("MRBTS-{}/NRBTS-{}/NRDRX-1".format(MRBTS_ID, NRBTS_ID), 'drxRetransTimerUl', '16slot')
        ds.add_param_to_delta(get_cell_dist(cells_used_in_tc[0]),
                              'actDtxOptimizedScheduler', 'true')

        ds.add_param_to_delta(get_cell_dist(cells_used_in_tc[0]),
                              'actCDrx', 'true')

        ds.add_param_to_delta(get_cell_dist(cells_used_in_tc[0]),
                              'actEnhDtxOptimizedScheduler', 'true')

    ds.validate_scf(skip_parameter_relation_errors=SKIP_REL_ERR)
    delta = ds.collect_delta_store()
    ds.perform_delta_recommissioning(delta, skip_parameter_relation_errors=SKIP_REL_ERR)
    verify_on_air()
    time.sleep(30)
    blog("Preconditions fulfilled")


@logged_keyword
def check_preconditions_9333_f(cells_used_in_tc):
    bts_sw_release = int(get_sw_release_name()[4:8].replace('R', ''))
    ds = DeltaStore()
    ds.initialise_delta_store()

    ds.add_param_to_delta('MRBTS-{mrbts_id}/NRBTS-{nrbts_id}/NRPMRNL-1'
                          .format(mrbts_id=MRBTS_ID, nrbts_id=NRBTS_ID),
                          'miNrCellUtilization', '5min')

    ds.add_param_to_delta(get_cell_dist(cells_used_in_tc[0]),
                          'actPdschAtSsbSlots', 'false')

    ds.add_param_to_delta(get_cell_dist(cells_used_in_tc[0]),
                          'actPdschRmCsirsForTracking', 'false')
    if bts_sw_release >= CONDITIONAL_RELEASE_4:
        ds.add_param_to_delta(get_cell_dist(cells_used_in_tc[0]),
                              'actPdschAllocAroundSsb', 'false')

    if bts_sw_release < CONDITIONAL_RELEASE_4:
        ds.add_param_to_delta('MRBTS-{mrbts_id}/NRBTS-{nrbts_id}'
                              .format(mrbts_id=MRBTS_ID, nrbts_id=NRBTS_ID),
                              'actMicroDTX', 'true')

    ds.add_complex_item_to_delta(get_cell_dist(cells_used_in_tc[0]), 'dtxOptimizedScheduler',
                                 dtxDelaySinceLastScheduling='0',
                                 dtxMaxRetentionDelay='50',
                                 dtxPrbThreshold='80',
                                 caSupportEnabled='false',
                                 drxSupportEnabled='true',
                                 multiCellSyncEnabled='false',
                                 drbDifferentiationEnabled='false',
                                 rlcStatusPduSupportEnabled='true')

    if CONDITIONAL_RELEASE_2 < bts_sw_release < CONDITIONAL_RELEASE:
        ds.add_complex_item_to_delta(get_cell_dist(cells_used_in_tc[0]), 'drxProfile1', **DRXPROFILE1_PARAMS_BELOW_24R1)
        ds.add_param_to_delta(get_cell_dist(cells_used_in_tc[0]),
                              'actDtxOptimizedScheduler', 'true')

        ds.add_param_to_delta(get_cell_dist(cells_used_in_tc[0]),
                              'actCDrx', 'true')

        ds.add_param_to_delta(get_cell_dist(cells_used_in_tc[0]),
                              'actEnhDtxOptimizedScheduler', 'true')
    elif bts_sw_release == CONDITIONAL_RELEASE_2:
        ds.add_complex_item_to_delta(get_cell_dist(cells_used_in_tc[0]), 'drxProfile1', **DRXPROFILE1_PARAMS_BELOW_24R1)

        ds.add_param_to_delta(get_cell_dist(cells_used_in_tc[0]),
                              'actDtxOptimizedScheduler', 'true')

        ds.add_param_to_delta(get_cell_dist(cells_used_in_tc[0]),
                              'actCDrx', 'true')

        ds.add_param_to_delta(get_cell_dist(cells_used_in_tc[0]),
                              'actEnhDtxOptimizedScheduler', 'false')
    elif CONDITIONAL_RELEASE < bts_sw_release < CONDITIONAL_RELEASE_3:
        ds.add_complex_item_to_delta(get_cell_dist(cells_used_in_tc[0]), 'drxProfile1', **DRXPROFILE1_PARAMS_FROM_24R1)

        ds.add_param_to_delta(get_cell_dist(cells_used_in_tc[0]),
                              'actDtxOptimizedScheduler', 'true')

        ds.add_param_to_delta(get_cell_dist(cells_used_in_tc[0]),
                              'actCDrx', 'true')

        ds.add_param_to_delta(get_cell_dist(cells_used_in_tc[0]),
                              'actEnhDtxOptimizedScheduler', 'true')
    elif bts_sw_release >= CONDITIONAL_RELEASE_3:
        ds.add_param_to_delta("MRBTS-{}/NRBTS-{}/NRDRX-1".format(MRBTS_ID, NRBTS_ID), 'drxHarqRttTimerDl', '0symbols')
        ds.add_param_to_delta("MRBTS-{}/NRBTS-{}/NRDRX-1".format(MRBTS_ID, NRBTS_ID), 'drxHarqRttTimerUl', '0symbols')
        ds.add_param_to_delta("MRBTS-{}/NRBTS-{}/NRDRX-1".format(MRBTS_ID, NRBTS_ID), 'drxInactivityTimer', '80ms')
        ds.add_param_to_delta("MRBTS-{}/NRBTS-{}/NRDRX-1".format(MRBTS_ID, NRBTS_ID), 'drxLongCycle', '160ms')
        ds.add_param_to_delta("MRBTS-{}/NRBTS-{}/NRDRX-1".format(MRBTS_ID, NRBTS_ID), 'drxOnDurationTimer', '10ms')
        ds.add_param_to_delta("MRBTS-{}/NRBTS-{}/NRDRX-1".format(MRBTS_ID, NRBTS_ID), 'drxPriority', '32')
        ds.add_param_to_delta("MRBTS-{}/NRBTS-{}/NRDRX-1".format(MRBTS_ID, NRBTS_ID), 'drxRetransTimerDl', '16slot')
        ds.add_param_to_delta("MRBTS-{}/NRBTS-{}/NRDRX-1".format(MRBTS_ID, NRBTS_ID), 'drxRetransTimerUl', '16slot')
        ds.add_param_to_delta(get_cell_dist(cells_used_in_tc[0]),
                              'actDtxOptimizedScheduler', 'true')

        ds.add_param_to_delta(get_cell_dist(cells_used_in_tc[0]),
                              'actCDrx', 'true')

        ds.add_param_to_delta(get_cell_dist(cells_used_in_tc[0]),
                              'actEnhDtxOptimizedScheduler', 'true')

    ds.validate_scf(skip_parameter_relation_errors=SKIP_REL_ERR)
    delta = ds.collect_delta_store()
    ds.perform_delta_recommissioning(delta, skip_parameter_relation_errors=SKIP_REL_ERR)
    verify_on_air()
    time.sleep(30)
    blog("Preconditions fulfilled")


@logged_keyword
def check_preconditions_9333_g(cells_used_in_tc, CNI_test=False):
    bts_sw_release = int(get_sw_release_name()[4:8].replace('R', ''))
    ds = DeltaStore()
    ds.initialise_delta_store()

    ds.add_param_to_delta('MRBTS-{mrbts_id}/NRBTS-{nrbts_id}/NRPMRNL-1'
                          .format(mrbts_id=MRBTS_ID, nrbts_id=NRBTS_ID),
                          'miNrCellUtilization', '5min')

    ds.add_param_to_delta(get_cell_dist(cells_used_in_tc[0]),
                          'actPdschAtSsbSlots', 'true')

    ds.add_param_to_delta(get_cell_dist(cells_used_in_tc[0]),
                          'actPdschRmCsirsForTracking', 'false')

    if CNI_test:
        ds.add_param_to_delta('MRBTS-{mrbts_id}/NRBTS-{nrbts_id}/NRPMRNL-1'
                              .format(mrbts_id=MRBTS_ID, nrbts_id=NRBTS_ID),
                              'miNrRSUP', '5min')
        ds.add_complex_item_to_delta(get_cell_dist(cells_used_in_tc[0]), 'dtxOptimizedScheduler',
                                     dtxDelaySinceLastScheduling='0',
                                     dtxMaxRetentionDelay='0',
                                     dtxPrbThreshold='80',
                                     caSupportEnabled='false',
                                     drxSupportEnabled='true',
                                     multiCellSyncEnabled='false',
                                     drbDifferentiationEnabled='true',
                                     rlcStatusPduSupportEnabled='true')
    else:
        ds.add_complex_item_to_delta(get_cell_dist(cells_used_in_tc[0]), 'dtxOptimizedScheduler',
                                     dtxDelaySinceLastScheduling='0',
                                     dtxMaxRetentionDelay='50',
                                     dtxPrbThreshold='80',
                                     caSupportEnabled='false',
                                     drxSupportEnabled='true',
                                     multiCellSyncEnabled='false',
                                     drbDifferentiationEnabled='true',
                                     rlcStatusPduSupportEnabled='true')
    if bts_sw_release < CONDITIONAL_RELEASE_4:
        ds.add_param_to_delta('MRBTS-{mrbts_id}/NRBTS-{nrbts_id}'
                              .format(mrbts_id=MRBTS_ID, nrbts_id=NRBTS_ID),
                              'actMicroDTX', 'true')
    else:
        ds.add_param_to_delta(get_cell_dist(cells_used_in_tc[0]),
                              'actPdschAllocAroundSsb', 'true')
    if bts_sw_release < CONDITIONAL_RELEASE:
        ds.add_complex_item_to_delta(get_cell_dist(cells_used_in_tc[0]), 'drxProfile1', **DRXPROFILE1_PARAMS_BELOW_24R1)
    elif CONDITIONAL_RELEASE < bts_sw_release < CONDITIONAL_RELEASE_3:
        ds.add_complex_item_to_delta(get_cell_dist(cells_used_in_tc[0]), 'drxProfile1', **DRXPROFILE1_PARAMS_FROM_24R1)
    elif bts_sw_release >= CONDITIONAL_RELEASE_3:
        ds.add_param_to_delta("MRBTS-{}/NRBTS-{}/NRDRX-1".format(MRBTS_ID, NRBTS_ID), 'drxHarqRttTimerDl', '0symbols')
        ds.add_param_to_delta("MRBTS-{}/NRBTS-{}/NRDRX-1".format(MRBTS_ID, NRBTS_ID), 'drxHarqRttTimerUl', '0symbols')
        ds.add_param_to_delta("MRBTS-{}/NRBTS-{}/NRDRX-1".format(MRBTS_ID, NRBTS_ID), 'drxInactivityTimer', '80ms')
        ds.add_param_to_delta("MRBTS-{}/NRBTS-{}/NRDRX-1".format(MRBTS_ID, NRBTS_ID), 'drxLongCycle', '160ms')
        ds.add_param_to_delta("MRBTS-{}/NRBTS-{}/NRDRX-1".format(MRBTS_ID, NRBTS_ID), 'drxOnDurationTimer', '10ms')
        ds.add_param_to_delta("MRBTS-{}/NRBTS-{}/NRDRX-1".format(MRBTS_ID, NRBTS_ID), 'drxPriority', '32')
        ds.add_param_to_delta("MRBTS-{}/NRBTS-{}/NRDRX-1".format(MRBTS_ID, NRBTS_ID), 'drxRetransTimerDl', '16slot')
        ds.add_param_to_delta("MRBTS-{}/NRBTS-{}/NRDRX-1".format(MRBTS_ID, NRBTS_ID), 'drxRetransTimerUl', '16slot')

    ds.add_param_to_delta(get_cell_dist(cells_used_in_tc[0]),
                          'actDtxOptimizedScheduler', 'true')

    ds.add_param_to_delta(get_cell_dist(cells_used_in_tc[0]),
                          'actCDrx', 'true')

    ds.add_param_to_delta(get_cell_dist(cells_used_in_tc[0]),
                          'actEnhDtxOptimizedScheduler', 'true')

    ds.add_param_to_delta(get_cell_dist(cells_used_in_tc[0]),
                          'actSib1ForNsaCell', 'true')

    ds.add_param_to_delta(get_cell_dist(cells_used_in_tc[0]),
                          'actFdmInitialDedicatedFdd', 'true')
    if CNI_test:
        ds.add_param_to_delta('MRBTS-{mrbts_id}/NRBTS-{nrbts_id}/NRDRB-13'.format(mrbts_id=MRBTS_ID, nrbts_id=NRBTS_ID),
                              'dtxDelaySinceLastScheduling', '0')
        ds.add_param_to_delta('MRBTS-{mrbts_id}/NRBTS-{nrbts_id}/NRDRB-13'.format(mrbts_id=MRBTS_ID, nrbts_id=NRBTS_ID),
                              'dtxMaxRetentionDelay', '50')
        ds.add_param_to_delta('MRBTS-{mrbts_id}/NRBTS-{nrbts_id}/NRDRB-14'.format(mrbts_id=MRBTS_ID, nrbts_id=NRBTS_ID),
                              'dtxDelaySinceLastScheduling', '0')
        ds.add_param_to_delta('MRBTS-{mrbts_id}/NRBTS-{nrbts_id}/NRDRB-14'.format(mrbts_id=MRBTS_ID, nrbts_id=NRBTS_ID),
                              'dtxMaxRetentionDelay', '0')
    ds.validate_scf(skip_parameter_relation_errors=SKIP_REL_ERR)
    delta = ds.collect_delta_store()
    ds.perform_delta_recommissioning(delta, skip_parameter_relation_errors=SKIP_REL_ERR)
    verify_on_air()
    time.sleep(30)
    blog("Preconditions fulfilled")


@logged_keyword
def check_preconditions_9333_w(cells_used_in_tc):
    bts_sw_release = int(get_sw_release_name()[4:8].replace('R', ''))
    ds = DeltaStore()
    ds.initialise_delta_store()

    ds.add_param_to_delta('MRBTS-{mrbts_id}/NRBTS-{nrbts_id}/NRPMRNL-1'
                          .format(mrbts_id=MRBTS_ID, nrbts_id=NRBTS_ID),
                          'miNrCellUtilization', '5min')

    ds.add_param_to_delta(get_cell_dist(cells_used_in_tc[0]),
                          'actPdschAtSsbSlots', 'false')

    ds.add_param_to_delta(get_cell_dist(cells_used_in_tc[0]),
                          'actPdschRmCsirsForTracking', 'false')

    if bts_sw_release < CONDITIONAL_RELEASE_4:
        ds.add_param_to_delta('MRBTS-{mrbts_id}/NRBTS-{nrbts_id}'
                              .format(mrbts_id=MRBTS_ID, nrbts_id=NRBTS_ID),
                              'actMicroDTX', 'true')

    ds.add_complex_item_to_delta(get_cell_dist(cells_used_in_tc[0]), 'dtxOptimizedScheduler',
                                 dtxDelaySinceLastScheduling='0',
                                 dtxMaxRetentionDelay='50',
                                 dtxPrbThreshold='80',
                                 caSupportEnabled='true',
                                 drxSupportEnabled='true',
                                 multiCellSyncEnabled='true',
                                 drbDifferentiationEnabled='true',
                                 rlcStatusPduSupportEnabled='true',
                                 dtxRoundingFactor='3',
                                 dtxRoundingOffset='0'
                                 )

    if bts_sw_release < CONDITIONAL_RELEASE:
        ds.add_complex_item_to_delta(get_cell_dist(cells_used_in_tc[0]), 'drxProfile1', **DRXPROFILE1_PARAMS_BELOW_24R1)
    elif CONDITIONAL_RELEASE < bts_sw_release < CONDITIONAL_RELEASE_3:
        ds.add_complex_item_to_delta(get_cell_dist(cells_used_in_tc[0]), 'drxProfile1', **DRXPROFILE1_PARAMS_FROM_24R1)
    elif bts_sw_release >= CONDITIONAL_RELEASE_3:
        ds.add_param_to_delta("MRBTS-{}/NRBTS-{}/NRDRX-1".format(MRBTS_ID, NRBTS_ID), 'drxHarqRttTimerDl', '0symbols')
        ds.add_param_to_delta("MRBTS-{}/NRBTS-{}/NRDRX-1".format(MRBTS_ID, NRBTS_ID), 'drxHarqRttTimerUl', '0symbols')
        ds.add_param_to_delta("MRBTS-{}/NRBTS-{}/NRDRX-1".format(MRBTS_ID, NRBTS_ID), 'drxInactivityTimer', '80ms')
        ds.add_param_to_delta("MRBTS-{}/NRBTS-{}/NRDRX-1".format(MRBTS_ID, NRBTS_ID), 'drxLongCycle', '160ms')
        ds.add_param_to_delta("MRBTS-{}/NRBTS-{}/NRDRX-1".format(MRBTS_ID, NRBTS_ID), 'drxOnDurationTimer', '10ms')
        ds.add_param_to_delta("MRBTS-{}/NRBTS-{}/NRDRX-1".format(MRBTS_ID, NRBTS_ID), 'drxPriority', '32')
        ds.add_param_to_delta("MRBTS-{}/NRBTS-{}/NRDRX-1".format(MRBTS_ID, NRBTS_ID), 'drxRetransTimerDl', '16slot')
        ds.add_param_to_delta("MRBTS-{}/NRBTS-{}/NRDRX-1".format(MRBTS_ID, NRBTS_ID), 'drxRetransTimerUl', '16slot')

    ds.add_param_to_delta(get_cell_dist(cells_used_in_tc[0]),
                          'actDtxOptimizedScheduler', 'true')

    ds.add_param_to_delta(get_cell_dist(cells_used_in_tc[0]),
                          'actCDrx', 'true')

    ds.add_param_to_delta(get_cell_dist(cells_used_in_tc[0]),
                          'actEnhDtxOptimizedScheduler', 'true')

    ds.add_param_to_delta(get_cell_dist(cells_used_in_tc[0]),
                          'actSib1ForNsaCell', 'true')

    ds.add_param_to_delta(get_cell_dist(cells_used_in_tc[0]),
                          'actFdmInitialDedicatedFdd', 'true')

    ds.validate_scf(skip_parameter_relation_errors=SKIP_REL_ERR)
    delta = ds.collect_delta_store()
    ds.perform_delta_recommissioning(delta, skip_parameter_relation_errors=SKIP_REL_ERR)
    verify_on_air()
    time.sleep(30)
    blog("Preconditions fulfilled")


@logged_keyword
def activate_actproactuischeduling(cells_used_in_tc):
    ds = DeltaStore()
    ds.initialise_delta_store()

    ds.add_param_to_delta(get_cell_dist(cells_used_in_tc[0]),
                          'actProactUlScheduling', 'true')

    ds.validate_scf(skip_parameter_relation_errors=SKIP_REL_ERR)
    delta = ds.collect_delta_store()
    ds.perform_delta_recommissioning(delta, skip_parameter_relation_errors=SKIP_REL_ERR)
    verify_on_air()
    time.sleep(30)
    blog("actProactUlScheduling activated.")


@logged_keyword
def deactivate_actproactuischeduling(cells_used_in_tc):
    ds = DeltaStore()
    ds.initialise_delta_store()

    ds.add_param_to_delta(get_cell_dist(cells_used_in_tc[0]),
                          'actProactUlScheduling', 'false')

    ds.validate_scf(skip_parameter_relation_errors=SKIP_REL_ERR)
    delta = ds.collect_delta_store()
    ds.perform_delta_recommissioning(delta, skip_parameter_relation_errors=SKIP_REL_ERR)
    verify_on_air()
    time.sleep(30)
    blog("actProactUlScheduling deactivated.")


@logged_keyword
def lock_unused_cells(cells_to_lock):
    blog("lock_unused_cells() is deprecated, use admin_utils' lock_cells() instead.")
    au.lock_cells(cells_to_lock)


@logged_keyword
def resolve_two_cells_scf_path():
    config_dir = get_config_dir()
    branch = get_sw_release_name()
    rat = ''
    try:
        rat = str(get_bts_id())[0]
    except Exception as e:
        blog("Error {} occured during getting bts id".format(e), level='ERROR')
        pass
    rat = rat if rat in ['4', '5'] else '5'
    file_name = '{}_{}_two_cells_{}G.xml'.format(socket.gethostname().replace('-', '_'), branch, rat)
    filepath = "{config}/{branch}/{file}".format(config=config_dir, branch=branch, file=file_name)
    assert os.path.isfile(filepath), "FileNotFoundError: [Errno 2] No such file or directory: {}".format(filepath)
    return filepath


@logged_keyword
def check_drx_active_and_sleep_counters(cell_id=['1']):
    cell_id = cell_id if isinstance(cell_id, list) else [str(cell_id)]
    pm_counters_path = pm.collect_counters()
    pm.check_counter_greater_than_x(pi_dir=pm_counters_path, counter_name='M55308C11001',
                                    object_id=cell_id, x=100, n_last_values=2)
    pm.check_counter_greater_than_x(pi_dir=pm_counters_path, counter_name='M55308C11002',
                                    object_id=cell_id, x=100, n_last_values=2)


@logged_keyword
def check_dtx_optimized_counter(cell_id=['1']):
    blog("Checking counters...")
    cell_id = cell_id if isinstance(cell_id, list) else [str(cell_id)]
    pm_counters_path = pm.collect_counters()
    pm.check_counter_greater_than_x(pi_dir=pm_counters_path, counter_name='M55308C33000',
                                    object_id=cell_id, x=0, n_last_values=2)


@logged_keyword
def check_dtx_no_bundling_counter(cell_id=['1']):
    cell_id = cell_id if isinstance(cell_id, list) else [str(cell_id)]
    pm_counters_path = pm.collect_counters()
    pm.check_counter_greater_than_x(pi_dir=pm_counters_path, counter_name='M55308C33001',
                                    object_id=cell_id, x=0, n_last_values=2)


@logged_keyword
def check_ue_multiplexed_with_si_rnti_for_c_rnti_in_dl_slot(cell_id=['1']):
    cell_id = cell_id if isinstance(cell_id, list) else [str(cell_id)]
    pm_counters_path = pm.collect_counters()
    pm.check_counter_greater_than_x(pi_dir=pm_counters_path, counter_name='M55308C00036',
                                    object_id=cell_id, x=0, n_last_values=2)


@logged_keyword
def check_sum_of_times_when_ue_multiplexed_with_si_rnti_for_c_rnti_in_dl_slot(cell_id=['1']):
    cell_id = cell_id if isinstance(cell_id, list) else [str(cell_id)]
    pm_counters_path = pm.collect_counters()
    pm.check_counter_greater_than_x(pi_dir=pm_counters_path, counter_name='M55308C00037',
                                    object_id=cell_id, x=0, n_last_values=2)


@logged_keyword
def check_msg_fragment_in_pcap_log(pcap_file, protocol_filter, msg_name, field_name, correct_value):
    msg_value = ""
    msg_found = False
    correct_value_found = False
    relevant_frames = log_finder(pcap_file, protocol_filter, msg_name)
    for frame in relevant_frames:
        try:
            msg_value = frame.find(field_name).first()['val']
        except BaseException:
            pass
        if msg_value:
            blog('{} found. Checking value...'.format(field_name))
            msg_found = True
            if correct_value in str(msg_value):
                blog("{0} = {1}. Correct value.".format(field_name, msg_value))
                correct_value_found = True
                break
    if not msg_found:
        assert False, '{} NOT found!'.format(field_name)
    if not correct_value_found:
        assert False, 'Incorrect {0} value: {1}. ' \
                      'Correct value: {2}'.format(field_name, msg_value, correct_value)


@logged_keyword
def check_sib(pcap_file):
    bts_sw_release = int(get_sw_release_name()[4:8].replace('R', ''))
    blog(bts_sw_release)
    if bts_sw_release >= 252:
        check_msg_fragment_in_pcap_log(pcap_file,
                                       protocol_filter='nr-rrc.sib_TypeAndInfo_item',
                                       msg_name='dldata_pdschpayloadtbsendreql1sw',
                                       field_name='sib-TypeAndInfo item*',
                                       correct_value='sib3')
    else:
        check_msg_fragment_in_pcap_log(pcap_file,
                                       protocol_filter='nr-rrc.sib_TypeAndInfo_item',
                                       msg_name='dldata_pdschpayloadtbsendreq',
                                       field_name='sib-TypeAndInfo item*',
                                       correct_value='sib3')


@logged_keyword
def check_drb(pcap_file):
    bts_sw_release = int(get_sw_release_name()[4:8].replace('R', ''))
    blog(bts_sw_release)
    if bts_sw_release >= 252:
        check_msg_fragment_in_pcap_log(pcap_file,
                                       protocol_filter='rlc-nr',
                                       msg_name='uldata_puschreceiveresplol1sw',
                                       field_name='*Bearer Type*',
                                       correct_value='DRB (5)')
    else:
        check_msg_fragment_in_pcap_log(pcap_file,
                                       protocol_filter='rlc-nr',
                                       msg_name='uldata_puschreceiveresplo',
                                       field_name='*Bearer Type*',
                                       correct_value='DRB (5)')


@logged_keyword
@wait_until_function_succeeds(retry_time_in_seconds=SCF_TIMEOUT_SECONDS, retry_interval_in_seconds=30)
def scf_commissioning(scf):
    au = AdminUtils()
    au.perform_commissioning(bts_id=MRBTS_ID, scf_file=scf, skip_parameter_relation_errors=SKIP_REL_ERR)
    au.wait_for_all_cells_on_air_state()
    time.sleep(60)


@logged_keyword
def set_attenuation_to_first_cell(attenuation_value=90):
    atten.initialise_attenuator()
    atten.set_attenuation(value_string=attenuation_value, ports=FIRST_CELL_ATTENUATOR_PORTS)
    atten.set_attenuation(value_string=0, ports=SECOND_CELL_ATTENUATOR_PORTS)


@logged_keyword
def set_attenuation_to_second_cell(attenuation_value=30):
    atten.initialise_attenuator()
    atten.set_attenuation(value_string=attenuation_value, ports=SECOND_CELL_ATTENUATOR_PORTS)
    atten.set_attenuation(value_string=0, ports=FIRST_CELL_ATTENUATOR_PORTS)


@logged_keyword
def nullify_attenuation_on_both_cells():
    atten.initialise_attenuator()
    atten.set_attenuation(value_string=0, ports=FIRST_CELL_ATTENUATOR_PORTS + SECOND_CELL_ATTENUATOR_PORTS)


@logged_keyword
def nullify_attenuation_on_all_cells():
    atten.initialise_attenuator()
    atten.nullify_attenuation_on_all_ports()


@logged_keyword
def set_relations(ds_obj, cells_used_in_TC, sCellAdditionMethod, sCellOperationalMode):
    relations_available = sorted(get_all_cells_relations_dist_list())
    relations_used_in_tc = get_used_relations_list(cells_used_in_TC)
    relations_to_configure = []
    relations_to_delete = []
    for relation in relations_available:
        if relation in relations_used_in_tc:
            relations_to_configure.append(relation)
        else:
            relations_to_delete.append(relation)

    for relation in list(set(relations_to_configure)):
        if "NRREL-{}".format(tl.cell_with_no_CC) in relation or "NRCELL-{}".format(tl.cell_with_no_CC) in relation:
            relations_to_configure.remove(relation)
            relations_to_delete.append(relation)

    for relation in list(set(relations_to_delete)):
        if relation in list(set(relations_to_configure)):
            relations_to_delete.remove(relation)

    for relation in list(set(relations_to_delete)):
        ds_obj.add_param_to_delta_to_delete_it(relation, 'sCellAdditionMethod')
    for relation in list(set(relations_to_configure)):
        ds_obj.add_param_to_delta(relation, 'sCellAdditionMethod', sCellAdditionMethod)

    for relation in list(set(relations_to_delete)):
        ds_obj.add_param_to_delta_to_delete_it(relation, 'sCellOperationalMode')
    for relation in list(set(relations_to_configure)):
        ds_obj.add_param_to_delta(relation, 'sCellOperationalMode', sCellOperationalMode)


def check_optimized_dtx_for_scell_activated(tti_logs, rnti):
    blog('Checking optimized DTX for SCell activated...')

    all_dlPreSchedData = extract_dl_pre_sched_data_from_tti(tti_logs, rnti)
    all_dlFdSchedData = extract_dl_fd_sched_data_from_tti(tti_logs, rnti)

    # --- SW version ---
    sw_name = get_sw_release_name()
    bts_sw_release = int(sw_name[4:8].replace('R', ''))
    blog(f'SW release name: {sw_name}, parsed: {bts_sw_release}')

    # --- Expected class selection ---
    if bts_sw_release < CONDITIONAL_RELEASE_TTI_CLASS:
        DTX_OPTIMIZED_DRB_TRAFFIC_TTI = [CLASS_BRANCH[1]]
        source = 'CLASS_BRANCH'
    elif bts_sw_release == CONDITIONAL_RELEASE_TTI_CLASS:
        DTX_OPTIMIZED_DRB_TRAFFIC_TTI = [CLASS_25R2[1]]
        source = 'CLASS_25R2'
    elif CONDITIONAL_RELEASE_TTI_CLASS_26R2 > bts_sw_release > CONDITIONAL_RELEASE_TTI_CLASS:
        DTX_OPTIMIZED_DRB_TRAFFIC_TTI = [CLASS_26R2[1]]
        source = 'CLASS_26R2'
    else:
        DTX_OPTIMIZED_DRB_TRAFFIC_TTI = [CLASS_TRUNK[1]]
        source = 'CLASS_TRUNK'

    blog(f'Expected DTX class ({source}): {DTX_OPTIMIZED_DRB_TRAFFIC_TTI}')

    # --- Debug highestClassPriority ---
    highest_values = [msg.get('highestClassPriority') for msg in all_dlPreSchedData]
    blog(f'All highestClassPriority values: {highest_values}')

    invalid_highest = [
        msg for msg in all_dlPreSchedData
        if msg.get('highestClassPriority') not in DTX_OPTIMIZED_DRB_TRAFFIC_TTI
    ]

    if invalid_highest:
        blog(f'Invalid highestClassPriority entries ({len(invalid_highest)}):')
        for entry in invalid_highest[:10]:  # limit zeby nie zaspamowac
            blog(str(entry))

    condition_dtx = any(
        msg.get('highestClassPriority') in DTX_OPTIMIZED_DRB_TRAFFIC_TTI
        for msg in all_dlPreSchedData
    )

    if not condition_dtx:
        raise AssertionError(
            f'Optimized DTX not present. '
            f'Expected: {DTX_OPTIMIZED_DRB_TRAFFIC_TTI}, '
            f'Actual: {highest_values}'
        )

    # --- Debug ueType ---
    ue_types = [msg.get('ueType') for msg in all_dlFdSchedData]
    blog(f'All ueType values: {ue_types}')
    blog(f'Expected ueType: {[PCELL, SCELL]}')

    invalid_ue = [
        msg for msg in all_dlFdSchedData
        if msg.get('ueType') not in [PCELL, SCELL]
    ]

    if invalid_ue:
        blog(f'Invalid ueType entries ({len(invalid_ue)}):')
        for entry in invalid_ue[:10]:
            blog(str(entry))

    condition_ue = any(
        msg.get('ueType') in [PCELL, SCELL]
        for msg in all_dlFdSchedData
    )

    if not condition_ue:
        raise AssertionError(
            f'ueType must be PCELL or SCELL. '
            f'Actual: {ue_types}'
        )

    blog('Optimized DTX checked successfully for SCell activated.')


def check_optimized_dtx_for_rnti(tti_logs, rnti, expected_result=None):
    blog('Checking optimized DTX for RNTI: {}...'.format(rnti))
    all_dlPreSchedData = extract_dl_pre_sched_data_from_tti(tti_logs, rnti)
    bts_sw_release = int(get_sw_release_name()[4:8].replace('R', ''))
    if bts_sw_release < CONDITIONAL_RELEASE_TTI_CLASS:
        DTX_OPTIMIZED_DRB_TRAFFIC_TTI = [CLASS_BRANCH[1]]
    elif bts_sw_release == CONDITIONAL_RELEASE_TTI_CLASS:
        DTX_OPTIMIZED_DRB_TRAFFIC_TTI = [CLASS_25R2[1]]
    elif CONDITIONAL_RELEASE_TTI_CLASS_26R2 > bts_sw_release > CONDITIONAL_RELEASE_TTI_CLASS:
        DTX_OPTIMIZED_DRB_TRAFFIC_TTI = [CLASS_26R2[1]]
    else:
        DTX_OPTIMIZED_DRB_TRAFFIC_TTI = [CLASS_TRUNK[1]]
    if expected_result == 'no_dtx':
        assert all(msg['highestClassPriority'] not in DTX_OPTIMIZED_DRB_TRAFFIC_TTI for msg in all_dlPreSchedData), \
            'Optimized DTX are present but not expected for RNTI: {}'.format(rnti)
        blog('Optimized DTX are NOT present')
    else:
        assert any(msg['highestClassPriority'] in DTX_OPTIMIZED_DRB_TRAFFIC_TTI for msg in all_dlPreSchedData), \
            'Optimized DTX are not present for RNTI: {}'.format(rnti)
        blog('Optimized DTX are present')
    blog('Optimized DTX checked successfully for RNTI: {}.'.format(rnti))


def check_prio_class_for_rlc_traffic(tti_logs, rnti):
    blog('Starting highest class priority check for RLC traffic for RNTI {}...'.format(rnti))
    all_dlPreSchedData = extract_dl_pre_sched_data_from_tti(tti_logs, rnti)

    bts_sw_release = int(get_sw_release_name()[4:8].replace('R', ''))
    if bts_sw_release < CONDITIONAL_RELEASE_TTI_CLASS:
        DL_DRB_DTX_TTI = [CLASS_BRANCH[0]]
    elif bts_sw_release == CONDITIONAL_RELEASE_TTI_CLASS:
        DL_DRB_DTX_TTI = [CLASS_25R2[0]]
    elif CONDITIONAL_RELEASE_TTI_CLASS_26R2 > bts_sw_release > CONDITIONAL_RELEASE_TTI_CLASS:
        DL_DRB_DTX_TTI = [CLASS_26R2[0]]
    else:
        DL_DRB_DTX_TTI = [CLASS_TRUNK[0]]

    blog(f"Expected DL_DRB_DTX_TTI: {DL_DRB_DTX_TTI}")

    compared_values = [msg['highestClassPriority'] for msg in all_dlPreSchedData]

    assert any(
        msg['highestClassPriority'] in DL_DRB_DTX_TTI and
        msg['csListEvent'] == ENTRYNONNULLBUFFER
        for msg in all_dlPreSchedData
    ), f'Expected {DL_DRB_DTX_TTI}, but compared with {compared_values} for RNTI {rnti}'

    blog('Highest class priority for ENTRYNONNULLBUFFER event checked')


def check_multi_cell_sync_slot_in_dldtxoptimevent(tti_logs):
    blog('Checking "MULTICELLSYNCSLOT" in the "dlDtxOptimEvent" event in TTI...')
    with LogHelper() as lh:
        tti_finder = lh.add_tti(log_files=tti_logs)
        multi_cell_sync_slot = tti_finder.find_all(TTIMessageMatcher('dlDtxOptimData').containing(
            key_pattern='dlDtxOptimEvent', val_pattern=MULTICELLSYNCSLOT, regex_engine='re'))
        assert multi_cell_sync_slot is not None, 'No MULTICELLSYNCSLOT was found in dlDtxOptimEvent'
        blog('dlDtxOptimEvent analysed successfully.')


def check_optimized_dtx_for_scell_deactivated(tti_logs, rnti):
    blog('Checking optimized DTX for SCell deactivated...')

    all_dlPreSchedData = extract_dl_pre_sched_data_from_tti(tti_logs, rnti)
    all_dlFdSchedData = extract_dl_fd_sched_data_from_tti(tti_logs, rnti)

    # --- SW version ---
    sw_name = get_sw_release_name()
    bts_sw_release = int(sw_name[4:8].replace('R', ''))
    blog(f'SW release name: {sw_name}, parsed: {bts_sw_release}')

    # --- Expected class selection ---
    if bts_sw_release < CONDITIONAL_RELEASE_TTI_CLASS:
        DTX_OPTIMIZED_DRB_TRAFFIC_TTI = [CLASS_BRANCH[1]]
        source = 'CLASS_BRANCH'
    elif bts_sw_release == CONDITIONAL_RELEASE_TTI_CLASS:
        DTX_OPTIMIZED_DRB_TRAFFIC_TTI = [CLASS_25R2[1]]
        source = 'CLASS_25R2'
    elif CONDITIONAL_RELEASE_TTI_CLASS_26R2 > bts_sw_release > CONDITIONAL_RELEASE_TTI_CLASS:
        DTX_OPTIMIZED_DRB_TRAFFIC_TTI = [CLASS_26R2[1]]
        source = 'CLASS_26R2'
    else:
        DTX_OPTIMIZED_DRB_TRAFFIC_TTI = [CLASS_TRUNK[1]]
        source = 'CLASS_TRUNK'

    blog(f'Forbidden DTX class ({source}): {DTX_OPTIMIZED_DRB_TRAFFIC_TTI}')

    # --- Debug highestClassPriority ---
    highest_values = [msg.get('highestClassPriority') for msg in all_dlPreSchedData]
    blog(f'All highestClassPriority values: {highest_values}')
    blog(f'Unique highestClassPriority values: {sorted(set(highest_values))}')

    invalid_highest = [
        msg for msg in all_dlPreSchedData
        if msg.get('highestClassPriority') in DTX_OPTIMIZED_DRB_TRAFFIC_TTI
    ]

    if invalid_highest:
        blog(f'Forbidden highestClassPriority FOUND ({len(invalid_highest)}):')
        for entry in invalid_highest[:10]:
            blog(str(entry))

    condition_dtx = all(
        msg.get('highestClassPriority') not in DTX_OPTIMIZED_DRB_TRAFFIC_TTI
        for msg in all_dlPreSchedData
    )

    if not condition_dtx:
        raise AssertionError(
            f'Optimized DTX present but should NOT be. '
            f'Forbidden: {DTX_OPTIMIZED_DRB_TRAFFIC_TTI}, '
            f'Actual: {highest_values}'
        )

    # --- Debug ueType ---
    ue_types = [msg.get('ueType') for msg in all_dlFdSchedData]
    blog(f'All ueType values: {ue_types}')
    blog(f'Unique ueType values: {sorted(set(ue_types))}')
    blog(f'Expected ueType: [NONCA]')

    invalid_ue = [
        msg for msg in all_dlFdSchedData
        if msg.get('ueType') != NONCA
    ]

    if invalid_ue:
        blog(f'Invalid ueType entries ({len(invalid_ue)}):')
        for entry in invalid_ue[:10]:
            blog(str(entry))

    condition_ue = all(
        msg.get('ueType') == NONCA
        for msg in all_dlFdSchedData
    )

    if not condition_ue:
        raise AssertionError(
            f'ueType must be NONCA when SCell inactive. '
            f'Actual: {ue_types}'
        )

    blog('Optimized DTX correctly NOT present for SCell deactivated.')


def extract_dl_fd_sched_data_from_tti(tti_logs, rnti):
    with LogHelper() as lh:
        tti_finder = lh.add_tti(log_files=tti_logs)
        matcher = TTIMessageMatcher('dlFdSchedData').containing(key_pattern='rnti', val_pattern=rnti,
                                                                regex_engine='re')
        return tti_finder.find_all(matcher)


def check_5qi_used_for_tput(mnc=['01'], expected='incremented'):
    blog("Checking counters...")
    pm_counters_path = pm.collect_counters()
    if expected == 'incremented':
        pm.check_counter_greater_than_x(pi_dir=pm_counters_path, counter_name='M55326C02008',
                                        object_id=mnc, x=0, n_last_values=2)
    elif expected == '0':
        pm.check_counter_equals_x(pi_dir=pm_counters_path, counter_name='M55326C02008',
                                  object_id=mnc, x=0, n_last_values=2)
