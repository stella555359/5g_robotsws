# -*- coding: utf-8 -*-
"""
:copyright: Nokia Networks
:mantainer: Michal Maczek
:contact: michal.maczek@nokia.com
:team: I_5GSC_SW_ENG_KRK_VRF_GMS
:email: I_5GSC_SW_ENG_KRK_VRF_GMS <I_5GSC_SW_ENG_KRK_VRF@internal.nsn.com>
"""

import os

SKIP_REPORT_TO_QC = False

CURDIR = '{}'.format(os.path.dirname(os.path.realpath(__file__)))
QFI_VONR = '2'
GNB_IP = '192.168.255.129'
AP_IP = '192.168.200.129'
NOKIA_USERNAME = 'toor4nsn'
NOKIA_PASS = "oZPS0POrRieRtu"
WEBEM_USERNAME = 'Nemuadmin'
WEBEM_PASS = 'nemuuser'
TEMP_DIR_TTI = '/home/ute/bs/robotlogs/B103_TTITRACE_3UE/'

IPHY_DIR_PATH_DEFAULT = '/opt/iphy/latest'
WTS_CFG = os.path.join(CURDIR, 'configs/SA/basic_setup.cfg')
EDAEMON_PORT = '22222'
EGATE_PORT = '20000'
SIB_RECEPTION_DICT_SA_SANSA = {2: [1]}
SIB_RECEPTION_DICT_SA_FDD = {2: [3]}
DO_NOT_ALLOW_FIRST_REBOOT = False

SYSCOM_FILE_NAME = 'syscom.pcap'
IS_SYSCOM = True

TRAFFIC_DIR_DL = 'dl'
FDD_CELL_ID = '3'

X2_LINK_TIMEOUT = '20'

WTS_CONFIGS = {
    'SA': {
        'TDD': {
            'default': os.path.join(CURDIR, 'configs/SA/TDD/basic_setup.cfg'),
            'VONR': os.path.join(CURDIR, 'configs/SA/TDD/basic_setup_VONR.cfg'),
            'CA_1PLMN': None,
            'CA_3PLMN': None,
            '3plmn': os.path.join(CURDIR, 'configs/SA/TDD/basic_setup_3PLMN.cfg'),
            'fdm_bl_kl': os.path.join(CURDIR, 'configs/SA/TDD/basic_setup.cfg')
        },
        'FDD': {
            'default': os.path.join(CURDIR, 'configs/SA/FDD/basic_setup.cfg'),
            'VONR': os.path.join(CURDIR, 'configs/SA/FDD/basic_setup_VONR.cfg'),
            'CA_1PLMN': os.path.join(CURDIR, 'configs/SA/FDD/basic_setup_CA_1PLMN.cfg'),
            'CA_3PLMN': os.path.join(CURDIR, 'configs/SA/FDD/basic_setup_CA_3PLMN.cfg'),
            '3plmn': os.path.join(CURDIR, 'configs/SA/FDD/basic_setup_3PLMN.cfg'),
            'fdm_bl_kl': os.path.join(CURDIR, 'configs/SA/FDD/basic_setup_FDM_BL_KL.cfg')
        }
    },
    'NSA': {
        'TDD': {
            'default': os.path.join(CURDIR, 'configs/NSA/TDD/basic_setup_NSA.cfg'),
            'VONR': os.path.join(CURDIR, 'configs/NSA/TDD/basic_setup_VONR_TDD_NSA.cfg'),
            'CA_1PLMN': None,
            'c_3plmn': None,
            'dl_prb_share': os.path.join(CURDIR, 'configs/NSA/TDD/basic_setup_dl_prb_share_TDD.cfg')
        },
        'FDD': {
            'default': os.path.join(CURDIR, 'configs/NSA/FDD/basic_setup_NSA.cfg'),
            'VONR': os.path.join(CURDIR, 'configs/NSA/FDD/basic_setup_VONR_FDD_NSA.cfg'),
            'CA_1PLMN': os.path.join(CURDIR, 'configs/NSA/FDD/basic_setup_1PLMN_NSA.cfg'),
            'c_3plmn': os.path.join(CURDIR, 'configs/NSA/FDD/basic_setup_c_3plmn_NSA.cfg'),
            'dl_prb_share': None
        }
    }
}

DELTAS = {
    'SA': {
        "TDD": {
            "quotas_fdm_setup": os.path.join(CURDIR, "configs/SA/TDD/DELTA-B-TDD.json"),
            'vonr': os.path.join(CURDIR, "configs/SA/TDD/DELTA-B-VONR-TDD.json"),
            "fdm_disabled": os.path.join(CURDIR, "configs/SA/TDD/DELTA-B-FDM-DISABLED.json"),
            'ca_1plmn_3slices': None,
            'ca_3plmn_3slices': None,
            '3plmn': None,
            'change_online1': os.path.join(CURDIR, 'configs/SA/TDD/DELTA-B-TDD-CHANGE-ONLINE-3SLICES.json'),
            "change_2_to_4_slice": os.path.join(CURDIR, "configs/SA/TDD/DELTA-CHANGE-ONLINE-SLICE_2_TO_4-TDD.json")
        },
        "FDD": {
            "quotas_fdm_setup": os.path.join(CURDIR, "configs/SA/FDD/DELTA-B-FDD.json"),
            "fdm_disabled": None,
            'vonr': os.path.join(CURDIR, "configs/SA/FDD/DELTA-B-VONR-FDD.json"),
            'ca_1plmn_3slices': os.path.join(CURDIR, "configs/SA/FDD/DELTA-B-FDD-CA-1PLMN.json"),
            'ca_3plmn_3slices': os.path.join(CURDIR, "configs/SA/FDD/DELTA-B-FDD-CA-3PLMN.json"),
            '3plmn': os.path.join(CURDIR, "configs/SA/FDD/DELTA-B-3PLMN-FDD.json"),
            'change_online1': None,
            "change_2_to_4_slice": None
        }
    },
    'NSA': {
        "FDD": {
            "1nsa_slice": os.path.join(CURDIR, "configs/NSA/FDD/DELTA_1NSA_slices.json"),
            '2nsa_slices': os.path.join(CURDIR, 'configs/NSA/FDD/DELTA_2NSA_slices.json'),
            "1nsa_1sa_slice": None,
            "3nsa_1sa_slice": os.path.join(CURDIR, "configs/NSA/FDD/DELTA_3NSA_slices.json"),
            "6nsa_slice": None,
            'vonr': os.path.join(CURDIR, "configs/NSA/FDD/DELTA-C-VONR-FDD.json"),
            'ca_1plmn_2slices': os.path.join(CURDIR, 'configs/NSA/FDD/DELTA-C-1PLMN-CA.json'),
            "ca_3plmn_3slices": os.path.join(CURDIR, "configs/NSA/FDD/DELTA_C_3PLMN.json"),
            'dl_prb_share_3_nsa_slices': None,
            'dl_prb_share_1_nsa_2_sa_slices': None
        },
        "TDD": {
            "1nsa_slice": None,
            '2nsa_slices': None,
            "1nsa_1sa_slice": None,
            "3nsa_1sa_slice": os.path.join(CURDIR, "configs/NSA/TDD/DELTA_3NSA_slices.json"),
            "6nsa_slice": os.path.join(CURDIR, "configs/NSA/TDD/DELTA_6NSA_slices.json"),
            'vonr': os.path.join(CURDIR, "configs/NSA/TDD/DELTA-C-VONR-TDD.json"),
            'ca_1plmn_2slices': None,
            "ca_3plmn_3slices": None,
            'dl_prb_share_3_nsa_slices':
                os.path.join(CURDIR, 'configs/NSA/TDD/DELTA_C_3_NSA_SLICES_NSA_ONLY_TDD.json'),
            'dl_prb_share_1_nsa_2_sa_slices':
                os.path.join(CURDIR, 'configs/NSA/TDD/DELTA_C_1_NSA_2_SA_SLICES_TDD.json')
        }
    }
}

DELTA_QUOTAS_DEFAULT = os.path.join(CURDIR, "configs/SA/DELTA_QUOTAs.json")
DELTA_3QUOTAS_DEFAULT = os.path.join(CURDIR, "configs/SA/DELTA_3QUOTAs.json")
DELTA_REMOVE_SLICES = os.path.join(CURDIR, "configs/SA/DELTA-REMOVE-SLICES.json")
DELTA_QUOTA_DEFAULT = os.path.join(CURDIR, "configs/NSA/DELTA_QUOTA.json")
DELTA_QUOTA_6_SLICE = os.path.join(CURDIR, "configs/NSA/DELTA_QUOTA_6_SLICE.json")

SCF_DIR = "/home/ute/testline_init_results/execution/configs/topology_configs/"
BASIC_SCF_FILE = \
    os.path.join(SCF_DIR, "SANSA_FS_CPRI_CMWV_FDD+ECPRI_CMWV_TDD_AEQE/scfc.xml")
BASIC_SCF_FILE_CA = \
    os.path.join(SCF_DIR, "SANSA_FS_ECPRI_CMWV_FDD+TDD/scfc.xml")

CELL_ID = '1'
ENB_ID = '1'
GNB_ID = '2'
UE_ID_1 = '1'
UE_ID_2 = '2'
UE_ID_3 = '3'
UE_ID_4 = '4'
UE_ID_11 = '11'
UE_ID_12 = '12'
UE_ID_13 = '13'
PDU_ID_1 = '1'
PDU_ID_2 = '2'
PDU_ID_3 = '3'
PDU_ID_4 = '4'
NWSLICE_ID_1 = '1'
NWSLICE_ID_2 = '2'
NWSLICE_ID_3 = '3'
NWSLICE_ID_4 = '4'
BEARER_ID_2 = '2'
BEARER_ID_3 = '3'
BEARER_ID_4 = '4'
PLMN_ID_0 = '0'
PLMN_ID_1 = '1'
PLMN_ID_2 = '2'
PLMN_ID_3 = '3'
GW_ID_1 = '1'
GW_ID_2 = '2'
GW_ID_3 = '3'
GW_ID_4 = '4'
PDU_GW_IP = '10.0.2.1'
TPUT_PORT = '7070'
PACKET_SIZE = '1400'
QOS_TO_ADD_VONR = '2'
TRAFFIC_ID_1 = '1'
TRAFFIC_ID_2 = '2'
TRAFFIC_ID_3 = '3'
TRAFFIC_ID_4 = '4'
TRAFFIC_ID_5 = '5'
TRAFFIC_ID_6 = '6'
TRAFFIC_ID_7 = '7'
TRAFFIC_ID_8 = '8'
TRAFFIC_ID_9 = '9'

RESOURCE_GROUP_ID_1 = '1'
RESOURCE_GROUP_ID_2 = '2'
RESOURCE_GROUP_ID_3 = '3'
RESOURCE_GROUP_ID_4 = '4'

MCC_311 = '311'
MNC_489 = '489'
MCC_312 = '312'
MNC_490 = '490'
MCC_313 = '313'
MNC_491 = '491'
MCC_314 = '314'
MNC_492 = '492'
MCC_315 = '315'
MNC_493 = '493'
MCC_316 = '316'
MNC_494 = '494'

PLMN_PER_RESOURCE_GROUP = {
    'RESOURCE_GROUP_ID_1': {
        'MCC': MCC_311,
        'MNC': MNC_489
    },
    'RESOURCE_GROUP_ID_2': {
        'MCC': MCC_312,
        'MNC': MNC_490
    },
    'RESOURCE_GROUP_ID_3': {
        'MCC': MCC_313,
        'MNC': MNC_491
    },
}

UE_PLMN_DEFAULT = MCC_311 + ":" + MNC_489
UE_PLMN_312_490 = MCC_312 + ":" + MNC_490
UE_PLMN_313_491 = MCC_313 + ":" + MNC_491
UE_PLMN_314_492 = MCC_314 + ":" + MNC_492
UE_PLMN_315_493 = MCC_315 + ":" + MNC_493
UE_PLMN_316_494 = MCC_316 + ":" + MNC_494

DL_PRB_SHARE_PLMN_LIST = {
    '1': {'mcc': MCC_311, 'mnc': MNC_489},
    '2': {'mcc': MCC_311, 'mnc': MNC_489},
    '3': {'mcc': MCC_311, 'mnc': MNC_489},
    '4': {'mcc': MCC_311, 'mnc': MNC_489},
    '11': {'mcc': MCC_311, 'mnc': MNC_489},
    '12': {'mcc': MCC_311, 'mnc': MNC_489},
}

VONR_PLMN_LIST = {
    '1': {'mcc': MCC_311, 'mnc': MNC_489},
    '2': {'mcc': MCC_311, 'mnc': MNC_489},
    '3': {'mcc': MCC_311, 'mnc': MNC_489},
    '4': {'mcc': MCC_311, 'mnc': MNC_489},
    '11': {'mcc': MCC_312, 'mnc': MNC_490},
    '12': {'mcc': MCC_313, 'mnc': MNC_491},
}

CA_1PLMN_LIST = {
    '1': {'mcc': MCC_311, 'mnc': MNC_489},
    '2': {'mcc': MCC_311, 'mnc': MNC_489},
    '3': {'mcc': MCC_311, 'mnc': MNC_489}
}

CA_3PLMN_LIST = {
    '1': {'mcc': MCC_311, 'mnc': MNC_489},
    '2': {'mcc': MCC_312, 'mnc': MNC_490},
    '3': {'mcc': MCC_313, 'mnc': MNC_491}
}

SNSSAI_1 = 'SNSSAI-1'
NRPLMN_1 = 'NRPLMN-1'
NRPLMN_2 = 'NRPLMN-2'
NRPLMN_3 = 'NRPLMN-3'


RESOURCEGROUP_DN_LIST_C_3PLMN = [SNSSAI_1, NRPLMN_2, NRPLMN_3]

PLMN_LIST_C_3PLMN = [PLMN_ID_0, PLMN_ID_1, PLMN_ID_2]

MCC_MNC_LIST_C_1PLMN = {
    NRPLMN_1: {'mcc': MCC_311, 'mnc': MNC_489},
    SNSSAI_1: {'mcc': MCC_311, 'mnc': MNC_489}
}

MCC_MNC_LIST_C_3PLMN = {
    SNSSAI_1: {'mcc': MCC_311, 'mnc': MNC_489},
    NRPLMN_2: {'mcc': MCC_312, 'mnc': MNC_490},
    NRPLMN_3: {'mcc': MCC_313, 'mnc': MNC_491}
}

RESOURCE_DN_LIST_CA_1PLMN_2SLICES = [
    NRPLMN_1, SNSSAI_1
]

UE_IP_DL = {
    'TDD': ['1.2.4.2', '1.2.4.3', '1.2.4.4', '1.2.4.5'],
    'FDD': ['1.2.4.2', '1.2.4.3', '1.2.4.4', '1.2.4.5']
}

THPUT_RANGE = '100'
THPUT_EXPECTED_VALUE = '500'
SCELL = 'secondary'
UE_STATS_TYPE = 'pusch'

SECONDS30_DURATION = '30'
UL_TPUT = '50m'

BH_ETH3_IP_ADDR = \
    ['10.0.1.1', '10.0.1.121', '10.0.1.131', '10.0.1.133', '10.0.1.134', '10.0.1.135', '10.0.1.136', '10.0.1.137']
BH_ETH4_IP_ADDR = ['10.0.2.1', '10.0.2.121']

ENABLE_WTS_START = 'True'
DISABLE_WTS_START = ' False'

# Standard Counters
M55359C00000 = 'M55359C00000'
M55359C00001 = 'M55359C00001'
M55308C10007 = 'M55308C10007'
M55328C00003 = 'M55328C00003'
COUNTERS_STD_LIST = [M55359C00000, M55359C00001, M55308C10007, M55328C00003]

DL_PRB_AVAIL_SAS = 'M55308C10013'
PRB_AVAIL_PDSCH_SLICES = "M55308C10007"
DL_PRB_USED_DATA_NRG = 'M55910C00001'
DL_PRB_UTIL_SLOT_MAX_NRG = 'M55910C00002'

COUNTERS_PRB_DL = [DL_PRB_AVAIL_SAS, DL_PRB_USED_DATA_NRG, DL_PRB_UTIL_SLOT_MAX_NRG]
# VONR Counters
M55310C01001 = 'M55310C01001'
COUNTERS_VONR_LIST = [M55310C01001]
# CA Counters
M55138C01501 = 'M55138C01501'
M55138C01502 = 'M55138C01502'
M55311C42006 = 'M55311C42006'
M55311C44006 = 'M55311C44006'
M55311C42007 = 'M55311C42007'
M55311C44007 = 'M55311C44007'
M55311C42008 = 'M55311C42008'
M55311C44008 = 'M55311C44008'
COUNTERS_CA_LIST = [M55138C01501, M55138C01502, M55311C42006, M55311C44006, M55311C42007, M55311C44007, M55311C42008,
                    M55311C44008]

M55338C01000 = 'M55338C01000'
M55338C01001 = 'M55338C01001'
M55326C00001 = 'M55326C00001'

COUNTERS_STD_NSA_LIST = [M55338C01001, M55338C01000, M55326C00001]

# successful radio admissions Counters
M55115C00015 = 'M55115C00015'

M55319C02008 = 'M55319C02008'

C_3PLMN_3UE_COUNTERS_LIST = [M55115C00015, M55311C42008, M55311C44008, M55319C02008]

SHOULD_PRINT_DICTS = True
OVERR_ERR_RAISE_DURING_VONR_VALIDATION = True
OVERRIDE_ERROR_RAISE_DURING_CA_MAX_UTI_VALIDATION = True

COUNTER_MAX_UTI_RATIO_MARGIN = 4
COUNTER_MAX_UTI_RATIO_VONR_MARGIN = 40
COUNTER_TPUT_MARGIN = 15
COUNTER_CA_TPUT_RATIO_MARGIN = 5

MAX_TPUT_PCELL = '135'
MAX_TPUT_SCELL = '320'

C_3PLMN_SCELL = 3
C_3PLMN_PCELL = 1

MAX_TPUT_BOTH_SUBCELLS = str(int(MAX_TPUT_PCELL) + int(MAX_TPUT_SCELL))
BIP_MCSHARK_PATH = '/home/ute/.local/lib/wireshark/plugins/4.0/epan'
MAX_TPUT_BOTH_SUBCELLS_TEMP = '1000'

ALIAS_TSHARK_SHERPA = "ALIAS_TSHARK_SHERPA"
SHERPA_L2PS = "L2Ps"
SHERPA_L2HIPDCP = "L2HiPdcp"
SHERPA_TYPES = [SHERPA_L2PS, SHERPA_L2HIPDCP]
SHERPA_SOURCE_IP = '10.0.1.2'
SHERPA_DESTINATION_IP = '10.0.1.1'
SHERPA_PORT = 5678
SHERPA_DSCP = 32
SHERPA_ETH_INTERFACE = "eth4"
SHERPA_PREFIX = "sherpa_8132_"

COLLECTOR_NAME = 'l2stream3'
TTITRACE_NAME_PREFIX = 'ttitrace_8132_'

SYSLOG_NAME_PREFIX = "syslog_8132_"
SYSLOG_ALIAS = "ALIAS_SYSLOG_GNB"

SNAPSHOT_NAME_PREFIX = "snapshot_8132_"

HW_TYPE_ASIB_ABIO = "ASIB_ABIO"
BIP_ASIB_ABIO_SCRIPTS_LIST = [
    '{}/scripts/bip_mirroring_ABIO.sh'.format(CURDIR)
]
BIP_ASIB_ABIO_OUTPUT_FILE = '/tmp/bip.pcap'
BIP_TERMINATE_ASIB_ABIO_NAME = 'bip.pcap'

HW_TYPE_ASIL_ABIO = "ASIL_ABIO"
BIP_ASIL_ABIO_SCRIPTS_LIST = [
    '{}/scripts/gnbMirroring.sh'.format(CURDIR),
    '{}/scripts/gnbMirroringConfig.sh'.format(CURDIR)
]
BIP_ASIL_ABIO_OUTPUT_FILE = '/tmp/tcpdump_L2L1_bip_filtering_on.pcap0'
BIP_TERMINATE_ASIL_ABIO_NAME = 'tcpdump_L2L1_bip_filtering_on.pcap'

LUASHARK_ROOT_PATH = '/opt/luashark'
ENABLE_MCSHARK_USAGE = True
BIP_MSG_CELLSETUPREQ = 'itf_l2_ps_cell_cellsetupreq'
BIP_FILTER_CELLSETUPREQ = '-Y "{}"'.format(BIP_MSG_CELLSETUPREQ)
BIP_MSG_CELLRECONFREQ = 'itf_l2_ps_cell_cellreconfigurationreq'
BIP_FILTER_CELLRECONFREQ = '-Y "{}"'.format(BIP_MSG_CELLRECONFREQ)

VALID_SYSLOG_FEATURE_ACTIVATED = '\"sliceAwareSchedulerCellActivation\":true'
VALID_SYSLOG_PLMN_CONFIG_LIST = "plmnConfigList"

VALID_SYSLOG_QUOTAS_CONFIG_REGEXP = r'CellSetupReq: plmn: \d has slices: \d:\d+ ' + \
                                    r'{minQuota: (?P<MINQUOTA_1>\d+), maxQuota: (?P<MAXQUOTA_1>\d+)},\s*\d+:\d+ ' + \
                                    r'{minQuota: (?P<MINQUOTA_2>\d+), maxQuota: (?P<MAXQUOTA_2>\d+)}'
VALID_SYSLOG_CONFIG_REGEXP_SECOND_SLICE = r'CellSetupReq: plmn: [1-9] has slices: \d:\d+ ' + \
                                          r'{minQuota: (?P<MINQUOTA>\d+), maxQuota: (?P<MAXQUOTA>\d+)}'

VALID_SYSLOG_CONFIG_REGEXP_SINGLE_QUOTA = r'CellSetupReq: nsaResourceGroup for plmn: (?P<PLMN>\d) has minimum quota' +\
                                          r': (and )?(?P<MINQUOTA>\d+) (and )?maximum quota: (?P<MAXQUOTA>\d+)'
VALID_SYSLOG_CONFIG_REGEXP_DOUBLE_QUOTA_1ST_REGEXP = VALID_SYSLOG_CONFIG_REGEXP_SINGLE_QUOTA
VALID_SYSLOG_CONFIG_REGEXP_DOUBLE_QUOTA_2ND_REGEXP = r'CellSetupReq: plmn: (?P<PLMN>\d).* has slices: \d:\d+ ' + \
                                                     r'{minQuota: (?P<MINQUOTA>\d+), maxQuota: (?P<MAXQUOTA>\d+)}'


VALID_BIP_CELLGRP_ID_REGEXP = r'nrCellGrpId \(Uint16\): (?P<CELLGRP_ID>\d+)'
VALID_BIP_FEATURE_ACTIVATED = 'sliceAwareSchedulerCellActivation (Boolean): True'
VALID_BIP_SLICE_LIST_SPLIT_TEXT = 'sliceList_item_'
VALID_BIP_NSA_SLICE_LIST_SPLIT_TEXT = 'nsaResourceGroup_'
VALID_BIP_MINQUOTA_REGEXP = r'minQuota \(Uint8\): (?P<MINQUOTA>\d+)'
VALID_BIP_MAXQUOTA_REGEXP = r'maxQuota \(Uint8\): (?P<MAXQUOTA>\d+)'
VALID_BIP_SD_REGEXPS = [
    r'sd_item_0 \(Uint8\): (?P<SDVALUE>\d+)',
    r'sd_item_1 \(Uint8\): (?P<SDVALUE>\d+)',
    r'sd_item_2 \(Uint8\): (?P<SDVALUE>\d+)'
]

ENABLE_FDM_SCHEDULING = 'true'
DISABLE_FDM_SCHEDULING = 'false'

TRUE = 'True'
FALSE = 'False'

SKIP_SA_STD_COUNTERS_DL_PRB_SHARE_NSA_ONLY = True
SKIP_SA_STD_COUNTERS_DL_PRB_SHARE_NSA_SA = False
SKIP_SA_STD_COUNTERS_ALLOCATED_PRBS_NSA = True
SKIP_SA_STD_COUNTERS_CELL_RECONFIGURATION_NSA = True

CELL_TDD = '1'
CELL_FDD = '1'

SD_VALUES = ['13714341', '2', '3', '4']
NSA_SD_VALUES = ['13714341', '16777215']

NWSLICE_1_SET_CMD_REGEXP = 'nwslice_set id=1'
NWSLICE_2_SET_WTS_CMD = 'nwslice_set id=2 snssai=0x01:0x02 ue=all amf=1'

HARDCODED_QUOTA_RANGE_DEFAULT = {"min": '0', "max": '100'}
UTILIZATION_MARGIN_ONE_SLICE = 1
UTILIZATION_MARGIN = 3
UTILIZATION_MARGIN_4 = 4
UTILIZATION_MARGIN_VONR = 10

TPUTS_1RG = [100]
TPUTS_2RG = [100, 100]
TPUTS_3RG = [100, 100, 100]
TPUTS_4RG_VONR = [100, 80, 80, 80]
DL_PRB_USED_COUNTERS_6RG_TDD = {"M55910C00001": {'1': "BTS/MRBTS-1/NRBTS-1/NRCELL-1/NRRESOURCEGROUP-1/NCUPNRG",
                                                 '2': "BTS/MRBTS-1/NRBTS-1/NRCELL-1/NRRESOURCEGROUP-2/NCUPNRG",
                                                 '3': "BTS/MRBTS-1/NRBTS-1/NRCELL-1/NRRESOURCEGROUP-3/NCUPNRG",
                                                 '4': "BTS/MRBTS-1/NRBTS-1/NRCELL-1/NRRESOURCEGROUP-4/NCUPNRG",
                                                 '5': "BTS/MRBTS-1/NRBTS-1/NRCELL-1/NRRESOURCEGROUP-5/NCUPNRG",
                                                 '6': "BTS/MRBTS-1/NRBTS-1/NRCELL-1/NRRESOURCEGROUP-6/NCUPNRG"}}

DL_PRB_MAX_UTIL_COUNTERS_6RG_TDD = {"M55910C00002": {'1': "BTS/MRBTS-1/NRBTS-1/NRCELL-1/NRRESOURCEGROUP-1/NCUPNRG",
                                                     '2': "BTS/MRBTS-1/NRBTS-1/NRCELL-1/NRRESOURCEGROUP-2/NCUPNRG",
                                                     '3': "BTS/MRBTS-1/NRBTS-1/NRCELL-1/NRRESOURCEGROUP-3/NCUPNRG",
                                                     '4': "BTS/MRBTS-1/NRBTS-1/NRCELL-1/NRRESOURCEGROUP-4/NCUPNRG",
                                                     '5': "BTS/MRBTS-1/NRBTS-1/NRCELL-1/NRRESOURCEGROUP-5/NCUPNRG",
                                                     '6': "BTS/MRBTS-1/NRBTS-1/NRCELL-1/NRRESOURCEGROUP-6/NCUPNRG"}}

DL_PRB_AVAIL_COUNTERS_6RG_TDD = {"M55308C10013": {'1': "BTS/MRBTS-1/NRBTS-1/NRCELL-1/NCELA",
                                                  '2': "BTS/MRBTS-1/NRBTS-1/NRCELL-1/NCELA",
                                                  '3': "BTS/MRBTS-1/NRBTS-1/NRCELL-1/NCELA",
                                                  '4': "BTS/MRBTS-1/NRBTS-1/NRCELL-1/NCELA",
                                                  '5': "BTS/MRBTS-1/NRBTS-1/NRCELL-1/NCELA",
                                                  '6': "BTS/MRBTS-1/NRBTS-1/NRCELL-1/NCELA"}}

DL_PRB_USED_COUNTERS_4RG_FDD = {"M55910C00001": {'1': "BTS/MRBTS-1/NRBTS-1/NRCELL-3/NRRESOURCEGROUP-1/NCUPNRG",
                                                 '2': "BTS/MRBTS-1/NRBTS-1/NRCELL-3/NRRESOURCEGROUP-2/NCUPNRG",
                                                 '3': "BTS/MRBTS-1/NRBTS-1/NRCELL-3/NRRESOURCEGROUP-3/NCUPNRG",
                                                 '4': "BTS/MRBTS-1/NRBTS-1/NRCELL-3/NRRESOURCEGROUP-4/NCUPNRG"}}

DL_PRB_MAX_UTIL_COUNTERS_4RG_FDD = {"M55910C00002": {'1': "BTS/MRBTS-1/NRBTS-1/NRCELL-3/NRRESOURCEGROUP-1/NCUPNRG",
                                                     '2': "BTS/MRBTS-1/NRBTS-1/NRCELL-3/NRRESOURCEGROUP-2/NCUPNRG",
                                                     '3': "BTS/MRBTS-1/NRBTS-1/NRCELL-3/NRRESOURCEGROUP-3/NCUPNRG",
                                                     '4': "BTS/MRBTS-1/NRBTS-1/NRCELL-3/NRRESOURCEGROUP-4/NCUPNRG"}}

DL_PRB_AVAIL_COUNTERS_4RG_FDD = {"M55308C10013": {'1': "BTS/MRBTS-1/NRBTS-1/NRCELL-3/NCELA",
                                                  '2': "BTS/MRBTS-1/NRBTS-1/NRCELL-3/NCELA",
                                                  '3': "BTS/MRBTS-1/NRBTS-1/NRCELL-3/NCELA",
                                                  '4': "BTS/MRBTS-1/NRBTS-1/NRCELL-3/NCELA"}}

DL_PRB_USED_COUNTERS_3RG_TDD = {"M55910C00001": {'1': "BTS/MRBTS-1/NRBTS-1/NRCELL-1/NRRESOURCEGROUP-1/NCUPNRG",
                                                 '2': "BTS/MRBTS-1/NRBTS-1/NRCELL-1/NRRESOURCEGROUP-2/NCUPNRG",
                                                 '3': "BTS/MRBTS-1/NRBTS-1/NRCELL-1/NRRESOURCEGROUP-3/NCUPNRG"}}

DL_PRB_MAX_UTIL_COUNTERS_3RG_TDD = {"M55910C00002": {'1': "BTS/MRBTS-1/NRBTS-1/NRCELL-1/NRRESOURCEGROUP-1/NCUPNRG",
                                                     '2': "BTS/MRBTS-1/NRBTS-1/NRCELL-1/NRRESOURCEGROUP-2/NCUPNRG",
                                                     '3': "BTS/MRBTS-1/NRBTS-1/NRCELL-1/NRRESOURCEGROUP-3/NCUPNRG"}}

DL_PRB_USED_COUNTERS_3RG_TDD_CA = {"M55910C00001": {'1': "BTS/MRBTS-1/NRBTS-1/NRCELL-1/NRRESOURCEGROUP-2/NCUPNRG",
                                                    '2': "BTS/MRBTS-1/NRBTS-1/NRCELL-1/NRRESOURCEGROUP-1/NCUPNRG",
                                                    '3': "BTS/MRBTS-1/NRBTS-1/NRCELL-1/NRRESOURCEGROUP-3/NCUPNRG"}}

DL_PRB_MAX_UTIL_COUNTERS_3RG_TDD_CA = {"M55910C00002": {'1': "BTS/MRBTS-1/NRBTS-1/NRCELL-1/NRRESOURCEGROUP-2/NCUPNRG",
                                                        '2': "BTS/MRBTS-1/NRBTS-1/NRCELL-1/NRRESOURCEGROUP-1/NCUPNRG",
                                                        '3': "BTS/MRBTS-1/NRBTS-1/NRCELL-1/NRRESOURCEGROUP-3/NCUPNRG"}}

DL_PRB_AVAIL_COUNTERS_3RG_TDD = {"M55308C10013": {'1': "BTS/MRBTS-1/NRBTS-1/NRCELL-1/NCELA",
                                                  '2': "BTS/MRBTS-1/NRBTS-1/NRCELL-1/NCELA",
                                                  '3': "BTS/MRBTS-1/NRBTS-1/NRCELL-1/NCELA"}}

DL_PRB_USED_COUNTERS_3RG_FDD_VONR = {"M55910C00001": {'1': "BTS/MRBTS-1/NRBTS-1/NRCELL-3/NRRESOURCEGROUP-2/NCUPNRG",
                                                      '2': "BTS/MRBTS-1/NRBTS-1/NRCELL-3/NRRESOURCEGROUP-3/NCUPNRG",
                                                      '3': "BTS/MRBTS-1/NRBTS-1/NRCELL-3/NRRESOURCEGROUP-4/NCUPNRG"}}

DL_PRB_MAX_UTIL_COUNTERS_3RG_FDD_VONR = \
    {"M55910C00002": {'1': "BTS/MRBTS-1/NRBTS-1/NRCELL-3/NRRESOURCEGROUP-2/NCUPNRG",
                      '2': "BTS/MRBTS-1/NRBTS-1/NRCELL-3/NRRESOURCEGROUP-3/NCUPNRG",
                      '3': "BTS/MRBTS-1/NRBTS-1/NRCELL-3/NRRESOURCEGROUP-4/NCUPNRG"}}

DL_PRB_USED_COUNTERS_3RG_FDD = {"M55910C00001": {'1': "BTS/MRBTS-1/NRBTS-1/NRCELL-3/NRRESOURCEGROUP-1/NCUPNRG",
                                                 '2': "BTS/MRBTS-1/NRBTS-1/NRCELL-3/NRRESOURCEGROUP-2/NCUPNRG",
                                                 '3': "BTS/MRBTS-1/NRBTS-1/NRCELL-3/NRRESOURCEGROUP-3/NCUPNRG"}}

DL_PRB_MAX_UTIL_COUNTERS_3RG_FDD = {"M55910C00002": {'1': "BTS/MRBTS-1/NRBTS-1/NRCELL-3/NRRESOURCEGROUP-1/NCUPNRG",
                                                     '2': "BTS/MRBTS-1/NRBTS-1/NRCELL-3/NRRESOURCEGROUP-2/NCUPNRG",
                                                     '3': "BTS/MRBTS-1/NRBTS-1/NRCELL-3/NRRESOURCEGROUP-3/NCUPNRG"}}

DL_PRB_AVAIL_COUNTERS_3RG_FDD = {"M55308C10013": {'1': "BTS/MRBTS-1/NRBTS-1/NRCELL-3/NCELA",
                                                  '2': "BTS/MRBTS-1/NRBTS-1/NRCELL-3/NCELA",
                                                  '3': "BTS/MRBTS-1/NRBTS-1/NRCELL-3/NCELA"}}

DL_PRB_USED_COUNTERS_3RG_FDD_CA = {"M55910C00001": {'1': "BTS/MRBTS-1/NRBTS-1/NRCELL-2/NRRESOURCEGROUP-1/NCUPNRG",
                                                    '2': "BTS/MRBTS-1/NRBTS-1/NRCELL-2/NRRESOURCEGROUP-2/NCUPNRG",
                                                    '3': "BTS/MRBTS-1/NRBTS-1/NRCELL-2/NRRESOURCEGROUP-3/NCUPNRG"}}

DL_PRB_MAX_UTIL_COUNTERS_3RG_FDD_CA = {"M55910C00002": {'1': "BTS/MRBTS-1/NRBTS-1/NRCELL-2/NRRESOURCEGROUP-1/NCUPNRG",
                                                        '2': "BTS/MRBTS-1/NRBTS-1/NRCELL-2/NRRESOURCEGROUP-2/NCUPNRG",
                                                        '3': "BTS/MRBTS-1/NRBTS-1/NRCELL-2/NRRESOURCEGROUP-3/NCUPNRG"}}

DL_PRB_AVAIL_COUNTERS_3RG_FDD_CA = {"M55308C10013": {'1': "BTS/MRBTS-1/NRBTS-1/NRCELL-2/NCELA",
                                                     '2': "BTS/MRBTS-1/NRBTS-1/NRCELL-2/NCELA",
                                                     '3': "BTS/MRBTS-1/NRBTS-1/NRCELL-2/NCELA"}}

DL_PRB_USED_COUNTERS_2RG_TDD = {"M55910C00001": {'1': "BTS/MRBTS-1/NRBTS-1/NRCELL-1/NRRESOURCEGROUP-1/NCUPNRG",
                                                 '2': "BTS/MRBTS-1/NRBTS-1/NRCELL-1/NRRESOURCEGROUP-2/NCUPNRG"}}

DL_PRB_MAX_UTIL_COUNTERS_2RG_TDD = {"M55910C00002": {'1': "BTS/MRBTS-1/NRBTS-1/NRCELL-1/NRRESOURCEGROUP-1/NCUPNRG",
                                                     '2': "BTS/MRBTS-1/NRBTS-1/NRCELL-1/NRRESOURCEGROUP-2/NCUPNRG"}}

DL_PRB_USED_COUNTERS_2RG_TDD_CA = {"M55910C00001": {'1': "BTS/MRBTS-1/NRBTS-1/NRCELL-1/NRRESOURCEGROUP-2/NCUPNRG",
                                                    '2': "BTS/MRBTS-1/NRBTS-1/NRCELL-1/NRRESOURCEGROUP-1/NCUPNRG"}}

DL_PRB_MAX_UTIL_COUNTERS_2RG_TDD_CA = {"M55910C00002": {'1': "BTS/MRBTS-1/NRBTS-1/NRCELL-1/NRRESOURCEGROUP-2/NCUPNRG",
                                                        '2': "BTS/MRBTS-1/NRBTS-1/NRCELL-1/NRRESOURCEGROUP-1/NCUPNRG"}}

DL_PRB_AVAIL_COUNTERS_2RG_TDD = {"M55308C10013": {'1': "BTS/MRBTS-1/NRBTS-1/NRCELL-1/NCELA",
                                                  '2': "BTS/MRBTS-1/NRBTS-1/NRCELL-1/NCELA"}}

DL_PRB_USED_COUNTERS_2RG_FDD_VONR = {"M55910C00001": {'1': "BTS/MRBTS-1/NRBTS-1/NRCELL-3/NRRESOURCEGROUP-2/NCUPNRG",
                                                      '2': "BTS/MRBTS-1/NRBTS-1/NRCELL-3/NRRESOURCEGROUP-3/NCUPNRG"}}

DL_PRB_MAX_UTIL_COUNTERS_2RG_FDD_VONR = \
    {"M55910C00002": {'1': "BTS/MRBTS-1/NRBTS-1/NRCELL-3/NRRESOURCEGROUP-2/NCUPNRG",
                      '2': "BTS/MRBTS-1/NRBTS-1/NRCELL-3/NRRESOURCEGROUP-3/NCUPNRG"}}

DL_PRB_USED_COUNTERS_2RG_FDD = {"M55910C00001": {'1': "BTS/MRBTS-1/NRBTS-1/NRCELL-3/NRRESOURCEGROUP-1/NCUPNRG",
                                                 '2': "BTS/MRBTS-1/NRBTS-1/NRCELL-3/NRRESOURCEGROUP-2/NCUPNRG"}}

DL_PRB_MAX_UTIL_COUNTERS_2RG_FDD = {"M55910C00002": {'1': "BTS/MRBTS-1/NRBTS-1/NRCELL-3/NRRESOURCEGROUP-1/NCUPNRG",
                                                     '2': "BTS/MRBTS-1/NRBTS-1/NRCELL-3/NRRESOURCEGROUP-2/NCUPNRG"}}

DL_PRB_AVAIL_COUNTERS_2RG_FDD = {"M55308C10013": {'1': "BTS/MRBTS-1/NRBTS-1/NRCELL-3/NCELA",
                                                  '2': "BTS/MRBTS-1/NRBTS-1/NRCELL-3/NCELA"}}

DL_PRB_USED_COUNTERS_2RG_FDD_CA = {"M55910C00001": {'1': "BTS/MRBTS-1/NRBTS-1/NRCELL-2/NRRESOURCEGROUP-1/NCUPNRG",
                                                    '2': "BTS/MRBTS-1/NRBTS-1/NRCELL-2/NRRESOURCEGROUP-2/NCUPNRG"}}

DL_PRB_MAX_UTIL_COUNTERS_2RG_FDD_CA = {"M55910C00002": {'1': "BTS/MRBTS-1/NRBTS-1/NRCELL-2/NRRESOURCEGROUP-1/NCUPNRG",
                                                        '2': "BTS/MRBTS-1/NRBTS-1/NRCELL-2/NRRESOURCEGROUP-2/NCUPNRG"}}

DL_PRB_AVAIL_COUNTERS_2RG_FDD_CA = {"M55308C10013": {'1': "BTS/MRBTS-1/NRBTS-1/NRCELL-2/NCELA",
                                                     '2': "BTS/MRBTS-1/NRBTS-1/NRCELL-2/NCELA"}}

DL_PRB_USED_COUNTERS_1RG_TDD = {"M55910C00001": {'1': "BTS/MRBTS-1/NRBTS-1/NRCELL-1/NRRESOURCEGROUP-1/NCUPNRG"}}

DL_PRB_MAX_UTIL_COUNTERS_1RG_TDD = {"M55910C00002": {'1': "BTS/MRBTS-1/NRBTS-1/NRCELL-1/NRRESOURCEGROUP-1/NCUPNRG"}}

DL_PRB_USED_COUNTERS_1RG_TDD_CA = {"M55910C00001": {'1': "BTS/MRBTS-1/NRBTS-1/NRCELL-1/NRRESOURCEGROUP-2/NCUPNRG"}}

DL_PRB_MAX_UTIL_COUNTERS_1RG_TDD_CA = {"M55910C00002": {'1': "BTS/MRBTS-1/NRBTS-1/NRCELL-1/NRRESOURCEGROUP-2/NCUPNRG"}}

DL_PRB_AVAIL_COUNTERS_1RG_TDD = {"M55308C10013": {'1': "BTS/MRBTS-1/NRBTS-1/NRCELL-1/NCELA"}}

DL_PRB_USED_COUNTERS_1RG_FDD_VONR = {"M55910C00001": {'1': "BTS/MRBTS-1/NRBTS-1/NRCELL-3/NRRESOURCEGROUP-2/NCUPNRG"}}

DL_PRB_MAX_UTIL_COUNTERS_1RG_FDD_VONR = \
    {"M55910C00002": {'1': "BTS/MRBTS-1/NRBTS-1/NRCELL-3/NRRESOURCEGROUP-2/NCUPNRG"}}

DL_PRB_USED_COUNTERS_1RG_FDD = {"M55910C00001": {'1': "BTS/MRBTS-1/NRBTS-1/NRCELL-3/NRRESOURCEGROUP-1/NCUPNRG"}}

DL_PRB_MAX_UTIL_COUNTERS_1RG_FDD = {"M55910C00002": {'1': "BTS/MRBTS-1/NRBTS-1/NRCELL-3/NRRESOURCEGROUP-1/NCUPNRG"}}

DL_PRB_AVAIL_COUNTERS_1RG_FDD = {"M55308C10013": {'1': "BTS/MRBTS-1/NRBTS-1/NRCELL-3/NCELA"}}

DL_PRB_USED_COUNTERS_1RG_FDD_CA = {"M55910C00001": {'1': "BTS/MRBTS-1/NRBTS-1/NRCELL-2/NRRESOURCEGROUP-1/NCUPNRG"}}

DL_PRB_MAX_UTIL_COUNTERS_1RG_FDD_CA = {"M55910C00002": {'1': "BTS/MRBTS-1/NRBTS-1/NRCELL-2/NRRESOURCEGROUP-1/NCUPNRG"}}

DL_PRB_AVAIL_COUNTERS_1RG_FDD_CA = {"M55308C10013": {'1': "BTS/MRBTS-1/NRBTS-1/NRCELL-2/NCELA"}}

QUOTAS_EXPECTED_B101 = [
    {
        "min": '10',
        "max": '80'
    },
    {
        "min": '20',
        "max": '60'
    }
]

QUOTAS_EXPECTED_B102 = [
    {
        "min": '1',
        "max": '15'
    },
    {
        "min": '70',
        "max": '100'
    }
]

QUOTAS_EXPECTED_B104_1 = [
    {
        "min": '10',
        "max": '50'
    },
    {
        "min": '10',
        "max": '50'
    }
]

QUOTAS_EXPECTED_B601 = [
    {
        "min": '10',
        "max": '80'
    },
    {
        "min": '20',
        "max": '60'
    }
]

QUOTAS_EXPECTED_B601_RECONF = [
    {
        "min": '50',
        "max": '80'
    },
    {
        "min": '50',
        "max": '60'
    }
]
DYN_SUBSTITUTE_B_VONR_FDD_4_SLICE = {
    'quotas': {
        "$resourceGroup1_minQuota": '30',
        "$resourceGroup1_maxQuota": '80',
        "$resourceGroup2_minQuota": '20',
        "$resourceGroup2_maxQuota": '20',
        "$resourceGroup3_minQuota": '40',
        "$resourceGroup3_maxQuota": '60',
        "$resourceGroup4_minQuota": '10',
        "$resourceGroup4_maxQuota": '10',
    }
}
DYN_SUBSTITUTE_B_VONR_FDD_3_SLICE = {
    'quotas': {
        "$resourceGroup1_minQuota": '20',
        "$resourceGroup1_maxQuota": '20',
        "$resourceGroup2_minQuota": '40',
        "$resourceGroup2_maxQuota": '60',
        "$resourceGroup3_minQuota": '10',
        "$resourceGroup3_maxQuota": '10'
    }
}
DYN_SUBSTITUTE_B_VONR_FDD_2_SLICE = {
    'quotas': {
        "$resourceGroup1_minQuota": '20',
        "$resourceGroup1_maxQuota": '20',
        "$resourceGroup2_minQuota": '40',
        "$resourceGroup2_maxQuota": '60'
    }
}
DYN_SUBSTITUTE_B_VONR_FDD_1_SLICE = {
    'quotas': {
        "$resourceGroup1_minQuota": '20',
        "$resourceGroup1_maxQuota": '20'
    }
}
QUOTAS_EXPECTED_B_VONR = [
    {
        "min": '30',
        "max": '80'
    },
    {
        "min": '20',
        "max": '20'
    },
    {
        "min": '40',
        "max": '60'
    },
    {
        "min": '10',
        "max": '10'
    }
]

QUOTAS_EXPECTED_C_1PLMN = [
    {
        "min": '40',
        "max": '60'
    },
    {
        "min": '20',
        "max": '60'
    }
]

QUOTAS_EXPECTED_C_VONR = [
    {
        "min": '20',
        "max": '45'
    },
    {
        "min": '10',
        "max": '70'
    },
    {
        "min": '10',
        "max": '80'
    }
]

QUOTAS_EXPECTED_C_017 = [
    {
        "min": '2',
        "max": '40'
    }
]

QUOTAS_EXPECTED_C_004 = [
    {
        "min": '30',
        "max": '70'
    }
]

QUOTAS_EXPECTED_C_B101 = [
    {
        "min": '10',
        "max": '10'
    },
    {
        "min": '50',
        "max": '80'
    }
]

QUOTAS_EXPECTED_C_CA_1PLMN = {

    'NRPLMN-1': {
        "min": '40',
        "max": '60'
    },
    'SNSSAI-1': {
        "min": '20',
        "max": '60'
    }
}

QUOTAS_EXPECTED_C_3PLMN = {
    'SNSSAI-1': {
        "min": '50',
        "max": '50'
    },
    'NRPLMN-2': {
        "min": '25',
        "max": '25'
    },
    'NRPLMN-3': {
        "min": '15',
        "max": '15'
    }
}

DYN_SUBSTITUTE_C_B301_TDD_6_SLICE = {
    'quotas': {
        "$resourceGroup1_minQuota": '10',
        "$resourceGroup1_maxQuota": '10',
        "$resourceGroup2_minQuota": '20',
        "$resourceGroup2_maxQuota": '20',
        "$resourceGroup3_minQuota": '30',
        "$resourceGroup3_maxQuota": '30',
        "$resourceGroup4_minQuota": '15',
        "$resourceGroup4_maxQuota": '15',
        "$resourceGroup5_minQuota": '5',
        "$resourceGroup5_maxQuota": '5',
        "$resourceGroup6_minQuota": '20',
        "$resourceGroup6_maxQuota": '20'
    }
}

QUOTAS_EXPECTED_C_B301 = [
    {
        "min": '10',
        "max": '10'
    },
    {
        "min": '20',
        "max": '20'
    },
    {
        "min": '30',
        "max": '30'
    },
    {
        "min": '15',
        "max": '15'
    },
    {
        "min": '5',
        "max": '5'
    },
    {
        "min": '20',
        "max": '20'
    }
]

DYN_SUBSTITUTE_C_B301_RECONF_TDD_6_SLICE = {
    'quotas': {
        "$resourceGroup1_minQuota": '5',
        "$resourceGroup1_maxQuota": '10',
        "$resourceGroup2_minQuota": '5',
        "$resourceGroup2_maxQuota": '20',
        "$resourceGroup3_minQuota": '10',
        "$resourceGroup3_maxQuota": '20',
        "$resourceGroup4_minQuota": '10',
        "$resourceGroup4_maxQuota": '30',
        "$resourceGroup5_minQuota": '15',
        "$resourceGroup5_maxQuota": '20',
        "$resourceGroup6_minQuota": '15',
        "$resourceGroup6_maxQuota": '30'
    }
}

QUOTAS_EXPECTED_C_B301_RECONF = [
    {
        "min": '5',
        "max": '10'
    },
    {
        "min": '5',
        "max": '20'
    },
    {
        "min": '10',
        "max": '20'
    },
    {
        "min": '10',
        "max": '30'
    },
    {
        "min": '15',
        "max": '20'
    },
    {
        "min": '15',
        "max": '30'
    }
]

DYN_SUBSTITUTE_C_B301_FDD_3_SLICE = {
    'quotas': {
        "$resourceGroup1_minQuota": '20',
        "$resourceGroup1_maxQuota": '80',
        "$resourceGroup2_minQuota": '30',
        "$resourceGroup2_maxQuota": '40',
        "$resourceGroup3_minQuota": '10',
        "$resourceGroup3_maxQuota": '90'
    }
}

QUOTAS_EXPECTED_C_B301_FDD = [
    {
        "min": '20',
        "max": '80'
    },
    {
        "min": '30',
        "max": '40'
    },
    {
        "min": '10',
        "max": '90'
    }
]

DYN_SUBSTITUTE_C_B301_RECONF_FDD_3_SLICE = {
    'quotas': {
        "$resourceGroup1_minQuota": '5',
        "$resourceGroup1_maxQuota": '25',
        "$resourceGroup2_minQuota": '35',
        "$resourceGroup2_maxQuota": '45',
        "$resourceGroup3_minQuota": '20',
        "$resourceGroup3_maxQuota": '100'
    }
}


QUOTAS_EXPECTED_C_B301_RECONF_FDD = [
    {
        "min": '5',
        "max": '25'
    },
    {
        "min": '35',
        "max": '45'
    },
    {
        "min": '20',
        "max": '100'
    }
]

QUOTAS_EXPECTED_MAX_SLICES = [
    {
        "min": '2',
        "max": '40'
    }
]

VONR_TPUT_SLICE_LISTS = ['1', '2', '3']
VONR_SPEC_SLICE_LIST = '0'

DYN_SUBSTITUE_CA_3PLMN_1_SLICE = {
    'quotas': {
        "$resourceGroup1_minQuota": '25',
        "$resourceGroup1_maxQuota": '25'
    }
}

DYN_SUBSTITUE_CA_3PLMN_2_SLICE = {
    'quotas': {
        "$resourceGroup1_minQuota": '25',
        "$resourceGroup1_maxQuota": '25',
        "$resourceGroup2_minQuota": '50',
        "$resourceGroup2_maxQuota": '50'
    }
}

DYN_SUBSTITUE_CA_3PLMN_3_SLICE = {
    'quotas': {
        "$resourceGroup1_minQuota": '25',
        "$resourceGroup1_maxQuota": '25',
        "$resourceGroup2_minQuota": '50',
        "$resourceGroup2_maxQuota": '50',
        "$resourceGroup3_minQuota": '15',
        "$resourceGroup3_maxQuota": '15'
    }
}

QUOTAS_EXPECTED_B_CA_1PLMN = [
    {
        "min": '25',
        "max": '25'
    },
    {
        "min": '50',
        "max": '50'
    },
    {
        "min": '15',
        "max": '15'
    }
]
QUOTAS_EXPECTED_B_CA_3PLMN = QUOTAS_EXPECTED_B_CA_1PLMN
QUOTAS_EXPECTED_B_3PLMN = QUOTAS_EXPECTED_B_CA_1PLMN

QUOTAS_EXPECTED_B_021 = [
    {
        "min": '10',
        "max": '80'
    },
    {
        "min": '20',
        "max": '60'
    },
    {
        "min": '30',
        "max": '90'
    }
]

QUOTAS_EXPECTED_B_021_RECONF = [
    {
        "min": '50',
        "max": '90'
    },
    {
        "min": '50',
        "max": '60'
    },
    {
        "min": '20',
        "max": '80'
    }
]

QUOTAS_EXPECTED_C_DL_PRB_SHARE_NSA_ONLY = [
    {
        "min": '30',
        "max": '80'
    },
    {
        "min": '20',
        "max": '20'
    },
    {
        "min": '40',
        "max": '60'
    }
]

DYN_SUBSTITUTE_C_DL_PRB_SHARE_1_NSA_2_SA = {
    'quotas': {
        "$resourceGroup1_minQuota": '50',
        "$resourceGroup1_maxQuota": '50',
        "$resourceGroup2_minQuota": '30',
        "$resourceGroup2_maxQuota": '80',
        "$resourceGroup3_minQuota": '20',
        "$resourceGroup3_maxQuota": '20'
    }
}

QUOTAS_EXPECTED_C_DL_PRB_SHARE_1_NSA_2_SA = [
    {
        "min": '50',
        "max": '50'
    },
    {
        "min": '30',
        "max": '80'
    },
    {
        "min": '20',
        "max": '20'
    }
]

QC_TESTCASES_TITLES = {
    'TDD': {
        # CB008132 -B SA -------------------------------------------------------------------------
        "B101": '[1]CB008132_B_002_B101_slice_aware_scheduler_check_quota_info_TDD',
        'B102': '[1]CB008132_B_004_B102_slice_aware_scheduler_calculate_dynamic_weight_TDD',
        'B102_fdm_disabled': '[1]CB008132_B_006_B102_slice_aware_scheduler_fdm_disabled_TDD',
        'B103': '[1]CB008132_B_012_B1_slice_aware_scheduler_verification_dl_prb_share_TDD',
        'B104': '[1]CB008132_B_008_B104_check_maximum_utilization_counter_TDD',
        'B601': '[1]CB008132_B_010_B601_slice_aware_scheduler_check_reconfiguration_quota_info_TDD',
        'B_VONR': '[1]CB008132_B_016_IWK3_slice_aware_scheduler_with_VoNR_enabled_TDD',
        'B021': '[1]CB008132_B_022_B6_slice_aware_scheduler_changing_configuration_online_TDD',
        # CB008132 -C NSA -------------------------------------------------------------------------
        'C101': '[1]CB008132_C_002_B101_slice_aware_scheduler_calculate_dynamic_weight_with_NSA_TDD',
        'C102': '[1]CB008132_C_004_B102_allocated_PRBs_for_NSA_counters_TDD',
        'C301': '[1]CB008132_C_006_B301_slice_aware_scheduler_cell_reconfiguration_with NSA_TDD',
        'C011': '[1]CB008132_C_012_B3_slice_aware_scheduler_changing_configuration_online_with_NSA_SA_TDD',
        'C_VONR': '[1]CB008132_C_016_IWK4_slice_aware_scheduler_with_VoNR_enabled_with_NSA_SA_TDD',
        'C_007_B1': '[1]CB008132_C_008_B1_slice_aware_scheduler_verification_dl_prb_share_with_NSA_only_TDD',
        'C_010_B2': '[1]CB008132_C_010_B2_slice_aware_scheduler_verification_dl_prb_share_with_NSA_SA_TDD'
    },
    'FDD': {
        # CB008132 -B SA -------------------------------------------------------------------------
        "B101": '[1]CB008132_B_001_B101_slice_aware_scheduler_check_quota_info_FDD',
        'B102': '[1]CB008132_B_003_B102_slice_aware_scheduler_calculate_dynamic_weight_FDD',
        'B102_fdm_disabled': '[1]CB008132_B_005_B102_slice_aware_scheduler_fdm_disabled_FDD',
        'B103': '[1]CB008132_B_011_B1_slice_aware_scheduler_verification_dl_prb_share_FDD',
        'B104': '[1]CB008132_B_007_B104_check_maximum_utilization_counter_FDD',
        'B601': '[1]CB008132_B_009_B601_slice_aware_scheduler_check_reconfiguration_quota_info_FDD',
        'B_VONR': '[1]CB008132_B_015_IWK3_slice_aware_scheduler_with_VoNR_enabled_FDD',
        'B021': '[1]CB008132_B_021_B6_slice_aware_scheduler_changing_configuration_online_FDD',
        # CB008132 -C NSA -------------------------------------------------------------------------
        'C101': '[1]CB008132_C_001_B101_slice_aware_scheduler_calculate_dynamic_weight_with_NSA_FDD',
        'C102': '[1]CB008132_C_003_B102_allocated_PRBs_for_NSA_counters_FDD',
        'C301': '[1]CB008132_C_005_B301_slice_aware_scheduler_cell_reconfiguration_with NSA_FDD',
        'C011': '[1]CB008132_C_011_B3_slice_aware_scheduler_changing_configuration_online_with_NSA_SA_FDD',
        'C_VONR': '[1]CB008132_C_015_IWK4_slice_aware_scheduler_with_VoNR_enabled_with_NSA_SA_FDD',
        'C_007_B1': '[1]CB008132_C_007_B1_slice_aware_scheduler_verification_dl_prb_share_with_NSA_only_FDD',
        'C_010_B2': '[1]CB008132_C_009_B2_slice_aware_scheduler_verification_dl_prb_share_with_NSA_SA_FDD'
    },
    'B_CA_1PLMN': '[1]CB008132_B_014_IWK2_slice_aware_scheduler_2CC_TDD_FDD_using_1plmn',
    'B_CA_3PLMN': '[1]CB008132_B_013_IWK2_slice_aware_scheduler_2CC_TDD_FDD_using_3plmns',
    'C_CA_1PLMN': '[1]CB008132_C_014_IWK4_slice_aware_scheduler_2CC_TDD_FDD_using_1plmn_with_NSA_SA',
    'C_CA_3PLMN': '[1]CB008132_C_013_IWK4_slice_aware_scheduler_2CC_TDD_FDD_using_3plmns_with_NSA_SA'
}

_dirname_8132 = 'CB008132_Slice_Aware_Scheduler'
_path_qc_8132 = 'Root\\Test_Sets\\Trunk\\RAN_L2_SW_KRK_2\\{}'.format(_dirname_8132)
_path_qc_22R4_8132 = 'Root\\Test_Sets\\22R4\\Regression\\RAN_L2_SW_KRK_2\\{}'.format(_dirname_8132)
_path_qc_23R1_8132 = 'Root\\Test_Sets\\23R1\\Regression\\RAN_L2_SW_KRK_2\\{}'.format(_dirname_8132)
_projectname_qc_8132_B = 'CB008132-B'
_projectname_qc_8132_C = 'CB008132-C'

QC_DIR_NAMES = {
    'SBTS00': {
        # CB008132 -B SA -------------------------------------------------------------------------
        "B101": {'path': _path_qc_8132, 'project': _projectname_qc_8132_B},
        "B102": {'path': _path_qc_8132, 'project': _projectname_qc_8132_B},
        "B103": {'path': _path_qc_8132, 'project': _projectname_qc_8132_B},
        "B104": {'path': _path_qc_8132, 'project': _projectname_qc_8132_B},
        "B601": {'path': _path_qc_8132, 'project': _projectname_qc_8132_B},
        'B021': {'path': _path_qc_8132, 'project': _projectname_qc_8132_B},
        "B_VONR": {'path': _path_qc_8132, 'project': _projectname_qc_8132_B},
        'B_CA_1PLMN': {'path': _path_qc_8132, 'project': _projectname_qc_8132_B},
        'B_CA_3PLMN': {'path': _path_qc_8132, 'project': _projectname_qc_8132_B},
        # CB008132 -C NSA -------------------------------------------------------------------------
        'C101': {'path': _path_qc_8132, 'project': _projectname_qc_8132_C},
        'C102': {'path': _path_qc_8132, 'project': _projectname_qc_8132_C},
        'C301': {'path': _path_qc_8132, 'project': _projectname_qc_8132_C},
        'C011': {'path': _path_qc_8132, 'project': _projectname_qc_8132_C},
        'C_VONR': {'path': _path_qc_8132, 'project': _projectname_qc_8132_C},
        'C_CA_1PLMN': {'path': _path_qc_8132, 'project': _projectname_qc_8132_C},
        'C_CA_3PLMN': {'path': _path_qc_8132, 'project': _projectname_qc_8132_C},
        'C_007_B1': {'path': _path_qc_8132, 'project': _projectname_qc_8132_C},
        'C_010_B2': {'path': _path_qc_8132, 'project': _projectname_qc_8132_C}
    },
    'SBTS23R1': {
        # CB008132 -B SA -------------------------------------------------------------------------
        "B101": {'path': _path_qc_23R1_8132, 'project': _projectname_qc_8132_B},
        "B102": {'path': _path_qc_23R1_8132, 'project': _projectname_qc_8132_B},
        "B103": {'path': _path_qc_23R1_8132, 'project': _projectname_qc_8132_B},
        "B104": {'path': _path_qc_23R1_8132, 'project': _projectname_qc_8132_B},
        "B601": {'path': _path_qc_23R1_8132, 'project': _projectname_qc_8132_B},
        'B021': {'path': _path_qc_23R1_8132, 'project': _projectname_qc_8132_B},
        "B_VONR": {'path': _path_qc_23R1_8132, 'project': _projectname_qc_8132_B},
        'B_CA_1PLMN': {'path': _path_qc_23R1_8132, 'project': _projectname_qc_8132_B},
        'B_CA_3PLMN': {'path': _path_qc_23R1_8132, 'project': _projectname_qc_8132_B},
        # CB008132 -C NSA -------------------------------------------------------------------------
        'C101': {'path': _path_qc_23R1_8132, 'project': _projectname_qc_8132_C},
        'C102': {'path': _path_qc_23R1_8132, 'project': _projectname_qc_8132_C},
        'C301': {'path': _path_qc_23R1_8132, 'project': _projectname_qc_8132_C},
        'C011': {'path': _path_qc_23R1_8132, 'project': _projectname_qc_8132_C},
        'C_VONR': {'path': _path_qc_23R1_8132, 'project': _projectname_qc_8132_C},
        'C_CA_1PLMN': {'path': _path_qc_23R1_8132, 'project': _projectname_qc_8132_C},
        'C_CA_3PLMN': {'path': _path_qc_23R1_8132, 'project': _projectname_qc_8132_C},
        'C_007_B1': {'path': _path_qc_23R1_8132, 'project': _projectname_qc_8132_C},
        'C_010_B2': {'path': _path_qc_23R1_8132, 'project': _projectname_qc_8132_C}
    },
    'SBTS22R4': {
        # CB008132 -B SA -------------------------------------------------------------------------
        "B101": {'path': _path_qc_22R4_8132, 'project': _projectname_qc_8132_B},
        "B102": {'path': _path_qc_22R4_8132, 'project': _projectname_qc_8132_B},
        "B103": {'path': _path_qc_22R4_8132, 'project': _projectname_qc_8132_B},
        "B104": {'path': _path_qc_22R4_8132, 'project': _projectname_qc_8132_B},
        "B601": {'path': _path_qc_22R4_8132, 'project': _projectname_qc_8132_B},
        'B021': {'path': _path_qc_22R4_8132, 'project': _projectname_qc_8132_B},
        "B_VONR": {'path': _path_qc_22R4_8132, 'project': _projectname_qc_8132_B},
        'B_CA_1PLMN': {'path': _path_qc_22R4_8132, 'project': _projectname_qc_8132_B},
        'B_CA_3PLMN': {'path': _path_qc_22R4_8132, 'project': _projectname_qc_8132_B},
        # CB008132 -C NSA -------------------------------------------------------------------------
        'C101': {'path': _path_qc_22R4_8132, 'project': _projectname_qc_8132_C},
        'C102': {'path': _path_qc_22R4_8132, 'project': _projectname_qc_8132_C},
        'C301': {'path': _path_qc_22R4_8132, 'project': _projectname_qc_8132_C},
        'C011': {'path': _path_qc_22R4_8132, 'project': _projectname_qc_8132_C},
        'C_VONR': {'path': _path_qc_22R4_8132, 'project': _projectname_qc_8132_C},
        'C_CA_1PLMN': {'path': _path_qc_22R4_8132, 'project': _projectname_qc_8132_C},
        'C_CA_3PLMN': {'path': _path_qc_22R4_8132, 'project': _projectname_qc_8132_C},
        'C_007_B1': {'path': _path_qc_22R4_8132, 'project': _projectname_qc_8132_C},
        'C_010_B2': {'path': _path_qc_22R4_8132, 'project': _projectname_qc_8132_C}
    }
}

_desc = 'Krakow VRF Engineering team testcases for CB008132 feature'
_qc_doc = \
    'maintainer: Mateusz Rzeczyca\ndescription:\n{}'.format(_desc)

CB008132_B_ROBOT_FILE_PATH = 'testsuite/Wroclaw/RRM/VRF_WRO1_T04/SAS_ET/CB008132/CB008132-B-TDD.robot'
CB008132_B_PLMNS_ROBOT_FILE_PATH = 'testsuite/Wroclaw/RRM/VRF_WRO1_T04/SAS_ET/CB008132/CB008132-B-PLMNS.robot'
CB008132_C_ROBOT_FILE_PATH = 'testsuite/Wroclaw/RRM/VRF_WRO1_T04/SAS_ET/CB008132/CB008132-C-TDD.robot'

REPORT_QC = {
    'qc_project': "RAN_ET",
    'qc_domain': "MN_RAN",
    'ca': 'RAN_L2_SW_KRK_2',
    'username': 'owner',
    'links': {},
    'add_info': ["UTE", "TAF"],
    'suite_path': None,
    'qc_testlab_path': None,
    'qc_test_set_name': None,
    'features_covered': None,
    'doc': _qc_doc
}

TTI_TRACE_PATH = "/home/ute/logi/trunk/"

# TTI_SLICE_EXPECTED_VALUES_1UE = {
#     "dlSliceData.slicesNumber": 2,
#     "dlSliceData.dlSlicesData[0].sliceId": 0,
#     "dlSliceData.dlSlicesData[0].plmnId": {'plmnIdBytes': [19, 65, 152]},
#     "dlSliceData.dlSlicesData[0].snssai": {'sst': 1, 'sd': [209, 67, 165]},
#     "dlSliceData.dlSlicesData[0].rrmSliceInstShareGbr": 0,
#     "dlSliceData.dlSlicesData[0].rrmSliceInstShareNgbr": 0,
#     "dlSliceData.dlSlicesData[0].rrmSliceAvgShareGbr": 0,
#     "dlSliceData.dlSlicesData[0].rrmSliceAvgShareNgbr": 0,
#     "dlSliceData.dlSlicesData[0].rrmSliceUnusedShare": 0.102273,
#     "dlSliceData.dlSlicesData[0].rrmSliceTargetShareTemp": 0.112732,
#     "dlSliceData.dlSlicesData[0].rrmSliceWeightInterm": 0.112732,
#     "dlSliceData.dlSlicesData[0].rrmSliceWeight": 0.90186,
#     "dlSliceData.dlSlicesData[1].sliceId": 1,
#     "dlSliceData.dlSlicesData[1].plmnId": {'plmnIdBytes': [19, 65, 152]},
#     "dlSliceData.dlSlicesData[1].snssai": {'sst': 1, 'sd': [0, 0, 2]},
#     "dlSliceData.dlSlicesData[1].rrmSliceInstShareGbr": 0,
#     "dlSliceData.dlSlicesData[1].rrmSliceInstShareNgbr": '1 OR 0.765568',
#     "dlSliceData.dlSlicesData[1].rrmSliceAvgShareGbr": 0,
#     "dlSliceData.dlSlicesData[1].rrmSliceAvgShareNgbr": '~0.95 +- 0.05',
#     "dlSliceData.dlSlicesData[1].rrmSliceUnusedShare": 0.102273,
#     "dlSliceData.dlSlicesData[1].rrmSliceTargetShareTemp": 0.98954,
#     "dlSliceData.dlSlicesData[1].rrmSliceWeightInterm": 0.98954,
#     "dlSliceData.dlSlicesData[1].rrmSliceWeight": '~3.995 +- 3.995'
# }

# TTI_DRB_EXPECTED_VALUES_1UE = {
#     "dlDrbWeightData.drbNumber": 1,
#     "dlDrbWeightData.dlDrbsWeightData[0].sliceId": 1,
#     "dlDrbWeightData.dlDrbsWeightData[0].logicalChannelIdentity": 4,
#     "dlDrbWeightData.dlDrbsWeightData[0].rrmDrbCombinedWeight": '~3.995 +- 3.995',
#     "dlDrbWeightData.dlDrbsWeightData[0].rrmDrbFinalWeight": 0,
#     "dlDrbWeightData.dlDrbsWeightData[0].rrmAvgDrbPrbAlloc": '~200 +- 15',
#     "dlDrbWeightData.dlDrbsWeightData[0].rrmAvgDrbPrbExp": '~200 +- 15',
#     "dlDrbWeightData.dlDrbsWeightData[0].rrmInstDrbPrbAlloc": '273 OR 209',
#     "dlDrbWeightData.dlDrbsWeightData[0].rrmDrbInstShare": 0
# }

TTI_EXPECTED_VALUES_1UE = {
    "dlDrbWeightData.dlDrbsWeightData[0].sliceId": {
        1: {
            "dlDrbWeightData.drbNumber": 1,
            "dlDrbWeightData.dlDrbsWeightData[0].sliceId": 1,
            "dlDrbWeightData.dlDrbsWeightData[0].logicalChannelIdentity": 4,
            "dlDrbWeightData.dlDrbsWeightData[0].rrmDrbCombinedWeight": '~3.995 +- 3.995',
            "dlDrbWeightData.dlDrbsWeightData[0].rrmDrbFinalWeight": 0,
            "dlDrbWeightData.dlDrbsWeightData[0].rrmAvgDrbPrbAlloc": '~200 +- 15',
            "dlDrbWeightData.dlDrbsWeightData[0].rrmAvgDrbPrbExp": '~200 +- 15',
            "dlDrbWeightData.dlDrbsWeightData[0].rrmInstDrbPrbAlloc": '273 OR 209',
            "dlDrbWeightData.dlDrbsWeightData[0].rrmDrbInstShare": 0
        }
    },

    "dlSliceData.slicesNumber": {
        2: {
            "dlSliceData.slicesNumber": 2,
            "dlSliceData.dlSlicesData[0].sliceId": 0,
            "dlSliceData.dlSlicesData[0].plmnId": {'plmnIdBytes': [19, 65, 152]},
            "dlSliceData.dlSlicesData[0].snssai": {'sst': 1, 'sd': [209, 67, 165]},
            "dlSliceData.dlSlicesData[0].rrmSliceInstShareGbr": 0,
            "dlSliceData.dlSlicesData[0].rrmSliceInstShareNgbr": 0,
            "dlSliceData.dlSlicesData[0].rrmSliceAvgShareGbr": 0,
            "dlSliceData.dlSlicesData[0].rrmSliceAvgShareNgbr": 0,
            "dlSliceData.rrmSliceUnusedShare": 0.102273,
            # "dlSliceData.dlSlicesData[0].rrmSliceTargetShareTemp": 0.112732,
            # "dlSliceData.dlSlicesData[0].rrmSliceWeightInterm": 0.112732,
            "dlSliceData.dlSlicesData[0].rrmSliceWeight": 0.90186,
            "dlSliceData.dlSlicesData[1].sliceId": 1,
            "dlSliceData.dlSlicesData[1].plmnId": {'plmnIdBytes': [19, 65, 152]},
            "dlSliceData.dlSlicesData[1].snssai": {'sst': 1, 'sd': [0, 0, 2]},
            "dlSliceData.dlSlicesData[1].rrmSliceInstShareGbr": 0,
            "dlSliceData.dlSlicesData[1].rrmSliceInstShareNgbr": '1 OR 0.765568',
            "dlSliceData.dlSlicesData[1].rrmSliceAvgShareGbr": 0,
            "dlSliceData.dlSlicesData[1].rrmSliceAvgShareNgbr": '~0.95 +- 0.05',
            # "dlSliceData.dlSlicesData[1].rrmSliceUnusedShare": 0.102273,
            # "dlSliceData.dlSlicesData[1].rrmSliceTargetShareTemp": 0.98954,
            # "dlSliceData.dlSlicesData[1].rrmSliceWeightInterm": 0.98954,
            "dlSliceData.dlSlicesData[1].rrmSliceWeight": '~3.995 +- 3.995'
        }
    }
}

TTI_EXPECTED_VALUES_3UE = {
    'TDD': {
        'SBTS00': {
            "dlDrbWeightData.dlDrbsWeightData[0].sliceId": {
                '0.0': {
                    "dlDrbWeightData.drbNumber": 1,
                    "dlDrbWeightData.dlDrbsWeightData[0].sliceId": 0,
                    "dlDrbWeightData.dlDrbsWeightData[0].logicalChannelIdentity": 4,
                    "dlDrbWeightData.dlDrbsWeightData[0].rrmDrbCombinedWeight": '~0.45 +- 0.09',
                    "dlDrbWeightData.dlDrbsWeightData[0].rrmDrbFinalWeight": 0,
                    "dlDrbWeightData.dlDrbsWeightData[0].rrmAvgDrbPrbAlloc": '~76 +- 5',
                    "dlDrbWeightData.dlDrbsWeightData[0].rrmAvgDrbPrbExp": '~76 +- 5',
                    "dlDrbWeightData.dlDrbsWeightData[0].rrmInstDrbPrbAlloc": '~105 +- 45'
                },
                '1.0': {
                    "dlDrbWeightData.drbNumber": 1,
                    "dlDrbWeightData.dlDrbsWeightData[0].sliceId": 1,
                    "dlDrbWeightData.dlDrbsWeightData[0].logicalChannelIdentity": 4,
                    "dlDrbWeightData.dlDrbsWeightData[0].rrmDrbCombinedWeight": '~0.24 +- 0.05',
                    "dlDrbWeightData.dlDrbsWeightData[0].rrmDrbFinalWeight": 0,
                    "dlDrbWeightData.dlDrbsWeightData[0].rrmAvgDrbPrbAlloc": '~40 +- 3',
                    "dlDrbWeightData.dlDrbsWeightData[0].rrmAvgDrbPrbExp": '~40 +- 3',
                    "dlDrbWeightData.dlDrbsWeightData[0].rrmInstDrbPrbAlloc": '~55 +- 30'
                },
                '2.0': {
                    "dlDrbWeightData.drbNumber": 1,
                    "dlDrbWeightData.dlDrbsWeightData[0].sliceId": 2,
                    "dlDrbWeightData.dlDrbsWeightData[0].logicalChannelIdentity": 4,
                    "dlDrbWeightData.dlDrbsWeightData[0].rrmDrbCombinedWeight": '~0.52 +- 0.11',
                    "dlDrbWeightData.dlDrbsWeightData[0].rrmDrbFinalWeight": 0,
                    "dlDrbWeightData.dlDrbsWeightData[0].rrmAvgDrbPrbAlloc": '~87 +- 6',
                    "dlDrbWeightData.dlDrbsWeightData[0].rrmAvgDrbPrbExp": '~87 +- 6',
                    "dlDrbWeightData.dlDrbsWeightData[0].rrmInstDrbPrbAlloc": '~120 +- 60'
                        }
            },
            "dlAdditionalSliceData.dlSlicesData": {
                '0.0': {
                    "rrmSliceTargetShareTemp": '~0.43 +- 0.02',
                    "rrmSliceWeightInterm": '~0.43 +- 0.02'
                },
                '1.0': {
                    "rrmSliceTargetShareTemp": '~0.43 +- 0.02',
                    "rrmSliceWeightInterm": '~0.43 +- 0.02'
                },
                '2.0': {
                    "rrmSliceTargetShareTemp": '~0.43 +- 0.02',
                    "rrmSliceWeightInterm": '~0.43 +- 0.02'
                },
            },
            "dlSliceData.slicesNumber": {
                '3.0': {
                    "dlSliceData.slicesNumber": 3,
                    "dlSliceData.rrmAvailablePrbsForSas": 273,
                    "dlSliceData.dlSlicesData[0].sliceId": 0,
                    "dlSliceData.dlSlicesData[0].plmnId": {'mcc': 311, 'mnc': 489, 'mncLength': 3},
                    "dlSliceData.dlSlicesData[0].snssai": {'sst': 1, 'sd': 13714341},
                    "dlSliceData.dlSlicesData[0].rrmSliceHighInstShare": 0,
                    "dlSliceData.dlSlicesData[0].rrmSliceLowInstShare": '~0.27 +- 0.27',
                    "dlSliceData.dlSlicesData[0].rrmSliceAvgHighShare": 0,
                    "dlSliceData.dlSlicesData[0].rrmSliceAvgLowShare": '~0.35 +- 0.03',
                    "dlSliceData.rrmSliceUnusedShare": '~0.03 +- 0.03',
                    # "dlSliceData.dlSlicesData[0].rrmSliceTargetShareTemp": '~0.37 +- 0.02',
                    # "dlSliceData.dlSlicesData[0].rrmSliceWeightInterm": '~0.37 +- 0.02',
                    "dlSliceData.dlSlicesData[0].rrmSliceWeight": '~0.44 +- 0.09',
                    "dlSliceData.dlSlicesData[1].sliceId": 1,
                    "dlSliceData.dlSlicesData[1].plmnId": {'mcc': 311, 'mnc': 490, 'mncLength': 3},
                    "dlSliceData.dlSlicesData[1].snssai": {'sst': 1, 'sd': 2},
                    "dlSliceData.dlSlicesData[1].rrmSliceHighInstShare": 0,
                    "dlSliceData.dlSlicesData[1].rrmSliceLowInstShare": '~0.15 +- 0.15',
                    "dlSliceData.dlSlicesData[1].rrmSliceAvgHighShare": 0,
                    "dlSliceData.dlSlicesData[1].rrmSliceAvgLowShare": '~0.19 +- 0.02',
                    # "dlSliceData.dlSlicesData[1].rrmSliceUnusedShare": '~0.03 +- 0.03',
                    # "dlSliceData.dlSlicesData[1].rrmSliceTargetShareTemp": '0.2 OR -255',
                    # "dlSliceData.dlSlicesData[1].rrmSliceWeightInterm": '0.2 OR -255',
                    "dlSliceData.dlSlicesData[1].rrmSliceWeight": '~0.15 +- 0.15',
                    "dlSliceData.dlSlicesData[2].sliceId": 2,
                    "dlSliceData.dlSlicesData[2].plmnId": {'mcc': 311, 'mnc': 491, 'mncLength': 3},
                    "dlSliceData.dlSlicesData[2].snssai": {'sst': 1, 'sd': 3},
                    "dlSliceData.dlSlicesData[2].rrmSliceHighInstShare": 0,
                    "dlSliceData.dlSlicesData[2].rrmSliceLowInstShare": '~0.30 +- 0.30',
                    "dlSliceData.dlSlicesData[2].rrmSliceAvgHighShare": 0,
                    "dlSliceData.dlSlicesData[2].rrmSliceAvgLowShare": '~0.41 +- 0.02',
                    # "dlSliceData.dlSlicesData[2].rrmSliceUnusedShare": '~0.03 +- 0.03',
                    # "dlSliceData.dlSlicesData[2].rrmSliceTargetShareTemp": '~0.43 +- 0.02',
                    # "dlSliceData.dlSlicesData[2].rrmSliceWeightInterm": '~0.43 +- 0.02',
                    "dlSliceData.dlSlicesData[2].rrmSliceWeight": '~0.52 +- 0.12'
                }
            }
        },
        'SBTS23R1': {
            "dlDrbWeightData.dlDrbsWeightData[0].sliceId": {
                '0.0': {
                    "dlDrbWeightData.drbNumber": 1,
                    "dlDrbWeightData.dlDrbsWeightData[0].sliceId": 0,
                    "dlDrbWeightData.dlDrbsWeightData[0].logicalChannelIdentity": 4,
                    "dlDrbWeightData.dlDrbsWeightData[0].rrmDrbCombinedWeight": '~0.45 +- 0.09',
                    "dlDrbWeightData.dlDrbsWeightData[0].rrmDrbFinalWeight": 0,
                    "dlDrbWeightData.dlDrbsWeightData[0].rrmAvgDrbPrbAlloc": '~76 +- 5',
                    "dlDrbWeightData.dlDrbsWeightData[0].rrmAvgDrbPrbExp": '~76 +- 5',
                    "dlDrbWeightData.dlDrbsWeightData[0].rrmInstDrbPrbAlloc": '~95 +- 55'
                },
                '1.0': {
                    "dlDrbWeightData.drbNumber": 1,
                    "dlDrbWeightData.dlDrbsWeightData[0].sliceId": 1,
                    "dlDrbWeightData.dlDrbsWeightData[0].logicalChannelIdentity": 4,
                    "dlDrbWeightData.dlDrbsWeightData[0].rrmDrbCombinedWeight": '~0.24 +- 0.05',
                    "dlDrbWeightData.dlDrbsWeightData[0].rrmDrbFinalWeight": 0,
                    "dlDrbWeightData.dlDrbsWeightData[0].rrmAvgDrbPrbAlloc": '~40 +- 3',
                    "dlDrbWeightData.dlDrbsWeightData[0].rrmAvgDrbPrbExp": '~40 +- 3',
                    "dlDrbWeightData.dlDrbsWeightData[0].rrmInstDrbPrbAlloc": '~42 +- 28'
                },
                '2.0': {
                    "dlDrbWeightData.drbNumber": 1,
                    "dlDrbWeightData.dlDrbsWeightData[0].sliceId": 2,
                    "dlDrbWeightData.dlDrbsWeightData[0].logicalChannelIdentity": 4,
                    "dlDrbWeightData.dlDrbsWeightData[0].rrmDrbCombinedWeight": '~0.57 +- 0.12',
                    "dlDrbWeightData.dlDrbsWeightData[0].rrmDrbFinalWeight": 0,
                    "dlDrbWeightData.dlDrbsWeightData[0].rrmAvgDrbPrbAlloc": '~87 +- 6',
                    "dlDrbWeightData.dlDrbsWeightData[0].rrmAvgDrbPrbExp": '~87 +- 6',
                    "dlDrbWeightData.dlDrbsWeightData[0].rrmInstDrbPrbAlloc": '~120 +- 60'
                        }
            },
            "dlSliceData.slicesNumber": {
                '3.0': {
                    "dlSliceData.slicesNumber": 3,
                    "dlSliceData.rrmAvailablePrbsForSas": 273,
                    "dlSliceData.dlSlicesData[0].sliceId": 0,
                    "dlSliceData.dlSlicesData[0].plmnId": {'mcc': 311, 'mnc': 489},
                    "dlSliceData.dlSlicesData[0].snssai": {'sst': 1, 'sd': [209, 67, 165]},
                    "dlSliceData.dlSlicesData[0].rrmSliceInstShareGbr": 0,
                    "dlSliceData.dlSlicesData[0].rrmSliceInstShareNgbr": '~0.27 +- 0.27',
                    "dlSliceData.dlSlicesData[0].rrmSliceAvgShareGbr": 0,
                    "dlSliceData.dlSlicesData[0].rrmSliceAvgShareNgbr": '~0.35 +- 0.03',
                    "dlSliceData.rrmSliceUnusedShare": '~0.03 +- 0.03',
                    # "dlSliceData.dlSlicesData[0].rrmSliceTargetShareTemp": '~0.15 +- 0.15',
                    # "dlSliceData.dlSlicesData[0].rrmSliceWeightInterm": '~0.37 +- 0.02',
                    "dlSliceData.dlSlicesData[0].rrmSliceWeight": '~0.44 +- 0.09',
                    "dlSliceData.dlSlicesData[1].sliceId": 1,
                    "dlSliceData.dlSlicesData[1].plmnId": {'mcc': 311, 'mnc': 490},
                    "dlSliceData.dlSlicesData[1].snssai": {'sst': 1, 'sd': [0, 0, 2]},
                    "dlSliceData.dlSlicesData[1].rrmSliceInstShareGbr": 0,
                    "dlSliceData.dlSlicesData[1].rrmSliceInstShareNgbr": '~0.15 +- 0.15',
                    "dlSliceData.dlSlicesData[1].rrmSliceAvgShareGbr": 0,
                    "dlSliceData.dlSlicesData[1].rrmSliceAvgShareNgbr": '~0.19 +- 0.02',
                    # "dlSliceData.dlSlicesData[1].rrmSliceUnusedShare": '~0.03 +- 0.03',
                    # "dlSliceData.dlSlicesData[1].rrmSliceTargetShareTemp": '0.2 OR -255',
                    # "dlSliceData.dlSlicesData[1].rrmSliceWeightInterm": '0.2 OR -255',
                    "dlSliceData.dlSlicesData[1].rrmSliceWeight": '~0.15 +- 0.15',
                    "dlSliceData.dlSlicesData[2].sliceId": 2,
                    "dlSliceData.dlSlicesData[2].plmnId": {'mcc': 311, 'mnc': 491},
                    "dlSliceData.dlSlicesData[2].snssai": {'sst': 1, 'sd': [0, 0, 3]},
                    "dlSliceData.dlSlicesData[2].rrmSliceInstShareGbr": 0,
                    "dlSliceData.dlSlicesData[2].rrmSliceInstShareNgbr": '~0.30 +- 0.30',
                    "dlSliceData.dlSlicesData[2].rrmSliceAvgShareGbr": 0,
                    "dlSliceData.dlSlicesData[2].rrmSliceAvgShareNgbr": '~0.41 +- 0.02',
                    # "dlSliceData.dlSlicesData[2].rrmSliceUnusedShare": '~0.03 +- 0.03',
                    # "dlSliceData.dlSlicesData[2].rrmSliceTargetShareTemp": '~0.43 +- 0.02',
                    # "dlSliceData.dlSlicesData[2].rrmSliceWeightInterm": '~0.43 +- 0.02',
                    "dlSliceData.dlSlicesData[2].rrmSliceWeight": '~0.52 +- 0.12'
                }
            }
        },
        'SBTS22R4': {
            "dlDrbWeightData.dlDrbsWeightData[0].sliceId": {
                '0.0': {
                    "dlDrbWeightData.drbNumber": 1,
                    "dlDrbWeightData.dlDrbsWeightData[0].sliceId": 0,
                    "dlDrbWeightData.dlDrbsWeightData[0].logicalChannelIdentity": 4,
                    "dlDrbWeightData.dlDrbsWeightData[0].rrmDrbCombinedWeight": '~0.45 +- 0.09',
                    "dlDrbWeightData.dlDrbsWeightData[0].rrmDrbFinalWeight": 0,
                    "dlDrbWeightData.dlDrbsWeightData[0].rrmAvgDrbPrbAlloc": '~76 +- 5',
                    "dlDrbWeightData.dlDrbsWeightData[0].rrmAvgDrbPrbExp": '~76 +- 5',
                    "dlDrbWeightData.dlDrbsWeightData[0].rrmInstDrbPrbAlloc": '~95 +- 55'
                },
                '1.0': {
                    "dlDrbWeightData.drbNumber": 1,
                    "dlDrbWeightData.dlDrbsWeightData[0].sliceId": 1,
                    "dlDrbWeightData.dlDrbsWeightData[0].logicalChannelIdentity": 4,
                    "dlDrbWeightData.dlDrbsWeightData[0].rrmDrbCombinedWeight": '~0.24 +- 0.05',
                    "dlDrbWeightData.dlDrbsWeightData[0].rrmDrbFinalWeight": 0,
                    "dlDrbWeightData.dlDrbsWeightData[0].rrmAvgDrbPrbAlloc": '~40 +- 3',
                    "dlDrbWeightData.dlDrbsWeightData[0].rrmAvgDrbPrbExp": '~40 +- 3',
                    "dlDrbWeightData.dlDrbsWeightData[0].rrmInstDrbPrbAlloc": '~42 +- 28'
                },
                '2.0': {
                    "dlDrbWeightData.drbNumber": 1,
                    "dlDrbWeightData.dlDrbsWeightData[0].sliceId": 2,
                    "dlDrbWeightData.dlDrbsWeightData[0].logicalChannelIdentity": 4,
                    "dlDrbWeightData.dlDrbsWeightData[0].rrmDrbCombinedWeight": '~0.57 +- 0.12',
                    "dlDrbWeightData.dlDrbsWeightData[0].rrmDrbFinalWeight": 0,
                    "dlDrbWeightData.dlDrbsWeightData[0].rrmAvgDrbPrbAlloc": '~87 +- 6',
                    "dlDrbWeightData.dlDrbsWeightData[0].rrmAvgDrbPrbExp": '~87 +- 6',
                    "dlDrbWeightData.dlDrbsWeightData[0].rrmInstDrbPrbAlloc": '~120 +- 60'
                        }
            },
            "dlSliceData.slicesNumber": {
                '3.0': {
                    "dlSliceData.slicesNumber": 3,
                    "dlSliceData.rrmAvailablePrbsForSas": 273,
                    "dlSliceData.dlSlicesData[0].sliceId": 0,
                    "dlSliceData.dlSlicesData[0].plmnId": {'mcc': 311, 'mnc': 489},
                    "dlSliceData.dlSlicesData[0].snssai": {'sst': 1, 'sd': [209, 67, 165]},
                    "dlSliceData.dlSlicesData[0].rrmSliceInstShareGbr": 0,
                    "dlSliceData.dlSlicesData[0].rrmSliceInstShareNgbr": '~0.27 +- 0.27',
                    "dlSliceData.dlSlicesData[0].rrmSliceAvgShareGbr": 0,
                    "dlSliceData.dlSlicesData[0].rrmSliceAvgShareNgbr": '~0.35 +- 0.03',
                    "dlSliceData.rrmSliceUnusedShare": '~0.03 +- 0.03',
                    # "dlSliceData.dlSlicesData[0].rrmSliceTargetShareTemp": '~0.15 +- 0.15',
                    # "dlSliceData.dlSlicesData[0].rrmSliceWeightInterm": '~0.37 +- 0.02',
                    "dlSliceData.dlSlicesData[0].rrmSliceWeight": '~0.44 +- 0.09',
                    "dlSliceData.dlSlicesData[1].sliceId": 1,
                    "dlSliceData.dlSlicesData[1].plmnId": {'mcc': 311, 'mnc': 490},
                    "dlSliceData.dlSlicesData[1].snssai": {'sst': 1, 'sd': [0, 0, 2]},
                    "dlSliceData.dlSlicesData[1].rrmSliceInstShareGbr": 0,
                    "dlSliceData.dlSlicesData[1].rrmSliceInstShareNgbr": '~0.15 +- 0.15',
                    "dlSliceData.dlSlicesData[1].rrmSliceAvgShareGbr": 0,
                    "dlSliceData.dlSlicesData[1].rrmSliceAvgShareNgbr": '~0.19 +- 0.02',
                    # "dlSliceData.dlSlicesData[1].rrmSliceUnusedShare": '~0.03 +- 0.03',
                    # "dlSliceData.dlSlicesData[1].rrmSliceTargetShareTemp": '0.2 OR -255',
                    # "dlSliceData.dlSlicesData[1].rrmSliceWeightInterm": '0.2 OR -255',
                    "dlSliceData.dlSlicesData[1].rrmSliceWeight": '~0.15 +- 0.15',
                    "dlSliceData.dlSlicesData[2].sliceId": 2,
                    "dlSliceData.dlSlicesData[2].plmnId": {'mcc': 311, 'mnc': 491},
                    "dlSliceData.dlSlicesData[2].snssai": {'sst': 1, 'sd': [0, 0, 3]},
                    "dlSliceData.dlSlicesData[2].rrmSliceInstShareGbr": 0,
                    "dlSliceData.dlSlicesData[2].rrmSliceInstShareNgbr": '~0.30 +- 0.30',
                    "dlSliceData.dlSlicesData[2].rrmSliceAvgShareGbr": 0,
                    "dlSliceData.dlSlicesData[2].rrmSliceAvgShareNgbr": '~0.41 +- 0.02',
                    # "dlSliceData.dlSlicesData[2].rrmSliceUnusedShare": '~0.03 +- 0.03',
                    # "dlSliceData.dlSlicesData[2].rrmSliceTargetShareTemp": '~0.43 +- 0.02',
                    # "dlSliceData.dlSlicesData[2].rrmSliceWeightInterm": '~0.43 +- 0.02',
                    "dlSliceData.dlSlicesData[2].rrmSliceWeight": '~0.52 +- 0.12'
                }
            }
        }
    },
    'FDD': {
        'SBTS00': {
            "dlDrbWeightData.dlDrbsWeightData[0].sliceId": {
                '0.0': {
                    "dlDrbWeightData.drbNumber": 1,
                    "dlDrbWeightData.dlDrbsWeightData[0].sliceId": 0,
                    "dlDrbWeightData.dlDrbsWeightData[0].logicalChannelIdentity": 4,
                    "dlDrbWeightData.dlDrbsWeightData[0].rrmDrbCombinedWeight": '~0.585 +- 0.44',
                    "dlDrbWeightData.dlDrbsWeightData[0].rrmDrbFinalWeight": 0,
                    "dlDrbWeightData.dlDrbsWeightData[0].rrmAvgDrbPrbAlloc": '~35 +- 5',
                    "dlDrbWeightData.dlDrbsWeightData[0].rrmAvgDrbPrbExp": '~35 +- 5',
                    "dlDrbWeightData.dlDrbsWeightData[0].rrmInstDrbPrbAlloc": '~58 +- 53'
                },
                '1.0': {
                    "dlDrbWeightData.drbNumber": 1,
                    "dlDrbWeightData.dlDrbsWeightData[0].sliceId": 1,
                    "dlDrbWeightData.dlDrbsWeightData[0].logicalChannelIdentity": 4,
                    "dlDrbWeightData.dlDrbsWeightData[0].rrmDrbCombinedWeight": '~0.3 +- 0.25',
                    "dlDrbWeightData.dlDrbsWeightData[0].rrmDrbFinalWeight": 0,
                    "dlDrbWeightData.dlDrbsWeightData[0].rrmAvgDrbPrbAlloc": '~19.5 +- 3',
                    "dlDrbWeightData.dlDrbsWeightData[0].rrmAvgDrbPrbExp": '~18.5 +- 2',
                    "dlDrbWeightData.dlDrbsWeightData[0].rrmInstDrbPrbAlloc": '~55 +- 55'
                },
                '2.0': {
                    "dlDrbWeightData.drbNumber": 1,
                    "dlDrbWeightData.dlDrbsWeightData[0].sliceId": 2,
                    "dlDrbWeightData.dlDrbsWeightData[0].logicalChannelIdentity": 4,
                    "dlDrbWeightData.dlDrbsWeightData[0].rrmDrbCombinedWeight": '~0.75 +- 0.4',
                    "dlDrbWeightData.dlDrbsWeightData[0].rrmDrbFinalWeight": 0,
                    "dlDrbWeightData.dlDrbsWeightData[0].rrmAvgDrbPrbAlloc": '~38 +- 5',
                    "dlDrbWeightData.dlDrbsWeightData[0].rrmAvgDrbPrbExp": '~38 +- 5',
                    "dlDrbWeightData.dlDrbsWeightData[0].rrmInstDrbPrbAlloc": '~55 +- 55'
                }
            },
            "dlSliceData.slicesNumber": {
                '3.0': {
                    "dlSliceData.slicesNumber": 3,
                    "dlSliceData.rrmAvailablePrbsForSas": '~103 +- 24',
                    "dlSliceData.dlSlicesData[0].sliceId": 0,
                    "dlSliceData.dlSlicesData[0].plmnId": {'mcc': 311, 'mnc': 489, 'mncLength': 3},
                    "dlSliceData.dlSlicesData[0].snssai": {'sst': 1, 'sd': 13714341},
                    "dlSliceData.dlSlicesData[0].rrmSliceHighInstShare": 0,
                    "dlSliceData.dlSlicesData[0].rrmSliceLowInstShare": '~0.5 +- 0.5',
                    "dlSliceData.dlSlicesData[0].rrmSliceAvgHighShare": 0,
                    "dlSliceData.dlSlicesData[0].rrmSliceAvgLowShare": '~0.35 +- 0.05',
                    "dlSliceData.rrmSliceUnusedShare": '~0.06 +- 0.12',
                    # "dlSliceData.dlSlicesData[0].rrmSliceTargetShareTemp": '~0.39 +- 0.05',
                    # "dlSliceData.dlSlicesData[0].rrmSliceWeightInterm": '~0.39 +- 0.05',
                    "dlSliceData.dlSlicesData[0].rrmSliceWeight": '~0.585 +- 0.4',
                    "dlAdditionalSliceData.dlSlicesData[0].rrmSliceTargetShareTemp": '~0.42 +- 0.07',
                    "dlAdditionalSliceData.dlSlicesData[0].rrmSliceWeightInterm": '~0.42 +- 0.07',
                    # "dlAdditionalSliceData.dlSlicesData[0].rrmSliceWeight": '~0.42 +- 0.07',
                    "dlSliceData.dlSlicesData[1].sliceId": 1,
                    "dlSliceData.dlSlicesData[1].plmnId": {'mcc': 311, 'mnc': 490, 'mncLength': 3},
                    "dlSliceData.dlSlicesData[1].snssai": {'sst': 1, 'sd': 2},
                    "dlSliceData.dlSlicesData[1].rrmSliceHighInstShare": 0,
                    "dlSliceData.dlSlicesData[1].rrmSliceLowInstShare": '~0.5 +- 0.5',
                    "dlSliceData.dlSlicesData[1].rrmSliceAvgHighShare": 0,
                    "dlSliceData.dlSlicesData[1].rrmSliceAvgLowShare": '~0.18 +- 0.05',
                    # "dlSliceData.dlSlicesData[1].rrmSliceUnusedShare": '~0.06 +- 0.12',
                    # "dlSliceData.dlSlicesData[1].rrmSliceTargetShareTemp": '0.2 OR -255',
                    # "dlSliceData.dlSlicesData[1].rrmSliceWeightInterm": '0.2 OR -255',
                    # "dlAdditionalSliceData.dlSlicesData[1].rrmSliceUnusedShare": '~0.06 +- 0.12',
                    "dlAdditionalSliceData.dlSlicesData[1].rrmSliceTargetShareTemp": '~0.2 +- 0.07',
                    "dlAdditionalSliceData.dlSlicesData[1].rrmSliceWeightInterm": '~0.2 +- 0.07',
                    "dlSliceData.dlSlicesData[1].rrmSliceWeight": '~0.3 +- 0.22',
                    "dlSliceData.dlSlicesData[2].sliceId": 2,
                    "dlSliceData.dlSlicesData[2].plmnId": {'mcc': 311, 'mnc': 491, 'mncLength': 3},
                    "dlSliceData.dlSlicesData[2].snssai": {'sst': 1, 'sd': 3},
                    "dlSliceData.dlSlicesData[2].rrmSliceHighInstShare": 0,
                    "dlSliceData.dlSlicesData[2].rrmSliceLowInstShare": '~0.5 +- 0.5',
                    "dlSliceData.dlSlicesData[2].rrmSliceAvgHighShare": 0,
                    "dlSliceData.dlSlicesData[2].rrmSliceAvgLowShare": '~0.385 +- 0.05',
                    # "dlSliceData.dlSlicesData[2].rrmSliceUnusedShare": '~0.06 +- 0.12',
                    # "dlSliceData.dlSlicesData[2].rrmSliceTargetShareTemp": '~0.45 +- 0.07',
                    # "dlSliceData.dlSlicesData[2].rrmSliceWeightInterm": '~0.45 +- 0.07',
                    # "dlAdditionalSliceData.dlSlicesData[2].rrmSliceUnusedShare": '~0.06 +- 0.12',
                    "dlAdditionalSliceData.dlSlicesData[2].rrmSliceTargetShareTemp": '~0.49 +- 0.07',
                    "dlAdditionalSliceData.dlSlicesData[2].rrmSliceWeightInterm": '~0.49 +- 0.07',
                    # "dlAdditionalSliceData.dlSlicesData[2].rrmSliceWeight": '~0.49 +- 0.07',

                    # "dlAdditionalSliceData.dlSlicesData": [0]{'sliceId': 0,
                    #                                        'rrmSliceTargetShareTemp':  0.430694,
                    #                                        'rrmSliceWeightInterm': 0.430694},
                    # "dlAdditionalSliceData.dlSlicesData": [{'sliceId': 0, 'rrmSliceTargetShareTemp':  '~0.42 +- 0.07',
                    #                                         'rrmSliceWeightInterm': '~0.42 +- 0.07'},
                    #                                        {'sliceId': 1, 'rrmSliceTargetShareTemp':  '~0.2 +- 0.07',
                    #                                         'rrmSliceWeightInterm': '~0.2 +- 0.07'},
                    #                                        {'sliceId': 2, 'rrmSliceTargetShareTemp':  '~0.49 +- 0.07',
                    #                                         'rrmSliceWeightInterm': '~0.49 +- 0.07'}
                    #                                        ]
                }
            },
        },
        'SBTS23R1': {
            "dlDrbWeightData.dlDrbsWeightData[0].sliceId": {
                '0.0': {
                    "dlDrbWeightData.drbNumber": 1,
                    "dlDrbWeightData.dlDrbsWeightData[0].sliceId": 0,
                    "dlDrbWeightData.dlDrbsWeightData[0].logicalChannelIdentity": 4,
                    "dlDrbWeightData.dlDrbsWeightData[0].rrmDrbCombinedWeight": '~0.585 +- 0.5',
                    "dlDrbWeightData.dlDrbsWeightData[0].rrmDrbFinalWeight": 0,
                    "dlDrbWeightData.dlDrbsWeightData[0].rrmAvgDrbPrbAlloc": '~35 +- 5',
                    "dlDrbWeightData.dlDrbsWeightData[0].rrmAvgDrbPrbExp": '~35 +- 5',
                    "dlDrbWeightData.dlDrbsWeightData[0].rrmInstDrbPrbAlloc": '~58 +- 53'
                },
                '1.0': {
                    "dlDrbWeightData.drbNumber": 1,
                    "dlDrbWeightData.dlDrbsWeightData[0].sliceId": 1,
                    "dlDrbWeightData.dlDrbsWeightData[0].logicalChannelIdentity": 4,
                    "dlDrbWeightData.dlDrbsWeightData[0].rrmDrbCombinedWeight": '~0.3 +- 0.25',
                    "dlDrbWeightData.dlDrbsWeightData[0].rrmDrbFinalWeight": 0,
                    "dlDrbWeightData.dlDrbsWeightData[0].rrmAvgDrbPrbAlloc": '~19.5 +- 3',
                    "dlDrbWeightData.dlDrbsWeightData[0].rrmAvgDrbPrbExp": '~18.5 +- 2',
                    "dlDrbWeightData.dlDrbsWeightData[0].rrmInstDrbPrbAlloc": '~55 +- 55'
                },
                '2.0': {
                    "dlDrbWeightData.drbNumber": 1,
                    "dlDrbWeightData.dlDrbsWeightData[0].sliceId": 2,
                    "dlDrbWeightData.dlDrbsWeightData[0].logicalChannelIdentity": 4,
                    "dlDrbWeightData.dlDrbsWeightData[0].rrmDrbCombinedWeight": '~0.75 +- 0.55',
                    "dlDrbWeightData.dlDrbsWeightData[0].rrmDrbFinalWeight": 0,
                    "dlDrbWeightData.dlDrbsWeightData[0].rrmAvgDrbPrbAlloc": '~38 +- 5',
                    "dlDrbWeightData.dlDrbsWeightData[0].rrmAvgDrbPrbExp": '~38 +- 5',
                    "dlDrbWeightData.dlDrbsWeightData[0].rrmInstDrbPrbAlloc": '~55 +- 55'
                }
            },
            "dlSliceData.slicesNumber": {
                '3.0': {
                    "dlSliceData.slicesNumber": 3,
                    "dlSliceData.rrmAvailablePrbsForSas": '~103 +- 24',
                    "dlSliceData.dlSlicesData[0].sliceId": 0,
                    "dlSliceData.dlSlicesData[0].plmnId": {'mcc': 311, 'mnc': 489, 'mncLength': 3},
                    "dlSliceData.dlSlicesData[0].snssai": {'sst': 1, 'sd': 13714341},
                    "dlSliceData.dlSlicesData[0].rrmSliceHighInstShare": 0,
                    "dlSliceData.dlSlicesData[0].rrmSliceLowInstShare": '~0.5 +- 0.5',
                    "dlSliceData.dlSlicesData[0].rrmSliceAvgHighShare": 0,
                    "dlSliceData.dlSlicesData[0].rrmSliceAvgLowShare": '~0.35 +- 0.05',
                    # "dlSliceData.rrmSliceUnusedShare": '~0.06 +- 0.12',
                    "dlSliceData.dlSlicesData[0].rrmSliceTargetShareTemp": '~0.39 +- 0.05',
                    "dlSliceData.dlSlicesData[0].rrmSliceWeightInterm": '~0.39 +- 0.05',
                    "dlSliceData.dlSlicesData[0].rrmSliceWeight": '~0.585 +- 0.5',
                    "dlSliceData.dlSlicesData[1].sliceId": 1,
                    "dlSliceData.dlSlicesData[1].plmnId": {'mcc': 311, 'mnc': 490, 'mncLength': 3},
                    "dlSliceData.dlSlicesData[1].snssai": {'sst': 1, 'sd': 2},
                    "dlSliceData.dlSlicesData[1].rrmSliceHighInstShare": 0,
                    "dlSliceData.dlSlicesData[1].rrmSliceLowInstShare": '~0.5 +- 0.5',
                    "dlSliceData.dlSlicesData[1].rrmSliceAvgHighShare": 0,
                    "dlSliceData.dlSlicesData[1].rrmSliceAvgLowShare": '~0.18 +- 0.05',
                    # "dlSliceData.dlSlicesData[1].rrmSliceUnusedShare": '~0.06 +- 0.12',
                    "dlSliceData.dlSlicesData[1].rrmSliceTargetShareTemp": '0.2 OR -255',
                    # "dlSliceData.dlSlicesData[1].rrmSliceWeightInterm": '0.2 OR -255',
                    "dlSliceData.dlSlicesData[1].rrmSliceWeight": '~0.3 +- 0.22',
                    "dlSliceData.dlSlicesData[2].sliceId": 2,
                    "dlSliceData.dlSlicesData[2].plmnId": {'mcc': 311, 'mnc': 491, 'mncLength': 3},
                    "dlSliceData.dlSlicesData[2].snssai": {'sst': 1, 'sd': 3},
                    "dlSliceData.dlSlicesData[2].rrmSliceHighInstShare": 0,
                    "dlSliceData.dlSlicesData[2].rrmSliceLowInstShare": '~0.5 +- 0.5',
                    "dlSliceData.dlSlicesData[2].rrmSliceAvgHighShare": 0,
                    "dlSliceData.dlSlicesData[2].rrmSliceAvgLowShare": '~0.385 +- 0.05',
                    "dlSliceData.dlSlicesData[2].rrmSliceUnusedShare": '~0.06 +- 0.12',
                    "dlSliceData.dlSlicesData[2].rrmSliceTargetShareTemp": '~0.45 +- 0.07',
                    # "dlSliceData.dlSlicesData[2].rrmSliceWeightInterm": '~0.45 +- 0.07',
                    "dlSliceData.dlSlicesData[2].rrmSliceWeight": '~0.74 +- 0.51'
                }
            }
        },
        'SBTS22R4': {
            "dlDrbWeightData.dlDrbsWeightData[0].sliceId": {
                '0.0': {
                    "dlDrbWeightData.drbNumber": 1,
                    "dlDrbWeightData.dlDrbsWeightData[0].sliceId": 0,
                    "dlDrbWeightData.dlDrbsWeightData[0].logicalChannelIdentity": 4,
                    "dlDrbWeightData.dlDrbsWeightData[0].rrmDrbCombinedWeight": '~0.585 +- 0.5',
                    "dlDrbWeightData.dlDrbsWeightData[0].rrmDrbFinalWeight": 0,
                    "dlDrbWeightData.dlDrbsWeightData[0].rrmAvgDrbPrbAlloc": '~35 +- 5',
                    "dlDrbWeightData.dlDrbsWeightData[0].rrmAvgDrbPrbExp": '~35 +- 5',
                    "dlDrbWeightData.dlDrbsWeightData[0].rrmInstDrbPrbAlloc": '~58 +- 53'
                },
                '1.0': {
                    "dlDrbWeightData.drbNumber": 1,
                    "dlDrbWeightData.dlDrbsWeightData[0].sliceId": 1,
                    "dlDrbWeightData.dlDrbsWeightData[0].logicalChannelIdentity": 4,
                    "dlDrbWeightData.dlDrbsWeightData[0].rrmDrbCombinedWeight": '~0.3 +- 0.25',
                    "dlDrbWeightData.dlDrbsWeightData[0].rrmDrbFinalWeight": 0,
                    "dlDrbWeightData.dlDrbsWeightData[0].rrmAvgDrbPrbAlloc": '~19.5 +- 3',
                    "dlDrbWeightData.dlDrbsWeightData[0].rrmAvgDrbPrbExp": '~18.5 +- 2',
                    "dlDrbWeightData.dlDrbsWeightData[0].rrmInstDrbPrbAlloc": '~55 +- 55'
                },
                '2.0': {
                    "dlDrbWeightData.drbNumber": 1,
                    "dlDrbWeightData.dlDrbsWeightData[0].sliceId": 2,
                    "dlDrbWeightData.dlDrbsWeightData[0].logicalChannelIdentity": 4,
                    "dlDrbWeightData.dlDrbsWeightData[0].rrmDrbCombinedWeight": '~0.75 +- 0.55',
                    "dlDrbWeightData.dlDrbsWeightData[0].rrmDrbFinalWeight": 0,
                    "dlDrbWeightData.dlDrbsWeightData[0].rrmAvgDrbPrbAlloc": '~38 +- 5',
                    "dlDrbWeightData.dlDrbsWeightData[0].rrmAvgDrbPrbExp": '~38 +- 5',
                    "dlDrbWeightData.dlDrbsWeightData[0].rrmInstDrbPrbAlloc": '~55 +- 55'
                }
            },
            "dlSliceData.slicesNumber": {
                '3.0': {
                    "dlSliceData.slicesNumber": 3,
                    "dlSliceData.rrmAvailablePrbsForSas": '~103 +- 24',
                    "dlSliceData.dlSlicesData[0].sliceId": 0,
                    "dlSliceData.dlSlicesData[0].plmnId": {'mcc': 311, 'mnc': 489, 'mncLength': 3},
                    "dlSliceData.dlSlicesData[0].snssai": {'sst': 1, 'sd': 13714341},
                    "dlSliceData.dlSlicesData[0].rrmSliceHighInstShare": 0,
                    "dlSliceData.dlSlicesData[0].rrmSliceLowInstShare": '~0.5 +- 0.5',
                    "dlSliceData.dlSlicesData[0].rrmSliceAvgHighShare": 0,
                    "dlSliceData.dlSlicesData[0].rrmSliceAvgLowShare": '~0.35 +- 0.05',
                    "dlSliceData.rrmSliceUnusedShare": '~0.06 +- 0.12',
                    "dlSliceData.dlSlicesData[0].rrmSliceTargetShareTemp": '~0.39 +- 0.05',
                    "dlSliceData.dlSlicesData[0].rrmSliceWeightInterm": '~0.39 +- 0.05',
                    "dlSliceData.dlSlicesData[0].rrmSliceWeight": '~0.585 +- 0.5',
                    "dlSliceData.dlSlicesData[1].sliceId": 1,
                    "dlSliceData.dlSlicesData[1].plmnId": {'mcc': 311, 'mnc': 490, 'mncLength': 3},
                    "dlSliceData.dlSlicesData[1].snssai": {'sst': 1, 'sd': 2},
                    "dlSliceData.dlSlicesData[1].rrmSliceHighInstShare": 0,
                    "dlSliceData.dlSlicesData[1].rrmSliceLowInstShare": '~0.5 +- 0.5',
                    "dlSliceData.dlSlicesData[1].rrmSliceAvgHighShare": 0,
                    "dlSliceData.dlSlicesData[1].rrmSliceAvgLowShare": '~0.18 +- 0.05',
                    "dlSliceData.dlSlicesData[1].rrmSliceUnusedShare": '~0.06 +- 0.12',
                    "dlSliceData.dlSlicesData[1].rrmSliceTargetShareTemp": '0.2 OR -255',
                    # "dlSliceData.dlSlicesData[1].rrmSliceWeightInterm": '0.2 OR -255',
                    "dlSliceData.dlSlicesData[1].rrmSliceWeight": '~0.3 +- 0.22',
                    "dlSliceData.dlSlicesData[2].sliceId": 2,
                    "dlSliceData.dlSlicesData[2].plmnId": {'mcc': 311, 'mnc': 491, 'mncLength': 3},
                    "dlSliceData.dlSlicesData[2].snssai": {'sst': 1, 'sd': 3},
                    "dlSliceData.dlSlicesData[2].rrmSliceHighInstShare": 0,
                    "dlSliceData.dlSlicesData[2].rrmSliceLowInstShare": '~0.5 +- 0.5',
                    "dlSliceData.dlSlicesData[2].rrmSliceAvgHighShare": 0,
                    "dlSliceData.dlSlicesData[2].rrmSliceAvgLowShare": '~0.385 +- 0.05',
                    "dlSliceData.dlSlicesData[2].rrmSliceUnusedShare": '~0.06 +- 0.12',
                    "dlSliceData.dlSlicesData[2].rrmSliceTargetShareTemp": '~0.45 +- 0.07',
                    "dlSliceData.dlSlicesData[2].rrmSliceWeightInterm": '~0.45 +- 0.07',
                    "dlSliceData.dlSlicesData[2].rrmSliceWeight": '~0.74 +- 0.51'
                }
            }
        }
    }
}

UE_INFO = {
    '1': {
        'PDU_ID': PDU_ID_1,
        'UE_ID': '1',
        'CELL_ID': None,
        'ENB_ID': GNB_ID,
        'NWSLICE_ID': NWSLICE_ID_1,
        'GW_ID': GW_ID_1
    },
    '2': {
        'PDU_ID': PDU_ID_2,
        'UE_ID': '2',
        'CELL_ID': None,
        'ENB_ID': GNB_ID,
        'NWSLICE_ID': NWSLICE_ID_2,
        'GW_ID': GW_ID_2
    },
    '11': {
        'BEARER_ID': BEARER_ID_2,
        'UE_ID': '11',
        'CELL_ID': None,
        'ENB_ID': GNB_ID
    },
}

C_12_1PLMN_1UE_PRB_VALIDATION_DICTIONARY = {
    'after_1st_ue': [
        {
            'resourcegroup_dn': NRPLMN_1,
            'target_share_rg_dn': [NRPLMN_1],
            'is_sa': False,
            'cell_num': 3
        },
        {
            'resourcegroup_dn': NRPLMN_1,
            'target_share_rg_dn': [NRPLMN_1],
            'is_sa': False,
            'cell_num': 1
        }
    ],
    'after_2nd_ue': [
        {
            'resourcegroup_dn': NRPLMN_1,
            'target_share_rg_dn': [NRPLMN_1],
            'is_sa': False,
            'cell_num': 3
        },
        {
            'resourcegroup_dn': NRPLMN_1,
            'target_share_rg_dn': [NRPLMN_1, SNSSAI_1],
            'is_sa': False,
            'cell_num': 1
        },
        {
            'resourcegroup_dn': SNSSAI_1,
            'target_share_rg_dn': [NRPLMN_1, SNSSAI_1],
            'is_sa': True,
            'cell_num': 1
        }
    ],
    'after_3rd_ue': [
        {
            'resourcegroup_dn': NRPLMN_1,
            'target_share_rg_dn': [NRPLMN_1],
            'is_sa': False,
            'cell_num': 3
        },
        {
            'resourcegroup_dn': NRPLMN_1,
            'target_share_rg_dn': [NRPLMN_1, SNSSAI_1, NRPLMN_1],
            'is_sa': False,
            'cell_num': 1
        },
        {
            'resourcegroup_dn': SNSSAI_1,
            'target_share_rg_dn': [NRPLMN_1, SNSSAI_1, NRPLMN_1],
            'is_sa': True,
            'cell_num': 1
        },
        {
            'resourcegroup_dn': NRPLMN_1,
            'target_share_rg_dn': [NRPLMN_1, SNSSAI_1, NRPLMN_1],
            'is_sa': False,
            'cell_num': 1
        }
    ]
}

C_13_3PLMN_3UE_PRB_VALIDATION_DICTIONARY = {
    'after_1st_ue': [
        {
            'resourcegroup_dn': NRPLMN_2,
            'target_share_rg_dn': [NRPLMN_2],
            'is_sa': False,
            'cell_num': 3
        },
        {
            'resourcegroup_dn': NRPLMN_2,
            'target_share_rg_dn': [NRPLMN_2],
            'is_sa': False,
            'cell_num': 1
        }
    ],
    'after_2nd_ue': [
        {
            'resourcegroup_dn': NRPLMN_2,
            'target_share_rg_dn': [NRPLMN_2],
            'is_sa': False,
            'cell_num': 3
        },
        {
            'resourcegroup_dn': NRPLMN_2,
            'target_share_rg_dn': [NRPLMN_2, SNSSAI_1],
            'is_sa': False,
            'cell_num': 1
        },
        {
            'resourcegroup_dn': SNSSAI_1,
            'target_share_rg_dn': [NRPLMN_2, SNSSAI_1],
            'is_sa': True,
            'cell_num': 1
        }
    ],
    'after_3rd_ue': [
        {
            'resourcegroup_dn': NRPLMN_2,
            'target_share_rg_dn': [NRPLMN_2],
            'is_sa': False,
            'cell_num': 3
        },
        {
            'resourcegroup_dn': NRPLMN_2,
            'target_share_rg_dn': [NRPLMN_2, SNSSAI_1, NRPLMN_3],
            'is_sa': False,
            'cell_num': 1
        },
        {
            'resourcegroup_dn': SNSSAI_1,
            'target_share_rg_dn': [NRPLMN_2, SNSSAI_1, NRPLMN_3],
            'is_sa': True,
            'cell_num': 1
        },
        {
            'resourcegroup_dn': NRPLMN_3,
            'target_share_rg_dn': [NRPLMN_2, SNSSAI_1, NRPLMN_3],
            'is_sa': False,
            'cell_num': 1
        }
    ]
}

C_12_1PLMN_1UE_SUCCES_ADMISSIONS_RADIO_VALIDATION_DICTIONARY = {
    'after_3rd_ue': {
        "SCELL_1": [
            {
                'cell': 3,
                'addmission_per_timestamp': [1]
            }
        ]
    }
}

C_13_3PLMN_3UE_SUCCES_ADMISSIONS_RADIO_VALIDATION_DICTIONARY = {
    'after_1st_ue': {
        "SCELL_1": [
            {
                'cell': 3,
                'addmission_per_timestamp': [1]
            }
        ]
    },
    'after_2nd_ue': {
        "SCELL_1": [
            {
                'cell': 3,
                'addmission_per_timestamp': [1]
            }
        ]
    },
    'after_3rd_ue': {
        "SCELL_1": [
            {
                'cell': 3,
                'addmission_per_timestamp': [1]
            }
        ]
    }
}

C_3PLMN_MAX_TPUT = {
    'after_1st_ue': {
        'pcell': '195',
        'scell': '428'
    },
    'after_2nd_ue': {
        'pcell': '195',
        'scell': '428'
    },
    'after_3rd_ue': {
        'pcell': '195',
        'scell': '428'
    }
}

C_12_1PLMN_3UE_THROUGHPUT_COUNTERS_DICTIONARY = {
    3: {
        NRPLMN_1: M55311C44008
    },
    1: {
        NRPLMN_1: M55319C02008,
        SNSSAI_1: M55328C00003
    }
}

C_13_3PLMN_3UE_THROUGHPUT_COUNTERS_DICTIONARY = {
    3: {
        NRPLMN_2: M55311C44008
    },
    1: {
        NRPLMN_2: M55311C42008,
        NRPLMN_3: M55319C02008,
        SNSSAI_1: M55328C00003
    }
}

C_3PLMN_COUNTER_UTI_RATIO_MARGIN = 2
