# -*- coding: utf-8 -*-
"""
2022/05/22 first version by @author: xiang.5.li@nokia-sbell.com
"""
import os
import re
try:
    from .logger_et import LoggingEt
except Exception as e:
    from logger_et import LoggingEt
import copy


class ReadEgateByMessage(object):
    def __init__(
            self,
            log_path,
            egateFile,
            message_head,
            anchor,
            paras,
            *args,
            **kwargs):
        """
        Get the rrc information.
        :param log_path: log path.
        :param egateFile: log file.
        :param message: message name， type:str, such as:"xxx"
        :param anchor: parameters include in which brance, type：list，such as[xxx, xxx]
        :param paras:need to get parameter type：list，such as:[xxx, xxx]
        """
        self.log_path = log_path
        self.egate_file = egateFile
        self.message_head = message_head
        self.anchor = [anchor] if type(anchor) is str else anchor
        self.paras = [paras] if type(paras) is str else paras
        __logger_name = os.path.basename(__file__)
        self.log = LoggingEt(self.log_path, __logger_name).log()
        self.paras_result = {}
        self.egate = None

    def get_message(self, lines):
        msg, open_brace, close_brace = '', 0, 0
        while True:
            line = lines.readline()
            if "{" in line:
                open_brace += 1
            elif "}" in line:
                close_brace += 1
            if open_brace > close_brace:
                msg += line
            elif open_brace == close_brace:
                msg += line
                break
        # print("get_message:%s" % msg)
        # print(open_brace, close_brace)
        # print(msg)
        return msg

    @staticmethod
    def get_msg_split_flag(msg):
        split_flag = "\n"
        if '\r\n' in msg:
            split_flag = "\r\n"
        elif "\n" in msg:
            split_flag = "\n"
        elif "\r" in msg:
            split_flag = "\r"
        return split_flag

    def get_msg_form_anchor(self, msg_lines, index):
        """
        get the message, such as: anchor {xx{xxxx}}, means all of this pair brace info.
        :param msg_lines:
        :param index:
        :return:
        """
        open_brace, close_brace, msg_anchor = 0, 0, ''
        num = index
        for num in range(index + 1, len(msg_lines)):
            line = msg_lines[num]
            if "{" in line:
                open_brace += 1
            elif "}" in line:
                close_brace += 1
            if open_brace > close_brace:
                msg_anchor += line + "\n"
            elif open_brace == close_brace:
                msg_anchor += line + "\n"
                break
        self.log.debug("msg_ancho length:%s, index:%s" %
                       (len(msg_anchor), num))
        return msg_anchor, num

    def get_paras_from_msg_anchor(self, anchor_point, msg_anchor):
        """
        generate the result according the "paras".
        :param anchor_point:
        :param msg_anchor:
        :return:
        """
        result = {}
        msg_anchor_lines = msg_anchor.split('\n')
        for msg_anchor_line in msg_anchor_lines:
            for para in self.paras:
                if para in msg_anchor_line:
                    value = msg_anchor_line.strip().strip(
                        ",").split(" ", 1)[-1]
                    if para in result:
                        tmp_value = copy.deepcopy(result[para])
                        tmp_value.append(value)
                        result[para] = tmp_value
                    else:
                        result[para] = [value]
        print(anchor_point, result)
        if anchor_point not in self.paras_result:
            self.paras_result[anchor_point] = [result]
        else:
            value_tmp = copy.deepcopy(self.paras_result[anchor_point])
            value_tmp.append(result)
            print("111:", anchor_point, value_tmp)
            self.paras_result[anchor_point] = value_tmp

    def get_paras(self, msg):
        """
        get parameters from the whole message.
        :param msg:
        :return:
        """
        split_flag = self.get_msg_split_flag(msg)
        msg_lines = msg.split(split_flag)
        for index in range(0, len(msg_lines)):
            for anchor_point in self.anchor:
                if anchor_point in msg_lines[index]:
                    msg_anchor, index = self.get_msg_form_anchor(
                        msg_lines, index)
                    self.get_paras_from_msg_anchor(anchor_point, msg_anchor)

    def parser_egate_file(self):
        """
        Start parser the egate file.
        :return:
        """
        with open(self.egate_file) as f:
            while 1:
                line = f.readline()
                if "::=" in line:
                    if self.message_head in line:
                        msg = self.get_message(f)
                        self.get_paras(msg)
                if not line:
                    break
        self.log.info("The egate log parameters:%s" % self.paras_result)
        return self.paras_result


class ParserEgate(object):
    def __init__(
            self,
            log_path,
            egateFile,
            message_anchor_paras,
            *args,
            **kwargs):
        self.log_path = log_path
        self.egate_file = egateFile
        self.map = message_anchor_paras
        __logger_name = os.path.basename(__file__)
        self.log = LoggingEt(self.log_path, __logger_name).log()
        self.paras_result = []
        self.msg = {}
        self.msg_key = ""
        self.cell_regex = re.compile(
            "(\\d+:\\d+:\\d+\\.\\d+).*?eNB (\\d+) cell (\\d+) " +
            "\\(PCI=\\d+:\\d+ \\((\\d+)\\) @ DL/UL = (.*?)\\s+\\w+ TECHNOLOGY = (\\w+)\\)")
        self.msg_wo_ue = re.compile(
            "\\d+:\\d+:\\d+\\.\\d+\\s+(\\d+:\\d+:\\d+\\.\\d+).*?(UEC-\\d+)")
        self.msg_w_ue = re.compile(
            "\\d+:\\d+:\\d+\\.\\d+\\s+(\\d+:\\d+:\\d+\\.\\d+).*?(UEC-\\d+): (UE\\d+)")
        self.time_regex = re.compile(
            "\\d+:\\d+:\\d+\\.\\d+\\s+(\\d+:\\d+:\\d+\\.\\d+)")
        self.value_in_next_brace = ["mcc", "mnc"]

    def time2ms(self, time_str):
        """
        cnvert time to ms
        :param time_str: such as 17:45:15.010
        :return:
        """
        h, m, s, ms = time_str.replace(".", ":").split(":")
        return (int(h) * 3600 + int(m) * 60 + int(s)) * 1000 + int(ms)

    def get_cell_info(self, line):
        result = {}
        info_regex = self.cell_regex.search(line)
        # print("info_regex:", info_regex)
        result['msg_type'] = "cell_info"
        result["time_stamp"] = info_regex.group(1)
        result['enb_id'] = info_regex.group(2)
        result['cell_id'] = info_regex.group(3)
        result['pci'] = info_regex.group(4)
        result['dl_fre'] = info_regex.group(5).split("/")[0]
        result['ul_fre'] = info_regex.group(5).split("/")[1]
        result['technology'] = info_regex.group(6)
        self.paras_result.append(result)

    def is_target_msg(self, line):
        for key in self.map.keys():
            if key in line:
                self.msg_key = key
                return True
        return False

    def get_message_time(self, line):
        if "[RRC]" in line:
            self.msg['technology'] = "lte"
        elif "[NR-RRC]" in line:
            self.msg["technology"] = 'nr'
        if self.msg_wo_ue.search(line):
            msg_wo_ue_regex = self.msg_wo_ue.search(line)
            self.msg['time_stamp'] = msg_wo_ue_regex.group(1)
            self.msg['uec'] = msg_wo_ue_regex.group(2)
        elif self.msg_w_ue.search(line):
            msg_w_ue_regex = self.msg_wo_ue.search(line)
            self.msg['time_stamp'] = msg_w_ue_regex.group(1)
            self.msg['uec'] = msg_w_ue_regex.group(2)
            self.msg['ue'] = msg_w_ue_regex.group(3)

    def get_message_type(self, index, lines):
        line = lines[index + 2]
        if line.strip() == "message" and self.msg['technology'] == 'lte':
            self.msg["msg_type"] = "mib"
        else:
            index = index + 2
            for num in range(index, index + 10):
                line = lines[num].strip()
                if "{" in line:
                    break
                if line.startswith("message"):
                    line_lst = line.strip().split(":")
                    line_lst = [x.strip() for x in line_lst]
                    if line_lst[0] == "message mib":
                        self.msg["msg_type"] = "mib"
                    elif line_lst[1] != " ":
                        self.msg["msg_type"] = line_lst[1]
                elif line.startswith("value"):
                    line_lst = line.strip().split(" ")
                    line_lst = [x.strip() for x in line_lst]
                    if line_lst[1] != " ":
                        self.msg["msg_type"] = line_lst[1]
                elif "rrcReconfiguration" in line:
                    self.msg["msg_type"] = "rrcReconfiguration"

    def get_message_lines(self, index, lines):
        msg, open_brace, close_brace = [], 0, 0
        index = index + 1
        while 1:
            line = lines[index]
            index += 1
            if "{" in line:
                open_brace += 1
            elif "}" in line:
                close_brace += 1
            if open_brace > close_brace:
                msg.append(line)
            elif open_brace == close_brace:
                msg.append(line)
                break
        # print("get_message:%s" % msg)
        # print(open_brace, close_brace)
        # print(msg)
        return index - 1, msg

    def get_message(self, index, lines):
        self.get_message_time(lines[index - 1])
        self.get_message_type(index, lines)
        return self.get_message_lines(index, lines)

    def get_value_from_next_brace(self, key, index, msg):
        value = []
        while 1:
            index = index + 1
            if "{" in msg[index]:
                continue
            if "}" in msg[index]:
                break
            else:
                value.append(msg[index].strip().strip(","))
        self.msg[key] = value

    def parser_msg(self, msg):
        paras = self.map[self.msg_key]
        anchor_tmp = {}
        for index, line in enumerate(msg):
            for anchor, para in paras.items():
                # del the anchor after get required paras.
                if anchor in anchor_tmp:
                    if anchor_tmp[anchor] != [0, 0] and len(
                            set(anchor_tmp[anchor])) == 1:
                        anchor_tmp.pop(anchor)
                    else:
                        if "{" in line:
                            anchor_tmp[anchor][0] = anchor_tmp[anchor][0] + 1
                        if "}" in line:
                            anchor_tmp[anchor][1] = anchor_tmp[anchor][1] + 1
                # add the anchor to anchor_tmp
                # print("anchor_tmp", ":", anchor_tmp)
                if anchor in line:
                    anchor_tmp[anchor] = [0, 0]
            for key in anchor_tmp:
                for item in paras[key]:
                    item_tmp = item[:item.find("##")] if "##" in item else item
                    if item_tmp in line:
                        if item in self.value_in_next_brace:
                            self.get_value_from_next_brace(item, index, msg)
                        else:
                            value = line.strip().split(" ")[1]
                            value = value.strip(",")
                            self.msg[item] = value

    def update_cell_info(self, index, index_tmp, lines):
        if "technology" not in self.msg:
            return
        cell_regex = re.compile(
            "\\d+:\\d+:\\d+\\.\\d+ .*?UEC-\\d+: eNB (\\d+) cell (\\d+):")
        rrc_seup_regex = re.compile(
            "\\[UeId:(\\d+),BwpId:(\\d+), pcid:(\\d+), scellIdx:(\\d+)\\]")
        if self.msg['technology'] == "lte":
            if self.msg['msg_type'] == "mib":
                for line_num in range(index_tmp, index_tmp + 10):
                    line = lines[line_num].strip()
                    if line.endswith("Updated") and "MIB" in line:
                        self.msg["enb_id"] = cell_regex.search(line).group(1)
                        self.msg['cell_id'] = cell_regex.search(line).group(2)
                        break
            elif self.msg['msg_type'] in ["systemInformationBlockType1", "systemInformation"]:
                for line_num in range(index, index - 5):
                    line = lines[line_num].strip()
                    if line.endswith(
                            "Updated") and "SystemInformationBlockType1" in line:
                        self.msg["enb_id"] = cell_regex.search(line).group(1)
                        self.msg['cellid_id'] = cell_regex.search(
                            line).group(2)
                        break
        elif self.msg['technology'] == "nr":
            if self.msg['msg_type'] in [
                "mib",
                "systemInformationBlockType1",
                    "systemInformation"]:
                for line_num in range(index_tmp, index_tmp + 10):
                    line = lines[line_num].strip()
                    if line.endswith("Updated") or line.endswith("updated"):
                        self.msg["enb_id"] = cell_regex.search(line).group(1)
                        self.msg['cell_id'] = cell_regex.search(line).group(2)
                        break
            elif self.msg['msg_type'] == "rrcSetup":
                for line_num in range(index_tmp, index_tmp + 5):
                    line = lines[line_num].strip()
                    if self.msg['uec'] in line and rrc_seup_regex.search(line):
                        self.msg["UeId"] = rrc_seup_regex.search(line).group(1)
                        self.msg["BwpId"] = rrc_seup_regex.search(
                            line).group(2)
                        self.msg["pciId"] = rrc_seup_regex.search(
                            line).group(3)
                        self.msg["scellIdx"] = rrc_seup_regex.search(
                            line).group(4)
                        break
            elif self.msg['msg_type'] == "rrcReconfiguration":
                for line_num in range(index_tmp, index_tmp + 5):
                    line = lines[line_num].strip()
                    if self.msg['uec'] in line and rrc_seup_regex.search(line):
                        self.msg["UeId"] = rrc_seup_regex.search(line).group(1)
                        self.msg["BwpId"] = rrc_seup_regex.search(
                            line).group(2)
                        self.msg["pciId"] = rrc_seup_regex.search(
                            line).group(3)
                        self.msg["scellIdx"] = rrc_seup_regex.search(
                            line).group(4)
                        break

    def parser_egate(self):
        with open(self.egate_file) as f:
            lines = f.readlines()
            length = len(lines)
            index_tmp = 0
            for index in range(0, length):
                line = lines[index]
                if index_tmp > index:
                    continue
                if "Established connection with proxy to" in line:
                    self.get_cell_info(line)
                if "::=" in line:
                    # self.msg = {}
                    if self.is_target_msg(line):
                        # get msg type and msg time.
                        index_tmp, msg, = self.get_message(index, lines)
                        self.parser_msg(msg)
                        self.update_cell_info(index, index_tmp, lines)
                    if self.msg:
                        self.paras_result.append(self.msg)
                        self.msg = {}
                        self.msg_key = ''
        return self.paras_result
        print(self.paras_result)


if __name__ == "__main__":
    log_path = r"C:\work\data\017-Feature\5G\8534\TDRA_log\CB007601_Auto_semiStatic_DL14"
    egateFile = r"C:\work\data\017-Feature\5G\8534\TDRA_log\CB007601_Auto_semiStatic_DL14\egate_console.log"
    # file = r"C:\work\data\017-Feature\5G\8534\TDRA_log\CB007601_Auto_semiStatic_DL14\iphy.xml"

    # message_head = 'value RRCReconfiguration ::='
    # anchor = ["pdsch-ServingCellConfig", "nzp-CSI-RS-ResourceToAddModList"]
    # paras = ["nrofHARQ-ProcessesForPDSCH", "maxMIMO-Layers", "nzp-CSI-RS-ResourceId", "periodicityAndOffset"]
    # readegate = ReadEgateByMessage(log_path, egateFile, message_head, anchor, paras)
    # readegate.parser_egate_file()

    message_anchor_paras = {
        "BCCH-BCH-Message ::=": {"message": ["dl-Bandwidth", "phich-Duration", "phich-Resource"]},
        "BCCH-DL-SCH-Message ::=": {"cellAccessRelatedInfo": ["mcc", "q-RxLevMin", "p-Max"]},
        "X2AP-PDU ::= initiatingMessage": {"InitiatingNodeType-EndcX2Setup : init-eNB": ["id", "eARFCN"]}
    }
    paraser_egate = ParserEgate(log_path, egateFile, message_anchor_paras)
    paraser_egate.parser_egate()
