*** Settings ***
Documentation    TC__SBTS__CM__Planned_Recommissioning_template
Variables    tc_variables/sbts__cm__planned_recommissioning_template_alarm_definitions.py
Resource    ../../resources/rfs_frame_rfs_soam_taf.robot

*** Variables ***
${RECOMMISSIONING_SBTS}               NONE     # Absolute SCF file path with commissioning for SBTS RAT (i.e. /home/ute/btsauto/SCF_01_SBTS19.xml).
                                               # If NONE, current SCF will be used
${REPEAT_COUNTER}                     3        # Number of SBTS Recommissioning operations, default value 3
${SBTS_SCF_VALIDATION}                True     # Validate SBTS SCF; can be True or False
${SBTS_MAX_WAIT_TIME}                 900      # Maximum Wait time for SBTS to be OnAir after commissioning
${SBTS_RESET_WRN_THR}                 504      # Time from first cell down to last cell up. Default value in line with KPI 1a specifications
${VERDICT_WRONG_SBTS_RESET_NUMBER}    PASS     # Test verdict in case of wrong NR Reset Number. Values: PASS(passed with restriction) or FAIL(Cloud)
${RESET_CONFIGURATION}                False    # Flag to Reset BTS configuration before recommissioning, can be True or False, default False

*** Keywords ***
TC__SBTS__CM__Planned_Recommissioning_template
    [Documentation]
    ...  [CASE LINK]: https://jiradc.ext.net.nokia.com/browse/TAT-22336
    ...
    ...  *****************
    ...  Basic information
    ...  *****************
    ...  SBTS test case for Planned_Recommissioning_template, - x times sequence.
    ...  x - value of REPEAT_COUNTER parameter (default: 3)
    ...  The main steps performed for the test are:
    ...  - check initial state and alarms for BTS technology
    ...  - BTS Reset configuration
    ...  - planned BTS recommissioning with SCF file
    ...  - check reset behavior on BTS based on IMS info as follows:
    ...    - BTS site: reset number is 2 if RESET_CONFIGURATION=True else reset number is 1poll
    ...  - check final state and alarms for BTS technology
    ...  Pass criteria: Planned Recommissioning operation works as expected, states and alarms are as expected
    ...
    ...  ******************
    ...  History of changes
    ...  ******************
    ...  - 03.01.2021 - TAT-22336 - [5G][RFSPLIT] RFS_BTS__STATE__SBTS_Planned_Recommissioning_Template
    ...  - 03.10.2022 - https://jiradc.ext.net.nokia.com/browse/TAT-23748
    ...  [5G] NRL__CM__Planned_Recommissioning_NR_template is Recommisioning NR side with LTE scf
    ...  - 09.03.2023 - https://jiradc.ext.net.nokia.com/browse/TAT-24842 - [5G][Reset Number ims2] Update SBTS CM ... scenarios to take reset
    ...  number from ims2 - P2
    ...  - 19.05.2023 - https://jiradc.ext.net.nokia.com/browse/TAT-24876 - [5G][CB007500] New behavior for Configuration Reset - RFSplit
    ...  - 01.04.2025 - https://jiradc.ext.net.nokia.com/browse/TAT-29003 -
    ...  Detect SBTS-SBTS instead off LTE-LTE for SBTS_SBTS__STATE__SharedRM_Power_Off_On
    ...  - 03.09.2025 - https://jiradc.ext.net.nokia.com/browse/TAT-29815 -
    ...  Unify alarm container names between all tests in order to use ${${alias.upper()}}_ALARMS_CNI_127210 ${${alias.upper()}}_ALARMS_NO_CNI_127210
    ...
    ...  *******************
    ...  Test case flowchart
    ...  *******************
    ...  .. image:: https://gitlabe1.ext.net.nokia.com/panda-docs/hran_doc/-/blob/master/testsuite/RFS_SOAM/
    ...  TAT-22336_SBTS__CM__Planned_Recommissioning_template.png

    Set Tags    CA-CM    OWNER-sorin.saulescu@nokia.com    AUTHOR-anca.tatar@nokia.com    PHASE-QT

    TC Parameters check
    Step 1: Check initial BTS state
    Step 2: Check initial BTS alarms
    FOR  ${INDEX}  IN RANGE  1  ${REPEAT_COUNTER}+1
        Log  ==============================================================================  console=True
        Log  Start Cycle ${INDEX} of ${REPEAT_COUNTER}  console=True
        Log  ==============================================================================  console=True
        Step 3: Get initial date UTC info
        Run Keyword If  '${RESET_CONFIGURATION}' == 'True'  Run Keywords
        ...  Step 4: BTS Reset Configuration
        ...  AND  Check BTS reset behavior after BTS Reset Configuration based on IMS info
        ...  ELSE  Log  Step 4: BTS Reset Configuration will be skipped  console=True
        Step 5: Planned BTS Recommissioning
        Step 6: Check final BTS state
        Step 7: Check final BTS alarms
        Step 8: Get final date UTC info
        Step 9: Check BTS reset behavior based on IMS info
        Step 10: Check final number and state of Cells and RMs
    END

TC Parameters check
    [Documentation]
    ...  Detect needed BTS SCF
    ...  If SCF is not specified in RECOMMISSIONING_SBTS, will download the current SCF and use it

    ${scf_path_tmp}=  Run Keyword If  '${RECOMMISSIONING_SBTS}' == 'NONE'
    ...  Admin Collect scf.xml with timestamp TAF  alias=${alias_local}  folder_path=${BTSFiles}/${alias_local}
    ...  ELSE  Set Variable  ${RECOMMISSIONING_SBTS}

    OperatingSystem.File Should Exist  ${scf_path_tmp}
    ${bts_info_tmp}=  Admin Get BTS state info  alias=${alias_local}
    Set Test Variable  ${sbts_commissioning_scf_path}  ${scf_path_tmp}
    Set Test Variable  ${bts_info}  ${bts_info_tmp}

Step ${index}: Check ${when} BTS state
    [Documentation]
    ...  BTS state is checked according to Admin

    Log  Step ${index}: Check ${when} BTS state  console=True
    Admin Check BTS RAT Procedural State  alias=${alias_local}  timeout=600
    Admin Check BTS Procedural and Blocking states  ${OnAir_}  ${Unblocked_}  600  ${alias_local}
    Log  BTS site - proceduralState: OnAir, blockingState: Unblocked  console=True

Step ${index}: Check ${when} BTS alarms
    [Documentation]
    ...  BTS alarms are compared with values from expected, ignored and critical alarms lists. BTS alarms are get from Admin

    [Timeout]  15 min
    Log  Step ${index}: Check ${when} BTS alarms  console=True
    Get and Check Alarms SOAM  alias=${alias_local}  expected_alarms=@{EMPTY}  ignored_alarms=${${alias_local.upper()}_IGNORED_ALARMS}
    ...  critical_alarms=${${alias_local.upper()}_CRITICAL_ALARMS}
    Log  BTS site - expected, ignored and critical alarms checked  console=True

Step ${index}: Get ${when} date UTC info
    Log  Step ${index}: Get ${when} date UTC info  console=True
    Get Current Date UTC info  ${when}

Step ${index}: BTS Reset Configuration
    [Documentation]
    ...  BTS Reset Configuration

    Log  Step ${index}: BTS Reset Configuration  console=True
    Reset BTS Configuration TAF  connection=${alias_local}  wait_for_admin_connection=False  remove_operator_certificates=False
    ...  remove_user_account_credentials=True  repair_center_reset=True

    Wait For Target To Be Reachable TAF  hostname=${${alias_local.upper()}}[${alias_local.upper()}_TECH_IP_ADDRESS]  timeout=250
    ...  remote_host=${${alias_local.upper()}}[${alias_local.upper()}_PC_IP_ADDRESS]
    Log Long String  BTS SM (${${alias_local.upper()}}[${alias_local.upper()}_TECH_IP_ADDRESS] from localhost) has been reachable within 250
    ...  seconds  console=True
    Wait Until Keyword Succeeds  5 min  1 min  Uncommission module status BTS SOAM
    Log  BTS Reset Configuration completed!  console=True
    Get Current Date UTC info  end_reset

Step ${index}: Planned BTS Recommissioning
    [Documentation]
    ...  Planned BTS recommissioning with SCF file is triggered. The new SCF file is loaded on BTS SM and a reboot should be triggered after

    [Timeout]  15 min
    Log  Step ${index}: Planned BTS Recommissioning  console=True

    Log  Commissioning via ADMIN will be performed using ${sbts_commissioning_scf_path}  console=True
    coam.Perform Commissioning  bts_id=${bts_info[0]}  scf_file=${sbts_commissioning_scf_path}  skip_parameter_relation_errors=True
    ...  should_activate=True  timeout=400  alias=${alias_local}
    Log  BTS commissioning has been performed  console=True

    Get Current Time  sbts_initial

    Run Keyword If  ${SBTS_SCF_VALIDATION}  Check BTS SCF Validation On Demand  alias=${alias_local}

    Check SW configuration did not change

    Get Current Time  sbts_before_check
    ${sbts_before_check_elapsed_time}=  DateTime.Subtract Date from Date  ${time_sbts_before_check}  ${time_sbts_initial}  number
    ${sbts_remained_time}=  BuiltIn.Evaluate  ${SBTS_MAX_WAIT_TIME}-${sbts_before_check_elapsed_time}
    Admin Check BTS Procedural and Blocking states  ${OnAir_}  ${Unblocked_}  ${sbts_remained_time}  ${alias_local}
    Get Current Time  sbts_final
    ${sbts_reset_elapsed_time}=  DateTime.Subtract Date From Date  ${time_sbts_final}  ${time_sbts_initial}  number
    Export ResetTime Results  ${alias_local}  ${BTS Files}/${alias_local}/ResetTimeInfo.txt  planned_recommissioning  sbts  ${EMPTY}
    ...  ${sbts_reset_elapsed_time}  ${EMPTY}
    Check KPI  ${sbts_reset_elapsed_time}  ${SBTS_RESET_WRN_THR}

Step ${index}: Check BTS reset behavior based on IMS info
    [Documentation]
    ...  BTS RESET info is checked based on IMS info.
    ...  Reset behavior as expected if: reset number is 2 if RESET_CONFIGURATION=True else reset number is 1
    ...  Otherwise, reset behavior not as expected, then errors are added to report and failed.

    Log  Step ${index}: Check BTS reset behavior based on IMS info  console=True
    ${log_level}=  Set Variable If  '${VERDICT_WRONG_SBTS_RESET_NUMBER}' == 'PASS'  WARN  ERROR
    Run Keyword and Continue on Failure  Run Keyword If  '${RESET_CONFIGURATION}' == 'True'
    ...  Get and check BTS RESET info from IMS file  expected_reset_number=2  alias=${alias_local}
    ...  start_point_timestamp_UTC=${date_timestamp_initial_UTC}  end_point_timestamp_UTC=${date_timestamp_final_UTC}  remove_ims_file=False
    ...  log_level=${log_level}
    ...  ELSE IF  '${RESET_CONFIGURATION}' == 'False'
    ...  Get and check BTS RESET info from IMS file  expected_reset_number=1  alias=${alias_local}
    ...  start_point_timestamp_UTC=${date_timestamp_initial_UTC}  end_point_timestamp_UTC=${date_timestamp_final_UTC}  remove_ims_file=False
    ...  log_level=${log_level}

Step ${index}: Check final number and state of Cells and RMs
    [Documentation]
    ...  Following checks are performed:
    ...  - number of configured cells and radio modules in SCF are properly mapped on BTS running view ADMIN
    ...  - check cells states
    ...  - check radio modules states

    Log  Step ${index}: Check final number and state of Cells and RMs  console=True
    RFS Test Case Final Checks

Uncommission module status BTS SOAM
    [Documentation]
    ...  Checks procedural state of BTS SOAM

    ${BTS state}=  coam.Get Mrbts State  timeout=600  alias=${alias_local}
    Log  BTS proceduralState is: ${BTS state}  console=True
    Should Contain  ${NotCommissioned_}  ${BTS state}

Check BTS reset behavior after BTS Reset Configuration based on IMS info
    [Documentation]
    ...  BTS RESET info is checked based on IMS info. Reset behavior as expected if:
    ...  - SBTS site: reset number is 1
    ...  Otherwise, reset behavior not as expected, then errors are added to report and failed.

    Log  Check BTS reset behavior after BTS Reset Configuration based on IMS info  console=True

    ${log_level}=  Set Variable If  '${VERDICT_WRONG_SBTS_RESET_NUMBER}' == 'PASS'  WARN  ERROR
    Get and check BTS RESET info from IMS file  expected_reset_number=1  alias=${alias_local}
    ...  start_point_timestamp_UTC=${date_timestamp_initial_UTC}  end_point_timestamp_UTC=${date_timestamp_end_reset_UTC}  remove_ims_file=False
    ...  log_level=${log_level}

Check SW configuration did not change
    [Documentation]
    ...  Extract BTS active and passive SWs using Admin and compare to initial values. Fail if something changed

    ${current_active_SW}  ${current_passive_SW}=  Wait Until Keyword Succeeds  5m  20s  Admin Get BTS SW Version  ${alias_local}
    ${initial_SW_list}=  Create List  ${${alias_local} active SW}  ${${alias_local} passive SW}
    ${current_SW_list}=  Create List  ${current_active_SW}  ${current_passive_SW}
    ${no_sw_change}=  Run Keyword And Return Status  Should Be Equal  ${initial_SW_list}  ${current_SW_list}
    Run Keyword If  not ${no_sw_change}  Run Keywords
    ...  Log  SW configuration changed! ${alias_local} SW active/passive: ${current_active_SW}/${current_passive_SW}  console=True
    ...  AND  Fail  SW configuration changed!

TC Setup
    ${tech_preset_list}=  Create List  SBTS
    Common Test Setup  preset_techs=${tech_preset_list}  common_sbts=${TRUE}  infomodelSetup=${FALSE}

TC Teardown
    Common Test Teardown
