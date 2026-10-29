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

# dcap_server_ip = tl.test_pcs[0].default_ssh_connection_details.addr
# dcap_server_username = tl.test_pcs[0].default_ssh_connection_details.username
# dcap_server_password = tl.test_pcs[0].default_ssh_connection_details.password
# dcap_server_port = tl.test_pcs[0].default_ssh_connection_details.port

dcap_server_ip = "10.57.195.82"
dcap_server_port = 49148
# dcap_server_ip = "10.101.60.40"
# dcap_server_username = tl.test_pcs[0].default_ssh_connection_details.username
# dcap_server_password = tl.test_pcs[0].default_ssh_connection_details.password

del_nrctrlts = {
    "class_name": "NRCTRLTS",
    "dist_name": MRBTS + "/" + NRBTS + "/NRCTRLTS-1",
    "operation_type": "delete",
    "payload": "{}"
}

del_nrctrltscuup = {
    "class_name": "NRCTRLTSCUUP",
    "dist_name": MRBTS + "/" + NRBTS + "/NRCUUP-1/NRCTRLTSCUUP-1",
    "operation_type": "delete",
    "payload": "{}"
}

del_nrctrltsdu = {
    "class_name": "NRCTRLTSDU",
    "dist_name": MRBTS + "/" + NRBTS + "/NRDU-1/NRCTRLTSDU-1",
    "operation_type": "delete",
    "payload": "{}"
}

del_tceadm = {
    "class_name": "TCEADM",
    "dist_name": MRBTS + "/MNL-1/TCEADM-1",
    "operation_type": "delete",
    "payload": "{}"
}

del_pcmd_flag = {
    "class_name": "NRBTS",
    "dist_name": MRBTS + "/" + NRBTS,
    "operation_type": "update",
    "payload": '{"actPCMDReport": "false"}'
}

del_celltrace_flag = {
    "class_name": "NRBTS",
    "dist_name": MRBTS + "/" + NRBTS,
    "operation_type": "update",
    "payload": '{"actCellTraceReport": "false"}'
}


add_all_pcmd_cu = [
    {
        "class_name": "NRBTS",
        "dist_name": "MRBTS-886/NRBTS-886",
        "operation_type": "update",
        "payload": '{"actPCMDReport": "true", "actCellTraceReport": "true"}'
    },
    {
        "class_name": "NRCTRLTS",
        "dist_name": "MRBTS-886/NRBTS-886/NRCTRLTS-1",
        "operation_type": "create",
        "payload": '{}'
    },
    {
        "class_name": "NRMTRACECU",
        "dist_name": "MRBTS-886/NRBTS-886/NRCTRLTS-1/NRMTRACECU-1",
        "operation_type": "update",
        "payload": '''
            {
                "actCellTraceReportingCU": "true",
                "actPCMDReporting": "true",
                "cellMaxActiveUEsTraced": 100,
                "jobType": "TraceOnly",
                "nrRanTraceReference": {"mcc": 262, "mnc": 3, "mncLength": 2, "traceId": 886},
                "nrTceIdentifier": 1,
                "scope": "allResources",
                "traceNGAPSetting": "all",
                "traceNRRRCSetting": "all",
                "traceX2Setting": "all",
                "traceXNSetting": "all"
            }
        '''
    },
    {
        "class_name": "TCEADM",
        "dist_name": "MRBTS-886/MNL-1/TCEADM-1",
        "operation_type": "create",
        "payload": '{}'
    },
    {
        "class_name": "TCE",
        "dist_name": "MRBTS-886/MNL-1/TCEADM-1/TCE-1",
        "operation_type": "create",
        "payload": '''
            {
                "tceIdentifier": 1,
                "tceIpAddress": "10.57.195.82",
                "tcePortNumber": 49148,
                "tlsEnabled": "false",
                "certTypeForTlsAuth": "RSA"
            }
        '''
    }
]


add_all_pcmd_du = [
    {
        "class_name": "NRBTS",
        "dist_name": "MRBTS-886/NRBTS-886",
        "operation_type": "update",
        "payload": '{"actPCMDReport": "true", "actCellTraceReport": "true"}'
    },
    {
        "class_name": "NRCTRLTSDU",
        "dist_name": "MRBTS-886/NRBTS-886/NRDU-1/NRCTRLTSDU-1",
        "operation_type": "create",
        "payload": '{}'
    },
    {
        "class_name": "NRBTS",
        "dist_name": "MRBTS-886/NRBTS-886/NRDU-1/NRCTRLTSDU-1/NRMTRACEDU-1",
        "operation_type": "create",
        "payload": '''
            {
                "actPCMDReporting": "true",
                "actRIReporting": "false",
                "cellMaxActiveUEsTraced": 100,
                "jobType": "TraceOnly",
                "nrRanTraceReference": {"mcc": 262, "mnc": 3, "mncLength": 2, "traceId": 886}
                "nrTceIdentifier": 1,
                "scope": "allResources",
            }
        '''
    },
    {
        "class_name": "TCEADM",
        "dist_name": "MRBTS-886/MNL-1/TCEADM-1",
        "operation_type": "create",
        "payload": '{}'
    },
    {
        "class_name": "TCE",
        "dist_name": "MRBTS-886/MNL-1/TCEADM-1/TCE-1",
        "operation_type": "create",
        "payload": '''
            {
                "tceIdentifier": 1,
                "tceIpAddress": "10.57.195.82",
                "tcePortNumber": 49148,
                "tlsEnabled": "false",
                "certTypeForTlsAuth": "RSA"
            }
        '''
    }
]
