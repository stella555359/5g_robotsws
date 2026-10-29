import os

__team__ = "MN 5G RAN I&V 4 Pz HZG SG1"
__email__ = "I_MN_5G_RAN_IV4_LINE_HZG_1@internal.nsn.com"

GoldenSCF_ON_GIT = "/home/ute/MN/UTE/robotws//commissionings/HGZ/7_5_UTE5G402T211/"
GoldenSCF = "SCF_SBTS00.xml"
TestLineID = "7_5_UTE402T211"
prefix_of_release = "5G_"

STREAM_INFOs = {
    "SBTS00_ENB_9999": {"StreamPrefix": "SBTSTRUNK", "GoldenSCF": "/SCF_SBTS00.xml"},
    "SBTS00_ENB_9200": {"StreamPrefix": "SBTSTRUNK", "GoldenSCF": "/SCF_SBTS00.xml"},
    "SBTS25R2_ENB_0000": {"StreamPrefix": "SBTS25R2", "GoldenSCF": "/SCF_SBTS25R2.xml"},
    "SBTS23R3_ENB_0000": {"StreamPrefix": "SBTS23R3", "GoldenSCF": "/SCF_SBTS23R3.xml"},
    "SBTS23R4_ENB_0000": {"StreamPrefix": "SBTS23R4", "GoldenSCF": "/SCF_SBTS23R4.xml"},
    "SBTS24R1_ENB_0000": {"StreamPrefix": "SBTS24R1", "GoldenSCF": "/SCF_SBTS24R1.xml"},
    "SBTS24R2_ENB_0000": {"StreamPrefix": "SBTS24R2", "GoldenSCF": "/SCF_SBTS24R2.xml"},
    "SBTS24R3_ENB_0000": {"StreamPrefix": "SBTS24R3", "GoldenSCF": "/SCF_SBTS24R3.xml"},
}

CASE_INPUT_5GC002479 = {
    "TLConfiguration": "1ASIK_1ABIN_TDD",
    "5GC002479_HA_KPI5": {
        "SFPCooledTransceiver": [
            {"Declaration": "True"},
        ],  # The value of SFPCooledTransceiver to different BBMOD,In order from BBMOD1
    },
    "5GC002479_HA_KPI1a": {
        "WebUI_reset_times": "5",
        "KPI1a_AVG": "540",
        "KPI1a_MAX": "756",
    },
    "cell_number": "2",
    "cell_type": "SA",
}
# modify Golden to TL007.V1 SCF
cell_number = "2"
cell_type = "SA"
Target_distinguished_name = "MRBTS-11051/EQM_R-1/APEQM_R-1/RMOD_R-3"
RU_index = "RMOD_R-3"


CNF_5G_Classical_3 = {
    "KPI1a": {"KPI1a_AVG": "390", "KPI1a_MAX": "468"},
    "KPI3": {"KPI3_AVG": "390", "KPI3_MAX": "468"},
    "KPI5": "510",
    "KPI17a": "10",
    "KPI17b": "10",
    "KPI51a": {"KPI51a_AVG": "240", "KPI51a_MAX": "288"},
    "KPI54a": {"KPI54a_AVG": "240", "KPI54a_MAX": "288"},
    "SW_Download_MAX": "1920",
    "KPI2a": {"KPI2a_AVG": "570", "KPI2a_MAX": "684"},
    "KPI2b": {"KPI2b_AVG": "810", "KPI2b_MAX": "972"},
    "KPI2c": {"KPI2c_AVG": "390", "KPI2c_MAX": "468"},
    "KPI2d": {"KPI2d_AVG": "630", "KPI2d_MAX": "756"},
    "KPI4": {"KPI4_AVG": "2610", "KPI4_MAX": "3132"},
    "Customer": "True",
}


Configurations = {"1ASIK_1ABIN_TDD": CNF_5G_Classical_3}


TLCommonConfig = {
    "MultiUECFG": {
        "ue_index_for_call": ["0", "1"],
        "0": {
            "detach_request": "true",
            "power_reset": "true",
            "ue_mode": "SA",
            "apn": "wap1nokiacom",
            "iperf_port": "default",
            "multidrb_QoS_dest": None,
            "check_tput_on_ue": "true",
            "target_avg_percent": "0.8",
            "target_min_percent": "0.5",
            "check_throughput_duration": "120",
            "call_loop": 1,
            "cell_index_list": ["1"],
            "iperf_type": "via_app",
            "dl": {"target_throughput": "100"},
            "ul": {"target_throughput": "30"},
        },
        "1": {
            "detach_request": "true",
            "power_reset": "true",
            "ue_mode": "SA",
            "apn": "wap1nokiacom",
            "iperf_port": "default",
            "multidrb_QoS_dest": None,
            "check_tput_on_ue": "true",
            "target_avg_percent": "0.8",
            "target_min_percent": "0.5",
            "check_throughput_duration": "120",
            "call_loop": 1,
            "cell_index_list": ["1"],
            "iperf_type": "via_app",
            "dl": {"target_throughput": "100"},
            "ul": {"target_throughput": "30"},
        },
    }
}

CASE_INPUT_CB005845 = {
    "ue_index": "0",
    "ue_mode": "SA",
    "apn": "wap1nokiacom",
    "CASE_24": {
        "DL": "800",
        "UL": "100",
        "Check_TP": "0.5",
        "duration": "30",
    },
    "TC60": {
        "lock_unlock_retry_times": "5",
    },
    "TC11": {"ru_index": "3"},
    "TC14": {"ru_index": "3"},
    "TC17": {"with_call": "True"},
    "TC21": {"ru_index": "3"},
    "TC22": {
        "ru_index": "3",
        "Tdanger_target": "30",
    },
    "TC24": {
        "band": "71",
        "ru_index": "3",
        "cell_id": "3",
    },
}


CASE_INPUT_CB007378 = {
    "Baseband_module_reset": {
        "BBMODs_Reset": [
            {"index": 1, "Rus": [{"index": 1, "Cells": [{"index": 11}, {"index": 12}]}]}
        ]
    },
    "RMODs_LockAndUnlock": [{"index": 1, "Cells": [{"index": 11}, {"index": 12}]}],
}

CASE_INPUT_CB007958 = {
    "mPlaneIpAddress": "7.7.7.7",
    "mPlaneIpPrefix": 24,
    "defaultGateway": "10.68.88.1",
    "identificationServerIpAddress": "10.110.144.153",
    "secondaryMPlaneIpAddress": "10.68.88.3",
    "secondaryMPlaneIpPrefix": 27,
}

TL_BASE_SCF_NR = "SCF_SBTS00_NR.xml"
TL_BASE_SCF_LTE = "SCF_SBTS00_LTE.xml"


CASE_INPUT_SISO = {
    "SISOCommon": {
        "cell_type": "lte",  # nr or lte
        "release": "SBTS23R1",  # release of software
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
    },
    # "ru_index": "1",
    # "ru_type": "AWPQZ",
    # "host_addr": "10.68.88.16",
    # "Ping from GNB container to RU_IP": "ping 172.16.73.128 -c 3600 -i 1",
    # "ru_product_code": "476086A.X21",
    # "ru_serial_number": "EB2201R0199",
}

CASE_INPUT_CB011039 = {
    "index": "3",
    "object": "RMOD_R-3",
}
