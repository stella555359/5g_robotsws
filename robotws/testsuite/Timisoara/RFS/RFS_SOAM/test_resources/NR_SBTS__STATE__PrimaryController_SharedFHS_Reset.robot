*** Settings ***
Documentation    TC__NR_SBTS__STATE__PrimaryController_SharedFHS_Reset
Variables    tc_variables/nr_sbts__state__primary_controller_sharedFHS_reset_alarms_definitions.py
Resource    ../../resources/rfs_frame_rfs_soam_taf.robot

*** Variables ***
${REPEAT_COUNTER}  3     # Number of NR shared FHS reset operations, default value 3
${FHS_RESET_WRN_THR}     270   # Time spent between first cell down to last cell up on FHS
                               # Default value: in accordance with KPI53a specifications
${FHS_RESET_MAX_WAIT_TIME}  900    # Maximum waiting time for FHS reset to be finished; default value 900 seconds

*** Keywords ***
TC__NR_SBTS__STATE__PrimaryController_SharedFHS_Reset
    [Documentation]
    ...  [CASE LINK]: https://jiradc.ext.net.nokia.com/browse/TAT-24502
    ...
    ...  *****************
    ...  Basic information
    ...  *****************
    ...  NR-SBTS test case for Primary Controller shared FHS reset, - x times sequence.
    ...  x - value of REPEAT_COUNTER parameter (default: 3)
    ...  The main steps performed for the test are:
    ...  - check initial state and alarms for both NR and SBTS technologies
    ...  - check primary controller and secondary controller BTS
    ...  - check FHS connection port from bbmod
    ...  - perform shared FHS reset
    ...  – check NR and SBTS status during FHS reset
    ...  – check final status after FHS reset.
    ...  - check final state and alarms for both NR and SBTS technologies
    ...  - check FHS KPI53a
    ...  Pass criteria: FHS Reset operation works as expected, states and alarms are as expected
    ...
    ...  ******************
    ...  History of changes
    ...  ******************
    ...  - 20.03.2023 - https://jiradc.ext.net.nokia.com/browse/TAT-24502 - [5G][OBSAI][CPRI][FHS] [CB008470] New NRL scenario
    ...  NR_SBTS__STATE__FHS_Reset_from_WEBEM
    ...  - 14.07.2023 - https://jiradc.ext.net.nokia.com/browse/TAT-25746 - [5G][OBSAI][CPRI][FHS] CB008470 FHS Status checked too early
    ...  - 11.09.2025 - https://jiradc.ext.net.nokia.com/browse/TAT-29834 - Update KW for BBMOD CELL mapping based on BBPOOL info
    ...  - 24.10.2025 - https://jiradc.ext.net.nokia.com/browse/TAT-29823 -
    ...  Unify alarm list names in order alarm list to begin with upper case Alias - NR_SBTS
    ...
    ...  *******************
    ...  Test case flowchart
    ...  *******************
    ...  .. image:: https://gitlabe1.ext.net.nokia.com/panda-docs/hran_doc/-/blob/master/testsuite/RFS_SOAM/
    ...  TAT-24502_NR_SBTS__STATE__PrimaryController_SharedFHS_Reset.png

    Set Tags    CA-STATE    OWNER-paul.neag@nokia.com    AUTHOR-andreea.szentannai@nokia.com    PHASE-QT    SW-SBTS23R2

    Step 1: Check initial all BTS state
    Step 2: Check initial all BTS alarms
    Step 3: Get BTS primary controller and BTS secondary controller role
    Step 4: Get shared FHS info for both BTS
    FOR  ${INDEX}  IN RANGE  1  ${REPEAT_COUNTER}+1
        Log  ==============================================================================  console=True
        Log  Start Cycle ${INDEX} of ${REPEAT_COUNTER}  console=True
        Log  ==============================================================================  console=True
        Step 5: Perform shared FHS Reset operation for iteration ${INDEX}
        Step 6: Check final all BTS state
        Step 7: Check final all BTS alarms
        Step 8: Check final number and state of Cells and RMs
    END

    [Teardown]  Particular Teardown

Step ${index}: Check ${when} all BTS state
    [Documentation]
    ...  SBTS state is checked according to Admin for BTS and each configured RAT

    Log  Step ${index}: Check ${when} all BTS state  console=True
    FOR  ${alias}  IN  @{alias_list}
        Log  ***** Check ${when} BTS ${alias} state *****  console=True
        Admin Check BTS RAT Procedural State  alias=${alias}  timeout=600
        Admin Check BTS Procedural and Blocking states  ${OnAir_}  ${Unblocked_}  alias=${alias}
        Log  BTS ${alias} site - proceduralState: OnAir, blockingState: Unblocked  console=True
    END

Step ${index}: Check ${when} all BTS alarms
    [Documentation]
    ...  SBTS alarms are compared with values from expected, ignored and critical alarms lists. SBTS alarms are get
    ...  from Admin

    Log  Step ${index}: Check ${when} all BTS alarms  console=True
    FOR  ${alias}  IN  @{alias_list}
        Log  ***** Check ${when} BTS ${alias} alarms *****  console=True
        ${wait_for_alarm_clear}=  Set Variable If  '${when}' == 'final'  15 min  5 min
        Get and Check Alarms SOAM  alias=${alias}  expected_alarms=@{EMPTY}  ignored_alarms=${${alias.upper()}_IGNORED_ALARMS}
        ...  critical_alarms=${${alias.upper()}_CRITICAL_ALARMS}  wait_for_alarm_clear=${wait_for_alarm_clear}
        Log  BTS ${alias} site - expected, ignored and critical alarms checked  console=True
    END

Step ${index}: Get BTS primary controller and BTS secondary controller role
    Log  Step ${index}: Get BTS primary controller and BTS secondary controller role  console=True

    ${Master_shared_RMOD_list}  ${Slave_shared_RMOD_list}  ${Master_dedicated_RMOD_list}  ${Slave_dedicated_RMOD_list}=
    ...  Admin Get shared and dedicated module list for Master and Slave  RMOD  Master  Slave
    Sort List  ${Master_shared_RMOD_list}
    Sort List  ${Slave_shared_RMOD_list}
    Set Test Variable  ${Master_shared_RMOD_list}
    Set Test Variable  ${Slave_shared_RMOD_list}

    Get BTS primary controller shared RMOD list  Master
    Get BTS primary controller shared RMOD list  Slave
    Get BTS secondary controller shared RMOD list  Master
    Get BTS secondary controller shared RMOD list  Slave

    ${BTS_secondary_controller}=  Set Variable If
    ...  ${Master_primary_controller_shared_RMOD_count} == 0  Master  ${Slave_primary_controller_shared_RMOD_count} == 0  Slave  BOTH
    ${BTS_primary_controller}=  Set Variable If  '${BTS_secondary_controller}' == 'Master'  Slave  '${BTS_secondary_controller}' == 'Slave'  Master
    ...  BOTH

    Set Test Variable  ${BTS_primary_controller}
    Set Test Variable  ${BTS_secondary_controller}

    Log  BTS primary controller role: ${BTS_primary_controller}  console=True
    Log  BTS secondary controller role: ${BTS_secondary_controller}  console=True

Step ${index}: Get shared FHS info for both BTS
    [Documentation]
    ...  BTS info related to shared FHS

    [Timeout]  5 min
    Log  Step ${index}: Get shared FHS info for both BTS  console=True

    ${Master_shared_FHS_list}  ${Slave_shared_FHS_list}  ${Master_dedicated_FHS_list}  ${Slave_dedicated_FHS_list}=
    ...  Admin Get shared and dedicated module list for Master and Slave  FHS  Master  Slave
    Log  Shared FHS on NR BTS: ${Master_shared_FHS_list}  console=True
    Log  Shared FHS on SBTS BTS: ${Slave_shared_FHS_list}  console=True
    Set Test Variable  ${Master_shared_FHS_list}
    Set Test Variable  ${Slave_shared_FHS_list}

    Get FHS ID SN dict  Master
    Get FHS ID SN dict  Slave
    Set Test Variable  ${Master_FHS_SN_ID_dict}  ${Master_module_SN_ID_dict}
    Set Test Variable  ${Master_FHS_ID_SN_dict}  ${Master_module_ID_SN_dict}
    Set Test Variable  ${Slave_FHS_SN_ID_dict}  ${Slave_module_SN_ID_dict}
    Set Test Variable  ${Slave_FHS_ID_SN_dict}  ${Slave_module_ID_SN_dict}

    ${Master_shared_FHS_count}=  Get Length  ${Master_shared_FHS_list}
    ${Slave_shared_FHS_count}=  Get Length  ${Slave_shared_FHS_list}

    Run Keyword If  ${Master_shared_FHS_count} == 0 or ${Slave_shared_FHS_count} == 0  Run Keywords
    ...  Log  No shared FHS on any BTS!  console=True
    ...  AND  Fail  No shared FHS on any BTS!

    ${Master_shared_FHS_RMOD_list}=  Get shared RMOD connected to shared FHS  ${Master_shared_FHS_list}  Master
    ${Slave_shared_FHS_RMOD_list}=  Get shared RMOD connected to shared FHS  ${Slave_shared_FHS_list}  Slave
    ${Master_shared_FHS_RMOD_count}=  Get Length  ${Master_shared_FHS_RMOD_list}
    ${Slave_shared_FHS_RMOD_count}=  Get Length  ${Slave_shared_FHS_RMOD_list}
    Set Test Variable  ${Master_shared_FHS_RMOD_list}
    Set Test Variable  ${Slave_shared_FHS_RMOD_list}
    Set Test Variable  ${Master_shared_FHS_RMOD_count}
    Set Test Variable  ${Slave_shared_FHS_RMOD_count}

    ${Slave_RMOD_L3Protocol_dict}=  Admin Get RMOD L3 Protocol Info  Slave
    ${Slave_CPRI_shared_RMOD_list}=  Create List
    ${Slave_OBSAI_shared_RMOD_list}=  Create List
    FOR  ${item}  IN  @{Slave_shared_FHS_RMOD_list}
        ${RMOD_L3Protocol}=  Get From Dictionary  ${Slave_RMOD_L3Protocol_dict}  ${item}
        Run Keyword If  '${RMOD_L3Protocol}' == 'CPRI_RP1'
        ...  Append To List  ${Slave_CPRI_shared_RMOD_list}  ${item}
        ...  ELSE IF  '${RMOD_L3Protocol}' == 'RP301_RP1'
        ...  Append To List  ${Slave_OBSAI_shared_RMOD_list}  ${item}
    END
    ${Slave_CPRI_shared_RMOD_count}=  Get Length  ${Slave_CPRI_shared_RMOD_list}
    Set Test Variable  ${Slave_CPRI_shared_RMOD_list}
    Set Test Variable  ${Slave_CPRI_shared_RMOD_count}
    Set Test Variable  ${Slave_OBSAI_shared_RMOD_list}

    ${Master_shared_RMOD_CELL_list}=  Get CELL Mapping By RMOD list  ${Master_shared_FHS_RMOD_list}  Master
    ${Slave_shared_RMOD_CELL_list}=  Get CELL Mapping By RMOD list  ${Slave_shared_FHS_RMOD_list}  Slave
    Set Test Variable  ${Master_shared_RMOD_CELL_list}
    Set Test Variable  ${Slave_shared_RMOD_CELL_list}

    Set Test Variable  ${SBTS_LTE_CELL_shared_RM_list}  ${SBTS_LTE_CELL_ids}
    Set Test Variable  ${SBTS_WCDMA_CELL_shared_RM_list}  ${SBTS_WCDMA_CELL_ids}
    Set Test Variable  ${SBTS_GSM_CELL_shared_RM_list}  ${SBTS_GSM_CELL_ids}

    ${NR_BBMOD_list}=  Get Ids For All  BBMOD  alias=Master
    ${SBTS_BBMOD_list}=  Get Ids For All  BBMOD  alias=Slave
    Set Test Variable  ${NR_BBMOD_list}
    Set Test Variable  ${SBTS_BBMOD_list}

    Get BBMOD ID SN dict  Master
    Get BBMOD ID SN dict  Slave

    ${NR_BBMOD_shared_FHS_dict}  ${NR_BBMOD_dedicated_FHS_dict}=  Get BBMOD FHS dict  ${SBTS_BBMOD_list}  Master
    ${SBTS_BBMOD_shared_FHS_dict}  ${SBTS_BBMOD_dedicated_FHS_dict}=  Get BBMOD FHS dict  ${SBTS_BBMOD_list}  Slave
    Set Test Variable  ${NR_BBMOD_shared_FHS_dict}
    Set Test Variable  ${SBTS_BBMOD_shared_FHS_dict}

    ${BBMOD_CELL_dict}=  Get BBMOD CELL mapping based on BBPOOL info from SCF  Slave
    Set Test Variable  ${SBTS_BBMOD_CELL_dict}  ${BBMOD_CELL_dict}

    Get SBTS FHS cell lists using BBPOOL

Step ${index}: Perform shared FHS Reset operation for iteration ${CYCLE}
    [Documentation]
    ...  Perform shared FHS Reset operation

    Log  Step ${index}: Perform NR Reset shared FHS operation for iteration ${CYCLE}  console=True
    FOR  ${item}  IN  @{${BTS_primary_controller}_shared_FHS_list}
        Get Current Date UTC info  start_resetFHS
        Reset shared FHS  ${item}
        Get Current Date UTC info  end_resetFHS
        Get and check KPI53a info from IMS file  ${FHS_SN}  ${item}  ${BTS_primary_controller}  ${CYCLE}
    END

Step ${index}: Check final number and state of Cells and RMs
    [Documentation]
    ...  Following checks are performed:
    ...  - number of configured cells and radio modules in SCF are properly mapped on BTS running view ADMIN
    ...  - check cells states
    ...  - check radio modules states

    Log  Step ${index}: Check final number and state of Cells and RMs  console=True
    RFS Test Case Final Checks

Get BTS primary controller shared RMOD list
    [Arguments]  ${alias}
    ${BTS_primary_controller_RMOD_list}=  Get RMOD radioMaster info  alias=${alias}
    ${BTS_primary_controller_shared_RMOD_list}=  Create List
    FOR  ${item}  IN  @{BTS_primary_controller_RMOD_list}
       Run Keyword If  '${item}' in ${${alias}_shared_RMOD_list}
        ...  Append To List  ${BTS_primary_controller_shared_RMOD_list}  ${item}
    END
    Sort List  ${BTS_primary_controller_shared_RMOD_list}
    Set Test Variable  ${${alias}_primary_controller_shared_RMOD_list}  ${BTS_primary_controller_shared_RMOD_list}
    Log  BTS ${alias} configured as primary controller for: ${BTS_primary_controller_shared_RMOD_list}  console=True
    ${BTS_primary_controller_shared_RMOD_count}=  Get Length  ${BTS_primary_controller_shared_RMOD_list}
    Set Test Variable  ${${alias}_primary_controller_shared_RMOD_count}  ${BTS_primary_controller_shared_RMOD_count}

Get BTS secondary controller shared RMOD list
    [Arguments]  ${alias}
    ${BTS_secondary_controller_shared_RMOD_list}=  Copy List  ${${alias}_shared_RMOD_list}
    FOR  ${item}  IN  @{${alias}_primary_controller_shared_RMOD_list}
        Remove Values From List  ${BTS_secondary_controller_shared_RMOD_list}  ${item}
    END
    Set Test Variable  ${${alias}_secondary_controller_shared_RMOD_list}  ${BTS_secondary_controller_shared_RMOD_list}

Get shared RMOD connected to shared FHS
    [Arguments]  ${FHS_list}  ${alias}
    ${shared_FHS_RMOD_list}=  Create List
    FOR  ${item}  IN  @{FHS_list}
        ${RMOD_list}=  Get RMOD Mapping By FHS Id  ${item}  ${alias}
        Append To List  ${shared_FHS_RMOD_list}  @{RMOD_list}
    END
    ${shared_FHS_RMOD_list}=  Remove Duplicates  ${shared_FHS_RMOD_list}
    [Return]  ${shared_FHS_RMOD_list}

Get RMOD Mapping By FHS Id
    [Arguments]   ${FHS_id}  ${alias}
    ${RMOD_list}=  Create List
    ${CABLINK_list}=  Get Parameters For All  class_name=CABLINK  connection=${alias}
    FOR  ${item}  IN  @{CABLINK_list}
        ${CABLINK_id}=  Get From Dictionary  ${item}  id
        ${firstEndpointDN_FHS_R}=  Run Keyword And Return Status  Should Contain  ${item.firstEndpointDN}  FHS_R
        ${secondEndpointDN_RMOD_R}=  Run Keyword And Return Status  Should Contain  ${item.secondEndpointDN}  RMOD_R
        Run Keyword If  ${firstEndpointDN_FHS_R} and ${secondEndpointDN_RMOD_R}
        ...  Run Keyword If  '${item.firstEndpointDN}' == '${FHS_id}'
        ...  Append To List  ${RMOD_list}  ${item.secondEndpointDN}
    END
    ${RMOD_list}=  Remove Duplicates  ${RMOD_list}
    [Return]  ${RMOD_list}

Get BBMOD FHS dict
    [Arguments]  ${BBMOD_list}  ${alias}
    ${BBMOD_shared_FHS_dict}=  Create Dictionary
    ${BBMOD_dedicated_FHS_dict}=  Create Dictionary
    FOR  ${item}  IN  @{BBMOD_list}
        ${shared_FHS_list}  ${dedicated_FHS_list}=  Get FHS Mapping By BBMOD Id  ${item}  ${alias}
        Set To Dictionary  ${BBMOD_shared_FHS_dict}  ${item}  ${shared_FHS_list}
        Set To Dictionary  ${BBMOD_dedicated_FHS_dict}  ${item}  ${dedicated_FHS_list}
    END
    [Return]  ${BBMOD_shared_FHS_dict}  ${BBMOD_dedicated_FHS_dict}

Get FHS Mapping By BBMOD Id
    [Arguments]   ${BBMOD_id}  ${alias}
    ${shared_FHS_list}=  Create List
    ${dedicated_FHS_list}=  Create List
    ${CABLINK_list}=  Get Parameters For All  class_name=CABLINK  connection=${alias}
    FOR  ${item}  IN  @{CABLINK_list}
        ${CABLINK_id}=  Get From Dictionary  ${item}  id
        ${firstEndpointDN_BBMOD_R}=  Run Keyword And Return Status  Should Contain  ${item.firstEndpointDN}  BBMOD_R
        ${secondEndpointDN_FHS_R}=  Run Keyword And Return Status  Should Contain  ${item.secondEndpointDN}  FHS_R
        ${shared_FHS}=  Run Keyword And Return Status  Should Contain  ${${alias}_shared_FHS_list}  ${item.secondEndpointDN}
        ${dedicated_FHS}=  Run Keyword And Return Status  Should Contain  ${${alias}_dedicated_FHS_list}  ${item.secondEndpointDN}
        Run Keyword If  ${firstEndpointDN_BBMOD_R} and ${secondEndpointDN_FHS_R}
        ...  Run Keyword If  '${item.firstEndpointDN}' == '${BBMOD_id}' and ${shared_FHS}
        ...  Append To List  ${shared_FHS_list}  ${item.secondEndpointDN}
        Run Keyword If  ${firstEndpointDN_BBMOD_R} and ${secondEndpointDN_FHS_R}
        ...  Run Keyword If  '${item.firstEndpointDN}' == '${BBMOD_id}' and ${dedicated_FHS}
        ...  Append To List  ${dedicated_FHS_list}  ${item.secondEndpointDN}
    END
    ${shared_FHS_list}=  Remove Duplicates  ${shared_FHS_list}
    ${dedicated_FHS_list}=  Remove Duplicates  ${dedicated_FHS_list}
    [Return]  ${shared_FHS_list}  ${dedicated_FHS_list}

Get CELL Mapping By RMOD list
    [Arguments]   ${RMOD_list}  ${alias}
    ${CELL_list}=  Create List
    FOR  ${item}  IN  @{RMOD_list}
        ${RMOD_CELL_list}=  Get Cell Mapping By Module Id  module_id=${item}  connection=${alias}
        Append To List  ${CELL_list}  @{RMOD_CELL_list}
    END
    ${CELL_list}=  Remove Duplicates  ${CELL_list}
    [Return]  ${CELL_list}

Get SBTS FHS cell lists using BBPOOL
    ${BBMOD_FHS_cells_list}=  Create List
    ${BBMOD_cells_list}=  Create List
    FOR  ${item}  IN  @{SBTS_BBMOD_list}
        ${connected_to_FHS}=  Get From Dictionary  ${SBTS_BBMOD_shared_FHS_dict}  ${item}
        ${cells_list}=  Get From Dictionary  ${SBTS_BBMOD_CELL_dict}  ${item}
        Run Keyword If  ${connected_to_FHS}  Append To List  ${BBMOD_FHS_cells_list}  @{cells_list}
        ...  ELSE  Append To List  ${BBMOD_cells_list}  @{cells_list}
    END
    ${SBTS_BBMOD_FHS_LTE_cells}=  Create List
    ${SBTS_BBMOD_FHS_WCDMA_cells}=  Create List
    ${SBTS_BBMOD_FHS_GSM_cells}=  Create List
    ${SBTS_BBMOD_LTE_cells}=  Create List
    ${SBTS_BBMOD_WCDMA_cells}=  Create List
    ${SBTS_BBMOD_GSM_cells}=  Create List
    FOR  ${item}  IN  @{SBTS_LTE_CELL_shared_RM_list}
        Run Keyword If  '${item}' in @{BBMOD_FHS_cells_list}  Append To List  ${SBTS_BBMOD_FHS_LTE_cells}  ${item}
        ...  ELSE IF  '${item}' in @{BBMOD_cells_list}  Append To List  ${SBTS_BBMOD_LTE_cells}  ${item}
    END
    FOR  ${item}  IN  @{SBTS_WCDMA_CELL_shared_RM_list}
        Run Keyword If  '${item}' in @{BBMOD_FHS_cells_list}  Append To List  ${SBTS_BBMOD_FHS_WCDMA_cells}  ${item}
        ...  ELSE IF  '${item}' in @{BBMOD_cells_list}  Append To List  ${SBTS_BBMOD_WCDMA_cells}  ${item}
    END
    FOR  ${item}  IN  @{SBTS_GSM_CELL_shared_RM_list}
        Run Keyword If  '${item}' in @{BBMOD_FHS_cells_list}  Append To List  ${SBTS_BBMOD_FHS_GSM_cells}  ${item}
        ...  ELSE IF  '${item}' in @{BBMOD_cells_list}  Append To List  ${SBTS_BBMOD_WCDMA_cells}  ${item}
    END
    Set Test Variable  ${SBTS_BBMOD_FHS_LTE_cells}
    Set Test Variable  ${SBTS_BBMOD_FHS_WCDMA_cells}
    Set Test Variable  ${SBTS_BBMOD_FHS_GSM_cells}
    Set Test Variable  ${SBTS_BBMOD_LTE_cells}
    Set Test Variable  ${SBTS_BBMOD_WCDMA_cells}
    Set Test Variable  ${SBTS_BBMOD_GSM_cells}

Reset shared FHS
    [Arguments]  ${primary_FHS_id}

    ${FHS_SN}=  Get From Dictionary  ${${BTS_primary_controller}_FHS_ID_SN_dict}  ${primary_FHS_id}
    ${secondary_FHS_id}=  Get From Dictionary  ${${BTS_secondary_controller}_FHS_SN_ID_dict}  ${FHS_SN}
    Set Test Variable  ${FHS_SN}
    Set Test Variable  ${secondary_FHS_id}

    ${NR_FHS_id}=  Set Variable If  '${BTS_primary_controller}'=='Master'  ${primary_FHS_id}  ${secondary_FHS_id}
    ${SBTS_FHS_id}=  Set Variable If  '${BTS_primary_controller}'=='Slave'  ${primary_FHS_id}  ${secondary_FHS_id}

    ${RMOD_state_disabled_check}=  Set Variable  operationalState=${Disabled_}, availabilityStatus=${NotInstalled_}, administrativeState=${Unlocked_}
    ${RMOD_state_enabled_check}=  Set Variable  operationalState=${Enabled_}, administrativeState=${Unlocked_}
    ${CELL_state_enabled_check}=  Set Variable  operationalState=${Enabled_}, blockingState=${Unblocked_}
    ${CELL_state_disabled_check}=  Set Variable  operationalState=${Disabled_}, blockingState=${Unblocked_}
    ${RMOD_state_disabled}=  Set Variable  operationalState=Disabled, availabilityStatus=NotInstalled, administrativeState=Unlocked
    ${RMOD_state_enabled}=  Set Variable  operationalState=Enabled, administrativeState=Unlocked
    ${CELL_state_enabled}=  Set Variable  operationalState=Enabled, blockingState=Unblocked
    ${CELL_state_disabled}=  Set Variable  operationalState=Disabled, blockingState=Unblocked

    ${NR_FID10_FHS}=  Evaluate  ${Master_shared_FHS_RMOD_count} + 1
    ${SBTS_FID10_FHS}=  Evaluate  ${Slave_CPRI_shared_RMOD_count} + 1
    ${NR_FID10_count}=  Set Variable If  '${BTS_primary_controller}'=='Master'  ${Master_shared_FHS_RMOD_count}  ${NR_FID10_FHS}
    ${SBTS_FID10_count}=  Set Variable If  '${BTS_primary_controller}'=='Slave'  ${Slave_CPRI_shared_RMOD_count}  ${SBTS_FID10_FHS}
    ${MASTER_EXPECTED_ALARMS_10_full}=  Prepare expected alarms list  ${MASTER_EXPECTED_ALARMS_10}  ${NR_FID10_count}
    ${SLAVE_EXPECTED_ALARMS_10_full}=  Prepare expected alarms list  ${SLAVE_EXPECTED_ALARMS_10}  ${SBTS_FID10_count}
    ${MASTER_IGNORED_ALARMS_full}=  Combine Lists  ${MASTER_IGNORED_ALARMS}  ${MASTER_IGNORED_ALARMS_DURING_FHS_RESET}

    Log  Perform "Reset" operation from NR BTS on shared FHS with SN ${FHS_SN}  console=True

    ${new_alias}=  Set Variable  resetFHS
    Get Current Time  initial
    Start new ADMIN instance  alias=${BTS_primary_controller}  new_alias=${new_alias}  connection_type=${connection_type_${BTS_primary_controller}}
    ${reset_info}=  Run Keyword In Background  Reset Unit  dist_name=${primary_FHS_id}  reset_type=Hard  timeout=${FHS_RESET_MAX_WAIT_TIME}
    ...  connection=${new_alias}
    Sleep  5s

    Log  Check NR and SBTS state during reset shared FHS with SN ${FHS_SN}  console=True
    Log  Check NR shared FHS with SN ${FHS_SN}  console=True
    ${remained_MAX_WAIT_TIME}=  Get elapsed time  ${time_initial}  ${FHS_RESET_MAX_WAIT_TIME}
    Wait Until Keyword Succeeds  ${remained_MAX_WAIT_TIME} sec  2 sec  Admin Check FHS state  ${NR_FHS_id}  ${Disabled_}  ${NotInstalled_}
    ...  ${Unlocked_}  Master
    Log  NR shared FHS with SN ${FHS_SN} status as expected  console=True
    ${remained_MAX_WAIT_TIME}=  Get elapsed time  ${time_initial}  ${FHS_RESET_MAX_WAIT_TIME}
    Check BTS Item State  NR  RMOD  ${Master_shared_FHS_RMOD_list}  ${RMOD_state_disabled_check}  ${RMOD_state_disabled}  ${remained_MAX_WAIT_TIME}
    ...  Master
    Log  All NR shared RMOD(s) connected to shared FHS with SN ${FHS_SN} status as expected  console=True
    ${remained_MAX_WAIT_TIME}=  Get elapsed time  ${time_initial}  ${FHS_RESET_MAX_WAIT_TIME}
    Check BTS Item State  NR  NRCEL  ${Master_shared_RMOD_CELL_list}  ${CELL_state_disabled_check}  ${CELL_state_disabled}
    ...  ${remained_MAX_WAIT_TIME}  Master
    Log  All NR cell{s} mapped on shared RMOD(s) connected to shared FHS with SN ${FHS_SN} status as expected  console=True

    Log  Check SBTS shared FHS with SN ${FHS_SN}  console=True
    ${remained_MAX_WAIT_TIME}=  Get elapsed time  ${time_initial}  ${FHS_RESET_MAX_WAIT_TIME}
    Wait Until Keyword Succeeds  ${remained_MAX_WAIT_TIME} sec  2 sec  Admin Check FHS state  ${SBTS_FHS_id}  ${Disabled_}  ${NotInstalled_}
    ...  ${Unlocked_}  Slave
    Log  SBTS shared FHS with SN ${FHS_SN} status as expected  console=True
    ${remained_MAX_WAIT_TIME}=  Get elapsed time  ${time_initial}  ${FHS_RESET_MAX_WAIT_TIME}
    Check BTS Item State  SBTS  RMOD  ${Slave_CPRI_shared_RMOD_list}  ${RMOD_state_disabled_check}  ${RMOD_state_disabled}
    ...  ${remained_MAX_WAIT_TIME}  Slave
    Check BTS Item State  SBTS  RMOD  ${Slave_OBSAI_shared_RMOD_list}  ${RMOD_state_enabled_check}  ${RMOD_state_enabled}  5  Slave
    Log  All SBTS shared RMOD(s) connected to shared FHS with SN ${FHS_SN} status as expected  console=True
    ${remained_MAX_WAIT_TIME}=  Get elapsed time  ${time_initial}  ${FHS_RESET_MAX_WAIT_TIME}
    Run Keyword If  ${SBTS_BBMOD_FHS_LTE_cells}
    ...  Check BTS Item State  SBTS  LNCEL  ${SBTS_BBMOD_FHS_LTE_cells}  ${CELL_state_disabled_check}  ${CELL_state_disabled}
    ...  ${remained_MAX_WAIT_TIME}  Slave
    ${remained_MAX_WAIT_TIME}=  Get elapsed time  ${time_initial}  ${FHS_RESET_MAX_WAIT_TIME}
    Run Keyword If  ${SBTS_BBMOD_FHS_WCDMA_cells}
    ...  Check BTS Item State  SBTS  WNCEL  ${SBTS_BBMOD_FHS_WCDMA_cells}  ${CELL_state_disabled_check}  ${CELL_state_disabled}
    ...  ${remained_MAX_WAIT_TIME}  Slave
    ${remained_MAX_WAIT_TIME}=  Get elapsed time  ${time_initial}  ${FHS_RESET_MAX_WAIT_TIME}
    Run Keyword If  ${SBTS_BBMOD_FHS_GSM_cells}
    ...  Check BTS Item State  SBTS  GNCEL  ${SBTS_BBMOD_FHS_GSM_cells}  ${CELL_state_disabled_check}  ${CELL_state_disabled}
    ...  ${remained_MAX_WAIT_TIME}  Slave
    Run Keyword If  ${SBTS_BBMOD_LTE_cells}
    ...  Check BTS Item State  SBTS  LNCEL  ${SBTS_BBMOD_LTE_cells}  ${CELL_state_enabled_check}  ${CELL_state_enabled}  5  Slave
    Run Keyword If  ${SBTS_BBMOD_WCDMA_cells}
    ...  Check BTS Item State  SBTS  WNCEL  ${SBTS_BBMOD_WCDMA_cells}  ${CELL_state_enabled_check}  ${CELL_state_enabled}  5  Slave
    Run Keyword If  ${SBTS_BBMOD_GSM_cells}
    ...  Check BTS Item State  SBTS  GNCEL  ${SBTS_BBMOD_GSM_cells}  ${CELL_state_enbled_check}  ${CELL_state_enabled}  5  Slave
    Log  All SBTS cell{s} mapped on shared RMOD(s) connected to shared FHS with SN ${FHS_SN} status as expected  console=True

    Log  Check NR and SBTS alarms during reset shared FHS with SN ${FHS_SN}  console=True
    Log  NR BTS "No connection to Unit (10)" alarm, expected number: ${NR_FID10_count}  console=True
    Get and Check Alarms SOAM  alias=Master  expected_alarms=${MASTER_EXPECTED_ALARMS_10_full}  ignored_alarms=${MASTER_IGNORED_ALARMS_full}
    ...  critical_alarms=${MASTER_CRITICAL_ALARMS}
    Log  NR BTS "No connection to Unit (10)" alarm, found number: ${NR_FID10_count}, as expected!  console=True
    Log  NR site - expected, ignored and critical alarms checked  console=True
    Log  SBTS BTS "No connection to Unit (10)" alarm, expected number: ${SBTS_FID10_count}  console=True
    Get and Check Alarms SOAM  alias=Slave  expected_alarms=${SLAVE_EXPECTED_ALARMS_10_full}
    ...  ignored_alarms=${SLAVE_IGNORED_ALARMS}  critical_alarms=${SLAVE_CRITICAL_ALARMS}
    Log  SBTS BTS "No connection to Unit (10)" alarm, found number: ${SBTS_FID10_count}, as expected!  console=True
    Log  SBTS site - expected, ignored and critical alarms checked  console=True

    Collect Keyword Result  ${reset_info}  timeout=${FHS_RESET_MAX_WAIT_TIME}

    Log  Check NR and SBTS state after reset shared FHS with SN ${FHS_SN}:  console=True
    ${remained_MAX_WAIT_TIME}=  Get elapsed time  ${time_initial}  ${FHS_RESET_MAX_WAIT_TIME}
    Wait Until Keyword Succeeds  ${remained_MAX_WAIT_TIME} sec  10 sec  Admin Check FHS state  ${NR_FHS_id}  ${Enabled_}  ${Online_}  ${Unlocked_}
    ...  Master
    ${remained_MAX_WAIT_TIME}=  Get elapsed time  ${time_initial}  ${FHS_RESET_MAX_WAIT_TIME}
    Wait Until Keyword Succeeds  ${remained_MAX_WAIT_TIME} sec  10 sec  Admin Check FHS state  ${SBTS_FHS_id}  ${Enabled_}  ${Online_}
    ...  ${Unlocked_}  Slave
    Log  NR and SBTS shared FHS with SN ${FHS_SN} status as expected  console=True

    ${remained_MAX_WAIT_TIME}=  Get elapsed time  ${time_initial}  ${FHS_RESET_MAX_WAIT_TIME}
    Check BTS Item State  NR  RMOD  ${Master_shared_RMOD_list}  ${RMOD_state_enabled_check}  ${RMOD_state_enabled}  ${remained_MAX_WAIT_TIME}
    ...  Master
    Log  All NR RMOD(s) status as expected  console=True
    ${remained_MAX_WAIT_TIME}=  Get elapsed time  ${time_initial}  ${FHS_RESET_MAX_WAIT_TIME}
    Admin Check all BTS cells expected states  expected_state=${CELL_state_enabled_check}  alias=Master  timeout=${remained_MAX_WAIT_TIME}
    Log  All NR cell(s) status:\n - ${CELL_state_enabled}  console=True

    ${remained_MAX_WAIT_TIME}=  Get elapsed time  ${time_initial}  ${FHS_RESET_MAX_WAIT_TIME}
    Check BTS Item State  SBTS  RMOD  ${Slave_shared_RMOD_list}  ${RMOD_state_enabled_check}  ${RMOD_state_enabled}  ${remained_MAX_WAIT_TIME}
    ...  Slave
    Log  All SBTS RMOD(s) status as expected  console=True
    ${remained_MAX_WAIT_TIME}=  Get elapsed time  ${time_initial}  ${FHS_RESET_MAX_WAIT_TIME}
    Admin Check all BTS cells expected states  expected_state=${CELL_state_enabled_check}  alias=Slave  timeout=${remained_MAX_WAIT_TIME}
    Log  All SBTS cell(s) status:\n - ${CELL_state_enabled}  console=True

    Log  Check NR and SBTS alarms after shared FHS with SN ${FHS_SN}:  console=True
    Get and Check Alarms SOAM  alias=Master  expected_alarms=@{EMPTY}  ignored_alarms=${MASTER_IGNORED_ALARMS}
    ...  critical_alarms=${MASTER_CRITICAL_ALARMS}
    Log  NR site - expected, ignored and critical alarms checked  console=True
    Get and Check Alarms SOAM  alias=Slave  expected_alarms=@{EMPTY}  ignored_alarms=${MASTER_IGNORED_ALARMS}
    ...  critical_alarms=${MASTER_CRITICAL_ALARMS}
    Log  SBTS site - expected, ignored and critical alarms checked  console=True

    [Teardown]  Teardown Admin  alias=${new_alias}

Check BTS Item State
    [Arguments]   ${tech}  ${BTS_item_class}  ${BTS_item_list}  ${BTS_item_state_check}  ${BTS_item_state}  ${timeout}  ${alias}
    FOR  ${item}  IN  @{BTS_item_list}
        Assert  class_name=${BTS_item_class}  id=${item}  parameters=${BTS_item_state_check}  timeout=${timeout}  connection=${alias}
        Log  ${tech} ${BTS_item_class} ${item} status:\n - ${BTS_item_state}  console=True
    END

Get and check KPI53a info from IMS file
    [Documentation]
    ...  Get and check KPI53a info from IMS file.

    [Arguments]  ${FHS_SN}  ${FHS_id}  ${alias}  ${CYCLE}

    Log  Get and check BTS ${alias} KPI53a info related to shared RM with SN ${FHS_SN} for iteration ${CYCLE}  console=True

    ${FHS_PN}=  Get FHS product name  ${FHS_id}  ${alias}

    ${kpi_name_delta_dict_kpi53a}=  Get and check KPI info from IMS file
    ...  kpi_names=kpi53a  kpi_thresholds=${FHS_RESET_WRN_THR}  alias=${alias}  start_point_timestamp_UTC=${date_timestamp_start_resetFHS_UTC}
    ...  end_point_timestamp_UTC=${date_timestamp_end_resetFHS_UTC}
    ${kpi_delta_list_kpi53a}=  Get From Dictionary  ${kpi_name_delta_dict_kpi53a}  kpi53a

    Export KPI Results to File  alias=${alias}  obj=FHS  obj_type=${FHS_PN}_${FHS_SN}  obj_id=${FHS_id}
    ...  action_1=FHS_Reset  kpi_reported_1=KPI_53a  event_value_1=${kpi_delta_list_kpi53a[0]}  cycle=${CYCLE}  source_info=ims

Get FHS product name
    [Arguments]  ${FHS_id}  ${alias}
    ${FHS_info_list}=  Get Fhs List  connection=${alias}
    ${module_ID_PN_dict}=  Create Dictionary
    FOR  ${item}  IN  @{FHS_info_list}
       Set To Dictionary  ${module_ID_PN_dict}  ${item['id']['internal']}  ${item['productName']}
    END
    ${FHS_ProdName}=  Get From Dictionary  ${module_ID_PN_dict}  ${FHS_id}
    [Return]  ${FHS_ProdName}

Particular Teardown
    Export KPI results to File Global  kpi_log_file_name=KpiTimeInfo

TC Setup
    ${tech_preset_list}=  Create List  SBTS  SBTS
    Common Test Setup  preset_techs=${tech_preset_list}  common_sbts=${TRUE}  infomodelSetup=${FALSE}

TC Teardown
    Common Test Teardown