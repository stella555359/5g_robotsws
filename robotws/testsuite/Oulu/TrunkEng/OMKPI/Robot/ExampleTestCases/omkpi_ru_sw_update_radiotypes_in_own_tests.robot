*** Settings ***
Documentation
...   Author:   Terhi Talvitie
...   Contact:  I_MN_RAN_RD_TV_OTACI_CITCRT1@internal.nsn.com
...   This test suite includes 3 test cases. Each test case is for different radio type.
...   Supported radio types in this test suite are AHLOA, AEHC and AHFIB.

Library     Collections
Library     taf.sw.reporting_portal
Resource    testsuite/Oulu/TrunkEng/Common/Robot/Resources/common_resources.robot
Resource    testsuite/Oulu/TrunkEng/OMKPI/Robot/Resources/OMKPI_common.robot
Resource    testsuite/Oulu/TrunkEng/OMKPI/Robot/TestKeywords/omkpi_rf_sw_update.robot

Suite Setup       Common Suite Setup
Suite Teardown    Common Suite Teardown

Test Setup        Run Keywords  Common Test Setup
...               AND           Start Alarm Listener  ${ALLOWED_ALARMS_FILE}
Test Teardown     Common Test Teardown

*** Variables ***
${WAIT_FOR_CELLS_UP}    300
${REPORT}               ${True}
# to list below you can add prints that will be monitored from syslog, if print is found, it is written to eventlog
@{SYSLOG_LIST}          Detected most recent reset type was   failed to execute   FirmwareActivationColdReset   BW.bin updated
...                     status = 70426 UPDATED
# to list below you can add prints that will fail the test if they are found from syslog
@{UNALLOWED_SYSLOGS}    4 (ERPresetTypeSpuriousReset)    14 (ERPresetTypeSpuriousResetBts)

# Path to allowed alarms file
${ALLOWED_ALARMS_FILE}  /home/ute/MN/UTE/robotws/testsuite/Oulu/TrunkEng/OMKPI/allowed_alarms.txt
# seconds, 0 if no waiting nor printing before post conditions check
${WAIT_CHECKS}          60

# Collect logs variable. Possible values are: On failure/Never/Always
${COLLECT_LOGS}         On failure
${TEST_LOOPS}           1
${REFERENCE_TESTLINE}   ${EMPTY}

*** Test Cases ***
OMKPI RU Sw Update KPIs Of AHLOA
    [Documentation]  This test calculates KPI#55a and KPI#55b to radio type AHLOA.
    ...              Get the RF SW to be downloaded from the SBTS SW builds. First do SWDL of T1 to radios,
    ...              then do SWDL of T2 to radios and finally do SWDL of normal build to radios.
    ...              Procedure introduced in 24R3-SR with CB010779.
    Set Suite Variable    ${RADIO_TYPE}  AHLOA
    Run Keyword And Continue On Failure  Run Keyword In Loop And Return Pass Rate
        ...    ${WAIT_FOR_CELLS_UP}  ${WAIT_CHECKS}  ${SYSLOG_LIST}  ${UNALLOWED_SYSLOGS}
        ...    name=OMKPI RU Sw Update AHLOA
        ...    test_case=1
        ...    loops=${TEST_LOOPS}
        ...    keywords=OMKPI RF SW Update
        ...    expected_pass_rate=1
        ...    collect_test_logs=${COLLECT_LOGS}
        ...    omkpi_case=${True}

OMKPI RU Sw Update KPIs Of AEHC
    [Documentation]  This test calculates KPI#55a and KPI#55b to radio type AEHC.
    ...              Get the RF SW to be downloaded from the SBTS SW builds. First do SWDL of T1 to radios,
    ...              then do SWDL of T2 to radios and finally do SWDL of normal build to radios.
    ...              Procedure introduced in 24R3-SR with CB010779.
    Set Suite Variable    ${RADIO_TYPE}  AEHC
    ${kpi55_list}=   Create List    kpi55a  kpi55b
    Run Keyword And Continue On Failure  Change Value Of Oam Kpi Target       ${kpi55_list}   500
    Run Keyword And Continue On Failure  Change Value Of Avg Oam Kpi Target   ${kpi55_list}   500
    Run Keyword And Continue On Failure  Run Keyword In Loop And Return Pass Rate
        ...    ${WAIT_FOR_CELLS_UP}  ${WAIT_CHECKS}  ${SYSLOG_LIST}  ${UNALLOWED_SYSLOGS}
        ...    name=OMKPI RU Sw Update AEHC
        ...    test_case=1
        ...    loops=${TEST_LOOPS}
        ...    keywords=OMKPI RF SW Update
        ...    expected_pass_rate=1
        ...    collect_test_logs=${COLLECT_LOGS}
        ...    omkpi_case=${True}
    Run Keyword And Continue On Failure    Change Value Of Kpi Targets Back To Original

OMKPI RU Sw Update KPIs Of AHFIB
    [Documentation]  This test calculates KPI#55a and KPI#55b to radio type AHFIB.
    ...              Get the RF SW to be downloaded from the SBTS SW builds. First do SWDL of T1 to radios,
    ...              then do SWDL of T2 to radios and finally do SWDL of normal build to radios.
    ...              Procedure introduced in 24R3-SR with CB010779.
    Set Suite Variable    ${RADIO_TYPE}  AHFIB
    Run Keyword And Continue On Failure  Run Keyword In Loop And Return Pass Rate
        ...    ${WAIT_FOR_CELLS_UP}  ${WAIT_CHECKS}  ${SYSLOG_LIST}  ${UNALLOWED_SYSLOGS}
        ...    name=OMKPI RU Sw Update AHFIB
        ...    test_case=1
        ...    loops=${TEST_LOOPS}
        ...    keywords=OMKPI RF SW Update
        ...    expected_pass_rate=1
        ...    collect_test_logs=${COLLECT_LOGS}
        ...    omkpi_case=${True}
