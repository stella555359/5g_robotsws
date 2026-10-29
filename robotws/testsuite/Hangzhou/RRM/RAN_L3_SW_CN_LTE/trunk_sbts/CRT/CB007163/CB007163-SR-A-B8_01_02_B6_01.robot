*** Settings ***
Suite Setup       Common Suite Setup And Setup CUS Env
Suite Teardown    Common Suite Teardown And Restore BTS Configuration Parameters
Test Setup        Common Test Setup And Start To Capture Logs
Test Teardown     Common Test Teardown And Stop Capture Logs
Force Tags        QCD_MN_RAN    QCP_RAN_ET    SBTS00    RAN_4G    RAN_4G_TDD    CRT    CLOUD_R4LAPO_CUS    team-DevHZ5_SG1
...               owner-feng.2.chen    release-SBTS22R3
Resource          ../../../resources/DevHZ5_resource.robot

*** Variables ***
@{PARAMS_IN_VENDOR}
...    LNBTS:reportTimerEndcA5=5000ms
...    LNBTS:reportTimerIFSBA4=3000ms
${PM_SPEED_UP_FLAG}    ${True}
@{PARAMS_IN_SCF}
...    @{x2link}
...    @{LTE4088}
...    @{LTE4193}
...    @{NRDCDPR_CONFIG}
...    @{add_moPrMapList}
...    @{HO_para}
...    @{CB007163}
...    @{PCMD_Setup}
...    @{cell_config}

${f1}    1600
${f2}    38020
${f3}    1700
@{cell_config}
...    LNCEL-1/LNCEL_TDD-0:earfcn=38000
...    LNCEL-2/LNCEL_TDD-0:earfcn=38020
...    LNCEL-3/LNCEL_TDD-0:earfcn=38000
...    MRBTS-1/EQM-1/HWTOP-1/CABLINK-3:linkSpeed=Auto
...    MRBTS-1/EQM-1/HWTOP-1/CABLINK-2:linkSpeed=Auto
...    MRBTS-1/EQM-1/HWTOP-1/CABLINK-1:linkSpeed=Auto

@{CB007163}
...    LNBTS:actEndcHo=enabled
...    LNBTS:actUeCapEndcHo=false
...    LNCEL:actEndcHoPrefLay=false
...    LNCEL-1:iFEndcHoRetryTimer=10
...    LNCEL-2:iFEndcHoRetryTimer=10
...    LNCEL-3:iFEndcHoRetryTimer=10
...    LNBTS-1:blockEndcHoRetryAtHoFromTrg=no blocking
...    LNBTS/MODPR-0:configUeCapEndcHoRetry=noRetries
...    LNBTS/MOPR-1:configUeCapEndcHoRetry=noRetries
...    LNBTS/MOPR-2:configUeCapEndcHoRetry=noRetries
...    LNBTS/MOPR-3:configUeCapEndcHoRetry=noRetries
...    LNBTS/CAGENB-0/CAIMLBP-0:pcellConfig:earfcnDL=1700
...    LNBTS/CAGENB-0/CAIMLBP-0/IMLBNR-0:nrcellConfigL:b1NrRequired=false
...    LNBTS/CAGENB-0/CAIMLBP-0/IMLBNR-0:nrcellConfigL:band=257
...    LNBTS/CAGENB-0/CAIMLBP-1:pcellConfig:earfcnDL=38020
...    LNBTS/CAGENB-0/CAIMLBP-1/IMLBNR-0:nrcellConfigL:b1NrRequired=false
...    LNBTS/CAGENB-0/CAIMLBP-1/IMLBNR-0:nrcellConfigL:band=7
...    LNBTS/CAGENB-0/CAIMLBP-3:pcellConfig:earfcnDL=1600
...    LNBTS/CAGENB-0/CAIMLBP-3/IMLBNR-0:nrcellConfigL:b1NrRequired=false
...    LNBTS/CAGENB-0/CAIMLBP-3/IMLBNR-0:nrcellConfigL:band=8
...    LNCEL/LNHOIF-1:thresholdRsrpEndcFilt=-98
...    LNCEL/LNHOIF-1:eutraCarrierInfo=1600
...    LNCEL/LNHOIF-1:thresholdRsrqEndcFilt=-120
...    LNCEL/LNHOIF-2:thresholdRsrpEndcFilt=-98
...    LNCEL-1/LNHOIF-2:eutraCarrierInfo=38020
...    LNCEL-1/LNHOIF-2:thresholdRsrqEndcFilt=-120
...    LNCEL-3/LNHOIF-2:eutraCarrierInfo=38020
...    LNCEL-3/LNHOIF-2:thresholdRsrqEndcFilt=-120
...    LNCEL-1/LNHOIF-3:thresholdRsrpEndcFilt=-98
...    LNCEL-1/LNHOIF-3:eutraCarrierInfo=1700
...    LNCEL-1/LNHOIF-3:thresholdRsrqEndcFilt=-120
...    @{freqLayEndcHoList_for_MOPR}
...    @{freqLayEndcHoList_for_MODPR}

@{freqLayEndcHoList_for_MODPR}
...    LNBTS/MODPR-0:freqLayEndcHoList:preference=true|freqLayer=${f1}
...    LNBTS/MODPR-0:freqLayEndcHoList:preference=true|freqLayer=${f2}
...    LNBTS/MODPR-0:freqLayEndcHoList:preference=false|freqLayer=${f3}

@{freqLayEndcHoList_for_MOPR}
...    LNBTS/MOPR-1:freqLayEndcHoList:preference=true|freqLayer=${f1}
...    LNBTS/MOPR-1:freqLayEndcHoList:preference=true|freqLayer=${f2}
...    LNBTS/MOPR-1:freqLayEndcHoList:preference=false|freqLayer=${f3}

@{HO_para}
...    LNBTS-1:actIfHo=enabled
...    LNBTS-1/LNADJ-1:adjEnbId=42
...    LNBTS-1/LNADJ-1:cPlaneIpAddr=10.0.1.3
...    LNCEL-1/LNREL-1:removeAllowed=false
...    LNCEL-1/LNREL-1:ecgiPlmnId:mncLength=2
...    LNCEL-1/LNREL-1:ecgiPlmnId:mcc=262
...    LNCEL-1/LNREL-1:ecgiPlmnId:mnc=3
...    LNCEL-1/LNREL-1:ecgiAdjEnbId=42
...    LNCEL-1/LNREL-1:ecgiLcrId=1
...    LNCEL-1/LNHOIF-1:eutraCarrierInfo=1500
...    LNBTS/MODPR-0:freqLayListLte=1500,1400,1700,1600,38000,900
...    LNBTS/MOPR-1:freqLayListLte=1500,1400,1700,1600,38000,900

@{x2link}
...    LNBTS/LNADJGNB-1:adjGnbId=7
...    LNBTS/LNADJGNB-1:adjGnbIdLength=22
...    LNBTS/LNADJGNB-1:administrativeState=unlocked
...    LNBTS/LNADJGNB-1:cPlaneIpAddr=10.0.1.11
...    LNCEL/LNRELGNBCELL-1:gnbIdLength=22
...    LNCEL/LNRELGNBCELL-1:lteNrDualConnectAllowed=allowed
...    LNCEL/LNRELGNBCELL-1:nrCellId=115970
...    LNCEL/LNRELGNBCELL-1:nrCgiPlmnId:mcc=262
...    LNCEL/LNRELGNBCELL-1:nrCgiPlmnId:mnc=3
...    LNCEL/LNRELGNBCELL-1:nrCgiPlmnId:mncLength=2

@{NRcell_unava}
...    LNCEL-1/LNRELGNBCELL-1:nrStatus=unavailable
@{LTE4088}
...    LNBTS:actTransmittedBelowGap=false
...    LNBTS:actLteNrDualConnectivity=false
...    LNBTS:tS1eRABModInd=2000
...    LNBTS:nrRestrictionOverride=disabled
...    LNCEL:defaultLnRelGnbCellId=1
...    LNBTS:actEndcSpidFwd=false
...    LNBTS:endcSchedWeightBoostDl=2
...    LNBTS:endcSchedWeightBoostUl=2
...    LNCEL:eTputInitMcs=20
...    LNCEL:eTputFilterConfig=51
...    LNBTS:tLteNrDualConnectPrep=5000
...    LNBTS:qciTab8:lteNrDualConnectSupport=EN-DC|nrPdcpProfIdx=1001

${nrF1}    531040
${nrF2}    524032
@{LTE4193}
...    LNBTS/NRDCDPR-0:dynTriggerLteNrDcConfList:lcrId=-1
...    LNBTS/NRDCDPR-0:dynTriggerLteNrDcConfList:method=coverageBased
...    LNBTS/NRDCDPR-0:dlPathlossChg=3 db
...    LNBTS/NRDCDPR-0:enDCpMaxEUTRApowerOffset=0
...    LNBTS/NRDCDPR-0:enDCpMaxNRpowerOffset=0
...    LNBTS/NRDCDPR-0:tPeriodicPhr=10sf
...    LNBTS/NRDCDPR-0:tProhibitPhr=0sf
...    LNBTS:actDynTrigLteNrDualConnectivity=false
...    LNCEL/LNCEL_TDD-0:actAutoPucchAlloc=true
...    LNCEL/LNCEL_TDD-0/APUCCH_TDD-0:aPucchAddAUeRrHo=10    
...    LNCEL/LNCEL_TDD-0/APUCCH_TDD-0:aPucchAddAUeTcHo=15
...    LNCEL/LNCEL_TDD-0/APUCCH_TDD-0:aPucchMinNumEmergencySessions=10    
...    LNCEL/LNCEL_TDD-0/APUCCH_TDD-0:aPucchMinNumRrc=10
...    LNCEL/LNCEL_TDD-0/APUCCH_TDD-0:aPucchMinNumRrcNoDrb=5
...    LNCEL/LNCEL_TDD-0/APUCCH_TDD-0:aPucchSrPeriodUpperLimit=40
...    LNCEL/LNCEL_TDD-0/APUCCH_TDD-0:actLbPucchReg=true
...    LNCEL/LNCEL_TDD-0/APUCCH_TDD-0:lbPucchRPrId=1
...    LNCEL/LNCEL_TDD-0/APUCCH_TDD-0:selectPrachRegion=None
...    LNBTS/LBPUCCHRPR-1:countdownPucchCompr=60min
...    LNBTS/LBPUCCHRPR-1:countdownPucchExp=1min
...    LNBTS/LBPUCCHRPR-1:rrcConnectedLowerThresh=10
...    LNBTS/LBPUCCHRPR-1:rrcConnectedUpperThresh=80

@{NRDCDPR_CONFIG}
...    LNBTS/NRMEASDPR-0:nrQuantityConfig:filterCoefficientRsrp=fc4|quantityConfigId=0
...    LNBTS/NRMEASDPR-0:nrQuantityConfig:filterCoefficientRsrq=fc4|quantityConfigId=0
...    LNBTS/NRMEASDPR-0:nrQuantityConfig:filterCoefficientRsrp=fc4|quantityConfigId=1
...    LNBTS/NRMEASDPR-0:nrQuantityConfig:filterCoefficientRsrq=fc4|quantityConfigId=1
...    LNBTS/NRDCDPR-0:dlPathlossChg=3 db
...    LNBTS/NRDCDPR-0:tPeriodicPhr=1000sf
...    LNBTS/NRDCDPR-0:tProhibitPhr=1000sf
...    LNBTS/NRDCDPR-0:dynTriggerLteNrDcConfList:lcrId=-1
...    LNBTS/NRDCDPR-0/ENDCDMEASCONF-1:b1ThresholdNrRsrp=90
...    LNBTS/NRDCDPR-0/ENDCDMEASCONF-1:b1TimeToTriggerRsrp=256ms
...    LNBTS/NRDCDPR-0/ENDCDMEASCONF-1:b1TimeToTriggerRsrq=256ms
...    LNBTS/NRDCDPR-0/ENDCDMEASCONF-1:b1TriggerQuantity=RSRP
...    LNBTS/NRDCDPR-0/ENDCDMEASCONF-1:carrierFreqNrCell=${nrF1}
...    LNBTS/NRDCDPR-0/ENDCDMEASCONF-1:freqBandIndicatorNrL:freqBandIndicatorNr=7
...    LNBTS/NRDCDPR-0/ENDCDMEASCONF-1:hysB1ThresholdRsrp=4
...    LNBTS/NRDCDPR-0/ENDCDMEASCONF-1:hysB1ThresholdRsrq=4
...    LNBTS/NRDCDPR-0/ENDCDMEASCONF-1:nrCarPrio=3
...    LNBTS/NRDCDPR-0/ENDCDMEASCONF-1:ssbDuration=sf1
...    LNBTS/NRDCDPR-0/ENDCDMEASCONF-1:ssbOffset=0
...    LNBTS/NRDCDPR-0/ENDCDMEASCONF-1:ssbPeriodicity=sf5-r15
...    LNBTS/NRDCDPR-0/ENDCDMEASCONF-1:ssbSubcarrierSpacing=15kHz
...    LNBTS/NRDCDPR-0/ENDCDMEASCONF-1:quantityConfigId=1
...    LNBTS/NRDCDPR-0/ENDCDMEASCONF-2:b1ThresholdNrRsrp=90
...    LNBTS/NRDCDPR-0/ENDCDMEASCONF-2:b1TimeToTriggerRsrp=256ms
...    LNBTS/NRDCDPR-0/ENDCDMEASCONF-2:b1TimeToTriggerRsrq=256ms
...    LNBTS/NRDCDPR-0/ENDCDMEASCONF-2:b1TriggerQuantity=RSRP
...    LNBTS/NRDCDPR-0/ENDCDMEASCONF-2:carrierFreqNrCell=${nrF2}
...    LNBTS/NRDCDPR-0/ENDCDMEASCONF-2:freqBandIndicatorNrL:freqBandIndicatorNr=7
...    LNBTS/NRDCDPR-0/ENDCDMEASCONF-2:hysB1ThresholdRsrp=4
...    LNBTS/NRDCDPR-0/ENDCDMEASCONF-2:hysB1ThresholdRsrq=4
...    LNBTS/NRDCDPR-0/ENDCDMEASCONF-2:nrCarPrio=6
...    LNBTS/NRDCDPR-0/ENDCDMEASCONF-2:ssbDuration=sf1
...    LNBTS/NRDCDPR-0/ENDCDMEASCONF-2:ssbOffset=0
...    LNBTS/NRDCDPR-0/ENDCDMEASCONF-2:ssbPeriodicity=sf5-r15
...    LNBTS/NRDCDPR-0/ENDCDMEASCONF-2:ssbSubcarrierSpacing=15kHz
...    LNBTS/NRDCDPR-0/ENDCDMEASCONF-2:quantityConfigId=1

@{PCMD_Setup}
...    LNBTS:actPCMDReport=true
...    LNBTS/CTRLTS-1:extTraceReporting:extCellTraceRep=true
...    LNBTS/CTRLTS-1/MTRACE-1:actPCMDReporting=true
...    LNBTS/CTRLTS-1/MTRACE-1:jobType=TraceOnly
...    LNBTS/CTRLTS-1/MTRACE-1:tceIpAddress=10.0.1.1
...    LNBTS/CTRLTS-1/MTRACE-1:tceCellTracePortNum=49150
...    LNBTS/CTRLTS-1/MTRACE-1:lcrId=1
...    LNBTS/CTRLTS-1/MTRACE-1:traceRrcSetting=None
...    LNBTS/CTRLTS-1/MTRACE-1:traceS1Setting=None
...    LNBTS/CTRLTS-1/MTRACE-1:traceX2Setting=None
...    LNBTS/CTRLTS-1/MTRACE-1:actUeThroughputMR=false
...    LNBTS/CTRLTS-1/MTRACE-1:cellVendorSpecTracing:cellTaTracing=false
@{add_moPrMapList}
...    LNBTS-1:actSelMobPrf=true
...    LNBTS-1/MODPR-0:autoAdapt=false
...    LNBTS-1:moProfileSelect=spid
...    LNCEL-1:moPrMappingList:spid=2|moPrId=1
...    LNCEL-1:moPrMappingList:spidLast=100|moPrId=1
...    LNCEL-1:moPrMappingList:mcc=262|moPrId=1
...    LNCEL-1:moPrMappingList:mnc=3|moPrId=1
...    LNCEL-1:moPrMappingList:mncLength=2|moPrId=1

${ue_nr_capabilities}    0000000001010040000060000038000400040160401C06000000
${ue_eutra_nr_capabilities}    SEPARATOR=
...    010810036040080819280701800000006C08010102020E0380000000D81003060061401D0000000001B0100402080438500000000018000
...    4020001008000402020040080
${ue_eutra_capabilities}    SEPARATOR=
...    DE1809D0008206102860E2048A163069022489942A58B983268D9D4AB5F9D3A00000001D00000000E800000007400000003A00000001D00
...    000000E800000007400000003A00000001D00000000E800000007400000003A00000001D00000000E800000007400000003A00000001D000
...    00000E800000007400000003A00000001D00000000E800000007400000003A00000001D00000000E800000007400000003A00000001D000
...    00001BFBFFED800801C364000000017BA000000080952A0E2740400003840000210002C20000108008400010C0002200004500008C00011
...    C0002400004900009400012C0002600004D0000A0000144000290000530000A80001540002B0000570000B00001640002D00005B0000BA0
...    001780003680007F001D3A00000001D00000000E800000007400000003A00000001D00000000E800000007400000003A00000001D0000000
...    0E800000007400000003A00000001D00000000E800000007400000003A00000001D00000000E800000007400000003A00000001D00000000
...    E800000007400000003A00000001D00000000E800000007400000003A00000001D00000000A080000079D000000000000000000000000000
...    000000000000000000000000000000001011C42129A061CFFFFFFFFFFFFFFFA020A8001802297000020000104B1A0180C03A0013BC000001
...    80000009000021800C020180740000

${ue_eutra_capabilities_with_gap}    SEPARATOR=
...    DE1809D0008206102860E2048A163069022489942A58B983268D9D4AB5F9D3A00000001D00000000E800000087400000003A00000001D00
...    000000E800000007400000003A00000001D00000000E800000007400000003A00000001D00000000E800000007400000003A00000001D000
...    00000E800000007400000003A00000001D00000000E800000007400000003A00000001D00000000E800000007400000003A00000001D000
...    00001BFBFFED800801C364000000017BA000000080952A0E2740400003840000210002C20000108008400010C0002200004500008C00011
...    C0002400004900009400012C0002600004D0000A0000144000290000530000A80001540002B0000570000B00001640002D00005B0000BA0
...    001780003680007F001D3A00000001D00000000E800000007400000003A00000001D00000000E800000007400000003A00000001D0000000
...    0E800000007400000003A00000001D00000000E800000007400000003A00000001D00000000E800000007400000003A00000001D00000000E
...    800000007400000003A00000001D00000000E800000007400000003A00000001D00000000A080000079D00000000000000000000000000000
...    0000000000000000000000000000001011C42129A061CFFFFFFFFFFFFFFFA020A8001802297000020000104B1A0180C03A0013BC000001800
...    00009000021800C020180740000
@{SharedPlmnList}    262:03
@{precondition_for_case1}
...    LNBTS:actDynTrigLteNrDualConnectivity=false    #LTE4193 enabled
...    LNBTS:actLteNrDualConnectivity=true    #LTE4088 enabled
...    LNBTS:actEndcHo=enabled    #(LTE5150)
...    LNBTS:actUeCapEndcHo=false    #(CB006607)
...    LNCEL:actEndcHoPrefLay=true    #(CB007163)
...    LNBTS/MODPR-0:configUeCapEndcHoRetry=noRetries
...    LNBTS/MOPR-1:configUeCapEndcHoRetry=noRetries
...    @{freqLayEndcHoList_for_MODPR}
...    @{freqLayEndcHoList_for_MOPR}

@{disable_7163}
...    LNCEL:actEndcHoPrefLay=false
...    LNBTS:actLteNrDualConnectivity=false

@{precondition_for_case2}
...    LNBTS:actDynTrigLteNrDualConnectivity=false    #LTE4193 enabled
...    LNBTS:actLteNrDualConnectivity=true    #LTE4088 enabled
...    LNBTS:actEndcHo=enabled    #(LTE5150)
...    LNBTS:actUeCapEndcHo=true    #(CB006607)
...    LNCEL:actEndcHoPrefLay=true    #(CB007163)
...    LNBTS/MODPR-0:configUeCapEndcHoRetry=priorityAboveLoadBasedHo
...    LNBTS/MOPR-1:configUeCapEndcHoRetry=priorityAboveLoadBasedHo
...    @{freqLayEndcHoList_for_MODPR}
...    @{freqLayEndcHoList_for_MOPR}

@{precondition_for_caseB6}
...    LNBTS:actDynTrigLteNrDualConnectivity=true    #LTE4193 enabled
...    LNBTS:actLteNrDualConnectivity=true    #LTE4088 enabled
...    LNBTS:actEndcHo=enabled    #(LTE5150)
...    LNBTS:actUeCapEndcHo=true    #(CB006607)
...    LNCEL:actEndcHoPrefLay=true    #(CB007163)
...    LNBTS/MODPR-0:configUeCapEndcHoRetry=priorityAboveLoadBasedHo
...    LNBTS/MOPR-1:configUeCapEndcHoRetry=priorityAboveLoadBasedHo
...    LNBTS:actMeasGapCoordEnDc=eNB initiated    #LTE4981 enabled
...    LNBTS:actMeasGapIfEnDc=true
...    LNCEL/LNCEL_TDD-0:measGapPattern=gap0
...    LNBTS:actHoWoSnChg=intraEnbAndX2HoEnabled
...    LNBTS/NRMEASDPR-0:measGapEnabledNRMeas=Disable
...    @{freqLayEndcHoList_for_MODPR}
...    @{freqLayEndcHoList_for_MOPR}

${tceport}    49150
${ENDC_HO_Preparation}    LNCEL-1:M8080C53
${ENDC_HO_Execution}    LNCEL-1:M8080C54
${ENDC_HO_successes}    LNCEL-1:M8080C55
${prefer_ENDC_HO_successes}    LNCEL-1:M8080C155
${prefer_ENDC_HO_Execution}    LNCEL-1:M8080C156

@{PM_pre3_exc3_suc3_preExe3_preSuc3}
...    ${ENDC_HO_Preparation}=3
...    ${ENDC_HO_Execution}=3
...    ${ENDC_HO_successes}=3
...    ${prefer_ENDC_HO_Execution}=3
...    ${prefer_ENDC_HO_successes}=3
@{PM_pre3_exc3_suc3_preExe0_preSuc0}
...    ${ENDC_HO_Preparation}=3
...    ${ENDC_HO_Execution}=3
...    ${ENDC_HO_successes}=3
...    ${prefer_ENDC_HO_Execution}=0
...    ${prefer_ENDC_HO_successes}=0
${ENDC_A5_activate}    eventA5 contains (a5-Threshold1 contains (threshold-RSRP eq 97))
${HO_to_1600}    mobilityControlInfo contains (targetPhysCellId eq 9 and dl-CarrierFreq eq 1600)
${HO_to_38020}    mobilityControlInfo contains (targetPhysCellId eq 2 and dl-CarrierFreq eq 38020)
${ENDC_a5_retry}    measIdToAddModList contains (measId eq 3,measId eq 5)
${ENDC_a5_remove}    measIdToRemoveList contains (3,5)
${endcA5activateAndGapConfig}
...    measIdToAddModList contains (
...    measId eq 3,
...    measId eq 5) and
...    gp0 eq 29 and
...    s-Measure eq 0
${endcA5deactivateAndGapRelease}
...    measIdToRemoveList contains (
...    3,
...    5) and
...    s-Measure eq 90 and
...    measGapConfig contains (release is present)

*** Test Cases ***
CB007163_A-B8_ET_01_01_counter and PCMD check for EN-DC HO to preferred layer when CB006607 disabled
    [Documentation]
    ...    precondition: f1=1600 (band3,FDD), f2=38020 (band38, Tdd), f3=1700(band3, FDD)
    ...    LNBTS:actEndcHo=enabled (LTE5150)
    ...    LNBTS:actUeCapEndcHo=false (CB006607)
    ...    LNCEL-1:actEndcHoPrefLay=true (CB007163 feature flag)
    ...    step1: UE1 ICS to cell1, A5 is activated for eNB-1 cell2, send A5 report, perform intra-eNB ENDC HO
    ...    step2: UE2 HO to cell1, A5 is activated for enb42 cell1, send A5 report, perform inter-eNB X2 ENDC HO
    ...    step3: UE3 reestablish to cell1, A5 is activated for enb42 cell1, send A5 report, perform inter-eNB S1 ENDC HO
    ...    step4: M8080C53=3 M8080C54=3 M8080C55=3 M8080C156=3 M8080C155=3 PCMD include ueMeasTraceRecord info
    ...    deleta commission: LNCEL-1:actEndcHoPrefLay=false (CB007163 feature flag)
    ...    step5: UE4 ICS to cell1, A5 is activated for eNB-1 cell2, send A5 report, perform intra-eNB ENDC HO
    ...    step6: UE5 HO to cell1, A5 is activated for enb42 cell1, send A5 report, perform inter-eNB X2 ENDC HO
    ...    step7: UE6 reestablish to cell1, A5 is activated for enb42 cell1, send A5 report, perform inter-eNB S1 ENDC HO
    ...    step8: M8080C53=3 M8080C54=3 M8080C55=3 M8080C156=0 M8080C155=0
    [Tags]
    [Setup]    Local Test Setup For PCMD Precondition
    OnlineParamChanges and clear counter Files    ${precondition_for_case1}
    UE enter cell via ICS and perform ENDC intra enb HO    ue_id=1    meas_id_blacklist=2,3
    UE enter cell via HO and perform ENDC X2 HO    ue_id=2
    UE enter cell via reestablish and perform ENDC S1 HO    ue_id=3
    Check Counters and PCMD messages    ${PM_pre3_exc3_suc3_preExe3_preSuc3}    ${CURDIR}/A2A_01/a2a_PCMD.ini
    OnlineParamChanges and clear counter Files    ${disable_7163}
    UE enter cell via ICS and perform ENDC intra enb HO    ue_id=4    meas_id_blacklist=2,3
    UE enter cell via HO and perform ENDC X2 HO    ue_id=5
    UE enter cell via reestablish and perform ENDC S1 HO    ue_id=6
    Check Counters    ${PM_pre3_exc3_suc3_preExe0_preSuc0}
    [Teardown]    Local Test Teardown For Each Postcondition

CB007163_A-B8_ET_02_01_counter and PCMD check for EN-DC HO to preferred layer when CB006607 enabled
    [Documentation]
    ...    precondition: f1=1600 (band3,FDD), f2=38020 (band38, Tdd), f3=1700(band3, FDD)
    ...    LNBTS:actEndcHo=enabled (LTE5150)
    ...    LNBTS:actUeCapEndcHo=true (CB006607)
    ...    LNCEL-1:actEndcHoPrefLay=true (CB007163 feature flag)
    ...    step1: UE1 ICS to cell1, A5 is activated for eNB-1 cell2, send A5 report, perform intra-eNB ENDC HO
    ...    step2: UE2 HO to cell1, A5 is activated for enb42 cell1, send A5 report, perform inter-eNB X2 ENDC HO
    ...    step3: UE3 reestablish to cell1, A5 is activated for enb42 cell1, send A5 report, perform inter-eNB S1 ENDC HO
    ...    step4: M8080C53=3 M8080C54=3 M8080C55=3 M8080C156=3 M8080C155=3 PCMD include ueMeasTraceRecord info
    ...    delete gNB cell to make ENDC function disable
    ...    step5: UE4 ICS to cell1, A5 is activated for eNB-1 cell2, send A5 report, perform intra-eNB ENDC HO
    ...    step6: UE5 HO to cell1, A5 is activated for enb42 cell1, send A5 report, perform inter-eNB X2 ENDC HO
    ...    step7: UE6 reestablish to cell1, A5 is activated for enb42 cell1, send A5 report, perform inter-eNB S1 ENDC HO
    ...    step8: M8080C53=3 M8080C54=3 M8080C55=3 M8080C156=0 M8080C155=0
   [Tags]
    [Setup]    Local Test Setup For PCMD Precondition
    OnlineParamChanges and clear counter Files    ${precondition_for_case2}
    UE enter cell via ICS and perform ENDC intra enb HO    ue_id=1    meas_id_blacklist=2,3
    UE enter cell via HO and perform ENDC X2 HO    ue_id=2
    UE enter cell via reestablish and perform ENDC S1 HO    ue_id=3
    Check Counters and PCMD messages    ${PM_pre3_exc3_suc3_preExe3_preSuc3}    ${CURDIR}/A2A_01/a2a_PCMD.ini
    Delete gnb_cell and Clear Counter Files
    UE enter cell via ICS and perform ENDC intra enb HO    ue_id=4    meas_id_blacklist=2,3
    UE enter cell via HO and perform ENDC X2 HO    ue_id=5
    UE enter cell via reestablish and perform ENDC S1 HO    ue_id=6
    Check Counters    ${PM_pre3_exc3_suc3_preExe0_preSuc0}
    [Teardown]    Local Test Teardown For Each Postcondition2

CB007163_A-B6_ET_01_01_measurement gap coordination with gNB upon incoming Intra-eNB HO without takeback
    [Documentation]
    ...    precondition: f1=1600 (band3,FDD), f2=38020 (band38, Tdd), f3=1700(band3, FDD)
    ...    LNBTS:actEndcHo=enabled (LTE5150)
    ...    LNBTS:actUeCapEndcHo=true (CB006607)
    ...    LNCEL-1:actEndcHoPrefLay=true (CB007163 feature flag)
    ...    step1: UE25 no need gap, ICS to cell1, ENDC created, A5 retry
    ...    step2: UE25 intra-eNB HO to cell3, ENDC keep, A5 retry with gap
    ...    step3: UE26 need gap, ICS to cell1, ENDC created, A5 retry
    ...    step4: UE26 intra-eNB HO to cell3, ENDC keep, A5 retry with gap
    [Tags]
    OnlineParamChanges and clear counter Files    ${precondition_for_caseB6}
    Attach UE and setup ENDC    ue_id=25
    Perform Intra HO and detach UE    ue_id=25
    Attach UE with Gap and setup ENDC    ue_id=26
    Perform Intra HO and detach UE    ue_id=26

*** Keywords ***
Common Suite Setup And Setup CUS Env
    Common Suite Setup
    Setup CUS Env    tl_type=3CELLs
    execute egate command    trace_sim on mme=1 protocol=s1
    Set ue parameters before attach
    execute egate command    ue_mme_param id=1-10 spid=20
	execute egate command    enb_timer T_SN_STATUS_TRANSFER=5000ms
    execute egate command    enb_timer T_DC_Overall=5000ms
    Create Alias

Create Alias
    FOR    ${ue_id}    IN RANGE    1    27
        Create UE Alias    UE_${ue_id}    ue_id=${ue_id}    id_type=cus
    END
    Create Enb Alias    ENB_1    enb_id=1    id_type=wts
    Create Enb Alias    ENB_2    enb_id=2    id_type=wts
    Create Enb Alias    GNB_7    enb_id=7    id_type=wts
    Create MME Alias    alias=MME_1    mme_id=1    id_type=wts

Modify Yaml
    ${GNB7_CELL1}    catenate    - {id: 71, technology: nr , tac: 33, pci: '0:1', nrci: '0x0000501', nr_arfcn: '507000:531000'}
    ${GNB7_CELL2}    catenate    - {id: 72, technology: nr , tac: 33, pci: '0:2', nrci: '0x0000502', nr_arfcn: '500000:524000'}
    Add Yaml    BASE_STATIONS
    ...    - id: 7
    ...      gnb_id: '0x00007'
    ...      type: simulated
    ...      plmn: '262:03'
    ...      s1u: 10.0.1.11
    ...      x2_peers: none
    ...      cells:
    ...        ${GNB7_CELL1}
    ...        ${GNB7_CELL2}
    Add Yaml    BASE_STATIONS
    ...    - id: 2
    ...      type: simulated
    ...      plmn: '262:03'
    ...      s1: 10.0.1.3
    ...      x2: 10.0.1.3
    ...      cells:
    ...        - {id: 21, technology: lte, tac: 33, pci: '3:0', earfcn: '1600:19600', bw: 20, status: 'enabled'}
    ...        - {id: 22, technology: lte, tdd_cell: yes, duplex_mode: TDD, tac: 33, pci: '3:1', earfcn: '38000:38000', bw: 20}
    ...        - {id: 23, technology: lte, tac: 33, pci: '3:2', earfcn: '1700:19700', bw: 20}
    FOR    ${ue_set_id}     IN RANGE    1    31
        ${ue_capablity_set}  catenate
        ...    UEs/UE_sets/${ue_set_id}    capability: ${ue_eutra_capabilities}
        ...    capability_nr: ${ue_nr_capabilities}    capability_mrdc: ${ue_eutra_nr_capabilities}
        Update Yaml    ${ue_capablity_set}
    END
    Add Yaml    UEs/bearer_sets
    ...    bearer_set_2:
    ...     - {qci: 6, default: on, pdn: 1}
    ...     - {qci: 8, pdn: 1}
    FOR    ${ue_id}     IN RANGE    1    21
        Update Yaml    UEs/UE_sets/${ue_id}     bearer: bearer_set_2
    END

Local Test Setup For PCMD Precondition
    Common Test Setup And Start To Capture Logs
    Start TCE    ${tceport}
    Sleep    120    #wait PCMD trace session to establish


Local Test Teardown For Each Postcondition
    Stop TCE    ${tceport}
    Common Test Teardown And Stop Capture Logs

Local Test Teardown For Each Postcondition2
    Stop TCE    ${tceport}
    Add gnb_cell
    Common Test Teardown And Stop Capture Logs

Set ue parameters before attach
    FOR    ${ue_id}    IN RANGE    1    30
        execute uex command    ue_param id=${ue_id} dual_conn=eutra_nr pdcp_sn_extension=18bit
        execute uex command    ue_param id=${ue_id} nr_supported_bands=7,8,40,257
    END

OnlineParamChange
    [Arguments]    ${Online_Param}
    Delta Commission Parameters    ${Online_Param}
    Cells Should Be OnAir

Attach UE
    [Arguments]    ${ue_id}    ${enb_id}=1    ${cell_id}=1    ${ue_eutra_capabilities}=${ue_eutra_capabilities}
    ${V_1}    catenate
    ...    ue_attach id=${ue_id} enb=${enb_id} cell=${cell_id} ue_eutra_capabilities=${ue_eutra_capabilities}
    ...    ue_nr_capabilities=${ue_nr_capabilities} ue_eutra_nr_capabilities=${ue_eutra_nr_capabilities}
    execute uex command    ${V_1}

Lock X2 Link Between SimeNB2 And eNB1
    execute egate command    link_lock link=x2 at=enb:2 to=enb:1    X2AP Link with ENB-1.* is locked

UnLock X2 Link Between SimeNB2 And eNB1
    execute egate command    link_unlock link=x2 at=enb:2 to=enb:1    X2AP Link with ENB-1.* is unlocked

Trigger Inter-Enb X2 handover from SimeNB2
    [Arguments]    ${ue_id}=3
    execute uex command    ue_ho id=${ue_id} enb=1 cell=1
    #...    MME-1: UE${ue_id}: === Intra-SGW X2 Handover \\(eNB 42 -> eNB 1\\) completed

Trigger UE Reestablish to target ENB-1_CELL-1 due HO fail
    [Arguments]    ${ue_id}=1
    execute uex command
    ...    ue_rrc_reconf_param id=${ue_id} if_contains=mobilityControlInfo action=reestablish cause=handoverFailure cell=1 nth=1
    execute uex command and expect error    ue_ho id=${ue_id} enb=1 cell=1    sErrTransactionInProgress

Trigger Inter-Enb X2 handover from SimeNB2 To ENB-1 CELL-1
    [Arguments]    ${ue_id}=1    ${cell_id}=1
    Attach UE    ue_id=${ue_id}    enb_id=2    cell_id=${cell_id}
    Trigger Inter-Enb X2 handover from SimeNB2    ue_id=${ue_id}

Trigger UE Reestablish to target ENB-1_CELL-1 due HO failure
    [Arguments]    ${ue_id}=3    ${cell_id}=1
    ...    ${ue_eutra_capabilities}=${ue_eutra_capabilities}
    Attach UE    ue_id=${ue_id}    enb_id=2    cell_id=${cell_id}
    Trigger UE Reestablish to target ENB-1_CELL-1 due HO fail    ue_id=${ue_id}

Perform ENDC HO and detach UE
    [Arguments]    ${meas_id_blacklist}    ${ue_id}    ${pcell_id}=10
    ${command}    catenate
    ...    ue_measurement_send meas_id_blacklist=${meas_id_blacklist} id=${ue_id} event=A5
    ...    srsrp=60 srsrq=15 phycell_id=${pcell_id} nrsrp=43 nrsrq=16
    execute uex command      ${command}
    sleep    2s
    UE Detach    ue_id=${ue_id}

Perform Intra HO and detach UE
    [Arguments]     ${ue_id}    ${cell_id}=3
    expect message flow
    ...    ENB_1:X2AP_SgNBModificationRequest(radioNetwork eq 'mCG-Mobility')
    ...    UE_${ue_id}:RRC_RRCConnectionReconfiguration(mobilityControlInfo contains (targetPhysCellId eq 3))
    ...    UE_${ue_id}:RRC_RRCConnectionReconfiguration(${endcA5activateAndGapConfig})
    ...    ENB_1:X2AP_SgNBModificationRequest(gapOffset eq 29)
    ...    UE_${ue_id}:RRC_RRCConnectionReconfiguration(${endcA5deactivateAndGapRelease})
    ...    ENB_1:X2AP_SgNBModificationRequest(measGapConfig contains (release is present))
    ...    UE_${ue_id}:RRC_RRCConnectionReconfiguration(${endcA5activateAndGapConfig})
    ...    ENB_1:X2AP_SgNBModificationRequest(gapOffset eq 29)
    ...    alias=intraeNBHo_flow    overall_timeout=30
    execute uex command      ue_ho id=${ue_id} enb=1 cell=${cell_id}
    Wait A5 retry timer twice
    flow occurred as expected    alias=intraeNBHo_flow
    UE Detach    ue_id=${ue_id}


Delete gnb_cell
    [Arguments]    ${cell_id}=72    ${gNB_id}=7
    ${command}    catenate    gnb_cell_param    id=${cell_id}    gnb=${gNB_id}    status=disabled
    ${command1}    catenate    endc_conf_update    id=${gNB_id}    target=1    served_nr_cells_to_delete=${cell_id}
    execute egate command    ${command}
    execute egate command    ${command1}
    Object Should Exist    ${NRcell_unava}

Add gnb_cell
    [Arguments]    ${cell_id}=72    ${gNB_id}=7
    ${command}    catenate    gnb_cell_param    id=${cell_id}    gnb=${gNB_id}    status=enabled
    ${command1}    catenate     endc_conf_update    id=${gNB_id}    target=1    served_nr_cells_to_add=${cell_id}
    execute egate command    ${command}
    execute egate command    ${command1}

UE enter cell via ICS and perform ENDC intra enb HO
    [Arguments]    ${ue_id}=1    ${meas_id_blacklist}=3
    expect message flow
    ...    UE_${ue_id}:RRC_RRCConnectionReconfiguration(${ENDC_A5_activate})
    ...    alias=endca5_flow    overall_timeout=30
    Attach UE    ue_id=${ue_id}    enb_id=1    cell_id=1
    flow occurred as expected    alias=endca5_flow
    expect message flow
    ...    UE_${ue_id}:RRC_RRCConnectionReconfiguration(${ho_to_38020})
    ...    alias=endca5ho_flow    overall_timeout=30
    Perform ENDC HO and detach UE    ${meas_id_blacklist}    ue_id=${ue_id}    pcell_id=2
    flow occurred as expected    endca5ho_flow

UE enter cell via HO and perform ENDC X2 HO
    [Arguments]    ${ue_id}=1
    expect message flow
    ...    ENB_2:X2AP_HandoverRequest
    ...    UE_${ue_id}:RRC_RRCConnectionReconfiguration(${ENDC_A5_activate})
    ...    alias=endca5activate_flow    overall_timeout=30
    Trigger Inter-Enb X2 handover from SimeNB2 To ENB-1 CELL-1    ue_id=${ue_id}    cell_id=22
    flow occurred as expected    alias=endca5activate_flow
    expect message flow
    ...    ENB_1:X2AP_HandoverRequest
    ...    UE_${ue_id}:RRC_RRCConnectionReconfiguration(${ho_to_1600})
    ...    alias=endca5ho_flow    overall_timeout=30
    Perform ENDC HO and detach UE    meas_id_blacklist=2,5    ue_id=${ue_id}    pcell_id=9
    flow occurred as expected    alias=endca5ho_flow

UE enter cell via reestablish and perform ENDC S1 HO
    [Arguments]    ${ue_id}=1
    expect message flow
    ...    ENB_2:X2AP_HandoverRequest
    ...    UE_${ue_id}:RRC_RRCConnectionReestablishmentRequest
    ...    UE_${ue_id}:RRC_RRCConnectionReestablishmentComplete
    ...    UE_${ue_id}:RRC_RRCConnectionReconfiguration(${endc_a5_activate})
    ...    alias=endca5rre_flow    overall_timeout=30
    Trigger UE Reestablish to target ENB-1_CELL-1 due HO failure    ue_id=${ue_id}    cell_id=22
    flow occurred as expected    alias=endca5rre_flow
    Lock X2 Link Between SimeNB2 And eNB1
    expect message flow
    ...    MME_1:S1AP_HandoverRequest
    ...    UE_${ue_id}:RRC_RRCConnectionReconfiguration(${ho_to_1600})
    ...    alias=endca5S1ho_flow    overall_timeout=30
    Perform ENDC HO and detach UE    meas_id_blacklist=2,5    ue_id=${ue_id}    pcell_id=9
    flow occurred as expected    alias=endca5S1ho_flow
    UnLock X2 Link Between SimeNB2 And eNB1

OnlineParamChanges and clear counter Files
    [Arguments]    ${parameter}
    OnlineParamChange    ${parameter}
    Clear Counter Files

Check Counters and PCMD messages
    [Arguments]    ${counters}    ${PCMD}
    Check Counters    ${counters}
    Check WireShark Log    ${PCMD}    wait_string=StopRecordingSession::3

Delete gnb_cell and Clear Counter Files
    Delete gnb_cell
    Clear Counter Files

Attach UE and setup ENDC
    [Arguments]    ${ue_id}=1
    expect message flow
    ...    UE_${ue_id}:RRC_RRCConnectionReconfiguration(measGapConfig contains (release is present))
    ...    UE_${ue_id}:RRC_RRCConnectionReconfiguration(${ENDC_A5_activate})
    ...    UE_${ue_id}:RRC_MeasurementReport(measId eq 17)
    ...    ENB_1:X2AP_SgNBAdditionRequest
    ...    GNB_7:X2AP_SgNBAdditionRequestAcknowledge
    ...    UE_${ue_id}:RRC_RRCConnectionReconfiguration(${ENDC_a5_remove})
    ...    UE_${ue_id}:RRC_RRCConnectionReconfiguration(${ENDC_a5_retry})
    ...    alias=icsAndENDC_flow    overall_timeout=60
    Attach UE    ue_id=${ue_id}    enb_id=1    cell_id=1
    Check ENDC setup for UE with valid B1    ue_id=${ue_id}    meas_id_blacklist=18    phycell_id=2
    Wait A5 retry timer twice
    flow occurred as expected    alias=icsAndENDC_flow

Attach UE with Gap and setup ENDC
    [Arguments]    ${ue_id}=1
    expect message flow
    ...    UE_${ue_id}:RRC_RRCConnectionReconfiguration(measGapConfig contains (release is present))
    ...    UE_${ue_id}:RRC_RRCConnectionReconfiguration(${ENDC_A5_activate})
    ...    UE_${ue_id}:RRC_MeasurementReport(measId eq 17)
    ...    ENB_1:X2AP_SgNBAdditionRequest
    ...    GNB_7:X2AP_SgNBAdditionRequestAcknowledge
    ...    UE_${ue_id}:RRC_RRCConnectionReconfiguration(${ENDC_a5_remove})
    ...    UE_${ue_id}:RRC_RRCConnectionReconfiguration(${ENDC_a5_retry})
    ...    alias=icsAndENDC_flow    overall_timeout=60
    Attach UE    ue_id=${ue_id}    enb_id=1    cell_id=1    ue_eutra_capabilities=${ue_eutra_capabilities_with_gap}
    Check ENDC setup for UE with valid B1    ue_id=${ue_id}    meas_id_blacklist=18    phycell_id=2
    Wait A5 retry timer twice
    flow occurred as expected    alias=icsAndENDC_flow

Check ENDC setup for UE with valid B1
    [Arguments]    ${ue_id}=1    ${meas_id_blacklist}=18    ${phycell_id}=2
    execute uex command
    ...    ue_measurement_send id=${ue_id} meas_id_blacklist=${meas_id_blacklist} event=B1_NR phycell_id=${phycell_id} nrsrp=120

Wait A5 retry timer twice
    sleep    20s    #A5 retry timer is 10s

UE Detach
    [Arguments]    ${ue_id}=1
    Execute Uex Command    ue_detach id=${ue_id}