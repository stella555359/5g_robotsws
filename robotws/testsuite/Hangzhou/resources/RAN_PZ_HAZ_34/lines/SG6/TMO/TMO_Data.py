# -*- coding: utf-8 -*-
"""
:copyright: Nokia Networks
:author: Chen Jun
:contact: jun.8.chen@nokia-sbell.com
"""
#
from robot.libraries.BuiltIn import BuiltIn


tl = BuiltIn().get_variable_value("${tl}")
mrbts_id = tl.gnbs[0].instance_id
nrbts_id = tl.gnbs[0].global_bts_id

TDD_DL_EXPECT_TPUT_TABLE = {
    "100MHz": "1420",
    "90MHz": "1250",
    "80MHz": "1079",
    "70MHz": "950",
    "60MHz": "840",
    "50MHz": "665",
    "40MHz": "550",
    "30MHz": "400",
    "20MHz": "250",
    "10MHz": "113",
    "20MHz_layer2": "125",
    "not_peak": "80",
    "no_data": "0",
    "low_traffic": "1",
}

TDD_UL_EXPECT_TPUT_TABLE = {
    "100MHz": "190",
    "90MHz": "170",
    "80MHz": "100",
    "70MHz": "90",
    "60MHz": "70",
    "50MHz": "55",
    "40MHz": "40",
    "30MHz": "30",
    "20MHz": "20",
    "10MHz": "10",
    "100MHz_layer1": "100",
    "90MHz_layer1": "90",
    "80MHz_layer1": "50",
    "60MHz_layer1": "36",
    "50MHz_layer1": "27",
    "40MHz_layer1": "20",
    "20MHz_layer1": "10",
    "10MHz_layer1": "5",
    "not_peak": "20",
    "no_data": "0",
}

FDD_DL_EXPECT_TPUT_TABLE = {
    "10MHz": "100",
    "15MHz": "145",
    "20MHz": "195",  # layer1   not peak,need to modify when testline is ok
    "30MHz": "250",
    "5MHz": "80",
    "10MHz_layer4": "190",
    "15MHz_layer4": "260",  # only layer2 for 080
    "20MHz_layer4": "400",  # only layer2 for 073
    "not_peak": "8",
    "no_data": "0",
}

FDD_UL_EXPECT_TPUT_TABLE = {
    "10MHz": "33",  # layer1   not peak,need to modify when testline is ok
    "15MHz": "60",  # layer1
    "20MHz": "75",  # layer1   not peak,need to modify when testline is ok
    "30MHz": "100",  # layer1
    "5MHz": "16",
    "10MHz_layer1": "33",
    "15MHz_layer1": "58",
    "20MHz_layer1": "75",  # layer1   not peak,need to modify when testline is ok
    "5MHz_layer1": "16",
    "not_peak": "10",
    "no_data": "0",
}

# Snapshot compare RU logs, white list
RU_LOGS_NOT_IN_SNAPSHOT_WHITE_LIST = [
    "swconfig.zip",
    "pm1_flash_logs_beamer.tar.gz",
    "pm1_flash_logs_dfe_part1.tar.gz",
    "pm1_flash_logs_dfe_part2.tar.gz",
    "pm2_flash_logs_beamer.tar.gz",
    "pm2_flash_logs_dfe_part1.tar.gz",
    "pm2_flash_logs_dfe_part2.tar.gz",
    "pm_1_syslog.zip",
    "pm_2_syslog.zip",
    "UnitOAM_SOAP_Log.zip",
    "MemoryConsumption_LastFourHours.csv",
    "MemoryConsumption_LastDay.csv",
    "MemoryConsumption_LastMonth.csv",
    "auth.zip",
    "faultLogs.zip",
    "l1low-bfweight.tar.gz",
    "swman_history.zip",
    "permanent.xml",
    "bip-reg-dumps.tar.gz",
    "l1lowRndParams.tar.gz",
    "rfsw-core-part0.tar.gz",
    "rfsw-core-part1.tar.gz",
    "rfsw-core-part2.tar.gz",
    "rfsw-core-part3.tar.gz",
    "rfsw-core-part4.tar.gz",
    "rfsw-core-part5.tar.gz",
    "rfsw-core-part6.tar.gz",
    "rfsw-core-part7.tar.gz",
    "rfsw-core-part8.tar.gz",
    "rfsw-core-part9.tar.gz",
    "socsw-logs.tar.gz",
    "base-pstore.tar.gz",
    "auth.tar.gz",
]

# Mode:tl_stream_ueIndex_ruIndex_paIndexInInit_paPort/value
T813_PA_VALUE_MAPPING = {
    0: {
        "0": {1: {"5": "10", "6": "10", "7": "10", "8": "10"}},
        "1": {1: {"9": "10", "10": "10", "11": "10", "12": "10"}},
        "2": {1: {"13": "10", "14": "10", "15": "10", "16": "10"}},
        "3": {0: {"1": "0", "2": "0"}},
        "4": {0: {"5": "15", "6": "15"}},
        "5": {0: {"13": "15", "14": "15"}},
        "6": {0: {"9": "0", "10": "0", "11": "0", "12": "0"}},
        "7": {1: {"1": "7", "2": "7", "3": "7", "4": "7"}},
        "8": {0: {"7": "3", "8": "3", "15": "3", "16": "3"}},
        # "7": {1: {"9": "0", "10": "0", "11": "0", "12": "0"}},
    },
    1: {
        "0": {1: {"5": "10", "6": "10", "7": "10", "8": "10"}},
        "1": {1: {"9": "10", "10": "10", "11": "10", "12": "10"}},
        "2": {1: {"13": "10", "14": "10", "15": "10", "16": "10"}},
        "3": {0: {"1": "0", "2": "0"}},
        "4": {0: {"5": "15", "6": "15"}},
        "5": {0: {"13": "15", "14": "15"}},
        "6": {0: {"9": "0", "10": "0", "11": "0", "12": "0"}},
        "7": {1: {"1": "7", "2": "7", "3": "7", "4": "7"}},
        "8": {0: {"7": "3", "8": "3", "15": "3", "16": "3"}},
        # "7": {1: {"9": "0", "10": "0", "11": "0", "12": "0"}},
    },
    2: {
        "0": {1: {"5": "10", "6": "10", "7": "10", "8": "10"}},
        "1": {1: {"9": "10", "10": "10", "11": "10", "12": "10"}},
        "2": {1: {"13": "10", "14": "10", "15": "10", "16": "10"}},
        "3": {0: {"1": "0", "2": "0"}},
        "4": {0: {"5": "15", "6": "15"}},
        "5": {0: {"13": "15", "14": "15"}},
        "6": {0: {"9": "0", "10": "0", "11": "0", "12": "0"}},
        "7": {1: {"1": "7", "2": "7", "3": "7", "4": "7"}},
        "8": {0: {"7": "3", "8": "3", "15": "3", "16": "3"}},
        # "7": {1: {"9": "0", "10": "0", "11": "0", "12": "0"}},
    },
}

# Mode:tl_stream_ueIndex_ruIndex_paIndexInInit_paPort/value
T073_PA_VALUE_MAPPING = {
    0: {
        "0": {0: {"1": "20", "2": "20", "3": "20", "4": "20"}},
        "3": {0: {"5": "0", "6": "0", "7": "0", "8": "0"}},
        "6": {0: {"9": "0", "10": "0", "11": "0", "12": "0"}},
        "7": {0: {"13": "0", "14": "0", "15": "0", "16": "0"}},
    },
    14: {
        "0": {0: {"1": "20", "2": "20", "3": "20", "4": "20"}},
        "3": {0: {"5": "0", "6": "0", "7": "0", "8": "0"}},
        "6": {0: {"9": "0", "10": "0", "11": "0", "12": "0"}},
        "7": {0: {"13": "0", "14": "0", "15": "0", "16": "0"}},
    },
}

# Mode:tl_stream_ueIndex_ruIndex_paIndexInInit_paPort/value
T080_PA_VALUE_MAPPING = {
    0: {
        "0": {1: {"11": "10", "12": "10", "13": "10", "14": "10"}},
        "1": {1: {"1": "9", "2": "9", "3": "9", "4": "9"}},
        "2": {2: {"1": "10", "2": "10", "3": "10", "4": "10"}},
        "3": {0: {"5": "15", "6": "15", "11": "15", "12": "15"}},
        "4": {1: {"5": "25", "6": "25", "15": "25", "16": "25"}},
        "5": {2: {"5": "15", "6": "15", "11": "15", "12": "15"}},
        "6": {0: {"7": "10", "8": "10", "9": "10", "10": "10"}},
        "7": {1: {"7": "25", "8": "25", "9": "25", "10": "25"}},
        "8": {2: {"7": "10", "8": "10", "9": "10", "10": "10"}},
    },
    1: {
        "0": {1: {"11": "10", "12": "10", "13": "10", "14": "10"}},
        "1": {1: {"1": "10", "2": "10", "3": "10", "4": "10"}},
        "2": {2: {"1": "10", "2": "10", "3": "10", "4": "10"}},
        "3": {0: {"5": "10", "6": "10", "11": "10", "12": "10"}},
        "4": {1: {"5": "10", "6": "10", "15": "10", "16": "10"}},
        "5": {2: {"5": "10", "6": "10", "11": "10", "12": "10"}},
        "6": {0: {"7": "10", "8": "10", "9": "10", "10": "10"}},
        "7": {1: {"7": "10", "8": "10", "9": "10", "10": "10"}},
        "8": {2: {"7": "10", "8": "10", "9": "10", "10": "10"}},
    },
    2: {
        "0": {1: {"11": "0", "12": "0", "13": "0", "14": "0"}},
        "1": {1: {"1": "8", "2": "8", "3": "8", "4": "8"}},
        "2": {2: {"1": "0", "2": "0", "3": "0", "4": "0"}},
        "3": {0: {"5": "10", "6": "10", "11": "10", "12": "10"}},
        "4": {1: {"5": "30", "6": "30", "15": "30", "16": "30"}},
        "5": {2: {"5": "10", "6": "10", "11": "10", "12": "10"}},
        "6": {0: {"7": "10", "8": "10", "9": "10", "10": "10"}},
        "7": {1: {"7": "10", "8": "10", "9": "10", "10": "10"}},
        "8": {2: {"7": "10", "8": "10", "9": "10", "10": "10"}},
    },
    3: {
        "0": {1: {"11": "0", "12": "0", "13": "0", "14": "0"}},
        "1": {1: {"1": "10", "2": "10", "3": "10", "4": "10"}},
        "2": {2: {"1": "10", "2": "10", "3": "10", "4": "10"}},
        "3": {0: {"5": "0", "6": "0", "11": "0", "12": "0"}},
        "4": {1: {"5": "10", "6": "10", "15": "10", "16": "10"}},
        "5": {2: {"5": "10", "6": "10", "11": "10", "12": "10"}},
        "6": {0: {"7": "10", "8": "10", "9": "10", "10": "10"}},
        "7": {1: {"7": "10", "8": "10", "9": "10", "10": "10"}},
        "8": {2: {"7": "10", "8": "10", "9": "10", "10": "10"}},
    },
    4: {
        "0": {1: {"11": "0", "12": "0", "13": "0", "14": "0"}},
        "1": {1: {"1": "0", "2": "0", "3": "0", "4": "0"}},
        "2": {2: {"1": "0", "2": "0", "3": "0", "4": "0"}},
        "3": {0: {"5": "0", "6": "0"}},
        "4": {1: {"5": "10", "6": "10"}},
        "5": {2: {"5": "10", "6": "10"}},
        "6": {0: {"7": "10", "8": "10", "9": "10", "10": "10"}},
        "7": {1: {"7": "10", "8": "10", "9": "10", "10": "10"}},
        "8": {2: {"7": "10", "8": "10", "9": "10", "10": "10"}},
    },
    6: {
        "0": {1: {"11": "10", "12": "10", "13": "10", "14": "10"}},
        "1": {1: {"1": "9", "2": "9", "3": "9", "4": "9"}},
        "2": {2: {"1": "10", "2": "10", "3": "10", "4": "10"}},
        "3": {0: {"5": "15", "6": "15", "11": "15", "12": "15"}},
        "4": {1: {"5": "25", "6": "25", "15": "25", "16": "25"}},
        "5": {2: {"5": "15", "6": "15", "11": "15", "12": "15"}},
        "6": {0: {"7": "10", "8": "10", "9": "10", "10": "10"}},
        "7": {1: {"7": "25", "8": "25", "9": "25", "10": "25"}},
        "8": {2: {"7": "10", "8": "10", "9": "10", "10": "10"}},
    },
    15: {
        "0": {1: {"11": "10", "12": "10", "13": "10", "14": "10"}},
        "1": {1: {"1": "9", "2": "9", "3": "9", "4": "9"}},
        "2": {2: {"1": "10", "2": "10", "3": "10", "4": "10"}},
        "3": {0: {"5": "15", "6": "15", "11": "15", "12": "15"}},
        "4": {1: {"5": "25", "6": "25", "15": "25", "16": "25"}},
        "5": {2: {"5": "15", "6": "15", "11": "15", "12": "15"}},
        "6": {0: {"7": "20", "8": "20", "9": "20", "10": "20"}},
        "7": {1: {"7": "25", "8": "25", "9": "25", "10": "25"}},
        "8": {2: {"7": "10", "8": "10", "9": "10", "10": "10"}},
    },
}

# Mode:tl_stream_ueIndex_ruIndex_paIndexInInit_paPort/value
T816_PA_VALUE_MAPPING = {
    0: {
        "0": {0: {"1": "15", "2": "15", "3": "15", "4": "15"}},
        "5": {0: {"5": "20", "6": "20", "7": "20", "8": "20"}},
        "2": {0: {"13": "20", "14": "20", "15": "20", "16": "20"}},
        "1": {0: {"9": "30", "10": "30", "11": "30", "12": "30"}},
        "6": {1: {"11": "20", "12": "20", "15": "20", "16": "20"}},
        "3": {1: {"9": "20", "10": "20"}},
        "7": {1: {"5": "30", "6": "30", "7": "30", "8": "30"}},
        "4": {1: {"13": "25", "14": "25"}},
    },
    1: {
        "0": {0: {"1": "15", "2": "15", "3": "15", "4": "15"}},
        "5": {0: {"5": "20", "6": "20", "7": "20", "8": "20"}},
        "2": {0: {"13": "20", "14": "20", "15": "20", "16": "20"}},
        "1": {0: {"9": "30", "10": "30", "11": "30", "12": "30"}},
        "6": {1: {"11": "20", "12": "20", "15": "20", "16": "20"}},
        "3": {1: {"9": "20", "10": "20"}},
        "7": {1: {"5": "30", "6": "30", "7": "30", "8": "30"}},
        "4": {1: {"13": "25", "14": "25"}},
    },
    2: {
        "0": {0: {"1": "15", "2": "15", "3": "15", "4": "15"}},
        "5": {0: {"5": "20", "6": "20", "7": "20", "8": "20"}},
        "2": {0: {"13": "20", "14": "20", "15": "20", "16": "20"}},
        "1": {0: {"9": "30", "10": "30", "11": "30", "12": "30"}},
        "6": {1: {"11": "20", "12": "20", "15": "20", "16": "20"}},
        "3": {1: {"9": "20", "10": "20"}},
        "7": {1: {"5": "30", "6": "30", "7": "30", "8": "30"}},
        "4": {1: {"13": "25", "14": "25"}},
    },
    3: {
        "0": {0: {"1": "15", "2": "15", "3": "15", "4": "15"}},
        "5": {0: {"5": "20", "6": "20", "7": "20", "8": "20"}},
        "2": {0: {"13": "20", "14": "20", "15": "20", "16": "20"}},
        "1": {0: {"9": "30", "10": "30", "11": "30", "12": "30"}},
        "6": {1: {"11": "20", "12": "20", "15": "20", "16": "20"}},
        "3": {1: {"9": "20", "10": "20"}},
        "7": {1: {"5": "30", "6": "30", "7": "30", "8": "30"}},
        "4": {1: {"13": "25", "14": "25"}},
    },
}

# Mode:tl_stream_ueIndex_ruIndex_paIndexInInit_paPort/value
T282_PA_VALUE_MAPPING = {
    0: {
        "0": {3: {"9": "10", "10": "10", "11": "10", "12": "10"}},
        "1": {3: {"5": "10", "6": "10", "7": "10", "8": "10"}},
        "2": {3: {"1": "0", "2": "0", "3": "0", "4": "0"}},
    },
    1: {
        "0": {3: {"9": "10", "10": "10", "11": "10", "12": "10"}},
        "1": {3: {"5": "10", "6": "10", "7": "10", "8": "10"}},
        "2": {3: {"1": "0", "2": "0", "3": "0", "4": "0"}},
    },
    2: {
        "0": {3: {"9": "10", "10": "10", "11": "10", "12": "10"}},
        "1": {3: {"5": "10", "6": "10", "7": "10", "8": "10"}},
        "2": {3: {"1": "0", "2": "0", "3": "0", "4": "0"}},
    },
}

# Mode:tl_stream_ueIndex_ruIndex_paIndexInInit_paPort/value
T283_PA_VALUE_MAPPING = {
    0: {
        "0": {0: {"1": "0", "2": "0", "3": "0", "4": "0"}},
        "1": {3: {"5": "0", "6": "0", "7": "0", "8": "0"}},
        "2": {0: {"5": "0", "6": "0", "7": "0", "8": "0"}},
        "3": {0: {"15": "15", "16": "15"}},
        "4": {0: {"13": "15", "14": "15"}},
        "5": {1: {"1": "15", "2": "15"}},
        "6": {0: {"9": "10", "10": "10", "11": "10", "12": "10"}},
        "7": {1: {"13": "10", "14": "10", "15": "10", "16": "10"}},
        "8": {1: {"9": "10", "10": "10", "11": "10", "12": "10"}},
        "9": {2: {"1": "10", "2": "10", "3": "10", "4": "10"}},
        "10": {3: {"13": "10", "14": "10", "15": "10", "16": "10"}},
        # '11': {2: {'1': '10', '2': '10', '3': '10', '4': '10'}},
    },
    1: {
        "0": {0: {"1": "0", "2": "0", "3": "0", "4": "0"}},
        # '1': {0: {'1': '0', '2': '0', '3': '0', '4': '0'}},
        # '2': {2: {'5': '0', '6': '0', '7': '0', '8': '0'}},
        "3": {0: {"15": "15", "16": "15"}},
        # '4': {1: {'1': '15', '2': '15'}},
        "5": {1: {"1": "15", "2": "15"}},
        "6": {0: {"9": "10", "10": "10", "11": "10", "12": "10"}},
        # '7': {1: {'13': '10', '14': '10', '15': '10', '16': '10'}},
        "8": {1: {"13": "10", "14": "10", "15": "10", "16": "10"}},
        # '9': {0: {'5': '10', '6': '10', '7': '10', '8': '10'}},
        # '10': {0: {'9': '10', '10': '10', '11': '10', '12': '10'}},
        # '11': {2: {'1': '10', '2': '10', '3': '10', '4': '10'}},
    },
    2: {
        "0": {0: {"1": "0", "2": "0", "3": "0", "4": "0"}},
        # '1': {0: {'1': '0', '2': '0', '3': '0', '4': '0'}},
        # '2': {2: {'5': '0', '6': '0', '7': '0', '8': '0'}},
        "3": {0: {"15": "15", "16": "15"}},
        # '4': {1: {'1': '15', '2': '15'}},
        "5": {1: {"1": "15", "2": "15"}},
        "6": {0: {"9": "10", "10": "10", "11": "10", "12": "10"}},
        # '7': {1: {'13': '10', '14': '10', '15': '10', '16': '10'}},
        "8": {1: {"13": "10", "14": "10", "15": "10", "16": "10"}},
        # '9': {0: {'5': '10', '6': '10', '7': '10', '8': '10'}},
        # '10': {0: {'9': '10', '10': '10', '11': '10', '12': '10'}},
        # '11': {2: {'1': '10', '2': '10', '3': '10', '4': '10'}},
    },
    7: {
        "0": {0: {"1": "0", "2": "0", "3": "0", "4": "0"}},
        "1": {3: {"5": "0", "6": "0", "7": "0", "8": "0"}},
        "2": {0: {"5": "0", "6": "0", "7": "0", "8": "0"}},
        "3": {0: {"15": "15", "16": "15"}},
        "4": {0: {"13": "15", "14": "15"}},
        "5": {1: {"1": "15", "2": "15"}},
        "6": {0: {"9": "10", "10": "10", "11": "10", "12": "10"}},
        "7": {1: {"13": "10", "14": "10", "15": "10", "16": "10"}},
        "8": {1: {"9": "10", "10": "10", "11": "10", "12": "10"}},
        "9": {2: {"1": "10", "2": "10", "3": "10", "4": "10"}},
        "10": {3: {"13": "10", "14": "10", "15": "10", "16": "10"}},
    },
}

# Mode:tl_stream_ueIndex_ruIndex_paIndexInInit_paPort/value
T819_PA_VALUE_MAPPING = {
    0: {
        "0": {0: {"1": "25", "2": "25", "3": "25", "4": "25"}},
        "1": {0: {"5": "25", "6": "25", "7": "25", "8": "25"}},
        "3": {0: {"9": "15", "10": "15", "11": "15", "12": "15"}},
        "4": {0: {"13": "15", "14": "15", "15": "15", "16": "15"}},
    },
}

# Mode:tl_stream_ueIndex_ruIndex_paIndexInInit_paPort/value
T284_PA_VALUE_MAPPING = {
    0: {
        "0": {0: {"9": "0", "10": "0", "11": "0", "12": "0"}},
        "1": {0: {"13": "20", "14": "20", "15": "20", "16": "20"}},
        "2": {0: {"7": "20", "8": "20"}},
    },
    1: {
        "0": {0: {"9": "0", "10": "0", "11": "0", "12": "0"}},
        "1": {0: {"13": "20", "14": "20", "15": "20", "16": "20"}},
        "2": {0: {"7": "20", "8": "20"}},
    },
    9: {
        "0": {0: {"9": "0", "10": "0", "11": "0", "12": "0"}},
        "1": {0: {"13": "20", "14": "20", "15": "20", "16": "20"}},
        "2": {0: {"7": "20", "8": "20"}},
        "7": {0: {"1": "5", "2": "5", "3": "5", "4": "5"}},
    },
}

CMAS_WARNING_AREA_LIST = {
    "warning_area_cgi_list_1cell": "0",
    "warning_area_cgi_list_2cells": "1",
    "warning_area_cgi_list_2cell": "2",
    "tai_warning_area_list": "3",
    "unknown_tai_warning_area_list": "4",
    "warning_area_emergency_list": "5",
    "unknown_warning_area_emergency_list": "6",
    "warnig_area_list_none": "7",
}

CASE_FOR_3CC_CHOOSED_UE = {
    "T813": 0,
    "T283": 0,
    "T073": 0,
    "T080": 4,
    "T284": 9,
    "T816": 3,
    "T819": 0,
}

Case_5603153_CHOOSED_UE = {
    "T813": 0,
    "T283": 7,
    "T073": 0,
    "T080": 4,
    "T284": 9,
}

GNB_INFO_MAPPING_TO_CASE_TABLE = {
    "5603018": {
        "T813": {"ca_technology": "TDD+TDD", "pcell_idx": 301, "attenuator": ["pa"]},
        "T073": {"ca_technology": "TDD+TDD", "pcell_idx": 301, "attenuator": ["pa"]},
        "T283": {"ca_technology": "TDD+TDD", "pcell_idx": 301, "attenuator": ["pa"]},
        "T080": {"ca_technology": "TDD+TDD", "pcell_idx": 302, "attenuator": ["pa"]},
    },
    "5603156": {
        "T813": {"ca_technology": "TDD+TDD", "pcell_idx": 301, "attenuator": ["pa"]},
        "T816": {"ca_technology": "TDD+TDD", "pcell_idx": 301, "attenuator": ["pa"]},
        "T819": {"ca_technology": "TDD+TDD", "pcell_idx": 301, "attenuator": ["pa"]},
        "T073": {"ca_technology": "TDD+TDD", "pcell_idx": 301, "attenuator": ["pa"]},
        "T283": {"ca_technology": "TDD+TDD", "pcell_idx": 301, "attenuator": ["pa"]},
        "T080": {"ca_technology": "TDD+TDD", "pcell_idx": 302, "attenuator": ["pa"]},
    },
    "5603159": {
        "T813": {"ca_technology": "TDD+TDD", "pcell_idx": 301, "attenuator": ["pa"]},
        "T816": {"ca_technology": "TDD+TDD", "pcell_idx": 301, "attenuator": ["pa"]},
        "T819": {"ca_technology": "TDD+TDD", "pcell_idx": 301, "attenuator": ["pa"]},
        "T073": {"ca_technology": "TDD+TDD", "pcell_idx": 301, "attenuator": ["pa"]},
        "T283": {"ca_technology": "TDD+TDD", "pcell_idx": 301, "attenuator": ["pa"]},
        "T080": {"ca_technology": "TDD+TDD", "pcell_idx": 302, "attenuator": ["pa"]},
    },
    "5603157": {
        "T813": {"ca_technology": "TDD+TDD", "pcell_idx": 301, "attenuator": ["pa"]},
        "T816": {"ca_technology": "TDD+TDD", "pcell_idx": 301, "attenuator": ["pa"]},
        "T819": {"ca_technology": "TDD+TDD", "pcell_idx": 301, "attenuator": ["pa"]},
        "T073": {"ca_technology": "TDD+TDD", "pcell_idx": 301, "attenuator": ["pa"]},
        "T283": {"ca_technology": "TDD+TDD", "pcell_idx": 301, "attenuator": ["pa"]},
        "T080": {"ca_technology": "TDD+TDD", "pcell_idx": 302, "attenuator": ["pa"]},
    },
    "5603158": {
        "T813": {"ca_technology": "TDD+TDD", "pcell_idx": 301, "attenuator": ["pa"]},
        "T816": {"ca_technology": "TDD+TDD", "pcell_idx": 301, "attenuator": ["pa"]},
        "T819": {"ca_technology": "TDD+TDD", "pcell_idx": 301, "attenuator": ["pa"]},
        "T073": {"ca_technology": "TDD+TDD", "pcell_idx": 301, "attenuator": ["pa"]},
        "T283": {"ca_technology": "TDD+TDD", "pcell_idx": 301, "attenuator": ["pa"]},
        "T080": {"ca_technology": "TDD+TDD", "pcell_idx": 302, "attenuator": ["pa"]},
    },
    "5603154": {
        "T813": {"ca_technology": "TDD+TDD", "pcell_idx": 301, "attenuator": ["pa"]},
        "T819": {"ca_technology": "TDD+TDD", "pcell_idx": 301, "attenuator": ["pa"]},
        "T282": {"ca_technology": "TDD+TDD", "pcell_idx": 301, "attenuator": ["pa"]},
        "T283": {"ca_technology": "TDD+TDD", "pcell_idx": 301, "attenuator": ["pa"]},
        "T284": {"ca_technology": "TDD+TDD", "pcell_idx": 301, "attenuator": ["pa"]},
    },
    "gNBSWUpgrade": {
        "T813": {"ca_technology": "TDD+TDD", "pcell_idx": 301, "attenuator": ["pa"]},
        "T073": {"ca_technology": "TDD+TDD", "pcell_idx": 301, "attenuator": ["pa"]},
        "T283": {"ca_technology": "TDD+TDD", "pcell_idx": 301, "attenuator": ["pa"]},
        "T080": {"ca_technology": "TDD+TDD", "pcell_idx": 302, "attenuator": ["pa"]},
    },
    "BWP": {
        "T813": {"ca_technology": "TDD+TDD", "pcell_idx": 301, "attenuator": ["pa"]},
        "T816": {"ca_technology": "TDD+FDD", "pcell_idx": 301, "attenuator": ["pa"]},
        "T819": {"ca_technology": "TDD+FDD", "pcell_idx": 301, "attenuator": ["pa"]},
        "T073": {"ca_technology": "TDD+TDD", "pcell_idx": 301, "attenuator": ["pa"]},
        "T284": {"ca_technology": "TDD+TDD", "pcell_idx": 301, "attenuator": ["pa"]},
        "T283": {"ca_technology": "TDD+TDD", "pcell_idx": 301, "attenuator": ["pa"]},
        "T080": {"ca_technology": "TDD+TDD", "pcell_idx": 312, "attenuator": ["pa"]},
    },
    "5603093": {
        "T073": {"ca_technology": "TDD+TDD", "pcell_idx": 301, "attenuator": ["pa"]},
    },
    "5603094": {
        "T073": {"ca_technology": "TDD+TDD", "pcell_idx": 301, "attenuator": ["pa"]},
    },
    "5603095": {
        "T073": {"ca_technology": "TDD+TDD", "pcell_idx": 301, "attenuator": ["pa"]},
    },
    "5603096": {
        "T073": {"ca_technology": "TDD+TDD", "pcell_idx": 301, "attenuator": ["pa"]},
    },
    "5603100": {
        "T813": {"ca_technology": "TDD+TDD", "pcell_idx": 301, "attenuator": ["pa"]},
        "T073": {"ca_technology": "TDD+TDD", "pcell_idx": 301, "attenuator": ["pa"]},
        "T283": {"ca_technology": "TDD+TDD", "pcell_idx": 301, "attenuator": ["pa"]},
        "T080": {"ca_technology": "TDD+TDD", "pcell_idx": 302, "attenuator": ["pa"]},
    },
    "5603001": {
        "T813": {"ca_technology": "TDD+FDD", "pcell_idx": 301, "attenuator": ["pa"]},
        "T080": {"ca_technology": "TDD+FDD", "pcell_idx": 302, "attenuator": ["pa"]},
        "T073": {"ca_technology": "TDD+FDD", "pcell_idx": 301, "attenuator": ["pa"]},
        "T283": {"ca_technology": "TDD+FDD", "pcell_idx": 301, "attenuator": ["pa"]},
    },
    "5603003": {
        "T813": {"ca_technology": "FDD+TDD", "pcell_idx": 21, "attenuator": ["pa"]},
        "T080": {"ca_technology": "FDD+TDD", "pcell_idx": 13, "attenuator": ["pa"]},
        "T073": {"ca_technology": "FDD+TDD", "pcell_idx": 21, "attenuator": ["pa"]},
        "T283": {"ca_technology": "FDD+TDD", "pcell_idx": 11, "attenuator": ["pa"]},
    },
    "5603002": {
        "T813": {"ca_technology": "FDD+TDD", "pcell_idx": 21, "attenuator": ["pa"]},
        "T080": {"ca_technology": "FDD+TDD", "pcell_idx": 13, "attenuator": ["pa"]},
        "T073": {"ca_technology": "FDD+TDD", "pcell_idx": 21, "attenuator": ["pa"]},
        "T283": {"ca_technology": "FDD+TDD", "pcell_idx": 11, "attenuator": ["pa"]},
    },
    "5603009": {
        "T813": {
            "ca_technology": "TDD+TDD",
            "pcell_idx": 301,
            "attenuator": ["pa"],
            "lte_cell_idx": 11,
            "nsa_pa_ru_idx": "6",
        },
        "T073": {
            "ca_technology": "TDD+TDD",
            "pcell_idx": 301,
            "attenuator": ["pa"],
            "lte_cell_idx": 11,
            "nsa_pa_ru_idx": "6",
        },
        "T283": {
            "ca_technology": "TDD+TDD",
            "pcell_idx": 301,
            "attenuator": ["pa"],
            "lte_cell_idx": 11,
            "nsa_pa_ru_idx": "7",
        },
        "T080": {
            "ca_technology": "TDD+TDD",
            "pcell_idx": 301,
            "attenuator": ["pa"],
            "lte_cell_idx": 31,
            "nsa_pa_ru_idx": "7",
        },
    },
    "5603008": {
        "T813": {"ca_technology": "TDD+TDD", "pcell_idx": 301, "attenuator": ["pa"]},
        "T073": {"ca_technology": "TDD+TDD", "pcell_idx": 301, "attenuator": ["pa"]},
        "T080": {"ca_technology": "TDD+TDD", "pcell_idx": 302, "attenuator": ["pa"]},
        "T283": {"ca_technology": "TDD+TDD", "pcell_idx": 301, "attenuator": ["pa"]},
    },
    "5603071": {
        "T813": {"ca_technology": "TDD+TDD", "pcell_idx": 301, "attenuator": ["pa"]},
        "T073": {"ca_technology": "TDD+TDD", "pcell_idx": 301, "attenuator": ["pa"]},
        "T283": {"ca_technology": "TDD+TDD", "pcell_idx": 301, "attenuator": ["pa"]},
        "T080": {"ca_technology": "TDD+TDD", "pcell_idx": 301, "attenuator": ["pa"]},
    },
    "5603039": {
        "T813": {"ca_technology": "TDD+TDD", "pcell_idx": 301, "attenuator": ["pa"]},
        "T073": {"ca_technology": "TDD+TDD", "pcell_idx": 301, "attenuator": ["pa"]},
        "T283": {"ca_technology": "TDD+TDD", "pcell_idx": 301, "attenuator": ["pa"]},
    },
    "5603038": {
        "T813": {"ca_technology": "TDD+TDD", "pcell_idx": 301, "attenuator": ["pa"]},
        "T073": {"ca_technology": "TDD+TDD", "pcell_idx": 301, "attenuator": ["pa"]},
        "T283": {"ca_technology": "TDD+TDD", "pcell_idx": 301, "attenuator": ["pa"]},
    },
    "5603013": {
        "T813": {"ca_technology": "TDD+TDD", "pcell_idx": 301, "attenuator": ["pa"]},
        "T073": {"ca_technology": "TDD+TDD", "pcell_idx": 301, "attenuator": ["pa"]},
        "T283": {"ca_technology": "TDD+TDD", "pcell_idx": 301, "attenuator": ["pa"]},
    },
    "5603057": {
        "T813": {"ca_technology": "TDD+TDD", "pcell_idx": 301, "attenuator": ["pa"]},
        "T073": {"ca_technology": "TDD+TDD", "pcell_idx": 301, "attenuator": ["pa"]},
        "T283": {"ca_technology": "TDD+TDD", "pcell_idx": 301, "attenuator": ["pa"]},
    },
    "5603041": {
        "T813": {"ca_technology": "TDD+TDD", "pcell_idx": 311, "attenuator": ["pa"]},
        "T073": {"ca_technology": "TDD+TDD", "pcell_idx": 401, "attenuator": ["pa"]},
        "T283": {"ca_technology": "TDD+TDD", "pcell_idx": 401, "attenuator": ["pa"]},
        "T080": {"ca_technology": "TDD+TDD", "pcell_idx": 403, "attenuator": ["pa"]},
    },
    "5603022": {
        "T813": {
            "ca_technology": "TDD+TDD",
            "pcell_idx": 311,
            "attenuator": ["pa"],
            "lte_cell_idx": 11,
            "nsa_pa_ru_idx": "6",
        },
        "T073": {
            "ca_technology": "TDD+TDD",
            "pcell_idx": 401,
            "attenuator": ["pa"],
            "lte_cell_idx": 11,
            "nsa_pa_ru_idx": "6",
        },
        "T283": {
            "ca_technology": "TDD+TDD",
            "pcell_idx": 401,
            "attenuator": ["pa"],
            "lte_cell_idx": 11,
            "nsa_pa_ru_idx": "7",
        },
    },
    "5603052": {
        "T813": {"ca_technology": "TDD+FDD", "pcell_idx": 301, "attenuator": ["pa"]},
        "T080": {"ca_technology": "TDD+TDD", "pcell_idx": 303, "attenuator": ["pa"]},
        "T073": {"ca_technology": "TDD+TDD", "pcell_idx": 301, "attenuator": ["pa"]},
        "T283": {"ca_technology": "TDD+TDD", "pcell_idx": 301, "attenuator": ["pa"]},
        "T284": {"ca_technology": "TDD+TDD", "pcell_idx": 301, "attenuator": ["pa"]},
    },
    "5603014": {
        "T813": {
            "ca_technology": "TDD+TDD",
            "pcell_idx": 301,
            "after_ho_pcell_idx": 1,
            "attenuator": ["pa"],
        },
        "T080": {
            "ca_technology": "TDD+TDD",
            "pcell_idx": 301,
            "after_ho_pcell_idx": 12,
            "attenuator": ["pa"],
        },
        "T073": {
            "ca_technology": "TDD+TDD",
            "pcell_idx": 301,
            "after_ho_pcell_idx": 11,
            "attenuator": ["pa"],
        },
        "T283": {
            "ca_technology": "TDD+TDD",
            "pcell_idx": 301,
            "after_ho_pcell_idx": 11,
            "attenuator": ["pa"],
        },
    },
    "5603084": {
        "T813": {
            "ca_technology": "TDD+TDD",
            "pcell_idx": 301,
            "after_ho_pcell_idx": 302,
            "attenuator": ["pa"],
            "ho_ca_technology": "TDD+TDD",
        },
        "T080": {
            "ca_technology": "TDD+TDD",
            "pcell_idx": 301,
            "after_ho_pcell_idx": 302,
            "attenuator": ["pa"],
            "ho_ca_technology": "TDD+TDD",
        },
    },
    "5603090": {
        "T813": {
            "ca_technology": "TDD+TDD",
            "pcell_idx": 301,
            "after_ho_pcell_idx": 1,
            "attenuator": ["pa"],
            "ho_ca_technology": "FDD+TDD",
        },
        "T073": {
            "ca_technology": "TDD+TDD",
            "pcell_idx": 301,
            "after_ho_pcell_idx": 1,
            "attenuator": ["pa", "mcs"],
            "ho_ca_technology": "FDD+TDD",
        },
        "T080": {
            "ca_technology": "TDD+TDD",
            "pcell_idx": 302,
            "after_ho_pcell_idx": 11,
            "attenuator": ["pa"],
            "ho_ca_technology": "FDD+TDD",
        },
        "T816": {
            "ca_technology": "TDD+TDD",
            "pcell_idx": 301,
            "after_ho_pcell_idx": 1,
            "attenuator": ["pa"],
            "ho_ca_technology": "FDD+TDD",
        },
    },
    "5603088": {
        "T813": {
            "ca_technology": "TDD+TDD",
            "pcell_idx": 301,
            "lte_cell_idx": 11,
            "attenuator": ["pa"],
            "ho_ca_technology": "TDD+TDD",
        },
        "T073": {
            "ca_technology": "TDD+TDD",
            "pcell_idx": 301,
            "after_ho_pcell_idx": 11,
            "attenuator": ["pa", "mcs"],
            "ho_ca_technology": "FDD+TDD",
        },
    },
    "5603085": {
        "T813": {
            "ca_technology": "TDD+TDD",
            "pcell_idx": 301,
            "after_ho_pcell_idx": 302,
            "attenuator": ["pa"],
            "ho_ca_technology": "TDD+TDD",
            "lte_cell_idx": 11,
            "nsa_pa_ru_idx": "6",
        },
    },
    "5603082": {
        "T813": {
            "ca_technology": "TDD+TDD",
            "pcell_idx": 301,
            "after_ho_pcell_idx": 1,
            "attenuator": ["pa"],
            "ho_ca_technology": "FDD+TDD",
            "lte_cell_idx": 11,
            "nsa_pa_ru_idx": "6",
        },
    },
    "5603016": {
        "T813": {
            "ca_technology": "FDD+TDD",
            "pcell_idx": 1,
            "ho_ca_technology": "TDD+TDD",
            "attenuator": ["pa"],
        },
        "T080": {
            "ca_technology": "FDD+TDD",
            "pcell_idx": 12,
            "ho_ca_technology": "TDD+TDD",
            "attenuator": ["pa"],
        },
        "T073": {
            "ca_technology": "FDD+TDD",
            "pcell_idx": 11,
            "ho_ca_technology": "TDD+TDD",
            "attenuator": ["pa"],
        },
        "T283": {
            "ca_technology": "FDD+TDD",
            "pcell_idx": 11,
            "ho_ca_technology": "TDD+TDD",
            "attenuator": ["pa"],
        },
    },
    "5603017": {
        "T813": {
            "ca_technology": "TDD+FDD",
            "pcell_idx": 301,
            "ho_ca_technology": "FDD+TDD",
            "attenuator": ["pa"],
        },
        "T073": {
            "ca_technology": "TDD+FDD",
            "pcell_idx": 301,
            "ho_ca_technology": "FDD+TDD",
            "attenuator": ["pa"],
        },
        "T080": {
            "ca_technology": "TDD+FDD",
            "pcell_idx": 301,
            "ho_ca_technology": "FDD+TDD",
            "attenuator": ["pa"],
        },
        "T283": {
            "ca_technology": "TDD+FDD",
            "pcell_idx": 301,
            "ho_ca_technology": "FDD+TDD",
            "attenuator": ["pa"],
        },
    },
    "5603033": {
        "T813": {
            "ca_technology": "TDD+TDD",
            "pcell_idx": 301,
            "attenuator": ["pa"],
            "lte_cell_idx": 11,
            "nsa_pa_ru_idx": "6",
        },
        "T073": {
            "ca_technology": "TDD+TDD",
            "pcell_idx": 301,
            "attenuator": ["pa"],
            "lte_cell_idx": 11,
            "nsa_pa_ru_idx": "6",
        },
        "T283": {
            "ca_technology": "TDD+TDD",
            "pcell_idx": 301,
            "attenuator": ["pa"],
            "lte_cell_idx": 11,
            "nsa_pa_ru_idx": "7",
        },
        "T080": {
            "ca_technology": "TDD+TDD",
            "pcell_idx": 302,
            "attenuator": ["pa"],
            "lte_cell_idx": 12,
            "nsa_pa_ru_idx": "7",
        },
    },
    "5603015": {
        "T813": {
            "ca_technology": "TDD+TDD",
            "pcell_idx": 301,
            "attenuator": ["pa"],
            "lte_cell_idx": 11,
            "nsa_pa_ru_idx": "6",
        },
        "T073": {
            "ca_technology": "TDD+TDD",
            "pcell_idx": 301,
            "attenuator": ["pa"],
            "lte_cell_idx": 11,
            "nsa_pa_ru_idx": "6",
        },
        "T283": {
            "ca_technology": "TDD+TDD",
            "pcell_idx": 301,
            "attenuator": ["pa"],
            "lte_cell_idx": 11,
            "nsa_pa_ru_idx": "7",
        },
    },
    "5603010": {
        "T813": {
            "ca_technology": "FDD+TDD",
            "pcell_idx": 1,
            "attenuator": ["pa"],
            "lte_cell_idx": 11,
            "nsa_pa_ru_idx": "6",
        },
        "T073": {
            "ca_technology": "FDD+TDD",
            "pcell_idx": 11,
            "attenuator": ["pa"],
            "lte_cell_idx": 11,
            "nsa_pa_ru_idx": "6",
        },
        "T283": {
            "ca_technology": "FDD+TDD",
            "pcell_idx": 11,
            "attenuator": ["pa"],
            "lte_cell_idx": 12,
            "nsa_pa_ru_idx": "7",
        },
        "T080": {
            "ca_technology": "FDD+TDD",
            "pcell_idx": 301,
            "lte_cell_idx": 31,
            "nsa_pa_ru_idx": "7",
            "attenuator": ["pa"],
        },
    },
    "5603029": {
        "T813": {"pcell_idx": 301, "attenuator": ["pa"]},
        "T080": {"pcell_idx": 301, "attenuator": ["pa"]},
        "T073": {"pcell_idx": 301, "attenuator": ["pa"]},
        "T283": {"pcell_idx": 301, "attenuator": ["pa"]},
    },
    "5603005": {
        "T813": {"ca_technology": "TDD+TDD", "pcell_idx": 301, "attenuator": ["pa"]},
        "T073": {"ca_technology": "TDD+TDD", "pcell_idx": 301, "attenuator": ["pa"]},
        "T283": {"ca_technology": "TDD+TDD", "pcell_idx": 301, "attenuator": ["pa"]},
        "T080": {
            "ca_technology": "TDD+TDD",
            "pcell_idx": 302,
            "attenuator": ["pa"],
            "UEs_info": {
                2: {
                    "ca_technology": "TDD+TDD",
                    "pcell_idx": 302,
                    "attenuator": ["pa"],
                }
            },
        },
    },
    "5603086": {
        "T073": {"pcell_idx": 301, "attenuator": ["pa"]},
        "T816": {"pcell_idx": 301, "attenuator": ["pa"]},
        "T813": {"pcell_idx": 301, "attenuator": ["pa"]},
    },
    "5603007": {
        "T073": {"pcell_idx": 301, "attenuator": ["pa"]},
        "T816": {"pcell_idx": 301, "attenuator": ["pa"]},
    },
    "5603046": {
        "T073": {
            "ca_technology": "TDD+TDD",
            "pcell_idx": 303,
            "attenuator": ["pa"],
            "lte_cell_idx": 133,
            "5G_fiber_switch_channel": [0, 1, 2, 3, 4, 5, 6, 7],
            "4G_fiber_switch_channel": [0, 1, 2, 3, 4, 5, 6, 7],
            "OPT1_fiber_switch_channel": [0, 1],
            "OPT2_fiber_switch_channel": [2, 3],
            "OPT3_fiber_switch_channel": [4, 5],
            "OPT4_fiber_switch_channel": [6, 7],
        },
        "T816": {
            "pcell_idx": 301,
            "ca_technology": "TDD+TDD",
            "attenuator": ["pa"],
            "5G_fiber_switch_channel": [0, 1],
            "4G_fiber_switch_channel": [2, 3],
            "OPT1_fiber_switch_channel": [2, 3],
            "OPT2_fiber_switch_channel": [0, 1],
        },
    },
    "5603047": {
        "T073": {
            "ca_technology": "TDD+TDD",
            "pcell_idx": 303,
            "attenuator": ["pa"],
            "lte_cell_idx": 133,
            "5G_fiber_switch_channel": [4, 5],
            "4G_fiber_switch_channel": [0, 1, 2, 3],
        },
        "T816": {
            "pcell_idx": 301,
            "ca_technology": "TDD+TDD",
            "attenuator": ["pa"],
            "5G_fiber_switch_channel": [0, 1],
            "4G_fiber_switch_channel": [2, 3],
        },
    },
    "5605003": {
        "T073": {
            "pcell_idx": 302,
            "scell_idx_list": [2, 22, 312],
            "swap_scell_index": {"source_scell": 22, "target_scell": 21},
            "attenuator": ["pa"],
        },
        "T080": {
            "pcell_idx": 301,
            "scell_idx_list": [1, 21, 311],
            "swap_scell_index": {"source_scell": 21, "target_scell": 22},
            "attenuator": ["pa"],
        },
        "T816": {
            "pcell_idx": 301,
            "scell_idx_list": [1, 21, 311],
            "swap_scell_index": {"source_scell": 21, "target_scell": 23},
            "attenuator": ["pa"],
        },
        "T283": {
            "pcell_idx": 351,
            "scell_idx_list": [1, 21, 361],
            "swap_scell_index": {"source_scell": 21, "target_scell": 22},
            "attenuator": ["pa"],
        },
        "T813": {
            "pcell_idx": 301,
            "scell_idx_list": [1, 21, 311],
            "swap_scell_index": {"source_scell": 21, "target_scell": 22},
            "attenuator": ["pa"],
        },
    },
    "CB007163": {
        "T816": {
            "pcell_idx": 301,
            "scell_idx_list": [1, 21, 311],
            "swap_scell_index": {"source_scell": 21, "target_scell": 23},
            "attenuator": ["pa"],
        },
    },
    "CB007035": {
        "T816": {
            "pcell_idx": 301,
            "scell_idx_list": [1, 21, 311],
            "swap_scell_index": {"source_scell": 21, "target_scell": 23},
            "attenuator": ["pa"],
        },
    },
    "CB007334": {
        "T816": {
            "pcell_idx": 301,
            "scell_idx_list": [1, 21, 311],
            "swap_scell_index": {"source_scell": 21, "target_scell": 23},
            "attenuator": ["pa"],
        },
    },
    "CNI_145514": {
        "T816": {
            "pcell_idx": 301,
            "scell_idx_list": [1, 21, 311],
            "swap_scell_index": {"source_scell": 21, "target_scell": 23},
            "attenuator": ["pa"],
        },
    },
    "CB012474": {
        "T816": {
            "pcell_idx": 301,
            "scell_idx_list": [1, 21, 311],
            "swap_scell_index": {"source_scell": 21, "target_scell": 23},
            "attenuator": ["pa"],
        },
        "T813": {
            "pcell_idx": 301,
            "scell_idx_list": [1, 21, 311],
            "swap_scell_index": {"source_scell": 21, "target_scell": 23},
            "attenuator": ["pa"],
        },
    },
    "5605004": {
        "T073": {
            "pcell_idx": 301,
            "scell_idx_list": [1, 21, 311],
            "inter_gnb_ho_cell": 301,
            "attenuator": ["pa"],
        },
        "T080": {
            "pcell_idx": 301,
            "scell_idx_list": [1, 21, 311],
            "inter_gnb_ho_cell": 301,
            "attenuator": ["pa"],
        },
    },
    "EDA05437018": {
        "T813": {
            "pcell_idx": 1,
            "scell_idx_list": [301],
            "attenuator": ["pa"],
        },
    },
    "5603054": {
        "T813": {"pcell_idx": 1, "scell_idx_list": [301, 311], "attenuator": ["pa"]},
        "T073": {"pcell_idx": 11, "scell_idx_list": [301, 311], "attenuator": ["pa"]},
        "T283": {"pcell_idx": 11, "scell_idx_list": [301, 311], "attenuator": ["pa"]},
        "T080": {"pcell_idx": 2, "scell_idx_list": [302, 312], "attenuator": ["pa"]},
    },
    "5603108": {
        "T283": {
            "pcell_idx": 301,
            "scell_idx_list": [1, 21, 41, 351, 11],
            "attenuator": ["pa"],
        },
        "T813": {
            "pcell_idx": 301,
            "scell_idx_list": [1, 311],
            "attenuator": ["pa"],
        },
        "T073": {
            "pcell_idx": 301,
            "scell_idx_list": [1, 21, 311, 11, 41],
            "attenuator": ["pa"],
        },
        "T819": {
            "pcell_idx": 301,
            "scell_idx_list": [21, 311],
            "attenuator": ["pa"],
        },
        "T080": {
            "pcell_idx": 302,
            "scell_idx_list": [2, 22, 312],
            "attenuator": ["pa"],
            "scell_ul_idx": "2",
        },
    },
    "5603160": {
        "T816": {
            "ca_technology": "TDD+TDD",
            "pcell_idx": 301,
            "attenuator": ["pa"],
        },
    },
    "5603153": {
        "T283": {"pcell_idx": 301, "scell_idx_list": [1, 21], "attenuator": ["pa"]},
        "T813": {
            "pcell_idx": 301,
            "scell_idx_list": [1],
            "attenuator": ["pa"],
            "scell_ul_idx": "1",
        },
        "T073": {
            "pcell_idx": 301,
            "scell_idx_list": [1, 21, 311],
            "attenuator": ["pa"],
        },
        "T080": {
            "pcell_idx": 302,
            "scell_idx_list": [2, 312],
            "attenuator": ["pa"],
            "scell_ul_idx": "2",
        },
    },
    "5603109": {
        "T283": {"pcell_idx": 1, "scell_idx_list": [21, 301], "attenuator": ["pa"]},
        "T813": {
            "pcell_idx": 1,
            "scell_idx_list": [21, 301],
            "attenuator": ["pa"],
            "scell_ul_idx": "301",
        },
        "T073": {
            "pcell_idx": 1,
            "scell_idx_list": [21, 301, 311, 11, 41],
            "attenuator": ["pa"],
        },
        "T080": {
            "pcell_idx": 2,
            "scell_idx_list": [22, 302, 312],
            "attenuator": ["pa"],
            "scell_ul_idx": "302",
        },
    },
    "5603110": {
        "T283": {"pcell_idx": 21, "scell_idx_list": [1, 301], "attenuator": ["pa"]},
        "T813": {
            "pcell_idx": 21,
            "scell_idx_list": [1, 301],
            "attenuator": ["pa"],
            "scell_ul_idx": "301",
        },
        "T073": {
            "pcell_idx": 11,
            "scell_idx_list": [1, 301, 311, 21, 41],
            "attenuator": ["pa"],
        },
        "T080": {
            "pcell_idx": 22,
            "scell_idx_list": [2, 302, 312],
            "attenuator": ["pa"],
            "scell_ul_idx": "302",
        },
    },
    "5603053": {
        "T813": {"pcell_idx": 301, "scell_idx_list": [1, 311], "attenuator": ["pa"]},
        "T073": {"pcell_idx": 301, "scell_idx_list": [11, 311], "attenuator": ["pa"]},
        "T283": {"pcell_idx": 301, "scell_idx_list": [11, 401], "attenuator": ["pa"]},
        "T080": {"pcell_idx": 302, "scell_idx_list": [2, 312], "attenuator": ["pa"]},
    },
    "5603032": {
        "T813": {
            "pcell_idx": 301,
            "scell_idx_list": [311, 1],
            "attenuator": ["pa"],
            "UEs_info": {
                1: {
                    "ca_technology": "TDD+TDD",
                    "pcell_idx": 131,
                    "attenuator": ["pa"],
                }
            },
        },
        "T080": {
            "pcell_idx": 303,
            "scell_idx_list": [403],
            "attenuator": ["pa"],
            "UEs_info": {
                0: {
                    "ca_technology": "FDD+TDD",
                    "pcell_idx": 13,
                    "attenuator": ["pa"],
                }
            },
        },
        "T073": {
            "pcell_idx": 301,
            "scell_idx_list": [311, 11],
            "attenuator": ["pa"],
            "UEs_info": {
                1: {
                    "ca_technology": "TDD+TDD",
                    "pcell_idx": 131,
                }
            },
        },
    },
    "5603012": {
        "T813": {
            "ca_technology": "TDD+FDD",
            "pcell_idx": 301,
            "scell_idx_list": [1],
            "attenuator": ["pa"],
            "UEs_info": {
                1: {
                    "ca_technology": "FDD+TDD",
                    "pcell_idx": 1,
                    "attenuator": ["pa"],
                }
            },
        },
        "T073": {
            "ca_technology": "TDD+FDD",
            "pcell_idx": 301,
            "attenuator": ["pa"],
            "UEs_info": {
                1: {
                    "ca_technology": "FDD+TDD",
                    "pcell_idx": 1,
                    "attenuator": ["pa"],
                }
            },
        },
        "T283": {
            "ca_technology": "TDD+FDD",
            "pcell_idx": 301,
            "attenuator": ["pa"],
            "UEs_info": {
                1: {
                    "ca_technology": "FDD+TDD",
                    "pcell_idx": 11,
                    "attenuator": ["pa"],
                }
            },
        },
    },
    "5603070": {
        "T813": {
            "ca_technology": "TDD+TDD",
            "pcell_idx": 301,
            "attenuator": ["pa"],
            "UEs_info": {
                1: {
                    "ca_technology": "FDD+FDD",
                    "pcell_idx": 1,
                    "attenuator": ["pa"],
                }
            },
        },
        "T816": {
            "ca_technology": "TDD+TDD",
            "pcell_idx": 301,
            "attenuator": ["pa"],
            "UEs_info": {
                2: {
                    "ca_technology": "FDD+FDD",
                    "pcell_idx": 1,
                    "attenuator": ["pa"],
                }
            },
        },
        "T073": {
            "ca_technology": "TDD+TDD",
            "pcell_idx": 301,
            "attenuator": ["pa"],
            "UEs_info": {
                14: {
                    "ca_technology": "FDD+FDD",
                    "pcell_idx": 1,
                    "attenuator": ["pa"],
                }
            },
        },
        "T283": {
            "ca_technology": "TDD+TDD",
            "pcell_idx": 301,
            "attenuator": ["pa"],
            "UEs_info": {
                1: {
                    "ca_technology": "FDD+FDD",
                    "pcell_idx": 1,
                    "attenuator": ["pa"],
                }
            },
        },
    },
    "5603011": {
        "T813": {
            "ca_technology": "TDD+TDD",
            "pcell_idx": 301,
            "attenuator": ["pa"],
            "UEs_info": {
                1: {
                    "ca_technology": "FDD+TDD",
                    "pcell_idx": 1,
                    "attenuator": ["pa"],
                }
            },
        },
        "T816": {
            "ca_technology": "TDD+TDD",
            "pcell_idx": 301,
            "attenuator": ["pa"],
            "UEs_info": {
                2: {
                    "ca_technology": "FDD+TDD",
                    "pcell_idx": 1,
                    "attenuator": ["pa"],
                }
            },
        },
        "T073": {
            "ca_technology": "TDD+TDD",
            "pcell_idx": 301,
            "attenuator": ["pa"],
            "UEs_info": {
                14: {
                    "ca_technology": "FDD+TDD",
                    "pcell_idx": 1,
                    "attenuator": ["pa"],
                }
            },
        },
        "T283": {
            "ca_technology": "TDD+TDD",
            "pcell_idx": 301,
            "attenuator": ["pa"],
            "UEs_info": {
                1: {
                    "ca_technology": "FDD+TDD",
                    "pcell_idx": 1,
                    "attenuator": ["pa"],
                }
            },
        },
        "T080": {
            "ca_technology": "FDD+TDD",
            "pcell_idx": 1,
            "attenuator": ["pa"],
            "UEs_info": {
                3: {
                    "ca_technology": "TDD+TDD",
                    "pcell_idx": 301,
                    "attenuator": ["pa"],
                }
            },
        },
    },
    "5603028": {
        "T813": {
            "ca_technology": "TDD+TDD",
            "pcell_idx": 301,
            "attenuator": ["pa"],
            "UEs_info": {
                1: {
                    "ca_technology": "TDD+TDD",
                    "pcell_idx": 131,
                    "attenuator": ["pa"],
                }
            },
        },
        "T073": {
            "ca_technology": "TDD+TDD",
            "pcell_idx": 301,
            "attenuator": ["pa"],
            "UEs_info": {
                1: {
                    "ca_technology": "TDD+TDD",
                    "pcell_idx": 131,
                    "attenuator": ["pa"],
                }
            },
        },
        "T080": {
            "ca_technology": "TDD+TDD",
            "pcell_idx": 302,
            "attenuator": ["pa"],
            "UEs_info": {
                0: {
                    "ca_technology": "FDD+TDD",
                    "pcell_idx": 2,
                    "attenuator": ["pa"],
                }
            },
        },
        "T283": {
            "ca_technology": "TDD+TDD",
            "pcell_idx": 301,
            "attenuator": ["pa"],
            "UEs_info": {
                1: {
                    "ca_technology": "TDD+TDD",
                    "pcell_idx": 132,
                    "attenuator": ["pa"],
                }
            },
        },
    },
    "5603080": {
        "T813": {
            "ca_technology": "TDD+TDD",
            "pcell_idx": 301,
            "attenuator": ["pa"],
            "lte_cell_idx": 11,
            "nsa_pa_ru_idx": "6",
            "UEs_info": {
                1: {
                    "ca_technology": "TDD+TDD",
                    "pcell_idx": 131,
                    "attenuator": ["pa"],
                }
            },
        },
        "T073": {
            "ca_technology": "TDD+TDD",
            "pcell_idx": 301,
            "attenuator": ["pa"],
            "lte_cell_idx": 11,
            "nsa_pa_ru_idx": "4",
            "UEs_info": {
                1: {
                    "ca_technology": "TDD+TDD",
                    "pcell_idx": 131,
                    "attenuator": ["pa"],
                }
            },
        },
        "T080": {
            "ca_technology": "TDD+TDD",
            "pcell_idx": 303,
            "attenuator": ["pa"],
            "lte_cell_idx": 13,
            "nsa_pa_ru_idx": "4",
            "UEs_info": {
                0: {
                    "ca_technology": "FDD+TDD",
                    "pcell_idx": 13,
                    "attenuator": ["pa"],
                }
            },
        },
        "T283": {
            "ca_technology": "TDD+TDD",
            "pcell_idx": 301,
            "attenuator": ["pa"],
            "lte_cell_idx": 11,
            "nsa_pa_ru_idx": "7",
            "UEs_info": {
                1: {
                    "ca_technology": "TDD+TDD",
                    "pcell_idx": 132,
                    "attenuator": ["pa"],
                }
            },
        },
    },
    "5603019": {
        "T813": {
            "ca_technology": "TDD+TDD",
            "pcell_idx": 301,
            "attenuator": ["pa"],
            "UEs_info": {
                1: {
                    "ca_technology": "TDD+TDD",
                    "pcell_idx": 131,
                    "attenuator": ["pa"],
                }
            },
        },
        "T073": {
            "ca_technology": "TDD+TDD",
            "pcell_idx": 301,
            "attenuator": ["pa"],
            "UEs_info": {
                1: {
                    "ca_technology": "TDD+TDD",
                    "pcell_idx": 131,
                    "attenuator": ["pa"],
                }
            },
        },
        "T080": {
            "ca_technology": "TDD+TDD",
            "pcell_idx": 302,
            "attenuator": ["pa"],
            "UEs_info": {
                0: {
                    "ca_technology": "FDD+TDD",
                    "pcell_idx": 2,
                    "attenuator": ["pa"],
                }
            },
        },
        "T283": {
            "ca_technology": "TDD+TDD",
            "pcell_idx": 301,
            "attenuator": ["pa"],
            "UEs_info": {
                1: {
                    "ca_technology": "TDD+TDD",
                    "pcell_idx": 132,
                    "attenuator": ["pa"],
                }
            },
        },
    },
    "5603083": {
        "T813": {
            "ca_technology": "FDD+TDD",
            "pcell_idx": 21,
            "attenuator": ["pa"],
            "lte_cell_idx": 11,
            "nsa_pa_ru_idx": "6",
            "UEs_info": {
                2: {
                    "ca_technology": "TDD+TDD",
                    "pcell_idx": 301,
                    "attenuator": ["pa"],
                },
                3: {
                    "ca_technology": "TDD+TDD",
                    "pcell_idx": 301,
                    "attenuator": ["pa"],
                },
            },
        },
        "T073": {
            "ca_technology": "TDD+TDD",
            "pcell_idx": 301,
            "attenuator": ["pa"],
            "UEs_info": {
                1: {
                    "ca_technology": "TDD+TDD",
                    "pcell_idx": 131,
                    "attenuator": ["pa"],
                }
            },
        },
        "T283": {
            "ca_technology": "FDD+TDD",
            "pcell_idx": 11,
            "attenuator": ["pa"],
            "lte_cell_idx": 11,
            "nsa_pa_ru_idx": "7",
            "UEs_info": {
                1: {
                    "ca_technology": "TDD+TDD",
                    "pcell_idx": 132,
                    "attenuator": ["pa"],
                },
                2: {
                    "ca_technology": "TDD+TDD",
                    "pcell_idx": 301,
                    "attenuator": ["pa"],
                },
            },
        },
    },
    "5603078": {
        "T813": {
            "ca_technology": "TDD+TDD",
            "pcell_idx": 311,
            "attenuator": ["pa"],
            "lte_cell_idx": 11,
            "nsa_pa_ru_idx": "6",
            "UEs_info": {
                1: {
                    "ca_technology": "TDD+TDD",
                    "pcell_idx": 131,
                    "attenuator": ["pa"],
                },
                2: {
                    "ca_technology": "TDD+TDD",
                    "pcell_idx": 301,
                    "attenuator": ["pa"],
                },
                3: {
                    "ca_technology": "TDD+TDD",
                    "pcell_idx": 141,
                    "attenuator": ["pa"],
                },
            },
        },
        "T073": {
            "ca_technology": "TDD+TDD",
            "pcell_idx": 401,
            "attenuator": ["pa"],
            "UEs_info": {
                1: {
                    "ca_technology": "TDD+TDD",
                    "pcell_idx": 131,
                    "attenuator": ["pa"],
                },
                2: {
                    "ca_technology": "TDD+TDD",
                    "pcell_idx": 301,
                    "attenuator": ["pa"],
                },
                3: {
                    "ca_technology": "TDD+TDD",
                    "pcell_idx": 141,
                    "attenuator": ["pa"],
                },
            },
        },
        "T283": {
            "ca_technology": "FDD+TDD",
            "pcell_idx": 11,
            "attenuator": ["pa"],
            "lte_cell_idx": 11,
            "nsa_pa_ru_idx": "7",
            "UEs_info": {
                1: {
                    "ca_technology": "TDD+TDD",
                    "pcell_idx": 132,
                    "attenuator": ["pa"],
                },
                2: {
                    "ca_technology": "TDD+TDD",
                    "pcell_idx": 301,
                    "attenuator": ["pa"],
                },
            },
        },
        "T080": {
            "ca_technology": "TDD+TDD",
            "pcell_idx": 301,
            "attenuator": ["pa"],
            "lte_cell_idx": 11,
            "nsa_pa_ru_idx": "6",
            "UEs_info": {
                0: {
                    "ca_technology": "TDD+TDD",
                    "pcell_idx": 301,
                    "attenuator": ["pa"],
                },
                1: {
                    "ca_technology": "TDD+TDD",
                    "pcell_idx": 301,
                    "attenuator": ["pa"],
                },
            },
        },
    },
    "5603027": {
        "T813": {
            "ca_technology": "FDD+TDD",
            "pcell_idx": 1,
            "attenuator": ["pa"],
            "lte_cell_idx": 1,
            "nsa_pa_ru_idx": "6",
            "UEs_info": {
                1: {
                    "ca_technology": "TDD+TDD",
                    "pcell_idx": 131,
                    "attenuator": ["pa"],
                },
                2: {
                    "ca_technology": "TDD+TDD",
                    "pcell_idx": 301,
                    "attenuator": ["pa"],
                },
            },
        },
        "T073": {
            "ca_technology": "TDD+TDD",
            "pcell_idx": 301,
            "attenuator": ["pa"],
            "UEs_info": {
                1: {
                    "ca_technology": "TDD+TDD",
                    "pcell_idx": 131,
                    "attenuator": ["pa"],
                }
            },
        },
        "T080": {
            "ca_technology": "TDD+TDD",
            "pcell_idx": 303,
            "attenuator": ["pa"],
            "UEs_info": {
                0: {
                    "ca_technology": "FDD+TDD",
                    "pcell_idx": 13,
                    "attenuator": ["pa"],
                }
            },
        },
        "T283": {
            "ca_technology": "FDD+TDD",
            "pcell_idx": 11,
            "attenuator": ["pa"],
            "lte_cell_idx": 11,
            "nsa_pa_ru_idx": "7",
            "UEs_info": {
                1: {
                    "ca_technology": "TDD+TDD",
                    "pcell_idx": 132,
                    "attenuator": ["pa"],
                },
                2: {
                    "ca_technology": "TDD+TDD",
                    "pcell_idx": 301,
                    "attenuator": ["pa"],
                },
            },
        },
    },
    "5603076": {
        "T813": {
            "ca_technology": "FDD+TDD",
            "pcell_idx": 1,
            "attenuator": ["pa"],
            "lte_cell_idx": 11,
            "nsa_pa_ru_idx": "6",
            "UEs_info": {
                1: {
                    "ca_technology": "TDD+TDD",
                    "pcell_idx": 131,
                    "attenuator": ["pa"],
                },
                2: {
                    "ca_technology": "TDD+FDD",
                    "pcell_idx": 301,
                    "attenuator": ["pa"],
                },
            },
        },
        "T073": {
            "ca_technology": "TDD+TDD",
            "pcell_idx": 301,
            "attenuator": ["pa"],
            "UEs_info": {
                1: {
                    "ca_technology": "TDD+FDD",
                    "pcell_idx": 131,
                    "attenuator": ["pa"],
                }
            },
        },
        "T080": {
            "ca_technology": "TDD+TDD",
            "pcell_idx": 303,
            "attenuator": ["pa"],
            "UEs_info": {
                0: {
                    "ca_technology": "FDD+TDD",
                    "pcell_idx": 13,
                    "attenuator": ["pa"],
                }
            },
        },
        "T283": {
            "ca_technology": "FDD+TDD",
            "pcell_idx": 11,
            "attenuator": ["pa"],
            "lte_cell_idx": 11,
            "nsa_pa_ru_idx": "7",
            "UEs_info": {
                1: {
                    "ca_technology": "TDD+TDD",
                    "pcell_idx": 132,
                    "attenuator": ["pa"],
                },
                2: {
                    "ca_technology": "TDD+FDD",
                    "pcell_idx": 301,
                    "attenuator": ["pa"],
                },
            },
        },
    },
    "5603086": {
        "T813": {"pcell_idx": 1, "attenuator": ["pa"]},
        "T080": {"pcell_idx": 11, "attenuator": ["pa"]},
        "T073": {"pcell_idx": 1, "attenuator": ["pa"]},
        "T283": {"pcell_idx": 11, "attenuator": ["pa"]},
    },
    "5603075": {
        "T813": {
            "ca_technology": "FDD+TDD",
            "pcell_idx": 1,
            "attenuator": ["pa"],
            "lte_cell_idx": 11,
            "nsa_pa_ru_idx": "6",
            "UEs_info": {
                1: {
                    "ca_technology": "TDD+TDD",
                    "pcell_idx": 131,
                    "attenuator": ["pa"],
                },
                2: {
                    "ca_technology": "TDD+FDD",
                    "pcell_idx": 301,
                    "attenuator": ["pa"],
                },
            },
        },
        "T080": {"pcell_idx": 303, "ca_technology": "TDD+TDD", "attenuator": ["pa"]},
        "T073": {
            "ca_technology": "TDD+TDD",
            "pcell_idx": 301,
            "attenuator": ["pa"],
            "UEs_info": {
                1: {
                    "ca_technology": "TDD+FDD",
                    "pcell_idx": 131,
                    "attenuator": ["pa"],
                }
            },
        },
        "T283": {
            "ca_technology": "FDD+TDD",
            "pcell_idx": 11,
            "attenuator": ["pa"],
            "lte_cell_idx": 11,
            "nsa_pa_ru_idx": "7",
            "UEs_info": {
                1: {
                    "ca_technology": "TDD+TDD",
                    "pcell_idx": 132,
                    "attenuator": ["pa"],
                },
                2: {
                    "ca_technology": "TDD+FDD",
                    "pcell_idx": 301,
                    "attenuator": ["pa"],
                },
            },
        },
    },
    "5603037": {
        "T813": {
            "ca_technology": "TDD+TDD",
            "pcell_idx": 301,
            "attenuator": ["pa"],
            "lte_cell_idx": 11,
            "nsa_pa_ru_idx": "6",
            "UEs_info": {
                1: {
                    "ca_technology": "TDD+TDD",
                    "pcell_idx": 131,
                    "attenuator": ["pa"],
                },
                2: {
                    "ca_technology": "FDD+FDD",
                    "pcell_idx": 1,
                    "attenuator": ["pa"],
                },
            },
        },
        "T073": {
            "ca_technology": "TDD+TDD",
            "pcell_idx": 301,
            "attenuator": ["pa"],
            "UEs_info": {
                1: {
                    "ca_technology": "TDD+FDD",
                    "pcell_idx": 131,
                    "attenuator": ["pa"],
                }
            },
        },
        "T080": {
            "ca_technology": "TDD+TDD",
            "pcell_idx": 303,
            "attenuator": ["pa"],
            "UEs_info": {
                0: {
                    "ca_technology": "FDD+TDD",
                    "pcell_idx": 13,
                    "attenuator": ["pa"],
                }
            },
        },
        "T283": {
            "ca_technology": "TDD+TDD",
            "pcell_idx": 301,
            "attenuator": ["pa"],
            "lte_cell_idx": 11,
            "nsa_pa_ru_idx": "7",
            "UEs_info": {
                1: {
                    "ca_technology": "TDD+TDD",
                    "pcell_idx": 132,
                    "attenuator": ["pa"],
                },
                2: {
                    "ca_technology": "FDD+FDD",
                    "pcell_idx": 11,
                    "attenuator": ["pa"],
                },
            },
        },
    },
    "5603153": {
        "T813": {
            "ca_technology": "TDD+TDD",
            "pcell_idx": 301,
            "lte_cell_idx": 11,
            "attenuator": ["pa"],
        },
        "T073": {
            "ca_technology": "TDD+TDD",
            "pcell_idx": 301,
            "lte_cell_idx": 11,
            "attenuator": ["pa"],
        },
        "T080": {
            "ca_technology": "TDD+TDD",
            "pcell_idx": 301,
            "lte_cell_idx": 11,
            "attenuator": ["pa"],
            "UEs_info": {
                4: {
                    "ca_technology": "TDD+TDD",
                    "pcell_idx": 301,
                    "lte_cell_idx": 11,
                    "attenuator": ["pa"],
                }
            },
        },
        "T283": {
            "ca_technology": "TDD+TDD",
            "pcell_idx": 301,
            "attenuator": ["pa"],
            "ho_ca_technology": "TDD+TDD",
        },
        "T284": {
            "ca_technology": "TDD+TDD",
            "pcell_idx": 301,
            "lte_cell_idx": 11,
            "attenuator": ["pa"],
        },
        "T816": {
            "ca_technology": "TDD+TDD",
            "pcell_idx": 301,
            "lte_cell_idx": 1,
            "attenuator": ["pa"],
            "UEs_info": {
                2: {
                    "ca_technology": "TDD+TDD",
                    "pcell_idx": 301,
                    "lte_cell_idx": 1,
                    "attenuator": ["pa"],
                }
            },
        },
    },
    "CB008236-SR-A": {
        "T283": {"ca_technology": "FDD", "pcell_idx": 1, "attenuator": ["pa"]},
    },
    "E2E": {
        "T813": {
            "ca_technology": "TDD+TDD",
            "pcell_idx": 301,
            "lte_cell_idx": 11,
            "attenuator": ["pa"],
        },
        "T282": {
            "ca_technology": "TDD+TDD",
            "pcell_idx": 301,
            "attenuator": ["pa"],
            "lte_cell_idx": 11,
        },
        "T283": {
            "ca_technology": "TDD+TDD",
            "pcell_idx": 301,
            "attenuator": ["pa"],
            "lte_cell_idx": 11,
        },
        "T073": {
            "ca_technology": "TDD+TDD",
            "pcell_idx": 301,
            "lte_cell_idx": 11,
            "attenuator": ["pa"],
        },
        "T819": {
            "ca_technology": "TDD+TDD",
            "pcell_idx": 301,
            "lte_cell_idx": 11,
            "attenuator": ["pa"],
        },
        "T080": {
            "ca_technology": "TDD+TDD",
            "pcell_idx": 301,
            "lte_cell_idx": 11,
            "attenuator": ["pa"],
            "UEs_info": {
                1: {
                    "ca_technology": "TDD+TDD",
                    "pcell_idx": 301,
                    "lte_cell_idx": 11,
                    "attenuator": ["pa"],
                }
            },
        },
        "T284": {
            "ca_technology": "TDD+TDD",
            "pcell_idx": 301,
            "lte_cell_idx": 11,
            "attenuator": ["pa"],
        },
        "T816": {
            "ca_technology": "TDD+TDD",
            "pcell_idx": 301,
            "lte_cell_idx": 1,
            "attenuator": ["pa"],
            "UEs_info": {
                2: {
                    "ca_technology": "TDD+TDD",
                    "pcell_idx": 301,
                    "lte_cell_idx": 1,
                    "attenuator": ["pa"],
                }
            },
        },
    },
    "5603099": {
        "T284": {
            "ca_technology": "TDD+TDD",
            "pcell_idx": 31,
            "attenuator": ["pa"],
            "UEs_info": {
                1: {
                    "ca_technology": "TDD+TDD",
                    "pcell_idx": 301,
                    "attenuator": ["pa"],
                }
            },
        },
    },
    "5603104": {
        "T813": {
            "ca_technology": "TDD+TDD",
            "pcell_idx": 301,
            "after_ho_pcell_idx": 1,
            "attenuator": ["pa"],
            "ho_ca_technology": "FDD+TDD",
        },
        "T080": {
            "ca_technology": "TDD+TDD",
            "pcell_idx": 302,
            "after_ho_pcell_idx": 11,
            "attenuator": ["pa"],
            "ho_ca_technology": "FDD+TDD",
        },
    },
    "5603105": {
        "T073": {
            "ca_technology": "TDD+TDD",
            "pcell_idx": 301,
            "attenuator": ["pa"],
            "ho_ca_technology": "TDD+TDD",
        },
        "T283": {
            "ca_technology": "TDD+TDD",
            "pcell_idx": 301,
            "attenuator": ["pa"],
            "ho_ca_technology": "TDD+TDD",
        },
        "T816": {
            "ca_technology": "TDD+TDD",
            "pcell_idx": 301,
            "attenuator": ["pa"],
            "ho_ca_technology": "TDD+TDD",
        },
        "T080": {
            "ca_technology": "TDD+TDD",
            "pcell_idx": 302,
            "attenuator": ["pa"],
            "ho_ca_technology": "TDD+TDD",
        },
    },
    "5603106": {
        "T813": {
            "ca_technology": "TDD+TDD",
            "pcell_idx": 301,
            "lte_cell_idx": 11,
            "nsa_pa_ru_idx": "6",
            "attenuator": ["pa"],
            "UEs_info": {
                1: {
                    "ca_technology": "TDD+TDD",
                    "pcell_idx": 301,
                    "attenuator": ["pa"],
                }
            },
        },
        "T073": {
            "ca_technology": "TDD+TDD",
            "pcell_idx": 301,
            "attenuator": ["pa"],
        },
        "T080": {
            "ca_technology": "TDD+TDD",
            "pcell_idx": 302,
            "attenuator": ["pa"],
        },
    },
    "[1]E2E": {
        "T813": {
            "ca_technology": "TDD+TDD",
            "pcell_idx": 301,
            "lte_cell_idx": 11,
            "attenuator": ["pa"],
        },
        "T282": {
            "ca_technology": "TDD+TDD",
            "pcell_idx": 301,
            "lte_cell_idx": 11,
            "attenuator": ["pa"],
        },
        "T819": {
            "ca_technology": "TDD+TDD",
            "pcell_idx": 301,
            "lte_cell_idx": 11,
            "attenuator": ["pa"],
        },
        "T283": {
            "ca_technology": "TDD+TDD",
            "pcell_idx": 301,
            "attenuator": ["pa"],
            "lte_cell_idx": 11,
        },
        "T073": {
            "ca_technology": "TDD+TDD",
            "pcell_idx": 301,
            "lte_cell_idx": 11,
            "gsm_bts_id": 1,
            "gsm_bcf_id": 1,
            "gsm_cell_idx": 1,
            "LTE_bts_id": 731,
            "attenuator": ["pa"],
        },
        "T080": {
            "ca_technology": "TDD+TDD",
            "pcell_idx": 301,
            "gsm_bts_id": 1,
            "gsm_bcf_id": 1,
            "gsm_cell_idx": 1,
            "LTE_bts_id": 8080,
            "lte_cell_idx": 11,
            "attenuator": ["pa"],
            "UEs_info": {
                0: {
                    "ca_technology": "TDD+TDD",
                    "pcell_idx": 302,
                    "attenuator": ["pa"],
                },
                15: {
                    "ca_technology": "TDD+TDD",
                    "pcell_idx": 302,
                    "attenuator": ["pa"],
                },
            },
        },
        "T284": {
            "ca_technology": "TDD+TDD",
            "pcell_idx": 301,
            "lte_cell_idx": 11,
            "attenuator": ["pa"],
        },
        "T816": {
            "ca_technology": "TDD+TDD",
            "pcell_idx": 301,
            "lte_cell_idx": 1,
            "gsm_bts_id": 1,
            "gsm_bcf_id": 1,
            "gsm_cell_idx": 1,
            "LTE_bts_id": 8161,
            "attenuator": ["pa"],
        },
    },
    "5603139": {
        "T813": {
            "ca_technology": "TDD+TDD",
            "pcell_idx": 301,
            "lte_cell_idx": 11,
            "nsa_pa_ru_idx": "6",
            "attenuator": ["pa"],
            "UEs_info": {
                1: {
                    "ca_technology": "TDD+TDD",
                    "pcell_idx": 301,
                    "attenuator": ["pa"],
                }
            },
        },
        "T073": {
            "ca_technology": "TDD+TDD",
            "pcell_idx": 301,
            "attenuator": ["pa"],
        },
        "T080": {
            "ca_technology": "TDD+TDD",
            "pcell_idx": 302,
            "attenuator": ["pa"],
        },
        "T284": {
            "ca_technology": "TDD+TDD",
            "pcell_idx": 301,
            "attenuator": ["pa"],
        },
        "T819": {
            "ca_technology": "TDD+TDD",
            "pcell_idx": 301,
            "attenuator": ["pa"],
        },
        "T816": {
            "ca_technology": "TDD+TDD",
            "pcell_idx": 301,
            "attenuator": ["pa"],
        },
    },
    "5603049": {
        "T080": {
            "ca_technology": "TDD+TDD",
            "pcell_idx": 301,
            "attenuator": ["pa"],
            "UEs_info": {
                1: {
                    "ca_technology": "TDD+TDD",
                    "pcell_idx": 301,
                    "lte_cell_idx": 31,
                    "attenuator": ["pa"],
                }
            },
        },
        "T813": {
            "ca_technology": "TDD+TDD",
            "pcell_idx": 301,
            "attenuator": ["pa"],
            "UEs_info": {
                1: {
                    "ca_technology": "TDD+TDD",
                    "pcell_idx": 301,
                    "lte_cell_idx": 11,
                    "attenuator": ["pa"],
                }
            },
        },
    },
    "5603142": {
        "T284": {
            "ca_technology": "TDD+TDD",
            "pcell_idx": 301,
            "attenuator": ["pa"],
        },
        "T080": {
            "ca_technology": "TDD+TDD",
            "pcell_idx": 303,
            "attenuator": ["pa"],
        },
    },
    "5603152": {
        "T284": {"ca_technology": "TDD+TDD", "pcell_idx": 371, "attenuator": ["pa"]},
    },
    "5605002": {
        "T284": {
            "ca_technology": "TDD+TDD",
            "pcell_idx": 301,
            "attenuator": ["pa"],
        },
        "T080": {
            "ca_technology": "TDD+TDD",
            "pcell_idx": 303,
            "attenuator": ["pa"],
        },
        "T073": {
            "ca_technology": "TDD+TDD",
            "pcell_idx": 301,
            "attenuator": ["pa"],
        },
    },
    "5605005": {
        "T080": {
            "ca_technology": "TDD+TDD",
            "pcell_idx": 301,
            "attenuator": ["pa"],
        },
        "T073": {
            "ca_technology": "TDD+TDD",
            "pcell_idx": 302,
            "attenuator": ["pa"],
        },
        "T284": {
            "ca_technology": "TDD+TDD",
            "pcell_idx": 301,
            "attenuator": ["pa"],
        },
        "T813": {
            "ca_technology": "TDD+TDD",
            "pcell_idx": 301,
            "attenuator": ["pa"],
        },
    },
    "5605006": {
        "T080": {
            "ca_technology": "TDD+TDD",
            "pcell_idx": 301,
            "attenuator": ["pa"],
        },
        "T813": {
            "ca_technology": "TDD+TDD",
            "pcell_idx": 301,
            "attenuator": ["pa"],
        },
        "T284": {
            "ca_technology": "TDD+TDD",
            "pcell_idx": 301,
            "attenuator": ["pa"],
        },
        "T283": {
            "ca_technology": "TDD+TDD",
            "pcell_idx": 301,
            "attenuator": ["pa"],
        },
    },
    "5605501": {
        "T080": {
            "ca_technology": "TDD+TDD",
            "pcell_idx": 301,
            "attenuator": ["pa"],
        },
        "T816": {
            "ca_technology": "TDD+TDD",
            "pcell_idx": 301,
            "attenuator": ["pa"],
        },
    },
    "5605011": {
        "T080": {
            "ca_technology": "TDD+TDD",
            "pcell_idx": 311,
            "attenuator": ["pa"],
        },
    },
    "5605500": {
        "T080": {
            "ca_technology": "TDD+TDD",
            "pcell_idx": 301,
            "attenuator": ["pa"],
        },
        "T813": {
            "ca_technology": "TDD+TDD",
            "pcell_idx": 301,
            "attenuator": ["pa"],
        },
    },
    "5605502": {
        "T080": {
            "ca_technology": "TDD+TDD",
            "pcell_idx": 301,
            "attenuator": ["pa"],
        },
    },
    "5603147": {
        "T080": {
            "ca_technology": "TDD+TDD",
            "pcell_idx": 301,
            "attenuator": ["pa"],
        },
    },
    "5605012": {
        "T283": {
            "ca_technology": "TDD+TDD",
            "pcell_idx": 301,
            "attenuator": ["pa"],
        },
        "T080": {
            "ca_technology": "TDD+TDD",
            "pcell_idx": 301,
            "attenuator": ["pa"],
        },
    },
    "5605013": {
        "T813": {
            "ca_technology": "TDD+TDD",
            "pcell_idx": 301,
            "attenuator": ["pa"],
        },
        "T284": {
            "ca_technology": "TDD+TDD",
            "pcell_idx": 301,
            "attenuator": ["pa"],
        },
    },
    "5605014": {
        "T080": {
            "ca_technology": "TDD+TDD",
            "pcell_idx": 301,
            "attenuator": ["pa"],
        },
    },
    "[1]CB010889": {
        "T813": {
            "ca_technology": "TDD+TDD",
            "pcell_idx": 301,
            "attenuator": ["pa"],
            "UEs_info": {
                1: {
                    "ca_technology": "FDD+TDD",
                    "pcell_idx": 301,
                    "lte_cell_idx": 11,
                    "attenuator": ["pa"],
                }
            },
        },
        "T073": {
            "ca_technology": "TDD+TDD",
            "pcell_idx": 301,
            "scell_idx_list": [311],
            "attenuator": ["pa"],
            "UEs_info": {
                14: {
                    "ca_technology": "FDD+TDD",
                    "pcell_idx": 1,
                    "attenuator": ["pa"],
                }
            },
        },
    },
    "[1]CB010744": {
        "T813": {
            "ca_technology": "TDD+TDD",
            "pcell_idx": 301,
            "attenuator": ["pa"],
            "UEs_info": {
                1: {
                    "ca_technology": "FDD+TDD",
                    "pcell_idx": 301,
                    "lte_cell_idx": 11,
                    "attenuator": ["pa"],
                }
            },
        },
        "T073": {
            "ca_technology": "TDD+TDD",
            "pcell_idx": 301,
            "attenuator": ["pa"],
            "UEs_info": {
                14: {
                    "ca_technology": "FDD+TDD",
                    "pcell_idx": 1,
                    "attenuator": ["pa"],
                }
            },
        },
    },
}

KPI_PA = {
    "T284": {
        "good": {"9": "5", "10": "5", "11": "5", "12": "5"},
        "good_avql": {"1": "11", "4": "11", "5": "11", "6": "11"},
        "mid": {"9": "33", "10": "33", "11": "33", "12": "33"},
        "mid_avql": {"1": "46", "4": "46", "5": "46", "6": "46"},
        "bad": {"9": "53", "10": "53", "11": "53", "12": "53"},
        "bad_avql": {"1": "64", "4": "64", "5": "64", "6": "64"},
        "low": {"9": "39", "10": "39", "11": "39", "12": "39"},
        "DL_Peak_TP": "2500M",
        "UL_Peak_TP": "235MKbits/sec",
        "DL_mid_TP": "800M",
        "UL_mid_TP": "20MKbits/sec",
        "DL_bad_TP": "500M",
        "UL_bad_TP": "20MKbits/sec",
        "DL_Low_TP": "10M",
        "UL_Low_TP": "1MKbits/sec",
        "DL_8UE_Peak_TP": "300M",
        "UL_8UE_Peak_TP": "30MKbits/sec",
        "DL_8UE_low_RSRP_TP": "150M",
        "UL_8UE_low_RSRP_TP": "3MKbits/sec",
        "DL_8UE_low_RSRP_low_TP": "10M",
        "UL_8UE_low_RSRP_low_TP": "1MKbits/sec",
        "DL_400M_8311": "400M",
        "DL_10M_8311": "10M",
        "DL_200M_8311": "200M",
    },
    "T080": {
        "good": {"1": "7", "2": "7", "3": "7", "4": "7"},
        "mid": {"1": "28", "2": "28", "3": "28", "4": "28"},
        "bad": {"1": "56", "2": "56", "3": "56", "4": "56"},
        "low": {"1": "35", "2": "35", "3": "35", "4": "35"},
        "DL_Peak_TP": "1250M",
        "UL_Peak_TP": "235MKbits/sec",
        "DL_mid_TP": "800M",
        "UL_mid_TP": "20MKbits/sec",
        "DL_bad_TP": "500M",
        "UL_bad_TP": "20MKbits/sec",
        "DL_Low_TP": "10M",
        "UL_Low_TP": "1MKbits/sec",
        "DL_8UE_Peak_TP": "300M",
        "UL_8UE_Peak_TP": "30MKbits/sec",
        "DL_8UE_low_RSRP_TP": "150M",
        "UL_8UE_low_RSRP_TP": "3MKbits/sec",
        "DL_8UE_low_RSRP_low_TP": "10M",
        "UL_8UE_low_RSRP_low_TP": "1MKbits/sec",
        "DL_400M_8311": "400M",
        "DL_10M_8311": "10M",
    },
    "T073": {
        "good": {"5": "7", "6": "7", "7": "7", "8": "7"},
        "mid": {"5": "28", "6": "28", "7": "28", "8": "28"},
        "bad": {"5": "56", "6": "56", "7": "56", "8": "56"},
        "low": {"5": "35", "6": "35", "7": "35", "8": "35"},
        "DL_Peak_TP": "1250M",
        "UL_Peak_TP": "235MKbits/sec",
        "DL_mid_TP": "800M",
        "UL_mid_TP": "20MKbits/sec",
        "DL_bad_TP": "500M",
        "UL_bad_TP": "20MKbits/sec",
        "DL_Low_TP": "10M",
        "UL_Low_TP": "1MKbits/sec",
        "DL_8UE_Peak_TP": "300M",
        "UL_8UE_Peak_TP": "30MKbits/sec",
        "DL_8UE_low_RSRP_TP": "150M",
        "UL_8UE_low_RSRP_TP": "3MKbits/sec",
        "DL_8UE_low_RSRP_low_TP": "10M",
        "UL_8UE_low_RSRP_low_TP": "1MKbits/sec",
        "DL_400M_8311": "400M",
        "DL_10M_8311": "10M",
    },
}

CASE_FOR_B2_HO_CHOOSED_UE = {
    "T813": 0,
    "T283": 0,
    "T073": 0,
    "T080": 3,
    "T284": 9,
}

CASE_FOR_VoLTE_CHOOSED_UE = {
    "T813": 0,
    "T283": 0,
    "T073": 0,
    "T080": 3,
}


CASE_FOR_KPI_CHOOSED_UE = {
    "T813": 0,
    "T283": 0,
    "T073": 6,
    "T080": 4,
    "T284": 9,
}


REPCASE_5605005_CHOOSED_UE = {
    "T073": 6,
    "T080": 6,
    "T284": 0,
    "T813": 0,
}

REPCASE_5605006_CHOOSED_UE = {
    "T073": 6,
    "T080": 0,
    "T284": 9,
    "T813": 0,
    "T283": 0,
}

REPCASE_5605012_CHOOSED_UE = {
    "T283": 7,
    "T080": 15,
}

REPCASE_5605003_CHOOSED_UE = {
    "T813": 0,
    "T283": 7,
    "T073": 0,
    "T080": 15,
    "T284": 9,
    "T816": 3,
}
REPCASE_5605014_CHOOSED_UE = {
    "T080": 4,
}
CB007163_CHOOSED_UE = {
    "T816": 3,
    "T813": 3,
}


EDA05437018_CHOOSED_UE = {
    "T813": 0,
}

CB007163_object_added = [
    {
        "dist_name": "MRBTS-816/LNBTS-8161/LNCEL-21/LNHOIF-2",
        "parameter": "a3OffsetRsrpInterFreq",
        "value": "2",
    },
    {
        "dist_name": "MRBTS-816/LNBTS-8161/LNCEL-21/LNHOIF-2",
        "parameter": "a3OffsetRsrpInterFreqQci1",
        "value": "6",
    },
    {
        "dist_name": "MRBTS-816/LNBTS-8161/LNCEL-21/LNHOIF-2",
        "parameter": "a3ReportAmountRsrpInterFreq",
        "value": "infinity",
    },
    {
        "dist_name": "MRBTS-816/LNBTS-8161/LNCEL-21/LNHOIF-2",
        "parameter": "a3ReportAmountRsrqInterFreq",
        "value": "infinity",
    },
    {
        "dist_name": "MRBTS-816/LNBTS-8161/LNCEL-21/LNHOIF-2",
        "parameter": "a3ReportIntervalRsrpInterFreq",
        "value": "240ms",
    },
    {
        "dist_name": "MRBTS-816/LNBTS-8161/LNCEL-21/LNHOIF-2",
        "parameter": "a3TimeToTriggerRsrpInterFreq",
        "value": "640ms",
    },
    {
        "dist_name": "MRBTS-816/LNBTS-8161/LNCEL-21/LNHOIF-2",
        "parameter": "a5ReportAmountRsrpInterFreq",
        "value": "infinity",
    },
    {
        "dist_name": "MRBTS-816/LNBTS-8161/LNCEL-21/LNHOIF-2",
        "parameter": "a5ReportAmountRsrqInterFreq",
        "value": "infinity",
    },
    {
        "dist_name": "MRBTS-816/LNBTS-8161/LNCEL-21/LNHOIF-2",
        "parameter": "a5ReportIntervalInterFreq",
        "value": "240ms",
    },
    {
        "dist_name": "MRBTS-816/LNBTS-8161/LNCEL-21/LNHOIF-2",
        "parameter": "a5TimeToTriggerInterFreq",
        "value": "320ms",
    },
    {
        "dist_name": "MRBTS-816/LNBTS-8161/LNCEL-21/LNHOIF-2",
        "parameter": "eutraCarrierInfo",
        "value": "2300",
    },
    {
        "dist_name": "MRBTS-816/LNBTS-8161/LNCEL-21/LNHOIF-2",
        "parameter": "hysA3OffsetRsrpInterFreq",
        "value": "2",
    },
    {
        "dist_name": "MRBTS-816/LNBTS-8161/LNCEL-21/LNHOIF-2",
        "parameter": "hysThreshold3InterFreq",
        "value": "2",
    },
    {
        "dist_name": "MRBTS-816/LNBTS-8161/LNCEL-21/LNHOIF-2",
        "parameter": "interPresAntP",
        "value": "true",
    },
    {
        "dist_name": "MRBTS-816/LNBTS-8161/LNCEL-21/LNHOIF-2",
        "parameter": "measQuantInterFreq",
        "value": "rsrp",
    },
    {
        "dist_name": "MRBTS-816/LNBTS-8161/LNCEL-21/LNHOIF-2",
        "parameter": "measurementBandwidth",
        "value": "mbw100",
    },
    {
        "dist_name": "MRBTS-816/LNBTS-8161/LNCEL-21/LNHOIF-2",
        "parameter": "offsetFreqInter",
        "value": "0dB",
    },
    {
        "dist_name": "MRBTS-816/LNBTS-8161/LNCEL-21/LNHOIF-2",
        "parameter": "threshold3InterFreq",
        "value": "94",
    },
    {
        "dist_name": "MRBTS-816/LNBTS-8161/LNCEL-21/LNHOIF-2",
        "parameter": "threshold3InterFreqQci1",
        "value": "45",
    },
    {
        "dist_name": "MRBTS-816/LNBTS-8161/LNCEL-21/LNHOIF-2",
        "parameter": "threshold3aInterFreq",
        "value": "24",
    },
    {
        "dist_name": "MRBTS-816/LNBTS-8161/LNCEL-21/LNHOIF-2",
        "parameter": "threshold3aInterFreqQci1",
        "value": "29",
    },
    {
        "dist_name": "MRBTS-816/LNBTS-8161/LNCEL-21/LNHOIF-2",
        "parameter": "thresholdRsrpEndcFilt",
        "value": "-110",
    },
    {
        "dist_name": "MRBTS-816/LNBTS-8161/LNCEL-21/LNHOIF-2",
        "parameter": "thresholdRsrpIFLBFilter",
        "value": "-104",
    },
    {
        "dist_name": "MRBTS-816/LNBTS-8161/LNCEL-21/LNHOIF-2",
        "parameter": "thresholdRsrpUlTraffHoFilter",
        "value": "-98",
    },
    {
        "dist_name": "MRBTS-816/LNBTS-8161/LNCEL-21/LNHOIF-2",
        "parameter": "thresholdRsrqEndcFilt",
        "value": "-195",
    },
    {
        "dist_name": "MRBTS-816/LNBTS-8161/LNCEL-21/LNHOIF-2",
        "parameter": "thresholdRsrqIFLBFilter",
        "value": "-190",
    },
    {
        "dist_name": "MRBTS-816/LNBTS-8161/LNCEL-21/LNHOIF-2",
        "parameter": "thresholdRsrqUlTraffHoFilter",
        "value": "-120",
    },
    {
        "dist_name": "MRBTS-816/LNBTS-8161/LNCEL-21/LNHOIF-2",
        "parameter": "eventMeasPrio",
        "value": [{"prioA3RSRP": "1", "prioA3RSRQ": "3", "prioA5": "1"}],
    },
]

CB007163_param_added = [
    {
        "dist_name": "MRBTS-816/LNBTS-8161/MODPR-0",
        "parameter": "freqLayEndcHoList",
        "value": [
            {"freqLayer": "2300", "preference": "true"},
            {"freqLayer": "975", "preference": "false"},
        ],
    }
]

CB007163_params_update = [
    {
        "dist_name": "MRBTS-816/LNBTS-8161",
        "parameter": "actEndcHo",
        "value": "enabled",
    },
    {
        "dist_name": "MRBTS-816/LNBTS-8161",
        "parameter": "actUeCapEndcHo",
        "value": "false",
    },
    {
        "dist_name": "MRBTS-816/LNBTS-8161",
        "parameter": "actSelMobPrf",
        "value": "false",
    },
    {
        "dist_name": "MRBTS-816/LNBTS-8161/LNCEL-21",
        "parameter": "actEndcHoPrefLay",
        "value": "true",
    },
    {
        "dist_name": "MRBTS-816/LNBTS-8161/LNCEL-21/SIB-0",
        "parameter": "cellBarred",
        "value": "notBarred",
    },
    {
        "dist_name": "MRBTS-816/LNBTS-8161/LNCEL-1/SIB-0",
        "parameter": "cellBarred",
        "value": "notBarred",
    },
    {
        "dist_name": "MRBTS-816/LNBTS-8161/LNCEL-11/SIB-0",
        "parameter": "cellBarred",
        "value": "notBarred",
    },
    {
        "dist_name": "MRBTS-816/LNBTS-8161/LNCEL-21/LNHOIF-1",
        "parameter": "eutraCarrierInfo",
        "value": "975",
    },
    {
        "dist_name": "MRBTS-816/LNBTS-8161/LNCEL-21/LNHOIF-1",
        "parameter": "thresholdRsrpEndcFilt",
        "value": "-110",
    },
    {
        "dist_name": "MRBTS-816/LNBTS-8161/MODPR-0",
        "parameter": "autoAdapt",
        "value": "false",
    },
]

CB007163_HO_param_modified = [
    {
        "dist_name": "MRBTS-816/LNBTS-8161/MODPR-0",
        "parameter": "freqLayEndcHoList",
        "value": [
            {"freqLayer": "975", "preference": "true"},
            {"freqLayer": "2300", "preference": "false"},
        ],
    }
]

CB007035_params_update_25R3 = [
    {
        "dist_name": "MRBTS-816/LNBTS-8161/ANR-0",
        "parameter": "anrNrInactivityTimer",
        "value": "1",
    },
    {
        "dist_name": "MRBTS-816/LNBTS-8161/ANR-0",
        "parameter": "anrNrMeasConfList",
        "value": [
            {"thresholdNrRsrp": "46"},
        ],
    },
    {
        "dist_name": "MRBTS-816/NRBTS-816",
        "parameter": "srbInactivityTimerSA",
        "value": "60",
    },
    {
        "dist_name": "MRBTS-816/NRBTS-816",
        "parameter": "drbInactivityTimerSA",
        "value": "60",
    },
    {
        "dist_name": "MRBTS-816/LNBTS-8161",
        "parameter": "actHOtoNR",
        "value": "true",
    },
    {
        "dist_name": "MRBTS-816/LNBTS-8161",
        "parameter": "actUeBasedAnrNrHo",
        "value": "true",
    },
    {
        "dist_name": "MRBTS-816/LNBTS-8161",
        "parameter": "actDynTrigLteNrDualConnectivity",
        "value": "true",
    },
    {
        "dist_name": "MRBTS-816/LNBTS-8161/LNMME-0",
        "parameter": "ipAddrPrim",
        "value": "10.70.255.38",
    },
    {
        "dist_name": "MRBTS-816/LNBTS-8161/LNCEL-1",
        "parameter": "tac",
        "value": "20310",
    },
    {
        "dist_name": "MRBTS-816/LNBTS-8161/LNCEL-1",
        "parameter": "actPeriodicB1NRMeas",
        "value": "enhanced",
    },
    {
        "dist_name": "MRBTS-816/LNBTS-8161/LNCEL-1",
        "parameter": "actNrServBasedHoQciX",
        "value": "true",
    },
    {
        "dist_name": "MRBTS-816/LNBTS-8161/LNCEL-1",
        "parameter": "threshold2NR",
        "value": "40",
    },
    {
        "dist_name": "MRBTS-816/LNBTS-8161/LNCEL-1",
        "parameter": "threshold2a",
        "value": "70",
    },
    {
        "dist_name": "MRBTS-816/NRBTS-816/NRCELL-302/NRPLMNSET_NSA-1",
        "parameter": "configuredEpsTac",
        "value": "20310",
    },
    {
        "dist_name": "MRBTS-816/NRBTS-816/NRCELL-302/NRPLMNSET_NSA-1",
        "parameter": "configuredEpsTac",
        "value": "20310",
    },
    # {
    #     "dist_name": "MRBTS-816/NRBTS-816/TRACKINGAREA-5700",
    #     "parameter": "fiveGsTac",
    #     "value": "20310",
    # },
    {
        "dist_name": "MRBTS-816/LNBTS-8161/MODPR-0",
        "parameter": "autoAdapt",
        "value": "false",
    },
    {
        "dist_name": "MRBTS-816/LNBTS-8161/MODPR-0",
        "parameter": "autoAdaptIMLB",
        "value": "false",
    },
    {
        "dist_name": "MRBTS-816/LNBTS-8161/NRDCDPR-0/ENDCDMEASCONF-1",
        "parameter": "b1ThresholdNrRsrp",
        "value": "116",
    },
    {
        "dist_name": "MRBTS-816/LNBTS-8161/NRDCDPR-0/ENDCDMEASCONF-3",
        "parameter": "b1ThresholdNrRsrp",
        "value": "116",
    },
    {
        "dist_name": "MRBTS-816/LNBTS-8161/NRDCDPR-0/ENDCDMEASCONF-4",
        "parameter": "b1ThresholdNrRsrp",
        "value": "116",
    },
    {
        "dist_name": "MRBTS-816/LNBTS-8161/NRDCDPR-0/ENDCDMEASCONF-0",
        "parameter": "b1ThresholdNrRsrp",
        "value": "116",
    },
    {
        "dist_name": "MRBTS-816/LNBTS-8161/NRDCDPR-0/ENDCDMEASCONF-2",
        "parameter": "b1ThresholdNrRsrp",
        "value": "116",
    },
    {
        "dist_name": "MRBTS-816/LNBTS-8161/MODPR-0",
        "parameter": "freqLayListNrServBasedHoQciX",
        "value": ["520110"],
    },
    {
        "dist_name": "MRBTS-816/LNBTS-8161/LNCEL-1/SIB-0",
        "parameter": "cellBarred",
        "value": "notBarred",
    },
    {
        "dist_name": "MRBTS-816/NRBTS-816/NRCELL-302",
        "parameter": "cellBarred",
        "value": "notBarred",
    },
    {
        "dist_name": "MRBTS-816/NRBTS-816/NRCELL-302",
        "parameter": "qRxLevMin",
        "value": "-50",
    },
]

CB007035_params_update = [
    {
        "dist_name": "MRBTS-816/LNBTS-8161/ANR-0",
        "parameter": "anrNrInactivityTimer",
        "value": "1",
    },
    {
        "dist_name": "MRBTS-816/LNBTS-8161/ANR-0",
        "parameter": "anrNrMeasConfList",
        "value": [
            {"thresholdNrRsrp": "46"},
        ],
    },
    {
        "dist_name": "MRBTS-816/NRBTS-816",
        "parameter": "srbInactivityTimerSA",
        "value": "60",
    },
    {
        "dist_name": "MRBTS-816/NRBTS-816",
        "parameter": "drbInactivityTimerSA",
        "value": "60",
    },
    {
        "dist_name": "MRBTS-816/LNBTS-8161",
        "parameter": "actHOtoNR",
        "value": "true",
    },
    {
        "dist_name": "MRBTS-816/LNBTS-8161",
        "parameter": "actUeBasedAnrNrHo",
        "value": "true",
    },
    {
        "dist_name": "MRBTS-816/LNBTS-8161",
        "parameter": "actDynTrigLteNrDualConnectivity",
        "value": "true",
    },
    {
        "dist_name": "MRBTS-816/LNBTS-8161/LNMME-0",
        "parameter": "ipAddrPrim",
        "value": "10.70.255.38",
    },
    {
        "dist_name": "MRBTS-816/LNBTS-8161/LNCEL-1",
        "parameter": "tac",
        "value": "20310",
    },
    {
        "dist_name": "MRBTS-816/LNBTS-8161/LNCEL-1",
        "parameter": "actPeriodicB1NRMeas",
        "value": "enhanced",
    },
    {
        "dist_name": "MRBTS-816/LNBTS-8161/LNCEL-1",
        "parameter": "actNrServBasedHoQciX",
        "value": "true",
    },
    {
        "dist_name": "MRBTS-816/LNBTS-8161/LNCEL-1",
        "parameter": "threshold2NR",
        "value": "40",
    },
    {
        "dist_name": "MRBTS-816/LNBTS-8161/LNCEL-1",
        "parameter": "threshold2a",
        "value": "70",
    },
    {
        "dist_name": "MRBTS-816/NRBTS-816/NRCELL-302/NRPLMNSET_NSA-1",
        "parameter": "configuredEpsTac",
        "value": "20310",
    },
    {
        "dist_name": "MRBTS-816/NRBTS-816/NRCELL-302/NRPLMNSET_NSA-1",
        "parameter": "configuredEpsTac",
        "value": "20310",
    },
    # {
    #     "dist_name": "MRBTS-816/NRBTS-816/TRACKINGAREA-5700",
    #     "parameter": "fiveGsTac",
    #     "value": "20310",
    # },
    {
        "dist_name": "MRBTS-816/LNBTS-8161/MODPR-0",
        "parameter": "autoAdapt",
        "value": "false",
    },
    {
        "dist_name": "MRBTS-816/LNBTS-8161/MODPR-0",
        "parameter": "autoAdaptIMLB",
        "value": "false",
    },
    {
        "dist_name": "MRBTS-816/LNBTS-8161/NRDCDPR-0/ENDCDMEASCONF-1",
        "parameter": "b1ThresholdNrRsrp",
        "value": "116",
    },
    {
        "dist_name": "MRBTS-816/LNBTS-8161/NRDCDPR-0/ENDCDMEASCONF-3",
        "parameter": "b1ThresholdNrRsrp",
        "value": "116",
    },
    {
        "dist_name": "MRBTS-816/LNBTS-8161/NRDCDPR-0/ENDCDMEASCONF-4",
        "parameter": "b1ThresholdNrRsrp",
        "value": "116",
    },
    {
        "dist_name": "MRBTS-816/LNBTS-8161/NRDCDPR-0/ENDCDMEASCONF-0",
        "parameter": "b1ThresholdNrRsrp",
        "value": "116",
    },
    {
        "dist_name": "MRBTS-816/LNBTS-8161/NRDCDPR-0/ENDCDMEASCONF-2",
        "parameter": "b1ThresholdNrRsrp",
        "value": "116",
    },
    {
        "dist_name": "MRBTS-816/LNBTS-8161",
        "parameter": "qciTab2",
        "value": [
            {"nrServBasedHoAllowed": "allowed"},
        ],
    },
    {
        "dist_name": "MRBTS-816/LNBTS-8161",
        "parameter": "qciTab3",
        "value": [
            {"nrServBasedHoAllowed": "allowed"},
        ],
    },
    {
        "dist_name": "MRBTS-816/LNBTS-8161",
        "parameter": "qciTab4",
        "value": [
            {"nrServBasedHoAllowed": "allowed"},
        ],
    },
    {
        "dist_name": "MRBTS-816/LNBTS-8161",
        "parameter": "qciTab5",
        "value": [
            {"nrServBasedHoAllowed": "allowed"},
        ],
    },
    {
        "dist_name": "MRBTS-816/LNBTS-8161",
        "parameter": "qciTab6",
        "value": [
            {"nrServBasedHoAllowed": "allowed"},
        ],
    },
    {
        "dist_name": "MRBTS-816/LNBTS-8161",
        "parameter": "qciTab7",
        "value": [
            {"nrServBasedHoAllowed": "allowed"},
        ],
    },
    {
        "dist_name": "MRBTS-816/LNBTS-8161",
        "parameter": "qciTab8",
        "value": [
            {"nrServBasedHoAllowed": "allowed"},
        ],
    },
    {
        "dist_name": "MRBTS-816/LNBTS-8161/MODPR-0",
        "parameter": "freqLayListNrServBasedHoQciX",
        "value": ["520110"],
    },
    {
        "dist_name": "MRBTS-816/LNBTS-8161/LNCEL-1/SIB-0",
        "parameter": "cellBarred",
        "value": "notBarred",
    },
    {
        "dist_name": "MRBTS-816/NRBTS-816/NRCELL-302",
        "parameter": "cellBarred",
        "value": "notBarred",
    },
    {
        "dist_name": "MRBTS-816/NRBTS-816/NRCELL-302",
        "parameter": "qRxLevMin",
        "value": "-50",
    },
]
CB007035_param_added = [
    {
        "dist_name": "MRBTS-816/LNBTS-8161/MODPR-0",
        "parameter": "freqLayListPsHoNR",
        "value": ["520110"],
    },
]

CB007035_param_added_25R3 = [
    {
        "dist_name": "MRBTS-816/LNBTS-8161/LNCEL-1",
        "parameter": "volteBearerProtectTimer",
        "value": "8",
    },
    {
        "dist_name": "MRBTS-816/LNBTS-8161/MODPR-0",
        "parameter": "freqLayListPsHoNR",
        "value": ["520110"],
    },
    {
        "dist_name": "MRBTS-816/LNBTS-8161",
        "parameter": "qciTab2",
        "value": [
            {"nrServBasedHoAllowed": "allowed"},
        ],
    },
    {
        "dist_name": "MRBTS-816/LNBTS-8161",
        "parameter": "qciTab3",
        "value": [
            {"nrServBasedHoAllowed": "allowed"},
        ],
    },
    {
        "dist_name": "MRBTS-816/LNBTS-8161",
        "parameter": "qciTab4",
        "value": [
            {"nrServBasedHoAllowed": "allowed"},
        ],
    },
    {
        "dist_name": "MRBTS-816/LNBTS-8161",
        "parameter": "qciTab5",
        "value": [
            {"nrServBasedHoAllowed": "allowed"},
        ],
    },
    {
        "dist_name": "MRBTS-816/LNBTS-8161",
        "parameter": "qciTab6",
        "value": [
            {"nrServBasedHoAllowed": "allowed"},
        ],
    },
    {
        "dist_name": "MRBTS-816/LNBTS-8161",
        "parameter": "qciTab7",
        "value": [
            {"nrServBasedHoAllowed": "allowed"},
        ],
    },
    {
        "dist_name": "MRBTS-816/LNBTS-8161",
        "parameter": "qciTab8",
        "value": [
            {"nrServBasedHoAllowed": "allowed"},
        ],
    },
    {
        "dist_name": "MRBTS-816/LNBTS-8161",
        "parameter": "qciTab9",
        "value": [
            {"nrServBasedHoAllowed": "allowed"},
        ],
    },
    {
        "dist_name": "MRBTS-816/LNBTS-8161",
        "parameter": "qciTab69",
        "value": [
            {"nrServBasedHoAllowed": "allowed"},
        ],
    },
    {
        "dist_name": "MRBTS-816/LNBTS-8161",
        "parameter": "qciTab70",
        "value": [
            {"nrServBasedHoAllowed": "allowed"},
        ],
    },
    {
        "dist_name": "MRBTS-816/LNBTS-8161",
        "parameter": "qciTabOperator",
        "value": [
            {"nrServBasedHoAllowed": "allowed"},
            {"nrServBasedHoAllowed": "allowed"},
        ],
    },
]


CB007035_param_added_after_ANR = [
    {
        "dist_name": "MRBTS-816/LNBTS-8161/MOPR-1",
        "parameter": "freqLayListNrServBasedHoQciX",
        "value": ["520110"],
    },
    {
        "dist_name": "MRBTS-816/LNBTS-8161/MODPR-1",
        "parameter": "freqLayListNrServBasedHoQciX",
        "value": ["520110"],
    },
]

CB007035_object_added = [
    {
        "dist_name": "MRBTS-816/LNBTS-8161/LNCEL-1/LNHON-0",
        "parameter": "b1HysThresholdRsrp",
        "value": "0",
    },
    {
        "dist_name": "MRBTS-816/LNBTS-8161/LNCEL-1/LNHON-0",
        "parameter": "b1NrBeamReportQuantity",
        "value": "None",
    },
    {
        "dist_name": "MRBTS-816/LNBTS-8161/LNCEL-1/LNHON-0",
        "parameter": "b1NrPciHoNbrCounterDecay",
        "value": "1000",
    },
    {
        "dist_name": "MRBTS-816/LNBTS-8161/LNCEL-1/LNHON-0",
        "parameter": "b1NrPciHoNbrRelAddThresh",
        "value": "2",
    },
    {
        "dist_name": "MRBTS-816/LNBTS-8161/LNCEL-1/LNHON-0",
        "parameter": "b1NrPciHoNbrRelRemThresh",
        "value": "100000",
    },
    {
        "dist_name": "MRBTS-816/LNBTS-8161/LNCEL-1/LNHON-0",
        "parameter": "b1ReportAmount",
        "value": "r1",
    },
    {
        "dist_name": "MRBTS-816/LNBTS-8161/LNCEL-1/LNHON-0",
        "parameter": "b1ReportInterval",
        "value": "120ms",
    },
    {
        "dist_name": "MRBTS-816/LNBTS-8161/LNCEL-1/LNHON-0",
        "parameter": "b1ThresholdRsrp",
        "value": "86",
    },
    {
        "dist_name": "MRBTS-816/LNBTS-8161/LNCEL-1/LNHON-0",
        "parameter": "b1TimeToTriggerRsrp",
        "value": "256ms",
    },
    {
        "dist_name": "MRBTS-816/LNBTS-8161/LNCEL-1/LNHON-0",
        "parameter": "b1TimeToTriggerRsrq",
        "value": "256ms",
    },
    {
        "dist_name": "MRBTS-816/LNBTS-8161/LNCEL-1/LNHON-0",
        "parameter": "b1TriggerQuantity",
        "value": "RSRP",
    },
    {
        "dist_name": "MRBTS-816/LNBTS-8161/LNCEL-1/LNHON-0",
        "parameter": "b2NrBeamReportQuantity",
        "value": "None",
    },
    {
        "dist_name": "MRBTS-816/LNBTS-8161/LNCEL-1/LNHON-0",
        "parameter": "b2NrCellReportQuantity",
        "value": "RSRP",
    },
    {
        "dist_name": "MRBTS-816/LNBTS-8161/LNCEL-1/LNHON-0",
        "parameter": "b2NrReportIntervalRsrp",
        "value": "480ms",
    },
    {
        "dist_name": "MRBTS-816/LNBTS-8161/LNCEL-1/LNHON-0",
        "parameter": "b2NrTimeToTriggerRsrpMeas",
        "value": "320ms",
    },
    {
        "dist_name": "MRBTS-816/LNBTS-8161/LNCEL-1/LNHON-0",
        "parameter": "b2Threshold1RsrpNr",
        "value": "40",
    },
    {
        "dist_name": "MRBTS-816/LNBTS-8161/LNCEL-1/LNHON-0",
        "parameter": "b2Threshold2RsrpNr",
        "value": "66",
    },
    {
        "dist_name": "MRBTS-816/LNBTS-8161/LNCEL-1/LNHON-0",
        "parameter": "carrierFreqNr",
        "value": "520110",
    },
    {
        "dist_name": "MRBTS-816/LNBTS-8161/LNCEL-1/LNHON-0",
        "parameter": "hysB2NrThresholdRsrp",
        "value": "4",
    },
    {
        "dist_name": "MRBTS-816/LNBTS-8161/LNCEL-1/LNHON-0",
        "parameter": "nrCarPrio5GSACapMobility",
        "value": "64",
    },
    {
        "dist_name": "MRBTS-816/LNBTS-8161/LNCEL-1/LNHON-0",
        "parameter": "nrPciHoNbrCounterDecay",
        "value": "1000",
    },
    {
        "dist_name": "MRBTS-816/LNBTS-8161/LNCEL-1/LNHON-0",
        "parameter": "nrPciHoNbrRelAddThresh",
        "value": "2",
    },
    {
        "dist_name": "MRBTS-816/LNBTS-8161/LNCEL-1/LNHON-0",
        "parameter": "nrPciHoNbrRelRemThresh",
        "value": "100000",
    },
    {
        "dist_name": "MRBTS-816/LNBTS-8161/LNCEL-1/LNHON-0",
        "parameter": "nrQuantityConfigSetId",
        "value": "1",
    },
    {
        "dist_name": "MRBTS-816/LNBTS-8161/LNCEL-1/LNHON-0",
        "parameter": "offsetFreqNr",
        "value": "0",
    },
    {
        "dist_name": "MRBTS-816/LNBTS-8161/LNCEL-1/LNHON-0",
        "parameter": "ssbDuration",
        "value": "sf1",
    },
    {
        "dist_name": "MRBTS-816/LNBTS-8161/LNCEL-1/LNHON-0",
        "parameter": "ssbOffset",
        "value": "0",
    },
    {
        "dist_name": "MRBTS-816/LNBTS-8161/LNCEL-1/LNHON-0",
        "parameter": "ssbPeriodicity",
        "value": "sf20-r15",
    },
    {
        "dist_name": "MRBTS-816/LNBTS-8161/LNCEL-1/LNHON-0",
        "parameter": "ssbSubcarrierSpacing",
        "value": "30kHz",
    },
    {
        "dist_name": "MRBTS-816/LNBTS-8161/LNCEL-1/LNHON-0",
        "parameter": "freqBandIndicatorListNr",
        "value": ["41"],
    },
    # {
    #     "dist_name": "MRBTS-816/LNBTS-8161/LNADJN-2",
    #     "parameter": "arfcnValueNR",
    #     "value": "520110",
    # },
    # {
    #     "dist_name": "MRBTS-816/LNBTS-8161/LNADJN-2",
    #     "parameter": "physCellIdNr",
    #     "value": "302",
    # },
    # {
    #     "dist_name": "MRBTS-816/LNBTS-8161/LNADJN-2",
    #     "parameter": "multiFrequencyBandList",
    #     "value": ["41"],
    # },
    # {
    #     "dist_name": "MRBTS-816/LNBTS-8161/LNADJN-2/LNADJNL-0",
    #     "parameter": "cellIdentity",
    #     "value": "3342638",
    # },
    # {
    #     "dist_name": "MRBTS-816/LNBTS-8161/LNADJN-2/LNADJNL-0",
    #     "parameter": "gnbIdLength",
    #     "value": "24",
    # },
    # {
    #     "dist_name": "MRBTS-816/LNBTS-8161/LNADJN-2/LNADJNL-0",
    #     "parameter": "trackingAreaCodeNR",
    #     "value": "20310",
    # },
    # {
    #     "dist_name": "MRBTS-816/LNBTS-8161/LNADJN-2/LNADJNL-0",
    #     "parameter": "gNBplmnId",
    #     "value": [
    #         {"mcc": "310", "mnc": "260", "mncLength": "3"},
    #     ],
    # },
    # {
    #     "dist_name": "MRBTS-816/LNBTS-8161/LNADJN-2/LNADJNL-0",
    #     "parameter": "plmnIdList",
    #     "value": [
    #         {"mcc": "310", "mnc": "260", "mncLength": "3"},
    #     ],
    # },
    # {
    #     "dist_name": "MRBTS-816/LNBTS-8161/LNCEL-1/LNRELN-1",
    #     "parameter": "cellIdentity",
    #     "value": "3342638",
    # },
    # {
    #     "dist_name": "MRBTS-816/LNBTS-8161/LNCEL-1/LNRELN-1",
    #     "parameter": "psHoAllowed",
    #     "value": "allowed",
    # },
    # {
    #     "dist_name": "MRBTS-816/LNBTS-8161/LNCEL-1/LNRELN-1",
    #     "parameter": "removeAllowed",
    #     "value": "true",
    # },
    # {
    #     "dist_name": "MRBTS-816/LNBTS-8161/LNCEL-1/LNRELN-1",
    #     "parameter": "plmnId",
    #     "value": [
    #         {"mcc": "310", "mnc": "260", "mncLength": "3"},
    #     ],
    # },
    {
        "dist_name": "MRBTS-816/LNBTS-8161/MOPR-1",
        "parameter": "bypassBuffTrigEnDc",
        "value": "disabled",
    },
    {
        "dist_name": "MRBTS-816/LNBTS-8161/MOPR-1",
        "parameter": "caBlockingAllowed",
        "value": "forbidden",
    },
    {
        "dist_name": "MRBTS-816/LNBTS-8161/MOPR-1",
        "parameter": "configUeCapEndcHoRetry",
        "value": "noRetries",
    },
    {
        "dist_name": "MRBTS-816/LNBTS-8161/MOPR-1",
        "parameter": "enDcBlockingAllowed",
        "value": "forbidden",
    },
    {
        "dist_name": "MRBTS-816/LNBTS-8161/MOPR-1",
        "parameter": "idleLBPercCaUe",
        "value": "0",
    },
    {
        "dist_name": "MRBTS-816/LNBTS-8161/MOPR-1",
        "parameter": "idleLBPercUeTM9",
        "value": "0",
    },
    {
        "dist_name": "MRBTS-816/LNBTS-8161/MOPR-1",
        "parameter": "idleLBPercentageOfUes",
        "value": "0",
    },
    {
        "dist_name": "MRBTS-816/LNBTS-8161/MOPR-1",
        "parameter": "targetSelMethod",
        "value": "SIB_based",
    },
    {
        "dist_name": "MRBTS-816/LNBTS-8161/MOPR-1",
        "parameter": "timeBlockLowPrioHoAtHo",
        "value": "0",
    },
    {
        "dist_name": "MRBTS-816/LNBTS-8161/MOPR-1",
        "parameter": "freqLayListNrServBasedHoQciX",
        "value": ["520110"],
    },
    {
        "dist_name": "MRBTS-816/LNBTS-8161/MOPR-1",
        "parameter": "freqLayListPsHoNR",
        "value": ["520110"],
    },
]

CNI_145514_object_added = [
    {
        "dist_name": "MRBTS-816/LNBTS-8161/LNCEL-1/LNHON-0",
        "parameter": "b1HysThresholdRsrp",
        "value": "0",
    },
    {
        "dist_name": "MRBTS-816/LNBTS-8161/LNCEL-1/LNHON-0",
        "parameter": "b1NrBeamReportQuantity",
        "value": "None",
    },
    {
        "dist_name": "MRBTS-816/LNBTS-8161/LNCEL-1/LNHON-0",
        "parameter": "b1NrPciHoNbrCounterDecay",
        "value": "1000",
    },
    {
        "dist_name": "MRBTS-816/LNBTS-8161/LNCEL-1/LNHON-0",
        "parameter": "b1NrPciHoNbrRelAddThresh",
        "value": "2",
    },
    {
        "dist_name": "MRBTS-816/LNBTS-8161/LNCEL-1/LNHON-0",
        "parameter": "b1NrPciHoNbrRelRemThresh",
        "value": "100000",
    },
    {
        "dist_name": "MRBTS-816/LNBTS-8161/LNCEL-1/LNHON-0",
        "parameter": "b1ReportAmount",
        "value": "r1",
    },
    {
        "dist_name": "MRBTS-816/LNBTS-8161/LNCEL-1/LNHON-0",
        "parameter": "b1ReportInterval",
        "value": "120ms",
    },
    {
        "dist_name": "MRBTS-816/LNBTS-8161/LNCEL-1/LNHON-0",
        "parameter": "b1ThresholdRsrp",
        "value": "86",
    },
    {
        "dist_name": "MRBTS-816/LNBTS-8161/LNCEL-1/LNHON-0",
        "parameter": "b1TimeToTriggerRsrp",
        "value": "256ms",
    },
    {
        "dist_name": "MRBTS-816/LNBTS-8161/LNCEL-1/LNHON-0",
        "parameter": "b1TimeToTriggerRsrq",
        "value": "256ms",
    },
    {
        "dist_name": "MRBTS-816/LNBTS-8161/LNCEL-1/LNHON-0",
        "parameter": "b1TriggerQuantity",
        "value": "RSRP",
    },
    {
        "dist_name": "MRBTS-816/LNBTS-8161/LNCEL-1/LNHON-0",
        "parameter": "b2NrBeamReportQuantity",
        "value": "None",
    },
    {
        "dist_name": "MRBTS-816/LNBTS-8161/LNCEL-1/LNHON-0",
        "parameter": "b2NrCellReportQuantity",
        "value": "RSRP",
    },
    {
        "dist_name": "MRBTS-816/LNBTS-8161/LNCEL-1/LNHON-0",
        "parameter": "b2NrReportIntervalRsrp",
        "value": "480ms",
    },
    {
        "dist_name": "MRBTS-816/LNBTS-8161/LNCEL-1/LNHON-0",
        "parameter": "b2NrTimeToTriggerRsrpMeas",
        "value": "320ms",
    },
    {
        "dist_name": "MRBTS-816/LNBTS-8161/LNCEL-1/LNHON-0",
        "parameter": "b2Threshold1RsrpNr",
        "value": "40",
    },
    {
        "dist_name": "MRBTS-816/LNBTS-8161/LNCEL-1/LNHON-0",
        "parameter": "b2Threshold2RsrpNr",
        "value": "66",
    },
    {
        "dist_name": "MRBTS-816/LNBTS-8161/LNCEL-1/LNHON-0",
        "parameter": "carrierFreqNr",
        "value": "520110",
    },
    {
        "dist_name": "MRBTS-816/LNBTS-8161/LNCEL-1/LNHON-0",
        "parameter": "hysB2NrThresholdRsrp",
        "value": "4",
    },
    {
        "dist_name": "MRBTS-816/LNBTS-8161/LNCEL-1/LNHON-0",
        "parameter": "nrCarPrio5GSACapMobility",
        "value": "64",
    },
    {
        "dist_name": "MRBTS-816/LNBTS-8161/LNCEL-1/LNHON-0",
        "parameter": "nrPciHoNbrCounterDecay",
        "value": "1000",
    },
    {
        "dist_name": "MRBTS-816/LNBTS-8161/LNCEL-1/LNHON-0",
        "parameter": "nrPciHoNbrRelAddThresh",
        "value": "2",
    },
    {
        "dist_name": "MRBTS-816/LNBTS-8161/LNCEL-1/LNHON-0",
        "parameter": "nrPciHoNbrRelRemThresh",
        "value": "100000",
    },
    {
        "dist_name": "MRBTS-816/LNBTS-8161/LNCEL-1/LNHON-0",
        "parameter": "nrQuantityConfigSetId",
        "value": "1",
    },
    {
        "dist_name": "MRBTS-816/LNBTS-8161/LNCEL-1/LNHON-0",
        "parameter": "offsetFreqNr",
        "value": "0",
    },
    {
        "dist_name": "MRBTS-816/LNBTS-8161/LNCEL-1/LNHON-0",
        "parameter": "ssbDuration",
        "value": "sf1",
    },
    {
        "dist_name": "MRBTS-816/LNBTS-8161/LNCEL-1/LNHON-0",
        "parameter": "ssbOffset",
        "value": "0",
    },
    {
        "dist_name": "MRBTS-816/LNBTS-8161/LNCEL-1/LNHON-0",
        "parameter": "ssbPeriodicity",
        "value": "sf20-r15",
    },
    {
        "dist_name": "MRBTS-816/LNBTS-8161/LNCEL-1/LNHON-0",
        "parameter": "ssbSubcarrierSpacing",
        "value": "30kHz",
    },
    {
        "dist_name": "MRBTS-816/LNBTS-8161/LNCEL-1/LNHON-0",
        "parameter": "freqBandIndicatorListNr",
        "value": ["41"],
    },
    {
        "dist_name": "MRBTS-816/LNBTS-8161/LNCEL-1/REDRT-2",
        "parameter": "addGsmSIToRedirMsg",
        "value": "both",
    },
    {
        "dist_name": "MRBTS-816/LNBTS-8161/LNCEL-1/REDRT-2",
        "parameter": "addUtranSIToRedirMsg",
        "value": "both",
    },
    {
        "dist_name": "MRBTS-816/LNBTS-8161/LNCEL-1/REDRT-2",
        "parameter": "redirRat",
        "value": "nr",
    },
    {
        "dist_name": "MRBTS-816/LNBTS-8161/LNCEL-1/REDRT-2",
        "parameter": "redirectPrio",
        "value": "1",
    },
    {
        "dist_name": "MRBTS-816/LNBTS-8161/LNCEL-1/REDRT-2",
        "parameter": "redirNrCarFrq",
        "value": [
            {
                "carrierFreqNrCell": "520110",
                "ssbDuration": "sf1",
                "ssbOffset": "0",
                "ssbPeriodicity": "sf20",
                "ssbSubcarrierSpacing": "30kHz",
            },
        ],
    },
]

CNI_145514_params_update = [
    {
        "dist_name": "MRBTS-816/NRBTS-816",
        "parameter": "srbInactivityTimerSA",
        "value": "600",
    },
    {
        "dist_name": "MRBTS-816/NRBTS-816",
        "parameter": "drbInactivityTimerSA",
        "value": "600",
    },
    {
        "dist_name": "MRBTS-816/LNBTS-8161",
        "parameter": "actDynTrigLteNrDualConnectivity",
        "value": "true",
    },
    {
        "dist_name": "MRBTS-816/LNBTS-8161/LNMME-0",
        "parameter": "ipAddrPrim",
        "value": "10.70.255.38",
    },
    {
        "dist_name": "MRBTS-816/LNBTS-8161/LNCEL-1",
        "parameter": "tac",
        "value": "20310",
    },
    {
        "dist_name": "MRBTS-816/LNBTS-8161/LNCEL-1",
        "parameter": "actPeriodicB1NRMeas",
        "value": "enhanced",
    },
    {
        "dist_name": "MRBTS-816/LNBTS-8161/LNCEL-1",
        "parameter": "actNrServBasedHoQciX",
        "value": "false",
    },
    {
        "dist_name": "MRBTS-816/LNBTS-8161/LNCEL-2",
        "parameter": "actNrServBasedHoQciX",
        "value": "false",
    },
    {
        "dist_name": "MRBTS-816/LNBTS-8161/LNCEL-3",
        "parameter": "actNrServBasedHoQciX",
        "value": "false",
    },
    {
        "dist_name": "MRBTS-816/NRBTS-816/NRCELL-302/NRPLMNSET_NSA-1",
        "parameter": "configuredEpsTac",
        "value": "20310",
    },
    {
        "dist_name": "MRBTS-816/NRBTS-816/NRCELL-302/NRPLMNSET_NSA-1",
        "parameter": "configuredEpsTac",
        "value": "20310",
    },
    {
        "dist_name": "MRBTS-816/LNBTS-8161/MODPR-0",
        "parameter": "autoAdapt",
        "value": "false",
    },
    {
        "dist_name": "MRBTS-816/LNBTS-8161/MODPR-0",
        "parameter": "autoAdaptIMLB",
        "value": "false",
    },
    {
        "dist_name": "MRBTS-816/LNBTS-8161/NRDCDPR-0/ENDCDMEASCONF-1",
        "parameter": "b1ThresholdNrRsrp",
        "value": "76",
    },
    {
        "dist_name": "MRBTS-816/LNBTS-8161/NRDCDPR-0/ENDCDMEASCONF-3",
        "parameter": "b1ThresholdNrRsrp",
        "value": "116",
    },
    {
        "dist_name": "MRBTS-816/LNBTS-8161/NRDCDPR-0/ENDCDMEASCONF-4",
        "parameter": "b1ThresholdNrRsrp",
        "value": "116",
    },
    {
        "dist_name": "MRBTS-816/LNBTS-8161/NRDCDPR-0/ENDCDMEASCONF-0",
        "parameter": "b1ThresholdNrRsrp",
        "value": "116",
    },
    {
        "dist_name": "MRBTS-816/LNBTS-8161/NRDCDPR-0/ENDCDMEASCONF-2",
        "parameter": "b1ThresholdNrRsrp",
        "value": "116",
    },
    {
        "dist_name": "MRBTS-816/LNBTS-8161/NRDCDPR-0",
        "parameter": "dynTriggerLteNrDcConfList",
        "value": [
            {"method": "coverageAndBufferBased", "lcrId": "1"},
        ],
    },
    {
        "dist_name": "MRBTS-816/LNBTS-8161/LNBTS_FDD-0",
        "parameter": "numTxWithHighNonGbr",
        "value": "1",
    },
    {
        "dist_name": "MRBTS-816/LNBTS-8161/LNBTS_TDD-0",
        "parameter": "numTxWithHighNonGbr",
        "value": "1",
    },
    {
        "dist_name": "MRBTS-816/LNBTS-8161/LNCEL-1/SIB-0",
        "parameter": "cellBarred",
        "value": "notBarred",
    },
    {
        "dist_name": "MRBTS-816/NRBTS-816/NRCELL-302",
        "parameter": "cellBarred",
        "value": "notBarred",
    },
]

CB012474_params_update = [
    {
        "dist_name": "MRBTS-{}/NRBTS-{}".format(mrbts_id, nrbts_id),
        "parameter": "actEnDcCuReattempt",
        "value": "true",
    },
    {
        "dist_name": "MRBTS-{}/NRBTS-{}/NRPMRNL-1".format(mrbts_id, nrbts_id),
        "parameter": "miNrX2CB",
        "value": "5min",
    },
]

CB012474_param_added = [
    {
        "dist_name": "MRBTS-{}/NRBTS-{}".format(mrbts_id, nrbts_id),
        "parameter": "enDcCuReattemptTmr",
        "value": "5",
    },
    {
        "dist_name": "MRBTS-{}/NRBTS-{}".format(mrbts_id, nrbts_id),
        "parameter": "maxEnDcCuReattempt",
        "value": "3",
    },
]

CB007334_params_update = [
    {
        "dist_name": "MRBTS-816/LNBTS-8161/ANR-0",
        "parameter": "anrNrNbrRelRemGuardTime",
        "value": "10",
    },
    {
        "dist_name": "MRBTS-816/LNBTS-8161/NRDCDPR-0/ENDCDMEASCONF-1",
        "parameter": "b1ThresholdNrRsrp",
        "value": "76",
    },
    {
        "dist_name": "MRBTS-816/LNBTS-8161/NRDCDPR-0/ENDCDMEASCONF-3",
        "parameter": "b1ThresholdNrRsrp",
        "value": "116",
    },
    {
        "dist_name": "MRBTS-816/LNBTS-8161/NRDCDPR-0/ENDCDMEASCONF-4",
        "parameter": "b1ThresholdNrRsrp",
        "value": "116",
    },
    {
        "dist_name": "MRBTS-816/LNBTS-8161/NRDCDPR-0/ENDCDMEASCONF-0",
        "parameter": "b1ThresholdNrRsrp",
        "value": "116",
    },
    {
        "dist_name": "MRBTS-816/LNBTS-8161/NRDCDPR-0/ENDCDMEASCONF-2",
        "parameter": "b1ThresholdNrRsrp",
        "value": "116",
    },
    {
        "dist_name": "MRBTS-816/LNBTS-8161/NRDCDPR-0/ENDCDMEASCONF-1",
        "parameter": "nrPciNbrRelAddThresh",
        "value": "4",
    },
    {
        "dist_name": "MRBTS-816/LNBTS-8161/NRDCDPR-0/ENDCDMEASCONF-1",
        "parameter": "nrPciNbrRelRemThresh",
        "value": "300000",
    },
    {
        "dist_name": "MRBTS-816/LNBTS-8161/NRDCDPR-0/ENDCDMEASCONF-1",
        "parameter": "nrPciNbrRelAddHyst",
        "value": "0",
    },
    {
        "dist_name": "MRBTS-816/LNBTS-8161/LNCEL-1/SIB-0",
        "parameter": "cellBarred",
        "value": "notBarred",
    },
    {
        "dist_name": "MRBTS-816/NRBTS-816",
        "parameter": "srbInactivityTimerSA",
        "value": "60",
    },
    {
        "dist_name": "MRBTS-816/NRBTS-816",
        "parameter": "drbInactivityTimerSA",
        "value": "60",
    },
    {
        "dist_name": "MRBTS-816/LNBTS-8161/LNADJGNB-2",
        "parameter": "cPlaneIpAddrCtrl",
        "value": "enbControlled",
    },
    {
        "dist_name": "MRBTS-816/LNBTS-8161/LNCEL-1",
        "parameter": "defaultLnRelGnbCellId",
        "value": "2",
    },
    {
        "dist_name": "MRBTS-816/LNBTS-8161/LNCEL-2",
        "parameter": "actNrServBasedHoQciX",
        "value": "false",
    },
    {
        "dist_name": "MRBTS-816/LNBTS-8161/LNCEL-3",
        "parameter": "actNrServBasedHoQciX",
        "value": "false",
    },
    {
        "dist_name": "MRBTS-816/LNBTS-8161/NRDCDPR-0",
        "parameter": "dynTriggerLteNrDcConfList",
        "value": [
            {"lcrId": "1"},
        ],
    },
]

CB007334_delete_params = [
    {"dist_name": "LNBTS-8161/LNCEL-1/LNRELGNBCELL-0"},
    {"dist_name": "LNBTS-8161/LNCEL-1/LNRELGNBCELL-1"},
]

CB007334_delete_params_anr = [
    {"dist_name": "LNBTS-8161/LNCEL-1/LNRELGNBCELL-254"},
]

CB007334_Change_Cell_lock_status = [
    {
        "dist_name": "MRBTS-816/LNBTS-8161/LNCEL-1",
        "parameter": "administrativeState",
        "value": "locked",
    },
    {
        "dist_name": "MRBTS-816/NRBTS-816/NRCELL-301",
        "parameter": "administrativeState",
        "value": "Locked",
    },
    {
        "dist_name": "MRBTS-816/NRBTS-816/NRCELL-302",
        "parameter": "administrativeState",
        "value": "Locked",
    },
]


CB007334_Change_Cell_Unlock_status = [
    {
        "dist_name": "MRBTS-816/LNBTS-8161/LNCEL-1",
        "parameter": "administrativeState",
        "value": "unlocked",
    },
    {
        "dist_name": "MRBTS-816/NRBTS-816/NRCELL-301",
        "parameter": "administrativeState",
        "value": "Unlocked",
    },
    {
        "dist_name": "MRBTS-816/NRBTS-816/NRCELL-302",
        "parameter": "administrativeState",
        "value": "Unlocked",
    },
]
