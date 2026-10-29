*** Settings ***
Documentation    TC__CBTS_SBTS__STATE__Secondary_Controller_SharedRM_Reset
Variables    tc_variables/cbts_sbts__state__secondary_controller_sharedrm_reset_alarms_definitions.py
Resource    ../../resources/rfs_frame_rfs_soam_taf.robot

*** Variables ***
${REPEAT_COUNTER}                  3    # Number of Reset shared RMOD operations from BTS secondary controller, default value 3
${SHARED_RMOD_SERIAL_NUMBER_LIST}  ALL  # Shared RMOD serial number list on which reset operation will be performed. Possible values (by default ALL):
                                        # - ALL: action will be performed on all shared RMOD
                                        # - list of selected shared RMOD serial number separated by comma.
${RMOD_RESET_MAX_WAIT_TIME}       900   # Maximum time to wait for all cells mapped on impacted RMOD to be enabled after reset operation
${RMOD_RESET_WRN_THR}             180   # Time (secs) spent between first cell down to last cell up on RMOD
                                        # Default value: in accordance with KPI51a specifications
${GRACEFUL_CELL_SHUTDOWN_SBTS}    True  # Graceful Cell Shutdown SBTS: True or False; default value: True
${GRACEFUL_CELL_SHUTDOWN_CBTS}    True  # Graceful Cell Shutdown CBTS: True or False; default value: True
${LTE_IOT_check}                  True  # Only for classical BTS RAT LTE. Specify in case of configured LTE IOT cells if their status
                                        # will be checked (True) or skipped (False) due to RMOD Reset. By default True

*** Keywords ***
TC__CBTS_SBTS__STATE__Secondary_Controller_SharedRM_Reset
     [Documentation]
    ...  [CASE LINK]: https://jiradc.ext.net.nokia.com/browse/TAT-28516
    ...
    ...  *****************
    ...  Basic information
    ...  *****************
    ...  CBTS-SBTS test case for Reset shared RMOD from BTS secondary controller, - x times sequence.
    ...  x - value of REPEAT_COUNTER parameter (default: 3)
    ...  The main steps performed for the test are:
    ...  - check initial state and alarms for all BTS
    ...  - get all BTS info for configured items: BTS role (primary/secondary controller per BTS), RMOD sharing info info, RAT cells (per BTS alias)
    ...  - perform Reset shared RMOD from BTS secondary controller checking states and alarms
    ...  - check for SBTS KPI51a info from IMS file
    ...  - check final state and alarms for for all BTS
    ...  Pass criteria: Reset shared RMOD from BTS secondary controllern works as expected; states and alarms are as expected
    ...
    ...  ******************
    ...  History of changes
    ...  ******************
    ...  - 03.02.2025 - https://jiradc.ext.net.nokia.com/browse/TAT-28516 - New TC - CB012220 CBTS_SBTS_Secondary_Controller_SharedRM_Reset
    ...  - 27.05.2025 - https://jiradc.ext.net.nokia.com/browse/TAT-29295 - Variable '${Master_active_SW_version_initial}' not found when created
    ...  kpi and due to this TCs are failing
    ...  - 04.08.2025 - https://jiradc.ext.net.nokia.com/browse/TAT-29655 - Wrong variable ${new_ADMIN_instance}
    ...

    Set Tags    CA-STATE    OWNER-liana.feresc@nokia.com   AUTHOR-dinu.olariu@nokia.com    PHASE-CRT    SW-CBTS24R3,SBTS24R3

    TC Preconditions
    Step 1: Check initial all BTS states
    Step 2: Check initial all BTS alarms
    Step 3: Get all BTS info for configured items
    FOR  ${INDEX}  IN RANGE  1  ${REPEAT_COUNTER}+1
        Log  ==============================================================================  console=True
        Log  Start Cycle ${INDEX} of ${REPEAT_COUNTER}  console=True
        Log  ==============================================================================  console=True
        Step 4: Perform Reset shared RMOD on cloud BTS for iteration ${INDEX}
        Step 5: Perform Reset shared RMOD on classical BTS for iteration ${INDEX}
        Step 6: Check final all BTS states
        Step 7: Check final all BTS alarms
        Step 8: Check final number and state of Cells and RMs
    END

    [Teardown]  Particular Teardown

TC Preconditions

    ${BTS_alias_RMOD_sn_dict}  ${RMOD_sn_BTS_alias_dict}  ${shared_RMOD_sn_list}  ${dedicated_RMOD_sn_list}=  Get all BTS RMOD sharing info
    Set Test Variable  ${BTS_alias_RMOD_sn_dict}
    Set Test Variable  ${RMOD_sn_BTS_alias_dict}
    Sort List  ${shared_RMOD_sn_list}
    Set Test Variable  ${shared_RMOD_sn_list}

    Run Keyword If  '${SHARED_RMOD_SERIAL_NUMBER_LIST}' != 'ALL'  Check shared RMOD serial number list

    Check feature CB007878 status on both BTS for shared RMOD

    Log  ==================================================  console=True
    Log  RMOD serial number list selected for Reset action: ${shared_RMOD_sn_list}  console=True
    Log  ==================================================  console=True

Step ${index}: Check ${when} all BTS states
    [Documentation]
    ...  BTS states is checked as follows:
    ...  - CBTS CU - Operational State: Enabled
    ...  - CBTS VDUs - Operational State: OnAir
    ...  - SBTS RAT - Procedural State: OnAir
    ...  - SBTS BTS - Procedural State: OnAir, Blocking State: Unblocked

    Log  Step ${index}: Check ${when} all BTS states  console=True

    FOR  ${alias}  IN  @{alias_list}

        Run Keyword If  '${${alias.upper()}}[${alias.upper()}_TECH]' == 'CBTS'  Run Keywords
        ...  Log  ***** Check ${when} cloud BTS ${alias} state *****  console=True
        ...  AND  Check CBTS CU VDU Operational State  alias=${alias}  timeout=600
        ...  AND  Log  ${alias} BTS site - CU Operational State: Enabled, VDUs Operational State: OnAir  console=True
        ...  ELSE IF  '${${alias.upper()}}[${alias.upper()}_TECH]' in ['NR', 'LTE', 'SBTS']  Run Keywords
        ...  Log  ***** Check ${when} classical BTS ${alias} state *****  console=True
        ...  AND  Admin Check BTS RAT Procedural State  alias=${alias}  timeout=600
        ...  AND  Admin Check BTS Procedural and Blocking states  exp_pro_state=${OnAir_}  exp_blk_state=${Unblocked_}  timeout=600  alias=${alias}
        ...  AND  Log  ${alias} BTS site - Procedural State: OnAir, Blocking State: Unblocked  console=True

    END

Step ${index}: Check ${when} all BTS alarms
    [Documentation]
    ...  BTS alarms are compared with values from expected, ignored and critical alarms lists.

    Log  Step ${index}: Check ${when} all BTS alarms  console=True

    FOR  ${alias}  IN  @{alias_list}

        Run Keyword If  '${${alias.upper()}}[${alias.upper()}_TECH]' == 'CBTS'  Run Keywords
        ...  Log  ***** Check ${when} cloud BTS ${alias} alarms *****  console=True
        ...  AND  Get and Check Alarms CBTS  alias=${alias}
        ...  ELSE IF  '${${alias.upper()}}[${alias.upper()}_TECH]' in ['NR', 'LTE', 'SBTS']  Run Keywords
        ...  Log  ***** Check ${when} classical BTS ${alias} alarms *****  console=True
        ...  AND  Get and Check Alarms SOAM  alias=${alias}  expected_alarms=@{EMPTY}  ignored_alarms=${${alias.upper()}_IGNORED_ALARMS}
        ...  critical_alarms=${${alias.upper()}_CRITICAL_ALARMS}

        Log  ${alias} BTS site - expected, ignored and critical alarms checked  console=True

    END

Step ${index}: Get all BTS info for configured items
    [Documentation]
    ...  Get all BTS info about following items:
    ...  - list of shared RM serial number configured on BTS primary controller (per BTS alias)
    ...  - list of shared RM serial number configured on BTS secondary controller (per BTS alias)
    ...  - list of RAT cells (per BTS alias)

    Log  Step ${index}: Get all BTS info for configured items  console=True

    ${all_BTS_RMOD_id_CELL_ids_info}=  Get all BTS Cells mapped on RMOD info
    Set Test Variable  ${all_BTS_RMOD_id_CELL_ids_info}

    ${all_BTS_controller_role_RMOD_sn_list}=  Get all BTS controller role for configured RMOD from SCF
    Set Test Variable  ${all_BTS_controller_role_RMOD_sn_list}

    Set Test Variable  ${CBTS_RMOD_state_disabled}
    ...  Operational state=Disabled, Availability status=NotInstalled|Offline, Administrative state=Unlocked
    Set Test Variable  ${CBTS_RMOD_state_enabled}  Operational state=Enabled, Availability status=Online, Administrative state=Unlocked
    Set Test Variable  ${CBTS_CELL_state_disabled}
    ...  Operational state=Disabled, Availability status=Failed|Offline, Administrative state=Unlocked, Blocking state=Unblocked
    Set Test Variable  ${CBTS_CELL_state_enabled}
    ...  Operational state=Enabled, Availability status=Online, Administrative state=Unlocked, Blocking state=Unblocked
    Set Test Variable  ${SBTS_RMOD_state_disabled_check}
    ...  operationalState=${Disabled_}, availabilityStatus=${NotInstalled_Offline_}, administrativeState=${Unlocked_}
    Set Test Variable  ${SBTS_RMOD_state_disabled}
    ...  operationalState=Disabled, availabilityStatus=NotInstalled|Offline, administrativeState=Unlocked
    Set Test Variable  ${SBTS_RMOD_state_enabled_check}  operationalState=${Enabled_}, administrativeState=${Unlocked_}
    Set Test Variable  ${SBTS_RMOD_state_enabled}  operationalState=Enabled, administrativeState=Unlocked
    Set Test Variable  ${SBTS_CELL_state_enabled_check}  operationalState=${Enabled_}, blockingState=${Unblocked_}
    Set Test Variable  ${SBTS_CELL_state_enabled}  operationalState=Enabled, blockingState=Unblocked

    FOR  ${alias}  IN  @{alias_list}
        ${alias_tech}=  Get From Dictionary  ${${alias.upper()}}  ${alias.upper()}_TECH
        Run Keyword If  '${alias_tech}' in ['NR', 'LTE', 'SBTS']
        ...  Get SBTS Cell info  ${alias}
    END

Step ${index}: Perform Reset shared RMOD on cloud BTS for iteration ${CYCLE}
    Log  Step ${index}: Perform Reset shared RMOD on cloud BTS for iteration ${CYCLE}  console=True

    FOR  ${alias}  IN  @{alias_list}

        Continue For Loop If  '${${alias.upper()}}[${alias.upper()}_TECH]' != 'CBTS'
        Log  ***** Perform Reset shared RMOD on ${alias} BTS *****  console=True

        Perform Reset CBTS VDU shared RMOD  ${alias}  ${CYCLE}

    END

Step ${index}: Perform Reset shared RMOD on classical BTS for iteration ${CYCLE}
    Log  Step ${index}: Perform Reset shared RMOD on classical BTS for iteration ${CYCLE}  console=True

    FOR  ${alias}  IN  @{alias_list}

        Continue For Loop If  '${${alias.upper()}}[${alias.upper()}_TECH]' not in ['NR', 'LTE', 'SBTS']
        Log  ***** Perform Reset shared RMOD on ${alias} BTS *****  console=True

        Perform Reset SBTS shared RMOD  ${alias}  ${CYCLE}

    END

Step ${index}: Check final number and state of Cells and RMs
    [Documentation]
    ...  Following checks are performed:
    ...  - number of configured cells and radio modules in SCF are properly mapped on BTS running view ADMIN
    ...  - check cells states
    ...  - check radio modules states

    Log  Step ${index}: Check final number and state of Cells and RMs  console=True
    RFS Test Case Final Checks

Get SBTS Cell info
    [Arguments]  ${alias}

    ${NR_CELL_list}=  Get Ids For All  class_name=NRCEL  connection=${alias}
    ${LTE_CELL_list}=  Get Ids For All  class_name=LNCEL  connection=${alias}
    ${WCDMA_CELL_list}=  Get Ids For All  class_name=WNCEL  connection=${alias}
    ${GSM_CELL_list}=  Get Ids For All  class_name=GNCEL  connection=${alias}
    Sort List  ${NR_CELL_list}
    Sort List  ${LTE_CELL_list}
    Sort List  ${WCDMA_CELL_list}
    Sort List  ${GSM_CELL_list}
    ${LTE_HOST_CELL_ID_LIST}  ${LTE_IOT_CELL_ID_LIST}  ${LTE_IOT_SA_CELL_ID_LIST}=  Admin Get LTE HOST and IOT Cell(s) Id list
    ...  CELL_list=${LTE_CELL_list}  alias=${alias}
    ${LTE_cell_IOT_mapping_dict}=  Run Keyword If  ${LTE_CELL_list}  Admin Get LTE CELL IOT mapping list  alias=${alias}
    Set Test Variable  ${${alias}_NR_CELL_list}  ${NR_CELL_list}
    Set Test Variable  ${${alias}_LTE_CELL_list}  ${LTE_HOST_CELL_ID_LIST}
    Set Test Variable  ${${alias}_WCDMA_CELL_list}  ${WCDMA_CELL_list}
    Set Test Variable  ${${alias}_GSM_CELL_list}  ${GSM_CELL_list}
    Set Test Variable  ${${alias}_LTE_cell_IOT_mapping_dict}  ${LTE_cell_IOT_mapping_dict}

Check shared RMOD serial number list
    ${shared_RMOD_sn_list_strip}=  Replace String  ${SHARED_RMOD_SERIAL_NUMBER_LIST}  ${SPACE}  ${EMPTY}
    ${custom_shared_RMOD_sn_list}=  Split String  ${shared_RMOD_sn_list_strip}  ,
    ${RMOD_sn_check}=  Set Variable  True
    ${RMOD_sn_invalid_list}=  Create List

    FOR  ${item}  IN  @{custom_shared_RMOD_sn_list}

        ${RMOD_sn_check}=  Set Variable If  '${item}' not in ${shared_RMOD_sn_list}  False  ${RMOD_sn_check}
        Run Keyword If  '${item}' not in ${shared_RMOD_sn_list}  Append To List  ${RMOD_sn_invalid_list}  ${item}

    END

    Run Keyword If  '${RMOD_sn_check}' == 'False'  Run Keywords
    ...  Log Long String  Following selected shared RMOD serial number values are not valid: ${RMOD_sn_invalid_list}. Please select values for test
    ...  argument \${SHARED_RMOD_SERIAL_NUMBER_LIST} from configured shared RMOD: ${shared_RMOD_sn_list} or let default value: ALL  console=True
    ...  AND  Fail  Improper value for argument!

    Sort List  ${custom_shared_RMOD_sn_list}
    Set Test Variable  ${shared_RMOD_sn_list}  ${custom_shared_RMOD_sn_list}

Check feature CB007878 status on both BTS for shared RMOD

    ${CB007878_shared_RMOD_sn_valid_list}=  Create List
    ${CB007878_shared_RMOD_sn_invalid_list}=  Create List
    ${CB007878_shared_RMOD_sn_invalid_list}=  Create List
    Set Test Variable  ${CB007878_shared_RMOD_sn_valid_list}
    Set Test Variable  ${CB007878_shared_RMOD_sn_invalid_list}

    Log  Check feature CB007878 settings for shared RMOD list: ${shared_RMOD_sn_list}  console=True

    FOR  ${RMOD_sn}  IN  @{shared_RMOD_sn_list}

        ${RMOD_BTS_alias_list}=  Get From Dictionary  ${RMOD_sn_BTS_alias_dict}  ${RMOD_sn}
        Check feature CB007878 status  ${RMOD_sn}  ${RMOD_BTS_alias_list}

    END

    ${CB007878_shared_RMOD_sn_valid_list}=  Remove Duplicates  ${CB007878_shared_RMOD_sn_valid_list}
    ${CB007878_shared_RMOD_sn_invalid_list}=  Remove Duplicates  ${CB007878_shared_RMOD_sn_invalid_list}
    ${CB007878_RMOD_sn_valid_count}=  Get Length  ${CB007878_shared_RMOD_sn_valid_list}
    ${CB007878_RMOD_sn_invalid_count}=  Get Length  ${CB007878_shared_RMOD_sn_invalid_list}

    Run Keyword If  '${SHARED_RMOD_SERIAL_NUMBER_LIST}' == 'ALL' and ${CB007878_RMOD_sn_valid_count} == 0  Run Keywords
    ...  Log Long String  Feature CB007878 is not enabled for any of configured shared RMOD. Please enable feature CB007878 for at least one item
    ...  from configured shared RMOD list: ${shared_RMOD_sn_list}  console=True
    ...  AND  Fail  Feature CB007878 is not enabled for any of configured shared RMOD!

    Run Keyword If  '${SHARED_RMOD_SERIAL_NUMBER_LIST}' != 'ALL' and ${CB007878_RMOD_sn_invalid_count} > 0  Run Keywords
    ...  Log Long String  Feature CB007878 is not enabled for all items from selected shared RMOD list: ${shared_RMOD_sn_list}. Please enable
    ...  feature CB007878 for following selected shared RMOD: ${CB007878_shared_RMOD_sn_invalid_list}  console=True
    ...  AND  Fail  Feature CB007878 is not enabled for all items from selected shared RMOD list!

    Set Test Variable  ${shared_RMOD_sn_list}  ${CB007878_shared_RMOD_sn_valid_list}
    Sort List  ${shared_RMOD_sn_list}

Check feature CB007878 status
    [Arguments]  ${RMOD_sn}  ${RMOD_BTS_alias_list}

    ${RMOD_sn_list}=  Create List  ${RMOD_sn}
    ${CB007878_shared_RMOD_info}=  Create List

    FOR  ${alias}  IN  @{RMOD_BTS_alias_list}

        ${BTS_feature_CB007878_dict}=  Run Keyword If  '${alias}' in ${alias_list}
        ...  Get feature CB007878 settings on classical BTS  RMOD_sn_list=${RMOD_sn_list}  alias=${alias}
        ...  ELSE
        ...  Get feature CB007878 settings on cloud BTS  RMOD_sn_list=${RMOD_sn_list}  vdu_alias=${alias}

        ${actSharedRUIndControl_info}=  Get From Dictionary  ${BTS_feature_CB007878_dict}  ${RMOD_sn}

        Log  - BTS ${alias} RMOD_${RMOD_sn} actSharedRUIndControl: ${actSharedRUIndControl_info}  console=True

        Append To List  ${CB007878_shared_RMOD_info}  ${actSharedRUIndControl_info}

    END

    ${CB007878_shared_RMOD_info}=  Remove Duplicates  ${CB007878_shared_RMOD_info}
    ${CB007878_status_shared_RMOD}=  Get Length  ${CB007878_shared_RMOD_info}

    Run Keyword If  ${CB007878_status_shared_RMOD} == 1 and '${CB007878_shared_RMOD_info[0]}' == 'true'
    ...  Append To List  ${CB007878_shared_RMOD_sn_valid_list}  ${RMOD_sn}
    ...  ELSE
    ...  Append To List  ${CB007878_shared_RMOD_sn_invalid_list}  ${RMOD_sn}

Perform Reset CBTS VDU shared RMOD
    [Arguments]  ${alias}  ${CYCLE}

    ${vdu_list}=  Set Variable  ${${alias.upper()}}[${alias.upper()}_VDU]

    FOR  ${index}  ${vdu_info}  IN ENUMERATE  @{vdu_list}

        ${vdu_alias}=  Set Variable  ${alias} VDU${index+1}

        ${VDU_controller_RMOD_sn_list}=  Get From Dictionary  ${all_BTS_controller_role_RMOD_sn_list}  ${vdu_alias}
        ${VDU_primary_controller_RMOD_sn_list}=  Get From Dictionary  ${VDU_controller_RMOD_sn_list}  BTS_primary_controller_RMOD_sn_list
        ${VDU_secondary_controller_RMOD_sn_list}=  Get From Dictionary  ${VDU_controller_RMOD_sn_list}  BTS_secondary_controller_RMOD_sn_list
        Sort List  ${VDU_primary_controller_RMOD_sn_list}
        Sort List  ${VDU_secondary_controller_RMOD_sn_list}
        ${VDU_primary_controller_RMOD_sn_count}=  Get Length  ${VDU_primary_controller_RMOD_sn_list}
        ${VDU_secondary_controller_RMOD_sn_count}=  Get Length  ${VDU_secondary_controller_RMOD_sn_list}

        Return From Keyword If  ${VDU_secondary_controller_RMOD_sn_count} == 0

        Set Test Variable  ${${vdu_alias}_primary_controller_RMOD_sn_list}  ${VDU_primary_controller_RMOD_sn_list}
        Set Test Variable  ${${vdu_alias}_secondary_controller_RMOD_sn_list}  ${VDU_secondary_controller_RMOD_sn_list}

        ${VDU_RMOD_sn_list}=  Get From Dictionary  ${BTS_alias_RMOD_sn_dict}  ${vdu_alias}
        Sort List  ${VDU_RMOD_sn_list}

        Reset CBTS VDU shared RMOD  ${VDU_RMOD_sn_list}  ${vdu_alias}  ${CYCLE}

    END

Perform Reset SBTS shared RMOD
    [Arguments]  ${alias}  ${CYCLE}

    ${BTS_controller_RMOD_sn_list}=  Get From Dictionary  ${all_BTS_controller_role_RMOD_sn_list}  ${alias}
    ${BTS_primary_controller_RMOD_sn_list}=  Get From Dictionary  ${BTS_controller_RMOD_sn_list}  BTS_primary_controller_RMOD_sn_list
    ${BTS_secondary_controller_RMOD_sn_list}=  Get From Dictionary  ${BTS_controller_RMOD_sn_list}  BTS_secondary_controller_RMOD_sn_list
    Sort List  ${BTS_primary_controller_RMOD_sn_list}
    Sort List  ${BTS_secondary_controller_RMOD_sn_list}
    ${BTS_primary_controller_RMOD_sn_count}=  Get Length  ${BTS_primary_controller_RMOD_sn_list}
    ${BTS_secondary_controller_RMOD_sn_count}=  Get Length  ${BTS_secondary_controller_RMOD_sn_list}

    Return From Keyword If  ${BTS_secondary_controller_RMOD_sn_count} == 0

    Set Test Variable  ${${alias}_primary_controller_RMOD_sn_list}  ${BTS_primary_controller_RMOD_sn_list}
    Set Test Variable  ${${alias}_secondary_controller_RMOD_sn_list}  ${BTS_secondary_controller_RMOD_sn_list}

    ${SBTS_RMOD_sn_list}=  Get From Dictionary  ${BTS_alias_RMOD_sn_dict}  ${alias}
    Sort List  ${SBTS_RMOD_sn_list}

    Reset SBTS shared RMOD  ${SBTS_RMOD_sn_list}  ${alias}  ${CYCLE}

Reset CBTS VDU shared RMOD
    [Arguments]  ${VDU_RMOD_sn_list}  ${vdu_alias}  ${CYCLE}

    FOR  ${item}  IN  @{VDU_RMOD_sn_list}

        Continue For Loop If  '${item}' not in ${shared_RMOD_sn_list} or '${item}' not in ${${vdu_alias}_secondary_controller_RMOD_sn_list}

        Reset shared RMOD on cloud BTS  ${item}  ${vdu_alias}  ${CYCLE}

    END

Reset SBTS shared RMOD
    [Arguments]  ${SBTS_RMOD_sn_list}  ${alias}  ${CYCLE}

    ${new_alias}=  Set Variable  reset_RMOD
    Start new ADMIN instance  alias=${alias}  new_alias=${new_alias}  connection_type=${connection_type_${alias}}

    FOR  ${item}  IN  @{SBTS_RMOD_sn_list}

        Continue For Loop If  '${item}' not in ${shared_RMOD_sn_list} or '${item}' not in ${${alias}_secondary_controller_RMOD_sn_list}

        Reset shared RMOD on classical BTS  ${item}  ${alias}  ${new_alias}  ${CYCLE}

    END

    [Teardown]  Teardown Admin  alias=${new_alias}

Reset shared RMOD on cloud BTS
    [Arguments]  ${RMOD_sn}  ${vdu_alias}  ${CYCLE}

    Get RMOD info from BTS  ${RMOD_sn}  ${vdu_alias}

    Log  ***** Perform "Reset" operation on shared RMOD ${RMOD_pn} with SN ${RMOD_sn} from ${vdu_alias} *****   console=True

    Get Current Date UTC info  initial
    Get Current Time  initial
    VDU Reset RMOD  rmods_list=${${vdu_alias}_RMOD_id_list}  timeout=${RMOD_RESET_MAX_WAIT_TIME}  vdu_connection=${vdu_alias}
    ...  graceful_cell_shutdown=${GRACEFUL_CELL_SHUTDOWN_CBTS}

    Log  Check ${vdu_alias} state and alarms during reset shared RMOD ${RMOD_pn} with SN ${RMOD_sn}  console=True
    Check cloud BTS states and alarms during reset shared RMOD  RMOD_sn=${RMOD_sn}  vdu_alias=${vdu_alias}  reset_triggered_from=${vdu_alias}
    Log  Check ${peer_BTS_alias} BTS state and alarms during reset shared RMOD ${RMOD_pn} with SN ${RMOD_sn}  console=True
    Run Keyword If  '${peer_BTS_alias}' in ${alias_list}
    ...  Check classical BTS states and alarms during reset shared RMOD  RMOD_sn=${RMOD_sn}  alias=${peer_BTS_alias}
    ...  reset_triggered_from=${vdu_alias}
    ...  ELSE
    ...  Check cloud BTS states and alarms during reset shared RMOD  RMOD_sn=${RMOD_sn}  vdu_alias=${peer_BTS_alias}
    ...  reset_triggered_from=${vdu_alias}

    Sleep  5s  reason=Waiting time before check no impact on other cells

    Log Long String  Check all cloud/classical BTS other cells are not impacted by "Reset" operation on shared RMOD ${RMOD_pn} with SN ${RMOD_sn}
    ...  from ${vdu_alias}  console=True
    ${NR_cell_info_exempted}=  Create Dictionary  ${vdu_alias}=${${vdu_alias}_RMOD_NR_CELL_ids_list}
    ...  ${peer_BTS_alias}=${${peer_BTS_alias}_RMOD_NR_CELL_ids_list}
    ${peer_alias_IoT_exempted_LTE_CELL_ids_list}=  Create List
    FOR  ${lte_cell_id}  IN  @{${peer_BTS_alias}_RMOD_LTE_CELL_ids_list}
        ${cell_IOT_id}=  Get From Dictionary  ${${peer_BTS_alias}_LTE_cell_IOT_mapping_dict}  ${lte_cell_id}
        Run Keyword If  '${cell_IOT_id}' != 'None'  Append To List  ${peer_alias_IoT_exempted_LTE_CELL_ids_list}  ${cell_IOT_id}
    END
    ${peer_alias_exempted_LTE_CELL_ids_list_full}=
    ...  Combine Lists  ${${peer_BTS_alias}_RMOD_LTE_CELL_ids_list}  ${peer_alias_IoT_exempted_LTE_CELL_ids_list}
    ${peer_alias_exempted_LTE_CELL_ids_list_full}=  Remove Duplicates  ${peer_alias_exempted_LTE_CELL_ids_list_full}
    ${LTE_cell_info_exempted}=  Create Dictionary  ${vdu_alias}=${${vdu_alias}_RMOD_LTE_CELL_ids_list}
    ...  ${peer_BTS_alias}=${peer_alias_exempted_LTE_CELL_ids_list_full}
    ${WCDMA_cell_info_exempted}=  Create Dictionary  ${vdu_alias}=${${vdu_alias}_RMOD_WCDMA_CELL_ids_list}
    ...  ${peer_BTS_alias}=${${peer_BTS_alias}_RMOD_WCDMA_CELL_ids_list}
    ${GSM_cell_info_exempted}=  Create Dictionary  ${vdu_alias}=${${vdu_alias}_RMOD_GSM_CELL_ids_list}
    ...  ${peer_BTS_alias}=${${peer_BTS_alias}_RMOD_GSM_CELL_ids_list}
    Check BTS cells are enabled online with exceptions  NR_cell_info_exempted=&{NR_cell_info_exempted}
    ...  LTE_cell_info_exempted=&{LTE_cell_info_exempted}  WCDMA_cell_info_exempted=&{WCDMA_cell_info_exempted}
    ...  GSM_cell_info_exempted=&{GSM_cell_info_exempted}  timeout=3
    Log  All cloud/classical BTS other cells status is OK.  console=True

    Log  Check ${vdu_alias} state and alarms after reset shared RMOD ${RMOD_pn} with SN ${RMOD_sn}  console=True
    Check cloud BTS states and alarms after reset shared RMOD  RMOD_sn=${RMOD_sn}  vdu_alias=${vdu_alias}
    Run Keyword If  '${peer_BTS_alias}' in ${alias_list}
    ...  Check classical BTS states and alarms after reset shared RMOD  RMOD_sn=${RMOD_sn}  alias=${peer_BTS_alias}
    ...  ELSE
    ...  Check cloud BTS states and alarms after reset shared RMOD  RMOD_sn=${RMOD_sn}  vdu_alias=${peer_BTS_alias}

    ${vdu_rmod_kpi_51a}=  DateTime.Subtract Date From Date  ${time_final}  ${time_initial}  number
    Set Test Variable  ${vdu_rmod_kpi_51a}

    Sleep  5s  reason=Waiting time before check no impact on other cells

    Log Long String  Check all cloud/classical BTS other cells are not impacted by "Reset" operation on shared RMOD ${RMOD_pn} with SN ${RMOD_sn}
    ...  from ${vdu_alias}  console=True
    Check BTS cells are enabled online with exceptions  timeout=3
    Log  All cloud/classical BTS other cells status is OK.  console=True

    Get and check KPI51a info from events  ${RMOD_sn}  ${vdu_alias}  ${CYCLE}

Reset shared RMOD on classical BTS
    [Arguments]  ${RMOD_sn}  ${alias}  ${new_alias}  ${CYCLE}

    Get RMOD info from BTS  ${RMOD_sn}  ${alias}

    Log  ***** Perform "Reset" operation on shared RMOD ${RMOD_pn} with SN ${RMOD_sn} from ${alias} BTS *****   console=True

    Get Current Date UTC info  initial
    Get Current Time  initial
    ${reset_info}=  RFS RM Reset  dist_name=${${alias}_RMOD_id}  timeout=${RMOD_RESET_MAX_WAIT_TIME}  connection=${new_alias}  alias=${alias}
    ...  graceful_cell_shutdown=${GRACEFUL_CELL_SHUTDOWN_SBTS}

    Log  Check ${alias} state and alarms during reset shared RMOD ${RMOD_pn} with SN ${RMOD_sn}  console=True
    Check classical BTS states and alarms during reset shared RMOD  RMOD_sn=${RMOD_sn}  alias=${alias}  reset_triggered_from=${alias}
    Log  Check ${peer_BTS_alias} BTS state and alarms during reset shared RMOD ${RMOD_pn} with SN ${RMOD_sn}  console=True
    Run Keyword If  '${peer_BTS_alias}' in ${alias_list}
    ...  Check classical BTS states and alarms during reset shared RMOD  RMOD_sn=${RMOD_sn}  alias=${peer_BTS_alias}  reset_triggered_from=${alias}
    ...  ELSE
    ...  Check cloud BTS states and alarms during reset shared RMOD  RMOD_sn=${RMOD_sn}  vdu_alias=${peer_BTS_alias}  reset_triggered_from=${alias}

    Sleep  5s  reason=Waiting time before check no impact on other cells

    Log Long String  Check all cloud/classical BTS other cells are not impacted by "Reset" operation on shared RMOD ${RMOD_pn} with SN ${RMOD_sn}
    ...  from ${alias}  console=True
    ${NR_cell_info_exempted}=  Create Dictionary  ${alias}=${${alias}_RMOD_NR_CELL_ids_list}
    ...  ${peer_BTS_alias}=${${peer_BTS_alias}_RMOD_NR_CELL_ids_list}
    ${alias_IoT_exempted_LTE_CELL_ids_list}=  Create List
    FOR  ${lte_cell_id}  IN  @{${alias}_RMOD_LTE_CELL_ids_list}
        ${cell_IOT_id}=  Get From Dictionary  ${${alias}_LTE_cell_IOT_mapping_dict}  ${lte_cell_id}
        Run Keyword If  '${cell_IOT_id}' != 'None'  Append To List  ${alias_IoT_exempted_LTE_CELL_ids_list}  ${cell_IOT_id}
    END
    ${alias_exempted_LTE_CELL_ids_list_full}=
    ...  Combine Lists  ${${alias}_RMOD_LTE_CELL_ids_list}  ${alias_IoT_exempted_LTE_CELL_ids_list}
    ${alias_exempted_LTE_CELL_ids_list_full}=  Remove Duplicates  ${alias_exempted_LTE_CELL_ids_list_full}
    ${LTE_cell_info_exempted}=  Create Dictionary  ${alias}=${alias_exempted_LTE_CELL_ids_list_full}
    ...  ${peer_BTS_alias}=${${peer_BTS_alias}_RMOD_LTE_CELL_ids_list}
    ${WCDMA_cell_info_exempted}=  Create Dictionary  ${alias}=${${alias}_RMOD_WCDMA_CELL_ids_list}
    ...  ${peer_BTS_alias}=${${peer_BTS_alias}_RMOD_WCDMA_CELL_ids_list}
    ${GSM_cell_info_exempted}=  Create Dictionary  ${alias}=${${alias}_RMOD_GSM_CELL_ids_list}
    ...  ${peer_BTS_alias}=${${peer_BTS_alias}_RMOD_GSM_CELL_ids_list}
    Check BTS cells are enabled online with exceptions  NR_cell_info_exempted=&{NR_cell_info_exempted}
    ...  LTE_cell_info_exempted=&{LTE_cell_info_exempted}  WCDMA_cell_info_exempted=&{WCDMA_cell_info_exempted}
    ...  GSM_cell_info_exempted=&{GSM_cell_info_exempted}  timeout=3
    Log  All cloud/classical BTS other cells status is OK.  console=True

    Collect Keyword Result  ${reset_info}  timeout=${RMOD_RESET_MAX_WAIT_TIME}

    Log  Check ${alias} state and alarms after reset shared RMOD ${RMOD_pn} with SN ${RMOD_sn}  console=True
    Check classical BTS states and alarms after reset shared RMOD  RMOD_sn=${RMOD_sn}  alias=${alias}
    Run Keyword If  '${peer_BTS_alias}' in ${alias_list}
    ...  Check classical BTS states and alarms after reset shared RMOD  RMOD_sn=${RMOD_sn}  alias=${peer_BTS_alias}
    ...  ELSE
    ...  Check cloud BTS states and alarms after reset shared RMOD  RMOD_sn=${RMOD_sn}  vdu_alias=${peer_BTS_alias}

    Sleep  5s  reason=Waiting time before check no impact on other cells

    Log Long String  Check all cloud/classical BTS other cells are not impacted by "Reset" operation on shared RMOD ${RMOD_pn} with SN ${RMOD_sn}
    ...  from ${alias}  console=True
    Check BTS cells are enabled online with exceptions  timeout=3
    Log  All cloud/classical BTS other cells status is OK.  console=True

    Get Current Date UTC info  final

    Run Keyword If  ${${alias}_RMOD_cell_state_failed_count} > 0
    ...  Get and check KPI51a info from IMS file  ${RMOD_sn}  ${alias}  ${CYCLE}

Get RMOD info from BTS
    [Arguments]  ${RMOD_sn}  ${alias}
    ${RMOD_id}=  Get From Dictionary  ${${alias}_RMOD_sn_id_dict}  ${RMOD_sn}
    ${RMOD_id_list}=  Create List  ${RMOD_id}
    Set Test Variable  ${${alias}_RMOD_id}  ${RMOD_id}
    Set Test Variable  ${${alias}_RMOD_id_list}  ${RMOD_id_list}
    ${RMOD_pn}=  Get From Dictionary  ${${alias}_RMOD_sn_pn_dict}  ${RMOD_sn}
    Set Test Variable  ${RMOD_pn}

    ${BTS_RMOD_id_CELL_ids_info}=  Get From Dictionary  ${all_BTS_RMOD_id_CELL_ids_info}  ${alias}
    ${RMOD_id_NR_CELL_ids_dict}=  Get From Dictionary  ${BTS_RMOD_id_CELL_ids_info}  RMOD_id_NR_CELL_ids_dict
    ${RMOD_id_LTE_CELL_ids_dict}=  Get From Dictionary  ${BTS_RMOD_id_CELL_ids_info}  RMOD_id_LTE_CELL_ids_dict
    ${RMOD_id_WCDMA_CELL_ids_dict}=  Get From Dictionary  ${BTS_RMOD_id_CELL_ids_info}  RMOD_id_WCDMA_CELL_ids_dict
    ${RMOD_id_GSM_CELL_ids_dict}=  Get From Dictionary  ${BTS_RMOD_id_CELL_ids_info}  RMOD_id_GSM_CELL_ids_dict
    ${RMOD_NR_CELL_ids_list}=  Get From Dictionary  ${RMOD_id_NR_CELL_ids_dict}  ${${alias}_RMOD_id}
    ${RMOD_LTE_CELL_ids_list}=  Get From Dictionary  ${RMOD_id_LTE_CELL_ids_dict}  ${${alias}_RMOD_id}
    ${RMOD_WCDMA_CELL_ids_list}=  Get From Dictionary  ${RMOD_id_WCDMA_CELL_ids_dict}  ${${alias}_RMOD_id}
    ${RMOD_GSM_CELL_ids_list}=  Get From Dictionary  ${RMOD_id_GSM_CELL_ids_dict}  ${${alias}_RMOD_id}
    Set Test Variable  ${${alias}_RMOD_NR_CELL_ids_list}  ${RMOD_NR_CELL_ids_list}
    Set Test Variable  ${${alias}_RMOD_LTE_CELL_ids_list}  ${RMOD_LTE_CELL_ids_list}
    Set Test Variable  ${${alias}_RMOD_WCDMA_CELL_ids_list}  ${RMOD_WCDMA_CELL_ids_list}
    Set Test Variable  ${${alias}_RMOD_GSM_CELL_ids_list}  ${RMOD_GSM_CELL_ids_list}

    ${RMOD_BTS_alias_list}=  Get From Dictionary  ${RMOD_sn_BTS_alias_dict}  ${RMOD_sn}
    ${RMOD_BTS_alias_count}=  Get Length  ${RMOD_BTS_alias_list}
    Return From Keyword If  ${RMOD_BTS_alias_count} == 1

    ${RMOD_peer_BTS_alias_list}=  Copy List  ${RMOD_BTS_alias_list}
    Remove Values From List  ${RMOD_peer_BTS_alias_list}  ${alias}
    ${peer_BTS_alias}=  Get From List  ${RMOD_peer_BTS_alias_list}  0
    Set Test Variable  ${peer_BTS_alias}
    ${RMOD_id}=  Get From Dictionary  ${${peer_BTS_alias}_RMOD_sn_id_dict}  ${RMOD_sn}
    Set Test Variable  ${${peer_BTS_alias}_RMOD_id}  ${RMOD_id}

    ${BTS_RMOD_id_CELL_ids_info}=  Get From Dictionary  ${all_BTS_RMOD_id_CELL_ids_info}  ${peer_BTS_alias}
    ${RMOD_id_NR_CELL_ids_dict}=  Get From Dictionary  ${BTS_RMOD_id_CELL_ids_info}  RMOD_id_NR_CELL_ids_dict
    ${RMOD_id_LTE_CELL_ids_dict}=  Get From Dictionary  ${BTS_RMOD_id_CELL_ids_info}  RMOD_id_LTE_CELL_ids_dict
    ${RMOD_id_WCDMA_CELL_ids_dict}=  Get From Dictionary  ${BTS_RMOD_id_CELL_ids_info}  RMOD_id_WCDMA_CELL_ids_dict
    ${RMOD_id_GSM_CELL_ids_dict}=  Get From Dictionary  ${BTS_RMOD_id_CELL_ids_info}  RMOD_id_GSM_CELL_ids_dict
    ${RMOD_NR_CELL_ids_list}=  Get From Dictionary  ${RMOD_id_NR_CELL_ids_dict}  ${${peer_BTS_alias}_RMOD_id}
    ${RMOD_LTE_CELL_ids_list}=  Get From Dictionary  ${RMOD_id_LTE_CELL_ids_dict}  ${${peer_BTS_alias}_RMOD_id}
    ${RMOD_WCDMA_CELL_ids_list}=  Get From Dictionary  ${RMOD_id_WCDMA_CELL_ids_dict}  ${${peer_BTS_alias}_RMOD_id}
    ${RMOD_GSM_CELL_ids_list}=  Get From Dictionary  ${RMOD_id_GSM_CELL_ids_dict}  ${${peer_BTS_alias}_RMOD_id}
    Set Test Variable  ${${peer_BTS_alias}_RMOD_NR_CELL_ids_list}  ${RMOD_NR_CELL_ids_list}
    Set Test Variable  ${${peer_BTS_alias}_RMOD_LTE_CELL_ids_list}  ${RMOD_LTE_CELL_ids_list}
    Set Test Variable  ${${peer_BTS_alias}_RMOD_WCDMA_CELL_ids_list}  ${RMOD_WCDMA_CELL_ids_list}
    Set Test Variable  ${${peer_BTS_alias}_RMOD_GSM_CELL_ids_list}  ${RMOD_GSM_CELL_ids_list}

    ${RMOD_interface}=  Get From Dictionary  ${${peer_BTS_alias}_RMOD_sn_interface_dict}  ${RMOD_sn}
    Set Test Variable  ${RMOD_interface}

Check cloud BTS states and alarms during reset shared RMOD
    [Arguments]  ${RMOD_sn}  ${vdu_alias}  ${reset_triggered_from}

    Log  Check ${vdu_alias} shared RMOD ${RMOD_pn} with SN ${RMOD_sn} status:  console=True
    ${remained_MAX_WAIT_TIME}=  Get elapsed time  ${time_initial}  ${RMOD_RESET_MAX_WAIT_TIME}
    Check CBTS VDU shared RMOD state  ${RMOD_sn}  ${CBTS_Disabled_}  ${CBTS_NotInstalled_Offline_}  ${CBTS_Unlocked_}  ${CBTS_RMOD_state_disabled}
    ...  ${remained_MAX_WAIT_TIME}  ${vdu_alias}

    Log  Check ${vdu_alias} cells mapped on shared RMOD ${RMOD_pn} with SN ${RMOD_sn} status:  console=True
    ${remained_MAX_WAIT_TIME}=  Get elapsed time  ${time_initial}  ${RMOD_RESET_MAX_WAIT_TIME}
    Check CBTS VDU shared RMOD cell state  ${RMOD_sn}  ${${vdu_alias}_RMOD_NR_CELL_ids_list}  ${CBTS_Disabled_}  ${CBTS_Failed_Offline_}
    ...  ${CBTS_Unlocked_}  ${CBTS_Unblocked_}  ${CBTS_CELL_state_disabled}  ${remained_MAX_WAIT_TIME}  ${vdu_alias}

    Log  Check ${vdu_alias} alarms:  console=True
    ${vdu_alias_alarm}=  Replace String  ${vdu_alias}  ${SPACE}  _
    ${VDU_EXPECTED_ALARMS_full}=  Create List
    Run Keyword If  '${reset_triggered_from}' != '${vdu_alias}'
    ...  Append To List  ${VDU_EXPECTED_ALARMS_full}  @{${vdu_alias_alarm.upper()}_EXPECTED_ALARMS_10}
    Run Keyword If  '${reset_triggered_from}' != '${vdu_alias}'
    ...  Log  ${vdu_alias} "No connection to Unit (10)" alarm, expected number: 1  console=True
    Get and Check Alarms CBTS VDU  vdu_alias=${vdu_alias}  poll_interval=5s  expected_alarms=${VDU_EXPECTED_ALARMS_full}
    ...  ignored_alarms=${${vdu_alias_alarm.upper()}_IGNORED_ALARMS}  critical_alarms=${${vdu_alias_alarm.upper()}_CRITICAL_ALARMS}
    Run Keyword If  '${reset_triggered_from}' != '${vdu_alias}'
    ...  Log  ${vdu_alias} "No connection to Unit (10)" alarm, found number: 1, as expected!  console=True
    Log  ${vdu_alias} site - expected, ignored and critical alarms checked  console=True

Check classical BTS states and alarms during reset shared RMOD
    [Arguments]  ${RMOD_sn}  ${alias}  ${reset_triggered_from}

    Log  Check ${alias} BTS shared RMOD ${RMOD_pn} with SN ${RMOD_sn} status:  console=True
    ${remained_MAX_WAIT_TIME}=  Get elapsed time  ${time_initial}  ${RMOD_RESET_MAX_WAIT_TIME}
    Check SBTS shared RMOD state  ${RMOD_sn}  ${SBTS_RMOD_state_disabled_check}  ${SBTS_RMOD_state_disabled}  ${remained_MAX_WAIT_TIME}  ${alias}

    Log  Check ${alias} BTS cells status mapped on shared RMOD ${RMOD_pn} with SN ${RMOD_sn}:  console=True
    Wait Until Keyword Succeeds  30s  10s  Check cells state mapped on RMOD  ${alias}

    Log  Check ${alias} BTS alarms:  console=True
    ${SBTS_EXPECTED_ALARMS_full}=  Create List
    ${SBTS_EXPECTED_ALARMS_4003}=  Prepare expected alarms list  ${${alias.upper()}_EXPECTED_ALARMS_4003}  ${${alias}_BTS_ALARM_COUNT_MIMO}
    Run Keyword If  ${${alias}_BTS_ALARM_COUNT_MIMO} > 0
    ...  Append To List  ${SBTS_EXPECTED_ALARMS_full}  @{SBTS_EXPECTED_ALARMS_4003}
    Run Keyword If  '${reset_triggered_from}' != '${alias}'  Append To List  ${SBTS_EXPECTED_ALARMS_full}  @{${alias.upper()}_EXPECTED_ALARMS_4773}

    Run Keyword If  '${reset_triggered_from}' != '${alias}'
    ...  Log  ${alias} BTS "Radio unit reset triggered by peer BTS (4773)" alarm, expected number: 1  console=True
    Run Keyword If  ${${alias}_BTS_ALARM_COUNT_MIMO} > 0
    ...  Log Long String  BTS ${alias} "Transmission path failure (4003)" or "Tx Failure Turn Mimo Off (4003)" alarm, expected number:
    ...  ${${alias}_BTS_ALARM_COUNT_MIMO}  console=True
    Get and Check Alarms SOAM  alias=${alias}  poll_interval=5 sec  expected_alarms=${SBTS_EXPECTED_ALARMS_full}
    ...  ignored_alarms=${${alias.upper()}_IGNORED_ALARMS}  critical_alarms=${${alias.upper()}_CRITICAL_ALARMS}
    Run Keyword If  '${reset_triggered_from}' != '${alias}'
    ...  Log  ${alias} BTS "Radio unit reset triggered by peer BTS (4773)" alarm, found number: 1, as expected!  console=True
    Run Keyword If  ${${alias}_BTS_ALARM_COUNT_MIMO} > 0
    ...  Log Long String  BTS ${alias} "Transmission path failure (4003)" or "Tx Failure Turn Mimo Off (4003)" alarm, expected number:
    ...  ${${alias}_BTS_ALARM_COUNT_MIMO}  console=True
    Log  ${alias} site - expected, ignored and critical alarms checked  console=True

Check cloud BTS states and alarms after reset shared RMOD
    [Arguments]  ${RMOD_sn}  ${vdu_alias}

    Log  Check ${vdu_alias} shared RMOD ${RMOD_pn} with SN ${RMOD_sn} status:  console=True
    ${remained_MAX_WAIT_TIME}=  Get elapsed time  ${time_initial}  ${RMOD_RESET_MAX_WAIT_TIME}
    Check CBTS VDU shared RMOD state  ${RMOD_sn}  ${CBTS_Enabled_}  ${CBTS_Online_}  ${CBTS_Unlocked_}  ${CBTS_RMOD_state_enabled}
    ...  ${remained_MAX_WAIT_TIME}  ${vdu_alias}

    Log  Check ${vdu_alias} cells mapped on shared RMOD ${RMOD_pn} with SN ${RMOD_sn} status:  console=True
    ${remained_MAX_WAIT_TIME}=  Get elapsed time  ${time_initial}  ${RMOD_RESET_MAX_WAIT_TIME}
    Check CBTS VDU shared RMOD cell state  ${RMOD_sn}  ${${vdu_alias}_RMOD_NR_CELL_ids_list}  ${CBTS_Enabled_}  ${CBTS_Online_}  ${CBTS_Unlocked_}
    ...  ${CBTS_Unblocked_}  ${CBTS_CELL_state_enabled}  ${remained_MAX_WAIT_TIME}  ${vdu_alias}

    Get Current Time  final

    Log  Check ${vdu_alias} alarms:  console=True
    ${vdu_alias_alarm}=  Replace String  ${vdu_alias}  ${SPACE}  _
    Get and Check Alarms CBTS VDU  vdu_alias=${vdu_alias}  poll_interval=5s  expected_alarms=@{EMPTY}
    ...  ignored_alarms=${${vdu_alias_alarm.upper()}_IGNORED_ALARMS}  critical_alarms=${${vdu_alias_alarm.upper()}_CRITICAL_ALARMS}
    Log  ${vdu_alias} site - expected, ignored and critical alarms checked  console=True

Check classical BTS states and alarms after reset shared RMOD
    [Arguments]  ${RMOD_sn}  ${alias}

    Log  Check ${alias} BTS shared RMOD ${RMOD_pn} with SN ${RMOD_sn} status:  console=True
    ${remained_MAX_WAIT_TIME}=  Get elapsed time  ${time_initial}  ${RMOD_RESET_MAX_WAIT_TIME}
    Check SBTS shared RMOD state  ${RMOD_sn}  ${SBTS_RMOD_state_enabled_check}  ${SBTS_RMOD_state_enabled}  ${remained_MAX_WAIT_TIME}  ${alias}

    Log  Check ${alias} BTS cells mapped on shared RMOD ${RMOD_pn} with SN ${RMOD_sn} status:  console=True
    ${remained_MAX_WAIT_TIME}=  Get elapsed time  ${time_initial}  ${RMOD_RESET_MAX_WAIT_TIME}
    Check SBTS shared RMOD cell state  ${RMOD_sn}  ${${alias}_RMOD_NR_CELL_ids_list}  ${${alias}_RMOD_LTE_CELL_ids_list}
    ...  ${${alias}_RMOD_WCDMA_CELL_ids_list}  ${${alias}_RMOD_GSM_CELL_ids_list}  ${SBTS_CELL_state_enabled_check}
    ...  ${SBTS_CELL_state_enabled}  ${remained_MAX_WAIT_TIME}  ${alias}

    Log  Check ${alias} BTS alarms:  console=True
    Get and Check Alarms SOAM  alias=${alias}  poll_interval=5 sec  expected_alarms=@{EMPTY}
    ...  ignored_alarms=${${alias.upper()}_IGNORED_ALARMS}  critical_alarms=${${alias.upper()}_CRITICAL_ALARMS}
    Log  ${alias} site - expected, ignored and critical alarms checked  console=True

Check CBTS VDU shared RMOD state
    [Arguments]  ${RMOD_sn}  ${RMOD_operational_state_check}  ${RMOD_availability_status_check}  ${RMOD_administrative_state_check}
    ...  ${RMOD_state}  ${timeout}  ${vdu_alias}
    Wait Until Keyword Succeeds  ${timeout}s  1s  VDU Check RMOD Expected Status  rmod_id=${${vdu_alias}_RMOD_id}
    ...  operational_state=${RMOD_operational_state_check}  availability_status=${RMOD_availability_status_check}
    ...  administrative_state==${RMOD_administrative_state_check}  vdu_connection=${vdu_alias}
    Log  ${vdu_alias} RMOD ${RMOD_pn} with SN ${RMOD_sn} status:\n - ${RMOD_state}  console=True

Check CBTS VDU shared RMOD cell state
    [Arguments]  ${RMOD_sn}  ${RMOD_NR_CELL_ids}  ${CELL_operational_state_check}  ${CELL_availability_status_check}
    ...  ${CELL_administrative_state_check}  ${CELL_blocking_state_check}  ${CELL_state}  ${timeout}  ${vdu_alias}

    FOR  ${item}  IN  @{RMOD_NR_CELL_ids}

        Wait Until Keyword Succeeds  ${timeout}s  1s  VDU Check Cell Expected Status  cell_id=${item}
        ...  operational_state=${CELL_operational_state_check}  availability_status=${CELL_availability_status_check}
        ...  administrative_state==${CELL_administrative_state_check}  blocking_state=${CELL_blocking_state_check}  vdu_connection=${vdu_alias}
        ${timeout}=  Get elapsed time  ${time_initial}  ${RMOD_RESET_MAX_WAIT_TIME}

    END
    Log  ${vdu_alias} cells mapped on RMOD ${RMOD_pn} with SN ${RMOD_sn} status:\n - ${CELL_state}  console=True

Check SBTS shared RMOD state
    [Arguments]  ${RMOD_sn}  ${RMOD_state_check}  ${RMOD_state}  ${timeout}  ${alias}
    Assert  class_name=RMOD  id=${${alias}_RMOD_id}  parameters=${RMOD_state_check}  timeout=${timeout}  connection=${alias}
    Log  ${alias} BTS RMOD ${RMOD_pn} with SN ${RMOD_sn} status:\n - ${RMOD_state}  console=True

Check SBTS shared RMOD cell state
    [Arguments]  ${RMOD_sn}  ${RMOD_NR_CELL_ids}  ${RMOD_LTE_CELL_ids}  ${RMOD_WCDMA_CELL_ids}  ${RMOD_GSM_NR_CELL_ids}  ${CELL_state_check}
    ...  ${CELL_state}  ${timeout}  ${alias}

    FOR  ${item}  IN  @{RMOD_NR_CELL_ids}
        Assert  class_name=NRCEL  id=${item}  parameters=${CELL_state_check}  timeout=${timeout}  connection=${alias}
        ${timeout}=  Get elapsed time  ${time_initial}  ${RMOD_RESET_MAX_WAIT_TIME}
    END

    FOR  ${item}  IN  @{RMOD_LTE_CELL_ids}
        Assert  class_name=LNCEL  id=${item}  parameters=${CELL_state_check}  timeout=${timeout}  connection=${alias}
        ${timeout}=  Get elapsed time  ${time_initial}  ${RMOD_RESET_MAX_WAIT_TIME}
    END

    FOR  ${item}  IN  @{RMOD_WCDMA_CELL_ids}
        Assert  class_name=WNCEL  id=${item}  parameters=${CELL_state_check}  timeout=${timeout}  connection=${alias}
        ${timeout}=  Get elapsed time  ${time_initial}  ${RMOD_RESET_MAX_WAIT_TIME}
    END

    FOR  ${item}  IN  @{RMOD_GSM_NR_CELL_ids}
        Assert  class_name=GNCEL  id=${item}  parameters=${CELL_state_check}  timeout=${timeout}  connection=${alias}
        ${timeout}=  Get elapsed time  ${time_initial}  ${RMOD_RESET_MAX_WAIT_TIME}
    END

    Log  ${alias} BTS cells mapped on RMOD ${RMOD_pn} with SN ${RMOD_sn} status:\n - ${CELL_state}  console=True

Check cells state mapped on RMOD
    [Arguments]  ${alias}

    ${cell_status_enabled_degraded_check}=  Set Variable  operationalState=${Enabled_}, availabilityStatus=${Degraded_}
    ${cell_status_disabled_offline_check}=  Set Variable  operationalState=${Disabled_}, availabilityStatus=${Offline_}

    ${BTS_ALARM_COUNT_MIMO}=  Set Variable  0
    ${ALARM_COUNT_MIMO}=  Set Variable  0

    ${NR_cell_state_degraded_list}  ${NR_cell_state_failed_list}=  Run Keyword If  ${${alias}_RMOD_NR_CELL_ids_list}
    ...  Check NR cells state and MIMO alarm  cell_list=${${alias}_RMOD_NR_CELL_ids_list}  alias=${alias}
    ${NR_cell_state_failed_list}=  Run Keyword If  ${${alias}_RMOD_NR_CELL_ids_list}
    ...  Set Variable  ${NR_cell_state_failed_list}
    ...  ELSE  Create List
    ${BTS_ALARM_COUNT_MIMO}=  Evaluate  ${BTS_ALARM_COUNT_MIMO} + ${ALARM_COUNT_MIMO}

    ${ALARM_COUNT_MIMO}=  Set Variable  0
    ${LTE_cell_state_degraded_list}  ${LTE_cell_state_failed_list}=  Run Keyword If  ${${alias}_RMOD_LTE_CELL_ids_list}
    ...  Check LTE cells state and MIMO alarm  cell_list=${${alias}_RMOD_LTE_CELL_ids_list}  alias=${alias}
    ${LTE_cell_state_failed_list}=  Run Keyword If  ${${alias}_RMOD_LTE_CELL_ids_list}
    ...  Set Variable  ${LTE_cell_state_failed_list}
    ...  ELSE  Create List
    ${BTS_ALARM_COUNT_MIMO}=  Evaluate  ${BTS_ALARM_COUNT_MIMO} + ${ALARM_COUNT_MIMO}

    ${ALARM_COUNT_MIMO}=  Set Variable  0
    ${WCDMA_cell_state_degraded_list}  ${WCDMA_cell_state_failed_list}=  Run Keyword If  ${${alias}_RMOD_WCDMA_CELL_ids_list}
    ...  Check WCDMA cells state and MIMO alarm  cell_list=${${alias}_RMOD_WCDMA_CELL_ids_list}  alias=${alias}
    ${WCDMA_cell_state_failed_list}=  Run Keyword If  ${${alias}_RMOD_WCDMA_CELL_ids_list}
    ...  Set Variable  ${WCDMA_cell_state_failed_list}
    ...  ELSE  Create List
    ${BTS_ALARM_COUNT_MIMO}=  Evaluate  ${BTS_ALARM_COUNT_MIMO} + ${ALARM_COUNT_MIMO}

    ${ALARM_COUNT_MIMO}=  Set Variable  0
    ${GSM_cell_state_degraded_list}  ${GSM_cell_state_failed_list}=  Run Keyword If  ${${alias}_RMOD_GSM_CELL_ids_list}
    ...  Check GSM cells state and MIMO alarm  cell_list=${${alias}_RMOD_GSM_CELL_ids_list}  alias=${alias}
    ${GSM_cell_state_failed_list}=  Run Keyword If  ${${alias}_RMOD_GSM_CELL_ids_list}
    ...  Set Variable  ${GSM_cell_state_failed_list}
    ...  ELSE  Create List
    ${BTS_ALARM_COUNT_MIMO}=  Evaluate  ${BTS_ALARM_COUNT_MIMO} + ${ALARM_COUNT_MIMO}
    Set Test Variable  ${${alias}_BTS_ALARM_COUNT_MIMO}  ${BTS_ALARM_COUNT_MIMO}

    Calculate number of disabled cells mapped on RMOD  ${alias}  ${NR_cell_state_failed_list}  ${LTE_cell_state_failed_list}
    ...  ${WCDMA_cell_state_failed_list}  ${GSM_cell_state_failed_list}

    Run Keyword If  not ${${alias}_RMOD_LTE_CELL_ids_list}  Return From Keyword
    Run Keyword If  '${LTE_IOT_check}' != 'True'  Return From Keyword

    FOR  ${lte_cell_id}  IN  @{LTE_cell_state_degraded_list}
        ${cell_IOT_id}=  Get From Dictionary  ${${alias}_LTE_cell_IOT_mapping_dict}  ${lte_cell_id}
        Run Keyword If  '${cell_IOT_id}' != 'None'
        ...  Assert  class_name=LNCEL  id=${cell_IOT_id}  parameters=${cell_status_enabled_degraded_check}  connection=${alias}
    END

    FOR  ${lte_cell_id}  IN  @{LTE_cell_state_failed_list}
        ${cell_IOT_id}=  Get From Dictionary  ${${alias}_LTE_cell_IOT_mapping_dict}  ${lte_cell_id}
        Run Keyword If  '${cell_IOT_id}' != 'None'
        ...  Assert  class_name=LNCEL  id=${cell_IOT_id}  parameters=${cell_status_disabled_offline_check}  connection=${alias}
    END

Calculate number of disabled cells mapped on RMOD
    [Arguments]  ${alias}  ${NR_cell_state_failed_list}  ${LTE_cell_state_failed_list}  ${WCDMA_cell_state_failed_list}
    ...  ${GSM_cell_state_failed_list}

    ${NR_cell_state_failed_count}=  Get Length  ${NR_cell_state_failed_list}
    ${LTE_cell_state_failed_count}=  Get Length  ${LTE_cell_state_failed_list}
    ${WCDMA_cell_state_failed_count}=  Get Length  ${WCDMA_cell_state_failed_list}
    ${GSM_cell_state_failed_count}=  Get Length  ${GSM_cell_state_failed_list}

    ${condition}=  Create Long String  ${NR_cell_state_failed_count} + ${LTE_cell_state_failed_count} + ${WCDMA_cell_state_failed_count} +
    ...  ${GSM_cell_state_failed_count}
    ${RMOD_cell_state_failed_count}=  Evaluate  ${condition}

    Set Test Variable  ${${alias}_RMOD_cell_state_failed_count}  ${RMOD_cell_state_failed_count}

Get and check KPI51a info from events
    [Arguments]  ${RMOD_sn}  ${vdu_alias}  ${CYCLE}

    Log  Get and check KPI51a info related to reset shared RMOD ${RMOD_pn} with SN ${RMOD_sn} from ${vdu_alias} for iteration ${CYCLE}  console=True

    Export KPI Results to File  alias=${vdu_alias}  obj_info=RMOD productName_serialNumber  obj=BTS KPI measurement
    ...  obj_type=${RMOD_pn}_${RMOD_sn}  obj_id=${vdu_alias}  action_1=RMOD_Reset  kpi_reported_1=KPI_51a  event_value_1=${vdu_rmod_kpi_51a}
    ...  cycle=${CYCLE}  source_info=events  add_info_label=BTS RMOD_reset action  add_info_value=${vdu_alias}

    Check and set KPI verdict  kpi51a  ${vdu_rmod_kpi_51a}  ${RMOD_RESET_WRN_THR}

Get and check KPI51a info from IMS file
    [Arguments]  ${RMOD_sn}  ${alias}  ${CYCLE}

    Log  Get and check KPI51a info related to reset shared RMOD ${RMOD_pn} with SN ${RMOD_sn} from ${alias} for iteration ${CYCLE}  console=True

    ${kpi_name_delta_dict_kpi51a}=  Get and check KPI info from IMS file  kpi_names=kpi51a  kpi_thresholds=${RMOD_RESET_WRN_THR}
    ...  alias=${alias}  start_point_timestamp_UTC=${date_timestamp_initial_UTC}
    ...  end_point_timestamp_UTC=${date_timestamp_final_UTC}
    ${kpi_delta_list_kpi51a}=  Get From Dictionary  ${kpi_name_delta_dict_kpi51a}  kpi51a

    Export KPI Results to File  alias=${alias}  obj_info=RMOD productName_serialNumber  obj=BTS KPI measurement
    ...  obj_type=${RMOD_pn}_${RMOD_sn}  obj_id=${alias}  action_1=RMOD_Reset  kpi_reported_1=KPI_51a
    ...  event_value_1=${kpi_delta_list_kpi51a[0]}  cycle=${CYCLE}  source_info=ims  add_info_label=BTS RMOD_reset action
    ...  add_info_value=${alias}

Particular Teardown
    Export KPI results to File Global  kpi_log_file_name=KpiTimeInfo

TC Setup
    ${tech_preset_list}=  Create List  CBTS  SBTS  SBTS  SBTS
    Common Test Setup  preset_techs=${tech_preset_list}  common_sbts=${TRUE}  infomodelSetup=${FALSE}

TC Teardown
    Common Test Teardown
