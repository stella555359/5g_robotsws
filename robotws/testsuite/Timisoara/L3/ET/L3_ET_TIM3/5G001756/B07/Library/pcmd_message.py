import re
import json
from robot.api import logger


def check_empty_pcmd_msg(source_file):
    empty_count = 0
    with open(source_file, "r") as fp:
        msg_str = fp.read()

    all_format_msgs = {}
    msgs = re.findall(
        r"[\w]uVendorExtensionRecordDataType : (.+?)Message:", msg_str, re.S)

    for msg in msgs:
        msg = msg.strip()
        if msg == "":
            empty_count += 1
    return empty_count


def get_pcmd_msgs_by_record_name(source_file, record_name):
    with open(source_file, "r") as fp:
        msg_str = fp.read()

    msgs = re.findall(r"[\w]uVendorExtensionRecordDataType : " +
                      record_name + " : data : (.+?)Message:", msg_str, re.S)
    format_msgs = []
    for msg in msgs:
        format_msgs.append(_format_pcmd_message(msg))
    return format_msgs


def get_pcmd_msgs_by_record_list(source_file, record_list):
    # record_list = ["ueCtxReleaseRecord"]
    with open(source_file, "r") as fp:
        msg_str = fp.read()

    all_format_msgs = {}
    for record_name in record_list:
        msgs = re.findall(r"[\w]uVendorExtensionRecordDataType : " +
                          record_name + " : data : (.+?)Message:", msg_str, re.S)
        format_msgs = []
        for msg in msgs:
            format_msgs.append(_format_pcmd_message(msg))
        all_format_msgs[record_name] = format_msgs
    return all_format_msgs


# def get_all_pcmd_msgs(source_file):
#     with open(source_file, "r") as fp:
#         msg_str = fp.read()

#     all_format_msgs = {}
#     msgs = [r.group(0) for r in re.finditer(
#         r"[\w]uVendorExtensionRecordDataType : (.+?)Message:", msg_str, re.S)]
#     for msg in msgs:
#         keys = [r.group(1) for r in re.finditer(
#             r"[\w]uVendorExtensionRecordDataType : (.+?) : data : (.+?)Message:", msg, re.S)]
#         values = [r.group(2) for r in re.finditer(
#             r"[\w]uVendorExtensionRecordDataType : (.+?) : data : (.+?)Message:", msg, re.S)]
#         if len(keys) == 0 or len(values) == 0:
#             continue
#         key = keys[0]
#         value = values[0]
#         if key not in all_format_msgs:
#             all_format_msgs[key] = []
#         all_format_msgs[key].append(_format_pcmd_message(value))
#     return all_format_msgs


def get_all_pcmd_msgs(source_file):
    with open(source_file, "r") as fp:
        msg_str = fp.read()

    all_format_msgs = {}
    msg_list = msg_str.split('Message:')

    for value in msg_list:
        value += "Message:"
        msgs = [r.group(0) for r in re.finditer(
            r"[\w]uVendorExtensionRecordDataType : (.+?)Message:", value, re.S)]
        if msgs:
            crnti_list = re.findall(r"crnti (.*)", value)
            if crnti_list:
                crnti = crnti_list[0]
                if crnti not in all_format_msgs:
                    all_format_msgs[crnti] = {}
                keys = [r.group(1) for r in re.finditer(
                    r"[\w]uVendorExtensionRecordDataType : (.+?) : (data|data-r1) : (.+?)Message:", value, re.S)]
                values = [r.group(3) for r in re.finditer(
                    r"[\w]uVendorExtensionRecordDataType : (.+?) : (data|data-r1) : (.+?)Message:", value, re.S)]
                if len(keys) == 0 or len(values) == 0:
                    continue
                key = keys[0]
                value = values[0]
                if key not in all_format_msgs[crnti]:
                    all_format_msgs[crnti][key] = []
                all_format_msgs[crnti][key].append(_format_pcmd_message(value))
    return all_format_msgs


def get_all_pcmd_timestamp(source_file):
    with open(source_file, "r") as fp:
        msg_str = fp.read()
    msg_list = msg_str.split('Message:')
    all_format_timestamp = {}
    for value in msg_list:
        msgs = [r.group(1) for r in re.finditer(
            r"[\w]uVendorExtensionRecordDataType : (.+?) : data", value, re.S)]
        if msgs:
            crnti_list = re.findall(r"crnti (.*)", value)
            if crnti_list:
                crnti = crnti_list[0]
                if crnti not in all_format_timestamp:
                    all_format_timestamp[crnti] = {}
                record_name = msgs[0]
                if record_name not in all_format_timestamp[crnti]:
                    all_format_timestamp[crnti][record_name] = []
                timestamp = re.findall(r"timestamp {(.+?)}", value, re.S)
                timestamp = timestamp[0]
                time_list = timestamp.strip().split(',')
                time_list = [i.strip().split(' ')[-1] for i in time_list]
                msgs_timestamp = {'seconds': int(time_list[0]), 'useconds': int(time_list[1])}
                all_format_timestamp[crnti][record_name].append(msgs_timestamp)
    return all_format_timestamp


def _format_pcmd_message(msg):
    check_msg = msg.strip()
    lines = check_msg.splitlines()
    line_str = ""
    for line in lines:
        line = line.strip().replace(" : ", ":")
        line_str += line

    if line_str.count('ngranBearer') >= 2:
        ngranBearer_quota_position_start = []
        ngranBearer_quota_position_end = []
        strlocation = line_str.rindex('ngranBearer')
        # print(strlocation)
        for i in range(strlocation, len(line_str)):
            if line_str[i] == "{":
                start = i + 1
                ngranBearer_quota_position_start.append(start)
                # ngranBearer_quota_position.append(end)
        # print(ngranBearer_quota_position_start)
        for j in range(strlocation, len(line_str)):
            if line_str[j] == "}":
                end = j
                ngranBearer_quota_position_end.append(end)
        # print(ngranBearer_quota_position_end)
        # print(line_str)
        # print(line_str[ngranBearer_quota_position_end[len(ngranBearer_quota_position_start)]+1:])
        # print(line_str[0: strlocation-2])
        line_str = (line_str[0: strlocation-1] +
                    line_str[ngranBearer_quota_position_end[len(ngranBearer_quota_position_start)]:])
        # print(line_str)

    if line_str.count('drb-Id') >= 2 and line_str.count('setupBearers') >= 1:
        ngranBearer_quota_position_start = []
        ngranBearer_quota_position_end = []
        strlocation = line_str.rindex('drb-Id')
        # print(strlocation)
        for i in range(strlocation, len(line_str)):
            if line_str[i] == "{":
                start = i + 1
                ngranBearer_quota_position_start.append(start)
                # ngranBearer_quota_position.append(end)
        # print(ngranBearer_quota_position_start)
        for j in range(strlocation, len(line_str)):
            if line_str[j] == "}":
                end = j
                ngranBearer_quota_position_end.append(end)
        # print(ngranBearer_quota_position_end)
        # print(line_str)
        # print(line_str[ngranBearer_quota_position_end[len(ngranBearer_quota_position_start)]+1:])
        # print(line_str[0: strlocation-2])
        line_str = (line_str[0: strlocation-1] +
                    line_str[ngranBearer_quota_position_end[len(ngranBearer_quota_position_start)]:])
        print(line_str)

    digital_decode = [r.group(0)
                      for r in re.finditer("'(.+?)('H|'B)", line_str)]
    for value in digital_decode:
        new_value = value.replace(" ", "").replace(
            "'", "").replace("H", "").replace("B", "")
        line_str = line_str.replace(value, new_value)

    # brace
    if ":" in line_str:
        ss = line_str.split(":")
        for i in range(1, len(ss)):
            brace = 0
            for j in range(len(ss[i])):
                if ss[i][j] == "{":
                    brace += 1
                elif ss[i][j] == "}":
                    brace -= 1
                    if brace <= 0:
                        ss[i] = ss[i][:j] + "}" + ss[i][j:]
                        break
        for m in range(0, len(ss)-1):
            index = [r.start() for r in re.finditer(' ', ss[m])][-1]
            ss[m] = ss[m][:index+1] + "{" + ss[m][index+1:]
        line_str = ":".join(ss).replace(" ", ":")
    else:
        line_str = line_str.replace(" ", ":")

    # Array parentheses
    start_brace = []
    stop_brace = []
    check_brace = []
    for i in range(len(line_str)):
        if line_str[i] == "{":
            check_brace.append(i)
        elif line_str[i] == "}":
            start_brace.append(check_brace.pop())
            stop_brace.append(i)
            if len(check_brace) == 0:
                break

    for j in range(len(start_brace)):
        if line_str[start_brace[j]:stop_brace[j]+1].find(":") == -1:
            line_str = line_str[:start_brace[j]] + "[" + line_str[start_brace[j] +
                                                                  1:stop_brace[j]] + "]" + line_str[stop_brace[j]+1:]
            continue
        else:
            indexes = [r.start() + start_brace[j]
                       for r in re.finditer(':', line_str[start_brace[j]:stop_brace[j]+1])]

        flag = False
        for index in indexes:
            in_other = False
            for k in range(0, j):
                if index >= start_brace[k] and index <= stop_brace[k]:
                    in_other = True
                    break
            flag = flag or not in_other

        if not flag:
            line_str = line_str[:start_brace[j]] + "[" + line_str[start_brace[j] +
                                                                  1:stop_brace[j]] + "]" + line_str[stop_brace[j]+1:]
            continue

    # key single quotation marks
    key_quota_position = []
    new_line_str = ""
    for i in range(len(line_str)):
        if line_str[i] == ":":
            end = i
            start = end
            for j in range(i-1, -1, -1):
                if line_str[j] == "{" or line_str[j] == ",":
                    start = j+1
                    break
            key_quota_position.append(start)
            key_quota_position.append(end)
    for j in range(len(line_str)):
        if len(key_quota_position) == 0:
            new_line_str += line_str[j]
        else:
            if j != key_quota_position[0]:
                new_line_str += line_str[j]
            else:
                new_line_str += "'"+line_str[j]
                key_quota_position = key_quota_position[1:]
    line_str = new_line_str

    # value single quotation marks
    value_quota_position = []
    new_line_str = ""
    for i in range(len(line_str)):
        if line_str[i] == ":" and line_str[i+1] != "[" and line_str[i+1] != "{":
            start = i+1
            end = start
            for j in range(i+2, len(line_str)):
                if line_str[j] == "}" or line_str[j] == ",":
                    end = j
                    break
            value_quota_position.append(start)
            value_quota_position.append(end)
    for j in range(len(line_str)):
        if len(value_quota_position) == 0:
            new_line_str += line_str[j]
        else:
            if j != value_quota_position[0]:
                new_line_str += line_str[j]
            else:
                new_line_str += "'"+line_str[j]
                value_quota_position = value_quota_position[1:]
    line_str = new_line_str

    try:
        line_obj = eval(line_str)
    except Exception:
        line_str = line_str + "}"
        line_obj = eval(line_str)
        return line_obj
    else:
        return line_obj


if __name__ == "__main__":
    print("DEBUG")
