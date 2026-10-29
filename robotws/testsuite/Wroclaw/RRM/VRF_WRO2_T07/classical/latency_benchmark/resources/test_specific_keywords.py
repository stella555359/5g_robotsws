import testsuite.Wroclaw.RRM.VRF_WRO2_T07.resources.rue.attach_utils as ue_utils
from testsuite.Wroclaw.RRM.VRF_WRO2_T07.resources.attenuator import Attenuator
from testsuite.Wroclaw.RRM.VRF_WRO2_T07.resources.log_analyzer.matchers import PcapMessageMatcher as PM
from testsuite.Wroclaw.RRM.VRF_WRO2_T07.resources.log_analyzer.matchers import TTIMessageMatcher as TM
from testsuite.Wroclaw.RRM.VRF_WRO2_T07.resources.logs.tti import tti_streaming as tti_dump
from testsuite.Wroclaw.RRM.VRF_WRO2_T07.resources.log_analyzer.log_helper import LogHelper
from testsuite.Wroclaw.RRM.resources.log.log import blog
from time import sleep
from datetime import datetime
from robot.libraries.BuiltIn import BuiltIn
from testsuite.Wroclaw.RRM.VRF_WRO2_T07.resources.decorators import logged_keyword

UE_NUMBER = 1
UE_CAPABILITIES = 'BENCHMARK_UE'
TIME = 20
SPEED = '15Mbits/sec'
CELL_1 = [1, 3]
CELL_2 = [5, 7]
ATTENUATOR = Attenuator()

output_dir = BuiltIn().get_variable_value('${OUTPUT_DIR}')
time_path = output_dir + '/logs_times.txt'


@logged_keyword
def analyze_latency(sctp_logs, filters, msg_start, msg_stop, msg):
    with LogHelper() as lh:
        finder = lh.add_pcap(pcap_file_path=sctp_logs, tshark_filter=filters, lua=None)

        msg_start_matcher = PM(msg_start, message_type_pattern='empty')
        msg_stop_matcher = PM(msg_stop, message_type_pattern='empty')

        all_msg_start = finder.find_all(msg_start_matcher)
        all_msg_stop = finder.find_all(msg_stop_matcher)

        nums = len(all_msg_start)

    assert lists_are_non_empty(all_msg_start, all_msg_stop), \
        'Not all necessary messages for {} could be found in SCTP logs.'.format(msg)

    indexes = get_indexes_sorted_msgs(all_msg_start, all_msg_stop, nums)
    latency = 0.0
    for i in range(nums):
        latency += time_diff(all_msg_start[indexes[i][0]], all_msg_stop[indexes[i][1]])

    text = 'Average latency of {} tests is {} ms'.format(nums, round(latency / nums, 2))
    with open(time_path, 'a') as f:
        f.write(text + '\n\n')

    blog(text)


@logged_keyword
def analyze_tti(tti):
    with LogHelper() as lh:
        finder = lh.add_tti(log_files=tti)

        dl_msg_matcher = TM('dlTdSchedSubcellData').containing(key_pattern='rnti', regex_engine='re')
        ul_msg_matcher = TM('ulTdSchedSubcellData').containing(key_pattern='rnti', regex_engine='re')

        all_msg_dl = finder.find_all(dl_msg_matcher)
        all_msg_ul = finder.find_all(ul_msg_matcher)

    assert lists_are_non_empty(all_msg_dl, all_msg_ul), \
        'Not all necessary messages for Interruption Time could be found in TTI logs.'

    dl_interruptions_begin, dl_interruptions_end = get_interruptions_time(all_msg_dl, ['10', '40'], ['99'])
    ul_interruptions_begin, ul_interruptions_end = get_interruptions_time(all_msg_ul, ['30', '60'], ['90'])

    assert len(dl_interruptions_begin) == len(dl_interruptions_end), "Downlink handover count isn't the same"
    assert len(ul_interruptions_begin) == len(ul_interruptions_end), "Uplink handover count isn't the same"

    dl_average_time = calculate_average_interruption_time(dl_interruptions_begin, dl_interruptions_end)
    ul_average_time = calculate_average_interruption_time(ul_interruptions_begin, ul_interruptions_end)

    return dl_average_time, len(dl_interruptions_begin), ul_average_time, len(ul_interruptions_begin)


def msg_to_date(msg):
    arrival_time = msg.find('Arrival Time', engine='re').first()['val'][:-5].rstrip('0')
    date_format = '%b  %d, %Y %H:%M:%S.%f'
    return datetime.strptime(arrival_time, date_format)


def time_diff(msg_start, msg_stop):
    time_start = msg_to_date(msg_start)
    time_stop = msg_to_date(msg_stop)
    return (time_stop - time_start).total_seconds() * 1000


@logged_keyword
def get_indexes_sorted_msgs(msgs_start, msgs_stop, nums):
    msgs_start_with_date = [[i, msg_to_date(i), 'start'] for i in msgs_start]
    msgs_stop_with_date = [[i, msg_to_date(i), 'stop'] for i in msgs_stop]

    msgs = msgs_start_with_date + msgs_stop_with_date
    msgs.sort(key=lambda x: x[1])

    indexes = []
    z = 0
    for _ in range(nums):
        while msgs[z][2] != 'start':
            z += 1

        tmp = [msgs_start.index(msgs[z][0])]

        while msgs[z][2] != 'stop':
            z += 1

        tmp.append(msgs_stop.index(msgs[z][0]))
        indexes.append(tmp)

    return indexes


def lists_are_non_empty(*lists):
    return all(lst for lst in lists)


def require_UE(ue_number, capabilities=UE_CAPABILITIES):
    ue_utils.require_ues(ue_number, capabilities=capabilities)


def attach_UE(ue_number):
    ue_utils.attach_ues(ue_number)


def detach_UE(ue_number):
    ue_utils.detach_ues(ue_number)


def get_value_from_msg(msg, id):
    return msg.find(id, engine='re').first()['val']


def check_resReqClassPrio(msg, resReqClassPrio):
    try:
        return get_value_from_msg(msg, "resReqClassPrio") in resReqClassPrio
    except BaseException:
        return None


def get_time(msg):
    sfn = get_value_from_msg(msg, "sfn")
    slot = get_value_from_msg(msg, "slot")
    return int(sfn + slot)


@logged_keyword
def get_rnti_ho_msgs(msgs, ho_index, resReqClassPrios):
    loop_range = min(ho_index + 1, len(msgs))
    last_msg, first_msg = None, None
    for index in range(1, loop_range):
        if not last_msg and check_resReqClassPrio(msgs[ho_index - index], resReqClassPrios):
            last_msg = msgs[ho_index - index]
        elif not first_msg and check_resReqClassPrio(msgs[ho_index + index], resReqClassPrios):
            first_msg = msgs[ho_index + index]
    return last_msg, first_msg


@logged_keyword
def get_rntis(msgs, resReqClassPrios, hoResReqClassPrios):
    rnti_begin = dict()
    rnti_end = dict()
    for index, msg in enumerate(msgs):
        if check_resReqClassPrio(msg, hoResReqClassPrios):
            last_msg, first_msg = get_rnti_ho_msgs(msgs, index, resReqClassPrios)
            if last_msg and first_msg:
                rnti_last_value = get_value_from_msg(last_msg, 'rnti2')
                rnti_first_value = get_value_from_msg(first_msg, 'rnti2')
                rnti_begin[rnti_last_value] = {"lcrId": get_value_from_msg(last_msg, "lcrId"),
                                               "time": get_time(last_msg)}
                rnti_end[rnti_first_value] = {"lcrId": get_value_from_msg(first_msg, "lcrId"),
                                              "time": get_time(first_msg)}
    return rnti_begin, rnti_end


def filter_handovers(rntis):
    return {key: value for index, (key, value) in enumerate(list(rntis.items()))
            if value["lcrId"] != rntis[list(rntis.keys())[index + (1 if index != len(rntis) - 1 else - 1)]]["lcrId"]}


def remove_doubled_rntis(filtered_begin, filtered_end):
    loop_range = min(len(filtered_begin), len(filtered_end))
    for i in range(loop_range):
        if list(filtered_begin.keys())[i] == list(filtered_end.keys())[i]:
            filtered_end.pop(list(filtered_end.keys())[i])


@logged_keyword
def remove_unwanted_keys(rnti_begin, rnti_end):
    filtered_begin = filter_handovers(rnti_begin)
    filtered_end = filter_handovers(rnti_end)
    remove_doubled_rntis(filtered_begin, filtered_end)
    return filtered_begin, filtered_end


@logged_keyword
def get_interruptions_time(msgs, resReqClassPrio, hoResReqClassPrio):
    rnti_begin, rnti_end = get_rntis(msgs, resReqClassPrio, hoResReqClassPrio)
    rnti_before, rnti_after = remove_unwanted_keys(rnti_begin, rnti_end)
    return rnti_before, rnti_after


def calculate_average_interruption_time(interruptions_begin, interruptions_end):
    times = [(value["time"] - list(interruptions_begin.values())[index]["time"] + 1024) % 1024
             for index, value in enumerate(list(interruptions_end.values()))]
    return sum(times) / len(times)


@logged_keyword
def make_handover(nums):
    ATTENUATOR.set_attenuation(value_string=0, ports=CELL_1)
    ATTENUATOR.set_attenuation(value_string=90, ports=CELL_2)
    attach_UE(UE_NUMBER)
    sleep(TIME)

    ue_utils.start_dl_data_transfer_on_ues(UE_NUMBER, throughput=SPEED, duration='5000s')
    ue_utils.start_ul_data_transfer_on_ues(UE_NUMBER, throughput=SPEED, duration='5000s')

    for i in range(nums):
        ATTENUATOR.set_attenuation(value_string=0, ports=CELL_1)
        ATTENUATOR.set_attenuation(value_string=90, ports=CELL_2)
        for x in range(0, 26, 2):
            ATTENUATOR.set_attenuation(value_string=10 + x, ports=CELL_1)
            ATTENUATOR.set_attenuation(value_string=36 - x, ports=CELL_2)
        for n in range(0, 26, 2):
            ATTENUATOR.set_attenuation(value_string=10 + n, ports=CELL_2)
            ATTENUATOR.set_attenuation(value_string=36 - n, ports=CELL_1)
            sleep(TIME)
        blog("loop no:", i)

    ue_utils.stop_dl_data_transfer_on_ues(UE_NUMBER)
    ue_utils.stop_ul_data_transfer_on_ues(UE_NUMBER)

    ATTENUATOR.nullify_attenuation_on_all_ports()
    ATTENUATOR.release_attenuator()

    detach_UE(UE_NUMBER)


@logged_keyword
def make_setup(num):
    require_UE(UE_NUMBER)
    sleep(TIME)

    for _ in range(num):
        attach_UE(UE_NUMBER)
        sleep(TIME)
        detach_UE(UE_NUMBER)
        sleep(TIME)


@logged_keyword
def make_interuption_time(nums):
    require_UE(UE_NUMBER)

    tti_dump.start_tti_traces_in_streaming_mode(collector_type="sbts")
    make_handover(nums)
    tti = tti_dump.stop_tti_traces_in_streaming_mode()
    return tti


@logged_keyword
def process_tti(tti):
    average_dl, dl_ho_count, average_ul, ul_ho_count = analyze_tti(tti)

    text1 = 'Average interruption time for downlink is {} ms'.format(round(average_dl, 2))
    text2 = 'Average interruption time for uplink is {} ms'.format(round(average_ul, 2))

    with open(time_path, 'a') as f:
        f.write('Found {} handovers during downlink tput\n'.format(dl_ho_count))
        f.write('Found {} handovers during uplink tput\n'.format(ul_ho_count))
        f.write('Average interruption time for downlink is {} ms\n'.format(round(average_dl, 2)))
        f.write('Average interruption time for uplink is {} ms\n'.format(round(average_ul, 2)))

    blog(text1)
    blog(text2)


def make_handover_latency(nums):
    require_UE(UE_NUMBER)
    make_handover(nums)
