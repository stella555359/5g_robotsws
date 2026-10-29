*** Settings ***
Documentation  This suite contains STATE__WCDMA_RAT_reset_from_ADMIN TC

Resource  ../test_resources/STATE__WCDMA_RAT_reset_from_ADMIN.robot


*** Test Cases ***
STATE__WCDMA_RAT_reset_from_ADMIN
    [Setup]  TC Setup
    TC__STATE__WCDMA_RAT_reset_from_ADMIN
    [Teardown]  TC Teardown
