import os

__team__ = "MN 5G RAN I&V 4 Pz HZG SG1"
__email__ = "I_MN_5G_RAN_IV4_LINE_HZG_1@internal.nsn.com"

# TestLineID = "7_5_UTE5G402T2205"
TL_BASE_SCF_NR = "SCF_SBTS00_NR.xml"
TL_BASE_SCF_LTE = "SCF_SBTS00_LTE.xml"

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
            "server": "10.71.218.96:4438",
            "version": "version 1.2",
            "path": "/cygdrive/c/sasserver/",
        },
        "TS2": {
            "server": "10.71.218.96:4438",
            "version": "version 1.2",
            "path": "/cygdrive/c/sasserver/",
        },
    },
}


# CASE_INPUT_CB008712 = {
#     # "Pmax": {
#     #     "start": "23",
#     #     "count": 2,
#     # },
#     "CBSD": {
#         "TS1": {
#             "server": "10.71.206.164:4438",
#             "version": "version 1.2",
#             "path": "/cygdrive/c/sasserver/",
#         },
#         "TS2": {
#             "server": "10.71.206.164:4438",
#             "version": "version 1.2",
#             "path": "/cygdrive/c/sasserver/",
#         },
#     },
#     "ru_index": "1",
#     "ru_type": "AWHQX",
#     "system_moudle_pdu_vernder": "HBTE",
#     "system_moudle_pdu_addr": "10.71.197.57",
#     "system_moudle_pdu_port": 3,
#     # "host_addr": "10.68.88.16",
#     # "Ping from GNB container to RU_IP": "ping 172.16.73.128 -c 3600 -i 1",
#     # "ru_product_code": "476086A.X21",
#     # "ru_serial_number": "EB2201R0199",
# }

TLCommonConfig = {
    "MultiUECFG": {
        "0": {
            "ue_mode": "LTE",
            "apn": "dxdata1.mnc002.mcc460.gprs",
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
            "check_tput_on_ue": "true",
            "reset_sol": "none",
            "attach_mode": "5G_SA",
            "dt_name": "DT_1",
            "protocol": "udp",
            "connection_type": "app",

        },
        "ue_index_for_call": ["0"],
    },
    # "PAGroups": {
    #     "1": {
    #         "ports": [
    #             {"port_id": 1, "default_value": 15},
    #             {"port_id": 2, "default_value": 40},
    #             {"port_id": 3, "default_value": 40},
    #             {"port_id": 4, "default_value": 15},
    #             {"port_id": 5, "default_value": 40},
    #             {"port_id": 6, "default_value": 40},
    #             {"port_id": 7, "default_value": 40},
    #             {"port_id": 8, "default_value": 40},
    #         ]
    #     },
    # },
}
