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

dcap_server_ip = tl.test_pcs[1].default_ssh_connection_details.addr
dcap_server_username = tl.test_pcs[1].default_ssh_connection_details.username
dcap_server_password = tl.test_pcs[1].default_ssh_connection_details.password
dcap_server_port = tl.test_pcs[1].default_ssh_connection_details.port
dcap_server_ip_2 = tl.test_pcs[-1].default_ssh_connection_details.addr
dcap_server_port_2 = tl.test_pcs[-1].default_ssh_connection_details.port

del_nrctrlts = {
    "distName": MRBTS + "/" + NRBTS + "/NRCTRLTS-1",
    "operation": "delete",
    "parameters": []
}

del_nrstracecu = {
    "distName": MRBTS + "/" + NRBTS + "/NRCTRLTS-1/NRSTRACECU-1",
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

add_nrctrlts = [
    {
        "distName": MRBTS + "/" + NRBTS + "/NRCTRLTS-1",
        "operation": "create",
        "parameters": [
            {
                "parameterName": "nrCtrltsId",
                "value": 1,
                "operation": "update"
            }
        ]
    }
]

add_tceadm = [
    {
        "distName": MRBTS + "/MNL-1/TCEADM-1",
        "operation": "create",
        "parameters": [
            {
                "parameterName": "tceAdminId",
                "value": 1,
                "operation": "update"
            }
        ]
    }
]

add_tce = [
    {
        "distName": MRBTS + "/MNL-1/TCEADM-1/TCE-2",
        "operation": "create",
        "parameters": [
            {
                "parameterName": "tceIdentifier",
                "value": 2,
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

add_tce1 = [
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
            },
        ]
    },
]

add_tce2 = [
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
                "value": dcap_server_ip_2,
                "operation": "update"
            },
            {
                "parameterName": "tcePortNumber",
                "value": dcap_server_port_2,
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
            },
        ]
    },
]

add_all_subscriber_trace = [
    {
        "distName": MRBTS + "/" + NRBTS + "/NRCTRLTS-1/NRSTRACECU-1",
        "operation": "create",
        "parameters": [
            {
                "parameterName": "applyDefNrTceForAllSessions",
                "value": "false",
                "operation": "update"
            },
            {
                "parameterName": "certTypeForTlsAuth",
                "value": "RSA",
                "operation": "update"
            },
            {
                "parameterName": "nrTcePortNumber",
                "value": "49148",
                "operation": "update"
            },
            {
                "parameterName": "tlsEnabled",
                "value": "false",
                "operation": "update"
            },
        ]
    },
]

add_all_subscriber_trace_new = [
    {
        "distName": MRBTS + "/" + NRBTS + "/NRCTRLTS-1/NRSTRACECU-1",
        "operation": "create",
        "parameters": [
            {
                "parameterName": "applyDefNrTceForAllSessions",
                "value": "false",
                "operation": "update"
            },
            {
                "parameterName": "certTypeForTlsAuth",
                "value": "RSA",
                "operation": "update"
            },
            {
                "parameterName": "nrTcePortNumber",
                "value": "49148",
                "operation": "update"
            },
            {
                "parameterName": "tlsEnabled",
                "value": "false",
                "operation": "update"
            },
            {
                "parameterName": "maxBufferingTime",
                "value": "2000",
                "operation": "update"
            },
            {
                "parameterName": "actPCMDReporting",
                "value": "true",
                "operation": "update"
            },
            {
                "parameterName": "nrStraceCuId",
                "value": "1",
                "operation": "update"
            },
        ]
    },
]

add_all_subscriber_trace_tls = [
    {
        "distName": MRBTS + "/" + NRBTS + "/NRCTRLTS-1/NRSTRACECU-1",
        "operation": "create",
        "parameters": [
            {
                "parameterName": "applyDefNrTceForAllSessions",
                "value": "false",
                "operation": "update"
            },
            {
                "parameterName": "certTypeForTlsAuth",
                "value": "RSA",
                "operation": "update"
            },
            {
                "parameterName": "nrTcePortNumber",
                "value": "49148",
                "operation": "update"
            },
            {
                "parameterName": "tlsEnabled",
                "value": "true",
                "operation": "update"
            },
        ]
    },
]

add_all_subscriber_trace_tls_new = [
    {
        "distName": MRBTS + "/" + NRBTS + "/NRCTRLTS-1/NRSTRACECU-1",
        "operation": "create",
        "parameters": [
            {
                "parameterName": "applyDefNrTceForAllSessions",
                "value": "false",
                "operation": "update"
            },
            {
                "parameterName": "certTypeForTlsAuth",
                "value": "RSA",
                "operation": "update"
            },
            {
                "parameterName": "nrTcePortNumber",
                "value": "49148",
                "operation": "update"
            },
            {
                "parameterName": "tlsEnabled",
                "value": "true",
                "operation": "update"
            },
            {
                "parameterName": "maxBufferingTime",
                "value": "2000",
                "operation": "update"
            },
            {
                "parameterName": "actPCMDReporting",
                "value": "true",
                "operation": "update"
            },
            {
                "parameterName": "nrStraceCuId",
                "value": "1",
                "operation": "update"
            },
        ]
    },
]

add_default_tce_para_for_allsession = [
    {
        "distName": MRBTS + "/" + NRBTS + "/NRCTRLTS-1/NRSTRACECU-1",
        "operation": "create",
        "parameters": [
            {
                "parameterName": "applyDefNrTceForAllSessions",
                "value": "true",
                "operation": "update"
            },
            {
                "parameterName": "certTypeForTlsAuth",
                "value": "RSA",
                "operation": "update"
            },
            {
                "parameterName": "defaultNrTceIdentifier",
                "value": "2",
                "operation": "update"
            },
            {
                "parameterName": "nrTcePortNumber",
                "value": "49148",
                "operation": "update"
            },
            {
                "parameterName": "tlsEnabled",
                "value": "false",
                "operation": "update"
            },
        ]
    },
    {
        "distName": MRBTS + "/MNL-1/TCEADM-1/TCE-2",
        "operation": "create",
        "parameters": [
            {
                "parameterName": "tceIdentifier",
                "value": 2,
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

add_default_tce_para = [
    {
        "distName": MRBTS + "/" + NRBTS + "/NRCTRLTS-1/NRSTRACECU-1",
        "operation": "create",
        "parameters": [
            {
                "parameterName": "applyDefNrTceForAllSessions",
                "value": "false",
                "operation": "update"
            },
            {
                "parameterName": "certTypeForTlsAuth",
                "value": "RSA",
                "operation": "update"
            },
            {
                "parameterName": "defaultNrTceIdentifier",
                "value": "2",
                "operation": "update"
            },
            {
                "parameterName": "nrTcePortNumber",
                "value": "49148",
                "operation": "update"
            },
            {
                "parameterName": "tlsEnabled",
                "value": "false",
                "operation": "update"
            },
        ]
    },
    {
        "distName": MRBTS + "/MNL-1/TCEADM-1/TCE-2",
        "operation": "create",
        "parameters": [
            {
                "parameterName": "tceIdentifier",
                "value": 2,
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

add_cell_trace = [
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
                "value": "100",
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
                    {"mcc": 460, "mnc": 2, "mncLength": 2, "traceId": MRBTS_ID}
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
        ]
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

add_pcmd = [
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
                "value": "false",
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
                "parameterName": "traceNGAPSetting",
                "value": "none",
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
                    {"mcc": 460, "mnc": 2, "mncLength": 2, "traceId": MRBTS_ID}
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

add_cell_trace_and_pcmd = [
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
                    {"mcc": 460, "mnc": 2, "mncLength": 2, "traceId": MRBTS_ID}
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
                    {"mcc": 460, "mnc": 2, "mncLength": 2, "traceId": MRBTS_ID}
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

add_cell_trace_and_pcmd_without_tce = [
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
                    {"mcc": 460, "mnc": 2, "mncLength": 2, "traceId": MRBTS_ID}
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
                    {"mcc": 460, "mnc": 2, "mncLength": 2, "traceId": MRBTS_ID}
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
        ]
    },
]

add_cell_trace_and_pcmd_without_tce_23R3 = [
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
                    {"mcc": 460, "mnc": 2, "mncLength": 2, "traceId": MRBTS_ID}
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
                    {"mcc": 460, "mnc": 2, "mncLength": 2, "traceId": MRBTS_ID}
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
        ]
    },
]

FR1 = {
    "15 KHz": {
        "5MHz": "25",
        "10MHz": "52",
        "15MHz": "79",
        "20MHz": "106",
        "25MHz": "133",
        "30MHz": "160",
        "40MHz": "216",
        "50MHz": "270"
    },
    "30 KHz": {
        "5MHz": "11",
        "10MHz": "24",
        "15MHz": "38",
        "20MHz": "51",
        "25MHz": "65",
        "30MHz": "78",
        "40MHz": "106",
        "50MHz": "133",
        "60MHz": "162",
        "70MHz": "189",
        "80MHz": "217",
        "90MHz": "245",
        "100MHz": "273"
    },
    "60 KHz": {
        "10MHz": "11",
        "15MHz": "18",
        "20MHz": "24",
        "25MHz": "31",
        "30MHz": "38",
        "40MHz": "51",
        "50MHz": "65",
        "60MHz": "79",
        "70MHz": "93",
        "80MHz": "107",
        "90MHz": "121",
        "100MHz": "135"
    }
}

TL_cellid = {
    '10843': {
        'source_cellid': '1',
        'target_cellid': '2'
    }
}
