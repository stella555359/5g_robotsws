*** Settings ***
Documentation  This suite contains WebEM__Enable_Disable_Energy_Consumption_Measurement_Collectection TC

Resource  ../test_resources/WebEM__Enable_Disable_Energy_Consumption_Measurement_Collectection.robot


*** Test Cases ***
WebEM__Enable_Disable_Energy_Consumption_Measurement_Collectection
    [Setup]  TC Setup
    TC__WebEM__Enable_Disable_Energy_Consumption_Measurement_Collectection
    [Teardown]  TC Teardown
