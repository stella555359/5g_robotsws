"""
SFE TMO HO common keywords
Author: ming.shi@nokia-sbell.com
"""
import base64
import json
import os.path
import re
import threading
import time

import paramiko
import requests
import yaml
import pandas as pd


# import taf.transport.ssh as ssh


class MakeTraffic:
    def __init__(self):
        # self.sshconn = ssh.ssh()
        self.p = '{print $2}'

    @staticmethod
    def get_ue_info_for_traffic(file_path):
        with open(file_path, "r") as f:
            ue_data = yaml.safe_load(f)

        return ue_data

    @staticmethod
    def connections(ssh, ip, username, password, tries=3):
        for attempt in range(tries):
            try:
                ssh.connect(hostname=ip, username=username, password=password)
            except Exception as E:
                print(f"Connection failed {E}")
                if attempt < tries - 1:
                    time.sleep(1)
                else:
                    raise Exception("Max attempts reached. Connection failed.")

    def make_dl_traffic(self, ue_ip, port, duration, interval, process_num, t_size, buffer_size, iperf_server_ip,
                        username, password):
        try:
            ssh = paramiko.SSHClient()
            ssh.set_missing_host_key_policy(policy=paramiko.AutoAddPolicy())
            # ssh.connect(hostname=iperf_server_ip, username=username, password=password)
            self.connections(ssh, iperf_server_ip, username, password)
        except Exception as e:
            print(f"{iperf_server_ip} {ue_ip}: {e}")
        else:
            output = ssh.exec_command(
                command=f'iperf -c {ue_ip} -u -t {duration} -i {interval} -p {port} '
                        f'-P {process_num} -f m -b {t_size} -l {buffer_size} -T 64 &')
            print(f"ue ip {ue_ip} {port} result is {output}")
        finally:
            ssh.close()

    def make_ul_traffic(self, sn, sever_ip, b_size, buffer_size, port, duration, interval, w_size, pc_ip, username,
                        password):
        try:
            ssh = paramiko.SSHClient()
            ssh.set_missing_host_key_policy(policy=paramiko.AutoAddPolicy())
            # ssh.connect(hostname=pc_ip, username=username, password=password)
            self.connections(ssh, pc_ip, username, password)
        except Exception as e:
            print(e)
        else:
            output = ssh.exec_command(
                command=f"adb -s {sn} shell /data/local/tmp/iperf -c "
                        f"{sever_ip} -u -b {b_size} -l {buffer_size} -p {port} "
                        f"-t {duration} -i {interval} -w {w_size} &")
            print(f"ue sn {sn} {port} result is {output}")
        finally:
            ssh.close()

    def make_traffic_via_threading(self, file_path, direction):
        threads = []
        ue_info = self.get_ue_info_for_traffic(file_path=file_path)
        if direction == 'dl':
            for i in range(len(ue_info["ue_ip"])):
                th = threading.Thread(target=self.make_dl_traffic,
                                      args=(
                                          ue_info["ue_ip"][i], ue_info["dl_initial_port"] + i,
                                          ue_info["dl_duration"], ue_info["dl_traffic_interval"],
                                          ue_info["dl_traffic_process_num"], ue_info["dl_traffic_size"],
                                          ue_info["dl_traffic_buffer_size"],
                                          ue_info["server_ip"], ue_info["server_username"],
                                          ue_info["server_password"]))
                threads.append(th)
        elif direction == 'ul':
            for j in range(len(ue_info["ue_sn"])):
                th = threading.Thread(target=self.make_ul_traffic,
                                      args=(ue_info["ue_sn"][j], ue_info["server_ip"],
                                            ue_info["ul_traffic_size"], ue_info["ul_traffic_buffer_size"],
                                            ue_info["ul_initial_port"] + j, ue_info["ul_duration"],
                                            ue_info["ul_traffic_interval"], ue_info["ul_traffic_window_size"],
                                            ue_info["pc_ip"][j], ue_info["pc_username"],
                                            ue_info["pc_password"]))
                threads.append(th)
        for t in threads:
            t.start()
            time.sleep(1)
        for t in threads:
            t.join()

    def stop_dl_traffic(self, ue_info):
        try:
            ssh = paramiko.SSHClient()
            ssh.set_missing_host_key_policy(policy=paramiko.AutoAddPolicy())
            # ssh.connect(hostname=ue_info['server_ip'], username=ue_info['server_username'],
            #             password=ue_info['server_password'])
            self.connections(ssh, ue_info['server_ip'], ue_info['server_username'], ue_info['server_password'])
        except Exception as e:
            print(e)
        else:
            for i in range(len(ue_info["ue_sn"])):
                output = ssh.exec_command(
                    command=f"ps -ef|grep iperf|grep -v grep|grep "
                            f"{ue_info['dl_initial_port'] + i}| awk '{self.p}' |xargs kill -9")
                print(f"dl port {ue_info['dl_initial_port'] + i} result is: {output}")
                time.sleep(0.5)
        finally:
            ssh.close()

    def stop_ul_traffic(self, ue_info):
        j = 0
        for ip in ue_info['pc_ip']:
            try:
                ssh = paramiko.SSHClient()
                ssh.set_missing_host_key_policy(policy=paramiko.AutoAddPolicy())
                # ssh.connect(hostname=ip, username=ue_info['pc_username'], password=ue_info['pc_password'])
                self.connections(ssh, ip, ue_info['pc_username'], ue_info['pc_password'])
            except Exception as e:
                print(e)
            else:
                output = ssh.exec_command(
                    command=f"adb -s {ue_info['ue_sn'][j]} shell ps -ef | grep iperf |grep "
                            f"{ue_info['ul_initial_port'] + j} |grep -v grep |awk '{self.p}'")
                time.sleep(0.5)
                pid = str(output[1].read(), encoding='utf-8').strip()
                result = ssh.exec_command(
                    command=f"adb -s {ue_info['ue_sn'][j]} shell kill -9 {pid} &")
                print(f"adb -s {ue_info['ue_sn'][j]} shell kill -9 {pid} &")
                print(f"{ue_info['ue_sn'][j]} ul port {ue_info['ul_initial_port'] + j} result is: {result}")
                time.sleep(0.5)
            finally:
                j += 1
                ssh.close()

    def make_dl_ping(self, ue_ip, interval, size, iperf_server_ip, username, password):
        try:
            ssh = paramiko.SSHClient()
            ssh.set_missing_host_key_policy(policy=paramiko.AutoAddPolicy())
            # ssh.connect(hostname=iperf_server_ip, username=username, password=password)
            self.connections(ssh, iperf_server_ip, username, password)
        except Exception as e:
            print(f"{iperf_server_ip} {ue_ip}: {e}")
        else:
            output = ssh.exec_command(
                command=f"ping -i {interval} -s {size} {ue_ip} &")
            print(f"ue ip {ue_ip} result is {output}")
        finally:
            ssh.close()

    def make_ping_via_threading(self, file_path):
        threads = []
        ue_info = self.get_ue_info_for_traffic(file_path=file_path)
        for i in range(len(ue_info["ue_ip"])):
            th = threading.Thread(target=self.make_dl_ping,
                                  args=(
                                      ue_info["ue_ip"][i], ue_info["dl_ping_interval"], ue_info["dl_ping_size"],
                                      ue_info["server_ip"], ue_info["server_username"], ue_info["server_password"]))
            threads.append(th)
        for t in threads:
            t.start()
            time.sleep(1)
        for t in threads:
            t.join()

    def stop_dl_ping(self, ue_info):
        try:
            ssh = paramiko.SSHClient()
            ssh.set_missing_host_key_policy(policy=paramiko.AutoAddPolicy())
            # ssh.connect(hostname=ue_info['server_ip'], username=ue_info['server_username'],
            #             password=ue_info['server_password'])
            self.connections(ssh, ue_info['server_ip'], ue_info['server_username'], ue_info['server_password'])
        except Exception as e:
            print(e)
        else:
            for i in range(len(ue_info["ue_sn"])):
                output = ssh.exec_command(
                    command=f"ps -ef|grep ping|grep -v grep|grep "
                            f"{ue_info['ue_ip'][i]}| awk '{self.p}' |xargs kill -9")
                print(f"ue ip {ue_info['ue_ip'][i]} result is: {output}")
                time.sleep(0.5)
        finally:
            ssh.close()


def make_traffic_multi_ue(file_path, direction='dl'):
    mt = MakeTraffic()
    mt.make_traffic_via_threading(file_path=file_path, direction=direction)


def stop_traffic_multi_ue(file_path, direction='dl'):
    ue_info = MakeTraffic.get_ue_info_for_traffic(file_path=file_path)
    mt = MakeTraffic()
    if direction == 'dl':
        mt.stop_dl_traffic(ue_info=ue_info)
    elif direction == 'ul':
        mt.stop_ul_traffic(ue_info=ue_info)


def make_ping_multi_ue(file_path):
    mt = MakeTraffic()
    mt.make_ping_via_threading(file_path=file_path)


def stop_ping_multi_ue(file_path):
    ue_info = MakeTraffic.get_ue_info_for_traffic(file_path=file_path)
    mt = MakeTraffic()
    mt.stop_dl_ping(ue_info=ue_info)


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

    def generate_new_report(self, report_name, tl_id, package_version, template_name, start_time, end_time,
                            comments="", check_out_entry="false"):
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
            "test_line": f"7_5_UTE5G402T{tl_id}",
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
    def get_excel_data(json_file_path, tl_id, json_file_name):
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
                          f"7_5_UTE5G402T{tl_id}": testline_id}
        return dict_items

    @staticmethod
    def write_data_to_excel(data, path, excel_name):
        excel_file_name = os.path.join(path, f"{excel_name}.xlsx")
        df = pd.DataFrame(data)
        df.to_excel(excel_writer=excel_file_name, sheet_name="Base Report")


def record_time(label="start"):
    print(f"{label} time is: {DownloadKpiFile.get_time()}")
    return DownloadKpiFile.get_time()


def generate_new_report_on_compass(file_path, report_name, tl_id, package_version, start_time, end_time,
                                   comments="", check_out_entry="false"):
    template_name = DownloadKpiFile.get_parameter_info(file_path=file_path)["template_name"]
    if template_name is None:
        print("Failed to get the template name.")
        raise Exception("Failed to get the template name. please check yaml file")
    dpf = DownloadKpiFile()
    report_id = dpf.generate_new_report(report_name=report_name, tl_id=tl_id, package_version=package_version,
                                        template_name=template_name, start_time=start_time, end_time=end_time,
                                        comments=comments, check_out_entry=check_out_entry)
    return report_id


def generate_kpi_report_on_compass(template_name, report_name, tl_id, package_version, start_time, end_time,
                                   comments="", check_out_entry="false"):
    dpf = DownloadKpiFile()
    report_id = dpf.generate_new_report(report_name=report_name, tl_id=tl_id, package_version=package_version,
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
                                tl_id,
                                excel_path,
                                excel_name):
    dpf = DownloadKpiFile()
    dpf.crawling_kpi_data(report_id=report_id, json_file_path=json_file_path, json_file_name=json_file_name)
    if os.path.exists(os.path.join(json_file_path, f"{json_file_name}.json")):
        dict_dat = DownloadKpiFile.get_excel_data(json_file_path=json_file_path, tl_id=tl_id,
                                                  json_file_name=json_file_name)
        DownloadKpiFile.write_data_to_excel(data=dict_dat, path=excel_path, excel_name=excel_name)
        print("Data has been written to excel file")
    else:
        print("Data has not been written to excel file")
