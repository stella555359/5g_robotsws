*** Settings ***
Documentation
...  AUTHOR-piotr.korczynski@nokia.com  MAINTAINER-piotr.korczynskia@nokia.com
...  [CASE LINK]: https://rep-portal.ext.net.nokia.com/details/qc-case/36575
...
...  *****************
...  Basic information
...  *****************
...  ******************
...  History of changes
...  ******************
...  - 04.10.2024 - Initial creation

Resource  ./../../Resources/Setup/setup_and_teardown.robot
Library  taf.ul.oam_kpi_calculations  WITH NAME  kpi


*** Variables ***
${DELTA}=  example
${DELTA_RESET}=  ${False}


*** Keywords ***
TC__CM_Delta_Recommissioning_With_KPI_15
  Set Tags  AUTHOR-piotr.korczynski@nokia.com  MAINTAINER-piotr.korczynski@nokia.com
  Common Test Setup
  Logging With Timestamp
  ...  message=CM_Delta_Recommissioning_With_KPI_15.robot for every node on list : @{CFG.active_bts_list} will be executed
  ...  style=ONGOING
  FOR  ${bts_id}  IN  @{CFG.active_bts_list}
    Precondition For Delta_Recommissioning_With_KPI_15  ${bts_id}
    Step 1 Perform Delta File Commissioning  ${DELTA_SCF_FILE}
    Step 2 Verify BTS State
    Step 3 Verify Alarms
    Step 4 Calculate KPI 15
    Postcondition For Delta_Recommissioning_With_KPI_15
  END
  [Teardown]  Common Test Teardown

Precondition For Delta_Recommissioning_With_KPI_15
  [Arguments]  ${bts_id}
  ${bts_alias_type}=  Get From Dictionary  ${CFG.NODES['${bts_id}']}  bts_alias_type
  ${bts_ip_address}=  Get From Dictionary  ${CFG.NODES['${bts_id}']}  bts_ip_address
  IF  '${bts_alias_type}' == 'localhost'
    Logging Additional Admin Session Start
    ...  logs_dir_path=${TEST_LOGS_PATH}/BTSFiles/${bts_id}/
    ...  connection=kpi15
    ...  bts_id=${bts_id}
  ELSE IF  '${bts_ip_address}'=='${EMPTY}'
    Logging Additional Admin Session Start
    ...  logs_dir_path=${TEST_LOGS_PATH}/BTSFiles/${bts_id}/
    ...  connection=kpi15
    ...  bts_id=${bts_id}
    ...  host_ip=${CFG.NODES['${bts_id}']['vm_ip_LMP_address']}
  END
  ${delta_scf_file}=  Delta Recommissioning Define JSON File Path  ${bts_id}  ${DELTA}
  Set Test Variable  ${DELTA_SCF_FILE}  ${delta_scf_file}
  Set Test Variable  ${BTS_ID}  ${bts_id}
  [Return]  ${DELTA_SCF_FILE}

Postcondition For Delta_Recommissioning_With_KPI_15
  Logging With Timestamp
  ...  message=Postcondition For Delta_Recommissioning_With_KPI_15 started.
  ...  style=STEP
  ...  frame=${TRUE}
  CM Perform Template File Commissioning
  ...  bts_id=${BTS_ID}
  ...  recommissioning_scf_file_path=${CFG.NODES['${BTS_ID}']['scf_file_path']}
  ...  ignore_errors=${True}
  Run Keyword And Ignore Error  CM BTS Admin Not Available  ${BTS_ID}
  Wait Until Keyword Succeeds  ${CONFIGURATION_STARTUP_TIMEOUT}  30sec  STATE Verify BTS states
  ...  node_id=${BTS_ID}
  ...  expected_BTS_status=OnAir
  ...  HW_check=${TRUE}
  ...  cells_check=${TRUE}
  ...  scf_check=${FALSE}
  ...  timeout=${CONFIGURATION_STARTUP_TIMEOUT}
  Logging With Timestamp
  ...  message=Postcondition For Delta_Recommissioning_With_KPI_15 finished, additional admin session started.
  ...  style=DONE

Step 1 Perform Delta File Commissioning
  [Arguments]  ${delta_scf_file}
  Logging With Timestamp
  ...  message=Step 1 Perform Delta File Commissioning
  ...  style=STEP
  ...  frame=${TRUE}
  Logging With Timestamp
  ...  message=BTS Delta commissioning procedure on bts_id node=${BTS_ID} started, Source File = ${DELTA_SCF_FILE}.
  ...  style=ONGOING
  ${result}=  CM Perform Delta File Commissioning  ${BTS_ID}  ${DELTA_SCF_FILE}

Delta Recommissioning Define JSON File Path
  [Arguments]  ${bts_id}  ${delta_file_name}
  ${testsuite_name}=  Fetch From Right
  ...  string=${SUITE_SOURCE}
  ...  marker=/
  ${delta_scf_file}=  Replace String Using Regexp
  ...  string=${SUITE_SOURCE}
  ...  pattern=${testsuite_name}
  ...  replace_with=delta_${bts_id}_${delta_file_name}.json
  ${file_status}=  OperatingSystem.File Should Exist
  ...  path=${delta_scf_file}
  [Teardown]  Run Keyword If  '${file_status}'=='${False}'  Fail
  [Return]  ${delta_scf_file}

Step 2 Verify BTS State
  Logging With Timestamp
  ...  message=Step 2 Verify BTS State
  ...  style=STEP
  ...  frame=${TRUE}
  Wait Until Keyword Succeeds  ${CONFIGURATION_STARTUP_TIMEOUT}  30sec  STATE Verify BTS states
  ...  node_id=${BTS_ID}
  ...  expected_BTS_status=OnAir
  ...  HW_check=${TRUE}
  ...  cells_check=${TRUE}
  ...  scf_check=${FALSE}
  ...  timeout=${CONFIGURATION_STARTUP_TIMEOUT}
  Logging With Timestamp
  ...  message=Step 2 Verify BTS State finished.
  ...  style=DONE

Step 3 Verify Alarms
  Logging With Timestamp
  ...  message=Step 3 Verify Alarms
  ...  style=STEP
  ...  frame=${TRUE}
  Run Keyword And Continue On Failure  FM Check Unexpected And Historical Faults  node_id=${BTS_ID}
  Logging With Timestamp
  ...  message=Step 3 Verify Alarms finished.
  ...  style=DONE

Step 4 Calculate KPI 15
  Logging With Timestamp
  ...  message=Step 4 Calculate KPI 15
  ...  style=STEP
  ...  frame=${TRUE}
  Run Keyword And Continue On Failure
  ...  admin.Collect Infomodel Log From Current Session
  ...  target_file_name=${TEST_LOGS_PATH}BTSFiles/${BTS_ID}/kpi15_infomodel.ims2
  ...  timeout=120
  ...  connection=${BTS_ID}
  Logging With Timestamp
  ...  message=Infomodel session for kpi calculation saved under this path: ${TEST_LOGS_PATH}BTSFiles/${BTS_ID}/
  Logging With Timestamp
  ...  message=KPI calculation start.
  ...  style=ONGOING
  kpi.Clear Results
  @{kpi15}=  Run Keyword And Continue On Failure  kpi.Calculate Kpi 15
  ...  ims_file_path=${TEST_LOGS_PATH}BTSFiles/${BTS_ID}/kpi15_infomodel.ims2
  ${kpi15}=  kpi.Get All Deltas  kpi_name=kpi15
  Logging With Timestamp
  ...  message=KPI15 value is : ${kpi15}
  Logging With Timestamp
  ...  message=Step 4 Calculate KPI 15
  ...  style=DONE
  [Teardown]  Run Keyword And Continue On Failure  admin.Teardown  connection=kpi15
