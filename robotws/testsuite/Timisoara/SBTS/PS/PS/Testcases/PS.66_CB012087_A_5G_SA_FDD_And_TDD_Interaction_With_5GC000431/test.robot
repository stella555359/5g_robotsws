*** Settings ***
Resource    ../../../resources/common.robot
Resource    ../../../resources/alarms.robot
Resource    ../../../resources/power_saving.robot

Documentation
...  TEST NAME:     PS.66_CB012087_A_5G_SA_FDD_And_TDD_Interaction_With_5GC000431
...  AUTHORS:       victor.banicioiu@nokia.com
...  MAINTAINER:    TIM_5_Vrf    victor.banicioiu@nokia.com
...  FEATURE:       CB012087
...  *****************
...  Basic information
...  *****************
...  Purpose of this test case is to verify the interaction between CB012087-A and 5GC000431, respectively that
...  CB012087-A have priority in case of both features activated on the same cell.
...  *****************
...  Pre-conditions
...  *****************
...  All RAT are onAir and no active alarms are visible
...  ******************
...  History of changes
...  ******************
...  05.12.2024 - https://jiradc.ext.net.nokia.com/browse/TAT-28495 - TC creation
...  *******************


*** Variables ***
${RU_SERIAL_NUMBER}  L1244007372  #targeted RU serial number


*** Keywords ***
PS.66_CB012087_A_5G_SA_FDD_And_TDD_Interaction_With_5GC000431
    PS.66_CB012087_A_5G_SA_FDD_And_TDD_Interaction_With_5GC000431.Step 0: Preparing Environment
    PS.66_CB012087_A_5G_SA_FDD_And_TDD_Interaction_With_5GC000431.Step 1: Creating And Activating NRPGRP
    PS.66_CB012087_A_5G_SA_FDD_And_TDD_Interaction_With_5GC000431.Step 2: Creating And Activating NRFSOPGRP
    PS.66_CB012087_A_5G_SA_FDD_And_TDD_Interaction_With_5GC000431.Step 3: Check Interworking Of Features


PS.66_CB012087_A_5G_SA_FDD_And_TDD_Interaction_With_5GC000431.Step 0: Preparing Environment
    Log  \n========================================  console=true
    Log  Step 0: Preparing Environment\n  console=true
    Log  ========================================  console=true
    @{FEATURE_FLAGS_CB012087}  Create List  actForcedCellSwitchOff
    Set Test Variable  ${FEATURE_FLAGS_CB012087}
    @{FEATURE_FLAGS_5GC000431}  Create List  actNrLBPowerSaving
    Set Test Variable  ${FEATURE_FLAGS_5GC000431}
    ${found_rmod_flag}  Set Variable  ${False}
    ${rmod_list}  admin.Get Frm
    Log  Getting the required RMOD and the cells under it\n  console=true
    FOR  ${rmod}  IN  @{rmod_list}
        ${rmod_serial_number}  Set Variable  ${rmod['serialNumber']}
        ${rmod_id}  Set Variable  ${rmod['id']['configuration']}
        ${rmod_internal_id}  Set Variable  ${rmod['id']['internal']}
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


PS.66_CB012087_A_5G_SA_FDD_And_TDD_Interaction_With_5GC000431.Step 1: Creating And Activating NRPGRP
    Log  \n========================================  console=true
    Log  Step 1: Creating And Activating NRPGRP\n  console=true
    Log  ========================================  console=true
    Log  Deleting any old NRPGRP that was already on the BTS\n  console=true
    Remove PSGRP/NRPGRP Objects If Exist  NRPGRP
    Log  Creating and activating NRPGRP\n  console=true
    @{FIRST_NRCELL}  Create List
    ${nrcell}  Convert To Integer  ${NRCEL_IDS}[0]
    Append To List  ${FIRST_NRCELL}  ${nrcell}
    Set Test Variable  ${FIRST_NRCELL}
    Create And Activate NRPGRP With 5GC000431  ${FIRST_NRCELL}  5 minutes  30
    Log  Set actNrLBPowerSaving flag to true\n  console=true
    Set Feature Under Given Object  ${NRBTS_DistName}  ${FEATURE_FLAGS_5GC000431}  true


PS.66_CB012087_A_5G_SA_FDD_And_TDD_Interaction_With_5GC000431.Step 2: Creating And Activating NRFSOPGRP
    Log  \n========================================  console=true
    Log  Step 2: Creating And Activating NRFSOPGRP\n  console=true
    Log  ========================================  console=true
    Log  Deleting any old NRFSOPGRP that was already on the BTS\n  console=true
    Remove Old NRFSOPGRPs Objects If Existing
    Log  Creating and activating NRFSOPGRP based on time window\n  console=true
    Create And Activate NRFSOPGRP Based On Time Windows  ${FIRST_NRCELL}  15 minutes  30
    Log  Set actForcedCellSwitchOff flag to true\n  console=true
    Set Feature Under Given Object  ${NRBTS_DistName}  ${FEATURE_FLAGS_CB012087}  true


PS.66_CB012087_A_5G_SA_FDD_And_TDD_Interaction_With_5GC000431.Step 3: Check Interworking Of Features
    Log  \n========================================  console=true
    Log  Step 3: Check Interworking Of Features\n  console=true
    Log  ========================================  console=true
    Log  Test enters pause until NRPGRP time window starts\n  console=true
    Sleep Until Given Date  ${TIME_WITH_OFFSET_NRPGRP}
    Log  Check that selected cell's energy saving state is EnergySaving after NRPGRP time window starts\n  console=true
    Wait For NRCELs To Reach Expected States  ${FIRST_NRCELL}  10min  30sec  DISABLED  ENERGYSAVING
    Log  Test enters pause until energy saving time window of NRFSOPGRP is reached.\n  console=true
    Sleep Until Given Date  ${END_TIME_NRPGRP}
    Log  Check that selected cell's energy saving state is still EnergySaving after the end of NRPGRP time window\n  console=true
    Wait For NRCELs To Reach Expected States  ${FIRST_NRCELL}  1min  30sec  DISABLED  ENERGYSAVING
    Log  Test enters pause until energy saving time window of NRFSOPGRP is over.\n  console=true
    Sleep Until Given Date  ${END_TIME}
    Log  Check that selected cell's energy saving state is NotEnergySaving after the end of NRFSOPGRP time window\n  console=true
    Wait For NRCELs To Reach Expected States  ${FIRST_NRCELL}  5min  30sec  ENABLED  NOTENERGYSAVING


PS.66_CB012087_A_5G_SA_FDD_And_TDD_Interaction_With_5GC000431.Test Specific Teardown
    Log To Console  \n============ SPECIFIC TEST TEARDOWN =============
    Log  Setting feature flag actForcedCellSwitchOff back to false value\n  console=true
    Set Feature Under Given Object  ${NRBTS_DistName}  ${FEATURE_FLAGS_CB012087}  false
    Log  Setting feature flag actNrLBPowerSaving back to false value\n  console=true
    Set Feature Under Given Object  ${NRBTS_DistName}  ${FEATURE_FLAGS_5GC000431}  false
    Log  Deleting NRFSOPGRPs\n  console=true
    Remove Old NRFSOPGRPs Objects If Existing
    Log  Deleting NRPGRPs\n  console=true
    Remove PSGRP/NRPGRP Objects If Exist  NRPGRP
    Log  Check if any unexpected alarm occured\n  console=true
    Check If Unexpected Alarms Are Raised  ${skip_fault}
    Log To Console  ========== SPECIFIC TEST TEARDOWN DONE ==========\n


PS.66_CB012087_A_5G_SA_FDD_And_TDD_Interaction_With_5GC000431.Test Case Teardown
    PS.66_CB012087_A_5G_SA_FDD_And_TDD_Interaction_With_5GC000431.Test Specific Teardown
    Common Test Teardown
