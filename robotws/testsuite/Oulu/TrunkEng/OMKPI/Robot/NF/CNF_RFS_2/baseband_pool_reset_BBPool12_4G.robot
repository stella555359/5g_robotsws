*** Settings ***
Force Tags          CLOUD_5G_CLASSICAL_ASIL_2xABIO_3xAHCA_3xAEQK_3xAHFIB_RFS

Documentation
...   Author:       Heikki Autio
...   Contact:      I_MN_RAN_RD_TV_OTACI_CITCRT1@internal.nsn.com
...                 KPI#18 - Manual baseband pool reset downtime

Library           Collections
Library           taf.sw.reporting_portal
Resource          testsuite/Oulu/TrunkEng/Common/Robot/Resources/common_resources.robot
Resource          testsuite/Oulu/TrunkEng/OMKPI/Robot/Resources/OMKPI_common.robot
Resource          testsuite/Oulu/TrunkEng/OMKPI/Robot/TestKeywords/omkpi_bbpool_reset.robot
Variables         testsuite/Oulu/TrunkEng/OMKPI/Robot/Targets/CNF_RFS_2_omkpi_targets.py

Suite Setup       Common Suite Setup
Suite Teardown    Common Suite Teardown

Test Setup        Run Keywords  Common Test Setup
...               AND           Start Alarm Listener  ${ALLOWED_ALARMS_FILE}
Test Teardown     Common Test Teardown


*** Variables ***
${WAIT_FOR_CELLS_UP}    300
${REPORT}               ${True}
# BB Pool that is reseted. Can have values BBPool11, BBPool12, BBPool21, BBPool22, BBPool31 or BBPool32. If multiple
# BB pools are wanted to be reseted at the same time you can do it like this: @{BBPOOL_TO_RESET}    BBPool12    BBPool22
${BBPOOL_TO_RESET}      BBPool12
# to list below you can add prints that will be monitored from syslog, if print is found, it is written to eventlog
# NOTE also regex can be used
@{SYSLOG_LIST}
# to list below you can add prints that will fail the test if they are found from syslog
@{UNALLOWED_SYSLOGS}    13 (ERPresetTypeApplicationBts)  4 (ERPresetTypeSpuriousReset)
                   ...  14 (ERPresetTypeSpuriousResetBts)  0 (ERPresetTypePowerOn)
# Path to allowed alarms file
${ALLOWED_ALARMS_FILE}  testsuite/Oulu/TrunkEng/OMKPI/allowed_alarms.txt
${WAIT_CHECKS}          90    # seconds, 0 if no waiting nor printing before post conditions check
# How many times test will be run, needs to be more than 0
${TEST_LOOPS}           10
${REFERENCE_TESTLINE}   CNF_RFS_2
# Collect logs variable. Possible values are: On failure/Never/Always
${COLLECT_LOGS}         Always
${RFS}                  ${True}
${MASTER}               Other
${ZIP_LOGS}             ${True}
${NO_MARVIN}          True

*** Test Cases ***
Automated_OAMKPI_Baseband_Pool_Reset
    [Documentation]  Reset user given BBPool and checks alarms and cell states.
    [Tags]    "Bbpool reset" -test loops: ${TEST_LOOPS}
    Run Keyword And Continue On Failure  Run Keyword In Loop And Return Pass Rate
        ...    ${BBPOOL_TO_RESET}  ${WAIT_FOR_CELLS_UP}  ${WAIT_CHECKS}  ${SYSLOG_LIST}  ${UNALLOWED_SYSLOGS}
        ...    name=Reset BBPool
        ...    test_case=1
        ...    loops=${TEST_LOOPS}
        ...    keywords=Reset BBPool
        ...    expected_pass_rate=1
        ...    collect_test_logs=${COLLECT_LOGS}
        ...    omkpi_case=${True}
