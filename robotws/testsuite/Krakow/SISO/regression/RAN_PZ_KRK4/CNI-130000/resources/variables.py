RF_ALARM_TRIGGER_DATA = {
    'A5G067': {
        "additional_allowed_alarms": [
            "No X2 link available",
            "No X2 link available for a specific LTEENB",
            "No connection to unit",
            "Fault signature for crash or failure",
            "BTS configuration error (not enough HW for LCR)",
            "Unit power reset"
        ],
        "commands": [
            "sudo devmem2 0xFB900100 w 0x4018035"
        ],
        "expected_alarms": {
            "raw_fault_ids": [
                r"EFaultId_AbfcMessageFailure\s\(1386\)",
                r"EFaultId_SBFC_Error\s\(1488\)",
                r"EFaultId_FIFO_FULL_Error\s\(1492\)"
            ],
            "bts_faults": [
                "Radio autonomous reset as recovery action",
                "TX out of order",
                "RF Module out of order"
            ]
        },
        "ignored_raw_fault_ids": [
            r"EFaultId_BMUFault\s\(1461\)"
        ]
    },
    'A5G160': {
        "additional_allowed_alarms": [
            "No X2 link available",
            "No X2 link available for a specific LTEENB",
            "BTS configuration error (not enough HW for LCR)",
            "F1 SCTP endpoint in DU",
            "No connection to unit",
            "RF module configuring failed",
            "Fault signature for crash or failure",
            "Unit power reset"
        ],
        "commands": [
            "sudo devmem2 0xfb94047c w 0x05005011",
            "sudo devmem2 0xfb940480 w 0x05005011",
            "sudo devmem2 0xfb940484 w 0x05005011",
            "sudo devmem2 0xfb940488 w 0x05005011"
        ],
        "expected_alarms": {
            "raw_fault_ids": [
                r"EFaultId_ParityError\s\(1487\)",
                r"EfaultId_ProcessCrash\s\(1463\)"
            ],
            "bts_faults": [
                "Radio autonomous reset as recovery action",
                "RF Module out of order",
                "RF module configuring failed"
            ]
        },
        "ignored_raw_fault_ids": [
            r"EFaultId_BMUFault\s\(1461\)"
        ]
    },
    'A5G163': {
        "additional_allowed_alarms": [
            "No X2 link available",
            "No X2 link available for a specific LTEENB",
            "Fault signature for crash or failure",
            "BTS configuration error (not enough HW for LCR)",
            "Unit power reset"
        ],
        "commands": [
            "sudo devmem2 0xFB9401FC w 0x15770001",
            "sudo devmem2 0xFB9401FC w 0x15770003"
        ],
        "expected_alarms": {
            "raw_fault_ids": [
                r"EFaultId_FIFO_FULL_Error\s\(1492\)",
                r"EFaultId_AbfcMessageFailure\s\(1386\)"
            ],
            "bts_faults": [
                "Radio autonomous reset as recovery action",
                "TX out of order",
                "RF Module out of order"
            ]
        },
        "ignored_raw_fault_ids": [
            r"EFaultId_BMUFault\s\(1461\)"
        ]
    },
    'A5G164': {
        "additional_allowed_alarms": [
            "No X2 link available",
            "No X2 link available for a specific LTEENB",
            "TX out of order",
            "Cooling fan broken",
            "Unit power reset",
            "No connection to unit",
        ],
        "commands": [
            "sudo devmem2 0xFC881160 w 0x00000006"
        ],
        "expected_alarms": {
            "raw_fault_ids": [
                r"EFaultId_BFIC_DeviceConnectionError\s\(1490\)",
                r"EFaultId_AntennaModuleDeviceError\s\(1491\)",
                r"EFaultId_AntennaSubmodulePllUnlocked\s\(1361\)"
            ],
            "bts_faults": [
                "Radio autonomous reset as recovery action",
                "Radio module hardware failure",
                "TX out of order"
            ]
        },
        "ignored_raw_fault_ids": [
            r"EFaultId_BMUFault\s\(1461\)"
        ]
    }
}

RAD_FLAGS_RU_RECOVERY_RESET = {
    "disable": {
        "0xe5": {
            "value": "2",
            "options": "mpw"
        },
        "0xc0015": {
            "value": "1",
            "options": "mpw"
        },
        "0xe6": {
            "value": "2",
            "options": "mpw"
        },
    },
    "enable": {
        "0xe5": {
            "value": "0",
            "options": "mpw"
        },
        "0xc0015": {
            "value": "0",
            "options": "mpw"
        },
        "0xe6": {
            "value": "0",
            "options": "mpw"
        },
    }
}

AWKUC_ID = 0
