*** Settings ***
Force Tags    CLOUD_5G_I_LO_AP_LO_SANSA_FS_ECPRI_CMWV_TDD    CONFIGURED    CRT
...           PY36    RAN_5G_TDD    RAN_5G_FDD    RAN_5G    SBTS00    SBTS23R1
...           NoResUsage


Documentation      :author: Michal Fluder, Ilona Kondel
...                :email: michal.fluder@nokia.com, ilona.kondel@nokia.com

Resource    ../../resources/5G_SW_WRO_Keywords.robot
Library     ta5g_pm_counters

Suite Setup       Run Keywords    Start Default Logging And Reach Onair    lua_cfg_filepath=${CURDIR}/../../resources/egate_2c_tdd_2c_fdd_sansa.lua
    ...                           output_dirpath=${OUTPUT_DIR}/Suite_Setup_Logs
    ...           AND             Set Counter Collecting Interval To Five Minutes
    ...           AND             Stop Default Logging    output_dirpath=${OUTPUT_DIR}/Suite_Setup_Logs

Suite Teardown    Stop Default Processes And Gather Logs And Compress Logs

Test Setup    Run Keywords    Start Default Logging    output_dirpath=${OUTPUT_DIR}/${TEST_NAME}
...           AND             Wait For Next Full Pm Interval

Test Teardown    Stop Default Logging    output_dirpath=${OUTPUT_DIR}/${TEST_NAME}

*** Variables ***
${TRIGGER_MSG3_DECODING_FAILURE}=    rrc_setup_req:21
${TRIGGER_MSG5_DECODING_FAILURE}=    rrc_setup_complete:22336699

*** Test Cases ***
5GC000723_R_1_Check_MSG3_Decoding_Failure
    [Documentation]    F1AP_INITIAL_UL_RRC_MESSAGE_TRANSFER is not present in pcap because of MSG3 decoding failure.
    [Setup]    Start Default Logging    output_dirpath=${OUTPUT_DIR}/${TEST_NAME}
    Ue Nr Rrc Setup Param    ue_id=1    if_contains=any    action=send_hex    hex=${TRIGGER_MSG3_DECODING_FAILURE}
    Attach UE With No Response    ue_id=1
    Verify Tcpdump Log    packet_filter=${F1AP_INITIAL_UL_RRC_MESSAGE_TRANSFER}    number_of_messages=0

5GC000723_R_4_Check_RRC_TID_Mismatch
    [Documentation]    After sending different transaction identifires in MSG3 and MSG5 UE Should start release after RRC_SETUP_COMPLETE
    Ue Nr Rrc Setup Param    ue_id=3    if_contains=any    action=invalid_tid
    Attach UE Without Confirmation    ue_id=3
    Verify Tcpdump Log    packet_filter=${F1AP_INITIAL_UL_RRC_MESSAGE_TRANSFER}
    Verify Tcpdump Log    packet_filter=${RRC_SETUP_COMPLETE}
    Verify Tcpdump Log    packet_filter=${RRC_RELEASE}
    Verify Tcpdump Log    packet_filter=${F1AP_UE_CONTEXT_RELEASE_COMPLETE}
    Verify RRC Release Setup Fail Counter Is Increamented

*** Keywords ***
Verify RRC Release Setup Fail Counter Is Increamented
    Wait For Next Full Pm Interval
    ${pm_counter_file}=    Get Latest Unpacked Full Pm Counters File
    Verify Any Counters In File
        ...    M55124C01012    +1    NRRRC_RRC_RELEASE_SETUP_FAIL
        ...    local_moid=PLMN-PLMN/MRBTS-1/NRBTS-1/NRCELL-1
        ...    file_path=${pm_counter_file}
