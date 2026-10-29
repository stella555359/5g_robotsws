*** Settings ***
Documentation  This suite contains WebEM__vDU__CW_Provision_configuration_plan TC

Resource  ../test_resources/WebEM__vDU__CW_Provision_configuration_plan.robot


*** Test Cases ***
WebEM__vDU__CW_Provision_configuration_plan
    [Setup]  TC Setup
    TC__WebEM__vDU__CW_Provision_configuration_plan
    [Teardown]  TC Teardown
