*** Settings ***
Documentation
...   Keywords for regression testing of feature CB011091/92
...   author: Mateusz Bugaj
...   contact: mateusz.bugaj@nokia.com

Resource     taf/rfrl/bts/robot/common/gnb_alarm.robot
Resource     taf/rfrl/procedures/resources/robot/common_setups_and_teardowns.robot

Library      Collections
Library      taf.rfrl.procedures.resources.python.common_allowed_alarms           WITH NAME    alarm
Library      taf.rfrl.utilities.logger.custom_logger                              WITH NAME    logger
Library      taf.rfrl.bts.devices.du.du_operations.GnbDuOperations                WITH NAME    gnb_du
Library      SFP_keywords.py                                                      WITH NAME    sfp_actions


*** Keywords ***
Set additional alarms
    [Arguments]    ${alarms_for_test}
    Set Test Variable    ${CUSTOM_ALLOWED_ALARMS}    ${alarms_for_test}

Actions before test
    [Arguments]    ${alarms_for_test}=${None}
    ${default_alarms}=    alarm.get_variables
    Set Test Variable    ${allowed_alarms}    ${default_alarms}[allowed_alarms]
    Run keyword if    "${alarms_for_test}!=${None}"    Set additional alarms    ${alarms_for_test}
    Add Custom Allowed Alarms If Defined

Actions after test
    Remove custom allowed alarms if defined

SFP Lock And Unlock
    logger.log_info_to_console      Performing actions for SFP id 2 - Lock
    sfp_actions.action with sfp    action=Lock      sfp_id=1
    Sleep       40s
    Verify Allowed Alarms on gNB    allowed_alarms=${allowed_alarms}

    logger.log_info_to_console      Performing actions for SFP id 2 - Unlock
    sfp_actions.action with sfp    action=Unlock      sfp_id=1
    Wait Until Keyword Succeeds       300 sec    30 sec    gnbcell.Verify All Cells Are Onair

    logger.log_info_to_console      Performing actions for SFP id 1 - Lock
    sfp_actions.action with sfp    action=Lock      sfp_id=2
    Sleep       40s
    Verify Allowed Alarms on gNB    allowed_alarms=${allowed_alarms}

    logger.log_info_to_console      Performing actions for SFP id 1 - Unlock
    sfp_actions.action with sfp    action=Unlock      sfp_id=2
    Wait Until Keyword Succeeds       300 sec    30 sec    gnbcell.Verify All Cells Are Onair

