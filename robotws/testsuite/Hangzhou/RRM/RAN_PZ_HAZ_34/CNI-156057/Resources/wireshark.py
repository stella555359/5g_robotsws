# -*- coding:utf-8 -*-
import re
import subprocess
import sys
from ta_xml.common_xml import CommonXML
from robot.libraries.BuiltIn import BuiltIn

builtin_obj = BuiltIn()


class wireshark(object):
    def __init__(self):
        pass

    def remove_empty_from_list(self, list_in):
        list_out = []
        list1 = []
        if not isinstance(list_in, list):
            list_in = [list_in]
        for value in list_in:
            is_python2 = sys.version_info.major == 2
            if is_python2:
                str_type = (unicode, bytes)
            else:
                str_type = (str, bytes)
            if isinstance(value, str_type):
                if len(value.strip()) != 0:
                    list1.append(value.strip())
            else:
                list1.append(value.strip())
        for value in list1:
            remove_equal_emtpy = re.sub(r"\s*=\s*", "=", value)
            remove_vertical_line_emtpy = re.sub(r"\s*\|\s*", "|", remove_equal_emtpy)
            list_out.append(remove_vertical_line_emtpy)
        return list_out

    def execute_cmd_on_pc(self, cmd):
        builtin_obj.log("execute cmd: {}".format(cmd))
        process = subprocess.Popen(
            cmd,
            shell=True,
            stdout=subprocess.PIPE,
            stderr=subprocess.STDOUT,
            text=True
        )
        builtin_obj.log("cmd output:")
        lines = []
        for line in process.stdout:
            line = line.rstrip()
            builtin_obj.log(line)
            lines.append(line)

        return "\n".join(lines)

    def get_wireshark_message_count(self, pcap_file, filter):
        """
        :param pcap_file: full path to pcap file
        :param filter: filter same as wireshark gui
        :return: the number of messges which satisfy filter
        """
        log_file = "/home/ute/tshark_tmp.txt"
        self.execute_cmd_on_pc("tshark -r %s -o ntrstr.defragment:TRUE -d tcp.port==49150,ntrstr "
                               "-d tcp.port==49151,ntrstr -d tcp.port==49148,ntrstr -Y '%s' > %s" % (
                                   pcap_file, filter, log_file))
        count = 0
        try:
            f = open(log_file, "r")
            for line in f.readlines():
                count = count + 1
        finally:
            f.close()
        return count

    def get_wireshark_field_value(self, pcap_file, field_path, display_filter, packet_num=0):
        """
        This keyword is to get field value from pcap file and return field value list
        | Arguments      | Man. | Default | Description |
        | pcap_file      | Yes  | NA      | pcap file |
        | field_path     | Yes  | NA      | field path separated by '/', can jump multiple fields |
        | display_filter | Yes  | NA      | wireshark filter |
        | packet         | No   | 0       | packet index, starts from 0. If two packets according to field_path \
        and display_filter, its available is 0 or 1 |

        Example data:
        csi-ReportConfigToAddModList: 9 items
            Item 0
                CSI-ReportConfig
                    reportConfigId: 0
                    resourcesForChannelMeasurement: 0
                    csi-IM-ResourcesForInterference: 11
                    reportConfigType: periodic (0)
                        periodic
                            reportSlotConfig: slots320 (9)
                                slots320: 19
                            pucch-CSI-ResourceList: 1 item

        Example 1:
        | ${slots320_values}    | Get Wireshark Field Value |
        | ...                   | /home/ute/wireshark.pcap |
        | ...                   | csi-ReportConfigToAddModList/slots320 |
        | ...                   | nr-rrc.csi_ReportConfigToAddModList == 9 |
        | ${unique_values}      | Evaluate | list(set(${slots320_values})) |
        | ${value0_number}      | count values in list | ${slots320_values} | ${unique_values[0]} |
        | ${value1_number}      | count values in list | ${slots320_values} | ${unique_values[1]} |
        | Should Be True        | ${value0_number}+${value1_number}==9 |

        Example 2:
        | ${slots320_values}    | Get Wireshark Field Value |
        | ...                   | /home/ute/wireshark.pcap |
        | ...                   | csi-ReportConfigToAddModList: 9 items/slots320 |
        | ...                   | nr-rrc.csi_ReportConfigToAddModList == 9 |
        | ...                   | packet=1 |
        | xxxx |
        """
        field_values = []
        self.execute_cmd_on_pc("tshark -r {} -o ntrstr.defragment:TRUE "
                               "-d tcp.port==49150,ntrstr -d tcp.port==49151,ntrstr -d tcp.port==49148,ntrstr "
                               "-Y '{}' -T pdml "
                               "> /home/ute/wireshark.xml".format(pcap_file, display_filter))
        commonxml_obj1 = CommonXML("/home/ute/wireshark.xml")
        field_xpath = ""
        for field in field_path.split("/"):
            field_xpath = field_xpath + "//*[matches(@showname, '{}$|{}[ :].*')]".format(field, field)
        builtin_obj.log("debug: field_xpath is {}".format(field_xpath))
        for packet in commonxml_obj1.get_elements("//packet"):
            field_values_under_frame = []
            packet = commonxml_obj1.element_to_string(packet)
            commonxml_obj2 = CommonXML(packet)
            # get frame_number
            frame_number = commonxml_obj2.get_element_attribute(
                commonxml_obj2.get_element("//*[@name='frame.number']"), "show")
            # get field values under the frame
            all = commonxml_obj2.get_elements(field_xpath)
            for element in all:
                field_values_under_frame.append(commonxml_obj2.get_element_attribute(element, "show"))
            field_values.append(field_values_under_frame)
            builtin_obj.log("debug: frame_number={}, field_values={}".format(frame_number, field_values_under_frame))
        if len(field_values) < int(packet_num) + 1:
            raise Exception("fail to get packet{}, only {} packets got according to display_filter and "
                            "field_path".format(packet_num, len(field_values)))
        else:
            return field_values[int(packet_num)]

    def _matches_expected(self, value_exp, value_act):
        if value_exp.lower().startswith("[re]"):
            pattern = value_exp[4:]
            return bool(re.fullmatch(pattern, value_act, re.I))
        else:
            pattern = r"{}(?: \(.*\))?".format(value_exp)
            return bool(re.fullmatch(pattern, value_act, re.I))

    def check_wireshark_fields(self, pcap_file, filter, check_fields, packet_num=0):
        self.execute_cmd_on_pc("tshark -r {} -o ntrstr.defragment:TRUE "
                               "-d tcp.port==49150,ntrstr -d tcp.port==49151,ntrstr -d tcp.port==49148,ntrstr "
                               "-Y '{}' -T pdml "
                               "> /home/ute/wireshark.xml".format(pcap_file, filter))
        check_fields = self.remove_empty_from_list(check_fields)
        self.execute_cmd_on_pc("ls -ltrh /home/ute/wireshark.xml")
        commonxml_obj1 = CommonXML("/home/ute/wireshark.xml")
        for field_path_value_pair in check_fields:
            builtin_obj.log("step: handle {}".format(field_path_value_pair))
            field_values = []
            field_path, field_value_exp = map(str.strip, field_path_value_pair.split('='))
            field_xpath = ""
            for field in field_path.split("/"):
                field_xpath = field_xpath + "//*[matches(@showname, '{}$|{}[ :].*')]".format(field, field)
            builtin_obj.log("debug: field_xpath is {}".format(field_xpath))
            for packet in commonxml_obj1.get_elements("//packet"):
                field_values_under_frame = []
                packet = commonxml_obj1.element_to_string(packet)
                commonxml_obj2 = CommonXML(packet)
                # get frame_number
                frame_number = commonxml_obj2.get_element_attribute(
                    commonxml_obj2.get_element("//*[@name='frame.number']"), "show")
                # get field values under the frame
                all_elements = commonxml_obj2.get_elements(field_xpath)
                for element in all_elements:
                    showname = commonxml_obj2.get_element_attribute(element, "showname")
                    field_values_under_frame.append(showname.split(":", 1)[-1].strip())
                builtin_obj.log(
                    "debug: frame_number={}, field_values={}".format(frame_number, field_values_under_frame))
                field_values.append(field_values_under_frame)

            # get specified packet or all package
            if packet_num == "all":
                field_value_act = [item for sublist in field_values for item in sublist]
            elif packet_num != "all" and len(field_values) < int(packet_num) + 1:
                raise Exception("fail to get packet{}, only {} packets got according to filter and "
                                "field_path".format(packet_num, len(field_values)))
            else:
                field_value_act = field_values[int(packet_num)]

            # compare field value
            builtin_obj.log("debug: compare field value, expected values={}, actual_values={}".format(
                field_value_exp, field_value_act))
            err_info = "checking {} failed, actual values are {}".format(field_path_value_pair, field_value_act)
            if field_value_exp == "not_existing":
                assert len(field_value_act) == 0, err_info
            elif field_value_exp == "existing":
                assert len(field_value_act) > 0, err_info
            else:
                field_value_exp_list = field_value_exp.split(",")
                assert len(field_value_exp_list) == len(field_value_act), err_info + "\n length not equal"
                flag = all(
                    any(self._matches_expected(value_exp, value_act) for value_act in field_value_act)
                    for value_exp in field_value_exp_list
                )
                assert flag, err_info


if __name__ == "__main__":
    wireshark_obj = wireshark()
    help(wireshark_obj)
