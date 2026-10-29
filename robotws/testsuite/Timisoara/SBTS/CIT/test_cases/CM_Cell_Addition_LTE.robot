*** Settings ***
Documentation  This suite contains CM_Cell_Addition_LTE TC

Resource  ../test_resources/CM_Cell_Addition_LTE.robot


*** Test Cases ***
CM_Cell_Addition_LTE
    [Setup]  TC Setup
    TC__CM_Cell_Addition_LTE
    [Teardown]  TC Teardown
