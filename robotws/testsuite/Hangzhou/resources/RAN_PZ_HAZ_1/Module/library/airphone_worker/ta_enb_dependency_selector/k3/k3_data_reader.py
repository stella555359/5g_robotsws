# -*- coding: utf-8 -*-

import re

MANIFEST_BASE_URL = 'http://files.ute.nsn-rdnet.net/builds/enb/base/{}/Manifest.ini'
CPLAN_TRUNK_BASE_URL = 'BTS_SC_CPLANE/trunk'
CPLAN_TAG_BASE_URL = 'BTS_SC_CPLANE/tags'
K3_TAG_BASE_URL = 'BTS_D_K3LTEASN1/tags'
K3_PCMD_BASE_URL = 'BTS_D_K3NSETAP_ASN1/tags'

# This code is for temporary solution during FB16.09l
K3_TRUNK_BASE_URL = 'BTS_D_K3LTEASN1/trunk'


def read_manifest(manifest_path):
    """
    Reads the contents of the Manifest.ini path

    :param string manifest_path:    Path to Manifest.ini

    :return:                        Dictionary version of the contents of Manifest.ini
    """
    ret = {}
    with open(manifest_path, 'r') as f:
        for line in f:
            if '=' in line:
                key, value = line.split('=')
                ret[key.strip()] = value.strip()
    return ret


def get_k3lteasn1(config_fsm_path):
    """
    Reads the contents of config_fsm_path and returns the value of K3LTEASN1

    :param string config_fsm_path:      Path to config_fsm3 or config_fsm4

    :return:                K3LTEASN1 value
    """
    with open(config_fsm_path, 'r') as f:
        for line in f:
            if re.search('K3LTEASN1', line):
                return line.split()[1]
