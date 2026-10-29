*** Settings ***
Resource    ../../../resources/common.robot
Resource    ../../../resources/alarms.robot
Resource    ../../../resources/power_saving.robot

Documentation
...  TEST NAME:     PS.73_CNI130232_PS_Handle_Power_Saving_Configuration_Change
...  AUTHORS:       victor.banicioiu@nokia.com
...  MAINTAINER:    TIM_5_Vrf    victor.banicioiu@nokia.com
...  *****************
...  Basic information
...  *****************
...  Test checks system behaviour when power saving configuration changes (MIMO muting or cell switch off power saving enabled).
...  *****************
...  Pre-conditions
...  *****************
...  eNB is in operational On Air state.
...  actLBRTXPowerSaving = false & actLBPowerSaving = false
...  ******************
...  History of changes
...  ******************
...  29.08.2025 - https://jiradc.ext.net.nokia.com/browse/TAT-29800 - TC creation
...  *******************


*** Variables ***
${LBPS_CELL_DURATION}    30


*** Keywords ***
PS.73_CNI130232_PS_Handle_Power_Saving_Configuration_Change
    PS.73_CNI130232_PS_Handle_Power_Saving_Configuration_Change.Step 0: Preparing Environment
    PS.73_CNI130232_PS_Handle_Power_Saving_Configuration_Change.Step 1: Creating And Activating The PSGRP
    PS.73_CNI130232_PS_Handle_Power_Saving_Configuration_Change.Step 2: Change Cell List For PSGRP
    PS.73_CNI130232_PS_Handle_Power_Saving_Configuration_Change.Step 3: Activate LTE1103 And Check Cell States
    PS.73_CNI130232_PS_Handle_Power_Saving_Configuration_Change.Step 4: Activate CB008800 And Check Cell States
    PS.73_CNI130232_PS_Handle_Power_Saving_Configuration_Change.Step 5: Configure Cell Period List For PSGRP
    PS.73_CNI130232_PS_Handle_Power_Saving_Configuration_Change.Step 6: Modify Cell Period List For PSGRP


PS.73_CNI130232_PS_Handle_Power_Saving_Configuration_Change.Step 0: Preparing Environment
    Log  \n========================================  console=true
    Log  Step 0: Preparing Environment\n  console=true
    Log  ========================================  console=true
    @{FEATURE_FLAGS}  Create List  actLBRTXPowerSaving  actLBPowerSaving
    Set Test Variable  ${FEATURE_FLAGS}
    Set Feature Under Given Object  ${LNBTS_DistName}  ${FEATURE_FLAGS}  false
    ${LNBTS_ID}  Get LNBTS ID
    Set Test Variable  ${LNBTS_ID}
    ${LTE_IDS}  Get LNCEL ID List Without IoT Cells
    Set Test Variable  ${LTE_IDS}
    @{states_to_check}  Create List  availabilityStatus  administrativeState  blockingState
    @{expected_states}  Create List  -  UNLOCKED  UNBLOCKED
    FOR  ${cell_id}  IN  @{LTE_IDS}
        Check Cell States For Specific Cell  LNCEL  ${cell_id}  ${states_to_check}  ${expected_states}
    END
    ${nr_of_cells}  Get Length  ${LTE_IDS}
    IF  ${nr_of_cells} >= 4
        ${SELECTED_LTES}  Create List
        FOR  ${i}  IN RANGE  0  4
            ${cell_id}  Fetch From Right  ${LTE_IDS[${i}]}  -
            Append To List  ${SELECTED_LTES}  ${cell_id}
        END
        Set Test Variable  ${SELECTED_LTES}
    ELSE
        Log  Insufficient LTE cells number (lower than 4). Test cannot continue.\n  level=WARN  console=true
        Fail  Not enough LTE cells available for the test!
    END


PS.73_CNI130232_PS_Handle_Power_Saving_Configuration_Change.Step 1: Creating And Activating The PSGRP
    Log  \n========================================  console=true
    Log  Step 1: Creating And Activating The PSGRP\n  console=true
    Log  ========================================  console=true
    Remove Old PSGRP Objects If Present
    Set Feature Under Given Object  ${LNBTS_DistName}  actLBRTXPowerSaving  true
    Set Feature Under Given Object  ${LNBTS_DistName}  actOnlineTXSwitch  false
    Get Time And Date With Minute Offset  5minutes
    Log  Create PSGRP-0\n  console=true
    ${standalone_params}  Create Dictionary
    Set To Dictionary  ${standalone_params}  name  standalone
    Set To Dictionary  ${standalone_params}  lbpsLastCellRTXMinLoad  10
    Set To Dictionary  ${standalone_params}  lbpsLastCellSOEnabled  true
    Set To Dictionary  ${standalone_params}  lbpsMaxLoad  30
    Set To Dictionary  ${standalone_params}  lbpsPdcchLoadOffset  80
    Set To Dictionary  ${standalone_params}  lbpsRTXCellCapOffset  80
    Set To Dictionary  ${standalone_params}  lbpsRTXMaxLoad  40
    Set To Dictionary  ${standalone_params}  lbpsRTXMinLoad  15
    ${cell_1}  Create Dictionary  name=lbpsCellList  lbpsCellSOOrder=10  lbpsUseExtConfig=false  lnCelId=${SELECTED_LTES[0]}
    ${cell_2}  Create Dictionary  name=lbpsCellList  lbpsCellSOOrder=20  lbpsUseExtConfig=false  lnCelId=${SELECTED_LTES[1]}
    ${cell_3}  Create Dictionary  name=lbpsCellList  lbpsCellSOOrder=100  lbpsUseExtConfig=false  lnCelId=${SELECTED_LTES[2]}
    @{cell_list}  Create List  ${cell_1}  ${cell_2}  ${cell_3}
    ${lbpsPeriodList}  Create Dictionary
    Set To Dictionary  ${lbpsPeriodList}  name=lbpsPeriodList
    Set To Dictionary  ${lbpsPeriodList}  lbpsDayOfWeek=${day}
    Set To Dictionary  ${lbpsPeriodList}  lbpsDuration=${SWITCH_OFF_DURATION}
    Set To Dictionary  ${lbpsPeriodList}  lbpsStartTimeHour=${start_hour}
    Set To Dictionary  ${lbpsPeriodList}  lbpsStartTimeMinute=${start_minutes}
    Create And Activate PSGRP  0  ${standalone_params}  ${cell_list}  ${lbpsPeriodList}
    Log  Test enters pause until PSGRP time window starts\n  console=true
    Sleep Until Given Date  ${TIME_WITH_OFFSET_PSGRP}
    Log  Check if the LNCELs entered reduced energy saving state in max 30min\n  console=true
    @{states_to_check}  Create List  operationalState  energySavingState
    @{expected_states}  Create List  ENABLED  REDUCEDENERGYSAVING
    ${SPARE_CELL}  Get From List  ${SELECTED_LTES}  3
    Set Test Variable  ${SPARE_CELL}
    Remove From List  ${SELECTED_LTES}  3
    Wait For Specific Cell To Reach Expected States  LNCEL  ${SELECTED_LTES}  30min  1min  ${states_to_check}  ${expected_states}
    Log  LNCELs energy saving state check is concluded!\n  console=true


PS.73_CNI130232_PS_Handle_Power_Saving_Configuration_Change.Step 2: Change Cell List For PSGRP
    Log  \n========================================  console=true
    Log  Step 2: Change Cell List For PSGRP\n  console=true
    Log  ========================================  console=true
    Log  Removing cell ${SELECTED_LTES[0]} from PSGRP\n  console=true
    ${cell_list}  Create List  ${SELECTED_LTES[0]}
    Modify Cell Composition Of Group  PSGRP  ${cell_list}  0  REMOVE
    Log  Check if ${SELECTED_LTES[0]} was successfully removed from PSGRP-0\n  console=true
    ${psgrp_cells}  Get Cell IDs From Group  PSGRP  0
    ${search_value_int}  Convert To Integer  ${SELECTED_LTES[0]}
    List Should Not Contain Value  ${psgrp_cells}  ${search_value_int}
    Log  Cell was successfully removed!\n  console=true
    Log  Adding cell ${SPARE_CELL} to PSGRP\n  console=true
    ${so_order}  Create List  10
    ${cell_list}  Create List  ${SPARE_CELL}
    Modify Cell Composition Of Group  PSGRP  ${cell_list}  0  ADD  ${so_order}
    ${psgrp_cells}  Get Cell IDs From Group  PSGRP  0
    ${search_value_int}  Convert To Integer  ${SPARE_CELL}
    List Should Contain Value  ${psgrp_cells}  ${search_value_int}
    Append To List  ${SELECTED_LTES}  ${SPARE_CELL}
    Log  Cell was successfully added!\n  console=true
    Log  Check if the LNCELs returned to not energy saving state in max 7 min\n  console=true
    @{states_to_check}  Create List  operationalState  energySavingState
    @{expected_states}  Create List  ENABLED  NOTENERGYSAVING
    Wait For Specific Cell To Reach Expected States  LNCEL  ${SELECTED_LTES}  10min  30sec  ${states_to_check}  ${expected_states}
    Remove From List  ${SELECTED_LTES}  0
    Log  Check if the LNCELs entered reduced energy saving state in max 26min\n  console=true
    @{expected_states}  Create List  ENABLED  REDUCEDENERGYSAVING
    Wait For Specific Cell To Reach Expected States  LNCEL  ${SELECTED_LTES}  26min  1min  ${states_to_check}  ${expected_states}


PS.73_CNI130232_PS_Handle_Power_Saving_Configuration_Change.Step 3: Activate LTE1103 And Check Cell States
    Log  \n========================================  console=true
    Log  Step 3: Activate LTE1103 And Check Cell States\n  console=true
    Log  ========================================  console=true
    Log  Activate feature flag actLBPowerSaving for LTE1103\n  console=true
    Set Feature Under Given Object  ${LNBTS_DistName}  actLBPowerSaving  true
    Log  Check if the LNCELs returned to not energy saving state in max 7 min\n  console=true
    @{states_to_check}  Create List  operationalState  energySavingState
    @{expected_states}  Create List  ENABLED  NOTENERGYSAVING
    Wait For Specific Cell To Reach Expected States  LNCEL  ${SELECTED_LTES}  7min  30sec  ${states_to_check}  ${expected_states}
    Log  Check if cells re-entered energy saving state and reduced energy saving state\n  console=true
    @{expected_states}  Create List  ENABLED  REDUCEDENERGYSAVING
    Wait For Specific Cell To Reach Expected States  LNCEL  ${SELECTED_LTES[1]}  26min  1min  ${states_to_check}  ${expected_states}
    @{expected_states}  Create List  DISABLED  ENERGYSAVING
    Check Cell States For Specific Cell  LNCEL  ${SELECTED_LTES[2]}  ${states_to_check}  ${expected_states}
    Check Cell States For Specific Cell  LNCEL  ${SELECTED_LTES[0]}  ${states_to_check}  ${expected_states}


PS.73_CNI130232_PS_Handle_Power_Saving_Configuration_Change.Step 4: Activate CB008800 And Check Cell States
    Log  \n========================================  console=true
    Log  Step 4: Activate CB008800 And Check Cell States\n  console=true
    Log  ========================================  console=true
    Log  Activate feature flag actExtCellSOMethod for CB008800\n  console=true
    Set Feature Under Given Object  ${LNBTS_DistName}  actExtCellSOMethod  true
    Log  Check if the LNCELs returned to not energy saving state\n  console=true
    Check One Cell Has Delayed Switch On TC73  ${SELECTED_LTES}


PS.73_CNI130232_PS_Handle_Power_Saving_Configuration_Change.Step 5: Configure Cell Period List For PSGRP
    Log  \n========================================  console=true
    Log  Step 5: Configure Cell Period List For PSGRP\n  console=true
    Log  ========================================  console=true
    Get Time And Date With Minute Offset  1minute
    ${cell_period_1}  Create Dictionary  name=lbpsCelPeriodList  lbpsCellDayOfWeek=${day}  lbpsCellDuration=${LBPS_CELL_DURATION}
    ...  lbpsCellSOMethod=Cell Switch Off  lbpsCellStartTimeHour=${start_hour}  lbpsCellStartTimeMinute=${start_minutes}
    ...  lnCelId=${SELECTED_LTES[2]}
    ${cell_period_2}  Create Dictionary  name=lbpsCelPeriodList  lbpsCellDayOfWeek=${day}  lbpsCellDuration=${LBPS_CELL_DURATION}
    ...  lbpsCellSOMethod=Cell Switch Off  lbpsCellStartTimeHour=${start_hour}  lbpsCellStartTimeMinute=${start_minutes}
    ...  lnCelId=${SELECTED_LTES[0]}
    ${cell_period_3}  Create Dictionary  name=lbpsCelPeriodList  lbpsCellDayOfWeek=${day}  lbpsCellDuration=${LBPS_CELL_DURATION}
    ...  lbpsCellSOMethod=Tx Paths Switch Off  lbpsCellStartTimeHour=${start_hour}  lbpsCellStartTimeMinute=${start_minutes}
    ...  lnCelId=${SELECTED_LTES[1]}
    @{cell_list}  Create List  ${cell_period_1}  ${cell_period_2}  ${cell_period_3}
    Reconfigure Energy Saving Group  PSGRP  0  @{cell_list}
    Log  Check if the LNCELs returned to energy saving states\n  console=true
    @{states_to_check}  Create List  operationalState  energySavingState
    @{expected_states}  Create List  ENABLED  REDUCEDENERGYSAVING
    Wait For Specific Cell To Reach Expected States  LNCEL  ${SELECTED_LTES[1]}  26min  1min  ${states_to_check}  ${expected_states}
    @{expected_states}  Create List  DISABLED  ENERGYSAVING
    Check Cell States For Specific Cell  LNCEL  ${SELECTED_LTES[2]}  ${states_to_check}  ${expected_states}
    Check Cell States For Specific Cell  LNCEL  ${SELECTED_LTES[0]}  ${states_to_check}  ${expected_states}


PS.73_CNI130232_PS_Handle_Power_Saving_Configuration_Change.Step 6: Modify Cell Period List For PSGRP
    Log  \n========================================  console=true
    Log  Step 6: Modify Cell Period List For PSGRP\n  console=true
    Log  ========================================  console=true
    Log  Remove cell ${SELECTED_LTES[2]} from lbpsCelPeriodList\n  console=true
    ${cell_period_1}  Create Dictionary  name=lbpsCelPeriodList  lbpsCellDayOfWeek=${day}  lbpsCellDuration=${LBPS_CELL_DURATION}
    ...  lbpsCellSOMethod=Cell Switch Off  lbpsCellStartTimeHour=${start_hour}  lbpsCellStartTimeMinute=${start_minutes}
    ...  lnCelId=${SELECTED_LTES[0]}
    ${cell_period_2}  Create Dictionary  name=lbpsCelPeriodList  lbpsCellDayOfWeek=${day}  lbpsCellDuration=${LBPS_CELL_DURATION}
    ...  lbpsCellSOMethod=Tx Paths Switch Off  lbpsCellStartTimeHour=${start_hour}  lbpsCellStartTimeMinute=${start_minutes}
    ...  lnCelId=${SELECTED_LTES[1]}
    @{cell_list}  Create List  ${cell_period_1}  ${cell_period_2}
    Reconfigure Energy Saving Group  PSGRP  0  @{cell_list}
    Log  Check if the LNCELs returned to energy saving states\n  console=true
    Check One Cell Has Delayed Switch On TC73  ${SELECTED_LTES}


PS.73_CNI130232_PS_Handle_Power_Saving_Configuration_Change.Test Specific Teardown
    Log To Console  \n============ SPECIFIC TEST TEARDOWN =============
    Log  Set actLBRTXPowerSaving and actLBPowerSaving back on false\n  console=true
    Set Feature Under Given Object  ${LNBTS_DistName}  ${FEATURE_FLAGS}  false
    Log  Set actExtCellSOMethod back on false\n  console=true
    Set Feature Under Given Object  ${LNBTS_DistName}  actExtCellSOMethod  false
    Log  Deleting any old PSGRP that was already on the BTS\n  console=true
    Remove Old PSGRP Objects If Present
    Log  Check eNB is onAir\n  console=true
    @{states_to_check}  Create List  availabilityStatus  administrativeState  blockingState
    @{expected_states}  Create List  -  UNLOCKED  UNBLOCKED
    FOR  ${cell_id}  IN  @{LTE_IDS}
        Check Cell States For Specific Cell  LNCEL  ${cell_id}  ${states_to_check}  ${expected_states}
    END
    Log  Check if any unexpected alarm occured\n  console=true
    Check If Unexpected Alarms Are Raised  ${skip_fault}
    Log To Console  ========== SPECIFIC TEST TEARDOWN DONE ==========\n


PS.73_CNI130232_PS_Handle_Power_Saving_Configuration_Change.Test Case Teardown
    PS.73_CNI130232_PS_Handle_Power_Saving_Configuration_Change.Test Specific Teardown
    Common Test Teardown


Check One Cell Has Delayed Switch On TC73
    [Arguments]  ${cell_list}

    ${nr_of_cells}  Get Length  ${cell_list}
    @{states_to_check}  Create List  operationalState  energySavingState
    @{expected_states}  Create List  ENABLED  NOTENERGYSAVING
    Sleep  30  Wait for the first three cells to get to NOTENERGYSAVING and last cell still in SWITCHINGONTX
    ${slow_cell}  Set Variable  0
    FOR  ${i}  IN RANGE  0  ${nr_of_cells}
        ${is_not_energy_saving}  Run Keyword And Return Status
        ...  Check Cell States For Specific Cell  LNCEL  ${cell_list[${i}]}  ${states_to_check}  ${expected_states}
        ${slow_cell}  Set Variable If  not ${is_not_energy_saving}  ${cell_list[${i}]}  ${slow_cell}
        IF  not ${is_not_energy_saving}  Log  Cell ${slow_cell} is the cell delayed\n  console=true
    END
    IF  '${slow_cell}'=='0'  Fail  No cell delay observed in exiting energy saving
    Log  All but one cell exited energy saving and one is delayed\n  console=true
    Sleep  240  Wait for last cell delayed Tx switch on
    Check Cell States For Specific Cell  LNCEL  ${slow_cell}  ${states_to_check}  ${expected_states}

