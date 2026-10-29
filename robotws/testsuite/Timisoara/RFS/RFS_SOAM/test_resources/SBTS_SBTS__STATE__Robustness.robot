*** Settings ***
Documentation    TC__SBTS_SBTS__STATE__Robustness
Variables    tc_variables/sbts_sbts__state__robustness_alarms_definitions.py
Resource    ../../resources/rfs_frame_rfs_soam_taf.robot

*** Variables ***
${BTS}                            # BTS on which OAM operation is performed. No need to set if ${RESOURCE} is set RMOD and ${OAM_OPERATION} is set
                                  # Power Off or Power On. Possible values: BTS1 or BTS2
${OAM_OPERATION}                  # OAM operation performed on BTS. Possible values: Reset, Lock, Unlock, Block, Unblock, Power Off, Power On
${RESOURCE}                       # BTS resource on which OAM operation is performed. Possible values: BTS, SMOD, BBMOD, FHS, RMOD, NRCEL, LNCEL,
                                  # WNCEL, GNCEL or RAT
${HW_SN_LIST}                     # Only if ${RESOURCE} is set SMOD, BBMOD, FHS or RMOD. HW serial number list on which OAM operation is performed on
                                  # selected ${BTS}. All HW serial numbers must belong to the same HW type selected in ${RESOURCE}
${CELL_ID_LIST}                   # Only if ${RESOURCE} is set NRCEL, LNCEL, WNCEL or GNCEL. Cell ID list on which OAM operation is performed on
                                  # selected ${BTS}. Cell ID refers to NR global cell ID (if ${RESOURCE} set NRCEL), LTE global cell ID (if
                                  # ${RESOURCE} set LNCEL), WCDMA cell ID (if ${RESOURCE} set WNCEL) or GSM sector ID (if ${RESOURCE} set GNCEL)
${RAT_LIST}                       # Only if ${RESOURCE} is set RAT. RAT on which OAM operation is performed on selected ${BTS}. Possible values: NR,
                                  # LTE, WCDMA or GSM
${RAT_RESET_TYPE}          Soft   # Only if ${RESOURCE} is set RAT. RAT reset type: Soft or Hard; default value: Soft
${GRACEFUL_CELL_SHUTDOWN}  True   # Graceful cell shutdown: True or False; default value: True
${RESET_WITHOUT_RU}        False  # Only if ${RESOURCE} is set BTS and ${OAM_OPERATION} is set Reset. Reset Site without RU reset: True or False;
                                  # default value: False
${OAM_OPERATION_TIMEOUT}   300    # OAM operation timeout to be completed; default value 300 seconds
${BTS_STABLE_TIME}         10     # Waiting time for BTS resource to get stable status; default value 10 seconds
${CRITICAL_FAULT_ID_LIST}         # Critical alarms (defined by fault ID list separated by comma) to be checked in active or historic alarm info: if
                                  # found test will be failed.
${LOAD_HISTORY}            False  # Flag to specify if load BTS historic alarms for current session (False) or entire BTS history (True); default
                                  # value False
${SNAPSHOT_COLLECT}        False  # Flag to specify if snapshot will be collected even passed verdict: True or False; default value: False

*** Keywords ***
TC__SBTS_SBTS__STATE__Robustness
     [Documentation]
    ...  [CASE LINK]: https://jiradc.ext.net.nokia.com/browse/TAT-30030
    ...
    ...  *****************
    ...  Basic information
    ...  *****************
    ...  SBTS-SBTS test case for BTS robustness testing.
    ...  The main steps performed for the test are:
    ...  - get initial all BTS resources states
    ...  - get initial all BTS alarms
    ...  - perform OAM operation on BTS resource
    ...  - get final all BTS resources states
    ...  - get final all BTS alarms
    ...  - get all BTS resources changes
    ...  - collect BTS snapshot info (if ${SNAPSHOT_COLLECT} is set True)
    ...
    ...  ******************
    ...  History of changes
    ...  ******************
    ...  - 05.11.2025 - https://jiradc.ext.net.nokia.com/browse/TAT-30030 - [EDA Robustness] Create robustness TC for single basic action
    ...  - 22.01.2026 - https://jiradc.ext.net.nokia.com/browse/TAT-30409 - Updates for SBTS_SBTS__STATE__Robustness
    ...  - 24.02.2026 - https://jiradc.ext.net.nokia.com/browse/TAT-30544 - Some enhancements (historical alarms check and FID alarm list comparison)
    ...    for SBTS_SBTS__STATE__Robustness robot
    ...

    Set Tags    CA-STATE    OWNER-valentin.marian@nokia.com    AUTHOR-dinu.olariu@nokia.com    PHASE-QT    SW-SBTS26R2

    TC Preconditions
    Step 1: Get initial all BTS resources states
    Step 2: Get initial all BTS alarms
    Step 3: Perform OAM operation on BTS resource
    Step 4: Get final all BTS resources states
    Step 5: Get final all BTS alarms
    Step 6: Get all BTS resources changes
    Step 7: Get all BTS alarms changes
    Step 8: Collect BTS snapshot info

    [Teardown]  Particular Teardown

TC Preconditions
    Set Test Variable  ${tc_folder_path}  ${Test Results Dir}
    Set Test Variable  ${tc_file_name}  TC_Robustness_info
    Set Test Variable  ${suite_folder_path}  ${OUTPUT DIR}
    Set Test Variable  ${suite_file_name}  Suite_Robustness_info

    ${BTS_alias_label_dict}  ${BTS_label_alias_dict}=  Get BTS alias label info dict
    Set Test Variable  ${BTS_alias_label_dict}
    Set Test Variable  ${BTS_label_alias_dict}
    ${BTS_alias_list}=  Get Dictionary Keys  ${BTS_alias_label_dict}  False
    ${BTS_label_list}=  Get Dictionary Values  ${BTS_alias_label_dict}  False
    Set Test Variable  ${BTS_alias_list}
    Set Test Variable  ${BTS_label_list}

    Check BTS info
    ${BTS_critical_alarms_list}=  Run Keyword If  '${CRITICAL_FAULT_ID_LIST}' != ''
    ...  Get critical alarms list info
    ...  ELSE
    ...  Create List
    Set Test Variable  ${BTS_critical_alarms_list}

    Set Test Variable  ${Block_BTS_state_check}  blockingState=${Blocked_}
    Set Test Variable  ${Unblock_BTS_state_check}  blockingState=${Unblocked_}

    Set Test Variable  ${Lock_HW_state_check}  administrativeState=${Locked_}
    Set Test Variable  ${Unlock_HW_state_check}  administrativeState=${Unlocked_}

    Set Test Variable  ${Block_CELL_state_check}  blockingState=${Blocked_}
    Set Test Variable  ${Unblock_CELL_state_check}  blockingState=${Unblocked_}
    Set Test Variable  ${Lock_CELL_state_check}  administrativeState=${Locked_}
    Set Test Variable  ${Unlock_CELL_state_check}  administrativeState=${Unlocked_}
    Set Test Variable  ${CELL_state_enabled_check}  operationalState=${Enabled_}
    Set Test Variable  ${CELL_state_disabled_check}  operationalState=${Disabled_}

    Set Test Variable  ${Reset_RAT_state_check}  proceduralState=${Commissioned_}
    Set Test Variable  ${Block_RAT_state_check}  blockingState=${Blocked_}
    Set Test Variable  ${Unblock_RAT_state_check}  blockingState=${Unblocked_}

    ${tc_args}=  Create Long String  TC arguments:\n - \${BTS}=${BTS}\n - \${OAM_OPERATION}=${OAM_OPERATION}\n - \${RESOURCE}=${RESOURCE}\n
    ...  - \${HW_SN_LIST}=${HW_SN_LIST}\n - \${CELL_ID_LIST}=${CELL_ID_LIST}\n - \${RAT_LIST}=${RAT_LIST}\n - \${RAT_RESET_TYPE}=${RAT_RESET_TYPE}\n
    ...  - \${GRACEFUL_CELL_SHUTDOWN}=${GRACEFUL_CELL_SHUTDOWN}\n - \${RESET_WITHOUT_RU}=${RESET_WITHOUT_RU}\n
    ...  - \${OAM_OPERATION_TIMEOUT}=${OAM_OPERATION_TIMEOUT}\n - \${BTS_STABLE_TIME}=${BTS_STABLE_TIME}\n
    ...  - \${CRITICAL_FAULT_ID_LIST}=${CRITICAL_FAULT_ID_LIST}\n - \${LOAD_HISTORY}=${LOAD_HISTORY}\n - \${SNAPSHOT_COLLECT}=${SNAPSHOT_COLLECT}

    Export tc run info to tc file  tc_run_info=TC name:\n - ${TEST NAME}
    Export tc run info to tc file  tc_run_info=${tc_args}

    Get all BTS configuration info

    ${all_BTS_RMOD_id_CELL_ids_info}=  Get all BTS Cells mapped on RMOD info
    Set Test Variable  ${all_BTS_RMOD_id_CELL_ids_info}

Step ${index}: Get ${when} all BTS resources states
    Log  \nStep ${index}: Get ${when} all BTS resources states  console=True
    Export tc run info to tc file  tc_run_info=\n***** Get ${when} all BTS resources states *****

    FOR  ${alias}  IN  @{alias_list}

        ${BTS_label}=  Get From Dictionary  ${BTS_alias_label_dict}  ${alias}

        Log  \n***** Get ${when} ${BTS_label} resources states *****  console=True
        ${BTS_info_dict}  ${BTS_HW_info_dict}  ${BTS_CELL_info_dict}=  Get BTS resources states  alias=${alias}
        Set Test Variable  ${${when}_${alias}_BTS_info_dict}  ${BTS_info_dict}
        Set Test Variable  ${${when}_${alias}_HW_info_dict}  ${BTS_HW_info_dict}
        Set Test Variable  ${${when}_${alias}_CELL_info_dict}  ${BTS_CELL_info_dict}

    END

Step ${index}: Get ${when} all BTS alarms
    Log  \nStep ${index}: Get ${when} all BTS alarms  console=True
    Export tc run info to tc file  tc_run_info=\n***** Get ${when} all BTS alarms *****

    FOR  ${alias}  IN  @{alias_list}

        ${BTS_label}=  Get From Dictionary  ${BTS_alias_label_dict}  ${alias}

        Log  \n***** Get ${when} ${BTS_label} active alarms *****  console=True
        ${BTS_active_alarms_info}=  Get BTS active alarms  alias=${alias}
        Set Test Variable  ${${when}_${alias}_active_alarms_info}  ${BTS_active_alarms_info}

    END

    FOR  ${alias}  IN  @{alias_list}

        ${BTS_label}=  Get From Dictionary  ${BTS_alias_label_dict}  ${alias}

        Log  \n***** Get ${when} ${BTS_label} historic alarms *****  console=True
        ${BTS_historic_alarms_info}=  Get BTS historic alarms  alias=${alias}
        Set Test Variable  ${${when}_${alias}_historic_alarms_info}  ${BTS_historic_alarms_info}

    END

Step ${index}: Perform OAM operation on BTS resource
    Log  \nStep ${index}: Perform OAM operation on BTS resource  console=True
    Export tc run info to tc file  tc_run_info=\n***** Perform OAM operation on BTS resource *****

    Run Keyword If  '${RESOURCE.upper()}' == 'RMOD' and '${OAM_OPERATION.title()}' in ['Power Off', 'Power On']
    ...  Perform power operation on RMOD
    ...  ELSE IF  '${RESOURCE.upper()}' == 'BTS'
    ...  Perform OAM operation on BTS  ${BTS_alias}
    ...  ELSE IF    '${RESOURCE.upper()}' in ${HW_list}
    ...  Perform OAM operation on HW  ${BTS_alias}
    ...  ELSE IF  '${RESOURCE.upper()}' in ${CELL_list}
    ...  Perform OAM operation on CELL  ${BTS_alias}
    ...  ELSE IF  '${RESOURCE.upper()}' == 'RAT'
    ...  Perform OAM operation on RAT  ${BTS_alias}

Step ${index}: Get all BTS resources changes
    Log  \nStep ${index}: Get all BTS resources changes  console=True
    Export tc run info to tc file  tc_run_info=\n***** Get all BTS resources changes *****

    FOR  ${alias}  IN  @{alias_list}

        ${BTS_label}=  Get From Dictionary  ${BTS_alias_label_dict}  ${alias}
        Log  \n***** Get ${BTS_label} resources changes *****  console=True
        Get BTS resources changes  alias=${alias}

    END

Step ${index}: Get all BTS alarms changes
    Log  \nStep ${index}: Get all BTS alarms changes  console=True
    Export tc run info to tc file  tc_run_info=\n***** Get all BTS alarms changes *****

    FOR  ${alias}  IN  @{alias_list}

        ${BTS_label}=  Get From Dictionary  ${BTS_alias_label_dict}  ${alias}
        Log  \n***** Get ${BTS_label} active alarms changes *****  console=True
        ${diff_initial_BTS_active_alarms_info}=  Get different items info from lists  ${initial_${alias}_active_alarms_info}
        ...  ${final_${alias}_active_alarms_info}
        Get active alarms info  ${diff_initial_BTS_active_alarms_info}  present  not present  ${alias}
        ${diff_final_BTS_active_alarms_info}=  Get different items info from lists  ${final_${alias}_active_alarms_info}
        ...  ${initial_${alias}_active_alarms_info}
        Get active alarms info  ${diff_final_BTS_active_alarms_info}  not present  present  ${alias}

    END

    FOR  ${alias}  IN  @{alias_list}

        ${BTS_label}=  Get From Dictionary  ${BTS_alias_label_dict}  ${alias}
        Log  \n***** Get ${BTS_label} historic alarms changes *****  console=True
        ${diff_initial_BTS_historic_alarms_info}=  Get different items info from lists  ${initial_${alias}_historic_alarms_info}
        ...  ${final_${alias}_historic_alarms_info}
        Get historic alarms info  ${diff_initial_BTS_historic_alarms_info}  present  not present  ${alias}
        ${diff_final_BTS_historic_alarms_info}=  Get different items info from lists  ${final_${alias}_historic_alarms_info}
        ...  ${initial_${alias}_historic_alarms_info}
        Get historic alarms info  ${diff_final_BTS_historic_alarms_info}  not present  present  ${alias}

    END

Step ${index}: Collect BTS snapshot info

    Return From Keyword If  '${SNAPSHOT_COLLECT}' == 'False'

    Log  \nStep ${index}: Collect BTS snapshot info  console=True
    Export tc run info to tc file  tc_run_info=\n***** Collect BTS snapshot info *****

    ${snapshot_dir}=  Set Variable  ${Test Results Dir}/Snapshot_On_Demand
    ${snapshot_dir_status}=  Run Keyword And Return Status  OperatingSystem.Directory Should Exist  ${snapshot_dir}
    Run Keyword If  not ${snapshot_dir_status}  Create Directory  ${snapshot_dir}

    FOR  ${item}  IN  @{alias_list}

        ${BTS_label}=  Get From Dictionary  ${BTS_alias_label_dict}  ${item}

        Log  \n***** Collect ${BTS_label} snapshot info *****  console=True
        Export tc run info to tc file  tc_run_info=\n***** Collect ${BTS_label} snapshot info *****

        ${target_file_name}=  Set Variable  ${snapshot_dir}/${item}_snapshot.zip
        Trigger BTS snapshot collect  ${target_file_name}  ${item}

    END

Get critical alarms list info
    ${CRITICAL_FAULT_ID_LIST_strip}=  Replace String  ${CRITICAL_FAULT_ID_LIST}  ${SPACE}  ${EMPTY}
    ${BTS_critical_alarms_list}=  Split String  ${CRITICAL_FAULT_ID_LIST_strip}  ,

    [Return]  ${BTS_critical_alarms_list}

Check BTS info
    ${RESOURCE_list}=  Create List  BTS  RAT  SMOD  BBMOD  FHS  RMOD  NRCEL  LNCEL  WNCEL  GNCEL
    ${RESOURCE_Reset_list}=  Create List  BTS  RAT  SMOD  BBMOD  FHS  RMOD  CELL
    ${RESOURCE_Lock_Unlock_list}=  Create List  NRDU  BBMOD  FHS  RMOD  NRCEL  LNCEL  GNCEL
    ${RESOURCE_Block_Unblock_list}=  Create List  BTS  RAT  NRCEL  LNCEL  WNCEL  GNCEL
    ${RESOURCE_Power_Off_On_list}=  Create List  RMOD
    ${OAM_OPERATION_Reset_list}=  Create List  Reset
    ${OAM_OPERATION_Lock_Unlock_list}=  Create List  Lock  Unlock
    ${OAM_OPERATION_Block_Unblock_list}=  Create List  Block  Unblock
    ${OAM_OPERATION_Power_Off_On_list}=  Create List  Power Off  Power On
    ${OAM_OPERATION_list}=  Combine Lists  ${OAM_OPERATION_Reset_list}  ${OAM_OPERATION_Lock_Unlock_list}  ${OAM_OPERATION_Block_Unblock_list}
    ...  ${OAM_OPERATION_Power_Off_On_list}
    ${HW_list}=  Create List  SMOD  BBMOD  FHS  RMOD
    Set Test Variable  ${HW_list}
    ${CELL_list}=  Create List  NRCEL  LNCEL  WNCEL  GNCEL
    Set Test Variable  ${CELL_list}

    Run Keyword If  '${BTS}' == '' and '${OAM_OPERATION.title()}' not in ${OAM_OPERATION_Power_Off_On_list}  Run Keywords
    ...  Log  No BTS selected. Please select value for test argument \${BTS} from: ${BTS_label_list}  console=True
    ...  AND  Fail  Improper value for argument!
    ...  ELSE IF  '${BTS}' not in ${BTS_label_list} and '${OAM_OPERATION.title()}' not in ${OAM_OPERATION_Power_Off_On_list}  Run Keywords
    ...  Log  Selected BTS: ${BTS} is not valid. Please select value for test argument \${BTS} from: ${BTS_label_list}  console=True
    ...  AND  Fail  Improper value for argument!

    ${BTS_alias}=  Run Keyword If  '${BTS}' != ''
    ...  Get From Dictionary  ${BTS_label_alias_dict}  ${BTS}
    Set Test Variable  ${BTS_alias}

    Run Keyword If  '${OAM_OPERATION}' == ''  Run Keywords
    ...  Log  No OAM operation selected. Please select value for test argument \${OAM_OPERATION} from: ${OAM_OPERATION_list}  console=True
    ...  AND  Fail  Improper value for argument!
    ...  ELSE IF  '${OAM_OPERATION.title()}' not in ${OAM_OPERATION_list}  Run Keywords
    ...  Log Long String  Selected OAM operation: ${OAM_OPERATION} is not valid. Please select value for test argument \${OAM_OPERATION} from:
    ...  ${OAM_OPERATION_list}  console=True
    ...  AND  Fail  Improper value for argument!

    Run Keyword If  '${RESOURCE}' == ''  Run Keywords
    ...  Log  No resource selected. Please select value for test argument \${RESOURCE} from: ${RESOURCE_list}  console=True
    ...  AND  Fail  Improper value for argument!
    ...  ELSE IF  '${RESOURCE.upper()}' not in ${RESOURCE_list}  Run Keywords
    ...  Log  Selected resource: ${RESOURCE} is not valid. Please select value for test argument \${RESOURCE} from: ${RESOURCE_list}  console=True
    ...  AND  Fail  Improper value for argument!

    Run Keyword If  '${OAM_OPERATION.title()}' in ${OAM_OPERATION_Reset_list} and '${RESOURCE.upper()}' not in ${RESOURCE_Reset_list}
    ...  Run Keywords
    ...  Log Long String  Selected OAM operation: ${OAM_OPERATION} and resource: ${RESOURCE} are not compatible. Please select value for test
    ...  argument \${RESOURCE} from: ${RESOURCE_Reset_list}  console=True
    ...  AND  Fail  Improper value for argument!

    Run Keyword If  '${OAM_OPERATION.title()}' in ${OAM_OPERATION_Lock_Unlock_list} and '${RESOURCE.upper()}' not in ${RESOURCE_Lock_Unlock_list}
    ...  Run Keywords
    ...  Log Long String  Selected OAM operation: ${OAM_OPERATION} and resource: ${RESOURCE} are not compatible. Please select value for test
    ...  argument \${RESOURCE} from: ${RESOURCE_Lock_Unlock_list}  console=True
    ...  AND  Fail  Improper value for argument!

    Run Keyword If  '${OAM_OPERATION.title()}' in ${OAM_OPERATION_Block_Unblock_list} and '${RESOURCE.upper()}' not in ${RESOURCE_Block_Unblock_list}
    ...  Run Keywords
    ...  Log Long String  Selected OAM operation: ${OAM_OPERATION} and resource: ${RESOURCE} are not compatible. Please select value for test
    ...  argument \${RESOURCE} from: ${RESOURCE_Block_Unblock_list}  console=True
    ...  AND  Fail  Improper value for argument!

    Run Keyword If  '${OAM_OPERATION.title()}' in ${OAM_OPERATION_Power_Off_On_list} and '${RESOURCE.upper()}' not in ${RESOURCE_Power_Off_On_list}
    ...  Run Keywords
    ...  Log Long String  Selected OAM operation: ${OAM_OPERATION} and resource: ${RESOURCE} are not compatible. Please select value for test
    ...  argument \${RESOURCE} from: ${RESOURCE_Power_Off_On_list}  console=True
    ...  AND  Fail  Improper value for argument!

    Run Keyword If  '${RESOURCE.upper()}' == 'RMOD' and '${OAM_OPERATION.title()}' in ${OAM_OPERATION_Power_Off_On_list}
    ...  Check all BTS HW info
    ...  ELSE IF  '${RESOURCE.upper()}' in ${HW_list}
    ...  Check HW info  ${BTS_alias}
    ...  ELSE IF  '${RESOURCE.upper()}' in ${CELL_list}
    ...  Check CELL info  ${BTS_alias}
    ...  ELSE IF  '${RESOURCE.upper()}' == 'RAT'
    ...  Check RAT info  ${BTS_alias}

Check all BTS HW info

    ${all_BTS_HW_sn_list}=  Create List

    FOR  ${item}  IN  @{alias_list}

        ${HW_id_sn_dict}  ${HW_sn_id_dict}=  Get BTS HW sn id info  HW_class_name=${RESOURCE}  alias=${item}
        Set Test Variable  ${${item}_HW_id_sn_dict}  ${HW_id_sn_dict}
        Set Test Variable  ${${item}_HW_sn_id_dict}  ${HW_sn_id_dict}
        ${BTS_HW_sn_list}=  Get Dictionary Keys  ${HW_sn_id_dict}
        Append To List  ${all_BTS_HW_sn_list}  @{BTS_HW_sn_list}

    END

    ${all_BTS_HW_sn_list}=  Remove Duplicates  ${all_BTS_HW_sn_list}
    ${selected_HW_sn_list}=  Check item list  HW_sn_LIST  ${all_BTS_HW_sn_list}
    Set Test Variable  ${BTS_HW_sn_list}  ${selected_HW_sn_list}

Check HW info
    [Arguments]  ${alias}

    ${BTS_HW_id_list}=  Get Ids For All  class_name=${RESOURCE}  connection=${alias}
    ${BTS_HW_count}=  Get Length  ${BTS_HW_id_list}

    Run Keyword If  ${BTS_HW_count} == 0  Run Keywords
    ...  Log  No ${RESOURCE} configured on ${BTS}. Please select value(s) for test argument \${RESOURCE} according to ${BTS} configuration!
    ...  console=True
    ...  AND  Fail  Improper value for argument!

    Run Keyword If  '${HW_SN_LIST}' == ''  Run Keywords
    ...  Log  No selected HW serial number list. Please select value(s) for test argument \${HW_SN_LIST} according to ${BTS} configuration!
    ...  console=True
    ...  AND  Fail  Improper value for argument!

    ${HW_id_sn_dict}  ${HW_sn_id_dict}=  Get BTS HW sn id info  HW_class_name=${RESOURCE}  alias=${alias}
    Set Test Variable  ${HW_id_sn_dict}
    Set Test Variable  ${HW_sn_id_dict}

    ${BTS_HW_sn_list}=  Get Dictionary Keys  ${HW_sn_id_dict}
    ${selected_HW_sn_list}=  Check item list  HW_sn_LIST  ${BTS_HW_sn_list}
    Set Test Variable  ${BTS_HW_sn_list}  ${selected_HW_sn_list}

Get BTS HW sn id info
    [Arguments]  ${HW_class_name}  ${alias}

    ${HW_id_sn_dict}=  Create Dictionary
    ${HW_sn_id_dict}=  Create Dictionary

    ${BTS_HW_id_list}=  Get Ids For All  class_name=${HW_class_name}  connection=${alias}

    FOR  ${BTS_HW_id}  IN  @{BTS_HW_id_list}

        ${BTS_HW_info}=  Get Parameters For  class_name=${HW_class_name}  id_num=${BTS_HW_id}  connection=${alias}
        ${BTS_HW_sn}=  Get From Dictionary  ${BTS_HW_info}  serialNumber
        Set To Dictionary  ${HW_id_sn_dict}  ${BTS_HW_id}  ${BTS_HW_sn}
        Set To Dictionary  ${HW_sn_id_dict}  ${BTS_HW_sn}  ${BTS_HW_id}

    END

    [Return]  ${HW_id_sn_dict}  ${HW_sn_id_dict}

Check CELL info
    [Arguments]  ${alias}

    ${BTS_CELL_id_list}=  Get Ids For All  class_name=${RESOURCE}  connection=${alias}
    ${BTS_CELL_count}=  Get Length  ${BTS_CELL_id_list}

    Run Keyword If  ${BTS_CELL_count} == 0  Run Keywords
    ...  Log  No ${RESOURCE} configured on ${BTS}. Please select value(s) for test argument \${RESOURCE} according to ${BTS} configuration!
    ...  console=True
    ...  AND  Fail  Improper value for argument!

    Run Keyword If  '${CELL_ID_LIST}' == ''  Run Keywords
    ...  Log  No selected cell id list. Please select value(s) for argument \${CELL_ID_LIST} according to ${BTS} configuration!  console=True
    ...  AND  Fail  Improper value for argument!

    ${CELL_identifier_id_dict}  ${CELL_identifier_dn_dict}  ${CELL_id_dn_dict}=  Get configured CELL info  ${RESOURCE}  ${alias}
    ${CELL_identifier_list}=  Get Dictionary Keys  ${CELL_identifier_id_dict}
    ${selected_CELL_identifier_list}=  Check item list  CELL_ID_LIST  ${CELL_identifier_list}
    Set Test Variable  ${BTS_CELL_identifier_list}  ${selected_CELL_identifier_list}
    Set Test Variable  ${${alias}_${RESOURCE}_identifier_id_dict}  ${CELL_identifier_id_dict}
    Set Test Variable  ${${alias}_${RESOURCE}_identifier_dn_dict}  ${CELL_identifier_dn_dict}

Check RAT info
    [Arguments]  ${alias}

    Run Keyword If  '${RAT_LIST}' == ''  Run Keywords
    ...  Log  No selected RAT. Please select value(s) for test argument \${RAT_LIST} according to ${BTS} configuration!  console=True
    ...  AND  Fail  Improper value for argument!

    ${configured_RAT_list}=  Get configured RAT info  ${alias}

    ${selected_RAT_list}=  Check item list  RAT_LIST  ${configured_RAT_list}
    Set Test Variable  ${BTS_RAT_list}  ${selected_RAT_list}

Get all configured CELL info
    [Arguments]  ${alias}

    ${BTS_CELL_identifier_id_dict}=  Create Dictionary
    ${BTS_CELL_identifier_dn_dict}=  Create Dictionary
    ${BTS_CELL_id_dn_dict}=  Create Dictionary

    FOR  ${item}  IN  @{CELL_list}

        ${CELL_identifier_id_dict}  ${CELL_identifier_dn_dict}  ${CELL_id_dn_dict}=  Get configured CELL info  ${item}  ${alias}

        ${BTS_CELL_identifier_id_dict}=  Append Dictionary To Target Dictionary  ${BTS_CELL_identifier_id_dict}  ${CELL_identifier_id_dict}
        ${BTS_CELL_identifier_dn_dict}=  Append Dictionary To Target Dictionary  ${BTS_CELL_identifier_dn_dict}  ${CELL_identifier_dn_dict}
        ${BTS_CELL_id_dn_dict}=  Append Dictionary To Target Dictionary  ${BTS_CELL_id_dn_dict}  ${CELL_id_dn_dict}

    END

    [Return]  ${BTS_CELL_identifier_id_dict}  ${BTS_CELL_identifier_dn_dict}  ${BTS_CELL_id_dn_dict}

Get configured CELL info
    [Arguments]  ${CELL_class_name}  ${alias}

    ${CELL_identifier_id_dict}=  Create Dictionary
    ${CELL_identifier_dn_dict}=  Create Dictionary
    ${CELL_id_dn_dict}=  Create Dictionary
    ${CELL_type}=  Set variable If  '${CELL_class_name}' == 'NRCEL'  nr  '${CELL_class_name}' == 'LNCEL'  lte  '${CELL_class_name}' == 'WNCEL'  wcdma
    ...  '${CELL_class_name}' == 'GNCEL'  gsm
    ${CELL_identifier_info}=  Set variable If  '${CELL_class_name}' == 'NRCEL'  globalCellId  '${CELL_class_name}' == 'LNCEL'  globalCellId
    ...  '${CELL_class_name}' == 'WNCEL'  cellId  '${CELL_class_name}' == 'GNCEL'  gsmSectorID

    ${cells_info}=  Get Cells Info  cell_type=${CELL_type}  timeout=10  connection=${alias}

    FOR  ${item}  IN  @{cells_info}
        ${CELL_identifier}=  Get From Dictionary  ${item}  ${CELL_identifier_info}
        ${CELL_identifier}=  Convert To String  ${CELL_identifier}
        Set To Dictionary  ${CELL_identifier_id_dict}  ${CELL_identifier}  ${item['id']['internal']}
        Set To Dictionary  ${CELL_identifier_dn_dict}  ${CELL_identifier}  ${item['id']['configuration']}
        Set To Dictionary  ${CELL_id_dn_dict}  ${item['id']['internal']}  ${item['id']['configuration']}
    END

    [Return]  ${CELL_identifier_id_dict}  ${CELL_identifier_dn_dict}  ${CELL_id_dn_dict}

Get configured RAT info
    [Arguments]  ${alias}

    ${configured_RAT_list}=  Create List

    ${BTS_NR_cell_id_list}=  Get Ids For All  class_name=NRCEL  connection=${alias}
    ${BTS_NR_cell_count}=  Get Length  ${BTS_NR_cell_id_list}
    ${BTS_LTE_cell_id_list}=  Get Ids For All  class_name=LNCEL  connection=${alias}
    ${BTS_LTE_cell_count}=  Get Length  ${BTS_LTE_cell_id_list}
    ${BTS_WCDMA_cell_id_list}=  Get Ids For All  class_name=WNCEL  connection=${alias}
    ${BTS_WCDMA_cell_count}=  Get Length  ${BTS_WCDMA_cell_id_list}
    ${BTS_GSM_cell_id_list}=  Get Ids For All  class_name=GNCEL  connection=${alias}
    ${BTS_GSM_cell_count}=  Get Length  ${BTS_GSM_cell_id_list}

    Run Keyword If  ${BTS_NR_cell_count} > 0
    ...  Append To List  ${configured_RAT_list}  NR
    Run Keyword If  ${BTS_LTE_cell_count} > 0
    ...  Append To List  ${configured_RAT_list}  LTE
    Run Keyword If  ${BTS_WCDMA_cell_count} > 0
    ...  Append To List  ${configured_RAT_list}  WCDMA
    Run Keyword If  ${BTS_GSM_cell_count} > 0
    ...  Append To List  ${configured_RAT_list}  GSM

    [Return]  ${configured_RAT_list}

Check item list
    [Arguments]  ${arg_name}  ${item_list}
    ${arg_item_list_strip}=  Replace String  ${${arg_name}}  ${SPACE}  ${EMPTY}
    ${arg_item_list_split}=  Split String  ${arg_item_list_strip}  ,
    ${item_check}=  Set Variable  True
    ${item_valid_list}=  Create List
    ${item_invalid_list}=  Create List

    FOR  ${item}  IN  @{arg_item_list_split}

        ${item_check}=  Set Variable If  '${item}' not in ${item_list}  False  ${item_check}
        Run Keyword If  '${item}' in ${item_list}
        ...  Append To List  ${item_valid_list}  ${item}
        ...  ELSE
        ...  Append To List  ${item_invalid_list}  ${item}

    END

    Run Keyword If  '${item_check}' == 'False'  Run Keywords
    ...  Log Long String  Following selected item values are not valid: ${item_invalid_list}. Please select values for test argument \${${arg_name}}
    ...  from configured items: ${item_list}  console=True
    ...  AND  Fail  Improper value for argument!

    [Return]  ${item_valid_list}

Get all BTS configuration info

    Log  \n***** Get all BTS configuration info *****
    Export tc run info to tc file  tc_run_info=\n***** Get all BTS configuration info *****

    FOR  ${alias}  IN  @{alias_list}

        ${BTS_label}=  Get From Dictionary  ${BTS_alias_label_dict}  ${alias}

        Log  \nGet ${BTS_label} info:
        Export tc run info to tc file  tc_run_info=\nGet ${BTS_label} info:
        Export tc run info to tc file  tc_run_info=\nActive SW info:\n - ${${alias}_active_SW_version_initial}

        ${SMOD_id_sn_dict}  ${SMOD_sn_id_dict}=  Get BTS HW sn id info  HW_class_name=SMOD  alias=${alias}
        Set Test Variable  ${${alias}_SMOD_id_sn_dict}  ${SMOD_id_sn_dict}
        Set Test Variable  ${${alias}_SMOD_sn_id_dict}  ${SMOD_sn_id_dict}
        ${BBMOD_id_sn_dict}  ${BBMOD_sn_id_dict}=  Get BTS HW sn id info  HW_class_name=BBMOD  alias=${alias}
        Set Test Variable  ${${alias}_BBMOD_id_sn_dict}  ${BBMOD_id_sn_dict}
        Set Test Variable  ${${alias}_BBMOD_sn_id_dict}  ${BBMOD_sn_id_dict}
        ${FHS_id_sn_dict}  ${FHS_sn_id_dict}=  Get BTS HW sn id info  HW_class_name=FHS  alias=${alias}
        Set Test Variable  ${${alias}_FHS_id_sn_dict}  ${FHS_id_sn_dict}
        Set Test Variable  ${${alias}_FHS_sn_id_dict}  ${FHS_sn_id_dict}
        ${RMOD_id_sn_dict}  ${RMOD_sn_id_dict}=  Get BTS HW sn id info  HW_class_name=RMOD  alias=${alias}
        Set Test Variable  ${${alias}_RMOD_id_sn_dict}  ${RMOD_id_sn_dict}
        Set Test Variable  ${${alias}_RMOD_sn_id_dict}  ${RMOD_sn_id_dict}

        Log  \nGet ${BTS_label} HW cablink connections info:
        Export tc run info to tc file  tc_run_info=\nGet ${BTS_label} HW cablink connections info:
        Get BTS HW CABLINK info dict  ${alias}

        ${BTS_CELL_identifier_id_dict}  ${BTS_CELL_identifier_dn_dict}  ${BTS_CELL_id_dn_dict}=  Get all configured CELL info  ${alias}

        Log  \nGet ${BTS_label} HW cells mapping info:
        Export tc run info to tc file  tc_run_info=\nGet ${BTS_label} HW cells mapping info:
        ${BBMOD_id_CELL_id_dict}  ${BBMOD_id_CELL_id_dict_scf_dict}=  Get BBMOD CELL mapping based on BBPOOL info from SCF  ${alias}
        Get BTS HW CELL mapping info  BBMOD  ${BBMOD_id_sn_dict}  ${BBMOD_id_CELL_id_dict}  ${BTS_CELL_id_dn_dict}

        ${RMOD_id_CELL_id_dict}=  Get RMOD CELL mapping based on Carrier info  ${alias}
        Get BTS HW CELL mapping info  RMOD  ${RMOD_id_sn_dict}  ${RMOD_id_CELL_id_dict}  ${BTS_CELL_id_dn_dict}

    END

Get BTS HW CABLINK info dict
    [Arguments]  ${alias}

    ${BTS_CABLINK_info}=  Get Parameters For All  CABLINK  connection=${alias}

    Get HW CABLINK connections  SMOD  ${BTS_CABLINK_info}  ${alias}
    Get HW CABLINK connections  BBMOD  ${BTS_CABLINK_info}  ${alias}
    Get HW CABLINK connections  FHS  ${BTS_CABLINK_info}  ${alias}
    Get HW CABLINK connections  RMOD  ${BTS_CABLINK_info}  ${alias}

Get HW CABLINK connections
    [Arguments]  ${HW_type}  ${BTS_CABLINK_info}  ${alias}

    ${BTS_HW_id_list}=  Get Dictionary Keys  ${${alias}_${HW_type}_id_sn_dict}
    FOR  ${item}  IN  @{BTS_HW_id_list}

        ${HW_sn}=  Get From Dictionary  ${${alias}_${HW_type}_id_sn_dict}  ${item}

        ${secondEndpoint_HW_sn_list}=  Get HW sn list connected by CABLINK  firstEndpointDN  ${item}  ${BTS_CABLINK_info}  ${alias}
        ${firstEndpoint_HW_sn_list}=  Get HW sn list connected by CABLINK  secondEndpointDN  ${item}  ${BTS_CABLINK_info}  ${alias}

        ${HW_info1}=  Create Long String  ${HW_type}_${HW_sn} cablink connections:
        Log  ${HW_info1}
        Export tc run info to tc file  tc_run_info=${HW_info1}
        ${HW_info2}=  Create Long String  - as firstEndpointDN to: ${secondEndpoint_HW_sn_list}
        Log  ${HW_info2}
        Export tc run info to tc file  tc_run_info=${HW_info2}
        ${HW_info3}=  Create Long String  - as secondEndpointDN from: ${firstEndpoint_HW_sn_list}
        Log  ${HW_info3}
        Export tc run info to tc file  tc_run_info=${HW_info3}

    END

Get HW sn list connected by CABLINK
    [Arguments]  ${HW_EndpointDN}  ${HW_id}  ${cablink_info}  ${alias}

    ${connected_HW_sn_list}=  Create List
    ${connected_HW_EndpointDN}=  Set Variable If  '${HW_EndpointDN}' == 'firstEndpointDN'  secondEndpointDN
    ...  '${HW_EndpointDN}' == 'secondEndpointDN'  firstEndpointDN

    FOR  ${item}  IN  @{cablink_info}

        Continue For Loop If  '${item['${HW_EndpointDN}']}' != '${HW_id}'

        ${connected_SMOD_R}=  Run Keyword And Return Status  Should Contain  ${item['${connected_HW_EndpointDN}']}  SMOD_R
        ${connected_SMOD_EXT_R}=  Run Keyword And Return Status  Should Contain  ${item['${connected_HW_EndpointDN}']}  SMOD_EXT_R
        ${connected_BBMOD_R}=  Run Keyword And Return Status  Should Contain  ${item['${connected_HW_EndpointDN}']}  BBMOD_R
        ${connected_FHS_R}=  Run Keyword And Return Status  Should Contain  ${item['${connected_HW_EndpointDN}']}  FHS_R
        ${connected_RMOD_R}=  Run Keyword And Return Status  Should Contain  ${item['${connected_HW_EndpointDN}']}  RMOD_R

        ${connected_HW_type}=  Set Variable If  ${connected_SMOD_R}  SMOD  ${connected_SMOD_EXT_R}  SMOD_EXT_R  ${connected_BBMOD_R}  BBMOD
        ...  ${connected_FHS_R}  FHS  ${connected_RMOD_R}  RMOD
        ${HW_sn}=  Run Keyword If  '${connected_HW_type}' != 'SMOD_EXT_R'
        ...  Get From Dictionary  ${${alias}_${connected_HW_type}_id_sn_dict}  ${item['${connected_HW_EndpointDN}']}

        Run Keyword If  '${connected_HW_type}' != 'SMOD_EXT_R'
        ...  Append To List  ${connected_HW_sn_list}  ${connected_HW_type}_${HW_sn}
        ...  ELSE
        ...  Append To List  ${connected_HW_sn_list}  SMOD_EXT_R

    END

    [Return]  ${connected_HW_sn_list}

Get BTS HW CELL mapping info
    [Arguments]  ${HW_type}  ${HW_id_sn_dict}  ${HW_id_CELL_id_dict}  ${CELL_id_dn_dict}

    FOR  ${HW_id}  ${CELL_id_list}  IN  &{HW_id_CELL_id_dict}

        ${HW_sn}=  Get From Dictionary  ${HW_id_sn_dict}  ${HW_id}
        ${CELL_label_list}=  Get CELL label info  ${CELL_id_list}  ${CELL_id_dn_dict}
        ${HW_CELL_info}=  Create Long String  ${HW_type}_${HW_sn} cells:\n -${CELL_label_list}
        Log  ${HW_CELL_info}
        Export tc run info to tc file  tc_run_info=${HW_CELL_info}

    END
Get CELL label info
    [Arguments]  ${CELL_id_list}  ${CELL_id_dn_dict}

    ${CELL_label_list}=  Create List

    FOR  ${CELL_id}  IN  @{CELL_id_list}

        ${CELL_dn}=  Get From Dictionary  ${CELL_id_dn_dict}  ${CELL_id}
        ${CELL_label}=  Fetch From Right  ${CELL_dn}  /
        Append To List  ${CELL_label_list}  ${CELL_label}

    END

    [Return]  ${CELL_label_list}

Get BTS resources states
    [Arguments]  ${alias}

    ${BTS_info_dict}=  Create Dictionary
    ${BTS_HW_info_dict}=  Create Dictionary
    ${BTS_CELL_info_dict}=  Create Dictionary
    Set Test Variable  ${BTS_info_dict}
    Set Test Variable  ${BTS_HW_info_dict}
    Set Test Variable  ${BTS_CELL_info_dict}
    ${BTS_label}=  Get From Dictionary  ${BTS_alias_label_dict}  ${alias}

    Log  \nGet ${BTS_label} info:  console=True
    Export tc run info to tc file  tc_run_info=\nGet ${BTS_label} info:

    Get BTS status info  ${alias}

    ${BTS_info}=  Get Bts Info  connection=${alias}
    Log  \nGet HW resources info:  console=True
    Export tc run info to tc file  tc_run_info=\nGet ${BTS_label} HW resources info:

    Get HW status info  ${BTS_info}  SMOD
    Get HW status info  ${BTS_info}  BBMOD
    Get HW status info  ${BTS_info}  FHS
    Get HW status info  ${BTS_info}  RMOD
    Get HW status info  ${BTS_info}  ALD

    Log  \nGet CELL resources info:  console=True
    Export tc run info to tc file  tc_run_info=\nGet ${BTS_label} CELL resources info:

    Get CELL status info  ${BTS_info}  nr
    Get CELL status info  ${BTS_info}  lte
    Get CELL status info  ${BTS_info}  wcdma
    Get CELL status info  ${BTS_info}  gsm

    [Return]  ${BTS_info_dict}  ${BTS_HW_info_dict}  ${BTS_CELL_info_dict}

Get BTS status info
    [Arguments]  ${alias}

    ${BTS_status_dict}=  Create Dictionary
    ${BTS_id}=  Get Id For Current  BTS  connection=${alias}
    ${status}=  Assert  class_name=BTS  id=${BTS_id}  connection=${alias}
    Set To Dictionary  ${BTS_status_dict}  proceduralState  ${status['proceduralState']}
    Set To Dictionary  ${BTS_status_dict}  blockingState  ${status['blockingState']}
    Set To Dictionary  ${BTS_info_dict}  BTS  ${BTS_status_dict}
    ${site_info}=  Set Variable  BTS status:\n - Procedural state: ${status['proceduralState']}, Blocking state: ${status['blockingState']}
    Log  ${site_info}  console=True
    Export tc run info to tc file  tc_run_info=${site_info}

    ${BTS_rat_list}=  Create List  NRBTS  LNBTS  WNBTS  GNBTS
    FOR  ${item}  IN  @{BTS_rat_list}

        ${bts_rat_id}=  Get Id For Current  ${item}  connection=${alias}
        Continue For Loop If  '${bts_rat_id}' == 'None'

        ${BTS_status_dict}=  Create Dictionary
        ${status}=  coam.Get Parameters  dist_name=${bts_rat_id}  connection=${alias}
        Set To Dictionary  ${BTS_status_dict}  operationalState  ${status['operationalState']}
        Run Keyword If  '${item}' != 'GNBTS'
        ...  Set To Dictionary  ${BTS_status_dict}  blockingState  ${status['blockingState']}
        Set To Dictionary  ${BTS_info_dict}  ${item}  ${BTS_status_dict}

        ${item_info}=  Run Keyword If  '${item}' == 'GNBTS'
        ...  Create Long String  ${item} status:\n - Operational state: ${status['operationalState']}
        ...  ELSE
        ...  Create Long String  ${item} status:\n - Operational state: ${status['operationalState']}, Blocking state: ${status['blockingState']}
        Log  ${item_info}  console=True
        Export tc run info to tc file  tc_run_info=${item_info}

    END

Get HW status info
    [Arguments]  ${BTS_info}  ${HW_type}

    ${BTS_HW_info}=  Set Variable If
    ...  '${HW_type}' == 'SMOD'  ${BTS_info['systemModules']}
    ...  '${HW_type}' == 'BBMOD'  ${BTS_info['basebandModules']}
    ...  '${HW_type}' == 'FHS'  ${BTS_info['fhs']}
    ...  '${HW_type}' == 'RMOD'  ${BTS_info['radioModules']['rmod']}
    ...  '${HW_type}' == 'ALD'  ${BTS_info['alds']}

    FOR  ${item}  IN  @{BTS_HW_info}

        ${HW_status_dict}=  Create Dictionary

        ${HW_sn}=  Get From Dictionary  ${item}  serialNumber
        ${HW_pn}=  Get From Dictionary  ${item}  productName

        Set To Dictionary  ${HW_status_dict}  operationalState  ${item['status']['operationalState']}
        ${availabilityStatus_check}=  Run Keyword and Return Status  Variable Should Exist  ${item['status']['availabilityStatus']}
        ${availabilityStatus}=  Set Variable If  ${availabilityStatus_check}  ${item['status']['availabilityStatus']}  -
        Set To Dictionary  ${HW_status_dict}  availabilityStatus  ${availabilityStatus}
        Set To Dictionary  ${HW_status_dict}  administrativeState  ${item['status']['administrativeState']}
        Set To Dictionary  ${BTS_HW_info_dict}  ${HW_type}_${HW_sn}  ${HW_status_dict}

        ${HW_info}=  Create Long String  ${HW_type}_${HW_sn} (${HW_pn}) status:\n - Operational state: ${item['status']['operationalState']},
        ...  Availability status: ${availabilityStatus}, Administrative state: ${item['status']['administrativeState']}
        Log  ${HW_info}  console=True
        Export tc run info to tc file  tc_run_info=${HW_info}

    END

Get CELL status info
    [Arguments]  ${BTS_info}  ${CELL_type}

    FOR  ${item}  IN  @{BTS_info['cells']['${CELL_type}']}

        ${CELL_status_dict}=  Create Dictionary

        ${CELL_label}=  Fetch From Right  ${item['id']['configuration']}  /

        Set To Dictionary  ${CELL_status_dict}  operationalState  ${item['status']['operationalState']}
        ${availabilityStatus_check}=  Run Keyword and Return Status  Variable Should Exist  ${item['status']['availabilityStatus']}
        ${availabilityStatus}=  Set Variable If  ${availabilityStatus_check}  ${item['status']['availabilityStatus']}  -
        Set To Dictionary  ${CELL_status_dict}  availabilityStatus  ${availabilityStatus}
        Set To Dictionary  ${CELL_status_dict}  blockingState  ${item['status']['blockingState']}
        Run Keyword If  '${CELL_type}' != 'wcdma'
        ...  Set To Dictionary  ${CELL_status_dict}  administrativeState  ${item['status']['administrativeState']}
        Set To Dictionary  ${BTS_CELL_info_dict}  ${CELL_label}  ${CELL_status_dict}

        ${CELL_info}=  Run Keyword If  '${CELL_type}' == 'wcdma'
        ...  Create Long String  ${CELL_label} status:\n - Operational state: ${item['status']['operationalState']}, Availability status:
        ...  ${availabilityStatus}, Blocking state: ${item['status']['blockingState']}
        ...  ELSE
        ...  Create Long String  ${CELL_label} status:\n - Operational state: ${item['status']['operationalState']}, Availability status:
        ...  ${availabilityStatus}, Blocking state: ${item['status']['blockingState']}, Administrative state: ${item['status']['administrativeState']}
        Log  ${CELL_info}  console=True
        Export tc run info to tc file  tc_run_info=${CELL_info}

    END

Get BTS active alarms
    [Arguments]  ${alias}

    ${BTS_label}=  Get From Dictionary  ${BTS_alias_label_dict}  ${alias}
    Log  \nGet ${BTS_label} active alarms info:  console=True
    Export tc run info to tc file  tc_run_info=\nGet ${BTS_label} active alarms info:

    ${BTS_active_alarms_info}=  coam.Get Alarms  connection=${alias}

    FOR  ${index}  ${item}  IN ENUMERATE  @{BTS_active_alarms_info}

        ${runtime_alarming_object_list}=  Get alarming object info  ${item['alarmingObjectIds']}  runtime
        ${configuration_alarming_object_list}=  Get alarming object info  ${item['alarmingObjectIds']}  configuration

        ${alarm_info}=  Create Long String  Alarm ${index+1} info:\n - Severity: ${item['severity']}, Appeared: ${item['observationTime']},
        ...  Alarm ID: ${item['alarmId']}, Alarm name: ${item['alarmName']}, Fault ID: ${item['faultId']},
        ...  Fault name: ${item['alarmInformation']['faultDescription']}, Runtime alarming object: ${runtime_alarming_object_list[0]},
        ...  Configuration alarming object: ${configuration_alarming_object_list[0]}
        Log  ${alarm_info}  console=True
        Export tc run info to tc file  tc_run_info=${alarm_info}

    END

    [Return]  ${BTS_active_alarms_info}

Get BTS historic alarms
    [Arguments]  ${alias}
    ${BTS_label}=  Get From Dictionary  ${BTS_alias_label_dict}  ${alias}

    Log  \nGet ${BTS_label} historic alarms info:  console=True
    Export tc run info to tc file  tc_run_info=\nGet ${BTS_label} historic alarms info:

    ${BTS_historic_alarms_info}=  coam.Get Historic Alarms  connection=${alias}  timeout=300  load_history=${LOAD_HISTORY}

    FOR  ${index}  ${item}  IN ENUMERATE  @{BTS_historic_alarms_info}

        ${runtime_alarming_object_list}=  Get alarming object info  ${item['alarmingObjectIds']}  runtime
        ${configuration_alarming_object_list}=  Get alarming object info  ${item['alarmingObjectIds']}  configuration

        ${alarm_info}=  Create Long String  Alarm ${index+1} info:\n - Severity: ${item['severity']}, Appeared: ${item['btsObservationTime']},
        ...  Cleared: ${item['clearedTime']}, Alarm ID: ${item['alarmId']}, Alarm name: ${item['alarmName']}, Fault ID: ${item['faultId']},
        ...  Fault name: ${item['faultName']}, Runtime alarming object: ${runtime_alarming_object_list[0]},
        ...  Configuration alarming object: ${configuration_alarming_object_list[0]}
        Log  ${alarm_info}  console=True
        Export tc run info to tc file  tc_run_info=${alarm_info}

    END

    [Return]  ${BTS_historic_alarms_info}

Get alarming object info
    [Arguments]  ${alarmingObjectIds}  ${type}

    ${alarming_object_list}=  Create List

    FOR  ${item}  IN  @{alarmingObjectIds}
        ${alarm_info_check}=  Run Keyword and Return Status  Variable Should Exist  ${item['${type}']}
        ${alarm_info}=  Set Variable If  ${alarm_info_check}  ${item['${type}']}  -
        Append To List  ${alarming_object_list}  ${alarm_info}
    END

    [Return]  ${alarming_object_list}

Perform power operation on RMOD

    FOR  ${item}  IN  @{BTS_HW_sn_list}

        Run Keyword If  '${OAM_OPERATION.title()}' == 'Power Off'
        ...  Perform Power RMOD  HW_sn=${item}  power=off  wait_stable_time=${BTS_STABLE_TIME}
        ...  ELSE IF  '${OAM_OPERATION.title()}' == 'Power On'
        ...  Perform Power RMOD  HW_sn=${item}  power=on  wait_stable_time=${BTS_STABLE_TIME}

    END

Perform OAM operation on BTS
    [Arguments]  ${alias}

    Run Keyword If  '${OAM_OPERATION.title()}' == 'Reset'
    ...  Perform Reset BTS  graceful_cell_shutdown=${GRACEFUL_CELL_SHUTDOWN}  reset_without_ru=${RESET_WITHOUT_RU}
    ...  wait_stable_time=${BTS_STABLE_TIME}  timeout=${OAM_OPERATION_TIMEOUT}  alias=${alias}
    ...  ELSE IF  '${OAM_OPERATION.title()}' == 'Block'
    ...  Perform Block BTS  wait_stable_time=${BTS_STABLE_TIME}  timeout=${OAM_OPERATION_TIMEOUT}  alias=${alias}
    ...  ELSE IF  '${OAM_OPERATION.title()}' == 'Unblock'
    ...  Perform Unblock BTS  wait_stable_time=${BTS_STABLE_TIME}  timeout=${OAM_OPERATION_TIMEOUT}  alias=${alias}

Perform OAM operation on HW
    [Arguments]  ${alias}

    FOR  ${item}  IN  @{BTS_HW_sn_list}

        Run Keyword If  '${OAM_OPERATION.title()}' == 'Reset'
        ...  Perform Reset HW  HW_type=${RESOURCE}  HW_sn=${item}  graceful_cell_shutdown=${GRACEFUL_CELL_SHUTDOWN}
        ...  wait_stable_time=${BTS_STABLE_TIME}  timeout=${OAM_OPERATION_TIMEOUT}  alias=${alias}
        ...  ELSE IF  '${OAM_OPERATION.title()}' == 'Lock'
        ...  Perform Lock HW  HW_type=${RESOURCE}  HW_sn=${item}  wait_stable_time=${BTS_STABLE_TIME}  timeout=${OAM_OPERATION_TIMEOUT}
        ...  alias=${alias}
        ...  ELSE IF  '${OAM_OPERATION.title()}' == 'Unlock'
        ...  Perform Unlock HW  HW_type=${RESOURCE}  HW_sn=${item}  wait_stable_time=${BTS_STABLE_TIME}  timeout=${OAM_OPERATION_TIMEOUT}
        ...  alias=${alias}

    END

Perform OAM operation on CELL
    [Arguments]  ${alias}

    FOR  ${item}  IN  @{BTS_CELL_identifier_list}

        Run Keyword If  '${OAM_OPERATION.title()}' == 'Block'
        ...  Perform Block CELL  CELL_identifier=${item}  wait_stable_time=${BTS_STABLE_TIME}  timeout=${OAM_OPERATION_TIMEOUT}  alias=${alias}
        ...  ELSE IF  '${OAM_OPERATION.title()}' == 'Unblock'
        ...  Perform Unblock CELL  CELL_identifier=${item}  wait_stable_time=${BTS_STABLE_TIME}  timeout=${OAM_OPERATION_TIMEOUT}  alias=${alias}
        ...  ELSE IF  '${OAM_OPERATION.title()}' == 'Lock'
        ...  Perform Lock CELL  CELL_identifier=${item}  wait_stable_time=${BTS_STABLE_TIME}  timeout=${OAM_OPERATION_TIMEOUT}  alias=${alias}
        ...  ELSE IF  '${OAM_OPERATION.title()}' == 'Unlock'
        ...  Perform Unlock CELL  CELL_identifier=${item}  wait_stable_time=${BTS_STABLE_TIME}  timeout=${OAM_OPERATION_TIMEOUT}  alias=${alias}

    END

Perform OAM operation on RAT
    [Arguments]  ${alias}

    FOR  ${rat_type}  IN  @{BTS_RAT_list}

        Run Keyword If  '${OAM_OPERATION.title()}' == 'Reset'
        ...  Perform Reset RAT  rat_type=${rat_type}  reset_type=${RAT_RESET_TYPE}  graceful_cell_shutdown=${GRACEFUL_CELL_SHUTDOWN}
        ...  wait_stable_time=${BTS_STABLE_TIME}  timeout=${OAM_OPERATION_TIMEOUT}  alias=${alias}
        ...  ELSE IF  '${OAM_OPERATION.title()}' == 'Block'
        ...  Perform Block RAT  rat_type=${rat_type}  wait_stable_time=${BTS_STABLE_TIME}  timeout=${OAM_OPERATION_TIMEOUT}  alias=${alias}
        ...  ELSE IF  '${OAM_OPERATION.title()}' == 'Unblock'
        ...  Perform Unblock RAT  rat_type=${rat_type}  wait_stable_time=${BTS_STABLE_TIME}  timeout=${OAM_OPERATION_TIMEOUT}  alias=${alias}

    END

Perform Power RMOD
    [Arguments]  ${HW_sn}  ${power}  ${wait_stable_time}

    ${operation_info}=  Set Variable  Perform "Power ${power.title()}" operation on RMOD_${HW_sn}
    Log  ${operation_info}  console=True
    Export tc run info to tc file  tc_run_info=\n${operation_info}

    Run Keyword If  '${power}' == 'on'
    ...  Pdu BTS Interface On  RMOD_${HW_sn}
    ...  ELSE IF  '${power}' == 'off'
    ...  Pdu BTS Interface Off  RMOD_${HW_sn}
    ${operation_info}=  Set Variable  Operation "Power ${power.title()}" completed on RMOD_${HW_sn}
    Log  ${operation_info}  console=True
    Export tc run info to tc file  tc_run_info=${operation_info}

    Sleep  5s  Waiting for PDU RMOD stable status
    ${PDU_port_status}=  Pdu BTS Interface Get Status  RMOD_${HW_sn}
    Run Keyword if  '${PDU_port_status}' == '${power}'
    ...  Log Long String  RMOD_${HW_sn} PDU info: IP=${INTERFACES['RMOD_${HW_sn}']['IP']}, PORT=${INTERFACES['RMOD_${HW_sn}']['OUTLET']} switched
    ...  ${PDU_port_status}  console=True
    ...  ELSE  Run Keywords
    ...  Log Long String  RMOD_${HW_sn} PDU info: IP=${INTERFACES['RMOD_${HW_sn}']['IP']}, PORT=${INTERFACES['RMOD_${HW_sn}']['OUTLET']} switched
    ...  ${PDU_port_status}!  level=ERROR
    ...  AND  Fail  RMOD_${HW_sn} power ${power} failed!

    Log  Waiting ${wait_stable_time}s for RMOD stable status  console=True
    Export tc run info to tc file  tc_run_info=\nWaiting ${wait_stable_time}s for RMOD stable status
    Sleep  ${wait_stable_time}s  Waiting for RMOD stable status

Perform Reset BTS
    [Arguments]  ${graceful_cell_shutdown}  ${reset_without_ru}  ${wait_stable_time}  ${timeout}  ${alias}

    ${BTS_id}=  Get Id For Current  BTS  connection=${alias}
    ${BTS_label}=  Get From Dictionary  ${BTS_alias_label_dict}  ${alias}
    ${graceful_cell_shutdown}=  Set Variable If  '${${alias.upper()}}[${alias.upper()}_MODULE_TYPE]' == 'FSMF'  ${None}  ${graceful_cell_shutdown}
    ${reset_without_ru}=  Set Variable If  '${${alias.upper()}}[${alias.upper()}_MODULE_TYPE]' == 'FSMF'  ${None}  ${reset_without_ru}

    ${operation_info}=  Set Variable  ${BTS_label} -> Perform "Reset Site" operation on ${BTS_label}
    Log  ${operation_info}  console=True
    Export tc run info to tc file  tc_run_info=\n${operation_info}
    coam.Reset Site  timeout=${timeout}  connection=${alias}  graceful_cell_shutdown=${graceful_cell_shutdown}  reset_without_ru=${reset_without_ru}
    ${operation_info}=  Set Variable  Operation "Reset Site" completed on ${BTS_label}
    Log  ${operation_info}  console=True
    Export tc run info to tc file  tc_run_info=${operation_info}

    Log  Waiting ${wait_stable_time}s for ${BTS_label} stable status  console=True
    Export tc run info to tc file  tc_run_info=\nWaiting ${wait_stable_time}s for ${BTS_label} stable status
    Sleep  ${wait_stable_time}s  Waiting for BTS stable status

    Log  ${BTS_label} -> Check ${BTS_label} status  console=True
    ${status}=  Assert  class_name=BTS  id=${BTS_id}  timeout=${timeout}  connection=${alias}
    ${site_info}=  Create Long String  BTS status:\n - Procedural state: ${status['proceduralState']}, Blocking state: ${status['blockingState']}
    Log  ${site_info}  console=True
    Export tc run info to tc file  tc_run_info=${site_info}

Perform Block BTS
    [Arguments]  ${wait_stable_time}  ${timeout}  ${alias}

    ${BTS_id}=  Get Id For Current  BTS  connection=${alias}
    ${BTS_label}=  Get From Dictionary  ${BTS_alias_label_dict}  ${alias}

    ${operation_info}=  Set Variable  ${BTS_label} -> Perform "Block Site" operation on ${BTS_label}
    Log  ${operation_info}  console=True
    Export tc run info to tc file  tc_run_info=\n${operation_info}
    coam.Block  timeout=${timeout}  connection=${alias}
    ${operation_info}=  Set Variable  Operation "Block Site" completed on ${BTS_label}
    Log  ${operation_info}  console=True
    Export tc run info to tc file  tc_run_info=${operation_info}

    Log  Waiting ${wait_stable_time}s for ${BTS_label} stable status  console=True
    Export tc run info to tc file  tc_run_info=\nWaiting ${wait_stable_time}s for ${BTS_label} stable status
    Sleep  ${wait_stable_time}s  Waiting for BTS stable status

    Log  ${BTS_label} -> Check ${BTS_label} status  console=True
    ${status}=  Assert  class_name=BTS  id=${BTS_id}  parameters=${Block_BTS_state_check}  timeout=${timeout}  connection=${alias}
    ${site_info}=  Create Long String  BTS status:\n - Procedural state: ${status['proceduralState']}, Blocking state: ${status['blockingState']}
    Log  ${site_info}  console=True
    Export tc run info to tc file  tc_run_info=${site_info}

Perform Unblock BTS
    [Arguments]  ${wait_stable_time}  ${timeout}  ${alias}

    ${BTS_id}=  Get Id For Current  BTS  connection=${alias}
    ${BTS_label}=  Get From Dictionary  ${BTS_alias_label_dict}  ${alias}

    ${operation_info}=  Set Variable  ${BTS_label} -> Perform "Unblock Site" operation on ${BTS_label}
    Log  ${operation_info}  console=True
    Export tc run info to tc file  tc_run_info=\n${operation_info}
    coam.Unblock  timeout=${timeout}  connection=${alias}
    ${operation_info}=  Set Variable  Operation "Unblock Site" completed on ${BTS_label}
    Log  ${operation_info}  console=True
    Export tc run info to tc file  tc_run_info=${operation_info}

    Log  Waiting ${wait_stable_time}s for ${BTS_label} stable status  console=True
    Export tc run info to tc file  tc_run_info=\nWaiting ${wait_stable_time}s for ${BTS_label} stable status
    Sleep  ${wait_stable_time}s  Waiting for BTS stable status

    Log  ${BTS_label} -> Check ${BTS_label} status  console=True
    ${status}=  Assert  class_name=BTS  id=${BTS_id}  parameters=${Unblock_BTS_state_check}  timeout=${timeout}  connection=${alias}
    ${site_info}=  Create Long String  BTS status:\n - Procedural state: ${status['proceduralState']}, Blocking state: ${status['blockingState']}
    Log  ${site_info}  console=True
    Export tc run info to tc file  tc_run_info=${site_info}

Perform Reset HW
    [Arguments]  ${HW_type}  ${HW_sn}  ${graceful_cell_shutdown}  ${wait_stable_time}  ${timeout}  ${alias}

    ${HW_id}=  Get From Dictionary  ${HW_sn_id_dict}  ${HW_sn}
    ${BTS_label}=  Get From Dictionary  ${BTS_alias_label_dict}  ${alias}
    ${reset_type}=  Set Variable If  '${HW_type}' == 'BBMOD'  Warm  '${HW_type}' == 'FHS'  Hard  '${HW_type}' == 'RMOD'  Hard
    ${graceful_cell_shutdown}=  Set Variable If
    ...  '${${alias.upper()}}[${alias.upper()}_MODULE_TYPE]' == 'FSMF'  ${None}  ${graceful_cell_shutdown}

    ${operation_info}=  Set Variable  ${BTS_label} -> Perform "Reset" operation on ${HW_type}_${HW_sn}
    Log  ${operation_info}  console=True
    Export tc run info to tc file  tc_run_info=\n${operation_info}
    coam.Reset Unit  dist_name=${HW_id}  reset_type=${reset_type}  timeout=${timeout}  connection=${alias}
    ...  graceful_cell_shutdown=${graceful_cell_shutdown}
    ${operation_info}=  Set Variable  Operation "Reset" completed on ${BTS_label}
    Log  ${operation_info}  console=True
    Export tc run info to tc file  tc_run_info=${operation_info}

    Log  Waiting ${wait_stable_time}s for ${BTS_label} stable status  console=True
    Export tc run info to tc file  tc_run_info=\nWaiting ${wait_stable_time}s for ${BTS_label} stable status
    Sleep  ${wait_stable_time}s  Waiting for BTS stable status

    Log  ${BTS_label} -> Check ${HW_type}_${HW_sn} status  console=True
    ${status}=  Assert  class_name=${HW_type}  id=${HW_id}  timeout=${timeout}  connection=${alias}
    ${availabilityStatus_check}=  Run Keyword and Return Status  Variable Should Exist  ${status['availabilityStatus']}
    ${availabilityStatus}=  Set Variable If  ${availabilityStatus_check}  ${status['availabilityStatus']}  -
    ${HW_info}=  Create Long String  ${HW_type}_${HW_sn} status:\n - Operational state: ${status['operationalState']},
    ...  Availability status: ${availabilityStatus}, Administrative state: ${status['administrativeState']}
    Log  ${HW_info}  console=True
    Export tc run info to tc file  tc_run_info=${HW_info}

Perform Lock HW
    [Arguments]  ${HW_type}  ${HW_sn}  ${wait_stable_time}  ${timeout}  ${alias}

    ${HW_id}=  Get From Dictionary  ${HW_sn_id_dict}  ${HW_sn}
    ${BTS_label}=  Get From Dictionary  ${BTS_alias_label_dict}  ${alias}

    ${operation_info}=  Set Variable  ${BTS_label} -> Perform "Lock" operation on ${HW_type}_${HW_sn}
    Log  ${operation_info}  console=True
    Export tc run info to tc file  tc_run_info=\n${operation_info}
    coam.Lock  dist_name=${HW_id}  timeout=${timeout}  connection=${alias}
    ${operation_info}=  Set Variable  Operation "Lock" completed on ${BTS_label}
    Log  ${operation_info}  console=True
    Export tc run info to tc file  tc_run_info=${operation_info}

    Log  Waiting ${wait_stable_time}s for ${BTS_label} stable status  console=True
    Export tc run info to tc file  tc_run_info=\nWaiting ${wait_stable_time}s for ${BTS_label} stable status
    Sleep  ${wait_stable_time}s  Waiting for BTS stable status

    Log  ${BTS_label} -> Check ${HW_type}_${HW_sn} status  console=True
    ${status}=  Assert  class_name=${HW_type}  id=${HW_id}  parameters=${Lock_HW_state_check}  timeout=${timeout}  connection=${alias}
    ${availabilityStatus_check}=  Run Keyword and Return Status  Variable Should Exist  ${status['availabilityStatus']}
    ${availabilityStatus}=  Set Variable If  ${availabilityStatus_check}  ${status['availabilityStatus']}  -
    ${HW_info}=  Create Long String  ${HW_type}_${HW_sn} status:\n - Operational state: ${status['operationalState']},
    ...  Availability status: ${availabilityStatus}, Administrative state: ${status['administrativeState']}
    Log  ${HW_info}  console=True
    Export tc run info to tc file  tc_run_info=${HW_info}

Perform Unlock HW
    [Arguments]  ${HW_type}  ${HW_sn}  ${wait_stable_time}  ${timeout}  ${alias}

    ${HW_id}=  Get From Dictionary  ${HW_sn_id_dict}  ${HW_sn}
    ${BTS_label}=  Get From Dictionary  ${BTS_alias_label_dict}  ${alias}

    ${operation_info}=  Set Variable  ${BTS_label} -> Perform "Unlock" operation on ${HW_type}_${HW_sn}
    Log  ${operation_info}  console=True
    Export tc run info to tc file  tc_run_info=\n${operation_info}
    coam.Unlock  dist_name=${HW_id}  timeout=${timeout}  connection=${alias}
    ${operation_info}=  Set Variable  Operation "Unlock" completed on ${BTS_label}
    Log  ${operation_info}  console=True
    Export tc run info to tc file  tc_run_info=${operation_info}

    Log  Waiting ${wait_stable_time}s for ${BTS_label} stable status  console=True
    Export tc run info to tc file  tc_run_info=\nWaiting ${wait_stable_time}s for ${BTS_label} stable status
    Sleep  ${wait_stable_time}s  Waiting for BTS stable status

    Log  ${BTS_label} -> Check ${HW_type}_${HW_sn} status  console=True
    ${status}=  Assert  class_name=${HW_type}  id=${HW_id}  parameters=${Unlock_HW_state_check}  timeout=${timeout}  connection=${alias}
    ${availabilityStatus_check}=  Run Keyword and Return Status  Variable Should Exist  ${status['availabilityStatus']}
    ${availabilityStatus}=  Set Variable If  ${availabilityStatus_check}  ${status['availabilityStatus']}  -
    ${HW_info}=  Create Long String  ${HW_type}_${HW_sn} status:\n - Operational state: ${status['operationalState']},
    ...  Availability status: ${availabilityStatus}, Administrative state: ${status['administrativeState']}
    Log  ${HW_info}  console=True
    Export tc run info to tc file  tc_run_info=${HW_info}

Perform Block CELL
    [Arguments]  ${CELL_identifier}  ${wait_stable_time}  ${timeout}  ${alias}

    ${cell_id}=  Get From Dictionary  ${${alias}_${RESOURCE}_identifier_id_dict}  ${CELL_identifier}
    ${BTS_label}=  Get From Dictionary  ${BTS_alias_label_dict}  ${alias}
    ${CELL_identifier_info}=  Set variable If  '${RESOURCE}' == 'NRCEL'  globalCellId  '${RESOURCE}' == 'LNCEL'  globalCellId
    ...  '${RESOURCE}' == 'WNCEL'  cellId  '${RESOURCE}' == 'GNCEL'  gsmSectorID

    ${operation_info}=  Set Variable  ${BTS_label} -> Perform "Block Cell" operation on ${RESOURCE} with ${CELL_identifier_info} ${CELL_identifier}
    Log  ${operation_info}  console=True
    Export tc run info to tc file  tc_run_info=\n${operation_info}
    coam.Block Cell  dist_name=${cell_id}  timeout=${timeout}  connection=${alias}
    ${operation_info}=  Set Variable  Operation "Block Cell" completed on ${BTS_label}
    Log  ${operation_info}  console=True
    Export tc run info to tc file  tc_run_info=${operation_info}

    Log  Waiting ${wait_stable_time}s for ${BTS_label} stable status  console=True
    Export tc run info to tc file  tc_run_info=\nWaiting ${wait_stable_time}s for ${BTS_label} stable status
    Sleep  ${wait_stable_time}s  Waiting for BTS stable status

    Log  ${BTS_label} -> Check ${RESOURCE} with ${CELL_identifier_info} ${CELL_identifier} status  console=True
    ${status}=  Assert  class_name=${RESOURCE}  id=${cell_id}  parameters=${Block_CELL_state_check}  timeout=${timeout}
    ...  connection=${alias}
    ${CELL_info}=  Run Keyword If  '${RESOURCE}' == 'WNCEL'
    ...  Create Long String  ${RESOURCE} ${cell_id} status:\n - Operational state: ${status['operationalState']},
    ...  Availability status: ${status['availabilityStatus']}, Blocking state: ${status['blockingState']}
    ...  ELSE  Create Long String  ${RESOURCE} ${cell_id} status:\n - Operational state: ${status['operationalState']},
    ...  Availability status: ${status['availabilityStatus']}, Blocking state: ${status['blockingState']},
    ...  Administrative state: ${status['administrativeState']}
    Log  ${CELL_info}  console=True
    Export tc run info to tc file  tc_run_info=${CELL_info}

Perform Unblock CELL
    [Arguments]  ${CELL_identifier}  ${wait_stable_time}  ${timeout}  ${alias}

    ${cell_id}=  Get From Dictionary  ${${alias}_${RESOURCE}_identifier_id_dict}  ${CELL_identifier}
    ${BTS_label}=  Get From Dictionary  ${BTS_alias_label_dict}  ${alias}
    ${CELL_identifier_info}=  Set variable If  '${RESOURCE}' == 'NRCEL'  globalCellId  '${RESOURCE}' == 'LNCEL'  globalCellId
    ...  '${RESOURCE}' == 'WNCEL'  cellId  '${RESOURCE}' == 'GNCEL'  gsmSectorID

    ${operation_info}=  Set Variable  ${BTS_label} -> Perform "Unblock Cell" operation on ${RESOURCE} with ${CELL_identifier_info} ${CELL_identifier}
    Log  ${operation_info}  console=True
    Export tc run info to tc file  tc_run_info=\n${operation_info}
    coam.Unblock Cell  dist_name=${cell_id}  timeout=${timeout}  connection=${alias}
    ${operation_info}=  Set Variable  Operation "Unblock Cell" completed on ${BTS_label}
    Log  ${operation_info}  console=True
    Export tc run info to tc file  tc_run_info=${operation_info}

    Log  Waiting ${wait_stable_time}s for BTS ${BTS_label} status  console=True
    Export tc run info to tc file  tc_run_info=\nWaiting ${wait_stable_time}s for ${BTS_label} stable status
    Sleep  ${wait_stable_time}s  Waiting for BTS stable status

    Log  ${BTS_label} -> Check ${RESOURCE} with ${CELL_identifier_info} ${CELL_identifier} status  console=True
    ${status}=  Assert  class_name=${RESOURCE}  id=${cell_id}  parameters=${Unblock_CELL_state_check}  timeout=${timeout}  connection=${alias}
    ${availabilityStatus_check}=  Run Keyword and Return Status  Variable Should Exist  ${status['availabilityStatus']}
    ${availabilityStatus}=  Set Variable If  ${availabilityStatus_check}  ${status['availabilityStatus']}  -
    ${CELL_info}=  Run Keyword If  '${RESOURCE}' == 'WNCEL'
    ...  Create Long String  ${RESOURCE} ${cell_id} status:\n - Operational state: ${status['operationalState']},
    ...  Availability status: ${availabilityStatus}, Blocking state: ${status['blockingState']}
    ...  ELSE  Create Long String  ${RESOURCE} ${cell_id} status:\n - Operational state: ${status['operationalState']},
    ...  Availability status: ${availabilityStatus}, Blocking state: ${status['blockingState']},
    ...  Administrative state: ${status['administrativeState']}
    Log  ${CELL_info}  console=True
    Export tc run info to tc file  tc_run_info=${CELL_info}

Perform Lock CELL
    [Arguments]  ${CELL_identifier}  ${wait_stable_time}  ${timeout}  ${alias}

    ${cell_id}=  Get From Dictionary  ${${alias}_${RESOURCE}_identifier_id_dict}  ${CELL_identifier}
    ${BTS_label}=  Get From Dictionary  ${BTS_alias_label_dict}  ${alias}
    ${CELL_identifier_info}=  Set variable If  '${RESOURCE}' == 'NRCEL'  globalCellId  '${RESOURCE}' == 'LNCEL'  globalCellId
    ...  '${RESOURCE}' == 'WNCEL'  cellId  '${RESOURCE}' == 'GNCEL'  gsmSectorID

    ${operation_info}=  Set Variable  ${BTS_label} -> Perform "Lock Cell" operation on ${RESOURCE} with ${CELL_identifier_info} ${CELL_identifier}
    Log  ${operation_info}  console=True
    Export tc run info to tc file  tc_run_info=\n${operation_info}
    coam.Lock  dist_name=${cell_id}  timeout=${timeout}  connection=${alias}
    ${operation_info}=  Set Variable  Operation "Lock Cell" completed on ${BTS_label}
    Log  ${operation_info}  console=True
    Export tc run info to tc file  tc_run_info=${operation_info}

    Log  Waiting ${wait_stable_time}s for ${BTS_label} stable status  console=True
    Export tc run info to tc file  tc_run_info=\nWaiting ${wait_stable_time}s for ${BTS_label} stable status
    Sleep  ${wait_stable_time}s  Waiting for BTS stable status

    Log  ${BTS_label} -> Check ${RESOURCE} with ${CELL_identifier_info} ${CELL_identifier} status  console=True
    ${status}=  Assert  class_name=${RESOURCE}  id=${cell_id}  parameters=${Lock_CELL_state_check}  timeout=${timeout}
    ...  connection=${alias}
    ${CELL_info}=  Create Long String  ${RESOURCE} ${cell_id} status:\n - Operational state: ${status['operationalState']},
    ...  Availability status: ${status['availabilityStatus']}, Blocking state: ${status['blockingState']},
    ...  Administrative state: ${status['administrativeState']}
    Log  ${CELL_info}  console=True
    Export tc run info to tc file  tc_run_info=${CELL_info}

Perform Unlock CELL
    [Arguments]  ${CELL_identifier}  ${wait_stable_time}  ${timeout}  ${alias}

    ${cell_id}=  Get From Dictionary  ${${alias}_${RESOURCE}_identifier_id_dict}  ${CELL_identifier}
    ${BTS_label}=  Get From Dictionary  ${BTS_alias_label_dict}  ${alias}
    ${CELL_identifier_info}=  Set variable If  '${RESOURCE}' == 'NRCEL'  globalCellId  '${RESOURCE}' == 'LNCEL'  globalCellId
    ...  '${RESOURCE}' == 'WNCEL'  cellId  '${RESOURCE}' == 'GNCEL'  gsmSectorID

    ${operation_info}=  Set Variable  ${BTS_label} -> Perform "Unlock Cell" operation on ${RESOURCE} with ${CELL_identifier_info} ${CELL_identifier}
    Log  ${operation_info}  console=True
    Export tc run info to tc file  tc_run_info=\n${operation_info}
    coam.Unlock  dist_name=${cell_id}  timeout=${timeout}  connection=${alias}
    ${operation_info}=  Set Variable  Operation "Unlock Cell" completed on ${BTS_label}
    Log  ${operation_info}  console=True
    Export tc run info to tc file  tc_run_info=${operation_info}

    Log  Waiting ${wait_stable_time}s for BTS ${BTS_label} status  console=True
    Export tc run info to tc file  tc_run_info=\nWaiting ${wait_stable_time}s for ${BTS_label} stable status
    Sleep  ${wait_stable_time}s  Waiting for BTS stable status

    Log  ${BTS_label} -> Check ${RESOURCE} with ${CELL_identifier_info} ${CELL_identifier} status  console=True
    ${status}=  Assert  class_name=${RESOURCE}  id=${cell_id}  parameters=${Unlock_CELL_state_check}  timeout=${timeout}  connection=${alias}
    ${availabilityStatus_check}=  Run Keyword and Return Status  Variable Should Exist  ${status['availabilityStatus']}
    ${availabilityStatus}=  Set Variable If  ${availabilityStatus_check}  ${status['availabilityStatus']}  -
    ${CELL_info}=  Create Long String  ${RESOURCE} ${cell_id} status:\n - Operational state: ${status['operationalState']},
    ...  Availability status: ${availabilityStatus}, Blocking state: ${status['blockingState']},
    ...  Administrative state: ${status['administrativeState']}
    Log  ${CELL_info}  console=True
    Export tc run info to tc file  tc_run_info=${CELL_info}

Perform Reset RAT
    [Arguments]  ${rat_type}  ${reset_type}  ${graceful_cell_shutdown}  ${wait_stable_time}  ${timeout}  ${alias}

    ${BTS_label}=  Get From Dictionary  ${BTS_alias_label_dict}  ${alias}
    ${bts_class_name}=  Set Variable If  '${rat_type}' == 'NR'  NRBTS  '${rat_type}' == 'LTE'  LNBTS  '${rat_type}' == 'WCDMA'  WNBTS
    ...  '${rat_type}' == 'GSM'  GNBTS
    ${bts_rat_id}=  Get Id For Current  ${bts_class_name}  connection=${alias}

    ${operation_info}=  Set Variable  ${BTS_label} -> Perform "Reset ${rat_type} RAT" operation on ${BTS_label}
    Log  ${operation_info}  console=True
    Export tc run info to tc file  tc_run_info=\n${operation_info}

    ${graceful_cell_shutdown}=  Set Variable If
    ...  '${${alias.upper()}}[${alias.upper()}_MODULE_TYPE]' == 'FSMF'  ${None}  ${graceful_cell_shutdown}
    coam.Rat Reset  rat_type=${rat_type}  timeout=${timeout}  connection=${alias}  graceful_cell_shutdown=${graceful_cell_shutdown}
    ...  reset_type=${reset_type}
    ${operation_info}=  Set Variable  Operation "Reset ${rat_type} RAT" completed on ${BTS_label}
    Log  ${operation_info}  console=True
    Export tc run info to tc file  tc_run_info=${operation_info}

    Log  Waiting ${wait_stable_time}s for ${BTS_label} stable status  console=True
    Export tc run info to tc file  tc_run_info=\nWaiting ${wait_stable_time}s for ${BTS_label} stable status
    Sleep  ${wait_stable_time}s  Waiting for BTS stable status

    Log  ${BTS_label} -> Check ${bts_class_name} status  console=True
    ${status}=  coam.Get Parameters  dist_name=${bts_rat_id}  connection=${alias}
    ${rat_info}=  Run Keyword If  '${bts_class_name}' == 'GNBTS'
    ...  Create Long String  ${bts_class_name} status:\n - Operational state: ${status['operationalState']}
    ...  ELSE
    ...  Create Long String  ${bts_class_name} status:\n - Operational state: ${status['operationalState']},
    ...  Blocking state: ${status['blockingState']}
    Log  ${rat_info}  console=True
    Export tc run info to tc file  tc_run_info=${rat_info}

Perform Block RAT
    [Arguments]  ${rat_type}  ${wait_stable_time}  ${timeout}  ${alias}

    ${BTS_label}=  Get From Dictionary  ${BTS_alias_label_dict}  ${alias}
    ${bts_class_name}=  Set Variable If  '${rat_type}' == 'NR'  NRBTS  '${rat_type}' == 'LTE'  LNBTS  '${rat_type}' == 'WCDMA'  WNBTS
    ...  '${rat_type}' == 'GSM'  GNBTS
    ${bts_rat_id}=  Get Id For Current  ${bts_class_name}  connection=${alias}

    ${operation_info}=  Set Variable  ${BTS_label} -> Perform "Block ${rat_type} RAT" operation on ${BTS_label}
    Log  ${operation_info}  console=True
    Export tc run info to tc file  tc_run_info=\n${operation_info}

    coam.Block Rat  rat=${rat_type}  timeout=${timeout}  connection=${alias}
    ${operation_info}=  Set Variable  Operation "Block ${rat_type} RAT" completed on ${BTS_label}
    Log  ${operation_info}  console=True
    Export tc run info to tc file  tc_run_info=${operation_info}

    Log  Waiting ${wait_stable_time}s for ${BTS_label} stable status  console=True
    Export tc run info to tc file  tc_run_info=\nWaiting ${wait_stable_time}s for ${BTS_label} stable status
    Sleep  ${wait_stable_time}s  Waiting for BTS stable status

    Log  ${BTS_label} -> Check ${bts_class_name} status  console=True
    ${status}=  coam.Get Parameters  dist_name=${bts_rat_id}  connection=${alias}
    ${rat_info}=  Run Keyword If  '${bts_class_name}' == 'GNBTS'
    ...  Create Long String  ${bts_class_name} status:\n - Operational state: ${status['operationalState']}
    ...  ELSE
    ...  Create Long String  ${bts_class_name} status:\n - Operational state: ${status['operationalState']},
    ...  Blocking state: ${status['blockingState']}
    Log  ${rat_info}  console=True
    Export tc run info to tc file  tc_run_info=${rat_info}

Perform Unblock RAT
    [Arguments]  ${rat_type}  ${wait_stable_time}  ${timeout}  ${alias}

    ${BTS_label}=  Get From Dictionary  ${BTS_alias_label_dict}  ${alias}
    ${bts_class_name}=  Set Variable If  '${rat_type}' == 'NR'  NRBTS  '${rat_type}' == 'LTE'  LNBTS  '${rat_type}' == 'WCDMA'  WNBTS
    ...  '${rat_type}' == 'GSM'  GNBTS
    ${bts_rat_id}=  Get Id For Current  ${bts_class_name}  connection=${alias}

    ${operation_info}=  Set Variable  ${BTS_label} -> Perform "Unblock ${rat_type} RAT" operation on ${BTS_label}
    Log  ${operation_info}  console=True
    Export tc run info to tc file  tc_run_info=\n${operation_info}

    coam.Unblock Rat  rat=${rat_type}  timeout=${timeout}  connection=${alias}
    ${operation_info}=  Set Variable  Operation "Unblock ${rat_type} RAT" completed on ${BTS_label}
    Log  ${operation_info}  console=True
    Export tc run info to tc file  tc_run_info=${operation_info}

    Log  Waiting ${wait_stable_time}s for ${BTS_label} stable status  console=True
    Export tc run info to tc file  tc_run_info=\nWaiting ${wait_stable_time}s for ${BTS_label} stable status
    Sleep  ${wait_stable_time}s  Waiting for BTS stable status

    Log  ${BTS_label} -> Check ${bts_class_name} status  console=True
    ${status}=  coam.Get Parameters  dist_name=${bts_rat_id}  connection=${alias}
    ${rat_info}=  Run Keyword If  '${bts_class_name}' == 'GNBTS'
    ...  Create Long String  ${bts_class_name} status:\n - Operational state: ${status['operationalState']}
    ...  ELSE
    ...  Create Long String  ${bts_class_name} status:\n - Operational state: ${status['operationalState']},
    ...  Blocking state: ${status['blockingState']}
    Log  ${rat_info}  console=True
    Export tc run info to tc file  tc_run_info=${rat_info}

Get BTS resources changes
    [Arguments]  ${alias}

    ${BTS_label}=  Get From Dictionary  ${BTS_alias_label_dict}  ${alias}
    Export tc run info to tc file  tc_run_info=\nGet ${BTS_label} resources changes:

    ${change_BTS_info_dict}=  Create Dictionary
    ${change_BTS_HW_info_dict}=  Create Dictionary
    ${change_BTS_CELL_info_dict}=  Create Dictionary

    ${initial_BTS_info_list}=  Get Dictionary Keys  ${initial_${alias}_BTS_info_dict}
    ${final_BTS_info_list}=  Get Dictionary Keys  ${final_${alias}_BTS_info_dict}
    ${initial_BTS_count}=  Get Length  ${initial_BTS_info_list}
    ${final_BTS_count}=  Get Length  ${final_BTS_info_list}
    Should Be Equal As Integers  ${initial_BTS_count}  ${final_BTS_count}

    ${initial_BTS_status_dict}=  Get From Dictionary  ${initial_${alias}_BTS_info_dict}  BTS
    ${final_BTS_status_dict}=  Get From Dictionary  ${final_${alias}_BTS_info_dict}  BTS

    ${initial_BTS_proceduralState}=  Get From Dictionary  ${initial_BTS_status_dict}  proceduralState
    ${final_BTS_proceduralState}=  Get From Dictionary  ${final_BTS_status_dict}  proceduralState
    Run Keyword If  '${initial_BTS_proceduralState}' != '${final_BTS_proceduralState}'  Run Keywords
    ...  Set To Dictionary  ${change_BTS_info_dict}  BTS  ${initial_BTS_proceduralState} -> ${final_BTS_proceduralState}
    ...  AND  Log  BTS Procedural state: ${initial_BTS_proceduralState} -> ${final_BTS_proceduralState}  console=True
    ...  AND  Export tc run info to tc file
    ...  tc_run_info=BTS Procedural state: ${initial_BTS_proceduralState} -> ${final_BTS_proceduralState}

    ${initial_BTS_blockingState}=  Get From Dictionary  ${initial_BTS_status_dict}  blockingState
    ${final_BTS_blockingState}=  Get From Dictionary  ${final_BTS_status_dict}  blockingState
    Run Keyword If  '${initial_BTS_blockingState}' != '${final_BTS_blockingState}'  Run Keywords
    ...  Set To Dictionary  ${change_BTS_info_dict}  BTS  ${initial_BTS_blockingState} -> ${final_BTS_blockingState}
    ...  AND  Log  BTS Blocking state: ${initial_BTS_blockingState} -> ${final_BTS_blockingState}  console=True
    ...  AND  Export tc run info to tc file
    ...  tc_run_info=BTS Blocking state: ${initial_BTS_blockingState} -> ${final_BTS_blockingState}

    FOR  ${item}  IN  @{initial_BTS_info_list}

        Continue For Loop If  '${item}' == 'BTS'

        ${initial_BTS_status_dict}=  Get From Dictionary  ${initial_${alias}_BTS_info_dict}  ${item}
        ${final_BTS_status_dict}=  Get From Dictionary  ${final_${alias}_BTS_info_dict}  ${item}

        ${initial_BTS_operationalState}=  Get From Dictionary  ${initial_BTS_status_dict}  operationalState
        ${final_BTS_operationalState}=  Get From Dictionary  ${final_BTS_status_dict}  operationalState
        Run Keyword If  '${initial_BTS_operationalState}' != '${final_BTS_operationalState}'  Run Keywords
        ...  Set To Dictionary  ${change_BTS_info_dict}  BTS  ${initial_BTS_operationalState} -> ${final_BTS_operationalState}
        ...  AND  Log  ${item} Operational state: ${initial_BTS_operationalState} -> ${final_BTS_operationalState}  console=True
        ...  AND  Export tc run info to tc file
        ...  tc_run_info=${item} Operational state: ${initial_BTS_operationalState} -> ${final_BTS_operationalState}

        Continue For Loop If  '${item}' == 'GNBTS'

        ${initial_BTS_blockingState}=  Get From Dictionary  ${initial_BTS_status_dict}  blockingState
        ${final_BTS_blockingState}=  Get From Dictionary  ${final_BTS_status_dict}  blockingState
        Run Keyword If  '${initial_BTS_blockingState}' != '${final_BTS_blockingState}'  Run Keywords
        ...  Set To Dictionary  ${change_BTS_info_dict}  BTS  ${initial_BTS_blockingState} -> ${final_BTS_blockingState}
        ...  AND  Log  ${item} Blocking state: ${initial_BTS_blockingState} -> ${final_BTS_blockingState}  console=True
        ...  AND  Export tc run info to tc file
        ...  tc_run_info=${item} Blocking state: ${initial_BTS_blockingState} -> ${final_BTS_blockingState}

    END

    ${initial_BTS_HW_info_list}=  Get Dictionary Keys  ${initial_${alias}_HW_info_dict}
    ${final_BTS_HW_info_list}=  Get Dictionary Keys  ${final_${alias}_HW_info_dict}
    ${initial_BTS_HW_count}=  Get Length  ${initial_BTS_HW_info_list}
    ${final_BTS_HW_count}=  Get Length  ${final_BTS_HW_info_list}
    Should Be Equal As Integers  ${initial_BTS_HW_count}  ${final_BTS_HW_count}

    FOR  ${item}  IN  @{initial_BTS_HW_info_list}

        ${initial_BTS_HW_status_dict}=  Get From Dictionary  ${initial_${alias}_HW_info_dict}  ${item}
        ${final_BTS_HW_status_dict}=  Get From Dictionary  ${final_${alias}_HW_info_dict}  ${item}

        ${initial_BTS_HW_operationalState}=  Get From Dictionary  ${initial_BTS_HW_status_dict}  operationalState
        ${final_BTS_HW_operationalState}=  Get From Dictionary  ${final_BTS_HW_status_dict}  operationalState
        Run Keyword If  '${initial_BTS_HW_operationalState}' != '${final_BTS_HW_operationalState}'  Run Keywords
        ...  Set To Dictionary  ${change_BTS_HW_info_dict}  ${item}  ${initial_BTS_HW_operationalState} -> ${final_BTS_HW_operationalState}
        ...  AND  Log  ${item} Operational state: ${initial_BTS_HW_operationalState} -> ${final_BTS_HW_operationalState}  console=True
        ...  AND  Export tc run info to tc file
        ...  tc_run_info=${item} Operational state: ${initial_BTS_HW_operationalState} -> ${final_BTS_HW_operationalState}

        ${initial_BTS_HW_availabilityStatus}=  Get From Dictionary  ${initial_BTS_HW_status_dict}  availabilityStatus
        ${final_BTS_HW_availabilityStatus}=  Get From Dictionary  ${final_BTS_HW_status_dict}  availabilityStatus
        Run Keyword If  '${initial_BTS_HW_availabilityStatus}' != '${final_BTS_HW_availabilityStatus}'  Run Keywords
        ...  Set To Dictionary  ${change_BTS_HW_info_dict}  ${item}  ${initial_BTS_HW_availabilityStatus} -> ${final_BTS_HW_availabilityStatus}
        ...  AND  Log  ${item} Availability status: ${initial_BTS_HW_availabilityStatus} -> ${final_BTS_HW_availabilityStatus}  console=True
        ...  AND  Export tc run info to tc file
        ...  tc_run_info=${item} Availability status: ${initial_BTS_HW_availabilityStatus} -> ${final_BTS_HW_availabilityStatus}

        ${initial_BTS_HW_administrativeState}=  Get From Dictionary  ${initial_BTS_HW_status_dict}  administrativeState
        ${final_BTS_HW_administrativeState}=  Get From Dictionary  ${final_BTS_HW_status_dict}  administrativeState
        Run Keyword If  '${initial_BTS_HW_administrativeState}' != '${final_BTS_HW_administrativeState}'  Run Keywords
        ...  Set To Dictionary  ${change_BTS_HW_info_dict}  ${item}  ${initial_BTS_HW_administrativeState} -> ${final_BTS_HW_administrativeState}
        ...  AND  Log  ${item} Administrative state: ${initial_BTS_HW_administrativeState} -> ${final_BTS_HW_administrativeState}  console=True
        ...  AND  Export tc run info to tc file
        ...  tc_run_info=${item} Administrative state: ${initial_BTS_HW_administrativeState} -> ${final_BTS_HW_administrativeState}

    END

    ${initial_BTS_CELL_info_list}=  Get Dictionary Keys  ${initial_${alias}_CELL_info_dict}
    ${final_BTS_CELL_info_list}=  Get Dictionary Keys  ${final_${alias}_CELL_info_dict}
    ${initial_BTS_CELL_count}=  Get Length  ${initial_BTS_CELL_info_list}
    ${final_BTS_CELL_count}=  Get Length  ${final_BTS_CELL_info_list}
    Should Be Equal As Integers  ${initial_BTS_CELL_count}  ${final_BTS_CELL_count}

    FOR  ${item}  IN  @{initial_BTS_CELL_info_list}

        ${initial_BTS_CELL_status_dict}=  Get From Dictionary  ${initial_${alias}_CELL_info_dict}  ${item}
        ${final_BTS_CELL_status_dict}=  Get From Dictionary  ${final_${alias}_CELL_info_dict}  ${item}

        ${initial_BTS_CELL_operationalState}=  Get From Dictionary  ${initial_BTS_CELL_status_dict}  operationalState
        ${final_BTS_CELL_operationalState}=  Get From Dictionary  ${final_BTS_CELL_status_dict}  operationalState
        Run Keyword If  '${initial_BTS_CELL_operationalState}' != '${final_BTS_CELL_operationalState}'  Run Keywords
        ...  Set To Dictionary  ${change_BTS_CELL_info_dict}  ${item}  ${initial_BTS_CELL_operationalState} -> ${final_BTS_CELL_operationalState}
        ...  AND  Log  ${item} Operational state: ${initial_BTS_CELL_operationalState} -> ${final_BTS_CELL_operationalState}  console=True
        ...  AND  Export tc run info to tc file
        ...  tc_run_info=${item} Operational state: ${initial_BTS_CELL_operationalState} -> ${final_BTS_CELL_operationalState}

        ${initial_BTS_CELL_availabilityStatus}=  Get From Dictionary  ${initial_BTS_CELL_status_dict}  availabilityStatus
        ${final_BTS_CELL_availabilityStatus}=  Get From Dictionary  ${final_BTS_CELL_status_dict}  availabilityStatus
        Run Keyword If  '${initial_BTS_CELL_availabilityStatus}' != '${final_BTS_CELL_availabilityStatus}'  Run Keywords
        ...  Set To Dictionary  ${change_BTS_CELL_info_dict}  ${item}  ${initial_BTS_CELL_availabilityStatus} -> ${final_BTS_CELL_availabilityStatus}
        ...  AND  Log  ${item} Availability status: ${initial_BTS_CELL_availabilityStatus} -> ${final_BTS_CELL_availabilityStatus}  console=True
        ...  AND  Export tc run info to tc file
        ...  tc_run_info=${item} Availability status: ${initial_BTS_CELL_availabilityStatus} -> ${final_BTS_CELL_availabilityStatus}

        ${initial_BTS_CELL_blockingState}=  Get From Dictionary  ${initial_BTS_CELL_status_dict}  blockingState
        ${final_BTS_CELL_blockingState}=  Get From Dictionary  ${final_BTS_CELL_status_dict}  blockingState
        Run Keyword If  '${initial_BTS_CELL_blockingState}' != '${final_BTS_CELL_blockingState}'  Run Keywords
        ...  Set To Dictionary  ${change_BTS_CELL_info_dict}  ${item}  ${initial_BTS_CELL_blockingState} -> ${final_BTS_CELL_blockingState}
        ...  AND  Log  ${item} Blocking state: ${initial_BTS_CELL_blockingState} -> ${final_BTS_CELL_blockingState}  console=True
        ...  AND  Export tc run info to tc file
        ...  tc_run_info=${item} Blocking state: ${initial_BTS_CELL_blockingState} -> ${final_BTS_CELL_blockingState}

        ${administrativeState_check}=  Run Keyword And Return Status  Variable Should Exist  ${initial_BTS_CELL_status_dict['administrativeState']}
        Continue For Loop If  not ${administrativeState_check}

        ${initial_BTS_CELL_administrativeState}=  Get From Dictionary  ${initial_BTS_CELL_status_dict}  administrativeState
        ${final_BTS_CELL_administrativeState}=  Get From Dictionary  ${final_BTS_CELL_status_dict}  administrativeState
        Run Keyword If  '${initial_BTS_CELL_administrativeState}' != '${final_BTS_CELL_administrativeState}'  Run Keywords
        ...  Set To Dictionary  ${change_BTS_CELL_info_dict}  ${item}
        ...  ${initial_BTS_CELL_administrativeState} -> ${final_BTS_CELL_administrativeState}
        ...  AND  Log  ${item} Administrative state: ${initial_BTS_CELL_administrativeState} -> ${final_BTS_CELL_administrativeState}  console=True
        ...  AND  Export tc run info to tc file
        ...  tc_run_info=${item} Administrative state: ${initial_BTS_CELL_administrativeState} -> ${final_BTS_CELL_administrativeState}

    END

Get different items info from lists
    [Arguments]  ${target_list}  ${compare_list}

    ${diff_list}=  Create List
    FOR  ${item}  IN  @{target_list}

        ${status}=  Run Keyword And Return Status  List Should Contain Value  ${compare_list}  ${item}
        Continue For Loop If  ${status}
        Append To List  ${diff_list}  ${item}

    END

    [Return]  ${diff_list}

Get active alarms info
    [Arguments]  ${BTS_alarms_info}  ${initial_status}  ${final_status}  ${alias}

    ${BTS_label}=  Get From Dictionary  ${BTS_alias_label_dict}  ${alias}
    Log  Get ${BTS_label} active alarms changes (initial ${initial_status} -> final ${final_status}):  console=True
    Export tc run info to tc file  tc_run_info=\nGet ${BTS_label} active alarms changes (initial ${initial_status} -> final ${final_status}):

    FOR  ${index}  ${item}  IN ENUMERATE  @{BTS_alarms_info}

        ${runtime_alarming_object_list}=  Get alarming object info  ${item['alarmingObjectIds']}  runtime
        ${configuration_alarming_object_list}=  Get alarming object info  ${item['alarmingObjectIds']}  configuration

        ${alarm_info}=  Create Long String  Alarm ${index+1} info:\n - Severity: ${item['severity']}, Appeared: ${item['observationTime']},
        ...  Alarm ID: ${item['alarmId']}, Alarm name: ${item['alarmName']}, Fault ID: ${item['faultId']},
        ...  Fault name: ${item['alarmInformation']['faultDescription']}, Runtime alarming object: ${runtime_alarming_object_list[0]},
        ...  Configuration alarming object: ${configuration_alarming_object_list[0]}
        Log  ${alarm_info}  console=True
        Export tc run info to tc file  tc_run_info=${alarm_info}

        Run Keyword If  '${item['faultId']}' in ${BTS_critical_alarms_list}  Run Keywords
        ...  Log  Critical active alarm with fault ID ${item['faultId']} exists on ${BTS_label}!  level=ERROR
        ...  AND  Export tc run info to tc file  tc_run_info=[ERROR] Critical active alarm with fault ID ${item['faultId']} exists on ${BTS_label}!
        ...  AND  Fail  Critical active alarm with fault ID ${item['faultId']} exists on ${BTS_label}!

    END

Get historic alarms info
    [Arguments]  ${BTS_alarms_info}  ${initial_status}  ${final_status}  ${alias}

    ${BTS_label}=  Get From Dictionary  ${BTS_alias_label_dict}  ${alias}
    Log  Get ${BTS_label} historic alarms changes (initial ${initial_status} -> final ${final_status}):  console=True
    Export tc run info to tc file  tc_run_info=\nGet ${BTS_label} historic alarms changes (initial ${initial_status} -> final ${final_status}):

    FOR  ${index}  ${item}  IN ENUMERATE  @{BTS_alarms_info}

        ${runtime_alarming_object_list}=  Get alarming object info  ${item['alarmingObjectIds']}  runtime
        ${configuration_alarming_object_list}=  Get alarming object info  ${item['alarmingObjectIds']}  configuration

        ${alarm_info}=  Create Long String  Alarm ${index+1} info:\n - Severity: ${item['severity']}, Appeared: ${item['btsObservationTime']},
        ...  Cleared: ${item['clearedTime']}, Alarm ID: ${item['alarmId']}, Alarm name: ${item['alarmName']}, Fault ID: ${item['faultId']},
        ...  Fault name: ${item['faultName']}, Runtime alarming object: ${runtime_alarming_object_list[0]},
        ...  Configuration alarming object: ${configuration_alarming_object_list[0]}
        Log  ${alarm_info}  console=True
        Export tc run info to tc file  tc_run_info=${alarm_info}

        Run Keyword If  '${item['faultId']}' in ${BTS_critical_alarms_list}  Run Keywords
        ...  Log  Critical historic alarm with fault ID ${item['faultId']} exists on ${BTS_label}!  level=ERROR
        ...  AND  Export tc run info to tc file  tc_run_info=[ERROR] Critical historic alarm with fault ID ${item['faultId']} exists on ${BTS_label}!
        ...  AND  Fail  Critical historic alarm with fault ID ${item['faultId']} exists on ${BTS_label}!

    END

Check PDU port status
    [Arguments]  ${item}  ${status}

    ${PDU_port_status}=  Pdu BTS Interface Get Status  ${item}
    Run Keyword if  '${PDU_port_status}' == '${status}'
    ...  Log  ${item} PDU info: IP=${INTERFACES['${item}']['IP']}, PORT=${INTERFACES['${item}']['OUTLET']} switched ${PDU_port_status}  console=True
    ...  ELSE  Run Keywords
    ...  Log  ${item} PDU info: IP=${INTERFACES['${item}']['IP']}, PORT=${INTERFACES['${item}']['OUTLET']} switched ${PDU_port_status}!  level=ERROR
    ...  AND  Fail  ${item} PDU info: IP=${INTERFACES['${item}']['IP']}, PORT=${INTERFACES['${item}']['OUTLET']} switched ${PDU_port_status}!

Export tc run info to tc file
    [Arguments]  ${tc_run_info}

    ${tc_file_path}=  Set Variable  ${tc_folder_path}/${tc_file_name}.txt
    ${tc_file_path_status}=  Run Keyword And Return Status  OperatingSystem.File Should Exist  ${tc_file_path}
    Run Keyword If  not ${tc_file_path_status}
    ...  Create File  ${tc_file_path}

    Append To File  ${tc_file_path}  ${tc_run_info} \n

Export tc file info to suite file
    [Arguments]  ${tc_file_info}
    ${tc_file_content}=  OperatingSystem.Get File  ${tc_file_info}
    ${suite_file_path}=  Set Variable  ${suite_folder_path}/${suite_file_name}.txt
    ${suite_file_path_status}=  Run Keyword And Return Status  OperatingSystem.File Should Exist  ${suite_file_path}
    Run Keyword If  not ${suite_file_path_status}
    ...  Create File  ${suite_file_path}

    Append To File  ${suite_file_path}  =========================================================================================== \n
    Append To File  ${suite_file_path}  =========================================================================================== \n
    Append To File  ${suite_file_path}  ${tc_file_content} \n

Trigger BTS snapshot collect
    [Arguments]  ${target_file_name}  ${alias}

    coam.Collect Snapshot  target_file_name=${target_file_name}  connection=${alias}  timeout=1800
    ${target_file_name_status}=  Run Keyword And Return Status  OperatingSystem.File Should Exist  ${target_file_name}
    Run Keyword If  ${target_file_name_status}
    ...  Log  BTS ${alias} snapshot collect info: ${target_file_name}  console=True
    ...  ELSE  Run Keywords
    ...  Log  BTS ${alias} snapshot collect failed!  level=ERROR
    ...  AND  Fail  BTS ${alias} snapshot collect failed!
    Export tc run info to tc file  tc_run_info=\nBTS ${alias} snapshot collect info: ${target_file_name}

Particular Teardown
    Export tc file info to suite file  tc_file_info=${tc_folder_path}/${tc_file_name}.txt

TC Setup
    ${tech_preset_list}=  Create List  SBTS  SBTS  SBTS  SBTS
    Common Test Setup  PrecheckConf=${FALSE}  PrecheckCells=${FALSE}  PrecheckModules=${FALSE}  PrecheckSCF=${FALSE}  RTWP_check=${FALSE}
    ...  preset_techs=${tech_preset_list}  common_sbts=${TRUE}  infomodelSetup=${FALSE}  GetModuleInformation=${FALSE}

TC Teardown
    Common Test Teardown
