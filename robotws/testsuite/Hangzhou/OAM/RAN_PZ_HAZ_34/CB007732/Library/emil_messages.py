import re
import json
from robot.api import logger


def _load_json_file(origin_file):
    with open(origin_file, 'r') as f:
        r = json.load(f)
        return r


def _get_emil_message(source_file):
    my_emil = emil_analyzer(source_file)
    return my_emil.zqm_message()


def check_valid_start_recording_session(source_file, with_stop_valid=False):
    source_message = _get_emil_message(source_file)
    start_count = _read_message_count(source_message, "startRecordingSession")
    if with_stop_valid:
        stop_count = _read_message_count(source_message, "stopRecordingSession")
        return start_count - stop_count
    else:
        return start_count


def check_target_message_all_matched(source_file, target_file, should_found=True):
    source_message = _get_emil_message(source_file)
    logger.info(source_message, also_console=True)
    target_dict = _load_json_file(origin_file=target_file)
    logger.info(target_dict, also_console=True)
    unfound_list = []
    for key in target_dict.keys():
        if should_found:
            if key.lower() not in [source_message_key.lower() for source_message_key in source_message]:
                unfound_list.append(key)
        else:
            if key.lower() in [source_message_key.lower() for source_message_key in source_message]:
                unfound_list.append(key)
    if unfound_list:
        if should_found:
            raise Exception("Message Not Found", unfound_list)
        else:
            raise Exception("Message Should Not Found", unfound_list)


def _read_message_count(message_dict, search_message):
    for key, value in message_dict.items():
        if key.lower() == search_message.lower():
            return value
    return 0


class emil_analyzer():
    zqm_expr_dict = {
        "NGAP-PDU": r"value\s+(\w+)\s+:",
        "TraceMessage": r"TraceMessage\s+:\s+(\w+)\s+:",
        "UL-CCCH-Message": r"message c1\s+:\s+(\w+)\s+:",
        "DL-CCCH-Message": r"message c1\s+:\s+(\w+)\s+:",
        "UL-DCCH-Message": r"message c1\s+:\s+(\w+)\s+:",
        "DL-DCCH-Message": r"message c1\s+:\s+(\w+)\s+:",
        "XNAP-PDU": r"value\s+(\w+)\s+:",
        "X2AP-PDU": r"value\s+(\w+)\s+:",
        "DuVendorExtensionRecordDataType": r"DuVendorExtensionRecordDataType\s+:\s+(\w+)\s+:\s+data",
        "CuVendorExtensionRecordDataType": r"CuVendorExtensionRecordDataType\s+:\s+(\w+)\s+:\s+data"
    }

    def __init__(self, emil_file):
        self.msg_str = self._read_file(emil_file)
        if self.msg_str.count('AASYSLOG') > 0:
            self.message_type = "aasyslog"
        else:
            self.message_type = "zqm"

    def _read_file(self, emil_file):
        with open(emil_file, "r") as fp:
            file_str = fp.read()
            return file_str

    def _split_zqm_messages(self, msg_str):
        return msg_str.split(r"Message:")

    def convert_message(self):
        if self.message_type == "aasyslog":
            return self.aasyslog_message()
        else:
            return self.zqm_message()

    def aasyslog_message(self):
        pass

    def zqm_message(self):
        msg_statistic = {}
        messages = self._split_zqm_messages(self.msg_str)
        for message in messages:
            try:
                message_type = message.splitlines()[1].split(" : ")[0]
                if not message or message_type not in self.zqm_expr_dict:
                    continue
                msg_name = re.findall(self.zqm_expr_dict[message_type], message)
                if msg_name:
                    if msg_name[0] == "report":
                        message_type = re.findall(r"[\w]uVendorExtensionRecordDataType", message)
                        if message_type:
                            msg_name = re.findall(self.zqm_expr_dict[message_type[0]], message)
                            if msg_name:
                                self._add_new_set_dict(msg_name[0], msg_statistic)
                    else:
                        self._add_new_set_dict(msg_name[0], msg_statistic)
            except Exception as e:
                print("zqm_message() catch exception: %s", str(e))

        return msg_statistic

    def _add_new_set_dict(self, key, dict):
        if key not in dict.keys():
            dict[key] = 0
        dict[key] += 1
        return dict


def bin_to_dec(bin_value):
    return int(bin_value, 2)
