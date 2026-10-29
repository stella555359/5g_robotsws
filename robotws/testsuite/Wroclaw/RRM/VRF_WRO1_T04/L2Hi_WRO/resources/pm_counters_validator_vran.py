from robot.libraries.BuiltIn import BuiltIn
from robot.errors import ExecutionFailed
from collections import OrderedDict
from robot.api import logger

LOCAL_MOID_BTS_CELL1 = 'PLMN-PLMN/MRBTS-1/NRBTS-1/NRCELL-1'
COUNTER_ID_UL_RLC_VOL_UE_TPUT_PMQAP = 'M55353C00001'
COUNTER_ID_UL_RLC_VOL_UE_TPUT_QOS06 = 'M55349C01006'
COUNTER_ID_UL_RLC_TIME_UE_TPUT_PMQAP = 'M55353C01001'
COUNTER_ID_UL_RLC_TIME_UE_TPUT_QOS06 = 'M55349C00006'
COUNTER_ID_DL_PDCP_VOL_UE_TPUT_QOS06 = 'M55350C01006'
COUNTER_ID_DL_PDCP_VOL_UE_TPUT_PMQAP = 'M55352C01001'
COUNTER_ID_DL_PDCP_TIME_UE_TPUT_PMQAP = 'M55352C00001'
COUNTER_ID_DL_PDCP_TIME_UE_TPUT_QOS06 = 'M55350C00006'
COUNTER_ID_DL_PDCP_VOL_UE_TPUT_LTE_QOS06 = 'M55350C05006'


def process_counter_value(counter_value, counter_id):
    if counter_value is None:
        raise ExecutionFailed(
            message=f'Counter {counter_id} value is None, check if counter is enabled and local moid path is correct.',
            continue_on_failure=True
        )
    else:
        logger.info(
            f'The PM counter {counter_id} actual value: {counter_value}',
            html=True, also_console=True
        )
        return int(counter_value)


def compare_counter_value(value, counter_value, counter_id, comparison_type):
    processed_value = process_counter_value(counter_value, counter_id)
    expected_value = int(value)

    if comparison_type == 'lower':
        if processed_value >= expected_value:
            raise ExecutionFailed(
                message=f'The PM counter {counter_id} actual value: {counter_value} - '
                        f'the value should be lower than: {expected_value}',
                continue_on_failure=True,
            )

    elif comparison_type == 'bigger':
        if processed_value <= expected_value:
            raise ExecutionFailed(
                message=f'The PM counter {counter_id} actual value: {counter_value} - '
                        f'the value should be bigger than: {expected_value}',
                continue_on_failure=True,
            )
    elif comparison_type == 'exact':
        if processed_value != expected_value:
            raise ExecutionFailed(
                message=f'The PM counter {counter_id} actual value: {counter_value} - '
                        f'the value is not equal to: {expected_value}',
                continue_on_failure=True,
            )
    else:
        raise ValueError(f'Invalid comparison type: {comparison_type}')


def check_if_values_of_pm_counters_are_same(actual_value_for_first_counter_id, actual_value_for_second_counter_id):
    if actual_value_for_first_counter_id == 0 or actual_value_for_second_counter_id == 0:
        raise ExecutionFailed(
            message='The values of PM counters {} or {} are equal to 0'.format(
                actual_value_for_first_counter_id, actual_value_for_second_counter_id),
            continue_on_failure=True
        )
    elif actual_value_for_first_counter_id != actual_value_for_second_counter_id:
        raise ExecutionFailed(
            message='The values of PM counters {} and {} are different'.format(
                actual_value_for_first_counter_id, actual_value_for_second_counter_id),
            continue_on_failure=True,
        )
