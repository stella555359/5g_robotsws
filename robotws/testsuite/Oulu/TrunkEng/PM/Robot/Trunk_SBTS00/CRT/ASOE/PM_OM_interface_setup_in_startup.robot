*** Settings ***
Documentation
...    Author:      Valtteri Lamberg
...    Contact:     I_MN_RAN_RD_TV_OTACI_CITCRT1@internal.nsn.com

Library     taf.sw.reporting_portal
Resource    testsuite/Oulu/TrunkEng/Common/Robot/Resources/common_resources.robot
Resource    testsuite/Oulu/TrunkEng/PM/Robot/TestKeywords/PM_OM_interface_setup_in_startup.robot

Suite Setup         Common Suite Setup
Suite Teardown      Common Suite Teardown

Test Setup          Run Keywords  Common Test Setup
...                 AND           Start Alarm Listener  ${ALLOWED_ALARMS_FILE}
...                 AND           Init PM File Check    ${BASELINE}  ${IGNORED_MEAS}  ${IGNORED_COUNTERS}
Test Teardown       Common Test Teardown

*** Variables ***

${TEST_LOOPS}           1
${PASS_RATE}            1
${WAIT_FOR_CELLS_UP}    300
${ALLOWED_ALARMS_FILE}  testsuite/Oulu/TrunkEng/PM/Resources/Allowed_alarms_SBTS00_Netact.txt
${BASELINE}             testsuite/Oulu/TrunkEng/PM/Resources/Baseline_SBTS00.xml
${IGNORED_MEAS}         testsuite/Oulu/TrunkEng/PM/Resources/Ignored_measurements_SBTS00.txt
${IGNORED_COUNTERS}     testsuite/Oulu/TrunkEng/PM/Resources/Ignored_counters_SBTS00.txt
${COLLECT_LOGS}         On failure

*** Test Cases ***
PM O&M interface setup in startup
    Sleep  5m
    Run Keyword In Loop And Return Pass Rate
    ...   ${WAIT_FOR_CELLS_UP}
    ...   name=PM O&M interface setup in startup
    ...   test_case=1
    ...   loops=${TEST_LOOPS}
    ...   keywords=PM O&M interface setup in startup
    ...   expected_pass_rate=${PASS_RATE}
    ...   collect_test_logs=${COLLECT_LOGS}

