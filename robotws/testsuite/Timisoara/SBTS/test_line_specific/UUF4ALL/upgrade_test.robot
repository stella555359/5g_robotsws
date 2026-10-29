*** Settings ***
Documentation
  ...  Upgrade Test UUF4ALL
  ...
  ...  Author Szymon Kramczynski
  ...  szymon.kramczynski@nokia.com
  ...
  ...  Basic upgrade test in loops
  ...   - Check cell status,
  ...   - Check fault list,
  ...   - Check Validation
  ...   - Check Blackbox
  ...   - Check Syslog
  ...   - Check ALD

  ...  Add SW_CONFIG flags on requested nodes
  ...  Collects Syslog, snapshot and IM snapshot from all nodes
  ...  Recovers testline after test fails.

  ...  Can work with LMI boards with SERIAL_CONSOLE_ON=True

Resource  ./resources/robot/keywords.robot


Suite Setup      run keywords
    ...       Set Candidate
    ...  AND  Get Hostname
    ...  AND  Map Variables
#    ...  AND  Get Label
    ...  AND  Get Vm Password
    ...  AND  Get Vm IP
    ...  AND  Generate Random String  string_length=5
    ...  AND  set suite variable  ${log_dir_backup}  ${LOG_DIR}
    ...  AND  set suite variable  ${LOG_DIR}  ${log_dir_backup}/${UUF_RAND}
    ...  AND  run process  mkdir -p ${LOG_DIR}  shell=True


*** Variables ***
${VIRTUAL_ENV_ACT_CMD}=  source /opt/ute/sran_venv/bin/activate;    # source /home/ute/test_repo/bin/activate;
${TEST_PATH}=  /home/ute/MN/UTE/robotws/testsuite/SBTS/test_line_specific/Timisoara/UUF4ALL    # resources
${TL_CONFIG_PATH_AND_NAME}=  /home/ute/MN/UTE/robotws/testsuite/SBTS/test_line_specific/Timisoara/UUF4ALL/tl_config.py
${DEBUG}=  False

*** Test Cases ***

UUF4ALL report Upgrade MultiNode
    Start time
    Get Active Software On Remotes
    Report To Reporting Portal
    ...  status=failed
    ...  case_type=Upgrade
    ...  initial_build=${INITIAL_SW_DICT}
    ...  candidate=${CANDIDATE}


*** Keywords ***


