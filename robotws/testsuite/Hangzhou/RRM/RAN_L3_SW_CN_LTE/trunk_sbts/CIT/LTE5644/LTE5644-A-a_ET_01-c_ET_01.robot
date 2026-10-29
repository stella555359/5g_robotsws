*** Settings ***
Suite Setup       Setup CUS Env And Common Suite Setup
Suite Teardown    Common Suite Teardown And Restore BTS Configuration Parameters
Test Setup        Common Test Setup And Start To Capture Logs
Test Teardown     Common Test Teardown And Stop Capture Logs
Force Tags        QCD_MN_RAN    QCP_RAN_ET    SBTS00    4G_TDD    RAN_4G    RAN_4G_TDD    CIT
...                 CLOUD_R4LAPO_CUS    team-CN3ET    owner-lixia.zhou,annie.nie    release-SBTS20C
Resource          ../../../resources/DevHZ5_resource.robot

*** Variables ***
@{PARAMS_IN_SCF}
...    @{PARAMS_COMMON}
...    @{PARAMS_HO}
...    @{AMLE_ENABLE}
...    @{LTE5644_ENABLE}
@{PARAMS_COMMON}
...    LNCEL:actTtiBundling=false
...    LNCEL:inactivityTimer=1000
...    LNCEL:actModulationSchemeDl=64QAM
...    LNCEL:actModulationSchemeUL=16QAMHighMCS
...    LNCEL-1:loadSettings:nomNumPrbNonGbr=10
...    LNBTS-1:qciTab5:schedulWeight=5
...    LNCEL/LNCEL_TDD-0:tddFrameConf=1
...    LNCEL/LNCEL_TDD-0:tddSpecSubfConf=7
...    LNCEL/LNCEL_TDD-0:actTmSwitch=false
...    LNBTS/MODPR-0:autoAdapt=true
...    LNCEL-1/LNCEL_TDD-0:earfcn=38100
...    LNCEL-2/LNCEL_TDD-0:earfcn=38000
...    LNCEL-1/LNREL-1:ecgiLcrId=2
...    LNCEL-1/LNREL-1:ecgiAdjEnbId=1
...    LNCEL-2/LNREL-1:ecgiLcrId=1
...    LNCEL-2/LNREL-1:ecgiAdjEnbId=1
...    LNCEL-1/LNREL-1:cellIndOffNeigh=0dB
...    LNCEL-1/LNREL-1:nrControl=automatic
...    LNCEL-1/LNREL-1:removeAllowed=false
...    LNCEL-1/LNREL-1:handoverAllowed=allowed
...    LNCEL-1/LNREL-1:ecgiPlmnId:mcc=262
...    LNCEL-1/LNREL-1:ecgiPlmnId:mnc=3
...    LNCEL-1/LNREL-1:ecgiPlmnId:mncLength=2
...    LNCEL-1/LNREL-1:amleAllowed=false
...    LNCEL-1:iFLBLoadThresholds:iFLBHighLoadGBRDL=60
...    LNCEL-1:iFLBLoadThresholds:iFLBHighLoadNonGBRDL=60
...    LNCEL-1:iFLBLoadThresholds:iFLBHighLoadPdcch=1
...    LNCEL-1:iFLBLoadThresholds:iFLBBearCheckTimer=12
...    LNCEL-1:loadSettings:cellCapClass=100
...    LNCEL-1:loadSettings:mlbEicicOperMode=allUes
...    LNCEL-1:loadSettings:targetLoadGbrDl=40
...    LNCEL-1:loadSettings:targetLoadNonGbrDl=40
...    LNCEL-1:loadSettings:targetLoadPdcch=1
...    LNCEL-1:loadSettings:ulCacSelection=ulReflectDlCac
...    LNCEL-1:intraFreqLbLoadThresholds:highLoadGbrDl=60
...    LNCEL-1:intraFreqLbLoadThresholds:highLoadNonGbrDl=60
...    LNCEL-1:intraFreqLbLoadThresholds:highLoadPdcch=60
...    LNCEL-2:iFLBA4ActLim=20
...    LNCEL-2:actServRlqInterFreqLB=true
...    LNCEL-2/LNHOIF-1:thresholdRsrpServIFLBFilter=-120
...    LNCEL-2/LNHOIF-1:thresholdRsrqServIFLBFilter=-150
@{PARAMS_HO}
...    LNBTS:actIfHo=enabled
...    LNCEL:enableBetterCellHo=true
...    LNCEL:enableCovHo=true
...    LNCEL-1/LNHOIF-1:eutraCarrierInfo=38000
...    LNCEL-1:actServRlqInterFreqLB=true
...    LNCEL-1/LNHOIF-1:thresholdRsrpServIFLBFilter=-120
...    LNCEL-1/LNHOIF-1:thresholdRsrqServIFLBFilter=-150
...    LNCEL-1:actInterFreqLB=true
...    LNCEL-1:actAmle=false
...    LNCEL-1:iFLBA4ActLim=20
...    LNCEL-1/LNHOIF-1:thresholdRsrqIFLBFilter=-140
...    LNCEL-1/LNHOIF-1:thresholdRsrpIFLBFilter=-100
...    LNCEL-1/AMLEPR-0:deltaCac=20
...    LNCEL-1/AMLEPR-0:cacHeadroom=10
...    LNCEL-1/AMLEPR-0:targetCarrierFreq=38000
...    LNCEL-1/AMLEPR-0:maxCacThreshold=80
...    LNCEL-1:iFLBLoadThresholds:iFLBRetryTimer=10
...    LNCEL-1/LNREL-1:amleAllowed=true
...    LNCEL-2/LNHOIF-1:offsetRsrpServIFLBFilter=15
...    LNCEL-2/LNHOIF-1:offsetRsrqServIFLBFilter=20
@{PARAMS_IN_VENDOR}
...    LNBTS:reportTimerIFLBA4=5000ms
@{AMLE_ENABLE}
...    LNCEL-1:actAmle=true
...    LNCEL-1:actInterFreqLB=false
...    LNCEL-2:actAmle=true
...    LNCEL-2:actInterFreqLB=false
@{LTE5644_ENABLE}
...    LNCEL/LNCEL_TDD-0:actServRlqTputInterFreqLB=true
...    LNCEL/LNCEL_TDD-0:dlUserTputThrInterFreqLB=${dlUserTputThrInterFreqLB}
...    LNCEL-1/LNHOIF-1:offsetRsrpServIFLBFilter=15
...    LNCEL-1/LNHOIF-1:offsetRsrqServIFLBFilter=20
@{LTE5644_DISABLE}
...    LNCEL/LNCEL_TDD-0:actServRlqTputInterFreqLB=false
${dlUserTputThrInterFreqLB}    9000
${A4_event}
...    eventId contains ("eventA4") and a4-Threshold contains (threshold-RSRP eq 0)
...    and
...    measIdToAddModList contains (measId eq 31 and measObjectId eq 2 and reportConfigId eq 5 )
${handover}
...    mobilityControlInfo contains (targetPhysCellId eq 2 and carrierFreq contains (dl-CarrierFreq eq 38000))
*** Test Cases ***
LTE5644-A-a_ET_01_01_Activation and Deactivation of LTE5644 feature
    [Tags]
    Disable LTE5644 feature
    UEs Attach and Start Traffic to Enter High Load With Ave Tput Smaller Than dlUserTputThrInterFreqLB
    UE Send A4 MR And No Handover Perform Because sRSRP And sRSRQ Are Bigger Than Each Threshold
    release all ues
    Enable LTE5644 feature
    UEs Attach and Start Traffic to Enter High Load With Ave Tput Smaller Than dlUserTputThrInterFreqLB
    UE Send A4 MR And Perform Handover When sRSRP or sRSRQ Smaller Than Threshold
    [Teardown]    Case Teardown for Case1

*** Keywords ***
Setup CUS Env And Common Suite Setup
    Common Suite Setup
    Setup CUS Env    3CELLs
    Create Alias
    execute egate command    trace_sim on mme=1 protocol=s1
    execute egate command    trace uec=1 protocol=rrc on

Create Alias
    Create UE Alias    UE_1    ue_id=1    id_type=cus
    Create UE Alias    UE_2    ue_id=2    id_type=cus
    Create UE Alias    UE_3    ue_id=3    id_type=cus
    Create Enb Alias    ENB_1    enb_id=1    id_type=wts
    Create MME Alias    MME_1    mme_id=1    id_type=wts

Disable LTE5644 feature
    Delta Commission Parameters    ${LTE5644_DISABLE}

Enable LTE5644 feature
    Delta Commission Parameters    ${LTE5644_ENABLE}

UEs Attach and Start Traffic to Enter High Load With Ave Tput Smaller Than dlUserTputThrInterFreqLB
    FOR    ${ue_id}    IN RANGE    1    4
        expect message flow
        ...    UE_${ue_id}:RRC_RRCConnectionReconfigurationComplete
        ...    alias=UE${ue_id}_attach_flow     overall_timeout=20
    END
    execute uex command    ue_attach id=1-3 cell=1
    FOR    ${ue_id}    IN RANGE    1    4
        flow occurred as expected    alias=UE${ue_id}_attach_flow
    END
    Add Bearer With QCI567
    Start Traffic to Trigger A4 event
    ${res}    execute uex command    get_cell_stats id=1 type=dl_mac
    Should Be True    ${res["avg"]}/1000 < ${dlUserTputThrInterFreqLB}

Add Bearer With QCI567
    expect message flow
    ...    MME_1:S1AP_E-RABSetupRequest (E-RABToBeSetupItemBearerSUReq contains (e-RAB-ID eq 6 and e-RABlevelQoSParameters contains (qCI eq 5)))
    ...    MME_1:S1AP_E-RABSetupResponse
    ...    alias=qci5     overall_timeout=20
    execute uex command    bearer_add ue=1 qci=5
    flow occurred as expected    alias=qci5
    expect message flow
    ...    MME_1:S1AP_E-RABSetupRequest (E-RABToBeSetupItemBearerSUReq contains (e-RAB-ID eq 6 and e-RABlevelQoSParameters contains (qCI eq 6)))
    ...    MME_1:S1AP_E-RABSetupResponse
    ...    alias=qci6     overall_timeout=20
    execute uex command    bearer_add ue=2 qci=6
    flow occurred as expected      alias=qci6
    expect message flow
    ...    MME_1:S1AP_E-RABSetupRequest (E-RABToBeSetupItemBearerSUReq contains (e-RAB-ID eq 6 and e-RABlevelQoSParameters contains (qCI eq 7)))
    ...    MME_1:S1AP_E-RABSetupResponse
    ...    alias=qci7     overall_timeout=20
    execute uex command    bearer_add ue=3 qci=7
    flow occurred as expected      alias=qci7
Start Traffic to Trigger A4 event
    FOR    ${ue_id}    IN RANGE    1    4
        expect message flow
        ...    UE_${ue_id}:RRC_RRCConnectionReconfiguration (${A4_event})
        ...    UE_${ue_id}:RRC_RRCConnectionReconfigurationComplete
        ...    alias=ue${ue_id}_A4_event    overall_timeout=25
    END
    execute uex command    trf_data_start ue=${UE1} dir=dl protocol=udp Mbps=5
    execute uex command    trf_data_start ue=${UE2} dir=dl protocol=udp kbps=300
    execute uex command    trf_data_start ue=${UE3} dir=dl protocol=udp kbps=300
    FOR    ${ue_id}    IN RANGE    1    4
        flow occurred as expected    alias=ue${ue_id}_A4_event
    END

UE Send A4 MR And No Handover Perform Because sRSRP And sRSRQ Are Bigger Than Each Threshold
    expect message will not occur
    ...    UE_3:RRC_RRCConnectionReconfiguration (${handover})
    ...    alias=no_ho    overall_timeout=25
    execute uex command    ue_measurement_send id=${UE3} event=A4 srsrp=31 srsrq=21 phycell_id=2 nrsrp=85 nrsrq=34
    flow not occurred for message    alias=no_ho

UE Send A4 MR And Perform Handover When sRSRP or sRSRQ Smaller Than Threshold
    expect message flow
    ...    UE_3:RRC_RRCConnectionReconfiguration (${handover})
    ...    UE_3:RRC_RRCConnectionReconfigurationComplete
    ...    alias=ho_ok    overall_timeout=25
    execute uex command    ue_measurement_send id=${UE3} event=A4 srsrp=31 srsrq=21 phycell_id=2 nrsrp=85 nrsrq=34
    flow occurred as expected    alias=ho_ok

Case Teardown for Case1
    Run Keyword If Test Failed    Delta Commission Parameters    ${LTE5644_ENABLE}
    Common Test Teardown And Stop Capture Logs

