*** Settings ***
Documentation  This suite contains WebEM__Admin_CLI_getRmodMeasurementsById TC

Resource  ../test_resources/WebEM__Admin_CLI_getRmodMeasurementsById.robot


*** Test Cases ***
WebEM__Admin_CLI_getRmodMeasurementsById
    [Setup]  TC Setup
    TC__WebEM__Admin_CLI_getRmodMeasurementsById
    [Teardown]  TC Teardown
