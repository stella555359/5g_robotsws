# -*- coding: utf-8 -*-
# @Time    : 2023/4/12 14:39
# @Author  : Jian.1.Chen
# @Email   : jian.1.chen@nokia-sbell.com
# @File    : analysis_ipconfig.py
# @Software: PyCharm
'''this function is for getting IP from PC
the network adapter name should include UE0 or UE
e.g.
UE1:
   IPv4 address . . . . . . . . . . . . : 10.108.251.37
'''


def get_ue_ips_from_ipconfig(ipconfig_output_path):
    with open(ipconfig_output_path, "r", encoding="GBK") as fr:
        ipconfig_lines = fr.readlines()
    ue_ips = {}
    ue_name = ""
    ue_ip = ""
    for ipconfig_line in ipconfig_lines:
        if "UE0" in ipconfig_line:
            # spilt to UE01..UE02
            ue_name = ipconfig_line[-6:-2]
            ue_ip = ""
        elif "UE" in ipconfig_line:
            # spilt to UE1..UE2
            ue_name = ipconfig_line[-5:-2]
            ue_ip = ""
        if "IPv4" in ipconfig_line and ue_name != "":
            ue_ip = ipconfig_line.split(": ")[1][:-1]
            print(ue_ip)
            print(ue_name)
            assert ue_ip.startswith("10.108.251") or ue_ip.startswith("172.250"), "Invalid IP format"
        if ue_name != "" and ue_ip != "":
            ue_ips[ue_name] = ue_ip
    return ue_ips
