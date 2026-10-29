*** Settings ***
Documentation  This suite contains STATE__WCDMA_RAT_reset__parameter_change__ADMIN TC

Resource  ../test_resources/STATE__WCDMA_RAT_reset__parameter_change__ADMIN.robot


*** Test Cases ***
STATE__WCDMA_RAT_reset__parameter_change__ADMIN
    [Setup]  TC Setup
    TC__STATE__WCDMA_RAT_reset__parameter_change__ADMIN
    [Teardown]  TC Teardown
