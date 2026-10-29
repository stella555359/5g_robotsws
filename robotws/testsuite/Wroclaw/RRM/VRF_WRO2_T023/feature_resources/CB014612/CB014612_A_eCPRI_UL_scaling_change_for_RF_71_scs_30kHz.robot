*** Settings ***
Documentation
...   contact: Monika Ceglarek

Resource    ../../resources/ca_IWK.robot
Library     resources/snapshot_analysis.py

*** Variables ***
${RMOD_SN}                                   # SN of RMOD for which UL gain correction will be checked

*** Keywords ***
TC__CB014612_A_eCPRI_UL_scaling_change_for_RF_71_scs_30kHz

    Set Tags    CA-RRM    AUTHOR-monika.ceglarek@nokia.com    MAINTAINER-monika.ceglarek@nokia.com
    ...         PHASE-CRT   SW-SBTS26R2    GROUP_IN_CHARGE-Pz_2_WRO_2


    Preconditions
    Step 1: Deactivate Feature CB014612
    Step 2: Collect Snapshot
    Step 3: Get UL Gain Correction
    Step 4: Activate Feature CB014612
    Step 5: Collect Snapshot
    Step 6: Get UL Gain Correction
    Step 7: Compare UL Gain Correction Values


Preconditions
    Log  \n==== Preconditions ====  console=True

    Create Global Variables
    Check If ActDisableEcpriUlScalingEnh Has Expected Value  expected_value=false


Create Global Variables
    Set Test Variable  ${CB014612_ACTIVATED}  True

    ${mrbts_id} =  Get BTS ID From ADMIN  alias=gNB
    Set Test Variable  ${MRBTS_ID}  ${mrbts_id}

    ${ul_gain_correction_dict} =  Create Dictionary
    Set Test Variable  ${UL_GAIN_CORRECTION_DICT}  ${ul_gain_correction_dict}


Check If ActDisableEcpriUlScalingEnh Has Expected Value
    [Arguments]  ${expected_value}

    ${_}  ${parsed_scf_gnb}=  Save And Parse SCF  SCF_gNB  alias=gNB
    ${cb014612_status} =  Run Keyword And Return Status
    ...  Check Element In SCF  ${parsed_scf_gnb}  FEATCADM  FEATCADM-1  /p[@name='actDisableEcpriUlScalingEnh']
    ...  <p name="actDisableEcpriUlScalingEnh">${expected_value}</p>  dist_name_substring=True
    Should Be True  ${cb014612_status}
    ...  msg=Value of parameter actDisableEcpriUlScalingEnh is different than expected (Expected value: ${expected_value}).


Step ${index}: ${action} Feature CB014612
    Log  \n==== Step ${index}: ${action} Feature CB014612 ====  console=True

    Set Current Time In Epoch Format
    ${value} =  Set Variable If  '${action}' == 'Activate'  false  true
    Toggle Feature CB014612  ${value}
    Log  Feature CB014612 ${action}d.  console=True


Set Current Time In Epoch Format
    ${current_date} =  Get Current Date  time_zone=UTC
    Log  \nCurrent date: ${current_date}  console=True
    ${current_epoch} =  Get Current Date  result_format=epoch
    Set Test Variable  ${CURRENT_EPOCH}  ${current_epoch}


Toggle Feature CB014612
    [Arguments]  ${value}
    IF  '${value}' == 'false'  Set Test Variable  ${CB014612_ACTIVATED}  True
    Perform Parameter Recommissioning  MRBTS-${MRBTS_ID}/MNL-1/MNLENT-1/FEATCADM-1
    ...  actDisableEcpriUlScalingEnh  update  ${value}  connection=gNB
    IF  '${value}' == 'true'  Set Test Variable  ${CB014612_ACTIVATED}  False
    Wait Until Keyword Succeeds  1min  10s  Verify BTS States For IWK Test
    Check If ActDisableEcpriUlScalingEnh Has Expected Value  expected_value=${value}


Step ${index}: Collect Snapshot
    Log  \n==== Step ${index}: Collect Snapshot ====  console=True

    ${timestamp} =  Run  date +%H-%M-%S
    Log  Collecting snapshot...  console=True
    Collect Snapshot  ${LOG_PATH}/snapshots/snapshot_${timestamp}.zip  timeout=1h  connection=gNB
    Log  DONE  console=True
    Set Test Variable  ${SNAPSHOT_PATH}  ${LOG_PATH}/snapshots/snapshot_${timestamp}.zip


Step ${index}: Get UL Gain Correction
    Log  \n==== Step ${index}: Get UL Gain Correction ====  console=True

    ${ul_gain_correction} =  Get UL Gain Correction  snapshot_path=${SNAPSHOT_PATH}  mrbts_id=${MRBTS_ID}
    ...  rmod_sn=${RMOD_SN}  min_epoch=${CURRENT_EPOCH}  destination_dir=${LOG_PATH}/misc_logs/step_${index}
    Set To Dictionary  ${UL_GAIN_CORRECTION_DICT}  step_${index}=${ul_gain_correction}
    Set Test Variable  ${UL_GAIN_CORRECTION_DICT}


Step 7: Compare UL Gain Correction Values
    Log  \n==== Step 7: Compare UL Gain Correction Values ====  console=True
    ${difference} =  Evaluate  ${UL_GAIN_CORRECTION_DICT['step_6']} - ${UL_GAIN_CORRECTION_DICT['step_3']}

    Should Be True  ${difference} == 12
    ...  msg=Difference between UL gain correction before and after feature activation is different than 12dB.
    Log  Difference between UL gain correction values when feature is activated and deactivated is 12 dB.  console=True


TC Setup
    IWK Test Setup  local_enb_connection=False


TC Teardown
    [Timeout]  60 min
    Log  \n=== TC Teardown ===  console=True
    Run Keyword If  not ${CB014612_ACTIVATED}  Toggle Feature CB014612  false
    IWK Test Teardown  delta_exists=False  local_enb_connection=False
