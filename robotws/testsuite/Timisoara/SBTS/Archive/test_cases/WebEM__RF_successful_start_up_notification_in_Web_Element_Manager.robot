*** Settings ***
Resource    ../test_resources/WebEM__RF_successful_start_up_notification_in_Web_Element_Manager.robot

*** Test Cases ***
WebEM__RF_successful_start_up_notification_in_Web_Element_Manager
    [Setup]    TC Setup
    [Teardown]    TC Teardown
    TC__WebEM__RF_successful_start_up_notification_in_Web_Element_Manager
