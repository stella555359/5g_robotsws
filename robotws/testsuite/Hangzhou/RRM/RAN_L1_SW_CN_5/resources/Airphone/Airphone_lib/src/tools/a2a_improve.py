# -*- coding: utf-8 -*-
"""
:copyright: Nokia Networks
:author: I_ASL3_HZH_TA_FRAMEWORK_GMS@internal.nsn.com
:contact: I_ASL3_HZH_TA_FRAMEWORK_GMS@internal.nsn.com
"""

import os
import re
from robot.libraries.BuiltIn import BuiltIn
from robot.libraries.OperatingSystem import OperatingSystem

builtin_obj = BuiltIn()
os_obj = OperatingSystem()


class a2a_improve(object):

    def __init__(self):
        pass

    def __del__(self):
        pass

    def _parse_a2a_ini(self, a2a_ini):
        sep = ":"
        a2a_ini_dict = {}
        with open(a2a_ini, 'r') as f:
            for line in f.readlines():
                if line.strip().startswith("#"):
                    continue
                # [block title]
                if line.count("[") and line.count("]"):
                    key = line.strip()[1:-1].lower()
                    if key not in a2a_ini_dict:
                        a2a_ini_dict[key] = {}
                # name:value
                elif line.count(sep):
                    a2a_ini_dict[key][line.split(sep)[0].strip().lower().replace("_tag", "")] = \
                        line.split(sep)[1].strip().replace("/", os.sep).replace("\\", os.sep)
                else:
                    pass
        return a2a_ini_dict

    def _get_wireshark_info(self, a2a_ini):
        """
        Get wireshark info with dict, the key is wireshark file and the value is pdm files.
        When CHECK_TYPE is 0 or 1, the value is ini file.
        """
        wireshark_info = {}
        logdir = builtin_obj.get_variable_value("${SAVE LOG DIRECTORY}")
        a2a_ini_dict = self._parse_a2a_ini(a2a_ini)
        for key in a2a_ini_dict.keys():
            if key.count("wireshark"):
                wireshark_file = os.path.join(logdir, a2a_ini_dict["global"][key.split()[0]])
                if wireshark_file.endswith(".txt") is False:
                    wireshark_file = os.path.join(wireshark_file, a2a_ini_dict[key]["check_file"])
                if wireshark_file not in wireshark_info:
                    wireshark_info[wireshark_file] = []
                try:
                    wireshark_info[wireshark_file].append(os.path.join(os.path.dirname(a2a_ini),
                                                                       a2a_ini_dict[key]["paradigm"]))
                except Exception:
                    wireshark_info[wireshark_file].append(a2a_ini)
        return wireshark_info

    def _parse_wireshark_pdm(self, pdm_files):
        messages_care = []
        for wireshark_pdm in pdm_files:
            with open(wireshark_pdm, 'r') as f:
                for line in f.readlines():
                    line = "=".join([i.strip() for i in line.split("=")])  # remove space around “=”
                    if line.startswith("#"):
                        continue
                    if line.count("x2ap_pdu="):
                        messages_care.append(r"X2AP-PDU:.*\(%s\)" % line.split("=")[-1])
                    elif line.count("s1ap_pdu="):
                        messages_care.append(r"S1AP-PDU:.*\(%s\)" % line.split("=")[-1])
                    elif line.count("E1AP-PDU="):
                        messages_care.append(r"E1AP-PDU:.*\(%s\)" % line.split("=")[-1])
                    elif line.count("procedure_code=") or line.count("procedureCode="):
                        messages_care.append(r"procedureCode:.*\(%s\)" % line.split("=")[-1])
                    elif line.count(".id-Cause"):
                        messages_care.append(r"%s:.*\(%s\)" % (line.split(".")[-1].split("=")[0].strip(),
                                                               line.split(".")[-1].split("=")[1].strip()))
                    elif line.count(".id-"):
                        id_str = "id-" + line.split("id-")[1].split(".")[0]
                        messages_care.append(id_str)
                    elif line.count("nsnti.") or line.count("nsnti[") or line.count("nsetap.") \
                            or line.count("nsetap["):
                        messages_care.append(line.split(".")[4].split("=")[0].strip())
                    # ethernet.vlan.ip.sctp.ngap.NGAP-PDU.initiatingMessage.value.InitialContextSetupRequest.proto...
                    # ethernet.ip.sctp.ngap.NGAP-PDU.initiatingMessage.value.NGSetupRequest = None
                    elif line.count("value."):
                        messages_care.append(line.partition("value.")[-1].split(".")[0].split("=")[0])
                    elif line.count("sctp.shutdown"):
                        messages_care.append("shutdown")
                    elif line.count("sctp.abort"):
                        messages_care.append("abort")
                    elif line.count("value="):
                        right_part_of_equation = line.split("=")[-1]
                        if '*' == right_part_of_equation:
                            raise Exception("recreate wireshark can't extract keyword from {}， "
                                            "please contact TA group".
                                            format(line)
                                            )
                        messages_care.append("%s" % right_part_of_equation)
                    else:
                        pass

        messages_care = list(set(messages_care))
        builtin_obj.log("messages to care: %s" % messages_care)
        return messages_care

    def _parse_wireshark_txt(self, wireshark_file):
        out = []
        one_frame = ""
        with open(wireshark_file, 'r') as f:
            for line in f.readlines():
                match = re.match(r"Frame \d+:", line, re.I)
                if match is not None:
                    out.append(one_frame)
                    one_frame = line
                else:
                    one_frame = one_frame + line
            out.append(one_frame)
        return out

    def recreate_wireshark_txt_files(self, a2a_ini):
        "recreate wireshark txt files according to wireshark pdm files, only keep the messages to be checked, \
        in order to reduce execution time"
        wireshark_info = self._get_wireshark_info(a2a_ini)
        if builtin_obj.get_variable_value('${RECREATE_WIRESHARK_FLAG}') is True:
            for wireshark in wireshark_info.keys():
                try:
                    os_obj.file_should_exist(wireshark + "_org")
                except Exception:
                    os_obj.move_file(wireshark, wireshark + "_org")

                pdm_files = wireshark_info[wireshark]
                messages_care = self._parse_wireshark_pdm(pdm_files)
                if len(messages_care) == 0:
                    builtin_obj.log("no specify care messages in pdm files, restore wireshark txt")
                    os_obj.copy_file(wireshark + "_org", wireshark)
                    continue
                builtin_obj.log("orginal wireshark file: %s_org" % wireshark)
                builtin_obj.log("new wireshark file: %s" % wireshark)
                builtin_obj.log("only the following frames are kept:")
                messages_org = self._parse_wireshark_txt(wireshark + "_org")
                with open(wireshark, 'w') as f:
                    for message in messages_org:
                        for message_care in messages_care:
                            match = re.search(r"%s" % message_care, message, re.I)
                            if match is not None:
                                f.write(message)
                                lines = message.splitlines()
                                # find message value and it is 3 lines below procedureCode
                                for index in range(len(lines)):
                                    if lines[index].count("procedureCode"):
                                        break
                                try:
                                    builtin_obj.log("%s: %s" % (lines[0].split(":")[0], lines[index + 3].strip()))
                                except Exception:
                                    # no message value for trace messages
                                    builtin_obj.log("%s" % (lines[0].split(":")[0]))
                                break
                if os.path.getsize(wireshark) == 0:
                    builtin_obj.log("the size of new created wireshark txt is 0, restore it.")
                    os_obj.copy_file(wireshark + "_org", wireshark)
        else:
            for wireshark in wireshark_info.keys():
                try:
                    os_obj.file_should_exist(wireshark + "_org")
                    os_obj.copy_file(wireshark + "_org", wireshark)
                except Exception:
                    pass
