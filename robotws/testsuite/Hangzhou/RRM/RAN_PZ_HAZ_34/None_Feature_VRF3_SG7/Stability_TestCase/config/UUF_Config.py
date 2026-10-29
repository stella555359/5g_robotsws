from UUF_Alarms import *

Specific_Upgrade_TL = {
    "851": ["enb_0", "gnb_0", ],
    "596": ["gnb_0", "enb_0", ],
    "315": ["gnb_0", "enb_0", ],
    "748": ["gnb_0"],
}
Specific_Rollback_TL = {
    "851": ["gnb_0", "enb_0", ],
    "596": ["gnb_0", "enb_0", ],
    "315": ["gnb_0", "enb_0", ],
    "748": ["gnb_0"],
}
Specific_Reset_TL = {
    "851": ["gnb_0", "enb_0", ],
    "596": ["gnb_0", "enb_0", ],
    "315": ["gnb_0", "enb_0", ],
    "748": ["gnb_0"],
}

DOWNGRADE_FIRMWARE_TL = ["90", "869", "306"]

UUF_PROCESS_ADMIN_TL = ["838", "847", "852", "875", "851", "869"]

TL_SPECIFIC_ALLOWED_ACTIVE_FAULTS = {
    # # 6129 EN DSS Setup Failure - Max EN DSS Counter Value reached - No DSS Partner Cell
    "851": [6129, 6351, 1898],
    # "871": [6129, 6351],
    # # PPS reference missing
    "852": [1898, 6930],
    "875": [1898, 4298],
    "847": [1898, 4385],
    "505": [4728],
    "600": [6351],
    "599": [6351],
    "882": [2403, 4681],

}
TL_SPECIFIC_ALLOWED_HISTORY_FAULTS = {
    # "871": DSS_HISTORY_FAULTS,
    # "851": DSS_HISTORY_FAULTS

    # # 4389,  # OTDOA PRS transmission disabled
    # # 6351,  # System information broadcast parameters overflow
    # # # - Fault 6351 doesn’t impact site reset procedure,
    # # # - it’s only for information that SIB related parameters were changed
    # # #   for more than 32 times during last 3 hours
    # # # - System works as expected.
    "871": [4389, 6351],
    "851": [6351],
    "875": [4298],
    "852": [6930],
    "847": [4385],
    # # 1912,  # Radio autonomous reset as recovery action
    # #          Concurrent CPRI LINK Drop known issue in CuDo.
    # # 4562,  # Antenna Carrier Failure
    "288": [1912, 4562],
    "505": [4728],
    "292": [6450],
    "600": [6351],
    "599": [6351],
    "882": [2403, 4681],
}

# Wait Active Fault Disapper After UUF Upgrade/Rollback/Reset
# Data Format:
# - List: Only Contains Faults
# - Dictionary: Contain fault_list, retry, retry_interval
# Example:
# "505": {"fault_list": [4389, 6351], "retry": "20m", "retry_interval": "1m"},
# "505": [4389, 6351],
TL_WAITING_DISAPPEAR_ACTIVE_FAULT = {
    "505": {"fault_list": [4389, 6351], "retry": "20m", "retry_interval": "1m"},
    "805": [4389, 6351],
}

SERIAL_CONSOLE_ACTIVATED_TL = {
    "838": ["enb_1"],
    "847": ["enb_2"],
    "868": ["gnb_0"],
    "292": ["gnb_0"],
    "871": ["gnb_0"],
    "851": ["gnb_0"],
}

Exclude_Log_Collection_TL = {
    # "288": ["gnb_snapshot", "enb_syslog", "ru_log", "passlog"],
    # "89": ["ru_log", "snapshot"],
    # "10117": ["snapshot"],
    # "288": ["enb_snapshot"],
    "883": ["passlog"],
    "888": ["passlog"],
    "847": ["passlog"],
    "852": ["passlog"],
}

Exclude_Check_Point_TL = {
    # "288": {
    #     "enb_0": ["cell_status", "hardware_status"],
    # },
}

Extra_Stop_Flag_TL = {
    "89": {
        "enb_0": {
            "active": [1956],
        },
        "gnb_0": {
            "active": [1956],
            "history": [1956],
        },
    },
    "838": {
        "gnb_0": {
            "active": [2087],
            "history": [2087],
        },
    },
    "871": {
        "gnb_0": {
            "active": [1981, 1904],
            # "history": [1981, 1904],
        },
    },
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
                 "connected_RU": ['K9182103369', 'BL2120V0CVO', 'K9221730258'],
                 "L3CALL_band": ['N71', 'N41', 'N25', 'B71', 'B12', 'B2', 'B41', 'B4'],
                 "arfcn_248": '66686',
                 "band_248": 'B66'}
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
