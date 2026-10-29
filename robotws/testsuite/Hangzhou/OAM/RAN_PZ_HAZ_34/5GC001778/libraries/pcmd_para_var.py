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
        mcc = "460"
        mnc = "2"
else:
    mcc = "460"
    mnc = "2"

if tl.gnbs[0].dcap:
    dcap_server_ip = tl.gnbs[0].dcap.connection_details.addr
    dcap_server_username = tl.gnbs[0].dcap.connection_details.username
    dcap_server_password = tl.gnbs[0].dcap.connection_details.password
    dcap_server_port = tl.gnbs[0].dcap.connection_details.port
else:
    dcap_server_ip = tl.test_pcs[0].default_ssh_connection_details.addr
    dcap_server_username = tl.test_pcs[0].default_ssh_connection_details.username
    dcap_server_password = tl.test_pcs[0].default_ssh_connection_details.password
    dcap_server_port = tl.test_pcs[0].default_ssh_connection_details.port

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
            },
            {
                "parameterName": "traceE1Setting",
                "value": "all",
                "operation": "update"
            },
            {
                "parameterName": "traceF1Setting",
                "value": "all",
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
            }
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

add_all_pcmd_25r3 = [
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
            },
            {
                "parameterName": "traceE1Setting",
                "value": "all",
                "operation": "update"
            },
            {
                "parameterName": "traceF1Setting",
                "value": "all",
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
            }
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
                "parameterName": "tracePCMDCoordinateSystem",
                "value": "DoA",
                "operation": "update"
            },
            {
                "parameterName": "tracePCMDSetting",
                "value": ["all"],
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

add_all_pcmd_26r1 = [
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
                "value": "TraceOnly",
                "operation": "update"
            },
            {
                "parameterName": "nrTceIdentifier",
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
                "parameterName": "scope",
                "value": "allResources",
                "operation": "update"
            },
            {
                "parameterName": "traceE1Setting",
                "value": "all",
                "operation": "update"
            },
            {
                "parameterName": "traceF1Setting",
                "value": "all",
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
                "parameterName": "tracePCMDSetting",
                "value": ["all"],
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
            }
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
                "parameterName": "nrTceIdentifier",
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
                "parameterName": "riReportInterval",
                "value": "s5",
                "operation": "update"
            },
            {
                "parameterName": "scope",
                "value": "allResources",
                "operation": "update"
            },
            # #SW deprecated the parameter  from SBTS00_ENB_9999_250801_000007
            # {
            #     "parameterName": "tracePCMDCoordinateSystem",
            #     "value": "DoA",
            #     "operation": "update"
            # },
            {
                "parameterName": "tracePCMDSetting",
                "value": ["all"],
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
                "parameterName": "certTypeForTlsAuth",
                "value": "RSA",
                "operation": "update"
            },
            {
                "parameterName": "tlsEnabled",
                "value": "false",
                "operation": "update"
            },
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
            }
        ]
    }
]

add_cell_trace_ngap = [
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
                "parameterName": "traceE1Setting",
                "value": "all",
                "operation": "update"
            },
            {
                "parameterName": "traceF1Setting",
                "value": "all",
                "operation": "update"
            },
            {
                "parameterName": "traceNGAPSetting",
                "value": "none",
                "operation": "update"
            },
            {
                "parameterName": "traceNRRRCSetting",
                "value": "all",
                "operation": "update"
            },
            {
                "parameterName": "traceX2Setting",
                "value": "none",
                "operation": "update"
            },
            {
                "parameterName": "traceXNSetting",
                "value": "none",
                "operation": "update"
            },
            {
                "parameterName": "cellMaxActiveUEsTraced",
                "value": "3",
                "operation": "update"
            },
            {
                "parameterName": "immedMDTControl",
                "operation": "delete"
            },
            {
                "parameterName": "immedMDTUEMeas",
                "operation": "delete"}
        ]
    },
    {
        "distName": MRBTS + "/" + NRBTS,
        "operation": "update",
        "parameters": [
            {
                "parameterName": "actCellTraceReport",
                "value": "true",
                "operation": "update"
            },
            {
                "parameterName": "actPCMDReport",
                "value": "false",
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

add_cell_trace_rrc = [
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
                "parameterName": "traceE1Setting",
                "value": "all",
                "operation": "update"
            },
            {
                "parameterName": "traceF1Setting",
                "value": "all",
                "operation": "update"
            },
            {
                "parameterName": "traceNGAPSetting",
                "value": "all",
                "operation": "update"
            },
            {
                "parameterName": "traceNRRRCSetting",
                "value": "none",
                "operation": "update"
            },
            {
                "parameterName": "traceX2Setting",
                "value": "none",
                "operation": "update"
            },
            {
                "parameterName": "traceXNSetting",
                "value": "none",
                "operation": "update"
            },
            {
                "parameterName": "cellMaxActiveUEsTraced",
                "value": "3",
                "operation": "update"
            },
            {
                "parameterName": "immedMDTControl",
                "operation": "delete"
            },
            {
                "parameterName": "immedMDTUEMeas",
                "operation": "delete"}
        ]
    },
    {
        "distName": MRBTS + "/" + NRBTS,
        "operation": "update",
        "parameters": [
            {
                "parameterName": "actCellTraceReport",
                "value": "true",
                "operation": "update"
            },
            {
                "parameterName": "actPCMDReport",
                "value": "false",
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

del_nrctrltscuup = {
    "distName": MRBTS + "/" + NRBTS + "/NRCUUP-1/NRCTRLTSCUUP-1",
    "operation": "delete",
    "parameters": []
}

List__allowfaults_1756 = ['8000']
