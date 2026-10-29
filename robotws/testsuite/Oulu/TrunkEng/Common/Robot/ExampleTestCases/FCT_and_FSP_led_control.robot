*** Settings ***
Documentation
...    Author:      Valtteri Lamberg
...    Contact:     I_MN_RAN_RD_TV_OTACI_CITCRT1@internal.nsn.com

Library     taf.sw.reporting_portal
Resource    testsuite/Oulu/TrunkEng/Common/Robot/Resources/common_resources.robot
Resource    testsuite/Oulu/TrunkEng/OMKPI/Robot/Resources/OMKPI_common.robot
Resource    testsuite/Oulu/TrunkEng/Common/Robot/TestKeywords/FCT_and_FSP_led_control.robot

Suite Setup         Common Suite Setup
Suite Teardown      Common Suite Teardown

Test Setup          Run Keywords  Common Test Setup
...                 AND           Start Alarm Listener  ${ALLOWED_ALARMS_FILE}  ${ALLOWED_ALARMS}
Test Teardown       Common Test Teardown

*** Variables ***
@{LED_COLORS_WHEN_POWER_ON}=   Green  Off
@{LED_COLORS_WHEN_POWER_OFF}=  Green  Red  Off
${WAIT_TIME_AFTER_POWER_OFF}=  60   # seconds to wait between power off and on
${RMOD_TO_RESET}               r1
${WAIT_FOR_CELLS_UP}           300
${COLLECT_LOGS}                On failure
${TEST_LOOPS}                  1
${REFERENCE_TESTLINE}          ${EMPTY}
${SCOUT_TL_NAME}               ${EMPTY}
${ALLOWED_ALARMS_FILE}         testsuite/Oulu/TrunkEng/OMKPI/allowed_alarms.txt
# List of allowed alarms for this case. Either fault id or fault name. Faults separated by at least two spaces
@{ALLOWED_ALARMS}              10
${REPORT}                      ${True}


*** Test Cases ***
Automated_FCT_and_FSP_Led_control
    [Tags]  "FCT and FSP led control" -test loops: ${TEST_LOOPS}
    [Documentation]  Check LEDs before and after RU/FSP reset.
    Run Keyword And Continue On Failure  Run Keyword In Loop And Return Pass Rate
        ...    ${RMOD_TO_RESET}  ${WAIT_TIME_AFTER_POWER_OFF}  ${WAIT_FOR_CELLS_UP}
        ...    name=FCT and FSP led control
        ...    test_case=1
        ...    loops=${TEST_LOOPS}
		...    keywords=FCT and FSP led control
        ...    expected_pass_rate=1
        ...    collect_test_logs=${COLLECT_LOGS}

