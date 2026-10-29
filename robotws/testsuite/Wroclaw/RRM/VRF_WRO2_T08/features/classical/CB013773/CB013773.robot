*** Settings ***
Documentation
...   author: Marcin Bednarski
...   contact: marcin.bednarski@nokia.com

Library        taf.ue
Library        testsuite/Wroclaw/RRM/VRF_WRO2_T08/features/classical/CB013773/resources/test_specific_keywords.py

Test Setup       Test Setup
Test Teardown    Test Teardown

*** Test Cases ***
CB013773_A_B1_Lyapunov_smoothing_Activated
    TC01_CB013773_A_B1_Lyapunov_smoothing_Activated
