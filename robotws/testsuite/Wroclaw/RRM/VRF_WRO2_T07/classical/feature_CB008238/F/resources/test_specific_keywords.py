from testsuite.Wroclaw.RRM.VRF_WRO2_T07.classical.feature_CB008238.A.resources.test_specific_keywords import \
    DTX_OPTIMIZED_DRB_TRAFFIC_CLASS, pairwise, MAX_SFN
from testsuite.Wroclaw.RRM.VRF_WRO2_T07.classical.feature_CB008238.E.resources.test_specific_keywords import \
    ds, MRBTS_ID, NRBTS_ID
from testsuite.Wroclaw.RRM.VRF_WRO2_T07.resources.log import blog
from testsuite.Wroclaw.RRM.VRF_WRO2_T07.resources.log_analyzer.log_helper import LogHelper
from testsuite.Wroclaw.RRM.VRF_WRO2_T07.resources.log_analyzer.matchers import TTIMessageMatcher
from testsuite.Wroclaw.RRM.VRF_WRO2_T07.resources.logs.pm_counters import check_counter_greater_than_x, \
    check_counter_less_than_x
from testsuite.Wroclaw.RRM.VRF_WRO2_T07.resources.testline_preparation import get_sw_release_name

SFN_DELAY_SINCE_LAST_SCHEDULING = 10
DELAY_SINCE_LAST_SCHEDULING_EXCEEDED = 'DELAYSINCELASTSCHED'
DELAY_SINCE_LAST_SCHEDULING_ERROR_THRESHOLD = 10
CONDITIONAL_RELEASE_4 = int('SBTS25R1'[4:].replace('R', ''))

scf_params_f = {'actPdschAtSsbSlots': 'false', 'actPdschRmCsirsForTracking': 'false', 'actMicroDTX': 'true',
                'actDtxOptimizedScheduler': 'true',
                'dtxDelaySinceLastScheduling': str(SFN_DELAY_SINCE_LAST_SCHEDULING * 10),
                'dtxMaxRetentionDelay': '10', 'dtxPrbThreshold': '80', 'miNrCellUtilization': '5min'}


def setup_scf_8238_F7():
    bts_sw_release = int(get_sw_release_name()[4:8].replace('R', ''))
    ds.initialise_delta_store()
    ds.add_param_to_delta('MRBTS-{}/NRBTS-{}/NRPMRNL-1'.format(MRBTS_ID, NRBTS_ID),
                          'miNrCellUtilization', '5min')
    ds.add_param_to_delta('MRBTS-{}/NRBTS-{}/NRCELL-1'.format(MRBTS_ID, NRBTS_ID),
                          'actPdschAtSsbSlots', 'false')
    ds.add_param_to_delta('MRBTS-{}/NRBTS-{}/NRCELL-2'.format(MRBTS_ID, NRBTS_ID),
                          'actPdschAtSsbSlots', 'false')
    ds.add_param_to_delta('MRBTS-{}/NRBTS-{}/NRCELL-3'.format(MRBTS_ID, NRBTS_ID),
                          'actPdschAtSsbSlots', 'false')
    ds.add_param_to_delta('MRBTS-{}/NRBTS-{}/NRCELL-4'.format(MRBTS_ID, NRBTS_ID),
                          'actPdschAtSsbSlots', 'false')
    ds.add_param_to_delta('MRBTS-{}/NRBTS-{}/NRCELL-5'.format(MRBTS_ID, NRBTS_ID),
                          'actPdschAtSsbSlots', 'false')
    ds.add_param_to_delta('MRBTS-{}/NRBTS-{}'.format(MRBTS_ID, NRBTS_ID),
                          'sCellActivationMethod', 'blind')
    if bts_sw_release >= CONDITIONAL_RELEASE_4:
        ds.add_param_to_delta('MRBTS-{}/NRBTS-{}/NRCELL-1'.format(MRBTS_ID, NRBTS_ID),
                              'actPdschAllocAroundSsb', 'false')
        ds.add_param_to_delta('MRBTS-{}/NRBTS-{}/NRCELL-2'.format(MRBTS_ID, NRBTS_ID),
                              'actPdschAllocAroundSsb', 'false')
        ds.add_param_to_delta('MRBTS-{}/NRBTS-{}/NRCELL-3'.format(MRBTS_ID, NRBTS_ID),
                              'actPdschAllocAroundSsb', 'false')
        ds.add_param_to_delta('MRBTS-{}/NRBTS-{}/NRCELL-4'.format(MRBTS_ID, NRBTS_ID),
                              'actPdschAllocAroundSsb', 'false')
        ds.add_param_to_delta('MRBTS-{}/NRBTS-{}/NRCELL-5'.format(MRBTS_ID, NRBTS_ID),
                              'actPdschAllocAroundSsb', 'false')
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
    ds.add_param_to_delta('MRBTS-{}/NRBTS-{}'.format(MRBTS_ID, NRBTS_ID),
                          'actSliceAwareScheduler', 'true')
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
                                 dtxDelaySinceLastScheduling=str(SFN_DELAY_SINCE_LAST_SCHEDULING * 10),
                                 dtxMaxRetentionDelay='10',
                                 dtxPrbThreshold='80',
                                 multiCellSyncEnabled='false',
                                 rlcStatusPduSupportEnabled='false')
    ds.add_complex_item_to_delta('MRBTS-{}/NRBTS-{}/NRCELL-3'.format(MRBTS_ID, NRBTS_ID), 'dtxOptimizedScheduler',
                                 caSupportEnabled='true',
                                 drbDifferentiationEnabled='false',
                                 drxSupportEnabled='false',
                                 dtxDelaySinceLastScheduling=str(SFN_DELAY_SINCE_LAST_SCHEDULING * 10),
                                 dtxMaxRetentionDelay='10',
                                 dtxPrbThreshold='80',
                                 multiCellSyncEnabled='false',
                                 rlcStatusPduSupportEnabled='false')
    ds.add_complex_item_to_delta('MRBTS-{}/NRBTS-{}/NRCELL-4'.format(MRBTS_ID, NRBTS_ID), 'dtxOptimizedScheduler',
                                 caSupportEnabled='true',
                                 drbDifferentiationEnabled='false',
                                 drxSupportEnabled='false',
                                 dtxDelaySinceLastScheduling=str(SFN_DELAY_SINCE_LAST_SCHEDULING * 10),
                                 dtxMaxRetentionDelay='10',
                                 dtxPrbThreshold='80',
                                 multiCellSyncEnabled='false',
                                 rlcStatusPduSupportEnabled='false')
    ds.add_complex_item_to_delta('MRBTS-{}/NRBTS-{}/NRCELL-5'.format(MRBTS_ID, NRBTS_ID), 'dtxOptimizedScheduler',
                                 caSupportEnabled='true',
                                 drbDifferentiationEnabled='false',
                                 drxSupportEnabled='false',
                                 dtxDelaySinceLastScheduling=str(SFN_DELAY_SINCE_LAST_SCHEDULING * 10),
                                 dtxMaxRetentionDelay='10',
                                 dtxPrbThreshold='80',
                                 multiCellSyncEnabled='false',
                                 rlcStatusPduSupportEnabled='false')
    enable_ds_file = ds.collect_delta_store()
    blog('Delta store file (enable_ds_file): {}'.format(enable_ds_file))
    ds.perform_delta_recommissioning(delta_file=enable_ds_file)


def check_below_delay_since_last_scheduled(tti_logs, rnti):
    blog('Start checking TTI with throughput below delay since last scheduled')
    with LogHelper() as lh:
        tti_finder = lh.add_tti(log_files=tti_logs)
        preSched_data_matcher = TTIMessageMatcher('dlPreSchedData'). \
            containing(key_pattern='rnti', val_pattern=rnti, regex_engine='re')
        relevant_preSchedData = tti_finder.find_all(preSched_data_matcher)

    is_17_present = any(
        msg['highestClassPriority'] in DTX_OPTIMIZED_DRB_TRAFFIC_CLASS
        for msg
        in relevant_preSchedData
    )

    assert is_17_present, 'highestClassPriority with value "17" was not found in TTI.'
    blog('TTI analysed successfully!')


def check_above_delay_since_last_scheduled(tti_logs):
    blog('Start checking TTI with throughput above delay since last scheduled')
    with LogHelper() as lh:
        tti_finder = lh.add_tti(log_files=tti_logs)
        relevant_dtx_optim_data = tti_finder.find_all(TTIMessageMatcher('dlDtxOptimData').containing(
            key_pattern='dlDtxOptimEvent', val_pattern=DELAY_SINCE_LAST_SCHEDULING_EXCEEDED, regex_engine='re'))

    invalid_period = 0
    for prev, _next in pairwise(relevant_dtx_optim_data):
        prev_sfn, next_sfn = int(prev['sfn']), int(_next['sfn'])
        prev_slot, next_slot = int(prev['slot']), int(_next['slot'])
        if (next_sfn - prev_sfn) % MAX_SFN == SFN_DELAY_SINCE_LAST_SCHEDULING:
            if next_slot < prev_slot:
                invalid_period += 1
        if (next_sfn - prev_sfn) % MAX_SFN < SFN_DELAY_SINCE_LAST_SCHEDULING:
            invalid_period += 1

    try:
        invalid_period_percent = 100 * float(invalid_period) / len(relevant_dtx_optim_data)
        blog('Percent of invalid periods between subsequent "DELAYSINCELASTSCHEDULED": {}%'.format(
            invalid_period_percent))
    except ZeroDivisionError:
        raise Exception('No dlDtxOptimData with "DELAYSINCELASTSCHEDULED" were found in TTI.')

    assert invalid_period_percent <= DELAY_SINCE_LAST_SCHEDULING_ERROR_THRESHOLD, \
        '"DELAYSINCELASTSCHEDULED" appears too often. Max error: {}%. Current error: {}%'.format(
            DELAY_SINCE_LAST_SCHEDULING_ERROR_THRESHOLD, invalid_period_percent)

    blog('TTI analysed successfully!')


def check_optimized_dtx_counters(pi_dir, cell_id, condition):
    blog('Start checking optimized DTX counters')
    counter_1 = 'M55308C33000'
    counter_2 = 'M55308C33001'
    if condition == 'BELOW':
        check_counter_greater_than_x(pi_dir, counter_1, [cell_id], 0)
        check_counter_greater_than_x(pi_dir, counter_2, [cell_id], 0)
    elif condition == 'ABOVE':
        check_counter_less_than_x(pi_dir, counter_1, [cell_id], 1000)
        check_counter_less_than_x(pi_dir, counter_2, [cell_id], 200)
    else:
        raise Exception('Invalid option passed. Available options: BELOW | ABOVE')

    blog('Counters analysed successfully!')
