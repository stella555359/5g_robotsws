*** Settings ***
Force Tags    CLOUD_5G_I_LO_AP_LO    SANSA_FS_CPRI_CMWV_FDD+ECPRI_CMWV_TDD_AEQE_GMC    SBTS00
...           CONFIGURED    RAN_5G_TDD    RAN_5G    PY310    RAN_5G_FDD
...           NoResUsage    RF50

Documentation    :copyright: Nokia
...              :authors: Katarzyna Wisniewska
...              :contact: katarzyna.wisniewska@nokia.com

Resource     ../../../resources/airphone/5G_SW_WRO_Keywords.robot
Resource     5GC000746_A_Keywords_And_Variables.robot

Variables    ta5g_global_var

Library      ta5g_tshark
Library      ta5g_pm_counters

Suite Setup    Run Keywords    Start Default Logging    output_dirpath=${OUTPUT_DIR}/suite_setup_logs
    ...        AND             Reach Onair    lua_cfg=${CURDIR}/../../../resources/airphone/egate_2c_tdd_2c_fdd_sansa.lua    cell_type=TDD
    ...        AND             Wait For Next Full Pm Interval
    ...        AND             Perform Parameter Commissioning    parameter=actCMAS    value=true
    ...        AND             Stop Default Logging     output_dirpath=${OUTPUT_DIR}/suite_setup_logs

Suite Teardown    Run Keywords    Perform Parameter Commissioning    parameter=actCMAS    value=false
    ...           AND             Unlock All Cells
    ...           AND             Stop Default Processes And Gather Logs And Compress Logs

*** Variables ***
${NGAP_WRITE_REPLACE_WARNING_REQUEST_NUMBER_OF_BROADCASTS} =    ngap.NumberOfBroadcastsRequested == 0
${NGAP_WRITE_REPLACE_WARNING_REQUEST_CONTROLLED_NUMBER_OF_BROADCASTS} =    ngap.NumberOfBroadcastsRequested == 5

*** Test Cases ***

5GC000746_A_4_Successful_CMAS_notification_procedure_RRC_CONNECTED_next_PWS
    [Tags]    CIT    RAN_5G_FDD    SBTS23R1    SBTS22R4
    [Documentation]   Correct handling of second CMAS notification procedure when UE is in RRC_CONNECTED mode.

    [Setup]    Run Keywords    Start Default Logging    output_dirpath=${OUTPUT_DIR}/${TEST_NAME}
        ...    AND             Attach Ue    ue_id=1
        ...    AND             Trigger CMAS

    Trigger CMAS
    Verify Ngap Messages    packet_filter=${NGAP_WRITE_REPLACE_WARNING_REQUEST}    number_of_messages=2
    Verify Ngap Messages    packet_filter=${NGAP_WRITE_REPLACE_WARNING_RESPONSE}    number_of_messages=2
    Verify Ngap Messages    packet_filter=${NGAP_WRITE_REPLACE_WARNING_RESPONSE_BROADCAST_LIST_IE}    number_of_messages=2

    [Teardown]    Run Keywords    Add Scout External Execution ID To Reporting Portal
        ...       AND             Stop CMAS Broadcast    cancel_all=on
        ...       AND             Deregister Ue Without Confirmation    ue_id=1
        ...       AND             Stop Default Logging     output_dirpath=${OUTPUT_DIR}/${TEST_NAME}

