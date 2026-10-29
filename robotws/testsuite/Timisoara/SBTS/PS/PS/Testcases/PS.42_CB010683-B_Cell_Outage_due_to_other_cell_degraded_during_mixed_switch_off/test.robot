*** Settings ***
Resource    ../../../resources/common.robot
Resource    ../../../resources/alarms.robot
Resource    ../../../resources/ald.robot
Resource    ../../../resources/power_saving.robot
Resource    ../../../resources/L3_call.robot

Documentation
...  TEST NAME:     PS.42_CB010683-B_Cell_Outage_due_to_other_cell_degraded_during_mixed_switch_off
...  AUTHORS:       mateusz.gumieniak@nokia.com
...  MAINTAINER:    RAN_PZ_WRO_3_SG01
...  *****************
...  Basic information
...  *****************
...  Purpose of this test case is to verify if ES cells works properly on degraded/failed one of them.
...  *****************
...  Pre-conditions
...  *****************
...  gNB is in operational On Air state, No active alarms on gNB, At least one non singleTX cell available
...  ******************
...  History of changes
...  ******************
...  12.09.2023 - https://jiradc.ext.net.nokia.com/browse/TAW-415 - TC creation
...  27.09.2023 - https://jiradc.ext.net.nokia.com/browse/TAW-405 - TC adaptation for non mMIMO BTS
...  *******************
...  RAN PZ3 WRO1 TEMPLATE


*** Keywords ***
PS.42_CB010683-B_Cell_Outage_due_to_other_cell_degraded_during_mixed_switch_off
    PS.42_CB010683-B_Cell_Outage_due_to_other_cell_degraded_during_mixed_switch_off:0 Test Preparation
    PS.42_CB010683-B_Cell_Outage_due_to_other_cell_degraded_during_mixed_switch_off:1 Create and activate NRGRP
    PS.42_CB010683-B_Cell_Outage_due_to_other_cell_degraded_during_mixed_switch_off:2 Activate PS features
    PS.42_CB010683-B_Cell_Outage_due_to_other_cell_degraded_during_mixed_switch_off:3 Check Energy saving states
    PS.42_CB010683-B_Cell_Outage_due_to_other_cell_degraded_during_mixed_switch_off:4 Disable PS features
    PS.42_CB010683-B_Cell_Outage_due_to_other_cell_degraded_during_mixed_switch_off:5 Final recovery and verification

PS.42_CB010683-B_Cell_Outage_due_to_other_cell_degraded_during_mixed_switch_off:0 Test Preparation
    Log to console    \n========================================
    Log  Step: 0 Test Preparation  console=${True}
    Log to console    ========================================
    Remove PSGRP/NRPGRP Objects If Exist  NRPGRP
    @{feature_flags}=  Create List  actNrExtCellSOMethod  actNrMixedSOMethod  actNrLBPowerSaving  actNrLBRTXPowerSaving  actNrLBmMimoRTXPowerSaving
    Set Test Variable  ${feature_flags}
    Get NR Cells For CB010683
    ${nr_cells_length}  Get Length  ${selected_cells}
    @{cell_order}  Create List
    FOR    ${i}    IN RANGE    1    ${nr_cells_length}+1
      Append To List    ${cell_order}    ${i}
    END
    Set List Value  ${cell_order}    -1    ${100}
    Set Test Variable    ${cell_order}
    ${rats}  Detect RATs

PS.42_CB010683-B_Cell_Outage_due_to_other_cell_degraded_during_mixed_switch_off:1 Create and activate NRGRP
    Log to console    \n========================================
    Log  Step: 1 Create and activate  console=${True}
    Log to console    ========================================
    ${if_actNrExtCellSOMethod}  ${value_actNrExtCellSOMethod}=  Run Keyword And Ignore Error  Get Parameter Value Under NRBTS  actNrExtCellSOMethod
    Set Test Variable  ${if_actNrExtCellSOMethod}
    ${duration}  Set variable  35 minutes
    Create And Activate NRPGRP For CB010683  ${duration}
    ${start_date}  Get Current Date
    ${duration}  Add Time To Time  ${duration}  10 minutes
    ${end_date}  Add Time To Date    ${start_date}    ${duration}
    Set Test Variable  ${end_date}
    ${nrpgrp_start}    Add Time To Date    ${start_date}    10 minutes
    Set Test Variable    ${nrpgrp_start}


PS.42_CB010683-B_Cell_Outage_due_to_other_cell_degraded_during_mixed_switch_off:2 Activate PS features
    Log to console    \n========================================
    Log  Step: 2 Activate PS features  console=${True}
    Log to console    ========================================
    ${rats}  Detect RATs
    Set Test Variable  ${rats}
    ${if_NR_exist}  Run Keyword And Return Status  List Should Contain Value  ${rats}  nr
    IF  ${if_NR_exist}
        Allow Fault In Watchdog  faultID=6327  #fault_name: Setup of X2 connectivity to gNB failed
        Allow Fault In Watchdog  faultID=7300  #fault_name: No X2 link available
        Allow Fault In Watchdog  faultID=7319  #fault_name: No X2 link available for a specific LTEENB
    END
    Set Feature Under Given Object  ${NRBTS_DistName}  ${feature_flags}  true
    Check If NLWG Cells Are OnAir


PS.42_CB010683-B_Cell_Outage_due_to_other_cell_degraded_during_mixed_switch_off:3 Check Energy saving states
    Log to console    \n========================================
    Log  Step: 3 Check Energy saving states  console=${True}
    Log to console    ========================================
    Wait for date    ${nrpgrp_start}
    Log to console  check Energysaving for NRCELL ${selected_cells[0]}
    Wait Until Keyword Succeeds  10min  30sec  Check Power Saving NR  ${selected_cells[0]}  DISABLED  ENERGYSAVING
#    Log to console  check Reduced Energysaving for NRCELL ${selected_cells[1]}
#    Wait Until Keyword Succeeds  8min  60sec  Check Power Saving NR  ${selected_cells[1]}  ENABLED  REDUCEDENERGYSAVING
    Log to console  check Energysaving for NRCELL ${selected_cells[2]}
    Wait Until Keyword Succeeds  10min  30sec  Check Power Saving NR  ${selected_cells[2]}  DISABLED  ENERGYSAVING
    Log to console  check Reduced Energysaving for NRCELL ${selected_cells[1]}
    Wait Until Keyword Succeeds  10min  30sec  Check Power Saving NR  ${selected_cells[1]}  ENABLED  REDUCEDENERGYSAVING
    #RMOD RESET
    ${RMODS_Len}  Get Length    ${MIMO_RMODS}
    FOR    ${i}    IN RANGE    0    ${RMODS_Len}
        Log To Console  Reset RMOD: ${MIMO_RMODS[${i}]}
        Run Keyword And Ignore Error    admin.reset unit  MRBTS-${MRBTS_ID}/EQM-1/APEQM-1/${MIMO_RMODS[${i}]}    timeout=10
    END
#Following CB013099 req. 11692117 cells remain in EE mode
    Log to console  check Not Energysaving for NRCELL ${selected_cells[1]} and ${selected_cells[2]}
    Wait Until Keyword Succeeds  1min  30sec  Check Power Saving NR  ${selected_cells[1]}  ENABLED  REDUCEDENERGYSAVING
    Wait Until Keyword Succeeds  1min  30sec  Check Power Saving NR  ${selected_cells[2]}  DISABLED  ENERGYSAVING


PS.42_CB010683-B_Cell_Outage_due_to_other_cell_degraded_during_mixed_switch_off:4 Disable PS features
    Log to console    \n========================================
    Log  Step: 4 Disable PS features  console=${True}
    Log to console    ========================================
    Remove PSGRP/NRPGRP Objects If Exist  NRPGRP
    Set Feature Under Given Object  ${NRBTS_DistName}  ${feature_flags}  false
    ${if_NR_exist}  Run Keyword And Return Status  List Should Contain Value  ${rats}  nr
    IF  ${if_NR_exist}
        Disallow Fault In Watchdog  faultID=6327  #fault_name: Setup of X2 connectivity to gNB failed
        Disallow Fault In Watchdog  faultID=7300  #fault_name: No X2 link available
        Disallow Fault In Watchdog  faultID=7319  #fault_name: No X2 link available for a specific LTEENB
    END


PS.42_CB010683-B_Cell_Outage_due_to_other_cell_degraded_during_mixed_switch_off:5 Final recovery and verification
    Log to console    \n========================================
    Log  Step: 5 Final recovery and verification  console=${True}
    Log to console    ========================================
    Check If NLWG Cells Are OnAir
    Check If Unexpected Alarms Are Raised  ${skip_fault}


PS.42_CB010683-B_Cell_Outage_due_to_other_cell_degraded_during_mixed_switch_off.Test Case Teardown
    Run Keyword If Test Failed  PS.42_CB010683-B_Cell_Outage_due_to_other_cell_degraded_during_mixed_switch_off :4 Disable PS features
    Run Keywords  common.Common Test Teardown
