*** Settings ***
Documentation    TC__SBTS_SBTS_SBTS_SBTS__STATE__Cell_Block_Unblock_Lock_Unlock_Site_Reset
Variables    tc_variables/sbts_sbts_sbts_sbts__state__cell_block_unblock_lock_unlock_site_reset_alarms_definitions.py
Resource    ../../resources/rfs_frame_rfs_soam_taf.robot

*** Variables ***
${REPEAT_COUNTER}                      3    # Number of BTS operations: Block/Unblock and Lock/Unlock cells and Reset Site, default value 3
${BTS_RESET_LIST}                           # BTS list on which Reset Site operation will be performed. List of selected BTS separated by comma
                                            # labeled as BTSx (x is test_pc number in init.py) (ex. BTS1, BTS3)
${BTS1_NR_GLOBAL_CELL_ID_BLOCK_LIST}        # BTS1 NR global cell ID list for Block/Unblock operations
${BTS1_NR_GLOBAL_CELL_ID_LOCK_LIST}         # BTS1 NR global cell ID list for Lock/Unlock operations
${BTS1_LTE_GLOBAL_CELL_ID_BLOCK_LIST}       # BTS1 LTE global cell ID list for Block/Unblock operations
${BTS1_LTE_GLOBAL_CELL_ID_LOCK_LIST}        # BTS1 LTE global cell ID list for Lock/Unlock operations
${BTS2_NR_GLOBAL_CELL_ID_BLOCK_LIST}        # BTS2 NR global cell ID list for Block/Unblock operations
${BTS2_NR_GLOBAL_CELL_ID_LOCK_LIST}         # BTS2 NR global cell ID list for Lock/Unlock operations
${BTS2_LTE_GLOBAL_CELL_ID_BLOCK_LIST}       # BTS2 LTE global cell ID list for Block/Unblock operations
${BTS2_LTE_GLOBAL_CELL_ID_LOCK_LIST}        # BTS2 LTE global cell ID list for Lock/Unlock operations
${BTS3_NR_GLOBAL_CELL_ID_BLOCK_LIST}        # BTS3 NR global cell ID list for Block/Unblock operations
${BTS3_NR_GLOBAL_CELL_ID_LOCK_LIST}         # BTS3 NR global cell ID list for Lock/Unlock operations
${BTS3_LTE_GLOBAL_CELL_ID_BLOCK_LIST}       # BTS3 LTE global cell ID list for Block/Unblock operations
${BTS3_LTE_GLOBAL_CELL_ID_LOCK_LIST}        # BTS3 LTE global cell ID list for Lock/Unlock operations
${BTS4_NR_GLOBAL_CELL_ID_BLOCK_LIST}        # BTS4 NR global cell ID list for Block/Unblock operations
${BTS4_NR_GLOBAL_CELL_ID_LOCK_LIST}         # BTS4 NR global cell ID list for Lock/Unlock operations
${BTS4_LTE_GLOBAL_CELL_ID_BLOCK_LIST}       # BTS4 LTE global cell ID list for Block/Unblock operations
${BTS4_LTE_GLOBAL_CELL_ID_LOCK_LIST}        # BTS4 LTE global cell ID list for Lock/Unlock operations
${CELL_MAX_WAIT_TIME}                  200  # Maximum waiting time for CELL operation to be completed; default value 200 seconds
${BTS_MAX_WAIT_TIME}                   900  # Maximum waiting time for BTS operation to be completed; default value 900 seconds

*** Keywords ***
TC__SBTS_SBTS_SBTS_SBTS__STATE__Cell_Block_Unblock_Lock_Unlock_Site_Reset
     [Documentation]
    ...  [CASE LINK]: https://jiradc.ext.net.nokia.com/browse/TAT-29226
    ...
    ...  *****************
    ...  Basic information
    ...  *****************
    ...  SBTS-SBTS-SBTS-SBTS test case for mixed BTS operations: Cell Block/Unblock, Cell Lock/Unlock, Site Reset - x times sequence.
    ...  x - value of REPEAT_COUNTER parameter (default: 3)
    ...  The main steps performed for the test are:
    ...  - check initial state and alarms for all BTS
    ...  - get all BTS info
    ...  - perform Block operation on selected BTS cells checking state and alarms
    ...  - perform Lock operation on selected BTS cells checking state and alarms
    ...  - perform Reset Site operation on selected BTS checking state and alarms
    ...  - perform Unblock operation on selected BTS cells checking state and alarms
    ...  - perform Unlock operation on selected BTS cells checking state and alarms
    ...  - check final state and alarms for for all BTS
    ...  Pass criteria: Cell Block/Unblock, Cell Lock/Unlock, Site Reset works as expected; states and alarms are as expected
    ...
    ...  ******************
    ...  History of changes
    ...  ******************
    ...  - 16.06.2025 - https://jiradc.ext.net.nokia.com/browse/TAT-29226 - New scenario for NR&LTE Cell block/Unblock and Lock/Unlock
    ...

    Set Tags    CA-STATE    OWNER-razvan.rechesan@nokia.com    AUTHOR-dinu.olariu@nokia.com    PHASE-QT    SW-SBTS25R3

    TC Preconditions
    Step 1: Check initial all BTS state
    Step 2: Check initial all BTS alarms
    Step 3: Get all BTS info
    FOR  ${INDEX}  IN RANGE  1  ${REPEAT_COUNTER}+1
        Log  ==============================================================================  console=True
        Log  Start Cycle ${INDEX} of ${REPEAT_COUNTER}  console=True
        Log  ==============================================================================  console=True
        Step 4: Perform Block operation on BTS cells
        Step 5: Perform Lock operation on BTS cells
        Step 6: Perform Reset Site operation on BTS
        Step 7: Perform Unblock operation on BTS cells
        Step 8: Perform Unlock operation on BTS cells
        Step 9: Check final all BTS state
        Step 10: Check final all BTS alarms
        Step 11: Check final number and state of Cells and RMs
    END

    [Teardown]  Particular Teardown

TC Preconditions
    ${BTS_alias_label_dict}  ${BTS_label_alias_dict}=  Get BTS alias label info dict
    Set Test Variable  ${BTS_alias_label_dict}
    Set Test Variable  ${BTS_label_alias_dict}
    ${BTS_alias_list}=  Get Dictionary Keys  ${BTS_alias_label_dict}  False
    ${BTS_label_list}=  Get Dictionary Values  ${BTS_alias_label_dict}  False
    Set Test Variable  ${BTS_alias_list}
    Set Test Variable  ${BTS_label_list}

    Check BTS reset list

    Get all BTS cell info dict

    Check BTS global cell id list

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

    Get all BTS NR and LTE cell info
    Get all BTS LTE IOT cell info

    Set Test Variable  ${CELL_state_blocked_check}
    ...  operationalState=${Disabled_}, availabilityStatus=${Offline_}, blockingState=${Blocked_}, administrativeState=${Unlocked_}
    Set Test Variable  ${CELL_state_blocked}
    ...  operationalState=Disabled, availabilityStatus=Offline, blockingState=Blocked, administrativeState=Unlocked
    Set Test Variable  ${CELL_state_locked_check}
    ...  operationalState=${Disabled_}, availabilityStatus=${Offline_}, blockingState=${Unblocked_}, administrativeState=${Locked_}
    Set Test Variable  ${CELL_state_locked}
    ...  operationalState=Disabled, availabilityStatus=Offline, blockingState=Unblocked, administrativeState=Locked
    Set Test Variable  ${CELL_state_blocked_locked_check}
    ...  operationalState=${Disabled_}, availabilityStatus=${Offline_}, blockingState=${Blocked_}, administrativeState=${Locked_}
    Set Test Variable  ${CELL_state_blocked_locked}
    ...  operationalState=Disabled, availabilityStatus=Offline, blockingState=Blocked, administrativeState=Locked
    Set Test Variable  ${CELL_state_enabled_check}
    ...  operationalState=${Enabled_}, blockingState=${Unblocked_}, administrativeState=${Unlocked_}
    Set Test Variable  ${CELL_state_enabled}
    ...  operationalState=Enabled, blockingState=Unblocked, administrativeState=Unlocked

Step ${index}: Perform Block operation on BTS cells
    Log  Step ${index}: Perform Block operation on BTS cells  console=True

    FOR  ${alias}  IN  @{BTS_alias_list}
        Perform Block cells on BTS  ${alias}
    END

Step ${index}: Perform Lock operation on BTS cells
    Log  Step ${index}: Perform Lock operation on BTS cells  console=True

    FOR  ${alias}  IN  @{BTS_alias_list}
        Perform Lock cells on BTS  ${alias}
    END

Step ${index}: Perform Reset Site operation on BTS
    Log  Step ${index}: Perform Reset Site operation on BTS  console=True

    FOR  ${alias}  IN  @{BTS_RESET_alias_list}
        Perform Reset Site on BTS  ${alias}
    END

Step ${index}: Perform Unblock operation on BTS cells
    Log  Step ${index}: Perform Unblock operation on BTS cells  console=True

    FOR  ${alias}  IN  @{BTS_alias_list}
        Perform Unblock cells on BTS  ${alias}
    END

Step ${index}: Perform Unlock operation on BTS cells
    Log  Step ${index}: Perform Unlock operation on BTS cells  console=True

    FOR  ${alias}  IN  @{BTS_alias_list}
        Perform Unlock cells on BTS  ${alias}
    END

Step ${index}: Check final number and state of Cells and RMs
    [Documentation]
    ...  Following checks are performed:
    ...  - number of configured cells and radio modules in SCF are properly mapped on BTS running view ADMIN
    ...  - check cells states
    ...  - check radio modules states

    Log  Step ${index}: Check final number and state of Cells and RMs  console=True
    RFS Test Case Final Checks

Check BTS reset list
    Run Keyword If  '${BTS_RESET_LIST}' == ''  Run Keywords
    ...  Log Long String  No selected BTS for Reset Site operation. Please select values for test argument \${BTS_RESET_LIST} from configured BTS:
    ...  ${BTS_label_list}  console=True
    ...  AND  Fail  Improper value for argument!

    ${BTS_RESET_LIST_stripped}=  Replace String  ${BTS_RESET_LIST}  ${SPACE}  ${EMPTY}
    ${BTS_RESET_LIST_split}=  Split String  ${BTS_RESET_LIST_stripped}  ,
    ${BTS_RESET_check}=  Set Variable  True
    ${BTS_RESET_invalid_list}=  Create List
    ${BTS_RESET_request_list}=  Create List
    ${BTS_RESET_request_alias_list}=  Create List

    FOR  ${item}  IN  @{BTS_RESET_LIST_split}
        ${BTS_RESET_check}=  Set Variable If  '${item}' not in ${BTS_label_list}  False  ${BTS_RESET_check}

        Run Keyword If  '${item}' in ${BTS_label_list}
        ...  Append To List  ${BTS_RESET_request_list}  ${item}
        ...  ELSE
        ...  Append To List  ${BTS_RESET_invalid_list}  ${item}
    END

    Run Keyword If  '${BTS_RESET_check}' == 'False'  Run Keywords
    ...  Log Long String  Following selected BTS are not valid: ${BTS_RESET_invalid_list}. Please select values for test argument \${BTS_RESET_LIST}
    ...  from configured BTS: ${BTS_label_list}  console=True
    ...  AND  Fail  Improper value for argument!

    FOR  ${item}  IN  @{BTS_RESET_request_list}
        ${BTS_RESET_request_alias}=  Get From Dictionary  ${BTS_label_alias_dict}  ${item}
        Append To List  ${BTS_RESET_request_alias_list}  ${BTS_RESET_request_alias}
    END

    Set Test Variable  ${BTS_RESET_label_list}  ${BTS_RESET_request_list}
    Set Test Variable  ${BTS_RESET_alias_list}  ${BTS_RESET_request_alias_list}

Get all BTS cell info dict
    FOR  ${alias}  IN  @{alias_list}
        ${NR_globalCellId_cell_id_dict}=  Get BTS cell info dict  nr  ${alias}
        ${LTE_globalCellId_cell_id_dict}=  Get BTS cell info dict  lte  ${alias}
        Set Test Variable  ${${alias}_NR_globalCellId_cell_id_dict}  ${NR_globalCellId_cell_id_dict}
        Set Test Variable  ${${alias}_LTE_globalCellId_cell_id_dict}  ${LTE_globalCellId_cell_id_dict}
    END

Get BTS cell info dict
    [Arguments]  ${cell_type}  ${alias}

    ${globalCellId_cell_id_dict}=  Create Dictionary

    ${cells_info}=  Get Cells Info  cell_type=${cell_type}  timeout=10  connection=${alias}

    FOR  ${item}  IN  @{cells_info}
        ${globalCellId_info}=  Get From Dictionary  ${item}  globalCellId
        ${id_info}=  Get From Dictionary  ${item}  id
        ${cell_id}=  Get From Dictionary  ${id_info}  internal

        Set To Dictionary  ${globalCellId_cell_id_dict}  ${globalCellId_info}  ${cell_id}
    END

    [Return]  ${globalCellId_cell_id_dict}

Check BTS global cell id list
    ${condition_cell_block}=  Create Long String
    ...  '${BTS1_NR_GLOBAL_CELL_ID_BLOCK_LIST}' == '' and '${BTS1_LTE_GLOBAL_CELL_ID_BLOCK_LIST}' == '' and
    ...  '${BTS2_NR_GLOBAL_CELL_ID_BLOCK_LIST}' == '' and '${BTS2_LTE_GLOBAL_CELL_ID_BLOCK_LIST}' == '' and
    ...  '${BTS3_NR_GLOBAL_CELL_ID_BLOCK_LIST}' == '' and '${BTS3_LTE_GLOBAL_CELL_ID_BLOCK_LIST}' == '' and
    ...  '${BTS4_NR_GLOBAL_CELL_ID_BLOCK_LIST}' == '' and '${BTS4_LTE_GLOBAL_CELL_ID_BLOCK_LIST}' == ''

    Run Keyword If  ${condition_cell_block}  Run Keywords
    ...  Log Long String  No selected NR or LTE global cell ID for Block/Unblock operations on any BTS. Please select values for test argument
    ...  \${BTSx_NR_GLOBAL_CELL_ID_BLOCK_LIST} or \${BTSx_LTE_GLOBAL_CELL_ID_BLOCK_LIST} from configured NR or LTE global cell ID on BTS  console=True
    ...  AND  Fail  Improper value for argument!

    ${condition_cell_lock}=  Create Long String
    ...  '${BTS1_NR_GLOBAL_CELL_ID_LOCK_LIST}' == '' and '${BTS1_LTE_GLOBAL_CELL_ID_LOCK_LIST}' == '' and
    ...  '${BTS2_NR_GLOBAL_CELL_ID_LOCK_LIST}' == '' and '${BTS2_LTE_GLOBAL_CELL_ID_LOCK_LIST}' == '' and
    ...  '${BTS3_NR_GLOBAL_CELL_ID_LOCK_LIST}' == '' and '${BTS3_LTE_GLOBAL_CELL_ID_LOCK_LIST}' == '' and
    ...  '${BTS4_NR_GLOBAL_CELL_ID_LOCK_LIST}' == '' and '${BTS4_LTE_GLOBAL_CELL_ID_LOCK_LIST}' == ''

    Run Keyword If  ${condition_cell_lock}  Run Keywords
    ...  Log Long String  No selected NR or LTE global cell ID for Lock/Unlock operations on any BTS. Please select values for test argument
    ...  \${BTSx_NR_GLOBAL_CELL_ID_LOCK_LIST} or \${BTSx_LTE_GLOBAL_CELL_ID_LOCK_LIST} from configured NR or LTE global cell ID on BTS  console=True
    ...  AND  Fail  Improper value for argument!

    ${BTS_cell_id_list}=  Check and get BTS cell id list  ${BTS1_NR_GLOBAL_CELL_ID_BLOCK_LIST}  nr  BTS1
    Set Test Variable  ${BTS1_NR_cell_id_block_list}  ${BTS_cell_id_list}
    ${BTS_cell_id_list}=  Check and get BTS cell id list  ${BTS1_NR_GLOBAL_CELL_ID_LOCK_LIST}  nr  BTS1
    Set Test Variable  ${BTS1_NR_cell_id_lock_list}  ${BTS_cell_id_list}
    ${BTS_cell_id_list}=  Check and get BTS cell id list  ${BTS1_LTE_GLOBAL_CELL_ID_BLOCK_LIST}  lte  BTS1
    Set Test Variable  ${BTS1_LTE_cell_id_block_list}  ${BTS_cell_id_list}
    ${BTS_cell_id_list}=  Check and get BTS cell id list  ${BTS1_LTE_GLOBAL_CELL_ID_LOCK_LIST}  lte  BTS1
    Set Test Variable  ${BTS1_LTE_cell_id_lock_list}  ${BTS_cell_id_list}

    ${BTS_cell_id_list}=  Check and get BTS cell id list  ${BTS2_NR_GLOBAL_CELL_ID_BLOCK_LIST}  nr  BTS2
    Set Test Variable  ${BTS2_NR_cell_id_block_list}  ${BTS_cell_id_list}
    ${BTS_cell_id_list}=  Check and get BTS cell id list  ${BTS2_NR_GLOBAL_CELL_ID_LOCK_LIST}  nr  BTS2
    Set Test Variable  ${BTS2_NR_cell_id_lock_list}  ${BTS_cell_id_list}
    ${BTS_cell_id_list}=  Check and get BTS cell id list  ${BTS2_LTE_GLOBAL_CELL_ID_BLOCK_LIST}  lte  BTS2
    Set Test Variable  ${BTS2_LTE_cell_id_block_list}  ${BTS_cell_id_list}
    ${BTS_cell_id_list}=  Check and get BTS cell id list  ${BTS2_LTE_GLOBAL_CELL_ID_LOCK_LIST}  lte  BTS2
    Set Test Variable  ${BTS2_LTE_cell_id_lock_list}  ${BTS_cell_id_list}

    ${BTS_cell_id_list}=  Check and get BTS cell id list  ${BTS3_NR_GLOBAL_CELL_ID_BLOCK_LIST}  nr  BTS3
    Set Test Variable  ${BTS3_NR_cell_id_block_list}  ${BTS_cell_id_list}
    ${BTS_cell_id_list}=  Check and get BTS cell id list  ${BTS3_NR_GLOBAL_CELL_ID_LOCK_LIST}  nr  BTS3
    Set Test Variable  ${BTS3_NR_cell_id_lock_list}  ${BTS_cell_id_list}
    ${BTS_cell_id_list}=  Check and get BTS cell id list  ${BTS3_LTE_GLOBAL_CELL_ID_BLOCK_LIST}  lte  BTS3
    Set Test Variable  ${BTS3_LTE_cell_id_block_list}  ${BTS_cell_id_list}
    ${BTS_cell_id_list}=  Check and get BTS cell id list  ${BTS3_LTE_GLOBAL_CELL_ID_LOCK_LIST}  lte  BTS3
    Set Test Variable  ${BTS3_LTE_cell_id_lock_list}  ${BTS_cell_id_list}

    ${BTS_cell_id_list}=  Check and get BTS cell id list  ${BTS4_NR_GLOBAL_CELL_ID_BLOCK_LIST}  nr  BTS4
    Set Test Variable  ${BTS4_NR_cell_id_block_list}  ${BTS_cell_id_list}
    ${BTS_cell_id_list}=  Check and get BTS cell id list  ${BTS4_NR_GLOBAL_CELL_ID_LOCK_LIST}  nr  BTS4
    Set Test Variable  ${BTS4_NR_cell_id_lock_list}  ${BTS_cell_id_list}
    ${BTS_cell_id_list}=  Check and get BTS cell id list  ${BTS4_LTE_GLOBAL_CELL_ID_BLOCK_LIST}  lte  BTS4
    Set Test Variable  ${BTS4_LTE_cell_id_block_list}  ${BTS_cell_id_list}
    ${BTS_cell_id_list}=  Check and get BTS cell id list  ${BTS4_LTE_GLOBAL_CELL_ID_LOCK_LIST}  lte  BTS4
    Set Test Variable  ${BTS4_LTE_cell_id_lock_list}  ${BTS_cell_id_list}

Check and get BTS cell id list
    [Arguments]  ${globalCellId_list}  ${cell_type}  ${BTS_label}

    ${BTS_status}=  Run Keyword And Return Status  Dictionary Should Contain Key  ${BTS_label_alias_dict}  ${BTS_label}
    Return From Keyword If  not ${BTS_status}

    ${alias}=  Get From Dictionary  ${BTS_label_alias_dict}  ${BTS_label}

    ${BTS_cell_id_list}=  Create List

    Return From Keyword If  '${globalCellId_list}' == ''  ${BTS_cell_id_list}

    ${globalCellId_list_stripped}=  Replace String  ${globalCellId_list}  ${SPACE}  ${EMPTY}
    ${globalCellId_list_split}=  Split String  ${globalCellId_list_stripped}  ,
    ${globalCellId_check}=  Set Variable  True
    ${globalCellId_invalid_list}=  Create List
    ${globalCellId_request_list}=  Create List
    ${globalCellId_configured_list}=  Create List

    ${globalCellId_configured_list}=  Get Dictionary Keys  ${${alias}_${cell_type.upper()}_globalCellId_cell_id_dict}

    FOR  ${globalCellId}  IN  @{globalCellId_list_split}
        ${globalCellId}=  Convert To Integer  ${globalCellId}
        ${globalCellId_check}=  Set Variable If  ${globalCellId} not in ${globalCellId_configured_list}  False  ${globalCellId_check}

        Run Keyword If  ${globalCellId} in ${globalCellId_configured_list}
        ...  Append To List  ${globalCellId_request_list}  ${globalCellId}
        ...  ELSE
        ...  Append To List  ${globalCellId_invalid_list}  ${globalCellId}
    END

    Run Keyword If  '${globalCellId_check}' == 'False'  Run Keywords
    ...  Log Long String  Following selected values for test argument \${${BTS_label}_${cell_type.upper()}_GLOBAL_CELL_ID_BLOCK_LIST}
    ...  or \${${BTS_label}_${cell_type.upper()}_GLOBAL_CELL_ID_LOCK_LIST} are not valid: ${globalCellId_invalid_list}. Please select values from
    ...  configured BTS cells: ${globalCellId_configured_list}  console=True
    ...  AND  Fail  Improper value for argument!

    FOR  ${globalCellId}  IN  @{globalCellId_request_list}
        ${cell_id}=  Get From Dictionary  ${${alias}_${cell_type.upper()}_globalCellId_cell_id_dict}  ${globalCellId}
        Append To List  ${BTS_cell_id_list}  ${cell_id}
    END

    [Return]  ${BTS_cell_id_list}
Get all BTS NR and LTE cell info
    FOR  ${alias}  IN  @{alias_list}
        ${NR_CELL_id_list}=  Get Ids For All  class_name=NRCEL  connection=${alias}
        ${NR_CELL_id_count}=  Get Length  ${NR_CELL_id_list}
        Set Test Variable  ${${alias}_NR_CELL_id_list}  ${NR_CELL_id_list}
        Set Test Variable  ${${alias}_NR_CELL_id_count}  ${NR_CELL_id_count}

        ${LTE_CELL_id_list}=  Get Ids For All  class_name=LNCEL  connection=${alias}
        ${LTE_HOST_CELL_id_list}  ${LTE_IOT_CELL_id_list}  ${LTE_IOT_SA_CELL__id_list}=
        ...  Admin Get LTE HOST and IOT Cell(s) Id list  CELL_list=${LTE_CELL_id_list}  alias=${alias}
        ${LTE_CELL_id_list}=  Combine Lists  ${LTE_HOST_CELL_id_list}  ${LTE_IOT_SA_CELL_id_list}
        ${LTE_CELL_id_count}=  Get Length  ${LTE_CELL_id_list}
        Set Test Variable  ${${alias}_LTE_CELL_id_list}  ${LTE_CELL_id_list}
        Set Test Variable  ${${alias}_LTE_CELL_id_count}  ${LTE_CELL_id_count}
    END

Get all BTS LTE IOT cell info
    FOR  ${alias}  IN  @{alias_list}
        ${LTE_IOT_cell_mapping_dict}=  Admin Get LTE CELL IOT mapping list  alias=${alias}
        Set Test Variable  ${${alias}_LTE_IOT_cell_mapping_dict}  ${LTE_IOT_cell_mapping_dict}
    END

Perform Block cells on BTS
    [Arguments]  ${alias}

    ${BTS_label}=  Get From Dictionary  ${BTS_alias_label_dict}  ${alias}
    ${NR_cell_id_block_count}=  Get Length  ${${BTS_label}_NR_cell_id_block_list}
    ${LTE_cell_id_block_count}=  Get Length  ${${BTS_label}_LTE_cell_id_block_list}

    Return From Keyword If  ${NR_cell_id_block_count} == 0 and ${LTE_cell_id_block_count} == 0

    ${NR_cell_id_blocked_list}=  Create List
    ${LTE_cell_id_blocked_list}=  Create List
    ${LTE_IOT_cell_id_blocked_list}=  Create List

    FOR  ${cell_id}  IN  @{${BTS_label}_NR_cell_id_block_list}
        Log  ***** Perform Block operation on NR cell ${cell_id} from BTS ${alias} *****  console=True

        coam.Block Cell  dist_name=${cell_id}  timeout=${CELL_MAX_WAIT_TIME}  connection=${alias}

        Assert  class_name=NRCEL  id=${cell_id}  parameters=${CELL_state_blocked_check}  timeout=${CELL_MAX_WAIT_TIME}  connection=${alias}
        Log  NR cell ${cell_id} status:\n - ${CELL_state_blocked}  console=True

        Append To List  ${NR_cell_id_blocked_list}  ${cell_id}
    END

    FOR  ${cell_id}  IN  @{${BTS_label}_LTE_cell_id_block_list}
        Log  ***** Perform Block operation on LTE cell ${cell_id} from BTS ${alias} *****  console=True

        coam.Block Cell  dist_name=${cell_id}  timeout=${CELL_MAX_WAIT_TIME}  connection=${alias}

        Assert  class_name=LNCEL  id=${cell_id}  parameters=${CELL_state_blocked_check}  timeout=${CELL_MAX_WAIT_TIME}  connection=${alias}
        Log  LTE cell ${cell_id} status:\n - ${CELL_state_blocked}  console=True

        Append To List  ${LTE_cell_id_blocked_list}  ${cell_id}

        ${LTE_IOT_cell_status}=  Run Keyword And Return Status  Dictionary Should Contain Key  ${${alias}_LTE_IOT_cell_mapping_dict}  ${cell_id}
        Continue For Loop If  not ${LTE_IOT_cell_status}

        ${LTE_IOT_cell_id}=  Get From Dictionary  ${${alias}_LTE_IOT_cell_mapping_dict}  ${cell_id}

        Run Keyword If  '${LTE_IOT_cell_id}' != 'None'  Run Keywords
        ...  Assert  class_name=LNCEL  id=${LTE_IOT_cell_id}  parameters=${CELL_state_blocked_check}  timeout=${CELL_MAX_WAIT_TIME}
        ...  connection=${alias}
        ...  AND  Log  LTE IOT cell ${LTE_IOT_cell_id} status:\n - ${CELL_state_blocked}  console=True
        ...  AND  Append To List  ${LTE_IOT_cell_id_blocked_list}  ${LTE_IOT_cell_id}
    END

    ${NR_cell_id_blocked_count}=  Get Length  ${NR_cell_id_blocked_list}
    ${LTE_cell_id_blocked_count}=  Get Length  ${LTE_cell_id_blocked_list}
    ${LTE_IOT_cell_id_blocked_count}=  Get Length  ${LTE_IOT_cell_id_blocked_list}
    ${FID49_alarm_count}=  Evaluate  ${NR_cell_id_blocked_count} + ${LTE_cell_id_blocked_count} + ${LTE_IOT_cell_id_blocked_count}

    Set Test Variable  ${${alias}_NR_cell_id_blocked_list}  ${NR_cell_id_blocked_list}
    Set Test Variable  ${${alias}_LTE_cell_id_blocked_list}  ${LTE_cell_id_blocked_list}
    Set Test Variable  ${${alias}_LTE_IOT_cell_id_blocked_list}  ${LTE_IOT_cell_id_blocked_list}
    Set Test Variable  ${${alias}_FID49_alarm_count}  ${FID49_alarm_count}

    ${BTS_EXPECTED_ALARMS}=  Prepare expected alarms list  ${${alias.upper()}_EXPECTED_ALARMS_49}  ${FID49_alarm_count}
    ${BTS_IGNORED_ALARMS}=  Combine Lists  ${${alias.upper()}_IGNORED_ALARMS}  ${${alias.upper()}_IGNORED_ALARMS_DURING_ACTION}

    Log  Check BTS ${alias} alarms:  console=True
    Log  BTS ${alias} "Cell Blocked (49)" alarm, expected number: ${FID49_alarm_count}  console=True
    Get and Check Alarms SOAM  alias=${alias}  poll_interval=5s  expected_alarms=${BTS_EXPECTED_ALARMS}  ignored_alarms=${BTS_IGNORED_ALARMS}
    ...  critical_alarms=${${alias.upper()}_CRITICAL_ALARMS}
    Log  BTS ${alias} "Cell Blocked (49)" alarm, found number: ${FID49_alarm_count}, as expected  console=True
    Log  BTS ${alias} site - expected, ignored and critical alarms checked  console=True

Perform Lock cells on BTS
    [Arguments]  ${alias}

    ${BTS_label}=  Get From Dictionary  ${BTS_alias_label_dict}  ${alias}
    ${NR_cell_id_lock_count}=  Get Length  ${${BTS_label}_NR_cell_id_lock_list}
    ${LTE_cell_id_lock_count}=  Get Length  ${${BTS_label}_LTE_cell_id_lock_list}

    Return From Keyword If  ${NR_cell_id_lock_count} == 0 and ${LTE_cell_id_lock_count} == 0

    ${NR_cell_id_locked_list}=  Create List
    ${LTE_cell_id_locked_list}=  Create List
    ${LTE_IOT_cell_id_locked_list}=  Create List

    FOR  ${cell_id}  IN  @{${BTS_label}_NR_cell_id_lock_list}
        Log  ***** Perform Lock operation on NR cell ${cell_id} from BTS ${alias} *****  console=True

        coam.Lock  dist_name=${cell_id}  timeout=${CELL_MAX_WAIT_TIME}  connection=${alias}

        ${CELL_state_check}=  Set Variable If  '${cell_id}' in ${${alias}_NR_cell_id_blocked_list}  ${CELL_state_blocked_locked_check}
        ...  ${CELL_state_locked_check}
        ${CELL_state}=  Set Variable If  '${cell_id}' in ${${alias}_NR_cell_id_blocked_list}  ${CELL_state_blocked_locked}  ${CELL_state_locked}
        Assert  class_name=NRCEL  id=${cell_id}  parameters=${CELL_state_check}  timeout=${CELL_MAX_WAIT_TIME}  connection=${alias}
        Log  NR cell ${cell_id} status:\n - ${CELL_state}  console=True

        Append To List  ${NR_cell_id_locked_list}  ${cell_id}
    END

    FOR  ${cell_id}  IN  @{${BTS_label}_LTE_cell_id_lock_list}
        Log  ***** Perform Lock operation on LTE cell ${cell_id} from BTS ${alias} *****  console=True

        coam.Lock  dist_name=${cell_id}  timeout=${CELL_MAX_WAIT_TIME}  connection=${alias}

        ${CELL_state_check}=  Set Variable If  '${cell_id}' in ${${alias}_LTE_cell_id_blocked_list}  ${CELL_state_blocked_locked_check}
        ...  ${CELL_state_locked_check}
        ${CELL_state}=  Set Variable If  '${cell_id}' in ${${alias}_LTE_cell_id_blocked_list}  ${CELL_state_blocked_locked}  ${CELL_state_locked}
        Assert  class_name=LNCEL  id=${cell_id}  parameters=${CELL_state_check}  timeout=${CELL_MAX_WAIT_TIME}  connection=${alias}
        Log  LTE cell ${cell_id} status:\n - ${CELL_state}  console=True

        Append To List  ${LTE_cell_id_locked_list}  ${cell_id}

        ${LTE_IOT_cell_status}=  Run Keyword And Return Status  Dictionary Should Contain Key  ${${alias}_LTE_IOT_cell_mapping_dict}  ${cell_id}
        Continue For Loop If  not ${LTE_IOT_cell_status}

        ${LTE_IOT_cell_id}=  Get From Dictionary  ${${alias}_LTE_IOT_cell_mapping_dict}  ${cell_id}
        ${CELL_state_check}=  Set Variable If  '${LTE_IOT_cell_id}' in ${${alias}_LTE_IOT_cell_id_blocked_list}
        ...  ${CELL_state_blocked_locked_check}  ${CELL_state_locked_check}
        ${CELL_state}=  Set Variable If  '${LTE_IOT_cell_id}' in ${${alias}_LTE_IOT_cell_id_blocked_list}  ${CELL_state_blocked_locked}
        ...  ${CELL_state_locked}

        Run Keyword If  '${LTE_IOT_cell_id}' != 'None'  Run Keywords
        ...  Assert  class_name=LNCEL  id=${LTE_IOT_cell_id}  parameters=${CELL_state_check}  timeout=${CELL_MAX_WAIT_TIME}  connection=${alias}
        ...  AND  Log  LTE IOT cell ${LTE_IOT_cell_id} status:\n - ${CELL_state}  console=True
        ...  AND  Append To List  ${LTE_IOT_cell_id_locked_list}  ${LTE_IOT_cell_id}
    END

    Set Test Variable  ${${alias}_NR_cell_id_locked_list}  ${NR_cell_id_locked_list}
    Set Test Variable  ${${alias}_LTE_cell_id_locked_list}  ${LTE_cell_id_locked_list}
    Set Test Variable  ${${alias}_LTE_IOT_cell_id_locked_list}  ${LTE_IOT_cell_id_locked_list}

    ${FID49_alarm_count}=  Get Variable Value  ${${alias}_FID49_alarm_count}  0
    ${BTS_EXPECTED_ALARMS}=  Prepare expected alarms list  ${${alias.upper()}_EXPECTED_ALARMS_49}  ${FID49_alarm_count}
    ${BTS_IGNORED_ALARMS}=  Combine Lists  ${${alias.upper()}_IGNORED_ALARMS}  ${${alias.upper()}_IGNORED_ALARMS_DURING_ACTION}

    Log  Check BTS ${alias} alarms:  console=True
    Run Keyword If  ${FID49_alarm_count} > 0
    ...  Log  BTS ${alias} "Cell Blocked (49)" alarm, expected number: ${FID49_alarm_count}  console=True
    Get and Check Alarms SOAM  alias=${alias}  poll_interval=5s  expected_alarms=${BTS_EXPECTED_ALARMS}  ignored_alarms=${BTS_IGNORED_ALARMS}
    ...  critical_alarms=${${alias.upper()}_CRITICAL_ALARMS}
    Run Keyword If  ${FID49_alarm_count} > 0
    ...  Log  BTS ${alias} "Cell Blocked (49)" alarm, found number: ${FID49_alarm_count}, as expected  console=True
    Log  BTS ${alias} site - expected, ignored and critical alarms checked  console=True

Perform Reset Site on BTS
    [Arguments]  ${alias}

    ${NR_cell_id_unblocked_list}=  Create List
    ${LTE_cell_id_unblocked_list}=  Create List

    Log  ***** Perform Reset Site operation on BTS ${alias} *****  console=True
    RFS Site Reset  wait_for_reconnection=True  connection=${alias}

    Log  Check BTS ${alias} states and alarms after Reset Site operation on BTS ${alias}:  console=True
    Run Keyword If  ${${alias}_NR_CELL_id_count} > 0
    ...  Log  Check BTS ${alias} NR cells status:   console=True
    FOR  ${cell_id}  IN  @{${alias}_NR_CELL_id_list}
        ${CELL_state_check}=  Set Variable If  '${cell_id}' in ${${alias}_NR_cell_id_locked_list}  ${CELL_state_locked_check}
        ...  ${CELL_state_enabled_check}
        ${CELL_state}=  Set Variable If  '${cell_id}' in ${${alias}_NR_cell_id_locked_list}  ${CELL_state_locked}  ${CELL_state_enabled}
        Assert  class_name=NRCEL  id=${cell_id}  parameters=${CELL_state_check}  timeout=${BTS_MAX_WAIT_TIME}  connection=${alias}
        Log  NR cell ${cell_id} status:\n - ${CELL_state}  console=True

        Remove Values From List  ${${alias}_NR_cell_id_blocked_list}  ${cell_id}
    END

    Run Keyword If  ${${alias}_LTE_CELL_id_count} > 0
    ...  Log  Check BTS ${alias} LTE cells status:  console=True
    FOR  ${cell_id}  IN  @{${alias}_LTE_CELL_id_list}
        ${CELL_state_check}=  Set Variable If  '${cell_id}' in ${${alias}_LTE_cell_id_locked_list}  ${CELL_state_locked_check}
        ...  ${CELL_state_enabled_check}
        ${CELL_state}=  Set Variable If  '${cell_id}' in ${${alias}_LTE_cell_id_locked_list}  ${CELL_state_locked}  ${CELL_state_enabled}
        Assert  class_name=LNCEL  id=${cell_id}  parameters=${CELL_state_check}  timeout=${BTS_MAX_WAIT_TIME}  connection=${alias}
        Log  LTE cell ${cell_id} status:\n - ${CELL_state}  console=True

        Remove Values From List  ${${alias}_LTE_cell_id_blocked_list}  ${cell_id}

        ${LTE_IOT_cell_status}=  Run Keyword And Return Status  Dictionary Should Contain Key  ${${alias}_LTE_IOT_cell_mapping_dict}  ${cell_id}
        Continue For Loop If  not ${LTE_IOT_cell_status}

        ${LTE_IOT_cell_id}=  Get From Dictionary  ${${alias}_LTE_IOT_cell_mapping_dict}  ${cell_id}
        ${CELL_state_check}=  Set Variable If  '${LTE_IOT_cell_id}' in ${${alias}_LTE_IOT_cell_id_locked_list}  ${CELL_state_locked_check}
        ...  ${CELL_state_enabled_check}
        ${CELL_state}=  Set Variable If  '${LTE_IOT_cell_id}' in ${${alias}_LTE_IOT_cell_id_locked_list}  ${CELL_state_locked}  ${CELL_state_enabled}

        Run Keyword If  '${LTE_IOT_cell_id}' != 'None'  Run Keywords
        ...  Assert  class_name=LNCEL  id=${LTE_IOT_cell_id}  parameters=${CELL_state_check}  timeout=${CELL_MAX_WAIT_TIME}  connection=${alias}
        ...  AND  Log  LTE IOT cell ${LTE_IOT_cell_id} status:\n - ${CELL_state}  console=True
        ...  AND  Remove Values From List  ${${alias}_LTE_IOT_cell_id_blocked_list}  ${LTE_IOT_cell_id}
    END

    ${BTS_IGNORED_ALARMS}=  Combine Lists  ${${alias.upper()}_IGNORED_ALARMS}  ${${alias.upper()}_IGNORED_ALARMS_DURING_ACTION}

    Log  Check BTS ${alias} alarms:  console=True
    Get and Check Alarms SOAM  alias=${alias}  expected_alarms=@{EMPTY}  ignored_alarms=${BTS_IGNORED_ALARMS}
    ...  critical_alarms=${${alias.upper()}_CRITICAL_ALARMS}
    Log  BTS ${alias} site - expected, ignored and critical alarms checked  console=True

Perform Unblock cells on BTS
    [Arguments]  ${alias}

    ${NR_cell_id_blocked_count}=  Get Length  ${${alias}_NR_cell_id_blocked_list}
    ${LTE_cell_id_blocked_count}=  Get Length  ${${alias}_LTE_cell_id_blocked_list}

    Return From Keyword If  ${NR_cell_id_blocked_count} == 0 and ${LTE_cell_id_blocked_count} == 0

    FOR  ${cell_id}  IN  @{${alias}_NR_cell_id_blocked_list}
        Log  ***** Perform Unblock operation on NR cell ${cell_id} from BTS ${alias} *****  console=True

        coam.Unblock Cell  dist_name=${cell_id}  timeout=${CELL_MAX_WAIT_TIME}  connection=${alias}

        ${CELL_state_check}=  Set Variable If  '${cell_id}' in ${${alias}_NR_cell_id_locked_list}  ${CELL_state_locked_check}
        ...  ${CELL_state_enabled_check}
        ${CELL_state}=  Set Variable If  '${cell_id}' in ${${alias}_NR_cell_id_locked_list}  ${CELL_state_locked}  ${CELL_state_enabled}
        Assert  class_name=NRCEL  id=${cell_id}  parameters=${CELL_state_check}  timeout=${CELL_MAX_WAIT_TIME}  connection=${alias}
        Log  NR cell ${cell_id} status:\n - ${CELL_state}  console=True
    END

    FOR  ${cell_id}  IN  @{${alias}_LTE_cell_id_blocked_list}
        Log  ***** Perform Unblock operation on LTE cell ${cell_id} from BTS ${alias} *****  console=True

        coam.Unblock Cell  dist_name=${cell_id}  timeout=${CELL_MAX_WAIT_TIME}  connection=${alias}

        ${CELL_state_check}=  Set Variable If  '${cell_id}' in ${${alias}_LTE_cell_id_locked_list}  ${CELL_state_locked_check}
        ...  ${CELL_state_enabled_check}
        ${CELL_state}=  Set Variable If  '${cell_id}' in ${${alias}_LTE_cell_id_locked_list}  ${CELL_state_locked}  ${CELL_state_enabled}
        Assert  class_name=LNCEL  id=${cell_id}  parameters=${CELL_state_check}  timeout=${CELL_MAX_WAIT_TIME}  connection=${alias}
        Log  LTE cell ${cell_id} status:\n - ${CELL_state}  console=True

        ${LTE_IOT_cell_status}=  Run Keyword And Return Status  Dictionary Should Contain Key  ${${alias}_LTE_IOT_cell_mapping_dict}  ${cell_id}
        Continue For Loop If  not ${LTE_IOT_cell_status}

        ${LTE_IOT_cell_id}=  Get From Dictionary  ${${alias}_LTE_IOT_cell_mapping_dict}  ${cell_id}
        ${CELL_state_check}=  Set Variable If  '${LTE_IOT_cell_id}' in ${${alias}_LTE_IOT_cell_id_locked_list}  ${CELL_state_locked_check}
        ...  ${CELL_state_enabled_check}
        ${CELL_state}=  Set Variable If  '${LTE_IOT_cell_id}' in ${${alias}_LTE_IOT_cell_id_locked_list}  ${CELL_state_locked}  ${CELL_state_enabled}

        Run Keyword If  '${LTE_IOT_cell_id}' != 'None'  Run Keywords
        ...  Assert  class_name=LNCEL  id=${LTE_IOT_cell_id}  parameters=${CELL_state_check}  timeout=${CELL_MAX_WAIT_TIME}
        ...  connection=${alias}
        ...  AND  Log  LTE IOT cell ${LTE_IOT_cell_id} status:\n - ${CELL_state}  console=True
    END

    ${BTS_IGNORED_ALARMS}=  Combine Lists  ${${alias.upper()}_IGNORED_ALARMS}  ${${alias.upper()}_IGNORED_ALARMS_DURING_ACTION}

    Log  Check BTS ${alias} alarms:  console=True
    Get and Check Alarms SOAM  alias=${alias}  expected_alarms=@{EMPTY}  ignored_alarms=${BTS_IGNORED_ALARMS}
    ...  critical_alarms=${${alias.upper()}_CRITICAL_ALARMS}
    Log  BTS ${alias} site - expected, ignored and critical alarms checked  console=True

Perform Unlock cells on BTS
    [Arguments]  ${alias}

    ${NR_cell_id_locked_count}=  Get Length  ${${alias}_NR_cell_id_locked_list}
    ${LTE_cell_id_locked_count}=  Get Length  ${${alias}_LTE_cell_id_locked_list}

    Return From Keyword If  ${NR_cell_id_locked_count} == 0 and ${LTE_cell_id_locked_count} == 0

    FOR  ${cell_id}  IN  @{${alias}_NR_cell_id_locked_list}
        Log  ***** Perform Unlock operation on NR cell ${cell_id} from BTS ${alias} *****  console=True

        coam.Unlock  dist_name=${cell_id}  timeout=${CELL_MAX_WAIT_TIME}  connection=${alias}

        Assert  class_name=NRCEL  id=${cell_id}  parameters=${CELL_state_enabled_check}  timeout=${CELL_MAX_WAIT_TIME}  connection=${alias}
        Log  NR cell ${cell_id} status:\n - ${CELL_state_enabled}  console=True
    END

    FOR  ${cell_id}  IN  @{${alias}_LTE_cell_id_locked_list}
        Log  ***** Perform Unlock operation on LTE cell ${cell_id} from BTS ${alias} *****  console=True

        coam.Unlock  dist_name=${cell_id}  timeout=${CELL_MAX_WAIT_TIME}  connection=${alias}

        Assert  class_name=LNCEL  id=${cell_id}  parameters=${CELL_state_enabled_check}  timeout=${CELL_MAX_WAIT_TIME}  connection=${alias}
        Log  LTE cell ${cell_id} status:\n - ${CELL_state_enabled}  console=True

        ${LTE_IOT_cell_status}=  Run Keyword And Return Status  Dictionary Should Contain Key  ${${alias}_LTE_IOT_cell_mapping_dict}  ${cell_id}
        Continue For Loop If  not ${LTE_IOT_cell_status}

        ${LTE_IOT_cell_id}=  Get From Dictionary  ${${alias}_LTE_IOT_cell_mapping_dict}  ${cell_id}

        Run Keyword If  '${LTE_IOT_cell_id}' != 'None'  Run Keywords
        ...  Assert  class_name=LNCEL  id=${LTE_IOT_cell_id}  parameters=${CELL_state_enabled_check}  timeout=${CELL_MAX_WAIT_TIME}
        ...  connection=${alias}
        ...  AND  Log  LTE IOT cell ${LTE_IOT_cell_id} status:\n - ${CELL_state_enabled}  console=True
    END

    ${BTS_IGNORED_ALARMS}=  Combine Lists  ${${alias.upper()}_IGNORED_ALARMS}  ${${alias.upper()}_IGNORED_ALARMS_DURING_ACTION}

    Log  Check BTS ${alias} alarms:  console=True
    Get and Check Alarms SOAM  alias=${alias}  expected_alarms=@{EMPTY}  ignored_alarms=${BTS_IGNORED_ALARMS}
    ...  critical_alarms=${${alias.upper()}_CRITICAL_ALARMS}
    Log  BTS ${alias} site - expected, ignored and critical alarms checked  console=True

Check if all BTS cells are unblocked
    FOR  ${alias}  IN  @{alias_list}
        Admin Check if BTS cells are unblocked  ${alias}
    END

Check if all BTS cells are unlocked
    FOR  ${alias}  IN  @{alias_list}
        Admin Check if BTS cells are unlocked  ${alias}
    END

Particular Teardown
    Run Keyword And Continue On Failure  Check if all BTS cells are unblocked
    Run Keyword And Continue On Failure  Check if all BTS cells are unlocked

TC Setup
    ${tech_preset_list}=  Create List  SBTS  SBTS  SBTS  SBTS
    Common Test Setup  preset_techs=${tech_preset_list}  common_sbts=${TRUE}  infomodelSetup=${FALSE}

TC Teardown
    Common Test Teardown
