*** Settings ***
Documentation       Test case for
...                 Author: Xu Yuyan
...                 Contact: yuyan.xu@nokia-sbell.com
# Test Timeout    3h
Resource          ../../../../../resources/RAN_PZ_HAZ_1/SISO_OAM/oam_cm_resources/hran_frame_taf_oam.robot

*** Keywords ***
CM__Lock_And_Unlock_LTE_Cell_During_Cell_Block_And_Unblock_Via_WebEM
    [Documentation]    [CASE MRT]: CM__Lock_And_Unlock_LTE_Cell_During_Cell_Block_And_Unblock_Via_WebEM
    ...
    ...    *****************
    ...    Basic information
    ...    *****************
    ...
    ...    Lock all LTE cells via webEM windows1 and block all LTE cells via webEM windows2 in parallel
    ...
    ...    ******************
    ...    History of changes
    ...    ******************
    ...    - 10.01.2024 - Bin.7.Liu - Commit to robotws.
    Set Tags    CM    UI    OWNER-II_NSB_MN_RAN_PZ_1_HAZ_11@internal.nsn.com    AUTHOR-bin.7.Liu@nokia-sbell.com
    LOG    ${TEST_NAME} start.    console=${True}
    Step 1: Block LTE Cells And Set AdministrativeState As Locked
    Step 2: UnBlock LTE Cells And Set AdministrativeState As Unlocked
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
    ${WINDOWS_INDEX_PE_LOCKER}    SBTS WEM Logon    https://${MPLANE_IP}    skip_error=${True}
    Set Test Variable    ${WINDOWS_INDEX_PE_LOCKER}
    ${LIST_CELL_NAME}    Create List
    ${LIST_CELL_ID}    Create List
    ${dic_cell_states}    SBTS WEM Get All Cell States On DetailedSiteView
    ${all_cellName}    Get Dictionary Keys    ${dic_cell_states}
    FOR    ${cellName}    IN    @{all_cellName}
        ${cell_id}    Get From Dictionary    ${dic_cell_states["${cellName}"]}    distName
        ${not_LNCEL}    Run Keyword And Return Status    Should Not Contain    ${cell_id}    /LNCEL-
        Continue For Loop If    ${not_LNCEL}
        ${host_cell}    Pop From Dictionary    ${dic_cell_states["${cellName}"]}    Host cell:    ${EMPTY}
        Continue For Loop If    '${host_cell}'!=''
        Append To List    ${LIST_CELL_ID}    ${cell_id}
        Append To List    ${LIST_CELL_NAME}    ${cellName}
    END
    Set Test Variable    ${LIST_CELL_NAME}
    Set Test Variable    ${LIST_CELL_ID}


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
    Run Keyword If    ${NEED_RECOVER}    Wait Until Keyword Succeeds    10min    10s    SBTS WEM Unblock Cells    ${LIST_CELL_NAME}
    ...    ${True}
    Return From Keyword If    not ${NEED_RECOVER}
    ${param_list}    Evaluate    [{"Administrative state":["unlocked"]}]
    FOR    ${cell_mo}    IN    @{LIST_CELL_ID}
        SBTS WEM Set Parameters Of One Object    ${cell_mo.split('/')[-1]}    ${param_list}
    END
    SBTS WEM Validate Plan
    SBTS WEM Activate Plan
    [Teardown]    Close All Browsers

Step ${index}: Check SBTS Status
    Log To Console    Step ${index}: Check SBTS Status
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

Step ${index}: Block LTE Cells And Set AdministrativeState As Locked
    Log To Console    Step ${index}: Block LTE Cells And Set AdministrativeState As Locked
    Switch Browser    ${WINDOWS_INDEX_PE_LOCKER}
    ${param_list}    Evaluate    [{"Administrative state":["locked"]}]
    FOR    ${cell_name}    IN    @{LIST_CELL_ID}
        SBTS WEM Set Parameters Of One Object    ${cell_name}    ${param_list}
    END
    SBTS WEM Validate Plan
    Should Has No Configuration Error
    Set Test Variable    ${NEED_RECOVER}    ${True}
    SBTS WEM Activate Plan    download_only=${True}
    SBTS WEM Expand Configuration Tree On Navigation Panel Under Pramater Editor    Inactive BTS configurations
    SBTS WEM Activate Plan    forced_activate=${False}    wait_until_finish=${False}
    ${wait_sec}    Evaluate    random.randint(0,6)    modules=random, sys
    sleep    ${wait_sec}
    Selenium2Library.Set Window Size    50    50
    Switch Browser    ${WINDOWS_INDEX_CELL_BLOCKER}
    Selenium2Library.Set Window Size    1600    1200
    Log To Console    Blocking cells
    SBTS WEM Block Cells    ${LIST_CELL_NAME}    ${True}
    Selenium2Library.Set Window Size    50    50
    Switch Browser    ${WINDOWS_INDEX_PE_LOCKER}
    Selenium2Library.Set Window Size    1600    1200
    Wait Until WebElement Enabled With Attribute    //deploy-plan-modal-component//ui-button[@a-text="Close"]//button    timeout=600s
    SBTS WEM Close Dialog After Activation
    Log To Console    Cells blocked
    ${dic_cell_states}    SBTS WEM Get All Cell States On DetailedSiteView
    ${all_cellName}    Get Dictionary Keys    ${dic_cell_states}
    FOR    ${cellName}    IN    @{all_cellName}
        ${cell_id}    Get From Dictionary    ${dic_cell_states["${cellName}"]}    distName
        ${not_LNCEL}    Run Keyword And Return Status    Should Not Contain    ${cell_id}    /LNCEL-
        ${admin_state}    Set Variable If    ${not_LNCEL}    Unlocked    Locked
        ${blocking_state}    Set Variable If    ${not_LNCEL}    Unblocked    Blocked
        ${not_WNCEL}    Run Keyword And Return Status    Should Not Contain    ${cell_id}    /WNCEL-
        Run Keyword If    ${not_WNCEL}
        ...    Should Be Equal As Strings    ${dic_cell_states["${cellName}"]["Administrative state:"]}    ${admin_state}    ignore_case=True
        Should Be Equal As Strings    ${dic_cell_states["${cellName}"]["Blocking state:"]}    ${blocking_state}    ignore_case=True
    END

Step ${index}: UnBlock LTE Cells And Set AdministrativeState As Unlocked
    Log To Console    Step ${index}: UnBlock LTE Cells And Set AdministrativeState As Unlocked
    Selenium2Library.Set Window Size    50    50
    Switch Browser    ${WINDOWS_INDEX_PE_LOCKER}
    Selenium2Library.Set Window Size    1600    1200
    ${param_list}    Evaluate    [{"Administrative state":["unlocked"]}]
    FOR    ${cell_name}    IN    @{LIST_CELL_ID}
        SBTS WEM Set Parameters Of One Object    ${cell_name}    ${param_list}
    END
    SBTS WEM Validate Plan
    Should Has No Configuration Error
    SBTS WEM Activate Plan    forced_activate=${False}    wait_until_finish=${False}
    ${wait_sec}    Evaluate    random.randint(0,6)    modules=random, sys
    sleep    ${wait_sec}
    Selenium2Library.Set Window Size    50    50
    Switch Browser    ${WINDOWS_INDEX_CELL_BLOCKER}
    Selenium2Library.Set Window Size    1600    1200
    Log To Console    Unblocking cells
    SBTS WEM Unblock Cells    ${LIST_CELL_NAME}    ${True}
    Selenium2Library.Set Window Size    50    50
    Switch Browser    ${WINDOWS_INDEX_PE_LOCKER}
    Selenium2Library.Set Window Size    1600    1200
    Wait Until WebElement Enabled With Attribute    //deploy-plan-modal-component//ui-button[@a-text="Close"]//button    timeout=600s
    SBTS WEM Close Dialog After Activation
    Log To Console    Cells unblocked
    ${dic_cell_states}    SBTS WEM Get All Cell States On DetailedSiteView
    ${all_cellName}    Get Dictionary Keys    ${dic_cell_states}
    FOR    ${cellName}    IN    @{all_cellName}
        ${cell_id}    Get From Dictionary    ${dic_cell_states["${cellName}"]}    distName
        ${not_WNCEL}    Run Keyword And Return Status    Should Not Contain    ${cell_id}    /WNCEL-
        Run Keyword If    ${not_WNCEL}
        ...    Should Be Equal As Strings    ${dic_cell_states["${cellName}"]["Administrative state:"]}    Unlocked    ignore_case=True
        Should Be Equal As Strings    ${dic_cell_states["${cellName}"]["Blocking state:"]}    Unblocked    ignore_case=True
    END