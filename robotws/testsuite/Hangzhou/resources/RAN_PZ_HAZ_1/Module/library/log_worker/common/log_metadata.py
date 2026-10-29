# -*- coding: utf-8 -*-
"""
Author: Liu, Renhui
Contacts: renhui-david.liu@nokia-sbell.com
"""

import os
from common_utils import load_yaml_to_dict

LOG_METADATA_FILENAME = "log_metadata.yml"
SITE_TYPE_Cloud = "_CloudRAN"
SITE_TYPE_Classical = "_ClassicalBTS"
CLOUDRAN_TRUNK_PREFIX = "vDUCNF00"


def load_log_metadata(log_path):
    """
    *Usage:*
        - Keyword
        - This keyword is used to load log metadata.
    *Contact:*
        - renhui-david.liu@nokia-sbell.com
    """
    if not os.path.exists(log_path):
        return None

    if os.path.isfile(log_path):
        log_path = os.path.dirname(log_path)

    log_metadata_file_path = os.path.join(log_path, LOG_METADATA_FILENAME)
    if not os.path.exists(log_metadata_file_path):
        return None
    log_metadata = load_yaml_to_dict(log_metadata_file_path)
    return log_metadata


def get_log_directory(log_path):
    """
    *Usage:*
        - Keyword
        - This keyword is used to get log directory if log_path is a file.
    *Contact:*
        - renhui-david.liu@nokia-sbell.com
    """
    if not os.path.exists(log_path):
        return None

    if os.path.isfile(log_path):
        log_path = os.path.dirname(log_path)
    return log_path


def determine_site_type(log_metadata):
    """
    *Usage:*
        - Keyword
        - This keyword is used to determine site type.
    *Contact:*
        - renhui-david.liu@nokia-sbell.com
    """
    product_type = log_metadata['product_type']
    if product_type in ['gnb', 'enb']:
        return SITE_TYPE_Classical
    if product_type in ['vdu', 'vcu']:
        return SITE_TYPE_Cloud


def get_bts_version_in_url(log_path):
    """
    *Usage:*
        - Keyword
        - This keyword is used to get bts version in download url.
    *Contact:*ss
        - renhui-david.liu@nokia-sbell.com
    """
    log_metadata = load_log_metadata(log_path)
    bts_version = log_metadata["bts_version"]
    site_type = determine_site_type(log_metadata)
    bts_version_in_url = ""
    if site_type == SITE_TYPE_Cloud:
        bts_version_in_url = get_cloudran_bts_version_in_url(bts_version)
    if site_type == SITE_TYPE_Classical:
        bts_version_in_url = get_classical_bts_version_in_url(bts_version)
    return bts_version_in_url


def get_cloudran_bts_version_in_url(bts_version):
    """
    *Usage:*
        - Keyword
        - This keyword is used to get cloudRAN bts version in download url.
    *Contact:*
        - renhui-david.liu@nokia-sbell.com
    """
    split_version = bts_version.split('_')
    version = split_version[1].split('.')
    bts_version_in_url = bts_version
    if version[0] == '0':
        bts_version_in_url = f"{CLOUDRAN_TRUNK_PREFIX}_{split_version[1]}"
    return bts_version_in_url


def get_classical_bts_version_in_url(bts_version):
    """
    *Usage:*
        - Keyword
        - This keyword is used to get classical bts version in download url.
    *Contact:*
        - renhui-david.liu@nokia-sbell.com
    """
    split_version = bts_version.split('_')
    header, trunk_flag = split_version[0], split_version[2]
    if trunk_flag == '9999':
        header = 'SBTS00'
    version_part = "_".join(split_version[1:])
    bts_version_in_url = f"{header}_{version_part}"
    return bts_version_in_url
