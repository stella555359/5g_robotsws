*** Settings ***
Documentation    TC__SBTS_SBTS__SWM__SW_Update_Rollback_memory_consumption_CB015315_using_Admin_CLI
Variables    tc_variables/sbts_sbts__swm__sw_update_rollback_memory_consumption_cb015315_using_admin_cli_alarms_definitions.py
Resource    ../../resources/rfs_frame_rfs_soam_taf.robot

*** Variables ***
${REPEAT_COUNTER}              3
${BTS SW Update}               ALL     # Specify on which BTS to perform SW Update operation. Possible values (by default ALL):
                                       # - ALL: SW Update will be performed on all BTS
                                       # - list of selected BTS separated by comma labeled as BTSx (x is test_pc number in init.py) (ex. BTS1, BTS3)
${BTS_SW_Rollback}             ALL     # BTS list on which SW Rollback operation will be performed. Possible values (by default ALL):
                                       # - ALL: action will be performed on all BTS (SW Rollback on each BTS)
                                       # - list of selected BTS separated by comma labelized as BTSx
                                       # (x is test_pc number in init.py) (ex. BTS1, BTS3)
${Target SW name BTS1}  None           # Name of BTS1 SW from local folder / None.
                                       # If no SW name is given, the latest package from the folder will be taken
${Target SW dir BTS1}   /home/ute/btsauto/TARGET_SW_MASTER  # Local folder where BTS1 SW is located / None.
                                       # Default value: /home/ute/TARGET_SW_MASTER
${Target SW name BTS2}  None           # Name of BTS2 SW from local folder / None.
                                       # If no SW name is given, the latest package from the folder will be taken
${Target SW dir BTS2}   /home/ute/btsauto/TARGET_SW_SLAVE   # Local folder where BTS2 SW is located / None.
                                       # Default value: /home/ute/TARGET_SW_SLAVE
${Target SW name BTS3}  None           # Name of BTS3 SW from local folder / None.
                                       # If no SW name is given, the latest package from the folder will be taken
${Target SW dir BTS3}   /home/ute/btsauto/TARGET_SW_SLAVE1  # Local folder where BTS3 SW is located / None.
                                       # Default value: /home/ute/TARGET_SW_SLAVE1
${Target SW name BTS4}  None           # Name of BTS4 SW from local folder / None.
                                       # If no SW name is given, the latest package from the folder will be taken
${Target SW dir BTS4}   /home/ute/btsauto/TARGET_SW_SLAVE2  # Local folder where BTS4 SW is located / None.
                                       # Default value: /home/ute/TARGET_SW_SLAVE2
${Activate SW}                 True    # Activate SW flag; can be True or False
${SW Update Timeout}           3000    # Timeout for SW Update; given in seconds
${BTS_RESET_UPDATE_WRN_THR}    600     # Time (secs) spent between first cell down to last cell up on BTS
                                       # Possible values: (by default in accordance with KPI2a specifications)
                                       # - If ${BTS SW Update} is set to ALL, only one value should be given (ex. 606)
                                       # - list of all kpi thresholds separated by comma for each BTS software update operation is performed on
                                       # (ex. 600, 606).
${BTS_RESET_ROLLBACK_WRN_THR}  600     #  Time (secs) spent between first cell down to last cell up on BTS
                                       # Possible values: (by default in accordance with KPI13 specifications)
                                       # - If ${BTS_SW_Rollback} is set to ALL, only one value should be given (ex. 600)
                                       # - list of all kpi thresholds separated by comma for each BTS software rollback operation is performed on
                                       # (ex. 600, 606).
${BTS_MAX_WAIT_TIME}           900     # Maximum time for wait of ENB OnAir
${BTS_SCF_VALIDATION}          True    # Validate BTS SCF; can be True or False
${FORCE_TARGET_BTS_SW_DL}      False   # Flag used to force download of target BTS build(s) from WFT based on CM tags & selected build from
                                       # CM Single Run form, in order to be used for SW Update on each BTS.
                                       # For this case, variables "WFT_BTS_target_sw" should be default on empty, in order to select target build
                                       # based on CM form and tags. CM tags support also setting of different BTS target build for different BTSs
                                       # (tag: TARGET_BUILD={SW_BUILD_NAME}:{BTS_NUMBER}; Example: TARGET_BUILD=SBTS00_ENB_9999_250219_000019:1)
                                       # In offline running, you can define ENB_BUILD variable in argfile.txt, in order to select target build which
                                       # will be downloaded and used on each BTS or set "WFT_BTS_target_sw" variables, which allow to set explicitly
                                       # which build to download from WFT and use as target on each BTS. These WFT_BTS_target_sw variables have higher
                                       # priority and will override any CM settings.
${WFT_BTS1_target_sw}    # WFT BTS1 target SW name. Possible Values:
                         # - Leave default value Empty for automatic detection based on Single run form
                         # - Custom SW name; ex: SBTS00_ENB_9999_240910_000009
${WFT_BTS2_target_sw}    # WFT BTS2 target SW name. Possible Values:
                         # - Leave default value Empty for automatic detection based on Single run form
                         # - Custom SW name; ex: SBTS00_ENB_9999_240910_000009
${WFT_BTS3_target_sw}    # WFT BTS3 target SW name. Possible Values:
                         # - Leave default value Empty for automatic detection based on Single run form
                         # - Custom SW name; ex: SBTS00_ENB_9999_240910_000009
${WFT_BTS4_target_sw}    # WFT BTS4 target SW name. Possible Values:
                         # - Leave default value Empty for automatic detection based on Single run form
                         # - Custom SW name; ex: SBTS00_ENB_9999_240910_000009
${Remote target SW path BTS1}  None    # Path to remote zip file which needs to be downloaded; ex: 3G/WBTS00_0000/WBTS00_0000_3889_00.zip - for BTS1
${Remote target SW path BTS2}  None    # Path to remote zip file which needs to be downloaded; ex: 3G/WBTS00_0000/WBTS00_0000_3889_00.zip - for BTS2
${Remote target SW path BTS3}  None    # Path to remote zip file which needs to be downloaded; ex: 3G/WBTS00_0000/WBTS00_0000_3889_00.zip - for BTS3
${Remote target SW path BTS4}  None    # Path to remote zip file which needs to be downloaded; ex: 3G/WBTS00_0000/WBTS00_0000_3889_00.zip - for BTS4
${RFS_CUSTOM_SHARE_SW_DL}      False   # Flag to enable/disable SW package download from remote location
                                       # - SWs from BuildShareTimi01 can be downloaded locally. Default value is False
${CB015052_CHECK}              False   # Specify if feature CB015052 behavior (no FID4220 on BTS secondary controller) should be checked (True) or
                                       # skipped (False). By default False
${tempRadioMasterTriggerTime}  0       # Temporary radio master trigger time on BTS secondary controller, default value 0 (minutes). Taken into
                                       # account only if ${CB015052_CHECK} set on True
${RESTORE_TARGET_SW}           False   # Flag to enable/disable restoring target SW at the end of the test, via additional SW upgrade.
                                       # Possible values: True, False. Default value: False
${MEMORY_THRESHOLD}             20     # Maximum memory consumption difference in % between Admin CLI SW update performed in
                                       # server mode vs client mode(local mode)

*** Keywords ***
TC__SBTS_SBTS__SWM__SW_Update_Rollback_memory_consumption_CB015315_using_Admin_CLI
     [Documentation]
    ...  [CASE LINK]: https://jiradc.ext.net.nokia.com/browse/TAT-30503
    ...
    ...  *****************
    ...  Basic information
    ...  *****************
    ...  SBTS-SBTS-SBTS-SBTS test case for BTS SW Update Rollback measuring memory consumption when using Admin CLI.
    ...  The main steps performed for the test are:
    ...  - check initial state and alarms for all BTS
    ...  - Check and set actCli parameter on all BTS
    ...  - get initial SW versions from all BTS partitions
    ...  - perform SW Update via admin CLI in client mode on all BTS or choosen BTS
    ...  - monitor memory consumption during SW Update operation & export results to file
    ...  - check final SW versions from all BTS partitions
    ...  - perform SW rollback
    ...  - synchronize active and passive SW versions
    ...  - perform SW Update via admin CLI in server mode on all BTS or choosen BTS
    ...  - monitor memory consumption during SW Update operation & export results to file
    ...  - compare memory consumption in Admin CLI client mode vs server mode and set verdict based on defined threshold
    ...  - check reset behavior on all BTS after SW Update from ims file
    ...  - check state and alarms for all BTS after SW Update operation
    ...  - restore initial value of actCli parameter on all BTS
    ...  Pass criteria: BTS SW Update operation using admin CLI works as expected, states and alarms are as expected
    ...  memory consumption during Admin CLI SW Update in server mode is under defined threshold compared to client mode
    ...
    ...  ***************************
    ...  History of changes for SOAM
    ...  ***************************
    ...  - 20.02.2026 - https://jiradc.ext.net.nokia.com/browse/TAT-30503 - [CB015315] New TC
    ...  SBTS_SBTS_SWM_SW Update_Rollback_memory consumtion_CB015315_using_ADMIN_CLI
    ...  -19.03.2026 - https://jiradc.ext.net.nokia.com/browse/TAT-30648 - [CB015315] Update formula for
    ...  SBTS_SBTS_SWM_SW Update_Rollback_memory consumtion_CB015315_using_ADMIN_CLI DoD_<endfb2607>_
    ...

    Set Tags    CA-STATE    OWNER-constantin.diaconu@nokia.com    AUTHOR-adelina.branc@nokia.com    PHASE-QT    SW-SBTS26R2

    Check threshold list
    Step 1: Check initial all BTS state
    Step 2: Check initial all BTS alarms
    Step 3: Get all BTS info
    Step 4: Check and set actCli parameter on all BTS
    Step 5: Get Target SW for BTS SW Update
    Step 6: Perform BTS SW Update via Admin CLI client Mode
    Step 7: Check before rollback all BTS state
    Step 8: Check before rollback all BTS alarms
    Step 9: Perform BTS SW Rollback operation
    Step 10: Synchronize active and passive SW versions
    FOR  ${INDEX}  IN RANGE  1  ${REPEAT_COUNTER}+1
        Log  ==============================================================================  console=True
        Log  Start Cycle ${INDEX} of ${REPEAT_COUNTER}  console=True
        Log  ==============================================================================  console=True
        Set Test Variable  ${ITERATION}  ${INDEX}
        Step 11: Perform BTS SW Update via Admin CLI server Mode
        Step 12: Perform BTS SW Rollback operation
        Step 13: Synchronize active and passive SW versions
        Step 14: Check final all BTS state
        Step 15: Check final all BTS alarms
        Step 16: Check final number and state of Cells and RMs
    END
    Step 17: Restore Target SW on all BTS

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
        Get and Check Alarms SOAM  alias=${alias}  expected_alarms=@{EMPTY}  ignored_alarms=${test_alarms_list['${alias.upper()}_IGNORED_ALARMS']}
        ...  critical_alarms=${test_alarms_list['${alias.upper()}_CRITICAL_ALARMS']}
        Log  BTS ${alias} site - expected, ignored and critical alarms checked  console=True
    END

Step ${index}: Get all BTS info
    Log  Step ${index}: Get all BTS info  console=True

    ${BTS_alias_label_dict}  ${BTS_label_alias_dict}=  Get BTS alias label info dict
    Set Test Variable  ${BTS_alias_label_dict}
    Set Test Variable  ${BTS_label_alias_dict}
    ${BTS_alias_list}=  Get Dictionary Keys  ${BTS_alias_label_dict}  False
    ${BTS_label_list}=  Get Dictionary Values  ${BTS_alias_label_dict}  False
    Set Test Variable  ${BTS_alias_list}
    Set Test Variable  ${BTS_label_list}

    IF  '${BTS SW Update}' != 'ALL'
        Check BTS list  ${BTS_label_alias_dict}  ${BTS_label_list}
    END
    Log  ====================================================  console=True
    Log  BTS label list selected for BTS SW Update: ${BTS_label_list}  console=True
    Log  BTS alias list selected for BTS SW Update: ${BTS_alias_list}  console=True
    Log  ====================================================  console=True

    ${alias_to_BTS_index_dict}=  Create Dictionary  Master=1  Slave=2  Slave1=3  Slave2=4
    Set Test Variable  ${alias_to_BTS_index_dict}

    IF  '${CB015052_CHECK}' == 'False'  RETURN

    Log  Check TRM feature settings for check CB015052 feature behavior  console=True

    ${BTS_alias_RMOD_sn_dict}  ${RMOD_sn_BTS_alias_dict}  ${shared_RMOD_sn_list}  ${dedicated_RMOD_sn_list}=  Get all BTS RMOD sharing info
    Set Test Variable  ${BTS_alias_RMOD_sn_dict}
    Set Test Variable  ${RMOD_sn_BTS_alias_dict}
    Set Test Variable  ${shared_RMOD_sn_list}
    Set Test Variable  ${dedicated_RMOD_sn_list}

    ${all_BTS_controller_role_RMOD_sn_dict}=  Get all BTS controller role for configured RMOD from SCF
    Set Test Variable  ${all_BTS_controller_role_RMOD_sn_dict}

    ${BTS_primary_controller_shared_RMOD_list}  ${BTS_secondary_controller_shared_RMOD_list}=  Get all BTS controller role for shared RMOD
    Set Test Variable  ${BTS_primary_controller_shared_RMOD_list}
    Set Test Variable  ${BTS_secondary_controller_shared_RMOD_list}

    FOR  ${alias}  IN  @{BTS_secondary_controller_shared_RMOD_list}

        Check TRM feature settings  ${alias}

    END

Step ${index}: Check and set actCli parameter on all BTS
    [Documentation]
    ...  Check and set actCli parameter on all BTS from Admin

    Log  Step ${index}: Check and set actCli parameter to true on all BTS before SW Update Admin CLI actions  console=True
    FOR  ${alias}  IN  @{alias_list}
        ${actCli_initial}=  rfs_general.Get actCli parameter value  ${alias}
        IF  '${actCli_initial}' == 'false'
            rfs_general.Set actCli parameter value  true  ${alias}
        END
        Set Test Variable  ${ACTCLI_INITIAL_${alias}}  ${actCli_initial}
        Log  actCli parameter value on BTS ${alias} is set to true for SW Update Admin CLI actions  console=True
    END

Step ${index}: Get Target SW for BTS SW Update
    Log  Step ${index}: Get Target SW for BTS SW Update  console=True

    FOR  ${alias}  IN  @{alias_list}

        IF  '${alias}' not in ${BTS_alias_list}  CONTINUE

        ${BTS_index}=  Get From Dictionary  ${alias_to_BTS_index_dict}  ${alias}

        ${decoupling_build}=  tools.Get Bts Decoupling Build  bts_label=BTS${BTS_index}  decoupling_tag=TARGET_BUILD

        ${preloaded_package}=  Set Variable If  '${FORCE_TARGET_BTS_SW_DL}' != 'True'  ${EMPTY}
        ...  '${WFT_BTS${BTS_index}_target_sw}' != '${EMPTY}'  ${WFT_BTS${BTS_index}_target_sw}
        ...  '${decoupling_build}' != '${EMPTY}'  ${decoupling_build}
        ...  ${EMPTY}

        IF  '${FORCE_TARGET_BTS_SW_DL}' == 'True'
            Download And Set Current SW for SWDL  Target_SW_dir=${Target SW dir BTS${BTS_index}}  preloaded_package=${preloaded_package}
            Set Test Variable  ${Target SW BTS${BTS_index}}  ${Target SW}
            Set Test Variable  ${Target SW BTS${BTS_index} before renaming}  ${Target SW BTS before renaming}
            Check if SW version already exists on BTS  ${alias}
            Set Test Variable  ${Target SW name BTS${BTS_index}}  ${Target Package Name}
            CONTINUE
        END

        Set Test Variable  ${Target SW BTS${BTS_index} before renaming}  ${Target SW BTS${BTS_index}}

        IF  '${RFS_CUSTOM_SHARE_SW_DL}'!='True'
            ${Target SW tmp}=  Get SW file for SWDL  ${Target SW dir BTS${BTS_index}}  ${Target SW name BTS${BTS_index}}
        END

        IF  '${RFS_CUSTOM_SHARE_SW_DL}'=='True'
            Log  SW package for BTS ${alias} will be downloaded from remote server  console=True
            SFTP Download SW from remote server and rename  ${Remote target SW path BTS${BTS_index}}  ${alias}
        ELSE
            Rename Software Package  ${Target SW tmp}
        END
        Set Test Variable  ${Target SW BTS${BTS_index}}  ${Target SW}
        Log  Target SW for BTS ${alias} SW Update: ${Target SW}  console=True
        Check if SW version already exists on BTS  ${alias}
        ${target_sw_path}  ${target_sw_file}=  Split Path  ${Target SW}
        ${target_sw_name}  ${ext}=  Split Extension  ${target_sw_file}
        ${qc_target_sw}=  Convert To Uppercase  ${target_sw_name}
        Set Qc Parameter  qc_tc_swbuild  ${qc_target_sw}; ${QC ${alias} Active SW}
        Set Test Variable  ${Target SW name BTS${BTS_index}}  ${Target SW name}

    END

Step ${index}: Perform BTS SW Update via Admin CLI Client Mode
    [Documentation]
    ...  Perform SW Update on BTS via Admin CLI Client Mode

    Log  Step ${index}: Perform SW Update on BTS via Admin CLI Client Mode  console=True
    FOR  ${alias}  IN  @{BTS_alias_list}
        ${label}=  Get From Dictionary  ${BTS_alias_label_dict}  ${alias}
        Set Test Variable  ${label}
        Log  ==================================================  console=True
        Log  ***** Test will perform ${label} SW Update via Admin CLI Client Mode *****  console=True
        Log  ==================================================  console=True
        Set Test Variable  ${ITERATION}  1
        Get Current Date UTC info  start
        Get SW versions from all BTS partitions  initial
        Start Memory Consumption Check for BTS  ${label}  ${alias}  client
        BTS SW Update  ${alias}  client
        Stop Memory Consumption Check for BTS  ${label}  ${alias}  client
        Get SW versions from all BTS partitions  final
        Check SW versions from BTS partitions after BTS SW Update  ${alias}
        Get Current Date UTC info  end
        Check BTS reset behavior based on IMS info after BTS SW Update  ${alias}
        Get and check KPI2a info from IMS file  ${alias}
        Check feature CB015052 behaviour  ${alias}
    END

Step ${index}: Perform BTS SW Update via Admin CLI Server Mode
    [Documentation]
    ...  Perform SW Update on BTS via Admin CLI Server Mode

    Log  Step ${index}: Perform BTS SW Update via Admin CLI Server Mode  console=True
    FOR  ${alias}  IN  @{BTS_alias_list}
        ${label}=  Get From Dictionary  ${BTS_alias_label_dict}  ${alias}
        Set Test Variable  ${label}
        Log  ==================================================  console=True
        Log  ***** Test will perform ${label} SW Update via Admin CLI Server Mode *****  console=True
        Log  ==================================================  console=True
        Get Current Date UTC info  start
        Get SW versions from all BTS partitions  initial
        Start Memory Consumption Check for BTS  ${label}  ${alias}  server
        BTS SW Update  ${alias}  server
        Stop Memory Consumption Check for BTS  ${label}  ${alias}  server
        Get SW versions from all BTS partitions  final
        Check SW versions from BTS partitions after BTS SW Update  ${alias}
        Get Current Date UTC info  end
        Check BTS reset behavior based on IMS info after BTS SW Update  ${alias}
        Get and check KPI2a info from IMS file  ${alias}
        Check feature CB015052 behaviour  ${alias}
        Compare memory consumption in Client Mode vs Server Mode  ${label}  ${alias}
    END

Step ${index}: Perform BTS SW Rollback operation
    [Documentation]
    ...  Perform BTS SW Rollback from Admin

    IF  '${Activate_SW}' == 'False'
        Log  Skipping Step ${index}: BTS SW Rollback operation since Activate SW flag is set to False  console=True
        RETURN
    END

    Log  Step ${index}: Perform BTS SW Rollback operation  console=True
    FOR  ${alias}  IN  @{BTS_alias_list}
        ${label}=  Get From Dictionary  ${BTS_alias_label_dict}  ${alias}
        Set Test Variable  ${label}
        Get Current Date UTC info  start
        Get SW versions from all BTS partitions  initial
        Perform BTS SW Rollback  ${alias}
        Get SW versions from all BTS partitions  final
        Check SW versions from all BTS partitions after BTS SW Rollback  ${alias}
        Get Current Date UTC info  end
        Check all BTS reset behavior based on IMS info  ${alias}
        Get and check KPI13 info from IMS file  ${alias}
        Check feature CB015052 behaviour  ${alias}
    END

Step ${index}: Synchronize active and passive SW versions
    [Documentation]
    ...  Helper keyword used to synchronize Active and Passive partition SW

    IF  '${Activate_SW}' == 'False'
        Log  Skipping Step ${index}: Synchronize active and passive SW versions since Activate SW flag is set to False  console=True
        RETURN
    END

    Log  Step ${index}: Synchronize active and passive SW versions  console=True

    Sleep  5min  reason=Wait additional 5 min before synchronizing SW versions to ensure that all BTS internal processes are finished

    FOR  ${alias}  IN  @{BTS_alias_list}
        ${label}=  Get From Dictionary  ${BTS_alias_label_dict}  ${alias}
        Log  Synchronize active and passive SW versions on ${label}   console=True
        Wait Until Keyword Succeeds  15 min  30 sec  Admin Synchronizing Active and Passive SW version  alias=${alias}  timeout=600
    END

Step ${index}: Check final number and state of Cells and RMs
    [Documentation]
    ...  Cells state is checked according to operationalState attribute
    ...  Check if number of configured cells and radio modules in SCF are properly mapping on BTS running view.
    ...  Also check RMs operationalState

    [Timeout]  30 min
    Log  Step ${index}: Check final number and state of Cells and RMs  console=True
    RFS Test Case Final Checks

Step ${index}: Restore Target SW on all BTS
    [Documentation]
    ...  Restore Target SW on all BTS as final step in case RESTORE_TARGET_SW is set to True

    Log  Step ${index}: Restore Target SW on all BTS  console=True
    IF  '${RESTORE_TARGET_SW}' == 'True'
        Restore Target SW on all BTS
    ELSE
        Log  Skipping restoring Target SW on all BTS since RESTORE_TARGET_SW is set to False  console=True
    END

Check threshold list
    Check threshold list for SW Update Rollback  Update  ${BTS SW Update}  ${BTS_RESET_UPDATE_WRN_THR}
    Check threshold list for SW Update Rollback  Rollback  ${BTS_SW_Rollback}  ${BTS_RESET_ROLLBACK_WRN_THR}

Check threshold list for SW Update Rollback
    [Arguments]  ${operation}  ${BTS_SW_operation}  ${BTS_RESET_WRN_THR}

    ${BTS_RESET_WRN_THR_strip}=  Replace String  ${BTS_RESET_WRN_THR}  ${SPACE}  ${EMPTY}
    ${BTS_RESET_WRN_THR}=  Split String  ${BTS_RESET_WRN_THR_strip}  ,
    ${BTS_RESET_WRN_THR_length}=  Get Length  ${BTS_RESET_WRN_THR}

    IF  ${BTS_RESET_WRN_THR_length} == 1 and '${BTS_SW_operation}' == 'ALL'  RETURN

    ${BTS_SW_operation_strip}=  Replace String  ${BTS_SW_operation}  ${SPACE}  ${EMPTY}
    ${BTS_SW_operation}=  Split String  ${BTS_SW_operation_strip}  ,
    ${BTS_SW_operation_length}=  Get Length  ${BTS_SW_operation}

    IF  ${BTS_RESET_WRN_THR_length} != ${BTS_SW_operation_length} and '${operation}' == 'Update'
        FAIL  Test arguments \${BTS_RESET_UPDATE_WRN_THR} and \${BTS SW Update} were set incorrectly!
    ELSE IF  ${BTS_RESET_WRN_THR_length} != ${BTS_SW_operation_length} and '${operation}' == 'Rollback'
        FAIL  Test arguments \${BTS_RESET_ROLLBACK_WRN_THR} and \${BTS_SW_Rollback} were set incorrectly!
    END

    Create Threshold Dict  ${operation}  ${BTS_SW_operation}  ${BTS_RESET_WRN_THR}

Create Threshold Dict
    [Arguments]  ${operation}  ${BTS_SW_operation}  ${BTS_RESET_WRN_THR}

    ${threshold_dict}=  Create Dictionary
    ${length}=  Get Length  ${BTS_SW_operation}
    FOR  ${index}  IN RANGE  ${length}
        ${threshold}=  Set Variable  ${BTS_RESET_WRN_THR}[${index}]
        ${bts}=  Set Variable  ${BTS_SW_operation}[${index}]
        Set To Dictionary  ${threshold_dict}  ${bts}  ${threshold}
    END
    Set Test Variable  ${${operation}_threshold_dict}  ${threshold_dict}

Check BTS list
    [Arguments]  ${BTS_label_alias_dict}  ${BTS_label_list}

    ${BTS_SW_Update_strip}=  Replace String  ${BTS SW Update}  ${SPACE}  ${EMPTY}
    ${BTS_SW_Update}=  Split String  ${BTS_SW_Update_strip}  ,
    ${BTS_check}=  Set Variable  True
    ${BTS_invalid_label_list}=  Create List
    ${BTS_request_label_list}=  Create List
    ${BTS_request_alias_list}=  Create List

    FOR  ${item}  IN  @{BTS_SW_Update}
        IF  '${item}' not in ${BTS_label_list}
            ${BTS_check}=  Set Variable  False
            Append To List  ${BTS_invalid_label_list}  ${item}
        ELSE
            Append To List  ${BTS_request_label_list}  ${item}
        END
    END

    IF  '${BTS_check}' == 'False'
        Log Long String  Following selected BTS are not valid: ${BTS_invalid_label_list}. Please select values for test argument \${BTS_LIST} from
        ...  configured BTS: ${BTS_label_list} or let default value: ALL  console=True
        Fail  Improper value for argument!
    END

    FOR  ${item}  IN  @{BTS_request_label_list}
        ${BTS_request_alias}=  Get From Dictionary  ${BTS_label_alias_dict}  ${item}
        Append To List  ${BTS_request_alias_list}  ${BTS_request_alias}
    END

    Set Test Variable  ${BTS_label_list}  ${BTS_request_label_list}
    Set Test Variable  ${BTS_alias_list}  ${BTS_request_alias_list}

Check if SW version already exists on BTS
    [Arguments]  ${alias}

    ${BTS_index}=  Get From Dictionary  ${alias_to_BTS_index_dict}  ${alias}
    Check if SW already exists on BTS  ${Target SW BTS${BTS_index}}  ${${alias} active SW}  ${${alias} passive SW}

Get SW versions from all BTS partitions
    [Arguments]  ${when}

    Log  Get ${when} SW versions from all BTS partitions  console=True
    FOR  ${alias}  IN  @{alias_list}
        Admin Get BTS SW Version  alias=${alias}
        Set Test Variable  ${${alias} ${when} active SW}  ${${alias} active SW}
        Set Test Variable  ${${alias} ${when} passive SW}  ${${alias} passive SW}
    END

BTS SW Update
    [Arguments]  ${alias}  ${mode}

    Log  Perform ${label} SW Update via Admin CLI ${mode}  console=True
    ${BTS_index}=  Get From Dictionary  ${alias_to_BTS_index_dict}  ${alias}
    ${activation_preposition}=  Set Variable If  ${Activate SW}  with  without
    Set Test Variable  ${activation_preposition}

    IF  '${Activate SW}'=='True'
        Log Long String  ${label} SW Update ${activation_preposition} activation via ADMIN CLI will be performed using ${Target SW BTS${BTS_index}}
        ...  in ${mode} mode  console=True
        BTS SW Update With Activation  ${alias}  ${mode}
    ELSE
        Log Long String  ${label} SW Update ${activation_preposition} activation via ADMIN CLI will be performed using ${Target SW BTS${BTS_index}}
        ...  in ${mode} mode  console=True
        BTS SW Update Without Activation  ${alias}  ${mode}
    END

BTS SW Update in Server Mode
    [Arguments]  ${alias}  ${should_activate}

    Log  Perform ${label} SW Update in Server Mode  console=True
    ${BTS_index}=  Get From Dictionary  ${alias_to_BTS_index_dict}  ${alias}
    ${cli_command}=  Set Variable
    ...  {"requestId":100,"parameters":{"name":"softwareUpdate","parameters":{"shouldActivate":${should_activate},"shouldResetRadios":true}}}

    ${BTS_mplane_ip}=  Admin Get BTS M-plane IP address  alias=${alias}
    rfs_admin.Admin Get BTS SW Version  ${alias}

    ${status}  ${server_response}=  Run Keyword And Ignore Error  admin_cli.Setup Admin CLI Server Mode
    ...    sw_basename=${Target SW BTS${BTS_index} before renaming}
    ...    ip=${BTS_mplane_ip}
    ...    user=Nemuadmin
    ...    password=nemuuser
    ...    port=443
    ...    cli_host=127.0.0.1
    ...    cli_port=9001
    IF  '${status}' == 'FAIL'
        Fail  Admin CLI Server Mode setup failed with error: ${server_response}
    END
    Log  Admin CLI server response: ${server_response}  console=True

    ${status}  ${request_response}=  Run Keyword And Ignore Error  admin_cli.Send Admin CLI Request To Server
    ...  request_data=${cli_command}  server_input_file=${Target SW BTS${BTS_index}}

    IF  '${status}' == 'FAIL'
        Fail  Admin CLI request failed with error: ${request_response}
    END
    Log  Admin CLI request status response from Server: ${status}  console=True

    ${final_response}=  Get From List  ${request_response}  -1
    IF  '${final_response['requestStatus']}' != 'completed'
        Fail  Admin CLI request failed with error: ${final_response}
    ELSE
        Log  Admin CLI request final response from Server: ${final_response}  console=True
    END

    [Teardown]  admin_cli.Teardown Admin CLI Server Mode

BTS SW Update in Client Mode
    [Arguments]  ${alias}  ${should_activate}

    Log  Perform ${label} SW Update in Client Mode  console=True
    ${BTS_index}=  Get From Dictionary  ${alias_to_BTS_index_dict}  ${alias}
    ${cli_command}=  Set Variable
    ...  {"requestId":100,"parameters":{"name":"softwareUpdate","parameters":{"shouldActivate":${should_activate},"shouldResetRadios":true}}}

    ${BTS_mplane_ip}=  Admin Get BTS M-plane IP address  alias=${alias}
    rfs_admin.Admin Get BTS SW Version  ${alias}

    ${status}  ${setup_response}=  Run Keyword And Ignore Error  admin_cli.Setup Admin CLI
    ...  ${Target SW BTS${BTS_index} before renaming}  ${BTS_mplane_ip}
    IF  '${status}' == 'FAIL'
        Fail  Admin CLI setup failed with error: ${setup_response}
    END
    ${status}  ${request_response}=  Run Keyword And Ignore Error  admin_cli.Send Admin CLI Request
    ...  request_data=${cli_command}  input_file=${Target SW BTS${BTS_index}}

    IF  '${status}' == 'FAIL' or '${request_response['requestStatus']}' == 'failed'
        Fail  Admin CLI request failed with error: ${request_response}
    END

    Log  Admin CLI request response in Client Mode: ${request_response}  console=True

Perform BTS SW Rollback
    [Arguments]  ${alias}

    Log  Perform ${label} SW Rollback  console=True
    Get Current Time  rollback_initial
    Log  ${label} reset_start_time is: ${time_rollback_initial}  console=True
    coam.Rollback Software  connection=${alias}  timeout=${BTS_MAX_WAIT_TIME}

    ${remote_host_ip}=  Set Variable If  '${alias.upper()}' == 'MASTER'  None  ${${alias.upper()}}[${alias.upper()}_PC_IP_ADDRESS]
    ${remained_MAX_WAIT_TIME}=  Get elapsed time  ${time_rollback_initial}  ${BTS_MAX_WAIT_TIME}
    Wait For Target To Be Not Reachable TAF  hostname=${${alias.upper()}}[${alias.upper()}_TECH_IP_ADDRESS]  timeout=${remained_MAX_WAIT_TIME}
    ...  remote_host=${remote_host_ip}
    ${remained_MAX_WAIT_TIME}=  Get elapsed time  ${time_rollback_initial}  ${BTS_MAX_WAIT_TIME}
    Wait For Target To Be Reachable TAF  hostname=${${alias.upper()}}[${alias.upper()}_TECH_IP_ADDRESS]  timeout=${remained_MAX_WAIT_TIME}
    ...  remote_host=${remote_host_ip}
    Sleep  120s
    ${ims_file_path_Rollback}=  Admin Collect IMS file with timestamp  folder_path=${Test Results Dir}/IMS/${alias}  alias=${alias}
    Set Test Variable  ${${alias}_ims_file_path_Rollback}  ${ims_file_path_Rollback}
    Wait Until Keyword Succeeds  3x  10s  Admin reset and Infomodel reconnect sessions  reset_req=True  alias=${alias}  infomodel_reset=False

    ${remained_MAX_WAIT_TIME}=  Get elapsed time  ${time_rollback_initial}  ${BTS_MAX_WAIT_TIME}
    Check cells availability status online  ${alias}  ${remained_MAX_WAIT_TIME}

    Check all BTS states and alarms after BTS SW Rollback  ${alias}

Check all BTS states and alarms after BTS SW Rollback
    [Arguments]  ${alias}
    ${CELL_state_enabled_check}=  Set Variable  operationalState=${Enabled_}, blockingState=${Unblocked_}
    ${CELL_state_enabled}=  Set Variable  operationalState=Enabled, blockingState=Unblocked

    Log  ***** Check ${label} status and alarms after BTS SW Rollback operation on ${label} *****  console=True
    ${remained_MAX_WAIT_TIME}=  Get elapsed time  ${time_rollback_initial}  ${BTS_MAX_WAIT_TIME}
    Admin Check BTS Procedural and Blocking states  ${OnAir_}  ${Unblocked_}  ${remained_MAX_WAIT_TIME}  ${alias}
    Log  ${label} site - proceduralState: OnAir, blockingState: Unblocked, as expected!  console=True

    ${remained_MAX_WAIT_TIME}=  Get elapsed time  ${time_rollback_initial}  ${BTS_MAX_WAIT_TIME}
    Admin Check BTS RAT cells expected states  ${CELL_state_enabled_check}  ${alias}  ${remained_MAX_WAIT_TIME}
    Log  All ${label} cell(s) status:\n - ${CELL_state_enabled}  console=True

    Log  Check ${label} alarms:  console=True
    Get and Check Alarms SOAM  alias=${alias}  expected_alarms=@{EMPTY}  ignored_alarms=${test_alarms_list['${alias.upper()}_IGNORED_ALARMS']}
    ...  critical_alarms=${test_alarms_list['${alias.upper()}_CRITICAL_ALARMS']}
    Log  ${label} site - expected, ignored and critical alarms checked  console=True

    Log  ***** Check the other BTS(s) status and alarms after BTS SW Rollback operation on ${label} *****  console=True
    FOR  ${other_alias}  IN  @{alias_list}
        IF  '${other_alias}' == '${alias}'  CONTINUE

        ${other_label}=  Get From Dictionary  ${BTS_alias_label_dict}  ${other_alias}

        Log  Check ${other_label} status:  console=True
        Admin Check BTS Procedural and Blocking states  ${OnAir_}  ${Unblocked_}  180  ${other_alias}
        Log  ${other_label} site - proceduralState: OnAir, blockingState: Unblocked, as expected!  console=True
        Admin Check all BTS cells expected states  ${CELL_state_enabled_check}  ${other_alias}  180
        Log  All ${other_label} cell(s) status:\n - ${CELL_state_enabled}  console=True

        Log  Check ${other_label} alarms:  console=True
        Get and Check Alarms SOAM  alias=${other_alias}  expected_alarms=@{EMPTY}
        ...  ignored_alarms=${test_alarms_list['${other_alias.upper()}_IGNORED_ALARMS']}
        ...  critical_alarms=${test_alarms_list['${other_alias.upper()}_CRITICAL_ALARMS']}  wait_for_alarm_clear=15 min
        Log  ${other_label} site - expected, ignored and critical alarms checked  console=True
    END

Check SW versions from all BTS partitions after BTS SW Rollback
    [Arguments]  ${alias}
    Log  Check SW versions from all BTS partitions after ${label} SW Rollback  console=True

    Should Be Equal  ${${alias} final active SW}  ${${alias} initial passive SW}
    Should Be Equal  ${${alias} final passive SW}  ${${alias} initial active SW}

    FOR  ${other_alias}  IN  @{alias_list}
        IF  '${other_alias}' == '${alias}'  CONTINUE

        Should Be Equal  ${${other_alias} final active SW}  ${${other_alias} initial active SW}
        Should Be Equal  ${${other_alias} final passive SW}  ${${other_alias} initial passive SW}
    END

    Log  ${label} SW Rollback successfully performed!  console=True

BTS SW Update With Activation
    [Documentation]
    ...  Perform BTS SW Update with activation. BTS reset time check performed.
    [Arguments]  ${alias}  ${mode}

    ${BTS_index}=  Get From Dictionary  ${alias_to_BTS_index_dict}  ${alias}
    IF  ${BTS_SCF_VALIDATION}
        Check BTS SCF Validation On Demand  alias=${alias}
    END

    ${reset_number}=  Admin Get Reset info based on BTS SW Precheck  SW_package=${Target SW BTS${BTS_index}}  alias=${alias}
    Set Test Variable  ${${alias.upper()}_EXPECTED_RESET_NUMBER}  ${reset_number}
    Log  ${\n}======================================================================  console=True
    IF  ${resetCoverage_found}
        Log  Expected ${label} reset number based on SW Precheck before SW Update: ${${alias.upper()}_EXPECTED_RESET_NUMBER}  console=True
    ELSE
        Log  Expected ${label} reset number after SW Update (without SW Precheck): ${${alias.upper()}_EXPECTED_RESET_NUMBER}  console=True
    END
    Log  ======================================================================${\n}  console=True

    Sleep  60s  Wait some time before performing SW Update to ensure BTS ${alias} is not busy

    IF  '${mode}' == 'client'
        BTS SW Update in Client Mode  ${alias}  true
    ELSE
        BTS SW Update in Server Mode  ${alias}  true
    END

    ${remote_host_ip}=  Set Variable If  '${alias}' == 'Master'  None  ${${alias.upper()}}[${alias.upper()}_PC_IP_ADDRESS]
    IF  ${${alias.upper()}_EXPECTED_RESET_NUMBER} != 0
        Wait For Target To Be Not Reachable TAF
        ...  hostname=${${alias.upper()}}[${alias.upper()}_TECH_IP_ADDRESS]  timeout=${BTS_MAX_WAIT_TIME}  remote_host=${remote_host_ip}
    END

    Get Current Time  update_initial
    IF  ${${alias.upper()}_EXPECTED_RESET_NUMBER} != 0
        Log  ${label} reset_start_time is: ${time_update_initial}  console=True
    END

    ${remained_MAX_WAIT_TIME}=  Get elapsed time  ${time_update_initial}  ${BTS_MAX_WAIT_TIME}
    Wait For Target To Be Reachable TAF  hostname=${${alias.upper()}}[${alias.upper()}_TECH_IP_ADDRESS]  timeout=${remained_MAX_WAIT_TIME}
    ...  remote_host=${remote_host_ip}

    Sleep  120s
    ${ims_file_path_SWDL}=  Admin Collect IMS file with timestamp  folder_path=${Test Results Dir}/IMS/${alias}  alias=${alias}
    Set Test Variable  ${${alias}_ims_file_path_SWDL}  ${ims_file_path_SWDL}
    Wait Until Keyword Succeeds  3x  10s  Admin reset and Infomodel reconnect sessions  reset_req=True  alias=${alias}  infomodel_reset=False

    ${remained_MAX_WAIT_TIME}=  Get elapsed time  ${time_update_initial}  ${BTS_MAX_WAIT_TIME}
    Check cells availability status online  ${alias}  ${remained_MAX_WAIT_TIME}
    Log  All BTS cell(s) status:\n - operationalState=Enabled  console=True

    IF  ${BTS_SCF_VALIDATION}
        Check BTS SCF Validation On Demand  alias=${alias}
    END

    Log  ${label} SW Update in ${mode} Mode with activation performed!  console=True

BTS SW Update Without Activation
    [Documentation]
    ...  Perform BTS SW Update without activation.
    [Arguments]  ${alias}  ${mode}

    IF  '${mode}' == 'client'
        BTS SW Update in Client Mode  ${alias}  false
    ELSE
        BTS SW Update in Server Mode  ${alias}  false
    END

    Log  ${label} SW Update in ${mode} Mode without activation performed!  console=True

Check SW versions from BTS partitions after BTS SW Update
    [Arguments]  ${alias}
    Log  Check SW versions from ${label} partitions after ${label} SW Update  console=True

    ${BTS_index}=  Get From Dictionary  ${alias_to_BTS_index_dict}  ${alias}

    Admin Get BTS SW Version  alias=${alias}
    IF  not ${Activate SW}
        Should Match Regexp  ${Target SW BTS${BTS_index}}  (?i).*(${${alias} passive SW}|${${alias} planned SW}).*
        Check SW version on peer BTS after BTS SW Update  ${alias}
    ELSE
        Should Match Regexp  ${Target SW BTS${BTS_index}}  (?i).*${${alias} active SW}.*
        Check SW version on peer BTS after BTS SW Update  ${alias}
    END
    Log  ${label} SW update ${activation_preposition} activation successfully performed!  console=True

Check SW version on peer BTS after BTS SW Update
    [Arguments]  ${alias}
    FOR  ${other_alias}  IN  @{alias_list}
        IF  '${other_alias}' == '${alias}'  CONTINUE

        Should Be Equal  ${${other_alias} final active SW}  ${${other_alias} initial active SW}
        Should Be Equal  ${${other_alias} final passive SW}  ${${other_alias} initial passive SW}
    END

Check BTS reset behavior based on IMS info after BTS SW Update
    [Arguments]  ${alias}
    [Documentation]

    ...  BTS RESET info is checked based on IMS info. Reset behavior as expected if:
    ...  - BTS ${alias} site: ${${alias.upper()}_EXPECTED_RESET_NUMBER}
    ...  - other BTS(s) site: reset number is 0
    ...  Otherwise, reset behavior not as expected, then errors are added to report and failed.

    Log  Check BTS reset behavior based on IMS info after ${label} SW Update  console=True

    IF  ${Activate SW} is True
        Log  Check ${label} reset behavior during ${label} SW Update with activation  console=True
        Get and check BTS RESET info from IMS file  ims_file_path=${${alias}_ims_file_path_SWDL}
        ...  expected_reset_number=${${alias.upper()}_EXPECTED_RESET_NUMBER}  alias=${alias}
        ...  remove_ims_file=False
        Log  Check ${label} reset behavior after ${label} SW Update with activation  console=True
        Get and check BTS RESET info from IMS file  expected_reset_number=0  alias=${alias}  remove_ims_file=False
        Check reset behavior on peer BTS  with  ${alias}
    ELSE IF  ${Activate SW} is False
        Log  Check ${label} reset behavior after ${label} SW Update without activation  console=True
        Get and check BTS RESET info from IMS file  expected_reset_number=0  alias=${alias}  remove_ims_file=False
        Check reset behavior on peer BTS  without  ${alias}
    END

Check reset behavior on peer BTS
    [Arguments]  ${activation_preposition}  ${alias}
    FOR  ${other_alias}  IN  @{alias_list}
        IF  '${other_alias}' == '${alias}'  CONTINUE

        ${label_peer}=  Get From Dictionary  ${BTS_alias_label_dict}  ${other_alias}
        Log  Check ${label_peer} reset behavior after ${label} SW Update ${activation_preposition} activation  console=True
        Get and check BTS RESET info from IMS file  expected_reset_number=0  alias=${other_alias}  remove_ims_file=False
    END

Check all BTS reset behavior based on IMS info
    [Documentation]
    ...  BTS RESET info is checked based on IMS info. Reset behavior as expected if:
    ...  - BTS ${alias} site: 1
    ...  - other BTS(s) site: reset number is 0
    ...  Otherwise, reset behavior not as expected, then errors are added to report and failed.
    [Arguments]  ${alias}

    Log  Check all BTS reset behavior based on IMS info  console=True
    Get and check BTS RESET info from IMS file  ims_file_path=${${alias}_ims_file_path_Rollback}  expected_reset_number=1  alias=${alias}
    ...  start_point_timestamp_UTC=${date_timestamp_start_UTC}  end_point_timestamp_UTC=${date_timestamp_end_UTC}
    FOR  ${other_alias}  IN  @{alias_list}
        IF  '${other_alias}' == '${alias}'  CONTINUE
        Get and check BTS RESET info from IMS file  expected_reset_number=0  alias=${other_alias}
        ...  start_point_timestamp_UTC=${date_timestamp_start_UTC}  end_point_timestamp_UTC=${date_timestamp_end_UTC}
    END

Get and check KPI13 info from IMS file
    [Documentation]
    ...  Get and check KPI13 info from IMS file.
    [Arguments]  ${alias}

    Log  Get and check KPI13 info from IMS file  console=True
    ${label}=  Get From Dictionary  ${BTS_alias_label_dict}  ${alias}
    ${KeyIsPresent}=  Run Keyword And Return Status  Dictionary Should Contain Key  ${Rollback_threshold_dict}  ${label}
    IF  ${KeyIsPresent}
        ${BTS_RESET_WRN_THR}=  Get From Dictionary  ${Rollback_threshold_dict}  ${label}
    ELSE
        ${BTS_RESET_WRN_THR}=  Set Variable  ${BTS_RESET_ROLLBACK_WRN_THR}
    END
    ${ims_file_path_after_Rollback}=  Admin Collect IMS file with timestamp  folder_path=${Test Results Dir}/IMS/${alias}  alias=${alias}
    ${ims_file_path_list}=  Create List  ${${alias}_ims_file_path_Rollback}  ${ims_file_path_after_Rollback}
    ${kpi_name_delta_dict}=  Get and check KPI info from IMS file
    ...  kpi_names=kpi13  kpi_thresholds=${BTS_RESET_WRN_THR}   ims_file_path=${ims_file_path_list}  alias=${alias}
    ${kpi_delta_list}=  Get From Dictionary  ${kpi_name_delta_dict}  kpi13

    Export KPI Results to File  alias=${alias}  obj=BTS  obj_type=SBTS  obj_id=${alias}  action_1=SW_Rollback  kpi_reported_1=KPI_13
    ...  event_value_1=${kpi_delta_list[0]}  source_info=ims

Get and check KPI2a info from IMS file
    [Documentation]
    ...  Get and check KPI2a info from IMS file.
    [Arguments]  ${alias}

    IF  '${Activate SW}' == 'False'  RETURN
    IF  ${${alias.upper()}_EXPECTED_RESET_NUMBER} == 0  RETURN

    Log  Get and check KPI2a info from IMS file  console=True
    ${label}=  Get From Dictionary  ${BTS_alias_label_dict}  ${alias}
    ${KeyIsPresent}=  Run Keyword And Return Status  Dictionary Should Contain Key  ${Update_threshold_dict}  ${label}
    IF  ${KeyIsPresent}
        ${BTS_RESET_WRN_THR}=  Get From Dictionary  ${Update_threshold_dict}  ${label}
    ELSE
        ${BTS_RESET_WRN_THR}=  Set Variable  ${BTS_RESET_UPDATE_WRN_THR}
    END
    ${ims_file_path_after_Update}=  Admin Collect IMS file with timestamp  folder_path=${Test Results Dir}/IMS/${alias}  alias=${alias}
    ${ims_file_path_list}=  Create List  ${${alias}_ims_file_path_SWDL}  ${ims_file_path_after_Update}
    ${kpi_name_delta_dict}=  Get and check KPI info from IMS file
    ...  kpi_names=kpi2a  kpi_thresholds=${BTS_RESET_WRN_THR}  ims_file_path=${ims_file_path_list}  alias=${alias}
    ${kpi_delta_list}=  Get From Dictionary  ${kpi_name_delta_dict}  kpi2a

    Export KPI Results to File  alias=${alias}  obj=BTS  obj_type=SBTS  obj_id=${alias}  action_1=SW_Update  kpi_reported_1=KPI_2a
    ...  event_value_1=${kpi_delta_list[0]}  source_info=ims

Get all BTS controller role for shared RMOD

    ${BTS_primary_controller_shared_RMOD_list}=  Create List
    ${BTS_secondary_controller_shared_RMOD_list}=  Create List

    FOR  ${alias}  IN  @{alias_list}

        ${BTS_controller_role_RMOD_sn_dict}=  Get From Dictionary  ${all_BTS_controller_role_RMOD_sn_dict}  ${alias}
        ${BTS_primary_controller_RMOD_sn_list}=  Get From Dictionary  ${BTS_controller_role_RMOD_sn_dict}  BTS_primary_controller_RMOD_sn_list
        ${BTS_secondary_controller_RMOD_sn_list}=  Get From Dictionary  ${BTS_controller_role_RMOD_sn_dict}  BTS_secondary_controller_RMOD_sn_list
        ${BTS_primary_controller_shared_RMOD_sn_list}=  Get BTS info for shared RMOD  ${BTS_primary_controller_RMOD_sn_list}
        ${BTS_primary_controller_shared_RMOD_sn_count}=  Get Length  ${BTS_primary_controller_shared_RMOD_sn_list}
        IF  ${BTS_primary_controller_shared_RMOD_sn_count} > 0
            Append To List  ${BTS_primary_controller_shared_RMOD_list}  ${alias}
        END
        ${BTS_secondary_controller_shared_RMOD_sn_list}=  Get BTS info for shared RMOD  ${BTS_secondary_controller_RMOD_sn_list}
        ${BTS_secondary_controller_shared_RMOD_sn_count}=  Get Length  ${BTS_secondary_controller_shared_RMOD_sn_list}
        IF  ${BTS_secondary_controller_shared_RMOD_sn_count} > 0
            Append To List  ${BTS_secondary_controller_shared_RMOD_list}  ${alias}
        END

        Set Test Variable  ${${alias}_secondary_controller_shared_RMOD_sn_count}  ${BTS_secondary_controller_shared_RMOD_sn_count}

    END

    RETURN  ${BTS_primary_controller_shared_RMOD_list}  ${BTS_secondary_controller_shared_RMOD_list}

Get BTS info for shared RMOD
    [Arguments]  ${RMOD_sn_list}

    ${BTS_shared_RMOD_sn_list}=  Create List

    FOR  ${RMOD_sn}  IN  @{RMOD_sn_list}

        IF  '${RMOD_sn}' in ${shared_RMOD_sn_list}
            Append To List  ${BTS_shared_RMOD_sn_list}  ${RMOD_sn}
        END

    END

    RETURN  ${BTS_shared_RMOD_sn_list}

Start Memory Consumption Check for BTS
    [Arguments]  ${label}  ${alias}  ${mode}
    Log  Start Memory consumption check for ${label} with alias ${alias} in ${mode} mode  console=True
    ${BTS_index}=  Get From Dictionary  ${alias_to_BTS_index_dict}  ${alias}

    ${pattern_client}=  Set Variable If  '${mode}' == 'client'
    ...  ${Target SW BTS${BTS_index} before renaming}_ADMIN_CLI/bin/main.bundle.js
    ...  ${Target SW BTS${BTS_index} before renaming}_ADMIN_CLI/agent-cli/bin/agent.bundle.js

    ${pattern_server}=  Set Variable If  '${mode}' == 'server'
    ...  ${Target SW BTS${BTS_index} before renaming}_ADMIN_CLI/bin/main.bundle.js
    ...  ${Target SW BTS${BTS_index} before renaming}_ADMIN_CLI/agent-cli/bin/agent.bundle.js

    IF  '${mode}' == 'server'
        memory_consumption.Start Continuous Memory Monitoring  ${label}_${mode}_client  ${pattern_client}  interval=1
        Set Test Variable  ${${label}_${mode}_client_monitor_id}  ${label}_${mode}_client
        Log  Started memory monitoring with ID:${${label}_${mode}_client_monitor_id} on ${alias} for Admin CLI Client process  console=True
        memory_consumption.Start Continuous Memory Monitoring  ${label}_${mode}  ${pattern_server}  interval=1
        Set Test Variable  ${${label}_${mode}_monitor_id}  ${label}_${mode}
        Log  Started memory monitoring with ID:${${label}_${mode}_monitor_id} on ${alias} for Admin CLI Server process  console=True
    ELSE IF  '${mode}' == 'client'
        memory_consumption.Start Continuous Memory Monitoring  ${label}_${mode}  ${pattern_client}  interval=1
        Set Test Variable  ${${label}_${mode}_monitor_id}  ${label}_${mode}
        Log  Started memory monitoring with ID:${${label}_${mode}_monitor_id} on ${alias}  console=True
    END

Stop Memory Consumption Check for BTS
    [Arguments]  ${label}  ${alias}  ${mode}
    Log  Stop Memory consumption check for ${label} with alias ${alias} in ${mode} mode  console=True

    IF  '${mode}' == 'server'
        Stop Continuous Memory Monitoring  ${${label}_${mode}_client_monitor_id}
        Log  Stopped memory monitoring with ID:${${label}_${mode}_client_monitor_id} on ${alias} for Admin CLI Client process.  console=True
        Stop Continuous Memory Monitoring  ${${label}_${mode}_monitor_id}
        Log  Stopped memory monitoring with ID:${${label}_${mode}_monitor_id} on ${alias} for Admin CLI Server process.  console=True
        Get Memory Statistics for BTS  ${label}  ${alias}  server
    ELSE IF  '${mode}' == 'client'
        memory_consumption.Stop Continuous Memory Monitoring  ${${label}_${mode}_monitor_id}
        Log  Stopped memory monitoring with ID:${${label}_${mode}_monitor_id} on ${alias}.  console=True
        Get Memory Statistics for BTS  ${label}  ${alias}  client
    END

Get Memory Statistics for BTS
    [Arguments]  ${label}  ${alias}  ${mode}

    Log  Get Memory Statistics for ${label} in ${mode} mode  console=True
     ${stats}=  memory_consumption.Get Memory Statistics  ${${label}_${mode}_monitor_id}
    Log  Memory Consumption Statistics for ID:${${label}_${mode}_monitor_id} on ${alias}  console=True
    Log  - Max RSS: ${stats['max_rss_gb']} GB  console=True
    Log  - Latest RSS: ${stats['latest_rss_gb']} GB  console=True
    Log  - Max Memory %: ${stats['max_mem_percent']}%  console=True
    Log  - Latest Memory %: ${stats['latest_mem_percent']}%  console=True

    Set Test Variable  ${${label}_${mode}_stats}  ${stats}

    ${output_file}=  Set Variable  ${BTS Files}/${alias}/iteration${ITERATION}_memory_${${label}_${mode}_monitor_id}.txt

    memory_consumption.Save Memory Data To File  ${${label}_${mode}_monitor_id}  ${output_file}  ${mode}
    Log  Memory consumption data for ${label} in ${mode} mode saved to file: ${output_file}  console=True

    memory_consumption.Clear Memory Data  ${${label}_${mode}_monitor_id}

    IF  '${mode}' == 'client'  RETURN

    Log  Get Memory Statistics for client part ${label} in ${mode} mode  console=True
    ${stats}=  memory_consumption.Get Memory Statistics  ${${label}_${mode}_client_monitor_id}
    Log  Memory Consumption Statistics for ID:${${label}_${mode}_client_monitor_id} on ${alias}  console=True
    Log  - Max RSS: ${stats['max_rss_gb']} GB  console=True
    Log  - Latest RSS: ${stats['latest_rss_gb']} GB  console=True
    Log  - Max Memory %: ${stats['max_mem_percent']}%  console=True
    Log  - Latest Memory %: ${stats['latest_mem_percent']}%  console=True

    Set Test Variable  ${${label}_${mode}_client_stats}  ${stats}

    ${output_file}=  Set Variable  ${Test Results Dir}/iteration${ITERATION}_memory_${mode}_client_${${label}_${mode}_client_monitor_id}.txt
    memory_consumption.Save Memory Data To File  ${${label}_${mode}_client_monitor_id}  ${output_file}  ${mode}_client
    Log  Memory consumption data for ${label} in ${mode}_client mode saved to file: ${output_file}  console=True

    memory_consumption.Clear Memory Data  ${${label}_${mode}_client_monitor_id}

Compare memory consumption in Client Mode vs Server Mode
    [Arguments]  ${label}  ${alias}

    Log  Compare memory consumption in Client Mode vs Server Mode for ${label}  console=True
    ${client_stats}=  Set Variable  ${${label}_client_stats}
    ${server_stats}=  Set Variable  ${${label}_server_stats}
    ${server_client_stats}=  Set Variable  ${${label}_server_client_stats}

    ${client_max}=  Set Variable  ${client_stats['max_rss_gb']}
    ${server_max}=  Set Variable  ${server_stats['max_rss_gb']}
    ${server_client_max}=  Set Variable  ${server_client_stats['max_rss_gb']}

    ${server_client_total}=  Evaluate  ${server_max} + ${server_client_max}
    ${treshold}=  Evaluate  (${client_max} + ((${MEMORY_THRESHOLD} / 100) * ${client_max}))

    Log  ${label} Client Mode Max Memory: ${client_max} GB  console=True
    Log  ${label} Server Mode Max Memory: ${server_client_total} GB  console=True
    Log  ${label} Memory consumption max treshold for server: ${treshold} GB  console=True

    IF  ${server_client_total} > ${treshold}
        Fail  ${label} Memory consumption exceeds threshold (${treshold} GB) for ${alias} - exceeds ${MEMORY_THRESHOLD}%
    ELSE
        Log  ${label} Memory consumption is within acceptable range( <${treshold} GB) for alias ${alias} - within ${MEMORY_THRESHOLD}%
        ...  console=True
    END

Check TRM feature settings
    [Arguments]  ${alias}

    ${BTS_TRM_feature_dict_initial}=  Get BTS TRM feature parameters  BTS_SCF_path_file=${${alias.lower()}_scf_initial}  alias=${alias}
    Set Test Variable  ${${alias}_TRM_feature_dict_initial}  ${BTS_TRM_feature_dict_initial}
    Set classical BTS TRM feature parameter  actTempRadioMaster  true  ${alias}
    Set classical BTS TRM feature parameter  tempRadioMasterTriggerTime  ${tempRadioMasterTriggerTime}  ${alias}

Check feature CB015052 behaviour
    [Arguments]  ${alias}

    IF  '${CB015052_CHECK}' == 'True'
        Log  ***** Check feature CB015052 behaviour *****  console=True
        FOR  ${peer_alias}  IN  @{BTS_secondary_controller_shared_RMOD_list}
            IF  '${peer_alias}' == '${alias}' or '${${peer_alias.upper()}}[${peer_alias.upper()}_MODULE_TYPE]' == 'FSMF'  CONTINUE
            Check feature CB015052 behaviour on BTS  ${peer_alias}
        END
    END

Check feature CB015052 behaviour on BTS
    [Arguments]  ${alias}
    Log  Check BTS ${alias} (as secondary controller) feature CB015052 behaviour:  console=True

    ${FID4220_check}=  Run Keyword And Return Status  Get and check detailed IMS2 Alarms SOAM  alias=${alias}
    ...  start_timestamp=${date_timestamp_start_UTC}  skip_check_if_empty_expected_alarms=${False}
    ...  critical_alarms=${test_alarms_list['TRM_ALARMS_4220']}

    IF  not ${FID4220_check}
        Log Long String  BTS ${alias} check feature CB015052 behaviour failed:\n- Found "Radio slave has taken temporary radio master role
        ...  (4220)" alarms  console=True  level=ERROR
        Fail  BTS ${alias} check feature CB015052 behaviour failed
    ELSE
        Log Long String  BTS ${alias} check feature CB015052 behaviour passed:\n- Not found any "Radio slave has taken temporary radio master role
        ...  (4220)" alarms  console=True
    END

Recover TRM feature initial settings
    [Arguments]  ${alias}

    ${actTempRadioMaster_initial}=  Get From Dictionary  ${${alias}_TRM_feature_dict_initial}  actTempRadioMaster
    ${tempRadioMasterTriggerTime_initial}=  Get From Dictionary  ${${alias}_TRM_feature_dict_initial}  tempRadioMasterTriggerTime
    Set classical BTS TRM feature parameter  actTempRadioMaster  ${actTempRadioMaster_initial}  ${alias}
    Set classical BTS TRM feature parameter  tempRadioMasterTriggerTime  ${tempRadioMasterTriggerTime_initial}  ${alias}

Restore Target SW on all BTS
    Log  Restore Target SW on all BTS  console=True
    FOR  ${alias}  IN  @{BTS_alias_list}
        ${BTS_index}=  Get From Dictionary  ${alias_to_BTS_index_dict}  ${alias}
        Get SW versions from all BTS partitions  current
        IF  '${${alias} current active SW}' != '${Target SW BTS${BTS_index}}'
            Perform Restore SWDL on BTS  ${alias}  ${BTS_index}
        END
    END

Restore actCli parameter value on all BTS
    FOR  ${alias}  IN  @{alias_list}
        ${actCli_initial}=  Get Variable Value  ${ACTCLI_INITIAL_${alias}}
        IF  '${actCli_initial}' == 'false'
            rfs_general.Set actCli parameter value  false  ${alias}
        END
        Log  actCli parameter value on BTS ${alias} is restored to ${actCli_initial}  console=True
    END

Perform Restore SWDL on BTS
    [Arguments]  ${alias}  ${BTS_index}

    Log  Restoring Target SW ${Target SW BTS${BTS_index}} on BTS${BTS_index}  console=True

    coam.Update Software  sw_package=${Target SW BTS${BTS_index}}  should_activate=True  timeout=${SW Update Timeout}  connection=${alias}

    ${remote_host_ip}=  Set Variable If  '${alias}' == 'Master'  None  ${${alias.upper()}}[${alias.upper()}_PC_IP_ADDRESS]
    IF  ${${alias.upper()}_EXPECTED_RESET_NUMBER} != 0
        Wait For Target To Be Not Reachable TAF
        ...  hostname=${${alias.upper()}}[${alias.upper()}_TECH_IP_ADDRESS]  timeout=${BTS_MAX_WAIT_TIME}  remote_host=${remote_host_ip}
    END

    Wait For Target To Be Reachable TAF  hostname=${${alias.upper()}}[${alias.upper()}_TECH_IP_ADDRESS]  timeout=${BTS_MAX_WAIT_TIME}
    ...  remote_host=${remote_host_ip}

    Sleep  120s
    Wait Until Keyword Succeeds  3x  10s  Admin reset and Infomodel reconnect sessions  reset_req=True  alias=${alias}  infomodel_reset=False

    Check cells availability status online  ${alias}  ${BTS_MAX_WAIT_TIME}
    Log  All BTS${BTS_index} cell(s) status:\n - operationalState=Enabled  console=True

Particular Teardown
    Export KPI results to File Global  kpi_log_file_name=KpiTimeInfo
    Log  Recover actCli feature initial settings  console=True
    Restore actCli parameter value on all BTS

    IF  '${CB015052_CHECK}' == 'True'
        Log  Recover TRM feature initial settings  console=True
        FOR  ${alias}  IN  @{BTS_secondary_controller_shared_RMOD_list}
            ${TRM_feature_dict_status}=  Run Keyword And Return Status  Variable Should Exist  ${${alias}_TRM_feature_dict_initial}
            IF  not ${TRM_feature_dict_status}  CONTINUE
            Recover TRM feature initial settings  ${alias}
        END
    END

TC Setup
    ${tech_preset_list}=  Create List  SBTS  SBTS  SBTS  SBTS
    Common Test Setup  preset_techs=${tech_preset_list}  common_sbts=${TRUE}  infomodelSetup=${FALSE}  newAlarmsFormat=${TRUE}

TC Teardown
    Common Test Teardown
