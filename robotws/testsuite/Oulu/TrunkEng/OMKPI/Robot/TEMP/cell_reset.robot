*** Settings ***
Documentation
...   Author:   Valtteri Lamberg
...   Contact:  I_MN_RAN_RD_TV_OTACI_CITCRT1@internal.nsn.com

Library          taf.sw.reporting_portal
Library          Collections
Resource         testsuite/Oulu/TrunkEng/Common/Robot/Resources/common_resources.robot
Resource         testsuite/Oulu/TrunkEng/OMKPI/Robot/Resources/OMKPI_common.robot
Resource         testsuite/Oulu/TrunkEng/OMKPI/Robot/TestKeywords/omkpi_cell_reset.robot
Variables        testsuite/Oulu/TrunkEng/OMKPI/Robot/Targets/omkpi_targets_example.py

Suite Setup       Common Suite Setup
Suite Teardown    Common Suite Teardown

Test Setup        Run Keywords  Common Test Setup
...               AND           Start Alarm Listener  ${ALLOWED_ALARMS_FILE}
Test Teardown     Common Test Teardown

*** Variables ***
# Time (seconds) to max wait for cells to be up and running
${WAIT_FOR_CELLS_UP}    30
# Give id of cell to be blocked
${CELL_TO_RESET}        1
# To USED_RAT Give LN for LTE and NR if 5G tested. (This is used for cell state checks)
${USED_RAT}             LN
# Path to allowed_alarm file
${ALLOWED_ALARMS_FILE}  /home/ute/MN/UTE/robotws/testsuite/Oulu/TrunkEng/OMKPI/allowed_alarms.txt
# seconds, 0 if no waiting nor printing before post conditions check
${WAIT_CHECKS}          90
# Amount of LOOPs 1->
${TEST_LOOPS}           10
# to list below you can add prints that will be monitored from syslog, if print is found, it is written to eventlog
@{SYSLOG_LIST}
# to list below you can add prints that will fail the test if they are found from syslog
@{UNALLOWED_SYSLOGS}    13 (ERPresetTypeApplicationBts)  4 (ERPresetTypeSpuriousReset)
                   ...  14 (ERPresetTypeSpuriousResetBts)  0 (ERPresetTypePowerOn)
${REFERENCE_TESTLINE}   ${EMPTY}
${REPORT}               ${True}
${COLLECT_LOGS}         On failure

*** Test Cases ***
Cell Reset
    [Documentation]    Resets cell
    [Tags]             "Cell reset" -test loops: ${TEST_LOOPS}
    Run Keyword And Continue On Failure  Run Keyword In Loop And Return Pass Rate
        ...    ${CELL_TO_RESET}  ${WAIT_FOR_CELLS_UP}  ${WAIT_CHECKS}  ${SYSLOG_LIST}  ${USED_RAT}  ${UNALLOWED_SYSLOGS}  ${WAIT_CHECKS}
        ...    name=Cell reset
        ...    test_case=1
        ...    loops=${TEST_LOOPS}
        ...    keywords=Cell reset
        ...    expected_pass_rate=1
        ...    collect_test_logs=${COLLECT_LOGS}
        ...    omkpi_case=${True}