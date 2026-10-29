*** Settings ***
Resource    ../../../resources_mem/common.robot
Resource    ../../../resources_mem/alarms.robot
Resource    ../../../resources_mem/ald.robot
Resource    ../../../resources_mem/netact.robot
Resource    ../../../resources_mem/power_saving.robot
Resource    ../../../resources_mem/L3_call.robot

Documentation
...  TEST NAME:     SM.22_RMOD_Reset_via_NA
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
...  26.07.2023 - https://jiradc.ext.net.nokia.com/browse/TAW-388 - Update TC with conditional Graceful Cell Shutdown set as "false".
...  24.01.2024 - https://jiradc.ext.net.nokia.com/browse/TAW-521 - add FID4003 "Transmission path failure" to allowed + small enhancements
...  *******************
...  RAN PZ3 WRO1 TEMPLATE




*** Keywords ***
SM.22_RMOD_Reset_via_NA
    SM.22_RMOD_Reset_via_NA.Test_Step:0 Test Preparation
    SM.22_RMOD_Reset_via_NA.Test_Step:1 Resetting RMOD
    SM.22_RMOD_Reset_via_NA.Test_Step:2 Final Checkpoint

SM.22_RMOD_Reset_via_NA.Test_Step:0 Test Preparation
    Log to console    \n========================================
    Log  Step: 0 Test Preparation  console=${True}
    Log to console    ========================================
    ${COUNTER_BEFORE_TEST}=  Get Reset Counter From Blackbox  COLLECT_BLACKBOX_FILE=${True}
    Set Test Variable  ${COUNTER_BEFORE_TEST}
    netact.Upload Configuration  dist_names=PLMN-PLMN/MRBTS-${MRBTS_ID}
    ${rats}  Detect RATs
    Set Test Variable  ${rats}
    Get RMODs
    ${randomRmod}  Evaluate  random.choice(${rmods})  random
    Set Test Variable  ${randomRmod}


SM.22_RMOD_Reset_via_NA.Test_Step:1 Resetting RMOD
    Log to console    \n========================================
    Log  Test_Step:1 Resetting RMOD: ${randomRmod}  console=${True}
    Log to console    ========================================
    ${check_sw}=  Run Keyword And Return Status  Should Not Contain  ${active_sw_version}  23R
    ${shared_cell}  Check If Cells Configured On Other RMOD  ${randomRmod}
    Run Keyword If  ${shared_cell}
    ...  Allow Fault In Watchdog  faultID=4003  #fault_name: Transmission path failure
    ${pre_reset_date}  Get Current Date
    Run Keyword If  ${check_sw}
    ...  netact.Reset NE    dist_names=PLMN-PLMN/${randomRmod}  parameters=gracefulCellShutdown=false  verbose=True
    ...  ELSE  netact.Reset NE    dist_names=PLMN-PLMN/${randomRmod}  verbose=True
    ${post_reset_date}  Get Current Date
    Log To Console  Checking if selected RMOD has reached the expected state: operationalState=Disabled, the rest of the RMODs should remain Enabled
    ${bts_info}  admin.get bts info
    FOR  ${rmod}  IN  @{bts_info['radioModules']['rmod']}
        ${rmod_states}  Get From Dictionary  ${rmod}  status
        ${operational_state}  Get From Dictionary  ${rmod_states}  operationalState
        ${operational_state_upper}  Evaluate  "${operational_state}".upper()
        Run Keyword If  '${rmod['id']['configuration']}'=='${randomRmod}' and '${operational_state_upper}'!='ENABLED'
        ...                 Should Be Equal As Strings  ${operational_state}  disabled  ignore_case=True
        ...         ELSE    Should Be Equal As Strings  ${operational_state}  enabled   ignore_case=True
        ${administrative_state}  Get From Dictionary  ${rmod_states}  administrativeState
        Should Be Equal As Strings  ${administrative_state}  Unlocked  ignore_case=True
        Log To Console  State of ${rmod['id']['configuration']} is correct
    END
    ${reset_time}  Subtract Date From Date  ${post_reset_date}  ${pre_reset_date}
    Log to console  RMOD Reset Took: ${reset_time}
    Should Be True  ${reset_time}<330  #OM_GEN_SFS_PERF_CAP.26570
    Check If NLWG Cells Are OnAir
    ${if_gsm_exist}  Run Keyword And Return Status  List Should Contain Value  ${rats}  gsm
    Run Keyword If  ${if_gsm_exist}  Wait Until Keyword Succeeds  3min  30s  Check State on GNCELs  availabilityStatus  None
    Run Keyword If  ${shared_cell}  Run Keywords
    ...         Run Keyword And Ignore Error  Wait For Inactive Fault  faultID=4003  timeout=60 sec
    ...  AND    Disallow Fault In Watchdog  faultID=4003  #fault_name: Transmission path failure
    Wait Until Keyword Succeeds  7x  10s  Check Cells State In Netact

SM.22_RMOD_Reset_via_NA.Test_Step:2 Final Checkpoint
    Log to console    \n========================================
    Log  Step: 2 Final Checkpoint  console=${True}
    Log to console    ========================================
    ${COUNTER_AFTER_TEST}=  Get Reset Counter From Blackbox  COLLECT_BLACKBOX_FILE=${True}
    ${counter_diff}  Evaluate  abs(${COUNTER_AFTER_TEST} - ${COUNTER_BEFORE_TEST})
    Run Keyword If  ${counter_diff}!=${0}  Log  Reset Counter Incremented +${counter_diff}  WARN
    Run Keywords
    ...  Check SMODs State  ${SMOD_expected_states}
	...  AND  Check RMODs State  ${RMOD_expected_states}
	...  AND  Check If ALDs Are Connected And Achieved Expected State
	...  AND  common.Check BTS State  ${BTS_expected_states}
	...  AND  Check If NLWG Cells Are OnAir
    ...  AND  Wait Until Keyword Succeeds  7x  10s  Check Cells State In Netact
	...  AND  Check If Unexpected Alarms Are Raised  ${skip_fault}
