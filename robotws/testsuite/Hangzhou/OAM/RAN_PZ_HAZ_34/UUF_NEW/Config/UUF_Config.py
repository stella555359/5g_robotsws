from UUF_Alarms import *

Specific_Upgrade_TL = {
    "596": ["gnb_0", "enb_0", ],
    "315": ["gnb_0"],
    "748": ["gnb_0"],
    "869": ["gnb_0", "gnb_1"],
}
Specific_Rollback_TL = {
    "596": ["gnb_0", "enb_0", ],
    "315": ["gnb_0"],
    "748": ["gnb_0"],
    "869": ["gnb_1", "gnb_0"],
}
Specific_Reset_TL = {
    "596": ["gnb_0", "enb_0", ],
    "315": ["gnb_0"],
    "748": ["gnb_0"],
    "869": ["gnb_0", "gnb_1"],
}

# TMO LTE-NR decoupling Testline
# TMO_DECOUPLING_TL = ["838", "847", "852", "875"]
INDEPENDENT_DU_SW_UPGRADE_TL = []
SEQUENTIAL_RU_SW_UPGRADE_TL = []

# Auto Enable LMI Script TL
AUTO_ENABLE_LMI_TL = []

# Downgrade Firmware before UUF upgrade
DOWNGRADE_FIRMWARE_TL = [
    "97", "98", "291", "292", "310", "591", "575", "805",
    "847", "851", "852", "868", "869", "871", "875", "882", "890",
    "858", "806", "863", "4294967208"
]
DOWNGRADE_FIRMWARE_REPEAT_TL = ["871", "847", "882", "575"]

# Use AdminCLI for UUF function
UUF_PROCESS_ADMIN_TL = [
    "97", "98", "291", "292", "310", "570", "575", "591", "805",
    "838", "847", "851", "852", "868", "869", "871", "875", "882", "890",
    "858", "4294967208", "863", "806"
]

TL_SPECIFIC_ALLOWED_ACTIVE_FAULTS = {
    # # 6129 EN DSS Setup Failure - Max EN DSS Counter Value reached - No DSS Partner Cell
    # "851": [6129, 6351, 1898],
    # "871": [4589],
    # # PPS reference missing
    # TL869 4589 intoduced cause by uCCS rollback to Previous CCS
    # uCCS introduce: SRM6/ERM6 from 25R2, CAT6/FRU6 from 25R1
    "852": [1898, 6930, 4293, 6261],
    "875": [1898, 4298],
    "847": [1898, 4385],
    "600": [6351],
    "599": [6351],
    "292": [4589],
    "869": [4589],
}
TL_SPECIFIC_ALLOWED_HISTORY_FAULTS = {
    # # 4389,  # OTDOA PRS transmission disabled
    # # 6351,  # System information broadcast parameters overflow
    # # # - Fault 6351 doesn’t impact site reset procedure,
    # # # - it’s only for information that SIB related parameters were changed
    # # #   for more than 32 times during last 3 hours
    # # # - System works as expected.
    "871": [4389, 6351],
    "851": [6351],
    "875": [4298],
    "852": [6930, 4681, 6261],
    "847": [4385, 6261],
    "600": [6351],
    "599": [6351],
    "282": [7108, 4731],
    "292": [4589],
    "869": [4589],
}

# Wait Active Fault Disapper After UUF Upgrade/Rollback/Reset
# Data Format:
# - List: Only Contains Faults
# - Dictionary: Contain fault_list, retry, retry_interval
# Example:
# "505": {"fault_list": [4389, 6351], "retry": "20m", "retry_interval": "1m"},
# "505": [4389, 6351],
TL_WAITING_DISAPPEAR_ACTIVE_FAULT = {
    # "505": {"fault_list": [4389, 6351], "retry": "20m", "retry_interval": "1m"},
    # "805": [4389, 6351],
}

SERIAL_CONSOLE_ACTIVATED_TL = {
    "875": ["enb_0"],
    # "852": ["enb_0"],
    "845": ["gnb_0"],
    "868": ["gnb_0"],
    "882": ["gnb_0"],
    "805": ["gnb_0"],
}

Exclude_Log_Collection_TL = {
    # "288": ["gnb_snapshot", "enb_syslog", "ru_log", "passlog"],
    # "89": ["ru_log", "snapshot"],
    # "10117": ["snapshot"],
    # "288": ["enb_snapshot"],
    "847": ["passlog"],
    # "838": ["passlog"],
    "852": ["passlog"],
    "875": ["passlog"],
    # "98": ["passlog"],
    # "882": ["passlog"],
    "291": ["passlog"],
    # "869": ["passlog"],
    # "851": ["passlog"],
    # "871": ["passlog"],
}

Exclude_Check_Point_TL = {
    # "288": {
    #     "enb_0": ["cell_status", "hardware_status"],
    # },
}

Extra_Stop_Flag_TL = {
    # "89": {
    #     "enb_0": {
    #         "active": [1956],
    #     },
    #     "gnb_0": {
    #         "active": [1956],
    #         "history": [1956],
    #     },
    # },
    # "805": {
    #     "gnb_0": {
    #         "active": [1981, 1904],
    #         "history": [1981, 1904],
    #     },
    # },
}

"""UUF_L3CALL config explanation:
    "868": {          --------tl_index
        "gnb_0": {    --------gnb/enb index
            "0":      --------ue_index
                {"ue_reboot": False, "attach_only": True, "dl_tp": "10", "dl_tp_ratio": "1", "ul_tp": "5",
                 "ul_tp_ratio": "1", "duration": "60", "actImgGeneration": False,
                 "connected_RU": ['K9182103369', 'BL2120V0CVO', 'L1205002772'],
                  ----ue_${ue_index} physical connected RU SN
                 "L3CALL_band": ['N71', 'N41', 'N25', 'B12', 'B71', 'B41', 'B2']}
                  ----ue_${ue_index} supported band, one band number corresponding to multi-cells
                  ----tester can remove one or more band if temporarily no need test this band call
                 """
UUF_L3Call = {
    "868": {
        "gnb_0": {
            "0":
                {"ue_reboot": False, "attach_only": True, "dl_tp": "10", "dl_tp_ratio": "1", "ul_tp": "5",
                 "ul_tp_ratio": "1", "duration": "60", "actImgGeneration": False,
                 "connected_RU": ['BL2114G1A7P', 'BL2133V0HYH', 'L1205002772'],
                 "L3CALL_band": ['N71', 'N41', 'N25', 'B71', 'B12', 'B2', 'B41', 'B4'],
                 "arfcn_192": '66686',
                 "band_192": 'B66'},
            "1":
                {"ue_reboot": False, "attach_only": True, "dl_tp": "10", "dl_tp_ratio": "1", "ul_tp": "5",
                 "ul_tp_ratio": "1", "duration": "60", "actImgGeneration": False,
                 "connected_RU": ['BL2114G1A7T', 'BL2133V0HZG', 'K9214824402'],
                 "L3CALL_band": ['N71', 'N41', 'N25', 'B71', 'B12', 'B2', 'B41', 'B4'],
                 "arfcn_415": '66686',
                 "band_415": 'B66'},
            "2":
                {"ue_reboot": False, "attach_only": True, "dl_tp": "10", "dl_tp_ratio": "1", "ul_tp": "5",
                 "ul_tp_ratio": "1", "duration": "60", "actImgGeneration": False,
                 "connected_RU": ['BL2118G1DOR', 'BL2120V0CVO', 'K9221730258'],
                 "L3CALL_band": ['N71', 'N41', 'N25', 'B71', 'B12', 'B2', 'B41', 'B4'],
                 "arfcn_446": '66811',
                 "band_446": 'B66'}
        }
    },
    "575": {
        "gnb_0": {
            "0":
                {"ue_reboot": False, "attach_only": True, "dl_tp": "10", "dl_tp_ratio": "1", "ul_tp": "5",
                 "ul_tp_ratio": "1", "duration": "60", "actImgGeneration": False,
                 "connected_RU": ['4H210730019', '4H210530077'],
                 "L3CALL_band": ['N77']}
        }
    },
    "596": {
        "gnb_0": {
            "0":
                {"ue_reboot": False, "attach_only": False, "dl_tp": "1500", "dl_tp_ratio": "0.1", "ul_tp": "300",
                 "ul_tp_ratio": "0.05", "duration": "1200", "actImgGeneration": False,
                 "connected_RU": ['1M202406691'],
                 "L3CALL_band": ['N78']}
        }
    },
    "599": {
        "gnb_0": {
            "0":
                {"ue_reboot": False, "attach_only": False, "dl_tp": "1500", "dl_tp_ratio": "0.4", "ul_tp": "300",
                 "ul_tp_ratio": "0.1", "duration": "1200", "actImgGeneration": False,
                 "connected_RU": ['1M203907047'],
                 "L3CALL_band": ['N78']}
        }
    },
    "600": {
        "gnb_0": {
            "0":
                {"ue_reboot": False, "attach_only": False, "dl_tp": "1500", "dl_tp_ratio": "0.4", "ul_tp": "300",
                 "ul_tp_ratio": "0.1", "duration": "1200", "actImgGeneration": False,
                 "connected_RU": ['1M222026259'],
                 "L3CALL_band": ['N78']}
        }
    },
    "315": {
        "gnb_0": {
            "0":
                {"ue_reboot": False, "attach_only": False, "dl_tp": "1500", "dl_tp_ratio": "0.4", "ul_tp": "300",
                 "ul_tp_ratio": "0.1", "duration": "1200", "actImgGeneration": False,
                 "connected_RU": ['1M221311532'],
                 "L3CALL_band": ['N78']}
        }
    },
    "312": {
        "gnb_0": {
            "0":
                {"ue_reboot": False, "attach_only": False, "dl_tp": "1500", "dl_tp_ratio": "0.1", "ul_tp": "300",
                 "ul_tp_ratio": "0.05", "duration": "1200", "actImgGeneration": False,
                 "connected_RU": ['1M202406694'],
                 "L3CALL_band": ['N78']}
        }
    }
}

E2E_TL = ["312", "596", "315", "599", "600"]
