import os

__team__ = "MN 5G RAN I&V 4 Pz HZG SG1"
__email__ = "I_MN_5G_RAN_IV4_LINE_HZG_1@internal.nsn.com"


CASE_INPUT_CB009407 = {
    "cell_index": 4,
    "ru_index": 2
}

TLCommonConfig = {
    "MultiUECFG": {
        "ue_index_for_call": ["0"],
        "0": {
            "detach_request": True,
            "power_reset": "true",
            "ue_mode": "SA",
            "apn": "dxdata1",
            "iperf_port": "default",
            "multidrb_QoS_dest": None,
            "check_tput_on_ue": "true",
            "target_avg_percent": "0.8",
            "target_min_percent": "0.5",
            "check_throughput_duration": "120",
            "cell_index_list": ["1"],
            "iperf_type": "via_app",
            "protocol": "udp",
            "dl": {"target_throughput": "10", "duration": "2000"},
            "ul": {"target_throughput": "0", "duration": "2000"},
        },
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
