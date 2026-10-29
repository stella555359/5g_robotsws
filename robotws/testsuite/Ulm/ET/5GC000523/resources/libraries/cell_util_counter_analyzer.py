import re


def sample_count_analyzer(no_slots_per_frame, interval_pm, sampling_period=20):
    """ Generating expected values for the following counters:
        M55308C01000   Sample count for DL UE amount counters
        M55308C01001   Sample count for UL UE amount counters
    """
    interval_pm = int(re.split('min', interval_pm)[0])
    sample_count = int(float(interval_pm*60*1000) / (float(sampling_period)*10.0/float(no_slots_per_frame)))
    expected_pi_value = {"M55308C01000": sample_count, "M55308C01001": sample_count}
    return expected_pi_value


def sample_count_verdict(counters_to_be_analyzed, expected_pi_value, abs_tolerance=20,
                         permitted_relative_tolerance=0.1):
    failed_counter = []
    verdict_test = True
    for counter in counters_to_be_analyzed:
        verdict_per_counter = True
        fail_type_ctr = 0
        relative_tolerance_deviation = 0
        fail_type = "None"
        failed_counter_log = ""
        absolute_tolerance_limits = absolute_tolerance_evaluator(expected_pi_value[counter], int(abs_tolerance))
        calculated_relative_tolerance = relative_tolerance_evaluator(counters_to_be_analyzed[counter],
                                                                     expected_pi_value[counter])
        if absolute_tolerance_limits["LowerLimit"] <= counters_to_be_analyzed[counter] <= \
                absolute_tolerance_limits["UpperLimit"]:
            verdict_per_counter = verdict_per_counter and True
        else:
            verdict_per_counter = verdict_per_counter and False
            fail_type = "Absolute Tolerance Test"
            fail_type_ctr += 1

        if float(calculated_relative_tolerance) < float(permitted_relative_tolerance):
            verdict_per_counter = verdict_per_counter and True
        else:
            verdict_per_counter = verdict_per_counter and False
            relative_tolerance_deviation = calculated_relative_tolerance - float(permitted_relative_tolerance)
            fail_type = "Relative Tolerance Test"
            fail_type_ctr += 1

        if fail_type_ctr > 1:
            fail_type = "Absolute and Relative Tolerance Test"

        if not (verdict_per_counter):
            failed_dict = {counter: {"Counter_Value": counters_to_be_analyzed[counter],
                                     "Expected_Value": expected_pi_value[counter],
                                     "Absolute_Tolerance_Range": absolute_tolerance_limits,
                                     "Failure_in_test_type": fail_type,
                                     "Relative_tolerance_deviation": relative_tolerance_deviation,
                                     }}
            failed_counter.append(failed_dict)
        verdict_test = verdict_test and verdict_per_counter
    if verdict_test:
        verdict = "PASS"
    else:
        verdict = "FAIL"
        failed_counter_log = log_failed_counters(failed_counter)
    return verdict, failed_counter_log


def slot_ratio_calculator(extract_to_be_analyzed):
    """	DL Data Slot        M55308C00001
        UL Data Slot        M55308C00002
        SS Burst Slot       M55308C00003
        Random Access Slot  M55308C00004
    """
    ulslots = float(int(extract_to_be_analyzed['M55308C00002'])+int(extract_to_be_analyzed['M55308C00004']))
    dlslots = float(int(extract_to_be_analyzed['M55308C00001'])+int(extract_to_be_analyzed['M55308C00003']))
    calculated_ratio = ulslots/dlslots

    return calculated_ratio


def extractor(pi_dict, required_pi_list, distname, index=0):
    try:
        extract_to_be_analyzed = generate_dict_pm_values(pi_dict, required_pi_list, distname, index)
        return extract_to_be_analyzed
    except IndexError:
        print("Check Index used!")
        return 0
    except KeyError:
        print("Check Cell Number used")
        return 0


def generate_dict_pm_values(pi_dict, required_pi_list, dist_name, index=0):
    values_to_be_analyzed = {}
    for ctr in required_pi_list:
        values_to_be_analyzed[ctr] = get_counter_value(pi_dict, ctr, dist_name, int(index))
    return values_to_be_analyzed


def slot_type_counter_analyzer(extract_to_be_analyzed, expected_slot_ratio):
    try:
        fraction_split = (re.split('/', expected_slot_ratio))
        expected_slot_ratio = float(fraction_split[0])/float(fraction_split[1])
        result = slot_ratio_calculator(extract_to_be_analyzed)
        if round(result, 2) == float(expected_slot_ratio):
            return "PASS"
        else:
            return "FAIL"
    except TypeError:
        return "No data to be analyzed, Check if PM Data exists for the cell and it's corresponding index"


def absolute_tolerance_evaluator(value, abs_tolerance):
    upperlimit_abs = value + abs_tolerance
    lowerlimit_abs = value - abs_tolerance
    absoulte_tolerance_limits = {"UpperLimit": upperlimit_abs, "LowerLimit": lowerlimit_abs}
    return absoulte_tolerance_limits


def relative_tolerance_evaluator(value, expected):
    relative_tolerance = (float(abs(value-expected))/float(expected))*100
    return relative_tolerance


def log_failed_counters(failed_counter):
    result_str = "\nThe following counter(s) failed !"
    for counter in failed_counter:
        counter_name = list(counter.keys())[0]
        result = ("\nCounter Name : %s \nExpected Value : %s \nActual Value : %s\nType of test failed : %s\n"
                  "Absoulte tolerance range : %s\nRelative tolerance deviation : %s\n" %
                  (counter_name, counter[counter_name]['Expected_Value'], counter[counter_name]['Counter_Value'],
                   counter[counter_name]['Failure_in_test_type'], counter[counter_name]['Absolute_Tolerance_Range'],
                   counter[counter_name]['Relative_tolerance_deviation']))
        result_str += result
    return result_str


def get_counter_value(pi_dict, pi, dist_name, index=0):
    """Author : Srihari Janardhan
    Gets counter value from given dict. Index is calculated from latest sample to previous.
    I.e. index=0 returns the last value, index=1 returns the one before that."""
    samples = sorted(pi_dict.keys(), reverse=True)
    return int(pi_dict[samples[int(index)]][pi][dist_name])
