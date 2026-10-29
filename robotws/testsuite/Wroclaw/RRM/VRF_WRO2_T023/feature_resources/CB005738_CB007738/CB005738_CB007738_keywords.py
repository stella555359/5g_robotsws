from robot.libraries.BuiltIn import BuiltIn

from testsuite.Wroclaw.RRM.VRF_WRO2_T023.resources.log_analyzer.log_helper import LogHelper
from testsuite.Wroclaw.RRM.VRF_WRO2_T023.resources.log_analyzer.matchers import SyslogMessageMatcher
from testsuite.Wroclaw.RRM.VRF_WRO2_T023.resources.log_analyzer.common.log import blog
from itertools import tee
from datetime import datetime

EXPECTED_SR_NR_ONLY = 95
EXPECTED_SR_NR_AND_LTE = 50
EXPECTED_SR_LTE_ONLY = 22


def compare_superfast_throughputs_for_lte(tput_lte_no_burst_with_superfast, tput_lte_no_burst_no_superfast,
                                          tput_lte_with_burst_with_superfast, tput_lte_with_burst_no_superfast,
                                          error_margin=10):
    blog('Start comparing throughput for LTE...')
    compare_superfast_throughputs(tput_lte_no_burst_with_superfast, tput_lte_no_burst_no_superfast,
                                  tput_lte_with_burst_with_superfast, tput_lte_with_burst_no_superfast,
                                  error_margin)
    blog('LTE throughput analysed successfully.')


def compare_superfast_throughputs_for_nr(tput_nr_no_burst_with_superfast, tput_nr_no_burst_no_superfast,
                                         tput_nr_with_burst_with_superfast, tput_nr_with_burst_no_superfast,
                                         error_margin=10):
    blog('Start comparing throughput for NR...')
    compare_superfast_throughputs(tput_nr_no_burst_with_superfast, tput_nr_no_burst_no_superfast,
                                  tput_nr_with_burst_with_superfast, tput_nr_with_burst_no_superfast, error_margin)
    blog('NR throughput analysed successfully.')


def compare_superfast_throughputs(tput_no_burst_with_superfast, tput_no_burst_no_superfast,
                                  tput_with_burst_with_superfast, tput_with_burst_no_superfast, error_margin):
    tput_margin = float(tput_no_burst_no_superfast) * float(error_margin) / 100.0
    assert abs(float(tput_no_burst_no_superfast) - float(tput_no_burst_with_superfast)) <= tput_margin, \
        'Throughput without burst does not meet the superfast requirements (it is too low).'
    assert abs(float(tput_with_burst_no_superfast) - float(tput_with_burst_with_superfast)) <= tput_margin, \
        'Throughput with burst does not meet the superfast requirements (it is too low).'


def analyse_crm_logs_with_superfast(btslog, release):
    analyse_crm_logs(btslog, 10, lambda x, y: x <= y, release)


def analyse_crm_logs(btslog, period_threshold, comparison_method, release):
    with LogHelper() as lh:
        syslog = lh.add_syslog(btslog)

        if release:
            pattern = '*CRM*/A *'
        else:
            pattern = '*CRM*Alloc*'
        print(f"Using pattern: {pattern}")
        alloc_msgs = syslog.find_all(SyslogMessageMatcher(pattern))

        alloc_msgs = [x for x in alloc_msgs if len(x) < int(get_robot_variable('UL_CRM_LOG_LENGTH'))]
        assert alloc_msgs, 'No sign of CRM logs containing Alloc information.'

        periods = calculate_periods(alloc_msgs)
        avg_period = sum(periods) / len(periods)
        blog('PERIODS: {}'.format(periods))
        blog('AVERAGE_PERIOD: {}'.format(avg_period))

        count_good = len([x for x in periods if comparison_method(int(x), int(period_threshold))])
        count_all = len(periods)
        count_errors = count_all - count_good
        error_in_percent = float(count_errors) * 100 / count_all
        blog('ERROR_PERCENT: {}'.format(error_in_percent))

        assert error_in_percent < float(get_robot_variable('ALLOC_PERIOD_ERROR_THRESHOLD')), \
            'Allocation period does not meet requirements.'


def calculate_periods(alloc_msgs):
    """Calculate time difference between instances of CRM allocation message print from syslog."""
    periods = []
    for current, _next in pairwise(alloc_msgs):
        current_time = extract_timestamp(current)
        next_time = extract_timestamp(_next)
        diff = next_time - current_time
        periods.append(diff.microseconds / 1000)

    return periods


def pairwise(iterable):
    """Return adjacent elements from an iterable."""
    a, b = tee(iterable)
    next(b, None)
    return zip(a, b)


def extract_timestamp(line):
    """Extract timestamp from syslog line."""
    TIME_IDX = 1
    time_string = line.split(' ')[TIME_IDX]
    timestamp = datetime.strptime(time_string, '%H:%M:%S.%f')
    return timestamp


def get_robot_variable(variable_name):
    variable_signature = '${{{variable_name}}}'.format(variable_name=variable_name)
    return BuiltIn().get_variable_value(variable_signature)


def verify_dss3_max_throughputs(nr_only, nr_and_lte, lte_only, error_in_percent=10):
    blog('Start comparing throughputs for DSS Ph3...')
    nr_only_throughput_target = float(get_robot_variable('NR_ONLY_THROUGHPUT_TARGET'))
    nr_tput_with_lte = float(get_robot_variable('NR_THROUGHPUT_TARGET_WITH_LTE'))
    lte_tput_with_nr = float(get_robot_variable('LTE_THROUGHPUT_TARGET_WITH_NR'))
    lte_only_throughput_target = float(get_robot_variable('LTE_ONLY_THROUGHPUT_TARGET'))

    compare_nr_only_throughput(nr_only, nr_only_throughput_target, error_in_percent)
    compare_nr_and_lte_throughputs(nr_and_lte, [nr_tput_with_lte, lte_tput_with_nr], error_in_percent)
    compare_lte_only_throughput(lte_only, lte_only_throughput_target, error_in_percent)
    blog('DSS Ph3 throughputs analysed successfully.')


def compare_nr_only_throughput(actual_throughput, target_throughput, error_in_percent):
    blog('Start comparing NR throughput...')
    verify_x_greater_than_y(actual_throughput / 1000, target_throughput, error_in_percent,
                            'NR throughput is not as expected')
    blog('NR throughput comparison completed successfully.')


def compare_nr_and_lte_throughputs(actual_throughputs, target_throughputs, error_in_percent):
    blog('Start comparing NR and LTE throughput...')
    verify_x_greater_than_y(actual_throughputs[0] / 1000, target_throughputs[0], error_in_percent,
                            'NR throughput is not as expected')
    verify_x_greater_than_y(actual_throughputs[1] / 1000, target_throughputs[1], error_in_percent,
                            'LTE throughput is not as expected')
    blog('NR and LTE throughput comparison completed successfully.')


def compare_lte_only_throughput(actual_throughput, target_throughput, error_in_percent):
    blog('Start comparing LTE throughput...')
    verify_x_greater_than_y(actual_throughput / 1000, target_throughput, error_in_percent,
                            'LTE throughput is not as expected')
    blog('LTE throughput comparison completed successfully.')


def verify_x_greater_than_y(x, y, error_in_percent, assert_msg='Conditions were not met.'):
    max_deviation = float(y * error_in_percent) / 100.0
    assert float(x) > float(y) - max_deviation, assert_msg


def analyse_sharing_ratio_nr_only(btslog, error_margin):
    analyse_sharing_ratio_logs(btslog, EXPECTED_SR_NR_ONLY, error_margin)


def analyse_sharing_ratio_nr_and_lte(btslog, error_margin):
    analyse_sharing_ratio_logs(btslog, EXPECTED_SR_NR_AND_LTE, error_margin)


def analyse_sharing_ratio_lte_only(btslog, error_margin):
    analyse_sharing_ratio_logs(btslog, EXPECTED_SR_LTE_ONLY, error_margin)


def analyse_sharing_ratio_logs(btslog, expected_sharing_ratio, error_margin):
    crm_logs = extract_crm_logs_from_syslog(btslog)
    sharing_ratios = [extract_sharing_ratio_from_crm_log(crm_log) for crm_log in crm_logs if crm_log]
    sharing_ratios = [x for x in sharing_ratios if x]

    verify_sharing_ratios(sharing_ratios, 'LteRatio and NrRatio do not sum up to 100.')
    avg_nr_ratio, avg_lte_ratio = calculate_avg_sharing_ratio(sharing_ratios)

    blog('NrRatio: {}'.format(avg_nr_ratio))
    blog('LteRatio: {}'.format(avg_lte_ratio))

    assert abs(avg_nr_ratio - float(expected_sharing_ratio)) <= float(error_margin), \
        'Sharing ratio is {}. Should be {}'.format(avg_nr_ratio, expected_sharing_ratio)


def extract_crm_logs_from_syslog(btslog):
    with LogHelper() as lh:
        syslog = lh.add_syslog(btslog)
        gnb_id_hex = get_robot_variable('GNB_ID_HEX')
        pci_hex = get_robot_variable('NR_PCI_HEX')
        crm_sharing_ratio_prints = syslog.find_all(
            SyslogMessageMatcher('*CRMexe*CRM*g{}*c{}*CrmDlStatus*'.format(gnb_id_hex, pci_hex)))
        assert crm_sharing_ratio_prints, 'No sign of CRM logs in Syslog.'
        return crm_sharing_ratio_prints


def extract_sharing_ratio_from_crm_log(crm_log):
    crm_log = crm_log.split('CrmDlStatus:')[-1]
    crm_log = crm_log.split(':')
    lte_ratio = crm_log[1].split(' ')[0]
    nr_ratio = crm_log[2].split(' ')[0]

    try:
        lte_ratio = float(lte_ratio)
        nr_ratio = float(nr_ratio)
    except ValueError:
        return None

    return nr_ratio, lte_ratio


def verify_sharing_ratios(sharing_ratios, assert_msg):
    assert all(is_correct_sharing_ratio_pair(lte_ratio, nr_ratio) for nr_ratio, lte_ratio in sharing_ratios), \
        assert_msg


def is_correct_sharing_ratio_pair(lte_ratio, nr_ratio):
    float_comparison_margin = 0.1
    return abs(100 - lte_ratio - nr_ratio) < float_comparison_margin


def calculate_avg_sharing_ratio(sharing_ratios):
    return [sum(x) / len(x) for x in zip(*sharing_ratios)]
