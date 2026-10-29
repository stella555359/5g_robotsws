*** Settings ***
Resource    ../../../resources_mem/common.robot
Resource    ../../../resources_mem/alarms.robot
Resource    ../../../resources_mem/ald.robot
Resource    ../../../resources_mem/netact.robot
Resource    ../../../resources_mem/power_saving.robot
Resource    ../../../resources_mem/L3_call.robot

Documentation
...  TEST NAME:     SM.23_BBMOD_Reset_via_NA
...  AUTHORS:       mateusz.gumieniak@nokia.com
...  MAINTAINER:    RAN_PZ_WRO_3_SG01
...  *****************
...  Basic information
...  *****************
...  This test resets random RMOD via NetAct
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
...  05.05.2023 - https://jiradc.ext.net.nokia.com/browse/TAW-356 - TC creation
...  30.06.2023 - https://jiradc.ext.net.nokia.com/browse/TAW-371 - BBmod random select changes
...  26.07.2023 - https://jiradc.ext.net.nokia.com/browse/TAW-388 - Update TC with conditional Graceful Cell Shutdown set as "false".
...  *******************
...  RAN PZ3 WRO1 TEMPLATE




*** Keywords ***
SM.23_BBMOD_Reset_via_NA
    SM.23_BBMOD_Reset_via_NA.Test_Step:0 Test Preparation
    SM.23_BBMOD_Reset_via_NA.Test_Step:1 Resetting BBMOD
    SM.23_BBMOD_Reset_via_NA.Test_Step:2 Final Checkpoint

SM.23_BBMOD_Reset_via_NA.Test_Step:0 Test Preparation
    Log to console    \n========================================
    Log  Step: 0 Test Preparation  console=${True}
    Log to console    ========================================
    ${COUNTER_BEFORE_TEST}=  Get Reset Counter From Blackbox  COLLECT_BLACKBOX_FILE=${True}
    netact.Upload Configuration  dist_names=PLMN-PLMN/MRBTS-${MRBTS_ID}
    Get Resettable BBMODS



SM.23_BBMOD_Reset_via_NA.Test_Step:1 Resetting BBMOD
    Log to console    \n========================================
    Log  Test_Step:1 Resetting BBMOD: ${randomBBmod}  console=${True}
    Log to console    ========================================
    ${check_sw}=  Run Keyword And Return Status  Should Not Contain  ${active_sw_version}  23R
    ${pre_reset_date}  Get Current Date
    Run Keyword If  ${check_sw}
    ...  netact.Reset NE    dist_names=PLMN-PLMN/${randomBBmod}  parameters=gracefulCellShutdown=false  verbose=True
    ...  ELSE  netact.Reset NE    dist_names=PLMN-PLMN/${randomBBmod}  verbose=True
    ${post_reset_date}  Get Current Date
    ${reset_time}  Subtract Date From Date  ${post_reset_date}  ${pre_reset_date}
    Log to console  BBMOD Reset Took: ${reset_time}
    Should Be True  ${reset_time}<190  #OM_GEN_SFS_PERF_CAP.26568
    Check If NLWG Cells Are OnAir
    Wait Until Keyword Succeeds  7x  10s  Check Cells State In Netact

SM.23_BBMOD_Reset_via_NA.Test_Step:2 Final Checkpoint
    Log to console    \n========================================
    Log  Step: 3 Final Checkpoint  console=${True}
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



Get Resettable BBMODS
    ${bbmods_parameters}    admin.Get Managed Objects    BBMOD_R
    ${bbmods}=  Create List
    ${bbmods_invalid}=  Create List
    ${bbmods_configuration}=  Create List
    FOR  ${bbmod}  IN  @{bbmods_parameters}
        ${bbmod_type_invalid}  Run Keyword And Return Status  Should Contain Any  '${bbmod['parameters']['productName']}'  FBBC
        Run Keyword If  '${bbmod['parameters']['geranSupport']}'=='True' or '${bbmod['parameters']['utranSupport']}'=='True' or ${bbmod_type_invalid}
        ...  Append To List  ${bbmods_invalid}  ${bbmod['distName']}
    END
    ${bbmods_invalid_empty}  Run Keyword And Return Status  Should Be Empty  ${bbmods_invalid}
    ${bts_info}=  admin.get bts info
    FOR  ${item}  IN  @{bts_info['basebandModules']}
        ${BTS_ID_remove}  Remove String  ${item['id']['runtime']}  MRBTS-${MRBTS_ID}
        ${bbmods_invalid_full}  Run Keyword And Return Status  Should Contain Any  '${bbmods_invalid}'  ${BTS_ID_remove}
        Run Keyword If  ${bbmods_invalid_empty}
        ...  Append To List  ${bbmods}  ${item['id']['configuration']}
        ...  ELSE  Run Keyword If  not ${bbmods_invalid_full}
        ...  Append To List  ${bbmods}  ${item['id']['configuration']}
    END
    ${randomBBmod}  Evaluate  random.choice(${bbmods})  random
    Set Test Variable  ${randomBBmod}

