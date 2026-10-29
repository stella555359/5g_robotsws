*** Settings ***
Resource    ../../../resources/common.robot
Resource    ../../../resources/alarms.robot
Resource    ../../../resources/power_saving.robot
Library    ute_admin_infomodel


Documentation
...  TEST NAME:     PS.64_CB012087_A_5G_Cell_Switch_Off_On_Based_On_Time_Of_Day_Interworking_With_Low_Voltage
...  AUTHORS:       victor.banicioiu@nokia.com
...  MAINTAINER:    TIM_5_Vrf    victor.banicioiu@nokia.com
...  FEATURE:       CB012087
...  *****************
...  Basic information
...  *****************
...  Purpose of the test is to verify 5G SA cell switch off/on based on Time of Day interworking with 5G SA FDD+TDD Cell
...  switch off/on based on Low Voltage.
...  *****************
...  Pre-conditions
...  *****************
...  All RAT are onAir and no active alarms are visible
...  ******************
...  History of changes
...  ******************
...  16.10.2024 - https://jiradc.ext.net.nokia.com/browse/TAT-28233 - TC creation
...  *******************


*** Variables ***
${FDD_RU_SERIAL_NUMBER}  BL1844G11L5
${TDD_RU_SERIAL_NUMBER}  L1244007372
${SHELL_PATH}  /home/ute/MN/UTE/robotws/testsuite/Timisoara/SBTS/PS/resources/voltage_scripts/


*** Keywords ***
PS.64_CB012087_A_5G_Cell_Switch_Off_On_Based_On_Time_Of_Day_Interworking_With_Low_Voltage
    PS.64_CB012087_A_5G_Cell_Switch_Off_On_Based_On_Time_Of_Day_Interworking_With_Low_Voltage.Step0: Preparing Environment
    PS.64_CB012087_A_5G_Cell_Switch_Off_On_Based_On_Time_Of_Day_Interworking_With_Low_Voltage.Step1: Creating And Activating The NRFSOPGRPs
    PS.64_CB012087_A_5G_Cell_Switch_Off_On_Based_On_Time_Of_Day_Interworking_With_Low_Voltage.Step2: Check Interworking Of Features


PS.64_CB012087_A_5G_Cell_Switch_Off_On_Based_On_Time_Of_Day_Interworking_With_Low_Voltage.Step0: Preparing Environment
    Log  \n========================================  console=true
    Log  Step 0: Preparing Environment\n  console=true
    Log  ========================================  console=true
    Setup Infomodel    192.168.255.129
    Connect Infomodel
    @{FEATURE_FLAGS}  Create List  actForcedCellSwitchOff
    Set Test Variable  ${FEATURE_FLAGS}
    Change FEATCADM Parameter  actPowerMeter  true
    Change FEATCADM Parameter  actRadioDeepSleepTimeSchedule  false
    Log  Getting 1 FDD cell from RU ${FDD_RU_SERIAL_NUMBER} and all TDD cells from RU ${TDD_RU_SERIAL_NUMBER}\n  console=true
    ${tdd_nrcels}  Get NRCEL List Of Specified Duplex Under RMOD  ${TDD_RU_SERIAL_NUMBER}  TDD
    ${fdd_nrcels}  Get NRCEL List Of Specified Duplex Under RMOD  ${FDD_RU_SERIAL_NUMBER}  FDD
    ${TDD_RANDOM}  Evaluate  random.sample(${tdd_nrcels}, 1)  random
    ${FDD_RANDOM}  Evaluate  random.sample(${fdd_nrcels}, 1)  random
    @{NRCEL_IDS}  Create List
    ${tdd_cell}  Convert To Integer  ${TDD_RANDOM}[-1]
    ${fdd_cell}  Convert To Integer  ${FDD_RANDOM}[-1]
    Append To List  ${NRCEL_IDS}  ${tdd_cell}  ${fdd_cell}
    Set Test Variable  ${NRCEL_IDS}
    Log  Getting the distName for RU ${FDD_RU_SERIAL_NUMBER} and RU ${TDD_RU_SERIAL_NUMBER}\n  console=true
    ${rmod_list}  admin.Get Frm
    FOR  ${rmod}  IN  @{rmod_list}
        ${rmod_serial_number}  Set Variable  ${rmod['serialNumber']}
        ${rmod_internal_name}  Set Variable  ${rmod['id']['internal']}
        IF  '${rmod_serial_number}'=='${FDD_RU_SERIAL_NUMBER}'
            ${fdd_internal}  Fetch From Right  ${rmod_internal_name}  /
            Set Test Variable  ${FDD_RMOD_INTERNAL_NAME}  ${fdd_internal}
        ELSE IF  '${rmod_serial_number}'=='${TDD_RU_SERIAL_NUMBER}'
            ${tdd_internal}  Fetch From Right  ${rmod_internal_name}  /
            Set Test Variable  ${TDD_RMOD_INTERNAL_NAME}  ${tdd_internal}
        END
    END


PS.64_CB012087_A_5G_Cell_Switch_Off_On_Based_On_Time_Of_Day_Interworking_With_Low_Voltage.Step1: Creating And Activating The NRFSOPGRPs
    Log  \n========================================  console=true
    Log  Step1: Creating And Activating The NRFSOPGRPs\n  console=true
    Log  ========================================  console=true
    Log  Deleting any old NRFSOPGRP that was already on the BTS\n  console=true
    Remove Old NRFSOPGRPs Objects If Existing
    Log  Creating and activating NRFSOPGRP based on time window\n  console=true
    Create And Activate NRFSOPGRP Based On Time Windows  ${NRCEL_IDS}  5 minutes  10
    Log  Creating and activating NRFSOPGRP based on voltage threshold\n  console=true
    Create And Activate NRFSOPGRP Based On Voltage Threshold  ${NRCEL_IDS}  480  500
    Log  Set actForcedCellSwitchOff flag to true\n  console=true
    Set Feature Under Given Object  ${NRBTS_DistName}  ${FEATURE_FLAGS}  true


PS.64_CB012087_A_5G_Cell_Switch_Off_On_Based_On_Time_Of_Day_Interworking_With_Low_Voltage.Step2: Check Interworking Of Features
    Log  \n========================================  console=true
    Log  Step2: Check Interworking Of Features\n  console=true
    Log  ========================================  console=true
    Log  Wait for NRCELs to enter EnergySaving State due to Time Of Day NRFSOPGRP\n  console=true
    Wait For NRCELs To Reach Expected States  ${NRCEL_IDS}  7min  15sec  DISABLED  ENERGYSAVING
    Check If Unexpected Alarms Are Raised  ${skip_fault}
    Log  Decrease voltage on RU ${TDD_RU_SERIAL_NUMBER} to 47V\n  console=true
    Set Voltage For RU Based On Serial Number  ${SHELL_PATH}  ${TDD_RU_SERIAL_NUMBER}  LOWER
    Log  Decrease voltage on RU ${FDD_RU_SERIAL_NUMBER} to 47V\n  console=true
    Set Voltage For RU Based On Serial Number  ${SHELL_PATH}  ${FDD_RU_SERIAL_NUMBER}  LOWER
    Log  Check the energySaving state and voltage values while fsoDuration is still active and RU voltage was lowered\n  console=true
    Wait For NRCELs To Reach Expected States  ${NRCEL_IDS}  1min  5sec  DISABLED  ENERGYSAVING
    Log  Check voltage value on RU ${TDD_RU_SERIAL_NUMBER} is below 48V\n  console=true
    Wait Until Keyword Succeeds  5min  30sec  Check Voltage For RU Based On RMOD Internal Name  ${TDD_RMOD_INTERNAL_NAME}  LOWER_THAN  48.0
    Log  Check voltage value on RU ${FDD_RU_SERIAL_NUMBER} is below 48V\n  console=true
    Wait Until Keyword Succeeds  5min  30sec  Check Voltage For RU Based On RMOD Internal Name  ${FDD_RMOD_INTERNAL_NAME}  LOWER_THAN  48.0
    Sleep Until Given Date  ${END_TIME}
    Log  Check the energySaving state and voltage values after fsoDuration is over and RU voltage was lowered\n  console=true
    Wait For NRCELs To Reach Expected States  ${NRCEL_IDS}  1min  5sec  DISABLED  ENERGYSAVING
    Log  Check voltage value on RU ${TDD_RU_SERIAL_NUMBER} is below 48V\n  console=true
    Wait Until Keyword Succeeds  5min  30sec  Check Voltage For RU Based On RMOD Internal Name  ${TDD_RMOD_INTERNAL_NAME}  LOWER_THAN  48.0
    Log  Check voltage value on RU ${FDD_RU_SERIAL_NUMBER} is below 48V\n  console=true
    Wait Until Keyword Succeeds  5min  30sec  Check Voltage For RU Based On RMOD Internal Name  ${FDD_RMOD_INTERNAL_NAME}  LOWER_THAN  48.0
    Log  Increase voltage on RU ${TDD_RU_SERIAL_NUMBER} to 52V\n  console=true
    Set Voltage For RU Based On Serial Number  ${SHELL_PATH}  ${TDD_RU_SERIAL_NUMBER}  RAISE
    Log  Increase voltage on RU ${FDD_RU_SERIAL_NUMBER} to 52V\n  console=true
    Set Voltage For RU Based On Serial Number  ${SHELL_PATH}  ${FDD_RU_SERIAL_NUMBER}  RAISE
    Log  Check voltage value on RU ${TDD_RU_SERIAL_NUMBER} is above 50V\n  console=true
    Wait Until Keyword Succeeds  6min  30sec  Check Voltage For RU Based On RMOD Internal Name  ${TDD_RMOD_INTERNAL_NAME}  GREATER_THAN  50.0
    Log  Check voltage value on RU ${FDD_RU_SERIAL_NUMBER} is above 50V\n  console=true
    Wait Until Keyword Succeeds  6min  30sec  Check Voltage For RU Based On RMOD Internal Name  ${FDD_RMOD_INTERNAL_NAME}  GREATER_THAN  50.0
    Log  Check that all NRCELs return to energySavingState NOTENERGYSAVING\n  console=true
    Wait For NRCELs To Reach Expected States  ${NRCEL_IDS}  5min  30sec  ENABLED  NOTENERGYSAVING


PS.64_CB012087_A_5G_Cell_Switch_Off_On_Based_On_Time_Of_Day_Interworking_With_Low_Voltage.Test Specific Teardown
    Log To Console  \n============ SPECIFIC TEST TEARDOWN =============
    Log  Setting feature flag actForcedCellSwitchOff back to false value\n  console=true
    Set Feature Under Given Object  ${NRBTS_DistName}  ${FEATURE_FLAGS}  false
    Log  Deleting NRFSOPGRPs\n  console=true
    Remove Old NRFSOPGRPs Objects If Existing
    Log  Check if any unexpected alarm occured\n  console=true
    Check If Unexpected Alarms Are Raised  ${skip_fault}
    Teardown Infomodel
    Log To Console  ========== SPECIFIC TEST TEARDOWN DONE ==========\n


PS.64_CB012087_A_5G_Cell_Switch_Off_On_Based_On_Time_Of_Day_Interworking_With_Low_Voltage.Test Case Teardown
    PS.64_CB012087_A_5G_Cell_Switch_Off_On_Based_On_Time_Of_Day_Interworking_With_Low_Voltage.Test Specific Teardown
    Common Test Teardown

