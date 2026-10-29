*** Settings ***
Documentation
...    Author:      Valtteri Lamberg
...    Contact:     I_MN_RAN_RD_TV_OTACI_CITCRT1@internal.nsn.com

Library     taf.sw.reporting_portal
Resource    testsuite/Oulu/TrunkEng/Common/Robot/Resources/common_resources.robot
Resource    testsuite/Oulu/TrunkEng/PM/Robot/TestKeywords/PM_result_files_upload_after_25h_break.robot

Suite Setup         Common Suite Setup
Suite Teardown      Common Suite Teardown

Test Setup          Run Keywords  Common Test Setup
...                 AND           Start Alarm Listener  ${ALLOWED_ALARMS_FILE}
...                 AND           Init PM File Check    ${BASELINE}  ${IGNORED_MEAS}  ${IGNORED_COUNTERS}
Test Teardown       Common Test Teardown

*** Variables ***

${TEST_LOOPS}           1
${PASS_RATE}            1
${MEAS_INTERVAL}        ${15}
${UPLOAD_INTERVAL}      ${15}
${ALLOWED_ALARMS_FILE}  testsuite/Oulu/TrunkEng/PM/Resources/Allowed_alarms_SBTS00.txt
${BASELINE}             testsuite/Oulu/TrunkEng/PM/Resources/Baseline_SBTS00.xml
${IGNORED_MEAS}         testsuite/Oulu/TrunkEng/PM/Resources/Ignored_measurements_SBTS00.txt
${IGNORED_COUNTERS}     testsuite/Oulu/TrunkEng/PM/Resources/Ignored_counters_SBTS00.txt
${COLLECT_LOGS}         On failure
${CHECK_OAM}            ${True}   # True if OAM connection is dropped and checked. False if only 25h case with PM checks

*** Test Cases ***

PM result files upload after 25h break
    Run Keyword In Loop And Return Pass Rate
    ...   ${MEAS_INTERVAL}  ${UPLOAD_INTERVAL}
    ...   name=PM result files upload after 25h break
    ...   test_case=1
    ...   loops=${TEST_LOOPS}
    ...   keywords=PM result files upload after 25h break
    ...   expected_pass_rate=${PASS_RATE}
    ...   collect_test_logs=${COLLECT_LOGS}
