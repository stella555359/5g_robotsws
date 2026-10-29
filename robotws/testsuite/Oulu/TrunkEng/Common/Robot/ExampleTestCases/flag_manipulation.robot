*** Settings ***
Documentation
...   Author:   Terhi Talvitie
...   Contact:  I_MN_RAN_RD_TV_OTACI_CITCRT1@internal.nsn.com

Library     Collections
Resource    testsuite/Oulu/TrunkEng/Common/Robot/Resources/common_resources.robot
Resource    testsuite/Oulu/TrunkEng/Common/Robot/TestKeywords/flag_manipulation.robot

Suite Setup       Common Suite Setup
Suite Teardown    Common Suite Teardown


Test Setup        Run Keywords  Common Test Setup
...               AND           Start Alarm Listener  ${ALLOWED_ALARMS_FILE}
Test Teardown     Common Test Teardown


*** Variables ***
${WAIT_FOR_CELLS_UP}    300
${REPORT}               ${True}
# Developer access to admin
&{FLAG_VALUE}           0x450027=1
${ADD_FLAG}             ${True}
# to list below you can add prints that will be monitored from syslog, if print is found, it is written to eventlog
@{SYSLOG_LIST}          Detected most recent reset type was    failed to execute
# Path to allowed alarms file
${ALLOWED_ALARMS_FILE}  testsuite/Oulu/TrunkEng/OMKPI/allowed_alarms.txt
${WAIT_CHECKS}          0    # seconds, 0 if no waiting nor printing before post conditions check
# Collect logs variable. Possible values are: On failure/Never/Always
${COLLECT_LOGS}         Never
${TEXT_TO_STEP}         Add flag


*** Test Cases ***
Add flag to swconfig
    [Documentation]  Get swconfig from bts, add/change flag to it and upload it back to bts and give site reset.
    Run Keyword And Continue On Failure  Run Keyword In Loop And Return Pass Rate
        ...    ${WAIT_FOR_CELLS_UP}  ${WAIT_CHECKS}  ${SYSLOG_LIST}  ${FLAG_VALUE}  ${ADD_FLAG}  ${TEXT_TO_STEP}
        ...    name=Add flag to swconfig
        ...    test_case=1
        ...    loops=1
		...    keywords=Change flag to swconfig
        ...    expected_pass_rate=1
        ...    collect_test_logs=${COLLECT_LOGS}

Remove flag from swconfig
    [Documentation]  Get swconfig from bts, remove flag from it and upload it back to bts and give site reset.
    Set Suite Variable  ${ADD_FLAG}  ${False}
    Set Suite Variable  ${TEXT_TO_STEP}  Remove flag
    Run Keyword And Continue On Failure  Run Keyword In Loop And Return Pass Rate
        ...   ${WAIT_FOR_CELLS_UP}  ${WAIT_CHECKS}  ${SYSLOG_LIST}  ${FLAG_VALUE}  ${ADD_FLAG}  ${TEXT_TO_STEP}
        ...    name=Remove flag from swconfig
        ...    test_case=1
        ...    loops=1
		...    keywords=Change flag to swconfig
        ...    expected_pass_rate=1
        ...    collect_test_logs=${COLLECT_LOGS}

Add flag without need for reset
    [Documentation]  Take ssh connection and telnet connection to bts and change the flag on the run, without need of reset.
   Run Keyword And Continue On Failure  Run Keyword In Loop And Return Pass Rate
        ...    ${WAIT_CHECKS}  ${SYSLOG_LIST}  ${FLAG_VALUE}
        ...    name=Add flag without need for reset
        ...    test_case=1
        ...    loops=1
		...    keywords=Add flag without need for reset
        ...    expected_pass_rate=1
        ...    collect_test_logs=${COLLECT_LOGS}
