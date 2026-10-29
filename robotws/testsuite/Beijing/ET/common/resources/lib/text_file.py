# -*- coding: utf-8 -*-
"""
2022/06/09 first version by @author: xiang.5.li@nokia-sbell.com
"""

try:
    from .logger_et import LoggingEt
except BaseException:
    from logger_et import LoggingEt
import copy
import re
import os


class ReadPcapMessage(object):
    def __init__(
            self,
            log_path,
            pcapFile,
            message_anchor_paras,
            *args,
            **kwargs):
        """
        Get the rrc information.
        :param log_path: log path.
        :param pcapFile: log file.
        :param message: message name， type:str, such as:"xxx"
        :param anchor: parameters include in which brance, type：list，such as[xxx, xxx]
        :param paras:need to get parameter type：list，such as:[xxx, xxx]
        """
        self.log_path = log_path
        self.pcap_file = pcapFile
        self.map = message_anchor_paras
        __logger_name = os.path.basename(__file__)
        self.log = LoggingEt(self.log_path, __logger_name).log()
        self.paras_result = []
        self.default_paras = ["Arrival Time", "Epoch Time"]
        self.value_in_next_line = [
            "periodicityAndOffset", "frequencyDomainAllocation"]
        self.default_paras_flag = 0
        self.frame_paras_result = {}
        self.anchor_l_space = {}  # record the search parameters range.

    def get_message(self, frame):
        line_num = 0
        for line in frame:
            for key in self.map.keys():
                if key in line:
                    return key
            line_num += 1
            if line_num > 150:
                break
        return None

    def get_default_value(self, line):
        value = line.split(":", 1)[1].strip()
        return value

    def get_default_paras(self, line):
        if len(self.default_paras) == self.default_paras_flag:
            return
        for item in self.default_paras:
            if item in line:
                self.default_paras_flag += 1
                value = self.get_default_value(line)
                if item == "Arrival Time":
                    value = value.replace(" China Standard Time", '')
                if item == "Epoch Time":
                    value = value.replace(" seconds", '')
                self.frame_paras_result[item] = value

    def get_required_value(self, item, index, line, frame):
        if item in self.value_in_next_line:
            value = frame[index + 1].strip()
        else:
            value = line.split(":", 1)[1].strip()
        return value

    def get_required_paras(self, message, index, line, frame):
        required_paras = self.map[message]
        for key, paras in required_paras.items():
            # get all ancho para then del this anchor from self.anchor_l_space
            if key in self.anchor_l_space and self.anchor_l_space[key] == len(
                    line) - len(line.lstrip(" ")):
                self.anchor_l_space.pop(key)
            if key in line:
                # calc space length in the head of line and add this anchor to
                # self.anchor_l_space.
                self.anchor_l_space[key] = len(line) - len(line.lstrip(" "))
            elif key in self.anchor_l_space:
                for item in paras:
                    item_tmp = item[:item.find("##")] if "##" in item else item
                    if item_tmp in line:
                        value = self.get_required_value(
                            item_tmp, index, line, frame)
                        if item in self.frame_paras_result:
                            value_tmp = copy.deepcopy(
                                self.frame_paras_result[item])
                            value_tmp.append(value)
                            self.frame_paras_result[item] = value_tmp
                        else:
                            self.frame_paras_result[item] = [value]

    def get_paras(self, message, frame):
        """
        get parameters from the whole message.
        :param message: show which frame
        :param frame: total frame lines
        :return:
        """
        self.default_paras_flag = 0
        self.frame_paras_result = {}
        self.frame_paras_result['type'] = message
        for index, line in enumerate(frame):
            self.get_default_paras(line)
            self.get_required_paras(message, index, line, frame)

    def parser_pcap_file(self):
        """
        Start parser the egate file.
        :return:
        """
        frame = []
        self.result_info = []
        frame_regex = '^Frame\\s+\\d+:\\s+\\d+'
        with open(self.pcap_file) as f:
            while 1:
                mylog = f.readlines(50000000)
                if len(mylog) == 0:
                    break
                for line in mylog:
                    # fetch one frame of pcap info.
                    if re.search(frame_regex, line):
                        message = self.get_message(frame)
                        if message:
                            self.get_paras(message, frame)
                        if self.frame_paras_result:
                            self.paras_result.append(self.frame_paras_result)
                            self.frame_paras_result = {}
                        frame = []
                    else:
                        frame.append(line)
        self.log.info("pcap:%s" % self.paras_result)
        return self.paras_result


if __name__ == "__main__":
    log_path = r"C:\work\data\017-Feature\5G\8534\TDRA_log\manual_Dl14_secondaryList_actpdsch_true"
    x2File = r"C:\work\data\017-Feature\5G\8534\TDRA_log\manual_Dl14_secondaryList_actpdsch_true\x2gnp-2.txt"
    paras = ["nrofHARQ-ProcessesForPDSCH", "maxMIMO-Layers",
             "nzp-CSI-RS-ResourceId", "periodicityAndOffset"]
    message_anchor_paras = {
        "SgNBAdditionRequestAcknowledge": {
            "nzp-CSI-RS-ResourceToAddModList":
                ["nzp-CSI-RS-ResourceId", "firstOFDMSymbolInTimeDomain",
                    "periodicityAndOffset"],
            "pdsch-ConfigCommon: setup (1)": ["startSymbolAndLength##common"],
            "pdsch-Config: setup (1)": ['startSymbolAndLength##dedicate']
        }
    }

    readegate = ReadPcapMessage(log_path, x2File, message_anchor_paras)
    readegate.parser_pcap_file()
