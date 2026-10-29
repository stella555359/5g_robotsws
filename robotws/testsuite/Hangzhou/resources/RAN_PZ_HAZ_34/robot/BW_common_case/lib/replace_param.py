# -*- coding: utf-8 -*

"""
Author: cai lanwen
Contact Mail:lanwen.cai@nokia-sbell.com
Description: replace dist_name in scf
"""


def replace_parameter_dist_name(scf_para, new_value):
    for i in scf_para:
        i["dist_name"] = new_value
    return scf_para
