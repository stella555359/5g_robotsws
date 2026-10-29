from jinja2 import Template
import os
import testsuite.Wroclaw.RRM.resources.webUI_operations as webUI
from testsuite.Wroclaw.RRM.VRF_WRO2_T07.resources.decorators import logged_keyword

DELTA_DIR = os.path.join(os.path.dirname(os.path.abspath(__file__)), 'delta_templates')


def load_delta_template(filename):
    delta_filepath = os.path.join(DELTA_DIR, filename)
    with open(delta_filepath) as f:
        return Template(f.read())


@logged_keyword
def change_CB013438_configuration_and_schedul_weights(faf_CB013438, SNSSAI_1_sched_weight, SNSSAI_2_sched_weight):
    template = load_delta_template('TC_11_CB013438_template.json')
    delta = template.render(faf_CB013438=faf_CB013438, SNSSAI_1_sched_weight=SNSSAI_1_sched_weight,
                            SNSSAI_2_sched_weight=SNSSAI_2_sched_weight)
    __perform_delta(delta)


def __perform_delta(delta_str):
    with webUI.WebUIOperations() as coam:
        coam.perform_delta_recommissioning(delta_file=delta_str, skip_parameter_relation_errors=False,
                                           should_activate=True, timeout=300)


def compare_counters_after_algorithm_switch(counters_legacy_wrr, counters_enh_wrr, expected_behavior):
    if expected_behavior == 'increased':
        check_if_counters_increased(counters_legacy_wrr, counters_enh_wrr)
    elif expected_behavior == 'decreased':
        check_if_counters_decreased(counters_legacy_wrr, counters_enh_wrr)
    elif expected_behavior == 'equal':
        check_if_counters_equal(counters_legacy_wrr, counters_enh_wrr)


def check_if_counters_increased(counters_legacy, counters_enh):
    for leg, enh in zip(counters_legacy, counters_enh):
        if leg < enh:
            continue
        raise ValueError('Counters not increased!', counters_legacy, counters_enh)


def check_if_counters_decreased(counters_legacy, counters_enh):
    for leg, enh in zip(counters_legacy, counters_enh):
        if leg > enh:
            continue
        raise ValueError('Counters not decreased!', counters_legacy, counters_enh)


def check_if_counters_equal(counters_legacy, counters_enh):
    for leg, enh in zip(counters_legacy, counters_enh):
        if leg == enh:
            continue
        raise ValueError('Counters not equal!', counters_legacy, counters_enh)


def compare_KPIs_after_algorithm_switch(counters_legacy_wrr, counters_enh_wrr, expected_behavior, KPI_name):
    if expected_behavior == 'increased':
        legacy, enhanced = get_KPIs(counters_legacy_wrr, counters_enh_wrr, KPI_name)
        if legacy > enhanced:
            raise ValueError('KPIs not increased!', legacy, enhanced)
    elif expected_behavior == 'decreased':
        legacy, enhanced = get_KPIs(counters_legacy_wrr, counters_enh_wrr, KPI_name)
        if legacy < enhanced:
            raise ValueError('KPIs not decreased!', legacy, enhanced)
    elif expected_behavior == 'equal':
        legacy, enhanced = get_KPIs(counters_legacy_wrr, counters_enh_wrr, KPI_name)
        if legacy != enhanced:
            raise ValueError('KPIs not equal!', legacy, enhanced)
    elif expected_behavior == 'undefined':
        legacy, enhanced = get_KPIs(counters_legacy_wrr, counters_enh_wrr, KPI_name)
        if legacy != -1 and enhanced != -1:
            raise ValueError('KPIs not undefined!', legacy, enhanced)


def get_KPIs(counters_legacy_wrr, counters_enh_wrr, KPI_name):
    legacy = -1
    enhanced = -1
    if KPI_name == 'NR_5192e':
        legacy = calculate_KPI_NR_5192e(counters_legacy_wrr)
        enhanced = calculate_KPI_NR_5192e(counters_enh_wrr)
    elif KPI_name == 'NR_5193b':
        legacy = calculate_KPI_NR_5193b(counters_legacy_wrr)
        enhanced = calculate_KPI_NR_5193b(counters_enh_wrr)
    elif KPI_name == 'NR_5888a':
        legacy = calculate_KPI_NR_5888a(counters_legacy_wrr)
        enhanced = calculate_KPI_NR_5888a(counters_enh_wrr)
    elif KPI_name == 'NR_5887a':
        legacy = calculate_KPI_NR_5887a(counters_legacy_wrr)
        enhanced = calculate_KPI_NR_5887a(counters_enh_wrr)
    elif KPI_name == 'NR_5244e':
        legacy = calculate_KPI_NR_5244e(counters_legacy_wrr)
        enhanced = calculate_KPI_NR_5244e(counters_enh_wrr)
    elif KPI_name == 'NR_5245d':
        legacy = calculate_KPI_NR_5245d(counters_legacy_wrr)
        enhanced = calculate_KPI_NR_5245d(counters_enh_wrr)
    return legacy, enhanced


def calculate_KPI_NR_5192e(counters):
    return counters[0] / (counters[1] + counters[2] + counters[3])


def calculate_KPI_NR_5193b(counters):
    return counters[0] / (counters[1] + counters[2])


def calculate_KPI_NR_5888a(counters):
    if counters[1] != 0:
        return counters[0] / counters[1]
    return -1


def calculate_KPI_NR_5887a(counters):
    if counters[1] != 0:
        return counters[0] / counters[1]
    return -1


def calculate_KPI_NR_5244e(counters):
    sum_A = 8 * sum(counters[0:56]) / counters[57]
    sum_B = counters[58] / counters[59]
    sum_C = counters[60] / (counters[61] + counters[62] + counters[63])

    return sum_A / sum_B / sum_C


def calculate_KPI_NR_5245d(counters):
    sum_A = 8 * sum(counters[0:84]) / counters[85]
    sum_B = counters[86] / counters[87]
    sum_C = counters[88] / (counters[89] + counters[90])

    return sum_A / sum_B / sum_C
