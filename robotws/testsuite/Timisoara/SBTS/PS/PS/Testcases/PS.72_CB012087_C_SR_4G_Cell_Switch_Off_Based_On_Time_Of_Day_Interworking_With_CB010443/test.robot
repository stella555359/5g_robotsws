*** Settings ***
Resource    ../../../resources/common.robot
Resource    ../../../resources/alarms.robot
Resource    ../../../resources/power_saving.robot
Library    ute_admin_infomodel

Documentation
...  TEST NAME:     PS.72_CB012087_C_SR_4G_Cell_Switch_Off_Based_On_Time_Of_Day_Interworking_With_CB010443
...  AUTHORS:       victor.banicioiu@nokia.com
...  MAINTAINER:    TIM_5_Vrf    victor.banicioiu@nokia.com
...  FEATURE:       CB012087 / CB010443
...  *****************
...  Basic information
...  *****************
...  Purpose of the test is cell switch off based on Time of Day on eNB when Coordinated 4G-5G power saving part 2 (CB010443)
...  is also activated for the cell.
...  *****************
...  Pre-conditions
...  *****************
...  All RAT are onAir and no active alarms are visible
...  ******************
...  History of changes
...  ******************
...  04.09.2025 - https://jiradc.ext.net.nokia.com/browse/TAT-29829 - TC creation
...  *******************


*** Variables ***
${RMOD_SN}    BL1844G11L5
@{LNCEL_IDS}    48040  48045
${NRCEL_ID}    400
${SHELL_PATH}    /home/ute/MN/UTE/robotws/testsuite/Timisoara/SBTS/PS/resources/voltage_scripts/
${SWITCH_OFF_DURATION}    15
${FSO_DURATION}    20


*** Keywords ***
PS.72_CB012087_C_SR_4G_Cell_Switch_Off_Based_On_Time_Of_Day_Interworking_With_CB010443
    PS.72_CB012087_C_SR_4G_Cell_Switch_Off_Based_On_Time_Of_Day_Interworking_With_CB010443.Step 0: Preparing Environment
    PS.72_CB012087_C_SR_4G_Cell_Switch_Off_Based_On_Time_Of_Day_Interworking_With_CB010443.Step 1: Configure CB010443
    PS.72_CB012087_C_SR_4G_Cell_Switch_Off_Based_On_Time_Of_Day_Interworking_With_CB010443.Step 2: Creating And Activating The PSGRPs
    PS.72_CB012087_C_SR_4G_Cell_Switch_Off_Based_On_Time_Of_Day_Interworking_With_CB010443.Step 3: Creating And Activating The NRPGRP
    PS.72_CB012087_C_SR_4G_Cell_Switch_Off_Based_On_Time_Of_Day_Interworking_With_CB010443.Step 4: Checking LNCELs Are In Energy Saving
    PS.72_CB012087_C_SR_4G_Cell_Switch_Off_Based_On_Time_Of_Day_Interworking_With_CB010443.Step 5: Creating And Activating The FSOPSGRP
    PS.72_CB012087_C_SR_4G_Cell_Switch_Off_Based_On_Time_Of_Day_Interworking_With_CB010443.Step 6: Check Time Window LNCEL ES State


PS.72_CB012087_C_SR_4G_Cell_Switch_Off_Based_On_Time_Of_Day_Interworking_With_CB010443.Step 0: Preparing Environment
    Log  \n========================================  console=true
    Log  Step 0: Preparing Environment\n  console=true
    Log  ========================================  console=true
    @{FEATURE_FLAGS}  Create List  actForcedCellSwitchOff
    Set Test Variable  ${FEATURE_FLAGS}
    ${LNBTS_ID}  Get LNBTS ID
    Set Test Variable  ${LNBTS_ID}
    ${LTE_IDS}  Get LNCEL ID List
    Set Test Variable  ${LTE_IDS}
    @{states_to_check}  Create List  availabilityStatus  administrativeState  blockingState
    @{expected_states}  Create List  -  UNLOCKED  UNBLOCKED
    FOR  ${cell_id}  IN  @{LTE_IDS}
        Check Cell States For Specific Cell  LNCEL  ${cell_id}  ${states_to_check}  ${expected_states}
    END
    ${rmod_distname}  ${RMOD_INT_NAME}  Get RMOD DistName And Internal Name Based On Serial Number  ${RMOD_SN}
    Set Test Variable  ${RMOD_INT_NAME}


PS.72_CB012087_C_SR_4G_Cell_Switch_Off_Based_On_Time_Of_Day_Interworking_With_CB010443.Step 1: Configure CB010443
    Log  \n========================================  console=true
    Log  Step 1: Configure CB010443\n  console=true
    Log  ========================================  console=true
    @{CB010443_FEATURE_FLAGS}  Create List  actLteNrDualConnectivity  actLBPowerSaving
    Set Test Variable  ${CB010443_FEATURE_FLAGS}
    Log  Setting actLteNrDualConnectivity and actLBPowerSaving on TRUE for CB010443\n  console=true
    Set Feature Under Given Object  ${LNBTS_DistName}  ${CB010443_FEATURE_FLAGS}  true
    Log  Setting actCoordinated4g5gPowerSaving on TRUE for CB010443\n  console=true
    Set Feature Under Given Object  ${LNBTS_DistName}  actCoordinated4g5gPowerSaving  cellDeactAndReact
    Set Feature Under Given Object  ${NRBTS_DistName}  actCoordinated4g5gPowerSaving  cellDeactAndReact
    Set Feature Under Given Object  ${NRBTS_DistName}  actNrLBPowerSaving  true
    #Set Feature Under Given Object  ${NRBTS_DistName}  actLBRTXPowerSaving  false
    Log  CB010443 configured!\n  console=true


PS.72_CB012087_C_SR_4G_Cell_Switch_Off_Based_On_Time_Of_Day_Interworking_With_CB010443.Step 2: Creating And Activating The PSGRPs
    Log  \n========================================  console=true
    Log  Step 2: Creating And Activating The PSGRPs\n  console=true
    Log  ========================================  console=true
    Log  Deleting any old PSGRP that was already on the BTS\n  console=true
    Remove Old PSGRP Objects If Present
    Get Time And Date With Minute Offset  5minutes
	${start_time_fsopsgrp}  Add Time To Date  ${TIME_WITH_OFFSET}  10minutes
	${start_hour_fso}  Convert Date  ${start_time_fsopsgrp}  result_format=%H
    ${start_minutes_fso}  Convert Date  ${start_time_fsopsgrp}  result_format=%M
	${end_time_fso}  Add Time To Date  ${start_time_fsopsgrp}  ${FSO_DURATION}minutes
    Set Test Variable  ${FSO_START_TIME}  ${start_time_fsopsgrp}
    Set Test Variable  ${FSO_START_HOUR}  ${start_hour_fso}
    Set Test Variable  ${FSO_START_MIN}  ${start_minutes_fso}
	Set Test Variable  ${FSO_END_TIME}  ${end_time_fso}
    ${psgrp_end_time}  Add Time To Date  ${end_time}  ${SWITCH_OFF_DURATION}min
    ${standalone_params}  Create Dictionary
    Set To Dictionary  ${standalone_params}  name  standalone
    Set To Dictionary  ${standalone_params}  lbpsCSONCtlEnabled  true
    Set To Dictionary  ${standalone_params}  lbpsGuardTimerNrAct  20
    Set To Dictionary  ${standalone_params}  lbpsLastCellMinLoad  0
    Set To Dictionary  ${standalone_params}  lbpsLastCellSOEnabled  true
    Set To Dictionary  ${standalone_params}  lbpsMaxLoad  4
    Set To Dictionary  ${standalone_params}  lbpsMaxLoadNrAct  40
    Set To Dictionary  ${standalone_params}  lbpsMinLoad  2
    Set To Dictionary  ${standalone_params}  lbpsMinNumEndcCapUeNrAct  0
    Set To Dictionary  ${standalone_params}  lbpsMonWinNrAct  5
    Set To Dictionary  ${standalone_params}  lbpsPdcchLoadOffset  4
    Set To Dictionary  ${standalone_params}  lbpsRTXCellCapOffset  80
    Set To Dictionary  ${standalone_params}  lbpsRTXMaxLoad  60
    Set To Dictionary  ${standalone_params}  lbpsRTXMinLoad  20
    Set To Dictionary  ${standalone_params}  lbpsRetryTimerNrAct  5
    Set To Dictionary  ${standalone_params}  lbpsSOMethod  Cell Switch Off
    ${lbpsCellList}  Create Dictionary
    Set To Dictionary  ${lbpsCellList}  name=lbpsCellList
    Set To Dictionary  ${lbpsCellList}  lbpsCellSOOrder=100
    Set To Dictionary  ${lbpsCellList}  lbpsUseExtConfig=false
    Set To Dictionary  ${lbpsCellList}  lnCelId=${LNCEL_IDS[0]}
    ${lbpsCellListNrAct}  Create Dictionary
    Set To Dictionary  ${lbpsCellListNrAct}  name=lbpsCellListNrAct
    Set To Dictionary  ${lbpsCellListNrAct}  gNbIdLength=22
    Set To Dictionary  ${lbpsCellListNrAct}  mcc=540
    Set To Dictionary  ${lbpsCellListNrAct}  mnc=1
    Set To Dictionary  ${lbpsCellListNrAct}  mncLength=2
    Set To Dictionary  ${lbpsCellListNrAct}  nrCellId=709345281
    ${lbpsPeriodList}  Create Dictionary
    Set To Dictionary  ${lbpsPeriodList}  name=lbpsPeriodList
    Set To Dictionary  ${lbpsPeriodList}  lbpsDayOfWeek=${day}
    Set To Dictionary  ${lbpsPeriodList}  lbpsDuration=${SWITCH_OFF_DURATION}
    Set To Dictionary  ${lbpsPeriodList}  lbpsStartTimeHour=${start_hour}
    Set To Dictionary  ${lbpsPeriodList}  lbpsStartTimeMinute=${start_minutes}
    Set To Dictionary  ${lbpsPeriodList}  lbpsSuspended=notSuspended
    Log  Create PSGRP-0 with ${LNCEL_IDS[0]}\n  console=true
    Create And Activate PSGRP  0  ${standalone_params}  ${lbpsCellList}  ${lbpsCellListNrAct}  ${lbpsPeriodList}
    Set To Dictionary  ${standalone_params}  name=standalone
    #Set To Dictionary  ${standalone_params}  lbpsLastCellRTXMinLoad  0
    Set To Dictionary  ${lbpsCellList}  name=lbpsCellList
    Set To Dictionary  ${lbpsCellListNrAct}  name=lbpsCellListNrAct
    Set To Dictionary  ${lbpsPeriodList}  name=lbpsPeriodList
    Set To Dictionary  ${lbpsCellList}  lnCelId=${LNCEL_IDS[1]}
    Log  Create PSGRP-1 with ${LNCEL_IDS[1]}\n  console=true
    Create And Activate PSGRP  1  ${standalone_params}  ${lbpsCellList}  ${lbpsCellListNrAct}  ${lbpsPeriodList}

PS.72_CB012087_C_SR_4G_Cell_Switch_Off_Based_On_Time_Of_Day_Interworking_With_CB010443.Step 3: Creating And Activating The NRPGRP
    Log  \n========================================  console=true
    Log  Step 3: Creating And Activating The NRPGRP\n  console=true
    Log  ========================================  console=true
    Log  Deleting any old NRPGRP that was already on the BTS\n  console=true
    Remove Old NRPGRP Objects If Present
    Log  Create NRPGRP-1 with ${NRCEL_ID}\n  console=true
    ${standalone_params}  Create Dictionary
    Set To Dictionary  ${standalone_params}  name  standalone
    Set To Dictionary  ${standalone_params}  lbpsCSONCtlEnabled  true
    Set To Dictionary  ${standalone_params}  lbpsLastCellMinLoad  0
    Set To Dictionary  ${standalone_params}  lbpsLastCellSOEnabled  true
    Set To Dictionary  ${standalone_params}  lbpsMaxLoad  4
    Set To Dictionary  ${standalone_params}  lbpsMinLoad  2
    Set To Dictionary  ${standalone_params}  lbpsPdcchLoadOffset  4
    Set To Dictionary  ${standalone_params}  lbpsSOMethod  cell switch off
    ${lbpsCellList}  Create Dictionary
    Set To Dictionary  ${lbpsCellList}  name  lbpsCellList
    Set To Dictionary  ${lbpsCellList}  lbpsCellSOOrder  100
    Set To Dictionary  ${lbpsCellList}  lbpsUseExtConfig  false
    Set To Dictionary  ${lbpsCellList}  nrCellId  ${NRCEL_ID}
    ${lbpsPeriodList}  Create Dictionary
    Set To Dictionary  ${lbpsPeriodList}  name  lbpsPeriodList
    Set To Dictionary  ${lbpsPeriodList}  lbpsDayOfWeek  ${DAY}
    Set To Dictionary  ${lbpsPeriodList}  lbpsDuration  ${SWITCH_OFF_DURATION}
    Set To Dictionary  ${lbpsPeriodList}  lbpsStartTimeHour  ${START_HOUR}
    Set To Dictionary  ${lbpsPeriodList}  lbpsStartTimeMinute  ${START_MINUTES}
    Set To Dictionary  ${lbpsPeriodList}  lbpsSuspended  notSuspended
    Create And Activate NRPGRP  1  ${standalone_params}  ${lbpsCellList}  ${lbpsPeriodList}
    Log  Test enters pause until PSGRP time window starts\n  console=true
    Sleep Until Given Date  ${TIME_WITH_OFFSET_PSGRP}



PS.72_CB012087_C_SR_4G_Cell_Switch_Off_Based_On_Time_Of_Day_Interworking_With_CB010443.Step 4: Checking LNCELs Are In Energy Saving
    Log  \n========================================  console=true
    Log  Step 4: Checking LNCELs Are In Energy Saving\n  console=true
    Log  ========================================  console=true
    Log  Check if the LNCELs entered energy saving state\n  console=true
    @{states_to_check}  Create List  operationalState  energySavingState
    @{expected_states}  Create List  DISABLED  ENERGYSAVING
    Wait For Specific Cell To Reach Expected States  LNCEL  ${LNCEL_IDS}  8min  30sec  ${states_to_check}  ${expected_states}
    Log  LNCELs energy saving state check is concluded!\n  console=true


PS.72_CB012087_C_SR_4G_Cell_Switch_Off_Based_On_Time_Of_Day_Interworking_With_CB010443.Step 5: Creating And Activating The FSOPSGRP
    Log  \n========================================  console=true
    Log  Step 5: Creating And Activating The FSOPSGRP\n  console=true
    Log  ========================================  console=true
    Log  Deleting any old FSOPSGRP that was already on the BTS\n  console=true
    Remove Old FSOPSGRP Objects If Present
    ${fsopsgrp_cell}  Create List  ${LNCEL_IDS}[0]
    ${standalone_params}  Create Dictionary  name=standalone  cellSwitchOffType=TimeWindow
    ${time_window_switchoff}  Create Dictionary
    Set To Dictionary  ${time_window_switchoff}  name=timeWindowCellSwitchOffList
    Set To Dictionary  ${time_window_switchoff}  fsoDayOfWeek=${DAY}
    Set To Dictionary  ${time_window_switchoff}  fsoDuration=${FSO_DURATION}
    Set To Dictionary  ${time_window_switchoff}  fsoStartHour=${FSO_START_HOUR}
    Set To Dictionary  ${time_window_switchoff}  fsoStartMinute=${FSO_START_MIN}
    Create And Activate FSOPSGRP  ${fsopsgrp_cell}  1  ${standalone_params}  ${time_window_switchoff}
    Log  Set actForcedCellSwitchOff flag to true\n  console=true
    Set Feature Under Given Object  ${LNBTS_DistName}  ${FEATURE_FLAGS}  true



PS.72_CB012087_C_SR_4G_Cell_Switch_Off_Based_On_Time_Of_Day_Interworking_With_CB010443.Step 6: Check Time Window LNCEL ES State
    Log  \n========================================  console=true
    Log  Step 6: Check Time Window LNCEL ES State\n  console=true
    Log  ========================================  console=true
    Log  Test is entering pause state until time window switch off duration ends for the PSGRPs\n  console=true
    Sleep Until Given Date  ${END_TIME_PSGRP}
    @{states_to_check}  Create List  operationalState  energySavingState
    @{expected_states}  Create List  DISABLED  ENERGYSAVING
    Log  Check that the LNCEL in the FSOPSGRP is still in energy saving state\n  console=true
    Check Cell States For Specific Cell  LNCEL  ${LNCEL_IDS[0]}  ${states_to_check}  ${expected_states}
	Log  Test is entering pause state until time window switch off duration ends for the FSOPSGRP\n  console=true
	Sleep Until Given Date  ${FSO_END_TIME}
	@{states_to_check}  Create List  operationalState  energySavingState
    @{expected_states}  Create List  ENABLED  NOTENERGYSAVING
    Log  Check that the LNCEL in the FSOPSGRP is no longer in energy saving state\n  console=true
    Check Cell States For Specific Cell  LNCEL  ${LNCEL_IDS[0]}  ${states_to_check}  ${expected_states}


PS.72_CB012087_C_SR_4G_Cell_Switch_Off_Based_On_Time_Of_Day_Interworking_With_CB010443.Test Specific Teardown
    Log To Console  \n============ SPECIFIC TEST TEARDOWN =============
    Log  Setting feature flag actForcedCellSwitchOff back to false value\n  console=true
    Set Feature Under Given Object  ${LNBTS_DistName}  ${FEATURE_FLAGS}  false
    Log  Setting feature flag actLteNrDualConnectivity to true value\n  console=true
    Set Feature Under Given Object  ${LNBTS_DistName}  actLteNrDualConnectivity  true

    #Cristi
    Set Feature Under Given Object  ${LNBTS_DistName}  actCoordinated4g5gPowerSaving  disabled
    Set Feature Under Given Object  ${NRBTS_DistName}  actCoordinated4g5gPowerSaving  disabled
    #end Cristi
    Log  Deleting any old FSOPSGRP that was already on the BTS\n  console=true
    Remove Old FSOPSGRP Objects If Present
    Log  Deleting any old PSGRP that was already on the BTS\n  console=true
    Remove Old PSGRP Objects If Present
    Log  Deleting any old NRPGRP that was already on the BTS\n  console=true
    Remove Old NRPGRP Objects If Present

    Log  Setting feature flag actLBPowerSaving back to false value\n  console=true
    Set Feature Under Given Object  ${LNBTS_DistName}  actLBPowerSaving  false
    Set Feature Under Given Object  ${NRBTS_DistName}  actNrLBPowerSaving    false
    Set Feature Under Given Object  ${LNBTS_DistName}  actLbpsCtrlLogicEnh  false
    Log  Check if any unexpected alarm occured\n  console=true
    Check If Unexpected Alarms Are Raised  ${skip_fault}
    Log To Console  ========== SPECIFIC TEST TEARDOWN DONE ==========\n


PS.72_CB012087_C_SR_4G_Cell_Switch_Off_Based_On_Time_Of_Day_Interworking_With_CB010443.Test Case Teardown
    PS.72_CB012087_C_SR_4G_Cell_Switch_Off_Based_On_Time_Of_Day_Interworking_With_CB010443.Test Specific Teardown
    Common Test Teardown

