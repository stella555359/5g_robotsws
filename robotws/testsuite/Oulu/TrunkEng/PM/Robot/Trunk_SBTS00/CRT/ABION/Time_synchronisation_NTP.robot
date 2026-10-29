*** Settings ***
Force Tags  PY36  SCFC_ADJUSTMENTS=IPv4.yml

Documentation
...   Author:   Pekka Lonnakko
...   Contact:  pekka.lonnakko@nokia.com

Resource    testsuite/Oulu/TrunkEng/Common/Robot/Resources/common_resources.robot
Resource    testsuite/Oulu/TrunkEng/PM/Robot/TestKeywords/time_synchronization_NTP.robot

Suite Setup       Common Suite Setup
Suite Teardown    Common Suite Teardown

Test Setup        Run Keywords  Common Test Setup
...               AND           Start Alarm Listener  ${ALLOWED_ALARMS_FILE}
...               AND           Init PM File Check    ${BASELINE}
...                                                   ${IGNORED_MEAS}
...                                                   ${IGNORED_COUNTERS}
Test Teardown     Common Test Teardown


*** Variables ***
${INCORRECT_IP}         10.34.142.45
${CORRECT_IP}           10.34.142.90
${MEAS_INTERVAL}        ${15}
${UPLOAD_INTERVAL}      ${15}
${WAIT_CHECKS}          180
${ALLOWED_ALARMS_FILE}  testsuite/Oulu/TrunkEng/PM/Resources/Allowed_alarms_SBTS00.txt
${BASELINE}             testsuite/Oulu/TrunkEng/PM/Resources/Baseline_SBTS00.xml
${IGNORED_MEAS}         testsuite/Oulu/TrunkEng/PM/Resources/Ignored_measurements_SBTS00.txt
${IGNORED_COUNTERS}     testsuite/Oulu/TrunkEng/PM/Resources/Ignored_counters_SBTS00.txt
# Collect logs variable. Possible values are: On failure/Never/Always
${COLLECT_LOGS}         On failure
${MARVIN}               ${True}

*** Test Cases ***
Time Synchronization NTP
    Run Keyword In Loop And Return Pass Rate
        ...    ${INCORRECT_IP}  ${CORRECT_IP}  ${UPLOAD_INTERVAL}  ${MEAS_INTERVAL}  ${WAIT_CHECKS}
        ...    name=Time Synchronization NTP
        ...    test_case=1
        ...    loops=1
		...    keywords=Time Synchronization NTP
        ...    expected_pass_rate=1
        ...    collect_test_logs=${COLLECT_LOGS}

