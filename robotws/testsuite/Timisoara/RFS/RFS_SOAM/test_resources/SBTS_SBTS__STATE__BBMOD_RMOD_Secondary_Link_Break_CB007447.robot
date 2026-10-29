*** Settings ***
Documentation    TC__SBTS_SBTS__STATE__BBMOD_RMOD_Secondary_Link_Break_CB007447
Variables    tc_variables/sbts_sbts__state__bbmod_rmod_secondary_link_break_cb007447.py
Resource    ../../resources/rfs_frame_rfs_soam_taf.robot

*** Variables ***
${REPEAT_COUNTER}                      3   # Number of link break operations, default value 3
${cpriSyncBreakTime}                       # cpriSyncBreakTime duration in ms; possible values: 100...10000, step 100ms; ex: 500

${stickToSyncSourcePeriod}                 # stickToSyncSourcePeriod duration in ms; possible values: 0...10000, step 10ms; ex: 400
${Link_break_duration}                     # Link break duration in ms; ex:3300
${SET_PRIMARY_LINK_TIME}             720   # Maximum time in seconds to wait for Primary Link set on ${BTS_PRIMARY_LINK}, default value: 720
${SHARED_RMOD_SERIAL_NUMBER_LIST}    ALL   # Shared RM serial number list on which link break will be performed. Possible values: ALL (operation
                                           # will be performed on all shared RM) or list of selected shared RM serial number separated by comma.
                                           # By default: ALL
${PM_Counters_Check}                 True  # PM counters check Flag for checking M40015C10 (short link break) and M40015C11 (long link break).
                                           # Possible values: True or False; by default: True
${DELAY_BETWEEN_SNAPSHOTS}           30    # In case of Snapshot collections during test (PM_Counters_Check=True and PM Counter Check fail),
                                           # defined as the delay time between Snapshot collections measured in seconds. Default value: 30
${RTWP_CHECK}                        True  # RTWP check during test steps, after link break. Possible values: True or False; by default: True
${ASOx_counters_flag}               False  # Flag for checking dedicated ASOx counters M40014C10 and M40014C11; Possible values: True, False;
                                           # Default value: False

*** Keywords ***
TC__SBTS_SBTS__STATE__BBMOD_RMOD_Secondary_Link_Break_CB007447
    [Documentation]
    ...  [CASE LINK]: https://jiradc.ext.net.nokia.com/browse/TAT-26679
    ...
    ...  *****************
    ...  Basic information
    ...  *****************
    ...  SBTS-SBTS test case for SBTS BBMOD RMOD Secondary Link Break - x times sequence.
    ...
    ...  The main steps performed for the test are:
    ...
    ...  - check initial state and alarms for both BTS
    ...  - get both BTS info for configured items: BTS role (primary/secondary controller per BTS), shared RM info
    ...  - check feature CB007447 status on both BTS and activate it if needed
    ...  - perform secondary link break between BBMOD and shared RMOD as follows:
    ...     - get shared RMOD Secondary Link Info before link break operation
    ...     - perform BBMOD_RMOD secondary link break on BTS checking states and alarms; RTWP check is also performed after ended action
    ...     - switch primary link on the BTS where secondary link break was performed
    ...     - perform BBMOD_RMOD secondary link break on peer BTS checking states and alarms; RTWP check is also performed after ended action
    ...     - repeat for all shared RMODs
    ...  - check final state and alarms for both BTS
    ...
    ...  Pass criteria: Scenario works as expected, states and alarms are as expected
    ...  ***************************
    ...  History of changes for SOAM
    ...  ***************************
    ...  - 20.05.2025 - https://jiradc.ext.net.nokia.com/browse/TAT-26679 - [5G][CB007447] - P1 - New Automated Test Scenario
    ...  [RFS_SBTS_SBTS__STATE__Secondary_Link_Configurable_Break_Duration]
    ...  - 29.07.2024 - https://jiradc.ext.net.nokia.com/browse/TAT-27837 - [5G] FID4742 is not calculated correct for CB007447 scripts when
    ...  using multiple RUs
    ...  - 07.08.2024 - https://jiradc.ext.net.nokia.com/browse/TAT-27838 - [CNI-127210] FID4760 to be checked in IMS for all CB007447 scripts
    ...  - 29.08.2024 - https://jiradc.ext.net.nokia.com/browse/TAT-27980 - [5G] Check R&D Fault in IMS for 7447 test-cases
    ...  - 05.09.2024 - https://jiradc.ext.net.nokia.com/browse/TAT-27963 - [5G] [Infomodel] Infomodel refactor KWs:
    ...  "Get linkModeConfiguration info dict" & "Get linkModeSynchronization info dict"
    ...  - 19.09.2024 - https://jiradc.ext.net.nokia.com/browse/TAT-28101 - Remove "enabledCpriLongLinkBreakAlarm" param check for CB007447
    ...  - 28.10.2024 - https://jiradc.ext.net.nokia.com/browse/TAT-28268 - PM delivery for
    ...  SBTS_SBTS__STATE__BBMOD_RMOD_Secondary_Link_Break_CB007447.robot
    ...  - 04.11.2024 - https://jiradc.ext.net.nokia.com/browse/TAT-28312 - [5G][CB007447] Resource KW "Set feature CB007447 on BTS" can be
    ...  enhanced to avoid FID1900 on radio unit
    ...  - 04.12.2024 - https://jiradc.ext.net.nokia.com/browse/TAT-28369 - [CB007447] Adapt 7447 Automated TCs to ASOx boards
    ...  - 20.12.2024 - https://jiradc.ext.net.nokia.com/browse/TAT-28384 - [CB007447] New counter check to be added to all 7447 automated TCs
    ...  - for Link_Break test - After TAT-28369
    ...  - 23.10.2025 - https://jiradc.ext.net.nokia.com/browse/TAT-30022 - Improve counters reading mechanism for Primary Link Break CB007447
    ...  - 17.11.2025 - https://jiradc.ext.net.nokia.com/browse/TAT-30185 - Adapt SBTS_SBTS__STATE__Uncontrolled_L1Soc_Reset_CB010846 with
    ...  ${actForceUnitAutoReset}' == 'false' case when CB007447 is enabled
    ...  - 21.11.2025 - https://jiradc.ext.net.nokia.com/browse/TAT-30176 - Add R&D fault check for Short Link Break in CB007447 TCs
    ...  - 27.11.2025 - https://jiradc.ext.net.nokia.com/browse/TAT-30221 - Remove ${actForceUnitAutoReset}' in tests and KWs related to CB007447
    ...  - 10.02.2026 - https://jiradc.ext.net.nokia.com/browse/TAT-30452 - Secondary Link Break robot with FID10 allowed for O&M long link break
    ...
    ...  *******************
    ...  Test case flowchart
    ...  *******************
    ...  .. image:: https://gitlabe1.ext.net.nokia.com/panda-docs/hran_doc/-/blob/master/testsuite/RFS_SOAM/
    ...  TAT-26679_SBTS_SBTS__STATE__BBMOD_RMOD_Secondary_Link_Break_CB007447.png

    Set Tags    CA-STATE    OWNER-raul.caraiman@nokia.com    AUTHOR-anca.tatar@nokia.com    PHASE-QT    SW-SBTS24R3

    TC Preconditions
    Step 1: Check initial both BTS state
    Step 2: Check initial both BTS alarms
    Step 3: Get both BTS info for configured items
    Step 4: Check and activate feature CB007447 on both BTS
    FOR  ${INDEX}  IN RANGE  1  ${REPEAT_COUNTER}+1
        Log  ==============================================================================  console=True
        Log  Start Cycle ${INDEX} of ${REPEAT_COUNTER}  console=True
        Log  ==============================================================================  console=True
        Step 5: Perform secondary link break between BBMOD and shared RMOD
        Step 6: Check final both BTS state
        Step 7: Check final both BTS alarms
        Step 8: Check final number and state of Cells and RMs
    END
    Check TC Verdict

    [Teardown]  Particular Teardown

TC Preconditions

    Run Keyword If  '${cpriSyncBreakTime}' == ''  Run Keywords
    ...  Log  Please select a proper value for test argument \${cpriSyncBreakTime}.  console=True
    ...  AND  Fail  Improper value for argument!

    Run Keyword If  '${stickToSyncSourcePeriod}' == ''  Run Keywords
    ...  Log  Please select a proper value for test argument \${stickToSyncSourcePeriod}.  console=True
    ...  AND  Fail  Improper value for argument!

    Run Keyword If  '${Link_break_duration}' == ''  Run Keywords
    ...  Log  Please select a proper value for test argument \${Link_break_duration}.  console=True
    ...  AND  Fail  Improper value for argument!

    Run Keyword If  '${PM_Counters_Check}'=='True'  Set Test Variable  ${TC_verdict_counters}  PASS

Step ${index}: Check ${when} both BTS state
    [Documentation]
    ...  SBTS state is checked according to Admin for BTS and each configured RAT

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
    ...  from Admin

    Log  Step ${index}: Check ${when} both BTS alarms  console=True
    FOR  ${alias}  IN  @{alias_list}
        Log  ***** Check ${when} BTS ${alias} alarms *****  console=True
        Get and Check Alarms SOAM  alias=${alias}  expected_alarms=@{EMPTY}  ignored_alarms=${test_alarms_list['${alias.upper()}_IGNORED_ALARMS']}
        ...  critical_alarms=${test_alarms_list['${alias.upper()}_CRITICAL_ALARMS']}
        Log  BTS ${alias} site - expected, ignored and critical alarms checked  console=True
    END

Step ${index}: Get both BTS info for configured items
    [Documentation]
    ...  Get both BTS info about following items:
    ...  - list of shared RMOD serial number configured on BTS primary controller (per BTS alias)
    ...  - list of shared RMOD serial number configured on BTS secondary controller (per BTS alias)

    Log  Step ${index}: Get both BTS info for configured items  console=True

    ${RMOD_sn_bts-alias_dict}  ${shared_RMOD_sn_list}  ${dedicated_RMOD_sn_list}=  Admin Get RM sn bts-alias info dict
    Set Test Variable  ${shared_RMOD_sn_list}

    FOR  ${alias}  IN  @{alias_list}
        ${BTS_primary_controller_shared_RMOD_sn_list}  ${BTS_secondary_controller_shared_RMOD_sn_list}=
        ...  Get BTS controller role shared RM SN list from SCF  ${shared_RMOD_sn_list}  ${alias}

        Log  BTS ${alias} configured as primary controller for: ${BTS_primary_controller_shared_RMOD_sn_list}  console=True
        Log  BTS ${alias} configured as secondary controller for: ${BTS_secondary_controller_shared_RMOD_sn_list}  console=True

        ${BTS_secondary_controller_shared_RMOD_count}=  Get Length  ${BTS_secondary_controller_shared_RMOD_sn_list}

        Set Test Variable  ${${alias}_BTS_secondary_controller_shared_RMOD_sn_list}  ${BTS_secondary_controller_shared_RMOD_sn_list}
        Set Test Variable  ${${alias}_BTS_secondary_controller_shared_RMOD_count}  ${BTS_secondary_controller_shared_RMOD_count}

        ${RMOD_list}=  Get Ids For All  class_name=RMOD  connection=${alias}
        Set Test Variable  ${${alias}_module_list}  ${RMOD_list}

        Get RMOD ID SN dict  ${alias}
        Get BBMOD ID SN dict  ${alias}
        Get SMOD ID SN dict  ${alias}

        Continue For Loop If  '${PM_Counters_Check}' != 'True'

        Get BTS MODULE LANE info dict  RMOD  ${alias}
        Set Test Variable  ${${alias}_MODULE_LANE_dict}  ${MODULE_LANE_dict}
    END

    Run Keyword If  '${SHARED_RMOD_SERIAL_NUMBER_LIST}' != 'ALL'  Check shared RMOD SN list
    Log  =======================================================  console=True
    Log  Shared RMOD serial number list selected for link break action: ${shared_RMOD_sn_list}  console=True
    Log  =======================================================  console=True

Step ${index}: Check and activate feature CB007447 on both BTS
    [Documentation]
    ...  Check feature CB007447 status on both BTS and enable it if needed

    Log  Step ${index}: Check and activate feature CB007447 on both BTS  console=True

    Set Test Variable  ${Master_CB007447_check}  False
    Set Test Variable  ${Slave_CB007447_check}  False
    ${BTS1_FID4742_count}=  Set Variable  ${Master_BTS_secondary_controller_shared_RMOD_count}
    ${BTS2_FID4742_count}=  Set Variable  ${Slave_BTS_secondary_controller_shared_RMOD_count}
    ${BTS1_EXPECTED_ALARMS_4742}=  Prepare expected alarms list  ${test_alarms_list['MASTER_EXPECTED_ALARMS_4742']}  ${BTS1_FID4742_count}
    ${BTS2_EXPECTED_ALARMS_4742}=  Prepare expected alarms list  ${test_alarms_list['SLAVE_EXPECTED_ALARMS_4742']}  ${BTS2_FID4742_count}

    Check initial feature CB007447 status  Master
    Check initial feature CB007447 status  Slave

    ${condition}=  Create Long String  '${Master_actCpriLinkRecovery_initial}' == 'false' or '${Master_actSyncLinkSwitchover_initial}' == 'false'

    Run Keyword If  not ${Master_CB007447_check}  Run Keywords
    ...  Log  Activating feature CB007447 on BTS Master!  console=True
    ...  AND  Set feature CB007447 on BTS
    ...  cpriSyncBreakTime_value=${cpriSyncBreakTime}  stickToSyncSourcePeriod_value=${stickToSyncSourcePeriod}  alias=Master
    ...  AND  Check final feature CB007447 status  Master
    ...  AND  Set Test Variable  ${Master_CB007447_check}  True

    Run Keyword If  ${condition}  Run Keywords
    ...  Check BTS alarms after activate CB007447 feature  Master  Master  ${BTS1_FID4742_count}  ${BTS1_EXPECTED_ALARMS_4742}
    ...  AND  Check BTS alarms after activate CB007447 feature  Slave  Master  ${BTS2_FID4742_count}  ${BTS2_EXPECTED_ALARMS_4742}

    Run Keyword If  not ${Slave_CB007447_check}  Run Keywords
    ...  Log  Activating feature CB007447 on BTS Slave!  console=True
    ...  AND  Set feature CB007447 on BTS
    ...  cpriSyncBreakTime_value=${cpriSyncBreakTime}  stickToSyncSourcePeriod_value=${stickToSyncSourcePeriod}  alias=Slave
    ...  AND  Check final feature CB007447 status  Slave
    ...  AND  Set Test Variable  ${Slave_CB007447_check}  True
    ...  AND  Check BTS alarms after activate CB007447 feature  Master  Slave  0
    ...  AND  Check BTS alarms after activate CB007447 feature  Slave  Slave  0

    Run Keyword If  '${PM_Counters_Check}'!='True'  Return From Keyword

    FOR  ${alias}  IN  @{alias_list}
        Check initial mt param   ${alias}  mtSbtsSfpBbmodLane
        Check initial mt param   ${alias}  mtSbtsSfpSmodLane
    END

    Check BTS SCF Validation On Demand  alias=Master
    Check BTS SCF Validation On Demand  alias=Slave
    Get all SMOD board types

Step ${index}: Perform secondary link break between BBMOD and shared RMOD

    [Documentation]
    ...  Perform link break between BBMOD and shared RM

    Log  Step ${index}: Perform secondary link break between BBMOD and shared RMOD  console=True

    Setup for Optical Switch

    FOR  ${RMOD_sn}  IN  @{shared_RMOD_sn_list}
        Log  ***** Secondary Link Break will be performed on both BTS for shared RMOD with SN ${RMOD_sn} *****  console=True

        ${non_PL_alias}=  Check alias of secondary link  ${RMOD_sn}
        ${PL_alias}=  Set Variable If  '${non_PL_alias}' == 'Master'  Slave  Master
        Secondary Link Break on BTS  ${RMOD_sn}  ${non_PL_alias}  ${PL_alias}

        Set Primary Link on BTS  ${RMOD_sn}  ${non_PL_alias}

        ${new_non_PL_alias}=  Check alias of secondary link  ${RMOD_sn}
        ${new_PL_alias}=  Set Variable If  '${new_non_PL_alias}' == 'Master'  Slave  Master
        Secondary Link Break on BTS  ${RMOD_sn}  ${new_non_PL_alias}  ${new_PL_alias}

    END

Step ${index}: Check final number and state of Cells and RMs
    [Documentation]
    ...  Cells state is checked according to operationalState attribute
    ...  Check if number of configured cells and radio modules in SCF are properly mapping on BTS running view.
    ...  Also check RMs operationalState

    [Timeout]  30 min
    Log  Step ${index}: Check final number and state of Cells and RMs  console=True
    RFS Test Case Final Checks

Check shared RMOD SN list
    ${SHARED_RMOD_SERIAL_NUMBER_LIST_strip}=  Replace String  ${SHARED_RMOD_SERIAL_NUMBER_LIST}  ${SPACE}  ${EMPTY}
    ${SHARED_RMOD_SERIAL_NUMBER_LIST}=  Split String  ${SHARED_RMOD_SERIAL_NUMBER_LIST_strip}  ,
    ${shared_RMOD_sn_check}=  Set Variable  True
    ${shared_RMOD_SN_invalide_list}=  Create List

    FOR  ${item}  IN  @{SHARED_RMOD_SERIAL_NUMBER_LIST}
        ${shared_RMOD_sn_check}=  Set Variable If  '${item}' not in ${shared_RMOD_sn_list}  False  ${shared_RMOD_sn_check}
        Run Keyword If  '${item}' not in ${shared_RMOD_sn_list}  Append To List  ${shared_RMOD_sn_invalide_list}  ${item}
    END

    Run Keyword If  '${shared_RMOD_sn_check}' == 'False'  Run Keywords
    ...  Log  Following selected shared RMOD serial number values are not valid: ${shared_RMOD_sn_invalide_list}.  console=True
    ...  AND  Log  Please select values for test argument \${SHARED_RMOD_SERIAL_NUMBER_LIST} from configured shared RMOD: ${shared_RMOD_sn_list}
    ...  console=True
    ...  AND  Fail  Improper value for argument!

    Set Test Variable  ${shared_RMOD_sn_list}  ${SHARED_RMOD_SERIAL_NUMBER_LIST}

Check initial feature CB007447 status
    [Arguments]  ${alias}

    Log  Check initial feature CB007447 status on BTS ${alias}:  console=True

    ${actCpriLinkRecovery_initial}  ${actSyncLinkSwitchover_initial}  ${cpriSyncBreakTime_initial}  ${stickToSyncSourcePeriod_initial}=
    ...  Get feature CB007447 info  ${alias}

    Log  Initial actCpriLinkRecovery parameter value: ${actCpriLinkRecovery_initial}  console=True
    Log  Initial actSyncLinkSwitchover parameter value: ${actSyncLinkSwitchover_initial}  console=True
    Log  Initial cpriSyncBreakTime parameter value: ${cpriSyncBreakTime_initial}  console=True
    Log  Initial stickToSyncSourcePeriod parameter value: ${stickToSyncSourcePeriod_initial}  console=True

    Set Test Variable  ${${alias}_actCpriLinkRecovery_initial}  ${actCpriLinkRecovery_initial}
    Set Test Variable  ${${alias}_actSyncLinkSwitchover_initial}  ${actSyncLinkSwitchover_initial}
    Set Test Variable  ${${alias}_cpriSyncBreakTime_initial}  ${cpriSyncBreakTime_initial}
    Set Test Variable  ${${alias}_stickToSyncSourcePeriod_initial}  ${stickToSyncSourcePeriod_initial}

    ${condition}=  Create Long String  '${actCpriLinkRecovery_initial}' == 'true' and '${actSyncLinkSwitchover_initial}' == 'true' and
    ...  '${cpriSyncBreakTime_initial}' == '${cpriSyncBreakTime}' and '${stickToSyncSourcePeriod_initial}' == '${stickToSyncSourcePeriod}'

    Run Keyword If  ${condition}  Run Keywords
    ...  Log  Feature CB007447 already activated on BTS ${alias}, no action needed!  console=True
    ...  AND  Set Test Variable  ${${alias}_CB007447_check}  True
    ...  ELSE  Run Keywords  Log  Need to activate feature CB007447 on BTS ${alias}!  console=True
    ...  AND  Set Test Variable  ${${alias}_CB007447_check}  False

Check final feature CB007447 status
    [Arguments]  ${alias}

    Log  Check final feature CB007447 status on BTS ${alias}:  console=True

    ${actCpriLinkRecovery_final}  ${actSyncLinkSwitchover_final}  ${cpriSyncBreakTime_final}  ${stickToSyncSourcePeriod_final}=
    ...  Get feature CB007447 info  ${alias}

    Run Keyword If  '${actCpriLinkRecovery_final}' == 'true'
    ...  Log  Final actCpriLinkRecovery parameter value: ${actCpriLinkRecovery_final}, as expected!  console=True
    ...  ELSE  Run Keywords
    ...  Log  Parameter actCpriLinkRecovery = ${actCpriLinkRecovery_final}, not properly commissioned!  level=ERROR
    ...  AND  Fail  Parameter actCpriLinkRecovery = ${actCpriLinkRecovery_final}, not properly commissioned!

    Run Keyword If  '${actSyncLinkSwitchover_final}' == 'true'
    ...  Log  Final actSyncLinkSwitchover parameter value: ${actSyncLinkSwitchover_final}, as expected!  console=True
    ...  ELSE  Run Keywords
    ...  Log  Parameter actSyncLinkSwitchover = ${actSyncLinkSwitchover_final}, not properly commissioned!  level=ERROR
    ...  AND  Fail  Parameter actSyncLinkSwitchover = ${actSyncLinkSwitchover_final}, not properly commissioned!

    Run Keyword If  '${cpriSyncBreakTime_final}' == '${cpriSyncBreakTime}'
    ...  Log  Final cpriSyncBreakTime parameter value: ${cpriSyncBreakTime_final}, as expected!  console=True
    ...  ELSE  Run Keywords
    ...  Log  Parameter cpriSyncBreakTime = ${cpriSyncBreakTime}, not properly commissioned!  level=ERROR
    ...  AND  Fail  Parameter cpriSyncBreakTime = ${cpriSyncBreakTime}, not properly commissioned!

    Run Keyword If  '${stickToSyncSourcePeriod_final}' == '${stickToSyncSourcePeriod}'
    ...  Log  Final stickToSyncSourcePeriod parameter value: ${stickToSyncSourcePeriod_final}, as expected!  console=True
    ...  ELSE  Run Keywords
    ...  Log  Parameter stickToSyncSourcePeriod = ${stickToSyncSourcePeriod_final}, not properly commissioned!  level=ERROR
    ...  AND  Fail  Parameter stickToSyncSourcePeriod = ${stickToSyncSourcePeriod_final}, not properly commissioned!

Check BTS alarms after activate CB007447 feature
    [Arguments]  ${alias}  ${BTS_feature_activation}  ${expected_alarms_count}  ${expected_alarms_list}=@{EMPTY}

    Log  Check BTS ${alias} alarms after activate CB007447 feature on BTS ${BTS_feature_activation}  console=True
    Log  BTS ${alias} "Configuration mismatch between peer BTSs (4742)" alarm, expected number: ${expected_alarms_count}  console=True
    Get and Check Alarms SOAM  alias=${alias}  expected_alarms=${expected_alarms_list}
    ...  ignored_alarms=${test_alarms_list['${alias.upper()}_IGNORED_ALARMS']}
    ...  critical_alarms=${test_alarms_list['${alias.upper()}_CRITICAL_ALARMS']}
    Log  BTS ${alias} "Configuration mismatch between peer BTSs (4742)" alarm, found number: ${expected_alarms_count}, as expected!  console=True
    Log  BTS ${alias} site - expected, ignored and critical alarms checked  console=True

Setup for Optical Switch
    Optical Switch Setup  switch_ip=${OPTICAL_SWITCH['IP']}  switch_username=${OPTICAL_SWITCH['USERNAME']}
    ...  switch_password=${OPTICAL_SWITCH['PASSWORD']}  port=${OPTICAL_SWITCH['PORT']}

Check alias of secondary link
    [Arguments]  ${RMOD_sn}

    FOR  ${alias}  IN  @{alias_list}
        Check secondary link between Capacity Module and shared RMOD  ${RMOD_sn}  ${alias}
        Run Keyword If  ${${alias}_secondary_link_status}  Run Keywords
	    ...  Log  Secondary link is on RMOD_${RMOD_sn} from BTS ${alias}  console=True
	    ...  AND  Return From Keyword  ${alias}
    END

Check secondary link between Capacity Module and shared RMOD
    [Arguments]  ${RMOD_sn}  ${alias}
    ${BBMOD_sn_list}=  Get Dictionary Keys  ${${alias}_BBMOD_SN_ID_dict}
    ${SMOD_sn_list}=  Get Dictionary Keys  ${${alias}_SMOD_SN_ID_dict}
    ${capacity_modules_sn_list}=  Combine Lists  ${BBMOD_sn_list}  ${SMOD_sn_list}

    FOR  ${item}  IN  @{capacity_modules_sn_list}
        ${cap_module_sn}=  Set Variable  ${item}
        ${firstModule_connectorLabel_linkModeSynchronization_dict}  ${secondModule_connectorLabel_linkModeSynchronization_dict}
        ...  ${firstModule_connectorLabel_linkModeConfiguration_dict}  ${secondModule_connectorLabel_linkModeConfiguration_dict}
        ...  ${firstModule_secondModule_connectorLabel}
        ...  ${secondModule_firstModule_connectorLabel}=   Get linkModeSynchronization and linkModeConfiguration info dict
        ...  ${cap_module_sn}  ${RMOD_sn}  ${alias}
        Set Test Variable  ${${alias}_${RMOD_sn}_${cap_module_sn}_connectorLabel_linkModeConfiguration_dict}
        ...  ${secondModule_connectorLabel_linkModeConfiguration_dict}
        Set Test Variable  ${${alias}_${RMOD_sn}_${cap_module_sn}_connectorLabel_linkModeSynchronization_dict}
        ...  ${secondModule_connectorLabel_linkModeSynchronization_dict}
        Set Test Variable  ${${alias}_${cap_module_sn}_${RMOD_sn}_connectorLabel_linkModeConfiguration_dict}
        ...  ${firstModule_connectorLabel_linkModeConfiguration_dict}
        Set Test Variable  ${${alias}_${cap_module_sn}_${RMOD_sn}_connectorLabel}  ${firstModule_secondModule_connectorLabel}
        Set Test Variable  ${${alias}_${RMOD_sn}_${cap_module_sn}_connectorLabel}  ${secondModule_firstModule_connectorLabel}
    END
    FOR  ${item}  IN  @{capacity_modules_sn_list}
        ${RMOD_connectorLabel_list}=  Get Dictionary Values  ${${alias}_${item}_${RMOD_sn}_connectorLabel}
        Continue For Loop If  not ${RMOD_connectorLabel_list}
        ${cap_module_RMOD_secondary_link_dict}=  Get secondary link  ${item}  ${RMOD_sn}  ${RMOD_connectorLabel_list}  ${alias}
        Continue For Loop If  '${${alias}_secondary_link_status}' == 'False'
        Log  Secondary link between shared RMOD_${RMOD_sn} capacity module ${item} info from ${alias}  console=True
        ${shared_cap_module_RMOD_secondary_link_keys}=  Get Dictionary Keys  ${cap_module_RMOD_secondary_link_dict}
        ${shared_cap_module_RMOD_secondary_link_values}=  Get Dictionary Values  ${cap_module_RMOD_secondary_link_dict}
        ${cap_module_connectorLabel}=  Set Variable  ${shared_cap_module_RMOD_secondary_link_keys[0]}
        ${RMOD_connectorLabel}=  Set Variable  ${shared_cap_module_RMOD_secondary_link_values[0]}
        Log  - Capacity Module connectorLabel: ${cap_module_connectorLabel} - shared RMOD connectorLabel: ${RMOD_connectorLabel}  console=True
        Set Test Variable  ${RMOD_connectorLabel}
        Set Test Variable  ${cap_module_connectorLabel}
        Set Test Variable  ${cap_module_sn}  ${item}
        Exit For Loop
    END

Get secondary link
    [Arguments]  ${cap_module_sn}  ${RMOD_sn}  ${RMOD_connectorLabel_list}  ${alias}
    ${cap_module_RMOD_secondary_link_dict}=  Create Dictionary
    FOR  ${item}  IN  @{RMOD_connectorLabel_list}
        ${linkModeConfiguration}=  Get From Dictionary  ${${alias}_${RMOD_sn}_${cap_module_sn}_connectorLabel_linkModeConfiguration_dict}  ${item}
        ${linkModeSynchronization}=  Get From Dictionary  ${${alias}_${RMOD_sn}_${cap_module_sn}_connectorLabel_linkModeSynchronization_dict}  ${item}
        ${cap_module_connectorLabel}=  Get From Dictionary  ${${alias}_${RMOD_sn}_${cap_module_sn}_connectorLabel}  ${item}
        Run Keyword If  '${linkModeConfiguration}' == 'True' and '${linkModeSynchronization}' == 'False'  Run Keywords
        ...  Set Test Variable  ${${alias}_secondary_link_status}  True
        ...  AND  Exit For Loop
        ...  ELSE  Set Test Variable  ${${alias}_secondary_link_status}  False
    END
    Run Keyword If  ${${alias}_secondary_link_status}
    ...  Set To Dictionary  ${cap_module_RMOD_secondary_link_dict}  ${cap_module_connectorLabel}  ${item}
    [Return]  ${cap_module_RMOD_secondary_link_dict}

Secondary Link Break on BTS
    [Arguments]  ${RMOD_sn}  ${alias}  ${peer_alias}

    ${duration}=  Evaluate  ${cpriSyncBreakTime} + 1770
    Run Keyword If  ${Link_break_duration} <= ${duration}
    ...  Check the behavior for short link break  ${RMOD_sn}  ${alias}  ${peer_alias}
    ...  ELSE IF  ${Link_break_duration} >= ${duration}
    ...  Check the behavior for long link break  ${RMOD_sn}  ${alias}  ${peer_alias}

Check the behavior for short link break
    [Arguments]  ${RMOD_sn}  ${alias}  ${peer_alias}

    Perform secondary link break  ${RMOD_sn}  ${alias}
    Check alarms after link break  short  ${alias}
    Check alarms after link break  short  ${peer_alias}
    Check both BTS states and alarms after link break  ${RMOD_sn}  ${alias}  ${peer_alias}
    Check BTS alarms from IMS  ${alias}  4721
    Run Keyword If  '${PM_Counters_Check}'=='True'  Check PM counters  M40015C10  ${RMOD_sn}  ${alias}
    Run Keyword If  ${RTWP_CHECK}  Launch RTWP Check on Demand

Check the behavior for long link break
    [Arguments]  ${RMOD_sn}  ${alias}  ${peer_alias}

    Perform secondary long link break and check alarms  ${RMOD_sn}  ${alias}
    Check alarms after link break  long  ${peer_alias}
    Check both BTS states and alarms after link break  ${RMOD_sn}  ${alias}  ${peer_alias}
    Check BTS alarms from IMS  ${alias}  4760
    Run Keyword If  '${PM_Counters_Check}'=='True'  Check PM counters  M40015C11  ${RMOD_sn}  ${alias}
    Run Keyword If  ${RTWP_CHECK}  Launch RTWP Check on Demand

Check PM counters
    [Arguments]  ${counter_id}  ${RMOD_sn}  ${alias}

    Log  Checking ${counter_id} counter value on BTS ${alias}  console=True
    ${SMOD_params_list}=  Get From Dictionary  ${alias_SMOD_board_types_dict}  ${alias}
    ${RMOD_Id}=  Get From Dictionary  ${${alias}_module_SN_ID_dict}  ${RMOD_sn}
    ${LANE_Id}=  Get From Dictionary  ${${alias}_MODULE_LANE_dict}  ${RMOD_Id}
    ${LANE_Id}=  Set Variable  ${LANE_Id}[0]
    ${SFP_Id}=  Fetch From Left  ${LANE_Id}  /LANE_R-
    ${SFP_R_number}=  Fetch From Right  ${SFP_Id}  /SFP_R-
    ${module_R_id}=  Fetch From Left  ${SFP_Id}  /SFP_R-
    ${product Name}=  Set Variable   None

    FOR  ${SMOD_params}  IN  @{SMOD_params_list}
        ${SMOD_present}=  Run Keyword And Return Status  Dictionary Should Contain Key  ${SMOD_params}  ${module_R_id}
        Continue For Loop If  not ${SMOD_present}
        ${product Name}=  Get From Dictionary  ${SMOD_params}  ${module_R_id}
        Exit For Loop
    END

    ${is_ASOx}=  Run Keyword And Return Status  Should Match Regexp    ${product Name}}    ASO[\\s\\S] AirScale Core
    ${mt_param}=  Set Variable If  ${is_ASOx} and '${ASOx_counters_flag}'=='True'  mtSbtsSfpSmodLane  mtSbtsSfpBbmodLane
    ${alternate_counter_ids}=  Create Dictionary  M40015C10=M40014C10  M40015C11=M40014C11
    Run Keyword If  ${is_ASOx} and '${ASOx_counters_flag}'=='True'
    ...  Log  Since ASOx_counters_flag=True and board product name is ${product Name}, counter ${alternate_counter_ids["${counter_id}"]} will apply!
    ${counter_id_to_check}=  Set Variable If  ${is_ASOx} and '${ASOx_counters_flag}'=='True'
    ...  ${alternate_counter_ids["${counter_id}"]}  ${counter_id}
    ${LANE_R_number}=  Fetch From Right  ${LANE_Id}  /LANE_R-
    ${SFP_SCF_dn}=  Get SFP SCF distinguished name  ${SFP_Id}  ${alias}
    ${SFP_counters_path}=  Fetch From Left  ${SFP_SCF_dn}  /SFP-
    ${last_obj}=  Set Variable If  ${is_ASOx}  SBTS_SFP_SMOD_LANE  SBTS_SFP_BBMOD_LANE
    ${LANE_counters_dn}=  Set Variable  ${SFP_counters_path}/SFP-${SFP_R_number}/LANE-${LANE_R_number}/${last_obj}
    ${epoch_time_now}=  OperatingSystem.Run    date +%s
    ${elapsed_time_seconds}=    Evaluate  ${epoch_time_now}-${link_break_event_epoch_time}
    ${remaining_time}=  Evaluate  ${${alias}_${mt_param}_seconds}-${elapsed_time_seconds}
    ${guard_time}=  Set Variable  45

    Run Keyword If  ${remaining_time}>0  Run Keywords
    ...  Log  Waiting ${remaining_time}s for PM completion  console=True
    ...  AND  Sleep  ${remaining_time}s
    Log  Waiting ${guard_time}s more as guard time to assure last PM availability  console=True
    Sleep  ${guard_time}s

    ${counter value}=  Get PM Counter Value from Admin
    ...  ${LANE_counters_dn}   ${counter_id_to_check}  ${link_break_event_epoch_time}  ${${alias}_${mt_param}_seconds}  ${alias}
    Check counter value  ${counter_id_to_check}  ${counter value}  ${alias}

Check counter value
    [Arguments]    ${counter_id}  ${counter value}  ${alias}
    Run Keyword If  ${counter value}==0  Run Keywords
    ...  Log  ${counter_id} counter value: ${counter value}, not incremented! Please check logs  level=ERROR
    ...  AND  Mid Test Snapshot collection  ${alias}  PM counter ${counter_id} not incremented
    ...  AND  Set Test Variable  ${TC_verdict_counters}  FAIL
    ...  AND  Return From Keyword
    Run Keyword If  ${counter value}==1  Run Keywords
    ...  Log  ${counter_id} counter value: ${counter value}, incremented as expected!  console=True
    ...  AND  Return From Keyword
    Run Keyword If  ${counter value}==2  Run Keywords
    ...  Log  ${counter_id} counter value: ${counter value}, incremented, but twice! Please check logs  level=WARN
    ...  AND  Mid Test Snapshot collection  ${alias}  PM counter ${counter_id} incremented twice
    ...  AND  Return From Keyword
    Run Keyword If  ${counter value}>2  Run Keywords
    ...  Log  ${counter_id} counter value: ${counter value}, incremented more than twice! Please check logs  level=ERROR
    ...  AND  Mid Test Snapshot collection  ${alias}  PM counter ${counter_id} incremented more than twice
    ...  AND  Set Test Variable  ${TC_verdict_counters}  FAIL
    ...  AND  Return From Keyword

Perform secondary link break
    [Arguments]  ${RMOD_sn}  ${alias}

    ${BBMOD_sn_list}=  Get Dictionary Keys  ${${alias}_BBMOD_SN_ID_dict}
    ${SMOD_sn_list}=  Get Dictionary Keys  ${${alias}_SMOD_SN_ID_dict}
    ${module_type}=  Set Variable If  '${cap_module_sn}' in ${SMOD_sn_list}  SMOD  BBMOD

    Log Long String  ***** Performing secondary link break between ${module_type}_${cap_module_sn} port
    ...  ${cap_module_connectorLabel} and shared RMOD_${RMOD_sn} port ${RMOD_connectorLabel} on BTS ${alias} *****
    ...  console=True

    Get Current Date UTC info  start_link_break

    Check Optical Switch definition info  ${module_type}  ${cap_module_sn}  ${cap_module_connectorLabel}
    Check Optical Switch definition info  RMOD  ${RMOD_sn}  ${RMOD_connectorLabel}

    ${cross_connection}=  Get Cross Connection Id
    ...  ${${module_type}_${cap_module_sn}_${cap_module_connectorLabel}_cross_connection}
    ...  ${RMOD_${RMOD_sn}_${RMOD_connectorLabel}_cross_connection}

    Run Keyword If  '${PM_Counters_Check}'=='True'  Synchronize link break event to PM generation  ${alias}  mtSbtsSfpSmodLane
    ...  ${Link_break_duration}

    Set link break  ${cross_connection}

    Run Keyword If  '${PM_Counters_Check}'!='True'  Return From Keyword
    ${event_epoch_time}=  GET event epoch time
    Set Test Variable  ${link_break_event_epoch_time}  ${event_epoch_time}
    Log  Link break event epoch time: ${link_break_event_epoch_time}  console=True

Set link break
    [Arguments]  ${cross_connection}

    Optical Switch Setup  switch_ip=${OPTICAL_SWITCH['IP']}  switch_password=${OPTICAL_SWITCH['PASSWORD']}
    ...  switch_username=tl1user  port=22
    ...  alias=TL1_alias  protocol=tl1

    Log  Perform link break=${Link_break_duration} on connection_id: ${cross_connection}  console=True
    ${link_break_status}=  Run Keyword And Return Status  Set Short Link Break by Connection ID
    ...  connection_id=${cross_connection}  lowperiod=${Link_break_duration}  highperiod=${Link_break_duration}
    ...  repeat=1  optical_switch_device=TL1_alias
    Log  Link break status is: ${link_break_status}  console=True

    [Teardown]  Teardown Optical Switch  alias=TL1_alias

Perform secondary long link break and check alarms
    [Arguments]  ${RMOD_sn}  ${alias}

    ${ignored_alarms_full}=  Run Keyword If  ${Link_break_duration} >= 12000
    ...  Combine Lists  ${test_alarms_list['${alias.upper()}_IGNORED_ALARMS']}  ${test_alarms_list['${alias.upper()}_IGNORED_ALARMS_10']}
    ...  ${test_alarms_list['${alias.upper()}_IGNORED_ALARMS_4694']}
    ...  ELSE  Combine Lists  ${test_alarms_list['${alias.upper()}_IGNORED_ALARMS']}  ${test_alarms_list['${alias.upper()}_IGNORED_ALARMS_4694']}

    Perform secondary link break  ${RMOD_sn}  ${alias}

    Log  Check unnexpected BTS ${alias} alarms after long link break:  console=True

    Run Keyword If  ${Link_break_duration} >= 12000
    ...  Get and Check Alarms SOAM  alias=${alias}  expected_alarms=@{EMPTY}  ignored_alarms=${ignored_alarms_full}
    ...  critical_alarms=${test_alarms_list['${alias.upper()}_CRITICAL_ALARMS']}
    ...  ELSE  Run Keywords
    ...  Ensure that link break is recovered without radio reset  ${alias}
    ...  AND  Get and Check Alarms SOAM  alias=${alias}  expected_alarms=@{EMPTY}  ignored_alarms=${ignored_alarms_full}
    ...  critical_alarms=${test_alarms_list['${alias.upper()}_CRITICAL_ALARMS_10']}

    Log  BTS ${alias} alarms, as expected! No unnexpected alarms found!  console=True

Ensure that link break is recovered without radio reset
    [Arguments]  ${alias}

    ${unnexpected_fid_10_status}=  Run Keyword And Return Status  Assert Alarm Active  faultId=10  timeout=30  connection=${alias}
    Run Keyword If  ${unnexpected_fid_10_status}  Run Keywords
    ...  Log  Unnexpected "No connection to Unit (10)" alarm present on BTS ${alias}!  level=ERROR
    ...  AND  Fail  Unnexpected "No connection to Unit (10)" alarm present on BTS ${alias}!

Check alarms after link break
    [Arguments]  ${link_break_type}  ${alias}

    ${ignored_alarms_full}=  Combine Lists  ${test_alarms_list['${alias.upper()}_IGNORED_ALARMS']}
    ...  ${test_alarms_list['${alias.upper()}_IGNORED_ALARMS_4694']}

    Log  Check BTS ${alias} alarms after ${link_break_type} link break:  console=True
    Log  BTS ${alias} expected alarm number: 0  console=True
    Ensure that link break is recovered without radio reset  ${alias}
    Get and Check Alarms SOAM  alias=${alias}  expected_alarms=@{EMPTY}
    ...  ignored_alarms=${ignored_alarms_full}  critical_alarms=${test_alarms_list['${alias.upper()}_CRITICAL_ALARMS_10']}
    Log  BTS ${alias} found alarm number: 0, as expected!  console=True

Check both BTS states and alarms after link break
    [Arguments]  ${RMOD_sn}  ${alias}  ${peer_alias}

    ${CELL_state_enabled}=  Set Variable  operationalState=Enabled, blockingState=Unblocked

    Log  Check BTS ${alias} and BTS ${peer_alias} state and alarms after secondary link break on BTS ${alias}:  console=True

    Log  Check BTS ${alias} and ${peer_alias} alarms:  console=True
    Get and Check Alarms SOAM  alias=${alias}  expected_alarms=@{EMPTY}  ignored_alarms=${test_alarms_list['${alias.upper()}_IGNORED_ALARMS']}
    ...  critical_alarms=${test_alarms_list['${alias.upper()}_CRITICAL_ALARMS']}
    Log  BTS ${alias} site - expected, ignored and critical alarms checked  console=True
    Get and Check Alarms SOAM  alias=${peer_alias}  expected_alarms=@{EMPTY}
    ...  ignored_alarms=${test_alarms_list['${peer_alias.upper()}_IGNORED_ALARMS']}
    ...  critical_alarms=${test_alarms_list['${peer_alias.upper()}_CRITICAL_ALARMS']}
    Log  BTS ${peer_alias} site - expected, ignored and critical alarms checked  console=True

    Log  Check BTS ${alias} and BTS ${peer_alias} shared RMOD with SN ${RMOD_sn} state:  console=True
    Check RMOD state  ${RMOD_sn}  ${alias}
    Check RMOD state  ${RMOD_sn}  ${peer_alias}

    Log  Check BTS ${alias} and BTS ${peer_alias} cells state:  console=True
    Check cells availability status online  ${alias}  60
    Log  All BTS ${alias} cell(s) status:\n - ${CELL_state_enabled}  console=True
    Check cells availability status online  ${peer_alias}  60
    Log  All BTS ${peer_alias} cell(s) status:\n - ${CELL_state_enabled}  console=True

Check RMOD state
    [Arguments]  ${RMOD_sn}  ${alias}

    ${RMOD_state_enabled_check}=  Set Variable  operationalState=${Enabled_}, administrativeState=${Unlocked_}
    ${RMOD_state_enabled}=  Set Variable  operationalState=Enabled, administrativeState=Unlocked

    ${RMOD_id}=  Get From Dictionary  ${${alias}_module_SN_ID_dict}  ${RMOD_sn}
    Assert  RMOD  ${RMOD_id}  ${RMOD_state_enabled_check}  timeout=60  alias=${alias}
    Log  BTS ${alias} shared RMOD with SN ${RMOD_sn} status: ${RMOD_state_enabled}  console=True

Set Primary Link on BTS
    [Arguments]  ${RM_sn}  ${alias}

    ${RM_sn}=  Create List  ${RM_sn}
    Log  ===== Setting primary link on BTS ${alias} for RMOD with SN ${RM_sn} =====  console=True
    Set Primary Link status based on linkModeSynchronization by LANE lock unlock procedure  module_type=RMOD  alias=${alias}
    ...  wait_for_Primary_Link_set=${SET_PRIMARY_LINK_TIME}  module_SN_list=${RM_sn}

Check BTS alarms from IMS
    [Arguments]  ${alias}  ${fault_id}

    Log  Check BTS ${alias} RD faults from IMS  console=True
    ${link_break_type}=  Set Variable If  '${fault_id}'=='4760'  Long  '${fault_id}'=='4721'   Short
    Log  BTS ${alias} "Fronthaul ${link_break_type} Link Break (${fault_id})" RD fault, expected number: 1  console=True
    Get and check detailed RD Fault from IMS  alias=${alias}  start_timestamp=${date_timestamp_start_link_break_UTC}
    ...  expected_rd_faults=${test_alarms_list['${alias.upper()}_EXPECTED_RD_FAULT_${fault_id}']}
    Log  BTS ${alias} "Fronthaul ${link_break_type} Link Break (${fault_id})", RD fault found number: 1, as expected!  console=True

GET event epoch time
    ${epoch_time}=  OperatingSystem.Run    date +%s
    [Return]  ${epoch_time}

Convert PM duration to seconds
    [Arguments]  ${pm_duration}

    ${pm_duration_value}=  Fetch From Left  ${pm_duration}  min
    ${pm_duration_value}=  Strip String  ${pm_duration_value}
    ${pm_duration_value_int}=  Convert To Integer  ${pm_duration_value}
    ${pm_duration_value_seconds}=  Evaluate  ${pm_duration_value_int}*60
    [Return]  ${pm_duration_value_seconds}

Check initial mt param
    [Arguments]  ${alias}  ${mt_param}

    ${scf_path}=  Admin Collect scf.xml with timestamp TAF  alias=${alias}
    ${dn_list}=  Get All Dist Names By Pattern from SCF  pattern=/PMMNL-[\\d]+$  scf_path=${scf_path}  alias=${alias}
    ${BTS_SCF_dn}=  Get From List  ${dn_list}  0
    ${mt_param_value}=  Check Parameter value from SCF  item_dist_name=${BTS_SCF_dn}
	...  parameter_to_check=${mt_param}  scf_path=${scf_path}
    Set Test variable  ${${alias}_${mt_param}_initial}  ${mt_param_value}
    Run Keyword If  '${mt_param_value}' == '5min'  Run Keywords
    ...  Log  ${mt_param}_value already set to ${mt_param_value}. No action needed  console=True
    ...  AND  Set Test Variable  ${${alias}_${mt_param}}  ${mt_param_value}
    ...  ELSE  Run Keywords
    ...  Log  Performing Parameter Recommissioning on BTS ${alias} parameter ${mt_param} to 5 min  console=True
    ...  AND  coam.Perform Parameter Recommissioning  dist_name=${BTS_SCF_dn}  parameter=${mt_param}  operation=update
    ...  value=5min  skip_parameter_relation_errors=False  should_activate=True  connection=${alias}
    ...  AND  Log  Waiting 5 min in for the PM period change to be taken into account  console=True
    ...  AND  Sleep  300s
    ...  AND  Set Test Variable  ${${alias}_${mt_param}}  5min
    ${mt_param_seconds}=  Convert PM duration to seconds  ${${alias}_${mt_param}}
    Set Test Variable  ${${alias}_${mt_param}_seconds}  ${mt_param_seconds}
    Log  BTS ${alias} PM duration in seconds: ${${alias}_${mt_param}_seconds}  console=True


Recover initial settings for feature CB007447
    [Arguments]  ${alias}

    Log  ==============================================================  console=True
    Log  Recover initial settings for feature CB007447 on BTS ${alias}  console=True
    Log  ==============================================================  console=True

    Set feature CB007447 on BTS  ${${alias}_actCpriLinkRecovery_initial}  ${${alias}_actSyncLinkSwitchover_initial}
    ...  ${${alias}_cpriSyncBreakTime_initial}  ${${alias}_stickToSyncSourcePeriod_initial}  ${alias}

Recover initial mt param
    [Arguments]  ${alias}  ${mt_param}

    ${scf_path}=  Admin Collect scf.xml with timestamp TAF  alias=${alias}
    ${dn_list}=  Get All Dist Names By Pattern from SCF  pattern=/PMMNL-[\\d]+$  scf_path=${scf_path}  alias=${alias}
    ${BTS_SCF_dn}=  Get From List  ${dn_list}  0
    ${mt_param_value}=  Check Parameter value from SCF  item_dist_name=${BTS_SCF_dn}
	...  parameter_to_check=${mt_param}  scf_path=${scf_path}
    Run Keyword If  '${mt_param_value}' == '${${alias}_${mt_param}_initial}'  Run Keywords
    ...  Log  Parameter Recommissioning ${mt_param} not needed.  console=True
    ...  AND  Return From Keyword
    Log  Recovering initial value of ${mt_param} on BTS ${alias}: ${${alias}_${mt_param}_initial}  console=True
    coam.Perform Parameter Recommissioning  dist_name=${BTS_SCF_dn}  parameter=${mt_param}  operation=update
    ...  value=${${alias}_${mt_param}_initial}  skip_parameter_relation_errors=False  should_activate=True  connection=${alias}

Mid Test Snapshot collection
    [Arguments]  ${alias}  ${reason}
    Log  Mid Test Snapshot collection for ${reason} problem found on BTS ${alias}  console=True
    ${timestamp}=  Get Current Date  result_format=%Y-%m-%d_%H:%M:%S
    ${path}=  Set Variable  ${Test Results Dir}/Snapshot
    Log  Snapshot file collection on BTS ${alias} started  console=True
    ${folder_path}  ${Snapshot_filename}=  Snapshot collection on demand SOAM  ${alias}  ${path}/${timestamp}_BTS_${alias}_${reason}
    Log  Snapshot file collected: ${folder_path}/${Snapshot_filename}  console=True
    Log  Wait static time of ${DELAY_BETWEEN_SNAPSHOTS} seconds between Snapshot collections  console=True
    Sleep  ${DELAY_BETWEEN_SNAPSHOTS}s

Check TC Verdict
    Run Keyword If  '${PM_Counters_Check}'!='True'  Return From Keyword
    Run Keyword If  '${TC_verdict_counters}' == 'FAIL'
    ...  Fail  At least one PM counter check was failed during TC execution!

Particular Teardown
    FOR  ${alias}  IN  @{alias_list}
        Recover initial settings for feature CB007447  ${alias}
    END
    Run Keyword If  '${PM_Counters_Check}'!='True'  Run Keywords
    ...  Check all BTS cells availability status online
    ...  AND  Return From Keyword
    FOR  ${alias}  IN  @{alias_list}
        Recover initial mt param  ${alias}  mtSbtsSfpBbmodLane
        Recover initial mt param  ${alias}  mtSbtsSfpSmodLane
    END
    Check all BTS cells availability status online

TC Setup
    ${tech_preset_list}=  Create List  SBTS  SBTS
    Common Test Setup  preset_techs=${tech_preset_list}  common_sbts=${TRUE}  infomodelSetup=${FALSE}  newAlarmsFormat=${TRUE}

TC Teardown
    Common Test Teardown
