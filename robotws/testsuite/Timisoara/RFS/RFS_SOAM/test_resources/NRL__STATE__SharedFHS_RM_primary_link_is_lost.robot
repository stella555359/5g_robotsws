*** Settings ***
Documentation    TC__NRL__STATE__SharedFHS_RM_primary_link_is_lost
Variables    tc_variables/nrl__state__sharedfhs_rm_primary_link_is_lost_alarms_definitions.py
Resource    ../../resources/rfs_frame_rfs_soam_taf.robot

*** Variables ***
${REPEAT_COUNTER}  3  # Number of test operation, default value 3
${RM_serialNumber}  # RMOD serial number used for test, possible values: empty (test primary link break on all RMOD connected to shared FHS) or
                    # set specific RMOD serial number (test primary link break only on specified RMOD connected to shared FHS); default value: empty

*** Keywords ***
TC__NRL__STATE__SharedFHS_RM_primary_link_is_lost
    [Documentation]
    ...  [CASE LINK]: https://jiradc.ext.net.nokia.com/browse/TAT-21995
    ...
    ...  *****************
    ...  Basic information
    ...  *****************
    ...  NR-LTE test case for primary link (sync) break between shared FHS and RMOD, - x times sequence.
    ...  x - value of REPEAT_COUNTER parameter (default: 3)
    ...  The main steps performed for the test are:
    ...  - check initial state and alarms for both BTS
    ...  - get RMOD info and related shared FHS and cells info for both BTS
    ...  - perform primary link (sync) break between shared FHS and RMOD
    ...  - check states and alarms for both BTS
    ...  - perform primary link (sync) restore between shared FHS and RMOD
    ...  - check final state and alarms for both BTS
    ...  Pass criteria: BTS behavior, when primary link (sync) is lost/restored, works as expected, states and alarms are as expected
    ...
    ...  ******************
    ...  History of changes
    ...  ******************
    ...  - 10.03.2022 - https://jiradc.ext.net.nokia.com/browse/TAT-21995 - [5G][Obsai][SharedFHS] NRL_State_SharedFHS_RM_Primary_link_failure
    ...  - 27.05.2022 - https://jiradc.ext.net.nokia.com/browse/TAT-23184
    ...  - [5G][Calient] Remove extra parameters from connection details so will use Calient defauls
    ...  - 15.11.2022 - https://jiradc.ext.net.nokia.com/browse/TAT-23185
    ...  - [5G][Calient] Create cross-connect with saved options not with default ones or hardcoded values
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
    ...  - 17.04.2025 - https://jiradc.ext.net.nokia.com/browse/TAT-29018 - [REFACTORING][ALARMS] Remove legacy SOAM alarms in Test_Cases and
    ...  Alarm Files - NRL TCs
    ...  - 16.09.2025 - https://jiradc.ext.net.nokia.com/browse/TAT-29822 -
    ...  Unify alarm list names in order alarm list to begin with upper case Alias - NRL
    ...
    ...  *******************
    ...  Test case flowchart
    ...  *******************
    ...  .. image:: https://gitlabe1.ext.net.nokia.com/panda-docs/hran_doc/-/blob/master/testsuite/RFS_SOAM/
    ...  TAT-21995_NRL__STATE__SharedFHS_RM_primary_link_is_lost.png

    Set Tags    CA-STATE    OWNER-bogdan.vinereanu@nokia.com    AUTHOR-dinu.olariu@nokia.com    PHASE-QT    SW-SBTS22R2

    Step 1: Check initial all BTS state
    Step 2: Check initial all BTS alarms
    Step 3: Get shared FHS and RMOD info for both BTS
    FOR  ${INDEX}  IN RANGE  1  ${REPEAT_COUNTER}+1
        Log  ==============================================================================  console=True
        Log  Start Cycle ${INDEX} of ${REPEAT_COUNTER}  console=True
        Log  ==============================================================================  console=True
        Step 4: Perform action on primary link between shared FHS and RMOD
        Step 5: Check final all BTS state
        Step 6: Check final all BTS alarms
        Step 7: Check final number and state of Cells and RMs
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

Step ${index}: Get shared FHS and RMOD info for both BTS
    [Documentation]
    ...  BTS info are related to shared FHS and RMOD

    [Timeout]  5 min
    Log  Step ${index}: Get shared FHS and RMOD info for both BTS  console=True

    ${Master_shared_FHS_list}  ${Slave_shared_FHS_list}  ${Master_dedicated_FHS_list}  ${Slave_dedicated_FHS_list}=
    ...  Admin Get shared and dedicated module list for Master and Slave  FHS  Master  Slave
    ${shared_FHS_count}=  Get Length  ${Master_shared_FHS_list}
    Set Test Variable  ${shared_FHS_count}
    Run Keyword If  ${shared_FHS_count} == 0  Run Keywords
    ...  Log  No shared FHS on BTS!  console=True
    ...  AND  Fail  No shared FHS on BTS!
    Set Test Variable  ${Master_shared_FHS_list}
    Set Test Variable  ${Slave_shared_FHS_list}
    Get FHS ID SN dict  Master
    Get FHS ID SN dict  Slave
    Set Test Variable  ${Master_FHS_SN_ID_dict}  ${Master_module_SN_ID_dict}
    Set Test Variable  ${Master_FHS_ID_SN_dict}  ${Master_module_ID_SN_dict}
    Set Test Variable  ${Slave_FHS_SN_ID_dict}  ${Slave_module_SN_ID_dict}
    Set Test Variable  ${Slave_FHS_ID_SN_dict}  ${Slave_module_ID_SN_dict}
    ${shared_FHS_sn_list}=  Get Dictionary Keys  ${Master_FHS_SN_ID_dict}
    Set Test Variable  ${shared_FHS_sn_list}

    ${Master_shared_RMOD_list}  ${Slave_shared_RMOD_list}  ${Master_dedicated_RMOD_list}  ${Slave_dedicated_RMOD_list}=
    ...  Admin Get shared and dedicated module list for Master and Slave  RMOD  Master  Slave
    Set Test Variable  ${Master_shared_RMOD_list}
    Set Test Variable  ${Slave_shared_RMOD_list}
    Set Test Variable  ${Master_dedicated_RMOD_list}
    Set Test Variable  ${Slave_dedicated_RMOD_list}
    Get RMOD ID SN dict  Master
    Get RMOD ID SN dict  Slave
    Set Test Variable  ${Master_RMOD_SN_ID_dict}  ${Master_module_SN_ID_dict}
    Set Test Variable  ${Master_RMOD_ID_SN_dict}  ${Master_module_ID_SN_dict}
    Set Test Variable  ${Slave_RMOD_SN_ID_dict}  ${Slave_module_SN_ID_dict}
    Set Test Variable  ${Slave_RMOD_ID_SN_dict}  ${Slave_module_ID_SN_dict}
    Get specific RMOD SN list  shared  Master
    Get specific RMOD SN list  shared  Slave
    Get specific RMOD SN list  dedicated  Master
    Get specific RMOD SN list  dedicated  Slave
    Get shared FHS RMOD info dict  ${Master_shared_FHS_list}  Master
    Get shared FHS RMOD info dict  ${Slave_shared_FHS_list}  Slave
    Set Test Variable  ${shared_FHS_RMOD_sn_dict}  ${Master_shared_FHS_RMOD_sn_dict}
    ${shared_FHS_RMOD_sn_list}=  Create List
    Set Test Variable  ${shared_FHS_RMOD_sn_list}
    FOR  ${FHS_sn}  IN  @{shared_FHS_sn_list}
        ${RMOD_sn_list}=  Get From Dictionary  ${shared_FHS_RMOD_sn_dict}  ${FHS_sn}
        Get RMOD info connected to shared FHS  ${RMOD_sn_list}  ${FHS_sn}
    END

    Run Keyword If  '${RM_serialNumber}' != '' and '${RM_serialNumber}' not in ${shared_FHS_RMOD_sn_list}  Run Keywords
    ...  Log Long String  No RMOD with SN ${RM_serialNumber} connected to shared FHS present on BTS. Please choose one of the following:
    ...  ${shared_FHS_RMOD_sn_list} or let default value (empty)  console=True
    ...  AND  FAIL  No RMOD with SN ${RM_serialNumber} connected to shared FHS present on BTS.

Step ${index}: Perform action on primary link between shared FHS and RMOD
    [Documentation]
    ...  Break and restore optical link carrying sync between shared FHS and RMOD

    Log  Step ${index}: Perform action on primary link between shared FHS and RMOD  console=True
    Setup for Optical Switch
    FOR  ${item}  IN  @{shared_FHS_RMOD_sn_list}
        Continue For Loop If  '${RM_serialNumber}' != '' and '${item}' != '${RM_serialNumber}'
        Perform primary link break and restore  ${item}
    END

Step ${index}: Check final number and state of Cells and RMs
    [Documentation]
    ...  Following checks are performed:
    ...  - number of configured cells and radio modules in SCF are properly mapped on BTS running view ADMIN
    ...  - check cells states
    ...  - check radio modules states

    Log  Step ${index}: Check final number and state of Cells and RMs  console=True
    RFS Test Case Final Checks

Get shared FHS RMOD info dict
    [Arguments]  ${FHS_list}  ${alias}
    ${shared_FHS_RMOD_id_dict}=  Create Dictionary
    ${shared_FHS_RMOD_sn_dict}=  Create Dictionary
    FOR  ${FHS_id}  IN  @{FHS_list}
        Get RMOD mapping info by FHS Id  ${FHS_id}  ${alias}
        Set To Dictionary  ${shared_FHS_RMOD_id_dict}  ${FHS_id}  ${${alias}_RMOD_id_list}
        ${FHS_sn}=  Get From Dictionary  ${${alias}_FHS_ID_SN_dict}  ${FHS_id}
        Set To Dictionary  ${shared_FHS_RMOD_sn_dict}  ${FHS_sn}  ${${alias}_RMOD_sn_list}
    END
    Set Test Variable  ${${alias}_shared_FHS_RMOD_id_dict}  ${shared_FHS_RMOD_id_dict}
    Set Test Variable  ${${alias}_shared_FHS_RMOD_sn_dict}  ${shared_FHS_RMOD_sn_dict}

Get RMOD mapping info by FHS Id
    [Arguments]   ${FHS_id}  ${alias}
    ${RMOD_id_list}=  Create List
    ${RMOD_sn_list}=  Create List
    ${CABLINK_list}=  Get Parameters For All  class_name=CABLINK  connection=${alias}
    FOR  ${item}  IN  @{CABLINK_list}
        ${CABLINK_id}=  Get From Dictionary  ${item}  id
        ${secondEndpointDN_RMOD_R}=  Run Keyword And Return Status  Should Contain  ${item.secondEndpointDN}  RMOD_R
        Run Keyword If  '${item.firstEndpointDN}' != '${FHS_id}' or '${secondEndpointDN_RMOD_R}' == 'False'
        ...  Continue For Loop
        ${RMOD_sn}=  Get From Dictionary  ${${alias}_RMOD_ID_SN_dict}  ${item.secondEndpointDN}
        Append To List  ${RMOD_id_list}  ${item.secondEndpointDN}
        Append To List  ${RMOD_sn_list}  ${RMOD_sn}
    END
    ${RMOD_id_list}=  Remove Duplicates  ${RMOD_id_list}
    ${RMOD_sn_list}=  Remove Duplicates  ${RMOD_sn_list}
    Set Test Variable  ${${alias}_RMOD_id_list}  ${RMOD_id_list}
    Set Test Variable  ${${alias}_RMOD_sn_list}  ${RMOD_sn_list}

Get RMOD info connected to shared FHS
    [Arguments]  ${RMOD_sn_list}  ${FHS_sn}
    FOR  ${RMOD_sn}  IN  @{RMOD_sn_list}
        ${Master_RMOD_id}=  Get From Dictionary  ${Master_RMOD_SN_ID_dict}  ${RMOD_sn}
        ${Slave_RMOD_id}=  Get From Dictionary  ${Slave_RMOD_SN_ID_dict}  ${RMOD_sn}
        Append To List  ${shared_FHS_RMOD_sn_list}  ${RMOD_sn}
        Log  RMOD_${RMOD_sn} connected to shared FHS_${FHS_sn}:  console=True
        Log  - Master NR RMOD: ${Master_RMOD_id}  console=True
        Log  - Slave LTE RMOD: ${Slave_RMOD_id}  console=True
    END

Get specific RMOD SN list
    [Arguments]  ${configured}  ${alias}
    ${RMOD_sn_list}=  Create List
    FOR  ${RMOD_id}  IN  @{${alias}_${configured}_RMOD_list}
        ${RMOD_sn}=  Get From Dictionary  ${${alias}_RMOD_ID_SN_dict}  ${RMOD_id}
        Append To List  ${RMOD_sn_list}  ${RMOD_sn}
    END
    Set Test Variable  ${${alias}_${configured}_RMOD_sn_list}  ${RMOD_sn_list}

Perform primary link break and restore
    [Arguments]  ${RMOD_sn}
    Get primary link between shared FHS and RMOD  ${RMOD_sn}  initial
    Log Long String
    ...  Test action will be performed on primary link configured between shared FHS_${FHS_sn} port ${FHS_connectorLabel} and RMOD_${RMOD_sn}
    ...  port ${RMOD_connectorLabel}  console=True
    Check Optical Switch definition info  FHS  ${FHS_sn}  ${FHS_connectorLabel}
    Check Optical Switch definition info  RMOD  ${RMOD_sn}  ${RMOD_connectorLabel}

    ${cross_connection}=  Get Cross Connection Id
    ...  ${FHS_${FHS_sn}_${FHS_connectorLabel}_cross_connection}
    ...  ${RMOD_${RMOD_sn}_${RMOD_connectorLabel}_cross_connection}
    Set Test Variable  ${cross_connection}
    Check Optical Switch Cross Connection availability  ${cross_connection}
    Save cross connection details  ${cross_connection}
    Perform primary link break  ${cross_connection}
    Perform primary link restore  ${cross_connection}
    Get primary link between shared FHS and RMOD  ${RMOD_sn}  final

Get primary link between shared FHS and RMOD
    [Arguments]  ${RMOD_sn}  ${when}
    Log  Get ${when} primary link between shared FHS and RMOD:  console=True
    ${alias}=  Set Variable If  '${RMOD_sn}' in ${Slave_dedicated_RMOD_sn_list}  Slave  Master
    FOR  ${item}  IN  @{shared_FHS_sn_list}
        ${FHS_sn}=  Set Variable  ${item}
        ${firstModule_connectorLabel_linkModeSynchronization_dict}  ${secondModule_connectorLabel_linkModeSynchronization_dict}
        ...  ${firstModule_connectorLabel_linkModeConfiguration_dict}  ${secondModule_connectorLabel_linkModeConfiguration_dict}
        ...  ${firstModule_secondModule_connectorLabel}
        ...  ${secondModule_firstModule_connectorLabel}=  Get linkModeSynchronization and linkModeConfiguration info dict
        ...  ${FHS_sn}  ${RMOD_sn}  ${alias}
        Set Test Variable  ${${alias}_${FHS_sn}_connectorLabel_linkModeSynchronization_dict}
        ...  ${firstModule_connectorLabel_linkModeSynchronization_dict}
        Set Test Variable  ${${alias}_${RMOD_sn}_connectorLabel_linkModeSynchronization_dict}
        ...  ${secondModule_connectorLabel_linkModeSynchronization_dict}
        Set Test Variable  ${${alias}_${FHS_sn}_${RMOD_sn}_connectorLabel}  ${firstModule_secondModule_connectorLabel}
        Set Test Variable  ${${alias}_${RMOD_sn}_${FHS_sn}_connectorLabel}  ${secondModule_firstModule_connectorLabel}
    END
    FOR  ${item}  IN  @{shared_FHS_sn_list}
        ${RMOD_connectorLabel_list}=  Get Dictionary Values  ${${alias}_${item}_${RMOD_sn}_connectorLabel}
        ${shared_FHS_RMOD_primary_link_dict}=  Get primary link  ${item}  ${RMOD_sn}  ${RMOD_connectorLabel_list}  ${alias}
        Continue For Loop If  '${primary_link_status}' == 'False'
        Log  Primary link between RMOD_${RMOD_sn} and shared FHS_${item} info:  console=True
        ${shared_FHS_RMOD_primary_link_keys}=  Get Dictionary Keys  ${shared_FHS_RMOD_primary_link_dict}
        ${shared_FHS_RMOD_primary_link_values}=  Get Dictionary Values  ${shared_FHS_RMOD_primary_link_dict}
        ${FHS_connectorLabel}=  Set Variable  ${shared_FHS_RMOD_primary_link_keys[0]}
        ${RMOD_connectorLabel}=  Set Variable  ${shared_FHS_RMOD_primary_link_values[0]}
        Log  - RMOD connectorLabel: ${RMOD_connectorLabel} - shared FHS connectorLabel: ${FHS_connectorLabel}  console=True
        Set Test Variable  ${RMOD_connectorLabel}
        Set Test Variable  ${FHS_connectorLabel}
        Set Test Variable  ${RMOD_sn}
        Set Test Variable  ${FHS_sn}  ${item}
        Exit For Loop
    END

Get primary link
    [Arguments]  ${FHS_sn}  ${RMOD_sn}  ${RMOD_connectorLabel_list}  ${alias}
    ${shared_FHS_RMOD_primary_link_dict}=  Create Dictionary
    FOR  ${item}  IN  @{RMOD_connectorLabel_list}
        ${linkModeSynchronization}=  Get From Dictionary  ${${alias}_${RMOD_sn}_connectorLabel_linkModeSynchronization_dict}  ${item}
        ${FHS_connectorLabel}=  Get From Dictionary  ${${alias}_${RMOD_sn}_${FHS_sn}_connectorLabel}  ${item}
        Run Keyword If  '${linkModeSynchronization}' == 'True'  Run Keywords
        ...  Set Test Variable  ${primary_link_status}  True
        ...  AND  Exit For Loop
    END
    Run Keyword If  ${primary_link_status}  Set To Dictionary  ${shared_FHS_RMOD_primary_link_dict}  ${FHS_connectorLabel}  ${item}
    [Return]  ${shared_FHS_RMOD_primary_link_dict}

Perform primary link break
    [Arguments]  ${cross_connection}
    ${RMOD_state_disabled_check}=  Set Variable
    ...  operationalState=${Disabled_}, availabilityStatus=${NotInstalled_Offline_}, administrativeState=${Unlocked_}
    ${RMOD_state_disabled}=  Set Variable  operationalState=Disabled, availabilityStatus=NotInstalled|Offline, administrativeState=Unlocked
    ${Master_RMOD_id}=  Get From Dictionary  ${Master_RMOD_SN_ID_dict}  ${RMOD_sn}
    ${Slave_RMOD_id}=  Get From Dictionary  ${Slave_RMOD_SN_ID_dict}  ${RMOD_sn}
    ${Master_RMOD_CELL_list}=  Get Cell Mapping By Module Id  module_id=${Master_RMOD_id}  connection=Master
    ${Slave_RMOD_CELL_list}=  Get Cell Mapping By Module Id  module_id=${Slave_RMOD_id}  connection=Slave
    ${Master_RMOD_CELL_count}=  Get Length  ${Master_RMOD_CELL_list}
    ${Slave_RMOD_CELL_count}=  Get Length  ${Slave_RMOD_CELL_list}
    Sort List  ${Master_RMOD_CELL_list}
    Sort List  ${Slave_RMOD_CELL_list}

    ${MASTER_IGNORED_ALARMS_full}=  Combine Lists  ${MASTER_IGNORED_ALARMS_4003}  ${MASTER_IGNORED_ALARMS}
    ${SLAVE_IGNORED_ALARMS_full}=  Combine Lists  ${SLAVE_IGNORED_ALARMS_4003}  ${SLAVE_IGNORED_ALARMS}

    Log  Cell(s) impacted by RMOD_${RMOD_sn} primary link break:   console=True
    Log  - Master NRCEL: ${Master_RMOD_CELL_list}  console=True
    Log  - Slave LNCEL: ${Slave_RMOD_CELL_list}  console=True

    Log  Perform primary link break by remove Cross Connection ${cross_connection} in Optical Switch  console=True
    Remove Cross Connection By Id  ${cross_connection}
    ${cross_connection_status}=  Get Cross Connection Status by Id  ${cross_connection}
    Run Keyword If  ${cross_connection_status}  Run Keywords
    ...  Log  Primary link break failed: Cross Connection ${cross_connection} not removed in Optical Switch  level=ERROR
    ...  AND  Fail  Primary link break failed
    ...  ELSE
    ...  Log  Primary link break successfully performed: Cross Connection ${cross_connection} removed in Optical Switch  console=True
    Sleep  10s

    Log  Check Master NR state and alarm after primary link break on RMOD_${RMOD_sn}  console=True
    Assert  class_name=RMOD  id=${Master_RMOD_id}  parameters=${RMOD_state_disabled_check}  timeout=60  connection=Master
    Log  NR RMOD ${Master_RMOD_id} status:\n - ${RMOD_state_disabled}  console=True
    Check NR cells state and MIMO alarm  alias=Master
    Log  NR "No connection to Unit (10)" alarm, expected number: 1  console=True
    Get and Check Alarms SOAM  alias=Master  poll_interval=10 sec  expected_alarms=${MASTER_EXPECTED_ALARMS_10}
    ...  ignored_alarms=${MASTER_IGNORED_ALARMS_full}  critical_alarms=${MASTER_CRITICAL_ALARMS}
    Log  NR "No connection to Unit (10)" alarm, found number: 1, as expected!  console=True
    Log  NR site - expected, ignored and critical alarms checked  console=True

    Log  Check Slave LTE state and alarm after primary link break on RMOD_${RMOD_sn}  console=True
    Assert  class_name=RMOD  id=${Slave_RMOD_id}  parameters=${RMOD_state_disabled_check}  timeout=60  connection=Slave
    Log  LTE RMOD ${Slave_RMOD_id} status:\n - ${RMOD_state_disabled}  console=True
    Check LTE cells state and MIMO alarm  alias=Slave
    Log  LTE "No connection to Unit (10)" alarm, expected number: 1  console=True
    Get and Check Alarms SOAM  alias=Slave  poll_interval=10 sec  expected_alarms=${SLAVE_EXPECTED_ALARMS_10}
    ...  ignored_alarms=${SLAVE_IGNORED_ALARMS_full}  critical_alarms=${SLAVE_CRITICAL_ALARMS}
    Log  LTE "No connection to Unit (10)" alarm, found number: 1, as expected!  console=True
    Log  LTE site - expected, ignored and critical alarms checked  console=True

    Log  Waiting 2 minutes after primary link break  console=True
    Sleep  120s

Perform primary link restore
    [Arguments]  ${cross_connection}
    ${RMOD_state_enabled_check}=  Set Variable  operationalState=${Enabled_}, administrativeState=${Unlocked_}
    ${RMOD_state_enabled}=  Set Variable  operationalState=Enabled, administrativeState=Unlocked
    ${CELL_state_enabled_check}=  Set Variable  operationalState=${Enabled_}, blockingState=${Unblocked_}
    ${CELL_state_enabled}=  Set Variable  operationalState=Enabled, blockingState=Unblocked
    ${Master_RMOD_id}=  Get From Dictionary  ${Master_RMOD_SN_ID_dict}  ${RMOD_sn}
    ${Slave_RMOD_id}=  Get From Dictionary  ${Slave_RMOD_SN_ID_dict}  ${RMOD_sn}

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

    Log  Check Master NR state and alarm after primary link restore on RMOD_${RMOD_sn}  console=True
    Assert  class_name=RMOD  id=${Master_RMOD_id}  parameters=${RMOD_state_enabled_check}  timeout=300  connection=Master
    Log  NR RMOD ${Master_RMOD_id} status:\n - ${RMOD_state_enabled}  console=True
    Get and Check Alarms SOAM  alias=Master  expected_alarms=@{EMPTY}   ignored_alarms=${MASTER_IGNORED_ALARMS}
    ...  critical_alarms=${MASTER_CRITICAL_ALARMS}
    Log  NR site - expected, ignored and critical alarms checked  console=True
    Assert Every  class_name=NRCEL  parameters=${CELL_state_enabled_check}  timeout=300  connection=Master
    Log  All NR cell(s) status:\n - ${CELL_state_enabled}  console=True

    Log  Check Slave LTE state and alarm after primary link restore on RMOD_${RMOD_sn}  console=True
    Assert  class_name=RMOD  id=${Slave_RMOD_id}  parameters=${RMOD_state_enabled_check}  timeout=300  connection=Slave
    Log  LTE RMOD ${Slave_RMOD_id} status:\n - ${RMOD_state_enabled}  console=True
    Get and Check Alarms SOAM  alias=Slave  expected_alarms=@{EMPTY}  ignored_alarms=${SLAVE_IGNORED_ALARMS}
    ...  critical_alarms=${SLAVE_CRITICAL_ALARMS}
    Log  LTE site - expected, ignored and critical alarms checked  console=True
    Assert Every  class_name=LNCEL  parameters=${CELL_state_enabled_check}  timeout=300  connection=Slave
    Log  All LTE cell(s) status:\n - ${CELL_state_enabled}  console=True

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

Save cross connection details
    [Arguments]  ${cross_connection}
    ${options}=  Get Cross Connection details  ${cross_connection}
    Set Test Variable  ${options}

Particular Teardown
    Check if Cross Connection is created in Optical Switch  ${cross_connection}
    Check all BTS cells availability status online

TC Setup
    ${tech_preset_list}=  Create List  SBTS  SBTS
    Common Test Setup  preset_techs=${tech_preset_list}  common_sbts=${TRUE}  infomodelSetup=${FALSE}

TC Teardown
    Common Test Teardown
