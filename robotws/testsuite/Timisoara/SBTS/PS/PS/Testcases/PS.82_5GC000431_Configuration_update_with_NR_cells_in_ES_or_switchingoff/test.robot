*** Settings ***
Resource    ../../../resources/common.robot
Resource    ../../../resources/alarms.robot
Resource    ../../../resources/power_saving.robot
Resource    ../../../resources/L3_call.robot


Documentation
...  TEST NAME:     PS.82_5GC000431_Configuration_update_with_NR_cells_in_ES_or_switchingoff
...  AUTHORS:       andreea.burtic@nokia.com
...  MAINTAINER:    TIM_5_Vrf    andreea.burtic@nokia.com
...  *****************
...  Basic information
...  *****************
...  Test scope is to check NR cells after configuration update for EDA05015338.
...  Mandatory for the TC is to be at least 1 mMIMO NR cell and 2 non-mMIMO NR cells.
...  *****************
...  Pre-conditions
...  *****************
...  On-Air running eNB with no alarms.
...  ******************
...  History of changes
...  ******************
...  16.03.2026 - https://jiradc.ext.net.nokia.com/browse/TAT-30509 - TC creation
...  *******************


*** Variables ***
${LBPS_PERIOD_DURATION}  120  #Time in minutes for NRPGRP duration configured on SBTS
${ITERATIONS}  30  #Number of times Step1-Step6 are repeated, default is 30.


*** Keywords ***
PS.82_5GC000431_Configuration_update_with_NR_cells_in_ES_or_switchingoff
    PS.82_Configuration_update_with_NR_cells_in_ES_or_switchingoff.Step0: Test Preparation
    FOR  ${iteration}  IN RANGE  ${ITERATIONS}
        Log  \n============ ITERATION ${iteration + 1}/${ITERATIONS} ============  console=true
        PS.82_Configuration_update_with_NR_cells_in_ES_or_switchingoff.Step1: Set Feature And Create And Activate NRGRP For 5GC000431
        PS.82_Configuration_update_with_NR_cells_in_ES_or_switchingoff.Step2: Check Cells Are In Energy Saving State
        PS.82_Configuration_update_with_NR_cells_in_ES_or_switchingoff.Step3: Change actDlDynSwitchAlloc And Check Cells Exit Energy Saving State
        PS.82_Configuration_update_with_NR_cells_in_ES_or_switchingoff.Step4: Check Cells Are In switchingoff State And Change actDlDynSwitchAlloc
        PS.82_Configuration_update_with_NR_cells_in_ES_or_switchingoff.Step5: Check Cells Exit Energy Saving State
        PS.82_Configuration_update_with_NR_cells_in_ES_or_switchingoff.Step6: Deactivate The Features And Remove The NRGRP
    END


PS.82_Configuration_update_with_NR_cells_in_ES_or_switchingoff.Step0: Test Preparation
    Log  \n========================================  console=true
    Log  Step0: Test Preparation\n  console=true
    Log  ========================================  console=true

    Get NR MIMO/NotMIMO Cells And RMODS Lists
    Should Not Be Empty  ${MIMO_CELLS}  At least one mMIMO NR cell should exist!
    ${len_not_mimo}  Get Length  ${NOT_MIMO_CELLS}
    Should Be True  ${len_not_mimo} >= 2  At least two non-mMIMO NR cells should exist!

    ${mimo_cell}  Evaluate  random.choice($MIMO_CELLS)  modules=random
    ${not_mimo_cells}  Evaluate  random.sample($NOT_MIMO_CELLS, 2)  modules=random
    Append To List  ${not_mimo_cells}  ${mimo_cell}
    Set Test Variable  @{NR_CELL_IDS_FOR_NRPGRP}  @{not_mimo_cells}
    Log  Selected cells for NRPGRP: ${NR_CELL_IDS_FOR_NRPGRP}  console=true


PS.82_Configuration_update_with_NR_cells_in_ES_or_switchingoff.Step1: Set Feature And Create And Activate NRGRP For 5GC000431
    Log  \n========================================  console=true
    Log  Step1: Set Feature And Create And Activate NRGRP For 5GC000431\n  console=true
    Log  ========================================  console=true

    Remove NRPGRP Objects If Exist
    ${features}  Create Dictionary  actLbpsCtrlLogicEnh=true  actNrLBPowerSaving=true  actCellSwitchOnForCmUpdate=true  shutdownWindow=120
    Set Parameters From Dictionary Under Given Object  ${NRBTS_DISTNAME}  ${features}

    Create And Activate NRPGRP With 3 Cells For 5GC000431  0  ${NRBTS_DISTNAME}  ${NR_CELL_IDS_FOR_NRPGRP}  ${LBPS_PERIOD_DURATION}


PS.82_Configuration_update_with_NR_cells_in_ES_or_switchingoff.Step2: Check Cells Are In Energy Saving State
    Log  \n========================================  console=true
    Log  Step2: Check Cells Are In Energy Saving State\n  console=true
    Log  ========================================  console=true

    Log  Waiting for ENERGYSAVING on NRCELL-${NR_CELL_IDS_FOR_NRPGRP}[0]...  console=true
    Wait Until Keyword Succeeds  10min  15sec  Check Power Saving for NRCEL  ${NR_CELL_IDS_FOR_NRPGRP}[0]  DISABLED  ENERGYSAVING
    Log  NRCELL-${NR_CELL_IDS_FOR_NRPGRP}[0] is in ENERGYSAVING!  console=true
    Log  Waiting for ENERGYSAVING on NRCELL-${NR_CELL_IDS_FOR_NRPGRP}[1]...  console=true
    Wait Until Keyword Succeeds  30s  5s  Check Power Saving for NRCEL  ${NR_CELL_IDS_FOR_NRPGRP}[1]  DISABLED  ENERGYSAVING
    Log  NRCELL-${NR_CELL_IDS_FOR_NRPGRP}[1] is in ENERGYSAVING!  console=true
    Log  Waiting for ENERGYSAVING on NRCELL-${NR_CELL_IDS_FOR_NRPGRP}[2]...  console=true
    Wait Until Keyword Succeeds  30s  5s  Check Power Saving for NRCEL  ${NR_CELL_IDS_FOR_NRPGRP}[2]  DISABLED  ENERGYSAVING
    Log  NRCELL-${NR_CELL_IDS_FOR_NRPGRP}[2] is in ENERGYSAVING!  console=true

    Check If Unexpected Alarms Are Raised  ${skip_fault}


PS.82_Configuration_update_with_NR_cells_in_ES_or_switchingoff.Step3: Change actDlDynSwitchAlloc And Check Cells Exit Energy Saving State
    Log  \n========================================  console=true
    Log  Step3: Change actDlDynSwitchAlloc And Check Cells Exit Energy Saving State\n  console=true
    Log  ========================================  console=true

    FOR  ${cell}  IN  @{NR_CELL_IDS_FOR_NRPGRP}
        admin.Perform Parameter Recommissioning  dist_name=${NRBTS_DISTNAME}/NRCELL-${cell}  parameter=actDlDynSwitchAlloc  operation=update
        ...  value=false  skip_parameter_relation_errors=true  timeout=600
        Log  Parameter actDlDynSwitchAlloc for NRCELL-${cell} value is false!  console=true
    END

    FOR  ${cell}  IN  @{NR_CELL_IDS_FOR_NRPGRP}
        Log  Waiting for NOTENERGYSAVING on NRCELL-${cell}...  console=true
        Wait Until Keyword Succeeds  10min  5sec  Check Power Saving for NRCEL  ${cell}  ENABLED  NOTENERGYSAVING
        Log  NRCELL-${cell} is in NOTENERGYSAVING!  console=true
    END

    Check If Unexpected Alarms Are Raised  ${skip_fault}


PS.82_Configuration_update_with_NR_cells_in_ES_or_switchingoff.Step4: Check Cells Are In switchingoff State And Change actDlDynSwitchAlloc
    Log  \n========================================  console=true
    Log  Step4: Check Cells Are In switchingoff State And Change actDlDynSwitchAlloc\n  console=true
    Log  ========================================  console=true

    FOR  ${cell}  IN  @{NR_CELL_IDS_FOR_NRPGRP}
        Log  Waiting for switchingoff on NRCELL-${cell}...  console=true
        Wait Until Keyword Succeeds  5min  5sec  Check Power Saving for NRCEL  ${cell}  ENABLED  SWITCHINGOFF
        Log  NRCELL-${cell} is in SWITCHINGOFF!  console=true
        admin.Perform Parameter Recommissioning  dist_name=${NRBTS_DISTNAME}/NRCELL-${cell}  parameter=actDlDynSwitchAlloc  operation=update
        ...  value=true  skip_parameter_relation_errors=true  timeout=600
        Log  Parameter actDlDynSwitchAlloc for NRCELL-${cell} value is true!  console=true
    END

    Check If Unexpected Alarms Are Raised  ${skip_fault}


PS.82_Configuration_update_with_NR_cells_in_ES_or_switchingoff.Step5: Check Cells Exit Energy Saving State
    Log  \n========================================  console=true
    Log  Step5: Check Cells Exit Energy Saving State\n  console=true
    Log  ========================================  console=true

    FOR  ${cell}  IN  @{NR_CELL_IDS_FOR_NRPGRP}
        Log  Waiting for NOTENERGYSAVING on NRCELL-${cell}...  console=true
        Wait Until Keyword Succeeds  10min  5sec  Check Power Saving for NRCEL  ${cell}  ENABLED  NOTENERGYSAVING
        Log  NRCELL-${cell} is in NOTENERGYSAVING!  console=true
    END

    Check If Unexpected Alarms Are Raised


PS.82_Configuration_update_with_NR_cells_in_ES_or_switchingoff.Step6: Deactivate The Features And Remove The NRGRP
    Log  \n========================================  console=true
    Log  Step6: Deactivate The Features And Remove The NRGRP\n  console=true
    Log  ========================================  console=true

    ${features}  Create Dictionary  actLbpsCtrlLogicEnh=false  actNrLBPowerSaving=false  actCellSwitchOnForCmUpdate=false
    Set Parameters From Dictionary Under Given Object  ${NRBTS_DISTNAME}  ${features}
    Log  Deleting NRGRP object...  console=true
    Remove NRPGRP Objects If Exist
    Log  Check if any unexpected alarm occured.\n  console=true

    Check If Unexpected Alarms Are Raised  ${skip_fault}


PS.82_5GC000431_Configuration_update_with_NR_cells_in_ES_or_switchingoff.Test Specific Teardown
    Log  \n============ SPECIFIC TEST TEARDOWN =============  console=true

    admin.Setup Admin  admin_api_log_dir=${RESULTS}/admin_api/  alias=${ute_admin_alias}
    ${features}  Create Dictionary  actLbpsCtrlLogicEnh=false  actNrLBPowerSaving=false  actCellSwitchOnForCmUpdate=false
    Set Parameters From Dictionary Under Given Object  ${NRBTS_DISTNAME}  ${features}

    Log  Deleting NRGRP object...  console=true
    Remove NRPGRP Objects If Exist
    Log  Check if any unexpected alarm occured.\n  console=true
    Check If Unexpected Alarms Are Raised  ${skip_fault}
    admin.Teardown Admin  alias=${ute_admin_alias}

    Log  ========== SPECIFIC TEST TEARDOWN DONE ==========\n  console=true


PS.82_5GC000431_Configuration_update_with_NR_cells_in_ES_or_switchingoff.Test Case Teardown
    common.Common Test Teardown
    Run Keyword If Test Failed  PS.82_5GC000431_Configuration_update_with_NR_cells_in_ES_or_switchingoff.Test Specific Teardown
