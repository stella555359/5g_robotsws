*** Settings ***
Suite Setup       Common Suite Setup And Setup Cus Env
Suite Teardown    Common Suite Teardown And Restore BTS Configuration Parameters
Test Setup        Common Test Setup And Start To Capture Logs
Test Teardown     Common Test Teardown And Stop Capture Logs
Force Tags        QCD_MN_RAN    QCP_RAN_ET    SBTS00    4G_TDD    RAN_4G    RAN_4G_TDD    CIT
...               CLOUD_R4LAPO_CUS    release-RL45    owner-chendong.he    DevHZ5_SG4
Resource          ../../../resources/DevHZ5_resource.robot

*** Variables ***
@{PARAMS_IN_SCF}
...  LNCEL-1:enableBetterCellHo=true
...  LNCEL-1/LNCEL_TDD-0:earfcn=38000
...  LNCEL-2/LNCEL_TDD-0:earfcn=38000
...  LNCEL-1:actDrx=false
...  MODPR-0:autoAdapt=true
...  LNBTS-1:actLTES1Ho=true
...  LNBTS-1:actSelMobPrf=false
...  @{Anr_profile_cfg}
...  @{Delete Neighbour Relation}
...  @{Add_Blacklist}
...  @{Anr_feature_enable}
...  @{threshold_parameter1}
...  @{other_feature_enable}
...  @{other_WCDMA_relationship}
...  LNBTS-1/ANR-0:anrIfTRSC=8000
@{Delete Neighbour Relation}
...  delete:LNADJ.*
...  delete:LNREL.*
@{Anr_feature_enable}
...  LNBTS-1:actUeBasedAnrInterFreqLte=true
...  LNBTS-1:actUeBasedAnrIntraFreqLte=true
...  LNBTS-1:actIfHo=enabled
@{Add_Blacklist}
...  LNBTS-1/ANR-0:glbNbEnbIdX2LinkBlacklist:mcc=262|enbId=2
...  LNBTS-1/ANR-0:glbNbEnbIdX2LinkBlacklist:mcc=262|enbId=3
...  LNBTS-1/ANR-0:glbNbEnbIdX2LinkBlacklist:mcc=262|enbId=4
@{PARAMS_DISABLE_OTHER_ANR}
...  LNBTS-1:anrOmExtEnable=false
...  LNBTS-1:actUeBasedAnrUtran=false
...  LNBTS-1:actAnrRtt=false
@{Anr_profile_cfg}
...  ANRPRL-0:actAlsoForUeBasedANR=true
...  ANRPRL-0:anrThresRSRPNbCell=-90
...  ANRPRL-0:anrThresRSRPNbCellMobEv=-100
...  ANRPRL-0:anrThresRSRQNbCell=-24
...  ANRPRL-0:nrLimitInterFreq=16
...  ANRPRL-0:nrLimitIntraFreq=32
...  ANRPRL-1:actAlsoForUeBasedANR=true
...  ANRPRL-1:anrThresRSRPNbCell=-90
...  ANRPRL-1:anrThresRSRPNbCellMobEv=-100
...  ANRPRL-1:anrThresRSRQNbCell=-24
...  ANRPRL-1:nrLimitInterFreq=16
...  ANRPRL-1:nrLimitIntraFreq=32
...  ANRPRL-1:targetCarrierFreq=38000
...  ANRPRL-2:actAlsoForUeBasedANR=true
...  ANRPRL-2:anrThresRSRPNbCell=-90
...  ANRPRL-2:anrThresRSRPNbCellMobEv=-100
...  ANRPRL-2:anrThresRSRQNbCell=-24
...  ANRPRL-2:nrLimitInterFreq=16
...  ANRPRL-2:nrLimitIntraFreq=32
...  ANRPRL-2:targetCarrierFreq=38100
...  ANRPRL-3:actAlsoForUeBasedANR=true
...  ANRPRL-3:anrThresRSRPNbCell=-90
...  ANRPRL-3:anrThresRSRPNbCellMobEv=-100
...  ANRPRL-3:anrThresRSRQNbCell=-24
...  ANRPRL-3:nrLimitInterFreq=16
...  ANRPRL-3:nrLimitIntraFreq=32
...  ANRPRL-3:targetCarrierFreq=37900
${ue_capabilities}    CD9FF439B2E750040E07FFFFFFFFCA20804184100414A8100115003059FFFFFFFF00A7FFFFFFFE
@{threshold_parameter1}
...  LNCEL-1:threshold2InterFreq=65
...  LNCEL-1:threshold2Wcdma=65
...  LNCEL-1:threshold2aHpue=65
...  LNCEL-1:threshold2a=66
@{other_feature_enable}
...  LNBTS-1:actRedirect=enabled
...  LNCEL-1/REDRT-0:addGsmSIToRedirMsg=both
...  LNCEL-1/REDRT-0:addUtranSIToRedirMsg=both
...  LNCEL-1/REDRT-0:csFallBPrio=1
...  LNCEL-1/REDRT-0:emerCallPrio=3
...  LNCEL-1/REDRT-0:redirFreqUtra=10562
...  LNCEL-1/REDRT-0:redirRat=utraFDD
...  LNCEL-1/REDRT-0:redirectPrio=4
...  LNCEL-1/REDRT-1:addGsmSIToRedirMsg=both
...  LNCEL-1/REDRT-1:addUtranSIToRedirMsg=both
...  LNCEL-1/REDRT-1:csFallBPrio=2
...  LNCEL-1/REDRT-1:emerCallPrio=2
...  LNCEL-1/REDRT-1:redirFreqUtra=10572
...  LNCEL-1/REDRT-1:redirRat=utraFDD
...  LNCEL-1/REDRT-1:redirectPrio=3
...  LNCEL-1/REDRT-2:addGsmSIToRedirMsg=both
...  LNCEL-1/REDRT-2:addUtranSIToRedirMsg=both
...  LNCEL-1/REDRT-2:csFallBPrio=3
...  LNCEL-1/REDRT-2:emerCallPrio=1
...  LNCEL-1/REDRT-2:redirGeranArfcnStructL:redirGeranArfcnValue=680
...  LNCEL-1/REDRT-2:redirGeranBandIndicator=gsm1800
...  LNCEL-1/REDRT-2:redirectPrio=2
...  LNCEL-1/REDRT-3:addGsmSIToRedirMsg=both
...  LNCEL-1/REDRT-3:addUtranSIToRedirMsg=both
...  LNCEL-1/REDRT-3:redirFreqEutra=1500
...  LNCEL-1/REDRT-3:redirRat=eutra
...  LNCEL-1/REDRT-3:redirectPrio=1
...  LNCEL-1/REDRT-3:emerCallPrio=
...  LNCEL-1/REDRT-3:csFallBPrio=
...  LNCEL-1:rsrqRedirectParams:hysThreshold4Rsrq=0
...  LNCEL-1:rsrqRedirectParams:threshold4Rsrq=-38
...  LNCEL-1:rsrqRedirectParams:a2TimeToTriggerRedirectRsrq=480ms
...  LNCEL-1:rsrqMobilityParams:a1ReportInterval=1024ms
...  LNCEL-1:rsrqMobilityParams:a2TimeToTriggerMobRsrq=480ms
...  LNCEL-1:rsrqMobilityParams:hysThreshold2MobRsrq=0
...  LNCEL-1:rsrqMobilityParams:threshold2MobRsrq=20
...  LNCEL-1:rsrqMobilityParams:threshold2aRsrq=30
...  LNCEL-1:actSixIfMeasurements=true
...  LNCEL-1/LNHOIF-1:eutraCarrierInfo=38100
...  LNCEL-1/LNHOIF-2:eutraCarrierInfo=37940
...  LNCEL-1/LNHOIF-3:eutraCarrierInfo=37900
...  LNCEL-1/LNHOIF-4:eutraCarrierInfo=37910
...  LNCEL-1/LNHOIF-5:eutraCarrierInfo=37920
...  LNCEL-1/LNHOIF-6:eutraCarrierInfo=37930
...  LNCEL-1/LNHOIF-1:measQuantInterFreq=both
...  LNCEL-1/LNHOIF-2:measQuantInterFreq=both
...  LNCEL-1/LNHOIF-3:measQuantInterFreq=both
...  LNCEL-1/LNHOIF-4:measQuantInterFreq=both
...  LNCEL-1/LNHOIF-5:measQuantInterFreq=both
...  LNCEL-1/LNHOIF-6:measQuantInterFreq=both
...  LNCEL-1:actInterFreqLB=true
...  LNBTS-1:qciTab5:schedulWeight=100
...  LNCEL-1:loadSettings:mlbEicicOperMode=allUes
...  LNCEL-1:loadSettings:nomNumPrbNonGbr=10
...  LNCEL-1:loadSettings:targetLoadGbrDl=1
...  LNCEL-1:loadSettings:targetLoadNonGbrDl=1
...  LNCEL-1:loadSettings:targetLoadPdcch=1
...  LNCEL-1:iFLBLoadThresholds:iFLBHighLoadGBRDL=1
...  LNCEL-1:iFLBLoadThresholds:iFLBHighLoadNonGBRDL=1
...  LNCEL-1:iFLBLoadThresholds:iFLBHighLoadPdcch=1
...  LNCEL-1:iFLBLoadThresholds:iFLBBearCheckTimer=10
...  LNCEL-1:iFLBLoadThresholds:iFLBRetryTimer=60
...  LNCEL-1:intraFreqLbLoadThresholds:hysteresisLoadDlGbr=0
...  LNCEL-1:intraFreqLbLoadThresholds:hysteresisLoadDlNonGbr=0
...  LNCEL-1:intraFreqLbLoadThresholds:hysteresisLoadPdcch=0
...  LNCEL-1/LNCEL_TDD-0:maxNrSymPdcch=1
...  LNBTS-1:actRsrqInterRatMobility=true
...  LNCEL-1/LNHOW-1:utraCarrierFreq=1500
...  LNBTS-1:actHOtoWcdma=true
...  LNCEL-1/LNHOW-1:b2Threshold1Utra=40
...  LNCEL-1/LNHOW-1:b2Threshold2UtraRscp=-5
...  LNADJW-0:uTargetScFdd=222
...  LNADJW-0:uTargetCid=222
...  LNADJW-0:uTargetFreq=1500
...  LNADJW-0:uTargetRncId=222
...  LNADJW-0:uTargetLac=124
...  LNADJW-0:uTargetRac=111
...  LNCEL-1/LNRELW-0:uTargetCid=222
...  LNCEL-1/LNRELW-0:uTargetRncId=222
...  LNCEL-1/LNRELW-0:removeAllowed=true
...  LNCEL-1/LNRELW-0:plmnId:mcc=262
...  LNCEL-1/LNRELW-0:plmnId:mnc=3
...  LNCEL-1/LNRELW-0:plmnId:mncLength=2
...  LNBTS-1:actRsrqInterFreqMobility=true
@{other_WCDMA_relationship}
...  LNCEL-1/LNHOW-2:utraCarrierFreq=1499
...  LNCEL-1/LNHOW-2:b2Threshold1Utra=40
...  LNCEL-1/LNHOW-2:b2Threshold2UtraRscp=-5
...  LNADJW-1:uTargetScFdd=223
...  LNADJW-1:uTargetCid=223
...  LNADJW-1:uTargetFreq=1499
...  LNADJW-1:uTargetRncId=223
...  LNADJW-1:uTargetLac=123
...  LNADJW-1:uTargetRac=111
...  LNCEL-1/LNRELW-1:uTargetCid=223
...  LNCEL-1/LNRELW-1:uTargetRncId=223
...  LNCEL-1/LNRELW-1:removeAllowed=true
...  LNCEL-1/LNRELW-1:plmnId:mcc=262
...  LNCEL-1/LNRELW-1:plmnId:mnc=3
...  LNCEL-1/LNRELW-1:plmnId:mncLength=2
...  LNCEL-1/LNHOW-3:utraCarrierFreq=1498
...  LNCEL-1/LNHOW-3:b2Threshold1Utra=40
...  LNCEL-1/LNHOW-3:b2Threshold2UtraRscp=-5
...  LNADJW-2:uTargetScFdd=224
...  LNADJW-2:uTargetCid=224
...  LNADJW-2:uTargetFreq=1498
...  LNADJW-2:uTargetRncId=224
...  LNADJW-2:uTargetLac=124
...  LNADJW-2:uTargetRac=111
...  LNCEL-1/LNRELW-2:uTargetCid=224
...  LNCEL-1/LNRELW-2:uTargetRncId=224
...  LNCEL-1/LNRELW-2:removeAllowed=true
...  LNCEL-1/LNRELW-2:plmnId:mcc=262
...  LNCEL-1/LNRELW-2:plmnId:mnc=3
...  LNCEL-1/LNRELW-2:plmnId:mncLength=2
...  LNCEL-1/LNHOW-4:utraCarrierFreq=1497
...  LNCEL-1/LNHOW-4:b2Threshold1Utra=40
...  LNCEL-1/LNHOW-4:b2Threshold2UtraRscp=-5
...  LNADJW-3:uTargetScFdd=225
...  LNADJW-3:uTargetCid=225
...  LNADJW-3:uTargetFreq=1497
...  LNADJW-3:uTargetRncId=225
...  LNADJW-3:uTargetLac=124
...  LNADJW-3:uTargetRac=111
...  LNCEL-1/LNRELW-3:uTargetCid=225
...  LNCEL-1/LNRELW-3:uTargetRncId=225
...  LNCEL-1/LNRELW-3:removeAllowed=true
...  LNCEL-1/LNRELW-3:plmnId:mcc=262
...  LNCEL-1/LNRELW-3:plmnId:mnc=3
...  LNCEL-1/LNRELW-3:plmnId:mncLength=2

*** Test Cases ***
Instance1
    [Tags]
    Cus UE attach to eNB1    ue_eutra_capabilities=${ue_capabilities}
    Cus Report Inter-freq A2

*** Keywords ***
Common Suite Setup And Setup CUS Env
    Common Suite Setup
    Setup Cus Env    tl_type=3CELLs    ue_count=10
    #Debug Enter Into Egate
    Create Alias

Create Alias
    Create UE Alias    UE_1    ue_id=1    id_type=cus

Cus UE attach to eNB1
    [Arguments]    ${ueid}=1    ${cellid}=1    ${ue_eutra_capabilities}=${ue_eutra_capabilities}    ${sleeptime}=0
    Execute Uex Command    ue_param id=${ueid} csfb_rat=utran_geran voice_domain_preference=lte_preferred
    Execute Uex Command    ue_param id=${ueid} ue_eutra_capabilities=${ue_eutra_capabilities}
    Execute Uex Command    ue_attach id=${ueid} cell=${cellid} selected_plmn=262:03
    sleep    ${sleeptime}

Cus Report Inter-freq A2
    ${measure_check}    catenate
    ...    measObjectUTRA contains (carrierFreq eq 1500) and
    ...    measIdToAddModList contains ( measId eq 14) and
    ...    measIdToAddModList contains ( measId eq 15) and
    ...    measIdToAddModList contains ( measId eq 16) and
    ...    measIdToAddModList contains ( measId eq 17) and
    ...    measIdToAddModList contains ( measId eq 18) and
    ...    measIdToAddModList contains ( measId eq 19) and
    ...    measIdToAddModList contains ( measId eq 20) and
    ...    measIdToAddModList contains ( measId eq 21) and
    ...    measIdToAddModList contains ( measId eq 22) and
    ...    measIdToAddModList contains ( measId eq 23) and
    ...    measIdToAddModList contains ( measId eq 24) and
    ...    measIdToAddModList contains ( measId eq 25) and
    ...    measIdToAddModList contains ( measId eq 26) and
    ...    measIdToAddModList contains ( measId eq 27) and
    ...    measIdToAddModList contains ( measId eq 28) and
    ...    measIdToAddModList contains ( measId eq 29) and
    ...    measIdToAddModList contains ( measId eq 30) and
    ...    measIdToAddModList contains ( measId eq 31) and
    ...    measIdToAddModList contains ( measId eq 32)
    ${measure_not_check}    catenate
    ...    measIdToAddModList contains ( measId eq 1) or
    ...    measIdToAddModList contains ( measId eq 2) or
    ...    measIdToAddModList contains ( measId eq 3) or
    ...    measIdToAddModList contains ( measId eq 33)
    Expect Message Flow
    ...    UE_1:RRC_RRCConnectionReconfiguration ( ${measure_check} )
    ...    alias=LTE556_flow1    overall_timeout=60
    Expect Message Will Not Occur
    ...    UE_1:RRC_RRCConnectionReconfiguration ( ${measure_not_check} )
    ...    alias=LTE556_flow2    overall_timeout=60
    Execute Uex Command    ue_measurement_send id=1 event=A2 srsrp=30 srsrq=15 meas_id_blacklist=4,12
    Flow Occurred As Expected    alias=LTE556_flow1
    Flow Not Occurred For Message    alias=LTE556_flow2