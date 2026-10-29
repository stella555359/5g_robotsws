*** Settings ***

Documentation
...   Author:   Pekka Lonnakko
...   Contact:  pekka.lonnakko@nokia.com

Resource    testsuite/Oulu/TrunkEng/Common/Robot/Resources/common_resources.robot
Resource    testsuite/Oulu/TrunkEng/PM/Robot/TestKeywords/Concurrent_PM_upload_and_snapshot.robot

Suite Setup       Common Suite Setup
Suite Teardown    Common Suite Teardown

Test Setup        Run Keywords  Common Test Setup
...               AND           Start Alarm Listener  ${ALLOWED_ALARMS_FILE}
...               AND           Init PM File Check    ${BASELINE}
...                                                   ${IGNORED_MEAS}
...                                                   ${IGNORED_COUNTERS}
Test Teardown     Common Test Teardown


*** Variables ***
${MEAS_INTERVAL}        ${15}
${UPLOAD_INTERVAL}      ${15}
${LOOPS}                1
${PASS_RATE}            1
${ALLOWED_ALARMS_FILE}  testsuite/Oulu/TrunkEng/PM/Resources/Allowed_alarms_SBTS00_Netact_integration.txt
${BASELINE}             testsuite/Oulu/TrunkEng/PM/Resources/Baseline_SBTS00.xml
${IGNORED_MEAS}         testsuite/Oulu/TrunkEng/PM/Resources/Ignored_measurements_SBTS00.txt
${IGNORED_COUNTERS}     testsuite/Oulu/TrunkEng/PM/Resources/Ignored_counters_SBTS00.txt
${COLLECT_LOGS}         On failure
${MARVIN}               ${True}

*** Test Cases ***
Concurrent PM upload and snapshot
    Sleep  5m
    Run Keyword In Loop And Return Pass Rate
        ...    ${UPLOAD_INTERVAL}  ${MEAS_INTERVAL}
        ...    name=Concurrent PM upload and snapshot
        ...    test_case=1
        ...    loops=${LOOPS}
		...    keywords=Concurrent PM upload and snapshot
        ...    expected_pass_rate=${PASS_RATE}
        ...    collect_test_logs=${COLLECT_LOGS}
