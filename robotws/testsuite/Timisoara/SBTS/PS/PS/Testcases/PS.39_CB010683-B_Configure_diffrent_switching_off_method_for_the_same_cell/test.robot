*** Settings ***
Resource    ../../../resources/common.robot
Resource    ../../../resources/alarms.robot
Resource    ../../../resources/ald.robot
Resource    ../../../resources/power_saving.robot
Resource    ../../../resources/L3_call.robot

Documentation
...  TEST NAME:     PS.39_CB010683-B_Configure_diffrent_switching_off_method_for_the_same_cell
...  AUTHORS:       mateusz.gumieniak@nokia.com
...  MAINTAINER:    RAN_PZ_WRO_3_SG01
...  *****************
...  Basic information
...  *****************
...  Purpose of this test case is to verify extended cell-level configuration with mixed switch off method set works properly on NR cells.
...  *****************
...  Pre-conditions
...  *****************
...  gNB is in operational On Air state, No active alarms on gNB, At least one non singleTX cell available
...  ******************
...  History of changes
...  ******************
...  12.09.2023 - https://jiradc.ext.net.nokia.com/browse/TAW-413 - TC creation
...  27.09.2023 - https://jiradc.ext.net.nokia.com/browse/TAW-405 - TC adaptation for non mMIMO BTS
...  *******************
...  RAN PZ3 WRO1 TEMPLATE


*** Keywords ***
PS.39_CB010683-B_Configure_diffrent_switching_off_method_for_the_same_cell
    PS.39_CB010683-B_Configure_diffrent_switching_off_method_for_the_same_cell:0 Test Preparation
    PS.39_CB010683-B_Configure_diffrent_switching_off_method_for_the_same_cell:1 Create and activate NRGRP
    PS.39_CB010683-B_Configure_diffrent_switching_off_method_for_the_same_cell:2 Activate PS features
    PS.39_CB010683-B_Configure_diffrent_switching_off_method_for_the_same_cell:3 Check Energy saving states
    PS.39_CB010683-B_Configure_diffrent_switching_off_method_for_the_same_cell:4 Disable PS features
    PS.39_CB010683-B_Configure_diffrent_switching_off_method_for_the_same_cell:5 Final recovery and verification

PS.39_CB010683-B_Configure_diffrent_switching_off_method_for_the_same_cell:0 Test Preparation
    Log to console    \n========================================
    Log  Step: 0 Test Preparation  console=${True}
    Log to console    ========================================
    Remove PSGRP/NRPGRP Objects If Exist  NRPGRP
    @{feature_flags}=  Create List  actNrExtCellSOMethod  actNrMixedSOMethod  actNrLBPowerSaving  actNrLBRTXPowerSaving
    Set Test Variable  ${feature_flags}
    @{mimo_flags}=  Create List  actNrLBPowerSaving  actNrLBRTXPowerSaving  actNrLBmMimoRTXPowerSaving  actNrExtCellSOMethod  actNrMixedSOMethod
    Set Test Variable  ${mimo_flags}
    Get NR Cells For CB010683
    ${nr_cells_length}  Get Length  ${selected_cells}
    @{cell_order}  Create List
    FOR    ${i}    IN RANGE    1    ${nr_cells_length}+1
      Append To List    ${cell_order}    ${i}
    END
    Set List Value  ${cell_order}    -1    ${100}
    Set Test Variable    ${cell_order}
    ${rats}  Detect RATs

PS.39_CB010683-B_Configure_diffrent_switching_off_method_for_the_same_cell:1 Create and activate NRGRP
    Log to console    \n========================================
    Log  Step: 1 Create and activate  console=${True}
    Log to console    ========================================
    ${if_actNrExtCellSOMethod}  ${value_actNrExtCellSOMethod}=  Run Keyword And Ignore Error  Get Parameter Value Under NRBTS  actNrExtCellSOMethod
    Set Test Variable  ${if_actNrExtCellSOMethod}
    # <><><><><><> CHANGE KEYWORD IN PS <><><><><><><><>
    ${duration}  Set variable  50 minutes
    Set test Variable    ${duration}
    Create And Activate NRPGRP For CB010683  ${duration}  test_id=39
    ${start_date}  Get Current Date
    ${duration}  Add Time To Time  ${duration}  10 minutes
    ${end_date}  Add Time To Date    ${start_date}    ${duration}
    Set Test Variable  ${end_date}
    ${mid_date}  Add Time To Date  ${start_date}  30 minutes
    Set Test Variable    ${mid_date}
    ${nrpgrp_start}    Add Time To Date    ${start_date}    10 minutes
    Set Test Variable    ${nrpgrp_start}

PS.39_CB010683-B_Configure_diffrent_switching_off_method_for_the_same_cell:2 Activate PS features
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
    IF  ${MIMO_CELLS}!=[]  Set Feature Under Given Object  ${NRBTS_DistName}  actNrLBmMimoRTXPowerSaving  true
    Check If NLWG Cells Are OnAir

PS.39_CB010683-B_Configure_diffrent_switching_off_method_for_the_same_cell:3 Check Energy saving states
    Log to console    \n========================================
    Log  Step: 3 Check Energy saving states  console=${True}
    Log to console    ========================================
    Wait for date    ${nrpgrp_start}
    Log to console  check Energysaving for NRCELL ${selected_cells[0]}
    Wait Until Keyword Succeeds  10min  30sec  Check Power Saving NR  ${selected_cells[0]}  DISABLED  ENERGYSAVING
    Log to console  check Energysaving for NRCELL ${selected_cells[1]}
    Wait Until Keyword Succeeds  10min  30sec  Check Power Saving NR  ${selected_cells[1]}  DISABLED  ENERGYSAVING
    #
    Wait for date    ${mid_date}  30
    Log to console  check Not Energysaving for NRCELL ${selected_cells[0]}
    Wait Until Keyword Succeeds  10min  30sec  Check Power Saving NR  ${selected_cells[0]}  ENABLED  NOTENERGYSAVING
    Log to console  check Not Energysaving for NRCELL ${selected_cells[1]}
    Wait Until Keyword Succeeds  10min  30sec  Check Power Saving NR  ${selected_cells[1]}  ENABLED  NOTENERGYSAVING
    #
    Log to console  check Reduced Energysaving for NRCELL ${selected_cells[0]}
    Wait Until Keyword Succeeds  10min  30sec  Check Power Saving NR  ${selected_cells[0]}  ENABLED  REDUCEDENERGYSAVING
    Log to console  check Reduced Energysaving for NRCELL ${selected_cells[1]}
    Wait Until Keyword Succeeds  10min  30sec  Check Power Saving NR  ${selected_cells[1]}  ENABLED  REDUCEDENERGYSAVING
    #
    Wait for date  ${end_date}  30
    Log to console  check Not Energysaving for NRCELL ${selected_cells[0]}
    Wait Until Keyword Succeeds  1min  30sec  Check Power Saving NR  ${selected_cells[0]}  ENABLED  NOTENERGYSAVING
    Log to console  check Not Energysaving for NRCELL ${selected_cells[1]}
    Wait Until Keyword Succeeds  1min  30sec  Check Power Saving NR  ${selected_cells[1]}  ENABLED  NOTENERGYSAVING

PS.39_CB010683-B_Configure_diffrent_switching_off_method_for_the_same_cell:4 Disable PS features
    Log to console    \n========================================
    Log  Step: 4 Disable PS features  console=${True}
    Log to console    ========================================
    Remove PSGRP/NRPGRP Objects If Exist  NRPGRP
    Set Feature Under Given Object  ${NRBTS_DistName}  ${mimo_flags}  false
    ${if_NR_exist}  Run Keyword And Return Status  List Should Contain Value  ${rats}  nr
    IF  ${if_NR_exist}
        Disallow Fault In Watchdog  faultID=6327  #fault_name: Setup of X2 connectivity to gNB failed
        Disallow Fault In Watchdog  faultID=7300  #fault_name: No X2 link available
        Disallow Fault In Watchdog  faultID=7319  #fault_name: No X2 link available for a specific LTEENB
    END

PS.39_CB010683-B_Configure_diffrent_switching_off_method_for_the_same_cell:5 Final recovery and verification
    Log to console    \n========================================
    Log  Step: 5 Final recovery and verification  console=${True}
    Log to console    ========================================
    Check If NLWG Cells Are OnAir
#    Check If Unexpected Alarms Are Raised  ${skip_fault}

PS.39_CB010683-B_Configure_diffrent_switching_off_method_for_the_same_cell.Test Case Teardown
    Run Keyword If Test Failed  PS.39_CB010683-B_Configure_diffrent_switching_off_method_for_the_same_cell:4 Disable PS features
    Run Keywords  Common Test Teardown
