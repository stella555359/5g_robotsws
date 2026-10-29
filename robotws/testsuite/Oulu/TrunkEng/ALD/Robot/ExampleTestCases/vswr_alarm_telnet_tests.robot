*** Settings ***

Documentation
...  Author:   Terhi Talvitie
...  Contact:  I_MN_RAN_RD_TV_OTACI_CITCRT1@internal.nsn.com

Resource     testsuite/Oulu/TrunkEng/Common/Robot/Resources/common_resources.robot
Resource     testsuite/Oulu/TrunkEng/ALD/Robot/TestKeywords/vswr_fault_with_telnet_tests.robot
Library      testsuite.Oulu.TrunkEng.ALD.Python.Interfaces.VSWR

Suite Setup        Common Suite Setup
Suite Teardown     Common Suite Teardown

Test Setup         Run keywords  Common Test Setup
...                AND  Start Alarm Listener  ${ALLOWED_ALARMS_FILE}
Test Teardown      Common Test Teardown


*** Variables ***
${ANTL}=                        RMOD-1/ANTL-1
${RMOD}=                        RMOD-1
${ALLOWED_ALARMS_FILE}=         testsuite/Oulu/TrunkEng/ALD/allowed_alarms.txt
${WAIT_FOR_ALARMS}=             240
${WAIT_AFTER_CANCEL_ALARM}=     60
# Collect logs variable. Possible values are: On failure/Never/Always
${COLLECT_LOGS}                 Never
# How many times test will be run, needs to be more than 0
${TEST_LOOPS}                   1


*** Test Cases ***
VSWR Minor Alarm
    [Documentation]    Use telnet to set and cancel VSWR minor alarm.
    Run Keyword And Continue On Failure  Run Keyword In Loop And Return Pass Rate
    ...   ${ANTL}  ${RMOD}  ${WAIT_FOR_ALARMS}  ${WAIT_AFTER_CANCEL_ALARM}
    ...   name=Fault 1838 and VSWR Minor Alarm
    ...   test_case=1
    ...   collect_test_logs=${COLLECT_LOGS}
    ...   loops=${TEST_LOOPS}
    ...   keywords=VSWR Minor Alarm With Telnet
    ...   expected_pass_rate=1

VSWR Major Alarm
    [Documentation]    Use telnet to set VSWR major alarm. Cancel of fault is done with RMOD lock and unlock.
    Run Keyword And Continue On Failure  Run Keyword In Loop And Return Pass Rate
    ...   ${ANTL}  ${RMOD}  ${WAIT_FOR_ALARMS}  ${WAIT_AFTER_CANCEL_ALARM}
    ...   name=Fault 1837 and VSWR Major Alarm
    ...   test_case=1
    ...   collect_test_logs=${COLLECT_LOGS}
    ...   loops=${TEST_LOOPS}
    ...   keywords=VSWR Major Alarm With Telnet
    ...   expected_pass_rate=1

VSWR Minor And Major Alarm
    [Documentation]    Use telnet to set VSWR major alarm. Cancel of fault is done with RMOD lock and unlock.
    Run Keyword And Continue On Failure  Run Keyword In Loop And Return Pass Rate
    ...   ${ANTL}  ${RMOD}  ${WAIT_FOR_ALARMS}  ${WAIT_AFTER_CANCEL_ALARM}
    ...   name=VSWR Alarms 1838 Minor and 1837 Major
    ...   test_case=1
    ...   collect_test_logs=${COLLECT_LOGS}
    ...   loops=${TEST_LOOPS}
    ...   keywords=VSWR Minor Major Alarm Telnet
    ...   expected_pass_rate=1
