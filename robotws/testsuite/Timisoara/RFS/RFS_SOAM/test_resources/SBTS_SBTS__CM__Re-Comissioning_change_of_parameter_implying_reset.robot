*** Settings ***
Documentation    TC__SBTS_SBTS__CM__Re-Comissioning_change_of_parameter_implying_reset
Variables    tc_variables/sbts_sbts__cm__re-comissioning_change_of_parameter_implying_reset.py
Resource    ../../resources/rfs_frame_rfs_soam_taf.robot

*** Variables ***
${REPEAT_COUNTER}             3          # Number of BTS Re-Commissioning operations, default value 3
${TARGET_BTS}                 BTS1     # Target BTS on which to perform Recommissioning. May be the following: BTS1, BTS2, ALL
${BTS_PRIMARY_LINK}                      # BTS primary link set before BTS Recommissioning, possible values: empty (no set required),
                                         # BTS1 (BTS1 set required) or BTS2 (BTS2 set required); default value: empty
${SET_PRIMARY_LINK_TIME}       720       # Maximum time in seconds to wait for Primary Link set on ${BTS_PRIMARY_LINK}, default value: 720
${SET_PRIMARY_LINK_PROCEDURE}  LANE      # Procedure for setting BTS_PRIMARY_LINK, possible values: BTS (BTS Reset), LANE (Lock Unlock SFP LANE)
${BTS_TIMEZONE_LIST}  (GMT+8) Asia/Hong_Kong, (GMT-11) US/Samoa, (GMT-5) Brazil/Acre   # List of BTS timeZone parameter values to be commissioned
                                         # ,separated by comma. By default: (GMT+8) Asia/Hong_Kong, (GMT-11) US/Samoa, (GMT-5) Brazil/Acre
${CHECK_PEER_DURING_RESET}       False   # Flag to enable/disable checks on peer during BTS Reset; possible values: True, False

*** Keywords ***
TC__SBTS_SBTS__CM__Re-Comissioning_change_of_parameter_implying_reset
    [Documentation]
    ...  [CASE LINK]: https://jiradc.ext.net.nokia.com/browse/TAT-28089
    ...
    ...  *****************
    ...  Basic information
    ...  *****************
    ...  SBTS-SBTS test case for Re-Comissioning_change_of_parameter_implying_reset, - x times sequence.
    ...  x - value of REPEAT_COUNTER parameter (default: 3)
    ...  The main steps performed for the test are:
    ...  - set if needed shared RMOD primary link on requested technology
    ...  - check initial state and alarms for ALL technologies
    ...  - get initial value of parameter timeZone and change it, operation on target bts
    ...  - check reset behavior on BTS1 and BTS2 based on IMS info as follows:
    ...    - target site: reset number is 0
    ...    - other site: reset number is 1
    ...  - check final state and alarms for ALL technologies
    ...  - recover initial scf configuration by recommission timeZone to its initial value
    ...  Pass criteria: timeZone parameter recommission successfully, states and alarms are as expected
    ...
    ...  ***************************
    ...  History of changes for SOAM
    ...  ***************************
    ...  - 14.11.2024 - https://jiradc.ext.net.nokia.com/browse/TAT-28237:
    ...  [5G] managedObject class changed for timeZone parameter -CM_Re-Comissioning_change_of_parameter_implying_reset - generic test
    ...  - 14.04.2025 - https://jiradc.ext.net.nokia.com/browse/TAT-27956 - [REFACTORING][ALARMS] Remove legacy SOAM alarms in Test_Cases and
    ...  Alarm Files NR_SBTS & SBTS_SBTS
    ...  *******************
    ...  Test case flowchart
    ...  *******************
    ...  https://confluence.ext.net.nokia.com/display/SRANRFSP/Test+Cases+Documentation

    Set Tags    CA-CM    OWNER-geraldina.isfan@nokia.com    AUTHOR-alexandru.rafiroiu@nokia.com    PHASE-QT    SW-SBTS25R1

    Primary Link TC Parameter Check
    TC Parameters check
    Step 1: Check initial BTS state
    Step 2: Check initial BTS alarms
    FOR  ${INDEX}  IN RANGE  1  ${REPEAT_COUNTER}+1
        Log  ==============================================================================  console=True
        Log  Start Cycle ${INDEX} of ${REPEAT_COUNTER}  console=True
        Log  ==============================================================================  console=True
        Run Keyword If  'ALL' in '${TARGET_BTS}'  Run Keywords
        ...  Perform Recommissioning on Master
        ...  AND  Perform Recommissioning on Slave
        ...  ELSE  Perform Recommissioning on ${TARGET_BTS}
    END

    [Teardown]  Particular Teardown

Perform Recommissioning on ${TARGET_ALIAS}
    Set Test Variable  ${TARGET_ALIAS}
    Step 3: Set Shared RMOD Primary Link before ${TARGET_ALIAS} BTS Recommissioning operation
    Step 4: Get initial date UTC info
    Step 5: Get initial value of parameter timeZone and update it
    Step 6: Check after recommissioning BTS state
    Step 7: Check after recommissioning BTS alarms
    Step 8: Get final date UTC info
    Step 9: Check BTS reset behavior based on IMS info
    Step 10: Check after recommissioning number and state of Cells and RMs
    Step 11: Recover initial scf configuration
    Step 12: Check final BTS state
    Step 13: Check final BTS alarms
    Step 14: Check final number and state of Cells and RMs

TC Parameters check
    ${alias_count}=  Get Length  ${alias_list}
    Set Test Variable  ${alias_count}
    Run Keyword If  ${alias_count} < 2  Run Keywords
    ...  Set Test Variable  ${TARGET_BTS}  Master
    ...  AND  Return From Keyword
    Return From Keyword If  'ALL' in '${TARGET_BTS}'
    ${TARGET_BTS}=  Set Variable If  '${TARGET_BTS}' == 'BTS1'  Master  Slave
    Set Test Variable  ${TARGET_BTS}

Step ${index}: Set Shared RMOD Primary Link before ${alias} Recommissioning operation
    [Documentation]
    ...  Set shared RMOD Primary Link if needed

    Run Keyword If  ${alias_count} < 2  Run Keywords
    ...  Highlight Log  Test action will be performed with existing Primary Link configuration
    ...  AND  Return From Keyword

    Log  Step ${index}: Set Shared RMOD Primary Link before ${alias} Recommissioning operation  console=True
    Run Keyword If  '${BTS_PRIMARY_LINK}' == ''  Run Keywords
    ...  Highlight Log  Test action will be performed with existing Primary Link configuration
    ...  AND  Return From Keyword
    ...  ELSE IF  '${BTS_PRIMARY_LINK}' in ['Master','Slave']  Run Keywords
    ...  Highlight Log  Test action will be performed with Primary Link set on BTS ${BTS_PRIMARY_LINK}
    ...  AND  Set Primary Link status based on linkModeSynchronization  module_type=RMOD
    ...  procedure_for_Primary_Link_set=${SET_PRIMARY_LINK_PROCEDURE}  alias=${BTS_PRIMARY_LINK}  wait_for_Primary_Link_set=${SET_PRIMARY_LINK_TIME}

Get RMOD info
    ${all_BTS_PL_shared_RM_info}=  Get PL shared RM info on all BTS
    FOR  ${alias}  IN  @{alias_list}
        ${BTS_PL_shared_RM_info}=  Get From Dictionary  ${all_BTS_PL_shared_RM_info}  ${alias}

        ${BTS_PL_CPRI_shared_RMOD_list}=  Get From Dictionary  ${BTS_PL_shared_RM_info}  BTS_PL_CPRI_shared_RM_id_list
        ${BTS_PL_ECPRI_shared_RMOD_list}=  Get From Dictionary  ${BTS_PL_shared_RM_info}  BTS_PL_ECPRI_shared_RM_id_list
        ${BTS_PL_OBSAI_shared_RMOD_list}=  Get From Dictionary  ${BTS_PL_shared_RM_info}  BTS_PL_OBSAI_shared_RM_id_list

        ${BTS_non_PL_CPRI_shared_RMOD_list}=  Get From Dictionary  ${BTS_PL_shared_RM_info}  BTS_non_PL_CPRI_shared_RM_id_list
        ${BTS_non_PL_ECPRI_shared_RMOD_list}=  Get From Dictionary  ${BTS_PL_shared_RM_info}  BTS_non_PL_ECPRI_shared_RM_id_list
        ${BTS_non_PL_OBSAI_shared_RMOD_list}=  Get From Dictionary  ${BTS_PL_shared_RM_info}  BTS_non_PL_OBSAI_shared_RM_id_list

        ${BTS_PL_CPRI_shared_RMOD_count}=  Get Length  ${BTS_PL_CPRI_shared_RMOD_list}
        ${BTS_PL_ECPRI_shared_RMOD_count}=  Get Length  ${BTS_PL_ECPRI_shared_RMOD_list}
        ${BTS_PL_OBSAI_shared_RMOD_count}=  Get Length  ${BTS_PL_OBSAI_shared_RMOD_list}

        Log  CPRI Shared RMOD count with Primary Link configured on ${alias} BTS: ${BTS_PL_CPRI_shared_RMOD_count}  console=True
        Log  ECPRI Shared RMOD count with Primary Link configured on ${alias} BTS: ${BTS_PL_ECPRI_shared_RMOD_count}  console=True
        Log  OBSAI Shared RMOD count with Primary Link configured on ${alias} BTS: ${BTS_PL_OBSAI_shared_RMOD_count}  console=True

        Set Test Variable  ${${alias}_PL_CPRI_shared_RMOD_list}  ${BTS_PL_CPRI_shared_RMOD_list}
        Set Test Variable  ${${alias}_PL_ECPRI_shared_RMOD_list}  ${BTS_PL_ECPRI_shared_RMOD_list}
        Set Test Variable  ${${alias}_PL_OBSAI_shared_RMOD_list}  ${BTS_PL_OBSAI_shared_RMOD_list}
        Set Test Variable  ${${alias}_non_PL_CPRI_shared_RMOD_list}  ${BTS_non_PL_CPRI_shared_RMOD_list}
        Set Test Variable  ${${alias}_non_PL_ECPRI_shared_RMOD_list}  ${BTS_non_PL_ECPRI_shared_RMOD_list}
        Set Test Variable  ${${alias}_non_PL_OBSAI_shared_RMOD_list}  ${BTS_non_PL_OBSAI_shared_RMOD_list}

        Set Test Variable  ${${alias}_PL_CPRI_shared_RMOD_count}  ${BTS_PL_CPRI_shared_RMOD_count}
        Set Test Variable  ${${alias}_PL_ECPRI_shared_RMOD_count}  ${BTS_PL_ECPRI_shared_RMOD_count}
        Set Test Variable  ${${alias}_PL_OBSAI_shared_RMOD_count}  ${BTS_PL_OBSAI_shared_RMOD_count}
    END

Step ${index}: Check ${when} BTS state
    [Documentation]
    ...  SBTS state is checked according to Admin for BTS and each configured RAT

    Log  Step ${index}: Check ${when} platform state  console=True
    FOR  ${alias}  IN  @{alias_list}
        Admin Check BTS RAT Procedural State  alias=${alias}  timeout=600
        Admin Check BTS Procedural and Blocking states  ${OnAir_}  ${Unblocked_}  600  ${alias}
        Log  ${alias} site - proceduralState: OnAir, blockingState: Unblocked  console=True
    END

Step ${index}: Check ${when} BTS alarms
    [Documentation]
    ...  SBTS alarms are compared with values from expected, ignored and critical alarms lists. SBTS alarms are get
    ...  from Admin

    Log  Step ${index}: Check ${when} platform alarms  console=True
    FOR  ${alias}  IN  @{alias_list}
        ${wait_for_alarm_clear}=  Set Variable If  '${when}' == 'final'  10min  5min
        Get and Check Alarms SOAM  alias=${alias}  expected_alarms=@{EMPTY}  ignored_alarms=${${alias.upper()}_IGNORED_ALARMS}
        ...  critical_alarms=${${alias.upper()}_CRITICAL_ALARMS}  wait_for_alarm_clear=${wait_for_alarm_clear}
        Log  ${alias} site - expected, ignored and critical alarms checked  console=True
    END

Step ${index}: Get initial value of parameter timeZone and update it
    [Documentation]
    ...  Get initial value of parameter timeZone and update it

    ${alias_count}=  Get Length  ${alias_list}
    Log  Step ${index}: Get initial value of parameter timeZone and update it  console=True
    Run Keyword If  ${CHECK_PEER_DURING_RESET} and ${alias_count} > 1  Run Keywords
    ...  Get initial value of parameter timeZone and update it with peer checks
    ...  AND  Return from Keyword

    ${temp_timezone}=  Get Time Zone from SCF  scf_path=${${TARGET_ALIAS.lower()}_scf_initial}  alias=${TARGET_ALIAS}
    Set Test Variable  ${${TARGET_ALIAS}_timeZone_init}  ${temp_timezone}
    Log  Initial value timeZone=${${TARGET_ALIAS}_timeZone_init}  console=True
    Log  BTS Time Zone selection list for BTS Commissioning: ${BTS_TIMEZONE_LIST}  console=True
    ${BTS_TIMEZONE_LIST_strip}=  Strip String  ${BTS_TIMEZONE_LIST}
    ${BTS_TIMEZONE_LIST_strip}=  Evaluate  '${BTS_TIMEZONE_LIST_strip}'.replace(', ',',')
    ${BTS_TIMEZONE_LIST}=  Split String  ${BTS_TIMEZONE_LIST_strip}  ,

    FOR  ${item}  IN  @{BTS_TIMEZONE_LIST}
        Run Keyword If  '${item}' not in '${${TARGET_ALIAS}_timeZone_init}'  Run Keywords
        ...  Set Test Variable  ${TIMEZONE_VALUE}  ${item}
        ...  AND  Exit For Loop
    END
    Log  Recommissioning will be performed using timeZone=${TIMEZONE_VALUE}  console=True
    Get Current Time  bts_initial
    ${dst_name}=  Get object dist name for timeZone parameter recommissioning  alias=${TARGET_ALIAS}  scf_path=${${TARGET_ALIAS.lower()}_scf_initial}
    coam.Perform Parameter Recommissioning  dist_name=${dst_name}
    ...  parameter=timeZone  operation=update  value=${TIMEZONE_VALUE}
    ...  skip_parameter_relation_errors=True  should_activate=True  timeout=900  alias=${TARGET_ALIAS}
    Check timeZone parameter after recommissioning
    Check BTS SCF Validation On Demand  alias=${TARGET_ALIAS}

Get initial value of parameter timeZone and update it with peer checks
    Get RMOD info
    ${peer_alias}=  Set Variable If  'Master' in '${TARGET_ALIAS}'  Slave  Master
    Get Cell Count  alias=${peer_alias}

    ${temp_timezone}=  Get Time Zone from SCF  scf_path=${${TARGET_ALIAS.lower()}_scf_initial}  alias=${TARGET_ALIAS}
    Set Test Variable  ${${TARGET_ALIAS}_timeZone_init}  ${temp_timezone}
    Log  Initial value timeZone=${${TARGET_ALIAS}_timeZone_init}  console=True
    Log  BTS Time Zone selection list for BTS Commissioning: ${BTS_TIMEZONE_LIST}  console=True
    ${BTS_TIMEZONE_LIST}=  Split String  ${BTS_TIMEZONE_LIST}  ,${SPACE}

    FOR  ${item}  IN  @{BTS_TIMEZONE_LIST}
        Run Keyword If  '${item}' not in '${${TARGET_ALIAS}_timeZone_init}'  Run Keywords
        ...  Set Test Variable  ${TIMEZONE_VALUE}  ${item}
        ...  AND  Exit For Loop
    END
    Log  Recommissioning will be performed using timeZone: ${TIMEZONE_VALUE}  console=True
    Get Current Time  bts_initial
    Start new ADMIN instance  alias=${TARGET_ALIAS}  new_alias=commission
    ${dst_name}=  Get object dist name for timeZone parameter recommissioning  alias=${TARGET_ALIAS}  scf_path=${${TARGET_ALIAS.lower()}_scf_initial}
    ${reset_info}=  Run Keyword In Background  coam.Perform Parameter Recommissioning  dist_name=${dst_name}  skip_parameter_relation_errors=False
    ...  parameter=timeZone  operation=update  value=${TIMEZONE_VALUE}
    ...  skip_parameter_relation_errors=True  should_activate=True  timeout=900  alias=commission
    Sleep  10s

    ${host}=  Set Variable  ${${TARGET_ALIAS.upper()}}[${TARGET_ALIAS.upper()}_TECH_IP_ADDRESS]
    ${remote_host}=  Set Variable  ${${TARGET_ALIAS.upper()}}[${TARGET_ALIAS.upper()}_PC_IP_ADDRESS]

    Wait For Target To Be Not Reachable TAF  hostname=${host}
    ...  timeout=200  remote_host=${remote_host}

    Check peer state and alarms during ${TARGET_ALIAS} reset

    Wait For Target To Be Reachable TAF  hostname=${host}
    ...  timeout=200  remote_host=${remote_host}

    Admin Check BTS Procedural and Blocking states  ${OnAir_}  ${Unblocked_}  600  ${TARGET_ALIAS}

    Check timeZone parameter after recommissioning

    Collect Keyword Result  ${reset_info}  timeout=600

    [Teardown]  Teardown Admin  alias=commission

Check peer state and alarms during ${alias} reset
    ${peer_alias}=  Set Variable If  'Master' in '${alias}'  Slave  Master

    ${alias_PL_CPRI_OBSAI_shared_RMOD_count}=  Evaluate  ${${alias}_PL_CPRI_shared_RMOD_count} + ${${alias}_PL_OBSAI_shared_RMOD_count}
    ${peer_alias_non_PL_CPRI_OBSAI_shared_RM_CELL_count}=  Evaluate
    ...  ${${peer_alias}_non_PL_CPRI_shared_RM_CELL_count} + ${${peer_alias}_non_PL_OBSAI_shared_RM_CELL_count}
    ${peer_alias_EXPECTED_ALARMS_full}=  Create List
    ${FID10_count}=  Set Variable  ${alias_PL_CPRI_OBSAI_shared_RMOD_count}
    ${FID16_count}=  Set Variable  ${${alias}_PL_ECPRI_shared_RMOD_count}
    ${peer_alias_EXPECTED_ALARMS_10_full}=  Prepare expected alarms list  ${${peer_alias}_EXPECTED_ALARMS_10}  ${FID10_count}
    ${peer_alias_EXPECTED_ALARMS_16_full}=  Prepare expected alarms list  ${${peer_alias}_EXPECTED_ALARMS_16}  ${FID16_count}
    ${peer_alias_EXPECTED_ALARMS_10_16_full}=  Combine Lists  ${peer_alias_EXPECTED_ALARMS_10_full}  ${peer_alias_EXPECTED_ALARMS_16_full}
    ${peer_alias_EXPECTED_ALARMS}=  Set Variable If
    ...  (${alias_PL_CPRI_OBSAI_shared_RMOD_count} == 0 and ${${alias}_PL_ECPRI_shared_RMOD_count} == 0)
    ...  ${peer_alias_EXPECTED_ALARMS_full}  ${peer_alias_EXPECTED_ALARMS_10_16_full}
    ${peer_alias_IGNORED_ALARMS_full}=  Combine Lists  ${PEER_IGNORED_ALARMS_DURING_RESET}  ${${peer_alias}_IGNORED_ALARMS}

    Run Keyword If  ${alias_PL_CPRI_OBSAI_shared_RMOD_count} > 0
    ...  Log  ${peer_alias} "No connection to Unit (10)" alarm, expected number: ${FID10_count}  console=True
    Run Keyword If  ${${alias}_PL_ECPRI_shared_RMOD_count} > 0
    ...  Log  ${peer_alias} "Unit synchronization failed (16)" alarm, expected numberl: ${FID16_count}  console=True

    Get and Check Alarms SOAM  alias=${peer_alias}  expected_alarms=${peer_alias_EXPECTED_ALARMS}
    ...  ignored_alarms=${peer_alias_IGNORED_ALARMS_full}  critical_alarms=${${peer_alias}_CRITICAL_ALARMS}

    Run Keyword If  ${alias_PL_CPRI_OBSAI_shared_RMOD_count} > 0
    ...  Log  ${peer_alias} "No connection to Unit (10)" alarm, found number: ${FID10_count}, as expected!
    ...  console=True
    Run Keyword If  ${${alias}_PL_ECPRI_shared_RMOD_count} > 0
    ...  Log  ${peer_alias} "Unit synchronization failed (16)" alarm, found number: ${FID16_count}, as expected!
    ...  console=True
    Log  ${peer_alias} site - expected, ignored and critical alarms checked  console=True

    ${RMOD_state_disabled_check}=  Set Variable
    ...  operationalState=${Disabled_}, availabilityStatus=${NotInstalled_Offline_}, administrativeState=${Unlocked_}
    ${RMOD_state_enabled_check}=  Set Variable  operationalState=${Enabled_}, administrativeState=${Unlocked_}
    ${RMOD_state_disabled}=  Set Variable  operationalState=Disabled, availabilityStatus=NotInstalled|Offline, administrativeState=Unlocked
    ${RMOD_state_enabled}=  Set Variable  operationalState=Enabled, administrativeState=Unlocked

    Run Keyword If  ${${peer_alias}_non_PL_CPRI_shared_RMOD_list}  Run Keywords
    ...  Check BTS Item State  RMOD  ${${peer_alias}_non_PL_CPRI_shared_RMOD_list}  ${RMOD_state_disabled_check}  60  ${peer_alias}
    ...  AND  Log  All CPRI Shared RMOD with Primary Link configured on ${alias} BTS status:\n - ${RMOD_state_disabled}  console=True
    Run Keyword If  ${${peer_alias}_PL_CPRI_shared_RMOD_list}  Run Keywords
    ...  Check BTS Item State  RMOD  ${${peer_alias}_PL_CPRI_shared_RMOD_list}  ${RMOD_state_enabled_check}  60  ${peer_alias}
    ...  AND  Log  All CPRI Shared RMOD with Primary Link configured on ${peer_alias} BTS status:\n - ${RMOD_state_enabled}  console=True
    Run Keyword If  ${${peer_alias}_non_PL_ECPRI_shared_RMOD_list}  Run Keywords
    ...  Check BTS Item State  RMOD  ${${peer_alias}_non_PL_ECPRI_shared_RMOD_list}  ${RMOD_state_disabled_check}  60  ${peer_alias}
    ...  AND  Log  All ECPRI Shared RMOD with Primary Link configured on ${alias} BTS status:\n - ${RMOD_state_disabled}  console=True
    Run Keyword If  ${${peer_alias}_PL_ECPRI_shared_RMOD_list}  Run Keywords
    ...  Check BTS Item State  RMOD  ${${peer_alias}_PL_ECPRI_shared_RMOD_list}  ${RMOD_state_enabled_check}  60  ${peer_alias}
    ...  AND  Log  All ECPRI Shared RMOD with Primary Link configured on ${peer_alias} BTS status:\n - ${RMOD_state_enabled}  console=True
    Run Keyword If  ${${peer_alias}_PL_OBSAI_shared_RMOD_list}  Run Keywords
    ...  Check BTS Item State  RMOD  ${${peer_alias}_PL_OBSAI_shared_RMOD_list}  ${RMOD_state_enabled_check}  60  ${peer_alias}
    ...  AND  Log  All OBSAI Shared RMOD with Primary Link configured on ${peer_alias} BTS status:\n - ${RMOD_state_enabled}  console=True

Check BTS Item State
    [Arguments]  ${BTS_item_class}  ${BTS_item_list}  ${BTS_item_state_check}  ${timeout}  ${alias}
    FOR  ${item}  IN  @{BTS_item_list}
        Assert  class_name=${BTS_item_class}  id=${item}  parameters=${BTS_item_state_check}  timeout=${timeout}  connection=${alias}
    END

Get Cell Count
    [Arguments]  ${alias}
    ${non_PL_CPRI_shared_RM_CELL_list}  ${non_PL_CPRI_shared_RM_CELL_count}=  Get cells mapped on shared RM
    ...  ${${alias}_non_PL_CPRI_shared_RMOD_list}  ${alias}
    ${non_PL_ECPRI_shared_RM_CELL_list}  ${non_PL_ECPRI_shared_RM_CELL_count}=  Get cells mapped on shared RM
    ...  ${${alias}_non_PL_ECPRI_shared_RMOD_list}  ${alias}
    ${non_PL_OBSAI_shared_RM_CELL_list}  ${non_PL_OBSAI_shared_RM_CELL_count}=  Get cells mapped on shared RM
    ...  ${${alias}_non_PL_OBSAI_shared_RMOD_list}  ${alias}
    ${non_PL_shared_RM_CELL_list}=  Combine Lists  ${non_PL_CPRI_shared_RM_CELL_list}  ${non_PL_ECPRI_shared_RM_CELL_list}
    ...  ${non_PL_OBSAI_shared_RM_CELL_list}
    Set Test Variable  ${${alias}_non_PL_CPRI_shared_RM_CELL_count}  ${non_PL_CPRI_shared_RM_CELL_count}
    Set Test Variable  ${${alias}_non_PL_ECPRI_shared_RM_CELL_count}  ${non_PL_ECPRI_shared_RM_CELL_count}
    Set Test Variable  ${${alias}_non_PL_OBSAI_shared_RM_CELL_count}  ${non_PL_OBSAI_shared_RM_CELL_count}
    Set Test Variable  ${${alias}_non_PL_shared_RM_CELL_list}  ${non_PL_shared_RM_CELL_list}

Get cells mapped on shared RM
    [Arguments]  ${shared_RM_list}  ${alias}
    ${shared_RM_CELL_list}=  Create List
    FOR  ${item}  IN  @{shared_RM_list}
        ${CELL_RM_list}=  Get Cell Mapping By Module Id  module_id=${item}  alias=${alias}
        Append To List  ${shared_RM_CELL_list}  @{CELL_RM_list}
    END
    ${shared_RM_CELL_list}=  Remove Duplicates  ${shared_RM_CELL_list}
    ${shared_RM_CELL_count}=  Get Length  ${shared_RM_CELL_list}
    [Return]  ${shared_RM_CELL_list}  ${shared_RM_CELL_count}

Step ${index}: Check ${when} number and state of Cells and RMs
    [Documentation]
    ...  Following checks are performed:
    ...  - number of configured cells and radio modules in SCF are properly mapped on BTS running view ADMIN
    ...  - check cells states
    ...  - check radio modules states

    Log  Step ${index}: Check ${when} number and state of Cells and RMs  console=True
    RFS Test Case Final Checks

Step ${index}: Recover initial scf configuration
    [Documentation]
    ...  Change timeZone parameter to its initial value

    Log  Step ${index}: Recover initial scf configuration  console=True
    Ensure recover initial parameter value  target_alias=${TARGET_ALIAS}

Step ${index}: Get ${when} date UTC info
    Log  Step ${index}: Get ${when} date UTC info  console=True
    Get Current Date UTC info  ${when}

Step ${index}: Check BTS reset behavior based on IMS info
    [Documentation]
    ...  BTS RESET info is checked based on IMS info for ALL Tehnologies. Reset behavior as expected if:
    ...  - target bts site: reset number is 1
    ...  - peer site: reset number is 0
    ...  Otherwise, reset behavior not as expected, then errors are added to report and failed.

    Log  Step ${index}: Check BTS reset behavior based on IMS info  console=True
    Get and check BTS RESET info from IMS file  expected_reset_number=1  alias=${TARGET_ALIAS}  remove_ims_file=False
    ...  start_point_timestamp_UTC=${date_timestamp_initial_UTC}  end_point_timestamp_UTC=${date_timestamp_final_UTC}

    FOR  ${alias}  IN  @{alias_list}
        Continue For Loop If  '${alias}' == '${TARGET_ALIAS}'
        Get and check BTS RESET info from IMS file  expected_reset_number=0  alias=${alias}  remove_ims_file=False
        ...  start_point_timestamp_UTC=${date_timestamp_initial_UTC}  end_point_timestamp_UTC=${date_timestamp_final_UTC}
    END

Ensure recover initial parameter value
    [Arguments]  ${target_alias}
    ${scf_final}=  Admin Collect scf.xml with timestamp TAF  alias=${target_alias}  folder_path=${BTSFiles}/${target_alias}
    ${dst_name}=  Get object dist name for timeZone parameter recommissioning  alias=${target_alias}  scf_path=${scf_final}
    ${timeZone_final}=  Get Time Zone from SCF  scf_path=${scf_final}  alias=${target_alias}
    Run Keyword If  '${timeZone_final}' != '${${target_alias}_timeZone_init}'  Run Keywords
    ...  Log  Recover timeZone parameter to its intial value  console=True  AND
    ...  coam.Perform Parameter Recommissioning  dist_name=${dst_name}
    ...  parameter=timeZone  operation=update  value=${${target_alias}_timeZone_init}
    ...  skip_parameter_relation_errors=True  should_activate=True  timeout=900  alias=${target_alias}
    ...  AND  Check BTS SCF Validation On Demand  alias=${target_alias}

Check timeZone parameter after recommissioning
    ${scf_after_recommissioning}=  Admin Collect scf.xml with timestamp TAF  alias=${TARGET_ALIAS}  folder_path=${BTSFiles}/${TARGET_ALIAS}
    ${timeZone_val}=  Get Time Zone from SCF  scf_path=${scf_after_recommissioning}  alias=${TARGET_ALIAS}
    Run Keyword If  '${timeZone_val}' == '${TIMEZONE_VALUE}'
    ...  Log  ${TARGET_ALIAS} timeZone new parameter value ${TIMEZONE_VALUE}, successfully recommissioned!  console=True  ELSE
    ...  Run Keywords  Log  ${TARGET_ALIAS} timeZone parameter could not be successfully recommissioned as ${TIMEZONE_VALUE}.
    ...  Actual value is ${timeZone_val}.  console=True  AND  FAIL

Particular Teardown
    Run Keyword If  'ALL' in '${TARGET_BTS}'  Run Keywords
    ...  Run Keyword And Continue On Failure  Ensure recover initial parameter value  target_alias=Master
    ...  AND  Run Keyword And Continue On Failure  Ensure recover initial parameter value  target_alias=Slave
    ...  ELSE  Run Keyword And Continue On Failure  Ensure recover initial parameter value  target_alias=${TARGET_BTS}
    Check all BTS cells availability status online

TC Setup
    ${tech_preset_list}=  Create List  SBTS  SBTS
    Common Test Setup  preset_techs=${tech_preset_list}  common_sbts=${TRUE}  infomodelSetup=${FALSE}

TC Teardown
    Common Test Teardown
