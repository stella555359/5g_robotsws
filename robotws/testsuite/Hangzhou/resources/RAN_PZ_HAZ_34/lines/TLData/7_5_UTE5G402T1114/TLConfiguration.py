import os

__team__ = "MN 5G RAN I&V 4 Pz HZG SG1"
__email__ = "I_MN_5G_RAN_IV4_LINE_HZG_1@internal.nsn.com"

TL_BASE_SCF_NR = "TL_BASE_SCF_NR.xml"
casescf = "TL_BASE_SCF_NR.xml"
casescf_2cc_20m = "TL_BASE_SCF_NR_2cc_20MHz.xml"
casescf_2cc_100m = "TL_BASE_SCF_NR_2cc_100MHz.xml"
Case_SCF_Path = "TL_BASE_SCF_NR.xml"

TL_BASE_SCF_LTE_10M = "SCF_SBTS00_10M_LTE.xml"
TL_BASE_SCF_10M = "SCF_SBTS00_10M_LTE.xml"
TL_BASE_SCF_NR_10M = "SCF_SBTS00_NR_10M.xml"

# this test value is for FDD cases
# none GRB
TLCommonConfig = {
    "MultiUECFG": {
        "0": {
            "detach_request": True,
            "power_reset": "true",
            "ue_mode": "SA",
            "apn": "mdrbnokiacom",
            "iperf_port": "51126",
            "multidrb_QoS_dest": None,
            "check_tput_on_ue": "true",
            "target_avg_percent_ul": "0.26",
            "target_avg_percent_dl": "0.47",
            "target_min_percent": "0.9",
            "check_throughput_duration": "30",
            "call_loop": 1,
            "iperf_type": "via_app",
            "cell_index_list": ["1"],
            "dl": {"target_throughput": "300"},
            "ul": {"target_throughput": "200"},
        },
        "1": {
            "detach_request": True,
            "power_reset": "true",
            "ue_mode": "SA",
            "apn": "mdrbnokiacom",
            "iperf_port": "51127",
            "multidrb_QoS_dest": None,
            "check_tput_on_ue": "true",
            "target_avg_percent_ul": "0.26",
            "target_avg_percent_dl": "0.47",
            "target_min_percent": "0.9",
            "check_throughput_duration": "30",
            "call_loop": 1,
            "iperf_type": "via_app",
            "cell_index_list": ["2"],
            "dl": {"target_throughput": "300"},
            "ul": {"target_throughput": "200"},
        },
        "ue_index_for_call": ["0", "1"],
    },
}
# GBR Case
GBRTLCommonConfig = {
        "0": {
            "target_avg_percent_ul": "0.35",
            "target_avg_percent_dl": "0.9",
            "target_min_percent": "0.9",
            "dl": "300",
            "ul": "0",
            "iperf_port": "51126",
        },
        "1": {
            "target_avg_percent_ul": "0.9",
            "target_avg_percent_dl": "1",
            "target_min_percent": "0.9",
            "dl": "15",
            "ul": "0",
            "iperf_port": "51125",
        },
}

# preemption case
preemTLCommonConfig = {
        "0": {
            "dl": "0",
            "ul": "0",
        },
        "1": {
            "dl": "0",
            "ul": "0",
        },
        "ue_index_for_call": ["1", "0"],
}

SCHEDULING_ON = {
        "0": {
            "target_avg_percent_dl": "0.23",
            "target_min_percent": "0.5",
            "target_avg_percent_ul": "0.17",
            "dl": "300",
            "ul": "200",
        },
        "1": {
            "target_avg_percent_dl": "0.72",
            "target_min_percent": "0.5",
            "target_avg_percent_ul": "0.35",
            "dl": "300",
            "ul": "200",
        },
}

NSA_Before = {
        "0": {
            "target_avg_percent_dl": "0.45",
            "target_min_percent": "0.7",
            "target_avg_percent_ul": "0.24",
            "iperf_port": "5412",
            "ue_mode": "5G_NSA",
            "apn": "dxmdrb1101",
            "dl": "300",
            "ul": "200",
        },
        "1": {
            "target_avg_percent_dl": "0.45",
            "target_min_percent": "0.5",
            "target_avg_percent_ul": "0.24",
            "iperf_port": "5412",
            "ue_mode": "5G_NSA",
            "apn": "dxmdrb1101",
            "dl": "300",
            "ul": "200",
        },
}

NSA_After = {
        "0": {
            "target_avg_percent_dl": "0.22",
            "target_min_percent": "0.7",
            "target_avg_percent_ul": "0.2",
            "ue_mode": "5G_NSA",
            "apn": "dxmdrb1101",
            "dl": "300",
            "ul": "200",
        },
        "1": {
            "target_avg_percent_dl": "0.66",
            "target_min_percent": "0.5",
            "target_avg_percent_ul": "0.3",
            "ue_mode": "5G_NSA",
            "apn": "dxmdrb1101",
            "dl": "300",
            "ul": "200",
        },
}

GBR_exceed_GFBR_data = {
    "1": {
        "target_avg_percent_dl": "0.5",
        "dl": "40",
    }
}

GBR_VONR_data = {
    "1": {
        "target_avg_percent_dl": "1",
        "dl": "0.003",
    }
}
