*** Settings ***
Documentation    TC__SBTS_SBTS_SBTS_SBTS__SWM__SW_Update_CNI_103974
Variables    tc_variables/sbts_sbts_sbts_sbts__swm__sw_update_cni_103974_alarms_definitions.py
Resource    ../../resources/rfs_frame_rfs_soam_taf.robot

*** Variables ***
${BTS SW Update}               ALL    # BTS list on which to perform SW Update operation. Possible values (by default ALL):
                                      # - ALL: action will be performed on all BTS (reset each BTS until last BTS from TL)
                                      # - list of selected BTS separated by comma labelized as BTSx (x is test_pc number in init.py) (ex. BTS1, BTS3)
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
${Activate SW}                 True   # Activate SW flag; can be True or False
${SW Update Timeout}           3000   # Timeout for SW Update; given in seconds
${BTS_RESET_WRN_THR}           606    # Time (secs) spent between first cell down to last cell up on BTS
                                      # Possible values: (by default in accordance with KPI2a specifications)
                                      # - If ${BTS SW Update} is set to ALL, only one value should be given (ex. 606)
                                      # - list of all kpi thresholds separated by comma for each BTS software update operation is performed on
                                      # (ex. 600, 606).
${BTS_MAX_WAIT_TIME}           900    # Maximum time for wait of ENB OnAir
${BTS_SCF_VALIDATION}          True   # Validate BTS SCF; can be True or False
${FORCE_TARGET_BTS_SW_DL}      False   # Flag used to force download of target BTS build(s) from WFT based on CM tags & selected build from
                                       # CM Single Run form, in order to be used for SW Update on each BTS.
                                       # For this case, variables "WFT_BTS_target_sw" should be default on empty, in order to select target build
                                       # based on CM form and tags. CM tags support also setting of different BTS target build for different BTSs
                                       # (tag: TARGET_BUILD={SW_BUILD_NAME}:{BTS_NUMBER}; Example: TARGET_BUILD=SBTS00_ENB_9999_250219_000019:1)
                                       # In offline running, you can define ENB_BUILD variable in argfile.txt, in order to select target build which
                                       # will be downloaded and used on each BTS or set "WFT_BTS_target_sw" variables, which allow to set explicitly
                                       # which build to download from WFT and use as target on each BTS. These WFT_BTS_target_sw variables have higher
                                       # priority and will override any CM settings.
${WFT_BTS1_target_sw}    # WTF BTS1 target SW name. Possible Values:
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
${RFS_CUSTOM_SHARE_SW_DL}      False   # Flag to enable/disable SW package download from remote location
                                       # - SWs from BuildShareTimi01 can be downloaded locally. Default value is False
${Remote target SW path BTS1}  None    # Path to remote zip file which needs to be downloaded; ex: 3G/WBTS00_0000/WBTS00_0000_3889_00.zip - for BTS1
${Remote target SW path BTS2}  None    # Path to remote zip file which needs to be downloaded; ex: 3G/WBTS00_0000/WBTS00_0000_3889_00.zip - for BTS2
${Remote target SW path BTS3}  None    # Path to remote zip file which needs to be downloaded; ex: 3G/WBTS00_0000/WBTS00_0000_3889_00.zip - for BTS3
${Remote target SW path BTS4}  None    # Path to remote zip file which needs to be downloaded; ex: 3G/WBTS00_0000/WBTS00_0000_3889_00.zip - for BTS4
${TWO_STEP_DOWNLOAD_ACTIVATE}  False   # Flag to enable SW partitions check and unexpected alarms check after download action; can be True, False
${SYNCHRONIZE_ACTIVE_PASSIVE_SW_VERSION}    False  # Flag to copy active software to passive before download action.
                                                   # Default value to False; can be True, False
${HISTORICAL_ALARMS_CHECK}     True   # Flag to enable/disable historical alarms check; Possible values: True, False
${SNAPSHOT_CHECK}              True   # Check if Snapshot contains SCF file before the SW Update and updated SCF after the SW Update;
                                      # Possible values: True, False

*** Keywords ***
TC__SBTS_SBTS_SBTS_SBTS__SWM__SW_Update_CNI_103974
    [Documentation]
    ...  [CASE LINK]: https://jiradc.ext.net.nokia.com/browse/TAT-26609
    ...
    ...  *****************
    ...  Basic information
    ...  *****************
    ...  Test case for BTS SW Update for 2 to 4 SBTS.
    ...  The main steps performed for the test are:
    ...  - check initial state and alarms for all BTS
    ...  - get all BTS info for configured items
    ...  - get target SW for BTS SW Update
    ...  - check feature CB006028 status on all BTS
    ...  - perform SW Update operation on all BTS or choosen BTS
    ...  - check final BTS and RM SW versions from all BTS partitions
    ...  - check reset behavior on all BTS after SW Update from ims file
    ...  - check state and alarms for all BTS after SW Update operation
    ...  Pass criteria: BTS SW Update operation works as expected, states and alarms are as expected
    ...
    ...  ***************************
    ...  History of changes for SOAM
    ...  ***************************
    ...  - 24.01.2024 - https://jiradc.ext.net.nokia.com/browse/TAT-26609 - [5G][CNI-103974]SWM_SW_Update_from_Primary_Controller
    ...  - 22.05.2024 - https://jiradc.ext.net.nokia.com/browse/TAT-27414 -
    ...  [5G] [SCF check] - P0 - SWM -Include SCF walidation with hardware check in all SWM tests
    ...  - 08.07.2024 - https://jiradc.ext.net.nokia.com/browse/TAT-27696 - [5G] [Infomodel] Disable Infomodel in SW Update Test-Cases
    ...  - 19.11.2024 - https://jiradc.ext.net.nokia.com/browse/TAT-28409 - [5G] Add copy active to passive in SBTS_SBTS__SWM__SW_Update_CNI_103974
    ...  - 04.12.2024 - https://jiradc.ext.net.nokia.com/browse/TAT-28486 - SBTS_SBTS__SWM__SW_Update_CNI_103974 to check correctly
    ...  actIndSwUpgradeForSharedRU=true
    ...  - 05.12.2024 - https://jiradc.ext.net.nokia.com/browse/TAT-28455 -
    ...  [5G] Check all RU SW according to Radio protocol in TargetBD SBTS_SBTS__SWM__SW_Update_CNI_103974
    ...  - 14.01.2025 - https://jiradc.ext.net.nokia.com/browse/TAT-28573 - eCPRI -SBTS_SBTS__SWM__SW_update_CNI_103974 wrong timestamp
    ...  - 25.02.2025 - https://jiradc.ext.net.nokia.com/browse/TAT-28764 - [5G] SBTS_SBTS__SWM__SW_Update_CNI_103974 should search in
    ...  TargetBD only for selected BTS for upgrade
    ...  - 25.02.2025 - https://jiradc.ext.net.nokia.com/browse/TAT-28787 - [5G] Adapt SBTS_SBTS__SWM__SW_Update_CNI_103974 to allow FID 4773
    ...  exception while CNI-103974 mechanism is used
    ...  - 04.03.2025 - https://jiradc.ext.net.nokia.com/browse/TAT-27176 - [5G][CNI-103974] Study FHS behavior in context of new CNI checks:
    ...  SBTS_SBTS__SWM__SW_Update_CNI_103974
    ...  - 31.02.2025 - https://jiradc.ext.net.nokia.com/browse/TAT-28859 - SBTS_SBTS__SWM__SW_Update_CNI_103974.robot should check if snapshot
    ...  contains initial scf and final scf
    ...  - 06.05.2025 - https://jiradc.ext.net.nokia.com/browse/TAT-29127 -
    ...  Some expected alarms were not found: [{'alarmId': '7116', 'faultId': '16 in the test [1]SBTS_SBTS__SWM__SW_Update_CNI_103974
    ...  - 20.05.2025 - https://jiradc.ext.net.nokia.com/browse/TAT-29242 - OBSAI radios should not expect FID 4773
    ...  - 23.06.2025 - https://jiradc.ext.net.nokia.com/browse/TAT-29374 - Support more than 2 x SBTS in SBTS_SBTS__SWM__SW_Update_CNI_103974
    ...  - 02.07.2025 - https://jiradc.ext.net.nokia.com/browse/TAT-27609 - SWM__SW_Update robots to do SWDL with different SW on multiple BTS
    ...  - 04.08.2025 - https://jiradc.ext.net.nokia.com/browse/TAT-28860 - Robot should check the additional information of fault 4592
    ...  - 13.08.2025 - https://jiradc.ext.net.nokia.com/browse/TAT-29592 -
    ...  [5G] System upgrade is failed if rfs version in trunk is older than rfs version on branch
    ...  - 24.09.2025 - https://jiradc.ext.net.nokia.com/browse/TAT-29819 - SBTS_SBTS_SBTS_SBTS__SWM__SW_Update_CNI_103974.robot should never set
    ...  status as 'failed' depending on FID4592
    ...
    ...  *******************
    ...  Test case flowchart
    ...  *******************
    ...  .. image:: https://gitlabe1.ext.net.nokia.com/panda-docs/hran_doc/-/blob/master/testsuite/RFS_SOAM/
    ...  TAT-26609_SBTS_SBTS__SWM__SW_Update_CNI_103974.png
    ...

    Set Tags    CA-SWM    OWNER-dan.popescu@nokia.com    AUTHOR-anca.tatar@nokia.com    PHASE-QT    SW-SBTS24R2

    TC Preconditions
    Check threshold list
    Step 1: Check initial all BTS state
    Step 2: Check initial all BTS alarms
    Step 3: Get all BTS info for configured items
    Step 4: Get Target SW for BTS SW Update
    Step 5: Check feature CB006028 status on all BTS
    Step 6: Perform BTS SW Update
    Step 7: Check final all BTS state
    Step 8: Check final all BTS alarms
    Step 9: Check final number and state of Cells and RMs
    Step 10: Check Historic Alarms

TC Preconditions
    ${BTS_alias_label_dict}  ${BTS_label_alias_dict}=  Get BTS alias label info dict
    Set Test Variable  ${BTS_alias_label_dict}
    Set Test Variable  ${BTS_label_alias_dict}
    ${BTS_alias_list}=  Get Dictionary Keys  ${BTS_alias_label_dict}  False
    ${BTS_label_list}=  Get Dictionary Values  ${BTS_alias_label_dict}  False
    Set Test Variable  ${BTS_alias_list}
    Set Test Variable  ${BTS_label_list}

    Run Keyword If  '${BTS SW Update}' != 'ALL'  Check BTS list
    Log  ====================================================  console=True
    Log  BTS label selected for BTS SW Update: ${BTS_label_list}  console=True
    Log  BTS alias selected for BTS SW Update: ${BTS_alias_list}  console=True
    Log  ====================================================  console=True

Check BTS list
    ${BTS_SW_Update_strip}=  Replace String  ${BTS SW Update}  ${SPACE}  ${EMPTY}
    ${BTS_SW_Update}=  Split String  ${BTS_SW_Update_strip}  ,
    ${BTS_check}=  Set Variable  True
    ${BTS_invalid_label_list}=  Create List
    ${BTS_request_label_list}=  Create List
    ${BTS_request_alias_list}=  Create List

    FOR  ${item}  IN  @{BTS_SW_Update}
        ${BTS_check}=  Set Variable If  '${item}' not in ${BTS_label_list}  False  ${BTS_check}
        Run Keyword If  '${item}' not in ${BTS_label_list}
        ...  Append To List  ${BTS_invalid_label_list}  ${item}
        ...  ELSE
        ...  Append To List  ${BTS_request_label_list}  ${item}
    END

    Run Keyword If  '${BTS_check}' == 'False'  Run Keywords
    ...  Log Long String  Following selected BTS are not valid: ${BTS_invalid_label_list}. Please select values for test argument
    ...  \${BTS SW Update} from configured BTS: ${BTS_label_list} or let default value: ALL  console=True
    ...  AND  Fail  Improper value for argument!

    FOR  ${item}  IN  @{BTS_request_label_list}
        ${BTS_request_alias}=  Get From Dictionary  ${BTS_label_alias_dict}  ${item}
        Append To List  ${BTS_request_alias_list}  ${BTS_request_alias}
    END

    Set Test Variable  ${BTS_label_list}  ${BTS_request_label_list}
    Set Test Variable  ${BTS_alias_list}  ${BTS_request_alias_list}

Step ${index}: Check ${when} all BTS state
    [Documentation]
    ...  SBTS state is checked according to Admin for BTS and each configured RAT

    [Timeout]  15 min
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
    ...  from admin

    [Timeout]  15 min
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
    ...  - list of shared RM serial number configured on BTS primary controller (per BTS alias)
    ...  - list of shared RM serial number configured on BTS secondary controller (per BTS alias)

    Log  Step ${index}: Get all BTS info for configured items  console=True

    ${alias_to_BTS_index_dict}=  Create Dictionary  Master=1  Slave=2  Slave1=3  Slave2=4
    Set Test Variable  ${alias_to_BTS_index_dict}

    ${RM_sn_bts-alias_dict}  ${shared_RM_sn_list}  ${dedicated_RM_sn_list}=  Admin Get RM sn bts-alias info dict
    Set Test Variable  ${RM_sn_bts-alias_dict}
    Set Test Variable  ${shared_RM_sn_list}
    Set Test Variable  ${dedicated_RM_sn_list}

    FOR  ${alias}  IN  @{alias_list}
        ${BTS_primary_controller_shared_RM_sn_list}  ${BTS_secondary_controller_shared_RM_sn_list}=
        ...  Get BTS controller role shared RM SN list from SCF  ${shared_RM_sn_list}  ${alias}
        Set Test Variable  ${${alias}_BTS_primary_controller_shared_RM_sn_list}  ${BTS_primary_controller_shared_RM_sn_list}
        Set Test Variable  ${${alias}_BTS_secondary_controller_shared_RM_sn_list}  ${BTS_secondary_controller_shared_RM_sn_list}

        ${BTS_shared_RM_sn_list}=  Combine Lists  ${BTS_primary_controller_shared_RM_sn_list}  ${BTS_secondary_controller_shared_RM_sn_list}
        Set Test Variable  ${${alias}_BTS_shared_RM_sn_list}  ${BTS_shared_RM_sn_list}

        ${BTS_dedicated_RM_sn_list}=  Get dedicated RMOD list   ${dedicated_RM_sn_list}  ${alias}
        Set Test Variable  ${${alias}_BTS_dedicated_RM_sn_list}  ${BTS_dedicated_RM_sn_list}

        ${BTS_FHS_alias_connection_dict}  ${BTS_shared_FHS_id_sn_dict}  ${BTS_dedicated_FHS_id_sn_dict}  ${BTS_shared_FHS_sn_id_dict}
        ...  ${BTS_dedicated_FHS_sn_id_dict}=  Admin Get shared and dedicated module info for BTS  FHS  ${alias}
        Set Test Variable  ${${alias}_shared_FHS_id_sn_dict}  ${BTS_shared_FHS_id_sn_dict}
    END

    FOR  ${RM_sn}  IN  @{shared_RM_sn_list}
        ${RM_bts-alias_list}=  Get From Dictionary  ${RM_sn_bts-alias_dict}  ${RM_sn}
        Get shared RM info  ${RM_sn}  ${RM_bts-alias_list}
    END

Step ${index}: Get Target SW for BTS SW Update
    Log  Step ${index}: Get Target SW for BTS SW Update  console=True

    Run Keyword If  '${SYNCHRONIZE_ACTIVE_PASSIVE_SW_VERSION}' == 'True'  Synchronize active and pasive SW versions

    FOR  ${alias}  IN  @{alias_list}

        Continue For Loop If  '${alias}' not in ${BTS_alias_list}
        ${BTS_index}=  Get From Dictionary  ${alias_to_BTS_index_dict}  ${alias}
        ${decoupling_build}=  tools.Get Bts Decoupling Build  bts_label=BTS${BTS_index}  decoupling_tag=TARGET_BUILD

        ${preloaded_package}=  Set Variable If  '${FORCE_TARGET_BTS_SW_DL}' != 'True'  ${EMPTY}
        ...  '${WFT_BTS${BTS_index}_target_sw}' != '${EMPTY}'  ${WFT_BTS${BTS_index}_target_sw}
        ...  '${decoupling_build}' != '${EMPTY}'  ${decoupling_build}
        ...  ${EMPTY}

        Run Keyword If  '${FORCE_TARGET_BTS_SW_DL}' == 'True'  Run Keywords
        ...  Download And Set Current SW for SWDL  Target_SW_dir=${Target SW dir BTS${BTS_index}}  preloaded_package=${preloaded_package}
        ...  AND  Set Test Variable  ${Target SW BTS${BTS_index}}  ${Target SW}
        ...  AND  Check if SW version already exists on BTS  ${alias}
        ...  AND  Set Test Variable  ${Target SW name BTS${BTS_index}}  ${Target Package Name}
        ...  AND  Continue For Loop

        ${Target SW tmp}=  Run Keyword If  '${RFS_CUSTOM_SHARE_SW_DL}'!='True'
        ...  Get SW file for SWDL  ${Target SW dir BTS${BTS_index}}  ${Target SW name BTS${BTS_index}}
        Run Keyword If  '${RFS_CUSTOM_SHARE_SW_DL}'=='True'  Run Keywords
        ...  Log  SW package for BTS ${alias} will be downloaded from remote server  console=True
        ...  AND  SFTP Download SW from remote server and rename  ${Remote target SW path BTS${BTS_index}}  ${alias}
        ...  ELSE  Rename Software Package  ${Target SW tmp}
        Set Test Variable  ${Target SW BTS${BTS_index}}  ${Target SW}
        Log  Target SW for BTS ${alias} SW Update: ${Target SW}  console=True
        Check if SW version already exists on BTS  ${alias}
        ${target_sw_path}  ${target_sw_file}=  Split Path  ${Target SW}
        ${target_sw_name}  ${ext}=  Split Extension  ${target_sw_file}
        ${qc_target_sw}=  Convert To Uppercase  ${target_sw_name}
        Set Qc Parameter  qc_tc_swbuild  ${qc_target_sw}; ${QC ${alias} Active SW}
        Set Test Variable  ${Target SW name BTS${BTS_index}}  ${Target SW name}

    END

Step ${index}: Check feature CB006028 status on all BTS

    Log  Step ${index}: Check feature CB006028 status on all BTS  console=True
    ${shared_RM_sn_actIndSwUpgradeForSharedRU_true_list}=  Create List

    FOR  ${RM_sn}  IN  @{shared_RM_sn_list}
        ${RM_bts-alias_list}=  Get From Dictionary  ${RM_sn_bts-alias_dict}  ${RM_sn}
        ${RM_sn_actIndSwUpgradeForSharedRU_status}=  Check feature CB006028 status  ${RM_sn}  ${RM_bts-alias_list}
        Run Keyword If  ${RM_sn_actIndSwUpgradeForSharedRU_status}  Append To List  ${shared_RM_sn_actIndSwUpgradeForSharedRU_true_list}  ${RM_sn}
    END
    Set Test Variable  ${shared_RM_sn_actIndSwUpgradeForSharedRU_true_list}

    FOR  ${alias}  IN  @{alias_list}
        ${BTS_primary_controller_CB006028_true_list}=  Get BTS controller shared RM SN list with feature CB006028 activated
        ...  ${${alias}_BTS_primary_controller_shared_RM_sn_list}
        ${BTS_secondary_controller_CB006028_true_list}=  Get BTS controller shared RM SN list with feature CB006028 activated
        ...  ${${alias}_BTS_secondary_controller_shared_RM_sn_list}
        Set Test Variable  ${${alias}_BTS_primary_controller_shared_RM_sn_CB006028_true_list}  ${BTS_primary_controller_CB006028_true_list}
        Set Test Variable  ${${alias}_BTS_secondary_controller_shared_RM_sn_CB006028_true_list}  ${BTS_secondary_controller_CB006028_true_list}
    END

Step ${index}: Perform BTS SW Update
    [Documentation]
    ...  Perform SW Update on BTS

    Log  Step ${index}: Perform BTS SW Update  console=True
    FOR  ${alias}  IN  @{BTS_alias_list}
        Continue For Loop If  '${alias}' not in ${BTS_alias_list}
        Log  ==================================================  console=True
        Log  ***** Test will perform BTS ${alias} SW Update *****  console=True
        Log  ==================================================  console=True
        ${BTS_index}=  Get From Dictionary  ${alias_to_BTS_index_dict}  ${alias}
        Set Target BD xml file  ${Target SW BTS${BTS_index}}
        Get BTS SW versions on all BTS  initial
        Get RM SW versions on all BTS  initial
        Get and Check RM SW versions from BTS Target SW version
        Get shared RM impact on peer BTS  ${alias}
        BTS SW Update  ${alias}
        Get BTS SW versions on all BTS  final
        Get RM SW versions on all BTS  final
        Check BTS and RM SW versions from BTS partitions after BTS SW Update  ${alias}
        Check BTS reset behavior based on IMS info after BTS SW Update  ${alias}
    END

Step ${index}: Check final number and state of Cells and RMs
    [Documentation]
    ...  Cells state is checked according to operationalState attribute
    ...  Check if number of configured cells and radio modules in SCF are properly mapping on BTS running view.
    ...  Also check RMs operationalState

    [Timeout]  30 min
    Log  Step ${index}: Check final number and state of Cells and RMs  console=True
    Run Keyword If  ${SNAPSHOT_CHECK}  Check SCF files from Snapshot
    RFS Test Case Final Checks

Step ${index}: Check Historic Alarms
    [Documentation]
    ...  check historic alarms for BBMOD autoreset
    ...  no historic autoreset alarm expected
    ...  Otherwise, BBMOD reset behavior not as expected, then errors are added to report and failed

    Run Keyword If  ${HISTORICAL_ALARMS_CHECK}==False  Run Keywords
    ...  Log  Historical Alarms Check will be skipped.  console=True
    ...  AND  Return From Keyword
    Log  Step ${index}: Check NR and LTE Historic alarms  console=True

    FOR  ${alias_item}  IN  @{alias_list}

        ${IGNORED_HISTORICAL_ALARMS}=  Combine Lists  ${${alias_item.upper()}_IGNORED_ALARMS}
        ...  ${${alias_item.upper()}_IGNORED_ALARMS_DURING_RESET}

        Eval Historic Alarms  connection=${alias_item}    expected_alarms=@{EMPTY}  ignored_alarms=${IGNORED_HISTORICAL_ALARMS}
        ...  critical_alarms=${${alias_item.upper()}_CRITICAL_ALARMS}  ignore_unexpected=False

    END

    FOR  ${alias}  IN  @{alias_list}
        ${BTS_index}=  Get From Dictionary  ${alias_to_BTS_index_dict}  ${alias}
        Continue For Loop If    '${BTS SW Update}'!='ALL' and 'BTS${BTS_index}' not in '${BTS SW Update}'
        Check specific reset cause alarm from IMS  ${alias}
    END

Check specific reset cause alarm from IMS
    [Arguments]  ${alias}

    Log  Expecting alarm BTS Reset Cause (4592) with additional info: software reset on BTS ${alias}  console=True

    ${found_expected_ims2_alarms_tmp}=  Create List
    ${not_found_expected_ims2_alarms_tmp}=  Create List
    Set Test Variable  ${found_expected_ims2_alarms}  ${found_expected_ims2_alarms_tmp}
    Set Test Variable  ${not_found_expected_ims2_alarms}  ${not_found_expected_ims2_alarms_tmp}

    ${status}=  Run Keyword And Return Status  Wait Until Keyword Succeeds  6 min  5 s  Check FID 4592 expected alarm
    ...  ${alias}

    ${found_expected_ims2_alarms_len}=  Get Length  ${found_expected_ims2_alarms}

    Run Keyword If  ${found_expected_ims2_alarms_len} == 0  Run Keywords
    ...  Log  BTS Reset Cause (4592) not found on BTS ${alias}!  level=WARN
    ...  AND  Return From Keyword

    Run Keyword If  ${found_expected_ims2_alarms_len} > 1
    ...  Fail  FID "BTS Reset Cause (4592)", found but more than once, please check logs: ${found_expected_ims2_alarms}!

    ${alarm_dict}=  Get From List  ${found_expected_ims2_alarms}  0
    ${supplAlarmInfo}=  Get From Dictionary  ${alarm_dict}  supplAlarmInfo
    ${reset_cause_sw_reset}=  Set Variable If  'software reset' in '${supplAlarmInfo.lower()}'  ${TRUE}
    ...  ${FALSE}

    Run Keyword If  not ${reset_cause_sw_reset}  Log  BTS Reset cause not as expected! Expected: software reset, got: ${supplAlarmInfo}!  level=WARN
    ...  ELSE  Log  Checking BTS Reset Cause (4592) successful on BTS ${alias}! Reset cause: ${supplAlarmInfo}  console=True

Check FID 4592 expected alarm
    [Arguments]  ${alias}

    Get Current Date UTC info  end_SWUpdate_reset_reason_check
    Set Test Variable    ${BTS_${alias}_end_SWUpdate_reset_reason_check}  ${date_timestamp_end_SWUpdate_reset_reason_check_UTC}
    ${ims_file_path}=  Admin Collect IMS file with timestamp  folder_path=${Test Results Dir}/IMS/${alias}  alias=${alias}
    ${found_expected_ims2_alarms_tmp}  ${not_found_expected_ims2_alarms_tmp}=  ims2alarms.Get Expected Alarms
    ...  file_path=${ims_file_path}  alarms=${${alias.upper()}_EXPECTED_ALARMS_4592}  begin=${BTS_${alias}_start_SWUpdate}
    ...  end=${BTS_${alias}_end_SWUpdate_reset_reason_check}

    Run Keyword If  not ${found_expected_ims2_alarms_tmp}  Run Keywords
    ...  Log  BTS Reset Cause (4592) not found, IMS file will be removed and retry after  console=True
    ...  AND  Remove File  ${ims_file_path}
    ...  AND  Fail  BTS ${alias} "BTS Reset Cause (4592)" alarm, not found!

    Set Test Variable  ${found_expected_ims2_alarms}  ${found_expected_ims2_alarms_tmp}
    Set Test Variable  ${not_found_expected_ims2_alarms}  ${not_found_expected_ims2_alarms_tmp}

Get dedicated RMOD list
    [Arguments]  ${dedicated_RM_sn_list}  ${alias}

    ${BTS_dedicated_RM_sn_list}=  Create List
    FOR  ${RMOD_sn}  IN  @{dedicated_RM_sn_list}
        ${RM_bts-alias_list}=  Get From Dictionary  ${RM_sn_bts-alias_dict}  ${RMOD_sn}
        Run Keyword If  '${alias}' in ${RM_bts-alias_list}
        ...  Append To List  ${BTS_dedicated_RM_sn_list}  ${RMOD_sn}
    END

    [Return]  ${BTS_dedicated_RM_sn_list}

Get shared RM info
    [Arguments]  ${RM_sn}  ${RM_bts-alias_list}

    Log  Shared RM with SN ${RM_sn} info:  console=True
    FOR  ${alias}  IN  @{RM_bts-alias_list}
        ${RM_id}=  Get From Dictionary  ${${alias}_RM_sn_id_dict}  ${RM_sn}
        ${BTS_role}=  Set Variable If  '${RM_sn}' in ${${alias}_BTS_primary_controller_shared_RM_sn_list}  Primary Controller
        ...  '${RM_sn}' in ${${alias}_BTS_secondary_controller_shared_RM_sn_list}  Secondary Controller
        Log  - BTS ${alias} role: ${BTS_role} -> RM id: ${RM_id}  console=True
    END

Check if SW version already exists on BTS
    [Arguments]  ${alias}
    ${BTS_index}=  Get From Dictionary  ${alias_to_BTS_index_dict}  ${alias}
    Check if SW already exists on BTS  ${Target SW BTS${BTS_index}}  ${${alias} active SW}  ${${alias} passive SW}

Set Target BD xml file
    [Arguments]  ${Target SW}
    FOR  ${alias}  IN  @{alias_list}
        ${TargetBD_xml}=  Get TargetBD File From SW Package  ${Target SW}
        Set Test Variable  ${${alias}_TargetBD_xml_file}  ${TargetBD_xml}
    END

Check feature CB006028 status
    [Arguments]  ${RM_sn}  ${RM_bts-alias_list}

    ${RM_sn_actIndSwUpgradeForSharedRU_status_list}=  Create List
    FOR  ${alias}  IN  @{RM_bts-alias_list}
        ${RM_id}=  Get From Dictionary  ${${alias}_RM_sn_id_dict}  ${RM_sn}
        ${actIndSwUpgradeForSharedRU}=  Get actIndSwUpgradeForSharedRU parameter value  ${RM_id}  ${alias}
        Append To List  ${RM_sn_actIndSwUpgradeForSharedRU_status_list}  ${actIndSwUpgradeForSharedRU}
    END
    ${RM_sn_actIndSwUpgradeForSharedRU_status}=
    ...  Set Variable If  'false' in ${RM_sn_actIndSwUpgradeForSharedRU_status_list} or 'none' in ${RM_sn_actIndSwUpgradeForSharedRU_status_list}
    ...  False  True

    Log  Shared RM with SN ${RM_sn} feature CB006028 status:  console=True
    Log  - parameter actIndSwUpgradeForSharedRU = ${RM_sn_actIndSwUpgradeForSharedRU_status}  console=True

    [Return]  ${RM_sn_actIndSwUpgradeForSharedRU_status}

Get BTS SW versions on all BTS
    [Arguments]  ${when}

    Log  Get ${when} BTS SW versions on all BTS  console=True
    FOR  ${alias}  IN  @{alias_list}
        Admin Get BTS SW Version  alias=${alias}
        Set Test Variable  ${${alias} ${when} active SW}  ${${alias} active SW}
        Set Test Variable  ${${alias} ${when} passive SW}  ${${alias} passive SW}
    END

Get RM SW versions on all BTS
    [Arguments]  ${when}

     Log  Get ${when} RM SW versions on all BTS  console=True
     FOR  ${alias}  IN  @{alias_list}
         Get RM SW info dict on BTS  ${alias}  ${when}
     END

Get RM SW info dict on BTS
    [Arguments]  ${alias}  ${when}

    ${RMOD_serialNumber_buildVersion_dict}  ${RMOD_serialNumber_buildTimestamp_dict}  ${RMOD_serialNumber_productName_dict}
    ...  ${RMOD_serialNumber_l3Protocol_dict}=  Get BTS running RMOD SW info dict  ${alias}
    Set Test Variable  ${${alias}_${when}_RMOD_serialNumber_buildVersion_dict}  ${RMOD_serialNumber_buildVersion_dict}
    Set Test Variable  ${${alias}_${when}_RMOD_serialNumber_buildTimestamp_dict}  ${RMOD_serialNumber_buildTimestamp_dict}
    Set Test Variable  ${${alias}_RMOD_serialNumber_productName_dict}  ${RMOD_serialNumber_productName_dict}
    Set Test Variable  ${${alias}_RMOD_serialNumber_l3Protocol_dict}  ${RMOD_serialNumber_l3Protocol_dict}

    ${RMOD_serialNumber_list}=  Get Dictionary Keys  ${RMOD_serialNumber_buildVersion_dict}
    Sort List  ${RMOD_serialNumber_list}
    Set Test Variable  ${${alias}_RMOD_serialNumber_list}  ${RMOD_serialNumber_list}

    Log  Running BTS ${alias} ${when} RM SW info:  console=True
    FOR  ${RM_sn}  IN  @{RMOD_serialNumber_list}

        ${RM_productName}=  Get From Dictionary  ${RMOD_serialNumber_productName_dict}  ${RM_sn}
        ${RM_l3Protocol}=  Get From Dictionary  ${RMOD_serialNumber_l3Protocol_dict}  ${RM_sn}
        ${RM_buildVersion}=  Get From Dictionary  ${RMOD_serialNumber_buildVersion_dict}  ${RM_sn}
        Log  - RM ${RM_productName} with SN ${RM_sn} (${RM_l3Protocol}) buildVersion: ${RM_buildVersion}  console=True
        ${RM_buildTimestamp}=  Get From Dictionary  ${RMOD_serialNumber_buildTimestamp_dict}  ${RM_sn}
        Log  - RM ${RM_productName} with SN ${RM_sn} (${RM_l3Protocol}) buildTimestamp: ${RM_buildTimestamp}  console=True

    END

Get and Check RM SW versions from BTS Target SW version
     [Documentation]
     ...  Get and Check RM SW versions from BTS Target SW version

     Log  Get and Check RM SW versions from BTS Target SW version  console=True
     FOR  ${alias}  IN   @{alias_list}

         Get RM SW versions from BTS Target SW version  ${alias}  shared
         Run Keyword If  '${alias}' in ${BTS_alias_list}  Get RM SW versions from BTS Target SW version  ${alias}  dedicated

         ${target_RMOD_serialNumber_buildVersion_dict}=  Run Keyword If  '${alias}' in ${BTS_alias_list}
         ...  Create Dictionary  &{${alias}_target_shared_RMOD_serialNumber_buildVersion_dict}
         ...  &{${alias}_target_dedicated_RMOD_serialNumber_buildVersion_dict}
         ...  ELSE  Set Variable  ${${alias}_target_shared_RMOD_serialNumber_buildVersion_dict}

         ${target_RMOD_serialNumber_buildTimestamp_dict}=  Run Keyword If  '${alias}' in ${BTS_alias_list}
         ...  Create Dictionary  &{${alias}_target_shared_RMOD_serialNumber_buildTimestamp_dict}
         ...  &{${alias}_target_dedicated_RMOD_serialNumber_buildTimestamp_dict}
         ...  ELSE  Set Variable  ${${alias}_target_shared_RMOD_serialNumber_buildTimestamp_dict}

         Set Test Variable  ${${alias}_target_RMOD_serialNumber_buildVersion_dict}  ${target_RMOD_serialNumber_buildVersion_dict}
         Set Test Variable  ${${alias}_target_RMOD_serialNumber_buildTimestamp_dict}  ${target_RMOD_serialNumber_buildTimestamp_dict}

         Check RM SW versions from BTS Target SW version  ${alias}  shared
         Run Keyword If  '${alias}' in ${BTS_alias_list}  Check RM SW versions from BTS Target SW version  ${alias}  dedicated

         ${RM_sn_newer_SW_buildVersion_list}=  Run Keyword If  '${alias}' in ${BTS_alias_list}
         ...  Combine Lists  ${${alias}_shared_RM_sn_newer_SW_buildVersion_list}  ${${alias}_dedicated_RM_sn_newer_SW_buildVersion_list}
         ...  ELSE  Set Variable  ${${alias}_shared_RM_sn_newer_SW_buildVersion_list}

         Set Test Variable  ${${alias}_RM_sn_newer_SW_buildVersion_list}  ${RM_sn_newer_SW_buildVersion_list}

     END

Get RM SW versions from BTS Target SW version
    [Arguments]  ${alias}  ${RM_type}

    ${target_RMOD_serialNumber_buildVersion_dict}=  Create Dictionary
    ${target_RMOD_serialNumber_buildTimestamp_dict}=  Create Dictionary

    Log  Target BTS ${alias} RM SW info:  console=True
    FOR  ${RM_sn}  IN  @{${alias}_RMOD_serialNumber_list}

        Run Keyword If  '${RM_type}' == 'shared' and '${RM_sn}' not in ${${alias}_BTS_shared_RM_sn_list}
        ...  Continue For Loop
        ...  ELSE IF  '${RM_type}' == 'dedicated' and '${RM_sn}' not in ${${alias}_BTS_dedicated_RM_sn_list}
        ...  Continue For Loop

        ${RM_productName}=  Get From Dictionary  ${${alias}_RMOD_serialNumber_productName_dict}  ${RM_sn}
        ${RM_l3Protocol}=  Get From Dictionary  ${${alias}_RMOD_serialNumber_l3Protocol_dict}  ${RM_sn}

        ${resourceBuildKey_resourceSWVersion_dict}  ${resourceBuildKey_buildTimestamp_dict}=  Get TargetBD RMOD SW info dict
        ...  ${${alias}_TargetBD_xml_file}  ${RM_productName}

        ${RM_resourceSWVersion_list}=  Get Dictionary Values  ${resourceBuildKey_resourceSWVersion_dict}  False
        ${RM_resourceSWVersion_count}=  Get Length  ${RM_resourceSWVersion_list}
        ${RM_resourceSWVersion}=  Run Keyword If  ${RM_resourceSWVersion_count} == 1
        ...  Get From List  ${RM_resourceSWVersion_list}  0
        ...  ELSE IF  ${RM_resourceSWVersion_count} > 1 and '${RM_l3Protocol}' == 'ECPRI_MPLANE'
        ...  Get From Dictionary  ${resourceBuildKey_resourceSWVersion_dict}  LTX_${RM_productName}_E1
        ...  ELSE
        ...  Get From Dictionary  ${resourceBuildKey_resourceSWVersion_dict}  LTX_${RM_productName}
        Log  - RM ${RM_productName} with SN ${RM_sn} (${RM_l3Protocol}) buildVersion: ${RM_resourceSWVersion}  console=True
        Set To Dictionary  ${target_RMOD_serialNumber_buildVersion_dict}  ${RM_sn}  ${RM_resourceSWVersion}

        ${RM_buildTimestamp_list}=  Get Dictionary Values  ${resourceBuildKey_buildTimestamp_dict}  False
        ${RM_buildTimestamp_count}=  Get Length  ${RM_buildTimestamp_list}
        ${RM_buildTimestamp}=  Run Keyword If  ${RM_buildTimestamp_count} == 1
        ...  Get From List  ${RM_buildTimestamp_list}  0
        ...  ELSE IF  ${RM_buildTimestamp_count} > 1 and '${RM_l3Protocol}' == 'ECPRI_MPLANE'
        ...  Get From Dictionary  ${resourceBuildKey_buildTimestamp_dict}  LTX_${RM_productName}_E1
        ...  ELSE
        ...  Get From Dictionary  ${resourceBuildKey_buildTimestamp_dict}  LTX_${RM_productName}
        Log  - RM ${RM_productName} with SN ${RM_sn} (${RM_l3Protocol}) buildTimestamp: ${RM_buildTimestamp}  console=True
        Set To Dictionary  ${target_RMOD_serialNumber_buildTimestamp_dict}  ${RM_sn}  ${RM_buildTimestamp}

    END

    Set Test Variable  ${${alias}_target_${RM_type}_RMOD_serialNumber_buildVersion_dict}  ${target_RMOD_serialNumber_buildVersion_dict}
    Set Test Variable  ${${alias}_target_${RM_type}_RMOD_serialNumber_buildTimestamp_dict}  ${target_RMOD_serialNumber_buildTimestamp_dict}

Check RM SW versions from BTS Target SW version
    [Arguments]  ${alias}  ${RM_type}

    ${RM_sn_newer_SW_buildVersion_list}=  Create List

    FOR  ${RM_sn}  IN  @{${alias}_RMOD_serialNumber_list}

        Run Keyword If  '${RM_type}' == 'shared' and '${RM_sn}' not in ${${alias}_BTS_shared_RM_sn_list}
        ...  Continue For Loop
        ...  ELSE IF  '${RM_type}' == 'dedicated' and '${RM_sn}' not in ${${alias}_BTS_dedicated_RM_sn_list}
        ...  Continue For Loop

        ${newer_RM_SW_buildVersion_found}=  Compare RM SW info  ${alias}  ${RM_sn}
        Run Keyword If  ${newer_RM_SW_buildVersion_found}  Append To List  ${RM_sn_newer_SW_buildVersion_list}  ${RM_sn}

    END

    Set Test Variable  ${${alias}_${RM_type}_RM_sn_newer_SW_buildVersion_list}  ${RM_sn_newer_SW_buildVersion_list}

Compare RM SW info
    [Arguments]  ${alias}  ${RM_sn}

    ${running_RM_buildVersion}=  Get From Dictionary  ${${alias}_initial_RMOD_serialNumber_buildVersion_dict}  ${RM_sn}
    ${target_RM_buildVersion}=  Get From Dictionary  ${${alias}_target_RMOD_serialNumber_buildVersion_dict}  ${RM_sn}

    Return From Keyword If  '${target_RM_buildVersion}' == '${running_RM_buildVersion}'  ${False}

    ${running_RM_buildTimestamp}=  Get From Dictionary  ${${alias}_initial_RMOD_serialNumber_buildTimestamp_dict}  ${RM_sn}
    ${target_RM_buildTimestamp}=  Get From Dictionary  ${${alias}_target_RMOD_serialNumber_buildTimestamp_dict}  ${RM_sn}

    ${Newer_buildVersion}=  Compare and parse RMOD buildVersion and buildTimestamp from TargetBD and BTS
    ...  ${target_RM_buildVersion}  ${running_RM_buildVersion}  ${target_RM_buildTimestamp}  ${running_RM_buildTimestamp}

    ${newer_RM_SW_buildVersion_found}=  Set Variable If  '${target_RM_buildVersion}' == '${Newer_buildVersion}'  ${True}  ${False}

    [Return]  ${newer_RM_SW_buildVersion_found}

Get BTS controller shared RM SN list with feature CB006028 activated
    [Arguments]  ${BTS_controller_shared_RM_sn_list}

    ${BTS_controller_shared_RM_sn_CB006028_true_list}=  Create List

    FOR  ${RM_sn}  IN  @{BTS_controller_shared_RM_sn_list}
        Run Keyword If  '${RM_sn}' in ${shared_RM_sn_actIndSwUpgradeForSharedRU_true_list}
        ...  Append To List  ${BTS_controller_shared_RM_sn_CB006028_true_list}  ${RM_sn}
    END

    [Return]  ${BTS_controller_shared_RM_sn_CB006028_true_list}

Get shared RM impact on peer BTS
    [Arguments]  ${alias}

    Log  Get shared RM impact on peer BTS   console=True

    ${all_BTS_PL_shared_RM_info}=  Get PL shared RM info on all BTS
    ${BTS_PL_shared_RM_info}=  Get From Dictionary  ${all_BTS_PL_shared_RM_info}  ${alias}
    ${BTS_PL_CPRI_shared_RM_sn_list}=  Get From Dictionary  ${BTS_PL_shared_RM_info}  BTS_PL_CPRI_shared_RM_sn_list
    ${BTS_PL_ECPRI_shared_RM_sn_list}=  Get From Dictionary  ${BTS_PL_shared_RM_info}  BTS_PL_ECPRI_shared_RM_sn_list
    ${BTS_PL_OBSAI_shared_RM_sn_list}=  Get From Dictionary  ${BTS_PL_shared_RM_info}  BTS_PL_OBSAI_shared_RM_sn_list

    ${BTS_primary_controller_new_RM_SW_list}  ${BTS_secondary_controller_new_RM_SW_list}=  Get BTS new RM SW alarm list  ${alias}
    ${BTS_new_RM_SW_list}=  Combine Lists  ${BTS_primary_controller_new_RM_SW_list}  ${BTS_secondary_controller_new_RM_SW_list}
    Set Test Variable  ${${alias}_final_new_RM_SW_sn_list}  ${BTS_new_RM_SW_list}

    FOR  ${other_alias}  IN  @{alias_list}
        Continue For Loop If  '${other_alias}' == '${alias}'
        ${other_BTS_PL_shared_RM_info}=  Get From Dictionary  ${all_BTS_PL_shared_RM_info}  ${other_alias}
        ${other_BTS_non_PL_CPRI_shared_RM_sn_list}=  Get From Dictionary  ${other_BTS_PL_shared_RM_info}  BTS_non_PL_CPRI_shared_RM_sn_list
        ${other_BTS_non_PL_CPRI_shared_RM_sn_list}=
        ...  Evaluate  list(set(${other_BTS_non_PL_CPRI_shared_RM_sn_list}) & set(${${alias}_BTS_shared_RM_sn_list}))
        ${other_BTS_non_PL_ECPRI_shared_RM_sn_list}=  Get From Dictionary  ${other_BTS_PL_shared_RM_info}  BTS_non_PL_ECPRI_shared_RM_sn_list
        ${other_BTS_non_PL_ECPRI_shared_RM_sn_list}=
        ...  Evaluate  list(set(${other_BTS_non_PL_ECPRI_shared_RM_sn_list}) & set(${${alias}_BTS_shared_RM_sn_list}))
        ${other_BTS_non_PL_OBSAI_shared_RM_sn_list}=  Get From Dictionary  ${other_BTS_PL_shared_RM_info}  BTS_non_PL_OBSAI_shared_RM_sn_list
        ${other_BTS_non_PL_OBSAI_shared_RM_sn_list}=
        ...  Evaluate  list(set(${other_BTS_non_PL_OBSAI_shared_RM_sn_list}) & set(${${alias}_BTS_shared_RM_sn_list}))
        ${other_BTS_PL_OBSAI_shared_RM_sn_list}=  Get From Dictionary  ${other_BTS_PL_shared_RM_info}  BTS_PL_OBSAI_shared_RM_sn_list
        ${other_BTS_PL_OBSAI_shared_RM_sn_list}=
        ...  Evaluate  list(set(${other_BTS_PL_OBSAI_shared_RM_sn_list}) & set(${${alias}_BTS_shared_RM_sn_list}))

        ${other_BTS_secondary_controller_new_RM_SW_list}  ${other_BTS_primary_controller_new_RM_SW_list}=
        ...  Get other BTS new RM SW alarm list  ${alias}  ${other_alias}
        ${other_BTS_new_RM_SW_list}=  Combine Lists  ${other_BTS_secondary_controller_new_RM_SW_list}  ${other_BTS_primary_controller_new_RM_SW_list}

        ${other_alias_final_new_RM_SW_sn_list}=  Copy List  ${other_BTS_new_RM_SW_list}
        Set Test Variable  ${${other_alias}_final_new_RM_SW_sn_list}  ${other_alias_final_new_RM_SW_sn_list}
        Remove Values From List  ${other_BTS_new_RM_SW_list}   @{other_BTS_PL_OBSAI_shared_RM_sn_list}
        ${other_BTS_new_RM_SW_list_with_exceptions}=  Get new RM SW alarm list with CNI-103974 exceptions  ${other_BTS_new_RM_SW_list}
        ...  ${other_alias}

        ${other_BTS_non_PL_CPRI_shared_RM_sn_list}=
        ...  Get PL impact based on new RM SW  ${other_BTS_non_PL_CPRI_shared_RM_sn_list}  ${other_BTS_new_RM_SW_list_with_exceptions}
        ${other_BTS_non_PL_ECPRI_shared_RM_sn_list}=
        ...  Get PL impact based on new RM SW  ${other_BTS_non_PL_ECPRI_shared_RM_sn_list}  ${other_BTS_new_RM_SW_list_with_exceptions}

        ${other_BTS_CPRI_alarm_count}=  Calculate other BTS alarms count  ${BTS_PL_CPRI_shared_RM_sn_list}
        ...  ${other_BTS_non_PL_CPRI_shared_RM_sn_list}
        ${other_BTS_ECPRI_alarm_count}=  Calculate other BTS alarms count  ${BTS_PL_ECPRI_shared_RM_sn_list}
        ...  ${other_BTS_non_PL_ECPRI_shared_RM_sn_list}
        ${other_BTS_OBSAI_alarm_count}=  Calculate other BTS alarms count  ${BTS_PL_OBSAI_shared_RM_sn_list}
        ...  ${other_BTS_non_PL_OBSAI_shared_RM_sn_list}
        ${other_BTS_new_RM_SW_alarm_count}=  Get Length  ${other_BTS_new_RM_SW_list}
        ${other_BTS_new_RM_SW_alarm_count_with_exceptions}=  Get Length  ${other_BTS_new_RM_SW_list_with_exceptions}

        ${FID10_shared_RM_sn_list_full}=  Combine Lists  ${other_BTS_non_PL_CPRI_shared_RM_sn_list}  ${other_BTS_non_PL_OBSAI_shared_RM_sn_list}
        Set Test Variable  ${${other_alias}_FID10_shared_RM_sn_list}  ${FID10_shared_RM_sn_list_full}
        Set Test Variable  ${${other_alias}_FID16_shared_RM_sn_list}  ${other_BTS_non_PL_ECPRI_shared_RM_sn_list}
        Set Test Variable  ${${other_alias}_FID4773_shared_RM_sn_list}  ${other_BTS_new_RM_SW_list_with_exceptions}

        ${FID10_alarm_count}=  Evaluate  ${other_BTS_CPRI_alarm_count} + ${other_BTS_OBSAI_alarm_count}
        ${FID16_alarm_count}=  Evaluate  ${other_BTS_ECPRI_alarm_count} + 0
        ${FID4773_alarm_count}=  Set Variable  ${other_BTS_new_RM_SW_alarm_count_with_exceptions}
        Set Test Variable  ${${other_alias}_FID10_alarm_count}  ${FID10_alarm_count}
        Set Test Variable  ${${other_alias}_FID16_alarm_count}  ${FID16_alarm_count}
        Set Test Variable  ${${other_alias}_FID4773_alarm_count}  ${FID4773_alarm_count}

        ${EXPECTED_ALARMS}=  Create List
        ${EXPECTED_ALARMS_10_full}=  Prepare expected alarms list  ${${other_alias.upper()}_EXPECTED_ALARMS_10}  ${FID10_alarm_count}
        ${EXPECTED_ALARMS_16_full}=  Prepare expected alarms list  ${${other_alias.upper()}_EXPECTED_ALARMS_16}  ${FID16_alarm_count}
        ${EXPECTED_ALARMS_4773_full}=  Prepare expected alarms list  ${${other_alias.upper()}_EXPECTED_ALARMS_4773}
        ...  ${FID4773_alarm_count}
        ${EXPECTED_ALARMS_10}=  Set Variable If  ${FID10_alarm_count} == 0  ${EXPECTED_ALARMS}   ${EXPECTED_ALARMS_10_full}
        ${EXPECTED_ALARMS_16}=  Set Variable If  ${FID16_alarm_count} == 0  ${EXPECTED_ALARMS}   ${EXPECTED_ALARMS_16_full}
        ${EXPECTED_ALARMS_4773}=  Set Variable If  ${FID4773_alarm_count} == 0  ${EXPECTED_ALARMS}   ${EXPECTED_ALARMS_4773_full}
        Set Test Variable  ${${other_alias}_EXPECTED_ALARMS_10_full}  ${EXPECTED_ALARMS_10_full}
        Set Test Variable  ${${other_alias}_EXPECTED_ALARMS_16_full}  ${EXPECTED_ALARMS_16_full}
        Set Test Variable  ${${other_alias}_EXPECTED_ALARMS_4773_full}  ${EXPECTED_ALARMS_4773_full}

        Log  BTS ${other_alias} new RM SW impacted shared RM count: ${other_BTS_new_RM_SW_alarm_count}   console=True
        Log Long String  BTS ${other_alias} new RM SW impacted shared RM count CNI-103974 exceptions:
        ...  ${other_BTS_new_RM_SW_alarm_count_with_exceptions}  console=True

        Continue For Loop If  ${${other_alias}_shared_FHS_id_sn_dict}

        Log  BTS ${other_alias} PL impacted CPRI shared RM count: ${other_BTS_CPRI_alarm_count}   console=True
        Log  BTS ${other_alias} PL impacted ECPRI shared RM count: ${other_BTS_ECPRI_alarm_count}   console=True
        Log  BTS ${other_alias} PL impacted OBSAI shared RM count: ${other_BTS_OBSAI_alarm_count}   console=True
    END

Get impacted shared RM id list
    [Arguments]  ${BTS_impacted_shared_RM_sn_list}  ${other_alias}

    ${BTS_impacted_shared_RM_id_list}=  Create List

    FOR  ${RM_sn}  IN  @{BTS_impacted_shared_RM_sn_list}
        ${RM_id}=  Get From Dictionary  ${${other_alias}_RM_sn_id_dict}  ${RM_sn}
        Append To List  ${BTS_impacted_shared_RM_id_list}  ${RM_id}
    END

    [Return]  ${BTS_impacted_shared_RM_id_list}

Get BTS new RM SW alarm list
    [Arguments]  ${alias}
    ${BTS_primary_controller_new_RM_SW_list}=  Create List
    ${BTS_secondary_controller_new_RM_SW_list}=  Create List

    FOR  ${RM_sn}  IN  @{${alias}_BTS_primary_controller_shared_RM_sn_list}
        Run Keyword If  '${RM_sn}' in ${${alias}_RM_sn_newer_SW_buildVersion_list}
        ...  Append To List  ${BTS_primary_controller_new_RM_SW_list}  ${RM_sn}
    END

    FOR  ${RM_sn}  IN  @{${alias}_BTS_secondary_controller_shared_RM_sn_CB006028_true_list}
        Run Keyword If  '${RM_sn}' in ${${alias}_RM_sn_newer_SW_buildVersion_list}
        ...  Append To List  ${BTS_secondary_controller_new_RM_SW_list}  ${RM_sn}
    END

    [Return]  ${BTS_primary_controller_new_RM_SW_list}  ${BTS_secondary_controller_new_RM_SW_list}

Get other BTS new RM SW alarm list
    [Arguments]  ${alias}  ${other_alias}
    ${other_BTS_secondary_controller_new_RM_SW_list}=  Create List
    ${other_BTS_primary_controller_new_RM_SW_list}=  Create List

    FOR  ${RM_sn}  IN  @{${alias}_BTS_primary_controller_shared_RM_sn_list}
        ${RM_bts-alias_list}=  Get From Dictionary  ${RM_sn_bts-alias_dict}  ${RM_sn}
        Continue For Loop If  '${other_alias}' not in ${RM_bts-alias_list}

        Run Keyword If  '${RM_sn}' in ${${other_alias}_BTS_secondary_controller_shared_RM_sn_list}
        ...  Run Keyword If  '${RM_sn}' in ${${other_alias}_RM_sn_newer_SW_buildVersion_list}
        ...  Append To List  ${other_BTS_secondary_controller_new_RM_SW_list}  ${RM_sn}
    END

    FOR  ${RM_sn}  IN  @{${alias}_BTS_secondary_controller_shared_RM_sn_CB006028_true_list}
        ${RM_bts-alias_list}=  Get From Dictionary  ${RM_sn_bts-alias_dict}  ${RM_sn}
        Continue For Loop If  '${other_alias}' not in ${RM_bts-alias_list}

        Run Keyword If  '${RM_sn}' in ${${other_alias}_BTS_primary_controller_shared_RM_sn_CB006028_true_list}
        ...  Run Keyword If  '${RM_sn}' in ${${other_alias}_RM_sn_newer_SW_buildVersion_list}
        ...  Append To List  ${other_BTS_primary_controller_new_RM_SW_list}  ${RM_sn}
    END

    [Return]  ${other_BTS_secondary_controller_new_RM_SW_list}  ${other_BTS_primary_controller_new_RM_SW_list}

Get new RM SW alarm list with CNI-103974 exceptions
    [Arguments]  ${other_BTS_new_RM_SW_list}  ${other_alias}

    ${other_BTS_new_RM_SW_list_with_exceptions}=  Copy List  ${other_BTS_new_RM_SW_list}

    FOR  ${RM_sn}  IN  @{other_BTS_new_RM_SW_list}

        ${RM_id}=  Get From Dictionary  ${${other_alias}_RM_sn_id_dict}  ${RM_sn}
        ${RM_param}=  Get Parameters For  class_name=RMOD  id_num=${RM_id}  connection=${other_alias}
        ${RM_exception}=  Run Keyword And Return Status  Should Contain  ${RMOD_CNI_103974_exceptions}  ${RM_param['productName']}

        Run Keyword If  '${RM_exception}' == 'True'
        ...  Remove Values From List  ${other_BTS_new_RM_SW_list_with_exceptions}  ${RM_sn}

    END

    [Return]  ${other_BTS_new_RM_SW_list_with_exceptions}

Get PL impact based on new RM SW
    [Arguments]  ${other_BTS_non_PL_shared_RM_sn_list}  ${other_BTS_new_RM_SW_list}

    ${other_BTS_non_PL_shared_RM_sn_list_copy}=  Copy List  ${other_BTS_non_PL_shared_RM_sn_list}

    FOR  ${item}  IN  @{other_BTS_non_PL_shared_RM_sn_list}
        Run Keyword If  '${item}' in ${other_BTS_new_RM_SW_list}
        ...  Remove Values From List  ${other_BTS_non_PL_shared_RM_sn_list_copy}  ${item}
    END

    [Return]  ${other_BTS_non_PL_shared_RM_sn_list_copy}

Calculate other BTS alarms count
    [Arguments]  ${BTS_PL_shared_RM_sn_list}  ${other_BTS_non_PL_shared_RM_sn_list}
    ${other_BTS_alarm_count}=  Set Variable  0

    FOR  ${item}  IN  @{BTS_PL_shared_RM_sn_list}
        ${other_BTS_alarm_count}=  Run Keyword If  '${item}' in ${other_BTS_non_PL_shared_RM_sn_list}
        ...  Evaluate  ${other_BTS_alarm_count} + 1
        ...  ELSE
        ...  Evaluate  ${other_BTS_alarm_count} + 0
    END

    [Return]  ${other_BTS_alarm_count}

BTS SW Update
    [Arguments]  ${alias}

    Log  Perform BTS ${alias} SW Update  console=True
    ${BTS_index}=  Get From Dictionary  ${alias_to_BTS_index_dict}  ${alias}
    ${activation_preposition}=  Set Variable If  ${Activate SW}  with  without
    Set Test Variable  ${activation_preposition}
    Run Keyword If  '${Activate SW}'=='True' and '${TWO_STEP_DOWNLOAD_ACTIVATE}'=='True'  Run Keywords
    ...  Log  BTS ${alias} SW Update ${activation_preposition} activation will be performed using ${Target SW BTS${BTS_index}}  console=True
    ...  AND  BTS SW Update with download check and activation  ${alias}
    ...  ELSE  Run Keywords
    ...  Log  BTS ${alias} SW Update ${activation_preposition} activation will be performed using ${Target SW BTS${BTS_index}}  console=True
    ...  AND  Run Keyword If  ${Activate SW}  BTS SW Update With Activation  ${alias}
    ...  AND  Run Keyword If  not ${Activate SW}  BTS SW Update Without Activation  ${alias}

BTS SW Update with download check and activation
    [Documentation]
    ...  Perform BTS SW Update with alarms checked during download and activation at end
    [Arguments]  ${alias}

    ${BTS_index}=  Get From Dictionary  ${alias_to_BTS_index_dict}  ${alias}
    Log  Start Download build without activation on BTS ${alias}  console=True
    ${new_alias}=  Set Variable  downloadSession
    Start new ADMIN instance  alias=${alias}  new_alias=${new_alias}  connection_type=${connection_type_${alias}}

    Adding alarms to ignored list  ${${alias.upper()}_IGNORED_ALARMS}  connection_alias=${alias}
    ${download_thread}=  Run Keyword In Background
    ...  Update Software  sw_package=${Target SW BTS${BTS_index}}  should_activate=False
    ...  timeout=${SW Update Timeout}  connection=downloadSession

    ${alarms_info_response}=  Create List
    ${alarms_info_result}  ${alarms_info_response}=  Wait Until Keyword Succeeds  90 min  10 s  Check alarms while thread is running
    ...  ${download_thread}  ${alias}  ${alarms_info_response}
    Collect Keyword Result  ${download_thread}  timeout=${SW Update Timeout}

    Run Keyword And Continue On Failure  Run Keyword If  '${alarms_info_result}' == 'FAIL'
    ...  Fail  Unexpected alarms occurred during ${alias} Software Download -- ${alarms_info_response}
    ...  ELSE  Log  No unexpected alarms found during ${alias} Software Download  console=True

    Check planned software build name  Target SW name=${Target SW BTS${BTS_index}}  alias=${alias}

    Log  Perform build activation on BTS ${alias}  console=True
    BTS SW Update With Activation  ${alias}

    [Teardown]  Teardown Admin  alias=${new_alias}

Check planned software build name
    [Arguments]  ${Target SW name}  ${alias}
    Log  Get downloaded SW build name  console=True
    ${BTS_SW_Info}=   Get software info  alias=${alias}
    ${Planned_SW}=  Get from dictionary  ${BTS_SW_Info}  Planned SW version
    Run Keyword If  '${Planned_SW}' == '${Target SW name}'
    ...  Log  Planned SW build is the same as ${Target SW name}. Download build was successful!  console=True
    ...  ELSE  Fail  Download build action without activation failed!

BTS SW Update With Activation
    [Documentation]
    ...  Perform BTS SW Update with activation. BTS reset time check performed.
    [Arguments]  ${alias}

    ${BTS_index}=  Get From Dictionary  ${alias_to_BTS_index_dict}  ${alias}
    Run Keyword If  ${BTS_SCF_VALIDATION}  Check BTS SCF Validation On Demand  alias=${alias}

    ${reset_number}=  Admin Get Reset info based on BTS SW Precheck  SW_package=${Target SW BTS${BTS_index}}  alias=${alias}
    Set Test Variable  ${${alias.upper()}_EXPECTED_RESET_NUMBER}  ${reset_number}
    Log  ${\n}======================================================================  console=True
    Run Keyword If  ${resetCoverage_found}
    ...  Log  Expected BTS ${alias} reset number based on SW Precheck before SW Update: ${${alias.upper()}_EXPECTED_RESET_NUMBER}  console=True
    ...  ELSE  Log  Expected BTS ${alias} reset number after SW Update (without SW Precheck): ${${alias.upper()}_EXPECTED_RESET_NUMBER}
    ...  console=True
    Log  ======================================================================${\n}  console=True

    coam.Update Software  sw_package=${Target SW BTS${BTS_index}}  should_activate=True  timeout=${SW Update Timeout}  connection=${alias}
    Log  BTS ${alias} SW Update: download finished, waiting for activation reset!  console=True

    Get Current Date UTC info  start_SWUpdate

    Set Test Variable    ${BTS_${alias}_start_SWUpdate}  ${date_timestamp_start_SWUpdate_UTC}

    ${remote_host_ip}=  Set Variable If  '${alias}' == 'Master'  None  ${${alias.upper()}}[${alias.upper()}_PC_IP_ADDRESS]
    Run Keyword If  ${${alias.upper()}_EXPECTED_RESET_NUMBER} != 0  Wait For Target To Be Not Reachable TAF
    ...  hostname=${${alias.upper()}}[${alias.upper()}_TECH_IP_ADDRESS]  timeout=${BTS_MAX_WAIT_TIME}  remote_host=${remote_host_ip}

    Get Current Time  bts_initial
    Log  BTS ${alias} reset_start_time is: ${time_bts_initial}  console=True

    ${remained_MAX_WAIT_TIME}=  Get elapsed time  ${time_bts_initial}  ${BTS_MAX_WAIT_TIME}
    Wait For Target To Be Reachable TAF  hostname=${${alias.upper()}}[${alias.upper()}_TECH_IP_ADDRESS]  timeout=${remained_MAX_WAIT_TIME}
    ...  remote_host=${remote_host_ip}

    Sleep  120s
    ${ims_file_path_SWDL}=  Admin Collect IMS file with timestamp  folder_path=${Test Results Dir}/IMS/${alias}  alias=${alias}
    Set Test Variable  ${${alias}_ims_file_path_SWDL}  ${ims_file_path_SWDL}
    Wait Until Keyword Succeeds  3x  10s  Admin reset and Infomodel reconnect sessions  reset_req=True  alias=${alias}  infomodel_reset=False

    Log  SW Update with activation performed!  console=True

    Log  Check BTS ${alias} status and alarms after BTS ${alias} SW Update:  console=True
    ${remained_MAX_WAIT_TIME}=  Get elapsed time  ${time_bts_initial}  ${BTS_MAX_WAIT_TIME}
    Admin Check BTS Procedural and Blocking states  ${OnAir_}  ${Unblocked_}  ${remained_MAX_WAIT_TIME}  ${alias}
    Log  BTS ${alias} site - proceduralState: OnAir, blockingState: Unblocked, as expected!  console=True

    ${remained_MAX_WAIT_TIME}=  Get elapsed time  ${time_bts_initial}  ${BTS_MAX_WAIT_TIME}
    Check cells availability status online  ${alias}  ${remained_MAX_WAIT_TIME}
    Log  All BTS ${alias} cell(s) status:\n - operationalState=Enabled  console=True

    Log  Check BTS ${alias} alarms:  console=True
    Get and Check Alarms SOAM  alias=${alias}  expected_alarms=@{EMPTY}  ignored_alarms=${${alias.upper()}_IGNORED_ALARMS}
    ...  critical_alarms=${${alias.upper()}_CRITICAL_ALARMS}
    Log  BTS ${alias} site - expected, ignored and critical alarms checked  console=True

    Log  ***** Check peer BTS status and alarms after BTS ${alias} SW Update *****  console=True
    Check peer BTS states and alarms after BTS SW Update  ${alias}

    Run Keyword If  ${BTS_SCF_VALIDATION}  Check BTS SCF Validation On Demand  alias=${alias}

    Sleep  5s  reason=IMS file content completed

    Get Current Date UTC info  end_SWUpdate

    Get peer BTS alarms during SW Update from IMS file  ${alias}

    Run Keyword If  ${${alias.upper()}_EXPECTED_RESET_NUMBER} != 0
    ...  Get and check KPI2a info from IMS file  ${alias}

Check peer BTS states and alarms after BTS SW Update
    [Arguments]  ${alias}

    FOR  ${other_alias}  IN  @{alias_list}
        Continue For Loop If  '${other_alias}' == '${alias}'

        Log  Check BTS ${other_alias} status:  console=True
        Admin Check BTS Procedural and Blocking states  ${OnAir_}  ${Unblocked_}  ${BTS_MAX_WAIT_TIME}  ${other_alias}
        Log  BTS ${other_alias} site - proceduralState: OnAir, blockingState: Unblocked, as expected!  console=True

        Check cells availability status online  ${other_alias}  ${BTS_MAX_WAIT_TIME}
        Log  All BTS ${other_alias} cell(s) status:\n - operationalState=Enabled  console=True

        Log  Check BTS ${other_alias} alarms:  console=True
        Get and Check Alarms SOAM  alias=${other_alias}  expected_alarms=@{EMPTY}  ignored_alarms=${${other_alias.upper()}_IGNORED_ALARMS}
        ...  critical_alarms=${${other_alias.upper()}_CRITICAL_ALARMS}
        Log  BTS ${other_alias} site - expected, ignored and critical alarms checked  console=True
    END

BTS SW Update Without Activation
    [Documentation]
    ...  Perform BTS SW Update without activation.
    [Arguments]  ${alias}

    ${BTS_index}=  Get From Dictionary  ${alias_to_BTS_index_dict}  ${alias}
    coam.Update Software  sw_package= ${Target SW BTS${BTS_index}}  should_activate=False  timeout=${SW Update Timeout}  connection=${alias}
    Log  BTS ${alias} SW Update without activation performed!  console=True

    Sleep  5s  reason=IMS file content completed

    ${ims_file_path_SWDL}=  Admin Collect IMS file with timestamp  folder_path=${Test Results Dir}/IMS/Master  alias=Master
    Set Test Variable  ${${alias}_ims_file_path_SWDL}  ${ims_file_path_SWDL}

    Get KPI_SW_Download info from IMS file  ${alias}

Get KPI_SW_Download info from IMS file
    [Documentation]
    ...  Get KPI_SW_Download info from IMS file.
    [Arguments]  ${alias}

    Log  Get BTS ${alias} KPI_SW_Download info from IMS file  console=True

    ${kpi_name_delta_dict}=  Get KPI info  kpi_names=kpiswdownload  ims_file_path=${${alias}_ims_file_path_SWDL}  alias= ${alias}
    ${kpi_delta_list_kpiswdownload}=  Get From Dictionary  ${kpi_name_delta_dict}  kpiswdownload
    Set Test Variable  ${${alias}_SW_Download_duration}  ${kpi_delta_list_kpiswdownload[0]}

    Export KPI Results to File  alias=${alias}  obj=BTS  obj_type=sbts  obj_id=${alias}  action_1=SW_Update  kpi_reported_1=KPI_SW_Download
    ...  event_value_1=${kpi_delta_list_kpiswdownload[0]}  source_info=ims

Get peer BTS alarms during SW Update from IMS file
    [Arguments]  ${alias}

    Log  Get peer BTS alarms during SW Update from IMS file  console=True

    FOR  ${other_alias}  IN  @{alias_list}

        Continue For Loop If  '${other_alias}' == '${alias}'

        ${ims_file_path_after_SWDL}=  Admin Collect IMS file with timestamp  folder_path=${Test Results Dir}/IMS/${other_alias}  alias=${other_alias}

        Log  Check BTS ${other_alias} alarms:  console=True

        Log Long String  BTS ${other_alias} "Radio unit reset triggered by peer BTS (4773)" alarm, expected number:
        ...  ${${other_alias}_FID4773_alarm_count}  console=True
        Run Keyword If  ${${other_alias}_FID4773_alarm_count} >0
        ...  Log   BTS ${other_alias} impacted shared RM SN list are: ${${other_alias}_FID4773_shared_RM_sn_list}  console=True
        Check expected faultId on BTS object from IMS  fault_id_number=4773  alias=${other_alias}
        Log Long String  BTS ${other_alias} "Radio unit reset triggered by peer BTS (4773)" alarm, found number:
        ...  ${${other_alias}_FID4773_alarm_count}, as expected!  console=True

        Continue For Loop If  ${${other_alias}_shared_FHS_id_sn_dict}

        Log  BTS ${other_alias} "No connection to Unit (10)" alarm, expected number: ${${other_alias}_FID10_alarm_count}  console=True
        Run Keyword If  ${${other_alias}_FID10_alarm_count} >0
        ...  Log   BTS ${other_alias} impacted shared RM SN list are: ${${other_alias}_FID10_shared_RM_sn_list}  console=True
        Check expected faultId on BTS object from IMS  fault_id_number=10  alias=${other_alias}
        Log Long String  BTS ${other_alias} "No connection to Unit (10)" alarm, found number: ${${other_alias}_FID10_alarm_count},
        ...  as expected!  console=True

        Log  BTS ${other_alias} "Unit synchronization failed (16)" alarm, expected number: ${${other_alias}_FID16_alarm_count}  console=True
        Run Keyword If  ${${other_alias}_FID16_alarm_count} >0
        ...  Log   BTS ${other_alias} impacted shared RM SN list are: ${${other_alias}_FID16_shared_RM_sn_list}  console=True
        Check expected faultId on BTS object from IMS  fault_id_number=16  alias=${other_alias}
        Log Long String  BTS ${other_alias} "Unit synchronization failed (16)" alarm, found number: ${${other_alias}_FID16_alarm_count},
        ...  as expected!  console=True

    END

Check expected faultId on BTS object from IMS
    [Arguments]  ${fault_id_number}  ${alias}

    ${shared_RM_sn_alarm_info}=  Create List

    FOR  ${RM_sn}  IN  @{${alias}_FID${fault_id_number}_shared_RM_sn_list}
        ${shared_RM_alarm_dict}=  Get From List  ${${alias.upper()}_EXPECTED_ALARMS_${fault_id_number}}  0
        ${shared_RM_alarm_dict_copy}=  Copy Dictionary  ${shared_RM_alarm_dict}
        Set To Dictionary  ${shared_RM_alarm_dict_copy}  sn_attribute=${RM_sn}
        Append To List  ${shared_RM_sn_alarm_info}  ${shared_RM_alarm_dict_copy}
    END

    Get and check detailed IMS2 Alarms SOAM  alias=${alias}  start_timestamp=${date_timestamp_start_SWUpdate_UTC}
    ...  expected_alarms=${${alias}_EXPECTED_ALARMS_${fault_id_number}_full}  bts_additional_alarm_info=${shared_RM_sn_alarm_info}

Check BTS and RM SW versions from BTS partitions after BTS SW Update
    [Arguments]  ${alias}
    Log  Check BTS and RM SW versions from BTS ${alias} partitions after BTS ${alias} SW Update  console=True

    ${BTS_index}=  Get From Dictionary  ${alias_to_BTS_index_dict}  ${alias}
    Admin Get BTS SW Version  alias=${alias}
    Run Keyword If  not ${Activate SW}  Run Keywords
    ...  Should Match Regexp  ${Target SW BTS${BTS_index}}  (?i).*${${alias} passive SW}.*|(?i).*${${alias} planned SW}.*
    ...  AND  Log  BTS ${alias} SW as expected!  console=True
    ...  AND  Check SW version on peer BTS after BTS SW Update  ${alias}
    ...  ELSE  Run Keywords
    ...  Should Match Regexp  ${Target SW BTS${BTS_index}}  (?i).*${${alias} active SW}.*
    ...  AND  Log  BTS ${alias} SW as expected!  console=True
    ...  AND  Check SW version on peer BTS after BTS SW Update  ${alias}
    ...  AND  Check RM SW versions on all BTS after BTS SW Update  ${alias}
    Log  BTS ${alias} SW update ${activation_preposition} activation successfully performed!  console=True

Check SW version on peer BTS after BTS SW Update
    [Arguments]  ${alias}
    FOR  ${other_alias}  IN  @{alias_list}
        Continue For Loop If  '${other_alias}' == '${alias}'
        Should Be Equal  ${${other_alias} final active SW}  ${${other_alias} initial active SW}
        Should Be Equal  ${${other_alias} final passive SW}  ${${other_alias} initial passive SW}
        Log  BTS ${other_alias} initial active SW = final active SW: ${${other_alias} final active SW}, as expected!  console=True
        Log  BTS ${other_alias} initial passive SW = final passive SW: ${${other_alias} final passive SW}, as expected!    console=True
    END

Check RM SW versions on all BTS after BTS SW Update
    [Arguments]  ${BTS_SW_Update}

    FOR  ${alias}  IN  @{alias_list}
        Check RM SW versions after BTS SW Update  ${alias}  ${BTS_SW_Update}
    END

Check RM SW versions after BTS SW Update
    [Arguments]  ${alias}  ${BTS_SW_Update}

    FOR  ${RM_sn}  IN  @{shared_RM_sn_list}
        ${RM_bts-alias_list}=  Get From Dictionary  ${RM_sn_bts-alias_dict}  ${RM_sn}
        Continue For Loop If  '${alias}' not in ${RM_bts-alias_list}

        Run Keyword If  '${RM_sn}' in ${${alias}_final_new_RM_SW_sn_list}
        ...  Compare RM SW versions after BTS SW Update  ${alias}  ${RM_sn}  target
        ...  ELSE
        ...  Compare RM SW versions after BTS SW Update  ${alias}  ${RM_sn}  initial
    END

    FOR  ${RM_sn}  IN  @{dedicated_RM_sn_list}
        ${RM_bts-alias_list}=  Get From Dictionary  ${RM_sn_bts-alias_dict}  ${RM_sn}

        Run Keyword If  '${alias}' in ${RM_bts-alias_list} and '${alias}' == '${BTS_SW_Update}'
        ...  Compare RM SW versions after BTS SW Update  ${alias}  ${RM_sn}  target
        ...  ELSE IF  '${alias}' in ${RM_bts-alias_list} and '${alias}' != '${BTS_SW_Update}'
        ...  Compare RM SW versions after BTS SW Update  ${alias}  ${RM_sn}  initial
    END

Compare RM SW versions after BTS SW Update
    [Arguments]  ${alias}  ${RM_sn}  ${sw_build}

    ${buildVersion_initial_or_target}=  Get From Dictionary  ${${alias}_${sw_build}_RMOD_serialNumber_buildVersion_dict}  ${RM_sn}
    ${buildVersion_final}=  Get From Dictionary  ${${alias}_final_RMOD_serialNumber_buildVersion_dict}  ${RM_sn}

    ${status}=  Run Keyword And Return Status  Run Keyword And Continue On Failure
    ...  Should Be Equal  ${buildVersion_initial_or_target}  ${buildVersion_final}
    Run Keyword If  not ${status}
    ...  Fail  BTS ${alias} RM with SN ${RM_sn} ${sw_build} RM SW != final active RM SW: ${buildVersion_initial_or_target} != ${buildVersion_final}

    Log  BTS ${alias} RM with SN ${RM_sn} ${sw_build} RM SW = final active RM SW: ${buildVersion_initial_or_target}, as expected!  console=True

Check BTS reset behavior based on IMS info after BTS SW Update
    [Arguments]  ${alias}
    [Documentation]

    ...  BTS RESET info is checked based on IMS info. Reset behavior as expected if:
    ...  - BTS ${alias} site: 1
    ...  - peer BTS site: reset number is 0
    ...  Otherwise, reset behavior not as expected, then errors are added to report and failed.

    Log  Check BTS reset behavior based on IMS info after BTS ${alias} SW Update  console=True

    Run Keyword If  ${Activate SW} is True  Run Keywords
    ...  Log  Check BTS ${alias} reset behavior during BTS ${alias} SW Update with activation  console=True
    ...  AND  Get and check BTS RESET info from IMS file  ims_file_path=${${alias}_ims_file_path_SWDL}
    ...  expected_reset_number=${${alias.upper()}_EXPECTED_RESET_NUMBER}  alias=${alias}  remove_ims_file=False
    ...  AND  Log  Check BTS ${alias} reset behavior after BTS ${alias} SW Update with activation  console=True
    ...  AND  Get and check BTS RESET info from IMS file  expected_reset_number=0  alias=${alias}  remove_ims_file=False
    ...  AND  Check reset behavior on peer BTS  with  ${alias}
    ...  ELSE IF  ${Activate SW} is False  Run Keywords
    ...  Log  Check BTS ${alias} reset behavior after BTS ${alias} SW Update without activation  console=True
    ...  AND  Get and check BTS RESET info from IMS file  expected_reset_number=0  alias=${alias}  remove_ims_file=False
    ...  AND  Check reset behavior on peer BTS  without  ${alias}

Check reset behavior on peer BTS
    [Arguments]  ${activation_preposition}  ${alias}
    FOR  ${other_alias}  IN  @{alias_list}
        Continue For Loop If  '${other_alias}' == '${alias}'
        Log  Check BTS ${other_alias} reset behavior after BTS ${alias} SW Update ${activation_preposition} activation  console=True
        Get and check BTS RESET info from IMS file  expected_reset_number=0  alias=${other_alias}  remove_ims_file=False
    END

Get and check KPI2a info from IMS file
    [Documentation]
    ...  Get and check KPI2a info from IMS file.
    [Arguments]  ${alias}
    Log  Get and check KPI2a info from IMS file  console=True
    Return From Keyword If  '${Activate SW}' == 'False'
    Return From Keyword If  ${${alias.upper()}_EXPECTED_RESET_NUMBER} == 0
    ${label}=  Get From Dictionary  ${BTS_alias_label_dict}  ${alias}
    ${KeyIsPresent}=  Run Keyword And Return Status  Dictionary Should Contain Key  ${threshold_dict}  ${label}
    ${BTS_RESET_THR}=  Run Keyword If  ${KeyIsPresent}
    ...  Get From Dictionary  ${threshold_dict}  ${label}
    ...  ELSE  Set Variable  ${BTS_RESET_WRN_THR}
    ${ims_file_path_after_Update}=  Admin Collect IMS file with timestamp  folder_path=${Test Results Dir}/IMS/${alias}  alias=${alias}
    ${ims_file_path_list}=  Create List  ${${alias}_ims_file_path_SWDL}  ${ims_file_path_after_Update}
    ${kpi_name_delta_dict}=  Get and check KPI info from IMS file
    ...  kpi_names=kpi2a  kpi_thresholds=${BTS_RESET_THR}  ims_file_path=${ims_file_path_list}  alias=${alias}
    ${kpi_delta_list}=  Get From Dictionary  ${kpi_name_delta_dict}  kpi2a

    Export KPI Results to File  alias=${alias}  obj=BTS  obj_type=SBTS  obj_id=${alias}  action_1=SW_Update  kpi_reported_1=KPI_2a
    ...  event_value_1=${kpi_delta_list[0]}  source_info=ims

Check threshold list
    ${BTS_RESET_WRN_THR_strip}=  Replace String  ${BTS_RESET_WRN_THR}  ${SPACE}  ${EMPTY}
    ${BTS_RESET_WRN_THR}=  Split String  ${BTS_RESET_WRN_THR_strip}  ,
    ${BTS_RESET_WRN_THR_length}=  Get Length  ${BTS_RESET_WRN_THR}
    ${BTS_SW_Update_strip}=  Replace String  ${BTS SW Update}  ${SPACE}  ${EMPTY}
    ${BTS_SW_Update}=  Split String  ${BTS_SW_Update_strip}  ,
    ${BTS_SW_Update_length}=  Get Length  ${BTS_SW_Update}
    ${threshold_dict}=  Create Dictionary
    ${threshold_check}=  Set Variable  True

    Run Keyword If  ${BTS_RESET_WRN_THR_length} == 1 and ${BTS SW Update} == 'ALL'  Run Keywords
    ...  Set Variable  ${threshold_check}  False
    ...  AND  Log  BTS_RESET_WRN_THR and BTS SW Update were set correctly, test will continue  console=True
    ...  ELSE IF  ${BTS_RESET_WRN_THR_length} == ${BTS_SW_Update_length}
    ...  Log  BTS_RESET_WRN_THR and BTS SW Update were set correctly, test will continue  console=True
    ...  ELSE  FAIL  Variables BTS_RESET_WRN_THR and BTS SW Update were set incorrectly!

    Run Keyword If  ${threshold_check} is True  Create Threshold Dict  ${threshold_dict}  ${BTS_RESET_WRN_THR}  ${BTS_SW_Update}

Create Threshold Dict
    [Arguments]  ${threshold_dict}  ${BTS_RESET_WRN_THR}  ${BTS_SW_Update}
    ${length}=  Get Length  ${BTS_SW_Update}
    FOR  ${index}  IN RANGE  ${length}
        ${threshold}=  Set Variable  ${BTS_RESET_WRN_THR}[${index}]
        ${bts}=  Set Variable  ${BTS_SW_Update}[${index}]
        Set To Dictionary  ${threshold_dict}  ${bts}  ${threshold}
    END
    Set Test Variable  ${threshold_dict}

Synchronize active and pasive SW versions
    [Documentation]
    ...  Helper keyword used to synchronize Active and Passive partition SW

    FOR  ${alias}  IN  @{BTS_alias_list}
        ${label}=  Get From Dictionary  ${BTS_alias_label_dict}  ${alias}
        Log  Synchronize active and pasive SW versions on ${label}   console=True
        Admin Synchronizing Active and Passive SW version  alias=${alias}  timeout=2400
    END

Check SCF files from Snapshot

    Log  Check the presence of SCF file before the SW Update and updated SCF after the SW Update from Snapshot  console=True

    FOR  ${alias}  IN  @{BTS_alias_list}

        Continue For Loop If  '${${alias.upper()}}[${alias.upper()}_MODULE_TYPE]' == 'FSMF'

        Log  BTS for Snapshot file check: ${alias}  console=True
        Save Snapshot file  ${alias}
        Check initial and final SCF  ${alias}

    END

Save Snapshot file
    [Arguments]  ${alias}

    Log  Snapshot file collection on BTS ${alias} started  console=True
    ${folder_path}  ${snapshot_filename}=  Snapshot collection on demand SOAM  alias=${alias}  folder_path=${Test Results Dir}/Snapshot_check
    Set Test Variable  ${${alias}_path_to_snapshot}  ${folder_path}/${snapshot_filename}

Check initial and final SCF
    [Arguments]  ${alias}

    ${migtools_name_list}=  Create List  [A-Za-z0-9_]+_migtoolsdata.tar.gz
    ${working_folder}=  Set Variable  /tmp/Snapshot_check

    Log  Check BTS ${alias} SCF files  console=True

    ${snapshot_dict}=  snapshot.Get Data From Snapshot  ${${alias}_path_to_snapshot}
    ${json_spec_dict}=  Create Dictionary  mandatory_file=@{migtools_name_list}  not_mandatory_file=@{EMPTY}
    ${snapshot_scf_data}=  snapshot.Validate Snapshot Using Custom Data  ${snapshot_dict}  ${json_spec_dict}

    ${snapshot_archive_list}=  Get Snapshot archive list  ${alias}  ${snapshot_scf_data}
    ${migtoolsdata_archive_list}=  Get migtoolsdata archive list  ${snapshot_archive_list}

    OperatingSystem.Remove Directory  ${working_folder}  recursive=${True}
    OperatingSystem.Create Directory  ${working_folder}

    Unzip Snapshot archive list  ${snapshot_archive_list}  ${working_folder}

    ${scf_found_check}=  Set Variable  False

    Check if SCF files are present in migtoolsdata archive list  ${alias}  ${working_folder}  ${migtoolsdata_archive_list}

    Run Keyword If  ${scf_found_check}  Run Keywords
    ...  Log  All BTS ${alias} SCF files were found!  console=True
    ...  AND  Return From Keyword

    Run Keyword and Continue On Failure
    ...  Run Keyword If  not ${scf_found_check}  Run Keywords
    ...  Log  BTS ${alias} SCF files were not found in ${${alias}_path_to_snapshot}!  level=ERROR
    ...  AND  Fail  BTS ${alias} SCF files were not found in ${${alias}_path_to_snapshot}!

    [Teardown]    OperatingSystem.Remove Directory  ${working_folder}  recursive=${True}

Get Snapshot archive list
    [Arguments]  ${alias}  ${snapshot_scf_data}

    ${snapshot_archive_list}=  Create List

    FOR  ${item}  IN  @{snapshot_scf_data}

        ${path}=  Set Variable  ${item[${1}]}
        ${path}=  Split String  ${path}  /
        ${path_list}=  Create List  ${${alias}_path_to_snapshot}  @{path}
        Append To List  ${snapshot_archive_list}  @{path_list}

    END

    [Return]  ${snapshot_archive_list}

Get migtoolsdata archive list
    [Arguments]  ${snapshot_archive_list}

    ${migtoolsdata_archive_list}=  Create List

    FOR  ${item}  IN  @{snapshot_archive_list}

        Run Keyword If  'migtoolsdata' in '${item}'
        ...  Append To List  ${migtoolsdata_archive_list}  ${item}

    END

    [Return]  ${migtoolsdata_archive_list}

Unzip Snapshot archive list
    [Arguments]  ${snapshot_archive_list}  ${working_folder}

    FOR  ${index}  ${archive}  IN ENUMERATE  @{snapshot_archive_list[:-1:]}

        OperatingSystem.Run  cd ${working_folder};unzip -j ${archive} ${snapshot_archive_list[${index+1}]}

    END

Check if SCF files are present in migtoolsdata archive list
    [Arguments]  ${alias}  ${working_folder}  ${migtoolsdata_archive_list}

    FOR  ${migtoolsdata}  IN  @{migtoolsdata_archive_list}

        ${tar_gz_file_details}=  OperatingSystem.Run  tar -tvzf '${working_folder}//${migtoolsdata}' | awk '{print $3 " " $6}'
        ${scf_status}=  Check SCF  ${alias}  ${migtoolsdata}  ${tar_gz_file_details}

        Run Keyword If  ${scf_status}  Run Keywords
        ...  Set Test Variable  ${scf_found_check}  True
        ...  AND  Exit For Loop

    END

Check SCF
    [Arguments]  ${alias}  ${migtoolsdata}  ${tar_gz_file_details}

    ${scf_files}=  Create List  scf_decode.xml  scf_migrated.xml
    ${regexp_scf_size}=  Set Variable  [1-9][0-9]*\\s[a-zA-Z0-9/]+
    ${scf_status}=  Create List

    FOR  ${scf_file}  IN  @{scf_files}

        ${status}=  Run Keyword And Return Status  Should Match Regexp  ${tar_gz_file_details}  ${regexp_scf_size}${scf_file}
        Log  BTS ${alias} SCF file ${scf_file} from ${migtoolsdata} archive check status: ${status}  console=True

        Run Keyword If  ${status}  Append To List  ${scf_status}  True
        ...  ELSE  Append To List  ${scf_status}  False

    END

    ${scf_status}=  Set Variable If  'False' in @{scf_status}  False  True

    [Return]  ${scf_status}

TC Setup
    ${tech_preset_list}=  Create List  SBTS  SBTS  SBTS  SBTS
    Common Test Setup  preset_techs=${tech_preset_list}  common_sbts=${TRUE}  infomodelSetup=${FALSE}

TC Teardown
    Common Test Teardown
