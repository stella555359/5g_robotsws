import os

__team__ = "MN 5G RAN I&V 4 Pz HZG SG1"
__email__ = "I_MN_5G_RAN_IV4_LINE_HZG_1@internal.nsn.com"
TL_BASE_SCF_NR = "TL_BASE_SCF_NR.xml"
casescf = "TL_BASE_SCF_NR.xml"
casescf_2cc_20m = "TL_BASE_SCF_NR_2cc_20MHz.xml"
casescf_2cc_100m = "TL_BASE_SCF_NR_2cc_100MHz.xml"
Case_SCF_Path = "TL_BASE_SCF_NR.xml"
block_unblock_casescf = "4X4_100MHZ_1CC_A9.xml"
block_unblock_23R2_casescf = "23R2_1CC.xml"
block_unblock_23R1_casescf = "23R1_1CC.xml"
block_unblock_trunk_casescf = "Trunk_1CC.xml"
Band_50M_with_4T4R = "50M_with_4T4R.xml"
# add for AWPQZ
TL_BASE_SCF_NR_8712 = "SCF_SBTS00_NR_20MHz.xml"
TL_BASE_SCF_NR_2CC_40MHz_100MHz = "SCF_SBTS00_NR_2CC_40MHz_100MHz.xml"
TL_BASE_SCF_NR_2CC_20MHz_40MHz = "SCF_SBTS00_NR_2CC_20MHz_40MHz.xml"
TL_BASE_SCF_NR_2CC_20MHz_40MHz_Cell2 = "SCF_SBTS00_NR_2CC_20MHz_40MHz_Cell2.xml"
TL_BASE_SCF_NR_9218_A2_40MHz = "SCF_SBTS00_NR_1CC_9218_A2_40MHz.xml"
TL_BASE_SCF_NR_2CC_40MHz_100MHz_spacing0 = "TL_BASE_SCF_NR_2CC_40MHz_100MHz_spacing0.xml"
TL_BASE_SCF_NR_2CC_20MHz_20MHz = "SCF_SBTS00_NR_2CC_20MHz_20MHz.xml"
TL_BASE_SCF_NR_2CC_40MHz_40MHz = "SCF_SBTS00_NR_2CC_40MHz_40MHz.xml"
TL_BASE_SCF_LTE = "SCF_SBTS00_LTE.xml"

CASE_INPUT_SISO = {
    "SISOCommon": {
        "cell_type": "nr",  # nr or lte
        "release": "SBTS23R1",  # release of software
    },
    # parameter of case "BS-RF__LTE_Transmitted_carrier_power_min_max_allowed_power"
    "Pmax": {"start": "23", "count": 2, "isCBRS": "true"},  # true or false
}
STREAM_INFOs = {
    "SBTS23R4_ENB_0000": {
        "StreamPrefix": "SBTS23R4",
        "GoldenSCF": "/SCF_SBTS00.xml",
    },
    "SBTS24R2_ENB_0000": {
        "StreamPrefix": "SBTS24R2",
        "GoldenSCF": "/SCF_SBTS00.xml",
    },
    "SBTS26R1_ENB_9999": {
        "StreamPrefix": "SBTS00",
        "GoldenSCF": "/SCF_SBTS00.xml",
    },
    "SBTS26R2_ENB_9999": {
        "StreamPrefix": "SBTS00",
        "GoldenSCF": "/SCF_SBTS00.xml",
    },
    "SBTS26R3_ENB_9999": {
        "StreamPrefix": "SBTS00",
        "GoldenSCF": "/SCF_SBTS00.xml",
    },
    "SBTS27R1_ENB_9999": {
        "StreamPrefix": "SBTS00",
        "GoldenSCF": "/SCF_SBTS00.xml",
    },
    "SBTS27R2_ENB_9999": {
        "StreamPrefix": "SBTS00",
        "GoldenSCF": "/SCF_SBTS00.xml",
    },
    "SBTS00_ENB_9999": {
        "StreamPrefix": "SBTS00",
        "GoldenSCF": "/SCF_SBTS00.xml",
    },

}

TCCB008445_TC66 = {
    "LTE_cell_id_list": "1",
    "ru_index": "1",
    "ru_type": "AWHKB",
    "Ping from GNB container to RU_IP": "ping 172.16.73.128 -c 3600 -i 1",
    "ru_product_code": "476086A.X21",
    "ru_serial_number": "EB2201R0201",
}

TCCB007758_INPUT = {
    "TC24": {
        "CELLs_BLockAndUnblock": ["2", "3"],
        "UE_Attach_Cell_index": "1",
        "UE_index": "0",
    }
}

TCCB008974_INPUT = {
    "TC22": {
        "ru_index": "1",
    },
    "TC19": {
        "cell_index_list": [{"ru_index": 1, "cell_id": [1]}, {"ru_index": 2, "cell_id": [2, 3]}],
    },
    "NR_BBMOD_RESET": {
        "baseband_index_list": [1],
        "UE_Attach_Cell_list": [2],
    },
}

TCCB009463_INPUT = {
    "RF_Module_lock_unlock": {
        "ru_index": "3",
    },
    "E2E_with_data_transfer": {
        "UE_Attach_Cell_index": "4",
        "UE_index": "1",
        "peak_use_tool": True,
    },
}

TCCB010267_INPUT = {
    "TC24": {
        "UE_Attach_Cell_index": "5",
        "UE_index": "0",
    }
}

TLCommonConfig = {
    "MultiUECFG": {
        # If your UE is samsung, "iperf_type" should be "via_command", it's used for UL traffic test at UE side.
        "0": {
            "ue_mode": "SA",
            "apn": "wap1nokiacom",
            "iperf_port": 51003,
            "multidrb_QoS_dest": None,
            "check_tput_on_ue": "false",
            "target_avg_percent": "0.98",
            "target_min_percent": "0.85",
            "check_throughput_duration": "300",
            "call_loop": 1,
            "iperf_type": "via_app",
            "cell_index_list": ["1"],
            "dl": {"target_throughput": "500", "duration": "600"},
            "ul": {"target_throughput": "150", "duration": "600"},
            # spark ue
            "detach_request": "True",
            "power_reset": "true",
            "adapt_UL": "1",
            "adapt_DL": "1",
        },
        "ue_index_for_call": ["0"],
    },
    "MultiUECFG_9463": {
        # If your UE is samsung, "iperf_type" should be "via_command", it's used for UL traffic test at UE side.
        "1": {
            "ue_mode": "SA",
            "apn": "wap1nokiacom",
            "multidrb_QoS_dest": None,
            "check_tput_on_ue": "false",
            "target_avg_percent": "0.98",
            "target_min_percent": "0.85",
            "check_throughput_duration": "300",
            "call_loop": 1,
            "iperf_type": "via_app",
            "cell_index_list": ["4"],
            "dl": {"target_throughput": "50", "duration": "600"},
            "ul": {"target_throughput": "30", "duration": "600"},
            # spark ue
            "detach_request": True,
            "power_reset": "true",
        },
        "ue_index_for_call": ["1"],
    },
    "MultiUECFG_X85": {
        # If your UE is samsung, "iperf_type" should be "via_command", it's used for UL traffic test at UE side.
        "3": {
            "ue_mode": "SA",
            "apn": "wap1nokiacom",
            "multidrb_QoS_dest": None,
            "check_tput_on_ue": "false",
            "target_avg_percent": "0.98",
            "target_min_percent": "0.85",
            "check_throughput_duration": "30",
            "call_loop": 1,
            "iperf_type": "via_app",
            "cell_index_list": ["7"],
            "dl": {"target_throughput": "50", "duration": "60"},
            "ul": {"target_throughput": "4", "duration": "60"},
            # spark ue
            "detach_request": True,
            "power_reset": "true",
        },
        "ue_index_for_call": ["3"],
    },
    "MultiUECFG_10267": {
        # If your UE is samsung, "iperf_type" should be "via_command", it's used for UL traffic test at UE side.
        "0": {
            "ue_mode": "SA",
            "apn": "wap1nokiacom",
            "iperf_port": 51003,
            "multidrb_QoS_dest": None,
            "check_tput_on_ue": "false",
            "target_avg_percent": "0.98",
            "target_min_percent": "0.85",
            "check_throughput_duration": "300",
            "call_loop": 1,
            "iperf_type": "via_app",
            "cell_index_list": ["6"],
            "dl": {"target_throughput": "50", "duration": "600"},
            "ul": {"target_throughput": "30", "duration": "600"},
            # spark ue
            "detach_request": True,
            "power_reset": "true",
        },
        "ue_index_for_call": ["0"],
    }
}

TLCommonConfig_CB007758 = {
    "MultiUECFG": {
        # If your UE is samsung, "iperf_type" should be "via_command", it's used for UL traffic test at UE side.
        "0": {
            "ue_mode": "SA",
            "apn": "wap1nokiacom",
            "iperf_port": 51003,
            "multidrb_QoS_dest": None,
            "check_tput_on_ue": "false",
            "target_avg_percent": "0.98",
            "target_min_percent": "0.85",
            "check_throughput_duration": "300",
            "call_loop": 1,
            "iperf_type": "via_app",
            "cell_index_list": ["1"],
            "dl": {"target_throughput": "1500", "duration": "600"},
            "ul": {"target_throughput": "197", "duration": "600"},
            "detach_request": True,
            "power_reset": "true",
            "adapt_UL": "1",
            "adapt_DL": "1",
        },
        "ue_index_for_call": ["0"],
    }
}

CASE_INPUT_CB012475 = {
    'CB012475_SR_B_19_06': {
        'ru_index': 6,
    },

    'site_reset_times': '3',
    'site_reset_duration': '600',
    'SAS_IP': '10.57.159.64',
    'SAS_UserName': 'ute',
    'SAS_Password': 'iW_K#8.ute%A10h0m0ra',
}

TLCommonConfig_8712 = {
    "MultiUECFG": {
        "2": {
            "ue_mode": "SA",
            "apn": "wap3nokiacom",
            "iperf_port": "default",
            "multidrb_QoS_dest": None,
            "iperf_type": "via_app",
            "target_avg_percent": "0.8",
            "cell_index_list": ["1"],
            "dl": {"target_throughput": "5", "duration": "300"},
            "ul": {"target_throughput": "5", "duration": "300"},
            "detach_request": True,
            "power_reset": "true",
            "target_percent": "0.95",
            "check_tput_on_ue": "true",
            "reset_sol": "none",
            "attach_mode": "5G_SA",
            # "dt_name": "DT_1",
            "protocol": "udp",
            "connection_type": "app",
        },
        "ue_index_for_call": ["2"],
    },
}
