*** Settings ***
Documentation    TC__NR_SBTS__STATE__BBMOD_SharedFHS_primary_link_is_lost
Variables    tc_variables/nr_sbts__state__bbmod_sharedfhs_primary_link_is_lost_alarms_definitions.py
Resource    ../../resources/rfs_frame_rfs_soam_taf.robot

*** Variables ***
${REPEAT_COUNTER}  3  # Number of test operation, default value 3
${FHS_serialNumber}  # Shared FHS serial number used for test, possible values: empty (test primary link break on all found shared FHS) or
                     # set specific shared FHS serial number (test primary link break only on specified shared FHS); default value: empty
${BTS_PRIMARY_LINK}  # BTS for primary link set before primary link (sync) break between BBMOD and shared FHS,
                     # possible values: empty (no set required), Master (Master set required) or Slave (Slave set required), default value: empty
${SET_PRIMARY_LINK_TIME}  720  # Maximum time in seconds to wait for Primary Link set on ${BTS_PRIMARY_LINK}, default value: 720

*** Keywords ***
TC__NR_SBTS__STATE__BBMOD_SharedFHS_primary_link_is_lost
    [Documentation]
    ...  [CASE LINK]: https://jiradc.ext.net.nokia.com/browse/TAT-22788
    ...
    ...  *****************
    ...  Basic information
    ...  *****************
    ...  NR-SBTS test case for primary link (sync) break between BBMOD and shared FHS, - x times sequence.
    ...  x - value of REPEAT_COUNTER parameter (default: 3)
    ...  The main steps performed for the test are:
    ...  - check initial state and alarms for both BTS
    ...  - get shared FHS info and related BBMOD RMOD and cells info for both BTS
    ...  - perform primary link (sync) break between BBMOD and shared FHS
    ...  - check states and alarms for both BTS
    ...  - perform primary link (sync) restore between BBMOD and shared FHS
    ...  - check final state and alarms for both BTS
    ...  Pass criteria: BTS behavior, when primary (sync) link is lost/restored, works as expected, states and alarms are as expected
    ...
    ...  ******************
    ...  History of changes
    ...  ******************
    ...  - 07.04.2022 - https://jiradc.ext.net.nokia.com/browse/TAT-22788 -
    ...  [5G][CNI76753][Obsai][SharedFHS] NR_SBTS__State_BBMOD_SharedFHS_Primary_syncronization_to_FHS_is_lost
    ...  - 27.05.2022 - https://jiradc.ext.net.nokia.com/browse/TAT-23184 - [5G][Calient] Remove extra parameters from connection details
    ...  so will use Calient defauls
    ...  - 15.11.2022 - https://jiradc.ext.net.nokia.com/browse/TAT-23185
    ...  - [5G][Calient] Create cross-connect with saved options not with default ones or hardcoded values
    ...  - 03.04.2023 - https://jiradc.ext.net.nokia.com/browse/TAT-24939 - [5G][Refactoring Tracker][CNI 82119] Refactor FHS state check based on
    ...  admin instead of admin-infomodel - NR-SBTS
    ...  - 03.05.2023 - https://jiradc.ext.net.nokia.com/browse/TAT-25242 - [5G] OpticalSwitchResponseError: Unrecognized response from the
    ...  server. Status: 400
    ...  - 22.05.2023 - https://jiradc.ext.net.nokia.com/browse/TAT-25369 - [5G] [Refactoring Tracker] Update rfs_optical_switch resources with
    ...  connection_ID instead of connection_name
    ...  - 17.10.2023 - https://jiradc.ext.net.nokia.com/browse/TAT-26162 -
    ...  [5G] LTE_Site_Reset_from_WEBEM_SharedFHS_mixed_OBSAI_CPRI - update for FID10
    ...  - 15.12.2023 - https://jiradc.ext.net.nokia.com/browse/TAT-26595 - [5G] Add check for BTS state in TCs with Power on / unlock / unblock /
    ...  commissioning in Particular Teardown
    ...  - 23.09.2024 - https://jiradc.ext.net.nokia.com/browse/TAT-28023 - [5G] [Infomodel] In other Link Break TCs: Infomodel refactor KWs:
    ...  "Get linkModeSynchronization info dict" - after TAT-27963
    ...  - 14.04.2025 - https://jiradc.ext.net.nokia.com/browse/TAT-27956 - [REFACTORING][ALARMS] Remove legacy SOAM alarms in Test_Cases and
    ...  Alarm Files NR_SBTS & SBTS_SBTS
    ...  - 24.10.2025 - https://jiradc.ext.net.nokia.com/browse/TAT-29823 -
    ...  Unify alarm list names in order alarm list to begin with upper case Alias - NR_SBTS
    ...
    ...  *******************
    ...  Test case flowchart
    ...  *******************
    ...  .. image:: https://gitlabe1.ext.net.nokia.com/panda-docs/hran_doc/-/blob/master/testsuite/RFS_SOAM/
    ...  TAT-22788_NR_SBTS__STATE__BBMOD_SharedFHS_primary_link_is_lost.png

    Set Tags    CA-STATE    OWNER-bogdan.vinereanu@nokia.com    AUTHOR-ana.tugui@nokia.com    PHASE-QT    SW-SBTS22R3

    Step 1: Check initial all BTS state
    Step 2: Check initial all BTS alarms
    Step 3: Get shared FHS info and related BBMOD, RMOD and cells info for both BTS
    FOR  ${INDEX}  IN RANGE  1  ${REPEAT_COUNTER}+1
        Log  ==============================================================================  console=True
        Log  Start Cycle ${INDEX} of ${REPEAT_COUNTER}  console=True
        Log  ==============================================================================  console=True
        Step 4: Set shared FHS primary link before action
        Step 5: Perform action on primary link between BBMOD and shared FHS
        Step 6: Check final all BTS state
        Step 7: Check final all BTS alarms
        Step 8: Check final number and state of Cells and RMs
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
        Get and Check Alarms SOAM  alias=${alias}  expected_alarms=@{EMPTY}  ignored_alarms=${${alias.upper()}_IGNORED_ALARMS}
        ...  critical_alarms=${${alias.upper()}_CRITICAL_ALARMS}
        Log  BTS ${alias} site - expected, ignored and critical alarms checked  console=True
    END

Step ${index}: Get shared FHS info and related BBMOD, RMOD and cells info for both BTS
    [Documentation]
    ...  BTS info are related to shared FHS, BBMOD, RMOD and cells

    [Timeout]  5 min
    Log  Step ${index}: Get shared FHS info and related BBMOD, RMOD and cells info for both BTS  console=True

    ${Master_shared_FHS_list}  ${Slave_shared_FHS_list}  ${Master_dedicated_FHS_list}  ${Slave_dedicated_FHS_list}=
    ...  Admin Get shared and dedicated module list for Master and Slave  FHS  Master  Slave
    Sort List  ${Master_shared_FHS_list}
    Set Test Variable  ${Master_shared_FHS_list}
    Set Test Variable  ${Slave_shared_FHS_list}
    ${shared_FHS_count}=  Get Length  ${Master_shared_FHS_list}
    Set Test Variable  ${shared_FHS_count}
    Run Keyword If  ${shared_FHS_count} == 0  Run Keywords
    ...  Log  No shared FHS on BTS!  console=True
    ...  AND  Fail  No shared FHS on BTS!

    Get FHS ID SN dict  Master
    Get FHS ID SN dict  Slave
    Set Test Variable  ${Master_FHS_SN_ID_dict}  ${Master_module_SN_ID_dict}
    Set Test Variable  ${Master_FHS_ID_SN_dict}  ${Master_module_ID_SN_dict}
    Set Test Variable  ${Slave_FHS_SN_ID_dict}  ${Slave_module_SN_ID_dict}
    Set Test Variable  ${Slave_FHS_ID_SN_dict}  ${Slave_module_ID_SN_dict}

    ${shared_FHS_sn_list}=  Create List
    FOR  ${Master_FHS_id}  IN  @{Master_shared_FHS_list}
        ${FHS_sn}=  Get From Dictionary  ${Master_FHS_ID_SN_dict}  ${Master_FHS_id}
        ${Slave_FHS_id}=  Get From Dictionary  ${Slave_FHS_sn_ID_dict}  ${FHS_sn}
        Append To List  ${shared_FHS_sn_list}  ${FHS_sn}
        Log  Shared FHS_${FHS_sn}:  console=True
        Log  - Master NR FHS: ${Master_FHS_id}  console=True
        Log  - Slave SBTS FHS: ${Slave_FHS_id}  console=True
    END

    Run Keyword If  '${FHS_serialNumber}' != '' and '${FHS_serialNumber}' not in ${shared_FHS_sn_list}  Run Keywords
    ...  Log Long String  No shared FHS with SN ${FHS_serialNumber} present on BTS. Please choose one of the following: ${shared_FHS_sn_list} or
    ...  let default value (empty)  console=True
    ...  AND  FAIL  No shared FHS with SN ${FHS_serialNumber} present on BTS.

    Set Test Variable  ${shared_FHS_sn_list}
    Get BBMOD ID SN dict  Master
    Get BBMOD ID SN dict  Slave

    ${BBMOD_CELL_dict}=  Get BBMOD CELL mapping based on BBPOOL info from SCF  Master
    Set Test Variable  ${Master_BBMOD_CELL_dict}  ${BBMOD_CELL_dict}
    ${BBMOD_CELL_dict}=  Get BBMOD CELL mapping based on BBPOOL info from SCF  Slave
    Set Test Variable  ${Slave_BBMOD_CELL_dict}  ${BBMOD_CELL_dict}

    ${Master_shared_FHS_RMOD_dict}=  Get shared FHS RMOD dict  ${Master_shared_FHS_list}  Master
    ${Slave_shared_FHS_RMOD_dict}=  Get shared FHS RMOD dict  ${Slave_shared_FHS_list}  Slave
    Set Test Variable  ${Master_shared_FHS_RMOD_dict}
    Set Test Variable  ${Slave_shared_FHS_RMOD_dict}

Step ${index}: Set shared FHS primary link before action
    [Documentation]
    ...  Set shared FHS Primary Link if needed

    Log  Step ${index}: Set shared FHS primary link before action  console=True
    Run Keyword If  '${BTS_PRIMARY_LINK}' == ''  Run Keywords
    ...  Log  ==================================================================================  console=True
    ...  AND  Log  ***** Test action will be performed with existing Primary Link configuration *****  console=True
    ...  AND  Log  ==================================================================================  console=True
    ...  AND  Return From Keyword
    ...  ELSE  Run Keywords
    ...  Log  =============================================================================  console=True
    ...  AND  Log  ***** Test action will be performed with Primary Link set on BTS ${BTS_PRIMARY_LINK} *****  console=True
    ...  AND  Log  =============================================================================  console=True
    Run Keyword If  '${BTS_PRIMARY_LINK}' in ['Master','Slave']
    ...  Set Primary Link status based on linkModeSynchronization by LANE lock unlock procedure
    ...  module_type=FHS  alias=${BTS_PRIMARY_LINK}  wait_for_Primary_Link_set=${SET_PRIMARY_LINK_TIME}
    ...  ELSE  Run Keywords
    ...  Log  Please set one of following values for test argument \${BTS_PRIMARY_LINK}: Master or Slave  level=ERROR
    ...  AND  Fail  Improper value for argument!

Step ${index}: Perform action on primary link between BBMOD and shared FHS
    [Documentation]
    ...  Break and restore optical link carrying sync between BBMOD and shared FHS

    Log  Step ${index}: Perform action on primary link between BBMOD and shared FHS  console=True
    Setup for Optical Switch
    Set Test Variable  ${action_performed}  False
    FOR  ${item}  IN  @{shared_FHS_sn_list}
        Continue For Loop If  '${FHS_serialNumber}' != '' and '${item}' != '${FHS_serialNumber}'
        Run Keyword If  '${BTS_PRIMARY_LINK}' in ['Master','Slave']
        ...  Perform primary link break and restore  ${item}  ${BTS_PRIMARY_LINK}
        ...  ELSE  Run Keywords
        ...  Perform primary link break and restore  ${item}  Master
        ...  AND  Perform primary link break and restore  ${item}  Slave
    END

Step ${index}: Check final number and state of Cells and RMs
    [Documentation]
    ...  Following checks are performed:
    ...  - number of configured cells and radio modules in SCF are properly mapped on BTS running view ADMIN
    ...  - check cells states
    ...  - check radio modules states

    Log  Step ${index}: Check final number and state of Cells and RMs  console=True
    RFS Test Case Final Checks

Get shared FHS RMOD dict
    [Arguments]  ${FHS_list}  ${alias}
    ${shared_FHS_RMOD_dict}=  Create Dictionary
    FOR  ${item}  IN  @{FHS_list}
        ${RMOD_list}=  Get RMOD Mapping By FHS Id  ${item}  ${alias}
        Set To Dictionary  ${shared_FHS_RMOD_dict}  ${item}  ${RMOD_list}
    END
    [Return]  ${shared_FHS_RMOD_dict}

Get RMOD Mapping By FHS Id
    [Arguments]   ${FHS_id}  ${alias}
    ${RMOD_list}=  Create List
    ${CABLINK_list}=  Get Parameters For All  class_name=CABLINK  connection=${alias}
    FOR  ${item}  IN  @{CABLINK_list}
        ${CABLINK_id}=  Get From Dictionary  ${item}  id
        ${firstEndpointDN_FHS_R}=  Run Keyword And Return Status  Should Contain  ${item.firstEndpointDN}  FHS_R
        ${secondEndpointDN_RMOD_R}=  Run Keyword And Return Status  Should Contain  ${item.secondEndpointDN}  RMOD_R
        Run Keyword If  ${firstEndpointDN_FHS_R} and ${secondEndpointDN_RMOD_R}
        ...  Run Keyword If  '${item.firstEndpointDN}' == '${FHS_id}'
        ...  Append To List  ${RMOD_list}  ${item.secondEndpointDN}
    END
    ${RMOD_list}=  Remove Duplicates  ${RMOD_list}
    [Return]  ${RMOD_list}

Perform primary link break and restore
    [Arguments]  ${FHS_sn}  ${alias}
    Return From Keyword If  ${action_performed}
    Get primary link between BBMOD and shared FHS  ${FHS_sn}  ${alias}
    Run Keyword If  ${primary_link_status}
    ...  Log Long String  Test action will be performed on primary link configured between BBMOD_${BBMOD_sn} port ${BBMOD_connectorLabel}
    ...  and shared FHS_${FHS_sn} port ${FHS_connectorLabel} on ${alias}  console=True
    ...  ELSE  Run Keywords
    ...  Log  No primary link configured between any BBMOD and shared FHS_${FHS_sn} on ${alias}, try action on peer BTS  console=True
    ...  AND  Return From Keyword
    Check Optical Switch definition info  BBMOD  ${BBMOD_sn}  ${BBMOD_connectorLabel}
    Check Optical Switch definition info  FHS  ${FHS_sn}  ${FHS_connectorLabel}

    ${cross_connection}=  Get Cross Connection Id
    ...  ${BBMOD_${BBMOD_sn}_${BBMOD_connectorLabel}_cross_connection}
    ...  ${FHS_${FHS_sn}_${FHS_connectorLabel}_cross_connection}
    Set Test Variable  ${cross_connection}
    Check Optical Switch Cross Connection availability  ${cross_connection}
    Save cross connection details  ${cross_connection}
    Perform primary link break  ${cross_connection}  ${alias}
    Perform primary link restore  ${cross_connection}  ${alias}
    Set Test Variable  ${action_performed}  True

Get primary link between BBMOD and shared FHS
    [Arguments]  ${FHS_sn}  ${alias}
    Log  Get primary link between BBMOD and shared FHS_${FHS_sn} on ${alias}:  console=True
    ${BBMOD_sn_list}=  Get Dictionary Keys  ${${alias}_BBMOD_SN_ID_dict}
    FOR  ${item}  IN  @{BBMOD_sn_list}
        ${BBMOD_sn}=  Set Variable  ${item}
        ${firstModule_connectorLabel_linkModeSynchronization_dict}  ${secondModule_connectorLabel_linkModeSynchronization_dict}
        ...  ${firstModule_connectorLabel_linkModeConfiguration_dict}  ${secondModule_connectorLabel_linkModeConfiguration_dict}
        ...  ${firstModule_secondModule_connectorLabel}
        ...  ${secondModule_firstModule_connectorLabel}=  Get linkModeSynchronization and linkModeConfiguration info dict
        ...  ${BBMOD_sn}  ${FHS_sn}  ${alias}
        Set Test Variable  ${${alias}_${BBMOD_sn}_connectorLabel_linkModeSynchronization_dict}
        ...  ${firstModule_connectorLabel_linkModeSynchronization_dict}
        Set Test Variable  ${${alias}_${FHS_sn}_connectorLabel_linkModeSynchronization_dict}
        ...  ${secondModule_connectorLabel_linkModeSynchronization_dict}
        Set Test Variable  ${${alias}_${BBMOD_sn}_${FHS_sn}_connectorLabel}  ${firstModule_secondModule_connectorLabel}
    END
    Set Test Variable  ${primary_link_status}  False
    FOR  ${item}  IN  @{BBMOD_sn_list}
        ${BBMOD_connectorLabel_list}=  Get Dictionary Keys  ${${alias}_${item}_${FHS_sn}_connectorLabel}
        ${BBMOD_FHS_primary_link_dict}=  Get primary link  ${item}  ${FHS_sn}  ${BBMOD_connectorLabel_list}  ${alias}
        Continue For Loop If  '${primary_link_status}' == 'False'
        Set Test Variable  ${BBMOD_${item}_FHS_${FHS_sn}_primary_link_dict}  ${BBMOD_FHS_primary_link_dict}
        ${BBMOD_FHS_primary_link_count}=  Get Length  ${BBMOD_${item}_FHS_${FHS_sn}_primary_link_dict}
        Log  Primary link between BBMOD_${item} and shared FHS_${FHS_sn} info:  console=True
        ${BBMOD_FHS_primary_link_keys}=  Get Dictionary Keys  ${BBMOD_FHS_primary_link_dict}
        ${BBMOD_connectorLabel}=  Set Variable  ${BBMOD_FHS_primary_link_keys[0]}
        ${FHS_connectorLabel}=  Get From Dictionary  ${BBMOD_FHS_primary_link_dict}  ${BBMOD_connectorLabel}
        Log  - BBMOD connectorLabel: ${BBMOD_connectorLabel} - shared FHS connectorLabel: ${FHS_connectorLabel}  console=True
        Set Test Variable  ${BBMOD_connectorLabel}
        Set Test Variable  ${FHS_connectorLabel}
        Set Test Variable  ${BBMOD_sn}  ${item}
        Set Test Variable  ${FHS_sn}
        Exit For Loop
    END

Get primary link
    [Arguments]  ${BBMOD_sn}  ${FHS_sn}  ${BBMOD_connectorLabel_list}  ${alias}
    ${BBMOD_FHS_primary_link_dict}=  Create Dictionary
    FOR  ${item}  IN  @{BBMOD_connectorLabel_list}
        ${linkModeSynchronization}=  Get From Dictionary  ${${alias}_${BBMOD_sn}_connectorLabel_linkModeSynchronization_dict}  ${item}
        ${FHS_connectorLabel}=  Get From Dictionary  ${${alias}_${BBMOD_sn}_${FHS_sn}_connectorLabel}  ${item}
        Run Keyword If  '${linkModeSynchronization}' == 'True'  Run Keywords
        ...  Set Test Variable  ${primary_link_status}  True
        ...  AND  Exit For Loop
    END
    Run Keyword If  ${primary_link_status}  Set To Dictionary  ${BBMOD_FHS_primary_link_dict}  ${item}  ${FHS_connectorLabel}
    [Return]  ${BBMOD_FHS_primary_link_dict}

Perform primary link break
    [Arguments]  ${cross_connection}  ${alias}
    ${peer_alias}=  Set Variable If  '${alias}' == 'Master'  Slave  Master
    ${RMOD_state_disabled_check}=  Set Variable
    ...  operationalState=${Disabled_}, availabilityStatus=${NotInstalled_Offline_}, administrativeState=${Unlocked_}
    ${RMOD_state_disabled}=  Set Variable  operationalState=Disabled, availabilityStatus=NotInstalled|Offline, administrativeState=Unlocked
    ${CELL_state_enabled_check}=  Set Variable  operationalState=${Enabled_}, blockingState=${Unblocked_}
    ${CELL_state_enabled}=  Set Variable  operationalState=Enabled, blockingState=Unblocked

    ${FHS_id}=  Get From Dictionary  ${${alias}_FHS_SN_ID_dict}  ${FHS_sn}
    ${FHS_id_list}=  Create List
    Append To List  ${FHS_id_list}  ${FHS_id}
    ${peer_FHS_id}=  Get From Dictionary  ${${peer_alias}_FHS_SN_ID_dict}  ${FHS_sn}
    ${peer_FHS_id_list}=  Create List
    Append To List  ${peer_FHS_id_list}  ${peer_FHS_id}

    ${shared_FHS_RMOD_list}=  Get From Dictionary  ${${alias}_shared_FHS_RMOD_dict}  ${FHS_id}
    ${peer_shared_FHS_RMOD_list}=  Get From Dictionary  ${${peer_alias}_shared_FHS_RMOD_dict}  ${peer_FHS_id}
    ${shared_FHS_RMOD_count}=  Get Length  ${shared_FHS_RMOD_list}
    ${peer_shared_FHS_RMOD_count}=  Get Length  ${peer_shared_FHS_RMOD_list}

    ${shared_RMOD_CELL_list}=  Get Cell list mapped on shared RM  ${shared_FHS_RMOD_list}  ${alias}
    ${shared_RMOD_CELL_count}=  Get Length  ${shared_RMOD_CELL_list}
    ${peer_shared_RMOD_CELL_list}=  Get Cell list mapped on shared RM  ${peer_shared_FHS_RMOD_list}  ${peer_alias}
    ${peer_shared_RMOD_CELL_count}=  Get Length  ${peer_shared_RMOD_CELL_list}

    ${EXPECTED_ALARMS_10_count}=  Evaluate  ${shared_FHS_RMOD_count} + 1
    ${EXPECTED_ALARMS_10_full}=  Prepare expected alarms list  ${${alias.upper()}_EXPECTED_ALARMS_10}  ${EXPECTED_ALARMS_10_count}

    ${peer_EXPECTED_ALARMS_10_count}=  Evaluate  ${peer_shared_FHS_RMOD_count} + 1
    ${peer_EXPECTED_ALARMS_10_full}=  Prepare expected alarms list  ${${peer_alias.upper()}_EXPECTED_ALARMS_10}  ${peer_EXPECTED_ALARMS_10_count}

    Get BTS CELL list by RAT  Master
    Get BTS CELL list by RAT  Slave

    Log  Perform primary link break by remove Cross Connection ${cross_connection} in Optical Switch  console=True
    Remove Cross Connection By Id  ${cross_connection}
    ${cross_connection_status}=  Get Cross Connection Status by Id  ${cross_connection}
    Run Keyword If  ${cross_connection_status}  Run Keywords
    ...  Log  Primary link break failed: Cross Connection ${cross_connection} not removed in Optical Switch  level=ERROR
    ...  AND  Fail  Primary link break failed
    ...  ELSE
    ...  Log  Primary link break successfully performed: Cross Connection ${cross_connection} removed in Optical Switch  console=True

    Log  Check BTS ${alias} state after primary link break on ${alias}  console=True
    Wait Until Keyword Succeeds  300 sec  10 sec  Admin Check FHS list state  ${FHS_id_list}  ${Disabled_}  Disabled  ${NotInstalled_}
    ...  NotInstalled  ${Unlocked_}  Unlocked  ${alias}
    Log  BTS ${alias} FHS ${FHS_id} status as expected  console=True
    Check BTS Item State  RMOD  ${shared_FHS_RMOD_list}  ${RMOD_state_disabled_check}  ${RMOD_state_disabled}  300  ${alias}
    Log  All BTS ${alias} shared RMOD(s) connected to shared FHS with SN ${FHS_sn} status as expected  console=True

    Log  Check BTS ${peer_alias} state after primary link break on ${alias}  console=True
    Wait Until Keyword Succeeds  300 sec  10 sec  Admin Check FHS list state  ${peer_FHS_id_list}  ${Disabled_}  Disabled  ${NotInstalled_}
    ...  NotInstalled  ${Unlocked_}  Unlocked  ${peer_alias}
    Log  BTS ${peer_alias} FHS ${peer_FHS_id} status as expected  console=True
    Check BTS Item State  RMOD  ${peer_shared_FHS_RMOD_list}  ${RMOD_state_disabled_check}  ${RMOD_state_disabled}  300  ${peer_alias}
    Log  All BTS ${peer_alias} shared RMOD(s) connected to shared FHS with SN ${FHS_sn} status as expected  console=True

    Run Keyword If  ${Master_NR_CELL_list}  Check NR cells state and MIMO alarm  alias=Master
    Log  All BTS ${alias} cell(s) status:\n - ${CELL_state_enabled}  console=True

    Run Keyword If  ${Slave_NR_CELL_list}  Check NR cells state and MIMO alarm  alias=Slave
    Run Keyword If  ${Slave_LTE_CELL_list}  Check LTE cells state and MIMO alarm  alias=Slave
    Run Keyword If  ${Slave_WCDMA_CELL_list}  Check WCDMA cells state and MIMO alarm  alias=Slave
    Run Keyword If  ${Slave_GSM_CELL_list}  Check GSM cells state and MIMO alarm  alias=Slave
    Log  All BTS ${peer_alias} cell(s) status:\n - ${CELL_state_enabled}  console=True

    Log  Check BTS ${alias} alarms after primary link break on ${alias}  console=True
    Log  BTS ${alias} "No connection to Unit (10)" alarm, expected number: ${EXPECTED_ALARMS_10_count}  console=True
    Get and Check Alarms SOAM  alias=${alias}  poll_interval=10 sec  expected_alarms=${EXPECTED_ALARMS_10_full}
    ...  ignored_alarms=${${alias.upper()}_IGNORED_ALARMS}  critical_alarms=${${alias.upper()}_CRITICAL_ALARMS}
    Log  BTS ${alias} "No connection to Unit (10)" alarm, found number: ${EXPECTED_ALARMS_10_count}, as expected!  console=True
    Log  BTS ${alias} site - expected, ignored and critical alarms checked  console=True

    Log  Check BTS ${peer_alias} alarms after primary link break on ${alias}  console=True
    Log  ${peer_alias} "No connection to Unit (10)" alarm, expected number: ${peer_EXPECTED_ALARMS_10_count}  console=True
    Get and Check Alarms SOAM  alias=${peer_alias}  poll_interval=10 sec  expected_alarms=${peer_EXPECTED_ALARMS_10_full}
    ...  ignored_alarms=${${peer_alias.upper()}_IGNORED_ALARMS}  critical_alarms=${${peer_alias.upper()}_CRITICAL_ALARMS}
    Log  BTS ${peer_alias} "No connection to Unit (10)" alarm, found number: ${peer_EXPECTED_ALARMS_10_count}, as expected!  console=True
    Log  BTS ${peer_alias} site - expected, ignored and critical alarms checked  console=True

    Log  Waiting 2 minutes after primary link break on ${alias}  console=True
    Sleep  120s

Perform primary link restore
    [Arguments]  ${cross_connection}  ${alias}
    ${peer_alias}=  Set Variable If  '${alias}' == 'Master'  Slave  Master
    ${RMOD_state_enabled_check}=  Set Variable  operationalState=${Enabled_}, administrativeState=${Unlocked_}
    ${RMOD_state_enabled}=  Set Variable  operationalState=Enabled, administrativeState=Unlocked
    ${CELL_state_enabled_check}=  Set Variable  operationalState=${Enabled_}, blockingState=${Unblocked_}
    ${CELL_state_enabled}=  Set Variable  operationalState=Enabled, blockingState=Unblocked

    ${FHS_id}=  Get From Dictionary  ${${alias}_FHS_SN_ID_dict}  ${FHS_sn}
    ${FHS_id_list}=  Create List
    Append To List  ${FHS_id_list}  ${FHS_id}
    ${peer_FHS_id}=  Get From Dictionary  ${${peer_alias}_FHS_SN_ID_dict}  ${FHS_sn}
    ${peer_FHS_id_list}=  Create List
    Append To List  ${peer_FHS_id_list}  ${peer_FHS_id}

    ${shared_FHS_RMOD_list}=  Get From Dictionary  ${${alias}_shared_FHS_RMOD_dict}  ${FHS_id}
    ${peer_shared_FHS_RMOD_list}=  Get From Dictionary  ${${peer_alias}_shared_FHS_RMOD_dict}  ${peer_FHS_id}

    Get BTS CELL list by RAT  Master
    Get BTS CELL list by RAT  Slave

    Log  Perform primary link restore by create Cross Connection ${cross_connection} in Optical Switch  console=True
    Create Cross Connection with Options by Id  new_connection=${cross_connection}  group=${options['group']}  conn=${options['connid']}
    ...  dir=${options['dir'].lower()}  band=${options['band'][0]}  nolight=${options['nolight']}  deadreckon=${options['deadreckon']}
    ${cross_connection_status}=  Get Cross Connection Status by Id  ${cross_connection}
    Run Keyword If  ${cross_connection_status}
    ...  Log  Primary link restore successfully performed: Cross Connection ${cross_connection} created in Optical Switch  console=True
    ...  ELSE  Run Keywords
    ...  Log  Primary link restore failed: Cross Connection ${cross_connection} not created in Optical Switch  level=ERROR
    ...  AND  Fail  Primary link restore failed
    Sleep  60s

    Log  Check BTS ${alias} state and alarms after primary link restore on ${alias}  console=True
    Wait Until Keyword Succeeds  300 sec  10 sec  Admin Check FHS list state  ${FHS_id_list}  ${Enabled_}  Enabled  ${Online_}  Online|None
    ...  ${Unlocked_}  Unlocked  ${alias}
    Log  BTS ${alias} FHS ${FHS_id} status as expected  console=True
    Check BTS Item State  RMOD  ${shared_FHS_RMOD_list}  ${RMOD_state_enabled_check}  ${RMOD_state_enabled}  300  ${alias}
    Log  All BTS ${alias} shared RMOD(s) connected to shared FHS with SN ${FHS_sn} status as expected  console=True
    Run Keyword If  ${Master_NR_CELL_list}
    ...  Check BTS Item State  NRCEL  ${Master_NR_CELL_list}  ${CELL_state_enabled_check}  ${CELL_state_enabled}  300  Master
    Log  All BTS ${alias} cell(s) status:\n - ${CELL_state_enabled}  console=True
    Get and Check Alarms SOAM  alias=${alias}  expected_alarms=@{EMPTY}  ignored_alarms=${${alias.upper()}_IGNORED_ALARMS}
    ...  critical_alarms=${${alias.upper()}_CRITICAL_ALARMS}
    Log  BTS ${alias} site - expected, ignored and critical alarms checked  console=True

    Log  Check BTS ${peer_alias} state and alarms after primary link restore on ${alias}  console=True
    Wait Until Keyword Succeeds  300 sec  10 sec  Admin Check FHS list state  ${peer_FHS_id_list}  ${Enabled_}  Enabled  ${Online_}  Online|None
    ...  ${Unlocked_}  Unlocked  ${peer_alias}
    Log  BTS ${peer_alias} FHS ${peer_FHS_id} status as expected  console=True
    Check BTS Item State  RMOD  ${peer_shared_FHS_RMOD_list}  ${RMOD_state_enabled_check}  ${RMOD_state_enabled}  300  ${peer_alias}
    Log  All BTS ${peer_alias} shared RMOD(s) connected to shared FHS with SN ${FHS_sn} status as expected  console=True
    Admin Check all BTS cells expected states  expected_state=${CELL_state_enabled_check}  alias=Slave
    Log  All BTS ${peer_alias} cell(s) status:\n - ${CELL_state_enabled}  console=True
    Get and Check Alarms SOAM  alias=${peer_alias}  expected_alarms=@{EMPTY}  ignored_alarms=${${peer_alias.upper()}_IGNORED_ALARMS}
    ...  critical_alarms=${${peer_alias.upper()}_CRITICAL_ALARMS}
    Log  BTS ${peer_alias} site - expected, ignored and critical alarms checked  console=True

Setup for Optical Switch
    Optical Switch Setup  switch_ip=${OPTICAL_SWITCH['IP']}  switch_username=${OPTICAL_SWITCH['USERNAME']}
    ...  switch_password=${OPTICAL_SWITCH['PASSWORD']}  port=${OPTICAL_SWITCH['PORT']}

Check Optical Switch Cross Connection availability
    [Documentation]
    ...  Check if Cross Connection is created in Optical Switch

    [Arguments]  ${cross_connection}
    Log  Check Cross Connection ${cross_connection} availability:  console=True
    ${cross_connection_status}=  Get Cross Connection Status by Id  ${cross_connection}
    Run Keyword If  ${cross_connection_status}
    ...  Log  Cross Connection ${cross_connection} created in Optical Switch  console=True
    ...  ELSE  Run Keywords
    ...  Log  Cross Connection ${cross_connection}} doesn't exist in Optical Switch  level=ERROR
    ...  AND  Fail  Cross Connection ${cross_connection}} doesn't exist in Optical Switch

Check if Cross Connection is created in Optical Switch
    [Arguments]  ${cross_connection}
    ${cross_connection_status}=  Get Cross Connection Status by Id  ${cross_connection}
    Run Keyword If  '${cross_connection_status}' == 'False'  Run Keywords
    ...  Create Cross Connection with Options by Id  ${cross_connection}  group=${options['group']}  conn=${options['connid']}
    ...  dir=${options['dir'].lower()}  band=${options['band'][0]}  nolight=${options['nolight']}  deadreckon=${options['deadreckon']}
    ...  AND  Log  Create Cross Connection ${cross_connection} in Optical Switch indicated  console=True
    [Teardown]  Teardown Optical Switch

Check BTS Item State
    [Arguments]   ${BTS_item_class}  ${BTS_item_list}  ${BTS_item_state_check}  ${BTS_item_state}  ${timeout}  ${alias}
    FOR  ${item}  IN  @{BTS_item_list}
        Assert  class_name=${BTS_item_class}  id=${item}  parameters=${BTS_item_state_check}  timeout=${timeout}  connection=${alias}
        Log  BTS ${alias} ${BTS_item_class} ${item} status:\n - ${BTS_item_state}  console=True
    END

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

Save cross connection details
    [Arguments]  ${cross_connection}
    ${options}=  Get Cross Connection details  ${cross_connection}
    Set Test Variable  ${options}

Particular Teardown
    Check if Cross Connection is created in Optical Switch  ${cross_connection}
    Check all BTS cells availability status online

TC Setup
    ${tech_preset_list}=  Create List  SBTS  SBTS
    Common Test Setup  preset_techs=${tech_preset_list}  common_sbts=${TRUE}  connection_type=ssh_tunnel  infomodelSetup=${FALSE}

TC Teardown
    Common Test Teardown
