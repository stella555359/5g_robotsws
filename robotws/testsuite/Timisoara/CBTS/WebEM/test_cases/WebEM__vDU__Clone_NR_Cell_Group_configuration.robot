*** Settings ***
Documentation  This suite contains WebEM__vDU__Clone_NR_Cell_Group_configuration TC

Resource  ../test_resources/WebEM__vDU__Clone_NR_Cell_Group_configuration.robot


*** Test Cases ***
WebEM__vDU__Clone_NR_Cell_Group_configuration
    [Setup]  TC Setup
    TC__WebEM__vDU__Clone_NR_Cell_Group_configuration
    [Teardown]  TC Teardown
