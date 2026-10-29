*** Settings ***
Resource    ../../../resources/common.robot
Resource    ../../../resources/alarms.robot
Resource    ../../../resources/ald.robot
Resource    ../../../resources/power_saving.robot
Resource    ../../../resources/L3_call.robot

Documentation
...  TEST NAME:     PS.41_PS_CB010683-B_Mixed_switch_off_with_extended_configuration_change
...  AUTHORS:       filip.tuznik@nokia.com
...  MAINTAINER:    RAN_PZ_WRO_3_SG01
...  *****************
...  Basic information
...  *****************
...  Purpose of this test case is to verify extended cell-level configuration with mixed SO method and config changes set works properly on NR cells
...  *****************
...  Pre-conditions
...  *****************
...  gNB is in operational On Air state, No active alarms on gNB, NR cells should be 4Tx4RX.
...  ******************
...  History of changes
...  ******************
...  21.09.2023 - https://jiradc.ext.net.nokia.com/browse/TAW-412 - TC creation
...  27.09.2023 - https://jiradc.ext.net.nokia.com/browse/TAW-405 - TC adaptation for non mMIMO BTS
...  *******************
...  RAN PZ3 WRO1 TEMPLATE


*** Keywords ***
PS.41_PS_CB010683-B_Mixed_switch_off_with_extended_configuration_change
    PS.41_PS_CB010683-B_Mixed_switch_off_with_extended_configuration_change:0 Test Preparation
    PS.41_PS_CB010683-B_Mixed_switch_off_with_extended_configuration_change:1 Create and activate NRGRP
    PS.41_PS_CB010683-B_Mixed_switch_off_with_extended_configuration_change:2 Activate PS features
    PS.41_PS_CB010683-B_Mixed_switch_off_with_extended_configuration_change:3 Check Energy saving states
    PS.41_PS_CB010683-B_Mixed_switch_off_with_extended_configuration_change:4 Reconfigure Power Saving Group
    PS.41_PS_CB010683-B_Mixed_switch_off_with_extended_configuration_change:5 Check Energy saving states after reconfiguration
    PS.41_PS_CB010683-B_Mixed_switch_off_with_extended_configuration_change:6 Disable PS features
    PS.41_PS_CB010683-B_Mixed_switch_off_with_extended_configuration_change:7 Final recovery and verification

PS.41_PS_CB010683-B_Mixed_switch_off_with_extended_configuration_change:0 Test Preparation
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

PS.41_PS_CB010683-B_Mixed_switch_off_with_extended_configuration_change:1 Create and activate NRGRP
    Log to console    \n========================================
    Log  Step: 1 Create and activate  console=${True}
    Log to console    ========================================
    ${if_actNrExtCellSOMethod}  ${value_actNrExtCellSOMethod}=  Run Keyword And Ignore Error  Get Parameter Value Under NRBTS  actNrExtCellSOMethod
    Set Test Variable  ${if_actNrExtCellSOMethod}
    ${duration}  Set variable  50 minutes
    Create And Activate NRPGRP For CB010683  ${duration}  test_id=41
    ${start_date}  Get Current Date
    ${duration}  Add Time To Time  ${duration}  10 minutes
    ${end_date}  Add Time To Date    ${start_date}    ${duration}
    Set Test Variable  ${end_date}
    ${nrpgrp_start}    Add Time To Date    ${start_date}    10 minutes
    Set Test Variable    ${nrpgrp_start}

PS.41_PS_CB010683-B_Mixed_switch_off_with_extended_configuration_change:2 Activate PS features
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

PS.41_PS_CB010683-B_Mixed_switch_off_with_extended_configuration_change:3 Check Energy saving states
    Log to console    \n========================================
    Log  Step: 3 Check Energy saving states  console=${True}
    Log to console    ========================================
    Wait for date    ${nrpgrp_start}
    Log to console  \nWaiting for ENERGYSAVING on NRCELL_R-${selected_cells[0]}
    Wait Until Keyword Succeeds  10min  30sec  Check Power Saving NR  ${selected_cells[0]}  DISABLED  ENERGYSAVING
    Log to console  \nWaiting for ENERGYSAVING on NRCELL_R-${selected_cells[2]}
    Wait Until Keyword Succeeds  10min  30sec  Check Power Saving NR  ${selected_cells[2]}  DISABLED  ENERGYSAVING
    Log to console  \nWaiting for REDUCEDENERGYSAVING on NRCELL_R-${selected_cells[1]}
    Wait Until Keyword Succeeds  10min  30sec  Check Power Saving NR  ${selected_cells[1]}  ENABLED  REDUCEDENERGYSAVING

PS.41_PS_CB010683-B_Mixed_switch_off_with_extended_configuration_change:4 Reconfigure Power Saving Group
    Log to console  \n========================================
    Log  Step: 4 Reconfigure Power Saving Group console=${True}
    Log to console  ========================================
    ${pre_action_reset_number}=  Get Reset Counter From Blackbox
    ${delta_reconfig_nrpgrp}=  Set Variable  delta_reconfig_nrpgrp
    admin.create delta  ${delta_reconfig_nrpgrp}
    ${lbpsCellList}=  Create Dictionary
    ${lbpsCellPer_reconf}=  Create Dictionary
    ${NRPGRP_DN}=  Set Variable  MRBTS-${MRBTS_ID}/NRBTS-${NRBTS_ID}/NRPGRP-13

    ${switch_off_methods}=  Create List  TX switch off  mixed switch off
    FOR  ${switch_off_method}  ${cell_ID}  IN ZIP  ${switch_off_methods}  ${selected_cells}[0:-1]
        Set To Dictionary  ${lbpsCellPer_reconf}  lbpsCellDayOfWeek=${day}
		Set To Dictionary  ${lbpsCellPer_reconf}  lbpsCellDuration=20
        Set To Dictionary  ${lbpsCellPer_reconf}  lbpsCellSOMethod=${switch_off_method}
        IF  '${switch_off_method}' == 'TX switch off'
            Get Time And Date With Minute Offset  8 minutes  20 minutes
            Set To Dictionary  ${lbpsCellPer_reconf}  lbpsCellStartTimeHour=${start_hour}
            Set To Dictionary  ${lbpsCellPer_reconf}  lbpsCellStartTimeMinute=${start_minutes}
            Log  Power Saving for NRCELL_R-${cell_ID} time frame: ${start_hour}:${start_minutes}-${end_hour}:${end_minutes}.  console=${true}
            Log  Switching Off Method: ${switch_off_method}  console=${true}  console=${true}
        ELSE IF  '${switch_off_method}' == 'mixed switch off'
            Get Time And Date With Minute Offset  6 minutes  20 minutes
            Set To Dictionary  ${lbpsCellPer_reconf}  lbpsCellStartTimeHour=${start_hour}
            Set To Dictionary  ${lbpsCellPer_reconf}  lbpsCellStartTimeMinute=${start_minutes}
            Log  Power Saving for NRCELL_R-${cell_ID} time frame: ${start_hour}:${start_minutes}-${end_hour}:${end_minutes}.  console=${true}
            Log  Switching Off Method: ${switch_off_method}  console=${true}
        END
        Set To Dictionary  ${lbpsCellPer_reconf}  nrCellId=${cell_ID}
        admin.append complex item to delta  ${NRPGRP_DN}  list_name=lbpsCellPeriodList  &{lbpsCellPer_reconf}  delta_id=${delta_reconfig_nrpgrp}
    END
    admin.get delta  ${delta_reconfig_nrpgrp}
    admin.save delta  ${RESULTS}/delta_reconfig_nrpgrp_CB010683.json  ${delta_reconfig_nrpgrp}
    admin.perform delta recommissioning  ${RESULTS}/delta_reconfig_nrpgrp_CB010683.json  ${delta_reconfig_nrpgrp}
    Log to console  Configuration update to a NRCELLs:NRPGRP:lbpsCellPeriodList

PS.41_PS_CB010683-B_Mixed_switch_off_with_extended_configuration_change:5 Check Energy saving states after reconfiguration
    Log to console    \n========================================
    Log  Step: 5 Check Energy saving states after reconfiguration  console=${True}
    Log to console    ========================================

    Log to console  \nWaiting for NOTENERGYSAVING on NRCELL_R-${selected_cells[0]}
    Wait Until Keyword Succeeds  0.5min  10sec  Check Power Saving NR  ${selected_cells[0]}  ENABLED  NOTENERGYSAVING
    Log to console  \nWaiting for NOTENERGYSAVING on NRCELL_R-${selected_cells[1]}
    Wait Until Keyword Succeeds  5min  10sec  Check Power Saving NR  ${selected_cells[1]}  ENABLED  NOTENERGYSAVING
    Log to console  \nWaiting for NOTENERGYSAVING on NRCELL_R-${selected_cells[2]}
    Wait Until Keyword Succeeds  5min  10sec  Check Power Saving NR  ${selected_cells[2]}  ENABLED  NOTENERGYSAVING

    Log to console  \nWaiting for ENERGYSAVING on NRCELL_R-${selected_cells[2]}
    Wait Until Keyword Succeeds  15min  30sec  Check Power Saving NR  ${selected_cells[2]}  DISABLED  ENERGYSAVING
    Log to console  \nWaiting for ENERGYSAVING on NRCELL_R-${selected_cells[1]}
    Wait Until Keyword Succeeds  10min  30sec  Check Power Saving NR  ${selected_cells[1]}  DISABLED  ENERGYSAVING
    Log to console  \nWaiting for REDUCEDENERGYSAVING on NRCELL_R-${selected_cells[0]}
    Wait Until Keyword Succeeds  20min  30sec  Check Power Saving NR  ${selected_cells[0]}  ENABLED  REDUCEDENERGYSAVING

    Log to console  \nWaiting for Power Saving Period ends
    Wait for date  ${end_date}  120

    Log to console  \nCheck Not Energysaving for NRCELL ${selected_cells[0]}, ${selected_cells[1]} and ${selected_cells[2]}
    Wait Until Keyword Succeeds  1min  30sec  Check Power Saving NR  ${selected_cells[0]}  ENABLED  NOTENERGYSAVING
    Wait Until Keyword Succeeds  1min  30sec  Check Power Saving NR  ${selected_cells[1]}  ENABLED  NOTENERGYSAVING
    Wait Until Keyword Succeeds  1min  30sec  Check Power Saving NR  ${selected_cells[2]}  ENABLED  NOTENERGYSAVING
    Check If Unexpected Alarms Are Raised  ${skip_fault}

PS.41_PS_CB010683-B_Mixed_switch_off_with_extended_configuration_change:6 Disable PS features
    Log to console    \n========================================
    Log  Step: 6 Disable PS features  console=${True}
    Log to console    ========================================
    Remove PSGRP/NRPGRP Objects If Exist  NRPGRP
    Set Feature Under Given Object  ${NRBTS_DistName}  ${mimo_flags}  false
    ${if_NR_exist}  Run Keyword And Return Status  List Should Contain Value  ${rats}  nr
    IF  ${if_NR_exist}
        Disallow Fault In Watchdog  faultID=6327  #fault_name: Setup of X2 connectivity to gNB failed
        Disallow Fault In Watchdog  faultID=7300  #fault_name: No X2 link available
        Disallow Fault In Watchdog  faultID=7319  #fault_name: No X2 link available for a specific LTEENB
    END

PS.41_PS_CB010683-B_Mixed_switch_off_with_extended_configuration_change:7 Final recovery and verification
    Log to console    \n========================================
    Log  Step: 7 Final recovery and verification  console=${True}
    Log to console    ========================================
    Check If NLWG Cells Are OnAir
    Check If Unexpected Alarms Are Raised  ${skip_fault}

PS.41_PS_CB010683-B_Mixed_switch_off_with_extended_configuration_change.Test Case Teardown
    Run Keyword If Test Failed  PS.41_PS_CB010683-B_Mixed_switch_off_with_extended_configuration_change:6 Disable PS features
    Run Keywords  Common Test Teardown
