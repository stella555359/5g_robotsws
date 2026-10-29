#!/usr/bin/env python
# -*- coding: utf-8 -*-

"""
This module handles load-build checking tasks, including
 1) Get the version of some component in a certain load build.
    Note: Currently only 21A and Trunk load build is supported, as this is no component data get from wft API
    for 20A and 20B streams.
 2) Get the load build version with self-defined status, within the last pre-defined number of builds.
 3) Get the last load-build version by given conditions,
      A component version is the same as the current's.
      and, B component version is different from the current's.
      and, C component version is the same the current's.
      ...

"""
import json
import argparse
import requests
import re
import string
import time
import sys
import os

# user_agent and header for requests
USER_AGENT = 'Mozilla/5.0 (Windows NT 6.1; WOW64) AppleWebKit/537.36 (KHTML, like Gecko) \
Chrome/45.0.2454.101 Safari/537.36'
HEADERS = {'User-Agent': USER_AGENT,
           'Content-type': 'application/json', 'Accept': '*/*'}

WFT_URL_BUILD = 'https://wft.int.net.nokia.com:8091/api/v1'
WFT_URL_BRANCH = "https://wft.int.net.nokia.com:8091/"
ACCESS_KEY = {"access_key": 'eXeILQiJrwjD4XKVUlrW6Kkr8EFeH4TRxOagTYrM'}
# DEFAULT_PRO = '5G:WMP'
# DEFAULT_COM = '5G_Central'
COMPONENT_KEY = 'sub_builds'
# BUILD_REGEX = re.compile(r'^5G.*_\d{1,2}\.\d{1,9}\.\d{1,9}$')
BUILD_REGEX = re.compile(
    r'(^5G.*_\d{1,2}\.\d{1,9}\.\d{1,9}$)|(^SBTS.*_ENB_\d{4}_\d{6}_\d{6}$)')

FW_NAMES = {"PS": ["PS", "PS"],
            "AZQG": ["Common", "rf-5GB4"],
            "AEHC": ["Common", "rf-CHB0"]}   # input firmware name: com_project, com_name,  can be refined.

BRANCHES = {"0.800": ["master_classicalbts_all", "5G"],
            "11.800": ["21A_classicalbts", "5G21A"],
            "10.1800": ["20Bb1_classicalbts", "5G20B"],
            "SBTS00_ENB_9999": ["SBTS00", "SBTS00_ENB"],
            "SBTS21B_ENB_0000": ["SBTS21B", "SBTS21B_ENB"],
            "SBTS22R1_ENB_0000": ["SBTS22R1", "SBTS22R1_ENB"],
            "SBTS22R2_ENB_0000": ["SBTS22R2", "SBTS22R2_ENB"],
            "SBTS22R3_ENB_9999": ["SBTS00", "SBTS22R3_ENB"],
            }

PRODUCTS = {"5G": {"project": "5G:WMP", "component": "5G_Central"},
            "SBTS": {"project": "SBTS", "component": "CI_ENB"}}


def verify_loadbuild_format(build_version):
    validness = False
    b1 = re.split("[_.]", build_version)
    # print(build_version)
    # print(b1)
    # print(BUILD_REGEX.pattern)
    # print(len(b1))
    # print(BUILD_REGEX.match(build_version))
    if not 4 <= len(b1) <= 5 or not BUILD_REGEX.match(build_version):
        print("Invalid loadbuid format!")
        validness = False
    else:
        validness = True
    return validness


def get_product_by_loadbuild(build_version):
    product = None
    if "5G" in re.split("[_.]", build_version)[0]:
        product = "5G"
    elif "SBTS" in re.split("[_.]", build_version)[0]:
        product = "SBTS"
    else:
        print("Invalid loadbuid!")
    return product


def get_comp_data_from_wft(build_version, data_format='json'):
    """
    Get data for all component of a loadbuild.

    :param build_version: the version of a loadbuild, e.g. 5G_0.800.2755 or 5G21A_11.800.123
    :param data_format: the output file format that get from the WFT Rest API, by default it is json. other formats
            in this module is not supported for now.
    :return: a list holding data of all components/sub-builds.
    """
    data_get_from_wft = {}
    retry_count = 0
    get_data_success = False
    product = get_product_by_loadbuild(build_version)
    api_url = "{}/{}/{}/builds/{}.{}?items[]={}".format(WFT_URL_BUILD, PRODUCTS[product]["project"],
                                                        PRODUCTS[product]["component"],
                                                        build_version, data_format, COMPONENT_KEY)
    # print(api_url)
    while True:
        try:
            resp = requests.get(url=api_url,
                                params=ACCESS_KEY,
                                headers=HEADERS
                                )
            # print(resp.text)
        except requests.exceptions.RequestException as e:
            print(e)
            retry_count += 1
            if retry_count > 10:
                print(
                    'Retried {} times, skip to query {} from WFT!'.format(
                        retry_count, build_version))
                return False
            time.sleep(15)
        else:
            data_get_from_wft = json.loads(resp.text)
            # print(data_get_from_wft)
            component_data_in_wft = data_get_from_wft[COMPONENT_KEY]
            break
    if "error" in data_get_from_wft:
        print("{} does not exist in WFT!".format(build_version))
    else:
        get_data_success = True
        # print("{} found in WFT.".format(build_version))

    return get_data_success, component_data_in_wft


def check_component_version(fw_name, com_data):
    """
    Get the version of a certain component from the data of all components.

    :param fw_name: firware name, eg: PS, AEQB, AEQN, AZQH, rf-5GB4 etc.
           The other 2 values can be derived.from the predefined global dictitionary

           FW_NAMES = {"PS": ["PS", "PS"],
           "AZQG": ["Common", "rf-5GB4"],
           }

           1) com_project: the project name of a component, e.g. 5G, Common, Or PS,
                which can be found from the Project Name Column of the Sub-Builds tab of a loadbuild in WFT.
           2) com_name: the name of a loadbuild's sub-build, which can be found from the Component Name Column of
               the Sub-Builds tab of a loadbuild in WFT.
    :param com_data: a string holding data of all components/sub-builds.

    :return: a string indicating the version of the component in question.
    """
    com_project = FW_NAMES[fw_name][0]
    com_name = FW_NAMES[fw_name][1]
    com_to_check = com_project + ":" + com_name
    # com_data_list = string.split(com_data, "\n")
    # line = 0
    # com_version = None
    # for item in com_data_list:
    #     line = line + 1
    #     if com_to_check in item:
    #         # print("This item is {}".format(item))
    #         # print("This is line {}".format(line))
    #         # print("The line component to check is {}".format(item))
    #         com_version = string.split(com_data_list[line], ":")[-1].strip()
    #         # print("The {} version is {}".format(com_name, com_version))

    com_version = None
    for item in com_data:
        if item["title"] == com_name:
            com_version = item["version"]
    return com_version


def check_com_version_of_loadbuild(build_version, fw_name):
    """
    Get the version of a certain component of a loadbuild.

    :param build_version: the version of a loadbuild, e.g. 5G_0.800.2755
    :param com_project: the project name of a component, e.g. 5G, Common, Or PS,
           which can be found from the Project Name Column of the Sub-Builds tab of a loadbuild in WFT.
    :param com_name: the name of a loadbuild's sub-build, which can be found from the Component Name Column of
            the Sub-Builds tab of a loadbuild in WFT.
    :param com_data: a string holding data of all components/sub-builds.

    :return: a string indicating the version of the component in question.
    """
    fw_name = fw_name.upper()

    if not verify_loadbuild_format(build_version):
        sys.exit("Invalid build version {}. \n Exit!".format(build_version))

    # check on WFT
    # print("Query {} on WFT!".format(build_version))
    get_comp_data_from_wft_succeed, component_data_in_wft = get_comp_data_from_wft(
        build_version)
    if not get_comp_data_from_wft_succeed:
        sys.exit("Query WFT failed. \n Exit!")

    com_version = check_component_version(fw_name, component_data_in_wft)
    if fw_name == "PS":
        com_version = com_version.split("REL_")[-1]
    print("The {} version of {} is : {}.".format(
        fw_name, build_version, com_version))
    return com_version


def get_loadbuild_candidates_via_lib(max_num=100, stream="0.800", status=["released", "released_with_restrictions"],
                                     cit="true", output="loadbuild_candidates.txt"):
    """
    Get candidate loadbuilds for later use.
    com.interface.wft is used. To be deprecated.

    :param max_num: the num of new loadbuilds listed in WFT, among which candidates are selected.
    :param stream: stream version to check. like 0.800, or 11.800
    :param status: list, all status you want to check.
    :param cit:  TBA, ture by default.
    :param output: output file that contains the raw data of all selected candidates.
    :return: a list containing all loadbuilds with the given status defined by pramater "status", in descending order
     """
    cmd = "python -m com.interface.wft query-package --lookup_status={} --lookup_status={}" \
          " --stream_version={} --limit_number={} --cit={}" \
          " --output={}".format(status[0], status[1],
                                stream, max_num, cit, output)
    # cmd_install_lib = "python -m pip install" \
    #                   " git+ssh://git@gitlabe1.ext.net.nokia.com/5gpci/UnifyQTPipeline/com.interface.wft.git --force"
    # os.system("pip list | grep -w wft > wft_presence.txt")
    # with open("wft_presence.txt", "r") as f:
    #     # print("wft_presence is {}.".format(f.read()))
    #     if "com.interface.wft" not in f.read():
    #         os.system(cmd_install_lib)
    os.system(cmd)
    with open(output, 'r') as load_f:
        loadbuild_data = json.load(load_f)
        print(loadbuild_data)
    candidates = []
    for item in loadbuild_data:
        if "DNAF" in item["version"]:
            continue
        else:
            candidates.append(item["version"])
    print(candidates)
    return candidates


def get_loadbuild_candidates(max_num=200, stream="0.800", status=[
                             "released", "released_with_restrictions"]):
    """
    Get candidate loadbuilds for later use.
    WFT API is used.

    :param max_num: the num of new loadbuilds listed in WFT, among which candidates are selected.
    :param stream: stream version to check. like 0.800, or 11.800
    :param status: list, all status you want to check.
    :return: a list containing all loadbuilds with the given status defined by pramater "status", in descending order
     """
    candidates = []
    branch = BRANCHES[stream][0]
    # print(branch)
    if "SBTS" in stream:
        product = "SBTS"
    else:
        product = "5G"
    try:

        api_url = "{}{}/api/v1/build_branch.json?" \
                  "access_key={}&view[items]={}&view[columns[][id]]=version&view[columns[][id]]=quicktest_status" \
                  "&view[columns[][id]]=ps_env&view[view_filters_attributes[1]][column]=branch.title" \
                  "&view[view_filters_attributes[1]][operation]=eq" \
                  "&view[view_filters_attributes[1]][value][]={}".format(WFT_URL_BRANCH, PRODUCTS[product]["project"],
                                                                         ACCESS_KEY['access_key'], max_num, branch)
        print(api_url)
        requests.packages.urllib3.disable_warnings()
        res = requests.get(api_url, verify=False)
        print(res.status_code)
        if res.status_code == 200:
            loadbuild_data = res.json()["items"]
            # print(loadbuild_data)
            for item in loadbuild_data:
                if item["quicktest_status"]["state"] in status:
                    candidates.append(item["version"])
        return candidates
    except Exception as error:
        print("Exception: {}.".format(error))
    return candidates


def get_loadbuild_by_ps_version_comparision(original_build, max_num=200, stream="0.800",
                                            status=["released", "released_with_restrictions"], condition=None):
    """
    First, get candidate loadbuilds in <stream> with <status>,from the last <max-num> builds.
    Then, from the candidats, filter out the newest loadbuils that met the requirement: PS version is same as or
    different from that of the original build.
    if condition (the filter requirement)is not defined, for intra release, return the last candidate that is older
    than the original. for inter release, return the first/latest candidate.
    WFT API is used.

    :param original_build: current loadbuild
    :param max_num: the num of new loadbuilds listed in WFT, among which candidates are selected.
    :param stream: stream version to check. like 0.800, or 11.800
    :param status: list, all status you want to check.
    :param condition: string, "same" or "diff", not case sensitive. Default is None, if None, return the last candidate
    :return: a list containing all loadbuilds with the given status defined by pramater "status", in descending order
     """
    candidates = []
    branch = BRANCHES[stream][0]
    branch_pre = BRANCHES[stream][1]
    winner = None

    if condition is not None:
        if condition.lower() == "same":
            expected_result = True
        elif condition.lower() == "diff":
            expected_result = False
        else:
            print("invalid condition.")
    # print(branch)
    if "SBTS" in stream:
        product = "SBTS"
    else:
        product = "5G"
    try:
        api_url = "{}{}/api/v1/build_branch.json?" \
                  "access_key={}&view[items]={}&view[columns[][id]]=version&view[columns[][id]]=quicktest_status" \
                  "&view[columns[][id]]=ps_env&view[view_filters_attributes[1]][column]=branch.title" \
                  "&view[view_filters_attributes[1]][operation]=eq" \
                  "&view[view_filters_attributes[1]][value][]={}".format(WFT_URL_BRANCH, PRODUCTS[product]["project"],
                                                                         ACCESS_KEY['access_key'], max_num, branch)
        # print(api_url)
        requests.packages.urllib3.disable_warnings()
        res = requests.get(api_url, verify=False)
        # print(res.status_code)
        if res.status_code == 200:
            loadbuild_data = res.json()["items"]
            # print(loadbuild_data)
            flag = "False"
            for item in loadbuild_data:
                if item["quicktest_status"]["state"] in status:
                    candidates.append(
                        {item["version"]: item["ps_env"][0]['baseline']})
        print(candidates)

        if branch_pre == "5G20B":
            for item in candidates:
                key, value = list(item.items())[0]
                if key == original_build:
                    ori_version = value.split("REL_")[-1]
                    print(
                        "The PS version of loabuild {} is {}.".format(
                            original_build, value))
                    print(ori_version)
        else:
            ori_version = check_com_version_of_loadbuild(build_version=original_build,
                                                         fw_name="PS").split("REL_")[-1]
        # build_origin = string.split(original_build, ".")[-1]
        build_origin = re.split("[_.]",
                                original_build)[-2] + "." + re.split("[_.]",
                                                                     original_build)[-1]

        no = 0
        relation = compare_release_of_loadbuilds(
            original_build, list(candidates[0])[0])
        for item in candidates:
            no += 1
            key, value = list(item.items())[0]
            print("The PS version of {} is {}.".format(key, value))
            # build_traget = string.split(key, ".")[-1]
            build_traget = re.split("[_.]", item)[-2] + \
                "." + re.split("[_.]", item)[-1]
            can_version = value.split("REL_")[-1]

            if relation == "intra-release" and float(
                    build_origin) <= float(build_traget):
                continue
            if (relation == "intra-release" and condition is None) \
                    or (relation == "inter-release" and condition is None):
                winner = key
                return winner
            if (can_version == ori_version and expected_result is True) or\
                    (can_version != ori_version and expected_result is False):
                winner = key
                print("Congrats! The winner out of the {} candidates is #{}: {}!".format(len(candidates),
                      no, winner))
                return winner
    except Exception as error:
        print("Exception: {}.".format(error))
    if winner is None:
        print(
            "Sorry, none of the {} candidates is eligible!".format(
                len(candidates)))
    return winner


def filter_target_loadbuild_from_candidates(
        original_build, candidates, conditions=None):
    """
    filter out the target loadbuild from all candidate loadbuild, by setting a condition that indicates
    with same version of a certain, or, with different fireware version.

    :param original_build: current loadbuild
    :param candidates: list, a certain number of released/released with restriction loadbuilds.
    :param conditions: dict, eg.{"PS": "same", "rf_5GB4": "diff", "xxx": "Same"},
    for RU, passing SW package version via the key of condition item is recommanded.
    if None return the last candidate build that is older that original build.
    :return: if found, return the latest loadbuild that meet the condition. if not found, return None.
    """
    ori_versions = []
    can_versions = []
    target_res = []
    winner = None
    no = 0
    if conditions is not None:
        for key, value in conditions.items():
            if key != "ps" and key not in FW_NAMES.keys():
                FW_NAMES.update({"ANO_" + Common.upper(key): [key]})
                # print(FW_NAMES)
                key = "ANO_" + key
                # print(key)
            ori_versions.append(
                check_com_version_of_loadbuild(
                    build_version=original_build,
                    fw_name=key))
            if value.lower() == "same":
                target_res.append(True)
            elif value.lower() == "diff":
                target_res.append(False)
            else:
                print("Wrong input for conditions!")

    # print("origin versions are {}.". format(ori_versions))
    # print("target result should be {}.".format(target_res))
    relation = compare_release_of_loadbuilds(original_build, candidates[0])
    # build_origin = string.split(original_build, ".")[-1]
    build_origin = re.split("[_.]", original_build)[-2] + \
        "." + re.split("[_.]", original_build)[-1]
    for item in candidates:
        no += 1
        # build_traget = string.split(item, ".")[-1]
        build_traget = re.split("[_.]", item)[-2] + \
            "." + re.split("[_.]", item)[-1]
        print(
            "origin is: {} target is : {}".format(
                build_origin,
                build_traget))
        if relation == "intra-release" and float(
                build_origin) <= float(build_traget):
            continue
        if (relation == "intra-release" and conditions is None) \
                or (relation == "inter-release" and conditions is None):
            winner = item
            return winner
        for key, value in conditions.items():
            if key != "ps" and key not in FW_NAMES.keys():
                key = "ANO_" + key
            can_versions.append(
                check_com_version_of_loadbuild(
                    build_version=item, fw_name=key))
        cnt = 0
        for i in range(len(ori_versions)):
            # print("time {} of {}.".format(i, len(ori_versions)))
            if (ori_versions[i] == can_versions[i]) == target_res[i]:
                cnt += 1
            else:
                continue
        if cnt == len(ori_versions):
            winner = item
            print(
                "Congrats! The winner out of the {} candidates is #{}: {}!".format(
                    len(candidates), no, winner))
            return winner
        else:
            can_versions = []
    if winner is None:
        print(
            "Sorry, none of the {} candidates is eligible!".format(
                len(candidates)))
    return winner


def compare_release_of_loadbuilds(original_build, target_build):
    """
    Compare two loadbuilds to see if they are in the same release.

    :param original_build: build name like 5G_0.800.123, 5G21A_11.800.2
    :param target_build: another build name like 5G_0.800.456, 5G21A_11.800.2
    :return: a string indicating the comparision result: intra-release if in the same release.
        inter-release if not in the same release.
    """
    compare_result = None
    b1 = original_build.split("_")
    b2 = target_build.split("_")
    if verify_loadbuild_format(
            original_build) and verify_loadbuild_format(target_build):
        if b1[0] == b2[0]:
            compare_result = "intra-release"
        else:
            compare_result = "inter-release"
    return compare_result


def compare_firemware_of_loadbuilds(original_build, target_build, firmware):
    """
     Compare two loadbuilds to see if they are in the same release.

     :param original_build: build name like 5G_0.800.123, 5G21A_11.800.2
     :param target_build: another build name like 5G_0.800.456, 5G21A_11.800.2
     :param firmware: the fireware or sw component name, eg. PS, if RU, it should be ru name like AEQN, AEQB, etc.
     :return: a string indicating the comparision result: True if in they have the same version. False if not.
     """
    compare_result = None
    if not verify_loadbuild_format(
            original_build) or not verify_loadbuild_format(target_build):
        print("Invalid loadbuid format!")
        return
    fm_version_b1 = check_com_version_of_loadbuild(build_version=original_build, com_project=SW_NAMES[firmware][0],
                                                   com_name=SW_NAMES[firmware][1])
    fm_version_b2 = check_com_version_of_loadbuild(build_version=target_build, com_project=SW_NAMES[firmware][0],
                                                   com_name=SW_NAMES[firmware][1])
    if fm_version_b1 == fm_version_b2:
        compare_result = True
    else:
        compare_result = False
    return compare_result


def main():
    # CLI
    # to be updated to add the functionality of select loadbuild by conditions
    parser = argparse.ArgumentParser(
        description="Check the component version of a trunk load-build.")
    parser.add_argument(
        "BuildVersion",
        help="Load build. e.g. 5G_0.800.2704")
    parser.add_argument(
        "ComponentName",
        help="Component name. e.g. PS")

    args = parser.parse_args()

    # Validate arguments
    my_loadbuild = args.BuildVersion
    my_comname = args.ComponentName

    if not BUILD_REGEX.match(my_loadbuild):
        sys.exit("Invalid build version {}. \n Exit!".format(my_loadbuild))

    # check component version on WFT
    print("Query {} on WFT!".format(my_loadbuild))
    get_comp_data_from_wft_succeed, component_data_in_wft = get_comp_data_from_wft(
        my_loadbuild)
    if not get_comp_data_from_wft_succeed:
        sys.exit("Query WFT failed. \n Exit!")

    com_version = check_component_version(my_comname, component_data_in_wft)

    print("The {} version of {} is : {}.".format(
        my_comname, my_loadbuild, com_version))


if __name__ == '__main__':
    main()
