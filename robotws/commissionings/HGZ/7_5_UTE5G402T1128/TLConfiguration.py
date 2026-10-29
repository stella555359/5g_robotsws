GoldenSCF_ON_GIT = "/opt/transformers.dynamic.nsn-net.net/gnb_configuration/Hangzhou/7_5_UTE5G402T1128/"


STREAM_INFOs = {
    "SBTS22R3_ENB_0000": {
        "StreamPrefix": "SBTS22R3",
        "GoldenSCF": "TestLineSCF1Cell_Both_dual.xml",
    },
    "SBTS00_ENB_9999": {
        "StreamPrefix": "SBTSTRUNK",
        "GoldenSCF": "TestLineSCF1Cell_Both_dual.xml",
    },
}

TLCommonConfig = {
    "MultiUECFG": {
        "0": {  # ue0
            "detach_request": False,
            "power_reset": "true",
            "ue_mode": "SA",
            "apn": "dxdata2",
            "iperf_port": "default",
            "multidrb_QoS_dest": None,
            "check_tput_on_ue": "false",
            "target_avg_percent": "0.8",
            "target_min_percent": "0.5",
            "check_throughput_duration": "800",
            "call_loop": 1,
            "iperf_type": "via_app",
            "cell_index_list": ["1"],
            "dl": {"target_throughput": "10"},
            "ul": {"target_throughput": "5"},
        },
        "1": {
            "detach_request": True,
            "power_reset": "true",
            "ue_mode": "NSA",
            "apn": "DXDATA1",
            "iperf_port": "default",
            "multidrb_QoS_dest": None,
            "check_tput_on_ue": "true",
            "target_avg_percent": "0.8",
            "target_min_percent": "0.5",
            "check_throughput_duration": "120",
            "call_loop": 1,
            "cell_index_list": ["1"],
            "iperf_type": "via_app",
            "protocol": "udp",
            "dl": {"target_throughput": "2"},
            "ul": {"target_throughput": "2"},
        },
        "ue_index_for_call": ["0", "1"],
    },
}

CASE_INPUT_5GC000829 = {
    "dcap_server_ip": "host-10-70-230-71",
    "dcap_server_port": "443",
    "cellIndexOfPrimary": [1],
    "cellIndexOfSecondary": [2],
    "829_A_009": {
        "BBMODs_Reset": [{"index": 2, "Rus": [{"index": 2, "Cells": [{"index": 2}]}]}],
        "RMODs_Reset": [{"index": 2, "Cells": [{"index": 2}]}],
        "RMODs_LockAndUnlock": [{"index": 2, "Cells": [{"index": 2}]}],
        "CELLs_LockAndUnlock": [{"index": 2}],
    },
    "829_A_010": {"nrcell": "2"},
    "829_A_021": {"call_cell_index": 1, "lock_unlock_cell_index": [2]},
    "829_A_022": {"call_cell_index": 2, "lock_unlock_cell_index": [1]},
}

CASE_INPUT_5GC001473 = {
    "1473_K": {
        "ue_index": "0",
        "apn": "wap1nokiacom",
        "cell_index": "1",
    },
}

CASE_INPUT_CB007475 = {
    "cellIndexOfPrimary": [1],
    "cellIndexOfSecondary": [2],
    "Baseband_module_reset": {
        "BBMODs_Reset": [
            {
                "index": 1,
                "Rus": [
                    {"index": 1, "Cells": [{"index": 1, "cell_type": "NR"}, {"index": 4, "cell_type": "LTE"}]},
                    {"index": 2, "Cells": [{"index": 2, "cell_type": "NR"}, {"index": 5, "cell_type": "LTE"}]},
                    {"index": 3, "Cells": [{"index": 3, "cell_type": "NR"}, {"index": 6, "cell_type": "LTE"}]},
                    {
                        "index": 4,
                        "Cells": [
                            {"index": 11, "cell_type": "LTE"},
                            {"index": 12, "cell_type": "LTE"},
                            {"index": 13, "cell_type": "LTE"},
                            {"index": 14, "cell_type": "LTE"},
                        ],
                    },
                    {
                        "index": 5,
                        "Cells": [
                            {"index": 21, "cell_type": "LTE"},
                            {"index": 22, "cell_type": "LTE"},
                            {"index": 23, "cell_type": "LTE"},
                            {"index": 24, "cell_type": "LTE"},
                        ],
                    },
                    {
                        "index": 6,
                        "Cells": [
                            {"index": 31, "cell_type": "LTE"},
                            {"index": 32, "cell_type": "LTE"},
                            {"index": 33, "cell_type": "LTE"},
                            {"index": 34, "cell_type": "LTE"},
                        ],
                    },
                ],
            }
        ]
    },
}
