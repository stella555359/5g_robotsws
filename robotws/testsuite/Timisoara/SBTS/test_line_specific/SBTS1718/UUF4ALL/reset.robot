*** Settings ***
Documentation
  ...  Testline Reset Test UUF4ALL
  ...
  ...  Author Szymon Kramczynski
  ...  szymon.kramczynski@nokia.com
  ...
  ...  Basic reset test in loops
  ...  Check cell status, fault list, ALD status and syslog messages in every iteration.
  ...  Gathers syslog, snapshot and IM log after fail
  ...  Recovers testline after test fails.


Library  Collections
Library  DateTime
Library  OperatingSystem
Library  Process
Library  String
Library  ute_fsmaccess
Library  ute_reporting_portal
Library  ute_syslog
Resource  ./resources/robot/keywords.robot

Suite Setup      run keywords
    ...       Set Candidate
    ...  AND  Get Hostname
    ...  AND  Map Variables
    ...  AND  Get Vm Password
    ...  AND  Get Vm IP
    ...  AND  Generate Random String  string_length=5
    ...  AND  set suite variable  ${log_dir_backup}  ${LOG_DIR}
    ...  AND  set suite variable  ${LOG_DIR}  ${log_dir_backup}/${UUF_RAND}
    ...  AND  run process  mkdir -p ${LOG_DIR}  shell=True
#    ...  AND  Run On Nodes  Download Build
#        ...  node_list=${PERFORM_UPGRADE}
#        ...  variables=--variable CANDIDATE:${CANDIDATE} --variable SW_CACHE:${sw_cache}

*** Variables ***


${VIRTUAL_ENV_ACT_CMD}=  source /opt/ute/sran_venv/bin/activate;    # source /home/ute/test_repo/bin/activate;  ; must be added
${TEST_PATH}=  /home/ute/MN/UTE/robotws/testsuite/SBTS/test_line_specific/Timisoara/SBTS1718/UUF4ALL    # resources
${TL_CONFIG_PATH_AND_NAME}=  /home/ute/MN/UTE/robotws/testsuite/SBTS/test_line_specific/Timisoara/SBTS1718/UUF4ALL/tl_config.py
${DEBUG}=  True
${RESET_PHASE}=  Setup

*** Test Cases ***
#    run test with command
#    robot /home/ute/MN/UTE/robotlte/testsuite/WMP/GVe/Wroclaw/SFE/UUF/UUF4ALL_DEBUG/RESET.robot

#    link to report (there can be deley due to RP parsing reports (~ 1h max)
#    https://rep-portal.wroclaw.nsn-rdnet.net/reports/uuf

Reset In Loop
    [Setup]  Run Keywords
    ...       log to console  ${EMPTY}
    ...  AND  Run On Nodes  Add Swconfig Flags
        ...  variables=--variable NO_HWF:True
        ...  node_list=${PERFORM_RESET}


    Recover Testline After Fail
    ...  node_list=${PERFORM_RESET}

    @{failed_loops}=  create list
    : FOR  ${loop_number}  IN RANGE  0  ${NUMBER_OF_LOOPS}
    \  Log to console with time  ----------------------- RESET ${loop_number+1}-----------------------
    \  set suite variable  ${RESET_PHASE}  Before_Reset
    \  Start time
    \  run keyword if  ${loop_number}!=0  set suite variable  ${LOG_DIR}  ${log_dir_backup}/${UUF_RAND}
    \  ${status}=  run keyword and return status  Perform Reset  ${CANDIDATE}
    \  run keyword unless  ${status}  append to list  ${failed_loops}  LOOP: ${loop_number}_${UUF_RAND} ${KW_FAULT_MESSAGE}
    \  ${message}=  catenate  SEPARATOR=${SPACE}
        ...  - LOOP: ${loop_number}
        ...  - RESET_PHASE:${RESET_PHASE}
        ...  - ${KW_FAULT_MESSAGE}
    \  ${process_command}=   run keyword unless  ${status}
    ...  Run process
        ...  (echo ${message}) >> ${LOG_DIR}/../statistics.txt  shell=True
    \  Generate Random String  string_length=5
    should be empty  ${failed_loops}  Found faild loops: ${failed_loops}
    [Teardown]  Run Keyword
    ...  Run Keyword If Test Failed
        ...  run keyword if  ${RECOVER_TESTLINE}
             ...  Recover Testline After Fail
                  ...  node_list=${PERFORM_RESET}



*** Keywords ***
Perform Reset
    [Arguments]  ${initial_build}
    setup ute_syslog on nodes
    ...  node_list=${COLLECT_SYSLOG}

    Get Active Software On Remotes

    # save syslog timestamps before upgrade
    &{start_of_reset_dict}=  Create Dictionary
    :FOR  ${node}  IN  @{CHECK_SYSLOG}
    \  log to console with time  savepoint from node:${node}
    \  ${start_of_reset}=  ute_syslog.Capture Savepoint    alias=syslog_node_${node}
    \  ${node_as_string}=  convert to string  ${node}
    \  Set To Dictionary   ${start_of_reset_dict}    ${node_as_string}=${start_of_reset}
    set suite variable  ${START_OF_RESET}  ${start_of_reset_dict}

    Run On Nodes  Reset Testline
    ...  node_list=${PERFORM_RESET}
    set suite variable  ${RESET_PHASE}  After_Reset

    Wait Until Keyword Succeeds  10m  30s  Run On Nodes  Address Is Pingable
    ...  node_list=${TL_CONFIG}

    Wait Until Keyword Succeeds  ${CHECK_CELL_COUNT}x  1m  Run On Nodes  Check Cells
    ...  node_list=${CHECK_CELLS}

    Wait Until Keyword Succeeds  ${CHECK_FAULT_COUNT}x  1m  Run On Nodes  Check Faults
    ...  variables=--variable TEST_PHASE:after_upgrade
    ...  node_list=${CHECK_FAULTS}

    Wait Until Keyword Succeeds  20x  1m  Run On Nodes  Check ALD
    ...  node_list=${CHECK_ALD}

    Check Syslog
    ...  timestamp_dict=${START_OF_RESET}

    Wait Until Keyword Succeeds  5x  1m  Reset time Report

    [Teardown]  run keywords
    ...       run keyword if  '${KEYWORD STATUS}'=='FAIL'  run keyword if  ${SAVE_LOGS_AFTER_TEST_FAIL}  Log Collector
    ...  AND  run keyword if  '${KEYWORD STATUS}'=='PASS'  run keyword if  ${SAVE_LOGS_AFTER_TEST_PASS}  Log Collector
    ...  AND  run keyword and ignore error  admin.Teardown Admin  alias=reset_testline
    ...  AND  run keyword and ignore error  Teardown All Aliases For Syslog
    ...  AND  run Keyword If  ${REPORT['RP_REPORT']} and '${KEYWORD STATUS}'=='FAIL'
        ...  run keyword and ignore error  Report To Reporting Portal
            ...  status=failed
            ...  case_type=Reset
            ...  initial_build=${INITIAL_SW_DICT}
            ...  candidate=${CANDIDATE}
    ...  AND  run Keyword If  ${REPORT['RP_REPORT']} and '${KEYWORD STATUS}'=='PASS'
        ...  run keyword and ignore error  Report To Reporting Portal
            ...  status=passed
            ...  case_type=Reset
            ...  initial_build=${INITIAL_SW_DICT}
            ...  candidate=${CANDIDATE}
    ...  AND  run keyword if  '${KEYWORD STATUS}'=='PASS' and '${SAVE_LOGS_AFTER_TEST_PASS}'=='False'
              ...  Run process  sudo rm -rfv ${LOG_DIR}  shell=True