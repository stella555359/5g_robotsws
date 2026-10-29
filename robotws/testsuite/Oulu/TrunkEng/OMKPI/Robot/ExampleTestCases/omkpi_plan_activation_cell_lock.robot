*** Settings ***
Documentation
...   Author:   Pekka Lonnakko
...   Contact:  I_MN_RAN_RD_TV_OTACI_CITCRT1@internal.nsn.com

Library          taf.sw.reporting_portal
Library          Collections
Resource         testsuite/Oulu/TrunkEng/Common/Robot/Resources/common_resources.robot
Resource         testsuite/Oulu/TrunkEng/OMKPI/Robot/Resources/OMKPI_common.robot
Library          testsuite.Oulu.TrunkEng.OMKPI.Python.Interfaces.OmkpiCommissioningInterface
Resource         testsuite/Oulu/TrunkEng/OMKPI/Robot/TestKeywords/omkpi_plan_activation_cell_lock.robot
Variables        testsuite/Oulu/TrunkEng/OMKPI/Robot/Targets/omkpi_targets_example.py

Suite Setup       Common Suite Setup
Suite Teardown    Common Suite Teardown

Test Setup        Run Keywords  Common Test Setup
...               AND           Start Alarm Listener  ${ALLOWED_ALARMS_FILE}
Test Teardown     Common Test Teardown

*** Variables ***
# Time (seconds) to max wait for cells to be up and running
${WAIT_FOR_CELLS_UP}    300
# Give id of cell to be blocked
${CELL_TO_LOCK}         1
# To USED_RAT Give LN for LTE and NR if 5G tested
${USED_RAT}             NR
# Lock commission value
#        com.nokia.srbts.nrbts:NRCELL.dlMimoMode=4x4 or 4x2 Closed Loop Spatial Multiplexing,
#        com.nokia.srbts.nrbts:NRCELL.pMax=330,
#        com.nokia.srbts.nrbts:NRCELLGRP.beamformingGridSel=ABFG90DT,
#        com.nokia.srbts.nrbts:NRCELL.prachConfigurationIndex=156
${PARAMETER}            com.nokia.srbts.nrbts:NRCELLGRP.beamformingGridSel=ABFG90DT
# Path to allowed_alarm file
${ALLOWED_ALARMS_FILE}  /home/ute/MN/UTE/robotws/testsuite/Oulu/TrunkEng/OMKPI/allowed_alarms.txt
# seconds, 0 if no waiting nor printing before post conditions check
${WAIT_CHECKS}          10
# Amount of LOOPs 1->
${TEST_LOOPS}           1
# to list below you can add prints that will be monitored from syslog, if print is found, it is written to eventlog
@{SYSLOG_LIST}          Detected most recent reset type was
# to list below you can add prints that will fail the test if they are found from syslog
@{UNALLOWED_SYSLOGS}    13 (ERPresetTypeApplicationBts)  4 (ERPresetTypeSpuriousReset)
                   ...  14 (ERPresetTypeSpuriousResetBts)  0 (ERPresetTypePowerOn)
# testline
${REFERENCE_TESTLINE}   ${EMPTY}
${REPORT}               ${True}
# Collect logs variable. Possible values are: On failure/Never/Always
${COLLECT_LOGS}         On failure

*** Test Cases ***
Plan activation cell lock
    [Documentation]  Locks cell by commissioning. Checks KPI values.
    [Tags]           "Plan activation cell lock" -test loops: ${TEST_LOOPS}
    Run Keyword And Continue On Failure  Run Keyword In Loop And Return Pass Rate
        ...    ${CELL_TO_LOCK}  ${USED_RAT}  ${PARAMETER}  ${WAIT_FOR_CELLS_UP}  ${WAIT_CHECKS}  ${SYSLOG_LIST}  ${UNALLOWED_SYSLOGS}
        ...    name=Plan activation cell lock
        ...    test_case=1
        ...    loops=${TEST_LOOPS}
        ...    keywords=Plan activation cell lock
        ...    expected_pass_rate=1
        ...    collect_test_logs=${COLLECT_LOGS}
        ...    omkpi_case=${True}
