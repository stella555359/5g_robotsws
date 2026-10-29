*** Settings ***
Documentation    uuf rfrl common keywords

Library    Collections
Library    OperatingSystem
Library    Process
Library    String
Library    DateTime
Library    taf.sbts.oam.coam.admin    WITH NAME    admin
Library    ute_syslog
Library    ute_fsmaccess
Library    ute_reporting_portal
Library    taf.ul.alarms_watchdog  WITH NAME  watchdog
Library    taf.ul.oam_kpi_calculations  WITH NAME  kpi
Library    testsuite/Paris/UUF/ST/UUF4All/resources/common.py  WITH NAME  uuf_rfrl_common
Library    taf/rfrl/uuf4all/resources/python/uuf_rfrl_oam_kpi.py  WITH NAME  uuf_rfrl_oam_kpi
Library    taf/rfrl/uuf4all/resources/python/uuf_rfrl_update.py  WITH NAME  update
Library    taf/rfrl/uuf4all/resources/python/uuf_rfrl_utilities.py  WITH NAME  rfrl_utilities
Variables  taf/rfrl/uuf4all/resources/python/uuf_rfrl_variables.py

*** Variables ***
${LOG_PATH}=    ${OUTPUT_DIR}

*** Keywords ***
Start Collecting Syslog
    [Documentation]  Keyword to provide syslog collection.
    [Arguments]  ${test_phase}=${EMPTY}
    Log    Starting Syslog Collection    console=yes
    Start Syslog    log_dir=${LOG_PATH}/${TEST_NAME}/${test_phase}    log_name=syslog.log    ip=192.168.255.126
    ...  alias=local_syslog
    Set Test Variable    ${local_syslog}    ${LOG_PATH}/${TEST_NAME}/${test_phase}/syslog.log
    Run Keyword And Ignore Error  Run Keyword If  "${REMOTE_VM_IP}" != "None"  Start Syslog
    ...  log_dir=${LOG_PATH}/${TEST_NAME}/${test_phase}    log_name=syslog_remote.log    ip=192.168.255.126
    ...  host_ip=${REMOTE_VM_IP}   alias=remote_syslog
    Run Keyword And Ignore Error  Run Keyword If  "${REMOTE_VM_IP}" != "None"
    ...  Set Test Variable    ${remote_syslog}    ${LOG_PATH}/${TEST_NAME}/${test_phase}/syslog_remote.log

Verify Test In Loop
    [Documentation]
    ...   Perform test verification in loop:
    ...   - check bts proper state before test,
    ...   - provide syslog collection,
    ...   - run test, then check for crashes in syslog and get test result,
    ...   - uuf_rfrl_common_keywords.Gather Snapshot if iteration failed,
    ...   - recover hardware if needed,
    ...   - provide report to Reporting portal,
    ...   - get PASS to FAIL ratio.
    [Arguments]    ${iteration_number}  ${should_be_reported}  ${test_keyword}
    @{loop_results}=    Create List
    &{kpis}=    Create Dictionary
    Set Test Variable  ${KPIS}  ${kpis}
    Set Test Variable  ${PASS_ITERATION}  ${0}
    FOR    ${i}    IN RANGE    1    ${iteration_number}+1
         ${disk_space}=  uuf_rfrl_common.Check Free Space
         Set Test Variable  ${i}
         uuf_rfrl_common_keywords.Get Iteration Start Time
         Log    ${\n}Iteration_${i} of ${test_keyword} started : ${START_TIME}    console=yes
         ${iteration_result}    ${error}=    Run Keyword And Ignore Error    ${test_keyword}    test_phase=Loop_${i}
         Run Keyword If  "${iteration_result}"=="FAIL"  Log  Loop_${i} Failed due to Error:${\n}${error}  ERROR  console=yes
         ${test_run_status}=  uuf_rfrl_common.Evaluate Test Run Results  ${iteration_result}
         Append To List    ${loop_results}    ${test_run_status}
         uuf_rfrl_common_keywords.Get Iteration End Time
         Run Keyword If  "${should_be_reported}" == "True"  uuf_rfrl_common_keywords.Report To Reporting Portal  ${test_run_status}
         ${failed_test_qty}=    Count Values in list   ${loop_results}   failed
         uuf_rfrl_common.Tar Logs And Remove  ${LOG_PATH}/${TEST_NAME}/Loop_${i}
         Run Keyword If  "${test_run_status}" == "passed"  uuf_rfrl_common.Store First Passed Logs
            ...  ${LOG_PATH}/${TEST_NAME}/Loop_${i}
         Run Keyword If  "${test_run_status}" == "passed"  uuf_rfrl_common_keywords.Remove Passed Logs
         Run Keyword And Ignore Error  uuf_rfrl_common.Clear Admin Api Logs
         Run Keyword If  "${STOP_FIX}" != "False"  uuf_rfrl_common.Stop And Fix Procedure
         Log    Test Progress ${i}/${iteration_number} Failed test: ${failed_test_qty}    console=yes
         Run Keyword And Ignore Error  Run Keyword If  "${REMOTE_VM_IP}" != "None" and "${test_run_status}" == "passed"
            ...  uuf_rfrl_common.Remove Logs From Remote  ${REMOTE_VM_IP}  ${LOG_PATH}/${TEST_NAME}/Loop_${i}
         ${recover_result}=  uuf_rfrl_common_keywords.Check Before Next Iteration
         Exit For Loop If    "${recover_result}" == "FAIL"
    END
    Run Keyword And Ignore Error  uuf_rfrl_oam_kpi.Log Average Cell Downtime Kpi  ${KPIS}
    uuf_rfrl_common_keywords.Pass Ratio    ${loop_results}
    List Should Not Contain Value    ${loop_results}    failed

Get Blackbox File Before Test
    [Arguments]  ${test_phase}=Loop_${i}  ${remote}=${False}
    ${blackbox_before}=  uuf_rfrl_common.Get Blackbox File  ${LOG_PATH}/${TEST_NAME}/${test_phase}  before_test  ${remote}
    Set Test Variable  ${blackbox_before}

Get Blackbox File After Test
    [Arguments]  ${test_phase}=Loop_${i}  ${remote}=${False}
    ${blackbox_after}=  uuf_rfrl_common.Get Blackbox File  ${LOG_PATH}/${TEST_NAME}/${test_phase}  after_test  ${remote}
    Set Test Variable  ${blackbox_after}

Reset Site Test
    [Documentation]  Keyword to perform site reset test.
    [Arguments]    ${test_phase}=${EMPTY}
    Set Test Variable  ${CELL_DOWNTIME}  ${None}
    Log    Performing Reset Site.    console=yes
    uuf_rfrl_common_keywords.Start Collecting Syslog    test_phase=${test_phase}
    uuf_rfrl_common_keywords.Get Blackbox File Before Test
    uuf_rfrl_common_keywords.Watch Alarms
    admin.Reset site    connection=${LOCAL_ADMIN}
    ${bts_state}  ${bts_error}=  Run Keyword And Ignore Error  uuf_rfrl_common_keywords.Verify BTS State  120  ${test_phase} after test
    uuf_rfrl_common_keywords.Get Blackbox File After Test
    ${logs_results}  ${logs_error}=  Run Keyword And Ignore Error  uuf_rfrl_common_keywords.Verify Logs   ${test_phase} after test
    ${site_reset_ims}=  uuf_rfrl_common.Get IMS From Session  ${test_phase}  site_reset.ims2
    ${attach_result}=  Execute Attach If Included In Test Scope
    ${result}=  uuf_rfrl_common.Verify Iteration  ${test_phase}  ${bts_state}  ${logs_results}  ${attach_result}
    uuf_rfrl_common_keywords.Get Cell Downtime KPI
    Run Keyword If  "${result}" == "False"  uuf_rfrl_common_keywords.Gather Snapshot
    uuf_rfrl_common.Check Stop Fix Trigger
    Run Keyword If  "${result}" == "False"  Fail  Site Reset Failed - ${test_phase}
    Gather Snaphshot For First Passed Iteration  ${test_phase}
    [Teardown]   uuf_rfrl_common_keywords.Stop Logging

Pass Ratio
    [Documentation]  Keyword to return PASS to FAIL ratio of the test.
    [Arguments]    ${results_list}
    ${failed_test_qty}=    Count Values in list    ${results_list}    failed
    ${passed_test_qty}=    Count Values in list    ${results_list}    passed
    Log    Passed Tests: ${passed_test_qty} ${\n}Failed Tests:${failed_test_qty}    console=yes

Recovery Site Reset
    [Documentation]  Keyword to perform recovery site reset.
    [Arguments]    ${test_phase}=Loop_${i}
    uuf_rfrl_common_keywords.Watch Alarms
    uuf_rfrl_common_keywords.Start Collecting Syslog  test_phase=${test_phase}/Recovery_reset
    admin.Reset site    connection=${LOCAL_ADMIN}
    uuf_rfrl_common_keywords.Collect Syslog
    ${bts_state}  ${bts_error}=  Run Keyword And Ignore Error  uuf_rfrl_common_keywords.Verify BTS State  120  recovery
    Run Keyword If  "${bts_state}" == "FAIL"  uuf_rfrl_common_keywords.Gather Snapshot  ${test_phase}/Recovery_reset
    Run Keyword If  "${bts_state}" == "FAIL"  Fail  Recovery Site Reset Failed

Try To Recover bts
    [Documentation]  Keyword to attempt to recover bts by performing multiple recovery site resets.
    Log    Trying to recover bts by reset site action.    console=yes
    ${recovery_result}    ${error}=    Run Keyword And Ignore Error  uuf_rfrl_common_keywords.Recovery Site Reset
    Run Keyword If    "${recovery_result}" == "FAIL"   Log    Recovery failed - Ending test case execution.  console=yes
    [Return]    ${recovery_result}

Get Current Time
    @{time}=    Get Time    hour min sec    NOW
    ${time_now}=    Catenate    SEPARATOR=:    @{time}[0]    @{time}[1]    @{time}[2]
    [Return]    ${time_now}

UUF Site Reset Test Setup
    Log  uuf_rfrl_common_keywords.UUF Site Reset Test Setup  console=true
    ${case_type}=  Convert To String  Reset
    Set Test Variable  ${CASE_TYPE}  ${case_type}
    uuf_rfrl_common_keywords.Watch Alarms
    uuf_rfrl_common_keywords.Start Collecting Syslog  test_phase=Test_Setup
    ${hwf_flag}   uuf_rfrl_common.Get Hwf Flag   connection=${LOCAL_ADMIN}
    uuf_rfrl_common.Add Flag To SWCONFIG  ${hwf_flag}  ${LOG_PATH}/${TEST_NAME}
    admin.Reset site    connection=${LOCAL_ADMIN}
    Log    ${\n}Waiting for bts HW to be fully functional after swconfig modification    console=yes
    ${check_result}  ${error}=  Run Keyword And Ignore Error
    ...   uuf_rfrl_common_keywords.Verify BTS State   120    Test Setup - After SW modification
    uuf_rfrl_common_keywords.Collect Syslog
    Run Keyword If    "${check_result}"=="FAIL"  uuf_rfrl_common_keywords.Gather Snapshot  Test_Setup
    uuf_rfrl_common.Check Stop Fix Trigger
    Run Keyword If    "${check_result}"=="FAIL"  FAIL  Site Reset Test Failed After Setting Flag in SW CONFIG
    [Teardown]  Run Keywords  uuf_rfrl_common_keywords.Stop Logging  AND
    ...  Run Keyword If  "${STOP_FIX}" != "False"  uuf_rfrl_common.Stop And Fix Procedure

Remove Special Characters From Rfrl Testname
    ${test_name}=    Replace String Using Regexp   ${TESTNAME}   ${space}   _
    ${test_name}=    Replace String Using Regexp   ${test_name}   &   _
    ${test_name}=    Remove String   ${test_name}   (
    ${test_name}=    Remove String   ${test_name}   )
    Set Test Variable   ${test_name}

UUF Site Reset Test Teardown
    Log  uuf_rfrl_common_keywords.UUF Site Reset Test Teardown  console=true
    Run Keyword If  "${STOP_FIX}" != "False"  uuf_rfrl_common.Stop And Fix Procedure
    uuf_rfrl_common_keywords.Watch Alarms
    uuf_rfrl_common_keywords.Start Collecting Syslog  test_phase=Test_Teardown
    uuf_rfrl_common.Restore Original SWCONFIG  ${LOG_PATH}/${TEST_NAME}
    admin.Reset site    connection=${LOCAL_ADMIN}
    Log    ${\n}Waiting for bts HW to be fully functional after restoring original swconfig    console=yes
    ${check_result}  ${error}=  Run Keyword And Ignore Error  uuf_rfrl_common_keywords.Verify BTS State   120    Test Teardown
    uuf_rfrl_common_keywords.Collect Syslog
    Run Keyword If    "${check_result}"=="FAIL"  uuf_rfrl_common_keywords.Gather Snapshot  Test_Teardown
    uuf_rfrl_common.Check Stop Fix Trigger
    Run Keyword If    "${check_result}"=="FAIL"  FAIL  Site Reset Teardown Failed After Recovering SW CONFIG
    [Teardown]      Run Keywords  Run Keyword And Ignore Error  admin.Teardown All Aliases For Admin  AND
    ...  Run Keyword And Ignore Error  uuf_rfrl_common_keywords.Stop Logging  AND
    ...      Run Keyword If  "${STOP_FIX}" != "False"  uuf_rfrl_common.Stop And Fix Procedure

Report To Reporting Portal
    [Arguments]  ${status}
    Run Keyword If  "${CASE_TYPE}" == "Reset"  uuf_rfrl_common_keywords.Report To Reporting Portal Reset  ${status}
    ...  ELSE IF  "${CASE_TYPE}" == "Upgrade"   uuf_rfrl_common_keywords.Report To Reporting Portal Upgrade  ${status}

Report To Reporting Portal Reset
    [Documentation]  Keyword send report to reporting portal and return link.
    [Arguments]  ${status}
    ${build}=  Set Variable  ${RESERVED_BUILD}
    ${test_run}=  Convert To String  UUF4ALL_RESET_TEST
    ${ca}=  uuf_rfrl_common.Get Competence Area  ${TEST_TAGS}
    ${testline}=  Convert To String  ${HOSTNAME}
    ${qc_domain}=  Set Variable
    ${qc_project}=  Set Variable
    ${qc_id}=  Set Variable
    &{empty_dict}=  Create Dictionary
    ${comment}=  Convert To String  UUF4ALL_${build}
    ${uuf_test}=  Convert To String  True
    ${BTS_TYPE}=  Convert To String  ${LOCAL_BTS_TYPE}
    ${testline_type}=  Convert To String  ${LABEL}
    ${KPI}=  Convert To String  ${CELL_DOWNTIME}
    ${link_to_reporting_portal}=
    ...  ute_reporting_portal.report to rp
    ...  name=${test_run}
    ...  result=${status}
    ...  ca=${ca}
    ...  testline=${testline}
    ...  build=${RESERVED_BUILD}
    ...  qc_domain=${qc_domain}
    ...  qc_project=${qc_project}
    ...  qc_id=${qc_id}
    ...  comment=${comment}
    ...  uuf_test=${uuf_test}
    ...  label=${testline_type}
    ...  parameter_1=${RESERVED_BUILD}
    ...  reset_downtime=${KPI}
    ...  links=&{empty_dict}
    ...  starttime=${START_TIME}
    ...  endtime=${END_TIME}
    ...  case_type=${CASE_TYPE}
    ...  ru_type=${RU_TYPE}
    ...  sa/nsa_variant=${BTS_TYPE}
    ...  tdd/fdd_variant=${TDD_FDD_VARIANT}
    ...  hw_id=${HW_ID}
    ...  tool=WebEM
    ...  customers=${CUSTOMERS_LIST}

Report To Reporting Portal Upgrade
    [Documentation]  Keyword send report to reporting portal and return link.
    [Arguments]  ${status}
    ${build}=  Set Variable  ${REPORT_SW}
    ${build}=  Convert To String  ${build}
    ${test_run}=  Convert To String  UUF4ALL_UPGRADE_TEST
    ${ca}=  uuf_rfrl_common.Get Competence Area  ${TEST_TAGS}
    ${testline}=  Convert To String  ${HOSTNAME}
    ${qc_domain}=  Set Variable
    ${qc_project}=  Set Variable
    ${qc_id}=  Set Variable
    &{empty_dict}=  Create Dictionary
    ${comment}=  Convert To String  UUF4ALL_${build}
    ${uuf_test}=  Convert To String  True
    ${BTS_TYPE}=  Convert To String  ${LOCAL_BTS_TYPE}
    ${testline_type}=  Convert To String  ${LABEL}
    ${KPI}=  Convert To String  ${CELL_DOWNTIME}
    ${link_to_reporting_portal}=
    ...  ute_reporting_portal.report to rp
    ...  name=${test_run}
    ...  result=${status}
    ...  ca=${ca}
    ...  testline=${testline}
    ...  build=${build}
    ...  qc_domain=${qc_domain}
    ...  qc_project=${qc_project}
    ...  qc_id=${qc_id}
    ...  comment=${comment}
    ...  uuf_test=${uuf_test}
    ...  label=${testline_type}
    ...  parameter_1=${RESERVED_BUILD}
    ...  upgrade_downtime=${KPI}
    ...  links=&{empty_dict}
    ...  starttime=${START_TIME}
    ...  endtime=${END_TIME}
    ...  case_type=${CASE_TYPE}
    ...  ru_type=${RU_TYPE}
    ...  sa/nsa_variant=${BTS_TYPE}
    ...  tdd/fdd_variant=${TDD_FDD_VARIANT}
    ...  hw_id=${HW_ID}
    ...  tool=WebEM
    ...  customers=${CUSTOMERS_LIST}

Get Hostname
    ${rc}  ${hostname_tmp}=  Run And Return Rc And Output  hostname
    ${hostname_tmp}=  Replace String  ${hostname_tmp}  -  _
    ${hostname_tmp}=  Convert To String  ${hostname_tmp}
    ${hostname_part}=  Split String  ${hostname_tmp}  _
    ${hostname_combined}=  Catenate  ${hostname_part[0]}_${hostname_part[1]}_${hostname_part[2]}
    Set Test Variable  ${HOSTNAME}  ${hostname_combined}

Get Label
    ${label_cmd}=  Convert To String  cat /opt/ute/reservation.json | grep -o -P '"topology": (".+")' | awk -F '"' '{print $4}'
    ${label}=  Run process  ${label_cmd}  shell=True  cwd=${CURDIR}
    ${label}=  Convert To String  ${label.stdout}
    Log  ${label}  console=yes
    Set Test Variable  ${LABEL}  ${label}

Gather Snapshot
    [Arguments]  ${test_phase}=Loop_${i}
    Log  Gathering Snapshot from local node  console=yes
    Wait Until Keyword Succeeds   3 times   20   admin.Get Snapshot   ${LOG_PATH}/${TEST_NAME}/${test_phase}/snapshot.zip
    ...  coverage=Full  timeout=2400    connection=${LOCAL_ADMIN}
    Run Keyword And Ignore Error  Run Keyword If  "${REMOTE_VM_IP}" != "None"
    ...  Log  Gathering Snapshot from remote node  console=yes
    Run Keyword And Ignore Error  Run Keyword If  "${REMOTE_VM_IP}" != "None"
    ...  Wait Until Keyword Succeeds   3 times   20   admin.Get Snapshot
    ...  ${LOG_PATH}/${TEST_NAME}/${test_phase}/snapshot_remote_node.zip    coverage=Full  timeout=2400
    ...  connection=remote_admin

Setup Admin Connection
    ${local_admin}=  admin.Setup Admin   alias=local_admin
    Set Test Variable  ${LOCAL_ADMIN}  ${local_admin}
    ${remote_admin}=  Run Keyword If  "${REMOTE_VM_IP}" != "None"
    ...  admin.Setup Admin  remote_host=${REMOTE_VM_IP}   alias=remote_admin
    Run Keyword If  "${REMOTE_VM_IP}" != "None"  Set Test Variable  ${REMOTE_ADMIN}  ${remote_admin}

Collect Syslog
    ute_syslog.Collect Syslog Results    alias=local_syslog
    Run Keyword And Ignore Error  Run Keyword If  "${REMOTE_VM_IP}" != "None"
    ...  ute_syslog.Collect Syslog Results  unzip=True    alias=remote_syslog
    [Teardown]  Run Keyword And Ignore Error  ute_syslog.Teardown All Aliases For Syslog

Remove Passed Logs
    [Arguments]  ${test_phase}=Loop_${i}
    Remove Directory    ${LOG_PATH}/${TEST_NAME}/${test_phase}    recursive=True
    Run Keyword And Ignore Error  Run Keyword If  "${REMOTE_VM_IP}" != "None"
    ...  uuf_rfrl_common.Remove Logs From Remote  ${REMOTE_VM_IP}  ${LOG_PATH}/${TEST_NAME}/${test_phase}

Get Cell Downtime KPI
    [Arguments]  ${test_phase}=Loop_${i}
    ${cell_downtime}=  uuf_rfrl_oam_kpi.Get OAM Kpi For NR Cells  ${local_syslog}
    Set Test Variable  ${CELL_DOWNTIME}  ${cell_downtime}
    uuf_rfrl_oam_kpi.Append Reset KPI  ${cell_downtime}  ${test_phase}  ${KPIS}

Set Test Variables
    [Arguments]  ${custom_alarms}  ${remote_vm_ip}  ${label}  ${hostname}  ${critical_faults}  ${remote_mplane}
    ...   ${use_remote_node}
    Run Keyword If  ${use_remote_node}==${True}  Set Test Variable  ${REMOTE_VM_IP}  ${remote_vm_ip}  ELSE
    ...  Set Test Variable  ${REMOTE_VM_IP}  ${None}
    Run Keyword If  ${use_remote_node}==${True}  Set Test Variable  ${REMOTE_MPLANE}  ${remote_mplane}  ELSE
    ...  Set Test Variable  ${REMOTE_MPLANE}  ${None}
    Set Test Variable  ${LABEL}  ${label}
    Set Test Variable  ${HOSTNAME}  ${hostname}
    Set Test Variable  ${USE_REMOTE_NODE}  ${use_remote_node}
    uuf_rfrl_common.Extend Critical Faults List  ${critical_faults}
    Set Test Variable  ${CRITICAL_FAULT_STATUS_LOCAL}  ${True}
    Set Suite Variable  ${STOP_FIX}  ${False}
    ${tl_check}  ${error}=  Run Keyword And Ignore Error  Variable Should exist  ${tl}
    Run Keyword If  "${REMOTE_VM_IP}"=="${None}" and "${tl_check}"=="PASS" and ${use_remote_node}==${True}
    ...     uuf_rfrl_common_keywords.Setup UTE Test Line Remote VM
    uuf_rfrl_common_keywords.Setup Test Line Watchdog
    ${watchdog_allowed_alarms}=  uuf_rfrl_common.Add Custom Allowed Alarms  ${RFRL_ALLOWED_ALARMS}  ${custom_alarms}
    Set Test Variable  ${WATCHDOG_ALLOWED_ALARMS}  ${watchdog_allowed_alarms}
    Set Test Variable    ${BACKUP_SCF_DIR}    ${LOG_PATH}/${TEST_NAME}/backup_scf.xml
    Run Keyword If  "${REMOTE_VM_IP}"!="${None}" and ${use_remote_node}==${True}
    ...  Set Test Variable  ${CRITICAL_FAULT_STATUS_REMOTE}  ${True}

Set Reporting Portal Variables
    [Arguments]  ${customers_list}
    Run Keyword If  "${LABEL}" == "${None}"   uuf_rfrl_common_keywords.Get Label
    Run Keyword If  "${HOSTNAME}" == "${None}"  uuf_rfrl_common_keywords.Get Hostname
    ${RESERVED_BUILD}=  uuf_rfrl_common.Get Reporting Build  connection=${LOCAL_ADMIN}
    Set Test Variable  ${RESERVED_BUILD}
    ${bts_info}=  admin.Get Bts Info  connection=${LOCAL_ADMIN}
    ${HW_ID}=  uuf_rfrl_common.Get HW ID  ${bts_info}
    Set Test Variable  ${HW_ID}
    ${RU_TYPE}=  uuf_rfrl_common.Get Rmods  ${bts_info}
    ${TDD_FDD_VARIANT}=  uuf_rfrl_common.Get Technology Variant  ${bts_info}
    Set Test Variable  ${RU_TYPE}
    Set Test Variable  ${TDD_FDD_VARIANT}
    Log  List of supported customers: ${RFRL_CUSTOMERS_LIST}
    ${customers_list}=  uuf_rfrl_common.Validate Customers List  ${customers_list}
    Set Test Variable  ${CUSTOMERS_LIST}  ${customers_list}

Setup Test Line Watchdog
    ${local_config}=  uuf_rfrl_common.Create Mocked BTS Config  192.168.255.129
    Set Test Variable  ${LOCAL_CONFIG}  ${local_config}
    ${local_watchdog}=  uuf_rfrl_common.Create Watchdog
    Set Test Variable  ${LOCAL_WATCHDOG}  ${local_watchdog}
    Run Keyword If  "${REMOTE_MPLANE}" != "${None}"  uuf_rfrl_common_keywords.Setup Remote Watchdog

Setup Remote Watchdog
    ${remote_config}=  uuf_rfrl_common.Create Mocked BTS Config  ${REMOTE_MPLANE}
    Set Test Variable  ${REMOTE_CONFIG}  ${remote_config}
    ${remote_watchdog}=  uuf_rfrl_common.Create Watchdog
    Set Test Variable  ${REMOTE_WATCHDOG}  ${remote_watchdog}

Setup UTE Test Line Remote VM
    ${remote_vm_ip}  ${remote_mplane}=  uuf_rfrl_common.Get Remote Object Details
    Set Test Variable  ${REMOTE_VM_IP}  ${remote_vm_ip}
    Set Test Variable  ${REMOTE_MPLANE}  ${remote_mplane}
    uuf_rfrl_common_keywords.Setup Remote Watchdog

Set Initial Modules
    uuf_rfrl_common.Set Initial Modules Variable  remote=False
    Run Keyword And Ignore Error  Run Keyword If  "${REMOTE_VM_IP}" != "None"
    ...  uuf_rfrl_common.Set Initial Modules Variable  remote=True


Common Test Setup
    [Arguments]  ${custom_alarms}  ${remote_vm_ip}  ${label}  ${hostname}  ${critical_faults}  ${should_be_reported}
    ...  ${customers_list}  ${remote_mplane}  ${use_remote_node}
    Log  uuf_rfrl_common_keywords.Common Test Setup  console=true
    uuf_rfrl_common_keywords.Remove Special Characters From Rfrl Testname
    uuf_rfrl_common.Remove Old Logs  ${LOG_PATH}/${TEST_NAME}
    uuf_rfrl_common_keywords.Set Test Variables  ${custom_alarms}  ${remote_vm_ip}
    ...  ${label}  ${hostname}  ${critical_faults}  ${remote_mplane}  ${use_remote_node}
    uuf_rfrl_common_keywords.Setup Admin Connection
    Set Initial Modules
    admin.Collect Im Snapshot  ${LOG_PATH}/${TEST_NAME}/ims_setup.ims2  connection=${LOCAL_ADMIN}
    Run Keyword If  "${should_be_reported}"=="True"
    ...  uuf_rfrl_common_keywords.Set Reporting Portal Variables  ${customers_list}
    uuf_rfrl_common_keywords.Set BTS Type
    Run Keyword And Ignore Error  Run Keyword If  "${REMOTE_VM_IP}" != "None"
    ...  uuf_rfrl_common.Remove Logs From Remote  ${REMOTE_VM_IP}  ${LOG_PATH}/${TEST_NAME}
    uuf_rfrl_common.Get Swconfig  Backup_swconfig  ${LOG_PATH}/${TEST_NAME}
    admin.Get Current SCF File  ${LOG_PATH}/${TEST_NAME}  backup_scf.xml  connection=${LOCAL_ADMIN}  timeout=120
    uuf_rfrl_common.Get Local Mplane From SCF And Set As Test Variable

Set BTS Type
    ${local_bts_type}=  uuf_rfrl_common.Get Bts Type  local_admin
    Set Test Variable    ${LOCAL_BTS_TYPE}          ${local_bts_type}
    ${remote_bts_type}=  Run Keyword If  "${REMOTE_VM_IP}" != "None"  uuf_rfrl_common.Get Bts Type  remote_admin
    Set Test Variable    ${REMOTE_BTS_TYPE}          ${remote_bts_type}


Get Iteration Start Time
    ${start_time}=    uuf_rfrl_common.Get Time Now
    Set Test Variable  ${START_TIME}  ${start_time}

Get Iteration End Time
    ${end_time}=    uuf_rfrl_common.Get Time Now
    Set Test Variable  ${END_TIME}  ${end_time}

Verify BTS State
    [Documentation]
    ...   Keyword to verify if bts is fully setup:
    ...   - run functionality verification desired amount of times,
    ...   - verify hardware state before X2 link is up,
    ...   - verify if NSA is up,
    ...   - verify if unexpected alarms occurred.
    [Arguments]    ${how_many_hw_checks}=6  ${test_phase}=${EMPTY}  ${remote}=${False}
    ${local_bts_state}=  uuf_rfrl_common.Check Bts State  ${how_many_hw_checks}  ${test_phase}  ${remote}

Verify Logs
    [Arguments]  ${test_phase}  ${reset_check}=${True}  ${remote}=${False}
    uuf_rfrl_common_keywords.Collect Syslog
    ${logs_check}=  uuf_rfrl_common.Check Logs For Crashes  ${test_phase}  ${reset_check}  ${remote}

Watch Alarms
    [Arguments]  ${allowed_alarms}=${WATCHDOG_ALLOWED_ALARMS}  ${remote}=${False}
    uuf_rfrl_common.Start Watching Alarms  ${allowed_alarms}  ${remote}

Stop Watching Alarms
    [Arguments]  ${remote}=${False}
    uuf_rfrl_common.Stop Watchdog  ${remote}

Update Rollback Test Setup
    [Arguments]  ${5g_source_sw}  ${5g_target_sw}  ${5g_target_sw_path}  ${4g_source_sw}  ${4g_target_sw}
    ...  ${4g_target_sw_path}  ${use_builds_storage}=${True}  ${remote_node_update}=${False}  ${download_path}=${None}
    ...  ${use_test_packages}=${False}
    Log  Update Rollback Test Setup  console=true
    ${case_type}=  Convert To String  Upgrade
    Run Keyword If  ${use_builds_storage}  update.Mount SW Dir
    Set Test Variable  ${CASE_TYPE}  ${case_type}
    Set Test Variable  ${USE_TEST_PACKAGES}  ${use_test_packages}
    Run Keyword If  "${5g_target_sw}" != "${None}"
    ...  uuf_rfrl_common_keywords.Prepare 5G SW  ${5g_source_sw}  ${5g_target_sw}
    ...  ${5g_target_sw_path}  use_builds_storage=${use_builds_storage}  download_path=${download_path}
    ...  use_test_packages=${USE_TEST_PACKAGES}
    Run Keyword If  "${4g_target_sw}" != "${None}"
    ...  uuf_rfrl_common_keywords.Prepare 4G SW  ${4g_source_sw}  ${4g_target_sw}
    ...   ${4g_target_sw_path}   use_builds_storage=${use_builds_storage}  download_path=${download_path}
    ...  use_test_packages=${USE_TEST_PACKAGES}
    Set Test Variable  ${VALIDATION_COUNTER}  ${0}
    Set Test Variable  ${REMOTE_NODE_UPDATE}  ${remote_node_update}
    ${update_test_variables}=  uuf_rfrl_common.Get Update Variables
    Set Test Variable  ${UPDATE_TEST_VARIABLES}  ${update_test_variables}
    uuf_rfrl_common.Verify Correct Source SW Before Test  ${UPDATE_TEST_VARIABLES["1st_bts"]["source_sw"]}
    ...  ${UPDATE_TEST_VARIABLES["1st_bts"]["remote_node"]}
    Run Keyword If  "${REMOTE_VM_IP}" != "None" and "${REMOTE_NODE_UPDATE}" == "True"
    ...  uuf_rfrl_common.Verify Correct Source SW Before Test
    ...  ${UPDATE_TEST_VARIABLES["2nd_bts"]["source_sw"]}  ${UPDATE_TEST_VARIABLES["2nd_bts"]["remote_node"]}
    &{update_results}=    Create Dictionary
    Set Test Variable  ${UPDATE_RESULTS}  ${update_results}
    uuf_rfrl_common.Set Report SW

Prepare 5G SW
    [Arguments]  ${5g_source_sw}  ${5g_target_sw}  ${5g_target_sw_path}  ${use_builds_storage}  ${download_path}
    ...  ${use_test_packages}
    Set Test Variable    ${5G_SOURCE_SW}  ${5g_source_sw}
    Set Test Variable    ${5G_TARGET_SW}  ${5g_target_sw}
    ${5g_target_sw_path}=    Run Keyword if  "${5g_target_sw_path}"=="${None}"  update.Download Package
    ...   ${5G_TARGET_SW}  use_builds_storage=${use_builds_storage}  download_path=${download_path}
    ...  ELSE  Set Variable  ${5g_target_sw_path}
    Set Test Variable       ${5G_TARGET_SW_PATH}        ${5g_target_sw_path}
    Run Keyword If  ${USE_TEST_PACKAGES}  update.Download Test Packages  5G  ${5G_TARGET_SW}
    ...  use_builds_storage=${use_builds_storage}  download_path=${download_path}


Prepare 4G SW
    [Arguments]  ${4g_source_sw}  ${4g_target_sw}   ${4g_target_sw_path}  ${use_builds_storage}  ${download_path}
    ...  ${use_test_packages}
    Set Test Variable    ${4G_SOURCE_SW}  ${4g_source_sw}
    Set Test Variable    ${4G_TARGET_SW}  ${4g_target_sw}
    ${4g_target_sw_path}=    Run Keyword if  "${4g_target_sw_path}"=="${None}"  update.Download Package
    ...   ${4G_TARGET_SW}  use_builds_storage=${use_builds_storage}  download_path=${download_path}
    ...  ELSE  Set Variable  ${4g_target_sw_path}
    Set Test Variable       ${4G_TARGET_SW_PATH}        ${4g_target_sw_path}
    Run Keyword If  ${USE_TEST_PACKAGES}  update.Download Test Packages  4G  ${4G_TARGET_SW}
    ...  use_builds_storage=${use_builds_storage}  download_path=${download_path}

Software Update
    [Arguments]  ${target_sw}  ${target_sw_path}  ${test_phase}=${EMPTY}  ${remote}=${False}
    uuf_rfrl_common_keywords.Setup Admin Connection
    ${bts}=  uuf_rfrl_common.Get Bts For Operation  ${remote}
    ${pre_validation_result}  ${pre_validation_error}=  Run Keyword And Ignore Error  uuf_rfrl_common.Validate Scf File
    ...  ${BACKUP_SCF_DIR}
    Log  SW Update Part  console=true
    uuf_rfrl_common_keywords.Get Blackbox File Before Test  ${test_phase}/update/${bts}  ${remote}
    uuf_rfrl_common_keywords.Watch Alarms  remote=${remote}
    uuf_rfrl_common_keywords.Start Collecting Syslog    ${test_phase}/update/${bts}
    uuf_rfrl_common.Update Sw  ${target_sw}  ${target_sw_path}  ${remote}
    Wait Until Keyword Succeeds   10m   20  uuf_rfrl_common.Check WebEm Is Down  ${remote}
    uuf_rfrl_common.Verify SW change  ${target_sw}  ${remote}
    ${bts_state}  ${bts_error}=  Run Keyword And Ignore Error
    ...  uuf_rfrl_common_keywords.Verify BTS State  120  ${test_phase} after update  ${remote}
    uuf_rfrl_common_keywords.Get Blackbox File After Test  ${test_phase}/update/${bts}  ${remote}
    ${logs_results}  ${logs_error}=  Run Keyword And Ignore Error
    ...  uuf_rfrl_common_keywords.Verify Logs   ${test_phase} after update  ${False}  ${remote}
    ${validation_result}  ${validation_error}=  Run Keyword And Ignore Error  uuf_rfrl_common.Validate Scf File
    ${attach_result}=  Execute Attach If Included In Test Scope  remote=${remote}
    ${result}=  uuf_rfrl_common.Verify Iteration  ${test_phase}  ${bts_state}  ${logs_results}  ${validation_result}
    ...  ${attach_result}
    Run Keyword If  ${remote}==${False}  uuf_rfrl_common_keywords.Get Cell Downtime KPI
    Run Keyword If  "${result}" == "False"  uuf_rfrl_common_keywords.Gather Snapshot  ${test_phase}/update/${bts}
    uuf_rfrl_common.Update Results  result=${result}  operation=Update
    uuf_rfrl_common.Check Stop Fix Trigger
    Run Keyword If  "${result}" == "False"  Fail
    Gather Snaphshot For First Passed Iteration      ${test_phase}/update/${bts}
    [Teardown]  Run Keywords   uuf_rfrl_common_keywords.Stop Logging  ${remote}  AND
    ...                 Run Keyword And Ignore Error  admin.Teardown All Aliases For Admin  AND
    ...                 Run Keyword If  "${STOP_FIX}" != "False"  uuf_rfrl_common.Stop And Fix Procedure


Software Rollback
    [Arguments]    ${source_sw}  ${test_phase}=${EMPTY}  ${remote}=${False}  ${recovery}=${EMPTY}
    Run Keyword And Ignore Error  admin.Teardown All Aliases For Admin
    ${recovery}=  Set Variable If  "${recovery}"=="True"  Recovery_  ${EMPTY}
    ${bts}=  uuf_rfrl_common.Get Bts For Operation  ${remote}
    uuf_rfrl_common_keywords.Setup Admin Connection
    Log  SW Rollback Part  console=true
    uuf_rfrl_common_keywords.Get Blackbox File Before Test  ${test_phase}/${recovery}rollback/${bts}  ${remote}
    uuf_rfrl_common_keywords.Watch Alarms  remote=${remote}
    uuf_rfrl_common_keywords.Start Collecting Syslog    ${test_phase}/${recovery}rollback/${bts}
    uuf_rfrl_common.Rollback Sw  ${remote}
    Wait Until Keyword Succeeds   10m   20  uuf_rfrl_common.Check WebEm Is Down  ${remote}
    uuf_rfrl_common.Verify SW change  ${source_sw}  ${remote}
    ${bts_state}  ${bts_error}=  Run Keyword And Ignore Error
    ...   uuf_rfrl_common_keywords.Verify BTS State  120  ${test_phase} after rollback  ${remote}
    uuf_rfrl_common_keywords.Get Blackbox File After Test  ${test_phase}/${recovery}rollback/${bts}  ${remote}
    ${logs_results}  ${logs_error}=  Run Keyword And Ignore Error
    ...   uuf_rfrl_common_keywords.Verify Logs   ${test_phase} after rollback  ${False}  ${remote}
    ${result}=  uuf_rfrl_common.Verify Iteration  ${test_phase}  ${bts_state}  ${logs_results}
    Run Keyword If  "${result}" == "False"  uuf_rfrl_common_keywords.Gather Snapshot  ${test_phase}/${recovery}rollback/${bts}
    uuf_rfrl_common.Update Results  result=${result}  operation=Rollback
    uuf_rfrl_common.Check Stop Fix Trigger
    Run Keyword If  "${result}" == "False"  Fail
    Gather Snaphshot For First Passed Iteration      ${test_phase}/${recovery}rollback/${bts}
    [Teardown]  Run Keywords  uuf_rfrl_common_keywords.Stop Logging  ${remote}  AND
    ...         Run Keyword If  "${STOP_FIX}" != "False"  uuf_rfrl_common.Stop And Fix Procedure

Upgrade Test
    [Arguments]  ${test_phase}=${EMPTY}
    Set Test Variable  ${CELL_DOWNTIME}  ${None}
    Log  ${UPDATE_TEST_VARIABLES}
    admin.Teardown All Aliases For Admin
    uuf_rfrl_common_keywords.Software Update  ${UPDATE_TEST_VARIABLES["1st_bts"]["target_sw"]}
    ...  ${UPDATE_TEST_VARIABLES["1st_bts"]["target_sw_path"]}  ${test_phase}
    ...  ${UPDATE_TEST_VARIABLES["1st_bts"]["remote_node"]}
    Run Keyword If  "${REMOTE_VM_IP}" != "None" and "${REMOTE_NODE_UPDATE}" == "True"
    ...  uuf_rfrl_common_keywords.Software Update  ${UPDATE_TEST_VARIABLES["2nd_bts"]["target_sw"]}
    ...  ${UPDATE_TEST_VARIABLES["2nd_bts"]["target_sw_path"]}  ${test_phase}
    ...  ${UPDATE_TEST_VARIABLES["2nd_bts"]["remote_node"]}
    uuf_rfrl_common_keywords.Software Rollback  ${UPDATE_TEST_VARIABLES["1st_bts"]["source_sw"]}  ${test_phase}
    ...  ${UPDATE_TEST_VARIABLES["1st_bts"]["remote_node"]}
    Run Keyword If  "${REMOTE_VM_IP}" != "None" and "${REMOTE_NODE_UPDATE}" == "True"
    ...  uuf_rfrl_common_keywords.Software Rollback  ${UPDATE_TEST_VARIABLES["2nd_bts"]["source_sw"]}
    ...  ${test_phase}  ${UPDATE_TEST_VARIABLES["2nd_bts"]["remote_node"]}
    [Teardown]   Run Keyword If  ${USE_TEST_PACKAGES}  uuf_rfrl_common.Update Target SW Variable



Verify SW Version Before Next Iteration
    Run Keyword And Ignore Error  admin.Teardown All Aliases For Admin
    ${node1_sw_change}  ${node1_error}=  Run Keyword And Ignore Error    uuf_rfrl_common.Verify SW change
    ...  ${UPDATE_TEST_VARIABLES["1st_bts"]["source_sw"]}  ${UPDATE_TEST_VARIABLES["1st_bts"]["remote_node"]}
    ${node2_sw_change}  ${node2_error}=  Run Keyword If  "${REMOTE_VM_IP}" != "None" and "${REMOTE_NODE_UPDATE}" == "True"
    ...  Run Keyword And Ignore Error
    ...  uuf_rfrl_common.Verify SW change  ${UPDATE_TEST_VARIABLES["2nd_bts"]["source_sw"]}
    ...  ${UPDATE_TEST_VARIABLES["2nd_bts"]["remote_node"]}
    ${node1_rec_rollback}  ${node1_rec_error}=  Run Keyword If  "${node1_sw_change}" =="FAIL"  Run Keyword And Ignore Error
    ...  uuf_rfrl_common_keywords.Software Rollback   ${UPDATE_TEST_VARIABLES["1st_bts"]["source_sw"]}
    ...  remote=${UPDATE_TEST_VARIABLES["1st_bts"]["remote_node"]}  recovery=True
    ${node2_rec_rollback}  ${node2_rec_error}=  Run Keyword If  "${node2_sw_change}" =="FAIL"  Run Keyword And Ignore Error
    ...  uuf_rfrl_common_keywords.Software Rollback  ${UPDATE_TEST_VARIABLES["2nd_bts"]["source_sw"]}
    ...  remote=${UPDATE_TEST_VARIABLES["2nd_bts"]["remote_node"]}  recovery=True
    Return From keyword if  "${node1_rec_rollback}" == "FAIL" or "${node2_rec_rollback}" == "FAIL"  FAIL
    [Return]  PASS


Check Before Next iteration
    ${bts_state_result}=  uuf_rfrl_common_keywords.Check BTS State Before Next iteration
    ${sw_check_result}=   Run Keyword If  "${CASE_TYPE}" == "Upgrade"
    ...  uuf_rfrl_common_keywords.Verify SW Version Before Next Iteration
    Return From keyword if  "${bts_state_result}" == "FAIL" or "${sw_check_result}" == "FAIL"  FAIL
    [Return]  PASS


Check BTS State Before Next iteration
    uuf_rfrl_common_keywords.Watch Alarms
    Sleep  10
    ${check_after_test}  ${bts_error}=  Run Keyword And Ignore Error
    ...  uuf_rfrl_common_keywords.Verify BTS State  5  before next iteration
    Run Keyword If  "${check_after_test}" == "FAIL"  uuf_rfrl_common_keywords.Gather Snapshot  Loop_${i}/before_recovery/
    uuf_rfrl_common.Check Stop Fix Trigger
    Run Keyword If  "${STOP_FIX}" != "False"  uuf_rfrl_common.Stop And Fix Procedure
    Run Keyword If    "${check_after_test}" == "FAIL"   Log  Performing Recovery Site Reset  console=yes
    ${recover_result}=    Run Keyword If    "${check_after_test}" == "FAIL"  uuf_rfrl_common_keywords.Try To Recover Bts
    [Return]  ${recover_result}
    [Teardown]   uuf_rfrl_common_keywords.Stop Logging

Restore To Target SW
    Run Keyword If  "${STOP_FIX}" != "False"  uuf_rfrl_common.Stop And Fix Procedure
    Log  uuf_rfrl_common_keywords.Restore To Target SW  console=true
    admin.Teardown All Aliases For Admin
    ${node1_sw_change}  ${node1_error}=  Run Keyword And Ignore Error
    ...  uuf_rfrl_common.Verify SW change  ${INITIAL_UPDATE_VARIABLES["1st_bts"]["target_sw"]}  ${INITIAL_UPDATE_VARIABLES["1st_bts"]["remote_node"]}
    ${node2_sw_change}  ${node2_error}=  Run Keyword If  "${REMOTE_VM_IP}" != "None" and "${REMOTE_NODE_UPDATE}" == "True"
    ...  Run Keyword And Ignore Error
    ...  uuf_rfrl_common.Verify SW change  ${INITIAL_UPDATE_VARIABLES["2nd_bts"]["target_sw"]}  ${INITIAL_UPDATE_VARIABLES["2nd_bts"]["remote_node"]}
    admin.Teardown All Aliases For Admin
    Run Keyword If  '${node1_sw_change}' == 'FAIL'
    ...     uuf_rfrl_common_keywords.Software Update  ${INITIAL_UPDATE_VARIABLES["1st_bts"]["target_sw"]}
    ...  ${INITIAL_UPDATE_VARIABLES["1st_bts"]["target_sw_path"]}  restore_target  ${INITIAL_UPDATE_VARIABLES["1st_bts"]["remote_node"]}
    Run Keyword If  "${REMOTE_VM_IP}" != "None" and "${REMOTE_NODE_UPDATE}" == "True" and '${node2_sw_change}' == 'FAIL'
    ...     uuf_rfrl_common_keywords.Software Update  ${INITIAL_UPDATE_VARIABLES["2nd_bts"]["target_sw"]}
    ...  ${INITIAL_UPDATE_VARIABLES["2nd_bts"]["target_sw_path"]}  restore_target  ${INITIAL_UPDATE_VARIABLES["2nd_bts"]["remote_node"]}

BBMOD Reset Test Setup
    [Arguments]  ${bbmod_id}=${False}
    Set Test Variable  ${CASE_TYPE}  BBMOD_RESET
    @{list_of_bbmods}=  uuf_rfrl_common.Get BBMOD Eligible for Reset  ${LOCAL_ADMIN}
    ${bbmods_iterator}=  uuf_rfrl_common.Load List As Iterator  ${list_of_bbmods}
    Set Test Variable  ${BBMODS_ITERATOR}  ${bbmods_iterator}
    ${bbmod_id}=  Run Keyword If  ${bbmod_id}!=${False}
    ...   uuf_rfrl_common.Get Object Distname  BBMOD  ${bbmod_id}  ${list_of_bbmods}
    Set Test Variable  ${BBMOD_ID}  ${bbmod_id}

Reset BBMOD Test
    [Arguments]  ${bbmod_to_reset}=${BBMOD_ID}  ${test_phase}=${EMPTY}
    Log    Performing Reset BBMOD.    console=yes
    uuf_rfrl_common_keywords.Start Collecting Syslog    ${test_phase}
    uuf_rfrl_common_keywords.Get Blackbox File Before Test
    uuf_rfrl_common_keywords.Watch Alarms
    ${bbmod_to_reset}=  Run Keyword Unless  ${bbmod_to_reset}
    ...   uuf_rfrl_common.Get Object For Operation  ${BBMODS_ITERATOR}
    uuf_rfrl_common.Try Reset Unit  ${bbmod_to_reset}  Warm  timeout=900  admin_connection=${LOCAL_ADMIN}
    ${bts_state}  ${bts_error}=  Run Keyword And Ignore Error
    ...   uuf_rfrl_common_keywords.Verify BTS State  120  ${test_phase} after test
    uuf_rfrl_common_keywords.Get Blackbox File After Test
    ${logs_results}  ${logs_error}=  Run Keyword And Ignore Error
    ...   uuf_rfrl_common_keywords.Verify Logs   ${test_phase} after test  reset_check=${False}
    ${bbmod_reset_ims}=  uuf_rfrl_common.Get IMS From Session  ${test_phase}  bbmod_reset.ims2
    ${dependent_cells}=  uuf_rfrl_common.Get Dependent Cells For Attach Test  ${bbmod_to_reset}
    ${attach_result}=  Execute Attach If Included In Test Scope  ${dependent_cells}
    ${result}=  uuf_rfrl_common.Verify Iteration  ${test_phase}  ${bts_state}  ${logs_results}  ${attach_result}
    Run Keyword And Ignore Error  uuf_rfrl_oam_kpi.Get Oam Kpi BBMOD Reset  Loop ${i}  ${local_syslog}  ${KPIS}
    Run Keyword If  "${result}" == "False"  uuf_rfrl_common_keywords.Gather Snapshot  ${test_phase}
    uuf_rfrl_common.Check Stop Fix Trigger
    Run Keyword If  "${result}" == "False"  Fail
    Gather Snaphshot For First Passed Iteration      ${test_phase}
    [Teardown]   uuf_rfrl_common_keywords.Stop Logging

RMOD Test Setup
    [Arguments]  ${rmod_id}=${False}
    Set Test Variable  ${CASE_TYPE}  RMOD_RESET
    @{list_of_rmods}=  uuf_rfrl_common.Get Rmods Eligible For Reset
    ${rmods_iterator}=  uuf_rfrl_common.Load List As Iterator  ${list_of_rmods}
    Set Test Variable  ${RMODS_ITERATOR}  ${rmods_iterator}
    ${rmod_id}=  Run Keyword If  ${rmod_id}!=${False}  uuf_rfrl_common.Get Object Distname  RMOD  ${rmod_id}
    ...  ${list_of_rmods}
    Set Test Variable  ${RMOD_ID}  ${rmod_id}

Reset RMOD Test
    [Arguments]  ${rmod_to_reset}=${RMOD_ID}  ${test_phase}=${EMPTY}
    Log    Performing Reset RMOD.    console=yes
    uuf_rfrl_common_keywords.Start Collecting Syslog    ${test_phase}
    uuf_rfrl_common_keywords.Get Blackbox File Before Test
    uuf_rfrl_common_keywords.Watch Alarms
    ${rmod_to_reset}=  Run Keyword Unless  ${rmod_to_reset}  uuf_rfrl_common.Get Object For Operation  ${RMODS_ITERATOR}
    uuf_rfrl_common.Try Reset Unit  ${rmod_to_reset}  Soft  timeout=900  admin_connection=${LOCAL_ADMIN}
    ${bts_state}  ${bts_error}=  Run Keyword And Ignore Error
    ...  uuf_rfrl_common_keywords.Verify BTS State  120  ${test_phase} after test
    uuf_rfrl_common_keywords.Get Blackbox File After Test
    ${logs_results}  ${logs_error}=  Run Keyword And Ignore Error
    ...  uuf_rfrl_common_keywords.Verify Logs   ${test_phase} after test  reset_check=${False}
    ${rmod_reset_ims}=  uuf_rfrl_common.Get IMS From Session  ${test_phase}  rmod_reset.ims2
    ${dependent_cells}=  uuf_rfrl_common.Get Dependent Cells For Attach Test  ${rmod_to_reset}
    ${attach_result}=  Execute Attach If Included In Test Scope  ${dependent_cells}
    ${result}=  uuf_rfrl_common.Verify Iteration  ${test_phase}  ${bts_state}  ${logs_results}  ${attach_result}
    Run Keyword And Ignore Error  uuf_rfrl_oam_kpi.Get Oam Kpi RMOD Reset  Loop ${i}  ${local_syslog}  ${KPIS}
    Run Keyword If  "${result}" == "False"  uuf_rfrl_common_keywords.Gather Snapshot  ${test_phase}
    uuf_rfrl_common.Check Stop Fix Trigger
    Run Keyword If  "${result}" == "False"  Fail
    Gather Snaphshot For First Passed Iteration      ${test_phase}
    [Teardown]   uuf_rfrl_common_keywords.Stop Logging

Lock Cells Test Setup
    [Arguments]  ${cell_type}  ${band_no}=${None}
    Set Test Variable  ${CASE_TYPE}  ${cell_type}_LOCK
    Set Test Variable  ${CELL_TYPE}  ${cell_type}
    ${delta_iterator}=  uuf_rfrl_common.Prepare Cell Lock Deltas  ${CELL_TYPE}  ${band_no}
    Set Test Variable  ${DELTA_ITERATOR}  ${delta_iterator}


Lock Cells Test
    [Arguments]  ${test_phase}=${EMPTY}
    Log    Locking band ${BAND_NO}.    console=yes
    uuf_rfrl_common_keywords.Start Collecting Syslog    ${test_phase}/Lock_${CELL_TYPE}
    uuf_rfrl_common_keywords.Get Blackbox File Before Test  ${test_phase}/Lock_${CELL_TYPE}
    uuf_rfrl_common_keywords.Watch Alarms
    admin.Perform Delta Recommissioning  ${LOCK_DELTA}  alias=local_admin
    ${bts_state}  ${bts_error}=  Run Keyword And Ignore Error
    ...   uuf_rfrl_common_keywords.Verify BTS State During Cells Lock  120  ${test_phase} after lock
    uuf_rfrl_common_keywords.Get Blackbox File After Test  ${test_phase}/Lock_${CELL_TYPE}
    ${logs_results}  ${logs_error}=  Run Keyword And Ignore Error  uuf_rfrl_common_keywords.Verify Logs
    ...  ${test_phase} after test  reset_check=${False}
    ${lock_ims}=  uuf_rfrl_common.Get IMS From Session  ${test_phase}  Lock_${CELL_TYPE}/lock.ims2
    ${result}=  uuf_rfrl_common.Verify Iteration  ${test_phase}  ${bts_state}  ${logs_results}
    Run Keyword And Ignore Error  uuf_rfrl_oam_kpi.Get Oam Kpi Cell Lock  Loop ${i}  ${local_syslog}  ${KPIS}
    Run Keyword If  "${result}" == "False"  uuf_rfrl_common_keywords.Gather Snapshot  ${test_phase}/Lock_${CELL_TYPE}
    uuf_rfrl_common.Check Stop Fix Trigger
    Run Keyword If  "${result}" == "False"  Fail  Lock ${CELL_TYPE} Failed - Loop ${i}
    Gather Snaphshot For First Passed Iteration      ${test_phase}/Lock_${CELL_TYPE}
    [Teardown]  Run Keywords  uuf_rfrl_common_keywords.Stop Logging  AND
    ...         Run Keyword If  "${STOP_FIX}" != "False"  uuf_rfrl_common.Stop And Fix Procedure


Unlock Cells Test
    [Arguments]  ${test_phase}=${EMPTY}
    Log    UnLocking band ${BAND_NO}.    console=yes
    uuf_rfrl_common_keywords.Start Collecting Syslog    ${test_phase}/Unlock_${CELL_TYPE}
    uuf_rfrl_common_keywords.Get Blackbox File Before Test  ${test_phase}/Unlock_${CELL_TYPE}
    uuf_rfrl_common_keywords.Watch Alarms
    admin.Perform Delta Recommissioning  ${UNLOCK_DELTA}  alias=local_admin
    ${bts_state}  ${bts_error}=  Run Keyword And Ignore Error  uuf_rfrl_common_keywords.Verify BTS State  120
    ...  ${test_phase} after unlock
    uuf_rfrl_common_keywords.Get Blackbox File After Test  ${test_phase}/Unlock_${CELL_TYPE}
    ${logs_results}  ${logs_error}=  Run Keyword And Ignore Error  uuf_rfrl_common_keywords.Verify Logs
    ...   ${test_phase} after test  reset_check=${False}
    ${unlock_ims}=  uuf_rfrl_common.Get IMS From Session  ${test_phase}  Unlock_${CELL_TYPE}/unlock.ims2
    ${result}=  uuf_rfrl_common.Verify Iteration  ${test_phase}  ${bts_state}  ${logs_results}
    Run Keyword And Ignore Error  uuf_rfrl_oam_kpi.Get Oam Kpi Cell Unlock  Loop ${i}  ${local_syslog}  ${KPIS}
    Run Keyword If  "${result}" == "False"  uuf_rfrl_common_keywords.Gather Snapshot  ${test_phase}/Unlock_${CELL_TYPE}
    uuf_rfrl_common.Check Stop Fix Trigger
    Run Keyword If  "${result}" == "False"  Fail  Unlock ${CELL_TYPE} Failed - Loop ${i}
    Gather Snaphshot For First Passed Iteration  ${test_phase}/Unlock_${CELL_TYPE}
    [Teardown]  Run Keywords  uuf_rfrl_common_keywords.Stop Logging  AND
    ...         Run Keyword If  "${STOP_FIX}" != "False"  uuf_rfrl_common.Stop And Fix Procedure

Lock Unlock Cells Test
    [Arguments]   ${test_phase}=${EMPTY}
    ${band_no}  ${locked_cells}  ${lock_delta}  ${unlock_delta}=  uuf_rfrl_common.Get Delta  ${DELTA_ITERATOR}
    Set Test Variable  ${LOCKED_CELLS}      ${locked_cells}
    Set Test Variable  ${BAND_NO}           ${band_no}
    Set Test Variable  ${LOCK_DELTA}        ${lock_delta}
    Set Test Variable  ${UNLOCK_DELTA}      ${unlock_delta}
    uuf_rfrl_common_keywords.Lock Cells Test    ${test_phase}
    uuf_rfrl_common_keywords.Unlock Cells Test  ${test_phase}
    [Teardown]   Run Keywords  uuf_rfrl_common_keywords.Stop Logging  AND
    ...  Run Keyword If  "${STOP_FIX}" != "False"  uuf_rfrl_common.Stop And Fix Procedure  AND
    ...  Run Keyword And Ignore Error  admin.Perform Delta Recommissioning  ${UNLOCK_DELTA}  alias=local_admin

Get List Of Objects For Given Class
    [Documentation]  Keyword to choose random object from given class E.g. RMOD, BBMOD, NRCEL
    ...              and return this distname of this object
    ...              author: lukasz.klosinski@nokia.com
    [Arguments]     ${object_class}
    ${objects_list}=  admin.get ids for all  ${object_class}  connection=${LOCAL_ADMIN}
    [Return]        ${objects_list}

Verify BTS State During Cells Lock
    [Documentation]
    ...   Keyword to verify if gNB is fully setup:
    ...   - run functionality verification desired amount of times,
    ...   - verify hardware state before X2 link is up,
    ...   - verify if NSA is up,
    ...   - verify if unexpected alarms occurred.
    [Arguments]   ${how_many_hw_checks}=6  ${test_phase}=${EMPTY}  ${remote}=${False}
    ${bts_state}=  uuf_rfrl_common.Check Bts State During Cells Lock  ${CELL_TYPE}  ${LOCKED_CELLS}  ${how_many_hw_checks}
    ...   ${test_phase}  ${remote}


Verify BTS State During Object Block
    [Documentation]
    ...   Keyword to verify if gNB is fully setup:
    ...   - run functionality verification desired amount of times,
    ...   - verify hardware state before X2 link is up,
    ...   - verify if NSA is up,
    ...   - verify if unexpected alarms occurred.
    [Arguments]  ${blocked_object}   ${how_many_hw_checks}=6  ${test_phase}=${EMPTY}  ${remote}=${False}
    ${bts_state}=  uuf_rfrl_common.Check Bts State During Object Block  ${blocked_object}  ${how_many_hw_checks}
    ...   ${test_phase}  ${remote}

Common Test Teardown
    uuf_rfrl_common_keywords.Stop Logging
    Run Keyword And Ignore Error  admin.Teardown All Aliases For Admin


Lock Unlock LNCells Test
    [Arguments]  ${test_phase}=${EMPTY}
    uuf_rfrl_common_keywords.Lock Unlock Cells Test  ${test_phase}

Lock Unlock NRCells Test
    [Arguments]  ${test_phase}=${EMPTY}
    uuf_rfrl_common_keywords.Lock Unlock Cells Test  ${test_phase}

Block Cells Test Setup
    [Arguments]  ${cell_type}
    Set Test Variable  ${CASE_TYPE}  ${cell_type}_BLOCK
    Set Test Variable  ${CELL_TYPE}  ${cell_type}
    Set Test Variable  ${WATCHDOG_ALLOWED_ALARMS}  ${watchdog_allowed_alarms}
    @{list_of_cells}=  uuf_rfrl_common_keywords.Get List Of Objects For Given Class  ${CELL_TYPE}
    ${cells_iterator}=  uuf_rfrl_common.Load List As Iterator  ${list_of_cells}
    Set Test Variable  ${CELLS_ITERATOR}  ${cells_iterator}


Block Cells Test
    [Arguments]   ${test_phase}=${EMPTY}
    uuf_rfrl_common_keywords.Start Collecting Syslog    ${test_phase}/Block
    uuf_rfrl_common_keywords.Get Blackbox File Before Test  ${test_phase}/Block
    uuf_rfrl_common.Add Allowed Alarm  fault_id=49
    uuf_rfrl_common_keywords.Watch Alarms
    uuf_rfrl_common.Try Block Cell  ${CELL_TO_BLOCK}
    ${bts_state}  ${bts_error}=  Run Keyword And Ignore Error
    ...  uuf_rfrl_common_keywords.Verify BTS State During Object Block  ${CELL_TO_BLOCK}  120  ${test_phase} after block
    uuf_rfrl_common_keywords.Get Blackbox File After Test  ${test_phase}/Block
    ${logs_results}  ${logs_error}=  Run Keyword And Ignore Error  uuf_rfrl_common_keywords.Verify Logs
    ...   ${test_phase} after test  reset_check=${False}

    ${result}=  uuf_rfrl_common.Verify Iteration  ${test_phase}  ${bts_state}  ${logs_results}
    ${block_ims}=  uuf_rfrl_common.Get IMS From Session  ${test_phase}/Block  cell_block.ims2
    Run Keyword And Ignore Error  uuf_rfrl_oam_kpi.Get Oam Kpi Cell Block  Loop ${i}  ${local_syslog}  ${KPIS}
    Run Keyword If  "${result}" == "False"  uuf_rfrl_common_keywords.Gather Snapshot  ${test_phase}/Block
    uuf_rfrl_common.Check Stop Fix Trigger
    Run Keyword If  "${result}" == "False"  Fail  Block ${CELL_TO_BLOCK} Failed - Loop ${i}
    Gather Snaphshot For First Passed Iteration  ${test_phase}/Block
    [Teardown]   Run Keywords  uuf_rfrl_common_keywords.Stop Logging  AND
    ...  Run Keyword If  "${STOP_FIX}" != "False"  uuf_rfrl_common.Stop And Fix Procedure

Unblock Cells Test
    [Arguments]   ${test_phase}=${EMPTY}
    uuf_rfrl_common_keywords.Start Collecting Syslog    ${test_phase}/Unblock
    uuf_rfrl_common_keywords.Get Blackbox File Before Test  ${test_phase}/Unblock
    uuf_rfrl_common.Add Allowed Alarm  fault_id=49
    uuf_rfrl_common_keywords.Watch Alarms
    uuf_rfrl_common.Try Unblock Cell  ${CELL_TO_BLOCK}
    ${bts_state}  ${bts_error}=  Run Keyword And Ignore Error
    ...   uuf_rfrl_common_keywords.Verify BTS State  120  ${test_phase} after unblock
    uuf_rfrl_common_keywords.Get Blackbox File After Test  ${test_phase}/Unblock
    ${logs_results}  ${logs_error}=  Run Keyword And Ignore Error  uuf_rfrl_common_keywords.Verify Logs
    ...   ${test_phase} after test  reset_check=${False}
    ${unblock_ims}=  uuf_rfrl_common.Get IMS From Session  ${test_phase}/Unblock  cell_unblock.ims2
    ${result}=  uuf_rfrl_common.Verify Iteration  ${test_phase}  ${bts_state}  ${logs_results}
    Run Keyword And Ignore Error  uuf_rfrl_oam_kpi.Get Oam Kpi Cell Unblock  Loop ${i}  ${local_syslog}  ${KPIS}
    Run Keyword If  "${result}" == "False"  uuf_rfrl_common_keywords.Gather Snapshot  ${test_phase}/Unblock
    uuf_rfrl_common.Check Stop Fix Trigger
    Run Keyword If  "${result}" == "False"  Fail  Unblock ${CELL_TO_BLOCK} Failed - Loop ${i}
    Gather Snaphshot For First Passed Iteration  ${test_phase}/Unblock
    [Teardown]   Run Keywords  uuf_rfrl_common_keywords.Stop Logging  AND
    ...  Run Keyword If  "${STOP_FIX}" != "False"  uuf_rfrl_common.Stop And Fix Procedure


Block Unblock Cells Test
    [Arguments]   ${test_phase}=${EMPTY}
    ${cell_to_block}=  uuf_rfrl_common.Get Object For Operation  ${CELLS_ITERATOR}
    Set Test Variable  ${CELL_TO_BLOCK}  ${cell_to_block}
    uuf_rfrl_common_keywords.Block Cells Test    ${test_phase}
    uuf_rfrl_common_keywords.Unblock Cells Test  ${test_phase}
    uuf_rfrl_common.Check Stop Fix Trigger
    [Teardown]   Run Keywords  uuf_rfrl_common_keywords.Stop Logging  AND
    ...  Run Keyword If  "${STOP_FIX}" != "False"  uuf_rfrl_common.Stop And Fix Procedure  AND
    ...  Run Keyword and Ignore Error  uuf_rfrl_common.Try Unblock Cell  ${CELL_TO_BLOCK}  True


Stop Logging
    [Arguments]  ${remote}=${False}
    Run Keyword And Ignore Error  Teardown All Aliases For Syslog
    Run Keyword And Ignore Error  uuf_rfrl_common_keywords.Stop Watching Alarms  ${remote}

Gather Snaphshot For First Passed Iteration
    [Arguments]  ${test_phase}
    Run Keyword if  ${PASS_ITERATION}==${0}    Run Keywords   uuf_rfrl_common_keywords.Gather Snapshot  ${test_phase}  AND
    ...   Set Test Variable  ${PASS_ITERATION}  ${1}

Delta Commissioning Test
    [Arguments]  ${bts_reset}=${False}  ${test_phase}=${EMPTY}
    Log    Performing Delta Commissioning.    console=yes
    uuf_rfrl_common_keywords.Start Collecting Syslog    ${test_phase}
    uuf_rfrl_common_keywords.Get Blackbox File Before Test  ${test_phase}
    uuf_rfrl_common_keywords.Watch Alarms
    admin.Perform Delta Recommissioning  ${DELTA}    alias=local_admin
    ${rat_reset_check}  ${rat_reset_error}=  Run Keyword If  "${RAT_TO_RESET}" != "None"  Run Keyword And Ignore Error
    ...   uuf_rfrl_common.Verify Given Rat Reset  ${RAT_TO_RESET}  ELSE  Set Variable  PASS  None
    ${bts_state}  ${bts_error}=  Run Keyword And Ignore Error
    ...   uuf_rfrl_common_keywords.Verify BTS State  120  ${test_phase} after plan activation
    uuf_rfrl_common_keywords.Get Blackbox File After Test  ${test_phase}
    ${logs_results}  ${logs_error}=  Run Keyword And Ignore Error  uuf_rfrl_common_keywords.Verify Logs
    ...  ${test_phase} after test  reset_check=${bts_reset}
    ${result}=  uuf_rfrl_common.Verify Iteration  ${test_phase}  ${bts_state}  ${logs_results}  ${rat_reset_check}
    Run Keyword If  "${result}" == "False"  uuf_rfrl_common_keywords.Gather Snapshot  ${test_phase}
    uuf_rfrl_common.Check Stop Fix Trigger
    Run Keyword If  "${result}" == "False"  Fail  Delta Commissioning Failed - Loop ${i}
    Gather Snaphshot For First Passed Iteration      ${test_phase}
    [Teardown]   uuf_rfrl_common_keywords.Stop Logging


Delta Commissioning Test Teardown
    Run Keyword And Ignore Error  admin.Perform Commissioning  scf_file=${BACKUP_SCF_DIR}  alias=local_admin

Delta Commissioning Test Setup
    [Arguments]  ${delta_json}  ${bts_reset}=${False}  ${rat_to_reset}=${None}
    ${delta_json}=  uuf_rfrl_common.Set Delta  ${delta_json}  bts_reset=${bts_reset}  rat_to_reset=${rat_to_reset}
    Set Test Variable  ${DELTA}  ${delta_json}
    Set Test Variable  ${RAT_TO_RESET}  ${rat_to_reset}
    Set Test Variable  ${CASE_TYPE}  DELTA_COMMISSIONING

Delta Commissioning With Site Reset
    [Arguments]  ${test_phase}=${EMPTY}
    Delta Commissioning Test  bts_reset=${True}  test_phase=${test_phase}
    [Teardown]   Run Keywords  uuf_rfrl_common_keywords.Stop Logging  AND
    ...  Delta Commissioning Teardown  ${test_phase}

Delta Commissioning Without Site Reset
    [Arguments]  ${test_phase}=${EMPTY}
    Delta Commissioning Test  bts_reset=${False}  test_phase=${test_phase}
    [Teardown]   Run Keywords  uuf_rfrl_common_keywords.Stop Logging  AND
    ...  Delta Commissioning Teardown  ${test_phase}

Delta Commissioning With Rat Reset
    [Arguments]  ${test_phase}=${EMPTY}
    Delta Commissioning Test  bts_reset=${False}  test_phase=${test_phase}
    [Teardown]   Run Keywords  uuf_rfrl_common_keywords.Stop Logging  AND
    ...  Delta Commissioning Teardown  ${test_phase}

Delta Commissioning Teardown
    [Arguments]  ${test_phase}=${EMPTY}
    Run Keyword If  "${STOP_FIX}" != "False"  uuf_rfrl_common.Stop And Fix Procedure
    Log  ${\n}Performing Backup Scf Commissioning  console=true
    uuf_rfrl_common_keywords.Start Collecting Syslog    ${test_phase}/teardown
    uuf_rfrl_common_keywords.Get Blackbox File Before Test  ${test_phase}/teardown
    uuf_rfrl_common_keywords.Watch Alarms
    Run Keyword And Ignore Error  admin.Perform Commissioning  scf_file=${BACKUP_SCF_DIR}  alias=local_admin
    ${bts_state}  ${bts_error}=  Run Keyword And Ignore Error
    ...   uuf_rfrl_common_keywords.Verify BTS State  120  ${test_phase} backup scf restore
    uuf_rfrl_common_keywords.Get Blackbox File After Test  ${test_phase}/teardown
    ${logs_results}  ${logs_error}=  Run Keyword And Ignore Error  uuf_rfrl_common_keywords.Verify Logs
    ...  ${test_phase} after test
    ${result}=  uuf_rfrl_common.Verify Iteration  ${test_phase}/teardown  ${bts_state}  ${logs_results}
    Run Keyword If  "${result}" == "False"  uuf_rfrl_common_keywords.Gather Snapshot  ${test_phase}/teardown
    Run Keyword If  "${result}" == "False"  Fatal Error  ${test_phase}/teardown Failed

Perform Attach Test
    [Arguments]  ${cell_used_in_test}=${None}  ${remote}=${False}
    rfrl_utilities.Robot Logger  Checking if Cell OnAir Before Attach Test  info
    ${cell_check}  ${cell_error}=  Run Keyword And Ignore Error  Verify Cells Before Attach Test  ${remote}
    Return From Keyword If  "${cell_check}" != "PASS"  FAIL
    rfrl_utilities.Robot Logger  Executing Provided Attach Test ${ATTACH_TEST_KEYWORD}   info
    ${attach_result}  ${attach_error}=  Run Keyword And Ignore Error  Run Keyword If  ${remote}==${False}
    ...  ${ATTACH_TEST_KEYWORD}  ${cell_used_in_test}  ${remote}  ELSE
    ...  ${REMOTE_NODE_ATTACH_TEST_KEYWORD}  remote=${remote}
    [Return]  ${attach_result}


Attach Test Setup
    [Arguments]  ${attach_test_keyword}  ${remote_node_attach_test_keyword}=${None}
    Set Test Variable  ${ATTACH_TEST_KEYWORD}  ${attach_test_keyword}
    Set Test Variable  ${REMOTE_NODE_ATTACH_TEST_KEYWORD}  ${remote_node_attach_test_keyword}


Execute Attach If Included In Test Scope
    [Arguments]  ${cell_used_in_test}=${None}  ${remote}=${False}
    ${perform_attach}=  uuf_rfrl_common.Evaluate If Attach In Scope
    Run Keyword And Return If  "${perform_attach}" == "True"  Perform Attach Test  ${cell_used_in_test}  ${remote}
    [Return]  ${True}
