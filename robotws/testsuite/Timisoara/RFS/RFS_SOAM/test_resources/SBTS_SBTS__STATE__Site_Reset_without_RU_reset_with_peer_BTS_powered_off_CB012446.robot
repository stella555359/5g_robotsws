*** Settings ***
Documentation    TC__SBTS_SBTS__STATE__Site_Reset_without_RU_reset_with_peer_BTS_powered_off_CB012446
Variables    tc_variables/sbts_sbts__state__site_reset_without_ru_reset_with_peer_bts_powered_off_cb012446_alarms_definitions.py
Resource    ../../resources/rfs_frame_rfs_soam_taf.robot

*** Variables ***
${REPEAT_COUNTER}                  3     # Number of BTS Reset Site without RU reset operations with peer BTS powered OFF; actions run on both BTS,
                                         # default value 3
${cntrldResetMplaneBreakTimeSite}  300   # Maximum time when RU tries to re-establish released M-plane connection to BTS after a site reset
                                         # without RU reset. Should be in range: 180 - 420 (seconds), by default 300
${BTS_MAX_WAIT_TIME}               900   # Maximum time to wait for BTS OnAir after reset, by default 900
${GRACEFUL_CELL_SHUTDOWN}          True  # Graceful cell shutdown: True or False, by default True
${BTS1_SYNC_ROLE}                        # BTS1 sync role on TL. Useful for those TL sync configurations when BTS sync role info get by robot is
                                         # not reliable (e.g. dual core BTS configured on TL). In such case user should explicitly specify
                                         # BTS1 sync role: Master or Slave. Possible values (by default empty, Master or Slave):
                                         # - empty: BTS1 sync role is get by robot (reliable info only for single core BTS configured on TL)
                                         # - Master: BTS1 sync role will be treated as Master Sync role
                                         # - Slave: BTS1 sync role will be treated as Slave Sync role
${BTS2_SYNC_ROLE}                        # BTS2 sync role on TL. Useful for those TL sync configurations when BTS sync role info get by robot is
                                         # not reliable (e.g. dual core BTS configured on TL). In such case user should explicitly specify
                                         # BTS2 sync role: Master or Slave. Possible values (by default empty, Master or Slave):
                                         # - empty: BTS2 sync role is get by robot (reliable info only for single core BTS configured on TL)
                                         # - Master: BTS2 sync role will be treated as Master Sync role
                                         # - Slave: BTS2 sync role will be treated as Slave Sync role

*** Keywords ***
TC__SBTS_SBTS__STATE__Site_Reset_without_RU_reset_with_peer_BTS_powered_off_CB012446
    [Documentation]
    ...  [CASE LINK]: https://jiradc.ext.net.nokia.com/browse/TAT-28170
    ...
    ...  *****************
    ...  Basic information
    ...  *****************
    ...  SBTS-SBTS test case for BTS Reset Site without RU reset operations with peer BTS powered OFF; actions run on both BTS, - x times sequence.
    ...  x - value of REPEAT_COUNTER parameter (default: 3)
    ...  The main steps performed for the test are:
    ...  - check initial state and alarms for both BTS
    ...  - get and check CB012446 settings on both BTS
    ...  - get primary link settings for shared RMOD before peer BTS power OFF operation
    ...  - perform peer BTS power OFF operation checking states and alarms on BTS
    ...  - perform BTS Reset Site without RU reset operation checking states and alarms on BTS
    ...  - perform peer BTS power ON operation checking states and alarms on peer BTS
    ...  - check reset behavior on both BTS based on info from IMS file as follows:
    ...    - BTS: reset number is 1 (no FID4001 raised) or 2 (FID4001 raised)
    ...    - peer BTS: reset number is 1
    ...  - check states and alarms for both BTS after Reset Site without RU reset operation
    ...  Pass criteria: Reset Site without RU reset operation works as expected, states and alarms are as expected
    ...
    ...  ******************
    ...  History of changes
    ...  ******************
    ...  - 08.10.2024 - https://jiradc.ext.net.nokia.com/browse/TAT-28170 -
    ...  [CB012446][5G] Startup Improvement - New Testcase : Site Reset without RM restart with TRM
    ...  - 23.10.2024 - https://jiradc.ext.net.nokia.com/browse/TAT-28283 -
    ...  [5G] SBTS_SBTS__STATE__Site_Reset_without_RU_reset_with_peer_BTS_powered_off_CB012446 fails
    ...  - 21.11.2024 - https://jiradc.ext.net.nokia.com/browse/TAT-28421 - [5G] Get properly BTS Sync role
    ...  - 30.06.2025 - https://jiradc.ext.net.nokia.com/browse/TAT-29379 -
    ...  [5G] Enhancement to SBTS_SBTS__STATE__Site_Reset_without_RU_reset_with_peer_BTS_powered_off_CB012446 to check FID4001
    ...  - 10.10.2025 - https://jiradc.ext.net.nokia.com/browse/TAT-29932 - Site_Reset_without_RU_reset_CB012446 robots should be modified
    ...  for no dependency of CB010846
    ...  - 27.11.2025 - https://jiradc.ext.net.nokia.com/browse/TAT-30221 - Remove ${actForceUnitAutoReset}' in tests and KWs related to CB007447
    ...  - 27.01.2026 - https://jiradc.ext.net.nokia.com/browse/TAT-30423 - [5G] Please ignore FID4590 in
    ...  SBTS_SBTS__STATE__Site_Reset_without_RU_reset_with_peer_BTS_powered_off_CB012446
    ...

    Set Tags    CA-STATE    OWNER-georgiana.stefan@nokia.com    AUTHOR-dinu.olariu@nokia.com    PHASE-QT    SW-SBTS25R1

    Step 1: Check initial all BTS state
    Step 2: Check initial all BTS alarms
    Step 3: Check CB012446 and CB007447 features settings
    Step 4: Check PDU definition and reachability
    Step 5: Get all BTS info for configured items
    FOR  ${INDEX}  IN RANGE  1  ${REPEAT_COUNTER}+1
        Log  ==============================================================================  console=True
        Log  Start Cycle ${INDEX} of ${REPEAT_COUNTER}  console=True
        Log  ==============================================================================  console=True
        Step 6: Perform Reset Site without RU reset operation with peer BTS powered OFF
        Step 7: Check final all BTS state
        Step 8: Check final all BTS alarms
        Step 9: Check final number and state of Cells and RMs
    END

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

Step ${index}: Check CB012446 and CB007447 features settings
    [Documentation]
    ...  Check CB012446 and CB007447 features settings on BTS

    Log  Step ${index}: Check CB012446 and CB007447 features settings  console=True

    FOR  ${alias}  IN  @{alias_list}

        Log  Check CB012446 feature settings on BTS ${alias} and set them accordingly if needed  console=True

        ${BTS_CB012446_feature_dict}=  Get BTS CB012446 feature parameters  BTS_SCF_path_file=${${alias.lower()}_scf_initial}  alias=${alias}

        Set Test Variable  ${${alias}_BTS_CB012446_feature_dict}  ${BTS_CB012446_feature_dict}

        Set classical BTS CB012446 feature parameter  cntrldResetMplaneBreakTimeSite  ${cntrldResetMplaneBreakTimeSite}  ${alias}

        Log  Get CB007447 feature status on BTS ${alias}  console=True

        ${actCpriLinkRecovery}  ${actSyncLinkSwitchover}  ${cpriSyncBreakTime}  ${stickToSyncSourcePeriod}=  Get feature CB007447 info  ${alias}

        Run Keyword If  '${actCpriLinkRecovery}' == 'true' and '${actSyncLinkSwitchover}' == 'true'  Run Keywords
        ...  Log  BTS ${alias} CB007447 feature status: Enabled  console=True
        ...  AND  Set Test Variable  ${${alias}_CB007447_status}  ${TRUE}
        ...  ELSE  Run Keywords
        ...  Log  BTS ${alias} CB007447 feature status: Disabled  console=True
        ...  AND  Set Test Variable  ${${alias}_CB007447_status}  ${FALSE}

    END

Step ${index}: Check PDU definition and reachability
    [Documentation]
    ...  Keyword used to check if BTS SMs PDU are defined, can be reached and their status is on

    Log  Step ${index}: Check PDU definition and reachability  console=True

    FOR  ${alias}  IN  @{alias_list}

        ${BTS_SM_PDU_if_name_list}=  Check BTS SMs PDU info definition  ${alias}
        Set Test Variable  ${${alias}_SM_PDU_if_name_list}  ${BTS_SM_PDU_if_name_list}

        ${PDU_port_status}=  Check BTS SMs PDU port status  ${${alias}_SM_PDU_if_name_list}  on
        Run Keyword if  ${PDU_port_status}
        ...  Log  BTS ${alias} SMs PDU port status as expected  console=True  console=True
        ...  ELSE  Run Keywords
        ...  Log  PDU for BTS ${alias} SMs is either not reachable or not switched on!  level=ERROR
        ...  AND  Fail  PDU for BTS ${alias} SMs is either not reachable or not switched on!

    END

Step ${index}: Get all BTS info for configured items
    [Documentation]
    ...  Get all BTS info about following items:
    ...  - list of shared and dedicated RMOD serial number on BTS
    ...  - list of shared and dedicated RMOD serial number eligible for CB012446 on BTS

    Log  Step ${index}: Get all BTS info for configured items  console=True

    ${BTS_alias_label_dict}  ${BTS_label_alias_dict}=  Get BTS alias label info dict
    Set Test Variable  ${BTS_alias_label_dict}

    ${BTS_alias_RMOD_sn_dict}  ${RMOD_sn_BTS_alias_dict}  ${shared_RMOD_sn_list}  ${dedicated_RMOD_sn_list}=  Get all BTS RMOD sharing info
    Set Test Variable  ${BTS_alias_RMOD_sn_dict}

    ${all_BTS_controller_role_RMOD_sn_list}=  Get all BTS controller role for configured RMOD from SCF
    Set Test Variable  ${all_BTS_controller_role_RMOD_sn_list}

    ${BTS_alias_TRM_feature_dict}=  Get all BTS TRM feature settings
    Set Test Variable  ${BTS_alias_TRM_feature_dict}

    ${BTS_alias_RMOD_sn_RMOD_buildVersion_dict}  ${BTS_alias_RMOD_sn_RMOD_l3Protocol_dict}=  Get all BTS RMOD buildVersion and l3Protocol info

    ${BTS_alias_CB012446_RMOD_sn_dict}=  Get all BTS RMOD eligible for CB012446  ${BTS_alias_RMOD_sn_dict}
    ...  ${BTS_alias_RMOD_sn_RMOD_buildVersion_dict}  ${BTS_alias_RMOD_sn_RMOD_l3Protocol_dict}
    Set Test Variable  ${BTS_alias_CB012446_RMOD_sn_dict}

    ${BTS_alias_sync_info_dict}=  Get all BTS Synchronization Information
    Set Test Variable  ${BTS_alias_sync_info_dict}

    FOR  ${alias}  IN  @{alias_list}

        ${BTS_RMOD_sn_id_dict}  ${BTS_RMOD_id_sn_dict}  ${BTS_RMOD_sn_pn_dict}  ${BTS_RMOD_sn_interface_dict}=
        ...  Admin Get RMOD sn id pn interface info  ${alias}
        Set Test Variable  ${${alias}_RMOD_sn_id_dict}  ${BTS_RMOD_sn_id_dict}

    END

    Set Test Variable  ${RMOD_state_enabled_check}  operationalState=${Enabled_}, administrativeState=${Unlocked_}
    Set Test Variable  ${RMOD_state_enabled}  operationalState=Enabled, administrativeState=Unlocked
    Set Test Variable  ${CELL_state_enabled_check}  operationalState=${Enabled_}, blockingState=${Unblocked_}
    Set Test Variable  ${CELL_state_enabled}  operationalState=Enabled, blockingState=Unblocked

Step ${index}: Perform Reset Site without RU reset operation with peer BTS powered OFF

    Log  Step ${index}: Perform Reset Site without RU reset operation with peer BTS powered OFF  console=True

    FOR  ${alias}  IN  @{alias_list}

        Perform Reset Site without RU reset operation on BTS with peer BTS powered OFF  ${alias}

        Check all BTS reset behavior based on IMS info  ${alias}

        Check BTS RMOD reset behavior based on Uptime info  ${alias}

    END

Step ${index}: Check final number and state of Cells and RMs
    [Documentation]
    ...  Following checks are performed:
    ...  - number of configured cells and radio modules in SCF are properly mapped on BTS running view ADMIN
    ...  - check cells states
    ...  - check radio modules states

    Log  Step ${index}: Check final number and state of Cells and RMs  console=True
    RFS Test Case Final Checks

Get all BTS TRM feature settings

    ${BTS_alias_TRM_feature_dict}=  Create Dictionary

    FOR  ${alias}  IN  @{alias_list}

        ${BTS_TRM_feature_dict_initial}=  Get BTS TRM feature parameters  BTS_SCF_path_file=${${alias.lower()}_scf_initial}  alias=${alias}

        Set To Dictionary  ${BTS_alias_TRM_feature_dict}  ${alias}  ${BTS_TRM_feature_dict_initial}

    END

    [Return]  ${BTS_alias_TRM_feature_dict}

Get all BTS Synchronization Information

    Run Keyword If  '${BTS1_SYNC_ROLE}' not in ['', 'Master', 'Slave']  Run Keywords
    ...  Log Long String  Improper value for test argument \${BTS1_SYNC_ROLE}. Please select values for test argument \${BTS1_SYNC_ROLE} from: Master
    ...  or Slave (according to BTS Sync role), otherwise let default value  console=True
    ...  AND  Fail  Improper value for argument!

    Run Keyword If  '${BTS2_SYNC_ROLE}' not in ['', 'Master', 'Slave']  Run Keywords
    ...  Log Long String  Improper value for test argument \${BTS2_SYNC_ROLE}. Please select values for test argument \${BTS2_SYNC_ROLE} from: Master
    ...  or Slave (according to BTS Sync role), otherwise let default value  console=True
    ...  AND  Fail  Improper value for argument!

    ${condition1}=  Set Variable  '${BTS1_SYNC_ROLE}' != '' and '${BTS2_SYNC_ROLE}' == ''
    ${condition2}=  Set Variable  '${BTS1_SYNC_ROLE}' == '' and '${BTS2_SYNC_ROLE}' != ''
    Run Keyword If  ${condition1} or ${condition2}  Run Keywords
    ...  Log Long String  Improper values for test arguments \${BTS1_SYNC_ROLE} and \${BTS2_SYNC_ROLE}. Please select values for both test arguments
    ...  \${BTS1_SYNC_ROLE} and \${BTS2_SYNC_ROLE} from: Master or Slave (according to each BTS Sync role), otherwise let default value  console=True
    ...  AND  Fail  Improper value for argument!

    ${BTS_alias_sync_info_dict}=  Run Keyword If  '${BTS1_SYNC_ROLE}' != '' and '${BTS2_SYNC_ROLE}' != ''  Set all BTS Synchronization Information
    Return From Keyword If  '${BTS1_SYNC_ROLE}' != '' and '${BTS2_SYNC_ROLE}' != ''  ${BTS_alias_sync_info_dict}

    ${BTS_alias_sync_info_dict}=  Create Dictionary

    FOR  ${alias}  IN  @{alias_list}

        ${syncMode}  ${syncInputType}  ${tuningMode}  ${syncHubRole}  ${syncMaster}  ${holdOverModeUsed}=  Admin Get BTS Synchronization Information
        ...  ${alias}
        ${BTS_sync_info_dict}=  Create Dictionary  syncMode=${syncMode}  syncInputType=${syncInputType}  tuningMode=${tuningMode}
        ...  syncHubRole=${syncHubRole}  syncMaster=${syncMaster}  holdOverModeUsed=${holdOverModeUsed}
        Set To Dictionary  ${BTS_alias_sync_info_dict}  ${alias}  ${BTS_sync_info_dict}

    END

    [Return]  ${BTS_alias_sync_info_dict}

Set all BTS Synchronization Information

    ${BTS_alias_sync_info_dict}=  Create Dictionary

    FOR  ${alias}  IN  @{alias_list}

        ${BTS_label}=  Get From Dictionary  ${BTS_alias_label_dict}  ${alias}
        ${BTS_sync_info_dict}=  Create Dictionary  syncHubRole=${${BTS_label}_SYNC_ROLE}
        Set To Dictionary  ${BTS_alias_sync_info_dict}  ${alias}  ${BTS_sync_info_dict}

    END

    [Return]  ${BTS_alias_sync_info_dict}

Perform Reset Site without RU reset operation on BTS with peer BTS powered OFF
    [Arguments]  ${alias}

    ${peer_alias}=  Set Variable If  '${alias}' == 'Master'  Slave  Master
    Log  ***** Perform Reset Site without RU reset operation on BTS ${alias} with peer BTS ${peer_alias} powered OFF *****  console=True

    Prepare BTS expected transitory alarms with peer BTS powered OFF  ${alias}
    Prepare BTS expected stable alarms with peer BTS powered OFF  ${alias}

    Power BTS  ${peer_alias}  OFF
    Check BTS states and alarms with peer BTS powered OFF  ${alias}  ${peer_alias}

    Perform Reset Site without RU reset on BTS  ${alias}
    Check BTS states and alarms after BTS reset with peer BTS powered OFF  ${alias}  ${peer_alias}

    Power BTS  ${peer_alias}  ON
    Check BTS states and alarms after peer BTS powered ON  ${alias}  ${peer_alias}

    Get Current Date UTC info  final

Prepare BTS expected transitory alarms with peer BTS powered OFF
    [Arguments]  ${alias}

    ${all_BTS_PL_shared_RMOD_info}=  Get PL shared RM info on all BTS

    ${BTS_PL_shared_RMOD_info}=  Get From Dictionary  ${all_BTS_PL_shared_RMOD_info}  ${alias}

    ${BTS_non_PL_OBSAI_shared_RMOD_id_list}=  Get From Dictionary  ${BTS_PL_shared_RMOD_info}  BTS_non_PL_OBSAI_shared_RM_id_list
    ${BTS_non_PL_CPRI_shared_RMOD_id_list}=  Get From Dictionary  ${BTS_PL_shared_RMOD_info}  BTS_non_PL_CPRI_shared_RM_id_list
    ${BTS_non_PL_ECPRI_shared_RMOD_id_list}=  Get From Dictionary  ${BTS_PL_shared_RMOD_info}  BTS_non_PL_ECPRI_shared_RM_id_list
    ${BTS_non_PL_not_excepted_ECPRI_shared_RMOD_id_list}  ${BTS_non_PL_excepted_ECPRI_shared_RMOD_id_list}=
    ...  Get excepted and not excepted RMOD lists  ${BTS_non_PL_ECPRI_shared_RMOD_id_list}  ${RMOD_ECPRI_fid16_exceptions}  ${alias}

    ${BTS_non_PL_OBSAI_shared_RMOD_count}=  Get Length  ${BTS_non_PL_OBSAI_shared_RMOD_id_list}
    ${BTS_non_PL_CPRI_shared_RMOD_count}=  Get Length  ${BTS_non_PL_CPRI_shared_RMOD_id_list}
    ${BTS_non_PL_not_excepted_ECPRI_shared_RMOD_count}=  Get Length  ${BTS_non_PL_not_excepted_ECPRI_shared_RMOD_id_list}
    ${BTS_non_PL_excepted_ECPRI_shared_RMOD_count}=  Get Length  ${BTS_non_PL_excepted_ECPRI_shared_RMOD_id_list}

    ${BTS_EXPECTED_ALARMS_shared_RMOD_OBSAI_count}=  Set Variable  ${BTS_non_PL_OBSAI_shared_RMOD_count}
    ${BTS_EXPECTED_ALARMS_shared_RMOD_CPRI_count}=  Run Keyword If  ${${alias}_CB007447_status}
    ...  Set Variable  0
    ...  ELSE
    ...  Set Variable  ${BTS_non_PL_CPRI_shared_RMOD_count}
    ${BTS_EXPECTED_ALARMS_shared_RMOD_ECPRI_count}=  Set Variable  ${BTS_non_PL_not_excepted_ECPRI_shared_RMOD_count}

    ${BTS_EXPECTED_ALARMS_shared_RMOD_OBSAI_list}=  Prepare expected alarms list  ${test_alarms_list['${alias.upper()}_EXPECTED_ALARMS_10_1815']}
    ...  ${BTS_EXPECTED_ALARMS_shared_RMOD_OBSAI_count}
    ${BTS_EXPECTED_ALARMS_shared_RMOD_CPRI_list}=  Prepare expected alarms list  ${test_alarms_list['${alias.upper()}_EXPECTED_ALARMS_10_1815']}
    ...  ${BTS_EXPECTED_ALARMS_shared_RMOD_CPRI_count}
    ${BTS_EXPECTED_ALARMS_shared_RMOD_ECPRI_list}=  Prepare expected alarms list  ${test_alarms_list['${alias.upper()}_EXPECTED_ALARMS_16']}
    ...  ${BTS_EXPECTED_ALARMS_shared_RMOD_ECPRI_count}
    ${BTS_EXPECTED_ALARMS_shared_RMOD_OBSAI_CPRI_count}=  Evaluate
    ...  ${BTS_EXPECTED_ALARMS_shared_RMOD_OBSAI_count} + ${BTS_EXPECTED_ALARMS_shared_RMOD_CPRI_count}

    Set Test Variable  ${${alias.upper()}_EXPECTED_ALARMS_10_1815_count}  ${BTS_EXPECTED_ALARMS_shared_RMOD_OBSAI_CPRI_count}
    Set Test Variable  ${${alias.upper()}_EXPECTED_ALARMS_16_count}  ${BTS_EXPECTED_ALARMS_shared_RMOD_ECPRI_count}

    ${BTS_EXPECTED_ALARMS_transitory_list}=  Combine Lists  ${BTS_EXPECTED_ALARMS_shared_RMOD_OBSAI_list}
    ...  ${BTS_EXPECTED_ALARMS_shared_RMOD_CPRI_list}  ${BTS_EXPECTED_ALARMS_shared_RMOD_ECPRI_list}
    ${BTS_IGNORED_ALARMS_transitory_list}=  Combine Lists  ${test_alarms_list['${alias.upper()}_IGNORED_ALARMS']}
    ...  ${test_alarms_list['${alias.upper()}_IGNORED_ALARMS_DURING_POWER_OFF']}

    Set Test Variable  ${${alias.upper()}_EXPECTED_ALARMS_transitory_list}  ${BTS_EXPECTED_ALARMS_transitory_list}
    Set Test Variable  ${${alias.upper()}_IGNORED_ALARMS_transitory_list}  ${BTS_IGNORED_ALARMS_transitory_list}

Prepare BTS expected stable alarms with peer BTS powered OFF
    [Arguments]  ${alias}

    ${BTS_TRM_feature_dict}=  Get From Dictionary  ${BTS_alias_TRM_feature_dict}  ${alias}
    ${BTS_actTempRadioMaster}=  Get From Dictionary  ${BTS_TRM_feature_dict}  actTempRadioMaster
    ${BTS_tempRadioMasterTriggerTime}=  Get From Dictionary  ${BTS_TRM_feature_dict}  tempRadioMasterTriggerTime
    ${BTS_tempRadioMasterRecovTime}=  Get From Dictionary  ${BTS_TRM_feature_dict}  tempRadioMasterRecovTime
    Set Test Variable  ${${alias}_actTempRadioMaster}  ${BTS_actTempRadioMaster}
    Set Test Variable  ${${alias}_tempRadioMasterTriggerTime}  ${BTS_tempRadioMasterTriggerTime}
    Set Test Variable  ${${alias}_tempRadioMasterRecovTime}  ${BTS_tempRadioMasterRecovTime}

    ${BTS_controller_RMOD_sn_list}=  Get From Dictionary  ${all_BTS_controller_role_RMOD_sn_list}  ${alias}
    ${BTS_secondary_controller_RMOD_sn_list}=  Get From Dictionary  ${BTS_controller_RMOD_sn_list}  BTS_secondary_controller_RMOD_sn_list
    ${BTS_secondary_controller_RMOD_sn_count}=  Get Length  ${BTS_secondary_controller_RMOD_sn_list}

    Set Test Variable  ${${alias.upper()}_EXPECTED_ALARMS_4220_count}  ${BTS_secondary_controller_RMOD_sn_count}

    ${BTS_EXPECTED_ALARMS_stable_list}=  Prepare expected alarms list  ${test_alarms_list['${alias.upper()}_EXPECTED_ALARMS_4220']}
    ...  ${BTS_secondary_controller_RMOD_sn_count}

    ${BTS_IGNORED_ALARMS_stable_list}=  Combine Lists  ${test_alarms_list['${alias.upper()}_IGNORED_ALARMS']}
    ...  ${test_alarms_list['${alias.upper()}_IGNORED_ALARMS_DURING_POWER_OFF']}

    Set Test Variable  ${${alias.upper()}_EXPECTED_ALARMS_stable_list}  ${BTS_EXPECTED_ALARMS_stable_list}
    Set Test Variable  ${${alias.upper()}_IGNORED_ALARMS_stable_list}  ${BTS_IGNORED_ALARMS_stable_list}

Power BTS
    [Documentation]
    ...  Helper Keyword used to power ON/OFF BTS

    [Arguments]  ${alias}  ${power}

    Log  ***** Perform BTS ${alias} power ${power} *****  console=True

    ${power}=  Convert To Lower Case  ${power}
    Get Current Date UTC info  power_${power}

    ${PDU_port_status}=  Set BTS SMs PDU port status  ${${alias}_SM_PDU_if_name_list}  ${power}
    Run Keyword If  ${PDU_port_status}
    ...  Log  BTS ${alias} SMs PDU port status ${power}, as expected  console=True
    ...  ELSE  Run Keywords
    ...  Log  Set BTS ${alias} SMs PDU port status ${power} failed!  level=ERROR
    ...  AND  Fail  Set BTS ${alias} SMs PDU port status on failed!

Perform Reset Site without RU reset on BTS
    [Documentation]
    ...  Helper Keyword used to perform Reset Site without RU reset on BTS
    [Arguments]  ${alias}

    ${BTS_alias_list}=  Create List  ${alias}
    ${BTS_alias_RMOD_sn_Uptime_dict_initial}=  Get all BTS RMOD Uptime info  ${BTS_alias_list}
    Set Test Variable  ${BTS_alias_RMOD_sn_Uptime_dict_initial}

    Get Current Date UTC info  reset
    Get Current Time  reset

    Log  ***** Perform Reset Site without RU reset operation on BTS ${alias} *****  console=True
    ${GRACEFUL_CELL_SHUTDOWN}=  Convert To Boolean  ${GRACEFUL_CELL_SHUTDOWN}
    RFS Site Reset  graceful_cell_shutdown=${GRACEFUL_CELL_SHUTDOWN}  reset_without_ru=${TRUE}  wait_for_reconnection=${TRUE}  connection=${alias}

Check BTS states and alarms with peer BTS powered OFF
    [Arguments]  ${alias}  ${peer_alias}
    Check BTS transitory alarms with peer BTS powered OFF  ${alias}  ${peer_alias}
    Check BTS stable alarms with peer BTS powered OFF  ${alias}  ${peer_alias}
    Check BTS RMOD status with peer BTS powered OFF  ${alias}  ${peer_alias}

Check BTS transitory alarms with peer BTS powered OFF
    [Arguments]  ${alias}  ${peer_alias}

    Log  Check BTS ${alias} alarms in transitory phase with BTS ${peer_alias} powered OFF:  console=True

    Run Keyword If  ${${alias.upper()}_EXPECTED_ALARMS_10_1815_count} > 0
    ...  Log Long String  BTS ${alias} "No connection to Unit (10)" or "Not able to synchronize baseband bus (1815)" alarm, expected number:
    ...  ${${alias.upper()}_EXPECTED_ALARMS_10_1815_count}  console=True
    Run Keyword If  ${${alias.upper()}_EXPECTED_ALARMS_16_count} > 0
    ...  Log  BTS ${alias} "Unit synchronization failed (16)" alarm, expected number: ${${alias.upper()}_EXPECTED_ALARMS_16_count}
    ...  console=True

    Get and Check Alarms SOAM  alias=${alias}  poll_interval=5s  expected_alarms=${${alias.upper()}_EXPECTED_ALARMS_transitory_list}
    ...  ignored_alarms=${${alias.upper()}_IGNORED_ALARMS_transitory_list}  critical_alarms=${test_alarms_list['${alias.upper()}_CRITICAL_ALARMS']}

    Run Keyword If  ${${alias.upper()}_EXPECTED_ALARMS_10_1815_count} > 0
    ...  Log Long String  BTS ${alias} "No connection to Unit (10)" or "Not able to synchronize baseband bus (1815)" alarm, found number:
    ...  ${${alias.upper()}_EXPECTED_ALARMS_10_1815_count}  console=True
    Run Keyword If  ${${alias.upper()}_EXPECTED_ALARMS_16_count} > 0
    ...  Log  BTS ${alias} "Unit synchronization failed (16)" alarm, found number: ${${alias.upper()}_EXPECTED_ALARMS_16_count}
    ...  console=True

    Log  BTS ${alias} site - expected, ignored and critical alarms checked  console=True

Check BTS stable alarms with peer BTS powered OFF
    [Arguments]  ${alias}  ${peer_alias}

    Return From Keyword If  '${${alias}_actTempRadioMaster}' == 'false' or ${${alias.upper()}_EXPECTED_ALARMS_4220_count} == 0

    Log  Check BTS ${alias} alarms in stable phase with BTS ${peer_alias} powered OFF:  console=True
    Sleep  ${${alias}_tempRadioMasterTriggerTime}min

    Log Long String  BTS ${alias} "Radio slave has taken temporary radio master role (4220)" alarm, expected number:
    ...  ${${alias.upper()}_EXPECTED_ALARMS_4220_count}  console=True

    Get and Check Alarms SOAM  alias=${alias}  time=10 min  poll_interval=5s  expected_alarms=${${alias.upper()}_EXPECTED_ALARMS_stable_list}
    ...  ignored_alarms=${${alias.upper()}_IGNORED_ALARMS_stable_list}  critical_alarms=${test_alarms_list['${alias.upper()}_CRITICAL_ALARMS']}

    Log Long String  BTS ${alias} "Radio slave has taken temporary radio master role (4220)" alarm, found number:
    ...  ${${alias.upper()}_EXPECTED_ALARMS_4220_count}  console=True

    Log  BTS ${alias} site - expected, ignored and critical alarms checked  console=True

Check BTS RMOD status with peer BTS powered OFF
    [Arguments]  ${alias}  ${peer_alias}

    Log  Check BTS ${alias} RMOD status with BTS ${peer_alias} powered OFF:  console=True

    Assert Every  class_name=RMOD  parameters=${RMOD_state_enabled_check}  timeout=600  connection=${alias}
    Log  BTS ${alias} RMODs status:\n - ${RMOD_state_enabled}  console=True

Check BTS states and alarms after BTS reset with peer BTS powered OFF
    [Arguments]  ${alias}  ${peer_alias}

    ${BTS_sync_info_dict}=  Get From Dictionary  ${BTS_alias_sync_info_dict}  ${alias}
    ${BTS_syncHubRole}=  Get From Dictionary  ${BTS_sync_info_dict}  syncHubRole

    Run Keyword If  '${BTS_syncHubRole}' == 'Slave'
    ...  Check BTS Slave Sync role states and alarms  ${alias}  ${peer_alias}
    ...  ELSE IF  '${BTS_syncHubRole}' == 'Master'
    ...  Check BTS Master Sync role states and alarms  ${alias}  ${peer_alias}

Check BTS states and alarms after peer BTS powered ON
    [Arguments]  ${alias}  ${peer_alias}

    Check fault 4001 on BTS  alias=${alias}

    FOR  ${alias}  IN  @{alias_list}

        Log  Check BTS ${alias} states and alarms after BTS ${peer_alias} powered ON:  console=True
        Admin Check BTS Procedural and Blocking states  ${OnAir_}  ${Unblocked_}  ${BTS_MAX_WAIT_TIME}  ${alias}
        Log  BTS ${alias} status:\n - proceduralState: OnAir, blockingState: Unblocked  console=True

        Assert Every  class_name=RMOD  parameters=${RMOD_state_enabled_check}  timeout=${BTS_MAX_WAIT_TIME}  connection=${alias}
        Log  BTS ${alias} RMODs status:\n - ${RMOD_state_enabled}  console=True

        Check cells availability status online  ${alias}  ${BTS_MAX_WAIT_TIME}
        Log  BTS ${alias} cells status:\n - operationalState=Enabled, availabilityStatus=Online, blockingState=Unblocked  console=True

        Get and Check Alarms SOAM  alias=${peer_alias}  expected_alarms=@{EMPTY}
        ...  ignored_alarms=${test_alarms_list['${alias.upper()}_IGNORED_ALARMS']}
        ...  critical_alarms=${test_alarms_list['${alias.upper()}_CRITICAL_ALARMS']}
        Log  BTS ${alias} site - expected, ignored and critical alarms checked  console=True

    END

Check BTS Slave Sync role states and alarms
    [Arguments]  ${alias}  ${peer_alias}

    Log  Check BTS ${alias} (with Slave Sync role) states and alarms after BTS ${alias} reset with BTS ${peer_alias} powered OFF:  console=True

    ${remained_MAX_WAIT_TIME}=  Get elapsed time  ${time_reset}  ${BTS_MAX_WAIT_TIME}

    ${BTS_OnAir_status}=  Run Keyword And Return Status  Admin Check BTS Procedural and Blocking states  ${OnAir_}  ${Unblocked_}
    ...  ${remained_MAX_WAIT_TIME}  ${alias}
    Set Test Variable  ${${alias}_OnAir_status}  ${BTS_OnAir_status}

    ${BTS_info}=  Get Mrbts Info  detailed_output=True  connection=${alias}
    Log Long String  BTS ${alias} status:\n - proceduralState=${BTS_info['status']['proceduralState']},
    ...  operationalState=${BTS_info['status']['operationalState']}, blockingState=${BTS_info['status']['blockingState']}  console=True

    ${RMOD_sn_list}=  Get From Dictionary  ${BTS_alias_RMOD_sn_dict}  ${alias}

    FOR  ${RMOD_sn}  IN  @{RMOD_sn_list}

        ${RMOD_id}=  Get From Dictionary  ${${alias}_RMOD_sn_id_dict}  ${RMOD_sn}
        ${RMOD_info}=  Assert  class_name=RMOD  id=${RMOD_id}  connection=${alias}
        Log Long String  BTS ${alias} RMOD_${RMOD_sn} status:\n - operationalState=${RMOD_info['operationalState']},
        ...  administrativeState=${RMOD_info['administrativeState']}  console=True

    END

Check BTS Master Sync role states and alarms
    [Arguments]  ${alias}  ${peer_alias}

    Log  Check BTS ${alias} (with Master Sync role) states and alarms after BTS ${alias} reset with BTS ${peer_alias} powered OFF:  console=True

    ${remained_MAX_WAIT_TIME}=  Get elapsed time  ${time_reset}  ${BTS_MAX_WAIT_TIME}
    ${BTS_OnAir_status}=  Run Keyword And Return Status  Admin Check BTS Procedural and Blocking states  ${OnAir_}  ${Unblocked_}
    ...  ${remained_MAX_WAIT_TIME}  ${alias}
    Set Test Variable  ${${alias}_OnAir_status}  ${BTS_OnAir_status}

    ${BTS_info}=  Get Mrbts Info  detailed_output=True  connection=${alias}
    Log Long String  BTS ${alias} status:\n - proceduralState=${BTS_info['status']['proceduralState']},
    ...  operationalState=${BTS_info['status']['operationalState']}, blockingState=${BTS_info['status']['blockingState']}  console=True

    ${RMOD_sn_list}=  Get From Dictionary  ${BTS_alias_RMOD_sn_dict}  ${alias}

    FOR  ${RMOD_sn}  IN  @{RMOD_sn_list}

        ${remained_MAX_WAIT_TIME}=  Get elapsed time  ${time_reset}  ${BTS_MAX_WAIT_TIME}
        ${RMOD_id}=  Get From Dictionary  ${${alias}_RMOD_sn_id_dict}  ${RMOD_sn}
        Assert  class_name=RMOD  id=${RMOD_id}  parameters=${RMOD_state_enabled_check}  timeout=${remained_MAX_WAIT_TIME}  connection=${alias}
        Log  BTS ${alias} RMOD_${RMOD_sn} status:\n - ${RMOD_state_enabled}  console=True

    END

    Check BTS stable alarms with peer BTS powered OFF  ${alias}  ${peer_alias}

Check all BTS reset behavior based on IMS info
    [Documentation]
    ...  BTS RESET info is checked based on IMS info. Reset behavior as expected if:
    ...  - BTS ${alias} site: 1
    ...  - peer BTS site: 1
    ...  Otherwise, reset behavior not as expected, then errors are added to report and failed.
    [Arguments]  ${alias}

    Log  Check all BTS reset behavior based on IMS info  console=True
    ${peer_alias}=  Set Variable If  '${alias}' == 'Master'  Slave  Master

    ${BTS_FID4001_reset}=  Get Variable Value  ${${alias}_FID4001_reset}  ${FALSE}
    ${BTS_expected_reset_number}=  Set Variable If  ${BTS_FID4001_reset}  2  1
    Get and check BTS RESET info from IMS file  expected_reset_number=${BTS_expected_reset_number}  alias=${alias}
    ...  start_point_timestamp_UTC=${date_timestamp_reset_UTC}  end_point_timestamp_UTC=${date_timestamp_final_UTC}

    Get and check BTS RESET info from IMS file  expected_reset_number=1  alias=${peer_alias}
    ...  start_point_timestamp_UTC=${date_timestamp_power_off_UTC}  end_point_timestamp_UTC=${date_timestamp_final_UTC}

Check BTS RMOD reset behavior based on Uptime info
    [Documentation]
    ...  Shared and dedicated RMOD RESET behavior is checked based on Uptime info get from BTS (if BTS is syncHubRole Master ). RMOD reset behavior
    ...  as expected if:
    ...  - RMOD on BTS ${alias}: no reset if RU is eligible for CB012446 feature
    ...  Otherwise, reset behavior not as expected, then errors are added to report and failed.
    [Arguments]  ${alias}

    ${BTS_sync_info_dict}=  Get From Dictionary  ${BTS_alias_sync_info_dict}  ${alias}
    ${BTS_syncHubRole}=  Get From Dictionary  ${BTS_sync_info_dict}  syncHubRole

    Return From Keyword If  '${BTS_syncHubRole}' == 'Slave'

    Log  Check BTS RMOD reset behavior based on Uptime info  console=True

    ${BTS_alias_list}=  Create List  ${alias}
    ${BTS_alias_RMOD_sn_Uptime_dict_final}=  Get all BTS RMOD Uptime info  ${BTS_alias_list}
    Set Test Variable  ${BTS_alias_RMOD_sn_Uptime_dict_final}

    Check RMOD reset behavior on BTS  alias=${alias}

Get all BTS RMOD eligible for CB012446
    [Arguments]  ${BTS_alias_RMOD_sn_dict}  ${BTS_alias_RMOD_sn_RMOD_buildVersion_dict}  ${BTS_alias_RMOD_sn_RMOD_l3Protocol_dict}

    ${BTS_alias_CB012446_RMOD_sn_dict}=  Create Dictionary

    FOR  ${alias}  IN  @{alias_list}

        ${RMOD_sn_list}=  Get From Dictionary  ${BTS_alias_RMOD_sn_dict}  ${alias}
        ${RMOD_sn_RMOD_buildVersion_dict}=  Get From Dictionary  ${BTS_alias_RMOD_sn_RMOD_buildVersion_dict}  ${alias}
        ${RMOD_sn_RMOD_l3Protocol_dict}=  Get From Dictionary  ${BTS_alias_RMOD_sn_RMOD_l3Protocol_dict}  ${alias}

        ${CB012446_RMOD_sn_list}=  Get BTS RMOD eligible for CB012446  ${RMOD_sn_list}  ${RMOD_sn_RMOD_buildVersion_dict}
        ...  ${RMOD_sn_RMOD_l3Protocol_dict}

        Set To Dictionary  ${BTS_alias_CB012446_RMOD_sn_dict}  ${alias}   ${CB012446_RMOD_sn_list}

    END

    [Return]  ${BTS_alias_CB012446_RMOD_sn_dict}

Get BTS RMOD eligible for CB012446
    [Arguments]  ${RMOD_sn_list}  ${RMOD_sn_RMOD_buildVersion_dict}  ${RMOD_sn_RMOD_l3Protocol_dict}

    ${CB012446_RMOD_sn_list}=  Create List

    FOR  ${RMOD_sn}  IN  @{RMOD_sn_list}

        ${RMOD_l3Protocol}=  Get From Dictionary  ${RMOD_sn_RMOD_l3Protocol_dict}  ${RMOD_sn}

        Continue For Loop If  '${RMOD_l3Protocol}' not in ['CPRI_RP1', 'ECPRI_MPLANE']

        ${RMOD_buildVersion}=  Get From Dictionary  ${RMOD_sn_RMOD_buildVersion_dict}  ${RMOD_sn}
        ${RMOD_CB012446_excepted}  ${RMOD_SWline}=  Check RMOD exception for CB012446  ${RMOD_buildVersion}

        Continue For Loop If  ${RMOD_CB012446_excepted}

        Append To List  ${CB012446_RMOD_sn_list}  ${RMOD_sn}

    END

    Sort List  ${CB012446_RMOD_sn_list}

    [Return]  ${CB012446_RMOD_sn_list}

Check RMOD exception for CB012446
    [Arguments]  ${RMOD_buildVersion}

    ${RMOD_buildVersion_split_list}=  Split String  ${RMOD_buildVersion}  .

    FOR  ${item}  IN  @{RMOD_CB012446_exceptions}

        ${RMOD_CB012446_excepted}=  Run Keyword And Return Status  List Should Contain Value  ${RMOD_buildVersion_split_list}  ${item}

        Exit For Loop If  ${RMOD_CB012446_excepted}

    END

    ${RMOD_SWline}=  Set Variable  ${item}

    [Return]  ${RMOD_CB012446_excepted}  ${RMOD_SWline}

Check RMOD reset behavior on BTS
    [Arguments]  ${alias}

    Log  Check RMOD reset behavior on BTS ${alias}  console=True

    ${CB012446_RMOD_sn_list}=  Get From Dictionary  ${BTS_alias_CB012446_RMOD_sn_dict}  ${alias}
    ${CB012446_RMOD_count}=  Get Length  ${CB012446_RMOD_sn_list}

    Run Keyword If  ${CB012446_RMOD_count} == 0  Run Keywords
    ...  Log  No RMODs eligible for CB012446 feature on BTS ${alias}  console=True
    ...  AND  Return From Keyword

    ${RMOD_sn_Uptime_dict_initial}=  Get From Dictionary  ${BTS_alias_RMOD_sn_Uptime_dict_initial}  ${alias}
    ${RMOD_sn_Uptime_dict_final}=  Get From Dictionary  ${BTS_alias_RMOD_sn_Uptime_dict_final}  ${alias}

    Check RMODs RESET behavior based on Uptime info on BTS  RMOD_sn_list=${CB012446_RMOD_sn_list}
    ...  RMOD_sn_Uptime_dict_initial=${RMOD_sn_Uptime_dict_initial}  RMOD_sn_Uptime_dict_final=${RMOD_sn_Uptime_dict_final}  alias=${alias}

Check fault 4001 on BTS
    [Arguments]  ${alias}

    ${hostname_ip}=  Set Variable  ${${alias.upper()}}[${alias.upper()}_TECH_IP_ADDRESS]
    ${remote_host_ip}=  Set Variable If  '${alias}' == 'Master'  None  ${${alias.upper()}}[${alias.upper()}_PC_IP_ADDRESS]

    ${FID4001_active}=  Run Keyword And Return Status  Assert Alarm Active  parameters=faultId=4001  timeout=600  connection=${alias}
    Return From Keyword If  '${FID4001_active}' == 'False'

    ${FID4001_autonomous_reset}=  Run Keyword And Return Status  Assert Alarm Active  parameters=faultId=4001, alarmId=7101  connection=${alias}
    Run Keyword If  ${FID4001_autonomous_reset}  Run Keywords
    ...  Log  BTS ${alias} site autonomous reset as recovery action  console=True
    ...  AND  Wait For Target To Be Not Reachable TAF  hostname=${hostname_ip}  remote_host=${remote_host_ip}  timeout=300
    ...  AND  Wait For Target To Be Reachable TAF  hostname=${hostname_ip}  remote_host=${remote_host_ip}  timeout=300
    ...  AND  Set Test Variable  ${${alias}_FID4001_reset}  ${TRUE}
    ...  AND  Sleep  60s  Wait for Admin starting
    ...  AND  Admin Check all BTS cells expected states  expected_state=${CELL_state_enabled_check}  alias=${alias}
    ...  AND  Return From Keyword

    Log  BTS ${alias} reset is needed to activate features requiring network level synchronization accuracy  console=True
    coam.Reset Site  connection=${alias}
    Set Test Variable  ${${alias}_FID4001_reset}  ${TRUE}
    Sleep  60s  Wait for Admin starting
    Admin Check all BTS cells expected states  expected_state=${CELL_state_enabled_check}  alias=${alias}

Recover initial settings for CB012446 feature
    [Documentation]
    ...  Keyword used to recover initial settings for CB012446 features

    [Arguments]  ${alias}

    Log  Recover initial settings for CB012446 feature on BTS ${alias}  console=True
    ${cntrldResetMplaneBreakTimeSite_initial}=  Get From Dictionary  ${${alias}_BTS_CB012446_feature_dict}  cntrldResetMplaneBreakTimeSite
    Set classical BTS CB012446 feature parameter  cntrldResetMplaneBreakTimeSite  ${cntrldResetMplaneBreakTimeSite_initial}  ${alias}

Particular Teardown

    FOR  ${alias}  IN  @{alias_list}

        Recover BTS SMs PDU port status  ${${alias}_SM_PDU_if_name_list}  on  ${alias}

    END

    FOR  ${alias}  IN  @{alias_list}

        Recover initial settings for CB012446 feature  ${alias}

    END

TC Setup
    ${tech_preset_list}=  Create List  SBTS  SBTS
    Common Test Setup  preset_techs=${tech_preset_list}  common_sbts=${TRUE}  infomodelSetup=${FALSE}  newAlarmsFormat=${TRUE}

TC Teardown
    Common Test Teardown
