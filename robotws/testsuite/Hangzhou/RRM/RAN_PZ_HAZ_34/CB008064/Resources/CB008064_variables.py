import requests
import re
from taf.transport.ssh import ssh
from requests.packages.urllib3.exceptions import InsecureRequestWarning, InsecurePlatformWarning
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

dcap_server_ip = tl.test_pc[1].default_ssh_connection_details.addr
dcap_server_username = tl.test_pc[1].default_ssh_connection_details.username
dcap_server_password = tl.test_pc[1].default_ssh_connection_details.password
dcap_server_port = tl.test_pc[1].default_ssh_connection_details.port
dcap_server_ip_2 = tl.test_pc[2].default_ssh_connection_details.addr
dcap_server_port_2 = tl.test_pc[2].default_ssh_connection_details.port
dcap_server_ip_3 = tl.test_pc[3].default_ssh_connection_details.addr
dcap_server_username_3 = tl.test_pc[3].default_ssh_connection_details.username
dcap_server_password_3 = tl.test_pc[3].default_ssh_connection_details.password
dcap_server_port_3 = tl.test_pc[3].default_ssh_connection_details.port

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

del_nrctrltscuup = {
    "distName": MRBTS + "/" + NRBTS + "/NRCUUP-1/NRCTRLTSCUUP-1",
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

add_nrctrltsdu = [
    {
        "distName": MRBTS + "/" + NRBTS + "/NRDU-1/NRCTRLTSDU-1",
        "operation": "create",
        "parameters": [
            {
                "parameterName": "nrCtrltsDuId",
                "value": 1,
                "operation": "update"
            }
        ]
    }
]

add_nrctrltscuup = [
    {
        "distName": MRBTS + "/" + NRBTS + "/NRCUUP-1/NRCTRLTSCUUP-1",
        "operation": "create",
        "parameters": [
            {
                "parameterName": "nrCtrltsCuUpId",
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

add_tce3 = [
    {
        "distName": MRBTS + "/MNL-1/TCEADM-1/TCE-3",
        "operation": "create",
        "parameters": [
            {
                "parameterName": "tceIdentifier",
                "value": 3,
                "operation": "update"
            },
            {
                "parameterName": "tceIpAddress",
                "value": dcap_server_ip_3,
                "operation": "update"
            },
            {
                "parameterName": "tcePortNumber",
                "value": dcap_server_port_3,
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

add_unavailable_tce = [
    {
        "distName": MRBTS + "/MNL-1/TCEADM-1/TCE-10",
        "operation": "create",
        "parameters": [
            {
                "parameterName": "tceIdentifier",
                "value": 1,
                "operation": "update"
            },
            {
                "parameterName": "tceIpAddress",
                "value": "10.101.101.101",
                "operation": "update"
            },
            {
                "parameterName": "tcePortNumber",
                "value": "44444",
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

add_nrmtracecu1 = [
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
                    {"mcc": mcc, "mnc": mnc, "mncLength": 2, "traceId": 1}
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
                        "cellMaxActiveMDTUEsTraced": "100",
                        "immedMDTObtainLocation": "false",
                        "immedMDTPosMethod": "none",
                        "immedMDTSelectOnlyGNSSUEs": "false"
                    }
                ],
                "operation": "update"
            },
        ]
    }
]

add_nrmtracecu2 = [
    {
        "distName": MRBTS + "/" + NRBTS + "/NRCTRLTS-1/NRMTRACECU-2",
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
                "value": "ImmediateMDTAndTrace",
                "operation": "update"
            },
            {
                "parameterName": "nrMtraceCuId",
                "value": "2",
                "operation": "update"
            },
            {
                "parameterName": "nrRanTraceReference",
                "value": [
                    {"mcc": mcc, "mnc": mnc, "mncLength": 2, "traceId": 2}
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
                    {
                     "mdtMeasType": "periodic",
                     "reportAmount": "infinity",
                     "reportInterval": "min30",
                     "rrmEventTriggeredMeas": "false"
                     }
                ],
                "operation": "update"
            },
            {
                "parameterName": "immedMDTControl",

                "value": [
                    {
                        "cellMaxActiveMDTUEsTraced": "100",
                        "immedMDTObtainLocation": "false",
                        "immedMDTPosMethod": "none",
                        "immedMDTSelectOnlyGNSSUEs": "false"
                    }
                ],
                "operation": "update"
            },
        ]
    }
]

add_nrmtracecu3 = [
    {
        "distName": MRBTS + "/" + NRBTS + "/NRCTRLTS-1/NRMTRACECU-3",
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
                "parameterName": "nrMtraceCuId",
                "value": "3",
                "operation": "update"
            },
            {
                "parameterName": "nrRanTraceReference",
                "value": [
                    {"mcc": mcc, "mnc": mnc, "mncLength": 2, "traceId": 3}
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
                    {
                     "mdtMeasType": "periodic",
                     "reportAmount": "infinity",
                     "reportInterval": "min30",
                     "rrmEventTriggeredMeas": "false"
                     }
                ],
                "operation": "update"
            },
            {
                "parameterName": "immedMDTControl",
                "value": [
                    {
                        "cellMaxActiveMDTUEsTraced": "100",
                        "immedMDTObtainLocation": "false",
                        "immedMDTPosMethod": "none",
                        "immedMDTSelectOnlyGNSSUEs": "false"
                    }
                ],
                "operation": "update"
            },
        ]
    }
]

add_nrmtracecu4 = [
    {
        "distName": MRBTS + "/" + NRBTS + "/NRCTRLTS-1/NRMTRACECU-4",
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
                "value": "ImmediateMDTAndTrace",
                "operation": "update"
            },
            {
                "parameterName": "nrMtraceCuId",
                "value": "4",
                "operation": "update"
            },
            {
                "parameterName": "nrRanTraceReference",
                "value": [
                    {"mcc": mcc, "mnc": mnc, "mncLength": 2, "traceId": 4}
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
            },
            {
                "parameterName": "immedMDTUEMeas",
                "value": [
                    {
                     "mdtMeasType": "periodic",
                     "reportAmount": "infinity",
                     "reportInterval": "ms5120",
                     "rrmEventTriggeredMeas": "false"
                     }
                ],
                "operation": "update"
            },
            {
                "parameterName": "immedMDTControl",

                "value": [
                    {
                        "cellMaxActiveMDTUEsTraced": "100",
                        "immedMDTObtainLocation": "false",
                        "immedMDTPosMethod": "none",
                        "immedMDTSelectOnlyGNSSUEs": "false"
                    }
                ],
                "operation": "update"
            },
        ]
    }
]

add_nrmtracecu5 = [
    {
        "distName": MRBTS + "/" + NRBTS + "/NRCTRLTS-1/NRMTRACECU-5",
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
                "value": "5",
                "operation": "update"
            },
            {
                "parameterName": "nrRanTraceReference",
                "value": [
                    {"mcc": mcc, "mnc": mnc, "mncLength": 2, "traceId": 5}
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
                    {
                     "mdtMeasType": "periodic",
                     "reportAmount": "r2",
                     "reportInterval": "ms120",
                     "rrmEventTriggeredMeas": "false"
                     }
                ],
                "operation": "update"
            },
            {
                "parameterName": "immedMDTControl",

                "value": [
                    {
                        "cellMaxActiveMDTUEsTraced": "100",
                        "immedMDTObtainLocation": "false",
                        "immedMDTPosMethod": "none",
                        "immedMDTSelectOnlyGNSSUEs": "false"
                    }
                ],
                "operation": "update"
            },
        ]
    }
]

add_nrmtracedu1 = [
    {
        "distName": MRBTS + "/" + NRBTS + "/NRDU-1/NRCTRLTSDU-1/NRMTRACEDU-1",
        "operation": "create",
        "parameters": [
            {
                "parameterName": "actRIReporting",
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
                    {"mcc": mcc, "mnc": mnc, "mncLength": 2, "traceId": 1}
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
    }
]

add_nrmtracedu2 = [
    {
        "distName": MRBTS + "/" + NRBTS + "/NRDU-1/NRCTRLTSDU-1/NRMTRACEDU-2",
        "operation": "create",
        "parameters": [
            {
                "parameterName": "actRIReporting",
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
                    {"mcc": mcc, "mnc": mnc, "mncLength": 2, "traceId": 2}
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
    }
]

add_nrmtracedu3 = [
    {
        "distName": MRBTS + "/" + NRBTS + "/NRDU-1/NRCTRLTSDU-1/NRMTRACEDU-3",
        "operation": "create",
        "parameters": [
            {
                "parameterName": "actRIReporting",
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
                    {"mcc": mcc, "mnc": mnc, "mncLength": 2, "traceId": 3}
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
    }
]

add_nrmtracedu4 = [
    {
        "distName": MRBTS + "/" + NRBTS + "/NRDU-1/NRCTRLTSDU-1/NRMTRACEDU-4",
        "operation": "create",
        "parameters": [
            {
                "parameterName": "actRIReporting",
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
                    {"mcc": mcc, "mnc": mnc, "mncLength": 2, "traceId": 4}
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
    }
]

add_nrmtracedu5 = [
    {
        "distName": MRBTS + "/" + NRBTS + "/NRDU-1/NRCTRLTSDU-1/NRMTRACEDU-5",
        "operation": "create",
        "parameters": [
            {
                "parameterName": "actRIReporting",
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
                    {"mcc": mcc, "mnc": mnc, "mncLength": 2, "traceId": 5}
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
    }
]

add_subscriber_trace = [
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

add_nrmtracecuup1 = [
    {
        "distName": MRBTS + "/" + NRBTS + "/NRCUUP-1/NRCTRLTSCUUP-1/NRMTRACECUUP-1",
        "operation": "create",
        "parameters": [
            {
                "parameterName": "actPCMDReporting",
                "value": "true",
                "operation": "update"
            },
            {
                "parameterName": "cuUpMaxActiveUEsTraced",
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
                    {"mcc": mcc, "mnc": mnc, "mncLength": 2, "traceId": 1}
                ],
                "operation": "update"
            },
            {
                "parameterName": "nrTceIdentifier",
                "value": "1",
                "operation": "update"
            }
        ]
    },
]

add_nrmtracecuup2 = [
    {
        "distName": MRBTS + "/" + NRBTS + "/NRCUUP-1/NRCTRLTSCUUP-1/NRMTRACECUUP-2",
        "operation": "create",
        "parameters": [
            {
                "parameterName": "actPCMDReporting",
                "value": "true",
                "operation": "update"
            },
            {
                "parameterName": "cuUpMaxActiveUEsTraced",
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
                    {"mcc": mcc, "mnc": mnc, "mncLength": 2, "traceId": 2}
                ],
                "operation": "update"
            },
            {
                "parameterName": "nrTceIdentifier",
                "value": "1",
                "operation": "update"
            }
        ]
    },
]

add_nrmtracecuup3 = [
    {
        "distName": MRBTS + "/" + NRBTS + "/NRCUUP-1/NRCTRLTSCUUP-1/NRMTRACECUUP-3",
        "operation": "create",
        "parameters": [
            {
                "parameterName": "actPCMDReporting",
                "value": "true",
                "operation": "update"
            },
            {
                "parameterName": "cuUpMaxActiveUEsTraced",
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
                    {"mcc": mcc, "mnc": mnc, "mncLength": 2, "traceId": 3}
                ],
                "operation": "update"
            },
            {
                "parameterName": "nrTceIdentifier",
                "value": "1",
                "operation": "update"
            }
        ]
    },
]

add_nrmtracecuup4 = [
    {
        "distName": MRBTS + "/" + NRBTS + "/NRCUUP-1/NRCTRLTSCUUP-1/NRMTRACECUUP-4",
        "operation": "create",
        "parameters": [
            {
                "parameterName": "actPCMDReporting",
                "value": "true",
                "operation": "update"
            },
            {
                "parameterName": "cuUpMaxActiveUEsTraced",
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
                    {"mcc": mcc, "mnc": mnc, "mncLength": 2, "traceId": 4}
                ],
                "operation": "update"
            },
            {
                "parameterName": "nrTceIdentifier",
                "value": "1",
                "operation": "update"
            }
        ]
    },
]

add_nrmtracecuup5 = [
    {
        "distName": MRBTS + "/" + NRBTS + "/NRCUUP-1/NRCTRLTSCUUP-1/NRMTRACECUUP-5",
        "operation": "create",
        "parameters": [
            {
                "parameterName": "actPCMDReporting",
                "value": "true",
                "operation": "update"
            },
            {
                "parameterName": "cuUpMaxActiveUEsTraced",
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
                    {"mcc": mcc, "mnc": mnc, "mncLength": 2, "traceId": 5}
                ],
                "operation": "update"
            },
            {
                "parameterName": "nrTceIdentifier",
                "value": "1",
                "operation": "update"
            }
        ]
    },
]

# add_all_subscriber_trace_tls = [
#     {
#         "distName": MRBTS + "/" + NRBTS + "/NRCTRLTS-1/NRSTRACECU-1",
#         "operation": "create",
#         "parameters": [
#             {
#                 "parameterName": "applyDefNrTceForAllSessions",
#                 "value": "false",
#                 "operation": "update"
#             },
#             {
#                 "parameterName": "certTypeForTlsAuth",
#                 "value": "RSA",
#                 "operation": "update"
#             },
#             {
#                 "parameterName": "nrTcePortNumber",
#                 "value": "49148",
#                 "operation": "update"
#             },
#             {
#                 "parameterName": "tlsEnabled",
#                 "value": "true",
#                 "operation": "update"
#             },
#         ]
#     },
# ]

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
                "value": "1",
                "operation": "update"
            },
            {
                "parameterName": "nrTcePortNumber",
                "value": "49151",
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
                "value": "1",
                "operation": "update"
            },
            {
                "parameterName": "nrTcePortNumber",
                "value": "49151",
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


def check_if_package_exists(package_path):
    requests.packages.urllib3.disable_warnings(InsecureRequestWarning)
    requests.packages.urllib3.disable_warnings(InsecurePlatformWarning)
    r = requests.get(package_path, verify=False)
    if r.status_code == 200:
        return True
    else:
        return False


def get_sw_version_by_ssh(gnb_ip, username='toor4nsn', password='oZPS0POrRieRtu', format='abbreviation'):
    """
        - get sw version
        - format: abbreviation or full

        Example:
        | get_sw_version_by_ssh | 10.57.227.228 | format='abbreviation' |
        result: 11.800.604
        | get_sw_version_by_ssh | 10.57.227.228 | format='full' |
        result: 5G21A_GNB_0011_000800_000604
    """
    ssh_handler = ssh()
    ssh_handler.connect_to(gnb_ip, username, password)
    active_v_cmd = r"ls -al /ffs/run/ | grep -i TargetBD | grep -v .p7 | awk '{print $9}'"
    passive_v_cmd = r"ls -al /ffs/stb/ | grep -i TargetBD | grep -v .p7 | awk '{print $9}'"
    active_output = ssh_handler.execute(active_v_cmd)
    passive_output = ssh_handler.execute(passive_v_cmd)
    ssh_handler.disconnect()
    if format == 'abbreviation':
        active_v = __exact_version(active_output)
        passive_v = __exact_version(passive_output)
    elif format == 'full':
        active_v = active_output.strip('\r\n').lstrip('TargetBD_').rstrip('.xml')
        passive_v = passive_output.strip('\r\n').lstrip('TargetBD_').rstrip('.xml')
    else:
        raise Exception('wrong format')
    return active_v, passive_v


def __exact_version(origin_v):
    format_v = ''
    if origin_v:
        common_v = origin_v.find('SBTS')
        if common_v == -1:
            match_obj = re.match(r'.*?_0*(\d*)_0*(\d*)_0*(\d*)(.*)?\.xml', origin_v)
            if match_obj:
                format_v = '%s.%s.%s%s' % (match_obj.group(1) if match_obj.group(1) else '0',
                                           match_obj.group(2) if match_obj.group(2) else '0',
                                           match_obj.group(3) if match_obj.group(3) else '0',
                                           match_obj.group(4).rstrip('_').replace('_', '-')
                                           if match_obj.group(4) else '')
        else:
            match_obj = origin_v.strip('\r\n').lstrip('TargetBD_').rstrip('.xml').split('_')
            format_v = '%s_%s_%s_%s' % (match_obj[1], match_obj[2], match_obj[3], match_obj[4])
    return format_v
