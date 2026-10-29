import os

__team__ = "MN 5G RAN I&V 4 Pz HZG SG1"
__email__ = "I_MN_5G_RAN_IV4_LINE_HZG_1@internal.nsn.com"
TL_BASE_SCF_LTE_10M = "SCF_LTE_1CC.xml"
TL_BASE_SCF_NR_10M = "SCF_SBTS00_NR_10M.xml"
casescf = "SCF_SBTS00_NR_2CC.xml"

TCCB008445_TC66 = {
    "LTE_cell_id_list": "11",
    "ru_index": "1",
    "ru_type": "AWHKB",
    "Ping from GNB container to RU_IP": "ping 172.16.73.128 -c 3600 -i 1",
    "ru_product_code": "476086A.X21",
    "ru_serial_number": "EB2201R0201",
}

TLCommonConfig = {
    "MultiUECFG": {
        "0": {
            "target_avg_percent": "0.8",
            "dl": {"target_throughput": "5M", "duration": "120"},
            "ul": {"target_throughput": "5M", "duration": "120"},
            "internal_ip": "192.168.10.70",
            "power_cycle_script_path": "C:/ViViPowerReset/ViViPowerReset.py",
            "dial_connection": "Broadband Connection",
            "dial_username": "tm500",
            "dial_password": "tm500",
            "app_ta_port": "5030",
            "app_path": "/cygdrive/c/Program Files (x86)/Aeroflex/TM500/LTE - LMF 10.20.0/Test Mobile Application/TMA",
            "script_path": "ViViScript/",
            "ASCMappingPort": "10000",
            "group": "AllUnitsPresent",
        },
        "ue_index_for_call": ["0"],
    },
}
