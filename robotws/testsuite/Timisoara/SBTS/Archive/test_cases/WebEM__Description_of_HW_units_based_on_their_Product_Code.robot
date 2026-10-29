*** Settings ***
Resource    ../test_resources/WebEM__Description_of_HW_units_based_on_their_Product_Code.robot

*** Test Cases ***
WebEM__Description_of_HW_units_based_on_their_Product_Code
    [Setup]    TC Setup
    [Teardown]    TC Teardown
    TC__WebEM__Description_of_HW_units_based_on_their_Product_Code

