*** Settings ***
Documentation
...    author: Rafal Kaczmarski
...    contact: rafal.kaczmarski@nokia.com

Resource    ./resources/test_specific_keywords.robot

Force Tags      CA_VRF_WRO2

*** Test Cases ***
[1]1_CNI-117433_A_B1_SA_ANR_Online_modification_of_ANR_learning_related_parameters_Intra-NR_UE_based
    [Setup]    Test Setup
    CNI-117433_ANR_triggered_Xnlink_setup_after_prior_Xnlink_removal
    [Teardown]    Test Teardown
