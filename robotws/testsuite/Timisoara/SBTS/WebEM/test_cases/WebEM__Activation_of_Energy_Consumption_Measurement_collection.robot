*** Settings ***
Documentation  This suite contains WebEM__Activation_of_Energy_Consumption_Measurement_collection TC

Resource  ../test_resources/WebEM__Activation_of_Energy_Consumption_Measurement_collection.robot


*** Test Cases ***
WebEM__Activation_of_Energy_Consumption_Measurement_collection
    [Setup]  TC Setup
    TC__WebEM__Activation_of_Energy_Consumption_Measurement_collection
    [Teardown]  TC Teardown
