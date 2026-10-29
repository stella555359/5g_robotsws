*** Settings ***
Force Tags    CLOUD_5G_I_LO_AP_LO_SANSA_FS_ECPRI_CMWV_TDD
...           CONFIGURED    RAN_5G_TDD    RAN_5G    CRT    SBTS00    SBTS23R1    PY36
...           NoResUsage

Documentation    :copyright: Nokia
...              :authors: Kamil Wos, Julia Szymczak
...              :contact: kamil.wos@nokia.com, julia.szymczak@nokia.com

Resource     5GC000752_D_Keywords.robot
Resource     5GC000752_D_Variables.robot

Suite Setup     Run Keywords    Start Default Logging And Reach Onair
    ...                         output_dirpath=${OUTPUT_DIR}/Suite_Setup_Logs
    ...                         lua_cfg_filepath=${CURDIR}/../../resources/egate_2c_tdd_2c_fdd_sansa.lua
    ...         AND             Stop Default Logging    output_dirpath=${OUTPUT_DIR}/Suite_Setup_Logs

Suite Teardown    Stop Default Processes And Gather Logs And Compress Logs

*** Test Cases ***
5GC000752-D_7_USBasicCall-D_EC34_Unsuccessful_PDU_Session_Setup_subsequent_PDU_session_5G_UE_no_response_DRB_lack_of_RRC_Reconfiguration_Complete
    [Documentation]   Correct handling of unsuccessful Initial Context Setup without PDU session
    ...    when 5GUE_rejects AS Security Activation which in turn cause RRC Security Mode Failure
    [Setup]    Start Default Logging  output_dirpath=${OUTPUT_DIR}/${TEST_NAME}
    [Teardown]    Run Keywords    Deregister Ue Without Confirmation   ue_id=1
    ...           AND             Reset UE NR RRC Reconf Param
    ...           AND             Stop Default Logging    output_dirpath=${OUTPUT_DIR}/${TEST_NAME}

    Attach UE    ue_id=1
    Establish PDU Session    ue_id=1
    Set Ue NR RRC Reconf Param    ue_id=1    value=drop
    Establish PDU Session Without Confirmation   ue_id=1    pdu_id=2   gw_id=2
    Verify Ngap Messages    packet_filter=${PDU_SESSION_RESOURCE_SETUP_FAILED}
    Verify Tshark For Ngap Ue Context Release With Automatic Id Allocation

5GC000752-D_3_USBasicCall-D_EC27_Unsuccessful_PDU_Session_Setup_subsequent_PDU_session_gNB-CU-CP_rejection
    [Documentation]   Correct handling of unsuccessful PDU Session Setup without PDU session
    ...    when 5GUE rejects AS Security Activation which in turn cause RRC Security Mode Failure
    [Setup]    Start Default Logging  output_dirpath=${OUTPUT_DIR}/${TEST_NAME}
    [Teardown]    Run Keywords    Deregister Ue Without Confirmation   ue_id=2
    ...           AND             Reset SMF Security Indication
    ...           AND             Stop Default Logging    output_dirpath=${OUTPUT_DIR}/${TEST_NAME}

    Attach Ue    ue_id=2
    Establish PDU Session    ue_id=2    pdu_id=3    gw_id=3
    Change SMF Security Indication
    Establish PDU Session Without Confirmation   ue_id=2    pdu_id=4   gw_id=4
    Check If Ues Are Active    expected_ues=1
    Verify Ngap Messages    packet_filter=${UE_INTEGRITY_PROTECTION_NOT_POSSIBLE}    timeout=30
