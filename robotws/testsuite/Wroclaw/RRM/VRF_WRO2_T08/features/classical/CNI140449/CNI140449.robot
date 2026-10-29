*** Settings ***
Documentation
...    author: Rafal Kaczmarski
...    contact: rafal.kaczmarski@nokia.com

Resource    ./resources/test_specific_keywords.robot

Force Tags      CA_VRF_WRO2

*** Test Cases ***
[1][1.0] ANR_triggered_Xnlink_setup_after_prior_Xnlink_removal
    [Setup]    Test Setup
    CNI-140449_ANR_triggered_Xnlink_setup_after_prior_Xnlink_removal
    [Teardown]    Test Teardown
