*** Settings ***
Documentation    TC__SBTS_SBTS_SBTS_SBTS__SWM__SW_Rollback
Variables    tc_variables/sbts_sbts_sbts_sbts__swm__sw_rollback_alarms_definitions.py
Resource    ../../resources/rfs_frame_rfs_soam_taf.robot

*** Variables ***
${BTS_SW_Rollback}  ALL  # BTS list on which SW Rollback operation will be performed. Possible values (by default ALL):
                         # - ALL: action will be performed on all BTS (SW Rollback on each BTS)
                         # - list of selected BTS separated by comma labelized as BTSx (x is test_pc number in init.py) (ex. BTS1, BTS3)
                         # should be corelated with variable ${BTS_RESET_WRN_THR} value
${BTS_RESET_WRN_THR}  600  #  Time from first cell down to last cell up.
                           # Possible values: (by default in accordance with KPI13 specifications)
                           # - If ${BTS_SW_Rollback} is set to ALL, only one value should be given (ex. 600)
                           # - list of all kpi thresholds separated by comma for each BTS software rollback operation is performed on (ex. 600, 606).
${BTS_RESET_MAX_WAIT_TIME}  900  # Maximum time to wait for BTS OnAir after SW Rollback (by default 900)
${CB015052_CHECK}              False   # Specify if feature CB015052 behavior (no FID4220 on BTS secondary controller) should be checked (True) or
                                       # skipped (False). By default False
${tempRadioMasterTriggerTime}  0       # Temporary radio master trigger time on BTS secondary controller, default value 0 (minutes). Taken into
                                       # account only if ${CB015052_CHECK} set on True

*** Keywords ***
TC__SBTS_SBTS_SBTS_SBTS__SWM__SW_Rollback
     [Documentation]
    ...  [CASE LINK]: https://jiradc.ext.net.nokia.com/browse/TAT-25391
    ...
    ...  *****************
    ...  Basic information
    ...  *****************
    ...  SBTS-SBTS-SBTS-SBTS test case for BTS SW Rollback operation.
    ...  The main steps performed for the test are:
    ...  - check initial state and alarms for all BTS
    ...  - get initial SW versions from all BTS partitions
    ...  - perform SW Rollback operation on all BTS or choosen BTS
    ...  - check state and alarms for all BTS after SW Rollback operation
    ...  - check final SW versions from all BTS partitions
    ...  - check reset behavior on all BTS after SW Rollback from ims file
    ...  - check KPI13 info from IMS file
    ...  - check final state and alarms for all BTS
    ...
    ...  Pass criteria: BTS SW Rollback operation works as expected, states and alarms are as expected
    ...
    ...  ***************************
    ...  History of changes for SOAM
    ...  ***************************
    ...  - 20.06.2023 - https://jiradc.ext.net.nokia.com/browse/TAT-25391 -
    ...  [5G][CB008693][CNI-58093] New TC SBTS_SBTS_SBTS_SBTS_SWM_Software_rollback
    ...  - 13.03.2024 - https://jiradc.ext.net.nokia.com/browse/TAT-26819 -
    ...  [5G] Update KPI for SW activation get and check based on IMS info - 4 x SBTS
    ...  - 10.04.2024 - https://jiradc.ext.net.nokia.com/browse/TAT-27326 - update alarm list for SBTS_SBTS_SBTS_SBTS__SWM__SW_Rollback
    ...  - 08.07.2024 - https://jiradc.ext.net.nokia.com/browse/TAT-27696 - [5G] [Infomodel] Disable Infomodel in SW Update Test-Cases
    ...  - 29.08.2025 - https://jiradc.ext.net.nokia.com/browse/TAT-29632 - 4220 Alarm Filtering during SW activation
    ...  - 20.01.2026 - https://jiradc.ext.net.nokia.com/browse/TAT-30393 -
    ...  SBTS_SBTS_SBTS_SBTS__SWM__SW_Update.robot sometimes have wrong error message "Missing alarms" even if is wit status 'passed'
    ...
    ...  *******************
    ...  Test case flowchart
    ...  *******************
    ...  .. image:: https://gitlabe1.ext.net.nokia.com/panda-docs/hran_doc/-/blob/master/testsuite/RFS_SOAM/
    ...  TAT-25391_SBTS_SBTS_SBTS_SBTS__SWM__Rollback.png
    ...

    Set Tags    CA-STATE    OWNER-oana.bonchis@nokia.com   AUTHOR-traian-alin.bacos@nokia.com    PHASE-QT    SW-SBTS23R3

    Check threshold list
    Step 1: Check initial all BTS state
    Step 2: Check initial all BTS alarms
    Step 3: Get all BTS info
    Step 4: Perform BTS SW Rollback operation
    Step 5: Check final all BTS state
    Step 6: Check final all BTS alarms
    Step 7: Check final number and state of Cells and RMs

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
        Get and Check ALD state info  alias=${alias}
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

Step ${index}: Get all BTS info
    [Documentation]
    ...  Get all BTS info

    Log  Step ${index}: Get all BTS info  console=True
    ${BTS_alias_label_dict}  ${BTS_label_alias_dict}=  Get BTS alias label info dict
    Set Test Variable  ${BTS_alias_label_dict}
    Set Test Variable  ${BTS_label_alias_dict}
    ${BTS_alias_list}=  Get Dictionary Keys  ${BTS_alias_label_dict}  False
    ${BTS_label_list}=  Get Dictionary Values  ${BTS_alias_label_dict}  False
    Set Test Variable  ${BTS_alias_list}
    Set Test Variable  ${BTS_label_list}

    Run Keyword If  '${BTS_SW_Rollback}' != 'ALL'  Check BTS list
    Log  ====================================================  console=True
    Log  BTS label list selected for SW Rollback operation: ${BTS_label_list}  console=True
    Log  BTS alias list selected for SW Rollback operation: ${BTS_alias_list}  console=True
    Log  ====================================================  console=True

    ${alias_to_BTS_index_dict}=  Create Dictionary  Master=1  Slave=2  Slave1=3  Slave2=4
    Set Test Variable  ${alias_to_BTS_index_dict}

    Return From Keyword If  '${CB015052_CHECK}' == 'False'

    Log  Check TRM feature settings for check CB015052 feature behavior  console=True

    ${BTS_alias_RMOD_sn_dict}  ${RMOD_sn_BTS_alias_dict}  ${shared_RMOD_sn_list}  ${dedicated_RMOD_sn_list}=  Get all BTS RMOD sharing info
    Set Test Variable  ${BTS_alias_RMOD_sn_dict}
    Set Test Variable  ${RMOD_sn_BTS_alias_dict}
    Set Test Variable  ${shared_RMOD_sn_list}
    Set Test Variable  ${dedicated_RMOD_sn_list}

    ${all_BTS_controller_role_RMOD_sn_dict}=  Get all BTS controller role for configured RMOD from SCF
    Set Test Variable  ${all_BTS_controller_role_RMOD_sn_dict}

    ${BTS_primary_controller_shared_RMOD_list}  ${BTS_secondary_controller_shared_RMOD_list}=  Get all BTS controller role for shared RMOD
    Set Test Variable  ${BTS_primary_controller_shared_RMOD_list}
    Set Test Variable  ${BTS_secondary_controller_shared_RMOD_list}

    FOR  ${alias}  IN  @{BTS_secondary_controller_shared_RMOD_list}

        Check TRM feature settings  ${alias}

    END

Step ${index}: Perform BTS SW Rollback operation
    [Documentation]
    ...  Perform BTS SW Rollback from Admin

    Log  Step ${index}: Perform BTS SW Rollback operation  console=True
    FOR  ${alias}  IN  @{BTS_alias_list}
        ${label}=  Get From Dictionary  ${BTS_alias_label_dict}  ${alias}
        Set Test Variable  ${label}
        Get Current Date UTC info  start
        Get initial SW versions from all BTS partitions
        Perform BTS SW Rollback  ${alias}
        Get final SW versions from all BTS partitions
        Check SW versions from all BTS partitions after BTS SW Rollback  ${alias}
        Get Current Date UTC info  end
        Check all BTS reset behavior based on IMS info  ${alias}
        Get and check KPI13 info from IMS file  ${alias}
        Check feature CB015052 behaviour  ${alias}
    END

Step ${index}: Check final number and state of Cells and RMs
    [Documentation]
    ...  Cells state is checked according to operationalState attribute
    ...  Check if number of configured cells and radio modules in SCF are properly mapping on BTS running view.
    ...  Also check RMs operationalState

    [Timeout]  30 min
    Log  Step ${index}: Check final number and state of Cells and RMs  console=True
    RFS Test Case Final Checks

Perform BTS SW Rollback
    [Arguments]  ${alias}

    Log  Perform ${label} SW Rollback  console=True
    Get Current Time  sbts_initial
    Log  ${label} reset_start_time is: ${time_sbts_initial}  console=True
    coam.Rollback Software  connection=${alias}  timeout=${BTS_RESET_MAX_WAIT_TIME}

    ${remote_host_ip}=  Set Variable If  '${alias.upper()}' == 'MASTER'  None  ${${alias.upper()}}[${alias.upper()}_PC_IP_ADDRESS]
    ${remained_MAX_WAIT_TIME}=  Get elapsed time  ${time_sbts_initial}  ${BTS_RESET_MAX_WAIT_TIME}
    Wait For Target To Be Not Reachable TAF  hostname=${${alias.upper()}}[${alias.upper()}_TECH_IP_ADDRESS]  timeout=${remained_MAX_WAIT_TIME}
    ...  remote_host=${remote_host_ip}
    ${remained_MAX_WAIT_TIME}=  Get elapsed time  ${time_sbts_initial}  ${BTS_RESET_MAX_WAIT_TIME}
    Wait For Target To Be Reachable TAF  hostname=${${alias.upper()}}[${alias.upper()}_TECH_IP_ADDRESS]  timeout=${remained_MAX_WAIT_TIME}
    ...  remote_host=${remote_host_ip}
    Sleep  120s
    ${ims_file_path_Rollback}=  Admin Collect IMS file with timestamp  folder_path=${Test Results Dir}/IMS/${alias}  alias=${alias}
    Set Test Variable  ${${alias}_ims_file_path_Rollback}  ${ims_file_path_Rollback}
    Wait Until Keyword Succeeds  3x  10s  Admin reset and Infomodel reconnect sessions  reset_req=True  alias=${alias}  infomodel_reset=False

    Check all BTS states and alarms after BTS SW Rollback  ${alias}

Check all BTS states and alarms after BTS SW Rollback
    [Arguments]  ${alias}
    ${CELL_state_enabled_check}=  Set Variable  operationalState=${Enabled_}, blockingState=${Unblocked_}
    ${CELL_state_enabled}=  Set Variable  operationalState=Enabled, blockingState=Unblocked

    Log  ***** Check ${label} status and alarms after BTS SW Rollback operation on ${label} *****  console=True
    ${remained_MAX_WAIT_TIME}=  Get elapsed time  ${time_sbts_initial}  ${BTS_RESET_MAX_WAIT_TIME}
    Admin Check BTS Procedural and Blocking states  ${OnAir_}  ${Unblocked_}  ${remained_MAX_WAIT_TIME}  ${alias}
    Log  ${label} site - proceduralState: OnAir, blockingState: Unblocked, as expected!  console=True

    ${remained_MAX_WAIT_TIME}=  Get elapsed time  ${time_sbts_initial}  ${BTS_RESET_MAX_WAIT_TIME}
    Check cells availability status online  ${alias}  ${remained_MAX_WAIT_TIME}
    Log  All ${label} cell(s) status:\n - ${CELL_state_enabled}  console=True

    Log  Check ${label} alarms:  console=True
    Get and Check Alarms SOAM  alias=${alias}  expected_alarms=@{EMPTY}  ignored_alarms=${${alias.upper()}_IGNORED_ALARMS}
    ...  critical_alarms=${${alias.upper()}_CRITICAL_ALARMS}
    Log  ${label} site - expected, ignored and critical alarms checked  console=True

    Log  ***** Check the other BTS(s) status and alarms after BTS SW Rollback operation on ${label} *****  console=True
    FOR  ${other_alias}  IN  @{alias_list}
        Continue For Loop If  '${other_alias}' == '${alias}'
        ${other_label}=  Get From Dictionary  ${BTS_alias_label_dict}  ${other_alias}

        Log  Check ${other_label} status:  console=True
        Admin Check BTS Procedural and Blocking states  ${OnAir_}  ${Unblocked_}  ${BTS_RESET_MAX_WAIT_TIME}  ${other_alias}
        Log  ${other_label} site - proceduralState: OnAir, blockingState: Unblocked, as expected!  console=True
        Check cells availability status online  ${other_alias}  ${BTS_RESET_MAX_WAIT_TIME}
        Log  All ${other_label} cell(s) status:\n - ${CELL_state_enabled}  console=True

        Log  Check ${other_label} alarms:  console=True
        Get and Check Alarms SOAM  alias=${other_alias}  expected_alarms=@{EMPTY}  ignored_alarms=${${other_alias.upper()}_IGNORED_ALARMS}
        ...  critical_alarms=${${other_alias.upper()}_CRITICAL_ALARMS}
        Log  ${other_label} site - expected, ignored and critical alarms checked  console=True
    END

Check SW versions from all BTS partitions after BTS SW Rollback
    [Arguments]  ${alias}
    Log  Check SW versions from all BTS partitions after ${label} SW Rollback  console=True

    Should Be Equal  ${${alias} final active SW}  ${${alias} initial passive SW}
    Should Be Equal  ${${alias} final passive SW}  ${${alias} initial active SW}

    FOR  ${other_alias}  IN  @{alias_list}
        Continue For Loop If  '${other_alias}' == '${alias}'
        Should Be Equal  ${${other_alias} final active SW}  ${${other_alias} initial active SW}
        Should Be Equal  ${${other_alias} final passive SW}  ${${other_alias} initial passive SW}
    END

    Log  ${label} SW Rollback successfully performed!  console=True

Get ${when} SW versions from all BTS partitions
    [Timeout]  15 min
    Log  Get ${when} SW versions from all BTS partitions  console=True
    FOR  ${alias}  IN  @{alias_list}
        Admin Get BTS SW Version  ${alias}
        Set Test Variable  ${${alias} ${when} active SW}  ${${alias} active SW}
        Set Test Variable  ${${alias} ${when} passive SW}  ${${alias} passive SW}
    END

Check all BTS reset behavior based on IMS info
    [Documentation]
    ...  BTS RESET info is checked based on IMS info. Reset behavior as expected if:
    ...  - BTS ${alias} site: 1
    ...  - other BTS(s) site: reset number is 0
    ...  Otherwise, reset behavior not as expected, then errors are added to report and failed.
    [Arguments]  ${alias}

    Log  Check all BTS reset behavior based on IMS info  console=True
    Get and check BTS RESET info from IMS file  ims_file_path=${${alias}_ims_file_path_Rollback}  expected_reset_number=1  alias=${alias}
    ...  start_point_timestamp_UTC=${date_timestamp_start_UTC}  end_point_timestamp_UTC=${date_timestamp_end_UTC}
    FOR  ${other_alias}  IN  @{alias_list}
        Continue For Loop If  '${other_alias}' == '${alias}'
        Get and check BTS RESET info from IMS file  expected_reset_number=0  alias=${other_alias}
        ...  start_point_timestamp_UTC=${date_timestamp_start_UTC}  end_point_timestamp_UTC=${date_timestamp_end_UTC}
    END

Get and check KPI13 info from IMS file
    [Documentation]
    ...  Get and check KPI13 info from IMS file.
    [Arguments]  ${alias}

    Log  Get and check KPI13 info from IMS file  console=True
    ${label}=  Get From Dictionary  ${BTS_alias_label_dict}  ${alias}
    ${KeyIsPresent}=  Run Keyword And Return Status  Dictionary Should Contain Key  ${threshold_dict}  ${label}
    ${BTS_RESET_THR}=  Run Keyword If  ${KeyIsPresent}
    ...  Get From Dictionary  ${threshold_dict}  ${label}
    ...  ELSE  Set Variable  ${BTS_RESET_WRN_THR}
    ${ims_file_path_after_Rollback}=  Admin Collect IMS file with timestamp  folder_path=${Test Results Dir}/IMS/${alias}  alias=${alias}
    ${ims_file_path_list}=  Create List  ${${alias}_ims_file_path_Rollback}  ${ims_file_path_after_Rollback}
    ${kpi_name_delta_dict}=  Get and check KPI info from IMS file
    ...  kpi_names=kpi13  kpi_thresholds=${BTS_RESET_THR}  ims_file_path=${ims_file_path_list}  alias=${alias}
    ${kpi_delta_list}=  Get From Dictionary  ${kpi_name_delta_dict}  kpi13

    Export KPI Results to File  alias=${alias}  obj=BTS  obj_type=SBTS  obj_id=${alias}  action_1=SW_Rollback  kpi_reported_1=KPI_13
    ...  event_value_1=${kpi_delta_list[0]}  source_info=ims

Check BTS list
    ${BTS_LIST_strip}=  Replace String  ${BTS_SW_Rollback}  ${SPACE}  ${EMPTY}
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

Get all BTS controller role for shared RMOD

    ${BTS_primary_controller_shared_RMOD_list}=  Create List
    ${BTS_secondary_controller_shared_RMOD_list}=  Create List

    FOR  ${alias}  IN  @{alias_list}

        ${BTS_controller_role_RMOD_sn_dict}=  Get From Dictionary  ${all_BTS_controller_role_RMOD_sn_dict}  ${alias}
        ${BTS_primary_controller_RMOD_sn_list}=  Get From Dictionary  ${BTS_controller_role_RMOD_sn_dict}  BTS_primary_controller_RMOD_sn_list
        ${BTS_secondary_controller_RMOD_sn_list}=  Get From Dictionary  ${BTS_controller_role_RMOD_sn_dict}  BTS_secondary_controller_RMOD_sn_list
        ${BTS_primary_controller_shared_RMOD_sn_list}=  Get BTS info for shared RMOD  ${BTS_primary_controller_RMOD_sn_list}
        ${BTS_primary_controller_shared_RMOD_sn_count}=  Get Length  ${BTS_primary_controller_shared_RMOD_sn_list}
        Run Keyword If  ${BTS_primary_controller_shared_RMOD_sn_count} > 0  Append To List  ${BTS_primary_controller_shared_RMOD_list}  ${alias}
        ${BTS_secondary_controller_shared_RMOD_sn_list}=  Get BTS info for shared RMOD  ${BTS_secondary_controller_RMOD_sn_list}
        ${BTS_secondary_controller_shared_RMOD_sn_count}=  Get Length  ${BTS_secondary_controller_shared_RMOD_sn_list}
        Run Keyword If  ${BTS_secondary_controller_shared_RMOD_sn_count} > 0  Append To List  ${BTS_secondary_controller_shared_RMOD_list}  ${alias}

        Set Test Variable  ${${alias}_secondary_controller_shared_RMOD_sn_count}  ${BTS_secondary_controller_shared_RMOD_sn_count}

    END

    [Return]  ${BTS_primary_controller_shared_RMOD_list}  ${BTS_secondary_controller_shared_RMOD_list}

Get BTS info for shared RMOD
    [Arguments]  ${RMOD_sn_list}

    ${BTS_shared_RMOD_sn_list}=  Create List

    FOR  ${RMOD_sn}  IN  @{RMOD_sn_list}

        Run Keyword If  '${RMOD_sn}' in ${shared_RMOD_sn_list}  Append To List  ${BTS_shared_RMOD_sn_list}  ${RMOD_sn}

    END

    [Return]  ${BTS_shared_RMOD_sn_list}

Check TRM feature settings
    [Arguments]  ${alias}

    ${BTS_TRM_feature_dict_initial}=  Get BTS TRM feature parameters  BTS_SCF_path_file=${${alias.lower()}_scf_initial}  alias=${alias}
    Set Test Variable  ${${alias}_TRM_feature_dict_initial}  ${BTS_TRM_feature_dict_initial}
    Set classical BTS TRM feature parameter  actTempRadioMaster  true  ${alias}
    Set classical BTS TRM feature parameter  tempRadioMasterTriggerTime  ${tempRadioMasterTriggerTime}  ${alias}

Check threshold list
    ${BTS_RESET_WRN_THR_strip}=  Replace String  ${BTS_RESET_WRN_THR}  ${SPACE}  ${EMPTY}
    ${BTS_RESET_WRN_THR}=  Split String  ${BTS_RESET_WRN_THR_strip}  ,
    ${BTS_RESET_WRN_THR_length}=  Get Length  ${BTS_RESET_WRN_THR}
    ${BTS_SW_Rollback_strip}=  Replace String  ${BTS_SW_Rollback}  ${SPACE}  ${EMPTY}
    ${BTS_SW_Rollback_check}=  Split String  ${BTS_SW_Rollback_strip}  ,
    ${BTS_SW_Rollback_length}=  Get Length  ${BTS_SW_Rollback_check}
    ${threshold_dict}=  Create Dictionary
    ${threshold_check}=  Set Variable  True

    Run Keyword If  ${BTS_RESET_WRN_THR_length} == 1 and '${BTS_SW_Rollback}' == 'ALL'  Run Keywords
    ...  Set Test Variable  ${threshold_check}  False
    ...  AND  Log  BTS_RESET_WRN_THR and BTS_SW_Rollback were set correctly, test will continue  console=True
    ...  ELSE IF  ${BTS_RESET_WRN_THR_length} == ${BTS_SW_Rollback_length}
    ...  Log  BTS_RESET_WRN_THR and BTS_SW_Rollback were set correctly, test will continue  console=True
    ...  ELSE  FAIL  Variables BTS_RESET_WRN_THR and BTS_SW_Rollback were set incorrectly!

    Run Keyword If  ${threshold_check} is True  Create Threshold Dict  ${threshold_dict}  ${BTS_RESET_WRN_THR}  ${BTS_SW_Rollback_check}

Create Threshold Dict
    [Arguments]  ${threshold_dict}  ${BTS_RESET_WRN_THR}  ${BTS_SW_Rollback_check}
    ${length}=  Get Length  ${BTS_SW_Rollback_check}
    FOR  ${index}  IN RANGE  ${length}
        ${threshold}=  Set Variable  ${BTS_RESET_WRN_THR}[${index}]
        ${bts}=  Set Variable  ${BTS_SW_Rollback_check}[${index}]
        Set To Dictionary  ${threshold_dict}  ${bts}  ${threshold}
    END
    Set Test Variable  ${threshold_dict}

Check feature CB015052 behaviour
    [Arguments]  ${alias}

    Return From Keyword If  '${CB015052_CHECK}' == 'False'

    Log  ***** Check feature CB015052 behaviour *****  console=True
    FOR  ${peer_alias}  IN  @{BTS_secondary_controller_shared_RMOD_list}
        Continue For Loop If  '${peer_alias}' == '${alias}' or '${${peer_alias.upper()}}[${peer_alias.upper()}_MODULE_TYPE]' == 'FSMF'
        Check feature CB015052 behaviour on BTS  ${peer_alias}
    END

Check feature CB015052 behaviour on BTS
    [Arguments]  ${alias}
    Log  Check BTS ${alias} (as secondary controller) feature CB015052 behaviour:  console=True

    ${FID4220_check}=  Run Keyword And Return Status  Get and check detailed IMS2 Alarms SOAM  alias=${alias}
    ...  start_timestamp=${date_timestamp_start_UTC}  skip_check_if_empty_expected_alarms=${False}
    ...  critical_alarms=${TRM_ALARMS_4220}

    Run Keyword If  not ${FID4220_check}  Run Keywords
    ...  Log Long String  BTS ${alias} check feature CB015052 behaviour failed:\n- Found "Radio slave has taken temporary radio master role
    ...  (4220)" alarms  console=True
    ...  AND  Fail  BTS ${alias} check feature CB015052 behaviour failed
    ...  ELSE
    ...  Log Long String  BTS ${alias} check feature CB015052 behaviour passed:\n- Not found any "Radio slave has taken temporary radio master role
    ...  (4220)" alarms  console=True

Recover TRM feature initial settings
    [Arguments]  ${alias}

    ${actTempRadioMaster_initial}=  Get From Dictionary  ${${alias}_TRM_feature_dict_initial}  actTempRadioMaster
    ${tempRadioMasterTriggerTime_initial}=  Get From Dictionary  ${${alias}_TRM_feature_dict_initial}  tempRadioMasterTriggerTime
    Set classical BTS TRM feature parameter  actTempRadioMaster  ${actTempRadioMaster_initial}  ${alias}
    Set classical BTS TRM feature parameter  tempRadioMasterTriggerTime  ${tempRadioMasterTriggerTime_initial}  ${alias}

Particular Teardown
    Export KPI results to File Global  kpi_log_file_name=KpiTimeInfo
    Return From Keyword If  '${CB015052_CHECK}' == 'False'

    Log  Recover TRM feature initial settings  console=True
    FOR  ${alias}  IN  @{BTS_secondary_controller_shared_RMOD_list}
        ${TRM_feature_dict_status}=  Run Keyword and Return Status  Variable Should Exist  ${${alias}_TRM_feature_dict_initial}
        Continue For Loop If  not ${TRM_feature_dict_status}
        Recover TRM feature initial settings  ${alias}
    END

TC Setup
    ${tech_preset_list}=  Create List  SBTS  SBTS  SBTS  SBTS
    Common Test Setup  preset_techs=${tech_preset_list}  common_sbts=${TRUE}  infomodelSetup=${FALSE}

TC Teardown
    Common Test Teardown
