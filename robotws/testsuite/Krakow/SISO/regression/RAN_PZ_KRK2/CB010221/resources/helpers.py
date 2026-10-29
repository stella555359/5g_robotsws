"""
author: Maciej Russek, maciej.russek@nokia.com
maintainer: Maciej Russek, maciej.russek@nokia.com
description: Python helper methods
"""


class LinkModeNotAsExpected(Exception):
    pass


def get_cablink_distname_by_port_name(sfp_links_data, port_name):
    cablink_distname = ''
    for connected in sfp_links_data["connected"]:
        if port_name in connected["data"]["linkPorts"]["source"]:
            cablink_distname = connected["link"]["distName"]

    return cablink_distname


def verify_link_synchronization(cablink_data):
    synchronization = cablink_data["linkModeSynchronization"]
    if not synchronization:
        raise LinkModeNotAsExpected("Link mode synchronization is not True: value is {}".format(synchronization))


def get_port_number_priority_from_topp_data(topp_data):
    priority_dict = {
        topp_data[0]["parameters"]["topMasterList"][0]["localPriority"]:
            topp_data[0]["parameters"]["topMasterList"][0]["ruECpriPortNumber"],
        topp_data[0]["parameters"]["topMasterList"][1]["localPriority"]:
            topp_data[0]["parameters"]["topMasterList"][1]["ruECpriPortNumber"]
    }

    return priority_dict
