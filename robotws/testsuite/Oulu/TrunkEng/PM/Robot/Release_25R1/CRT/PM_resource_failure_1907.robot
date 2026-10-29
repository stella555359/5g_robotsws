*** Settings ***
Documentation
...    Author:      Valtteri Lamberg
...    Contact:     I_MN_RAN_RD_TV_OTACI_CITCRT1@internal.nsn.com

Library     taf.sw.reporting_portal
Resource    testsuite/Oulu/TrunkEng/Common/Robot/Resources/common_resources.robot
Resource    testsuite/Oulu/TrunkEng/PM/Robot/TestKeywords/PM_resource_failure_1907.robot

Suite Setup         Common Suite Setup
Suite Teardown      Common Suite Teardown

Test Setup          Run Keywords  Common Test Setup
...                 AND           Start Alarm Listener  ${ALLOWED_ALARMS_FILE}
...                 AND           Init PM File Check    ${BASELINE}  ${IGNORED_MEAS}  ${IGNORED_COUNTERS}
Test Teardown       Common Test Teardown

*** Variables ***

${SELECTED_CELL}        1
${USED_RAT}             LN
${TEST_LOOPS}           1
${PASS_RATE}            1
${WAIT_FOR_CELLS_UP}    300
${MEAS_INTERVAL}        ${15}
${UPLOAD_INTERVAL}      ${15}
${RMOD}                 r1
${ALLOWED_ALARMS_FILE}  testsuite/Oulu/TrunkEng/PM/Resources/A_alarms_branch.txt
@{ALLOWED_ALARMS}       1907
${BASELINE}             testsuite/Oulu/TrunkEng/PM/Resources/baseline_SBTS25R1.xml
${IGNORED_MEAS}         testsuite/Oulu/TrunkEng/PM/Resources/I_measurements_branch.txt
${IGNORED_COUNTERS}     testsuite/Oulu/TrunkEng/PM/Resources/I_counters_branch.txt
${COLLECT_LOGS}         On failure

*** Test Cases ***
PM resource failure 1907
    Run Keyword In Loop And Return Pass Rate
        ...   ${SELECTED_CELL}  ${USED_RAT}  ${MEAS_INTERVAL}  ${UPLOAD_INTERVAL}  ${RMOD}  ${WAIT_FOR_CELLS_UP}
        ...   name=PM resource failure 1907
        ...   test_case=1
        ...   loops=${TEST_LOOPS}
        ...   keywords=PM resource failure 1907
        ...   expected_pass_rate=${PASS_RATE}
        ...   collect_test_logs=${COLLECT_LOGS}

