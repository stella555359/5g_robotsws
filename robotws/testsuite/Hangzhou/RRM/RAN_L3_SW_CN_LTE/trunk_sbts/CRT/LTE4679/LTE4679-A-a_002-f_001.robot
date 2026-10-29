*** Settings ***
Documentation     ENB1: FDD;
...                 ENB2: TDD;
Suite Setup       Setup CUS Env And Common Suite Setup
Suite Teardown    Common Suite Teardown And Restore BTS Configuration Parameters
Test Setup        Common Test Setup And Start To Capture Logs
Test Teardown     Common Test Teardown And Stop Capture Logs
Force Tags        QCD_MN_RAN    QCP_RAN_ET    SBTS00    RAN_4G    RAN_4G_TDD    CRT    CLOUD_2MAPO_2CUS    owner-chao.3.zhang
...                 DevHZ5_SG8    release-SBTS19A    team-SG4    owner-annie.nie
Resource          ../../../resources/DevHZ5_resource.robot

*** Variables ***
@{PARAMS_IN_SCF}
...    MRBTS-1:btsName=LTE4679_FDD_side
...    LNBTS:mcc=262
...    LNBTS:mnc=3
...    LNBTS:mncLength=2
...    @{DELETE_NOT_NEED_PARAMS_IN_SCF}
...    @{CA_PARAMS_IN_SCF}
...    @{EARFCN_AND_CHBW_PARAMS_IN_SCF}
...    @{RELATION_ERROR_PARAMS_IN_SCF}
@{PARAMS_IN_SWCONFIG}
...    0x45000B=1
@{PARAMS_IN_SWCONFIG_ENB2}
...    0x45000B=1
@{PARAMS_IN_SCF_ENB2}
...    MRBTS-2:btsName=LTE4679_TDD_side
...    LNBTS-2:mcc=262
...    LNBTS-2:mnc=3
...    LNBTS-2:mncLength=2
...    LNBTS-2/LNCEL-5:actFlowCtrlEnh=true
...    @{EARFCN_AND_CHBW_PARAMS_IN_ENB2}
...    @{CBRS_PARAMS_IN_ENB2}
...    @{CA_PARAMS_IN_ENB2}
...    @{DELETE_NOT_NEED_PARAMS_IN_ENB2}
...    @{Fix_Relation_Error_Enb2}
@{DELETE_NOT_NEED_PARAMS_IN_SCF}
...    delete:LNBTS/LNADJG-1
...    delete:LNBTS/LNADJW-1
...    delete:LNBTS/LNADJX-1
...    LNBTS/CADPR-0:a3Offset=10
...    LNBTS/CADPR-0:maxNumMimoLayerTdd=10
...    LNBTS/CADPR-0:scellMeasThreshRsrp=-100
...    LNBTS/CADPRCBRS-0:a3Offset=10
...    LNBTS/CADPRCBRS-0:a6Offset=6
...    LNBTS/CADPRCBRS-0:hysA3Offset=10
@{DELETE_NOT_NEED_PARAMS_IN_ENB2}
...    delete:LNBTS-2/LNCEL-1/CAPR-1
...    delete:LNBTS-2/LNCEL-1/CAREL-1
...    delete:LNBTS-2/LNCEL-1/CAREL-2
...    delete:LNBTS-2/LNCEL-1/CAREL-3
...    delete:LNBTS-2/LNCEL-2/CAPR-2
@{EARFCN_AND_CHBW_PARAMS_IN_SCF}
...    LNCEL-1/LNCEL_FDD-0:earfcnDL=700
...    LNCEL-1/LNCEL_FDD-0:earfcnUL=18700
...    LNCEL-1/LNCEL_FDD-0:dlChBw=10 MHz
...    LNCEL-1/LNCEL_FDD-0:ulChBw=10 MHz
...    LNCEL-2/LNCEL_FDD-0:earfcnDL=66538
...    LNCEL-2/LNCEL_FDD-0:earfcnUL=132074
...    LNCEL-2/LNCEL_FDD-0:dlChBw=20 MHz
...    LNCEL-2/LNCEL_FDD-0:ulChBw=20 MHz
@{EARFCN_AND_CHBW_PARAMS_IN_ENB2}
...    LNBTS-2/LNCEL-3/LNCEL_TDD-0:earfcn=55390    #55690
...    LNBTS-2/LNCEL-3/LNCEL_TDD-0:chBw=10 MHz
...    LNBTS-2/LNCEL-4/LNCEL_TDD-0:earfcn=${ENB2_CELL4_OLD_EARFCN}
...    LNBTS-2/LNCEL-4/LNCEL_TDD-0:chBw=10 MHz
...    LNBTS-2/LNCEL-5/LNCEL_TDD-0:earfcn=55290    #55490
...    LNBTS-2/LNCEL-5/LNCEL_TDD-0:chBw=10 MHz
@{CA_PARAMS_IN_SCF}
...    LNBTS:actDLCAggr=true
...    LNBTS:actEnhCbrsCAggr=true
...    LNBTS:actEnhAcAndGbrServices=true
...    LNBTS:actMultBearers=true
...    LNBTS:actInterEnbDLCAggr=true
...    LNBTS/LNBTS_FDD-0:numTxWithHighNonGbr=1
...    LNBTS:actAdvStepwiseScellAdd=oneStepAdvanced
...    LNBTS:sCellActivationMethod=nonGBRBufferBasedStepWise
...    LNBTS:actFlexScellSelect=true
...    LNCEL-1/LNCEL_FDD-0:actAutoPucchAlloc=true
...    LNCEL-2/LNCEL_FDD-0:actAutoPucchAlloc=true
...    LNCEL-1/CAREL-1:lcrId=53
...    LNCEL-1/CAREL-1:lnBtsId=2
...    LNCEL-1/CAREL-1:maxNumOfSuppMimoLayer=2-layer
...    LNCEL-1/CAREL-1:pcellSwapAllowed=allowed
...    LNCEL-1/CAREL-1:scellPrio=1
...    LNCEL-1/CAREL-2:lcrId=54
...    LNCEL-1/CAREL-2:lnBtsId=2
...    LNCEL-1/CAREL-2:maxNumOfSuppMimoLayer=2-layer
...    LNCEL-1/CAREL-2:pcellSwapAllowed=allowed
...    LNCEL-1/CAREL-2:scellPrio=2
...    LNCEL-1/CAREL-3:lcrId=2
...    LNCEL-1/CAREL-3:lnBtsId=1
...    LNCEL-1/CAREL-3:maxNumOfSuppMimoLayer=2-layer
...    LNCEL-1/CAREL-3:pcellSwapAllowed=allowed
...    LNCEL-1/CAREL-3:scellPrio=1
...    LNCEL-1:caPoolId=1
...    LNCEL-2:caPoolId=1
...    LNCEL-1:maxNumScells=4
...    LNBTS/CAGENB-0:caClusterEnbList:lnBtsId=2
...    LNBTS/CAGENB-0:caClusterEnbList:numSrioLinks=0
...    LNBTS/LNADJ-1:adjEnbId=2
...    LNBTS/LNADJ-1:cPlaneIpAddr=10.0.1.4
...    LNBTS/LNADJ-1:cPlaneIpAddrCtrl=oamControlled
...    LNBTS/LNADJ-1:plmnId:mcc=262
...    LNBTS/LNADJ-1:plmnId:mnc=3
...    LNBTS/LNADJ-1:plmnId:mncLength=2
...    LNBTS/LNADJ-1/LNADJL-1:tac=33
...    LNBTS:caClusterId=1
...    LNBTS:caClusterMemberId=1
...    LNBTS:caSchedFairFact=0
...      MNL-1/MNLENT-1/SYNC-1:btsSyncMode=PhaseSync
@{CBRS_PARAMS_IN_ENB2}
...    LNBTS-2/CBSD-1:supportedSpectrumV2=1073741823
...    LNBTS-2/CBSD-1:antennaGain=8
...    LNBTS-2/CBSD-2:supportedSpectrumV2=1073741823
...    LNBTS-2/CBSD-2:antennaGain=8
...    LNBTS-2/LNCEL-3/CBSDCEL-0:maxGrantPwrRed=10
...    LNBTS-2/LNCEL-3/CBSDCEL-0:desiredPmax=320
...    LNBTS-2/LNCEL-4/CBSDCEL-0:maxGrantPwrRed=10
...    LNBTS-2/LNCEL-4/CBSDCEL-0:desiredPmax=320
...    LNBTS-2/LNCEL-5/CBSDCEL-0:maxGrantPwrRed=10
...    LNBTS-2/LNCEL-5/CBSDCEL-0:desiredPmax=320
@{CA_PARAMS_IN_ENB2}
...    LNBTS-2/CAGENB-0:caClusterEnbList:lnBtsId=1
...    LNBTS-2/CAGENB-0:caClusterEnbList:numSrioLinks=0
...    LNBTS-2/LNADJ-1:adjEnbId=1
...    LNBTS-2/LNADJ-1:cPlaneIpAddr=10.0.1.2
...    LNBTS-2/LNADJ-1:cPlaneIpAddrCtrl=oamControlled
...    LNBTS-2/LNADJ-1:plmnId:mcc=262
...    LNBTS-2/LNADJ-1:plmnId:mnc=3
...    LNBTS-2/LNADJ-1:plmnId:mncLength=2
...    LNBTS-2/LNADJ-1/LNADJL-1:tac=33
...    LNBTS-2/LNADJ-1:rlfBasedRCRsupported=false
...    LNBTS-2:caClusterId=1
...    LNBTS-2:caClusterMemberId=2
...    LNBTS-2:caSchedFairFact=0
...    LNBTS-2:actDLCAggr=true
...    LNBTS-2/LNBTS_TDD-0:actCbrs=true
...    LNBTS-2:actEnhCbrsCAggr=true
...    LNBTS-2:actEnhAcAndGbrServices=true
...    LNBTS-2:actMultBearers=true
...    LNBTS-2:actInterEnbDLCAggr=true
...    LNBTS-2/LNBTS_TDD-0:numTxWithHighNonGbr=1
...    LNBTS-2:actAdvStepwiseScellAdd=oneStepAdvanced
...    LNBTS-2:sCellActivationMethod=nonGBRBufferBasedStepWise
...    LNBTS-2/LNCEL-3/LNCEL_TDD-0:actAutoPucchAlloc=true
...    LNBTS-2/LNCEL-4/LNCEL_TDD-0:actAutoPucchAlloc=true
...    LNBTS-2/LNCEL-5/LNCEL_TDD-0:actAutoPucchAlloc=true
...    LNBTS-2:actFlexScellSelect=true
...    LNBTS-2/LNCEL-3/CAREL-1:lcrId=54
...    LNBTS-2/LNCEL-3/CAREL-1:lnBtsId=2
...    LNBTS-2/LNCEL-3/CAREL-1:maxNumOfSuppMimoLayer=4-layer
...    LNBTS-2/LNCEL-3/CAREL-1:pcellSwapAllowed=allowed
...    LNBTS-2/LNCEL-3/CAREL-1:scellPrio=1
...    LNBTS-2/LNCEL-3:caPoolId=1
...    LNBTS-2/LNCEL-4:caPoolId=1
...    LNBTS-2/LNCEL-3:maxNumScells=1
@{RELATION_ERROR_PARAMS_IN_SCF}
...    LNBTS:actAmbrModCaTrigger=false
...    LNBTS:actFlexCaMgmt=false
...    LNCEL:actCaArchEnhImp=off
...    LNBTS/LNCEL:actFlowCtrlEnh=true
...    LNBTS/LNCEL:actScellConfigForHiDemand=false
...    LNBTS:actIscaHarqEnh=false
...    LNCEL:eTputInitMcs=20
...    LNCEL:eTputFilterConfig=51
@{Fix_Relation_Error_Enb2}
...    LNBTS-2/LNCEL-5:actFlowCtrlEnh=true
...    LNBTS-2:actAmbrModCaTrigger=false
...    LNBTS-2/LNCEL:eTputInitMcs=20
...    LNBTS-2/LNCEL:eTputFilterConfig=51
...    delete:LNCEL:a2TimeToTriggerActInterFreqMeas
...    LNBTS-2/LNCEL-3:scellFastSchedulingSelect=normal
...    LNBTS-2/LNCEL-3:dlCaMinPcellCqi=0
...    LNBTS-2/LNCEL-3:ulCaMinPcellSinr=0
...    LNBTS-2/LNCEL-3:actScellConfigForHiDemand=false
...    LNBTS-2/LNCEL-4:scellFastSchedulingSelect=normal
...    LNBTS-2/LNCEL-4:dlCaMinPcellCqi=0
...    LNBTS-2/LNCEL-4:ulCaMinPcellSinr=0
...    LNBTS-2/LNCEL-4:actScellConfigForHiDemand=false
...    LNBTS-2/LNBTS_FDD-0:actConvVoice=false
...    LNBTS-2/LNBTS_TDD-0:actConvVoice=false
...    LNBTS-2/LNCEL-3:actDl256QamChQualEst=false
...    LNBTS-2/LNCEL-4:actDl256QamChQualEst=false
...    LNBTS-2:actIfHo=disabled
...    LNBTS-2/LNCEL-5:caPoolId=1
...    LNBTS-2/LNCEL-5:actCaArchEnhImp=off
...    LNBTS-2/LNCEL-3/CBSDCEL-0:prachFreqOff10M=2
...    LNBTS-2/LNCEL-3/CBSDCEL-0:prachFreqOff20M=2
...    LNBTS-2/LNCEL-4/CBSDCEL-0:prachFreqOff10M=2
...    LNBTS-2/LNCEL-4/CBSDCEL-0:prachFreqOff20M=2
...    LNBTS-2/LNCEL-5/CBSDCEL-0:prachFreqOff10M=2
...    LNBTS-2/LNCEL-5/CBSDCEL-0:prachFreqOff20M=2
...    LNBTS-2/LNCEL-3/LNCEL_TDD-0:prachFreqOff=2
...    LNBTS-2/LNCEL-4/LNCEL_TDD-0:prachFreqOff=2
...    LNBTS-2/LNCEL-5/LNCEL_TDD-0:prachFreqOff=2
...    LNBTS-2:actIscaHarqEnh=false
@{LOCK_ENB2_CELL4_PARAMS_IN_SCF_TARGET}
...    LNBTS-2/LNCEL-4:administrativeState=locked
@{UNLOCK_ENB2_CELL4_PARAMS_IN_SCF_TARGET}
...    LNBTS-2/LNCEL-4:administrativeState=unlocked
@{SCELL_ADD_ONESTEP_PARAMS_IN_SCF_TARGET}
...    LNBTS-2/LNBTS_TDD-0:numTxWithHighNonGbr=1
...    LNBTS-2:actAdvStepwiseScellAdd=oneStepAdvanced
...    LNBTS-2:sCellActivationMethod=nonGBRBufferBasedStepWise
@{SCELL_ADD_OFF_PARAMS_IN_SCF_TARGET}
...    LNBTS-2/LNBTS_TDD-0:numTxWithHighNonGbr=1
...    LNBTS-2:actAdvStepwiseScellAdd=off
...    LNBTS-2:sCellActivationMethod=nonGBRBufferBasedStepWise
@{DELTA_ENB2_CELL4_CHBW_CHANGE_PARAMS_IN_SCF_TARGET}
...    LNBTS-2/LNCEL-4/LNCEL_TDD-0:chBw=${ENB2_CELL4_NEW_CHBW}
@{RECOVER_ENB2_CELL4_CHBW_CHANGE_PARAMS_IN_SCF_TARGET}
...    LNBTS-2/LNCEL-4/LNCEL_TDD-0:chBw=${ENB2_CELL4_OLD_CHBW}
@{UNLOCK_ENB2_CELL4_AND_SCELL_ADD_ONESTEP_PARAMS_IN_SCF_TARGET}
...    @{UNLOCK_ENB2_CELL4_PARAMS_IN_SCF_TARGET}
...    @{SCELL_ADD_ONESTEP_PARAMS_IN_SCF_TARGET}
${CA_SUPPORTED_BAND_48A_48A}    48:a:a+48:a supported_bands=48
${CA_SUPPORTED_BAND_2A_66A_48A_48A}    SEPARATOR=
...    2:a:a+64::a+48::a+48::a|2:a:a+48::a+48::a|2:a:a+48::a|2:a:a+64::a|2:a:a+48::a+64::a supported_bands=2,48,64 extended_supported_bands=64:66
${ENB2_CELL4_OLD_CHBW}    10 MHz
${ENB2_CELL4_NEW_CHBW}    20 MHz
${ENB2_CELL4_OLD_EARFCN}    55490    #55890
${ATTACH_CHECK}
...    measObjectToAddModList contains (carrierFreq eq 55290, carrierFreq eq 55390)
${ADD_1SCELL_TCELL4}
...    sCellToAddModList-r10 contains (
...    sCellIndex-r10 eq 1 and
...    cellIdentification-r10 contains (
...    physCellId-r10 eq 54 and
...    dl-CarrierFreq-r10 eq 55390))
${ADD_3SCELLS}
...    sCellToAddModList-r10 contains (
...    sCellIndex-r10 eq 1 and
...    cellIdentification-r10 contains (
...    physCellId-r10 eq 2 and
...    dl-CarrierFreq-r10 eq 65535),
...    sCellIndex-r10 eq 3 and
...    cellIdentification-r10 contains (
...    physCellId-r10 eq 54 and
...    dl-CarrierFreq-r10 eq 55390),
...    sCellIndex-r10 eq 2 and
...    cellIdentification-r10 contains (
...    physCellId-r10 eq 53 and
...    dl-CarrierFreq-r10 eq 55290))
${REL_SCELL3_TCELL4}
...    sCellToReleaseList-r10 contains (3) and
...    sCellToAddModList-r10 contains (
...    sCellIndex-r10 eq 1, sCellIndex-r10 eq 2)
${ADD_SCELL3_TCELL4}
...    sCellToAddModList-r10 contains (
...    sCellIndex-r10 eq 1,
...    sCellIndex-r10 eq 2,
...    sCellIndex-r10 eq 3 and
...    cellIdentification-r10 contains (
...    physCellId-r10 eq 54 and
...    dl-CarrierFreq-r10 eq 55440))
*** Test Cases ***
LTE4679-A-a_002_Downgrade_NonCA_From_2CC
    [Documentation]    Pcell ENB2 cell3; scell1 ENB2 cell4;
    [Tags]
    Online change SCELL STEP OFF on Target
    Attach UE Successfully on ENB2 Cell3 without Scell addition    ue_id=1
    Start Data Traffic To Trigger Scell Addition Successfully    ${UE1}    ${ADD_1SCELL_TCELL4}
    Release Scell on Cell4 By Blocking Cell4
    [Teardown]    Common Test Teardown and Recover Env    ${UE1}    ${UNLOCK_ENB2_CELL4_AND_SCELL_ADD_ONESTEP_PARAMS_IN_SCF_TARGET}

LTE4679-A-f_001_Scell_Release_Addition_Caused_By_CBRS_Frequency_Change_advSCellStepWise_oneStep
    [Documentation]    Pcell ENB1 cell1; scell1 ENB1 cell2; scell2 ENB2 cell3; scell3 ENB2 cell4;
    ...    numTxWithHighNonGbr=1
    ...    actAdvStepwiseScellAdd=oneStepAdvanced
    [Tags]
    Attach UE On Cell1 And 3Scell Additon Successful    ue_id=2
    change ENB2 CELL4 CHBW to release 3rd Scell on Cell4    ue_id=2
    Start Data Traffic To Trigger Scell Addition Successfully    ${UE2}    ${ADD_SCELL3_TCELL4}
    [Teardown]    Common Test Teardown and Recover Env    ${UE2}    ${RECOVER_ENB2_CELL4_CHBW_CHANGE_PARAMS_IN_SCF_TARGET}

*** Keywords ***
Setup CUS Env And Common Suite Setup
    Common Suite Setup
    Start SAS Server
    Setup 2CUS Env    tl_type=3CELLs_FDD_band2band4band12    tl_type_enb2=2CELLs_FDD_3CELLs_TDD_2B2_2B48
    Create Alias
    Setup UE parameters

Create Alias
    Create UE Alias    UE_1    ue_id=1    id_type=cus
    Create UE Alias    UE_2    ue_id=2    id_type=cus
    Create Enb Alias    alias=ENB_1    enb_id=1    id_type=wts
    Create Enb Alias    alias=ENB_2    enb_id=2    id_type=wts
    Create MME Alias    alias=MME_1    mme_id=1    id_type=wts

Setup UE parameters
    Execute Egate Command    trace uec=1 mme=1 protocol=rrc,nr_rrc,s1,x2 on
    Execute Egate Command    trace_sim enb=1 protocol=x2,s1 on
    Execute Egate Command    trace_sim enb=2 protocol=x2,s1 on

Common Test Teardown and Recover Env
    [Arguments]    ${ue_id}    ${delta_commission_file_for_enb2}=${EMPTY}
    execute uex command    ue_detach id=${ue_id}
    Do Delta Commission and Wait for Cell Start Up    ${EMPTY}    ${delta_commission_file_for_enb2}
    Common Test Teardown And Stop Capture Logs

Attach UE Successfully on ENB2 Cell3 without Scell addition
    [Arguments]    ${ue_id}=1
    expect message flow
    ...    UE_${ue_id}:RRC_RRCConnectionReconfiguration (${ATTACH_CHECK})
    ...    UE_${ue_id}:RRC_RRCConnectionReconfigurationComplete
    ...    MME_1:S1AP_InitialContextSetupRequest
    ...    MME_1:S1AP_InitialContextSetupResponse
    ...    alias=ue_attach_flow    overall_timeout=30
    Execute Uex Command    ue_param id=${ue_id} ca_supported_bands=${CA_SUPPORTED_BAND_48A_48A}
    Execute Uex Command    ue_attach id=${ue_id} cell=53 enb=2
    flow occurred as expected    alias=ue_attach_flow

Attach UE On Cell1 And 3Scell Additon Successful
    [Arguments]    ${ue_id}=2
    Execute Uex Command    ue_param id=${ue_id} ca_supported_bands=${CA_SUPPORTED_BAND_2A_66A_48A_48A}
    expect message flow
    ...    UE_${ue_id}:RRC_RRCConnectionReconfiguration (${ADD_3SCELLS})
    ...    alias=3cc_scell_flow    overall_timeout=30
    Execute Uex Command    ue_attach id=${ue_id} enb=1 cell=1
    flow occurred as expected    alias=3cc_scell_flow

Start Data Traffic To Trigger Scell Addition Successfully
    [Arguments]    ${ue_id}=${UE1}    ${scell_add}=${scell_add}}
    expect message flow
    ...    UE_${ue_id}:RRC_RRCConnectionReconfiguration (${scell_add})
    ...    alias=scell_add_flow    overall_timeout=30
    Execute Uex Command    trf_data_start ue=${ue_id} protocol=udp trf_id=1 dir=dl Mbps=175
    #Execute Uex Command    ue_stats clear id=${ue_id}
    Get Throughput    ue_id=${ue_id}
    flow occurred as expected    alias=scell_add_flow


Release Scell on Cell4 By Blocking Cell4
    [Arguments]    ${ue_id}=${UE1}
    expect message flow
    ...    UE_${ue_id}:RRC_RRCConnectionReconfiguration (sCellToReleaseList-r10 contains (1))
    ...    alias=scell_rel_flow    overall_timeout=60
    Delta Commission Parameters Enb2    ${LOCK_ENB2_CELL4_PARAMS_IN_SCF_TARGET}
    #Execute Uex Command    ue_stats clear id=${ue_id}
    Get Throughput    ue_id=${ue_id}
    Flow Occurred As Expected    alias=scell_rel_flow

Do Delta Commission and Wait for Cell Start Up
    [Arguments]    ${delta_commission_file_for_enb1}=${EMPTY}    ${delta_commission_file_for_enb2}=${EMPTY}
    Delta Commission Parameters Enb2    ${delta_commission_file_for_enb2}
    Delta Commission Parameters    ${delta_commission_file_for_enb1}
    Cells Should Be OnAir
    Cells Should Be OnAir eNB2

Online change SCELL STEP OFF on Target
    Do Delta Commission and Wait for Cell Start Up    ${EMPTY}    ${SCELL_ADD_OFF_PARAMS_IN_SCF_TARGET}

change ENB2 CELL4 CHBW to release 3rd Scell on Cell4
    [Arguments]    ${ue_id}=2
    expect message flow
    ...    UE_${ue_id}:RRC_RRCConnectionReconfiguration (${REL_SCELL3_TCELL4})
    ...    alias=rel_scell3_flow    overall_timeout=40
    Do Delta Commission and Wait for Cell Start Up    ${EMPTY}    ${DELTA_ENB2_CELL4_CHBW_CHANGE_PARAMS_IN_SCF_TARGET}
    flow occurred as expected    alias=rel_scell3_flow