# -*- coding: utf-8 -*-
"""
:copyright: Nokia Networks
:author: I_ASL3_HZH_TA_FRAMEWORK_GMS@internal.nsn.com
:contact: I_ASL3_HZH_TA_FRAMEWORK_GMS@internal.nsn.com
"""
import json
import requests


class mdrb_aic(object):
    def __init__(self):
        pass

    def dynamic_rule_submit(self, imsi, rule):
        url = 'https://newhorizons.srn.dyn.nesc.nokia.net/api/selfservice/ncp_api_update_device'
        headers = {
            'Content-Type': 'application/x-www-form-urlencoded',
            'Authorization': 'Bearer eyJhbGciOiJSUzI1NiIsInR5cCI6IkpXVCJ9.eyJ1aWQiOiJwejRfaHozIiwiZW1haWwiOiJtaW5'
                             'nLnNoaUBub2tpYS1zYmVsbC5jb20iLCJkaXNwbGF5bmFtZSI6IlB6NCBIejMiLCJuc25jaXR5IjoiSGFuZ3'
                             'pob3UiLCJyb2xlcyI6WyJwejRfaHozX2F1dG9tYXRpb24iXSwiZXhwIjoyMDEzNDAxMTk3LjAwNzE4OH0.R'
                             'HAz-svYO1k5byDdHI6ECT_0RG_J7pXc8ZmNyZh25QzkddRBJZcEP1HkuhPrkpisH9ED8hH9aCBSYLC5B0Yd'
                             'edKqx2NIbaW1SHyaey8GpdZDE-XVL2Z2OSY5jEvkWPTbHxu4ldvld_MESZuxtQ5kNeoHghuo-DbY8hSAQi-c'
                             'yT-EPgDJCEcBt4O903Rka3TQ-f_hOxkwrjqMtIjT1yfF4oEfxnqQRRGyqk-_Rzyu9A_1vg5PSsgMzYR6t-bnj'
                             'FOrv9gHMVYaeBiCjlY1CX8idpgcUfV24jvwTPrzLONF3hiYG1_bxcxwS5EAGlCh-JpRoFH1NoQEmRHvn73Uz9Q7QA'
        }
        data = {
            'imsi': imsi,
            'rule_name': rule
        }
        response = requests.post(url=url, headers=headers, data=data, verify=False)
        print(response.text)
        result = json.loads(response.text)
        # if response.status_code == 200:
        #     msg = result['msg']['responseStatus']['message']
        # elif response.status_code == 500:
        #     msg = result['msg']
        msg = result['msg']
        assert "Success" in msg, "fail to execute {}".format(rule)


if __name__ == "__main__":
    mdrb_obj = mdrb()
    help(mdrb_obj)
