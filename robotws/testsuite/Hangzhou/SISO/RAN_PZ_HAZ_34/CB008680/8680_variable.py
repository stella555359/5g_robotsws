from robot.libraries.BuiltIn import BuiltIn

tl = BuiltIn().get_variable_value("${tl}")

MRBTS_ID = tl.gnbs[0].instance_id
NRBTS_ID = tl.gnbs[0].global_bts_id
MRBTS = "MRBTS-" + str(MRBTS_ID)
NRBTS = "NRBTS-" + str(NRBTS_ID)

sfpID = tl.gnbs[0].dus[0].cablinks[0].target.port_id
print(sfpID)
M40008C1_distname = "BTS/MRBTS-" + str(MRBTS_ID) + "/EQM-1/APEQM-1/RMOD-1/SBTS_RMOD_TEMPERATURE/M40008C1"

M40008C1_path = "['BTS']['MRBTS-" + str(MRBTS_ID) + \
                "']['EQM-1']['APEQM-1']['RMOD-1']['SBTS_RMOD_TEMPERATURE']['M40008C1']"

M40005C2_distname = "BTS/MRBTS-" + str(MRBTS_ID) + "/EQM-1/APEQM-1/RMOD-1/SFP-" + str(sfpID) + "/SBTS_SFP_RMOD/M40005C2"

M40005C2_path = "['BTS']['MRBTS-" + str(MRBTS_ID) + \
                "']['EQM-1']['APEQM-1']['RMOD-1'] ['SFP-" + str(sfpID) + "']['SBTS_SFP_RMOD']['M40005C2']"
M40008C1_distname_before_24R2 = "BTS/BTS/MRBTS-" + str(MRBTS_ID) + "/APEQM-1/RMOD-1/SBTS_RMOD_TEMPERATURE/M40008C1"

M40008C1_path_before_24R2 = "['BTS']['BTS']['MRBTS-" + str(MRBTS_ID) + \
                "'] ['APEQM-1']['RMOD-1']['SBTS_RMOD_TEMPERATURE']['M40008C1']"
M40005C2_distname_before_24R2 = "BTS/SMOD/SFP-" + str(sfpID) + "/RMOD-1/SBTS_SFP_RMOD/M40005C2"
M40005C2_path_before_24R2 = "['BTS']['SMOD']['SFP-" + str(sfpID) + "']['RMOD-1']['SBTS_SFP_RMOD']['M40005C2']"

delta_8017 = [
    {
        "distName": MRBTS + "/" + NRBTS + "/NRCELL-1",
        "operation": "update",
        "parameters": [
            {
                "parameterName": "actBeamforming",
                "value": "true",
                "operation": "update"
            },
            {
                "parameterName": "chBw",
                "value": "100MHz",
                "operation": "update"
            },
            {
                "parameterName": "cellBwpList",
                "value": [
                    {
                        "bwpDN": MRBTS + "/" + NRBTS + "/BWP_PROFILE-7",
                        "cellBwpId": 0
                    },
                    {
                        "bwpDN": MRBTS + "/" + NRBTS + "/BWP_PROFILE-77",
                        "cellBwpId": 1
                    }
                ],
                "operation": "update"
            }
        ]
    }
]

delta_energySaving_update = [
    {
        "distName": MRBTS + "/EQM-1/APEQM-1/RMOD-1",
        "operation": "update",
        "parameters": [
            {
                "parameterName": "energySavingMode",
                "value": "NORMAL",
                "operation": "update"
            }
        ]
    },
    {
        "distName": MRBTS + "/" + NRBTS,
        "operation": "update",
        "parameters": [
            {
                "parameterName": "actNrLBPowerSaving",
                "value": "false",
                "operation": "update"
            }
        ]
    }

]

delta_energySaving_delete = [
    {
        "distName": MRBTS + "/" + NRBTS + "/NRPGRP-1",
        "operation": "delete",
        "parameters": []

    }
]

delta_energySaving_delete1 = [
    {
        "distName": MRBTS + "/" + NRBTS + "/NRPGRP-2",
        "operation": "delete",
        "parameters": []

    }
]

delta_M40005C2_M40008C1 = [

    {
        "distName": MRBTS + "/MNL-1/MNLENT-1/PMMNL-1",
        "operation": "update",
        "parameters": [
            {
                "parameterName": "mtSBTSRMODTemperature",
                "value": "15min",
                "operation": "update"
            },
            {
                "parameterName": "mtSBTSSfpRMOD",
                "value": "15min",
                "operation": "update"
            }

        ]
    }
]

delta_M40005C2_M40008C1_disable = [

    {
        "distName": MRBTS + "/MNL-1/MNLENT-1/PMMNL-1",
        "operation": "update",
        "parameters": [
            {
                "parameterName": "mtSBTSRMODTemperature",
                "value": "disabled",
                "operation": "update"
            },
            {
                "parameterName": "mtSBTSSfpRMOD",
                "value": "disabled",
                "operation": "update"
            }

        ]
    }
]

delta_energySave_add = [

    {
        "distName": MRBTS + "/EQM-1/APEQM-1/RMOD-1",
        "operation": "update",
        "parameters": [
            {
                "parameterName": "energySavingMode",
                "value": "DEEPSLEEP",
                "operation": "update"
            }
        ]
    },
    {
        "distName": MRBTS + "/" + NRBTS,
        "operation": "update",
        "parameters": [
            {
                "parameterName": "actNrLBPowerSaving",
                "value": "true",
                "operation": "update"
            }
        ]
    },
    {
        "distName": MRBTS + "/" + NRBTS + "/NRPGRP-1",
        "operation": "create",
        "parameters": [
            {
                "parameterName": "lbpsCSONCtlEnabled",
                "value": "true",
                "operation": "update"
            },
            {
                "parameterName": "lbpsLastCellMinLoad",
                "value": "0",
                "operation": "update"
            },
            {
                "parameterName": "lbpsLastCellRTXMinLoad",
                "value": "0",
                "operation": "update"
            },
            {
                "parameterName": "lbpsLastCellSOEnabled",
                "value": "true",
                "operation": "update"
            },
            {
                "parameterName": "lbpsMaxLoad",
                "value": "60",
                "operation": "update"
            },
            {
                "parameterName": "lbpsMinLoad",
                "value": "20",
                "operation": "update"
            },
            {
                "parameterName": "lbpsMonWinForCellSOff",
                "value": "300",
                "operation": "update"
            },
            {
                "parameterName": "lbpsMonWinForCellSOn",
                "value": "120",
                "operation": "update"
            },
            {
                "parameterName": "lbpsPdcchLoadOffset",
                "value": "4",
                "operation": "update"
            },
            {
                "parameterName": "lbpsRTXCellCapOffset",
                "value": "80",
                "operation": "update"
            },
            {
                "parameterName": "lbpsRTXMaxLoad",
                "value": "60",
                "operation": "update"
            },
            {
                "parameterName": "lbpsRTXMinLoad",
                "value": "20",
                "operation": "update"
            },
            {
                "parameterName": "lbpsRTXSOffTime",
                "value": "300",
                "operation": "update"
            },
            {
                "parameterName": "lbpsRTXSOnTime",
                "value": "120",
                "operation": "update"
            },
            {
                "parameterName": "lbpsSOMethod",
                "value": "cell switch off",
                "operation": "update"
            },
            {
                "parameterName": "lbpsCellList",
                "value": [
                    {
                        "lbpsCellSOOrder": "60",
                        "lbpsUseExtConfig": "false",
                        "nrCellId": "1"
                    }
                ],
                "operation": "update"
            },
            {
                "parameterName": "lbpsPeriodList",

                "value": [
                    {
                        "lbpsDayOfWeek": "Mon",
                        "lbpsDuration": "1440",
                        "lbpsStartTimeHour": "0",
                        "lbpsStartTimeMinute": "0",
                        "lbpsSuspended": "notSuspended"

                    },
                    {
                        "lbpsDayOfWeek": "Tue",
                        "lbpsDuration": "1440",
                        "lbpsStartTimeHour": "0",
                        "lbpsStartTimeMinute": "0",
                        "lbpsSuspended": "notSuspended"

                    },
                    {
                        "lbpsDayOfWeek": "Wed",
                        "lbpsDuration": "1440",
                        "lbpsStartTimeHour": "0",
                        "lbpsStartTimeMinute": "0",
                        "lbpsSuspended": "notSuspended"

                    },
                    {
                        "lbpsDayOfWeek": "Thu",
                        "lbpsDuration": "1440",
                        "lbpsStartTimeHour": "0",
                        "lbpsStartTimeMinute": "0",
                        "lbpsSuspended": "notSuspended"

                    },
                    {
                        "lbpsDayOfWeek": "Fri",
                        "lbpsDuration": "1440",
                        "lbpsStartTimeHour": "0",
                        "lbpsStartTimeMinute": "0",
                        "lbpsSuspended": "notSuspended"

                    },
                    {
                        "lbpsDayOfWeek": "Sat",
                        "lbpsDuration": "1440",
                        "lbpsStartTimeHour": "0",
                        "lbpsStartTimeMinute": "0",
                        "lbpsSuspended": "notSuspended"

                    },
                    {
                        "lbpsDayOfWeek": "Sun",
                        "lbpsDuration": "1440",
                        "lbpsStartTimeHour": "0",
                        "lbpsStartTimeMinute": "0",
                        "lbpsSuspended": "notSuspended"

                    }
                ],
                "operation": "update"
            }
        ]
    },
    {
        "distName": MRBTS + "/" + NRBTS + "/NRPGRP-2",
        "operation": "create",
        "parameters": [
            {
                "parameterName": "lbpsCSONCtlEnabled",
                "value": "true",
                "operation": "update"
            },
            {
                "parameterName": "lbpsLastCellMinLoad",
                "value": "0",
                "operation": "update"
            },
            {
                "parameterName": "lbpsLastCellRTXMinLoad",
                "value": "0",
                "operation": "update"
            },
            {
                "parameterName": "lbpsLastCellSOEnabled",
                "value": "true",
                "operation": "update"
            },
            {
                "parameterName": "lbpsMaxLoad",
                "value": "60",
                "operation": "update"
            },
            {
                "parameterName": "lbpsMinLoad",
                "value": "20",
                "operation": "update"
            },
            {
                "parameterName": "lbpsMonWinForCellSOff",
                "value": "300",
                "operation": "update"
            },
            {
                "parameterName": "lbpsMonWinForCellSOn",
                "value": "120",
                "operation": "update"
            },
            {
                "parameterName": "lbpsPdcchLoadOffset",
                "value": "4",
                "operation": "update"
            },
            {
                "parameterName": "lbpsRTXCellCapOffset",
                "value": "80",
                "operation": "update"
            },
            {
                "parameterName": "lbpsRTXMaxLoad",
                "value": "60",
                "operation": "update"
            },
            {
                "parameterName": "lbpsRTXMinLoad",
                "value": "20",
                "operation": "update"
            },
            {
                "parameterName": "lbpsRTXSOffTime",
                "value": "300",
                "operation": "update"
            },
            {
                "parameterName": "lbpsRTXSOnTime",
                "value": "120",
                "operation": "update"
            },
            {
                "parameterName": "lbpsSOMethod",
                "value": "cell switch off",
                "operation": "update"
            },
            {
                "parameterName": "lbpsCellList",
                "value": [
                    {
                        "lbpsCellSOOrder": "60",
                        "lbpsUseExtConfig": "false",
                        "nrCellId": "2"
                    }
                ],
                "operation": "update"
            },
            {
                "parameterName": "lbpsPeriodList",

                "value": [
                    {
                        "lbpsDayOfWeek": "Mon",
                        "lbpsDuration": "1440",
                        "lbpsStartTimeHour": "0",
                        "lbpsStartTimeMinute": "0",
                        "lbpsSuspended": "notSuspended"

                    },
                    {
                        "lbpsDayOfWeek": "Tue",
                        "lbpsDuration": "1440",
                        "lbpsStartTimeHour": "0",
                        "lbpsStartTimeMinute": "0",
                        "lbpsSuspended": "notSuspended"

                    },
                    {
                        "lbpsDayOfWeek": "Wed",
                        "lbpsDuration": "1440",
                        "lbpsStartTimeHour": "0",
                        "lbpsStartTimeMinute": "0",
                        "lbpsSuspended": "notSuspended"

                    },
                    {
                        "lbpsDayOfWeek": "Thu",
                        "lbpsDuration": "1440",
                        "lbpsStartTimeHour": "0",
                        "lbpsStartTimeMinute": "0",
                        "lbpsSuspended": "notSuspended"

                    },
                    {
                        "lbpsDayOfWeek": "Fri",
                        "lbpsDuration": "1440",
                        "lbpsStartTimeHour": "0",
                        "lbpsStartTimeMinute": "0",
                        "lbpsSuspended": "notSuspended"

                    },
                    {
                        "lbpsDayOfWeek": "Sat",
                        "lbpsDuration": "1440",
                        "lbpsStartTimeHour": "0",
                        "lbpsStartTimeMinute": "0",
                        "lbpsSuspended": "notSuspended"

                    },
                    {
                        "lbpsDayOfWeek": "Sun",
                        "lbpsDuration": "1440",
                        "lbpsStartTimeHour": "0",
                        "lbpsStartTimeMinute": "0",
                        "lbpsSuspended": "notSuspended"

                    }
                ],
                "operation": "update"
            }
        ]
    }

]

delta_energySave_add_23R2 = [

    {
        "distName": MRBTS + "/EQM-1/APEQM-1/RMOD-1",
        "operation": "update",
        "parameters": [
            {
                "parameterName": "energySavingMode",
                "value": "DEEPSLEEP",
                "operation": "update"
            }
        ]
    },
    {
        "distName": MRBTS + "/" + NRBTS,
        "operation": "update",
        "parameters": [
            {
                "parameterName": "actNrLBPowerSaving",
                "value": "true",
                "operation": "update"
            }
        ]
    },
    {
        "distName": MRBTS + "/" + NRBTS + "/NRPGRP-0",
        "operation": "create",
        "parameters": [
            {
                "parameterName": "lbpsCSONCtlEnabled",
                "value": "true",
                "operation": "update"
            },
            {
                "parameterName": "lbpsLastCellMinLoad",
                "value": "0",
                "operation": "update"
            },
            {
                "parameterName": "lbpsLastCellRTXMinLoad",
                "value": "0",
                "operation": "update"
            },
            {
                "parameterName": "lbpsLastCellSOEnabled",
                "value": "true",
                "operation": "update"
            },
            {
                "parameterName": "lbpsMaxLoad",
                "value": "60",
                "operation": "update"
            },
            {
                "parameterName": "lbpsMinLoad",
                "value": "20",
                "operation": "update"
            },
            {
                "parameterName": "lbpsMonWinForCellSOff",
                "value": "300",
                "operation": "update"
            },
            {
                "parameterName": "lbpsMonWinForCellSOn",
                "value": "120",
                "operation": "update"
            },
            {
                "parameterName": "lbpsPdcchLoadOffset",
                "value": "4",
                "operation": "update"
            },
            {
                "parameterName": "lbpsRTXCellCapOffset",
                "value": "80",
                "operation": "update"
            },
            {
                "parameterName": "lbpsRTXMaxLoad",
                "value": "60",
                "operation": "update"
            },
            {
                "parameterName": "lbpsRTXMinLoad",
                "value": "20",
                "operation": "update"
            },
            {
                "parameterName": "lbpsRTXSOffTime",
                "value": "300",
                "operation": "update"
            },
            {
                "parameterName": "lbpsRTXSOnTime",
                "value": "120",
                "operation": "update"
            },
            {
                "parameterName": "lbpsSOMethod",
                "value": "cell switch off",
                "operation": "update"
            },
            {
                "parameterName": "lbpsCellList",
                "value": [
                    {
                        "lbpsCellSOOrder": "60",
                        "nrCellId": "1"
                    }
                ],
                "operation": "update"
            },
            {
                "parameterName": "lbpsPeriodList",

                "value": [
                    {
                        "lbpsDayOfWeek": "Mon",
                        "lbpsDuration": "1440",
                        "lbpsStartTimeHour": "0",
                        "lbpsStartTimeMinute": "0",
                        "lbpsSuspended": "notSuspended"

                    },
                    {
                        "lbpsDayOfWeek": "Tue",
                        "lbpsDuration": "1440",
                        "lbpsStartTimeHour": "0",
                        "lbpsStartTimeMinute": "0",
                        "lbpsSuspended": "notSuspended"

                    },
                    {
                        "lbpsDayOfWeek": "Wed",
                        "lbpsDuration": "1440",
                        "lbpsStartTimeHour": "0",
                        "lbpsStartTimeMinute": "0",
                        "lbpsSuspended": "notSuspended"

                    },
                    {
                        "lbpsDayOfWeek": "Thu",
                        "lbpsDuration": "1440",
                        "lbpsStartTimeHour": "0",
                        "lbpsStartTimeMinute": "0",
                        "lbpsSuspended": "notSuspended"

                    },
                    {
                        "lbpsDayOfWeek": "Fri",
                        "lbpsDuration": "1440",
                        "lbpsStartTimeHour": "0",
                        "lbpsStartTimeMinute": "0",
                        "lbpsSuspended": "notSuspended"

                    },
                    {
                        "lbpsDayOfWeek": "Sat",
                        "lbpsDuration": "1440",
                        "lbpsStartTimeHour": "0",
                        "lbpsStartTimeMinute": "0",
                        "lbpsSuspended": "notSuspended"

                    },
                    {
                        "lbpsDayOfWeek": "Sun",
                        "lbpsDuration": "1440",
                        "lbpsStartTimeHour": "0",
                        "lbpsStartTimeMinute": "0",
                        "lbpsSuspended": "notSuspended"

                    }
                ],
                "operation": "update"
            }
        ]
    },
    {
        "distName": MRBTS + "/" + NRBTS + "/NRPGRP-1",
        "operation": "create",
        "parameters": [
            {
                "parameterName": "lbpsCSONCtlEnabled",
                "value": "true",
                "operation": "update"
            },
            {
                "parameterName": "lbpsLastCellMinLoad",
                "value": "0",
                "operation": "update"
            },
            {
                "parameterName": "lbpsLastCellRTXMinLoad",
                "value": "0",
                "operation": "update"
            },
            {
                "parameterName": "lbpsLastCellSOEnabled",
                "value": "true",
                "operation": "update"
            },
            {
                "parameterName": "lbpsMaxLoad",
                "value": "60",
                "operation": "update"
            },
            {
                "parameterName": "lbpsMinLoad",
                "value": "20",
                "operation": "update"
            },
            {
                "parameterName": "lbpsMonWinForCellSOff",
                "value": "300",
                "operation": "update"
            },
            {
                "parameterName": "lbpsMonWinForCellSOn",
                "value": "120",
                "operation": "update"
            },
            {
                "parameterName": "lbpsPdcchLoadOffset",
                "value": "4",
                "operation": "update"
            },
            {
                "parameterName": "lbpsRTXCellCapOffset",
                "value": "80",
                "operation": "update"
            },
            {
                "parameterName": "lbpsRTXMaxLoad",
                "value": "60",
                "operation": "update"
            },
            {
                "parameterName": "lbpsRTXMinLoad",
                "value": "20",
                "operation": "update"
            },
            {
                "parameterName": "lbpsRTXSOffTime",
                "value": "300",
                "operation": "update"
            },
            {
                "parameterName": "lbpsRTXSOnTime",
                "value": "120",
                "operation": "update"
            },
            {
                "parameterName": "lbpsSOMethod",
                "value": "cell switch off",
                "operation": "update"
            },
            {
                "parameterName": "lbpsCellList",
                "value": [
                    {
                        "lbpsCellSOOrder": "60",
                        "nrCellId": "2"
                    }
                ],
                "operation": "update"
            },
            {
                "parameterName": "lbpsPeriodList",

                "value": [
                    {
                        "lbpsDayOfWeek": "Mon",
                        "lbpsDuration": "1440",
                        "lbpsStartTimeHour": "0",
                        "lbpsStartTimeMinute": "0",
                        "lbpsSuspended": "notSuspended"

                    },
                    {
                        "lbpsDayOfWeek": "Tue",
                        "lbpsDuration": "1440",
                        "lbpsStartTimeHour": "0",
                        "lbpsStartTimeMinute": "0",
                        "lbpsSuspended": "notSuspended"

                    },
                    {
                        "lbpsDayOfWeek": "Wed",
                        "lbpsDuration": "1440",
                        "lbpsStartTimeHour": "0",
                        "lbpsStartTimeMinute": "0",
                        "lbpsSuspended": "notSuspended"

                    },
                    {
                        "lbpsDayOfWeek": "Thu",
                        "lbpsDuration": "1440",
                        "lbpsStartTimeHour": "0",
                        "lbpsStartTimeMinute": "0",
                        "lbpsSuspended": "notSuspended"

                    },
                    {
                        "lbpsDayOfWeek": "Fri",
                        "lbpsDuration": "1440",
                        "lbpsStartTimeHour": "0",
                        "lbpsStartTimeMinute": "0",
                        "lbpsSuspended": "notSuspended"

                    },
                    {
                        "lbpsDayOfWeek": "Sat",
                        "lbpsDuration": "1440",
                        "lbpsStartTimeHour": "0",
                        "lbpsStartTimeMinute": "0",
                        "lbpsSuspended": "notSuspended"

                    },
                    {
                        "lbpsDayOfWeek": "Sun",
                        "lbpsDuration": "1440",
                        "lbpsStartTimeHour": "0",
                        "lbpsStartTimeMinute": "0",
                        "lbpsSuspended": "notSuspended"

                    }
                ],
                "operation": "update"
            }
        ]
    }

]

# import os
# file_path = os.path.join(os.getcwd(), '2005.bin')
RAE_path_list = [{'file_path': '/home/ute/Downloads/2005.bin'}]

TOP_DOMAIN_NUMBER_MODIFY = [
    dict(dist_name='MRBTS-{mrbtsID}/MNL-1/MNLENT-1/SYNC-2/CLOCK-1/TOP-1',
         list_name=None,
         filter_param='ToP domain number',
         p_name='topDomainNumber',
         value='43')
]
