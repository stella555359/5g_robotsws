*** Settings ***
Library      ta5g_egate
Library      ute_wtssim
Library      ta5g_tshark
Library      ta5g_ue_mobility
Library      ta5g_ue_measurements
Library      ta5g_throughput
Library      ta5g_testline_management

Documentation    Keywords for CB009884_NR_Additional_PM_Counters_for_KPIs_-_III

*** Keywords ***
Wait 300s For Wts To Reset
    Sleep    300s
Set VM Ethernet Interfaces for Simulated Core Network
    Start Vm Ethernet Interface    if_name=eth3:S11          ip_with_mask=10.0.1.134/24
    Start Vm Ethernet Interface    if_name=eth3:ENB_X2U      ip_with_mask=10.0.1.135/24
    Start Vm Ethernet Interface    if_name=eth3:ENB_S1       ip_with_mask=10.0.1.136/24
    Start Vm Ethernet Interface    if_name=eth3:MME_SIM      ip_with_mask=10.0.1.131/24
    Start Vm Ethernet Interface    if_name=eth3:ENB_X2C      ip_with_mask=10.0.1.137/24
    Start Vm Ethernet Interface    if_name=eth3:Server       ip_with_mask=10.0.1.132/24
    Start Vm Ethernet Interface    if_name=eth3:SERV         ip_with_mask=10.0.1.133/24
    Start Vm Ethernet Interface    if_name=eth3:AMF2         ip_with_mask=10.0.1.101/24
    Start Vm Ethernet Interface    if_name=eth3:AMF3         ip_with_mask=10.0.1.102/24
    Start Vm Ethernet Interface    if_name=eth3:OTH20        ip_with_mask=10.0.2.90/24
    Start Vm Ethernet Interface    if_name=eth3:OTH21        ip_with_mask=10.0.2.91/24
    Start Vm Ethernet Interface    if_name=eth3:OTH22        ip_with_mask=10.0.2.92/24
    Start Vm Ethernet Interface    if_name=eth3:OTH31        ip_with_mask=10.0.1.9/24
    Start Vm Ethernet Interface    if_name=eth3:OTH32        ip_with_mask=10.0.1.10/24
    Start Vm Ethernet Interface    if_name=eth3:OTH33        ip_with_mask=10.0.1.11/24
    Start Vm Ethernet Interface    if_name=eth3:OTH34        ip_with_mask=10.0.1.12/24
    Start Vm Ethernet Interface    if_name=eth3:OTH35        ip_with_mask=10.0.1.13/24
    Start Vm Ethernet Interface    if_name=eth3:OTH36        ip_with_mask=10.0.1.14/24
    Start Vm Ethernet Interface    if_name=eth3:OTH48        ip_with_mask=10.0.1.121/24
    Start Vm Ethernet Interface    if_name=eth3:OTH49        ip_with_mask=10.0.1.128/24

Activate And Check If X2 Link is active
    Setup X2 Link    pass_regexp=X2AP Link .* is up
    Log to console  \n***Activation of eNBSim with X2AP interface completed ***

Activate X2 Link to gNB-4
    Setup X2 Link    initiator_device=1     complementary_device=4

Wait ${x:\d+}s For Counters To Be Pegged
    Sleep    ${x}s


Wait ${x:\d+}s For Traffic To Stabilize
    Sleep    ${x}s

Wait ${x:\d+}s For UE Register
    Sleep    ${x}s

Wait ${x:\d+}s For PDU Session
    Sleep    ${x}s

Wait ${x:\d+}s For Testmode Activation
    Sleep    ${x}s

Wait ${x:\d+}s For UE Attach to Simulated eNB
    Sleep    ${x}s

Wait ${x:\d+}s For Sending A4 Measurement
    Sleep    ${x}s

Wait ${x:\d+}s For UE to Setup CA
    Sleep    ${x}s

Wait ${x:\d+}s For Modify PDU Session
    Sleep    ${x}s

Wait ${x:\d+}s For UE Handover
    Sleep    ${x}s

Wait ${x:\d+}s For UE to Setup EN-DC
    Sleep    ${x}s

Wait ${x:\d+}s For Establish PDU Session
    Sleep    ${x}s

Wait ${x:\d+}s For UE to Perform SgNB Change
    Sleep    ${x}s

Register Inactive UEs To gNB To Selected PLMN And Setup PDU Session
    [Arguments]    ${UE_ID}    ${ALL_UES}    ${AMF_ID}    ${TAC_ID}    ${SELECTED_PLMN}    ${PDU_ID}=1    ${SLICE_ID}=1
    FOR  ${ID}    IN RANGE    ${UE_ID}    ${ALL_UES}
        Attach UE    ue_id=${ID}  optional_parameters=selected_plmn=${SELECTED_PLMN}
        Prepare UE to Support Inactive State    ID=${ID}    AMF_ID=${AMF_ID}    TAC_ID=${TAC_ID}    SELECTED_PLMN=${SELECTED_PLMN}
        Wait 1s For UE Register
        Establish PDU Session With Traffic
        ...    ue_id=${ID}
        ...    pdu_id=${PDU_ID}
        ...    nwslice=${SLICE_ID}
        ...    gw_id=${ID}
        ...    throughput=5mbps
        ...    check_timestamps=${False}
        Wait 1s For PDU Session
    END

Start Data Traffic for Multiple UEs
    [Arguments]    ${UE_ID}    ${ALL_UES}    ${PDU_ID}    ${TRF_ID}    ${DIR}    ${MBPS}
    FOR  ${ID}    IN RANGE    ${UE_ID}    ${ALL_UES}
        Execute Egate Command    cmd=trf_data_start ue=${ID} pdu=${PDU_ID} trf_id=${TRF_ID} dir=${DIR} mbps=${MBPS}
    END

Stop Data Traffic For Multiple UEs
    [Arguments]    ${UE_ID}    ${ALL_UES}    ${PDU_ID}=1
    FOR  ${ID}    IN RANGE    ${UE_ID}    ${ALL_UES}
        Execute Egate Command    cmd=trf_data_stop ue=${ID} pdu=${PDU_ID}
    END

Trigger RRC ResumeRequest With Invalid Short MAC_I For Multiple UEs
    [Arguments]    ${UE_ID}    ${ALL_UES}    ${GNB_ID}    ${CELL_ID}    ${CAUSE}    ${MSG}=resume_request_1    ${ACT}=invalid_short_mac_i
    FOR  ${ID}    IN RANGE    ${UE_ID}    ${ALL_UES}
        Execute Egate Command    cmd=ue_nr_rrc_resume_request_param id=${ID} gnb=${GNB_ID} cell=${CELL_ID} msg=${MSG} cause=${CAUSE} action=${ACT}
    END

Trigger RRC ResumeRequest With Invalid I-RNTI For Multiple UEs
    [Arguments]    ${UE_ID}    ${ALL_UES}    ${GNB_ID}    ${CELL_ID}    ${CAUSE}    ${MSG}=resume_request_1    ${ACT}=invalid_irnti
    FOR  ${ID}    IN RANGE    ${UE_ID}    ${ALL_UES}
        Execute Egate Command    cmd=ue_nr_rrc_resume_request_param id=${ID} gnb=${GNB_ID} cell=${CELL_ID} msg=${MSG} cause=${CAUSE} action=${ACT}
    END

Trigger RRC ResumeRequest for Multiple UEs
    [Arguments]    ${UE_ID}    ${ALL_UES}
    FOR  ${ID}    IN RANGE    ${UE_ID}    ${ALL_UES}
        Execute Egate Command    cmd=ue_nr_rrc_resume id=${ID}
    END

Verify UEs State
    [Arguments]    ${UE_ID}    ${ALL_UES}    ${EXPECTED_STATE}
    FOR  ${ID}    IN RANGE    ${UE_ID}    ${ALL_UES}
        Verify UE State    ue_id=${ID}    expected_state=${EXPECTED_STATE}
    END

Prepare UE to Support Inactive State
    [Arguments]    ${AMF_ID}    ${ID}    ${TAC_ID}    ${SELECTED_PLMN}
    ${prepare_command}=    Catenate
    ...                    amf_ue_ics_param id=${AMF_ID} ue=${ID} core_network_assistance_info=on ue_identity_index_value=${ID}
    ...                    ue_specific_drx=64 periodic_registration_update_timer=1:10min plmn_id=${SELECTED_PLMN} tac_id=${TAC_ID}
    Execute Egate Command
    ...    cmd=${prepare_command}

Prepare UE Testmode For MSG3 Configuration
    [Arguments]    ${PROFILE_ID}    ${TESTMODE_ACTION}     ${NUMBER_OF_ACTIONS}
    Execute Egate Command   cmd=cont_res_testmode_nr profile_id=${PROFILE_ID} ${TESTMODE_ACTION}=${NUMBER_OF_ACTIONS}

Register UEs with Testmode For MSG3 Configuration Activated
    [Arguments]    ${UE_ID}    ${ALL_UES}   ${ACTION_DESIRED}   ${PROFILE_ID}
    FOR  ${ID}    IN RANGE    ${UE_ID}    ${ALL_UES}
        Execute Egate Command    cmd=ue_testmode_set_nr id=${ID} action=${ACTION_DESIRED} testmode=contention_resolution profile_id=${PROFILE_ID}
        Execute Egate Command    cmd=ue_register id=${ID}
        Wait 1s For UE Register
    END

Register UEs with No Testmode Activated
    [Arguments]    ${UE_ID}    ${ALL_UES}
    FOR  ${ID}    IN RANGE    ${UE_ID}    ${ALL_UES}
        Attach UE    ue_id=${ID}
        Wait 1s For UE Register
    END

Attach Multiple UEs To Simulated eNB
    [Arguments]    ${UE_ID}    ${ALL_UES}
    FOR  ${ID}    IN RANGE    ${UE_ID}    ${ALL_UES}
        Execute Egate Command   cmd=ue_attach id=${ID}
        Wait 1s For UE Attach to Simulated eNB
    END

Setup EN-DC for Multiple UEs From Simulated eNB
    [Arguments]    ${UE_ID}    ${ALL_UES}    ${TARGET_GNB}    ${TARGET_CELLS}    ${BEARER}
    FOR  ${ID}    IN RANGE    ${UE_ID}    ${ALL_UES}
        Start gNB Addition Procedure    ue=${ID}   target_gnb=${TARGET_GNB}     target_cells=${TARGET_CELLS}    bearer=${BEARER}   dc_type=split_scg
        Wait 1s For UE to Setup EN-DC
    END

Send Measurement A1 To Trigger SCell Addition For Multiple UEs
    [Arguments]    ${UE_ID}    ${ALL_UES}    ${MEAS_ID}    ${SRSRP_NR}    ${EVENT}
    FOR  ${ID}    IN RANGE    ${UE_ID}    ${ALL_UES}
        Send UE Measurement NR    ue_id=${ID}    meas_id=${MEAS_ID}    srsrp_nr=${SRSRP_NR}    event=${EVENT}
        Wait 1s For UE to Setup CA
    END

Establish PDU Session With Traffic For Multiple UEs
    [Arguments]    ${UE_ID}    ${ALL_UES}    ${PDU_ID}
    FOR  ${ID}    IN RANGE    ${UE_ID}    ${ALL_UES}
    Establish PDU Session With Traffic    ue_id=${ID}    pdu_id=${PDU_ID}    nwslice=1    gw_id=${ID}
    Wait 1s For Establish PDU Session
    END

Establish PDU Session With Traffic For Multiple UEs with Different PDU ID
    [Arguments]    ${UE_ID}    ${ALL_UES}
    FOR  ${ID}    IN RANGE    ${UE_ID}    ${ALL_UES}
    Establish PDU Session With Traffic    ue_id=${ID}    pdu_id=${ID}    nwslice=1    gw_id=${ID}
    Wait 1s For Establish PDU Session
    END

Establish PDU Session With Traffic and Send A4 Measurement for NR-DC UEs
    [Arguments]    ${UE_ID}    ${ALL_UES}
    FOR  ${ID}    IN RANGE    ${UE_ID}    ${ALL_UES}
    Establish PDU Session With Traffic    ue_id=${ID}    pdu_id=1    nwslice=1    gw_id=${ID}
    Wait 1s For Sending A4 Measurement
    Send UE Measurement NR    ue_id=${ID}    meas_id=2    event=A4    phycell_id=52    nrsrp_nr=60
    END

Establish PDU Session With Traffic and Send A4 Measurement for NR-DC UEs with Different PDU ID
    [Arguments]    ${UE_ID}    ${ALL_UES}    ${MEAS_ID}
    FOR  ${ID}    IN RANGE    ${UE_ID}    ${ALL_UES}
    Establish PDU Session With Traffic    ue_id=${ID}    pdu_id=${ID}    nwslice=1    gw_id=${ID}    throughput='5mbps'
    Wait 1s For Sending A4 Measurement
    Send UE Measurement NR    ue_id=${ID}    meas_id=${MEAS_ID}    event=A4    phycell_id=52    nrsrp_nr=80
    END

Trigger Handovers for CA UEs
    [Arguments]    ${UE_ID}    ${ALL_UES}    ${MEAS_TYPE}    ${SRC_RSRP}    ${TGT_SSB_FREQ}    ${TGT_PCI}
    FOR  ${ID}    IN RANGE    ${UE_ID}    ${ALL_UES}
        Send UE Measurement NR    ue_id=${ID}    meas_id=1    srsrp_nr=10    event=A2
        Wait 1s For UE Handover
        ${prepare_command}=    Catenate
        ...                    ue_ho_nr ue_id=${ID} meas_type=${MEAS_TYPE} src_rsrp_nr=${SRC_RSRP}
        ...                    tgt_cell_ssb_frequency=${TGT_SSB_FREQ} tgt_phycell_id=${TGT_PCI}
        Execute Egate Command
        ...    cmd=${prepare_command}
    END

Modify PDU Session For Multiple UEs
    [Arguments]    ${UE_ID}    ${ALL_UES}    ${QOS_TO_ADD}
    FOR  ${ID}    IN RANGE    ${UE_ID}    ${ALL_UES}
    Modify PDU Session    ue_id=${ID}    pdu_id=1    qos_to_add=${QOS_TO_ADD}
    Wait 1s For Modify PDU Session
    END

Perform Sgnb Release For Multiple UEs
    [Arguments]    ${UE_ID}    ${ALL_UES}
    FOR    ${ID}    IN RANGE    ${UE_ID}    ${ALL_UES}
        Execute Egate Command And Wait For Data    cmd=enb_ue_dc_release by=enb ue=${ID} cause=RN_normal_release
        ...    pass_regexp=UE${ID}:  === Bearer-type change from SCG-split to MCG is successful ===
        ...    timeout=20
    END

Perform AMF Initiated UE Context Release For Multiple UEs
    [Arguments]    ${UE_ID}    ${ALL_UES}    ${CAUSE}
    FOR    ${ID}    IN RANGE    ${UE_ID}    ${ALL_UES}
        Execute Egate Command And Wait For Data    cmd=ue_ng_ctx_release id=${ID} by=amf cause=${CAUSE}
    END

Inject GTP Error By UPF For Multiple UE
    [Arguments]    ${UE_ID}    ${ALL_UES}    ${PDU_ID}    ${UPF_ID}
    FOR    ${ID}    IN RANGE    ${UE_ID}    ${ALL_UES}
        Execute Egate Command And Wait For Data   cmd=upf_ue_pdu_inject_error_ind id=${UPF_ID} ue=${ID} pdu=${PDU_ID}
    END

Enable GTP-U Sequence Number inclusion in bearer packets
    [Arguments]    ${UPF_ID}=1
    Execute Egate Command   cmd=upf_param id=${UPF_ID} enable_gtpu_sn=on

Trigger Lost Packets on N3 interface
    [Arguments]    ${UE_ID}    ${PDU_ID}    ${SEQ}
    ${prepare_command}=    Catenate
    ...                    ue_pdu_upf_param ue=${UE_ID} modify_gtpu_header=gtpu_sn_error pdu_id_for_force_drop=${PDU_ID}
    ...                    qfi_id_for_force_drop=1 force_drop_dl_gtpu=${SEQ}
    Execute Egate Command   cmd=${prepare_command}

Trigger Out of Order Packets on N3 interface
    [Arguments]    ${UE_ID}    ${PDU_ID}    ${SEQ}
    ${prepare_command}=    Catenate
    ...                    ue_pdu_upf_param ue=${UE_ID} modify_gtpu_header=gtpu_sn_error pdu_id_for_force_ooo=${PDU_ID}
    ...                    qfi_id_for_force_ooo=1 force_ooo_dl_gtpu=${SEQ}
    Execute Egate Command   cmd=${prepare_command}

Prepare Sending Invalid RRC Reconfiguration For UE${ue:\d+}
    ue nr rrc reconf param    ue_id=${ue}    if_contains=any    action=invalid_tid

Prepare Reestablishment Due RRC Reconfiguration Failure For UE${ue:\d+}
    ue nr rrc reconf param    ue_id=${ue} if_contains=any action=reestablish cause=reconfigurationFailure

Wait For Successfull PDU Session Modification
    Sleep    2s

Trigger SgNB Change For Multiple UEs
    [Arguments]    ${UE_ID}    ${ALL_UES}    ${MEAS_ID}    ${SRSRP_NR}    ${EVENT}    ${TARGET_PCI}    ${TARGET_RSRP}
    FOR  ${ID}    IN RANGE    ${UE_ID}    ${ALL_UES}
        Send UE Measurement NR    ue_id=${ID}    meas_id=${MEAS_ID}    srsrp_nr=${SRSRP_NR}    phycell_id=${TARGET_PCI}    nrsrp_nr=${TARGET_RSRP}
        ...                       event=${EVENT}
        Wait 1s For UE to Perform SgNB Change
    END

Wait For Energy Saving State Activation
    Sleep    600s

Set QoSFlow Priority To Emergency
    [Arguments]    ${QOS_ID}
    Execute Egate Command   cmd=qosflow_modify qos_flow=${QOS_ID}  priority=1

Enable Additional QoSFlow Addition during PDU Session Setup
    [Arguments]    ${QOS_ID}
    Execute Egate Command   cmd=smf_param id=1 additional_qosflows_to_activate=${QOS_ID}

Enable Voice Fallback on AMF
    Execute Egate Command   cmd=amf_param id=1 voice_fallback=on
    Execute Egate Command   cmd=amf_ue_ics_param id=1 ue=18,19 emergency_fb=on

Register UEs To Selected PLMN And Setup PDU Session Without Confirmation
    [Arguments]    ${UE_ID}    ${ALL_UES}    ${SELECTED_PLMN}    ${PDU_ID}    ${SLICE_ID}   ${GW_ID}
    FOR  ${ID}    IN RANGE    ${UE_ID}    ${ALL_UES}
        Attach UE    ue_id=${ID}  optional_parameters=selected_plmn=${SELECTED_PLMN}
        Wait 1s For UE Register
        Establish Pdu Session Without Confirmation    ue_id=${ID}    pdu_id=${PDU_ID}    nwslice=${SLICE_ID}    gw_id=${GW_ID}
        Wait 1s For PDU Session
    END

Prepare UE Testmode For RLF Triggering Configuration
    [Arguments]    ${PROFILE_ID}
    Execute Egate Command   cmd=rlf_testmode_nr profile_id=${PROFILE_ID} num_stop_csi_report=1000 num_stop_dlharq_tx=2000

Trigger PDU Session Setup with 5QI-1 while RLF detected
    [Arguments]    ${UE_ID}    ${ALL_UES}   ${PDU_ID}    ${SLICE_ID}
    Enable Additional QoSFlow Addition during PDU Session Setup    QOS_ID=2
    FOR  ${ID}    IN RANGE    ${UE_ID}    ${ALL_UES}
        Execute Egate Command   cmd=ue_testmode_set_nr id=${ID} testmode=rlf profile_id=7 action=activate
        Wait 1s For Testmode Activation
        Establish Pdu Session Without Confirmation    ue_id=${ID}    pdu_id=${PDU_ID}    nwslice=${SLICE_ID}    gw_id=${ID}
        Wait 1s For PDU Session
    END

Disable Additional QoSFlow Addition during PDU Session Setup
        Execute Egate Command   cmd=smf_param id=1 reset
