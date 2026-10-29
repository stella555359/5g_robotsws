*** Settings ***
Resource    ../../../resources/common.robot
Resource    ../../../resources/alarms.robot
Resource    ../../../resources/ald.robot
Resource    ../../../resources/power_saving.robot
Resource    ../../../resources/L3_call.robot

Documentation
...  TEST NAME:     PS.31_5GC000431_Cell_Switch_Off_Suspend_Un-suspend_Load-Based_Power_Saving
...  AUTHORS:       mateusz.gumieniak@nokia.com
...  MAINTAINER:    RAN_PZ_WRO_3_SG01
...  *****************
...  Basic information
...  *****************
...  Puropse of this test is to check the possibility to quickly bring back resources that are switching off or power saving.
...  Using actNrLBPowerSaving feature with suspending/unsuspending powers saving time periods.
...  *****************
...  Pre-conditions
...  *****************
...  N/A
...  ******************
...  History of changes
...  ******************
...  05.02.2023 - https://jiradc.ext.net.nokia.com/browse/TAW-212 - Test case creation
...  26.04.2023 - https://jiradc.ext.net.nokia.com/browse/TAW-350 - Test case adaption for CB010683 - mandatory parameter lbpsUseExtConfig added
...  15.06.2023 - https://jiradc.ext.net.nokia.com/browse/TAW-377 - Time frames fix
...  *******************
...  RAN PZ3 WRO1 TEMPLATE


*** Keywords ***
PS.31_5GC000431_Cell_Switch_Off_Suspend_Un-suspend_Load-Based_Power_Saving

    PS.31_5GC000431_Cell_Switch_Off_Suspend_Un-suspend_Load-Based_Power_Saving.Test_Step:0 Test Preparation
    PS.31_5GC000431_Cell_Switch_Off_Suspend_Un-suspend_Load-Based_Power_Saving.Test_Step:1 Disable Feature Before Test
    PS.31_5GC000431_Cell_Switch_Off_Suspend_Un-suspend_Load-Based_Power_Saving.Test_Step:2 Configure Load Based Power Saving
    PS.31_5GC000431_Cell_Switch_Off_Suspend_Un-suspend_Load-Based_Power_Saving.Test_Step:3 Activate Load Based Power Saving
    PS.31_5GC000431_Cell_Switch_Off_Suspend_Un-suspend_Load-Based_Power_Saving.Test_Step:4 Load Based Power Saving 2nd Time Period
    PS.31_5GC000431_Cell_Switch_Off_Suspend_Un-suspend_Load-Based_Power_Saving.Test_Step:5 Load Based Power Saving 3rd Time Period
    PS.31_5GC000431_Cell_Switch_Off_Suspend_Un-suspend_Load-Based_Power_Saving.Test_Step:6 Final Recovery

PS.31_5GC000431_Cell_Switch_Off_Suspend_Un-suspend_Load-Based_Power_Saving.Test_Step:0 Test Preparation
    Log to console  \n========================================
    Log  Step: 0 Test Preparation  console=${True}
    Log to console  ========================================
    ${COUNTER_BEFORE_TEST}=  Get Reset Counter From Blackbox  COLLECT_BLACKBOX_FILE=${True}
    Set Test Variable  ${COUNTER_BEFORE_TEST}
    Select All NR Cells
    @{cell_order}  Create List
    FOR    ${i}    IN RANGE    1    ${nr_cells_length}+1
      Append To List    ${cell_order}    ${i}
    END
    Set List Value  ${cell_order}    -1    ${100}
    Set Test Variable    ${cell_order}
    ${1}    Set Variable    1
    FOR  ${i}  IN RANGE  ${nr_cells_length}
      Log   Energy Saving for NRCEL-${selected_cells}[${i}]   WARN
      Check Power Saving   ${selected_cells}[${i}]    ENABLED    NOTENERGYSAVING
    END
    Check if not Energy Saving cells are enabled    ENABLED    NOTENERGYSAVING    ${selected_cells_paths}

PS.31_5GC000431_Cell_Switch_Off_Suspend_Un-suspend_Load-Based_Power_Saving.Test_Step:1 Disable Feature Before Test
    Log to console  \n========================================
    Log  Step: 1 Disable Feature Before Test  console=${True}
    Log to console  ========================================
    ${pre_action_reset_number}=  Get Reset Counter From Blackbox
    Set Feature Under Given Object  ${NRBTS_DistName}  actNrLBPowerSaving  false
    Remove PSGRP/NRPGRP Objects If Exist  NRPGRP
    Remove PSGRP/NRPGRP Objects If Exist  PSGRP
    Check If Unexpected Alarms Are Raised  ${skip_fault}
    ${post_action_reset_number}=  Get Reset Counter From Blackbox

PS.31_5GC000431_Cell_Switch_Off_Suspend_Un-suspend_Load-Based_Power_Saving.Test_Step:2 Configure Load Based Power Saving
    Log to console    \n========================================
    Log  Step: 2 Configure Load Based Power Saving  console=${True}
    Log to console    ========================================
    ${pre_action_reset_number}=  Get Reset Counter From Blackbox
    ${if_actNrExtCellSOMethod}  ${value_actNrExtCellSOMethod}=  Run Keyword And Ignore Error  Get Parameter Value Under NRBTS  actNrExtCellSOMethod
    Set Test Variable  ${if_actNrExtCellSOMethod}
    Create And Activate NRPGRP for 5GC000431
    ${start_date}  Get Current Date
    ${1st_ES_period_date}  Add Time To Date    ${start_date}    2 minutes
    ${2nd_ES_period_date}  Add Time To Date    ${start_date}    24 minutes
    ${3rd_ES_period_date}  Add Time To Date    ${start_date}    45 minutes
    Set Test Variable    ${1st_ES_period_date}
    Set Test Variable    ${2nd_ES_period_date}
    Set Test Variable    ${3rd_ES_period_date}
    Check If Unexpected Alarms Are Raised  ${skip_fault}
    ${post_action_reset_number}=  Get Reset Counter From Blackbox

PS.31_5GC000431_Cell_Switch_Off_Suspend_Un-suspend_Load-Based_Power_Saving.Test_Step:3 Activate Load Based Power Saving
    Log to console    \n========================================
    Log  Step: 3 Activate Load Based Power Saving  console=${True}
    Log to console    ========================================
    ${pre_action_reset_number}=  Get Reset Counter From Blackbox
    Set Feature Under Given Object  ${NRBTS_DistName}  actNrLBPowerSaving  true
    Log To Console  \nWaiting for first energy saving time period
    Wait for date  ${1st_ES_period_date}
    FOR  ${i}  IN RANGE  ${nr_cells_length}-1
      Log to console    \nWaiting for ENERGYSAVING for NRCEL-${selected_cells}[${i}]
      Wait Until keyword Succeeds    13min    30sec    Check Power Saving NR   ${selected_cells}[${i}]   DISABLED      ENERGYSAVING
      Check if not Energy Saving cells are enabled    ENABLED    NOTENERGYSAVING     ${selected_cells_paths}
    END
    Suspend/notSuspend PowerSaving NR
    Log To Console  \nPower Saving has been suspended in 1st time period
    Log To Console  \nPower Saving Cells should be ENABLED NOTENERGYSAVING
    FOR  ${i}  IN RANGE  ${nr_cells_length}-1
      Log to console    \nWaiting for NOTENERGYSAVING for NRCEL-${selected_cells}[${i}]
      Wait Until keyword Succeeds    1min    30sec    Check Power Saving NR   ${selected_cells}[${i}]   ENABLED    NOTENERGYSAVING
    END
    Log To Console  \nPower Saving Cells are ENABLED NOTENERGYSAVING
    ${post_action_reset_number}=  Get Reset Counter From Blackbox

PS.31_5GC000431_Cell_Switch_Off_Suspend_Un-suspend_Load-Based_Power_Saving.Test_Step:4 Load Based Power Saving 2nd Time Period
    Log to console    \n========================================
    Log  Step: 4 Load Based Power Saving 2nd Time Period console=${True}
    Log to console    ========================================
    ${pre_action_reset_number}=  Get Reset Counter From Blackbox
    Log To Console  \nWaiting for second energy saving time period
    Wait for date  ${2nd_ES_period_date}
    FOR  ${i}  IN RANGE  ${nr_cells_length}-1
      Log to console    \nWaiting for ENERGYSAVING for NRCEL-${selected_cells}[${i}]
      Wait Until keyword Succeeds    13min    30sec    Check Power Saving NR   ${selected_cells}[${i}]   DISABLED      ENERGYSAVING
      Check if not Energy Saving cells are enabled    ENABLED    NOTENERGYSAVING     ${selected_cells_paths}
    END
    ${post_action_reset_number}=  Get Reset Counter From Blackbox

PS.31_5GC000431_Cell_Switch_Off_Suspend_Un-suspend_Load-Based_Power_Saving.Test_Step:5 Load Based Power Saving 3rd Time Period
    Log to console    \n========================================
    Log  Step: 5 Load Based Power Saving 3nd Time Period console=${True}
    Log to console    ========================================
    ${pre_action_reset_number}=  Get Reset Counter From Blackbox
    Log To Console  \nWaiting for third energy saving time period
    Wait for date  ${3rd_ES_period_date}
    FOR  ${i}  IN RANGE  ${nr_cells_length}-1
      Log to console    \nWaiting for NOTENERGYSAVING for NRCEL-${selected_cells}[${i}]
      Wait Until keyword Succeeds    3min    30sec    Check Power Saving NR   ${selected_cells}[${i}]   ENABLED    NOTENERGYSAVING
    END
    ${status}  Run Keyword And Return Status  L3 Call
    IF  not ${status}  Teardown if call failed
    ${post_action_reset_number}=  Get Reset Counter From Blackbox

PS.31_5GC000431_Cell_Switch_Off_Suspend_Un-suspend_Load-Based_Power_Saving.Test_Step:6 Final Recovery
    Log to console    \n========================================
    Log  Step: 6 Final Recovery  console=${True}
    Log to console    ========================================
    ${pre_action_reset_number}=  Get Reset Counter From Blackbox
    Set Feature Under Given Object  ${NRBTS_DistName}  actNrLBPowerSaving  false
    Remove PSGRP/NRPGRP Objects If Exist  NRPGRP
    ${COUNTER_AFTER_TEST}=  Get Reset Counter From Blackbox  COLLECT_BLACKBOX_FILE=${True}

PS.31_5GC000431_Cell_Switch_Off_Suspend_Un-suspend_Load-Based_Power_Saving.Test Case Teardown
    Log to console    \n========================================
    Log  Step: Test Case Teardown  console=${True}
    Log to console    ========================================
    Run Keyword If Test Failed    Set Feature Under Given Object  ${NRBTS_DistName}  actNrLBPowerSaving  false
    Run Keyword If Test Failed    Remove PSGRP/NRPGRP Objects If Exist  NRPGRP
    Run Keywords    common.Common Test Teardown
