# -*- coding: utf-8 -*-
"""
:copyright: Nokia Networks
:author: Chen Jun
:contact: jun.8.chen@nokia-sbell.com
"""
#
ALLOWED_FAULT_UUF = [
    {'faultId': 61652},
    {'faultId': 61524},
    {'faultId': 61649},
    {'faultId': 9000},
    {'faultId': 4592},
    {'faultId': 4527},
    {'faultId': 1932},
    {'faultId': 4334},
    {'faultId': 61074},
    {'faultId': 61618},
    {'faultId': 4687},
    {'faultId': 4654},
    {'faultId': 4655},
    {'faultId': 4459},
    {'faultId': 4073},
    {'faultId': 4078},
    {'faultId': 1838},
    {'faultId': 4046},
    {'faultId': 4293},
    {'faultId': 1955},
    {'faultId': 7319},
    {'faultId': 7300},
    {'faultId': 4589},
    {'faultId': 4297},
    {'faultId': 6261},
]

ALLOWED_HISTORY_FAULT_UUF = [
    {'faultId': 7319},
    {'faultId': 7300},
    {'faultId': 4589},
    {'faultId': 4297},
    {'faultId': 6261},
]

ALLOWED_HISTORY_FAULT_UUF.extend(ALLOWED_FAULT_UUF)

TDD_DL_EXPECT_TPUT_TABLE = {
    "100MHz": "1420",
    "80MHz": "1066",
    "60MHz": "800",
    "50MHz": "677",
    "40MHz": "550",
    "20MHz": "210",
    "20MHz_layer2": "105",
    "not_peak": "200",
    "no_data": "0",
}

TDD_UL_EXPECT_TPUT_TABLE = {
    "100MHz": "150",
    "80MHz": "100",
    "60MHz": "60",
    "50MHz": "55",
    "40MHz": "40",
    "20MHz": "20",
    "100MHz_layer1": "55",
    "80MHz_layer1": "50",
    "60MHz_layer1": "30",
    "50MHz_layer1": "27",
    "40MHz_layer1": "20",
    "20MHz_layer1": "10",
    "not_peak": "10",
    "no_data": "0",
}

FDD_DL_EXPECT_TPUT_TABLE = {
    "10MHz": "95",
    "15MHz": "75",
    "20MHz": "100",
    "10MHz_DSS_Phase_3": "95",
    "15MHz_DSS_Phase_3": "121",
    "20MHz_DSS_Phase_3": "166",
    "not_peak": "75",
    "no_data": "0",
}

FDD_UL_EXPECT_TPUT_TABLE = {
    "10MHz": "10",
    "15MHz": "22",
    "20MHz": "30",
    "10MHz_DSS_Phase_3": "10",
    "15MHz_DSS_Phase_3": "37",
    "20MHz_DSS_Phase_3": "55",
    "not_peak": "10",
    "no_data": "0",
}

# Mode:tl_stream_ueIndex_ruIndex_paIndexInInit_paPort/value
T813_PA_VALUE_MAPPING = {
    '22R1': {
        0: {
            '0': {0: {'1': '10', '2': '10', '3': '10', '4': '10'}},
            '1': {0: {'5': '10', '6': '10', '7': '10', '8': '10'}},
            '2': {0: {'13': '0', '14': '0'}},
            '3': {1: {'7': '0', '8': '0'}},
            '4': {1: {'5': '0', '6': '0'}},
            '5': {0: {'9': '0', '10': '0'}},
            '6': {0: {'11': '0', '12': '0'}},
            '7': {0: {'15': '0', '16': '0'}},
        },
    },
    '22R2': {
        0: {
            '0': {0: {'1': '10', '2': '10', '3': '10', '4': '10'}},
            '1': {0: {'5': '10', '6': '10', '7': '10', '8': '10'}},
            '2': {0: {'13': '0', '14': '0'}},
            '3': {1: {'7': '0', '8': '0'}},
            '4': {1: {'5': '0', '6': '0'}},
            '5': {0: {'9': '0', '10': '0'}},
            '6': {0: {'11': '0', '12': '0'}},
            '7': {0: {'15': '0', '16': '0'}},
        },
    }
}

# Mode:tl_stream_ueIndex_ruIndex_paIndexInInit_paPort/value
T073_PA_VALUE_MAPPING = {
    '22R1': {
        0: {
            '1': {0: {'1': '10', '2': '10', '3': '10', '4': '10'}},
            '3': {0: {'9': '15', '10': '15'}},
            '4': {0: {'11': '15', '12': '15'}},
            '6': {0: {'5': '0', '6': '0'}},
            '7': {0: {'7': '0', '8': '0'}},
        },
    },
    '22R2': {
        0: {
            '1': {0: {'1': '10', '2': '10', '3': '10', '4': '10'}},
            '3': {0: {'9': '15', '10': '15'}},
            '4': {0: {'11': '15', '12': '15'}},
            '6': {0: {'5': '0', '6': '0'}},
            '7': {0: {'7': '0', '8': '0'}},
        },
    }
}


GNB_INFO_MAPPING_TO_CASE_TABLE = {
    "5603018": {
        "T813": {"ca_technology": "TDD+TDD", "pcell_idx": 301, "attenuator": ["pa"]},
        "T073": {"ca_technology": "TDD+TDD", "pcell_idx": 301, "attenuator": ["mcs"]},
    },
    "5603001": {
        "T813": {"ca_technology": "FDD+TDD", "pcell_idx": 11, "attenuator": ["pa"]},
        "T073": {"ca_technology": "FDD+TDD", "pcell_idx": 11, "attenuator": ["mcs", "pa"]},
    },
    "5603003": {
        "T813": {"ca_technology": "FDD+TDD", "pcell_idx": 11, "attenuator": ["pa"]},
        "T073": {"ca_technology": "FDD+TDD", "pcell_idx": 11, "attenuator": ["mcs", "pa"]},
    },
    "5603009": {"pcell_idx": 301},
    "5603008": {"pcell_idx": 301},
    "5603007": {"pcell_idx": 301},
    "5603033": {"pcell_idx": 301},
    "5603002": {
        "pcell_idx": 11,
        "pa_port_value_mapping": {
            "9": "15",
            "10": "15"
        },
    },
    "5603010": {
        "pcell_idx": 11,
        "pa_port_value_mapping": {
            "5": "15",
            "6": "15",
            "9": "15",
            "10": "15"
        },
    },
    "5603014": {
        "pcell_idx": 301,
        "ho_port_value_mapping": {
            "9": "15",
            "10": "15"
        },
        "after_ho_pcell_idx": 11,
    },
    "5603049": {"pcell_idx": 301},
    "5603036": {"pcell_idx": 401},
}
