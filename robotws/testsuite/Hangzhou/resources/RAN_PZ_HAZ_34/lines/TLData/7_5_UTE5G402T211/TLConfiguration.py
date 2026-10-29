import os

__team__ = "MN 5G RAN I&V 4 Pz HZG SG1"
__email__ = "I_MN_5G_RAN_IV4_LINE_HZG_1@internal.nsn.com"

CASE_INPUT_CB009407 = {
    "cell_index": 1,
    "ru_index": 1
}

TLCommonConfig = {
    "MultiUECFG": {
        "ue_index_for_call": ["0"],
        "0": {
            "detach_request": True,
            "power_reset": "true",
            "ue_mode": "SA",
            "apn": "dxdata2",
            "iperf_port": "default",
            "multidrb_QoS_dest": None,
            "check_tput_on_ue": "true",
            "target_avg_percent": "0.8",
            "target_min_percent": "0.5",
            "check_throughput_duration": "30",
            "call_loop": 1,
            "iperf_type": "via_app",
            "cell_index_list": ["1"],
            "dl": {"target_throughput": "5"},
            "ul": {"target_throughput": "5"},
        },
        "1": {
            "detach_request": True,
            "power_reset": "true",
            "ue_mode": "SA",
            "apn": "dxdata2",
            "iperf_port": "default",
            "multidrb_QoS_dest": None,
            "check_tput_on_ue": "true",
            "target_avg_percent": "0.8",
            "target_min_percent": "0.5",
            "check_throughput_duration": "30",
            "call_loop": 1,
            "iperf_type": "via_app",
            "cell_index_list": ["1"],
            "dl": {"target_throughput": "5"},
            "ul": {"target_throughput": "5"},
        },
    },
    "MultiUECFG1": {
        "ue_index_for_call": ["0"],
        "0": {
            "detach_request": True,
            "power_reset": "true",
            "ue_mode": "SA",
            "apn": "dxdata2",
            "iperf_port": "default",
            "multidrb_QoS_dest": None,
            "check_tput_on_ue": "true",
            "target_avg_percent": "0.8",
            "target_min_percent": "0.5",
            "check_throughput_duration": "50",
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
    },
}
