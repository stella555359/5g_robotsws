*** Settings ***
Resource    ../../../resources/common.robot
Resource    ../../../resources/alarms.robot
Resource    ../../../resources/power_saving.robot
Resource    ../../../resources/L3_call.robot


Documentation
...  TEST NAME:     PS.79_CB010869_LTE_Determine_Cell_TX_Switch_OFF_and_ON_list
...  AUTHORS:       andrada-lavinia.baleti@nokia.com
...  MAINTAINER:    TIM_5_Vrf    andrada-lavinia.baleti@nokia.com
...  *****************
...  Basic information
...  *****************
...  Test scope is to check LTE Cell TX Switch Off/On by creating RTX load threshold list in PSGRP object with two cells
...  and perform downlink on second cell (lower priority) for CB010869 feature.
...  *****************
...  Pre-conditions
...  *****************
...  On-Air running eNB with no alarms.
...  ******************
...  History of changes
...  ******************
...  07.11.2025 - https://jiradc.ext.net.nokia.com/browse/TAT-30169 - TC creation
...  24.02.2026 - https://jiradc.ext.net.nokia.com/browse/TAT-30570 - Fix Perform Downlink On LTE Cell argument passing
...  *******************


*** Variables ***
#@{LTE_CELL_IDS_FOR_PSGRP}  48180  48140  #LTE cells to be added in PSGRP
@{LTE_CELL_IDS_FOR_PSGRP}  23  2  #LTE cells to be added in PSGRP
#@{LTE_CELLS_TO_BE_LOCKED}  48182  48185  #LTE cells to be locked to not interfere with required cell for downlink
@{LTE_CELLS_TO_BE_LOCKED}  12  32  #LTE cells to be locked to not interfere with required cell for downlink
#${LBPS_PERIOD_DURATION}   60  #Time in minutes for PSGRP duration configured on SBTS
#${LBPS_RTX_LOAD_THRES_DURATION}    20  #Time in minutes for RTX load duration configured in PSGRP
${LBPS_PERIOD_DURATION}  30  #Time in minutes for PSGRP duration configured on SBTS
${LBPS_RTX_LOAD_THRES_DURATION}  10  #Time in minutes for RTX load duration configured in PSGRP
${LTE_DESIRED_THROUGHPUT_DOWNLINK}  80 Mbits/sec  #Data traffic required for downlink
#${LTE_MIN_THROUGHPUT_DOWNLINK}  40 Mbits/sec  #Minimum data traffic for downlink
${LTE_MIN_THROUGHPUT_DOWNLINK}  20 Mbits/sec  #Minimum data traffic for downlink
${LTE_DL_DURATION}  130s  #Downlink duration


*** Keywords ***
PS.79_CB010869_LTE_Determine_Cell_TX_Switch_OFF_and_ON_list
    PS.79_CB010869_LTE_Determine_Cell_TX_Switch_OFF_and_ON_list.Step 0: Preparing Environment
    PS.79_CB010869_LTE_Determine_Cell_TX_Switch_OFF_and_ON_list.Step 1: Create And Activate PSGRP For CB010869
    PS.79_CB010869_LTE_Determine_Cell_TX_Switch_OFF_and_ON_list.Step 2: Perform Downlink And Check Cell Is In Reduced Energy Saving State
    PS.79_CB010869_LTE_Determine_Cell_TX_Switch_OFF_and_ON_list.Step 3: Perform Downlink And Check Cell Exit Reduced Energy Saving State
    PS.79_CB010869_LTE_Determine_Cell_TX_Switch_OFF_and_ON_list.Step 4: Perform Downlink And Check Cells Are In Reduced Energy Saving State


PS.79_CB010869_LTE_Determine_Cell_TX_Switch_OFF_and_ON_list.Step 0: Preparing Environment
    Log  \n========================================  console=true
    Log  Step 0: Preparing Environment\n  console=true
    Log  ========================================  console=true

#    attenuator.Setup Attenuator  attenuator=${tl.attenuator[0]}
#    Set Attenuator Value On All Ports  set_value_db=${90}
#    Adjust Attenuation Value For Port  set_value_db=${0}  port=${att_port_5}

    ${lncel_list}  Get Ids For All  LNCEL
    ${first_cell_in_config}  Get Matches  ${lncel_list}  *-${LTE_CELL_IDS_FOR_PSGRP}[0]
    ${second_cell_in_config}  Get Matches  ${lncel_list}  *-${LTE_CELL_IDS_FOR_PSGRP}[1]
    Should Be True  ${first_cell_in_config} and ${second_cell_in_config}  @{LTE_CELL_IDS_FOR_PSGRP} LTE cell ids are not configured on SBTS.
    ${lnbts_id}  Get LNBTS ID
    Set Test Variable  ${LNBTS_DISTNAME}  MRBTS-${MRBTS_ID}/LNBTS-${lnbts_id}
    @{states_to_check}  Create List  availabilityStatus  administrativeState  blockingState
    @{expected_states}  Create List  -  UNLOCKED  UNBLOCKED
    FOR  ${cell_id}  IN  @{LTE_CELL_IDS_FOR_PSGRP}
        Check Cell States For Specific Cell  LNCEL  ${cell_id}  ${states_to_check}  ${expected_states}
    END


PS.79_CB010869_LTE_Determine_Cell_TX_Switch_OFF_and_ON_list.Step 1: Create And Activate PSGRP For CB010869
    Log  \n========================================  console=true
    Log  Step 1: Create And Activate PSGRP For CB010869\n  console=true
    Log  ========================================  console=true
    Remove PSGRP/NRPGRP Objects If Exist  PSGRP
    ${features}  Create Dictionary  actLBRTXPowerSaving=true  actOnlineTXSwitch=true  actLbpsThresPerTimeWindow=true  shutdownWindow=60
    Set Parameters From Dictionary Under Given Object  ${LNBTS_DISTNAME}  ${features}

    ${current_date}  Get Current Date  result_format=datetime
    ${psgrp_period_starting_time}  Add Time To Date  ${current_date}  5 minutes
    ${rtx_load_starting_time}  Add Time To Date  ${psgrp_period_starting_time}  ${LBPS_RTX_LOAD_THRES_DURATION} minutes
    Create And Activate One PSGRP For CB010869  0  ${LNBTS_DISTNAME}  ${LTE_CELL_IDS_FOR_PSGRP}  ${LBPS_PERIOD_DURATION}
    ...  ${LBPS_RTX_LOAD_THRES_DURATION}  ${psgrp_period_starting_time}  ${rtx_load_starting_time}

    ${second_time_period_ending_time}  Add Time To Date  ${rtx_load_starting_time}  ${LBPS_RTX_LOAD_THRES_DURATION} minutes
    ${third_time_period_ending_time}  Add Time To Date  ${second_time_period_ending_time}  ${LBPS_RTX_LOAD_THRES_DURATION} minutes
    Set Test Variable  ${RTX_LOAD_STARTING_TIME}
    Set Test Variable  ${SECOND_TIME_PERIOD_ENDING_TIME}
    Set Test Variable  ${THIRD_TIME_PERIOD_ENDING_TIME}

    Log  Lock LTE cells with ids: ${LTE_CELLS_TO_BE_LOCKED}\n  console=true
    @{states_to_check}  Create List  administrativeState
    @{expected_states}  Create List  LOCKED
    FOR  ${cell_id}  IN  @{LTE_CELLS_TO_BE_LOCKED}
        Change Parameter Under LNCEL  administrativeState  locked  ${cell_id}
        Wait Until Keyword Succeeds  120  15  Check Cell States For Specific Cell  LNCEL  ${cell_id}  ${states_to_check}  ${expected_states}
    END
    ${lncel_dns}  Create List  ${LNBTS_DISTNAME}/LNCEL-${LTE_CELL_IDS_FOR_PSGRP}[0]  ${LNBTS_DISTNAME}/LNCEL-${LTE_CELL_IDS_FOR_PSGRP}[1]
    Commission LoadSettings For LNCELs  ${lncel_dns}  10


PS.79_CB010869_LTE_Determine_Cell_TX_Switch_OFF_and_ON_list.Step 2: Perform Downlink And Check Cell Is In Reduced Energy Saving State
    Log  \n========================================  console=true
    Log  Step 2: Perform Downlink And Check Cell Is In Reduced Energy Saving State\n  console=true
    Log  ========================================  console=true
    Log  Waiting for REDUCEDENERGYSAVING on LNCEL_R-${LTE_CELL_IDS_FOR_PSGRP}[0]...  console=true
    Wait Until Keyword Succeeds  8min  15sec  Check Power Saving  ${LTE_CELL_IDS_FOR_PSGRP}[0]  ENABLED  REDUCEDENERGYSAVING
    Check Power Saving  ${LTE_CELL_IDS_FOR_PSGRP}[1]  ENABLED  NOTENERGYSAVING
    Perform Downlink On LTE Cell  ${LTE_CELL_IDS_FOR_PSGRP}[1]  ${LTE_DL_DURATION}  ${LTE_DESIRED_THROUGHPUT_DOWNLINK}  ${LTE_MIN_THROUGHPUT_DOWNLINK}
    Log  TC waits 20 seconds before checking LNCEL_R-${LTE_CELL_IDS_FOR_PSGRP}[0] to be still in REDUCEDENERGYSAVING.\n  console=true
    Sleep  20s  TC waits 20s before checking LNCEL status.
    Check Power Saving  ${LTE_CELL_IDS_FOR_PSGRP}[0]  ENABLED  REDUCEDENERGYSAVING


PS.79_CB010869_LTE_Determine_Cell_TX_Switch_OFF_and_ON_list.Step 3: Perform Downlink And Check Cell Exit Reduced Energy Saving State
    Log  \n========================================  console=true
    Log  Step 3: Perform Downlink And Check Cell Exit Reduced Energy Saving State\n  console=true
    Log  ========================================  console=true
    ${current_date}  Get Current Date  result_format=datetime
    ${seconds_to_wait}  Subtract Date From Date  ${RTX_LOAD_STARTING_TIME}  ${current_date}
    ${min_and_sec}  Convert date  ${seconds_to_wait}  result_format=%M minutes and %S seconds
    Log  TC sleeps for ${min_and_sec} until RTX load ${LBPS_RTX_LOAD_THRES_DURATION} minutes time period starts.  console=true
    Sleep  ${seconds_to_wait}

    Wait Until Keyword Succeeds  1min  15s  Check Power Saving  ${LTE_CELL_IDS_FOR_PSGRP}[0]  ENABLED  REDUCEDENERGYSAVING
    Check Power Saving  ${LTE_CELL_IDS_FOR_PSGRP}[1]  ENABLED  NOTENERGYSAVING
    Perform Downlink On LTE Cell  ${LTE_CELL_IDS_FOR_PSGRP}[1]  ${LTE_DL_DURATION}  ${LTE_DESIRED_THROUGHPUT_DOWNLINK}  ${LTE_MIN_THROUGHPUT_DOWNLINK}
    Log  Waiting for NOTENERGYSAVING on LNCEL_R-${LTE_CELL_IDS_FOR_PSGRP}[0]...  console=true
    Wait Until Keyword Succeeds  180s  15s  Check Power Saving  ${LTE_CELL_IDS_FOR_PSGRP}[0]  ENABLED  NOTENERGYSAVING
    Log  Waiting for REDUCEDENERGYSAVING on LNCEL_R-${LTE_CELL_IDS_FOR_PSGRP}[0]...\n  console=true
    Wait Until Keyword Succeeds  8min  15sec  Check Power Saving  ${LTE_CELL_IDS_FOR_PSGRP}[0]  ENABLED  REDUCEDENERGYSAVING


PS.79_CB010869_LTE_Determine_Cell_TX_Switch_OFF_and_ON_list.Step 4: Perform Downlink And Check Cells Are In Reduced Energy Saving State
    Log  \n========================================  console=true
    Log  Step 4: Perform Downlink And Check Cells Are In Reduced Energy Saving State\n  console=true
    Log  ========================================  console=true
    ${current_date}  Get Current Date  result_format=datetime
    ${seconds_to_wait}  Subtract Date From Date  ${SECOND_TIME_PERIOD_ENDING_TIME}  ${current_date}
    ${min_and_sec}  Convert date  ${seconds_to_wait}  result_format=%M minutes and %S seconds
    Log  TC sleeps for ${min_and_sec} until second ${LBPS_RTX_LOAD_THRES_DURATION} minutes time period ends.  console=true
    Sleep  ${seconds_to_wait}

    Check Power Saving  ${LTE_CELL_IDS_FOR_PSGRP}[0]  ENABLED  REDUCEDENERGYSAVING
    Check Power Saving  ${LTE_CELL_IDS_FOR_PSGRP}[1]  ENABLED  NOTENERGYSAVING
    Perform Downlink On LTE Cell  ${LTE_CELL_IDS_FOR_PSGRP}[1]  ${LTE_DL_DURATION}  ${LTE_DESIRED_THROUGHPUT_DOWNLINK}  ${LTE_MIN_THROUGHPUT_DOWNLINK}
    Log  TC waits 20 seconds before checking LNCEL_R-${LTE_CELL_IDS_FOR_PSGRP}[0] to be still in REDUCEDENERGYSAVING.  console=true
    Sleep  20s  TC waits 20s before checking LNCEL status.
    Check Power Saving  ${LTE_CELL_IDS_FOR_PSGRP}[0]  ENABLED  REDUCEDENERGYSAVING

    ${current_date}  Get Current Date  result_format=datetime
    ${seconds_to_wait}  Subtract Date From Date  ${THIRD_TIME_PERIOD_ENDING_TIME}  ${current_date}
    ${min_and_sec}  Convert date  ${seconds_to_wait}  result_format=%M minutes and %S seconds
    Log  TC sleeps for ${min_and_sec} until PSGRP period duration ends.\n  console=true
    Sleep  ${seconds_to_wait}


PS.79_CB010869_LTE_Determine_Cell_TX_Switch_OFF_and_ON_list.Test Specific Teardown
    Log  \n============ SPECIFIC TEST TEARDOWN =============  console=true

    admin.Setup Admin  admin_api_log_dir=${RESULTS}/admin_api/  alias=${ute_admin_alias}
    ${features}  Create Dictionary  actLBRTXPowerSaving=false  actOnlineTXSwitch=false  actLbpsThresPerTimeWindow=false
    Set Parameters From Dictionary Under Given Object  ${LNBTS_DISTNAME}  ${features}

    Log  Deleting PSGRP-0 object...  console=true
    Remove PSGRP/NRPGRP Objects If Exist  PSGRP
    @{states_to_check}  Create List  operationalState  energySavingState
    @{expected_states}  Create List  ENABLED  NOTENERGYSAVING
    FOR  ${cell_id}  IN  @{LTE_CELL_IDS_FOR_PSGRP}
        Wait Until Keyword Succeeds  20min  30s  Check Cell States For Specific Cell  LNCEL  ${cell_id}  ${states_to_check}  ${expected_states}
    END
    Log  LNCELs are in correct energy saving state. [OK]\n  console=true

    Log  Unlock LTE cells with ids: ${LTE_CELLS_TO_BE_LOCKED}.\n  console=true
    @{states_to_check}  Create List  availabilityStatus  administrativeState
    @{expected_states}  Create List  -  UNLOCKED
    FOR  ${cell_id}  IN  @{LTE_CELLS_TO_BE_LOCKED}
        Change Parameter Under LNCEL  administrativeState  unlocked  ${cell_id}
        Wait Until Keyword Succeeds  120  15  Check Cell States For Specific Cell  LNCEL  ${cell_id}  ${states_to_check}  ${expected_states}
    END
    Log  Check if any unexpected alarm occured.\n  console=true
    Check If Unexpected Alarms Are Raised  ${skip_fault}
    admin.Teardown Admin  alias=${ute_admin_alias}
    Log  ========== SPECIFIC TEST TEARDOWN DONE ==========\n  console=true


PS.79_CB010869_LTE_Determine_Cell_TX_Switch_OFF_and_ON_list.Test Case Teardown
    common.Common Test Teardown
    PS.79_CB010869_LTE_Determine_Cell_TX_Switch_OFF_and_ON_list.Test Specific Teardown
