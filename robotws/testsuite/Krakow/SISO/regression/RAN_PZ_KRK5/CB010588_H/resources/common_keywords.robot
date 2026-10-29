*** Settings ***
Documentation
...   Keywords for regression testing of feature CB010588
...   author: Mateusz Bugaj, Daniel Kulaga, Pawel Grabania
...   contact: mateusz.bugaj@nokia.com, daniel.kulaga@nokia.com, pawel.grabania@nokia.com

Resource     taf/rfrl/procedures/resources/robot/common_setups_and_teardowns.robot

Library      Collections
Library      taf.rfrl.utilities.logger.custom_logger                              WITH NAME    logger
Library      taf.rfrl.bts.devices.du.cell_operations.GnbCellOperations            WITH NAME    gnbcell
Library     ./resources.py                                                        WITH NAME    local_resources

*** Keywords ***
Add custom alarms
    [Arguments]    ${alarms_for_test}
    Set Test Variable    ${additional_allowed_alarms}    ${alarms_for_test}
    Set Test Variable    ${CUSTOM_ALLOWED_ALARMS}    ${alarms_for_test}

Actions after test
    Remove custom allowed alarms if defined
    [Teardown]    Common Postconditions With Watching Alarms

Actions before test With Checking Configuration and Changing It If Needed
    [Arguments]    ${correct_config}    ${prefix_tag}=${None}    ${alarms_for_test}=${None}
    local_resources.Verify Is Correct Config And Change It If Needed    correct_config=${correct_config}
    ...                                                                 prefix_tag=${prefix_tag}
    Wait Until Keyword Succeeds    900 sec    30 sec    gnbcell.Verify All Cells Are Onair
    Run keyword if    "${alarms_for_test}!=${None}"    Add custom alarms    ${alarms_for_test}
    Common Preconditions With Watching Alarms

Actions before test
    [Arguments]    ${alarms_for_test}=${None}
    Run keyword if    "${alarms_for_test}!=${None}"    Add custom alarms    ${alarms_for_test}
    Common Preconditions With Watching Alarms

Actions before test With Checking Configuration
    [Arguments]    ${correct_config}    ${alarms_for_test}=${None}
    local_resources.Verify Is Correct Config    correct_config=${correct_config}
    Run keyword if    "${alarms_for_test}!=${None}"    Add custom alarms    ${alarms_for_test}
    Common Preconditions With Watching Alarms
