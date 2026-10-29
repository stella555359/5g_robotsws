*** Settings ***
Documentation    Test Suite
Resource    ../test_resources/NR_SBTS__STATE__PrimaryController_SecondaryController_Site_Reset_from_WEBEM_with_sharedFHS_config.robot

*** Test Cases ***
[1]NR_SBTS__STATE__PrimaryController_SecondaryController_Site_Reset_from_WEBEM_with_sharedFHS_config
    [Setup]    TC Setup
    [Teardown]    TC Teardown
    TC__NR_SBTS__STATE__PrimaryController_SecondaryController_Site_Reset_from_WEBEM_with_sharedFHS_config
