import os

__team__ = "MN 5G RAN I&V 4 Pz HZG SG1"
__email__ = "I_MN_5G_RAN_IV4_LINE_HZG_1@internal.nsn.com"

TestLineID = "7_5_UTE5G402T2202"
TL_BASE_SCF_NR = "TL_BASE_SCF_NR_2CC_40MHz_100MHz.xml"
TL_BASE_SCF_NR_2CC_40MHz_100MHz = "TL_BASE_SCF_NR_2CC_40MHz_100MHz.xml"
TL_BASE_SCF_NR_2CC_20MHz_40MHz = "TL_BASE_SCF_NR_2CC_20MHz_40MHz.xml"
TL_BASE_SCF_NR_2CC_20MHz_40MHz_Cell2 = "TL_BASE_SCF_NR_2CC_20MHz_40MHz_Cell2.xml"
TL_BASE_SCF_NR_2CC_20MHz_20MHz = "TL_BASE_SCF_NR_2CC_20MHz_20MHz.xml"
TL_BASE_SCF_NR_2CC_40MHz_40MHz = "TL_BASE_SCF_NR_2CC_40MHz_40MHz.xml"
TL_BASE_SCF_NR_9218_A2_40MHz = "SCF_SBTS00_NR_1CC_9218_A2_40MHz.xml"
TL_BASE_SCF_NR_2CC_40MHz_100MHz_spacing0 = ""

# TL_BASE_SCF_LTE = "SCF_SBTS00_LTE_2CC_20M+20M.xml"
# TL_BASE_SCF_LTE_10MHz = "SCF_SBTS00_LTE_10MHz.xml"


CASE_INPUT_SISO = {
    "SISOCommon": {
        "cell_type": "nr",  # nr or lte
        "release": "SBTS23R2",  # release of software
    },
    # parameter of case "BS-RF__LTE_Transmitted_carrier_power_min_max_allowed_power"
    "Pmax": {"start": "23", "count": 2, "isCBRS": "true"},  # true or false

    # parameter of CBRS
    "CBSD": {
        "TS1": {
            "server": "10.71.218.94:4438",
            "version": "version 1.2",
            "path": "/cygdrive/c/sasserver/",
        },
        "TS2": {
            "server": "10.71.218.94:4438",
            "version": "version 1.2",
            "path": "/cygdrive/c/sasserver/",
        },
        "SAS_Sim": {
            "server": "10.101.60.108",
            "username": "ute",
            "password": "iW_K#8.ute%A10h0m0ra",
        },
    },
}


# CASE_INPUT_CB008712 = {
#     "Pmax": {
#         "start": "20",
#         "count": 2,
#     },
#     "CBSD": {
#         "TS1": {
#             "server": "10.71.218.94:4438",
#             "version": "version 1.2",
#             "path": "/cygdrive/c/SASSim_0906/",
#         },
#         "TS2": {
#             "server": "10.71.218.94:4438",
#             "version": "version 1.2",
#             "path": "/cygdrive/c/SASSim_0906/",
#         },
#     },
#     "ru_index": "1",
#     "ru_type": "AWPQZ",
#     "host_addr": "10.71.215.103",
#     "Ping from GNB container to RU_IP": "ping 172.22.0.2 -c 3600 -i 1",
#     "ru_product_code": "476101A.X21",
#     "ru_serial_number": "EB2234R0644",
#
#     "system_moudle_pdu_vernder": "HBTE",
#     "system_moudle_pdu_addr": "10.71.197.56",
#     "system_moudle_pdu_port": 5,
#     "release": "SBTS23R1",
# }

TLCommonConfig = {
    "MultiUECFG": {
        "0": {
            "ue_mode": "SA",
            "apn": "dxdata2",
            "iperf_port": "default",
            "multidrb_QoS_dest": None,
            "iperf_type": "via_app",
            "target_avg_percent": "0.8",
            "dl": {"target_throughput": "5", "duration": "300"},
            "ul": {"target_throughput": "5", "duration": "300"},
            # spark ue
            "detach_request": True,
            "power_reset": "true",
            # multi ue args
            "target_percent": "0.95",
            "reset_sol": "none",
            "attach_mode": "5G_SA",
            "dt_name": "DT_1",
            "protocol": "udp",
            "connection_type": "app",

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
    },
}
