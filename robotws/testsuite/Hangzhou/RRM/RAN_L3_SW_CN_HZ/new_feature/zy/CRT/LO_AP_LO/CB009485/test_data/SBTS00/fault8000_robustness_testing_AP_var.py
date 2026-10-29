PARAMS_IN_SCF = []

clean_trace_mocs = [
    "delete:TCE-.*",
    "delete:NRMTRACECU-.*",
    "delete:MRBTS/MNL-1/TCEADM-1",
    "delete:NRBTS/NRCTRLTS-1"
]
trace_NRBTS_flags = [
    "NRBTS:actPCMDReport=true",
    "NRBTS:actCellTraceReport=true",
    "NRBTS:actSubscriberTraceReport=true",
]

c1_delta_TCE1_MTRACECU1 = [
    # TCE-1
    "MRBTS/MNL-1/TCEADM-1",
    "MRBTS/MNL-1/TCEADM-1/TCE-1:tceIdentifier=1",
    "MRBTS/MNL-1/TCEADM-1/TCE-1:tceIpAddress=11.11.11.11",
    "MRBTS/MNL-1/TCEADM-1/TCE-1:tcePortNumber=49100",
    "MRBTS/MNL-1/TCEADM-1/TCE-1:tlsEnabled=false",
    # NRMTRACECU-1
    "NRBTS/NRCTRLTS-1",
    "NRBTS/NRCTRLTS-1/NRMTRACECU-1:jobType=TraceOnly",
    "NRBTS/NRCTRLTS-1/NRMTRACECU-1:cellMaxActiveUEsTraced=100",
    "NRBTS/NRCTRLTS-1/NRMTRACECU-1:nrTceIdentifier=1",
    "NRBTS/NRCTRLTS-1/NRMTRACECU-1:scope=allResources",
    "NRBTS/NRCTRLTS-1/NRMTRACECU-1:nrRanTraceReference:mcc=311",
    "NRBTS/NRCTRLTS-1/NRMTRACECU-1:nrRanTraceReference:mnc=489",
    "NRBTS/NRCTRLTS-1/NRMTRACECU-1:nrRanTraceReference:mncLength=3",
    "NRBTS/NRCTRLTS-1/NRMTRACECU-1:nrRanTraceReference:traceId=1",
    "NRBTS/NRCTRLTS-1/NRMTRACECU-1:actPCMDReporting=true",
    "NRBTS/NRCTRLTS-1/NRMTRACECU-1:tracePCMDSetting=all",
    "NRBTS/NRCTRLTS-1/NRMTRACECU-1:actCellTraceReportingCU=true",
    "NRBTS/NRCTRLTS-1/NRMTRACECU-1:traceE1Setting=all",
]

c1_delta_delete_TCE1_MTRACECU1_add_TCE2_MTRACECU2 = [
    "delete:MRBTS/MNL-1/TCEADM-1/TCE-1",
    "delete:NRBTS/NRCTRLTS-1/NRMTRACECU-1",
    # TCE-2 has different IP with TCE-1, but same tceIdentifier
    "MRBTS/MNL-1/TCEADM-1/TCE-2:tceIdentifier=1",
    "MRBTS/MNL-1/TCEADM-1/TCE-2:tceIpAddress=10.0.1.1",
    "MRBTS/MNL-1/TCEADM-1/TCE-2:tcePortNumber=49100",
    "MRBTS/MNL-1/TCEADM-1/TCE-2:tlsEnabled=false",
    # MTRACECU-2 has same parameter with MTRACECU-1, especially same nrTceIdentifier
    "NRBTS/NRCTRLTS-1/NRMTRACECU-2:jobType=TraceOnly",
    "NRBTS/NRCTRLTS-1/NRMTRACECU-2:cellMaxActiveUEsTraced=100",
    "NRBTS/NRCTRLTS-1/NRMTRACECU-2:nrTceIdentifier=1",
    "NRBTS/NRCTRLTS-1/NRMTRACECU-2:scope=allResources",
    "NRBTS/NRCTRLTS-1/NRMTRACECU-2:nrRanTraceReference:mcc=311",
    "NRBTS/NRCTRLTS-1/NRMTRACECU-2:nrRanTraceReference:mnc=489",
    "NRBTS/NRCTRLTS-1/NRMTRACECU-2:nrRanTraceReference:mncLength=3",
    "NRBTS/NRCTRLTS-1/NRMTRACECU-2:nrRanTraceReference:traceId=1",
    "NRBTS/NRCTRLTS-1/NRMTRACECU-2:actPCMDReporting=true",
    "NRBTS/NRCTRLTS-1/NRMTRACECU-2:tracePCMDSetting=all",
    "NRBTS/NRCTRLTS-1/NRMTRACECU-2:actCellTraceReportingCU=true",
    "NRBTS/NRCTRLTS-1/NRMTRACECU-2:traceE1Setting=all",
]

c2_delta_TCE2_MTRACECU1 = [
    # TCE-1
    "MRBTS/MNL-1/TCEADM-1",
    "MRBTS/MNL-1/TCEADM-1/TCE-2:tceIdentifier=1",
    "MRBTS/MNL-1/TCEADM-1/TCE-2:tceIpAddress=11.11.11.11",
    "MRBTS/MNL-1/TCEADM-1/TCE-2:tcePortNumber=49100",
    "MRBTS/MNL-1/TCEADM-1/TCE-2:tlsEnabled=false",
    # NRMTRACECU-1
    "NRBTS/NRCTRLTS-1",
    "NRBTS/NRCTRLTS-1/NRMTRACECU-1:jobType=TraceOnly",
    "NRBTS/NRCTRLTS-1/NRMTRACECU-1:cellMaxActiveUEsTraced=100",
    "NRBTS/NRCTRLTS-1/NRMTRACECU-1:nrTceIdentifier=1",
    "NRBTS/NRCTRLTS-1/NRMTRACECU-1:scope=allResources",
    "NRBTS/NRCTRLTS-1/NRMTRACECU-1:nrRanTraceReference:mcc=311",
    "NRBTS/NRCTRLTS-1/NRMTRACECU-1:nrRanTraceReference:mnc=489",
    "NRBTS/NRCTRLTS-1/NRMTRACECU-1:nrRanTraceReference:mncLength=3",
    "NRBTS/NRCTRLTS-1/NRMTRACECU-1:nrRanTraceReference:traceId=1",
    "NRBTS/NRCTRLTS-1/NRMTRACECU-1:actPCMDReporting=true",
    "NRBTS/NRCTRLTS-1/NRMTRACECU-1:tracePCMDSetting=all",
    "NRBTS/NRCTRLTS-1/NRMTRACECU-1:actCellTraceReportingCU=true",
    "NRBTS/NRCTRLTS-1/NRMTRACECU-1:traceE1Setting=all",
]

c2_delta_delete_TCE2_MTRACECU1_add_TCE1_MTRACECU2 = [
    "delete:MRBTS/MNL-1/TCEADM-1/TCE-2",
    "delete:NRBTS/NRCTRLTS-1/NRMTRACECU-1",
    # TCE-2 has different IP with TCE-1, but same tceIdentifier
    "MRBTS/MNL-1/TCEADM-1/TCE-1:tceIdentifier=1",
    "MRBTS/MNL-1/TCEADM-1/TCE-1:tceIpAddress=10.0.1.1",
    "MRBTS/MNL-1/TCEADM-1/TCE-1:tcePortNumber=49100",
    "MRBTS/MNL-1/TCEADM-1/TCE-1:tlsEnabled=false",
    # MTRACECU-2 has same parameter with MTRACECU-1, especially same nrTceIdentifier
    "NRBTS/NRCTRLTS-1/NRMTRACECU-2:jobType=TraceOnly",
    "NRBTS/NRCTRLTS-1/NRMTRACECU-2:cellMaxActiveUEsTraced=100",
    "NRBTS/NRCTRLTS-1/NRMTRACECU-2:nrTceIdentifier=1",
    "NRBTS/NRCTRLTS-1/NRMTRACECU-2:scope=allResources",
    "NRBTS/NRCTRLTS-1/NRMTRACECU-2:nrRanTraceReference:mcc=311",
    "NRBTS/NRCTRLTS-1/NRMTRACECU-2:nrRanTraceReference:mnc=489",
    "NRBTS/NRCTRLTS-1/NRMTRACECU-2:nrRanTraceReference:mncLength=3",
    "NRBTS/NRCTRLTS-1/NRMTRACECU-2:nrRanTraceReference:traceId=1",
    "NRBTS/NRCTRLTS-1/NRMTRACECU-2:actPCMDReporting=true",
    "NRBTS/NRCTRLTS-1/NRMTRACECU-2:tracePCMDSetting=all",
    "NRBTS/NRCTRLTS-1/NRMTRACECU-2:actCellTraceReportingCU=true",
    "NRBTS/NRCTRLTS-1/NRMTRACECU-2:traceE1Setting=all",
]
