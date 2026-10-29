*** Settings ***
Resource    ../../../resources/common.robot
Resource    ../../../resources/alarms.robot
Resource    ../../../resources/power_saving.robot

Documentation
...  TEST NAME:     PS.62_CB012087_A_5G_Cell_Switch_On_Off_Based_On_Time_of_Day_Interworking_With_RU_DeepSleep_Features
...  AUTHORS:       victor.banicioiu@nokia.com
...  MAINTAINER:    TIM_5_Vrf    victor.banicioiu@nokia.com
...  FEATURE:       CB012087
...  *****************
...  Basic information
...  *****************
...   Purpose of the test is interworking  of 5G SA FDD+TDD Cell switch off based on Time of Day with RU Deep Sleep feature.
...  *****************
...  Pre-conditions
...  *****************
...  All RAT are onAir and no active alarms are visible
...  ******************
...  History of changes
...  ******************
...  08.10.2024 - https://jiradc.ext.net.nokia.com/browse/TAT-28209 - TC creation
...  *******************

*** Variables ***
${RU_SERIAL_NUMBER}    L1244007372
${RMOD_RESET_UPTIME_LIMIT}  600    #maximum uptime allowed for RMOD in order to consider it actually restarted
${RMOD_DESIRED_SLEEP_STATE}  SLEEP  #desired value for RMOD powerState to be reachd during test

*** Keywords ***
PS.62_CB012087_A_5G_Cell_Switch_On_Off_Based_On_Time_of_Day_Interworking_With_RU_DeepSleep_Features
    PS.62_CB012087_A_5G_Cell_Switch_On_Off_Based_On_Time_of_Day_Interworking_With_RU_DeepSleep_Features.Step 0: Preparing Environment
    PS.62_CB012087_A_5G_Cell_Switch_On_Off_Based_On_Time_of_Day_Interworking_With_RU_DeepSleep_Features.Step 1: Activate Energy Saving Mode On RU
    PS.62_CB012087_A_5G_Cell_Switch_On_Off_Based_On_Time_of_Day_Interworking_With_RU_DeepSleep_Features.Step 2: Creating And Activating The NRFSOPGRP
    PS.62_CB012087_A_5G_Cell_Switch_On_Off_Based_On_Time_of_Day_Interworking_With_RU_DeepSleep_Features.Step 3:Check RU And Cells States


PS.62_CB012087_A_5G_Cell_Switch_On_Off_Based_On_Time_of_Day_Interworking_With_RU_DeepSleep_Features.Step 0: Preparing Environment
    Log  \n========================================  console=true
    Log  Step 0: Preparing Environment\n  console=true
    Log  ========================================  console=true
    ${found_rmod_flag}  Set Variable  ${False}
    @{FEATURE_FLAGS}  Create List  actForcedCellSwitchOff
    Set Test Variable  ${FEATURE_FLAGS}
    ${rmod_list}  admin.Get Frm
    Log  Getting the required RMOD and the cells under it\n  console=true
    FOR  ${rmod}  IN  @{rmod_list}
        ${rmod_serial_number}  Set Variable  ${rmod['serialNumber']}
        ${rmod_id}  Set Variable  ${rmod['id']['configuration']}
        ${rmod_internal_id}  Set Variable  ${rmod['id']['internal']}
        ${rmod_power_state}  Set Variable  ${rmod['status']['powerState']}
        ${found_rmod_flag}  Set Variable If  '${rmod_serial_number}'=='${RU_SERIAL_NUMBER}'  ${True}  ${False}
        IF  ${found_rmod_flag}
            Set Test Variable  ${RMOD_DISTNAME}  ${rmod_id}
            ${NRCEL_IDS}  Get Cell List Under RMOD  ${rmod_internal_id}
            Set Test Variable  ${NRCEL_IDS}
            BREAK
        END
    END
    Run Keyword If  ${found_rmod_flag}==${False}
    ...  Fail  No RMOD with the serial number ${rmod_serial_number} was found. Test cannot continue\n


PS.62_CB012087_A_5G_Cell_Switch_On_Off_Based_On_Time_of_Day_Interworking_With_RU_DeepSleep_Features.Step 1: Activate Energy Saving Mode On RU
    Log  \n========================================  console=true
    Log  Step 1: Activate Energy Saving Mode On RU\n  console=true
    Log  ========================================  console=true
    admin.Perform Parameter Recommissioning    ${RMOD_DISTNAME}  energySavingMode  update  DEEPSLEEP


PS.62_CB012087_A_5G_Cell_Switch_On_Off_Based_On_Time_of_Day_Interworking_With_RU_DeepSleep_Features.Step 2: Creating And Activating The NRFSOPGRP
    Log  \n========================================  console=true
    Log  Step 2: Creating And Activating The NRFSOPGRP\n  console=true
    Log  ========================================  console=true
    Log  Deleting any old NRFSOPGRP that was already on the BTS\n  console=true
    Remove Old NRFSOPGRPs Objects If Existing
    Log  Creating and activating NRFSOPGRP based on time window\n  console=true
    Create And Activate NRFSOPGRP Based On Time Windows  ${NRCEL_IDS}  5 minutes  10
    Log  Set actForcedCellSwitchOff flag to true\n  console=true
    Set Feature Under Given Object  ${NRBTS_DistName}  ${FEATURE_FLAGS}  true
    Wait For NRCELs To Reach Expected States  ${NRCEL_IDS}  9min  30sec  DISABLED  ENERGYSAVING
    Check If Unexpected Alarms Are Raised  ${skip_fault}


PS.62_CB012087_A_5G_Cell_Switch_On_Off_Based_On_Time_of_Day_Interworking_With_RU_DeepSleep_Features.Step 3:Check RU And Cells States
    Log  \n========================================  console=true
    Log  Step 3:Check RU And Cells States\n  console=true
    Log  ========================================  console=true
    Log  Checking that RMOD power state is ${RMOD_DESIRED_SLEEP_STATE}\n  console=true
    Wait Until Keyword Succeeds  15min  30sec  Check RMOD Power State  ${RU_SERIAL_NUMBER}  ${RMOD_DESIRED_SLEEP_STATE}
    Log  Checking that NRFSOPGRP cells are not in energy saving state anymore\n  console=true
    Wait For NRCELs To Reach Expected States  ${NRCEL_IDS}  7min  30sec  ENABLED  NOTENERGYSAVING
    Log  Check RMOD performed reset to enable the cells under it\n  console=true
    Wait Until Keyword Succeeds  3min  30sec  Check If RMOD Performed Reset  ${RMOD_DISTNAME}  ${RMOD_RESET_UPTIME_LIMIT}
    Log  Check that RMOD's new power state is AWAKE\n  console=true
    Wait Until Keyword Succeeds  5min  30sec  Check RMOD Power State  ${RU_SERIAL_NUMBER}  AWAKE


PS.62_CB012087_A_5G_Cell_Switch_On_Off_Based_On_Time_of_Day_Interworking_With_RU_DeepSleep_Features.Test Specific Teardown
    Log To Console  \n============ SPECIFIC TEST TEARDOWN =============
    Log  Setting energy saving mode of RMOD back to NORMAL\n  console=true
    admin.Perform Parameter Recommissioning    ${RMOD_DISTNAME}  energySavingMode  update  NORMAL  skip_parameter_relation_errors=True
    Log  Setting feature flag actForcedCellSwitchOff back to false value\n  console=true
    Set Feature Under Given Object  ${NRBTS_DistName}  ${FEATURE_FLAGS}  false
    Log  Deleting NRFSOPGRP\n  console=true
    Remove Old NRFSOPGRPs Objects If Existing
    Log  Check if any unexpected alarm occured\n  console=true
    Check If Unexpected Alarms Are Raised  ${skip_fault}
    Log To Console  ========== SPECIFIC TEST TEARDOWN DONE ==========\n


PS.62_CB012087_A_5G_Cell_Switch_On_Off_Based_On_Time_of_Day_Interworking_With_RU_DeepSleep_Features.Test Case Teardown
    PS.62_CB012087_A_5G_Cell_Switch_On_Off_Based_On_Time_of_Day_Interworking_With_RU_DeepSleep_Features.Test Specific Teardown
    Common Test Teardown
