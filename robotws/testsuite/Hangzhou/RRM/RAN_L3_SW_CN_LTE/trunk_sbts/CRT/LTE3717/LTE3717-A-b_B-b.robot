*** Settings ***
Suite Setup       Common Suite Setup And Setup CUS Env
Suite Teardown    Common Suite Teardown And Restore BTS Configuration Parameters
Test Setup        Common Test Setup And Start To Capture Logs
Test Teardown     Common Test Teardown And Stop Capture Logs
Force Tags        QCD_MN_RAN    QCP_RAN_ET    SBTS00    RAN_4G    RAN_4G_TDD    CRT    CLOUD_R4LAPO_CUS
...                 release-SBTS19A    team-CN3ET    owner-lishuo.geng,annie.nie
Resource          ../../../resources/DevHZ5_resource.robot

*** Variables ***
@{PARAMS_IN_SCF}
...    @{Enable_Feature}
...    @{Cell1_Configuration}
...    @{Cell2_Configuration}
...    @{X2_LINK}
...    @{RELATION_ERROR}
@{RELATION_ERROR}
...    LNCEL:actServRlqInterFreqLB=false
...    LNCEL:iFLBA4ActLim=20
...    LNCEL:intraFreqLbLoadThresholds:highLoadNonGbrDl=60
...    LNCEL/LNCEL_TDD-0:actServRlqTputInterFreqLB=false
@{Enable_Feature}
...    LNCEL-1:actAmle=true
...    LNCEL-2:actAmle=true
...    LNCEL-1:actInterFreqLB=false
...    LNCEL-2:actInterFreqLB=false
...    LNBTS:actMultBearers=true
...    LNBTS/MODPR-0:autoAdapt=true
...    LNBTS:actIfHo=enabled
...    LNBTS:actSelMobPrf=false
...    LNBTS:actLTES1Ho=true
...    LNCEL-1/LNCEL_TDD-0:earfcn=38000
...    LNCEL-2/LNCEL_TDD-0:earfcn=38100
...    LNBTS-1:qciTab5:schedulWeight=5
...    LNCEL-1/LNHOIF-1:eutraCarrierInfo=38100
...    LNCEL-2/LNHOIF-1:eutraCarrierInfo=38000
@{Cell1_Configuration}
...    LNCEL-1/LNHOIF-1:thresholdRsrpIFLBFilter=-140
...    LNCEL-1/AMLEPR-0:deltaCac=1
...    LNCEL-1/AMLEPR-0:cacHeadroom=0
...    LNCEL-1/AMLEPR-0:targetCarrierFreq=38100
...    LNCEL-1/AMLEPR-0:maxCacThreshold=100
...    LNCEL-1:iFLBLoadThresholds:iFLBRetryTimer=10
...    LNCEL-1:iFLBLoadThresholds:iFLBHighLoadGBRDL=60
...    LNCEL-1:iFLBLoadThresholds:iFLBHighLoadNonGBRDL=60
...    LNCEL-1:iFLBLoadThresholds:iFLBHighLoadPdcch=60
...    LNCEL-1:iFLBLoadThresholds:iFLBBearCheckTimer=12
...    LNCEL-1:loadSettings:cellCapClass=100
...    LNCEL-1:loadSettings:mlbEicicOperMode=allUes
...    LNCEL-1:loadSettings:nomNumPrbNonGbr=10
...    LNCEL-1:loadSettings:targetLoadGbrDl=40
...    LNCEL-1:loadSettings:targetLoadNonGbrDl=40
...    LNCEL-1:loadSettings:targetLoadPdcch=55
...    LNCEL-1:loadSettings:ulCacSelection=ulReflectDlCac
...    LNCEL-1:intraFreqLbLoadThresholds:highLoadGbrDl=60
...    LNCEL-1:intraFreqLbLoadThresholds:highLoadNonGbrDl=60
...    LNCEL-1:intraFreqLbLoadThresholds:highLoadPdcch=60
...    LNCEL-1/LNREL-1:amleAllowed=true
...    LNCEL-1/LNREL-1:cellIndOffNeigh=0dB
...    LNCEL-1/LNREL-1:handoverAllowed=allowed
...    LNCEL-1/LNREL-1:ecgiLcrId=2
...    LNCEL-1/LNREL-1:ecgiAdjEnbId=1
...    LNCEL-1/LNREL-1:nrControl=automatic
...    LNCEL-1/LNREL-1:removeAllowed=false
...    LNCEL-1/LNREL-1:ecgiPlmnId:mcc=262
...    LNCEL-1/LNREL-1:ecgiPlmnId:mnc=3
...    LNCEL-1/LNREL-1:ecgiPlmnId:mncLength=2
@{Cell2_Configuration}
...    LNCEL-2/LNHOIF-1:thresholdRsrpIFLBFilter=-140
...    LNCEL-2/AMLEPR-0:deltaCac=1
...    LNCEL-2/AMLEPR-0:cacHeadroom=0
...    LNCEL-2/AMLEPR-0:targetCarrierFreq=38000
...    LNCEL-2/AMLEPR-0:maxCacThreshold=100
...    LNCEL-2:iFLBLoadThresholds:iFLBRetryTimer=60
...    LNCEL-2:iFLBLoadThresholds:iFLBHighLoadGBRDL=60
...    LNCEL-2:iFLBLoadThresholds:iFLBHighLoadNonGBRDL=60
...    LNCEL-2:iFLBLoadThresholds:iFLBHighLoadPdcch=60
...    LNCEL-2:iFLBLoadThresholds:iFLBBearCheckTimer=12
...    LNCEL-2:loadSettings:cellCapClass=100
...    LNCEL-2:loadSettings:mlbEicicOperMode=allUes
...    LNCEL-2:loadSettings:nomNumPrbNonGbr=5
...    LNCEL-2:loadSettings:targetLoadGbrDl=55
...    LNCEL-2:loadSettings:targetLoadNonGbrDl=60
...    LNCEL-2:loadSettings:targetLoadPdcch=55
...    LNCEL-2:loadSettings:ulCacSelection=ulReflectDlCac
...    LNCEL-2:intraFreqLbLoadThresholds:highLoadGbrDl=60
...    LNCEL-2:intraFreqLbLoadThresholds:highLoadNonGbrDl=60
...    LNCEL-2:intraFreqLbLoadThresholds:highLoadPdcch=60
...    LNCEL-2/LNREL-1:amleAllowed=true
...    LNCEL-2/LNREL-1:cellIndOffNeigh=0dB
...    LNCEL-2/LNREL-1:handoverAllowed=allowed
...    LNCEL-2/LNREL-1:ecgiLcrId=1
...    LNCEL-2/LNREL-1:ecgiAdjEnbId=1
...    LNCEL-2/LNREL-1:nrControl=automatic
...    LNCEL-2/LNREL-1:removeAllowed=false
...    LNCEL-2/LNREL-1:ecgiPlmnId:mcc=262
...    LNCEL-2/LNREL-1:ecgiPlmnId:mnc=3
...    LNCEL-2/LNREL-1:ecgiPlmnId:mncLength=2
...    LNCEL-3:loadSettings:targetLoadNonGbrDl=60
@{X2_LINK}
...    LNBTS/LNADJ-1:cPlaneIpAddrCtrl=oamControlled
...    LNBTS/LNADJ-1:adjEnbId=2
...    LNBTS/LNADJ-1:cPlaneIpAddr=10.0.1.31
...    LNBTS/LNADJ-1/LNADJL-1:fDlEarfcn=38100
...    LNBTS/LNADJ-1/LNADJL-1:phyCellId=31
...    LNBTS/LNADJ-1/LNADJL-1:tac=33
...    LNCEL-1/LNREL-3:ecgiAdjEnbId=2
...    LNCEL-1/LNREL-3:ecgiLcrId=1
...    LNCEL-1/LNREL-3:handoverAllowed=allowed
...    LNCEL-1/LNREL-3:amleAllowed=true
...    LNCEL-1/LNREL-3:removeAllowed=false
...    LNCEL-1/LNREL-3:cellIndOffNeigh=0dB
...    LNCEL-1/LNREL-3:ecgiPlmnId:mcc=262
...    LNCEL-1/LNREL-3:ecgiPlmnId:mnc=3
...    LNCEL-1/LNREL-3:ecgiPlmnId:mncLength=2
${INTRA_ENB_IEF_LEQ_HO_PREP}    M8071C27
${INTRA_ENB_IEF_LEQ_HO_ATT}    M8071C28
${INTRA_ENB_IEF_LEQ_HO_SUCC}    M8071C29
${INTER_ENB_IEF_LEQ_X2_HO_PREP}    M8072C31
${INTER_ENB_IEF_LEQ_X2_HO_ATT}    M8072C32
${INTER_ENB_IEF_LEQ_X2_HO_SUCC}    M8072C33
${PM_COUNTER_INTERVAL}    1min
@{pm_counters_Ab03}
...    LNCEL-1:LTE_Intra_eNB_Handover_Extension:${INTRA_ENB_IEF_LEQ_HO_PREP}=1
...    LNCEL-1:LTE_Intra_eNB_Handover_Extension:${INTRA_ENB_IEF_LEQ_HO_ATT}=1
...    LNCEL-1:LTE_Intra_eNB_Handover_Extension:${INTRA_ENB_IEF_LEQ_HO_SUCC}=0
@{pm_counters_Bb01}
...    LNCEL-1:LTE_Inter_eNB_via_X2_Handover:${INTER_ENB_IEF_LEQ_X2_HO_PREP}=2
...    LNCEL-1:LTE_Inter_eNB_via_X2_Handover:${INTER_ENB_IEF_LEQ_X2_HO_ATT}=2
...    LNCEL-1:LTE_Inter_eNB_via_X2_Handover:${INTER_ENB_IEF_LEQ_X2_HO_SUCC}=2

${mobilty_info}
...    mobilityControlInfo contains (targetPhysCellId eq 31 and
...    carrierFreq contains (dl-CarrierFreq eq 38100 and ul-CarrierFreq eq 38100))
${intra-mobility}
...    mobilityControlInfo contains (targetPhysCellId eq 2 and carrierFreq contains (dl-CarrierFreq eq 38100))
*** Test Cases ***
LTE3717-A_b_03-Counter Updated After Intra-eNB Inter-frequency Load Equalization Handover Execution Failure Due To HandoverFailure
    [Documentation]    LTE3717-A_b_03-Counter Updated After Intra-eNB Inter-frequency Load Equalization Handover Execution Failure Due To HandoverFai
    ...    lu
    ...    re
    ...    Step 1:set two intra-eNB LNADJs and related LNRELS in CELL-1 .and CELL-1 is not in AMLE state by NetAct CM. Start downlink UDP traffic ove
    ...    r
    ...    QCI6 at SRC CELL
    ...    Step 2:set UE handle handover message timeout
    ...    Step 3:Send RRC:measurementReport (A4 measurement for CELL-2 ) that fulfills RSRP/RSRQ criteria for HO
    ...    Expected result:
    ...    Step 1:SRC CELL nonGBR load at 25%,SRC CELL enters AMLE state.
    ...    eNB sends RRC:rrcConnectionReconfiguration with A4 event activation for CELL-2
    ...    Step 2:
    ...    Upon receiving RRC:measurementReport,eNB triggers HO
    ...    Check NetAct PM, the following PM counters are incremented:
    ...    M8071C27: The Counter Intra ENB Inter Frequency Load Equalization Handover Preparations
    ...    M8071C28: The Counter Intra ENB Inter Frequency Load Equalization Handover Attempts
    ...    Check NetAct PM, the following PM counters are not incremented:
    ...    M8071C29: The Counter Intra ENB Inter Frequency Load Equalization Handover Successes
    [Tags]
    Start Rtpm Counter
    UE Attach    ue_id=1
    Setup Bearer With QCI5
    Send Traffic And Wait A4
    Set RRC Reestablishment During A4 Trigger Intra-freq HO With Cause
    Check Rtpm Counters    ${pm_counters_Ab03}

LTE3717-B_b_01_Counter Updated After Inter-eNB Inter-Frequency Load Equalization Handover Finish
    [Documentation]    LTE3717_B_b_01_Counter Updated After Inter-eNB Inter-Frequency Load Equalization Handover Finish
    ...    Step 1:set two inter-eNB LNADJs and related LNRELS in CELL-1 .and CELL-1 is not in AMLE state by NetAct CM. Start downlink UDP traffic ove
    ...    r
    ...    QCI6 at SRC CELL
    ...    Step 2:Send RRC:measurementReport (A4 measurement for CELL-2 ) that fulfills RSRP/RSRQ criteria for HO
    ...    Expected result:
    ...    Step 1:SRC CELL nonGBR load at 25%,SRC CELL enters AMLE state.
    ...    eNB sends RRC:rrcConnectionReconfiguration with A4 event activation for CELL-2
    ...    Step 2:
    ...    Upon receiving RRC:measurementReport,eNB triggers HO
    ...    Check NetAct PM, the following PM counters are incremented:
    ...    M8072C31: The Counter Inter eNB Inter Frequency Load Equalization X2 Handover Preparations
    ...    M8072C32: The Counter Inter eNB Inter Frequency Load Equalization X2 Handover Attempts
    ...    M8072C33: The Counter Inter eNB Inter Frequency Load Equalization X2 Handover Successes
    [Tags]
    Start Rtpm Counter
    3UEs Attach
    Setup Dedicate Bearer For All UE
    Send Traffic And Wait A4 For ALL UE
    A4 Event And Wait Inter-eNB Ho For ALL UE Except UE1
    Check Rtpm Counters    ${pm_counters_Bb01}

*** Keywords ***
Common Suite Setup And Setup CUS Env
    Common Suite Setup
    Setup CUS Env    3CELLs
    Create UE Alias    UE_1    ue_id=1    id_type=cus
    Create UE Alias    UE_2    ue_id=2    id_type=cus
    Create UE Alias    UE_3    ue_id=3    id_type=cus
    Create Enb Alias    ENB_1    enb_id=1    id_type=wts
    Create MME Alias    MME_1    mme_id=1    id_type=wts
    execute egate command    trace_sim on mme=1 protocol=s1

Modify Yaml
    Add Yaml    BASE_STATIONS
    ...    - id: 2
    ...      type: simulated
    ...      plmn: '262:03'
    ...      s1: 10.0.1.31
    ...      bts_param: {mlb_feature_flag: 'on', mlbSupportedRelease: 'r9'}
    ...      cells:
    ...        - {id: 1, technology: lte, tac: 33, pci: '10:1', earfcn: '38100:38100', bw: 20}

UE Attach
    [Arguments]    ${ue_id}=1
    execute uex command    ue_attach id=${ue_id} cell=1
3UEs Attach
    expect message flow
    ...    MME_1:S1AP_InitialContextSetupResponse
    ...    MME_1:S1AP_InitialContextSetupResponse
    ...    MME_1:S1AP_InitialContextSetupResponse
    ...    alias=attach_flow    overall_timeout=20
    execute uex command    ue_attach id=1-3 cell=1
    flow occurred as expected    alias=attach_flow
Setup Bearer With QCI5
    execute uex command    bearer_add ue=1 qci=5

Send Traffic And Wait A4 For ALL UE
    expect message flow
    ...    UE_1:RRC_RRCConnectionReconfiguration (eventA4 contains (a4-Threshold contains (threshold-RSRP eq 0)))
    ...    UE_1:RRC_RRCConnectionReconfigurationComplete
    ...    UE_2:RRC_RRCConnectionReconfiguration (eventA4 contains (a4-Threshold contains (threshold-RSRP eq 0)))
    ...    UE_2:RRC_RRCConnectionReconfigurationComplete
    ...    UE_3:RRC_RRCConnectionReconfiguration (eventA4 contains (a4-Threshold contains (threshold-RSRP eq 0)))
    ...    UE_3:RRC_RRCConnectionReconfigurationComplete
    ...    alias=A4_event    overall_timeout=20
    execute uex command    trf_data_start ue=1 dir=dl kbps=3000 protocol=udp
    execute uex command    trf_data_start ue=2 dir=dl kbps=300 protocol=udp
    execute uex command    trf_data_start ue=3 dir=dl kbps=300 protocol=udp
    flow occurred as expected    alias=A4_event

A4 Event And Wait Inter-eNB Ho For ALL UE Except UE1
    expect message flow
    ...    UE_2:RRC_MeasurementReport (measId eq 31 and physCellId eq 31)
    ...    ENB_1:X2AP_HandoverRequest (radioNetwork contains ("reduce-load-in-serving-cell"))
    ...    ENB_1:X2AP_HandoverRequestAcknowledge
    ...    UE_2:RRC_RRCConnectionReconfiguration (${mobilty_info})
    ...    UE_2:RRC_RRCConnectionReconfigurationComplete
    ...    UE_3:RRC_MeasurementReport (measId eq 31 and physCellId eq 31)
    ...    ENB_1:X2AP_HandoverRequest (radioNetwork contains ("reduce-load-in-serving-cell"))
    ...    ENB_1:X2AP_HandoverRequestAcknowledge
    ...    UE_3:RRC_RRCConnectionReconfiguration (${mobilty_info})
    ...    UE_3:RRC_RRCConnectionReconfigurationComplete
    ...    alias=ue23_ho    overall_timeout=20
    execute uex command    ue_measurement_send id=2 event=A4 srsrp=30 srsrq=15 phycell_id=31 nrsrp=80 nrsrq=34
    execute uex command    ue_measurement_send id=3 event=A4 srsrp=30 srsrq=15 phycell_id=31 nrsrp=80 nrsrq=34
    flow occurred as expected    alias=ue23_ho

Send Traffic And Wait A4
    expect message flow
    ...    UE_1:RRC_RRCConnectionReconfiguration (eventA4 contains (a4-Threshold contains (threshold-RSRP eq 0)))
    ...    UE_1:RRC_RRCConnectionReconfigurationComplete
    ...    alias=ue1_A4    overall_timeout=20
    execute uex command    trf_data_start ue=1 dir=dl kbps=3000 protocol=udp
    flow occurred as expected    alias=ue1_A4

Setup Dedicate Bearer For All UE
    expect message flow
    ...    MME_1:S1AP_E-RABSetupRequest (e-RAB-ID eq 6 and qCI eq 5)
    ...    MME_1:S1AP_E-RABSetupResponse
    ...    MME_1:S1AP_E-RABSetupRequest (e-RAB-ID eq 6 and qCI eq 5)
    ...    MME_1:S1AP_E-RABSetupResponse
    ...    MME_1:S1AP_E-RABSetupRequest (e-RAB-ID eq 6 and qCI eq 5)
    ...    MME_1:S1AP_E-RABSetupResponse
    ...    alias=qci5_add    overall_timeout=20
    execute uex command    bearer_add ue=1 qci=5
    execute uex command    bearer_add ue=2 qci=5
    execute uex command    bearer_add ue=3 qci=5
    flow occurred as expected    alias=qci5_add


Set RRC Reestablishment During A4 Trigger Intra-freq HO With Cause
    [Arguments]    ${cause}=handoverFailure
    expect message flow
    ...    UE_1:RRC_MeasurementReport (measId eq 31 and physCellId eq 2)
    ...    UE_1:RRC_RRCConnectionReconfiguration (${intra-mobility})
    ...    UE_1:RRC_RRCConnectionReestablishmentRequest (reestablishmentCause eq "handoverFailure")
    ...    UE_1:RRC_RRCConnectionReestablishmentComplete
    ...    alias=ho_failure    overall_timeout=20
    Execute UEx Command    ue_rrc_reconf_param id=1 nth=1 if_contains=mobilityControlInfo action=reestablish cell=1 cause=handoverFailure
    execute uex command    ue_measurement_send id=1 event=A4 srsrp=30 srsrq=15 phycell_id=2 nrsrp=80 nrsrq=34
    flow occurred as expected    alias=ho_failure
