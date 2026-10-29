import os

__team__ = "MN 5G RAN I&V 4 Pz HZG SG1"
__email__ = "I_MN_5G_RAN_IV4_LINE_HZG_1@internal.nsn.com"

GoldenSCF = "/Trunk/GoldenSCF_6Cell_v5.xml"
TestLineID = "7_5_UTE5G402T1103"
prefix_of_release = "5G_"
CASE_INPUT_5GC002479 = {
    "TLConfiguration": "1ASIK_1ABIN_FDD",
    "5GC002479_HA_KPI5": {
        "SFPCooledTransceiver": [
            {"Declaration": "False"},
        ],  # The value of SFPCooledTransceiver to different BBMOD,In order from BBMOD1
    },
    "5GC002479_HA_KPI1a": {
        "WebUI_reset_times": "5",
        "KPI1a_AVG": "390",
        "KPI1a_MAX": "756",
    },
    "cell_number": "3",
    "cell_type": "NSA",
}
# modify Golden to TL007.V1 SCF
cell_number = "3"
cell_type = "NSA"

CNF_5G_Classical_3 = {
    "KPI1a": {"KPI1a_AVG": "390", "KPI1a_MAX": "468"},
    "KPI3": {"KPI3_AVG": "390", "KPI3_MAX": "468"},
    "KPI5": "270",
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


Configurations = {"1ASIK_1ABIN_FDD": CNF_5G_Classical_3}


TLCommonConfig = {
    "MultiUECFG": {
        "ue_index_for_call": ["0", "1"],
        "0": {
            "detach_request": "true",
            "power_reset": "true",
            "ue_mode": "5G_SA",
            "apn": "wap1nokiacom",
            "iperf_port": "default",
            "multidrb_QoS_dest": None,
            "check_tput_on_ue": "false",
            "target_avg_percent": "0.8",
            "target_min_percent": "0.5",
            "check_throughput_duration": "120",
            "call_loop": 1,
            "iperf_type": "via_app",
            "cell_index_list": ["1"],
            "dl": {"target_throughput": "10"},
            "ul": {"target_throughput": "5"},
        },
        "1": {
            "detach_request": "true",
            "power_reset": "true",
            "ue_mode": "5G_NSA",
            "apn": "dxdata2",
            "iperf_port": "default",
            "multidrb_QoS_dest": None,
            "check_tput_on_ue": "false",
            "target_avg_percent": "0.8",
            "target_min_percent": "0.5",
            "check_throughput_duration": "120",
            "call_loop": 1,
            "iperf_type": "via_app",
            "cell_index_list": ["1"],
            "dl": {"target_throughput": "10"},
            "ul": {"target_throughput": "5"},
        },
    }
}

CASE_INPUT_CB007958 = {
    "mPlaneIpAddress": "7.7.7.7",
    "mPlaneIpPrefix": 24,
    "defaultGateway": "10.71.215.1",
    "identificationServerIpAddress": "10.110.144.153",
    "secondaryMPlaneIpAddress": "10.71.215.2",
    "secondaryMPlaneIpPrefix": 27,
}
