*** Settings ***
Resource    ../../../resources_mem/common.robot
Resource    ../../../resources_mem/alarms.robot
Resource    ../../../resources_mem/ald.robot
Resource    ../../../resources_mem/netact.robot
Resource    ../../../resources_mem/power_saving.robot
Resource    ../../../resources_mem/L3_call.robot

Documentation
...  TEST NAME:     SM.25_BBPOOL_Reset_via_NA
...  AUTHORS:       pawel.bartkowiak@nokia.com
...  MAINTAINER:    RAN_PZ_WRO_3_SG01
...  *****************
...  Basic information
...  *****************
...  This User Scenario describes how to perform BBPOOL reset from NetAct by using Open API.
...  TC created for dedicated TLs: enb5098, enb101022 and enb101054
...  *****************
...  Pre-conditions
...  *****************
...  BTS-NetAct M-Plane connection is working
...  ACTIONS NIDD adaptation is supported by SW releases on both NetAct and BTS
...  SRNCLAB with "pure trunk base"
...  NetActTrunk - NetAct - 99.23.04.0.96 (or higher)
...  ******************
...  History of changes
...  ******************
...  08.05.2023 - https://jiradc.ext.net.nokia.com/browse/TAW-356 - TC creation
...  26.07.2023 - https://jiradc.ext.net.nokia.com/browse/TAW-388 - Update TC with conditional Graceful Cell Shutdown set as "false".
...  26.07.2023 - https://jiradc.ext.net.nokia.com/browse/TAW-394 - New KW for dynamic BBPOOL selection.
...  17.07.2025 - https://jiradc.ext.net.nokia.com/browse/FCA_VRF_OAM-23647 - solution for disabled BBPOOL
...  *******************
...  RAN PZ3 WRO1 TEMPLATE




*** Keywords ***
SM.25_BBPOOL_Reset_via_NA

    SM.25_BBPOOL_Reset_via_NA.Test_Step:0 Test Preparation
    SM.25_BBPOOL_Reset_via_NA.Test_Step:1 Resetting BBPOOL
    SM.25_BBPOOL_Reset_via_NA.Test_Step:2 Final Checkpoint

SM.25_BBPOOL_Reset_via_NA.Test_Step:0 Test Preparation

    Log to console    \n========================================
    Log  Step: 0 Test Preparation  console=${True}
    Log to console    ========================================
    ${COUNTER_BEFORE_TEST}=  Get Reset Counter From Blackbox  COLLECT_BLACKBOX_FILE=${True}
    netact.Upload Configuration  dist_names=PLMN-PLMN/MRBTS-${MRBTS_ID}
    Log    == Select resettable BBPOOL ==     console=True

    ${selected_bbpool}  Get Resettable BBPOOL
    Set Test Variable  ${selected_bbpool}
    Log     == Selected BBPOOL: ${selected_bbpool} ==   console=True
    ${bbpool_is_enabled}  Run Keyword And Return Status  Check If BBPOOL Is Enabled  ${selected_bbpool}
    Run Keyword If  not ${bbpool_is_enabled}  Run Keywords
    ...                                       Log To Console  === ${selected_bbpool} is disabled ===
    ...                                  AND  Reset Cell Allocated To Given BBPOOL   ${selected_bbpool}
    ...                                  AND  Wait Until Keyword Succeeds  2x  5s    Check If BBPOOL Is Enabled  ${selected_bbpool}
    ...                                  AND  Log To Console  === ${selected_bbpool} is enabled ===
    ...                                  AND  Check If NLWG Cells Are OnAir
    ...                                  AND  Wait Until Keyword Succeeds  7x  10s  Check Cells State In Netact


SM.25_BBPOOL_Reset_via_NA.Test_Step:1 Resetting BBPOOL
    Log to console    \n========================================
    Log  Test_Step:1 Resetting BBPOOL  console=${True}
    Log to console    ========================================
    ${time_before}  Get Current Date
    netact.Reset NE  dist_names=${selected_bbpool}  parameters=gracefulCellShutdown=false  timeout=700
    ${time_after}  Get Current Date
    ${diff}  Subtract Date From Date  ${time_after}  ${time_before}
    Should Be True  ${diff}<160  #OM_GEN_SFS_PERF_CAP.26569
    Log  == Reset time is ${diff} ==  console=true


SM.25_BBPOOL_Reset_via_NA.Test_Step:2 Final Checkpoint
    Log to console    \n========================================
    Log  Step: 2 Final Checkpoint  console=${True}
    Log to console    ========================================
    ${COUNTER_AFTER_TEST}=  Get Reset Counter From Blackbox  COLLECT_BLACKBOX_FILE=${True}
    Run Keywords
    ...  Check SMODs State  ${SMOD_expected_states}
	...  AND  Check RMODs State  ${RMOD_expected_states}
	...  AND  Check If ALDs Are Connected And Achieved Expected State
#	...  AND  Check ALDs State  ${ALD_expected_states}
	...  AND  common.Check BTS State  ${BTS_expected_states}
	...  AND  Check If NLWG Cells Are OnAir
    ...  AND  Wait Until Keyword Succeeds  7x  10s  Check Cells State In Netact
	...  AND  Check If Unexpected Alarms Are Raised  ${skip_fault}

Get Resettable BBPOOL
    [Documentation]  Keyword checks for resettable BBPOOL on ABIA and returns variable ${selected_bbpool}.
    ${bbpool}=  Create List
    ${bbmods_valid}=  Create List
    ${bbmods_parameters}=  admin.Get Managed Objects  BBMOD_R
    FOR  ${bbmod}  IN  @{bbmods_parameters}
        ${bbmod_type_valid}  Run Keyword And Return Status  Should Contain  '${bbmod['parameters']['productName']}'  ABIA
        ${geran_false}=  Run Keyword And Return Status  Should Be True  '${bbmod['parameters']['geranSupport']}'=='False'
        ${utran_false}=  Run Keyword And Return Status  Should Be True  '${bbmod['parameters']['utranSupport']}'=='False'
        ${nr_false}=  Run Keyword And Return Status  Should Be True  '${bbmod['parameters']['nrSupport']}'=='False'
        Run Keyword If  ${bbmod_type_valid} and ${geran_false} and ${utran_false} and ${nr_false}
        ...  Append To List  ${bbmods_valid}  ${bbmod['distName']}
    END
    ${bbmods_valid_not_empty}=  Run Keyword And Return Status  Should Not Be Empty  ${bbmods_valid}
    Run Keyword If  not ${bbmods_valid_not_empty}
    ...  Fail  msg=There is no ABIA valid for BBPOOL reset in configuration. Skipping test.
    ${bbpool_parameters}=  admin.Get Managed Objects  BBPOOL_R
    ${bbpool_check}=  Create List
    FOR  ${bbpool}  IN  @{bbpool_parameters}
        ${bbmod_check}=  Run Keyword And Return Status  Should Contain Any  '${bbpool['parameters']['bbPwrGroupDNList'][0]}'  @{bbmods_valid}
        Continue For Loop If    ${bbpool['parameters']['bbPoolCellsList']}==[]
        Run Keyword If  ${bbmod_check} and 'POWERGROUP_R-2' in '${bbpool['parameters']['bbPwrGroupDNList'][0-1]}'
        ...  Append To List  ${bbpool_check}  ${bbpool['distName']}
    END
    ${bbpool_not_empty}  Run Keyword And Return Status  Should Not Be Empty  ${bbpool_check}
    Run Keyword If  not ${bbpool_not_empty}
    ...  Fail  msg=There is no resettable BBPOOL in configuration. Skipping test
    ${get_bbpool}=  Evaluate  random.choice(${bbpool_check})  random
    ${bbpool_id}=  Fetch From Right  ${get_bbpool}  -
    ${selected_bbpool}  Set Variable  MRBTS-${MRBTS_ID}/MNL-1/MNLENT-1/BBADM-1/BBPOOL-${bbpool_id}
    [Return]  ${selected_bbpool}

Get Cell Allocated To Given BBPOOL ID
    [Arguments]  ${bbpool_id}
    ${cell_in_bbpool}  Set Variable
    ${bbpoolalloc_r}   admin.Get Managed Objects  BBPOOLALLOC_R
    FOR  ${object}  IN  @{bbpoolalloc_r}
      IF  '${bbpool_id}' != '${object['parameters']['hostingBbPoolId']}'  CONTINUE
      ${cell_distname}  ${ignore}  Split String From Right  ${object['distName']}  separator=/  max_split=1
      ${cell_in_bbpool}  Set Variable  ${cell_distname}
      BREAK
    END
    [Return]  ${cell_in_bbpool}

Reset Cell Allocated To Given BBPOOL
    [Arguments]  ${bbpool}
    ${id}  Fetch From Right  ${bbpool}  -
    ${allocated_cell}  Get Cell Allocated To Given BBPOOL ID  ${id}
    Log To Console  === Resetting Cell: ${allocated_cell} ===
    admin.Reset Cell  ${allocated_cell}

Check If BBPOOL Is Enabled
    [Arguments]  ${bbpool}
    ${id}  Fetch From Right  ${bbpool}  -
    ${BBPOOL_R}  admin.Get Managed Objects  BBPOOL_R
    FOR  ${object}  IN  @{BBPOOL_R}
      IF  'BBPOOL_R-${id}' not in '${object['distName']}'  CONTINUE
      Should Be Equal As Strings  ${object['parameters']['operationalState']}  ENABLED  ignore_case=True
    END
