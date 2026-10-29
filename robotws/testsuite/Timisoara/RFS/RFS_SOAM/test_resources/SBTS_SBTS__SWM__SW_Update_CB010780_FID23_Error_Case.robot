*** Settings ***
Documentation    TC__SBTS_SBTS__SWM__SW_Update_CB010780_FID23_Error_Case
Variables    tc_variables/sbts_sbts__swm__sw_update_cb010780_fid23_error_case_alarms_definitions.py
Resource    ../../resources/rfs_frame_rfs_soam_taf.robot

*** Variables ***
${REPEAT_COUNTER}              3      # Number of repetitions, default value 3
${Target SW dir}               /home/ute/btsauto/TARGET_SW_BTS1  # path to directory with SW build zip files
${Target SW name}                     # N+1 BTS SW name; In case ${FORCE_CURRENT_SW_DL} = True, this parameter doesn't need to be modified and the
                                      # target SW build will be the CM reservation SW build.
                                      # In case ${FORCE_CURRENT_SW_DL} = False, Target BTS SW name should be filled (in case of Trunk SW, its
                                      # name should start with SBTS00, as in WFT tool) and SW build should be manually downloaded in ${Target SW dir}
${Initial SW name}                    # Initial BTS SW name (mandatory parameter); In case ${FORCE_CURRENT_SW_DL} = True, SW build will be
                                      # downloaded automatically for both CM and offline run (for automated SW download, in case of Trunk SW, its
                                      # name should start with SBTS00, as in WFT tool). In case ${FORCE_CURRENT_SW_DL} = False, SW build should be
                                      # manually downloaded in ${Target SW dir}
${Intermediate SW name}               # Intermediate BTS SW name (mandatory parameter); In case ${FORCE_CURRENT_SW_DL} = True, SW build will be
                                      # downloaded automatically for both CM and offline run (for automated SW download, in case of Trunk SW, its
                                      # name should start with SBTS00, as in WFT tool). In case ${FORCE_CURRENT_SW_DL} = False, SW build should be
                                      # manually downloaded in ${Target SW dir}
${SW Update Timeout}           3000   # Timeout for SW Update; given in seconds
${BTS_MAX_WAIT_TIME}           900    # Maximum time for wait of ENB OnAir
${FORCE_CURRENT_SW_DL}         False  # Force download current reservation SW build in order to be used for SW Update, in offline running it needs
                                      # variable ENB_BUILD to be defined in argfile.txt
${Remote target SW path}       None   # Path to remote zip file which needs to be downloaded; ex: /SBTS/Trunk/SBTS00_ENB_9999_231030_000010.zip
${RFS_CUSTOM_SHARE_SW_DL}      False  # Flag to enable/disable target SW package download from remote location
                                      # - SWs from share-1 can be downloaded locally. Default value is False
${BTS_SCF_VALIDATION}          True   # Validate BTS SCF; can be True or False
${BTS_RU_SW_UPDATE}            BTS1   # BTS on which RU SW Update will be performed. Possible values: BTS1 or BTS2. By default: BTS1
${FID23_RM_SN_LIST}            ALL    # RM serial number list on which FID23 error case will be tested. Possible values: ALL (disableSWUpdate
                                      # will set on true on all RM) or list of selected RM serial number separated by comma.
                                      # By default: ALL
${sequentialRuSwUpgrade}       false  # Parameter sequentialRuSwUpgrade value to be tested. Possible values: true or false (by default false)
${CB007447_SHARED_RM_SN_EXCEPTIONS_LIST}  # CPRI shared RM serial number list separated by comma that don't support feature CB007447 (only in case
                                          # CB007447 is activated)

*** Keywords ***
TC__SBTS_SBTS__SWM__SW_Update_CB010780_FID23_Error_Case
     [Documentation]
    ...  [CASE LINK]: https://jiradc.ext.net.nokia.com/browse/TAT-28414
    ...
    ...  *****************
    ...  Basic information
    ...  *****************
    ...  SBTS-SBTS test case for BTS SW Update with check CB010780 FID23 error case.
    ...  The main steps performed for the test are:
    ...  - check initial state and alarms for both BTS
    ...  - get both BTS info for configured items
    ...  - get target SW for BTS SW Update
    ...  - check and activate feature CB006028 on both BTS
    ...  - get and set (if needed) sequentialRuSwUpgrade parameter value on both BTS
    ...  - get and set disableSWUpdate parameter value on both BTS
    ...  - check feature CB007447 status on both BTS
    ...  - perform SW Update as follows:
    ...    - get initial BTS and RM SW versions on both BTS
    ...    - get and check RM SW versions from BTS Target SW version
    ...    - perform RU SW Update from BTS primary controller with peer and own BTS checks
    ...    - set disableSWUpdate parameter on false on ${FID23_RM_SN_LIST}
    ...    - perform DU+RU SW Update from BTS secondary controller with peer and own BTS checks
    ...    - perform DU+RU SW Update from BTS primary controller with peer and own BTS checks
    ...    - get final BTS and RM SW versions on both BTS
    ...    - check BTS and RM SW versions from BTS partitions after SW Update
    ...  - check final state and alarms for both BTS
    ...  Pass criteria: BTS SW Update operation works as expected, states and alarms are as expected
    ...
    ...  ******************
    ...  History of changes
    ...  ******************
    ...  - 19.11.2024 - https://jiradc.ext.net.nokia.com/browse/TAT-28414 - [5G] [CB012267] New TC SBTS_SBTS_RU SW_UPDATED_FID23_ERROR_CASE
    ...  - 17.01.2025 - https://jiradc.ext.net.nokia.com/browse/TAT-28574 - RF SW Timestamp check enhancements in SWM Tcs - after TAT-28573
    ...  - 18.06.2025 - https://jiradc.ext.net.nokia.com/browse/TAT-29378 - Adapt [1]SBTS_SBTS__SWM__SW_Update_CB010780_FID23_Error_Case with
    ...  SW Download followed by SW activation
    ...  - 18.08.2025 - https://jiradc.ext.net.nokia.com/browse/TAT-29710 - Adapt [1]SBTS_SBTS__SWM__SW_Update_CB010780_FID23_Error_Case with
    ...  the customizable sequentialRuSwUpgrade parameter and with the posibility of SW Upgrade on dedicated RMODs
    ...  - 06.10.2025 - https://jiradc.ext.net.nokia.com/browse/TAT-29992 - TC failed with "Variable '${Target SW}' not found" during
    ...  TC Preconditions
    ...  - 27.11.2025 - https://jiradc.ext.net.nokia.com/browse/TAT-30221 - Remove ${actForceUnitAutoReset}' in tests and KWs related to CB007447
    ...

    Set Tags    CA-STATE    OWNER-petronela.daraban@nokia.com    AUTHOR-anca.tatar@nokia.com    PHASE-QT    SW-SBTS25R2

    TC Preconditions
    Step 1: Check initial both BTS state
    Step 2: Check initial both BTS alarms
    Step 3: Get both BTS info for configured items
    Step 4: Get Initial and Intermediate SW builds
    Step 5: Get Target SW for BTS SW Update
    Step 6: Check feature CB006028 status on both BTS
    Step 7: Get and set sequentialRuSwUpgrade parameter value on both BTS
    Step 8: Get and set actValidationOnUpgrade parameter value on both BTS
    Step 9: Get disableSWUpdate parameter value on both BTS
    Step 10: Check feature CB007447 status on both BTS
    FOR  ${INDEX}  IN RANGE  1  ${REPEAT_COUNTER}+1
        Log  ==============================================================================  console=True
        Log  Start Cycle ${INDEX} of ${REPEAT_COUNTER}  console=True
        Log  ==============================================================================  console=True
        Step 11: Perform SW Update for iteration ${INDEX}
        Step 12: Check final both BTS state
        Step 13: Check final both BTS alarms
        Step 14: Check final number and state of Cells and RMs
    END

    [Teardown]  Particular Teardown

TC Preconditions
    ${Initial_SW_name_status}=  Run Keyword And Return Status  Should Not Be Empty  ${Initial SW name}
    Run Keyword If  not ${Initial_SW_name_status}  Run Keywords
    ...  Log  Test argument \${Initial_SW_name_status} should not be empty!  level=ERROR
    ...  AND  Fail  Test argument \${Initial_SW_name_status} should not be empty!

    ${Intermediate_SW_name_status}=  Run Keyword And Return Status  Should Not Be Empty  ${Intermediate SW name}
    Run Keyword If  not ${Intermediate_SW_name_status}  Run Keywords
    ...  Log  Test argument \${Intermediate_SW_name_status} should not be empty!  level=ERROR
    ...  AND  Fail  Test argument \${Intermediate_SW_name_status} should not be empty!

    ${BTS_alias_label_dict}  ${BTS_label_alias_dict}=  Get BTS alias label info dict
    Set Test Variable  ${BTS_alias_label_dict}
    Set Test Variable  ${BTS_label_alias_dict}

    ${BTS_alias_RM_sn_dict}  ${RM_sn_BTS_alias_dict}  ${shared_RM_sn_list}  ${dedicated_RM_sn_list}=  Get all BTS RMOD sharing info
    Set Test Variable  ${BTS_alias_RM_sn_dict}
    Set Test Variable  ${RM_sn_BTS_alias_dict}
    Set Test Variable  ${shared_RM_sn_list}
    Set Test Variable  ${dedicated_RM_sn_list}

    Check BTS RU SW Update info

    Check FID23 RM serial number info

Step ${index}: Check ${when} both BTS state
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

Step ${index}: Check ${when} both BTS alarms
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

Step ${index}: Get both BTS info for configured items

    Log  Step ${index}: Get both BTS info for configured items  console=True

    FOR  ${item}  IN  @{alias_list}
        ${RM_sn_id_dict}  ${RM_id_sn_dict}=  Get RM id sn info dict  ${item}
        Set Test Variable  ${${item}_RM_sn_id_dict}  ${RM_sn_id_dict}
        Set Test Variable  ${${item}_RM_id_sn_dict}  ${RM_id_sn_dict}
    END

    Run Keyword If  '${CB007447_SHARED_RM_SN_EXCEPTIONS_LIST}' != ''
    ...  Check RM CPRI CB007447 validity
    ...  ELSE
    ...  Set Test Variable  @{CB007447_shared_RM_sn_exceptions_list}  @{EMPTY}

    FOR  ${item}  IN  @{alias_list}
        ${BTS_dedicated_RM_sn_list}=  Get dedicated RM list   ${dedicated_RM_sn_list}  ${item}
        Set Test Variable  ${${item}_BTS_dedicated_RM_sn_list}  ${BTS_dedicated_RM_sn_list}
    END

Step ${index}: Get Initial and Intermediate SW builds

    Log  Step ${index}: Get Initial and Intermediate SW builds  console=True

    Run Keyword If  '${FORCE_CURRENT_SW_DL}' == 'True'  Run Keywords
    ...  Download SW from WFT
    ...  AND  Return From Keyword

    Log  Get Initial SW Build:  console=True
    Get BTS SW build  sw_build_type=initial  sw_build_name=${Initial SW name}
    Log  Get Intermediate SW Build:  console=True
    Get BTS SW build   sw_build_type=intermediate  sw_build_name=${Intermediate SW name}

Step ${index}: Get Target SW for BTS SW Update
    Log  Step ${index}: Get Target SW for BTS SW Update  console=True

    Run Keyword If  '${FORCE_CURRENT_SW_DL}' == 'True'  Run Keywords
    ...  Get and Check Target SW for BTS SW Update
    ...  AND  Return From Keyword

    ${Target SW tmp}=  Run Keyword If  '${RFS_CUSTOM_SHARE_SW_DL}' != 'True'
    ...  Get SW file for SWDL  ${Target SW dir}  ${Target SW name}
    Run Keyword If  '${RFS_CUSTOM_SHARE_SW_DL}'=='True'  Run Keywords
    ...  Log  SW package will be downloaded from remote server  console=True
    ...  AND  SFTP Download SW from remote server and rename  ${Remote target SW path}  Master
    ...  ELSE  Rename Software Package  ${Target SW tmp}
    Set Test Variable  ${Target SW}
    Log  Target SW for BTS SW Update: ${Target SW}  console=True
    Check if SW version already exists on BTS
    ${target_sw_path}  ${target_sw_file}=  Split Path  ${Target SW}
    ${target_sw_name}  ${ext}=  Split Extension  ${target_sw_file}
    ${qc_target_sw}=  Convert To Uppercase  ${target_sw_name}
    Set Test Variable  ${Target SW name}

    FOR  ${item}  IN  @{alias_list}
        Set Qc Parameter  qc_tc_swbuild  ${qc_target_sw}; ${QC ${item} Active SW}
    END

    ${TargetBD_xml}=  Get TargetBD File From SW Package  ${Target SW}
    Set Test Variable  ${TargetBD_xml_file}  ${TargetBD_xml}

Step ${index}: Check feature CB006028 status on both BTS

    Log  Step ${index}: Check feature CB006028 status on both BTS  console=True
    Log  Get actIndSwUpgradeForSharedRU parameter value on all shared RMs  console=True

    ${initial_RM_sn_RM_id_actIndSwUpgradeForSharedRU_dict}=  Create Dictionary

    FOR  ${RM_sn}  IN  @{shared_RM_sn_list}
        ${RM_BTS_alias_list}=  Get From Dictionary  ${RM_sn_BTS_alias_dict}  ${RM_sn}
        ${RM_id_actIndSwUpgradeForSharedRU_dict}=  Get actIndSwUpgradeForSharedRU parameter  ${RM_sn}  ${RM_BTS_alias_list}
        Set To Dictionary  ${initial_RM_sn_RM_id_actIndSwUpgradeForSharedRU_dict}  ${RM_sn}  ${RM_id_actIndSwUpgradeForSharedRU_dict}
    END

    Set Test Variable  ${initial_RM_sn_RM_id_actIndSwUpgradeForSharedRU_dict}

Step ${index}: Get and set sequentialRuSwUpgrade parameter value on both BTS

    Log  Step ${index}: Get and set sequentialRuSwUpgrade parameter value on both BTS  console=True

    ${initial_BTS_sequentialRuSwUpgrade_dict}=  Create Dictionary
    FOR  ${item}  IN  @{alias_list}
        Log  Check BTS ${item} sequentialRuSwUpgrade parameter value  console=True

        ${sequentialRuSwUpgrade_value}=  Get sequentialRuSwUpgrade parameter value  ${item}
        Log  - BTS ${item} sequentialRuSwUpgrade parameter value: ${sequentialRuSwUpgrade_value}  console=True
        Set To Dictionary  ${initial_BTS_sequentialRuSwUpgrade_dict}  ${item}  ${sequentialRuSwUpgrade_value}
    END
    Set Test Variable  ${initial_BTS_sequentialRuSwUpgrade_dict}

    FOR  ${item}  IN  @{alias_list}
        Log  Set BTS ${item} sequentialRuSwUpgrade parameter value on ${sequentialRuSwUpgrade}  console=True
        Set sequentialRuSwUpgrade parameter value  ${sequentialRuSwUpgrade}  ${item}
    END

Step ${index}: Get disableSWUpdate parameter value on both BTS

    Log  Step ${index}: Get disableSWUpdate parameter value on both BTS  console=True

    Get disableSWUpdate parameter on both BTS  initial

Step ${index}: Get and set actValidationOnUpgrade parameter value on both BTS

    Log  Step ${index}: Get and set actValidationOnUpgrade parameter value on both BTS  console=True

    ${initial_BTS_actValidationOnUpgrade_dict}=  Create Dictionary
    FOR  ${item}  IN  @{alias_list}
        Log  Check BTS ${item} actValidationOnUpgrade parameter value  console=True

        ${actValidationOnUpgrade_value}=  Get actValidationOnUpgrade parameter value  ${item}
        Log  - BTS ${item} actValidationOnUpgrade parameter value: ${actValidationOnUpgrade_value}  console=True
        Set To Dictionary  ${initial_BTS_actValidationOnUpgrade_dict}  ${item}  ${actValidationOnUpgrade_value}
    END
    Set Test Variable  ${initial_BTS_actValidationOnUpgrade_dict}

    FOR  ${item}  IN  @{alias_list}
        Log  Set BTS ${item} actValidationOnUpgrade parameter value on false  console=True
        Set actValidationOnUpgrade parameter value  false  ${item}
    END

Step ${index}: Check feature CB007447 status on both BTS

    Log  Step ${index}: Check feature CB007447 status on both BTS  console=True

    FOR  ${item}  IN  @{alias_list}
        Log  Get feature CB007447 status on BTS ${item}  console=True

        ${actCpriLinkRecovery}  ${actSyncLinkSwitchover}  ${cpriSyncBreakTime}  ${stickToSyncSourcePeriod}=  Get feature CB007447 info  ${item}

        ${condition}=  Create Long String  '${actCpriLinkRecovery}' == 'true' and '${actSyncLinkSwitchover}' == 'true'

        Run Keyword If  ${condition}  Run Keywords
        ...  Log  BTS ${item} feature CB007447 status: Enabled  console=True
        ...  AND  Set Test Variable  ${${item}_CB007447_check}  ${TRUE}
        ...  ELSE  Run Keywords
        ...  Log  BTS ${item} feature CB007447 status: Disabled  console=True
        ...  AND  Set Test Variable  ${${item}_CB007447_check}  ${FALSE}
    END

Step ${index}: Perform SW Update for iteration ${CYCLE}
    [Documentation]
    ...  Perform SW Update on BTS

    ${BTS_peer_alias}=  Set Variable If  '${BTS_RU_SW_UPDATE_alias}' == 'Master'  Slave  Master
    ${BTS_alias}=  Set Variable  ${BTS_RU_SW_UPDATE_alias}
    Set Test Variable  ${RM_state_enabled_check}  operationalState=${Enabled_}, administrativeState=${Unlocked_}
    Set Test Variable  ${RM_state_enabled}  operationalState=Enabled, administrativeState=Unlocked
    Set Test Variable  ${CELL_state_enabled_check}  operationalState=${Enabled_}, blockingState=${Unblocked_}
    Set Test Variable  ${CELL_state_enabled}  operationalState=Enabled, blockingState=Unblocked

    Log  Step ${index}: Perform SW Update for iteration ${CYCLE}  console=True

    Log  Step ${index}.1: Get initial BTS SW versions on both BTS  console=True
    Get BTS SW versions on both BTS  initial

    Log  Step ${index}.2: Get initial RM SW versions on both BTS  console=True
    Get RM SW versions on both BTS  initial

    Log  Step ${index}.3: Get and check RM SW versions from BTS Target SW version  console=True
    Get and check RM SW versions from BTS Target SW version

    Log  Step ${index}.4: Set actIndSwUpgradeForSharedRU on true on all shared RMs  console=True
    Set actIndSwUpgradeForSharedRU parameter on both BTS  actIndSwUpgradeForSharedRU_value=true

    Log  Step ${index}.5: Set disableSWUpdate on true on requested RMs  console=True
    Set disableSWUpdate parameter on both BTS  disableSWUpdate_value=true

    Log  Step ${index}.6: Get shared RM impact on peer BTS ${BTS_peer_alias} before BTS ${BTS_alias} RU SW Update  console=True
    Get shared RM impact on peer BTS  alias=${BTS_alias}  peer_alias=${BTS_peer_alias}  when=initial

    Log  Step ${index}.7: Perform RU SW Update from BTS ${BTS_alias}  console=True
    Perform RU SW Update from BTS  alias=${BTS_alias}  peer_alias=${BTS_peer_alias}

    Log  Step ${index}.8: Set disableSWUpdate on false on requested RMs  console=True
    Set disableSWUpdate parameter on both BTS  disableSWUpdate_value=false

    Log  Step ${index}.9: Get shared RM impact on peer BTS ${BTS_alias} before BTS ${BTS_peer_alias} DU+RU SW Update  console=True
    Get shared RM impact on peer BTS  alias=${BTS_peer_alias}  peer_alias=${BTS_alias}  when=after_RM_SW_Update

    Log  Step ${index}.10: Perform DU+RU SW Update from BTS ${BTS_peer_alias}  console=True
    Perform first DU+RU SW Update from BTS  alias=${BTS_peer_alias}  peer_alias=${BTS_alias}

    Log  Step ${index}.11: Get shared RM impact on peer BTS ${BTS_peer_alias} before BTS ${BTS_alias} DU+RU SW Update  console=True
    Get shared RM impact on peer BTS  alias=${BTS_alias}  peer_alias=${BTS_peer_alias}  when=after_DU_RU_SW_Update

    Log  Step ${index}.12: Perform DU+RU SW Update from BTS ${BTS_alias}  console=True
    Perform second DU+RU SW Update from BTS  alias=${BTS_alias}  peer_alias=${BTS_peer_alias}

    Log  Step ${index}.13: Get final BTS SW versions on both BTS  console=True
    Get BTS SW versions on both BTS  final

    Log  Step ${index}.14: Get final RM SW versions on both BTS  console=True
    Get RM SW versions on both BTS  final

    Log  Step ${index}.15: Check BTS and RM SW versions from BTS partitions after SW Update  console=True
    Check BTS and RM SW versions from BTS partitions after SW Update

    Return From Keyword If  '${CYCLE}' == '${REPEAT_COUNTER}'

    Log  Step ${index}.16: Set actIndSwUpgradeForSharedRU on false on all shared RMs  console=True
    Set actIndSwUpgradeForSharedRU parameter on both BTS  actIndSwUpgradeForSharedRU_value=false

    Log  Step ${index}.17: Perform SW Update in an intermediate software on both BTS  console=True
    Perform initial or intermediate SW Update on both BTS  sw_update_type=intermediate

    Log  Step ${index}.18: Perform SW Update in the initial software on both BTS  console=True
    Perform initial or intermediate SW Update on both BTS  sw_update_type=initial

Step ${index}: Check final number and state of Cells and RMs
    [Documentation]
    ...  Following checks are performed:
    ...  - number of configured cells and radio modules in SCF are properly mapped on BTS running view ADMIN
    ...  - check cells states
    ...  - check radio modules states

    Log  Step ${index}: Check final number and state of Cells and RMs  console=True
    RFS Test Case Final Checks

Check BTS RU SW Update info
    ${BTS_label_list}=  Get Dictionary Keys  ${BTS_label_alias_dict}

    Run Keyword If  '${BTS_RU_SW_UPDATE}' not in ${BTS_label_list}  Run Keywords
    ...  Log Long String  Selected BTS is not valid: ${BTS_RU_SW_UPDATE}. Please select a value for test argument \${BTS_RU_SW_UPDATE} from
    ...  configured BTS: ${BTS_label_list} or let default value: BTS1  console=True
    ...  AND  Fail  Improper value for argument!

    ${BTS_RU_SW_UPDATE_alias}=  Get From Dictionary  ${BTS_label_alias_dict}  ${BTS_RU_SW_UPDATE}
    Set Test Variable  ${BTS_RU_SW_UPDATE_alias}

Check FID23 RM serial number info
    ${RM_sn_list}=  Get From Dictionary  ${BTS_alias_RM_sn_dict}  ${BTS_RU_SW_UPDATE_alias}
    Set Test Variable  ${RM_sn_list}

    Run Keyword If  '${FID23_RM_SN_LIST}' == 'ALL'  Run Keywords
    ...  Set Test Variable  ${FID23_RM_SN_LIST}  ${RM_sn_list}
    ...  AND  Return From Keyword

    ${FID23_RM_SN_LIST_strip}=  Replace String  ${FID23_RM_SN_LIST}  ${SPACE}  ${EMPTY}
    ${FID23_RM_SN_LIST}=  Split String  ${FID23_RM_SN_LIST_strip}  ,
    ${FID23_RM_sn_check}=  Set Variable  True
    ${FID23_RM_SN_invalide_list}=  Create List

    FOR  ${item}  IN  @{FID23_RM_SN_LIST}
        ${FID23_RM_sn_check}=  Set Variable If  '${item}' not in ${RM_sn_list}  False  ${FID23_RM_sn_check}
        Run Keyword If  '${item}' not in ${RM_sn_list}
        ...  Append To List  ${FID23_RM_SN_invalide_list}  ${item}
    END

    Run Keyword If  '${FID23_RM_sn_check}' == 'False'  Run Keywords
    ...  Log Long String  Following selected RM serial number values are not valid: ${FID23_RM_SN_invalide_list}. Please select values for test
    ...  argument \${FID23_RM_SN_LIST} from ${BTS_RU_SW_UPDATE} configured RM: ${RM_sn_list} or let default value: ALL  console=True
    ...  AND  Fail  Improper value for argument!
    Set Test Variable  ${FID23_RM_SN_LIST}

Check RM CPRI CB007447 validity
    ${CB007447_SHARED_RM_SN_EXCEPTIONS_LIST_strip}=  Replace String  ${CB007447_SHARED_RM_SN_EXCEPTIONS_LIST}  ${SPACE}  ${EMPTY}
    ${CB007447_SHARED_RM_SN_EXCEPTIONS_LIST}=  Split String  ${CB007447_SHARED_RM_SN_EXCEPTIONS_LIST}  ,
    ${CB007447_SHARED_RM_SN_EXCEPTIONS_check}=  Set Variable  True
    ${CB007447_SHARED_RM_SN_EXCEPTIONS_invalide_list}=  Create List

    FOR  ${item}  IN  @{CB007447_SHARED_RM_SN_EXCEPTIONS_LIST}
        ${CB007447_SHARED_RM_SN_EXCEPTIONS_check}=  Set Variable If
        ...  '${item}' not in ${shared_RM_sn_list}  False  ${CB007447_SHARED_RM_SN_EXCEPTIONS_check}
        Run Keyword If  '${item}' not in ${shared_RM_sn_list}  Append To List  ${CB007447_SHARED_RM_SN_EXCEPTIONS_invalide_list}  ${item}
    END

    Run Keyword If  '${CB007447_SHARED_RM_SN_EXCEPTIONS_check}' == 'False'  Run Keywords
    ...  Log  Following selected shared RM serial number values are not valid: ${CB007447_SHARED_RM_SN_EXCEPTIONS_invalide_list}.  console=True
    ...  AND  Log  Please select values for test argument \${CB007447_SHARED_RM_SN_EXCEPTIONS_LIST} from configured shared RM: ${shared_RM_sn_list}
    ...  console=True
    ...  AND  Fail  Improper value for argument!
    Set Test Variable  ${CB007447_shared_RM_sn_exceptions_list}  ${CB007447_SHARED_RM_SN_EXCEPTIONS_LIST}

Get dedicated RM list
    [Arguments]  ${dedicated_RM_sn_list}  ${alias}

    ${BTS_dedicated_RM_sn_list}=  Create List
    FOR  ${RM_sn}  IN  @{dedicated_RM_sn_list}
        ${RM_BTS_alias_list}=  Get From Dictionary  ${RM_sn_BTS_alias_dict}  ${RM_sn}
        Run Keyword If  '${alias}' in ${RM_BTS_alias_list}
        ...  Append To List  ${BTS_dedicated_RM_sn_list}  ${RM_sn}
    END

    [Return]  ${BTS_dedicated_RM_sn_list}

Download SW from WFT
    Log  Get Initial SW Build:  console=True
    Download And Set Current SW for SWDL  Target_SW_dir=${Target SW dir}  preloaded_package=${Initial SW name}
    Set Test Variable  ${initial_SW_build}  ${Target SW}

    Log  Get Intermediate SW Build:  console=True
    Download And Set Current SW for SWDL  Target_SW_dir=${Target SW dir}  preloaded_package=${Intermediate SW name}
    Set Test Variable  ${intermediate_SW_build}  ${Target SW}

Get BTS SW build
    [Arguments]    ${sw_build_type}  ${sw_build_name}

    ${SW tmp}=  Get SW file for SWDL  SW dir=${Target SW dir}  SW name=${sw_build_name}
    Rename Software Package  ${SW tmp}
    Set Test Variable  ${${sw_build_type}_SW_build}  ${Target SW}

Get and Check Target SW for BTS SW Update
    Download And Set Current SW for SWDL  Target_SW_dir=${Target SW dir}
    Check if SW version already exists on BTS
    Set Test Variable  ${Target SW name}  ${Target Package Name}
    ${TargetBD_xml}=  Get TargetBD File From SW Package  ${Target SW}
    Set Test Variable  ${TargetBD_xml_file}  ${TargetBD_xml}

Check if SW version already exists on BTS
    FOR  ${item}  IN  @{alias_list}
        Check if SW already exists on BTS  ${Target SW}  ${${item} active SW}  ${${item} passive SW}
    END

Get actIndSwUpgradeForSharedRU parameter
    [Arguments]  ${RM_sn}  ${RM_BTS_alias_list}

    Log  Get shared RM with SN ${RM_sn} actIndSwUpgradeForSharedRU parameter value  console=True

    ${RM_id_actIndSwUpgradeForSharedRU_dict}=  Create Dictionary

    FOR  ${item}  IN  @{RM_BTS_alias_list}
        ${RM_id}=  Get From Dictionary  ${${item}_RM_sn_id_dict}  ${RM_sn}
        ${actIndSwUpgradeForSharedRU_value}=  Get actIndSwUpgradeForSharedRU parameter value  ${RM_id}  ${item}
        Set To Dictionary  ${RM_id_actIndSwUpgradeForSharedRU_dict}  ${RM_id}  ${actIndSwUpgradeForSharedRU_value}
        Log  - BTS ${item} RM id ${RM_id} - actIndSwUpgradeForSharedRU parameter value: ${actIndSwUpgradeForSharedRU_value}  console=True
    END

    [Return]    ${RM_id_actIndSwUpgradeForSharedRU_dict}

Get disableSWUpdate parameter on both BTS
    [Arguments]  ${when}

    ${RM_sn_RM_id_disableSWUpdate_dict}=  Create Dictionary

    FOR  ${RM_sn}  IN  @{FID23_RM_SN_LIST}
        ${RM_BTS_alias_list}=  Get From Dictionary  ${RM_sn_BTS_alias_dict}  ${RM_sn}
        ${RM_id_disableSWUpdate_dict}=  Get disableSWUpdate parameter  ${RM_sn}  ${RM_BTS_alias_list}
        Set To Dictionary  ${RM_sn_RM_id_disableSWUpdate_dict}  ${RM_sn}  ${RM_id_disableSWUpdate_dict}
    END
    Set Test Variable  ${${when}_RM_sn_RM_id_disableSWUpdate_dict}  ${RM_sn_RM_id_disableSWUpdate_dict}

Get disableSWUpdate parameter
    [Arguments]  ${RM_sn}  ${RM_BTS_alias_list}

    Log  Get RM with SN ${RM_sn} disableSWUpdate parameter value  console=True

    ${RM_id_disableSWUpdate_dict}=  Create Dictionary

    FOR  ${item}  IN  @{RM_BTS_alias_list}
        ${RM_id}=  Get From Dictionary  ${${item}_RM_sn_id_dict}  ${RM_sn}
        ${disableSWUpdate_value}=  Get disableSWUpdate parameter value  ${RM_id}  ${item}
        Set To Dictionary  ${RM_id_disableSWUpdate_dict}  ${RM_id}  ${disableSWUpdate_value}
        Log  - BTS ${item} RM id ${RM_id} - disableSWUpdate parameter value: ${disableSWUpdate_value}  console=True
    END

    [Return]    ${RM_id_disableSWUpdate_dict}

Set actIndSwUpgradeForSharedRU parameter on both BTS
    [Arguments]  ${actIndSwUpgradeForSharedRU_value}

    Log  Set actIndSwUpgradeForSharedRU parameter value on all shared RMs  console=True

    FOR  ${RM_sn}  IN  @{shared_RM_sn_list}
        Log  Set shared RM with SN ${RM_sn} actIndSwUpgradeForSharedRU parameter value on ${actIndSwUpgradeForSharedRU_value}  console=True
        ${RM_BTS_alias_list}=  Get From Dictionary  ${RM_sn_BTS_alias_dict}  ${RM_sn}
        Set actIndSwUpgradeForSharedRU parameter  ${actIndSwUpgradeForSharedRU_value}  ${RM_sn}  ${RM_BTS_alias_list}
    END

Set actIndSwUpgradeForSharedRU parameter
    [Arguments]  ${actIndSwUpgradeForSharedRU_value}  ${RM_sn}  ${RM_BTS_alias_list}

    FOR  ${item}  IN  @{RM_BTS_alias_list}
        ${RM_id}=  Get From Dictionary  ${${item}_RM_sn_id_dict}  ${RM_sn}
        Set actIndSwUpgradeForSharedRU parameter value  ${RM_id}  ${actIndSwUpgradeForSharedRU_value}  ${item}
    END

Set disableSWUpdate parameter on both BTS
    [Arguments]  ${disableSWUpdate_value}

    FOR  ${RM_sn}  IN  @{FID23_RM_SN_LIST}
        Log  Set RM with SN ${RM_sn} disableSWUpdate parameter value on ${disableSWUpdate_value}  console=True
        ${RM_BTS_alias_list}=  Get From Dictionary  ${RM_sn_BTS_alias_dict}  ${RM_sn}
        Set disableSWUpdate parameter  ${RM_sn}  ${RM_BTS_alias_list}  ${disableSWUpdate_value}
    END

Set disableSWUpdate parameter
    [Arguments]  ${RM_sn}  ${RM_BTS_alias_list}  ${disableSWUpdate_value}

    FOR  ${item}  IN  @{RM_BTS_alias_list}
        ${RM_id}=  Get From Dictionary  ${${item}_RM_sn_id_dict}  ${RM_sn}
        Set disableSWUpdate parameter value  ${RM_id}  ${disableSWUpdate_value}  ${item}
    END

Get BTS SW versions on both BTS
    [Arguments]  ${when}

    FOR  ${item}  IN  @{alias_list}
        Admin Get BTS SW Version  alias=${item}
        Set Test Variable  ${${item} ${when} active SW}  ${${item} active SW}
        Set Test Variable  ${${item} ${when} passive SW}  ${${item} passive SW}
    END

Get RM SW versions on both BTS
    [Arguments]  ${when}

     FOR  ${item}  IN  @{alias_list}
         Get RM SW info dict on BTS  ${item}  ${when}
     END

Get RM SW info dict on BTS
    [Arguments]  ${alias}  ${when}

    ${RM_serialNumber_buildVersion_dict}  ${RM_serialNumber_buildTimestamp_dict}  ${RM_serialNumber_productName_dict}
    ...  ${RM_serialNumber_l3Protocol_dict}=  Get BTS running RMOD SW info dict  ${alias}
    Set Test Variable  ${${alias}_${when}_RM_serialNumber_buildVersion_dict}  ${RM_serialNumber_buildVersion_dict}
    Set Test Variable  ${${alias}_${when}_RM_serialNumber_buildTimestamp_dict}  ${RM_serialNumber_buildTimestamp_dict}
    Set Test Variable  ${${alias}_RM_serialNumber_productName_dict}  ${RM_serialNumber_productName_dict}
    Set Test Variable  ${${alias}_RM_serialNumber_l3Protocol_dict}  ${RM_serialNumber_l3Protocol_dict}

    ${RM_serialNumber_list}=  Get Dictionary Keys  ${RM_serialNumber_buildVersion_dict}
    Sort List  ${RM_serialNumber_list}
    Set Test Variable  ${${alias}_RM_serialNumber_list}  ${RM_serialNumber_list}

    Log  Running BTS ${alias} ${when} RM SW info:  console=True

    FOR  ${RM_sn}  IN  @{RM_serialNumber_list}
        ${RM_productName}=  Get From Dictionary  ${RM_serialNumber_productName_dict}  ${RM_sn}
        ${RM_l3Protocol}=  Get From Dictionary  ${RM_serialNumber_l3Protocol_dict}  ${RM_sn}
        ${RM_buildVersion}=  Get From Dictionary  ${RM_serialNumber_buildVersion_dict}  ${RM_sn}
        Log  - RM ${RM_productName} with SN ${RM_sn} (${RM_l3Protocol}) buildVersion: ${RM_buildVersion}  console=True
        ${RM_buildTimestamp}=  Get From Dictionary  ${RM_serialNumber_buildTimestamp_dict}  ${RM_sn}
        Log  - RM ${RM_productName} with SN ${RM_sn} (${RM_l3Protocol}) buildTimestamp: ${RM_buildTimestamp}  console=True
    END

Get and check RM SW versions from BTS Target SW version
    [Documentation]
    ...  Get and Check RM SW versions from BTS Target SW version

    FOR  ${item}  IN   @{alias_list}
        Get RM SW versions from BTS Target SW version  ${item}
        Check RM SW versions from BTS Target SW version  ${item}  initial
        Ensure that all shared RMs selected for FID23 error case check have newer target RM SW  ${item}
    END

Get RM SW versions from BTS Target SW version
    [Arguments]  ${alias}

    ${target_RM_serialNumber_buildVersion_dict}=  Create Dictionary
    ${target_RM_serialNumber_buildTimestamp_dict}=  Create Dictionary

    Log  Target BTS ${alias} RM SW info:  console=True
    FOR  ${RM_sn}  IN  @{${alias}_RM_serialNumber_list}
       ${RM_productName}=  Get From Dictionary  ${${alias}_RM_serialNumber_productName_dict}  ${RM_sn}
       ${RM_l3Protocol}=  Get From Dictionary  ${${alias}_RM_serialNumber_l3Protocol_dict}  ${RM_sn}

       ${resourceBuildKey_resourceSWVersion_dict}  ${resourceBuildKey_buildTimestamp_dict}=  Get TargetBD RMOD SW info dict  ${TargetBD_xml_file}
       ...  ${RM_productName}

       ${RM_resourceSWVersion_list}=  Get Dictionary Values  ${resourceBuildKey_resourceSWVersion_dict}  False
       ${RM_resourceSWVersion_count}=  Get Length  ${RM_resourceSWVersion_list}
       ${RM_resourceSWVersion}=  Run Keyword If  ${RM_resourceSWVersion_count} == 1
       ...  Get From List  ${RM_resourceSWVersion_list}  0
       ...  ELSE IF  ${RM_resourceSWVersion_count} > 1 and '${RM_l3Protocol}' == 'ECPRI_MPLANE'
       ...  Get From Dictionary  ${resourceBuildKey_resourceSWVersion_dict}  LTX_${RM_productName}_E1
       ...  ELSE
       ...  Get From Dictionary  ${resourceBuildKey_resourceSWVersion_dict}  LTX_${RM_productName}
       Log  - RM ${RM_productName} with SN ${RM_sn} (${RM_l3Protocol}) buildVersion: ${RM_resourceSWVersion}  console=True
       Set To Dictionary  ${target_RM_serialNumber_buildVersion_dict}  ${RM_sn}  ${RM_resourceSWVersion}

       ${RM_buildTimestamp_list}=  Get Dictionary Values  ${resourceBuildKey_buildTimestamp_dict}  False
       ${RM_buildTimestamp_count}=  Get Length  ${RM_buildTimestamp_list}
       ${RM_buildTimestamp}=  Run Keyword If  ${RM_buildTimestamp_count} == 1
       ...  Get From List  ${RM_buildTimestamp_list}  0
       ...  ELSE IF  ${RM_buildTimestamp_count} > 1 and '${RM_l3Protocol}' == 'ECPRI_MPLANE'
       ...  Get From Dictionary  ${resourceBuildKey_buildTimestamp_dict}  LTX_${RM_productName}_E1
       ...  ELSE
       ...  Get From Dictionary  ${resourceBuildKey_buildTimestamp_dict}  LTX_${RM_productName}
       Log  - RM ${RM_productName} with SN ${RM_sn} (${RM_l3Protocol}) buildTimestamp: ${RM_buildTimestamp}  console=True
       Set To Dictionary  ${target_RM_serialNumber_buildTimestamp_dict}  ${RM_sn}  ${RM_buildTimestamp}
    END

    Set Test Variable  ${${alias}_target_RM_serialNumber_buildVersion_dict}  ${target_RM_serialNumber_buildVersion_dict}
    Set Test Variable  ${${alias}_target_RM_serialNumber_buildTimestamp_dict}  ${target_RM_serialNumber_buildTimestamp_dict}

Check RM SW versions from BTS Target SW version
    [Arguments]  ${alias}  ${when}

     ${RM_sn_newer_SW_buildVersion_list}=  Create List
     ${RM_sn_target_SW_buildVersion_list}=  Create List

     FOR  ${RM_sn}  IN  @{${alias}_RM_serialNumber_list}
        ${newer_RM_SW_buildVersion_found}=  Compare RM SW info  ${alias}  ${RM_sn}  ${when}
        Run Keyword If  '${newer_RM_SW_buildVersion_found}' == 'True'
        ...  Append To List  ${RM_sn_newer_SW_buildVersion_list}  ${RM_sn}
        ...  ELSE IF  '${newer_RM_SW_buildVersion_found}' == 'False'
        ...  Append To List  ${RM_sn_target_SW_buildVersion_list}  ${RM_sn}
     END

     Set Test Variable  ${${alias}_${when}_RM_sn_newer_SW_buildVersion_list}  ${RM_sn_newer_SW_buildVersion_list}
     Set Test Variable  ${${alias}_${when}_RM_sn_target_SW_buildVersion_list}  ${RM_sn_target_SW_buildVersion_list}

Compare RM SW info
    [Arguments]  ${alias}  ${RM_sn}  ${when}

    ${running_RM_buildVersion}=  Get From Dictionary  ${${alias}_${when}_RM_serialNumber_buildVersion_dict}  ${RM_sn}
    ${target_RM_buildVersion}=  Get From Dictionary  ${${alias}_target_RM_serialNumber_buildVersion_dict}  ${RM_sn}

    Return From Keyword If  '${target_RM_buildVersion}' == '${running_RM_buildVersion}'  ${False}

    ${running_RM_buildTimestamp}=  Get From Dictionary  ${${alias}_initial_RM_serialNumber_buildTimestamp_dict}  ${RM_sn}
    ${target_RM_buildTimestamp}=  Get From Dictionary  ${${alias}_target_RM_serialNumber_buildTimestamp_dict}  ${RM_sn}

    ${Newer_buildVersion}=  Compare and parse RMOD buildVersion and buildTimestamp from TargetBD and BTS
    ...  ${target_RM_buildVersion}  ${running_RM_buildVersion}  ${target_RM_buildTimestamp}  ${running_RM_buildTimestamp}

    ${newer_RM_SW_buildVersion_found}=  Set Variable If  '${target_RM_buildVersion}' == '${Newer_buildVersion}'  ${True}  ${False}

    [Return]  ${newer_RM_SW_buildVersion_found}

Ensure that all shared RMs selected for FID23 error case check have newer target RM SW
    [Arguments]    ${alias}

    FOR  ${FID23_RM_SN}  IN  @{FID23_RM_SN_LIST}
        Continue For Loop If  '${FID23_RM_SN}' not in ${${alias}_BTS_dedicated_RM_sn_list}
        Run Keyword If  '${FID23_RM_SN}' not in ${${alias}_initial_RM_sn_newer_SW_buildVersion_list}  Run Keywords
        ...  Log  BTS ${alias} RM with SN ${FID23_RM_SN} has initial RM SW = target RM SW! Please choose another SW build!  level=ERROR
        ...  AND  FAIL  BTS ${alias} RM with SN ${FID23_RM_SN} has initial RM SW = target RM SW! Please choose another SW build!
    END

    Log  All BTS ${alias} RMs selected for FID23 error case check ${FID23_RM_SN_LIST} have newer target RM SW!  console=True

Get shared RM impact on peer BTS
    [Arguments]    ${alias}  ${peer_alias}  ${when}

    ${all_BTS_PL_shared_RM_info}=  Get PL shared RM info on all BTS
    ${BTS_PL_shared_RM_info}=  Get From Dictionary  ${all_BTS_PL_shared_RM_info}  ${alias}
    ${BTS_PL_CPRI_shared_RM_sn_list}=  Get From Dictionary  ${BTS_PL_shared_RM_info}  BTS_PL_CPRI_shared_RM_sn_list
    ${BTS_PL_ECPRI_shared_RM_sn_list}=  Get From Dictionary  ${BTS_PL_shared_RM_info}  BTS_PL_ECPRI_shared_RM_sn_list
    ${BTS_PL_OBSAI_shared_RM_sn_list}=  Get From Dictionary  ${BTS_PL_shared_RM_info}  BTS_PL_OBSAI_shared_RM_sn_list

    ${BTS_new_RM_SW_list}=  Get BTS new RM SW alarm list  ${alias}  ${when}
    Set Test Variable  ${${alias}_final_new_RM_SW_sn_list}  ${BTS_new_RM_SW_list}

    ${peer_BTS_PL_shared_RM_info}=  Get From Dictionary  ${all_BTS_PL_shared_RM_info}  ${peer_alias}
    ${peer_BTS_non_PL_CPRI_shared_RM_sn_list}=  Get From Dictionary  ${peer_BTS_PL_shared_RM_info}  BTS_non_PL_CPRI_shared_RM_sn_list
    ${peer_BTS_non_PL_ECPRI_shared_RM_sn_list}=  Get From Dictionary  ${peer_BTS_PL_shared_RM_info}  BTS_non_PL_ECPRI_shared_RM_sn_list
    ${peer_BTS_non_PL_ECPRI_shared_RM_id_list}=  Get From Dictionary  ${peer_BTS_PL_shared_RM_info}  BTS_non_PL_ECPRI_shared_RM_id_list
    ${peer_BTS_non_PL_OBSAI_shared_RM_sn_list}=  Get From Dictionary  ${peer_BTS_PL_shared_RM_info}  BTS_non_PL_OBSAI_shared_RM_sn_list

    ${peer_BTS_non_PL_not_excepted_ECPRI_shared_RM_id_list}  ${peer_BTS_non_PL_excepted_ECPRI_shared_RM_id_list}=
    ...  Get excepted and not excepted RMOD lists  ${peer_BTS_non_PL_ECPRI_shared_RM_id_list}  ${RMOD_ECPRI_fid16_exceptions}  ${peer_alias}
    ${peer_BTS_non_PL_not_excepted_ECPRI_shared_RM_sn_list}=
    ...  Get not excepted ECPRI RM SN list  ${peer_BTS_non_PL_not_excepted_ECPRI_shared_RM_id_list}  ${peer_alias}

    ${peer_BTS_new_RM_SW_list}=  Get peer BTS new RM SW alarm list  ${peer_alias}  ${when}
    Set Test Variable  ${${peer_alias}_final_new_RM_SW_sn_list}  ${peer_BTS_new_RM_SW_list}

    ${peer_BTS_non_PL_CPRI_shared_RM_sn_list}=  Get PL impact based on new RM SW and CB007447 exceptions  ${peer_BTS_non_PL_CPRI_shared_RM_sn_list}
    ...  ${peer_BTS_new_RM_SW_list}  ${when}  ${peer_alias}  CPRI
    ${peer_BTS_non_PL_not_excepted_ECPRI_shared_RM_sn_list}=  Get PL impact based on new RM SW and CB007447 exceptions
    ...  ${peer_BTS_non_PL_not_excepted_ECPRI_shared_RM_sn_list}  ${peer_BTS_new_RM_SW_list}  ${when}  ${peer_alias}  ECPRI

    ${peer_BTS_CPRI_alarm_count}=  Calculate peer BTS alarms count  ${BTS_PL_CPRI_shared_RM_sn_list}
    ...  ${peer_BTS_non_PL_CPRI_shared_RM_sn_list}
    ${peer_BTS_ECPRI_alarm_count}=  Calculate peer BTS alarms count  ${BTS_PL_ECPRI_shared_RM_sn_list}
    ...  ${peer_BTS_non_PL_not_excepted_ECPRI_shared_RM_sn_list}
    ${peer_BTS_OBSAI_alarm_count}=  Calculate peer BTS alarms count  ${BTS_PL_OBSAI_shared_RM_sn_list}
    ...  ${peer_BTS_non_PL_OBSAI_shared_RM_sn_list}
    ${peer_BTS_new_RM_SW_alarm_count}=  Get Length  ${peer_BTS_new_RM_SW_list}

    Log  BTS ${peer_alias} new RM SW impacted shared RM count: ${peer_BTS_new_RM_SW_alarm_count}   console=True
    Log  BTS ${peer_alias} PL impacted CPRI shared RM count: ${peer_BTS_CPRI_alarm_count}   console=True
    Log  BTS ${peer_alias} PL impacted ECPRI shared RM count: ${peer_BTS_ECPRI_alarm_count}   console=True
    Log  BTS ${peer_alias} PL impacted OBSAI shared RM count: ${peer_BTS_OBSAI_alarm_count}   console=True

    ${FID10_1815_alarm_count}=  Set Variable  ${peer_BTS_CPRI_alarm_count}
    ${FID10_alarm_count}=  Set Variable  ${peer_BTS_OBSAI_alarm_count}
    ${FID16_alarm_count}=  Evaluate  ${peer_BTS_ECPRI_alarm_count} + 0
    ${FID4773_alarm_count}=  Set Variable  ${peer_BTS_new_RM_SW_alarm_count}
    Set Test Variable  ${${peer_alias}_FID10_1815_alarm_count}  ${FID10_1815_alarm_count}
    Set Test Variable  ${${peer_alias}_FID10_alarm_count}  ${FID10_alarm_count}
    Set Test Variable  ${${peer_alias}_FID16_alarm_count}  ${FID16_alarm_count}
    Set Test Variable  ${${peer_alias}_FID4773_alarm_count}  ${FID4773_alarm_count}
    ${EXPECTED_ALARMS}=  Create List
    ${EXPECTED_ALARMS_10_1815_full}=  Prepare expected alarms list  ${${peer_alias.upper()}_EXPECTED_ALARMS_10_1815}  ${FID10_1815_alarm_count}
    ${EXPECTED_ALARMS_10_full}=  Prepare expected alarms list  ${${peer_alias.upper()}_EXPECTED_ALARMS_10}  ${FID10_alarm_count}
    ${EXPECTED_ALARMS_16_full}=  Prepare expected alarms list  ${${peer_alias.upper()}_EXPECTED_ALARMS_16}  ${FID16_alarm_count}
    ${EXPECTED_ALARMS_4773_full}=  Prepare expected alarms list  ${${peer_alias.upper()}_EXPECTED_ALARMS_4773}
    ...  ${FID4773_alarm_count}
    ${EXPECTED_ALARMS_10_1815_16_4773_full}=  Combine Lists  ${EXPECTED_ALARMS_10_1815_full}  ${EXPECTED_ALARMS_10_full}
    ...  ${EXPECTED_ALARMS_16_full}  ${EXPECTED_ALARMS_4773_full}
    ${EXPECTED_ALARMS}=  Set Variable If
    ...  ${FID10_1815_alarm_count} == 0 and ${FID10_alarm_count} == 0 and ${FID16_alarm_count} == 0 and ${FID4773_alarm_count} == 0
    ...  ${EXPECTED_ALARMS}  ${EXPECTED_ALARMS_10_1815_16_4773_full}
    Set Test Variable  ${${peer_alias.upper()}_EXPECTED_ALARMS}  ${EXPECTED_ALARMS}

Get BTS new RM SW alarm list
    [Arguments]  ${alias}  ${when}
    ${BTS_new_RM_SW_list}=  Create List

    FOR  ${RM_sn}  IN  @{shared_RM_sn_list}
        Run Keyword If  '${RM_sn}' in ${${alias}_${when}_RM_sn_newer_SW_buildVersion_list}
        ...  Append To List  ${BTS_new_RM_SW_list}  ${RM_sn}
    END

    [Return]  ${BTS_new_RM_SW_list}

Get not excepted ECPRI RM SN list
    [Arguments]    ${RM_id_list}  ${alias}

    ${not_excepted_RM_sn_list}=  Create List

    FOR  ${RM_id}  IN  @{RM_id_list}
        ${RM_param}=  Get Parameters For  class_name=RMOD  id_num=${RM_id}  connection=${alias}
        Append To List  ${not_excepted_RM_sn_list}  ${RM_param['serialNumber']}
    END

    [Return]    ${not_excepted_RM_sn_list}

Get peer BTS new RM SW alarm list
    [Arguments]  ${peer_alias}  ${when}
    ${peer_BTS_new_RM_SW_list}=  Create List

    FOR  ${RM_sn}  IN  @{shared_RM_sn_list}
        Run Keyword If  '${RM_sn}' in ${FID23_RM_SN_LIST} and '${when}' == 'initial'
        ...  Continue For Loop
        ...  ELSE IF  '${RM_sn}' in ${${peer_alias}_${when}_RM_sn_newer_SW_buildVersion_list}
        ...  Append To List  ${peer_BTS_new_RM_SW_list}  ${RM_sn}
    END

    [Return]  ${peer_BTS_new_RM_SW_list}

Get PL impact based on new RM SW and CB007447 exceptions
    [Arguments]  ${peer_BTS_non_PL_shared_RM_sn_list}  ${peer_BTS_new_RM_SW_list}  ${when}  ${peer_alias}  ${RM_protocol}

    ${peer_BTS_non_PL_shared_RM_sn_list_copy}=  Copy List  ${peer_BTS_non_PL_shared_RM_sn_list}

    FOR  ${item}  IN  @{peer_BTS_non_PL_shared_RM_sn_list}
        Run Keyword If  ('${item}' in ${peer_BTS_new_RM_SW_list}) or ('${item}' in ${FID23_RM_SN_LIST} and '${when}' == 'initial')
        ...  Remove Values From List  ${peer_BTS_non_PL_shared_RM_sn_list_copy}  ${item}
    END
   Return From Keyword If  '${${peer_alias}_CB007447_check}' == 'False'  ${peer_BTS_non_PL_shared_RM_sn_list_copy}

   FOR  ${item}  IN  @{peer_BTS_non_PL_shared_RM_sn_list_copy}
        Run Keyword If  '${RM_protocol}' == 'CPRI' and '${item}' not in ${CB007447_shared_RM_sn_exceptions_list}
        ...  Remove Values From List  ${peer_BTS_non_PL_shared_RM_sn_list_copy}  ${item}
   END

    [Return]  ${peer_BTS_non_PL_shared_RM_sn_list_copy}

Calculate peer BTS alarms count
    [Arguments]  ${BTS_PL_shared_RM_sn_list}  ${peer_BTS_non_PL_shared_RM_sn_list}
    ${peer_BTS_alarm_count}=  Set Variable  0

    FOR  ${item}  IN  @{BTS_PL_shared_RM_sn_list}
        ${peer_BTS_alarm_count}=  Run Keyword If  '${item}' in ${peer_BTS_non_PL_shared_RM_sn_list}
        ...  Evaluate  ${peer_BTS_alarm_count} + 1
        ...  ELSE
        ...  Evaluate  ${peer_BTS_alarm_count} + 0
    END

    [Return]  ${peer_BTS_alarm_count}

Perform RU SW Update from BTS
    [Arguments]    ${alias}  ${peer_alias}

    Run Keyword If  ${BTS_SCF_VALIDATION}  Check BTS SCF Validation On Demand  alias=${alias}

    ${new_alias}=  Set Variable  ${alias}_RuSwOnly

    Start new ADMIN instance  alias=${alias}  new_alias=${new_alias}  connection_type=${connection_type_${alias}}

    Get RESET timestamp info  start_RU_Update

    ${RuSwOnly_info}=  Run Keyword In Background  Update Software  sw_package=${Target SW}  should_activate=True  timeout=${SW Update Timeout}
    ...  connection=${new_alias}  independent_sw_update_type=RuSwOnly
    Log  BTS ${alias} RU SW Update: download finished!  console=True

    Log  ***** Check peer BTS ${peer_alias} states and alarms during BTS ${alias} RU SW Update *****  console=True
    Check peer BTS states and alarms during BTS SW Update  ${peer_alias}

    Collect Keyword Result  ${RuSwOnly_info}  timeout=${SW Update Timeout}

    Log  ***** Check BTS ${alias} alarms after BTS ${alias} RU SW Update *****  console=True
    Check BTS alarms after BTS RU SW Update  ${alias}

    Log  ***** Check both BTS RM states after BTS ${alias} RU SW Update *****  console=True
    Check BTS RM states and alarms after RU SW Update  ${alias}
    Check BTS RM states and alarms after RU SW Update  ${peer_alias}

    Run Keyword If  ${BTS_SCF_VALIDATION}  Check BTS SCF Validation On Demand  alias=${alias}

    Log  ***** Get RM SW versions after BTS ${alias} RU SW Update *****  console=True
    Get RM SW versions on both BTS  after_RM_SW_Update

    FOR  ${item}  IN  @{alias_list}
        Check RM SW versions from BTS Target SW version  ${item}  after_RM_SW_Update
        Ensure that RMs have been updated to target RM SW  ${item}  after_RM_SW_Update
    END

    Run Keyword If  ${CNI_127210_ENABLED}  Check BTS alarms from IMS  alias=${alias}
    [Teardown]  Teardown Admin  alias=${new_alias}

Check peer BTS states and alarms during BTS SW Update
    [Arguments]    ${peer_alias}

    ${IGNORED_ALARMS_full}=  Combine Lists  ${${peer_alias.upper()}_IGNORED_ALARMS_DURING_RESET}  ${${peer_alias.upper()}_IGNORED_ALARMS}

    Log  Check BTS ${peer_alias} alarms:  console=True
    Run Keyword If  ${${peer_alias}_FID10_alarm_count} > 0
    ...  Log Long String  BTS ${peer_alias} "No connection to Unit (10)" alarm, expected number:
    ...  ${${peer_alias}_FID10_alarm_count}  console=True
    Run Keyword If  ${${peer_alias}_FID10_1815_alarm_count} > 0
    ...  Log Long String  BTS ${peer_alias} "No connection to Unit (10)" or "Not able to synchronize baseband bus (1815)" alarm,
    ...  expected number: ${${peer_alias}_FID10_1815_alarm_count}  console=True
    Run Keyword If  ${${peer_alias}_FID16_alarm_count} > 0
    ...  Log Long String  BTS ${peer_alias} "Unit synchronization failed (16)" alarm, expected number:
    ...  ${${peer_alias}_FID16_alarm_count}  console=True
    Run Keyword If  ${${peer_alias}_FID4773_alarm_count} > 0
    ...  Log Long String  BTS ${peer_alias} "Radio unit reset triggered by peer BTS (4773)" alarm, expected number:
    ...  ${${peer_alias}_FID4773_alarm_count}  console=True

    Get and Check Alarms SOAM  alias=${peer_alias}  poll_interval=5 sec  expected_alarms=${${peer_alias.upper()}_EXPECTED_ALARMS}
    ...  ignored_alarms=${IGNORED_ALARMS_full}  critical_alarms=${${peer_alias.upper()}_CRITICAL_ALARMS}

    Run Keyword If  ${${peer_alias}_FID10_alarm_count} > 0
    ...  Log Long String  BTS ${peer_alias} "No connection to Unit (10)" alarm, found number:
    ...  ${${peer_alias}_FID10_alarm_count}, as expected!  console=True
    Run Keyword If  ${${peer_alias}_FID10_1815_alarm_count} > 0
    ...  Log Long String  BTS ${peer_alias} "No connection to Unit (10)" or "Not able to synchronize baseband bus (1815)" alarm,
    ...  found number: ${${peer_alias}_FID10_1815_alarm_count}, as expected!  console=True
    Run Keyword If  ${${peer_alias}_FID16_alarm_count} > 0
    ...  Log Long String  BTS ${peer_alias} "Unit synchronization failed (16)" alarm, found number:
    ...  ${${peer_alias}_FID16_alarm_count}, as expected!  console=True
    Run Keyword If  ${${peer_alias}_FID4773_alarm_count} > 0
    ...  Log Long String  BTS ${peer_alias} "Radio unit reset triggered by peer BTS (4773)" alarm, found number:
    ...  ${${peer_alias}_FID4773_alarm_count}, as expected!  console=True
    Log  BTS ${peer_alias} site - expected, ignored and critical alarms checked  console=True

    FOR  ${RM_sn}  IN  @{${peer_alias}_BTS_dedicated_RM_sn_list}
        Log  Check BTS ${peer_alias} dedicated RM with SN ${RM_sn} state:  console=True

        ${RM_id}=  Get From Dictionary  ${${peer_alias}_RM_sn_id_dict}  ${RM_sn}
        Assert  class_name=RMOD  id=${RM_id}  parameters=${RM_state_enabled_check}  timeout=5  connection=${peer_alias}
        Log  BTS ${peer_alias} dedicated RM with SN ${RM_sn} status:\n - ${RM_state_enabled}  console=True
    END

Check BTS alarms after BTS RU SW Update
    [Arguments]  ${alias}

    ${FID23_count}=  Get Length  ${FID23_RM_SN_LIST}
    ${EXPECTED_ALARMS_23_full}=  Prepare expected alarms list  ${${alias.upper()}_EXPECTED_ALARMS_23}  ${FID23_count}

    Run Keyword If  ${CNI_127210_ENABLED}  Run Keywords
    ...  Log  Check unexpected BTS ${alias} alarms:  console=True
    ...  AND  Get and Check Alarms SOAM  alias=${alias}  poll_interval=5 sec  expected_alarms=@{EMPTY}
    ...  ignored_alarms=${${alias.upper()}_IGNORED_ALARMS}  critical_alarms=${${alias.upper()}_CRITICAL_ALARMS}
    ...  AND  Log  BTS ${alias} alarms, as expected!  console=True
    ...  ELSE  Run Keywords
    ...  Log  Check BTS ${alias} alarms:  console=True
    ...  AND  Log  BTS ${alias} "Incompatible SW version detected (23)" alarm, expected number: ${FID23_count}  console=True
    ...  AND  Get and Check Alarms SOAM  alias=${alias}  poll_interval=5 sec  expected_alarms=${EXPECTED_ALARMS_23_full}
    ...  ignored_alarms=${${alias.upper()}_IGNORED_ALARMS}  critical_alarms=${${alias.upper()}_CRITICAL_ALARMS}
    ...  AND  Log  BTS ${alias} "Incompatible SW version detected (23)" alarm, found number: ${FID23_count}, as expected!  console=True
    ...  AND  Log  BTS ${alias} site - expected, ignored and critical alarms checked  console=True

Check BTS alarms from IMS
    [Arguments]  ${alias}

    ${FID23_count}=  Get Length  ${FID23_RM_SN_LIST}
    ${EXPECTED_ALARMS_23_full}=  Prepare expected alarms list  ${${alias.upper()}_EXPECTED_ALARMS_23}  ${FID23_count}

    Log  Check BTS ${alias} alarms from IMS  console=True
    Log  BTS ${alias} "Incompatible SW version detected (23)" alarm, expected number: ${FID23_count}  console=True

    ${ims2_alarm_status}=  Run Keyword and Return Status  Wait Until Keyword Succeeds  5 min  30 sec
    ...  Get and check detailed IMS2 Alarms SOAM  alias=${alias}  expected_alarms=${EXPECTED_ALARMS_23_full}
    ...  start_timestamp=${date_timestamp_start_RU_Update_UTC}

    Run Keyword If  not ${ims2_alarm_status}  Run Keywords
    ...  Log  Not all expected ims2 alarms found for ${alias}  level=ERROR
    ...  AND  Fail  ${alias} ims2 alarm check failed !

    Log  BTS ${alias} "Incompatible SW version detected (23)" alarm, found number: ${FID23_count}, as expected!  console=True
    Log  BTS ${alias} site - expected, ignored and critical alarms checked  console=True

Check BTS RM states and alarms after RU SW Update
    [Arguments]    ${alias}

    FOR  ${RM_sn}  IN  @{shared_RM_sn_list}
        Log  Check BTS ${alias} shared RM with SN ${RM_sn} state:  console=True

        ${RM_id}=  Get From Dictionary  ${${alias}_RM_sn_id_dict}  ${RM_sn}
        Assert  class_name=RMOD  id=${RM_id}  parameters=${RM_state_enabled_check}  timeout=${BTS_MAX_WAIT_TIME}  connection=${alias}
        Log  BTS ${alias} shared RM with SN ${RM_sn} status:\n - ${RM_state_enabled}  console=True
    END

    FOR  ${RM_sn}  IN  @{${alias}_BTS_dedicated_RM_sn_list}
        Log  Check BTS ${alias} dedicated RM with SN ${RM_sn} state:  console=True

        ${RM_id}=  Get From Dictionary  ${${alias}_RM_sn_id_dict}  ${RM_sn}
        Assert  class_name=RMOD  id=${RM_id}  parameters=${RM_state_enabled_check}  timeout=${BTS_MAX_WAIT_TIME}  connection=${alias}
        Log  BTS ${alias} dedicated RM with SN ${RM_sn} status:\n - ${RM_state_enabled}  console=True
    END

Ensure that RMs have been updated to target RM SW
    [Arguments]    ${alias}  ${when}

    FOR  ${RM_sn}  IN  @{shared_RM_sn_list}
        ${condition}=  Create Long String  ('${RM_sn}' not in ${${alias}_${when}_RM_sn_target_SW_buildVersion_list}) and
        ...  ('${RM_sn}' not in ${FID23_RM_SN_LIST})
        Run Keyword If  '${RM_sn}' in ${${alias}_initial_RM_sn_newer_SW_buildVersion_list}
        ...  Run Keyword If  ${condition}   Run Keywords
        ...  Log  BTS ${alias} shared with SN ${RM_sn} has not been updated after RU SW Update!  level=ERROR
        ...  AND  FAIL  BTS ${alias} shared with SN ${RM_sn} has not been updated after RU SW Update!
    END
    Log  All BTS ${alias} shared RMs SW (besides those selected for FID23 error case check) have been updated to target RM SW!  console=True

Get RESET timestamp info
    [Arguments]  ${when}

    Get Current Date UTC info  ${when}
    Log  UTC ${when}_point_timestamp: ${date_timestamp_${when}_UTC}  console=True

Perform first DU+RU SW Update from BTS
    [Arguments]    ${alias}  ${peer_alias}

    Run Keyword If  ${BTS_SCF_VALIDATION}  Check BTS SCF Validation On Demand  alias=${alias}

    Get RESET timestamp info  start

    Sleep  60s  reason=Avoid BTS Busy state
    ${reset_number}=  Admin Get Reset info based on BTS SW Precheck  SW_package=${Target SW}  alias=${alias}
    coam.Update Software  sw_package=${Target SW}  should_activate=True  timeout=${SW Update Timeout}  connection=${alias}
    ...  independent_sw_update_type=All
    Log  BTS ${alias} DU+RU SW Update: download finished, waiting for activation reset!  console=True

    ${remote_host_ip}=  Set Variable If  '${alias}' == 'Master'  None  ${${alias.upper()}}[${alias.upper()}_PC_IP_ADDRESS]
    Run Keyword If  ${reset_number} != 0  Wait For Target To Be Not Reachable TAF
    ...  hostname=${${alias.upper()}}[${alias.upper()}_TECH_IP_ADDRESS]  timeout=${BTS_MAX_WAIT_TIME}
    ...  remote_host=${remote_host_ip}

    Get Current Time  reset_start_time
    Log  BTS ${alias} reset_start_time is: ${time_reset_start_time}  console=True

    Log  ***** Check peer BTS ${peer_alias} alarms during BTS ${alias} DU+RU SW Update *****  console=True
    Check peer BTS states and alarms during BTS SW Update  ${peer_alias}

    Wait For Target To Be Reachable TAF  hostname=${${alias.upper()}}[${alias.upper()}_TECH_IP_ADDRESS]
    ...  timeout=${BTS_MAX_WAIT_TIME}  remote_host=${remote_host_ip}
    Sleep  120s
    Admin Collect IMS file with timestamp  folder_path=${Test Results Dir}/IMS/${alias}  alias=${alias}
    Wait Until Keyword Succeeds  3x  10s  Admin reset and Infomodel reconnect sessions  reset_req=True  alias=${alias}  infomodel_reset=False

    Log  ***** Check both BTS states and alarms after BTS ${alias} DU+RU SW Update *****  console=True
    Check both BTS states and alarms after SW Update

    Run Keyword If  ${BTS_SCF_VALIDATION}  Check BTS SCF Validation On Demand  alias=${alias}

    Log  ***** Get RM SW versions after BTS ${alias} DU+RU SW Update *****  console=True
    Get RM SW versions on both BTS  after_DU_RU_SW_Update

    FOR  ${item}  IN  @{alias_list}
        Check RM SW versions from BTS Target SW version  ${item}  after_DU_RU_SW_Update
        Ensure that all RMs selected for FID23 error case check have been updated to target RM SW  ${item}  after_DU_RU_SW_Update  shared
    END

    Get RESET timestamp info  end

    Run Keyword If  '${${peer_alias}_CB007447_check}' == 'True'  Run Keywords
    ...  Log  ***** Check peer BTS ${peer_alias} CPRI RM reset behavior during BTS ${alias} DU+RU SW Update from IMS *****  console=True
    ...  AND  Check peer BTS CPRI RM reset behavior during BTS DU+RU SW Update from IMS  peer_alias=${peer_alias}  alias=${alias}

Check both BTS states and alarms after SW Update
    FOR  ${item}  IN  @{alias_list}
        Log  Check BTS ${item} status:  console=True

        Admin Check BTS Procedural and Blocking states  ${OnAir_}  ${Unblocked_}  ${BTS_MAX_WAIT_TIME}  ${item}
        Log  BTS ${item} site - proceduralState: OnAir, blockingState: Unblocked, as expected!  console=True

        Admin Check BTS RAT cells expected states  ${CELL_state_enabled_check}  ${item}  ${BTS_MAX_WAIT_TIME}
        Log  All BTS ${item} cell(s) status:\n - ${CELL_state_enabled}  console=True
        Check cells availability status online  ${item}  ${BTS_MAX_WAIT_TIME}

        Log  Check BTS ${item} alarms:  console=True
        Get and Check Alarms SOAM  alias=${item}  expected_alarms=@{EMPTY}  ignored_alarms=${${item.upper()}_IGNORED_ALARMS}
        ...  critical_alarms=${${item.upper()}_CRITICAL_ALARMS}
        Log  BTS ${item} site - expected, ignored and critical alarms checked  console=True
    END

Ensure that all RMs selected for FID23 error case check have been updated to target RM SW
    [Arguments]    ${alias}  ${when}  ${sharing}

    FOR  ${RM_sn}  IN  @{FID23_RM_SN_LIST}
        Continue For Loop If  '${RM_sn}' not in ${${sharing}_RM_sn_list}
        Continue For Loop If  '${RM_sn}' not in ${${alias}_BTS_dedicated_RM_sn_list}
        Run Keyword If  '${RM_sn}' not in ${${alias}_${when}_RM_sn_target_SW_buildVersion_list}  Run Keywords
        ...  Log  BTS ${alias} ${sharing} RM with SN ${RM_sn} has not been updated after DU+RU SW Update!  level=ERROR
        ...  AND  FAIL  BTS ${alias} ${sharing} RM with SN ${RM_sn} has not been updated after DU+RU SW Update!
    END

    Log  All BTS ${alias} ${sharing} RMs SW selected for FID23 error case check have been updated to target RM SW!  console=True

Check peer BTS CPRI RM reset behavior during BTS DU+RU SW Update from IMS
    [Arguments]  ${peer_alias}  ${alias}
    [Documentation]
    ...  Check CPRI RM states on peer BTS during BTS DU+RU SW Update

    ${ims_file_path}=  Admin Collect IMS file with timestamp  folder_path=${Test Results Dir}/IMS/${peer_alias}  alias=${peer_alias}
    ${RM_L3Protocol_dict}=  Admin Get RMOD L3 Protocol Info  ${peer_alias}

    FOR  ${RM_sn}  IN  @{shared_RM_sn_list}
        ${RM_id}=  Get From Dictionary  ${${peer_alias}_RM_sn_id_dict}  ${RM_sn}
        ${RM_L3Protocol}=  Get From Dictionary  ${RM_L3Protocol_dict}  ${RM_id}
        Continue For Loop If
        ...  '${RM_L3Protocol}' != 'CPRI_RP1' or ('${RM_L3Protocol}' == 'CPRI_RP1' and '${RM_sn}' in ${CB007447_shared_RM_sn_exceptions_list})
        Continue For Loop If  ${${peer_alias}_final_new_RM_SW_sn_list}
        Log  Checking BTS ${peer_alias} CPRI RM ${RM_id} states during BTS ${alias} DU+RU SW Update  console=True
        Check IMS object states not changed  ${ims_file_path}  ${RM_id}  ${date_timestamp_start_UTC}  ${date_timestamp_end_UTC}  ${peer_alias}
    END

    Log  All CPRI RMs state checks passed! No RM reset was performed!  console=True

Check IMS object states not changed
    [Arguments]  ${ims_file_path}  ${obj_id}  ${begin}  ${end}  ${alias}

    Log  No state changes expected on BTS ${alias} object ${obj_id}   console=True
    ${obj_updates}=  ims2alarms.Get Object Updates In Interval  file_path=${ims_file_path}  obj_dist_name=${obj_id}  begin=${begin}  end=${end}
    ...  obj_exact_match=True

    FOR  ${item}  IN  @{obj_updates}
        ${operationalState_found}=  Run Keyword And Return Status  Dictionary Should Contain Key  ${item}  operationalState
        Run Keyword If  ${operationalState_found}
        ...  Run Keyword If   '${item["operationalState"]}'!='enabled'
        ...  Fail  State operationalState changed for BTS ${alias} object ${obj_id}! Please check IMS file: ${ims_file_path}
        ${availabilityStatus_found}=  Run Keyword And Return Status  Dictionary Should Contain Key  ${item}  availabilityStatus
        Run Keyword If  ${availabilityStatus_found}
        ...  Fail  State availabilityStatus changed for BTS ${alias} object ${obj_id}! Please check IMS file: ${ims_file_path}
    END

Perform second DU+RU SW Update from BTS
    [Arguments]    ${alias}  ${peer_alias}

    Run Keyword If  ${BTS_SCF_VALIDATION}  Check BTS SCF Validation On Demand  alias=${alias}

    Get RESET timestamp info  start

    Sleep  60s  reason=Avoid BTS Busy state
    ${reset_number}=  Admin Get Reset info based on BTS SW Precheck  SW_package=${Target SW}  alias=${alias}
    coam.Update Software  sw_package=${Target SW}  should_activate=True  timeout=${SW Update Timeout}  connection=${alias}
    ...  independent_sw_update_type=All
    Log  BTS ${alias} DU+RU SW Update: download finished, waiting for activation reset!  console=True

    ${remote_host_ip}=  Set Variable If
    ...  '${alias}' == 'Master'  None  ${${alias.upper()}}[${alias.upper()}_PC_IP_ADDRESS]
    Run Keyword If  ${reset_number} != 0  Wait For Target To Be Not Reachable TAF
    ...  hostname=${${alias.upper()}}[${alias.upper()}_TECH_IP_ADDRESS]  timeout=${BTS_MAX_WAIT_TIME}
    ...  remote_host=${remote_host_ip}

    Get Current Time  reset_start_time
    Log  BTS ${alias} reset_start_time is: ${time_reset_start_time}  console=True

    Log  ***** Check peer BTS ${peer_alias} alarms during BTS ${alias} DU+RU SW Update *****  console=True
    Check peer BTS states and alarms during BTS SW Update  ${peer_alias}

    Wait For Target To Be Reachable TAF  hostname=${${alias.upper()}}[${alias.upper()}_TECH_IP_ADDRESS]
    ...  timeout=${BTS_MAX_WAIT_TIME}  remote_host=${remote_host_ip}
    Sleep  120s
    Admin Collect IMS file with timestamp  folder_path=${Test Results Dir}/IMS/${alias}  alias=${alias}
    Wait Until Keyword Succeeds  3x  10s  Admin reset and Infomodel reconnect sessions  reset_req=True  alias=${alias}  infomodel_reset=False

    Log  ***** Check both BTS states and alarms after BTS ${alias} DU+RU SW Update *****  console=True
    Check both BTS states and alarms after SW Update

    Run Keyword If  ${BTS_SCF_VALIDATION}  Check BTS SCF Validation On Demand  alias=${alias}

    Get RESET timestamp info  end

    Log  ***** Get RM SW versions after BTS ${alias} DU+RU SW Update *****  console=True
    Get RM SW versions on both BTS  after_DU_RU_SW_Update

    FOR  ${item}  IN  @{alias_list}
        Check RM SW versions from BTS Target SW version  ${item}  after_DU_RU_SW_Update
        Ensure that all RMs selected for FID23 error case check have been updated to target RM SW  ${item}  after_DU_RU_SW_Update  dedicated
    END

    Run Keyword If  '${${peer_alias}_CB007447_check}' == 'True'  Run Keywords
    ...  Log  ***** Check peer BTS ${peer_alias} CPRI RM reset behavior during BTS ${alias} DU+RU SW Update from IMS *****  console=True
    ...  AND  Check peer BTS CPRI RM reset behavior during BTS DU+RU SW Update from IMS  peer_alias=${peer_alias}  alias=${alias}

Check BTS and RM SW versions from BTS partitions after SW Update
    FOR  ${item}  IN  @{alias_list}
        Log  Check BTS ${item} SW versions  console=True
        Should Match Regexp  ${Target SW}  (?i).*${${item} final active SW}.*
        Should Be Equal  ${${item} initial active SW}  ${${item} final passive SW}
        Log  BTS ${item} final active SW = target SW: ${${item} final active SW}, as expected!  console=True
        Log  BTS ${item} initial active SW = final passive SW: ${${item} final passive SW}, as expected!  console=True
        Log  Check BTS ${item} RM SW versions  console=True
        Check RM SW versions after SW Update  ${item}
    END

Check RM SW versions after SW Update
    [Arguments]    ${alias}

    FOR  ${RM_sn}  IN  @{${alias}_initial_RM_sn_newer_SW_buildVersion_list}
        ${final_buildVersion}=  Get From Dictionary  ${${alias}_final_RM_serialNumber_buildVersion_dict}  ${RM_sn}
        ${target_buildVersion}=  Get From Dictionary  ${${alias}_target_RM_serialNumber_buildVersion_dict}  ${RM_sn}
        Should Be Equal  ${final_buildVersion}  ${target_buildVersion}
        Log  BTS ${alias} final active RM SW = target RM SW: ${final_buildVersion}, as expected!  console=True
    END

Perform initial or intermediate SW Update on both BTS
    [Arguments]    ${sw_update_type}

    FOR  ${alias}  IN  @{alias_list}
        Log  Perform BTS ${alias} SW Update using ${${sw_update_type}_SW_build} SW build  console=True

        Run Keyword If  ${BTS_SCF_VALIDATION}  Check BTS SCF Validation On Demand  alias=${alias}

        Sleep  60s  reason=Avoid BTS Busy state
        ${reset_number}=  Admin Get Reset info based on BTS SW Precheck  SW_package=${${sw_update_type}_SW_build}  alias=${alias}
        coam.Update Software  sw_package=${${sw_update_type}_SW_build}  should_activate=True  timeout=${SW Update Timeout}
        ...  connection=${alias}  independent_sw_update_type=All
        Log  BTS ${alias} SW Update to ${sw_update_type} SW build: download finished, waiting for activation reset!  console=True

        ${remote_host_ip}=  Set Variable If
        ...  '${alias}' == 'Master'  None  ${${alias.upper()}}[${alias.upper()}_PC_IP_ADDRESS]
        Run Keyword If  ${reset_number} != 0  Wait For Target To Be Not Reachable TAF
        ...  hostname=${${alias.upper()}}[${alias.upper()}_TECH_IP_ADDRESS]  timeout=${BTS_MAX_WAIT_TIME}
        ...  remote_host=${remote_host_ip}

        Get Current Time  reset_start_time
        Log  BTS ${alias} reset_start_time is: ${time_reset_start_time}  console=True

        Wait For Target To Be Reachable TAF  hostname=${${alias.upper()}}[${alias.upper()}_TECH_IP_ADDRESS]
        ...  timeout=${BTS_MAX_WAIT_TIME}  remote_host=${remote_host_ip}
        Sleep  120s
        Admin Collect IMS file with timestamp  folder_path=${Test Results Dir}/IMS/${alias}  alias=${alias}
        Wait Until Keyword Succeeds  3x  10s  Admin reset and Infomodel reconnect sessions  reset_req=True  alias=${alias}  infomodel_reset=False

        Log  ***** Check both BTS states and alarms after BTS ${alias} SW Update *****  console=True
        Check both BTS states and alarms after SW Update

        Run Keyword If  ${BTS_SCF_VALIDATION}  Check BTS SCF Validation On Demand  alias=${alias}
    END

Recover initial feature settings
    Log  =========================================  console=True
    Log  Recover initial settings feature settings  console=True
    Log  =========================================  console=True

    FOR  ${RM_sn}  IN  @{shared_RM_sn_list}
        ${RM_BTS_alias_list}=  Get From Dictionary  ${RM_sn_BTS_alias_dict}  ${RM_sn}
        Recover initial actIndSwUpgradeForSharedRU parameter value  ${RM_sn}  ${RM_BTS_alias_list}
    END
    FOR  ${item}  IN  @{alias_list}
        Log  Recover initial value for sequentialRuSwUpgrade parameter on BTS ${item}  console=True
        ${initial_sequentialRuSwUpgrade_value}=  Get From Dictionary  ${initial_BTS_sequentialRuSwUpgrade_dict}  ${item}
        Set sequentialRuSwUpgrade parameter value  ${initial_sequentialRuSwUpgrade_value}  ${item}
    END
    FOR  ${item}  IN  @{alias_list}
        Log  Recover initial value for actValidationOnUpgrade parameter on BTS ${item}  console=True
        ${initial_actValidationOnUpgrade_value}=  Get From Dictionary  ${initial_BTS_actValidationOnUpgrade_dict}  ${item}
        Set actValidationOnUpgrade parameter value  ${initial_actValidationOnUpgrade_value}  ${item}
    END
    FOR  ${RM_sn}  IN  @{FID23_RM_SN_LIST}
        ${RM_BTS_alias_list}=  Get From Dictionary  ${RM_sn_BTS_alias_dict}  ${RM_sn}
        Recover initial disableSWUpdate parameter value  ${RM_sn}  ${RM_BTS_alias_list}
    END

Recover initial actIndSwUpgradeForSharedRU parameter value
    [Arguments]    ${RM_sn}  ${RM_BTS_alias_list}

    ${initial_RM_id_actIndSwUpgradeForSharedRU_dict}=  Get From Dictionary  ${initial_RM_sn_RM_id_actIndSwUpgradeForSharedRU_dict}  ${RM_sn}
    Log  Recover initial values for actIndSwUpgradeForSharedRU parameter on shared RM with SN ${RM_sn}  console=True

    FOR  ${item}  IN  @{RM_BTS_alias_list}
        ${RM_id}=  Get From Dictionary  ${${item}_RM_sn_id_dict}  ${RM_sn}
        ${initial_actIndSwUpgradeForSharedRU_value}=  Get From Dictionary  ${initial_RM_id_actIndSwUpgradeForSharedRU_dict}  ${RM_id}
        Set actIndSwUpgradeForSharedRU parameter value  ${RM_id}  ${initial_actIndSwUpgradeForSharedRU_value}  ${item}
    END

Recover initial disableSWUpdate parameter value
    [Arguments]    ${RM_sn}  ${RM_BTS_alias_list}

    ${initial_RM_id_disableSWUpdate_dict}=  Get From Dictionary  ${initial_RM_sn_RM_id_disableSWUpdate_dict}  ${RM_sn}
    Log  Recover initial values for disableSWUpdate parameter on RM with SN ${RM_sn}  console=True

    FOR  ${item}  IN  @{RM_BTS_alias_list}
        ${RM_id}=  Get From Dictionary  ${${item}_RM_sn_id_dict}  ${RM_sn}
        ${initial_disableSWUpdate_value}=  Get From Dictionary  ${initial_RM_id_disableSWUpdate_dict}  ${RM_id}
        Set disableSWUpdate parameter value  ${RM_id}  ${initial_disableSWUpdate_value}  ${item}
    END

Particular Teardown
    Run Keyword If  '${FORCE_CURRENT_SW_DL}' == 'True'
    ...  OperatingSystem.Run  rm -rf ${Target SW dir}
    Recover initial feature settings

TC Setup
    ${tech_preset_list}=  Create List  SBTS  SBTS
    Common Test Setup  preset_techs=${tech_preset_list}  common_sbts=${TRUE}  infomodelSetup=${FALSE}

TC Teardown
    Common Test Teardown