import base64
import json
import os.path
import re
import sys
import threading
import time

import paramiko
import requests
import yaml
import pandas as pd


class DownloadKpiFile:
    def __init__(self,
                 compass_url="http://compass.dyn.nesc.nokia.net:8080/kpi/generate_kpi_report/",
                 compass_login_url="http://compass.dyn.nesc.nokia.net:8080/common/login_handle/"):
        self.compass_generate_kpi_report_url = compass_url
        self.common_user_agent = ("Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) "
                                  "Chrome/120.0.0.0 Safari/537.36")
        self.compass_login_url = compass_login_url

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

    def generate_new_report(self, report_name, test_line, package_version, template_name, start_time, end_time,
                            comments="", check_out_entry="false"):
        """
        Generate a new report on Compass.
        :param report_name: the name of the report
        # :param tl_id: the test line id e.g. 335
        :param test_line: the test line id e.g. 7_5_UTE5G402T335
        :param package_version: the package version
        :param template_name: the template name
        :param start_time: the start time of the report
        :param end_time: the end time of the report
        :param comments: the comments of the report
        :param check_out_entry: the check out entry value "true" or "false", so that to generate chart
        :return: the report id
        """
        session = requests.session()
        res = session.post(url=self.compass_login_url,
                           data={"username": base64.b64decode(b'bTFzaGk=').decode('utf-8'),
                                 "password": base64.b64decode(b'UWF6d3N4ZWRjcmZ2dGdiOA==').decode('utf-8')},
                           verify=False)
        session.headers['cookie'] = res.headers.get('Set-Cookie').split(sep=';', maxsplit=1)[0]
        # headers = {
        #     'cookie': "name=m1shi; sessionid=kwm3keqgqn9if8bc1io1wm5g2rlom9el"
        # }
        data = {
            "report_name": report_name,
            # "test_line": f"7_5_UTE5G402T{tl_id}",
            "test_line": test_line,
            "package_version": package_version,
            "template_name": template_name,
            "start_time": start_time,
            "end_time": end_time,
            "comments": comments,
            "check_out_entry": str(check_out_entry)
        }
        """
        resp.json()
        {"success": true, "error": "", "data": {"id": "68722", "name": "test_2024-06-21T06:13:18.993134",
        "package": "2.0", "start_time": "2024-06-19 16:29:00", "end_time": "2024-06-20 17:00:00",
        "kpi_template_id": "1698", "comments": "test1", "kpi_template__name": "CHZ_SG3_TMO_SA_KPI",
        "testlines": "7_5_UTE5G402T335", "testline_ids": "TL_5085"}}
        with requests.post(url=self.compass_generate_kpi_report_url, headers=headers, data=data) as resp:
        """
        with session.post(url=self.compass_generate_kpi_report_url, data=data) as resp:
            print(resp.json())
            if str(resp.json()["success"]) == "True":
                print("Generate new report successfully.")
                kpi_report_id = int(resp.json()["data"]["id"])
                return kpi_report_id
            elif str(resp.json()["success"]) == "false":
                print(f"Failed to generate new report. error reason: {resp.json()['error']}")
                return None

    def get_scout_token(self, username, password):
        """
        Get the Scout token.
        :param username: the username
        :param password: the password
        :return: the Scout token
        """
        url = "https://scout.nsn-rdnet.net/future/api/v1/api_token_obtain/"
        data = {"data": {"type": "obtain_json_web_token",
                         "attributes": {"username": username, "password": password}}}
        headers = {
            "User-Agent": self.common_user_agent,
            'Accept': 'application/vnd.api+json',
            'Content-Type': 'application/vnd.api+json'
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
        excel_url = re.search(pattern, response.json()["errors"][0]["detail"]).group("url").strip()
        print(excel_url)
        with requests.get(url=excel_url, headers=headers_2) as resp_2:
            print(resp_2.status_code)
            filename = excel_url.split("/")[-1]
            excel_file_name = os.path.join(path, filename)
            if resp_2.status_code == 200:
                with open(excel_file_name, "wb") as f:
                    f.write(resp_2.content)

    def download_kpi_result_file(self, report_id, path):
        """
        Download the KPI result file.
        :param report_id: the report id
        :param path: the path to save the KPI result file
        """
        authorization = self.get_scout_token(
            username=base64.b64decode(b'bTFzaGk=').decode('utf-8'),
            password=base64.b64decode(b'UWF6d3N4ZWRjcmZ2dGdiOA==').decode('utf-8'))
        url = f"https://scout.nsn-rdnet.net/future/api/v1/kpis_reports/{report_id}/export_to_excel/"
        headers = {
            "User-Agent": self.common_user_agent,
            "Authorization": f"JWT {authorization}"
            # "Authorization": "JWT eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJ0b2tlbl90eXBlIjoiYWNjZXNzIiwiZXhwIjoxNz"
            #                  "E5NTQzOTQyLCJpYXQiOjE3MTg5MzkxNDIsImp0aSI6Ijg5ZWMzOGU0OWQ0ZTRmMzU5NmIwZDQ2NTBmNDJkY"
            #                  "mVkIiwidXNlcm5hbWUiOiJtMXNoaSIsImVtYWlsIjoibWluZy5zaGlAbm9raWEtc2JlbGwuY29tIiwiaWQi"
            #                  "OjIzNDIsImRpc3BsYXlfbmFtZSI6Ik1pbmcgU2hpIChOU0IpIn0.rLe9F_e1HhG1dOaRHxFUVKNF63DYS4n"
            #                  "T4KYaM2w5awc"
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
                print(resp.json())
                if list(resp.json().keys())[0] == "errors" and ("You're KPI report already exist as excel file in our "
                                                                "storage" in resp.json()["errors"][0]["detail"]):
                    self.get_kpi_report(response=resp, path=path)
                    break
                else:
                    print("waif for 300s to get the KPI report.")
                    time.sleep(300)

    def crawling_kpi_data(self, report_id, json_file_path, json_file_name):
        url = f"https://scout.nsn-rdnet.net/api/v1/kpis_reports/{report_id}/?include=author%2Ckpi_report_template"
        authorization = self.get_scout_token(
            username=base64.b64decode(b'bTFzaGk=').decode('utf-8'),
            password=base64.b64decode(b'UWF6d3N4ZWRjcmZ2dGdiOA==').decode('utf-8'))
        headers = {
            "Accept": "application/json, text/plain, */*",
            "User-Agent": self.common_user_agent,
            'Content-Type': 'application/vnd.api+json',
            "Authorization": f"JWT {authorization}",
            # "Authorization": "JWT eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJ0b2tlbl90eXBlIjoiYWNjZXNzIiwiZXhwIjoxNz"
            #                  "E5NTQzOTQyLCJpYXQiOjE3MTg5MzkxNDIsImp0aSI6Ijg5ZWMzOGU0OWQ0ZTRmMzU5NmIwZDQ2NTBmNDJkY"
            #                  "mVkIiwidXNlcm5hbWUiOiJtMXNoaSIsImVtYWlsIjoibWluZy5zaGlAbm9raWEtc2JlbGwuY29tIiwiaWQi"
            #                  "OjIzNDIsImRpc3BsYXlfbmFtZSI6Ik1pbmcgU2hpIChOU0IpIn0.rLe9F_e1HhG1dOaRHxFUVKNF63DYS4n"
            #                  "T4KYaM2w5awc"
        }
        with requests.get(url=url, headers=headers) as resp:
            print(resp.status_code)
            data_json_file = os.path.join(json_file_path, f"{json_file_name}.json")
            with open(data_json_file, "w") as f:
                json.dump(resp.json(), f)

    @staticmethod
    def get_excel_data(json_file_path, test_line, json_file_name):
        data_json_file = os.path.join(json_file_path, f"{json_file_name}.json")
        with open(data_json_file, "r") as f:
            data = json.load(f)
            group_name = []
            EntryName = []
            Unit = []
            Aggregated = []
            testline_id = []
            for index, item in enumerate(data["data"]["attributes"]["report"]):
                group_name.append(item["group_name"])
                EntryName.append(item["code"] + item["name"])
                if "unit" not in item.keys():
                    Unit.append("")
                else:
                    Unit.append(item["unit"])
                Aggregated.append(item["global_result"]["value"])
                testline_id.append(item["global_result"]["value"])
            dict_items = {"Group Name": group_name, "EntryName": EntryName, "Unit": Unit, "Aggregated": Aggregated,
                          f"{test_line}": testline_id}
        return dict_items

    @staticmethod
    def write_data_to_excel(data, path, excel_name):
        excel_file_name = os.path.join(path, f"{excel_name}.xlsx")
        df = pd.DataFrame(data)
        df.to_excel(excel_writer=excel_file_name, sheet_name="Base Report")


def record_time(label="start"):
    print(f"{label} time is: {DownloadKpiFile.get_time()}")
    return DownloadKpiFile.get_time()


def generate_new_report_on_compass(template_name, report_name, test_line, package_version, start_time, end_time,
                                   comments="", check_out_entry="false"):
    # template_name = DownloadKpiFile.get_parameter_info(file_path=file_path)["template_name"]
    # if template_name is None:
    #     print("Failed to get the template name.")
    #     raise Exception("Failed to get the template name. please check yaml file")
    dpf = DownloadKpiFile()
    report_id = dpf.generate_new_report(report_name=report_name, test_line=test_line, package_version=package_version,
                                        template_name=template_name, start_time=start_time, end_time=end_time,
                                        comments=comments, check_out_entry=check_out_entry)
    return report_id


def generate_kpi_report_on_compass(template_name, report_name, test_line, package_version, start_time, end_time,
                                   comments="", check_out_entry="false"):
    dpf = DownloadKpiFile()
    report_id = dpf.generate_new_report(report_name=report_name, test_line=test_line, package_version=package_version,
                                        template_name=template_name, start_time=start_time, end_time=end_time,
                                        comments=comments, check_out_entry=check_out_entry)
    return report_id


def download_kpi_file(report_id, path):
    dpf = DownloadKpiFile()
    dpf.download_kpi_result_file(report_id=report_id, path=path)


def python_handle_string(start_time):
    """
    test case
    """
    handle_time = start_time.replace('-', '_').replace(' ', '_').replace(':', '_')
    print(handle_time)
    return handle_time


def get_required_info(file_path):
    """
    Get the parameters from the yaml file.
    FYI: testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/lines/SG3/kpi_report_releated_parameters.yml
    :param file_path: the path of the yaml file
    :return: the data in the yaml file
    """
    with open(file_path, "r") as f:
        data = yaml.safe_load(f)
    return data


def crawling_data_to_excel_file(report_id,
                                json_file_path,
                                json_file_name,
                                test_line,
                                excel_path,
                                excel_name):
    dpf = DownloadKpiFile()
    dpf.crawling_kpi_data(report_id=report_id, json_file_path=json_file_path, json_file_name=json_file_name)
    if os.path.exists(os.path.join(json_file_path, f"{json_file_name}.json")):
        dict_dat = DownloadKpiFile.get_excel_data(json_file_path=json_file_path, test_line=test_line,
                                                  json_file_name=json_file_name)
        DownloadKpiFile.write_data_to_excel(data=dict_dat, path=excel_path, excel_name=excel_name)
        print("Data has been written to excel file")
    else:
        print("Data has not been written to excel file")


def kpi_generate_and_crawling(template_name,
                              report_name,
                              test_line,
                              package_version,
                              start_time,
                              end_time,
                              report_excel_file_path):
    report_id = generate_new_report_on_compass(template_name=template_name,
                                               report_name=report_name,
                                               test_line=test_line,
                                               package_version=package_version,
                                               start_time=start_time,
                                               end_time=end_time)
    if report_id is not None:
        # download_kpi_file(report_id=report_id,
        #                   path=path)
        crawling_data_to_excel_file(report_id=report_id,
                                    json_file_path=report_excel_file_path,
                                    json_file_name=report_name,
                                    test_line=test_line,
                                    excel_path=report_excel_file_path,
                                    excel_name=report_name)
