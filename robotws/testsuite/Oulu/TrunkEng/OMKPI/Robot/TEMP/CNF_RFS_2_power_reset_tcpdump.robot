*** Settings ***
Force Tags

Documentation
...   Author:   Heikki Autio
...   Contact:  I_MN_RAN_RD_TV_OTACI_CITCRT1@internal.nsn.com
...             KPI#3 - Manual power reset downtime

Library          taf.sw.reporting_portal
Resource         testsuite/Oulu/TrunkEng/Common/Robot/Resources/common_resources.robot
Resource         testsuite/Oulu/TrunkEng/OMKPI/Robot/Resources/OMKPI_common.robot
Resource         testsuite/Oulu/TrunkEng/OMKPI/Robot/TestKeywords/omkpi_power_reset.robot
Variables        testsuite/Oulu/TrunkEng/OMKPI/Robot/Targets/CNF_RFS_2_omkpi_targets.py

Suite Setup       Common Suite Setup
Suite Teardown    Common Suite Teardown

Test Setup        Run Keywords  Common Test Setup
...               AND           Start Alarm Listener  ${ALLOWED_ALARMS_FILE}
Test Teardown     Common Test Teardown

*** Variables ***
${WAIT_FOR_CELLS_UP}        1000
${PB_WAIT}                  1      # seconds to wait between power off and on
# Collect logs variable. Possible values are: On failure/Never/Always
${COLLECT_LOGS}             On failure
# How many times test will be run, needs to be more than 0
${TEST_LOOPS}               10
${REFERENCE_TESTLINE}       CNF_RFS_2
${ALLOWED_ALARMS_FILE}      testsuite/Oulu/TrunkEng/OMKPI/allowed_alarms.txt
# List of allowed alarms for this case. Either fault id or fault name. Faults separated by at least two spaces
@{ALLOWED_ALARMS}           4590  1815  1898  6327
${REPORT}                   ${False}
@{SYSLOG_LIST}
@{UNALLOWED_SYSLOGS}        4 (ERPresetTypeSpuriousReset)    14 (ERPresetTypeSpuriousResetBts)
${WAIT_CHECKS}              90    # seconds, 0 if no waiting nor printing before post conditions check
${RFS}                      ${True}
${MASTER}                   This
${FAULT_CAUSE_DEGRADED_CELLS}  1898
${SSH_COMMANDS_BEFORE_TEST}    tcpdump sctp -i any -W 10 -C 100 -w /ffs/run/logs/1011.pcap
${SPECIAL_LOG}                 /ffs/run/logs/1011.pcap*

*** Test Cases ***
Automated_OAMKPI_Power_Reset
    [Documentation]  Perform power reset and collect KPI results.
    [Tags]           "RFS Power reset" -test loops: ${TEST_LOOPS}
    Run Keyword And Continue On Failure  Run Keyword In Loop And Return Pass Rate
        ...    ${SYSLOG_LIST}  ${UNALLOWED_SYSLOGS}  ${WAIT_CHECKS}  ${WAIT_FOR_CELLS_UP}  ${PB_WAIT}  ${OAM_KPI_TARGETS}
        ...    name=RFS Power Reset
        ...    test_case=1
        ...    loops=${TEST_LOOPS}
        ...    keywords=RFS Power Reset
        ...    expected_pass_rate=1.0
        ...    collect_test_logs=${COLLECT_LOGS}
        ...    omkpi_case=${True}

