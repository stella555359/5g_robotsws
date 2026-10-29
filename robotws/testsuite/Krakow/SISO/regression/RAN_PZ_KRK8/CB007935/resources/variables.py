ruSynceRearrangement = {"rmod": "M40121C0", "asirmod": "M40501C0"}

ruSynceEstHoldoverTime = {"rmod": "M40122C0", "asirmod": "M40502C0"}

parameter_distnames = {
    "rmod": {
        "synceStatus": "MRBTS-79110/MNL-1/MNLENT-1/SYNC-3/CLOCK-1/SYNCE-1/SYNCE_R-1",
        "ssmValue": "MRBTS-79110/MNL-1/MNLENT-1/SYNC-3/CLOCK-1/SYNCE-1/SYNCE_R-1",
        "syncStatus": "MRBTS-79110/MNL-1/MNLENT-1/SYNC-3/CLOCK-1/CLOCK_R-1",
        "ruAssistedHoPeriod": "MRBTS-79110/MNL-1/MNLENT-1/SYNC-3/CLOCK-1/CLOCK_R-1"
    },
    "asirmod": {
        "synceStatus": "MRBTS-75030/MNL-1/MNLENT-1/SYNC-2/CLOCK-1/SYNCE-1/SYNCE_R-1",
        "ssmValue": "MRBTS-75030/MNL-1/MNLENT-1/SYNC-2/CLOCK-1/SYNCE-1/SYNCE_R-1",
        "syncStatus": "MRBTS-75030/MNL-1/MNLENT-1/SYNC-2/CLOCK-1/CLOCK_R-1",
        "ruAssistedHoPeriod": "MRBTS-75030/MNL-1/MNLENT-1/SYNC-2/CLOCK-1/CLOCK_R-1"
    }
}

synce_drop_commands = {"rmod": [
    "config interface t24ps1 1/3/C5 25gbe synceoppmode non sync",
    "config interface t24ps1 1/3/C7 25gbe synceoppmode non sync"
],
    "asirmod": [
        "config interface t24ps1 1/3/C3 25gbe synceoppmode non sync",
        "config interface t24ps1 1/3/C1 25gbe synceoppmode non sync"
    ]
}

synce_restore_commands = {"rmod": [
    "config interface t24ps1 1/3/C5 25gbe synceoppmode sync",
    "config interface t24ps1 1/3/C7 25gbe synceoppmode sync"
],
    "asirmod": [
        "config interface t24ps1 1/3/C3 25gbe synceoppmode sync",
        "config interface t24ps1 1/3/C1 25gbe synceoppmode sync"
    ]
}

ptp_drop_commands = {"rmod": [
    "config sync 1 ptp clock1 port5 adminState down",
    "config sync 1 ptp clock1 port7 adminState down"
],
    "asirmod": [
        "config sync 1 ptp clock1 port3 adminState down",
        "config sync 1 ptp clock1 port1 adminState down"
    ]
}

restore_ptp_sync_commands = {"rmod": [
    "config sync 1 ptp clock1 port5 adminState up",
    "config sync 1 ptp clock1 port7 adminState up"
],
    "asirmod": [
        "config sync 1 ptp clock1 port3 adminState up",
        "config sync 1 ptp clock1 port1 adminState up"
    ]
}

ssm_too_low_commands = {"rmod": [
    "config interface t24ps1 1/3/C5 25gbe ssmtrans none",
    "config interface t24ps1 1/3/C7 25gbe ssmtrans none"
],
    "asirmod": [
        "config interface t24ps1 1/3/C3 25gbe ssmtrans none",
        "config interface t24ps1 1/3/C1 25gbe ssmtrans none"
    ]
}

restore_ssm_commands = {"rmod": [
    "config interface t24ps1 1/3/C5 25gbe ssmtrans act",
    "config interface t24ps1 1/3/C7 25gbe ssmtrans act"
],
    "asirmod": [
        "config interface t24ps1 1/3/C3 25gbe ssmtrans act",
        "config interface t24ps1 1/3/C1 25gbe ssmtrans act"
    ]
}

alarms_4298_16 = ['4298', '16']

CB007935_disable_delta_manual = {"rmod": [
    {
        "distName": "MRBTS-79110/MNL-1/MNLENT-1/PMMNL-1",
        "operation": "update",
        "parameters": [
            {
                "parameterName": "ruSynceHoPeriod",
                "operation": "update",
                "value": "disabled"
            },
            {
                "parameterName": "ruSynceNetworkReArrgt",
                "operation": "update",
                "value": "disabled"
            }
        ]
    },
    {
        "distName": "MRBTS-79110/MNL-1/MNLENT-1/SYNC-3",
        "operation": "update",
        "parameters": [
            {
                "parameterName": "actRuIntelligentSynceAstHoTime",
                "operation": "update",
                "value": "false"
            },
            {
                "parameterName": "maxPtpNetworkTimeErrorRuIn",
                "operation": "delete",
                "value": "2500"
            },
            {
                "parameterName": "maximumRuTimeErrorAstHoEnd",
                "operation": "delete",
                "value": "3500"
            },
            {
                "parameterName": "synceAssistedHoldoverMode",
                "operation": "delete",
                "value": "IntelligentHoldover"
            }
        ]
    },
    {
        "distName": "MRBTS-79110/MNL-1/MNLENT-1/SYNC-3/CLOCK-1/SYNCE-1",
        "operation": "delete",
        "parameters": [
            {
                "parameterName": "ruAstHoSyncePortNumber",
                "operation": "delete",
                "value": "1"
            },
            {
                "parameterName": "synceNtwReAgtForceMajor",
                "operation": "delete",
                "value": "false"
            }
        ]
    },
    {
        "distName": "MRBTS-79110/MNL-1/MNLENT-1/SYNC-3",
        "operation": "update",
        "parameters": [
            {
                "parameterName": "manualSynceAssistedHoPeriod",
                "operation": "delete",
                "value": "1"
            }]}
],
    "asirmod": [
        {
            "distName": "MRBTS-75030/MNL-1/MNLENT-1/PMMNL-1",
            "operation": "update",
            "parameters": [
                {
                    "parameterName": "ruSynceHoPeriodAsiRMod",
                    "operation": "update",
                    "value": "disabled"
                },
                {
                    "parameterName": "ruSynceNetworkReArrgtAsiRMod",
                    "operation": "update",
                    "value": "disabled"
                }
            ]
        },
        {
            "distName": "MRBTS-75030/MNL-1/MNLENT-1/SYNC-2",
            "operation": "update",
            "parameters": [
                {
                    "parameterName": "actRuIntelligentSynceAstHoTime",
                    "operation": "update",
                    "value": "false"
                },
                {
                    "parameterName": "maxPtpNetworkTimeErrorRuIn",
                    "operation": "delete",
                    "value": "2500"
                },
                {
                    "parameterName": "maximumRuTimeErrorAstHoEnd",
                    "operation": "delete",
                    "value": "3500"
                },
                {
                    "parameterName": "synceAssistedHoldoverMode",
                    "operation": "delete",
                    "value": "IntelligentHoldover"
                }
            ]
        },
        {
            "distName": "MRBTS-75030/MNL-1/MNLENT-1/SYNC-2/CLOCK-1/SYNCE-1",
            "operation": "delete",
            "parameters": [
                {
                    "parameterName": "ruAstHoSyncePortNumber",
                    "operation": "delete",
                    "value": "1"
                },
                {
                    "parameterName": "synceNtwReAgtForceMajor",
                    "operation": "delete",
                    "value": "false"
                }
            ]
        },
        {
            "distName": "MRBTS-75030/MNL-1/MNLENT-1/SYNC-2",
            "operation": "update",
            "parameters": [
                {
                    "parameterName": "manualSynceAssistedHoPeriod",
                    "operation": "delete",
                    "value": "1"
                }]}
    ]}

CB007935_enable_delta = {'rmod': [
    {
        "distName": "MRBTS-79110/MNL-1/MNLENT-1/PMMNL-1",
        "operation": "update",
        "parameters": [
            {
                "parameterName": "ruSynceHoPeriod",
                "operation": "update",
                "value": "5min"
            },
            {
                "parameterName": "ruSynceNetworkReArrgt",
                "operation": "update",
                "value": "5min"
            }
        ]
    },
    {
        "distName": "MRBTS-79110/MNL-1/MNLENT-1/SYNC-3",
        "operation": "update",
        "parameters": [
            {
                "parameterName": "actRuIntelligentSynceAstHoTime",
                "operation": "update",
                "value": "true"
            },
            {
                "parameterName": "maxPtpNetworkTimeErrorRuIn",
                "operation": "update",
                "value": "2500"
            },
            {
                "parameterName": "maximumRuTimeErrorAstHoEnd",
                "operation": "update",
                "value": "3500"
            },
            {
                "parameterName": "synceAssistedHoldoverMode",
                "operation": "update",
                "value": "IntelligentHoldover"
            }
        ]
    },
    {
        "distName": "MRBTS-79110/MNL-1/MNLENT-1/SYNC-3/CLOCK-1/SYNCE-1",
        "operation": "create",
        "parameters": [
            {
                "parameterName": "ruAstHoSyncePortNumber",
                "operation": "update",
                "value": "1"
            },
            {
                "parameterName": "ssmAcceptanceLevel",
                "operation": "update",
                "value": "ssmPRCorPRS"
            },
            {
                "parameterName": "ssmEnabled",
                "operation": "update",
                "value": "true"
            },
            {
                "parameterName": "ssmTimeout",
                "operation": "update",
                "value": "5"
            },
            {
                "parameterName": "ssmType",
                "operation": "update",
                "value": "SSM_ITU"
            },
            {
                "parameterName": "synceNtwReAgtForceMajor",
                "operation": "update",
                "value": "false"
            }
        ]
    }
],
    'asirmod': [
        {
            "distName": "MRBTS-75030/MNL-1/MNLENT-1/PMMNL-1",
            "operation": "update",
            "parameters": [
                {
                    "parameterName": "ruSynceHoPeriodAsiRMod",
                    "operation": "update",
                    "value": "5min"
                },
                {
                    "parameterName": "ruSynceNetworkReArrgtAsiRMod",
                    "operation": "update",
                    "value": "5min"
                }
            ]
        },
        {
            "distName": "MRBTS-75030/MNL-1/MNLENT-1/SYNC-2",
            "operation": "update",
            "parameters": [
                {
                    "parameterName": "actRuIntelligentSynceAstHoTime",
                    "operation": "update",
                    "value": "true"
                },
                {
                    "parameterName": "maxPtpNetworkTimeErrorRuIn",
                    "operation": "update",
                    "value": "2500"
                },
                {
                    "parameterName": "maximumRuTimeErrorAstHoEnd",
                    "operation": "update",
                    "value": "3400"
                },
                {
                    "parameterName": "synceAssistedHoldoverMode",
                    "operation": "update",
                    "value": "IntelligentHoldover"
                }
            ]
        },
        {
            "distName": "MRBTS-75030/MNL-1/MNLENT-1/SYNC-2/CLOCK-1/SYNCE-1",
            "operation": "create",
            "parameters": [
                {
                    "parameterName": "ruAstHoSyncePortNumber",
                    "operation": "update",
                    "value": "5"
                },
                {
                    "parameterName": "ssmAcceptanceLevel",
                    "operation": "update",
                    "value": "ssmPRCorPRS"
                },
                {
                    "parameterName": "ssmEnabled",
                    "operation": "update",
                    "value": "true"
                },
                {
                    "parameterName": "ssmTimeout",
                    "operation": "update",
                    "value": "8"
                },
                {
                    "parameterName": "ssmType",
                    "operation": "update",
                    "value": "SSM_ITU"
                },
                {
                    "parameterName": "synceNtwReAgtForceMajor",
                    "operation": "update",
                    "value": "false"
                }
            ]
        }
    ]}

CB007935_enable_delta_manual = {"rmod": [
    {
        "distName": "MRBTS-79110/MNL-1/MNLENT-1/PMMNL-1",
        "operation": "update",
        "parameters": [
            {
                "parameterName": "ruSynceHoPeriod",
                "operation": "update",
                "value": "5min"
            },
            {
                "parameterName": "ruSynceNetworkReArrgt",
                "operation": "update",
                "value": "5min"
            }
        ]
    },
    {
        "distName": "MRBTS-79110/MNL-1/MNLENT-1/SYNC-3",
        "operation": "update",
        "parameters": [
            {
                "parameterName": "actRuIntelligentSynceAstHoTime",
                "operation": "update",
                "value": "true"
            },
            {
                "parameterName": "maxPtpNetworkTimeErrorRuIn",
                "operation": "update",
                "value": "2500"
            },
            {
                "parameterName": "maximumRuTimeErrorAstHoEnd",
                "operation": "update",
                "value": "3500"
            },
            {
                "parameterName": "synceAssistedHoldoverMode",
                "operation": "update",
                "value": "ManualHoldover"
            }
        ]
    },
    {
        "distName": "MRBTS-79110/MNL-1/MNLENT-1/SYNC-3/CLOCK-1/SYNCE-1",
        "operation": "create",
        "parameters": [
            {
                "parameterName": "ruAstHoSyncePortNumber",
                "operation": "update",
                "value": "1"
            },
            {
                "parameterName": "ssmAcceptanceLevel",
                "operation": "update",
                "value": "ssmPRCorPRS"
            },
            {
                "parameterName": "ssmEnabled",
                "operation": "update",
                "value": "true"
            },
            {
                "parameterName": "ssmTimeout",
                "operation": "update",
                "value": "5"
            },
            {
                "parameterName": "ssmType",
                "operation": "update",
                "value": "SSM_ITU"
            },
            {
                "parameterName": "synceNtwReAgtForceMajor",
                "operation": "update",
                "value": "false"
            }
        ]
    },
    {
        "distName": "MRBTS-79110/MNL-1/MNLENT-1/SYNC-3",
        "operation": "update",
        "parameters": [
            {
                "parameterName": "manualSynceAssistedHoPeriod",
                "operation": "update",
                "value": "1"
            }]}
],
    "asirmod": [
        {
            "distName": "MRBTS-75030/MNL-1/MNLENT-1/PMMNL-1",
            "operation": "update",
            "parameters": [
                {
                    "parameterName": "ruSynceHoPeriodAsiRMod",
                    "operation": "update",
                    "value": "5min"
                },
                {
                    "parameterName": "ruSynceNetworkReArrgtAsiRMod",
                    "operation": "update",
                    "value": "5min"
                }
            ]
        },
        {
            "distName": "MRBTS-75030/MNL-1/MNLENT-1/SYNC-2",
            "operation": "update",
            "parameters": [
                {
                    "parameterName": "actRuIntelligentSynceAstHoTime",
                    "operation": "update",
                    "value": "true"
                },
                {
                    "parameterName": "maxPtpNetworkTimeErrorRuIn",
                    "operation": "update",
                    "value": "2500"
                },
                {
                    "parameterName": "maximumRuTimeErrorAstHoEnd",
                    "operation": "update",
                    "value": "3400"
                },
                {
                    "parameterName": "synceAssistedHoldoverMode",
                    "operation": "update",
                    "value": "ManualHoldover"
                },
                {
                    "parameterName": "manualSynceAssistedHoPeriod",
                    "operation": "update",
                    "value": "1"
                }
            ]
        },
        {
            "distName": "MRBTS-75030/MNL-1/MNLENT-1/SYNC-2/CLOCK-1/SYNCE-1",
            "operation": "create",
            "parameters": [
                {
                    "parameterName": "ruAstHoSyncePortNumber",
                    "operation": "update",
                    "value": "5"
                },
                {
                    "parameterName": "ssmAcceptanceLevel",
                    "operation": "update",
                    "value": "ssmPRCorPRS"
                },
                {
                    "parameterName": "ssmEnabled",
                    "operation": "update",
                    "value": "true"
                },
                {
                    "parameterName": "ssmTimeout",
                    "operation": "update",
                    "value": "8"
                },
                {
                    "parameterName": "ssmType",
                    "operation": "update",
                    "value": "SSM_ITU"
                },
                {
                    "parameterName": "synceNtwReAgtForceMajor",
                    "operation": "update",
                    "value": "false"
                }
            ]
        }
    ]
}

CB007935_disable_delta = {"rmod": [
    {
        "distName": "MRBTS-79110/MNL-1/MNLENT-1/PMMNL-1",
        "operation": "update",
        "parameters": [
            {
                "parameterName": "ruSynceHoPeriod",
                "operation": "update",
                "value": "disabled"
            },
            {
                "parameterName": "ruSynceNetworkReArrgt",
                "operation": "update",
                "value": "disabled"
            }
        ]
    },
    {
        "distName": "MRBTS-79110/MNL-1/MNLENT-1/SYNC-3",
        "operation": "update",
        "parameters": [
            {
                "parameterName": "actRuIntelligentSynceAstHoTime",
                "operation": "update",
                "value": "false"
            },
            {
                "parameterName": "maxPtpNetworkTimeErrorRuIn",
                "operation": "delete",
                "value": "2500"
            },
            {
                "parameterName": "maximumRuTimeErrorAstHoEnd",
                "operation": "delete",
                "value": "3500"
            },
            {
                "parameterName": "synceAssistedHoldoverMode",
                "operation": "delete",
                "value": "IntelligentHoldover"
            }
        ]
    },
    {
        "distName": "MRBTS-79110/MNL-1/MNLENT-1/SYNC-3/CLOCK-1/SYNCE-1",
        "operation": "delete",
        "parameters": [
            {
                "parameterName": "ruAstHoSyncePortNumber",
                "operation": "delete",
                "value": "1"
            },
            {
                "parameterName": "synceNtwReAgtForceMajor",
                "operation": "delete",
                "value": "false"
            }
        ]
    }
],
    "asirmod": [
        {
            "distName": "MRBTS-75030/MNL-1/MNLENT-1/PMMNL-1",
            "operation": "update",
            "parameters": [
                {
                    "parameterName": "ruSynceHoPeriodAsiRMod",
                    "operation": "update",
                    "value": "disabled"
                },
                {
                    "parameterName": "ruSynceNetworkReArrgtAsiRMod",
                    "operation": "update",
                    "value": "disabled"
                }
            ]
        },
        {
            "distName": "MRBTS-75030/MNL-1/MNLENT-1/SYNC-2",
            "operation": "update",
            "parameters": [
                {
                    "parameterName": "actRuIntelligentSynceAstHoTime",
                    "operation": "update",
                    "value": "false"
                },
                {
                    "parameterName": "maxPtpNetworkTimeErrorRuIn",
                    "operation": "delete",
                    "value": "2500"
                },
                {
                    "parameterName": "maximumRuTimeErrorAstHoEnd",
                    "operation": "delete",
                    "value": "3500"
                },
                {
                    "parameterName": "synceAssistedHoldoverMode",
                    "operation": "delete",
                    "value": "IntelligentHoldover"
                }
            ]
        },
        {
            "distName": "MRBTS-75030/MNL-1/MNLENT-1/SYNC-2/CLOCK-1/SYNCE-1",
            "operation": "delete",
            "parameters": [
                {
                    "parameterName": "ruAstHoSyncePortNumber",
                    "operation": "delete",
                    "value": "1"
                },
                {
                    "parameterName": "synceNtwReAgtForceMajor",
                    "operation": "delete",
                    "value": "false"
                }
            ]
        }
    ]}
