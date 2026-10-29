*** Settings ***
Force Tags          CLOUD_5G_CLASSICAL_ASIL_2xABIO_ASIB_2xABIA_3xAEHC_4xAHLOA_4xAHFIB_RFS


Documentation
...   Author:   Pekka Kuusiniemi
...   Contact:  I_MN_RAN_RD_TV_OTACI_CITCRT1@internal.nsn.com
...             KPI#54a - Power-on RU startup availability
...             KPI#54b - Power-on RU startup availability

Library         taf.sw.reporting_portal
Resource        testsuite/Oulu/TrunkEng/Common/Robot/Resources/common_resources.robot
Resource        testsuite/Oulu/TrunkEng/OMKPI/Robot/Resources/OMKPI_common.robot
Resource        testsuite/Oulu/TrunkEng/OMKPI/Robot/TestKeywords/omkpi_rf_power_reset.robot
Variables       testsuite/Oulu/TrunkEng/OMKPI/Robot/Targets/CNF_RFS_4_omkpi_targets.py

Suite Setup       Common Suite Setup
Suite Teardown    Common Suite Teardown

Test Setup        Run Keywords  Common Test Setup
...               AND           Start Alarm Listener  ${ALLOWED_ALARMS_FILE}
Test Teardown     Common Test Teardown

*** Variables ***
# This variable has the kind of name that is in power breaker, currently r1, r2, r3....
${RMOD_TO_TEST}          BBMOD2-RMOD4
${WAIT_AFTER_POWER_CUT}  30
${WAIT_FOR_CELLS_UP}     500
${WAIT_CHECKS}           300
# Amount of LOOPs 1->
${TEST_LOOPS}            10
# to list below you can add prints that will be monitored from syslog, if print is found, it is written to eventlog
@{SYSLOG_LIST}
# to list below you can add prints that will fail the test if they are found from syslog
@{UNALLOWED_SYSLOGS}    13 (ERPresetTypeApplicationBts)  4 (ERPresetTypeSpuriousReset)
                   ...  14 (ERPresetTypeSpuriousResetBts)  0 (ERPresetTypePowerOn)
${REFERENCE_TESTLINE}   CNF_RFS_4
${REPORT}               ${True}
# Collect logs variable. Possible values are: On failure/Never/Always
${COLLECT_LOGS}         Always
${RFS}                  ${True}
${MASTER}               This
${ZIP_LOGS}             ${True}

${ALLOWED_ALARMS_FILE}  /home/ute/MN/UTE/robotws/testsuite/Oulu/TrunkEng/OMKPI/allowed_alarms.txt
@{ALLOWED_ALARMS}       4589  1815  10  4773
${NO_MARVIN}            True


*** Test Cases ***
Automated_OAMKPI_RU_Power_Reset
    [Documentation]  Switch power of radio off and back on, check alarms and collect KPI results.
    [Tags]           "RF power reset" -test loops: ${TEST_LOOPS}
    Run Keyword And Continue On Failure  Run Keyword In Loop And Return Pass Rate
        ...    ${RMOD_TO_TEST}  ${WAIT_AFTER_POWER_CUT}  ${WAIT_CHECKS}  ${WAIT_FOR_CELLS_UP}
        ...    ${SYSLOG_LIST}   ${UNALLOWED_SYSLOGS}    ${OAM_KPI_TARGETS}
        ...    name=RF Power Reset
        ...    test_case=1
        ...    loops=${TEST_LOOPS}
        ...    keywords=RF power reset
        ...    expected_pass_rate=1.0
        ...    collect_test_logs=${COLLECT_LOGS}
        ...    omkpi_case=${True}
