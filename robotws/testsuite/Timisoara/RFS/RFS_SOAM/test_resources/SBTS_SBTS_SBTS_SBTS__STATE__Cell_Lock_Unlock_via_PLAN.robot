*** Settings ***
Documentation    TC__SBTS_SBTS_SBTS_SBTS__STATE__Cell_Lock_Unlock_via_PLAN
Variables    tc_variables/sbts_sbts_sbts_sbts__state__cell_lock_unlock_via_plan_alarms_definitions.py
Resource    ../../resources/rfs_frame_rfs_soam_taf.robot

*** Variables ***
${REPEAT_COUNTER}              3     # Number of BTS Cell Lock/Unlock operations, default value 3
${BTS_LIST}                    ALL   # BTS list on which Cell Lock/Unlock operation will be performed. Possible values (by default ALL):
                                     # - ALL: action will be performed on all BTS (lock/Unlock cells on each BTS until last BTS from TL)
                                     # - list of selected BTS separated by comma labeled as BTSx (x is test_pc number in init.py) (ex. BTS1, BTS3)
${RAT_LIST}                    ALL   # RAT list on which Cell Lock/Unlock operation will be performed. Possible values (by default ALL):
                                     # - ALL: action will be performed on all RATs (lock/Unlock cells on all configured BTS RATs)
                                     # - list of selected RATs separated by comma, possible values: NR, LTE(ex. NR, LTE)
${LTE_IOT_SA_action}           True  # Only if RAT LTE is requested. Specify in case of configured LTE IOT SA cells if Lock/Unlock operations
                                     # should be performed on them; possible values True or False, default value: True
${LTE_IOT_check}               True  # Only if RAT LTE is requested. Specify in case of configured LTE IOT cells if their status will be checked
                                     # (True) or skipped (False) after Lock host LTE cell. By default True
${NR_CELL_LOCK_WRN_THR}       30     # Compared with the time spent from cell block command sent to cell down.
                                     # If exceeds NR_CELL_LOCK_WRN_THR, test verdict will be failed and snapshot collected.
                                     # Default value: in accordance with kpi16a specifications
${NR_CELL_UNLOCK_WRN_THR}     30     # Compared with the time spent from cell unblock command sent to cell up.
                                     # If exceeds NR_CELL_UNLOCK_WRN_THR, test verdict will be failed and snapshot collected.
                                     # Default value: in accordance with kpi16b specifications
${LTE_CELL_LOCK_WRN_THR}      30    # Compared with the time spent from cell block command sent to cell down.
                                     # If exceeds LTE_CELL_LOCK_WRN_THR, test verdict will be failed and snapshot collected.
                                     # Default value: in accordance with kpi16a specifications
${LTE_CELL_UNLOCK_WRN_THR}    30    # Compared with the time spent from cell unblock command sent to cell up.
                                     # If exceeds LTE_CELL_UNLOCK_WRN_THR, test verdict will be failed and snapshot collected.
                                     # Default value: in accordance with kpi16b specifications
${CELL_LOCK_MAX_WAIT_TIME}    200   # Maximum waiting time for cell to be Locked; default value 200 seconds
${CELL_UNLOCK_MAX_WAIT_TIME}  200   # Maximum waiting time for cell to be unlocked; default value 200 seconds


*** Keywords ***
TC__SBTS_SBTS_SBTS_SBTS__STATE__Cell_Lock_Unlock_via_PLAN
     [Documentation]
    ...  [CASE LINK]: https://jiradc.ext.net.nokia.com/browse/TAT-29967
    ...
    ...  *****************
    ...  Basic information
    ...  *****************
    ...  SBTS-SBTS-SBTS-SBTS test case for Cell Lock/Unlock on BTS, - x times sequence.
    ...  x - value of REPEAT_COUNTER parameter (default: 3)
    ...  The main steps performed for the test are:
    ...  - check initial state and alarms for all BTS
    ...  - get all BTS info
    ...  - perform Lock/Unlock cells on BTS checking state and alarms;
    ...    - if ${BTS_LIST} == ALL, cell Lock/unlock operations will be performed on all BTS
    ...    - if ${BTS_LIST} != ALL, cell Lock/unlock operations will be performed on requested BTS
    ...    - if ${RAT_LIST} == ALL, cell Lock/unlock operations will be performed on all configured RATs
    ...    - if ${RAT_LIST} != ALL, cell Lock/unlock operations will be performed on requested configured RATs
    ...    - if ${LTE_IOT_SA_action} == True and LTE is in ${RAT_LIST}, LTE SA IOT cell Lock/unlock operations will be performed
    ...    - if ${LTE_IOT_check} == True and LTE is in ${RAT_LIST}, LTE IOT cell check status will be performed after Lock LTE HOST cell operation
    ...  - check final state and alarms for for all BTS
    ...  Pass criteria: Cell Lock/Unlock operation works as expected; states and alarms are as expected
    ...
    ...  ******************
    ...  History of changes
    ...  ******************
    ...  - 27.10.2025 - https://jiradc.ext.net.nokia.com/browse/TAT-29967 - New TC
    ...  SBTS_SBTS_SBTS_SBTS__STATE__Cell_lock_Unlock_via_parameter_commissioning -
    ...  FCA_VRF_SISO-29409/CNI-147674/EDA for 04757534
    ...

    Set Tags    CA-STATE    OWNER-constantin.diaconu@nokia.com   AUTHOR-valentin.marian@nokia.com    PHASE-QT    SW-SBTS26R2

    TC Preconditions
    Step 1: Check initial all BTS state
    Step 2: Check initial all BTS alarms
    Step 3: Get all BTS info
    FOR  ${INDEX}  IN RANGE  1  ${REPEAT_COUNTER}+1
        Log  ==============================================================================  console=True
        Log  Start Cycle ${INDEX} of ${REPEAT_COUNTER}  console=True
        Log  ==============================================================================  console=True
        Step 4: Perform Cell Lock/Unlock on BTS for iteration ${INDEX}
        Step 5: Check final all BTS state
        Step 6: Check final all BTS alarms
        Step 7: Check final number and state of Cells and RMs
    END

    [Teardown]  Particular Teardown

TC Preconditions
    ${BTS_alias_label_dict}  ${BTS_label_alias_dict}=  Get BTS alias label info dict
    ${BTS_alias_list}=  Get Dictionary Keys  ${BTS_alias_label_dict}  False
    ${BTS_label_list}=  Get Dictionary Values  ${BTS_alias_label_dict}  False
    Set Test Variable  ${BTS_alias_list}
    Set Test Variable  ${BTS_label_list}

    Run Keyword If  '${BTS_LIST}' != 'ALL'  Check BTS list  ${BTS_label_alias_dict}  ${BTS_label_list}
    Log  =========================================================  console=True
    Log  BTS label list selected for Lock/Unlock Cell operation: ${BTS_label_list}  console=True
    Log  BTS alias list selected for Lock/Unlock Cell operation: ${BTS_alias_list}  console=True
    Log  =========================================================  console=True

    Check RAT list

Step ${index}: Check ${when} all BTS state
    [Documentation]
    ...  SBTS state is checked according to Admin for BTS and each configured RAT

    Log  Step ${index}: Check ${when} all BTS state  console=True

    FOR  ${alias}  IN  @{alias_list}

        Log  ***** Check ${when} BTS ${alias} state *****  console=True

        Admin Check BTS RAT Procedural State  alias=${alias}  timeout=600

        Admin Check BTS Procedural and Blocking states  ${OnAir_}  ${Unblocked_}  alias=${alias}

        Log  BTS ${alias} site - proceduralState: OnAir, administrativeState: Unlocked  console=True

    END

Step ${index}: Check ${when} all BTS alarms
    [Documentation]
    ...  SBTS alarms are compared with values from expected, ignored and critical alarms lists. SBTS alarms are get
    ...  from Admin

    Log  Step ${index}: Check ${when} all BTS alarms  console=True

    FOR  ${alias}  IN  @{alias_list}

        Log  ***** Check ${when} BTS ${alias} alarms *****  console=True

        Get and Check Alarms SOAM  alias=${alias}  expected_alarms=@{EMPTY}  ignored_alarms=${${alias.upper()}_IGNORED_ALARMS}
        ...  critical_alarms=${${alias.upper()}_CRITICAL_ALARMS}

        Log  BTS ${alias} site - expected, ignored and critical alarms checked  console=True

    END

Step ${index}: Get all BTS info
    Log  Step ${index}: Get all BTS info  console=True

    FOR  ${alias}  IN  @{alias_list}

       Get BTS cells info  ${alias}

    END

    ${BTS_XP_localAlias_remoteAlias_dict}  ${NRBTS_DSS_alias_actLteNrDss_dict}  ${LNBTS_DSS_alias_actLteNrDss_dict}
    ...  ${BTS_DSS_NR_LTE_CELL_scf_dict}  ${BTS_DSS_LTE_NR_CELL_scf_dict}  ${BTS_DSS_NR_LTE_CELL_dict}  ${BTS_DSS_LTE_NR_CELL_dict}=
    ...  Get all BTS DSS feature info
    Set Test Variable  ${BTS_XP_localAlias_remoteAlias_dict}
    Set Test Variable  ${NRBTS_DSS_alias_actLteNrDss_dict}
    Set Test Variable  ${LNBTS_DSS_alias_actLteNrDss_dict}
    Set Test Variable  ${BTS_DSS_NR_LTE_CELL_dict}
    Set Test Variable  ${BTS_DSS_LTE_NR_CELL_dict}

    Set Test Variable  ${CELL_state_locked_check}  operationalState=${Disabled_}, availabilityStatus=${Offline_}, administrativeState=${Locked_}
    Set Test Variable  ${CELL_state_locked}  operationalState=Disabled, availabilityStatus=Offline, administrativeState=Locked
    Set Test Variable  ${CELL_state_unlocked_check}  operationalState=${Enabled_}, administrativeState=${Unlocked_}
    Set Test Variable  ${CELL_state_unlocked}  operationalState=Enabled, administrativeState=Unlocked

    Set Test Variable  ${NR_DSS_alarms_info}  "EN DSS De-activated on partner side (7513)" alarm
    Set Test Variable  ${LTE_DSS_alarms_info}  "EN DSS De-activated on partner side (6134)" alarm

Step ${index}: Perform Cell Lock/Unlock on BTS for iteration ${CYCLE}
    Log  Step ${index}: Perform Cell Lock/Unlock on BTS  console=True

    FOR  ${alias}  IN  @{BTS_alias_list}

        Perform Lock Unlock BTS cells  ${alias}  ${CYCLE}

    END

Step ${index}: Check final number and state of Cells and RMs
    [Documentation]
    ...  Following checks are performed:
    ...  - number of configured cells and radio modules in SCF are properly mapped on BTS running view ADMIN
    ...  - check cells states
    ...  - check radio modules states

    Log  Step ${index}: Check final number and state of Cells and RMs  console=True
    RFS Test Case Final Checks

Check BTS list
    [Arguments]  ${BTS_label_alias_dict}  ${BTS_label_list}

    ${BTS_LIST_strip}=  Replace String  ${BTS_LIST}  ${SPACE}  ${EMPTY}
    ${BTS_LIST}=  Split String  ${BTS_LIST_strip}  ,
    ${BTS_check}=  Set Variable  True
    ${BTS_invalid_label_list}=  Create List
    ${BTS_request_label_list}=  Create List
    ${BTS_request_alias_list}=  Create List

    FOR  ${item}  IN  @{BTS_LIST}

        ${BTS_check}=  Set Variable If  '${item}' not in ${BTS_label_list}  False  ${BTS_check}

        Run Keyword If  '${item}' not in ${BTS_label_list}
        ...  Append To List  ${BTS_invalid_label_list}  ${item}
        ...  ELSE
        ...  Append To List  ${BTS_request_label_list}  ${item}

    END

    Run Keyword If  '${BTS_check}' == 'False'  Run Keywords
    ...  Log Long String  Following selected BTS are not valid: ${BTS_invalid_label_list}. Please select values for test argument \${BTS_LIST} from
    ...  configured BTS: ${BTS_label_list} or let default value: ALL  console=True
    ...  AND  Fail  Improper value for argument!

    FOR  ${item}  IN  @{BTS_request_label_list}

        ${BTS_request_alias}=  Get From Dictionary  ${BTS_label_alias_dict}  ${item}
        Append To List  ${BTS_request_alias_list}  ${BTS_request_alias}

    END

    Set Test Variable  ${BTS_label_list}  ${BTS_request_label_list}
    Set Test Variable  ${BTS_alias_list}  ${BTS_request_alias_list}

Check RAT list
    Get all BTS RAT info

    Return From Keyword If  '${RAT_LIST}' == 'ALL'

    ${RAT_LIST_strip}=  Replace String  ${RAT_LIST}  ${SPACE}  ${EMPTY}
    ${RAT_request_list}=  Split String  ${RAT_LIST_strip}  ,
    Set Test Variable  ${RAT_request_list}

    ${RAT_check}=  Set Variable  True

    FOR  ${alias}  IN  @{BTS_alias_list}

        ${BTS_RAT_check}=  Check BTS RAT list  ${alias}

    END

Get all BTS RAT info
    FOR  ${alias}  IN  @{BTS_alias_list}

        ${BTS_RAT_list}=  Get BTS RAT info  ${alias}

        Set Test Variable  ${${alias}_BTS_RAT_list}  ${BTS_RAT_list}

    END

Get BTS RAT info
    [Arguments]  ${alias}

    ${BTS_RAT_list}=  Create List

    ${NR_CELL_id_list}=  Get Ids For All  class_name=NRCEL  connection=${alias}
    Run Keyword If  ${NR_CELL_id_list}  Append To List  ${BTS_RAT_list}  NR

    ${LTE_CELL_id_list}=  Get Ids For All  class_name=LNCEL  connection=${alias}
    Run Keyword If  ${LTE_CELL_id_list}  Append To List  ${BTS_RAT_list}  LTE

    [Return]  ${BTS_RAT_list}

Check BTS RAT list
    [Arguments]  ${alias}

    ${BTS_RAT_check}=  Set Variable  True
    ${BTS_RAT_invalid_list}=  Create List
    ${BTS_RAT_request_list}=  Create List

    FOR  ${rat}  IN  @{RAT_request_list}

        ${BTS_RAT_check}=  Set Variable If  '${rat}' not in ${${alias}_BTS_RAT_list}  False  ${BTS_RAT_check}

        Run Keyword If  '${rat}' not in ${${alias}_BTS_RAT_list}
        ...  Append To List  ${BTS_RAT_invalid_list}  ${rat}
        ...  ELSE
        ...  Append To List  ${BTS_RAT_request_list}  ${rat}

    END

    Run Keyword If  '${BTS_RAT_check}' == 'False'  Run Keywords
    ...  Log Long String  Following selected RATs for BTS ${alias} are not valid: ${BTS_RAT_invalid_list}. Please select values for test argument
    ...  \${RAT_LIST} from configured RATs: ${${alias}_BTS_RAT_list} or let default value: ALL  level=WARN
    ...  AND  Fail  Improper value for argument!

    Set Test Variable  ${${alias}_BTS_RAT_list}  ${BTS_RAT_request_list}

    [Return]  ${BTS_RAT_check}

Get BTS cells info
    [Arguments]  ${alias}
    ${NR_CELL_details}=  Get Cells Info  cell_type=nr  connection=${alias}
    ${NR_CELL_id_list}=  Get Ids For All  class_name=NRCEL  connection=${alias}
    Sort List  ${NR_CELL_id_list}
    Set Test Variable  ${${alias}_NR_CELL_id_list}  ${NR_CELL_id_list}
    Set Test Variable  ${${alias}_NR_CELL_details}  ${NR_CELL_details}

    ${LTE_CELL_details}=  Get Cells Info  cell_type=lte  connection=${alias}
    ${LTE_CELL_id_list}=  Get Ids For All  class_name=LNCEL  connection=${alias}
    ${LTE_HOST_CELL_id_list}  ${LTE_IOT_CELL_id_list}  ${LTE_IOT_SA_CELL__id_list}=  Admin Get LTE HOST and IOT Cell(s) Id list
    ...  CELL_list=${LTE_CELL_id_list}  alias=${alias}
    Sort List  ${LTE_HOST_CELL_id_list}
    Sort List  ${LTE_IOT_CELL_id_list}
    Sort List  ${LTE_IOT_SA_CELL_id_list}
    ${LTE_CELL_id_list}=  Run Keyword If  ${LTE_IOT_SA_action}
    ...  Combine Lists  ${LTE_HOST_CELL_id_list}  ${LTE_IOT_SA_CELL_id_list}
    ...  ELSE
    ...  Set Variable  ${LTE_HOST_CELL_id_list}
    Set Test Variable  ${${alias}_LTE_CELL_id_list}  ${LTE_CELL_id_list}
    Set Test Variable  ${${alias}_LTE_HOST_CELL_id_list}  ${LTE_HOST_CELL_id_list}
    Set Test Variable  ${${alias}_LTE_IOT_CELL_id_list}  ${LTE_IOT_CELL_id_list}
    Set Test Variable  ${${alias}_LTE_IOT_SA_CELL__id_list}  ${LTE_IOT_SA_CELL__id_list}
    Set Test Variable  ${${alias}_LTE_CELL_details}  ${LTE_CELL_details}

    ${LTE_cell_IOT_mapping_dict}=  Admin Get LTE CELL IOT mapping list  alias=${alias}
    Set Test Variable  ${${alias}_LTE_cell_IOT_mapping_dict}  ${LTE_cell_IOT_mapping_dict}

    ${WCDMA_CELL_id_list}=  Get Ids For All  class_name=WNCEL  connection=${alias}
    Sort List  ${WCDMA_CELL_id_list}
    Set Test Variable  ${${alias}_WCDMA_CELL_id_list}  ${WCDMA_CELL_id_list}

    ${GSM_CELL_id_list}=  Get Ids For All  class_name=GNCEL  connection=${alias}
    Sort List  ${GSM_CELL_id_list}
    Set Test Variable  ${${alias}_GSM_CELL_id_list}  ${GSM_CELL_id_list}

Perform Lock Unlock BTS cells
    [Arguments]  ${alias}  ${CYCLE}

    FOR  ${rat}  IN  @{${alias}_BTS_RAT_list}

        Log  ***** Perform ${rat} Cell Lock/Unlock on BTS ${alias} *****  console=True

        Lock Unlock BTS cells  ${rat}  ${alias}  ${CYCLE}

    END

Lock Unlock BTS cells
    [Arguments]  ${rat}  ${alias}  ${CYCLE}

    FOR  ${cell_id}  IN  @{${alias}_${rat}_CELL_id_list}

        Get Current Date UTC info  start

        ${DSS_peer_cell_id}  ${DSS_peer_rat}  ${DSS_peer_alias}=  Get DSS feature impact  ${cell_id}  ${rat}  ${alias}
        Set Test Variable  ${DSS_peer_cell_id}
        Set Test Variable  ${DSS_peer_rat}
        Set Test Variable  ${DSS_peer_alias}

        ${LTE_cell_IOT_id}  ${NR_cell_info_exempted}  ${LTE_cell_info_exempted}  ${WCDMA_cell_info_exempted}  ${GSM_cell_info_exempted}=
        ...  Get additional info  ${cell_id}  ${rat}  ${alias}
        Set Test Variable  ${LTE_cell_IOT_id}
        Set Test Variable  ${NR_cell_info_exempted}
        Set Test Variable  ${LTE_cell_info_exempted}
        Set Test Variable  ${WCDMA_cell_info_exempted}
        Set Test Variable  ${GSM_cell_info_exempted}

        Lock BTS cell  ${cell_id}  ${rat}  ${alias}

        Unlock BTS cell  ${cell_id}  ${rat}  ${alias}

        Get Current Date UTC info  end

        Get and check kpi16a and kpi16b info from IMS file  ${cell_id}  ${rat}  ${alias}  ${CYCLE}

    END

Get DSS feature impact
    [Arguments]  ${cell_id}  ${rat}  ${alias}

    Return From Keyword If  '${rat}' in ['WCDMA', 'GSM']  None  None  None

    ${DSS_peer_rat}=  Set Variable If  '${rat}' == 'NR'  LTE  NR

    ${actLteNrDss}=  Run Keyword If  '${rat}' == 'NR'
    ...  Get From Dictionary  ${NRBTS_DSS_alias_actLteNrDss_dict}  ${alias}
    ...  ELSE IF  '${rat}' == 'LTE'
    ...  Get From Dictionary  ${LNBTS_DSS_alias_actLteNrDss_dict}  ${alias}

    Return From Keyword If  '${actLteNrDss}' == 'False'  None  ${DSS_peer_rat}  None

    ${DSS_NR_LTE_CELL_dict}=  Get From Dictionary  ${BTS_DSS_NR_LTE_CELL_dict}  ${alias}
    ${DSS_LTE_NR_CELL_dict}=  Get From Dictionary  ${BTS_DSS_LTE_NR_CELL_dict}  ${alias}
    ${DSS_NR_LTE_dict_keys}=  Get Dictionary Keys  ${DSS_NR_LTE_CELL_dict}
    ${DSS_LTE_NR_dict_keys}=  Get Dictionary Keys  ${DSS_LTE_NR_CELL_dict}

    ${DSS_peer_cell_id}=  Run Keyword If  '${rat}' == 'NR' and '${cell_id}' in ${DSS_NR_LTE_dict_keys}
    ...  Get From Dictionary  ${DSS_NR_LTE_CELL_dict}  ${cell_id}
    ...  ELSE IF  '${rat}' == 'LTE' and '${cell_id}' in ${DSS_LTE_NR_dict_keys}
    ...  Get From Dictionary  ${DSS_LTE_NR_CELL_dict}  ${cell_id}
    ...  ELSE
    ...  Set Variable  None

    Return From Keyword If  '${DSS_peer_cell_id}' == 'None'  None  ${DSS_peer_rat}  None

    ${DSS_peer_alias_list}=  Get From Dictionary  ${BTS_XP_localAlias_remoteAlias_dict}  ${alias}
    ${DSS_peer_alias}=  Get DSS peer BTS  ${DSS_peer_cell_id}  ${DSS_peer_rat}  ${DSS_peer_alias_list}

    [Return]  ${DSS_peer_cell_id}  ${DSS_peer_rat}  ${DSS_peer_alias}

Get DSS peer BTS
    [Arguments]  ${DSS_peer_cell_id}  ${DSS_peer_rat}  ${DSS_peer_alias_list}

    ${DSS_peer_alias}=  Set Variable  None

    FOR  ${alias}  IN  @{DSS_peer_alias_list}

        ${DSS_peer_alias}=  Set Variable If  '${DSS_peer_cell_id}' in ${${alias}_${DSS_peer_rat}_CELL_id_list}  ${alias}
        Exit For Loop If  '${DSS_peer_alias}' != 'None'

    END

    [Return]  ${DSS_peer_alias}

Get additional info
    [Arguments]  ${cell_id}  ${rat}  ${alias}

    ${NR_cell_info_exempted}=  Create Dictionary
    ${LTE_cell_info_exempted}=  Create Dictionary
    ${WCDMA_cell_info_exempted}=  Create Dictionary
    ${GSM_cell_info_exempted}=  Create Dictionary

    ${LTE_cell_IOT_id}=  Run Keyword If  '${rat}' == 'LTE' and '${cell_id}' in ${${alias}_LTE_HOST_CELL_id_list}
    ...  Get From Dictionary  ${${alias}_LTE_cell_IOT_mapping_dict}  ${cell_id}
    ...  ELSE
    ...  Set Variable  None

    ${BTS_CELL_id_list_exempted}=  Run Keyword If  '${rat}' == 'LTE' and '${LTE_cell_IOT_id}' != 'None'
    ...  Create List  ${cell_id}  ${LTE_cell_IOT_id}
    ...  ELSE
    ...  Create List  ${cell_id}

    Run Keyword If  '${rat}' == 'NR'  Set To Dictionary  ${NR_cell_info_exempted}  ${alias}  ${BTS_CELL_id_list_exempted}
    ...  ELSE IF  '${rat}' == 'LTE'  Set To Dictionary  ${LTE_cell_info_exempted}  ${alias}  ${BTS_CELL_id_list_exempted}
    ...  ELSE IF  '${rat}' == 'WCDMA'  Set To Dictionary  ${WCDMA_cell_info_exempted}  ${alias}  ${BTS_CELL_id_list_exempted}
    ...  ELSE IF  '${rat}' == 'GSM'  Set To Dictionary  ${GSM_cell_info_exempted}  ${alias}  ${BTS_CELL_id_list_exempted}

    Return From Keyword If  '${DSS_peer_cell_id}' == 'None' or '${DSS_peer_alias}' == 'None'
    ...  ${LTE_cell_IOT_id}  ${NR_cell_info_exempted}  ${LTE_cell_info_exempted}  ${WCDMA_cell_info_exempted}
    ...  ${GSM_cell_info_exempted}

    ${DSS_peer_cell_id_list_exempted}=  Create List  ${DSS_peer_cell_id}
    Run Keyword If  '${DSS_peer_rat}' == 'NR'
    ...  Set To Dictionary  ${NR_cell_info_exempted}  ${DSS_peer_alias}  ${DSS_peer_cell_id_list_exempted}
    ...  ELSE IF  '${DSS_peer_rat}' == 'LTE'
    ...  Set To Dictionary  ${LTE_cell_info_exempted}  ${DSS_peer_alias}  ${DSS_peer_cell_id_list_exempted}

    [Return]  ${LTE_cell_IOT_id}  ${NR_cell_info_exempted}  ${LTE_cell_info_exempted}  ${WCDMA_cell_info_exempted}
    ...  ${GSM_cell_info_exempted}

Lock BTS cell
    [Arguments]  ${cell_id}  ${rat}  ${alias}

    Log  Perform "Lock Cell" operation on ${rat} cell ${cell_id} from BTS ${alias}   console=True

    Perform action on cell via PLAN  alias=${alias}  cell_id=${cell_id}  action=lock

    Log  Check BTS ${alias} state and alarms after "Lock Cell" operation on ${rat} cell ${cell_id}    console=True
    Check BTS impacted cells  lock  ${cell_id}  ${rat}  ${alias}
    Check BTS alarms  ${alias}

    Run Keyword If  '${DSS_peer_alias}' not in ['${alias}', 'None']  Run Keywords
    ...  Log  Check BTS ${DSS_peer_alias} alarms after "Lock Cell" operation on ${rat} cell ${cell_id}    console=True
    ...  AND  Check peer BTS alarms

    Sleep  5s  reason=Waiting time before check no impact on other cells

    Log  Check all BTS other cells are not impacted by "Lock Cell" operation on ${rat} cell ${cell_id} from BTS ${alias}  console=True
    Check BTS cells are enabled online with exceptions  NR_cell_info_exempted=&{NR_cell_info_exempted}
    ...  LTE_cell_info_exempted=&{LTE_cell_info_exempted}  WCDMA_cell_info_exempted=&{WCDMA_cell_info_exempted}
    ...  GSM_cell_info_exempted=&{GSM_cell_info_exempted}  timeout=3
    Log  All BTS other cells status is OK.  console=True

Unlock BTS cell
    [Arguments]  ${cell_id}  ${rat}  ${alias}

    Log  Perform "Unlock Cell" operation on ${rat} cell ${cell_id} from BTS ${alias}   console=True

    Perform action on cell via PLAN  alias=${alias}  cell_id=${cell_id}  action=unlock

    Log  Check BTS ${alias} state and alarms after "Unlock Cell" operation on ${rat} cell ${cell_id}  console=True
    Check BTS impacted cells  unlock  ${cell_id}  ${rat}  ${alias}
    Get and Check Alarms SOAM  alias=${alias}  expected_alarms=@{EMPTY}  ignored_alarms=${${alias.upper()}_IGNORED_ALARMS}
    ...  critical_alarms=${${alias.upper()}_CRITICAL_ALARMS}
    Log  BTS ${alias} site - expected, ignored and critical alarms checked  console=True

    Run Keyword If  '${DSS_peer_alias}' not in ['${alias}', 'None']  Run Keywords
    ...  Log  Check BTS ${DSS_peer_alias} alarms after "Unlock Cell" operation on ${rat} cell ${cell_id}    console=True
    ...  AND  Get and Check Alarms SOAM  alias=${DSS_peer_alias}  expected_alarms=@{EMPTY}
    ...  ignored_alarms=${${DSS_peer_alias.upper()}_IGNORED_ALARMS}  critical_alarms=${${DSS_peer_alias.upper()}_CRITICAL_ALARMS}
    ...  AND  Log  BTS ${DSS_peer_alias} site - expected, ignored and critical alarms checked  console=True

    Sleep  5s  reason=Waiting time before check no impact on other cells

    Log  Check all BTS other cells are not impacted by "Unlock Cell" operation on ${rat} cell ${cell_id} from BTS ${alias}  console=True
    Check BTS cells are enabled online with exceptions  timeout=3
    Log  All BTS other cells status is OK.  console=True

Check BTS impacted cells
    [Arguments]  ${operation}  ${cell_id}  ${rat}  ${alias}

    ${cell_class_name}=  Set Variable If  '${rat}' == 'NR'  NRCEL  '${rat}' == 'LTE'  LNCEL
    ${cell_state_check}=  Set Variable If  '${operation}' == 'lock'  ${CELL_state_locked_check}  '${operation}' == 'unlock'
    ...  ${CELL_state_unlocked_check}
    ${cell_state}=  Set Variable If  '${operation}' == 'lock'  ${CELL_state_locked}  '${operation}' == 'unlock'  ${CELL_state_unlocked}
    ${timeout}=  Set Variable If  '${operation}' == 'lock'  ${CELL_lock_MAX_WAIT_TIME}  '${operation}' == 'unlock'  ${CELL_UNlock_MAX_WAIT_TIME}

    Assert  class_name=${cell_class_name}  id=${cell_id}  parameters=${cell_state_check}  timeout=${timeout}  connection=${alias}
    Log  ${rat} cell ${cell_id} status:\n - ${cell_state}  console=True

    Run Keyword If  '${operation}' == 'unlock'
    ...  Wait Until Keyword Succeeds  60s  3s  Check cell is enabled online  ${cell_id}  ${cell_class_name}  ${alias}

    Run Keyword If  '${LTE_cell_IOT_id}' != 'None' and '${LTE_IOT_check}' == 'True'  Run Keywords
    ...  Assert  class_name=${cell_class_name}  id=${LTE_cell_IOT_id}  parameters=${cell_state_check}  timeout=${timeout}  connection=${alias}
    ...  AND  Log  ${rat} cell IOT ${LTE_cell_IOT_id} status:\n - ${cell_state}  console=True

Check cell is enabled online
    [Arguments]  ${cell_id}  ${cell_class_name}  ${alias}
    ${cell_status_enabled_degraded_check}=  Set Variable  operationalState=${Enabled_}, availabilityStatus=${Degraded_}
    ${cell_status_enabled_degraded_found}=  Run Keyword And Return Status  Assert  class_name=${cell_class_name}  id=${cell_id}
    ...  parameters=${cell_status_enabled_degraded_check}  timeout=3  connection=${alias}
    Should Be Equal As Strings  ${cell_status_enabled_degraded_found}  False

Check BTS alarms
    [Arguments]  ${alias}

    ${BTS_EXPECTED_ALARMS_full}=  Run Keyword If  '${alias}' == '${DSS_peer_alias}'
    ...  Set Variable  ${${alias.upper()}_ALARMS_${DSS_peer_rat}_DSS}
    ...  ELSE
    ...  Create List

    ${DSS_alarms_info}=  Set Variable If  '${DSS_peer_rat}' == 'NR'  ${NR_DSS_alarms_info}  '${DSS_peer_rat}' == 'LTE'  ${LTE_DSS_alarms_info}

    Run Keyword If  '${alias}' == '${DSS_peer_alias}'
    ...  Log  BTS ${alias} ${DSS_alarms_info}, expected number: 1  console=True

    Get and Check Alarms SOAM  alias=${alias}  poll_interval=5s  expected_alarms=${BTS_EXPECTED_ALARMS_full}
    ...  ignored_alarms=${${alias.upper()}_IGNORED_ALARMS}  critical_alarms=${${alias.upper()}_CRITICAL_ALARMS}

    Run Keyword If  '${alias}' == '${DSS_peer_alias}'
    ...  Log  BTS ${alias} ${DSS_alarms_info}, found number: 1, as expected  console=True

    Log  BTS ${alias} site - expected, ignored and critical alarms checked  console=True

Check peer BTS alarms

    ${DSS_alarms_info}=  Set Variable If  '${DSS_peer_rat}' == 'NR'  ${NR_DSS_alarms_info}  '${DSS_peer_rat}' == 'LTE'  ${LTE_DSS_alarms_info}

    Log  BTS ${DSS_peer_alias} ${DSS_alarms_info}, expected number: 1  console=True

    Get and Check Alarms SOAM  alias=${DSS_peer_alias}  poll_interval=5s  expected_alarms=${${DSS_peer_alias.upper()}_ALARMS_${DSS_peer_rat}_DSS}
    ...  ignored_alarms=${${DSS_peer_alias.upper()}_IGNORED_ALARMS}  critical_alarms=${${DSS_peer_alias.upper()}_CRITICAL_ALARMS}

    Log  BTS ${DSS_peer_alias} ${DSS_alarms_info}, found number: 1, as expected  console=True

    Log  BTS ${DSS_peer_alias} site - expected, ignored and critical alarms checked  console=True

Check if all BTS cells are unlocked
    FOR  ${alias}  IN  @{alias_list}

        Admin Check if BTS cells are unlocked  ${alias}

    END

Perform action on cell via PLAN
    [Arguments]    ${alias}  ${cell_id}  ${action}

    Log  ***** Perform "Lock" operation on cell ${Cell_id} from BTS ${alias} *****  console=True

    Get Current Date UTC info  initial
    Get Current Time  initial

    ${tech}=  Run Keyword If  'NRCEL' in '${cell_id}'
    ...  Set Variable  NR
    ...  ELSE IF  'LNCEL' in '${cell_id}'
    ...  Set Variable  LTE

    ${administrative_state_name_lock}=  Create Dictionary  NR=Locked  LTE=locked
    ${administrative_state_name_unlock}=  Create Dictionary  NR=Unlocked  LTE=unlocked

    ${Cell_detail_list}=  Get Variable Value  ${${alias}_${tech}_CELL_details}

    FOR  ${cell}  IN  @{Cell_detail_list}
       ${cell_id_internal}=  Get Variable Value  ${cell}[id][internal]
       ${CELL_ID_SCF}=  Get Variable Value  ${cell}[id][configuration]
       Exit For Loop If  '${cell_id_internal}'=='${cell_id}'
    END
    Should Be Equal  '${cell_id_internal}'  '${cell_id}'

    Perform Administrative State Recommissioning  obj_scf_dn=${CELL_ID_SCF}
    ...  administrativeState=${administrative_state_name_${action}}[${tech}]  alias=${alias}  timeout=${CELL_LOCK_MAX_WAIT_TIME}

Get and check kpi16a and kpi16b info from IMS file
    [Arguments]  ${cell_dn}  ${rat}  ${alias}  ${CYCLE}

    ${cell_label}=  Fetch From Right  ${cell_dn}  /
    ${global_cell_id}=  Fetch From Right  ${cell_dn}  -

    Log  Get and check KPI16a and KPI16b info from IMS file for ${rat} cell ${cell_label} from BTS ${alias}  console=True

    ${kpi_name_delta_dict}=  Get and check KPI info from IMS file  kpi_names=kpi16a, kpi16b
    ...  kpi_thresholds=${${rat}_CELL_LOCK_WRN_THR}, ${${rat}_CELL_UNLOCK_WRN_THR}  alias=${alias}  global_cell_id=${global_cell_id}
    ...  start_point_timestamp_UTC=${date_timestamp_start_UTC}  end_point_timestamp_UTC=${date_timestamp_end_UTC}
    ${kpi_delta_list_15a}=  Get From Dictionary  ${kpi_name_delta_dict}  kpi16a
    ${kpi_delta_list_15b}=  Get From Dictionary  ${kpi_name_delta_dict}  kpi16b

    ${obj_type}=  Set Variable If  '${rat}'=='NR'  NRCEL  '${rat}'=='LTE'  LNCEL

    Export KPI Results to File  alias=${alias}  obj=CELL  obj_type=${obj_type}  obj_id=${alias}_${cell_label}  action_1=Lock cell
    ...  action_2=Unlock cell  kpi_reported_1=KPI_15a  kpi_reported_2=KPI_15b  event_value_1=${kpi_delta_list_15a}[0]
    ...  event_value_2=${kpi_delta_list_15b}[0]  cycle=${CYCLE}  source_info=ims

Particular Teardown
    Run Keyword And Continue On Failure  Check if all BTS cells are unlocked
    Export KPI results to File Global  kpi_log_file_name=KpiTimeInfo

TC Setup
    ${tech_preset_list}=  Create List  SBTS  SBTS  SBTS  SBTS
    Common Test Setup  preset_techs=${tech_preset_list}  common_sbts=${TRUE}  infomodelSetup=${FALSE}
	...  PrecheckCells=${False}

TC Teardown
    Common Test Teardown
