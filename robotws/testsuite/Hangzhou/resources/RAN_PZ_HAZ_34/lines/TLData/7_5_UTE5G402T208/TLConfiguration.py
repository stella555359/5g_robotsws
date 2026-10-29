import os

__team__ = "MN 5G RAN I&V 4 Pz HZG SG1"
__email__ = "I_MN_5G_RAN_IV4_LINE_HZG_1@internal.nsn.com"

TestLineID = "7_5_UTE5G402T208"
TL_BASE_SCF_NR_10M = "SCF_SBTS00_NR_10M.xml"
TL_BASE_SCF_NR_5M = "SCF_SBTS00_NR_5M.xml"
TL_BASE_SCF_LTE_10M = "SCF_SBTS00_LTE_10M.xml"
TL_BASE_SCF_LTE_5M = "SCF_SBTS00_LTE_5M.xml"
TL_BASE_SCF_DSS = "SCF_SBTS00_DSS.xml"

TCCB008445_TC66 = {
    "LTE_cell_id_list": "1",
    "ru_index": "1",
    "ru_type": "AWHKB",
    "host_addr": "10.68.88.16",
    "Ping from GNB container to RU_IP": "ping 172.16.73.128 -c 3600 -i 1",
    "ru_product_code": "476086A.X21",
    "ru_serial_number": "EB2201R0199",
}

TLCommonConfig = {
    "MultiUECFG": {
        "0": {
            "target_avg_percent": "0.8",
            "dl": {"target_throughput": "5M", "duration": "300"},
            "ul": {"target_throughput": "5M", "duration": "300"},
            "internal_ip": "192.168.10.70",
            "power_cycle_script_path": "C:/ViViPowerReset/ViViPowerReset.py",
            "dial_connection": "Broadband Connection",
            "dial_username": "tm500",
            "dial_password": "tm500",
            "app_ta_port": "5030",
            "app_path": "/cygdrive/c/Program Files (x86)/VIAVI/TM500/5G NR - NLA 5.16.0/Test Mobile Application/TMA",
            "script_path": "ViViScript/",
            "ASCMappingPort": "10000",
            "group": "Units-1",
        },
        "ue_index_for_call": ["0"],
    },
    "PAGroups": {
        "1": {
            "ports": [
                {"port_id": 1, "default_value": 15},
                {"port_id": 2, "default_value": 40},
                {"port_id": 3, "default_value": 40},
                {"port_id": 4, "default_value": 15},
                {"port_id": 5, "default_value": 40},
                {"port_id": 6, "default_value": 40},
                {"port_id": 7, "default_value": 40},
                {"port_id": 8, "default_value": 40},
            ]
        },
        "2": {
            "ports": [
                {"port_id": 1, "default_value": 15},
                {"port_id": 2, "default_value": 28},
                {"port_id": 3, "default_value": 28},
                {"port_id": 4, "default_value": 15},
                {"port_id": 5, "default_value": 40},
                {"port_id": 6, "default_value": 40},
                {"port_id": 7, "default_value": 40},
                {"port_id": 8, "default_value": 40},
            ]
        },
    },
}
