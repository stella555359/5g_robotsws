*** Settings ***
Resource    ../../../resources/common.robot
Resource    ../../../resources/alarms.robot
Resource    ../../../resources/ald.robot
Resource    ../../../resources/power_saving.robot
Resource    ../../../resources/L3_call.robot

Documentation
...  TEST NAME:     PS.10_CB007416_Load_based_carrier_switch_off_on_TDD
...  AUTHORS:       tomasz.marchewka@nokia.com
...  MAINTAINER:    RAN_PZ_WRO_3_SG01
...  *****************
...  Basic information
...  *****************
...  Verification the functionality of carrier switch off/on for power saving on TDD 4/8/64TRx deployments
...  (both CPRI and eCPRI).
...  This feature reuses LTE1103 mechanism to achieve load based carrier switch off for new deployments and new
...  platforms. This feature will cover CPRI and eCPRI based TDD mMIMO scenarios, then operators can exploit this
...  feature to reduce power consumption significantly. And this feature also will support CPRI based standard MIMO
...  and eCPRI based 4/8/64 pipe beamforming on ABIO/N. LTE1103 (Load based Power Saving for multi-layer networks)
...  has introduced load trigger carrier power shutdown based on Power Saving Group. CB007416 will explicit support
...  load based carrier switch off/on to provide power saving function for different platforms(ABIA, ABIC, ABIO/N),
...  different scenarios and different fronthaul interfaces (CPRI, eCPRI).
...  *****************
...  Pre-conditions
...  *****************
...  N/A
...  ******************
...  History of changes
...  ******************
...  - 24.01.2022 - https://jiradc.ext.net.nokia.com/browse/TAW-51 - TC refactoring
...  - 13.07.2022 - https://jiradc.ext.net.nokia.com/browse/TAW-210 - Modification of PSGRP parametr due to CB008800
...  24.10.2023 - https://jiradc.ext.net.nokia.com/browse/TAW-471 - Added Teardown if call failed
...  *******************
...  RAN PZ3 WRO1 TEMPLATE


*** Keywords ***
PS.10_CB007416_Load_based_carrier_switch_off_on_for_PS_on_TDD

    PS.10_CB007416_Load_based_carrier_switch_off_on_for_PS_on_TDD.Test_Step:0 Test Preparation
    PS.10_CB007416_Load_based_carrier_switch_off_on_for_PS_on_TDD.Test_Step:1 Disable Feature Before Test
    PS.10_CB007416_Load_based_carrier_switch_off_on_for_PS_on_TDD.Test_Step:2 Configure Load Based Power Saving
    PS.10_CB007416_Load_based_carrier_switch_off_on_for_PS_on_TDD.Test_Step:3 Activate Load Based Power Saving
    PS.10_CB007416_Load_based_carrier_switch_off_on_for_PS_on_TDD.Test_Step:4 Final Recovery and Checkpoint

PS.10_CB007416_Load_based_carrier_switch_off_on_for_PS_on_TDD.Test_Step:0 Test Preparation
    Log to console    \n========================================
    Log  Step: 0 Test Preparation  console=${True}
    Log to console    ========================================
    ${COUNTER_BEFORE_TEST}=  Get Reset Counter From Blackbox  COLLECT_BLACKBOX_FILE=${True}
#    Set Test Variable  ${COUNTER_BEFORE_TEST}
    @{feature_flags}=  Create List  actLBPowerSaving  actLBRTXPowerSaving
    Set Test Variable  ${feature_flags}
    ${tdd_lncels}=  Get Specified Duplex LNCEL List  duplex=TDD
    Set Test Variable  ${tdd_lncels}
    ${LNCEL_QTY}=  Get Length  ${tdd_lncels}
    IF  ${LNCEL_QTY}<${4}  Fail  msg=At least 4 TDD LNCELs are needed
    Select Four Random TDD LTE Cells
    Log  Selected 1st LNCEL DN: ${1st_LNCEL_DN}  console=${True}
    Log  Selected 2nd LNCEL DN: ${2nd_LNCEL_DN}  console=${True}
    Log  Selected 3rd LNCEL DN: ${3rd_LNCEL_DN}  console=${True}
    Log  Selected 4th LNCEL DN: ${4th_LNCEL_DN}  console=${True}
    ${selected_cells_DNs}=  Create List  ${1st_LNCEL_DN}  ${2nd_LNCEL_DN}  ${3rd_LNCEL_DN}  ${4th_LNCEL_DN}
    Set Test Variable  ${selected_cells_DNs}

PS.10_CB007416_Load_based_carrier_switch_off_on_for_PS_on_TDD.Test_Step:1 Disable Feature Before Test
    Log to console    \n========================================
    Log  Step: 1 Disable Feature Before Test  console=${True}
    Log to console    ========================================
    ${pre_action_reset_number}=  Get Reset Counter From Blackbox
    Set Feature Under Given Object  ${LNBTS_DistName}  ${feature_flags}  false
    Remove PSGRP/NRPGRP Objects If Exist  PSGRP
    Check If Unexpected Alarms Are Raised  ${skip_fault}
    ${post_action_reset_number}=  Get Reset Counter From Blackbox
#    ${counter_diff}  Evaluate  abs(${pre_action_reset_number} - ${post_action_reset_number})
#    IF  ${counter_diff}!=${0}  Fail  msg=Detected unexpected BTS reset

PS.10_CB007416_Load_based_carrier_switch_off_on_for_PS_on_TDD.Test_Step:2 Configure Load Based Power Saving
    Log to console    \n========================================
    Log  Step: 2 Configure Load Based Power Saving  console=${True}
    Log to console    ========================================
    ${pre_action_reset_number}=  Get Reset Counter From Blackbox
    ${if_actExtCellSOMethod}  ${value_actExtCellSOMethod}=  Run Keyword And Ignore Error  Get Parameter Value Under LNBTS  actExtCellSOMethod
    Set Test Variable  ${if_actExtCellSOMethod}
    ${if_actCo4g5g}  ${value_actCo4g5g}=  Run Keyword And Ignore Error  Get Parameter Value Under LNBTS  actCoordinated4g5gPowerSaving
    Set Test Variable  ${if_actCo4g5g}
    Create And Activate PSGRP For CB007416  ${1st_LNCEL_DN}  ${2nd_LNCEL_DN}  PSGRP-1  25min
    Create And Activate PSGRP For CB007416  ${3rd_LNCEL_DN}  ${4th_LNCEL_DN}  PSGRP-2  1440min
    Check If Unexpected Alarms Are Raised  ${skip_fault}
    ${post_action_reset_number}=  Get Reset Counter From Blackbox
#    ${counter_diff}  Evaluate  abs(${pre_action_reset_number} - ${post_action_reset_number})
#    IF  ${counter_diff}!=${0}  Fail  msg=Detected unexpected BTS reset

PS.10_CB007416_Load_based_carrier_switch_off_on_for_PS_on_TDD.Test_Step:3 Activate Load Based Power Saving
    Log to console    \n========================================
    Log  Step: 3 Activate Load Based Power Saving  console=${True}
    Log to console    ========================================
    ${pre_action_reset_number}=  Get Reset Counter From Blackbox
    Set Feature Under Given Object  ${LNBTS_DistName}  actLBPowerSaving  true
    Log To Console  Waiting for ENERGYSAVING on LNCEL_R-${1st_LNCEL_ID}
    Wait Until Keyword Succeeds  20min  30sec  Check Power Saving  ${1st_LNCEL_ID}  DISABLED  ENERGYSAVING
    Log To Console  Waiting for ENERGYSAVING on LNCEL_R-${2nd_LNCEL_ID}
    Wait Until Keyword Succeeds  20min  30sec  Check Power Saving  ${2nd_LNCEL_ID}  DISABLED  ENERGYSAVING
    Log To Console  Waiting for ENERGYSAVING on LNCEL_R-${3rd_LNCEL_ID}
    Wait Until Keyword Succeeds  20min  30sec  Check Power Saving  ${3rd_LNCEL_ID}  DISABLED  ENERGYSAVING
    Log To Console  Waiting for ENERGYSAVING on LNCEL_R-${4th_LNCEL_ID}
    Wait Until Keyword Succeeds  20min  30sec  Check Power Saving  ${4th_LNCEL_ID}  DISABLED  ENERGYSAVING
    Check If Not Energy Saving Cells Are Enabled  ENABLED  NOTENERGYSAVING  ${selected_cells_DNs}
    Log To Console  Waiting for NOTENERGYSAVING on LNCEL_R-${1st_LNCEL_ID}
    Wait Until keyword Succeeds  20min  30sec  Check Power Saving  ${1st_LNCEL_ID}  ENABLED  NOTENERGYSAVING
    Log To Console  Waiting for NOTENERGYSAVING on LNCEL_R-${2nd_LNCEL_ID}
    Wait Until keyword Succeeds  20min  30sec  Check Power Saving  ${2nd_LNCEL_ID}  ENABLED  NOTENERGYSAVING
    Set Feature Under Given Object  ${LNBTS_DistName}  actLBPowerSaving  false
    Log To Console  Waiting for NOTENERGYSAVING on LNCEL_R-${3rd_LNCEL_ID}
    Wait Until Keyword Succeeds  20min  30sec  Check Power Saving  ${3rd_LNCEL_ID}  ENABLED  NOTENERGYSAVING
    Log To Console  Waiting for NOTENERGYSAVING on LNCEL_R-${4th_LNCEL_ID}
    Wait Until Keyword Succeeds  20min  30sec  Check Power Saving  ${4th_LNCEL_ID}  ENABLED  NOTENERGYSAVING
    Check If Unexpected Alarms Are Raised  ${skip_fault}
    ${post_action_reset_number}=  Get Reset Counter From Blackbox
#    ${counter_diff}  Evaluate  abs(${pre_action_reset_number} - ${post_action_reset_number})
#    IF  ${counter_diff}!=${0}  Fail  msg=Detected unexpected BTS reset
#    ${status}  Run Keyword And Return Status  L3 Call
#    IF  not ${status}  Teardown if call failed

PS.10_CB007416_Load_based_carrier_switch_off_on_for_PS_on_TDD.Test_Step:4 Final Recovery and Checkpoint
    Log to console    \n========================================
    Log  Step: 4 Final Recovery and Checkpoint  console=${True}
    Log to console    ========================================
    Remove PSGRP/NRPGRP Objects If Exist  PSGRP
    ${COUNTER_AFTER_TEST}=  Get Reset Counter From Blackbox  COLLECT_BLACKBOX_FILE=${True}
#    ${counter_diff}  Evaluate  abs(${COUNTER_AFTER_TEST} - ${COUNTER_BEFORE_TEST})
#    IF  ${counter_diff}!=${0}  Fail  msg=Detected unexpected BTS reset

PS.10_CB007416_Load_based_carrier_switch_off_on_for_PS_on_TDD.Test Specific Teardown
    [Documentation]  Test Specific Teardown.
    admin.setup admin  admin_api_log_dir=${RESULTS}/admin_api/  alias=${ute_admin_alias}
    Run Keyword And Ignore Error  Remove PSGRP/NRPGRP Objects If Exist  PSGRP
    Run Keyword And Ignore Error  Set Feature Under Given Object  ${LNBTS_DistName}  actLBPowerSaving  false
    admin.teardown admin  alias=${ute_admin_alias}

PS.10_CB007416_Load_based_carrier_switch_off_on_for_PS_on_TDD.Test Case Teardown
    Run Keywords  common.Common Test Teardown
    Run Keyword If Test Failed  PS.10_CB007416_Load_based_carrier_switch_off_on_for_PS_on_TDD.Test Specific Teardown

Select Four Random TDD LTE Cells
    @{cell}  Evaluate  random.sample(${tdd_lncels}, 4)  random
    ${1st_LNCEL_ID}=  Evaluate  re.search(r'LNCEL_R-(\\d+)','''${cell}[0]''').group(1)  re
    ${2nd_LNCEL_ID}=  Evaluate  re.search(r'LNCEL_R-(\\d+)','''${cell}[1]''').group(1)  re
    ${3rd_LNCEL_ID}=  Evaluate  re.search(r'LNCEL_R-(\\d+)','''${cell}[2]''').group(1)  re
    ${4th_LNCEL_ID}=  Evaluate  re.search(r'LNCEL_R-(\\d+)','''${cell}[3]''').group(1)  re
    Set Test Variable  ${1st_LNCEL_ID}
    Set Test Variable  ${2nd_LNCEL_ID}
    Set Test Variable  ${3rd_LNCEL_ID}
    Set Test Variable  ${4th_LNCEL_ID}
    Set Test Variable  ${1st_LNCEL_DN}  ${cell}[0]
    Set Test Variable  ${2nd_LNCEL_DN}  ${cell}[1]
    Set Test Variable  ${3rd_LNCEL_DN}  ${cell}[2]
    Set Test Variable  ${4th_LNCEL_DN}  ${cell}[3]
