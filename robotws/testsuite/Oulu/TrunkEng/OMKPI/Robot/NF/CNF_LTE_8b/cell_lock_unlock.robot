*** Settings ***
Force Tags          CLOUD_FR4A_x_AA_[1][1]_[AHBCC][AHBCC]_ASIAA

Documentation
...   Author:       Topi Pasanen
...   Contact:      I_MN_RAN_RD_TV_OTACI_CITCRT1@internal.nsn.com
...                 KPI#16a - Manual lock cell duration
...                 KPI#16b - Manual unlock cell duration

Library          taf.sw.reporting_portal
Library          Collections
Resource         testsuite/Oulu/TrunkEng/Common/Robot/Resources/common_resources.robot
Resource         testsuite/Oulu/TrunkEng/OMKPI/Robot/Resources/OMKPI_common.robot
Resource         testsuite/Oulu/TrunkEng/OMKPI/Robot/TestKeywords/omkpi_cell_lock_unlock.robot
Variables        testsuite/Oulu/TrunkEng/OMKPI/Robot/Targets/CNF_LTE_8b_omkpi_targets.py

Suite Setup       Common Suite Setup
Suite Teardown    Common Suite Teardown

Test Setup        Run Keywords  Common Test Setup
...               AND           Start Alarm Listener  ${ALLOWED_ALARMS_FILE}
Test Teardown     Common Test Teardown

*** Variables ***
# Time (seconds) to max wait for cells to be up and running
${WAIT_FOR_CELLS_UP}    100
# Give id of cell to be blocked
${CELL_TO_LOCK}         1
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
# testline
${REFERENCE_TESTLINE}   CNF_LTE_8b
${REPORT}               ${True}
# Collect logs variable. Possible values are: On failure/Never/Always
${COLLECT_LOGS}         Always
${ZIP_LOGS}             ${True}


*** Test Cases ***
Automated_OAMKPI_Cell_Lock_Unlock
    [Documentation]  Locks and unlocks cell. Checks KPI values.
    [Tags]           "Cell lock/unlock" -test loops: ${TEST_LOOPS}
    Run Keyword And Continue On Failure  Run Keyword In Loop And Return Pass Rate
        ...    ${CELL_TO_LOCK}  ${USED_RAT}  ${WAIT_FOR_CELLS_UP}  ${WAIT_CHECKS}  ${SYSLOG_LIST}  ${UNALLOWED_SYSLOGS}
        ...    name=Cell lock unlock
        ...    test_case=1
        ...    loops=${TEST_LOOPS}
        ...    keywords=Cell lock and unlock
        ...    expected_pass_rate=1
        ...    collect_test_logs=${COLLECT_LOGS}
        ...    omkpi_case=${True}
