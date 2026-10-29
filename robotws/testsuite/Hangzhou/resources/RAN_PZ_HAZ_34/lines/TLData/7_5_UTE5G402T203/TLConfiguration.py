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
block_unblock_casescf = "4X4_100MHZ_1CC_A9.xml"
block_unblock_23R2_casescf = "23R2_1CC.xml"
block_unblock_23R1_casescf = "23R1_1CC.xml"
block_unblock_trunk_casescf = "Trunk_1CC.xml"

CASE_INPUT_SISO = {
    "SISOCommon": {
        "cell_type": "nr",  # nr or lte
        "release": "SBTS23R1",  # release of software
    },
}
STREAM_INFOs = {
    "9.1800": {
        "StreamPrefix": "20A",
        "GoldenSCF": "/20A/SCF_TDD_CPRI_ASIB_AEQB_TL103_3CELL.xml",
    },
    "10.1800": {"StreamPrefix": "20B", "GoldenSCF": "/20B/GoldenSCF_6Cell_v30.xml"},
    "11.800": {"StreamPrefix": "21A", "GoldenSCF": "/21A/GoldenSCF_6Cell_v24.xml"},
    "0.800": {"StreamPrefix": "TRUNK", "GoldenSCF": "/Trunk/GoldenSCF_6Cell.xml"},
    "0.300": {"StreamPrefix": "TRUNK", "GoldenSCF": ""},
    "17.300": {"StreamPrefix": "23R1", "GoldenSCF": ""},
    "SBTS21B_ENB_0000": {
        "StreamPrefix": "SBTS21B",
        "GoldenSCF": "/21B/GoldenSCF_6Cell_v20.xml",
    },
    "SBTS22R1_ENB_0000": {
        "StreamPrefix": "SBTS22R1",
        "GoldenSCF": "/Trunk/GoldenSCF_6Cell_v4.xml",
    },
    "SBTS00_ENB_9999": {
        "StreamPrefix": "SBTSTRUNK",
        "GoldenSCF": "/Trunk/GoldenSCF_6Cell_v4.xml",
    },
    "SBTS23R1_ENB_0000": {
        "StreamPrefix": "SBTS23R1",
        "GoldenSCF": "/Trunk/GoldenSCF_6Cell_v4.xml",
    },
}
CASE_INPUT_5GC002479 = {
    "5GC002479_HA_KPI51": {
        "KPI51_AVG": "240",
        "KPI51_MAX": "300",
        "KPI51_AVG_ADJ": "0",
        "RF_reset_times": "5",
        "ru_index": "1",
    },
    "5GC002479_HA_KPI1a": {
        "KPI1a_AVG": "600",
        "KPI1a_MAX": "630",
        "KPI1a_AVG_ADJ": "0",
        "WebUI_reset_times": "5",
    },
    "5GC002479_HA_08_KPI51": {
        "RF_reset_times": "5",
        "ru_index": "1",
    },
}

TCCB008445_TC66 = {
    "LTE_cell_id_list": "1",
    "ru_index": "1",
    "ru_type": "AWHQX",
    "Ping from GNB container to RU_IP": "ping 172.16.73.128 -c 3600 -i 1",
    "ru_product_code": "476086A.X21",
    "ru_serial_number": "EB2201R0201",
}

TLCommonConfig = {
    "MultiUECFG": {
        # If your UE is samsung, "iperf_type" should be "via_command", it's used for UL traffic test at UE side.
        "0": {
            "ue_mode": "SA",
            "apn": "wap2nokiacom",
            "iperf_port": "default",
            "multidrb_QoS_dest": None,
            "check_tput_on_ue": "false",
            "target_avg_percent": "0.7",
            "target_min_percent": "0.6",
            "check_throughput_duration": "120",
            "call_loop": 1,
            "iperf_type": "via_app",
            "cell_index_list": ["1"],
            "dl": {"target_throughput": "1000", "duration": "600"},
            "ul": {"target_throughput": "150", "duration": "600"},
            # spark ue
            "detach_request": True,
            "power_reset": "true",
            # multi ue args
            "target_percent": "0.6",
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
