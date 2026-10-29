*** Settings ***
Documentation
...   Author:   Terhi Talvitie
...   Contact:  I_MN_RAN_RD_TV_OTACI_CITCRT1@internal.nsn.com

Library     Collections

Resource    testsuite/Oulu/TrunkEng/Common/Robot/Resources/common_resources.robot
Resource    testsuite/Oulu/TrunkEng/Common/Robot/TestKeywords/trs_commissioning.robot
Library     testsuite.Oulu.TrunkEng.Common.Python.Resources.CommissioningFileModifier
Library     testsuite.Oulu.TrunkEng.Common.Python.Resources.ParameterCommissioning
Library     testsuite.Oulu.TrunkEng.OMKPI.Python.Interfaces.OmkpiCommonInterface

Suite Setup       Common Suite Setup
Suite Teardown    Common Suite Teardown


Test Setup        Run Keywords  Common Test Setup
...               AND           Start Alarm Listener  ${ALLOWED_ALARMS_FILE}
Test Teardown     Common Test Teardown

*** Variables ***
# Path to user given delta file
${COMMISSIONING_FILE}   testsuite/Oulu/TrunkEng/Common/Resources/CommissioningFiles/full_configuration_ipv6.xml
# seconds, 0 if no waiting after commissioning for cells to be faulty
${WAIT_CHECKS}          300
# Time to max wait for all cells to be up and running
${WAIT_FOR_CELLS_UP}    1200
# to list below you can add prints that will be monitored from syslog, if print is found, it is written to eventlog
@{SYSLOG_LIST}          Detected most recent reset type was    failed to execute
# Syslog prints that will fail the test if found from syslog
@{UNALLOWED_SYSLOGS}    4 (ERPresetTypeSpuriousReset)    14 (ERPresetTypeSpuriousResetBts)
# Path to allowed alarms file
${ALLOWED_ALARMS_FILE}  testsuite/Oulu/TrunkEng/OMKPI/allowed_alarms.txt
# Collect logs variable. Possible values are: On failure/Never/Always
${COLLECT_LOGS}         On failure
${REPORT}               ${True}
# How many times test will be run, needs to be more than 0
${TEST_LOOPS}           1

*** Test Cases ***
Full Configuration Commissioning
    [Documentation]  Changes values of commissioning with user given commissioning file
    Run Keyword And Continue On Failure  Run Keyword In Loop And Return Pass Rate
        ...    ${WAIT_FOR_CELLS_UP}  ${WAIT_CHECKS}  ${SYSLOG_LIST}  ${UNALLOWED_SYSLOGS}  ${COMMISSIONING_FILE}
        ...    name=Trs Sec Full Configuration Commissioning
        ...    test_case=1
        ...    loops=${TEST_LOOPS}
		...    keywords=Trs Sec Full Configuration Commissioning
        ...    expected_pass_rate=1
        ...    collect_test_logs=${COLLECT_LOGS}
