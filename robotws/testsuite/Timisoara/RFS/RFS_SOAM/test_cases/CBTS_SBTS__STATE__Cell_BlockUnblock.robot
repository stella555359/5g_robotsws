*** Settings ***
Documentation    Test Suite
Resource    ../test_resources/CBTS_SBTS__STATE__Cell_BlockUnblock.robot

*** Test Cases ***
[1]CBTS_SBTS__STATE__Cell_BlockUnblock
    [Setup]    TC Setup
    [Teardown]    TC Teardown
    TC__CBTS_SBTS__STATE__Cell_BlockUnblock

