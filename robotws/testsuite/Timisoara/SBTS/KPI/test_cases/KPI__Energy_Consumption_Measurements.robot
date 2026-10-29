*** Settings ***
Documentation  This suite contains KPI__Energy_Consumption_Measurements TC

Resource  ../test_resources/KPI__Energy_Consumption_Measurements.robot


*** Test Cases ***
TC__Energy_Consumption_Measurements
    [Setup]  TC Setup
    KPI__Energy_Consumption_Measurements
    [Teardown]  TC Teardown
