# OAM KPI cases parameter

CASE_INPUT_SISO = {
    "SISOCommon": {
        "cell_type": "lte",  # nr or lte
        "release": "SBTS23R1",  # release of software
    },
    "CommonCasexxx": {
        "MultiUECFG": {
            "0": {
                "dl": {"target_throughput": "5M", "duration": "600"},
                "ul": {"target_throughput": "5M", "duration": "600"},
            },
            "ue_index_for_call": ["0"],
        }
    },
    # parameter of case "BS-RF__LTE_Transmitted_carrier_power_min_max_allowed_power"
    "Pmax": {"start": "23", "count": 2, "isCBRS": "true"},  # true or false
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
    "ru_index": "1",
    "ru_type": "AWPQZ",
    # "host_addr": "10.68.88.16",
    # "Ping from GNB container to RU_IP": "ping 172.16.73.128 -c 3600 -i 1",
    # "ru_product_code": "476086A.X21",
    # "ru_serial_number": "EB2201R0199",
}


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

CASE_INPUT_CB008445 = {
    "Manual_SiSo_ALD_SN": "0000CN10184761297",
}

CB005845 = {
    "DeltaSCFCellNumber": "None",
    "CellType": "SA",
}

TLCommonConfig = {
    "MultiUECFG": {
        # If your UE is samsung, "iperf_type" should be "via_command", it's used for UL traffic test at UE side.
        "0": {
            "ue_mode": "SA",
            "apn": "wap1nokiacom",
            "iperf_port": "default",
            "multidrb_QoS_dest": None,
            "check_tput_on_ue": "false",
            "target_avg_percent": "0.8",
            "target_min_percent": "0.5",
            "check_throughput_duration": "120",
            "call_loop": 2,
            "iperf_type": "via_app",
            "cell_index_list": ["1"],
            "dl": {"target_throughput": "5M", "duration": "600"},
            "ul": {"target_throughput": "5M", "duration": "600"},
            # spark ue
            "detach_request": True,
            "power_reset": "false",
            # multi ue args
            "target_percent": "0.95",
            "reset_sol": "none",
            "attach_mode": "5G_SA",
            "dt_name": "DT_1",
            "protocol": "udp",
            "connection_type": "app",
            # Vivi ue args
            "internal_ip": "192.168.10.70",
            "power_cycle_script_path": "C:/ViViPowerReset/ViViPowerReset.py",
            "dial_connection": "Broadband Connection",
            "dial_username": "tm500",
            "dial_password": "tm500",
            # "appserver_ip": "10.57.163.34",
            # "appserver_username": "cmw_sg1",
            # "appserver_password": "Noki_sg1@123!",
            "app_ta_port": "5030",
            "app_path": "/cygdrive/c/Program Files (x86)/VIAVI/TM500/5G NR - NLA 5.11.1/Test Mobile Application/TMA",
            # "controlpc_ip":"10.68.86.232",
            # "controlpc_username":"nokia5G",
            # "controlpc_password":"noki@123",
            "script_path": "robotws/testsuite/Hangzhou/RRM/RAN_PZ_HAZ_34/5GC000496_C/Resources/viviscript/",
        },
        "ue_index_for_call": ["0"],
    }
}
