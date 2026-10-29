*** Settings ***
Resource    ../../../resources/common.robot
Resource    ../../../resources/alarms.robot
Resource    ../../../resources/power_saving.robot
Resource    ../../../resources/L3_call.robot


Documentation
...  TEST NAME:     PS.80_CB010869_NR_Determine_Cell_TX_Switch_OFF_and_ON_list
...  AUTHORS:       andrada-lavinia.baleti@nokia.com
...  MAINTAINER:    TIM_5_Vrf    andrada-lavinia.baleti@nokia.com
...  *****************
...  Basic information
...  *****************
...  Test scope is to check NR Cell TX Switch Off/On by creating RTX load threshold list in NRPGRP object with two cells
...  and perform downlink on second cell (lower priority) for CB010869 feature.
...  *****************
...  Pre-conditions
...  *****************
...  On-Air running eNB with no alarms.
...  ******************
...  History of changes
...  ******************
...  29.10.2025 - https://jiradc.ext.net.nokia.com/browse/TAT-30102 - TC creation
...  *******************


*** Variables ***
#@{NR_CELL_IDS_FOR_NRPGRP}  23  303  #NR cells to be added in NRPGRP
@{NR_CELL_IDS_FOR_NRPGRP}  23  302
#${NR_CELL_TO_BE_BARRED}  313  #NR cell to be set as barred to not interfere with required cell for downlink
${NR_CELL_TO_BE_BARRED}  312
#${LBPS_PERIOD_DURATION}  60  #Time in minutes for NRPGRP duration configured on SBTS
${LBPS_PERIOD_DURATION}  45
#${LBPS_RTX_LOAD_THRES_DURATION}  20  #Time in minutes for RTX load duration configured in NRPGRP
${LBPS_RTX_LOAD_THRES_DURATION}  15
${NR_DESIRED_THROUGHPUT_DOWNLINK}  120 Mbits/sec  #Data traffic required for downlink
#${NR_MIN_THROUGHPUT_DOWNLINK}  55 Mbits/sec  #Minimum data traffic for downlink
${NR_MIN_THROUGHPUT_DOWNLINK}  45 Mbits/sec
${NR_DL_DURATION}  320s  #Downlink duration


*** Keywords ***
PS.80_CB010869_NR_Determine_Cell_TX_Switch_OFF_and_ON_list
    PS.80_CB010869_NR_Determine_Cell_TX_Switch_OFF_and_ON_list.Step 0: Preparing Environment
    PS.80_CB010869_NR_Determine_Cell_TX_Switch_OFF_and_ON_list.Step 1: Create And Activate NRGRP For CB010869
    PS.80_CB010869_NR_Determine_Cell_TX_Switch_OFF_and_ON_list.Step 2: Perform Downlink And Check Cells Are In Reduced Energy Saving State
    PS.80_CB010869_NR_Determine_Cell_TX_Switch_OFF_and_ON_list.Step 3: Perform Downlink And Check Cells Exit Reduced Energy Saving State
    PS.80_CB010869_NR_Determine_Cell_TX_Switch_OFF_and_ON_list.Step 4: Perform Downlink And Check Cells Are In Reduced Energy Saving State


PS.80_CB010869_NR_Determine_Cell_TX_Switch_OFF_and_ON_list.Step 0: Preparing Environment
    Log  \n========================================  console=true
    Log  Step 0: Preparing Environment\n  console=true
    Log  ========================================  console=true

#    attenuator.Setup Attenuator  attenuator=${tl.attenuator[0]}
#    Set Attenuator Value On All Ports  set_value_db=${90}
##    Adjust Attenuation Value For Port  set_value_db=${0}  port=${att_port_9}
#    Adjust Attenuation Value For Port  set_value_db=${0}  port=${att_port_8}

    ${nrcell_list}  Get Ids For All  NRCEL
    ${first_cell_in_config}  Get Matches  ${nrcell_list}  *-${NR_CELL_IDS_FOR_NRPGRP}[0]
    ${second_cell_in_config}  Get Matches  ${nrcell_list}  *-${NR_CELL_IDS_FOR_NRPGRP}[1]
    Should Be True  ${first_cell_in_config} and ${second_cell_in_config}  @{NR_CELL_IDS_FOR_NRPGRP} NR cell ids are not configured on SBTS.
    @{states_to_check}  Create List  availabilityStatus  administrativeState  blockingState
    @{expected_states}  Create List  -  UNLOCKED  UNBLOCKED
    FOR  ${cell_id}  IN  @{NR_CELL_IDS_FOR_NRPGRP}
        Check Cell States For Specific Cell  NRCEL  ${cell_id}  ${states_to_check}  ${expected_states}
    END


PS.80_CB010869_NR_Determine_Cell_TX_Switch_OFF_and_ON_list.Step 1: Create And Activate NRGRP For CB010869
    Log  \n========================================  console=true
    Log  Step 1: Create And Activate NRGRP For CB010869\n  console=true
    Log  ========================================  console=true

    Remove NRPGRP Objects If Exist
    ${features}  Create Dictionary  actNrLBmMimoRTXPowerSaving=true  actNrLBRTXPowerSaving=true  actLbpsThresPerTimeWindow=true  shutdownWindow=60
    Set Parameters From Dictionary Under Given Object  ${NRBTS_DISTNAME}  ${features}

    Log  \nTC is waiting for NRCELLs to recover after RAT Reset triggered by activating actNrLBRTXPowerSaving parameter.  console=true
    Wait Until Keyword Succeeds  10min  30s  admin.Assert Every  NRCEL  ${NR_EXPECTED_STATE}

    ${current_date}  Get Current Date  result_format=datetime
    ${nrpgrp_period_starting_time}  Add Time To Date  ${current_date}  5 minutes
    ${rtx_load_starting_time}  Add Time To Date  ${nrpgrp_period_starting_time}  ${LBPS_RTX_LOAD_THRES_DURATION} minutes
    Create And Activate NRPGRP With 2 Cells For CB010869  0  ${NRBTS_DISTNAME}  ${NR_CELL_IDS_FOR_NRPGRP}  ${LBPS_PERIOD_DURATION}
    ...  ${LBPS_RTX_LOAD_THRES_DURATION}  ${nrpgrp_period_starting_time}  ${rtx_load_starting_time}

    ${second_time_period_ending_time}  Add Time To Date  ${rtx_load_starting_time}  ${LBPS_RTX_LOAD_THRES_DURATION} minutes
    ${third_time_period_ending_time}  Add Time To Date  ${second_time_period_ending_time}  ${LBPS_RTX_LOAD_THRES_DURATION} minutes
    Set Test Variable  ${RTX_LOAD_STARTING_TIME}
    Set Test Variable  ${SECOND_TIME_PERIOD_ENDING_TIME}
    Set Test Variable  ${THIRD_TIME_PERIOD_ENDING_TIME}

    Cell Barred/NotBarred  barred  MRBTS-${MRBTS_ID}/NRBTS-${NRBTS_ID}/NRCELL-${NR_CELL_TO_BE_BARRED}


PS.80_CB010869_NR_Determine_Cell_TX_Switch_OFF_and_ON_list.Step 2: Perform Downlink And Check Cells Are In Reduced Energy Saving State
    Log  \n========================================  console=true
    Log  Step 2: Perform Downlink And Check Cells Are In Reduced Energy Saving State\n  console=true
    Log  ========================================  console=true

    FOR  ${cell_id}  IN  @{NR_CELL_IDS_FOR_NRPGRP}
        Log  Waiting for REDUCEDENERGYSAVING on NRCELL_R-${cell_id}...  console=true
        Wait Until Keyword Succeeds  8min  15sec  Check Power Saving for NRCEL  ${cell_id}  ENABLED  REDUCEDENERGYSAVING
    END
    Perform Downlink On NR Cell  ${NR_CELL_IDS_FOR_NRPGRP}[1]  ${NR_DL_DURATION}  ${NR_DESIRED_THROUGHPUT_DOWNLINK}  ${NR_MIN_THROUGHPUT_DOWNLINK}
    Log  TC waits 20 seconds before checking NRCELLs ${NR_CELL_IDS_FOR_NRPGRP} to be still in REDUCEDENERGYSAVING.\n  console=true
    Sleep  20s  TC waits 20s before checking NRCELLs status.
    FOR  ${cell_id}  IN  @{NR_CELL_IDS_FOR_NRPGRP}
        Check Power Saving for NRCEL  ${cell_id}  ENABLED  REDUCEDENERGYSAVING
    END


PS.80_CB010869_NR_Determine_Cell_TX_Switch_OFF_and_ON_list.Step 3: Perform Downlink And Check Cells Exit Reduced Energy Saving State
    Log  \n========================================  console=true
    Log  Step 3: Perform Downlink And Check Cells Exit Reduced Energy Saving State\n  console=true
    Log  ========================================  console=true

    ${current_date}  Get Current Date  result_format=datetime
    ${seconds_to_wait}  Subtract Date From Date  ${RTX_LOAD_STARTING_TIME}  ${current_date}
    ${min_and_sec}  Convert date  ${seconds_to_wait}  result_format=%M minutes and %S seconds
    Log  TC sleeps for ${min_and_sec} until RTX load ${LBPS_RTX_LOAD_THRES_DURATION} minutes time period starts.  console=true
    Sleep  ${seconds_to_wait}

    FOR  ${cell_id}  IN  @{NR_CELL_IDS_FOR_NRPGRP}
        Log  Check NRCELL_R-${cell_id} is still in REDUCEDENERGYSAVING.  console=true
        Check Power Saving for NRCEL  ${cell_id}  ENABLED  REDUCEDENERGYSAVING
    END
    Perform Downlink On NR Cell  ${NR_CELL_IDS_FOR_NRPGRP}[1]  ${NR_DL_DURATION}  ${NR_DESIRED_THROUGHPUT_DOWNLINK}  ${NR_MIN_THROUGHPUT_DOWNLINK}
    FOR  ${cell_id}  IN  @{NR_CELL_IDS_FOR_NRPGRP}
        Log  Waiting for NOTENERGYSAVING on NRCELL_R-${cell_id}...  console=true
        Wait Until Keyword Succeeds  180s  15sec  Check Power Saving for NRCEL  ${cell_id}  ENABLED  NOTENERGYSAVING
    END


PS.80_CB010869_NR_Determine_Cell_TX_Switch_OFF_and_ON_list.Step 4: Perform Downlink And Check Cells Are In Reduced Energy Saving State
    Log  \n========================================  console=true
    Log  Step 4: Perform Downlink And Check Cells Are In Reduced Energy Saving State\n  console=true
    Log  ========================================  console=true

    ${current_date}  Get Current Date  result_format=datetime
    ${seconds_to_wait}  Subtract Date From Date  ${SECOND_TIME_PERIOD_ENDING_TIME}  ${current_date}
    ${min_and_sec}  Convert date  ${seconds_to_wait}  result_format=%M minutes and %S seconds
    Log  TC sleeps for ${min_and_sec} until second ${LBPS_RTX_LOAD_THRES_DURATION} minutes time period ends.  console=true
    Sleep  ${seconds_to_wait}

    FOR  ${cell_id}  IN  @{NR_CELL_IDS_FOR_NRPGRP}
        Log  Check NRCELL_R-${cell_id} to be in REDUCEDENERGYSAVING.  console=true
        Wait Until Keyword Succeeds  8min  15sec  Check Power Saving for NRCEL  ${cell_id}  ENABLED  REDUCEDENERGYSAVING
    END

    Perform Downlink On NR Cell  ${NR_CELL_IDS_FOR_NRPGRP}[1]  ${NR_DL_DURATION}  ${NR_DESIRED_THROUGHPUT_DOWNLINK}  ${NR_MIN_THROUGHPUT_DOWNLINK}
    Log  TC waits 20 seconds before checking NRCELLs ${NR_CELL_IDS_FOR_NRPGRP} to be still in REDUCEDENERGYSAVING.\n  console=true
    Sleep  20s  TC waits 20s before checking NRCELLs status.
    FOR  ${cell_id}  IN  @{NR_CELL_IDS_FOR_NRPGRP}
        Check Power Saving for NRCEL  ${cell_id}  ENABLED  REDUCEDENERGYSAVING
    END

    ${current_date}  Get Current Date  result_format=datetime
    ${seconds_to_wait}  Subtract Date From Date  ${THIRD_TIME_PERIOD_ENDING_TIME}  ${current_date}
    ${min_and_sec}  Convert date  ${seconds_to_wait}  result_format=%M minutes and %S seconds
    Log  TC sleeps for ${min_and_sec} until NRPGRP period duration ends.\n  console=true
    Sleep  ${seconds_to_wait}


PS.80_CB010869_NR_Determine_Cell_TX_Switch_OFF_and_ON_list.Test Specific Teardown
    Log  \n============ SPECIFIC TEST TEARDOWN =============  console=true

    admin.Setup Admin  admin_api_log_dir=${RESULTS}/admin_api/  alias=${ute_admin_alias}
    ${features}  Create Dictionary  actNrLBmMimoRTXPowerSaving=false  actNrLBRTXPowerSaving=false  actLbpsThresPerTimeWindow=false
    Set Parameters From Dictionary Under Given Object  ${NRBTS_DISTNAME}  ${features}

    Log  Deleting NRGRP-0 object...  console=true
    Remove NRPGRP Objects If Exist
    @{states_to_check}  Create List  operationalState  energySavingState
    @{expected_states}  Create List  ENABLED  NOTENERGYSAVING
    FOR  ${cell_id}  IN  @{NR_CELL_IDS_FOR_NRPGRP}
        Wait Until Keyword Succeeds  5min  30s  Check Cell States For Specific Cell  NRCEL  ${cell_id}  ${states_to_check}  ${expected_states}
    END
    Log  NRCELLs are in correct energy saving state. [OK]\n  console=true

    Cell Barred/NotBarred  notBarred  MRBTS-${MRBTS_ID}/NRBTS-${NRBTS_ID}/NRCELL-${NR_CELL_TO_BE_BARRED}

    Log  Check if any unexpected alarm occured.\n  console=true
    Check If Unexpected Alarms Are Raised  ${skip_fault}
    admin.Teardown Admin  alias=${ute_admin_alias}

    Log  ========== SPECIFIC TEST TEARDOWN DONE ==========\n  console=true


PS.80_CB010869_NR_Determine_Cell_TX_Switch_OFF_and_ON_list.Test Case Teardown
    common.Common Test Teardown
    PS.80_CB010869_NR_Determine_Cell_TX_Switch_OFF_and_ON_list.Test Specific Teardown
