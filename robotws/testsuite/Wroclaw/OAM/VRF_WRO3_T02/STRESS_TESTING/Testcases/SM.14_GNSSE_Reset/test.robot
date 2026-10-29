*** Settings ***
Resource    ../../../resources_mem/common.robot
Resource    ../../../resources_mem/alarms.robot
Resource    ../../../resources_mem/power_saving.robot
Resource    ../../../resources_mem/oam_kpi.robot

Documentation
...  TEST NAME:     SM.14_GNSSE_Reset
...  AUTHORS:       artur.lebek@nokia.com, jakub.hirny@nokia.com
...  MAINTAINER:    RAN_PZ_WRO_3_SG01
...  *****************
...  Basic information
...  *****************
...  The purpose of this test case is to perform GNSSE Reset operations for randomly chosen unit,
...  check eNB status after operation is finished.
...  *****************
...  Pre-conditions
...  *****************
...  N/A
...  ******************
...  History of changes
...  ******************
...  19.04.2022 - https://jiradc.ext.net.nokia.com/browse/TAW-xxx - Test creation
...  20.09.2023 - https://jiradc.ext.net.nokia.com/browse/TAW-455 - robotws migration and small hotfixes
...  *******************
...  RAN PZ3 WRO1 TEMPLATE




*** Keywords ***
SM.14_GNSSE_Reset

    SM.14_GNSSE_Reset.Test_Step:0 Test Preparation
    SM.14_GNSSE_Reset.Test_Step:1 Select GNSSE
    SM.14_GNSSE_Reset.Test_Step:2 Perform GNSSE Reset

SM.14_GNSSE_Reset.Test_Step:0 Test Preparation
    Log to console    \n========================================
    Log  Step: 0 Test Preparation  console=${True}
    Log to console    ========================================
    ${COUNTER_BEFORE_TEST}  Get Reset Counter From Blackbox  COLLECT_BLACKBOX_FILE=${True}  iteration=${ITERATION_INDEX}
    Set Test Variable  ${COUNTER_BEFORE_TEST}
    Check If NLWG Cells Are OnAir
    SCF Backup

SM.14_GNSSE_Reset.Test_Step:1 Select GNSSE
    Log to console    \n========================================
    Log  Step: 1 Select GNSSE  console=${True}
    Log to console    ========================================
    ${gnsses}  Get GNSSEs
    ${selected_gnsse}  Evaluate  random.choice(${gnsses})  random
    Log To Console  Selected GNSSE: ${selected_gnsse}
    Set Test Variable  ${selected_gnsse}

SM.14_GNSSE_Reset.Test_Step:2 Perform GNSSE Reset
    Log to console    \n========================================
    Log  Step: 2 Perform GNSSE Reset  console=${True}
    Log to console    ========================================
    Allow Fault In Watchdog  faultID=9     #fault_name: Difference between BTS master clock and reference frequency
    Allow Fault In Watchdog  faultID=1898  #fault_name: PPS reference missing
    Allow Fault In Watchdog  faultID=4122  #fault_name: GPS receiver alarm: not tracking satellites
    Allow Fault In Watchdog  faultID=4123  #fault_name: GPS receiver alarm: survey in progress
    Allow Fault In Watchdog  faultID=4124  #fault_name: GPS receiver alarm: no stored position
    Allow Fault In Watchdog  faultID=4125  #fault_name: GPS receiver alarm: position questionable
    Log To Console  Reset GNSSE: ${selected_gnsse}
    admin.reset unit  ${selected_gnsse}  timeout=700
    Log To Console  Checking if selected GNSSE has reached the expected state: availabilityStatus=degraded
    Wait Until Keyword Succeeds  4x  5s  Verify GNSSE Status  availabilityStatus  degraded
    Log To Console  Checking if selected GNSSE has reached the expected state: availabilityStatus=none
    Wait Until Keyword Succeeds  120x  30s  Verify GNSSE Status  availabilityStatus  None
    Log To Console  Reset GNSSE is done
    Check If NLWG Cells Are OnAir
    Disallow Fault In Watchdog  faultID=9     #fault_name: Difference between BTS master clock and reference frequency
    Disallow Fault In Watchdog  faultID=1898  #fault_name: PPS reference missing
    Disallow Fault In Watchdog  faultID=4122  #fault_name: GPS receiver alarm: not tracking satellites
    Disallow Fault In Watchdog  faultID=4123  #fault_name: GPS receiver alarm: survey in progress
    Disallow Fault In Watchdog  faultID=4124  #fault_name: GPS receiver alarm: no stored position
    Disallow Fault In Watchdog  faultID=4125  #fault_name: GPS receiver alarm: position questionable
    ${COUNTER_AFTER_TEST}  Get Reset Counter From Blackbox  COLLECT_BLACKBOX_FILE=${True}  iteration=${ITERATION_INDEX}
    ${counter_diff}  Evaluate  abs(${COUNTER_AFTER_TEST} - ${COUNTER_BEFORE_TEST})
    Run Keyword If  ${counter_diff}!=${0}  Log  Reset Counter Incremented +${counter_diff}  WARN
    Sleep  120s  reason=Wait for sky visibility stabilization

Verify GNSSE Status
    [Arguments]  ${parameter}  ${expected_value}
    ${gnsse_info}  admin.get gnsses statuses
    ${status}  ${value}  Run Keyword And Ignore Error  Get From Dictionary  ${gnsse_info['GNSSE_R-1']}  ${parameter}
    ${if_empty}  Run Keyword And Return Status  Should Match Regexp  ${value}  Dictionary does not contain key.*
    ${current_value}  Set Variable If  ${if_empty}==${True}  None  ${value}
    Should Be Equal  ${current_value}  ${expected_value}
    Log To Console  State of ${selected_gnsse} is correct

SM.14_GNSSE_Reset.Test Case Teardown
    Run Keyword  common.Common Test Teardown - MEMORY
