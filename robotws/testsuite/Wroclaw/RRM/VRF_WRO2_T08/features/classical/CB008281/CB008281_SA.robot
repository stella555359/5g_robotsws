*** Settings ***
Documentation
...   author: Michal Halucha
...   contact: michal.halucha@nokia.com

Resource        testsuite/Wroclaw/RRM/VRF_WRO2_T08/features/classical/CB008281/resources/test_specific_keywords_CB008281.robot
Resource        testsuite/Wroclaw/RRM/VRF_WRO2_T08/resources/testline_preparation/testline_preparation.robot

*** Test Cases ***
TC01_CB008281_Activation_and_deactivation
    [Setup]    Test Setup
    CB008281_A_B_Activation_and_Verification
    [Teardown]  Test Teardown

TC04_CB008281_Activation_with_MDT_cell_interaction
    CB008281_A_D_Activation_And_MDT_Trace_Interaction
