import os

__team__ = "MN 5G RAN I&V 4 Pz HZG SG1"
__email__ = "I_MN_5G_RAN_IV4_LINE_HZG_1@internal.nsn.com"


TL_BASE_SCF_NR = "SCF_SBTS00_NR_20MHz.xml"
TL_BASE_SCF_NR_2CC_40MHz_100MHz = "SCF_SBTS00_NR_2CC_40MHz_100MHz.xml"
TL_BASE_SCF_NR_2CC_20MHz_40MHz = "SCF_SBTS00_NR_2CC_20MHz_40MHz.xml"
TL_BASE_SCF_NR_2CC_20MHz_40MHz_Cell2 = "SCF_SBTS00_NR_2CC_20MHz_40MHz_Cell2.xml"
TL_BASE_SCF_NR_9218_A2_40MHz = "SCF_SBTS00_NR_1CC_9218_A2_40MHz.xml"

TL_BASE_SCF_LTE = "SCF_SBTS00_LTE.xml"
TL_BASE_SCF_LTE_2CC_20MHz_20MHz = "SCF_SBTS00_LTE_2CC_20MHz_20MHz.xml"


CASE_INPUT_SISO = {
    "SISOCommon": {
        "cell_type": "lte",  # nr or lte
        "release": "SBTS23R2",  # release of software
    },
    # parameter of case "BS-RF__LTE_Transmitted_carrier_power_min_max_allowed_power"
    "Pmax": {"start": "23", "count": 2, "isCBRS": "true"},  # true or false

    # parameter of CBRS
    "CBSD": {
        "TS1": {
            "server": "10.71.218.130:4438",
            "version": "version 1.2",
            "path": "/cygdrive/c/sasserver/",
        },
        "TS2": {
            "server": "10.71.218.130:4438",
            "version": "version 1.2",
            "path": "/cygdrive/c/sasserver/",
        },
        "SAS_Sim": {
            "server": "10.101.60.109",
            "username": "ute",
            "password": "iW_K#8.ute%A10h0m0ra",
        },
    },
    # "ru_index": "1",
    # "ru_type": "AWPQZ",
    # "host_addr": "10.68.88.16",
    # "Ping from GNB container to RU_IP": "ping 172.16.73.128 -c 3600 -i 1",
    # "ru_product_code": "476086A.X21",
    # "ru_serial_number": "EB2201R0199",
}

TLCommonConfig = {
    "MultiUECFG": {
        "0": {
            "ue_mode": "LTE",
            "apn": "dxdata1.mnc002.mcc460.gprs",
            "iperf_port": "default",
            "multidrb_QoS_dest": None,
            "iperf_type": "via_app",
            "target_avg_percent": "0.8",
            "cell_index_list": ["1"],
            "dl": {"target_throughput": "5", "duration": "300"},
            "ul": {"target_throughput": "5", "duration": "300"},
            "detach_request": True,
            "power_reset": "true",
            "target_percent": "0.95",
            "check_tput_on_ue": "true",
            "reset_sol": "none",
            "attach_mode": "5G_SA",
            "dt_name": "DT_1",
            "protocol": "udp",
            "connection_type": "app",
        },
        "ue_index_for_call": ["0"],
    },
}
