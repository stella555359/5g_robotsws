*** Settings ***

Documentation
...   Author:   Pekka Lonnakko
...   Contact:  I_MN_RAN_RD_TV_TRUNK_OUL1_GMS <I_MN_RAN_RD_TV_OTACI_CITCRT1@internal.nsn.com>

Resource    testsuite/Oulu/TrunkEng/Common/Robot/Resources/common_resources.robot
Resource    testsuite/Oulu/TrunkEng/PM/Robot/TestKeywords/Graceful_cell_shutdown.robot

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
@{GCS_LIMITS}           ${180}  ${210}
${WAIT_BEFORE_LOCK}     180
${WAIT_FOR_CELLS_UP}    300
${MEAS_INTERVAL}        ${15}
${UPLOAD_INTERVAL}      ${15}
# To USED_RAT Give LN for LTE and NR if 5G tested. (This is used for cell state checks)
${USED_RAT}             LN
${TEST_LOOPS}           1
${PASS_RATE}            1
${ALLOWED_ALARMS_FILE}  testsuite/Oulu/TrunkEng/PM/Resources/Allowed_alarms_SBTS00.txt
${BASELINE}             testsuite/Oulu/TrunkEng/PM/Resources/Baseline_SBTS00.xml
${IGNORED_MEAS}         testsuite/Oulu/TrunkEng/PM/Resources/Ignored_measurements_SBTS00.txt
${IGNORED_COUNTERS}     testsuite/Oulu/TrunkEng/PM/Resources/Ignored_counters_SBTS00.txt

*** Test Cases ***
PM Graceful Cell Shutdown
    Run Keyword In Loop And Return Pass Rate
        ...    ${CELL_TO_LOCK}  ${USED_RAT}  ${UPLOAD_INTERVAL}  ${MEAS_INTERVAL}  ${WAIT_BEFORE_LOCK}
        ...    ${WAIT_FOR_CELLS_UP}  ${GCS_LIMITS}
        ...    name=PM Graceful Cell Shutdown
        ...    test_case=1
        ...    loops=${TEST_LOOPS}
		...    keywords=PM Graceful Cell Shutdown
        ...    expected_pass_rate=${PASS_RATE}
