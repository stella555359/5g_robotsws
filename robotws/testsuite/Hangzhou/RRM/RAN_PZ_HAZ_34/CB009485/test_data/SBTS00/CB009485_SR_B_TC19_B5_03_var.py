from robot.libraries.BuiltIn import BuiltIn
testline_ip = BuiltIn().get_variable_value("${testline_ip}")

PARAMS_IN_SWCONFIG = [
    "0x890073 = 0",  # Disable CB007208
    "0x5B0609 = 1",  # L2-HI rdDebugPcmdNrt
    "0x5B0610 = 1",  # L2-HI rdDebugPcmdRt
    "0x57000E = 1",  # enable L2-LO NRT PCMD debug logs
]

PARAMS_IN_SCF = [
    "NRBTS:rrcReestabTypeSA=sameGNB",
    # Trace
    "NRBTS:actCellTraceReport=true",
    "NRBTS:actSubscriberTraceReport=true",
    "NRBTS:actPCMDReport=true",
    # TCE
    "MRBTS/MNL-1/TCEADM-1",
    "MRBTS/MNL-1/TCEADM-1/TCE-1:tceIdentifier=1",
    f"MRBTS/MNL-1/TCEADM-1/TCE-1:tceIpAddress={testline_ip}",
    "MRBTS/MNL-1/TCEADM-1/TCE-1:tcePortNumber=49100",
    "MRBTS/MNL-1/TCEADM-1/TCE-1:tlsEnabled=false",
    # NRMTRACECU
    "NRBTS/NRCTRLTS-1",
    "NRBTS/NRCTRLTS-1/NRMTRACECU-1:nrTceIdentifier=1",
    "NRBTS/NRCTRLTS-1/NRMTRACECU-1:scope=allResources",
    "NRBTS/NRCTRLTS-1/NRMTRACECU-1:nrRanTraceReference:mcc=311",
    "NRBTS/NRCTRLTS-1/NRMTRACECU-1:nrRanTraceReference:mnc=489",
    "NRBTS/NRCTRLTS-1/NRMTRACECU-1:nrRanTraceReference:mncLength=3",
    "NRBTS/NRCTRLTS-1/NRMTRACECU-1:nrRanTraceReference:traceId=1",
    "NRBTS/NRCTRLTS-1/NRMTRACECU-1:actCellTraceReportingCU=true",
    "NRBTS/NRCTRLTS-1/NRMTRACECU-1:traceNGAPSetting=all",
    "NRBTS/NRCTRLTS-1/NRMTRACECU-1:traceNRRRCSetting=all",
    "NRBTS/NRCTRLTS-1/NRMTRACECU-1:traceX2Setting=all",
    "NRBTS/NRCTRLTS-1/NRMTRACECU-1:traceXNSetting=all",
    "NRBTS/NRCTRLTS-1/NRMTRACECU-1:traceF1Setting=all",
    "NRBTS/NRCTRLTS-1/NRMTRACECU-1:traceE1Setting=all",
    "NRBTS/NRCTRLTS-1/NRMTRACECU-1:actPCMDReporting=true",
    "NRBTS/NRCTRLTS-1/NRMTRACECU-1:jobType=TraceOnly",
    "NRBTS/NRCTRLTS-1/NRMTRACECU-1:tracePCMDSetting=all",
    # NRSTRACECU
    "NRBTS/NRCTRLTS-1/NRSTRACECU-1",
    "NRBTS/NRCTRLTS-1/NRSTRACECU-1:nrStraceCuId=1",
    "NRBTS/NRCTRLTS-1/NRSTRACECU-1:applyDefNrTceForAllSessions=true",
    "NRBTS/NRCTRLTS-1/NRSTRACECU-1:certTypeForTlsAuth=RSA",
    "NRBTS/NRCTRLTS-1/NRSTRACECU-1:defaultNrTceIdentifier=1",
    "NRBTS/NRCTRLTS-1/NRSTRACECU-1:nrTcePortNumber=49100",
    "NRBTS/NRCTRLTS-1/NRSTRACECU-1:tlsEnabled=false",
    "NRBTS/NRCTRLTS-1/NRSTRACECU-1:actPCMDReporting=true",
    "NRBTS/NRCTRLTS-1/NRSTRACECU-1:tracePCMDSetting=all",
    # NRMTRACEDU
    "NRBTS/NRDU-1/NRCTRLTSDU-1",
    "NRBTS/NRDU-1/NRCTRLTSDU-1/NRMTRACEDU-1:actPCMDReporting=true",
    "NRBTS/NRDU-1/NRCTRLTSDU-1/NRMTRACEDU-1:jobType=TraceOnly",
    "NRBTS/NRDU-1/NRCTRLTSDU-1/NRMTRACEDU-1:nrTceIdentifier=1",
    "NRBTS/NRDU-1/NRCTRLTSDU-1/NRMTRACEDU-1:scope=allResources",
    "NRBTS/NRDU-1/NRCTRLTSDU-1/NRMTRACEDU-1:tracePCMDSetting=all",
    "NRBTS/NRDU-1/NRCTRLTSDU-1/NRMTRACEDU-1:nrRanTraceReference:mcc=311",
    "NRBTS/NRDU-1/NRCTRLTSDU-1/NRMTRACEDU-1:nrRanTraceReference:mnc=489",
    "NRBTS/NRDU-1/NRCTRLTSDU-1/NRMTRACEDU-1:nrRanTraceReference:mncLength=3",
    "NRBTS/NRDU-1/NRCTRLTSDU-1/NRMTRACEDU-1:nrRanTraceReference:traceId=1",
    # NRSTRACEDU
    "NRBTS/NRDU-1/NRCTRLTSDU-1",
    "NRBTS/NRDU-1/NRCTRLTSDU-1/NRSTRACEDU-1",
    "NRBTS/NRDU-1/NRCTRLTSDU-1/NRSTRACEDU-1:nrStraceDuId=1",
    "NRBTS/NRDU-1/NRCTRLTSDU-1/NRSTRACEDU-1:applyDefNrTceForAllSessions=true",
    "NRBTS/NRDU-1/NRCTRLTSDU-1/NRSTRACEDU-1:certTypeForTlsAuth=RSA",
    "NRBTS/NRDU-1/NRCTRLTSDU-1/NRSTRACEDU-1:defaultNrTceIdentifier=1",
    "NRBTS/NRDU-1/NRCTRLTSDU-1/NRSTRACEDU-1:nrTcePortNumber=49100",
    "NRBTS/NRDU-1/NRCTRLTSDU-1/NRSTRACEDU-1:tlsEnabled=false",
    "NRBTS/NRDU-1/NRCTRLTSDU-1/NRSTRACEDU-1:actPCMDReporting=true",
    "NRBTS/NRDU-1/NRCTRLTSDU-1/NRSTRACEDU-1:tracePCMDSetting=all",
]
