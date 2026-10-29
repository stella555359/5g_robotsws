*** Settings ***

Documentation
...   Author:   Pekka Lonnakko
...   Contact:  I_MN_RAN_RD_TV_OTACI_CITCRT1@internal.nsn.com

Library           Collections
Library           taf.sw.reporting_portal
Resource          testsuite/Oulu/TrunkEng/Common/Robot/Resources/common_resources.robot
Resource          testsuite/Oulu/TrunkEng/OMKPI/Robot/Resources/OMKPI_common.robot
Variables         testsuite/Oulu/TrunkEng/OMKPI/Robot/Targets/omkpi_targets_example.py

Suite Setup       Common Suite Setup
Suite Teardown    Common Suite Teardown

Test Setup        Run Keywords  Common Test Setup
...               AND           Start Alarm Listener  ${ALLOWED_ALARMS_FILE}
Test Teardown     Common Test Teardown

*** Variables ***
${REPORT}               ${True}
## Expected syslog print that will fail the test if not found during test run
#${SYSLOG_PRINT}         Detected most recent reset type was 1 (ERPresetTypeApplication)
# to list below you can add prints that will be monitored from syslog, if print is found, it is written to eventlog
@{SYSLOG_LIST}          BbmodReset  ResetCounter  Detected most recent reset type was
# to list below you can add prints that will fail the test if they are found from syslog
@{UNALLOWED_SYSLOGS}    13 (ERPresetTypeApplicationBts)  4 (ERPresetTypeSpuriousReset)
# Path to allowed alarms file
${ALLOWED_ALARMS_FILE}  testsuite/Oulu/TrunkEng/OMKPI/allowed_alarms.txt
# Collect logs variable. Possible values are: On failure/Never/Always
# How many times test will be run, needs to be more than 0
${TEST_LOOPS}           1
${REFERENCE_TESTLINE}   ${EMPTY}
${COLLECT_LOGS}         Always
${RFS}                  ${True}
${MASTER}               This  # This/Other

# Example of HALT_TEST_ALARM. Upper has all the available fields
@{HALT_TEST_ALARM}      fault_id=10, fault_name=No connection to unit, hw_path=RMOD-3, alarm_id=7116
...                     fault_id=6450

*** Test Cases ***
Empty test
    [Documentation]  Log test
    Run Keyword And Continue On Failure  Run Keyword In Loop And Return Pass Rate
        ...    name=Log test
        ...    test_case=1
        ...    loops=${TEST_LOOPS}
        ...    keywords=Just Sleep
        ...    expected_pass_rate=1
        ...    collect_test_logs=${COLLECT_LOGS}

*** Keywords ***
Just Sleep
    Sleep  1 minutes
