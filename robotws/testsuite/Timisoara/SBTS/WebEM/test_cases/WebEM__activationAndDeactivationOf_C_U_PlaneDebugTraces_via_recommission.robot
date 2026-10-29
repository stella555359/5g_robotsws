*** Settings ***
Documentation  This suite contains WebEM__activationAndDeactivationOf_C_U_PlaneDebugTraces_via_recommission TC

Resource  ../test_resources/WebEM__activationAndDeactivationOf_C_U_PlaneDebugTraces_via_recommission.robot


*** Test Cases ***
WebEM__activationAndDeactivationOf_C_U_PlaneDebugTraces_via_recommission
    [Setup]  TC Setup
    TC__WebEM__activationAndDeactivationOf_C_U_PlaneDebugTraces_via_recommission
    [Teardown]  TC Teardown
