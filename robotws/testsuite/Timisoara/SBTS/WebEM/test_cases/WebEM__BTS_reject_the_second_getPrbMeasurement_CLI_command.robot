*** Settings ***
Documentation  This suite contains WebEM__BTS_reject_the_second_getPrbMeasurement_CLI_command TC

Resource  ../test_resources/WebEM__BTS_reject_the_second_getPrbMeasurement_CLI_command.robot


*** Test Cases ***
WebEM__BTS_reject_the_second_getPrbMeasurement_CLI_command
    [Setup]  TC Setup
    TC__WebEM__BTS_reject_the_second_getPrbMeasurement_CLI_command
    [Teardown]  TC Teardown
