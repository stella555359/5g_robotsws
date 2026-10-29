from robot.libraries.BuiltIn import BuiltIn

tl = BuiltIn().get_variable_value("${tl}")
gNbId = tl.gnbs[0].instance_id

PCMD_Enable = [
    "MRBTS/MNL-1/MNLENT-1/SECADM:actServicePortState=true",
    "NRCELL:actTrsPdschAvgCqiRatio=false",
    "MRBTS/MNL-1/TCEADM-1",
    "MRBTS/MNL-1/TCEADM-1/TCE-1:tceIdentifier=1",
    "MRBTS/MNL-1/TCEADM-1/TCE-1:tceIpAddress=10.0.1.1",
    "MRBTS/MNL-1/TCEADM-1/TCE-1:tlsEnabled=false",
    "NRBTS/NRCTRLTS-1",
    "NRBTS/NRCTRLTS-1/NRMTRACECU-1:cellMaxActiveUEsTraced=10",
    "NRBTS/NRCTRLTS-1/NRMTRACECU-1:nrTceIdentifier=1",
    "NRBTS/NRCTRLTS-1/NRMTRACECU-1:scope=allResources",
    "NRBTS/NRCTRLTS-1/NRMTRACECU-1:nrRanTraceReference:mcc=311",
    "NRBTS/NRCTRLTS-1/NRMTRACECU-1:nrRanTraceReference:mnc=489",
    "NRBTS/NRCTRLTS-1/NRMTRACECU-1:nrRanTraceReference:mncLength=3",
    "NRBTS/NRCTRLTS-1/NRMTRACECU-1:nrRanTraceReference:traceId=1",
    "NRBTS/NRCTRLTS-1/NRMTRACECU-1:tracePCMDSetting=all",
    "NRBTS:actPCMDReport=true",
    "NRBTS/NRCTRLTS-1/NRMTRACECU-1:actPCMDReporting=true",
    "NRBTS/NRCTRLTS-1/NRMTRACECU-1:jobType=TraceOnly",
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
]

PCMD_port_GNB1 = [
    "MRBTS/MNL-1/TCEADM-1/TCE-1:tcePortNumber=49100",
]

CellTrace_Enable = [
    "NRBTS:actCellTraceReport=true",
    "NRBTS/NRCTRLTS-1/NRMTRACECU-1:actCellTraceReportingCU=true",
    "NRBTS/NRCTRLTS-1/NRMTRACECU-1:traceE1Setting=all",
    "NRBTS/NRCTRLTS-1/NRMTRACECU-1:traceF1Setting=all",
    "NRBTS/NRCTRLTS-1/NRMTRACECU-1:traceNRRRCSetting=all",
    "NRBTS/NRCTRLTS-1/NRMTRACECU-1:traceX2Setting=all",
    "NRBTS/NRCTRLTS-1/NRMTRACECU-1:traceNGAPSetting=all",
    "NRBTS/NRCTRLTS-1/NRMTRACECU-1:traceXNSetting=all",
]

MDT_Enable = [
    "NRBTS:actMDTTraceReport=true",
    "NRBTS/NRCTRLTS-1/NRMTRACECU-1:jobType=ImmediateMDTAndTrace",
    "NRBTS/NRCTRLTS-1/NRMTRACECU-1:immedMDTUEMeas:mdtMeasType=periodic",
    "NRBTS/NRCTRLTS-1/NRMTRACECU-1:immedMDTUEMeas:reportAmount=infinity",
    "NRBTS/NRCTRLTS-1/NRMTRACECU-1:immedMDTUEMeas:reportInterval=ms5120",
    "NRBTS/NRCTRLTS-1/NRMTRACECU-1:immedMDTControl:cellMaxActiveMDTUEsTraced=10",
]

Segment = [
    "NRBTS:actSegUeCapUl=true",
]

PARAMS_IN_SCF = PCMD_Enable + CellTrace_Enable + PCMD_port_GNB1 + Segment
