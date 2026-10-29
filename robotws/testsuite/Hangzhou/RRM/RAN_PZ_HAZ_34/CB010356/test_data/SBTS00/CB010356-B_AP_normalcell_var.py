PARAMS_IN_SCF = [
    # 10356 enabled
    "NRCELL-4:actHPPosMethodOptList=UL-TDOA",
    # nGRanAccessPointPosition mapping to subcell
    "NRCELL/NRPOSINFO-1:nGRanAccessPointPosition:confidence=100|altitude=0",
    "NRCELL/NRPOSINFO-1:nGRanAccessPointPosition:degreesOfLatitude=0|altitude=0",
    "NRCELL/NRPOSINFO-1:nGRanAccessPointPosition:degreesOfLongitude=0|altitude=0",
    "NRCELL/NRPOSINFO-1:nGRanAccessPointPosition:directionOfAltitude=Height|altitude=0",
    "NRCELL/NRPOSINFO-1:nGRanAccessPointPosition:latitudeSign=North|altitude=0",
    "NRCELL/NRPOSINFO-1:nGRanAccessPointPosition:orientationOfMajorAxis=0|altitude=0",
    "NRCELL/NRPOSINFO-1:nGRanAccessPointPosition:uncertaintyAltitude=0|altitude=0",
    "NRCELL/NRPOSINFO-1:nGRanAccessPointPosition:uncertaintySemiMajor=0|altitude=0",
    "NRCELL/NRPOSINFO-1:nGRanAccessPointPosition:uncertaintySemiMinor=0|altitude=0",
    # SRS setting
    "NRCELL:srsForPositioning:comb=comb2",
    "NRCELL:srsForPositioning:cSRS=0",
    "NRCELL:srsForPositioning:numberOfCS=4 cycle shifts",
    "NRCELL:srsForPositioning:srsUePeriodicity=slots40",
    # sFNInitialisationTime related param
    "NRCELL:timingAdvanceOffset=n25600",
    # 5GC000707_InterRAT
    "NRBTS:actInterRatHoSA=true",
    "NRCELL-1:measGapSelectionSA=favourUeThroughput",
    "NRHOIR-1:allowedMeasBandwidth=mbw50",
    "NRHOIR-1:b2MeashoEnabled=rsrpAndRsrq",
    "NRHOIR-1:b2Threshold1hoRsrp=35",
    "NRHOIR-1:b2Threshold1hoRsrpVoNr=45",
    "NRHOIR-1:b2Threshold1hoRsrq=50",
    "NRHOIR-1:b2Threshold1hoRsrqVoNr=55",
    "NRHOIR-1:earfcnValue=39750",
    "NRHOIR-1:eutraFreqQOffsetRange=0dB",
    "NRHOIR-1:eutraB2MeashoRsrp:b2HysteresishoRsrp=0|b2TimeToTriggerhoRsrpVoNr=ms512",
    "NRHOIR-1:eutraB2MeashoRsrp:b2HysteresishoRsrpVoNr=4|b2TimeToTriggerhoRsrpVoNr=ms512",
    "NRHOIR-1:eutraB2MeashoRsrp:b2Threshold2hoRsrp=18|b2TimeToTriggerhoRsrpVoNr=ms512",
    "NRHOIR-1:eutraB2MeashoRsrp:b2Threshold2hoRsrpVoNr=28|b2TimeToTriggerhoRsrpVoNr=ms512",
    "NRHOIR-1:eutraB2MeashoRsrp:b2TimeToTriggerhoRsrp=ms480|b2TimeToTriggerhoRsrpVoNr=ms512",
    "NRHOIR-1:eutraB2MeashoRsrq:b2HysteresishoRsrq=0|b2TimeToTriggerhoRsrqVoNr=ms512",
    "NRHOIR-1:eutraB2MeashoRsrq:b2HysteresishoRsrqVoNr=4|b2TimeToTriggerhoRsrqVoNr=ms512",
    "NRHOIR-1:eutraB2MeashoRsrq:b2Threshold2hoRsrq=2|b2TimeToTriggerhoRsrqVoNr=ms512",
    "NRHOIR-1:eutraB2MeashoRsrq:b2Threshold2hoRsrqVoNr=10|b2TimeToTriggerhoRsrqVoNr=ms512",
    "NRHOIR-1:eutraB2MeashoRsrq:b2TimeToTriggerhoRsrq=ms480|b2TimeToTriggerhoRsrqVoNr=ms512",
    "NRCELL-1:nrhoirDNList=MRBTS-1/NRBTS-1/NRHOIR-1",
    # NRADJECELL_SIMGNB5.1
    "NRADJECELL-1:eNodeBId=25",
    "NRADJECELL-1:ePSTrackingAreaCode=222",
    "NRADJECELL-1:earfcnValue=39750",
    "NRADJECELL-1:lcrId=1",
    "NRADJECELL-1:physCellId=12",
    "NRADJECELL-1:eUtraMultibandInfoList=41",
    "NRADJECELL-1:ecgiPlmn:mcc=311|mncLength=3",
    "NRADJECELL-1:ecgiPlmn:mnc=489|mncLength=3",
    "NRADJECELL-1:enbPlmn:mcc=311|mncLength=3",
    "NRADJECELL-1:enbPlmn:mnc=489|mncLength=3",
    # NRRELE_SIMGNB5
    "NRCELL-1/NRRELE-1:cellIndividualOffset=0dB",
    "NRCELL-1/NRRELE-1:eNodeBId=25",
    "NRCELL-1/NRRELE-1:lcrId=1",
    "NRCELL-1/NRRELE-1:ecgiPlmn:mcc=311|mncLength=3",
    " NRCELL-1/NRRELE-1:ecgiPlmn:mnc=489|mncLength=3",
    # 5GC000711
    "NRBTS:actInterRatHoFromEutraToSA=true",
    "NRBTS:nonContentRachAcFullConfigHo=true",
    "NRBTS:tNgRelocExecDeltL=5000",
    # CB007517
    "NRBTS:actHigherPrioFreqHo=SA",
    "NRCELL-1:a4PeriodicMeasControlSA:a4Fr1SupervisionTimer=4000",
    "NRCELL-1/NRHOIF-1:a4MeasHigherPrioFreqEnabled=rsrp",
    "NRCELL-1/NRHOIF-1:a4PriorityForHigherPrioFreqHo=2",
    "NRCELL-1/NRHOIF-1:a5MeasEnabled=rsrp",
    "NRCELL-1/NRHOIF-1:cellDepType=SA",
    "NRCELL-1/NRHOIF-1:freqBandIndicatorNR=77",
    "NRCELL-1/NRHOIF-1:ifhoSsbScs=30 KHz",
    "NRCELL-1/NRHOIF-1:ifhoSsbSmtcDuration=sf1",
    "NRCELL-1/NRHOIF-1:ifhoSsbSmtcPeriodicity=sf10",
    "NRCELL-1/NRHOIF-1:ssbFrequency=653856",
    "NRCELL-1/NRHOIF-1:a3MeasSsbRsrp:a3HysteresisSsbRsrp=0",
    "NRCELL-1/NRHOIF-1:a3MeasSsbRsrp:a3OffsetSsbRsrp=30",
    "NRCELL-1/NRHOIF-1:a3MeasSsbRsrp:a3TimeToTriggerSsbRsrp=ms64",
    "NRCELL-1/NRHOIF-1:a4MeasSsbRsrp:a4HysteresisSsbRsrp=0",
    "NRCELL-1/NRHOIF-1:a5MeasSsbRsrp:a5HysteresisSsbRsrp=0",
    "NRCELL-1/NRHOIF-1:a5MeasSsbRsrp:a5Threshold1SsbRsrp=30",
    "NRCELL-1/NRHOIF-1:a5MeasSsbRsrp:a5Threshold2SsbRsrp=40",
    "NRCELL-1/NRHOIF-1:a5MeasSsbRsrp:a5TimeToTriggerSsbRsrp=ms64",
    "NRCELL-10:a4PeriodicMeasControlSA:a4Fr1SupervisionTimer=4000",
    "NRCELL-2:administrativeState=Unlocked",
    "NRCELL-2:a4PeriodicMeasControlSA:a4Fr1SupervisionTimer=4000",
    "NRCELL-3:a4PeriodicMeasControlSA:a4Fr1SupervisionTimer=4000",
    "NRCELL-4:a4PeriodicMeasControlSA:a4Fr1SupervisionTimer=4000",
    "NRCELL-5:a4PeriodicMeasControlSA:a4Fr1SupervisionTimer=4000",
    "NRCELL-6:a4PeriodicMeasControlSA:a4Fr1SupervisionTimer=4000",
    "NRCELL-7:a4PeriodicMeasControlSA:a4Fr1SupervisionTimer=4000",
    "NRCELL-8:a4PeriodicMeasControlSA:a4Fr1SupervisionTimer=4000",
    "NRCELL-9:a4PeriodicMeasControlSA:a4Fr1SupervisionTimer=4000",
    # NRREL_FOR_A4_GNB2_NRCELL_3
    "NRCELL-1/NRREL-3:gNbId=1",
    "NRCELL-1/NRREL-3:lcrId=3",
    "NRCELL-1/NRREL-3:removeNotAllowed=true",
    "NRCELL-1/NRREL-3:gnbPlmn:mcc=311",
    "NRCELL-1/NRREL-3:gnbPlmn:mnc=489",
    "NRCELL-1/NRREL-3:gnbPlmn:mncLength=3",
    # CB008806      #intergnb HO
    "NRBTS-1:actIntraFreqHoSA=true",
    "NRBTS-1:actInterFreqHoSA=true",
    "MRBTS-1/NRBTS-1/NRPMRNL-1:miNrRelReportCu=15min",
    "NRBTS:actIntraNrNgHo=sourceAndTarget",
    "NRBTS-1:suppCnPartialAdNgHo=false",
    "NRBTS:tNgRelocExecDeltN=3000",
    "NRBTS:tNgRelocCancelN=2000",
    "NRBTS:tNgRelocOverallN=2000",
    "NRBTS:tNgRelocPrepN=2000",
    "NRBTS:timerXnDataFwdGuard=2000",
    "NRCELL:a1MeashoEnabledSA=rsrp",
    "NRCELL:a1MeashoSsbRsrpSA:a1HysteresishoSsbRsrpSA=20",
    "NRCELL:a1MeashoSsbRsrpSA:a1ThresholdhoSsbRsrpSA=80",
    "NRCELL:a1MeashoSsbRsrpSA:a1TimeToTriggerhoSsbRsrpSA=ms480",
    "NRCELL:a2MeashoEnabledSA=rsrp",
    "NRCELL:a2MeashoSsbRsrpSA:a2HysteresishoSsbRsrpSA=26",
    "NRCELL:a2MeashoSsbRsrpSA:a2ThresholdhoSsbRsrpSA=80",
    "NRCELL:a2MeashoSsbRsrpSA:a2TimeToTriggerhoSsbRsrpSA=ms40",
    "NRCELL:a3MeasEnabled=rsrp",
    "NRCELL:a3MeasSsbRsrp:a3HysteresisSsbRsrp=4",
    "NRCELL:a3MeasSsbRsrp:a3OffsetSsbRsrp=2",
    "NRCELL:a3MeasSsbRsrp:a3TimeToTriggerSsbRsrp=ms320",
    "NRCELL:absThreshSsbRsrpConsolidation=0",
    "NRCELL:measGapSelectionSA=favourUeThroughput",
    "NRCELL/NRHOIF-2:a3MeasEnabled=rsrp",
    "NRCELL/NRHOIF-2:a3MeasSsbRsrp:a3HysteresisSsbRsrp=1",
    "NRCELL/NRHOIF-2:a3MeasSsbRsrp:a3OffsetSsbRsrp=10",
    "NRCELL/NRHOIF-2:a3MeasSsbRsrp:a3TimeToTriggerSsbRsrp=ms80",
    "NRCELL/NRHOIF-2:cellDepType=SA",
    "NRCELL/NRHOIF-2:freqBandIndicatorNR=41",
    "NRCELL/NRHOIF-2:ifhoSsbScs=30 KHz",
    "NRCELL/NRHOIF-2:ifhoSsbSmtcDuration=sf1",
    "NRCELL/NRHOIF-2:ifhoSsbSmtcPeriodicity=sf10",
    "NRCELL/NRHOIF-2:numberOfTransmittedSsBlocks=1 beam",
    # point to gnbid=3, NRHOIF-2 is used for interrat HO
    "NRCELL/NRHOIF-2:ssbFrequency=513150",
    "NRCELL/NRHOIF-2:ssBurstSetPeriod",
    # NRREL_FOR_INTERGNB_HO_GNB3_NRCELL1
    # NRREL-1 point to gnb2.NRCELL2,use for inttragnb HO Based on A3
    "NRCELL/NRREL-2:cellIndividualSsbRsrpOffset=0dB",
    # NRREL-2 point to gnb3.NRCELL, use for intergnb ho
    "NRCELL/NRREL-2:cellIndividualSsbRsrqOffset=0dB",
    "NRCELL/NRREL-2:gNbId=35",
    "NRCELL/NRREL-2:gNbIdLength=22",
    "NRCELL/NRREL-2:lcrId=1",
    "NRCELL/NRREL-2:removeNotAllowed=false",
    "NRCELL/NRREL-2:nrDcAllowed=false",
    "NRCELL/NRREL-2:gnbPlmn:mcc=311",
    "NRCELL/NRREL-2:gnbPlmn:mnc=489",
    "NRCELL/NRREL-2:gnbPlmn:mncLength=3",
    "NRCELL/NRREL-2:handoverAllowedSA=XnHoNotAllowed",
    # NRADJGNB_GNB3.1
    "NRBTS/NRADJGNB-1:administrativeState=Unlocked",
    "NRBTS/NRADJGNB-1:gNbIdLength=22",
    "NRBTS/NRADJGNB-1:gNodeBId=35",
    "NRBTS/NRADJGNB-1:gNodeBIdCtrl=oamControlled",
    "NRBTS/NRADJGNB-1:weightForIgnbCaSelection=1",
    "NRBTS/NRADJGNB-1:gnbPlmn:mcc=311",
    "NRBTS/NRADJGNB-1:gnbPlmn:mnc=489",
    "NRBTS/NRADJGNB-1:gnbPlmn:mncLength=3",
    # NRADJNRCELL_GNB3.1
    "NRBTS/NRADJNRCELL-1:cellDepType=SA",
    "NRBTS/NRADJNRCELL-1:fiveGsTac=200",
    "NRBTS/NRADJNRCELL-1:freqBandIndicatorNR=41",
    "NRBTS/NRADJNRCELL-1:gNbId=35",
    "NRBTS/NRADJNRCELL-1:gNbIdLength=22",
    "NRBTS/NRADJNRCELL-1:lcrId=1",
    "NRBTS/NRADJNRCELL-1:nrarfcn=513234",
    "NRBTS/NRADJNRCELL-1:physCellId=381",
    "NRBTS/NRADJNRCELL-1:gnbPlmn:mcc=311",
    "NRBTS/NRADJNRCELL-1:gnbPlmn:mnc=489",
    "NRBTS/NRADJNRCELL-1:gnbPlmn:mncLength=3",
    "MRBTS-1/NRBTS-1/NRADJNRCELL-1:ssbFrequency=513150",
    # CB008225_enabled
    # paging related parameters
    "NRBTS:actRrcInactState=intra-gNB",
    "NRBTS:drbRrcInactInactivityTimerSA=3",
    "NRBTS:drbInactivityTimerSA=60",
    "NRBTS:srbInactivityTimerSA=3",
    "NRBTS:maxUeRrcInactTime=1",
    "NRBTS:rrcInactIMMSteeringEnabled=true",
    "NRBTS:rrcInactLocationReportEnabled=false",
    "NRBTS:t380=60min",
    "NRBTS:actPaging=true",
    "NRBTS:tRanPagingGuard=5",
    "NRBTS:ranPagingCycle=v32",
    "NRCELL:ranAC=0",
    "NRBTS:activityNotificationLevelSA=ue",
    "MRBTS-1/NRBTS-1/NRPMRNL-1:miNrRRCC=5min",
    "MRBTS-1/NRBTS-1/NRPMRNL-1:miNrPaging=5min",
    "MRBTS-1/NRBTS-1/NRPMRNL-1:miNrF1CD=5min",
    "NRBTS:act3gppBL23R1=true",
    "NRBTS:actIdleMMSteering=true",
    "NRCELL:idleMMSteeringAlgo=non CA aware",
    "NRCELL:idleMMSteeringPercentageOfUes=10",
    "NRCELL:idleMMSteeringWRREnabled=false",
    "NRBTS:rrcInactPreferredStateEnabled=false",
    "NRCELL:idleMMSteeringWRREnabledSec=Disabled",

    # Trace
    "NRBTS:actCellTraceReport=true",
    "NRBTS:actSubscriberTraceReport=true",
    "NRBTS:actPCMDReport=true",
    # TCE
    "MRBTS/MNL-1/TCEADM-1",
    "MRBTS/MNL-1/TCEADM-1/TCE-1:tceIdentifier=1",
    "MRBTS/MNL-1/TCEADM-1/TCE-1:tceIpAddress=10.0.1.1",
    "MRBTS/MNL-1/TCEADM-1/TCE-1:tcePortNumber=49150",
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
    "NRBTS/NRCTRLTS-1/NRMTRACECU-1:actPCMDReporting=true",
    "NRBTS/NRCTRLTS-1/NRMTRACECU-1:jobType=TraceOnly",
    # NRSTRACECU
    "NRBTS/NRCTRLTS-1/NRSTRACECU-1",
    "NRBTS/NRCTRLTS-1/NRSTRACECU-1:nrStraceCuId=1",
    "NRBTS/NRCTRLTS-1/NRSTRACECU-1:applyDefNrTceForAllSessions=true",
    "NRBTS/NRCTRLTS-1/NRSTRACECU-1:certTypeForTlsAuth=RSA",
    "NRBTS/NRCTRLTS-1/NRSTRACECU-1:defaultNrTceIdentifier=1",
    "NRBTS/NRCTRLTS-1/NRSTRACECU-1:nrTcePortNumber=49150",
    "NRBTS/NRCTRLTS-1/NRSTRACECU-1:tlsEnabled=false",
    # NRMTRACEDU
    "NRBTS/NRDU-1/NRCTRLTSDU-1",
    "NRBTS/NRDU-1/NRCTRLTSDU-1/NRMTRACEDU-1:actPCMDReporting=true",
    "NRBTS/NRDU-1/NRCTRLTSDU-1/NRMTRACEDU-1:jobType=TraceOnly",
    "NRBTS/NRDU-1/NRCTRLTSDU-1/NRMTRACEDU-1:nrTceIdentifier=1",
    "NRBTS/NRDU-1/NRCTRLTSDU-1/NRMTRACEDU-1:scope=allResources",
    "NRBTS/NRDU-1/NRCTRLTSDU-1/NRMTRACEDU-1:nrRanTraceReference:mcc=311",
    "NRBTS/NRDU-1/NRCTRLTSDU-1/NRMTRACEDU-1:nrRanTraceReference:mnc=489",
    "NRBTS/NRDU-1/NRCTRLTSDU-1/NRMTRACEDU-1:nrRanTraceReference:mncLength=3",
    "NRBTS/NRDU-1/NRCTRLTSDU-1/NRMTRACEDU-1:nrRanTraceReference:traceId=1",
    "NRBTS/NRDU-1/NRCTRLTSDU-1/NRMTRACEDU-1:tracePCMDSetting=all",
    # Overload
    "NRBTS:gnbOvlProtMode=classical",
    "NRBTS:cuOvlHa:ovlSaRrcRej=enabled",
    "NRBTS:duOvlHa:ovlSaRrcRej=true",
]
enable_gnbOvlProtMode = [
    "NRBTS:duOvlHa:delayRrcOvlCountermeasures=100",
    "NRBTS:drbRrcInactInactivityTimerSA=60",
    "NRBTS:srbInactivityTimerSA=600",
]

requested_item_temporarily_not_available = (
    "radioNetwork : requested-item-temporarily-not-available"
)

UE_Capa_Support_UAI_VONR = (
    "E1A00000074E5A031E00038520001E09306400043C2C006201A0130180603806546C28D6080A1A0259651311000F5"
    "B0404041C3BC70E418700040C9E3EAE0009E00380027800546C4CD6080A1A0259651311000F5B0404041C3BC70E41"
    "8700040C9E3EAE0009E00380027800546C4DD6080A1A0259651311000F5B0404041C3BC70E418700040C9E3EAE000"
    "9E00380027800546C4ED6080A1A0259651311000F5B0404041C3BC70E418700040C9E3EAA00000A00000021071300"
    "0000000809A3600003804044F61F00060005038280381804C00E000D07C0000000000001CA9A0002000012CB2A006"
    "95550F0007000B00000004008011AB130001020304050607080B101112131921252627284A44A9440000840"
)

longer_srbinactvity_drbrrcinactivty_timer = [
    "NRBTS:drbRrcInactInactivityTimerSA=5",
    "NRBTS:srbInactivityTimerSA=30",
]

rollback_srbinactvity_drbrrcinactivty_timer = [
    "NRBTS:drbRrcInactInactivityTimerSA=3",
    "NRBTS:srbInactivityTimerSA=3",
]

Resume_regexp_with_mo_Data = [
    "rrcResumeRequest1",
    "resumeCause mo-Data",
    "rrcResume",
    "rrcResumeComplete",
]

ResumeReq1_regexp_with_hpa = [
    "rrcResumeRequest1",
    "resumeCause highPriorityAccess",
    "rrcResume",
    "rrcResumeComplete",
]

ResumeReq1_regexp_with_mt_Access = [
    "rrcResumeRequest1",
    "resumeCause mt-Access",
    "rrcResume",
    "rrcResumeComplete",
]

HPA_ue_list = [
    "1",
    "2",
]

INACTIVE_check_UE2 = [
    "SuspendConfig",
    "fullI_RNTI",
    "shortI_RNTI",
    "nextHopChainingCount",
    "NR_RRC_INACTIVE",
    "UE2: Is INACTIVE",
]

srbInactivityTimerSA_30 = [
    "NRBTS:srbInactivityTimerSA=30",
]

srbInactivityTimerSA_600 = [
    "NRBTS:drbRrcInactInactivityTimerSA=7200",
    "NRBTS:drbInactivityTimerSA=7200",
    "NRBTS:srbInactivityTimerSA=600",
]


if __name__ == "__main__":
    print("hello")
