*** Settings ***
Resource    ../../../resources/common.robot
Resource    ../../../resources/alarms.robot
Resource    ../../../resources/power_saving.robot

Documentation
...  TEST NAME:     PS.74_CNI130232_PS_Suspend_Load_Based_Reduced_Tx_Path
...  AUTHORS:       victor.banicioiu@nokia.com
...  MAINTAINER:    TIM_5_Vrf    victor.banicioiu@nokia.com
...  *****************
...  Basic information
...  *****************
...  Test checks system behaviour when power saving period is suspended and MIMO muting enabled.
...  *****************
...  Pre-conditions
...  *****************
...  eNB is in operational On Air state.
...  ******************
...  History of changes
...  ******************
...  29.08.2025 - https://jiradc.ext.net.nokia.com/browse/TAT-29802 - TC creation
...  *******************


*** Variables ***
${LBPS_CELL_DURATION}    30


*** Keywords ***
PS.74_CNI130232_PS_Suspend_Load_Based_Reduced_Tx_Path
    PS.74_CNI130232_PS_Suspend_Load_Based_Reduced_Tx_Path.Step 0: Preparing Environment
    PS.74_CNI130232_PS_Suspend_Load_Based_Reduced_Tx_Path.Step 1: Creating And Activating The PSGRP
    PS.74_CNI130232_PS_Suspend_Load_Based_Reduced_Tx_Path.Step 2: Suspend Power Saving Period And Check Cell States
    PS.74_CNI130232_PS_Suspend_Load_Based_Reduced_Tx_Path.Step 3: Change Switch Off Order To 100 For All Cells
    PS.74_CNI130232_PS_Suspend_Load_Based_Reduced_Tx_Path.Step 4: Suspend Power Saving Period And Check Cell States


PS.74_CNI130232_PS_Suspend_Load_Based_Reduced_Tx_Path.Step 0: Preparing Environment
    Log  \n========================================  console=true
    Log  Step 0: Preparing Environment\n  console=true
    Log  ========================================  console=true
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


PS.74_CNI130232_PS_Suspend_Load_Based_Reduced_Tx_Path.Step 1: Creating And Activating The PSGRP
    Log  \n========================================  console=true
    Log  Step 1: Creating And Activating The PSGRP\n  console=true
    Log  ========================================  console=true
    Remove Old PSGRP Objects If Present
    Set Feature Under Given Object  ${LNBTS_DistName}  actLBRTXPowerSaving  true
	Set Feature Under Given Object  ${LNBTS_DistName}  actLBPowerSaving  false
    Set Feature Under Given Object  ${LNBTS_DistName}  actOnlineTXSwitch  false
    Get Time And Date With Minute Offset  5minutes
    Log  Create and activate PSGRP-0\n  console=true
    ${standalone_params}  Create Dictionary
    Set To Dictionary  ${standalone_params}  name  standalone
    Set To Dictionary  ${standalone_params}  lbpsLastCellRTXMinLoad  10
    Set To Dictionary  ${standalone_params}  lbpsLastCellSOEnabled  true
    Set To Dictionary  ${standalone_params}  lbpsRTXCellCapOffset  80
    Set To Dictionary  ${standalone_params}  lbpsRTXMaxLoad  50
    Set To Dictionary  ${standalone_params}  lbpsRTXMinLoad  20
    ${cell_1}  Create Dictionary  name=lbpsCellList  lbpsCellSOOrder=10  lbpsUseExtConfig=false  lnCelId=${SELECTED_LTES[0]}
    ${cell_2}  Create Dictionary  name=lbpsCellList  lbpsCellSOOrder=20  lbpsUseExtConfig=false  lnCelId=${SELECTED_LTES[1]}
    ${cell_3}  Create Dictionary  name=lbpsCellList  lbpsCellSOOrder=100  lbpsUseExtConfig=false  lnCelId=${SELECTED_LTES[2]}
    ${cell_4}  Create Dictionary  name=lbpsCellList  lbpsCellSOOrder=100  lbpsUseExtConfig=false  lnCelId=${SELECTED_LTES[3]}
    @{cell_list}  Create List  ${cell_1}  ${cell_2}  ${cell_3}  ${cell_4}
    ${lbpsPeriodList}  Create Dictionary
    Set To Dictionary  ${lbpsPeriodList}  name=lbpsPeriodList
    Set To Dictionary  ${lbpsPeriodList}  lbpsDayOfWeek=${day}
    Set To Dictionary  ${lbpsPeriodList}  lbpsDuration=${SWITCH_OFF_DURATION}
    Set To Dictionary  ${lbpsPeriodList}  lbpsStartTimeHour=${start_hour}
    Set To Dictionary  ${lbpsPeriodList}  lbpsStartTimeMinute=${start_minutes}
    Create And Activate PSGRP  0  ${standalone_params}  ${cell_list}  ${lbpsPeriodList}
    Log  Test enters pause until PSGRP time window starts\n  console=true
    Sleep Until Given Date  ${TIME_WITH_OFFSET_PSGRP}
    Log  Check if the LNCELs entered reduced energy saving state in max 27min\n  console=true
    @{states_to_check}  Create List  operationalState  energySavingState
    @{expected_states}  Create List  ENABLED  REDUCEDENERGYSAVING
    Wait For Specific Cell To Reach Expected States  LNCEL  ${SELECTED_LTES}  27min  1min  ${states_to_check}  ${expected_states}
    Log  LNCELs energy saving state check is concluded!\n  console=true


PS.74_CNI130232_PS_Suspend_Load_Based_Reduced_Tx_Path.Step ${i}: Suspend Power Saving Period And Check Cell States
    Log  \n========================================  console=true
    Log  Step ${i}: Suspend Power Saving Period And Check Cell States\n  console=true
    Log  ========================================  console=true
    ${lbps_period_list}  Create Dictionary
    Set To Dictionary  ${lbps_period_list}  name  lbpsPeriodList
    Set To Dictionary  ${lbps_period_list}  lbpsDayOfWeek  ${day}
    Set To Dictionary  ${lbps_period_list}  lbpsDuration  ${SWITCH_OFF_DURATION}
    Set To Dictionary  ${lbps_period_list}  lbpsStartTimeHour  ${start_hour}
    Set To Dictionary  ${lbps_period_list}  lbpsStartTimeMinute  ${start_minutes}
    Set To Dictionary  ${lbps_period_list}  lbpsSuspended  suspended
    Reconfigure Energy Saving Group  PSGRP  0  ${lbps_period_list}
    Log  Check if the LNCELs returned to not energy saving states\n  console=true
    Check One Cell Has Delayed Switch On


PS.74_CNI130232_PS_Suspend_Load_Based_Reduced_Tx_Path.Step 3: Change Switch Off Order To 100 For All Cells
    Log  \n========================================  console=true
    Log  Step 3: Change Switch Off Order To 100 For All Cells\n  console=true
    Log  ========================================  console=true
    ${cell_list}  Create List
    FOR  ${i}  IN RANGE  0  4
        ${cell}  Create Dictionary  name=lbpsCellList  lbpsCellSOOrder=100  lbpsUseExtConfig=false  lnCelId=${SELECTED_LTES[${i}]}
        Append To List  ${cell_list}  ${cell}
    END
    ${lbps_period_list}  Create Dictionary
    Set To Dictionary  ${lbps_period_list}  name  lbpsPeriodList
    Set To Dictionary  ${lbps_period_list}  lbpsDayOfWeek  ${day}
    Set To Dictionary  ${lbps_period_list}  lbpsDuration  ${SWITCH_OFF_DURATION}
    Set To Dictionary  ${lbps_period_list}  lbpsStartTimeHour  ${start_hour}
    Set To Dictionary  ${lbps_period_list}  lbpsStartTimeMinute  ${start_minutes}
    Set To Dictionary  ${lbps_period_list}  lbpsSuspended  notSuspended
    Reconfigure Energy Saving Group  PSGRP  0  ${cell_list}  ${lbps_period_list}
    Log  Check if cell switch off order updated successfully for all cells\n  console=true
    ${lbps_cell_list}  Get Specific Parameter From Existing Group  PSGRP  0  lbpsCellList
    FOR  ${cell}  IN  @{lbps_cell_list}
        ${so_order}  Get From Dictionary  ${cell}  lbpsCellSOOrder
        ${id}  Get From Dictionary  ${cell}  lnCelId
        IF  not '${so_order}'=='100'
            Fail  Switch off order has not updated for cell ${id}
        END
        Log  Switch off order for cell ${id} is ${so_order}\n  console=true
    END
    Log  Check if the LNCELs entered reduced energy saving state in max 5min\n  console=true
    @{states_to_check}  Create List  operationalState  energySavingState
    @{expected_states}  Create List  ENABLED  REDUCEDENERGYSAVING
    Wait For Specific Cell To Reach Expected States  LNCEL  ${SELECTED_LTES}  35min  1min  ${states_to_check}  ${expected_states}
    Log  LNCELs energy saving state check is concluded!\n  console=true


PS.74_CNI130232_PS_Suspend_Load_Based_Reduced_Tx_Path.Test Specific Teardown
    Log To Console  \n============ SPECIFIC TEST TEARDOWN =============
    Log  Set actLBRTXPowerSaving back on false\n  console=true
    Set Feature Under Given Object  ${LNBTS_DistName}  actLBRTXPowerSaving  false
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


PS.74_CNI130232_PS_Suspend_Load_Based_Reduced_Tx_Path.Test Case Teardown
    PS.74_CNI130232_PS_Suspend_Load_Based_Reduced_Tx_Path.Test Specific Teardown
    Common Test Teardown



Check One Cell Has Delayed Switch On
    @{states_to_check}  Create List  operationalState  energySavingState
    @{expected_states}  Create List  ENABLED  SWITCHINGONTX
    Sleep  30  Wait for the first three cells to get to SWITCHINGONTX and last cell still in RES
    ${slow_cell}  Set Variable  0
    FOR  ${i}  IN RANGE  0  4
        ${is_not_energy_saving}  Run Keyword And Return Status
        ...  Check Cell States For Specific Cell  LNCEL  ${SELECTED_LTES[${i}]}  ${states_to_check}  ${expected_states}
        ${slow_cell}  Set Variable If  not ${is_not_energy_saving}  ${SELECTED_LTES[${i}]}  ${slow_cell}
        IF  not ${is_not_energy_saving}  Log  Cell ${slow_cell} is the cell delayed\n  console=true
    END
    Log  Three cells exited energy saving and one is delayed\n  console=true
    Sleep  240  Wait for last cell delayed Tx switch on
    Check Cell States For Specific Cell  LNCEL  ${slow_cell}  ${states_to_check}  ${expected_states}