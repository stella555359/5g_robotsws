*** Settings ***
Documentation    TC__SBTS_SBTS_SBTS_SBTS__STATE__Cell_Block_Unblock_from_WEBEM
Variables    tc_variables/sbts_sbts_sbts_sbts__state__cell_block_unblock_from_webem_alarms_definitions.py
Resource    ../../resources/rfs_frame_rfs_soam_taf.robot

*** Variables ***
${REPEAT_COUNTER}              3     # Number of BTS Cell Block/Unblock operations, default value 3
${BTS_LIST}                    ALL   # BTS list on which Cell Block/Unblock operation will be performed. Possible values (by default ALL):
                                     # - ALL: action will be performed on all BTS (Block/Unblock cells on each BTS until last BTS from TL)
                                     # - list of selected BTS separated by comma labeled as BTSx (x is test_pc number in init.py) (ex. BTS1, BTS3)
${RAT_LIST}                    ALL   # RAT list on which Cell Block/Unblock operation will be performed. Possible values (by default ALL):
                                     # - ALL: action will be performed on all RATs (Block/Unblock cells on all configured BTS RATs)
                                     # - list of selected RATs separated by comma, possible values: NR, LTE, WCDMA, GSM (ex. NR, LTE)
${LTE_IOT_SA_action}           True  # Only if RAT LTE is requested. Specify in case of configured LTE IOT SA cells if Block/Unblock operations
                                     # should be performed on them; possible values True or False, default value: True
${LTE_IOT_check}               True  # Only if RAT LTE is requested. Specify in case of configured LTE IOT cells if their status will be checked
                                     # (True) or skipped (False) after block host LTE cell. By default True
${NR_CELL_BLOCK_WRN_THR}       10    # Compared with the time spent from cell block command sent to cell down.
                                     # If exceeds NR_CELL_BLOCK_WRN_THR, test verdict will be failed and snapshot collected.
                                     # Default value: in accordance with KPI17a specifications
${NR_CELL_UNBLOCK_WRN_THR}     10    # Compared with the time spent from cell unblock command sent to cell up.
                                     # If exceeds NR_CELL_UNBLOCK_WRN_THR, test verdict will be failed and snapshot collected.
                                     # Default value: in accordance with KPI17b specifications
${LTE_CELL_BLOCK_WRN_THR}      10    # Compared with the time spent from cell block command sent to cell down.
                                     # If exceeds LTE_CELL_BLOCK_WRN_THR, test verdict will be failed and snapshot collected.
                                     # Default value: in accordance with KPI17a specifications
${LTE_CELL_UNBLOCK_WRN_THR}    10    # Compared with the time spent from cell unblock command sent to cell up.
                                     # If exceeds LTE_CELL_UNBLOCK_WRN_THR, test verdict will be failed and snapshot collected.
                                     # Default value: in accordance with KPI17b specifications
${WCDMA_CELL_BLOCK_WRN_THR}    10    # Compared with the time spent from cell block command sent to cell down.
                                     # If exceeds WCDMA_CELL_BLOCK_WRN_THR, test verdict will be failed and snapshot collected.
                                     # Default value: in accordance with KPI17a specifications
${WCDMA_CELL_UNBLOCK_WRN_THR}  10    # Compared with the time spent from cell unblock command sent to cell up.
                                     # If exceeds WCDMA_CELL_UNBLOCK_WRN_THR, test verdict will be failed and snapshot collected.
                                     # Default value: in accordance with KPI17b specifications
${GSM_CELL_BLOCK_WRN_THR}      130   # Compared with the time spent from cell block command sent to cell down.
                                     # If exceeds GSM_CELL_BLOCK_WRN_THR, test verdict will be failed and snapshot collected.
                                     # Default value: in accordance with KPI17a specifications
${GSM_CELL_UNBLOCK_WRN_THR}    10    # Compared with the time spent from cell unblock command sent to cell up.
                                     # If exceeds GSM_CELL_UNBLOCK_WRN_THR, test verdict will be failed and snapshot collected.
                                     # Default value: in accordance with KPI17b specifications
${CELL_BLOCK_MAX_WAIT_TIME}    200   # Maximum waiting time for cell to be blocked; default value 200 seconds
${CELL_UNBLOCK_MAX_WAIT_TIME}  200   # Maximum waiting time for cell to be unblocked; default value 200 seconds

*** Keywords ***
TC__SBTS_SBTS_SBTS_SBTS__STATE__Cell_Block_Unblock_from_WEBEM
     [Documentation]
    ...  [CASE LINK]: https://jiradc.ext.net.nokia.com/browse/TAT-24890
    ...
    ...  *****************
    ...  Basic information
    ...  *****************
    ...  SBTS-SBTS-SBTS-SBTS test case for Cell Block/Unblock on BTS, - x times sequence.
    ...  x - value of REPEAT_COUNTER parameter (default: 3)
    ...  The main steps performed for the test are:
    ...  - check initial state and alarms for all BTS
    ...  - get all BTS info
    ...  - perform Block/Unblock cells on BTS checking state and alarms;
    ...    - if ${BTS_LIST} == ALL, cell block/unblock operations will be performed on all BTS
    ...    - if ${BTS_LIST} != ALL, cell block/unblock operations will be performed on requested BTS
    ...    - if ${RAT_LIST} == ALL, cell block/unblock operations will be performed on all configured RATs
    ...    - if ${RAT_LIST} != ALL, cell block/unblock operations will be performed on requested configured RATs
    ...    - if ${LTE_IOT_SA_action} == True and LTE is in ${RAT_LIST}, LTE SA IOT cell block/unblock operations will be performed
    ...    - if ${LTE_IOT_check} == True and LTE is in ${RAT_LIST}, LTE IOT cell check status will be performed after block LTE HOST cell operation
    ...  - check KPI17a and KPI17b info from IMS file
    ...  - check final state and alarms for for all BTS
    ...  Pass criteria: Cell Block/Unblock operation works as expected; states and alarms are as expected
    ...
    ...  ******************
    ...  History of changes
    ...  ******************
    ...  - 16.05.2023 - https://jiradc.ext.net.nokia.com/browse/TAT-24890 - [5G][CB008693][CNI-58093] New TC
    ...  SBTS_SBTS_SBTS_SBTS_Cell_Block_Unblock_from_WEBEM
    ...  - 11.07.2023 - https://jiradc.ext.net.nokia.com/browse/TAT-25371 - [5G][CB008693][CNI-58093] New
    ...  TC SBTS_SBTS_SBTS_SBTS_Cell_Block_Unblock_from_WEBEM - DSS adaptation
    ...  - 09.01.2024 - https://jiradc.ext.net.nokia.com/browse/TAT-26682 - [5G]Update in TCs handling of Admin Get LTE HOST and IOT Cell(s) Id list,
    ...  for KW returning Empty list instead of None - SBTS_SBTS_SBTS_SBTS
    ...  - 16.01.2024 - https://jiradc.ext.net.nokia.com/browse/TAT-26628 - [5G][CB009182-C002270-RP003030]new
    ...  NR_SBTS__STATE__Cell_Block_Unblock_from_WEBEM TC which will run SSBTS_SBTS_SBTS_SBTS__STATE__Cell_Block_Unblock_from_WEBEM In case of
    ...  SBTS-NR configuration
    ...  - 12.02.2024 - https://jiradc.ext.net.nokia.com/browse/TAT-26878 - [5G] Correct alarm list names for ignored alarms in
    ...  SBTS_SBTS_SBTS__STATE__Primary_Controller_SharedRM_Reset_from_WEBEM
    ...  - 23.07.2024 - https://jiradc.ext.net.nokia.com/browse/TAT-27803 -
	...  [CNI-127210] [Part 1] DSS LTE EXPECTED alarms check removal SBTS_* TCs
    ...  - 17.10.2024 - https://jiradc.ext.net.nokia.com/browse/TAT-28213 -
	...  Wrong DSS alarm check for cell block/unblock robot SBTS_SBTS_STATE_Cell_Block_Unblock_from_WEBEM.robot + Link
    ...

    Set Tags    CA-STATE    OWNER-oana.bonchis@nokia.com   AUTHOR-anca.tatar@nokia.com    PHASE-QT    SW-SBTS23R3

    TC Preconditions
    Step 1: Check initial all BTS state
    Step 2: Check initial all BTS alarms
    Step 3: Get all BTS info
    FOR  ${INDEX}  IN RANGE  1  ${REPEAT_COUNTER}+1
        Log  ==============================================================================  console=True
        Log  Start Cycle ${INDEX} of ${REPEAT_COUNTER}  console=True
        Log  ==============================================================================  console=True
        Step 4: Perform Cell Block/Unblock on BTS for iteration ${INDEX}
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
    Log  BTS label list selected for Block/Unblock Cell operation: ${BTS_label_list}  console=True
    Log  BTS alias list selected for Block/Unblock Cell operation: ${BTS_alias_list}  console=True
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

        Log  BTS ${alias} site - proceduralState: OnAir, blockingState: Unblocked  console=True

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

    Set Test Variable  ${CELL_state_blocked_check}  operationalState=${Disabled_}, availabilityStatus=${Offline_}, blockingState=${Blocked_}
    Set Test Variable  ${CELL_state_blocked}  operationalState=Disabled, availabilityStatus=Offline, blockingState=Blocked
    Set Test Variable  ${CELL_state_unblocked_check}  operationalState=${Enabled_}, blockingState=${Unblocked_}
    Set Test Variable  ${CELL_state_unblocked}  operationalState=Enabled, blockingState=Unblocked

    Set Test Variable  ${NR_DSS_alarms_info}  "EN DSS De-activated on partner side (7513)" alarm
    Set Test Variable  ${LTE_DSS_alarms_info}  "EN DSS De-activated on partner side (6134)" alarm

Step ${index}: Perform Cell Block/Unblock on BTS for iteration ${CYCLE}
    Log  Step ${index}: Perform Cell Block/Unblock on BTS  console=True

    FOR  ${alias}  IN  @{BTS_alias_list}

        Perform Block Unblock BTS cells  ${alias}  ${CYCLE}

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

    ${WCDMA_CELL_id_list}=  Get Ids For All  class_name=WNCEL  connection=${alias}
    Run Keyword If  ${WCDMA_CELL_id_list}  Append To List  ${BTS_RAT_list}  WCDMA

    ${GSM_CELL_id_list}=  Get Ids For All  class_name=GNCEL  connection=${alias}
    Run Keyword If  ${GSM_CELL_id_list}  Append To List  ${BTS_RAT_list}  GSM

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

    ${NR_CELL_id_list}=  Get Ids For All  class_name=NRCEL  connection=${alias}
    Sort List  ${NR_CELL_id_list}
    Set Test Variable  ${${alias}_NR_CELL_id_list}  ${NR_CELL_id_list}

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

    ${LTE_cell_IOT_mapping_dict}=  Admin Get LTE CELL IOT mapping list  alias=${alias}
    Set Test Variable  ${${alias}_LTE_cell_IOT_mapping_dict}  ${LTE_cell_IOT_mapping_dict}

    ${WCDMA_CELL_id_list}=  Get Ids For All  class_name=WNCEL  connection=${alias}
    Sort List  ${WCDMA_CELL_id_list}
    Set Test Variable  ${${alias}_WCDMA_CELL_id_list}  ${WCDMA_CELL_id_list}

    ${GSM_CELL_id_list}=  Get Ids For All  class_name=GNCEL  connection=${alias}
    Sort List  ${GSM_CELL_id_list}
    Set Test Variable  ${${alias}_GSM_CELL_id_list}  ${GSM_CELL_id_list}

Perform Block Unblock BTS cells
    [Arguments]  ${alias}  ${CYCLE}

    FOR  ${rat}  IN  @{${alias}_BTS_RAT_list}

        Log  ***** Perform ${rat} Cell Block/Unblock on BTS ${alias} *****  console=True

        Block Unblock BTS cells  ${rat}  ${alias}  ${CYCLE}

    END

Block Unblock BTS cells
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

        Block BTS cell  ${cell_id}  ${rat}  ${alias}

        Unblock BTS cell  ${cell_id}  ${rat}  ${alias}

        Get Current Date UTC info  end

        Get and check KPI17a and KPI17b info from IMS file  ${cell_id}  ${rat}  ${alias}  ${CYCLE}

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

Block BTS cell
    [Arguments]  ${cell_id}  ${rat}  ${alias}

    Log  Perform "Block Cell" operation on ${rat} cell ${cell_id} from BTS ${alias}   console=True

    coam.Block Cell  dist_name=${cell_id}  timeout=${CELL_BLOCK_MAX_WAIT_TIME}  connection=${alias}

    Log  Check BTS ${alias} state and alarms after "Block Cell" operation on ${rat} cell ${cell_id}    console=True
    Check BTS impacted cells  block  ${cell_id}  ${rat}  ${alias}
    Check BTS alarms  ${rat}  ${alias}

    Run Keyword If  '${DSS_peer_alias}' not in ['${alias}', 'None']  Run Keywords
    ...  Log  Check BTS ${DSS_peer_alias} alarms after "Block Cell" operation on ${rat} cell ${cell_id}    console=True
    ...  AND  Check peer BTS alarms

    Sleep  5s  reason=Waiting time before check no impact on other cells

    Log  Check all BTS other cells are not impacted by "Block Cell" operation on ${rat} cell ${cell_id} from BTS ${alias}  console=True
    Check BTS cells are enabled online with exceptions  NR_cell_info_exempted=&{NR_cell_info_exempted}
    ...  LTE_cell_info_exempted=&{LTE_cell_info_exempted}  WCDMA_cell_info_exempted=&{WCDMA_cell_info_exempted}
    ...  GSM_cell_info_exempted=&{GSM_cell_info_exempted}  timeout=3
    Log  All BTS other cells status is OK.  console=True

Unblock BTS cell
    [Arguments]  ${cell_id}  ${rat}  ${alias}

    Log  Perform "Unblock Cell" operation on ${rat} cell ${cell_id} from BTS ${alias}   console=True

    coam.Unblock Cell  dist_name=${cell_id}  timeout=${CELL_UNBLOCK_MAX_WAIT_TIME}  connection=${alias}

    Log  Check BTS ${alias} state and alarms after "Unblock Cell" operation on ${rat} cell ${cell_id}  console=True
    Check BTS impacted cells  unblock  ${cell_id}  ${rat}  ${alias}
    Get and Check Alarms SOAM  alias=${alias}  expected_alarms=@{EMPTY}  ignored_alarms=${${alias.upper()}_IGNORED_ALARMS}
    ...  critical_alarms=${${alias.upper()}_CRITICAL_ALARMS}
    Log  BTS ${alias} site - expected, ignored and critical alarms checked  console=True

    Run Keyword If  '${DSS_peer_alias}' not in ['${alias}', 'None']  Run Keywords
    ...  Log  Check BTS ${DSS_peer_alias} alarms after "Unblock Cell" operation on ${rat} cell ${cell_id}    console=True
    ...  AND  Get and Check Alarms SOAM  alias=${DSS_peer_alias}  expected_alarms=@{EMPTY}
    ...  ignored_alarms=${${DSS_peer_alias.upper()}_IGNORED_ALARMS}  critical_alarms=${${DSS_peer_alias.upper()}_CRITICAL_ALARMS}
    ...  AND  Log  BTS ${DSS_peer_alias} site - expected, ignored and critical alarms checked  console=True

    Sleep  5s  reason=Waiting time before check no impact on other cells

    Log  Check all BTS other cells are not impacted by "Unblock Cell" operation on ${rat} cell ${cell_id} from BTS ${alias}  console=True
    Check BTS cells are enabled online with exceptions  timeout=3
    Log  All BTS other cells status is OK.  console=True

Check BTS impacted cells
    [Arguments]  ${operation}  ${cell_id}  ${rat}  ${alias}

    ${cell_class_name}=  Set Variable If  '${rat}' == 'NR'  NRCEL  '${rat}' == 'LTE'  LNCEL  '${rat}' == 'WCDMA'  WNCEL  '${rat}' == 'GSM'  GNCEL
    ${cell_state_check}=  Set Variable If  '${operation}' == 'block'  ${CELL_state_blocked_check}  '${operation}' == 'unblock'
    ...  ${CELL_state_unblocked_check}
    ${cell_state}=  Set Variable If  '${operation}' == 'block'  ${CELL_state_blocked}  '${operation}' == 'unblock'  ${CELL_state_unblocked}
    ${timeout}=  Set Variable If  '${operation}' == 'block'  ${CELL_BLOCK_MAX_WAIT_TIME}  '${operation}' == 'unblock'  ${CELL_UNBLOCK_MAX_WAIT_TIME}

    Assert  class_name=${cell_class_name}  id=${cell_id}  parameters=${cell_state_check}  timeout=${timeout}  connection=${alias}
    Log  ${rat} cell ${cell_id} status:\n - ${cell_state}  console=True

    Run Keyword If  '${operation}' == 'unblock'
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
    [Arguments]  ${rat}  ${alias}

    ${FID49_alarm_count}=  Set Variable If  '${rat}' == 'LTE' and '${LTE_cell_IOT_id}' != 'None'  2  1
    ${BTS_EXPECTED_ALARMS_49_full}=  Prepare expected alarms list  ${${alias.upper()}_EXPECTED_ALARMS_49}  ${FID49_alarm_count}
    ${BTS_EXPECTED_ALARMS_full}=  Run Keyword If  '${alias}' == '${DSS_peer_alias}'
    ...  Combine Lists  ${BTS_EXPECTED_ALARMS_49_full}  ${${alias.upper()}_ALARMS_${DSS_peer_rat}_DSS}
    ...  ELSE
    ...  Set Variable  ${BTS_EXPECTED_ALARMS_49_full}

    ${DSS_alarms_info}=  Set Variable If  '${DSS_peer_rat}' == 'NR'  ${NR_DSS_alarms_info}  '${DSS_peer_rat}' == 'LTE'  ${LTE_DSS_alarms_info}

    Log  BTS ${alias} "Cell Blocked (49)" alarm, expected number: ${FID49_alarm_count}  console=True
    Run Keyword If  '${alias}' == '${DSS_peer_alias}'
    ...  Log  BTS ${alias} ${DSS_alarms_info}, expected number: 1  console=True

    Get and Check Alarms SOAM  alias=${alias}  poll_interval=5s  expected_alarms=${BTS_EXPECTED_ALARMS_full}
    ...  ignored_alarms=${${alias.upper()}_IGNORED_ALARMS}  critical_alarms=${${alias.upper()}_CRITICAL_ALARMS}

    Log  BTS ${alias} "Cell Blocked (49)" alarm, found number: ${FID49_alarm_count}, as expected  console=True
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

Get and check KPI17a and KPI17b info from IMS file
    [Arguments]  ${cell_id}  ${rat}  ${alias}  ${CYCLE}

    ${cell_label}=  Fetch From Right  ${cell_id}  /

    Log  Get and check KPI17a and KPI17b info from IMS file for ${rat} cell ${cell_label} from BTS ${alias}  console=True

    ${kpi_name_delta_dict}=  Get and check KPI info from IMS file  kpi_names=kpi17a, kpi17b
    ...  kpi_thresholds=${${rat}_CELL_BLOCK_WRN_THR}, ${${rat}_CELL_UNBLOCK_WRN_THR}  alias=${alias}  cell_dist_name=${cell_id}
    ...  start_point_timestamp_UTC=${date_timestamp_start_UTC}  end_point_timestamp_UTC=${date_timestamp_end_UTC}
    ${kpi_delta_list_17a}=  Get From Dictionary  ${kpi_name_delta_dict}  kpi17a
    ${kpi_delta_list_17b}=  Get From Dictionary  ${kpi_name_delta_dict}  kpi17b

    ${obj_type}=  Set Variable If  '${rat}'=='NR'  NRCEL  '${rat}'=='LTE'  LNCEL  '${rat}'=='WCDMA'  WNCEL  '${rat}'=='GSM'  GNCEL

    Export KPI Results to File  alias=${alias}  obj=CELL  obj_type=${obj_type}  obj_id=${alias}_${cell_label}  action_1=Block cell
    ...  action_2=Unblock cell  kpi_reported_1=KPI_17a  kpi_reported_2=KPI_17b  event_value_1=${kpi_delta_list_17a[0]}
    ...  event_value_2=${kpi_delta_list_17b[0]}  cycle=${CYCLE}  source_info=ims

Check if all BTS cells are unblocked
    FOR  ${alias}  IN  @{alias_list}

        Admin Check if BTS cells are unblocked  ${alias}

    END

Particular Teardown
    Run Keyword And Continue On Failure  Check if all BTS cells are unblocked
    Export KPI results to File Global  kpi_log_file_name=KpiTimeInfo

TC Setup
    ${tech_preset_list}=  Create List  SBTS  SBTS  SBTS  SBTS
    Common Test Setup  preset_techs=${tech_preset_list}  common_sbts=${TRUE}  infomodelSetup=${FALSE}

TC Teardown
    Common Test Teardown
