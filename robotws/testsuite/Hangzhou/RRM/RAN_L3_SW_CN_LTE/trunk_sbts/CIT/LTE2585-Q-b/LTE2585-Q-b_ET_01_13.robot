*** Settings ***
Suite Setup       Setup CUS Env And Start TCE
Suite Teardown    Stop TCE and Common Suite Teardown
Test Setup        Common Test Setup And Start To Capture Logs
Test Teardown     Common Test Teardown And Stop Capture Logs
Force Tags        QCD_MN_RAN    QCP_RAN_ET    SBTS00    4G_TDD    RAN_4G    RAN_4G_TDD    CIT
...               CLOUD_R4LAPO_CUS    release-xL18    owner-junli.chang    DevHZ5_SG3
Resource          ../../../resources/DevHZ5_resource.robot

*** Variables ***
@{PARAMS_IN_SCF}
...  LNBTS:actCellTrace=true
...  LNBTS:actMDTCellTrace=true
...  LNBTS:actInterFreqMDTCellTrace=true
...  @{MTRACE}
...  @{LNHOIF}
...  @{Gap_related}
...  @{Feature_related}
...  LNCEL-1/LNCEL_TDD-0:earfcn=40742
...  LNCEL-2/LNCEL_TDD-0:earfcn=40940
...  LNCEL-3/LNCEL_TDD-0:earfcn=41138
...  @{relationerror}
...  @{LTRACE}
...  @{CTRLTS}
@{relationerror}
...    LNBTS:actCellTrace=true
...    LNBTS:actAmbrModCaTrigger=false
...    LNBTS:actFlexCaMgmt=false
...    LNCEL-1:actScellConfigForHiDemand=false
...    LNCEL:eTputInitMcs=20
...    LNCEL:eTputFilterConfig=51
...    LNCEL:actCaArchEnhImp=off
...    LNCEL:actFlowCtrlEnh=false
...    LNBTS-1/LNBTS_TDD-0:actConvVoice=false
...    delete:LNCEL-1:n310Qci1
...    delete:LNCEL-1:t310Qci1
...    LNCEL-1/CAREL-1:lnBtsId=1
...    LNCEL-1/CAREL-1:lcrId=2
...    LNCEL-1/LNCEL_TDD-0/MPUCCH_TDD-0:maxNumRrc=55
...    LNCEL-2/LNCEL_TDD-0:maxNumActUE=50
...    LNCEL-2/LNCEL_TDD-0:maxNumActDrb=50
...    LNCEL-3/LNCEL_TDD-0/MPUCCH_TDD-0:maxNumRrc=540
@{LNHOIF}
...  LNCEL-1/LNHOIF-1:eutraCarrierInfo=40050
...  LNCEL-1/LNHOIF-1:measurementBandwidth=mbw100
...  LNCEL-1/LNHOIF-2:eutraCarrierInfo=41000
...  LNCEL-1/LNHOIF-2:measurementBandwidth=mbw100
${band41and38_ue_eutra_capabilities}
...  SEPARATOR=
...  D59FF420346504070380FFFFFFFFFC0000802000000098A006AA8403A0000303A0000207A00000680003D00000340081E800009A001ABE4000
...  18A200424000AA000404403BA0
${Not_supportGNSSue_eutra_capabilities}
...  SEPARATOR=
...  D59FF420346504070380FFFFFFFFFC0000802000000098A006A28403A0000303A0000207A00000680003D00000340081E800009A001ABE4000
...  028801090002A800101100EE80
@{CTRLTS}
...    LNBTS-1/CTRLTS-1:extTraceReporting:extCellTraceRep=true
...    LNBTS-1/CTRLTS-1:extTraceReporting:extUeTraceRep=true
...    LNBTS-1/CTRLTS-1:traceRepMode:cellTraceRepMode=Online
...    LNBTS-1/CTRLTS-1:traceRepMode:ueTraceRepMode=Online
...    LNBTS-1/CTRLTS-1:tceIdLogMdtIpMap:loggedPortNum=49150
...    LNBTS-1/CTRLTS-1:tceIdLogMdtIpMap:loggedTCEId=3
...    LNBTS-1/CTRLTS-1:tceIdLogMdtIpMap:loggedTCEIP=0.0.0.1
...    LNBTS-1/CTRLTS-1:tceIdLogMdtIpMap:loggedTCEmcc=262
...    LNBTS-1/CTRLTS-1:tceIdLogMdtIpMap:loggedTCEmnc=3
...    LNBTS-1/CTRLTS-1:tceIdLogMdtIpMap:loggedTCEmncLen=2
...    LNBTS-1/CTRLTS-1:vendorSpecTracing:taTracing=false
...    LNBTS-1/CTRLTS-1:maxUeTraceSessions=60
...    LNBTS-1/CTRLTS-1:netActIpAddr=1.1.1.1
...    LNBTS-1/CTRLTS-1:omsTracePortNum=49392
...    LNBTS-1/CTRLTS-1:subscriberMDTObtainLocation=false
...    LNBTS-1/CTRLTS-1:tceTracePortNum=49150
@{LTRACE}
...    LTRACE-1:enableLoggedMdtTRSStartStopInd=false
...    LTRACE-1:loggedCellConf:lcrId=1
...    LTRACE-1:loggedCellConf:mode=configureAndRetrieveDataFromUEs
...    LTRACE-1:loggedMDTConf:anonymizationMDTdata=No identity
...    LTRACE-1:loggedMDTConf:forceUEconsent=false
...    LTRACE-1:loggedMDTConf:loggedTCEId=2
...    LTRACE-1:loggedMDTConf:loggingDuration=120
...    LTRACE-1:loggedMDTConf:loggingInterval=20480
...    LTRACE-1:loggedMDTConf:selectOnlyStandaloneGNSSUes=true
...    LTRACE-1:plmnPerTAlist:mdtperTAmcc=3
...    LTRACE-1:plmnPerTAlist:mdtperTAmnc=99
...    LTRACE-1:plmnPerTAlist:mdtPerTAmncLen=3
...    LTRACE-1:traceReference:traceId=3
...    LTRACE-1:traceReference:traceReferenceMcc=262
...    LTRACE-1:traceReference:traceReferenceMnc=3
...    LTRACE-1:traceReference:traceReferenceMncLen=2
@{MTRACE}
...  MTRACE-1:lcrId=1
...  MTRACE-1:jobType=ImmediateMDTAndTrace
...  MTRACE-1:cellMaxActiveUEsTraced=20
...  MTRACE-1:tceIpAddress=${TCE_IP}
...  MTRACE-1:tceCellTracePortNum=${TCE_PORT}
...  MTRACE-1:traceRrcSetting=All
...  MTRACE-1:eutranTraceId:eutranTraceIdMcc=262
...  MTRACE-1:eutranTraceId:eutranTraceIdMnc=3
...  MTRACE-1:eutranTraceId:eutranTraceIdMncLen=2
...  MTRACE-1:eutranTraceId:traceId=1
...  MTRACE-1:eutranTraceId:trcRecSessionRef=1
...  MTRACE-1:iFMDTList:measBW=mbw100|iFFreqEARFCN=40940
...  MTRACE-1:iFMDTList:measBW=mbw100|iFFreqEARFCN=41138
...  MTRACE-1:iFMDTList:measBW=mbw100|iFFreqEARFCN=40000
...  MTRACE-1:periodicUeMeas:reportAmount=infinity
...  MTRACE-1:periodicUeMeas:reportInterval=5120ms
...  MTRACE-1:immedMDTControl:immedMDTAnonymization=IMEI-TAC
...  MTRACE-1:immedMDTControl:immedMDTForceUEConsent=false
...  MTRACE-1:immedMDTControl:immedMDTObtainLocation=true
...  MTRACE-1:immedMDTControl:immedMDTPosMethod=GNSS
...  MTRACE-1:immedMDTControl:immedMDTSelectOnlyGNSSUes=true
...  MTRACE-1:immedMDTControl:cellMaxActiveMDTUEsTraced=20
...  MTRACE-1:immedMDTControl:iFMDTPercentage=30
@{Gap_related}
...  LNCEL-1:actSmartDrx=true
...  LNCEL-1:actDrxDuringMeasGap=true
...  LNCEL-1:actDrx=true
@{Feature_related}
...  LNBTS:actMBMSServiceContinuity=true
...  LNCEL-1:iFServiceBasedHoRetryTimer=60
...  LNBTS:prioritizeVoLTEoverMBMS=true
...  LNBTS:actA3ScellSelect=true
...  LNBTS:actDLCAggr=true
...  LNBTS:caSchedFairFact=0
...  LNBTS:actEnhAcAndGbrServices=true
...  LNBTS:actMultBearers=true
...  LNBTS:actUeBasedAnrInterFreqLte=false
...  LNBTS:act1xCsfb=false
...  LNBTS:actCsfbPsHoToUtra=true
...  LNBTS:actHOtoWcdma=true
...  LNBTS/LNBTS_TDD-0:preventPsHOtoWcdma=None
...  LNBTS:actCSFBRedir=Enabled
...  LNBTS:geranDtmCap=true
...  LNBTS/LNBTS_TDD-0:actVoLteCallSteering=true
...  LNBTS/LNBTS_TDD-0:actRedirVoLte=true
...  LNBTS:actIfHo=enabled
...  LNCEL-1:threshold2aQci1=46
...  LNBTS:actLPPaEcid=true
...  LNCEL-1:actTtibRsc=true
...  LNCEL-1:actTtiBundling=true
...  LNCEL-1:ttibOperMode=blerBasedNotWithMeasGap
...  LNCEL-2/LNCEL_TDD-0:voLteRedirTimer=2
...  LNCEL-3/LNCEL_TDD-0:voLteRedirTimer=2
...  LNCEL-1:ecidMeasSupervisionTimer=3000
...  LNCEL-2:ecidMeasSupervisionTimer=3000
...  LNCEL-3:ecidMeasSupervisionTimer=3000
...  LNBTS/LNBTS_TDD-0:actConvVoice=false
...  LNCEL-2/LNCEL_TDD-0/MPUCCH_TDD-0:maxNumRrc=55
...  LNCEL-2/LNCEL_TDD-0/MPUCCH_TDD-0:maxNumRrcEmergency=65
...  LNCEL-1/LNCEL_TDD-0:maxNumActUE=50
...  LNCEL-1/LNCEL_TDD-0:maxNumActDrb=50
${ue1_reconfig}
...    measObjectToAddModList contains (carrierFreq eq 40940 and allowedMeasBandwidth eq 'mbw100') and
...    reportConfigToAddModList contains (purpose eq 'reportStrongestCells' and reportInterval eq 'ms5120') and
...    measIdToAddModList contains (measId eq 14 and measObjectId eq 2 and reportConfigId eq 5)
${ue3_reconfig}
...    measObjectToAddModList contains (carrierFreq eq 40742 and allowedMeasBandwidth eq 'mbw100') and
...    reportConfigToAddModList contains (purpose eq 'reportStrongestCells' and reportInterval eq 'ms5120') and
...    measIdToAddModList contains (measId eq 9 and measObjectId eq 1 and reportConfigId eq 5)
${ue5_reconfig}
...    measObjectToAddModList contains (carrierFreq eq 40742 and allowedMeasBandwidth eq 'mbw100') and
...    reportConfigToAddModList contains (purpose eq 'reportStrongestCells' and reportInterval eq 'ms5120') and
...    measIdToAddModList contains (measId eq 9 and measObjectId eq 1 and reportConfigId eq 5)

*** Test Cases ***
LTE2585-Q-b_ET_01_13_Inter Freq MDT with 30 percent iFMDTPercentage and immedMDTSelectOnlyGNSSUes is set True
    [Documentation]    checkpoints:
    ...
    ...    1.actInterFreqMDTCellTrace set false but MDT allowed is on in UE context, then eNB configures intraMDT to UE
    ...
    ...    2. after UE attach, eNB configures intraMDT to UE
    [Tags]
    [Template]
    Enable Management MDT Based Allowed
    UE1 UE2 UE3 attach to eNB1
    UE4 attach to eNB1
    UE5 attach to eNB1
    Check Wireshark log    ${CURDIR}${/}A2A_LTE2585-Q-b_01_13_EV${/}a2a.ini

*** Keywords ***
Setup CUS Env And Start TCE
    Common Suite Setup
    Setup CUS Env    3CELLs
    Start Tce    ${TCE_PORT}
    Sleep    5 minutes    #wait UEC receive MDT configuration
    Create Alias

Create Alias
    Create UE Alias    UE_1    ue_id=1    id_type=cus
    Create UE Alias    UE_3    ue_id=3    id_type=cus
    Create UE Alias    UE_5    ue_id=5    id_type=cus

Stop TCE and Common Suite Teardown
    Stop TCE
    Common Suite Teardown And Restore BTS Configuration Parameters

Enable Management MDT Based Allowed
    execute egate command    ue_mme_param mb_mdt_allowed=on id=1,3,4,5

UE1 UE2 UE3 attach to eNB1
    expect message flow
    ...    UE_1:RRC_RRCConnectionReconfiguration(${ue1_reconfig})
    ...    alias=attch_flow    overall_timeout=120
    execute uex command    ue_attach id=1 ue_eutra_capabilities=${band41and38_ue_eutra_capabilities} cell=1
    flow occurred as expected    alias=attch_flow
    execute uex command    ue_attach id=2 ue_eutra_capabilities=${band41and38_ue_eutra_capabilities} cell=1
    expect message flow
    ...    UE_3:RRC_RRCConnectionReconfiguration(${ue3_reconfig})
    ...    alias=ue3attch_flow    overall_timeout=120
    execute uex command    ue_attach id=3 ue_eutra_capabilities=${band41and38_ue_eutra_capabilities} cell=1
    flow occurred as expected    alias=ue3attch_flow

UE4 attach to eNB1
    execute uex command    ue_attach id=4 ue_eutra_capabilities=${Not_supportGNSSue_eutra_capabilities} cell=1

UE5 attach to eNB1
    expect message flow
    ...    UE_5:RRC_RRCConnectionReconfiguration(${ue5_reconfig})
    ...    alias=ue5attch_flow    overall_timeout=120
    execute uex command    ue_attach id=5 ue_eutra_capabilities=${band41and38_ue_eutra_capabilities} cell=1
    flow occurred as expected    alias=ue5attch_flow
