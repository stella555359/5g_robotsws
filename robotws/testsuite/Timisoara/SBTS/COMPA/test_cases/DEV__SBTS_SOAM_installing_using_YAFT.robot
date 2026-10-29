*** Settings ***
Documentation  This suite contains DEV__SBTS_SOAM_installing_using_YAFT TC

Resource  ../test_resources/DEV__SBTS_SOAM_installing_using_YAFT.robot


*** Test Cases ***
DEV__SBTS_SOAM_installing_using_YAFT
    [Setup]  TC Setup
    TC__DEV__SBTS_SOAM_installing_using_YAFT
    [Teardown]  TC Teardown
