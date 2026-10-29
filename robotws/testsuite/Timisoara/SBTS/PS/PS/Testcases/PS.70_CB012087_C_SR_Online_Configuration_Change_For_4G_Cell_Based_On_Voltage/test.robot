*** Settings ***
Resource    ../../../resources/common.robot
Resource    ../../../resources/alarms.robot
Resource    ../../../resources/power_saving.robot
Library    ute_admin_infomodel

Documentation
...  TEST NAME:     PS.70_CB012087_C_SR_Online_Configuration_Change_For_4G_Cell_Based_On_Voltage
...  AUTHORS:       victor.banicioiu@nokia.com
...  MAINTAINER:    TIM_5_Vrf    victor.banicioiu@nokia.com
...  FEATURE:       CB012087
...  *****************
...  Basic information
...  *****************
...  Purpose of the test is online modification of parameters related to 4G Cell switch off based on Voltage
...  *****************
...  Pre-conditions
...  *****************
...  All RAT are onAir and no active alarms are visible
...  ******************
...  History of changes
...  ******************
...  27.06.2025 - https://jiradc.ext.net.nokia.com/browse/TAT-29461 - TC creation
...  *******************

*** Variables ***
${RMOD_SN}    BL1844G11L5
${LNCEL_ID}    48040
${SHELL_PATH}  /home/ute/MN/UTE/robotws/testsuite/Timisoara/SBTS/PS/resources/voltage_scripts/


*** Keywords ***
PS.70_CB012087_C_SR_Online_Configuration_Change_For_4G_Cell_Based_On_Voltage
    PS.70_CB012087_C_SR_Online_Configuration_Change_For_4G_Cell_Based_On_Voltage.Step 0: Preparing Environment
    PS.70_CB012087_C_SR_Online_Configuration_Change_For_4G_Cell_Based_On_Voltage.Step 1: Creating And Activating The FSOPSGRP
    PS.70_CB012087_C_SR_Online_Configuration_Change_For_4G_Cell_Based_On_Voltage.Step 2: Changing Switch Off Voltage
    PS.70_CB012087_C_SR_Online_Configuration_Change_For_4G_Cell_Based_On_Voltage.Step 3: Delete MOC
    PS.70_CB012087_C_SR_Online_Configuration_Change_For_4G_Cell_Based_On_Voltage.Step 4: Creating And Activating The FSOPSGRP
    PS.70_CB012087_C_SR_Online_Configuration_Change_For_4G_Cell_Based_On_Voltage.Step 5: Changing Switch Off Voltage
    PS.70_CB012087_C_SR_Online_Configuration_Change_For_4G_Cell_Based_On_Voltage.Step 3: Delete MOC


PS.70_CB012087_C_SR_Online_Configuration_Change_For_4G_Cell_Based_On_Voltage.Step 0: Preparing Environment
    Log  \n========================================  console=true
    Log  Step 0: Preparing Environment\n  console=true
    Log  ========================================  console=true
    Setup Infomodel  192.168.255.129
    Connect Infomodel
    @{FEATURE_FLAGS}  Create List  actForcedCellSwitchOff
    Set Test Variable  ${FEATURE_FLAGS}
    Change FEATCADM Parameter  actPowerMeter  true
    ${LNBTS_ID}  Get LNBTS ID
    Set Test Variable  ${LNBTS_ID}
    @{LNCEL_IDS}  Create List  ${LNCEL_ID}
    Set Test Variable  ${LNCEL_IDS}
    @{states_to_check}  Create List  availabilityStatus  administrativeState  blockingState
    @{expected_states}  Create List  -  UNLOCKED  UNBLOCKED
    Check Cell States For Specific Cell  LNCEL  ${LNCEL_ID}  ${states_to_check}  ${expected_states}
	${rmod_distname}  ${RMOD_INT_NAME}  Get RMOD DistName And Internal Name Based On Serial Number  ${RMOD_SN}
	Set Test Variable  ${RMOD_INT_NAME}


PS.70_CB012087_C_SR_Online_Configuration_Change_For_4G_Cell_Based_On_Voltage.Step 1: Creating And Activating The FSOPSGRP
    Log  \n========================================  console=true
    Log  Step 1: Creating And Activating The FSOPSGRP\n  console=true
    Log  ========================================  console=true
    Log  Deleting any old FSOPSGRP that was already on the BTS\n  console=true
    Remove Old FSOPSGRP Objects If Present
    Create And Activate FSOPSGRP Based On Voltage  ${LNCEL_IDS}  480  500
    Log  Set actForcedCellSwitchOff flag to true\n  console=true
    Set Feature Under Given Object  ${LNBTS_DistName}  ${FEATURE_FLAGS}  true
	Log  Set voltage on RU ${RMOD_SN} on 46V\n  console=true
    Set Voltage For RU Based On Serial Number  ${SHELL_PATH}  ${RMOD_SN}  SET_LOW_46
	Log  Check voltage value on RU ${RMOD_SN} is below 48V\n  console=true
    Wait Until Keyword Succeeds  3min  30sec  Check Voltage For RU Based On RMOD Internal Name  ${RMOD_INT_NAME}  LOWER_THAN  47.0
	@{states_to_check}  Create List  operationalState  energySavingState
    @{expected_states}  Create List  DISABLED  ENERGYSAVING
    Wait For Specific Cell To Reach Expected States  LNCEL  ${LNCEL_IDS}  15min  30sec  ${states_to_check}  ${expected_states}


PS.70_CB012087_C_SR_Online_Configuration_Change_For_4G_Cell_Based_On_Voltage.Step 2: Changing Switch Off Voltage
    Log  \n========================================  console=true
    Log  Step 2: Changing Switch Off Voltage\n  console=true
    Log  ========================================  console=true
	Log  Modify the lower voltage threshold of the FSOPSGRP to 47V\n  console=true
	Modify Voltage Threshold For Existing FSOPSGRP  FSOPSGRP-2  470  500
	@{states_to_check}  Create List  operationalState  energySavingState
    @{expected_states}  Create List  DISABLED  ENERGYSAVING
	Log  Checking that cell ${LNCEL_ID} is still in energy saving state after changing Low Voltage value\n
	Check Cell States For Specific Cell  LNCEL  ${LNCEL_ID}  ${states_to_check}  ${expected_states}
	Log  Set voltage on RU ${RMOD_SN} on 52V\n  console=true
    Set Voltage For RU Based On Serial Number  ${SHELL_PATH}  ${RMOD_SN}  RAISE
	Log  Check voltage value on RU ${RMOD_SN} is higher than 50V\n  console=true
    Wait Until Keyword Succeeds  3min  30sec  Check Voltage For RU Based On RMOD Internal Name  ${RMOD_INT_NAME}  GREATER_THAN  51.0
	Log  Checking that cell ${LNCEL_ID} is not in energy saving state after changing RMOD voltage to 52V\n
	Remove Values From List  ${expected_states}  DISABLED  ENERGYSAVING
    Append To List  ${expected_states}  ENABLED  NOTENERGYSAVING
    Sleep  120  Wait for cell to exit energy saving state
	Check Cell States For Specific Cell  LNCEL  ${LNCEL_ID}  ${states_to_check}  ${expected_states}


PS.70_CB012087_C_SR_Online_Configuration_Change_For_4G_Cell_Based_On_Voltage.Step 3: Delete MOC
    Log  \n========================================  console=true
    Log  Step 3: Delete MOC\n  console=true
    Log  ========================================  console=true
    Log  Set actForcedCellSwitchOff flag to true\n  console=true
    Set Feature Under Given Object  ${LNBTS_DistName}  ${FEATURE_FLAGS}  false
    Log  Deleting any old FSOPSGRP that was already on the BTS\n  console=true
    Remove Old FSOPSGRP Objects If Present


PS.70_CB012087_C_SR_Online_Configuration_Change_For_4G_Cell_Based_On_Voltage.Step 4: Creating And Activating The FSOPSGRP
    Log  \n========================================  console=true
    Log  Step 4: Creating And Activating The FSOPSGRP\n  console=true
    Log  ========================================  console=true
    Create And Activate FSOPSGRP Based On Voltage  ${LNCEL_IDS}  480  500
    Log  Set actForcedCellSwitchOff flag to true\n  console=true
    Set Feature Under Given Object  ${LNBTS_DistName}  ${FEATURE_FLAGS}  true
    Log  Set voltage on RU ${RMOD_SN} on 46V\n  console=true
    Set Voltage For RU Based On Serial Number  ${SHELL_PATH}  ${RMOD_SN}  SET_LOW_46
	Log  Check voltage value on RU ${RMOD_SN} is below 48V\n  console=true
    Wait Until Keyword Succeeds  3min  30sec  Check Voltage For RU Based On RMOD Internal Name  ${RMOD_INT_NAME}  LOWER_THAN  47.0
	@{states_to_check}  Create List  operationalState  energySavingState
    @{expected_states}  Create List  DISABLED  ENERGYSAVING
    Wait For Specific Cell To Reach Expected States  LNCEL  ${LNCEL_IDS}  15min  30sec  ${states_to_check}  ${expected_states}


PS.70_CB012087_C_SR_Online_Configuration_Change_For_4G_Cell_Based_On_Voltage.Step 5: Changing Switch Off Voltage
	Log  \n========================================  console=true
    Log  Step 5: Changing Switch Off Voltage\n  console=true
    Log  ========================================  console=true
	Log  Modify the lower voltage threshold of the FSOPSGRP to 45V\n  console=true
	Modify Voltage Threshold For Existing FSOPSGRP  FSOPSGRP-2  440  450
    @{states_to_check}  Create List  operationalState  energySavingState
    @{expected_states}  Create List  ENABLED  NOTENERGYSAVING
    Sleep  240  Wait for cells to exit energy saving state
	Check Cell States For Specific Cell  LNCEL  ${LNCEL_ID}  ${states_to_check}  ${expected_states}
	Log  Set voltage on RU ${RMOD_SN} on 52V\n  console=true
    Set Voltage For RU Based On Serial Number  ${SHELL_PATH}  ${RMOD_SN}  RAISE
	Log  Check voltage value on RU ${RMOD_SN} is higher than 50V\n  console=true
    Wait Until Keyword Succeeds  3min  30sec  Check Voltage For RU Based On RMOD Internal Name  ${RMOD_INT_NAME}  GREATER_THAN  51.0
	Log  Checking that cell ${LNCEL_ID} is not in energy saving state after changing RMOD voltage to 52V\n
	Check Cell States For Specific Cell  LNCEL  ${LNCEL_ID}  ${states_to_check}  ${expected_states}


PS.70_CB012087_C_SR_Online_Configuration_Change_For_4G_Cell_Based_On_Voltage.Test Specific Teardown
    Log To Console  \n============ SPECIFIC TEST TEARDOWN =============
    Log  Setting feature flag actForcedCellSwitchOff back to false value\n  console=true
    Set Feature Under Given Object  ${LNBTS_DistName}  ${FEATURE_FLAGS}  false
    Log  Deleting any old FSOPSGRP that was already on the BTS\n  console=true
    Remove Old FSOPSGRP Objects If Present
    Teardown Infomodel
	Log  Set voltage on RU ${RMOD_SN} on 52V\n  console=true
    Set Voltage For RU Based On Serial Number  ${SHELL_PATH}  ${RMOD_SN}  RAISE
	Log  Check voltage value on RU ${RMOD_SN} is higher than 51V\n  console=true
    Wait Until Keyword Succeeds  3min  30sec  Check Voltage For RU Based On RMOD Internal Name  ${RMOD_INT_NAME}  GREATER_THAN  51.0
    Log  Check if any unexpected alarm occured\n  console=true
    Check If Unexpected Alarms Are Raised  ${skip_fault}
    Log To Console  ========== SPECIFIC TEST TEARDOWN DONE ==========\n


PS.70_CB012087_C_SR_Online_Configuration_Change_For_4G_Cell_Based_On_Voltage.Test Case Teardown
    PS.70_CB012087_C_SR_Online_Configuration_Change_For_4G_Cell_Based_On_Voltage.Test Specific Teardown
    Common Test Teardown
