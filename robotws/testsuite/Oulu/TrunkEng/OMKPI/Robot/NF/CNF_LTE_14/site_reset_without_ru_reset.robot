*** Settings ***
Documentation
Force Tags          CLOUD_FR4_ASOE_[11]_[AHEB_AHEB]
...                 CELL_CONFIG=[1I1I]
...                 GPS_SYNC=true
...                 SCFC_ADJUSTMENTS=ASOE_CIT.yml

...   Author:   Heikki Autio
...   Contact:  I_MN_RAN_RD_TV_OTACI_CITCRT1@internal.nsn.com

Library          taf.sw.reporting_portal

Resource         testsuite/Oulu/TrunkEng/Common/Robot/Resources/common_resources.robot
Resource         testsuite/Oulu/TrunkEng/OMKPI/Robot/Resources/OMKPI_common.robot
Resource         testsuite/Oulu/TrunkEng/OMKPI/Robot/TestKeywords/omkpi_site_reset.robot
Variables        testsuite/Oulu/TrunkEng/OMKPI/Robot/Targets/CNF_LTE_14_omkpi_targets.py
#Library          testsuite.Oulu.TrunkEng.Common.Python.Interfaces.Marvin  WITH NAME  Marvin


Suite Setup       Common Suite Setup
Suite Teardown    Common Suite Teardown

Test Setup        Run Keywords  Common Test Setup
...               AND           Start Alarm Listener  ${ALLOWED_ALARMS_FILE}
Test Teardown     Common Test Teardown

*** Variables ***
${WAIT_FOR_CELLS_UP}        400
# Collect logs variable. Possible values are: On failure/Never/Always
${COLLECT_LOGS}             Always
# How many times test will be run, needs to be more than 0
${TEST_LOOPS}               10
${REFERENCE_TESTLINE}       CNF_LTE_14
@{ALLOWED_ALARMS}
${ALLOWED_ALARMS_FILE}      testsuite/Oulu/TrunkEng/OMKPI/allowed_alarms.txt
${REPORT}                   ${True}
@{SYSLOG_LIST}
@{UNALLOWED_SYSLOGS}        4 (ERPresetTypeSpuriousReset)    14 (ERPresetTypeSpuriousResetBts)
${WAIT_CHECKS}              90    # seconds, 0 if no waiting nor printing before post conditions check
${RESET_WITHOUT_RU}         ${True}
${ZIP_LOGS}                 ${True}


*** Test Cases ***
Automated_OAMKPI_Site_Reset_Without_RU_Reset
    [Documentation]  Perform site reset and collect KPI results.
    [Tags]           "Site reset without ru reset" -test loops: ${TEST_LOOPS}
     Run Keyword And Continue On Failure  Run Keyword In Loop And Return Pass Rate
        ...    ${SYSLOG_LIST}  ${UNALLOWED_SYSLOGS}  ${WAIT_CHECKS}  ${WAIT_FOR_CELLS_UP}  ${OAM_KPI_TARGETS}
        ...    name=Site Reset without ru reset
        ...    test_case=1
        ...    loops=${TEST_LOOPS}
        ...    keywords=Site reset
        ...    expected_pass_rate=1.0
        ...    collect_test_logs=${COLLECT_LOGS}
        ...    omkpi_case=${True}
