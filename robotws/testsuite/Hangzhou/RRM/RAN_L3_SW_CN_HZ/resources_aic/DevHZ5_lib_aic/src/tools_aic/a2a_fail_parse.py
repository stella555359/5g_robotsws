# -*-encoding:utf-8 -*-

"""
:copyright: Nokia Networks
:author: eric.jiang
:contact: eric.jiang@nokia-sbell.com
"""

import os
import sys
import re


class EJA2AException(Exception):
    def __init__(self, ErrorInfo):
        self.errorinfo = ErrorInfo

    def __str__(self):
        return self.errorinfo


class FailIniSection(object):
    def __init__(self, section_name, checkfile_type, log_content, whole_log_content):
        self.name = section_name  # eg: "WiresharkLog_1 CP_1"
        self.log_content = log_content
        self.whole_log_content = whole_log_content

        ret_dict = eval(re.search(r"DEBUG: Get all items from section: %s are \{'%s': (.+)\}\n" % (
            self.name, self.name), self.log_content).group(1))
        self.check_type = int(ret_dict["check_type"])  # eg: 5 or 6
        self.paradigm = ret_dict["paradigm"][2:]  # eg：".\BarringForEmergency_TRUE.pdm[2:]"
        try:
            self.check_file = ret_dict[
                "check_file"]  # eg: "rrc_Before_barAC_Th.log"; Just the A2A target file's name,not full path
        except Exception:
            # Sometimes,in wireshark ini(only one CP),some testers like write check_file \
            # in "WIRESHARKLOG_TAG_1: wireshark.txt" under [global] section, not "CHECK_FILE: wireshark.txt"
            ret = re.search("DEBUG: Get Log path dictionary: {'(.+)': '(.+)'} for section: %s\n"
                            % self.name, self.whole_log_content).group(2)
            self.check_file = str(ret)
        self.repeat_num = int(ret_dict["repeat_num"])  # eg: 1 or 2,3......
        self.checkfile_type = checkfile_type  # eg: "p" or "w"

        ret = re.search(r".+Get pdm\(csv\) list are (.+), relationship is: (.+), other para dictionary is: (.+)\n",
                        self.log_content)
        # [     {'CP1':   [{'DL-DCCH-Message':{'DL-DCCH-Message.xx.yy':'23',
        #                                      'DL-DCCH-Message.xx.zz': '22',
        #                                       ...}
        #                   }]
        #        },
        #        {'CP2':[{'UL-DCCH-Message':{'UL-DCCH-Message.xx.yy': 'None'}}]}
        #  ]
        # eg: like above; "self.pdm_cp_content" is all cp content of actual pdm file, is a list
        self.pdm_cp_content = eval(ret.group(1))
        self.pdm_cp_relationship = eval(ret.group(2))  # eg: CP1&CP2 is [['CP1'], ['CP2']]


"""F(Five)-5"""


class FFailIniSection(FailIniSection):
    def parse(self):
        ret = re.search(
            r"ERROR:\s+Fail to check pdm CP: \['(.+)'\],.+ Cause: Check one workbook or one check point fail",
            self.log_content)
        self.fail_pdm_cp_name = ret.group(1)

        ret = re.search(r"DEBUG: Cannot match field line: (.+) in current block, \
        block's first line position: \d+, last line position: \d+\n", self.log_content)
        if ret is not None and self.repeat_num == 1:
            # "self.fail_pdm_message_block" is only fail message block, a dict.
            self.fail_pdm_message_block = eval(ret.group(1))
            if self.checkfile_type == "p" or self.checkfile_type == "w":
                # get self.fail_message_block_index
                for cp in self.pdm_cp_content:
                    for k_cp, v_mb_list in cp.items():
                        if k_cp == self.fail_pdm_cp_name:
                            self.fail_cp_content_list = v_mb_list
                            for message_block_dict in self.fail_cp_content_list:
                                if list(message_block_dict.values())[0] == self.fail_pdm_message_block:
                                    self.fail_message_block_index = self.fail_cp_content_list.index(
                                        message_block_dict) + 1
                            break

                # get self.fail_message_block
                for mb_dict in self.fail_cp_content_list:
                    for k, v in mb_dict.items():
                        list1 = list(v.keys())
                        list2 = list(v.values())
                        list_kfd = list(self.fail_pdm_message_block.keys())
                        list_vfd = list(self.fail_pdm_message_block.values())
                        if sorted(list1) == sorted(list_kfd) and sorted(list2) == sorted(list_vfd):
                            self.fail_message_block = mb_dict
                            break

                # get self.fail_message_line
                if self.checkfile_type == "p":
                    ret = re.findall(
                        r"DEBUG: Get dictionary: .+for message: %s, return message is: '%s' at position: \d+\n"
                        % (list(self.fail_message_block.keys())[0],
                           list(self.fail_message_block.keys())[0]), self.log_content)
                    resdict = {}
                    for k, v in list(self.fail_message_block.values())[0].items():
                        res1 = re.match(r"\$(.+)\$", v)
                        if res1:
                            v = res1.group(1)
                        resdict[(k, v)] = 0
                    for i in ret:
                        tmpdict = eval(re.search(r"\{.+\}", i).group())
                        for j in list(resdict.keys()):
                            if j in tmpdict.items():
                                resdict[j] += 1
                    self.fail_message_line = ""
                    for k, v in resdict.items():
                        if v == 0:
                            self.fail_message_line = "%s = %s" % (k[0], k[1])
                            break
                elif self.checkfile_type == "w":
                    ret = re.findall("DEBUG: Expression type 1 compare fail: '(.+)' compare with '(.+)'\n",
                                     self.log_content)
                    expected = ret[-1][0]
                    actual = ret[-1][1]
                    for k, v in list(self.fail_message_block.values())[0].items():
                        if v == expected:
                            self.fail_message_line = "%s = %s" % (k, v)
                            break

                # Total print info
                self.fail_message_block_print = ""
                for k, v_dict in self.fail_message_block.items():
                    self.fail_message_block_print += "%s\n" % k
                    for k1, v1 in v_dict.items():
                        self.fail_message_block_print += "%s%s = %s\n" % (" " * 45, k1, v1)
                self.print_res_str = "%s : \n" % self.name + \
                                     "    paradigm:    %s \n" % self.paradigm + \
                                     "    check_type:  %s \n" % self.check_type + \
                                     "    check_file:  %s \n" % self.check_file + \
                                     "    repeat_num:  %s \n" % self.repeat_num + \
                                     "    Detail failed message:  \n" + \
                                     "        fail CP name:                    %s \n" % self.fail_pdm_cp_name + \
                                     "        fail message block index of CP:  %d \n" \
                                     % self.fail_message_block_index + \
                                     "        fail message block:              %s" % self.fail_message_block_print + \
                                     "        fail message line:               %s \n" % self.fail_message_line
                return self.print_res_str
            else:
                pass
        # This issue is the pdm message exist but repeat_num is less than expected
        # while repeat_num > 1,usually,there will be only one CP in pdm, and under this CP1,\
        # there exist only one message block.
        elif self.repeat_num > 1:
            if self.checkfile_type == "p" or self.checkfile_type == "w":
                ret = re.findall(r"Succeed to check CP: \[CP1\] at position: \d+", self.log_content)
                self.fail_message_block = "%s\n" % list(self.pdm_cp_content[0][self.fail_pdm_cp_name][0].keys())[0]
                for k, v in list(self.pdm_cp_content[0][self.fail_pdm_cp_name][0].values())[0].items():
                    self.fail_message_block += "%s%s = %s\n" % (" " * 45, k, v)
                self.fail_message_block_index = 1
                self.print_res_str = "%s : \n" % self.name + \
                                     "    paradigm:    %s \n" % self.paradigm + \
                                     "    check_type:  %s \n" % self.check_type + \
                                     "    check_file:  %s \n" % self.check_file + \
                                     "    repeat_num:  %s \n" % self.repeat_num + \
                                     "    Detail failed message:  \n" + \
                                     "        fail CP name:                    %s \n" % self.fail_pdm_cp_name + \
                                     "        fail message block index of CP:  %d \n" \
                                     % self.fail_message_block_index + \
                                     "        fail message block:              %s" % self.fail_message_block + \
                                     "        expected appear times %d ;    actual appear times %d\n" % (
                                         self.repeat_num, len(ret))
                return self.print_res_str
            else:
                pass


"""S(Six)-6"""


# If "check_type" is 6, "repeat_num" must be 1, and there usually only one CP in pdm, and under this CP1,\
# there exist only one message block.
class SFailIniSection(FailIniSection):
    def parse(self):
        self.fail_pdm_cp_name = "CP1"

        if self.checkfile_type == "p" or self.checkfile_type == "w":
            ret = re.findall(r"Succeed to check CP: \[CP1\] at position: \d+", self.log_content)
            self.fail_message_block = "%s\n" % list(self.pdm_cp_content[0][self.fail_pdm_cp_name][0].keys())[0]
            for k, v in list(self.pdm_cp_content[0][self.fail_pdm_cp_name][0].values())[0].items():
                self.fail_message_block += "%s%s = %s\n" % (" " * 45, k, v)
            self.fail_message_block_index = 1
            self.print_res_str = "%s : \n" % self.name + \
                                 "    paradigm:    %s \n" % self.paradigm + \
                                 "    check_type:  %s \n" % self.check_type + \
                                 "    check_file:  %s \n" % self.check_file + \
                                 "    repeat_num:  %s \n" % self.repeat_num + \
                                 "    Detail failed message:  \n" + \
                                 "        fail CP name:                    %s \n" % self.fail_pdm_cp_name + \
                                 "        fail message block index of CP:  %d \n" % self.fail_message_block_index + \
                                 "        fail message block:              %s" % self.fail_message_block + \
                                 "        expected appear times 0 ;    actual appear times %d\n" % len(ret)
            return self.print_res_str
        else:
            pass


class a2a_fail_parse(object):
    def __init__(self):
        # self.a2a_tool = "/opt/ute/python/lib/python2.7/site-packages/ta_a2a/tool/Au2Analysis"
        import ta_a2a
        ta_a2a_folder = os.path.dirname(ta_a2a.__file__)
        if sys.platform.startswith("win"):
            self.a2a_tool = os.path.join(ta_a2a_folder, "tool", "Au2Analysis.exe")
        else:
            self.a2a_tool = os.path.join(ta_a2a_folder, "tool", "Au2Analysis")

    # Rerun A2A procedure, open the "debug" switch, to get a new log include detail steps. \
    # checkfile_type is "p"(rrc.log) or "w"(wireshark.txt)
    def rerun_a2a(self, case_log_path, checkfile_type):
        self.case_log_path = case_log_path
        for i in os.listdir(self.case_log_path):
            ini_name = re.match(r"\S+\.ini", i)
            if ini_name is not None:
                self.ini_file_name = ini_name.group()
                self.ini_file = os.path.join(self.case_log_path, ini_name.group())
                break
        self.checkfile_type = checkfile_type
        self.fail_log = os.path.join(self.case_log_path, "a2a_fail_parse.log")
        cmd = r"%s -c %s -%s  -D -F -L %s" % (self.a2a_tool, self.ini_file, self.checkfile_type, self.fail_log)
        ret = os.popen(cmd).read()
        if not os.path.exists(self.fail_log):
            raise Exception("Rerun A2A process failed! didn't generate a2a_fail_parse.log !")
        else:
            pass
            # print("Succeed to rerun a2a process,and generate detail debug level log %s"%self.fail_log)

    def parse_a2a_fail(self, case_log_path, checkfile_type):
        self.rerun_a2a(case_log_path, checkfile_type)

        fail_log_handle = open(self.fail_log, "r")
        self.fail_log_content = fail_log_handle.read()
        fail_log_handle.close()

        self.a2atool_version = re.search(r"INFO: Au2Analysis.exe version number: (.+)\n",
                                         self.fail_log_content).group(1)

        # One testcase only have one corresponding ini file, in one ini file,maybe exist several sections; \
        # every section have one pdm and one target file.
        ret = re.findall(r"[56]\s+\|.+\|\s+Fail\s+\|.+\n", self.fail_log_content, re.U)
        self.fail_ini_section = []
        for string in ret:
            section_name = string.split("|")[1].strip()
            section_check_type = int(string.split("|")[0].strip())
            section_log_content = re.search(r"Start to check ini CP: \[%s\].+End check ini CP: \[%s\]" % (
                section_name, section_name), self.fail_log_content, re.I | re.M | re.S).group()
            if section_check_type == 5:
                ini_section_obj = FFailIniSection(section_name, checkfile_type, section_log_content,
                                                  self.fail_log_content)
            elif section_check_type == 6:
                ini_section_obj = SFailIniSection(section_name, checkfile_type, section_log_content,
                                                  self.fail_log_content)
            self.fail_ini_section.append(ini_section_obj)

        print("=" * 40 + " A2A check failed section parse result [A2A version: %s] " % self.a2atool_version + "=" * 40)
        for i in self.fail_ini_section:
            print(i.parse())
        print("=" * 200)

        raise EJA2AException("ERR/: A2A check log failed,and detail analyze info as above print !")


if __name__ == "__main__":
    pass
    # obj = a2a_fail_parse()
    # obj.parse_a2a_fail(r"C:\ericjiang\python_robotframework\for_our_ta_framework
    # \a2a_fail_parse\local_a2a_debug_tool\debug","w")
