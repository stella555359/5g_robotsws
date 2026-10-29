import re


def _handle_raw_data(raw_throughput_list):
    throughput_dict = {}
    thread_dict = {}

    for a_throughput_match in raw_throughput_list:
        if a_throughput_match[1] not in throughput_dict.keys():
            throughput_dict[a_throughput_match[1]] = a_throughput_match[2]
            thread_dict[a_throughput_match[1]] = [a_throughput_match[0]]

        elif (a_throughput_match[1] in throughput_dict.keys()) and \
                (a_throughput_match[0] not in thread_dict[a_throughput_match[1]]):
            throughput_dict[a_throughput_match[1]] += a_throughput_match[2]
            thread_dict[
                a_throughput_match[1]].append(
                a_throughput_match[0])

        elif (a_throughput_match[1] in throughput_dict.keys()) and \
                (a_throughput_match[0] in thread_dict[a_throughput_match[1]]):
            throughput_dict[a_throughput_match[1]] = a_throughput_match[2]
            thread_dict[a_throughput_match[1]] = [a_throughput_match[0]]
    return throughput_dict


def get_iperf_throughput(server_output, allvalue=False):
    """This keyword returns the average throughput.

    | Input Parameters | Man. | Description |
    :param server_output: Iperf Serve output file
    :param allvalue: if False return average value, if True return max/min/avg value
    :return: value

    ::Example
        ${result}   Iperf Get Throughput   C:\\iperf_out.log
        Run Keyword If     0==${result}   Fail  v alue is zero

    Note:
    First 10% and last 5% throughput lines (by timestamp) in input file will NOT be calculated into output.
    """
    with open(server_output, "r") as file_object:
        lines = file_object.read()

    max_throughput = 0
    min_throughput = 0
    average_throughput = 0
    result_throughput_list = []
    pattern = r'\[\s*(\d+)\]\s+([0-9.]+\s*-\s*[0-9.]+)\s+sec\s+[0-9.]+\s+\w+\s+([0-9.]+)\s+\w+/sec'

    p_single = re.compile(pattern, re.M)

    ret_single = p_single.findall(lines)
    raw_throughput_list = []
    print('*INFO* total throughput lines in file %s : %d' % (server_output, len(ret_single)))
    for match in ret_single:
        second_space = [float(item.strip())
                        for item in match[1].split('-')]
        if second_space[1] - second_space[0] != 1.0:
            continue
        else:
            raw_throughput_list.append((match[0],
                                        second_space[0],
                                        float(match[2])))
    del ret_single

    throughput_dict = _handle_raw_data(raw_throughput_list)
    tmp_keys = sorted(throughput_dict.keys())
    sum_value = len(tmp_keys)
    if len(tmp_keys) == 1:
        result_throughput_list.append(throughput_dict[tmp_keys[0]])
    else:
        for idx in range(sum_value):
            if idx + 1 < sum_value * 0.1 or idx + 1 > sum_value * 0.95:
                continue
            else:
                if throughput_dict[tmp_keys[idx]] == 0:
                    print(tmp_keys[idx], throughput_dict[tmp_keys[idx]])
                result_throughput_list.append(
                    throughput_dict[tmp_keys[idx]])

    if len(result_throughput_list) > 0:
        max_throughput = '%.2f' % max(result_throughput_list)
        min_throughput = '%.2f' % min(result_throughput_list)
        average_throughput = '%.2f' % float(sum(result_throughput_list) /
                                            len(result_throughput_list))

    print('*DEBUG*AVERAGE_THROUGHPUT = %s' % average_throughput)
    print('*DEBUG*MAXIMUM_THROUGHPUT = %s' % max_throughput)
    print('*DEBUG*MINIMUM_THROUGHPUT = %s' % min_throughput)
    return average_throughput if (not allvalue) else \
        [max_throughput, min_throughput, average_throughput]


def get_ping_summary_data(log_path):
    time_delay = []  # type: List[float]
    delay_max_min_avg = []
    with open(log_path, "r") as file_object:
        lines = file_object.readlines()
    print(lines)

    delay_pattern1 = re.compile(r'.*from\s+?[01-9]+.[01-9]+.[01-9]+.[01-9]+:.*?time<(\d[\.|\d]*)\s+?ms.*')
    delay_pattern2 = re.compile(r'.*?from\s+?[01-9]+.[01-9]+.[01-9]+.[01-9]+:.*?time=(\d[\.|\d]*)\s+?ms.*')
    summary_pattern = \
        re.compile(r'(\d+)\s+?packets\stransmitted,\s+?(\d+)\s+?received,.*?\s+?(\d[\.|\d]*)%\s+?packet\sloss')
    for line in lines:
        time = delay_pattern1.match(line)
        if time:
            tmp = time.groups()[0]
            time_delay.append(float(tmp))
            continue
        time = delay_pattern2.match(line)
        if time:
            tmp = time.groups()[0]
            time_delay.append(float(tmp))
            continue

        result = summary_pattern.match(line)
        if result:
            summary_result = result.groups()

    statistic_delay = time_delay

    if 2 < len(statistic_delay):
        list_max = max(statistic_delay[1:])
        list_min = min(statistic_delay[1:])
        list_avg = float(sum(statistic_delay[1:])) / float(len(statistic_delay) - 1)
        delay_max_min_avg.append(list_max)
        delay_max_min_avg.append(list_min)
        delay_max_min_avg.append(list_avg)
    else:
        delay_max_min_avg = [-1, -1, -1]

    return summary_result, delay_max_min_avg
