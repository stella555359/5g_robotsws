# GoldenSCF_ON_GIT = "/opt/transformers.dynamic.nsn-net.net/gnb_configuration/Hangzhou/7_5_UTE5G402T1112/"

STREAM_INFOs = {
    "SBTS00_ENB_9999": {
        "StreamPrefix": "SBTSTRUNK",
        "GoldenSCF": "/TL1112_GoldenSCF_4Cells_v2.xml",
    }
}

TLCommonConfig = {
    "MultiUECFG": {
        "0": {  # ue0
            "detach_request": True,
            "power_reset": "true",
            "apn": "wap1nokiacom",
        },
    },
}

CASE_INPUT_CB009301 = {
    "TC1": {
            "dist_name": "MRBTS-10035/MNL-1/MNLENT-1/FEATCADM-1",
            "filter_param": "Activate eCPRI delay measurement",
            "abbr": "actEcpriDelayMeasurement",
            "9301_Mo_num": "2",
    },
    "TC2": {
            "loop_times": "3",
            "duration_target": "600"
    },
}

CASE_INPUT_5GC000829 = {
    "dcap_server_ip": "host-10-70-230-71",
    "dcap_server_port": "443",
    "cellIndexOfPrimary": [1],
    "cellIndexOfSecondary": [2],
    "829_A_009": {
        "BBMODs_Reset": [
            {"index": 1, "Rus": [{"index": 1, "Cells": [{"index": 1}]}]},
            {"index": 3, "Rus": [{"index": 3, "Cells": [{"index": 2}]}]},
        ],
        "RMODs_Reset": [
            {"index": 1, "Cells": [{"index": 1}]},
            {"index": 3, "Cells": [{"index": 2}]},
        ],
        "RMODs_LockAndUnlock": [
            {"index": 1, "Cells": [{"index": 1}]},
            {"index": 3, "Cells": [{"index": 2}]},
        ],
        "CELLs_LockAndUnlock": [{"index": 1}, {"index": 2}],
    },
    "829_A_010": {"nrcell": "1"},
    "829_A_021": {"call_cell_index": 1, "lock_unlock_cell_index": []},
    "829_A_022": {"call_cell_index": 2, "lock_unlock_cell_index": []},
}

TestLineID = "7_5_UTE5G402T1112"
prefix_of_release = "5G_"
gNBMode = "Dualcore"

CASE_INPUT_5GC002479 = {
    "TLConfiguration": "2ASIB_2ABIO_4ABIL",
    "StreamPrefix": "SBTS00_ENB_9999",
    # 'NETACT_URL': 'https://na20lbwas.qin1.srnhz.nsn-rdnet.net',
    # 'NETACT_URL': 'https://shanxilbwas.sui6.srnhz.nsn-rdnet.net',
    "NETACT_URL": "https://gansulbwas.gansu.srnhz.nsn-rdnet.net/",
    "NETACT_USER": "omc",
    # 'NETACT_PASSWORD': 'Nokia123!',
    "NETACT_PASSWORD": "Nokia126_",
    # 'NETACT_LOGSERVER_IP': '10.107.178.201',
    # 'NETACT_LOGSERVER_IP': '10.110.144.147', #this is shanxi
    # this is gansu
    "NETACT_LOGSERVER_IP": "10.108.248.82",
    "NETACT_LOGSERVER_USERNAME": "omc",
    "NETACT_LOGSERVER_PASSWORD": "Nokia126_",
    "5GC002479_HA_KPI1a": {
        "WebUI_reset_times": "5",
    },
    "5GC002479_HA_KPI3": {
        "Power_reset_times": "5",
    },
    "CB006939_HA_KPI51a": {
        "RF_Reset_Times": "2",
    },
    "CB006939_HA_KPI54a": {
        "RU_Reset_Times": "2",
    },
    "5GC002479_IA": {
        "OriginalStream": "SBTS22R3_ENB_0000",
        "OriginalStreamSCF": "OriginalStreamSCF.xml",
        "SecondaryUTEVMIP": "10.57.167.209",
        "SecondaryTLName": "7_5_UTE5G402T1112",
    },
    "5GC002479_HA_07": {
        "CellLockUnLockDurtion": "40",
    },
}

CASE_INPUT_5GC000732 = {
    "5GC000732": {
        "StreamPrefix": "5G_",
        "5GRU_PA_Ports": [13, 14, 15, 16],
        "PA_Value_default": 0,
    },
    "5GC000732_A_03": {
        "PA_Value_1": 0,
        "PA_Value_2": 80,
    },
    "5GC000732_F_02": {
        "PA_Value_1": 0,
        "PA_Value_2": 80,
        "PA_Value_3": 35,
    },
}

CASE_INPUT_CB007958 = {
    "mPlaneIpAddress": "7.7.7.7",
    "mPlaneIpPrefix": 24,
    "defaultGateway": "10.68.88.1",
    "identificationServerIpAddress": "10.110.144.153",
    "secondaryMPlaneIpAddress": "10.68.88.19",
    "secondaryMPlaneIpPrefix": 27,
}

CASE_INPUT_CB012611 = {
    "host": "10.68.88.19",
    "username": "toor4nsn",
    "password": "oZPS0POrRieRtu",
    "cell_index_e": ['2'],
    "KPI10b_cell_index_e": ['2'],
    "duration_target": "418",
    "KPI10b_command1": 'bsh 1:0 "cd /sys/kernel/debug/oip-2-0054;echo 0x17 > addr"',
    "KPI10b_command2": 'bsh 1:0 "cd /sys/kernel/debug/oip-2-0054;echo 0 > data;cat data"',
    "KPI10b_command3": 'bsh 1:0 "cd /sys/kernel/debug/oip-2-0054;echo 3 > data;cat data"',
    "KPI10b_loop_times": "1",
    "KPI10b_duration_target": "480",
    "Power_reset": {
            "IP": "10.68.87.12",
            "Port": '1',
            "Model": "HBTE",
    },
}
