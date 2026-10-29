*** Settings ***
Resource    ../../../resources/common.robot
Resource    ../../../resources/alarms.robot
Resource    ../../../resources/power_saving.robot

Documentation
...  TEST NAME:     PS.60_CB012087_B_5G_SA_FDD_And_TDD_Feature_Activation_Cell_Switch_Off_Based_On_Voltage
...  AUTHORS:       victor.banicioiu@nokia.com
...  MAINTAINER:    TIM_5_Vrf    victor.banicioiu@nokia.com
...  FEATURE:       CB012087
...  *****************
...  Basic information
...  *****************
...  Purpose of the test is activation of 5G SA FDD+TDD Cell switch off based on Voltage.
...  *****************
...  Pre-conditions
...  *****************
...  All RAT are onAir and no active alarms are visible
...  ******************
...  History of changes
...  ******************
...  06.09.2024 - https://jiradc.ext.net.nokia.com/browse/TAT-28044 - TC creation
...  *******************


*** Variables ***
${CHECK_ENERGYSAVING_STATE}  ${False}

*** Keywords ***
PS.60_CB012087_B_5G_SA_FDD_And_TDD_Feature_Activation_Cell_Switch_Off_Based_On_Voltage
    PS.60_CB012087_B_5G_SA_FDD_And_TDD_Feature_Activation_Cell_Switch_Off_Based_On_Voltage.Step 0: Preparing Environment
    PS.60_CB012087_B_5G_SA_FDD_And_TDD_Feature_Activation_Cell_Switch_Off_Based_On_Voltage.Step 1: Creating And Activating The NRFSOPGRP


PS.60_CB012087_B_5G_SA_FDD_And_TDD_Feature_Activation_Cell_Switch_Off_Based_On_Voltage.Step 0: Preparing Environment
    Log  \n========================================  console=true
    Log  Step 0: Preparing Environment\n  console=true
    Log  ========================================  console=true
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


PS.60_CB012087_B_5G_SA_FDD_And_TDD_Feature_Activation_Cell_Switch_Off_Based_On_Voltage.Step 1: Creating And Activating The NRFSOPGRP
    Log  \n========================================  console=true
    Log  Step 1: Creating And Activating The NRFSOPGRP\n  console=true
    Log  ========================================  console=true
    Log  Deleting any old NRFSOPGRP that was already on the BTS\n  console=true
    Remove Old NRFSOPGRPs Objects If Existing
    Log  Creating and activating NRFSOPGRP based on voltage threshold\n  console=true
    Create And Activate NRFSOPGRP Based On Voltage Threshold  ${NRCEL_IDS}  480  500
    Log  Set actForcedCellSwitchOff flag to true\n  console=true
    Set Feature Under Given Object  ${NRBTS_DistName}  ${FEATURE_FLAGS}  true
    IF  ${CHECK_ENERGYSAVING_STATE}  Wait For NRCELs To Reach Expected States  ${NRCEL_IDS}  15min  30sec  DISABLED  ENERGYSAVING
    Check If Unexpected Alarms Are Raised  ${skip_fault}


PS.60_CB012087_B_5G_SA_FDD_And_TDD_Feature_Activation_Cell_Switch_Off_Based_On_Voltage.Test Specific Teardown
    Log To Console  \n============ SPECIFIC TEST TEARDOWN =============
    Log  No test specific teardown is needed\n  console=true
    Log To Console  ========== SPECIFIC TEST TEARDOWN DONE ==========\n


PS.60_CB012087_B_5G_SA_FDD_And_TDD_Feature_Activation_Cell_Switch_Off_Based_On_Voltage.Test Case Teardown
    Common Test Teardown
    PS.60_CB012087_B_5G_SA_FDD_And_TDD_Feature_Activation_Cell_Switch_Off_Based_On_Voltage.Test Specific Teardown
