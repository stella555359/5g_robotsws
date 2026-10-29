import os

__team__ = "MN 5G RAN I&V 4 Pz HZG SG1"
__email__ = "I_MN_5G_RAN_IV4_LINE_HZG_1@internal.nsn.com"

TLCommonConfig = {
    "MultiUECFG": {
        "0": {
            "detach_request": True,
            "power_reset": "true",
            "ue_mode": "SA",
            "apn": "wap1nokiacom",
            "iperf_port": "default",
            "multidrb_QoS_dest": None,
            "check_tput_on_ue": "false",
            "target_avg_percent": "0.9",
            "target_min_percent": "0.8",
            "check_throughput_duration": "60",
            "call_loop": 1,
            "iperf_type": "via_app",
            "cell_index_list": ["1"],
            "dl": {"target_throughput": "1505"},
            "ul": {"target_throughput": "182"},
        },
        "ue_index_for_call": ["0"],
    }
}
