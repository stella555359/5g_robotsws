*** Settings ***
Documentation    TC__SBTS_SBTS_SBTS_SBTS__STATE__Secondary_Controller_SharedRM_LockUnlock_via_PLAN
Variables
...  tc_variables/sbts_sbts_sbts_sbts__state__secondary_controller_sharedrm_lockunlock_via_plan_alarms_definitions.py
Resource    ../../resources/rfs_frame_rfs_soam_taf.robot

*** Variables ***
${REPEAT_COUNTER}                  3     # Number of Lock/Unlock shared RMOD operations from BTS secondary controller, default value 3
${SHARED_RMOD_SERIAL_NUMBER_LIST}  ALL   # Shared RMOD serial number list on which Lock/Unlock operations will be performed.
                                         # Possible values (by default ALL):
                                         # - ALL: action will be performed on all shared RMOD
                                         # - list of selected shared RMOD serial number separated by comma.
${RMOD_LOCK_MAX_WAIT_TIME}         300   # Maximum time to wait for complete Lock RMOD operation (RMOD and mapped cells status)
${RMOD_UNLOCK_MAX_WAIT_TIME}       300   # Maximum time to wait for complete Unlock RMOD operation (RMOD and mapped cells status)
${LTE_IOT_check}                   True  # Specify in case of configured LTE IOT cells if their status will be checked (True) or skipped (False) after
                                         # Lock RMOD operation. By default True

*** Keywords ***
TC__SBTS_SBTS_SBTS_SBTS__STATE__Secondary_Controller_SharedRM_LockUnlock_via_PLAN
    [Documentation]
    ...  [CASE LINK]: https://jiradc.ext.net.nokia.com/browse/TAT-29899
    ...
    ...  *****************
    ...  Basic information
    ...  *****************
    ...  SBTS-SBTS-SBTS-SBTS test case for Lock/Unlock RMOD from BTS secondary controller, - x times sequence.
    ...  x - value of REPEAT_COUNTER parameter (default: 3)
    ...  The main steps performed for the test are:
    ...  - check initial state and alarms for all BTS
    ...  - get all BTS info for configured items: BTS role (primary/secondary controller per BTS), RM info, RAT cells (per BTS alias)
    ...  - perform lock unlock via commissioning administrativestate on shared RM of secondary controller BTS, checking states and alarms
    ...  - check final state and alarms for all BTS
    ...  Pass criteria: Lock/Unlock shared RMOD operation from BTS secondary controller works as expected; states and alarms are as expected
    ...
    ...  ******************
    ...  History of changes
    ...  ******************
    ...  - 29.09.2025 - https://jiradc.ext.net.nokia.com/browse/TAT-29899 - TC Delivery
    ...  - 13.10.2025 - https://jiradc.ext.net.nokia.com/browse/TAT-22669 - BBMOD Lock Unlock TC Delivery - move
    ...  Perform Administrative State Recommissioning to common resource

    Set Tags    CA-STATE    OWNER-constantin.diaconu@nokia.com    AUTHOR-gabriel.stanculescu@nokia.com    PHASE-QT    SW-SBTS26R1

    TC Preconditions
    Step 1: Check initial all BTS state
    Step 2: Check initial all BTS alarms
    Step 3: Get all BTS info for configured items
    FOR  ${INDEX}  IN RANGE  1  ${REPEAT_COUNTER}+1
        Log  ==============================================================================  console=True
        Log  Start Cycle ${INDEX} of ${REPEAT_COUNTER}  console=True
        Log  ==============================================================================  console=True
        Step 4: Perform Lock Unlock shared RMOD from BTS secondary controller via commissioning
        Step 5: Check final all BTS state
        Step 6: Check final all BTS alarms
        Step 7: Check final number and state of Cells and RMs
        Step 8: Check all BTS reset behavior based on IMS info
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

    Log  ========================================================  console=True
    Log  RMOD serial number list selected for Lock/Unlock action: ${shared_RMOD_sn_list}  console=True
    Log  ========================================================  console=True

Step ${index}: Check ${when} all BTS state
    [Documentation]
    ...  SBTS state is checked according to Admin for BTS and each configured RAT

    Log  Step ${index}: Check ${when} all BTS state  console=True

    FOR  ${alias}  IN  @{alias_list}

        Log  ***** Check ${when} BTS ${alias} state *****  console=True

        Admin Check BTS RAT Procedural State  alias=${alias}  timeout=600
        Admin Check BTS Procedural and Blocking states  ${OnAir_}  ${Unblocked_}  alias=${alias}
        Log  BTS ${alias} site - proceduralState: OnAir, blockingState: Unblocked  console=True
        Get and Check ALD state info  alias=${alias}

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

Step ${index}: Get all BTS info for configured items
    [Documentation]
    ...  Get all BTS info about following items:
    ...  - list of shared RM serial number configured on BTS primary controller and BTS secondary controller (per BTS alias)
    ...  - list of dedicated RM serial number (per BTS alias)
    ...  - list of RAT cells (per RMOD)
    ...  - list of RAT cells (per BTS alias)

    Log  Step ${index}: Get all BTS info for configured items  console=True

    ${all_BTS_RMOD_id_CELL_ids_info}=  Get all BTS Cells mapped on RMOD info
    Set Test Variable  ${all_BTS_RMOD_id_CELL_ids_info}

    ${all_BTS_controller_role_RMOD_sn_list}=  Get all BTS controller role for configured RMOD from SCF
    Set Test Variable  ${all_BTS_controller_role_RMOD_sn_list}

    Set Test Variable  ${RMOD_state_locked_check}  operationalState=${Enabled_}, administrativeState=${Locked_}
    Set Test Variable  ${RMOD_state_locked}  operationalState=Enabled, administrativeState=Locked
    Set Test Variable  ${RMOD_state_unlocked_check}  operationalState=${Enabled_}, administrativeState=${Unlocked_}
    Set Test Variable  ${RMOD_state_unlocked}  operationalState=Enabled, administrativeState=Unlocked
    Set Test Variable  ${CELL_state_enabled_check}  operationalState=${Enabled_}, blockingState=${Unblocked_}
    Set Test Variable  ${CELL_state_enabled}  operationalState=Enabled, blockingState=Unblocked
    Set Test Variable  ${CELL_state_enabled_degraded_check}
    ...  operationalState=${Enabled_}, availabilityStatus=${Degraded_}, blockingState=${Unblocked_}
    Set Test Variable  ${CELL_state_enabled_degraded}  operationalState=Enabled, availabilityStatus=Degraded, blockingState=Unblocked
    Set Test Variable  ${CELL_state_disabled_offline_check}
    ...  operationalState=${Disabled_}, availabilityStatus=${Offline_}, blockingState=${Unblocked_}
    Set Test Variable  ${CELL_state_disabled_offline}  operationalState=Disabled, availabilityStatus=Offline, blockingState=Unblocked
    Set Test Variable  ${CELL_state_disabled_failed_check}
    ...  operationalState=${Disabled_}, availabilityStatus=${Failed_}, blockingState=${Unblocked_}
    Set Test Variable  ${CELL_state_disabled_failed}  operationalState=Disabled, availabilityStatus=Failed, blockingState=Unblocked
    Set Test Variable  ${CELL_state_disabled_dependency_check}
    ...  operationalState=${Disabled_}, availabilityStatus=${Dependency_}, blockingState=${Unblocked_}
    Set Test Variable  ${CELL_state_disabled_dependency}  operationalState=Disabled, availabilityStatus=Dependency, blockingState=Unblocked

    FOR  ${alias}  IN  @{alias_list}

        Get BTS Cell info  ${alias}

    END

Step ${index}: Perform Lock Unlock shared RMOD from BTS secondary controller via commissioning
    Log  Step ${index}: Perform Lock Unlock shared RMOD from BTS secondary controller via commissioning  console=True

    Get Current Date UTC info  start

    FOR  ${alias}  IN  @{alias_list}

        Perform Lock Unlock shared RMOD from BTS via commissioning  ${alias}

    END

Step ${index}: Check final number and state of Cells and RMs
    [Documentation]
    ...  Following checks are performed:
    ...  - number of configured cells and radio modules in SCF are properly mapped on BTS running view ADMIN
    ...  - check cells states
    ...  - check radio modules states

    Log  Step ${index}: Check final number and state of Cells and RMs  console=True
    RFS Test Case Final Checks

Step ${index}: Check all BTS reset behavior based on IMS info
    [Documentation]
    ...  Final RESET info are compared with initial RESET info for all BTS.
    ...  Reset behavior as expected if reset number is 0
    ...  Otherwise, reset behavior not as expected, then errors are added to report and failed.

    Log  Step ${index}: Check all BTS reset behavior based on IMS info  console=True

    Get Current Date UTC info  end

    FOR  ${alias}  IN  @{alias_list}

        Get and check BTS RESET info from IMS file  expected_reset_number=0  alias=${alias}  remove_ims_file=False
        ...  start_point_timestamp_UTC=${date_timestamp_start_UTC}  end_point_timestamp_UTC=${date_timestamp_end_UTC}

    END

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

        ${BTS_feature_CB007878_dict}=  Get feature CB007878 settings on classical BTS  RMOD_sn_list=${RMOD_sn_list}  alias=${alias}

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

Get BTS Cell info
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
    Set Test Variable  ${${alias}_LTE_IOT_CELL_ID_LIST}  ${LTE_IOT_CELL_ID_LIST}
    Set Test Variable  ${${alias}_LTE_IOT_SA_CELL_ID_LIST}  ${LTE_IOT_SA_CELL_ID_LIST}
    Set Test Variable  ${${alias}_WCDMA_CELL_list}  ${WCDMA_CELL_list}
    Set Test Variable  ${${alias}_GSM_CELL_list}  ${GSM_CELL_list}
    Set Test Variable  ${${alias}_LTE_cell_IOT_mapping_dict}  ${LTE_cell_IOT_mapping_dict}

Perform Lock Unlock shared RMOD from BTS via commissioning
    [Arguments]  ${alias}

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

    ${BTS_RMOD_sn_list}=  Get From Dictionary  ${BTS_alias_RMOD_sn_dict}  ${alias}
    Sort List  ${BTS_RMOD_sn_list}

    Lock Unlock shared RMOD  ${BTS_RMOD_sn_list}  ${alias}

Lock Unlock shared RMOD
    [Arguments]  ${BTS_RMOD_sn_list}  ${alias}

    FOR  ${item}  IN  @{BTS_RMOD_sn_list}

        Continue For Loop If  '${item}' not in ${shared_RMOD_sn_list} or '${item}' not in ${${alias}_secondary_controller_RMOD_sn_list}

        Lock shared RMOD  ${item}  ${alias}
        Unlock shared RMOD  ${item}  ${alias}

    END

Lock shared RMOD
    [Arguments]  ${RMOD_sn}  ${alias}

    Get RMOD info from BTS  ${RMOD_sn}  ${alias}

    Log  ***** Perform "Lock" operation on shared RMOD ${RMOD_pn} with SN ${RMOD_sn} from BTS ${alias} *****  console=True

    Get Current Date UTC info  initial
    Get Current Time  initial
    ${RMOD_SCF_DN}=  Get RMOD SCF distinguished name  ${${alias}_RMOD_id}  ${alias}
    Perform Administrative State Recommissioning  obj_scf_dn=${RMOD_SCF_DN}  administrativeState=Locked  alias=${alias}
    ...  timeout=${RMOD_LOCK_MAX_WAIT_TIME}

    Log  Check BTS ${alias} state and alarms after lock shared RMOD ${RMOD_pn} with SN ${RMOD_sn}  console=True
    Check BTS states and alarms after lock RMOD  RMOD_sn=${RMOD_sn}  sharing_info=shared  alias=${alias}  lock_triggered_from=${alias}
    Log  Check BTS ${peer_BTS_alias} state and alarms after lock shared RMOD ${RMOD_pn} with SN ${RMOD_sn}  console=True
    Check BTS states and alarms after lock RMOD  RMOD_sn=${RMOD_sn}  sharing_info=shared  alias=${peer_BTS_alias}  lock_triggered_from=${alias}

    Sleep  5s  reason=Waiting time before check no impact on other cells

    Log  Check all BTS other cells are not impacted by "Lock" operation on shared RMOD ${RMOD_pn} with SN ${RMOD_sn} from BTS ${alias}  console=True
    ${NR_cell_info_exempted}=  Create Dictionary  ${alias}=${${alias}_RMOD_NR_CELL_ids_list}
    ...  ${peer_BTS_alias}=${${peer_BTS_alias}_RMOD_NR_CELL_ids_list}
    ${BTS_LTE_IOT_CELL_ids_list}=  Create List
    FOR  ${LTE_CELL_id}  IN  @{${alias}_RMOD_LTE_CELL_ids_list}
        ${LTE_IOT_CELL_id}=  Get From Dictionary  ${${alias}_LTE_cell_IOT_mapping_dict}  ${LTE_CELL_id}
        Run Keyword If  '${LTE_IOT_CELL_id}' != 'None'  Append To List  ${BTS_LTE_IOT_CELL_ids_list}  ${LTE_IOT_CELL_id}
    END
    ${BTS_LTE_CELL_ids_exempted_list}=  Combine Lists  ${${alias}_RMOD_LTE_CELL_ids_list}  ${BTS_LTE_IOT_CELL_ids_list}
    ...  ${${alias}_RMOD_LTE_IOT_SA_CELL_ids_list}
    ${peer_BTS_LTE_IOT_CELL_ids_list}=  Create List
    FOR  ${LTE_CELL_id}  IN  @{${peer_BTS_alias}_RMOD_LTE_CELL_ids_list}
        ${LTE_IOT_CELL_id}=  Get From Dictionary  ${${peer_BTS_alias}_LTE_cell_IOT_mapping_dict}  ${LTE_CELL_id}
        Run Keyword If  '${LTE_IOT_CELL_id}' != 'None'  Append To List  ${peer_BTS_LTE_IOT_CELL_ids_list}  ${LTE_IOT_CELL_id}
    END
    ${peer_BTS_LTE_CELL_ids_exempted_list}=  Combine Lists  ${${peer_BTS_alias}_RMOD_LTE_CELL_ids_list}  ${peer_BTS_LTE_IOT_CELL_ids_list}
    ...  ${${peer_BTS_alias}_RMOD_LTE_IOT_SA_CELL_ids_list}
    ${LTE_cell_info_exempted}=  Create Dictionary  ${alias}=${BTS_LTE_CELL_ids_exempted_list}
    ...  ${peer_BTS_alias}=${peer_BTS_LTE_CELL_ids_exempted_list}
    ${WCDMA_cell_info_exempted}=  Create Dictionary  ${alias}=${${alias}_RMOD_WCDMA_CELL_ids_list}
    ...  ${peer_BTS_alias}=${${peer_BTS_alias}_RMOD_WCDMA_CELL_ids_list}
    ${GSM_cell_info_exempted}=  Create Dictionary  ${alias}=${${alias}_RMOD_GSM_CELL_ids_list}
    ...  ${peer_BTS_alias}=${${peer_BTS_alias}_RMOD_GSM_CELL_ids_list}
    Check BTS cells are enabled online with exceptions  NR_cell_info_exempted=&{NR_cell_info_exempted}
    ...  LTE_cell_info_exempted=&{LTE_cell_info_exempted}  WCDMA_cell_info_exempted=&{WCDMA_cell_info_exempted}
    ...  GSM_cell_info_exempted=&{GSM_cell_info_exempted}  timeout=3
    Log  All BTS other cells status is OK.  console=True

Unlock shared RMOD
    [Arguments]  ${RMOD_sn}  ${alias}

    Get RMOD info from BTS  ${RMOD_sn}  ${alias}

    Log  ***** Perform "Unlock" operation on shared RMOD ${RMOD_pn} with SN ${RMOD_sn} from BTS ${alias} *****  console=True

    Get Current Date UTC info  initial
    Get Current Time  initial
    ${RMOD_SCF_DN}=  Get RMOD SCF distinguished name  ${${alias}_RMOD_id}  ${alias}
    Perform Administrative State Recommissioning  obj_scf_dn=${RMOD_SCF_DN}  administrativeState=Unlocked  alias=${alias}
    ...  timeout=${RMOD_UNLOCK_MAX_WAIT_TIME}

    Log  Check BTS ${alias} state and alarms after unlock shared RMOD ${RMOD_pn} with SN ${RMOD_sn}  console=True
    Check BTS states and alarms after unlock RMOD  RMOD_sn=${RMOD_sn}  sharing_info=shared  alias=${alias}
    Log  Check ${peer_BTS_alias} BTS state and alarms after unlock shared RMOD ${RMOD_pn} with SN ${RMOD_sn}  console=True
    Check BTS states and alarms after unlock RMOD  RMOD_sn=${RMOD_sn}  sharing_info=shared  alias=${peer_BTS_alias}

    Sleep  5s  reason=Waiting time before check no impact on other cells

    Log  Check all BTS other cells are not impacted by "Unlock" operation on shared RMOD ${RMOD_pn} with SN ${RMOD_sn} from BTS ${alias}  console=True
    ${NR_cell_info_exempted}=  Create Dictionary  ${alias}=${${alias}_RMOD_NR_CELL_ids_list}
    ...  ${peer_BTS_alias}=${${peer_BTS_alias}_RMOD_NR_CELL_ids_list}
    ${BTS_LTE_IOT_CELL_ids_list}=  Create List
    FOR  ${LTE_CELL_id}  IN  @{${alias}_RMOD_LTE_CELL_ids_list}
        ${LTE_IOT_CELL_id}=  Get From Dictionary  ${${alias}_LTE_cell_IOT_mapping_dict}  ${LTE_CELL_id}
        Run Keyword If  '${LTE_IOT_CELL_id}' != 'None'  Append To List  ${BTS_LTE_IOT_CELL_ids_list}  ${LTE_IOT_CELL_id}
    END
    ${BTS_LTE_CELL_ids_exempted_list}=  Combine Lists  ${${alias}_RMOD_LTE_CELL_ids_list}  ${BTS_LTE_IOT_CELL_ids_list}
    ...  ${${alias}_RMOD_LTE_IOT_SA_CELL_ids_list}
    ${peer_BTS_LTE_IOT_CELL_ids_list}=  Create List
    FOR  ${LTE_CELL_id}  IN  @{${peer_BTS_alias}_RMOD_LTE_CELL_ids_list}
        ${LTE_IOT_CELL_id}=  Get From Dictionary  ${${peer_BTS_alias}_LTE_cell_IOT_mapping_dict}  ${LTE_CELL_id}
        Run Keyword If  '${LTE_IOT_CELL_id}' != 'None'  Append To List  ${peer_BTS_LTE_IOT_CELL_ids_list}  ${LTE_IOT_CELL_id}
    END
    ${peer_BTS_LTE_CELL_ids_exempted_list}=  Combine Lists  ${${peer_BTS_alias}_RMOD_LTE_CELL_ids_list}  ${peer_BTS_LTE_IOT_CELL_ids_list}
    ...  ${${peer_BTS_alias}_RMOD_LTE_IOT_SA_CELL_ids_list}
    ${LTE_cell_info_exempted}=  Create Dictionary  ${alias}=${BTS_LTE_CELL_ids_exempted_list}
    ...  ${peer_BTS_alias}=${peer_BTS_LTE_CELL_ids_exempted_list}
    ${WCDMA_cell_info_exempted}=  Create Dictionary  ${alias}=${${alias}_RMOD_WCDMA_CELL_ids_list}
    ...  ${peer_BTS_alias}=${${peer_BTS_alias}_RMOD_WCDMA_CELL_ids_list}
    ${GSM_cell_info_exempted}=  Create Dictionary  ${alias}=${${alias}_RMOD_GSM_CELL_ids_list}
    ...  ${peer_BTS_alias}=${${peer_BTS_alias}_RMOD_GSM_CELL_ids_list}
    Check BTS cells are enabled online with exceptions  NR_cell_info_exempted=&{NR_cell_info_exempted}
    ...  LTE_cell_info_exempted=&{LTE_cell_info_exempted}  WCDMA_cell_info_exempted=&{WCDMA_cell_info_exempted}
    ...  GSM_cell_info_exempted=&{GSM_cell_info_exempted}  timeout=3
    Log  All BTS other cells status is OK.  console=True

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
    ${RMOD_id_LTE_IOT_CELL_ids_dict}=  Get From Dictionary  ${BTS_RMOD_id_CELL_ids_info}  RMOD_id_LTE_IOT_CELL_ids_dict
    ${RMOD_id_LTE_IOT_SA_CELL_ids_dict}=  Get From Dictionary  ${BTS_RMOD_id_CELL_ids_info}  RMOD_id_LTE_IOT_SA_CELL_ids_dict
    ${RMOD_id_WCDMA_CELL_ids_dict}=  Get From Dictionary  ${BTS_RMOD_id_CELL_ids_info}  RMOD_id_WCDMA_CELL_ids_dict
    ${RMOD_id_GSM_CELL_ids_dict}=  Get From Dictionary  ${BTS_RMOD_id_CELL_ids_info}  RMOD_id_GSM_CELL_ids_dict
    ${RMOD_NR_CELL_ids_list}=  Get From Dictionary  ${RMOD_id_NR_CELL_ids_dict}  ${${alias}_RMOD_id}
    ${RMOD_LTE_CELL_ids_list}=  Get From Dictionary  ${RMOD_id_LTE_CELL_ids_dict}  ${${alias}_RMOD_id}
    ${RMOD_LTE_IOT_CELL_ids_list}=  Get From Dictionary  ${RMOD_id_LTE_IOT_CELL_ids_dict}  ${${alias}_RMOD_id}
    ${RMOD_LTE_IOT_SA_CELL_ids_list}=  Get From Dictionary  ${RMOD_id_LTE_IOT_SA_CELL_ids_dict}  ${${alias}_RMOD_id}
    ${RMOD_WCDMA_CELL_ids_list}=  Get From Dictionary  ${RMOD_id_WCDMA_CELL_ids_dict}  ${${alias}_RMOD_id}
    ${RMOD_GSM_CELL_ids_list}=  Get From Dictionary  ${RMOD_id_GSM_CELL_ids_dict}  ${${alias}_RMOD_id}
    Set Test Variable  ${${alias}_RMOD_NR_CELL_ids_list}  ${RMOD_NR_CELL_ids_list}
    Set Test Variable  ${${alias}_RMOD_LTE_CELL_ids_list}  ${RMOD_LTE_CELL_ids_list}
    Set Test Variable  ${${alias}_RMOD_LTE_IOT_CELL_ids_list}  ${RMOD_LTE_IOT_CELL_ids_list}
    Set Test Variable  ${${alias}_RMOD_LTE_IOT_SA_CELL_ids_list}  ${RMOD_LTE_IOT_SA_CELL_ids_list}
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
    ${RMOD_id_LTE_IOT_CELL_ids_dict}=  Get From Dictionary  ${BTS_RMOD_id_CELL_ids_info}  RMOD_id_LTE_IOT_CELL_ids_dict
    ${RMOD_id_LTE_IOT_SA_CELL_ids_dict}=  Get From Dictionary  ${BTS_RMOD_id_CELL_ids_info}  RMOD_id_LTE_IOT_SA_CELL_ids_dict
    ${RMOD_id_WCDMA_CELL_ids_dict}=  Get From Dictionary  ${BTS_RMOD_id_CELL_ids_info}  RMOD_id_WCDMA_CELL_ids_dict
    ${RMOD_id_GSM_CELL_ids_dict}=  Get From Dictionary  ${BTS_RMOD_id_CELL_ids_info}  RMOD_id_GSM_CELL_ids_dict
    ${RMOD_NR_CELL_ids_list}=  Get From Dictionary  ${RMOD_id_NR_CELL_ids_dict}  ${${peer_BTS_alias}_RMOD_id}
    ${RMOD_LTE_CELL_ids_list}=  Get From Dictionary  ${RMOD_id_LTE_CELL_ids_dict}  ${${peer_BTS_alias}_RMOD_id}
    ${RMOD_LTE_IOT_CELL_ids_list}=  Get From Dictionary  ${RMOD_id_LTE_IOT_CELL_ids_dict}  ${${peer_BTS_alias}_RMOD_id}
    ${RMOD_LTE_IOT_SA_CELL_ids_list}=  Get From Dictionary  ${RMOD_id_LTE_IOT_SA_CELL_ids_dict}  ${${peer_BTS_alias}_RMOD_id}
    ${RMOD_WCDMA_CELL_ids_list}=  Get From Dictionary  ${RMOD_id_WCDMA_CELL_ids_dict}  ${${peer_BTS_alias}_RMOD_id}
    ${RMOD_GSM_CELL_ids_list}=  Get From Dictionary  ${RMOD_id_GSM_CELL_ids_dict}  ${${peer_BTS_alias}_RMOD_id}
    Set Test Variable  ${${peer_BTS_alias}_RMOD_NR_CELL_ids_list}  ${RMOD_NR_CELL_ids_list}
    Set Test Variable  ${${peer_BTS_alias}_RMOD_LTE_CELL_ids_list}  ${RMOD_LTE_CELL_ids_list}
    Set Test Variable  ${${peer_BTS_alias}_RMOD_LTE_IOT_CELL_ids_list}  ${RMOD_LTE_IOT_CELL_ids_list}
    Set Test Variable  ${${peer_BTS_alias}_RMOD_LTE_IOT_SA_CELL_ids_list}  ${RMOD_LTE_IOT_SA_CELL_ids_list}
    Set Test Variable  ${${peer_BTS_alias}_RMOD_WCDMA_CELL_ids_list}  ${RMOD_WCDMA_CELL_ids_list}
    Set Test Variable  ${${peer_BTS_alias}_RMOD_GSM_CELL_ids_list}  ${RMOD_GSM_CELL_ids_list}

    ${RMOD_interface}=  Get From Dictionary  ${${peer_BTS_alias}_RMOD_sn_interface_dict}  ${RMOD_sn}
    Set Test Variable  ${RMOD_interface}

Check BTS states and alarms after lock RMOD
    [Arguments]  ${RMOD_sn}  ${sharing_info}  ${alias}  ${lock_triggered_from}

    Log  Check BTS ${alias} ${sharing_info} RMOD ${RMOD_pn} with SN ${RMOD_sn} status:  console=True
    ${remained_MAX_WAIT_TIME}=  Get elapsed time  ${time_initial}  ${RMOD_LOCK_MAX_WAIT_TIME}
    Check BTS RMOD state  ${RMOD_sn}  ${RMOD_state_locked_check}  ${RMOD_state_locked}  ${remained_MAX_WAIT_TIME}  ${alias}

    Log  Check BTS ${alias} cells status mapped on ${sharing_info} RMOD ${RMOD_pn} with SN ${RMOD_sn}:  console=True
    Wait Until Keyword Succeeds  30s  10s  Check cells state mapped on RMOD  ${alias}  ${lock_triggered_from}

    Log  Check BTS ${alias} alarms:  console=True
    ${BTS_EXPECTED_ALARMS_full}=  Create List
    ${BTS_IGNORED_ALARMS_full}=  Combine Lists  ${${alias.upper()}_IGNORED_ALARMS_ALARMS_LOCK_RM}  ${${alias.upper()}_IGNORED_ALARMS_4003}
    ...  ${${alias.upper()}_IGNORED_ALARMS}
    Run Keyword If  '${lock_triggered_from}' != '${alias}'  Append To List  ${BTS_EXPECTED_ALARMS_full}  @{${alias.upper()}_EXPECTED_ALARMS_1931}

    Run Keyword If  '${lock_triggered_from}' != '${alias}'
    ...  Log  BTS ${alias} "RF Module blocked (1931)" alarm, expected number: 1  console=True
    Get and Check Alarms SOAM  alias=${alias}  poll_interval=5 sec  expected_alarms=${BTS_EXPECTED_ALARMS_full}
    ...  ignored_alarms=${BTS_IGNORED_ALARMS_full}  critical_alarms=${${alias.upper()}_CRITICAL_ALARMS}
    Run Keyword If  '${lock_triggered_from}' != '${alias}'
    ...  Log  BTS ${alias} "RF Module blocked (1931)" alarm, found number: 1, as expected!  console=True
    Log  ${alias} site - expected, ignored and critical alarms checked  console=True

Check BTS states and alarms after unlock RMOD
    [Arguments]  ${RMOD_sn}  ${sharing_info}  ${alias}

    Log  Check BTS ${alias} ${sharing_info} RMOD ${RMOD_pn} with SN ${RMOD_sn} status:  console=True
    ${remained_MAX_WAIT_TIME}=  Get elapsed time  ${time_initial}  ${RMOD_UNLOCK_MAX_WAIT_TIME}
    Check BTS RMOD state  ${RMOD_sn}  ${RMOD_state_unlocked_check}  ${RMOD_state_unlocked}  ${remained_MAX_WAIT_TIME}  ${alias}

    Log  Check BTS ${alias} cells mapped on ${sharing_info} RMOD ${RMOD_pn} with SN ${RMOD_sn} status:  console=True
    ${remained_MAX_WAIT_TIME}=  Get elapsed time  ${time_initial}  ${RMOD_UNLOCK_MAX_WAIT_TIME}
    Check BTS RMOD cell state  ${RMOD_sn}  ${${alias}_RMOD_NR_CELL_ids_list}  ${${alias}_RMOD_LTE_CELL_ids_list}
    ...  ${${alias}_RMOD_WCDMA_CELL_ids_list}  ${${alias}_RMOD_GSM_CELL_ids_list}  ${CELL_state_enabled_check}
    ...  ${CELL_state_enabled}  ${remained_MAX_WAIT_TIME}  ${alias}

    Log  Check BTS ${alias} alarms:  console=True
    Get and Check Alarms SOAM  alias=${alias}  poll_interval=5 sec  expected_alarms=@{EMPTY}
    ...  ignored_alarms=${${alias.upper()}_IGNORED_ALARMS}  critical_alarms=${${alias.upper()}_CRITICAL_ALARMS}
    Log  ${alias} site - expected, ignored and critical alarms checked  console=True

Check BTS RMOD state
    [Arguments]  ${RMOD_sn}  ${RMOD_state_check}  ${RMOD_state}  ${timeout}  ${alias}
    Assert  class_name=RMOD  id=${${alias}_RMOD_id}  parameters=${RMOD_state_check}  timeout=${timeout}  connection=${alias}
    Log  BTS ${alias} RMOD ${RMOD_pn} with SN ${RMOD_sn} status:\n - ${RMOD_state}  console=True

Check BTS RMOD cell state
    [Arguments]  ${RMOD_sn}  ${RMOD_NR_CELL_ids}  ${RMOD_LTE_CELL_ids}  ${RMOD_WCDMA_CELL_ids}  ${RMOD_GSM_NR_CELL_ids}  ${CELL_state_check}
    ...  ${CELL_state}  ${timeout}  ${alias}

    FOR  ${item}  IN  @{RMOD_NR_CELL_ids}
        Assert  class_name=NRCEL  id=${item}  parameters=${CELL_state_check}  timeout=${timeout}  connection=${alias}
        ${timeout}=  Get elapsed time  ${time_initial}  ${RMOD_UNLOCK_MAX_WAIT_TIME}
    END

    FOR  ${item}  IN  @{RMOD_LTE_CELL_ids}
        Assert  class_name=LNCEL  id=${item}  parameters=${CELL_state_check}  timeout=${timeout}  connection=${alias}
        ${timeout}=  Get elapsed time  ${time_initial}  ${RMOD_UNLOCK_MAX_WAIT_TIME}
    END

    FOR  ${item}  IN  @{RMOD_WCDMA_CELL_ids}
        Assert  class_name=WNCEL  id=${item}  parameters=${CELL_state_check}  timeout=${timeout}  connection=${alias}
        ${timeout}=  Get elapsed time  ${time_initial}  ${RMOD_UNLOCK_MAX_WAIT_TIME}
    END

    FOR  ${item}  IN  @{RMOD_GSM_NR_CELL_ids}
        Assert  class_name=GNCEL  id=${item}  parameters=${CELL_state_check}  timeout=${timeout}  connection=${alias}
        ${timeout}=  Get elapsed time  ${time_initial}  ${RMOD_UNLOCK_MAX_WAIT_TIME}
    END

    Log  BTS ${alias} cells mapped on RMOD ${RMOD_pn} with SN ${RMOD_sn} status:\n - ${CELL_state}  console=True

Check cells state mapped on RMOD
    [Arguments]  ${alias}  ${lock_triggered_from}

    ${LTE_IOT_SA_CELL_state_check}=  Set Variable If  '${lock_triggered_from}' == '${alias}'  ${CELL_state_disabled_dependency_check}
    ...  ${CELL_state_disabled_failed_check}
    ${LTE_IOT_SA_CELL_state}=  Set Variable If  '${lock_triggered_from}' == '${alias}'  ${CELL_state_disabled_dependency}
    ...  ${CELL_state_disabled_failed}

    ${NR_cell_state_degraded_list}  ${NR_cell_state_failed_list}=  Run Keyword If  ${${alias}_RMOD_NR_CELL_ids_list}
    ...  Check NR cells state and MIMO alarm  cell_list=${${alias}_RMOD_NR_CELL_ids_list}  alias=${alias}

    ${LTE_cell_state_degraded_list}  ${LTE_cell_state_failed_list}=  Run Keyword If  ${${alias}_RMOD_LTE_CELL_ids_list}
    ...  Check LTE cells state and MIMO alarm  cell_list=${${alias}_RMOD_LTE_CELL_ids_list}  alias=${alias}

    ${WCDMA_cell_state_degraded_list}  ${WCDMA_cell_state_failed_list}=  Run Keyword If  ${${alias}_RMOD_WCDMA_CELL_ids_list}
    ...  Check WCDMA cells state and MIMO alarm  cell_list=${${alias}_RMOD_WCDMA_CELL_ids_list}  alias=${alias}

    ${GSM_cell_state_degraded_list}  ${GSM_cell_state_failed_list}=  Run Keyword If  ${${alias}_RMOD_GSM_CELL_ids_list}
    ...  Check GSM cells state and MIMO alarm  cell_list=${${alias}_RMOD_GSM_CELL_ids_list}  alias=${alias}

    Return From Keyword If  '${LTE_IOT_check}' != 'True'

    FOR  ${item}  IN  @{${alias}_RMOD_LTE_IOT_SA_CELL_ids_list}

        Assert  class_name=LNCEL  id=${item}  parameters=${LTE_IOT_SA_CELL_state_check}  connection=${alias}
        Log  ${alias} LNCEL ${item} status:\n - ${LTE_IOT_SA_CELL_state}  console=True

    END

    FOR  ${item}  IN  @{${alias}_RMOD_LTE_CELL_ids_list}

        ${LTE_IOT_CELL_check}=  Run Keyword And Return Status  Dictionary Should Contain Key  ${${alias}_LTE_cell_IOT_mapping_dict}  ${item}
        Continue For Loop If  not ${LTE_IOT_CELL_check}

        ${LTE_IOT_CELL_id}=  Get From Dictionary  ${${alias}_LTE_cell_IOT_mapping_dict}  ${item}
        Continue For Loop If  '${LTE_IOT_CELL_id}' == 'None'

        ${LTE_CELL_info}=  Assert  class_name=LNCEL  id=${item}  connection=${alias}
        ${LTE_CELL_operationalState}=  Get From Dictionary  ${LTE_CELL_info}  operationalState
        ${LTE_IOT_CELL_state_check}=  Set Variable If  '${LTE_CELL_operationalState}' == 'disabled'  ${CELL_state_disabled_offline_check}
        ...  ${CELL_state_enabled_degraded_check}
        ${LTE_IOT_CELL_state}=  Set Variable If  '${LTE_CELL_operationalState}' == 'disabled'  ${CELL_state_disabled_offline}
        ...  ${CELL_state_enabled_degraded}

        Assert  class_name=LNCEL  id=${LTE_IOT_CELL_id}  parameters=${LTE_IOT_CELL_state_check}  connection=${alias}
        Log  ${alias} LNCEL ${LTE_IOT_CELL_id} status:\n - ${LTE_IOT_CELL_state}  console=True

    END

Particular Teardown
    FOR  ${alias}  IN  @{alias_list}
        Admin Check If BTS Objects Are Unlocked  class_name=RMOD  timeout=60  recover_timeout=60  connection=${alias}
    END

TC Setup
    ${tech_preset_list}=  Create List  SBTS  SBTS  SBTS  SBTS
    Common Test Setup  preset_techs=${tech_preset_list}  common_sbts=${TRUE}  infomodelSetup=${FALSE}

TC Teardown
    Common Test Teardown
