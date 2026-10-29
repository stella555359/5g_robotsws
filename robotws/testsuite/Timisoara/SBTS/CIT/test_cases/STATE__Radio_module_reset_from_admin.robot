*** Settings ***
Documentation  This suite contains STATE__Radio_module_reset_from_admin TC

Resource  ../test_resources/STATE__Radio_module_reset_from_admin.robot


*** Test Cases ***
STATE__Radio_module_reset_from_admin
    [Setup]  TC Setup
    TC__STATE__Radio_module_reset_from_admin
    [Teardown]  TC Teardown
