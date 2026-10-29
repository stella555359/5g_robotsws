*** Settings ***
Documentation    TC__SBTS_SBTS__STATE__BBMOD_RMOD_Primary_Link_Break_Reset_Recovery
Variables    tc_variables/sbts_sbts__state__bbmod_rmod_primary_link_break_reset_recovery.py
Resource    ../../resources/rfs_frame_rfs_soam_taf.robot

*** Variables ***
${REPEAT_COUNTER}  3      # Number of link break operations, default value 3
                          # In order to generate link breaks on each link of each RMOD, suggested to run 6 times
${Link_break_duration}    # Duration value should be in interval 50 .. 3000ms
                          # Recomanded values 1200, 2300
                          # Due to optical switch tolerance, avoid using interval (1500ms, 1800ms)

*** Keywords ***
TC__SBTS_SBTS__STATE__BBMOD_RMOD_Primary_Link_Break_Reset_Recovery
    [Documentation]
    ...  [CASE LINK]: https://jiradc.ext.net.nokia.com/browse/TAT-25179
    ...
    ...  *****************
    ...  Basic information
    ...  *****************
    ...  SBTS-SBTS test case for BTS1/BTS2 BBMOD_RMOD Primary Link Break Reset Recovery, - x times sequence.
    ...
    ...  The main steps performed for the test are:
    ...
    ...  - check initial state and alarms for both BTS
    ...  - get BTS primary controller and secondary controller role
    ...  - check feature CB007437 status on both BTS
    ...  - activate feture CB007437 on both BTS, if not activated
    ...  - check intermediate state and alarms for both BTS after activate feature CB007437
    ...  - get shared RMOD Primary Link Info before link break operation
    ...  - perform BBMOD_RMOD Primary Link Break reset on BTS1 checking states and alarms
    ...  - check final state and alarms for both BTS
    ...
    ...  Pass criteria: Scenario works as expected, states and alarms are as expected
    ...
    ...  ***************************
    ...  History of changes for SOAM
    ...  ***************************
    ...
    ...  - 18.07.2023 - https://jiradc.ext.net.nokia.com/browse/TAT-25149 - [Legacy][CB007437] New Automated Test Scenario
    ...  [LL]__STATE_PLBreak_Reset_Recovery
    ...  - 31.10.2023 - https://jiradc.ext.net.nokia.com/browse/TAT-26009 - [5G][CB007437] [NR_NR]__STATE_PLBreak_Reset_Recovery
    ...  - 23.09.2024 - https://jiradc.ext.net.nokia.com/browse/TAT-28023 - [5G] [Infomodel] In other Link Break TCs: Infomodel refactor KWs:
    ...  "Get linkModeSynchronization info dict" - after TAT-27963
    ...
    ...  *******************
    ...  Test case flowchart
    ...  *******************
    ...  .. image:: https://gitlabe1.ext.net.nokia.com/panda-docs/hran_doc/-/blob/master/testsuite/RFS_SOAM/
    ...  TAT-25179_LL__STATE__BBMOD_RMOD_Secondary_Link_Break_Reset_Recovery.png

    Set Tags    CA-STATE    OWNER-raul.caraiman@nokia.com    AUTHOR-horea.olar@nokia.com    PHASE-QT    SW-SBTS23R4

    Step 1: Check initial state on both BTS
    Step 2: Check initial alarms on both BTS
    Step 3: Get BTS primary controller and BTS secondary controller role
    Step 4: Check and set parameters related to feature CB007437 on both BTS
    Step 5: Check after enabled feature CB007437 state on both BTS
    Step 6: Check after enabled feature CB007437 alarms on both BTS
    Step 7: Get info related to BBMOD and shared RMOD for both BTS
    FOR  ${INDEX}  IN RANGE  1  ${REPEAT_COUNTER}+1
        Set Test Variable  ${CYCLE}  ${INDEX}
        Log  ==============================================================================  console=True
        Log  Start Cycle ${INDEX} of ${REPEAT_COUNTER}  console=True
        Log  ==============================================================================  console=True
        Step 8: Perform link break on primary link between BBMOD and shared RMOD
        Step 9: Check final state on both BTS
        Step 10: Check final alarms on both BTS
        Step 11: Check final number and state of Cells and RMs
    END

    [Teardown]  Particular Teardown

Step ${index}: Check ${when} state on both BTS
    [Documentation]
    ...  BTS state is checked according to Admin

    [Timeout]  15 min
    Log  Step ${index}: Check ${when} state on both BTS  console=True
    FOR  ${alias}  IN  @{alias_list}
        Admin Check BTS RAT Procedural State  alias=${alias}  timeout=600
        Admin Check BTS Procedural and Blocking states  ${OnAir_}  ${Unblocked_}  600  ${alias}
        Log  BTS ${alias} site - proceduralState: OnAir, blockingState: Unblocked  console=True
    END

Step ${index}: Check ${when} alarms on both BTS
    [Documentation]
    ...  BTS alarms are compared with values from expected, ignored and critical alarms lists. BTS alarms are get
    ...  from Admin

    [Timeout]  15 min
    Log  Step ${index}: Check ${when} alarms on both BTS  console=True
    FOR  ${alias}  IN  @{alias_list}
        Log  ***** Check ${when} BTS ${alias} alarms *****  console=True
        Get and Check Alarms SOAM  alias=${alias}  expected_alarms=@{EMPTY}  ignored_alarms=${${alias.upper()}_IGNORED_ALARMS}
        ...  critical_alarms=${${alias.upper()}_CRITICAL_ALARMS}
        Log  BTS ${alias} site - expected, ignored and critical alarms checked  console=True
    END

Step ${index}: Get BTS primary controller and BTS secondary controller role

    Log  Step ${index}: Get BTS primary controller and BTS secondary controller role  console=True
    ${Master_shared_RMOD_list}  ${Slave_shared_RMOD_list}  ${Master_dedicated_RMOD_list}  ${Slave_dedicated_RMOD_list}=
    ...  Admin Get shared and dedicated module list for Master and Slave  RMOD  Master  Slave

    Sort List  ${Master_shared_RMOD_list}
    Sort List  ${Slave_shared_RMOD_list}
    Set Test Variable  ${Master_shared_RMOD_list}
    Set Test Variable  ${Slave_shared_RMOD_list}
    ${shared_RMOD_count}=  Get Length  ${Master_shared_RMOD_list}
    Set Test Variable  ${shared_RMOD_count}

    FOR  ${alias}  IN  @{alias_list}
        Get primary controller BTS shared RMOD list  ${alias}
        Get secondary controller BTS shared RMOD list  ${alias}
    END

    ${BTS_secondary_controller}=  Set Variable If
    ...  ${Master_primary_controller_shared_RMOD_count} == 0  Master  ${Slave_primary_controller_shared_RMOD_count} == 0  Slave  BOTH
    ${BTS_primary_controller}=  Set Variable If  '${BTS_secondary_controller}' == 'Master'  Slave  '${BTS_secondary_controller}' == 'Slave'  Master
    ...  BOTH

    Log  BTS primary controller role: ${BTS_primary_controller}  console=True
    Log  BTS secondary controller role: ${BTS_secondary_controller}  console=True

Get primary controller BTS shared RMOD list
    [Arguments]  ${alias}

    ${BTS_primary_controller_RMOD_list}=  Get RMOD radioMaster info  alias=${alias}
    ${BTS_primary_controller_shared_RMOD_list}=  Create List
    FOR  ${item}  IN  @{BTS_primary_controller_RMOD_list}
       Run Keyword If  '${item}' in ${${alias}_shared_RMOD_list}
        ...  Append To List  ${BTS_primary_controller_shared_RMOD_list}  ${item}
    END
    Sort List  ${BTS_primary_controller_shared_RMOD_list}
    Set Test Variable  ${${alias}_primary_controller_shared_RMOD_list}  ${BTS_primary_controller_shared_RMOD_list}
    Log  BTS ${alias} configured as primary controller for: ${BTS_primary_controller_shared_RMOD_list}  console=True
    ${BTS_primary_controller_shared_RMOD_count}=  Get Length  ${BTS_primary_controller_shared_RMOD_list}
    Set Test Variable  ${${alias}_primary_controller_shared_RMOD_count}  ${BTS_primary_controller_shared_RMOD_count}

Get secondary controller BTS shared RMOD list
    [Arguments]  ${alias}

    ${BTS_secondary_controller_shared_RMOD_list}=  Copy List  ${${alias}_shared_RMOD_list}
    FOR  ${item}  IN  @{${alias}_primary_controller_shared_RMOD_list}
        Remove Values From List  ${BTS_secondary_controller_shared_RMOD_list}  ${item}
    END

    ${BTS_secondary_controller_shared_RMOD_count}=  Get Length  ${BTS_secondary_controller_shared_RMOD_list}
    Set Test Variable  ${${alias}_secondary_controller_shared_RMOD_count}  ${BTS_secondary_controller_shared_RMOD_count}
    Set Test Variable  ${${alias}_secondary_controller_shared_RMOD_list}  ${BTS_secondary_controller_shared_RMOD_list}

Step ${index}: Check and set parameters related to feature CB007437 on both BTS
    [Documentation]
    ...  Check feature CB007437 status on both BTS and set parameters if needed

    Log  Step ${index}: Check and set parameters related to feature CB007437 on both BTS  console=True
    Set Test Variable  ${Master_CB007437_check}  False
    Set Test Variable  ${Slave_CB007437_check}  False
    ${BTS1_FID4742_count}=  Set Variable  ${Master_secondary_controller_shared_RMOD_count}
    ${BTS2_FID4742_count}=  Set Variable  ${Slave_secondary_controller_shared_RMOD_count}
    ${BTS1_EXPECTED_ALARMS_4742}=  Prepare expected alarms list  ${MASTER_EXPECTED_ALARMS_4742}  ${BTS1_FID4742_count}
    ${BTS2_EXPECTED_ALARMS_4742}=  Prepare expected alarms list  ${SLAVE_EXPECTED_ALARMS_4742}  ${BTS2_FID4742_count}

    Check initial feature CB007437 status  Master
    Check initial feature CB007437 status  Slave

    Run Keyword If  not ${Master_CB007437_check}  Run Keywords
    ...  Set feature CB007437 on BTS  actCpriLinkRecovery_value=true  stickToSyncSourcePeriod_value=none  actSyncLinkSwitchover_value=false
    ...  alias=Master
    ...  AND  Set Test Variable  ${Master_CB007437_check}  True
    ...  AND  Log  Check alarms on BTS1 after activate CB007437 feature on BTS1  console=True
    ...  AND  Check BTS alarms after activate CB007437 feature  Master  ${BTS1_FID4742_count}  ${BTS1_EXPECTED_ALARMS_4742}
    ...  AND  Log  Check alarms on BTS2 after activate CB007437 feature on BTS1  console=True
    ...  AND  Check BTS alarms after activate CB007437 feature  Slave  ${BTS2_FID4742_count}  ${BTS2_EXPECTED_ALARMS_4742}

    Run Keyword If  not ${Slave_CB007437_check}  Run Keywords
    ...  Set feature CB007437 on BTS  actCpriLinkRecovery_value=true  stickToSyncSourcePeriod_value=none  actSyncLinkSwitchover_value=false
    ...  alias=Slave
    ...  AND  Set Test Variable  ${Slave_CB007437_check}  True
    ...  AND  Log  Check alarms on BTS1 after activate CB007437 feature on BTS2  console=True
    ...  AND  Check BTS alarms after activate CB007437 feature  Master  0
    ...  AND  Log  Check alarms on BTS2 after activate CB007437 feature on BTS2  console=True
    ...  AND  Check BTS alarms after activate CB007437 feature  Slave   0

Check initial feature CB007437 status
    [Arguments]  ${alias}
    Log  Check initial feature CB007437 status on BTS ${alias}:  console=True

    ${actCpriLinkRecovery_initial}  ${stickToSyncSourcePeriod_initial}  ${actSyncLinkSwitchover_initial}=  Get feature CB007437 info  ${alias}

    Set Test Variable  ${${alias}_actCpriLinkRecovery_initial}  ${actCpriLinkRecovery_initial}
    Set Test Variable  ${${alias}_stickToSyncSourcePeriod_initial}  ${stickToSyncSourcePeriod_initial}
    Set Test Variable  ${${alias}_actSyncLinkSwitchover_initial}  ${actSyncLinkSwitchover_initial}

    ${parameters_condition}=  Create Long String  '${actCpriLinkRecovery_initial}' == 'true' and '${stickToSyncSourcePeriod_initial}' == 'none' and
    ...  '${actSyncLinkSwitchover_initial}' == 'false'
    Run Keyword If  ${parameters_condition}  Run Keywords
    ...  Log  Parameters related to Feature CB007437 already set on BTS ${alias}, no action needed!  console=True
    ...  AND  Set Test Variable  ${${alias}_CB007437_check}  True
    ...  ELSE  Run Keywords  Log  Need to set parameters related to feature CB007437 on BTS ${alias}!  console=True
    ...  AND  Set Test Variable  ${${alias}_CB007437_check}  False

Check BTS alarms after activate CB007437 feature
    [Arguments]  ${alias}  ${expected_alarms_count}  ${expected_alarms_list}=@{EMPTY}

    Log  BTS ${alias} "Configuration mismatch between peer BTSs (4742)" alarm, expected number: ${expected_alarms_count}  console=True
    Get and Check Alarms SOAM  alias=${alias}  expected_alarms=${expected_alarms_list}  ignored_alarms=${${alias.upper()}_IGNORED_ALARMS}
    ...  critical_alarms=${${alias.upper()}_CRITICAL_ALARMS}
    Log  BTS ${alias} "Configuration mismatch between peer BTSs (4742)" alarm, found number: ${expected_alarms_count}, as expected!  console=True
    Log  BTS ${alias} site - expected, ignored and critical alarms checked  console=True

Step ${index}: Get info related to BBMOD and shared RMOD for both BTS
    [Documentation]
    ...  Get info related to BBMOD and shared RMOD for both BTS

    Log  Step ${index}: Get info related to BBMOD and shared RMOD for both BTS  console=True

    Get RMOD ID SN dict  Master
    Get RMOD ID SN dict  Slave
    ${shared_RMOD_sn_list}=  Create List
    FOR  ${Master_RMOD_id}  IN  @{Master_shared_RMOD_list}
        ${RMOD_sn}=  Get From Dictionary  ${Master_module_ID_SN_dict}  ${Master_RMOD_id}
        ${Slave_RMOD_id}=  Get From Dictionary  ${Slave_module_SN_ID_dict}  ${RMOD_sn}
        Append To List  ${shared_RMOD_sn_list}  ${RMOD_sn}
        Log  Shared RMOD with SN ${RMOD_sn}:  console=True
        Log  - Master RMOD id: ${Master_RMOD_id}  console=True
        Log  - Slave RMOD id: ${Slave_RMOD_id}  console=True
    END
    Set Test Variable  ${shared_RMOD_sn_list}

    Get BBMOD ID SN dict  Master
    Get BBMOD ID SN dict  Slave

Step ${index}: Perform link break on primary link between BBMOD and shared RMOD
    [Documentation]
    ...  Perform link break between BBMOD and shared RMOD

    Log  Step ${index}: Perform link break on primary link between BBMOD and shared RMOD  console=True

    Setup for Optical Switch

    ${alias_dict}=  Create dictionary  Master=Slave  Slave=Master
    Set Test Variable  ${alias_dict}

    FOR  ${item}  IN  @{shared_RMOD_sn_list}
        ${PrimaryLink_alias}=  Check alias of primary link  ${item}
        Log  Primary link is on RMOD_${RMOD_sn} from ${PrimaryLink_alias} BTS  console=True
        Run Keyword If  ${Link_break_duration} <= 1500  Run Keywords
        ...  Check the behavior for short link break  ${PrimaryLink_alias}  ${item}
        ...  AND  Log  ====================================================  console=True
        ...  ELSE IF  ${Link_break_duration} >= 1800  Run Keywords
        ...  Check the behavior for long link break  ${PrimaryLink_alias}  ${item}
        ...  AND  Log  ====================================================  console=True
    END

Setup for Optical Switch
    Optical Switch Setup  switch_ip=${OPTICAL_SWITCH['IP']}  switch_username=${OPTICAL_SWITCH['USERNAME']}
    ...  switch_password=${OPTICAL_SWITCH['PASSWORD']}  port=${OPTICAL_SWITCH['PORT']}

Check alias of primary link
    [Arguments]  ${RMOD_sn}

    Check primary link between BBMOD and shared RMOD  ${RMOD_sn}  Master
	Run Keyword If  ${Master_primary_link_status}  Run Keywords
	...  Log  Primary link is on RMOD_${RMOD_sn} from Master BTS  console=True
	...  AND  Return From Keyword  Master
	Check primary link between BBMOD and shared RMOD  ${RMOD_sn}  Slave
	Run Keyword If  ${Slave_primary_link_status}  Run Keywords
	...  Log  Primary link is on RMOD_${RMOD_sn} from Slave BTS  console=True
	...  AND  Return From Keyword  Slave

Check primary link between BBMOD and shared RMOD
    [Arguments]  ${RMOD_sn}  ${alias}
    ${BBMOD_sn_list}=  Get Dictionary Keys  ${${alias}_BBMOD_SN_ID_dict}
    FOR  ${item}  IN  @{BBMOD_sn_list}
        ${BBMOD_sn}=  Set Variable  ${item}
        ${firstModule_connectorLabel_linkModeSynchronization_dict}  ${secondModule_connectorLabel_linkModeSynchronization_dict}
        ...  ${firstModule_connectorLabel_linkModeConfiguration_dict}  ${secondModule_connectorLabel_linkModeConfiguration_dict}
        ...  ${firstModule_secondModule_connectorLabel}
        ...  ${secondModule_firstModule_connectorLabel}=  Get linkModeSynchronization and linkModeConfiguration info dict
        ...  ${BBMOD_sn}  ${RMOD_sn}  ${alias}
        Set Test Variable  ${${alias}_${RMOD_sn}_${BBMOD_sn}_connectorLabel_linkModeSynchronization_dict}
        ...  ${secondModule_connectorLabel_linkModeSynchronization_dict}
        Set Test Variable  ${${alias}_${BBMOD_sn}_${RMOD_sn}_connectorLabel_linkModeSynchronization_dict}
        ...  ${firstModule_connectorLabel_linkModeSynchronization_dict}
        Set Test Variable  ${${alias}_${BBMOD_sn}_${RMOD_sn}_connectorLabel}  ${firstModule_secondModule_connectorLabel}
        Set Test Variable  ${${alias}_${RMOD_sn}_${BBMOD_sn}_connectorLabel}  ${secondModule_firstModule_connectorLabel}
    END
    FOR  ${item}  IN  @{BBMOD_sn_list}
        ${RMOD_connectorLabel_list}=  Get Dictionary Values  ${${alias}_${item}_${RMOD_sn}_connectorLabel}
        Continue For Loop If  not ${RMOD_connectorLabel_list}
        ${BBMOD_RMOD_primary_link_dict}=  Get primary link  ${item}  ${RMOD_sn}  ${RMOD_connectorLabel_list}  ${alias}
        Continue For Loop If  '${${alias}_primary_link_status}' == 'False'
        Log  Primary link between shared RMOD_${RMOD_sn} and BBMOD_${item} info from ${alias}  console=True
        ${shared_BBMOD_RMOD_primary_link_keys}=  Get Dictionary Keys  ${BBMOD_RMOD_primary_link_dict}
        ${shared_BBMOD_RMOD_primary_link_values}=  Get Dictionary Values  ${BBMOD_RMOD_primary_link_dict}
        ${BBMOD_connectorLabel}=  Set Variable  ${shared_BBMOD_RMOD_primary_link_keys[0]}
        ${RMOD_connectorLabel}=  Set Variable  ${shared_BBMOD_RMOD_primary_link_values[0]}
        Log  - BBMOD connectorLabel: ${BBMOD_connectorLabel} - shared RMOD connectorLabel: ${RMOD_connectorLabel}  console=True
        Set Test Variable  ${RMOD_connectorLabel}
        Set Test Variable  ${BBMOD_connectorLabel}
        Set Test Variable  ${RMOD_sn}
        Set Test Variable  ${BBMOD_sn}  ${item}
        Exit For Loop
    END

Get primary link
    [Arguments]  ${BBMOD_sn}  ${RMOD_sn}  ${RMOD_connectorLabel_list}  ${alias}
    ${BBMOD_RMOD_primary_link_dict}=  Create Dictionary
    FOR  ${item}  IN  @{RMOD_connectorLabel_list}
        ${linkModeSynchronization}=  Get From Dictionary  ${${alias}_${RMOD_sn}_${BBMOD_sn}_connectorLabel_linkModeSynchronization_dict}  ${item}
        ${BBMOD_connectorLabel}=  Get From Dictionary  ${${alias}_${RMOD_sn}_${BBMOD_sn}_connectorLabel}  ${item}
        Run Keyword If  '${linkModeSynchronization}' == 'True'  Run Keywords
        ...  Set Test Variable  ${${alias}_primary_link_status}  True
        ...  AND  Set Test Variable  ${${alias_dict['${alias}']}_primary_link_status}  False
        ...  AND  Exit For Loop
        ...  ELSE  Set Test Variable  ${${alias}_primary_link_status}  False
    END
    Run Keyword If  ${${alias}_primary_link_status}  Set To Dictionary  ${BBMOD_RMOD_primary_link_dict}  ${BBMOD_connectorLabel}  ${item}
    [Return]  ${BBMOD_RMOD_primary_link_dict}

Check the behavior for short link break
    [Arguments]  ${alias}  ${RMOD_sn}

    Perform primary link break  alias=${alias}
    Sleep before alarms check
    Check alarms after link break  alias=${alias}  duration=short
    Check alarms after link break  alias=${alias_dict['${alias}']}  duration=short
    Log  Wait 30 sec for RMOD_${RMOD_sn} to be up, in case of reset due to UDPCP mechanism
    Sleep  30 sec
    Check RMOD state after primary link break  ${alias}
    Check alias of primary link  ${RMOD_sn}

Check the behavior for long link break
    [Arguments]  ${alias}  ${RMOD_sn}
    Perform primary link break  ${alias}
    Log  Waiting for "No connection to unit(10)" alarm on ${alias}, expected number: 1  console=True
    Check alarms after link break  alias=${alias}  expected_alarms=${${alias.upper()}_EXPECTED_ALARMS_10}  duration=long
    Log  Waiting for "No connection to unit(10)" alarm on ${alias}, found number: 1, as expected!  console=True

    Log  Waiting for "No connection to unit(10)" alarm on ${alias_dict['${alias}']}, expected number: 1  console=True
    Check alarms after link break  alias=${alias_dict['${alias}']}  expected_alarms=${${alias_dict['${alias}'].upper()}_EXPECTED_ALARMS_10}
    ...  duration=long
    Log  Waiting for "No connection to unit(10)" alarm on ${alias_dict['${alias}']}, found number: 1, as expected  console=True
    Sleep before alarms check
    Check alarms after link break  alias=${alias}  duration=long
    Check alarms after link break  alias=${alias_dict['${alias}']}  duration=long
    Log  Wait 30 sec for RMOD_${RMOD_sn} to be up, in case of reset due to UDPCP mechanism
    Sleep  30 sec
    Check RMOD state after primary link break  ${alias}
    Check alias of primary link  ${RMOD_sn}

Perform primary link break
    [Arguments]  ${alias}

    Run Keyword If  '${${alias}_primary_link_status}' == 'True'
    ...  Log Long String  Test action will be performed on primary link configured between BBMOD_${BBMOD_sn} port ${BBMOD_connectorLabel}
    ...  and shared RMOD_${RMOD_sn} port ${RMOD_connectorLabel} on ${alias}  console=True
    ...  ELSE  Run Keywords
    ...  Log  No primary link configured between any BBMOD and shared RMOD_${RMOD_sn} on ${alias}, try action on peer BTS  console=True
    ...  AND  Return From Keyword
    Check Optical Switch definition info  BBMOD  ${BBMOD_sn}  ${BBMOD_connectorLabel}
    Check Optical Switch definition info  RMOD  ${RMOD_sn}  ${RMOD_connectorLabel}

    ${cross_connection}=  Get Cross Connection Id
    ...  ${BBMOD_${BBMOD_sn}_${BBMOD_connectorLabel}_cross_connection}
    ...  ${RMOD_${RMOD_sn}_${RMOD_connectorLabel}_cross_connection}
    Set Test Variable  ${cross_connection}

    Set short link break  ${cross_connection}

Set short link break
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

Sleep before alarms check
    Log  Waiting 90 seconds for "FIFO buffer over/underflow (4694)" alarm cleared  console=True
    Sleep  90 sec

Check alarms after link break
    [Arguments]  ${alias}=default  ${duration}=short  ${expected_alarms}=@{EMPTY}

    Log  Check alarms after ${duration} link break on BTS ${alias}:  console=True
    Get and Check Alarms SOAM  alias=${alias}
    ...  poll_interval=3 sec
    ...  expected_alarms=${expected_alarms}
    ...  ignored_alarms=${${alias.upper()}_IGNORED_ALARMS}
    ...  critical_alarms=${${alias.upper()}_CRITICAL_ALARMS}

Check RMOD state after primary link break
    [Arguments]  ${alias}

    ${RMOD_state_enabled_check}=  Set Variable  operationalState=${Enabled_}, administrativeState=${Unlocked_}
    ${RMOD_state_enabled}=  Set Variable  operationalState=Enabled, administrativeState=Unlocked

    ${RMOD_id}=  Get From Dictionary  ${${alias}_module_SN_ID_dict}  ${RMOD_sn}
    Log  Check RMOD ${RMOD_id} state after primary link break on BTS ${alias}:  console=True
    Assert  RMOD  ${RMOD_id}  ${RMOD_state_enabled_check}  timeout=60  alias=${alias}
    Log  RMOD status: ${RMOD_state_enabled}  console=True

Step ${index}: Check final number and state of Cells and RMs
    [Documentation]
    ...  Cells state is checked according to operationalState attribute
    ...  Check if number of configured cells and radio modules in SCF are properly mapping on BTS running view.
    ...  Also check RMs operationalState

    [Timeout]  30 min
    Log  Step ${index}: Check final number and state of Cells and RMs  console=True
    RFS Test Case Final Checks

Recover initial settings for feature CB007437
    [Arguments]  ${alias}
    Log  ==============================================================  console=True
    Log  Recover initial settings for feature CB007437 on BTS ${alias}  console=True
    Log  ==============================================================  console=True

    Run Keyword If  '${${alias}_actSyncLinkSwitchover_initial}' == 'false'  Run Keywords
    ...  Set feature CB007437 on BTS  actCpriLinkRecovery_value=true
    ...  stickToSyncSourcePeriod_value=none
    ...  actSyncLinkSwitchover_value=${${alias}_actSyncLinkSwitchover_initial}
    ...  alias=${alias}
    ...  AND  Set feature CB007437 on BTS  actCpriLinkRecovery_value=${${alias}_actCpriLinkRecovery_initial}
    ...  stickToSyncSourcePeriod_value=none
    ...  actSyncLinkSwitchover_value=${${alias}_actSyncLinkSwitchover_initial}
    ...  alias=${alias}
    ...  ELSE  Set feature CB007437 on BTS  actCpriLinkRecovery_value=${${alias}_actCpriLinkRecovery_initial}
    ...  stickToSyncSourcePeriod_value=${${alias}_stickToSyncSourcePeriod_initial}
    ...  actSyncLinkSwitchover_value=${${alias}_actSyncLinkSwitchover_initial}
    ...  alias=${alias}

Particular Teardown
    Run Keyword If  ${Slave_CB007437_check}
    ...  Run Keyword And Continue On Failure  Recover initial settings for feature CB007437  Slave
    Run Keyword If  ${Master_CB007437_check}
    ...  Run Keyword And Continue On Failure  Recover initial settings for feature CB007437  Master

TC Setup
    ${tech_preset_list}=  Create List  SBTS  SBTS
    Common Test Setup  preset_techs=${tech_preset_list}  common_sbts=${TRUE}  infomodelSetup=${FALSE}

TC Teardown
    Common Test Teardown
