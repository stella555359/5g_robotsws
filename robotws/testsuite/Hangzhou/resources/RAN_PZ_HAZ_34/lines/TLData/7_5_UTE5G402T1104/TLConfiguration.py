import os

__team__ = "MN 5G RAN I&V 4 Pz HZG SG1"
__email__ = "I_MN_5G_RAN_IV4_LINE_HZG_1@internal.nsn.com"
TL_BASE_SCF_LTE_10M = "SCF_SBTS00_10M_LTE.xml"
TL_BASE_SCF_NR_10M = "SCF_SBTS00_NR_10M.xml"
casescf = "SCF_SBTS00_NR_2CC.xml"
TCCB008445_TC66 = {
    "LTE_cell_id_list": "1",
    "ru_index": "1",
    "ru_type": "AWHKB",
    "Ping from GNB container to RU_IP": "ping 172.16.73.128 -c 3600 -i 1",
    "ru_product_code": "476086A.X21",
    "ru_serial_number": "EB2201R0201",
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
            "dl": {"target_throughput": "5M", "duration": "120"},
            "ul": {"target_throughput": "5M", "duration": "120"},
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
            "script_path": "ViViScript/",
            "group": "Units-1",
        },
        "ue_index_for_call": ["0"],
    }
}
