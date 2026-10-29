*** Settings ***
Documentation  This suite contains WebEM__Simplified_Site_View_Master_Mode_visualization TC

Resource  ../test_resources/WebEM__Simplified_Site_View_Master_Mode_visualization.robot


*** Test Cases ***
WebEM__Simplified_Site_View_Master_Mode_visualization
    [Setup]  TC Setup
    TC__WebEM__Simplified_Site_View_Master_Mode_visualization
    [Teardown]  TC Teardown
