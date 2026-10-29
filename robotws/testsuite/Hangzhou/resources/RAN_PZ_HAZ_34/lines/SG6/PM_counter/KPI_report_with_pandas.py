# -*- coding: utf-8 -*-
"""
:copyright: Nokia Networks
:author: Lei Jia
:contact: lei.jia@nokia-sbell.com
"""
import base64
import json
import os.path
import re
import gzip
from stat import S_ISDIR
from datetime import datetime, timedelta
import openpyxl
from openpyxl.styles import Border, Side, PatternFill, Alignment, Font
import os
import glob
import logging
from set_pandas import *
import time
import paramiko
import tempfile
import requests
import yaml
from collections import OrderedDict
from openpyxl import load_workbook
import math
import shutil
import tarfile
import testsuite.Hangzhou.resources.RAN_PZ_HAZ_34.python.coam_parameter as coam_parameter

pd = None
np = None
plt = None


tl = BuiltIn().get_variable_value("${tl}")

REPRODUCE_KPI_NAME_LIST = [
    "NR_5057e",
    "SCOUT_NR_1418",
    "SCOUT_NR_1419a",
    "M55124C03006",
    "M55125C09029",
    "M55124C00505",
    "M55351C00001",
    "M55351C00002",
    "M55124C03001",
    "M55124C03002",
    "M55118C07003",
    "M55125C09005",
    "M55118C07004",
    "M55129C00004",
    "M55129C00003",
    "NR_5108e",
    "M55150C00035",
    "M55349C06000",
    "M55349C06001",
    "M55349C06002",
    "M55349C06003",
    "M55349C06004",
    "M55349C06005",
    "M55349C06006",
    "M55349C06007",
    "M55349C06008",
    "M55349C06009",
    "M55349C06010",
    "M55118C10005",
]

BOOLEAN_PARMS = [
    "actInitialBWPFlexibility",
    "actLAForHiReliab",
    "actPdcchCceFragmentControl",
    "actPowerSavingBWP",
    "actPRBBlanking",
    "actULSchedInactiveBwp",
    "actUpperThrAckNackFiltering",
    "actUpperThrAckNackFiltering",
    "trsMutingInBlankedPRBsEnabled",
]

SYSLOG_ERR_WHITE_LIST = [
    "LFS LogListener ERR/LFS/LinuxSyslog, dhcpd: DHCPDISCOVER",
    "Ne3sAdapter ne3sadapter-asy ERR/Ne3sAdapter/Coma",
    "ERR/CCS/AaTestPortClient, completeTlsHandShake()",
]

RF_ERR_WHITE_LIST = []

# Global dictionary for KPI ID to Name mapping
KPI_ID_NAME_MAPPING = {
    "00007": "KPI#2b - Inter-release SW activation downtime with firmware update",
    "00060": "KPI#2k - Inter-release SW activation",
    "00061": "KPI#4a - Complete BTS SW upgrade",
    "00062": "KPI#4b - Complete BTS SW upgrade",
    "02001": "Software Download Duration",
    "02002": "Software Provision Duration",
    "00015": "KPI#5 - Manual capacity module reset downtime",
    "00008": "KPI#2c - Intra-release SW activation downtime without firmware update",
    "00001": "KPI#1a - Manual site reset downtime",
    "00002": "KPI#1b - Manual site reset downtime",
    "00003": "KPI#1c - Manual site reset downtime",
    "00064": "KPI#13b - Manual SW rollback downtime",
}


class DownloadKpiFile:
    def __init__(
        self,
        compass_url="http://compass.dyn.nesc.nokia.net:8080/kpi/generate_kpi_report/",
        compare_url="http://compass.dyn.nesc.nokia.net:8080/kpi/scout_comparator_report/"
        "generate_comparator_report/",
        combine_report_url="http://compass.dyn.nesc.nokia.net:8080/kpi/combine_kpi_report/",
        analysis_report_url="http://compass.dyn.nesc.nokia.net:8080/kpi/analysis_kpi_report/",
        compass_login_url="http://compass.dyn.nesc.nokia.net:8080/common/login_handle/",
        horizontal_merge_url="http://compass.dyn.nesc.nokia.net:8080/kpi/horizontal_merge_reports/",
    ):
        self.compass_login_url = compass_login_url
        self.compass_generate_kpi_report_url = compass_url
        self.compass_generate_comparator_report_url = compare_url
        self.combine_kpi_report_url = combine_report_url
        self.horizontal_merge_reports_url = horizontal_merge_url
        self.analysis_kpi_report_url = analysis_report_url
        self.common_user_agent = (
            "Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) "
            "Chrome/120.0.0.0 Safari/537.36"
        )

    @staticmethod
    def get_time():
        """
        Get the current time.
        :return: the current time
        """
        return time.strftime("%Y-%m-%d %H:%M", time.localtime())

    @staticmethod
    def get_parameter_info(file_path):
        """
        Get the parameters from the yaml file.
        FYI: testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/lines/SG3/kpi_report_releated_parameters.yml
        :param file_path: the path of the yaml file
        :return: the data in the yaml file
        """
        with open(file_path, "r") as f:
            data = yaml.safe_load(f)
        return data

    def generate_new_report(
        self,
        report_name,
        tl_id,
        package_version,
        template_name,
        start_time,
        end_time,
        comments="",
        check_out_entry="true",
    ):
        """
        Generate a new report on Compass.
        :param report_name: the name of the report
        :param tl_id: the test line id e.g. 335
        :param package_version: the package version
        :param template_name: the template name
        :param start_time: the start time of the report
        :param end_time: the end time of the report
        :param comments: the comments of the report
        :param check_out_entry: the check out entry value "true" or "false", so that to generate chart
        :return: the report id
        """
        session = requests.session()
        res = session.post(
            url=self.compass_login_url,
            data={
                "username": base64.b64decode(b"c3RsaW4=").decode("utf-8"),
                "password": base64.b64decode(b"TWF5ZGF5NTU1MzU5QA==").decode("utf-8"),
            },
            verify=False,
        )
        session.headers["cookie"] = res.headers.get("Set-Cookie").split(
            sep=";", maxsplit=1
        )[0]
        # headers = {
        #     'cookie': "name=m1shi; sessionid=kwm3keqgqn9if8bc1io1wm5g2rlom9el"
        # }
        data = {
            "report_name": report_name,
            "test_line": f"{tl_id}",
            "package_version": package_version,
            "template_name": template_name,
            "start_time": start_time,
            "end_time": end_time,
            "comments": comments,
            "check_out_entry": str(check_out_entry),
        }
        logging.debug("data is {}".format(data))
        """
        resp.json()
        {"success": true, "error": "", "data": {"id": "68722", "name": "test_2024-06-21T06:13:18.993134",
        "package": "2.0", "start_time": "2024-06-19 16:29:00", "end_time": "2024-06-20 17:00:00",
        "kpi_template_id": "1698", "comments": "test1", "kpi_template__name": "CHZ_SG3_TMO_SA_KPI",
        "testlines": "7_5_UTE5G402T335", "testline_ids": "TL_5085"}}
        with requests.post(url=self.compass_generate_kpi_report_url, headers=headers, data=data) as resp:
        """
        for i in range(5):
            try:
                with session.post(
                    url=self.compass_generate_kpi_report_url, data=data
                ) as resp:
                    logging.debug("resp is {}".format(resp.json()))
                    if str(resp.json()["success"]) == "True":
                        print("Generate new report successfully.")
                        kpi_report_id = resp.json()["data"]["id"]
                        return kpi_report_id
                    elif str(resp.json()["success"]) == "false":
                        print(
                            f"Failed to generate new report. error reason: {resp.json()['error']}"
                        )
                        return None
            except Exception as e:
                print("Connection refused by the server..")
                time.sleep(15)
                print("Was a nice sleep, now let me continue...")
        return kpi_report_id

    def generate_comparator_report(
        self,
        test_line_id,
        test_line_name,
        report_name,
        template_names_list,
        template_id_list,
        first_description,
        first_start_time,
        first_end_time,
        second_description,
        second_start_time,
        second_end_time,
        alpha_factor=0.05,
        comments=" ",
    ):
        """
        Generate a new report on Compass.
        :param report_name: the name of the report
        :param tl_id: the test line id e.g. 335
        :param package_version: the package version
        :param template_name: the template name
        :param start_time: the start time of the report
        :param end_time: the end time of the report
        :param comments: the comments of the report
        :param check_out_entry: the check out entry value "true" or "false", so that to generate chart
        :return: the report id
        """
        headers = {"cookie": f"name=m1shi; sessionid=kwm3keqgqn9if8bc1io1wm5g2rlom9el"}
        data = {
            "test_line_id": test_line_id,
            "test_line_name": test_line_name,
            "report_name": report_name,
            "template_names": template_names_list,
            "template_id_list": template_id_list,
            "first_period_description": first_description,
            "first_start_time": first_start_time,
            "first_end_time": first_end_time,
            "second_period_description": second_description,
            "second_start_time": second_start_time,
            "second_end_time": second_end_time,
            "alpha": float(alpha_factor),
            "comments": comments,
        }
        for i in range(5):
            try:
                resp = requests.post(
                    url=self.compass_generate_comparator_report_url,
                    headers=headers,
                    data=data,
                )
                if resp.status_code == 200:
                    logging.debug("resp for report id is {}".format(resp.json()))
                    if str(resp.json()["success"]) == "True":
                        print("Generate kpi report successfully.")
                        kpi_report_id = int(resp.json()["data"]["comparator_report_id"])
                        break
                    elif str(resp.json()["success"]) == "false":
                        print(
                            f"Failed to generate new comparator report. error reason: {resp.json()['error']}"
                        )
                        time.sleep(30)
                        logging.debug(
                            "wait for 30sec for try to generate kpi report again"
                        )
                        kpi_report_id = None
            except Exception as e:
                print("Connection refused by the server..")
                time.sleep(15)
                print("Was a nice sleep, now let me continue...")
        return kpi_report_id

    def combine_kpi_report(self, report_id_list):
        """ """
        # report_id_list = [str(x) for x in report_id_list]
        # report_id_list = "[" + ",".join(['"' + x + '"' for x in report_id_list]) + "]"
        # logging.debug("report_id_list is {}".format(report_id_list))
        session = requests.session()
        res = session.post(
            url=self.compass_login_url,
            data={
                "username": base64.b64decode(b"c3RsaW4=").decode("utf-8"),
                "password": base64.b64decode(b"TWF5ZGF5NTU1MzU5QA==").decode("utf-8"),
            },
            verify=False,
        )
        session.headers["cookie"] = res.headers.get("Set-Cookie").split(
            sep=";", maxsplit=1
        )[0]
        data = {"report_id_list": json.dumps(report_id_list)}
        resp = session.post(url=self.combine_kpi_report_url, data=data, verify=False)
        logging.debug(resp.request)
        # logging.debug(resp.request.body)
        # logging.debug(resp.json())
        combine_report_id = resp.json()["data"].split(" ")[-1]
        logging.debug("combine_report_id is{}".format(combine_report_id))
        return combine_report_id

    def horizontal_merge_reports(
        self,
        report_id_list,
        file_path="/home/ute/KPI_Report/Compass_Report/result.xlsx",
    ):
        """ """
        session = requests.session()
        res = session.post(
            url=self.compass_login_url,
            data={
                "username": base64.b64decode(b"c3RsaW4=").decode("utf-8"),
                "password": base64.b64decode(b"TWF5ZGF5NTU1MzU5QA==").decode("utf-8"),
            },
            verify=False,
        )
        session.headers["cookie"] = res.headers.get("Set-Cookie").split(
            sep=";", maxsplit=1
        )[0]
        data = {"report_id_list": json.dumps(report_id_list)}
        response = session.post(
            url=self.horizontal_merge_reports_url, data=data, verify=False
        )
        if response.status_code == 200:
            # content_disposition = response.headers.get("Content-Disposition")
            # if content_disposition and "filename=" in content_disposition:
            #     filename = content_disposition.split("filename=")[-1].strip('"')
            # else:
            #     filename = "result.xlsx"
            # file_path = os.path.join(save_directory, filename)
            with open(file_path, "wb") as f:
                f.write(response.content)
            print(f"File saved as: {file_path}")
        else:
            print(f"Failed to download file. Status code: {response.status_code}")

    def get_compare_report(
        self, reports, file_name="/home/ute/KPI_Report/Compass_Report/compare.xlsx"
    ):
        session = requests.session()
        res = session.post(
            url=self.compass_login_url,
            data={
                "username": base64.b64decode(b"c3RsaW4=").decode("utf-8"),
                "password": base64.b64decode(b"TWF5ZGF5NTU1MzU5QA==").decode("utf-8"),
            },
            verify=False,
        )
        session.headers["cookie"] = res.headers.get("Set-Cookie").split(
            sep=";", maxsplit=1
        )[0]
        data = {"reports": reports}
        response = session.post(
            url="http://compass.dyn.nesc.nokia.net:8080/kpi/compare_kpi_report/",
            data=data,
            verify=False,
        )
        logging.debug(response.json())
        return response.json()

    def get_template_set_names(self):
        session = requests.session()
        res = session.post(
            url=self.compass_login_url,
            data={
                "username": base64.b64decode(b"c3RsaW4=").decode("utf-8"),
                "password": base64.b64decode(b"TWF5ZGF5NTU1MzU5QA==").decode("utf-8"),
            },
            verify=False,
        )
        session.headers["cookie"] = res.headers.get("Set-Cookie").split(
            sep=";", maxsplit=1
        )[0]
        response = session.post(
            url="http://compass.dyn.nesc.nokia.net:8080/kpi/kpi_template_set/",
            verify=False,
        )
        data = response.json()["data"]
        filter_data = [x for x in data if "ivy" in x["name"]]
        return filter_data

    def analysis_kpi_report(self, report_id_list, labels=[]):
        """ """
        report_id_list = [str(x) for x in report_id_list]
        report_id_list = "[" + ",".join(['"' + x + '"' for x in report_id_list]) + "]"
        logging.debug("report_id_list is {}".format(report_id_list))
        headers = {"cookie": f"name=m1shi; sessionid=kwm3keqgqn9if8bc1io1wm5g2rlom9el"}
        data = {"report_id_list": f"{report_id_list}", "labels": f"{labels}"}
        resp = requests.post(
            url=self.analysis_kpi_report_url, headers=headers, data=data, verify=False
        )
        logging.debug(resp.request)
        logging.debug(resp.request.body)
        # logging.debug(resp.text)
        logging.debug(resp.json())

    def get_analysis_kpi_result(self, report_id):
        """ """
        data = {"report_id": f"{report_id}"}
        session = requests.session()
        res = session.post(
            url=self.compass_login_url,
            data={
                "username": base64.b64decode(b"c3RsaW4=").decode("utf-8"),
                "password": base64.b64decode(b"TWF5ZGF5NTU1MzU5QA==").decode("utf-8"),
            },
            verify=False,
        )
        session.headers["cookie"] = res.headers.get("Set-Cookie").split(
            sep=";", maxsplit=1
        )[0]
        resp = session.post(
            url="http://compass.dyn.nesc.nokia.net:8080/kpi/get_kpi_report_detail/",
            data=data,
            verify=False,
        )
        logging.debug(resp.request.body)
        report_data = json.loads(resp.content)
        # logging.debug("report_data is {}".format(report_data))
        assert len(report_data["data"]) != 0, "ERRORS: get compass kpi result failed\n"
        return report_data

    def get_scout_token(self, username, password):
        """
        Get the Scout token.
        :param username: the username
        :param password: the password
        :return: the Scout token
        """
        url = "https://scout.nsn-rdnet.net/future/api/v1/api_token_obtain/"
        data = {
            "data": {
                "type": "obtain_json_web_token",
                "attributes": {"username": username, "password": password},
            }
        }
        headers = {
            "User-Agent": self.common_user_agent,
            "Accept": "application/vnd.api+json",
            "Content-Type": "application/vnd.api+json",
        }
        with requests.post(url=url, json=data, headers=headers) as resp:
            return resp.json()["data"]["attributes"]["token"]

    def get_kpi_report(self, response, path):
        """
        Get the KPI report.
        :param response: the response of the request
        :param path: the path to save the KPI report
        """
        headers_2 = {
            "User-Agent": self.common_user_agent,
        }
        pattern = re.compile(r"(?P<url>https://.*?\.xlsx)")
        excel_url = (
            re.search(pattern, response.json()["errors"][0]["detail"])
            .group("url")
            .strip()
        )
        print(excel_url)
        with requests.get(url=excel_url, headers=headers_2) as resp_2:
            print(resp_2.status_code)
            filename = excel_url.split("/")[-1]
            excel_file_name = os.path.join(path, filename)
            if resp_2.status_code == 200:
                with open(excel_file_name, "wb") as f:
                    f.write(resp_2.content)
        return excel_file_name

    def download_kpi_result_file(
        self, report_id, path, is_compare_kpi=False, is_analysis_report=False
    ):
        """
        Download the KPI result file.
        :param report_id: the report id
        :param path: the path to save the KPI result file
        """
        authorization = self.get_scout_token(
            username=base64.b64decode(b"c3RsaW4=").decode("utf-8"),
            password=base64.b64decode(b"TWF5ZGF5NTU1MzU5QA==").decode("utf-8"),
        )
        report_url = f"https://scout.nsn-rdnet.net/future/api/v1/kpis_reports/{report_id}/export_to_excel/"
        compare_url = f"https://scout.nsn-rdnet.net/future/api/v1/comparator_reports/{report_id}/export_compare_result/"
        analysis_report_url = f"http://compass.dyn.nesc.nokia.net:8080/kpi/scout_kpi/{report_id}/export_kpi_details"
        if is_compare_kpi:
            url = compare_url
        elif is_analysis_report:
            url = analysis_report_url
        else:
            url = report_url
        headers = {
            "User-Agent": self.common_user_agent,
            "Authorization": f"JWT {authorization}",
            # "Authorization": "JWT eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJ0b2tlbl90eXBlIjoiYWNjZXNzIiwiZXhwIjox"
            #                  "NzMwMDk0NTIxLCJpYXQiOjE3Mjk0ODk3MjEsImp0aSI6IjUwZDVlMWJjZTY5NDRiNWRiNDM3OTk4N2I5Z"
            #                  "DRlM2M2IiwidXNlcm5hbWUiOiJzdGxpbiIsImVtYWlsIjoic3RlbGxhLmxpbkBub2tpYS1zYmVsbC5jb2"
            #                  "0iLCJpZCI6MzM3MCwiZGlzcGxheV9uYW1lIjoiU3RlbGxhIExpbiAoTlNCKSJ9.5ph7XrhzXtP9GTmv3t"
            #                  "eZLEKI-dDHt6JAXs_oFcfuqgQ",
        }
        """
        resp.json()
        1. {'data': 'Scout is preparing your KPI report. Details will be sent to ming.shi@nokia-sbell.com'}
        2. {'errors': [{'detail': "You're KPI report already exist as excel file in our storage.
        If you want you can download this file from :
        https://es-si-s3-z2.eecloud.nsn-net.net/scout.reports/2024-06-20/test_2024-06-20T093229638119.xlsx",
        'status': '400', 'source': {'pointer': '/data'}}]}
        """
        for i in range(12):
            with requests.get(url=url, headers=headers) as resp:
                logging.debug("resp is{}".format(resp.json()))
                if list(resp.json().keys())[0] == "errors" and (
                    "You're KPI report already exist as excel file in our "
                    "storage" in resp.json()["errors"][0]["detail"]
                ):
                    excel_file_name = self.get_kpi_report(response=resp, path=path)
                    break
                else:
                    print("waif for 400s to get the KPI report.")
                    time.sleep(400)
        return excel_file_name


def round_to_3decimal(value):
    """
    author: jun.8.chen@nokia-sbell.com
    """
    try:
        return round(value, 3)
    except TypeError:
        return "N/A"


def get_data_from_scout_reports(kpis, x):
    """
    author: lei.jia@nokia-sbell.com
    """
    group_name = kpis[x]["group_name"]
    code = kpis[x]["code"]
    name = kpis[x]["name"]
    entry_name = "[" + code + "]" + " " + name
    value = kpis[x]["global_result"]["value"]
    unit = kpis[x].get("unit")
    rounded_value = round_to_3decimal(value)
    return group_name, entry_name, unit, rounded_value


def generate_excel_data(
    scout_report, file_path=None, stream_version=None, scf_version=None, try_index=0
):
    """
    author: lei.jia@nokia-sbell.com
    Generate excel data from scout KPI report.
    :param scout_report: scout KPI report
    :param file_path: path of created file. If None file is created in robot logs path.
    :param stream_version: for example 24R2
    :param scf_version: 24R1/24R2 and so on
    :param try_index: it is first, second or third try. Each turn try three times.
    :return: None
    """
    data_dict = {}
    group_name_list = []
    unit_name_list = []
    entry_name_list = []
    rounded_value_list = []
    value_column_name = (
        "SW" + stream_version + "_SCF" + scf_version + "_try" + str(try_index)
    )

    KPIs = scout_report[0]["report"]
    start_time = scout_report[0]["start_time"]
    end_time = scout_report[0]["end_time"]
    len_of_KPIs = len(KPIs)
    for x in range(len_of_KPIs):
        group_name, entry_name, unit_value, rounded_value = get_data_from_scout_reports(
            KPIs, x
        )
        group_name_list.append(group_name)
        entry_name_list.append(entry_name)
        unit_name_list.append(unit_value)
        rounded_value_list.append(rounded_value)
    data_dict["Group name"] = group_name_list
    data_dict["Entry name"] = entry_name_list
    data_dict["Unit"] = unit_name_list
    data_dict[value_column_name] = rounded_value_list
    return data_dict, start_time, end_time


def generate_excel_report(
    scout_report,
    file_path=None,
    sw_version=None,
    stream_version=None,
    scf_version=None,
    try_index=0,
):
    """
    author: lei.jia@nokia-sbell.com
    Generate excel from scout KPI report.
    :param scout_report: scout KPI report
    :param file_path: path of created file. If None file is created in robot logs path.
    :param sw_version: gnb active sw version
    :param stream_version: for example 24R2
    :param scf_version: 24R1/24R2 and so on
    :param try_index: it is first, second or third try. Each turn try three times.
    :return: None
    """
    init_pandas()
    data_dict, start_time, end_time = generate_excel_data(
        scout_report=scout_report,
        file_path=file_path,
        stream_version=stream_version,
        scf_version=scf_version,
        try_index=try_index,
    )

    df_the_dict = pd.DataFrame(data_dict)
    # adding a row for start time
    df_the_dict.loc[-1] = [None, None, None, "start_time: " + start_time]
    df_the_dict.index = df_the_dict.index + 1  # shifting index
    # adding a row for sw version
    df_the_dict.loc[-1] = [None, None, None, sw_version]
    df_the_dict.index = df_the_dict.index + 1  # shifting index
    df_the_dict = df_the_dict.sort_index()
    dir_name = os.path.dirname(file_path)
    if not os.path.exists(dir_name):
        os.makedirs(dir_name)
    df_the_dict.to_excel(file_path, index=False)


def concatenates_excel_report(
    input_file_paths, output_file_path, source_stream=None, target_stream=None
):
    """
    author: lei.jia@nokia-sbell.com
    concatenates all input Excel files into one and generate avg KPI data for source streams and target stream.
    :param input_file_paths: path for all input excels.
    :param output_file_path: output Excel file.
    :param source_stream: 24R1/24R2/24R3 before gnb upgrade
    :param target_stream: 24R2/24R3 after gnb upgrade
    :return: None
    """
    init_pandas()
    output_df = pd.DataFrame()
    for index, infile in enumerate(input_file_paths):
        input_df = pd.read_excel(infile)
        if index == 0:
            output_df = pd.concat([output_df, input_df], ignore_index=True)
        else:
            output_df = pd.concat([output_df, input_df.iloc[:, -1:]], axis=1)
    # generate 3 times avg KPI report: (before upgrade)source_stream_with_source_scf
    #                                  (after_upgrade)target_stream_source_scf
    #                                  (after_upgrade_load_new_scf)target_stream_target_scf
    generate_avg_kpi_data_based_on_stream_version(
        df=output_df, stream_version=source_stream, scf_version=source_stream
    )
    generate_avg_kpi_data_based_on_stream_version(
        df=output_df, stream_version=target_stream, scf_version=source_stream
    )
    generate_avg_kpi_data_based_on_stream_version(
        df=output_df, stream_version=target_stream, scf_version=target_stream
    )
    output_df.to_excel(output_file_path)


def generate_avg_kpi_data_based_on_stream_version(
    df=None, stream_version=None, scf_version=None
):
    """
    author: lei.jia@nokia-sbell.com
    calculate avg KPI data based on try0/1/2 for one stream
    :param df: df = pd.read_excel(file_path)
    :param stream_version: 24R1/24R2/24R3
    :param scf_version: 24R1/24R2/24R3
    :return: None
    """
    # df = pd.read_excel(file_path)
    check_string = "SW" + stream_version + "_SCF" + scf_version
    stream_cols = [col for col in df.columns if check_string in col]
    # col_index_list = [df.columns.get_loc(c) for c in stream_cols]
    avg_column_name = "avg_" + check_string
    df[avg_column_name] = df[stream_cols].iloc[2:].mean(axis=1)
    # df.to_excel(file_path)


def compare_avg_kpi_data(file_path):
    """
    author: lei.jia@nokia-sbell.com
    compare avg KPI data for 2 streams: for example avg_kpi_data from previous stream, avg_kpi_data after gnb upgrade.
    :param file_path: path of created file. If None file is created in robot logs path.
    :return: None
    """
    init_pandas()
    df = pd.read_excel(file_path)
    check_string = "avg"
    avg_col_name_list = [col for col in df.columns if check_string in col]
    col_index_list = [df.columns.get_loc(c) for c in avg_col_name_list]
    for index, column_index in enumerate(col_index_list):
        if index == len(col_index_list) - 1:
            continue
        else:
            new_column_name = (
                avg_col_name_list[index + 1][4:] + "_VS_" + avg_col_name_list[index][4:]
            )
            df[new_column_name] = (
                df.iloc[:, col_index_list[index + 1]]
                - df.iloc[:, col_index_list[index]]
            ) / df.iloc[:, col_index_list[index]]
    df.to_excel(file_path, index=False)


def set_font_color_for_kpi_date(file_path):
    """
    author: lei.jia@nokia-sbell.com
    set font for compared results, red for <-0.1, green for >-0.1.
    using openpyxl due to df.style.apply need pandas version for about 3.0
    :param file_path: path of created file. If None file is created in robot logs path.
    :return: None
    """
    wb = openpyxl.load_workbook(file_path)
    ws = wb.active
    red_Font = Font(color="c00000")
    green_Font = Font(color="00FF00")
    black_Font = Font(color="000000")
    max_col_end = ws.max_column
    max_row_end = ws.max_row
    # get column index for including "VS"
    rows = ws.iter_rows(min_row=1, max_row=1)  # returns a generator of rows
    first_row = next(rows)  # get the first row
    heading_list = [c.value for c in first_row]  # extract the values from the cells
    for col_name in heading_list[1:]:
        if "VS" in col_name:
            vs_col_index = heading_list.index(col_name)

    # set header wrap text
    for row in ws.iter_rows(min_row=1, max_row=2, min_col=None, max_col=None):
        for cell in row:
            cell.alignment = Alignment(wrap_text=True)

    # set compared KPI data(column like "SW24R2_SCF24R2_VS_SW24R2_SCF24R1") with font red or green
    for row in ws.iter_rows(
        min_row=4, max_row=max_row_end, min_col=vs_col_index, max_col=max_col_end
    ):
        for cell in row:
            if isinstance(cell.value, (float, int)):
                if cell.value <= -0.1:
                    cell.font = red_Font
                else:
                    cell.font = green_Font
                # change to 100% percentage
                cell.value = cell.value * 100
                cell.value = round(cell.value, 2)
            else:
                cell.font = black_Font
    wb.save(file_path)


def concatenates_excel_report_and_compare_kpi_data(
    input_file_paths, output_file_path, source_stream=None, target_stream=None
):
    concatenates_excel_report(
        input_file_paths=input_file_paths,
        output_file_path=output_file_path,
        source_stream=source_stream,
        target_stream=target_stream,
    )
    compare_avg_kpi_data(file_path=output_file_path)
    set_font_color_for_kpi_date(file_path=output_file_path)


def download_kpi_file(report_id, path, is_compare_kpi=False, is_analysis_report=False):
    dpf = DownloadKpiFile()
    excel_file_name = dpf.download_kpi_result_file(
        report_id=report_id,
        path=path,
        is_compare_kpi=is_compare_kpi,
        is_analysis_report=is_analysis_report,
    )
    return excel_file_name


def generate_new_report_on_compass(
    report_name,
    tl_id,
    package_version,
    start_time,
    end_time,
    comments="",
    template_name="KPI_24R1_TMO_SA_SG6",
    check_out_entry="true",
):
    # template_name = DownloadKpiFile.get_parameter_info(file_path=file_path)["template_name"]
    # if template_name is None:
    #     print("Failed to get the template name.")
    #     raise Exception("Failed to get the template name. please check yaml file")
    dpf = DownloadKpiFile()
    report_id = dpf.generate_new_report(
        report_name=report_name,
        tl_id=tl_id,
        package_version=package_version,
        template_name=template_name,
        start_time=start_time,
        end_time=end_time,
        comments=comments,
        check_out_entry=check_out_entry,
    )
    return report_id


def get_kpi_template_names_based_on_branch(release="26R2"):
    dpf = DownloadKpiFile()
    template_names = dpf.get_template_set_names()
    logging.debug("template_names is {}".format(template_names))
    template_names_release = [x for x in template_names if release in x["name"]]
    if len(template_names_release) == 0:
        template_names_release = [x for x in template_names if "26R2" in x["name"]]
    logging.debug("template_names_release is {}".format(template_names_release))
    assert len(template_names_release) != 0, "ERRORS: get template set name failed\n"
    template_set_names_list = template_names_release[0]["kpi_templates"].split(";")
    template_set_names_list = [x.strip() for x in template_set_names_list]
    return template_set_names_list


def get_kpi_result_from_compass(
    report_id,
    output_report="/home/ute/KPI_Report/Compass_Report/compass_report.xlsx",
    package_version=None,
):
    init_pandas()
    dpf = DownloadKpiFile()
    kpi_report = dpf.get_analysis_kpi_result(report_id=report_id)
    code_list = []
    kpi_name_list = []
    value_list = []
    context = kpi_report["data"]
    for data in context:
        code = data["code"]
        kpi_name = data["kpi_name"]
        value = data["value"]
        code_list.append(code)
        kpi_name_list.append(kpi_name)
        value_list.append(value)
    if package_version is not None:
        df_context = {
            "Code": code_list,
            "KPI Name": kpi_name_list,
            package_version: value_list,
        }
    else:
        df_context = {"Code": code_list, "KPI Name": kpi_name_list, "Value": value_list}
    df = pd.DataFrame(data=df_context)
    with pd.ExcelWriter(output_report) as writer:
        df.to_excel(
            writer,
            sheet_name="KPI Report",
            index=False,
            engine="xlsxwriter",
        )

    wb = load_workbook(output_report)
    ws = wb["KPI Report"]
    header_fill = PatternFill(
        start_color="87CEEB", end_color="87CEEB", fill_type="solid"
    )
    header_font = Font(color="FFFFFF", bold=True)  # 白色字体，粗体
    header_alignment = Alignment(horizontal="left", vertical="center", wrap_text=True)

    for cell in ws[1]:
        cell.fill = header_fill
        cell.font = header_font
        cell.alignment = header_alignment

    for row in ws.iter_rows(min_row=2):
        for cell in row:
            cell.alignment = Alignment(
                horizontal="left", vertical="center", wrap_text=True
            )
    ws.column_dimensions["A"].width = 32
    ws.column_dimensions["B"].width = 60
    ws.column_dimensions["C"].width = 25
    ws.column_dimensions["D"].width = 18
    ws.column_dimensions["E"].width = 18
    ws.column_dimensions["F"].width = 18
    ws.row_dimensions[1].height = 83
    for row in range(2, ws.max_row + 1):
        ws.row_dimensions[row].height = 31

    calibri_font = Font(name="Calibri", size=10)

    for row in ws.iter_rows(
        min_row=1, max_row=ws.max_row, min_col=1, max_col=ws.max_column
    ):
        for cell in row:
            cell.font = calibri_font
    wb.save(output_report)
    return output_report


def combine_kpi_reports_on_compass(report_id_list):
    dpf = DownloadKpiFile()
    combine_report_id = dpf.combine_kpi_report(report_id_list=report_id_list)
    return combine_report_id


def get_horizontal_merge_reports(
    report_id_list, file_path="/home/ute/KPI_Report/Compass_Report/result.xlsx"
):
    logging.debug("start to merge horizontal reports")
    dpf = DownloadKpiFile()
    dpf.horizontal_merge_reports(report_id_list=report_id_list, file_path=file_path)


def get_compare_kpi_report_from_compass(
    reports, file_name="/home/ute/KPI_Report/Compass_Report/compare.xlsx"
):
    init_pandas()
    dpf = DownloadKpiFile()
    context = dpf.get_compare_report(reports=reports, file_name=file_name)
    package_list = context["packages"]
    value_length = len(package_list)
    all_data = context["data"]
    group_name_list = []
    code_list = []
    kpi_name_list = []
    value1_list = []
    value2_list = []
    value3_list = []
    for data in all_data:
        group_name = data["group_name"]
        code = data["code"]
        kpi_name = data["kpi_name"]
        value1 = data["value1"]
        value2 = data["value2"]
        if value_length == 3:
            value3 = data["value3"]
        group_name_list.append(group_name)
        code_list.append(code)
        kpi_name_list.append(kpi_name)
        value1_list.append(value1)
        value2_list.append(value2)
        if value_length == 3:
            value3_list.append(value3)
    if value_length == 3:
        df_context = {
            "Group Name": group_name_list,
            "Code": code_list,
            "KPI Name": kpi_name_list,
            package_list[0]: value1_list,
            package_list[1]: value2_list,
            package_list[2]: value3_list,
        }
    else:
        df_context = {
            "Group Name": group_name_list,
            "Code": code_list,
            "KPI Name": kpi_name_list,
            package_list[0]: value1_list,
            package_list[1]: value2_list,
        }
    df = pd.DataFrame(data=df_context)
    with pd.ExcelWriter(file_name) as writer:
        df.to_excel(
            writer,
            sheet_name="KPI Report",
            index=False,
            engine="xlsxwriter",
        )
    wb = load_workbook(file_name)
    ws = wb["KPI Report"]
    header_fill = PatternFill(
        start_color="87CEEB", end_color="87CEEB", fill_type="solid"
    )
    header_font = Font(color="FFFFFF", bold=True)
    header_alignment = Alignment(horizontal="left", vertical="center", wrap_text=True)

    for cell in ws[1]:
        cell.fill = header_fill
        cell.font = header_font
        cell.alignment = header_alignment
    for row in ws.iter_rows(min_row=2):
        for cell in row:
            cell.alignment = Alignment(
                horizontal="left", vertical="center", wrap_text=True
            )
    ws.column_dimensions["A"].width = 34
    ws.column_dimensions["B"].width = 16
    ws.column_dimensions["C"].width = 53
    ws.column_dimensions["D"].width = 18
    ws.column_dimensions["E"].width = 18
    ws.column_dimensions["F"].width = 18
    ws.row_dimensions[1].height = 83
    for row in range(2, ws.max_row + 1):
        ws.row_dimensions[row].height = 31
    calibri_font = Font(name="Calibri", size=10)
    for row in ws.iter_rows(
        min_row=1, max_row=ws.max_row, min_col=1, max_col=ws.max_column
    ):
        for cell in row:
            cell.font = calibri_font
    wb.save(file_name)
    return file_name


def analysis_kpi_reports_on_compass(report_id_list):
    dpf = DownloadKpiFile()
    dpf.analysis_kpi_report(report_id_list=report_id_list)


def analysis_kpi_rule_result(report_id, output_report_path, package_info):
    init_pandas()
    # create rule result
    df_empty = pd.DataFrame()
    logging.debug("file is {}".format(output_report_path))
    output_report_dir = "/".join(output_report_path.split("/")[0:6])
    logging.debug("dir is {}".format(output_report_dir))
    if os.path.exists(output_report_path):
        pass
    else:
        if os.path.exists(output_report_dir):
            with pd.ExcelWriter(output_report_path) as writer:
                df_empty.to_excel(
                    writer,
                    sheet_name="ERR_WARN",
                    index=False,
                    engine="xlsxwriter",
                )
        else:
            os.makedirs(os.path.dirname(output_report_path))
            with pd.ExcelWriter(output_report_path) as writer:
                df_empty.to_excel(
                    writer,
                    sheet_name="rule_result",
                    index=False,
                    engine="xlsxwriter",
                )
    res = {
        "SwVersion": [package_info],
    }
    df_summary_new_err = pd.DataFrame(data=res)
    df_summary_new_manual = pd.DataFrame(data=res)
    dpf = DownloadKpiFile()
    kpi_rule_result = dpf.get_analysis_kpi_result(report_id=report_id)
    for name in ["ERR_WARN", "MANUAL_CHECK"]:
        wb = load_workbook(output_report_path, read_only=False)
        if name in wb.sheetnames:
            pass
        else:
            wb.create_sheet(name)
            wb.save(output_report_path)
    err_warn_list = []
    manual_check_list = []
    df_original_err = pd.read_excel(output_report_path, sheet_name="ERR_WARN")
    df_original_manual = pd.read_excel(output_report_path, sheet_name="MANUAL_CHECK")
    for kpi_result in kpi_rule_result["data"]:
        kpi_name = kpi_result["code"] + "\n" + kpi_result["kpi_name"]
        kpi_value = kpi_result["value"]
        if isinstance(kpi_value, float):
            kpi_value = round(kpi_value, 2)
        kpi_info = kpi_value
        if (
            "error" in kpi_result["analysis_result"]
            or "warning" in kpi_result["analysis_result"]
        ):
            kpi_rule_result = kpi_result["rule"]
            kpi_info = str(kpi_value) + "\n" + str(kpi_rule_result)
            type = "ERR_WARN"
            info = "kpi_name:{},value:{},rule:{}".format(
                kpi_name, kpi_value, kpi_result["rule"]
            )
            logging.debug(
                "kpi {} rule check status is {}".format(kpi_result["code"], type)
            )
            err_warn_list.append(info)
        elif "manual check" in kpi_result["analysis_result"]:
            type = "MANUAL_CHECK"
            info = "kpi_name:{},value:{},rule:{}".format(
                kpi_name, kpi_value, kpi_result["rule"]
            )
            logging.debug(
                "kpi {} rule check status is {}".format(kpi_result["code"], type)
            )
            manual_check_list.append(info)
        else:
            type = "PASS"
        # logging.debug("kpi {} rule check status is {}".format(kpi_result["code"], type))
        kpi_code_name_list = [kpi_info]
        context = {kpi_name: kpi_code_name_list}
        df_add_counter = pd.DataFrame(data=context)
        if type == "ERR_WARN":
            df_summary_new_err = pd.concat([df_summary_new_err, df_add_counter], axis=1)
            logging.debug("df_err_is{}".format(df_summary_new_err))
        elif type == "MANUAL_CHECK":
            df_summary_new_manual = pd.concat(
                [df_summary_new_manual, df_add_counter], axis=1
            )
            logging.debug("df_err_manual{}".format(df_summary_new_manual))
    df_summary_final_err = pd.concat(
        [df_original_err, df_summary_new_err], ignore_index=True
    )
    df_summary_final_manual = pd.concat(
        [df_original_manual, df_summary_new_manual], ignore_index=True
    )
    with pd.ExcelWriter(
        output_report_path, mode="a", engine="openpyxl", if_sheet_exists="replace"
    ) as writer:
        df_summary_final_err.to_excel(writer, sheet_name="ERR_WARN", index=False)
    with pd.ExcelWriter(
        output_report_path, mode="a", engine="openpyxl", if_sheet_exists="replace"
    ) as writer:
        df_summary_final_manual.to_excel(writer, sheet_name="MANUAL_CHECK", index=False)
    logging.debug("start to wrap text for kpi rule result")
    text_wrap_for_report(output_report_path)
    assert len(err_warn_list) == 0, "KPI RULE Check ERR_WARN for {}.\n{}".format(
        package_info, err_warn_list
    )


def generate_new_comparator_report_on_compass(
    test_line_id,
    test_line_name,
    report_name,
    template_names_list,
    template_id_list,
    first_description,
    first_start_time,
    first_end_time,
    second_description,
    second_start_time,
    second_end_time,
    alpha_factor=0.05,
    comments=" ",
):
    # template_name = DownloadKpiFile.get_parameter_info(file_path=file_path)["template_name"]
    # if template_name is None:
    #     print("Failed to get the template name.")
    #     raise Exception("Failed to get the template name. please check yaml file")
    dpf = DownloadKpiFile()
    report_id = dpf.generate_comparator_report(
        report_name=report_name,
        test_line_id=test_line_id,
        test_line_name=test_line_name,
        template_names_list=template_names_list,
        template_id_list=template_id_list,
        first_description=first_description,
        first_start_time=first_start_time,
        first_end_time=first_end_time,
        second_description=second_description,
        second_start_time=second_start_time,
        second_end_time=second_end_time,
        alpha_factor=alpha_factor,
        comments=comments,
    )
    return report_id


def generate_kpi_report_based_on_scout_report(
    sw_version,
    scf_name,
    scout_report_time,
    excel_report_path,
    output_report_path,
    filter_distnames=[],
    group_name=None,
):
    """
    author: stella.lin@nokia-sbell.com
    compare avg KPI data for 2 streams: for example avg_kpi_data from previous stream, avg_kpi_data after gnb upgrade.
    :param file_path: path of created file. If None file is created in robot logs path.
    :return: None
    """
    init_pandas()
    df_empty = pd.DataFrame()
    logging.debug("file is {}".format(output_report_path))
    output_report_dir = "/".join(output_report_path.split("/")[0:6])
    logging.debug("dir is {}".format(output_report_dir))
    if os.path.exists(output_report_path):
        pass
    else:
        if os.path.exists(output_report_dir):
            with pd.ExcelWriter(output_report_path) as writer:
                df_empty.to_excel(
                    writer,
                    sheet_name="bts",
                    index=False,
                    engine="xlsxwriter",
                )
        else:
            os.makedirs(os.path.dirname(output_report_path))
            with pd.ExcelWriter(output_report_path) as writer:
                df_empty.to_excel(
                    writer,
                    sheet_name="bts",
                    index=False,
                    engine="xlsxwriter",
                )
    df_details = pd.read_excel(excel_report_path, sheet_name="Chart Data")
    reproduce_kpi_values_dict = {}
    if group_name is not None:
        df_details = df_details[df_details.GroupName.str.contains(group_name)]
    for filter_disname in filter_distnames:
        try:
            df_original = pd.read_excel(output_report_path, sheet_name=filter_disname)
            original_counter_name_list = list(df_original.columns)
        except Exception as e:
            original_counter_name_list = []
        res = {
            "ReportTime": [scout_report_time],
            "SwVersion": [sw_version],
            "ScfName": [scf_name],
        }
        df_summary_new = pd.DataFrame(data=res)
        wb = load_workbook(output_report_path, read_only=False)
        if filter_disname in wb.sheetnames:
            df_summary_orig = pd.read_excel(
                output_report_path, sheet_name=filter_disname
            )
        else:
            wb.create_sheet(filter_disname)
            wb.save(output_report_path)
            df_summary_orig = pd.read_excel(
                output_report_path, sheet_name=filter_disname
            )
        filter_df_with_dist_name = df_details[
            df_details.DistName.str.contains(filter_disname)
        ]
        counter_name_list = filter_df_with_dist_name["EntryName"].values
        counter_name_list = list(set(counter_name_list))
        df_calculation = pd.read_excel(
            "/home/ute/KPI_Report/kpi_calculation_template.xlsx"
        )
        calculation_code = df_calculation["Code"].tolist()
        calculate_type = df_calculation["proposed to calculate"].tolist()
        for counter_name in counter_name_list:
            couter_prefix = counter_name.split("[")[-1].split("]")[0]
            filter_df_counter = filter_df_with_dist_name[
                filter_df_with_dist_name.EntryName.str.contains(couter_prefix)
            ]
            valid_type = ["sum", "avg", "min", "max"]
            try:
                index = calculation_code.index(couter_prefix)
                target_calculate_type = calculate_type[index]
                if math.isnan(target_calculate_type):
                    print("type is empty in kpi_calculation_template")
                    target_calculate_type = "sum"
                elif target_calculate_type not in valid_type:
                    target_calculate_type = "sum"
                else:
                    pass
            except Exception as e:
                print(
                    "counter_name {} is not in kpi_calculation_template".format(
                        couter_prefix
                    )
                )
                target_calculate_type = "sum"
            print(
                " calculate_type for {} is {}".format(
                    couter_prefix, target_calculate_type
                )
            )
            # logging.debug("couter_prefix is{}".format(couter_prefix))
            filter_df_counter = filter_df_counter.dropna(subset=["Value"])
            # logging.debug("filter_df_counter for {} is {}".format(couter_prefix,filter_df_counter))
            if filter_df_counter.empty:
                counter_sum = "Missed"
            else:
                if target_calculate_type == "sum":
                    counter_sum = filter_df_counter["Value"].sum(min_count=1)
                elif target_calculate_type == "avg":
                    counter_sum = filter_df_counter["Value"].mean()
                elif target_calculate_type == "min":
                    counter_sum = filter_df_counter["Value"].min()
                elif target_calculate_type == "max":
                    counter_sum = filter_df_counter["Value"].max()
                if isinstance(counter_sum, float):
                    counter_sum = round(counter_sum, 2)
            # logging.debug("sum for {} is {}".format(couter_prefix, counter_sum))
            if couter_prefix == "NR_5108e":
                logging.debug("start to deal with specfic kpi NR_5108e")
                filtered_df_remove_nan = filter_df_counter.dropna(subset=["Value"])
                if filtered_df_remove_nan.empty:
                    logging.debug("NR_5108e is NaN")
                    report_status = "INVALID"
                    counter_sum = filter_df_counter["Value"].sum(min_count=1)
                else:
                    filtered_df = filtered_df_remove_nan[
                        filter_df_counter["Value"].astype("float") > 10
                    ]
                    logging.debug(
                        "filtered_df NR_5108e value list is{}".format(filtered_df)
                    )
                    counter_sum = filtered_df["Value"].mean()
                    if isinstance(counter_sum, float):
                        counter_sum = round(counter_sum, 2)
            if couter_prefix in REPRODUCE_KPI_NAME_LIST:
                logging.debug(
                    "{} vaues is {}".format(couter_prefix, filter_df_counter["Value"])
                )
                if counter_sum != "Missed":
                    counter_sum = float(counter_sum)
                reproduce_kpi_values_dict[couter_prefix] = float(counter_sum)
            counter_sum_list = [counter_sum]
            couter_prefix_full = couter_prefix + "]"
            index = [
                i
                for i, e in enumerate(original_counter_name_list)
                if couter_prefix_full in e
            ]
            if len(index) == 0:
                counter_name_new = counter_name
                logging.debug("counter name new is {}".format(counter_name_new))
            else:
                counter_name_new = original_counter_name_list[index[0]]
            context = {counter_name_new: counter_sum_list}
            df_add_counter = pd.DataFrame(data=context)
            df_summary_new = pd.concat([df_summary_new, df_add_counter], axis=1)
        df_summary_final = pd.concat(
            [df_summary_orig, df_summary_new], ignore_index=True
        )
        df_summary_final = df_summary_final.round(2)
        with pd.ExcelWriter(
            output_report_path, mode="a", engine="openpyxl", if_sheet_exists="replace"
        ) as writer:
            df_summary_final.to_excel(writer, sheet_name=filter_disname, index=False)
    text_wrap_for_report(output_report_path)
    return reproduce_kpi_values_dict


def generate_kpi_data_to_testcase_path(
    kpi_info_list,
    output_report_path,
    filter_distnames=[],
    group_name=None,
):
    init_pandas()
    dfs = []
    for kpi_info in kpi_info_list:
        swbuild_info = kpi_info["swbuild_info"]
        report_period = kpi_info["report_period"]
        report_period = str(report_period)
        logging.debug("report_period is {}".format(report_period))
        excel_report_path = kpi_info["excel_report_path"]
        for report in excel_report_path:
            df_details = pd.read_excel(report, sheet_name="Chart Data")
            if group_name is not None:
                df_details = df_details[df_details.GroupName.str.contains(group_name)]
            timestamp_list = df_details["TimeStamp"].values
            # timestamp_list = list(set(timestamp_list))
            timestamp_list = list(OrderedDict.fromkeys(timestamp_list))
            timestamp_list.append("SUM")
            logging.debug("timestamp_list is {}".format(timestamp_list))
            report_info_list = [swbuild_info for x in timestamp_list]
            report_period_list = [report_period for x in timestamp_list]
            df_summary = pd.DataFrame()
            df_frame_list = []
            for filter_disname in filter_distnames:
                logging.debug("filter_disname is {}".format(filter_disname))
                df_summary_new = pd.DataFrame()
                filter_df_with_dist_name = df_details[
                    df_details.DistName.str.contains(filter_disname)
                ]
                # logging.debug(
                #     "filter_df_with_dist_name is {}".format(filter_df_with_dist_name)
                # )
                counter_name_list = filter_df_with_dist_name["EntryName"].values
                counter_name_list = list(set(counter_name_list))
                # logging.debug(
                #     "all counter under {} is {}".format(filter_disname, counter_name_list)
                # )
                for counter_name in counter_name_list:
                    couter_prefix = counter_name.split("[")[-1].split("]")[0]
                    logging.debug("couter_prefix is {}".format(couter_prefix))
                    couter_prefix = couter_prefix + "]"
                    filter_df_counter = filter_df_with_dist_name[
                        filter_df_with_dist_name.EntryName.str.contains(couter_prefix)
                    ]
                    # logging.debug(
                    #     "filter_df_counter for {} is {}".format(
                    #         counter_name, filter_df_counter
                    #     )
                    # )
                    counter_timestamp_values = filter_df_counter["Value"]
                    counter_sum = filter_df_counter["Value"].sum()
                    context = {counter_name: counter_timestamp_values}
                    df_add_counter = pd.DataFrame(data=context)
                    df_add_counter = pd.concat(
                        [df_add_counter, pd.DataFrame({counter_name: [counter_sum]})],
                        ignore_index=True,
                    )
                    df_summary_new = pd.concat([df_summary_new, df_add_counter], axis=1)
                    logging.debug("df_summary_new  is {}".format(df_summary_new))
                df_frame_list.append(df_summary_new)
            df_summary = pd.concat(df_frame_list, axis=1, keys=filter_distnames)
            logging.debug("df_summary is {}".format(df_summary))
            df_summary.insert(2, "TimeStamps", timestamp_list, True)
            df_summary.insert(1, "SwBuild", report_info_list, True)
            df_summary.insert(0, "ReportPeriod", report_period_list, True)
            df_summary = df_summary.set_index(["ReportPeriod", "SwBuild", "TimeStamps"])
            dfs.append(df_summary)
    startrow = 0
    with pd.ExcelWriter(output_report_path) as writer:
        for df in dfs:
            logging.debug("df is {}".format(df))
            df.to_excel(
                writer,
                sheet_name="summary",
                index=True,
                startrow=startrow,
                engine="xlsxwriter",
            )
            startrow += df.shape[0] + 6


def combine_two_excel_result(first_excel, second_excel):
    init_pandas()
    df_1 = pd.read_excel(first_excel, sheet_name="Sheet")
    df_2 = pd.read_excel(second_excel, sheet_name="Sheet")
    frames = [df_1, df_2]
    result = pd.concat(frames)
    result.to_excel(first_excel, sheet_name="Sheet", index=False)


def combine_multi_template_comparator_result(
    output_excel, results_list, filter_distnames=[]
):
    init_pandas()
    df_empty = pd.DataFrame()
    with pd.ExcelWriter(output_excel) as writer:
        # logging.debug("df is {}".format(df))
        df_empty.to_excel(
            writer,
            sheet_name="ALL",
            index=False,
            engine="xlsxwriter",
        )
    for filter_distname in filter_distnames:
        frames = []
        for result in results_list:
            df = pd.read_excel(result, sheet_name=filter_distname)
            frames.append(df)
        result = pd.concat(frames)
        with pd.ExcelWriter(
            output_excel,
            mode="a",
            engine="openpyxl",
            if_sheet_exists="replace",
        ) as writer:
            result.to_excel(writer, sheet_name=filter_distname, index=False)
    return output_excel


def extract_compare_data_from_scout(
    compare_report_id, excel_report_path, output_report_prefix, filter_distnames=[]
):
    url = "https://scout.nsn-rdnet.net/future/api/v1/comparator_reports/{}/".format(
        compare_report_id
    )
    init_pandas()
    df_all = pd.read_excel(excel_report_path, sheet_name="Base Report")
    all_entry_names_list = df_all["EntryName"].values
    # logging.debug("all_entry_names_list is {}".format(all_entry_names_list))
    dpf = DownloadKpiFile()
    authorization = dpf.get_scout_token(
        username=base64.b64decode(b"c3RsaW4=").decode("utf-8"),
        password=base64.b64decode(b"TWF5ZGF5NTU1MzU5QA==").decode("utf-8"),
    )
    headers = {
        "User-Agent": dpf.common_user_agent,
        "Authorization": f"JWT {authorization}",
    }
    for i in range(12):
        with requests.get(url=url, headers=headers) as report_resp:
            report_data = json.loads(report_resp.content)
            logging.debug("data is {}".format(report_data))
            time.sleep(30)
            # logging.debug("data is {}".format(report_data))
            try:
                data = report_data["data"]["attributes"]["report"]
            except Exception as e:
                data = {}
            logging.debug("key for data is {}".format(data.keys()))
            if len(data.keys()) != 0:
                break
            else:
                logging.debug("waif for 90s to get the comparator KPI report data.")
                time.sleep(90)
    # report_data = json.loads(report_resp.content)
    first_build = report_data["data"]["attributes"]["current_period_description"]
    second_build = report_data["data"]["attributes"]["reference_period_description"]
    # data = report_data["data"]["attributes"]["report"]
    total_list = []
    for index, (counter_type, context) in enumerate((data.items())):
        logging.debug("counter_type is {}".format(counter_type))
        # logging.debug("counter_type is {}".format(context.items()))
        for index, (counter_name, values) in enumerate(context.items()):
            for index, (object, context) in enumerate(values["data"].items()):
                # logging.debug("context is {}".format(context))
                round_list = []
                build_info = [first_build, second_build]
                round_list.append(build_info)
                # logging.debug("counter_name is {}".format(counter_name))
                round_list.append(counter_name)
                index = [
                    i for i, e in enumerate(all_entry_names_list) if counter_name in e
                ]
                # logging.debug("counter_index is {}".format(index))
                try:
                    full_name = all_entry_names_list[index][0]
                    full_counter_name = full_name.split("]")[-1]
                except Exception as e:
                    full_counter_name = counter_name
                # logging.debug("full name is {}".format(full_name))
                # logging.debug("counter full name is {}".format(full_counter_name))
                round_list.append(full_counter_name)
                if "/" in object:
                    object = object.split("/")[-1]
                round_list.append(object)
                round_list.append(context["calculations"]["status"])
                try:
                    first_data_value = [x[0] for x in context["current_period"]["data"]]
                except Exception as e:
                    first_data_value = "null"
                try:
                    second_data_value = [
                        x[0] for x in context["reference_period"]["data"]
                    ]
                except Exception as e:
                    second_data_value = "null"
                Values = [first_data_value, second_data_value]
                round_list.append(Values)
                try:
                    first_period_count = context["current_period"]["count"]
                except Exception as e:
                    first_period_count = "null"
                try:
                    second_period_count = context["reference_period"]["count"]
                except Exception as e:
                    second_period_count = "null"
                count = [first_period_count, second_period_count]
                round_list.append(count)
                # assert (
                #     first_period_count != second_period_count
                # ), "count for source and target build is not same,source is {},and sencond is {}".format(
                #     second_period_count, first_period_count
                # )
                try:
                    first_period_min = context["current_period"]["min"]
                except Exception as e:
                    first_period_min = "null"
                try:
                    second_period_min = context["reference_period"]["min"]
                except Exception as e:
                    second_period_min = "null"
                min = [first_period_min, second_period_min]
                round_list.append(min)
                try:
                    first_period_max = context["current_period"]["max"]
                except Exception as e:
                    first_period_max = "null"
                try:
                    second_period_max = context["reference_period"]["max"]
                except Exception as e:
                    second_period_max = "null"
                max = [first_period_max, second_period_max]
                round_list.append(max)
                try:
                    first_period_average = context["current_period"]["average"]
                except Exception as e:
                    first_period_average = "null"
                try:
                    second_period_average = context["reference_period"]["average"]
                except Exception as e:
                    second_period_average = "null"
                try:
                    difference = (
                        first_period_average - second_period_average
                    ) / second_period_average
                    average_difference = "{:.2%}".format(difference)
                except Exception as e:
                    average_difference = "null"
                average = [first_period_average, second_period_average]
                round_list.append(average)
                round_list.append(first_period_average)
                round_list.append(second_period_average)
                round_list.append(average_difference)
                try:
                    first_period_median = context["current_period"]["median"]
                except Exception as e:
                    first_period_median = "null"
                try:
                    second_period_median = context["reference_period"]["median"]
                except Exception as e:
                    second_period_median = "null"
                median = [first_period_median, second_period_median]
                round_list.append(median)
                total_list.append(round_list)
    build_first = "_".join(first_build.split("_")[0:5])
    build_second = "_".join(second_build.split("_")[0:5])
    comparator_report_path_on_ute = "/home/ute/KPI_Report/Comparator_Report/{}".format(
        build_first
    )
    report_time = excel_report_path.split(".")[0].split("_")[-1]
    output_report_path = "{}/{}-{} VS {}-{}.xlsx".format(
        comparator_report_path_on_ute,
        output_report_prefix,
        build_first,
        build_second,
        report_time,
    )
    # logging.debug(total_list)
    df = pd.DataFrame(
        total_list,
        columns=[
            "Comparator_Builds",
            "Code",
            "Name",
            "DistName",
            "Status",
            "Values",
            "Count",
            "Min",
            "Max",
            "Average",
            "Average_Target",
            "Average_Source",
            "Average_Difference",
            "Median",
        ],
    )
    df = df.round(2)
    logging.debug("file is {}".format(output_report_path))
    output_report_dir = "/".join(output_report_path.split("/")[0:6])
    logging.debug("dir is {}".format(output_report_dir))
    if os.path.exists(output_report_dir):
        pass
    else:
        logging.debug("add dir")
        os.makedirs(os.path.dirname(output_report_path))
    with pd.ExcelWriter(output_report_path) as writer:
        # logging.debug("df is {}".format(df))
        df.to_excel(
            writer,
            sheet_name="ALL",
            index=False,
            engine="xlsxwriter",
        )
    for filter_disname in filter_distnames:
        logging.debug("filter_disname is {}".format(filter_disname))
        filter_df_with_dist_name = df[df.DistName.str.contains(filter_disname)]
        filter_df_with_dist_name = filter_df_with_dist_name.round(2)
        with pd.ExcelWriter(
            output_report_path,
            mode="a",
            engine="openpyxl",
            if_sheet_exists="replace",
        ) as writer:
            filter_df_with_dist_name.to_excel(
                writer, sheet_name=filter_disname, index=False
            )
    return output_report_path


def comparator_data_analysis(
    compare_report_path, result_report_path, filter_distnames=[], is_fail_case=False
):
    init_pandas()
    df_empty = pd.DataFrame()
    with pd.ExcelWriter(result_report_path) as writer:
        # logging.debug("df is {}".format(df))
        df_empty.to_excel(
            writer,
            sheet_name="OUT OF RANGE",
            index=False,
            engine="xlsxwriter",
        )
    filter_distnames_list = []
    for filter_distname in filter_distnames:
        df_all = pd.read_excel(compare_report_path, sheet_name=filter_distname)
        df_without_null = df_all[df_all["Average_Difference"] != "null"]
        df_with_ablove_percent = df_without_null[
            df_without_null["Average_Difference"]
            .str.rstrip("%")
            .str.replace(",", "")
            .astype("float")
            .abs()
            >= 5
        ]
        with pd.ExcelWriter(
            result_report_path,
            mode="a",
            engine="openpyxl",
            if_sheet_exists="replace",
        ) as writer:
            df_with_ablove_percent.to_excel(
                writer, sheet_name=filter_distname, index=False
            )
        above_counter_code_list = df_with_ablove_percent["Code"].values
        above_counter_names_list = df_with_ablove_percent["Name"].values
        above_percent_list = df_with_ablove_percent["Average_Difference"].values
        # logging.debug("above_percent is {}".format(above_percent_list))
        result = list(
            zip(above_counter_code_list, above_counter_names_list, above_percent_list)
        )
        filter_distname_dict = {filter_distname: result}
        if len(result) != 0:
            filter_distnames_list.append(filter_distname_dict)
    df_status = pd.read_excel(compare_report_path, sheet_name="ALL")
    df_out_of_range = df_status[df_status["Status"] == "out of range"]
    with pd.ExcelWriter(
        result_report_path,
        mode="a",
        engine="openpyxl",
        if_sheet_exists="replace",
    ) as writer:
        df_out_of_range.to_excel(writer, sheet_name="OUT OF RANGE", index=False)
    out_of_range_code_list = df_out_of_range["Code"].values
    out_of_range_names_list = df_out_of_range["Name"].values
    out_of_range_result = list(zip(out_of_range_code_list, out_of_range_names_list))
    out_of_range_dict = {"out of range": out_of_range_result}
    filter_distnames_list.append(out_of_range_dict)
    if is_fail_case:
        assert (
            len(out_of_range_result) == 0 or len(filter_distnames_list) == 0
        ), "ERRORS: KPIs out of range:{}\nERRORS:KPIs Average Difference is more than 5%:{}".format(
            out_of_range_result, filter_distnames_list
        )
    else:
        assert len(out_of_range_result) == 0, "ERRORS: KPIs out of range:{}\n".format(
            out_of_range_result
        )


def mkdir_p(sftp, remote_directory):
    """Change to this directory, recursively making new folders if needed.
    Returns True if any folders were created."""
    if remote_directory == "/":
        # absolute path so change directory to root
        sftp.chdir("/")
        return
    if remote_directory == "":
        # top-level relative directory must exist
        return
    try:
        sftp.chdir(remote_directory)  # sub-directory exists
    except IOError:
        dirname, basename = os.path.split(remote_directory.rstrip("/"))
        mkdir_p(sftp, dirname)  # make parent directories
        sftp.mkdir(basename)  # sub-directory missing, so created it
        sftp.chdir(basename)
        return True


def upload_files_to_remote_server(
    local_path, remote_path, hostname, username, password
):
    # Upload a file using SSH
    ssh_client = paramiko.SSHClient()
    ssh_client.set_missing_host_key_policy(paramiko.AutoAddPolicy())
    ssh_client.connect(hostname=hostname, username=username, password=password)
    sftp_client = ssh_client.open_sftp()
    remote_dir = "/".join(remote_path.split("/")[:-1])
    mkdir_p(sftp_client, remote_dir)
    sftp_client.put(local_path, remote_path)
    sftp_client.close()
    ssh_client.close()


def combine_multi_templates_kpi_report_result(output_excel, results_list):
    init_pandas()
    output_report_dir = "/".join(output_excel.split("/")[0:7])
    logging.debug("dir is {}".format(output_report_dir))
    if os.path.exists(output_report_dir):
        pass
    else:
        os.makedirs(os.path.dirname(output_excel))
    df_empty = pd.DataFrame()
    with pd.ExcelWriter(output_excel) as writer:
        # logging.debug("df is {}".format(df))
        df_empty.to_excel(
            writer,
            sheet_name="Chart Data",
            index=False,
            engine="xlsxwriter",
        )
    frames = []
    for result in results_list:
        wb = load_workbook(result, read_only=False)
        if "Chart Data" in wb.sheetnames:
            df = pd.read_excel(result, sheet_name="Chart Data")
            frames.append(df)
        else:
            logging.debug("chart name not found in {}".format(result))
            continue
    result = pd.concat(frames)
    newdf = result.drop_duplicates(
        subset=["DistName", "EntryName", "TimeStamp"], keep="last"
    )
    with pd.ExcelWriter(
        output_excel,
        mode="a",
        engine="openpyxl",
        if_sheet_exists="replace",
    ) as writer:
        newdf.to_excel(writer, sheet_name="Chart Data", index=False)
    # text_wrap_for_report(output_excel)
    return output_excel


def record_kpi_reports_for_all_templates(
    package_info,
    repcase_id,
    excel_report_path,
    output_report_path,
    filter_distnames=[],
):
    """
    author: stella.lin@nokia-sbell.com
    compare avg KPI data for 2 streams: for example avg_kpi_data from previous stream, avg_kpi_data after gnb upgrade.
    :param file_path: path of created file. If None file is created in robot logs path.
    :return: None
    """
    init_pandas()
    df_empty = pd.DataFrame()
    logging.debug("file is {}".format(output_report_path))
    output_report_dir = "/".join(output_report_path.split("/")[0:6])
    logging.debug("dir is {}".format(output_report_dir))
    if os.path.exists(output_report_path):
        pass
    else:
        if os.path.exists(output_report_dir):
            with pd.ExcelWriter(output_report_path) as writer:
                df_empty.to_excel(
                    writer,
                    sheet_name="bts",
                    index=False,
                    engine="xlsxwriter",
                )
        else:
            os.makedirs(os.path.dirname(output_report_path))
            with pd.ExcelWriter(output_report_path) as writer:
                df_empty.to_excel(
                    writer,
                    sheet_name="bts",
                    index=False,
                    engine="xlsxwriter",
                )
    df_details = pd.read_excel(excel_report_path, sheet_name="Chart Data")
    reproduce_kpi_values_dict = {}
    if repcase_id == "5605012":
        comment = "Comment. bts:NR_5101b>60,NECELL-301>70"
    else:
        comment = "Comment"
    for filter_distname in filter_distnames:
        logging.debug("start to record kpi data for {}".format(filter_distname))
        filter_df_with_dist_name = df_details[
            df_details.DistName.str.contains(filter_distname)
        ]
        counter_name_list_in_template = filter_df_with_dist_name["EntryName"].values
        counter_name_list_in_template = list(set(counter_name_list_in_template))
        wb = load_workbook(output_report_path, read_only=False)
        if filter_distname in wb.sheetnames:
            df_summary_orig = pd.read_excel(
                output_report_path, sheet_name=filter_distname
            )
            logging.debug("df_summary_orig is {}".format(df_summary_orig))
            if df_summary_orig.empty:
                logging.debug("DataFrame df_summary_orig is empty")
                counter_name_list_base = counter_name_list_in_template
                counter_name_list_add = []
            else:
                df_summary_orig = df_summary_orig.set_index(["Unnamed: 0"])
                # logging.debug("df_summary_orig is {}".format(df_summary_orig))
                logging.debug("DataFrame df_summary_orig already exist,start to add")
                counter_name_list_in_kpi_report = list(df_summary_orig.index.values)[1:]
                counter_name_list_base = counter_name_list_in_kpi_report
                counter_prefix_in_kpi_report = [
                    x.split("[")[-1].split("]")[0]
                    for x in counter_name_list_in_kpi_report
                ]
                # logging.debug(" counter_prefix_in_kpi_report is {}".format( counter_prefix_in_kpi_report))
                counter_name_list_add = [
                    x
                    for x in counter_name_list_in_template
                    if x not in counter_name_list_in_kpi_report
                ]
                logging.debug(
                    "counter_name_list_add origin is {}".format(counter_name_list_add)
                )
                counter_name_list_add_all = [
                    x
                    for x in counter_name_list_in_template
                    if x not in counter_name_list_in_kpi_report
                ]
                for add_item in counter_name_list_add_all:
                    add_couter_prefix = add_item.split("[")[-1].split("]")[0]
                    logging.debug("add_couter_prefix is {}".format(add_couter_prefix))
                    if add_couter_prefix in counter_prefix_in_kpi_report:
                        logging.debug(
                            "counter {} is renamed only, need remove from add list".format(
                                add_couter_prefix
                            )
                        )
                        counter_name_list_add.remove(add_item)
                logging.debug(
                    "counter_name_list_add after all removed renamed object is {}".format(
                        counter_name_list_add
                    )
                )
        else:
            wb.create_sheet(filter_distname)
            wb.save(output_report_path)
            df_summary_orig = pd.read_excel(
                output_report_path, sheet_name=filter_distname
            )
            counter_name_list_base = counter_name_list_in_template
            counter_name_list_add = []
        counter_name_list = counter_name_list_base + counter_name_list_add
        counter_values_list = []
        report_status = "VALID"
        check_kpi_list = []
        df_calculation = pd.read_excel(
            "/home/ute/KPI_Report/kpi_calculation_template.xlsx"
        )
        calculation_code = df_calculation["Code"].tolist()
        # logging.debug("calculation_code is {}".format(calculation_code))
        calculate_type = df_calculation["proposed to calculate"].tolist()
        # logging.debug("calculate_type is {}".format(calculate_type))
        for counter_name in counter_name_list:
            # couter_prefix = counter_name.split("[")[-1].split("]")[0]
            couter_prefix = re.findall(r"\[(\S+)\]", counter_name)[0]
            couter_name_prefix = counter_name.split("_Type")[0]
            if couter_prefix in calculation_code:
                index = calculation_code.index(couter_prefix)
                target_calculate_type = calculate_type[index]
                target_calculate_type = target_calculate_type.split(",")
                logging.debug(
                    "target_calculate_type for {} is {}".format(
                        couter_prefix, target_calculate_type
                    )
                )
                if len(target_calculate_type) >= 1:
                    for type in target_calculate_type:
                        new_name = couter_name_prefix + "_Type_{}".format(type)
                        if new_name not in counter_name_list:
                            counter_name_list.append(new_name)
        for counter_name in counter_name_list:
            couter_prefix = counter_name.split("[")[-1].split("]")[0]
            couter_name_length = counter_name.split("_Type")
            if len(couter_name_length) == 1:
                target_calculate_type = "sum"
            else:
                counter_type_single = couter_name_length[1].split("_")[1]
                target_calculate_type = counter_type_single
            # logging.debug("couter_prefix is{}".format(couter_prefix))
            filter_df_counter = filter_df_with_dist_name[
                filter_df_with_dist_name.EntryName.str.contains(couter_prefix)
            ]
            filter_df_counter = filter_df_counter.dropna(subset=["Value"])
            # logging.debug("filter_df_counter for {} is {}".format(couter_prefix,filter_df_counter))
            if filter_df_counter.empty:
                counter_sum = "Missed"
            else:
                if target_calculate_type == "sum":
                    counter_sum = filter_df_counter["Value"].sum(min_count=1)
                elif target_calculate_type == "avg":
                    counter_sum = filter_df_counter["Value"].mean()
                elif target_calculate_type == "min":
                    counter_sum = filter_df_counter["Value"].min()
                elif target_calculate_type == "max":
                    counter_sum = filter_df_counter["Value"].max()
                if isinstance(counter_sum, float):
                    counter_sum = round(counter_sum, 3)
            # logging.debug("sum for {} is {}".format(couter_prefix, counter_sum))
            if couter_prefix == "NR_5108e":
                logging.debug("start to deal with specfic kpi NR_5108e")
                filtered_df_remove_nan = filter_df_counter.dropna(subset=["Value"])
                if filtered_df_remove_nan.empty:
                    logging.debug("NR_5108e is NaN")
                    report_status = "INVALID"
                    counter_sum = filter_df_counter["Value"].sum(min_count=1)
                else:
                    filtered_df = filtered_df_remove_nan[
                        filter_df_counter["Value"].astype("float") > 10
                    ]
                    logging.debug(
                        "filtered_df NR_5108e value list is{}".format(filtered_df)
                    )
                    counter_sum = filtered_df["Value"].mean()
                    if isinstance(counter_sum, float):
                        counter_sum = round(counter_sum, 2)
            if couter_prefix == "NR_5666b":
                logging.debug("start to deal with specfic kpi UEs: NR_5666b")
                filtered_df_remove_nan = filter_df_counter.dropna(subset=["Value"])
                logging.debug("NR_5666b is {}".format(filtered_df_remove_nan))
                if filtered_df_remove_nan.empty:
                    logging.debug("NR_5666b is NaN(Empty)")
                    counter_sum = filter_df_counter["Value"].sum(min_count=1)
                else:
                    counter_sum = filtered_df_remove_nan["Value"].mean()
                    if isinstance(counter_sum, float):
                        counter_sum = round(counter_sum, 2)
                    logging.debug("Avaerage UEs is {}".format(counter_sum))
            counter_values_list.append(counter_sum)
            if (
                couter_prefix == "NR_5101b"
                or couter_prefix == "NR_5905a"
                or couter_prefix == "NR_5666b"
            ):
                check_kpi_info = "{}:{}".format(couter_prefix, counter_sum)
                check_kpi_list.append(check_kpi_info)
            if couter_prefix in REPRODUCE_KPI_NAME_LIST:
                if counter_sum != "Missed":
                    counter_sum = float(counter_sum)
                reproduce_kpi_values_dict[couter_prefix] = counter_sum
            if couter_prefix == "NR_5101b" and repcase_id == "5605012":
                logging.debug(
                    "start to deal with specfic kpi NR_5101b for {}".format(
                        filter_distname
                    )
                )
                if filter_distname == "bts":
                    expect_5101b = 36
                elif filter_distname == "NRCELL-301":
                    expect_5101b = 26
                else:
                    expect_5101b = 26
                filtered_remove_nan = filter_df_counter.dropna(subset=["Value"])
                if filtered_remove_nan.empty:
                    logging.debug("NR_5101b is NaN(Empty)")
                    report_status = "INVALID"
                else:
                    logging.debug("NR_5101b is {}".format(int(counter_sum)))
                    if int(counter_sum) >= expect_5101b:
                        logging.debug("NR_5101b is in range")
                        report_status = "VALID"
                    else:
                        logging.debug("NR_5101b is out of range")
                        report_status = "INVALID"
            if couter_prefix == "NR_5666b" and repcase_id == "5605005":
                logging.debug(
                    "start to deal with specfic kpi NR_5666b for {}".format(
                        filter_distname
                    )
                )
                expect_5666b = 5
                filtered_remove_nan = filter_df_counter.dropna(subset=["Value"])
                if filtered_remove_nan.empty:
                    logging.debug("NR_5666b is NaN(Empty)")
                    report_status = "INVALID"
                else:
                    logging.debug("NR_5666b is {}".format(int(counter_sum)))
                    if int(counter_sum) >= expect_5666b:
                        logging.debug("NR_5666b is in range")
                        report_status = "VALID"
                    else:
                        logging.debug("NR_5666b is out of range")
                        report_status = "INVALID"
        report_status = report_status + "\n" + str(check_kpi_list)
        counter_name_list.insert(0, comment)
        counter_values_list.insert(0, report_status)
        logging.debug("counter_name_list length is {}".format(len(counter_name_list)))
        logging.debug("counter value length is {}".format(len(counter_values_list)))
        df_summary_new = pd.DataFrame(
            {package_info: counter_values_list}, index=counter_name_list
        )
        # logging.debug("df_summary_new is {}".format(df_summary_new))
        df_summary_final = pd.concat([df_summary_new, df_summary_orig], axis=1)
        # logging.debug("df_summary_final is {}".format(df_summary_final))
        with pd.ExcelWriter(
            output_report_path, mode="a", engine="openpyxl", if_sheet_exists="replace"
        ) as writer:
            df_summary_final.to_excel(writer, sheet_name=filter_distname, index=True)
    text_wrap_for_report(output_report_path)
    return reproduce_kpi_values_dict


def text_wrap_for_report(file_path):
    wb = openpyxl.load_workbook(file_path)
    for sheet in wb.sheetnames:
        ws = wb[sheet]
        logging.debug("start to wrap text for sheet {}".format(sheet))
        for row in ws.iter_rows():
            for cell in row:
                cell.alignment = Alignment(wrap_text=True, vertical="top")
        for col in ws.iter_cols():
            for cell in col:
                cell.alignment = Alignment(wrap_text=True, vertical="top")
        wb.save(file_path)


def check_cpri_forwading_data(
    ru_log_path, output_report_path, lte_port_number=0, nr_port_number=1
):
    init_pandas()
    ru_log_name = ru_log_path.split("/")[-1]
    with gzip.open(ru_log_path, "rt") as file:
        data = file.read()
    # print("data is {}".format(data))
    lines = "".join(data.split("\n"))
    lines_split = lines.split("object_name: ")
    cpri_forwading_object_name = []
    cpri_forwading_class_name = []
    nokia_cpri_forwading_object_name = []
    nokia_cpri_forwading_class_name = []
    N_list = []
    delay_utu_list = []
    for object in lines_split:
        if "CpriForwardingOffsetsState" in object:
            object_name = object.split("class_name")[0].strip('"')
            cpri_forwading_object_name.append(object_name)
            class_name = object.split("[hlapi")[0].split("class_name: ")[1].strip('"')
            cpri_forwading_class_name.append(class_name)
            first_port_number = re.findall(r"first_port_number: (-?\d+)", object)
            second_port_number = re.findall(r"second_port_number: (-?\d+)", object)
            first_to_second_offset_utu = re.findall(
                r"first_to_second_offset_utu: (-?\d+)", object
            )
            second_to_first_offset_utu = re.findall(
                r"second_to_first_offset_utu: (-?\d+)", object
            )
        if "NokiaCpriForwardingState" in object:
            object_name = object.split("class_name")[0].strip('"')
            nokia_cpri_forwading_object_name.append(object_name)
            class_name = object.split("[hlapi")[0].split("class_name: ")[1].strip('"')
            nokia_cpri_forwading_class_name.append(class_name)
            N = re.findall(r"N: (-?\d+)", object)
            N_list.append(N[0])
            delay_utu = re.findall(r"delay_utu: (-?\d+)", object)
            delay_utu_list.append(delay_utu[0])
    delay_utu_with_N = [
        float(x[1]) - 320 * float(x[0]) for x in zip(N_list, delay_utu_list)
    ]
    lte_tx_utu = [
        x[2]
        for x in zip(
            first_port_number,
            second_port_number,
            first_to_second_offset_utu,
            second_to_first_offset_utu,
        )
        if int(x[0]) == int(lte_port_number) and int(x[1]) == 2
    ]
    lte_tx_utu = float(lte_tx_utu[0])
    lte_rx_utu = [
        x[3]
        for x in zip(
            first_port_number,
            second_port_number,
            first_to_second_offset_utu,
            second_to_first_offset_utu,
        )
        if int(x[0]) == int(lte_port_number) and int(x[1]) == 2
    ]
    lte_rx_utu = float(lte_rx_utu[0])
    nr_tx_utu = [
        x[2]
        for x in zip(
            first_port_number,
            second_port_number,
            first_to_second_offset_utu,
            second_to_first_offset_utu,
        )
        if int(x[0]) == int(nr_port_number) and int(x[1]) == 2
    ]
    nr_tx_utu = float(nr_tx_utu[0])
    nr_rx_utu = [
        x[3]
        for x in zip(
            first_port_number,
            second_port_number,
            first_to_second_offset_utu,
            second_to_first_offset_utu,
        )
        if int(x[0]) == int(nr_port_number) and int(x[1]) == 2
    ]
    nr_rx_utu = float(nr_rx_utu[0])
    print("lte_tx_ute is : {}".format(lte_tx_utu))
    print("lte_rx_ute is : {}".format(lte_rx_utu))
    print("nr_tx_ute is : {}".format(nr_tx_utu))
    print("nr_rx_ute is : {}".format(nr_rx_utu))
    utu_compare_result = []
    utu_compare_status = []
    for nokia_cpri_data in zip(nokia_cpri_forwading_object_name, delay_utu_with_N):
        if "TX" in nokia_cpri_data[0]:
            if nokia_cpri_data[0].startswith("L") or nokia_cpri_data[0].startswith("G"):
                compare_result = nokia_cpri_data[1] - lte_tx_utu
                if abs(compare_result) <= 6.0:
                    compare_status = "PASS"
                else:
                    compare_status = "FAIL"
            elif nokia_cpri_data[0].startswith("NR"):
                compare_result = nokia_cpri_data[1] - nr_tx_utu
                if abs(compare_result) <= 6.0:
                    compare_status = "PASS"
                else:
                    compare_status = "FAIL"
        elif "RX" in nokia_cpri_data[0]:
            if nokia_cpri_data[0].startswith("L") or nokia_cpri_data[0].startswith("G"):
                compare_result = nokia_cpri_data[1] - lte_rx_utu
                if abs(compare_result) <= 6.0:
                    compare_status = "PASS"
                else:
                    compare_status = "FAIL"
            elif nokia_cpri_data[0].startswith("NR"):
                compare_result = nokia_cpri_data[1] - nr_rx_utu
                if abs(compare_result) <= 6.0:
                    compare_status = "PASS"
                else:
                    compare_status = "FAIL"
        utu_compare_result.append(compare_result)
        utu_compare_status.append(compare_status)
    list_object_name = (
        cpri_forwading_object_name
        + [cpri_forwading_object_name[0]]
        * (len(first_port_number) - len(cpri_forwading_object_name))
        + nokia_cpri_forwading_object_name
    )
    print("list_object_name is {}".format(list_object_name))
    print(len(list_object_name))
    list_class_name = (
        cpri_forwading_class_name
        + [cpri_forwading_class_name[0]]
        * (len(first_port_number) - len(cpri_forwading_class_name))
        + nokia_cpri_forwading_class_name
    )
    print("list_class_name is {}".format(list_class_name))
    print(len(list_class_name))
    list_File = [ru_log_name] * len(list_class_name)
    print("list_File is {}".format(list_File))
    list_first_port_number = first_port_number + [""] * (
        len(list_class_name) - len(first_port_number)
    )
    print(list_first_port_number)
    list_second_port_number = second_port_number + [""] * (
        len(list_class_name) - len(second_port_number)
    )
    print(list_second_port_number)
    list_first_to_second_offset_utu = first_to_second_offset_utu + [""] * (
        len(list_class_name) - len(first_to_second_offset_utu)
    )
    print(list_first_to_second_offset_utu)
    list_second_to_first_offset_utu = second_to_first_offset_utu + [""] * (
        len(list_class_name) - len(second_to_first_offset_utu)
    )
    print(list_second_to_first_offset_utu)
    list_N_list = [""] * (len(list_class_name) - len(N_list)) + N_list
    print(list_N_list)
    list_delay_utu_list = [""] * (
        len(list_class_name) - len(delay_utu_list)
    ) + delay_utu_list
    print(list_delay_utu_list)
    list_delay_utu_with_N = [""] * (
        len(list_class_name) - len(delay_utu_with_N)
    ) + delay_utu_with_N
    print(list_delay_utu_with_N)
    list_utu_compare_result = [""] * (
        len(list_class_name) - len(utu_compare_result)
    ) + utu_compare_result
    print(list_utu_compare_result)
    list_utu_compare_status = [""] * (
        len(list_class_name) - len(utu_compare_status)
    ) + utu_compare_status
    print(list_utu_compare_status)
    list_comment = [
        "LTE:first_port_number is {}\n NR:first_port_number is {}".format(
            lte_port_number, nr_port_number
        )
    ] + [""] * (len(list_class_name) - 1)
    res = {
        "File": list_File,
        "object_name": list_object_name,
        "class_name": list_class_name,
        "first_port_number": list_first_port_number,
        "second_port_number": list_second_port_number,
        "first_to_second_offset_utu": list_first_to_second_offset_utu,
        "second_to_first_offset_utu": list_second_to_first_offset_utu,
        "N": list_N_list,
        "delay_utu": list_delay_utu_list,
        "delay_ute_with_N": list_delay_utu_with_N,
        "compare_result": list_utu_compare_result,
        "compare_status": list_utu_compare_status,
        "Comment": list_comment,
    }
    df_table = pd.DataFrame(data=res)
    with pd.ExcelWriter(output_report_path) as writer:
        df_table.to_excel(
            writer,
            sheet_name="result",
            index=False,
            engine="xlsxwriter",
        )
    text_wrap_for_report(output_report_path)
    assert (
        "FAIL" not in utu_compare_status
    ), "delay ute checking failed.\ndetails please see result file:\n{}\n".format(
        output_report_path
    )


def get_ru_hlapi_state_log_path(bts_prefix, serial_number, snapshot_path):
    file_name = "{}/snapshot_file_list.txt".format(snapshot_path)
    with open(file_name, "r") as file:
        data = file.read()
    res = re.findall(
        r"{}_{}_RMOD_.*_hlapi_state.log.gz".format(bts_prefix, serial_number), data
    )
    print("hlapi_file_name is {}".format(res))
    hlapi_file_name = res[0]
    lines = "".join(data.split("\n"))
    lines_split = lines.split(".zip:")
    # print(lines_split)
    print("hlapi_file_name is {}".format(hlapi_file_name))
    result = [
        index for (index, item) in enumerate(lines_split) if hlapi_file_name in item
    ]
    print(result)
    index = result[0] - 1
    context = lines_split[index]
    full_name = "BTS" + context.split("BTS")[-1] + ".zip"
    print(full_name)
    return hlapi_file_name, full_name


def get_first_port_number_for_lte_and_nr(cables_info_list, rmod_index=7):
    mrbts_id = tl.gnbs[0].instance_id
    rmod_second_end_point_if2 = "MRBTS-{}/EQM-1/APEQM-1/RMOD-{}/OPT_IF2".format(
        mrbts_id, rmod_index
    )
    rmod_second_end_point_if1 = "MRBTS-{}/EQM-1/APEQM-1/RMOD-{}/OPT_IF1".format(
        mrbts_id, rmod_index
    )
    if2_filter_list = [
        x
        for x in cables_info_list
        if x["secondEndPointId"]["configuration"] == rmod_second_end_point_if2
    ]
    if1_filter_list = [
        x
        for x in cables_info_list
        if x["secondEndPointId"]["configuration"] == rmod_second_end_point_if1
    ]
    print("IF2_info is {}".format(if2_filter_list))
    print("IF1_info is {}".format(if1_filter_list))
    if2_synchronization_status = if2_filter_list[0]["linkMode"]["synchronization"]
    if2_firstEndPointId = if2_filter_list[0]["firstEndPointId"]["internal"]
    if1_synchronization_status = if1_filter_list[0]["linkMode"]["synchronization"]
    if1_firstEndPointId = if1_filter_list[0]["firstEndPointId"]["internal"]
    if if1_synchronization_status:
        primary_link = "OPT_IF1"
        if "BBMOD" in if1_firstEndPointId:
            device = "NR"
            nr_first_port_number = "0"
            lte_first_port_number = "1"
        elif "SMOD_EXT" in if1_firstEndPointId:
            device = "LTE"
            lte_first_port_number = "0"
            nr_first_port_number = "1"
    elif if2_synchronization_status:
        primary_link = "OPT_IF2"
        if "BBMOD" in if2_firstEndPointId:
            device = "NR"
            nr_first_port_number = "1"
            lte_first_port_number = "0"
        elif "SMOD_EXT" in if2_firstEndPointId:
            device = "LTE"
            lte_first_port_number = "1"
            nr_first_port_number = "0"
    print("primary link is {}, on {} side".format(primary_link, device))
    print(
        "lte_firs_port_number is {},nr_first_port_number is {}".format(
            lte_first_port_number, nr_first_port_number
        )
    )
    return lte_first_port_number, nr_first_port_number


def get_8150_pci_list_from_alarm_details(alarm_info_list):
    filter_8150_info = [x for x in alarm_info_list if x["faultId"] == 8150]
    print("8150 alarm is {}".format(filter_8150_info))
    assert len(filter_8150_info) != 0, "ERRORS: fault 8150 is not triggerd\n"
    detail_8150_info = filter_8150_info[0]["alarmText"]["alarmAdditionalInfo"][
        "supplAlarmInfo"
    ]
    pci_list = re.findall(r"NR-PCI = (\d+)", detail_8150_info)
    print("pci_list in alarm details is {}".format(pci_list))
    return pci_list


def verify_8150_cancelled(alarm_info_list):
    filter_8150_info = [x for x in alarm_info_list if x["faultId"] == 8150]
    assert len(filter_8150_info) == 0, "ERRORS: fault 8150 is not cancelled\n"


def get_ipv6_addr_from_ipconfig(output):
    lines = "".join(output.split("\n"))
    lines_split = lines.split("rmnet_data1 Link encap:UNSPEC")
    ipv6_addr = re.findall(r"inet6 addr: (\S+)/64 Scope: Global", lines_split[-1])
    print(ipv6_addr)
    return ipv6_addr[0]


def generate_modified_params_bwp(
    testcount=1, excel_path="/home/ute/BWP/Auto_test_input.xlsx", release="SBTS00"
):
    testcount = int(testcount)
    testcount = round(testcount, 1)
    logging.debug("testcount_is:{}".format(testcount))
    init_pandas()
    df_details = pd.read_excel(
        excel_path,
        sheet_name="input",
    )
    testcount_list = df_details["TestCount"].values
    # testcount_list = [int(x) for x in testcount_list]
    filter_df_with_testcount = df_details[df_details["TestCount"] == testcount]
    logging.debug("filter_df_with_testcount_is:{}".format(filter_df_with_testcount))
    filter_df_with_Category_Parameter = filter_df_with_testcount[
        filter_df_with_testcount.Category.str.contains("Parameter")
    ]
    logging.debug(
        "filter_df_with_Category_is:{}".format(filter_df_with_Category_Parameter)
    )
    filter_df_without_List_Name_cellBwpList = filter_df_with_Category_Parameter[
        ~filter_df_with_Category_Parameter.List_Name.str.contains(
            "cellBwpList", na=False
        )
    ]
    filter_df_with_List_Name_cellBwpList = filter_df_with_Category_Parameter[
        filter_df_with_Category_Parameter.List_Name.str.contains(
            "cellBwpList", na=False
        )
    ]
    logging.debug(
        "filter_df_without_cellBwpList_is:{}".format(
            filter_df_without_List_Name_cellBwpList
        )
    )
    logging.debug(
        "filter_df_with_cellBwpList_is:{}".format(filter_df_with_List_Name_cellBwpList)
    )
    mo_dn_list = filter_df_without_List_Name_cellBwpList["MO_DN"].values
    bwp_mo_dn_list = filter_df_with_List_Name_cellBwpList["MO_DN"].values
    bwp_mo_dn_list_remove_copy = list(set(bwp_mo_dn_list))
    mo_dn_list_remove_copy = list(set(mo_dn_list))
    logging.debug("mo dn under cellBwpList is {}".format(bwp_mo_dn_list_remove_copy))
    logging.debug("mo dn is {}".format(mo_dn_list_remove_copy))
    mrbts_id = "MRBTS-{}".format(tl.gnbs[0].instance_id)
    nrbts_id = "NRBTS-{}".format(tl.gnbs[0].global_bts_id)
    bts_id_prefix = mrbts_id + "/" + nrbts_id + "/"
    delete_param_delta = []
    added_params_delta = []
    bwp_diff_list = []
    update_params_delta = []
    for mo_dn in mo_dn_list_remove_copy:
        mo_distname = bts_id_prefix + mo_dn
        logging.debug("start to filter {}".format(mo_dn))
        filter_with_mo_dn = filter_df_without_List_Name_cellBwpList[
            filter_df_without_List_Name_cellBwpList["MO_DN"] == mo_dn
        ]
        logging.debug("filter param tyeo is PARAMS")
        filter_with_type_params = filter_with_mo_dn[
            filter_with_mo_dn["Parameters_Type"] == "PARAMS"
        ]
        logging.debug(
            "params df for {} is {}".format(mo_distname, filter_with_type_params)
        )
        params_list = filter_with_type_params["Parameters_Name"].values
        params_new_values_list = filter_with_type_params["Parameters_Value"].values
        logging.debug("filter param type is LIST_PARAMS")
        filter_with_type_list_params = filter_with_mo_dn[
            filter_with_mo_dn.Parameters_Type.str.contains("LIST_PARAMS")
        ]
        logging.debug("start to generate PARAMS context")
        params_zip = list(
            zip(
                params_list,
                params_new_values_list,
            )
        )
        for parameters in params_zip:
            param_name = parameters[0]
            logging.debug("param is{}oo".format(param_name))
            if param_name not in BOOLEAN_PARMS:
                if parameters[1] is True:
                    param_actual_value = "1"
                elif parameters[1] is False:
                    param_actual_value = "0"
                elif param_name in {
                    "cSRS",
                    "bSRS",
                }:  # Use a set for faster membership checks
                    logging.debug("Entering parameter: {}".format(param_name))
                    param_actual_value = str(parameters[1])
                    logging.debug("Parameter type: {}".format(type(param_actual_value)))
                elif isinstance(parameters[1], str):
                    parameters = list(parameters)
                    if "Mhz" in parameters[1]:
                        parameters[1] = parameters[1].replace(
                            "Mhz", "MHz"
                        )  # Fix reassignment
                    if release == "25R3" and parameters[1] == "70MHz":
                        logging.debug("special MHZ for 25R3")
                        parameters[1] = "70 MHz"
                    param_actual_value = parameters[1]  # Assign the modified string
                else:
                    param_actual_value = parameters[
                        1
                    ]  # Default case for non-boolean, non-string
            else:
                param_actual_value = parameters[
                    1
                ]  # Case where param_name is in BOOLEAN_PARMS
            logging.debug(
                "parameter name is{},value is {}".format(param_name, param_actual_value)
            )
            params_dict = {
                "dist_name": mo_distname,
                "parameter": parameters[0],
                "value": param_actual_value,
            }
            update_params_delta.append(params_dict)
        logging.debug("start to generate LIST PARAMS context")
        list_name_list = filter_with_type_list_params["List_Name"].values
        list_name_list_remove_copy = list(set(list_name_list))
        for name in list_name_list_remove_copy:
            filter_with_name_df = filter_with_type_list_params[
                filter_with_type_list_params.List_Name.str.contains(name)
            ]
            logging.debug(
                "list_params df for {} is {}".format(name, filter_with_name_df)
            )
            # filter_with_name_df = filter_with_type_list_params[
            #     filter_with_type_list_params["List_Name"]==name
            # ]
            list_params_list = filter_with_name_df["Parameters_Name"].values
            list_params_new_values_list = filter_with_name_df["Parameters_Value"].values
            logging.debug("start to generate LIST_PARAMS context")
            list_params_zip = list(
                zip(
                    list_params_list,
                    list_params_new_values_list,
                )
            )
            list_params_values_total = []
            value_dict = {}
            value_list = []
            special_params = False
            for parameters in list_params_zip:
                param_name = parameters[0]
                logging.debug("param is{}oo".format(param_name))
                if param_name not in BOOLEAN_PARMS:
                    if parameters[1] is True:
                        param_actual_value = "1"
                    elif parameters[1] is False:
                        param_actual_value = "0"
                    elif param_name == "cSRS" or param_name == "bSRS":
                        logging.debug("enter to param {}".format(param_name))
                        param_actual_value = str(parameters[1])
                        logging.debug(
                            " param type is {}".format(type(param_actual_value))
                        )
                    else:
                        param_actual_value = parameters[1]
                else:
                    param_actual_value = parameters[1]
                logging.debug(
                    "parameter name is{},value is {}".format(
                        param_name, param_actual_value
                    )
                )
                try:
                    if math.isnan(param_name):
                        logging.debug("parameter value is{}".format(parameters[1]))
                        value_list.append(str(param_actual_value))
                        special_params = True
                    else:
                        value_dict[parameters[0]] = param_actual_value
                except Exception as e:
                    value_dict[parameters[0]] = param_actual_value
            if special_params:
                list_params_values_total = value_list
            else:
                list_params_values_total.append(value_dict)
            logging.debug(mo_distname)
            logging.debug("dict for {} is {}".format(param_name, value_dict))
            logging.debug(
                "list is{},dict is {} for {}".format(
                    list_params_values_total, value_dict, name
                )
            )
            list_params_dict = {
                "dist_name": mo_distname,
                "parameter": name,
                "value": list_params_values_total,
            }
            update_params_delta.append(list_params_dict)
    logging.debug("start to generate bwp params")
    for bwp_mo_dn in bwp_mo_dn_list_remove_copy:
        bwp_distname = bts_id_prefix + bwp_mo_dn
        logging.debug("start to filter {}".format(bwp_mo_dn))
        original_bwp_id_list = get_original_bwpid(dist_name=bwp_distname)
        original_bwp_id_list = [x["cellBwpId"] for x in original_bwp_id_list]
        logging.debug(
            "original bwp_list_for {} is {}".format(bwp_distname, original_bwp_id_list)
        )
        cellBwpList_del_dict = {
            "dist_name": bwp_distname,
            "parameter": "cellBwpList",
        }
        delete_param_delta.append(cellBwpList_del_dict)
        filter_bwp_with_mo_dn = filter_df_with_List_Name_cellBwpList[
            filter_df_with_List_Name_cellBwpList.MO_DN.str.contains(bwp_mo_dn)
        ]
        bwp_list_index = filter_bwp_with_mo_dn["List_Index"].values
        bwp_list_index = list(set(bwp_list_index))
        bwp_list_index_int = [int(x) for x in bwp_list_index]
        bwp_list_index_str = [str(x) for x in bwp_list_index_int]
        logging.debug("bwp index for {} is {}".format(bwp_distname, bwp_list_index))
        logging.debug(
            "int bwp index for {} is {}".format(bwp_distname, bwp_list_index_str)
        )
        if len(original_bwp_id_list) > len(bwp_list_index_str):
            diff_bwp_id = list(set(original_bwp_id_list) - set(bwp_list_index_str))
            for id in diff_bwp_id:
                bwp_diff_dict = {}
                bwp_diff_dict[bwp_distname] = id
                bwp_diff_list.append(bwp_diff_dict)
                logging.debug("bwp_diff_list is {}".format(bwp_diff_list))
        bwp_dn_value_list = []
        for bwp_index in bwp_list_index:
            filter_with_index = filter_bwp_with_mo_dn[
                filter_bwp_with_mo_dn["List_Index"] == bwp_index
            ]
            bwp_param_name = filter_with_index["Parameters_Name"].values
            bwp_param_value = filter_with_index["Parameters_Value"].values
            value_dict = dict(zip(bwp_param_name, bwp_param_value))
            logging.debug(
                "value for bwp dn {} index {} is {}".format(
                    bwp_distname, bwp_index, value_dict
                )
            )
            bwp_dn_value_list.append(value_dict)
        cellBwpList_add_dict = {
            "dist_name": bwp_distname,
            "parameter": "cellBwpList",
            "value": bwp_dn_value_list,
        }
        added_params_delta.append(cellBwpList_add_dict)
    logging.debug("update_params_delta is {}".format(update_params_delta))
    logging.debug("added_params_delta is {}".format(added_params_delta))
    logging.debug("delete_params_delta is {}".format(delete_param_delta))
    return update_params_delta, delete_param_delta, added_params_delta, bwp_diff_list


def merge_JsonFiles(filename, output_file_path):
    result = list()
    for f1 in filename:
        with open(f1, "r") as infile:
            result.extend(json.load(infile))
    with open(output_file_path, "w") as output_file:
        json.dump(result, output_file)
    return output_file_path


def get_latest_err_file(folder_path):
    """
    Find the most recently created file and folder in the root of the given folder.

    Args:
        folder_path (str): Path to the folder.

    Returns:
        tuple: A tuple containing the name of the most recently created file and folder,
               or (None, None) if no files or folders are found.
    """
    try:
        # List all files and folders in the root of the folder
        files = [
            os.path.join(folder_path, f)
            for f in os.listdir(folder_path)
            if os.path.isfile(os.path.join(folder_path, f))
        ]
        folders = [
            os.path.join(folder_path, f)
            for f in os.listdir(folder_path)
            if os.path.isdir(os.path.join(folder_path, f))
        ]

        # Find the latest file and folder
        latest_file = max(files, key=os.path.getctime) if files else None
        latest_folder = max(folders, key=os.path.getctime) if folders else None

        # Return the names of the latest file and folder
        return (
            os.path.basename(latest_file) if latest_file else None,
            os.path.basename(latest_folder) if latest_folder else None,
        )
    except Exception as e:
        print(f"Error finding the latest file or folder: {e}")
        return None, None


def get_snapshot_zip_file_path(err_file_path):
    init_pandas()
    wb = load_workbook(err_file_path, read_only=False)
    if "RF_ERR_WRN_Differ" in wb.sheetnames:
        df_rf_err = pd.read_excel(err_file_path, sheet_name="RF_ERR_WRN_Differ")
        rf_log_path = df_rf_err["Log_Name"].values[0]
        rf_log_path_prefix = "/".join(rf_log_path.split("/")[0:10]).split("'")[1]
        rf_log_zip_path = rf_log_path_prefix + ".zip"
        logging.debug("rf_log_path is {}".format(rf_log_zip_path))
        return rf_log_zip_path
    else:
        logging.debug("RF_ERR_WRN_Differ sheet is not generated")
        return None


def copy_xlsx_file(source_file, destination_folder):
    """
    Copy an .xlsx file to the specified destination folder.

    Args:
        source_file (str): Path to the source .xlsx file.
        destination_folder (str): Path to the destination folder.

    Returns:
        str: Path to the copied file, or None if the operation fails.
    """
    try:
        # Ensure the source file is an .xlsx file
        if not source_file.endswith(".xlsx"):
            print("The source file is not an .xlsx file.")
            return None

        # Ensure the destination folder exists
        os.makedirs(destination_folder, exist_ok=True)

        # Copy the file
        destination_file = shutil.copy(source_file, destination_folder)
        print(f"File copied successfully to: {destination_file}")
        return destination_file
    except Exception as e:
        print(f"Error copying the file: {e}")
        return None


def get_timestamp_for_err_log(file_path, err_context):
    """
    Extract all timestamps of the given error from a file.

    Args:
        file_path (str): Path to the file to search.
        err_context (str): The error context to search for.

    Returns:
        list: A list of timestamps of the error occurrences, or an empty list if not found.
    """
    timestamps = []
    try:
        with open(file_path, "r", encoding="utf-8", errors="replace") as file:
            for line in file:
                if err_context in line:
                    matches = re.findall(r"<(.*?)>", line)
                    if matches:
                        timestamps.extend(matches)
    except Exception as e:
        print(f"Error reading file {file_path}: {e}")
    return timestamps


def filter_result_without_warn(err_file_path):
    init_pandas()
    err_file_folder = "/".join(err_file_path.split("/")[0:-1])
    err_file_name = err_file_path.split("/")[-1]
    err_file_name_prefix = err_file_name.split(".xlsx")[0]
    logging.debug("err file is {}".format(err_file_folder))
    new_err_file_folder = err_file_folder + "/{}".format(err_file_name_prefix)
    logging.debug("new_err file is {}".format(new_err_file_folder))
    dir_name = os.path.dirname(new_err_file_folder)
    if not os.path.exists(dir_name):
        os.makedirs(dir_name)
    copy_xlsx_file(source_file=err_file_path, destination_folder=new_err_file_folder)
    new_err_file_path = os.path.join(new_err_file_folder, err_file_name)
    logging.debug("new_err_file_path is {}".format(new_err_file_path))
    rf_check_err_status = True
    bts_check_err_status = True
    wb = load_workbook(err_file_path, read_only=False)
    bts_err_print = []
    rf_err_print = []
    if "RF_ERR_WRN_Differ" in wb.sheetnames:
        df_rf_err = pd.read_excel(err_file_path, sheet_name="RF_ERR_WRN_Differ")
        logging.debug("start to filter RF err log")
        filter_df_with_err = df_rf_err[df_rf_err.Log_Level.str.contains("ERR")]
        filter_df_with_err = filter_df_with_err[
            filter_df_with_err.Status.str.contains("New")
        ]
        if filter_df_with_err.empty:
            rf_check_err_status = True
        else:
            # SN_values = filter_df_with_err["SN"].values
            # Component_values = filter_df_with_err["Component"].values
            # Description_values = filter_df_with_err["Description"].values
            new_df_rf_err = pd.read_excel(
                new_err_file_path, sheet_name="RF_ERR_WRN_Differ"
            )
            new_df_rf_err_filter = new_df_rf_err[
                new_df_rf_err.Log_Level.str.contains("ERR")
            ]
            new_df_rf_err_filter_with_status = new_df_rf_err_filter[
                new_df_rf_err_filter.Status.str.contains("New")
            ]
            Description_values = new_df_rf_err_filter_with_status["Description"].values
            Log_Name_values = new_df_rf_err_filter_with_status["Log_Name"].values
            SN_values = new_df_rf_err_filter_with_status["SN"].values
            Component_values = new_df_rf_err_filter_with_status["Component"].values
            # logging.debug("Description_values {}".format(Description_values))
            # logging.debug("Log_Name_values {}".format(Log_Name_values))
            logging.debug(len(Description_values))
            logging.debug(len(Log_Name_values))
            column_timestamp = []
            for index in range(len(Description_values)):
                logging.debug("start to get ERR-{} timestamp".format(index))
                Description = Description_values[index]
                Log_Name = Log_Name_values[index].split("'")[1]
                SN = SN_values[index]
                Component = Component_values[index]
                logging.debug("Description is {}".format(Description))
                logging.debug("Log_Name is {}".format(Log_Name))
                err_timestamps = get_timestamp_for_err_log(
                    file_path=Log_Name, err_context=Description
                )
                logging.debug("err_timestamps is {}".format(err_timestamps))
                column_timestamp.append(err_timestamps)
                rf_err_info = (
                    str(err_timestamps)
                    + " "
                    + str(SN)
                    + " "
                    + str(Component)
                    + " "
                    + str(Description)
                    + "\n"
                )
                valid_status = True
                for pattern in RF_ERR_WHITE_LIST:
                    if pattern in rf_err_info:
                        valid_status = False
                if valid_status:
                    rf_err_print.append(rf_err_info)
            logging.debug("rf_err_print is  {}".format(rf_err_print))
            if len(rf_err_print) == 0:
                rf_check_err_status = True
            else:
                rf_check_err_status = False
            new_df_rf_err_filter_with_status["rf_err_timestamps"] = column_timestamp
            with pd.ExcelWriter(
                new_err_file_path,
                mode="a",
                engine="openpyxl",
                if_sheet_exists="replace",
            ) as writer:
                new_df_rf_err_filter_with_status.to_excel(
                    writer, sheet_name="RF_NEW_ERR", index=True
                )
    if "ERR_WRN_Differ" in wb.sheetnames:
        df_bts_err = pd.read_excel(err_file_path, sheet_name="ERR_WRN_Differ")
        logging.debug("start to filter bts err log")
        filter_df_with_err = df_bts_err[df_bts_err.Log_Level.str.contains("ERR")]
        filter_df_with_err_new = filter_df_with_err[
            filter_df_with_err.Status.str.contains("New")
        ]
        if filter_df_with_err_new.empty:
            bts_check_err_status = True
        else:
            new_df_bts_err = pd.read_excel(
                new_err_file_path, sheet_name="ERR_WRN_Differ"
            )
            new_df_bts_err_filter = new_df_bts_err[
                new_df_bts_err.Log_Level.str.contains("ERR")
            ]
            new_df_bts_err_filter_with_status = new_df_bts_err_filter[
                new_df_bts_err_filter.Status.str.contains("New")
            ]
            Description_values = new_df_bts_err_filter_with_status["Description"].values
            Process_values = new_df_bts_err_filter_with_status["Process"].values
            Component_values = new_df_bts_err_filter_with_status["Component"].values
            for index in range(len(Description_values)):
                logging.debug("start to get SYSLOG ERR-".format(index))
                Description = Description_values[index]
                Process = Process_values[index]
                Component = Component_values[index]
                bts_err_info = (
                    str(Component) + " " + str(Process) + " " + str(Description) + "\n"
                )
                valid_status = True
                for pattern in SYSLOG_ERR_WHITE_LIST:
                    if pattern in bts_err_info:
                        valid_status = False
                if valid_status:
                    bts_err_print.append(bts_err_info)
            logging.debug("bts_err_print is  {}".format(bts_err_print))
            if len(bts_err_print) == 0:
                bts_check_err_status = True
            else:
                bts_check_err_status = False
    return rf_check_err_status, bts_check_err_status, rf_err_print, bts_err_print


def print_err(err_info_list):
    err_info = "ERR INFO:\n" + "\n".join(err_info_list)
    return err_info
    # try:
    #
    #     raise Exception("ERR INFO:\n" + "\n".join(err_info_list))
    # except Exception as e:
    #     print(e)


def get_original_bwpid(dist_name, connection="GNB_OAM"):
    try:
        bwpid_list_param = [
            dict(
                dist_name=dist_name,
                parameter="cellBwpList",
                value=[
                    dict(cellBwpId=None),
                    dict(cellBwpId=None),
                    dict(cellBwpId=None),
                    dict(cellBwpId=None),
                    dict(cellBwpId=None),
                ],
            )
        ]
        cellBwpList = coam_parameter.get_list_values_from_scf_file(
            parameters=bwpid_list_param,
            timeout=600,
            connection=connection,
        )
    except IndexError:
        try:
            bwpid_list_param = [
                dict(
                    dist_name=dist_name,
                    parameter="cellBwpList",
                    value=[
                        dict(cellBwpId=None),
                        dict(cellBwpId=None),
                        dict(cellBwpId=None),
                        dict(cellBwpId=None),
                    ],
                )
            ]
            cellBwpList = coam_parameter.get_list_values_from_scf_file(
                parameters=bwpid_list_param, timeout=600, connection=connection
            )
        except Exception:
            try:
                bwpid_list_param = [
                    dict(
                        dist_name=dist_name,
                        parameter="cellBwpList",
                        value=[
                            dict(cellBwpId=None),
                            dict(cellBwpId=None),
                            dict(cellBwpId=None),
                        ],
                    )
                ]
                cellBwpList = coam_parameter.get_list_values_from_scf_file(
                    parameters=bwpid_list_param, timeout=600, connection=connection
                )
            except Exception:
                bwpid_list_param = [
                    dict(
                        dist_name=dist_name,
                        parameter="cellBwpList",
                        value=[dict(cellBwpId=None), dict(cellBwpId=None)],
                    )
                ]
                cellBwpList = coam_parameter.get_list_values_from_scf_file(
                    parameters=bwpid_list_param, timeout=600, connection=connection
                )
    logging.debug("cellBwpList is {} for cell {} ".format(cellBwpList, dist_name))
    return cellBwpList[0]["value"]


def process_json(json_file, output_file, deleted_file, distname_cellbwpid_list):
    """
    Remove objects in the 'value' list under the given 'distName' that match the specified 'cellBwpId',
    and save the removed objects into a separate JSON file with the 'operation' field set to 'delete'.

    Args:
        json_file (str): Path to the input JSON file.
        output_file (str): Path to save the modified JSON file.
        deleted_file (str): Path to save the deleted JSON file.
        distname_cellbwpid_list: A list of dictionaries where each dictionary contains a 'distName' and 'cellBwpId'.

    Returns:
        None
    """
    try:
        # Load JSON data from file
        with open(json_file, "r", encoding="utf-8") as file:
            data = json.load(file)
        # List to store deleted items
        deleted_items = []
        # Iterate through the JSON data
        for item in data:
            # Check if the current item's 'distName' matches any in the input list
            for entry in distname_cellbwpid_list:
                distname = list(entry.keys())[0]
                cell_bwp_id = entry[distname]

                if item.get("distName") == distname:
                    # Iterate through the parameters
                    for param in item.get("parameters", []):
                        if param.get("parameterName") == "cellBwpList":
                            # Find and remove objects with matching 'cellBwpId'
                            to_delete = [
                                v
                                for v in param.get("value", [])
                                if v.get("cellBwpId") == cell_bwp_id
                            ]

                            # Add deleted items to the deleted_items list
                            if to_delete:
                                deleted_item = {
                                    "distName": item["distName"],
                                    "operation": "delete",
                                    "parameters": [
                                        {
                                            "parameterName": param["parameterName"],
                                            "value": to_delete,
                                        }
                                    ],
                                }
                                deleted_items.append(deleted_item)

                            # Remove the matching items from the original JSON
                            param["value"] = [
                                v
                                for v in param.get("value", [])
                                if v.get("cellBwpId") != cell_bwp_id
                            ]
        # Save the modified JSON data back to the output file
        with open(output_file, "w", encoding="utf-8") as file:
            json.dump(data, file, indent=4, ensure_ascii=False)

        # Save the deleted items to a separate JSON file
        with open(deleted_file, "w", encoding="utf-8") as file:
            json.dump(deleted_items, file, indent=4, ensure_ascii=False)

        print(f"Modified JSON saved to {output_file}")
        print(f"Deleted items saved to {deleted_file}")

    except Exception as e:
        print(f"Error processing JSON file: {e}")


def create_kpi_report_directories(base_path, subdirs):
    """
    :param base_path:
    :param subdirs:
    """
    full_path = os.path.join(base_path, subdirs)
    os.makedirs(full_path, exist_ok=True)
    print(f"Directories created or already exist: {full_path}")
    return full_path


def create_and_append_all_results_to_excel(single_file_path, all_file_path):
    init_pandas()
    # Read the single.xlsx file
    single_df = pd.read_excel(single_file_path)
    # Check if ALL.xlsx exists
    if os.path.exists(all_file_path):
        # If it exists, read the ALL.xlsx file
        all_df = pd.read_excel(all_file_path, sheet_name="KPI Report")
        kpi_mapping = dict(zip(all_df["Code"], all_df["KPI Name"]))
        # Update df1's 'KPI Name' where 'Code' matches
        single_df["KPI Name"] = single_df["Code"].map(
            lambda code: kpi_mapping.get(
                code, single_df.loc[single_df["Code"] == code, "KPI Name"].values[0]
            )
        )
        kpi_mapping = dict(zip(all_df["Code"], all_df["Group Name"]))
        # Update df1's 'KPI Name' where 'Code' matches
        single_df["Group Name"] = single_df["Code"].map(
            lambda code: kpi_mapping.get(
                code, single_df.loc[single_df["Code"] == code, "Group Name"].values[0]
            )
        )
        # Merge df1 and df2 on 'Code', 'Group Name', 'KPI Name' with outer join
        if "Group Name" in single_df.columns:
            on_list = ["Group Name", "Code", "KPI Name"]
        else:
            on_list = ["Code", "KPI Name"]
        combined_df = pd.merge(single_df, all_df, on=on_list, how="outer")
        # Fill NaN values with empty strings or 0 (optional, based on your needs)
        combined_df.fillna("", inplace=True)
    else:
        # If it does not exist, directly use single_df
        combined_df = single_df
    # Write the merged data to the ALL.xlsx file with sheet name "KPI Report"
    with pd.ExcelWriter(all_file_path, engine="openpyxl", mode="w") as writer:
        combined_df.to_excel(writer, sheet_name="KPI Report", index=False)
    print(f"Data has been successfully appended to {all_file_path}!")
    wb = load_workbook(all_file_path)
    ws = wb["KPI Report"]

    header_fill = PatternFill(
        start_color="87CEEB", end_color="87CEEB", fill_type="solid"
    )
    header_font = Font(color="FFFFFF", bold=True)
    header_alignment = Alignment(horizontal="left", vertical="center", wrap_text=True)

    for cell in ws[1]:
        cell.fill = header_fill
        cell.font = header_font
        cell.alignment = header_alignment

    for row in ws.iter_rows(min_row=2):
        for cell in row:
            cell.alignment = Alignment(
                horizontal="left", vertical="center", wrap_text=True
            )
    ws.column_dimensions["A"].width = 34
    ws.column_dimensions["B"].width = 16
    ws.column_dimensions["C"].width = 53

    for col in ws.iter_cols(min_col=4, max_col=ws.max_column):
        col_letter = col[0].column_letter
        ws.column_dimensions[col_letter].width = 18
    ws.row_dimensions[1].height = 83
    for row in range(2, ws.max_row + 1):
        ws.row_dimensions[row].height = 31
    calibri_font = Font(name="Calibri", size=10)
    for row in ws.iter_rows(
        min_row=1, max_row=ws.max_row, min_col=1, max_col=ws.max_column
    ):
        for cell in row:
            cell.font = calibri_font
    wb.save(all_file_path)


def create_remote_dir(sftp, remote_directory):
    """
    Create a remote directory if it does not exist.
    """
    try:
        sftp.stat(remote_directory)  # Check if the directory exists
    except FileNotFoundError:
        # If the directory does not exist, recursively create parent directories
        parent_dir = os.path.dirname(remote_directory)
        create_remote_dir(sftp, parent_dir)
        sftp.mkdir(remote_directory)
        print(f"Created remote directory: {remote_directory}")


def copy_local_to_remote(local_path, remote_path, hostname, username, password):
    """
    Use SFTP to copy all files and directories from a local path to a remote server.
    If the remote directory does not exist, create it first.
    """
    # Create an SSH client
    ssh = paramiko.SSHClient()
    ssh.set_missing_host_key_policy(paramiko.AutoAddPolicy())
    ssh.connect(hostname, username=username, password=password)
    # Create an SFTP client
    sftp = ssh.open_sftp()
    # Traverse the local directory
    for root, dirs, files in os.walk(local_path):
        # Calculate the remote directory path
        relative_path = os.path.relpath(root, local_path)
        remote_dir = os.path.join(remote_path, relative_path).replace("\\", "/")
        # Create the remote directory if it does not exist
        create_remote_dir(sftp, remote_dir)
        # Upload files
        for file in files:
            local_file = os.path.join(root, file)
            remote_file = os.path.join(remote_dir, file).replace("\\", "/")
            sftp.put(local_file, remote_file)
            print(f"Copied {local_file} to {remote_file}")
    # Close the SFTP and SSH connections
    sftp.close()
    ssh.close()
    print("All files copied successfully.")


def split_intervals(intervals, delta_minutes=30):
    result = []
    for start_str, end_str in intervals:
        start = datetime.strptime(start_str, "%Y-%m-%d %H:%M:%S")
        end = datetime.strptime(end_str, "%Y-%m-%d %H:%M:%S")
        current = start
        while current < end:
            next_time = min(current + timedelta(minutes=delta_minutes), end)
            # Only add the interval if its duration is at least delta_minutes
            if (next_time - current).total_seconds() >= delta_minutes * 60:
                result.append(
                    [
                        current.strftime("%Y-%m-%d %H:%M:%S"),
                        next_time.strftime("%Y-%m-%d %H:%M:%S"),
                    ]
                )
            current = next_time
    return result


def get_kpi_values_rows_by_code_name(file_path, code_name):
    """ """
    init_pandas()
    # Filter rows based on the column value
    df = pd.read_excel(file_path)
    filtered_rows = df[df["Code"] == code_name]
    # Convert the filtered rows to a list of dictionaries
    return filtered_rows.to_dict(orient="records")


def ensure_directory_exists(file_path):
    """
    Ensure the directory for the given file path exists. If not, create it.

    Args:
        file_path (str): The file path for which the directory should be checked/created.
    """
    directory = os.path.dirname(file_path)
    if directory and not os.path.exists(directory):
        os.makedirs(directory)


def merge_syslog_tgz_files(input_files, output_file, temp_dir="/home/ute/temp_syslog"):
    """
    Merge multiple SYSLOG.tgz files into a single file.

    Args:
        input_files (list): List of paths to the SYSLOG.tgz files.
        output_file (str): Path to the output merged file.
        temp_dir (str): Temporary directory to extract the files. Default is "temp_syslog".

    Returns:
        None
    """
    # Ensure the output directory exists
    ensure_directory_exists(output_file)
    # Create a temporary directory to extract files
    if not os.path.exists(temp_dir):
        os.makedirs(temp_dir)
    try:
        with open(output_file, "w") as outfile:
            for file in input_files:
                # Extract the .tgz file
                with tarfile.open(file, "r:gz") as tar:
                    tar.extractall(path=temp_dir)

                # Find and read the SYSLOG file in the extracted contents
                for root, dirs, files in os.walk(temp_dir):
                    for name in files:
                        if name.lower().startswith("syslog"):
                            syslog_path = os.path.join(root, name)
                            with open(syslog_path, "r") as infile:
                                # Write the content of the SYSLOG file to the output file
                                outfile.write(infile.read())
                                outfile.write("\n")  # Add a newline between files
                            break

                # Clean up the temporary directory for the next file
                shutil.rmtree(temp_dir)
                os.makedirs(temp_dir)
    finally:
        # Remove the temporary directory after processing
        if os.path.exists(temp_dir):
            shutil.rmtree(temp_dir)
    print(f"All SYSLOG files have been merged into {output_file}")
    return output_file


def conver_bwp_params_to_json_file(bwp_params, output_file):
    json_bwp = []
    for item in bwp_params:
        json_item = {
            "distName": item["dist_name"],
            "operation": "update",
            "parameters": [
                {
                    "parameterName": item["parameter"],
                    "value": [
                        {
                            **value,
                            "cellBwpId": str(idx),
                            "pdcchResourcePreference": "peakRate",
                        }
                        for idx, value in enumerate(item["value"])
                    ],
                    "operation": "update",
                }
            ],
        }
        json_bwp.append(json_item)
    # Save the JSON to a file
    with open(output_file, "w") as json_file:
        json.dump(json_bwp, json_file, indent=4)
    logging.debug(
        f"JSON file '{output_file}' has been created and contains the transformed data."
    )
    return output_file


# Function to create a directory path if it doesn't exist
def create_directory(path):
    if not os.path.exists(path):
        os.makedirs(path)


# Function to process debug logs and save filtered data to an Excel file
def get_oam_kpi_from_debug_log(debug_log_path, kpi_id_list, kpi_restore_path):
    init_pandas()
    # Ensure the output path exists
    create_directory(kpi_restore_path)

    # Regular expression to match the desired log lines
    log_pattern = re.compile(
        r"Reported KPI results: ID=(?P<ID>\d+), VALUE=(?P<VALUE>[\d.]+)(?:, SOURCE=(?P<SOURCE>\w+))?(?:, "
        r"VARIANT=(?P<VARIANT>\{.*?\}))?(?:, ENTITY_ID=(?P<ENTITY_ID>\S+))?"
    )

    # Initialize a list to store extracted data
    extracted_data = []

    # Read the log file and extract matching lines
    with open(debug_log_path, "r", encoding="utf-8", errors="ignore") as log_file:
        for line in log_file:
            match = log_pattern.search(line)
            if match:
                data = match.groupdict()
                if data["ID"] in kpi_id_list:
                    # Handle VARIANT field
                    if data["ID"] == "00015":
                        variant = json.loads(data["VARIANT"])
                        data["VARIANT"] = variant.get("serial_number")
                    elif data["VARIANT"]:
                        variant = json.loads(data["VARIANT"])
                        data["VARIANT"] = variant.get("rat", "NO VARIANT")
                    else:
                        data["VARIANT"] = "NO VARIANT"
                    extracted_data.append(data)

    # Print the extracted data
    print("Extracted Data:", extracted_data)
    output_file = None
    # Convert the extracted data to a DataFrame
    if extracted_data:
        df = pd.DataFrame(extracted_data)
        # Save the DataFrame to an Excel file
        timestamp = datetime.now().strftime("%Y%m%d%H%M%S")
        output_file = os.path.join(kpi_restore_path, f"oam_kpi_{timestamp}.xlsx")
        with pd.ExcelWriter(output_file, engine="openpyxl") as writer:
            df.to_excel(writer, sheet_name="original_data", index=False)
    # Print the output file path
    print(f"Output File Path: {output_file}")
    # Load the Excel file and ensure ID column retains its original formatting
    if output_file:
        output_file_parsing(output_file)
    else:
        print("oam kpi report generation failed")
        # assert output_file, f"oam kpi report generation failed"
    # Return the path to the output file
    return output_file


def output_file_parsing(
    output_file,
):  # Load the Excel file and ensure ID column retains its original formatting
    init_pandas()
    df = pd.read_excel(output_file, sheet_name="original_data", dtype={"ID": str})

    # Group by ID, VARIANT, and ENTITY_ID, calculate the mean VALUE
    grouped_df = df.groupby(["ID", "VARIANT", "ENTITY_ID"], as_index=False).agg(
        {"VALUE": "mean"}
    )

    print("original data", df)
    print("base data:", grouped_df)
    # Save the result to a new sheet named 'base'
    with pd.ExcelWriter(output_file, engine="openpyxl", mode="a") as writer:
        grouped_df.to_excel(writer, sheet_name="base", index=False)


# Function to find the latest folder with a specific prefix
def compared_oam_kpi(oam_kpi_path, diff_threshold=10):
    init_pandas()
    # Extract kpi_restore_path from the oam_kpi_path
    kpi_restore_path = os.path.dirname(oam_kpi_path)

    # Extract the prefix (e.g., SBTS00) from the kpi_restore_path
    folder_name = os.path.basename(kpi_restore_path)
    prefix = folder_name.split("_")[0]

    # Extract the base directory from kpi_restore_path
    base_dir = os.path.dirname(kpi_restore_path)

    # Print the extracted prefix and base directory
    print(f"Prefix: {prefix}")
    print(f"Base Directory: {base_dir}")

    # Print the extracted kpi_restore_path
    print(f"KPI Restore Path: {kpi_restore_path}")

    # Find all folders under base_dir with the same prefix as kpi_restore_path, excluding kpi_restore_path itself

    # Standardize paths
    base_dir = os.path.normpath(base_dir)
    kpi_restore_path = os.path.normpath(kpi_restore_path)

    # Debugging information
    print(f"Base Directory: {base_dir}")
    print(f"KPI Restore Path: {kpi_restore_path}")
    print(f"Prefix: {prefix}")
    print(f"Glob Pattern: {os.path.join(base_dir, f'{prefix}*')}")

    # Debugging: List all folders in base_dir
    if os.path.exists(base_dir):
        all_dirs = [
            f for f in os.listdir(base_dir) if os.path.isdir(os.path.join(base_dir, f))
        ]
        print(f"All Directories in Base Directory: {all_dirs}")
    else:
        print(f"Base Directory does not exist: {base_dir}")

    # Debugging: Check if KPI Restore Path exists
    if not os.path.exists(kpi_restore_path):
        print(f"KPI Restore Path does not exist: {kpi_restore_path}")

    # Escape special characters in prefix
    safe_prefix = re.escape(prefix)
    glob_pattern = os.path.join(base_dir, f"{safe_prefix}*")
    glob_pattern = glob_pattern.replace("\\", "/")  # Normalize to forward slashes
    print(f"Escaped and Normalized Glob Pattern: {glob_pattern}")

    # Attempt to find folders using glob
    all_folders = glob.glob(glob_pattern)
    print(f"All Folders Matching Prefix (Glob): {all_folders}")

    # Manual matching as a fallback
    if not all_folders:
        all_folders = [
            os.path.join(base_dir, folder)
            for folder in os.listdir(base_dir)
            if folder.startswith(prefix)
            and os.path.isdir(os.path.join(base_dir, folder))
        ]
        print(f"All Folders Matching Prefix (Manual): {all_folders}")

    matching_folders = [
        folder
        for folder in all_folders
        if os.path.isdir(folder)
        and os.path.abspath(folder) != os.path.abspath(kpi_restore_path)
    ]
    print(f"Matching Folders: {matching_folders}")
    # Sort folders by modification time to find the latest one
    if matching_folders:
        latest_folder = max(matching_folders, key=os.path.getmtime)
    else:
        latest_folder = None
    # Print the latest folder for debugging
    print(f"Latest Folder: {latest_folder}")
    # Check if latest_folder exists
    if not latest_folder:
        print(f"WARN: No Base Dir Found For Release: {prefix}")
        return None

    # Find the latest xlsx file in the latest_folder
    xlsx_files = [
        os.path.join(latest_folder, file)
        for file in os.listdir(latest_folder)
        if file.lower().endswith((".xlsx", ".xls"))
    ]
    print(f"Excel Files in Latest Folder: {xlsx_files}")

    # Check if any Excel files were found
    if not xlsx_files:
        print(f"WARN: No Base File Found For Release: {prefix}")
        excel_file_path = None
    else:
        # Select the most recently modified Excel file
        excel_file_path = max(xlsx_files, key=os.path.getmtime)
        print(f"Selected Excel File Path: {excel_file_path}")

    # If excel_file_path exists, merge the 'base' sheets and calculate the difference
    if excel_file_path:
        # Load the 'base' sheets from both files
        output_base_df = pd.read_excel(
            oam_kpi_path,
            sheet_name="base",
            dtype={"ID": str, "VARIANT": str, "ENTITY_ID": str},
        )
        excel_base_df = pd.read_excel(
            excel_file_path,
            sheet_name="base",
            dtype={"ID": str, "VARIANT": str, "ENTITY_ID": str},
        )
        print("Output Base DataFrame:", output_base_df)
        print("Excel Base DataFrame:", excel_base_df)

        # Clean and normalize ID and VARIANT columns
        output_base_df["ID"] = output_base_df["ID"].str.strip()
        excel_base_df["ID"] = excel_base_df["ID"].str.strip()
        output_base_df["VARIANT"] = output_base_df["VARIANT"].str.strip()
        excel_base_df["VARIANT"] = excel_base_df["VARIANT"].str.strip()
        output_base_df["ENTITY_ID"] = output_base_df["ENTITY_ID"].str.strip()
        excel_base_df["ENTITY_ID"] = excel_base_df["ENTITY_ID"].str.strip()

        # Ensure ID, VARIANT, and ENTITY_ID columns have consistent data types
        output_base_df = output_base_df.astype(
            {"ID": str, "VARIANT": str, "ENTITY_ID": str}
        )
        excel_base_df = excel_base_df.astype(
            {"ID": str, "VARIANT": str, "ENTITY_ID": str}
        )

        # Debugging: Print unique values in ID and VARIANT columns
        print("Output Base ID Column:", output_base_df["ID"].unique())
        print("Excel Base ID Column:", excel_base_df["ID"].unique())

        print("Output Base VARIANT Column:", output_base_df["VARIANT"].unique())
        print("Excel Base VARIANT Column:", excel_base_df["VARIANT"].unique())

        print("Output Base ENTITY_ID Column:", output_base_df["ENTITY_ID"].unique())
        print("Excel Base ENTITY_ID Column:", excel_base_df["ENTITY_ID"].unique())

        # Extract suffixes from KPI Restore Path and Latest Folder
        suffix_output = f"_{os.path.basename(kpi_restore_path)}"
        suffix_excel = f"_{os.path.basename(latest_folder)}"

        # Merge the DataFrames on ID, VARIANT, and ENTITY_ID
        merged_df = pd.merge(
            output_base_df,
            excel_base_df,
            on=["ID", "VARIANT", "ENTITY_ID"],
            suffixes=(suffix_output, suffix_excel),
        )
        print("Merged DataFrame:", merged_df)

        # Calculate the percentage difference in VALUE columns using dynamic suffixes
        merged_df["DIFF"] = (
            (merged_df[f"VALUE{suffix_output}"] - merged_df[f"VALUE{suffix_excel}"])
            / merged_df[f"VALUE{suffix_excel}"]
            * 100
        ).round(1)

        # Format the DIFF column to display percentage values with a '%' symbol
        merged_df["DIFF"] = merged_df["DIFF"].apply(lambda x: f"{x}%")

        # Update the 'diff' sheet to replace ID values with their corresponding names
        merged_df["ID"] = (
            merged_df["ID"].map(KPI_ID_NAME_MAPPING).fillna(merged_df["ID"])
        )

        # Save the merged DataFrame to a new sheet named 'diff'
        with pd.ExcelWriter(oam_kpi_path, engine="openpyxl", mode="a") as writer:
            merged_df.to_excel(writer, sheet_name="diff", index=False)

        print(
            f"Merged and calculated differences saved to 'diff' sheet in {oam_kpi_path}"
        )
        # Load the workbook and access the 'diff' sheet
        workbook = load_workbook(oam_kpi_path)
        if "diff" in workbook.sheetnames:
            diff_sheet = workbook["diff"]

            # Set the first row to light blue fill
            header_fill = PatternFill(
                start_color="ADD8E6", end_color="ADD8E6", fill_type="solid"
            )
            for cell in diff_sheet[1]:
                cell.fill = header_fill

            # Align all cell contents to the left
            for row in diff_sheet.iter_rows():
                for cell in row:
                    cell.alignment = Alignment(horizontal="left")

            # Set column widths
            column_widths = {"A": 53, "B": 15, "C": 12, "D": 36, "E": 36, "F": 12}
            for col_letter, width in column_widths.items():
                diff_sheet.column_dimensions[col_letter].width = width

            # Set all row heights to 30
            for row in diff_sheet.iter_rows():
                diff_sheet.row_dimensions[row[0].row].height = 18

            # Set the font for all cells to Calibri, size 10
            calibri_font = Font(name="Calibri", size=10)
            for row in diff_sheet.iter_rows():
                for cell in row:
                    cell.font = calibri_font
        workbook.save(oam_kpi_path)
        # Save the workbook
        workbook = load_workbook(oam_kpi_path)
        if "diff" in workbook.sheetnames:
            workbook.active = workbook.sheetnames.index("diff")
        workbook.save(oam_kpi_path)
        # Assert all rows with DIFF > diff_threshold and include all columns from the 'diff' sheet
        high_diff = merged_df[
            merged_df["DIFF"].str.rstrip("%").astype(float) > diff_threshold
        ]
        assert (
            high_diff.empty
        ), f"following KPIs exceed {diff_threshold}%:\n{high_diff.to_string(index=False)}"


def execute_kpi_detector_and_copy_html(
    source_server_ip,
    source_username,
    source_password,
    script_path,
    script_args,
    dest_server_ip,
    dest_username,
    dest_password,
    dest_dir,
):
    """
    Execute a Python script on a remote server and copy the generated HTML file to another server.

    :param source_server_ip: Source server IP address
    :param source_username: Source server username
    :param source_password: Source server password
    :param script_path: Path to the script on the source server
    :param script_args: Script arguments (as a string)
    :param dest_server_ip: Destination server IP address
    :param dest_username: Destination server username
    :param dest_password: Destination server password
    :param dest_dir: Destination directory on the destination server
    :return: None
    """
    try:
        # Step 1: Execute the script on the source server
        ssh = paramiko.SSHClient()
        ssh.set_missing_host_key_policy(paramiko.AutoAddPolicy())
        ssh.connect(
            source_server_ip, username=source_username, password=source_password
        )

        command = f"python {script_path} {script_args}"
        print(f"Executing command: {command}")

        stdin, stdout, stderr = ssh.exec_command(command)
        output = stdout.read().decode()
        error = stderr.read().decode()
        ssh.close()

        if error:
            print(f"Error during script execution: {error}")
            return

        print("Script executed successfully. Output:")
        print(output)

        # Step 2: Extract the HTML file path from the output
        html_file_path = None
        for line in output.splitlines():
            if "HTML report saved to:" in line:
                html_file_path = line.split("HTML report saved to:")[-1].strip()
                break

        if not html_file_path:
            print("Failed to extract HTML file path from the output.")
            return

        print(f"Extracted HTML file path: {html_file_path}")

        # Step 3: Copy the HTML file to the destination server
        source_ssh = paramiko.SSHClient()
        source_ssh.set_missing_host_key_policy(paramiko.AutoAddPolicy())
        source_ssh.connect(
            source_server_ip, username=source_username, password=source_password
        )

        sftp_source = source_ssh.open_sftp()
        local_temp_file = tempfile.NamedTemporaryFile(
            delete=False
        ).name  # Generate a temporary file
        # Download the HTML file to the local machine
        sftp_source.get(html_file_path, local_temp_file)
        sftp_source.close()
        source_ssh.close()

        dest_ssh = paramiko.SSHClient()
        dest_ssh.set_missing_host_key_policy(paramiko.AutoAddPolicy())
        dest_ssh.connect(dest_server_ip, username=dest_username, password=dest_password)

        sftp_dest = dest_ssh.open_sftp()

        # Ensure the destination directory exists
        try:
            sftp_dest.stat(dest_dir)
        except FileNotFoundError:
            sftp_dest.mkdir(dest_dir)

        # Upload the HTML file to the destination directory
        dest_file_path = f"{dest_dir}/{html_file_path.split('/')[-1]}"
        sftp_dest.put(local_temp_file, dest_file_path)
        sftp_dest.close()
        dest_ssh.close()

        print(f"HTML file successfully copied to {dest_server_ip}:{dest_file_path}")

    except Exception as e:
        print(f"Error occurred: {e}")


def drb_change(imsi, rule):
    url = "https://newhorizons.srn.dyn.nesc.nokia.net/api/selfservice/ncp_api_update_device"
    headers = {
        "Content-Type": "application/x-www-form-urlencoded",
        "Authorization": "Bearer eyJhbGciOiJSUzI1NiIsInR5cCI6IkpXVCJ9.eyJ1aWQiOiJwejRfaHozIiwiZW1haWwiOiJtaW5"
        "nLnNoaUBub2tpYS1zYmVsbC5jb20iLCJkaXNwbGF5bmFtZSI6IlB6NCBIejMiLCJuc25jaXR5IjoiSGFuZ3"
        "pob3UiLCJyb2xlcyI6WyJwejRfaHozX2F1dG9tYXRpb24iXSwiZXhwIjoyMDEzNDAxMTk3LjAwNzE4OH0.R"
        "HAz-svYO1k5byDdHI6ECT_0RG_J7pXc8ZmNyZh25QzkddRBJZcEP1HkuhPrkpisH9ED8hH9aCBSYLC5B0Yd"
        "edKqx2NIbaW1SHyaey8GpdZDE-XVL2Z2OSY5jEvkWPTbHxu4ldvld_MESZuxtQ5kNeoHghuo-DbY8hSAQi-c"
        "yT-EPgDJCEcBt4O903Rka3TQ-f_hOxkwrjqMtIjT1yfF4oEfxnqQRRGyqk-_Rzyu9A_1vg5PSsgMzYR6t-bnj"
        "FOrv9gHMVYaeBiCjlY1CX8idpgcUfV24jvwTPrzLONF3hiYG1_bxcxwS5EAGlCh-JpRoFH1NoQEmRHvn73Uz9Q7QA",
    }
    data = {"imsi": imsi, "rule_name": rule}
    response = requests.post(url=url, headers=headers, data=data, verify=False)
    print(response.text)
    result = json.loads(response.text)
    if response.status_code == 200:
        # msg = result['msg']['responseStatus']['message']
        msg = result["msg"]
    elif response.status_code == 500:
        msg = result["msg"]
    return response.status_code, msg


def record_all_build_test_result_to_excel(build, test_result, excel_path):
    """
    Write build and test_result to an Excel file, automatically expanding new columns and appending rows.
    :param build: build name (string),eg.SBTS26R2_ENB_0000_000281_000000
    :param test_result: test result (dict) eg.{"tput": 100, "bler": 0.01}
    :param excel_path: path to the Excel file
    """
    ensure_directory_exists(file_path=excel_path)
    init_pandas()
    # New row data
    row = {"build": build}
    row.update(test_result)
    # Check if the file exists
    if os.path.exists(excel_path):
        df = pd.read_excel(excel_path)
        # Add new columns if any in the new row
        for key in row.keys():
            if key not in df.columns:
                df[key] = None
        # Add missing columns in the new row for old columns
        for col in df.columns:
            if col not in row:
                row[col] = None
        # Ensure column order
        row = {col: row.get(col, None) for col in df.columns}
        # Append the new row
        df = pd.concat([df, pd.DataFrame([row])], ignore_index=True)
    else:
        df = pd.DataFrame([row])

    # Reorder columns: 'build' first, others follow in order
    cols = ["build"] + [c for c in df.columns if c != "build"]
    df = df[cols]
    # Write to Excel
    df.to_excel(excel_path, index=False, engine="openpyxl")

    # Apply formatting
    workbook = load_workbook(excel_path)
    sheet = workbook.active

    # Set header style
    header_fill = PatternFill(
        start_color="0000FF", end_color="0000FF", fill_type="solid"
    )
    header_font = Font(name="Calibri", size=12, bold=True, color="FFFFFF")
    for cell in sheet[1]:
        cell.fill = header_fill
        cell.font = header_font
        cell.alignment = Alignment(horizontal="left")

    # Set column widths and alignment
    sheet.column_dimensions["A"].width = 35
    for col in sheet.iter_cols(min_col=2, min_row=2):
        for cell in col:
            cell.alignment = Alignment(horizontal="left")
    for col in sheet.iter_cols(min_col=2):
        col_letter = col[0].column_letter
        sheet.column_dimensions[col_letter].width = 15

    # Set font for all other cells
    for row in sheet.iter_rows(min_row=2):
        for cell in row:
            cell.font = Font(name="Calibri", size=10)
    workbook.save(excel_path)
