*** Settings ***
Documentation  This suite contains STATE__LTE_RAT_reset__parameter_change__ADMIN TC

Resource  ../test_resources/STATE__LTE_RAT_reset__parameter_change__ADMIN.robot


*** Test Cases ***
STATE__LTE_RAT_reset__parameter_change__ADMIN
    [Setup]  TC Setup
    TC__STATE__LTE_RAT_reset__parameter_change__ADMIN
    [Teardown]  TC Teardown
