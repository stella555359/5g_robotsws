*** Settings ***
Documentation       Test case for
...                 Author: Xu Yuyan
...                 Contact: yuyan.xu@nokia-sbell.com
# Test Timeout    3h
Resource          ../../../../../resources/RAN_PZ_HAZ_1/SISO_OAM/oam_cm_resources/hran_frame_taf_oam.robot

*** Variables ***
${Lock_RF}    RMOD-3
${REPEAT_TIME}    50

*** Keywords ***
CM__Repeat_Special_RF_Lock_Unlock_Via_AdminAPI
    [Documentation]    [CASE MRT]: CM__Repeat_Special_RF_Lock_Unlock_Via_AdminAPI
    ...
    ...    *****************
    ...    Basic information
    ...    *****************
    ...    This case is for
    ...    Locked/Unlocked RF through ADMIN API
    ...
    ...    The main steps performed for the test are:
    ...    . Repeat Lock Unlock Selected RF
    ...
    ...    ******************
    ...    History of changes
    ...    ******************
    ...    - 04.10.2025 - Xu Yuyan - New case

    Set Tags    CM    AUTHOR-yuyan.xu@nokia-sbell.com     OWNER-I_NSB_MN_RAN_RD_VRF_HAZ1_8_GMS@internal.nsn.com
    Log To Console    ${TEST_NAME} start.
    FOR    ${index}    IN RANGE    1    ${${REPEAT_TIME}+1}
        Log To Console    Repeat Time: ${index}
        Lock Unlock RF
    END


TC Setup
    Common Test Setup SBTS    scf_check=${FALSE}    alarms_check=${FALSE}
    ${btsInfo}    coam.Get Bts Info
    Set Test Variable    ${rmod_list}     ${btsInfo['radioModules']['rmod']}
    #${rmods_r}    coam.Get Managed Objects    class_name=RMOD_R
    Log    ${rmod_list}
    FOR    ${item}    IN    @{rmod_list}
        Run Keyword If    "${item['id']['configuration'].split("/")[-1]}"=="${Lock_RF}"
        ...    Set Test Variable    ${RMODID_Config}    ${item['id']['configuration']}
        Run Keyword If    "${item['id']['configuration'].split("/")[-1]}"=="${Lock_RF}"
        ...    Set Test Variable    ${RMODID_Internal}    ${item['id']['internal']}
    END

TC Teardown
    Log To Console    TC Teardown
    Common Test Teardown SBTS

Lock Unlock RF
    Log To Console    Lock RF:
    coam.lock    ${RMODID_Internal}    timeout=180
    Wait Until Keyword Succeeds    5x    10 sec    coam.Assert    RMOD    ${RMODID_Internal}    ${RMOD_locked_state}
    Log To Console    Unlock RF:
    coam.unlock    ${RMODID_Internal}    timeout=180
    Wait Until Keyword Succeeds    10min    30s    Check SBTS SMOD RMOD Cells Alarms