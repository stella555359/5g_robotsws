def analysis_trs_event_log(file_path, ip1, ip2):
    import re
    with open(file_path) as f:
        line_list = f.readlines()
        line_list.reverse()
        trigger2_pattern = re.compile(r'(.*)\s{\s"Event(.*)tpi::trigger(.*)"sessionId" : "2"(.*)Up')
        trigger1_pattern = re.compile(r'(.*)\s{\s"Event(.*)tpi::trigger(.*)"sessionId" : "1"(.*)Up')
        bfd_up_pattern = re.compile(r'(.*)\s{\s"Event(.*)tpi::bfd(.*)Ingress(.*)Up')
        trigger1_add = re.compile(r'(.*)\s{\s"Event(.*)tpi::iprouting(.*)Add(.*)"triggerId" : "1"')
        trigger2_add = re.compile(r'(.*)\s{\s"Event(.*)tpi::iprouting(.*)Add(.*)"triggerId" : "2"')
        trigger2 = None
        trigger1 = None
        bfd_up_line = None
        index_tail = None
        index_top = None
        for line in line_list:
            if re.search(trigger2_pattern, line):
                trigger2 = line
                index_top = line_list.index(line)
                trigger2_time = re.search(trigger2_pattern, line).group(1)
            if re.search(trigger1_pattern, line):
                trigger1 = line
                index = line_list.index(line)
                trigger1_time = re.search(trigger1_pattern, line).group(1)
            if re.search(bfd_up_pattern, line):
                bfd_up_line = line
                index_tail = line_list.index(line)
                bfd_time = re.search(bfd_up_pattern, line).group(1)
            if bfd_up_line and trigger1 and trigger2:
                break
        if index_tail is None or index_top is None:
            raise Exception('trigger is not up')
        index_tail = index_tail + 1
        sub_list = line_list[:index_tail]
        for item in sub_list:
            if re.search(trigger1_add, item):
                trigger1 = item
                trigger1_time_1 = re.search(trigger1_add, item).group(1)
                if ip1 not in str(trigger1):
                    raise Exception('ip1 is not been add')
            if re.search(trigger2_add, item):
                trigger2 = item
                trigger2_time_2 = re.search(trigger2_add, item).group(1)
                if ip2 not in str(trigger2):
                    raise Exception('ip2 is not been add')
    return trigger2_time, trigger1_time, bfd_time


def analysis_trs_event_log_delete_bfd(file_path, ip1, ip2):
    import re
    with open(file_path) as f:
        line_list = f.readlines()
        line_list.reverse()
        trigger2_pattern = re.compile(r'(.*)\s{\s"Event(.*)tpi::trigger(.*)"sessionId" : "2"(.*)Down')
        trigger1_pattern = re.compile(r'(.*)\s{\s"Event(.*)tpi::trigger(.*)"sessionId" : "1"(.*)Down')
        bfd_up_pattern = re.compile(r'(.*)\s{\s"Event(.*)tpi::bfd(.*)Ingress(.*)Down')
        trigger2_delete = re.compile(r'(.*)\s{\s"Event(.*)tpi::iprouting(.*)Delete(.*)"triggerId" : "2"(.*)')
        trigger1_delete = re.compile(r'(.*)\s{\s"Event(.*)tpi::iprouting(.*)Delete(.*)"triggerId" : "1"(.*)')
        trigger2 = None
        trigger1 = None
        bfd_up_line = None
        index_tail = None
        index_top = None
        for line in line_list:
            if re.search(trigger2_pattern, line):
                trigger2 = line
                index_top = line_list.index(line)
            if re.search(trigger1_pattern, line):
                trigger1 = line
                index = line_list.index(line)
            if re.search(bfd_up_pattern, line):
                bfd_up_line = line
                index_tail = line_list.index(line)
            if bfd_up_line and trigger1 and trigger2:
                break
        if index_tail is None or index_top is None:
            raise Exception('trigger is not down')
        index_tail = index_tail + 1
        sub_list = line_list[:index_tail]
        for item in sub_list:
            if re.search(trigger1_delete, item):
                trigger1 = item
                if ip1 not in str(trigger1):
                    raise Exception('ip1 is not been add')
            if re.search(trigger2_delete, item):
                trigger2 = item
                if ip2 not in str(trigger2):
                    raise Exception('ip2 is not been add')


def check_trs_event_log_time(bfd_up_time, trigger1_time, trigger2_time, false2TrueDelay1, false2TrueDelay2, tolerance):
    import time
    # bfd time
    bfd_up_mili_second = int(str(bfd_up_time).split('.')[-1])
    bfd_up_real_time = str(bfd_up_time).split('.')[0]
    bfd_up_real_time_array = time.strptime(bfd_up_real_time, '%Y-%m-%d %H:%M:%S')
    bfd_up_real_time_stamp = int(time.mktime(bfd_up_real_time_array))
    # trigger1 time
    trigger1_mili_second = int(str(trigger1_time).split('.')[-1])
    trigger1_real_time = str(trigger1_time).split('.')[0]
    trigger1_real_time_array = time.strptime(trigger1_real_time, '%Y-%m-%d %H:%M:%S')
    trigger1_real_time_stamp = int(time.mktime(trigger1_real_time_array))
    # trigger2 time
    trigger2_mili_second = int(str(trigger2_time).split('.')[-1])
    trigger2_real_time = str(trigger2_time).split('.')[0]
    trigger2_real_time_array = time.strptime(trigger2_real_time, '%Y-%m-%d %H:%M:%S')
    trigger2_real_time_stamp = int(time.mktime(trigger2_real_time_array))
    # trigger1 - bfd time
    bfd_trigger1_real_time = trigger1_real_time_stamp - bfd_up_real_time_stamp
    bfd_trigger1_mili_second = float((trigger1_mili_second - bfd_up_mili_second))/1000
    bfd_trigger1_diff_time = bfd_trigger1_real_time + bfd_trigger1_mili_second
    # trigger2 - bfd time
    bfd_trigger2_real_time = trigger2_real_time_stamp - bfd_up_real_time_stamp
    bfd_trigger2_mili_second = float((trigger2_mili_second - bfd_up_mili_second))/1000
    bfd_trigger2_diff_time = bfd_trigger2_real_time + bfd_trigger2_mili_second
    if bfd_trigger1_diff_time > (float(false2TrueDelay1) + float(tolerance)) or \
            bfd_trigger1_diff_time < (float(false2TrueDelay1) - float(tolerance)):
        raise Exception('The difference between bfd and trigger1 delay time is out of range')
    if bfd_trigger2_diff_time > (float(false2TrueDelay2) + float(tolerance)) or \
            bfd_trigger2_diff_time < (float(false2TrueDelay2) - float(tolerance)):
        raise Exception('The difference between bfd and trigger2 delay time is out of range')
