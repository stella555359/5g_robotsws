*** Settings ***
Documentation
...   Author:   Essi Passoja
...   Contact:  essi.passoja@nokia.com
# First Draft Author Esa Toivanen

Resource    testsuite/Oulu/TrunkEng/Common/Robot/Resources/common_resources.robot



Suite Setup       Common Suite Setup
Suite Teardown    Common Suite Teardown

Test Setup        Run Keywords  Common Test Setup
...               AND           Start Alarm Listener  ${ALLOWED_ALARMS_FILE}
Test Teardown     Common Test Teardown

*** Variables ***
${ALLOWED_ALARMS_FILE}  testsuite/Oulu/TrunkEng/RecoveryAndAlarms/allowed_alarms.txt
${RMOD_TO_TEST}         r1

*** Test Cases ***
Hot Remove Insert
    Run Keyword In Loop And Return Pass Rate
        ...    name=Hot Remove Insert
        ...    test_case=1
        ...    loops=1
        ...    keywords=Hot Remove Insert
        ...    expected_pass_rate=1

*** Keywords ***
Hot Remove Insert
    Print Step Text                      1  Check Preconditions
    Common Preconditions
#    Run Keyword And Continue On Failure     Sleeping Cell Check
    Setup Power Breaker Controller          rmod
    ${RMOD_OBJ}=  Get Rmod Object From User Given Values  ${RMOD_TO_TEST}
    ${rmod_unit_path}=    Get Values From Object    ${RMOD_OBJ}    unit_path
    ${rmod_hw_path}=    Get Values From Object    ${RMOD_OBJ}  hw_path
    ${rmod_name}=    Get Values From Object    ${RMOD_OBJ}  name
    @{ports}=           Find Ports For Chosen Units  r1
    Print Step Text                      2  Hot remove chosen ${rmod_name}
    Turn Power Off From Chosen Units        ${rmod_name}
    Print Step Text                      3  Check alarms
    Sleep  300s  # TODO remove this once below parts are working

#    Run Keyword And Continue On Failure     Wait For Affected Units Offline    ${ports} TODO


    Run Keyword And Continue On Failure Add Expected Alarm alarm_id=7116 fault_id=10
    ...    fault_name=No connection to unit
    ...    severity=Critical
    ...    unit_path=${rmod_unit_path}
    ...    hw_path=${rmod_hw_path}

    Run Keyword And Continue On Failure     Check Expected Alarms
    Print Step Text                      4  Hot insert chosen ports ${ports}
    Turn Power On To Chosen Units        ${rmod_name}
    Run Keyword And Continue On Failure     Wait For All Cells Up  300
    Reset Alarm Listener
    Print Step Text                      5  Check Postconditions
    Run Keyword And Continue On Failure     Common Postconditions
