*** Settings ***
Resource    ../../../resources/common.robot
Resource    ../../../resources/alarms.robot
Resource    ../../../resources/ald.robot
Resource    ../../../resources/power_saving.robot
Resource    ../../../resources/L3_call.robot

Documentation
...  TEST NAME:     PS.25_CB008800_Power_saving_configuration_change
...  AUTHORS:       roscislaw.szuminski@nokia.com
...  MAINTAINER:    RAN_PZ_WRO_3_SG01
...  *****************
...  Basic information
...  *****************
...  Purpose of this test case to check if cells under energySaving state have been switched on with all TX Paths switched on,
...  and after reconfiguration reevaluated again.
...  *****************
...  Pre-conditions
...  *****************
...  N/A
...  ******************
...  History of changes
...  ******************
...  26.10.2022 - https://jiradc.ext.net.nokia.com/browse/TAW-141 - Test case creation
...  21.12.2022 - https://jiradc.ext.net.nokia.com/browse/TAW-292 - Time increased for LTE1103 and LTE1203 activation
...  21.12.2022 - https://jiradc.ext.net.nokia.com/browse/TAW-292 - step 5 change to manage random period of SwitchingOnTX state
...  24.10.2023 - https://jiradc.ext.net.nokia.com/browse/TAW-471 - Added Teardown if call failed
...  *******************
...  RAN PZ3 WRO1 TEMPLATE


*** Keywords ***
PS.25_CB008800_Power_saving_configuration_change

    PS.25_CB008800_Power_saving_configuration_change.Test_Step:0 Test Preparation
    PS.25_CB008800_Power_saving_configuration_change.Test_Step:1 Disable Feature Before Test
    PS.25_CB008800_Power_saving_configuration_change.Test_Step:2 Activate Load-Based Extended Power Saving
    PS.25_CB008800_Power_saving_configuration_change.Test_Step:3 Configure Load-Based Extended Power Saving
    PS.25_CB008800_Power_saving_configuration_change.Test_Step:4 Check if selected cells reach applicable states
    PS.25_CB008800_Power_saving_configuration_change.Test_Step:5 Reconfigure Load-Based Extended Power Saving
    PS.25_CB008800_Power_saving_configuration_change.Test_Step:6 Final Recovery and Checkpoint

PS.25_CB008800_Power_saving_configuration_change.Test_Step:0 Test Preparation
    Log to console  \n========================================
    Log  Step: 0 Test Preparation  console=${True}
    Log to console  ========================================
    ${COUNTER_BEFORE_TEST}=  Get Reset Counter From Blackbox  COLLECT_BLACKBOX_FILE=${True}
#    Set Test Variable  ${COUNTER_BEFORE_TEST}
    @{feature_flags}=  Create List  actExtCellSOMethod  actLBPowerSaving  actLBRTXPowerSaving
    Set Test Variable  ${feature_flags}
    Select Random LTE Cell
    Set Test Variable  ${1st_ES_LNCEL_ID}  ${1st_LNCEL_ID}
    Set Test Variable  ${1st_ES_LNCEL_DN}  ${1st_LNCEL_DN}
    ${cell_list}=  Get LNCEL List Without SingleTX And mMIMO
    ${1st_RES_LNCEL_ID}  ${1st_RES_LNCEL_DN}  Select One Random LNCEL For ReducedEnergySanving  ${cell_list}
    Set Test Variable  ${1st_RES_LNCEL_ID}
    Set Test Variable  ${1st_RES_LNCEL_DN}
    ${selected_cells_IDs}=  Create List  ${1st_ES_LNCEL_ID}  ${1st_RES_LNCEL_ID}
    Set Test Variable  ${selected_cells_IDs}
    Log To Console  Reduced Energy Saving for LNCEL_R-${1st_RES_LNCEL_ID}
    Log To Console  Energy Saving for LNCEL_R-${1st_ES_LNCEL_ID}
    Check Power Saving  ${1st_ES_LNCEL_ID}  ENABLED  NOTENERGYSAVING
    Check Power Saving  ${1st_RES_LNCEL_ID}  ENABLED  NOTENERGYSAVING
    ${selected_cells_DNs}=  Create List  ${1st_ES_LNCEL_DN}  ${1st_RES_LNCEL_DN}
    Set Test Variable  ${selected_cells_DNs}
    Check if not Energy Saving cells are enabled  ENABLED  NOTENERGYSAVING  ${selected_cells_DNs}

PS.25_CB008800_Power_saving_configuration_change.Test_Step:1 Disable Feature Before Test
    Log to console  \n========================================
    Log  Step: 1 Disable Feature Before Test  console=${True}
    Log to console  ========================================
    ${pre_action_reset_number}=  Get Reset Counter From Blackbox
    Set Feature Under Given Object  ${LNBTS_DistName}  ${feature_flags}  false
    Remove PSGRP/NRPGRP Objects If Exist  PSGRP
    Check If Unexpected Alarms Are Raised  ${skip_fault}
    ${post_action_reset_number}=  Get Reset Counter From Blackbox
#    ${counter_diff}  Evaluate  abs(${pre_action_reset_number} - ${post_action_reset_number})
#    IF  ${counter_diff}!=${0}  Fail  msg=Detected unexpected BTS reset

PS.25_CB008800_Power_saving_configuration_change.Test_Step:2 Activate Load-Based Extended Power Saving
    Log to console  \n========================================
    Log  Step: 2 Activate Load-Based Extended Power Saving  console=${True}
    Log to console  ========================================
    ${pre_action_reset_number}=  Get Reset Counter From Blackbox
    Set Feature Under Given Object  ${LNBTS_DistName}  ${feature_flags}  true
    Check If Unexpected Alarms Are Raised  ${skip_fault}
    ${post_action_reset_number}=  Get Reset Counter From Blackbox
#    ${counter_diff}  Evaluate  abs(${pre_action_reset_number} - ${post_action_reset_number})
#    IF  ${counter_diff}!=${0}  Fail  msg=Detected unexpected BTS reset

PS.25_CB008800_Power_saving_configuration_change.Test_Step:3 Configure Load-Based Extended Power Saving
    Log to console  \n========================================
    Log  Step: 3 Configure Load-Based Extended Power Saving  console=${True}
    Log to console  ========================================
    ${pre_action_reset_number}=  Get Reset Counter From Blackbox
    Set Feature Under Given Object  ${LNBTS_DistName}  shutdownWindow  180
    ${if_actCo4g5g}  ${value_actCo4g5g}=  Run Keyword And Ignore Error  Get Parameter Value Under LNBTS  actCoordinated4g5gPowerSaving
    Set Test Variable  ${if_actCo4g5g}
    Create And Activate PSGRP For CB008800  ${1st_ES_LNCEL_DN}  ${1st_RES_LNCEL_DN}  PSGRP-88  45min  CB008800_Reconfig
    Check If Unexpected Alarms Are Raised  ${skip_fault}
    ${post_action_reset_number}=  Get Reset Counter From Blackbox
#    ${counter_diff}  Evaluate  abs(${pre_action_reset_number} - ${post_action_reset_number})
#    IF  ${counter_diff}!=${0}  Fail  msg=Detected unexpected BTS reset

PS.25_CB008800_Power_saving_configuration_change.Test_Step:4 Check if selected cells reach applicable states
    Log to console  \n========================================
    Log  Step: 4 Check if selected cells reach applicable states  console=${True}
    Log to console  ========================================
    ${pre_action_reset_number}=  Get Reset Counter From Blackbox
    Log To Console  \nWaiting for ENERGYSAVING on LNCEL_R-${1st_ES_LNCEL_ID}
    Wait Until keyword Succeeds  14min  15sec  Check Power Saving  ${1st_ES_LNCEL_ID}  DISABLED  ENERGYSAVING
    Check if not Energy Saving cells are enabled  ENABLED  NOTENERGYSAVING  ${selected_cells_DNs}
    Log To Console  \nWaiting for REDUCEDENERGYSAVING on LNCEL_R-${1st_RES_LNCEL_ID}
    Wait Until keyword Succeeds  10min  15sec  Check Power Saving  ${1st_RES_LNCEL_ID}  ENABLED  REDUCEDENERGYSAVING
    Check if not Energy Saving cells are enabled  ENABLED  NOTENERGYSAVING  ${selected_cells_DNs}
    Log To Console  Cells reach applicable states
    Check If Unexpected Alarms Are Raised  ${skip_fault}
    ${post_action_reset_number}=  Get Reset Counter From Blackbox
#    ${counter_diff}  Evaluate  abs(${pre_action_reset_number} - ${post_action_reset_number})
#    IF  ${counter_diff}!=${0}  Fail  msg=Detected unexpected BTS reset

PS.25_CB008800_Power_saving_configuration_change.Test_Step:5 Reconfigure Load-Based Extended Power Saving
    Log to console  \n========================================
    Log  Step: 5 Reconfigure Load-Based Extended Power Saving  console=${True}
    Log to console  ========================================
    ${pre_action_reset_number}=  Get Reset Counter From Blackbox
    ${delta_reconfig_psgrp}=  Set Variable  delta_reconfig_psgrp
    admin.create delta  ${delta_reconfig_psgrp}
    ${lbpsCellList}=  Create Dictionary
    ${lbpsCelPeriodList_reconfig}=  Create Dictionary
    ${item}=  Create List  2  1
    ${PSGRP_DN}=  Set Variable  MRBTS-${MRBTS_ID}/LNBTS-${MRBTS_ID}/PSGRP-88
    FOR  ${i}  ${cell}  IN ZIP  ${item}  ${selected_cells_IDs}
        Set To Dictionary  ${lbpsCellList}  lbpsCellSOOrder=${i}
        Set To Dictionary  ${lbpsCellList}  lbpsUseExtConfig  true
        Set To Dictionary  ${lbpsCellList}  lnCelId=${cell}
        admin.append complex item to delta  ${PSGRP_DN}  list_name=lbpsCellList  &{lbpsCellList}  delta_id=${delta_reconfig_psgrp}
    END
    ${switch_off_methods}=  Create List  Cell Switch Off  Tx Paths Switch Off
    FOR  ${switch_off_method}  ${cell_ID}  IN ZIP  ${switch_off_methods}  ${selected_cells_IDs}
        Set To Dictionary  ${lbpsCelPeriodList_reconfig}  lbpsCellDayOfWeek=${day}
		Set To Dictionary  ${lbpsCelPeriodList_reconfig}  lbpsCellDuration=20
        Set To Dictionary  ${lbpsCelPeriodList_reconfig}  lbpsCellSOMethod=${switch_off_method}
        IF  ('${switch_off_method}' == 'Cell Switch Off')
            Get Time And Date With Minute Offset  7 minutes  25 minutes
            Set To Dictionary  ${lbpsCelPeriodList_reconfig}  lbpsCellStartTimeHour=${start_hour}
            Set To Dictionary  ${lbpsCelPeriodList_reconfig}  lbpsCellStartTimeMinute=${start_minutes}
            Log  Power Saving for LNCEL_R-${cell_ID} time frame: ${start_hour}:${start_minutes}-${end_hour}:${end_minutes}.  console=${true}
            Log  Switching Off Method: ${switch_off_method}  console=${true}  console=${true}
        ELSE IF  '${switch_off_method}' == 'Tx Paths Switch Off'
            Get Time And Date With Minute Offset  5 minutes  25 minutes
            Set To Dictionary  ${lbpsCelPeriodList_reconfig}  lbpsCellStartTimeHour=${start_hour}
            Set To Dictionary  ${lbpsCelPeriodList_reconfig}  lbpsCellStartTimeMinute=${start_minutes}
            Log  Power Saving for LNCEL_R-${cell_ID} time frame: ${start_hour}:${start_minutes}-${end_hour}:${end_minutes}.  console=${true}
            Log  Switching Off Method: ${switch_off_method}  console=${true}
        END
        Set To Dictionary  ${lbpsCelPeriodList_reconfig}  lnCelId=${cell_ID}
        admin.append complex item to delta  ${PSGRP_DN}  list_name=lbpsCelPeriodList  &{lbpsCelPeriodList_reconfig}  delta_id=${delta_reconfig_psgrp}

    END
    admin.get delta  ${delta_reconfig_psgrp}
    admin.save delta  ${RESULTS}/delta_reconfig_psgrp_CB008800.json  ${delta_reconfig_psgrp}
    admin.perform delta recommissioning  ${RESULTS}/delta_reconfig_psgrp_CB008800.json  ${delta_reconfig_psgrp}
    Log to console  Configuration update to a LNCELs:PSGRP:lbpsCellList
    Log To Console  \nWaiting for NOTENERGYSAVING on LNCEL_R-${1st_ES_LNCEL_ID}
    Wait Until keyword Succeeds  0.5min  10sec  Check Power Saving  ${1st_ES_LNCEL_ID}  ENABLED  NOTENERGYSAVING
    Log To Console  \nWaiting for SWITCHINGONTX on LNCEL_R-${1st_RES_LNCEL_ID}
    Wait Until keyword Succeeds  5min  10sec  Check Power Saving  ${1st_RES_LNCEL_ID}  ENABLED  SWITCHINGONTX  #OM_LTE_SFS_RNL.28146
    Log To Console  \nWaiting for NOTENERGYSAVING on LNCEL_R-${1st_RES_LNCEL_ID}
    Wait Until keyword Succeeds  5min  10sec  Check Power Saving  ${1st_RES_LNCEL_ID}  ENABLED  NOTENERGYSAVING
    Log To Console  \nWaiting for REDUCEDENERGYSAVING on LNCEL_R-${1st_RES_LNCEL_ID}
    Wait Until keyword Succeeds  15min  15sec  Check Power Saving  ${1st_RES_LNCEL_ID}  ENABLED  REDUCEDENERGYSAVING
    Check if not Energy Saving cells are enabled  ENABLED  NOTENERGYSAVING  ${selected_cells_DNs}
    Log To Console  \nWaiting for ENERGYSAVING on LNCEL_R-${1st_ES_LNCEL_ID}
    Wait Until keyword Succeeds  15min  15sec  Check Power Saving  ${1st_ES_LNCEL_ID}  DISABLED  ENERGYSAVING
    Check if not Energy Saving cells are enabled  ENABLED  NOTENERGYSAVING  ${selected_cells_DNs}
    Log To Console  \nWaiting for NOTENERGYSAVING on LNCEL_R-${1st_ES_LNCEL_ID}
    Wait Until keyword Succeeds  20min  15sec  Check Power Saving  ${1st_ES_LNCEL_ID}  ENABLED  NOTENERGYSAVING
    Log To Console  \nWaiting for NOTENERGYSAVING on LNCEL_R-${1st_RES_LNCEL_ID}
    Wait Until keyword Succeeds  20min  15sec  Check Power Saving  ${1st_RES_LNCEL_ID}  ENABLED  NOTENERGYSAVING
    Check If Unexpected Alarms Are Raised  ${skip_fault}
    ${post_action_reset_number}=  Get Reset Counter From Blackbox
#    ${counter_diff}  Evaluate  abs(${pre_action_reset_number} - ${post_action_reset_number})
#    IF  ${counter_diff}!=${0}  Fail  msg=Detected unexpected BTS reset
#    ${status}  Run Keyword And Return Status  L3 Call
#    IF  not ${status}  Teardown if call failed

PS.25_CB008800_Power_saving_configuration_change.Test_Step:6 Final Recovery and Checkpoint
    Log to console  \n========================================
    Log  Step: 6 Final Recovery and Checkpoint  console=${True}
    Log to console  ========================================
    ${pre_action_reset_number}=  Get Reset Counter From Blackbox
    Remove PSGRP/NRPGRP Objects If Exist  PSGRP
    Set Feature Under Given Object  ${LNBTS_DistName}  ${feature_flags}  false
    Check If Unexpected Alarms Are Raised  ${skip_fault}
#    ${post_action_reset_number}=  Get Reset Counter From Blackbox
#    ${counter_diff}  Evaluate  abs(${pre_action_reset_number} - ${post_action_reset_number})
#    IF  ${counter_diff}!=${0}  Fail  msg=Detected unexpected BTS reset
    ${COUNTER_AFTER_TEST}=  Get Reset Counter From Blackbox  COLLECT_BLACKBOX_FILE=${True}
#    ${counter_diff}  Evaluate  abs(${COUNTER_AFTER_TEST} - ${COUNTER_BEFORE_TEST})
#    IF  ${counter_diff}!=${0}  Fail  msg=Detected unexpected BTS reset

PS.25_CB008800_Power_saving_configuration_change.Test Specific Teardown
    [Documentation]  Test Specific Teardown.
    Log To Console  \n============ SPECIFIC TEST TEARDOWN =============
    admin.setup admin  admin_api_log_dir=${RESULTS}/admin_api/  alias=${ute_admin_alias}
    Run Keyword And Ignore Error  Remove PSGRP/NRPGRP Objects If Exist  PSGRP
    Run Keyword And Ignore Error  Set Feature Under Given Object  ${LNBTS_DistName}  ${feature_flags}  false
    admin.teardown admin  alias=${ute_admin_alias}
    Log To Console  ========== SPECIFIC TEST TEARDOWN DONE ==========\n

PS.25_CB008800_Power_saving_configuration_change.Test Case Teardown
    Run Keywords  common.Common Test Teardown
    Run Keyword If Test Failed  PS.25_CB008800_Power_saving_configuration_change.Test Specific Teardown
