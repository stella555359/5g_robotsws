*** Settings ***
Documentation    TC__SBTS_SBTS_SBTS_SBTS__STATE__Site_Reset_same_time_from_WEBEM
Variables    tc_variables/sbts_sbts_sbts_sbts__state__site_reset_same_time_from_webem_alarms_definitions.py
Resource    ../../resources/rfs_frame_rfs_soam_taf.robot

*** Variables ***
${REPEAT_COUNTER}      3    # Number of BTS Reset operations, default value 3
${BTS_LIST}            ALL  # BTS list on which reset operation will be performed. Possible values (by default ALL):
                            # - ALL: action will be performed on all BTS (reset each BTS until last BTS from TL)
                            # - list of selected BTS separated by comma labelized as BTSx (x is test_pc number in init.py) (ex. BTS1, BTS3)
${BTS1_RESET_WRN_THR}  600  # Time (secs) spent between first cell down to last cell up on BTS1
                            # Default value: in accordance with KPI1a specifications
${BTS2_RESET_WRN_THR}  600  # Time (secs) spent between first cell down to last cell up on BTS2
                            # Default value: in accordance with KPI1a specifications
${BTS3_RESET_WRN_THR}  600  # Time (secs) spent between first cell down to last cell up on BTS3
                            # Default value: in accordance with KPI1a specifications
${BTS4_RESET_WRN_THR}  600  # Time (secs) spent between first cell down to last cell up on BTS4
                            # Default value: in accordance with KPI1a specifications
${BTS_MAX_WAIT_TIME}   900  # Maximum time to wait for BTS OnAir after reset (by default 900)
${SWCONFIG_CHANGE_FLAG}  False  # Enable/disable HWF flags in swconfig.txt file. By default HWF flags change is disabled: False
${SWCONFIG_FLAG_ACTION}  add  # Action that should be done with the list of HWF flags in swconfig.txt. Possible values: add/remove
                              # - add: check requested HWF flags from swconfig.txt file and set if needed on 0 -> HWF will not be took into use
                              # - remove: check requested HWF flags from swconfig.txt file and remove if set on 0 -> HWF will be took into use
${SWCONFIG_FLAG_LIST}  0x4F0214  # List of HWF flags that will be added/removed in swconfig.txt. User provides the flags with spaces between them.
                                 # Possible values:
                                 # - 0x190030 (OAM_DBG_EnableHwfLoading) till SBTS00_ENB_9999_211214_000014 or on maintenance branches till SBTS22R1
                                 # - 0x4F0214 (ERadLteHas_BB_PERIPHERIES_EnableHwfLoading) from SBTS00_ENB_9999_211214_000014
                                 # For current SW trunk, flag 0x4F0214 should be used
${GRACEFUL_CELL_SHUTDOWN}  True  # Graceful cell shutdown: True or False; default value: True

*** Keywords ***
TC__SBTS_SBTS_SBTS_SBTS__STATE__Site_Reset_same_time_from_WEBEM
     [Documentation]
    ...  [CASE LINK]: https://jiradc.ext.net.nokia.com/browse/TAT-27713
    ...
    ...  *****************
    ...  Basic information
    ...  *****************
    ...  SBTS-SBTS-SBTS-SBTS test case for reseting all BTSs on a testline at the same time , - x times sequence.
    ...  x - value of REPEAT_COUNTER parameter (default: 3)
    ...  The main steps performed for the test are:
    ...  - check initial state and alarms for all BTS
    ...  - IF BTS_LIST = ALL perform BTS reset operations on all BTSs at the same time
    ...  - IF BTS_LIST is custom, perform BTS reset operations on all BTSs selected BTS present in BTS_LIST
    ...  - check final state and alarms for for all BTS
    ...  Pass criteria: BTS reset operation works as expected; states and alarms are as expected
    ...
    ...  ***************************
    ...  History of changes for SOAM
    ...  ***************************
    ...  -  28.06.2024 - https://jiradc.ext.net.nokia.com/browse/TAT-27713 -  SBTS_SBST BTS1, BTS2 same time Site Reset similar to NRL, NR_SBTS
    ...  - 26.09.2024 - https://jiradc.ext.net.nokia.com/browse/TAT-28126 - [5G] CNI : 131510 - Classical - Part 1 - Graceful cell shutdown
    ...  - 24.11.2025 - https://jiradc.ext.net.nokia.com/browse/TAT-30179 - Remove infomodel usage in test-cases
    ...
    ...  *******************
    ...  Test case flowchart
    ...  *******************
    ...  https://confluence.ext.net.nokia.com/display/SRANRFSP/Test+Cases+Documentation+-+DRAFT
    ...  SBTS_SBTS_SBTS_SBTS__STATE__Site_Reset_same_time_from_WEBEM.xlsx

    Set Tags    CA-STATE    OWNER-dorin.caluser@nokia.com   AUTHOR-dorin.caluser@nokia.com    PHASE-CRT    SW-SBTS24R3

    TC Preconditions
    Configure Hardware File
    Step 1: Check initial all BTS state
    Step 2: Check initial all BTS alarms
    FOR  ${CYCLE}  IN RANGE  1  ${REPEAT_COUNTER}+1
        Log  ==============================================================================  console=True
        Log  Start Cycle ${CYCLE} of ${REPEAT_COUNTER}  console=True
        Log  ==============================================================================  console=True
        Step 3: Perform BTS Site Reset same time for iteration ${CYCLE}
        Step 4: Check final all BTS state
        Step 5: Check final all BTS alarms
        Step 6: Check final number and state of Cells and RMs
    END

    [Teardown]  Particular Teardown

TC Preconditions
    ${BTS_alias_label_dict}  ${BTS_label_alias_dict}=  Get BTS alias label info dict
    Set Test Variable  ${BTS_alias_label_dict}
    Set Test Variable  ${BTS_label_alias_dict}
    ${BTS_alias_list}=  Get Dictionary Keys  ${BTS_alias_label_dict}  False
    ${BTS_label_list}=  Get Dictionary Values  ${BTS_alias_label_dict}  False
    Set Test Variable  ${BTS_alias_list}
    Set Test Variable  ${BTS_label_list}

    Run Keyword If  '${BTS_LIST}' != 'ALL'  Check BTS list
    Log  ====================================================  console=True
    Log  BTS label list selected for reset operation: ${BTS_label_list}  console=True
    Log  BTS alias list selected for reset operation: ${BTS_alias_list}  console=True
    Run Keyword If  '${BTS_LIST}' != 'ALL'  Run Keywords
    ...  Log  BTS label list that are NOT selected for reset operation: ${BTS_remaining_label_list}  console=True
    ...  AND
    ...  Log  BTS alias list that are NOT selected for reset operation: ${BTS_remaining_alias_list}  console=True
    Log  ====================================================  console=True

Check BTS list
    ${BTS_LIST_strip}=  Replace String  ${BTS_LIST}  ${SPACE}  ${EMPTY}
    ${BTS_LIST}=  Split String  ${BTS_LIST_strip}  ,
    ${BTS_check}=  Set Variable  True
    ${BTS_invalid_label_list}=  Create List
    ${BTS_request_label_list}=  Create List
    ${BTS_request_alias_list}=  Create List

    FOR  ${item}  IN  @{BTS_LIST}
        ${BTS_check}=  Set Variable If  '${item}' not in ${BTS_label_list}  False  ${BTS_check}
        Run Keyword If  '${item}' not in ${BTS_label_list}
        ...  Append To List  ${BTS_invalid_label_list}  ${item}
        ...  ELSE
        ...  Append To List  ${BTS_request_label_list}  ${item}
    END

    Run Keyword If  '${BTS_check}' == 'False'  Run Keywords
    ...  Log Long String  Following selected BTS are not valid: ${BTS_invalid_label_list}. Please select values for test argument \${BTS_LIST} from
    ...  configured BTS: ${BTS_label_list} or let default value: ALL  console=True
    ...  AND  Fail  Improper value for argument!

    FOR  ${item}  IN  @{BTS_request_label_list}
        ${BTS_request_alias}=  Get From Dictionary  ${BTS_label_alias_dict}  ${item}
        Append To List  ${BTS_request_alias_list}  ${BTS_request_alias}
    END

    Set Test Variable  ${BTS_label_list}  ${BTS_request_label_list}
    Set Test Variable  ${BTS_alias_list}  ${BTS_request_alias_list}

    ${BTS_remaining_alias_list}=    Create List
    ${BTS_remaining_label_list}=    Create List
    FOR    ${item}    IN    @{alias_list}
        Run Keyword If    '${item}' not in @{BTS_alias_list}    Append To List    ${BTS_remaining_alias_list}    ${item}
    END
    FOR  ${alias}  IN  @{BTS_remaining_alias_list}
        ${name}=  Get From Dictionary  ${BTS_alias_label_dict}  ${alias}
        Append To List    ${BTS_remaining_label_list}    ${name}
    END
    Set Test Variable  ${BTS_remaining_alias_list}
    Set Test Variable  ${BTS_remaining_label_list}

Configure Hardware File
    Return From Keyword If  '${SWCONFIG_CHANGE_FLAG}' == 'False'
    FOR  ${alias}  IN  @{BTS_alias_list}
        Set HWF Flags  swconfig_flag_action=${SWCONFIG_FLAG_ACTION}  swconfig_flag_list=${SWCONFIG_FLAG_LIST}  alias=${alias}
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

    ${wait_for_alarm_clear}=  Set Variable If  '${when}' == 'final'  15 min  5 min
    Log  Step ${index}: Check ${when} all BTS alarms  console=True
    FOR  ${alias}  IN  @{alias_list}
        Log  ***** Check ${when} BTS ${alias} alarms *****  console=True
        Get and Check Alarms SOAM  alias=${alias}  expected_alarms=@{EMPTY}  ignored_alarms=${test_alarms_list['${alias.upper()}_IGNORED_ALARMS']}
        ...  critical_alarms=${test_alarms_list['${alias.upper()}_CRITICAL_ALARMS']}  wait_for_alarm_clear=${wait_for_alarm_clear}
        Log  BTS ${alias} site - expected, ignored and critical alarms checked  console=True
    END

Step ${index}: Perform BTS Site Reset same time for iteration ${CYCLE}
    [Documentation]
    ...  Perform Site Reset on the same time on all BTS, then expect them to by not reachable.
    ...  After Site Reset, check each BTS to by OnAir with all cell up, then calculate the number of resets and KPIs

    Log  Perform BTS Site Reset for iteration ${CYCLE}  console=True
    Set Test Variable  ${CYCLE}
    Create Dictionary with empty time values for each BTS
    FOR  ${alias}  IN  @{BTS_alias_list}
        ${label}=  Get From Dictionary  ${BTS_alias_label_dict}  ${alias}
        Set Test Variable  ${label}
        Log  Perform ${label} Site Reset  console=True
        Get RESET Timestamp Info  start    ${label}
        ${KeyIsPresent}=  Run Keyword And Return Status  Dictionary Should Contain Key  ${BTS_timestamps_start_reset}  ${label}
        ${BTS_timestamps_start_reset}=  Run Keyword If  ${KeyIsPresent}
        ...  Set To Dictionary    ${BTS_timestamps_start_reset}  ${label}  ${date_timestamp_start_UTC}
        Perform BTS Site Reset same time  ${alias}
    END
    Log  Step ${index}: Expect not reachable during reset for iteration ${CYCLE}  console=True
    FOR  ${alias}  IN  @{BTS_alias_list}
        ${label}=  Get From Dictionary  ${BTS_alias_label_dict}  ${alias}
        Log  Check ${label} to be not reachable while Site Reset is ongoing  console=True
        Expect BTS to be not reachable   ${alias}
    END
    Log   Check BTS status after reset for iteration ${CYCLE}  console=True
    FOR  ${alias}  IN  @{BTS_alias_list}
        ${label}=  Get From Dictionary  ${BTS_alias_label_dict}  ${alias}
        Log  Check ${label} behavior after Site Reset  console=True
        Check BTS status after Site Reset same time  ${alias}
        Sleep    time_=5s    reason="Avoid items transitories states"
        Get RESET Timestamp Info  end  ${label}
        ${KeyIsPresent}=  Run Keyword And Return Status  Dictionary Should Contain Key  ${BTS_timestamps_end_reset}  ${label}
        ${BTS_timestamps_end_reset}=  Run Keyword If  ${KeyIsPresent}
        ...  Set To Dictionary    ${BTS_timestamps_end_reset}  ${label}  ${date_timestamp_end_UTC}
        Check all BTS reset behavior based on IMS info  ${alias}  1
        Get and check KPI1a info from IMS file  ${alias}
    END
    Run Keyword If  '${BTS_LIST}' != 'ALL'  Check status of BTSs that are not in reset list

Check status of BTSs that are not in reset list
    [Documentation]
    ...  Check status of BTSs that are not in BTS_LIST list, expecting to find 0 Resets on them and all cells availability status online

    Log   Check BTS status for the ones that are not in reseting list after reset for iteration ${CYCLE}  console=True
    ${list_start_times} =  Get Dictionary Values  ${BTS_timestamps_start_reset}  sort_keys=False
    ${list_end_times} =  Get Dictionary Values  ${BTS_timestamps_end_reset}  sort_keys=False
    ${first_start_reset_UTC}=    Set Variable    ${list_start_times}[0]
    ${last_stop_reset_UTC}=     Set Variable    ${list_end_times}[-1]
    ${first_BTS_to_reset_label} =    Get From Dictionary  ${BTS_alias_label_dict}   ${BTS_alias_list}[0]
    ${first_start_reset}=    Set Variable      ${time_bts_reset_${first_BTS_to_reset_label}_}
    FOR  ${alias}  IN  @{BTS_remaining_alias_list}
        ${label}=  Get From Dictionary  ${BTS_alias_label_dict}  ${alias}
        Log  Check ${label} behavior after Site Reset  console=True
        Set To Dictionary  ${BTS_timestamps_start_reset}     ${label}     ${first_start_reset_UTC}
        Set To Dictionary  ${BTS_timestamps_end_reset}     ${label}     ${last_stop_reset_UTC}
        Check BTS status for the ones that are not reseting  ${alias}  ${first_start_reset}
        Check all BTS reset behavior based on IMS info  ${alias}  0
    END

Step ${index}: Check final number and state of Cells and RMs
    [Documentation]
    ...  Cells state is checked according to operationalState attribute
    ...  Check if number of configured cells and radio modules in SCF are properly mapping on BTS running view.
    ...  Also check RMs operationalState

    [Timeout]  30 min
    Log  Step ${index}: Check final number and state of Cells and RMs  console=True
    RFS Test Case Final Checks

Get RESET timestamp info
    [Arguments]  ${when}  ${label}
    Get Current Date UTC info low delay    ${when}
    Log    ${label} UTC ${when}_point_timestamp: ${date_timestamp_${when}_UTC}  console=True

Get Current Date UTC info low delay
    [Arguments]  ${when}
    Sleep  1s  reason=Avoid time desynchronization
    ${current_date}=  Get Current Date  time_zone=UTC
    Set Test Variable  ${date_timestamp_${when}_UTC}  ${current_date}
    Sleep  1s  reason=Avoid time desynchronization

Perform BTS Site Reset same time
    [Documentation]
    ...  Perform BTS Site Reset
    [Arguments]  ${alias}
    Set Test Variable  ${CELL_state_enabled_check}  operationalState=${Enabled_}, blockingState=${Unblocked_}
    Set Test Variable  ${CELL_state_enabled}  operationalState=Enabled, blockingState=Unblocked
    ${label}=  Get From Dictionary  ${BTS_alias_label_dict}  ${alias}
    Log  Perform "Reset Site" operation on ${label} from Admin  console=True
    Get Current Time  bts_reset_${label}
    RFS Site Reset  connection=${alias}  graceful_cell_shutdown=${GRACEFUL_CELL_SHUTDOWN}

Expect BTS to be not reachable
    [Documentation]
    ...  Check the BTS is indeed Reseting by checking if it is "Not Reachable"
    [Arguments]  ${alias}
    ${BTS_LMP_IP_address}=  Set Variable  ${${alias.upper()}}[${alias.upper()}_TECH_IP_ADDRESS]
    ${remote_host_ip}=  Set Variable If  '${alias}' == 'Master'  None  ${${alias.upper()}}[${alias.upper()}_PC_IP_ADDRESS]
    Wait For Target To Be Not Reachable TAF  hostname=${BTS_LMP_IP_address}  remote_host=${remote_host_ip}  timeout=180

Check BTS status after Site Reset same time
    [Documentation]
    ...  Check if BTS is OnAir and Check cells availability status online within the user given time
    [Arguments]  ${alias}
    ${label}=  Get From Dictionary  ${BTS_alias_label_dict}  ${alias}
    Log  ***** Check ${label} status and cells states after "Reset Site" *****  console=True
    ${time_bts_reset_} =   Set Variable      ${time_bts_reset_${label}_}
    ${remained_MAX_WAIT_TIME}=  Get elapsed time  ${time_bts_reset_}  ${BTS_MAX_WAIT_TIME}
    Admin Check BTS Procedural and Blocking states  ${OnAir_}  ${Unblocked_}  ${remained_MAX_WAIT_TIME}  ${alias}
    Log  ${label} site - proceduralState: OnAir, blockingState: Unblocked, as expected!  console=True

    ${remained_MAX_WAIT_TIME}=  Get elapsed time  ${time_bts_reset_}  ${BTS_MAX_WAIT_TIME}
    Admin Check BTS RAT cells expected states  ${CELL_state_enabled_check}  ${alias}  ${remained_MAX_WAIT_TIME}
    Log  All ${label} cell(s) status:\n - ${CELL_state_enabled}  console=True
    ${remained_MAX_WAIT_TIME}=  Get elapsed time  ${time_bts_reset_}  ${BTS_MAX_WAIT_TIME}
    Check cells availability status online  ${alias}  ${remained_MAX_WAIT_TIME}

Check BTS status for the ones that are not reseting
    [Documentation]
    ...  Check if BTS is OnAir and Check cells availability status online within the user given time
    ...  A 40sec extra time is added to  BTS_MAX_WAIT_TIME to compensate in error cases for time lost running the other keywords
    [Arguments]  ${alias}    ${last_start_reset}
    ${label}=  Get From Dictionary  ${BTS_alias_label_dict}  ${alias}
    Log  ***** Check ${label} status and cells states *****  console=True
    ${time_bts_reset_} =   Set Variable      ${last_start_reset}
    ${BTS_MAX_WAIT_TIME_added} =    Evaluate    ${BTS_MAX_WAIT_TIME} + 40
    ${remained_MAX_WAIT_TIME}=  Get elapsed time  ${time_bts_reset_}  ${BTS_MAX_WAIT_TIME_added}
    Admin Check BTS Procedural and Blocking states  ${OnAir_}  ${Unblocked_}  ${remained_MAX_WAIT_TIME}  ${alias}
    Log  ${label} site - proceduralState: OnAir, blockingState: Unblocked, as expected!  console=True

    ${remained_MAX_WAIT_TIME}=  Get elapsed time  ${time_bts_reset_}  ${BTS_MAX_WAIT_TIME_added}
    Admin Check BTS RAT cells expected states  ${CELL_state_enabled_check}  ${alias}  ${remained_MAX_WAIT_TIME}
    Log  All ${label} cell(s) status:\n - ${CELL_state_enabled}  console=True
    ${remained_MAX_WAIT_TIME}=  Get elapsed time  ${time_bts_reset_}  ${BTS_MAX_WAIT_TIME_added}
    Check cells availability status online  ${alias}  ${remained_MAX_WAIT_TIME}

Check all BTS reset behavior based on IMS info
    [Documentation]
    ...  BTS RESET info is checked based on IMS info. Reset behavior as expected if:
    ...  - BTS ${alias} site resets == ${expected_reset_count}
    ...  Otherwise, reset behavior not as expected, then errors are added to report and failed.
    [Arguments]  ${alias}  ${expected_reset_count}

    Log  Check all BTS reset behavior based on IMS info  console=True
    ${label}=  Get From Dictionary  ${BTS_alias_label_dict}  ${alias}
    ${date_timestamp_start_UTC} =    Get From Dictionary    ${BTS_timestamps_start_reset}  ${label}
    ${date_timestamp_end_UTC} =    Get From Dictionary    ${BTS_timestamps_end_reset}  ${label}
    Set Variable    ${date_timestamp_start_UTC}=  Get From Dictionary   ${BTS_timestamps_start_reset}  ${label}
    ${date_timestamp_end_UTC}=  Get From Dictionary   ${BTS_timestamps_end_reset}  ${label}
    Get and check BTS RESET info from IMS file  expected_reset_number=${expected_reset_count}  alias=${alias}
    ...  start_point_timestamp_UTC=${date_timestamp_start_UTC}  end_point_timestamp_UTC=${date_timestamp_end_UTC}

Get and check KPI1a info from IMS file
    [Documentation]
    ...  Get and check KPI1a info from IMS file.
    [Arguments]  ${alias}

    Log  Get and check KPI1a info from IMS file  console=True
    ${label}=  Get From Dictionary  ${BTS_alias_label_dict}  ${alias}
    ${date_timestamp_start_UTC} =    Get From Dictionary    ${BTS_timestamps_start_reset}  ${label}
    ${date_timestamp_end_UTC} =    Get From Dictionary    ${BTS_timestamps_end_reset}  ${label}
    ${kpi_name_delta_dict}=  Get and check KPI info from IMS file  kpi_names=kpi1a  kpi_thresholds=${${label}_RESET_WRN_THR}  alias=${alias}
    ...  start_point_timestamp_UTC=${date_timestamp_start_UTC}  end_point_timestamp_UTC=${date_timestamp_end_UTC}
    ${kpi_delta_list}=  Get From Dictionary  ${kpi_name_delta_dict}  kpi1a

    Export KPI Results to File  alias=${alias}  obj=BTS  obj_type=SBTS  obj_id=${label}  action_1=Site_Reset  kpi_reported_1=KPI_1a
    ...  event_value_1=${kpi_delta_list[0]}  cycle=${CYCLE}  source_info=ims

Create Dictionary with empty time values for each BTS
    [Documentation]
    ...  Create two Dictionaries to store Reset start and end UTC times for each BTS, to be used in KPI calculation and debugging
    ${BTS_timestamps_start_reset} =  Create Dictionary
    ${BTS_timestamps_end_reset} =  Create Dictionary
    ${length}=  Get Length  ${BTS_label_list}
    FOR  ${index}  IN RANGE   ${length}
        Set To Dictionary  ${BTS_timestamps_start_reset}  ${BTS_label_list}[${index}]  0
        Set To Dictionary  ${BTS_timestamps_end_reset}  ${BTS_label_list}[${index}]  0
    END
    Set Test Variable    ${BTS_timestamps_start_reset}
    Set Test Variable    ${BTS_timestamps_end_reset}

Hardware File Teardown
    Return From Keyword If  '${SWCONFIG_CHANGE_FLAG}' == 'False'
    FOR  ${alias}  IN  @{BTS_alias_list}
        Recover HWF Flags  alias=${alias}
    END

Particular Teardown
    Hardware File Teardown
    Export KPI results to File Global  kpi_log_file_name=KpiTimeInfo

TC Setup
    ${tech_preset_list}=  Create List  SBTS  SBTS  SBTS  SBTS
    Common Test Setup  preset_techs=${tech_preset_list}  common_sbts=${TRUE}  infomodelSetup=${FALSE}  newAlarmsFormat=${TRUE}

TC Teardown
    Common Test Teardown
