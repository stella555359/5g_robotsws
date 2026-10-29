*** Settings ***
Documentation    Test Suite
Resource    ../test_resources/NR_SBTS__STATE__SBTS_GSM_BCF_BlockUnblock_from_WEBEM.robot

*** Test Cases ***
[1]NR_SBTS__STATE__SBTS_GSM_BCF_BlockUnblock_from_WEBEM
    [Setup]    TC Setup
    [Teardown]    TC Teardown
    TC__NR_SBTS__STATE__SBTS_GSM_BCF_BlockUnblock_from_WEBEM