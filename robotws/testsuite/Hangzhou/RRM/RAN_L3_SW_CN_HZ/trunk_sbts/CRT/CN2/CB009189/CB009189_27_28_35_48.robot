*** Settings ***
Suite Setup    Common Suite Setup And Setup Airphone Env
Suite Teardown    Common Suite Teardown And Restore BTS Configuration Parameters
Test Setup    Common Test Setup And Start To Capture Logs
Test Teardown    Common Test Teardown And Stop Capture Logs
Force Tags    QCD_MN_RAN    QCP_RAN_ET    SBTS00    RAN_5G    RAN_5G_TDD    team-Beam    owner-meredith.ma
...    CLOUD_5G_I_LO_AP_LO_SANSA_FS_ECPRI_CMWV_TDD    CRT    CB009189    release-SBTS23R1
...    STATE_CONFIGURED
Resource    ../../../../resources/DevHZ5_resource.robot

*** Variables ***
${TL_TYPE_PATH}    tdd_sansa_cmwv/FS/2cells_ecpri
${OOO_UE_Capabilities}    SEPARATOR=
...    E1A03000074E5A031E0003832001E09306400043C2400C4034026010180E01951B0A3582028680965944C2403D6C10101070EF1C39061C001
...    03278FAB80027800E0009E00151B133582028680965944C2403D6C10101070EF1C39061C00103278FAB80027800E0009E00151B1375820286
...    80965944C2403D6C10101070EF1C39061C00103278FAB80027800E0009E00151B13B582028680965944C2403D6C10101070EF1C39061C0010
...    3278FAA8000028000000841C4D000000002026878003804044F613003000281C1401C0C026007000683E0000000000000E54D000100000965
...    950034AAA84801C002C00000010020046AC4C0004080C1014181C202C4044484C648494989CA1288A0

@{PARAMS_IN_SCF}
...    NRBTS-1:cipherPrefL:nea0=8
...    NRBTS-1:cipherPrefL:nea1_128=0
...    NRBTS-1:cipherPrefL:nea2_128=0
...    NRBTS-1:cipherPrefL:nea3_128=0
...    NRBTS/NRDRB_PDCP-2:outOfOrderDeliveryDl=true
...    NRBTS/NRDRB_PDCP-2:outOfOrderDeliveryUl=false
...    NRBTS-1:actServiceAwarePDCPConfig=true

...    NRCELL-1:actVoNR=true
...    NRCELL-1:actEnhancedVoNR=true
...    NRBTS/NRDRB-15:actDddsReduction=false
...    NRBTS/NRDRB-15:actLostPduFastRetx=false
...    NRBTS/NRDRB-15:discardTimer=200ms
...    NRBTS/NRDRB-15:discardTimerUl=200ms
...    NRBTS/NRDRB-13:discardTimer=10ms
...    NRBTS/NRDRB-14:discardTimer=10ms
...    NRBTS/NRDRB-13:discardTimerUl=1500ms
...    NRBTS/NRDRB-14:discardTimerUl=500ms
...    NRBTS/NRDRB-15:dlFlowControlAlgo=none
...    NRBTS/NRDRB-15:dscp=34
...    NRBTS/NRDRB-15:l2OHFactorDl=16
...    NRBTS/NRDRB-15:l2OHFactorUl=35
...    NRBTS/NRDRB-15:maxDataRateGbrDl=30720
...    NRBTS/NRDRB-15:maxDataRateGbrUl=30720
...    NRBTS/NRDRB-15:maxDddsPeriodCpuOvld=40
...    NRBTS/NRDRB-15:maxRlcQueueingDelayGbr=20
...    NRBTS/NRDRB-15:maxTransferDelayGbr=20
...    NRBTS/NRDRB-15:nrDrbMacDN=MRBTS-1/NRBTS-1/NRDRB_MAC-5
...    NRBTS/NRDRB-15:nrDrbPdcpDN=MRBTS-1/NRBTS-1/NRDRB_PDCP-3
...    NRBTS/NRDRB-15:nrDrbRlcUmDN=MRBTS-1/NRBTS-1/NRDRB_RLC_UM-1
...    NRBTS/NRDRB-15:numSduDiscard=1
...    NRBTS/NRDRB-15:queuingDelayDiscarding=Disabled
...    NRBTS/NRDRB-15:queuingDelaySduDiscardThreshold=750
...    NRBTS/NRDRB-15:resType=GBR
...    NRBTS/NRDRB-15:rlcMode=RLC_UM
...    NRBTS/NRDRB-15:schedulWeight=1
...    NRBTS/NRDRB-15:sduDiscardIntervalTmr=500
...    NRBTS/NRDRB-15:nsaDrbParam:actPrioritizeX2AfterInactivity=true
...    NRBTS/NRDRB-15:nsaDrbParam:actX2DuplicateTxNSA3x=false
...    NRBTS/NRDRB-15:nsaDrbParam:dlDataSplitBufferBuildUpThreshold=5
...    NRBTS/NRDRB-15:nsaDrbParam:dlDataSplitBufferBuildUpThresholdPrioritizeX2=5
...    NRBTS/NRDRB-15:nsaDrbParam:dlDataSplitGainThreshold=5
...    NRBTS/NRDRB-15:nsaDrbParam:dlDataSplitMode=dlOverF1UX2U
...    NRBTS/NRDRB-15:nsaDrbParam:inactivityThresholdForPrioritizeX2=300
...    NRBTS/NRDRB-15:nsaDrbParam:inactivityThresholdForRestartPrioritizeX2=100
...    NRBTS/NRDRB-15:nsaDrbParam:inactPeriodX2PdcpDuplication=300
...    NRBTS/NRDRB-15:nsaDrbParam:initialDLTrafficRouting=initDLoverX2U
...    NRBTS/NRDRB-15:nsaDrbParam:nsa3xBearerAllowed=true
...    NRBTS/NRDRB-15:nsaDrbParam:prioritizeX2Period=500
...    NRBTS/NRDRB-15:nsaDrbParam:ulDataPath=ulOverNr
...    NRBTS/NRDRB-15:nsaDrbParam:ulDataSplitThreshold=infinity
...    NRBTS/NRDRB-15:nrDrbRlcAmDN=${EMPTY}
...    NRBTS/NRDRB_5QI-6:fiveqiValueList=1
...    NRBTS/NRDRB_5QI-5:fiveqiValueList=80
...    NRBTS/NRDRB_5QI-6:nrDrbDN=MRBTS-1/NRBTS-1/NRDRB-15
...    NRBTS/NRDRB_MAC-5:delayTarget=50
...    NRBTS/NRDRB_MAC-5:lcgid=4
...    NRBTS/NRDRB_MAC-5:schedulBSD=5ms
...    NRBTS/NRDRB_MAC-5:schedulPrio=5
...    NRBTS/NRDRB_PDCP-3:cuFlowControlProfId=1
...    NRBTS/NRDRB_PDCP-3:pdcpBufDiscardEnabled=false
...    NRBTS/NRDRB_PDCP-3:pdcpBufDiscardThreshold=20000
...    NRBTS/NRDRB_PDCP-3:pdcpDelayThreshRetxMode=disabled
...    NRBTS/NRDRB_PDCP-3:tReorderingDl=ms100
...    NRBTS/NRDRB_PDCP-3:tReorderingUl=ms100
...    NRBTS/NRDRB_PDCP-3:xxFlowControlProfForCuIdx=1
...    NRBTS/NRDRB_RLC_UM-1:dlTReassemblyUm=ms40
...    NRBTS/NRDRB_RLC_UM-1:rlcUMDrbSNLength=rlcUm12bitSN
...    NRBTS/NRDRB_RLC_UM-1:ulTReassemblyUm=ms40
...    NRBTS/NRDRB_PDCP-1:outOfOrderDeliveryDl=true
...    NRBTS/NRDRB_PDCP-1:outOfOrderDeliveryUl=true
...    NRBTS/NRDRB_PDCP-3:outOfOrderDeliveryDl=true
...    NRBTS/NRDRB_PDCP-3:outOfOrderDeliveryUl=true
...    NRBTS:drbInactivityTimerSA5qi1=60
...    NRBTS:drbInactivityTimerSA5qi5=60
...    NRBTS/NRDRB_PDCP-4:cuFlowControlProfId=1
...    NRBTS/NRDRB_PDCP-4:pdcpBufDiscardEnabled=true
...    NRBTS/NRDRB_PDCP-4:pdcpBufDiscardThreshold=20000
...    NRBTS/NRDRB_PDCP-4:pdcpDelayThreshRetxMode=disabled
...    NRBTS/NRDRB_PDCP-4:tReorderingDl=ms100
...    NRBTS/NRDRB_PDCP-4:tReorderingUl=ms100
...    NRBTS/NRDRB_PDCP-4:xxFlowControlProfForCuIdx=1
...    NRBTS/NRDRB_PDCP-4:outOfOrderDeliveryDl=true
...    NRBTS/NRDRB_PDCP-4:outOfOrderDeliveryUl=true
...    NRBTS/NRDRB-14:nrDrbPdcpDN=MRBTS-1/NRBTS-1/NRDRB_PDCP-4
...    NRBTS/NRDRB_PDCP-2:outOfOrderDeliveryUl=true


@{PARAMS_To_Change27_F}
...    NRBTS/NRDRB_PDCP-2:outOfOrderDeliveryUl=false

@{PARAMS_To_Change27_T}
...    NRBTS/NRDRB_PDCP-2:outOfOrderDeliveryUl=true


@{PARAMS_To_Change35}
...    NRBTS/NRDRB_PDCP-4:outOfOrderDeliveryUl=false
...    NRBTS/NRDRB_PDCP-4:outOfOrderDeliveryDl=false

@{PARAMS_To_Change48}
...    NRBTS/NRDRB-13:discardTimer=20ms
...    NRBTS/NRDRB-14:discardTimer=20ms
...    NRBTS/NRDRB-13:discardTimerUl=10ms
...    NRBTS/NRDRB-14:discardTimerUl=10ms

${MAX_NUM_OOD_CAP_UE}    M55181C00001    #Maximum number of OutOfOrderDelivery capable UEs
${AVG_NUM_OOD_CAP_UE_NOM}    M55181C00002    #Average number of OutOfOrderDelivery capable Ues Numerator
${AVG_NUM_UE_DENOM}    M55181C00003    #Average number of UEs denominator


@{PM_Counters_Check_A28}
...    NRCELL-1:NUEQN:${MAX_NUM_OOD_CAP_UE}=0
...    NRCELL-1:NUEQN:${AVG_NUM_OOD_CAP_UE_NOM}=0
...    NRCELL-1:NUEQN:${AVG_NUM_UE_DENOM}>=299
...    NRCELL-1:NUEQN:${AVG_NUM_UE_DENOM}<=300

@{PM_Counters_Check_A35_1}
...    NRCELL-1:NUEQN:${MAX_NUM_OOD_CAP_UE}=1
...    NRCELL-1:NUEQN:${AVG_NUM_UE_DENOM}>=299
...    NRCELL-1:NUEQN:${AVG_NUM_UE_DENOM}<=300

@{PM_Counters_Check_A35_2}
...    NRCELL-1:NUEQN:${MAX_NUM_OOD_CAP_UE}=1
...    NRCELL-1:NUEQN:${AVG_NUM_OOD_CAP_UE_NOM}=300
...    NRCELL-1:NUEQN:${AVG_NUM_UE_DENOM}>=299
...    NRCELL-1:NUEQN:${AVG_NUM_UE_DENOM}<=300

*** Test Cases ***
CB009189_27_SA_DRB_setup_wo_outoforder_then_uplink_only_ue_not_support
    [Documentation]
    ...    1. This user scenario porpuse is to verify the PDCP behavior for the transmission when DRB set up with out of order
    ...    2. Configuration
    ...    configuration on BTS
    ...    a.FR1 TDD cells are configured with frequency NRF1 in band n78 with 100MHz bandwidths.
    ...    b.NRF1 cell has NRCELL-cellDepType set to SA or both
    ...    c.NRBTS/NRDRB_PDCP/outOfOlrderDeliveryDl = true , outOfOrderDeliveryUl = false
    ...    3. Test Case Steps:
    ...    a.UE attach and set up PDU session.A non-VoNR SA DRB is set up without out of order PDCP delivery.
    ...    b.UE detach.
    [Tags]    QC_220155
    OnlineParamChange    ${PARAMS_To_Change27_F}
    Start UE Attach UE not support outoforder    ue_id=1
    OnlineParamChange    ${PARAMS_To_Change27_T}
    Start UE Attach UE not support outoforder    ue_id=2
    Check Wireshark Log    ${CURDIR}${/}a2a_CB009189_27${/}a2a.ini    wait_string=UEContextReleaseComplete::4
    Check RRC Log    ${CURDIR}${/}a2a_CB009189_27${/}a2a.ini

CB009189_28_SA_VoNR_DRB_setup_wo_outoforder_both_link
    [Documentation]
    ...    1. This user scenario porpuse is to verify the PDCP behavior for the transmissilon when DRB set up with out of order
    ...    2. Configuration
    ...    configuration on BTS
    ...    a.FR1 TDD cells are configured with frequency NRF1 in band n78 with 100MHz bandwidths.
    ...    b.NRF1 cell has NRCELL-cellDepType set to SA or both
    ...    c.NRBTS/NRDRB_PDCP/outOfOrderDeliveryDl = true , outOfOrderDeliveryUl = true
    ...    3. Test Case Steps:
    ...    a.UE attach and set up PDU session.5QI-1 DRB is set up without out of order PDCP delivery.
    ...    b.UE detach.
    [Tags]    QC_222502
    UE Attach To Target Cell    ue_id=1    cell_id=1
    PDU Add QoSFlow 5QI5    ue_id=1
    PDU Add QoSFlow 5QI1    ue_id=1
    UE Deregister From gNB    ue_id=1
    Clear Counter Files
    Check Counters    ${PM_Counters_Check_A28}
    Check Wireshark Log    ${CURDIR}${/}a2a_CB009189_28${/}a2a.ini    wait_string=UEContextReleaseComplete::4
    Check RRC Log    ${CURDIR}${/}a2a_CB009189_28${/}a2a.ini

CB009189_35_SA_online_modification_Multiple_DRBs_for_outoforder_both_link
    [Documentation]
    ...    1. The purpose of this test case is to verify the PDCP behavior for the transmission when DRB set up with out of order.
    ...    2. Configuration
    ...    configuration on BTS
    ...    a.FR1 TDD cells are configured with frequency NRF1 in band n78 with 100MHz bandwidths.
    ...    b.NRF1 cell has NRCELL-cellDepType set to SA or both
    ...    c.NRBTS/NRDRB_PDCP/outOfOrderDeliveryDl = true , outOfOrderDeliveryUl = true for 5QI_8
    ...    d.NRBTS/NRDRB_PDCP/outOfOrderDeliveryDl = true , outOfOrderDeliveryUl = true for 5QI_80
    ...    3. Test Case Steps:
    ...    a.UE attach and set up PDU session.5QI_8 is setup with out of order
    ...    b.online change:NRBTS/NRDRB_PDCP/outOfOrderDeliveryDl = false , outOfOrderDeliveryUl = false for 5QI_80.
    ...    c.Add 5QI_80 drb which is setup with out of order.
    ...    d.UE detach.
    [Tags]    QC_222499
    Clear Counter Files
    UE Attach To Target Cell    ue_id=1    cell_id=1
    Send And Verify Throuput    qfi_id=1    ue_id=1    pdu_id=1
    OnlineParamChange    ${PARAMS_To_Change35}
    PDU Add QoSFlow 5QI80    ue_id=1
    A35 counters check
    UE Deregister From gNB    ue_id=1
    Check Wireshark Log    ${CURDIR}${/}a2a_CB009189_35${/}a2a.ini    wait_string=UEContextReleaseComplete::4
    Check RRC Log    ${CURDIR}${/}a2a_CB009189_35${/}a2a.ini

CB009189_48_SA_Online_change_MixGBR_DRB_setup_with_PDCP_Discard_Timer_UL_configured
    [Documentation]
    ...    1. The purpose of this test case is to verify the PDCP behavior for the transmission when DRB set up with discardtimer.
    ...    2. Configuration
    ...    configuration on BTS
    ...    a.FR1 TDD cells are configured with frequency NRF1 in band n78 with 100MHz bandwidths.
    ...    b.NRF1 cell has NRCELL-cellDepType set to SA or both
    ...    c.NRBTS/NRDRB/discardTimer=10ms , NRBTS/NRDRB/discardTimerUL=1500ms for 5QI=8
    ...    d.NRBTS/NRDRB/discardTimer=10ms , NRBTS/NRDRB/discardTimerUL=500ms for 5QI=80
    ...    3. Test Case Steps:
    ...    a.UE attach and set up PDU session.
    ...    b.online change:NRBTS/NRDRB/discardTimer=20ms , NRBTS/NRDRB/discardTimerUL=10ms for 5QI=80
    ...    c.Add 5QI_80 drb.
    ...    d.UE detach.
    [Tags]    QC_222503
    UE Attach To Target Cell    ue_id=1    cell_id=1
    Send And Verify Throuput    qfi_id=1    ue_id=1    pdu_id=1
    OnlineParamChange    ${PARAMS_To_Change48}
    PDU Add QoSFlow 5QI80    ue_id=1
    UE Deregister From gNB    ue_id=1
    Check Wireshark Log    ${CURDIR}${/}a2a_CB009189_48${/}a2a.ini    wait_string=UEContextReleaseComplete::4
    Check RRC Log    ${CURDIR}${/}a2a_CB009189_48${/}a2a.ini



*** Keywords ***
Common Suite Setup And Setup Airphone Env
    Common Suite Setup
    Setup Airphone Env    tl_type=tdd_sansa_cmwv/FS/2cells_ecpri    ue_count=15

Start UE Attach UE not support outoforder
    [Arguments]    ${ue_id}
    Start To Capture Wireshark Log    log${ue_id}
    Start RRC Log    rrclog${ue_id}
    UE Attach To Target Cell    ue_id=2    cell_id=1
    stop capture wireshark log    log${ue_id}
    Get RRC Log
    UE Deregister From gNB    ue_id=2

Modify Cfg
    Update Cfg    ue_param id=1 ue_nr_capabilities=${OOO_UE_Capabilities}
    Update Cfg    set_qosflow id=2 5qi=5
    Update Cfg    set_qosflow id=3 5qi=1 gfbr_ul=30720 gfbr_dl=30720 mfbr_ul=30720 mfbr_dl=30720 qos_flow_type=gbr ue=all
    Update Cfg    set_qosflow id=4 5qi=80

UE Attach To Target Cell
    [Arguments]    ${ue_id}    ${cell_id}
    Execute Egate Command    ue_change_location id=${ue_id} enb=2 cell=${cell_id}
    Execute Egate Command    ue_register id=${ue_id}    UE now in NG RM
    Execute Egate Command    set_pdu_param ue=${ue_id} pdu=1 trf_type=internal
    Execute Egate Command    ue_pdu_session_setup ue=${ue_id} pdu=1 gw=1 nwslice=1    QoS Routing Table

PDU Add QoSFlow 5QI5
    [Arguments]    ${ue_id}
    Send And Verify Throuput    qfi_id=1    ue_id=1    pdu_id=1
    Execute Egate Command    ue_pdu_session_modify ue=${ue_id} pdu=1 qosflows_to_add=2 by=amf    pass_regexp=Added QosFlow with QFI:2 fiveQI:5
    Send And Verify Throuput    qfi_id=2    ue_id=1    pdu_id=1

PDU Add QoSFlow 5QI1
    [Arguments]    ${ue_id}
    Execute Egate Command    ue_pdu_session_modify ue=${ue_id} pdu=1 qosflows_to_add=3 by=amf    pass_regexp=Added QosFlow with QFI:3 fiveQI:1

PDU Add QoSFlow 5QI80
    [Arguments]    ${ue_id}
    Execute Egate Command    ue_pdu_session_modify ue=${ue_id} pdu=1 qosflows_to_add=4 by=amf    pass_regexp=Added QosFlow with QFI:2 fiveQI:80
    Send And Verify Throuput    qfi_id=2    ue_id=1    pdu_id=1

UE Deregister From gNB
    [Arguments]    ${ue_id}
    Execute Egate Command    ue_deregister id=${ue_id} ue_deregister_type=switch_off    UE${ue_id}: detached    timeout=10s

OnlineParamChange
    [Arguments]    ${Online_Param}
    Delta Commission Parameters    ${Online_Param}
    Cells Should Be OnAir

Send And Verify Throuput
    [Arguments]    ${ue_id}    ${qfi_id}    ${pdu_id}    ${send_dl}=70    ${send_ul}=10    ${sleep_time}=10s
    Execute Egate Command    trf_data_start ue=${ue_id} pdu=${pdu_id} qfi=${qfi_id} dir=dl mbps=${send_dl}
    Execute Egate Command    trf_data_start ue=${ue_id} pdu=${pdu_id} qfi=${qfi_id} dir=ul mbps=${send_ul}
    Verify Throuput    ${pdu_id}    ${ue_id}    ${qfi_id}    ${send_dl}*0.9    ${send_ul}*0.9    ${sleep_time}

Verify Throuput
    [Arguments]    ${pdu_id}    ${ue_id}    ${qfi_id}    ${Tput_dl}    ${Tput_ul}    ${sleep_time}
    sleep    ${sleep_time}    sleep for Tput stable
    ${dl_throughput}    Ap Get SA Throughput    ue_id=${ue_id}    pdu=${pdu_id}    qfi=${qfi_id}    direction=dl    rate_type=ave
    ${ul_throughput}    Ap Get SA Throughput    ue_id=${ue_id}    pdu=${pdu_id}    qfi=${qfi_id}    direction=ul    rate_type=ave
    Should Be True    ${dl_throughput}/1000>${Tput_dl}
    Should Be True    ${ul_throughput}/1000>${Tput_ul}

A35 counters check
    Check Counters    ${PM_Counters_Check_A35_1}
    Clear Counter Files
    Check Counters    ${PM_Counters_Check_A35_2}
