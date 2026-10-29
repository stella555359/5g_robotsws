*** Settings ***
Resource    ../../../resources/common.robot
Resource    ../../../resources/alarms.robot
Resource    ../../../resources/power_saving.robot

Documentation
...  TEST NAME:     PS.69_CB012087_C_SR_Online_Configuration_Change_For_4G_Cell_Based_On_Time_Of_Day
...  AUTHORS:       victor.banicioiu@nokia.com
...  MAINTAINER:    TIM_5_Vrf    victor.banicioiu@nokia.com
...  FEATURE:       CB012087
...  *****************
...  Basic information
...  *****************
...  Purpose of the test is online modification of parameters related to 4G Cell switch off based on Time of Day
...  *****************
...  Pre-conditions
...  *****************
...  All RAT are onAir and no active alarms are visible
...  ******************
...  History of changes
...  ******************
...  29.05.2025 - https://jiradc.ext.net.nokia.com/browse/TAT-29304 - TC creation
...  *******************

*** Variables ***
${USED_CELL_TECHNOLOGY}    "FDD"


*** Keywords ***
PS.69_CB012087_C_SR_Online_Configuration_Change_For_4G_Cell_Based_On_Time_Of_Day
    PS.69_CB012087_C_SR_Online_Configuration_Change_For_4G_Cell_Based_On_Time_Of_Day.Step 0: Preparing Environment
    PS.69_CB012087_C_SR_Online_Configuration_Change_For_4G_Cell_Based_On_Time_Of_Day.Step 1: Creating And Activating The FSOPGRP
    PS.69_CB012087_C_SR_Online_Configuration_Change_For_4G_Cell_Based_On_Time_Of_Day.Step 2: Changing Switch Off Duration
    PS.69_CB012087_C_SR_Online_Configuration_Change_For_4G_Cell_Based_On_Time_Of_Day.Step 3: Delete MOC
    PS.69_CB012087_C_SR_Online_Configuration_Change_For_4G_Cell_Based_On_Time_Of_Day.Step 4: Creating And Activating The FSOPGRP
    PS.69_CB012087_C_SR_Online_Configuration_Change_For_4G_Cell_Based_On_Time_Of_Day.Step 5: Changing Switch Off Duration
    PS.69_CB012087_C_SR_Online_Configuration_Change_For_4G_Cell_Based_On_Time_Of_Day.Step 3: Delete MOC


PS.69_CB012087_C_SR_Online_Configuration_Change_For_4G_Cell_Based_On_Time_Of_Day.Step 0: Preparing Environment
    Log  \n========================================  console=true
    Log  Step 0: Preparing Environment\n  console=true
    Log  ========================================  console=true
    @{FEATURE_FLAGS}  Create List  actForcedCellSwitchOff
    Set Test Variable  ${FEATURE_FLAGS}
    ${LNBTS_ID}=  Get LNBTS ID
    Set Test Variable  ${LNBTS_ID}
    IF  ${USED_CELL_TECHNOLOGY}=="TDD"
        ${lncel_list}  Get 2 TDD And 0 FDD LNCEL Cells At Random
    ELSE IF  ${USED_CELL_TECHNOLOGY}=="FDD"
        ${lncel_list}  Get 0 TDD And 2 FDD LNCEL Cells At Random
    ELSE
        ${lncel_list}  Get 1 TDD And 1 FDD LNCEL Cells At Random
    END
    @{LNCEL_IDS}  Create List
    FOR  ${index}  IN RANGE  2
        ${LNCEL_id}  Fetch From Right  ${lncel_list}[${index}]  -
        ${cell_id}  Convert To Integer  ${LNCEL_id}
        Append To List  ${LNCEL_IDS}  ${cell_id}
    END
    Set Test Variable  ${LNCEL_IDS}
    #@{states_to_check}  Create List  availabilityStatus  administrativeState  blockingState
    @{states_to_check}  Create List  availabilityStatus  administrativeState  blockingState
   # @{expected_states}  Create List  -  UNLOCKED  UNBLOCKED
    @{expected_states}  Create List  -  UNLOCKED  UNBLOCKED
    FOR  ${cell}  IN  @{LNCEL_IDS}
        Check Cell States For Specific Cell  LNCEL  ${cell}  ${states_to_check}  ${expected_states}
    END


PS.69_CB012087_C_SR_Online_Configuration_Change_For_4G_Cell_Based_On_Time_Of_Day.Step 1: Creating And Activating The FSOPGRP
    Log  \n========================================  console=true
    Log  Step 1: Creating And Activating The FSOPGRP\n  console=true
    Log  ========================================  console=true
    Log  Deleting any old FSOPSGRP that was already on the BTS\n  console=true
    Remove Old FSOPSGRP Objects If Present
    Create And Activate FSOPSGRP Based On Time Windows  ${LNCEL_IDS}  15 minutes  10
    Log  Set actForcedCellSwitchOff flag to true\n  console=true
    Set Feature Under Given Object  ${LNBTS_DistName}  ${FEATURE_FLAGS}  true
    @{states_to_check}  Create List  operationalState  energySavingState
    @{expected_states}  Create List  DISABLED  ENERGYSAVING
    Wait For Specific Cell To Reach Expected States  LNCEL  ${LNCEL_IDS}  16min  30sec  ${states_to_check}  ${expected_states}


PS.69_CB012087_C_SR_Online_Configuration_Change_For_4G_Cell_Based_On_Time_Of_Day.Step 2: Changing Switch Off Duration
    Log  \n========================================  console=true
    Log  Step 2: Changing Switch Off Duration\n  console=true
    Log  ========================================  console=true
    #Create And Activate Second FSOPSGRP Based On Time Windows  ${LNCEL_IDS}  15
    Modify Fso Duration For Existing FSOPSGRP  FSOPSGRP-1  15
    ${extended_endtime}  Add Time To Date  ${END_TIME}  1min
    Log  Sleep until the first PSGRP cell switch off duration ends\n  console=true
    Sleep Until Given Date  ${extended_endtime}
    Log  Checking that cells are still in energy saving state during the updated cell switch off duration\n  console=true
    @{states_to_check}  Create List  operationalState  energySavingState
    @{expected_states}  Create List  DISABLED  ENERGYSAVING
    FOR  ${cell}  IN  @{LNCEL_IDS}
        Check Cell States For Specific Cell  LNCEL  ${cell}  ${states_to_check}  ${expected_states}
    END
    Log  Sleep until the updated cell switch off duration ends\n  console=true
    ${current_time}  Get Time  epoch
    ${updated_so_duration_endtime}  Add Time To Date  ${current_time}  9min
    Sleep Until Given Date  ${updated_so_duration_endtime}
    Log  Checking that cells are not in energy saving state anymore after the cell switch off duration ended\n  console=true
    Remove Values From List  ${expected_states}  DISABLED  ENERGYSAVING
    Append To List  ${expected_states}  ENABLED  NOTENERGYSAVING
    FOR  ${cell}  IN  @{LNCEL_IDS}
        Check Cell States For Specific Cell  LNCEL  ${cell}  ${states_to_check}  ${expected_states}
    END


PS.69_CB012087_C_SR_Online_Configuration_Change_For_4G_Cell_Based_On_Time_Of_Day.Step 3: Delete MOC
    Log  \n========================================  console=true
    Log  Step 3: Delete MOC\n  console=true
    Log  ========================================  console=true
    Log  Set actForcedCellSwitchOff flag to true\n  console=true
    Set Feature Under Given Object  ${LNBTS_DistName}  ${FEATURE_FLAGS}  false
    Log  Deleting any old FSOPSGRP that was already on the BTS\n  console=true
    Remove Old FSOPSGRP Objects If Present


PS.69_CB012087_C_SR_Online_Configuration_Change_For_4G_Cell_Based_On_Time_Of_Day.Step 4: Creating And Activating The FSOPGRP
    Log  \n========================================  console=true
    Log  Step 4: Creating And Activating The FSOPGRP\n  console=true
    Log  ========================================  console=true
    Create And Activate FSOPSGRP Based On Time Windows  ${LNCEL_IDS}  15 minutes  15
    Log  Set actForcedCellSwitchOff flag to true\n  console=true
    Set Feature Under Given Object  ${LNBTS_DistName}  ${FEATURE_FLAGS}  true
    @{states_to_check}  Create List  operationalState  energySavingState
    @{expected_states}  Create List  DISABLED  ENERGYSAVING
    Wait For Specific Cell To Reach Expected States  LNCEL  ${LNCEL_IDS}  16min  30sec  ${states_to_check}  ${expected_states}


PS.69_CB012087_C_SR_Online_Configuration_Change_For_4G_Cell_Based_On_Time_Of_Day.Step 5: Changing Switch Off Duration
    Log  \n========================================  console=true
    Log  Step 5: Changing Switch Off Duration\n  console=true
    Log  ========================================  console=true
    #Create And Activate Second FSOPSGRP Based On Time Windows  ${LNCEL_IDS}  10
    Modify Fso Duration For Existing FSOPSGRP  FSOPSGRP-1  10
    ${shortened_endtime}  Add Time To Date  ${END_TIME}  -4min
    Log  Sleep until the shortened cell switch off duration ends\n  console=true
    Sleep Until Given Date  ${shortened_endtime}
    Log  Checking that cells are not in energy saving state anymore after the cell switch off duration ended\n  console=true
    @{states_to_check}  Create List  operationalState  energySavingState
    @{expected_states}  Create List  ENABLED  NOTENERGYSAVING
    FOR  ${cell}  IN  @{LNCEL_IDS}
        Check Cell States For Specific Cell  LNCEL  ${cell}  ${states_to_check}  ${expected_states}
    END


PS.69_CB012087_C_SR_Online_Configuration_Change_For_4G_Cell_Based_On_Time_Of_Day.Test Specific Teardown
    Log To Console  \n============ SPECIFIC TEST TEARDOWN =============
    Log  Setting feature flag actForcedCellSwitchOff back to false value\n  console=true
    Set Feature Under Given Object  ${LNBTS_DistName}  ${FEATURE_FLAGS}  false
    Log  Deleting any old FSOPSGRP that was already on the BTS\n  console=true
    Remove Old FSOPSGRP Objects If Present
    Log  Check if any unexpected alarm occured\n  console=true
    Check If Unexpected Alarms Are Raised  ${skip_fault}
    Log To Console  ========== SPECIFIC TEST TEARDOWN DONE ==========\n


PS.69_CB012087_C_SR_Online_Configuration_Change_For_4G_Cell_Based_On_Time_Of_Day.Test Case Teardown
    PS.69_CB012087_C_SR_Online_Configuration_Change_For_4G_Cell_Based_On_Time_Of_Day.Test Specific Teardown
    Common Test Teardown
