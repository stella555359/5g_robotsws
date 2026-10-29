*** Settings ***
Documentation  This suite contains FM__SC_Late_Startup_actForce_True TC

Resource  ../test_resources/FM__SC_late_startup_actForceAutoReset_true.robot


*** Test Cases ***
FM__SC_Late_Startup_actForce_True
    [Setup]  TC Setup
    TC__FM__SC_Late_Startup_actForce_True
    [Teardown]  TC Teardown
