# GoldenSCF_ON_GIT = "/opt/transformers.dynamic.nsn-net.net/gnb_configuration/Hangzhou/7_5_UTE5G402T1112/"

TestLineID = "7_5_UTE5G402T204"
prefix_of_release = "5G_"

STREAM_INFOs = {
    "SBTS23R4_ENB_0000": {
        "StreamPrefix": "SBTS23R4",
        "GoldenSCF": "/SCF_SBTS00.xml",
    },
    "SBTS24R2_ENB_0000": {
        "StreamPrefix": "SBTS24R2",
        "GoldenSCF": "/SCF_SBTS00.xml",
    },
    "SBTS25R2_ENB_0000": {
        "StreamPrefix": "SBTS25R2",
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
    "SBTS00_ENB_9999": {
        "StreamPrefix": "SBTS00",
        "GoldenSCF": "/SCF_SBTS00.xml",
    },
}

CASE_INPUT_CB009301 = {
    "TC1": {
            "dist_name": "MRBTS-10035/MNL-1/MNLENT-1/FEATCADM-1",
            "filter_param": "Activate eCPRI delay measurement",
            "abbr": "actEcpriDelayMeasurement",
            "9301_Mo_num": "6",
    },
    "TC2": {
            "loop_times": "3",
            "duration_target": "600"
    },
}
