import os

__team__ = 'MN 5G RAN I&V 4 Pz HZG SG1'
__email__ = 'I_MN_5G_RAN_IV4_LINE_HZG_1@internal.nsn.com'

TestLineID = '7_5_UTE5G402T214'
prefix_of_release = '5G_'

TLCommonConfig = {
    "MultiUECFG": {
        "ue_index_for_call": ["0"],
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
    }
}
