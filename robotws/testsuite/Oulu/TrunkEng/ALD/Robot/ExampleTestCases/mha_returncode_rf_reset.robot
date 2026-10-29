*** Settings ***

Documentation
...  Author:   Jere Jacklin
...  Contact:  I_MN_RAN_RD_TV_OTACI_CITCRT1@internal.nsn.com

Resource     testsuite/Oulu/TrunkEng/Common/Robot/Resources/common_resources.robot
Resource     testsuite/Oulu/TrunkEng/ALD/Robot/TestKeywords/mha_returncode_rf_reset.robot
Variables    testsuite/Oulu/TrunkEng/ALD/Python/Resources/ALDEnvironments.py


Suite Setup        Common Suite Setup
Suite Teardown     Common Suite Teardown

Test Setup         Run keywords  Common Test Setup
...                AND  Start Alarm Listener  ${ALLOWED_ALARMS_FILE}
Test Teardown      Common Test Teardown


*** Variables ***
${WAIT_BEFORE_ALARMS}=                120
${EMULATOR_LINE}=                     EmulatorLine1
#  ALARM = fault id
${ALARM}=                             1869
${RETURN_CODE}=                       MinorTmaFault
${ALARM_ANTL}=                        RMOD-1/ANTL-5
${RADIO}=                             RMOD-1
#  This is a list variable so give it like this ->  RMOD-x/ANTL-x  RMOD-x/ANTL-x  (separated with two spaces)
#  If there is not going to be change in FEG values, leave this variable empty
@{AFFECTED_ANTLS}=
${WANTED_STATE}=                      degraded
${ALLOWED_ALARMS_FILE}=               testsuite/Oulu/TrunkEng/ALD/allowed_alarms.txt
${FAULT_NAME}=                        Mast Head Amplifier fault
${COLLECT_LOGS}                       On failure
${TEST_LOOPS}                         1

*** Test Cases ***
Mha Returncode Rf Reset
    [Documentation]    Set returncode for MHA during Rf Reset
    Run Keyword And Continue On Failure  Run Keyword In Loop And Return Pass Rate
    ...   ${ALARM_ANTL}  ${ALARM}  ${EMULATOR_LINE}  ${RETURN_CODE}  ${RADIO}
	...   ${WAIT_BEFORE_ALARMS}  ${WANTED_STATE}  ${AFFECTED_ANTLS}  ${FAULT_NAME}
    ...   name=Mha Returncode Rf Reset
    ...   test_case=1
    ...   collect_test_logs=${COLLECT_LOGS}
    ...   loops=${TEST_LOOPS}
    ...   keywords=Mha Returncode Rf Reset
    ...   expected_pass_rate=1