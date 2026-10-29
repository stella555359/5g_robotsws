"""
:copyright: Nokia Networks
:authors:
    Michal Gorski <michal.gorski@nokia.com>
    Kamil Krawiec <kamil.krawiec@nokia.com>
    Arkadiusz Sobejko <arkadiusz.sobejko@nokia.com>
    Patryk Wójcik <patryk.wojcik@nokia.com>
:maintainers:
    Michal Gorski <michal.gorski@nokia.com>
    Kamil Krawiec <kamil.krawiec@nokia.com>
    Arkadiusz Sobejko <arkadiusz.sobejko@nokia.com>
    Patryk Wójcik <patryk.wojcik@nokia.com>
"""

from ta5g_pm_counters import ta5g_pm_counters
from testsuite.Wroclaw.RRM.VRF_WRO1_T04.L2Hi_WRO.resources_kr.python.csv_verifiers import csv_verifiers
from robot.libraries.BuiltIn import BuiltIn
from ta_emss import ta_emss
from robot.api import logger

csv_tti_trace = csv_verifiers()
pm_counters = ta5g_pm_counters()
emss = ta_emss(host='10.0.1.1', port=4001)


def get_num_of_schedule_delay_drx_denominator(csv_path):
    """
    :param csv_path: File path to tti trace csv file
    :return: Number of rrmtotaldrbbufferedbyte occurrences used to calculate schedule delay drx denominator
    """
    csv_list = csv_tti_trace.create_list_of_lists_from_csv(csv_path)
    timestamp = 'timeStamp'
    buffered_bytes = 'dlFdSchedData.rrmtotalDrbBufferedBytes'
    scheduled_bytes = 'dlFlowControlData.scheduledBytes'
    traces = csv_tti_trace.get_multiple_columns_values(timestamp, buffered_bytes, scheduled_bytes,
                                                       input_list=csv_list, as_dict=True)

    dnm_counter = 0
    with open(f'{BuiltIn().get_variable_value("${OUTPUTDIR}")}/filtered_tti_trace.csv', 'w', newline='') as csvfile:
        csvfile.write(f'{timestamp},{buffered_bytes},{scheduled_bytes}\n')
        for i in range(len(traces[buffered_bytes])):
            if str(traces[buffered_bytes][i]) != '' and int(float(traces[buffered_bytes][i])) != 0 and str(
                    traces[scheduled_bytes][i]) != '':
                if int(float(traces[buffered_bytes][i])) < int(float(traces[scheduled_bytes][i])):
                    csvfile.write(f'{traces[timestamp][i]},{traces[buffered_bytes][i]},{traces[scheduled_bytes][i]}\n')
                    dnm_counter += 1

    return dnm_counter


def get_counters_values(counters, localmoid, filepath, id=1):
    """
    :return: counter_values (dict) {counter_name : value}
    """
    counter_values = {}
    list_of_counters = [x for x in counters.split(',')]
    for counter in list_of_counters:
        counter_value = pm_counters.get_pm_counter_value(counter, localmoid, filepath)
        counter_values[counter] = counter_value[id - 1]
    logger.info(f'Collected pm counters: {counter_values}')

    return counter_values


def compare_dl_schedule_delay_dnm_from_tti_trace_to_pm_counters(tti_trace_path, counters, localmoid,
                                                                counters_path, id=1):
    """
    Function that compares dl schedule delay denominator calculated from tti trace to PM counters
    """
    schedule_delay_drx_denominator = get_num_of_schedule_delay_drx_denominator(csv_path=tti_trace_path)
    counters_values = get_counters_values(counters=counters, localmoid=localmoid, filepath=counters_path, id=id)
    sum_of_dnm_counters = sum(counters_values.values())
    logger.info(f'Value from tti trace: {schedule_delay_drx_denominator}, Value from counters: {sum_of_dnm_counters}')
    logger.info(f'Ratio: {schedule_delay_drx_denominator / sum_of_dnm_counters}')

    assert 96.5 < sum_of_dnm_counters / schedule_delay_drx_denominator * 100 < 103.5, \
        (f"The difference beetween value from tti trace: {schedule_delay_drx_denominator} "
         f"and from counters: {sum_of_dnm_counters} is too big")


def get_drx_ratio_for_counters(counters, localmoid, counters_path, pmqap=False, id=1):
    """
    Function that get drx schedule to denominator ratio for given counters
    """
    counters_values = get_counters_values(counters=counters, localmoid=localmoid, filepath=counters_path, id=id)

    if pmqap:
        drx_act_ratio = counters_values['M55356C00004'] / counters_values['M55356C00006']
        drx_inact_ratio = counters_values['M55356C00005'] / counters_values['M55356C00007']

    elif not pmqap:
        drx_act_ratio = counters_values['M55308C00057'] / counters_values['M55308C00058']
        drx_inact_ratio = counters_values['M55308C00060'] / counters_values['M55308C00061']

    logger.info(f'drx_act_ratio: {drx_act_ratio}, drx_inact_ratio: {drx_inact_ratio}')
    drx_profile = emss.get_object_attributes(object_name='NRDRX-1')
    drx_long_cycle = int(drx_profile["drxlongcycle"][:-2]) * 1000
    drx_on_duration = int(drx_profile["drxondurationtimer"][:-2]) * 1000

    return drx_act_ratio, drx_inact_ratio, drx_long_cycle, drx_on_duration


def check_schedule_delay_to_dnm_ratio(counters, localmoid, counters_path, technology, pmqap=False, id=1):
    """
    Function that checks schedule delay counter to denominator ratio
    """
    drx_act_ratio, drx_inact_ratio, drx_long_cycle, drx_on_duration = get_drx_ratio_for_counters(
        counters, localmoid, counters_path, pmqap, id)
    if technology == "TDD_FR1":
        assert 500 <= drx_act_ratio <= 1000, f"Ratio should be between 500-1000us. Drx_act_ratio: {drx_act_ratio}"
        assert 500 <= drx_inact_ratio <= drx_long_cycle - drx_on_duration, \
            f"Ratio should be between 1000-{drx_long_cycle - drx_on_duration}us. Drx_inact_ratio: {drx_inact_ratio}"
    elif technology == "FDD_FR1":
        assert 1000 <= drx_act_ratio <= 2000, f"Ratio should be between 1000-2000us. Drx_act_ratio: {drx_act_ratio}"
        assert 1000 <= drx_inact_ratio <= drx_long_cycle - drx_on_duration, \
            f"Ratio should be between 2000-{drx_long_cycle - drx_on_duration}us. Drx_inact_ratio: {drx_inact_ratio}"
    elif technology == "TDD_FR2":
        assert 125 <= drx_act_ratio <= 250, f"Ratio should be between 125-250us. Drx_act_ratio: {drx_act_ratio}"
        assert 125 <= drx_inact_ratio <= drx_long_cycle - drx_on_duration, \
            f"Ratio should be between 250-{drx_long_cycle - drx_on_duration}us. Drx_inact_ratio: {drx_inact_ratio}"
    else:
        return f"Parameter 'technology' should be one of [TDD_FR1, FDD_FR1, TDD_FR2] but is: {technology} "


def check_counters_equality(counters, localmoid, counters_path):
    """
    Checks counters equality
    """
    counters_values = get_counters_values(counters=counters, localmoid=localmoid, filepath=counters_path)

    assert counters_values['M55356C00004'] == counters_values['M55308C00057'], \
        "Counters M55356C00004 and M55308C00057 not equal"
    assert counters_values['M55356C00006'] == counters_values['M55308C00058'], \
        "Counters M55356C00006 and M55308C00058 not equal"
    assert counters_values['M55356C00005'] == counters_values['M55308C00060'], \
        "Counters M55356C00005 and M55308C00060 not equal"
    assert counters_values['M55356C00007'] == counters_values['M55308C00061'], \
        "Counters M55356C00007 and M55308C00061 not equal"
