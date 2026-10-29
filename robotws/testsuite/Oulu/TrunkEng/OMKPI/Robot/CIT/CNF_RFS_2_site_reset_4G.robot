*** Settings ***
Force Tags          CLOUD_5G_CLASSICAL_ASIL_2xABIO_3xAHCA_3xAEQK_3xAHFIB_RFS

Documentation
...   Author:       Heikki Autio
...   Contact:      I_MN_RAN_RD_TV_OTACI_CITCRT1@internal.nsn.com
...                 KPI#1a - Manual site reset downtime
...                 KPI#1b - Manual site reset downtime
...                 KPI#1c - Manual site reset downtime

Library          taf.sw.reporting_portal
Resource         testsuite/Oulu/TrunkEng/Common/Robot/Resources/common_resources.robot
Resource         testsuite/Oulu/TrunkEng/OMKPI/Robot/Resources/OMKPI_common.robot
Resource         testsuite/Oulu/TrunkEng/OMKPI/Robot/TestKeywords/omkpi_site_reset.robot
Variables        testsuite/Oulu/TrunkEng/OMKPI/Robot/Targets/CNF_RFS_2_LTE_omkpi_targets.py

Suite Setup       Common Suite Setup
Suite Teardown    Common Suite Teardown

Test Setup        Run Keywords  Common Test Setup
...               AND           Start Alarm Listener  ${ALLOWED_ALARMS_FILE}
Test Teardown     Common Test Teardown

*** Variables ***
${WAIT_FOR_CELLS_UP}        1600
# Collect logs variable.    Possible values are: On failure/Never/Always
${COLLECT_LOGS}             On failure
# How many times test will be run, needs to be more than 0
${TEST_LOOPS}               10
${REFERENCE_TESTLINE}       CNF_RFS_2
${ALLOWED_ALARMS_FILE}      testsuite/Oulu/TrunkEng/OMKPI/allowed_alarms.txt
${REPORT}                   ${True}
@{SYSLOG_LIST}              \(EAaErrorFatality_(NonFatal|Fatal)\)
@{UNALLOWED_SYSLOGS}        4 (ERPresetTypeSpuriousReset)    14 (ERPresetTypeSpuriousResetBts)
                            ...  Please contact the owner of
${WAIT_CHECKS}              120    # seconds, 0 if no waiting nor printing before post conditions check
${MASTER}                   Other
${RFS}                      ${True}
@{ALLOWED_ALARMS}           7107  1898  6327  6202
${FAULT_CAUSE_DEGRADED_CELLS}  1898

*** Test Cases ***
Automated_OAMKPI_Site_Reset
    [Timeout]        16h
    [Documentation]  Perform site reset and collect KPI results.
    [Tags]           "Site reset" -test loops: ${TEST_LOOPS}
     Run Keyword And Continue On Failure  Run Keyword In Loop And Return Pass Rate
        ...    ${SYSLOG_LIST}  ${UNALLOWED_SYSLOGS}  ${WAIT_CHECKS}  ${WAIT_FOR_CELLS_UP}  ${OAM_KPI_TARGETS}
        ...    name=Site Reset
        ...    test_case=1
        ...    loops=${TEST_LOOPS}
        ...    keywords=Site reset
        ...    expected_pass_rate=1.0
        ...    collect_test_logs=${COLLECT_LOGS}
        ...    omkpi_case=${True}
