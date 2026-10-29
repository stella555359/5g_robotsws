GoldenSCF_ON_GIT = "/home/ute/MN/UTE/robotws//commissionings/HGZ/7_5_UTE5G402T014/"
GoldenSCF = "SCF_SBTS00.xml"

STREAM_INFOs = {
    "SBTS00_ENB_9999": {"StreamPrefix": "SBTSTRUNK", "GoldenSCF": "/SCF_SBTS00.xml"},
    "SBTS00_ENB_9200": {"StreamPrefix": "SBTSTRUNK", "GoldenSCF": "/SCF_SBTS00.xml"},
    "SBTS00_ENB_9990": {"StreamPrefix": "SBTSTRUNK", "GoldenSCF": "/SCF_SBTS00.xml"},
    "SBTS23R3_ENB_0000": {"StreamPrefix": "SBTS23R3", "GoldenSCF": "/SCF_SBTS23R3.xml"},
    "SBTS23R4_ENB_0000": {"StreamPrefix": "SBTS23R4", "GoldenSCF": "/SCF_SBTS23R4.xml"},
    "SBTS24R1_ENB_0000": {"StreamPrefix": "SBTS24R1", "GoldenSCF": "/SCF_SBTS24R1.xml"},
    "SBTS24R2_ENB_0000": {"StreamPrefix": "SBTS24R2", "GoldenSCF": "/SCF_SBTS24R2.xml"},
    "SBTS24R3_ENB_0000": {"StreamPrefix": "SBTS24R3", "GoldenSCF": "/SCF_SBTS24R3.xml"},
    "SBTS25R1_ENB_0000": {"StreamPrefix": "SBTS25R1", "GoldenSCF": "/SCF_SBTS25R1.xml"},
    "SBTS25R2_ENB_0000": {"StreamPrefix": "SBTS25R2", "GoldenSCF": "/SCF_SBTS25R2.xml"},
    "SBTS25R3_ENB_0000": {"StreamPrefix": "SBTS25R3", "GoldenSCF": "/SCF_SBTS25R3.xml"},
    "SBTS26R1_ENB_0000": {"StreamPrefix": "SBTS26R1", "GoldenSCF": "/SCF_SBTS26R1.xml"},
}

CASE_INPUT_5GC000829 = {
    "dcap_server_ip": "10.101.60.28",
    "dcap_server_port": "443",
    "cellIndexOfPrimary": [1],
    "cellIndexOfSecondary": [2],
    "829_A_009": {
        "BBMODs_Reset": [
            {"index": 1, "Rus": [{"index": 1, "Cells": [{"index": 1}]}]},
            {"index": 2, "Rus": [{"index": 2, "Cells": [{"index": 2}]}]},
        ],
        "RMODs_Reset": [
            {"index": 1, "Cells": [{"index": 1}]},
            {"index": 2, "Cells": [{"index": 2}]},
        ],
        "RMODs_LockAndUnlock": [
            {"index": 1, "Cells": [{"index": 1}]},
            {"index": 2, "Cells": [{"index": 2}]},
        ],
        "CELLs_LockAndUnlock": [{"index": 1}, {"index": 2}],
    },
    "829_A_010": {"nrcell": "2"},
    "829_A_021": {"call_cell_index": 1, "lock_unlock_cell_index": [2]},
    "829_A_022": {"call_cell_index": 2, "lock_unlock_cell_index": [1]},
}

CASE_INPUT_5GC001932 = {
    "file_server_ip": "10.57.195.7",
    "file_server_username": "ute",
    "file_server_password": "iW_K#8.ute%A10h0m0ra",
}

TLCommonConfig = {
    "MultiUECFG": {
        "ue_index_for_call": ["1"],
        "0": {
            "detach_request": "true",
            "power_reset": "true",
            "apn": "dxdata2",
            "cell_index_list": ["2"],
        },
        "1": {
            "detach_request": "true",
            "power_reset": "true",
            "apn": "dxdata2",
        },
    }
}

CASE_INPUT_CB007958 = {
    "mPlaneIpAddress": "7.7.7.7",
    "mPlaneIpPrefix": 24,
    "defaultGateway": "10.71.215.65",
    "identificationServerIpAddress": "10.110.144.153",
    "secondaryMPlaneIpAddress": "10.71.215.70",
    "secondaryMPlaneIpPrefix": 27,
}
