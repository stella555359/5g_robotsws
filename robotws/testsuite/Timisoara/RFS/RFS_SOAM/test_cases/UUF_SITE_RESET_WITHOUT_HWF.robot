*** Settings ***
Documentation    Test Suite
Resource    ../test_resources/UUF_SITE_RESET_WITHOUT_HWF.robot

*** Test Cases ***
[1]UUF_SITE_RESET_WITHOUT_HWF
    [Tags]    robot:skip
    TC__UUF_SITE_RESET_WITHOUT_HWF