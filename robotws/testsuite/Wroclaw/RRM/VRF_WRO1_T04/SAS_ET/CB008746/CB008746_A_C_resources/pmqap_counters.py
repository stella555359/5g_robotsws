"""
:copyright: Nokia Networks
:author: Mateusz Lesniak
:maintainer: CD ET Squad
:contact: i_cd_et_testers@internal.nsn.com
:team: MN_RAN_L2_SW_2_KRK_CntDlv_SG
"""
from itertools import chain

from robot.errors import ExecutionFailed

from testsuite.Wroclaw.RRM.sim_resources.Krk_regression.MN_RAN_L2.resources.Python.pm_counters import \
    manage_resource_groups_with_counters_collection, get_pm_counters_values, \
    get_latest_values_for_specified_counters, get_latest_counter_value
from testsuite.Wroclaw.RRM.sim_resources.Krk_regression.MN_RAN_L2.resources.Python.utilities import logger_console_info


def _get_pmqap_counters_values(nrpmqap_ids, cell):
    pm_counters_data = get_pm_counters_values(['M55363C00001', 'M55363C00003'])
    counter_values = []
    for pmqap in nrpmqap_ids:
        prbs_used = get_latest_values_for_specified_counters(
            ['M55363C00001'], path_filters=f'NRCELL-{cell}/NRPMQAP-{pmqap}/PTHPQ',
            counters_data=pm_counters_data)
        max_util_prbs = get_latest_values_for_specified_counters(
            ['M55363C00003'], path_filters=f'NRCELL-{cell}/NRPMQAP-{pmqap}/PTHPQ',
            counters_data=pm_counters_data)
        counter_values.append((prbs_used['M55363C00001'], max_util_prbs['M55363C00003']))
    return counter_values


def _calculate_pmqap_counters(slice_scheduler_counter_values, pmqap_counter_values, max_validation_diff):
    log_msgs = []
    failed_results = []
    max_validation_diff_perc = max_validation_diff / 100
    for slice_scheduler_counter, pmqap_counter in zip(slice_scheduler_counter_values, pmqap_counter_values):
        rat = float(slice_scheduler_counter[0]) / (float(pmqap_counter[0]) * 100)
        ratio_status = 1.0 - max_validation_diff_perc <= rat <= 1.0 + max_validation_diff_perc
        log_msgs.append(
            {
             'status': ratio_status,
             'msg': f'Difference between counter DL_PRB_USED_DATA_PMQAP and DL_PRB_USED_DATA_NRG is {(1-rat)*100}%'
             }
        )

        ratio_status = float(pmqap_counter[1]) >= float(slice_scheduler_counter[1])

        log_msgs.append(
            {
             'status': ratio_status,
             'msg': f'Counter DL_PRB_UTIL_SLOT_MAX_PMQAP({pmqap_counter[1]}) is greater than '
                    f'DL_PRB_UTIL_SLOT_MAX_NRG({slice_scheduler_counter[1]})'
            }
        )

    for result in log_msgs:
        if result['status']:
            logger_console_info(result['msg'])
        else:
            failed_results.append(result['msg'])

    return failed_results


def validate_pmqap_counters(resource_groups_nsa_sa={'NSA': (1, 2, 3)}, max_validation_diff=5, cell='1'):
    slice_scheduler_counter_values, joined_slices, prbs_avail_cell1 = manage_resource_groups_with_counters_collection(
        resource_groups_nsa_sa=resource_groups_nsa_sa, cell=cell)
    pmqap_counter_values = _get_pmqap_counters_values(nrpmqap_ids=[1, 2, 3], cell=cell)

    failed_results = _calculate_pmqap_counters(list(chain(*slice_scheduler_counter_values)), pmqap_counter_values,
                                               max_validation_diff)

    if len(failed_results) >= 1:
        raise ExecutionFailed(message='\n'.join(failed_results))


def _get_multiple_bwp_counters_values(cell_id=3):
    prbs_smaller_bwp_value = get_latest_counter_value(counter_id='M55308C29001', nr_cell_id=cell_id)[-1]
    prbs_bigger_bwp_value = get_latest_counter_value(counter_id='M55308C29003', nr_cell_id=cell_id)[-1]
    return prbs_smaller_bwp_value, prbs_bigger_bwp_value


def _calculate_multiple_bwp_counters(prbs_smaller_bwp_value, prbs_bigger_bwp_value):
    log_msgs = []
    sum_of_both_counters = (prbs_smaller_bwp_value + prbs_bigger_bwp_value)
    smaller_bwp_percent = round(float(prbs_smaller_bwp_value / sum_of_both_counters) * 100.0)
    bigger_bwp_percent = round(float(prbs_bigger_bwp_value / sum_of_both_counters) * 100.0)
    smaller_bwp_status = smaller_bwp_percent < 1
    log_msgs.append(
        {'status': smaller_bwp_status,
         'msg': f'status: {smaller_bwp_status} PRBs used for PDSCH for smaller BWP is {round(smaller_bwp_percent)}% '
                f'of the sum of both counters while < 1% expected.'})
    bigger_bwp_status = bigger_bwp_percent > 99
    log_msgs.append(
        {'status': bigger_bwp_status,
         'msg': f'status: {bigger_bwp_status} PRBs used for PDSCH for bigger BWP is {round(bigger_bwp_percent)}% '
                f'of the sum of both counters while > 99% expected.'})
    return log_msgs


def validate_multiple_bwp_counters():
    failed_results = []
    prbs_smaller_bwp_value, prbs_bigger_bwp_value = _get_multiple_bwp_counters_values()
    results = _calculate_multiple_bwp_counters(prbs_smaller_bwp_value, prbs_bigger_bwp_value)
    for result in results:
        if result['status']:
            logger_console_info(result['msg'])
        else:
            failed_results.append(result['msg'])
    if len(failed_results) >= 1:
        raise ExecutionFailed(message='\n'.join(failed_results))
