*** Settings ***
Documentation  This suite contains SWM__Upload_swconfig TC

Resource  ../test_resources/SWM__Upload_swconfig.robot


*** Test Cases ***
SWM__Upload_swconfig
    [Setup]  TC Setup
    TC__SWM__Upload_swconfig
    [Teardown]  TC Teardown
