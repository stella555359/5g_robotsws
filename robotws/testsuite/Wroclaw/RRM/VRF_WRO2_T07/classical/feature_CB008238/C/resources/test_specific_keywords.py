from testsuite.Wroclaw.RRM.VRF_WRO2_T07.classical.feature_CB008238.A.resources.test_specific_keywords import \
    DTX_OPTIMIZED_DRB_TRAFFIC_CLASS, DL_DRB_DTX_CLASS
from testsuite.Wroclaw.RRM.VRF_WRO2_T07.classical.feature_CB008238.E.resources.test_specific_keywords import \
    ds, MRBTS_ID, NRBTS_ID
from testsuite.Wroclaw.RRM.VRF_WRO2_T07.resources.log import blog
from testsuite.Wroclaw.RRM.VRF_WRO2_T07.resources.log_analyzer.log_helper import LogHelper
from testsuite.Wroclaw.RRM.VRF_WRO2_T07.resources.log_analyzer.matchers import TTIMessageMatcher
from testsuite.Wroclaw.RRM.VRF_WRO2_T07.resources.testline_preparation import get_sw_release_name

scf_params_c1 = {'actPdschAtSsbSlots': 'false', 'actPdschRmCsirsForTracking': 'false', 'actMicroDTX': 'true',
                 'actDtxOptimizedScheduler': 'true', 'dtxDelaySinceLastScheduling': '0',
                 'dtxMaxRetentionDelay': '10', 'dtxPrbThreshold': '60'}

scf_params_c3 = {'actPdschAtSsbSlots': 'false', 'actPdschRmCsirsForTracking': 'false', 'actMicroDTX': 'true',
                 'actDtxOptimizedScheduler': 'true', 'dtxDelaySinceLastScheduling': '0',
                 'dtxMaxRetentionDelay': '10', 'dtxPrbThreshold': '80'}

DTXPRBTHRES = 'DTXPRBTHRES'
EXPECTED_HIGHER = 80
EXPECTED_LOWER = 35
CONDITIONAL_RELEASE_4 = int('SBTS25R1'[4:].replace('R', ''))


def setup_scf_8238_C6():
    ds.initialise_delta_store()
    bts_sw_release = int(get_sw_release_name()[4:8].replace('R', ''))

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
                          'actEnhDtxOptimizedScheduler', 'true')
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
                                 dtxDelaySinceLastScheduling=0,
                                 dtxMaxRetentionDelay='10',
                                 dtxPrbThreshold='80',
                                 multiCellSyncEnabled='false',
                                 rlcStatusPduSupportEnabled='false')
    ds.add_complex_item_to_delta('MRBTS-{}/NRBTS-{}/NRCELL-3'.format(MRBTS_ID, NRBTS_ID), 'dtxOptimizedScheduler',
                                 caSupportEnabled='true',
                                 drbDifferentiationEnabled='false',
                                 drxSupportEnabled='false',
                                 dtxDelaySinceLastScheduling=0,
                                 dtxMaxRetentionDelay='10',
                                 dtxPrbThreshold='80',
                                 multiCellSyncEnabled='false',
                                 rlcStatusPduSupportEnabled='false')
    ds.add_complex_item_to_delta('MRBTS-{}/NRBTS-{}/NRCELL-4'.format(MRBTS_ID, NRBTS_ID), 'dtxOptimizedScheduler',
                                 caSupportEnabled='true',
                                 drbDifferentiationEnabled='false',
                                 drxSupportEnabled='false',
                                 dtxDelaySinceLastScheduling=0,
                                 dtxMaxRetentionDelay='10',
                                 dtxPrbThreshold='80',
                                 multiCellSyncEnabled='false',
                                 rlcStatusPduSupportEnabled='false')
    ds.add_complex_item_to_delta('MRBTS-{}/NRBTS-{}/NRCELL-5'.format(MRBTS_ID, NRBTS_ID), 'dtxOptimizedScheduler',
                                 caSupportEnabled='true',
                                 drbDifferentiationEnabled='false',
                                 drxSupportEnabled='false',
                                 dtxDelaySinceLastScheduling=0,
                                 dtxMaxRetentionDelay='10',
                                 dtxPrbThreshold='80',
                                 multiCellSyncEnabled='false',
                                 rlcStatusPduSupportEnabled='false')
    enable_ds_file = ds.collect_delta_store()
    blog('Delta store file (enable_ds_file): {}'.format(enable_ds_file))
    ds.perform_delta_recommissioning(delta_file=enable_ds_file)


def verify_throughput_with_and_without_8238(throughput_on, throughput_off, error_in_percent):
    blog('Start comparing throughputs...')
    tput_margin = float(throughput_off) * float(error_in_percent) / 100.0
    assert float(throughput_on) >= float(throughput_off) - tput_margin, \
        'Throughput with feature CB008238 turned on is too low'
    blog('Throughput comparison completed successfully.')


def analyze_prb_lower_than_threshold(tti_logs):
    blog('Start analysing TTI for PRB lower than threshold...')
    prb_threshold_occurrence = get_prb_threshold_occurrence(tti_logs)
    assert prb_threshold_occurrence < EXPECTED_LOWER, \
        'Too many DTXPRBTHRES found, while PRB threshold was NOT exceeded. Expected < {}%. Current: {}%'.format(
            EXPECTED_LOWER, prb_threshold_occurrence)
    blog('TTI analysed successfully for PRB lower than threshold.')


def analyze_prb_higher_than_threshold(tti_logs):
    blog('Start analysing TTI for PRB higher than threshold...')
    prb_threshold_occurrence = get_prb_threshold_occurrence(tti_logs)
    assert prb_threshold_occurrence >= EXPECTED_LOWER, \
        'Too few DTXPRBTHRES found, while PRB threshold was exceeded. Expected >= {}%. Current: {}%'.format(
            EXPECTED_HIGHER, prb_threshold_occurrence)
    blog('TTI analysed successfully for PRB higher than threshold.')


def get_prb_threshold_occurrence(tti_logs):
    relevant_dtx_optim_data = extract_dl_dtx_optim_data(tti_logs)
    num_of_prb_threshold_reached = len([el for el in relevant_dtx_optim_data if el['dlDtxOptimEvent'] == DTXPRBTHRES])

    try:
        prb_threshold_occurrence = 100 * float(num_of_prb_threshold_reached) / len(relevant_dtx_optim_data)
    except ZeroDivisionError:
        raise Exception('No dlDtxOptimData were found in TTI.')

    blog('DTX PRB threshold occurrence: {}%'.format(prb_threshold_occurrence))
    return prb_threshold_occurrence


def extract_dl_dtx_optim_data(tti_logs):
    with LogHelper() as lh:
        tti_finder = lh.add_tti(log_files=tti_logs)
        matcher = TTIMessageMatcher('dlDtxOptimData')
        return tti_finder.find_all(matcher)
