"""
:copyright: Nokia
:author: winnie.he
:contact: winnie.he@nokia-sbell.com
:maintainer winnie.he:
:contact winnie.he@nokia-sbell.com
"""
import requests

try:
    import robot.api.logger as logging
except ImportError:
    import logging
import json
from taf.internal.aliasing import aliasing_scope


class BaseReq:
    def __init__(self, baseurl):
        self.baseurl = baseurl

    def __reponse_handle(self, respon, url, params):
        if respon.status_code == 200:
            logging.info(
                msg="request success {} params {}".format(
                    url, params))
            return json.loads(respon.content)
        else:
            logging.error(msg="request fail {} params {}".format(url, params))
            logging.error(msg="{}".format(respon.content))
            raise ("request fail {}").format(respon.status_code)

    def post(self, api_post_fix, params, filepath=None):
        url = "{}{}".format(self.baseurl, api_post_fix)
        if filepath is None:
            respon = requests.post(url=url, data=params)
        else:
            respon = requests.post(
                url=url, data=params, files={'file': open(filepath, 'rb')}, timeout=300)
        return self.__reponse_handle(respon, url, params)

    def get(self, api_get_fix, params=None):
        url = "{}{}".format(self.baseurl, api_get_fix)
        respon = requests.get(url=url, data=params)
        if respon.status_code == '200':
            logging.info(msg="post success {} params {}".format(url, params))
        return self.__reponse_handle(respon, url, params)


class TrafficModel(BaseReq):
    def __init__(self):
        # self.url = "http://10.21.41.254/app_sfe"
        self.url = "http://10.21.41.175/app_sfe"
        # self.url = "http://dev5.eecloud.dynamic.nsn-net.net/app_sfe"
        BaseReq.__init__(self, self.url)

    def start_sequence(self, sequence_name):
        params = {"name": sequence_name,
                  "operation": "start"}
        api = "/apis/traffic_model_sequence/operation"
        return self.get(api_get_fix=api,
                        params=params)

    def stop_sequence(self, sequence_name):
        params = {"name": sequence_name,
                  "operation": "stop"}
        api = "/apis/traffic_model_sequence/operation"
        return self.get(api_get_fix=api,
                        params=params)

    def get_sequence_status(self, sequence_name):
        params = {"name": sequence_name}
        api = "/apis/traffic_model_sequence/status"
        return self.get(api_get_fix=api,
                        params=params)


class BenchmarkKpi(BaseReq):
    def __init__(self):
        self.url = "http://kpi1.eecloud.dynamic.nsn-net.net/app_kpi/"
        # self.url = "http://dev5.eecloud.dynamic.nsn-net.net/app_kpi/"
        BaseReq.__init__(self, self.url)

    def create_report(self, sw1,
                      site_list,
                      starttime1, endtime1, template1, owner,
                      sw2=None, starttime2=None, endtime2=None,
                      template2=None):
        bencsitesws = [{"sw": sw1,
                        "site": site_list,
                        "template": template1,
                        "start_time": starttime1,
                        "end_time": endtime1,
                        "group": 1}]
        if sw2 is not None:
            bencsitesws.append({"sw": sw2,
                                "site": site_list,
                                "template": template2,
                                "start_time": starttime2,
                                "end_time": endtime2,
                                "group": 2})
        params = {"cmd": "new_benchmark",
                  "group_ele": "sw",
                  "owner": owner,
                  "time_offset": 0,
                  "group": json.dumps(bencsitesws)}
        api_post_fix = "apis/new_benchmark"
        return self.post(api_post_fix, params)

    def create_report_by_ziped_pm(self,
                                  template,
                                  starttime,
                                  endtime,
                                  owner,
                                  file_path):
        bencsitesws = [{"template": template,
                        "start_time": starttime,
                        "end_time": endtime,
                        "group": 1}]
        params = {"cmd": "new_benchmark",
                  "group_ele": "sw",
                  "owner": owner,
                  "time_offset": 0,
                  "group": json.dumps(bencsitesws)}
        return self.post("apis/new_zip_benchmark", params, filepath=file_path)


# if __name__ == "__main__":
#     # tm = TrafficModel()
#     # re = tm.stop_sequence(sequence_name="newsequence")
#     # print(re)
#     bk = BenchmarkKpi()
#     bk.create_report(sw1="SBTS22R4_ENB_0000_000185_000000",
#                      site_list=["10.68.152.243"],
#                      starttime1="2022-08-30 09:01:00",
#                      endtime1="2022-08-31 09:01:00",
#                      template1="PMKPI_SBTS23R4_5G",
#                      owner="winnie.he@nokia-sbell.com")
