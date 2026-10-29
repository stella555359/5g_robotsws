def analysis_trs_log_delay_time(file_path):
    import re

    with open(file_path) as f:
        line_list = f.readlines()
        line_list.reverse()
        trigger2_pattern = re.compile(
            r'(.*)\s{\s"Event"(.*)bfd(.*)Ingress(.*)"sessionId"\s:\s"1"(.*)Down'
        )
        trigger1_pattern = re.compile(
            r'(.*)\s{\s"Event"(.*)setForwardingEntriesChangeHandler(.*)Delete(.*)'
            r'forwardingentry(.*)20.0.0.0(.*)"triggerId" : "3"'
        )
        trigger2 = None
        trigger1 = None
        index_tail = None
        index_top = None
        t2_time = None
        t1_time = None
        for line in line_list:
            if re.search(trigger2_pattern, line):
                trigger2 = line
                index_top = line_list.index(line)
                t2_time = re.search(trigger2_pattern, line).group(1)
            if re.search(trigger1_pattern, line):
                trigger1 = line
                index_tail = line_list.index(line)
                t1_time = re.search(trigger1_pattern, line).group(1)
            if trigger1 and trigger2:
                break
    return t2_time, t1_time


def check_trs_log_time_delay_time(time_1, time_2):
    import time

    trigger1_mili_second = int(str(time_1).split(".")[-1])
    trigger1_real_time = str(time_1).split(".")[0]
    trigger1_real_time_array = time.strptime(trigger1_real_time, "%Y-%m-%d %H:%M:%S")
    trigger1_real_time_stamp = int(time.mktime(trigger1_real_time_array))

    trigger2_mili_second = int(str(time_2).split(".")[-1])
    trigger2_real_time = str(time_2).split(".")[0]
    trigger2_real_time_array = time.strptime(trigger2_real_time, "%Y-%m-%d %H:%M:%S")
    trigger2_real_time_stamp = int(time.mktime(trigger2_real_time_array))

    bfd_trigger_real_time = trigger1_real_time_stamp - trigger2_real_time_stamp
    bfd_trigger_mili_second = (
        float((trigger1_mili_second - trigger2_mili_second)) / 1000
    )
    bfd_trigger_diff_time = bfd_trigger_real_time + bfd_trigger_mili_second
    if bfd_trigger_diff_time > 2:
        raise Exception("The re-routing delay time is out of range")
