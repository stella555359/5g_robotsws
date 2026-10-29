*** Settings ***
Documentation
  ...  AUTHOR-przemyslaw.kempa@nokia.com  MAINTAINER-przemyslaw.kempa@nokia.com
  ...  [CASE LINK]: https://rep-portal.ext.net.nokia.com/details/qc-case/
  ...
  ...  *****************
  ...  Basic information
  ...  *****************
  ...  The purpose of this test case is to verify the correct behavior of BTS during multiple power resets.
  ...  It ensures that after each iteration of BTS power reset, the system recovers back to the normal operating state
  ...  within the specified time frame.
  ...
  ...  *****************
  ...  Test Objectives
  ...  *****************
  ...  1. Verify that BTS powers off and on correctly during each reset iteration.
  ...  2. Ensure that BTS state is restored to the expected operational state after a power reset.
  ...  3. Validate that all startup parameters are correctly configured after the reset.
  ...  4. Check for any unexpected alarms or faults during and after the reset process.
  ...  5. Confirm that the recovery time is within the specified limits.
  ...
  ...  *****************
  ...  Test Steps
  ...  *****************
  ...  1. Power off the BTS.
  ...  2. Power on the BTS.
  ...  3. Verify the BTS state.
  ...  4. Validate the startup parameters.
  ...  5. Check for alarms and faults.
  ...
  ...  *****************
  ...  Expected Results
  ...  *****************
  ...  - BTS powers off and on without issues.
  ...  - BTS state is restored to "OnAir" or the expected operational state.
  ...  - Startup parameters are correctly configured.
  ...  - No unexpected alarms or faults are present.
  ...  - Recovery time is within the specified time frame.
  ...
  ...  *****************
  ...  Variables and KPI usage
  ...  *****************
  ...  KPI_REF_DICT = {
  ...    'bts_id': {'kpi3': ['ref_time', 'tc_verdict']},
  ...  }
  ...
  ...  Example of usage:
  ...      @{kpi3_bts_id}    125    ${TRUE}
  ...      &{kpis_bts_id}    kpi3=@{kpi3_bts_id}
  ...      &{KPI_REF_DICT}  <bts_id>=&{bts_id}
  ...
  ...  Allowed values in 'KPI_REF_DICT' (dictionary is empty by default):
  ...      bts_id (bts id; if bts_id missing in dictionary, calculated KPI is only printed to console)
  ...      tc_verdict (user switch that allows to fail or not TC when calculated startup time exceeds 'ref_time';
  ...      calculated KPI is printed to console) = ${TRUE}/${FALSE}
  ...      ref_time (expected max time for radio to start-up;
  ...      if 'None' used, tc_verdict is skipped and calculated KPI is only printed to console) = int values/None
  ...
  ...  'SKIP_KPIs' - custom switch to skip completely KPI mechanism
  ...  'CONFIGURATION_STARTUP_TIMEOUT' - custom timeout for states/faults check after radio power on
  ...
  ...  ******************
  ...  History of changes
  ...  ******************
  ...  - 10.05.2025 - Initial creation

Resource  ./../../Resources/Setup/setup_and_teardown.robot
Resource  ./../../Resources/Robot/KPI.robot

*** Variables ***
${CONFIGURATION_STARTUP_TIMEOUT}  360        # Maximum time (in seconds) allowed for BTS to recover to its normal state after a power reset.
${KPI_REF_DICT}                   &{EMPTY}   # dictionary with parameters for KPI control
${SKIP_KPIs}                      ${FALSE}   # user can skip completely KPI mechanism

*** Keywords ***
TC__STARTUP_Site_Power_Reset
    Set Tags  AUTHOR-przemyslaw.kempa@nokia.com  MAINTAINER-przemyslaw.kempa@nokia.com
    Common Test Setup
    Logging With Timestamp
    ...  message=Site Power Reset TC for every node on list : @{CFG.active_bts_list} will be executed
    ...  style=ONGOING
    FOR  ${bts}  IN  @{CFG.active_bts_list}
      Step 1 Site Power Off  bts=${bts}
      Step 2 Site Power On  bts=${bts}
      Step 3 Verify BTS State  bts=${bts}
      Step 4 Verify Startup Parameters  bts=${bts}
      Step 5 Verify Alarms  bts=${bts}
    END
    [Teardown]  Common Test Teardown

Step 1 Site Power Off
    [Arguments]  ${bts}
    Logging With Timestamp
    ...  message=Step 1 Site Power Off
    ...  style=STEP
    ...  frame=${TRUE}
    Logging With Timestamp
    ...  message=Site Power Off for BTS-${bts} will be executed. Please wait...
    ...  style=ONGOING
    PDU Switch OFF Device Lists
    ...  ${CFG['NODES']['${bts}']['scf_hw_sm_list']}
    PDU Switch OFF Device Lists
    ...  ${CFG['NODES']['${bts}']['scf_hw_fr_list']}
    PDU Switch OFF Device Lists
    ...  ${CFG['NODES']['${bts}']['scf_hw_asir_list']}
    Sleep  20 sec
    Logging With Timestamp
    ...  message=Site Power Off for BTS-${bts} finished.
    ...  style=DONE

Step 2 Site Power On
    [Arguments]  ${bts}
    Logging With Timestamp
    ...  message=Step 2 Site Power On
    ...  style=STEP
    ...  frame=${TRUE}
    Logging With Timestamp
    ...  message=Site Power On for BTS-${bts} will be executed. Please wait...
    ...  style=ONGOING
    PDU Switch ON Device Lists
    ...  ${CFG['NODES']['${bts}']['scf_hw_sm_list']}
    ${power_start_timestamp}  Get Current Date  UTC
    Set Test Variable  ${POWER_START_TIMESTAMP}  ${power_start_timestamp}
    PDU Switch ON Device Lists
    ...  ${CFG['NODES']['${bts}']['scf_hw_fr_list']}
    PDU Switch ON Device Lists
    ...  ${CFG['NODES']['${bts}']['scf_hw_asir_list']}
    Logging With Timestamp
    ...  message=Site Power On for BTS-${bts} finished
    ...  style=ONGOING
    Run Keyword And Ignore Error  STATE BTS Address Is Pingable
        ...  host_ip_addr=192.168.255.129
        ...  timeout=240
        ...  bts_id=${bts}
    Logging With Timestamp
    ...  message=Power on for BTS-${bts} completed successfully.
    ...  style=DONE

Step 3 Verify BTS State
    [Arguments]  ${bts}
    Logging With Timestamp
    ...  message=Step 3 Verify BTS State
    ...  style=STEP
    ...  frame=${TRUE}
    Logging With Timestamp
    ...  message=Verifying BTS state for BTS-${bts}. Please wait...
    ...  style=ONGOING
    CM BTS Admin Not Available
    ...  node=${bts}
    ...  timeout=120
    Run Keyword And Continue On Failure  STATE Verify BTS states
    ...  node_id=${bts}
    ...  expected_BTS_status=OnAir
    ...  HW_check=${TRUE}
    ...  cells_check=${TRUE}
    ...  scf_check=${FALSE}
    ...  timeout=${CONFIGURATION_STARTUP_TIMEOUT}
    Logging With Timestamp
    ...  message=Verification of BTS state for BTS-${bts} completed successfully.
    ...  style=DONE

Step 4 Verify Startup Parameters
    [Arguments]  ${bts}
    Logging With Timestamp
    ...  message=Step 4 Verify Startup Parameters
    ...  style=STEP
    ...  frame=${TRUE}
    Logging With Timestamp
    ...  message=Verifying startup parameters for BTS-${bts}. Please wait...
    ...  style=ONGOING
    ${is_kpi_ref_dict}  Run Keyword And Return Status  Variable Should Exist  ${KPI_REF_DICT['${bts}']}
    ${calc_dict}  Set Variable If  ${is_kpi_ref_dict}  ${KPI_REF_DICT['${bts}']}  &{EMPTY}
    IF  '${POWER_START_TIMESTAMP}'!='${0}' and not ${SKIP_KPIs}
      ${ims_dir}  Run Keyword If  ${ITERATION}==0  Set Variable  ${CFG['test_logs_path']}
      ...  ELSE  Set Variable  ${CFG['test_logs_path']}/Loop_${ITERATION}
      Set Test Variable  ${IMS_DIR}  ${ims_dir}
      ${file_not_exists}  Run Keyword And Return Status  OperatingSystem.File Should Not Exist  ${CFG['test_logs_path']}/KPI_results.txt
      IF  ${file_not_exists} and not ${SKIP_KPIs}  Create File  ${CFG['test_logs_path']}/KPI_results.txt
      IF  ${ITERATION}!=0  Run Keyword And Ignore Error
      ...  Append To File
      ...  path=${CFG['test_logs_path']}/KPI_results.txt
      ...  content=+++++ LOOP ${ITERATION} +++++${\n}
      kpi.Clear Results
      ${kpi_result_dict}  KPI Execute Calculation For KPI3
      ...  bts_startup_start_date=${POWER_START_TIMESTAMP}
      ...  bts_id=${bts}
      ...  ims_directory=${IMS_DIR}
      ...  calc_dict=${calc_dict}
      KPI Report Results  kpi_result_dict=${kpi_result_dict}
      KPI Save KPI Calculations To File
      ...  file_path=${CFG['test_logs_path']}/KPI_results.txt
      ...  kpi_result_dict=${kpi_result_dict}
      ...  bts_id=${bts}
      ...  object_dscrp=Site_power_reset-${bts}
    ELSE
      Logging With Timestamp
      ...  message=KPIs were no calculated. Parameter SKIP_KPIs is ${SKIP_KPIs}
    END

Step 5 Verify Alarms
    [Arguments]  ${bts}
    Logging With Timestamp
    ...  message=Step 5 Verify Alarms
    ...  style=STEP
    ...  frame=${TRUE}
    Logging With Timestamp
    ...  message=Verifying alarms for BTS-${bts} after power reset. Please wait...
    ...  style=ONGOING
    ${rus_sn_list}  Create List  @{CFG['NODES']['${bts}']['scf_hw_fr_list']}
    ${unexpected_historical_faults_list}  admin.Get Unexpected Historical Alarms  connection=${bts}
    FOR  ${ru_sn}  IN  @{rus_sn_list}
       Exit For Loop If  ${unexpected_historical_faults_list} is None
       FM Check for Alarm 4589
       ...  ru_bts_id=${bts}
       ...  ru_sn=${ru_sn}
       ...  unexpected_historical_alarms_list=${unexpected_historical_faults_list}
    END
    FM Check Unexpected And Historical Faults
    ...  node_id=${bts}
    Logging With Timestamp
    ...  message=Verification of alarms for BTS-${bts} after power reset completed successfully.
    ...  style=DONE
