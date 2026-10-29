*** Settings ***

Documentation
...  Contact:  I_MN_RAN_RD_TV_OTACI_CITCRT1@internal.nsn.com

Resource     testsuite/Oulu/TrunkEng/Common/Robot/Resources/common_resources.robot
Resource     testsuite/Oulu/TrunkEng/ALD/Robot/TestKeywords/ald_10_alarm_with_rf_reset.robot
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
#  Possible second radio for RF reset
${POSSIBLE_RADIO}=
${WAIT_TIME_BEFORE_ALARM}=            120
${WAIT_TIME_AFTER_CANCELLING_ALARM}=  60
#  Affected ANTLs is used for FEG calculation, FEGs are allowed to change for this specific ANTL
#  This is a list variable so give it like this ->  RMOD-x/ANTL-x  RMOD-x/ANTL-x  (separated with two spaces)
@{AFFECTED_ANTLS}=
${ALARM}=                             10


*** Test Cases ***
ALD 10 Alarm With Rf Reset
    [Documentation]    Generate No Connection To Unit Alarm
    Run Keyword And Continue On Failure  Run Keyword In Loop And Return Pass Rate
    ...   ${ALARM_ANTL}  ${RADIO}  ${POSSIBLE_RADIO}  ${WAIT_TIME_BEFORE_ALARM}
    ...   ${WAIT_TIME_AFTER_CANCELLING_ALARM}  ${AFFECTED_ANTLS}  ${ALARM}
    ...   name=ALD 10 Alarm
    ...   test_case=1
    ...   collect_test_logs=${COLLECT_LOGS}
    ...   loops=${TEST_LOOPS}
    ...   keywords=ALD 10 Alarm With Rf Reset
    ...   expected_pass_rate=1
