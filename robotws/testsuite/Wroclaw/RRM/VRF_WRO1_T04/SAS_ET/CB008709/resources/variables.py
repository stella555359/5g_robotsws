"""
:copyright: Nokia Networks
:author: Damian Zak
:maintainer: Damian Zak
:contact: damian.zak@nokia.com, I_VRF_KRK_11@internal.nsn.com
:team: MN_RAN_RD_VRF_KRK_11
"""
import os

GNB_IP = "192.168.255.129"
AP_IP = "192.168.200.129"
NOKIA_USERNAME = "toor4nsn"
NOKIA_PASS = "oZPS0POrRieRtu"
WEBEM_USERNAME = "Nemuadmin"
WEBEM_PASS = "nemuuser"

CURDIR_PATH = os.path.dirname(os.path.realpath(__file__))
CONFIGS_PATH = f"{CURDIR_PATH}/config_files"
DELTAS_PATH = f"{CURDIR_PATH}/deltas"

NSA_SIB_RECEPTION_DICT = {1: [1]}
ALL_CELLS_SIB_RECEPTION_DICT = {2: [1, 2, 3, 4]}
CUSTOM_RG_TS_028 = [61, 0, 0, 0, 38]
CUSTOM_RG_TS_011 = [26, 45, 26]

# Delta
DELTA_L_B1 = os.path.join(DELTAS_PATH, "delta_L_B1.json")
DELTA_B_EC2 = os.path.join(DELTAS_PATH, "delta_B_EC2.json")
DELTA_B_B1 = os.path.join(DELTAS_PATH, "delta_B_B1.json")
DELTA_A_EC2 = os.path.join(DELTAS_PATH, "delta_A_EC2.json")
DELTA_C_EC2 = os.path.join(DELTAS_PATH, "delta_C_EC2.json")
DELTA_C_ROBUSTNESS = os.path.join(DELTAS_PATH, "delta_C_ROBUSTNESS.json")
DELTA_L_B1 = os.path.join(DELTAS_PATH, "delta_L_B1.json")
DELTA_B_EC2 = os.path.join(DELTAS_PATH, "delta_B_EC2.json")
DELTA_B_B1 = os.path.join(DELTAS_PATH, "delta_B_B1.json")
DELTA_A_EC2 = os.path.join(DELTAS_PATH, "delta_A_EC2.json")
DELTA_K_B102 = os.path.join(DELTAS_PATH, "delta_K_B102.json")
DELTA_K_B102_CHANGE = os.path.join(DELTAS_PATH, "delta_K_B102_change.json")
DELTA_K_B102_CHANGE_2 = os.path.join(DELTAS_PATH, "delta_K_B102_change_2.json")
DELTA_K_B103 = os.path.join(DELTAS_PATH, "delta_K_B103.json")
DELTA_K_B103_CHANGE = os.path.join(DELTAS_PATH, "delta_K_B103_change.json")
DELTA_K_B201 = os.path.join(DELTAS_PATH, "delta_K_B201.json")
DELTA_K_B201_FIRST_CHANGE = os.path.join(DELTAS_PATH, "delta_K_B201_first_change.json")
DELTA_K_B201_SECOND_CHANGE = os.path.join(DELTAS_PATH, "delta_K_B201_second_change.json")
DELTA_J_EC301 = os.path.join(DELTAS_PATH, "delta_J_EC301.json")
K_SCF = os.path.join(DELTAS_PATH, "scf_K_201.xml")

# WTS CONFIG
TC004_A_WTS_CONFIG_CD = os.path.join(CONFIGS_PATH, "TC004_A_WTS_CONFIG_CD.cfg")
TC011_G_WTS_CONFIG_CD = os.path.join(CONFIGS_PATH, "TC011_G_WTS_CONFIG_CD.cfg")
TC015_K_WTS_CONFIG_CD = os.path.join(CONFIGS_PATH, "TC015_K_WTS_CONFIG_CD.cfg")
TC024_K_WTS_CONFIG_CD = os.path.join(CONFIGS_PATH, "TC024_K_WTS_CONFIG_CD.cfg")
TC031_K_WTS_CONFIG_CD = os.path.join(CONFIGS_PATH, "TC031_K_WTS_CONFIG_CD.cfg")
TC003_A_WTS_CONFIG_VRF = os.path.join(CONFIGS_PATH, "TC003_A_WTS_CONFIG_VRF.cfg")
TC006_B_WTS_CONFIG_VRF = os.path.join(CONFIGS_PATH, "TC006_B_WTS_CONFIG_VRF.cfg")
TC012_B_WTS_CONFIG_VRF = os.path.join(CONFIGS_PATH, "TC012_B_WTS_CONFIG_VRF.cfg")
TC032_L_WTS_CONFIG_VRF = os.path.join(CONFIGS_PATH, "TC032_L_WTS_CONFIG_VRF.cfg")
TC014_C_WTS_CONFIG_VRF = os.path.join(CONFIGS_PATH, "TC014_C_WTS_CONFIG_VRF.cfg")
TC035_C_WTS_CONFIG_VRF = os.path.join(CONFIGS_PATH, "TC035_C_WTS_CONFIG_VRF.cfg")
WTS_L_B1 = os.path.join(CONFIGS_PATH, "cfg_L_B1.cfg")
WTS_B_EC2_CONF = os.path.join(CONFIGS_PATH, "cfg_B_EC2.cfg")
WTS_B_B1_CONF = os.path.join(CONFIGS_PATH, "cfg_B_B1.cfg")
WTS_A_EC2_CONF = os.path.join(CONFIGS_PATH, "cfg_A_EC2.cfg")
WTS_K_B102_CONF = os.path.join(CONFIGS_PATH, "TC024_K_WTS_CONFIG_VRF.cfg")
WTS_K_B103_CONF = os.path.join(CONFIGS_PATH, "TC025_K_WTS_CONFIG_VRF.cfg")
WTS_K_B201_CONF = os.path.join(CONFIGS_PATH, "TC028_K_WTS_CONFIG_VRF.cfg")
WTS_J_EC301_CONF = os.path.join(CONFIGS_PATH, "TC022_J_WTS_CONFIG_VRF.cfg")
HO_REGEX = r"Intra-eNB\s+handover\s+from\s+EXT_ENB-\d\.\d\s+to\s+EXT_ENB-\d\.\d\s+performed"

# SAS Deltas
SAS_DELTA_A_004 = {
    "RG_amount": 2,
    "minQuotas": [40, 30],
    "maxQuotas": [60, 70],
    "resourceDN": ["SNSSAI-1", "SNSSAI-2"],
    "SNSSAI_NRPLMN": [[1], [1]],
    "NRPLMN_IDs": [1],
    "defaultRG": {1: {"SA": {1: 1}}},
    "RG_profile_grp": {3: {"UL": 1}},
    "cellDepType": {1: "SANSA", 2: "SANSA", 3: "SA", 4: "SANSA"}
}

SAS_DELTA_C_005 = {
    "RG_amount": 5,
    "minQuotas": [20, 20, 30, 10, 10],
    "maxQuotas": [60, 80, 70, 80, 90],
    "resourceDN": ["SNSSAI-1", "SNSSAI-2", "SNSSAI-3", "SNSSAI-4", "SNSSAI-5"],
    "SNSSAI_NRPLMN": [[1], [1], [2], [2], [2]],
    "NRPLMN_IDs": [1, 2],
    "defaultRG": {1: {"SA": {1: 1, 2: 3}}},
    "RG_profile_grp": {1: {"UL": 1}},
    "cellDepType": {1: "SA", 2: "SANSA", 3: "SANSA", 4: "SANSA"}
}

SAS_DELTA_C_006 = {
    "RG_amount": 10,
    "minQuotas": [20, 30, 50, 10, 20, 30, 20, 30, 40, 20],
    "maxQuotas": [80, 70, 50, 90, 80, 70, 80, 70, 60, 80],
    "resourceDN": ["NRSPIDGRP-1", "NRSPIDGRP-2", "NRSPIDGRP-3", "NRSPIDGRP-4", "NRSPIDGRP-5", "NRSPIDGRP-6",
                   "NRSPIDGRP-7", "NRSPIDGRP-8", "NRSPIDGRP-9", "NRSPIDGRP-10"],
    "NRSPIDGRP": [[1, 1, 10], [1, 11, 20], [1, 21, 30], [1, 31, 40], [1, 41, 50], [1, 51, 60], [1, 61, 70],
                  [1, 71, 80], [1, 81, 90], [1, 91, 100]],
    "NRPLMN_IDs": [1],
    "defaultRG": {1: {"NSA": {1: 1}}},
    "RG_profile_grp": {1: {"UL": 1}},
    "cellDepType": {1: "NSA", 2: "SANSA", 3: "SANSA", 4: "SANSA"}
}

SAS_DELTA_C_007 = {
    "RG_amount": 2,
    "minQuotas": [0, 90],
    "maxQuotas": [5, 100],
    "resourceDN": ["SNSSAI-1", ["SNSSAI-2", "NRSPIDGRP-2"]],
    "NRSPIDGRP": [[1, 20, 40]],
    "SNSSAI_NRPLMN": [[1], [1]],
    "NRPLMN_IDs": [1],
    "defaultRG": {1: {"NSA": {1: 2}, "SA": {1: 1}}},
    "RG_profile_grp": {1: {"UL": 1}},
    "cellDepType": {1: "SANSA", 2: "SANSA", 3: "SANSA", 4: "SANSA"}
}

SAS_DELTA_G_008 = {
    "RG_amount": 2,
    "minQuotas": [20, 30],
    "maxQuotas": [80, 70],
    "resourceDN": ["SNSSAI-1", "SNSSAI-2"],
    "SNSSAI_NRPLMN": [[1], [1]],
    "NRPLMN_IDs": [1],
    "defaultRG": {1: {"SA": {1: 2}}},
    "RG_profile_grp": {3: {"UL": 1}},
    "cellDepType": {1: "SANSA", 2: "SANSA", 3: "SA", 4: "SANSA"}
}

SAS_DELTA_K_B201 = {
    "RG_amount": 4,
    "minQuotas": [10, 20, 10, 10],
    "maxQuotas": [100, 80, 60, 30],
    "RG_profile_grp": {1: {"DL": 1}},
}


SAS_DELTA_K_B201_FIRST_CHANGE = {
    "RG_amount": 4,
    "minQuotas": [10, 20, 10, 50],
    "maxQuotas": [100, 80, 30, 90],
    "RG_profile_grp": {1: {"DL": 1}},
}


SAS_DELTA_K_B201_SECOND_CHANGE = {
    "RG_amount": 5,
    "minQuotas": [10, 50, 10, 10, 10],
    "maxQuotas": [100, 90, 60, 30, 60],
    "RG_profile_grp": {1: {"DL": 1}},
}

SAS_DELTA_G_009 = {
    "RG_amount": 5,
    "minQuotas": [20, 30, 30, 10, 10],
    "maxQuotas": [80, 70, 60, 80, 80],
    "resourceDN":
        ["NRSPIDGRP-1", "SNSSAI-1", "SNSSAI-2", ["SNSSAI-3", "NRSPIDGRP-2"], ["NRSPIDGRP-3", "SNSSAI-4", "SNSSAI-5"]],
    "NRSPIDGRP": [[1, 1, 10], [2, 11, 20], [2, 21, 30]],
    "SNSSAI_NRPLMN": [[1], [1], [2], [2], [2]],
    "NRPLMN_IDs": [1, 2],
    "defaultRG": {1: {"SA": {1: 2, 2: 3}, "NSA": {1: 1, 2: 5}}},
    "RG_profile_grp": {1: {"UL": 1}},
    "cellDepType": {1: "SANSA", 2: "SANSA", 3: "SANSA", 4: "SANSA"}
}

SAS_DELTA_G_010 = {
    "RG_amount": 2,
    "minQuotas": [30, 20],
    "maxQuotas": [70, 80],
    "resourceDN": ["SNSSAI-1", "SNSSAI-2"],
    "SNSSAI_NRPLMN": [[1], [1]],
    "NRPLMN_IDs": [1],
    "defaultRG": {1: {"SA": {1: 1}}},
    "RG_profile_grp": {3: {"UL": 1}},
    "cellDepType": {1: "SANSA", 2: "SANSA", 3: "SA", 4: "SANSA"}
}

SAS_DELTA_G_011 = {
    "RG_amount": 3,
    "minQuotas": [20, 30, 40],
    "maxQuotas": [80, 70, 60],
    "resourceDN":
        [["NRSPIDGRP-1", "SNSSAI-1", "SNSSAI-2"], ["NRSPIDGRP-2", "SNSSAI-3"], ["NRSPIDGRP-3", "SNSSAI-4", "SNSSAI-5"]],
    "NRSPIDGRP": [[1, 1, 10], [2, 11, 20], [2, 21, 30]],
    "SNSSAI_NRPLMN": [[1], [1], [2], [2], [2]],
    "NRPLMN_IDs": [1, 2],
    "defaultRG": {1: {"SA": {1: 1, 2: 2}, "NSA": {1: 1, 2: 3}}},
    "RG_profile_grp": {1: {"UL": 1}},
    "cellDepType": {1: "SANSA", 2: "SANSA", 3: "SANSA", 4: "SANSA"}
}

SAS_DELTA_G_012 = {
    "RG_amount": 20,
    "minQuotas": [0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0],
    "maxQuotas": [100, 100, 100, 100, 100, 100, 100, 100, 100, 100, 100, 100, 100, 100, 100, 100, 100, 100, 100, 100],
    "resourceDN": ["SNSSAI-1", "SNSSAI-2", "SNSSAI-3", "SNSSAI-4", "SNSSAI-5", "SNSSAI-6", "SNSSAI-7", "SNSSAI-8",
                   "SNSSAI-9", "SNSSAI-10", "NRSPIDGRP-1", "NRSPIDGRP-2", "NRSPIDGRP-3", "NRSPIDGRP-4", "NRSPIDGRP-5",
                   "NRSPIDGRP-6", "NRSPIDGRP-7", "NRSPIDGRP-8", "NRSPIDGRP-9", "NRSPIDGRP-10"],
    "NRSPIDGRP": [[1, 1, 10], [1, 11, 20], [1, 21, 30], [1, 31, 40], [1, 41, 50], [2, 51, 60], [2, 61, 70], [2, 71, 80],
                  [2, 81, 90], [2, 91, 100]],
    "SNSSAI_NRPLMN": [[1], [1], [1], [1], [1], [2], [2], [2], [2], [2]],
    "NRPLMN_IDs": [1, 2],
    "defaultRG": {1: {"SA": {1: 2, 2: 12}, "NSA": {1: 10, 2: 18}}},
    "RG_profile_grp": {1: {"UL": 1}},
    "cellDepType": {1: "SANSA", 2: "SANSA", 3: "SANSA", 4: "SANSA"}
}

SAS_DELTA_L_032 = {
    "RG_amount": 3,
    "minQuotas": [10, 20, 50],
    "maxQuotas": [20, 80, 50],
    "resourceDN": [["SNSSAI-1", "SNSSAI-2", "NRSPIDGRP-1", "NRSPIDGRP-2", "NRSPIDGRP-3"],
                   ["SNSSAI-3", "SNSSAI-4", "NRSPIDGRP-4"],
                   ["SNSSAI-5", "SNSSAI-6", "NRSPIDGRP-5", "NRSPIDGRP-6"]],
    "NRSPIDGRP": [[1, 1, 10], [2, 15, None], [3, 30, 40], [4, 100, 101], [5, 200, 255], [6, 256, None]],
    "SNSSAI_NRPLMN": [[1], [1], [2], [2], [3], [3]],
    "NRPLMN_IDs": [1, 2, 3, 4, 5, 6],
    "defaultRG": {1: {"NSA": {1: 1, 2: 1, 3: 1, 4: 2, 5: 3, 6: 3}, "SA": {1: 1, 2: 2, 3: 3}}},
    "RG_profile_grp": {1: {"DL": 1}},
    "cellDepType": {1: "SANSA", 2: "SANSA", 3: "SANSA", 4: "SANSA"}
}

SAS_DELTA_B_B1 = {
    "RG_amount": 8,
    "minQuotas": [5, 10, 20, 15, 5, 20, 10, 15],
    "maxQuotas": [10, 30, 20, 50, 5, 80, 25, 15],
    "resourceDN": [["SNSSAI-1"],
                   ["SNSSAI-2"],
                   ["SNSSAI-3"],
                   ["SNSSAI-4"],
                   ["NRSPIDGRP-1"],
                   ["NRSPIDGRP-2"],
                   ["NRSPIDGRP-3"],
                   ["NRSPIDGRP-4"],
                   ],
    "NRSPIDGRP": [[1, 1, 10], [2, 11, 15], [3, 20, 60], [4, 99, None]],
    "SNSSAI_NRPLMN": [[1], [1, 2, 3, 4], [1], [1]],
    "NRPLMN_IDs": [1, 2, 3, 4],
    "defaultRG": {1: {"NSA": {1: 5, 2: 6, 3: 7, 4: 8}, "SA": {1: 1, 2: 1, 3: 1, 4: 1}}},
    "RG_profile_grp": {1: {"DL": 1}},
    "cellDepType": {1: "SANSA", 2: "SANSA", 3: "SANSA", 4: "SANSA"},
    "should_set_actSliceNumExt_dynamically": False,
}

SAS_DELTA_B_EC2 = {
    "RG_amount": 4,
    "minQuotas": [5, 30, 20, 15],
    "maxQuotas": [100, 30, 80, 50],
    "resourceDN": [["SNSSAI-1"],
                   ["SNSSAI-2"],
                   ["SNSSAI-3"],
                   ["SNSSAI-4"]],
    "NRSPIDGRP": [],
    "SNSSAI_NRPLMN": [[1], [1], [1], [1]],
    "NRPLMN_IDs": [1],
    "defaultRG": {1: {"SA": {1: 1}}},
    "RG_profile_grp": {1: {"DL": 1}},
    "cellDepType": {1: "SA", 2: "SANSA", 3: "SANSA", 4: "SANSA"},
}

SAS_DELTA_A_EC2_3 = {
    "RG_amount": 7,
    "minQuotas": {1: [10, 5, 20, 10, 40], 2: [90, 7]},
    "maxQuotas": {1: [30, 50, 35, 55, 100], 2: [100, 53]},
    "resourceDN": {1: [["SNSSAI-1", "SNSSAI-2", "SNSSAI-3", "NRSPIDGRP-1", "NRSPIDGRP-2"],
                       ["NRSPIDGRP-3", "NRSPIDGRP-4"],
                       ["SNSSAI-4", "SNSSAI-5", "NRSPIDGRP-5"],
                       ["SNSSAI-6", "NRSPIDGRP-6"],
                       ["SNSSAI-7"],
                       ],
                   2: [["SNSSAI-8", "NRSPIDGRP-7"],
                       ["NRSPIDGRP-8"],
                       ]
                   },
    "NRSPIDGRP": [[1, 1, 9],
                  [2, 54, None],
                  [3, 5, 15],
                  [1, 71, None],
                  [2, 150, 255],
                  [3, 100, None],
                  [2, 157, None],
                  [2, 71, 90]],
    "SNSSAI_NRPLMN": [[1], [1, 3], [3], [2], [3], [2], [2], [2]],
    "NRPLMN_IDs": [1, 2, 3],
    "defaultRG": {1: {"NSA": {3: 1, 2: 2, 1: 3}, "SA": {1: 2, 2: 5, 3: 4}},
                  2: {"SA": {1: 2, 2: 1, 3: 1}, "NSA": {1: 2}}},
    "RG_profile_grp": {1: {"UL": 1}, 4: {"UL": 2}},
    "cellDepType": {1: "SANSA", 2: "SANSA", 3: "SANSA", 4: "SANSA"}
}

SAS_DELTA_C_ROBUSTNESS = {
    "RG_amount": 2,
    "minQuotas": [10, 45, 20, 10, 40],
    "maxQuotas": [38, 100, 35, 55, 100],
    "resourceDN": [["SNSSAI-1", "SNSSAI-2", "NRSPIDGRP-1"],
                   ["SNSSAI-3", "NRSPIDGRP-2"]],
    "NRSPIDGRP": [[3, 100, 160],
                  [1, 5, 32]],
    "SNSSAI_NRPLMN": [[1], [2, 3], [1, 2]],
    "NRPLMN_IDs": [1, 2, 3],
    "defaultRG": {1: {"NSA": {1: 2, 3: 1, 2: 1}, "SA": {1: 2, 2: 2, 3: 2}}},
    "RG_profile_grp": {1: {"UL": 1, "DL": 1}, 3: {"UL": 1}, 4: {"DL": 1}},
    "cellDepType": {1: "SANSA", 2: "SANSA", 3: "SANSA", 4: "SANSA"},
    "should_set_actSliceNumExt_dynamically": False,
}

SAS_DELTA_K_B102 = {
        "RG_amount": 2,
        "minQuotas": [20, 30],
        "maxQuotas": [80, 60],
        "resourceDN": ["SNSSAI-1", "SNSSAI-2"],
        "SNSSAI_NRPLMN": [[1], [2]],
        "NRPLMN_IDs": [1, 2],
        "defaultRG": {1: {"SA": {1: 1, 2: 2}}},
        "RG_profile_grp": {3: {"UL": 1}},
        "cellDepType": {1: "SA", 2: "SA", 3: "SA", 4: "SA"},
        "should_set_actSliceNumExt_dynamically": False,
    }

SAS_DELTA_K_B103 = {
        "RG_amount": 4,
        "minQuotas": [20, 10, 20, 20],
        "maxQuotas": [70, 40, 25, 25],
        "resourceDN": ["SNSSAI-1", "SNSSAI-2", "SNSSAI-3", "SNSSAI-4"],
        "SNSSAI_NRPLMN": [[1], [2], [2], [2]],
        "NRPLMN_IDs": [1, 2],
        "defaultRG": {1: {"SA": {1: 1, 2: 1}}},
        "RG_profile_grp": {1: {"UL": 1}},
        "cellDepType": {1: "SA", 2: "SA", 3: "SA", 4: "SA"}
    }

SAS_DELTA_K_013 = {
    "RG_amount": 3,
    "minQuotas": [20, 10, 30],
    "maxQuotas": [60, 40, 50],
    "resourceDN": [["SNSSAI-1", "SNSSAI-2"], "SNSSAI-3", ["SNSSAI-4", "SNSSAI-5"]],
    "SNSSAI_NRPLMN": [[1], [1], [1], [2], [2], [1]],
    "NRPLMN_IDs": [1, 2],
    "defaultRG": {1: {"SA": {1: 1, 2: 3}}},
    "RG_profile_grp": {3: {"UL": 1}},
    "cellDepType": {1: "SANSA", 2: "SANSA", 3: "SA", 4: "SANSA"}
}

SAS_DELTA_K_014 = {
    "RG_amount": 3,
    "minQuotas": [10, 20, 30],
    "maxQuotas": [30, 60, 70],
    "resourceDN":
        [["NRSPIDGRP-1", "NRSPIDGRP-2"], ["NRSPIDGRP-3", "NRSPIDGRP-4"], ["NRSPIDGRP-5"]],
    "NRSPIDGRP": [[1, 20, 40], [1, 41, 60], [2, 61, 80], [2, 81, 100], [2, 101, 120]],
    "NRPLMN_IDs": [1, 2],
    "defaultRG": {1: {"NSA": {1: 1, 2: 3}}},
    "RG_profile_grp": {1: {"UL": 1}},
    "cellDepType": {1: "NSA", 2: "NSA", 3: "NSA", 4: "NSA"}
}

SAS_DELTA_K_015 = {
    "RG_amount": 6,
    "minQuotas": [10, 10, 20, 30, 20, 10],
    "maxQuotas": [30, 20, 30, 50, 50, 20],
    "resourceDN":
        [["NRSPIDGRP-1", "SNSSAI-1"], ["SNSSAI-2", "SNSSAI-3"], ["NRSPIDGRP-2", "NRSPIDGRP-3"],
         ["NRSPIDGRP-4", "SNSSAI-4"], ["SNSSAI-5", "SNSSAI-6"], ["NRSPIDGRP-5", "NRSPIDGRP-6"]],
    "NRSPIDGRP": [[1, 20, 40], [1, 41, 60], [1, 61, 80], [2, 81, 100], [2, 101, 120], [2, 121, 140]],
    "SNSSAI_NRPLMN": [[1], [1], [1], [2], [2], [2], [1, 2]],
    "NRPLMN_IDs": [1, 2],
    "defaultRG": {1: {"SA": {1: 1, 2: 4}, "NSA": {1: 1, 2: 4}}},
    "RG_profile_grp": {3: {"UL": 1}},
    "cellDepType": {1: "SANSA", 2: "SANSA", 3: "SANSA", 4: "SANSA"}
}

SAS_DELTA_K_016 = {
    "RG_amount": 2,
    "minQuotas": [10, 40],
    "maxQuotas": [40, 80],
    "resourceDN": [["NRSPIDGRP-1", "NRSPIDGRP-2"], ["NRSPIDGRP-3", "NRSPIDGRP-4"]],
    "NRSPIDGRP": [[1, 20, 40], [1, 41, 60], [1, 61, 80], [1, 81, 100]],
    "NRPLMN_IDs": [1],
    "defaultRG": {1: {"NSA": {1: 1}}},
    "RG_profile_grp": {1: {"UL": 1}},
    "cellDepType": {1: "NSA", 2: "SANSA", 3: "SANSA", 4: "SANSA"}
}

SAS_DELTA_K_017 = {
    "RG_amount": 5,
    "minQuotas": [20, 25, 20, 20, 10],
    "maxQuotas": [70, 60, 60, 80, 40],
    "resourceDN": ["NRSPIDGRP-1", "NRSPIDGRP-2", "NRSPIDGRP-3", "NRSPIDGRP-4", ["NRSPIDGRP-5", "NRSPIDGRP-6"]],
    "NRSPIDGRP": [[1, 20, 40], [1, 41, 60], [2, 61, 80], [2, 81, 100], [1, 101, 120], [2, 121, 140]],
    "NRPLMN_IDs": [1, 2],
    "defaultRG": {1: {"NSA": {1: 2, 2: 4}}},
    "RG_profile_grp": {3: {"UL": 1}},
    "cellDepType": {1: "NSA", 2: "NSA", 3: "NSA", 4: "NSA"}
}

SAS_DELTA_K_018 = {
    "RG_amount": 5,
    "minQuotas": [10, 20, 20, 30, 10],
    "maxQuotas": [50, 50, 60, 60, 30],
    "resourceDN": ["SNSSAI-1", "SNSSAI-2", "SNSSAI-3", "SNSSAI-4", "SNSSAI-5"],
    "SNSSAI_NRPLMN": [[1], [1], [2], [2], [1, 2]],
    "NRPLMN_IDs": [1, 2],
    "defaultRG": {1: {"SA": {1: 2, 2: 4}}},
    "RG_profile_grp": {1: {"UL": 1}},
    "cellDepType": {1: "SA", 2: "SANSA", 3: "SANSA", 4: "SANSA"}
}

SAS_DELTA_K_019 = {
    "RG_amount": 3,
    "minQuotas": [30, 20, 30],
    "maxQuotas": [60, 30, 60],
    "resourceDN": [["SNSSAI-1", "SNSSAI-2"], "SNSSAI-3", ["SNSSAI-4", "SNSSAI-5"]],
    "SNSSAI_NRPLMN": [[1], [1], [1], [1], [1]],
    "NRPLMN_IDs": [1],
    "defaultRG": {1: {"SA": {1: 2}}},
    "RG_profile_grp": {3: {"UL": 1}},
    "cellDepType": {1: "SANSA", 2: "SANSA", 3: "SA", 4: "SANSA"}
}

ONLINE_CHANGE_SAS_DELTA_K_019 = {
    "RG_amount": 2,
    "minQuotas": [30, 20],
    "maxQuotas": [60, 30],
    "RG_profile_grp": {3: {"UL": 1}},
}

SAS_DELTA_K_020 = {
    "RG_amount": 3,
    "minQuotas": [40, 10, 20],
    "maxQuotas": [70, 30, 60],
    "resourceDN": [["NRSPIDGRP-1", "NRSPIDGRP-2"], ["NRSPIDGRP-3", "NRSPIDGRP-4"], ["NRSPIDGRP-5", "NRSPIDGRP-6"]],
    "NRSPIDGRP": [[1, 20, 40], [1, 41, 60], [2, 61, 80], [2, 81, 100], [1, 101, 120], [2, 121, 140]],
    "NRPLMN_IDs": [1, 2],
    "defaultRG": {1: {"NSA": {1: 1, 2: 2}}},
    "RG_profile_grp": {1: {"UL": 1}},
    "cellDepType": {1: "NSA", 2: "NSA", 3: "NSA", 4: "NSA"}
}

ONLINE_CHANGE_SAS_DELTA_K_020 = {
    "RG_amount": 2,
    "minQuotas": [40, 10],
    "maxQuotas": [70, 30],
    "RG_profile_grp": {1: {"UL": 1}},
}

SAS_DELTA_K_021 = {
    "RG_amount": 4,
    "minQuotas": [5, 10, 20, 40],
    "maxQuotas": [20, 30, 60, 70],
    "resourceDN": ["SNSSAI-1", "NRSPIDGRP-1", ["NRSPIDGRP-2", "SNSSAI-2"], ["NRSPIDGRP-3", "SNSSAI-3"]],
    "NRSPIDGRP": [[1, 20, 40], [1, 41, 60], [1, 61, 80]],
    "SNSSAI_NRPLMN": [[1], [2], [1, 2]],
    "NRPLMN_IDs": [1, 2],
    "defaultRG": {1: {"SA": {1: 1, 2: 3}, "NSA": {1: 2, 2: 3}}},
    "RG_profile_grp": {3: {"UL": 1}},
    "cellDepType": {1: "SANSA", 2: "SANSA", 3: "SANSA", 4: "SANSA"}
}

ONLINE_CHANGE_SAS_DELTA_K_021 = {
    "RG_amount": 3,
    "minQuotas": [5, 10, 20],
    "maxQuotas": [20, 30, 60],
    "RG_profile_grp": {3: {"UL": 1}},
}

SAS_DELTA_K_022 = {
    "RG_amount": 4,
    "minQuotas": [20, 40, 30, 10],
    "maxQuotas": [80, 70, 60, 30],
    "resourceDN": ["SNSSAI-1", "SNSSAI-2", "SNSSAI-3", "SNSSAI-4"],
    "SNSSAI_NRPLMN": [[1], [1], [1], [2]],
    "NRPLMN_IDs": [1, 2],
    "defaultRG": {1: {"SA": {1: 1, 2: 4}}},
    "RG_profile_grp": {1: {"UL": 1}},
    "cellDepType": {1: "SA", 2: "SANSA", 3: "SANSA", 4: "SANSA"}
}

SAS_DELTA_K_023 = {
    "RG_amount": 2,
    "minQuotas": [30, 20],
    "maxQuotas": [80, 70],
    "resourceDN": [["NRSPIDGRP-1", "NRSPIDGRP-2"], ["NRSPIDGRP-3", "NRSPIDGRP-4"]],
    "NRSPIDGRP": [[1, 20, 40], [1, 41, 60], [1, 61, 80], [1, 81, 100]],
    "NRPLMN_IDs": [1],
    "defaultRG": {1: {"NSA": {1: 2}}},
    "RG_profile_grp": {3: {"UL": 1}},
    "cellDepType": {1: "SANSA", 2: "SANSA", 3: "NSA", 4: "SANSA"}
}

SAS_DELTA_K_024 = {
    "RG_amount": 8,
    "minQuotas": [20, 10, 5, 6, 7, 8, 9, 10],
    "maxQuotas": [40, 30, 50, 80, 80, 80, 80, 80],
    "resourceDN":
        ["SNSSAI-1", "NRSPIDGRP-1", "SNSSAI-2", "NRSPIDGRP-2", "SNSSAI-3", "NRSPIDGRP-3",
         ["SNSSAI-4", "NRSPIDGRP-4"], "NRSPIDGRP-5"],
    "NRSPIDGRP": [[1, 20, 40], [1, 41, 60], [2, 61, 80], [2, 81, 100], [2, 101, 120]],
    "SNSSAI_NRPLMN": [[1], [1], [2], [2], [1], [2]],
    "NRPLMN_IDs": [1, 2],
    "defaultRG": {1: {"SA": {1: 1, 2: 5}, "NSA": {1: 2, 2: 6}}},
    "RG_profile_grp": {1: {"UL": 1}},
    "cellDepType": {1: "SANSA", 2: "SANSA", 3: "SANSA", 4: "SANSA"}
}

SAS_DELTA_K_025 = {
    "RG_amount": 2,
    "minQuotas": [20, 30],
    "maxQuotas": [60, 80],
    "resourceDN": [["SNSSAI-1", "SNSSAI-2"], "SNSSAI-3"],
    "SNSSAI_NRPLMN": [[1], [1], [2]],
    "NRPLMN_IDs": [1, 2],
    "defaultRG": {1: {"SA": {1: 1, 2: 2}}},
    "RG_profile_grp": {3: {"UL": 1}},
    "cellDepType": {1: "SANSA", 2: "SANSA", 3: "SA", 4: "SANSA"}
}

ONLINE_CHANGE_SAS_DELTA_K_025 = {
    "RG_amount": 4,
    "minQuotas": [20, 30, 20, 10],
    "maxQuotas": [60, 80, 40, 24],
    "RG_profile_grp": {3: {"UL": 1}},
}

SAS_DELTA_K_026 = {
    "RG_amount": 2,
    "minQuotas": [10, 30],
    "maxQuotas": [70, 60],
    "resourceDN": [["NRSPIDGRP-1", "NRSPIDGRP-2"], "NRSPIDGRP-3"],
    "NRSPIDGRP": [[1, 20, 40], [1, 41, 60], [1, 61, 80]],
    "NRPLMN_IDs": [1],
    "defaultRG": {1: {"NSA": {1: 1}}},
    "RG_profile_grp": {1: {"UL": 1}},
    "cellDepType": {1: "NSA", 2: "SANSA", 3: "SANSA", 4: "SANSA"}
}

ONLINE_CHANGE_SAS_DELTA_K_026 = {
    "RG_amount": 3,
    "minQuotas": [10, 30, 5],
    "maxQuotas": [70, 60, 20],
    "RG_profile_grp": {1: {"UL": 1}},
}

SAS_DELTA_K_027 = {
    "RG_amount": 5,
    "minQuotas": [10, 10, 15, 25, 10],
    "maxQuotas": [20, 80, 80, 90, 80],
    "resourceDN": ["SNSSAI-1", "NRSPIDGRP-1", "SNSSAI-2", "NRSPIDGRP-2", "NRSPIDGRP-3"],
    "NRSPIDGRP": [[1, 20, 40], [2, 41, 60], [2, 61, 80]],
    "SNSSAI_NRPLMN": [[1], [2]],
    "NRPLMN_IDs": [1, 2],
    "defaultRG": {1: {"SA": {1: 1, 2: 5}, "NSA": {1: 2, 2: 6}}},
    "RG_profile_grp": {3: {"UL": 1}},
    "cellDepType": {1: "SANSA", 2: "SANSA", 3: "SANSA", 4: "SANSA"}
}

ONLINE_CHANGE_SAS_DELTA_K_027 = {
    "RG_amount": 8,
    "minQuotas": [10, 10, 15, 25, 10, 5, 4, 11],
    "maxQuotas": [20, 80, 80, 90, 80, 70, 70, 20],
    "RG_profile_grp": {3: {"UL": 1}},
}

SAS_DELTA_K_028 = {
    "RG_amount": 6,
    "minQuotas": [8, 20, 10, 13, 3, 8],
    "maxQuotas": [40, 50, 60, 80, 80, 40],
    "resourceDN": [["SNSSAI-1", "NRSPIDGRP-1"], "SNSSAI-2", "NRSPIDGRP-2",
                   ["SNSSAI-3", "NRSPIDGRP-3"], "SNSSAI-4", "NRSPIDGRP-4"],
    "NRSPIDGRP": [[1, 20, 40], [1, 41, 60], [2, 61, 80], [2, 81, 100], [1, 101, 120], [2, 121, 140], [2, 141, 160]],
    "SNSSAI_NRPLMN": [[1], [1], [1], [2], [1], [2], [1]],
    "NRPLMN_IDs": [1, 2],
    "defaultRG": {1: {"SA": {1: 2, 2: 5}, "NSA": {1: 3, 2: 6}}},
    "RG_profile_grp": {1: {"UL": 1}},
    "cellDepType": {1: "SANSA", 2: "SANSA", 3: "SANSA", 4: "SANSA"}
}

ONLINE_CHANGE_SAS_DELTA_K_028 = {
    "RG_amount": 10,
    "minQuotas": [8, 20, 10, 13, 3, 8, 5, 6, 11, 5],
    "maxQuotas": [40, 50, 60, 80, 80, 40, 15, 60, 39, 35],
    "RG_profile_grp": {1: {"UL": 1}},
}

SAS_DELTA_K_029 = {
    "RG_amount": 8,
    "minQuotas": [20, 10, 10, 20, 17, 5, 10, 0],
    "maxQuotas": [80, 30, 60, 80, 70, 40, 90, 100],
    "resourceDN": [["SNSSAI-1", "NRSPIDGRP-1"], ["SNSSAI-2", "NRSPIDGRP-2"], "SNSSAI-3", "NRSPIDGRP-3",
                   ["SNSSAI-4", "NRSPIDGRP-4"], ["SNSSAI-5", "NRSPIDGRP-5"], "SNSSAI-6", "NRSPIDGRP-6"],
    "NRSPIDGRP": [[1, 20, 40], [1, 41, 60], [1, 61, 80], [2, 81, 100], [2, 101, 120], [2, 121, 140]],
    "SNSSAI_NRPLMN": [[1], [1], [1], [2], [2], [2]],
    "NRPLMN_IDs": [1, 2],
    "defaultRG": {1: {"SA": {1: 2, 2: 7}, "NSA": {1: 2, 2: 8}}},
    "RG_profile_grp": {3: {"UL": 1}},
    "cellDepType": {1: "SANSA", 2: "SANSA", 3: "SANSA", 4: "SANSA"}
}

ONLINE_CHANGE_SAS_DELTA_K_029 = {
    "RG_amount": 9,
    "minQuotas": [20, 10, 10, 20, 17, 5, 0, 10, 0],
    "maxQuotas": [80, 30, 60, 80, 70, 90, 100, 15, 100],
    "RG_profile_grp": {3: {"UL": 1}},
}

SAS_DELTA_K_030 = {
    "RG_amount": 7,
    "minQuotas": [20, 25, 13, 4, 10, 20, 1],
    "maxQuotas": [80, 60, 33, 24, 30, 80, 100],
    "resourceDN": ["SNSSAI-1", "SNSSAI-2", "SNSSAI-3", "SNSSAI-4", "SNSSAI-5", "SNSSAI-6", "SNSSAI-7"],
    "SNSSAI_NRPLMN": [[1], [1], [1], [1], [2], [2], [2]],
    "NRPLMN_IDs": [1, 2],
    "defaultRG": {1: {"SA": {1: 2, 2: 7}}},
    "RG_profile_grp": {1: {"DL": 1}},
    "cellDepType": {1: "SA", 2: "SANSA", 3: "SANSA", 4: "SANSA"}
}

ONLINE_CHANGE_SAS_DELTA_K_030 = {
    "RG_amount": 8,
    "minQuotas": [20, 25, 13, 4, 10, 1, 10, 2],
    "maxQuotas": [80, 60, 33, 24, 30, 100, 30, 40],
    "RG_profile_grp": {1: {"DL": 1}},
}

SAS_DELTA_K_031 = {
    "RG_amount": 7,
    "minQuotas": [10, 10, 5, 10, 10, 10, 30],
    "maxQuotas": [90, 60, 40, 80, 80, 50, 70],
    "resourceDN":
        ["NRSPIDGRP-1", "NRSPIDGRP-2", "NRSPIDGRP-3", "NRSPIDGRP-4", "NRSPIDGRP-5", "NRSPIDGRP-6", "NRSPIDGRP-7"],
    "NRSPIDGRP": [[1, 20, 40], [1, 41, 60], [1, 61, 80], [1, 81, 100], [2, 101, 120], [2, 121, 140], [2, 141, 160]],
    "NRPLMN_IDs": [1, 2],
    "defaultRG": {1: {"NSA": {1: 2, 2: 7}}},
    "RG_profile_grp": {3: {"UL": 1, "DL": 1}},
    "cellDepType": {1: "NSA", 2: "NSA", 3: "NSA", 4: "NSA"}
}

ONLINE_CHANGE_3_SAS_DELTA_K_031 = {
    "RG_amount": 8,
    "minQuotas": [10, 10, 5, 10, 10, 10, 30, 10],
    "maxQuotas": [90, 60, 40, 80, 80, 50, 70, 40],
    "RG_profile_grp": {3: {"UL": 1, "DL": 1}},
}
ONLINE_CHANGE_4_SAS_DELTA_K_031 = {
    "RG_amount": 9,
    "minQuotas": [10, 10, 5, 10, 10, 10, 30, 10, 10],
    "maxQuotas": [90, 60, 40, 80, 80, 50, 70, 40, 60],
    "RG_profile_grp": {3: {"UL": 1, "DL": 1}},
}

SAS_DELTA_C_EC2_3 = {
    "RG_amount": 4,
    "minQuotas": [30, 0, 40, 20],
    "maxQuotas": [70, 3, 42, 100],
    "resourceDN":
        [["SNSSAI-1", "SNSSAI-2"],
         ["SNSSAI-3", "NRSPIDGRP-1"],
         ["NRSPIDGRP-2", "NRSPIDGRP-3", "SNSSAI-4"],
         ["SNSSAI-5", "NRSPIDGRP-4"]],
    "NRSPIDGRP": [[3, 100, 160], [1, 5, 32], [1, 33, 51], [3, 1, None]],
    "SNSSAI_NRPLMN": [[1], [1, 2], [2], [1, 2], [2, 3]],
    "NRPLMN_IDs": [1, 2, 3],
    "defaultRG": {1: {"NSA": {1: 3, 2: 1, 3: 1}, "SA": {1: 1, 2: 2, 3: 2}}},
    "RG_profile_grp": {3: {"UL": 1, "DL": 1}, 4: {"DL": 1}, 1: {"UL": 1}},
    "cellDepType": {1: "SANSA", 2: "SANSA", 3: "SANSA", 4: "SANSA"},
    "should_set_actSliceNumExt_dynamically": False,
}

SAS_DELTA_J_EC301 = {
    "RG_amount": 7,
    "minQuotas": {1: [5, 17, 10, 40], 2: [30, 5, 10]},
    "maxQuotas": {1: [55, 17, 95, 100], 2: [70, 37, 65]},
    "resourceDN": {1: ["SNSSAI-1", "SNSSAI-2", "SNSSAI-3", "SNSSAI-4"],
                   2: ["SNSSAI-2", "SNSSAI-5", "SNSSAI-6"]},
    "SNSSAI_NRPLMN": [[1], [1, 2], [2], [1, 2], [1], [2]],
    "NRPLMN_IDs": [1, 2],
    "defaultRG": {1: {"SA": {1: 3, 2: 3}}, 2: {"SA": {1: 2, 2: 3}}},
    "RG_profile_grp": {3: {"UL": 1}, 4: {"UL": 2}},
    "cellDepType": {1: "SA", 2: "SA", 3: "SA", 4: "SA"}
}

SAS_DELTA_J_EC301_HO = {
    "RG_amount": 7,
    "minQuotas": {1: [5, 10, 40], 2: [17, 30, 5, 10]},
    "maxQuotas": {1: [55, 95, 100], 2: [17, 70, 37, 65]},
    "resourceDN": {1: ["SNSSAI-1", "SNSSAI-2", "SNSSAI-3", "SNSSAI-4"],
                   2: ["SNSSAI-2", "SNSSAI-5", "SNSSAI-6"]},
    "SNSSAI_NRPLMN": [[1], [1, 2], [2], [1, 2], [1], [2]],
    "NRPLMN_IDs": [1, 2],
    "defaultRG": {1: {"SA": {1: 3, 2: 3}}, 2: {"SA": {1: 2, 2: 3}}},
    "RG_profile_grp": {3: {"UL": 1}, 4: {"UL": 2}},
    "cellDepType": {1: "SA", 2: "SA", 3: "SA", 4: "SA"}
}

QC_TESTCASES_TITLES = {
    "TDD": {
        "C-Robustness_035": "CB008709-C-Robustness_035_UE_with_tput_alternating_between_two_RGs",
        "K-B103_025": "CB008709-K-B103_025_UL_SAS_online_quotas_modification_TDD",
        "K-B201_028":
            "CB008709-K-B201_028_Slice_aware_downlink_scheduler_with_RG_configuration_change_via_online_modification_"
            "TDD_SA+NSA_with_CB008746",
        "A-EC201_003":
            "CB008709-A-EC201_003_Slice_aware_uplink_scheduler_for_the_special_case_of_single_RG_per_UE_with_empty_RG_"
            "in_the_cell_TDD_SA_NSA",
        "B-B102_006": "CB008709-B-B102_006_Slice_aware_downlink_scheduler_TDD",
        "B-EC201_012": "CB008709-B-EC201_012_Slice_aware_downlink_scheduler_with_empty_RG_in_the_cell_TDD"
            "_low_buffer_RGs_TDD",
        "L-B101_032": "CB008709-L-B101_032_Slice_aware_downlink_scheduler_TDD_SANSA_with_mixed_resources",
    },
    "FDD": {
        "J-EC301_022": "CB008709-J-EC301_022_Slice_aware_uplink_scheduler_interacts_with_handover_for_non"
                       "-configured_RG_in_target_cell",
        "K-B102_024": "CB008709-K-B102_024_UL_SAS_online_deactivation_and_reactivation_FDD",
        "C-EC201_014":  "CB008709-C-EC201_014_Slice_aware_uplink_and_downlink_scheduler_interworking_FDD",
    }
}

# TTI
COLLECTOR_NAME = "l2stream3"
TTITRACE_NAME_PREFIX = "ttitrace_8709_"

# BIP
BIP_NAME_PREFIX = "bip_8709_"

# NG
NG_NAME_PREFIX = "8709"

# SYSLOG
SYSLOG_NAME_PREFIX = "syslog_8709_"
SYSLOG_ALIAS = "ALIAS_SYSLOG_GNB"

_dirname_8709 = "CB008709_Slice_aware_uplink_scheduler"
_path_qc_8709 = f"Root\\Test_Sets\\Trunk\\VRF_WRO1\\CRT\\{_dirname_8709}"
_projectname_qc_8709_A = "CB008709-A Single RG per UE for UL SAS"
_projectname_qc_8709_B = "CB008709-B Enhanced SVC for RG based DL SAS"
_projectname_qc_8709_C = "CB008709-C Multiple RGs per UE for UL SAS"
_projectname_qc_8709_L = "CB008709-L Add NSA support to RG concept for DL"
_projectname_qc_8709_K = "CB008709-K Online RG reconfiguration"
_projectname_qc_8709_J = "CB008709-J Interaction with CA and handover"

QC_DIR_NAMES = {
    "SBTS00": {
        "K-B102_024": {"path": _path_qc_8709, "project": _projectname_qc_8709_K},
        "K-B103_025": {"path": _path_qc_8709, "project": _projectname_qc_8709_K},
        "K-B201_028": {"path": _path_qc_8709, "project": _projectname_qc_8709_K},
        "A-EC201_003": {"path": _path_qc_8709, "project": _projectname_qc_8709_A},
        "B-B102_006": {"path": _path_qc_8709, "project": _projectname_qc_8709_B},
        "B-EC201_012": {"path": _path_qc_8709, "project": _projectname_qc_8709_B},
        "L-B101_032": {"path": _path_qc_8709, "project": _projectname_qc_8709_L},
        "J-EC301_022": {"path": _path_qc_8709, "project": _projectname_qc_8709_J},
        "C-EC201_014":  {"path": _path_qc_8709, "project": _projectname_qc_8709_C},
        "C-Robustness_035": {"path": _path_qc_8709, "project": _projectname_qc_8709_C},
    }
}

_DESC = "Krakow VRF Engineering team testcases for CB008709 feature"
_QC_DOC = \
    f"maintainer: Adrianna Pienkowska, Jacek Kozmic, Agata Sidlo, Sebastian Talka\ndescription:\n{_DESC}"

REPORT_QC = {
    "qc_project": "RAN_ET",
    "qc_domain": "MN_RAN",
    "ca": "RAN_L2_SW_KRK_2",
    "username": "owner",
    "links": {},
    "add_info": ["UTE", "TAF"],
    "suite_path": None,
    "qc_testlab_path": None,
    "qc_test_set_name": None,
    "features_covered": None,
    "doc": _QC_DOC
}
