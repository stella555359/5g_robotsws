*** Settings ***
Resource    ../../../resources_mem/common.robot
Resource    ../../../resources_mem/alarms.robot
Resource    ../../../resources_mem/power_saving.robot
Resource    ../../../resources_mem/oam_kpi.robot

Documentation
...  TEST NAME:     SM.01_Site_Reset
...  AUTHORS:       artur.lebek@nokia.com, tomasz.marchewka@nokia.com
...  MAINTAINER:    RAN_PZ_WRO_3_SG01
...  *****************
...  Basic information
...  *****************
...  The purpose of this test case is to perform Site Reset operation, check eNB status after operation is finished
...  and measure KPI for operation time.
...  *****************
...  Pre-conditions
...  *****************
...  N/A
...  ******************
...  History of changes
...  ******************
...  06.10.2021 - https://jiradc.ext.net.nokia.com/browse/TAW-xxx - Legacy test - New tempate adaptation
...  10.08.2023 - https://jiradc.ext.net.nokia.com/browse/TAW-421 - robotws migration and small hotfixes
...  10.08.2023 - https://jiradc.ext.net.nokia.com/browse/TAW-564 - Disable ecolab when connection with BTS is lost
...  24.05.2024 - https://jiradc.ext.net.nokia.com/browse/TAW-585 - Moved checking concurrent side cells to "Check If NLWG Cells Are OnAir"
...  11.07.2024 - https://jiradc.ext.net.nokia.com/browse/TAW-578 - Delay request for 'Get actual configuration' of Netact
...  in common.robot to include energySaving states
...  *******************
...  RAN PZ3 WRO1 TEMPLATE


*** Keywords ***
SM.01_Site_Reset

    SM.01_Site_Reset.Test_Step:0 Test Preparation
    SM.01_Site_Reset.Test_Step:1 Perfom Site Reset
    SM.01_Site_Reset.Test_Step:2 Check BTS
    SM.01_Site_Reset.Test_Step:3 KPI Measurement

SM.01_Site_Reset.Test_Step:0 Test Preparation
    Log to console    \n========================================
    Log  Step: 0 Test Preparation  console=${True}
    Log to console    ========================================
    ${COUNTER_BEFORE_TEST}=  Get Reset Counter From Blackbox  COLLECT_BLACKBOX_FILE=${True}  iteration=${ITERATION_INDEX}
    Set Test Variable  ${COUNTER_BEFORE_TEST}
    ${rats}  Detect RATs
    Set Test Variable  ${rats}
    Check If NLWG Cells Are OnAir
    SCF Backup
    Run Keyword If  not ${skip_NA_integration}  Wait Until Keyword Succeeds  60s  10s  Check Cells State In Netact  operationalState  Enabled

SM.01_Site_Reset.Test_Step:1 Perfom Site Reset
    Log to console    \n========================================
    Log  Step: 1 Perfom Site Reset  console=${True}
    Log to console    ========================================
    ${if_nr_exist}  Run Keyword And Return Status  List Should Contain Value  ${rats}  nr
    Run Keyword If  ${if_nr_exist}  Run Keywords  Allow Fault In Watchdog  faultID=6327  #fault_name: Setup of X2 connectivity to gNB failed
                                    ...    AND    Allow Fault In Watchdog  faultID=7300  #fault_name: No X2 link available
                                    ...    AND    Allow Fault In Watchdog  faultID=7319  #fault_name: No X2 link available for a specific LTEENB
    Run Keyword If  ${CONCURRENT}   Run Keywords  Allow Fault In Watchdog  faultID=1798  #fault_name: PPS reference missing
                                    ...    AND    Allow Fault In Watchdog  faultID=4530  #fault_name: TD-LTE radio disabled
                                    ...    AND    Allow Fault In Watchdog  faultID=6327  #fault_name: Setup of X2 connectivity to gNB failed
    Set Test Variable  ${if_nr_exist}
    Log To Console  BTS Reset site...
    ${resetText}=  Run Keyword And Return Status  admin.reset site  timeout=700
    Run Keyword If  ${CONCURRENT}  Run Keywords  Log To Console  BTS Reset site - concurrent...
    ...  AND  admin.reset site  timeout=700  alias=concurrent
    Run Keyword If    '${resetText}'=='False'    Run Keywords    Log To Console    BTS not reachable after Site Reset
                                                ...    AND    Log To Console    Disabling EcoLab
                                                ...    AND    Run  sudo touch /etc/ute/disable_ecolab

SM.01_Site_Reset.Test_Step:2 Check BTS
    Log to console    \n========================================
    Log  Step: 2 Check BTS  console=${True}
    Log to console    ========================================
    Check SMODs State  ${SMOD_expected_states}
    Check RMODs State  ${RMOD_expected_states}
    Check If ALDs Are Connected And Achieved Expected State
    common.Check BTS State  ${BTS_expected_states}
    Check If NLWG Cells Are OnAir
    Sleep    3s
    Run Keyword If  'nr' in $rats  Wait Until Keyword Succeeds  10min  1min  Check X2 Link
    Run Keyword If  not ${skip_NA_integration}  Wait Until Keyword Succeeds  60s  10s  Check Cells State In Netact  operationalState  Enabled
    Run Keyword If  ${if_nr_exist}  Run Keywords  Disallow Fault In Watchdog  faultID=6327  #fault_name: Setup of X2 connectivity to gNB failed
                                    ...    AND    Disallow Fault In Watchdog  faultID=7300  #fault_name: No X2 link available
                                    ...    AND    Disallow Fault In Watchdog  faultID=7319  #fault_name: No X2 link available for a specific LTEENB
    Run Keyword If  ${CONCURRENT}   Run Keywords  Disallow Fault In Watchdog  faultID=1798  #fault_name: PPS reference missing
                                    ...    AND    Disallow Fault In Watchdog  faultID=4530  #fault_name: TD-LTE radio disabled
                                    ...    AND    Wait For Inactive Fault  faultID=6327  timeout=480 sec
                                    ...    AND    Disallow Fault In Watchdog  faultID=6327  #fault_name: Setup of X2 connectivity to gNB failed
    ${COUNTER_AFTER_TEST}=  Get Reset Counter From Blackbox  COLLECT_BLACKBOX_FILE=${True}  iteration=${ITERATION_INDEX}
    ${counter_diff}  Evaluate  abs(${COUNTER_AFTER_TEST} - ${COUNTER_BEFORE_TEST})
    Run Keyword If  ${0}<${counter_diff}<${2}  Log To Console  Reset Counter Incremented +${counter_diff}
    ...  ELSE  Log  Reset Counter Incremented +${counter_diff}  WARN

SM.01_Site_Reset.Test_Step:3 KPI Measurement
    Log to console    \n========================================
    Log  Step: 3 KPI Measurement  console=${True}
    Log to console    ========================================
    Run Keyword And Ignore Error  Calculate KPI1a KPI1b KPI1c  ${ITERATION_INDEX}

SM.01_Site_Reset.Test Case Teardown
    Run Keyword  common.Common Test Teardown - MEMORY
