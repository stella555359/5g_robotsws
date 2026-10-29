*** Settings ***
Documentation  This suite contains WebEM__LTEL2CellConfigurationCollector_script TC

Resource  ../test_resources/WebEM__LTEL2CellConfigurationCollector_script.robot


*** Test Cases ***
WebEM__LTEL2CellConfigurationCollector_script
    [Setup]  TC Setup
    TC__WebEM__LTEL2CellConfigurationCollector_script
    [Teardown]  TC Teardown
