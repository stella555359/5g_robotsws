*** Settings ***
Documentation    Suite description
Suite Setup    Common Suite Setup And Setup Airphone Env
Suite Teardown    Common Suite Teardown And Restore BTS Configuration Parameters
Test Setup    Common Test Setup And Start To Capture Logs
Test Teardown    Common Test Teardown And Stop Capture Logs
Force Tags    QCD_MN_RAN    QCP_RAN_ET    SBTS00    RAN_5G    RAN_5G_TDD    team-Beam    owner-niya.ma
...    CLOUD_5G_I_BOO_AP_LOO_SANSA_FS_ECPRI_CMWV_FDD+TDD    CRT    CB009189    release-SBTS23R1
...    STATE_CONFIGURED
Resource    ../../../../resources/DevHZ5_resource.robot

*** Variables ***
@{PARAMS_IN_SCF}
...    NRBTS-1:cipherPrefL:nea0=8
...    NRBTS-1:cipherPrefL:nea1_128=0
...    NRBTS-1:cipherPrefL:nea2_128=0
...    NRBTS-1:cipherPrefL:nea3_128=0
...    NRCELL:actVoNR=true
...    NRCELL:actEnhancedVoNR=true
...    @{5qi80_related_modification}
...    @{CA_related}

@{5qi80_related_modification}
...    NRBTS-1/NRDRB-15:actDddsReduction=false
...    NRBTS-1/NRDRB-15:actLostPduFastRetx=false
...    NRBTS-1/NRDRB-15:discardTimer=infinity
...    NRBTS-1/NRDRB-15:dlFlowControlAlgo=3gppFlowControl
...    NRBTS-1/NRDRB-15:dscp=0
...    NRBTS-1/NRDRB-15:endMarkerTimer=2000
...    NRBTS-1/NRDRB-15:maxDddsPeriodCpuOvld=40
...    NRBTS-1/NRDRB-15:maxRlcQueueingDelayGbr=20
...    NRBTS-1/NRDRB-15:maxTransferDelayGbr=20
...    NRBTS-1/NRDRB-15:nrDrbMacDN=MRBTS-1/NRBTS-1/NRDRB_MAC-2
...    NRBTS-1/NRDRB-15:nrDrbPdcpDN=MRBTS-1/NRBTS-1/NRDRB_PDCP-2
...    NRBTS-1/NRDRB-15:nrDrbRlcAmDN=MRBTS-1/NRBTS-1/NRDRB_RLC_AM-2
...    NRBTS-1/NRDRB-15:nrDrbRlcUmDN=MRBTS-1/NRBTS-1/NRDRB_RLC_UM-1
...    NRBTS-1/NRDRB-15:numSduDiscard=1
...    NRBTS-1/NRDRB-15:queuingDelayDiscarding=Controlled Delay (CoDel)
...    NRBTS-1/NRDRB-15:queuingDelaySduDiscardThreshold=750
...    NRBTS-1/NRDRB-15:resType=nonGBR
...    NRBTS-1/NRDRB-15:rlcMode=RLC_AM
...    NRBTS-1/NRDRB-15:schedulWeight=1
...    NRBTS-1/NRDRB-15:sduDiscardIntervalTmr=500
...    NRBTS-1/NRDRB-15:nsaDrbParam:actPrioritizeX2AfterInactivity=true
...    NRBTS-1/NRDRB-15:nsaDrbParam:actX2DuplicateTxNSA3x=false
...    NRBTS-1/NRDRB-15:nsaDrbParam:dlDataSplitBufferBuildUpThreshold=5
...    NRBTS-1/NRDRB-15:nsaDrbParam:dlDataSplitBufferBuildUpThresholdPrioritizeX2=5
...    NRBTS-1/NRDRB-15:nsaDrbParam:dlDataSplitGainThreshold=5
...    NRBTS-1/NRDRB-15:nsaDrbParam:dlDataSplitMode=dlOverF1U
...    NRBTS-1/NRDRB-15:nsaDrbParam:inactivityThresholdForPrioritizeX2=300
...    NRBTS-1/NRDRB-15:nsaDrbParam:inactivityThresholdForRestartPrioritizeX2=100
...    NRBTS-1/NRDRB-15:nsaDrbParam:inactPeriodX2PdcpDuplication=300
...    NRBTS-1/NRDRB-15:nsaDrbParam:initialDLTrafficRouting=initDLoverX2U
...    NRBTS-1/NRDRB-15:nsaDrbParam:nsa3xBearerAllowed=true
...    NRBTS-1/NRDRB-15:nsaDrbParam:prioritizeX2Period=500
...    NRBTS-1/NRDRB-15:nsaDrbParam:ulDataPath=ulOverNr
...    NRBTS-1/NRDRB-15:nsaDrbParam:ulDataSplitThreshold=infinity
...    NRBTS-1/NRDRB_5QI-3:fiveqiValueList=80
...    NRBTS-1/NRDRB_5QI-3:nrDrbDN=MRBTS-1/NRBTS-1/NRDRB-15

@{CA_related}
...    MRBTS-1/NRBTS-1:actCarrierAggregation=true
...    MRBTS-1/NRBTS-1:caConfigurationSupport=2CCDL_2CCUL
...    MRBTS-1/NRBTS-1:sCellActivationMethod=blind
...    NRCELL:sCellDeactivationTimerGNB=infinity
...    MRBTS-1/NRBTS-1/NRCELL-11/NRREL-1:sCellAdditionMethod=blind
...    NRCELL-11/NRREL-1:gNbId=1
...    NRCELL-11/NRREL-1:gnbPlmn:mcc=311
...    NRCELL-11/NRREL-1:gnbPlmn:mnc=489
...    NRCELL-11/NRREL-1:gnbPlmn:mncLength=3
...    NRBTS/NRDU-1:carrierAggregationSupportList=ca_Fdd_Fr1Tdd_Sa,ca_Fr1Tdd_Sa,ca_Fr1Tdd_Fdd_Sa,ca_Fdd_Any_Sa,ca_Fr1Tdd_Any_Sa,ca_Fdd_Fdd

@{ca_disable}
...    delete:MRBTS-1/NRBTS-1/NRCELL-11/NRREL-1:sCellAdditionMethod

@{ca_enable}
...    MRBTS-1/NRBTS-1/NRCELL-11/NRREL-1:sCellAdditionMethod=blind

${ue_id}    81

*** Test Cases ***
CB009189-D_ID_64_FT_CA_5QI80_setup_ICS_wo_PDU_session_then_repeat_after_CA_disabled
    [Documentation]
    ...    1. FR1 SA CA is enabled in for TDD and FDD PCells.
    ...    2. cell2 is configured as SCell of cell1 cell via NRREL object with scellAdditionMethod set to "blind"
    ...    3. 5QI-80 DRB profile is configured and DRB mapped to RLC-AM
    ...    4. Initial Context Setup without PDU session
    [Tags]    QC_223935    owner-niya.ma
    ICS Without PDU    ue_id=81    cell_id=11    amf_id=1
    Send And Verify Throuput    ue_id=81    qfi=1    send_dl=30    send_ul=10    sleep_time=10s    pdu=1
    UE Deregister From gNB    ue_id=81
    OnlineParamChange    @{ca_disable}
    ICS Without PDU    ue_id=81    cell_id=11    amf_id=1
    Send And Verify Throuput    ue_id=81    qfi=1    send_dl=30    send_ul=10    sleep_time=10s    pdu=1
    UE Deregister From gNB    ue_id=81
    Check Wireshark Log     ${CURDIR}${/}a2a_CB009189D064${/}a2a.ini    wait_string=UEContextReleaseComplete::4

CB009189-D_ID_66_FT_CA_5QI80_setup_ICS_with_PDU_session_then_repeat_after_CA_disabled
    [Documentation]
    ...    1. FR1 SA CA is enabled in for TDD and FDD PCells.
    ...    2. cell2 is configured as SCell of cell1 cell via NRREL object with scellAdditionMethod set to "blind"
    ...    3. 5QI-80 DRB profile is configured and DRB mapped to RLC-AM
    ...    4. Initial Context Setup with PDU session
    [Tags]    QC_221207    owner-niya.ma
    OnlineParamChange    @{ca_enable}
    UE Attach To Target Cell    ue_id=81    cell_id=11
    Send And Verify Throuput    ue_id=81    qfi=1    send_dl=30    send_ul=10    sleep_time=10s    pdu=1
    UE Deregister From gNB    ue_id=81
    OnlineParamChange    @{ca_disable}
    UE Attach To Target Cell    ue_id=81    cell_id=11
    Send And Verify Throuput    ue_id=81    qfi=1    send_dl=30    send_ul=10    sleep_time=10s    pdu=1
    UE Deregister From gNB    ue_id=81
    Check Wireshark Log    ${CURDIR}${/}a2a_CB009189D066${/}a2a.ini    wait_string=UEContextReleaseComplete::4

CB009189-D_ID_68_FT_CA_5QI80_setup_with_VoNR_by_PDU_Session_Modification_then_repeat_after_CA_disabled
    [Documentation]
    ...    1. FR1 SA CA is enabled in for TDD and FDD PCells.
    ...    2. cell2 is configured as SCell of cell1 cell via NRREL object with scellAdditionMethod set to "blind"
    ...    3. 5QI-80 DRB profile is configured and DRB mapped to RLC-AM
    ...    4. 5QI80_setup_by_PDU_Session_Modification
    [Tags]    QC_221206    owner-niya.ma
    OnlineParamChange    @{ca_enable}
    UE Attach To Target Cell And Add 5qi    ue_id=81    cell_id=11    qos_flow_default=8    qos_flow_add_01=9
    ...    qos_flow_add_02=5    qos_flow_add_03=1
    Send And Verify Throuput    ue_id=81    qfi=1    send_dl=20    send_ul=5    sleep_time=10s    pdu=1
    Send And Verify Throuput    ue_id=81    qfi=2    send_dl=20    send_ul=5    sleep_time=10s    pdu=1
    Send And Verify Throuput    ue_id=81    qfi=3    send_dl=20    send_ul=5    sleep_time=10s    pdu=1
    UE Deregister From gNB    ue_id=81
    OnlineParamChange    @{ca_disable}
    UE Attach To Target Cell And Add 5qi    ue_id=81    cell_id=11    qos_flow_default=8    qos_flow_add_01=9
    ...    qos_flow_add_02=5    qos_flow_add_03=1
    Send And Verify Throuput    ue_id=81    qfi=1    send_dl=20    send_ul=5    sleep_time=10s    pdu=1
    Send And Verify Throuput    ue_id=81    qfi=2    send_dl=20    send_ul=5    sleep_time=10s    pdu=1
    Send And Verify Throuput    ue_id=81    qfi=3    send_dl=20    send_ul=5    sleep_time=10s    pdu=1
    UE Deregister From gNB    ue_id=81
    Check Wireshark Log    ${CURDIR}${/}a2a_CB009189D068${/}a2a.ini    wait_string=UEContextReleaseComplete::4


*** Keywords ***
Common Suite Setup And Setup Airphone Env
    Common Suite Setup
    Setup Airphone Env    tl_type=fddtdd_sansa_cmwv/6cells_2T4F_2N41_2N71_2N66

Modify Cfg
    Delete Cfg    set_qosflow id=1 5qi=6 default=on
    Update Cfg    set_qosflow id=1 5qi=1
    Update Cfg    set_qosflow id=2 5qi=2 gfbr_ul=30720 gfbr_dl=30720 mfbr_ul=30720 mfbr_dl=30720 qos_flow_type=gbr ue=all
    Update Cfg    set_qosflow id=3 5qi=3 gfbr_ul=30720 gfbr_dl=30720 mfbr_ul=30720 mfbr_dl=30720 qos_flow_type=gbr ue=all
    Update Cfg    set_qosflow id=4 5qi=4 gfbr_ul=30720 gfbr_dl=30720 mfbr_ul=30720 mfbr_dl=30720 qos_flow_type=gbr ue=all
    Update Cfg    set_qosflow id=5 5qi=5
    Update Cfg    set_qosflow id=6 5qi=6
    Update Cfg    set_qosflow id=7 5qi=7
    Update Cfg    set_qosflow id=8 5qi=8
    Update Cfg    set_qosflow id=9 5qi=80 default=on

UE Attach To Target Cell
    [Arguments]    ${ue_id}    ${cell_id}
    Execute Egate Command    ue_change_location id=${ue_id} enb=2 cell=${cell_id}
    Execute Egate Command    ue_register id=${ue_id}    UE now in NG RM Register
    Execute Egate Command    set_pdu_param ue=${ue_id} pdu=1 trf_type=internal
    Execute Egate Command    ue_pdu_session_setup ue=${ue_id} pdu=1 gw=1 nwslice=1    QoS Routing Table

ICS Without PDU
    [Arguments]    ${ue_id}    ${cell_id}    ${amf_id}
    Execute Egate Command    ue_change_location id=${ue_id} enb=2 cell=${cell_id}
    Execute Egate Command    amf_param id=${amf_id} send_ics_registration=on
    Execute Egate Command    ue_register id=${ue_id}    UE now in NG RM Register
    Execute Egate Command    set_pdu_param ue=${ue_id} pdu=1 trf_type=internal
    Execute Egate Command    ue_pdu_session_setup ue=${ue_id} pdu=1 gw=1 nwslice=1    QoS Routing Table
    Execute Egate Command    amf_param id=${amf_id} send_ics_registration=off

OnlineParamChange
    [Arguments]    ${Online_Param}
    Delta Commission Parameters    ${Online_Param}
    Cells Should Be OnAir

UE Deregister From gNB
    [Arguments]    ${ue_id}
    Execute Egate Command    ue_deregister id=${ue_id} ue_deregister_type=switch_off    UE${ue_id}: detached    timeout=10s

Verify Throuput
    [Arguments]    ${ue_id}    ${qfi}    ${Tput_dl}    ${Tput_ul}    ${sleep_time}    ${pdu}
    sleep    ${sleep_time}    sleep for Tput stable
    ${dl_throughput}    Ap Get SA Throughput    ue_id=${ue_id}    pdu=${pdu}    qfi=${qfi}    direction=dl    rate_type=ave
    ${ul_throughput}    Ap Get SA Throughput    ue_id=${ue_id}    pdu=${pdu}    qfi=${qfi}    direction=ul    rate_type=ave
    Should Be True    ${dl_throughput}/1000>${Tput_dl}
    Should Be True    ${ul_throughput}/1000>${Tput_ul}

Send And Verify Throuput
    [Arguments]    ${ue_id}    ${qfi}    ${send_dl}    ${send_ul}    ${sleep_time}    ${pdu}
    Execute Egate Command    trf_data_start ue=${ue_id} pdu=${pdu} qfi=${qfi} dir=dl mbps=${send_dl}
    Execute Egate Command    trf_data_start ue=${ue_id} pdu=${pdu} qfi=${qfi} dir=ul mbps=${send_ul}
    Verify Throuput    ${ue_id}    ${qfi}    ${send_dl}*0.9    ${send_ul}*0.9    ${sleep_time}    ${pdu}

UE Attach To Target Cell And Add 5qi
    [Arguments]    ${ue_id}    ${cell_id}    ${qos_flow_default}    ${qos_flow_add_01}    ${qos_flow_add_02}    ${qos_flow_add_03}
    Execute Egate Command    ue_change_location id=${ue_id} enb=2 cell=${cell_id}
    Execute Egate Command    ue_register id=${ue_id}    UE now in NG RM Register
    Execute Egate Command    set_pdu_param ue=${ue_id} pdu=1 trf_type=internal
    Execute Egate Command    qosflow_modify default=on qos_flow=${qos_flow_default} priority=15
    Execute Egate Command    ue_pdu_session_setup ue=${ue_id} pdu=1 gw=1 nwslice=1    QoS Routing Table
    Execute Egate Command    ue_pdu_session_modify ue=${ue_id} pdu=1 qosflows_to_add=${qos_flow_add_01} by=amf
    ...    UE81: Ue 81 PduId 1 Created FiveQi:Qfi mapping fiveQi 80 qfi 2
    Execute Egate Command    ue_pdu_session_modify ue=${ue_id} pdu=1 qosflows_to_add=${qos_flow_add_02} by=amf
    ...    UE81: Ue 81 PduId 1 Created FiveQi:Qfi mapping fiveQi 5 qfi 3
    Execute Egate Command    ue_pdu_session_modify ue=${ue_id} pdu=1 qosflows_to_add=${qos_flow_add_03} by=amf
    ...    UE81: Ue 81 PduId 1 Created FiveQi:Qfi mapping fiveQi 1 qfi 4

