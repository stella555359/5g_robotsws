*** Settings ***
Documentation    TC__SBTS_SBTS__SWM__SW_Fallback
Variables    tc_variables/sbts_sbts__swm__sw_fallback_alarms_definitions.py
Resource    ../../resources/rfs_frame_rfs_soam_taf.robot

*** Variables ***
${REPEAT_COUNTER}          3      # Number of repetitions, default value 3
${BTS_SW_Fallback}         BOTH   # BTS on which SW Fallback functionality will be tested. Possible values (by default BOTH):
                                  # - BOTH: action will be performed on both BTS
                                  # - BTS labelized as BTSx (x is test_pc number in init.py) (ex. BTS1)
${Target SW dir}           /home/ute/btsauto/TARGET_SW_BTS1  # path to directory with target SW zip file
${Target SW name}          None   # N+1 BTS SW name; if not given, the last modified zip file from ${Target SW dir} will be taken
${SW Update Timeout}       3000   # Timeout for SW Update; given in seconds
${FORCE_CURRENT_SW_DL}     False  # Force downlaod current reservation SW build in order to be used for SW Update, in offline running it needs
                                  # variable ENB_BUILD to be defined in argfile.txt
${Remote target SW path}   None   # Path to remote zip file which needs to be downloaded; ex: /SBTS/Trunk/SBTS00_ENB_9999_231030_000010.zip
${RFS_CUSTOM_SHARE_SW_DL}  False  # Flag to enable/disable SW package download from remote location
                                  # - SWs from share-1 can be downloaded locally. Default value is False
${CB015052_CHECK}          False  # Specify if feature CB015052 behavior (FID4220 on BTS secondary controller is raised) should be checked
                                  # (True) or skipped (False). By default False
${tempRadioMasterTriggerTime}  0  # Temporary radio master trigger time on BTS secondary controller, default value 0 (minutes). Taken into
                                  # account only if ${CB015052_CHECK} set on True
${RESTORE_INITIAL_BTS_SW}  False  # Specify if initial BTS SW versions should be restored at the end of the test (True) or not (False).
                                  # By default False
${BTS_MAX_WAIT_TIME}       900    # Maximum time for waiting for BTS to be OnAir; given in seconds
${BTS1_reset_number}              # Expected BTS1 reset behavior after SW Fallback; test will not fail if BTS1 reset number is not as expected
${BTS2_reset_number}              # Expected BTS2 reset behavior after SW Fallback; test will not fail if BTS2 reset number is not as expected
${swFallbackTimer}                # Timer in minutes to start SW fallback; possible values: 30, 60 or 90
${BTS1_EIF_down}                        # EIF down info for BTS1
${BTS1_EIF_pass_down}                   # EIF down password for BTS1,
${BTS1_EIF_up}                          # EIF up info for BTS1
${BTS1_EIF_pass_up}                     # EIF up password for BTS1
${BTS1_EIF_Switch_IpAddress}            # EIF switch IP address for BTS1
${BTS2_EIF_down}                        # EIF down info for BTS2
${BTS2_EIF_pass_down}                   # EIF down password for BTS2
${BTS2_EIF_up}                          # EIF up info for BTS2
${BTS2_EIF_pass_up}                     # EIF up password for BTS2
${BTS2_EIF_Switch_IpAddress}            # EIF switch IP address for BTS2

*** Keywords ***
TC__SBTS_SBTS__SWM__SW_Fallback
    [Documentation]
    ...  [CASE LINK]: https://jiradc.ext.net.nokia.com/browse/TAT-26026
    ...
    ...  *****************
    ...  Basic information
    ...  *****************
    ...  SBTS-SBTS test case for BTS SW Fallback.
    ...  The main steps performed for the test are:
    ...  - check initial state and alarms for both BTS
    ...  - get target SW for BTS SW Update
    ...  - get all BTS info for configured items: RMOD sharing info, controller role for shared RMOD, TRM feature settings
    ...  - check and set swFallbackTimer parameter value on both BTS
    ...  - test SW Fallback functionality on BTS checking states and alarms:
    ...    - get initial SW versions from BTS partitions
    ...    - perform BTS SW Update with download check and activation on BTS
    ...    - perform LMP and EIF down operation on BTS
    ...    - perform LMP and EIF up operation on BTS
    ...    - get after LMP and EIF up operation SW versions from BTS partitions
    ...    - check BTS alarms after LMP and EIF up operation on BTS: fault 4085 is expected
    ...    - check BTS secondary controller fault 4220 from IMS if CB015052_CHECK is set to True
    ...    - check BTS reset behavior after LMP and EIF up operation based on IMS info
    ...    - perform SW Update to N+1 SW version on BTS
    ...  - check final state and alarms for both BTS
    ...
    ...  ******************
    ...  History of changes
    ...  ******************
    ...  - 31.10.2023 - https://jiradc.ext.net.nokia.com/browse/TAT-26026 - [5G][CB009400] RFS_SBTS_SBTS_SWFallback_with_WebEM
    ...  - 08.07.2024 - https://jiradc.ext.net.nokia.com/browse/TAT-27696 - [5G] [Infomodel] Disable Infomodel in SW Update Test-Cases
    ...  - 13.12.2024 - https://jiradc.ext.net.nokia.com/browse/TAT-28528 - Fixes for RFS_SBTS_SBTS_SWFallback_with_WebEM
    ...  - 10.02.2025 - https://jiradc.ext.net.nokia.com/browse/TAT-28681 - [5G] Replace LMP unplug LABOPS scripts with VM scripts for the
    ...  SW fallback robots
    ...  - 10.11.2025 - https://jiradc.ext.net.nokia.com/browse/TAT-30098 - FID7300 and FID7319 to be ignored in SBTS_SBTS_SWFallback_with_WebEM
    ...  - 10.11.2025 - https://jiradc.ext.net.nokia.com/browse/TAT-29633 - [CB015052] 4220 Alarm Filtering during SW activation - update
    ...  SBTS_SBTS__SWM__SW_Fallback.robot to check FID 4220 (no alarm filtering) - EST w46.5
    ...  - 28.11.2025 - https://jiradc.ext.net.nokia.com/browse/TAT-30215 - [CB015052]Add parameter in SW Fallback
    ...  - 12.12.2025 - https://jiradc.ext.net.nokia.com/browse/TAT-30321 - Adapt SBTS_SBTS__SWM__SW_Fallback & Fallback_with_Cold_Reset in case
    ...  of GPS receiver alarm: firmware upgrade ongoing
    ...  - 15.12.2025 - https://jiradc.ext.net.nokia.com/browse/TAT-30247 - Adapt SBTS_SBTS__SWM__SW_Fallback & Fallback_with_Cold_Reset for
    ...  multiple runs

    Set Tags    CA-SWM    OWNER-lorena.borobar@nokia.com@nokia.com    AUTHOR-anca.tatar@nokia.com    PHASE-QT    SW-SBTS24R1

    TC Preconditions
    Step 1: Check initial both BTS state
    Step 2: Check initial both BTS alarms
    Step 3: Get Target SW for BTS SW Update
    Step 4: Get all BTS info for configured items
    Step 5: Check and set swFallbackTimer parameter value on BTS
    FOR  ${INDEX}  IN RANGE  1  ${REPEAT_COUNTER}+1
        Log  ==============================================================================  console=True
        Log  Start Cycle ${INDEX} of ${REPEAT_COUNTER}  console=True
        Log  ==============================================================================  console=True
        Step 6: Test SW Fallback functionality on BTS for iteration ${INDEX}
        Step 7: Check final both BTS state
        Step 8: Check final both BTS alarms
        Step 9: Check final number and state of Cells and RMs
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
    ${swFallbackTimer_values_list}=  Create List  30  60  90

    Run Keyword If  '${BTS_SW_Fallback}' != 'BOTH'  Check BTS list
    Log  ====================================================  console=True
    Log  BTS label selected for BTS SW Fallback: ${BTS_label_list}  console=True
    Log  BTS alias selected for BTS SW Fallback: ${BTS_alias_list}  console=True
    Log  ====================================================  console=True

    Run Keyword If  '${swFallbackTimer}' not in ${swFallbackTimer_values_list}  Run Keywords
    ...  Log  Please select a proper value for test argument \${swFallbackTimer}.  level=ERROR
    ...  AND  Fail  Improper value for argument!

    Run Keyword If  '${BTS1_reset_number}' == ''  Run Keywords
    ...  Log  Please select a proper value for test argument \${BTS1_reset_number}.  level=ERROR
    ...  AND  Fail  Improper value for argument!

    Run Keyword If  '${BTS2_reset_number}' == ''  Run Keywords
    ...  Log  Please select a proper value for test argument \${BTS2_reset_number}.  level=ERROR
    ...  AND  Fail  Improper value for argument!

    Run Keyword If  '${CB015052_CHECK}' not in ['True', 'False']  Run Keywords
    ...  Log  Please select a proper value for test argument \${CB015052_CHECK}. Possible values: True or False.  level=ERROR
    ...  AND  Fail  Improper value for argument!

Check BTS list
    ${BTS_SW_Fallback_strip}=  Replace String  ${BTS_SW_Fallback}  ${SPACE}  ${EMPTY}
    ${BTS_SW_Fallback}=  Split String  ${BTS_SW_Fallback_strip}  ,
    ${BTS_check}=  Set Variable  True
    ${BTS_invalid_label_list}=  Create List
    ${BTS_request_label_list}=  Create List
    ${BTS_request_alias_list}=  Create List

    FOR  ${item}  IN  @{BTS_SW_Fallback}
        ${BTS_check}=  Set Variable If  '${item}' not in ${BTS_label_list}  False  ${BTS_check}
        Run Keyword If  '${item}' not in ${BTS_label_list}
        ...  Append To List  ${BTS_invalid_label_list}  ${item}
        ...  ELSE
        ...  Append To List  ${BTS_request_label_list}  ${item}
    END

    Run Keyword If  '${BTS_check}' == 'False'  Run Keywords
    ...  Log Long String  Following selected BTS are not valid: ${BTS_invalid_label_list}. Please select values for test argument
    ...  \${BTS_SW_Fallback} from configured BTS: ${BTS_label_list} or let default value: BOTH  console=True
    ...  AND  Fail  Improper value for argument!

    FOR  ${item}  IN  @{BTS_request_label_list}
        ${BTS_request_alias}=  Get From Dictionary  ${BTS_label_alias_dict}  ${item}
        Append To List  ${BTS_request_alias_list}  ${BTS_request_alias}
    END

    Set Test Variable  ${BTS_label_list}  ${BTS_request_label_list}
    Set Test Variable  ${BTS_alias_list}  ${BTS_request_alias_list}

Step ${index}: Check ${when} both BTS state
    [Documentation]
    ...  SBTS state is checked according to Admin for BTS and each configured RAT

    [Timeout]  15 min
    Log  Step ${index}: Check ${when} both BTS state  console=True
    FOR  ${alias}  IN  @{alias_list}
        Log  ***** Check ${when} BTS ${alias} state *****  console=True
        Admin Check BTS RAT Procedural State  alias=${alias}  timeout=600
        Admin Check BTS Procedural and Blocking states  ${OnAir_}  ${Unblocked_}  alias=${alias}
        Log  BTS ${alias} site - proceduralState: OnAir, blockingState: Unblocked  console=True
    END

Step ${index}: Check ${when} both BTS alarms
    [Documentation]
    ...  SBTS alarms are compared with values from expected, ignored and critical alarms lists. SBTS alarms are get
    ...  from admin

    [Timeout]  15 min
    Log  Step ${index}: Check ${when} both BTS alarms  console=True
    FOR  ${alias}  IN  @{alias_list}
        Log  ***** Check ${when} BTS ${alias} alarms *****  console=True
        Get and Check Alarms SOAM  alias=${alias}  expected_alarms=@{EMPTY}  ignored_alarms=${test_alarms_list['${alias.upper()}_IGNORED_ALARMS']}
        ...  critical_alarms=${test_alarms_list['${alias.upper()}_CRITICAL_ALARMS']}
        Log  BTS ${alias} site - expected, ignored and critical alarms checked  console=True
    END

Step ${index}: Get Target SW for BTS SW Update
    Log  Step ${index}: Get Target SW for BTS SW Update  console=True

    Run Keyword If  '${FORCE_CURRENT_SW_DL}' == 'True'  Run Keywords
    ...  Download And Set Current SW for SWDL  Target_SW_dir=${Target SW dir}
    ...  AND  Check if SW version already exists on BTS
    ...  AND  Set Test Variable  ${Target SW name}  ${Target Package Name}
    ...  AND  Return From Keyword

    ${Target SW tmp}=  Run Keyword If  not '${RFS_CUSTOM_SHARE_SW_DL}' == 'True'
    ...  Get SW file for SWDL  ${Target SW dir}  ${Target SW name}
    Run Keyword If  '${RFS_CUSTOM_SHARE_SW_DL}' == 'True'  Run Keywords
    ...  Log  SW package will be downloaded from remote server  console=True
    ...  AND  SFTP Download SW from remote server and rename  ${Remote target SW path}  Master
    ...  ELSE  Rename Software Package  ${Target SW tmp}
    Set Test Variable  ${Target SW}
    Log  Target SW for BTS SW Update: ${Target SW}  console=True
    Check if SW version already exists on BTS
    ${target_sw_path}  ${target_sw_file}=  Split Path  ${Target SW}
    ${target_sw_name}  ${ext}=  Split Extension  ${target_sw_file}
    ${qc_target_sw}=  String.Convert To Upper Case  ${target_sw_name}
    Set Test Variable  ${Target SW name}
    FOR  ${alias}  IN  @{BTS_alias_list}
        Set Qc Parameter  qc_tc_swbuild  ${qc_target_sw}; ${QC ${alias} Active SW}
    END

Step ${index}: Get all BTS info for configured items
    Log  Step ${index}: Get all BTS info for configured items  console=True

    ${BTS_alias_RMOD_sn_dict}  ${RMOD_sn_BTS_alias_dict}  ${shared_RMOD_sn_list}  ${dedicated_RMOD_sn_list}=  Get all BTS RMOD sharing info
    Set Test Variable  ${shared_RMOD_sn_list}

    ${all_BTS_controller_role_RMOD_sn_dict}=  Get all BTS controller role for configured RMOD from SCF
    Set Test Variable  ${all_BTS_controller_role_RMOD_sn_dict}

    Get all BTS controller role for shared modules

    Get all BTS shared RMOD list that are connected in BBMOD from primary core subrack

    Run Keyword If  '${CB015052_CHECK}' == 'True'  Get and Set TRM feature settings

Step ${index}: Check and set swFallbackTimer parameter value on BTS
    [Documentation]
    ...  Check and set swFallbackTimer parameter value on BTS

    Log  Step ${index}: Check and set swFallbackTimer parameter value on BTS  console=True

    FOR  ${alias}  IN  @{BTS_alias_list}
        ${BTS_label}=  Get From Dictionary  ${BTS_alias_label_dict}  ${alias}
        Log  Check swFallbackTimer parameter value on ${BTS_label}:  console=True
        ${swFallbackTimer_value}=  Get swFallbackTimer parameter value  ${alias}
        Set Test Variable  ${${alias}_swFallbackTimer_value_initial}  ${swFallbackTimer_value}
        Run Keyword If  '${swFallbackTimer_value}' == 'None'  Run Keywords
        ...  Log  Parameter swFallbackTimer value not set on ${BTS_label}. Need to set parameter swFallbackTimer = ${swFallbackTimer}.  console=True
        ...  AND  Set swFallbackTimer parameter value  ${swFallbackTimer}  update  ${alias}
        ...  ELSE IF  '${swFallbackTimer_value}' == '${swFallbackTimer}'
        ...  Log  Parameter swFallbackTimer = ${swFallbackTimer} already set on ${BTS_label}, no action needed!  console=True
        ...  ELSE  Run Keywords
        ...  Log Long String  Parameter swFallbackTimer = ${swFallbackTimer_value} on ${BTS_label}, need to set parameter
        ...  swFallbackTimer = ${swFallbackTimer}  console=True
        ...  AND  Set swFallbackTimer parameter value  ${swFallbackTimer}  update  ${alias}
    END

Step ${index}: Test SW Fallback functionality on BTS for iteration ${CYCLE}
    [Documentation]
    ...  Test BTS SW Fallback functionality on BTS checking states and alarms

    Log  Step ${index}: Test SW Fallback functionality on BTS for iteration ${CYCLE}  console=True

    FOR  ${alias}  IN  @{BTS_alias_list}
        ${BTS_label}=  Get From Dictionary  ${BTS_alias_label_dict}  ${alias}
        ${alias_list_temp}=  Get Dictionary Keys  ${BTS_alias_label_dict}  False
        ${BTS_label_list_temp}=  Get Dictionary Values  ${BTS_alias_label_dict}  False
        Remove Values From List  ${alias_list_temp}  ${alias}
        Remove Values From List  ${BTS_label_list_temp}  ${BTS_label}
        ${peer_alias}=  Get From List  ${alias_list_temp}  0
        ${peer_BTS_label}=  Get From List  ${BTS_label_list_temp}  0
        Set Test Variable  ${alias}
        Set Test Variable  ${peer_alias}
        Set Test Variable  ${BTS_label}
        Set Test Variable  ${peer_BTS_label}
        Test BTS SW Fallback functionality
    END

    Return From Keyword If  '${RESTORE_INITIAL_BTS_SW}' == 'False' and (${REPEAT_COUNTER} == 1 or ${CYCLE} == ${REPEAT_COUNTER})

    FOR  ${alias}  IN  @{BTS_alias_list}
        ${BTS_label}=  Get From Dictionary  ${BTS_alias_label_dict}  ${alias}
        Set Test Variable  ${alias}
        Set Test Variable  ${BTS_label}
        Log  ==================================================================================================  console=True
        Log  ***** Perform BTS SW Rollback and Synchronize Active and Passive SW versions on ${BTS_label} *****  console=True
        Log  ==================================================================================================  console=True
        Perform BTS SW Rollback operation
        Synchronize active and pasive SW versions
    END

Get all BTS controller role for shared modules

    ${BTS_primary_controller_shared_RMOD_list}=  Create List
    ${BTS_secondary_controller_shared_RMOD_list}=  Create List

    FOR  ${alias}  IN  @{alias_list}

        ${BTS_controller_role_RMOD_sn_dict}=  Get From Dictionary  ${all_BTS_controller_role_RMOD_sn_dict}  ${alias}
        ${BTS_primary_controller_RMOD_sn_list}=  Get From Dictionary  ${BTS_controller_role_RMOD_sn_dict}  BTS_primary_controller_RMOD_sn_list
        ${BTS_secondary_controller_RMOD_sn_list}=  Get From Dictionary  ${BTS_controller_role_RMOD_sn_dict}  BTS_secondary_controller_RMOD_sn_list
        ${BTS_primary_controller_shared_RMOD_sn_list}=  Get BTS info for shared modules  ${BTS_primary_controller_RMOD_sn_list}
        ${BTS_primary_controller_shared_RMOD_sn_count}=  Get Length  ${BTS_primary_controller_shared_RMOD_sn_list}
        Run Keyword If  ${BTS_primary_controller_shared_RMOD_sn_count} > 0  Append To List  ${BTS_primary_controller_shared_RMOD_list}  ${alias}
        ${BTS_secondary_controller_shared_RMOD_sn_list}=  Get BTS info for shared modules  ${BTS_secondary_controller_RMOD_sn_list}
        ${BTS_secondary_controller_shared_RMOD_sn_count}=  Get Length  ${BTS_secondary_controller_shared_RMOD_sn_list}
        Run Keyword If  ${BTS_secondary_controller_shared_RMOD_sn_count} > 0  Append To List  ${BTS_secondary_controller_shared_RMOD_list}  ${alias}

        ${BTS_primary_controller_shared_RMOD_id_list}=  Create List

        FOR  ${RMOD_sn}  IN  @{BTS_primary_controller_shared_RMOD_sn_list}

            ${RMOD_id}=  Get From Dictionary  ${${alias}_RMOD_sn_id_dict}  ${RMOD_sn}
            Append To List  ${BTS_primary_controller_shared_RMOD_id_list}  ${RMOD_id}

        END

        Set Test Variable  ${${alias}_BTS_primary_controller_shared_RMOD_id_list}  ${BTS_primary_controller_shared_RMOD_id_list}

    END

    Set Test Variable  ${BTS_primary_controller_shared_RMOD_list}
    Set Test Variable  ${BTS_secondary_controller_shared_RMOD_list}

Get BTS info for shared modules
    [Arguments]  ${RMOD_sn_list}

    ${shared_RM_sn_list}=  Create List

    FOR  ${RMOD_sn}  IN  @{RMOD_sn_list}

        Run Keyword If  '${RMOD_sn}' in ${shared_RMOD_sn_list}  Append To List  ${shared_RM_sn_list}  ${RMOD_sn}

    END

    [Return]  ${shared_RM_sn_list}

Get all BTS shared RMOD list that are connected in BBMOD from primary core subrack

    FOR  ${alias}  IN  @{alias_list}

        ${all_BBMOD_connected_in_primary_core}=  Create List
        ${all_shared_RMOD_connected_in_BBMOD_from_primary_core}=  Create List

        ${BBMOD_list}=  Get Ids For All  class_name=BBMOD  connection=${alias}
        Sort List  ${BBMOD_list}

        FOR  ${BBMOD_id}  IN  @{BBMOD_list}

            ${BBMOD_SMOD_info_dict}=  Get BBMOD and SMOD position in subrack  ${BBMOD_id}  ${alias}
            ${BBMOD_verticalPosition}=  Get From Dictionary  ${BBMOD_SMOD_info_dict}  BBMOD_verticalPosition
            ${BBMOD_verticalPosition}=  Evaluate  ${BBMOD_verticalPosition} - 1
            ${SMOD_activeRole}=  Get From Dictionary  ${BBMOD_SMOD_info_dict}  SMOD_activeRole

            Run Keyword If  '${SMOD_activeRole}' == 'Primary' or '${SMOD_activeRole}' == 'None'
            ...  Append To List  ${all_BBMOD_connected_in_primary_core}  ${BBMOD_id}

        END

        FOR  ${BBMOD_id}  IN  @{all_BBMOD_connected_in_primary_core}

            ${BBMOD_RMOD_list}=  Get RMOD Mapping By BBMOD Id  ${BBMOD_id}  ${alias}
            ${BBMOD_RMOD_list}=  Remove Duplicates  ${BBMOD_RMOD_list}

            Append To List  ${all_shared_RMOD_connected_in_BBMOD_from_primary_core}  @{BBMOD_RMOD_list}

        END

        ${all_shared_RMOD_connected_in_BBMOD_from_primary_core}=  Remove Duplicates  ${all_shared_RMOD_connected_in_BBMOD_from_primary_core}
        Set Test Variable  ${${alias}_all_shared_RMOD_connected_in_BBMOD_from_primary_core}  ${all_shared_RMOD_connected_in_BBMOD_from_primary_core}

    END

Get RMOD Mapping By BBMOD Id
    [Arguments]   ${BBMOD_id}  ${alias}
    ${BBMOD_RMOD_list}=  Create List
    ${CABLINK_list}=  Get Parameters For All  CABLINK  alias=${alias}

    FOR  ${item}  IN  @{CABLINK_list}

        ${secondEndpointDN_RMOD_R}=  Run Keyword And Return Status  Should Contain  ${item.secondEndpointDN}  RMOD_R
        Run Keyword If  '${item.firstEndpointDN}' == '${BBMOD_id}' and ${secondEndpointDN_RMOD_R}
        ...  Append To List  ${BBMOD_RMOD_list}  ${item.secondEndpointDN}

    END
    Sort List  ${BBMOD_RMOD_list}

    [Return]  ${BBMOD_RMOD_list}

Get and Set TRM feature settings

    FOR  ${alias}  IN  @{BTS_secondary_controller_shared_RMOD_list}

        Log  Get and Set TRM feature settings on BTS ${alias} and set them accordingly if needed  console=True

        ${BTS_TRM_feature_dict_initial}=  Get BTS TRM feature parameters  BTS_SCF_path_file=${${alias.lower()}_scf_initial}  alias=${alias}
        Set Test Variable  ${${alias}_TRM_feature_dict_initial}  ${BTS_TRM_feature_dict_initial}
        Set classical BTS TRM feature parameter  actTempRadioMaster  true  ${alias}
        Set classical BTS TRM feature parameter  tempRadioMasterTriggerTime  ${tempRadioMasterTriggerTime}  ${alias}

        Log  Test will be performed with TRM feature settings on BTS ${alias}: tempRadioMasterTriggerTime: ${tempRadioMasterTriggerTime}  console=True

    END

Test BTS SW Fallback functionality
    [Documentation]
    ...  Test BTS SW Fallback functionality on BTS checking states and alarms

    Log  ======================================================  console=True
    Log  ***** Test SW Fallback functionality on ${BTS_label} *****  console=True
    Log  ======================================================  console=True

    Log  ***** Get initial SW versions from ${BTS_label} partitions *****  console=True
    Get SW versions from BTS partitions  initial

    Log  ***** Perform BTS SW Update with download check and activation on ${BTS_label} *****  console=True
    BTS SW Update with download check and activation

    Log  ***** Perform LMP and EIF down operation on ${BTS_label} *****  console=True
    Perform LMP and EIF operation on BTS  down

    Log  ***** Perform LMP and EIF up operation on ${BTS_label} *****  console=True
    Perform LMP and EIF operation on BTS  up

    Log  ***** Get after LMP and EIF up operation SW versions from ${BTS_label} partitions *****  console=True
    Get SW versions from BTS partitions  after

    Log  ***** Check ${BTS_label} alarms after LMP and EIF up operation on ${BTS_label} *****  console=True
    Check BTS alarms after LMP and EIF up operation

    Run Keyword If  '${CB015052_CHECK}' == 'True' and '${alias}' in ${BTS_primary_controller_shared_RMOD_list}  Run Keywords
    ...  Calculate peer BTS 4220 possible alarm impact
    ...  AND  Run Keyword If  ${fid_4220_alarm_count} > 0  Check peer BTS alarms from IMS

    Log  ***** Check ${BTS_label} reset behavior after LMP and EIF up operation on ${BTS_label} based on IMS info *****  console=True
    Check BTS reset behavior after LMP and EIF up operation

    Log  ***** Perform SW Update to N+1 SW version on ${BTS_label} *****  console=True
    Activate N+1 SW version on BTS  after

Step ${index}: Check final number and state of Cells and RMs
    [Documentation]
    ...  Cells state is checked according to operationalState attribute
    ...  Check if number of configured cells and radio modules in SCF are properly mapping on BTS running view.
    ...  Also check RMs operationalState

    [Timeout]  30 min
    Log  Step ${index}: Check final number and state of Cells and RMs  console=True
    RFS Test Case Final Checks

Check if SW version already exists on BTS
    FOR  ${alias}  IN  @{BTS_alias_list}
        Check if SW already exists on BTS  ${Target SW}  ${${alias} active SW}  ${${alias} passive SW}
    END

Check planned software build name
    [Arguments]  ${Target SW name}  ${alias}
    Log  Get downloaded SW build name  console=True
    ${BTS_SW_Info}=   Get software info  alias=${alias}
    ${Planned_SW}=  Get from dictionary  ${BTS_SW_Info}  Planned SW version
    Run Keyword If  '${Planned_SW}' == '${Target SW name}'
    ...  Log  Planned SW build is the same as ${Target SW name}. Download build was successful!  console=True
    ...  ELSE  Fail  Download SW build action without activation failed!

Get SW versions from BTS partitions
    [Arguments]  ${when}

    ${remote_host_ip}=  Set Variable If  '${alias}' == 'Master'  None  ${${alias.upper()}}[${alias.upper()}_PC_IP_ADDRESS]
    Run Keyword If  '${when}' == 'after'
    ...  Wait For Target To Be Reachable TAF  hostname=${${alias.upper()}}[${alias.upper()}_TECH_IP_ADDRESS]  timeout=${BTS_MAX_WAIT_TIME}
    ...  remote_host=${remote_host_ip}

    Admin Get BTS SW Version  ${alias}
    Set Test Variable  ${${alias} ${when} active SW}  ${${alias} active SW}

    Run Keyword If  '${when}' == 'after'
    ...  Run Keyword If  '${${alias} initial active SW}' == '${${alias} after active SW}'
    ...  Log  Active SW build on ${BTS_label}, as expected!
    ...  ELSE IF  '${when}' == 'after'
    ...  Fail  Active SW build on ${BTS_label}, not as expected!

BTS SW Update with download check and activation
    Get Current Date UTC info  start
    Perform Download N+1 SW on BTS
    Activate N+1 SW version on BTS  initial

Perform Download N+1 SW on BTS
    [Documentation]
    ...  Perform Download N+1 SW version on BTS

    Log  Start Download build ${Target SW name} without activation on ${BTS_label}  console=True

    ${new_alias}=  Set Variable  downloadSession
    Start new ADMIN instance  alias=${alias}  new_alias=${new_alias}  connection_type=${connection_type_${alias}}

    Adding alarms to ignored list  ${test_alarms_list['${alias.upper()}_IGNORED_ALARMS']}  connection_alias=${alias}
    ${download_thread}=  coam.Run Keyword In Background  Update Software  sw_package=${Target SW}  should_activate=False
    ...  timeout=${SW Update Timeout}  connection=downloadSession

    ${alarms_info_response}=  Create List
    ${alarms_info_result}  ${alarms_info_response}=  Wait Until Keyword Succeeds  90 min  10 s  Check alarms while thread is running
    ...  ${download_thread}  ${alias}  ${alarms_info_response}
    Collect Keyword Result  ${download_thread}  timeout=${SW Update Timeout}

    Run Keyword And Continue On Failure  Run Keyword If  '${alarms_info_result}' == 'FAIL'
    ...  Fail  Unexpected alarms occurred during ${BTS_label} Software Download -- ${alarms_info_response}
    ...  ELSE  Log  No unexpected alarms found during ${BTS_label} Software Download  console=True

    Check planned software build name  Target SW name=${Target SW name}  alias=${alias}

    [Teardown]  Teardown Admin  alias=${new_alias}

Activate N+1 SW version on BTS
    [Documentation]
    ...  Activate N+1 SW version on BTS
    [Arguments]  ${when}

    Log  Perform SW build ${Target SW name} activation on ${BTS_label}  console=True
    coam.Update Software  sw_package=${Target SW}  should_activate=True  timeout=${SW Update Timeout}  connection=${alias}
    Log  ${BTS_label} SW Update: download finished, waiting for activation reset!  console=True

    ${remote_host_ip}=  Set Variable If  '${alias}' == 'Master'  None  ${${alias.upper()}}[${alias.upper()}_PC_IP_ADDRESS]
    Wait For Target To Be Not Reachable TAF  hostname=${${alias.upper()}}[${alias.upper()}_TECH_IP_ADDRESS]  timeout=${BTS_MAX_WAIT_TIME}
    ...  remote_host=${remote_host_ip}

    Get Current Time  bts_initial
    Log  ${BTS_label} reset_start_time is: ${time_bts_initial}  console=True

    Run Keyword If  '${when}' == 'after'  Run Keywords
    ...  Log  ***** Check ${BTS_label} state and alarms after final ${BTS_label} SW Update *****  console=True
    ...  AND  Check final BTS state and alarms  fid_4420_check=True

Get RESET timestamp info
    [Arguments]  ${when}
    Get Current Date UTC info  ${when}

Perform LMP and EIF operation on BTS
    [Documentation]
    ...  Perform LMP and EIF down or up operation on BTS
    [Arguments]  ${operation}

    ${EIF_info}=  Set Variable If
    ...  '${operation}' == 'down' and '${BTS_label}' == 'BTS1'  ${BTS1_EIF_down}
    ...  '${operation}' == 'up' and '${BTS_label}' == 'BTS1'  ${BTS1_EIF_up}
    ...  '${operation}' == 'down' and '${BTS_label}' == 'BTS2'  ${BTS2_EIF_down}
    ...  '${operation}' == 'up' and '${BTS_label}' == 'BTS2'  ${BTS2_EIF_up}
    ${EIF_pass}=  Set Variable If
    ...  '${operation}' == 'down' and '${BTS_label}' == 'BTS1'  ${BTS1_EIF_pass_down}
    ...  '${operation}' == 'up' and '${BTS_label}' == 'BTS1'  ${BTS1_EIF_pass_up}
    ...  '${operation}' == 'down' and '${BTS_label}' == 'BTS2'  ${BTS2_EIF_pass_down}
    ...  '${operation}' == 'up' and '${BTS_label}' == 'BTS2'  ${BTS2_EIF_pass_up}
    ${EIF_ip}=  Set Variable If
    ...  '${BTS_label}' == 'BTS1'  ${BTS1_EIF_Switch_IpAddress}  ${BTS2_EIF_Switch_IpAddress}

    ${BTS_secondary_core}=  Run Keyword And Return Status
    ...  Dictionary Should Contain Key  ${${alias.upper()}_EXT}  ${alias.upper()}_EXT_PC_IP_ADDRESS
    Set Test Variable  ${${alias}_BTS_secondary_core}  ${BTS_secondary_core}

    Perform EIF operation on BTS  ${operation}  ${EIF_info}  ${EIF_pass}  ${EIF_ip}
    Perform LMP operation on BTS  ${operation}  primary
    Run Keyword If  '${BTS_secondary_core}' == 'True'
    ...  Perform LMP operation on BTS  ${operation}  secondary

    Run Keyword If  '${operation}' == 'up'  Run Keywords
    ...  Log  LMP and EIF ${operation} operation on ${BTS_label} ended, wait 20 min for BTS reactivity.  console=True
    ...  AND  Sleep  20m
    ...  AND  Return From Keyword

    Log  LMP and EIF ${operation} operation on ${BTS_label} ended, wait swFallbackTimer:${swFallbackTimer} min.  console=True
    Sleep  ${swFallbackTimer}m

    Get RESET timestamp info  fallback_reset

    Log  Wait additional 10 min for ${BTS_label} fallback reset.  console=True
    Sleep  10m

Perform EIF operation on BTS
    [Arguments]  ${operation}  ${info}  ${pass}  ${ip}

    ${command}=  Set Variable  sudo sshpass -p ${pass} ssh -tt ${info}@${ip}
    Log  Perform EIF ${operation} operation on ${BTS_label} by following command:\n ${command}  console=True
    ${output}=  Run Process  ${command}  stderr=STDOUT  shell=True
    ${status}=  Run Keyword And Return Status  Should Be Equal As Integers  ${output.rc}  0
    ${status1}=  Run Keyword And Return Status  Should Be Equal As Integers  ${output.rc}  255
    Run Keyword If  '${status}' == 'False'
    ...  Run Keyword If  '${status1}' == 'False'  Run Keywords
    ...  Log Long String  EIF ${operation} operation on ${BTS_label} could not be performed! Please verify if
    ...  ${info} command is correct!  lever=ERROR
    ...  AND
    ...  Fail  EIF ${operation} operation on ${BTS_label} could not be performed! Please verify if ${info} command is correct!
    Log  EIF ${operation} operation on ${BTS_label} ended!  console=True

Perform LMP operation on BTS
    [Arguments]  ${operation}  ${BTS_core}

    ${command}=  Run Keyword If  '${operation}' == 'down'
    ...  Create Long String
    ...  sudo iptables -F;
    ...  sudo iptables -A INPUT -i eth1 -p udp -m multiport --dports 51000,51001,51003,50011 -j ACCEPT;
    ...  sudo iptables -A INPUT -i eth1 -j DROP;
    ...  sudo iptables -A FORWARD -i eth1 -p udp -m multiport --dports 51000,51001,51003,50011 -j ACCEPT;
    ...  sudo iptables -A FORWARD -i eth1 -j DROP
    ...  ELSE IF  '${operation}' == 'up'
    ...  Set Variable  sudo service iptables restart

    Log  Perform LMP ${operation} operation on ${BTS_label} ${BTS_core} core by following command:\n ${command}  console=True

    Run Keyword if  '${alias}' == 'Master' and '${BTS_core}' == 'primary'
    ...  Execute Local Command  command=${command}
    ...  ELSE IF  '${alias}' != 'Master' and '${BTS_core}' == 'primary'
    ...  Execute Remote Command  command=${command}  index_or_alias=remote  host_ip=${${alias.upper()}}[${alias.upper()}_PC_IP_ADDRESS]
    ...  ssh_port=${${alias.upper()}}[${alias.upper()}_PC_SSH_PORT]  ssh_username=${${alias.upper()}}[${alias.upper()}_PC_SSH_USERNAME]
    ...  ssh_password=${${alias.upper()}}[${alias.upper()}_PC_SSH_PASSWORD]
    ...  ELSE IF  '${BTS_core}' == 'secondary'
    ...  Execute Remote Command  command=${command}  index_or_alias=remote  host_ip=${${alias.upper()}_EXT}[${alias.upper()}_EXT_PC_IP_ADDRESS]
    ...  ssh_port=${${alias.upper()}_EXT}[${alias.upper()}_EXT_PC_SSH_PORT]  ssh_username=ute  ssh_password=ute

    Log  LMP ${operation} operation on ${BTS_label} ${BTS_core} core ended!  console=True

Check BTS alarms after LMP and EIF up operation
    ${IGNORED_ALARMS_full}=  Combine Lists  ${test_alarms_list['${alias.upper()}_IGNORED_ALARMS_AFTER_FALLBACK']}
    ...  ${test_alarms_list['${alias.upper()}_IGNORED_ALARMS']}  ${test_alarms_list['${alias.upper()}_IGNORED_ALARMS_4420']}
    ${FID4085_alarm_count}=  Set Variable If  ${${alias}_BTS_secondary_core}  2  1
    ${EXPECTED_ALARMS_4085_full}=  Prepare expected alarms list  ${test_alarms_list['${alias.upper()}_EXPECTED_ALARMS_4085']}  ${FID4085_alarm_count}

    Log  ${BTS_label} "SW fallback (4085)" alarm, expected number: ${FID4085_alarm_count}  console=True
    Get and Check Alarms SOAM  alias=${alias}  expected_alarms=${EXPECTED_ALARMS_4085_full}
    ...  ignored_alarms=${IGNORED_ALARMS_full}  critical_alarms=${test_alarms_list['${alias.upper()}_CRITICAL_ALARMS']}
    Log  ${BTS_label} "SW fallback (4085)" alarm, found number: ${FID4085_alarm_count}, as expected!  console=True
    Log  ${BTS_label} site - expected, ignored and critical alarms checked  console=True

Calculate peer BTS 4220 possible alarm impact

    ${fid_4220_alarm_count}=  Set Variable  0

    FOR  ${RMOD_id}  IN  @{${alias}_all_shared_RMOD_connected_in_BBMOD_from_primary_core}

        ${fid_4220_alarm_count}=  Run Keyword If
            ...  '${RMOD_id}' in ${${alias}_BTS_primary_controller_shared_RMOD_id_list}
            ...  Evaluate  ${fid_4220_alarm_count} + 1
            ...  ELSE  Set Variable  ${fid_4220_alarm_count}

    END

    Set Test Variable  ${fid_4220_alarm_count}

Check peer BTS alarms from IMS

    ${IGNORED_ALARMS_full}=  Combine Lists  ${test_alarms_list['${peer_alias.upper()}_IGNORED_ALARMS_DURING_FALLBACK']}
    ...  ${test_alarms_list['${peer_alias.upper()}_EXPECTED_ALARMS_4220']}  ${test_alarms_list['${peer_alias.upper()}_IGNORED_ALARMS_4420']}

    Log  ***** Check ${peer_BTS_label} alarms from IMS *****  console=True
    Log Long String  Check that ${peer_BTS_label} "Radio slave has taken temporary radio master role (4220)" alarm was raised at least one
    ...  time on ${peer_BTS_label} Secondary Controller shared RMODs during SW Fallback reset on ${BTS_label}

    Get And Check Detailed IMS2 Alarms SOAM  alias=${peer_alias}  start_timestamp=${date_timestamp_fallback_reset_UTC}
    ...  expected_alarms=${test_alarms_list['${peer_alias.upper()}_EXPECTED_ALARMS_4220']}  ignored_alarms=${IGNORED_ALARMS_full}

    Log Long String  ${peer_BTS_label} "Radio slave has taken temporary radio master role (4220)" alarm was raised at least one
    ...  time on ${peer_BTS_label} Secondary Controller shared RMODs during SW Fallback reset on ${BTS_label}, as expected!

Check BTS reset behavior after LMP and EIF up operation
    Get Current Date UTC info  end
    Get and check BTS RESET info from IMS file  expected_reset_number=${${BTS_label}_reset_number}  alias=${alias}  log_level=WARN
    ...  remove_ims_file=False  start_point_timestamp_UTC=${date_timestamp_start_UTC}  end_point_timestamp_UTC=${date_timestamp_end_UTC}

Check final BTS state and alarms
    [Arguments]  ${fid_4420_check}=False

    ${CELL_state_enabled}=  Set Variable  operationalState=Enabled, blockingState=Unblocked
    ${remote_host_ip}=  Set Variable If  '${alias}' == 'Master'  None  ${${alias.upper()}}[${alias.upper()}_PC_IP_ADDRESS]

    Wait For Target To Be Reachable TAF  hostname=${${alias.upper()}}[${alias.upper()}_TECH_IP_ADDRESS]  timeout=${BTS_MAX_WAIT_TIME}
    ...  remote_host=${remote_host_ip}

    Sleep  120s
    Wait Until Keyword Succeeds  3x  10s  Admin reset and Infomodel reconnect sessions  reset_req=True  alias=${alias}  infomodel_reset=False

    Log  Check ${BTS_label} status:  console=True
    Admin Check BTS Procedural and Blocking states  ${OnAir_}  ${Unblocked_}  ${BTS_MAX_WAIT_TIME}  ${alias}
    Log  ${BTS_label} site - proceduralState: OnAir, blockingState: Unblocked  console=True
    Check cells availability status online  ${alias}  ${BTS_MAX_WAIT_TIME}
    Log  All ${BTS_label} cell(s) status:\n - ${CELL_state_enabled}  console=True

    Log  Check ${BTS_label} alarms:  console=True

    Run Keyword If  '${fid_4420_check}' == 'True'  Check if BTS faultId 4420 alarm is active

    Get and Check Alarms SOAM  alias=${alias}  expected_alarms=@{EMPTY}  ignored_alarms=${test_alarms_list['${alias.upper()}_IGNORED_ALARMS']}
    ...  critical_alarms=${test_alarms_list['${alias.upper()}_CRITICAL_ALARMS']}
    Log  ${BTS_label} site - expected, ignored and critical alarms checked  console=True

Check if BTS faultId 4420 alarm is active
    [Documentation]
    ...  Check if BTS faultId 4420 alarm is active and wait for it to be cleared

    ${fid_4420_status}=  Run Keyword And Return Status  Assert Alarm Active  parameters=faultId=4420  timeout=120  connection=${alias}
    Run Keyword If  ${fid_4420_status}
    ...  Log Long String  ${BTS_label} "GPS receiver alarm: firmware upgrade ongoing (4420)" alarm was detected. Wait maximum 25 minutes
    ...  for alarm to be cleared.  console=True
    ...  ELSE  Return From Keyword

    ${fid_4420_status}=  Run Keyword And Return Status  Assert Alarm Inactive  parameters=faultId=4420  timeout=1500  interval=30  connection=${alias}
    Run Keyword If  ${fid_4420_status}
    ...  Log  ${BTS_label} "GPS receiver alarm: firmware upgrade ongoing (4420)" alarm was cleared, as expected!  console=True
    ...  ELSE
    ...  Log  ${BTS_label} "GPS receiver alarm: firmware upgrade ongoing (4420)" alarm was NOT cleared after 25 minutes!  level=WARN

Perform BTS SW Rollback operation
    [Documentation]
    ...  Helper keyword used to perform BTS SW Rollback operation

    Log  Perform ${BTS_label} SW Rollback  console=True
    coam.Rollback Software  connection=${alias}  timeout=${BTS_MAX_WAIT_TIME}

    ${remote_host_ip}=  Set Variable If  '${alias}' == 'Master'  None  ${${alias.upper()}}[${alias.upper()}_PC_IP_ADDRESS]
    Wait For Target To Be Not Reachable TAF  hostname=${${alias.upper()}}[${alias.upper()}_TECH_IP_ADDRESS]  timeout=${BTS_MAX_WAIT_TIME}
    ...  remote_host=${remote_host_ip}

    Check final BTS state and alarms

Synchronize active and pasive SW versions
    [Documentation]
    ...  Helper keyword used to synchronize Active and Passive partition SW

    Sleep  5min  reason=Wait additional 5 min before synchronizing SW versions to ensure that X2 link is available
    Log  Synchronize active and pasive SW versions on ${BTS_label}  console=True
    Admin Synchronizing Active and Passive SW version  alias=${alias}  timeout=600

Recover initial settings for parameter swFallbackTimer
    [Arguments]  ${alias}

    Log  Recover initial settings for parameter swFallbackTimer on BTS ${alias}  console=True
    Run Keyword If  '${${alias}_swFallbackTimer_value_initial}' == '${swFallbackTimer}'  Return From Keyword
    ...  ELSE IF  '${${alias}_swFallbackTimer_value_initial}' == 'None'
    ...  Set swFallbackTimer parameter value  ${swFallbackTimer}  delete  ${alias}
    ...  ELSE
    ...  Set swFallbackTimer parameter value  ${${alias}_swFallbackTimer_value_initial}  update  ${alias}

Recover TRM initial feature settings on BTS
    [Documentation]
    ...  Keyword used to recover TRM initial feature settings on BTS

    FOR  ${alias}  IN  @{BTS_secondary_controller_shared_RMOD_list}

        Log  Recover TRM initial feature settings on BTS ${alias}  console=True
        ${actTempRadioMaster_initial}=  Get From Dictionary  ${${alias}_TRM_feature_dict_initial}  actTempRadioMaster
        ${tempRadioMasterTriggerTime_initial}=  Get From Dictionary  ${${alias}_TRM_feature_dict_initial}  tempRadioMasterTriggerTime
        Set classical BTS TRM feature parameter  actTempRadioMaster  ${actTempRadioMaster_initial}  ${alias}
        Set classical BTS TRM feature parameter  tempRadioMasterTriggerTime  ${tempRadioMasterTriggerTime_initial}  ${alias}

    END

Particular Teardown
    FOR  ${alias}  IN  @{BTS_alias_list}
        Run Keyword And Continue On Failure  Recover initial settings for parameter swFallbackTimer  ${alias}
    END

    Run Keyword If  '${CB015052_CHECK}' == 'True'  Recover TRM initial feature settings on BTS

TC Setup
    ${tech_preset_list}=  Create List  SBTS  SBTS
    Common Test Setup  preset_techs=${tech_preset_list}  common_sbts=${TRUE}  infomodelSetup=${FALSE}  newAlarmsFormat=${TRUE}

TC Teardown
    Common Test Teardown