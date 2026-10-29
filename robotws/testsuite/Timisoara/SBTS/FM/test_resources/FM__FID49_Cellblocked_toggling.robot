*** Settings ***
Documentation
    ...  This test case provides the SBTS functional verification for Fault 49 (Cell blocked) toggling,
    ...  in scope of CNI-119576 - Alarm toggling enhancement.

Resource  ../../common_resources/ca_FM_general.robot


*** Variables ***
${AL_TOGG_CONDITION_TIME}  3600  # [in seconds] Duration time when the alarm is toggling.
${AL_TOGG_CLEARENCE_TIME}  3600  # [in seconds] Duration time when the toggling alarm is no longer toggling.
${AL_TOGG_AMOUNT}  2  # Toggling alarm amount for declared toggling alarm.
${ALARM_TIMEOUT}  300  # [in seconds] Timeout for alarm to appear in WebEM
${NETACT_TIMEOUT}  120  # [in seconds] Timeout for alarm to appear in Netact
${BLOCK_TIMEOUT}  300  # [in seconds] Timeout for cell blocking


*** Keywords ***
TC__FM__FID49_Cellblocked_toggling
    [Documentation]
    ...  [CASE LINK]: https://jiradc.ext.net.nokia.com/browse/TAT-27755
    ...
    ...  ******************
    ...  History of changes
    ...  ******************
    ...  25.07.2024 - https://jiradc.ext.net.nokia.com/browse/TAT-27755 - Initial TAT creation
    ...  19.08.2024 - https://jiradc.ext.net.nokia.com/browse/TAT-27952 - Test fails at checking netact object when alarm is raised
    ...  22.08.2024 - https://jiradc.ext.net.nokia.com/browse/TAT-27972 - Test fails at checking netact fault name
    ...  31.10.2024 - https://jiradc.ext.net.nokia.com/browse/TAT-28025 - Enhancement for verifying additonalFaultID in NetAct
    ...  12.12.2024 - https://jiradc.ext.net.nokia.com/browse/TAT-28511 - Check fault on WCDMA/GSM cell under RNC/BSC object in Netact
    ...  20.02.2025 - https://jiradc.ext.net.nokia.com/browse/TAT-28708 - Test fails at checking IoT cell state
    ...  24.02.2025 - https://jiradc.ext.net.nokia.com/browse/TAT-28760 - Keywords moved to resource file
    ...  10.03.2025 - https://jiradc.ext.net.nokia.com/browse/TAT-28875 - Mandatory logs not collected when test fails
    ...  23.04.2025 - https://jiradc.ext.net.nokia.com/browse/TAT-29106 - Cell id in dist_name set wrong
    ...  ******************

    Set Tags  CA-FM  OWNER-virgil.blot@nokia.com  AUTHOR-laura.craciunel@nokia.com  MAINTAINER-laura.craciunel@nokia.com  GROUP_IN_CHARGE-TIM_4_Vrf
    ...  PHASE-CRT  SW-SBTS24  CNI-119576

    Step0: Set Test Preconditions
    Step1: Commission Toggling Alarm List
    Step2: Block Cells
    Step3: Stop Alarm Toggling
    Step4: Unblock Cells
    Step5: Remove Fault From Toggling Alarm List


Step0: Set Test Preconditions
    Log  Step0: Set test preconditions.  console=true
    Set ALTOGGSUPP Path
    Run Keyword And Ignore Error
    ...  Delete ALTOGGSUPP Object
    ${FAULT_4026_OTHER_FAULT_NAME}  Copy Dictionary  ${FAULT_4026_ALARM_7102}
    Remove From Dictionary  ${FAULT_4026_OTHER_FAULT_NAME}  fault_name
    Set To Dictionary  ${FAULT_4026_OTHER_FAULT_NAME}  fault_name=Toggling: Cell blocked
    Set Test Variable  ${FAULT_4026_OTHER_FAULT_NAME}
    ${rnc_infomodel}  Query Infomodel  get object //RAT-*/WTS-*/RNC-*
    ${wbts_infomodel}  Query Infomodel  get object //RAT-*/WTS-*/RNC-*/WBTS-*
    ${bsc_infomodel}  Query Infomodel  get object //RAT-*/GTS-*/BSC-*
    ${bcf_infomodel}  Query Infomodel  get object //RAT-*/GTS-*/BSC-*/BCF-*
    ${rnc_id}  Fetch From Right  ${rnc_infomodel}[dist_name]  RNC-
    ${wbts_id}  Fetch From Right  ${wbts_infomodel}[dist_name]  WBTS-
    ${bsc_id}  Fetch From Right  ${bsc_infomodel}[dist_name]  BSC-
    ${bcf_id}  Fetch From Right  ${bcf_infomodel}[dist_name]  BCF-
    Set Test Variable  ${RNC_ID}
    Set Test Variable  ${WBTS_ID}
    Set Test Variable  ${BSC_ID}
    Set Test Variable  ${BCF_ID}


Step1: Commission Toggling Alarm List
    Log  Step1: Commission toggling alarm list.  console=true
    Create Or Update ALTOGGSUPP Object  create  al_togg_amount=${AL_TOGG_AMOUNT}  al_togg_clearence_time=${AL_TOGG_CLEARENCE_TIME}
    ...  al_togg_conditon_time=${AL_TOGG_CONDITION_TIME}  fault_id=${FAULT_49}[fault_id]  in_use=true
    Check All Cells


Step2: Block Cells
    Log  Step2: Block cells.  console=true
    Block Cell On NR
    Block Cell On LTE
    Block Cell On WCDMA
    Block Cell On GSM


Step3: Stop Alarm Toggling
    Log  Step3: Stop alarm toggling.  console=true
    Disable Alarm Toggling
    Check Alarm Status In WebEM  inactive  ${FAULT_4026_ALARM_7102}[fault_id]  ${FAULT_4026_ALARM_7102}[fault_name]
    ...  ${FAULT_4026_ALARM_7102}[alarm_id]  ${FAULT_4026_ALARM_7102}[alarm_name]  ${FAULT_4026_ALARM_7102}[severity]
    Sleep  ${NETACT_TIMEOUT}s  Wait for alarm update in Netact.
    ${toggling_status_netact}  Run Keyword And Return Status  Check Additional Information For Given Alarm And Fault  &{FAULT_4026_OTHER_FAULT_NAME}
    ...  additional_fault_id=${FAULT_49}[fault_id]
    IF  ${toggling_status_netact}
      Fail  Fault ${FAULT_4026_OTHER_FAULT_NAME} is still active in NetAct. [NOK]
    ELSE
      Log  Fault ${FAULT_4026_OTHER_FAULT_NAME} is inactive in NetAct. [OK]  console=true
    END


Step4: Unblock Cells
    Log  Step4: Unblock cells.  console=true
    Unblock Cell On NR
    Unblock Cell On LTE
    Unblock Cell On WCDMA
    Unblock Cell On GSM


Step5: Remove Fault From Toggling Alarm List
    Log  Step5: Remove fault from toggling alarm list.  console=true
    Delete ALTOGGSUPP Object
    Check All Cells


Block Cell On ${rat}
    Log  \nChecking if ${rat} cells are commissioned.  console=true
    IF  '${SCF_COUNT_${rat}}'=='0'
      Log  ${rat} cells are not commissioned. Test will check another rat.  console=true
      Return From Keyword
    ELSE
      Log  ${rat} cells are commissioned. One cell will be randomly selected.  console=true
    END

    ${cell}  Select One Cell Randomly  ${rat}
    ${configuration_dist_name}  Set Variable  ${cell}[id][configuration]
    ${internal_dist_name}  Set Variable  ${cell}[id][internal]
    Log  Selected cell: ${internal_dist_name}.  console=true

    ${string_module_id}  Replace String Using Regexp  ${internal_dist_name}  .+/MRBTS_R-\\d+  MRBTS-${BTS_ID}
    ${without_runtime}  Remove String  ${string_module_id}  _R
    ${module_id_NR_LTE}  Catenate  SEPARATOR=/  PLMN-PLMN  ${without_runtime}
    ${module_id}  Set variable if
    ...  '${rat}'=='NR' or '${rat}'=='LTE'  ${module_id_NR_LTE}
    ...  '${rat}'=='WCDMA'  PLMN-PLMN/RNC-${RNC_ID}/WBTS-${WBTS_ID}/WCEL-${cell}[cellId]
    ...  '${rat}'=='GSM'  PLMN-PLMN/BSC-${BSC_ID}/BCF-${BCF_ID}/BTS-${cell}[gsmSectorID]
    ${dist_name_netact}  Set variable if
    ...  '${rat}'=='NR' or '${rat}'=='LTE'  ${MRBTS_DN}
    ...  '${rat}'=='WCDMA'  PLMN-PLMN/RNC-${RNC_ID}/WBTS-${WBTS_ID}/WCEL-${cell}[cellId]
    ...  '${rat}'=='GSM'  PLMN-PLMN/BSC-${BSC_ID}/BCF-${BCF_ID}/BTS-${cell}[gsmSectorID]
    ${number_of_loops}  Evaluate  ${AL_TOGG_AMOUNT}-1
    ${lowercase_rat}  Convert To Lower Case  ${rat}
    ${all_rat_cells}  Get Cells Info  cell_type=${lowercase_rat}  timeout=60
    ${dist_name_cells}  Get Dist_name Of Cells  ${all_rat_cells}
    ${not_impacted_cells}  Copy List  ${dist_name_cells}
    ${affected_cells}  Create List
    Append To List  ${affected_cells}  ${internal_dist_name}
    ${affected_cells}  Check If Affected Cells Have IoT Associated Cells And Add Them To List  ${affected_cells}
    Remove Values From List  ${not_impacted_cells}  @{affected_cells}

    FOR  ${loop}  IN RANGE  0  ${number_of_loops}
        Log  Cell will be blocked.  console=true
        Block Cell  dist_name=${internal_dist_name}  timeout=${BLOCK_TIMEOUT}
        ${string_block}  Get String With Alarm Parameters  ${FAULT_49}
        ${fault_block_params}  Catenate  SEPARATOR=,${SPACE}
        ...  ${string_block}  alarmingResource=regex"${internal_dist_name}|${configuration_dist_name}"
        ${block_status}  Run Keyword And Return Status
        ...  Assert Alarm Active  parameters=${fault_block_params}  timeout=${ALARM_TIMEOUT}

        IF  ${block_status}
          Log  Fault ${FAULT_49} is active in WebEM. [OK]  console=true
          Log  alarmingResource in WebEM alarm is field correctlly. [OK]  console=true
        ELSE
          Fail  Fault ${FAULT_49} is not active in WebEM. [NOK]
        END

        ${block_status_netact}  Run Keyword And Return Status
        ...  Wait Until Keyword Succeeds  ${NETACT_TIMEOUT}  30
        ...  Check Additional Information For Given Alarm And Fault  &{FAULT_49}  additional_fault_id=${FAULT_49}[fault_id]
        ...  dist_name=${dist_name_netact}  object_id=${module_id}
        IF  ${block_status_netact}
          Log  Fault ${FAULT_49} was reported in NetAct. [OK]  console=true
          Log  Alarm found in Netact under dn: ${module_id}.  console=true
        ELSE
          Fail  Fault ${FAULT_49} was not reported in NetAct. [NOK]
        END

        Check Parameters Status For Cells  ${not_impacted_cells}  operationalState=${ENABLED}, blockingState=${UNBLOCKED}

        Log  Cell will be unblocked.  console=true
        Unblock Cell  dist_name=${internal_dist_name}  timeout=${BLOCK_TIMEOUT}
        ${unblock_status}  Run Keyword And Return Status
        ...  Assert Alarm Inactive  parameters=${fault_block_params}  timeout=${ALARM_TIMEOUT}
        IF  ${unblock_status}
          Log  Fault ${FAULT_49} is inactive in WebEM. [OK]  console=true
        ELSE
          Fail  Fault ${FAULT_49} is active in WebEM. [NOK]
        END

        Sleep  ${NETACT_TIMEOUT}s  Wait for alarm update in Netact.
        ${unblock_status_netact}  Run Keyword And Return Status
        ...  Check Additional Information For Given Alarm And Fault  &{FAULT_49}  additional_fault_id=${FAULT_49}[fault_id]
        ...  dist_name=${dist_name_netact}  object_id=${module_id}
        IF  ${unblock_status_netact}
          Fail  Fault ${FAULT_49} is still active in NetAct. [NOK]
        ELSE
          Log  Fault ${FAULT_49} is inactive in NetAct. [OK]  console=true
        END

        Wait Until Keyword Succeeds  ${BLOCK_TIMEOUT}  10s
        ...  Check Parameters Status For Cells  ${dist_name_cells}  operationalState=${ENABLED}, blockingState=${UNBLOCKED}
    END

    Log  Cell will be blocked.  console=true
    Block Cell  dist_name=${internal_dist_name}  timeout=${BLOCK_TIMEOUT}
    ${string_toggling}  Get String With Alarm Parameters  ${FAULT_4026_ALARM_7102}
    ${fault_toggling_params}  Catenate  SEPARATOR=,  ${string_toggling}  alarmingResource=regex"${internal_dist_name}|${configuration_dist_name}"
    ${toggling_status}  Run Keyword And Return Status
    ...  Assert Alarm Active  parameters=${fault_toggling_params}  timeout=${ALARM_TIMEOUT}
    IF  ${toggling_status}
      Log  Fault ${FAULT_4026_ALARM_7102} is active in WebEM. [OK]  console=true
      Log  alarmingResource in WebEM alarm is field correctlly. [OK]  console=true
    ELSE
      Fail  Fault ${FAULT_4026_ALARM_7102} is not active in WebEM. [NOK]
    END

    ${toggling_status_netact}  Run Keyword And Return Status
    ...  Wait Until Keyword Succeeds  ${NETACT_TIMEOUT}  30
    ...  Check Additional Information For Given Alarm And Fault  &{FAULT_4026_OTHER_FAULT_NAME}  additional_fault_id=${FAULT_49}[fault_id]
    ...  dist_name=${dist_name_netact}  object_id=${module_id}
    IF  ${toggling_status_netact}
      Log  Fault ${FAULT_4026_OTHER_FAULT_NAME} was reported in NetAct. [OK]  console=true
      Log  Alarm found in Netact under dn: ${module_id}.  console=true
      Log  additionalFaultID=49 in additionalText3.  console=true
    ELSE
      Fail  Fault ${FAULT_4026_OTHER_FAULT_NAME} was not reported in NetAct. [NOK]
    END

    Wait Until Keyword Succeeds  ${BLOCK_TIMEOUT}  10s
    ...  Check Parameters Status For Cells  ${not_impacted_cells}  operationalState=${ENABLED}, blockingState=${UNBLOCKED}


Select One Cell Randomly
    [Arguments]  ${rat}

    ${lowercase_rat}  Convert To Lower Case  ${rat}
    ${cells}  Get Cells Info  cell_type=${lowercase_rat}  timeout=60
    ${candidate_for_block_cell}  IF  '${rat}'=='LTE'  Remove IoT cells and select cell  ${cells}  ELSE  Evaluate  random.choice(${cells})  random

    [Return]  ${candidate_for_block_cell}


Remove IoT cells and select cell
    [Documentation]  Narrow band IoT cells can't be blocked , only hosting cell can be blocked.
    [Arguments]  ${cells}

    ${not_IoT_cells}  Create List
    FOR  ${cell}  IN  @{cells}
         IF  '${cell}[narrowbandIotMode]'=='disabled'  Append To List  ${not_IoT_cells}  ${cell}
    END
    ${candidate_for_block_cell}  Evaluate  random.choice(${not_IoT_cells})  random

   [Return]  ${candidate_for_block_cell}


Unblock Cell On ${rat}
    Log  \nChecking if ${rat} cells are commissioned.  console=true
    IF  '${SCF_COUNT_${rat}}'=='0'
      Log  ${rat} cells are not commissioned. Test will check another rat.  console=true
      Return From Keyword
    ELSE
      Log  ${rat} cells are commissioned. Blocked cell will be unblocked.  console=true
    END

    ${lowercase_rat}  Convert To Lower Case  ${rat}
    ${all_rat_cells}  Get Cells Info  cell_type=${lowercase_rat}  timeout=60
    ${blocked_cells}  Create List
    FOR  ${cell}  IN  @{all_rat_cells}
        Run Keyword If  '${cell}[status][blockingState]' == 'Blocked'
        ...  Append To List  ${blocked_cells}  ${cell}
    END
    Reverse List  ${blocked_cells}
    ${blocked_cell}  Set Variable  ${blocked_cells}[0]
    ${internal_dist_name}  Set Variable  ${blocked_cell}[id][internal]
    ${configuration_dist_name}  Set Variable  ${blocked_cell}[id][configuration]

    ${string_module_id}  Replace String Using Regexp  ${internal_dist_name}  .+/MRBTS_R-\\d+  MRBTS-${BTS_ID}
    ${without_runtime}  Remove String  ${string_module_id}  _R
    ${module_id_NR_LTE}  Catenate  SEPARATOR=/  PLMN-PLMN  ${without_runtime}
    ${module_id}  Set variable if
    ...  '${rat}'=='NR' or '${rat}'=='LTE'  ${module_id_NR_LTE}
    ...  '${rat}'=='WCDMA'  PLMN-PLMN/RNC-${RNC_ID}/WBTS-${WBTS_ID}/WCEL-${blocked_cell}[cellId]
    ...  '${rat}'=='GSM'  PLMN-PLMN/BSC-${BSC_ID}/BCF-${BCF_ID}/BTS-${blocked_cell}[gsmSectorID]
    ${dist_name_netact}  Set variable if
    ...  '${rat}'=='NR' or '${rat}'=='LTE'  ${MRBTS_DN}
    ...  '${rat}'=='WCDMA'  PLMN-PLMN/RNC-${RNC_ID}/WBTS-${WBTS_ID}/WCEL-${blocked_cell}[cellId]
    ...  '${rat}'=='GSM'  PLMN-PLMN/BSC-${BSC_ID}/BCF-${BCF_ID}/BTS-${blocked_cell}[gsmSectorID]

    ${all_rat_cells}  Get Cells Info  cell_type=${lowercase_rat}  timeout=60
    ${dist_name_cells}  Get Dist_name Of Cells  ${all_rat_cells}
    ${not_impacted_cells}  Copy List  ${dist_name_cells}
    ${affected_cells}  Create List
    Append To List  ${affected_cells}  ${internal_dist_name}
    ${affected_cells}  Check If Affected Cells Have IoT Associated Cells And Add Them To List  ${affected_cells}
    Remove Values From List  ${not_impacted_cells}  @{affected_cells}

    Log  Checking if fault is active on blocked cell.
    ${string_block}  Get String With Alarm Parameters  ${FAULT_49}
    ${fault_block_params}  Catenate  SEPARATOR=,${SPACE}  ${string_block}  alarmingResource=regex"${internal_dist_name}|${configuration_dist_name}"
    ${block_status}  Run Keyword And Return Status
    ...  Assert Alarm Active  parameters=${fault_block_params}  timeout=${ALARM_TIMEOUT}

    IF  ${block_status}
      Log  Fault ${FAULT_49} is active in WebEM. [OK]  console=true
      Log  alarmingResource in WebEM alarm is field correctlly. [OK]  console=true
    ELSE
      Fail  Fault ${FAULT_49}[fault_id] "${FAULT_49}[fault_name]" is not active in WebEM. [NOK]
    END

    ${block_status_netact}  Run Keyword And Return Status
    ...  Wait Until Keyword Succeeds  ${NETACT_TIMEOUT}  30
    ...  Check Additional Information For Given Alarm And Fault  &{FAULT_49}  additional_fault_id=${FAULT_49}[fault_id]
    ...  dist_name=${dist_name_netact}  object_id=${module_id}
    IF  ${block_status_netact}
      Log  Fault ${FAULT_49} was reported in NetAct. [OK]  console=true
      Log  Alarm found in Netact under dn: ${module_id}.  console=true
    ELSE
      Fail  Fault ${FAULT_49} was not reported in NetAct. [NOK]
    END

    Check Parameters Status For Cells  ${not_impacted_cells}  operationalState=${ENABLED}, blockingState=${UNBLOCKED}

    Log  Cell will be unblocked.  console=true
    Unblock Cell  dist_name=${internal_dist_name}  timeout=${BLOCK_TIMEOUT}
    ${string_block}  Get String With Alarm Parameters  ${FAULT_49}
    ${fault_block_params}  Catenate  SEPARATOR=,${SPACE}  ${string_block}  alarmingResource=regex"${internal_dist_name}|${configuration_dist_name}"
    ${unblock_status}  Run Keyword And Return Status
    ...  Assert Alarm Inactive  parameters=${fault_block_params}  timeout=${ALARM_TIMEOUT}
    IF  ${unblock_status}
      Log  Fault ${FAULT_49} is inactive in WebEM. [OK]  console=true
    ELSE
      Fail  Fault ${FAULT_49} is active in WebEM. [NOK]
    END

    Sleep  ${NETACT_TIMEOUT}s  Wait for alarm update in Netact.
    ${unblock_status_netact}  Run Keyword And Return Status
    ...  Check Additional Information For Given Alarm And Fault  &{FAULT_49}  additional_fault_id=${FAULT_49}[fault_id]
    ...  dist_name=${dist_name_netact}  object_id=${module_id}
    IF  ${unblock_status_netact}
      Fail  Fault ${FAULT_49} is still active in NetAct. [OK]
    ELSE
      Log  Fault ${FAULT_49} is inactive in NetAct. [NOK]  console=true
    END

    Wait Until Keyword Succeeds  ${BLOCK_TIMEOUT}  10s
    ...  Check Parameters Status For Cells  ${dist_name_cells}  operationalState=${ENABLED}, blockingState=${UNBLOCKED}


Get Dist_name Of Cells
    [Arguments]  ${cells_list}

    ${dist_name_cells}  Create List
    FOR  ${cell}  IN  @{cells_list}
        Append To List  ${dist_name_cells}  ${cell}[id][internal]
    END

    [Return]  ${dist_name_cells}


Unblock All Cells
    Log  Unblock All Cells.  console=true
    ${blocked_cells}  Create List
    ${nr_cells}  Get Cells Info  timeout=60
    ${lte_cells}  Get Cells Info  cell_type=lte  timeout=60
    ${wcdma_cells}  Get Cells Info  cell_type=wcdma  timeout=60
    ${gsm_cells}  Get Cells Info  cell_type=gsm  timeout=60
    ${all_cells}  Combine Lists  ${nr_cells}  ${lte_cells}  ${wcdma_cells}  ${gsm_cells}
    FOR  ${cell}  IN  @{all_cells}
        IF  '${cell}[status][blockingState]'=='Blocked'  Append To List  ${blocked_cells}  ${cell}
    END
    FOR  ${blocked_cell}  IN  @{blocked_cells}
        Unblock Cell  dist_name=${blocked_cell}[id][internal]  timeout=${BLOCK_TIMEOUT}
    END
    Wait Until Keyword Succeeds  ${BLOCK_TIMEOUT}  10s   Check All Cells


Delete Object And Unblock Cells
    Run Keyword And Ignore Error
    ...  Delete ALTOGGSUPP Object
    Run Keyword And Ignore Error
    ...  Unblock All Cells


TC Setup
    Common Test Setup  tc_name=FM__FID49_Cellblocked_toggling
    Setup NetAct


TC Teardown
    Run Keyword And Ignore Error
    ...  Delete Object And Unblock Cells
    Teardown NetAct
    Common Test Teardown