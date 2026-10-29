*** Settings ***
Documentation    TC__PM__RFS__KPI_PM_Counters_benchmarking
Variables    tc_variables/pm__rfs__kpi_pm_counters_benchmarking_alarms_definitions.py
Resource    ../../resources/rfs_frame_rfs_soam_taf.robot
Library    taf.ul.energy_efficiency_monitoring  WITH NAME  eem
Library    ../../resources/python_resources/BenchmarkDb.py  WITH NAME  db
Library    taf/rfrl/procedures/resources/python/scout/scout_comparator/ScoutComparator.py  WITH NAME  scout_comparator

*** Variables ***
${BTS}                             # BTS on which KPI/PM counters check will be performed. Should be labeled as BTSx (x is test_pc number in init.py)
${BTS_SCF}                         # SCF file path for BTS recommissioning before KPI/PM counters check. By default empty value means that no BTS
                                   # recommissioning is performed, otherwise BTS recommissioning with SCF. e.g. /home/ute/Downloads/BTS_SCF.xml
${SCOUT_BTS_NAME}                  # BTS name as defined in Scout tool, e.g. 10_18_UTESRANMTNRL23_1
${SCOUT_TEMPLATE_ID}               # Template id as defined in Scout tool. Template should contain requested KPI/PM counters for Scout Comparator
                                   # report
${SCOUT_ALPHA}           0.005     # The alpha index used in Scout Comparator report (for t-test calculation), by default 0.005
${COUNTER_INTERVAL}      15        # Time interval to get KPI/PM counters, default value 15 (minutes)
${COUNTER_CYCLES}        1         # Number of counter intervals required to collect KPI/PM counters, by default 1. When argument
                                   # ${FIRST_TIME_RANGE_SET} is set to False, this value should be the same as used in previous testcase run
${L3_CALL_CHECK}         True      # Specifies if L3 call will be performed during KPI/PM counters collect period. Possible values: True or False;
                                   # default value True
${L3_CALL_KW_INFO}       &{EMPTY}  # L3 call KW info as dictionary with following structure:
                                   # - 'KW_resource_path':<path to specific resource where external KW is defined>
                                   # - 'KW_name':<external L3 call KW name to be run>
                                   # - 'KW_impact':<impact of external L3 call KW run on testcase run>
${L3_CALL_KW_ARGUMENTS}  &{EMPTY}  # L3 call KW arguments as dictionary containing arguments info for external L3 call KW
${FIRST_TIME_RANGE_SET}  False     # Allow user to set BTS records in database without trigger Scout Comparator report.
                                   # Possible values: True or False; default value False
                                   # - True: testcase is run just to set BTS records in database (no triggered Scout Comparator report as no previous
                                   # BTS records related to testcase scenario are available in database)
                                   # - False: testcase is run and previous BTS records related to testcase scenario available in database are used
                                   # by Scout Comparator report

*** Keywords ***
TC__PM__RFS__KPI_PM_Counters_benchmarking
     [Documentation]
    ...  [CASE LINK]: https://jiradc.ext.net.nokia.com/browse/TAT-29091
    ...
    ...  *****************
    ...  Basic information
    ...  *****************
    ...  Test case for KPI/PM counters benchmarking using Scout Comparator report.
    ...  The main steps performed for the test are:
    ...  - check initial state and alarms for all BTS
    ...  - perform (if required) BTS recommissioning with new SCF
    ...  - get BTS counters period info and set
    ...  - perform (if required) call
    ...  - set BTS records in database
    ...  - wait for BTS counters to be generated
    ...  - generate (if required) Scout Comparator report based on current and previous testcase run
    ...  - validate (if required) Scout Comparator report result
    ...  - check final state and alarms for all BTS
    ...  Pass criteria: KPI/PM counters benchmarking works as expected; states and alarms are as expected
    ...
    ...  ******************
    ...  History of changes
    ...  ******************
    ...  - 22.04.2025 - https://jiradc.ext.net.nokia.com/browse/TAT-29091 - Implementation -New TC- General_SiSo_KPI_PM_Counters_benchmarking.robot
    ...  - 06.06.2025 - https://jiradc.ext.net.nokia.com/browse/TAT-29345 -
    ...  PM__RFS__KPI_PM_Counters_benchmarking update due to taf.sw.scout enhancement

    Set Tags    CA-STATE    OWNER-catalin.chiorean@nokia.com   AUTHOR-dinu.olariu@nokia.com    PHASE-QT    SW-SBTS25R3

    TC Preconditions
    Step 1: Check initial all BTS state
    Step 2: Check initial all BTS alarms
    Step 3: Check BTS recommissioning requirement
    Step 4: Get BTS counters period info
    Step 5: Perform call
    Step 6: Set BTS records in database
    Step 7: Generate and validate Scout Comparator report
    Step 8: Check final all BTS state
    Step 9: Check final all BTS alarms
    Step 10: Check final number and state of Cells and RMs

TC Preconditions

    Set Test Variable  ${TC_name}  PM__RFS__KPI_PM_Counters_benchmarking
    Set Test Variable  ${SCOUT_api}  d3c60817-a9a2-4e57-acc6-a490361e9dde

    ${BTS_alias_label_dict}  ${BTS_label_alias_dict}=  Get BTS alias label info dict
    ${BTS_label_list}=  Get Dictionary Values  ${BTS_alias_label_dict}  False

    Run Keyword If  '${BTS}' == ''  Run Keywords
    ...  Log  Test argument \${BTS} not valued. Please select a value from configured BTS: ${BTS_label_list}  console=True
    ...  AND  Fail  Improper value for argument!
    ...  ELSE IF  '${BTS}' not in ${BTS_label_list}  Run Keywords
    ...  Log  Selected value ${BTS} for test argument \${BTS} is not valid. Please select a value from configured BTS: ${BTS_label_list}
    ...  console=True
    ...  AND  Fail  Improper value for argument!

    ${BTS_alias}=  Get From Dictionary  ${BTS_label_alias_dict}  ${BTS}
    Set Test Variable  ${BTS_alias}

    Run Keyword If  '${SCOUT_BTS_NAME}' == ''  Run Keywords
    ...  Log  Test argument \${SCOUT_BTS_NAME} not valued. Please select BTS name as defined in Scout tool!  console=True
    ...  AND  Fail  Improper value for argument!

    ${Scout_setup_status}  ${Scout_setup_response}=  Run Keyword And Ignore Error  Setup Scout  scout_testline_name=${SCOUT_BTS_NAME}

    Run Keyword If  '${Scout_setup_status}' == 'FAIL'  Run Keywords
    ...  Log  Scout setup failed! ${Scout_setup_response}  console=True
    ...  AND  Fail  Scout setup failed!

    ${BTS_info}=  Get Bts Info  connection=${BTS_alias}
    ${BTS_id}=  Set Variable  ${BTS_info['id']['internal']}
    ${MRBTS_id}=  Set Variable  ${BTS_info['mrbtsID']}
    ${BTS_swVersion}=  Set Variable  ${BTS_info['swInfo']['swVersion']}
    Set Test Variable  ${BTS_id}
    Set Test Variable  ${MRBTS_id}
    Set Test Variable  ${current_BTS_swVersion}  ${BTS_swVersion}

    db.Setup Db  index_name=benchmark_db

    Check and get previous run testcase info

    [Teardown]  scout.Teardown Scout API

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
    ...  SBTS alarms are compared with values from expected, ignored and critical alarms lists. SBTS alarms are get from Admin

    Log  Step ${index}: Check ${when} all BTS alarms  console=True

    FOR  ${alias}  IN  @{alias_list}

        Log  ***** Check ${when} BTS ${alias} alarms *****  console=True
        Get and Check Alarms SOAM  alias=${alias}  expected_alarms=@{EMPTY}  ignored_alarms=${${alias.upper()}_IGNORED_ALARMS}
        ...  critical_alarms=${${alias.upper()}_CRITICAL_ALARMS}
        Log  BTS ${alias} site - expected, ignored and critical alarms checked  console=True

    END

Step ${index}: Check BTS recommissioning requirement
    [Documentation]
    ...  Check BTS recommissioning requirement

    Log  Step ${index}: Check BTS recommissioning requirement  console=True

    Run Keyword If  '${BTS_SCF}' == ''  Run Keywords
    ...  Log  No BTS ${BTS_alias} recommissioning requirement.  console=True
    ...  AND  Return From Keyword

    Log  Perform BTS ${BTS_alias} recommissioning with SCF: ${BTS_SCF}  console=True
    coam.Perform Commissioning  bts_id=${BTS_id}  scf_file=${BTS_SCF}  skip_parameter_relation_errors=False  should_activate=True  timeout=600
    ...  connection=${BTS_alias}
    Log  BTS ${BTS_alias} recommissioning finished.  console=True

    Check BTS SCF Validation On Demand  alias=${BTS_alias}

    Admin Check BTS Procedural and Blocking states  ${OnAir_}  ${Unblocked_}  600  ${BTS_alias}
    Log  BTS ${BTS_alias} site - proceduralState: OnAir, blockingState: Unblocked, as expected!  console=True

Step ${index}: Get BTS counters period info
    [Documentation]
    ...  Get BTS counters period info

    Log  Step ${index}: Get BTS counters period info  console=True

    Log  Wait for start of BTS counter period  console=True
    ${COUNTER_start_info}=  eem.Wait For Next Pm Period  interval=${COUNTER_INTERVAL}min

    ${start_date_epoch}=  Get From List  ${COUNTER_start_info}  0
    ${start_date}=  Convert Date  ${start_date_epoch}  result_format=timestamp  exclude_millis=True
    ${start_date}=  Add Time To Date  ${start_date}  2min  exclude_millis=True
    ${COUNTER_start_date_epoch}=  Get From List  ${COUNTER_start_info}  1
    ${COUNTER_start_date}=  Convert Date  ${COUNTER_start_date_epoch}  result_format=timestamp  exclude_millis=True
    ${COUNTER_CYCLES_INTERVAL}=  Evaluate  ${COUNTER_CYCLES} * ${COUNTER_INTERVAL}
    ${COUNTER_end_date}=  Add Time To Date  ${COUNTER_start_date}  ${COUNTER_CYCLES_INTERVAL}min  exclude_millis=True
    ${end_date}=  Add Time To Date  ${COUNTER_end_date}  2min  exclude_millis=True

    Log  Start BTS counter period timestamp (UTC): ${COUNTER_start_date}  console=True
    Log  End BTS counter period timestamp (UTC): ${COUNTER_end_date}  console=True

    Set Test Variable  ${current_run_start_date}  ${start_date}
    Set Test Variable  ${current_run_end_date}  ${end_date}
    Set Test Variable  ${COUNTER_start_date}
    Set Test Variable  ${COUNTER_end_date}

    Wait Until Keyword Succeeds  5min  1s  Wait for reach target date  target_date=${start_date}

Step ${index}: Perform call
    [Documentation]
    ...  Perform call

    Log  Step ${index}: Perform call  console=True

    Run Keyword If  '${L3_CALL_CHECK}' != 'True'  Run Keywords
    ...  Log  No L3 call requested during test scenario. This step will be skipped!  console=True
    ...  AND  Return From Keyword

    ${KW_resource_path}=  Get From Dictionary  ${L3_CALL_KW_INFO}  KW_resource_path
    ${KW_name}=  Get From Dictionary  ${L3_CALL_KW_INFO}  KW_name
    ${KW_impact}=  Get From Dictionary  ${L3_CALL_KW_INFO}  KW_impact

    Log  =========================  console=True
    Log  L3 call selected KW name: ${KW_name}  console=True
    Log  =========================  console=True

    ${KW_status}=  Execute External KW  KW_resource_path=${KW_resource_path}  KW_name=${KW_name}  KW_args=${L3_CALL_KW_ARGUMENTS}

    Run Keyword If  '${KW_status}' == 'True'  Run Keywords
    ...  Log  L3 call successfully performed: ${KW_name} run passed  console=True
    ...  AND  Return From Keyword

    Run Keyword If  '${KW_impact}' == 'False'
    ...  Log  L3 call failed: ${KW_name} run failed  level=WARN
    ...  ELSE IF  '${KW_impact}' == 'True'  Run Keywords
    ...  Log  L3 call failed: ${KW_name} run failed  level=ERROR
    ...  AND  Fail  L3 call failed: ${KW_name} run failed

Step ${index}: Set BTS records in database
    [Documentation]
    ...  Set BTS records in database

    Log  Step ${index}: Set BTS records in database  console=True

    Log  Wait for end of BTS counters period  console=True
    ${COUNTER_INTERVAL_check}=  Evaluate  (${COUNTER_CYCLES} + 1) * ${COUNTER_INTERVAL}
    Wait Until Keyword Succeeds  ${COUNTER_INTERVAL_check}min  1min  Wait for reach target date  target_date=${COUNTER_end_date}

    ${DB_save_datetime_status}=  Run Keyword and Return Status  db.Save Datetime For Bts  bts_id=${MRBTS_id}  tc_name=${TC_name}
    ...  template_id=${SCOUT_TEMPLATE_ID}  start_date=${current_run_start_date}  end_date=${current_run_end_date}  cycles=${COUNTER_CYCLES}
    ...  sw_version=${current_BTS_swVersion}

    Run Keyword If  '${DB_save_datetime_status}' == 'True'
    ...  Log  Save BTS ${BTS_alias} records successfully finished  console=True
    ...  ELSE  Run Keywords
    ...  Log  Save BTS ${BTS_alias} records failed!  level=ERROR
    ...  AND  Fail  Save BTS ${BTS_alias} records failed!  level=ERROR

Step ${index}: Generate and validate Scout Comparator report
    [Documentation]
    ...  Generate and validate Scout Comparator report

    Log  Step ${index}: Generate and validate Scout Comparator report  console=True

    Run Keyword If  '${FIRST_TIME_RANGE_SET}' == 'True'  Run Keywords
    ...  Log Long String  No Scout Comparator report will be triggered for this run as argument \${FIRST_TIME_RANGE_SET} is set to True. This step
    ...  will be skipped!  console=True
    ...  AND  Return From Keyword

    Log  Wait for Scout tool safe time window of 20 minutes  console=True
    ${SCOUT_safe_date}=  Add Time To Date  ${current_run_end_date}  20min  exclude_millis=True
    Wait Until Keyword Succeeds  30min  1min  Wait for reach target date  target_date=${SCOUT_safe_date}

    Log  Generate Scout Comparator Report with following info:  console=True
    Log  - Pick start date time of the reference time range (UTC): ${reference_run_start_date}  console=True
    Log  - Pick end date time of the reference time range (UTC): ${reference_run_end_date}  console=True
    Log  - Pick start date time of the current time range (UTC): ${current_run_start_date}  console=True
    Log  - Pick end date time of the current time range (UTC): ${current_run_end_date}  console=True
    Log  - Alpha factor: ${SCOUT_ALPHA}  console=True

    ${SCOUT_template_id_int}=  Convert To Integer  ${SCOUT_TEMPLATE_ID}
    ${SCOUT_template_ids}=  Create List  ${SCOUT_template_id_int}

    scout.Setup Scout  scout_testline_name=${SCOUT_BTS_NAME}  api_key=${SCOUT_api}

    ${SCOUT_report_info}=  scout.Generate Comparator Report  report_name=Counters_benchmarking  template_ids=${SCOUT_template_ids}
    ...  reference_start_time=${reference_run_start_date}  reference_end_time=${reference_run_end_date}  current_start_time=${current_run_start_date}
    ...  current_end_time=${current_run_end_date}  reference_period_description=${reference_BTS_swVersion}
    ...  current_period_description=${current_BTS_swVersion}  alpha_factor=${SCOUT_ALPHA}

    ${SCOUT_report_id}=  Set Variable  ${SCOUT_report_info[0]['comparator_reports'][0]['id']}

    Wait Until Keyword Succeeds  1min  5s  Validate Scout Report Is Ready  report_id=${SCOUT_report_id}
    scout_comparator.Validate Report  report_id=${SCOUT_report_id}

    Log  Scout Comparator Report successfully validated!  console=True

    [Teardown]  scout.Teardown Scout API

Step ${index}: Check final number and state of Cells and RMs
    [Documentation]
    ...  Following checks are performed:
    ...  - number of configured cells and radio modules in SCF are properly mapped on BTS running view ADMIN
    ...  - check cells states
    ...  - check radio modules states

    Log  Step ${index}: Check final number and state of Cells and RMs  console=True
    RFS Test Case Final Checks

Check and get previous run testcase info

    Run Keyword If  '${FIRST_TIME_RANGE_SET}' == 'True'  Run Keywords
    ...  Log  Testcase will be run just to set BTS records in database. No Scout Comparator report will be triggered for this run!  console=True
    ...  AND  Return From Keyword

    Check database for BTS records

    Run Keyword If  '${FIRST_TIME_RANGE_SET}' == 'False' and '${DB_BTS_record_status}' == 'False'  Run Keywords
    ...  Log Long String  No BTS records found in database. Please rerun testcase with argument \${FIRST_TIME_RANGE_SET} set to True to set BTS
    ...  records in database!  console=True
    ...  AND  Fail  No BTS records found in database.

Check database for BTS records

    ${DB_BTS_record_status}=  db.Check If Record Exists For Bts  bts_id=${MRBTS_id}  tc_name=${TC_name}  template_id=${SCOUT_TEMPLATE_ID}
    ...  cycles=${COUNTER_CYCLES}

    Set Test Variable  ${DB_BTS_record_status}
    Return From Keyword If  '${DB_BTS_record_status}' == 'False'

    ${DB_BTS_record_info}=  db.Read Data For Bts  bts_id=${MRBTS_id}  tc_name=${TC_name}  template_id=${SCOUT_TEMPLATE_ID}  cycles=${COUNTER_CYCLES}

    Set Test Variable  ${reference_run_start_date}  ${DB_BTS_record_info['start_date']}
    Set Test Variable  ${reference_run_end_date}  ${DB_BTS_record_info['end_date']}
    Set Test Variable  ${reference_BTS_swVersion}  ${DB_BTS_record_info['sw_version']}

Wait for reach target date
    [Arguments]  ${target_date}

    ${target_date_epoch}=  Convert Date  ${target_date}  result_format=epoch  exclude_millis=True
    ${current_date_epoch}=  Get Current Date  result_format=epoch  exclude_millis=True
    Should Be True  ${current_date_epoch} > ${target_date_epoch}

Validate Scout Report Is Ready
    [Arguments]  ${report_id}
    ${report_ready}=  scout_comparator.Validate Report Calculation Successful  report_id=${report_id}
    Run Keyword If  not ${report_ready}
    ...  Fail  Scout report is not ready for validation

TC Setup
    ${tech_preset_list}=  Create List  SBTS  SBTS  SBTS  SBTS
    Common Test Setup  preset_techs=${tech_preset_list}  common_sbts=${TRUE}  infomodelSetup=${FALSE}

TC Teardown
    Common Test Teardown