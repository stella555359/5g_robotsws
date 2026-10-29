*** Settings ***
Documentation    TC__SBTS_SBTS__STATE__BBMOD_RMOD_Secondary_Link_Break_CB013082
Variables    tc_variables/sbts_sbts__state__bbmod_rmod_secondary_link_break_cb013082.py
Resource    ../../resources/rfs_frame_rfs_soam_taf.robot

*** Variables ***
${REPEAT_COUNTER}                      3   # Number of link break operations, default value 3
${SET_PRIMARY_LINK_TIME}             720   # Maximum time in seconds to wait for Primary Link set on ${BTS_PRIMARY_LINK}, default value: 720
${SHARED_RMOD_SERIAL_NUMBER_LIST}    ALL   # Shared RM serial number list on which link break will be performed. Possible values: ALL (operation
                                           # will be performed on all shared RM) or list of selected shared RM serial number separated by comma.
                                           # By default: ALL
${BTS_SCF_VALIDATION}                True  # Validate BTS SCF after activate feature CB013082. Possible values: True or False; by default: True
${RTWP_CHECK}                        True  # RTWP check during test steps, after link break. Possible values: True or False; by default: True
${LONG_FIBER_PORTS}                        # Calient ports where long fiber is connected. ex: 5.4.7-5.4.8

*** Keywords ***
TC__SBTS_SBTS__STATE__BBMOD_RMOD_Secondary_Link_Break_CB013082
    [Documentation]
    ...  [CASE LINK]: https://jiradc.ext.net.nokia.com/browse/TAT-27549
    ...
    ...  *****************
    ...  Basic information
    ...  *****************
    ...  SBTS-SBTS test case for SBTS BBMOD RMOD Secondary Link Break - x times sequence.
    ...
    ...  The main steps performed for the test are:
    ...
    ...  - check initial state and alarms for both BTS
    ...  - get both BTS info for configured items: BTS role (primary/secondary controller per BTS), shared RM info and cells info
    ...  - check feature CB013082 status on both BTS and activate it if needed; BTS SCF validation is performed after feature activation on both
    ...    BTS if ${BTS_SCF_VALIDATION} is set on True
    ...  - perform secondary link break between BBMOD and shared RMOD as follows:
    ...     - get shared RMOD Secondary Link Info before link break operation
    ...     - perform BBMOD_RMOD secondary link break on BTS by switching to long fiber and checking states and alarms;
    ...       RTWP check is also performed after ended action if ${RTWP_CHECK} is set on True
    ...     - restore initial cross connection and check final states and alarms
    ...     - switch primary link on the BTS where secondary link break was performed
    ...     - perform BBMOD_RMOD secondary link break on peer BTS by switching to long fiber and checking states and alarms;
    ...       RTWP check is also performed after ended action if ${RTWP_CHECK} is set on True
    ...     - restore initial cross connection and check final states and alarms
    ...     - repeat for all shared RMODs
    ...  - check final state and alarms for both BTS
    ...
    ...  Pass criteria: Scenario works as expected, states and alarms are as expected
    ...  ***************************
    ...  History of changes for SOAM
    ...  ***************************
    ...  - 19.06.2024 - https://jiradc.ext.net.nokia.com/browse/TAT-27549 - [5G][CB013082] - P0 -New Automated Test Scenario
    ...  [RFS__RFS_Secondary_link_break_on_RUs_Supported_by_CB007447_while_feature_ CB013082_is_enabled_and_feature_CB007447_is_disabled]
    ...  - 29.07.2024 - https://jiradc.ext.net.nokia.com/browse/TAT-27837 - [5G] FID4742 is not calculated correct for CB007447 scripts when
    ...  using multiple RUs
    ...  - 05.09.2024 - https://jiradc.ext.net.nokia.com/browse/TAT-27963 - [5G] [Infomodel] Infomodel refactor KWs:
    ...  "Get linkModeConfiguration info dict" & "Get linkModeSynchronization info dict"

    Set Tags    CA-STATE    OWNER-oana.vacarescu@nokia.com@nokia.com    AUTHOR-anca.tatar@nokia.com    PHASE-QT    SW-SBTS24R3

    Step 1: Check initial both BTS state
    Step 2: Check initial both BTS alarms
    Step 3: Get both BTS info for configured items
    Step 4: Check and activate feature CB013082 on both BTS
    FOR  ${INDEX}  IN RANGE  1  ${REPEAT_COUNTER}+1
        Log  ==============================================================================  console=True
        Log  Start Cycle ${INDEX} of ${REPEAT_COUNTER}  console=True
        Log  ==============================================================================  console=True
        Step 5: Perform secondary link break between BBMOD and shared RMOD
        Step 6: Check final both BTS state
        Step 7: Check final both BTS alarms
        Step 8: Check final number and state of Cells and RMs
    END

    [Teardown]  Particular Teardown

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
        Get and Check Alarms SOAM  alias=${alias}  expected_alarms=@{EMPTY}  ignored_alarms=${${alias.upper()}_IGNORED_ALARMS}
        ...  critical_alarms=${${alias.upper()}_CRITICAL_ALARMS}
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

        Get BTS CELL list by RAT  ${alias}

        Get RMOD ID SN dict  ${alias}
        Get BBMOD ID SN dict  ${alias}
    END

    Run Keyword If  '${SHARED_RMOD_SERIAL_NUMBER_LIST}' != 'ALL'  Check shared RMOD SN list
    Log  =======================================================  console=True
    Log  Shared RMOD serial number list selected for link break action: ${shared_RMOD_sn_list}  console=True
    Log  =======================================================  console=True

Step ${index}: Check and activate feature CB013082 on both BTS
    [Documentation]
    ...  Check feature CB013082 status on both BTS and enable it if needed

    Log  Step ${index}: Check and activate feature CB013082 on both BTS  console=True

    Set Test Variable  ${Master_CB013082_check}  False
    Set Test Variable  ${Slave_CB013082_check}  False
    ${BTS1_FID4742_count}=  Set Variable  ${Master_BTS_secondary_controller_shared_RMOD_count}
    ${BTS2_FID4742_count}=  Set Variable  ${Slave_BTS_secondary_controller_shared_RMOD_count}
    ${BTS1_EXPECTED_ALARMS_4742}=  Prepare expected alarms list  ${MASTER_EXPECTED_ALARMS_4742}  ${BTS1_FID4742_count}
    ${BTS2_EXPECTED_ALARMS_4742}=  Prepare expected alarms list  ${SLAVE_EXPECTED_ALARMS_4742}  ${BTS2_FID4742_count}

    Check initial feature CB013082 status  Master
    Check initial feature CB013082 status  Slave

    ${condition}=  Create Long String  '${Master_actRecovFromSecondaryController_initial}' == 'false' or
    ...  '${Master_actCpriLinkRecovery_initial}' == 'true'

    Run Keyword If  not ${Master_CB013082_check}  Run Keywords
    ...  Log  Activating feature CB013082 on BTS Master!  console=True
    ...  AND  Set feature CB013082 on BTS  alias=Master
    ...  AND  Check final feature CB013082 status  Master
    ...  AND  Set Test Variable  ${Master_CB013082_check}  True

    Run Keyword If  ${condition}  Run Keywords
    ...  Check BTS alarms after activate CB013082 feature  Master  Master  ${BTS1_FID4742_count}  ${BTS1_EXPECTED_ALARMS_4742}
    ...  AND  Check BTS alarms after activate CB013082 feature  Slave  Master  ${BTS2_FID4742_count}  ${BTS2_EXPECTED_ALARMS_4742}

    Run Keyword If  not ${Slave_CB013082_check}  Run Keywords
    ...  Log  Activating feature CB013082 on BTS Slave!  console=True
    ...  AND  Set feature CB013082 on BTS  alias=Slave
    ...  AND  Check final feature CB013082 status  Slave
    ...  AND  Set Test Variable  ${Slave_CB013082_check}  True
    ...  AND  Check BTS alarms after activate CB013082 feature  Master  Slave  0
    ...  AND  Check BTS alarms after activate CB013082 feature  Slave  Slave  0

    Run Keyword If  ${BTS_SCF_VALIDATION}  Run Keywords
    ...  Check BTS SCF Validation On Demand  alias=Master
    ...  AND  Check BTS SCF Validation On Demand  alias=Slave

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

Get BTS CELL list by RAT
    [Arguments]  ${alias}
    ${NR_CELL_list}=  Get Ids For All  class_name=NRCEL  connection=${alias}
    ${LTE_CELL_list}=  Get Ids For All  class_name=LNCEL  connection=${alias}
    ${WCDMA_CELL_list}=  Get Ids For All  class_name=WNCEL  connection=${alias}
    ${GSM_CELL_list}=  Get Ids For All  class_name=GNCEL  connection=${alias}
    ${CELL_list}=  Combine Lists   ${NR_CELL_list}  ${LTE_CELL_list}  ${WCDMA_CELL_list}  ${GSM_CELL_list}
    Set Test Variable  ${${alias}_NR_CELL_list}  ${NR_CELL_list}
    Set Test Variable  ${${alias}_LTE_CELL_list}  ${LTE_CELL_list}
    Set Test Variable  ${${alias}_WCDMA_CELL_list}  ${WCDMA_CELL_list}
    Set Test Variable  ${${alias}_GSM_CELL_list}  ${GSM_CELL_list}
    Set Test Variable  ${${alias}_CELL_list}  ${CELL_list}

Get shared RMOD all cells from specific RAT
    [Arguments]  ${RMOD_sn}  ${alias}
    ${RMOD_id}=  Get From Dictionary  ${${alias}_RM_sn_id_dict}  ${RMOD_sn}
    ${CELL_RMOD_list}=  Get Cell Mapping By Module Id  module_id=${RMOD_id}  connection=${alias}
    ${NR_CELL_RMOD_list}=  Create List
    ${LTE_CELL_RMOD_list}=  Create List
    ${WCDMA_CELL_RMOD_list}=  Create List
    ${GSM_CELL_RMOD_list}=  Create List
    FOR  ${item}  IN  @{${alias}_CELL_list}
        Run Keyword If  '${item}' in ${CELL_RMOD_list} and '${item}' in ${${alias}_NR_CELL_list}  Append To List  ${NR_CELL_RMOD_list}  ${item}
        Run Keyword If  '${item}' in ${CELL_RMOD_list} and '${item}' in ${${alias}_LTE_CELL_list}  Append To List  ${LTE_CELL_RMOD_list}  ${item}
        Run Keyword If  '${item}' in ${CELL_RMOD_list} and '${item}' in ${${alias}_WCDMA_CELL_list}  Append To List  ${WCDMA_CELL_RMOD_list}  ${item}
        Run Keyword If  '${item}' in ${CELL_RMOD_list} and '${item}' in ${${alias}_GSM_CELL_list}  Append To List  ${GSM_CELL_RMOD_list}  ${item}
    END
    Sort List  ${NR_CELL_RMOD_list}
    Sort List  ${LTE_CELL_RMOD_list}
    Sort List  ${WCDMA_CELL_RMOD_list}
    Sort List  ${GSM_CELL_RMOD_list}
    ${CELL_RMOD_list}=  Combine Lists   ${NR_CELL_RMOD_list}  ${LTE_CELL_RMOD_list}  ${WCDMA_CELL_RMOD_list}  ${GSM_CELL_RMOD_list}
    Set Test Variable  ${${alias}_NR_CELL_RMOD_list}  ${NR_CELL_RMOD_list}
    Set Test Variable  ${${alias}_LTE_CELL_RMOD_list}  ${LTE_CELL_RMOD_list}
    Set Test Variable  ${${alias}_WCDMA_CELL_RMOD_list}  ${WCDMA_CELL_RMOD_list}
    Set Test Variable  ${${alias}_GSM_CELL_RMOD_list}  ${GSM_CELL_RMOD_list}
    Set Test Variable  ${${alias}_CELL_RMOD_list}  ${CELL_RMOD_list}
    Log  BTS ${alias} cells mapped on shared RMOD with SN ${RMOD_sn}:  console=True
    Run Keyword If  ${NR_CELL_RMOD_list}  Log  - NRCEL: ${NR_CELL_RMOD_list}  console=True
    Run Keyword If  ${LTE_CELL_RMOD_list}  Log  - LNCEL: ${LTE_CELL_RMOD_list}  console=True
    Run Keyword If  ${WCDMA_CELL_RMOD_list}  Log  - WNCEL: ${WCDMA_CELL_RMOD_list}  console=True
    Run Keyword If  ${GSM_CELL_RMOD_list}  Log  - GNCEL: ${GSM_CELL_RMOD_list}  console=True

Check initial feature CB013082 status
    [Arguments]  ${alias}

    Log  Check initial feature CB013082 status on BTS ${alias}:  console=True

    ${actForceUnitAutoReset_initial}  ${actRecovFromSecondaryController_initial}  ${actCpriLinkRecovery_initial}=
    ...  Get feature CB013082 info  ${alias}

    Log  Initial actForceUnitAutoReset parameter value: ${actForceUnitAutoReset_initial}  console=True
    Log  Initial actRecovFromSecondaryController parameter value: ${actRecovFromSecondaryController_initial}  console=True
    Log  Initial actCpriLinkRecovery parameter value: ${actCpriLinkRecovery_initial}  console=True

    Set Test Variable  ${${alias}_actForceUnitAutoReset_initial}  ${actForceUnitAutoReset_initial}
    Set Test Variable  ${${alias}_actRecovFromSecondaryController_initial}  ${actRecovFromSecondaryController_initial}
    Set Test Variable  ${${alias}_actCpriLinkRecovery_initial}  ${actCpriLinkRecovery_initial}

    ${condition}=  Create Long String  '${actForceUnitAutoReset_initial}' == 'true' and '${actRecovFromSecondaryController_initial}' == 'true' and
    ...  '${actCpriLinkRecovery_initial}' == 'false'

    Run Keyword If  ${condition}  Run Keywords
    ...  Log  Feature CB013082 already activated on BTS ${alias}, no action needed!  console=True
    ...  AND  Set Test Variable  ${${alias}_CB013082_check}  True
    ...  ELSE  Run Keywords  Log  Need to activate feature CB013082 on BTS ${alias}!  console=True
    ...  AND  Set Test Variable  ${${alias}_CB013082_check}  False

Check final feature CB013082 status
    [Arguments]  ${alias}

    Log  Check final feature CB013082 status on BTS ${alias}:  console=True

    ${actForceUnitAutoReset_final}  ${actRecovFromSecondaryController_final}  ${actCpriLinkRecovery_final}=  Get feature CB013082 info  ${alias}

    Run Keyword If  '${actForceUnitAutoReset_final}' == 'true'
    ...  Log  Final actForceUnitAutoReset parameter value: ${actForceUnitAutoReset_final}, as expected!  console=True
    ...  ELSE  Run Keywords
    ...  Log  Parameter actForceUnitAutoReset = ${actForceUnitAutoReset_final}, not properly commissioned!  level=ERROR
    ...  AND  Fail  Parameter actForceUnitAutoReset = ${actForceUnitAutoReset_final}, not properly commissioned!

    Run Keyword If  '${actRecovFromSecondaryController_final}' == 'true'
    ...  Log  Final actRecovFromSecondaryController parameter value: ${actRecovFromSecondaryController_final}, as expected!  console=True
    ...  ELSE  Run Keywords
    ...  Log  Parameter actRecovFromSecondaryController = ${actRecovFromSecondaryController_final}, not properly commissioned!  level=ERROR
    ...  AND  Fail  Parameter actRecovFromSecondaryController = ${actRecovFromSecondaryController_final}, not properly commissioned!

    Run Keyword If  '${actCpriLinkRecovery_final}' == 'false'
    ...  Log  Final actCpriLinkRecovery parameter value: ${actCpriLinkRecovery_final}, as expected!  console=True
    ...  ELSE  Run Keywords
    ...  Log  Parameter actCpriLinkRecovery = ${actCpriLinkRecovery}, not properly commissioned!  level=ERROR
    ...  AND  Fail  Parameter actCpriLinkRecovery = ${actCpriLinkRecovery}, not properly commissioned!

Check BTS alarms after activate CB013082 feature
    [Arguments]  ${alias}  ${BTS_feature_activation}  ${expected_alarms_count}  ${expected_alarms_list}=@{EMPTY}

    Log  Check BTS ${alias} alarms after activate CB013082 feature on BTS ${BTS_feature_activation}  console=True
    Log  BTS ${alias} "Configuration mismatch between peer BTSs (4742)" alarm, expected number: ${expected_alarms_count}  console=True
    Get and Check Alarms SOAM  alias=${alias}  expected_alarms=${expected_alarms_list}  ignored_alarms=${${alias.upper()}_IGNORED_ALARMS}
    ...  critical_alarms=${${alias.upper()}_CRITICAL_ALARMS}
    Log  BTS ${alias} "Configuration mismatch between peer BTSs (4742)" alarm, found number: ${expected_alarms_count}, as expected!  console=True
    Log  BTS ${alias} site - expected, ignored and critical alarms checked  console=True

Setup for Optical Switch
    Optical Switch Setup  switch_ip=${OPTICAL_SWITCH['IP']}  switch_username=${OPTICAL_SWITCH['USERNAME']}
    ...  switch_password=${OPTICAL_SWITCH['PASSWORD']}  port=${OPTICAL_SWITCH['PORT']}

Check alias of secondary link
    [Arguments]  ${RMOD_sn}

    FOR  ${alias}  IN  @{alias_list}
        Check secondary link between BBMOD and shared RMOD  ${RMOD_sn}  ${alias}
        Run Keyword If  ${${alias}_secondary_link_status}  Run Keywords
	    ...  Log  Secondary link is on RMOD_${RMOD_sn} from BTS ${alias}  console=True
	    ...  AND  Return From Keyword  ${alias}
    END

Check secondary link between BBMOD and shared RMOD
    [Arguments]  ${RMOD_sn}  ${alias}
    ${BBMOD_sn_list}=  Get Dictionary Keys  ${${alias}_BBMOD_SN_ID_dict}
    FOR  ${item}  IN  @{BBMOD_sn_list}
        ${BBMOD_sn}=  Set Variable  ${item}
        ${firstModule_connectorLabel_linkModeSynchronization_dict}  ${secondModule_connectorLabel_linkModeSynchronization_dict}
        ...  ${firstModule_connectorLabel_linkModeConfiguration_dict}  ${secondModule_connectorLabel_linkModeConfiguration_dict}
        ...  ${firstModule_secondModule_connectorLabel}
        ...  ${secondModule_firstModule_connectorLabel}=   Get linkModeSynchronization and linkModeConfiguration info dict
        ...  ${BBMOD_sn}  ${RMOD_sn}  ${alias}
        Set Test Variable  ${${alias}_${RMOD_sn}_${BBMOD_sn}_connectorLabel_linkModeConfiguration_dict}
        ...  ${secondModule_connectorLabel_linkModeConfiguration_dict}
        Set Test Variable  ${${alias}_${RMOD_sn}_${BBMOD_sn}_connectorLabel_linkModeSynchronization_dict}
        ...  ${secondModule_connectorLabel_linkModeSynchronization_dict}
        Set Test Variable  ${${alias}_${BBMOD_sn}_${RMOD_sn}_connectorLabel_linkModeConfiguration_dict}
        ...  ${firstModule_connectorLabel_linkModeConfiguration_dict}
        Set Test Variable  ${${alias}_${BBMOD_sn}_${RMOD_sn}_connectorLabel}  ${firstModule_secondModule_connectorLabel}
        Set Test Variable  ${${alias}_${RMOD_sn}_${BBMOD_sn}_connectorLabel}  ${secondModule_firstModule_connectorLabel}
    END
    FOR  ${item}  IN  @{BBMOD_sn_list}
        ${RMOD_connectorLabel_list}=  Get Dictionary Values  ${${alias}_${item}_${RMOD_sn}_connectorLabel}
        Continue For Loop If  not ${RMOD_connectorLabel_list}
        ${BBMOD_RMOD_secondary_link_dict}=  Get secondary link  ${item}  ${RMOD_sn}  ${RMOD_connectorLabel_list}  ${alias}
        Continue For Loop If  '${${alias}_secondary_link_status}' == 'False'
        Log  Secondary link between shared RMOD_${RMOD_sn} and BBMOD_${item} info from ${alias}  console=True
        ${shared_BBMOD_RMOD_secondary_link_keys}=  Get Dictionary Keys  ${BBMOD_RMOD_secondary_link_dict}
        ${shared_BBMOD_RMOD_secondary_link_values}=  Get Dictionary Values  ${BBMOD_RMOD_secondary_link_dict}
        ${BBMOD_connectorLabel}=  Set Variable  ${shared_BBMOD_RMOD_secondary_link_keys[0]}
        ${RMOD_connectorLabel}=  Set Variable  ${shared_BBMOD_RMOD_secondary_link_values[0]}
        Log  - BBMOD connectorLabel: ${BBMOD_connectorLabel} - shared RMOD connectorLabel: ${RMOD_connectorLabel}  console=True
        Set Test Variable  ${RMOD_connectorLabel}
        Set Test Variable  ${BBMOD_connectorLabel}
        Set Test Variable  ${BBMOD_sn}  ${item}
        Exit For Loop
    END

Get secondary link
    [Arguments]  ${BBMOD_sn}  ${RMOD_sn}  ${RMOD_connectorLabel_list}  ${alias}
    ${BBMOD_RMOD_secondary_link_dict}=  Create Dictionary
    FOR  ${item}  IN  @{RMOD_connectorLabel_list}
        ${linkModeConfiguration}=  Get From Dictionary  ${${alias}_${RMOD_sn}_${BBMOD_sn}_connectorLabel_linkModeConfiguration_dict}  ${item}
        ${linkModeSynchronization}=  Get From Dictionary  ${${alias}_${RMOD_sn}_${BBMOD_sn}_connectorLabel_linkModeSynchronization_dict}  ${item}
        ${BBMOD_connectorLabel}=  Get From Dictionary  ${${alias}_${RMOD_sn}_${BBMOD_sn}_connectorLabel}  ${item}
        Run Keyword If  '${linkModeConfiguration}' == 'True' and '${linkModeSynchronization}' == 'False'  Run Keywords
        ...  Set Test Variable  ${${alias}_secondary_link_status}  True
        ...  AND  Exit For Loop
        ...  ELSE  Set Test Variable  ${${alias}_secondary_link_status}  False
    END
    Run Keyword If  ${${alias}_secondary_link_status}  Set To Dictionary  ${BBMOD_RMOD_secondary_link_dict}  ${BBMOD_connectorLabel}  ${item}
    [Return]  ${BBMOD_RMOD_secondary_link_dict}

Secondary Link Break on BTS
    [Arguments]  ${RMOD_sn}  ${alias}  ${peer_alias}

    Get shared RMOD all cells from specific RAT  ${RMOD_sn}  ${alias}
    Perform secondary link break by switching to long fiber  ${RMOD_sn}  ${alias}
    Check cells state and alarms after link break  ${RMOD_sn}  ${alias}
    Check final both BTS states and alarms  ${RMOD_sn}  ${alias}  ${peer_alias}
    Run Keyword If  ${RTWP_CHECK}  Launch RTWP Check on Demand
    Restore initial cross connection
    Check cells state and alarms after link restore  ${RMOD_sn}  ${alias}
    Check final both BTS states and alarms  ${RMOD_sn}  ${alias}  ${peer_alias}

Perform secondary link break by switching to long fiber
    [Arguments]  ${RMOD_sn}  ${alias}

    Log Long String  ***** Performing secondary link break between BBMOD_${BBMOD_sn} port ${BBMOD_connectorLabel}
    ...  and shared RMOD_${RMOD_sn} port ${RMOD_connectorLabel} on BTS ${alias} *****  console=True
    Log  The interrupted optical fiber will be replaced with a long fiber that uses calient ports ${LONG_FIBER_PORTS}  console=True

    Check Optical Switch definition info  BBMOD  ${BBMOD_sn}  ${BBMOD_connectorLabel}
    Check Optical Switch definition info  RMOD  ${RMOD_sn}  ${RMOD_connectorLabel}

    ${cross_connection_BBMOD_RMOD}=  Get Cross Connection Id
    ...  ${BBMOD_${BBMOD_sn}_${BBMOD_connectorLabel}_cross_connection}
    ...  ${RMOD_${RMOD_sn}_${RMOD_connectorLabel}_cross_connection}

    Remove Cross Connection By Id  connection=${LONG_FIBER_PORTS}

    Set Test Variable  ${initial_cross_connection_BBMOD_RMOD}  ${cross_connection_BBMOD_RMOD}

    Perform link break by setting multiple cross connections  ${cross_connection_BBMOD_RMOD}  ${LONG_FIBER_PORTS}

    Set Test Variable  ${RESTORE_CONNECTION}  False

Perform link break by setting multiple cross connections
    [Arguments]  ${cross_connection_BBMOD_RMOD}  ${cross_connection_long_fiber}

    ${BBMOD_port}  ${RMOD_port}=  Split String  ${cross_connection_BBMOD_RMOD}  -
    ${long_fiber_first_port}  ${long_fiber_second_port}=  Split String  ${cross_connection_long_fiber}  -
    ${BBMOD_long_fiber_first_port}=  Catenate  SEPARATOR=-  ${BBMOD_port}  ${long_fiber_first_port}
    ${long_fiber_second_port_RMOD}=  Catenate  SEPARATOR=-  ${long_fiber_second_port}  ${RMOD_port}
    ${cross_connection_list}=  Create List  ${BBMOD_long_fiber_first_port}  ${long_fiber_second_port_RMOD}

    Optical Switch Setup  switch_ip=${OPTICAL_SWITCH['IP']}  switch_password=${OPTICAL_SWITCH['PASSWORD']}  switch_username=tl1user  port=22
    ...  alias=TL1_alias  protocol=tl1

    ${date_timestamp_alarm_ims2_start_UTC}=  Get Current Date  time_zone=UTC
    Set Test Variable  ${date_timestamp_alarm_ims2_start_UTC}

    Log  Perform link break on connection_id: ${cross_connection_BBMOD_RMOD}  console=True
    ${link_break_status}=  Run Keyword And Return Status  Create Multiple Cross Connections  connection_list=${cross_connection_list}
    ...  optical_switch_device=TL1_alias
    Run Keyword If  ${link_break_status}
    ...  Log  Link break status is: ${link_break_status}  console=True
    ...  ELSE  Run Keywords
    ...  Log  Link break status is: ${link_break_status}  console=True
    ...  AND  Fail  Link break failed!
    Log  New cross connections are: ${BBMOD_long_fiber_first_port} & ${long_fiber_second_port_RMOD}, as expected!  console=True

    [Teardown]  Teardown Optical Switch  alias=TL1_alias

Check cells state and alarms after link break
    [Arguments]  ${RMOD_sn}  ${alias}

    ${ALARM_4685_count}=  Get Length  ${${alias}_CELL_RMOD_list}
    ${EXPECTED_ALARMS_4685_full}=  Prepare expected alarms list  ${${alias.upper()}_EXPECTED_ALARMS_4685}  ${ALARM_4685_count}
    ${ignored_alarms_full}=  Combine Lists  ${${alias.upper()}_IGNORED_ALARMS}  ${${alias.upper()}_IGNORED_ALARMS_1815}
    ...  ${${alias.upper()}_IGNORED_ALARMS_DSS}


    Run Keyword If  ${CNI_127210_ENABLED}
    ...  Run Keywords
    ...  Log  Check unexpected BTS ${alias} alarms after link break:  console=True
    ...  AND  Get and Check Alarms SOAM  alias=${alias}  poll_interval=5 sec  expected_alarms=@{EMPTY}
    ...  ignored_alarms=${ignored_alarms_full}  critical_alarms=${${alias.upper()}_CRITICAL_ALARMS_10}
    ...  AND  Log  BTS ${alias} alarms, as expected!  console=True
    ...  ELSE
    ...  Run Keywords
    ...  Log  BTS ${alias} "Runtime Fibre Delay Change Out Of Tolerance (4685)" alarm, expected number: ${ALARM_4685_count}  console=True
    ...  AND  Get and Check Alarms SOAM  alias=${alias}  poll_interval=5 sec
    ...  expected_alarms=${EXPECTED_ALARMS_4685_full}  ignored_alarms=${ignored_alarms_full}
    ...  critical_alarms=${${alias.upper()}_CRITICAL_ALARMS_10}
    ...  AND  Log  BTS ${alias} "Runtime Fibre Delay Change Out Of Tolerance (4685)" alarm, found number: ${ALARM_4685_count}, as expected!
    ...  console=True

    Log  Check BTS ${alias} cells status mapped on shared RMOD with SN ${RMOD_sn}:  console=True
    Check cells state mapped on shared RMOD  ${RMOD_sn}  ${alias}

    Run Keyword If  ${CNI_127210_ENABLED}
    ...  Run Keywords
    ...  Log  BTS ${alias} "Runtime Fibre Delay Change Out Of Tolerance (4685)" alarm, expected number: ${ALARM_4685_count}  console=True
    ...  AND  Get and check detailed IMS2 Alarms SOAM  alias=${alias}  expected_alarms=${EXPECTED_ALARMS_4685_full}
    ...  start_timestamp=${date_timestamp_alarm_ims2_start_UTC}
    ...  AND  Log  BTS ${alias} "Runtime Fibre Delay Change Out Of Tolerance (4685)" alarm, found number: ${ALARM_4685_count}, as expected!
    ...  console=True

Check cells state and alarms after link restore
    [Arguments]  ${RMOD_sn}  ${alias}

    ${ALARM_4685_count}=  Get Length  ${${alias}_CELL_RMOD_list}
    ${EXPECTED_ALARMS_4685_full}=  Prepare expected alarms list  ${${alias.upper()}_EXPECTED_ALARMS_4685}  ${ALARM_4685_count}
    ${ignored_alarms_full}=  Combine Lists  ${${alias.upper()}_IGNORED_ALARMS}  ${${alias.upper()}_IGNORED_ALARMS_1815}
    ...  ${${alias.upper()}_IGNORED_ALARMS_DSS}

    Run Keyword If  ${CNI_127210_ENABLED}
    ...  Run Keywords
    ...  Log  During Link restore, allow for unexpected BTS ${alias} alarms after link break:  console=True
    ...  AND  Run Keyword And Return Status  Get and Check Alarms SOAM  alias=${alias}  poll_interval=5 sec  expected_alarms=@{EMPTY}
    ...  ignored_alarms=${ignored_alarms_full}  critical_alarms=${${alias.upper()}_CRITICAL_ALARMS_10}
    ...  AND  Log  BTS ${alias} alarms wait finished  console=True
    ...  ELSE
    ...  Run Keywords
    ...  Log  During link restore, allow on BTS ${alias} for "Runtime Fibre Delay Change Out Of Tolerance (4685)" alarm  console=True
    ...  AND  Run Keyword And Return Status  Get and Check Alarms SOAM  alias=${alias}  poll_interval=5 sec
    ...  expected_alarms=${EXPECTED_ALARMS_4685_full}  ignored_alarms=${ignored_alarms_full}
    ...  critical_alarms=${${alias.upper()}_CRITICAL_ALARMS_10}
    ...  AND  Log  BTS ${alias} alarms wait finished  console=True

    Log  Check BTS ${alias} cells status mapped on shared RMOD with SN ${RMOD_sn}:  console=True
    Check cells state mapped on shared RMOD  ${RMOD_sn}  ${alias}

    Run Keyword If  ${CNI_127210_ENABLED}
    ...  Run Keywords
    ...  Log  During link restore, allow on BTS ${alias} for "Runtime Fibre Delay Change Out Of Tolerance (4685)" alarm  console=True
    ...  AND  Run Keyword and Return Status  Get and check detailed IMS2 Alarms SOAM  alias=${alias}  expected_alarms=${EXPECTED_ALARMS_4685_full}
    ...  start_timestamp=${date_timestamp_alarm_ims2_start_UTC}
    ...  AND  Log  BTS ${alias} alarms wait finished  console=True

Check cells state mapped on shared RMOD
    [Arguments]  ${RMOD_sn}  ${alias}

    ${CELL_state_disabled_check}=  Set Variable  operationalState=${Disabled_}, availabilityStatus=${Failed_Offline_}, blockingState=${Unblocked_}
    ${CELL_state_disabled}=  Set Variable  operationalState=Disabled, availabilityStatus=Failed|Offline, blockingState=Unblocked

   Run Keyword If  ${${alias}_NR_CELL_RMOD_list}
    ...  Check Cell State  NRCEL  ${${alias}_NR_CELL_RMOD_list}  ${CELL_state_disabled_check}  ${CELL_state_disabled}  30  ${alias}
    Run Keyword If  ${${alias}_LTE_CELL_RMOD_list}
    ...  Check Cell State  LNCEL  ${${alias}_LTE_CELL_RMOD_list}  ${CELL_state_disabled_check}  ${CELL_state_disabled}  30  ${alias}
    Run Keyword If  ${${alias}_WCDMA_CELL_RMOD_list}
    ...  Check Cell State  WNCEL  ${${alias}_WCDMA_CELL_RMOD_list}  ${CELL_state_disabled_check}  ${CELL_state_disabled}  30  ${alias}
    Run Keyword If  ${${alias}_GSM_CELL_RMOD_list}
    ...  Check Cell State  GNCEL  ${${alias}_GSM_CELL_RMOD_list}  ${CELL_state_disabled_check}  ${CELL_state_disabled}  30  ${alias}
    Log  All BTS ${alias} cells mapped on shared RMOD with SN ${RMOD_sn}:\n - ${CELL_state_disabled}  console=True

Check Cell State
    [Arguments]   ${cell_class_name}  ${cell_list}  ${cell_state_check}  ${cell_state}  ${timeout}  ${alias}

    FOR  ${item}  IN  @{cell_list}
        Assert  class_name=${cell_class_name}  id=${item}  parameters=${cell_state_check}  timeout=${timeout}  connection=${alias}
        Log  BTS ${alias} ${cell_class_name} ${item} status:\n - ${cell_state}  console=True
    END

Check final both BTS states and alarms
    [Arguments]  ${RMOD_sn}  ${alias}  ${peer_alias}

    ${CELL_state_enabled}=  Set Variable  operationalState=Enabled, blockingState=Unblocked
    ${bts_ignored_alarms_full}=  Combine Lists  ${${alias.upper()}_IGNORED_ALARMS}  ${${alias.upper()}_IGNORED_ALARMS_DSS}
    ${peer_bts_ignored_alarms_full}=  Combine Lists  ${${peer_alias.upper()}_IGNORED_ALARMS}  ${${peer_alias.upper()}_IGNORED_ALARMS_DSS}

    Log  Check BTS ${alias} and BTS ${peer_alias} state and alarms:  console=True

    Log  Check BTS ${alias} and BTS ${peer_alias} shared RMOD with SN ${RMOD_sn} state:  console=True
    Check RMOD state  ${RMOD_sn}  ${alias}
    Check RMOD state  ${RMOD_sn}  ${peer_alias}

    Log  Check BTS ${alias} and BTS ${peer_alias} cells state:  console=True
    Check cells availability status online  ${alias}  60
    Log  All BTS ${alias} cell(s) status:\n - ${CELL_state_enabled}  console=True
    Check cells availability status online  ${peer_alias}  60
    Log  All BTS ${peer_alias} cell(s) status:\n - ${CELL_state_enabled}  console=True

    Log  Check alarm "Runtime Fibre Delay Change Out Of Tolerance (4685)" is cleared  console=True

    ${fid_4685_status}=  Run Keyword If  ${CNI_127210_ENABLED}
    ...  Log  CNI 127210 is active. Skipping check of alarm cleared  console=True
    ...  ELSE  Run Keywords
    ...  Assert Alarm Inactive  faultId=4685  timeout=30  connection=${alias}
    ...  AND  Log  Alarm "Runtime Fibre Delay Change Out Of Tolerance (4685)" is cleared  console=True

    Get and Check Alarms SOAM  alias=${alias}  expected_alarms=@{EMPTY}  ignored_alarms=${bts_ignored_alarms_full}
    ...  critical_alarms=${${alias.upper()}_CRITICAL_ALARMS_10}
    Log  BTS ${alias} site - expected, ignored and critical alarms checked  console=True
    Get and Check Alarms SOAM  alias=${peer_alias}  expected_alarms=@{EMPTY}  ignored_alarms=${peer_bts_ignored_alarms_full}
    ...  critical_alarms=${${peer_alias.upper()}_CRITICAL_ALARMS_10}
    Log  BTS ${peer_alias} site - expected, ignored and critical alarms checked  console=True

Check RMOD state
    [Arguments]  ${RMOD_sn}  ${alias}

    ${RMOD_state_enabled_check}=  Set Variable  operationalState=${Enabled_}, administrativeState=${Unlocked_}
    ${RMOD_state_enabled}=  Set Variable  operationalState=Enabled, administrativeState=Unlocked

    ${RMOD_id}=  Get From Dictionary  ${${alias}_module_SN_ID_dict}  ${RMOD_sn}
    Assert  RMOD  ${RMOD_id}  ${RMOD_state_enabled_check}  timeout=60  alias=${alias}
    Log  BTS ${alias} shared RMOD with SN ${RMOD_sn} status: ${RMOD_state_enabled}  console=True

Restore initial cross connection

    ${initial_cross_connection_BBMOD_RMOD}=  Create List  ${initial_cross_connection_BBMOD_RMOD}

    Optical Switch Setup  switch_ip=${OPTICAL_SWITCH['IP']}  switch_password=${OPTICAL_SWITCH['PASSWORD']}  switch_username=tl1user  port=22
    ...  alias=TL1_alias  protocol=tl1

    Log  Restore initial cross connection ${initial_cross_connection_BBMOD_RMOD}  console=True
    ${restore_connection_status}=  Run Keyword And Return Status  Create Multiple Cross Connections
    ...  connection_list=${initial_cross_connection_BBMOD_RMOD}  optical_switch_device=TL1_alias

    ${date_timestamp_alarm_ims2_start_UTC}=  Get Current Date  time_zone=UTC
    Set Test Variable  ${date_timestamp_alarm_ims2_start_UTC}

    Run Keyword If  ${restore_connection_status}
    ...  Log  Restore initial cross connection status is: ${restore_connection_status}  console=True
    ...  ELSE  Run Keywords
    ...  Log  Restore initial cross connection status is: ${restore_connection_status}  console=True
    ...  AND  Fail  Restore initial cross connection failed!

    Set Test Variable  ${RESTORE_CONNECTION}  True

    [Teardown]  Teardown Optical Switch  alias=TL1_alias

Set Primary Link on BTS
    [Arguments]  ${RM_sn}  ${alias}

    ${RM_sn}=  Create List  ${RM_sn}
    Log  ===== Setting primary link on BTS ${alias} for RMOD with SN ${RM_sn} =====  console=True
    Set Primary Link status based on linkModeSynchronization by LANE lock unlock procedure  module_type=RMOD  alias=${alias}
    ...  wait_for_Primary_Link_set=${SET_PRIMARY_LINK_TIME}  module_SN_list=${RM_sn}

Recover initial settings for feature CB013082
    [Arguments]  ${alias}

    Log  ==============================================================  console=True
    Log  Recover initial settings for feature CB013082 on BTS ${alias}  console=True
    Log  ==============================================================  console=True

    Set feature CB013082 on BTS  ${${alias}_actForceUnitAutoReset_initial}  ${${alias}_actRecovFromSecondaryController_initial}
    ...  ${${alias}_actCpriLinkRecovery_initial}  ${alias}

Particular Teardown
    Run Keyword If  not ${RESTORE_CONNECTION}  Restore initial cross connection
    FOR  ${alias}  IN  @{alias_list}
        Recover initial settings for feature CB013082  ${alias}
    END
    Check all BTS cells availability status online

TC Setup
    ${tech_preset_list}=  Create List  SBTS  SBTS
    Common Test Setup  preset_techs=${tech_preset_list}  common_sbts=${TRUE}  infomodelSetup=${FALSE}

TC Teardown
    Common Test Teardown