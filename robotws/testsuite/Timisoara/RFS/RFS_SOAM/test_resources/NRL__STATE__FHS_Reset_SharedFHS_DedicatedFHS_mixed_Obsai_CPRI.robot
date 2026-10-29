*** Settings ***
Documentation    TC__NRL__STATE__FHS_Reset_SharedFHS_DedicatedFHS_mixed_Obsai_CPRI
Variables    tc_variables/nrl__state__fhs_reset_sharedfhs_dedicatedfhs_mixed_obsai_cpri_alarms_definitions.py
Resource    ../../resources/rfs_frame_rfs_soam_taf.robot

*** Variables ***
${REPEAT_COUNTER}  3     # Number of NR shared FHS reset operations, default value 3
${FHS_TO_RESET}   All    # The FHS's to be reset. Possible values: All, Shared, Dedicated

*** Keywords ***
TC__NRL__STATE__FHS_Reset_SharedFHS_DedicatedFHS_mixed_Obsai_CPRI
     [Documentation]
    ...  [CASE LINK]: https://jiradc.ext.net.nokia.com/browse/TAT-24253
    ...
    ...  *****************
    ...  Basic information
    ...  *****************
    ...  NR-LTE test case for shared and dedicated FHS reset operations, - x times sequence.
    ...  x - value of REPEAT_COUNTER parameter (default: 3)
    ...  The main steps performed for the test are:
    ...  - check initial state and alarms for both BTS
    ...  - prepare FHS list and related RMOD and cells info for both BTS
    ...  - perform Reset operation on each shared FHS checking state and alarms for both BTS
    ...  - perform Reset operation on each dedicated FHS checking state and alarms for BTS
    ...  - check final state and alarms for both both BTS
    ...  Pass criteria: Reset FHS operation works as expected, states and alarms are as expected
    ...
    ...  ******************
    ...  History of changes
    ...  ******************
    ...  - 14.02.2023 - https://jiradc.ext.net.nokia.com/browse/TAT-24253 - [5G][CB008470]
    ...  5G_RFS_FHS_reset_mixed_OBSAI_CPRI_2_cases_FHS_dedicated_and FHS_shared
    ...  - 25.10.2023 - https://jiradc.ext.net.nokia.com/browse/TAT-26234 - [5G] Use new DSS mechanism in existing TCs - Site Reset NRL SharedFHS,
    ...  mixed Obsai CPRI
    ...  - 05.04.2024 - https://jiradc.ext.net.nokia.com/browse/TAT-27113 - [5G] [DSS] Remove usage of actLteNrDss_ from
    ...  NRL__STATE__FHS_Reset_SharedFHS_DedicatedFHS_mixed_Obsai_CPRI
    ...  - 02.08.2024 - https://jiradc.ext.net.nokia.com/browse/TAT-27823 - [CNI-127210] [Part 2] DSS LTE EXPECTED alarms check removal NR_* TCs
    ...  - after DSS discussion is concluded
    ...  - 17.04.2025 - https://jiradc.ext.net.nokia.com/browse/TAT-29018 - [REFACTORING][ALARMS] Remove legacy SOAM alarms in Test_Cases and
    ...  Alarm Files - NRL TCs
    ...  - 11.09.2025 - https://jiradc.ext.net.nokia.com/browse/TAT-29834 - Update KW for BBMOD CELL mapping based on BBPOOL info
    ...  - 16.09.2025 - https://jiradc.ext.net.nokia.com/browse/TAT-29822 -
    ...  Unify alarm list names in order alarm list to begin with upper case Alias - NRL
    ...
    ...  *******************
    ...  Test case flowchart
    ...  *******************
    ...  .. image:: https://gitlabe1.ext.net.nokia.com/panda-docs/hran_doc/-/blob/master/testsuite/RFS_SOAM/
    ...  TAT-24253_NRL__STATE__FHS_Reset_SharedFHS_DedicatedFHS_mixed_Obsai_CPRI.png

    Set Tags    CA-STATE    OWNER-felician.ghitoaica@nokia.com    AUTHOR-horea.olar@nokia.com    PHASE-QT    SW-SBTS23R2

    Step 1: Check initial all BTS state
    Step 2: Check initial all BTS alarms
    Step 3: Get FHS info
    FOR  ${INDEX}  IN RANGE  1  ${REPEAT_COUNTER}+1
        Log  ==============================================================================  console=True
        Log  Start Cycle ${INDEX} of ${REPEAT_COUNTER}  console=True
        Log  ==============================================================================  console=True
        Step 4: Perform FHS reset operation
        Step 5: Check final all BTS state
        Step 6: Check final all BTS alarms
        Step 7: Check both BTS reset behavior based on IMS info
        Step 8: Check final number and state of Cells and RMs
    END

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

Step ${index}: Get FHS info
    [Documentation]
    ...  BTS info are related to shared FHS, BBMOD, RMOD and cells

    [Timeout]  5 min
    Log  Step ${index}: Get FHS info and related BBMOD, RMOD and cells info for both BTS  console=True

    ${Master_shared_FHS_list}  ${Slave_shared_FHS_list}  ${Master_dedicated_FHS_list}  ${Slave_dedicated_FHS_list}=
    ...  Admin Get shared and dedicated module list for Master and Slave  FHS  Master  Slave
    Set Test Variable  ${Master_shared_FHS_list}
    Set Test Variable  ${Slave_shared_FHS_list}
    Set Test Variable  ${Master_dedicated_FHS_list}
    Set Test Variable  ${Slave_dedicated_FHS_list}
    ${shared_FHS_count}=  Get Length  ${Master_shared_FHS_list}

    Get FHS ID SN dict  Master
    Get FHS ID SN dict  Slave
    Set Test Variable  ${Master_FHS_SN_ID_dict}  ${Master_module_SN_ID_dict}
    Set Test Variable  ${Master_FHS_ID_SN_dict}  ${Master_module_ID_SN_dict}
    Set Test Variable  ${Slave_FHS_SN_ID_dict}  ${Slave_module_SN_ID_dict}
    Set Test Variable  ${Slave_FHS_ID_SN_dict}  ${Slave_module_ID_SN_dict}

    Get BTS primary controller shared FHS list  Master
    Get BTS primary controller shared FHS list  Slave
    Get BTS secondary controller shared FHS list  Master
    Get BTS secondary controller shared FHS list  Slave

    ${BBMOD_CELL_dict}=  Get BBMOD CELL mapping based on BBPOOL info from SCF  Master
    Set Test Variable  ${Master_BBMOD_CELL_dict}  ${BBMOD_CELL_dict}
    ${BBMOD_CELL_dict}=  Get BBMOD CELL mapping based on BBPOOL info from SCF  Slave
    Set Test Variable  ${Slave_BBMOD_CELL_dict}  ${BBMOD_CELL_dict}

    ${Master_shared_FHS_RMOD_dict}=  Get FHS RMOD dict  ${Master_shared_FHS_list}  Master
    ${Slave_shared_FHS_RMOD_dict}=  Get FHS RMOD dict  ${Slave_shared_FHS_list}  Slave
    ${Master_dedicated_FHS_RMOD_dict}=  Get FHS RMOD dict  ${Master_dedicated_FHS_list}  Master
    ${Slave_dedicated_FHS_RMOD_dict}=  Get FHS RMOD dict  ${Slave_dedicated_FHS_list}  Slave
    Set Test Variable  ${Master_shared_FHS_RMOD_dict}
    Set Test Variable  ${Slave_shared_FHS_RMOD_dict}
    Set Test Variable  ${Master_dedicated_FHS_RMOD_dict}
    Set Test Variable  ${Slave_dedicated_FHS_RMOD_dict}

    ${Master_shared_FHS_CELL_dict}=  Get FHS CELL dict  ${Master_shared_FHS_list}  Master
    ${Slave_shared_FHS_CELL_dict}=  Get FHS CELL dict  ${Slave_shared_FHS_list}  Slave
    ${Master_dedicated_FHS_CELL_dict}=  Get FHS CELL dict  ${Master_dedicated_FHS_list}  Master
    ${Slave_dedicated_FHS_CELL_dict}=  Get FHS CELL dict  ${Slave_dedicated_FHS_list}  Slave
    Set Test Variable  ${Master_shared_FHS_CELL_dict}
    Set Test Variable  ${Slave_shared_FHS_CELL_dict}
    Set Test Variable  ${Master_dedicated_FHS_CELL_dict}
    Set Test Variable  ${Slave_dedicated_FHS_CELL_dict}

    Check if DSS is configured

Get BTS primary controller shared FHS list
    [Arguments]  ${alias}
    ${BTS_primary_controller_FHS_list}=  Get FHS primaryController info  alias=${alias}
    ${BTS_primary_controller_shared_FHS_list}=  Create List
    FOR  ${item}  IN  @{BTS_primary_controller_FHS_list}
       Run Keyword If  '${item}' in ${${alias}_shared_FHS_list}
        ...  Append To List  ${BTS_primary_controller_shared_FHS_list}  ${item}
    END
    Sort List  ${BTS_primary_controller_shared_FHS_list}
    Set Test Variable  ${${alias}_primary_controller_shared_FHS_list}  ${BTS_primary_controller_shared_FHS_list}
    Log  BTS ${alias} configured as primary controller for: ${BTS_primary_controller_shared_FHS_list}  console=True
    ${BTS_primary_controller_shared_FHS_count}=  Get Length  ${BTS_primary_controller_shared_FHS_list}
    Set Test Variable  ${${alias}_primary_controller_shared_FHS_count}  ${BTS_primary_controller_shared_FHS_count}

Get BTS secondary controller shared FHS list
    [Arguments]  ${alias}
    ${BTS_secondary_controller_shared_FHS_list}=  Copy List  ${${alias}_shared_FHS_list}
    FOR  ${item}  IN  @{${alias}_primary_controller_shared_FHS_list}
        Remove Values From List  ${BTS_secondary_controller_shared_FHS_list}  ${item}
    END
    Set Test Variable  ${${alias}_secondary_controller_shared_FHS_list}  ${BTS_secondary_controller_shared_FHS_list}

Step ${index}: Perform FHS reset operation
    [Documentation]
    ...  Perform FHS reset operationon

    Log  Step ${index}: Perform FHS reset operation  console=True
    Run Keyword If  '${FHS_TO_RESET}' == 'All'  Run Keywords
    ...  Perform Reset Shared FHS operation
    ...  AND  Perform Reset Dedicated FHS operation
    ...  ELSE IF  '${FHS_TO_RESET}' == 'Shared'
    ...  Perform Reset Shared FHS operation
    ...  ELSE IF  '${FHS_TO_RESET}' == 'Dedicated'
    ...  Perform Reset Dedicated FHS operation

Perform Reset Shared FHS operation
    Log  Perform Shared FHS reset operation  console=True
    FOR  ${item}  IN  @{Master_primary_controller_shared_FHS_list}
        Reset shared FHS  ${item}  Master
    END
    FOR  ${item}  IN  @{Slave_primary_controller_shared_FHS_list}
        Reset shared FHS  ${item}  Slave
    END

Perform Reset Dedicated FHS operation
    Log  Perform Dedicated FHS reset operation  console=True
    FOR  ${item}  IN  @{Master_dedicated_FHS_list}
        Reset dedicated FHS  ${item}  Master
    END
    FOR  ${item}  IN  @{Slave_dedicated_FHS_list}
        Reset dedicated FHS  ${item}  Slave
    END

Step ${index}: Check both BTS reset behavior based on IMS info
    [Documentation]
    ...  RESET info is taken from IMS file. Reset behavior as expected if:
    ...  - NR BTS: reset number is 0
    ...  - LTE BTS: reset number is 0
    ...  Otherwise, reset behavior not as expected, then errors are added to report and failed.

    Log  Step ${index}: Check both BTS reset behavior based on IMS info  console=True
    Get and check BTS RESET info from IMS file  expected_reset_number=0  alias=Master  remove_ims_file=False
    ...  start_point_timestamp_UTC=${date_timestamp_start_UTC}  end_point_timestamp_UTC=${date_timestamp_end_UTC}
    Get and check BTS RESET info from IMS file  expected_reset_number=0  alias=Slave  remove_ims_file=False
    ...  start_point_timestamp_UTC=${date_timestamp_start_UTC}  end_point_timestamp_UTC=${date_timestamp_end_UTC}

Step ${index}: Check final number and state of Cells and RMs
    [Documentation]
    ...  Following checks are performed:
    ...  - number of configured cells and radio modules in SCF are properly mapped on BTS running view ADMIN
    ...  - check cells states
    ...  - check radio modules states

    Log  Step ${index}: Check final number and state of Cells and RMs  console=True
    RFS Test Case Final Checks

Get FHS RMOD dict
    [Arguments]  ${FHS_list}  ${alias}
    ${FHS_RMOD_dict}=  Create Dictionary
    FOR  ${item}  IN  @{FHS_list}
        ${RMOD_list}=  Get RMOD Mapping By FHS Id  ${item}  ${alias}
        Set To Dictionary  ${FHS_RMOD_dict}  ${item}  ${RMOD_list}
    END
    [Return]  ${FHS_RMOD_dict}

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

Get FHS CELL dict
    [Arguments]  ${FHS_list}  ${alias}
    ${FHS_CELL_dict}=  Create Dictionary
    FOR  ${item}  IN  @{FHS_list}
        ${RMOD_list}=  Get RMOD Mapping By FHS Id  ${item}  ${alias}
        ${CELL_list}=  Get CELL Mapping By RMOD Id  ${RMOD_list}  ${alias}
        Set To Dictionary  ${FHS_CELL_dict}  ${item}  ${CELL_list}
    END
    [Return]  ${FHS_CELL_dict}

Get CELL Mapping By RMOD Id
    [Arguments]   ${RMOD_list}  ${alias}
    ${CELL_list}=  Create List
    FOR  ${item}  IN  @{RMOD_list}
        ${RMOD_CELL_list}=  Get Cell Mapping By Module Id  module_id=${item}  connection=${alias}
        Append To List  ${CELL_list}  @{RMOD_CELL_list}
    END
    ${CELL_list}=  Remove Duplicates  ${CELL_list}
    [Return]  ${CELL_list}

Reset shared FHS
    [Arguments]  ${FHS_id}  ${alias}
    ${peer_alias}=  Set Variable If  '${alias}' == 'Master'  Slave  Master
    ${tech}=  Set Variable If  '${alias}' == 'Master'  NR  LTE
    ${peer_tech}=  Set Variable If  '${alias}' == 'Master'  LTE  NR
    ${cell_class}=  Set Variable If  '${alias}' == 'Master'  NRCEL  LNCEL
    ${peer_cell_class}=  Set Variable If  '${alias}' == 'Master'  LNCEL  NRCEL
    ${FHS_id_list}=  Create List
    Append To List  ${FHS_id_list}  ${FHS_id}
    ${RMOD_state_disabled_check}=  Set Variable
    ...  operationalState=${Disabled_}, availabilityStatus=${NotInstalled_}, administrativeState=${Unlocked_}
    ${RMOD_state_enabled_check}=  Set Variable  operationalState=${Enabled_}, administrativeState=${Unlocked_}
    ${CELL_state_disabled_check}=  Set Variable  operationalState=${Disabled_}, availabilityStatus=${Failed_Offline_}, blockingState=${Unblocked_}
    ${CELL_state_enabled_check}=  Set Variable  operationalState=${Enabled_}, blockingState=${Unblocked_}
    ${RMOD_state_disabled}=  Set Variable  operationalState=Disabled, availabilityStatus=NotInstalled, administrativeState=Unlocked
    ${RMOD_state_enabled}=  Set Variable  operationalState=Enabled, administrativeState=Unlocked
    ${CELL_state_disabled}=  Set Variable  operationalState=Disabled, availabilityStatus=Failed|Offline, blockingState=Unblocked
    ${CELL_state_enabled}=  Set Variable  operationalState=Enabled, blockingState=Unblocked

    ${FHS_SN}=  Get From Dictionary  ${${alias}_FHS_ID_SN_dict}  ${FHS_id}
    ${peer_FHS_id}=  Get From Dictionary  ${${peer_alias}_FHS_SN_ID_dict}  ${FHS_SN}
    ${peer_FHS_id_list}=  Create List
    Append To List  ${peer_FHS_id_list}  ${peer_FHS_id}
    ${shared_FHS_RMOD_list}=  Get From Dictionary  ${${alias}_shared_FHS_RMOD_dict}  ${FHS_id}
    ${peer_shared_FHS_RMOD_list}=  Get From Dictionary  ${${peer_alias}_shared_FHS_RMOD_dict}  ${peer_FHS_id}

    ${shared_FHS_RMOD_count}=  Get Length  ${shared_FHS_RMOD_list}
    ${peer_shared_FHS_RMOD_count}=  Get Length  ${peer_shared_FHS_RMOD_list}
    ${shared_FHS_CELL_list}=  Get From Dictionary  ${${alias}_shared_FHS_CELL_dict}  ${FHS_id}
    ${peer_shared_FHS_CELL_list}=  Get From Dictionary  ${${peer_alias}_shared_FHS_CELL_dict}  ${peer_FHS_id}

    ${ALARMS_10_count}=  Set Variable  ${shared_FHS_RMOD_count}
    ${EXPECTED_ALARMS_10_full}=  Prepare expected alarms list  ${${alias.upper()}_EXPECTED_ALARMS_10}  ${ALARMS_10_count}
    ${peer_ALARMS_10_count}=  Evaluate  ${shared_FHS_RMOD_count} + 1
    ${peer_EXPECTED_ALARMS_10_full}=  Prepare expected alarms list  ${${peer_tech}_EXPECTED_ALARMS_10}  ${peer_ALARMS_10_count}

    Run Keyword If  ${DSS_configured}  Get DSS alarms  ${shared_FHS_CELL_list}  ${peer_tech}

    Log  Perform "Reset" operation from ${alias} BTS on shared FHS with SN ${FHS_SN}  console=True

    ${new_alias}=  Set Variable  resetFHS
    Start new ADMIN instance  alias=${alias}  new_alias=${new_alias}  connection_type=${connection_type_${alias}}
    Get Current Date UTC info  start
    ${reset_info}=  Run Keyword In Background  Reset Unit  dist_name=${FHS_id}  reset_type=Hard  timeout=600  connection=${new_alias}
    Sleep  5s

    Log  Check ${alias} BTS and ${peer_alias} BTS state during reset shared FHS with SN ${FHS_SN}  console=True
    Wait Until Keyword Succeeds  180 sec  10 sec  Admin Check FHS list state  ${FHS_id_list}  ${Disabled_}  Disabled
    ...  ${NotInstalled_}  NotInstalled  ${Unlocked_}  Unlocked  ${alias}
    Log  ${tech} FHS ${FHS_id} status as expected  console=True
    Check BTS Item State  ${tech}  RMOD  ${shared_FHS_RMOD_list}  ${RMOD_state_disabled_check}  ${RMOD_state_disabled}  60  ${alias}
    Log  All ${tech} shared RMOD(s) connected to shared FHS with SN ${FHS_SN} status as expected  console=True
    Check BTS Item State  ${tech}  ${cell_class}  ${shared_FHS_CELL_list}  ${CELL_state_disabled_check}  ${CELL_state_disabled}  60  ${alias}
    Log  All ${tech} cell{s} mapped on shared RMOD(s) connected to shared FHS with SN ${FHS_SN} status as expected  console=True
    Wait Until Keyword Succeeds  180 sec  10 sec  Admin Check FHS list state  ${peer_FHS_id_list}  ${Disabled_}  Disabled
    ...  ${NotInstalled_}  NotInstalled  ${Unlocked_}  Unlocked  ${peer_alias}
    Log  ${peer_tech} FHS ${peer_FHS_id} status as expected  console=True
    Check BTS Item State  ${peer_tech}  RMOD  ${peer_shared_FHS_RMOD_list}  ${RMOD_state_disabled_check}  ${RMOD_state_disabled}  60  ${peer_alias}
    Log  All ${peer_tech} shared RMOD(s) connected to shared FHS with SN ${FHS_SN} status as expected  console=True
    Check BTS Item State  ${tech}  ${peer_cell_class}  ${peer_shared_FHS_CELL_list}
    ...  ${CELL_state_disabled_check}  ${CELL_state_disabled}  60  ${peer_alias}
    Log  All ${peer_tech} cell{s} mapped on shared RMOD(s) connected to shared FHS with SN ${FHS_SN} status as expected  console=True

    Log  Check ${tech} and ${peer_tech} alarms during reset shared FHS with SN ${FHS_SN}  console=True
    Log  ${tech} BTS "No connection to Unit (10)" alarm, expected number: ${ALARMS_10_count}  console=True
    Get and Check Alarms SOAM  alias=${alias}  expected_alarms=${EXPECTED_ALARMS_10_full}  ignored_alarms=${${alias.upper()}_IGNORED_ALARMS}
    ...  critical_alarms=${${alias.upper()}_CRITICAL_ALARMS}
    Log  ${tech} BTS "No connection to Unit (10)" alarm, found number: ${ALARMS_10_count}, as expected!  console=True
    Log  ${tech} site - expected, ignored and critical alarms checked  console=True
    ${peer_EXPECTED_ALARMS_full}=  Create List
    ${peer_EXPECTED_ALARMS_full}=  Run Keyword If  ${DSS_configured}  Combine Lists  ${EXPECTED_ALARMS_DSS_full}  ${peer_EXPECTED_ALARMS_10_full}
    ...  ELSE  Set Variable  ${peer_EXPECTED_ALARMS_10_full}
    ${peer_IGNORED_ALARMS_full}=  Combine Lists  ${${peer_tech}_IGNORED_ALARMS_DSS}  ${${peer_tech}_IGNORED_ALARMS}
     Run Keyword If  ${DSS_configured} and '${peer_tech}' == 'NR'
    ...  Log Long String  NR "EN DSS De-activated on partner side (7513)" or "EN DSS Keep Alive Procedure Time out (7511)", or
    ...  "EN DSS Setup Failure - Max EN DSS Counter Value reached - No answer from CRM (7509)" alarm, expected number:
    ...  ${DSS_alarm_count}  console=True
    Log  ${peer_tech} BTS "No connection to Unit (10)" alarm, expected number: ${peer_ALARMS_10_count}  console=True
    Get and Check Alarms SOAM  alias=${peer_alias}  expected_alarms=${peer_EXPECTED_ALARMS_full}
    ...  ignored_alarms=${peer_IGNORED_ALARMS_full}  critical_alarms=${${peer_tech}_CRITICAL_ALARMS}
    Run Keyword If  ${DSS_configured} and '${peer_tech}' == 'NR'
    ...  Log Long String  NR "EN DSS De-activated on partner side (7513)" or "EN DSS Keep Alive Procedure Time out (7511)", or
    ...  "EN DSS Setup Failure - Max EN DSS Counter Value reached - No answer from CRM (7509)" alarm, found number:
    ...  ${DSS_alarm_count}  console=True
    Log  ${peer_tech} BTS "No connection to Unit (10)" alarm, found number: ${peer_ALARMS_10_count}, as expected!  console=True
    Log  ${peer_tech} site - expected, ignored and critical alarms checked  console=True

    Collect Keyword Result  ${reset_info}  timeout=600

    Log  Check ${tech} and ${peer_tech} state after reset shared FHS with SN ${FHS_SN}  console=True
    Wait Until Keyword Succeeds  180 sec  10 sec  Admin Check FHS list state  ${FHS_id_list}  ${Enabled_}  Enabled
    ...  ${Online_}  Online|None  ${Unlocked_}  Unlocked  ${alias}
    Log  ${tech} shared FHS ${FHS_id} status as expected  console=True
    Check BTS Item State  ${tech}  RMOD  ${shared_FHS_RMOD_list}  ${RMOD_state_enabled_check}  ${RMOD_state_enabled}  180  ${alias}
    Log  All ${tech} shared RMOD(s) connected to shared FHS with SN ${FHS_SN} status as expected  console=True
    Check BTS Item State  ${tech}  ${cell_class}  ${shared_FHS_CELL_list}  ${CELL_state_enabled_check}  ${CELL_state_enabled}  180  ${alias}
    Log  All ${tech} cell{s} mapped on shared RMOD(s) connected to shared FHS with SN ${FHS_SN} status as expected  console=True
    Wait Until Keyword Succeeds  300 sec  10 sec  Admin Check FHS list state  ${FHS_id_list}  ${Enabled_}  Enabled
    ...  ${Online_}  Online|None  ${Unlocked_}  Unlocked  ${alias}
    Log  ${peer_tech} shared FHS ${peer_FHS_id} status as expected  console=True
    Check BTS Item State  ${peer_tech}  RMOD  ${peer_shared_FHS_RMOD_list}  ${RMOD_state_enabled_check}  ${RMOD_state_enabled}  180  ${peer_alias}
    Log  All ${peer_tech} shared RMOD(s) connected to shared FHS with SN ${FHS_SN} status as expected  console=True
    Check BTS Item State  ${peer_tech}  ${peer_cell_class}  ${peer_shared_FHS_CELL_list}
    ...  ${CELL_state_enabled_check}  ${CELL_state_enabled}  180  ${peer_alias}
    Log  All ${peer_alias} cell{s} mapped on shared RMOD(s) connected to shared FHS with SN ${FHS_SN} status as expected  console=True

    Get Current Date UTC info  end

    [Teardown]  Teardown Admin  alias=${new_alias}

Reset dedicated FHS
    [Arguments]  ${FHS_id}  ${alias}
    ${tech}=  Set Variable If  '${alias}' == 'Master'  NR  LTE
    ${cell_class}=  Set Variable If  '${alias}' == 'Master'  NRCEL  LNCEL
    ${FHS_id_list}=  Create List
    Append To List  ${FHS_id_list}  ${FHS_id}
    ${RMOD_state_disabled_check}=  Set Variable
    ...  operationalState=${Disabled_}, availabilityStatus=${NotInstalled_}, administrativeState=${Unlocked_}
    ${RMOD_state_enabled_check}=  Set Variable  operationalState=${Enabled_}, administrativeState=${Unlocked_}
    ${CELL_state_disabled_check}=  Set Variable  operationalState=${Disabled_}, availabilityStatus=${Failed_Offline_}, blockingState=${Unblocked_}
    ${CELL_state_enabled_check}=  Set Variable  operationalState=${Enabled_}, blockingState=${Unblocked_}
    ${RMOD_state_disabled}=  Set Variable  operationalState=Disabled, availabilityStatus=NotInstalled, administrativeState=Unlocked
    ${RMOD_state_enabled}=  Set Variable  operationalState=Enabled, administrativeState=Unlocked
    ${CELL_state_disabled}=  Set Variable  operationalState=Disabled, availabilityStatus=Failed|Offline, blockingState=Unblocked
    ${CELL_state_enabled}=  Set Variable  operationalState=Enabled, blockingState=Unblocked

    ${FHS_SN}=  Get From Dictionary  ${${alias}_FHS_ID_SN_dict}  ${FHS_id}
    ${dedicated_FHS_RMOD_list}=  Get From Dictionary  ${${alias}_dedicated_FHS_RMOD_dict}  ${FHS_id}

    ${dedicated_FHS_RMOD_count}=  Get Length  ${dedicated_FHS_RMOD_list}
    ${dedicated_FHS_CELL_list}=  Get From Dictionary  ${${alias}_dedicated_FHS_CELL_dict}  ${FHS_id}

    Log  Perform "Reset" operation from ${alias} BTS on dedicated FHS with SN ${FHS_SN}  console=True

    ${new_alias}=  Set Variable  resetFHS
    Start new ADMIN instance  alias=${alias}  new_alias=${new_alias}  connection_type=${connection_type_${alias}}
    Get Current Date UTC info  start
    ${reset_info}=  Run Keyword In Background  Reset Unit  dist_name=${FHS_id}  reset_type=Hard  timeout=600  connection=${new_alias}
    Sleep  5s

    Log  Check ${alias} BTS state during reset dedicated FHS with SN ${FHS_SN}  console=True
    Wait Until Keyword Succeeds  180 sec  10 sec  Admin Check FHS list state  ${FHS_id_list}  ${Disabled_}  Disabled
    ...  ${NotInstalled_}  NotInstalled  ${Unlocked_}  Unlocked  ${alias}
    Log  ${tech} FHS ${FHS_id} status as expected  console=True
    Check BTS Item State  ${tech}  RMOD  ${dedicated_FHS_RMOD_list}  ${RMOD_state_disabled_check}  ${RMOD_state_disabled}  60  ${alias}
    Log  All ${tech} dedicated RMOD(s) connected to dedicated FHS with SN ${FHS_SN} status as expected  console=True
    Check BTS Item State  ${tech}  ${cell_class}  ${dedicated_FHS_CELL_list}  ${CELL_state_disabled_check}  ${CELL_state_disabled}  60  ${alias}
    Log  All ${tech} cell{s} mapped on dedicated RMOD(s) connected to dedicated FHS with SN ${FHS_SN} status as expected  console=True

    Log  Check ${tech} alarms during reset dedicated FHS with SN ${FHS_SN}  console=True
    Get and Check Alarms SOAM  alias=${alias}  expected_alarms=@{EMPTY}  ignored_alarms=${${alias.upper()}_IGNORED_ALARMS}
    ...  critical_alarms=${${alias.upper()}_CRITICAL_ALARMS}
    Log  ${tech} site - expected, ignored and critical alarms checked  console=True

    Collect Keyword Result  ${reset_info}  timeout=600

    Log  Check ${tech} state after reset dedicated FHS with SN ${FHS_SN}  console=True
    Wait Until Keyword Succeeds  300 sec  10 sec  Admin Check FHS list state  ${FHS_id_list}  ${Enabled_}  Enabled
    ...  ${Online_}  Online|None  ${Unlocked_}  Unlocked  ${alias}
    Log  ${tech} dedicated FHS ${FHS_id} status as expected  console=True
    Check BTS Item State  ${tech}  RMOD  ${dedicated_FHS_RMOD_list}  ${RMOD_state_enabled_check}  ${RMOD_state_enabled}  180  ${alias}
    Log  All ${tech} dedicated RMOD(s) connected to dedicated FHS with SN ${FHS_SN} status as expected  console=True
    Check BTS Item State  ${tech}  ${cell_class}  ${dedicated_FHS_CELL_list}  ${CELL_state_enabled_check}  ${CELL_state_enabled}  180  ${alias}
    Log  All ${tech} cell{s} mapped on dedicated RMOD(s) connected to dedicated FHS with SN ${FHS_SN} status as expected  console=True

    Get Current Date UTC info  end

    [Teardown]  Teardown Admin  alias=${new_alias}

Check BTS Item State
    [Arguments]   ${tech}  ${BTS_item_class}  ${BTS_item_list}  ${BTS_item_state_check}  ${BTS_item_state}  ${timeout}  ${alias}
    FOR  ${item}  IN  @{BTS_item_list}
        Assert  class_name=${BTS_item_class}  id=${item}  parameters=${BTS_item_state_check}  timeout=${timeout}  connection=${alias}
        Log  ${tech} ${BTS_item_class} ${item} status:\n - ${BTS_item_state}  console=True
    END

Check if DSS is configured
    ${BTS_XP_localAlias_remoteAlias_dict}  ${NRBTS_DSS_alias_actLteNrDss_dict}  ${LNBTS_DSS_alias_actLteNrDss_dict}  ${BTS_DSS_NR_LTE_CELL_scf_dict}
    ...  ${BTS_DSS_LTE_NR_CELL_scf_dict}  ${BTS_DSS_NR_LTE_CELL_runtime_dict}  ${BTS_DSS_LTE_NR_CELL_runtime_dict}=  Get all BTS DSS feature info
    Set Test Variable  ${BTS_DSS_NR_LTE_CELL_runtime_dict}
    Set Test Variable  ${BTS_DSS_LTE_NR_CELL_runtime_dict}
    FOR  ${alias}  IN  @{alias_list}
        ${peer_alias}=  Set Variable If  '${alias}' == 'Master'  Slave  Master
        ${BTS_actLteNrDss_NR}=  Get From Dictionary  ${NRBTS_DSS_alias_actLteNrDss_dict}  ${alias}
        ${BTS_actLteNrDss_LTE}=  Get From Dictionary  ${LNBTS_DSS_alias_actLteNrDss_dict}  ${alias}

        ${BTS_DSS_configured}=  Set Variable If  '${BTS_actLteNrDss_NR}' == 'True' or '${BTS_actLteNrDss_LTE}' == 'True'  True  False
        ${BTS_DSS_peer}=  Get From Dictionary  ${BTS_XP_localAlias_remoteAlias_dict}  ${alias}
        Run Keyword If  '${peer_alias}' not in ${BTS_DSS_peer}
        ...  Set Test Variable  ${BTS_DSS_configured}  False

        Set Test Variable  ${${alias}_DSS_configured}  ${BTS_DSS_configured}
    END

    ${DSS_configured}=  Set Variable If  ${Master_DSS_configured} and ${Slave_DSS_configured}  True  False
    Set Test Variable  ${DSS_configured}

    Run Keyword If  ${Master_DSS_configured} and ${Slave_DSS_configured}
    ...  Log  DSS is configured between NR and LTE BTS. DSS alarms check will be performed!  console=True
    ...  ELSE  Log  DSS is not configured between NR and LTE BTS. DSS alarms check will be skipped!  console=True

Get DSS alarms
    [Arguments]  ${FHS_CELL_list}  ${tech}
    ${DSS_NR_LTE_CELL_runtime_dict}=  Get From Dictionary  ${BTS_DSS_NR_LTE_CELL_runtime_dict}  Master
    ${DSS_LTE_NR_CELL_runtime_dict}=  Get From Dictionary  ${BTS_DSS_LTE_NR_CELL_runtime_dict}  Slave

    ${CELL_DSS_dict}=  Run Keyword If  '${tech}' == 'NR'
    ...  Set Variable  ${DSS_NR_LTE_CELL_runtime_dict}
    ...  ELSE  Create Dictionary
    ${DSS_alarm_count}=  Set Variable  0
    FOR  ${item}  IN  @{FHS_CELL_list}
        ${CELL_DSS}=  Run Keyword And Return Status  Dictionary Should Contain Key  ${CELL_DSS_dict}  ${item}
        ${DSS_alarm_count}=  Run Keyword If  ${CELL_DSS}  Evaluate  ${DSS_alarm_count} + 1
        ...  ELSE  Evaluate  ${DSS_alarm_count} + 0
    END
    ${EXPECTED_ALARMS_DSS_full}=  Run Keyword If  '${tech}' == 'NR'
    ...  Prepare expected alarms list  ${${alias.upper()}_EXPECTED_ALARMS_DSS}  ${DSS_alarm_count}
    ...  ELSE  Create List
    Set Test Variable  ${DSS_alarm_count}
    Set Test Variable  ${EXPECTED_ALARMS_DSS_full}

TC Setup
    ${tech_preset_list}=  Create List  SBTS  SBTS
    Common Test Setup  preset_techs=${tech_preset_list}  common_sbts=${TRUE}  infomodelSetup=${FALSE}

TC Teardown
    Common Test Teardown
