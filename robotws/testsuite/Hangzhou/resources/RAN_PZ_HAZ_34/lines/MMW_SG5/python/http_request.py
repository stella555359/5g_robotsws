# -*- coding: utf-8 -*-
# @Time    : 2023/10/25 15:10
# @Author  : Jian.1.Chen
# @Email   : jian.1.chen@nokia-sbell.com
# @File    : http_request.py
# @Software: PyCharm
import requests
import json
import time


def post_request_with_form_content(url, data, access_token):
    headers = {"Content-Type": "application/x-www-form-urlencoded",
               "Authorization": "Bearer " + access_token}
    res = requests.post(url=url, data=data, headers=headers, verify=False)
    print(res.text)


def modify_pdu_via_update_ncp_rule(imsi="262033100011503", rule_name="DEL5QI8-PZ3-ZYH"):
    url = "https://newhorizons.srn.dyn.nesc.nokia.net/api/selfservice/ncp_api_update_device"
    data = {
        "imsi": imsi,
        "rule_name": rule_name
    }
    access_token = "eyJhbGciOiJSUzI1NiIsInR5cCI6IkpXVCJ9.eyJ1aWQiOiJwejNfaHo1IiwiZW1haWwiOiJjaHVuLmxpQG5va2lhLXNiZ" \
                   "WxsLmNvbSIsImRpc3BsYXluYW1lIjoiUHozIEh6NSIsIm5zbmNpdHkiOiJIYW5nemhvdSIsInJvbGVzIjpbInB6M19oejV" \
                   "fYXV0b21hdGlvbiJdLCJleHAiOjIwMTM0OTY4NjYuMjE2NzAxfQ.JkDxuwL085A7cQJvUv9pC3GemBpSIK8eDJcmh3NNwF" \
                   "N6phnQQaSLdhEctoU9t_2N4QLzIfHKFLDTyC_8D-ME45apfg55MuhEE_1AmEKxfvlJBv6pAFtLYZp4qGLORuwi2MBhxgLB" \
                   "M-2-oMVhj3gdcA8gD9nn9kzmcqRcKHnYslOXYmOfoijwZEuPNy98jztktPrLWUeEL65KJr3zl0rNhekcK-yiWbR57_p0kj" \
                   "HJh_wM5xbZSP1l2ArBLJ_cab5uW4I-3MZpmJ-jr2ztsfPD34H1Uej8TD0krAeZYzjMaYiCbMCIfeUo4rTmMuTEABkIgv56" \
                   "yPWMtjq-HOrCse_yDw"
    post_request_with_form_content(url, data, access_token)


def add_new_line_to_target_sheet_for_8132_via_http_request(rsrp, build, time, fiveqi_dict, testline):
    fiveqi_dict = json.dumps(fiveqi_dict)
    headers = {"Content-Type": "application/x-www-form-urlencoded"}
    url = "http://10.0.176.127:8080/update_qos_excel"
    data = {
        "rsrp": rsrp,
        "build": build,
        "time": time,
        "fiveqi_dict": fiveqi_dict,
        "testline": testline
    }
    res = requests.post(url=url, data=data, headers=headers, verify=False)


def update_operation_history_txt_for_8132_via_http_request(file_path):
    url = "http://10.0.176.127:8080/update_qos_txt"
    files = {'file': open(file_path, 'rb')}
    res = requests.post(url=url, files=files, verify=False)


def add_cur_scf_for_8132_via_http_request(file_path, build):
    url = "http://10.0.176.127:8080/update_qos_txt"
    build = build.replace("SBTS", "")
    build = build.replace("_ENB_9999_", "_")
    build = build.replace("0000", "")
    build = build + time.strftime("_%Y-%m-%d-%H-%M-%S.xml", time.localtime())
    with open(file_path, "r") as fr:
        scf = fr.read()
        with open(build, "w") as fw:
            fw.write(scf)

    files = {'file': open(build, 'rb')}

    res = requests.post(url=url, files=files, verify=False)
