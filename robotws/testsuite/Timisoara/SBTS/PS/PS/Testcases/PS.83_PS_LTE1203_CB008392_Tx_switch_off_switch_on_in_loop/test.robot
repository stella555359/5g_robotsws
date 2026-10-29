*** Settings ***
Resource    ../../../resources/common.robot
Resource    ../../../resources/alarms.robot
Resource    ../../../resources/power_saving.robot


Documentation
...  TEST NAME:     PS.83_PS_LTE1203_CB008392_Tx_switch_off_switch_on_in_loop
...  AUTHORS:       andrada-lavinia.baleti@nokia.com
...  MAINTAINER:    TIM_5_Vrf   andrada-lavinia.baleti@nokia.com
...  *****************
...  Basic information
...  *****************
...  Test scope is to check LTE and NR cells TX Switch Off/On after configuration update for EDA05031472.
...  PSGRPs and NRPGRPs are created for every LTE cell with at least 2 TXs and NR cell with at least 4 TXs.
...  Power saving group window is shifted with 10 minutes for ${ITERATIONS} times and all cells must have the expected
...  energy saving states.
...  *****************
...  Pre-conditions
...  *****************
...  On-Air running eNB with no alarms.
...  ******************
...  History of changes
...  ******************
...  13.02.2026 - https://jiradc.ext.net.nokia.com/browse/TAT-30517 - TC creation
...  *******************


*** Variables ***
${LBPS_LTE_PERIOD_DURATION}  5  #Time in minutes for PSGRPduration configured on SBTS
${LBPS_NR_PERIOD_DURATION}  6  #Time in minutes for NRPGRP duration configured on SBTS
${ITERATIONS}  15  #Number of times power group window is shifted with 10 minute for both LTE and NR, default is 15.


*** Keywords ***
PS.83_PS_LTE1203_CB008392_Tx_switch_off_switch_on_in_loop
    PS.83_PS_LTE1203_CB008392_Tx_switch_off_switch_on_in_loop.Step0: Test Preparation
    PS.83_PS_LTE1203_CB008392_Tx_switch_off_switch_on_in_loop.Step1: Set Feature And Create And Activate PSGRP And NRPGRP For LTE1203 And CB008392
    PS.83_PS_LTE1203_CB008392_Tx_switch_off_switch_on_in_loop.Step2: Check Cells Are In Reduced Energy Saving State
    PS.83_PS_LTE1203_CB008392_Tx_switch_off_switch_on_in_loop.Step3: Check Cells Exit Reduced Energy Saving State

    FOR  ${iteration}  IN RANGE  ${ITERATIONS}
        Log  \n============ ITERATION ${iteration + 1}/${ITERATIONS} ============  console=true
        PS.83_PS_LTE1203_CB008392_Tx_switch_off_switch_on_in_loop.Step4: Shift Power Saving Window With 10 Minutes
        PS.83_PS_LTE1203_CB008392_Tx_switch_off_switch_on_in_loop.Step2: Check Cells Are In Reduced Energy Saving State
        PS.83_PS_LTE1203_CB008392_Tx_switch_off_switch_on_in_loop.Step3: Check Cells Exit Reduced Energy Saving State
    END


PS.83_PS_LTE1203_CB008392_Tx_switch_off_switch_on_in_loop.Step0: Test Preparation
    Log  \n========================================  console=true
    Log  Step0: Test Preparation\n  console=true
    Log  ========================================  console=true

    ${cells_params}  Get Cell List  100
    ${lte_cell_ids_for_psgrp}  PS.83_PS_LTE1203_CB008392_Tx_switch_off_switch_on_in_loop.Get LTE Cells With At Least 2 TXs  ${cells_params}
    ${nr_cell_ids_for_nrpgrp}  ${there_are_mimo_cells}  PS.83_PS_LTE1203_CB008392_Tx_switch_off_switch_on_in_loop.Get NR Cells With At Least 4 TXs
    ...  ${cells_params}

    Set Test Variable  @{LTE_CELL_IDS_FOR_PSGRP}
    Set Test Variable  @{NR_CELL_IDS_FOR_NRPGRP}
    Set Test Variable  ${THERE_ARE_MIMO_CELLS}


PS.83_PS_LTE1203_CB008392_Tx_switch_off_switch_on_in_loop.Step1: Set Feature And Create And Activate PSGRP And NRPGRP For LTE1203 And CB008392
    Log  \n========================================  console=true
    Log  Step1: Set Feature And Create And Activate PSGRP And NRPGRP For LTE1203 And CB008392\n  console=true
    Log  ========================================  console=true

    Remove PSGRP/NRPGRP Objects If Exist  PSGRP/NRPGRP

    ${features}  Create Dictionary  actLBPowerSaving=true  actLBRTXPowerSaving=true  actOnlineTXSwitch=false
    ${lnbts_id}  Get LNBTS ID
    Set Test Variable  ${LNBTS_DISTNAME}  MRBTS-${MRBTS_ID}/LNBTS-${lnbts_id}
    Set Parameters From Dictionary Under Given Object  ${LNBTS_DISTNAME}  ${features}

    ${features}  Create Dictionary  actNrLBPowerSaving=true  actNrLBRTXPowerSaving=true
    IF  ${THERE_ARE_MIMO_CELLS}  Set To Dictionary  ${features}  actNrLBmMimoRTXPowerSaving=true
    Set Parameters From Dictionary Under Given Object  ${NRBTS_DISTNAME}  ${features}

    ${current_date}  Get Current Date  result_format=datetime
    ${period_starting_time}  Add Time To Date  ${current_date}  5 minutes
    Create And Activate PSGRPs And NRPGRPs For LTE1203 And CB008392  ${LNBTS_DISTNAME}  ${NRBTS_DISTNAME}  ${LTE_CELL_IDS_FOR_PSGRP}
    ...  ${NR_CELL_IDS_FOR_NRPGRP}  ${LBPS_LTE_PERIOD_DURATION}  ${LBPS_NR_PERIOD_DURATION}  ${period_starting_time}

    Set Test Variable  ${PERIOD_STARTING_TIME}


PS.83_PS_LTE1203_CB008392_Tx_switch_off_switch_on_in_loop.Step2: Check Cells Are In Reduced Energy Saving State
    Log  \n========================================  console=true
    Log  Step2: Check Cells Are In Reduced Energy Saving State\n  console=true
    Log  ========================================  console=true

    FOR  ${cell_id}  IN  @{LTE_CELL_IDS_FOR_PSGRP}
        Log  Waiting for REDUCEDENERGYSAVING on LNCEL_R-${cell_id}...  console=true
        Wait Until Keyword Succeeds  8min  20sec  Check Power Saving  ${cell_id}  ENABLED  REDUCEDENERGYSAVING
    END
    FOR  ${cell_id}  IN  @{NR_CELL_IDS_FOR_NRPGRP}
        Log  Waiting for REDUCEDENERGYSAVING on NRCELL_R-${cell_id}...  console=true
        Wait Until Keyword Succeeds  8min  20sec  Check Power Saving for NRCEL  ${cell_id}  ENABLED  REDUCEDENERGYSAVING
    END


PS.83_PS_LTE1203_CB008392_Tx_switch_off_switch_on_in_loop.Step3: Check Cells Exit Reduced Energy Saving State
    Log  \n========================================  console=true
    Log  Step3: Check Cells Exit Reduced Energy Saving State\n  console=true
    Log  ========================================  console=true

    FOR  ${cell_id}  IN  @{LTE_CELL_IDS_FOR_PSGRP}
        Log  Waiting for NOTENERGYSAVING on LNCEL_R-${cell_id}...  console=true
        Wait Until Keyword Succeeds  5min  20sec  Check Power Saving  ${cell_id}  ENABLED  NOTENERGYSAVING
    END
    FOR  ${cell_id}  IN  @{NR_CELL_IDS_FOR_NRPGRP}
        Log  Waiting for NOTENERGYSAVING on NRCELL_R-${cell_id}...  console=true
        Wait Until Keyword Succeeds  5min  20sec  Check Power Saving for NRCEL  ${cell_id}  ENABLED  NOTENERGYSAVING
    END


PS.83_PS_LTE1203_CB008392_Tx_switch_off_switch_on_in_loop.Step4: Shift Power Saving Window With 10 Minutes
    Log  \n========================================  console=true
    Log  Step4: Shift Power Saving Window With 10 Minutes\n  console=true
    Log  ========================================  console=true

    ${new_period_starting_time}  Add Time To Date  ${PERIOD_STARTING_TIME}  10 minutes
    Set Test Variable  ${PERIOD_STARTING_TIME}  ${new_period_starting_time}
    ${period_day}  Convert Date  ${new_period_starting_time}  result_format=%a
    ${period_hour}  Convert Date  ${new_period_starting_time}  result_format=%H
    ${period_minute}  Convert Date  ${new_period_starting_time}  result_format=%M

    ${lbpsPeriodList_lte}  Create Dictionary  lbpsDayOfWeek=${period_day}  lbpsDuration=${LBPS_LTE_PERIOD_DURATION}
    ...  lbpsStartTimeHour=${period_hour}  lbpsStartTimeMinute=${period_minute}  lbpsSuspended=notSuspended
    ${lbpsPeriodList_nr}  Create Dictionary  lbpsDayOfWeek=${period_day}  lbpsDuration=${LBPS_NR_PERIOD_DURATION}
    ...  lbpsStartTimeHour=${period_hour}  lbpsStartTimeMinute=${period_minute}  lbpsSuspended=notSuspended

    ${delta_id}  Set Variable  psg_LTE1203_CB008392
    admin.Create Delta  ${delta_id}

    ${lte_cells_length}  Get Length  ${LTE_CELL_IDS_FOR_PSGRP}
    FOR  ${index}  IN RANGE  ${lte_cells_length}
        ${psgrp_dn}  Set Variable  ${LNBTS_DISTNAME}/PSGRP-${index}
        admin.Append Managed Object To Delta  ${psgrp_dn}  update  ${delta_id}
        admin.Append Complex Item To Delta  ${psgrp_dn}  list_name=lbpsPeriodList  &{lbpsPeriodList_lte}  delta_id=${delta_id}
    END

    ${nr_cells_length}  Get Length  ${NR_CELL_IDS_FOR_NRPGRP}
    FOR  ${index}  IN RANGE  ${nr_cells_length}
        ${nrpgrp_dn}  Set Variable  ${NRBTS_DISTNAME}/NRPGRP-${index}
        admin.Append Managed Object To Delta  ${nrpgrp_dn}  update  ${delta_id}
        admin.Append Complex Item To Delta  ${nrpgrp_dn}  list_name=lbpsPeriodList  &{lbpsPeriodList_nr}  delta_id=${delta_id}
    END
    admin.Get Delta  ${delta_id}
    admin.Save Delta  ${RESULTS}/delta_update_${delta_id}.json  ${delta_id}
    admin.Perform Delta Recommissioning  ${RESULTS}/delta_create_${delta_id}.json  ${delta_id}
    Remove Delta  ${delta_id}

    Log  PSGRPs are shifted with 10 minutes, new time frame: ${period_hour}:${period_minute} (+${LBPS_LTE_PERIOD_DURATION} minutes)\n
    ...  console=true
    Log  NRPGRPs are shifted with 10 minutes, new time frame: ${period_hour}:${period_minute} (+${LBPS_NR_PERIOD_DURATION} minutes)\n
    ...  console=true


PS.83_PS_LTE1203_CB008392_Tx_switch_off_switch_on_in_loop.Get LTE Cells With At Least 2 TXs
    [Arguments]  ${cells_params}

    ${lte_cell_ids_for_psgrp}  Create List
    FOR  ${lte_cell}  IN  @{cells_params['cells']['lte']}
        ${no_of_tx}  Set Variable  0
        FOR  ${antenna}  IN  @{lte_cell['carrierList']}
            IF  "${antenna}[direction]"!="TX"  CONTINUE
            ${no_of_tx}  Evaluate  ${no_of_tx}+1
        END
        IF  ${no_of_tx}<2  CONTINUE
        ${cell_id}  Fetch From Right  ${lte_cell}[id][internal]  -
        Append To List  ${lte_cell_ids_for_psgrp}  ${cell_id}
    END

    RETURN  ${lte_cell_ids_for_psgrp}


PS.83_PS_LTE1203_CB008392_Tx_switch_off_switch_on_in_loop.Get NR Cells With At Least 4 TXs
    [Arguments]  ${cells_params}

    ${there_are_mimo_cells}  Set Variable  ${FALSE}
    ${nr_cell_ids_for_nrpgrp}  Create List
    FOR  ${nr_cell}  IN  @{cells_params['cells']['nr']}
        ${no_of_tx}  Set Variable  0
        FOR  ${antenna}  IN  @{nr_cell['carrierList']}
            IF  "${antenna}[direction]"!="TX"  CONTINUE
            ${no_of_tx}  Evaluate  ${no_of_tx}+1
        END
        IF  ${no_of_tx}<4  CONTINUE
        ${cell_id}  Fetch From Right  ${nr_cell}[id][internal]  -
        Append To List  ${nr_cell_ids_for_nrpgrp}  ${cell_id}
        IF  not ${there_are_mimo_cells} and "PHYANT" in "${nr_cell}[carrierList][0][antennaLineId][configuration]"
            ${there_are_mimo_cells}  Set Variable  ${TRUE}
        END
    END

    RETURN  ${nr_cell_ids_for_nrpgrp}  ${there_are_mimo_cells}


PS.83_PS_LTE1203_CB008392_Tx_switch_off_switch_on_in_loop.Test Specific Teardown
    Log  \n============ SPECIFIC TEST TEARDOWN =============  console=true

    admin.Setup Admin  admin_api_log_dir=${RESULTS}/admin_api/  alias=${ute_admin_alias}

    ${features}  Create Dictionary  actLBPowerSaving=false  actLBRTXPowerSaving=false
    Set Parameters From Dictionary Under Given Object  ${LNBTS_DISTNAME}  ${features}
    ${features}  Create Dictionary  actNrLBPowerSaving=false  actNrLBRTXPowerSaving=false
    IF  ${THERE_ARE_MIMO_CELLS}  Set To Dictionary  ${features}  actNrLBmMimoRTXPowerSaving=false
    Set Parameters From Dictionary Under Given Object  ${NRBTS_DISTNAME}  ${features}

    Remove PSGRP/NRPGRP Objects If Exist  PSGRP/NRPGRP

    Log  Check if any unexpected alarm occured.\n  console=true
    Check If Unexpected Alarms Are Raised  ${skip_fault}
    admin.Teardown Admin  alias=${ute_admin_alias}

    Log  ========== SPECIFIC TEST TEARDOWN DONE ==========\n  console=true


PS.83_PS_LTE1203_CB008392_Tx_switch_off_switch_on_in_loop.Test Case Teardown
    common.Common Test Teardown
    PS.83_PS_LTE1203_CB008392_Tx_switch_off_switch_on_in_loop.Test Specific Teardown
