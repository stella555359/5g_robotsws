*** Settings ***
Suite Setup    Common Suite Setup And Setup Airphone Env
Suite Teardown    Common Suite Teardown And Restore BTS Configuration Parameters
Test Setup    Common Test Setup And Start To Capture Logs
Test Teardown    Common Test Teardown And Stop Capture Logs
Force Tags    QCD_MN_RAN    QCP_RAN_ET    SBTS00    RAN_5G    RAN_5G_TDD    team-Beam    owner-meredith.ma
...    CLOUD_5G_I_LO_AP_LO_SANSA_FS_ECPRI_CMWV_TDD    CRT    CB008120    release-SBTS23R1
...    STATE_CONFIGURED
Resource    ../../../../resources/DevHZ5_resource.robot

*** Variables ***
${TL_TYPE_PATH}    tdd_sansa_cmwv/FS/2cells_ecpri

@{PARAMS_IN_SCF}
...    NRBTS:actAdditionalSliceSupport=true

...    NRBTS:activityNotificationLevelSA=drb
...    NRCELL-1:actVoNR=true
...    NRCELL-1:actEnhancedVoNR=true
...    NRBTS/NRDRB-15:actDddsReduction=false
...    NRBTS/NRDRB-15:actLostPduFastRetx=false
...    NRBTS/NRDRB-15:discardTimer=750ms
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
...    NRBTS/SNSSAI-2:administrativeState=Unlocked
...    NRBTS/SNSSAI-2:sst=2
...    NRBTS/SNSSAI-2:ngUplane:ipV4AddressDN1=MRBTS-1/TNLSVC-1/TNL-1/IPNO-1/IPIF-1/IPADDRESSV4-1
...    NRBTS/SNSSAI-2:nrPlmnDNList=MRBTS-1/NRBTS-1/NRPLMN-1
...    NRBTS/TRACKINGAREA-200:snssaiList:snssaiDN=MRBTS-1/NRBTS-1/SNSSAI-1|snssaiDN=MRBTS-1/NRBTS-1/SNSSAI-1
...    NRBTS/TRACKINGAREA-200:snssaiList:snssaiDN=MRBTS-1/NRBTS-1/SNSSAI-2|snssaiDN=MRBTS-1/NRBTS-1/SNSSAI-2

...    NRBTS/NRDRB-10:drbInactivityTimerSA=60
...    NRBTS/NRDRB-15:drbInactivityTimerSA=60
...    NRBTS:drbInactivityTimerSA5qi1=30
...    NRBTS:drbInactivityTimerSA5qi5=30
...    NRBTS:drbInactivityTimerSA=10
...    NRBTS:srbInactivityTimerSA=10

@{PARAMS_To_Change}
...    NRBTS/NRDRB-10:drbInactivityTimerSA=${EMPTY}
...    NRBTS/NRDRB-15:drbInactivityTimerSA=${EMPTY}
...    NRBTS/SNSSAI-2:drbInactivityTimerSA=10
...    NRBTS:drbInactivityTimerSA=60

*** Test Cases ***
CB008120_10_Release_vonr_with_no_influence_of_NRDRB_InactivityTimer
    [Documentation]
    ...    1. This user scenario porpuse is to verify release VoNR for slice configured with standarized SST value from
    ...    range (0-127) and NRDRB/drbInactivityTimerSA is not influencing releasing VoNR
    ...    2. Configuration
    ...    configuration on BTS
    ...    a.FR1 TDD cells are configured with frequency NRF1 in band n78 with 100MHz bandwidths.
    ...    b.NRF1 cell has NRCELL-cellDepType set to SA or both
    ...    c.New slices is enabled by setting actAdditionalSliceSupport=true
    ...    3. Test Case Steps:
    ...    a.UE attach and set up PDU session.
    ...    b.UE add 5QI=5 and 5QI=1 drb.
    ...    c.UE detach.
    [Tags]    QC_219481
    UE Attach To Target Cell    ue_id=1    cell_id=1
    PDU Add QoSFlow 5QI5    ue_id=1
    PDU Add QoSFlow 5QI1    ue_id=1
    Wait for ue inactivitytimer expire    ue_id=1    InactivityTimer1=20s    InactivityTimer2=20s
    UE Deregister From gNB    ue_id=1
    Check Wireshark Log    ${CURDIR}${/}a2a_10_12${/}a2a.ini    wait_string=UEContextReleaseComplete::8

CB008120_12_Release_vonr_with_no_influence_of_SNSSAI_InactivityTimer
    [Documentation]
    ...    1. This user scenario porpuse is to verify release VoNR for slice configured with standarized SST value from
    ...    range (0-127) and SNSSAI/drbInactivityTimerSA is not influencing releasing VoNR
    ...    2. Configuration
    ...    configuration on BTS
    ...    a.FR1 TDD cells are configured with frequency NRF1 in band n78 with 100MHz bandwidths.
    ...    b.NRF1 cell has NRCELL-cellDepType set to SA or both
    ...    c.New slices is enabled by setting actAdditionalSliceSupport=true
    ...    3. Test Case Steps:
    ...    a.UE attach and set up PDU session.
    ...    b.UE add 5QI=5 and 5QI=1 drb.
    ...    c.UE detach.
    [Tags]    QC_219480
    OnlineParamChange    ${PARAMS_To_Change}
    UE Attach To Target Cell    ue_id=1    cell_id=1
    PDU Add QoSFlow 5QI5    ue_id=1
    PDU Add QoSFlow 5QI1    ue_id=1
    Wait for ue inactivitytimer expire    ue_id=1    InactivityTimer1=20s    InactivityTimer2=10s
    UE Deregister From gNB    ue_id=1
    Check Wireshark Log    ${CURDIR}${/}a2a_10_12${/}a2a.ini    wait_string=UEContextReleaseComplete::8

*** Keywords ***
Common Suite Setup And Setup Airphone Env
    Common Suite Setup
    Setup Airphone Env    tl_type=tdd_sansa_cmwv/FS/2cells_ecpri    ue_count=15

Modify Cfg
    Update Cfg    set_nwslice id=1 snssai=0x02:0xFFFFFF default=on ue=all amf=1-6
    Update Cfg    ue_param id=1-12 ue_nr_capabilities=${SA_Capa_perUE_Full}
    Update Cfg    set_qosflow id=2 5qi=5
    Update Cfg    set_qosflow id=3 5qi=1

UE Attach To Target Cell
    [Arguments]    ${ue_id}    ${cell_id}
    Execute Egate Command    ue_change_location id=${ue_id} enb=2 cell=${cell_id}
    Execute Egate Command    ue_register id=${ue_id}    UE now in NG RM Register
    Execute Egate Command    set_pdu_param ue=${ue_id} pdu=1 trf_type=internal
    Execute Egate Command    ue_pdu_session_setup ue=${ue_id} pdu=1 gw=1 nwslice=1    QoS Routing Table

PDU Add QoSFlow 5QI5
    [Arguments]    ${ue_id}
    Execute Egate Command    ue_pdu_session_modify ue=${ue_id} pdu=1 qosflows_to_add=2 by=amf    pass_regexp=Added QosFlow with QFI:2 fiveQI:5

PDU Add QoSFlow 5QI1
    [Arguments]    ${ue_id}
    Execute Egate Command    ue_pdu_session_modify ue=${ue_id} pdu=1 qosflows_to_add=3 by=amf    pass_regexp=Added QosFlow with QFI:3 fiveQI:1

Wait for ue inactivitytimer expire
    [Arguments]    ${ue_id}    ${InactivityTimer1}    ${InactivityTimer2}
    Sleep    ${InactivityTimer1}    wait for UE inactivity
    Start RRC Log    rrcRelease
    Sleep    ${InactivityTimer2}    wait for UE Release
    rrc Should Contain    rrcRelease
    rrc Should Contain    UE${ue_id}: IS IDLE

UE Deregister From gNB
    [Arguments]    ${ue_id}
    Execute Egate Command    ue_deregister id=${ue_id} ue_deregister_type=switch_off    UE${ue_id}: detached    timeout=10s

OnlineParamChange
    [Arguments]    ${Online_Param}
    Delta Commission Parameters    ${Online_Param}
    Cells Should Be OnAir
