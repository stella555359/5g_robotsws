*** Settings ***
Force Tags    CLOUD_5GC_dRNIC_1vDU_P_AP_LO_DC    VARIANT_SANSA_FS_CPRI_CMWV_FDD+ECPRI_CMWV_TDD    CONFIGURED
...           RAN_5G_TDD    RAN_5G    SBTS00


Documentation    :copyright: Nokia
...              :authors: Wojciech Peciak
...              :contact: wojciech.peciak@nokia.com

Resource     taf/rfrl/common_resources/robot/libraries_instances.robot
Variables    ta5g_global_var
Library      ta5g_commissioning
Library      ta5g_iphy
Library      ta5g_admin_operations
Library      ta5g_ue_mobility
Library      ta5g_testline_management
Library      ta5g_cell_operations
Library      ta5g_egate
Library      ta5g_setups_and_teardowns
Library      ta5g_tshark
Library      taf.ul.log_collection
Library      OperatingSystem
Library      ta5g_enb
Resource     taf/rfrl/cbts/robot/vdu/vdu_cm.robot
Resource     taf/rfrl/cbts/robot/vcu/vcu_cm.robot

Suite Setup    Run Keywords    Enable Cloud
...            AND             Get Current CloudBTS Configuration
...            AND             Update And Put Iphy Xml Aic
...                               input_filepath=${ap_cfg_file_path}
...                               output_dirpath=${OUTPUT_DIR}/suite_setup
...            AND             Call Ap Console Reboot
...            AND             Upload XML Delta Vdu
...                               scfc_filename=${vDU_delta_cfg}
...            AND             Upload XML Delta Vcu
...                               scfc_filename=${vCU_delta_cfg}
...            AND             Check Radios Availability Aic
...                               timeout=500
...            AND             Wait For F1 Links To Be Available Aic
...            AND             Reach Onair Aic
...                            check_edaemon_port=${True}
...                            lua_cfg=${wts_cfg_file_path}
...            AND             Wait For All Cells To Be Enabled Aic


Suite Teardown    Run Keywords
...            Run Keyword And Ignore Error    Restore Original CloudBTS Configuration
...            AND                Stop Default Processes And Gather Logs And Compress Logs


Test Teardown    Run Keywords    Deregister Ue    ue_id=${ue_id}
...            AND               Stop Default Logging
...                                 output_dirpath=${OUTPUT_DIR}/${TEST_NAME}

*** Variables ***
${wts_cfg_file_path}=                       ${CURDIR}${/}config${/}egate_SANSA_FS_CPRI_CMWV_FDD_ECPRI_CMWV_TDD.cfg
${ap_cfg_file_path}=                        ${CURDIR}${/}config${/}iphy_SANSA_FS_CPRI_CMWV_FDD_ECPRI_CMWV_TDD.xml
${vDU_delta_cfg}=                           delta_vDU_CB010369_CB008225.xml
${vCU_delta_cfg}=                           delta_vCU_CB010369_CB008225.xml
${delta_for_second_timers_settings}=
...    delta_vCU_rfspRrcInactInactivityTimer_based_transition_to_RRC_inactive_after_HO.json
${gnb_vCU_tcpdump_alias}=                   default_F1_E1_RRC

${ue_id}=                              1
${indexToRFSP}=                        129
${TC_1_srbInactivityTimerSA}=          70
${TC_1_rfspRrcInactInactivityTimer}=   90
${TC_2_srbInactivityTimerSA}=          70
${TC_2_rfspRrcInactInactivityTimer}=   20

${filter_rfspRrcInactInactivityTimer_low_set}=
...    e1ap.BearerContextSetupRequest_element && e1ap.Inactivity_Timer == ${TC_1_rfspRrcInactInactivityTimer}
${filter_rfspRrcInactInactivityTimer_high_set}=
...    e1ap.BearerContextSetupRequest_element && e1ap.Inactivity_Timer == ${TC_2_rfspRrcInactInactivityTimer}
${filter_RFSP_act_AMF}=
...    ngap.InitialContextSetupRequest_element && ngap.IndexToRFSP == ${indexToRFSP}
${filter_IntraFreq_HO_completed}=    nr-rrc.rrcReconfigurationComplete_element && nr-rrc.rrc_TransactionIdentifier == 3
${filter_RRC_Inactive_verf_gNB_lvl}=    e1ap.BearerContextInactivityNotification_element && e1ap.uE_Activity == 1
${filter_RRC_Inactive_verf_UE_lvl}=    nr-rrc.suspendConfig_element && nr-rrc.RAN_AreaCode == 2

*** Test Cases ***
CB010369-B_Successful_transition_of_UE_from_RRC_Connected_to_RRC_Inactive_state_due_to_expiration_of_RFSP_based_Inactivity_timer_IWK_with_CB008225
    [Documentation]    The purpose of the test case is to verify the transition of UE from RRC_Connected to
    ...    RRC_Inactive state due to expiration of Inactivity timer (rfspRrcInactInactivityTimer) for a configured RFSP.
    ...    Coexisting timers setting:
    ...     srbInactivityTimerSA:           70
    ...     drbInactivityTimerSA:           40
    ...     rfspInactivityTimer:            30
    ...     drbRrcInactInactivityTimerSA:   10
    ...     rfspRrcInactInactivityTimer:    90

    [Setup]    Run Keywords
    ...            Configure AMF
    ...    AND     Start Default Logging
    ...               output_dirpath=${OUTPUT_DIR}/${TEST_NAME}
    ...               alias=${gnb_vCU_tcpdump_alias}
    ...    AND     Wait For Tshark From CpRT To Be Collecting

    Attach Ue    ue_id=${ue_id}    cell=1    enb=2
    Establish Pdu Session    ue_id=${ue_id}    pdu_id=1    nwslice=1    gw_id=1

    Verify rfspRrcInactInactivityTimer Sent To UE    ${filter_rfspRrcInactInactivityTimer_low_set}
    Verify RFSP Sent To UE

    Perform IntraFreq Handover UE To Second Cell
    Wait And Verify UE Transfer To RRC_Inactive
    Verify Ue Bearer Inactivity Detected At gNB

    Verify Expiration Of Timer Causing Transfer To RRC_Inactive    ${TC_1_rfspRrcInactInactivityTimer}

CB010369_CB008225_srbInactivityTimerSA_based_transition_to_RRC_inactive_after_HO
    [Documentation]    The purpose of the test case is to verify the transition of UE from RRC_Connected to
    ...    RRC_Inactive state due to expiration of Inactivity timer (rfspRrcInactInactivityTimer) for a configured RFSP.
    ...    Coexisting timers setting:
    ...     srbInactivityTimerSA:           70
    ...     drbInactivityTimerSA:           40
    ...     rfspInactivityTimer:            30
    ...     drbRrcInactInactivityTimerSA:   10
    ...     rfspRrcInactInactivityTimer:    20

    [Setup]    Run Keywords
    ...           Find SCFC And Send Delta Commissioning Aic
    ...               ${delta_for_second_timers_settings}
    ...    AND    Wait For All Cells To Be Enabled Aic
    ...    AND    Configure AMF
    ...    AND    Start Default Logging
    ...               output_dirpath=${OUTPUT_DIR}/${TEST_NAME}
    ...               alias=${gnb_vCU_tcpdump_alias}
    ...    AND     Wait For Tshark From CpRT To Be Collecting

    Attach Ue    ue_id=${ue_id}    cell=1    enb=2
    Establish Pdu Session    ue_id=${ue_id}    pdu_id=1    nwslice=1    gw_id=1

    Verify rfspRrcInactInactivityTimer Sent To UE    ${filter_rfspRrcInactInactivityTimer_high_set}
    Verify RFSP Sent To UE

    Perform IntraFreq Handover UE To Second Cell
    Wait And Verify UE Transfer To RRC_Inactive
    Verify Ue Bearer Inactivity Detected At gNB

    Verify Expiration Of Timer Causing Transfer To RRC_Inactive    ${TC_2_srbInactivityTimerSA}


*** Keywords ***
Configure AMF
    Configure AMF for CB010369
    Configure AMF for CB008225

Configure AMF For CB010369
    Execute Egate Command
    ...    cmd=amf_ue_ics_param id=1 ue=${ue_id} indexToRFSP=${indexToRFSP}

Configure AMF For CB008225
    ${cmd}=    Catenate
    ...    amf_ue_ics_param id=1 ue=${ue_id} core_network_assistance_info=on ue_identity_index_value=1
    ...    ue_specific_drx=64 periodic_registration_update_timer=5:1min plmn_id=311:489 tac_id=200
    Execute Egate Command    ${cmd}

Verify rfspRrcInactInactivityTimer Sent To UE
    [Arguments]    ${rfspRrcInactInactivityTimer_setting}
    Verify tshark for single message
    ...    alias=${gnb_vCU_tcpdump_alias}
    ...    packet_filter=${rfspRrcInactInactivityTimer_setting}
    ...    pcap_file_path=default

Verify RFSP Sent To UE
    Verify tshark for single message
    ...    alias=${gnb_vCU_tcpdump_alias}
    ...    packet_filter=${filter_RFSP_act_AMF}
    ...    pcap_file_path=default

Perform IntraFreq Handover UE To Second Cell
    ${arfcnSsbPbch_cell_2}=    Get Admin Object Parameter Value Vdu Aic
    ...    dist_name=MRBTS-1/NRBTS-1/NRCELL-2
    ...    parameter_name=arfcnSsbPbch
    ${physCellId_cell_2}=    Get Admin Object Parameter Value Vdu Aic
    ...    dist_name=MRBTS-1/NRBTS-1/NRCELL-2
    ...    parameter_name=physCellId
    ${cmd}=    Catenate
    ...    ue_ho_nr ue_id\=${ue_id} meas_type\=A3 tgt_phycell_id\=${physCellId_cell_2}
    ...    tgt_cell_ssb_frequency\=${arfcnSsbPbch_cell_2}
    Execute Egate Command And Wait For Data
    ...    cmd=${cmd}
    ...    pass_regexp=message c1 : rrcReconfigurationComplete

Wait And Verify UE Transfer To RRC_Inactive
    Start counting packets and wait for given packets number
    ...    nr_of_packets=1
    ...    alias=${DEFAULT_UU_TSHARK_ALIAS}
    ...    timeout=180
    ...    packet_filter=${filter_RRC_Inactive_verf_UE_lvl}

Verify Ue Bearer Inactivity Detected At gNB
    Verify tshark for single message
    ...    alias=${gnb_vCU_tcpdump_alias}
    ...    packet_filter=${filter_RRC_Inactive_verf_gNB_lvl}
    ...    pcap_file_path=default

Measure Time For The Transsition To RRC_Inactive
    ${result}=    Time between two tshark messages
    ...    alias=${gnb_vCU_tcpdump_alias}
    ...    filter1=${filter_IntraFreq_HO_completed}
    ...    filter2=${filter_RRC_Inactive_verf_UE_lvl}
    ...    output_pdml_filepath1=${OUTPUT_DIR}/${TEST_NAME}/nr_rrc_rrcReconfigurationComplete.pdml
    ...    output_pdml_filepath2=${OUTPUT_DIR}/${TEST_NAME}/nr_rrc_suspendConfig.pdml
    ...    pcap_file_path=default
    [Return]    ${result}

Verify Expiration Of Timer Causing Transfer To RRC_Inactive
    [Arguments]    ${timer_setting}
    ${time_elapsed}=    Measure time for the transsition to RRC_Inactive
    ${result}=   Evaluate   ${timer_setting} - 10 <= ${time_elapsed} <= ${timer_setting} + 10
    Should be true    ${result}

Get Current CloudBTS Configuration
    Get Scfc File Aic        ${OUTPUT_DIR}${/}ORG_BTS_vCU_SCF.xml
    Get Scfc File vDU Aic    ${OUTPUT_DIR}${/}ORG_BTS_vDU_SCF.xml

Restore Original CloudBTS Configuration
    Send Full Commissioning vDU Aic    input_filepath=${OUTPUT_DIR}${/}ORG_BTS_vDU_SCF.xml    vdu=1
    Perform Commissioning vCU Aic      path_to_plan_file=${OUTPUT_DIR}${/}ORG_BTS_vCU_SCF.xml

Upload XML Delta Vcu
    [Arguments]    ${scfc_filename}
    ${scfc_path}=    Get Commissioning File For Enb Release Name     input_filename=${scfc_filename}
    Log To Console    Uploading new delta: ${scfc_path}
    vcu_cm.Fast Delta Commissioning With Delta XML File     ${scfc_path}

Upload XML Delta Vdu
    [Arguments]    ${scfc_filename}
    ${scfc_path}=    Get Commissioning File For Enb Release Name     input_filename=${scfc_filename}
    Log To Console    Uploading new delta: ${scfc_path}
    vdu_cm.Fast Delta Commissioning With Delta XML File     ${scfc_path}

Wait For Tshark From CpRT To Be Collecting
    FOR    ${attempts}    IN RANGE    1    5
        ${result}=    Run Keyword And Ignore Error    Verify Tshark
    ...                alias=${gnb_vCU_tcpdump_alias}
    ...                packet_filter=e1ap
    ...                pass_criteria=' >= 1'
    ...                pcap_file_path=default
        Exit For Loop If    ${result} == ('PASS', None)
        Sleep    5s
    END
