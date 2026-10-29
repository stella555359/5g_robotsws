*** Settings ***
Documentation    Test Suite
Resource    ../test_resources/SBTS_SBTS_SBTS_SBTS__STATE__Cell_Block_Unblock_from_WEBEM.robot

*** Test Cases ***
[1]SBTS_SBTS__STATE__BTS1_BTS2_Cell_BlockUnblock_on_SharedRMs_from_WebEM
    [Tags]    robot:skip
    [Setup]    TC Setup
    [Teardown]    TC Teardown
    TC__SBTS_SBTS_SBTS_SBTS__STATE__Cell_Block_Unblock_from_WEBEM
