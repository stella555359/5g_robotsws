*** Settings ***
Documentation    TC__SBTS_SBTS__STATE__SMOD_BBMOD_shared_RM_Primary_link_is_lost
Variables    tc_variables/sbts_sbts__state__smod_bbmod_shared_rm_primary_link_is_lost.py
Resource    ../../resources/rfs_frame_rfs_soam_taf.robot

*** Variables ***
${REPEAT_COUNTER}  3       # Number of test operation, default value 3
${RMOD_SN_list}  ALL       # List of shared RMODs serial numbers impacted. Possible values (by default ALL):
                           # - ALL: action will be performed on all shared RMODs
                           # - list of selected RMODs separated by comma. Example: L1181711696, L1181711681
${RM_MAX_WAIT_TIME_Link_Break}    240  # Maximum time for impacted RMOD to switch primary link on peer BTS after primary link break on BTS. If this
                                       # value is exceeded test will fail
${RM_MAX_WAIT_TIME_Link_Restore}  60   # Maximum time for impacted RMOD to recover after link restore on BTS. If this value
                                       # is exceeded test will fail

*** Keywords ***
TC__SBTS_SBTS__STATE__SMOD_BBMOD_shared_RM_Primary_link_is_lost
    [Documentation]
    ...  [CASE LINK]: https://jiradc.ext.net.nokia.com/browse/TAT-26151
    ...
    ...  *****************
    ...  Basic information
    ...  *****************
    ...  SBTS-SBTS test case for SBTS BTS1/BTS2 shared RMOD Primary Link Break, - x times sequence.
    ...
    ...  The main steps performed for the test are:
    ...
    ...  - check initial state and alarms for both BTS
    ...  - get shared RMOD and cells info for both BTS
    ...  - get shared RMOD Primary Link Info before link break operation
    ...  - perform primary link break between RMOD and BBMOD/SMOD
    ...  - check RMOD state and alarms on both BTS
    ...  - perform link restore between RMOD and BBMOD/SMOD
    ...  - check final state and alarms for both BTS
    ...  Pass criteria: BTS behavior, when primary (sync) link is lost/restored, works as expected, states and alarms are as expected
    ...
    ...
    ...  Pass criteria: Scenario works as expected, states and alarms are as expected
    ...
    ...  ***************************
    ...  History of changes for SOAM
    ...  ***************************
    ...
    ...  - 06.12.2023 - https://jiradc.ext.net.nokia.com/browse/TAT-26151 - [5G][CB010564] Automated_SBTS_SBTS__STATE_SharedRM_primary_link_failure
    ...  - 19.06.2023 - https://jiradc.ext.net.nokia.com/browse/TAT-27623 - [NR-LTE] Check cell state and availability status
    ...  - 23.07.2024 - https://jiradc.ext.net.nokia.com/browse/TAT-27819 - [CNI-127210][Part 1] MIMO remove EXPECTED minor alarm from SBTS_* TCs
    ...  - 23.09.2024 - https://jiradc.ext.net.nokia.com/browse/TAT-28023 - [5G] [Infomodel] In other Link Break TCs: Infomodel refactor KWs:
    ...  "Get linkModeSynchronization info dict" - after TAT-27963
    ...
    ...  *******************
    ...  Test case flowchart
    ...  *******************
    ...  .. image:: https://gitlabe1.ext.net.nokia.com/panda-docs/hran_doc/-/blob/master/testsuite/RFS_SOAM/
    ...  TAT-26151__SBTS_SBTS__STATE__SMOD_BBMOD_shared_RM_Primary_link_is_lost.png

    Set Tags    CA-STATE    OWNER-deiana-nicolia.stoianovici@nokia.com    AUTHOR-andreea.szentannai@nokia.com    PHASE-QT    SW-SBTS24R1

    Step 1: Check initial both BTS state
    Step 2: Check initial both BTS alarms
    Step 3: Get shared RMOD and cells info for both BTS
    FOR  ${INDEX}  IN RANGE  1  ${REPEAT_COUNTER}+1
        Log  ==============================================================================  console=True
        Log  Start Cycle ${INDEX} of ${REPEAT_COUNTER}  console=True
        Log  ==============================================================================  console=True
        Step 4: Perform primary link break and restore between SMOD/BBMOD and shared RMOD
        Step 5: Check final both BTS state
        Step 6: Check final both BTS alarms
        Step 7: Check final number and state of Cells and RMs
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

Step ${index}: Get shared RMOD and cells info for both BTS
    Log  Step ${index}: Get shared RMOD and cells info for both BTS  console=True
    ${Master_shared_RMOD_list}  ${Slave_shared_RMOD_list}  ${Master_dedicated_RMOD_list}  ${Slave_dedicated_RMOD_list}=
    ...  Admin Get shared and dedicated module list for Master and Slave  RMOD  Master  Slave
    Sort List  ${Master_shared_RMOD_list}
    Sort List  ${Slave_shared_RMOD_list}
    Set Test Variable  ${Master_shared_RMOD_list}
    Set Test Variable  ${Slave_shared_RMOD_list}
    ${shared_RMOD_sn_list}=  Create List

    FOR  ${alias}  IN  @{alias_list}
        Get shared RMOD CELL dict  ${alias}
        Get BTS CELL list by RAT  ${alias}
        Get RMOD ID SN dict  ${alias}
        ${RM_L3Protocol_dict}=  Admin Get RMOD L3 Protocol Info  ${alias}
        Set Test Variable  ${${alias}_RM_L3Protocol_dict}  ${RM_L3Protocol_dict}
    END

    FOR  ${Master_RMOD_id}  IN  @{Master_shared_RMOD_list}
        ${RMOD_sn}=  Get From Dictionary  ${Master_module_ID_SN_dict}  ${Master_RMOD_id}
        Append To List  ${shared_RMOD_sn_list}  ${RMOD_sn}
    END
    Set Test Variable  ${shared_RMOD_sn_list}

    Run Keyword If  '${RMOD_SN_list}' != 'ALL'  Check RM serial number list

Step ${index}: Perform primary link break and restore between SMOD/BBMOD and shared RMOD
    [Documentation]
    ...  Perform primary link break and restore between SMOD/BBMOD and shared RMOD

    Set Test Variable  ${RMOD_state_disabled_check}
    ...  operationalState=${Disabled_}, availabilityStatus=${NotInstalled_}, administrativeState=${Unlocked_}
    Set Test Variable  ${RMOD_state_disabled}  operationalState=Disabled, availabilityStatus=NotInstalled, administrativeState=Unlocked
    Set Test Variable  ${RMOD_state_enabled_check}  operationalState=${Enabled_}, administrativeState=${Unlocked_}
    Set Test Variable  ${RMOD_state_enabled}  operationalState=Enabled, administrativeState=Unlocked
    Set Test Variable  ${CELL_state_disabled_check}
    ...  operationalState=${Disabled_}, availabilityStatus=${Failed_Offline_}, blockingState=${Unblocked_}
    Set Test Variable  ${CELL_state_enabled_check}  operationalState=${Enabled_}, blockingState=${Unblocked_}
    Set Test Variable  ${CELL_state_disabled}  operationalState=Disabled, availabilityStatus=Failed|Offline, blockingState=Unblocked
    Set Test Variable  ${CELL_state_enabled}  operationalState=Enabled, blockingState=Unblocked

    Log  Step ${index}: Perform primary link break and restore between SMOD/BBMOD and shared RMOD  console=True
    Setup for Optical Switch

    FOR  ${item}  IN  @{shared_RMOD_sn_list}
        ${PL_alias}=  Check alias of primary link  ${item}
        ${non_PL_alias}=  Set Variable If  '${PL_alias}' == 'Master'  Slave  Master
        ${RMOD_id}=  Get From Dictionary  ${${PL_alias}_module_SN_ID_dict}  ${item}
        ${RM_L3Protocol}=  Get From Dictionary  ${${PL_alias}_RM_L3Protocol_dict}  ${RMOD_id}
        Perform RMOD primary link break and restore  ${item}  ${RM_L3Protocol}  ${PL_alias}  ${non_PL_alias}
    END

Perform RMOD primary link break and restore
   [Arguments]  ${RMOD_sn}  ${RM_L3Protocol}  ${alias}  ${peer_alias}

    ${Cross_connection_dict_keys}=  Get Dictionary Keys  ${${alias}_Cross_connection_linkModeSynchronization_dict}
    FOR  ${item}  IN  @{Cross_connection_dict_keys}
        ${linkModeSynchronization}=  Get From Dictionary  ${${alias}_Cross_connection_linkModeSynchronization_dict}  ${item}
        Run Keyword If  '${linkModeSynchronization}' == 'True'  Run Keywords
        ...  Set Test Variable  ${cross_connection}  ${item}
        ...  AND  Exit For Loop
    END
    ${options}=  Get From Dictionary  ${${alias}_Cross_connection_options_dict}  ${cross_connection}
    Set Test Variable  ${options}
    Get shared RMOD cells  ${RMOD_sn}  ${alias}
    Get shared RMOD cells  ${RMOD_sn}  ${peer_alias}
    Perform RMOD primary link break  ${cross_connection}  ${alias}
    Run Keyword If  '${RM_L3Protocol}' == 'CPRI_RP1'
    ...  Check CPRI RMOD state and alarms after primary link break  ${RMOD_sn}  ${alias}  ${peer_alias}
    ...  ELSE IF  '${RM_L3Protocol}' == 'ECPRI_MPLANE'
    ...  Check ECPRI RMOD state and alarms after primary link break  ${RMOD_sn}  ${alias}  ${peer_alias}
    ...  ELSE IF  '${RM_L3Protocol}' == 'RP301_RP1'
    ...  Check OBSAI RMOD state and alarms after primary link break  ${RMOD_sn}  ${alias}  ${peer_alias}
    Perform RMOD primary link restore  ${cross_connection}  ${alias}
    Check RMOD and cells state after link restore  ${RMOD_sn}  ${alias}

Perform RMOD primary link break
    [Arguments]  ${cross_connection}  ${alias}

    Log  Perform primary link break on connection_id: ${cross_connection}  console=True
    Remove Cross Connection By Id  ${cross_connection}
    Get Current Time  link_break
    ${cross_connection_status}=  Get Cross Connection Status by Id  ${cross_connection}
    Run Keyword If  ${cross_connection_status}  Run Keywords
    ...  Log  Primary Link break failed: Cross Connection ${cross_connection} on BTS ${alias} was not removed in Optical Switch  console=True
    ...  AND  Fail  Link break failed
    ...  ELSE
    ...  Log  Primary Link break successfully performed: Cross Connection ${cross_connection} on BTS ${alias} was removed in Optical Switch
    ...  console=True

Perform RMOD primary link restore
    [Arguments]  ${cross_connection}  ${alias}

    Log  Perform link restore for connection_id: ${cross_connection}  console=True
    Create Cross Connection with Options by Id  new_connection=${cross_connection}  group=${options['group']}  conn=${options['connid']}
    ...  dir=${options['dir'].lower()}  band=${options['band'][0]}  nolight=${options['nolight']}  deadreckon=${options['deadreckon']}
    Get Current Time  link_restore
    ${cross_connection_status}=  Get Cross Connection Status by Id  ${cross_connection}
    Run Keyword If  ${cross_connection_status}
    ...  Log  Link restore successfully performed: link for connection_id: ${cross_connection} on BTS ${alias} was created in Optical Switch
    ...  console=True
    ...  ELSE  Run Keywords
    ...  Log  Link restore failed: link for connection_id: ${cross_connection} on BTS ${alias} was not created in Optical Switch  console=True
    ...  AND  Fail  Link restore failed

Check CPRI RMOD state and alarms after primary link break
    [Arguments]  ${RMOD_sn}  ${alias}  ${peer_alias}

    Log  Check initial alarms after primary link break for CPRI shared RMOD with ${RMOD_sn}  console=True
    ${BTS_IGNORED_ALARMS}=  Combine Lists
    ...  ${${alias.upper()}_IGNORED_ALARMS}  ${${alias.upper()}_IGNORED_ALARMS_4003}  ${${alias.upper()}_IGNORED_ALARMS_4220}
    ${peer_BTS_IGNORED_ALARMS}=  Combine Lists
    ...  ${${peer_alias.upper()}_IGNORED_ALARMS}  ${${peer_alias.upper()}_IGNORED_ALARMS_4003}  ${${peer_alias.upper()}_IGNORED_ALARMS_4220}

    Log  BTS ${alias} "Not able to synchronize baseband bus (1815)" alarm, expected number: 1  console=True
    Get and Check Alarms SOAM  alias=${alias}  poll_interval=5 sec  expected_alarms=${${alias.upper()}_EXPECTED_ALARMS_1815}
    ...  ignored_alarms=${BTS_IGNORED_ALARMS}  critical_alarms=${${alias.upper()}_CRITICAL_ALARMS}
    Log  BTS ${alias} "Not able to synchronize baseband bus (1815)" alarm, found number: 1  console=True

    Log  BTS ${peer_alias} "Not able to synchronize baseband bus (1815)" alarm, expected number: 1  console=True
    Get and Check Alarms SOAM  alias=${peer_alias}  poll_interval=5 sec  expected_alarms=${${peer_alias.upper()}_EXPECTED_ALARMS_1815}
    ...  ignored_alarms=${peer_BTS_IGNORED_ALARMS}  critical_alarms=${${peer_alias.upper()}_CRITICAL_ALARMS}
    Log  BTS ${peer_alias} "Not able to synchronize baseband bus (1815)" alarm, found number: 1  console=True

    Sleep  120s  reason=Avoid CPRI RMOD transitory states on both BTS
    Check peer RMOD and cells state after primary link break  ${RMOD_sn}  ${peer_alias}
    Check RMOD and cells state after primary link break  ${RMOD_sn}  ${alias}

Check ECPRI RMOD state and alarms after primary link break
    [Arguments]  ${RMOD_sn}  ${alias}  ${peer_alias}

    Log  Check initial alarms after primary link break for ECPRI shared RMOD with ${RMOD_sn}  console=True

    ${peer_BTS_IGNORED_ALARMS}=  Combine Lists
    ...  ${${peer_alias.upper()}_IGNORED_ALARMS}  ${${peer_alias.upper()}_IGNORED_ALARMS_4003}  ${${peer_alias.upper()}_IGNORED_ALARMS_4220}

    Log  BTS ${peer_alias} "Unit synchronization failed (16)" alarm, expected number: 1  console=True
    Get and Check Alarms SOAM  alias=${peer_alias}  expected_alarms=${${peer_alias.upper()}_EXPECTED_ALARMS_16}
    ...  ignored_alarms=${peer_BTS_IGNORED_ALARMS}  critical_alarms=${${peer_alias.upper()}_CRITICAL_ALARMS}
    Log  BTS ${peer_alias} "Unit synchronization failed (16)" alarm, found number: 1  console=True

    Check peer RMOD and cells state after primary link break  ${RMOD_sn}  ${peer_alias}
    Check RMOD and cells state after primary link break  ${RMOD_sn}  ${alias}

Check OBSAI RMOD state and alarms after primary link break
    [Arguments]  ${RMOD_sn}  ${alias}  ${peer_alias}

    Log  Check initial alarms after primary link break for OBSAI shared RMOD with ${RMOD_sn}  console=True

    ${peer_BTS_IGNORED_ALARMS}=  Combine Lists
    ...  ${${peer_alias.upper()}_IGNORED_ALARMS}  ${${peer_alias.upper()}_IGNORED_ALARMS_4003}  ${${peer_alias.upper()}_IGNORED_ALARMS_4220}

    Log  BTS ${peer_alias} "No connection to unit (10)" alarm, expected number: 1  console=True
    Get and Check Alarms SOAM  alias=${peer_alias}  expected_alarms=${${peer_alias.upper()}_EXPECTED_ALARMS_10}
    ...  ignored_alarms=${peer_BTS_IGNORED_ALARMS}  critical_alarms=${${peer_alias.upper()}_CRITICAL_ALARMS}
    Log  BTS ${peer_alias} "No connection to unit (10)" alarm, found number: 1  console=True

    Check peer RMOD and cells state after primary link break  ${RMOD_sn}  ${peer_alias}
    Check RMOD and cells state after primary link break  ${RMOD_sn}  ${alias}

Check RMOD and cells state after primary link break
    [Arguments]  ${RMOD_sn}  ${alias}

    Check RMOD State  RMOD_sn=${RMOD_sn}  rmod_state_check=${RMOD_state_disabled_check}  rmod_state=${RMOD_state_disabled}
    ...  timeout=30  alias=${alias}

    Wait Until Keyword Succeeds  30 sec  10 sec  Check cells state mapped on shared RMOD  ${RMOD_sn}  ${alias}
    Check cell state not mapped on shared RMOD  ${RMOD_sn}  ${alias}

    ${BTS_IGNORED_ALARMS}=  Combine Lists  ${${alias.upper()}_IGNORED_ALARMS}  ${${alias.upper()}_IGNORED_ALARMS_4220}
    ...  ${${alias.upper()}_IGNORED_ALARMS_4003}

    Log  Check BTS ${alias} alarms on RM with SN ${RMOD_sn} after primary link break:  console=True
    Log  BTS ${alias} "No connection to unit (10)" alarm, expected number: 1  console=True

    Get and Check Alarms SOAM  alias=${alias}  expected_alarms=${${alias.upper()}_EXPECTED_ALARMS_10}
    ...  ignored_alarms=${BTS_IGNORED_ALARMS}  critical_alarms=${${alias.upper()}_CRITICAL_ALARMS}

    Log  BTS ${alias} "No connection to unit (10)" alarm, found number: 1  console=True
    Log  BTS ${alias} site - expected, ignored and critical alarms checked  console=True

Check peer RMOD and cells state after primary link break
    [Arguments]  ${RMOD_sn}  ${peer_alias}

    ${remained_MAX_WAIT_TIME}=  Get elapsed time  ${time_link_break}  ${RM_MAX_WAIT_TIME_Link_Break}
    Check RMOD State  RMOD_sn=${RMOD_sn}  rmod_state_check=${RMOD_state_enabled_check}  rmod_state=${RMOD_state_enabled}
    ...  timeout=${remained_MAX_WAIT_TIME}  alias=${peer_alias}
    Log  Primary link for RMOD with SN ${RMOD_sn} succesfully switched on BTS ${peer_alias}  console=True

    Log  Check BTS ${peer_alias} cells mapped on RM with SN ${RMOD_sn} after primary link break  console=True
    ${remained_MAX_WAIT_TIME}=  Get elapsed time  ${time_link_break}  ${RM_MAX_WAIT_TIME_Link_Break}
    Run Keyword If  ${${peer_alias}_NR_CELL_RMOD_list}
    ...  Check Cell State
    ...  NRCEL  ${${peer_alias}_NR_CELL_RMOD_list}  ${CELL_state_enabled_check}  ${CELL_state_enabled}  ${remained_MAX_WAIT_TIME}  ${peer_alias}
    ${remained_MAX_WAIT_TIME}=  Get elapsed time  ${time_link_break}  ${RM_MAX_WAIT_TIME_Link_Break}
    Run Keyword If  ${${peer_alias}_LTE_CELL_RMOD_list}
    ...  Check Cell State
    ...  LNCEL  ${${peer_alias}_LTE_CELL_RMOD_list}  ${CELL_state_enabled_check}  ${CELL_state_enabled}  ${remained_MAX_WAIT_TIME}  ${peer_alias}
    ${remained_MAX_WAIT_TIME}=  Get elapsed time  ${time_link_break}  ${RM_MAX_WAIT_TIME_Link_Break}
    Run Keyword If  ${${peer_alias}_WCDMA_CELL_RMOD_list}
    ...  Check Cell State  WNCEL  ${${peer_alias}_WCDMA_CELL_RMOD_list}  ${CELL_state_enabled_check}  ${CELL_state_enabled}
    ...  ${remained_MAX_WAIT_TIME}  ${peer_alias}
    ${remained_MAX_WAIT_TIME}=  Get elapsed time  ${time_link_break}  ${RM_MAX_WAIT_TIME_Link_Break}
    Run Keyword If  ${${peer_alias}_GSM_CELL_RMOD_list}
    ...  Check Cell State  GNCEL  ${${peer_alias}_GSM_CELL_RMOD_list}  ${CELL_state_enabled_check}  ${CELL_state_enabled}
    ...  ${remained_MAX_WAIT_TIME}  ${peer_alias}
    Log  All BTS ${peer_alias} cells mapped on RMOD with SN ${RMOD_sn} status as expected!  console=True

    Check cell state not mapped on shared RMOD  ${RMOD_sn}  ${peer_alias}

    ${peer_BTS_IGNORED_ALARMS}=  Combine Lists  ${${peer_alias.upper()}_IGNORED_ALARMS}  ${${peer_alias.upper()}_IGNORED_ALARMS_4220}
    Log  Check BTS ${peer_alias} alarms after primary link break:  console=True
    Get and Check Alarms SOAM  alias=${peer_alias}  expected_alarms=@{EMPTY}
    ...  ignored_alarms=${peer_BTS_IGNORED_ALARMS}  critical_alarms=${${peer_alias.upper()}_CRITICAL_ALARMS}
    Log  BTS ${peer_alias} site - expected, ignored and critical alarms checked  console=True

Check RMOD and cells state after link restore
    [Arguments]  ${RMOD_sn}  ${alias}

    ${remained_MAX_WAIT_TIME}=  Get elapsed time  ${time_link_restore}  ${RM_MAX_WAIT_TIME_Link_Restore}
    Check RMOD State  RMOD_sn=${RMOD_sn}  rmod_state_check=${RMOD_state_enabled_check}  rmod_state=${RMOD_state_enabled}
    ...  timeout=${remained_MAX_WAIT_TIME}  alias=${alias}

    Log  Check BTS ${alias} cells mapped on RM with SN ${RMOD_sn} after link restore  console=True
    ${remained_MAX_WAIT_TIME}=  Get elapsed time  ${time_link_restore}  ${RM_MAX_WAIT_TIME_Link_Restore}
    Run Keyword If  ${${alias}_NR_CELL_RMOD_list}
    ...  Check Cell State
    ...  NRCEL  ${${alias}_NR_CELL_RMOD_list}  ${CELL_state_enabled_check}  ${CELL_state_enabled}  ${remained_MAX_WAIT_TIME}  ${alias}
    ${remained_MAX_WAIT_TIME}=  Get elapsed time  ${time_link_restore}  ${RM_MAX_WAIT_TIME_Link_Restore}
    Run Keyword If  ${${alias}_LTE_CELL_RMOD_list}
    ...  Check Cell State
    ...  LNCEL  ${${alias}_LTE_CELL_RMOD_list}  ${CELL_state_enabled_check}  ${CELL_state_enabled}  ${remained_MAX_WAIT_TIME}  ${alias}
    ${remained_MAX_WAIT_TIME}=  Get elapsed time  ${time_link_restore}  ${RM_MAX_WAIT_TIME_Link_Restore}
    Run Keyword If  ${${alias}_WCDMA_CELL_RMOD_list}
    ...  Check Cell State  WNCEL  ${${alias}_WCDMA_CELL_RMOD_list}  ${CELL_state_enabled_check}  ${CELL_state_enabled}
    ...  ${remained_MAX_WAIT_TIME}  ${alias}
    ${remained_MAX_WAIT_TIME}=  Get elapsed time  ${time_link_restore}  ${RM_MAX_WAIT_TIME_Link_Restore}
    Run Keyword If  ${${alias}_GSM_CELL_RMOD_list}
    ...  Check Cell State  GNCEL  ${${alias}_GSM_CELL_RMOD_list}  ${CELL_state_enabled_check}  ${CELL_state_enabled}
    ...  ${remained_MAX_WAIT_TIME}  ${alias}
    Log  All BTS ${alias} cells mapped on RMOD with SN ${RMOD_sn} status as expected!  console=True

    ${remained_MAX_WAIT_TIME}=  Get elapsed time  ${time_link_restore}  ${RM_MAX_WAIT_TIME_Link_Restore}
    Check cells availability status online  ${alias}  ${remained_MAX_WAIT_TIME}
    Check cell state not mapped on shared RMOD  ${RMOD_sn}  ${alias}

    Log  Check BTS ${alias} alarms after link restore:  console=True
    Get and Check Alarms SOAM  alias=${alias}  expected_alarms=@{EMPTY}
    ...  ignored_alarms=${${alias.upper()}_IGNORED_ALARMS}  critical_alarms=${${alias.upper()}_CRITICAL_ALARMS}
    Log  BTS ${alias} site - expected, ignored and critical alarms checked  console=True

Check RMOD State
    [Arguments]   ${RMOD_sn}  ${rmod_state_check}  ${rmod_state}  ${timeout}  ${alias}
    ${RMOD_id}=  Get From Dictionary  ${${alias}_module_SN_ID_dict}  ${RMOD_sn}
    Log  Check BTS ${alias} RM with SN ${RMOD_sn}:  console=True
    Assert  class_name=RMOD  id=${RMOD_id}  parameters=${rmod_state_check}  timeout=${timeout}  connection=${alias}
    Log  BTS ${alias} RM with SN ${RMOD_sn} status:\n - ${rmod_state}  console=True

Check cells state mapped on shared RMOD
    [Arguments]  ${RMOD_sn}  ${alias}

    Log  Check BTS ${alias} cells status mapped on RM with SN ${RMOD_sn} after primary link break:  console=True

    ${NR_cell_state_degraded_list}  ${NR_cell_state_failed_list}=  Run Keyword If  ${${alias}_NR_CELL_RMOD_list}
    ...  Check NR cells state and MIMO alarm  cell_list=${${alias}_NR_CELL_RMOD_list}  alias=${alias}

    ${LTE_cell_state_degraded_list}  ${LTE_cell_state_failed_list}=  Run Keyword If  ${${alias}_LTE_CELL_RMOD_list}
    ...  Check LTE cells state and MIMO alarm  cell_list=${${alias}_LTE_CELL_RMOD_list}  alias=${alias}

    ${WCDMA_cell_state_degraded_list}  ${WCDMA_cell_state_failed_list}=  Run Keyword If  ${${alias}_WCDMA_CELL_RMOD_list}
    ...  Check WCDMA cells state and MIMO alarm  cell_list=${${alias}_WCDMA_CELL_RMOD_list}  alias=${alias}

    ${GSM_cell_state_degraded_list}  ${GSM_cell_state_failed_list}=  Run Keyword If  ${${alias}_GSM_CELL_RMOD_list}
    ...  Check GSM cells state and MIMO alarm  cell_list=${${alias}_GSM_CELL_RMOD_list}  alias=${alias}

Check cell state not mapped on shared RMOD
    [Arguments]  ${RMOD_sn}  ${alias}

    Log  Check BTS ${alias} cells not mapped on RM with SN ${RMOD_sn}  console=True
    Run Keyword If  ${${alias}_NR_CELL_not_RMOD_list}
    ...  Check Cell State  NRCEL  ${${alias}_NR_CELL_not_RMOD_list}  ${CELL_state_enabled_check}  ${CELL_state_enabled}  3  ${alias}
    Run Keyword If  ${${alias}_LTE_CELL_not_RMOD_list}
    ...  Check Cell State  LNCEL  ${${alias}_LTE_CELL_not_RMOD_list}  ${CELL_state_enabled_check}  ${CELL_state_enabled}  3  ${alias}
    Run Keyword If  ${${alias}_WCDMA_CELL_not_RMOD_list}
    ...  Check Cell State  WNCEL  ${${alias}_WCDMA_CELL_not_RMOD_list}  ${CELL_state_enabled_check}  ${CELL_state_enabled}  3  ${alias}
    Run Keyword If  ${${alias}_GSM_CELL_not_RMOD_list}
    ...  Check Cell State  GNCEL  ${${alias}_GSM_CELL_not_RMOD_list}  ${CELL_state_enabled_check}  ${CELL_state_enabled}  3  ${alias}
    Log  All BTS ${alias} cells not mapped on RMOD with SN ${RMOD_sn} status as expected!  console=True

Check Cell State
    [Arguments]   ${cell_class_name}  ${cell_list}  ${cell_state_check}  ${cell_state}  ${timeout}  ${alias}
    FOR  ${item}  IN  @{cell_list}
        Assert  class_name=${cell_class_name}  id=${item}  parameters=${cell_state_check}  timeout=${timeout}  connection=${alias}
        Log  BTS ${alias} ${cell_class_name} ${item} status:\n - ${cell_state}  console=True
    END

Check alias of primary link
    [Arguments]  ${RMOD_sn}
    FOR  ${alias}  IN  @{alias_list}
        Get Cross Connections for RMOD  ${RMOD_sn}  ${alias}
        ${primary_link_check}=  Run keyword and return status
        ...  Dictionary Should Contain Value  ${${alias}_Cross_connection_linkModeSynchronization_dict}  ${True}
        Run Keyword If  ${primary_link_check}  Run Keywords
        ...  Log  Primary link is on RMOD_${RMOD_sn} from BTS ${alias}  console=True
        ...  AND  Return From Keyword  ${alias}
    END

Get Cross Connections for RMOD
    [Arguments]  ${RMOD_sn}  ${alias}
    Get links between SMOD/BBMOD and RMOD  ${RMOD_sn}  ${alias}
    ${Cross_connection_linkModeSynchronization_dict}=  Create Dictionary
    ${Cross_connection_options_dict}=  Create Dictionary
    Set Test Variable  ${${alias}_Cross_connection_linkModeSynchronization_dict}  ${Cross_connection_linkModeSynchronization_dict}
    Set Test Variable  ${${alias}_Cross_connection_options_dict}  ${Cross_connection_options_dict}
    FOR  ${item}  IN  @{RMOD_firstEndpointDN_info_list}
        ${firstEndpoint_param}=  coam.Get Parameters  ${item}  connection=${alias}
        ${firstEndpoint_sn}=  Set Variable  ${firstEndpoint_param['serialNumber']}
        ${firstEndpoint_connectorLabel_list}=  Get Dictionary Keys  ${${firstEndpoint_sn}_${RMOD_sn}_connectorLabel}
        Get cross connection info  ${item}  ${firstEndpoint_sn}  ${RMOD_sn}  ${firstEndpoint_connectorLabel_list}  ${alias}
    END

Get module type
    [Arguments]  ${firstEndpointDN}
    ${SMOD_check}=  Run Keyword And Return Status  Should Contain  ${firstEndpointDN}  SMOD_R
    ${BBMOD_check}=  Run Keyword And Return Status  Should Contain  ${firstEndpointDN}  BBMOD_R
    ${module_type}=  Set Variable If  '${SMOD_check}' == 'True'  SMOD  '${BBMOD_check}' == 'True'  BBMOD
    [Return]  ${module_type}

Get cross connection info
    [Arguments]  ${firstEndpoint_id}  ${firstEndpoint_sn}  ${RMOD_sn}  ${firstEndpoint_connectorLabel_list}  ${alias}
    ${module_type}=  Get module type  ${firstEndpoint_id}
    FOR  ${firstEndpoint_connectorLabel}  IN  @{firstEndpoint_connectorLabel_list}
        ${RMOD_connectorLabel}=  Get From Dictionary  ${${firstEndpoint_sn}_${RMOD_sn}_connectorLabel}  ${firstEndpoint_connectorLabel}
        Check Optical Switch definition info  ${module_type}  ${firstEndpoint_sn}  ${firstEndpoint_connectorLabel}
        Check Optical Switch definition info  RMOD  ${RMOD_sn}  ${RMOD_connectorLabel}
        ${linkModeSynchronization_value}=  Get From Dictionary
        ...  ${${RMOD_sn}_${firstEndpoint_sn}_connectorLabel_linkModeSynchronization_dict}  ${RMOD_connector_label}
        ${cross_connection_id}=  Get Cross Connection Id
        ...  first_port=${${module_type}_${firstEndpoint_sn}_${firstEndpoint_connectorLabel}_cross_connection}
        ...  second_port=${RMOD_${RMOD_sn}_${RMOD_connector_label}_cross_connection}
        Set To Dictionary  ${${alias}_Cross_connection_linkModeSynchronization_dict}  ${cross_connection_id}  ${linkModeSynchronization_value}
        ${options}=  Get Cross Connection details  ${cross_connection_id}
        Set To Dictionary  ${${alias}_Cross_connection_options_dict}  ${cross_connection_id}  ${options}
    END

Get links between SMOD/BBMOD and RMOD
    [Arguments]  ${RMOD_sn}  ${alias}
    ${RMOD_id}=  Get From Dictionary  ${${alias}_module_SN_ID_dict}  ${RMOD_sn}
    ${CABLINK_R_info}=  coam.Get Managed Objects  class_name=CABLINK_R  connection=${alias}
    ${RMOD_id_firstEndpointDN_info_dict}=  Get specific MODULE firstEndpointDN info dict  ${RMOD_id}  ${CABLINK_R_info}
    ${RMOD_firstEndpointDN_info_list}=  Get From Dictionary  ${RMOD_id_firstEndpointDN_info_dict}  ${RMOD_id}
    Set Test Variable  ${RMOD_firstEndpointDN_info_list}
    FOR  ${item}  IN  @{RMOD_firstEndpointDN_info_list}
        ${firstEndpoint_param}=  coam.Get Parameters  ${item}  connection=${alias}
        ${firstEndpoint_sn}=  Set Variable  ${firstEndpoint_param['serialNumber']}
        ${firstModule_connectorLabel_linkModeSynchronization_dict}  ${secondModule_connectorLabel_linkModeSynchronization_dict}
        ...  ${firstModule_connectorLabel_linkModeConfiguration_dict}  ${secondModule_connectorLabel_linkModeConfiguration_dict}
        ...  ${firstModule_secondModule_connectorLabel}
        ...  ${secondModule_firstModule_connectorLabel}=  Get linkModeSynchronization and linkModeConfiguration info dict
        ...  ${firstEndpoint_sn}  ${RMOD_sn}  ${alias}
        Set Test Variable  ${${firstEndpoint_sn}_${RMOD_sn}_connectorLabel_linkModeSynchronization_dict}
        ...  ${firstModule_connectorLabel_linkModeSynchronization_dict}
        Set Test Variable  ${${RMOD_sn}_${firstEndpoint_sn}_connectorLabel_linkModeSynchronization_dict}
        ...  ${secondModule_connectorLabel_linkModeSynchronization_dict}
        Set Test Variable  ${${RMOD_sn}_${firstEndpoint_sn}_connectorLabel_linkModeConfiguration_dict}
        ...  ${secondModule_connectorLabel_linkModeConfiguration_dict}
        Set Test Variable  ${${firstEndpoint_sn}_${RMOD_sn}_connectorLabel}  ${firstModule_secondModule_connectorLabel}
        Set Test Variable  ${${RMOD_sn}_${firstEndpoint_sn}_connectorLabel}  ${secondModule_firstModule_connectorLabel}
    END

Setup for Optical Switch
    Optical Switch Setup  switch_ip=${OPTICAL_SWITCH['IP']}  switch_username=${OPTICAL_SWITCH['USERNAME']}
    ...  switch_password=${OPTICAL_SWITCH['PASSWORD']}  port=${OPTICAL_SWITCH['PORT']}

Check RM serial number list
    ${RMOD_SN_list_strip}=  Replace String  ${RMOD_SN_list}  ${SPACE}  ${EMPTY}
    ${RMOD_SN_list}=  Split String  ${RMOD_SN_list_strip}  ,
    ${RM_sn_check}=  Set Variable  True
    ${RM_SN_invalide_list}=  Create List
    FOR  ${item}  IN  @{RMOD_SN_list}
        ${RM_sn_check}=  Set Variable If  '${item}' not in ${shared_RMOD_sn_list}  False  ${RM_sn_check}
        Run Keyword If  '${item}' not in ${shared_RMOD_sn_list}  Append To List  ${RM_sn_invalid_list}  ${item}
    END
    Run Keyword If  '${RM_sn_check}' == 'False'  Run Keywords
    ...  Log  Following selected RM serial number values are not valid: ${RM_sn_invalid_list}.  console=True
    ...  AND  Log  Please select values for test argument \${RMOD_SN_list} from configured RM: ${shared_RMOD_sn_list}
    ...  console=True
    ...  AND  Fail  Improper value for argument!
    Set Test Variable  ${shared_RMOD_sn_list}  ${RMOD_SN_list}

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

Get shared RMOD CELL dict
    [Arguments]   ${alias}
    ${shared_RMOD_CELL_dict}=  Create Dictionary
    FOR  ${item}  IN  @{${alias}_shared_RMOD_list}
        ${CELL_list}=  Get Cell Mapping By Module Id  module_id=${item}  connection=${alias}
        Sort List  ${CELL_list}
        Set To Dictionary  ${shared_RMOD_CELL_dict}  ${item}  ${CELL_list}
    END
    Set Test Variable  ${${alias}_shared_RMOD_CELL_dict}  ${shared_RMOD_CELL_dict}

Get shared RMOD cells
    [Arguments]  ${RMOD_sn}  ${alias}
    ${RMOD_id}=  Get From Dictionary  ${${alias}_module_SN_ID_dict}  ${RMOD_sn}
    ${CELL_RMOD_list}=  Get From Dictionary  ${${alias}_shared_RMOD_CELL_dict}  ${RMOD_id}
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
    Set Test Variable  ${${alias}_CELL_RMOD_list}  ${CELL_RMOD_list}
    Set Test Variable  ${${alias}_NR_CELL_RMOD_list}  ${NR_CELL_RMOD_list}
    Set Test Variable  ${${alias}_LTE_CELL_RMOD_list}  ${LTE_CELL_RMOD_list}
    Set Test Variable  ${${alias}_WCDMA_CELL_RMOD_list}  ${WCDMA_CELL_RMOD_list}
    Set Test Variable  ${${alias}_GSM_CELL_RMOD_list}  ${GSM_CELL_RMOD_list}
    Log  BTS ${alias} cells mapped on shared RMOD with SN ${RMOD_sn}:  console=True
    Run Keyword If  ${NR_CELL_RMOD_list}  Log  - NRCEL: ${NR_CELL_RMOD_list}  console=True
    Run Keyword If  ${LTE_CELL_RMOD_list}  Log  - LNCEL: ${LTE_CELL_RMOD_list}  console=True
    Run Keyword If  ${WCDMA_CELL_RMOD_list}  Log  - WNCEL: ${WCDMA_CELL_RMOD_list}  console=True
    Run Keyword If  ${GSM_CELL_RMOD_list}  Log  - GNCEL: ${GSM_CELL_RMOD_list}  console=True

    ${NR_CELL_not_RMOD_list}=  Copy List  ${${alias}_NR_CELL_list}
    ${LTE_CELL_not_RMOD_list}=  Copy List  ${${alias}_LTE_CELL_list}
    ${WCDMA_CELL_not_RMOD_list}=  Copy List  ${${alias}_WCDMA_CELL_list}
    ${GSM_CELL_not_RMOD_list}=  Copy List  ${${alias}_GSM_CELL_list}
    FOR  ${item}  IN  @{${alias}_CELL_RMOD_list}
        Remove Values From List  ${NR_CELL_not_RMOD_list}  ${item}
        Remove Values From List  ${LTE_CELL_not_RMOD_list}  ${item}
        Remove Values From List  ${WCDMA_CELL_not_RMOD_list}  ${item}
        Remove Values From List  ${GSM_CELL_not_RMOD_list}  ${item}
    END
    Set Test Variable  ${${alias}_NR_CELL_not_RMOD_list}  ${NR_CELL_not_RMOD_list}
    Set Test Variable  ${${alias}_LTE_CELL_not_RMOD_list}  ${LTE_CELL_not_RMOD_list}
    Set Test Variable  ${${alias}_WCDMA_CELL_not_RMOD_list}  ${WCDMA_CELL_not_RMOD_list}
    Set Test Variable  ${${alias}_GSM_CELL_not_RMOD_list}  ${GSM_CELL_not_RMOD_list}

Step ${index}: Check final number and state of Cells and RMs
    [Documentation]
    ...  Cells state is checked according to operationalState attribute
    ...  Check if number of configured cells and radio modules in SCF are properly mapping on BTS running view.
    ...  Also check RMs operationalState

    [Timeout]  30 min
    Log  Step ${index}: Check final number and state of Cells and RMs  console=True
    RFS Test Case Final Checks

Check if Cross Connection is created in Optical Switch
    [Arguments]  ${cross_connection}
    ${cross_connection_status}=  Get Cross Connection Status by Id  ${cross_connection}
    Run Keyword If  '${cross_connection_status}' == 'False'  Run Keywords
    ...  Create Cross Connection with Options by Id  ${cross_connection}  group=${options['group']}  conn=${options['connid']}
    ...  dir=${options['dir'].lower()}  band=${options['band'][0]}  nolight=${options['nolight']}  deadreckon=${options['deadreckon']}
    ...  AND  Log  Create Cross Connection ${cross_connection} in Optical Switch indicated  console=True
    [Teardown]  Teardown Optical Switch

Particular Teardown
    Check if Cross Connection is created in Optical Switch  ${cross_connection}

TC Setup
    ${tech_preset_list}=  Create List  SBTS  SBTS
    Common Test Setup  preset_techs=${tech_preset_list}  common_sbts=${TRUE}  infomodelSetup=${FALSE}

TC Teardown
    Common Test Teardown