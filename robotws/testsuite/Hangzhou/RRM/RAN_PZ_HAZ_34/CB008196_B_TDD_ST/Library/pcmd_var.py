from robot.libraries.BuiltIn import BuiltIn
tl = BuiltIn().get_variable_value("${tl}")

MRBTS_ID = tl.gnbs[0].instance_id
NRBTS_ID = tl.gnbs[0].global_bts_id
MRBTS = "MRBTS-" + str(MRBTS_ID)
NRBTS = "NRBTS-" + str(NRBTS_ID)

if tl.core:
    if tl.core.mcc and tl.core.mnc:
        mcc = tl.core.mcc
        mnc = tl.core.mnc
    else:
        mcc = "262"
        mnc = "3"
else:
    mcc = "262"
    mnc = "3"

dcap_server_ip = tl.host[0].default_ssh_connection_details.addr
dcap_server_username = tl.host[0].default_ssh_connection_details.username
dcap_server_password = tl.host[0].default_ssh_connection_details.password
dcap_server_port = tl.host[0].default_ssh_connection_details.port

del_nrctrlts = {
    "distName": MRBTS + "/" + NRBTS + "/NRCTRLTS-1",
    "operation": "delete",
    "parameters": []
}

del_nrctrltsdu = {
    "distName": MRBTS + "/" + NRBTS + "/NRDU-1/NRCTRLTSDU-1",
    "operation": "delete",
    "parameters": []
}

del_tceadm = {
    "distName": MRBTS + "/MNL-1/TCEADM-1",
    "operation": "delete",
    "parameters": []
}

add_all_pcmd = [
    {
        "distName": MRBTS + "/" + NRBTS + "/NRCTRLTS-1",
        "operation": "create",
        "parameters": []
    },
    {
        "distName": MRBTS + "/" + NRBTS + "/NRCTRLTS-1/NRMTRACECU-1",
        "operation": "create",
        "parameters": [
            {
                "parameterName": "actCellTraceReportingCU",
                "value": "true",
                "operation": "update"
            },
            {
                "parameterName": "actPCMDReporting",
                "value": "true",
                "operation": "update"
            },
            {
                "parameterName": "cellMaxActiveUEsTraced",
                "value": 100,
                "operation": "update"
            },
            {
                "parameterName": "jobType",
                "value": "ImmediateMDTAndTrace",
                "operation": "update"
            },
            {
                "parameterName": "nrRanTraceReference",
                "value": [
                    {"mcc": mcc, "mnc": mnc, "mncLength": 2, "traceId": MRBTS_ID}
                ],
                "operation": "update"
            },
            {
                "parameterName": "nrTceIdentifier",
                "value": 1,
                "operation": "update"
            },
            {
                "parameterName": "scope",
                "value": "allResources",
                "operation": "update"
            },
            {
                "parameterName": "traceNGAPSetting",
                "value": "all",
                "operation": "update"
            },
            {
                "parameterName": "traceNRRRCSetting",
                "value": "all",
                "operation": "update"
            },
            {
                "parameterName": "traceX2Setting",
                "value": "all",
                "operation": "update"
            },
            {
                "parameterName": "traceXNSetting",
                "value": "all",
                "operation": "update"
            },
            {
                "parameterName": "nrPeriodicUeMeas",
                "value": [
                    {"cellMaxPeriodicUEsTraced": 2, "reportAmount": "r2", "reportInterval": "ms120"}
                ],
                "operation": "update"
            },

        ]
    },
    {
        "distName": MRBTS + "/" + NRBTS + "/NRDU-1/NRCTRLTSDU-1",
        "operation": "create",
        "parameters": []
    },
    {
        "distName": MRBTS + "/" + NRBTS + "/NRDU-1/NRCTRLTSDU-1/NRMTRACEDU-1",
        "operation": "create",
        "parameters": [
            {
                "parameterName": "actPCMDReporting",
                "value": "true",
                "operation": "update"
            },
            {
                "parameterName": "cellMaxActiveUEsTraced",
                "value": 100,
                "operation": "update"
            },
            {
                "parameterName": "jobType",
                "value": "TraceOnly",
                "operation": "update"
            },
            {
                "parameterName": "nrRanTraceReference",
                "value": [
                    {"mcc": mcc, "mnc": mnc, "mncLength": 2, "traceId": MRBTS_ID}
                ],
                "operation": "update"
            },
            {
                "parameterName": "nrTceIdentifier",
                "value": 1,
                "operation": "update"
            },
            {
                "parameterName": "scope",
                "value": "allResources",
                "operation": "update"
            }
        ]
    },
    {
        "distName": MRBTS + "/MNL-1/TCEADM-1",
        "operation": "create",
        "parameters": []
    },
    {
        "distName": MRBTS + "/MNL-1/TCEADM-1/TCE-1",
        "operation": "create",
        "parameters": [
            {
                "parameterName": "tceIdentifier",
                "value": 1,
                "operation": "update"
            },
            {
                "parameterName": "tceIpAddress",
                "value": dcap_server_ip,
                "operation": "update"
            },
            {
                "parameterName": "tcePortNumber",
                "value": dcap_server_port,
                "operation": "update"
            },
            {
                "parameterName": "tlsEnabled",
                "value": "false",
                "operation": "update"
            },
            {
                "parameterName": "certTypeForTlsAuth",
                "value": "RSA",
                "operation": "update"
            }
        ]
    }
]

add_all_pcmd_23R2 = [
    {
        "distName": MRBTS + "/" + NRBTS + "/NRCTRLTS-1",
        "operation": "create",
        "parameters": []
    },
    {
        "distName": MRBTS + "/" + NRBTS + "/NRCTRLTS-1/NRMTRACECU-1",
        "operation": "create",
        "parameters": [
            {
                "parameterName": "actCellTraceReportingCU",
                "value": "true",
                "operation": "update"
            },
            {
                "parameterName": "actPCMDReporting",
                "value": "true",
                "operation": "update"
            },
            {
                "parameterName": "cellMaxActiveUEsTraced",
                "value": 100,
                "operation": "update"
            },
            {
                "parameterName": "jobType",
                "value": "ImmediateMDTAndTrace",
                "operation": "update"
            },
            {
                "parameterName": "nrMtraceCuId",
                "value": "1",
                "operation": "update"
            },
            {
                "parameterName": "nrRanTraceReference",
                "value": [
                    {"mcc": mcc, "mnc": mnc, "mncLength": 2, "traceId": MRBTS_ID}
                ],
                "operation": "update"
            },
            {
                "parameterName": "nrTceIdentifier",
                "value": 1,
                "operation": "update"
            },
            {
                "parameterName": "scope",
                "value": "allResources",
                "operation": "update"
            },
            {
                "parameterName": "traceNGAPSetting",
                "value": "all",
                "operation": "update"
            },
            {
                "parameterName": "traceNRRRCSetting",
                "value": "all",
                "operation": "update"
            },
            {
                "parameterName": "traceX2Setting",
                "value": "all",
                "operation": "update"
            },
            {
                "parameterName": "traceXNSetting",
                "value": "all",
                "operation": "update"
            },
            # {
            #     "parameterName": "nrPeriodicUeMeas",
            #     "value": [
            #         {"cellMaxPeriodicUEsTraced": 2, "reportAmount": "r2", "reportInterval": "ms120"}
            #     ],
            #     "operation": "update"
            # },

            {
                "parameterName": "immedMDTUEMeas",
                "value": [
                    {"mdtMeasType": "periodic",
                     "reportAmount": "r2",
                     "reportInterval": "ms120",
                     "rrmEventTriggeredMeas": "false"}
                ],
                "operation": "update"
            },
            {
                "parameterName": "immedMDTControl",

                "value": [
                    {
                        "cellMaxActiveMDTUEsTraced": "2",
                        "immedMDTObtainLocation": "false",
                        "immedMDTPosMethod": "none",
                        "immedMDTSelectOnlyGNSSUEs": "false"
                    }
                ],
                "operation": "update"
            },



        ]
    },
    {
        "distName": MRBTS + "/" + NRBTS + "/NRDU-1/NRCTRLTSDU-1",
        "operation": "create",
        "parameters": []
    },
    {
        "distName": MRBTS + "/" + NRBTS + "/NRDU-1/NRCTRLTSDU-1/NRMTRACEDU-1",
        "operation": "create",
        "parameters": [
            {
                "parameterName": "actPCMDReporting",
                "value": "true",
                "operation": "update"
            },
            {
                "parameterName": "cellMaxActiveUEsTraced",
                "value": 100,
                "operation": "update"
            },
            {
                "parameterName": "jobType",
                "value": "TraceOnly",
                "operation": "update"
            },
            {
                "parameterName": "nrRanTraceReference",
                "value": [
                    {"mcc": mcc, "mnc": mnc, "mncLength": 2, "traceId": MRBTS_ID}
                ],
                "operation": "update"
            },
            {
                "parameterName": "nrTceIdentifier",
                "value": 1,
                "operation": "update"
            },
            {
                "parameterName": "scope",
                "value": "allResources",
                "operation": "update"
            }
        ]
    },
    {
        "distName": MRBTS + "/MNL-1/TCEADM-1",
        "operation": "create",
        "parameters": []
    },
    {
        "distName": MRBTS + "/MNL-1/TCEADM-1/TCE-1",
        "operation": "create",
        "parameters": [
            {
                "parameterName": "tceIdentifier",
                "value": 1,
                "operation": "update"
            },
            {
                "parameterName": "tceIpAddress",
                "value": dcap_server_ip,
                "operation": "update"
            },
            {
                "parameterName": "tcePortNumber",
                "value": dcap_server_port,
                "operation": "update"
            },
            {
                "parameterName": "tlsEnabled",
                "value": "false",
                "operation": "update"
            },
            {
                "parameterName": "certTypeForTlsAuth",
                "value": "RSA",
                "operation": "update"
            }
        ]
    }
]

add_all_pcmd_23R4 = [
    {
        "distName": MRBTS + "/" + NRBTS + "/NRCTRLTS-1",
        "operation": "create",
        "parameters": []
    },
    {
        "distName": MRBTS + "/" + NRBTS + "/NRCTRLTS-1/NRMTRACECU-1",
        "operation": "create",
        "parameters": [
            {
                "parameterName": "actCellTraceReportingCU",
                "value": "true",
                "operation": "update"
            },
            {
                "parameterName": "actPCMDReporting",
                "value": "true",
                "operation": "update"
            },
            {
                "parameterName": "cellMaxActiveUEsTraced",
                "value": 100,
                "operation": "update"
            },
            {
                "parameterName": "jobType",
                "value": "ImmediateMDTAndTrace",
                "operation": "update"
            },
            {
                "parameterName": "nrMtraceCuId",
                "value": "1",
                "operation": "update"
            },
            {
                "parameterName": "nrRanTraceReference",
                "value": [
                    {"mcc": mcc, "mnc": mnc, "mncLength": 2, "traceId": MRBTS_ID}
                ],
                "operation": "update"
            },
            {
                "parameterName": "nrTceIdentifier",
                "value": 1,
                "operation": "update"
            },
            {
                "parameterName": "scope",
                "value": "allResources",
                "operation": "update"
            },
            {
                "parameterName": "traceNGAPSetting",
                "value": "all",
                "operation": "update"
            },
            {
                "parameterName": "traceNRRRCSetting",
                "value": "all",
                "operation": "update"
            },
            {
                "parameterName": "traceX2Setting",
                "value": "all",
                "operation": "update"
            },
            {
                "parameterName": "traceXNSetting",
                "value": "all",
                "operation": "update"
            },
            # {
            #     "parameterName": "nrPeriodicUeMeas",
            #     "value": [
            #         {"cellMaxPeriodicUEsTraced": 2, "reportAmount": "r2", "reportInterval": "ms120"}
            #     ],
            #     "operation": "update"
            # },

            {
                "parameterName": "immedMDTUEMeas",
                "value": [
                    {"mdtMeasType": "periodic",
                     "reportAmount": "r2",
                     "reportInterval": "ms120",
                     "rrmEventTriggeredMeas": "false"}
                ],
                "operation": "update"
            },
            {
                "parameterName": "immedMDTControl",

                "value": [
                    {
                        "cellMaxActiveMDTUEsTraced": "2",
                        "immedMDTObtainLocation": "false",
                        "immedMDTPosMethod": "none",
                        "immedMDTSelectOnlyGNSSUEs": "false"
                    }
                ],
                "operation": "update"
            },



        ]
    },
    {
        "distName": MRBTS + "/" + NRBTS + "/NRDU-1/NRCTRLTSDU-1",
        "operation": "create",
        "parameters": []
    },
    {
        "distName": MRBTS + "/" + NRBTS + "/NRDU-1/NRCTRLTSDU-1/NRMTRACEDU-1",
        "operation": "create",
        "parameters": [
            {
                "parameterName": "actPCMDReporting",
                "value": "true",
                "operation": "update"
            },
            {
                "parameterName": "actRIReporting",
                "value": "false",
                "operation": "update"
            },
            {
                "parameterName": "cellMaxActiveUEsTraced",
                "value": 100,
                "operation": "update"
            },
            {
                "parameterName": "jobType",
                "value": "TraceOnly",
                "operation": "update"
            },
            {
                "parameterName": "nrMtraceDuId",
                "value": 1,
                "operation": "update"
            },
            {
                "parameterName": "nrRanTraceReference",
                "value": [
                    {"mcc": mcc, "mnc": mnc, "mncLength": 2, "traceId": MRBTS_ID}
                ],
                "operation": "update"
            },
            {
                "parameterName": "nrTceIdentifier",
                "value": 1,
                "operation": "update"
            },
            {
                "parameterName": "scope",
                "value": "allResources",
                "operation": "update"
            }
        ]
    },
    {
        "distName": MRBTS + "/MNL-1/TCEADM-1",
        "operation": "create",
        "parameters": []
    },
    {
        "distName": MRBTS + "/MNL-1/TCEADM-1/TCE-1",
        "operation": "create",
        "parameters": [
            {
                "parameterName": "tceIdentifier",
                "value": 1,
                "operation": "update"
            },
            {
                "parameterName": "tceIpAddress",
                "value": dcap_server_ip,
                "operation": "update"
            },
            {
                "parameterName": "tcePortNumber",
                "value": dcap_server_port,
                "operation": "update"
            },
            {
                "parameterName": "tlsEnabled",
                "value": "false",
                "operation": "update"
            },
            {
                "parameterName": "certTypeForTlsAuth",
                "value": "RSA",
                "operation": "update"
            }
        ]
    }
]

add_nrctrlts_1ue = [
    {
        "distName": MRBTS + "/" + NRBTS + "/NRCTRLTS-1",
        "operation": "create",
        "parameters": []
    },
    {
        "distName": MRBTS + "/" + NRBTS + "/NRCTRLTS-1/NRMTRACECU-1",
        "operation": "create",
        "parameters": [
            {
                "parameterName": "actCellTraceReportingCU",
                "value": "true",
                "operation": "update"
            },
            {
                "parameterName": "actPCMDReporting",
                "value": "true",
                "operation": "update"
            },
            {
                "parameterName": "cellMaxActiveUEsTraced",
                "value": 100,
                "operation": "update"
            },
            {
                "parameterName": "jobType",
                "value": "ImmediateMDTAndTrace",
                "operation": "update"
            },
            {
                "parameterName": "nrRanTraceReference",
                "value": [
                    {"mcc": mcc, "mnc": mnc, "mncLength": 2, "traceId": MRBTS_ID}
                ],
                "operation": "update"
            },
            {
                "parameterName": "nrTceIdentifier",
                "value": 1,
                "operation": "update"
            },
            {
                "parameterName": "scope",
                "value": "allResources",
                "operation": "update"
            },
            {
                "parameterName": "traceNGAPSetting",
                "value": "all",
                "operation": "update"
            },
            {
                "parameterName": "traceNRRRCSetting",
                "value": "all",
                "operation": "update"
            },
            {
                "parameterName": "traceX2Setting",
                "value": "all",
                "operation": "update"
            },
            {
                "parameterName": "traceXNSetting",
                "value": "all",
                "operation": "update"
            },
            {
                "parameterName": "nrPeriodicUeMeas",
                "value": [
                    {"cellMaxPeriodicUEsTraced": 1, "reportAmount": "infinity", "reportInterval": "ms10240"}
                ],
                "operation": "update"
            },

        ]
    },
]

add_nrctrlts_1ue_23R2 = [
    {
        "distName": MRBTS + "/" + NRBTS + "/NRCTRLTS-1",
        "operation": "create",
        "parameters": []
    },
    {
        "distName": MRBTS + "/" + NRBTS + "/NRCTRLTS-1/NRMTRACECU-1",
        "operation": "create",
        "parameters": [
            {
                "parameterName": "actCellTraceReportingCU",
                "value": "true",
                "operation": "update"
            },
            {
                "parameterName": "actPCMDReporting",
                "value": "true",
                "operation": "update"
            },
            {
                "parameterName": "cellMaxActiveUEsTraced",
                "value": 100,
                "operation": "update"
            },
            {
                "parameterName": "jobType",
                "value": "ImmediateMDTAndTrace",
                "operation": "update"
            },
            {
                "parameterName": "nrMtraceCuId",
                "value": "1",
                "operation": "update"
            },
            {
                "parameterName": "nrRanTraceReference",
                "value": [
                    {"mcc": mcc, "mnc": mnc, "mncLength": 2, "traceId": MRBTS_ID}
                ],
                "operation": "update"
            },
            {
                "parameterName": "nrTceIdentifier",
                "value": 1,
                "operation": "update"
            },
            {
                "parameterName": "scope",
                "value": "allResources",
                "operation": "update"
            },
            {
                "parameterName": "traceNGAPSetting",
                "value": "all",
                "operation": "update"
            },
            {
                "parameterName": "traceNRRRCSetting",
                "value": "all",
                "operation": "update"
            },
            {
                "parameterName": "traceX2Setting",
                "value": "all",
                "operation": "update"
            },
            {
                "parameterName": "traceXNSetting",
                "value": "all",
                "operation": "update"
            },
            # {
            #     "parameterName": "nrPeriodicUeMeas",
            #     "value": [
            #         {"cellMaxPeriodicUEsTraced": 1, "reportAmount": "infinity", "reportInterval": "ms10240"}
            #     ],
            #     "operation": "update"
            # },
            {
                "parameterName": "immedMDTUEMeas",
                "value": [
                    {
                     "mdtMeasType": "periodic",
                     "reportAmount": "infinity",
                     "reportInterval": "ms10240",
                     "rrmEventTriggeredMeas": "false"
                     }
                ],
                "operation": "update"
            },
            {
                "parameterName": "immedMDTControl",

                "value": [
                    {
                        "cellMaxActiveMDTUEsTraced": "1",
                        "immedMDTObtainLocation": "false",
                        "immedMDTPosMethod": "none",
                        "immedMDTSelectOnlyGNSSUEs": "false"
                    }
                ],
                "operation": "update"
            },

        ]
    },
]

add_nrctrlts_1ue_r8 = [
    {
        "distName": MRBTS + "/" + NRBTS + "/NRCTRLTS-1",
        "operation": "create",
        "parameters": []
    },
    {
        "distName": MRBTS + "/" + NRBTS + "/NRCTRLTS-1/NRMTRACECU-1",
        "operation": "create",
        "parameters": [
            {
                "parameterName": "actCellTraceReportingCU",
                "value": "true",
                "operation": "update"
            },
            {
                "parameterName": "actPCMDReporting",
                "value": "true",
                "operation": "update"
            },
            {
                "parameterName": "cellMaxActiveUEsTraced",
                "value": 100,
                "operation": "update"
            },
            {
                "parameterName": "jobType",
                "value": "ImmediateMDTAndTrace",
                "operation": "update"
            },
            {
                "parameterName": "nrRanTraceReference",
                "value": [
                    {"mcc": mcc, "mnc": mnc, "mncLength": 2, "traceId": MRBTS_ID}
                ],
                "operation": "update"
            },
            {
                "parameterName": "nrTceIdentifier",
                "value": 1,
                "operation": "update"
            },
            {
                "parameterName": "scope",
                "value": "allResources",
                "operation": "update"
            },
            {
                "parameterName": "traceNGAPSetting",
                "value": "all",
                "operation": "update"
            },
            {
                "parameterName": "traceNRRRCSetting",
                "value": "all",
                "operation": "update"
            },
            {
                "parameterName": "traceX2Setting",
                "value": "all",
                "operation": "update"
            },
            {
                "parameterName": "traceXNSetting",
                "value": "all",
                "operation": "update"
            },
            {
                "parameterName": "nrPeriodicUeMeas",
                "value": [
                    {"cellMaxPeriodicUEsTraced": 1, "reportAmount": "r8", "reportInterval": "ms40960"}
                ],
                "operation": "update"
            },

        ]
    },
]

add_nrctrlts_1ue_r8_23R2 = [
    {
        "distName": MRBTS + "/" + NRBTS + "/NRCTRLTS-1",
        "operation": "create",
        "parameters": []
    },
    {
        "distName": MRBTS + "/" + NRBTS + "/NRCTRLTS-1/NRMTRACECU-1",
        "operation": "create",
        "parameters": [
            {
                "parameterName": "actCellTraceReportingCU",
                "value": "true",
                "operation": "update"
            },
            {
                "parameterName": "actPCMDReporting",
                "value": "true",
                "operation": "update"
            },
            {
                "parameterName": "cellMaxActiveUEsTraced",
                "value": 100,
                "operation": "update"
            },
            {
                "parameterName": "jobType",
                "value": "ImmediateMDTAndTrace",
                "operation": "update"
            },
            {
                "parameterName": "nrMtraceCuId",
                "value": "1",
                "operation": "update"
            },
            {
                "parameterName": "nrRanTraceReference",
                "value": [
                    {"mcc": mcc, "mnc": mnc, "mncLength": 2, "traceId": MRBTS_ID}
                ],
                "operation": "update"
            },
            {
                "parameterName": "nrTceIdentifier",
                "value": 1,
                "operation": "update"
            },
            {
                "parameterName": "scope",
                "value": "allResources",
                "operation": "update"
            },
            {
                "parameterName": "traceNGAPSetting",
                "value": "all",
                "operation": "update"
            },
            {
                "parameterName": "traceNRRRCSetting",
                "value": "all",
                "operation": "update"
            },
            {
                "parameterName": "traceX2Setting",
                "value": "all",
                "operation": "update"
            },
            {
                "parameterName": "traceXNSetting",
                "value": "all",
                "operation": "update"
            },
            {
                "parameterName": "immedMDTUEMeas",
                "value": [
                    {"mdtMeasType": "periodic",
                     "reportAmount": "r8",
                     "reportInterval": "ms40960",
                     "rrmEventTriggeredMeas": "false"}
                ],
                "operation": "update"
            },
            {
                "parameterName": "immedMDTControl",

                "value": [
                    {
                        "cellMaxActiveMDTUEsTraced": "1",
                        "immedMDTObtainLocation": "false",
                        "immedMDTPosMethod": "none",
                        "immedMDTSelectOnlyGNSSUEs": "false"
                    }
                ],
                "operation": "update"
            },

        ]
    },
]

add_nrctrlts_002 = [
    {
        "distName": MRBTS + "/" + NRBTS + "/NRCTRLTS-1",
        "operation": "create",
        "parameters": []
    },
    {
        "distName": MRBTS + "/" + NRBTS + "/NRCTRLTS-1/NRMTRACECU-1",
        "operation": "create",
        "parameters": [
            {
                "parameterName": "actCellTraceReportingCU",
                "value": "true",
                "operation": "update"
            },
            {
                "parameterName": "actPCMDReporting",
                "value": "true",
                "operation": "update"
            },
            {
                "parameterName": "cellMaxActiveUEsTraced",
                "value": 100,
                "operation": "update"
            },
            {
                "parameterName": "jobType",
                "value": "ImmediateMDTAndTrace",
                "operation": "update"
            },
            {
                "parameterName": "nrRanTraceReference",
                "value": [
                    {"mcc": mcc, "mnc": mnc, "mncLength": 2, "traceId": MRBTS_ID}
                ],
                "operation": "update"
            },
            {
                "parameterName": "nrTceIdentifier",
                "value": 1,
                "operation": "update"
            },
            {
                "parameterName": "scope",
                "value": "allResources",
                "operation": "update"
            },
            {
                "parameterName": "traceNGAPSetting",
                "value": "all",
                "operation": "update"
            },
            {
                "parameterName": "traceNRRRCSetting",
                "value": "all",
                "operation": "update"
            },
            {
                "parameterName": "traceX2Setting",
                "value": "all",
                "operation": "update"
            },
            {
                "parameterName": "traceXNSetting",
                "value": "all",
                "operation": "update"
            },
            {
                "parameterName": "nrPeriodicUeMeas",
                "value": [
                    {"cellMaxPeriodicUEsTraced": 2, "reportAmount": "r2", "reportInterval": "ms240"}
                ],
                "operation": "update"
            },

        ]
    },
]

add_nrctrlts_002_23R2 = [
    {
        "distName": MRBTS + "/" + NRBTS + "/NRCTRLTS-1",
        "operation": "create",
        "parameters": []
    },
    {
        "distName": MRBTS + "/" + NRBTS + "/NRCTRLTS-1/NRMTRACECU-1",
        "operation": "create",
        "parameters": [
            {
                "parameterName": "actCellTraceReportingCU",
                "value": "true",
                "operation": "update"
            },
            {
                "parameterName": "actPCMDReporting",
                "value": "true",
                "operation": "update"
            },
            {
                "parameterName": "cellMaxActiveUEsTraced",
                "value": 100,
                "operation": "update"
            },
            {
                "parameterName": "jobType",
                "value": "ImmediateMDTAndTrace",
                "operation": "update"
            },
            {
                "parameterName": "nrMtraceCuId",
                "value": "1",
                "operation": "update"
            },
            {
                "parameterName": "nrRanTraceReference",
                "value": [
                    {"mcc": mcc, "mnc": mnc, "mncLength": 2, "traceId": MRBTS_ID}
                ],
                "operation": "update"
            },
            {
                "parameterName": "nrTceIdentifier",
                "value": 1,
                "operation": "update"
            },
            {
                "parameterName": "scope",
                "value": "allResources",
                "operation": "update"
            },
            {
                "parameterName": "traceNGAPSetting",
                "value": "all",
                "operation": "update"
            },
            {
                "parameterName": "traceNRRRCSetting",
                "value": "all",
                "operation": "update"
            },
            {
                "parameterName": "traceX2Setting",
                "value": "all",
                "operation": "update"
            },
            {
                "parameterName": "traceXNSetting",
                "value": "all",
                "operation": "update"
            },
            # {
            #     "parameterName": "nrPeriodicUeMeas",
            #     "value": [
            #         {"cellMaxPeriodicUEsTraced": 2, "reportAmount": "r2", "reportInterval": "ms240"}
            #     ],
            #     "operation": "update"
            # },
            {
                "parameterName": "immedMDTUEMeas",
                "value": [
                    {"mdtMeasType": "periodic",
                     "reportAmount": "r2",
                     "reportInterval": "ms240",
                     "rrmEventTriggeredMeas": "false"}
                ],
                "operation": "update"
            },
            {
                "parameterName": "immedMDTControl",

                "value": [
                    {
                        "cellMaxActiveMDTUEsTraced": "2",
                        "immedMDTObtainLocation": "false",
                        "immedMDTPosMethod": "none",
                        "immedMDTSelectOnlyGNSSUEs": "false"
                    }
                ],
                "operation": "update"
            },

        ]
    },
]

add_nrctrlts_006 = [
    {
        "distName": MRBTS + "/" + NRBTS + "/NRCTRLTS-1",
        "operation": "create",
        "parameters": []
    },
    {
        "distName": MRBTS + "/" + NRBTS + "/NRCTRLTS-1/NRMTRACECU-1",
        "operation": "create",
        "parameters": [
            {
                "parameterName": "actCellTraceReportingCU",
                "value": "true",
                "operation": "update"
            },
            {
                "parameterName": "actPCMDReporting",
                "value": "true",
                "operation": "update"
            },
            {
                "parameterName": "cellMaxActiveUEsTraced",
                "value": 100,
                "operation": "update"
            },
            {
                "parameterName": "jobType",
                "value": "ImmediateMDTAndTrace",
                "operation": "update"
            },
            {
                "parameterName": "nrRanTraceReference",
                "value": [
                    {"mcc": mcc, "mnc": mnc, "mncLength": 2, "traceId": MRBTS_ID}
                ],
                "operation": "update"
            },
            {
                "parameterName": "nrTceIdentifier",
                "value": 1,
                "operation": "update"
            },
            {
                "parameterName": "scope",
                "value": "allResources",
                "operation": "update"
            },
            {
                "parameterName": "traceNGAPSetting",
                "value": "all",
                "operation": "update"
            },
            {
                "parameterName": "traceNRRRCSetting",
                "value": "all",
                "operation": "update"
            },
            {
                "parameterName": "traceX2Setting",
                "value": "all",
                "operation": "update"
            },
            {
                "parameterName": "traceXNSetting",
                "value": "all",
                "operation": "update"
            },
            {
                "parameterName": "nrPeriodicUeMeas",
                "value": [
                    {"cellMaxPeriodicUEsTraced": 2, "reportAmount": "r4", "reportInterval": "ms480"}
                ],
                "operation": "update"
            },

        ]
    },
]

add_nrctrlts_006_23R2 = [
    {
        "distName": MRBTS + "/" + NRBTS + "/NRCTRLTS-1",
        "operation": "create",
        "parameters": []
    },
    {
        "distName": MRBTS + "/" + NRBTS + "/NRCTRLTS-1/NRMTRACECU-1",
        "operation": "create",
        "parameters": [
            {
                "parameterName": "actCellTraceReportingCU",
                "value": "true",
                "operation": "update"
            },
            {
                "parameterName": "actPCMDReporting",
                "value": "true",
                "operation": "update"
            },
            {
                "parameterName": "cellMaxActiveUEsTraced",
                "value": 100,
                "operation": "update"
            },
            {
                "parameterName": "jobType",
                "value": "ImmediateMDTAndTrace",
                "operation": "update"
            },
            {
                "parameterName": "nrMtraceCuId",
                "value": "1",
                "operation": "update"
            },
            {
                "parameterName": "nrRanTraceReference",
                "value": [
                    {"mcc": mcc, "mnc": mnc, "mncLength": 2, "traceId": MRBTS_ID}
                ],
                "operation": "update"
            },
            {
                "parameterName": "nrTceIdentifier",
                "value": 1,
                "operation": "update"
            },
            {
                "parameterName": "scope",
                "value": "allResources",
                "operation": "update"
            },
            {
                "parameterName": "traceNGAPSetting",
                "value": "all",
                "operation": "update"
            },
            {
                "parameterName": "traceNRRRCSetting",
                "value": "all",
                "operation": "update"
            },
            {
                "parameterName": "traceX2Setting",
                "value": "all",
                "operation": "update"
            },
            {
                "parameterName": "traceXNSetting",
                "value": "all",
                "operation": "update"
            },
            # {
            #     "parameterName": "nrPeriodicUeMeas",
            #     "value": [
            #         {"cellMaxPeriodicUEsTraced": 2, "reportAmount": "r4", "reportInterval": "ms480"}
            #     ],
            #     "operation": "update"
            # },
            {
                "parameterName": "immedMDTUEMeas",
                "value": [
                    {"mdtMeasType": "periodic",
                     "reportAmount": "r4",
                     "reportInterval": "ms480",
                     "rrmEventTriggeredMeas": "false"}
                ],
                "operation": "update"
            },
            {
                "parameterName": "immedMDTControl",

                "value": [
                    {
                        "cellMaxActiveMDTUEsTraced": "2",
                        "immedMDTObtainLocation": "false",
                        "immedMDTPosMethod": "none",
                        "immedMDTSelectOnlyGNSSUEs": "false"
                    }
                ],
                "operation": "update"
            },

        ]
    },
]

add_nrctrlts_007 = [
    {
        "distName": MRBTS + "/" + NRBTS + "/NRCTRLTS-1",
        "operation": "create",
        "parameters": []
    },
    {
        "distName": MRBTS + "/" + NRBTS + "/NRCTRLTS-1/NRMTRACECU-1",
        "operation": "create",
        "parameters": [
            {
                "parameterName": "actCellTraceReportingCU",
                "value": "true",
                "operation": "update"
            },
            {
                "parameterName": "actPCMDReporting",
                "value": "true",
                "operation": "update"
            },
            {
                "parameterName": "cellMaxActiveUEsTraced",
                "value": 100,
                "operation": "update"
            },
            {
                "parameterName": "jobType",
                "value": "ImmediateMDTAndTrace",
                "operation": "update"
            },
            {
                "parameterName": "nrRanTraceReference",
                "value": [
                    {"mcc": mcc, "mnc": mnc, "mncLength": 2, "traceId": MRBTS_ID}
                ],
                "operation": "update"
            },
            {
                "parameterName": "nrTceIdentifier",
                "value": 1,
                "operation": "update"
            },
            {
                "parameterName": "scope",
                "value": "allResources",
                "operation": "update"
            },
            {
                "parameterName": "traceNGAPSetting",
                "value": "all",
                "operation": "update"
            },
            {
                "parameterName": "traceNRRRCSetting",
                "value": "all",
                "operation": "update"
            },
            {
                "parameterName": "traceX2Setting",
                "value": "all",
                "operation": "update"
            },
            {
                "parameterName": "traceXNSetting",
                "value": "all",
                "operation": "update"
            },
            {
                "parameterName": "nrPeriodicUeMeas",
                "value": [
                    {"cellMaxPeriodicUEsTraced": 2, "reportAmount": "r4", "reportInterval": "ms640"}
                ],
                "operation": "update"
            },

        ]
    },
]

add_nrctrlts_007_23R2 = [
    {
        "distName": MRBTS + "/" + NRBTS + "/NRCTRLTS-1",
        "operation": "create",
        "parameters": []
    },
    {
        "distName": MRBTS + "/" + NRBTS + "/NRCTRLTS-1/NRMTRACECU-1",
        "operation": "create",
        "parameters": [
            {
                "parameterName": "actCellTraceReportingCU",
                "value": "true",
                "operation": "update"
            },
            {
                "parameterName": "actPCMDReporting",
                "value": "true",
                "operation": "update"
            },
            {
                "parameterName": "cellMaxActiveUEsTraced",
                "value": 100,
                "operation": "update"
            },
            {
                "parameterName": "jobType",
                "value": "ImmediateMDTAndTrace",
                "operation": "update"
            },
            {
                "parameterName": "nrMtraceCuId",
                "value": "1",
                "operation": "update"
            },
            {
                "parameterName": "nrRanTraceReference",
                "value": [
                    {"mcc": mcc, "mnc": mnc, "mncLength": 2, "traceId": MRBTS_ID}
                ],
                "operation": "update"
            },
            {
                "parameterName": "nrTceIdentifier",
                "value": 1,
                "operation": "update"
            },
            {
                "parameterName": "scope",
                "value": "allResources",
                "operation": "update"
            },
            {
                "parameterName": "traceNGAPSetting",
                "value": "all",
                "operation": "update"
            },
            {
                "parameterName": "traceNRRRCSetting",
                "value": "all",
                "operation": "update"
            },
            {
                "parameterName": "traceX2Setting",
                "value": "all",
                "operation": "update"
            },
            {
                "parameterName": "traceXNSetting",
                "value": "all",
                "operation": "update"
            },
            # {
            #     "parameterName": "nrPeriodicUeMeas",
            #     "value": [
            #         {"cellMaxPeriodicUEsTraced": 2, "reportAmount": "r4", "reportInterval": "ms640"}
            #     ],
            #     "operation": "update"
            # },
            {
                "parameterName": "immedMDTUEMeas",
                "value": [
                    {"mdtMeasType": "periodic",
                     "reportAmount": "r4",
                     "reportInterval": "ms640",
                     "rrmEventTriggeredMeas": "false"}
                ],
                "operation": "update"
            },
            {
                "parameterName": "immedMDTControl",

                "value": [
                    {
                        "cellMaxActiveMDTUEsTraced": "2",
                        "immedMDTObtainLocation": "false",
                        "immedMDTPosMethod": "none",
                        "immedMDTSelectOnlyGNSSUEs": "false"
                    }
                ],
                "operation": "update"
            },

        ]
    },
]
