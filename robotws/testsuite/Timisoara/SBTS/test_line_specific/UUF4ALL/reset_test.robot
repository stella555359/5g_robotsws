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


${VIRTUAL_ENV_ACT_CMD}=  source /opt/ute/sran_venv/bin/activate;    # source /home/ute/test_repo/bin/activate;
${TEST_PATH}=  /home/ute/MN/UTE/robotws/testsuite/SBTS/test_line_specific/Timisoara/UUF4ALL    # resources
${TL_CONFIG_PATH_AND_NAME}=  /home/ute/MN/UTE/robotws/testsuite/SBTS/test_line_specific/Timisoara/UUF4ALL/tl_config.py
${DEBUG}=  True
${RESET_PHASE}=  Setup

*** Test Cases ***
Report Reset In Loop
    Start time
    Set Reported Software
    Report To Reporting Portal
            ...  status=failed
            ...  case_type=Reset
            ...  initial_build=${INITIAL_SW_DICT}
            ...  candidate=${CANDIDATE}


*** Keywords ***
