*** Settings ***
Force Tags    CLOUD_5G_I_LO_AP_LO_SANSA_FS_ECPRI_CMWV_TDD    CONFIGURED  CRT  RAN_5G_TDD
...           RAN_5G    SBTS00    SBTS23R1    PY36    12_18_UTE5GL3TIM3TL001
...           NoResUsage

Documentation    :copyright: Nokia
...              :author: Kamila Bialczyk, Katarzyna Wisniewska
...              :contact: kamila.bialczyk@nokia.com, katarzyna.wisniewska@nokia.com

Resource     ../../resources/5G_SW_WRO_Keywords.robot
Library      ta5g_tshark
Library      ta5g_egate
Library      ta5g_delta
Library      ta5g_enb

Suite Setup     Run Keywords    Start Default Logging And Reach Onair
...                             output_dirpath=${OUTPUT_DIR}/Suite_Setup_Logs
...                             lua_cfg_filepath=${CURDIR}/config/egate_1c.lua
...             AND             Stop Default Logging    output_dirpath=${OUTPUT_DIR}/Suite_Setup_Logs
...             AND             Get Scfc File
...                             output_filepath=${OUTPUT_DIR}/initial_commissioning.xml

Test Setup        Start Default Logging    output_dirpath=${OUTPUT_DIR}/${TEST_NAME}

Test Teardown    Stop Default Logging    output_dirpath=${OUTPUT_DIR}/${TEST_NAME}


Suite Teardown    Stop Default Processes And Gather Logs And Compress Logs



*** Test Cases ***
5GC000866-E_4_Encryption_Algorithm_Selection_Failure_nonNull_not_supported_by_gNB_NullFallback_Disabled
    [Tags]    GQC:FEATURE:5GC000866-E

    Find Scfc And Send Delta Commissioning    scfc_filename=delta_nea0_1_nea1_3_nea2_4_nea3_0_nullFalback_false.json
    Attach Ue    ue_id=1
    Establish Pdu Session Without Confirmation    ue_id=1     pdu_id=1    gw_id=1
    Verify Ngap Messages    packet_filter=${NGAP_INITIAL_CONTEX_SETUP_FAILURE}
    Verify Ngap Messages    packet_filter=${NGAP_UE_CONTEXT_RELEASE_COMPLETE}
    Verify Tcpdump Log      packet_filter=${F1AP_UE_CONTEXT_RELEASE_COMPLETE}
    Roll Delta Back
    ...    initial_scf_filename=${OUTPUT_DIR}/initial_commissioning.xml
    ...    delta_scf_filename=delta_nea0_1_nea1_3_nea2_4_nea3_0_nullFalback_false.json

5GC000865_E_1_5GC000866_E_1_Security_Mode_Failure_During_Initial_As_Security_Activation
    [Tags]    GQC:FEATURE:5GC000865-E    GQC:FEATURE:5GC000866-E

    Find Scfc and Send Delta Commissioning    scfc_filename=delta_change_nullFallback_true.json
    Configure Rule For SecurityModeCommand Messages    ue_id=2    rule=failure
    Attach Ue    ue_id=2
    Establish Pdu Session Without Confirmation    ue_id=2     pdu_id=2    gw_id=2
    Verify Ngap Messages
    ...    packet_filter=${NGAP_INITIAL_CONTEX_SETUP_FAILURE} && ${FAILURE_IN_RADIO_INTERFACE_PROCEDURE}
    Verify Ngap Messages     packet_filter=${NGAP_UE_CONTEXT_RELEASE_COMPLETE}
    Verify Tcpdump Log       packet_filter=${F1AP_UE_CONTEXT_RELEASE_COMPLETE}
    Roll Delta Back
    ...    initial_scf_filename=${OUTPUT_DIR}/initial_commissioning.xml
    ...    delta_scf_filename=delta_change_nullFallback_true.json
