*** Settings ***
Resource    ../../../resources/common.robot
Resource    ../../../resources/alarms.robot
Resource    ../../../resources/power_saving.robot
Library    ute_admin_infomodel

Documentation
...  TEST NAME:     PS.63_CB012087_A_5G_Cell_Switch_On_Off_Based_On_Low_Voltage_Interworking_With_RU_Deep_Sleep_Features
...  AUTHORS:       victor.banicioiu@nokia.com
...  MAINTAINER:    TIM_5_Vrf    victor.banicioiu@nokia.com
...  FEATURE:       CB012087
...  *****************
...  Basic information
...  *****************
...  Purpose of the test is to verify cell switch off/on based on Lowe Voltage and interworking  of 5G SA FDD+TDD Cell
...  switch off/on based on Low Voltage with RU Deep Sleep feature.
...  *****************
...  Pre-conditions
...  *****************
...  All RAT are onAir and no active alarms are visible
...  ******************
...  History of changes
...  ******************
...  16.10.2024 - https://jiradc.ext.net.nokia.com/browse/TAT-28232 - TC creation
...  *******************


*** Variables ***
${FDD_RU_SERIAL_NUMBER}  BL1844G11L5
${TDD_RU_SERIAL_NUMBER}  L1244007372
${RMOD_RESET_UPTIME_LIMIT}  600
${SHELL_PATH}  /home/ute/MN/UTE/robotws/testsuite/Timisoara/SBTS/PS/resources/voltage_scripts/


*** Keywords ***
PS.63_CB012087_A_5G_Cell_Switch_On_Off_Based_On_Low_Voltage_Interworking_With_RU_Deep_Sleep_Features
    PS.63_CB012087_A_5G_Cell_Switch_On_Off_Based_On_Low_Voltage_Interworking_With_RU_Deep_Sleep_Features.Step0: Preparing Environment
    PS.63_CB012087_A_5G_Cell_Switch_On_Off_Based_On_Low_Voltage_Interworking_With_RU_Deep_Sleep_Features.Step1: Creating And Activating The NRFSOPGRP
    PS.63_CB012087_A_5G_Cell_Switch_On_Off_Based_On_Low_Voltage_Interworking_With_RU_Deep_Sleep_Features.Step2: Activate Features And ES Mode
    PS.63_CB012087_A_5G_Cell_Switch_On_Off_Based_On_Low_Voltage_Interworking_With_RU_Deep_Sleep_Features.Step3: Modify Voltage And Check Status
    PS.63_CB012087_A_5G_Cell_Switch_On_Off_Based_On_Low_Voltage_Interworking_With_RU_Deep_Sleep_Features.Step4: Check RU And Cells States


PS.63_CB012087_A_5G_Cell_Switch_On_Off_Based_On_Low_Voltage_Interworking_With_RU_Deep_Sleep_Features.Step0: Preparing Environment
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
    ${TDD_NRCELS}  Get NRCEL List Of Specified Duplex Under RMOD  ${TDD_RU_SERIAL_NUMBER}  TDD
    ${fdd_nrcels}  Get NRCEL List Of Specified Duplex Under RMOD  ${FDD_RU_SERIAL_NUMBER}  FDD
    ${FDD_RANDOM}  Evaluate  random.sample(${fdd_nrcels}, 1)  random
    @{NRCEL_IDS}  Create List
    ${fdd_cell}  Convert To Integer  ${FDD_RANDOM}[-1]
    Append To List  ${NRCEL_IDS}  ${fdd_cell}
    FOR  ${cell}  IN  @{TDD_NRCELS}
        ${cell_id}  Convert To Integer  ${cell}
        Append To List  ${NRCEL_IDS}  ${cell_id}
    END
    Set Test Variable  ${NRCEL_IDS}
    Log  Getting the distName for RU ${FDD_RU_SERIAL_NUMBER} and RU ${TDD_RU_SERIAL_NUMBER}\n  console=true
    ${rmod_list}  admin.Get Frm
    FOR  ${rmod}  IN  @{rmod_list}
        ${rmod_serial_number}  Set Variable  ${rmod['serialNumber']}
        ${rmod_id}  Set Variable  ${rmod['id']['configuration']}
        ${rmod_internal_name}  Set Variable  ${rmod['id']['internal']}
        IF  '${rmod_serial_number}'=='${FDD_RU_SERIAL_NUMBER}'
            Set Test Variable  ${FDD_RMOD_DISTNAME}  ${rmod_id}
            ${fdd_internal}  Fetch From Right  ${rmod_internal_name}  /
            Set Test Variable  ${FDD_RMOD_INTERNAL_NAME}  ${fdd_internal}
        ELSE IF  '${rmod_serial_number}'=='${TDD_RU_SERIAL_NUMBER}'
            Set Test Variable  ${TDD_RMOD_DISTNAME}  ${rmod_id}
            ${tdd_internal}  Fetch From Right  ${rmod_internal_name}  /
            Set Test Variable  ${TDD_RMOD_INTERNAL_NAME}  ${tdd_internal}
        END
    END


PS.63_CB012087_A_5G_Cell_Switch_On_Off_Based_On_Low_Voltage_Interworking_With_RU_Deep_Sleep_Features.Step1: Creating And Activating The NRFSOPGRP
    Log  \n========================================  console=true
    Log  Step 1: Creating And Activating The NRFSOPGRP\n  console=true
    Log  ========================================  console=true
    Log  Deleting any old NRFSOPGRP that was already on the BTS\n  console=true
    Remove Old NRFSOPGRPs Objects If Existing
    Log  Creating and activating NRFSOPGRP based on voltage threshold\n  console=true
    Create And Activate NRFSOPGRP Based On Voltage Threshold  ${NRCEL_IDS}  480  500


PS.63_CB012087_A_5G_Cell_Switch_On_Off_Based_On_Low_Voltage_Interworking_With_RU_Deep_Sleep_Features.Step2: Activate Features And ES Mode
    Log  \n========================================  console=true
    Log  Step 2: Activate Features And ES Mode\n  console=true
    Log  ========================================  console=true
    Log  Activate energy saving mode on RU ${TDD_RU_SERIAL_NUMBER}. Set it on DEEPSLEEP\n  console=true
    admin.Perform Parameter Recommissioning    ${TDD_RMOD_DISTNAME}  energySavingMode  update  DEEPSLEEP  skip_parameter_relation_errors=True
    Log  Set actForcedCellSwitchOff flag to true\n  console=true
    Set Feature Under Given Object  ${NRBTS_DistName}  ${FEATURE_FLAGS}  true


PS.63_CB012087_A_5G_Cell_Switch_On_Off_Based_On_Low_Voltage_Interworking_With_RU_Deep_Sleep_Features.Step3: Modify Voltage And Check Status
    Log  \n========================================  console=true
    Log  Step 3: Modify Voltage And Check Status\n  console=true
    Log  ========================================  console=true
    Log  Set voltage on RU ${TDD_RU_SERIAL_NUMBER} on 47V\n  console=true
    Set Voltage For RU Based On Serial Number  ${SHELL_PATH}  ${TDD_RU_SERIAL_NUMBER}  LOWER
    Log  Set voltage on RU ${FDD_RU_SERIAL_NUMBER} on 47V\n  console=true
    Set Voltage For RU Based On Serial Number  ${SHELL_PATH}  ${FDD_RU_SERIAL_NUMBER}  LOWER
    Log  Check voltage value on RU ${TDD_RU_SERIAL_NUMBER} is below 48V\n  console=true
    Wait Until Keyword Succeeds  6min  15sec  Check Voltage For RU Based On RMOD Internal Name  ${TDD_RMOD_INTERNAL_NAME}  LOWER_THAN  48.0
    Log  Check voltage value on RU ${FDD_RU_SERIAL_NUMBER} is below 48V\n  console=true
    Wait Until Keyword Succeeds  3min  30sec  Check Voltage For RU Based On RMOD Internal Name  ${FDD_RMOD_INTERNAL_NAME}  LOWER_THAN  48.0
    Log  Wait for NRCELS in NRFSOPGRP to reach energy saving state\n  console=true
    Wait For NRCELs To Reach Expected States  ${NRCEL_IDS}  15min  30sec  DISABLED  ENERGYSAVING
    Log  Checking that RMOD power state for RU ${TDD_RU_SERIAL_NUMBER} is SLEEP\n  console=true
    Wait Until Keyword Succeeds  7min  30sec  Check RMOD Power State  ${TDD_RU_SERIAL_NUMBER}  SLEEP
    Log  Set voltage on RU ${TDD_RU_SERIAL_NUMBER} on 52V\n  console=true
    Set Voltage For RU Based On Serial Number  ${SHELL_PATH}  ${TDD_RU_SERIAL_NUMBER}  RAISE
    Log  Set voltage on RU ${FDD_RU_SERIAL_NUMBER} on 52V\n  console=true
    Set Voltage For RU Based On Serial Number  ${SHELL_PATH}  ${FDD_RU_SERIAL_NUMBER}  RAISE
    Log  Check voltage value on RU ${TDD_RU_SERIAL_NUMBER} is above 50V\n  console=true
    Wait Until Keyword Succeeds  5min  30sec  Check Voltage For RU Based On RMOD Internal Name  ${TDD_RMOD_INTERNAL_NAME}  GREATER_THAN  50.0
    Log  Check voltage value on RU ${FDD_RU_SERIAL_NUMBER} is above 50V\n  console=true
    Wait Until Keyword Succeeds  5min  50sec  Check Voltage For RU Based On RMOD Internal Name  ${FDD_RMOD_INTERNAL_NAME}  GREATER_THAN  50.0


PS.63_CB012087_A_5G_Cell_Switch_On_Off_Based_On_Low_Voltage_Interworking_With_RU_Deep_Sleep_Features.Step4: Check RU And Cells States
    Log  \n========================================  console=true
    Log  Step 4: Check RU And Cells States\n  console=true
    Log  ========================================  console=true
    Log  Checking that NRFSOPGRP cells are not in energy saving state anymore\n  console=true
    Wait For NRCELs To Reach Expected States  ${NRCEL_IDS}  8min  30sec  ENABLED  NOTENERGYSAVING
    Log  Check RMOD performed reset to enable the cells under it\n  console=true
    Wait Until Keyword Succeeds  3min  30sec  Check If RMOD Performed Reset  ${TDD_RMOD_DISTNAME}  ${RMOD_RESET_UPTIME_LIMIT}
    Log  Check that RMOD's new power state is AWAKE\n  console=true
    Wait Until Keyword Succeeds  5min  10sec  Check RMOD Power State  ${TDD_RU_SERIAL_NUMBER}  AWAKE


PS.63_CB012087_A_5G_Cell_Switch_On_Off_Based_On_Low_Voltage_Interworking_With_RU_Deep_Sleep_Features.Test Specific Teardown
    Log To Console  \n============ SPECIFIC TEST TEARDOWN =============
    Log  Setting energy saving mode of RMOD back to NORMAL\n  console=true
    admin.Perform Parameter Recommissioning  ${TDD_RMOD_DISTNAME}  energySavingMode  update  NORMAL    skip_parameter_relation_errors=True
    Log  Setting feature flag actForcedCellSwitchOff back to false value\n  console=true
    Set Feature Under Given Object  ${NRBTS_DistName}  ${FEATURE_FLAGS}  false
    Log  Deleting NRFSOPGRP\n  console=true
    Remove Old NRFSOPGRPs Objects If Existing
    Log  Check if any unexpected alarm occured\n  console=true
    Check If Unexpected Alarms Are Raised  ${skip_fault}
    Teardown Infomodel
    Log To Console  ========== SPECIFIC TEST TEARDOWN DONE ==========\n


PS.63_CB012087_A_5G_Cell_Switch_On_Off_Based_On_Low_Voltage_Interworking_With_RU_Deep_Sleep_Features.Test Case Teardown
    PS.63_CB012087_A_5G_Cell_Switch_On_Off_Based_On_Low_Voltage_Interworking_With_RU_Deep_Sleep_Features.Test Specific Teardown
    Common Test Teardown
