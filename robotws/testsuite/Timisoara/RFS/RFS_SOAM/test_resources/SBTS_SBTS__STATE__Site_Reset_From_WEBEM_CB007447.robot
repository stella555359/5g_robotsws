*** Settings ***
Documentation    TC__SBTS_SBTS__STATE__Site_Reset_From_WEBEM_CB007447
Variables    tc_variables/sbts_sbts__state__site_reset_from_webem_cb007447_alarms_definitions.py
Resource    ../../resources/rfs_frame_rfs_soam_taf.robot

*** Variables ***
${REPEAT_COUNTER}            3       # Number of link break operations, default value 3
${BTS_RESET}                 BOTH    # BTS list on which reset operation will be performed. Possible values (by default BOTH):
                                     # - BOTH: action will be performed on both BTS
                                     # - one selected BTS labelized as BTSx (x is test_pc number in init.py) (ex. BTS1)
${KPI_LIST}                  kpi1a   # Reset Site KPI label list separated by comma. Possible values (by default kpi1a):
                                     # - kpi1a: Time spent between first cell down to last cell up
                                     # - kpi1b: Time spent between last cell down to first cell up
                                     # - kpi1c: Time spent between reset request to first cell up
${BTS1_RESET_WRN_THR_LIST}   600     # BTS1 KPI value list separated by comma. They should be correlated with Reset Site KPI label list.
                                     # By default 600 (secs) for kpi1a
${BTS2_RESET_WRN_THR_LIST}   600     # BTS2 KPI value list separated by comma. They should be correlated with Reset Site KPI label list.
                                     # By default 600 (secs) for kpi1a
${cpriSyncBreakTime}                 # cpriSyncBreakTime duration in ms; possible values: 100...10000, step 100ms; ex: 500
${stickToSyncSourcePeriod}           # stickToSyncSourcePeriod duration in ms; possible values: 0...10000, step 10ms; ex: 400
${SET_PRIMARY_LINK_TIME}     720     # Maximum time in seconds to wait for Primary Link set on ${BTS_PRIMARY_LINK}, default value: 720
${BTS_MAX_WAIT_TIME}         900     # Maximum time to wait for BTS OnAir after reset
${PM_Counters_Check}         True    # PM counters check Flag for checking M40015C10 (short link break) and M40015C11 (long link break).
                                     # Possible values: True or False; by default: True
${DELAY_BETWEEN_SNAPSHOTS}   30      # In case of Snapshot collections during test (PM_Counters_Check=True and PM Counter Check fail),
                                     # defined as the delay time between Snapshot collections measured in seconds. Default value: 30
${GRACEFUL_CELL_SHUTDOWN}    False   # Graceful cell shutdown: True or False; default value: False
${ASOx_counters_flag}        False   # Flag for checking dedicated ASOx counters M40014C10 and M40014C11; Possible values: True, False;
                                     # Default value: False

*** Keywords ***
TC__SBTS_SBTS__STATE__Site_Reset_From_WEBEM_CB007447
    [Documentation]
    ...  [CASE LINK]: https://jiradc.ext.net.nokia.com/browse/TAT-27898
    ...
    ...  *****************
    ...  Basic information
    ...  *****************
    ...  SBTS-SBTS test case for SBTS Site Reset From WEBEM CB007447 - x times sequence.
    ...
    ...  The main steps performed for the test are:
    ...
    ...  - check initial states and alarms for both BTS
    ...  - get both BTS info for configured items: shared RM info
    ...  - check feature CB007447 status on both BTS and activate it if needed
    ...  - set primary synchronization link on BTS which will be reset
    ...  - perform site reset on BTS holding primary synchronization link
    ...  - check peer BTS CPRI RMOD and mapping cells behavior - expecting no impact
    ...  - check final states and alarms for both BTS
    ...
    ...  Pass criteria: Scenario works as expected, states and alarms are as expected
    ...  ******************
    ...  History of changes
    ...  ******************
    ...  - 08.10.2024 - https://jiradc.ext.net.nokia.com/browse/TAT-27898 - TC Delivery
    ...  - 25.10.2024 - https://jiradc.ext.net.nokia.com/browse/TAT-28270 - [5G][CB007447] PM delivery for
    ...  SBTS_SBTS__STATE__Site_Reset_From_WEBEM_CB007447.robot
    ...  - 25.10.2024 - https://jiradc.ext.net.nokia.com/browse/TAT-28292 - [5G] SBTS_SBTS__STATE__Site_Reset_From_WEBEM_CB007447 DSS alarms
    ...  improvement - with TAT-28270
    ...  - 21.11.2024 - https://jiradc.ext.net.nokia.com/browse/TAT-28366 - Counters M40014C10 and M40014C11 should be checked in case SBTS has
    ...  ASOx board configured and not the BBMOD ones
    ...  - 08.10.2025 - https://jiradc.ext.net.nokia.com/browse/TAT-29958 - TC fails if BTS_RESET is other than BOTH
    ...  - 23.10.2025 - https://jiradc.ext.net.nokia.com/browse/TAT-30022 - Improve counters reading mechanism for Primary Link Break CB007447
    ...  - 21.10.2025 - https://jiradc.ext.net.nokia.com/browse/TAT-29964 -
    ...  [CB012999] SBTS_SBTS__STATE__Site_Reset_From_WEBEM_CB007447 should be modified to check KPI-1b
    ...  - 17.11.2025 - https://jiradc.ext.net.nokia.com/browse/TAT-30185 - Adapt SBTS_SBTS__STATE__Uncontrolled_L1Soc_Reset_CB010846 with
    ...  ${actForceUnitAutoReset}' == 'false' case when CB007447 is enabled
    ...  - 27.11.2025 - https://jiradc.ext.net.nokia.com/browse/TAT-30221 - Remove ${actForceUnitAutoReset}' in tests and KWs related to CB007447
    ...

    Set Tags    CA-STATE    OWNER-raul.caraiman@nokia.com    AUTHOR-gabriel.stanculescu@nokia.com    PHASE-QT    SW-SBTS25R1

    TC Preconditions
    Step 1: Check initial both BTS state
    Step 2: Check initial both BTS alarms
    Step 3: Get both BTS info for configured items
    Step 4: Check and activate feature CB007447 on both BTS
    FOR  ${INDEX}  IN RANGE  1  ${REPEAT_COUNTER}+1
        Log  ==============================================================================  console=True
        Log  Start Cycle ${INDEX} of ${REPEAT_COUNTER}  console=True
        Log  ==============================================================================  console=True
        Step 5: Perform BTS Site Reset for iteration ${INDEX}
        Step 6: Check final both BTS state
        Step 7: Check final both BTS state
        Step 8: Check final number and state of Cells and RMs
    END
    Check TC Verdict

    [Teardown]  Particular Teardown

TC Preconditions
    ${BTS_alias_label_dict}  ${BTS_label_alias_dict}=  Get BTS alias label info dict
    Set Test Variable  ${BTS_alias_label_dict}
    Set Test Variable  ${BTS_label_alias_dict}
    ${BTS_alias_list}=  Get Dictionary Keys  ${BTS_alias_label_dict}  False
    ${BTS_label_list}=  Get Dictionary Values  ${BTS_alias_label_dict}  False
    Set Test Variable  ${BTS_alias_list}
    Set Test Variable  ${BTS_label_list}

    Run Keyword If  '${cpriSyncBreakTime}' == ''  Run Keywords
    ...  Log  Please select a proper value for test argument \${cpriSyncBreakTime}.  console=True
    ...  AND  Fail  Improper value for argument!

    Run Keyword If  '${stickToSyncSourcePeriod}' == ''  Run Keywords
    ...  Log  Please select a proper value for test argument \${stickToSyncSourcePeriod}.  console=True
    ...  AND  Fail  Improper value for argument!

    Run Keyword If  '${PM_Counters_Check}' == 'True'  Set Test Variable  ${TC_verdict_counters}  PASS

    Run Keyword If  '${BTS_RESET}' != 'BOTH'  Check BTS list
    Log  ====================================================  console=True
    Log  BTS label list selected for reset operation: ${BTS_label_list}  console=True
    Log  BTS alias list selected for reset operation: ${BTS_alias_list}  console=True
    Log  ====================================================  console=True

    Check KPI label list
    Check KPI value list

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

        Continue For Loop If  '${PM_Counters_Check}' != 'True'

        Get BTS MODULE LANE info dict  RMOD  ${alias}
        Set Test Variable  ${${alias}_MODULE_LANE_dict}  ${MODULE_LANE_dict}

        Check initial mt param   ${alias}  mtSbtsSfpBbmodLane
        Check initial mt param   ${alias}  mtSbtsSfpSmodLane
    END

    Get all SMOD board types

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

    Run Keyword If   not ${Slave_CB007447_check}  Run Keywords
    ...  Log  Activating feature CB007447 on BTS Slave!  console=True
    ...  AND  Set feature CB007447 on BTS
    ...  cpriSyncBreakTime_value=${cpriSyncBreakTime}  stickToSyncSourcePeriod_value=${stickToSyncSourcePeriod}  alias=Slave
    ...  AND  Check final feature CB007447 status  Slave
    ...  AND  Set Test Variable  ${Slave_CB007447_check}  True
    ...  AND  Check BTS alarms after activate CB007447 feature  Master  Slave  0
    ...  AND  Check BTS alarms after activate CB007447 feature  Slave  Slave  0

Step ${index}: Perform BTS Site Reset for iteration ${CYCLE}
    [Documentation]
    ...  Perform BTS Site Reset

    Log  Step ${index}: Perform BTS Site Reset for iteration ${CYCLE}  console=True
    Set Test Variable  ${CYCLE}
    FOR  ${alias}  IN  @{BTS_alias_list}
        ${peer_alias}=  Set Variable If  '${alias}' == 'Master'  Slave  Master
        Set Test Variable  ${peer_alias}
        Log  ***** Perform Reset Site on BTS ${alias} *****  console=True
        Set shared RMOD Primary Link before Reset Site on BTS  ${alias}
        Get shared RMOD Primary Link impact on peer BTS  ${alias}
        Get RESET timestamp info  start
        Perform BTS Site Reset  ${alias}
        Get RESET timestamp info  end
        Check both BTS reset behavior based on IMS info  ${alias}
        Get and check BTS KPI info from IMS file  ${alias}
        Check peer BTS CPRI RMOD behavior during BTS Site Reset from IMS  ${alias}
        Run Keyword If  '${PM_Counters_Check}' == 'True'  Check peer BTS CPRI RMOD PM counters
    END

Step ${index}: Check final number and state of Cells and RMs
    [Documentation]
    ...  Following checks are performed:
    ...  - number of configured cells and radio modules in SCF are properly mapped on BTS running view ADMIN
    ...  - check cells states
    ...  - check radio modules states

    Log  Step ${index}: Check final number and state of Cells and RMs  console=True
    RFS Test Case Final Checks

Check TC Verdict
    Return From Keyword If  '${PM_Counters_Check}' != 'True'
    Run Keyword If  '${TC_verdict_counters}' == 'FAIL'
    ...  Fail  At least one PM counter check was failed during TC execution!

Check BTS list
    ${BTS_LIST_strip}=  Replace String  ${BTS_RESET}  ${SPACE}  ${EMPTY}
    ${BTS_RESET}=  Split String  ${BTS_LIST_strip}  ,
    ${BTS_check}=  Set Variable  True
    ${BTS_invalid_label_list}=  Create List
    ${BTS_request_label_list}=  Create List
    ${BTS_request_alias_list}=  Create List

    FOR  ${item}  IN  @{BTS_RESET}
        ${BTS_check}=  Set Variable If  '${item}' not in ${BTS_label_list}  False  ${BTS_check}
        Run Keyword If  '${item}' not in ${BTS_label_list}
        ...  Append To List  ${BTS_invalid_label_list}  ${item}
        ...  ELSE
        ...  Append To List  ${BTS_request_label_list}  ${item}
    END

    Run Keyword If  '${BTS_check}' == 'False'  Run Keywords
    ...  Log Long String  Following selected BTS are not valid: ${BTS_invalid_label_list}. Please select values for test argument \${BTS_RESET} from
    ...  configured BTS: ${BTS_label_list} or let default value: ALL  console=True
    ...  AND  Fail  Improper value for argument!

    FOR  ${item}  IN  @{BTS_request_label_list}
        ${BTS_request_alias}=  Get From Dictionary  ${BTS_label_alias_dict}  ${item}
        Append To List  ${BTS_request_alias_list}  ${BTS_request_alias}
    END

    Set Test Variable  ${BTS_label_list}  ${BTS_request_label_list}
    Set Test Variable  ${BTS_alias_list}  ${BTS_request_alias_list}

Check KPI label list

    ${RESET_SITE_KPI_official_list}=  Create List  kpi1a  kpi1b  kpi1c

    ${RESET_SITE_KPI_list_strip}=  Replace String  ${KPI_LIST}  ${SPACE}  ${EMPTY}
    ${RESET_SITE_KPI_list}=  Split String  ${RESET_SITE_KPI_list_strip}  ,
    ${KPI_label_check}=  Set Variable  True
    ${KPI_invalid_label_list}=  Create List
    ${KPI_request_label_list}=  Create List
    ${KPI_request_alias_list}=  Create List

    FOR  ${kpi}  IN  @{RESET_SITE_KPI_list}
        ${KPI_label_check}=  Set Variable If  '${kpi}' not in ${RESET_SITE_KPI_official_list}  False  ${KPI_label_check}
        Run Keyword If  '${kpi}' not in ${RESET_SITE_KPI_official_list}
        ...  Append To List  ${KPI_invalid_label_list}  ${kpi}
        ...  ELSE
        ...  Append To List  ${KPI_request_label_list}  ${kpi}
    END

    Run Keyword If  '${KPI_label_check}' == 'False'  Run Keywords
    ...  Log Long String  Following selected KPI are not valid: ${KPI_invalid_label_list}. Please select values for test argument \${KPI_LIST} from
    ...  official Reset Site KPI list: ${RESET_SITE_KPI_official_list} or let default value: kpi1a  console=True
    ...  AND  Fail  Improper value for argument!

    Set Test Variable  ${RESET_SITE_KPI_list}  ${KPI_request_label_list}
    ${RESET_SITE_KPI_count}=  Get Length  ${RESET_SITE_KPI_list}
    Set Test Variable  ${RESET_SITE_KPI_count}

Check KPI value list

    FOR  ${item}  IN  @{BTS_alias_list}

        Get and check BTS KPI values  ${item}

    END

Get and check BTS KPI values
    [Arguments]  ${alias}

    ${label}=  Get From Dictionary  ${BTS_alias_label_dict}  ${alias}
    ${BTS_RESET_WRN_THR_LIST}=  Set Variable  ${${label}_RESET_WRN_THR_LIST}
    ${BTS_RESET_WRN_THR_list_strip}=  Replace String  ${BTS_RESET_WRN_THR_LIST}  ${SPACE}  ${EMPTY}
    ${RESET_SITE_KPI_values_list}=  Split String  ${BTS_RESET_WRN_THR_list_strip}  ,
    ${RESET_SITE_KPI_values_count}=  Get Length  ${RESET_SITE_KPI_values_list}

    Run Keyword If  ${RESET_SITE_KPI_values_count} != ${RESET_SITE_KPI_count}  Run Keywords
    ...  Log Long String  Number of KPI values set for test argument \${${label}_RESET_WRN_THR_LIST} is not aligned with number of selected KPI for
    ...  Reset Site operation. Please align values for \${${label}_RESET_WRN_THR_LIST} according to \${KPI_LIST} info or let default value:
    ...  600!  console=True
    ...  AND  Fail  Improper value for argument!

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

Convert PM duration to seconds
    [Arguments]  ${pm_duration}

    ${pm_duration_value}=  Fetch From Left  ${pm_duration}  min
    ${pm_duration_value}=  Strip String  ${pm_duration_value}
    ${pm_duration_value_int}=  Convert To Integer  ${pm_duration_value}
    ${pm_duration_value_seconds}=  Evaluate  ${pm_duration_value_int}*60
    [Return]  ${pm_duration_value_seconds}

Check initial feature CB007447 status
    [Arguments]  ${alias}

    Log  Check initial feature CB007447 status on BTS ${alias}:  console=True

    ${actCpriLinkRecovery_initial}  ${actSyncLinkSwitchover_initial}  ${cpriSyncBreakTime_initial}  ${stickToSyncSourcePeriod_initial}=
    ...  Get feature CB007447 info  ${alias}

    Log  Initial actCpriLinkRecovery parameter value: ${actCpriLinkRecovery_initial}  console=True
    Log  Initial actSyncLinkSwitchover parameter value: ${actSyncLinkSwitchover_initial}  console=True
    Log  Initial cpriSyncBreakTime parameter value: ${ cpriSyncBreakTime_initial}  console=True
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

Set shared RMOD Primary Link before Reset Site on BTS
    [Arguments]  ${alias}
    [Documentation]
    ...  Set RMOD Primary Link if needed

    Log  Set shared RMOD Primary Link before Reset Site on BTS ${alias}  console=True
    Log  =============================================================================  console=True
    Log  ***** Test action will be performed with Primary Link set on BTS ${alias} *****  console=True
    Log  =============================================================================  console=True
    Set Primary Link status based on linkModeSynchronization by LANE lock unlock procedure
    ...  module_type=RMOD  alias=${alias}  wait_for_Primary_Link_set=${SET_PRIMARY_LINK_TIME}

Get shared RMOD Primary Link impact on peer BTS
    [Arguments]  ${alias}

    Log  Get shared RMOD Primary Link impact on BTS ${peer_alias}   console=True
    ${all_BTS_PL_shared_RM_info}=  Get PL shared RM info on all BTS
    ${BTS_PL_shared_RM_info}=  Get From Dictionary  ${all_BTS_PL_shared_RM_info}  ${alias}
    ${BTS_PL_CPRI_shared_RM_sn_list}=  Get From Dictionary  ${BTS_PL_shared_RM_info}  BTS_PL_CPRI_shared_RM_sn_list
    ${BTS_PL_ECPRI_shared_RM_sn_list}=  Get From Dictionary  ${BTS_PL_shared_RM_info}  BTS_PL_ECPRI_shared_RM_sn_list

    ${peer_BTS_PL_shared_RM_info}=  Get From Dictionary  ${all_BTS_PL_shared_RM_info}  ${peer_alias}

    ${peer_BTS_PL_CPRI_shared_RM_sn_list}=  Get From Dictionary  ${peer_BTS_PL_shared_RM_info}  BTS_PL_CPRI_shared_RM_sn_list
    ${peer_BTS_PL_ECPRI_shared_RM_sn_list}=  Get From Dictionary  ${peer_BTS_PL_shared_RM_info}  BTS_PL_ECPRI_shared_RM_sn_list

    ${peer_BTS_non_PL_CPRI_shared_RM_sn_list}=  Get From Dictionary  ${peer_BTS_PL_shared_RM_info}  BTS_non_PL_CPRI_shared_RM_sn_list
    ${peer_BTS_non_PL_ECPRI_shared_RM_sn_list}=  Get From Dictionary  ${peer_BTS_PL_shared_RM_info}  BTS_non_PL_ECPRI_shared_RM_sn_list
    ${peer_BTS_non_PL_ECPRI_shared_RM_id_list}=  Get From Dictionary  ${peer_BTS_PL_shared_RM_info}  BTS_non_PL_ECPRI_shared_RM_id_list

    ${peer_BTS_non_PL_not_excepted_ECPRI_shared_RMOD_list}  ${peer_BTS_non_PL_excepted_ECPRI_shared_RMOD_list}=
    ...  Get excepted and not excepted RMOD lists  ${peer_BTS_non_PL_ECPRI_shared_RM_id_list}  ${RMOD_ECPRI_fid16_exceptions}  ${peer_alias}
    ${peer_BTS_non_PL_excepted_ECPRI_shared_RMOD_list_count}=  Get Length  ${peer_BTS_non_PL_excepted_ECPRI_shared_RMOD_list}

    ${peer_BTS_CPRI_alarm_count}=  Calculate peer BTS alarms count  ${BTS_PL_CPRI_shared_RM_sn_list}
    ...  ${peer_BTS_non_PL_CPRI_shared_RM_sn_list}
    ${peer_BTS_ECPRI_alarm_count}=  Calculate peer BTS alarms count  ${BTS_PL_ECPRI_shared_RM_sn_list}
    ...  ${peer_BTS_non_PL_not_excepted_ECPRI_shared_RMOD_list}

    Log  BTS ${peer_alias} impacted CPRI shared RMOD count: ${peer_BTS_CPRI_alarm_count}   console=True
    Log  BTS ${peer_alias} impacted ECPRI shared RMOD count: ${peer_BTS_ECPRI_alarm_count}   console=True

    Set Test Variable  ${${peer_alias}_FID16_alarm_count}  ${peer_BTS_ECPRI_alarm_count}

    ${EXPECTED_ALARMS}=  Create List
    ${EXPECTED_ALARMS_16_full}=  Prepare expected alarms list  ${test_alarms_list['${peer_alias.upper()}_EXPECTED_ALARMS_16']}
    ...  ${peer_BTS_ECPRI_alarm_count}
    ${EXPECTED_ALARMS}=  Set Variable If  ${peer_BTS_ECPRI_alarm_count} == 0  ${EXPECTED_ALARMS}  ${EXPECTED_ALARMS_16_full}
    Set Test Variable  ${${peer_alias.upper()}_EXPECTED_ALARMS}  ${EXPECTED_ALARMS}

Calculate peer BTS alarms count
    [Arguments]  ${BTS_PL_shared_RM_sn_list}  ${peer_BTS_non_PL_shared_RM_sn_list}
    ${peer_BTS_alarm_count}=  Set Variable  0

    FOR  ${item}  IN  @{BTS_PL_shared_RM_sn_list}
        ${peer_BTS_alarm_count}=  Run Keyword If  '${item}' in ${peer_BTS_non_PL_shared_RM_sn_list}
        ...  Evaluate  ${peer_BTS_alarm_count} + 1
        ...  ELSE
        ...  Evaluate  ${peer_BTS_alarm_count} + 0
    END

    [Return]  ${peer_BTS_alarm_count}

Get RESET timestamp info
    [Arguments]  ${when}

    Get Current Date UTC info  ${when}
    Log  UTC ${when}_point_timestamp: ${date_timestamp_${when}_UTC}  console=True

Perform BTS Site Reset
    [Arguments]  ${alias}
    Set Test Variable  ${CELL_state_enabled_check}  operationalState=${Enabled_}, blockingState=${Unblocked_}
    Set Test Variable  ${CELL_state_enabled}  operationalState=Enabled, blockingState=Unblocked

    Log  Perform "Reset Site" operation on BTS ${alias} from Admin  console=True
    Run Keyword If  '${PM_Counters_Check}' == 'True'  Synchronize link break event to PM generation  ${alias}  mtSbtsSfpSmodLane

    Get Current Time  bts_reset
    coam.Reset Site  wait_for_reconnection=False  connection=${alias}  graceful_cell_shutdown=${GRACEFUL_CELL_SHUTDOWN}

    Run Keyword If  '${PM_Counters_Check}' == 'True'  Get epoch time after Reset Site

    ${BTS_LMP_IP_address}=  Set Variable  ${${alias.upper()}}[${alias.upper()}_TECH_IP_ADDRESS]
    ${remote_host_ip}=  Set Variable If  '${alias}' == 'Master'  None  ${${alias.upper()}}[${alias.upper()}_PC_IP_ADDRESS]
    Wait For Target To Be Not Reachable TAF  hostname=${BTS_LMP_IP_address}  remote_host=${remote_host_ip}  timeout=300

    Log  ***** Check BTS ${peer_alias} alarms during "Reset Site" operation on BTS ${alias} *****  console=True
    Check peer BTS states and alarms during Site Reset

    Log  ***** Check BTS ${alias} status and alarms after "Reset Site" operation on BTS ${alias} *****  console=True
    Log  Check BTS ${alias} status:  console=True

    ${remained_MAX_WAIT_TIME}=  Get elapsed time  ${time_bts_reset}  ${BTS_MAX_WAIT_TIME}
    Admin Check BTS Procedural and Blocking states  ${OnAir_}  ${Unblocked_}  ${remained_MAX_WAIT_TIME}  ${alias}
    Log  BTS ${alias} site - proceduralState: OnAir, blockingState: Unblocked, as expected!  console=True

    ${remained_MAX_WAIT_TIME}=  Get elapsed time  ${time_bts_reset}  ${BTS_MAX_WAIT_TIME}
    Admin Check BTS RAT cells expected states  ${CELL_state_enabled_check}  ${alias}  ${remained_MAX_WAIT_TIME}
    Log  All BTS ${alias} cell(s) status:\n - ${CELL_state_enabled}  console=True
    ${remained_MAX_WAIT_TIME}=  Get elapsed time  ${time_bts_reset}  ${BTS_MAX_WAIT_TIME}
    Check cells availability status online  ${alias}  ${remained_MAX_WAIT_TIME}

    Log  Check BTS ${alias} alarms:  console=True
    Get and Check Alarms SOAM  alias=${alias}  expected_alarms=@{EMPTY}  ignored_alarms=${test_alarms_list['${alias.upper()}_IGNORED_ALARMS']}
    ...  critical_alarms=${test_alarms_list['${alias.upper()}_CRITICAL_ALARMS']}
    Log  BTS ${alias} site - expected, ignored and critical alarms checked  console=True

    Log  ***** Check BTS ${peer_alias} status and alarms after "Reset Site" operation on BTS ${alias} *****  console=True
    Check peer BTS states and alarms after Site Reset

Get epoch time after Reset Site
    ${event_epoch_time}=  GET event epoch time
    Set Test Variable  ${reset_site_event_epoch_time}  ${event_epoch_time}
    Log  Reset Site event epoch time: ${reset_site_event_epoch_time}  console=True

GET event epoch time
    ${epoch_time}=  OperatingSystem.Run    date +%s
    [Return]  ${epoch_time}

Check peer BTS states and alarms during Site Reset
    ${IGNORED_ALARMS_full}=  Combine Lists  ${test_alarms_list['${peer_alias.upper()}_IGNORED_ALARMS']}
    ...  ${test_alarms_list['${peer_alias.upper()}_IGNORED_ALARMS_DSS']}  ${test_alarms_list['${peer_alias.upper()}_IGNORED_ALARMS_SYNC']}

    Log  Check BTS ${peer_alias} alarms:  console=True
    Run Keyword If  ${${peer_alias}_FID16_alarm_count} > 0
    ...  Log  BTS ${peer_alias} "Unit synchronization failed (16)" alarm, expected number: ${${peer_alias}_FID16_alarm_count}  console=True

    Get and Check Alarms SOAM  alias=${peer_alias}  expected_alarms=${${peer_alias.upper()}_EXPECTED_ALARMS}
    ...  ignored_alarms=${IGNORED_ALARMS_FULL}  critical_alarms=${test_alarms_list['${peer_alias.upper()}_CRITICAL_ALARMS']}

    Run Keyword If  ${${peer_alias}_FID16_alarm_count} > 0
    ...  Log  BTS ${peer_alias} "Unit synchronization failed (16)" alarm, found number: ${${peer_alias}_FID16_alarm_count}, as expected!
    ...  console=True
    Log  BTS ${peer_alias} site - expected, ignored and critical alarms checked  console=True

Check peer BTS states and alarms after Site Reset
    Log  Check BTS ${peer_alias} status:  console=True

    ${remained_MAX_WAIT_TIME}=  Get elapsed time  ${time_bts_reset}  ${BTS_MAX_WAIT_TIME}
    Admin Check BTS Procedural and Blocking states  ${OnAir_}  ${Unblocked_}  ${remained_MAX_WAIT_TIME}  ${peer_alias}
    Log  BTS ${peer_alias} site - proceduralState: OnAir, blockingState: Unblocked, as expected!  console=True

    ${remained_MAX_WAIT_TIME}=  Get elapsed time  ${time_bts_reset}  ${BTS_MAX_WAIT_TIME}
    Admin Check all BTS cells expected states  ${CELL_state_enabled_check}  ${peer_alias}  ${remained_MAX_WAIT_TIME}
    Log  All BTS ${peer_alias} cell(s) status:\n - ${CELL_state_enabled}  console=True
    ${remained_MAX_WAIT_TIME}=  Get elapsed time  ${time_bts_reset}  ${BTS_MAX_WAIT_TIME}
    Check cells availability status online  ${peer_alias}  ${remained_MAX_WAIT_TIME}

    Log  Check BTS ${peer_alias} alarms:  console=True
    Get and Check Alarms SOAM  alias=${peer_alias}  expected_alarms=@{EMPTY}
    ...  ignored_alarms=${test_alarms_list['${peer_alias.upper()}_IGNORED_ALARMS']}
    ...  critical_alarms=${test_alarms_list['${peer_alias.upper()}_CRITICAL_ALARMS']}
    Log  BTS ${peer_alias} site - expected, ignored and critical alarms checked  console=True

Check peer BTS CPRI RMOD behavior during BTS Site Reset from IMS
    [Arguments]  ${alias}
    [Documentation]
    ...  Check CPRI RMOD and mapped cells states on peer BTS during BTS Reset

    Log  Check BTS ${peer_alias} CPRI RMOD behavior during BTS ${alias} Site Reset for iteration ${CYCLE}  console=True

    ${ims_file_path}=  Admin Collect IMS file with timestamp  folder_path=${Test Results Dir}/IMS/${peer_alias}  alias=${peer_alias}
    ${RMOD_L3Protocol_dict}=  Admin Get RMOD L3 Protocol Info  ${peer_alias}
    Set Test Variable  ${RMOD_L3Protocol_dict}
    ${CELL_mapped_on_CPRI_RMODs}=  Create List

    FOR  ${RMOD_id}  IN  @{${peer_alias}_module_list}
        ${RMOD_L3Protocol}=  Get From Dictionary  ${RMOD_L3Protocol_dict}  ${RMOD_id}
        Continue For Loop If  '${RMOD_L3Protocol}' != 'CPRI_RP1'
        Log  Checking BTS ${peer_alias} CPRI RMOD ${RMOD_id} states during BTS ${alias} reset  console=True
        Check IMS object states not changed  ${ims_file_path}  ${RMOD_id}  ${date_timestamp_start_UTC}  ${date_timestamp_end_UTC}  ${peer_alias}
        ${CELL_RM_list_temp}=  Get Cell Mapping By Module Id  module_id=${RMOD_id}  connection=${peer_alias}
        ${CELL_mapped_on_CPRI_RMODs}=  Combine Lists  ${CELL_mapped_on_CPRI_RMODs}  ${CELL_RM_list_temp}
    END
    ${CELL_mapped_on_CPRI_RMODs}=  Remove Duplicates  ${CELL_mapped_on_CPRI_RMODs}
    FOR  ${CELL_id}  IN  @{CELL_mapped_on_CPRI_RMODs}
        Log  Checking BTS ${peer_alias} CPRI RMOD mapped Cells states during BTS ${alias} reset  console=True
        Check IMS object states not changed  ${ims_file_path}  ${CELL_id}  ${date_timestamp_start_UTC}  ${date_timestamp_end_UTC}
        ...  ${peer_alias}
    END
    Log  All CPRI RMODs and mapped cells states checks passed.  console=True


Check IMS object states not changed
    [Arguments]  ${ims_file_path}  ${obj_id}  ${begin}  ${end}  ${alias}

    ${is_WNCEL}=  Run Keyword And Return Status  Should Contain  ${obj_id}  WNCEL
    Run Keyword If  ${is_WNCEL}  Run Keywords
    ...  Log  Skipping check on ${obj_id} since WCDMA is the only RAT that might change states  console=True
    ...  AND  Return From Keyword
    Log  No state changes expected on BTS ${alias} object ${obj_id}   console=True
    ${obj_updates}=  ims2alarms.Get Object Updates In Interval  file_path=${ims_file_path}  obj_dist_name=${obj_id}  begin=${begin}  end=${end}
    ...  obj_exact_match=True
    FOR  ${item}  IN  @{obj_updates}
        ${operationalState_found}=  Run Keyword And Return Status  Dictionary Should Contain Key  ${item}  operationalState
        Run Keyword If  ${operationalState_found}
        ...  Run Keyword If   '${item["operationalState"]}'!='enabled'
        ...  Fail  State operationalState changed for BTS ${alias} object ${obj_id}! Please check IMS file: ${ims_file_path}
    END

    Log  No state changes detected, as expected.  console=True

Check peer BTS CPRI RMOD PM counters
    FOR  ${RMOD_sn}  IN  @{shared_RMOD_sn_list}
        ${RMOD_id}=  Get From Dictionary  ${${peer_alias}_RM_sn_id_dict}  ${RMOD_sn}
        ${RMOD_L3Protocol}=  Get From Dictionary  ${RMOD_L3Protocol_dict}  ${RMOD_id}
        Continue For Loop If  '${RMOD_L3Protocol}' != 'CPRI_RP1'

        Check PM counters  M40015C10  ${RMOD_sn}  ${peer_alias}
    END

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
    ${elapsed_time_seconds}=    Evaluate  ${epoch_time_now}-${reset_site_event_epoch_time}
    ${remaining_time}=  Evaluate  ${${alias}_${mt_param}_seconds}-${elapsed_time_seconds}
    ${guard_time}=  Set Variable  45

    Run Keyword If  ${remaining_time}>0  Run Keywords
    ...  Log  Waiting ${remaining_time}s for PM completion  console=True
    ...  AND  Sleep  ${remaining_time}s
    Log  Waiting ${guard_time}s more as guard time to assure last PM availability  console=True
    Sleep  ${guard_time}s

    ${counter value}=  Get PM Counter Value from Admin
    ...  ${LANE_counters_dn}   ${counter_id_to_check}  ${reset_site_event_epoch_time}  ${${alias}_${mt_param}_seconds}  ${alias}
    Check counter value  ${counter_id_to_check}  ${counter value}  ${alias}

Check counter value
    [Arguments]    ${counter_id}  ${counter value}  ${alias}
    Run Keyword If  ${counter value} == 0  Run Keywords
    ...  Log  ${counter_id} counter value: ${counter value}, not incremented! Please check logs  level=ERROR
    ...  AND  Mid Test Snapshot collection  ${alias}  PM counter ${counter_id} not incremented!
    ...  AND  Set Test Variable  ${TC_verdict_counters}  FAIL
    ...  AND  Return From Keyword
    Run Keyword If  ${counter value} == 1  Run Keywords
    ...  Log  ${counter_id} counter value: ${counter value}, incremented as expected!  console=True
    ...  AND  Return From Keyword
    Run Keyword If  ${counter value} == 2  Run Keywords
    ...  Log  ${counter_id} counter value: ${counter value}, incremented, but twice! Please check logs  level=WARN
    ...  AND  Mid Test Snapshot collection  ${alias}  PM counter ${counter_id} incremented twice!
    ...  AND  Return From Keyword
    Run Keyword If  ${counter value} > 2  Run Keywords
    ...  Log  ${counter_id} counter value: ${counter value}, incremented more than twice! Please check logs  level=ERROR
    ...  AND  Mid Test Snapshot collection  ${alias}  PM counter ${counter_id} incremented more than twice
    ...  AND  Set Test Variable  ${TC_verdict_counters}  FAIL
    ...  AND  Return From Keyword

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

Check both BTS reset behavior based on IMS info
    [Documentation]
    ...  BTS RESET info is checked based on IMS info. Reset behavior as expected if:
    ...  - BTS ${alias} site: 1
    ...  - peer BTS site: reset number is 0
    ...  Otherwise, reset behavior not as expected, then errors are added to report and failed.
    [Arguments]  ${alias}

    Log  Check both BTS reset behavior based on IMS info  console=True
    Get and check BTS RESET info from IMS file  expected_reset_number=1  alias=${alias}
    ...  start_point_timestamp_UTC=${date_timestamp_start_UTC}  end_point_timestamp_UTC=${date_timestamp_end_UTC}
    Get and check BTS RESET info from IMS file  expected_reset_number=0  alias=${peer_alias}
    ...  start_point_timestamp_UTC=${date_timestamp_start_UTC}  end_point_timestamp_UTC=${date_timestamp_end_UTC}

Get and check BTS KPI info from IMS file
    [Documentation]
    ...  Get and check KPI info from IMS file.
    [Arguments]  ${alias}

    Log  Get and check KPI info from IMS file  console=True

    ${label}=  Get From Dictionary  ${BTS_alias_label_dict}  ${alias}

    ${kpi_name_delta_dict}=  Get and check KPI info from IMS file  kpi_names=${KPI_LIST}  kpi_thresholds=${${label}_RESET_WRN_THR_LIST}
    ...  alias=${alias}  start_point_timestamp_UTC=${date_timestamp_start_UTC}  end_point_timestamp_UTC=${date_timestamp_end_UTC}

    FOR  ${kpi}  IN  @{RESET_SITE_KPI_list}

        ${kpi_delta_list}=  Get From Dictionary  ${kpi_name_delta_dict}  ${kpi}

        Export KPI Results to File  alias=${alias}  obj=BTS  obj_type=SBTS  obj_id=${label}  action_1=Site_Reset  kpi_reported_1=${kpi}
        ...  event_value_1=${kpi_delta_list[0]}  cycle=${CYCLE}  source_info=ims

    END

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

Particular Teardown
    Export KPI results to File Global  kpi_log_file_name=KpiTimeInfo
    FOR  ${alias}  IN  @{alias_list}
        Recover initial settings for feature CB007447  ${alias}
    END
    Run Keyword If  '${PM_Counters_Check}' != 'True'  Run Keywords
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