*** Settings ***

Documentation
...  Author:   Essi Passoja
...  Contact:  I_MN_RAN_RD_TV_OTACI_CITCRT1@internal.nsn.com

Resource     testsuite/Oulu/TrunkEng/Common/Robot/Resources/common_resources.robot
Resource     testsuite/Oulu/TrunkEng/ALD/Robot/TestKeywords/vswr_exceed_threshold.robot
Library      testsuite.Oulu.TrunkEng.ALD.Python.Interfaces.VSWR


Suite Setup        Common Suite Setup
Suite Teardown     Common Suite Teardown

Test Setup         Run keywords  Common Test Setup
...                AND  Start Alarm Listener  ${ALLOWED_ALARMS_FILE}
Test Teardown      Common Test Teardown


*** Variables ***
${ANTL}=                        RMOD-2/ANTL-1
${RMOD}=                        RMOD-2
${ALARM}=                       1837
${THRESHOLD}=                   15  # VSWR threshold causing major alarm, actual threshold is 1.5 if given value is 15
${ALLOWED_ALARMS_FILE}=         testsuite/Oulu/TrunkEng/ALD/allowed_alarms.txt
${WAIT_FOR_ALARMS}=             240
${WAIT_AFTER_CANCEL_ALARM}=     60
# Collect logs variable. Possible values are: On failure/Never/Always
${COLLECT_LOGS}                 Never
# How many times test will be run, needs to be more than 0
${TEST_LOOPS}                   1


*** Test Cases ***
VSWR Major Fault
    [Documentation]    Change VSWR threshold causing alarm 1837 'VSWR upper threshold exceeded'.
    Run Keyword And Continue On Failure  Run Keyword In Loop And Return Pass Rate
    ...   ${ANTL}  ${RMOD}  ${ALARM}  ${THRESHOLD}  ${WAIT_FOR_ALARMS}  ${WAIT_AFTER_CANCEL_ALARM}
    ...   name=Exceed VSWR Threshold
    ...   test_case=1
    ...   collect_test_logs=${COLLECT_LOGS}
    ...   loops=${TEST_LOOPS}
    ...   keywords=Exceed VSWR Threshold
    ...   expected_pass_rate=1
