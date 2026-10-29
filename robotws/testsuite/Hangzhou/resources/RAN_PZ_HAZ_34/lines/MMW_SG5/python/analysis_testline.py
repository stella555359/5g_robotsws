# -*- coding: utf-8 -*-
# @Time    : 2024/12/24 9:51
# @Author  : Jian.1.Chen
# @Email   : jian.1.chen@nokia-sbell.com
# @File    : analysis_testline.py
# @Software: PyCharm
from robot.libraries.BuiltIn import BuiltIn


__all__ = ["get_ues_trs_info"]
tl = BuiltIn().get_variable_value("${tl}")


def get_ues_trs_info():
    ues_trs_info = []
    for ue in tl.ues:
        trs_info = {}
        trs_ports = []
        try:
            trs_ports.append(ue.iperf_details.port)
            trs_info["addr"] = ue.iperf_details.ssh_connection_details.addr
            trs_info["user"] = ue.iperf_details.ssh_connection_details.username
            trs_info["password"] = ue.iperf_details.ssh_connection_details.password
            trs_ports += ue.iperf_details.ports
        except (TypeError, AttributeError):
            trs_ports += ue.data_transfer[0].app_server.ports
            trs_info["addr"] = ue.data_transfer[0].app_server.address
            trs_info["user"] = ue.data_transfer[0].app_server.user
            trs_info["password"] = ue.data_transfer[0].app_server.password
        finally:
            trs_info["ports"] = trs_ports
            ues_trs_info.append(trs_info)
    return ues_trs_info
