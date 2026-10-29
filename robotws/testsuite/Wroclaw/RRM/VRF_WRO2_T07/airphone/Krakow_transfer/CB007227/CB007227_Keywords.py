
def calculate_counter_for_expected_value(counter,
                                         value: int) -> int:
    '''
    Function grabs the provided PM Counter value from the list
    multiples it by value and returns as an integer.
    '''
    if isinstance(counter, list):
        counter_value = counter[0] * int(value)
    else:
        counter_value = counter * value
    return counter_value


def compare_values_with_margin(value: int,
                               expected_value: int,
                               margin: int) -> None:
    '''
    Function calculates the margin percentage,
    difference between provided value and whether
    compared values differ more than the margin.
    '''
    margin = int(margin) / 100.0
    diff = abs(expected_value - value)
    if diff > expected_value * margin:
        raise Exception(
            f"Compared values differ more than the margin of {margin}")


def time_of_data_burst_should_be_equal_to_counter_value(
                                pcmd_val: int,
                                pm_counter_val: int) -> None:
    '''
    Function verifies whether the sum of PCMD reports
    equals value collected from PM counters
    '''
    if pcmd_val != pm_counter_val:
        raise Exception("Captured PCMD and PM Counter values are not equal.")


def verify_throughput_from_records(tput_bytes: list,
                                   time: list,
                                   margin: int) -> None:
    '''
    Function takes two lists for Burst and Time values
    from PCMD collected reports.
    Check whether the lists are of the same length, trims empty reports
    and performs calculation, comparing results with provided margin.
    '''
    if '0' in tput_bytes or '0' in time:
        tput_bytes = _trim_list(tput_bytes)
        time = _trim_list(time)

    if len(tput_bytes) != len(time):
        raise Exception("PCMD and PM counters' lists are of different length.")

    for i in range(len(tput_bytes)):
        tput_value = 8000 * int(tput_bytes[i])/int(time[i])
        compare_values_with_margin(value=tput_value,
                                   expected_value=10000000,
                                   margin=margin)


def get_sum_of_field_values_from_all_pcmd_reports_for_ue_download(
        report_field_name,
        pcmd_reports,
        ran_ue_id):

    filtered_json = _filter_json_by_ran_id(lst=pcmd_reports,
                                           key=report_field_name,
                                           ran_id=ran_ue_id)
    filtered_json = _filter_json(filtered_json, report_field_name)
    res = 0
    for i in filtered_json:
        res += int(i)

    return res


def get_all_field_values_from_all_pcmd_reports_for_ue_download(
        report_field_name,
        pcmd_reports,
        ran_ue_id):

    filtered_json = _filter_json_by_ran_id(lst=pcmd_reports,
                                           key=report_field_name,
                                           ran_id=ran_ue_id)
    filtered_json = _filter_json(filtered_json, report_field_name)

    return filtered_json


def _filter_json(lst: list[dict], key: str) -> list[dict]:
    results = []
    for d in lst:
        for j in d:
            if j.endswith(key):
                results.append(d[j])
        for inner_d in d.values():
            if isinstance(inner_d, dict):
                value = _filter_json([inner_d], key)
                results.extend(value)
    return results


def _filter_json_by_ran_id(lst: list[dict],
                           key: str,
                           ran_id: str = None) -> list[dict]:
    results = []
    for d in lst:
        for j in d:
            if j.endswith('ranUeId'):
                if d[j] == ran_id:
                    results.append(d)
        for inner_d in d.values():
            if isinstance(inner_d, dict):
                value = _filter_json_by_ran_id([inner_d], 'ranUeId', ran_id=ran_id)
                results.extend(value)

    return results


def _filter_json_by_ran_id2(lst: list[dict],
                            key: str) -> list[dict]:
    results = []
    for d in lst:
        for j in d:
            if j.endswith(key):
                results.append(d[j])
        for inner_d in d.values():
            if isinstance(inner_d, dict):
                value = _filter_json_by_ran_id2([inner_d], key)
                results.extend(value)
    return results


def _trim_list(lst: list) -> list:
    return [i for i in lst if i != '0']
