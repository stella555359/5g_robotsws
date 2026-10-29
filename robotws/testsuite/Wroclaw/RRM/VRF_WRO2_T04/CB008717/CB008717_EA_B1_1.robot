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
...                                scfc_filename=scfc.xml
...                                perform_full_commissioning=${FULL_COMMISSIONING}
...                                perform_testline_reset=${RESET_TL}
...                                output_dirpath=${OUTPUT_DIR}/testline_prep
...            AND             Start Default Logging    output_dirpath=${OUTPUT_DIR}/suite_setup_logs
...            AND             Start Vm Ethernet Interfaces
...            AND             Reach OnAir    lua_cfg=${LUA_FILEPATH}
...            AND             Stop Default Logging    output_dirpath=${OUTPUT_DIR}/suite_setup_logs

Suite Teardown    Run Keywords    Stop Default Processes And Gather Logs And Compress Logs
...               AND             Run Keyword If    ${RESTORE_DEFAULT_CONFIG}
...                               Send Full Commissioning    input_filepath=${OUTPUT_DIR}/../initial_commissioning_file.xml
...               AND             Run Keyword If    ${RESTORE_DEFAULT_CONFIG}
...                               Update Iphy Configuration And Modify Swconfig    iphy_xml_filepath=${OUTPUT_DIR}/../iphy.xml
...               AND             Trigger Site Reset
...               AND             Check Radios Availability

*** Test Cases ***
CB008717_EA_B1_1_Successful_Transition_From_RRC_Connected_To_RRC_Idle_State_Due_To_Inactivity_CB008225_Enabled_When_UE_In_NRDC_Mode
    [Documentation]    This test case checks the gNB behaviour for UE in RRC_CONNECTED state and configured with NR-DC that is successfully
    ...                transitioned to RRC_IDLE state based on the UE inactivity. All CB008225 RRC_INACTIVE state suspend conditions are met
    ...                besides that UE is configured with NR-DC.
    ...                5G_RAN_USR_RRM_18017; 5G_RAN_USR_RRM_16816; 5G_RAN_USR_RRM_15615

    [Setup]    Start Default Logging    output_dirpath=${OUTPUT_DIR}/${TEST_NAME}

    Trigger Core Network Assistance Information For RRC Inactive State In Initial Context Setup Request Procedure    ue_id=1
    Attach UE    ue_id=1
    Establish Pdu Session    ue_id=1    pdu_id=1    gw_id=1    nwslice=1
    Send Ue Measurement Nr Event A4 With Aligned Meas Id    ue_id=1    carrier_freq=2071387
    ...                                                     phycell_id=52    nrsrp_nr=60    timeout=10
    Wait For Release For No CoreNetworkAssistanceInformation UE
    Verify UE Transition To RRC INACTIVE
    Verify Tcpdump Log    packet_filter=${BEARER_CONTEXT_INACTIVITY_NOTIFICATION}
    Verify Ngap Messages    packet_filter=${UE_CONTEXT_RELEASE_REQUEST}
    Verify Ngap Messages    packet_filter=${UE_CONTEXT_RELEASE_COMMAND_NGAP}
    Verify Tcpdump Log    packet_filter=${UE_CONTEXT_RELEASE_COMMAND_NORMAL_RELEASE_PCELL_F1AP}     number_of_messages=2
    Verify Tcpdump Log    packet_filter=${BEARER_CONTEXT_RELEASE_COMMAND}
    Verify Tcpdump Log    packet_filter=${BEARER_CONTEXT_RELEASE_COMPLETE}
    Verify Tcpdump Log    packet_filter=${F1AP_UE_CONTEXT_RELEASE_COMPLETE_PCELL}
    Verify Tcpdump Log    packet_filter=${F1AP_UE_CONTEXT_RELEASE_COMPLETE_PSCELL}

    [Teardown]    Run Keywords    Add Scout External Execution ID To Reporting Portal
        ...       AND             Deregister Ue Without Confirmation   ue_id=1
        ...       AND             Stop Default Logging     output_dirpath=${OUTPUT_DIR}/${TEST_NAME}

CB008717_EA_B1_2_Successful_Transition_From_RRC_Connected_To_RRC_Idle_State_Due_To_Inactivity_CB008225_Enabled_When_UE_In_NRDC_Mode_ErrInd_Received
    [Documentation]    This test case checks the gNB behaviour for UE in RRC_CONNECTED state and configured with NR-DC that is
    ...                successfully transitioned to RRC_IDLE state based on the UE inactivity. All CB008225 RRC_INACTIVE state
    ...                suspend conditions are met besides that UE is configured with NR-DC. NGAP: UEContextReleaseCommand is not
    ...                received, NGAP:ErrorIndication is received.
    ...                5G_RAN_USR_RRM_15615; 5G_RAN_USR_RRM_15210; 5G_CP_IF_NTW_10513

    [Setup]    Start Default Logging    output_dirpath=${OUTPUT_DIR}/${TEST_NAME}

    Trigger Error Indication In NGAP UE Context Release Procedure
    Trigger Core Network Assistance Information For RRC Inactive State In Initial Context Setup Request Procedure    ue_id=2
    Attach UE    ue_id=2
    Establish Pdu Session    ue_id=2    pdu_id=2    gw_id=2    nwslice=1
    Send Ue Measurement Nr Event A4 With Aligned Meas Id    ue_id=2    carrier_freq=2071387
    ...                                                     phycell_id=52    nrsrp_nr=60    timeout=10
    Wait For Release For No CoreNetworkAssistanceInformation UE
    Verify UE Transition To RRC INACTIVE
    Verify Ngap Messages    packet_filter=${ERROR_INDICATION}
    Verify Ngap Messages    packet_filter=${UE_CONTEXT_RELEASE_COMMAND_NGAP_ELEMENT}    number_of_messages=0
    Verify Ngap Messages    packet_filter=${UE_CONTEXT_RELEASE_REQUEST}
    Verify Ngap Messages    packet_filter=${NGAP_UE_CONTEXT_RELEASE_COMPLETE}    number_of_messages=0
    Verify Tcpdump Log    packet_filter=${BEARER_CONTEXT_INACTIVITY_NOTIFICATION}
    Verify Tcpdump Log    packet_filter=${UE_CONTEXT_RELEASE_COMMAND_UNSPECIFIED_PSCELL_F1AP}
    Verify Tcpdump Log    packet_filter=${UE_CONTEXT_RELEASE_COMMAND_NORMAL_RELEASE_PCELL_F1AP}
    Verify Tcpdump Log    packet_filter=${BEARER_CONTEXT_RELEASE_COMMAND}
    Verify Tcpdump Log    packet_filter=${BEARER_CONTEXT_RELEASE_COMPLETE}
    Verify Tcpdump Log    packet_filter=${F1AP_UE_CONTEXT_RELEASE_COMPLETE_PCELL}
    Verify Tcpdump Log    packet_filter=${F1AP_UE_CONTEXT_RELEASE_COMPLETE_PSCELL}

    [Teardown]    Run Keywords    Add Scout External Execution ID To Reporting Portal
        ...       AND             Deregister Ue Without Confirmation   ue_id=2
        ...       AND             Stop Default Logging     output_dirpath=${OUTPUT_DIR}/${TEST_NAME}

