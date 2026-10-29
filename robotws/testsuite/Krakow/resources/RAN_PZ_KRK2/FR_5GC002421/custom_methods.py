# -*- coding: utf-8 -*-
"""
author: Grzegorz Kaczor, grzegorz.kaczor@nokia.com
maintainer: Grzegorz Kaczor, grzegorz.kaczor@nokia.com
Description: Methods for 2038 Secure Boot ABIO
"""

import os
import logging
from json import JSONDecoder


def verify_file_exists(file):
    assert os.path.isfile(file), "Given file: {} does not exist".format(file)


def check_if_file_exists(file):
    return os.path.isfile(file)


def parse_long_software_version_to_short_and_previous(software_version, trunk_substitution="SBTS00"):
    """
    This function get software version in 5G19A_FSMK_0006_028351_000211 form and return the pair of short version
    software recent and previous build e.g. 5G19A_6.28351.211 5G19A_6.28351.210

    :param software_version: long version of software e.g. 5G19A_FSMK_0006_028351_000211
    """
    split_software = software_version.split("_")
    release = split_software[0]
    if not split_software[3].startswith("0"):
        release = trunk_substitution
    split_software[2] = split_software[2].lstrip("0")
    split_software[3] = split_software[3].lstrip("0")
    split_software[4] = split_software[4].lstrip("0")
    if len(split_software[2]) == 0:
        split_software[2] = "0"
    try:
        previous = str(int(split_software[4])-1)
        previous = split_software[2] + "." + split_software[3] + "." + previous
    except ValueError as e:
        previous = str(int(split_software[3])-1)
        split_software[4] = "0"
        previous = split_software[2] + "." + previous + "." + split_software[4]
    shorten = split_software[2] + "." + split_software[3] + "." + split_software[4]
    return shorten, previous, release


def parse_sbts_software_version(software_version):
    split_software = software_version.split(".")
    sbts_software = "{}_{}_{}".format(split_software[0].zfill(4), split_software[1].zfill(6),
                                      split_software[2].zfill(6))
    return sbts_software


def parse_admin_response(response):
    decoder = JSONDecoder()
    while len(response) > 0:
        (json_data, index) = decoder.raw_decode(response)
        if json_data['requestStatus'] != 'ongoing':
            logging.debug("Returned output: {}".format(response))
            return json_data
        response = response[index + 1:].strip()
    return {}


def parse_compact_admin_response(response):
    decoder = JSONDecoder()
    lines = response.splitlines()
    for result in lines:
        (json_data, index) = decoder.raw_decode(result)
        if json_data['requestStatus'] != 'ongoing':
            logging.debug("Returned output: {}".format(response))
            return json_data
    return {}
