*** Settings ***
Documentation
  ...  AUTHOR-malgorzata.piecyk-celuch@nokia.com  MAINTAINER-malgorzata.piecyk-celuch@nokia.com
  ...
  ...  *****************
  ...  Basic information
  ...  *****************
  ...
  ...  This testcase is based on the original implementation located at path:
  ...  taf/rfrl/procedures/SISO/General_SiSo_KPI_PM_Counters_benchmarking.robot,
  ...  which is developed by team MN RAN RD VRF WRO1, current owner: Marcin Staniow.
  ...  The section responsible for generating the Scout report uses shared resources from that location from that location:
  ...  taf/rfrl/procedures/resources.
  ...  This testcase PM_KPI_Counters_benchmarking.robot has been modified and adapted to work within our environment and setup.
  ...  If any issues arise or further adjustments are needed, it may be necessary to contact mentioned team,
  ...  who maintain the original version and its dependencies.
  ...
  ...  Step 1: Preconditions For Counters Benchmarking
  ...  Getting cell(s) information for SiSo L3 Call.
  ...  Getting information about testline for preparing Scout Report.
  ...  Setup connection to benchmark database storing test execution results data.
  ...  Checking if TL's records are available in database.
  ...
  ...  Step 2: Perform Site Reset And L3 Call
  ...  Performing site reset.
  ...  Checking if all cells are onAir.
  ...  Performing SiSo L3 Call.
  ...
  ...  Step 3: Generate And Validate Scout Report
  ...  Generate Scout report in the required time.
  ...  Verifying results from Scout report.
  ...  Disconnect connection with benchmark database.

  ...  ******************
  ...  History of changes
  ...  ******************
  ...  - 12.05.2025 - Initial creation

Resource  ./../../Resources/Setup/setup_and_teardown.robot
Library   taf/rfrl/procedures/resources/python/testline/TestLine.py                                WITH NAME  hwpta_testline
Library   taf/rfrl/procedures/resources/python/wait.py                                             WITH NAME  wait
Library   taf/rfrl/procedures/resources/python/counters/benchmarking_db/BenchmarkingDB.py          WITH NAME  benchmarking_db
Library   taf/rfrl/procedures/resources/python/scout/scout_comparator/ScoutComparator.py           WITH NAME  scout_comparator
Library   taf/rfrl/procedures/resources/python/timer/timer.py                                      WITH NAME  timer

*** Variables ***
${SCOUT_TL_NAME}                   # testline name from Scout - Scout Name, e.g. 10_16_UTESRANSISO901_1, 10_16_UTESRANSISO082
${SCOUT_TEMPLATE_ID}               # Id of template needed to use in Scout Comparator report
${START_POINT_GENERATION}  False   # used to generate starting point for future test. Use it if it's first time using test for given BTS
${CYCLES}  1                       # number of full quarter cycles counted starting from the nearest quarter
${ALPHA}  0.005                    # the alpha index, margin of error for verifying counter value, e.g. 0.005
${SELECTED_CELLS}  None            # nrCellIdentity, eutranCellId, cellId or gsmSectorID for L3 Call, will be modified to distname in preconditions
${CELLS_YAML_PATH}                 # mandatory path for ue_config.yaml if ${SISO_L3_CALL} is True
${RECORD_EXISTS}  False

*** Keywords ***
TC__PM_KPI_Counters_benchmarking
  Set Tags  AUTHOR-malgorzata.piecyk-celuch@nokia.com  MAINTAINER-malgorzata.piecyk-celuch@nokia.com
  Common Test Setup
  ${bts_id}  Get From Dictionary  ${CFG}  primary_node_bts_id
  Step 1: Preconditions For Counters Benchmarking  ${bts_id}
  Step 2: Perform Site Reset And L3 Call  ${bts_id}
  Step 3: Generate And Validate Scout Report
  [Teardown]  Common Test Teardown

Step 1: Preconditions For Counters Benchmarking
    [Arguments]  ${bts_id}
    Logging With Timestamp
    ...  message=Step 1: Preconditions For Counters Benchmarking
    ...  style=STEP
    ...  frame=${TRUE}

    IF  '${SCOUT_TL_NAME}'=='${EMPTY}'
        Logging With Timestamp
        ...  message=Variable SCOUT_TL_NAME cannot be empty !
        ...  style=ERROR
        Fail  Variable SCOUT_TL_NAME cannot be empty !
    END

    IF  '${SCOUT_TEMPLATE_ID}'=='${EMPTY}'
        Logging With Timestamp
        ...  message=Variable SCOUT_TEMPLATE_ID cannot be empty !
        ...  style=ERROR
        Fail  Variable SCOUT_TEMPLATE_ID cannot be empty !
    END

    Logging With Timestamp
    ...  message=Get cell(s) info for L3 call procedure

    SiSo Convert Id to Runtime Distname  connection=${bts_id}

    ${bts_type}  hwpta_testline.get_type_of_setup
    Set Test Variable  ${BTS_TYPE}
    Set Test Variable  ${TC_NAME}  PM_KPI_Counters_benchmarking
    ${sw_version}  admin.Get Sw Version  connection=${bts_id}
    Set Test Variable  ${SW_VERSION}

    benchmarking_db.setup  connection=${bts_id}  bts_type=${BTS_TYPE}
    IF  '${START_POINT_GENERATION}'=='False'
        ${record_exists}  benchmarking_db.check_if_record_exists_for_bts
        ...  tc_name=${TC_NAME}
        ...  template_id=${SCOUT_TEMPLATE_ID}
        ...  cycles=${CYCLES}
        Set Test Variable  ${RECORD_EXISTS}
    END

    IF  '${START_POINT_GENERATION}'=='False' and '${RECORD_EXISTS}'=='False'
        Logging With Timestamp
        ...  message=Fail, please rerun test manually with flag `START_POINT_GENERATION` set to True to generate start point.
        ...  style=ERROR
        Fail  No data found in database for TL: ${SCOUT_TL_NAME}, template ID: ${SCOUT_TEMPLATE_ID} and cycles: ${CYCLES}.
    ELSE IF  '${START_POINT_GENERATION}'=='True' and '${RECORD_EXISTS}'=='False'
        Logging With Timestamp
        ...  message=Due to the START_POINT_GENERATION flag being set to True, a start point report will be generated to collect full data.
    ELSE
        Logging With Timestamp
        ...  message=Data for preparing Scout report are available in database.
    END

Step 2: Perform Site Reset And L3 Call
    [Arguments]  ${bts_id}
    Logging With Timestamp
    ...  message=Step 2: Perform Site Reset And L3 Call
    ...  style=STEP
    ...  frame=${TRUE}

    Logging With Timestamp
    ...  message=Site Reset for BTS-${bts_id} will be executed. Please wait...
    ...  style=ONGOING
    ${reset_response}=  Run Keyword And Continue On Failure    admin.Reset Site
    ...  connection=${bts_id}
    ...  wait_for_reconnection=True
    ...  timeout=${CONFIGURATION_STARTUP_TIMEOUT}
    Logging With Timestamp
    ...  message=Site Reset for BTS-${bts_id} finished.
    ...  style=DONE

    ${onair_status}  Run Keyword And Continue On Failure  Wait until keyword succeeds  ${CONFIGURATION_STARTUP_TIMEOUT}  20
    ...  STATE Verify BTS states
    ...  node_id=${bts_id}
    ...  expected_BTS_status=OnAir
    ...  HW_check=${TRUE}
    ...  cells_check=${TRUE}
    ...  scf_check=${FALSE}
    ...  timeout=1200

    IF  '${onair_status}'=='False'
        Logging With Timestamp  message=Cells are not onAir after site reset! Test failed !
        ...  style=ERROR
        Fail  Cells are not onAir after site reset!
    ELSE
        Logging With Timestamp  message=All cells are onAir !
        ...  style=PASS
    END

    Logging With Timestamp
    ...  message=Waiting to the next quarter to start L3 Call procedure...
    ...  style=ONGOING
    wait.wait_until_minutes_before_next_quarter  minutes=10

    Logging With Timestamp
    ...  message=SiSo L3 call will be executed. Please wait...
    ...  style=ONGOING
    Set Test Variable  ${LOGS_DIR}  ${CFG.test_logs_path}/TestFiles
    SiSo L3 Call

Step 3: Generate And Validate Scout Report
    Logging With Timestamp
    ...  message=Step 3: Generate And Validate Scout Report
    ...  style=STEP
    ...  frame=${TRUE}

    Logging With Timestamp
    ...  message=Waiting until next quarter-hour...
    ...  style=ONGOING
    ${start_datetime}  wait.wait_until_next_quarter  return_with_timezone=${True}

    Logging With Timestamp
    ...  message=Waiting ${CYCLES} full quarter-hour cycle(s) to generate complete PM counters data...
    ...  style=ONGOING
    ${end_datetime}  wait.wait_full_quarter_cycles  cycles=${CYCLES}  return_with_timezone=${True}

    Logging With Timestamp
    ...  message=Waiting for data to be available on Scout...
    ...  style=ONGOING
    wait.wait_until_next_hour
    Sleep  10min

    Logging With Timestamp
    ...  message=Generating report ongoing...
    ...  style=ONGOING

    IF  ${RECORD_EXISTS}
    ...  Generate and Verify Scout report
    ...  scout_tl_name=${SCOUT_TL_NAME}
    ...  tc_name=${TC_NAME}
    ...  template_id=${SCOUT_TEMPLATE_ID}
    ...  start_datetime=${start_datetime}
    ...  end_datetime=${end_datetime}
    ...  cycles=${CYCLES}
    ...  sw_version=${SW_VERSION}
    ...  alpha=${ALPHA}
    benchmarking_db.save_datetime_for_bts
    ...  tc_name=${TC_NAME}
    ...  template_id=${SCOUT_TEMPLATE_ID}
    ...  start_datetime=${start_datetime}
    ...  end_datetime=${end_datetime}
    ...  cycles=${CYCLES}
    [Teardown]  benchmarking_db.disconnect


Generate and Verify Scout Report
    [Arguments]  ${scout_tl_name}  ${tc_name}  ${template_id}  ${start_datetime}  ${end_datetime}  ${cycles}  ${sw_version}  ${alpha}
    Logging With Timestamp
    ...  message=Fetching last run data from db and triggering Scout report generation...
    ...  style=ONGOING
    ${db_record_data}  benchmarking_db.read_data_for_bts
    ...  tc_name=${TC_NAME}
    ...  template_id=${template_id}
    ...  cycles=${CYCLES}

    ${report_id}  scout_comparator.trigger_report_generation
    ...  scout_tl_name=${scout_tl_name}
    ...  template_id=${template_id}
    ...  reference_start_time=${db_record_data["start_datetime"]}
    ...  reference_end_time=${db_record_data["end_datetime"]}
    ...  first_period_description=${db_record_data["sw_version"]}
    ...  current_start_time=${start_datetime}
    ...  current_end_time=${end_datetime}
    ...  second_period_description=${SW_VERSION}
    ...  alpha=${ALPHA}

    timer.wait_until_keyword_succeeds_timer  5min
    ...  15s
    ...  Validate Scout Report Is Ready
    ...  report_id=${report_id}

    ${raport_result}  Run Keyword And Return Status  scout_comparator.validate_report  report_id=${report_id}
    IF  '${raport_result}'=='False'
        Logging With Timestamp  message=Scout report has incorrect counters data, check logs! Test failed !
        ...  style=ERROR
        Fail  Scout report has incorrect counters data, check logs! Test failed !
    ELSE
        Logging With Timestamp  message=Scout report validated successfully ! Test passed !\n
        ...  style=PASS
    END


Validate Scout Report Is Ready
    [Arguments]  ${report_id}
    ${report_ready}  scout_comparator.validate_report_calculation_successful  report_id=${report_id}
    IF  '${report_ready}'=='False'
        Logging With Timestamp  message=Report is not still ready for validation. Waiting...
        ...  style=ONGOING
        Fail  Report is not still ready for validation. Waiting...
    ELSE
        Logging With Timestamp  message=Report is ready for validation!
        ...  style=PASS
    END
