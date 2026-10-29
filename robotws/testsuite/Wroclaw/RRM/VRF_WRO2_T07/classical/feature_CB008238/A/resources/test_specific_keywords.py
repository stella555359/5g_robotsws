from itertools import tee

from testsuite.Wroclaw.RRM.VRF_WRO2_T07.resources.log import blog
from testsuite.Wroclaw.RRM.VRF_WRO2_T07.resources.log_analyzer.log_helper import LogHelper
from testsuite.Wroclaw.RRM.VRF_WRO2_T07.resources.log_analyzer.matchers import TTIMessageMatcher
import testsuite.Wroclaw.RRM.VRF_WRO2_T07.resources.admin_api.admin_api as adm_api
from testsuite.Wroclaw.RRM.VRF_WRO2_T07.resources.decorators import logged_keyword
from testsuite.Wroclaw.RRM.VRF_WRO2_T07.resources.admin_api.DeltaStore import DeltaStore
from testsuite.Wroclaw.RRM.VRF_WRO2_T07.resources.testline_preparation import get_sw_release_name

MAX_SFN = 1024
MICRO_DTX_DELAY_SFN = 1
EXPECTED_POWER_BENEFIT_PERCENT_LOWER = 0.2
EXPECTED_POWER_BENEFIT_PERCENT_HIGHER = 10

DL_DRB_DTX_CLASS = ['15', '18', '19', '27']
UPDATE_PRIO_CLASS_UP = 'UPDATEPRIORITYCLASSUPGRADE'
DTX_OPTIMIZED_DRB_TRAFFIC_CLASS = ['18', '21', '22', '31']
INVALID_PERIOD_ERROR_THRESHOLD = 5
CONDITIONAL_RELEASE_4 = int('SBTS25R1'[4:].replace('R', ''))


def check_highest_class_prio_for_optimized_dtx(tti_logs, rntis):
    blog('Check "highestClassPriority" in the "dlPreSchedData" event in TTI...')
    for rnti in rntis:
        check_highest_class_prio_for_rnti(tti_logs, rnti)
    blog('TTI analysed successfully.')


def check_highest_class_prio_for_rnti(tti_logs, rnti):
    blog('Starting highest class priority check for RNTI {}...'.format(rnti))
    all_dlPreSchedData = extract_dl_pre_sched_data_from_tti(tti_logs, rnti)

    dl_drb_dtx = []
    optimized_dtx = []
    for msg in all_dlPreSchedData:
        prio = msg['highestClassPriority']
        cs_list_event = msg['csListEvent']
        slot = int(msg['slot'])
        sfn = int(msg['sfn'])
        if prio in DL_DRB_DTX_CLASS and cs_list_event == UPDATE_PRIO_CLASS_UP:
            dl_drb_dtx.append((sfn, slot))
        elif prio in DTX_OPTIMIZED_DRB_TRAFFIC_CLASS:
            optimized_dtx.append((sfn, slot))

    check_dtx_opt_drb_traffic_class_msgs(optimized_dtx)
    check_dl_drb_dtx_class_period(dl_drb_dtx)
    blog('Highest class priority check for RNTI {} finished successfully.'.format(rnti))


def extract_dl_pre_sched_data_from_tti(tti_logs, rnti):
    with LogHelper() as lh:
        tti_finder = lh.add_tti(log_files=tti_logs)
        matcher = TTIMessageMatcher('dlPreSchedData').containing(key_pattern='rnti', val_pattern=rnti,
                                                                 regex_engine='re')
        return tti_finder.find_all(matcher)


def check_dtx_opt_drb_traffic_class_msgs(optimized_dtx):
    blog('Check whether the UE is assigned the "dtxOptimizedDrbTraffic" (prio 17) class at least once.')
    assert len(optimized_dtx) > 0, 'UE IS NEVER ASSIGNED THE "dtxOptimizedDrbTraffic"  CLASS'
    blog('"dtxOptimizedDrbTraffic" analysed successfully.')


def check_dl_drb_dtx_class_period(dl_drb_dtx):
    blog('Check whether the period between subsequent "dlDrbDtx" (prio 14) corresponds to "dtxMaxRetentionDelay"')
    assert len(dl_drb_dtx) > 0, 'UE IS NEVER ASSIGNED THE "dlDrbDtx" CLASS'

    invalid_period = 0
    for prev, current in pairwise(dl_drb_dtx):
        prev_sfn, prev_slot = prev
        current_sfn, current_slot = current
        if (current_sfn - prev_sfn) % MAX_SFN == MICRO_DTX_DELAY_SFN:
            if current_slot < prev_slot:
                invalid_period += 1
        if (current_sfn - prev_sfn) % MAX_SFN < MICRO_DTX_DELAY_SFN:
            invalid_period += 1

    invalid_period_percent = 100 * float(invalid_period) / len(dl_drb_dtx)
    blog('Percent of invalid period between subsequent "dlDrbDtx": {}%'.format(invalid_period_percent))

    assert invalid_period_percent <= INVALID_PERIOD_ERROR_THRESHOLD, \
        '"dlDrbDtx" class appears too often. Max error: {}%. Current error: {}%'.format(
            INVALID_PERIOD_ERROR_THRESHOLD, invalid_period_percent)
    blog('"dlDrbDtx" analysed successfully.')


def pairwise(iterable):
    """Return adjacent elements from an iterable."""
    a, b = tee(iterable)
    next(b, None)
    return zip(a, b)


def get_relevant_rmod_ip_from_smod(cmd_output, ru_serial_number):
    blog('Extracting available RUs from the "cat /rom/config/FRIps.txt" command output')

    ru_infos = [line for line in cmd_output.split('\r\n') if ru_serial_number in line]
    assert len(ru_infos) == 1, 'More than one matching RMOD entry found on SMOD.' \
        if len(ru_infos) else 'RMOD with given SN not found.'
    blog('Matching radios: {}'.format(ru_infos))

    ru_ips = [ru_entry.split(';')[2] for ru_entry in ru_infos]
    blog('Radio IP extracted successfully.')
    return ru_ips[0]


def evaluate_power_consumption_benefit(power_without_feature, power_with_feature, condition):
    blog('Evaluating whether the power consumption benefits for optimized DTX are satisfactory...')
    power_without_feature = float(power_without_feature)
    power_with_feature = float(power_with_feature)

    power_benefit = 100 * (power_without_feature - power_with_feature) / power_without_feature
    blog('Power benefit after turning optimized DTX on: {}%'.format(power_benefit))
    if condition == 'LOWER':
        assert power_benefit >= EXPECTED_POWER_BENEFIT_PERCENT_LOWER, 'POWER CONSUMPTION IS TOO HIGH'
    elif condition == 'HIGHER':
        assert power_benefit < EXPECTED_POWER_BENEFIT_PERCENT_HIGHER, 'POWER CONSUMPTION IS TOO LOW'
    blog('Power benefits evaluated correctly.')


@logged_keyword
def activate_micro_dtx_and_optimized_scheduler_specific_version_a(nr_delta, nrbts_dist_name, nrcell_dist_name):
    ds = DeltaStore()
    bts_sw_release = int(get_sw_release_name()[4:8].replace('R', ''))
    ds.initialise_delta_store(name=nr_delta)
    ds.add_parameters_to_delta(nrcell_dist_name, actPdschAtSsbSlots='false')
    ds.add_parameters_to_delta(nrcell_dist_name, actPdschRmCsirsForTracking='false')
    if bts_sw_release >= CONDITIONAL_RELEASE_4:
        ds.add_parameters_to_delta(nrcell_dist_name, actPdschAllocAroundSsb='false')
    if bts_sw_release < CONDITIONAL_RELEASE_4:
        ds.add_parameters_to_delta(nrbts_dist_name, actMicroDTX='true')
        ds.add_parameters_to_delta(nrbts_dist_name, actMicroDTXAdvanced='false')
    ds.add_parameters_to_delta(nrcell_dist_name, actDtxOptimizedScheduler='true')
    ds.add_parameters_to_delta(nrcell_dist_name, actEnhDtxOptimizedScheduler='true')

    if adm_api.assign_release_version() not in ['SBTS22R4', 'SBTS23R1']:
        ds.add_complex_item_to_delta(nrcell_dist_name, 'dtxOptimizedScheduler',
                                     dtxDelaySinceLastScheduling='0',
                                     dtxMaxRetentionDelay='10',
                                     dtxPrbThreshold='100',
                                     caSupportEnabled='false',
                                     drbDifferentiationEnabled='false',
                                     drxSupportEnabled='false',
                                     multiCellSyncEnabled='false',
                                     rlcStatusPduSupportEnabled='false')
    else:
        ds.add_complex_item_to_delta(nrcell_dist_name, 'dtxOptimizedScheduler',
                                     dtxDelaySinceLastScheduling='0',
                                     dtxMaxRetentionDelay='10',
                                     dtxPrbThreshold='100')

    delta_store = ds.collect_delta_store()
    ds.perform_delta_recommissioning(delta_store)


def activate_micro_dtx_and_optimized_scheduler_specific_version(nr_delta, nrbts_dist_name, nrcell_dist_name):
    ds = DeltaStore()
    bts_sw_release = int(get_sw_release_name()[4:8].replace('R', ''))
    ds.initialise_delta_store(name=nr_delta)
    ds.add_parameters_to_delta(nrcell_dist_name, actPdschAtSsbSlots='false')
    ds.add_parameters_to_delta(nrcell_dist_name, actPdschRmCsirsForTracking='false')
    if bts_sw_release >= CONDITIONAL_RELEASE_4:
        ds.add_parameters_to_delta(nrcell_dist_name, actPdschAllocAroundSsb='false')
    if bts_sw_release < CONDITIONAL_RELEASE_4:
        ds.add_parameters_to_delta(nrbts_dist_name, actMicroDTX='true')
        ds.add_parameters_to_delta(nrbts_dist_name, actMicroDTXAdvanced='false')
    delta_store = ds.collect_delta_store()
    ds.perform_delta_recommissioning(delta_store)


def deactivate_micro_dtx_and_optimized_scheduler(nr_delta, nrbts_dist_name, nrcell_dist_name):
    ds = DeltaStore()
    bts_sw_release = int(get_sw_release_name()[4:8].replace('R', ''))
    ds.initialise_delta_store(name=nr_delta)
    ds.add_parameters_to_delta(nrcell_dist_name, actPdschAtSsbSlots='false')
    ds.add_parameters_to_delta(nrcell_dist_name, actPdschRmCsirsForTracking='false')
    ds.add_parameters_to_delta(nrcell_dist_name, actDtxOptimizedScheduler='false')
    ds.add_parameters_to_delta(nrcell_dist_name, actEnhDtxOptimizedScheduler='false')
    if bts_sw_release >= CONDITIONAL_RELEASE_4:
        ds.add_parameters_to_delta(nrcell_dist_name, actPdschAllocAroundSsb='false')
    if bts_sw_release < CONDITIONAL_RELEASE_4:
        ds.add_parameters_to_delta(nrbts_dist_name, actMicroDTX='true')
        ds.add_parameters_to_delta(nrbts_dist_name, actMicroDTXAdvanced='false')
    delta_store = ds.collect_delta_store()
    ds.perform_delta_recommissioning(delta_store)
