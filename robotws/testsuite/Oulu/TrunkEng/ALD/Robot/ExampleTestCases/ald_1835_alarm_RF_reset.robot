*** Settings ***

Documentation
...  Contact:  I_MN_RAN_RD_TV_OTACI_CITCRT1@internal.nsn.com

Resource     testsuite/Oulu/TrunkEng/Common/Robot/Resources/common_resources.robot
Resource     testsuite/Oulu/TrunkEng/ALD/Robot/TestKeywords/ald_1835_alarm_with_rf_reset.robot
Variables    testsuite/Oulu/TrunkEng/ALD/Python/Resources/ALDEnvironments.py


Suite Setup        Common Suite Setup
Suite Teardown     Common Suite Teardown

Test Setup         Run keywords  Common Test Setup
...                AND  Start Alarm Listener  ${ALLOWED_ALARMS_FILE}
Test Teardown      Common Test Teardown


*** Variables ***
${ALARM_ANTL}=                        RMOD-1/ANTL-3
${RADIO}=                             RMOD-1
${ALLOWED_ALARMS_FILE}=               testsuite/Oulu/TrunkEng/ALD/allowed_alarms.txt
#  Possible second radio for RF reset
${POSSIBLE_RADIO}
${WAIT_TIME_BEFORE_ALARM}=            120
${WAIT_TIME_AFTER_LOCK}=              30
#  Affected ANTLs is used for FEG calculation, FEGs are allowed to change for this specific ANTL
#  This is a list variable so give it like this ->  RMOD-x/ANTL-x  RMOD-x/ANTL-x  (separated with two spaces)
@{AFFECTED_ANTLS}=                    RMOD-1/ANTL-3
${ALARM}=                             1835
${COLLECT_LOGS}                       On failure
${TEST_LOOPS}                         1

*** Test Cases ***
ALD 1835 Alarm With Rf Reset
    [Documentation]    Generate Below Current Window Alarm
    Run Keyword And Continue On Failure  Run Keyword In Loop And Return Pass Rate
    ...   ${ALARM_ANTL}  ${RADIO}
    ...   ${POSSIBLE_RADIO}  ${WAIT_TIME_BEFORE_ALARM}
    ...   ${AFFECTED_ANTLS}  ${ALARM}
    ...   name=ALD 1835 Alarm With Rf Reset
    ...   test_case=1
    ...   collect_test_logs=${COLLECT_LOGS}
    ...   loops=${TEST_LOOPS}
    ...   keywords=ALD 1835 Alarm With Rf Reset
    ...   expected_pass_rate=1