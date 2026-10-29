*** Settings ***
Resource    ../../../resources/common.robot
Resource    ../../../resources/alarms.robot
Resource    ../../../resources/power_saving.robot

Documentation
...  TEST NAME:     PS.58_CB012087_A_5G_SA_FDD_And_TDD_Feature_Activation_Cell_Switch_Off_Based_On_Time_Of_Day
...  AUTHORS:       victor.banicioiu@nokia.com
...  MAINTAINER:    TIM_5_Vrf    victor.banicioiu@nokia.com
...  FEATURE:       CB012087
...  *****************
...  Basic information
...  *****************
...  Purpose of the test is activation of 5G SA FDD+TDD Cell switch off based on Time of Day.
...  *****************
...  Pre-conditions
...  *****************
...  All RAT are onAir and no active alarms are visible
...  ******************
...  History of changes
...  ******************
...  20.08.2024 - https://jiradc.ext.net.nokia.com/browse/TAT-27961 - TC creation
...  *******************


*** Variables ***
${CHECK_ENERGYSAVING_STATE}  ${False}  #If this var is set on true, the test checks that cells in NRFSOPGRP reach ENABLED/ENERGYSAVING, else, SKIP

*** Keywords ***
PS.58_CB012087_A_5G_SA_FDD_And_TDD_Feature_Activation_Cell_Switch_Off_Based_On_Time_Of_Day
    PS.58_CB012087_A_5G_SA_FDD_And_TDD_Feature_Activation_Cell_Switch_Off_Based_On_Time_Of_Day.Step 0: Preparing Environment
    PS.58_CB012087_A_5G_SA_FDD_And_TDD_Feature_Activation_Cell_Switch_Off_Based_On_Time_Of_Day.Step 1: Creating And Activating The NRFSOPGRP


PS.58_CB012087_A_5G_SA_FDD_And_TDD_Feature_Activation_Cell_Switch_Off_Based_On_Time_Of_Day.Step 0: Preparing Environment
    Log  Step 0: Preparing Environment\n  console=true
    @{FEATURE_FLAGS}  Create List  actForcedCellSwitchOff
    Set Test Variable  ${FEATURE_FLAGS}
    ${nrcel_list}  Get 1 TDD And 1 FDD Cells At Random
    @{NRCEL_IDS}  Create List
    FOR  ${index}  IN RANGE  2
        ${NRCEL_id}  Fetch From Right  ${nrcel_list}[${index}]  -
        ${cell_id}  Convert To Integer  ${NRCEL_id}
        Append To List  ${NRCEL_IDS}  ${cell_id}
    END
    Set Test Variable  ${NRCEL_IDS}


PS.58_CB012087_A_5G_SA_FDD_And_TDD_Feature_Activation_Cell_Switch_Off_Based_On_Time_Of_Day.Step 1: Creating And Activating The NRFSOPGRP
    Log  Step 1: Creating And Activating The NRFSOPGRP\n  console=true
    Log  Deleting any old NRFSOPGRP that was already on the BTS\n  console=true
    Remove Old NRFSOPGRPs Objects If Existing
    Log  Creating and activating NRFSOPGRP based on time window\n  console=true
    Create And Activate NRFSOPGRP Based On Time Windows  ${NRCEL_IDS}  15 minutes  15
    Log  Set actForcedCellSwitchOff flag to true\n  console=true
    Set Feature Under Given Object  ${NRBTS_DistName}  ${FEATURE_FLAGS}  true
    IF  ${CHECK_ENERGYSAVING_STATE}  Wait For NRCELs To Reach Expected States  ${NRCEL_IDS}  15min  30sec  DISABLED  ENERGYSAVING
    Check If Unexpected Alarms Are Raised  ${skip_fault}


PS.58_CB012087_A_5G_SA_FDD_And_TDD_Feature_Activation_Cell_Switch_Off_Based_On_Time_Of_Day.Test Specific Teardown
    Log To Console  \n============ SPECIFIC TEST TEARDOWN =============
    Log  No test specific teardown is needed\n  console=true
    Log To Console  ========== SPECIFIC TEST TEARDOWN DONE ==========\n


PS.58_CB012087_A_5G_SA_FDD_And_TDD_Feature_Activation_Cell_Switch_Off_Based_On_Time_Of_Day.Test Case Teardown
    Common Test Teardown
    PS.58_CB012087_A_5G_SA_FDD_And_TDD_Feature_Activation_Cell_Switch_Off_Based_On_Time_Of_Day.Test Specific Teardown
