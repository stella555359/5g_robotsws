*** Settings ***
Documentation       Test case for EDA action
...                 Author: Xu Yuyan
...                 Contact: yuyan.xu@nokia-sbell.com
# Test Timeout    3h
Resource          ../../../../../resources/RAN_PZ_HAZ_1/SISO_OAM/oam_cm_resources/hran_frame_taf_oam.robot

*** Variables ***
${RAT_Type}
${Reset_Type}
${REPEAT_TIME}    1

*** Keywords ***
CM__Repeat_Reset_LTE_OR_NR_RAT_Via_AdminAPI
    [Documentation]    [CASE MRT]: CM__Repeat_Reset_LTE_OR_NR_RAT_Via_AdminAPI
    ...
    ...    *****************
    ...    Basic information
    ...    *****************
    ...    This case is for
    ...    Reset Rat through ADMIN API, randomly select LTE or NR, soft reset or hard reset every loop.
    ...
    ...
    ...    ******************
    ...    History of changes
    ...    ******************
    ...    - 04.10.2025 - Xu Yuyan - New case

    Set Tags    CM    AUTHOR-yuyan.xu@nokia-sbell.com     OWNER-I_NSB_MN_RAN_RD_VRF_HAZ1_8_GMS@internal.nsn.com
    Log To Console    ${TEST_NAME} start.
    Step 1: Repeat Reset Rat Via Admin API

Select LTE Or NR Rat
    Log To Console    Select LTE Or NR Rat
    ${rat_type_random}    Evaluate    random.choice(["LTE","NR"])    modules=random, sys
    ${rat_type_select}    Set Variable If    "${RAT_Type}"==""    ${rat_type_random}    ${RAT_Type}
    ${reset_type_random}    Evaluate    random.choice(["Soft","Hard"])    modules=random, sys
    ${reset_type_select}    Set Variable If    "${Reset_Type}"==""    ${reset_type_random}    ${Reset_Type}
    Set Test Variable    ${rat_type_select}
    Set Test Variable    ${reset_type_select}


Step ${index}: Repeat Reset Rat Via Admin API
    Log To Console    Step ${index}: Repeat Reset Rat Via Admin API
    FOR    ${index}    IN RANGE    1    ${${REPEAT_TIME}+1}
        Log To Console    Repeat Time: ${index}
        Select LTE Or NR Rat
        Log To Console    Start reset ${rat_type_select} with ${reset_type_select}
        coam.rat_reset    rat_type=${rat_type_select}    reset_type=${reset_type_select}    timeout=180s
        Wait Until Keyword Succeeds    20min    30s    Check SBTS SMOD RMOD Cells Alarms
    END

TC Setup
    Common Test Setup SBTS    scf_check=${FALSE}


TC Teardown
    Log To Console    TC Teardown
    Common Test Teardown SBTS