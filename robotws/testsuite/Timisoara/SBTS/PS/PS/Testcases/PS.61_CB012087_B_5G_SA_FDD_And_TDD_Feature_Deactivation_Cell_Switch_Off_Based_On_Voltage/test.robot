*** Settings ***
Resource    ../../../resources/common.robot
Resource    ../../../resources/alarms.robot
Resource    ../../../resources/power_saving.robot

Documentation
...  TEST NAME:     PS.61_CB012087_B_5G_SA_FDD_And_TDD_Feature_Deactivation_Cell_Switch_Off_Based_On_Voltage
...  AUTHORS:       victor.banicioiu@nokia.com
...  MAINTAINER:    TIM_5_Vrf    victor.banicioiu@nokia.com
...  FEATURE:       CB012087
...  *****************
...  Basic information
...  *****************
...  Purpose of the test is de-activation of 5G SA FDD+TDD Cell switch off based on voltage threshold.
...  *****************
...  Pre-conditions
...  *****************
...  All RAT are onAir and no active alarms are visible
...  ******************
...  History of changes
...  ******************
...  06.09.2024 - https://jiradc.ext.net.nokia.com/browse/TAT-28045 - TC creation
...  *******************


*** Keywords ***
PS.61_CB012087_B_5G_SA_FDD_And_TDD_Feature_Deactivation_Cell_Switch_Off_Based_On_Voltage
    PS.61_CB012087_B_5G_SA_FDD_And_TDD_Feature_Deactivation_Cell_Switch_Off_Based_On_Voltage.Step 0: Preparing Environment
    PS.61_CB012087_B_5G_SA_FDD_And_TDD_Feature_Deactivation_Cell_Switch_Off_Based_On_Voltage.Step 1: Deleting And Deactivating NRFSOPGRP


PS.61_CB012087_B_5G_SA_FDD_And_TDD_Feature_Deactivation_Cell_Switch_Off_Based_On_Voltage.Step 0: Preparing Environment
    Log  \n========================================  console=true
    Log  Step 0: Preparing Environment\n  console=true
    Log  ========================================  console=true
    @{FEATURE_FLAGS}  Create List  actForcedCellSwitchOff
    Set Test Variable  ${FEATURE_FLAGS}
    Log  Verifying all cells in NRFSOPGRPs are in ENABLED/NOTENERGYSAVING state\n  console=true
    Verifying Cells In NRFSOPGRP Are In Expected States  ENABLED  NOTENERGYSAVING


PS.61_CB012087_B_5G_SA_FDD_And_TDD_Feature_Deactivation_Cell_Switch_Off_Based_On_Voltage.Step 1: Deleting And Deactivating NRFSOPGRP
    Log  \n========================================  console=true
    Log  Step 1: Deleting And Deactivating NRFSOPGRP\n  console=true
    Log  ========================================  console=true
    Set Feature Under Given Object  ${NRBTS_DistName}  ${FEATURE_FLAGS}  false
    ${nrfsopgrp_exists}  Set Variable  ${True}
    ${nrfsopgrp_list}  admin.Get Managed Objects  NRFSOPGRP_A
    ${list_length_before}  Get Length  ${nrfsopgrp_list}
    ${nrfsopgrp_exists}  Set Variable If  ${list_length_before}>0  ${True}  ${False}
    Remove Old NRFSOPGRPs Objects If Existing
    ${nrsfopgrp_list_after}  admin.Get Managed Objects  NRFSOPGRP_A
    ${list_length_after}  Get Length  ${nrsfopgrp_list_after}
    IF  ${list_length_after}==0 and ${nrfsopgrp_exists}
        Log  Existing NRFSOPGRP have been successfully deleted. [OK]\n  console=true
    ELSE IF  ${list_length_after}==0 and not ${nrfsopgrp_exists}
        Log  There were no NRFSOPGRPs to delete\n  console=true
    ELSE IF  ${list_length_after}>0 and ${nrfsopgrp_exists}
        Fail  Something went wrong and the NRFSOPGRPs could not be deleted. [NOK]
    END
    Check If Unexpected Alarms Are Raised  ${skip_fault}


PS.61_CB012087_B_5G_SA_FDD_And_TDD_Feature_Deactivation_Cell_Switch_Off_Based_On_Voltage.Test Specific Teardown
    Log To Console  \n============ SPECIFIC TEST TEARDOWN =============
    Log  No test specific teardown procedure needed\n  console=true
    Log To Console  ========== SPECIFIC TEST TEARDOWN DONE ==========\n


PS.61_CB012087_B_5G_SA_FDD_And_TDD_Feature_Deactivation_Cell_Switch_Off_Based_On_Voltage.Test Case Teardown
    Common Test Teardown
    PS.61_CB012087_B_5G_SA_FDD_And_TDD_Feature_Deactivation_Cell_Switch_Off_Based_On_Voltage.Test Specific Teardown
