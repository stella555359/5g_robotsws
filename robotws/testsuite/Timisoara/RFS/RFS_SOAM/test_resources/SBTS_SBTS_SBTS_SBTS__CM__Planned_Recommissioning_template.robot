*** Settings ***
Documentation    TC__SBTS_SBTS_SBTS_SBTS__CM__Planned_Recommissioning_template
Variables    tc_variables/sbts_sbts_sbts_sbts__cm__planned_recommissioning_template_alarms_definitions.py
Resource    ../../resources/rfs_frame_rfs_soam_taf.robot

*** Variables ***
${RECOMMISSIONING_BTS1}    CURRENT  # CURRENT(use current scf), SCF PATH(use custom scf from path) or NONE(BTS is SKPPED from COMMISSIONG)
${RECOMMISSIONING_BTS2}    NONE     # CURRENT(use current scf), SCF PATH(use custom scf from path) or NONE(BTS is SKPPED from COMMISSIONG)
${RECOMMISSIONING_BTS3}    NONE     # CURRENT(use current scf), SCF PATH(use custom scf from path) or NONE(BTS is SKPPED from COMMISSIONG)
${RECOMMISSIONING_BTS4}    NONE     # CURRENT(use current scf), SCF PATH(use custom scf from path) or NONE(BTS is SKPPED from COMMISSIONG)
${REPEAT_COUNTER}          3        # Number of BTS Recommissioning operations
${RESET_CONFIGURATION}     False    # Flag to enable/disable BTS Reset Configuration before Recommissioning; can be True or False
${BTS_SCF_VALIDATION}      True     # Validate SCF; can be True or False
${BTS_MAX_WAIT_TIME}       900      # Max Wait Time for BTS to be up after Recommissioning
${RECOVER_INITIAL_SCF}     True     # Recover initial SCF; can be True or False
${KPI_LIST}                kpi12a   # BTS autonomous reset after plan activation KPI label list separated by comma.
                                    # Possible values (by default kpi12a):
                                    # - kpi12a: Time spent between first cell down to last cell up
                                    # - kpi12b: Time spent between last cell down to first cell up
${BTS_RESET_WRN_THR_LIST}  600      # BTS1 KPI value list separated by comma. They should be correlated with BTS autonomous reset after plan
                                    # activation KPI label list. By default 600 (secs) for kpi12a

*** Keywords ***
TC__SBTS_SBTS_SBTS_SBTS__CM__Planned_Recommissioning_template
    [Documentation]
    ...  [CASE LINK]: https://jiradc.ext.net.nokia.com/browse/TAT-26869
    ...
    ...  *****************
    ...  Basic information
    ...  *****************
    ...  SBTS-SBTS-SBTS-SBTS test case for Planned_Recommissioning_template, - x times sequence.
    ...  x - value of REPEAT_COUNTER parameter (default: 3)
    ...  The main steps performed for the test are:
    ...  - check initial state and alarms for all BTS
    ...  - BTS Reset configuration
    ...  - Planned BTS Recommissioning with SCF file
    ...  - check reset behavior on BTS based on IMS info as follows:
    ...    - BTS site: reset number is 1
    ...    - other BTS site: reset number is 0
    ...  - check final state and alarms for all BTS
    ...  Pass criteria: Planned Recommissioning operation works as expected, states and alarms are as expected
    ...
    ...  ***************************
    ...  History of changes for SOAM
    ...  ***************************
    ...  - 21.02.2023 - https://jiradc.ext.net.nokia.com/browse/TAT-26869 - [5G][CB010912] RFS_BTS_Commissioning_Recommissioning by changing SCF
    ...  - 21.06.2024 - https://jiradc.ext.net.nokia.com/browse/TAT-27665 -
    ...  [5G] [SCF check] - P1 - SBTS - Include SCF validation with hardware check in CM Tests
    ...  - 19.11.2025 - https://jiradc.ext.net.nokia.com/browse/TAT-30110 - Part 1- Add KPI12/KPI12b for recommissioning automated scenarios
    ...  - 26.01.2026 - https://jiradc.ext.net.nokia.com/browse/TAT-30418 - [5G] SBTS_SBTS__CM__Planned_Recommissioning_template fails during
    ...  KPI12a/b calculation
    ...
    ...  *******************
    ...  Test case flowchart
    ...  *******************
    ...  .. image:: https://gitlabe1.ext.net.nokia.com/panda-docs/hran_doc/-/blob/master/testsuite/RFS_SOAM/
    ...  TAT-26869_SBTS_SBTS_SBTS_SBTS__CM__Planned_Recommissioning_template.png

    Set Tags    CA-STATE    OWNER-oana.borchescu@nokia.com@nokia.com    AUTHOR-anca.tatar@nokia.com    PHASE-QT    SW-SBTS24R2

    TC Preconditions
    Step 1: Check initial all BTS state
    Step 2: Check initial all BTS alarms
    FOR  ${INDEX}  IN RANGE  1  ${REPEAT_COUNTER}+1
        Log  ==============================================================================  console=True
        Log  Start Cycle ${INDEX} of ${REPEAT_COUNTER}  console=True
        Log  ==============================================================================  console=True
        Step 3: Planned BTS Recommissioning for iteration ${INDEX}
        Step 4: Check final all BTS state
        Step 5: Check final all BTS alarms
        Step 6: Check final number and state of Cells and RMs
    END

    [Teardown]  Particular Teardown

TC Preconditions
    ${BTS_alias_label_dict}  ${BTS_label_alias_dict}=  Get BTS alias label info dict
    Set Test Variable  ${BTS_alias_label_dict}
    ${BTS_label_list}=  Get Dictionary Values  ${BTS_alias_label_dict}  False

    ${BTS_alias_list}=  Create List
    ${scf_recommissioning_dict}=  Create Dictionary

    FOR  ${BTS_label}  IN  @{BTS_label_list}
        Continue For Loop If  '${RECOMMISSIONING_${BTS_label}}' == 'NONE'

        ${alias}=  Get From Dictionary  ${BTS_label_alias_dict}  ${BTS_label}
        Append To List  ${BTS_alias_list}  ${alias}

        ${BTS_scf_initial}=  Admin Collect scf.xml with timestamp TAF  alias=${alias}  folder_path=${BTSFiles}/${alias}/initial_scf
        ...  export_type=configurationAndRuntimeObjects
        Set Test Variable  ${${alias}_BTS_scf_initial}  ${BTS_scf_initial}

        ${scf_path_tmp}=  Run Keyword If  '${RECOMMISSIONING_${BTS_label}}' == 'CURRENT'
        ...  Admin Collect scf.xml with timestamp TAF  alias=${alias}  folder_path=${BTSFiles}/${alias}  export_type=configurationAndRuntimeObjects
        ...  ELSE  Set Variable  ${RECOMMISSIONING_${BTS_label}}

        OperatingSystem.File Should Exist  ${scf_path_tmp}
        ${bts_info_tmp}=  Admin Get BTS state info  alias=${alias}
        Set Test Variable  ${${alias}_commissioning_scf_path}  ${scf_path_tmp}
        Set Test Variable  ${${alias}_bts_info}  ${bts_info_tmp}

        Set To Dictionary  ${scf_recommissioning_dict}  ${alias}  ${${alias}_commissioning_scf_path}
    END

    Set Test Variable  ${BTS_alias_list}
    Set Test Variable  ${scf_recommissioning_dict}

    Check KPI label list
    Check KPI value list

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
        Get and Check Alarms SOAM  alias=${alias}  expected_alarms=@{EMPTY}  ignored_alarms=${test_alarms_list['${alias.upper()}_IGNORED_ALARMS']}
        ...  critical_alarms=${test_alarms_list['${alias.upper()}_CRITICAL_ALARMS']}
        Log  BTS ${alias} site - expected, ignored and critical alarms checked  console=True
    END

Step ${index}: Planned BTS Recommissioning for iteration ${CYCLE}

    Log  Step ${index}: Planned BTS Recommissioning for iteration ${CYCLE}  console=True
    Set Test Variable  ${CYCLE}
    FOR  ${alias}  IN  @{BTS_alias_list}
        ${BTS_label}=  Get From Dictionary  ${BTS_alias_label_dict}  ${alias}
        Set Test Variable  ${BTS_label}
        Log  ***** ${BTS_label} Planned Recommissioning *****  console=True
        Run Keyword If  '${RESET_CONFIGURATION}' == 'True'
         ...  BTS Reset Configuration  ${alias}
         ...  ELSE  Log  BTS Reset Configuration on ${BTS_label} will be skipped!  console=True
        Get RESET timestamp info  start
        Planned BTS Recommissioning  ${alias}
        Get RESET timestamp info  end
        Check all BTS reset behavior based on IMS info  ${alias}
        Get and check BTS KPI info from IMS file  ${alias}
    END

Step ${index}: Check final number and state of Cells and RMs
    [Documentation]
    ...  Cells state is checked according to operationalState attribute
    ...  Check if number of configured cells and radio modules in SCF are properly mapping on BTS running view.
    ...  Also check RMs operationalState

    [Timeout]  30 min
    Log  Step ${index}: Check final number and state of Cells and RMs  console=True
    RFS Test Case Final Checks  entity_scf_dict=${scf_recommissioning_dict}

Check KPI label list

    ${RECOMMISSIONING_KPI_official_list}=  Create List  kpi12a  kpi12b
    ${RECOMMISSIONING_KPI_list_strip}=  Replace String  ${KPI_LIST}  ${SPACE}  ${EMPTY}
    ${RECOMMISSIONING_KPI_list}=  Split String  ${RECOMMISSIONING_KPI_list_strip}  ,
    ${KPI_label_check}=  Set Variable  True
    ${KPI_invalid_label_list}=  Create List
    ${KPI_request_label_list}=  Create List
    ${KPI_request_alias_list}=  Create List

    FOR  ${kpi}  IN  @{RECOMMISSIONING_KPI_list}
        ${KPI_label_check}=  Set Variable If  '${kpi}' not in ${RECOMMISSIONING_KPI_official_list}  False  ${KPI_label_check}
        Run Keyword If  '${kpi}' not in ${RECOMMISSIONING_KPI_official_list}
        ...  Append To List  ${KPI_invalid_label_list}  ${kpi}
        ...  ELSE
        ...  Append To List  ${KPI_request_label_list}  ${kpi}
    END

    Run Keyword If  '${KPI_label_check}' == 'False'  Run Keywords
    ...  Log Long String  Following selected KPI are not valid: ${KPI_invalid_label_list}. Please select values for test argument \${KPI_LIST} from
    ...  official Recommissioning KPI list: ${RECOMMISSIONING_KPI_official_list} or let default value: kpi12a
    ...  AND  Fail  Improper value for argument!

    Set Test Variable  ${RECOMMISSIONING_KPI_list}  ${KPI_request_label_list}
    ${RECOMMISSIONING_KPI_count}=  Get Length  ${RECOMMISSIONING_KPI_list}
    Set Test Variable  ${RECOMMISSIONING_KPI_count}

Check KPI value list

    ${BTS_RESET_WRN_THR_list_strip}=  Replace String  ${BTS_RESET_WRN_THR_LIST}  ${SPACE}  ${EMPTY}
    ${RECOMMISSIONING_KPI_values_list}=  Split String  ${BTS_RESET_WRN_THR_list_strip}  ,
    ${RECOMMISSIONING_KPI_values_count}=  Get Length  ${RECOMMISSIONING_KPI_values_list}

    Run Keyword If  ${RECOMMISSIONING_KPI_values_count} != ${RECOMMISSIONING_KPI_count}  Run Keywords
    ...  Log Long String  Number of KPI values set for test argument \${BTS_RESET_WRN_THR_LIST} is not aligned with number of selected KPI for
    ...  Recommissioning operation. Please align values for \${BTS_RESET_WRN_THR_LIST} according to \${KPI_LIST} info or let default value: 600!
    ...  AND  Fail  Improper value for argument!

BTS Reset Configuration
    [Documentation]
    ...  BTS Reset Configuration
    [Arguments]  ${alias}

    Log  Perform "BTS Reset Configuration" on ${BTS_label}  console=True

    ${BTS_TECH_IP_address}=  Set Variable  ${${alias.upper()}}[${alias.upper()}_TECH_IP_ADDRESS]
    ${remote_host_ip}=  Set Variable If  '${alias}' == 'Master'  None  ${${alias.upper()}}[${alias.upper()}_PC_IP_ADDRESS]

    Reset BTS Configuration TAF  connection=${alias}  wait_for_admin_connection=True  remove_operator_certificates=False
    ...  remove_user_account_credentials=True  repair_center_reset=True

    Wait For Target To Be Reachable TAF  hostname=${BTS_TECH_IP_address}  timeout=250  remote_host=${remote_host_ip}

    Log  BTS SM (${BTS_TECH_IP_address} from localhost) has been reachable within 250 seconds  console=True
    Wait Until Keyword Succeeds  10 min  1 min  Uncommission module status BTS SOAM  ${alias}
    Log  ${BTS_label} Reset Configuration completed!  console=True

Uncommission module status BTS SOAM
    [Documentation]
    ...  Checks procedural state of BTS SOAM
    [Arguments]  ${alias}

    ${BTS state}=  coam.Get Mrbts State  timeout=600  alias=${alias}
    Log  ${BTS_label} proceduralState is: ${BTS state}  console=True
    Should Contain  ${NotCommissioned_}  ${BTS state}

Get RESET timestamp info
    [Arguments]  ${when}
    Get Current Date UTC info  ${when}
    Log  UTC ${when}_point_timestamp: ${date_timestamp_${when}_UTC}  console=True

Planned BTS Recommissioning
    [Documentation]
    ...  Planned BTS recommissioning with SCF file is triggered. The new SCF file is loaded on BTS SM and a reboot should be triggered after.
    [Arguments]  ${alias}

    Log  Perform "Planned BTS Recommissioning" on ${BTS_label}  console=True
    Log  Commissioning via ADMIN will be performed using ${${alias}_commissioning_scf_path}  console=True

    Get Current Time  bts_initial

    coam.Perform Commissioning  bts_id=${${alias}_bts_info[0]}  scf_file=${${alias}_commissioning_scf_path}  skip_parameter_relation_errors=True
    ...  should_activate=True  timeout=${BTS_MAX_WAIT_TIME}  connection=${alias}
    Log  ${BTS_label} commissioning has been performed  console=True

    Run Keyword If  ${BTS_SCF_VALIDATION}  Check BTS SCF Validation On Demand  alias=${alias}

    Check SW configuration did not change  ${alias}

    ${remained_MAX_WAIT_TIME}=  Get elapsed time  ${time_bts_initial}  ${BTS_MAX_WAIT_TIME}
    Admin Check BTS Procedural and Blocking states  ${OnAir_}  ${Unblocked_}  ${remained_MAX_WAIT_TIME}  ${alias}
    Log  ${BTS_label} site - proceduralState: OnAir, blockingState: Unblocked, as expected!  console=True

    ${remained_MAX_WAIT_TIME}=  Get elapsed time  ${time_bts_initial}  ${BTS_MAX_WAIT_TIME}
    Check cells availability status online  ${alias}  ${remained_MAX_WAIT_TIME}
    Log  ${BTS_label} cells status:\n - operationalState=Enabled, availabilityStatus=Online, blockingState=Unblocked  console=True

    Log  Check ${BTS_label} alarms:  console=True
    Get and Check Alarms SOAM  alias=${alias}  expected_alarms=@{EMPTY}  ignored_alarms=${test_alarms_list['${alias.upper()}_IGNORED_ALARMS']}
    ...  critical_alarms=${test_alarms_list['${alias.upper()}_CRITICAL_ALARMS']}
    Log  ${BTS_label} site - expected, ignored and critical alarms checked  console=True

Check SW configuration did not change
    [Documentation]
    ...  Extract BTS active and passive SWs using Admin and compare to initial values. Fail if something changed
    [Arguments]  ${alias}

    ${current_active_SW}  ${current_passive_SW}=  Wait Until Keyword Succeeds  5m  20s  Admin Get BTS SW Version  ${alias}
    ${initial_SW_list}=  Create List  ${${alias} active SW}  ${${alias} passive SW}
    ${current_SW_list}=  Create List  ${current_active_SW}  ${current_passive_SW}
    ${no_sw_change}=  Run Keyword And Return Status  Should Be Equal  ${initial_SW_list}  ${current_SW_list}
    Run Keyword If  not ${no_sw_change}  Run Keywords
    ...  Log  SW configuration changed! ${BTS_label} SW active/passive: ${current_active_SW}/${current_passive_SW}  console=True
    ...  AND  Fail  SW configuration changed!

Check all BTS reset behavior based on IMS info
    [Documentation]
    ...  BTS RESET info is checked based on IMS info. Reset behavior as expected if:
    ...  - BTS site: reset number is 1
    ...  - other BTS site: reset number is 0
    ...  Otherwise, reset behavior not as expected, then errors are added to report and failed.
    [Arguments]  ${alias}

    Log  Check all BTS reset behavior based on IMS info  console=True
    Get and check BTS RESET info from IMS file  expected_reset_number=1  alias=${alias}  remove_ims_file=False
    ...  start_point_timestamp_UTC=${date_timestamp_start_UTC}  end_point_timestamp_UTC=${date_timestamp_end_UTC}

    FOR  ${other_alias}  IN  @{alias_list}
        Continue For Loop If  '${other_alias}' == '${alias}'
        Get and check BTS RESET info from IMS file  expected_reset_number=0  alias=${other_alias}  remove_ims_file=False
        ...  start_point_timestamp_UTC=${date_timestamp_start_UTC}  end_point_timestamp_UTC=${date_timestamp_end_UTC}
    END

Get and check BTS KPI info from IMS file
    [Documentation]
    ...  Get and check KPI info from IMS file.
    [Arguments]  ${alias}

    Log  Get and check BTS KPI info from IMS file  console=True

    ${current_cell_ids_list}=  Get Current Cell Ids  alias=${alias}

    ${kpi_name_delta_dict}=  Get and check KPI info from IMS file  kpi_names=${KPI_LIST}  kpi_thresholds=${BTS_RESET_WRN_THR_LIST}
    ...  alias=${alias}  start_point_timestamp_UTC=${date_timestamp_start_UTC}  end_point_timestamp_UTC=${date_timestamp_end_UTC}
    ...  current_cell_dist_names=${current_cell_ids_list}
    FOR  ${kpi}  IN  @{RECOMMISSIONING_KPI_list}

        ${kpi_delta_list}=  Get From Dictionary  ${kpi_name_delta_dict}  ${kpi}

        Export KPI Results to File  alias=${alias}  obj=BTS  obj_type=SBTS  obj_id=${alias}  action_1=Recommissioning  kpi_reported_1=${kpi}
        ...  event_value_1=${kpi_delta_list[0]}  cycle=${CYCLE}  source_info=ims

    END

Get Current Cell Ids
    [Documentation]
    ...  Get current cell ids from BTS for all configured RATs
    [Arguments]  ${alias}

    ${NR_cell_ids}=  Get Ids For All  class_name=NRCEL  connection=${alias}
    ${LTE_cell_ids}=  Get Ids For All  class_name=LNCEL  connection=${alias}
    ${WCDMA_cell_ids}=  Get Ids For All  class_name=WNCEL  connection=${alias}
    ${GSM_cell_ids}=  Get Ids For All  class_name=GNCEL  connection=${alias}
    ${cell_ids_list}=  Combine Lists  ${NR_cell_ids}  ${LTE_cell_ids}  ${WCDMA_cell_ids}  ${GSM_cell_ids}

    [Return]  ${cell_ids_list}

Recover initial SCF
    [Documentation]
    ...  Recover initial SCF
    [Arguments]  ${alias}  ${BTS_label}

    Log  Recover initial SCF on ${BTS_label}  console=True

    coam.Perform Commissioning  bts_id=${${alias}_bts_info[0]}  scf_file=${${alias}_BTS_scf_initial}  skip_parameter_relation_errors=True
    ...  should_activate=True  timeout=400  connection=${alias}
    Log  ${BTS_label} commissioning has been performed  console=True

    Admin Check BTS Procedural and Blocking states  ${OnAir_}  ${Unblocked_}  900  ${alias}
    Log  ${BTS_label} site - proceduralState: OnAir, blockingState: Unblocked, as expected!  console=True

Particular Teardown
    FOR  ${alias}  IN  @{BTS_alias_list}
        ${BTS_label}=  Get From Dictionary  ${BTS_alias_label_dict}  ${alias}
        Run Keyword If  ${RECOVER_INITIAL_SCF} and '${RECOMMISSIONING_${BTS_label}}' not in ['NONE','CURRENT']
        ...  Recover initial SCF  ${alias}  ${BTS_label}
    END
    Check all BTS cells availability status online

TC Setup
    ${tech_preset_list}=  Create List  SBTS  SBTS  SBTS  SBTS
    Common Test Setup  preset_techs=${tech_preset_list}  common_sbts=${TRUE}  infomodelSetup=${FALSE}  newAlarmsFormat=${TRUE}

TC Teardown
    Common Test Teardown

Standalone Execution
    [Arguments]    @{test_variables}
    [Teardown]    TC Teardown
    FOR  ${key}  ${value}  IN  @{test_variables}
        Set Test Variable  ${key}  ${value}
    END
    TC Setup
    TC__SBTS_SBTS_SBTS_SBTS__CM__Planned_Recommissioning_template
