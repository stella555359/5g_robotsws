*** Settings ***
Documentation  This suite contains COMPA__Uboot_downgrade TC

Resource  ../test_resources/COMPA__Uboot_downgrade.robot


*** Test Cases ***
COMPA__Uboot_downgrade.robot
    [Setup]  TC Setup
    TC__COMPA__Uboot_downgrade
    [Teardown]  TC Teardown
