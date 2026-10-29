*** Settings ***

Documentation
...  Contact:  Jere Jacklin

Resource     testsuite/Oulu/TrunkEng/Common/Robot/Resources/common_resources.robot
Resource     testsuite/Oulu/TrunkEng/ALD/Robot/TestKeywords/ald_10_alarm_with_soc_crash.robot
Variables    testsuite/Oulu/TrunkEng/ALD/Python/Resources/ALDEnvironments.py



Suite Setup        Common Suite Setup
Suite Teardown     Common Suite Teardown

Test Setup         Run keywords  Common Test Setup
...                AND  Start Alarm Listener  ${ALLOWED_ALARMS_FILE}
Test Teardown      Common Test Teardown


*** Variables ***
${ALARM_ANTL}=                        RMOD-1/ANTL-1
${RADIO}=                             RMOD-1
${ALLOWED_ALARMS_FILE}=               testsuite/Oulu/TrunkEng/ALD/allowed_alarms.txt
${WAIT_TIME_BEFORE_ALARM}=            120
${WAIT_TIME_AFTER_CANCELLING_ALARM}=  60
#  Affected ANTLs is used for FEG calculation, FEGs are allowed to change for this specific ANTL
#  This is a list variable so give it like this ->  RMOD-x/ANTL-x  RMOD-x/ANTL-x  (separated with two spaces)
@{AFFECTED_ANTLS}=
${ALARM}=                             10
${COLLECT_LOGS}=                      On failure
${TEST_LOOPS}=                        1
${SMOD}=                              SMOD1
# Currently testcase only works with ASOG/H/E environments and is tested with Thor & CCSEmDispatcherExe application
${SOC}=                               Thor
${APPLICATION}=                       CCSEmDispatcherExe
${ALLOWED_ALARMS}=                    6450

*** Test Cases ***
ALD 10 Alarm With SoC Crash
    [Documentation]    Generate No Connection To Unit Alarm with SoC crash
    Run Keyword And Continue On Failure  Run Keyword In Loop And Return Pass Rate
    ...   ${ALARM_ANTL}  ${RADIO}  ${WAIT_TIME_BEFORE_ALARM}  ${WAIT_TIME_AFTER_CANCELLING_ALARM}
    ...   ${AFFECTED_ANTLS}  ${ALARM}  ${SMOD}  ${SOC}  ${APPLICATION}
    ...   name=ALD 10 Alarm With SoC Crash
    ...   test_case=1
    ...   collect_test_logs=${COLLECT_LOGS}
    ...   loops=${TEST_LOOPS}
    ...   keywords=ALD 10 Alarm With SoC Crash
    ...   expected_pass_rate=1
