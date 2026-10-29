*** Settings ***
Documentation
...  AUTHOR-piotr.korczynski@nokia.com  MAINTAINER-piotr.korczynskia@nokia.com
...  [CASE LINK]: https://rep-portal.ext.net.nokia.com/details/qc-case/3959440/
...
...  *****************
...  Basic information
...  *****************
...
...  Step 1 Site reset
...  Site reset procedure is executed without enabled graceful shutdown - dedicated timeout is set.
...
...  Step 2 BTS availability
...  Checking all cells, modules and faults. After that if are incorrect test fail, otherwise test pass.
...  KPI1a, KPI1b, KPI1c are gathered and varificated on user demand
...
...  possible variables available to set by user:
...  'CONFIGURATION_STARTUP_TIMEOUT'  ( seconds )-   startup site reset time defined for tested configuration,
...  if not provided default value from varaibles file will be use, - seconds
...  'CUSTOM_EXPECTED_SITE_RESET_TIME'  ( seconds ) -  expected value for startup kpi1c,
...  if not provided testcase will not use startup value as verdict
...  'CUSTOM_KPI_CALCULATION'  -  (${TRUE} or ${FALSE}) - user can disable kpi calculation
...
...  Disclaimer: Exceptionaly this TC is imported in testcase 'SiSo_STARTUP_Site_Reset_With_Graceful_Shutdown.robot'
...  for reuse purposes. If any corrections needed consider verification in both TCs.
...
...  NOTE. If test used with OBSAI RUs (dual link), fault 1811 Warning can appear. Please adjust accordingly your TS allowed faults.
...
...  ******************
...  History of changes
...  ******************
...  - 07.05.2024 - Initial creation
...  - 16.10.2024 - Correction according Graceful Cell Shutdown - https://jiradc.ext.net.nokia.com/browse/FCA_VRF_SISO-12347
...  - 26.11.2024 - Adding documentation extension regarding fault 1811 - https://jiradc.ext.net.nokia.com/browse/FCA_ST_SISO-48966

*** Variables ***
${CONFIGURATION_STARTUP_TIMEOUT}
#${CUSTOM_EXPECTED_SITE_RESET_TIME}
${CUSTOM_KPI_CALCULATION}=  ${TRUE}

*** Keywords ***

Automated_SiSo_BTS_Startup_Multiple_Site_Reset
    Set Tags  AUTHOR-piotr.korczynski@nokia.com  MAINTAINER-piotr.korczynskia@nokia.com
    Common Test Setup
    Logging With Timestamp
    ...  message=Site Reset TC for every node on list : @{CFG.active_bts_list} will be executed
    ...  style=ONGOING
    FOR  ${bts}  IN  @{CFG.active_bts_list}
      Step 1 Site reset  bts=${bts}  graceful=${FALSE}
      Step 2 BTS availability  bts=${bts}
    END
    [Teardown]  Common Test Teardown

Step 1 Site reset
    [Arguments]  ${bts}  ${graceful}
    Logging With Timestamp
    ...  message=Step 1 Site reset
    ...  style=STEP
    ...  frame=${TRUE}
    Logging With Timestamp
    ...  message=Site Reset for BTS-${bts} will be executed. Graceful Shutdown is ${graceful}. Please wait...
    ...  style=ONGOING
    ${reset_response}=  Run Keyword And Continue On Failure    admin.Reset Site
    ...  connection=${bts}
    ...  wait_for_reconnection=True
    ...  detailed_output=True
    ...  graceful_cell_shutdown=${graceful}
    ...  timeout=${CONFIGURATION_STARTUP_TIMEOUT}
    Logging With Timestamp
    ...  message=Site Reset for BTS-${bts} finished. Graceful Shutdown is ${graceful}. Response from API: ${reset_response}
    ...  style=DONE

Step 2 BTS availability
    [Arguments]  ${bts}
    Logging With Timestamp
    ...  message=Step 2 BTS availability
    ...  style=STEP
    ...  frame=${TRUE}
    Logging With Timestamp
    ...  message=Site state verification after Site Reset start.
    ...  style=ONGOING
    CM BTS Admin Not Available
    ...  node=${bts}
    ...  timeout=120
    Run Keyword And Continue On Failure    STATE Verify BTS states
    ...  node_id=${bts}
    ...  expected_BTS_status=OnAir
    ...  HW_check=${TRUE}
    ...  cells_check=${TRUE}
    ...  scf_check=${FALSE}
    ...  timeout=${CONFIGURATION_STARTUP_TIMEOUT}
    Logging With Timestamp
    ...  message=Site state verification after Site Reset finished.
    ...  style=DONE
    Logging With Timestamp
    ...  message=Site faults state verification after Site Reset start.
    ...  style=ONGOING
    FM Check Unexpected And Historical Faults
    ...  node_id=${bts}
    ...  delay=0
    Logging With Timestamp
    ...  message=Site faults verification after Site Reset finished.
    ...  style=DONE
    Return From Keyword If  not ${CUSTOM_KPI_CALCULATION}
    Logging With Timestamp
    ...  message=KPI calculation start.
    ...  style=ONGOING
    admin.Collect Infomodel Log From Current Session
    ...  connection=${bts}
    ...  target_file_name=${TEST_LOGS_PATH}/BTSFiles/${bts}/ims_kpi.ims2
    ...  timeout=120
    kpi.Clear Results
    Run Keyword And Continue On Failure  kpi.Calculate Kpis
    ...  kpi_names=kpi1a kpi1b kpi1c
    ...  ims_file_path=${TEST_LOGS_PATH}/BTSFiles/${bts}/ims_kpi.ims2
    ${kpi1a}=  kpi.Get All Deltas  kpi_name=kpi1a
    ${kpi1b}=  kpi.Get All Deltas  kpi_name=kpi1b
    ${kpi1c}=  kpi.Get All Deltas  kpi_name=kpi1c
    ${bts_kpi_first_to_last}=  Run Keyword And Continue On Failure  Set Variable  ${kpi1a[0]}
    ${bts_kpi_last_to_first}=  Run Keyword And Continue On Failure  Set Variable  ${kpi1b[0]}
    ${bts_startup_time}=  Run Keyword And Continue On Failure  Set Variable  ${kpi1c[0]}
    ${check_startup_time}=  Run Keyword And Return Status  Should Not Be Empty  ${CUSTOM_EXPECTED_SITE_RESET_TIME}
    ${startup_values_comparison}=  Run Keyword If  ${check_startup_time}  Set Variable If  ${bts_startup_time} > ${CUSTOM_EXPECTED_SITE_RESET_TIME}
    ...  Fail
    ...  Pass
    ${test_verdict_log_level}=  Set Variable If  '${startup_values_comparison}' == 'Fail'  WARN  INFO
    Run Keyword And Continue On Failure  Run Keyword If   "${startup_values_comparison}" == "Fail" and ${check_startup_time}
    ...  Run Keywords
    ...  Logging With Timestamp
    ...  message=Specified startup time ( ${CUSTOM_EXPECTED_SITE_RESET_TIME} seconds) was exceeded. Executed startup time was: ${bts_startup_time}
    ...  style=FAIL
    ...  AND
    ...  Fail  Specified startup time ( ${CUSTOM_EXPECTED_SITE_RESET_TIME} seconds) was exceeded. Executed startup time was: ${bts_startup_time}
    Logging With Timestamp
    ...  message=Time From First Cell Down To Last Cell Up (KPI 1a) = ${bts_kpi_first_to_last}.
    Logging With Timestamp
    ...  message=Time From Last Cell Down To First Cell Up (KPI 1b) = ${bts_kpi_last_to_first}.
    Logging With Timestamp
    ...  message=Site Reset on BTS-${bts} executed with startup time (KPI 1c) = ${bts_startup_time}.
    Run Keyword If  ${check_startup_time}
    ...  Logging With Timestamp    message=Expecterd time set by user = ${CUSTOM_EXPECTED_SITE_RESET_TIME}  level=${test_verdict_log_level}
    ${tmp_it_dict}=    Create Dictionary    &{EMPTY}
    Set To Dictionary    ${tmp_it_dict}
    ...  kpi_1a=${bts_kpi_first_to_last}
    ...  kpi_1b=${bts_kpi_last_to_first}
    ...  kpi_1c=${bts_startup_time}
    ...  verdict=${startup_values_comparison}
    Logging With Timestamp   message=${tmp_it_dict}    console=${FALSE}  output_file=tc_verdicts_report.txt
    Logging With Timestamp
    ...  message=KPI calculation finished.
    ...  style=DONE
