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
    ...  AND  Run On Nodes  Download Build
        ...  node_list=${PERFORM_UPGRADE}
        ...  variables=--variable CANDIDATE:${CANDIDATE} --variable SW_CACHE:${sw_cache}

Suite Teardown  Run Keyword If Any Tests Failed  Report failed suite

*** Variables ***
${VIRTUAL_ENV_ACT_CMD}=  source /home/ute/test_repo/bin/activate;    # source /home/ute/test_repo/bin/activate;
${TEST_PATH}=  /home/ute/MN/UTE/robotws/testsuite/SBTS/test_line_specific/Timisoara/UUF4ALL    # resources
${TL_CONFIG_PATH_AND_NAME}=  /home/ute/MN/UTE/robotws/testsuite/SBTS/test_line_specific/Timisoara/UUF4ALL/tl_config.py
${DEBUG}=  False

# for upgrade to build from reservation(variable CANDIDATE_SW can be also passed via additional arguments in UTE)
# robot -b /home/ute/debug.log /home/ute/MN/UTE/robotlte/testsuite/WMP/GVe/Wroclaw/SFE/UUF/UUF4ALL/upgrade.robot

# for upgrade to build given in command
# robot --variable CANDIDATE_SW:SBTS00_ENB_9999_220302_000010 -b /home/ute/debug.log
# /home/ute/MN/UTE/robotlte/testsuite/WMP/GVe/Wroclaw/SFE/UUF/UUF4ALL_DEBUG/upgrade.robot
*** Test Cases ***

UUF4ALL Upgrade MultiNode
    [Setup]  Run Keywords
    ...       log to console  ${EMPTY}
    ...  AND  Run On Nodes  Add Swconfig Flags
        ...  variables=--variable NO_HWF:False
        ...  node_list=${ADD_SWCONFIG_FLAGS}

    @{failed_loops}=  create list
    FOR  ${loop_number}  IN RANGE  ${NUMBER_OF_UPGRADE_LOOPS}
      Start time
      run keyword if  ${loop_number}!=0  set suite variable  ${LOG_DIR}  ${log_dir_backup}/${UUF_RAND}
      ${status}=  run keyword and return status  Perform Upgrade Multinode  ${loop_number}
      run keyword unless  ${status}  append to list  ${failed_loops}  LOOP: ${loop_number}_${UUF_RAND} ${KW_FAULT_MESSAGE}
      ${time}   ${time_delta}   time_now
      ${message}=  catenate  SEPARATOR=${SPACE}
       ...  ${time}
       ...  - LOOP: ${loop_number}
       ...  - ${TEST_PHASE}
       ...  - ${KW_FAULT_MESSAGE}
      ${process_command}=   run keyword unless  ${status}
       ...  Run process
         ...  (echo ${message}) >> ${LOG_DIR}/../statistics.txt  shell=True
      Generate Random String  string_length=5
      run keyword if  '${status}'=='False' and ${STOP_TEST_AFTER_FAIL}  fail  Test Failed and STOP_TEST_AFTER_FAIL==True
      ${recover_status}=  run keyword and return status  run keyword if  '${status}'=='False' and ${RECOVER_TESTLINE}
        ...  recover testline after fail  node_list=${PERFORM_UPGRADE}
      run keyword unless  ${recover_status}  fail  Unable to Recover Testline After Fail
      run keyword if  '${status}'=='False' and '${RECOVER_TESTLINE}'=='False'  fail  Test Failed and RECOVER_TESTLINE==False
    END
    Should be empty  ${failed_loops}  Found faild loops: ${failed_loops}
    [Teardown]  run keywords
    ...       Run Keyword If Test Failed  log to console with time  Test Failed On Loops ${failed_loops}
    ...  AND  run keyword if test passed  log to console with time  All Loops PASSED


*** Keywords ***
Perform Upgrade Multinode
    [Arguments]  ${loop_number}
    set suite variable  ${TEST_PHASE}  before_upgrade
    Get Active Software On Remotes

    Wait Until Keyword Succeeds  10m  30s  Run On Nodes  Address Is Pingable
    ...  node_list=${TL_CONFIG}

    Run On Nodes  Downgrade Uboot
    ...  node_list=${UBOOT_DOWNGRADE}

    Run On Nodes  Cancel 6450 If Needed
    ...  node_list=${TL_CONFIG}

    setup ute_syslog on nodes  node_list=${COLLECT_SYSLOG}

    Wait Until Keyword Succeeds  ${CHECK_CELL_COUNT}x  1m  Run On Nodes  Check Cells
    ...  node_list=${CHECK_CELLS}

    Wait Until Keyword Succeeds  ${CHECK_FAULT_COUNT}x  1m  Run On Nodes  Check Faults
    ...  variables=--variable TEST_PHASE:before_upgrade
    ...  node_list=${CHECK_FAULTS}

    Run On Nodes  Get SCF From eNB
    ...  variables=--variable SCOPE:configuration --variable NAME:scf_before_upgrade.xml
    ...  node_list=${PERFORM_UPGRADE}

    Run On Nodes  Download Blackbox File
    ...  variables=--variable FILE_NAME:blackbox_before_upgrade.txt
    ...  node_list=${CHECK_BLACKBOX}

    # save syslog timestamps before upgrade
    &{start_of_upgrade_dict}=  Create Dictionary
    FOR  ${node}  IN  @{CHECK_SYSLOG}
      log to console with time  savepoint from node:${node}
      ${start_of_upgrade}=  ute_syslog.Capture Savepoint    alias=syslog_node_${node}
      ${node_as_string}=  convert to string  ${node}
      Set To Dictionary   ${start_of_upgrade_dict}    ${node_as_string}=${start_of_upgrade}
    END
    set suite variable  ${START_OF_UPGRADE}  ${start_of_upgrade_dict}

#    ============================================   UPGRADE  ===========================================
    set suite variable  ${TEST_PHASE}  during_upgrade
    Run On Nodes  Admin Upgrade
    ...  variables=--variable CANDIDATE:${CANDIDATE} --variable WAIT_FOR_UNAVAILABLE:${True}
    ...  node_list=${PERFORM_UPGRADE}
    set suite variable  ${TEST_PHASE}  after_upgrade

    Wait Until Keyword Succeeds  10m  30s  Run On Nodes  Address Is Pingable  node_list=${TL_CONFIG}

#   =============================================  AFTER  UPGRADE  =====================================
    Wait Until Keyword Succeeds  ${CHECK_CELL_COUNT}x  1m  Run On Nodes  Check Cells
    ...  node_list=${CHECK_CELLS}

    Wait Until Keyword Succeeds  ${CHECK_FAULT_COUNT}x  1m  Run On Nodes  Check Faults
    ...  variables=--variable TEST_PHASE:after_upgrade
    ...  node_list=${CHECK_FAULTS}

    # dorobic porownywarke scfow po upgradzie
    Run On Nodes  Get SCF From eNB
    ...  variables=--variable SCOPE:configuration --variable NAME:scf_after_upgrade.xml
    ...  node_list=${PERFORM_UPGRADE}

    Wait Until Keyword Succeeds  20x  1m  Run On Nodes  Check ALD
    ...  node_list=${CHECK_ALD}

    Run On Nodes  Check Validation
    ...  node_list=${CHECK_VALIDATION}

    Run On Nodes  Download Blackbox File
    ...  variables=--variable FILE_NAME:blackbox_after_upgrade.txt
    ...  node_list=${CHECK_BLACKBOX}

    Run On Nodes  Check Blackbox
    ...  variables=--variable NAME_BEFORE:blackbox_before_upgrade.txt --variable NAME_AFTER:blackbox_after_upgrade.txt
    ...  node_list=${CHECK_BLACKBOX}

    Check Syslog

    # for report purpose
    run keyword and ignore error  Count Downtime

    set suite variable  ${TEST_PHASE}  during_rollback
#   =============================================  ROLLBACK  =====================================
    Run On Nodes  Rollback
    ...  variables=--variable CANDIDATE:${CANDIDATE}
    ...  node_list=${PERFORM_ROLLBACK}
    set suite variable  ${TEST_PHASE}  after_rollback
#   =============================================  AFTER  ROLLBACK  =====================================
    Wait Until Keyword Succeeds  ${CHECK_CELL_COUNT}x  1m  Run On Nodes   Check Cells
    ...  node_list=${CHECK_CELLS}

    Wait Until Keyword Succeeds  ${CHECK_FAULT_COUNT}x  1m  Run On Nodes  Check Faults
    ...  variables=--variable TEST_PHASE:before_upgrade
    ...  node_list=${CHECK_FAULTS}

    [Teardown]  run keywords
    ...       run Keyword If  '${KEYWORD STATUS}'=='FAIL' and ${SAVE_LOGS_AFTER_TEST_FAIL}
        ...  run keyword and ignore error  Log Collector
    ...  AND  run Keyword If  '${KEYWORD STATUS}'=='PASS' and ${SAVE_LOGS_AFTER_TEST_PASS}
        ...  run keyword and ignore error  Log Collector
    ...  AND  run Keyword If  ${REPORT['RP_REPORT']} and '${KEYWORD STATUS}'=='FAIL'
        ...  run keyword and ignore error  Report To Reporting Portal
            ...  status=failed
            ...  case_type=Upgrade
            ...  initial_build=${INITIAL_SW_DICT}
            ...  candidate=${CANDIDATE}
            ...  loop_number=${loop_number}
    ...  AND  run Keyword If  ${REPORT['RP_REPORT']} and '${KEYWORD STATUS}'=='PASS'
        ...  run keyword and ignore error  Report To Reporting Portal
            ...  status=passed
            ...  case_type=Upgrade
            ...  initial_build=${INITIAL_SW_DICT}
            ...  candidate=${CANDIDATE}
            ...  loop_number=${loop_number}
    ...  AND  run keyword and ignore error  Teardown All Aliases For Syslog
    ...  AND  run keyword and ignore error
        ...  run Keyword If  '${KEYWORD STATUS}'=='PASS' and '${SAVE_LOGS_AFTER_TEST_PASS}'=='False'
            ...  run process  sudo rm -rfv ${LOG_DIR}  shell=True

Report failed suite
    Set Reported Software
	run Keyword If  ${REPORT['RP_REPORT']}
        ...  run keyword and ignore error  Report To Reporting Portal
            ...  status=failed
            ...  case_type=Reset
            ...  initial_build=${INITIAL_SW_DICT}
            ...  candidate=${CANDIDATE}
            ...  loop_number=suite
