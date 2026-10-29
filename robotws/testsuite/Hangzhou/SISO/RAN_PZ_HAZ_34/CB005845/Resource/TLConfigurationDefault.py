# OAM KPI cases parameter
CASE_INPUT_5GC002479 = {
    "5GC002479_IA_15": {
        "SW_update_times": "1",
        "UpdateByYAFT": "true",
    },
    "5GC002479_HA_08_KPI51": {
        "RF_reset_times": "2",
        "ru_index": "1",
    },
    "5GC002479_HA_KPI51": {
        "KPI51_AVG": "360",
        "KPI51_MAX": "432",
        "KPI51_AVG_ADJ": "0",
    },
    "5GC002479_IA_KPI4": {
        "KPI4_AVG": "1320",
        "KPI4_MAX": "1584",
    },
}

CB005845 = {
    "DeltaSCFCellNumber": "None",
    "CellType": "SA",
}

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
            "target_avg_percent": "0.8",
            "target_min_percent": "0.5",
            "check_throughput_duration": "30",
            "call_loop": 1,
            "iperf_type": "via_app",
            "cell_index_list": ["1"],
            "dl": {"target_throughput": "5"},
            "ul": {"target_throughput": "5"},
        },
        "ue_index_for_call": ["0"],
    }
}
