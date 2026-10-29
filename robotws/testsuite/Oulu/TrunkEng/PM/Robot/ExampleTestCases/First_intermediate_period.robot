*** Settings ***

Documentation
...   Author:   Pekka Lonnakko
...   Contact:  I_MN_RAN_RD_TV_TRUNK_OUL1_GMS <I_MN_RAN_RD_TV_OTACI_CITCRT1@internal.nsn.com>

Resource    testsuite/Oulu/TrunkEng/Common/Robot/Resources/common_resources.robot
Resource    testsuite/Oulu/TrunkEng/PM/Robot/TestKeywords/First_intermediate_period.robot

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
${WAIT_FOR_CELLS_UP}    ${600}
${LOOPS}                1
${PASS_RATE}            1
${ALLOWED_ALARMS_FILE}  testsuite/Oulu/TrunkEng/PM/Resources/Allowed_alarms_SBTS00.txt
${BASELINE}             testsuite/Oulu/TrunkEng/PM/Resources/Baseline_SBTS00.xml
${IGNORED_MEAS}         testsuite/Oulu/TrunkEng/PM/Resources/Ignored_measurements_SBTS00.txt
${IGNORED_COUNTERS}     testsuite/Oulu/TrunkEng/PM/Resources/Ignored_counters_SBTS00.txt
# Collect logs variable. Possible values are: On failure/Never/Always
${COLLECT_LOGS}         On failure

*** Test Cases ***
PM First Intermediate Period
    Run Keyword In Loop And Return Pass Rate
        ...    ${UPLOAD_INTERVAL}  ${MEAS_INTERVAL}  ${WAIT_FOR_CELLS_UP}
        ...    name=First Intermediate Period
        ...    test_case=1
        ...    loops=${LOOPS}
		...    keywords=PM First Intermediate Period
        ...    expected_pass_rate=${PASS_RATE}
        ...    collect_test_logs=${COLLECT_LOGS}
