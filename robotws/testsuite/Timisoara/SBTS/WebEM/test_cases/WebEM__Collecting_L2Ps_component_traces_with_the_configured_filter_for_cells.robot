*** Settings ***
Documentation  This suite contains WebEM__Collecting_L2Ps_component_traces_with_the_configured_filter_for_cells TC

Resource  ../test_resources/WebEM__Collecting_L2Ps_component_traces_with_the_configured_filter_for_cells.robot


*** Test Cases ***
WebEM__Collecting_L2Ps_component_traces_with_the_configured_filter_for_cells
    [Setup]  TC Setup
    TC__WebEM__Collecting_L2Ps_component_traces_with_the_configured_filter_for_cells
    [Teardown]  TC Teardown
