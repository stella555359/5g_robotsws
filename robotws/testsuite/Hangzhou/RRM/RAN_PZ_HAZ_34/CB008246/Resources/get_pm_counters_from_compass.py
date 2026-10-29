# *-coding=utf-8-*

# Name: Ming Shi
# Time: 2023/5/30 15:41
import json
import math

import requests


class GetPmCounter:
    def __init__(self):
        """
        response = requests.post('http://compass-5g.eecloud.dynamic.nsn-net.net:8000/common/login_handle/',
                              {'username': 'useranme', 'password': 'password'})
        session_id = response.cookies.get('sessionid')
        print(session_id)
        """
        self.headers = {'cookie': 'sessionid={}'.format('rh6t5gl8iijpzqw02c3wuv8we6f8irch')}
        self.generate_kpi_report_url = "http://compass-5g.eecloud.dynamic.nsn-net.net:8000/kpi/generate_kpi_report/"
        self.scout_kpi_url = "http://compass-5g.eecloud.dynamic.nsn-net.net:8000/kpi/scout_kpi/"
        self.kpi_report_detail_url = "http://compass-5g.eecloud.dynamic.nsn-net.net:8000/kpi/get_kpi_report_detail/"

    def generate_new_report(self, package_version, template_id, template_name, report_name, test_line,
                            start_time, end_time):
        """

        :param package_version:
        :param template_id: the ID is got from https://scout.nsn-rdnet.net/kpis-templates/997/
        :param template_name:
        :param report_name:
        :param test_line:
        :param start_time:
        :param end_time:
        :return:
        """
        """
        dict_data = {
             "package_version": "SBTS00_ENB_9999_230529_000003",
             "template_id": "997",
             "template_name": "CB008246-D",
             "report_name": "CB008246-D_2023-05-29_10:06:43",
             "test_line": "7_5_UTE5G402T389-2",
             "start_time": "2023-05-29 12:00+0800",
             "end_time": "2023-05-29 17:30+0800"}
        response:
        {'success': True, 'error': '', 'data': {'id': '33991',
        'name': 'CB008246-D_2023-05-29_10:06:43_2023-05-31T08:07:51.199222',
        'package': 'SBTS00_ENB_9999_230529_000003',
        'start_time': '2023-05-29T04:00:00Z',
        'end_time': '2023-05-29T09:30:00Z',
        'kpi_template_id': '997', 'kpi_template__name': 'CB008246-D', 'testlines': '7_5_UTE5G402T389-2'}}
        """
        dict_data = {
             "package_version": package_version,
             "template_id": template_id,
             "template_name": template_name,
             "report_name": report_name,
             "test_line": test_line,
             "start_time": f"{start_time}+0800",
             "end_time": f"{end_time}+0800"}
        resp = requests.post(url=self.generate_kpi_report_url, data=dict_data, headers=self.headers)
        print(resp.status_code)
        print(resp.json())
        return resp.json()["success"]

    def get_report_id(self, report_name, package_version):
        """

        :param report_name:
        :param package_version:
        :return:
        """
        # get report id in order to access url of kpi report detail
        report_id = ''
        resp = requests.post(url=self.scout_kpi_url, headers=self.headers)
        total_report = resp.json()["recordsTotal"]  # total report num
        per_page_report_num = len(resp.json()["data"])  # kpi report num per page
        page_num = math.ceil(int(total_report) / int(per_page_report_num))  # Returns the rounded integer of a number
        resp.close()
        offset = 0
        for page in range(page_num):
            resp = requests.post(url=self.scout_kpi_url, data={"offset": f"{offset}"}, headers=self.headers)
            data = resp.json()["data"]  # get all info of scout_kpi_url, return a list
            for dat in data:
                if report_name in dat["name"] and dat["package"] == package_version:
                    report_id = dat["id"]
                    break
            resp.close()
            if report_id != '':
                break
            offset += int(per_page_report_num)
        print(report_id)

        return report_id

    def get_kpi_report_detail(self, report_name, package_version, file_path):
        """

        :param report_name:
        :param package_version:
        :param file_path:
        :return:
        """
        rep_id = self.get_report_id(report_name=report_name, package_version=package_version)
        pam = {
            "report_id": rep_id
        }
        # get report detail info from url get_kpi_report_detail
        resp = requests.post(url=self.kpi_report_detail_url, data=pam,  headers=self.headers)
        kpi_name_list = []
        value_list = []
        start_range_list = []
        end_range_list = []
        with open(f"{file_path}kpi_report_detail.json", 'w') as f:
            for dat in resp.json()["data"]:
                json.dump(obj=dat, fp=f)
                f.write('\n')   # # write kpi report detail to json file
                kpi_name_list.append(dat["kpi_name"])
                value_list.append(dat["value"])
                start_range_list.append(dat["start_range"])
                end_range_list.append(dat["end_range"])
        # get a dict with kpi name and value
        dict_kpi_name_value = dict(zip(kpi_name_list, value_list))
        # get a dict with kpi name and start_range
        dict_kpi_name_start_range = dict(zip(kpi_name_list, start_range_list))
        # get a dict with kpi name and end_range
        dict_kpi_name_end_range = dict(zip(kpi_name_list, end_range_list))
        resp.close()

        return dict_kpi_name_value, dict_kpi_name_start_range, dict_kpi_name_end_range
