*** Settings ***
Resource    ../../../resources/common.robot
Resource    ../../../resources/alarms.robot
Resource    ../../../resources/power_saving.robot

Documentation
...  TEST NAME:     PS.77_LTE1103_LTE1203_S1_Link_Break_With_Cells_In_EnergySaving_And_ReducedES
...  AUTHORS:       victor.banicioiu@nokia.com
...  MAINTAINER:    TIM_5_Vrf    victor.banicioiu@nokia.com
...  *****************
...  Basic information
...  *****************
...  The test scope is to check LTE1103 and LTE1203 features behavior when S1 link is unavailable (EDA action for case 04504202)
...  *****************
...  Pre-conditions
...  *****************
...  On-Air running eNB with no alarms.
...  ******************
...  History of changes
...  ******************
...  14.10.2025 - https://jiradc.ext.net.nokia.com/browse/TAT-30025 - TC creation
...  *******************


*** Keywords ***
PS.77_LTE1103_LTE1203_S1_Link_Break_With_Cells_In_EnergySaving_And_ReducedES
    PS.77_LTE1103_LTE1203_S1_Link_Break_With_Cells_In_EnergySaving_And_ReducedES.Step 0: Preparing Environment
    PS.77_LTE1103_LTE1203_S1_Link_Break_With_Cells_In_EnergySaving_And_ReducedES.Step 1: Create And Activate PSGRP
    PS.77_LTE1103_LTE1203_S1_Link_Break_With_Cells_In_EnergySaving_And_ReducedES.Step 2: Break S1 Link First Time
    PS.77_LTE1103_LTE1203_S1_Link_Break_With_Cells_In_EnergySaving_And_ReducedES.Step 3: Reestablish S1 Link When ES Window Is Active
    PS.77_LTE1103_LTE1203_S1_Link_Break_With_Cells_In_EnergySaving_And_ReducedES.Step 4: Break S1 Link When ES Window Is Active
    PS.77_LTE1103_LTE1203_S1_Link_Break_With_Cells_In_EnergySaving_And_ReducedES.Step 5: Reestablish S1 Link When ES Window Is Active
    PS.77_LTE1103_LTE1203_S1_Link_Break_With_Cells_In_EnergySaving_And_ReducedES.Step 6: Break S1 Link When ES Window Is Active
    PS.77_LTE1103_LTE1203_S1_Link_Break_With_Cells_In_EnergySaving_And_ReducedES.Step 7: Check Cells After Power Saving Window Ends
    PS.77_LTE1103_LTE1203_S1_Link_Break_With_Cells_In_EnergySaving_And_ReducedES.Step 8: Reestablish S1 Link Without ES Window


PS.77_LTE1103_LTE1203_S1_Link_Break_With_Cells_In_EnergySaving_And_ReducedES.Step 0: Preparing Environment
    Log  \n========================================  console=true
    Log  Step 0: Preparing Environment\n  console=true
    Log  ========================================  console=true
    watchdog.Allow Alarm  fault_id=6202
    ${LNBTS_ID}  Get LNBTS ID
    Set Test Variable  ${LNBTS_ID}
    ${LTE_IDS}  Get LNCEL ID List Without IoT Cells
    Set Test Variable  ${LTE_IDS}
    ${S1_CELL_DEACT_DELAY}  Get Specific Parameter Value From LNBTS  s1InducedCellDeactDelayTime
    Set Test Variable  ${S1_CELL_DEACT_DELAY}
    ${int_value}  Convert To Integer  ${S1_CELL_DEACT_DELAY}
    IF  ${int_value} > 1  Set Feature Under Given Object  ${LNBTS_DistName}  s1InducedCellDeactDelayTime  1
    ${lnmme_params}  admin.Get Parameters For All  class_name=LNMME
    ${INIT_PRIM_IP_ADDR}  Set Variable  ${lnmme_params[0]['ipAddrPrim']}
    Set Test Variable  ${INIT_PRIM_IP_ADDR}
    ${lnmme_id}  Fetch From Right    ${lnmme_params[0]['id']}    -
    ${LNMME_DN}    Set Variable    MRBTS-${MRBTS_ID}/LNBTS-${LNBTS_ID}/LNMME-${lnmme_id}
    Set Test Variable  ${LNMME_DN}
    @{states_to_check}  Create List  availabilityStatus  administrativeState  blockingState
    @{expected_states}  Create List  -  UNLOCKED  UNBLOCKED
    FOR  ${cell_id}  IN  @{LTE_IDS}
        Check Cell States For Specific Cell  LNCEL  ${cell_id}  ${states_to_check}  ${expected_states}
    END
    ${nr_of_lte_cells}  Get Length  ${LTE_IDS}
    IF  ${nr_of_lte_cells} >= 2
        ${SELECTED_LTES}  Create List
        FOR  ${i}  IN RANGE  0  2
            ${lte_cell_id}  Fetch From Right  ${LTE_IDS[${i}]}  -
            Append To List  ${SELECTED_LTES}  ${lte_cell_id}
        END
        Set Test Variable  ${SELECTED_LTES}
    ELSE
        Log  Insufficient LTE cells number (lower than 2). Test cannot continue.\n  level=ERROR  console=true
        Fail  Not enough LTE cells available for the test!
    END


PS.77_LTE1103_LTE1203_S1_Link_Break_With_Cells_In_EnergySaving_And_ReducedES.Step 1: Create And Activate PSGRP
    Log  \n========================================  console=true
    Log  Step 1: Create And Activate PSGRP\n  console=true
    Log  ========================================  console=true
    Remove Old PSGRP Objects If Present
    Set Feature Under Given Object  ${LNBTS_DistName}  actLBPowerSaving  true
    Set Feature Under Given Object  ${LNBTS_DistName}  actLBRTXPowerSaving  true
    Set Feature Under Given Object  ${LNBTS_DistName}  actOnlineTXSwitch  true
    Set Feature Under Given Object  ${LNBTS_DistName}  shutdownWindow  180
    Log  Create and activate PSGRP-0 and NRPGRP-0\n  console=true
    ${standalone_params_psgrp}  Create Dictionary
    Set To Dictionary  ${standalone_params_psgrp}  name  standalone
    Set To Dictionary  ${standalone_params_psgrp}  lbpsLastCellSOEnabled  true
    Set To Dictionary  ${standalone_params_psgrp}  lbpsMonWinForCellSOff  120
    Set To Dictionary  ${standalone_params_psgrp}  lbpsMonWinForRtxSOff  120
    Set To Dictionary  ${standalone_params_psgrp}  lbpsLastCellMinLoad  20
    Set To Dictionary  ${standalone_params_psgrp}  lbpsRTXMaxLoad  60
    Set To Dictionary  ${standalone_params_psgrp}  lbpsMaxLoad  60
    Set To Dictionary  ${standalone_params_psgrp}  lbpsMinLoad  20
    Set To Dictionary  ${standalone_params_psgrp}  lbpsRTXMinLoad  20
    Set To Dictionary  ${standalone_params_psgrp}  lbpsLastCellRTXMinLoad  20
    Set To Dictionary  ${standalone_params_psgrp}  lbpsSOMethod  Legacy Mixed Switch Off
    ${cell_1}  Create Dictionary  name=lbpsCellList  lbpsCellSOOrder=20  lbpsUseExtConfig=false  lnCelId=${SELECTED_LTES[0]}
    ${cell_2}  Create Dictionary  name=lbpsCellList  lbpsCellSOOrder=30  lbpsUseExtConfig=false  lnCelId=${SELECTED_LTES[1]}
    @{cell_list_psgrp}  Create List  ${cell_1}  ${cell_2}
    Get Time And Date With Minute Offset  5minutes  ${SWITCH_OFF_DURATION}minutes
    ${lbpsPeriodList}  Create Dictionary  name=lbpsPeriodList  lbpsDayOfWeek=${day}  lbpsDuration=${SWITCH_OFF_DURATION}
    ...  lbpsStartTimeHour=${start_hour}  lbpsStartTimeMinute=${start_minutes}
    Create And Activate PSGRP  0  ${standalone_params_psgrp}  ${cell_list_psgrp}  ${lbpsPeriodList}
    Log  PSGRP created with time frame ${TIME_WITH_OFFSET}-${END_TIME}\n  console=true
    Log  Test will enter pause until PSGRP energy saving period begins\n  console=true
    Sleep Until Given Date  ${TIME_WITH_OFFSET_PSGRP}
    Log  PSGRP energy saving period started. Check LNCELs are in expected states\n  console=true
    @{states_to_check}  Create List  operationalState  energySavingState
    @{expected_states}  Create List  ENABLED  SWITCHINGOFF
    Log  Wait for Cell ${SELECTED_LTES[0]} to reach SWITCHINGOFF and Cell ${SELECTED_LTES[1]} to be in NOTENERGYSAVING\n  console=true
    Wait For Specific Cell To Reach Expected States  LNCEL  ${SELECTED_LTES[0]}  6min  15s  ${states_to_check}  ${expected_states}
    @{expected_states}  Create List  ENABLED  NOTENERGYSAVING
    Check Cell States For Specific Cell  LNCEL  ${SELECTED_LTES[1]}  ${states_to_check}  ${expected_states}
    Log  Cells are in expected states [OK]\n  console=true


PS.77_LTE1103_LTE1203_S1_Link_Break_With_Cells_In_EnergySaving_And_ReducedES.Step 2: Break S1 Link First Time
    Log  \n========================================  console=true
    Log  Step 2: Break S1 Link When ES Window Not Active\n  console=true
    Log  ========================================  console=true
    Break S1 Link
    Log  Checking if LNCELs entered DISABLED/NOTENERGYSAVING after S1 Link Break\n  console=true
    @{states_to_check}  Create List  operationalState  energySavingState
    @{expected_states}  Create List  DISABLED  NOTENERGYSAVING
    Wait For Specific Cell To Reach Expected States  LNCEL  ${SELECTED_LTES}  3min  30s  ${states_to_check}  ${expected_states}
    Log  LNCELs are in DISABLED/NOTENERGYSAVING following S1 Link Break [OK]\n  console=true


PS.77_LTE1103_LTE1203_S1_Link_Break_With_Cells_In_EnergySaving_And_ReducedES.Step ${i}: Reestablish S1 Link When ES Window Is Active
    Log  \n========================================  console=true
    Log  Step ${i}: Reestablish S1 Link When ES Window Is Active\n  console=true
    Log  ========================================  console=true
    ${step}  Convert To Integer  ${i}
    Reestablish S1 Link
    @{states_to_check}  Create List  operationalState  energySavingState
    @{cell1_expected_states}  Create List  DISABLED  ENERGYSAVING
    @{cell2_expected_states}  Create List  ENABLED  REDUCEDENERGYSAVING
    Log  Checking if LNCELs entered correct energy saving states after S1 Link recovery\n  console=true
    IF  ${step}>=5
        Wait For Specific Cell To Reach Expected States  LNCEL  ${SELECTED_LTES[1]}  6min  1min  ${states_to_check}  ${cell2_expected_states}
    ELSE
        Wait For Specific Cell To Reach Expected States  LNCEL  ${SELECTED_LTES[1]}  15min  1min  ${states_to_check}  ${cell2_expected_states}
    END
    Wait For Specific Cell To Reach Expected States  LNCEL  ${SELECTED_LTES[0]}  1min  15s  ${states_to_check}  ${cell1_expected_states}
    Log  LNCELs are in ENERGYSAVING and REDUCEDENERGYSAVING states [OK]\n  console=true


PS.77_LTE1103_LTE1203_S1_Link_Break_With_Cells_In_EnergySaving_And_ReducedES.Step ${i}: Break S1 Link When ES Window Is Active
    Log  \n========================================  console=true
    Log  Step ${i}: Break S1 Link When ES Window Is Active\n  console=true
    Log  ========================================  console=true
    Break S1 Link
    Log  Checking if LNCELs entered DISABLED/NOTENERGYSAVING after S1 Link Break\n  console=true
    @{states_to_check}  Create List  operationalState  energySavingState
    @{cell1_expected_states}  Create List  DISABLED  ENERGYSAVING
    @{cell2_expected_states}  Create List  DISABLED  NOTENERGYSAVING
    Wait For Specific Cell To Reach Expected States  LNCEL  ${SELECTED_LTES[1]}  5min  1min  ${states_to_check}  ${cell2_expected_states}
    Wait For Specific Cell To Reach Expected States  LNCEL  ${SELECTED_LTES[0]}  1min  15s  ${states_to_check}  ${cell1_expected_states}
    Log  LNCELs are in ENERGYSAVING and NOTENERGYSAVING following S1 Link Break [OK]\n  console=true


PS.77_LTE1103_LTE1203_S1_Link_Break_With_Cells_In_EnergySaving_And_ReducedES.Step 7: Check Cells After Power Saving Window Ends
    Log  \n========================================  console=true
    Log  Step 7: Check Cells After Power Saving Window Ends\n  console=true
    Log  ========================================  console=true
    Log  Test will enter pause until energy saving window of PSGRP ends\n  console=true
    Sleep Until Given Date  ${END_TIME_PSGRP}
    Log  Check that both cells are DISABLED/NOTENERGYSAVING while S1 Link is still broken\n  console=true
    @{states_to_check}  Create List  operationalState  energySavingState
    @{expected_states}  Create List  DISABLED  NOTENERGYSAVING
    Wait For Specific Cell To Reach Expected States  LNCEL  ${SELECTED_LTES}  4min  20s  ${states_to_check}  ${expected_states}
    Log  Both cells are in DISABLED/NOTENERGYSAVING [OK]\n  console=true


PS.77_LTE1103_LTE1203_S1_Link_Break_With_Cells_In_EnergySaving_And_ReducedES.Step 8: Reestablish S1 Link Without ES Window
    Log  \n========================================  console=true
    Log  Step 8: Reestablish S1 Link Without ES Window\n  console=true
    Log  ========================================  console=true
    Reestablish S1 Link
    Log  Check that both cells are ENABLED/NOTENERGYSAVING while S1 Link is still broken\n  console=true
    @{states_to_check}  Create List  operationalState  energySavingState
    @{expected_states}  Create List  ENABLED  NOTENERGYSAVING
    Wait For Specific Cell To Reach Expected States  LNCEL  ${SELECTED_LTES[1]}  3min  15s  ${states_to_check}  ${expected_states}
    Wait For Specific Cell To Reach Expected States  LNCEL  ${SELECTED_LTES[0]}  1min  15s  ${states_to_check}  ${expected_states}
    Log  Both cells are in ENABLED/NOTENERGYSAVING [OK]\n  console=true


PS.77_LTE1103_LTE1203_S1_Link_Break_With_Cells_In_EnergySaving_And_ReducedES.Test Specific Teardown
    Log To Console  \n============ SPECIFIC TEST TEARDOWN =============
    Reestablish S1 Link
    Set Feature Under Given Object  ${LNBTS_DistName}  s1InducedCellDeactDelayTime  ${S1_CELL_DEACT_DELAY}
    Set Feature Under Given Object  ${LNBTS_DistName}  actLBPowerSaving  false
    Set Feature Under Given Object  ${LNBTS_DistName}  actLBRTXPowerSaving  false
    Set Feature Under Given Object  ${LNBTS_DistName}  actOnlineTXSwitch  false
    Log  Deleting any old PSGRP that was already on the BTS\n  console=true
    Remove Old PSGRP Objects If Present
    @{states_to_check}  Create List  operationalState  energySavingState
    @{expected_states}  Create List  ENABLED  NOTENERGYSAVING
    FOR  ${lte_cell_id}  IN  @{LTE_IDS}
        Check Cell States For Specific Cell  LNCEL  ${lte_cell_id}  ${states_to_check}  ${expected_states}
    END
    Log  LNCELs are in correct energy saving state [OK]\n  console=true
    Log  Check eNB is onAir\n  console=true
    @{states_to_check}  Create List  availabilityStatus  administrativeState  blockingState
    @{expected_states}  Create List  -  UNLOCKED  UNBLOCKED
    FOR  ${lte_cell_id}  IN  @{LTE_IDS}
        Check Cell States For Specific Cell  LNCEL  ${lte_cell_id}  ${states_to_check}  ${expected_states}
    END
    Log  Check if any unexpected alarm occured\n  console=true
    Check If Unexpected Alarms Are Raised  ${skip_fault}
    Log To Console  ========== SPECIFIC TEST TEARDOWN DONE ==========\n


PS.77_LTE1103_LTE1203_S1_Link_Break_With_Cells_In_EnergySaving_And_ReducedES.Test Case Teardown
    PS.77_LTE1103_LTE1203_S1_Link_Break_With_Cells_In_EnergySaving_And_ReducedES.Test Specific Teardown
    Common Test Teardown


Break S1 Link
    Log  Changing primary IP address to dummy value\n  console=true
    Set Feature Under Given Object  ${LNMME_DN}  ipAddrPrim  2.2.2.2
    Wait For Active Fault    6202    timeout=200


Reestablish S1 Link
    Log  Changing primary IP address back to the original value\n  console=true
    Set Feature Under Given Object  ${LNMME_DN}  ipAddrPrim  ${INIT_PRIM_IP_ADDR}