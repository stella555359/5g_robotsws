*** Settings ***

Documentation
...  Author:   Jere Jacklin
...  Contact:  I_MN_RAN_RD_TV_OTACI_CITCRT1@internal.nsn.com

Resource     testsuite/Oulu/TrunkEng/Common/Robot/Resources/common_resources.robot
Resource     testsuite/Oulu/TrunkEng/ALD/Robot/TestKeywords/mha_alarm_during_rf_lock.robot
Variables    testsuite/Oulu/TrunkEng/ALD/Python/Resources/ALDEnvironments.py


Suite Setup        Common Suite Setup
Suite Teardown     Common Suite Teardown

Test Setup         Run keywords  Common Test Setup
...                AND  Start Alarm Listener  ${ALLOWED_ALARMS_FILE}
Test Teardown      Common Test Teardown


*** Variables ***
${WAIT_BEFORE_ALARMS}=                120
${WAIT_AFTER_RF_LOCK}=                30
${WAIT_AFTER_CANCEL_ALARM}=           60
${LNA}=                               lna2
${ALARM_TYPE}=                        MajorTmaFault
${EMULATOR_LINE}=                     EmulatorLine1
#  ALARM = fault id
${ALARM}=                             1870
${ALARM_ANTL}=                        RMOD-1/ANTL-5
${RADIO}=                             RMOD-1
#  This is a list variable so give it like this ->  RMOD-x/ANTL-x  RMOD-x/ANTL-x  (separated with two spaces)
#  If there is not going to be change in FEG values, leave this variable empty
@{AFFECTED_ANTLS}=                    RMOD-2/ANTL-5
${WANTED_STATE}=                      failed
${ALLOWED_ALARMS_FILE}=               testsuite/Oulu/TrunkEng/ALD/allowed_alarms.txt
${FAULT_NAME}=                        Mast Head Amplifier fault
${COLLECT_LOGS}                       On failure
${TEST_LOOPS}                         1

*** Test Cases ***
Mha Alarm During Rf Lock
    [Documentation]    Raise MHA alarm during Rf Lock
    Run Keyword And Continue On Failure  Run Keyword In Loop And Return Pass Rate
    ...  ${WAIT_BEFORE_ALARMS}  ${WAIT_AFTER_RF_LOCK}  ${WAIT_AFTER_CANCEL_ALARM}
    ...  ${LNA}  ${ALARM_TYPE}  ${EMULATOR_LINE}  ${ALARM}  ${ALARM_ANTL}  ${RADIO}  ${AFFECTED_ANTLS}
    ...  ${WANTED_STATE}  ${FAULT_NAME}
    ...   name=Mha Alarm During Rf Lock
    ...   test_case=1
    ...   collect_test_logs=${COLLECT_LOGS}
    ...   loops=${TEST_LOOPS}
    ...   keywords=Mha Alarm During Rf Lock
    ...   expected_pass_rate=1