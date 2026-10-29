*** Settings ***
Documentation
    ...  This suite contains WebEM__Active_configuration_edition_in_CM_PE_and_fixing_validation_errors_in_online_and_offline_mode TC

Resource  ../test_resources/WebEM__Active_configuration_edition_in_CM_PE_and_fixing_validation_errors_in_online_and_offline_mode.robot


*** Test Cases ***
WebEM__Active_configuration_edition_in_CM_PE_and_fixing_validation_errors_in_online_and_offline_mode
    [Setup]  TC Setup
    TC__WebEM__Active_configuration_edition_in_CM_PE_and_fixing_validation_errors_in_online_and_offline_mode
    [Teardown]  TC Teardown