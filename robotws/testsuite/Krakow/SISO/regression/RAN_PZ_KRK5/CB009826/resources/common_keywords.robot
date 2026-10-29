*** Settings ***
Documentation
...   Keywords for regression testing of feature CB009826

Resource     taf/rfrl/procedures/resources/robot/common_setups_and_teardowns.robot
Library      Collections
Library      taf.rfrl.utilities.logger.custom_logger                              WITH NAME    logger
Library      taf.rfrl.procedures.resources.python.common_allowed_alarms           WITH NAME    alarm

*** Keywords ***
Set additional alarms
    [Arguments]    ${alarms_for_test}
    Set Test Variable    ${CUSTOM_ALLOWED_ALARMS}    ${alarms_for_test}

Actions before test
    [Arguments]    ${alarms_for_test}=${None}
    ${default_alarms}=    alarm.get_variables
    Set Test Variable    ${allowed_alarms}    ${default_alarms}[allowed_alarms]
    Set Test Variable    ${ASIR_ALLOWED_ALARMS}    ${default_alarms}[ASIR_ALLOWED_ALARMS]
    Run keyword if    "${alarms_for_test}!=${None}"    Set additional alarms    ${alarms_for_test}
    Common Preconditions With Watching Alarms

Actions after test
    Remove custom allowed alarms if defined
    Common Postconditions With Watching Alarms
