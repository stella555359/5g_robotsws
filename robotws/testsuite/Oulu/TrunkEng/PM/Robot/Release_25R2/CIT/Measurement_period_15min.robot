*** Settings ***

Documentation
...   Author:   Pekka Lonnakko
...   Contact:  I_MN_RAN_RD_TV_TRUNK_OUL1_GMS <I_MN_RAN_RD_TV_TRUNK_OUL1@internal.nsn.com>

Resource    testsuite/Oulu/TrunkEng/Common/Robot/Resources/common_resources.robot
Resource    testsuite/Oulu/TrunkEng/PM/Robot/TestKeywords/Measurement_period_15min.robot

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
${ALLOWED_ALARMS_FILE}  testsuite/Oulu/TrunkEng/PM/Resources/A_alarms_branch.txt
${BASELINE}             testsuite/Oulu/TrunkEng/PM/Resources/baseline_SBTS25R2.xml
${IGNORED_MEAS}         testsuite/Oulu/TrunkEng/PM/Resources/I_measurements_branch.txt
${IGNORED_COUNTERS}     testsuite/Oulu/TrunkEng/PM/Resources/I_counters_branch.txt
# Collect logs variable. Possible values are: On failure/Never/Always
${COLLECT_LOGS}         On failure

*** Test Cases ***
Measurement Period 15min
    Run Keyword In Loop And Return Pass Rate
        ...    ${UPLOAD_INTERVAL}  ${MEAS_INTERVAL}
        ...    name=Measurement Period 15min
        ...    test_case=1
        ...    loops=${LOOPS}
		...    keywords=Measurement Period 15min
        ...    expected_pass_rate=${PASS_RATE}
        ...    collect_test_logs=${COLLECT_LOGS}
