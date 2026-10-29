# -*- coding: utf-8 -*-
"""
:copyright: Nokia Networks
:author:  Mao Cathy
:contact: cathy.mao@nokia-sbell.com
"""

from robot.api import logger
import re
import shutil
# import commands
import sys
if sys.version_info.major == 3:         # python2 python3 distinction
    import subprocess as commands
else:
    import commands


class Stack(object):
    """Stack"""

    def __init__(self):
        self._list = []

    def push(self, item):
        """push a new item to top"""
        self._list.append(item)

    def pop(self):
        """pop the top item"""
        return self._list.pop()

    def peek(self):
        """return the top item"""
        if self._list:
            return self._list[-1]
        else:
            return None

    def is_empty(self):
        """judge if stack is empty"""
        return self._list == []

    def size(self):
        """return the stack item number"""
        return len(self._list)


def get_wanted_msg_from_egate_console(key_name, egate_log, output_file):
    """
        get_wanted_msg_from_egate_console log
        :Author: Mao Cathy
        :param string key_name: search msg name
        :param string egate_log: egate_log
        :param string output_file: output_file
        :return: bool True or False

        - Example::

              get_wanted_msg_from_egate_console    key_name="value RRCReconfiguration" \
                 egate_log=/tmp/egate_console.log    output_file="output.json"
    """
    catched = False
    exist_line_for_key = []
    wanted_data = []
    time_patt = re.compile(r'^\d{1,2}:\d{1,2}:\d{1,2}')
    start_read = False
    stop_read = False

    with open(egate_log, "r") as f:
        for num, value in enumerate(f):
            if key_name in value:
                catched = True
                exist_line_for_key.append(num)
    print("=====exist_line_for_key_name: {} ======"+str(key_name))
    print(exist_line_for_key)
    print("======================================")
    if catched:
        start_line = exist_line_for_key[-1]

        with open(egate_log, "r") as f:
            for num, value in enumerate(f):
                if num == start_line:
                    wanted_data.append(value)
                    start_read = True
                if start_read:
                    if re.match(time_patt, value) is None:
                        wanted_data.append(value)
                    else:
                        stop_read = True
                        break

    with open(output_file, "w") as f:
        for i in wanted_data[:]:
            f.write(i)

    if catched is False:
        logger.info("Cannot find the message in egate output file !! ")
        return False
    else:
        return True


def cut_specified_msg_in_egate(msg, input_file, output_file):
    """
        cut_specified_msg_in_egate
        :Author: Mao Cathy
        :param string msg: msg name
        :param string input_file: input_file
        :param string output_file: output_file
        :return: None

        - Example::

              cut_specified_msg_in_egate    msg="reportConfigToAddModList" \
                 input_file=/tmp/output.json    output_file="reportConfigToAddModList.json"
              cut_specified_msg_in_egate("measObjectToAddModList", \
              target_dir+"output.json",target_dir+"measObjectToAddModList.json")
    """
    catched = False
    wanted_data = []
    left_s = Stack()

    with open(input_file, "r") as f:
        for num, value in enumerate(f):
            if msg in value:
                catched = True
                start_line = num + 1
            if catched:
                wanted_data.append(value)
                if "{" in value:
                    left_s.push(num)
                elif "}" in value:
                    left_s.pop()
                    if left_s.is_empty():
                        break
                else:
                    pass

    with open(output_file, "w") as f:
        for i in wanted_data[:]:
            f.write(i)


def get_reportConfig(input_file):
    """
        get_reportConfig
        :Author: Mao Cathy
        :param string input_file: input_file
        :return: reportConfig_list

        - Example::

              reportConfig_list=get_reportConfig("/tmp/reportConfigToAddModList.json")
    """
    catched = False
    tmp_file = "tmp.json"
    reportConfig_list = []
    reportConfig = {'reportConfigId': '', 'eventId': '', 'Threshold': ''}
    with open(input_file, "r") as f1, open(tmp_file, "w") as f2:
        for num, line in enumerate(f1):
            line = line.replace(",", "")
            line = line.replace(":", "")
            f2.write(line)
    with open(tmp_file, "r") as f:
        for num, value in enumerate(f):
            if "reportConfigId" in value:
                catched = True
                reportConfig['reportConfigId'] = value.split()[1]
            if catched:
                if "eventId" in value:
                    reportConfig['eventId'] = value.split()[1]
                if "Threshold" in value:
                    reportConfig['Threshold'] = value.split(
                    )[0] + "_" + value.split()[1] + "_" + value.split()[2]
                    reportConfig_list.append(reportConfig.copy())

                if reportConfig['eventId'] == "eventA3":
                    if "Offset" in value:
                        reportConfig['Threshold'] = value.split()[
                            0] + "_" + value.split()[1] + "_" + value.split()[2]
                        reportConfig_list.append(reportConfig.copy())

    print("=== reportConfig in get_reportConfig ===")
    print(reportConfig)
    return reportConfig_list


def get_measId(input_file):
    """
        get_measId
        :Author: Mao Cathy
        :param string input_file: input_file
        :return: measId_list

        - Example::

              measId_list=get_measId(target_dir+"measIdToAddModList.json")
    """
    catched = False
    tmp_file = "tmp.json"
    measId_list = []
    measId = {'measId': '', 'measObjectId': '', 'reportConfigId': ''}
    with open(input_file, "r") as f1, open(tmp_file, "w") as f2:
        for num, line in enumerate(f1):
            line = line.replace(",", "")
            line = line.replace(":", "")
            f2.write(line)
    with open(tmp_file, "r") as f:
        for value in f.readlines()[1:]:
            if "measId" in value:
                catched = True
                measId['measId'] = value.split()[1]
            if catched:
                if "measObjectId" in value:
                    measId['measObjectId'] = value.split()[1]
                if "reportConfigId" in value:
                    measId['reportConfigId'] = value.split()[1]
                    measId_list.append(measId.copy())

    return measId_list


def get_measObject(input_file):
    """
        get_measId
        :Author: Mao Cathy
        :param string input_file: input_file
        :return: measObject_list

        - Example::

              measObject_list=get_measObject(target_dir+"measObjectToAddModList.json")
    """
    catched = False
    tmp_file = "tmp.json"
    measObject_list = []
    measObject = {'measObjectId': '', 'ssbFrequency': ''}
    with open(input_file, "r") as f1, open(tmp_file, "w") as f2:
        for num, line in enumerate(f1):
            line = line.replace(",", "")
            line = line.replace(":", "")
            f2.write(line)
    with open(tmp_file, "r") as f:
        for value in f.readlines()[1:]:
            if "measObjectId" in value:
                catched = True
                measObject['measObjectId'] = value.split()[1]
            if catched:
                if "ssbFrequency" in value:
                    measObject['ssbFrequency'] = value.split()[1]
                    measObject_list.append(measObject.copy())

    return measObject_list


def calculate_measId(event, Threshold, ssbFrequency=None):
    """
        calculate_measId

        :param string event: event
        :param string Threshold: Threshold
        :param string ssbFrequency: ssbFrequency
        :return: search_measId

        - Example::

              ${a2_meas_id}    calculate_measId    eventA2    a2-Threshold_rsrp_11
              ${a3_meas_id}    calculate_measId    eventA3    a3-Offset_rsrq_10
              ${a5_meas_id}    calculate_measId    eventA5    a5-Threshold1_rsrq_11
    """
    target_dir = "/tmp/"
    env_type = ""
    shutil.copyfile(
        "/opt/iphy/latest/egate_console.log",
        target_dir + "egate_console.log")

    file = open("/tmp/egate_console.log")
    for line in file:
        if "ue_dc_enb_start" in line:
            env_type = "NSA"
        else:
            continue
    if not env_type.strip():
        env_type = "SA"
    file.close()
    print("--------env_type-----------")
    print(env_type)
    print("---------------------------")

    if env_type == "NSA":
        get_wanted_msg_from_egate_console(
            "value RRCReconfiguration",
            target_dir + "egate_console.log",
            target_dir + "output.json")
    elif env_type == "SA":
        get_wanted_msg_from_egate_console(
            "measConfig",
            target_dir + "egate_console.log",
            target_dir + "output.json")
    else:
        print("!! Cannot know the env_type from egate_console.log")
    cut_specified_msg_in_egate(
        "measObjectToAddModList",
        target_dir + "output.json",
        target_dir + "measObjectToAddModList.json")
    cut_specified_msg_in_egate(
        "reportConfigToAddModList",
        target_dir + "output.json",
        target_dir + "reportConfigToAddModList.json")
    cut_specified_msg_in_egate(
        "measIdToAddModList",
        target_dir + "output.json",
        target_dir + "measIdToAddModList.json")
    reportConfig_list = get_reportConfig(
        target_dir + "reportConfigToAddModList.json")
    print("-------------------")
    (ret_code, output) = commands.getstatusoutput(
        "cat /tmp/reportConfigToAddModList.json")
    print(output)
    (ret_code, output) = commands.getstatusoutput(
        "cat /tmp/measIdToAddModList.json")
    print(output)
    (ret_code, output) = commands.getstatusoutput(
        "cat /tmp/measObjectToAddModList.json")
    print(output)
    measId_list = get_measId(target_dir + "measIdToAddModList.json")
    measObject_list = get_measObject(
        target_dir + "measObjectToAddModList.json")
    print("--- Debug Log: reportConfig_list ---")
    print(reportConfig_list)
    for report in reportConfig_list:
        if report['eventId'] == event and report['Threshold'] == Threshold:
            search_reportConfigId = report['reportConfigId']
            break

    if ssbFrequency is None:
        search_measObjectId = '1'
    else:
        for measObject in measObject_list:
            if measObject['ssbFrequency'] == ssbFrequency:
                search_measObjectId = measObject['measObjectId']
                break

    for measId in measId_list:
        if measId['measObjectId'] == search_measObjectId and measId['reportConfigId'] == search_reportConfigId:
            search_measId = measId['measId']
            break
    return search_measId


def get_all_msg_from_egate_log(msg_name, egate_log, output_file='temp.log'):
    '''

    :param msg_name:
    :param egate_log:
    :param output_file:
    :return:
    '''
    time_patt = re.compile(r'^\d{1,2}:\d{1,2}:\d{1,2}')
    _list = list()

    with open(egate_log, "r") as f:
        f_data = f.read()
        _temp_data = f_data.split('\n')
        for index, line in enumerate(f_data.split('\n')):
            if re.match(time_patt, line) is not None:
                _temp_data[index] = '+-' * 10

    _temp = '\n'.join(_temp_data)
    for i in _temp.split('+-' * 10):
        if 'value ' in i:
            _list.append(i)

    msg_list = list()
    for li in _list:
        if msg_name in li:
            msg_list.append(li)

    with open(output_file, 'w') as t:
        t.write('\n'.join(msg_list))
    print('--- Find [ %d ] %s' % (len(msg_list), msg_name))

    return msg_list


def check_specified_info_in_msg(msg_name, egate_log, msg_file, *msg_con):
    '''

    :param msg_name: message you want to check. such as, 'value RadioBearerConfig'
    :param egate_log:
    :param msg_file: the message matched would be wrote to this file.
    :param msg_con: the filter conditions. It's a variable argument. You can input multi strings as filter conditions.
                    Such as: "drb-Identity 4,"
    :return: if messages are found, return True.

    _Example_:
    check_specified_info_in_msg      value UL-DCCH-Message    egate_console.log
    ...    msg_file.log    ue-CapabilityRAT-Container '01000000010900000004D0100000000780

    '''
    msg_list = get_all_msg_from_egate_log(msg_name, egate_log)
    print('--- msg_con is:  %s ' % str(msg_con))
    if len(msg_list) != 0:
        check_msg = list()

        if len(msg_con) != 0:
            for li in msg_list:
                for m in msg_con:
                    result = True
                    if m not in li.replace(" ", ""):
                        result = result and False
                        break
                if result:
                    check_msg.append(li)
            if len(check_msg) == 0:
                print('*WARN* No specified info in the message!!!')
            else:
                print(
                    "--- Find [ %d ] messages with specified info." %
                    len(check_msg))
                # for i in check_msg:
                #     print i

                with open(msg_file, 'w') as f:
                    f.write('\n'.join(check_msg))

                return True

    else:
        print("*WARN* No [ %s ] message found!!!" % msg_name)


if __name__ == "__main__":
    # id1=calculate_measId("eventA2","a2-Threshold_rsrp_34")
    # id2=calculate_measId("eventA2","a2-Threshold_rsrp_75")
    pass
