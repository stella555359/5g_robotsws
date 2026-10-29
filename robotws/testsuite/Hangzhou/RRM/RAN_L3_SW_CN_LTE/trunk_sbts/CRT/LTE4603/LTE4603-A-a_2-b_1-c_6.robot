*** Settings ***
Suite Setup       Common Suite Setup And Setup 2CUS Env
Suite Teardown    Common Suite Teardown And Restore BTS Configuration Parameters
Test Setup        Common Test Setup And Start To Capture Logs
Test Teardown     Common Test Teardown And Stop Capture Logs
Force Tags        QCD_MN_RAN    QCP_RAN_ET    SBTS00    RAN_4G    RAN_4G_FDD    CRT    CLOUD_2MAPO_2CUS    owner-chao.3.zhang
...                 DevHZ5_SG8    release-SBTS19A    owner-annie.nie    team-SG4
Resource          ../../../resources/DevHZ5_resource.robot

*** Variables ***
@{PARAMS_IN_SCF}
...    MRBTS-1:btsName=LTE4603_FDD_side
...    LNBTS:mcc=311
...    LNBTS:mnc=9
...    LNBTS:mncLength=2
...    LNBTS/LNCEL:tac=124
...    @{EARFCN_AND_CHBW_PARAMS_IN_SCF}
...    @{CA_PARAMS_IN_SCF}
...    @{DELETE_NOT_NEED_PARAMS_IN_SCF}
...    @{RELATION_ERROR_PARAMS_IN_SCF}
@{PARAMS_IN_SWCONFIG}
...    0x45000B=1
@{PARAMS_IN_SWCONFIG_ENB2}
...    0x45000B=1
@{PARAMS_IN_SCF_ENB2}
...    MRBTS-2:btsName=LTE4603_TDD_side
...    LNBTS-2:mcc=311
...    LNBTS-2:mnc=9
...    LNBTS-2:mncLength=2
...    LNBTS-2/LNCEL:tac=124
...    @{EARFCN_AND_CHBW_PARAMS_IN_SCF_TARGET}
...    @{DELETE_NOT_NEED_PARAMS_IN_SCF_TARGET}
...    @{CA_PARAMS_IN_SCF_TARGET}
...    @{CBRS_PARAMS_IN_SCF_TARGET}
...    @{RELATION_ERROR_PARAMS_IN_SCF_TARGET}
@{DELETE_NOT_NEED_PARAMS_IN_SCF}
...    delete:LNBTS/LNADJ-255
...    delete:LNBTS/LNADJ-255/LNADJL-254
...    delete:LNBTS/LNADJ-255/LNADJL-255
@{DELETE_NOT_NEED_PARAMS_IN_SCF_TARGET}
...    delete:LNBTS-2/LNCEL-1/CAPR-1
...    delete:LNBTS-2/LNCEL-1/CAREL-1
...    delete:LNBTS-2/LNCEL-1/CAREL-2
...    delete:LNBTS-2/LNCEL-1/CAREL-3
...    delete:LNBTS-2/LNCEL-2/CAPR-2
@{EARFCN_AND_CHBW_PARAMS_IN_SCF}
...    LNCEL-1/LNCEL_FDD-0:earfcnDL=700
...    LNCEL-1/LNCEL_FDD-0:earfcnUL=18700
...    LNCEL-1/LNCEL_FDD-0:dlChBw=20 MHz
...    LNCEL-1/LNCEL_FDD-0:ulChBw=20 MHz
...    LNCEL-2/LNCEL_FDD-0:earfcnDL=900
...    LNCEL-2/LNCEL_FDD-0:earfcnUL=18900
...    LNCEL-2/LNCEL_FDD-0:dlChBw=20 MHz
...    LNCEL-2/LNCEL_FDD-0:ulChBw=20 MHz
...    LNCEL-3/LNCEL_FDD-0:earfcnDL=47092
...    LNCEL-3/LNCEL_FDD-0:earfcnUL=47092
...    LNCEL-3/LNCEL_FDD-0:dlChBw=20 MHz
...    LNCEL-3/LNCEL_FDD-0:ulChBw=20 MHz
...    LNCEL-4/LNCEL_FDD-0:earfcnDL=47290
...    LNCEL-4/LNCEL_FDD-0:earfcnUL=47290
...    LNCEL-4/LNCEL_FDD-0:dlChBw=20 MHz
...    LNCEL-4/LNCEL_FDD-0:ulChBw=20 MHz
...    LNCEL-5/LNCEL_FDD-0:earfcnDL=47488
...    LNCEL-5/LNCEL_FDD-0:earfcnUL=47488
...    LNCEL-5/LNCEL_FDD-0:dlChBw=20 MHz
...    LNCEL-5/LNCEL_FDD-0:ulChBw=20 MHz
@{EARFCN_AND_CHBW_PARAMS_IN_SCF_TARGET}
...    LNBTS-2/LNCEL-3/LNCEL_TDD-0:earfcn=55340
...    LNBTS-2/LNCEL-3/LNCEL_TDD-0:chBw=20 MHz
...    LNBTS-2/LNCEL-4/LNCEL_TDD-0:earfcn=55538
...    LNBTS-2/LNCEL-4/LNCEL_TDD-0:chBw=20 MHz
...    LNBTS-2/LNCEL-5/LNCEL_TDD-0:earfcn=55940
...    LNBTS-2/LNCEL-5/LNCEL_TDD-0:chBw=20 MHz
@{CA_PARAMS_IN_SCF}
...    LNBTS:caClusterId=1
...    LNBTS:caClusterMemberId=1
...    LNBTS/CAGENB-0:caClusterEnbList:lnBtsId=2
...    LNBTS/CAGENB-0:caClusterEnbList:numSrioLinks=0
...    LNBTS/LNADJ-1:adjEnbId=2
...    LNBTS/LNADJ-1:cPlaneIpAddr=10.0.1.4
...    LNBTS/LNADJ-1:cPlaneIpAddrCtrl=oamControlled
...    LNCEL-1/CAREL-1:lcrId=2
...    LNCEL-1/CAREL-1:lnBtsId=1
...    LNCEL-1/CAREL-1:maxNumOfSuppMimoLayer=2-layer
...    LNCEL-1/CAREL-1:pcellSwapAllowed=allowed
...    LNCEL-1/CAREL-1:scellPrio=1
...    LNCEL-1/CAREL-2:lcrId=3
...    LNCEL-1/CAREL-2:lnBtsId=1
...    LNCEL-1/CAREL-2:maxNumOfSuppMimoLayer=2-layer
...    LNCEL-1/CAREL-2:pcellSwapAllowed=allowed
...    LNCEL-1/CAREL-2:scellPrio=2
...    LNCEL-1/CAREL-3:lcrId=4
...    LNCEL-1/CAREL-3:lnBtsId=1
...    LNCEL-1/CAREL-3:maxNumOfSuppMimoLayer=2-layer
...    LNCEL-1/CAREL-3:pcellSwapAllowed=allowed
...    LNCEL-1/CAREL-3:scellPrio=1
...    LNCEL-1/CAREL-4:lcrId=5
...    LNCEL-1/CAREL-4:lnBtsId=1
...    LNCEL-1/CAREL-4:maxNumOfSuppMimoLayer=2-layer
...    LNCEL-1/CAREL-4:pcellSwapAllowed=allowed
...    LNCEL-1/CAREL-4:scellPrio=1
...    LNCEL-1/CAREL-5:lcrId=53
...    LNCEL-1/CAREL-5:lnBtsId=2
...    LNCEL-1/CAREL-5:maxNumOfSuppMimoLayer=2-layer
...    LNCEL-1/CAREL-5:pcellSwapAllowed=allowed
...    LNCEL-1/CAREL-5:scellPrio=1
...    LNCEL-1/CAREL-6:lcrId=54
...    LNCEL-1/CAREL-6:lnBtsId=2
...    LNCEL-1/CAREL-6:maxNumOfSuppMimoLayer=2-layer
...    LNCEL-1/CAREL-6:pcellSwapAllowed=allowed
...    LNCEL-1/CAREL-6:scellPrio=1
...    LNBTS:caSchedFairFact=0
...    LNBTS:actDLCAggr=true
...    LNBTS:actEnhCbrsCAggr=false
...    LNBTS:actEnhAcAndGbrServices=true
...    LNBTS:actMultBearers=true
...    LNBTS:actInterEnbDLCAggr=true
...    LNBTS/LNBTS_FDD-0:numTxWithHighNonGbr=1
...    LNBTS:actAdvStepwiseScellAdd=oneStepAdvanced
...    LNBTS:sCellActivationMethod=nonGBRBufferBasedStepWise
...    LNBTS:actFlexScellSelect=true
...    LNCEL-1/LNCEL_FDD-0:actAutoPucchAlloc=true
...    LNCEL-2/LNCEL_FDD-0:actAutoPucchAlloc=true
...    LNCEL-3/LNCEL_FDD-0:actAutoPucchAlloc=true
...    LNCEL-4/LNCEL_FDD-0:actAutoPucchAlloc=true
...    LNCEL-5/LNCEL_FDD-0:actAutoPucchAlloc=true
...    LNCEL-1:caPoolId=1
...    LNCEL-2:caPoolId=1
...    LNCEL-3:caPoolId=1
...    LNCEL-4:caPoolId=1
...    LNCEL-5:caPoolId=1
...    LNCEL-1:maxNumScells=4
...    LNBTS:sCellDeactivationTimereNB=infinity
@{CBRS_PARAMS_IN_SCF_TARGET}
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
...    LNBTS-2/CBRSPR-1:channelSpace2020=19.8
@{CA_PARAMS_IN_SCF_TARGET}
...    LNBTS-2:caClusterId=1
...    LNBTS-2:caClusterMemberId=2
...    LNBTS-2/CAGENB-0:caClusterEnbList:lnBtsId=1
...    LNBTS-2/CAGENB-0:caClusterEnbList:numSrioLinks=0
...    LNBTS-2/LNADJ-1:adjEnbId=1
...    LNBTS-2/LNADJ-1:cPlaneIpAddr=10.0.1.2
...    LNBTS-2/LNADJ-1:cPlaneIpAddrCtrl=oamControlled
...    LNBTS-2/LNADJ-1:rlfBasedRCRsupported=false
...    LNBTS-2/LNADJ-1:plmnId:mcc=311
...    LNBTS-2/LNADJ-1:plmnId:mnc=9
...    LNBTS-2/LNADJ-1:plmnId:mncLength=2
...    LNBTS-2:caSchedFairFact=0
...    LNBTS-2:actDLCAggr=true
...    LNBTS-2/LNBTS_TDD-0:actCbrs=true
...    LNBTS-2:actEnhCbrsCAggr=false
...    LNBTS-2:actEnhAcAndGbrServices=true
...    LNBTS-2:actMultBearers=true
...    LNBTS-2:actInterEnbDLCAggr=true
...    LNBTS-2/LNBTS_TDD-0:numTxWithHighNonGbr=0
...    LNBTS-2:actAdvStepwiseScellAdd=off
...    LNBTS-2:sCellActivationMethod=blind
...    LNBTS-2/LNCEL-3/LNCEL_TDD-0:actAutoPucchAlloc=true
...    LNBTS-2/LNCEL-4/LNCEL_TDD-0:actAutoPucchAlloc=true
...    LNBTS-2/LNCEL-5/LNCEL_TDD-0:actAutoPucchAlloc=true
...    LNBTS-2:actFlexScellSelect=true
...    LNBTS-2/LNCEL-3:caPoolId=1
...    LNBTS-2/LNCEL-4:caPoolId=1
...    LNBTS-2:actMultGbrBearers=false
...    LNBTS-2:sCellDeactivationTimereNB=infinity
@{RELATION_ERROR_PARAMS_IN_SCF}
...    LNBTS:actFlexCaMgmt=false
...    LNCEL-1:actCaArchEnhImp=off
...    LNCEL-1:actFlowCtrlEnh=true
...    LNCEL-1:actScellConfigForHiDemand=false
...    LNCEL-2:actCaArchEnhImp=off
...    LNCEL-2:actFlowCtrlEnh=true
...    LNCEL-3:actCaArchEnhImp=off
...    LNCEL-3:actFlowCtrlEnh=true
...    LNBTS:actIscaHarqEnh=false
@{RELATION_ERROR_PARAMS_IN_SCF_TARGET}
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
...    LNBTS-2/LNCEL-3:actUl256QamChQualEst=false
...    LNBTS-2/LNCEL-4:actUl256QamChQualEst=false
...    LNBTS-2/LNCEL-5:caPoolId=1
...    LNBTS-2/LNCEL-5:actCaArchEnhImp=off
...    LNBTS-2/LNCEL-5:actFlowCtrlEnh=true
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
...    LNBTS-2:actAmbrModCaTrigger=false
...    LNBTS-2/LNCEL:eTputInitMcs=20
...    LNBTS-2/LNCEL:eTputFilterConfig=51
${3CA_SUPPORTED_BAND_2A_46A_48A}    2:a:a|2:a:a+46::a|2:a:a+46::a+48::a
${4CA_SUPPORTED_BAND_2A_46C_48A}    2:a:a|2:a:a+46::a|2:a:a+46::c|2:a:a+46::c+48::a
${5CA_SUPPORTED_BAND_2A_46D_48A}    2:a:a|2:a:a+46::a|2:a:a+46::c|2:a:a+46::d|2:a:a+46::d+48::a
${LTE4603_SUPPORTED_BAND}    2,4,5,46,48
${DL_TPUT_1F_1T_1LAA_3CC}    350
${DL_TPUT_1F_1T_2LAA_4CC}    420
${DL_TPUT_1F_1T_3LAA_5CC}    470
${Wait_For_Throughtput_stable}    8s
${ADD_2SCELLS_1LAA}
...    sCellToAddModList-r10 contains (
...    sCellIndex-r10 eq 1 and cellIdentification-r10 contains
...    (physCellId-r10 eq 5 and dl-CarrierFreq-r10 eq 47490)
...    and
...    radioResourceConfigDedicatedSCell-r10 contains (laa-SCellConfiguration-r13 is present),
...    sCellIndex-r10 eq 2 and cellIdentification-r10 contains
...    (physCellId-r10 eq 54 and dl-CarrierFreq-r10 eq 55538))
${ADD_3SCELLS_2LAA}
...    sCellToAddModList-r10  contains (
...    sCellIndex-r10 eq 2 and
...    cellIdentification-r10 contains
...    (physCellId-r10 eq 5 and dl-CarrierFreq-r10 eq 47490)
...    and
...    radioResourceConfigDedicatedSCell-r10 contains (laa-SCellConfiguration-r13 is present),
...    sCellIndex-r10 eq 1 and
...    cellIdentification-r10 contains
...    (physCellId-r10 eq 4 and dl-CarrierFreq-r10 eq 47289)
...    and
...    radioResourceConfigDedicatedSCell-r10 contains (laa-SCellConfiguration-r13 is present),
...    sCellIndex-r10 eq 3 and
...    cellIdentification-r10 contains
...    (physCellId-r10 eq 54 and dl-CarrierFreq-r10 eq 55538))
${ADD_4SCELLS_3LAA}
...    sCellToAddModList-r10 contains (
...    sCellIndex-r10 eq 3 and
...    cellIdentification-r10 contains
...    (physCellId-r10 eq 5 and dl-CarrierFreq-r10 eq 47490)
...    and
...    radioResourceConfigDedicatedSCell-r10 contains (laa-SCellConfiguration-r13 is present),
...    sCellIndex-r10 eq 2 and
...    cellIdentification-r10 contains
...    (physCellId-r10 eq 4 and dl-CarrierFreq-r10 eq 47289)
...    and
...    radioResourceConfigDedicatedSCell-r10 contains (laa-SCellConfiguration-r13 is present),
...    sCellIndex-r10 eq 1 and
...    cellIdentification-r10 contains
...    (physCellId-r10 eq 3 and dl-CarrierFreq-r10 eq 47091)
...    and
...    radioResourceConfigDedicatedSCell-r10 contains (laa-SCellConfiguration-r13 is present),
...    sCellIndex-r10 eq 4 and
...    cellIdentification-r10 contains
...    (physCellId-r10 eq 54 and dl-CarrierFreq-r10 eq 55538))

*** Test Cases ***
LTE4603-A-a-2_1F_1T_1LAA_3CC
    [Documentation]    PCELL ENB1 CELL1; SCELL1 ENB1 CELL5; SCELL2 ENB2 CELL4
    [Tags]
    Attach UE And Scell Additon Successful    ${UE1}    ${3CA_SUPPORTED_BAND_2A_46A_48A}    ${ADD_2SCELLS_1LAA}
    Start Big Tracffic And Wait It Stable    ${UE1}
    verify throughput    ${UE1}    ${DL_TPUT_1F_1T_1LAA_3CC}
    [Teardown]    Common Test Teardown and Recover Env    ue_id=1

LTE4603-A-b-1_1F_1T_2LAA_4CC
    [Documentation]    PCELL ENB1 CELL1; SCELL1 ENB1 CELL4; SCELL2 ENB1 CELL5; SCELL3 ENB2 CELL4;
    [Tags]
    Attach UE And Scell Additon Successful    ${UE2}    ${4CA_SUPPORTED_BAND_2A_46C_48A}    ${ADD_3SCELLS_2LAA}
    Start Big Tracffic And Wait It Stable    ${UE2}
    verify throughput    ${UE2}    ${DL_TPUT_1F_1T_2LAA_4CC}
    [Teardown]    Common Test Teardown and Recover Env    ue_id=2

LTE4603-A-c-6_1F_1T_3LAA_5CC
    [Documentation]    PCELL ENB1 CELL1; SCELL1 ENB1 CELL3; SCELL2 ENB1 CELL4; SCELL3 ENB1 CELL5; SCELL4 ENB2 CELL4;
    [Tags]
    Attach UE And Scell Additon Successful    ${UE3}    ${5CA_SUPPORTED_BAND_2A_46D_48A}    ${ADD_4SCELLS_3LAA}
    Start Big Tracffic And Wait It Stable    ${UE3}
    verify throughput    ${UE3}    ${DL_TPUT_1F_1T_3LAA_5CC}
    [Teardown]    Common Test Teardown and Recover Env    ue_id=3

*** Keywords ***
Common Suite Setup And Setup 2CUS Env
    Common Suite Setup
    Start SAS Server
    Setup 2CUS Env    tl_type=5CELLs_FDD_2B2_25_3B46    tl_type_enb2=2CELLs_FDD_3CELLs_TDD_2B2_2B48
    create alias
    Setup UE parameters

Modify Yaml
    Update Yaml    LOGS/EPC    log_level: 6
    Update Yaml    LOGS/CUS   syslog_mode: ERROR
    Update Yaml    LOGS/CUS   syslog_level: ERROR


Create Alias
    Create UE Alias    UE_1    ue_id=1    id_type=cus
    Create UE Alias    UE_2    ue_id=2    id_type=cus
    Create UE Alias    UE_3    ue_id=3    id_type=cus
    Create Enb Alias    alias=ENB_1    enb_id=1    id_type=wts
    Create Enb Alias    alias=ENB_2    enb_id=2    id_type=wts
    Create MME Alias    alias=MME_1    mme_id=1    id_type=wts

Setup UE parameters
    Execute Egate Command    trace uec=1 mme=1 protocol=rrc,nr_rrc,s1,x2 on
    Execute Egate Command    trace_sim enb=1 protocol=x2,s1 on
    Execute Egate Command    trace_sim enb=2 protocol=x2,s1 on

Attach UE And Scell Additon Successful
    [Arguments]    ${ue_id}    ${band_combination}    ${scell_addition}
    run uex command    turbo_mode_l2    cell=1    mode=enable
    ${V_2}    catenate
    ...    ue_param id=${ue_id} ca_supported_bands=${band_combination} supported_bands=${LTE4603_SUPPORTED_BAND}
    execute uex command    ${V_2}
    expect message flow
    ...    UE_${ue_id}:RRC_RRCConnectionReconfiguration (${scell_addition})
    ...    alias=scell_addition    overall_timeout=30
    execute uex command    ue_attach id=${ue_id} enb=1 cell=1
    flow occurred as expected      alias=scell_addition

Start Big Tracffic And Wait It Stable
    [Arguments]    ${ue_id}
    execute uex command    trf_data_start ue=${ue_id} dir=dl protocol=udp trf_id=1 Mbps=500
    execute uex command    trf_data_start ue=${ue_id} dir=dl protocol=udp trf_id=2 Mbps=250
    execute uex command    trf_data_start ue=${ue_id} dir=ul protocol=udp Mbps=7
    Sleep    ${Wait_For_Throughtput_stable}
    #run uex command    ue_stats clear    id=${ue_id}

verify throughput
    [Arguments]    ${ue_id}    ${dl_tput_expected}
    ${throughput}        Get Throughput    ue_id=${ue_id}
    Should Be True    ${throughput["UE"]["Overall"]["cur"]} > ${dl_tput_expected}
    Should Be True    ${throughput["UE"]["Overall"]["avg"]} > ${dl_tput_expected}
    Should Be True    ${throughput["UE"]["Overall"]["max"]} > ${dl_tput_expected}

Common Test Teardown and Recover Env
    [Arguments]    ${ue_id}
    execute uex command    ue_detach id=${ue_id}
    Common Test Teardown And Stop Capture Logs
