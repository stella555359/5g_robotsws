*** Settings ***

Documentation
...   Author:   Pekka Lonnakko
...   Contact:  pekka.lonnakko@nokia.com

Resource    testsuite/Oulu/TrunkEng/Common/Robot/Resources/common_resources.robot
Resource    testsuite/Oulu/TrunkEng/PM/Robot/TestKeywords/PM_cell_lock.robot

Suite Setup       Common Suite Setup
Suite Teardown    Common Suite Teardown

Test Setup        Run Keywords  Common Test Setup
...               AND           Start Alarm Listener  ${ALLOWED_ALARMS_FILE}
...               AND           Init PM File Check    ${BASELINE}
...                                                   ${IGNORED_MEAS}
...                                                   ${IGNORED_COUNTERS}
Test Teardown     Common Test Teardown


*** Variables ***
${CELL_TO_LOCK}         1
${WAIT_BEFORE_LOCK}     300
${WAIT_BEFORE_UNLOCK}   180
${MEAS_INTERVAL}        ${15}
${UPLOAD_INTERVAL}      ${15}
${TIMEOUT_ALARMS}       ${1200}
# To USED_RAT Give LN for LTE and NR if 5G tested. (This is used for cell state checks)
${USED_RAT}             LN
${WAIT_CHECKS}          180
${LOOPS}                1
${PASS_RATE}            1
${ALLOWED_ALARMS_FILE}  testsuite/Oulu/TrunkEng/PM/Resources/Allowed_alarms_SBTS00.txt
${BASELINE}             testsuite/Oulu/TrunkEng/PM/Resources/Baseline_SBTS00.xml
${IGNORED_MEAS}         testsuite/Oulu/TrunkEng/PM/Resources/Ignored_measurements_SBTS00.txt
${IGNORED_COUNTERS}     testsuite/Oulu/TrunkEng/PM/Resources/Ignored_counters_SBTS00.txt
${COLLECT_LOGS}         On failure

*** Test Cases ***
PM Cell Lock
    [Tags]  CRT  QCD_MN_RAN  QCP_RAN_ST  QC_798332
    Run Keyword In Loop And Return Pass Rate
        ...    ${CELL_TO_LOCK}  ${USED_RAT}  ${UPLOAD_INTERVAL}  ${MEAS_INTERVAL}  ${WAIT_BEFORE_LOCK}
        ...    ${WAIT_BEFORE_UNLOCK}
        ...    name=PM Cell Lock
        ...    test_case=1
        ...    loops=${LOOPS}
		...    keywords=PM Cell Lock
        ...    expected_pass_rate=${PASS_RATE}
        ...    collect_test_logs=${COLLECT_LOGS}
