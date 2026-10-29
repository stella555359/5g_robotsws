import datetime as dt
import json
from robot.api.logger import info, debug
import re


class SyslogFilter:
    def __init__(self):
        pass

    TYPE_OF_LOGS = {"[MessagesSender]": {"start_message": "Sending"},
                    "[MessagesReceiver]": {"start_message": "Received"}}

    @staticmethod
    def __get_message_name(message):
        # Ex:          "Sending cprt:aaa:bbbb, {..."
        # Ex_2:        "Sending cprt:aaa:bbbb:{..."
        # Will return: "cprt:aaa:bbbb"
        name = message.split("{", 1)[0].split(" ", 2)[1].strip()
        if not name[-1].isalpha():
            return name[:-1]

        return name

    @staticmethod
    def __flatten_dict(recursive_dict):
        items = []
        for dict_index, dict_value in recursive_dict.items():
            if isinstance(dict_value, dict):
                items.extend(SyslogFilter.__flatten_dict(dict_value).items())
            elif isinstance(dict_value, list):
                # It only gets first dict in list, the others will be skipped
                if dict_value and isinstance(dict_value[0], dict):
                    items.extend(SyslogFilter.__flatten_dict(dict_value[0]).items())
            else:
                items.append((dict_index, dict_value))
        return dict(items)

    @staticmethod
    def __get_message_parameters(message):
        # Ex:          "Sending cprt:aaa:bbbb, {..."
        # Ex_2:        "Sending cprt:aaa:bbbb:{..."
        # Will return: "{..."
        string_parameters = "{" + message.split("{", 1)[-1]
        # Change "bbb::aaa: type_of_a = ..."
        # To     "bbb::aaa: ..."
        string_parameters = re.sub(r'(?<!:):.*?=', ":", string_parameters)
        # Change "aaa: -234..."
        # To     "\"aaa\": \"-234...\""
        string_parameters = re.sub(r'[\w\d-]+', r'"\g<0>"', string_parameters)
        # Change "{...} some_dummy_text_after_brace_brackets"
        # To     "{...}"
        string_parameters = re.sub(r'({.*}).*', r'\g<1>', string_parameters)
        try:
            parameters = json.loads(string_parameters)
            flatten_parameters = SyslogFilter.__flatten_dict(parameters)
            return flatten_parameters
        except Exception:
            info("Message:\n{}\nis not json type!\nMessage params after changes:\n{}".format(message,
                                                                                             string_parameters))
            return {}

    @staticmethod
    def __get_parameters_from_message(message):
        formatted_log = {"name": SyslogFilter.__get_message_name(message),
                         "parameters": SyslogFilter.__get_message_parameters(message)}

        return formatted_log

    @staticmethod
    def get_all_expected_messages(path_to_syslog_file):
        dict_of_logs = {}

        with open(path_to_syslog_file, "r") as syslog_file:
            logs_divided_into_types = {}

            for type_of_log in SyslogFilter.TYPE_OF_LOGS:
                logs_divided_into_types.update({type_of_log: []})

            for line in syslog_file:
                # Date format: <%Y-%m-%dT%H:%M:%S.%fZ> ex. <2021-04-24T14:40:32.763556Z>
                if not re.match(r'^<\d+?-\d+?-\d+?T\d+?:\d+?:\d+?\.\d+?Z>', line):
                    continue
                date_of_message = dt.datetime.strptime(line.split(">", 1)[0], "<%Y-%m-%dT%H:%M:%S.%fZ")

                for type_of_log in SyslogFilter.TYPE_OF_LOGS:
                    if type_of_log in line:
                        line_without_type = line.split("{} ".format(type_of_log), 1)[1] \
                            .replace('\n', '').replace('\r', '')
                        logs_divided_into_types[type_of_log].append({"date": date_of_message,
                                                                     "line_without_type": line_without_type.strip()})
                        break

            log_index = 0
            for type_of_log, log_lines_info in logs_divided_into_types.items():
                buffer_for_message = ""
                for line_info in log_lines_info:
                    start_message = "{} ".format(SyslogFilter.TYPE_OF_LOGS[type_of_log]["start_message"])
                    line_without_type = line_info["line_without_type"]

                    if start_message == line_without_type[:len(start_message)]:
                        if buffer_for_message != "":
                            dict_of_logs.update({
                                str(log_index): SyslogFilter.__get_parameters_from_message(buffer_for_message.strip())}
                            )
                            dict_of_logs[str(log_index)].update({"date": line_info["date"]})
                        buffer_for_message = line_without_type
                        log_index += 1
                    elif start_message != line_without_type[:len(start_message)]:
                        buffer_for_message += line_without_type
                else:
                    dict_of_logs.update({
                        str(log_index): SyslogFilter.__get_parameters_from_message(buffer_for_message)})
                    dict_of_logs[str(log_index)].update({"date": line_info["date"]})

        return dict_of_logs

    @staticmethod
    def get_last_message_params(path_to_syslog_file, name_of_message):
        dict_of_logs = SyslogFilter.get_all_expected_messages(path_to_syslog_file)

        debug("List of all logs:\n{}".format(dict_of_logs))

        dict_of_interested_logs = {}
        for log_index, log_info in dict_of_logs.items():
            if name_of_message == log_info["name"]:
                dict_of_interested_logs.update({log_index: log_info})

        last_log_info = None
        for log_index, log_info in dict_of_interested_logs.items():
            if last_log_info is None or last_log_info["date"] < log_info["date"]:
                last_log_info = log_info

        return last_log_info["parameters"]

    @staticmethod
    def check_values_are_correct(main_dict, second_dict):
        info("Check if values of {} are correct with values of {}".format(main_dict, second_dict))

        for index, value in main_dict.items():
            if second_dict[index] != value:
                raise Exception("Value for {} should be {}, but is {}".format(index, value, second_dict[index]))
