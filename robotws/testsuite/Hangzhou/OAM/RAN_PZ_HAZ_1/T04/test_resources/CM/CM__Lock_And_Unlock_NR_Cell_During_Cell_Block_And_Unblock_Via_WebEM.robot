*** Settings ***
Documentation       Test case for
...                 Author: Xu Yuyan
...                 Contact: yuyan.xu@nokia-sbell.com
# Test Timeout    3h
Resource          ../../../../../resources/RAN_PZ_HAZ_1/SISO_OAM/oam_cm_resources/hran_frame_taf_oam.robot

*** Keywords ***
CM__Lock_And_Unlock_NR_Cell_During_Cell_Block_And_Unblock_Via_WebEM
    [Documentation]    [CASE MRT]: CM__Lock_And_Unlock_NR_Cell_During_Cell_Block_And_Unblock_Via_WebEM
    ...
    ...    *****************
    ...    Basic information
    ...    *****************
    ...
    ...    Lock all NR cells via webEM windows1 and block all NR cells via webEM windows2 in parallel
    ...
    ...    ******************
    ...    History of changes
    ...    ******************
    ...    - 10.01.2024 - Bin.7.Liu - Commit to robotws.
    Set Tags    CM    UI    OWNER-II_NSB_MN_RAN_PZ_1_HAZ_11@internal.nsn.com    AUTHOR-bin.7.Liu@nokia-sbell.com
    LOG    ${TEST_NAME} start.    console=${True}
    Step 1: Block NR Cells And Set AdministrativeState As Locked
    Step 2: UnBlock NR Cells And Set AdministrativeState As Unlocked
    Step 3: Check SBTS Status

SetUp
    log    SetUp    console=${True}
    Set Test Variable    ${NEED_RECOVER}    ${False}
    Common Test Setup SBTS
    ${WINDOWS_INDEX_CELL_BLOCKER}    SBTS WEM Logon    https://${MPLANE_IP}    skip_error=${True}
    Status Of RAT Should Be OK
    SBTS WEM Open Alarm Management
    ${alarms}    SBTS WEM Get Alarms On Current Page
    Set Test Variable    ${ALARMS_BEFORE_TEST}    ${alarms}
    ${filter_list}    Create List
    ${IGNORE_ALARM_FILTER_STRING}    Create List    {'Fault ID':'61649'}    {'Fault ID':'61524'}    {'Fault ID':'4655'}
    ...    {'Fault ID':'61652'}    {'Fault ID':'4654'}
    FOR    ${str}    IN    @{IGNORE_ALARM_FILTER_STRING}
        &{filter}    Evaluate    ${str}
        Append To List    ${filter_list}    ${filter}
    END
    Set Test Variable    ${IGNORE_ALARM_FILTER}    ${filter_list}
    Set Test Variable    ${WINDOWS_INDEX_CELL_BLOCKER}
    ${LIST_CELL_NAME}    Create List
    ${LIST_CELL_MO}    Create List
    SBTS WEM Filt Parameter    Cell name
    ${parameters}    SBTS WEM Get Parameters In PE Table
    FOR    ${params}    IN    @{parameters}
        ${MO}    Set Variable    ${params['object']}
        ${not_NRCEL}    Run Keyword And Return Status    Should Not Contain    ${MO}    /NRCELL-
        Continue For Loop If    ${not_NRCEL}
        Append To List    ${LIST_CELL_MO}    ${MO}
        ${cell_name}    Set Variable If    "${params['actual_value']}"=="!DELETE!"    ${MO}    ${MO.split('/')[-1]}     #${params['actual_value']}
        Append To List    ${LIST_CELL_NAME}    ${cell_name}
    END
    Set Test Variable    ${LIST_CELL_NAME}
    Set Test Variable    ${LIST_CELL_MO}
    SBTS WEM BackUp Current Configuration    https://${MPLANE_IP}    skip_error=${True}    windows_index=${WINDOWS_INDEX_CELL_BLOCKER}
    ${WINDOWS_INDEX_PE_LOCKER}    SBTS WEM Logon    https://${MPLANE_IP}    skip_error=${True}
    Set Test Variable    ${WINDOWS_INDEX_PE_LOCKER}


CaseTearDown
    log    CaseTearDown    console=${True}
    ${time}    Get Time    epoch
    Switch Browser    ${WINDOWS_INDEX_PE_LOCKER}
    #Selenium2Library.Set Window Size    1600    1200
    Run Keyword If Test Failed    Capture Page Screenshot    LOCKER_${time}.png
    Run Keyword And Return Status    SBTS WEM Close Dialog After Activation
    SBTS WEM Download Chrome Console Log
    Switch Browser    ${WINDOWS_INDEX_CELL_BLOCKER}
    Selenium2Library.Set Window Size    1600    1200
    Run Keyword If Test Failed    Capture Page Screenshot    BOLOCKER_${time}.png
    SBTS WEM Download Chrome Console Log
    Common Test Teardown SBTS
    Run Keyword If    ${NEED_RECOVER}    Wait Until Keyword Succeeds    2x    10s    SBTS WEM Unblock Cells    ${LIST_CELL_NAME}
    ...    ${True}
    Return From Keyword If    not ${NEED_RECOVER}
    ${param_list}    Evaluate    [{"Administrative state":["Unlocked"]}]
    FOR    ${cell_mo}    IN    @{LIST_CELL_MO}
        SBTS WEM Set Parameters Of One Object    ${cell_mo.split('/')[-1]}    ${param_list}
    END
    SBTS WEM Validate Plan
    SBTS WEM Activate Plan
    [Teardown]    Close All Browsers

Step ${index}: Check SBTS Status
    log    Step ${index}: Check SBTS Status    console=${True}
    Selenium2Library.Set Window Size    50    50
    Switch Browser    ${WINDOWS_INDEX_CELL_BLOCKER}
    Selenium2Library.Set Window Size    1600    1200
    Wait Until Keyword Succeeds    10x    5s    Status Of RAT Should Be OK
    SBTS WEM Open Alarm Management
    ${alarms}    SBTS WEM Get Alarms On Current Page
    Set Test Variable    ${ALALRMS_AFTER_TEST}    ${alarms}
    ${alarms_cleared}    ${alarms_raised}    Compare Alarm List    ${ALARMS_BEFORE_TEST}    ${ALALRMS_AFTER_TEST}    ${IGNORE_ALARM_FILTER}
    ${count}    Get Length    ${alarms_raised}
    Should Be Equal As Integers    ${count}    ${0}
    Set Test Variable    ${NEED_RECOVER}    ${False}

Step ${index}: Block NR Cells And Set AdministrativeState As Locked
    log    Step ${index}: Block NR Cells And Set AdministrativeState As Locked    console=${True}
    Switch Browser    ${WINDOWS_INDEX_PE_LOCKER}
    ${param_list}    Evaluate    [{"Administrative state":["Locked"]}]
    FOR    ${cell_mo}    IN    @{LIST_CELL_MO}
        SBTS WEM Set Parameters Of One Object    ${cell_mo}    ${param_list}
    END
    SBTS WEM Validate Plan
    Should Has No Configuration Error
    SBTS WEM Activate Plan    download_only=${True}
    SBTS WEM Expand Configuration Tree On Navigation Panel Under Pramater Editor    Inactive BTS configurations
    Set Test Variable    ${NEED_RECOVER}    ${True}
    SBTS WEM Activate Plan    forced_activate=${False}    wait_until_finish=${False}
    ${wait_sec}    Evaluate    random.randint(0,6)    modules=random, sys
    sleep    ${wait_sec}
    Selenium2Library.Set Window Size    50    50
    Switch Browser    ${WINDOWS_INDEX_CELL_BLOCKER}
    Selenium2Library.Set Window Size    1600    1200
    SBTS WEM Block Cells    ${LIST_CELL_NAME}    ${True}
    Selenium2Library.Set Window Size    50    50
    Switch Browser    ${WINDOWS_INDEX_PE_LOCKER}
    Selenium2Library.Set Window Size    1600    1200
    Wait Until WebElement Enabled With Attribute    //deploy-plan-modal-component//ui-button[@a-text="Close"]//button    timeout=600s
    SBTS WEM Close Dialog After Activation
    FOR    ${cell_name}    IN    @{LIST_CELL_NAME}
        ${status}    SBTS WEM Get Cell Status    ${cell_name}
        Should Be Equal As Strings    ${status['Administrative state']}    Locked    ignore_case=True
        Should Be Equal As Strings    ${status['Blocking state']}    Blocked    ignore_case=True
    END

Step ${index}: UnBlock NR Cells And Set AdministrativeState As Unlocked
    log    Step ${index}: UnBlock NR Cells And Set AdministrativeState As Unlocked    console=${True}
    Selenium2Library.Set Window Size    50    50
    Switch Browser    ${WINDOWS_INDEX_PE_LOCKER}
    Selenium2Library.Set Window Size    1600    1200
    ${param_list}    Evaluate    [{"Administrative state":["Unlocked"]}]
    FOR    ${cell_mo}    IN    @{LIST_CELL_MO}
        SBTS WEM Set Parameters Of One Object    ${cell_mo}    ${param_list}
    END
    SBTS WEM Validate Plan
    Should Has No Configuration Error
    SBTS WEM Activate Plan    forced_activate=${False}    wait_until_finish=${False}
    ${wait_sec}    Evaluate    random.randint(0,6)    modules=random, sys
    sleep    ${wait_sec}
    Selenium2Library.Set Window Size    50    50
    Switch Browser    ${WINDOWS_INDEX_CELL_BLOCKER}
    Selenium2Library.Set Window Size    1600    1200
    SBTS WEM Unblock Cells    ${LIST_CELL_NAME}    ${True}
    Selenium2Library.Set Window Size    50    50
    Switch Browser    ${WINDOWS_INDEX_PE_LOCKER}
    Selenium2Library.Set Window Size    1600    1200
    Wait Until WebElement Enabled With Attribute    //deploy-plan-modal-component//ui-button[@a-text="Close"]//button    timeout=600s
    SBTS WEM Close Dialog After Activation
    FOR    ${cell_name}    IN    @{LIST_CELL_NAME}
        ${status}    SBTS WEM Get Cell Status    ${cell_name}
        Should Be Equal As Strings    ${status['Administrative state']}    Unlocked    ignore_case=True
        Should Be Equal As Strings    ${status['Blocking state']}    Unblocked    ignore_case=True
    END
