*** Settings ***
Resource    ../../../resources/common.robot
Resource    ../../../resources/alarms.robot
Resource    ../../../resources/power_saving.robot

Documentation
...  TEST NAME:     PS.75_LTE1103_5GC000431_Multiple_Energy_Saving_Cell_Switch_Off_Switch_On_Transitions
...  AUTHORS:       victor.banicioiu@nokia.com
...  MAINTAINER:    TIM_5_Vrf    victor.banicioiu@nokia.com
...  *****************
...  Basic information
...  *****************
...  The test scope is to check LTE1103 and 5GC000431 features behavior when LTE&NR cells change energySaving state multiple times.
...  *****************
...  Pre-conditions
...  *****************
...  On-Air running eNB with no alarms.
...  ******************
...  History of changes
...  ******************
...  22.09.2025 - https://jiradc.ext.net.nokia.com/browse/TAT-29935 - TC creation
...  *******************


*** Variables ***
${NUMBER_OF_ES_PERIODS}    20    #Number of distinct energy saving time windows to be configured in PSGRP & NRPGRP


*** Keywords ***
PS.75_LTE1103_5GC000431_Multiple_Energy_Saving_Cell_Switch_Off_Switch_On_Transitions
    PS.75_LTE1103_5GC000431_Multiple_Energy_Saving_Cell_Switch_Off_Switch_On_Transitions.Step 0: Preparing Environment
    PS.75_LTE1103_5GC000431_Multiple_Energy_Saving_Cell_Switch_Off_Switch_On_Transitions.Step 1: Create And Activate PSGRP and NRPGRP
    PS.75_LTE1103_5GC000431_Multiple_Energy_Saving_Cell_Switch_Off_Switch_On_Transitions.Step 2: Check Cells Energy Entry And Exit


PS.75_LTE1103_5GC000431_Multiple_Energy_Saving_Cell_Switch_Off_Switch_On_Transitions.Step 0: Preparing Environment
    Log  \n========================================  console=true
    Log  Step 0: Preparing Environment\n  console=true
    Log  ========================================  console=true
    ${LNBTS_ID}  Get LNBTS ID
    Set Test Variable  ${LNBTS_ID}
    ${LTE_IDS}  Get LNCEL ID List Without IoT Cells
    ${NR_IDS}  Get NRCEL ID List Without IoT Cells
    Set Test Variable  ${LTE_IDS}
    Set Test Variable  ${NR_IDS}
    @{states_to_check}  Create List  availabilityStatus  administrativeState  blockingState
    @{expected_states}  Create List  -  UNLOCKED  UNBLOCKED
    FOR  ${cell_id}  IN  @{LTE_IDS}
        Check Cell States For Specific Cell  LNCEL  ${cell_id}  ${states_to_check}  ${expected_states}
    END
    FOR  ${cell_id}  IN  @{NR_IDS}
        Check Cell States For Specific Cell  NRCEL  ${cell_id}  ${states_to_check}  ${expected_states}
    END
    ${nr_of_lte_cells}  Get Length  ${LTE_IDS}
    ${nr_of_nr_cells}  Get Length  ${NR_IDS}
    IF  ${nr_of_lte_cells} >= 2 and ${nr_of_nr_cells} >=2
        ${SELECTED_LTES}  Create List
        ${SELECTED_NRS}  Create List
        FOR  ${i}  IN RANGE  0  2
            ${lte_cell_id}  Fetch From Right  ${LTE_IDS[${i}]}  -
            Append To List  ${SELECTED_LTES}  ${lte_cell_id}
            ${nr_cell_id}  Fetch From Right  ${NR_IDS[${i}]}  -
            Append To List  ${SELECTED_NRS}  ${nr_cell_id}
        END
        Set Test Variable  ${SELECTED_LTES}
        Set Test Variable  ${SELECTED_NRS}
    ELSE
        Log  Insufficient LTE or NR cells number (lower than 2). Test cannot continue.\n  level=ERROR  console=true
        Fail  Not enough LTE or NR cells available for the test!
    END


PS.75_LTE1103_5GC000431_Multiple_Energy_Saving_Cell_Switch_Off_Switch_On_Transitions.Step 1: Create And Activate PSGRP and NRPGRP
    Log  \n========================================  console=true
    Log  Step 1: Create And Activate PSGRP and NRPGRP\n  console=true
    Log  ========================================  console=true
    Remove Old PSGRP Objects If Present
    Remove Old NRPGRP Objects If Present
    Set Feature Under Given Object  ${LNBTS_DistName}  actLBPowerSaving  true
    Set Feature Under Given Object  ${LNBTS_DistName}  actLbpsCtrlLogicEnh  true
    Set Feature Under Given Object  ${LNBTS_DistName}  shutdownWindow  36
    Set Feature Under Given Object  ${NRBTS_DistName}  actNrLBPowerSaving  true
    Set Feature Under Given Object  ${NRBTS_DistName}  actLbpsCtrlLogicEnh  true
    Set Feature Under Given Object  ${NRBTS_DistName}  shutdownWindow  36
    Log  Create and activate PSGRP-0 and NRPGRP-0\n  console=true
    ${standalone_params_psgrp}  Create Dictionary
    Set To Dictionary  ${standalone_params_psgrp}  name  standalone
    Set To Dictionary  ${standalone_params_psgrp}  lbpsLastCellMinLoad  20
    Set To Dictionary  ${standalone_params_psgrp}  lbpsLastCellSOEnabled  true
    Set To Dictionary  ${standalone_params_psgrp}  lbpsLoadCalcMethod  Max(G_N_combined, P)
    Set To Dictionary  ${standalone_params_psgrp}  lbpsMaxLoad  60
    Set To Dictionary  ${standalone_params_psgrp}  lbpsMinLoad  25
    Set To Dictionary  ${standalone_params_psgrp}  lbpsMonWinForCellSOff  60
    Set To Dictionary  ${standalone_params_psgrp}  lbpsMonWinForCellSOn  120
    Set To Dictionary  ${standalone_params_psgrp}  lbpsMonWinForRtxSOff  60
    Set To Dictionary  ${standalone_params_psgrp}  lbpsMonWinForRtxSOn  120
    Set To Dictionary  ${standalone_params_psgrp}  lbpsSOffTrRule  SlidingAverageMethod
    Set To Dictionary  ${standalone_params_psgrp}  lbpsSOMethod  Cell Switch Off
    Set To Dictionary  ${standalone_params_psgrp}  lbpsSOnTrRule  SlidingAverageMethod
    ${cell_1}  Create Dictionary  name=lbpsCellList  lbpsCellSOOrder=100  lbpsUseExtConfig=false  lnCelId=${SELECTED_LTES[0]}
    ${cell_2}  Create Dictionary  name=lbpsCellList  lbpsCellSOOrder=100  lbpsUseExtConfig=false  lnCelId=${SELECTED_LTES[1]}
    @{cell_list_psgrp}  Create List  ${cell_1}  ${cell_2}

    ${standalone_params_nrpgrp}  Create Dictionary
    Set To Dictionary  ${standalone_params_nrpgrp}  name  standalone
    Set To Dictionary  ${standalone_params_nrpgrp}  lbpsLastCellMinLoad  20
    Set To Dictionary  ${standalone_params_nrpgrp}  lbpsLastCellSOEnabled  true
    Set To Dictionary  ${standalone_params_nrpgrp}  lbpsLoadCalcMethod  Max(G_N_combined, P)
    Set To Dictionary  ${standalone_params_nrpgrp}  lbpsMaxLoad  60
    Set To Dictionary  ${standalone_params_nrpgrp}  lbpsMinLoad  25
    Set To Dictionary  ${standalone_params_nrpgrp}  lbpsMonWinForCellSOff  60
    Set To Dictionary  ${standalone_params_nrpgrp}  lbpsMonWinForCellSOn  120
    Set To Dictionary  ${standalone_params_nrpgrp}  lbpsSOffTrRule  SlidingAverageMethod
    Set To Dictionary  ${standalone_params_nrpgrp}  lbpsSOMethod  cell switch off
    Set To Dictionary  ${standalone_params_nrpgrp}  lbpsSOnTrRule  SlidingAverageMethod
    ${cell_1}  Create Dictionary  name=lbpsCellList  lbpsCellSOOrder=100  lbpsUseExtConfig=false  nrCellId=${SELECTED_NRS[0]}
    ${cell_2}  Create Dictionary  name=lbpsCellList  lbpsCellSOOrder=100  lbpsUseExtConfig=false  nrCellId=${SELECTED_NRS[1]}
    @{cell_list_nrpgrp}  Create List  ${cell_1}  ${cell_2}
    ${offset}  Set Variable  ${5}
    Get Time And Date With Minute Offset  ${offset}minutes  ${SWITCH_OFF_DURATION}minutes
    @{period_list_psgrp}  Create List
    @{period_list_nrpgrp}  Create List
    @{START_TIMES}  Create List
    @{FINISH_TIMES}  Create List
    FOR  ${i}  IN RANGE  0  ${NUMBER_OF_ES_PERIODS}
        ${offset}  Set Variable  ${offset+10}
        ${lbpsPeriodList}  Create Dictionary  name=lbpsPeriodList  lbpsDayOfWeek=${day}  lbpsDuration=${SWITCH_OFF_DURATION}
        ...  lbpsStartTimeHour=${start_hour}  lbpsStartTimeMinute=${start_minutes}
        Append To List  ${period_list_psgrp}  ${lbpsPeriodList}
        Append To List  ${START_TIMES}  ${TIME_WITH_OFFSET}
        Append To List  ${FINISH_TIMES}  ${END_TIME}
        Get Time And Date With Minute Offset  ${offset}minutes  ${SWITCH_OFF_DURATION}minutes
    END
    Set Test Variable  ${START_TIMES}
    Set Test Variable  ${FINISH_TIMES}
    ${period_list_nrpgrp}  Copy List  ${period_list_psgrp}  deepcopy=true
    Create And Activate PSGRP  0  ${standalone_params_psgrp}  ${cell_list_psgrp}  ${period_list_psgrp}
    Log  PSGRP created with time frame ${START_TIMES[0]}-${FINISH_TIMES[-1]}\n  console=true
    Create And Activate NRPGRP  0  ${standalone_params_nrpgrp}  ${cell_list_nrpgrp}  ${period_list_nrpgrp}
    Log  NRPGRP created with time frame ${START_TIMES[0]}-${FINISH_TIMES[-1]}\n  console=true


PS.75_LTE1103_5GC000431_Multiple_Energy_Saving_Cell_Switch_Off_Switch_On_Transitions.Step 2: Check Cells Energy Entry And Exit
    Log  \n========================================  console=true
    Log  Step 2: Check Cells Energy Entry And Exit\n  console=true
    Log  ========================================  console=true
    @{states_to_check}  Create List  operationalState  energySavingState
    FOR  ${i}  IN RANGE  0  ${NUMBER_OF_ES_PERIODS}
        Log  Test enters pause until PSGRP/NRPGRP energy saving period ${i+1} starts\n  console=true
        Sleep Until Given Date  ${START_TIMES[${i}]}
        Log  Test enters pause until PSGRP/NRPGRP energy saving period ${i+1} starts\n  console=true
        @{expected_states}  Create List  DISABLED  ENERGYSAVING
        Wait For Specific Cell To Reach Expected States  LNCEL  ${SELECTED_LTES}  90s  15s  ${states_to_check}  ${expected_states}
        Wait For Specific Cell To Reach Expected States  NRCEL  ${SELECTED_NRS}  90s  15s  ${states_to_check}  ${expected_states}
        Log  LNCELs/NRCELs energy saving state check passed for energy saving period ${i+1} [OK]\n  console=true
        Log  Test enters pause until PSGRP/NRPGRP energy saving period ${i+1} ends\n  console=true
        Sleep Until Given Date  ${FINISH_TIMES[${i}]}
        Log  Check if the LNCELs/NRCELs returned to NOTENERGYSAVING state\n  console=true
        @{expected_states}  Create List  ENABLED  NOTENERGYSAVING
        Wait For Specific Cell To Reach Expected States  LNCEL  ${SELECTED_LTES}  1min  15s  ${states_to_check}  ${expected_states}
        Wait For Specific Cell To Reach Expected States  NRCEL  ${SELECTED_NRS}  1min  15s  ${states_to_check}  ${expected_states}
        Log  LNCELs/NRCELs successfully returned to NOTENERGYSAVING for energy saving period ${i+1} [OK]\n  console=true
    END


PS.75_LTE1103_5GC000431_Multiple_Energy_Saving_Cell_Switch_Off_Switch_On_Transitions.Test Specific Teardown
    Log To Console  \n============ SPECIFIC TEST TEARDOWN =============
    Set Feature Under Given Object  ${LNBTS_DistName}  actLBPowerSaving  false
    Set Feature Under Given Object  ${LNBTS_DistName}  actLbpsCtrlLogicEnh  false
    Set Feature Under Given Object  ${LNBTS_DistName}  shutdownWindow  180
    Set Feature Under Given Object  ${NRBTS_DistName}  actNrLBPowerSaving  false
    Set Feature Under Given Object  ${NRBTS_DistName}  actLbpsCtrlLogicEnh  false
    Set Feature Under Given Object  ${NRBTS_DistName}  shutdownWindow  180
    Log  Deleting any old PSGRP that was already on the BTS\n  console=true
    Remove Old PSGRP Objects If Present
    Log  Deleting any old NRPGRP that was already on the BTS\n  console=true
    Remove Old NRPGRP Objects If Present
    @{states_to_check}  Create List  operationalState  energySavingState
    @{expected_states}  Create List  ENABLED  NOTENERGYSAVING
    FOR  ${lte_cell_id}  ${nr_cell_id}  IN ZIP  ${SELECTED_LTES}  ${SELECTED_NRS}
        Check Cell States For Specific Cell  LNCEL  ${lte_cell_id}  ${states_to_check}  ${expected_states}
        Check Cell States For Specific Cell  NRCEL  ${nr_cell_id}  ${states_to_check}  ${expected_states}
    END
    Log  LNCELs/NRCELs are in correct energy saving state [OK]\n  console=true
    Log  Check eNB is onAir\n  console=true
    @{states_to_check}  Create List  availabilityStatus  administrativeState  blockingState
    @{expected_states}  Create List  -  UNLOCKED  UNBLOCKED
    FOR  ${lte_cell_id}  ${nr_cell_id}  IN ZIP  ${LTE_IDS}  ${NR_IDS}
        Check Cell States For Specific Cell  LNCEL  ${lte_cell_id}  ${states_to_check}  ${expected_states}
        Check Cell States For Specific Cell  NRCEL  ${nr_cell_id}  ${states_to_check}  ${expected_states}
    END
    Log  Check if any unexpected alarm occured\n  console=true
    Check If Unexpected Alarms Are Raised  ${skip_fault}
    Log To Console  ========== SPECIFIC TEST TEARDOWN DONE ==========\n


PS.75_LTE1103_5GC000431_Multiple_Energy_Saving_Cell_Switch_Off_Switch_On_Transitions.Test Case Teardown
    PS.75_LTE1103_5GC000431_Multiple_Energy_Saving_Cell_Switch_Off_Switch_On_Transitions.Test Specific Teardown
    Common Test Teardown