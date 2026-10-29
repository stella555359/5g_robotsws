import testsuite.Wroclaw.RRM.VRF_WRO2_T07.resources.tl_config as tl
from testsuite.Wroclaw.RRM.VRF_WRO2_T07.classical.CB007564.resources.test_specific_keywords_7564 import atten
from testsuite.Wroclaw.RRM.VRF_WRO2_T07.classical.feature_CB008238.A.resources.test_specific_keywords import \
    extract_dl_pre_sched_data_from_tti, DTX_OPTIMIZED_DRB_TRAFFIC_CLASS
from testsuite.Wroclaw.RRM.VRF_WRO2_T07.resources.log import blog
from testsuite.Wroclaw.RRM.VRF_WRO2_T07.resources.log_analyzer.log_helper import LogHelper
from testsuite.Wroclaw.RRM.VRF_WRO2_T07.resources.log_analyzer.matchers import TTIMessageMatcher
from testsuite.Wroclaw.RRM.VRF_WRO2_T07.resources.admin_api.DeltaStore import DeltaStore
from testsuite.Wroclaw.RRM.VRF_WRO2_T07.resources.testline_preparation import get_sw_release_name
from robot.libraries.BuiltIn import BuiltIn

MRBTS_ID = tl.tl.gnbs[0].instance_id
NRBTS_ID = tl.tl.gnbs[0].global_bts_id
CONDITIONAL_RELEASE_4 = int('SBTS25R1'[4:].replace('R', ''))

ds = DeltaStore()

scf_params_e1 = {'actPdschAtSsbSlots': 'false', 'actPdschRmCsirsForTracking': 'false', 'actMicroDTX': 'true',
                 'actDtxOptimizedScheduler': 'true', 'dtxDelaySinceLastScheduling': '0',
                 'dtxMaxRetentionDelay': '10', 'dtxPrbThreshold': '80',
                 'sCellActivationMethod': 'bufferBased', 'sCellDeactivationTimerGNB': 'ms1280'}

scf_params_e3 = {'actPdschAtSsbSlots': 'false', 'actPdschRmCsirsForTracking': 'false', 'actMicroDTX': 'true',
                 'actDtxOptimizedScheduler': 'true', 'dtxDelaySinceLastScheduling': '0',
                 'dtxMaxRetentionDelay': '10', 'dtxPrbThreshold': '80',
                 'sCellActivationMethod': 'blind'}

NONCA = 'NONCA'
PCELL = 'PCELL'
SCELL = 'SCELL'


def change_scell_deactivation_param():
    ds.initialise_delta_store()
    ds.add_param_to_delta('MRBTS-{}/NRBTS-{}/NRCELL-1'.format(MRBTS_ID, NRBTS_ID),
                          'sCellDeactivationTimerGNB', 'infinity')
    ds.add_param_to_delta('MRBTS-{}/NRBTS-{}/NRCELL-2'.format(MRBTS_ID, NRBTS_ID),
                          'sCellDeactivationTimerGNB', 'infinity')
    ds.add_param_to_delta('MRBTS-{}/NRBTS-{}/NRCELL-3'.format(MRBTS_ID, NRBTS_ID),
                          'sCellDeactivationTimerGNB', 'infinity')
    ds.add_param_to_delta('MRBTS-{}/NRBTS-{}/NRCELL-4'.format(MRBTS_ID, NRBTS_ID),
                          'sCellDeactivationTimerGNB', 'infinity')
    ds.add_param_to_delta('MRBTS-{}/NRBTS-{}/NRCELL-5'.format(MRBTS_ID, NRBTS_ID),
                          'sCellDeactivationTimerGNB', 'infinity')
    enable_ds_file = ds.collect_delta_store()
    blog('Delta store file (enable_ds_file): {}'.format(enable_ds_file))
    ds.perform_delta_recommissioning(delta_file=enable_ds_file)


def setup_buffer_based_CA():
    bts_sw_release = int(get_sw_release_name()[4:8].replace('R', ''))
    bts_id = BuiltIn().get_variable_value("${MRBTS_5G_ID}")
    nrbts_object = f'MRBTS-{bts_id}/NRBTS-{bts_id}'
    ds.initialise_delta_store()
    ds.add_param_to_delta(nrbts_object + '/NRCELL-1',
                          'qRxLevMin', '-22')
    ds.add_param_to_delta(nrbts_object + '/NRCELL-2',
                          'qRxLevMin', '-22')
    ds.add_param_to_delta(nrbts_object + '/NRCELL-3',
                          'qRxLevMin', '-22')
    ds.add_param_to_delta(nrbts_object + '/NRCELL-5',
                          'qRxLevMin', '-22')
    ds.add_param_to_delta('MRBTS-{}/NRBTS-{}'.format(MRBTS_ID, NRBTS_ID),
                          'sCellActivationMethod', 'bufferBased')
    if bts_sw_release < CONDITIONAL_RELEASE_4:
        ds.add_param_to_delta('MRBTS-{}/NRBTS-{}'.format(MRBTS_ID, NRBTS_ID),
                              'actMicroDTX', 'true')
        ds.add_param_to_delta('MRBTS-{}/NRBTS-{}'.format(MRBTS_ID, NRBTS_ID),
                              'actMicroDTXAdvanced', 'false')
    ds.add_param_to_delta('MRBTS-{}/NRBTS-{}'.format(MRBTS_ID, NRBTS_ID),
                          'actSliceAwareScheduler', 'true')
    ds.add_param_to_delta('MRBTS-{}/NRBTS-{}/NRCELL-1'.format(MRBTS_ID, NRBTS_ID),
                          'sCellDeactivationTimerGNB', 'ms1280')
    ds.add_param_to_delta('MRBTS-{}/NRBTS-{}/NRCELL-2'.format(MRBTS_ID, NRBTS_ID),
                          'sCellDeactivationTimerGNB', 'ms1280')
    ds.add_param_to_delta('MRBTS-{}/NRBTS-{}/NRCELL-3'.format(MRBTS_ID, NRBTS_ID),
                          'sCellDeactivationTimerGNB', 'ms1280')
    ds.add_param_to_delta('MRBTS-{}/NRBTS-{}/NRCELL-4'.format(MRBTS_ID, NRBTS_ID),
                          'sCellDeactivationTimerGNB', 'ms1280')
    ds.add_param_to_delta('MRBTS-{}/NRBTS-{}/NRCELL-5'.format(MRBTS_ID, NRBTS_ID),
                          'sCellDeactivationTimerGNB', 'ms1280')
    ds.add_param_to_delta('MRBTS-{}/NRBTS-{}/NRCELL-1'.format(MRBTS_ID, NRBTS_ID),
                          'actPdschRmCsirsForTracking', 'false')
    ds.add_param_to_delta('MRBTS-{}/NRBTS-{}/NRCELL-2'.format(MRBTS_ID, NRBTS_ID),
                          'actPdschRmCsirsForTracking', 'false')
    ds.add_param_to_delta('MRBTS-{}/NRBTS-{}/NRCELL-3'.format(MRBTS_ID, NRBTS_ID),
                          'actPdschRmCsirsForTracking', 'false')
    ds.add_param_to_delta('MRBTS-{}/NRBTS-{}/NRCELL-4'.format(MRBTS_ID, NRBTS_ID),
                          'actPdschRmCsirsForTracking', 'false')
    ds.add_param_to_delta('MRBTS-{}/NRBTS-{}/NRCELL-5'.format(MRBTS_ID, NRBTS_ID),
                          'actPdschRmCsirsForTracking', 'false')
    ds.add_param_to_delta('MRBTS-{}/NRBTS-{}/NRCELL-1'.format(MRBTS_ID, NRBTS_ID),
                          'actDtxOptimizedScheduler', 'true')
    ds.add_param_to_delta('MRBTS-{}/NRBTS-{}/NRCELL-2'.format(MRBTS_ID, NRBTS_ID),
                          'actDtxOptimizedScheduler', 'true')
    ds.add_param_to_delta('MRBTS-{}/NRBTS-{}/NRCELL-3'.format(MRBTS_ID, NRBTS_ID),
                          'actDtxOptimizedScheduler', 'true')
    ds.add_param_to_delta('MRBTS-{}/NRBTS-{}/NRCELL-4'.format(MRBTS_ID, NRBTS_ID),
                          'actDtxOptimizedScheduler', 'true')
    ds.add_param_to_delta('MRBTS-{}/NRBTS-{}/NRCELL-5'.format(MRBTS_ID, NRBTS_ID),
                          'actDtxOptimizedScheduler', 'true')
    ds.add_param_to_delta('MRBTS-{}/NRBTS-{}/NRCELL-1'.format(MRBTS_ID, NRBTS_ID),
                          'actEnhDtxOptimizedScheduler', 'true')
    ds.add_param_to_delta('MRBTS-{}/NRBTS-{}/NRCELL-2'.format(MRBTS_ID, NRBTS_ID),
                          'actEnhDtxOptimizedScheduler', 'true')
    ds.add_param_to_delta('MRBTS-{}/NRBTS-{}/NRCELL-3'.format(MRBTS_ID, NRBTS_ID),
                          'actEnhDtxOptimizedScheduler', 'true')
    ds.add_param_to_delta('MRBTS-{}/NRBTS-{}/NRCELL-4'.format(MRBTS_ID, NRBTS_ID),
                          'actEnhDtxOptimizedScheduler', 'true')
    ds.add_param_to_delta('MRBTS-{}/NRBTS-{}/NRCELL-5'.format(MRBTS_ID, NRBTS_ID),
                          'actEnhDtxOptimizedScheduler', 'true')
    ds.add_complex_item_to_delta('MRBTS-{}/NRBTS-{}/NRCELL-1'.format(MRBTS_ID, NRBTS_ID), 'dtxOptimizedScheduler',
                                 caSupportEnabled='true',
                                 drbDifferentiationEnabled='false',
                                 drxSupportEnabled='false',
                                 dtxDelaySinceLastScheduling='0',
                                 dtxMaxRetentionDelay='10',
                                 dtxPrbThreshold='80',
                                 multiCellSyncEnabled='false',
                                 rlcStatusPduSupportEnabled='false')
    ds.add_complex_item_to_delta('MRBTS-{}/NRBTS-{}/NRCELL-2'.format(MRBTS_ID, NRBTS_ID), 'dtxOptimizedScheduler',
                                 caSupportEnabled='true',
                                 drbDifferentiationEnabled='false',
                                 drxSupportEnabled='false',
                                 dtxDelaySinceLastScheduling='0',
                                 dtxMaxRetentionDelay='10',
                                 dtxPrbThreshold='80',
                                 multiCellSyncEnabled='false',
                                 rlcStatusPduSupportEnabled='false')
    ds.add_complex_item_to_delta('MRBTS-{}/NRBTS-{}/NRCELL-3'.format(MRBTS_ID, NRBTS_ID), 'dtxOptimizedScheduler',
                                 caSupportEnabled='true',
                                 drbDifferentiationEnabled='false',
                                 drxSupportEnabled='false',
                                 dtxDelaySinceLastScheduling='0',
                                 dtxMaxRetentionDelay='10',
                                 dtxPrbThreshold='80',
                                 multiCellSyncEnabled='false',
                                 rlcStatusPduSupportEnabled='false')
    ds.add_complex_item_to_delta('MRBTS-{}/NRBTS-{}/NRCELL-4'.format(MRBTS_ID, NRBTS_ID), 'dtxOptimizedScheduler',
                                 caSupportEnabled='true',
                                 drbDifferentiationEnabled='false',
                                 drxSupportEnabled='false',
                                 dtxDelaySinceLastScheduling='0',
                                 dtxMaxRetentionDelay='10',
                                 dtxPrbThreshold='80',
                                 multiCellSyncEnabled='false',
                                 rlcStatusPduSupportEnabled='false')
    ds.add_complex_item_to_delta('MRBTS-{}/NRBTS-{}/NRCELL-5'.format(MRBTS_ID, NRBTS_ID), 'dtxOptimizedScheduler',
                                 caSupportEnabled='true',
                                 drbDifferentiationEnabled='false',
                                 drxSupportEnabled='false',
                                 dtxDelaySinceLastScheduling='0',
                                 dtxMaxRetentionDelay='10',
                                 dtxPrbThreshold='80',
                                 multiCellSyncEnabled='false',
                                 rlcStatusPduSupportEnabled='false')
    enable_ds_file = ds.collect_delta_store()
    blog('Delta store file (enable_ds_file): {}'.format(enable_ds_file))
    ds.perform_delta_recommissioning(delta_file=enable_ds_file)


def setup_blind_CA():
    bts_sw_release = int(get_sw_release_name()[4:8].replace('R', ''))
    ds.initialise_delta_store()
    bts_id = BuiltIn().get_variable_value("${MRBTS_5G_ID}")
    nrbts_object = f'MRBTS-{bts_id}/NRBTS-{bts_id}'
    ds.add_param_to_delta(nrbts_object + '/NRCELL-1',
                          'qRxLevMin', '-22')
    ds.add_param_to_delta(nrbts_object + '/NRCELL-2',
                          'qRxLevMin', '-22')
    ds.add_param_to_delta(nrbts_object + '/NRCELL-3',
                          'qRxLevMin', '-22')
    ds.add_param_to_delta(nrbts_object + '/NRCELL-5',
                          'qRxLevMin', '-22')
    ds.add_param_to_delta('MRBTS-{}/NRBTS-{}/NRCELL-1'.format(MRBTS_ID, NRBTS_ID),
                          'sCellDeactivationTimerGNB', 'infinity')
    ds.add_param_to_delta('MRBTS-{}/NRBTS-{}/NRCELL-2'.format(MRBTS_ID, NRBTS_ID),
                          'sCellDeactivationTimerGNB', 'infinity')
    ds.add_param_to_delta('MRBTS-{}/NRBTS-{}/NRCELL-3'.format(MRBTS_ID, NRBTS_ID),
                          'sCellDeactivationTimerGNB', 'infinity')
    ds.add_param_to_delta('MRBTS-{}/NRBTS-{}/NRCELL-4'.format(MRBTS_ID, NRBTS_ID),
                          'sCellDeactivationTimerGNB', 'infinity')
    ds.add_param_to_delta('MRBTS-{}/NRBTS-{}/NRCELL-5'.format(MRBTS_ID, NRBTS_ID),
                          'sCellDeactivationTimerGNB', 'infinity')
    ds.add_param_to_delta('MRBTS-{}/NRBTS-{}'.format(MRBTS_ID, NRBTS_ID),
                          'sCellActivationMethod', 'blind')
    ds.add_param_to_delta('MRBTS-{}/NRBTS-{}'.format(MRBTS_ID, NRBTS_ID),
                          'actSliceAwareScheduler', 'true')
    if bts_sw_release < CONDITIONAL_RELEASE_4:
        ds.add_param_to_delta('MRBTS-{}/NRBTS-{}'.format(MRBTS_ID, NRBTS_ID),
                              'actMicroDTX', 'true')
        ds.add_param_to_delta('MRBTS-{}/NRBTS-{}'.format(MRBTS_ID, NRBTS_ID),
                              'actMicroDTXAdvanced', 'false')
    ds.add_param_to_delta('MRBTS-{}/NRBTS-{}/NRCELL-1'.format(MRBTS_ID, NRBTS_ID),
                          'actPdschRmCsirsForTracking', 'false')
    ds.add_param_to_delta('MRBTS-{}/NRBTS-{}/NRCELL-2'.format(MRBTS_ID, NRBTS_ID),
                          'actPdschRmCsirsForTracking', 'false')
    ds.add_param_to_delta('MRBTS-{}/NRBTS-{}/NRCELL-3'.format(MRBTS_ID, NRBTS_ID),
                          'actPdschRmCsirsForTracking', 'false')
    ds.add_param_to_delta('MRBTS-{}/NRBTS-{}/NRCELL-4'.format(MRBTS_ID, NRBTS_ID),
                          'actPdschRmCsirsForTracking', 'false')
    ds.add_param_to_delta('MRBTS-{}/NRBTS-{}/NRCELL-5'.format(MRBTS_ID, NRBTS_ID),
                          'actPdschRmCsirsForTracking', 'false')
    ds.add_param_to_delta('MRBTS-{}/NRBTS-{}/NRCELL-1'.format(MRBTS_ID, NRBTS_ID),
                          'actDtxOptimizedScheduler', 'true')
    ds.add_param_to_delta('MRBTS-{}/NRBTS-{}/NRCELL-2'.format(MRBTS_ID, NRBTS_ID),
                          'actDtxOptimizedScheduler', 'true')
    ds.add_param_to_delta('MRBTS-{}/NRBTS-{}/NRCELL-3'.format(MRBTS_ID, NRBTS_ID),
                          'actDtxOptimizedScheduler', 'true')
    ds.add_param_to_delta('MRBTS-{}/NRBTS-{}/NRCELL-4'.format(MRBTS_ID, NRBTS_ID),
                          'actDtxOptimizedScheduler', 'true')
    ds.add_param_to_delta('MRBTS-{}/NRBTS-{}/NRCELL-5'.format(MRBTS_ID, NRBTS_ID),
                          'actDtxOptimizedScheduler', 'true')
    ds.add_param_to_delta('MRBTS-{}/NRBTS-{}/NRCELL-1'.format(MRBTS_ID, NRBTS_ID),
                          'actEnhDtxOptimizedScheduler', 'true')
    ds.add_param_to_delta('MRBTS-{}/NRBTS-{}/NRCELL-2'.format(MRBTS_ID, NRBTS_ID),
                          'actEnhDtxOptimizedScheduler', 'true')
    ds.add_param_to_delta('MRBTS-{}/NRBTS-{}/NRCELL-3'.format(MRBTS_ID, NRBTS_ID),
                          'actEnhDtxOptimizedScheduler', 'true')
    ds.add_param_to_delta('MRBTS-{}/NRBTS-{}/NRCELL-4'.format(MRBTS_ID, NRBTS_ID),
                          'actEnhDtxOptimizedScheduler', 'true')
    ds.add_param_to_delta('MRBTS-{}/NRBTS-{}/NRCELL-5'.format(MRBTS_ID, NRBTS_ID),
                          'actEnhDtxOptimizedScheduler', 'true')
    ds.add_complex_item_to_delta('MRBTS-{}/NRBTS-{}/NRCELL-1'.format(MRBTS_ID, NRBTS_ID), 'dtxOptimizedScheduler',
                                 caSupportEnabled='true',
                                 drbDifferentiationEnabled='false',
                                 drxSupportEnabled='false',
                                 dtxDelaySinceLastScheduling='0',
                                 dtxMaxRetentionDelay='10',
                                 dtxPrbThreshold='80',
                                 multiCellSyncEnabled='false',
                                 rlcStatusPduSupportEnabled='false')
    ds.add_complex_item_to_delta('MRBTS-{}/NRBTS-{}/NRCELL-2'.format(MRBTS_ID, NRBTS_ID), 'dtxOptimizedScheduler',
                                 caSupportEnabled='true',
                                 drbDifferentiationEnabled='false',
                                 drxSupportEnabled='false',
                                 dtxDelaySinceLastScheduling='0',
                                 dtxMaxRetentionDelay='10',
                                 dtxPrbThreshold='80',
                                 multiCellSyncEnabled='false',
                                 rlcStatusPduSupportEnabled='false')
    ds.add_complex_item_to_delta('MRBTS-{}/NRBTS-{}/NRCELL-3'.format(MRBTS_ID, NRBTS_ID), 'dtxOptimizedScheduler',
                                 caSupportEnabled='true',
                                 drbDifferentiationEnabled='false',
                                 drxSupportEnabled='false',
                                 dtxDelaySinceLastScheduling='0',
                                 dtxMaxRetentionDelay='10',
                                 dtxPrbThreshold='80',
                                 multiCellSyncEnabled='false',
                                 rlcStatusPduSupportEnabled='false')
    ds.add_complex_item_to_delta('MRBTS-{}/NRBTS-{}/NRCELL-4'.format(MRBTS_ID, NRBTS_ID), 'dtxOptimizedScheduler',
                                 caSupportEnabled='true',
                                 drbDifferentiationEnabled='false',
                                 drxSupportEnabled='false',
                                 dtxDelaySinceLastScheduling='0',
                                 dtxMaxRetentionDelay='10',
                                 dtxPrbThreshold='80',
                                 multiCellSyncEnabled='false',
                                 rlcStatusPduSupportEnabled='false')
    ds.add_complex_item_to_delta('MRBTS-{}/NRBTS-{}/NRCELL-5'.format(MRBTS_ID, NRBTS_ID), 'dtxOptimizedScheduler',
                                 caSupportEnabled='true',
                                 drbDifferentiationEnabled='false',
                                 drxSupportEnabled='false',
                                 dtxDelaySinceLastScheduling='0',
                                 dtxMaxRetentionDelay='10',
                                 dtxPrbThreshold='80',
                                 multiCellSyncEnabled='false',
                                 rlcStatusPduSupportEnabled='false')
    enable_ds_file = ds.collect_delta_store()
    blog('Delta store file (enable_ds_file): {}'.format(enable_ds_file))
    ds.perform_delta_recommissioning(delta_file=enable_ds_file)


def qrxlevmin_8238_E_teardown():
    bts_sw_release = int(get_sw_release_name()[4:8].replace('R', ''))
    bts_id = BuiltIn().get_variable_value("${MRBTS_5G_ID}")
    nrbts_object = f'MRBTS-{bts_id}/NRBTS-{bts_id}'
    ds.initialise_delta_store()
    ds.add_param_to_delta(nrbts_object + '/NRCELL-1',
                          'qRxLevMin', '-60')
    ds.add_param_to_delta(nrbts_object + '/NRCELL-2',
                          'qRxLevMin', '-60')
    ds.add_param_to_delta(nrbts_object + '/NRCELL-3',
                          'qRxLevMin', '-60')
    enable_ds_file = ds.collect_delta_store()
    blog('Delta store file (enable_ds_file): {}'.format(enable_ds_file))
    ds.perform_delta_recommissioning(delta_file=enable_ds_file)


def check_optimized_dtx_for_scell_activated(tti_logs, rnti):
    blog('Checking optimized DTX for SCell activated...')
    all_dlPreSchedData = extract_dl_pre_sched_data_from_tti(tti_logs, rnti)
    all_dlFdSchedData = extract_dl_fd_sched_data_from_tti(tti_logs, rnti)

    assert all(msg['highestClassPriority'] != DTX_OPTIMIZED_DRB_TRAFFIC_CLASS for msg in all_dlPreSchedData), \
        'Optimized DTX are present even though SCell is activated.'

    assert all(msg['ueType'] in [PCELL, SCELL] for msg in all_dlFdSchedData), \
        'ueType must be either PCELL or SCELL, when SCell is active.'

    blog('Optimized DTX checked successfully for SCell activated.')


def check_optimized_dtx_for_scell_deactivated(tti_logs, rnti):
    blog('Checking optimized DTX for SCell deactivated...')
    all_dlPreSchedData = extract_dl_pre_sched_data_from_tti(tti_logs, rnti)
    all_dlFdSchedData = extract_dl_fd_sched_data_from_tti(tti_logs, rnti)

    assert any(msg['highestClassPriority'] in DTX_OPTIMIZED_DRB_TRAFFIC_CLASS for msg in all_dlPreSchedData), \
        'Optimized DTX are NOT present even though SCell is deactivated.'

    assert all(msg['ueType'] == NONCA for msg in all_dlFdSchedData), \
        'ueType must always be NONCA, when SCell is inactive.'

    blog('Optimized DTX checked successfully for SCell deactivated.')


def extract_dl_fd_sched_data_from_tti(tti_logs, rnti):
    with LogHelper() as lh:
        tti_finder = lh.add_tti(log_files=tti_logs)
        matcher = TTIMessageMatcher('dlFdSchedData').containing(key_pattern='rnti', val_pattern=rnti,
                                                                regex_engine='re')
        return tti_finder.find_all(matcher)


def attenuation_8238_E3(atten_value=15, cell_1_attenuator_ports=tl.tl.gnbs[0].dus[0].rus[1].attenuation_ports,
                        cell_2_attenuator_ports=tl.tl.gnbs[0].dus[0].rus[2].attenuation_ports,
                        cell_3_attenuator_ports=tl.tl.gnbs[0].dus[0].rus[3].attenuation_ports,
                        cell_4_attenuator_ports=tl.tl.gnbs[0].dus[0].rus[0].attenuation_ports,
                        cell_5_attenuator_ports=tl.tl.gnbs[0].dus[0].rus[4].attenuation_ports):
    atten.initialise_attenuator()
    blog(cell_1_attenuator_ports, "ports cell 1")
    blog(cell_2_attenuator_ports, "ports cell 2")
    blog(cell_3_attenuator_ports, "ports cell 5")
    blog(cell_4_attenuator_ports, "ports cell 3")
    blog(cell_5_attenuator_ports, "ports cell 3")

    atten.set_attenuation(value_string=atten_value, ports=cell_1_attenuator_ports)
    atten.set_attenuation(value_string=atten_value, ports=cell_2_attenuator_ports)
    atten.set_attenuation(value_string=atten_value, ports=cell_3_attenuator_ports)
    atten.set_attenuation(value_string=atten_value, ports=cell_4_attenuator_ports)
    atten.set_attenuation(value_string=0, ports=cell_5_attenuator_ports)
