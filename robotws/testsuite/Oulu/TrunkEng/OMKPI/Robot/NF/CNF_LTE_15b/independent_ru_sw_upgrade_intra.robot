*** Settings ***

Documentation
...   Author:   Lauri Lehtoaho
...   Contact:  I_MN_RAN_RD_TV_OTACI_CITCRT1@internal.nsn.com

Library     Collections
Library     taf.sw.reporting_portal
Resource    testsuite/Oulu/TrunkEng/Common/Robot/Resources/common_resources.robot
Resource    testsuite/Oulu/TrunkEng/OMKPI/Robot/Resources/OMKPI_common.robot
Resource    testsuite/Oulu/TrunkEng/OMKPI/Robot/TestKeywords/omkpi_rf_sw_update.robot
Variables   testsuite/Oulu/TrunkEng/OMKPI/Robot/Targets/CNF_LTE_15_omkpi_targets.py

Suite Setup       Common Suite Setup
Suite Teardown    Common Suite Teardown

Test Setup        Run Keywords  Common Test Setup
...               AND           Start Alarm Listener  ${ALLOWED_ALARMS_FILE}
Test Teardown     Common Test Teardown

*** Variables ***
${WAIT_FOR_CELLS_UP}    500
${REPORT}               ${True}
# to list below you can add prints that will be monitored from syslog, if print is found, it is written to eventlog
@{SYSLOG_LIST}
# to list below you can add prints that will fail the test if they are found from syslog
@{UNALLOWED_SYSLOGS}    4 (ERPresetTypeSpuriousReset)    14 (ERPresetTypeSpuriousResetBts)

# Path to allowed alarms file
${ALLOWED_ALARMS_FILE}  /home/ute/MN/UTE/robotws/testsuite/Oulu/TrunkEng/OMKPI/allowed_alarms.txt
# seconds, 0 if no waiting nor printing before post conditions check
${WAIT_CHECKS}          60

# Collect logs variable. Possible values are: On failure/Never/Always
${COLLECT_LOGS}         Always
${TEST_LOOPS}           3
${REFERENCE_TESTLINE}   CNF_LTE_15b
${ZIP_LOGS}             ${True}

*** Test Cases ***
OMKPI Rf Sw Update
   [Timeout]  24h
    [Documentation]  Get the RF SW to be downloaded from the SBTS SW builds. First do SWDL of T1 to radios,
    ...              then do SWDL of T2 to radios and finally do SWDL of normal build to radios.
    ...              Procedure introduced in 24R3-SR with CB010779.
    Run Keyword And Continue On Failure  Run Keyword In Loop And Return Pass Rate
        ...    ${WAIT_FOR_CELLS_UP}  ${WAIT_CHECKS}  ${SYSLOG_LIST}  ${UNALLOWED_SYSLOGS}
        ...    name=OMKPI Rf Sw Update
        ...    test_case=1
        ...    loops=${TEST_LOOPS}
        ...    keywords=OMKPI RF SW Update
        ...    expected_pass_rate=1
        ...    collect_test_logs=${COLLECT_LOGS}
        ...    omkpi_case=${True}
