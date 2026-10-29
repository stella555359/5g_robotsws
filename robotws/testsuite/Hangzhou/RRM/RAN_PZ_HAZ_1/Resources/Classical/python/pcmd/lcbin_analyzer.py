import re
from collections import defaultdict


class lcbin_analyzer():
    lcbin_expr_dict = {
        "TraceMessage": r"TraceMessage\s+:\s+(\w+)\s+:",
        "DuVendorExtensionRecordDataType": r"DuVendorExtensionRecordDataType\s+:\s+(\w+)\s+:\s+data",
        "CuVendorExtensionRecordDataType": r"CuVendorExtensionRecordDataType\s+:\s+(\w+)\s+:\s+data"
    }

    def __init__(self, lcbin_file):
        self.msg_str = self._read_file(lcbin_file)
        self.message_type = "lcbin"

    def _read_file(self, lcbin_file):
        with open(lcbin_file, "r") as fp:
            file_str = fp.read()
            return file_str

    def _remove_chars(self, input_str, chars):
        for char in chars:
            input_str = input_str.replace(char, "")
        return input_str

    def remove_dup(self, input_list):
        re_lst = list(set(input_list))
        return re_lst

    def convert_lcbin_message(self):
        messages = self.msg_str.split(r"TraceMessage :")
        message_list = []
        msg_statistic = defaultdict(list)
        for message in messages:
            try:
                tmp_list = re.split(r"\n|\r", message)
                tmp_list = [string for string in tmp_list if string != ""]
                if len(tmp_list) > 0:
                    message_list.append(tmp_list)
                for k, *v in message_list:
                    k = self._remove_chars(k, [' ', ':', '{'])
                    msg_statistic[k].append(v)
            except Exception as e:
                print("convert_message exception: %s", str(e))
        return msg_statistic

    def get_plmn(self, VendorExtension, target_RecordDataType, activation_type, target_crnti):
        word1 = r"plmn-Identity"
        key = [word1]
        a = dict([(k, []) for k in key])
        d = self.convert_lcbin_message()
        for item in d['report']:
            merged_string = ' '.join(element.strip() for element in item)
            if VendorExtension in merged_string:
                split_point = re.search(VendorExtension, merged_string).start()
                first_part = merged_string[:split_point]
                second_part = merged_string[split_point:]
                trace_activation_type_pattern = r"traceActivationType\s+(\w+),"
                crnti_pattern = r"crnti\s+(\d+)"
                plmn_identity_pattern = r"plmn-Identity\s+'(\w+ \w+ \w+)'H"
                RecordDataType_pattern = VendorExtension + r"\s*:\s*(\S+)\s*:\s*(.*)"
                trace_activation_type_match = re.search(trace_activation_type_pattern, first_part)
                crnti_match = re.search(crnti_pattern, first_part)
                plmn_identity_match = re.search(plmn_identity_pattern, second_part)
                recordDataType_match = re.search(RecordDataType_pattern, second_part)
                if trace_activation_type_match and crnti_match and recordDataType_match:
                    trace_activation_type = trace_activation_type_match.group(1)
                    crnti = crnti_match.group(1)
                    recordDataType = recordDataType_match.group(1)
                    if trace_activation_type == activation_type and crnti == target_crnti \
                            and recordDataType == target_RecordDataType:
                        plmn_identity = plmn_identity_match.group(1)
                        a[word1].append(plmn_identity)

        for word in key:
            a[word] = self.remove_dup(a[word])
        return a[word1]
