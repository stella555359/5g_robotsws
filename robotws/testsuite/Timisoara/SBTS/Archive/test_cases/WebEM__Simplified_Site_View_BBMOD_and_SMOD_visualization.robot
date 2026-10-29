*** Settings ***
Resource    ../test_resources/WebEM__Simplified_Site_View_BBMOD_and_SMOD_visualization.robot

*** Test Cases ***
WebEM__Simplified_Site_View_BBMOD_and_SMOD_visualization
    [Setup]    TC Setup
    [Teardown]    TC Teardown
    TC__WebEM__Simplified_Site_View_BBMOD_and_SMOD_visualization

