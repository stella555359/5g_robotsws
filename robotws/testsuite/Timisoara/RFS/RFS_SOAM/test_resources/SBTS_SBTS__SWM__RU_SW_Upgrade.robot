*** Settings ***
Documentation    TC__SBTS_SBTS__SWM__RU_SW_Upgrade
Variables    tc_variables/sbts_sbts__swm__ru_sw_upgrade_alarms_definitions.py
Resource    ../../resources/rfs_frame_rfs_soam_taf.robot

*** Variables ***
${REPEAT_COUNTER}                           3                    # Number of repetitions, default value 3
${Target SW dir}                            /home/ute/Downloads  # Path to directory with SW build zip file
${Target SW name}                                                # Target BTS SW build name.
                                                                 # - if ${FORCE_CURRENT_SW_DL}=True, this parameter doesn't need to be modified and
                                                                 # the target SW build will be the CM reservation SW build.
                                                                 # - if ${FORCE_CURRENT_SW_DL}=False, Target BTS SW build name should be filled (in
                                                                 # case of Trunk SW, its name should start with SBTS00, as in WFT tool) and SW
                                                                 # build should be manually downloaded in ${Target SW dir}
${Initial SW name}                                               # Only if ${REPEAT_COUNTER} > 1 or ${RECOVER_BTS_SW}=True. Initial BTS SW build name.
                                                                 # - if ${FORCE_CURRENT_SW_DL}=True, Initial BTS SW build will be downloaded
                                                                 # automatically for both CM and offline run (for automated SW download, in case of
                                                                 # Trunk SW, it's name should start with SBTS00, as in WFT tool).
                                                                 # - if ${FORCE_CURRENT_SW_DL}=False, Initial BTS SW build should be manually
                                                                 # downloaded in ${Target SW dir}
${Intermediate SW name}                                          # Only if ${REPEAT_COUNTER} > 1 or ${RECOVER_BTS_SW}=True. Intermediate BTS SW build
                                                                 # name.
                                                                 # - if ${FORCE_CURRENT_SW_DL}=True, Intermediate BTS SW build will be downloaded
                                                                 # automatically for both CM and offline run (for automated SW download, in case of
                                                                 # Trunk SW, it's name should start with SBTS00, as in WFT tool).
                                                                 # - if ${FORCE_CURRENT_SW_DL}=False, Intermediate BTS SW build should be manually
                                                                 # downloaded in ${Target SW dir}
${SW Update Timeout}                        3000                 # Timeout for SW Update; given in seconds
${BTS_MAX_WAIT_TIME}                        900                  # Maximum time for wait of BTS OnAir
${FORCE_CURRENT_SW_DL}                      False                # Force download current reservation SW build in order to be used for SW Update, in
                                                                 # offline running it needs variable ENB_BUILD to be defined in argfile.txt
${Remote target SW path}                    None                 # Path to remote zip file which needs to be downloaded
                                                                 # e.g. /SBTS/Trunk/SBTS00_ENB_9999_231030_000010.zip
${RFS_CUSTOM_SHARE_SW_DL}                   False                # Flag to enable/disable SW package download from remote location
                                                                 # - SWs from share-1 can be downloaded locally.
${BTS_SCF_VALIDATION}                       True                 # Validate BTS SCF. Possible values: True or False.
${CB010780_sequentialRuSwUpgrade}           false                # Only if CB010780 is activated on BTS. Possible values: false or true.
${CB013660_ruPhaseSwActivationResetPolicy}  Simultaneous         # Only if CB013660 is activated on BTS. Possible values: Simultaneous, Sequential,
                                                                 # User configuration, Together per HW type or Together per band.
${CB010780_NO_UPGRADE_RM_SN_LIST}                                # Only if CB010780 is activated on BTS. Skipped RM serial number list during RU SW
                                                                 # upgrade by set RM parameter disableSWUpdate=true
${CB013660_NO_UPGRADE_RM_SN_LIST}                                # Only if CB013660 is activated on BTS. Skipped RM serial number list during RU SW
                                                                 # upgrade by set RM parameter upgradePhase=No upgrade
${CB013660_DU_RM_SN_LIST}                                        # Only if CB013660 is activated on BTS. Skipped RM serial number list during RU SW
                                                                 # upgrade by set RM parameter upgradePhase=DU
${CB013660_RU_RM_SN_LIST}                                        # Only if CB013660 is activated on BTS. Allowed RM serial number list during RU SW
                                                                 # upgrade by set RM parameter upgradePhase=RU
${RU_FIRST_GROUP_RESET_RM_SN_LIST}                               # Only if CB013660 is activated on BTS and ruPhaseSwActivationResetPolicy set to User
                                                                 # configuration. First group of RM serial number list to reset during RU SW upgrade
${RU_SECOND_GROUP_RESET_RM_SN_LIST}                              # Only if CB013660 is activated on BTS and ruPhaseSwActivationResetPolicy set to User
                                                                 # configuration. Second group of RM serial number list to reset during RU SW upgrade
${CHANGE_RM_UPGRADE_PARAMETER}              False                # Specify if after RU SW upgrade, RM upgrade parameters should be changed:
                                                                 # - False: run BTS DU+RU SW Update keeping same RM settings as used during RU
                                                                 # SW upgrade
                                                                 # - True: run BTS DU+RU SW Update with default RM settings (CB010780
                                                                 # disableSWUpdate=false or CB013660 upgradePhase=none)
                                                                 # (False) or ${Initial SW name} (True). Possible values: True or False.
${CB007447_SHARED_RM_SN_EXCEPTIONS_LIST}                         # CPRI shared RM serial number list separated by comma that don't support feature
                                                                 # CB007447 (only in case CB007447 is activated)
${RECOVER_BTS_SW}                           False                # Specify if final running BTS SW build should be aligned to ${Target SW name}
                                                                 # (False) or ${Initial SW name} (True). Possible values: True or False.
${SECONDARY_CONTROLLER_BTS_SW_UPDATE}       True                 # Specify if secondary controller BTS SW Update will be performed (True) or
                                                                 # not (False). Possible values: True or False.

*** Keywords ***
TC__SBTS_SBTS__SWM__RU_SW_Upgrade
    [Documentation]
    ...  [CASE LINK]: https://jiradc.ext.net.nokia.com/browse/TAT-28382
    ...
    ...  *****************
    ...  Basic information
    ...  *****************
    ...  SBTS-SBTS test case for RU SW Upgrade.
    ...  The main steps performed for the test are:
    ...  - check initial state and alarms for both BTS
    ...  - get both BTS info for configured items
    ...  - get target SW for RU and BTS SW Update
    ...  - get recover SW builds (initial and intermediate SW) for BTS SW Update (needed only if ${REPEAT_COUNTER} > 1)
    ...  - check feature CB006028 for shared RM on both BTS (fail test if found CB006028 enabled)
    ...  - check feature CB007447 status on both BTS (fail test if found CB007447 disabled)
    ...  - check RU SW Upgrade feature activated on BTS primary controller (CB010780 or CB013660) and set specific parameters if needed
    ...  - perform SW Update as follows:
    ...    - get initial BTS and RM SW versions on both BTS
    ...    - get and check RM SW versions from BTS Target SW version
    ...    - set RM parameter (CB010780 disableSWUpdate=true or CB013660 upgradePhase=No upgrade/DU) to skip RU SW Upgrade if needed
    ...    - perform RU SW Update on BTS primary controller with peer and own BTS checks
    ...    - set RM parameter (CB010780 disableSWUpdate=false or CB013660 upgradePhase=none) to allow DU+RU SW Update on skipped RM
    ...    - perform DU+RU SW Update on BTS primary controller with peer and own BTS checks
    ...    - perform DU+RU SW Update on BTS secondary controller with peer and own BTS checks
    ...    - perform intermediate SW Update on both BTS (only if no final cycle run)
    ...    - perform initial SW Update on both BTS (only if no final cycle run)
    ...    - get final BTS and RM SW versions on both BTS
    ...    - check BTS and RM SW versions from BTS partitions after SW Update
    ...  - check final state and alarms for both BTS
    ...  Pass criteria: BTS SW Update operation works as expected, states and alarms are as expected
    ...
    ...  ******************
    ...  History of changes
    ...  ******************
    ...  - 9.12.2024 - https://jiradc.ext.net.nokia.com/browse/TAT-28382 - [5G] [CB012267] Adapt SBTS_SBTS_SBTS_SBTS__SWM__SW_Update with new
    ...  update_sotfware KW with new upgrade only RU option
    ...  - 17.01.2025 - https://jiradc.ext.net.nokia.com/browse/TAT-28574 - RF SW Timestamp check enhancements in SWM Tcs - after TAT-28573
    ...  - 12.09.2025 - https://jiradc.ext.net.nokia.com/browse/TAT-29863 -
    ...  [5G]Adapt SBTS_SBTS__SWM__SW_Update_CB010780 to work with new parameter MNL.ruPhaseSwActivationResetPolicy
    ...  - 18.09.2025 - https://jiradc.ext.net.nokia.com/browse/TAT-29893 -
    ...  Adapt SBTS_SBTS__SWM__RU_SW_Upgrade to work with ruPhaseSwActivationResetPolicy = "User configuration", ruPhaseResetOrder & upgradePhase
    ...  - 01.10.2025 - https://jiradc.ext.net.nokia.com/browse/TAT-29895 -
    ...  Adapt SBTS_SBTS__SWM__RU_SW_Upgrade to work with ruPhaseSwActivationResetPolicy = "Sequential", upgradePhase configured
    ...  - 07.10.2025 - https://jiradc.ext.net.nokia.com/browse/TAT-29897 -
    ...  Adapt SBTS_SBTS__SWM__SW_Update_CB010780 to work with new parameter MNL.ruPhaseSwActivationResetPolicy = "Simultaneous", upgradePhase ="DU"
    ...  - 13.10.2025 - https://jiradc.ext.net.nokia.com/browse/TAT-29894 -
    ...  Adapt SBTS_SBTS__SWM__RU_SW_Upgrade to work with ruPhaseSwActivationResetPolicy = "Together per HW type", upgradePhase configured
    ...  - 20.10.2025 - https://jiradc.ext.net.nokia.com/browse/TAT-29896 -
    ...  Adapt SBTS_SBTS__SWM__RU_SW_Upgrade to work with ruPhaseSwActivationResetPolicy = "Together per band", upgradePhase configured
    ...  - 06.11.2025 - https://jiradc.ext.net.nokia.com/browse/TAT-30167 - Adapt SBTS_SBTS__SWM__RU_SW_Upgrade with TMO upgrade scenario(decoupling)
    ...  - 13.11.2025 - https://jiradc.ext.net.nokia.com/browse/TAT-30182 - Adapt SBTS_SBTS__SWM__RU_SW_Upgrade for running from CM
    ...  - 14.11.2025 - https://jiradc.ext.net.nokia.com/browse/TAT-30184 -
    ...  Adapt SBTS_SBTS__SWM__RU_SW_Upgrade with recover BTS SW when ${REPEAT_COUNTER} == 1
    ...  - 18.11.2025 - https://jiradc.ext.net.nokia.com/browse/TAT-30218 -  Update SBTS_SBTS__SWM__RU_SW_Upgrade
    ...  - 27.11.2025 - https://jiradc.ext.net.nokia.com/browse/TAT-30221 - Remove ${actForceUnitAutoReset}' in tests and KWs related to CB007447
    ...  - 26.01.2026 - https://jiradc.ext.net.nokia.com/browse/TAT-30417 - Skip availabilityStatus check in SBTS_SBTS__SWM__RU_SW_Upgrad
    ...

    Set Tags    CA-SWM    OWNER-petronela.daraban@nokia.com    AUTHOR-anca.tatar@nokia.com    PHASE-QT    SW-SBTS26R1

    TC Preconditions
    Step 1: Check initial both BTS state
    Step 2: Check initial both BTS alarms
    Step 3: Get both BTS info for configured items
    Step 4: Get Target SW for BTS SW Update
    Step 5: Get Recover SW builds
    Step 6: Check feature CB006028 status on both BTS
    Step 7: Check feature CB007447 status on both BTS
    Step 8: Check RU SW Upgrade feature settings on BTS primary controller
    FOR  ${INDEX}  IN RANGE  1  ${REPEAT_COUNTER}+1
        Log  ==============================================================================  console=True
        Log  Start Cycle ${INDEX} of ${REPEAT_COUNTER}  console=True
        Log  ==============================================================================  console=True
        Step 9: Perform SW Update for iteration ${INDEX}
        Step 10: Check final both BTS state
        Step 11: Check final both BTS alarms
        Step 12: Check final number and state of Cells and RMs
    END

    [Teardown]  Particular Teardown

TC Preconditions
    ${BTS_alias_RM_sn_dict}  ${RM_sn_BTS_alias_dict}  ${shared_RM_sn_list}  ${dedicated_RM_sn_list}=  Get all BTS RMOD sharing info
    Set Test Variable  ${BTS_alias_RM_sn_dict}
    Set Test Variable  ${RM_sn_BTS_alias_dict}
    Set Test Variable  ${shared_RM_sn_list}
    Set Test Variable  ${dedicated_RM_sn_list}
    ${RM_sn_list}=  Get Dictionary Keys  ${RM_sn_BTS_alias_dict}
    Set Test Variable  ${RM_sn_list}

    ${BTS_primary_controller}=  Check BTS primary controller info
    Set Test Variable  ${BTS_RU_SW_UPDATE_alias}  ${BTS_primary_controller}

    ${RuSwUpgrade_feature}=  Check RU SW Upgrade feature info  ${BTS_RU_SW_UPDATE_alias}
    Set Test Variable  ${RuSwUpgrade_feature}

    Run Keyword If  '${RuSwUpgrade_feature}' == 'CB010780'
    ...  Check CB010780 feature info
    ...  ELSE IF  '${RuSwUpgrade_feature}' == 'CB013660'
    ...  Check CB013660 feature info

    Check CB007447 feature info

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

    FOR  ${alias}  IN  @{alias_list}

        ${BTS_RM_sn_id_dict}  ${BTS_RM_id_sn_dict}  ${BTS_RM_sn_pn_dict}  ${BTS_RM_sn_interface_dict}=  Admin Get RMOD sn id pn interface info
        ...  alias=${alias}
        Set Test Variable  ${${alias}_RM_sn_id_dict}  ${BTS_RM_sn_id_dict}
        Set Test Variable  ${${alias}_RM_id_sn_dict}  ${BTS_RM_id_sn_dict}
        Set Test Variable  ${${alias}_RM_sn_pn_dict}  ${BTS_RM_sn_pn_dict}
        Set Test Variable  ${${alias}_RM_sn_interface_dict}  ${BTS_RM_sn_interface_dict}

        ${BTS_dedicated_RM_sn_list}=  Get dedicated RM list  ${dedicated_RM_sn_list}  ${alias}
        ${BTS_dedicated_RM_count}=  Get Length  ${BTS_dedicated_RM_sn_list}
        Set Test Variable  ${${alias}_dedicated_RM_sn_list}  ${BTS_dedicated_RM_sn_list}
        Set Test Variable  ${${alias}_dedicated_RM_count}  ${BTS_dedicated_RM_count}

        ${RMOD_id_CELL_id_dict}=  Get RMOD CELL mapping based on Carrier info  ${alias}
        Set Test Variable  ${${alias}_RMOD_id_CELL_id_dict}  ${RMOD_id_CELL_id_dict}

    END

    Set Test Variable  ${RM_state_enabled_check}  operationalState=${Enabled_}, administrativeState=${Unlocked_}
    Set Test Variable  ${RM_state_enabled}  operationalState=Enabled, administrativeState=Unlocked
    Set Test Variable  ${CELL_state_enabled_check}  operationalState=${Enabled_}, blockingState=${Unblocked_}
    Set Test Variable  ${CELL_state_enabled}  operationalState=Enabled, blockingState=Unblocked

Step ${index}: Get Recover SW builds

    Return From Keyword If  '${RECOVER_BTS_SW}' == 'False' and ${REPEAT_COUNTER} == 1

    Log  Step ${index}: Get Recover SW builds  console=True

    Run Keyword If  '${FORCE_CURRENT_SW_DL}' == 'True'  Run Keywords
    ...  Download SW from WFT
    ...  AND  Return From Keyword

    Log  Get Initial SW Build:  console=True
    Get BTS SW build  sw_build_type=initial  sw_build_name=${Initial SW name}
    Log  Get Intermediate SW Build:  console=True
    Get BTS SW build  sw_build_type=intermediate  sw_build_name=${Intermediate SW name}

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
    Set Test Variable  ${target_SW_build}  ${Target SW}
    Log  Target SW for BTS SW Update: ${Target SW}  console=True
    Check if SW version already exists on BTS
    ${target_sw_path}  ${target_sw_file}=  Split Path  ${Target SW}
    ${target_sw_name}  ${ext}=  Split Extension  ${target_sw_file}
    ${qc_target_sw}=  Convert To Uppercase  ${target_sw_name}
    Set Test Variable  ${Target SW name}
    FOR  ${alias}  IN  @{alias_list}
        Set Qc Parameter  qc_tc_swbuild  ${qc_target_sw}; ${QC ${alias} Active SW}
    END

    ${TargetBD_xml}=  Get TargetBD File From SW Package  ${Target SW}
    Set Test Variable  ${TargetBD_xml_file}  ${TargetBD_xml}

Step ${index}: Check feature CB006028 status on both BTS
    Log  Step ${index}: Check feature CB006028 status on both BTS  console=True

    ${CB006028_activated_RM_list}=  Create List

    FOR  ${RM_sn}  IN  @{shared_RM_sn_list}

        ${actIndSwUpgradeForSharedRU_list}=  Get RMOD actIndSwUpgradeForSharedRU parameter  ${RM_sn}
        ${actIndSwUpgradeForSharedRU_count}=  Get Length  ${actIndSwUpgradeForSharedRU_list}

        Run Keyword If  ${actIndSwUpgradeForSharedRU_count} == 1 and 'true' in ${actIndSwUpgradeForSharedRU_list}  Run Keywords
        ...  Append To List  ${CB006028_activated_RM_list}  ${RM_sn}
        ...  AND  Log  Shared RM with SN ${RM_sn} feature CB006028 status: Enabled  console=True
        ...  ELSE
        ...  Log  Shared RM with SN ${RM_sn} feature CB006028 status: Disabled  console=True

    END

    ${CB006028_activated_RM_count}=  Get Length  ${CB006028_activated_RM_list}
    Run Keyword If  ${CB006028_activated_RM_count} > 0  Run Keywords
    ...  Log Long String  Feature CB006028 is activated on following shared RM list: ${CB006028_activated_RM_list}. Please deactivate feature
    ...  CB006028 on them!  console=True
    ...  AND  Fail  Feature CB006028 is activated on following shared RM list: ${CB006028_activated_RM_list}. Please deactivate feature CB006028!

Step ${index}: Check feature CB007447 status on both BTS
    Log  Step ${index}: Check feature CB007447 status on both BTS  console=True

    FOR  ${alias}  IN  @{alias_list}

        Log  Get feature CB007447 status on BTS ${alias}  console=True

        ${actCpriLinkRecovery}  ${actSyncLinkSwitchover}  ${cpriSyncBreakTime}  ${stickToSyncSourcePeriod}=  Get feature CB007447 info  ${alias}

        ${condition}=  Create Long String  '${actCpriLinkRecovery}' == 'true' and '${actSyncLinkSwitchover}' == 'true'

        Run Keyword If  ${condition}  Run Keywords
        ...  Log  BTS ${alias} feature CB007447 status: Enabled  console=True
        ...  AND  Set Test Variable  ${${alias}_CB007447_check}  ${TRUE}
        ...  ELSE  Run Keywords
        ...  Log  BTS ${alias} feature CB007447 status: Disabled  console=True
        ...  AND  Set Test Variable  ${${alias}_CB007447_check}  ${FALSE}
        ...  AND  Fail  Feature CB007447 is not activated on BTS ${alias}. Please activate feature CB007447!

    END

Step ${index}: Check RU SW Upgrade feature settings on BTS primary controller
    Log  Step ${index}: Check RU SW Upgrade feature settings on BTS primary controller  console=True

    Run Keyword If  '${RuSwUpgrade_feature}' == 'CB010780'
    ...  Check CB010780 feature settings  ${BTS_RU_SW_UPDATE_alias}
    ...  ELSE IF  '${RuSwUpgrade_feature}' == 'CB013660'
    ...  Check CB013660 feature settings  ${BTS_RU_SW_UPDATE_alias}

Step ${index}: Perform SW Update for iteration ${CYCLE}
    [Documentation]
    ...  Perform SW Update on BTS

    Log  Step ${index}: Perform SW Update for iteration ${CYCLE}  console=True

    ${BTS_alias}=  Set Variable  ${BTS_RU_SW_UPDATE_alias}
    ${BTS_peer_alias}=  Set Variable If  '${BTS_RU_SW_UPDATE_alias}' == 'Master'  Slave  Master
    Set Test Variable  ${SECONDARY_CONTROLLER_BTS_alias}  ${BTS_peer_alias}

    Log  Step ${index}.1: Get initial BTS SW versions on both BTS  console=True
    Get BTS SW versions on both BTS  when=initial

    Log  Step ${index}.2: Get initial RM SW versions on both BTS  console=True
    Get RM SW versions on both BTS  when=initial

    Log  Step ${index}.3: Get and check RM SW versions from BTS Target SW version  console=True
    Get and check RM SW versions from BTS Target SW version

    Log  Step ${index}.4: Set RU SW Update parameter on requested RMs before BTS ${BTS_alias} RU SW Update  console=True
    Control RU SW Update on requested RMs  alias=${BTS_alias}  when=initial

    Log  Step ${index}.5: Get both BTS impact before BTS ${BTS_alias} RU SW Update  console=True
    Get both BTS impact during RU SW Upgrade  alias=${BTS_alias}  peer_alias=${BTS_peer_alias}

    Log  Step ${index}.6: Perform RU SW Update on primary controller BTS ${BTS_alias}  console=True
    Perform RU SW Update from BTS  alias=${BTS_alias}  peer_alias=${BTS_peer_alias}

    Log  Step ${index}.7: Set RU SW Update parameter RU SW Update on requested RMs after BTS ${BTS_alias} RU SW Update  console=True
    Control RU SW Update on requested RMs  alias=${BTS_alias}  when=after_RU_SW_Update

    Log  Step ${index}.8: Get shared RM impact on peer BTS ${BTS_peer_alias} before BTS ${BTS_alias} DU+RU SW Update  console=True
    Get shared RM impact on peer BTS  alias=${BTS_alias}  peer_alias=${BTS_peer_alias}  when=after_RU_SW_Update

    Log  Step ${index}.9: Perform DU+RU SW Update on primary controller BTS ${BTS_alias}  console=True
    Perform DU+RU SW Update from BTS  alias=${BTS_alias}  peer_alias=${BTS_peer_alias}

    Log  Step ${index}.10: Get shared RM impact on peer BTS ${BTS_alias} before BTS ${BTS_peer_alias} DU+RU SW Update  console=True
    Get shared RM impact on peer BTS  alias=${BTS_peer_alias}  peer_alias=${BTS_alias}  when=after_DU_RU_SW_Update

    Log  Step ${index}.11: Perform DU+RU SW Update on secondary controller BTS ${BTS_peer_alias}  console=True
    Perform DU+RU SW Update from BTS  alias=${BTS_peer_alias}  peer_alias=${BTS_alias}

    Log  Step ${index}.12: Get final BTS SW versions on both BTS  console=True
    Get BTS SW versions on both BTS  when=final

    Log  Step ${index}.13: Get final RM SW versions on both BTS  console=True
    Get RM SW versions on both BTS  when=final

    Log  Step ${index}.14: Check BTS and RM SW versions from BTS partitions after SW Update  console=True
    Check BTS and RM SW versions from BTS partitions after SW Update

    Return From Keyword If  '${RECOVER_BTS_SW}' == 'False' and (${REPEAT_COUNTER} == 1 or ${CYCLE} == ${REPEAT_COUNTER})

    Log  ======================================  console=True
    Log  Recover initial running SW on both BTS  console=True
    Log  ======================================  console=True

    Log  Step ${index}.15: Perform SW Update in an intermediate software on both BTS  console=True
    Perform recover SW Update on both BTS  sw_update_type=intermediate

    Log  Step ${index}.16: Perform SW Update in the initial software on both BTS  console=True
    Perform recover SW Update on both BTS  sw_update_type=initial

Step ${index}: Check final number and state of Cells and RMs
    [Documentation]
    ...  Following checks are performed:
    ...  - number of configured cells and radio modules in SCF are properly mapped on BTS running view ADMIN
    ...  - check cells states
    ...  - check radio modules states

    Log  Step ${index}: Check final number and state of Cells and RMs  console=True
    RFS Test Case Final Checks

Check BTS primary controller info
    Log  Check BTS controller role for shared RMs  console=True

    ${BTS_primary_controller_list}=  Create List

    FOR  ${alias}  IN  @{alias_list}

        ${BTS_primary_controller_shared_RM_sn_list}  ${BTS_secondary_controller_shared_RM_sn_list}=
        ...  Get BTS controller role shared RM SN list from SCF  ${shared_RM_sn_list}  ${alias}
        Set Test Variable  ${${alias}_primary_controller_shared_RM_sn_list}  ${BTS_primary_controller_shared_RM_sn_list}
        ${BTS_primary_controller_shared_RM_count}=  Get Length  ${BTS_primary_controller_shared_RM_sn_list}
        Run Keyword If  ${BTS_primary_controller_shared_RM_count} > 0
        ...  Append To List  ${BTS_primary_controller_list}  ${alias}

    END

    ${BTS_primary_controller_list}=  Remove Duplicates  ${BTS_primary_controller_list}
    ${BTS_primary_controller_count}=  Get Length  ${BTS_primary_controller_list}
    Run Keyword If  ${BTS_primary_controller_count} > 1  Run Keywords
    ...  Log  Both BTS Master and Slave have primary controller role for shared RMs  console=True
    ...  AND  Fail  Both BTS Master and Slave have primary controller role for shared RMs

    ${BTS_primary_controller}=  Set Variable  ${BTS_primary_controller_list[0]}
    ${BTS_secondary_controller}=  Set Variable If  '${BTS_primary_controller}' == 'Master'  Slave  Master
    Log  - BTS primary controller role: ${BTS_primary_controller}  console=True
    Log  - BTS secondary controller role: ${BTS_secondary_controller}  console=True

    [Return]  ${BTS_primary_controller}

Check RU SW Upgrade feature info
    [Arguments]  ${alias}

    ${RuSwUpgrade_feature_list}=  Create List

    Log  Check BTS ${alias} RU SW Upgrade feature  console=True

    ${RuSwUpgrade_feature}=  Get RU SW Upgrade feature info  ${alias}
    Log  - BTS ${alias} RU SW Upgrade feature: ${RuSwUpgrade_feature}  console=True

    Run Keyword If  '${RuSwUpgrade_feature}' == 'none'  Run Keywords
    ...  Log  No RU SW Upgrade feature CB010780 or CB013660 activated on BTS ${alias}
    ...  AND  Fail  No RU SW Upgrade feature CB010780 or CB013660 activated on BTS ${alias}

    Run Keyword If  '${RuSwUpgrade_feature}' == 'CB010780_CB013660'  Run Keywords
    ...  Log  Both RU SW Upgrade features CB010780 and CB013660 activated on BTS ${alias}
    ...  AND  Fail  Both RU SW Upgrade features CB010780 and CB013660 activated on BTS ${alias}

    [Return]  ${RuSwUpgrade_feature}

Check CB010780 feature info
    ${CB010780_sequentialRuSwUpgrade_list}=  Create List  true  false
    Run Keyword If  '${CB010780_sequentialRuSwUpgrade}' not in ${CB010780_sequentialRuSwUpgrade_list}  Run Keywords
    ...  Log Long String  Selected CB010780 feature parameter sequentialRuSwUpgrade value: ${CB010780_sequentialRuSwUpgrade} is not valid. Please
    ...  select value for test argument \${CB010780_sequentialRuSwUpgrade} from: ${CB010780_sequentialRuSwUpgrade_list} or let default value: false
    ...  console=True
    ...  AND  Fail  Improper value for argument!

    ${No_upgrade_RM_sn_list}=  Run Keyword If  '${CB010780_NO_UPGRADE_RM_SN_LIST}' != ''
    ...  Check item list  CB010780_NO_UPGRADE_RM_SN_LIST  ${RM_sn_list}
    ...  ELSE
    ...  Create List
    Set Test Variable  ${No_upgrade_SW_RM_sn_list}  ${No_upgrade_RM_sn_list}

Check CB013660 feature info
    ${CB013660_ruPhaseSwActivationResetPolicy_list}=  Create List  Simultaneous  Sequential  User configuration  Together per HW type
    ...  Together per band
    Run Keyword If  '${CB013660_ruPhaseSwActivationResetPolicy}' not in ${CB013660_ruPhaseSwActivationResetPolicy_list}  Run Keywords
    ...  Log Long String  Selected CB013660 feature parameter ruPhaseSwActivationResetPolicy value: ${CB013660_ruPhaseSwActivationResetPolicy} is not
    ...  valid. Please select value for test argument \${CB013660_ruPhaseSwActivationResetPolicy} from:
    ...  ${CB013660_ruPhaseSwActivationResetPolicy_list} or let default value: Simultaneous  console=True
    ...  AND  Fail  Improper value for argument!

    ${No_upgrade_RM_sn_list}=  Run Keyword If  '${CB013660_NO_UPGRADE_RM_SN_LIST}' != ''
    ...  Check item list  CB013660_NO_UPGRADE_RM_SN_LIST  ${RM_sn_list}
    ...  ELSE
    ...  Create List
    Set Test Variable  ${No_upgrade_SW_No_upgrade_RM_sn_list}  ${No_upgrade_RM_sn_list}

    ${DU_RM_sn_list}=  Run Keyword If  '${CB013660_DU_RM_SN_LIST}' != ''
    ...  Check item list  CB013660_DU_RM_SN_LIST  ${RM_sn_list}
    ...  ELSE
    ...  Create List
    Set Test Variable  ${No_upgrade_SW_DU_RM_sn_list}  ${DU_RM_sn_list}

    ${RU_RM_sn_list}=  Run Keyword If  '${CB013660_RU_RM_SN_LIST}' != ''
    ...  Check item list  CB013660_RU_RM_SN_LIST  ${RM_sn_list}
    ...  ELSE
    ...  Create List
    Set Test Variable  ${Upgrade_SW_RU_RM_sn_list}  ${RU_RM_sn_list}

    ${No_upgrade_SW_RM_sn_list}=  Combine Lists  ${No_upgrade_RM_sn_list}  ${DU_RM_sn_list}
    Set Test Variable  ${No_upgrade_SW_RM_sn_list}

    Run Keyword If  '${CB013660_ruPhaseSwActivationResetPolicy}' == 'User configuration'
    ...  Check CB013660 feature info for User configuration

Check CB007447 feature info
    ${CB007447_exempted_shared_RM_sn_list}=  Run Keyword If  '${CB007447_SHARED_RM_SN_EXCEPTIONS_LIST}' != ''
    ...  Check item list  CB007447_SHARED_RM_SN_EXCEPTIONS_LIST  ${shared_RM_sn_list}
    ...  ELSE
    ...  Create List
    Set Test Variable  ${CB007447_exempted_shared_RM_sn_list}

Check CB013660 feature info for User configuration
    ${1st_reset_order_RM_sn_list}=  Run Keyword If  '${RU_FIRST_GROUP_RESET_RM_SN_LIST}' != ''
    ...  Check item list  RU_FIRST_GROUP_RESET_RM_SN_LIST  ${RM_sn_list}
    ...  ELSE
    ...  Create List
    Set Test Variable  ${1st_reset_order_RM_sn_list}

    ${2nd_reset_order_RM_sn_list}=  Run Keyword If  '${RU_SECOND_GROUP_RESET_RM_SN_LIST}' != ''
    ...  Check item list  RU_SECOND_GROUP_RESET_RM_SN_LIST  ${RM_sn_list}
    ...  ELSE
    ...  Create List
    Set Test Variable  ${2nd_reset_order_RM_sn_list}

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
    ...  from configured items: ${item_list} or let default value  console=True
    ...  AND  Fail  Improper value for argument!

    [Return]  ${item_valid_list}

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
    [Arguments]  ${sw_build_type}  ${sw_build_name}

    ${SW tmp}=  Get SW file for SWDL  SW dir=${Target SW dir}  SW name=${sw_build_name}
    Rename Software Package  ${SW tmp}
    Set Test Variable  ${${sw_build_type}_SW_build}  ${Target SW}

Get and Check Target SW for BTS SW Update
    Download And Set Current SW for SWDL  Target_SW_dir=${Target SW dir}
    Check if SW version already exists on BTS
    Set Test Variable  ${Target SW name}  ${Target Package Name}
    Set Test Variable  ${target_SW_build}  ${Target SW}
    ${TargetBD_xml}=  Get TargetBD File From SW Package  ${Target SW}
    Set Test Variable  ${TargetBD_xml_file}  ${TargetBD_xml}

Check if SW version already exists on BTS
    FOR  ${alias}  IN  @{alias_list}
        Check if SW already exists on BTS  ${Target SW}  ${${alias} active SW}  ${${alias} passive SW}
    END

Get BTS SW versions on both BTS
    [Arguments]  ${when}

    FOR  ${alias}  IN  @{alias_list}
        Admin Get BTS SW Version  alias=${alias}
        Set Test Variable  ${${alias} ${when} active SW}  ${${alias} active SW}
        Set Test Variable  ${${alias} ${when} passive SW}  ${${alias} passive SW}
    END

Get RM SW versions on both BTS
    [Arguments]  ${when}

     FOR  ${alias}  IN  @{alias_list}
         Get RM SW info dict on BTS  ${alias}  ${when}
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

    FOR  ${alias}  IN   @{alias_list}

        Get RM SW versions from BTS Target SW version  ${alias}
        Check RM SW versions from BTS Target SW version  ${alias}  initial

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

     FOR  ${RM_sn}  IN  @{${alias}_RM_serialNumber_list}
        ${newer_RM_SW_buildVersion_found}=  Compare RM SW info  ${alias}  ${RM_sn}  ${when}
        Run Keyword If  '${newer_RM_SW_buildVersion_found}' == 'True'
        ...  Append To List  ${RM_sn_newer_SW_buildVersion_list}  ${RM_sn}
     END

     Set Test Variable  ${${alias}_${when}_RM_sn_newer_SW_buildVersion_list}  ${RM_sn_newer_SW_buildVersion_list}

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

Control RU SW Update on requested RMs
    [Arguments]  ${alias}  ${when}

    Run Keyword If  '${RuSwUpgrade_feature}' == 'CB010780' and '${when}' == 'initial'
    ...  Set RMOD disableSWUpdate parameter  BTS_RM_sn_list=${No_upgrade_SW_RM_sn_list}  disableSWUpdate=true  alias=${alias}
    ...  ELSE IF  '${RuSwUpgrade_feature}' == 'CB010780' and '${when}' == 'after_RU_SW_Update' and '${CHANGE_RM_UPGRADE_PARAMETER}' == 'True'
    ...  Set RMOD disableSWUpdate parameter  BTS_RM_sn_list=${No_upgrade_SW_RM_sn_list}  disableSWUpdate=false  alias=${alias}
    ...  ELSE IF  '${RuSwUpgrade_feature}' == 'CB013660' and '${when}' == 'initial'  Run Keywords
    ...  Set RMOD upgradePhase parameter  BTS_RM_sn_list=${No_upgrade_SW_No_upgrade_RM_sn_list}  upgradePhase=No upgrade  alias=${alias}
    ...  AND  Set RMOD upgradePhase parameter  BTS_RM_sn_list=${No_upgrade_SW_DU_RM_sn_list}  upgradePhase=DU  alias=${alias}
    ...  AND  Set RMOD upgradePhase parameter  BTS_RM_sn_list=${Upgrade_SW_RU_RM_sn_list}  upgradePhase=RU  alias=${alias}
    ...  ELSE IF  '${RuSwUpgrade_feature}' == 'CB013660' and '${when}' == 'after_RU_SW_Update' and '${CHANGE_RM_UPGRADE_PARAMETER}' == 'True'
    ...  Set RMOD upgradePhase parameter  BTS_RM_sn_list=${No_upgrade_SW_RM_sn_list}  upgradePhase=none  alias=${alias}
    ...  ELSE IF  '${when}' == 'after_RU_SW_Update' and '${CHANGE_RM_UPGRADE_PARAMETER}' == 'False'
    ...  Log  No change needed for RU SW Update parameter after BTS ${alias} RU SW Update  console=True

Get both BTS impact during RU SW Upgrade
    [Arguments]  ${alias}  ${peer_alias}

    ${new_SW_dedicated_RM_sn_list}=  Get BTS new SW dedicated RM list during RU SW Update  ${alias}
    Set Test Variable  ${RU_SW_upgrade_new_SW_dedicated_RM_sn_list}  ${new_SW_dedicated_RM_sn_list}

    ${new_SW_shared_RM_sn_list}=  Get BTS new SW shared RM list during RU SW Update  ${alias}
    Set Test Variable  ${RU_SW_upgrade_new_SW_shared_RM_sn_list}  ${new_SW_shared_RM_sn_list}

    ${cond1}=  Set Variable  '${RuSwUpgrade_feature}' == 'CB010780' and '${CB010780_sequentialRuSwUpgrade}' == 'false'
    ${cond2}=  Set Variable  '${RuSwUpgrade_feature}' == 'CB010780' and '${CB010780_sequentialRuSwUpgrade}' == 'true'
    ${cond3}=  Set Variable  '${RuSwUpgrade_feature}' == 'CB013660' and '${CB013660_ruPhaseSwActivationResetPolicy}' == 'Simultaneous'
    ${cond4}=  Set Variable  '${RuSwUpgrade_feature}' == 'CB013660' and '${CB013660_ruPhaseSwActivationResetPolicy}' == 'Sequential'
    ${cond5}=  Set Variable  '${RuSwUpgrade_feature}' == 'CB013660' and '${CB013660_ruPhaseSwActivationResetPolicy}' == 'User configuration'
    ${cond6}=  Set Variable  '${RuSwUpgrade_feature}' == 'CB013660' and '${CB013660_ruPhaseSwActivationResetPolicy}' == 'Together per HW type'
    ${cond7}=  Set Variable  '${RuSwUpgrade_feature}' == 'CB013660' and '${CB013660_ruPhaseSwActivationResetPolicy}' == 'Together per band'

    Get BTS impact during RU SW Upgrade for requested no upgrade RM  ${alias}

    Run Keyword If  ${cond1} or ${cond3}
    ...  Get both BTS impact during RU SW Upgrade with simultaneous RU reset  ${alias}  ${peer_alias}
    ...  ELSE IF    ${cond2} or ${cond4}
    ...  Get both BTS impact during RU SW Upgrade with sequential RU reset  ${alias}
    ...  ELSE IF    ${cond5}
    ...  Get both BTS impact during RU SW Upgrade with user configuration RU reset  ${alias}  ${peer_alias}
    ...  ELSE IF    ${cond6}
    ...  Get both BTS impact during RU SW Upgrade with together per HW type RU reset  ${alias}
    ...  ELSE IF    ${cond7}
    ...  Get both BTS impact during RU SW Upgrade with together per band RU reset  ${alias}

Get BTS impact during RU SW Upgrade for requested no upgrade RM
    [Arguments]  ${alias}

    Log  Get BTS impact during RU SW Upgrade for requested no upgrade RM  console=True

    ${No_upgrade_CPRI_shared_RM_sn_list}=  Create List
    ${No_upgrade_ECPRI_shared_RM_sn_list}=  Create List
    ${No_upgrade_OBSAI_shared_RM_sn_list}=  Create List
    ${No_upgrade_dedicated_RM_sn_list}=  Create List

    FOR  ${RM_sn}  IN  @{No_upgrade_SW_RM_sn_list}

        Run Keyword If  '${RM_sn}' in ${${alias}_dedicated_RM_sn_list}  Run Keywords
        ...  Append To List  ${No_upgrade_dedicated_RM_sn_list}  ${RM_sn}
        ...  AND  Continue For Loop

        ${RM_L3Protocol}=  Get From Dictionary  ${${alias}_RM_sn_interface_dict}  ${RM_sn}

        Run Keyword If  '${RM_sn}' in ${${alias}_primary_controller_shared_RM_sn_list} and '${RM_L3Protocol}' == 'CPRI_RP1'
        ...  Append To List  ${No_upgrade_CPRI_shared_RM_sn_list}  ${RM_sn}
        ...  ELSE IF  '${RM_sn}' in ${${alias}_primary_controller_shared_RM_sn_list} and '${RM_L3Protocol}' == 'ECPRI_MPLANE'
        ...  Append To List  ${No_upgrade_ECPRI_shared_RM_sn_list}  ${RM_sn}
        ...  ELSE IF  '${RM_sn}' in ${${alias}_primary_controller_shared_RM_sn_list} and '${RM_L3Protocol}' == 'RP301_RP1'
        ...  Append To List  ${No_upgrade_OBSAI_shared_RM_sn_list}  ${RM_sn}

    END

    Set Test Variable  ${No_upgrade_CPRI_shared_RM_sn_list}
    Set Test Variable  ${No_upgrade_ECPRI_shared_RM_sn_list}
    Set Test Variable  ${No_upgrade_OBSAI_shared_RM_sn_list}
    Set Test Variable  ${No_upgrade_dedicated_RM_sn_list}
    ${No_upgrade_CPRI_shared_RM_count}=  Get Length  ${No_upgrade_CPRI_shared_RM_sn_list}
    ${No_upgrade_ECPRI_shared_RM_count}=  Get Length  ${No_upgrade_ECPRI_shared_RM_sn_list}
    ${No_upgrade_OBSAI_shared_RM_count}=  Get Length  ${No_upgrade_OBSAI_shared_RM_sn_list}
    ${No_upgrade_dedicated_RM_count}=  Get Length  ${No_upgrade_dedicated_RM_sn_list}
    Log  No upgrade CPRI shared RM count: ${No_upgrade_CPRI_shared_RM_count}   console=True
    Log  No upgrade ECPRI shared RM count: ${No_upgrade_ECPRI_shared_RM_count}   console=True
    Log  No upgrade OBSAI shared RM count: ${No_upgrade_OBSAI_shared_RM_count}   console=True
    Log  BTS ${alias} no upgrade dedicated RM count: ${No_upgrade_dedicated_RM_count}   console=True

Get both BTS impact during RU SW Upgrade with simultaneous RU reset
    [Arguments]  ${alias}  ${peer_alias}

    Log  Get both BTS impact during RU SW Upgrade with simultaneous RU reset  console=True

    ${new_SW_OBSAI_shared_RM_sn_list}=  Create List
    ${new_SW_CPRI_shared_RM_sn_list}=  Create List
    ${new_SW_ECPRI_shared_RM_sn_list}=  Create List

    FOR  ${RM_sn}  IN  @{RU_SW_upgrade_new_SW_shared_RM_sn_list}

        ${RM_L3Protocol}=  Get From Dictionary  ${${alias}_RM_sn_interface_dict}  ${RM_sn}
        Run Keyword If  '${RM_L3Protocol}' == 'CPRI_RP1'
        ...  Append To List  ${new_SW_CPRI_shared_RM_sn_list}  ${RM_sn}
        ...  ELSE IF  '${RM_L3Protocol}' == 'ECPRI_MPLANE'
        ...  Append To List  ${new_SW_ECPRI_shared_RM_sn_list}  ${RM_sn}
        ...  ELSE IF  '${RM_L3Protocol}' == 'RP301_RP1'
        ...  Append To List  ${new_SW_OBSAI_shared_RM_sn_list}  ${RM_sn}

    END

    Set Test Variable  ${new_SW_CPRI_shared_RM_sn_list}
    Set Test Variable  ${new_SW_ECPRI_shared_RM_sn_list}
    Set Test Variable  ${new_SW_OBSAI_shared_RM_sn_list}
    ${new_SW_CPRI_shared_RM_count}=  Get Length  ${new_SW_CPRI_shared_RM_sn_list}
    ${new_SW_ECPRI_shared_RM_count}=  Get Length  ${new_SW_ECPRI_shared_RM_sn_list}
    ${new_SW_OBSAI_shared_RM_count}=  Get Length  ${new_SW_OBSAI_shared_RM_sn_list}
    Log  Simultaneous new SW CPRI shared RM count: ${new_SW_CPRI_shared_RM_count}  console=True
    Log  Simultaneous new SW ECPRI shared RM count: ${new_SW_ECPRI_shared_RM_count}  console=True
    Log  Simultaneous new SW OBSAI shared RM count: ${new_SW_OBSAI_shared_RM_count}  console=True
    ${new_SW_CPRI_ECPRI_shared_RM_count}=  Evaluate  ${new_SW_CPRI_shared_RM_count} + ${new_SW_ECPRI_shared_RM_count}
    ${new_SW_shared_RM_count}=  Evaluate  ${new_SW_CPRI_ECPRI_shared_RM_count} + ${new_SW_OBSAI_shared_RM_count}
    Set Test Variable  ${new_SW_shared_RM_count}

    ${FID4773_alarm_count}=  Set Variable  ${new_SW_CPRI_ECPRI_shared_RM_count}
    ${FID10_alarm_count}=  Set Variable  ${new_SW_OBSAI_shared_RM_count}
    Set Test Variable  ${${peer_alias}_FID4773_alarm_count}  ${FID4773_alarm_count}
    Set Test Variable  ${${peer_alias}_FID10_alarm_count}  ${FID10_alarm_count}

    ${EXPECTED_ALARMS}=  Create List
    ${EXPECTED_ALARMS_4773_full}=  Prepare expected alarms list  ${${peer_alias.upper()}_EXPECTED_ALARMS_4773}  ${FID4773_alarm_count}
    ${EXPECTED_ALARMS_10_full}=  Prepare expected alarms list  ${${peer_alias.upper()}_EXPECTED_ALARMS_10}  ${FID10_alarm_count}
    ${EXPECTED_ALARMS}=  Combine Lists  ${EXPECTED_ALARMS_4773_full}  ${EXPECTED_ALARMS_10_full}
    Set Test Variable  ${${peer_alias.upper()}_EXPECTED_ALARMS}  ${EXPECTED_ALARMS}

    ${new_SW_dedicated_RM_count}=  Get Length  ${RU_SW_upgrade_new_SW_dedicated_RM_sn_list}
    Log  BTS ${alias} simultaneous new SW dedicated RM count: ${new_SW_dedicated_RM_count}  console=True
    Set Test Variable  ${new_SW_dedicated_RM_count}

Get both BTS impact during RU SW Upgrade with sequential RU reset
    [Arguments]  ${alias}

    Log  Get both BTS impact during RU SW Upgrade with sequential RU reset  console=True

    ${new_SW_OBSAI_shared_RM_sn_list}=  Create List
    ${new_SW_CPRI_shared_RM_sn_list}=  Create List
    ${new_SW_ECPRI_shared_RM_sn_list}=  Create List

    FOR  ${RM_sn}  IN  @{RU_SW_upgrade_new_SW_shared_RM_sn_list}

        ${RM_L3Protocol}=  Get From Dictionary  ${${alias}_RM_sn_interface_dict}  ${RM_sn}
        Run Keyword If  '${RM_L3Protocol}' == 'CPRI_RP1'
        ...  Append To List  ${new_SW_CPRI_shared_RM_sn_list}  ${RM_sn}
        ...  ELSE IF  '${RM_L3Protocol}' == 'ECPRI_MPLANE'
        ...  Append To List  ${new_SW_ECPRI_shared_RM_sn_list}  ${RM_sn}
        ...  ELSE IF  '${RM_L3Protocol}' == 'RP301_RP1'
        ...  Append To List  ${new_SW_OBSAI_shared_RM_sn_list}  ${RM_sn}

    END

    Set Test Variable  ${new_SW_CPRI_shared_RM_sn_list}
    Set Test Variable  ${new_SW_ECPRI_shared_RM_sn_list}
    Set Test Variable  ${new_SW_OBSAI_shared_RM_sn_list}
    ${new_SW_CPRI_shared_RM_count}=  Get Length  ${new_SW_CPRI_shared_RM_sn_list}
    ${new_SW_ECPRI_shared_RM_count}=  Get Length  ${new_SW_ECPRI_shared_RM_sn_list}
    ${new_SW_OBSAI_shared_RM_count}=  Get Length  ${new_SW_OBSAI_shared_RM_sn_list}
    Log  Sequential new SW CPRI shared RM count: ${new_SW_CPRI_shared_RM_count}  console=True
    Log  Sequential new SW ECPRI shared RM count: ${new_SW_ECPRI_shared_RM_count}  console=True
    Log  Sequential new SW OBSAI shared RM count: ${new_SW_OBSAI_shared_RM_count}  console=True

    ${new_SW_CPRI_ECPRI_shared_RM_count}=  Evaluate  ${new_SW_CPRI_shared_RM_count} + ${new_SW_ECPRI_shared_RM_count}
    ${new_SW_shared_RM_count}=  Evaluate  ${new_SW_CPRI_ECPRI_shared_RM_count} + ${new_SW_OBSAI_shared_RM_count}
    Set Test Variable  ${new_SW_shared_RM_count}

    ${new_SW_dedicated_RM_count}=  Get Length  ${RU_SW_upgrade_new_SW_dedicated_RM_sn_list}
    Log  BTS ${alias} sequential new SW dedicated RM count: ${new_SW_dedicated_RM_count}  console=True
    Set Test Variable  ${new_SW_dedicated_RM_count}

    ${new_SW_RM_count}=  Evaluate  ${new_SW_shared_RM_count} + ${new_SW_dedicated_RM_count}
    Set Test Variable  ${new_SW_RM_count}

Get both BTS impact during RU SW Upgrade with user configuration RU reset
    [Arguments]  ${alias}  ${peer_alias}

    Log  Get both BTS impact during RU SW Upgrade with user configuration RU reset  console=True

    ${defined_reset_order_RM_sn_list}=  Combine Lists  ${1st_reset_order_RM_sn_list}  ${2nd_reset_order_RM_sn_list}  ${No_upgrade_SW_RM_sn_list}

    ${1st_reset_order_new_SW_CPRI_shared_RM_sn_list}=  Create List
    ${1st_reset_order_new_SW_ECPRI_shared_RM_sn_list}=  Create List
    ${1st_reset_order_new_SW_OBSAI_shared_RM_sn_list}=  Create List

    FOR  ${RM_sn}  IN  @{RU_SW_upgrade_new_SW_shared_RM_sn_list}

        ${RM_L3Protocol}=  Get From Dictionary  ${${alias}_RM_sn_interface_dict}  ${RM_sn}
        Run Keyword If  '${RM_sn}' in ${1st_reset_order_RM_sn_list} and '${RM_L3Protocol}' == 'CPRI_RP1'
        ...  Append To List  ${1st_reset_order_new_SW_CPRI_shared_RM_sn_list}  ${RM_sn}
        ...  ELSE IF  '${RM_sn}' in ${1st_reset_order_RM_sn_list} and '${RM_L3Protocol}' == 'ECPRI_MPLANE'
        ...  Append To List  ${1st_reset_order_new_SW_ECPRI_shared_RM_sn_list}  ${RM_sn}
        ...  ELSE IF  '${RM_sn}' in ${1st_reset_order_RM_sn_list} and '${RM_L3Protocol}' == 'RP301_RP1'
        ...  Append To List  ${1st_reset_order_new_SW_OBSAI_shared_RM_sn_list}  ${RM_sn}

    END

    Set Test Variable  ${1st_reset_order_new_SW_CPRI_shared_RM_sn_list}
    Set Test Variable  ${1st_reset_order_new_SW_ECPRI_shared_RM_sn_list}
    Set Test Variable  ${1st_reset_order_new_SW_OBSAI_shared_RM_sn_list}
    ${1st_reset_order_new_SW_CPRI_shared_RM_count}=  Get Length  ${1st_reset_order_new_SW_CPRI_shared_RM_sn_list}
    ${1st_reset_order_new_SW_ECPRI_shared_RM_count}=  Get Length  ${1st_reset_order_new_SW_ECPRI_shared_RM_sn_list}
    ${1st_reset_order_new_SW_OBSAI_shared_RM_count}=  Get Length  ${1st_reset_order_new_SW_OBSAI_shared_RM_sn_list}
    Log  1st reset order new SW CPRI shared RM count: ${1st_reset_order_new_SW_CPRI_shared_RM_count}  console=True
    Log  1st reset order new SW ECPRI shared RM count: ${1st_reset_order_new_SW_ECPRI_shared_RM_count}  console=True
    Log  1st reset order new SW OBSAI shared RM count: ${1st_reset_order_new_SW_OBSAI_shared_RM_count}  console=True

    ${1st_reset_order_new_SW_CPRI_ECPRI_shared_RM_count}=
    ...  Evaluate  ${1st_reset_order_new_SW_CPRI_shared_RM_count} + ${1st_reset_order_new_SW_ECPRI_shared_RM_count}
    ${1st_reset_order_new_SW_shared_RM_count}=
    ...  Evaluate  ${1st_reset_order_new_SW_CPRI_ECPRI_shared_RM_count} + ${1st_reset_order_new_SW_OBSAI_shared_RM_count}
    Set Test Variable  ${1st_reset_order_new_SW_shared_RM_count}
    ${FID4773_alarm_count}=  Set Variable  ${1st_reset_order_new_SW_CPRI_ECPRI_shared_RM_count}
    ${FID10_alarm_count}=  Set Variable  ${1st_reset_order_new_SW_OBSAI_shared_RM_count}
    Set Test Variable  ${${peer_alias}_1st_reset_order_FID4773_alarm_count}  ${FID4773_alarm_count}
    Set Test Variable  ${${peer_alias}_1st_reset_order_FID10_alarm_count}  ${FID10_alarm_count}

    ${EXPECTED_ALARMS}=  Create List
    ${EXPECTED_ALARMS_4773_full}=  Prepare expected alarms list  ${${peer_alias.upper()}_EXPECTED_ALARMS_4773}  ${FID4773_alarm_count}
    ${EXPECTED_ALARMS_10_full}=  Prepare expected alarms list  ${${peer_alias.upper()}_EXPECTED_ALARMS_10}  ${FID10_alarm_count}
    ${EXPECTED_ALARMS}=  Combine Lists  ${EXPECTED_ALARMS_4773_full}  ${EXPECTED_ALARMS_10_full}
    Set Test Variable  ${${peer_alias.upper()}_EXPECTED_ALARMS_1st_reset_order}  ${EXPECTED_ALARMS}

    ${1st_reset_order_new_SW_dedicated_RM_sn_list}=  Create List

    FOR  ${RM_sn}  IN  @{RU_SW_upgrade_new_SW_dedicated_RM_sn_list}

        Run Keyword If  '${RM_sn}' in ${1st_reset_order_RM_sn_list}
        ...  Append To List  ${1st_reset_order_new_SW_dedicated_RM_sn_list}  ${RM_sn}

    END

    Set Test Variable  ${1st_reset_order_new_SW_dedicated_RM_sn_list}
    ${1st_reset_order_new_SW_dedicated_RM_count}=  Get Length  ${1st_reset_order_new_SW_dedicated_RM_sn_list}
    Log  BTS ${alias} 1st reset order new SW dedicated RM count: ${1st_reset_order_new_SW_dedicated_RM_count}  console=True
    Set Test Variable  ${1st_reset_order_new_SW_dedicated_RM_count}

    ${2nd_reset_order_new_SW_CPRI_shared_RM_sn_list}=  Create List
    ${2nd_reset_order_new_SW_ECPRI_shared_RM_sn_list}=  Create List
    ${2nd_reset_order_new_SW_OBSAI_shared_RM_sn_list}=  Create List

    FOR  ${RM_sn}  IN  @{RU_SW_upgrade_new_SW_shared_RM_sn_list}

        ${RM_L3Protocol}=  Get From Dictionary  ${${peer_alias}_RM_sn_interface_dict}  ${RM_sn}
        Run Keyword If  '${RM_sn}' in ${2nd_reset_order_RM_sn_list} and '${RM_L3Protocol}' == 'CPRI_RP1'
        ...  Append To List  ${2nd_reset_order_new_SW_CPRI_shared_RM_sn_list}  ${RM_sn}
        ...  ELSE IF  '${RM_sn}' in ${2nd_reset_order_RM_sn_list} and '${RM_L3Protocol}' == 'ECPRI_MPLANE'
        ...  Append To List  ${2nd_reset_order_new_SW_ECPRI_shared_RM_sn_list}  ${RM_sn}
        ...  ELSE IF  '${RM_sn}' in ${2nd_reset_order_RM_sn_list} and '${RM_L3Protocol}' == 'RP301_RP1'
        ...  Append To List  ${2nd_reset_order_new_SW_OBSAI_shared_RM_sn_list}  ${RM_sn}

    END

    Set Test Variable  ${2nd_reset_order_new_SW_CPRI_shared_RM_sn_list}
    Set Test Variable  ${2nd_reset_order_new_SW_ECPRI_shared_RM_sn_list}
    Set Test Variable  ${2nd_reset_order_new_SW_OBSAI_shared_RM_sn_list}
    ${2nd_reset_order_new_SW_CPRI_shared_RM_count}=  Get Length  ${2nd_reset_order_new_SW_CPRI_shared_RM_sn_list}
    ${2nd_reset_order_new_SW_ECPRI_shared_RM_count}=  Get Length  ${2nd_reset_order_new_SW_ECPRI_shared_RM_sn_list}
    ${2nd_reset_order_new_SW_OBSAI_shared_RM_count}=  Get Length  ${2nd_reset_order_new_SW_OBSAI_shared_RM_sn_list}
    Log  2nd reset order new SW CPRI shared RM count: ${2nd_reset_order_new_SW_CPRI_shared_RM_count}  console=True
    Log  2nd reset order new SW ECPRI shared RM count: ${2nd_reset_order_new_SW_ECPRI_shared_RM_count}  console=True
    Log  2nd reset order new SW OBSAI shared RM count: ${2nd_reset_order_new_SW_OBSAI_shared_RM_count}  console=True

    ${2nd_reset_order_new_SW_CPRI_ECPRI_shared_RM_count}=
    ...  Evaluate  ${2nd_reset_order_new_SW_CPRI_shared_RM_count} + ${2nd_reset_order_new_SW_ECPRI_shared_RM_count}
    ${2nd_reset_order_new_SW_shared_RM_count}=
    ...  Evaluate  ${2nd_reset_order_new_SW_CPRI_ECPRI_shared_RM_count} + ${2nd_reset_order_new_SW_OBSAI_shared_RM_count}
    Set Test Variable  ${2nd_reset_order_new_SW_shared_RM_count}
    ${FID4773_alarm_count}=  Set Variable  ${2nd_reset_order_new_SW_CPRI_ECPRI_shared_RM_count}
    ${FID10_alarm_count}=  Set Variable  ${2nd_reset_order_new_SW_OBSAI_shared_RM_count}
    Set Test Variable  ${${peer_alias}_2nd_reset_order_FID4773_alarm_count}  ${FID4773_alarm_count}
    Set Test Variable  ${${peer_alias}_2nd_reset_order_FID10_alarm_count}  ${FID10_alarm_count}

    ${EXPECTED_ALARMS}=  Create List
    ${EXPECTED_ALARMS_4773_full}=  Prepare expected alarms list  ${${peer_alias.upper()}_EXPECTED_ALARMS_4773}  ${FID4773_alarm_count}
    ${EXPECTED_ALARMS_10_full}=  Prepare expected alarms list  ${${peer_alias.upper()}_EXPECTED_ALARMS_10}  ${FID10_alarm_count}
    ${EXPECTED_ALARMS}=  Combine Lists  ${EXPECTED_ALARMS_4773_full}  ${EXPECTED_ALARMS_10_full}
    Set Test Variable  ${${peer_alias.upper()}_EXPECTED_ALARMS_2nd_reset_order}  ${EXPECTED_ALARMS}

    ${2nd_reset_order_new_SW_dedicated_RM_sn_list}=  Create List

    FOR  ${RM_sn}  IN  @{RU_SW_upgrade_new_SW_dedicated_RM_sn_list}

        Run Keyword If  '${RM_sn}' in ${2nd_reset_order_RM_sn_list}
        ...  Append To List  ${2nd_reset_order_new_SW_dedicated_RM_sn_list}  ${RM_sn}

    END

    Set Test Variable  ${2nd_reset_order_new_SW_dedicated_RM_sn_list}
    ${2nd_reset_order_new_SW_dedicated_RM_count}=  Get Length  ${2nd_reset_order_new_SW_dedicated_RM_sn_list}
    Log  BTS ${alias} 2nd reset order new SW dedicated RM count: ${2nd_reset_order_new_SW_dedicated_RM_count}  console=True
    Set Test Variable  ${2nd_reset_order_new_SW_dedicated_RM_count}

    ${undefined_reset_order_new_SW_CPRI_shared_RM_sn_list}=  Create List
    ${undefined_reset_order_new_SW_ECPRI_shared_RM_sn_list}=  Create List
    ${undefined_reset_order_new_SW_OBSAI_shared_RM_sn_list}=  Create List

    FOR  ${RM_sn}  IN  @{RU_SW_upgrade_new_SW_shared_RM_sn_list}

        ${RM_L3Protocol}=  Get From Dictionary  ${${peer_alias}_RM_sn_interface_dict}  ${RM_sn}
        Run Keyword If  '${RM_sn}' not in ${defined_reset_order_RM_sn_list} and '${RM_L3Protocol}' == 'CPRI_RP1'
        ...  Append To List  ${undefined_reset_order_new_SW_CPRI_shared_RM_sn_list}  ${RM_sn}
        ...  ELSE IF  '${RM_sn}' not in ${defined_reset_order_RM_sn_list} and '${RM_L3Protocol}' == 'ECPRI_MPLANE'
        ...  Append To List  ${undefined_reset_order_new_SW_ECPRI_shared_RM_sn_list}  ${RM_sn}
        ...  ELSE IF  '${RM_sn}' not in ${defined_reset_order_RM_sn_list} and '${RM_L3Protocol}' == 'RP301_RP1'
        ...  Append To List  ${undefined_reset_order_new_SW_OBSAI_shared_RM_sn_list}  ${RM_sn}

    END

    Set Test Variable  ${undefined_reset_order_new_SW_CPRI_shared_RM_sn_list}
    Set Test Variable  ${undefined_reset_order_new_SW_ECPRI_shared_RM_sn_list}
    Set Test Variable  ${undefined_reset_order_new_SW_OBSAI_shared_RM_sn_list}
    ${undefined_reset_order_new_SW_CPRI_shared_RM_count}=  Get Length  ${undefined_reset_order_new_SW_CPRI_shared_RM_sn_list}
    ${undefined_reset_order_new_SW_ECPRI_shared_RM_count}=  Get Length  ${undefined_reset_order_new_SW_ECPRI_shared_RM_sn_list}
    ${undefined_reset_order_new_SW_OBSAI_shared_RM_count}=  Get Length  ${undefined_reset_order_new_SW_OBSAI_shared_RM_sn_list}
    Log  Undefined reset order new SW CPRI shared RM count: ${undefined_reset_order_new_SW_CPRI_shared_RM_count}  console=True
    Log  Undefined reset order new SW ECPRI shared RM count: ${undefined_reset_order_new_SW_ECPRI_shared_RM_count}  console=True
    Log  Undefined reset order new SW OBSAI shared RM count: ${undefined_reset_order_new_SW_OBSAI_shared_RM_count}  console=True

    ${undefined_reset_order_new_SW_CPRI_ECPRI_shared_RM_count}=
    ...  Evaluate  ${undefined_reset_order_new_SW_CPRI_shared_RM_count} + ${undefined_reset_order_new_SW_ECPRI_shared_RM_count}
    ${undefined_reset_order_new_SW_shared_RM_count}=
    ...  Evaluate  ${undefined_reset_order_new_SW_CPRI_ECPRI_shared_RM_count} + ${undefined_reset_order_new_SW_OBSAI_shared_RM_count}
    Set Test Variable  ${undefined_reset_order_new_SW_shared_RM_count}
    ${FID4773_alarm_count}=  Set Variable  ${undefined_reset_order_new_SW_CPRI_ECPRI_shared_RM_count}
    ${FID10_alarm_count}=  Set Variable  ${undefined_reset_order_new_SW_OBSAI_shared_RM_count}
    Set Test Variable  ${${peer_alias}_undefined_reset_order_FID4773_alarm_count}  ${FID4773_alarm_count}
    Set Test Variable  ${${peer_alias}_undefined_reset_order_FID10_alarm_count}  ${FID10_alarm_count}

    ${EXPECTED_ALARMS}=  Create List
    ${EXPECTED_ALARMS_4773_full}=  Prepare expected alarms list  ${${peer_alias.upper()}_EXPECTED_ALARMS_4773}  ${FID4773_alarm_count}
    ${EXPECTED_ALARMS_10_full}=  Prepare expected alarms list  ${${peer_alias.upper()}_EXPECTED_ALARMS_10}  ${FID10_alarm_count}
    ${EXPECTED_ALARMS}=  Combine Lists  ${EXPECTED_ALARMS_4773_full}  ${EXPECTED_ALARMS_10_full}
    Set Test Variable  ${${peer_alias.upper()}_EXPECTED_ALARMS_undefined_reset_order}  ${EXPECTED_ALARMS}

    ${undefined_reset_order_new_SW_dedicated_RM_sn_list}=  Create List

    FOR  ${RM_sn}  IN  @{RU_SW_upgrade_new_SW_dedicated_RM_sn_list}

        Run Keyword If  '${RM_sn}' not in ${defined_reset_order_RM_sn_list}
        ...  Append To List  ${undefined_reset_order_new_SW_dedicated_RM_sn_list}  ${RM_sn}

    END

    Set Test Variable  ${undefined_reset_order_new_SW_dedicated_RM_sn_list}
    ${undefined_reset_order_new_SW_dedicated_RM_count}=  Get Length  ${undefined_reset_order_new_SW_dedicated_RM_sn_list}
    Log  BTS ${alias} undefined reset order new SW dedicated RM count: ${undefined_reset_order_new_SW_dedicated_RM_count}  console=True
    Set Test Variable  ${undefined_reset_order_new_SW_dedicated_RM_count}

Get both BTS impact during RU SW Upgrade with together per HW type RU reset
    [Arguments]  ${alias}

    Log  Get both BTS impact during RU SW Upgrade with together per HW type RU reset  console=True

    ${RM_pn_list}=  Get Dictionary Values  ${${alias}_RM_sn_pn_dict}
    ${RM_pn_list}=  Remove Duplicates  ${RM_pn_list}

    ${new_SW_shared_RM_pn_list}=  Create List
    ${new_SW_dedicated_RM_pn_list}=  Create List

    FOR  ${RM_pn}  IN  @{RM_pn_list}

        ${RM_pn_new_SW_shared_RM_sn_list}=  Get RM pn info impacted by RU SW Upgrade  ${RM_pn}  ${RU_SW_upgrade_new_SW_shared_RM_sn_list}  ${alias}
        Set Test Variable  ${${RM_pn}_new_SW_shared_RM_sn_list}  ${RM_pn_new_SW_shared_RM_sn_list}

        ${RM_pn_new_SW_shared_RM_count}=  Get Length  ${RM_pn_new_SW_shared_RM_sn_list}
        Run Keyword If  ${RM_pn_new_SW_shared_RM_count} > 0
        ...  Append To List  ${new_SW_shared_RM_pn_list}  ${RM_pn}

        ${RM_pn_new_SW_dedicated_RM_sn_list}=  Get RM pn info impacted by RU SW Upgrade  ${RM_pn}  ${RU_SW_upgrade_new_SW_dedicated_RM_sn_list}
        ...  ${alias}
        Set Test Variable  ${${RM_pn}_new_SW_dedicated_RM_sn_list}  ${RM_pn_new_SW_dedicated_RM_sn_list}

        ${RM_pn_new_SW_dedicated_RM_count}=  Get Length  ${RM_pn_new_SW_dedicated_RM_sn_list}
        Run Keyword If  ${RM_pn_new_SW_dedicated_RM_count} > 0
        ...  Append To List  ${new_SW_dedicated_RM_pn_list}  ${RM_pn}

    END

    ${new_SW_shared_RM_pn_list}=  Remove Duplicates  ${new_SW_shared_RM_pn_list}
    Set Test Variable  ${new_SW_shared_RM_pn_list}

    ${new_SW_dedicated_RM_pn_list}=  Remove Duplicates  ${new_SW_dedicated_RM_pn_list}
    Set Test Variable  ${new_SW_dedicated_RM_pn_list}

    FOR  ${RM_pn}  IN  @{new_SW_shared_RM_pn_list}

        ${new_SW_shared_RM_count}=  Get Length  ${${RM_pn}_new_SW_shared_RM_sn_list}
        Set Test Variable  ${${RM_pn}_new_SW_shared_RM_count}  ${new_SW_shared_RM_count}
        Log  Together per HW type new SW ${RM_pn} shared RM count: ${new_SW_shared_RM_count}  console=True

    END

    FOR  ${RM_pn}  IN  @{new_SW_dedicated_RM_pn_list}

        ${new_SW_dedicated_RM_count}=  Get Length  ${${RM_pn}_new_SW_dedicated_RM_sn_list}
        Set Test Variable  ${${RM_pn}_new_SW_dedicated_RM_count}  ${new_SW_dedicated_RM_count}
        Log  BTS ${alias} together per HW type new SW ${RM_pn} dedicated RM count: ${new_SW_dedicated_RM_count}  console=True

    END

    ${new_SW_RM_pn_list}=  Combine Lists  ${new_SW_shared_RM_pn_list}  ${new_SW_dedicated_RM_pn_list}
    ${new_SW_RM_pn_list}=  Remove Duplicates  ${new_SW_RM_pn_list}
    Set Test Variable  ${new_SW_RM_pn_list}
    ${new_SW_RM_pn_count}=  Get Length  ${new_SW_RM_pn_list}
    Set Test Variable  ${new_SW_RM_pn_count}

Get both BTS impact during RU SW Upgrade with together per band RU reset
    [Arguments]  ${alias}

    Log  Get both BTS impact during RU SW Upgrade with together per band reset  console=True

    ${RM_id_arfcn_dict}=  Get RMOD minimum arfcn info  ${alias}
    Set Test Variable  ${${alias}_RM_id_arfcn_dict}  ${RM_id_arfcn_dict}
    ${RM_arfcn_list}=  Get Dictionary Values  ${RM_id_arfcn_dict}
    ${RM_arfcn_list}=  Remove Duplicates  ${RM_arfcn_list}
    Set Test Variable  ${RM_arfcn_list}

    ${new_SW_shared_RM_arfcn_list}=  Create List
    ${new_SW_dedicated_RM_arfcn_list}=  Create List

    FOR  ${RM_arfcn}  IN  @{RM_arfcn_list}

        ${RM_arfcn_new_SW_shared_RM_sn_list}=  Get RM arfcn info impacted by RU SW Upgrade  ${RM_arfcn}
        ...  ${RU_SW_upgrade_new_SW_shared_RM_sn_list}  ${alias}
        Set Test Variable  ${${RM_arfcn}_new_SW_shared_RM_sn_list}  ${RM_arfcn_new_SW_shared_RM_sn_list}

        ${RM_arfcn_new_SW_shared_RM_count}=  Get Length  ${RM_arfcn_new_SW_shared_RM_sn_list}
        Run Keyword If  ${RM_arfcn_new_SW_shared_RM_count} > 0
        ...  Append To List  ${new_SW_shared_RM_arfcn_list}  ${RM_arfcn}

        ${RM_arfcn_new_SW_dedicated_RM_sn_list}=  Get RM arfcn info impacted by RU SW Upgrade  ${RM_arfcn}
        ...  ${RU_SW_upgrade_new_SW_dedicated_RM_sn_list}  ${alias}
        Set Test Variable  ${${RM_arfcn}_new_SW_dedicated_RM_sn_list}  ${RM_arfcn_new_SW_dedicated_RM_sn_list}

        ${RM_arfcn_new_SW_dedicated_RM_count}=  Get Length  ${RM_arfcn_new_SW_dedicated_RM_sn_list}
        Run Keyword If  ${RM_arfcn_new_SW_dedicated_RM_count} > 0
        ...  Append To List  ${new_SW_dedicated_RM_arfcn_list}  ${RM_arfcn}

    END

    Set Test Variable  ${new_SW_shared_RM_arfcn_list}
    Set Test Variable  ${new_SW_dedicated_RM_arfcn_list}

    FOR  ${RM_arfcn}  IN  @{new_SW_shared_RM_arfcn_list}

        ${new_SW_shared_RM_count}=  Get Length  ${${RM_arfcn}_new_SW_shared_RM_sn_list}
        Set Test Variable  ${${RM_arfcn}_new_SW_shared_RM_count}  ${new_SW_shared_RM_count}
        Log  Together per band new SW minimum ARFCN ${RM_arfcn} shared RM count: ${new_SW_shared_RM_count}  console=True

    END

    FOR  ${RM_arfcn}  IN  @{new_SW_dedicated_RM_arfcn_list}

        ${new_SW_dedicated_RM_count}=  Get Length  ${${RM_arfcn}_new_SW_dedicated_RM_sn_list}
        Set Test Variable  ${${RM_arfcn}_new_SW_dedicated_RM_count}  ${new_SW_dedicated_RM_count}
        Log  BTS ${alias} together per band new SW minimum ARFCN ${RM_arfcn} dedicated RM count: ${new_SW_dedicated_RM_count}  console=True

    END

    ${new_SW_RM_arfcn_list}=  Combine Lists  ${new_SW_shared_RM_arfcn_list}  ${new_SW_dedicated_RM_arfcn_list}
    ${new_SW_RM_arfcn_list}=  Remove Duplicates  ${new_SW_RM_arfcn_list}
    Set Test Variable  ${new_SW_RM_arfcn_list}
    ${new_SW_RM_arfcn_count}=  Get Length  ${new_SW_RM_arfcn_list}
    Set Test Variable  ${new_SW_RM_arfcn_count}

Get RM pn info impacted by RU SW Upgrade
    [Arguments]  ${RM_pn}  ${RU_SW_upgrade_new_SW_RM_sn_list}  ${alias}

    ${RM_pn_new_SW_RM_sn_list}=  Create List

    FOR  ${RM_sn}  IN  @{RU_SW_upgrade_new_SW_RM_sn_list}

        ${RM_pn_info}=  Get From Dictionary  ${${alias}_RM_sn_pn_dict}  ${RM_sn}
        Continue For Loop If  '${RM_pn_info}' != '${RM_pn}'
        Append To List  ${RM_pn_new_SW_RM_sn_list}  ${RM_sn}

    END

    [Return]  ${RM_pn_new_SW_RM_sn_list}

Get RM arfcn info impacted by RU SW Upgrade
    [Arguments]  ${RM_arfcn}  ${RU_SW_upgrade_new_SW_RM_sn_list}  ${alias}

    ${RM_arfcn_new_SW_RM_sn_list}=  Create List

    FOR  ${RM_sn}  IN  @{RU_SW_upgrade_new_SW_RM_sn_list}

        ${RM_id}=  Get From Dictionary  ${${alias}_RM_sn_id_dict}  ${RM_sn}
        ${RM_arfcn_info}=  Get From Dictionary  ${${alias}_RM_id_arfcn_dict}  ${RM_id}
        Continue For Loop If  '${RM_arfcn_info}' != '${RM_arfcn}'
        Append To List  ${RM_arfcn_new_SW_RM_sn_list}  ${RM_sn}

    END

    [Return]  ${RM_arfcn_new_SW_RM_sn_list}

Get RMOD minimum arfcn info
    [Arguments]  ${alias}

    ${RM_id_arfcn_dict}=  Create Dictionary

    ${CELL_id_arfcn_dict}=  Get Cell id arfcn info  ${alias}
    ${RM_id_list}=  Get Ids For All  class_name=RMOD  connection=${alias}

    FOR  ${RM_id}  IN  @{RM_id_list}

        ${RM_CELL_id_list}=  Get From Dictionary  ${${alias}_RMOD_id_CELL_id_dict}  ${RM_id}
        ${RM_CELL_arfcn_list}=  Get arfcn info for cells mapped on RMOD  ${RM_CELL_id_list}  ${CELL_id_arfcn_dict}
        ${CELL_arfcn}=  Get From List  ${RM_CELL_arfcn_list}  0

        Set To Dictionary  ${RM_id_arfcn_dict}  ${RM_id}  ${CELL_arfcn}

    END

    [Return]  ${RM_id_arfcn_dict}

Get Cell id arfcn info
    [Arguments]  ${alias}

    ${CELL_id_arfcn_dict}=  Create Dictionary

    ${BTS_info}=  Get Bts Info  connection=${alias}

    FOR  ${item}  IN  @{BTS_info['cells']['nr']}

        ${technology_check}=  Run Keyword And Return Status  Variable Should Exist  ${item['technology']}
        Run Keyword If  not ${technology_check}  Run Keywords
        ...  Set To Dictionary  ${CELL_id_arfcn_dict}  ${item['id']['internal']}  none
        ...  AND  Continue For Loop

        ${arfcn_info}=  Set Variable If  '${item['technology']}' == 'FDD'  nrarfcnDl  '${item['technology']}' == 'TDD'  nrarfcn  none
        Run Keyword If  '${arfcn_info}' == 'none'
        ...  Set To Dictionary  ${CELL_id_arfcn_dict}  ${item['id']['internal']}  none
        ...  ELSE
        ...  Set To Dictionary  ${CELL_id_arfcn_dict}  ${item['id']['internal']}  ${item['${arfcn_info}']}

    END

    FOR  ${item}  IN  @{BTS_info['cells']['lte']}

        ${technology_check}=  Run Keyword And Return Status  Variable Should Exist  ${item['technology']}
        Run Keyword If  not ${technology_check}  Run Keywords
        ...  Set To Dictionary  ${CELL_id_arfcn_dict}  ${item['id']['internal']}  none
        ...  AND  Continue For Loop

        ${arfcn_info}=  Set Variable If  '${item['technology']}' == 'FDD'  earfcnDownlink  '${item['technology']}' == 'TDD'  earfcn  none
        Run Keyword If  '${arfcn_info}' == 'none'
        ...  Set To Dictionary  ${CELL_id_arfcn_dict}  ${item['id']['internal']}  none
        ...  ELSE
        ...  Set To Dictionary  ${CELL_id_arfcn_dict}  ${item['id']['internal']}  ${item['${arfcn_info}']}

    END

    FOR  ${item}  IN  @{BTS_info['cells']['wcdma']}

        ${uarfcn_check}=  Run Keyword And Return Status  Variable Should Exist  ${item['uarfcn']}
        Run Keyword If  ${uarfcn_check}
        ...  Set To Dictionary  ${CELL_id_arfcn_dict}  ${item['id']['internal']}  ${item['uarfcn']}
        ...  ELSE
        ...  Set To Dictionary  ${CELL_id_arfcn_dict}  ${item['id']['internal']}  none

    END

    FOR  ${item}  IN  @{BTS_info['cells']['gsm']}

        Set To Dictionary  ${CELL_id_arfcn_dict}  ${item['id']['internal']}  none

    END

    [Return]  ${CELL_id_arfcn_dict}

Get arfcn info for cells mapped on RMOD
    [Arguments]  ${CELL_id_list}  ${CELL_id_arfcn_dict}

    ${CELL_arfcn_list}=  Create List

    FOR  ${CELL_id}  IN  @{CELL_id_list}

        ${CELL_arfcn}=  Get From Dictionary  ${CELL_id_arfcn_dict}  ${CELL_id}
        Run Keyword If  '${CELL_arfcn}' != 'none'
        ...  Append To List  ${CELL_arfcn_list}  ${CELL_arfcn}

    END

    ${CELL_arfcn_list}=  Remove Duplicates  ${CELL_arfcn_list}
    Sort List  ${CELL_arfcn_list}

    [Return]  ${CELL_arfcn_list}

Get shared RM impact on peer BTS
    [Arguments]  ${alias}  ${peer_alias}  ${when}

    ${all_BTS_PL_shared_RM_info}=  Get PL shared RM info on all BTS

    ${peer_BTS_PL_shared_RM_info}=  Get From Dictionary  ${all_BTS_PL_shared_RM_info}  ${peer_alias}

    ${peer_BTS_non_PL_OBSAI_shared_RM_id_list}=  Get From Dictionary  ${peer_BTS_PL_shared_RM_info}  BTS_non_PL_OBSAI_shared_RM_id_list
    ${peer_BTS_non_PL_CPRI_shared_RM_id_list}=  Get From Dictionary  ${peer_BTS_PL_shared_RM_info}  BTS_non_PL_CPRI_shared_RM_id_list
    ${peer_BTS_non_PL_ECPRI_shared_RM_id_list}=  Get From Dictionary  ${peer_BTS_PL_shared_RM_info}  BTS_non_PL_ECPRI_shared_RM_id_list
    ${peer_BTS_non_PL_OBSAI_shared_RM_sn_list}=  Get From Dictionary  ${peer_BTS_PL_shared_RM_info}  BTS_non_PL_OBSAI_shared_RM_sn_list
    ${peer_BTS_non_PL_CPRI_shared_RM_sn_list}=  Get From Dictionary  ${peer_BTS_PL_shared_RM_info}  BTS_non_PL_CPRI_shared_RM_sn_list
    ${peer_BTS_non_PL_ECPRI_shared_RM_sn_list}=  Get From Dictionary  ${peer_BTS_PL_shared_RM_info}  BTS_non_PL_ECPRI_shared_RM_sn_list

    ${peer_BTS_non_PL_not_excepted_ECPRI_shared_RM_id_list}  ${peer_BTS_non_PL_excepted_ECPRI_shared_RM_id_list}=
    ...  Get excepted and not excepted RMOD lists  ${peer_BTS_non_PL_ECPRI_shared_RM_id_list}  ${RMOD_ECPRI_fid16_exceptions}  ${peer_alias}

    ${new_SW_shared_RM_sn_list}=  Get BTS new SW shared RM list  ${alias}  ${when}
    Set Test Variable  ${${alias}_new_SW_shared_RM_sn_list}  ${new_SW_shared_RM_sn_list}
    ${peer_BTS_new_SW_shared_RM_alarm_count}=  Get Length  ${new_SW_shared_RM_sn_list}

    ${new_SW_dedicated_RM_sn_list}=  Get BTS new SW dedicated RM list  ${alias}  ${when}
    Set Test Variable  ${${alias}_new_SW_dedicated_RM_sn_list}  ${new_SW_shared_RM_sn_list}

    ${peer_BTS_CB007447_CPRI_shared_RM_sn_list}  ${peer_BTS_CB007447_exempted_CPRI_shared_RM_sn_list}=
    ...  Get peer BTS CB007447 CPRI shared RM not impacted by new RM SW  ${new_SW_shared_RM_sn_list}  ${peer_BTS_non_PL_CPRI_shared_RM_sn_list}
    ...  ${peer_alias}

    Set Test Variable  ${${peer_alias}_OBSAI_shared_RM_sn_list}  ${peer_BTS_non_PL_OBSAI_shared_RM_sn_list}
    Set Test Variable  ${${peer_alias}_CB007447_CPRI_shared_RM_sn_list}  ${peer_BTS_CB007447_CPRI_shared_RM_sn_list}
    Set Test Variable  ${${peer_alias}_CPRI_shared_RM_sn_list}  ${peer_BTS_CB007447_exempted_CPRI_shared_RM_sn_list}
    Set Test Variable  ${${peer_alias}_ECPRI_shared_RM_id_list}  ${peer_BTS_non_PL_not_excepted_ECPRI_shared_RM_id_list}

    ${peer_BTS_OBSAI_shared_RM_alarm_count}=  Get Length  ${peer_BTS_non_PL_OBSAI_shared_RM_sn_list}
    ${peer_BTS_CPRI_shared_RM_alarm_count}=  Get Length  ${peer_BTS_CB007447_exempted_CPRI_shared_RM_sn_list}
    ${peer_BTS_ECPRI_shared_RM_alarm_count}=  Get Length  ${peer_BTS_non_PL_not_excepted_ECPRI_shared_RM_id_list}

    Log  BTS ${peer_alias} new SW RM impacted shared RM count: ${peer_BTS_new_SW_shared_RM_alarm_count}  console=True
    Log  BTS ${peer_alias} PL impacted CPRI shared RM count: ${peer_BTS_CPRI_shared_RM_alarm_count}  console=True
    Log  BTS ${peer_alias} PL impacted ECPRI shared RM count: ${peer_BTS_ECPRI_shared_RM_alarm_count}  console=True
    Log  BTS ${peer_alias} PL impacted OBSAI shared RM count: ${peer_BTS_OBSAI_shared_RM_alarm_count}  console=True

    ${FID4773_alarm_count}=  Set Variable  ${peer_BTS_new_SW_shared_RM_alarm_count}
    ${FID10_1815_alarm_count}=  Set Variable  ${peer_BTS_CPRI_shared_RM_alarm_count}
    ${FID16_alarm_count}=  Set Variable  ${peer_BTS_ECPRI_shared_RM_alarm_count}
    ${FID10_alarm_count}=  Set Variable  ${peer_BTS_OBSAI_shared_RM_alarm_count}

    Set Test Variable  ${${peer_alias}_FID4773_alarm_count}  ${FID4773_alarm_count}
    Set Test Variable  ${${peer_alias}_FID10_1815_alarm_count}  ${FID10_1815_alarm_count}
    Set Test Variable  ${${peer_alias}_FID16_alarm_count}  ${FID16_alarm_count}
    Set Test Variable  ${${peer_alias}_FID10_alarm_count}  ${FID10_alarm_count}

    ${EXPECTED_ALARMS}=  Create List
    ${EXPECTED_ALARMS_4773_full}=  Prepare expected alarms list  ${${peer_alias.upper()}_EXPECTED_ALARMS_4773}  ${FID4773_alarm_count}
    ${EXPECTED_ALARMS_10_1815_full}=  Prepare expected alarms list  ${${peer_alias.upper()}_EXPECTED_ALARMS_10_1815}  ${FID10_1815_alarm_count}
    ${EXPECTED_ALARMS_16_full}=  Prepare expected alarms list  ${${peer_alias.upper()}_EXPECTED_ALARMS_16}  ${FID16_alarm_count}
    ${EXPECTED_ALARMS_10_full}=  Prepare expected alarms list  ${${peer_alias.upper()}_EXPECTED_ALARMS_10}  ${FID10_alarm_count}
    ${EXPECTED_ALARMS}=  Combine Lists  ${EXPECTED_ALARMS_4773_full}  ${EXPECTED_ALARMS_10_1815_full}  ${EXPECTED_ALARMS_16_full}
    ...  ${EXPECTED_ALARMS_10_full}
    Set Test Variable  ${${peer_alias.upper()}_EXPECTED_ALARMS}  ${EXPECTED_ALARMS}

Get BTS new SW shared RM list during RU SW Update
    [Arguments]  ${alias}

    ${BTS_new_SW_shared_RM_sn_list}=  Create List

    FOR  ${RM_sn}  IN  @{${alias}_primary_controller_shared_RM_sn_list}

        Run Keyword If  '${RuSwUpgrade_feature}' == 'CB010780'
        ...  Run Keyword If  '${RM_sn}' in ${${alias}_initial_RM_sn_newer_SW_buildVersion_list} and '${RM_sn}' not in ${No_upgrade_SW_RM_sn_list}
        ...  Append To List  ${BTS_new_SW_shared_RM_sn_list}  ${RM_sn}

        Run Keyword If  '${RuSwUpgrade_feature}' == 'CB013660'
        ...  Run Keyword If  '${RM_sn}' in ${${alias}_initial_RM_sn_newer_SW_buildVersion_list} and '${RM_sn}' not in ${No_upgrade_SW_RM_sn_list}
        ...  Append To List  ${BTS_new_SW_shared_RM_sn_list}  ${RM_sn}

    END

    [Return]  ${BTS_new_SW_shared_RM_sn_list}

Get BTS new SW dedicated RM list during RU SW Update
    [Arguments]  ${alias}

    ${BTS_new_SW_dedicated_RM_sn_list}=  Create List

    FOR  ${RM_sn}  IN  @{${alias}_dedicated_RM_sn_list}

        Run Keyword If  '${RuSwUpgrade_feature}' == 'CB010780'
        ...  Run Keyword If  '${RM_sn}' in ${${alias}_initial_RM_sn_newer_SW_buildVersion_list} and '${RM_sn}' not in ${No_upgrade_SW_RM_sn_list}
        ...  Append To List  ${BTS_new_SW_dedicated_RM_sn_list}  ${RM_sn}

        Run Keyword If  '${RuSwUpgrade_feature}' == 'CB013660'
        ...  Run Keyword If  '${RM_sn}' in ${${alias}_initial_RM_sn_newer_SW_buildVersion_list} and '${RM_sn}' not in ${No_upgrade_SW_RM_sn_list}
        ...  Append To List  ${BTS_new_SW_dedicated_RM_sn_list}  ${RM_sn}

    END

    [Return]  ${BTS_new_SW_dedicated_RM_sn_list}

Get BTS new SW shared RM list
    [Arguments]  ${alias}  ${when}

    ${BTS_new_SW_shared_RM_sn_list}=  Create List

    FOR  ${RM_sn}  IN  @{${alias}_primary_controller_shared_RM_sn_list}
        Run Keyword If  '${RM_sn}' in ${${alias}_${when}_RM_sn_newer_SW_buildVersion_list}
        ...  Append To List  ${BTS_new_SW_shared_RM_sn_list}  ${RM_sn}
    END

    [Return]  ${BTS_new_SW_shared_RM_sn_list}

Get BTS new SW dedicated RM list
    [Arguments]  ${alias}  ${when}

    ${BTS_new_SW_dedicated_RM_sn_list}=  Create List

    FOR  ${RM_sn}  IN  @{${alias}_dedicated_RM_sn_list}
        Run Keyword If  '${RM_sn}' in ${${alias}_${when}_RM_sn_newer_SW_buildVersion_list}
        ...  Append To List  ${BTS_new_SW_dedicated_RM_sn_list}  ${RM_sn}
    END

    [Return]  ${BTS_new_SW_dedicated_RM_sn_list}

Get peer BTS CB007447 CPRI shared RM not impacted by new RM SW
    [Arguments]  ${new_SW_shared_RM_sn_list}  ${peer_BTS_non_PL_CPRI_shared_RM_sn_list}  ${peer_alias}

    ${peer_BTS_CB007447_CPRI_shared_RM_sn_list}=  Create List
    ${peer_BTS_CB007447_exempted_CPRI_shared_RM_sn_list}=  Create List

    ${BTS_RM_sn_list}=  Get From Dictionary  ${BTS_alias_RM_sn_dict}  ${peer_alias}

    FOR  ${RM_sn}  IN  @{BTS_RM_sn_list}

        Continue For Loop If  '${RM_sn}' not in ${shared_RM_sn_list}
        Continue For Loop If  '${RM_sn}' in ${new_SW_shared_RM_sn_list}
        Continue For Loop If  '${RM_sn}' not in ${peer_BTS_non_PL_CPRI_shared_RM_sn_list}

        Run Keyword If  '${RM_sn}' in ${CB007447_exempted_shared_RM_sn_list}
        ...  Append To List  ${peer_BTS_CB007447_exempted_CPRI_shared_RM_sn_list}  ${RM_sn}
        ...  ELSE
        ...  Append To List  ${peer_BTS_CB007447_CPRI_shared_RM_sn_list}  ${RM_sn}

    END

    [Return]  ${peer_BTS_CB007447_CPRI_shared_RM_sn_list}  ${peer_BTS_CB007447_exempted_CPRI_shared_RM_sn_list}

Perform RU SW Update from BTS
    [Arguments]  ${alias}  ${peer_alias}

    Log  ***** Perform BTS ${alias} RU SW Update using ${target_SW_build} SW build *****  console=True

    Run Keyword If  ${BTS_SCF_VALIDATION}  Check BTS SCF Validation On Demand  alias=${alias}

    ${new_alias}=  Set Variable  ${alias}_RuSwOnly

    Start new ADMIN instance  alias=${alias}  new_alias=${new_alias}  connection_type=${connection_type_${alias}}

    Get RESET timestamp info  start_RU_Update

    ${RuSwOnly_info}=  Run Keyword In Background  Update Software  sw_package=${target_SW_build}  should_activate=True  timeout=${SW Update Timeout}
    ...  connection=${new_alias}  independent_sw_update_type=RuSwOnly

    Log  ***** Check both BTS states and alarms during BTS ${alias} RU SW Update *****  console=True
    Check both BTS states and alarms during RU SW Update  ${alias}  ${peer_alias}

    Collect Keyword Result  ${RuSwOnly_info}  timeout=${SW Update Timeout}
    Log  BTS ${alias} RU SW Update finished!  console=True

    Get RESET timestamp info  end_RU_Update

    Log  ***** Check both BTS states and alarms after BTS ${alias} RU SW Update *****  console=True
    Check both BTS states and alarms after SW Update
    Run Keyword If  ${${peer_alias}_dedicated_RM_count} > 0  Run Keywords
    ...  Log  Check BTS ${peer_alias} dedicated RM status after BTS ${alias} RU SW Update  console=True
    ...  AND  Check peer BTS dedicated RM reset behavior from IMS  ${date_timestamp_start_RU_Update_UTC}  ${date_timestamp_end_RU_Update_UTC}
    ...  ${peer_alias}
    ...  AND  Log  All BTS ${peer_alias} dedicated RMs status:\n - ${RM_state_enabled}  console=True

    Run Keyword If  ${BTS_SCF_VALIDATION}  Check BTS SCF Validation On Demand  alias=${alias}

    Log  ***** Get and check RM SW versions after BTS ${alias} RU SW Update *****  console=True
    Get RM SW versions on both BTS  after_RU_SW_Update
    Check RM SW versions from BTS Target SW version  ${alias}  after_RU_SW_Update
    Check shared RM running SW after RU SW Update  ${alias}
    Check dedicated RM running SW after RU SW Update  ${alias}

Check both BTS states and alarms during RU SW Update
    [Arguments]  ${alias}  ${peer_alias}

    ${cond1}=  Set Variable  '${RuSwUpgrade_feature}' == 'CB010780' and '${CB010780_sequentialRuSwUpgrade}' == 'false'
    ${cond2}=  Set Variable  '${RuSwUpgrade_feature}' == 'CB010780' and '${CB010780_sequentialRuSwUpgrade}' == 'true'
    ${cond3}=  Set Variable  '${RuSwUpgrade_feature}' == 'CB013660' and '${CB013660_ruPhaseSwActivationResetPolicy}' == 'Simultaneous'
    ${cond4}=  Set Variable  '${RuSwUpgrade_feature}' == 'CB013660' and '${CB013660_ruPhaseSwActivationResetPolicy}' == 'Sequential'
    ${cond5}=  Set Variable  '${RuSwUpgrade_feature}' == 'CB013660' and '${CB013660_ruPhaseSwActivationResetPolicy}' == 'User configuration'
    ${cond6}=  Set Variable  '${RuSwUpgrade_feature}' == 'CB013660' and '${CB013660_ruPhaseSwActivationResetPolicy}' == 'Together per HW type'
    ${cond7}=  Set Variable  '${RuSwUpgrade_feature}' == 'CB013660' and '${CB013660_ruPhaseSwActivationResetPolicy}' == 'Together per band'

    Run Keyword If  ${cond1} or ${cond3}
    ...  Check both BTS states and alarms during RU SW Update with simultaneous RU reset  ${alias}  ${peer_alias}
    ...  ELSE IF    ${cond2} or ${cond4}
    ...  Check both BTS states and alarms during RU SW Update with sequential RU reset  ${alias}  ${peer_alias}
    ...  ELSE IF    ${cond5}
    ...  Check both BTS states and alarms during RU SW Update with user configuration RU reset  ${alias}  ${peer_alias}
    ...  ELSE IF    ${cond6}
    ...  Check both BTS states and alarms during RU SW Update with together per HW type RU reset  ${alias}  ${peer_alias}
    ...  ELSE IF    ${cond7}
    ...  Check both BTS states and alarms during RU SW Update with together per band RU reset  ${alias}  ${peer_alias}

Check both BTS states and alarms during RU SW Update with simultaneous RU reset
    [Arguments]  ${alias}  ${peer_alias}

    Log  Check both BTS states and alarms during RU SW Update with simultaneous RU reset  console=True

    Run Keyword If  ${new_SW_shared_RM_count} > 0 or ${new_SW_dedicated_RM_count} > 0  Run Keywords
    ...  Log  Check BTS ${alias} reset RM during RU SW Update  console=True
    ...  AND  Assert Any  class_name=RMOD  parameters=operationalState=${Disabled_}  timeout=1800  connection=${alias}
    ...  AND  Log  BTS ${alias} reset RM status:\n - operationalState=Disabled  console=True
    Run Keyword If  ${new_SW_shared_RM_count} > 0
    ...  Check peer BTS alarms during RU SW Update  ${${peer_alias}_FID4773_alarm_count}  ${${peer_alias}_FID10_alarm_count}
    ...  ${${peer_alias.upper()}_EXPECTED_ALARMS}  ${peer_alias}

Check both BTS states and alarms during RU SW Update with sequential RU reset
    [Arguments]  ${alias}  ${peer_alias}

    Log  Check both BTS states and alarms during RU SW Update with sequential RU reset  console=True

    FOR  ${RM_count}  IN RANGE  1  ${new_SW_RM_count}+1

        ${RM_sn}=  Get RM info during sequential RU reset  ${alias}
        ${EXPECTED_ALARMS_EMPTY}=  Create List

        Run Keyword If  '${RM_sn}' in @{${alias}_dedicated_RM_sn_list}  Run Keywords
        ...  Log  Check BTS ${peer_alias} during RU SW Update due to reset RM with SN ${RM_sn}  console=True
        ...  AND  Check peer BTS alarms during RU SW Update  0  0  ${EXPECTED_ALARMS_EMPTY}  ${peer_alias}
        ...  AND  Log  Check BTS ${alias} RMs are enabled during RU SW Update after reset RM with SN ${RM_sn}  console=True
        ...  AND  Assert Every  class_name=RMOD  parameters=operationalState=${Enabled_}  timeout=360  connection=${alias}
        ...  AND  Log  All BTS ${alias} RMs status:\n - operationalState=Enabled  console=True
        ...  AND  Continue For Loop

        ${RM_L3Protocol}=  Get From Dictionary  ${${peer_alias}_RM_sn_interface_dict}  ${RM_sn}
        ${FID4773_alarm_count}=  Set Variable If  '${RM_L3Protocol}' in ['CPRI_RP1', 'ECPRI_MPLANE']  1
        ...  '${RM_L3Protocol}' == 'RP301_RP1'  0
        ${FID10_alarm_count}=  Set Variable If  '${RM_L3Protocol}' in ['CPRI_RP1', 'ECPRI_MPLANE']  0
        ...  '${RM_L3Protocol}' == 'RP301_RP1'  1

        ${EXPECTED_ALARMS}=  Set Variable If  '${RM_L3Protocol}' in ['CPRI_RP1', 'ECPRI_MPLANE']
        ...  ${${peer_alias.upper()}_EXPECTED_ALARMS_4773}
        ...  '${RM_L3Protocol}' == 'RP301_RP1'  ${${peer_alias.upper()}_EXPECTED_ALARMS_10}

        Log  Check BTS ${peer_alias} during RU SW Update due to reset RM with SN ${RM_sn}  console=True
        Check peer BTS alarms during RU SW Update  ${FID4773_alarm_count}  ${FID10_alarm_count}  ${EXPECTED_ALARMS}  ${peer_alias}
        Log  Check BTS ${alias} RMs are enabled during RU SW Update after reset RM with SN ${RM_sn}  console=True
        Assert Every  class_name=RMOD  parameters=operationalState=${Enabled_}  timeout=360  connection=${alias}
        Log  All BTS ${alias} RMs status:\n - operationalState=Enabled  console=True

    END

Check both BTS states and alarms during RU SW Update with user configuration RU reset
    [Arguments]  ${alias}  ${peer_alias}

    Log  Check both BTS states and alarms during RU SW Update with user configuration RU reset  console=True

    Run Keyword If  ${1st_reset_order_new_SW_shared_RM_count} > 0 or ${1st_reset_order_new_SW_dedicated_RM_count} > 0  Run Keywords
    ...  Log  Check BTS ${alias} 1st reset order RM group during RU SW Update  console=True
    ...  AND  Assert Any  class_name=RMOD  parameters=operationalState=${Disabled_}  timeout=1800  connection=${alias}
    ...  AND  Log  BTS ${alias} 1st reset order RM group status:\n - operationalState=Disabled  console=True
    Run Keyword If  ${1st_reset_order_new_SW_shared_RM_count} > 0  Run Keywords
    ...  Log  Check BTS ${peer_alias} during RU SW Update due to 1st reset order RM group  console=True
    ...  AND  Check peer BTS alarms during RU SW Update  ${${peer_alias}_1st_reset_order_FID4773_alarm_count}
    ...  ${${peer_alias}_1st_reset_order_FID10_alarm_count}  ${${peer_alias}_EXPECTED_ALARMS_1st_reset_order}  ${peer_alias}
    Run Keyword If  ${1st_reset_order_new_SW_shared_RM_count} > 0 or ${1st_reset_order_new_SW_dedicated_RM_count} > 0  Run Keywords
    ...  Log  Check BTS ${alias} RMs are enabled during RU SW Update after 1st reset order RM group  console=True
    ...  AND  Assert Every  class_name=RMOD  parameters=operationalState=${Enabled_}  timeout=360  connection=${alias}
    ...  AND  Log  All BTS ${alias} RMs status:\n - operationalState=Enabled  console=True

    Run Keyword If  ${2nd_reset_order_new_SW_shared_RM_count} > 0 or ${2nd_reset_order_new_SW_dedicated_RM_count} > 0  Run Keywords
    ...  Log  Check BTS ${alias} 2nd reset order RM group during RU SW Update  console=True
    ...  AND  Assert Any  class_name=RMOD  parameters=operationalState=${Disabled_}  timeout=1800  connection=${alias}
    ...  AND  Log  BTS ${alias} 2nd reset order RM group status:\n - operationalState=Disabled  console=True
    Run Keyword If  ${2nd_reset_order_new_SW_shared_RM_count} > 0  Run Keywords
    ...  Log  Check BTS ${peer_alias} during RU SW Update due to 2nd reset order RM group  console=True
    ...  AND  Check peer BTS alarms during RU SW Update  ${${peer_alias}_2nd_reset_order_FID4773_alarm_count}
    ...  ${${peer_alias}_2nd_reset_order_FID10_alarm_count}  ${${peer_alias}_EXPECTED_ALARMS_2nd_reset_order}  ${peer_alias}
    Run Keyword If  ${2nd_reset_order_new_SW_shared_RM_count} > 0 or ${2nd_reset_order_new_SW_dedicated_RM_count} > 0  Run Keywords
    ...  Log  Check BTS ${alias} RMs are enabled during RU SW Update after 2nd reset order RM group  console=True
    ...  AND  Assert Every  class_name=RMOD  parameters=operationalState=${Enabled_}  timeout=360  connection=${alias}
    ...  AND  Log  All BTS ${alias} RMs status:\n - operationalState=Enabled  console=True

    Run Keyword If  ${undefined_reset_order_new_SW_shared_RM_count} > 0 or ${undefined_reset_order_new_SW_dedicated_RM_count} > 0  Run Keywords
    ...  Log  Check BTS ${alias} undefined reset order RM group during RU SW Update  console=True
    ...  AND  Assert Any  class_name=RMOD  parameters=operationalState=${Disabled_}  timeout=1800  connection=${alias}
    ...  AND  Log  BTS ${alias} undefined reset order RM group status:\n - operationalState=Disabled  console=True
    Run Keyword If  ${undefined_reset_order_new_SW_shared_RM_count} > 0  Run Keywords
    ...  Log  Check BTS ${peer_alias} during RU SW Update due to undefined reset order RM group  console=True
    ...  AND  Check peer BTS alarms during RU SW Update  ${${peer_alias}_undefined_reset_order_FID4773_alarm_count}
    ...  ${${peer_alias}_undefined_reset_order_FID10_alarm_count}  ${${peer_alias}_EXPECTED_ALARMS_undefined_reset_order}  ${peer_alias}
    Run Keyword If  ${undefined_reset_order_new_SW_shared_RM_count} > 0 or ${undefined_reset_order_new_SW_dedicated_RM_count} > 0  Run Keywords
    ...  Log  Check BTS ${alias} RMs are enabled during RU SW Update after undefined reset order RM group  console=True
    ...  AND  Assert Every  class_name=RMOD  parameters=operationalState=${Enabled_}  timeout=360  connection=${alias}
    ...  AND  Log  All BTS ${alias} RMs status:\n - operationalState=Enabled  console=True

Check both BTS states and alarms during RU SW Update with together per HW type RU reset
    [Arguments]  ${alias}  ${peer_alias}

    Log  Check both BTS states and alarms during RU SW Update with together per HW type RU reset  console=True

    FOR  ${RM_count}  IN RANGE  1  ${new_SW_RM_pn_count}+1

        Get RM info during together per HW type RU reset  ${alias}  ${peer_alias}

        Log  Check BTS ${peer_alias} during RU SW Update due to reset RM with PN ${RM_pn_reset}  console=True
        Check peer BTS alarms during RU SW Update  ${${peer_alias}_FID4773_alarm_count}  ${${peer_alias}_FID10_alarm_count}
        ...  ${${peer_alias}_EXPECTED_ALARMS}  ${peer_alias}
        Log  Check BTS ${alias} RMs are enabled during RU SW Update after reset RM with PN ${RM_pn_reset}  console=True
        Assert Every  class_name=RMOD  parameters=operationalState=${Enabled_}  timeout=360  connection=${alias}
        Log  All BTS ${alias} RMs status:\n - operationalState=Enabled  console=True

    END

Check both BTS states and alarms during RU SW Update with together per band RU reset
    [Arguments]  ${alias}  ${peer_alias}
    Log  Check both BTS states and alarms during RU SW Update with together per band RU reset  console=True

    FOR  ${RM_count}  IN RANGE  1  ${new_SW_RM_arfcn_count}+1

        Get RM info during together per band RU reset  ${alias}  ${peer_alias}

        Log  Check BTS ${peer_alias} during RU SW Update due to reset RM with minimum ARFCN ${RM_arfcn_reset}  console=True
        Check peer BTS alarms during RU SW Update  ${${peer_alias}_FID4773_alarm_count}  ${${peer_alias}_FID10_alarm_count}
        ...  ${${peer_alias}_EXPECTED_ALARMS}  ${peer_alias}
        Log  Check BTS ${alias} RMs are enabled during RU SW Update after reset RM with minimum ARFCN ${RM_arfcn_reset}  console=True
        Assert Every  class_name=RMOD  parameters=operationalState=${Enabled_}  timeout=360  connection=${alias}
        Log  All BTS ${alias} RMs status:\n - operationalState=Enabled  console=True

    END

Get RM info during sequential RU reset
    [Arguments]  ${alias}

    ${RM_info}=  Assert Any  class_name=RMOD  parameters=operationalState=${Disabled_}  timeout=30 min  connection=${alias}

    ${disabled_RM_sn_list}=  Create List

    FOR  ${item}  IN  @{RM_info}

        ${RM_operationalState}=  Get From Dictionary  ${item}  operationalState
        Continue For Loop If  '${RM_operationalState}' != 'disabled'

        ${RM_sn}=  Get From Dictionary  ${item}  serialNumber
        Append To List  ${disabled_RM_sn_list}  ${RM_sn}

    END

    ${disabled_RM_count}=  Get Length  ${disabled_RM_sn_list}
    Run Keyword If  ${disabled_RM_count} > 1  Run Keywords
    ...  Log  Simultaneous RU reset during requested sequential RU reset!  level=ERROR
    ...  AND  Fail  Simultaneous RU reset during requested sequential RU reset!

    ${RM_sn}=  Set Variable  ${disabled_RM_sn_list[0]}

    [Return]  ${RM_sn}

Get RM info during together per HW type RU reset
    [Arguments]  ${alias}  ${peer_alias}

    ${RM_info}=  Assert Any  class_name=RMOD  parameters=operationalState=${Disabled_}  timeout=30 min  connection=${alias}

    FOR  ${item}  IN  @{RM_info}

        ${RM_operationalState}=  Get From Dictionary  ${item}  operationalState
        Exit For Loop If  '${RM_operationalState}' == 'disabled'

    END

    ${RM_pn}=  Get From Dictionary  ${item}  productName
    Set Test Variable  ${RM_pn_reset}  ${RM_pn}

    ${FID4773_alarm_count}=  Set Variable  0
    ${FID10_alarm_count}=  Set Variable  0

    FOR  ${RM_sn}  IN  @{${RM_pn}_new_SW_shared_RM_sn_list}

        ${RM_L3Protocol}=  Get From Dictionary  ${${peer_alias}_RM_sn_interface_dict}  ${RM_sn}
        ${FID4773_alarm_count}=  Run Keyword If  '${RM_L3Protocol}' in ['CPRI_RP1', 'ECPRI_MPLANE']
        ...  Evaluate  ${FID4773_alarm_count} + 1
        ...  ELSE
        ...  Evaluate  ${FID4773_alarm_count} + 0
        ${FID10_alarm_count}=  Run Keyword If  '${RM_L3Protocol}' == 'RP301_RP1'
        ...  Evaluate  ${FID10_alarm_count} + 1
        ...  ELSE
        ...  Evaluate  ${FID10_alarm_count} + 0

    END

    Set Test Variable  ${${peer_alias}_FID4773_alarm_count}  ${FID4773_alarm_count}
    Set Test Variable  ${${peer_alias}_FID10_alarm_count}  ${FID10_alarm_count}

    ${EXPECTED_ALARMS}=  Create List
    ${EXPECTED_ALARMS_4773_full}=  Prepare expected alarms list  ${${peer_alias.upper()}_EXPECTED_ALARMS_4773}  ${FID4773_alarm_count}
    ${EXPECTED_ALARMS_10_full}=  Prepare expected alarms list  ${${peer_alias.upper()}_EXPECTED_ALARMS_10}  ${FID10_alarm_count}
    ${EXPECTED_ALARMS}=  Combine Lists  ${EXPECTED_ALARMS_4773_full}  ${EXPECTED_ALARMS_10_full}
    Set Test Variable  ${${peer_alias.upper()}_EXPECTED_ALARMS}  ${EXPECTED_ALARMS}

Get RM info during together per band RU reset
    [Arguments]  ${alias}  ${peer_alias}

    ${RM_info}=  Assert Any  class_name=RMOD  parameters=operationalState=${Disabled_}  timeout=30 min  connection=${alias}

    FOR  ${item}  IN  @{RM_info}

        ${RM_operationalState}=  Get From Dictionary  ${item}  operationalState
        Exit For Loop If  '${RM_operationalState}' == 'disabled'

    END

    ${RM_id}=  Get From Dictionary  ${item}  id
    ${RM_arfcn}=  Get From Dictionary  ${${alias}_RM_id_arfcn_dict}  ${RM_id}
    Set Test Variable  ${RM_arfcn_reset}  ${RM_arfcn}

    ${FID4773_alarm_count}=  Set Variable  0
    ${FID10_alarm_count}=  Set Variable  0

    FOR  ${RM_sn}  IN  @{${RM_arfcn}_new_SW_shared_RM_sn_list}

        ${RM_L3Protocol}=  Get From Dictionary  ${${peer_alias}_RM_sn_interface_dict}  ${RM_sn}
        ${FID4773_alarm_count}=  Run Keyword If  '${RM_L3Protocol}' in ['CPRI_RP1', 'ECPRI_MPLANE']
        ...  Evaluate  ${FID4773_alarm_count} + 1
        ...  ELSE
        ...  Evaluate  ${FID4773_alarm_count} + 0
        ${FID10_alarm_count}=  Run Keyword If  '${RM_L3Protocol}' == 'RP301_RP1'
        ...  Evaluate  ${FID10_alarm_count} + 1
        ...  ELSE
        ...  Evaluate  ${FID10_alarm_count} + 0

    END

    Set Test Variable  ${${peer_alias}_FID4773_alarm_count}  ${FID4773_alarm_count}
    Set Test Variable  ${${peer_alias}_FID10_alarm_count}  ${FID10_alarm_count}

    ${EXPECTED_ALARMS}=  Create List
    ${EXPECTED_ALARMS_4773_full}=  Prepare expected alarms list  ${${peer_alias.upper()}_EXPECTED_ALARMS_4773}  ${FID4773_alarm_count}
    ${EXPECTED_ALARMS_10_full}=  Prepare expected alarms list  ${${peer_alias.upper()}_EXPECTED_ALARMS_10}  ${FID10_alarm_count}
    ${EXPECTED_ALARMS}=  Combine Lists  ${EXPECTED_ALARMS_4773_full}  ${EXPECTED_ALARMS_10_full}
    Set Test Variable  ${${peer_alias.upper()}_EXPECTED_ALARMS}  ${EXPECTED_ALARMS}

Check peer BTS alarms during RU SW Update
    [Arguments]  ${FID4773_alarm_count}  ${FID10_alarm_count}  ${EXPECTED_ALARMS}  ${alias}

    ${IGNORED_ALARMS_full}=  Combine Lists  ${${alias.upper()}_IGNORED_ALARMS_DURING_RESET}  ${${alias.upper()}_IGNORED_ALARMS}
    Log  Check BTS ${alias} alarms:  console=True
    Run Keyword If  ${FID4773_alarm_count} > 0
    ...  Log  BTS ${alias} "Radio unit reset triggered by peer BTS (4773)" alarm, expected number: ${FID4773_alarm_count}  console=True
    Run Keyword If  ${FID10_alarm_count} > 0
    ...  Log  BTS ${alias} "No connection to Unit (10)" alarm, expected number: ${FID10_alarm_count}  console=True

    Get and Check Alarms SOAM  alias=${alias}  poll_interval=5 sec  expected_alarms=${EXPECTED_ALARMS}  ignored_alarms=${IGNORED_ALARMS_full}
    ...  critical_alarms=${${alias.upper()}_CRITICAL_ALARMS}

    Run Keyword If  ${FID4773_alarm_count} > 0
    ...  Log  BTS ${alias} "Radio unit reset triggered by peer BTS (4773)" alarm, found number: ${FID4773_alarm_count}, as expected!  console=True
    Run Keyword If  ${FID10_alarm_count} > 0
    ...  Log  BTS ${alias} "No connection to Unit (10)" alarm, found number: ${FID10_alarm_count}, as expected!  console=True
    Log  BTS ${alias} site - expected, ignored and critical alarms checked  console=True

Check peer BTS states and alarms during BTS SW Update
    [Arguments]  ${alias}

    ${IGNORED_ALARMS_full}=  Combine Lists  ${${alias.upper()}_IGNORED_ALARMS_DURING_RESET}  ${${alias.upper()}_IGNORED_ALARMS}

    Log  Check BTS ${alias} alarms:  console=True
    Run Keyword If  ${${alias}_FID10_alarm_count} > 0
    ...  Log  BTS ${alias} "No connection to Unit (10)" alarm, expected number: ${${alias}_FID10_alarm_count}  console=True
    Run Keyword If  ${${alias}_FID10_1815_alarm_count} > 0
    ...  Log Long String  BTS ${alias} "No connection to Unit (10)" or "Not able to synchronize baseband bus (1815)" alarm,
    ...  expected number: ${${alias}_FID10_1815_alarm_count}  console=True
    Run Keyword If  ${${alias}_FID16_alarm_count} > 0
    ...  Log  BTS ${alias} "Unit synchronization failed (16)" alarm, expected number: ${${alias}_FID16_alarm_count}  console=True
    Run Keyword If  ${${alias}_FID4773_alarm_count} > 0
    ...  Log  BTS ${alias} "Radio unit reset triggered by peer BTS (4773)" alarm, expected number: ${${alias}_FID4773_alarm_count}  console=True

    Get and Check Alarms SOAM  alias=${alias}  time=15 min  poll_interval=5 sec  expected_alarms=${${alias.upper()}_EXPECTED_ALARMS}
    ...  ignored_alarms=${IGNORED_ALARMS_full}  critical_alarms=${${alias.upper()}_CRITICAL_ALARMS}

    Run Keyword If  ${${alias}_FID10_alarm_count} > 0
    ...  Log  BTS ${alias} "No connection to Unit (10)" alarm, found number: ${${alias}_FID10_alarm_count}, as expected!  console=True
    Run Keyword If  ${${alias}_FID10_1815_alarm_count} > 0
    ...  Log Long String  BTS ${alias} "No connection to Unit (10)" or "Not able to synchronize baseband bus (1815)" alarm,
    ...  found number: ${${alias}_FID10_1815_alarm_count}, as expected!  console=True
    Run Keyword If  ${${alias}_FID16_alarm_count} > 0
    ...  Log  BTS ${alias} "Unit synchronization failed (16)" alarm, found number: ${${alias}_FID16_alarm_count}, as expected!  console=True
    Run Keyword If  ${${alias}_FID4773_alarm_count} > 0
    ...  Log  BTS ${alias} "Radio unit reset triggered by peer BTS (4773)" alarm, found number: ${${alias}_FID4773_alarm_count}, as expected!
    ...  console=True
    Log  BTS ${alias} site - expected, ignored and critical alarms checked  console=True

Check shared RM running SW after RU SW Update
    [Arguments]  ${alias}

    FOR  ${RM_sn}  IN  @{${alias}_primary_controller_shared_RM_sn_list}

        ${current_buildVersion}=  Get From Dictionary  ${${alias}_after_RU_SW_Update_RM_serialNumber_buildVersion_dict}  ${RM_sn}
        ${target_buildVersion}=  Get From Dictionary  ${${alias}_target_RM_serialNumber_buildVersion_dict}  ${RM_sn}
        ${initial_buildVersion}=  Get From Dictionary  ${${alias}_initial_RM_serialNumber_buildVersion_dict}  ${RM_sn}

        Run Keyword If  '${RM_sn}' in ${${alias}_initial_RM_sn_newer_SW_buildVersion_list} and '${RM_sn}' not in ${No_upgrade_SW_RM_sn_list}
        ...  Should Be Equal  ${current_buildVersion}  ${target_buildVersion}
        ...  ELSE IF  '${RM_sn}' in ${${alias}_initial_RM_sn_newer_SW_buildVersion_list} and '${RM_sn}' in ${No_upgrade_SW_RM_sn_list}
        ...  Should Be Equal  ${current_buildVersion}  ${initial_buildVersion}

    END

    Log  All BTS ${alias} requested shared RMs SW have been updated accordingly!  console=True

Check dedicated RM running SW after RU SW Update
    [Arguments]  ${alias}

    FOR  ${RM_sn}  IN  @{${alias}_dedicated_RM_sn_list}

        ${current_buildVersion}=  Get From Dictionary  ${${alias}_after_RU_SW_Update_RM_serialNumber_buildVersion_dict}  ${RM_sn}
        ${target_buildVersion}=  Get From Dictionary  ${${alias}_target_RM_serialNumber_buildVersion_dict}  ${RM_sn}
        ${initial_buildVersion}=  Get From Dictionary  ${${alias}_initial_RM_serialNumber_buildVersion_dict}  ${RM_sn}

        Run Keyword If  '${RM_sn}' in ${${alias}_initial_RM_sn_newer_SW_buildVersion_list} and '${RM_sn}' not in ${No_upgrade_SW_RM_sn_list}
        ...  Should Be Equal  ${current_buildVersion}  ${target_buildVersion}
        ...  ELSE IF  '${RM_sn}' in ${${alias}_initial_RM_sn_newer_SW_buildVersion_list} and '${RM_sn}' in ${No_upgrade_SW_RM_sn_list}
        ...  Should Be Equal  ${current_buildVersion}  ${initial_buildVersion}

    END

    Log  All BTS ${alias} requested dedicated RMs SW have been updated accordingly!  console=True

Get RESET timestamp info
    [Arguments]  ${when}

    Get Current Date UTC info  ${when}
    Log  UTC ${when}_point_timestamp: ${date_timestamp_${when}_UTC}  console=True

Perform DU+RU SW Update from BTS
    [Arguments]  ${alias}  ${peer_alias}

    Run Keyword If  '${alias}' == '${SECONDARY_CONTROLLER_BTS_alias}' and '${SECONDARY_CONTROLLER_BTS_SW_UPDATE}' != 'True'  Run Keywords
    ...  Log  DU+RU SW Update on secondary controller BTS ${alias} is skipped due to test argument \${SECONDARY_CONTROLLER_BTS_SW_UPDATE} set False
    ...  console=True
    ...  AND  Return From Keyword

    Log  ***** Perform BTS ${alias} DU+RU SW Update using ${target_SW_build} SW build *****  console=True

    Run Keyword If  ${BTS_SCF_VALIDATION}  Check BTS SCF Validation On Demand  alias=${alias}

    Get RESET timestamp info  start

    ${reset_number}=  Admin Get Reset info based on BTS SW Precheck  SW_package=${target_SW_build}  alias=${alias}
    coam.Update Software  sw_package=${target_SW_build}  should_activate=True  timeout=${SW Update Timeout}  connection=${alias}
    ...  independent_sw_update_type=All
    Log  BTS ${alias} DU+RU SW Update: download finished, waiting for activation reset!  console=True

    ${remote_host_ip}=  Set Variable If  '${alias}' == 'Master'  None  ${${alias.upper()}}[${alias.upper()}_PC_IP_ADDRESS]
    Run Keyword If  ${reset_number} != 0
    ...  Wait For Target To Be Not Reachable TAF  hostname=${${alias.upper()}}[${alias.upper()}_TECH_IP_ADDRESS]  timeout=${BTS_MAX_WAIT_TIME}
    ...  remote_host=${remote_host_ip}

    Get Current Time  reset_start_time
    Log  BTS ${alias} reset_start_time is: ${time_reset_start_time}  console=True

    Log  ***** Check peer BTS ${peer_alias} alarms during BTS ${alias} DU+RU SW Update *****  console=True
    Check peer BTS states and alarms during BTS SW Update  ${peer_alias}

    Wait For Target To Be Reachable TAF  hostname=${${alias.upper()}}[${alias.upper()}_TECH_IP_ADDRESS]  timeout=${BTS_MAX_WAIT_TIME}
    ...  remote_host=${remote_host_ip}

    Log  ***** Check both BTS states and alarms after BTS ${alias} DU+RU SW Update *****  console=True
    Check both BTS states and alarms after SW Update

    Run Keyword If  ${BTS_SCF_VALIDATION}  Check BTS SCF Validation On Demand  alias=${alias}
    Get RESET timestamp info  end

    Get RM SW versions on both BTS  after_DU_RU_SW_Update
    FOR  ${item}  IN  @{alias_list}
        Check RM SW versions from BTS Target SW version  ${item}  after_DU_RU_SW_Update
    END

    Log  ***** Check peer BTS ${peer_alias} CPRI shared RM reset behavior during BTS ${alias} DU+RU SW Update from IMS *****  console=True
    Check peer BTS CPRI shared RM reset behavior during BTS DU+RU SW Update from IMS  peer_alias=${peer_alias}  alias=${alias}

Check both BTS states and alarms after SW Update
    FOR  ${alias}  IN  @{alias_list}

        Log  Check BTS ${alias} status:  console=True

        Admin Check BTS Procedural and Blocking states  ${OnAir_}  ${Unblocked_}  ${BTS_MAX_WAIT_TIME}  ${alias}
        Log  BTS ${alias} site - proceduralState: OnAir, blockingState: Unblocked, as expected!  console=True

        Admin Check BTS RAT cells expected states  ${CELL_state_enabled_check}  ${alias}  ${BTS_MAX_WAIT_TIME}
        Log  All BTS ${alias} cell(s) status:\n - ${CELL_state_enabled}  console=True
        Check cells availability status online  ${alias}  ${BTS_MAX_WAIT_TIME}

        Log  Check BTS ${alias} alarms:  console=True
        Get and Check Alarms SOAM  alias=${alias}  expected_alarms=@{EMPTY}  ignored_alarms=${${alias.upper()}_IGNORED_ALARMS}
        ...  critical_alarms=${${alias.upper()}_CRITICAL_ALARMS}
        Log  BTS ${alias} site - expected, ignored and critical alarms checked  console=True

    END

Check peer BTS CPRI shared RM reset behavior during BTS DU+RU SW Update from IMS
    [Arguments]  ${peer_alias}  ${alias}

    ${ims_file_path}=  Admin Collect IMS file with timestamp  folder_path=${Test Results Dir}/IMS/${peer_alias}  alias=${peer_alias}

    FOR  ${RM_sn}  IN  @{${peer_alias}_CB007447_CPRI_shared_RM_sn_list}

        Log  Checking BTS ${peer_alias} CPRI shared RM with SN ${RM_sn} states during BTS ${alias} DU+RU SW Update  console=True
        ${RM_id}=  Get From Dictionary  ${${peer_alias}_RM_sn_id_dict}  ${RM_sn}
        Check IMS object states not changed  ${ims_file_path}  ${RM_id}  ${date_timestamp_start_UTC}  ${date_timestamp_end_UTC}  ${peer_alias}

    END

    Log  BTS ${peer_alias} CPRI shared RMs (not impacted by DU+RU SW Update or CB007447 exempted) state check passed!  console=True

Check peer BTS dedicated RM reset behavior from IMS
    [Arguments]  ${begin}  ${end}  ${alias}

    ${ims_file_path}=  Admin Collect IMS file with timestamp  folder_path=${Test Results Dir}/IMS/${alias}  alias=${alias}

    FOR  ${RM_sn}  IN  @{${alias}_dedicated_RM_sn_list}

        ${RM_id}=  Get From Dictionary  ${${alias}_RM_sn_id_dict}  ${RM_sn}
        Check IMS object states not changed  ${ims_file_path}  ${RM_id}  ${begin}  ${end}  ${alias}

    END

Check IMS object states not changed
    [Arguments]  ${ims_file_path}  ${obj_id}  ${begin}  ${end}  ${alias}

    Log  No state changes expected on BTS ${alias} object ${obj_id}  console=True

    ${obj_updates}=  ims2alarms.Get Object Updates In Interval  file_path=${ims_file_path}  obj_dist_name=${obj_id}  begin=${begin}  end=${end}
    ...  obj_exact_match=True

    FOR  ${item}  IN  @{obj_updates}

        ${operationalState_found}=  Run Keyword And Return Status  Dictionary Should Contain Key  ${item}  operationalState
        Run Keyword If  ${operationalState_found}
        ...  Run Keyword If   '${item["operationalState"]}'!='enabled'
        ...  Fail  State operationalState changed for BTS ${alias} object ${obj_id}! Please check IMS file: ${ims_file_path}

    END

Check BTS and RM SW versions from BTS partitions after SW Update
    FOR  ${alias}  IN  @{alias_list}

        Log  Check BTS ${alias} SW versions  console=True

        Run Keyword If  '${alias}' == '${SECONDARY_CONTROLLER_BTS_alias}' and '${SECONDARY_CONTROLLER_BTS_SW_UPDATE}' != 'True'  Run Keywords
        ...  Should Be Equal  ${${alias} initial active SW}  ${${alias} final active SW}
        ...  AND  Should Be Equal  ${${alias} initial passive SW}  ${${alias} final passive SW}
        ...  ELSE  Run Keywords
        ...  Should Match Regexp  ${target_SW_build}  (?i).*${${alias} final active SW}.*
        ...  AND  Should Be Equal  ${${alias} initial active SW}  ${${alias} final passive SW}

        Log  BTS ${alias} final active SW: ${${alias} final active SW}, as expected!  console=True
        Log  BTS ${alias} initial active SW: ${${alias} final passive SW}, as expected!  console=True
        Log  Check BTS ${alias} RM SW versions  console=True

        Check RM SW versions after SW Update  ${alias}

    END

Check RM SW versions after SW Update
    [Arguments]  ${alias}

    FOR  ${RM_sn}  IN  @{${alias}_initial_RM_sn_newer_SW_buildVersion_list}

        ${condition}=  Create Long String  '${alias}' == '${SECONDARY_CONTROLLER_BTS_alias}' and '${SECONDARY_CONTROLLER_BTS_SW_UPDATE}' != 'True'
        ...  and '${RM_sn}' in ${${alias}_dedicated_RM_sn_list}

        ${final_buildVersion}=  Get From Dictionary  ${${alias}_final_RM_serialNumber_buildVersion_dict}  ${RM_sn}
        ${target_buildVersion}=  Get From Dictionary  ${${alias}_target_RM_serialNumber_buildVersion_dict}  ${RM_sn}
        ${initial_buildVersion}=  Get From Dictionary  ${${alias}_initial_RM_serialNumber_buildVersion_dict}  ${RM_sn}

        Run Keyword If  ${condition}
        ...  Should Be Equal  ${final_buildVersion}  ${initial_buildVersion}
        ...  ELSE
        ...  Should Be Equal  ${final_buildVersion}  ${target_buildVersion}
        Log  BTS ${alias} final active RM SW: ${final_buildVersion}, as expected!  console=True

    END

Perform recover SW Update on both BTS
    [Arguments]  ${sw_update_type}

    FOR  ${alias}  IN  @{alias_list}

        Run Keyword If  '${alias}' == '${SECONDARY_CONTROLLER_BTS_alias}' and '${SECONDARY_CONTROLLER_BTS_SW_UPDATE}' != 'True'  Run Keywords
        ...  Log  SW Update on secondary controller BTS ${alias} is skipped due to test argument \${SECONDARY_CONTROLLER_BTS_SW_UPDATE} set False
        ...  console=True
        ...  AND  Continue For Loop

        Log  ***** Perform BTS ${alias} SW Update using ${${sw_update_type}_SW_build} SW build *****  console=True

        Run Keyword If  ${BTS_SCF_VALIDATION}  Check BTS SCF Validation On Demand  alias=${alias}

        Sleep  60s  reason=Avoid BTS Busy state
        ${reset_number}=  Admin Get Reset info based on BTS SW Precheck  SW_package=${${sw_update_type}_SW_build}  alias=${alias}
        coam.Update Software  sw_package=${${sw_update_type}_SW_build}  should_activate=True  timeout=${SW Update Timeout}
        ...  connection=${alias}  independent_sw_update_type=All
        Log  BTS ${alias} SW Update to ${sw_update_type} SW build: download finished, waiting for activation reset!  console=True

        ${remote_host_ip}=  Set Variable If
        ...  '${alias}' == 'Master'  None  ${${alias.upper()}}[${alias.upper()}_PC_IP_ADDRESS]
        Run Keyword If  ${reset_number} != 0
        ...  Wait For Target To Be Not Reachable TAF  hostname=${${alias.upper()}}[${alias.upper()}_TECH_IP_ADDRESS]  timeout=${BTS_MAX_WAIT_TIME}
        ...  remote_host=${remote_host_ip}

        Get Current Time  reset_start_time
        Log  BTS ${alias} reset_start_time is: ${time_reset_start_time}  console=True

        Wait For Target To Be Reachable TAF  hostname=${${alias.upper()}}[${alias.upper()}_TECH_IP_ADDRESS]  timeout=${BTS_MAX_WAIT_TIME}
        ...  remote_host=${remote_host_ip}
        Sleep  120s  reason=Waiting for BTS Admin establish
        Admin Collect IMS file with timestamp  folder_path=${Test Results Dir}/IMS/${alias}  alias=${alias}
        Wait Until Keyword Succeeds  3x  10s  Admin reset and Infomodel reconnect sessions  reset_req=True  alias=${alias}  infomodel_reset=False

        Log  ***** Check both BTS states and alarms after BTS ${alias} SW Update *****  console=True
        Check both BTS states and alarms after SW Update

        Run Keyword If  ${BTS_SCF_VALIDATION}  Check BTS SCF Validation On Demand  alias=${alias}

    END

Check CB010780 feature settings
    [Arguments]  ${alias}

    ${BTS_sequentialRuSwUpgrade}=  Get BTS sequentialRuSwUpgrade parameter  ${alias}
    Set Test Variable  ${initial_BTS_sequentialRuSwUpgrade}  ${BTS_sequentialRuSwUpgrade}
    Set BTS sequentialRuSwUpgrade parameter  ${alias}

    ${RM_sn_disableSWUpdate_dict}=  Get RMOD disableSWUpdate parameter  ${alias}
    Set Test Variable  ${initial_RM_sn_disableSWUpdate_dict}  ${RM_sn_disableSWUpdate_dict}
    ${BTS_RM_sn_list}=  Get From Dictionary  ${BTS_alias_RM_sn_dict}  ${alias}
    Set RMOD disableSWUpdate parameter  BTS_RM_sn_list=${BTS_RM_sn_list}  disableSWUpdate=false  alias=${alias}

Get BTS sequentialRuSwUpgrade parameter
    [Arguments]  ${alias}

    Log  Get BTS ${alias} sequentialRuSwUpgrade parameter value  console=True
    ${BTS_sequentialRuSwUpgrade}=  Get sequentialRuSwUpgrade parameter value  ${alias}
    Log  - BTS ${alias} sequentialRuSwUpgrade parameter value: ${BTS_sequentialRuSwUpgrade}  console=True

    [Return]  ${BTS_sequentialRuSwUpgrade}

Set BTS sequentialRuSwUpgrade parameter
    [Arguments]  ${alias}

    Log  Set BTS ${alias} sequentialRuSwUpgrade parameter value on ${CB010780_sequentialRuSwUpgrade}  console=True
    Set sequentialRuSwUpgrade parameter value  ${CB010780_sequentialRuSwUpgrade}  ${alias}

Get RMOD disableSWUpdate parameter
    [Arguments]  ${alias}

    ${RM_sn_disableSWUpdate_dict}=  Create Dictionary
    ${BTS_RM_sn_list}=  Get From Dictionary  ${BTS_alias_RM_sn_dict}  ${alias}

    FOR  ${RM_sn}  IN  @{BTS_RM_sn_list}

        Log  Get BTS ${alias} RM with SN ${RM_sn} disableSWUpdate parameter value  console=True
        ${RM_id}=  Get From Dictionary  ${${alias}_RM_sn_id_dict}  ${RM_sn}
        ${disableSWUpdate_value}=  Get disableSWUpdate parameter value  ${RM_id}  ${alias}
        Log  - BTS ${alias} RM with SN ${RM_sn} - disableSWUpdate parameter value: ${disableSWUpdate_value}  console=True
        Set To Dictionary  ${RM_sn_disableSWUpdate_dict}  ${RM_sn}  ${disableSWUpdate_value}

    END

    [Return]  ${RM_sn_disableSWUpdate_dict}

Set RMOD disableSWUpdate parameter
    [Arguments]  ${BTS_RM_sn_list}  ${disableSWUpdate}  ${alias}

    FOR  ${RM_sn}  IN  @{BTS_RM_sn_list}

        Log  Set BTS ${alias} RM with SN ${RM_sn} disableSWUpdate parameter value on ${disableSWUpdate}  console=True
        ${RM_id}=  Get From Dictionary  ${${alias}_RM_sn_id_dict}  ${RM_sn}
        Set disableSWUpdate parameter value  ${RM_id}  ${disableSWUpdate}  ${alias}

    END

Check CB013660 feature settings
    [Arguments]  ${alias}

    ${BTS_ruPhaseSwActivationResetPolicy}=  Get BTS ruPhaseSwActivationResetPolicy parameter  ${alias}
    Set Test Variable  ${initial_BTS_ruPhaseSwActivationResetPolicy}  ${BTS_ruPhaseSwActivationResetPolicy}
    Set BTS ruPhaseSwActivationResetPolicy parameter  ${alias}

    ${RM_sn_upgradePhase_dict}=  Get RMOD upgradePhase parameter  ${alias}
    Set Test Variable  ${initial_RM_sn_upgradePhase_dict}  ${RM_sn_upgradePhase_dict}
    ${BTS_RM_sn_list}=  Get From Dictionary  ${BTS_alias_RM_sn_dict}  ${alias}
    Set RMOD upgradePhase parameter  BTS_RM_sn_list=${BTS_RM_sn_list}  upgradePhase=none  alias=${alias}

    Run Keyword If  '${CB013660_ruPhaseSwActivationResetPolicy}' == 'User configuration'
    ...  Get and set RMOD ruPhaseResetOrder parameter  ${alias}

Get BTS ruPhaseSwActivationResetPolicy parameter
    [Arguments]  ${alias}

    Log  Get BTS ${alias} ruPhaseSwActivationResetPolicy parameter value  console=True
    ${BTS_ruPhaseSwActivationResetPolicy}=  Get ruPhaseSwActivationResetPolicy parameter value  ${alias}
    Log  - BTS ${alias} ruPhaseSwActivationResetPolicy parameter value: ${BTS_ruPhaseSwActivationResetPolicy}  console=True

    [Return]  ${BTS_ruPhaseSwActivationResetPolicy}

Set BTS ruPhaseSwActivationResetPolicy parameter
    [Arguments]  ${alias}

    Log  Set BTS ${alias} ruPhaseSwActivationResetPolicy parameter value on ${CB013660_ruPhaseSwActivationResetPolicy}  console=True
    Set ruPhaseSwActivationResetPolicy parameter value  ${CB013660_ruPhaseSwActivationResetPolicy}  ${alias}

Get RMOD upgradePhase parameter
    [Arguments]  ${alias}

    ${RM_sn_upgradePhase_dict}=  Create Dictionary
    ${BTS_RM_sn_list}=  Get From Dictionary  ${BTS_alias_RM_sn_dict}  ${alias}

    FOR  ${RM_sn}  IN  @{BTS_RM_sn_list}

        Log  Get BTS ${alias} RM with SN ${RM_sn} upgradePhase parameter value  console=True
        ${RM_id}=  Get From Dictionary  ${${alias}_RM_sn_id_dict}  ${RM_sn}
        ${upgradePhase_value}=  Get upgradePhase parameter value  ${RM_id}  ${alias}
        Log  - BTS ${alias} RM with SN ${RM_sn} - upgradePhase parameter value: ${upgradePhase_value}  console=True
        Set To Dictionary  ${RM_sn_upgradePhase_dict}  ${RM_sn}  ${upgradePhase_value}

    END

    [Return]  ${RM_sn_upgradePhase_dict}

Set RMOD upgradePhase parameter
    [Arguments]  ${BTS_RM_sn_list}  ${upgradePhase}  ${alias}

    FOR  ${RM_sn}  IN  @{BTS_RM_sn_list}

        Log  Set BTS ${alias} RM with SN ${RM_sn} upgradePhase parameter value on ${upgradePhase}  console=True
        ${RM_id}=  Get From Dictionary  ${${alias}_RM_sn_id_dict}  ${RM_sn}
        Set upgradePhase parameter value  ${RM_id}  ${upgradePhase}  ${alias}

    END

Get and set RMOD ruPhaseResetOrder parameter
    [Arguments]  ${alias}

    ${RM_sn_ruPhaseResetOrder_dict}=  Get RMOD ruPhaseResetOrder parameter  ${alias}
    Set Test Variable  ${initial_RM_sn_ruPhaseResetOrder_dict}  ${RM_sn_ruPhaseResetOrder_dict}

    ${reset_order_RM_sn_list}=  Combine Lists  ${1st_reset_order_RM_sn_list}  ${2nd_reset_order_RM_sn_list}
    ${isEmpty}=  Run Keyword And Return Status  Should Be Empty  ${reset_order_RM_sn_list}
    Return From Keyword If  ${isEmpty}

    Set RMOD ruPhaseResetOrder parameter  BTS_RM_sn_list=${1st_reset_order_RM_sn_list}  ruPhaseResetOrder=1  alias=${alias}
    Set RMOD ruPhaseResetOrder parameter  BTS_RM_sn_list=${2nd_reset_order_RM_sn_list}  ruPhaseResetOrder=10  alias=${alias}

Get RMOD ruPhaseResetOrder parameter
    [Arguments]  ${alias}

    ${RM_sn_ruPhaseResetOrder_dict}=  Create Dictionary
    ${BTS_RM_sn_list}=  Get From Dictionary  ${BTS_alias_RM_sn_dict}  ${alias}

    FOR  ${RM_sn}  IN  @{BTS_RM_sn_list}

        Log  Get BTS ${alias} RM with SN ${RM_sn} ruPhaseResetOrder parameter value  console=True

        ${RM_id}=  Get From Dictionary  ${${alias}_RM_sn_id_dict}  ${RM_sn}
        ${ruPhaseResetOrder_value}=  Get ruPhaseResetOrder parameter value  ${RM_id}  ${alias}
        Log  - BTS ${alias} RM with SN ${RM_sn} - ruPhaseResetOrder parameter value: ${ruPhaseResetOrder_value}  console=True
        Set To Dictionary  ${RM_sn_ruPhaseResetOrder_dict}  ${RM_sn}  ${ruPhaseResetOrder_value}

    END

    [Return]  ${RM_sn_ruPhaseResetOrder_dict}

Set RMOD ruPhaseResetOrder parameter
    [Arguments]  ${BTS_RM_sn_list}  ${ruPhaseResetOrder}  ${alias}

    FOR  ${RM_sn}  IN  @{BTS_RM_sn_list}

        Log  Set BTS ${alias} RM with SN ${RM_sn} ruPhaseResetOrder parameter value on ${ruPhaseResetOrder}  console=True

        ${RM_id}=  Get From Dictionary  ${${alias}_RM_sn_id_dict}  ${RM_sn}
        Set ruPhaseResetOrder parameter value  ${RM_id}  ${ruPhaseResetOrder}  ${alias}

    END

Get RMOD actIndSwUpgradeForSharedRU parameter
    [Arguments]  ${RM_sn}

    Log  Get shared RM with SN ${RM_sn} actIndSwUpgradeForSharedRU parameter value  console=True

    ${RM_BTS_alias_list}=  Get From Dictionary  ${RM_sn_BTS_alias_dict}  ${RM_sn}
    ${actIndSwUpgradeForSharedRU_list}=  Create List

    FOR  ${alias}  IN  @{RM_BTS_alias_list}

        ${RM_id}=  Get From Dictionary  ${${alias}_RM_sn_id_dict}  ${RM_sn}
        ${actIndSwUpgradeForSharedRU}=  Get actIndSwUpgradeForSharedRU parameter value  ${RM_id}  ${alias}
        Append To List  ${actIndSwUpgradeForSharedRU_list}  ${actIndSwUpgradeForSharedRU}
        Log  - BTS ${alias} shared RM with SN ${RM_sn} - actIndSwUpgradeForSharedRU parameter value: ${actIndSwUpgradeForSharedRU}  console=True

    END

    ${actIndSwUpgradeForSharedRU_list}=  Remove Duplicates  ${actIndSwUpgradeForSharedRU_list}

    [Return]  ${actIndSwUpgradeForSharedRU_list}

Recover BTS features initial settings
    Log  =====================================  console=True
    Log  Recover BTS features initial settings  console=True
    Log  =====================================  console=True

    Run Keyword If  '${RuSwUpgrade_feature}' == 'CB010780'
    ...  Recover CB010780 feature initial settings  ${BTS_RU_SW_UPDATE_alias}
    ...  ELSE IF  '${RuSwUpgrade_feature}' == 'CB013660'
    ...  Recover CB013660 feature initial settings  ${BTS_RU_SW_UPDATE_alias}

Recover CB010780 feature initial settings
    [Arguments]  ${alias}

    Log  Recover BTS ${alias} sequentialRuSwUpgrade parameter initial value  console=True
    Set sequentialRuSwUpgrade parameter value  ${initial_BTS_sequentialRuSwUpgrade}  ${alias}

Recover CB013660 feature initial settings
    [Arguments]  ${alias}

    Run Keyword If  '${CB013660_ruPhaseSwActivationResetPolicy}' == 'User configuration'
    ...  Recover RMOD ruPhaseResetOrder parameter initial settings  ${alias}

    Log  Recover BTS ${alias} ruPhaseSwActivationResetPolicy parameter initial value  console=True
    Set ruPhaseSwActivationResetPolicy parameter value  ${initial_BTS_ruPhaseSwActivationResetPolicy}  ${alias}

    FOR  ${RM_sn}  IN  @{No_upgrade_SW_RM_sn_list}

        Log  Recover BTS ${alias} upgradePhase parameter initial value on RM with SN ${RM_sn}  console=True

        ${RM_id}=  Get From Dictionary  ${${alias}_RM_sn_id_dict}  ${RM_sn}
        ${upgradePhase_initial}=  Get From Dictionary  ${initial_RM_sn_upgradePhase_dict}  ${RM_sn}
        Set upgradePhase parameter value  ${RM_id}  ${upgradePhase_initial}  ${alias}

    END

Recover RMOD ruPhaseResetOrder parameter initial settings
    [Arguments]  ${alias}

    ${reset_order_RM_sn_list}=  Combine Lists  ${1st_reset_order_RM_sn_list}  ${2nd_reset_order_RM_sn_list}

    FOR  ${RM_sn}  IN  @{reset_order_RM_sn_list}

        Log  Recover BTS ${alias} ruPhaseResetOrder parameter initial value on RM with SN ${RM_sn}  console=True

        ${RM_id}=  Get From Dictionary  ${${alias}_RM_sn_id_dict}  ${RM_sn}
        ${ruPhaseResetOrder_initial}=  Get From Dictionary  ${initial_RM_sn_ruPhaseResetOrder_dict}  ${RM_sn}
        Set ruPhaseResetOrder parameter value  ${RM_id}  ${ruPhaseResetOrder_initial}  ${alias}

    END

Particular Teardown
    Recover BTS features initial settings

TC Setup
    ${tech_preset_list}=  Create List  SBTS  SBTS
    Common Test Setup  preset_techs=${tech_preset_list}  common_sbts=${TRUE}  infomodelSetup=${FALSE}

TC Teardown
    Common Test Teardown