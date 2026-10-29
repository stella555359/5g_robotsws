import logging

logging.basicConfig(level=logging.DEBUG)


def counter_verdict_generator_dl(actual_pm_values, ues_in_pm_interval):
    result_for_counter = {}
    result_for_counter['M55308C02001'] = validate_M55308C02001(actual_pm_values, ues_in_pm_interval)
    result_for_counter['M55308C02000'] = validate_M55308C02000(actual_pm_values)
    log_counter_verdict(result_for_counter)
    verdict = all(result_for_counter.values())
    return str(verdict)


def counter_verdict_generator_ul(actual_pm_values, ues_in_pm_interval):
    result_for_counter = {}
    result_for_counter['M55308C02003'] = validate_M55308C02003(actual_pm_values, ues_in_pm_interval)
    result_for_counter['M55308C02002'] = validate_M55308C02002(actual_pm_values)
    log_counter_verdict(result_for_counter)
    verdict = all(result_for_counter.values())
    return str(verdict)


def log_counter_verdict(result_for_counter):
    for counter in result_for_counter:
        if result_for_counter[counter]:
            logging.info("Test passed for counter %s" % counter)
        else:
            logging.error("Test failed for counter %s" % counter)


def validate_M55308C02003(actual_pm_values, ues_in_pm_interval):
    result = validate_max_ues_drb_buffered_data(actual_pm_values, ues_in_pm_interval, 'M55308C02003')
    return result


def validate_M55308C02001(actual_pm_values, ues_in_pm_interval):
    result = validate_max_ues_drb_buffered_data(actual_pm_values, ues_in_pm_interval, 'M55308C02001')
    return result


def validate_M55308C02002(actual_pm_values):
    """UL DRB evaluation"""
    result_comparison = generate_verdict_M55308C0200x(actual_pm_values, 'M55308C02002', 'M55308C01001')
    result_curve = verify_peak_at_center(actual_pm_values, 'M55308C02002')
    if not result_curve:
        logging.debug("The expected curve did not match, the PM Counters are expected to mimic "
                      "a hump shaped curve")
    return result_curve and result_comparison


def validate_M55308C02000(actual_pm_values):
    result_comparison = generate_verdict_M55308C0200x(actual_pm_values, 'M55308C02000', 'M55308C01000')
    result_curve = verify_peak_at_center(actual_pm_values, 'M55308C02000')
    if not result_curve:
        logging.debug("The expected curve did not match, the PM Counters are expected to mimic "
                      "a hump shaped curve")
    return result_curve and result_comparison


def verify_peak_at_center(actual_pm_values, pm_counter):
    if int(actual_pm_values[str(0)][pm_counter]) == int(actual_pm_values[str(5)][pm_counter]) == 0:
        if int(actual_pm_values[str(1)][pm_counter]) < int(actual_pm_values[str(2)][pm_counter]) \
                < int(actual_pm_values[str(4)][pm_counter]) < int(actual_pm_values[str(3)][pm_counter]):
            return True
        else:
            difference = abs(int(actual_pm_values[str(4)][pm_counter]) - int(actual_pm_values[str(3)][pm_counter]))
            difference_in_percentage = int(round(float(difference)/float(actual_pm_values[str(3)][pm_counter])))
            if difference_in_percentage <= 2:
                return True
            return False
    else:
        return False


# ----------------------------------------------------------------------------------------------------[120 characters]
def generate_verdict_M55308C0200x(actual_pm_values, piid_under_test, piid_sample):
    result = []
    logging.info("Testing PM Counter: " + piid_under_test)
    ul_sample_count = actual_pm_values[str(0)][piid_sample]
    # Note: M55308C02003 show BIGGER number of UEs, because UEs were detached AFTER measurement period started!
    exp_ues_in_each_interval = {'0': 0,  # PM Interval with No UEs and No traffic
                                '1': 0,  # PM Interval has all UEs detached
                                '2': 2,  # PM Interval has Detach 2 UEs detached
                                '3': 4,  # PM Interval has UL and DL traffic with full buffer
                                '4': 4,  # Attach 4 UEs and Start traffic with full buffer
                                '5': 0}  # Initial EMPTY Interval
    cal_ues_in_each_interval = {}
    for interval in sorted(exp_ues_in_each_interval):
        cal_ues_in_each_interval[interval] = (float(actual_pm_values[interval][piid_under_test]) /
                                              float(ul_sample_count))
        verdict = int(round(cal_ues_in_each_interval[interval])) == exp_ues_in_each_interval[interval]
        logString = ("Interval: %s | Calculated number of UEs: %s / %s = %s -> %s | Expected number of UEs: %s" %
                     (interval,
                      actual_pm_values[interval][piid_under_test],
                      ul_sample_count,
                      cal_ues_in_each_interval[interval],
                      int(round(cal_ues_in_each_interval[interval])),
                      exp_ues_in_each_interval[interval]))
        if verdict:
            logging.info(logString)
        else:
            logging.error(logString)
        result.append(verdict)
    return all(result)


def validate_max_ues_drb_buffered_data(actual_pm_values, ues_in_pm_interval, pm_counter):
    result = []
    logging.info("Testing PM Counter: %s", pm_counter)
    for interval in range(len(actual_pm_values) - 1, -1, -1):
        logging.info("Interval: %s | Actual counter value: %s | Expected counter value: %s"
                     % (interval, actual_pm_values[str(interval)][pm_counter], ues_in_pm_interval[str(interval)]))
        result.append(int(actual_pm_values[str(interval)][pm_counter]) == int(ues_in_pm_interval[str(interval)]))
    return all(result)
