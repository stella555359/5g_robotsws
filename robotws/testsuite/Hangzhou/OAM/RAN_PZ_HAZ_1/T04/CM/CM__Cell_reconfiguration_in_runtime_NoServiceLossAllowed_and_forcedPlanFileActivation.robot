*** Settings ***
Documentation       Test suite for SyVe_CM
...                 Author: Xu Yuyan
...                 Contact: yuyan.xu@nokia-sbell.com
# Test Timeout    3h
Variables         ../test_line_specific/SBTS_SYVE_1813/My_Variables.py
Resource          ../test_resources/CM/CM__Cell_reconfiguration_in_runtime_NoServiceLossAllowed_and_forcedPlanFileActivation.robot

*** Test Cases ***
CM__Cell_reconfiguration_in_runtime_NoServiceLossAllowed_and_forcedPlanFileActivation
    [Tags]    SRAN    QCD_MN_RAN    QCP_RAN_VRF    QC_123158    CA_VRF_OAM    CLOUD_LO_CUS_LO
    [Setup]    Common Test Setup SBTS
    CM__Cell_reconfiguration_in_runtime_NoServiceLossAllowed_and_forcedPlanFileActivation
    [Teardown]    Case TearDown
