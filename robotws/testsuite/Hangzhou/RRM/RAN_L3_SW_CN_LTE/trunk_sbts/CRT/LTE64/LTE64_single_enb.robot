*** Settings ***
Suite Setup       Common Suite Setup And Setup CUS Env
Suite Teardown    Common Suite Teardown And Restore BTS Configuration Parameters
Test Setup        Common Test Setup And Start To Capture Logs
Test Teardown     Common Test Teardown And Stop Capture Logs
Force Tags        QCD_MN_RAN    QCP_RAN_ET    SBTS00    RAN_4G    RAN_4G_FDD    CRT    CLOUD_R4LAPO_CUS
...               owner-xu.wang    team-SG4    release-L15A    owner-xu.wang
Resource          ../../../resources/DevHZ5_resource.robot

*** Variables ***
@{PARAMS_IN_SCF}
...    @{PARAMS_Feature_Related_Switch}
...    @{PARAMS_Measurement_Thresholds_Cell_1}
...    @{PARAMS_IRAT_WCDMA_Neighbor_Cell_1}
...    @{PARAMS_IRAT_GSM_Neighbor_Cell_1}
...    @{PARAMS_IFHO_Neighbor_Cell_1}
...    @{PARAMS_Measurement_Thresholds_Cell_2}
...    @{PARAMS_IRAT_WCDMA_Neighbor_Cell_2}
...    @{PARAMS_IRAT_GSM_Neighbor_Cell_2}
...    @{PARAMS_IFHO_Neighbor_Cell_2}
@{PARAMS_Feature_Related_Switch}
...    LNBTS-1:actServBasedMobThr=true
...    LNBTS-1:actIfHo=enabled
...    LNBTS-1:acteNACCtoGSM=true
...    LNBTS-1:actHOtoWcdma=true
...    LNBTS-1:actMultBearers=true
...    LNBTS-1:actMultGbrBearers=true
...    LNBTS-1:actRedirect=enabled
...    LNBTS-1/LNBTS_FDD-0:actSrvccToWcdma=true
...    LNBTS-1/LNBTS_FDD-0:actSrvccToGsm=true
...    LNBTS-1/LNBTS_FDD-0:actConvVoice=true
...    LNBTS-1/LNBTS_FDD-0:preventPsHOtoWcdma=None
@{PARAMS_Measurement_Thresholds_Cell_1}
...    LNCEL-1:a2RedirectQci1=enabled
...    LNCEL-1:a3Offset=10
...    LNCEL-1:a2TimeToTriggerActWcdmaMeas=64ms
...    LNCEL-1:hysThreshold2InterFreq=0
...    LNCEL-1:hysThreshold2a=0
...    LNCEL-1:threshold1=90
...    LNCEL-1:threshold2InterFreq=61
...    LNCEL-1:threshold2InterFreqQci1=64
...    LNCEL-1:threshold2GERAN=55
...    LNCEL-1:threshold2GERANQci1=55
...    LNCEL-1:threshold2Wcdma=58
...    LNCEL-1:threshold2WcdmaQci1=58
...    LNCEL-1:threshold2a=67
...    LNCEL-1:threshold2aQci1=70
...    LNCEL-1:threshold3=55
...    LNCEL-1:threshold3a=56
...    LNCEL-1:threshold4=52
...    LNCEL-1:rsrqMobilityParams:a1ReportInterval=1024ms
...    LNCEL-1:rsrqMobilityParams:hysThreshold2MobRsrq=0
...    LNCEL-1:rsrqMobilityParams:threshold2MobRsrq=10
...    LNCEL-1:rsrqMobilityParams:threshold2aRsrq=16
...    LNCEL-1:rsrqMobilityParams:a2TimeToTriggerMobRsrq=480ms
...    LNCEL-1:rsrqRedirectParams:a2TimeToTriggerRedirectRsrq=480ms
...    LNCEL-1:rsrqRedirectParams:hysThreshold4Rsrq=0
...    LNCEL-1:rsrqRedirectParams:threshold4Rsrq=-38
...    LNCEL-1/REDRT-1:addGsmSIToRedirMsg=both
...    LNCEL-1/REDRT-1:addUtranSIToRedirMsg=both
...    LNCEL-1/REDRT-1:redirFreqEutra=1500
...    LNCEL-1/REDRT-1:redirRat=eutra
...    LNCEL-1/REDRT-1:redirectPrio=1
@{PARAMS_Measurement_Thresholds_Cell_2}
...    LNCEL-2:a2RedirectQci1=enabled
...    LNCEL-2:a3Offset=12
...    LNCEL-2:a2TimeToTriggerActWcdmaMeas=64ms
...    LNCEL-2:threshold1=91
...    LNCEL-2:threshold2GERAN=56
...    LNCEL-2:threshold2GERANQci1=56
...    LNCEL-2:threshold2InterFreq=62
...    LNCEL-2:threshold2InterFreqQci1=65
...    LNCEL-2:threshold2Wcdma=59
...    LNCEL-2:threshold2WcdmaQci1=59
...    LNCEL-2:threshold2a=68
...    LNCEL-2:threshold2aQci1=71
...    LNCEL-2:threshold3=56
...    LNCEL-2:threshold3a=57
...    LNCEL-2:threshold4=53
...    LNCEL-2:hysThreshold2InterFreq=0
...    LNCEL-2:hysThreshold2a=0
...    LNCEL-2/REDRT-1:addGsmSIToRedirMsg=both
...    LNCEL-2/REDRT-1:addUtranSIToRedirMsg=both
...    LNCEL-2/REDRT-1:redirFreqEutra=1500
...    LNCEL-2/REDRT-1:redirRat=eutra
...    LNCEL-2/REDRT-1:redirectPrio=1
@{PARAMS_IRAT_WCDMA_Neighbor_Cell_1}
...    LNADJW-1:primaryPlmnId:mcc=262
...    LNADJW-1:primaryPlmnId:mnc=3
...    LNADJW-1:primaryPlmnId:mncLength=2
...    LNADJW-1:srvccHoInd=PSandCS
...    LNADJW-1:uTargetScFdd=1
...    LNADJW-1:uTargetCid=2
...    LNADJW-1:uTargetFreq=10600
...    LNADJW-1:uTargetLac=3
...    LNADJW-1:uTargetRncId=4
...    LNADJW-1:uTargetRac=5
...    LNCEL-1/LNHOW-1:reportIntervalUtra=480ms
...    LNCEL-1/LNHOW-1:maxNumCsfbTargets=16
...    LNCEL-1/LNHOW-1:hysB1ThresholdCSFBUtra=0
...    LNCEL-1/LNHOW-1:hysB2ThresholdUtra=4
...    LNCEL-1/LNHOW-1:b1ThresholdCSFBUtraEcn0=12
...    LNCEL-1/LNHOW-1:b1ThresholdCSFBUtraRscp=5
...    LNCEL-1/LNHOW-1:b2Threshold1Utra=56
...    LNCEL-1/LNHOW-1:b2Threshold1UtraQci1=57
...    LNCEL-1/LNHOW-1:b2Threshold2UtraEcn0=19
...    LNCEL-1/LNHOW-1:b2Threshold2UtraEcn0Qci1=19
...    LNCEL-1/LNHOW-1:b2Threshold2UtraRscp=8
...    LNCEL-1/LNHOW-1:b2Threshold2UtraRscpQci1=13
...    LNCEL-1/LNHOW-1:b2TimeToTriggerUtraMeas=320ms
...    LNCEL-1/LNHOW-1:b1TimeToTriggerCSFBUtraMeas=256ms
...    LNCEL-1/LNHOW-1:utraCarrierFreq=10600
...    LNCEL-1/LNHOW-1:offsetFreqUtra=0
...    LNCEL-1/LNHOW-1:thresholdEcn0UtranLbFilter=19
...    LNCEL-1/LNHOW-1:thresholdRscpUtranLbFilter=10
...    LNCEL-1/LNRELW-1:csfbPsHoAllowed=forbidden
...    LNCEL-1/LNRELW-1:utranLbAllowed=false
...    LNCEL-1/LNRELW-1:nrControl=automatic
...    LNCEL-1/LNRELW-1:psHoAllowed=allowed
...    LNCEL-1/LNRELW-1:redirWithSysInfoAllowed=allowed
...    LNCEL-1/LNRELW-1:removeAllowed=true
...    LNCEL-1/LNRELW-1:srvccAllowed=allowed
...    LNCEL-1/LNRELW-1:uTargetCid=2
...    LNCEL-1/LNRELW-1:uTargetRncId=4
...    LNCEL-1/LNRELW-1:plmnId:mcc=262
...    LNCEL-1/LNRELW-1:plmnId:mnc=3
...    LNCEL-1/LNRELW-1:plmnId:mncLength=2
@{PARAMS_IRAT_WCDMA_Neighbor_Cell_2}
...    LNCEL-2/LNHOW-1:reportIntervalUtra=480ms
...    LNCEL-2/LNHOW-1:maxNumCsfbTargets=16
...    LNCEL-2/LNHOW-1:hysB1ThresholdCSFBUtra=0
...    LNCEL-2/LNHOW-1:hysB2ThresholdUtra=4
...    LNCEL-2/LNHOW-1:b1ThresholdCSFBUtraEcn0=12
...    LNCEL-2/LNHOW-1:b1ThresholdCSFBUtraRscp=5
...    LNCEL-2/LNHOW-1:b2Threshold1Utra=56
...    LNCEL-2/LNHOW-1:b2Threshold1UtraQci1=57
...    LNCEL-2/LNHOW-1:b2Threshold2UtraEcn0=19
...    LNCEL-2/LNHOW-1:b2Threshold2UtraEcn0Qci1=25
...    LNCEL-2/LNHOW-1:b2Threshold2UtraRscp=8
...    LNCEL-2/LNHOW-1:b2Threshold2UtraRscpQci1=13
...    LNCEL-2/LNHOW-1:b2TimeToTriggerUtraMeas=320ms
...    LNCEL-2/LNHOW-1:b1TimeToTriggerCSFBUtraMeas=256ms
...    LNCEL-2/LNHOW-1:utraCarrierFreq=10600
...    LNCEL-2/LNHOW-1:offsetFreqUtra=0
...    LNCEL-2/LNHOW-1:thresholdEcn0UtranLbFilter=19
...    LNCEL-2/LNHOW-1:thresholdRscpUtranLbFilter=10
...    LNCEL-2/LNRELW-1:csfbPsHoAllowed=forbidden
...    LNCEL-2/LNRELW-1:utranLbAllowed=false
...    LNCEL-2/LNRELW-1:nrControl=automatic
...    LNCEL-2/LNRELW-1:psHoAllowed=allowed
...    LNCEL-2/LNRELW-1:redirWithSysInfoAllowed=allowed
...    LNCEL-2/LNRELW-1:removeAllowed=false
...    LNCEL-2/LNRELW-1:srvccAllowed=allowed
...    LNCEL-2/LNRELW-1:uTargetCid=2
...    LNCEL-2/LNRELW-1:uTargetRncId=4
...    LNCEL-2/LNRELW-1:plmnId:mcc=262
...    LNCEL-2/LNRELW-1:plmnId:mnc=3
...    LNCEL-2/LNRELW-1:plmnId:mncLength=2
@{PARAMS_IRAT_GSM_Neighbor_Cell_1}
...    LNADJG-1:arfcnValueGeran=512
...    LNADJG-1:bandIndicatorGeran=dcs1800
...    LNADJG-1:basestationColourCode=0
...    LNADJG-1:dtm=false
...    LNADJG-1:gTargetCi=1
...    LNADJG-1:gTargetLac=1
...    LNADJG-1:gTargetRac=1
...    LNADJG-1:mcc=262
...    LNADJG-1:mnc=3
...    LNADJG-1:mncLength=2
...    LNADJG-1:networkColourCode=1
...    LNADJG-1:networkControlOrder=NC0
...    LNADJG-1:systemInfoType=none
...    LNCEL-1/LNHOG-1:arfcnValueListGERAN=512
...    LNCEL-1/LNHOG-1:b2Threshold1GERAN=53
...    LNCEL-1/LNHOG-1:b2Threshold1GERANQci1=54
...    LNCEL-1/LNHOG-1:b2Threshold2RssiGERAN=26
...    LNCEL-1/LNHOG-1:b2Threshold2RssiGERANQci1=27
...    LNCEL-1/LNHOG-1:b2TimeToTriggerGERANMeas=512ms
...    LNCEL-1/LNHOG-1:bandIndicatorGERAN=dcs1800
...    LNCEL-1/LNHOG-1:hysB2ThresholdGERAN=4
...    LNCEL-1/LNHOG-1:nccperm=0
...    LNCEL-1/LNHOG-1:reportIntervalGERAN=480ms
...    LNCEL-1/LNRELG-1:ci=1
...    LNCEL-1/LNRELG-1:eNACCAllowed=allowed
...    LNCEL-1/LNRELG-1:lac=1
...    LNCEL-1/LNRELG-1:nrControl=automatic
...    LNCEL-1/LNRELG-1:redirWithSysInfoAllowed=forbidden
...    LNCEL-1/LNRELG-1:srvccAllowed=allowed
...    LNCEL-1/LNRELG-1:plmnId:mcc=262
...    LNCEL-1/LNRELG-1:plmnId:mnc=3
...    LNCEL-1/LNRELG-1:plmnId:mncLength=2
@{PARAMS_IRAT_GSM_Neighbor_Cell_2}
...    LNCEL-2/LNHOG-0:arfcnValueListGERAN=512
...    LNCEL-2/LNHOG-0:b2Threshold1GERAN=54
...    LNCEL-2/LNHOG-0:b2Threshold1GERANQci1=55
...    LNCEL-2/LNHOG-0:b2Threshold2RssiGERAN=27
...    LNCEL-2/LNHOG-0:b2Threshold2RssiGERANQci1=28
...    LNCEL-2/LNHOG-0:b2TimeToTriggerGERANMeas=512ms
...    LNCEL-2/LNHOG-0:bandIndicatorGERAN=dcs1800
...    LNCEL-2/LNHOG-0:hysB2ThresholdGERAN=4
...    LNCEL-2/LNHOG-0:nccperm=0
...    LNCEL-2/LNHOG-0:reportIntervalGERAN=480ms
...    LNCEL-2/LNRELG-1:ci=1
...    LNCEL-2/LNRELG-1:eNACCAllowed=allowed
...    LNCEL-2/LNRELG-1:lac=1
...    LNCEL-2/LNRELG-1:nrControl=automatic
...    LNCEL-2/LNRELG-1:redirWithSysInfoAllowed=forbidden
...    LNCEL-2/LNRELG-1:srvccAllowed=allowed
...    LNCEL-2/LNRELG-1:plmnId:mcc=262
...    LNCEL-2/LNRELG-1:plmnId:mnc=3
...    LNCEL-2/LNRELG-1:plmnId:mncLength=2
@{PARAMS_IFHO_Neighbor_Cell_1}
...    LNCEL-1/LNHOIF-1:a3OffsetRsrpInterFreq=10
...    LNCEL-1/LNHOIF-1:a3OffsetRsrpInterFreqHpue=6
...    LNCEL-1/LNHOIF-1:a3OffsetRsrpInterFreqQci1=6
...    LNCEL-1/LNHOIF-1:a3ReportIntervalRsrpInterFreq=240ms
...    LNCEL-1/LNHOIF-1:a3TimeToTriggerRsrpInterFreq=320ms
...    LNCEL-1/LNHOIF-1:a5ReportIntervalInterFreq=240ms
...    LNCEL-1/LNHOIF-1:a5TimeToTriggerInterFreq=256ms
...    LNCEL-1/LNHOIF-1:eutraCarrierInfo=1500
...    LNCEL-1/LNHOIF-1:hysA3OffsetRsrpInterFreq=0
...    LNCEL-1/LNHOIF-1:hysThreshold3InterFreq=0
...    LNCEL-1/LNHOIF-1:iFGroupPrio=12
...    LNCEL-1/LNHOIF-1:interPresAntP=false
...    LNCEL-1/LNHOIF-1:measQuantInterFreq=rsrp
...    LNCEL-1/LNHOIF-1:measurementBandwidth=mbw50
...    LNCEL-1/LNHOIF-1:offsetFreqInter=0dB
...    LNCEL-1/LNHOIF-1:threshold3InterFreq=63
...    LNCEL-1/LNHOIF-1:threshold3InterFreqHpue=53
...    LNCEL-1/LNHOIF-1:threshold3InterFreqQci1=65
...    LNCEL-1/LNHOIF-1:threshold3aInterFreq=66
...    LNCEL-1/LNHOIF-1:threshold3aInterFreqHpue=26
...    LNCEL-1/LNHOIF-1:threshold3aInterFreqQci1=68
...    LNCEL-1/LNHOIF-1:thresholdRsrpIFLBFilter=-98
...    LNCEL-1/LNHOIF-1:thresholdRsrpIFSBFilter=-98
...    LNCEL-1/LNHOIF-1:thresholdRsrqIFLBFilter=-120
...    LNCEL-1/LNHOIF-1:thresholdRsrqIFSBFilter=-120
@{PARAMS_IFHO_Neighbor_Cell_2}
...    LNCEL-2/LNHOIF-1:a3OffsetRsrpInterFreq=8
...    LNCEL-2/LNHOIF-1:a3OffsetRsrpInterFreqHpue=6
...    LNCEL-2/LNHOIF-1:a3OffsetRsrpInterFreqQci1=8
...    LNCEL-2/LNHOIF-1:a3ReportIntervalRsrpInterFreq=240ms
...    LNCEL-2/LNHOIF-1:a3TimeToTriggerRsrpInterFreq=320ms
...    LNCEL-2/LNHOIF-1:a5ReportIntervalInterFreq=240ms
...    LNCEL-2/LNHOIF-1:a5TimeToTriggerInterFreq=256ms
...    LNCEL-2/LNHOIF-1:eutraCarrierInfo=1300
...    LNCEL-2/LNHOIF-1:hysA3OffsetRsrpInterFreq=0
...    LNCEL-2/LNHOIF-1:hysThreshold3InterFreq=0
...    LNCEL-2/LNHOIF-1:iFGroupPrio=12
...    LNCEL-2/LNHOIF-1:interPresAntP=false
...    LNCEL-2/LNHOIF-1:measQuantInterFreq=rsrp
...    LNCEL-2/LNHOIF-1:measurementBandwidth=mbw50
...    LNCEL-2/LNHOIF-1:offsetFreqInter=0dB
...    LNCEL-2/LNHOIF-1:threshold3InterFreq=62
...    LNCEL-2/LNHOIF-1:threshold3InterFreqHpue=54
...    LNCEL-2/LNHOIF-1:threshold3InterFreqQci1=64
...    LNCEL-2/LNHOIF-1:threshold3aInterFreq=65
...    LNCEL-2/LNHOIF-1:threshold3aInterFreqHpue=26
...    LNCEL-2/LNHOIF-1:threshold3aInterFreqQci1=67
...    LNCEL-2/LNHOIF-1:thresholdRsrpIFLBFilter=-98
...    LNCEL-2/LNHOIF-1:thresholdRsrpIFSBFilter=-98
...    LNCEL-2/LNHOIF-1:thresholdRsrqIFLBFilter=-120
...    LNCEL-2/LNHOIF-1:thresholdRsrqIFSBFilter=-120
...    LNCEL-2/LNHOIF-2:a3OffsetRsrpInterFreq=8
...    LNCEL-2/LNHOIF-2:a3OffsetRsrpInterFreqHpue=6
...    LNCEL-2/LNHOIF-2:a3OffsetRsrpInterFreqQci1=2
...    LNCEL-2/LNHOIF-2:a3ReportIntervalRsrpInterFreq=240ms
...    LNCEL-2/LNHOIF-2:a3TimeToTriggerRsrpInterFreq=320ms
...    LNCEL-2/LNHOIF-2:a5ReportIntervalInterFreq=240ms
...    LNCEL-2/LNHOIF-2:a5TimeToTriggerInterFreq=256ms
...    LNCEL-2/LNHOIF-2:eutraCarrierInfo=1500
...    LNCEL-2/LNHOIF-2:hysA3OffsetRsrpInterFreq=0
...    LNCEL-2/LNHOIF-2:hysThreshold3InterFreq=0
...    LNCEL-2/LNHOIF-2:iFGroupPrio=12
...    LNCEL-2/LNHOIF-2:interPresAntP=false
...    LNCEL-2/LNHOIF-2:measQuantInterFreq=rsrp
...    LNCEL-2/LNHOIF-2:measurementBandwidth=mbw50
...    LNCEL-2/LNHOIF-2:offsetFreqInter=0dB
...    LNCEL-2/LNHOIF-2:threshold3InterFreq=63
...    LNCEL-2/LNHOIF-2:threshold3InterFreqHpue=54
...    LNCEL-2/LNHOIF-2:threshold3InterFreqQci1=66
...    LNCEL-2/LNHOIF-2:threshold3aInterFreq=64
...    LNCEL-2/LNHOIF-2:threshold3aInterFreqHpue=26
...    LNCEL-2/LNHOIF-2:threshold3aInterFreqQci1=67
...    LNCEL-2/LNHOIF-2:thresholdRsrpIFLBFilter=-98
...    LNCEL-2/LNHOIF-2:thresholdRsrpIFSBFilter=-98
...    LNCEL-2/LNHOIF-2:thresholdRsrqIFLBFilter=-120
...    LNCEL-2/LNHOIF-2:thresholdRsrqIFSBFilter=-120
${UE_R11}
...    CD9FF4F9B2E7500010610102912464D0312040E07FFFFFFFFCA18800182008295020022A0060B3FFFFFFFE014FFFFFFFFC

*** Test Cases ***
V_LTE64_005_4_Reestablishment_To_Serving_Cell
    [Documentation]    | VoLTE mobility thresholds re-configuration other cases |
    ...    QCI1 bearer and re-establishment cell1
    [Tags]    RAN_4G    RAN_4G_FDD    CDRT    V_LTE64_005_4
    CUS UE Attach To ENB
    Trigger A2 Event_RSRP below threshold2
    QCI1 Setup
    Reestablish To Cell
    QCI1 Release
    Trigger A1 event_RSRP above threshold2a

*** Keywords ***
Common Suite Setup And Setup CUS Env
    Common Suite Setup
    Setup CUS Env    tl_type=3CELLs_FDD
    Create UE Alias    UE_1    ue_id=1    id_type=cus

CUS UE Attach To ENB
    ${attach}    catenate
    ...    measConfig contains (
    ...    measObjectToAddModList contains (measObjectId eq 1 and carrierFreq eq 1400)
    ...    and
    ...    reportConfigToAddModList contains (
    ...    (reportConfigId eq 1 and reportConfigEUTRA contains (eventA3 contains (a3-Offset eq 10))),
    ...    (reportConfigId eq 2 and reportConfigEUTRA contains (eventA5 contains
    ...    (a5-Threshold1 contains (threshold-RSRP eq 55) and a5-Threshold2 contains (threshold-RSRP eq 56)))),
    ...    (reportConfigId eq 3 and reportConfigEUTRA contains (eventA2 contains (a2-Threshold contains (threshold-RSRP eq 52)))),
    ...    (reportConfigId eq 4 and reportConfigEUTRA contains (eventA2 contains (a2-Threshold contains (threshold-RSRP eq 61)))),
    ...    (reportConfigId eq 5 and reportConfigEUTRA contains (eventA2 contains (a2-Threshold contains (threshold-RSRQ eq 10)))))
    ...    and
    ...    measIdToAddModList contains (
    ...    (measId eq 1 and measObjectId eq 1 and reportConfigId eq 1),
    ...    (measId eq 2 and measObjectId eq 1 and reportConfigId eq 2),
    ...    (measId eq 4 and measObjectId eq 1 and reportConfigId eq 3),
    ...    (measId eq 7 and measObjectId eq 1 and reportConfigId eq 4),
    ...    (measId eq 12 and measObjectId eq 1 and reportConfigId eq 5))
    ...    )
    Expect Message Flow
    ...    UE_1:RRC_RRCConnectionReconfiguration (${attach})
    ...    alias=attach    overall_timeout=30
    Execute Uex Command    ue_attach id=1 enb=1 cell=1 ue_eutra_capabilities=${UE_R11}
    Flow Occurred As Expected    alias=attach

Trigger A2 Event_RSRP below threshold2
    ${A2}    catenate
    ...    measConfig contains (
    ...    measObjectToAddModList contains ((measObjectId eq 2 and carrierFreq eq 1500),(measObjectId eq 3 and carrierFreq eq 10600))
    ...    and
    ...    reportConfigToAddModList contains (
    ...    (reportConfigId eq 6 and reportConfigEUTRA contains (eventA1 contains (a1-Threshold contains (threshold-RSRP eq 67)))),
    ...    (reportConfigId eq 7 and reportConfigEUTRA contains (eventA2 contains (a2-Threshold contains (threshold-RSRP eq 55)))),
    ...    (reportConfigId eq 8 and reportConfigEUTRA contains (eventA3 contains (a3-Offset eq 10))),
    ...    (reportConfigId eq 9 and reportConfigEUTRA contains (eventA5 contains
    ...    (a5-Threshold1 contains (threshold-RSRP eq 63) and a5-Threshold2 contains (threshold-RSRP eq 66)))),
    ...    (reportConfigId eq 10 and reportConfigInterRAT contains (eventB2 contains
    ...    (b2-Threshold1 contains (threshold-RSRP eq 56) and b2-Threshold2 contains (b2-Threshold2UTRA contains (utra-RSCP eq 8))))))
    ...    and
    ...    measIdToRemoveList contains (7)
    ...    and
    ...    measIdToAddModList contains (
    ...    (measId eq 5 and measObjectId eq 1 and reportConfigId eq 6),
    ...    (measId eq 8 and measObjectId eq 1 and reportConfigId eq 7),
    ...    (measId eq 14 and measObjectId eq 2 and reportConfigId eq 8),
    ...    (measId eq 15 and measObjectId eq 2 and reportConfigId eq 9),
    ...    (measId eq 16 and measObjectId eq 3 and reportConfigId eq 10))
    ...    )
    Expect Message Flow
    ...    UE_1:RRC_RRCConnectionReconfiguration (${A2})
    ...    alias=A2    overall_timeout=30
    Execute Uex Command    ue_measurement_send id=1 event=A2 srsrp=57 srsrq=31 meas_id_blacklist=4,12
    Flow Occurred As Expected    alias=A2

QCI1 Setup
    ${QCI1}    catenate
    ...    measConfig contains (
    ...    reportConfigToAddModList contains (
    ...    (reportConfigId eq 11 and reportConfigInterRAT contains (eventB2 contains
    ...    (b2-Threshold1 contains (threshold-RSRP eq 57) and b2-Threshold2 contains (b2-Threshold2UTRA contains (utra-RSCP eq 13))))),
    ...    (reportConfigId eq 12 and reportConfigEUTRA contains (eventA1 contains (a1-Threshold contains (threshold-RSRP eq 70)))),
    ...    (reportConfigId eq 13 and reportConfigEUTRA contains (eventA3 contains (a3-Offset eq 6))),
    ...    (reportConfigId eq 14 and reportConfigEUTRA contains (eventA5 contains
    ...    (a5-Threshold1 contains (threshold-RSRP eq 65) and a5-Threshold2 contains (threshold-RSRP eq 68)))))
    ...    and
    ...    measIdToRemoveList contains (16,5,14,15)
    ...    and
    ...    measIdToAddModList contains (
    ...    (measId eq 16 and measObjectId eq 3 and reportConfigId eq 11),
    ...    (measId eq 5 and measObjectId eq 1 and reportConfigId eq 12),
    ...    (measId eq 14 and measObjectId eq 2 and reportConfigId eq 13),
    ...    (measId eq 15 and measObjectId eq 2 and reportConfigId eq 14))
    ...    )
    Expect Message Flow
    ...    UE_1:RRC_RRCConnectionReconfiguration (${QCI1})
    ...    alias=QCI1    overall_timeout=30
    execute uex command    bearer_add ue=1 qci=1 mbr_ul=25 mbr_dl=25 gbr_ul=25 gbr_dl=25
    Flow Occurred As Expected    alias=QCI1

Reestablish To Cell
    ${RCR}    catenate
    ...    measConfig contains (
    ...    measIdToRemoveList contains (1,2,3,4,5,6,7,8,9,10,11,12,13,14,15,16,17,18,19,20,21,22,23,24,25,26,27,28,29,30,31,32)
    ...    and
    ...    measIdToAddModList contains (
    ...    (measId eq 1 and measObjectId eq 1 and reportConfigId eq 1),
    ...    (measId eq 2 and measObjectId eq 1 and reportConfigId eq 2),
    ...    (measId eq 4 and measObjectId eq 1 and reportConfigId eq 3),
    ...    (measId eq 5 and measObjectId eq 1 and reportConfigId eq 12),
    ...    (measId eq 12 and measObjectId eq 1 and reportConfigId eq 5),
    ...    (measId eq 8 and measObjectId eq 1 and reportConfigId eq 7),
    ...    (measId eq 14 and measObjectId eq 2 and reportConfigId eq 13),
    ...    (measId eq 15 and measObjectId eq 2 and reportConfigId eq 14),
    ...    (measId eq 16 and measObjectId eq 3 and reportConfigId eq 11))
    ...    )
    Expect Message Flow
    ...    UE_1:RRC_RRCConnectionReestablishmentRequest
    ...    UE_1:RRC_RRCConnectionReestablishmentComplete
    ...    UE_1:RRC_RRCConnectionReconfiguration (${RCR})
    ...    alias=RCR    overall_timeout=30
    Execute Uex Command    ue_rrc_reestablish id=1 enb=1 cell=1
    Flow Occurred As Expected    alias=RCR

QCI1 Release
    ${QCI1_release}    catenate
    ...    measConfig contains (
    ...    measIdToRemoveList contains (16,5,14,15)
    ...    and
    ...    measIdToAddModList contains (
    ...    (measId eq 16 and measObjectId eq 3 and reportConfigId eq 10),
    ...    (measId eq 5 and measObjectId eq 1 and reportConfigId eq 6),
    ...    (measId eq 14 and measObjectId eq 2 and reportConfigId eq 8),
    ...    (measId eq 15 and measObjectId eq 2 and reportConfigId eq 9))
    ...    )
    ...    and
    ...    drb-ToReleaseList contains (5)
    Expect Message Flow
    ...    UE_1:RRC_RRCConnectionReconfiguration (${QCI1_release})
    ...    alias=QCI1_release    overall_timeout=30
    execute uex command    bearer_del ue=1 qci=1
    Flow Occurred As Expected    alias=QCI1_release

Trigger A1 event_RSRP above threshold2a
    ${A1}    catenate
    ...    measConfig contains (
    ...    measIdToRemoveList contains (5,8,16,15,14)
    ...    and
    ...    measIdToAddModList contains (measId eq 7 and measObjectId eq 1 and reportConfigId eq 4)
    ...    )
    Expect Message Flow
    ...    UE_1:RRC_RRCConnectionReconfiguration (${A1})
    ...    alias=A1    overall_timeout=30
    Execute Uex Command    ue_measurement_send id=1 event=A1 srsrp=72 srsrq=32
    Flow Occurred As Expected    alias=A1