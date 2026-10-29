#!/usr/bin/env python
# -*- coding: utf-8 -*-

"""
This module handles component version inquiry of a certain load build.
Currently only Trunk load build is supported, as this is no component data get from wft API for 20A and 20B streams.
"""

import json
import argparse
import requests
import re
import os
import string


# user_agent and header for requests
USER_AGENT = "Mozilla/5.0 (Windows NT 6.1; WOW64) AppleWebKit/537.36 (KHTML, like Gecko) \
Chrome/45.0.2454.101 Safari/537.36"
HEADERS = {
    "User-Agent": USER_AGENT,
    "Content-type": "application/json",
    "Accept": "*/*",
}

WFT_URL = "https://wft.int.net.nokia.com:8091/api/v1"
ACCESS_KEY = {"access_key": "7r7EN5TIIO6QqWID46SbnTte4CV6cgflMOoTawtQ"}

DEFAULT_PRO = "5G:WMP"
DEFAULT_COM = "5G_Central"
TRUNK_PRE = "5G_"
COMPONENT_KEY = "custom_config_spec"
BUILD_REGEX = re.compile(r"^\d{1}\.\d{1,9}\.\d{1,9}$")


def get_buildid_form_wft(release, target_version, prefix_of_release):
    version = ""
    try:
        wft_url = "https://wft.int.net.nokia.com:8091/ALL/api/v1/view/3.json?" \
                 "access_key=IMTttFegWFfW7ZTJHytbNQvkSKvU3BSHDRDL7i6U&view[items]=20000"
        # proxies = {'http': 'http://10.144.1.10:8080','https':"http://10.144.1.10:8080"}
        requests.packages.urllib3.disable_warnings()
        res = requests.get(wft_url, verify=False)
        if res.status_code == 200:
            sw_list = res.json()["items"]
            flag = "False"
            for wft_sw in sw_list:
                if str(wft_sw["version"]) == target_version:
                    flag = "True"
                    continue
                if (
                    str(wft_sw["version"]).startswith(release)
                    and (
                        str(wft_sw["state"]) == "RELEASED"
                        or str(wft_sw["state"]) == "RELEASED_WITH_RESTRICTIONS"
                    )
                    and (flag == "True")
                ):
                    version = wft_sw["version"].replace(prefix_of_release, "")
                    break
        return version
    except Exception as error:
        return version


def read_jason_file():
    f = open("/home/ute/cli.output1.txt")
    t = json.load(f)
    return t


def check_component_version(com_project, com_name, com_data):
    """
    Get the version of a certain component from the data of all components.

    :param com_project: the project name of a component, e.g. 5G, Common, Or PS,
           which can be found from the Project Name Column of the Sub-Builds tab of a loadbuild in WFT.
    :param com_name: the name of a loadbuild's sub-build, which can be found from the Component Name Column of
            the Sub-Builds tab of a loadbuild in WFT.
    :param com_data: a string holding data of all components/sub-builds.

    :return: a string indicating the version of the component in question.
    """
    com_to_check = com_project + ":" + com_name
    com_data_list = string.split(com_data, "\n")
    line = 0
    com_version = None
    for item in com_data_list:
        line = line + 1
        if com_to_check in item:
            # print("This item is {}".format(item))
            # print("This is line {}".format(line))
            # print("The line component to check is {}".format(item))
            com_version = string.split(com_data_list[line], ":")[-1].strip()
            # print("The {} version is {}".format(com_name, com_version))
    return com_version


def main():
    # CLI
    parser = argparse.ArgumentParser(
        description="Check the component version of a trunk loadbuild."
    )
    parser.add_argument("BuildVersion", help="Load build. e.g. 0.800.2704")
    parser.add_argument(
        "ComponentProject", help="Component project name. e.g. Common, 5G, or PS"
    )
    parser.add_argument("ComponentName", help="Component name. e.g. OAMADMIN, or PS")

    args = parser.parse_args()

    # Validate arguments
    my_loadbuild = args.BuildVersion
    my_comprj = args.ComponentProject
    my_comname = args.ComponentName


if __name__ == "__main__":
    main()
