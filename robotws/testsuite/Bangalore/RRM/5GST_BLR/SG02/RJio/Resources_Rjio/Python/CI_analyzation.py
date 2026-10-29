# -*- coding:utf-8 -*-
"""
:copyright: Nokia Networks
:author: Civen Chen
:contact: civen.chen@nokia-sbell.com
"""
import os
import re
import json
import requests
import logging
import Resources_Rjio.python.coam_gnb_classical as cgc
from datetime import datetime
from robot.api import TestData
from robot.libraries.BuiltIn import BuiltIn


__all__ = ["RobotCaseInfo", "selenium_coam"]


class RobotCaseInfo(object):
    """

    Step 1. get_execution_info
    Step 2. getTestPath
    Step 3. report_alarm
    """

    def __init__(self):
        self.build = None
        self.stream = None
        self.testline_name = None
        self.ute_cloud = None
        self.sw_version = None
        self.sg = None
        self.testlab = None
        self.testset = None
        self.case_name = None
        self.ue = None
        self.ru = None
        self.platform = None
        self.radio = None
        self.gnb_type = None
        self.gnb_mode = None
        self.update_qc = None
        self.alarm_data = {}
        self.traffic_data = {"tput": {}}
        self.scf_data = {}
        self.gnb_data = {}
        self.tp = {}
        self.duration = None
        self.use_nrdim = None

    def get_execution_info(self):
        buildin = BuiltIn()
        if buildin.get_variable_value(
            "${testline_name}"
        ) and buildin.get_variable_value("${AF_PATH}"):
            self.ute_cloud = False
            self.testline_name = buildin.get_variable_value("${testline_name}")
            self.build = buildin.get_variable_value("${AF_PATH}").split("/")[-2]
            if "sbts" in self.build.lower():
                if "_" not in self.build:
                    self.build = "_".join(
                        buildin.get_variable_value("${AF_PATH}")
                        .split("/")[-1]
                        .split("_")[:5]
                    )
                self.stream = self.build.split("_")[0]
            else:
                self.stream = ".".join(self.build.split(".")[:2])
            self.__get_sw_version_and_sg_from_db(self.build, self.testline_name)
            self.update_qc = buildin.get_variable_value("${uploadQC}")
            logging.info("Variable UploadQC type: {}".format(type(self.update_qc)))
        elif buildin.get_variable_value(
            "${CONFIGURATION}"
        ) and buildin.get_variable_value("${ENB_BUILD}"):
            self.ute_cloud = True
            self.testline_name = buildin.get_variable_value("${CONFIGURATION}").split(
                r"."
            )[-1]
            build = buildin.get_variable_value("${ENB_BUILD}")
            logging.info(
                "UTE CLOUD env, getting build and testline: {}, {}".format(
                    build, self.testline_name
                )
            )
            if "sbts" in build.lower():
                self.build = build
                self.stream = self.build.split("_")[0]
            else:
                self.build = build.split(r"_")[-1]
                self.stream = ".".join(self.build.split(".")[:2])
            self.__get_sw_version_and_sg_from_db(self.build, self.testline_name)
        else:
            self.ute_cloud = "Manual"
        self.use_nrdim = buildin.get_variable_value("${use_nrdim}", False)
        return self.ute_cloud, self.testline_name, self.build

    def getTestPath(self, file_path, case_name):
        self.case_name = case_name
        if type(self.ute_cloud) is not bool:
            return self.testlab, self.testset
        gnb_sw = self.sw_version.split(";")[0]
        qcFiles = []
        robotPath = re.findall(r"(.+)/\S+\.robot", file_path)[0]
        for i in os.listdir(robotPath):
            if re.match(r".*\.qc$", i):
                qcFiles.append(robotPath + "/" + i)
        logging.info(qcFiles)
        if not qcFiles:
            self.testlab = "NOQCFILE"
            self.testset = "NOQCFILE"
            return self.testlab, self.testset
        for i in qcFiles:
            logging.info("Analyzing QC file: {}".format(i))
            if self.ute_cloud:
                ret = self.__read_ute_qc(i, gnb_sw, file_path)
            else:
                ret = self.__read_local_qc(i, gnb_sw)
            if ret:
                self.testlab = ret[0]
                self.testset = ret[1]
                break
        else:
            self.testlab = "NOQCFILE"
            self.testset = "NOQCFILE"

    def get_technology_cells_mapping(
        self, cell_mapping, technology_cells_dict, technology="TDD"
    ):
        tdd_cell_mapping = {}
        for cell_id in technology_cells_dict[technology]:
            tdd_cell_mapping[cell_id] = cell_mapping[cell_id]
            tdd_cell_mapping[cell_id]["technology"] = technology
        return tdd_cell_mapping

    def add_alarm_report_data(self, alarms, history):
        self.alarm_data.update(
            {
                "Active Unexpected Alarm": alarms[2],
                "History Unexpected Alarm": history[2],
                "Active allowed Alarm": alarms[0],
                "History allowed Alarm": history[0],
                "Case Allowed Alarm": alarms[1] + history[1],
            }
        )

    # cell_info_list: ["cell_id": *, "frame_structure": *, "bandwidth"*]
    def add_scf_data(self, cell_info_list, lte_cell_info_list):
        self.scf_data.update({"cell_info_list": cell_info_list + lte_cell_info_list})

    def add_gnb_data(self, beamforming_status):
        self.gnb_data.update({"beamforming_status": beamforming_status})

    def add_throughput_duration(self, duration, ignore_time):
        if str(duration).replace(".", "", 1).isdigit():
            duration = "{}s".format(duration)
        if str(ignore_time).replace(".", "", 1).isdigit():
            ignore_time = "{}s".format(ignore_time)
        self.duration = "{ignore}+{duration}+{ignore}".format(
            ignore=ignore_time, duration=duration
        )

    def add_aasyslog_tp(
        self, cells, origin_tput, direction, target_tp, avg_percent, min_percent, ca
    ):
        if ca:
            self.__add_aasyslog_tp_data(
                ",".join([str(cell) for cell in cells]),
                origin_tput[0],
                direction,
                target_tp,
                avg_percent,
                min_percent,
            )
        else:
            for data in origin_tput:
                self.__add_aasyslog_tp_data(
                    str(data["cellid"]),
                    data,
                    direction,
                    target_tp,
                    avg_percent,
                    min_percent,
                )

    def __add_aasyslog_tp_data(
        self, cell, data, direction, target_tp, avg_percent, min_percent
    ):
        logging.info("Was: {}".format(self.tp))
        cell_id = cell
        avg_tp = data["average"]
        min_tp = data["minimum"]
        max_tp = data["peak"]
        if cell_id not in self.tp:
            self.tp[cell_id] = {}
        self.tp[cell_id][direction.lower()] = {
            "avg": avg_tp,
            "min": min_tp,
            "max": max_tp,
            "target": target_tp,
            "avg_percent": avg_percent,
            "min_percent": min_percent,
        }
        logging.info("Now: {}".format(self.tp))

    def add_sigspark_tp(
        self, cell, tput, direction, target_tp, avg_percent, min_percent
    ):
        logging.info("Was: {}".format(self.tp))
        if type(cell) is list:
            cell = cell[0]
        if cell not in self.tp:
            self.tp[cell] = {}
        self.tp[cell][direction.lower()] = {
            "avg": tput,
            "min": tput,
            "max": tput,
            "target": target_tp,
            "avg_percent": avg_percent,
            "min_percent": min_percent,
        }
        logging.info("Now: {}".format(self.tp))

    def add_iperf_tp(
        self,
        cell,
        avg_tput,
        min_tput,
        max_tput,
        direction,
        target_tp,
        avg_percent,
        min_percent,
    ):
        logging.info("Was: {}".format(self.tp))
        if type(cell) is list:
            cell = ",".join([str(i) for i in cell])
        if cell not in self.tp:
            self.tp[cell] = {}
        self.tp[cell][direction.lower()] = {
            "avg": avg_tput,
            "min": min_tput,
            "max": max_tput,
            "target": target_tp,
            "avg_percent": avg_percent,
            "min_percent": min_percent,
        }
        logging.info("Now: {}".format(self.tp))

    def add_traffic_report_data(
        self, cell_id, traffic_data, frame_structure, bandwidth
    ):
        self.traffic_data["tput"].update(
            {
                cell_id: {
                    "DL Tput": traffic_data["real_dl_tput"],
                    "DL Tput Thero": traffic_data["theory_dl_peak"],
                    "DL percent": traffic_data["real_dl_percent"],
                    "UL Tput": traffic_data["real_ul_tput"],
                    "UL Tput Thero": traffic_data["theory_ul_peak"],
                    "UL percent": traffic_data["real_ul_percent"],
                    "expect percent expect": traffic_data["acceptable_tput_percentage"],
                    "DL": "{real}/{theory}={percent}".format(
                        real=traffic_data["real_dl_tput"],
                        theory=traffic_data["theory_dl_peak"],
                        percent=traffic_data["real_dl_percent"],
                    ),
                    "UL": "{real}/{theory}={percent}".format(
                        real=traffic_data["real_ul_tput"],
                        theory=traffic_data["theory_ul_peak"],
                        percent=traffic_data["real_ul_percent"],
                    ),
                }
            }
        )
        if bandwidth:
            bandwidth = "{}MHz".format(bandwidth)
        self.traffic_data.update(
            {
                "frame_structure": frame_structure,
                "bandwidth": bandwidth,
            }
        )

    @property
    def tps(self):
        logging.info("Translating TP: {}".format(self.tp))
        output = []
        for cell_id in self.tp:
            new_data = {"cell_id": cell_id}
            if "ul" in self.tp[cell_id]:
                ul_data = self.tp[cell_id]["ul"]
                avg_real_percent = "{}%".format(
                    round(float(ul_data["avg"]) / float(ul_data["target"]) * 100, 2)
                )
                min_real_percent = "{}%".format(
                    round(float(ul_data["min"]) / float(ul_data["target"]) * 100, 2)
                )
                avg_exp_percent = self.__str_percent(ul_data["avg_percent"])
                min_exp_percent = self.__str_percent(ul_data["min_percent"])
                new_data["UL"] = "{}/{}={}{}{}".format(
                    self.__translate_throughput_for_log(ul_data["avg"]),
                    self.__translate_throughput_for_log(ul_data["target"]),
                    avg_real_percent,
                    self.__compare_result(
                        self._translate_percentage(avg_real_percent),
                        self._translate_percentage(avg_exp_percent),
                    ),
                    avg_exp_percent,
                )
                new_data["UL_MIN"] = "{}/{}={}{}{}".format(
                    self.__translate_throughput_for_log(ul_data["min"]),
                    self.__translate_throughput_for_log(ul_data["target"]),
                    min_real_percent,
                    self.__compare_result(
                        self._translate_percentage(min_real_percent),
                        self._translate_percentage(min_exp_percent),
                    ),
                    min_exp_percent,
                )
                new_data["acceptable_percentage"] = "AVG: {} | MIN: {}".format(
                    self.__str_percent(ul_data["avg_percent"]),
                    self.__str_percent(ul_data["min_percent"]),
                )
            if "dl" in self.tp[cell_id]:
                dl_data = self.tp[cell_id]["dl"]
                avg_real_percent = "{}%".format(
                    round(float(dl_data["avg"]) / float(dl_data["target"]) * 100, 2)
                )
                min_real_percent = "{}%".format(
                    round(float(dl_data["min"]) / float(dl_data["target"]) * 100, 2)
                )
                avg_exp_percent = self.__str_percent(dl_data["avg_percent"])
                min_exp_percent = self.__str_percent(dl_data["min_percent"])
                new_data["DL"] = "{}/{}={}{}{}".format(
                    self.__translate_throughput_for_log(dl_data["avg"]),
                    self.__translate_throughput_for_log(dl_data["target"]),
                    avg_real_percent,
                    self.__compare_result(
                        self._translate_percentage(avg_real_percent),
                        self._translate_percentage(avg_exp_percent),
                    ),
                    avg_exp_percent,
                )
                new_data["DL_MIN"] = "{}/{}={}{}{}".format(
                    self.__translate_throughput_for_log(dl_data["min"]),
                    self.__translate_throughput_for_log(dl_data["target"]),
                    min_real_percent,
                    self.__compare_result(
                        self._translate_percentage(min_real_percent),
                        self._translate_percentage(min_exp_percent),
                    ),
                    min_exp_percent,
                )
                new_data["acceptable_percentage"] = "AVG: {} | MIN: {}".format(
                    self.__str_percent(dl_data["avg_percent"]),
                    self.__str_percent(dl_data["min_percent"]),
                )
            output.append(new_data)
        logging.info("Output: {}".format(output))
        return output

    @staticmethod
    def __translate_throughput_for_log(tput):
        if float(tput) < 50:
            return str(round(float(tput), 2))
        elif float(tput) < 100:
            return str(round(float(tput), 1))
        else:
            return str(int(float(tput)))

    @staticmethod
    def __compare_result(real, exp):
        if real > exp:
            return ">"
        elif real < exp:
            return "<"
        else:
            return "="

    @staticmethod
    def __str_percent(origin_percent):
        percent = str(origin_percent)
        if "%" not in percent:
            percent = "{}%".format(int(float(percent) * 100))
        return percent

    @staticmethod
    def _translate_percentage(origin_percent):
        percent = str(origin_percent)
        if "%" in percent:
            target_percent = float(percent.replace("%", "")) / 100.0
        else:
            target_percent = float(percent)
        return target_percent

    def report(self, ta_status, ru_power, case_name=None):
        data = {
            "Squad Team": self.sg,
            "Testline Name": self.testline_name,
            "Test Lab": self.testlab,
            "Test Set": self.testset,
            "Case Name": case_name or self.case_name,
            "Build": self.build,
            "Stream": self.stream,
            "TA status": ta_status,
            "TA execute Time": str(datetime.now()).split(".")[0],
            "UTE cloud": self.ute_cloud,
            "ue": self.ue,
            "ru": self.ru,
            "platform": self.platform,
            "radio": self.radio,
            "gnb_type": self.gnb_type,
            "gnb_mode": self.gnb_mode,
            "ru_power": ru_power,
            "use_nrdim": self.use_nrdim,
        }
        data.update(self.alarm_data)
        data.update(self.gnb_data)
        if self.traffic_data["tput"]:
            data.update(self.traffic_data)
        else:
            data.update(self.scf_data)
        if self.tp:
            data["TP"] = self.tps
        if self.duration:
            data["tput_duration"] = self.duration
        logging.info("Data: {}".format(data))
        if type(self.ute_cloud) is not bool:
            logging.info("Manual testing, Data will not uploaded")
        # elif self.testlab == "NOQCFILE":
        #     logging.error("Can't match QC file. Not to upload data.")
        elif self.ute_cloud:
            self.report_via_restapi(
                url="http://10.57.169.251:8001/alarm_info", data=data
            )
        else:
            if self.update_qc is True or self.update_qc == "true":
                self.report_via_restapi(
                    url="http://10.57.169.251:8001/alarm_info", data=data
                )
            else:
                logging.info("Local CIT didn't choose upload QC, will not upload data.")

    @staticmethod
    def report_via_restapi(url, data):
        headers = {"Content-Type": "application/json"}
        res = requests.post(
            url=url,
            headers=headers,
            data=json.dumps(data),
        )
        logging.info("Data uploaded and get respond {res}".format(res=res.status_code))

    def __get_sw_version_and_sg_from_db(self, build, testline_name):
        try:
            data = {"sw_version": build, "testline": testline_name}
            headers = {"Content-Type": "application/json"}
            res = requests.post(
                url="http://10.57.169.251:8001/taf",
                headers=headers,
                data=json.dumps(data),
            )
            respond = json.loads(res.text)
            logging.info("REST respond: {}".format(respond))
            self.sw_version = respond["stream"]
            self.sg = respond["sg"]
            self.ue = respond["ue"]
            self.ru = respond["ru"]
            self.platform = respond["boards"]
            self.radio = respond["radio"]
            self.gnb_type = respond["duplex"]
            self.gnb_mode = respond["deploy"]
            logging.info(
                (
                    "Get sw_version:{}, SG:{}, UE:{}, "
                    "RU:{}, TYPE:{}, MODE:{}, PLATFORM: {}, RADIO:{} "
                    "from DB via RESTAPI"
                ).format(
                    self.sw_version,
                    self.sg,
                    self.ue,
                    self.ru,
                    self.gnb_type,
                    self.gnb_mode,
                    self.platform,
                    self.radio,
                )
            )
        except Exception as err:
            logging.exception(err)

    def __read_local_qc(self, qc_file, gnb_sw):
        trunk_match_dict = {
            "5G_PZ_HZ_1_SG": "RAN_PZ_HAZ_4_SG01",
            "5G_PZ_HZ_2_SG": "RAN_PZ_HAZ_4_SG02",
            "5G_PZ_HZ_3_SG": "RAN_PZ_HAZ_4_SG03",
            "5G_PZ_HZ_4_SG": "RAN_PZ_HAZ_4_SG04",
            "5G_PZ_HZ_5_SG": "RAN_PZ_HAZ_4_SG05",
            "5G_PZ_HZ_6_SG": "RAN_PZ_HAZ_4_SG06",
            "5G_PZ_HZ_7_SG": "RAN_PZ_HAZ_4_SG07",
            "5G_PZ_HZ_8_SG": "RAN_PZ_HAZ_4_SG08",
            "5G_PZ_MMW_HZ_1_SG": "RAN_PZ_HAZ_3_SG01",
            "5G_PZ_MMW_HZ_2_SG": "RAN_PZ_HAZ_3_SG02",
            "5G_PZ_MMW_HZ_3_SG": "RAN_PZ_HAZ_3_SG03",
            "5G_PZ_MMW_HZ_4_SG": "RAN_PZ_HAZ_3_SG04",
            "5G_PZ_MMW_HZ_5_SG": "RAN_PZ_HAZ_3_SG05",
        }
        if self.stream.lower() == "sbts00":
            sg_match = trunk_match_dict[self.sg]
        else:
            sg_match = self.sg
        with open(qc_file, "r") as f:
            qc_path = json.JSONDecoder(object_pairs_hook=parse_object_pairs).decode(
                f.read()
            )
            logging.info("Read QC file: {}".format(qc_path))
            for i in qc_path:
                stream = i[0]
                for key, value in i[1]:
                    if key == "label":
                        label = value
                    if "\\" in key:
                        testlab = key
                        testset = value[0][0]
                if re.findall(stream, gnb_sw) and re.findall(label, sg_match):
                    logging.info("Find matching: {}".format(i))
                    return testlab, testset
            else:
                return None, None

    def __read_ute_qc(self, qc_file, gnb_sw, file_path):
        testline_type = self.__get_all_tags(file_path)
        with open(qc_file, "r") as f:
            qc_path = json.JSONDecoder(object_pairs_hook=parse_object_pairs).decode(
                f.read()
            )
            logging.info("Read QC file: {}".format(qc_path))
            for i in qc_path:
                stream = i[0]
                for key, value in i[1]:
                    if key == "label":
                        label = value
                    if "\\" in key:
                        testlab = key
                        testset = value[0][0]
                if re.findall(stream, gnb_sw) and re.findall(label, testline_type):
                    logging.info("Find matching: {}".format(i))
                    return testlab, testset
            else:
                return None, None

    def __get_all_tags(self, file_path):
        suite = TestData(source=file_path)
        force_tags = suite.setting_table.force_tags.value
        for tag in force_tags:
            if "CLOUD_5G_" in tag:
                return tag
        cases = suite.testcase_table.tests
        for case in cases:
            if case.name == self.case_name:
                for tag in case.tags.value:
                    if "CLOUD_5G_" in tag:
                        return tag

    @staticmethod
    def __get_mapping_cell():
        output = {}
        mapping = cgc.get_relation_mapping_between_cell_index_and_nrCellIdentity()
        for cell_index in mapping:
            output[mapping[cell_index]["nrCellIdentity"]] = cell_index
        return output


def parse_object_pairs(pairs):
    return pairs


def use_sbts_selenium():
    build = BuiltIn().get_variable_value("${AF_PATH}") or BuiltIn().get_variable_value(
        "${ENB_BUILD}"
    )
    try:
        if build is None:
            print("Can't find AF_PATH or ENB_BUILD, defaultly treat as SBTS.")
            return True
        else:
            return True if "SBTS" in build.upper() else False
    except Exception as errprint:
        print(errprint)
        return False


if use_sbts_selenium():
    print("SBTS build, trying to import taf.selenium.sbts")
    from taf.selenium.sbts import sbts as selenium_coam
else:
    print("Not SBTS build, trying to import taf.selenium.gnb.oam.coam.classical")
    from taf.selenium.gnb.oam.coam.classical import classical as selenium_coam
