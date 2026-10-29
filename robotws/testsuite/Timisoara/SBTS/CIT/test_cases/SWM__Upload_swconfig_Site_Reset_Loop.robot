*** Settings ***
Documentation  This suite contains SWM__Upload_swconfig_Site_Reset_Loop TC

Resource  testsuite/Timisoara/SBTS/CIT/test_resources/SWM__Upload_swconfig_Site_Reset_Loop.robot


*** Test Cases ***
SWM__Upload_swconfig_Site_Reset_Loop
    [Setup]  TC Setup
    TC__SWM__Upload_swconfig_Site_Reset_Loop
    [Teardown]  TC Teardown