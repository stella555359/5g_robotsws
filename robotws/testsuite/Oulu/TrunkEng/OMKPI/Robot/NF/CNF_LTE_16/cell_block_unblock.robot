*** Settings ***
Force Tags          CLOUD_FR4_ASOH_[11]_[AHEH_AHEH]

Documentation
...   Author:   Heikki Autio
...   Contact:  I_MN_RAN_RD_TV_OTACI_CITCRT1@internal.nsn.com
...             KPI#17a - Manual block cell duration
...             KPI#17b - Manual unblock cell duration

Library           Collections
Library           taf.sw.reporting_portal
Resource          testsuite/Oulu/TrunkEng/Common/Robot/Resources/common_resources.robot
Resource          testsuite/Oulu/TrunkEng/OMKPI/Robot/Resources/OMKPI_common.robot
Resource          testsuite/Oulu/TrunkEng/OMKPI/Robot/TestKeywords/omkpi_block_unblock_one_cell.robot
Variables         testsuite/Oulu/TrunkEng/OMKPI/Robot/Targets/CNF_LTE_16_omkpi_targets.py

Suite Setup       Common Suite Setup
Suite Teardown    Common Suite Teardown

Test Setup        Run Keywords  Common Test Setup
...               AND           Start Alarm Listener  ${ALLOWED_ALARMS_FILE}
Test Teardown     Common Test Teardown

*** Variables ***
${WAIT_FOR_CELLS_UP}    100
${CELL_TO_BLOCK}        1    # Give id of cell to be blocked
${ALLOWED_ALARMS_FILE}  /home/ute/MN/UTE/robotws/testsuite/Oulu/TrunkEng/OMKPI/allowed_alarms.txt
${USED_RAT}             LN   # NR if 5G
${WAIT_CHECKS}          90   # seconds, 0 if no waiting nor printing before post conditions check
${TEST_LOOPS}           10
# to list below you can add prints that will be monitored from syslog, if print is found, it is written to eventlog
@{SYSLOG_LIST}
# to list below you can add prints that will fail the test if they are found from syslog
@{UNALLOWED_SYSLOGS}    13 (ERPresetTypeApplicationBts)  4 (ERPresetTypeSpuriousReset)
                   ...  14 (ERPresetTypeSpuriousResetBts)  0 (ERPresetTypePowerOn)
${REFERENCE_TESTLINE}   CNF_LTE_16
${REPORT}               ${True}
# Collect logs variable. Possible values are: On failure/Never/Always
${COLLECT_LOGS}         Always
${ZIP_LOGS}             ${True}

*** Test Cases ***
Automated_OAMKPI_Cell_Block_Unblock
    [Documentation]  Blocks and unblocks one cell. If you want to test 5G cells, switch RAT of Variables from LN to NR.
    [Tags]           "Cell block & unblock" -test loops: ${TEST_LOOPS}
    Run Keyword And Continue On Failure  Run Keyword In Loop And Return Pass Rate
        ...    ${CELL_TO_BLOCK}  ${USED_RAT}  ${WAIT_FOR_CELLS_UP}  ${WAIT_CHECKS}  ${SYSLOG_LIST}  ${UNALLOWED_SYSLOGS}
        ...    name=Block unblock cell
        ...    test_case=1
        ...    loops=${TEST_LOOPS}
        ...    keywords=Block unblock cell
        ...    expected_pass_rate=1
        ...    collect_test_logs=${COLLECT_LOGS}
        ...    omkpi_case=${True}
