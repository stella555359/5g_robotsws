import os

__team__ = "MN 5G RAN I&V 4 Pz HZG SG1"
__email__ = "I_MN_5G_RAN_IV4_LINE_HZG_1@internal.nsn.com"

# GoldenSCF='/Trunk/SCF_TDD_CPRI_ASIK_AEQA_TL108_3CELL_v6.xml'
# GoldenSCF='/opt/transformers.dynamic.nsn-net.net/gnb_configuration/Hangzhou/7_5_CLOUD402T014/GoldenSCF.xml'
# GoldenSCF='/21B/5G21B_FDD_Classical_RFSharing_10MHz_three_cells_v20.xml'

TLSCF_CELL_NUMs = [1, 2]

CASE_INPUT_5GC002479 = {
    "5GC002479": {
        "StreamPrefix": "5G_",
        "NETACT_URL": "https://shanxilbwas.sui6.srnhz.nsn-rdnet.net",
        "NETACT_USER": "omc",
        "NETACT_PASSWORD": "Nokia126_",
        "NETACT_LOGSERVER_IP": "10.110.144.140",
        "NETACT_LOGSERVER_USERNAME": "root",
        "NETACT_LOGSERVER_PASSWORD": "arthur",
    },
    "5GC002479_AA_01": {
        "Duration_SCFLoad": "20",
        "Duration_ValidationError": "270",
        "Duration_Validation": "140",
        "Duration_Activation": "575",
    },
    "5GC002479_AA_02": {
        "Duration_DeltaValidation": "1000",
    },
    "5GC002479_AA_03": {
        "SCF_backup_duration": "30",
    },
    "5GC002479_AA_04": {
        "Duration_DeltaActivation": "600",
    },
    "5GC002479_AA_05": {
        "Delta_Plan_Provision_Durtion": "110",
    },
    "5GC002479_AA_06": {
        "Full_Plan_Provision_Durtion": "635",
    },
    "5GC002479_AA_07": {
        "Delta_Plan_PreProvision_Durtion": "60",
    },
    "5GC002479_AA_08": {
        "Import_Delta_Plan_Durtion": "20",
    },
    "5GC002479_AA_09": {
        "Delta_Plan_Provision_Durtion_Reboot": "635",
    },
    "5GC002479_AA_10": {
        "CMUplod_Durtion": "30",
    },
    "5GC002479_AA_11": {
        "Duration_ChangeNoti": "17",
    },
    "5GC002479_BA_02": {
        "Duration_PM_Kept": "180",
    },  # should be 86400  24h  / 180 for test
    "5GC002479_BA_03": {
        "PM_MAX_Size": "272.7",
    },
    "5GC002479_BA_04": {
        "CPU_Jitter": "4",
    },
    "5GC002479_CA_01": {
        "alarm_report_time": "10",
    },
    "5GC002479_CA_02": {
        "Alarm_Upload_Durtion": "55",
    },
    "5GC002479_DA_01": {
        "snapshot_save_time": "900",
    },
    "5GC002479_DA_02": {
        "FilePresentTime": "15",
    },
    "5GC002479_DA_03": {
        "StartAndStopLtency": "15",
    },
    "5GC002479_FA_01": {
        "MaxFileSize": "2147483648",
    },
    "5GC002479_FA_02": {
        "MaxSession": "10",
    },
    "5GC002479_FA_03": {
        "Duration_Loading_WebEM": "5",
    },
    "5GC002479_FA_04": {
        "Login_duration_time": "25",
    },
    "5GC002479_FA_05": {
        "StartupView_Login_duration_time": "30",
    },
    "5GC002479_FA_06": {
        "RMToolSessionCount": "5",
    },
    "5GC002479_FA_07": {
        "RMToolRequestLatency": "30",
    },
    "5GC002479_FA_08": {
        "RMToolConnectionLatency": "30",
    },
    "5GC002479_FA_09": {
        "RMToolRequestLatencyServerMode": "5",
    },
    "5GC002479_HA_07": {
        "CellLockUnLockDurtion": "40",
    },
    "5GC002479_IA": {
        "OriginalStream": "5G_0.800",
        "OriginalStreamSCF": "OriginalStreamSCF.xml",  # please fill following on dualcore env
        "SecondaryUTEVMIP": "10.57.155.4",
        "SecondaryTLName": "7_5_CLOUD402T014",
    },
    "5GC002479_IA_01": {
        "SW_Download_MAX": "900",
    },
    "5GC002479_IA_KPI2a": {
        "KPI2a_AVG": "660",
        "KPI2a_MAX": "792",
    },
    "5GC002479_IA_KPI2b": {
        "KPI2b_AVG": "900",
        "KPI2b_MAX": "1080",
    },
    "5GC002479_IA_KPI2c": {
        "KPI2c_AVG": "480",
        "KPI2c_MAX": "576",
    },
    "5GC002479_IA_KPI2d": {
        "KPI2d_AVG": "720",
        "KPI2d_MAX": "888",
    },
    "5GC002479_IA_KPI2e": {
        "KPI2e_AVG": "720",
        "KPI2e_MAX": "888",
    },
    "5GC002479_IA_KPI4": {
        "KPI4_AVG": "1320",
        "KPI4_MAX": "1584",
    },
    "5GC002479_IA_KPI4a": {
        "KPI4a_AVG": "1560",
        "KPI4a_MAX": "1872",
    },
}

CASE_INPUT_5GC001932 = {
    "ALD_RMOD": [2],
}

CASE_INPUT_5GC001473 = {
    "1473_K": {
        "ue_index": "1",
        "apn": "wap1nokiacom",
        "cell_index": "2",
    },
}

# modify Golden to TL202 SCF 2CELL both#
TL_PARAMS_TO_DELETE_1CELL = []

TL_ADD_MOS_1CELL = []

TL_LIST_TO_ADD_1CELL = []

TL_PARAMS_TO_MODIFY_1CELL = []

TL_LIST_PARAMS_TO_MODIFY_1CELL = []

# modify Golden to TL202 SCF 2CELL both#
TL_PARAMS_TO_DELETE_2CELL = TL_PARAMS_TO_DELETE_1CELL


TL_ADD_MOS_2CELL = TL_ADD_MOS_1CELL

TL_LIST_TO_ADD_2CELL = TL_LIST_TO_ADD_1CELL

TL_PARAMS_TO_MODIFY_2CELL = TL_PARAMS_TO_MODIFY_1CELL

TL_LIST_PARAMS_TO_MODIFY_2CELL = TL_LIST_PARAMS_TO_MODIFY_1CELL
