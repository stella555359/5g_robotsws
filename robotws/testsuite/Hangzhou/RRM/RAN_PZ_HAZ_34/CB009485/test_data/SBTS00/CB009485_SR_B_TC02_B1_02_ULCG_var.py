from robot.libraries.BuiltIn import BuiltIn
testline_ip = BuiltIn().get_variable_value("${testline_ip}")

PARAMS_IN_SWCONFIG = [
    "0x890073 = 0",     # Disable CB007208
    "0x5B0609 = 1",     # L2-HI rdDebugPcmdNrt
    "0x5B0610 = 1",     # L2-HI rdDebugPcmdRt
    "0x57000E = 1",     # enable L2-LO NRT PCMD debug logs
    "0x58057e = 512",   # ULCGTYPE2.COMMON
    "0x58057f = 1536",  # ULCGTYPE2.POOLING_ACTIVATION
]

PARAMS_IN_SCF = [
    # CA disabled
    "NRBTS/NRDU-1:carrierAggregationSupportList="
    "ca_Fdd_Fdd,"
    "ca_Fdd_Fr1Tdd_Sa,"
    "ca_Fdd_Fr1Tdd_Sa_WithUl,"
    "ca_Fr1Tdd_Fdd_Sa,"
    "ca_Fr1Tdd_Fdd_Sa_WithUl",
    "NRCELL:increasePUSCHPrepTimeULCA=false",
    "NRCELL:maxNumScellsDlFr1=",
    "NRCELL-1/NRREL-1:sCellAdditionMethod=",
    "NRCELL-1/NRREL-1:sCellOperationalMode=",
    "NRCELL-1/NRREL-2:sCellAdditionMethod=",
    "NRCELL-1/NRREL-2:sCellOperationalMode=",
    "NRCELL-1/NRREL-3:sCellAdditionMethod=",
    "NRCELL-1/NRREL-3:sCellOperationalMode=",
    "NRCELL-1/NRREL-4:sCellAdditionMethod=",
    "NRCELL-1/NRREL-4:sCellOperationalMode=",
    "NRCELL-10/NRREL-1:sCellAdditionMethod=",
    "NRCELL-10/NRREL-1:sCellOperationalMode=",
    "NRCELL-10/NRREL-2:sCellAdditionMethod=",
    "NRCELL-10/NRREL-2:sCellOperationalMode=",
    "NRCELL-10/NRREL-3:sCellAdditionMethod=",
    "NRCELL-10/NRREL-3:sCellOperationalMode=",
    "NRCELL-10/NRREL-4:sCellAdditionMethod=",
    "NRCELL-10/NRREL-4:sCellOperationalMode=",
    "NRCELL-12/NRREL-1:sCellAdditionMethod=",
    "NRCELL-12/NRREL-1:sCellOperationalMode=",
    "NRCELL-12/NRREL-2:sCellAdditionMethod=",
    "NRCELL-12/NRREL-2:sCellOperationalMode=",
    "NRCELL-12/NRREL-3:sCellAdditionMethod=",
    "NRCELL-12/NRREL-3:sCellOperationalMode=",
    "NRCELL-12/NRREL-4:sCellAdditionMethod=",
    "NRCELL-12/NRREL-4:sCellOperationalMode=",
    # make sure no other UEs' interference
    "NRCELL:qRxLevMin=-45",

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
    "NRBTS/NRCTRLTS-1/NRMTRACECU-1:nrRanTraceReference:mcc=262",
    "NRBTS/NRCTRLTS-1/NRMTRACECU-1:nrRanTraceReference:mnc=03",
    "NRBTS/NRCTRLTS-1/NRMTRACECU-1:nrRanTraceReference:mncLength=2",
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
    "NRBTS/NRDU-1/NRCTRLTSDU-1/NRMTRACEDU-1:nrRanTraceReference:mcc=262",
    "NRBTS/NRDU-1/NRCTRLTSDU-1/NRMTRACEDU-1:nrRanTraceReference:mnc=03",
    "NRBTS/NRDU-1/NRCTRLTSDU-1/NRMTRACEDU-1:nrRanTraceReference:mncLength=2",
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

    # UAI
    "NRBTS:rrcInactPreferredStateEnabled=false",
    "NRBTS:actRrcReleasePreference=false",
    "NRBTS:timerReleasePreferenceProhibit=s3",
    "NRBTS:outOfConnectedPreference=idle",
    "NRBTS:actRrcInactState=intra-gNB",
    "NRBTS:maxUeRrcInactTime=2",
    "NRBTS:rrcInactLocationReportEnabled=false",
    "NRBTS:t380=60min",
    "NRBTS:actPaging=true",
    "NRBTS:ranPagingCycle=v32",
    "NRBTS:activityNotificationLevelSA=ue",
    "NRBTS:act3gppBL23R1=true",
    "NRCELL/NRPLMNSET_SA-1:ranAC=0",
    # Idle_Inactive
    "NRBTS:rrcInactIMMSteeringEnabled=true",
    "NRBTS:tRanPagingGuard=5",
    "NRBTS:actIdleMMSteering=true",
    "NRCELL:idleMMSteeringAlgo=non CA aware",
    "NRCELL:idleMMSteeringPercentageOfUes=10",
    "NRCELL:idleMMSteeringWRREnabled=false",
    "NRCELL:idleMMSteeringWRREnabledSec=Disabled",

    # PDL validation conflict and performance impact
    "NRCELL:actForcedDftSOfdmVonrUl=false",
    "NRCELL:actRel16DmrsForPucchF3=false",
    "NRCELL:actRel16DmrsForPusch=false",
    "NRCELL:actUlTransPreEnhHo=false",
    "NRCELL-1:actBadUplinkRadioRedirect=disabled",
    "NRCELL-2:actBadUplinkRadioRedirect=disabled",
    # gNbCuType and cellDepType change to 3GPP option 2 standalone then ignore to wait LTEENB:x2LinkStatus=available
    "MRBTS/MNL-1/MNLENT-1/FEATCADM-1:actNrAutDegAdmCtrlSlCellDetRec=false",
    "MRBTS/MNL-1/MNLENT-1/FEATCADM-1:actNrAutSgnbAddCplSlCellDetRec=false",
    "MRBTS/MNL-1/MNLENT-1/FEATCADM-1:actNrAutUeCtxStpRtSlCellDetRec=false",
    "NRBTS:gNbCuType=SA",
    "NRBTS:actA2SgnbRelease=false",
    "NRBTS:periodicalDataUsageReportTimer=0",
    "NRBTS:actIntraMeNBMobility=false",
    "NRBTS:actInterMeNBMobility=false",
    "NRBTS:actMobilityRetryToSecondBestCell=false",
    "NRBTS:actMultiDrbNSA=false",
    "NRCELL:cellDepType=SA",
    "NRCELL:actDynUlDataSplitMode=false",
    "NRCELL:actSib1ForNsaCell=false",
    "delete:NRCELL/NRPLMNSET_NSA-1",

    # ULCG
    "NRCELL:actUlCgType2=true",
    "NRCELL:ulConfiguredGrantType2:maxGBRAndCgType2TrafficLimit=90",
    "NRCELL:ulConfiguredGrantType2:ulCgMaxNumUeUl=8",
    "NRCELL:ulConfiguredGrantType2:ulCgPrbStartOffset=0",
    "NRCELL-1:ulConfiguredGrantType2:ulCgMaxNumPrbs=128",
    "NRCELL-2:ulConfiguredGrantType2:ulCgMaxNumPrbs=96",
    "NRCELL-10:ulConfiguredGrantType2:ulCgMaxNumPrbs=52",
    "NRCELL-11:ulConfiguredGrantType2:ulCgMaxNumPrbs=52",
    "NRCELL-12:ulConfiguredGrantType2:ulCgMaxNumPrbs=52",
    "NRCELL-13:ulConfiguredGrantType2:ulCgMaxNumPrbs=52",
    "NRBTS/NRULCG_PROFILE-1:maxNumPrbs=52",
    "NRBTS/NRULCG_PROFILE-1:grantedPacketSize=250",
    "NRBTS/NRULCG_PROFILE-1:periodicity=ms20",
    "NRBTS/NRDRB-4:nrDrbUlCgDN=NRULCG_PROFILE-1",
]

Modify_InactivityTimer = [
    "NRBTS:drbRrcInactInactivityTimerSA=30",
    "NRBTS:drbInactivityTimerSA=30",
    "NRBTS:srbInactivityTimerSA=30",
]
