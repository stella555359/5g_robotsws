*** Settings ***
Suite Setup       Common Suite Setup And Setup Airphone Env
Suite Teardown    Common Suite Teardown And Restore BTS Configuration Parameters
Test Setup        Common Test Setup And Start To Capture Logs
Test Teardown     Common Test Teardown And Stop Capture Logs
Force Tags    QCD_MN_RAN    QCP_RAN_ET    RAN_5G    RAN_5G_TDD    SBTS00    CRT    CLOUD_5G_I_MP_AP_LO
...           owner-jia.pan    team-CN1ET    release-SBTS24R1
Resource    ../../../../resources/DevHZ5_resource.robot

*** Variables ***
${SYSCOM_FLAG}    ${True}

@{PARAMS_IN_SCF}
...    @{CB008227_parameters}
...    @{HPA_related}
...    NRBTS-1:actMultiDrbNSA=true

@{CB008227_parameters}
...    NRCELL-1:congDetectPeriod=ms100
...    NRCELL-2:congDetectPeriod=ms100
...    NRBTS-1:actNonGbrServiceDiff=true
...    NRCELL-1:actNbrForNonGbrBearers=true
...    NRCELL-1:congWeightAlg=arpPrioPerVul
...    NRCELL-1:maxNbrTrafficLimit=80
...    NRCELL-1:maxPrbsPerNbrUe=30
...    NRCELL-1:nbrPdcchCongHandlingDl=true
...    NRCELL-1:nbrPdcchCongHandlingUl=true
...    NRCELL-1:nbrPdschCongHandling=true
...    NRCELL-1:nbrPuschCongHandling=true
...    NRCELL-2:actNbrForNonGbrBearers=true
...    NRCELL-2:congWeightAlg=arpPrioPerVul
...    NRCELL-2:maxNbrTrafficLimit=80
...    NRCELL-2:maxPrbsPerNbrUe=30
...    NRCELL-2:nbrPdcchCongHandlingDl=true
...    NRCELL-2:nbrPdcchCongHandlingUl=true
...    NRCELL-2:nbrPdschCongHandling=true
...    NRCELL-2:nbrPuschCongHandling=true
...    NRBTS-1/NRDRB_5QI-80:fiveqiValueList=80
...    NRBTS-1/NRDRB_5QI-80:nrDrbDN=MRBTS-1/NRBTS-1/NRDRB-14
...    NRBTS-1/NRDRB_MAC-1:nbrDl=500
...    NRBTS-1/NRDRB_MAC-1:nbrUl=100
...    NRBTS-1/NRDRB_MAC-1:schedulBSD=1000ms
...    NRBTS-1/NRDRB_MAC-4:nbrDl=10
...    NRBTS-1/NRDRB_MAC-4:nbrUl=10
...    NRBTS-1/NRDRB_MAC-4:schedulBSD=50ms
...    NRCELL:maxNumOfNbrBearers=1
...    NRBTS/NRDRB-13:nrDrbMacDN=MRBTS-1/NRBTS-1/NRDRB_MAC-1
...    NRBTS/NRDRB-13:priorityLevel=80
...    NRBTS/NRDRB-14:priorityLevel=68
...    NRBTS/NRDRB-14:nrDrbMacDN=MRBTS-1/NRBTS-1/NRDRB_MAC-2

@{HPA_related}
...    NRCELL-2:actPriorityAccess=true
...    NRBTS:applyPriorityAccess=HPA
...    NRBTS/NRPRIOACC_PROFILE-1:nrPlmnIdx=1
...    NRBTS/NRPRIOACC_PROFILE-1:arpPrioLevelHpaMax=8
...    NRBTS/NRPRIOACC_PROFILE-1:arpPrioLevelHpaMin=6
...    NRBTS/NRPRIOACC_PROFILE-1:arpPrioLevelMpsMax=4
...    NRBTS/NRPRIOACC_PROFILE-1:arpPrioLevelMpsMin=1
...    NRCELL-2:raPrioritizationForAI=MPS+MCS
...    NRCELL-2:powerRampingStepHighPriorityCbra=dB4
...    NRCELL-2:powerRampingStep=dB2
...    NRCELL-2:pagingPrioLevelPaMax=1
...    NRCELL-2:pagingPrioLevelPaMin=1
...    NRCELL-2:tPageCorrInt=3000

@{OnlineParam_C001_C003}
...    NRCELL:maxNumOfNbrBearers=0

@{OnlineParam_Recovery}
...    NRCELL:maxNumOfNbrBearers=1

@{pm_counter_Check_C001}
...    NRCELL-1:${SA_DU_DRB_NBR_DL}>1
...    NRCELL-1:${SA_DU_DRB_NBR_UL}>1
...    NRCELL-1:${SA_DRB_NBR_DENOM}>1
...    NRCELL-1:${SA_DU_DRB_NBR_REQ}=3
...    NRCELL-1:${SA_DU_DRB_NBR_ADMIT_WITH_NBR}=1    #After CB008227-E-UPD002
...    NRCELL-1:${SA_DU_DRB_NBR_ADMIT_NOT_NBR}=2    #After CB008227-E-UPD002

@{pm_counter_Check_C003}
...    NRCELL-2:${SA_DU_DRB_NBR_DL}>1
...    NRCELL-2:${SA_DU_DRB_NBR_UL}>1
...    NRCELL-2:${SA_DRB_NBR_DENOM}>1
...    NRCELL-2:${SA_DU_DRB_NBR_REQ}=3
...    NRCELL-2:${SA_DU_DRB_NBR_ADMIT_WITH_NBR}=3

...    NRCELL-2:${NSA_DU_DRB_NBR_DL}=0    #After CB008227-E-UPD002
...    NRCELL-2:${NSA_DU_DRB_NBR_UL}=0    #After CB008227-E-UPD002
...    NRCELL-2:${NSA_DRB_NBR_DENOM}>1
...    NRCELL-2:${NSA_DU_DRB_NBR_REQ}=2
...    NRCELL-2:${NSA_DU_DRB_NBR_ADMIT_WITH_NBR}=0    #After CB008227-E-UPD002
...    NRCELL-2:${NSA_DU_DRB_NBR_ADMIT_NOT_NBR}=2    #After CB008227-E-UPD002

${SA_DU_DRB_NBR_DL}    M55139C03509    #Cumulative number of non-GBR bearers with configured NBR in DL for SA    
${SA_DU_DRB_NBR_UL}    M55139C03510    #Cumulative number of non-GBR bearers with configured NBR in UL for SA
${SA_DRB_NBR_DENOM}    M55139C03511    #Denominator for NBR DRB counters for SA
${SA_DU_DRB_NBR_REQ}    M55139C03506    #Number of non-GBR bearers with configured NBR admission requests for SA
${SA_DU_DRB_NBR_ADMIT_WITH_NBR}    M55139C03507    #Non-GBR bearers with configured NBR successfully admitted with applying NBR during RAC for SA
${SA_DU_DRB_NBR_ADMIT_NOT_NBR}    M55139C03508    #Number of non-GBR bearers with configured NBR admitted without applying NBR during RAC for SA

${NSA_DU_DRB_NBR_DL}    M55115C03509    #Cumulative number of non-GBR bearers with configured NBR in DL for NSA 
${NSA_DU_DRB_NBR_UL}    M55115C03510    #Cumulative number of non-GBR bearers with configured NBR in UL for NSA
${NSA_DRB_NBR_DENOM}    M55115C03511    #Denominator for NBR DRB counters for NSA
${NSA_DU_DRB_NBR_REQ}    M55115C03506    #Number of non-GBR bearers with configured NBR admission requests for NSA
${NSA_DU_DRB_NBR_ADMIT_WITH_NBR}    M55115C03507    #Non-GBR bearers with configured NBR successfully admitted with applying NBR during RAC for NSA
${NSA_DU_DRB_NBR_ADMIT_NOT_NBR}    M55115C03508    #Number of non-GBR bearers with configured NBR admitted without applying NBR during RAC for NSA

*** Test Cases ***
CB008227-ET_C001_NBR_DRB_Should_be_admit_as_normal_Non-GBR-DRB_as_NBR_bearers_Exceed_Cell_NBR_max_amount_Limitationin_when_ICSsetup_withoutPDU_SA
    [Documentation]
    ...    1. This user scenario describes the gNB behavior for UE with Nominal Bit Rate of nonGBR bearers setup with Initial Context Setup (SA)
    ...    2. Configuration:
    ...       cell id=1 gnb=2 pci=16:2 band:n78 tdd_cell=on chBw=100MHz
    ...       configure 5QI-8:MRBTS-1/NRBTS-1/NRDRB-13: MRBTS-1/NRBTS-1/NRDRB_MAC-1: with NBR configured; Qosflow id=2; default =on
    ...    3. Test Case Steps:
    ...        1.Trigger UE1 and UE2 register to Cell1 without PDU,Setup PDU for UE1 and UE2 and Start traffic
    ...        2.onlinemodify parameter: maxNumOfNbrBearers=0
    ...        3.UE 3(with NBR normal call) register to cell-1 and start traffic 
    ...    4. Expected Results:
    ...        1.UE1 should register with NBR,UE2 should register as normal nonGBR DRB,no traffic lost 
    ...        2.online modify successfully  
    ...        3.UE3 should register without NBR(After CB008227-E-UPD002),no traffic lost 
    [Tags]    QC_323231    C001    jia.pan
    Clear Counter Files    ${False}
    ICS Without PDU    ue_id=1    cell_id=1    qos_flow=2    pdu=1
    ICS Without PDU    ue_id=2    cell_id=1    qos_flow=2    pdu=2
    Sent Traffic and Verify Throughput for UE1UE2
    OnlineParamChange    ${OnlineParam_C001_C003}
    Ue register and pdu session setup   
    Verify Throughput for UE1UE2  
    check counters    ${pm_counter_Check_C001}
    Check Wireshark Log    ${CURDIR}${/}a2a_C001${/}a2a.ini    wait_string=UEContextModificationResponse::16
    [Teardown]    C001C003_Teardown
	
CB008227-ET_C003_NBR_should_be_Configured_with_maxNumOfNbrBears_is_equal_to_0_with_HPA_CALL_SA
    [Documentation]
    ...    1. This user scenario describes the gNB behavior for UE with Nominal Bit Rate of nonGBR bearers setup with Initial Context Setup (SA)
    ...    2. Configuration:
    ...       cell id=2 gnb=2 pci=17:0 band:n78 tdd_cell=on chBw=100MHz
    ...       configure 5QI-8:MRBTS-1/NRBTS-1/NRDRB-13: MRBTS-1/NRBTS-1/NRDRB_MAC-1: with NBR configured; Qosflow id=2; default =on
    ...    3. Test Case Steps:
    ...        1.Trigger UE1 and UE2 register to Cell2 as SA HPA call,setup PDU and Start traffic
    ...        2.Trigger UE3 register to Cell2 as SA normal call,setup PDU and Start traffic
    ...        3.Trigger UE4 register to Cell2 as NSA normal call and Start traffic
    ...        4.Onlinemodify parameter: maxNumOfNbrBearers=0
    ...        5.Add drb to setup up normal call with NBR on UE4 and Start traffic
    ...    4. Expected Results:
    ...        1.setup successfully. AC NBR is ignored with NBR configuration applied.
    ...        2.setup successfully with NBR configuration applied.
    ...        3.setup successfully without NBR configuration applied.
    ...        4.online modify successfully .
    ...        5.Normal call access successfully without NBR configuration(After CB008227-E-UPD002).
    [Tags]    QC_323233    C003    jia.pan
    Clear Counter Files
    ICS With HPA    ue_id=1    cell_id=2
    ICS With HPA    ue_id=2    cell_id=2
    Ue register and pdu session setup    ue_id=3    cell_id=2
    NSA UE attach and OnlineChange then Add Bear
    check counters    ${pm_counter_Check_C003}	
    Check Wireshark Log    ${CURDIR}${/}a2a_C003${/}a2a.ini    wait_string=UEContextModificationResponse::16
    [Teardown]    C001C003_Teardown

*** Keywords ***
Common Suite Setup And Setup Airphone Env
    Common Suite Setup
    Setup Airphone Env    tl_type=tdd_sansa_cmwv/FS/2cells_ecpri

OnlineParamChange
    [Arguments]    ${Online_Param}
    Delta Commission Parameters    ${Online_Param}
    Cells Should Be Onair

C001C003_Teardown
    OnlineParamChange    ${OnlineParam_Recovery}
    Common Test Teardown And Stop Capture Logs

Modify Cfg
    Update Cfg    set_qosflow id=1 5qi=6 default=off
    Update Cfg    set_qosflow id=2 5qi=8 default=on 
    Update Cfg    set_qosflow id=3 5qi=80
    Update Cfg    set_bearer id=3 ue=31 qci=8 pdn=1 preprovisioned=on filter=0 precedence=0

ICS With HPA
    [Arguments]    ${ue_id}    ${cell_id}    ${pdu}=1 
    ${cmd}    catenate    ue_pdu_session_setup ue=${ue_id} pdu=${pdu} gw=1 nwslice=1
    Execute Egate Command    ue_change_location id=${ue_id} enb=2 cell=${cell_id}
    Execute Egate Command    ue_nr_rrc_setup_param id=${ue_id} establishment_cause=highPriorityAccess
    Execute Egate Command    qosflow_modify qos_flow=2 default=on priority=7
    Execute Egate Command    ue_register id=${ue_id}    UE now in NG RM Register
    Execute Egate Command    set_pdu_param ue=${ue_id} pdu=${pdu} trf_type=internal
    Execute Egate Command    ${cmd}    pass_regexp=Setup QosFlow with QFI:1 fiveQI:8
    Sent Traffic    ${ue_id}    ${pdu}
    Wait Until Keyword Succeeds    30s    15s    Verify Throughput    ${ue_id}    ${pdu}

ICS Without PDU
    [Arguments]    ${ue_id}=1    ${cell_id}=1    ${qos_flow}=2    ${pdu}=1
    Execute Egate Command    ue_change_location id=${ue_id} enb=2 cell=${cell_id}
    Execute Egate Command    amf_param id=1 send_ics_registration=on
    Execute Egate Command    ue_register id=${ue_id}    UE now in NG RM Register
    PDU_Session_setup    ue_id=${ue_id}    qos_flow=${qos_flow}    pdu=${pdu}
    ...    pass_regexp=Setup QosFlow with QFI:1 fiveQI:8
    Execute Egate Command    amf_param id=1 send_ics_registration=off

PDU_Session_setup
    [Arguments]    ${ue_id}=1    ${qos_flow}=2    ${pdu}=1    ${pass_regexp}=None
    Execute Egate Command    qosflow_modify default=on qos_flow=${qos_flow}
    Execute Egate Command    set_pdu_param ue=${ue_id} pdu=${pdu} trf_type=internal
    Execute Egate Command    ue_pdu_session_setup ue=${ue_id} pdu=${pdu} gw=${pdu} nwslice=1
    ...    pass_regexp=${pass_regexp}
  
Ue register and pdu session setup
    [Arguments]    ${ue_id}=3    ${cell_id}=1
    Execute Egate Command    ue_change_location id=${ue_id} enb=2 cell=${cell_id}
    Execute Egate Command    ue_register id=${ue_id}    UE now in NG RM Register
    Execute Egate Command    set_pdu_param ue=${ue_id} pdu=3 trf_type=internal
    Execute Egate Command    ue_pdu_session_setup ue=${ue_id} pdu=3 nwslice=1 gw=3    pass_regexp=Setup QosFlow with QFI:1 fiveQI:8
    Sent Traffic    ${ue_id}    ${ue_id}
    Wait Until Keyword Succeeds    30s    15s    Verify Throughput    ${ue_id}    ${ue_id}

NSA UE attach and OnlineChange then Add Bear
    [Arguments]    ${ue_id}=31    ${cell_id}=2
    Execute Egate Command    ue_attach id=${ue_id}    UE IS ACTIVE
    Execute Egate Command    ue_dc_enb_start ue=${ue_id} target_gnb=2 target_cells=${cell_id} bearer=2 type=split_scg    successful RA
    Send Throuput NSA
    Wait Until Keyword Succeeds    30s    15s    Verify Throughput NSA
    OnlineParamChange    ${OnlineParam_C001_C003}
    ${cmd}    catenate    enb_ue_dc_modify ue=31 bearer_to_add=3 by=enb cause=RN_CauseRadioNetwork_unspecified type=split_scg
    Execute Egate Command    ${cmd}    pass_regexp=SgNBReconfigurationComplete
    Send Throuput NSA    31    3
    Wait Until Keyword Succeeds    30s    15s    Verify Throughput NSA    31    3

Sent Traffic and Verify Throughput for UE1UE2
    Sent Traffic
    Sent Traffic    2    2
    Wait Until Keyword Succeeds    30s    15s    Verify Throughput
    Wait Until Keyword Succeeds    30s    15s    Verify Throughput    2    2

Verify Throughput for UE1UE2
    Wait Until Keyword Succeeds    30s    15s    Verify Throughput
    Wait Until Keyword Succeeds    30s    15s    Verify Throughput    2    2

Send Throuput NSA
    [Arguments]    ${ue_id}=31    ${bearer_id}=2  
    Execute Egate Command    data_trf_start ue=${ue_id} id=${bearer_id} dir=dl mbps=2 trf_id=1    UE ${ue_id}: UDP DL
    Execute Egate Command    data_trf_start ue=${ue_id} id=${bearer_id} dir=ul mbps=1 trf_id=1    UE ${ue_id}: UDP UL

Sent Traffic
   [Arguments]    ${ue_id}=1    ${pdu1}=1
    Execute Egate Command    trf_data_start ue=${ue_id} pdu=${pdu1} qfi=1 dir=dl mbps=2 trf_id=1    pass_regexp=Started Downlink
    Execute Egate Command    trf_data_start ue=${ue_id} pdu=${pdu1} qfi=1 dir=ul mbps=1 trf_id=1    pass_regexp=Started Uplink

Verify Throughput 
    [Arguments]    ${ue_id}=1    ${pdu}=1    ${Tput_dl}=1.8    ${Tput_ul}=0.9    ${sleep_time}=10s    ${qfi}=1   
    sleep    ${sleep_time}    sleep for Tput stable
    ${dl_throughput}    Ap Get SA Throughput    ue_id=${ue_id}    pdu=${pdu}    qfi=1    direction=dl    rate_type=ave
    ${ul_throughput}    Ap Get SA Throughput    ue_id=${ue_id}    pdu=${pdu}    qfi=1    direction=ul    rate_type=ave
    Should Be True    ${dl_throughput}/1000>${Tput_dl}
    Should Be True    ${ul_throughput}/1000>${Tput_ul}
	
Verify Throughput NSA
    [Arguments]    ${ue_id}=31    ${bearer_id}=2    ${Tput_dl}=1.8    ${Tput_ul}=0.9    ${sleep_time}=10s    ${qfi}=1   
    sleep    ${sleep_time}    sleep for Tput stable
    ${ul_Throughput}    Ap Get NSA Throughput    ue_id=${ue_id}    bearer_id=${bearer_id}    direction=ul    dc_cell_group=all    rate_type=ave
    ${dl_Throughput}    Ap Get NSA Throughput    ue_id=${ue_id}    bearer_id=${bearer_id}    direction=dl    dc_cell_group=all    rate_type=ave
    Should Be True    ${ul_Throughput}/1000>${Tput_ul}
    Should Be True    ${dl_Throughput}/1000>${Tput_dl}
