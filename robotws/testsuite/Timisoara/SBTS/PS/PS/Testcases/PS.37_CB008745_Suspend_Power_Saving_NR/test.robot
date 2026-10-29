*** Settings ***
Resource    ../../../resources/common.robot
Resource    ../../../resources/alarms.robot
Resource    ../../../resources/ald.robot
Resource    ../../../resources/power_saving.robot
Resource    ../../../resources/L3_call.robot

Documentation
...  TEST NAME:     PS.37_CB008745_Suspend_Power_Saving_NR
...  AUTHORS:       roscislaw.szuminski@nokia.com
...  MAINTAINER:    RAN_PZ_WRO_3_SG01
...  *****************
...  Basic information
...  *****************
...  Purpose of this test case is to suspend  5G cells under power saving, and check If cells which energy saving state
...  is energySaving start to switch on.
...  *****************
...  Pre-conditions
...  This test is dedicated for TL: 53103
...  *****************
...  N/A
...  ******************
...  History of changes
...  ******************
...  31.08.2023 - https://jiradc.ext.net.nokia.com/browse/TAW-416 - Test case creation
...  *******************
...  RAN PZ3 WRO1 TEMPLATE


*** Keywords ***
PS.37_CB008745_Suspend_Power_Saving_NR

    PS.37_CB008745_Suspend_Power_Saving_NR.Test_Step:0 Test Preparation
    PS.37_CB008745_Suspend_Power_Saving_NR.Test_Step:1 Disable Feature Before Test
    PS.37_CB008745_Suspend_Power_Saving_NR.Test_Step:2 Create NRPGRP and pre-configure for PSG control logic improvement
    PS.37_CB008745_Suspend_Power_Saving_NR.Test_Step:3 Activate PSG Control Logic Improvement for 5G
    PS.37_CB008745_Suspend_Power_Saving_NR.Test_Step:4 Check if selected cells reach applicable states
    PS.37_CB008745_Suspend_Power_Saving_NR.Test_Step:5 Final Recovery and Checkpoint

PS.37_CB008745_Suspend_Power_Saving_NR.Test_Step:0 Test Preparation
    Log to console  \n========================================
    Log  Step: 0 Test Preparation  console=${True}
    Log to console  ========================================
    ${COUNTER_BEFORE_TEST}=  Get Reset Counter From Blackbox  COLLECT_BLACKBOX_FILE=${True}
    Set Test Variable  ${COUNTER_BEFORE_TEST}
    Set Test Variable  ${ue}  NOKIA83
    Set Test Variable  ${RESULTS}
    @{feature_flags}=  Create List  actLbpsCtrlLogicEnh  actNrLBPowerSaving
    Set Test Variable  ${feature_flags}
    Select Two Random NR Cells
    Set Test Variable  ${1st_NRCELL_ID}  ${1st_NRCELL_ID}
    Set Test Variable  ${1st_NRCELL_DN}  ${1st_NRCELL_DN}
    Set Test Variable  ${2nd_NRCELL_ID}  ${2nd_NRCELL_ID}
    Set Test Variable  ${2nd_NRCELL_DN}  ${2nd_NRCELL_DN}
    ${selected_cells_IDs}=  Create List  ${1st_NRCELL_ID}  ${2nd_NRCELL_ID}
    Set Test Variable  ${selected_cells_IDs}
    Log To Console  Energy Saving for NRCEL_R-${1st_NRCELL_ID} and NRCEL_R-${2nd_NRCELL_ID}
    Check Power Saving NR  ${1st_NRCELL_ID}  ENABLED  NOTENERGYSAVING
    Check Power Saving NR  ${2nd_NRCELL_ID}  ENABLED  NOTENERGYSAVING
    ${selected_cells_DNs}=  Create List  ${1st_NRCELL_DN}  ${2nd_NRCELL_DN}
    Set Test Variable  ${selected_cells_DNs}
    Check If Not Energy Saving Cells Are Enabled  ENABLED  NOTENERGYSAVING  ${selected_cells_DNs}

PS.37_CB008745_Suspend_Power_Saving_NR.Test_Step:1 Disable Feature Before Test
    Log to console  \n========================================
    Log  Step: 1 Disable Feature Before Test  console=${True}
    Log to console  ========================================
    ${pre_action_reset_number}=  Get Reset Counter From Blackbox
    Set Feature Under Given Object  ${NRBTS_DistName}  ${feature_flags}  false
    Remove PSGRP/NRPGRP Objects If Exist  NRPGRP
    Check If Unexpected Alarms Are Raised  ${skip_fault}
    ${post_action_reset_number}=  Get Reset Counter From Blackbox

PS.37_CB008745_Suspend_Power_Saving_NR.Test_Step:2 Create NRPGRP and pre-configure for PSG control logic improvement
    Log to console  \n========================================
    Log  Step: 2 Activate Load-Based Extended Power Saving  console=${True}
    Log to console  ========================================
    ${pre_action_reset_number}=  Get Reset Counter From Blackbox
    ${if_actNrExtCellSOMethod}  ${value_actNrExtCellSOMethod}=  Run Keyword And Ignore Error  Get Parameter Value Under NRBTS  actNrExtCellSOMethod
    Set Test Variable  ${if_actNrExtCellSOMethod}
    Set Feature Under Given Object  ${NRBTS_DistName}  shutdownWindow  36
    Create And Activate NRPGRP For CB008745  1  10min  true
    ${post_action_reset_number}=  Get Reset Counter From Blackbox

PS.37_CB008745_Suspend_Power_Saving_NR.Test_Step:3 Activate PSG Control Logic Improvement for 5G
    Log to console  \n========================================
    Log  Step: 3 Configure Load-Based Extended Power Saving  console=${True}
    Log to console  ========================================
    ${pre_action_reset_number}=  Get Reset Counter From Blackbox
    Set Feature Under Given Object  ${NRBTS_DistName}  ${feature_flags}  true
    Check If Unexpected Alarms Are Raised  ${skip_fault}

PS.37_CB008745_Suspend_Power_Saving_NR.Test_Step:4 Check if selected cells reach applicable states
    Log to console  \n========================================
    Log  Step: 4 Check if selected cells reach applicable states  console=${True}
    Log to console  ========================================
    Log To Console  \nWaiting for ENERGYSAVING on NRCEL_R-${1st_NRCELL_ID}
    Wait Until Keyword Succeeds  5min  15sec  Check Power Saving NR  ${1st_NRCELL_ID}  ENABLED  SWITCHINGOFF
    Log To Console  NRCEL_R-${1st_NRCELL_ID} START TO SWITCHINGOFF
    Wait Until Keyword Succeeds  50sec  10sec  Check Power Saving NR  ${1st_NRCELL_ID}  DISABLED  ENERGYSAVING
    Log To Console  NRCEL_R-${1st_NRCELL_ID} ENTER ENERGYSAVING
    Check if not Energy Saving cells are enabled  ENABLED  NOTENERGYSAVING  ${selected_cells_DNs}
    Check If Unexpected Alarms Are Raised  ${skip_fault}
    Log To Console  \nWaiting for ENERGYSAVING on NRCEL_R-${2nd_NRCELL_ID}
    Wait Until Keyword Succeeds  3min  15sec  Check Power Saving NR  ${2nd_NRCELL_ID}  ENABLED  SWITCHINGOFF
    Log To Console  NRCEL_R-${1st_NRCELL_ID} START TO SWITCHINGOFF
    Wait Until Keyword Succeeds  50sec  10sec  Check Power Saving NR  ${2nd_NRCELL_ID}  DISABLED  ENERGYSAVING
    Log To Console  NRCEL_R-${2nd_NRCELL_ID} ENTER ENERGYSAVING
    Check if not Energy Saving cells are enabled  ENABLED  NOTENERGYSAVING  ${selected_cells_DNs}
    Check If Unexpected Alarms Are Raised  ${skip_fault}
    Suspend/notSuspend PowerSaving NR
    Log To Console  \nPower Saving has been suspended in 1st time period
    Log To Console  \nPower Saving Cells should be ENABLED NOTENERGYSAVING
    Wait Until Keyword Succeeds  30sec  15sec  Check Power Saving NR  ${1st_NRCELL_ID}  ENABLED  NOTENERGYSAVING
    Log To Console  \n Cell ${1st_NRCELL_ID} NOTENERGYSAVING
    Wait Until Keyword Succeeds  30sec  15sec  Check Power Saving NR  ${2nd_NRCELL_ID}  ENABLED  NOTENERGYSAVING
    Log To Console  \n Cell ${2nd_NRCELL_ID} NOTENERGYSAVING

PS.37_CB008745_Suspend_Power_Saving_NR.Test_Step:5 Final Recovery and Checkpoint
    Log to console  \n========================================
    Log  Step: 5 Final Recovery and Checkpoint  console=${True}
    Log to console  ========================================
    ${pre_action_reset_number}=  Get Reset Counter From Blackbox
    Set Feature Under Given Object  ${NRBTS_DistName}  ${feature_flags}  false
    Remove PSGRP/NRPGRP Objects If Exist  NRPGRP
    Set Feature Under Given Object  ${NRBTS_DistName}  shutdownWindow  180
    Check If Unexpected Alarms Are Raised  ${skip_fault}
    ${COUNTER_AFTER_TEST}=  Get Reset Counter From Blackbox  COLLECT_BLACKBOX_FILE=${True}

PS.37_CB008745_Suspend_Power_Saving_NR.Test Specific Teardown
    [Documentation]  Test Specific Teardown.
    admin.setup admin  admin_api_log_dir=${RESULTS}/admin_api/  alias=${ute_admin_alias}
    Run Keyword And Ignore Error  Set Feature Under Given Object  ${NRBTS_DistName}  ${feature_flags}  false
    Run Keyword And Ignore Error  Remove PSGRP/NRPGRP Objects If Exist  NRPGRP
    Run Keyword And Ignore Error  Set Feature Under Given Object  ${NRBTS_DistName}  shutdownWindow  180
    admin.teardown admin  alias=${ute_admin_alias}

PS.37_CB008745_Suspend_Power_Saving_NR.Test Case Teardown
    Run Keywords  common.Common Test Teardown
    Run Keyword If Test Failed  PS.37_CB008745_Suspend_Power_Saving_NR.Test Specific Teardown


