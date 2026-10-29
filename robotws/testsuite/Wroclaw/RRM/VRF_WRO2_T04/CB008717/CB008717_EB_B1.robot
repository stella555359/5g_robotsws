*** Settings ***
Force Tags    SBTS00    CONFIGURED    RAN_5G_TDD    RAN_5G    PY310
...           CLOUD_5G_I_BOO_AP_LOO    VARIANT_SANSA_FS_ECPRI_CMWV_FDD+TDD
...           NoResUsage    AP_REG    RF50

Documentation    :copyright: Nokia
...              :authors: Piotr Pinderak
...              :contact: piotr.pinderak@nokia.com

Resource    CB008717_Keywords_And_Variables.robot

Suite Setup    Run Keywords    Get Scfc File    output_filepath=${OUTPUT_DIR}/../initial_commissioning_file.xml
...            AND             Backup And Modify Swconfig File    parameters_list=@{swconfig_rndFlag}
...            AND             Get Iphy Xml File    output_filepath=${OUTPUT_DIR}/../iphy.xml
...            AND             Setup Test Line
...                                iphy_xml_filepath=${CURDIR}/config/iphy.xml
...                                scfc_filename=scfc_fwaue.xml
...                                perform_full_commissioning=${FULL_COMMISSIONING}
...                                perform_testline_reset=${RESET_TL}
...                                output_dirpath=${OUTPUT_DIR}/testline_prep
...            AND             Start Default Logging    output_dirpath=${OUTPUT_DIR}/suite_setup_logs
...            AND             Start Vm Ethernet Interfaces
...            AND             Reach OnAir    lua_cfg=${LUA_FWAUE_FILEPATH}
...            AND             Stop Default Logging    output_dirpath=${OUTPUT_DIR}/suite_setup_logs

Suite Teardown    Run Keywords    Stop Default Processes And Gather Logs And Compress Logs
...               AND             Run Keyword If    ${RESTORE_DEFAULT_CONFIG}
...                               Send Full Commissioning    input_filepath=${OUTPUT_DIR}/../initial_commissioning_file.xml
...               AND             Run Keyword If    ${RESTORE_DEFAULT_CONFIG}
...                               Update Iphy Configuration And Modify Swconfig    iphy_xml_filepath=${OUTPUT_DIR}/../iphy.xml
...               AND             Trigger Site Reset
...               AND             Check Radios Availability
...               AND             Stop Vm Ethernet Interfaces

*** Test Cases ***
CB008717_EB_B1_1_Successful_Transition_Of_UE_RRC_Inactive_To_RRC_Connected_Resume_Triggers_Nrdc_A4_Meas_Activation_On_FWAUE_With_NRDC_Eligible_Pdu
    [Documentation]    This test case checks the gNB behaviour for FWAUE in RRC_CONNECTED state and configured with NR-DC that is successfully
    ...                transitioned to RRC_IDLE state based on the FWAUE inactivity. All CB008225 RRC_INACTIVE state suspend conditions are met
    ...                besides that FWAUE is configured with NR-DC
    ...                5G_RAN_USR_RRM_18457; 5G_RAN_USR_RRM_22421; 5G_RAN_USR_RRM_18457; 5G_RAN_USR_RRM_15297; 5G_RAN_USR_RRM_18017
    ...                5G_RAN_USR_RRM_18085

    [Setup]    Start Default Logging    output_dirpath=${OUTPUT_DIR}/${TEST_NAME}

    Trigger Core Network Assistance Information For FWAUE RRC Inactive State In Initial Context Setup Request Procedure    ue_id=1
    Set Traffic Type For UE And PDU Session    ue_id=1    pdu_id=1
    Attach UE    ue_id=1
    Establish PDU Session    ue_id=1    pdu_id=1    gw_id=1    nwslice=1
    Wait For Release For No CoreNetworkAssistanceInformation UE
    Start Data Traffic For UE    ue_id=1    pdu_id=1
    Verify Tcpdump Log    packet_filter=${RRC_RELEASE}
    Verify Tcpdump Log    packet_filter=${NR_RRC_RESUME}
    Verify Tcpdump Log    packet_filter=${NR_RRC_RESUME_COMPLETED}
    Verify Ngap Messages    packet_filter=${NGAP_INITIAL_CONTEXT_SETUP_REQUEST_INDEX_TO_RFSP}
    Verify Tcpdump Log    packet_filter=${F1AP_UE_CONTEXT_MODIFICATION_REQUEST_MEAS_CONFIG}
    Verify Tcpdump Log    packet_filter=${F1AP_UE_CONTEXT_MODIFICATION_REQUEST_MEAS_GAP_CONFIG_NOT_INCLUDED}    number_of_messages=0
    Verify Tcpdump Log    packet_filter=${F1AP_UE_CONTEXT_MODIFICATION_REQUEST_MEASUREMENTS_OBJECTS_CANDIDATE}
    Verify Tcpdump Log    packet_filter=${F1AP_UE_CONTEXT_MODIFICATION_REQUEST_REPORT_CONFIG_NR}
    Verify Tcpdump Log    packet_filter=${F1AP_UE_CONTEXT_MODIFICATION_RESPONSE_MEAS_GAP_CONFIG}
    Verify Tcpdump Log    packet_filter=${RRC_RECONFIGURATIOM_MESSAGE_PCELL}
    Verify Tcpdump Log    packet_filter=${RRC_RECONFIGURATIOM_MESSAGE_PSCELL}
    Verify Tcpdump Log    packet_filter=${RRC_RECONFIGURATIOM_MESSAGE_REPORT_CONFIG_NR}
    Verify Tcpdump Log    packet_filter=${RRC_RECONFIGURATIOM_MESSAGE_MEAS_IDS}
    Verify Tcpdump Log    packet_filter=${RRC_RECONFIGURATIOM_MESSAGE_MEAS_GAP_CONFIG}
    Verify Tcpdump Log    packet_filter=${RRC_RECONFIGURATIOM_MESSAGE_S_MEASURE_CONFIG}

    [Teardown]    Run Keywords    Add Scout External Execution ID To Reporting Portal
        ...       AND             Deregister UE Without Confirmation   ue_id=1
        ...       AND             Trigger Site Reset
        ...       AND             Check Radios Availability
        ...       AND             Stop Default Logging     output_dirpath=${OUTPUT_DIR}/${TEST_NAME}

CB008717_EB_B1_2_A4RetryTimer_Is_Restarted_When_No_Nr_Dc_Eligible_Pdu_Session_Is_Established
    [Documentation]    This test case checks the gNB behaviour for FWAUE in RRC_CONNECTED state and configured with NR-DC that is successfully
    ...                transitioned to RRC_IDLE state based on the FWAUE inactivity. PDU session is non eligible and A4RetryTimer is restarted.
    ...                All CB008225 RRC_INACTIVE state suspend conditions are met
    ...                besides that FWAUE is configured with NR-DC
    ...                5G_RAN_USR_RRM_18457; 5G_RAN_USR_RRM_22421; 5G_RAN_USR_RRM_18457; 5G_RAN_USR_RRM_15297
    ...                5G_RAN_USR_RRM_18017; 5G_RAN_USR_RRM_18085

    [Setup]    Start Default Logging    output_dirpath=${OUTPUT_DIR}/${TEST_NAME}

    Trigger Core Network Assistance Information For FWAUE RRC Inactive State In Initial Context Setup Request Procedure    ue_id=2
    Set Traffic Type For UE And PDU Session    ue_id=2    pdu_id=2
    Set Traffic Type For UE And PDU Session    ue_id=2    pdu_id=3
    Attach UE    ue_id=2
    Establish PDU Session    ue_id=2    pdu_id=2    gw_id=2    nwslice=1
    Modify PDU Session To Non Eligible NRDC PDU Session
    Wait For Release For No CoreNetworkAssistanceInformation UE
    Start Data Traffic For UE    ue_id=2    pdu_id=2
    Establish PDU Session    ue_id=2    pdu_id=3    gw_id=3    nwslice=1
    Start Data Traffic For UE    ue_id=2    pdu_id=3
    Verify Tcpdump Log    packet_filter=${RRC_RELEASE}
    Verify Tcpdump Log    packet_filter=${NR_RRC_RESUME}
    Verify Tcpdump Log    packet_filter=${NR_RRC_RESUME_COMPLETED}
    Verify Ngap Messages    packet_filter=${NGAP_INITIAL_CONTEXT_SETUP_REQUEST_INDEX_TO_RFSP}
    Verify Ngap Messages    packet_filter=${NGAP_ELIGIBLE_PDU_SESSION_RESOURCE_SETUP_REQUEST}
    Verify Tcpdump Log    packet_filter=${F1AP_UE_CONTEXT_MODIFICATION_REQUEST_MEAS_CONFIG}
    Verify Tcpdump Log    packet_filter=${F1AP_UE_CONTEXT_MODIFICATION_REQUEST_MEAS_GAP_CONFIG_NOT_INCLUDED}    number_of_messages=0
    Verify Tcpdump Log    packet_filter=${F1AP_UE_CONTEXT_MODIFICATION_REQUEST_MEASUREMENTS_OBJECTS_CANDIDATE}
    Verify Tcpdump Log    packet_filter=${F1AP_UE_CONTEXT_MODIFICATION_REQUEST_REPORT_CONFIG_NR}
    Verify Tcpdump Log    packet_filter=${RRC_RECONFIGURATIOM_MESSAGE_PCELL}
    Verify Tcpdump Log    packet_filter=${RRC_RECONFIGURATIOM_MESSAGE_PSCELL}
    Verify Tcpdump Log    packet_filter=${RRC_RECONFIGURATIOM_MESSAGE_REPORT_CONFIG_NR}
    Verify Tcpdump Log    packet_filter=${RRC_RECONFIGURATIOM_MESSAGE_MEAS_IDS}
    Verify Tcpdump Log    packet_filter=${RRC_RECONFIGURATIOM_MESSAGE_MEAS_GAP_CONFIG}
    Verify Tcpdump Log    packet_filter=${RRC_RECONFIGURATIOM_MESSAGE_S_MEASURE_CONFIG}
    Verify Tcpdump Log    packet_filter=${RRC_RECONFIGURATION_COMPLETE}

    [Teardown]    Run Keywords    Add Scout External Execution ID To Reporting Portal
        ...       AND             Deregister UE Without Confirmation   ue_id=2
        ...       AND             Trigger Site Reset
        ...       AND             Check Radios Availability
        ...       AND             Stop Default Logging     output_dirpath=${OUTPUT_DIR}/${TEST_NAME}

CB008717_EB_B1_4_NR_DC_A4_Measurement_And_A4_RetryTimer_Does_Not_Start_For_Ue_NR_DC_Pscell_Ue_Is_Not_FWAUE
    [Documentation]    This test case checks the gNB behaviour for UE in RRC_CONNECTED state and configured with NR-DC that is successfully
    ...                transitioned to RRC_IDLE state based on the UE inactivity. All CB008225 RRC_INACTIVE state suspend conditions are met
    ...                besides that UE is configured with NR-DC. Conditions for FWAUE are not met and A4retryTimer does not start
    ...                5G_RAN_USR_RRM_18457; 5G_RAN_USR_RRM_22421; 5G_RAN_USR_RRM_18457; 5G_RAN_USR_RRM_15297; 5G_RAN_USR_RRM_18017
    ...                5G_RAN_USR_RRM_18085

    [Setup]    Start Default Logging    output_dirpath=${OUTPUT_DIR}/${TEST_NAME}

    Trigger Core Network Assistance Information For Non FWAUE RRC Inactive State In Initial Context Setup Request Procedure    ue_id=3
    Set Traffic Type For UE And PDU Session    ue_id=3    pdu_id=4
    Attach UE    ue_id=3
    Establish PDU Session    ue_id=3    pdu_id=4    gw_id=4    nwslice=1
    Wait For Release For No CoreNetworkAssistanceInformation UE
    Start Data Traffic For UE    ue_id=3    pdu_id=4
    Verify Tcpdump Log    packet_filter=${RRC_RELEASE}
    Verify Tcpdump Log    packet_filter=${NR_RRC_RESUME}
    Verify Tcpdump Log    packet_filter=${NR_RRC_RESUME_COMPLETED}
    Verify Ngap Messages    packet_filter=${NGAP_INITIAL_CONTEXT_SETUP_REQUEST_INDEX_TO_RFSP}    number_of_messages=0
    Verify Ngap Messages    packet_filter=${NGAP_ELIGIBLE_PDU_SESSION_RESOURCE_SETUP_REQUEST}    number_of_messages=0
    Verify Tcpdump Log    packet_filter=${F1AP_UE_CONTEXT_MODIFICATION_REQUEST_MEAS_CONFIG}      number_of_messages=0
    Verify Tcpdump Log    packet_filter=${RRC_RECONFIGURATIOM_MESSAGE_MEAS_GAP_CONFIG}    number_of_messages=0

    [Teardown]    Run Keywords    Add Scout External Execution ID To Reporting Portal
        ...       AND             Deregister UE Without Confirmation   ue_id=3
        ...       AND             Stop Default Logging     output_dirpath=${OUTPUT_DIR}/${TEST_NAME}

