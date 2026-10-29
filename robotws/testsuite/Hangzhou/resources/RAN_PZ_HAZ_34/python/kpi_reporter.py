# -*- coding: utf-8 -*-
"""
:copyright: Nokia Networks
:author: Civen Chen
:contact: civen.chen@nokia-sbell.com
:maintainer: Civen Chen
:contact: civen.chen@nokia-sbell.com
"""
import copy
import logging
import os
import json
import requests
from robot.libraries.BuiltIn import BuiltIn
from ute_ue.utils.param_checker import tput_user_value2normalized
from taf.rfrl.common_resources.python.report_to_rep import RfKPI, ReportKPIWrapper


__all__ = ["KpiReporter"]


class KpiReporter(object):
    """
    Reporter Kpi data to RP

    Author: Civen Chen
    Contact: civen.chen@nokia-sbell.com

    USAGE EXAMPLE:
    =============================  IMPORT ===============================
    *** Settings ***
    Library    ute_reporting_portal
 testsuite.Hangzhou.resources.RAN_PZ_HAZ_34.python/kpi_reporter.py
    Library    kpi_reporter.KpiReporter    WITH NAME    KpiReporter

    It's an example, after imported you can use KpiReporter.xxxxxxx to call all the functions.
    Please execute robot command with `-P` during local testing as CIT/CRT/UTE_CLOUD do.
    E.G  robot -P ~/Project/robotws5g your_case.robot

    [WARNING]
    Following add report list keywrod should be used with units,
    Validate units:
    - 'bits/sec'
    - 'Kbits/sec'
    - 'Mbits/sec'
    - 'Gbits/sec'
    - 'Bytes/sec'
    - 'KBytes/sec'
    - 'MBytes/sec'
    - 'GBytes/sec'
    eg. '100 MBytes/sec'

    ============================= DL ONLY ================================
    DL TPUT Teardown
        KpiReporter.add_dl_throughput_into_report_list    exp_dl=${exp_dl}
        ...                                               dl_avg=${dl_avg}
        ...                                               dl_max=${dl_max}
        ...                                               dl_min=${dl_min}
        KpiReporter.report_tput_kpi    protocol=${protocol}    deviation=${deviation}    logs_dir=${logs_dir}

    ============================= UL ONLY ================================
    UL TPUT Teardown
        KpiReporter.add_ul_throughput_into_report_list    exp_ul=${exp_ul}
        ...                                               ul_avg=${ul_avg}
        ...                                               ul_max=${ul_max}
        ...                                               ul_min=${ul_min}
        KpiReporter.report_tput_kpi    protocol=${protocol}    deviation=${deviation}    logs_dir=${logs_dir}

    ============================= UL & DL ================================
    BOTH TPUT Teardown
        KpiReporter.add_dl_throughput_into_report_list    exp_dl=${exp_dl}
        ...                                               dl_avg=${dl_avg}
        ...                                               dl_max=${dl_max}
        ...                                               dl_min=${dl_min}
        KpiReporter.add_ul_throughput_into_report_list    exp_ul=${exp_ul}
        ...                                               ul_avg=${ul_avg}
        ...                                               ul_max=${ul_max}
        ...                                               ul_min=${ul_min}
        KpiReporter.report_tput_kpi    protocol=${protocol}    deviation=${deviation}    logs_dir=${logs_dir}

    """
    def __init__(self):
        self.exp_dl = None
        self.dl_avg = None
        self.dl_max = None
        self.dl_min = None

        self.exp_ul = None
        self.ul_avg = None
        self.ul_max = None
        self.ul_min = None

    def add_dl_throughput_into_report_list(self, exp_dl, dl_avg, dl_min, dl_max):
        """
        Add DL throughput data into report list, should be executed before `report tput kpi` was call.
        :param exp_dl:  Expected DL throughput, equal to theory DL throughput
        :param dl_avg:  Average DL throughput
        :param dl_min:  Minimal DL throughput
        :param dl_max:  Maximum DL throughput
        :return:
        """
        if self.exp_dl is None:
            self.exp_dl = exp_dl
            self.dl_avg = dl_avg
            self.dl_max = dl_max
            self.dl_min = dl_min
        else:
            raise ValueError("DL throughput data already added")

    def add_ul_throughput_into_report_list(self, exp_ul, ul_avg, ul_min, ul_max):
        """
        Add UL throughput data into report list, should be executed before `report tput kpi` was call.
        :param exp_ul:  Expected UL throughput, equal to theory UL throughput
        :param ul_avg:  Average UL throughput
        :param ul_min:  Minimal UL throughput
        :param ul_max:  Maximum UL throughput
        :return:
        """
        if self.exp_ul is None:
            self.exp_ul = exp_ul
            self.ul_avg = ul_avg
            self.ul_max = ul_max
            self.ul_min = ul_min
        else:
            raise ValueError("UL throughput data already added")

    def report_tput_kpi(self, protocol, deviation="0%", logs_dir=None):
        """
        Report most important Tput KPIs to Reporting Portal.
        :param protocol: UDP/TCP
        :param deviation: in % - Needs to calculate target
        :param logs_dir: path to logs collected during data transfer eg BIP
        :return: None
        """
        # Generate Manual Posting File if needed.
        try:
            mp = ManualPostGenerator()
            mp.generate_manual_posting_file_when_case_fail()
        except Exception as errprint:
            logging.info("Generate Manual Posting failed: {}".format(errprint))

        if self.exp_dl and self.exp_ul:
            direction = "BOTH"
        elif self.exp_dl:
            direction = "DL"
        elif self.exp_ul:
            direction = "UL"
        else:
            raise ValueError(
                "At least execute one of "
                "`KpiReporter.add_dl_throughput_into_report_list` `KpiReporter.add_ul_throughput_into_report_list` "
                "to add throughput data before report."
            )
        logging.info(
            "Reporting direction {direction} data to RP".format(direction=direction)
        )

        # report TPUT and RF to RP.
        TputCustomizedKPI().report_tput_results_to_reporting_portal(
            protocol=protocol,
            dl_avg=self.dl_avg,
            ul_avg=self.ul_avg,
            dl_max=self.dl_max,
            ul_max=self.ul_max,
            dl_min=self.dl_min,
            ul_min=self.ul_min,
            exp_dl=self.exp_dl,
            exp_ul=self.exp_ul,
            deviation=deviation,
        )
        RfKPI().report_rf_kpi_to_reporting_portal(
            protocol=protocol, direction=direction, pcap_dir=logs_dir
        )

        # Reset report list after reported
        self.clear_report_list()

    def clear_report_list(self):
        self.exp_dl = None
        self.dl_avg = None
        self.dl_max = None
        self.dl_min = None

        self.exp_ul = None
        self.ul_avg = None
        self.ul_max = None
        self.ul_min = None


class TputCustomizedKPI(ReportKPIWrapper):
    """
    Class for reporting throughput KPIs.
    """

    def report_tput_results_to_reporting_portal(
        self,
        protocol,
        dl_avg=None,
        ul_avg=None,
        dl_max=None,
        ul_max=None,
        dl_min=None,
        ul_min=None,
        exp_dl=None,
        exp_ul=None,
        deviation="0%",
    ):
        """
        Report set of Tput KPIs to Reporting Portal
        :param protocol: UDP/TCP
        :param dl_avg:  Average DL throughput
        :param ul_avg:  Average uL throughput
        :param dl_max:  Maximum DL throughput
        :param ul_max:  Maximum UL throughput
        :param dl_min:  Minimal DL throughput
        :param ul_min:  Minimal UL throughput
        :param exp_dl:  Expected DL throughput, equal to theory DL throughput
        :param exp_ul:  Expected UL throughput, equal to theory UL throughput
        :param deviation: in % - Needs to calculate target
        :return:
        """
        self._add_tput_kpi(
            protocol=protocol,
            dl_avg=dl_avg,
            ul_avg=ul_avg,
            dl_max=dl_max,
            ul_max=ul_max,
            dl_min=dl_min,
            ul_min=ul_min,
            exp_dl=exp_dl,
            exp_ul=exp_ul,
            deviation=deviation,
        )
        self.report_all_kpi_results()

    def _add_tput_kpi(
        self,
        protocol,
        dl_avg=None,
        ul_avg=None,
        dl_max=None,
        ul_max=None,
        dl_min=None,
        ul_min=None,
        exp_dl=None,
        exp_ul=None,
        deviation="0%",
    ):
        """
        Report set of Tput KPIs to Reporting Portal
        :param protocol: UDP/TCP
        :param dl_avg:  Average DL throughput
        :param ul_avg:  Average uL throughput
        :param dl_max:  Maximum DL throughput
        :param ul_max:  Maximum UL throughput
        :param dl_min:  Minimal DL throughput
        :param ul_min:  Minimal UL throughput
        :param exp_dl:  Expected DL throughput, equal to theory DL throughput
        :param exp_ul:  Expected UL throughput, equal to theory UL throughput
        :param deviation: in % - Needs to calculate target
        :return:
        """
        if not exp_dl and not exp_ul:
            raise ValueError("One of parameter 'tput_dl' or 'tput_ul' must be defined")

        if exp_dl:
            self._add_set_tput_params(
                tput_avg=dl_avg,
                tput_min=dl_min,
                tput_max=dl_max,
                protocol=protocol,
                direction="DL",
                tput_exp=exp_dl,
                deviation=deviation,
            )
        if exp_ul:
            self._add_set_tput_params(
                tput_avg=ul_avg,
                tput_min=ul_min,
                tput_max=ul_max,
                protocol=protocol,
                direction="UL",
                tput_exp=exp_ul,
                deviation=deviation,
            )

    def _add_set_tput_params(
        self, tput_avg, tput_min, tput_max, protocol, direction, tput_exp, deviation
    ):
        tput_avg = tput_user_value2normalized(tput_avg) * 1000
        tput_min = tput_user_value2normalized(tput_min) * 1000
        tput_max = tput_user_value2normalized(tput_max) * 1000
        avg_target = self._calculate_target(tput_exp, deviation)
        base_name = "{}_{}_tput".format(direction.lower(), protocol.lower())
        base_description = "{} {} throughput".format(
            direction.upper(), protocol.upper()
        )
        common_tput_kpi_params = {
            "name": "",
            "value": "",
            "target": "",
            "description": "",
            "visible_to_db": "true",
            "kpi_type": "Throughput",
            "category": "Performance",
            "unit": "bits/sec",
        }

        specific_tput_params = {
            "AVG": {
                "name": "avg_{}".format(base_name),
                "description": "Average {}".format(base_description),
                "value": str(tput_avg),
                "target": str(avg_target),
            },
            "MIN": {
                "name": "min_{}".format(base_name),
                "description": "Minimum {}".format(base_description),
                "value": str(tput_min),
                "target": "",
            },
            "MAX": {
                "name": "max_{}".format(base_name),
                "description": "Maximum {}".format(base_description),
                "value": str(tput_max),
                "target": "",
            },
        }
        for param in specific_tput_params:
            tput_params = copy.deepcopy(common_tput_kpi_params)
            tput_params.update(specific_tput_params[param])
            self.add_kpi(params=tput_params)

    @staticmethod
    def _calculate_target(tput, deviation):
        def _parse_deviation(dev):
            number = dev.rstrip('%')
            return float(number) / 100.0

        deviation_as_float = _parse_deviation(deviation)
        normalized_tput = tput_user_value2normalized(tput)
        target = normalized_tput - (normalized_tput * deviation_as_float)

        return target


class ManualPostGenerator(object):
    def __init__(self):
        buildin = BuiltIn()
        self.test_status = buildin.get_variable_value("${TEST STATUS}")
        self.test_name = buildin.get_variable_value("${TEST NAME}")
        self.output_dir = buildin.get_variable_value("${OUTPUT DIR}")
        if buildin.get_variable_value("${testline_name}") and buildin.get_variable_value("${AF_PATH}"):
            self.ute_cloud = False
            self.testline_name = buildin.get_variable_value("${testline_name}")
            self.build = buildin.get_variable_value("${AF_PATH}").split("/")[-2]
            self.stream = ".".join(self.build.split(".")[:2])
            self.__get_sw_version_and_sg_from_db(self.build, self.testline_name)
        elif buildin.get_variable_value("${CONFIGURATION}") and buildin.get_variable_value("${ENB_BUILD}"):
            self.ute_cloud = True
            self.testline_name = buildin.get_variable_value("${CONFIGURATION}").split(r".")[-1]
            self.build = buildin.get_variable_value("${ENB_BUILD}").split(r"_")[-1]
            self.stream = ".".join(self.build.split(".")[:2])
            self.__get_sw_version_and_sg_from_db(self.build, self.testline_name)
        else:
            self.ute_cloud = "Manual"

    def generate_manual_posting_file_when_case_fail(self):
        if self.test_status.lower() == "fail":
            self.generate_manual_posting_file()

    def generate_manual_posting_file(self):
        output_dir = os.path.join(self.output_dir, "spotlight_manual_posting")
        if not os.path.exists(output_dir):
            os.mkdir(output_dir)
        output = os.path.join(output_dir, "{}.py".format(self.test_name))

        with open(output, "w") as f:
            data = self.template.format(test_name=self.test_name,
                                        platform=",".join(self.platform),
                                        tl="5G_Hangzhou_" + self.testline_name.split("_")[-1],
                                        sw_version=self.sw_version)
            f.write(data)

    @property
    def template(self):
        return """import pymongo
import datetime

collection_name = "KPI"
data = {{
    "product": ,  # string,       required
    "platform": "{platform}",                     # string,       required
    "test_line": "{tl}",   # string,       required
    "hw_id": ,                             # string,       required
    "cc_dl": ,                                   # integer/None,
    "cc_ul": ,                                   # integer/None
    "build": "{sw_version}",                  # string,       required
    "target": ,                         # float, in bits/s       required
    "value": ,                       # float, in bits/s       required
    "end": datetime.datetime.now(),               # datetime,     required
    "Test_Run_pronto": {{                          # dict,         required
        "pronto": None                            # string/None,  required
    }},
    "comment": "manual rerun",                    # string/None
    "test_case": {{                                # dict,         required
        "name": "{test_name}"  # string,       required
    }},
    "kpi": {{                                      # dict,         required
        "name": "avg_dl_tcp_tput"                 # string,       required
    }}
}}

con = pymongo.MongoClient(
    host="PLKR-SC5G-PBI.sc5g.krk-lab.nsn-rdnet.net",
    username="PowerBI_public_user",
    password="InsertOnly!")
try:
    x = con["PowerBI_public"][collection_name].insert_one(data)
    print("Inserted: " + str(data))
except Exception as e:
    print(str(e) + "\\n")
    validation = con["PowerBI_public"].command({{'listCollections': 1, 'filter': {{'name': collection_name}}}})
    for x in validation.get("cursor", {{}}).get("firstBatch", []):
        mandatory = x.get("options", {{}}).get("validator", {{}}).get("$jsonSchema", {{}}).get("required", [])
        print("required fields: " + ", ".join(mandatory) + "\\n")
        for k, v in x.get("options", {{}}).get("validator", {{}}).get("$jsonSchema", {{}}).get("properties",
                                                                                               {{}}).items():
            print(k + ": " + str(v))"""

    def __get_sw_version_and_sg_from_db(self, build, testline_name):
        data = {
            'sw_version': build,
            'testline': testline_name
        }
        headers = {'Content-Type': 'application/json'}
        res = requests.post(url='http://10.57.169.251:8001/taf', headers=headers, data=json.dumps(data))
        respond = json.loads(res.text)
        print("REST respond: {}".format(respond))
        self.sw_version = respond["stream"]
        self.sg = respond["sg"]
        self.ue = respond["ue"]
        self.ru = respond["ru"]
        self.platform = respond["boards"]
        self.radio = respond["radio"]
        self.gnb_type = respond["duplex"]
        self.gnb_mode = respond["deploy"]
        print(("Get "
               "sw_version:{}, SG:{}, UE:{}, RU:{}, TYPE:{}, MODE:{}, PLATFORM: {}, RADIO:{}"
               " from DB via RESTAPI").format(
            self.sw_version,
            self.sg,
            self.ue,
            self.ru,
            self.gnb_type,
            self.gnb_mode,
            self.platform,
            self.radio
        ))
