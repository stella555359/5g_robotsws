*** Settings ***
Force Tags          PY39

Documentation
...                 Author:   Lauri Lehtoaho
...                 Contact:  I_MN_RAN_RD_TV_OTACI_CITCRT1@internal.nsn.com

Resource        testsuite/Oulu/TrunkEng/Common/Robot/Resources/common_resources.robot
Resource        testsuite/Oulu/TrunkEng/OMKPI/Robot/TestKeywords/ue_data_transfer.robot

Suite Setup       Common Suite Setup
Suite Teardown    Common Suite Teardown

Test Setup        Run Keywords  Common Test Setup
...               AND           Start Alarm Listener  ${ALLOWED_ALARMS_FILE}
Test Teardown     Common Test Teardown

*** Variables ***
# Collect logs variable. Possible values are: On failure/Never/Always
${COLLECT_LOGS}             Never
# How many times test will be run, needs to be more than 0
${TEST_LOOPS}               1
${ALLOWED_ALARMS_FILE}      testsuite/Oulu/TrunkEng/OMKPI/allowed_alarms.txt
@{SYSLOG_LIST}
${UE_IN_USE}                ${True}

*** Test Cases ***
Data transfer
    [Documentation]  UE data transfer.
    [Tags]    "Data transfer" -test loops: ${TEST_LOOPS}
    Run Keyword And Continue On Failure  Run Keyword In Loop And Return Pass Rate
        ...    ${SYSLOG_LIST}
        ...    name=Data transfer
        ...    test_case=1
        ...    loops=${TEST_LOOPS}
        ...    keywords=Data transfer
        ...    expected_pass_rate=1.0
        ...    collect_test_logs=${COLLECT_LOGS}
