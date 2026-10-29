*** Settings ***
Resource    ../../../resources/common.robot
Resource    ../../../resources/alarms.robot
Resource    ../../../resources/power_saving.robot

Documentation
...  TEST NAME:     PS.68_CB008133_NRPGRP_With_mMIMO_And_Non_mMIMO_Cells
...  AUTHORS:       victor.banicioiu@nokia.com
...  MAINTAINER:    TIM_5_Vrf    victor.banicioiu@nokia.com
...  FEATURE:       CB008133
...  *****************
...  Basic information
...  *****************
...  The scope is to check PDL validation and CB010683 feature behaviour when NRPGRP is configured with mMIMO and none mMIMO cells.
...  *****************
...  Pre-conditions
...  *****************
...  gNB is onAir and no active alarms are visible.
...  ******************
...  History of changes
...  ******************
...  22.04.2025 - https://jiradc.ext.net.nokia.com/browse/TAT-29129 - TC creation
...  *******************


*** Keywords ***
PS.68_CB008133_NRPGRP_With_mMIMO_And_Non_mMIMO_Cells
    PS.68_CB008133_NRPGRP_With_mMIMO_And_Non_mMIMO_Cells.Step 0: Preparing Environment
    PS.68_CB008133_NRPGRP_With_mMIMO_And_Non_mMIMO_Cells.Step 1: Creating And Activating NRPGRP
    PS.68_CB008133_NRPGRP_With_mMIMO_And_Non_mMIMO_Cells.Step 2: Modify NRPGRP And actNrLBRTXPowerSaving
    PS.68_CB008133_NRPGRP_With_mMIMO_And_Non_mMIMO_Cells.Step 3: Checking Cell Was Added And Feature State
    PS.68_CB008133_NRPGRP_With_mMIMO_And_Non_mMIMO_Cells.Step 4: Checking Cells Energy Saving State
    PS.68_CB008133_NRPGRP_With_mMIMO_And_Non_mMIMO_Cells.Step 5: Checking Cells Switch Back On


PS.68_CB008133_NRPGRP_With_mMIMO_And_Non_mMIMO_Cells.Step 0: Preparing Environment
    Log  \n========================================  console=true
    Log  Step 0: Preparing Environment\n  console=true
    Log  ========================================  console=true
    @{FEATURE_FLAGS_TRUE}  Create List  actNrExtCellSOMethod  actNrLBPowerSaving  actNrLBmMimoRTXPowerSaving
    @{FEATURE_FLAGS_FALSE}  Create List  actNrLBRTXPowerSaving  actNrMixedSOMethod
    Set Test Variable  ${FEATURE_FLAGS_TRUE}
    Set Test Variable  ${FEATURE_FLAGS_FALSE}
    Get NR MIMO/NotMIMO Cells And RMODS Lists
    @{MIMO_NRCELL}  Evaluate  random.sample(${MIMO_CELLS}, 1)  random
    @{NMIMO_NRCELL}  Evaluate  random.sample(${NOT_MIMO_CELLS}, 2)  random
    Set Test Variable  ${MIMO_NRCELL}
    Set Test Variable  ${NMIMO_NRCELL}
    Check Power Saving NR  ${MIMO_NRCELL}[0]  ENABLED  NOTENERGYSAVING
    ${non_mimo_cell_nbr}  Get Length  ${NMIMO_NRCELL}
    FOR  ${i}  IN RANGE  ${non_mimo_cell_nbr}
        Check Power Saving NR  ${NMIMO_NRCELL}[${i}]  ENABLED  NOTENERGYSAVING
    END
    Log  Selected mMIMO cell is: ${MIMO_NRCELL}[0]\n  console=true
    Log  Selected non-mMIMO cells are: @{NMIMO_NRCELL}\n  console=true


PS.68_CB008133_NRPGRP_With_mMIMO_And_Non_mMIMO_Cells.Step 1: Creating And Activating NRPGRP
    Log  \n========================================  console=true
    Log  Step 1: Creating And Activating NRPGRP\n  console=true
    Log  ========================================  console=true
    Log  Deleting any old NRPGRP that was already on the BTS\n  console=true
    Remove NRPGRP Objects If Exist
    Log  Creating and activating NRPGRP based on time window\n  console=true
    Create And Activate NRPGRP With 1 mMIMO And 1 Non mMIMO  ${MIMO_NRCELL}[0]  ${NMIMO_NRCELL}[0]  5 minutes  55
    Sleep  1200  Wait for for NR RAT reset to finish and for MIMO cell to reach REDUCEDENERGYSAVING
    Check Power Saving for NRCEL  ${MIMO_NRCELL}[0]  ENABLED  REDUCEDENERGYSAVING
    Sleep  500  Wait for ENERGYSAVING
    Check Power Saving for NRCEL  ${NMIMO_NRCELL}[0]  DISABLED  ENERGYSAVING
    Log  Operational and Energy Saving states are as expected on NRPGRP cells\n  console=true


PS.68_CB008133_NRPGRP_With_mMIMO_And_Non_mMIMO_Cells.Step 2: Modify NRPGRP And actNrLBRTXPowerSaving
    Log  \n========================================  console=true
    Log  Step 2: Modify NRPGRP And actNrLBRTXPowerSaving\n  console=true
    Log  ========================================  console=true
    @{cells_to_add}  Create List  ${NMIMO_NRCELL}[1]
    @{cell_so_order_values}  Create List  10
    @{method_to_add}  Create List  TX switch off
    Log  Adding Non mMIMO cell ${NMIMO_NRCELL}[1] to existing NRPGRP\n  console=true
    Add NRCELLS To Existing NRPGRP  ${cells_to_add}  ${cell_so_order_values}  ${method_to_add}  55
    Set Feature Under Given Object  ${NRBTS_DistName}  actNrLBRTXPowerSaving  true


PS.68_CB008133_NRPGRP_With_mMIMO_And_Non_mMIMO_Cells.Step 3: Checking Cell Was Added And Feature State
    Log  \n========================================  console=true
    Log  Step 3: Checking Cell Was Added And Feature State\n  console=true
    Log  ========================================  console=true
    Get Nrcells Ids From NRPGRP
    List Should Contain Value  ${cells_in_nrpgrp}  NRCELL_R-${NMIMO_NRCELL}[1]
    Log  New non mMIMO cell was added successfully\n  console=true
    ${feature_status}  Get Parameter Value Under NRBTS  actNrLBRTXPowerSaving
    IF  '${feature_status}'=='true'
        Log  actNrLBRTXPowerSaving successfully set on true\n  console=true
    ELSE
        Fail  actNrLBRTXPowerSaving could not be set on true. Test cannot continue\n  console=true
    END


PS.68_CB008133_NRPGRP_With_mMIMO_And_Non_mMIMO_Cells.Step 4: Checking Cells Energy Saving State
    Log  \n========================================  console=true
    Log  Step 4: Checking Cells Energy Saving State\n  console=true
    Log  ========================================  console=true
    Log  Waiting for mMIMO NRCEL to reach reduced energy saving state\n  console=true
    Sleep  1200  Waiting 20 mins for cells to enter energy saving state
    Log  Checking that the mMIMO NRCEL reached REDUCEDENERGYSAVING state\n  console=true
    Check Power Saving for NRCEL  ${MIMO_NRCELL}[0]  ENABLED  REDUCEDENERGYSAVING
    Log  Operational and EnergySaving state are as expected for ${MIMO_NRCELL}[0] (ENABLED/REDUCEDENERGYSAVING)\n  console=true
    Log  Checking that the non-mMIMO NRCELs reached ENERGYSAVING state\n  console=true
    Check Power Saving for NRCEL  ${NMIMO_NRCELL}[0]  DISABLED  ENERGYSAVING
    Log  Operational and EnergySaving state are as expected for ${NMIMO_NRCELL}[0] (DISABLED/ENERGYSAVING)\n  console=true
    Check Power Saving for NRCEL  ${NMIMO_NRCELL}[1]  ENABLED  REDUCEDENERGYSAVING
    Log  Operational and EnergySaving state are as expected for ${NMIMO_NRCELL}[1] (ENABLED/REDUCEDENERGYSAVING)\n  console=true


PS.68_CB008133_NRPGRP_With_mMIMO_And_Non_mMIMO_Cells.Step 5: Checking Cells Switch Back On
    Log  \n========================================  console=true
    Log  Step 5: Checking Cells Switch Back On\n  console=true
    Log  ========================================  console=true
    Sleep Until Given Date  ${END_TIME_NRPGRP}
	Sleep  60s
    Log  Checking that both mMIMO and non mMIMO cells switch back on after power saving period ends\n  console=true
    Check Power Saving for NRCEL  ${MIMO_NRCELL}[0]  ENABLED  NOTENERGYSAVING
    Log  Operational and EnergySaving state are as expected for ${MIMO_NRCELL}[0] (ENABLED/NOTENERGYSAVING)\n  console=true
    Check Power Saving for NRCEL  ${NMIMO_NRCELL}[0]  ENABLED  NOTENERGYSAVING
    Log  Operational and EnergySaving state are as expected for ${NMIMO_NRCELL}[0] (DISABLED/ENERGYSAVING)\n  console=true
    Check Power Saving for NRCEL  ${NMIMO_NRCELL}[1]  ENABLED  NOTENERGYSAVING
    Log  Operational and EnergySaving state are as expected for ${NMIMO_NRCELL}[1] (DISABLED/ENERGYSAVING)\n  console=true


PS.68_CB008133_NRPGRP_With_mMIMO_And_Non_mMIMO_Cells.Test Specific Teardown
    Log To Console  \n============ SPECIFIC TEST TEARDOWN =============
    Log  Setting feature flags: actNrExtCellSOMethod / actNrLBPowerSaving / actNrLBmMimoRTXPowerSaving back to false value\n  console=true
    Set Feature Under Given Object  ${NRBTS_DistName}  ${FEATURE_FLAGS_TRUE}  false
    Log  Setting feature flags: actNrLBRTXPowerSaving / actNrMixedSOMethod back to false value\n  console=true
    Set Feature Under Given Object  ${NRBTS_DistName}  ${FEATURE_FLAGS_FALSE}  false
    Log  Deleting any old NRPGRP that was already on the BTS\n  console=true
    Remove NRPGRP Objects If Exist
    Log  Check if any unexpected alarm occured\n  console=true
    Check If Unexpected Alarms Are Raised  ${skip_fault}
    Log To Console  ========== SPECIFIC TEST TEARDOWN DONE ==========\n


PS.68_CB008133_NRPGRP_With_mMIMO_And_Non_mMIMO_Cells.Test Case Teardown
    PS.68_CB008133_NRPGRP_With_mMIMO_And_Non_mMIMO_Cells.Test Specific Teardown
    Common Test Teardown
