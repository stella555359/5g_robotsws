*** Settings ***
Documentation
...   author:  Marcin Bednarski
...   contact: marcin.bednarski@nokia.com

Resource    testsuite/Wroclaw/RRM/VRF_WRO2_T08/features/classical/CB010850/resources/test_specific_keywords.robot

Force Tags      CA_VRF_WRO2

Test Setup      Test Setup
Test Teardown   Test Teardown

*** Test Cases ***
TC20_CB010850_Ac_IWK9_PRB Blanking with multiple BWPs ANR HO SA+NSA 25MHz HighEgde
    TC20_CB010850_Ac_IWK9_PRB_Blanking_with_multiple_BWPs_ANR_HO_SA+NSA_25MHz_HighEgde

TC22_CB010850_Ac_IWK9_PRB Blanking with multiple BWPs VoNR SA 25MHz HighEgde
    TC22_CB010850_Ac_IWK9_PRB_Blanking_with_multiple_BWPs_VoNR_SA_25MHz_HighEgde

TC27_CB010850_Ac_IWK12_Interworking with initial BWP SA+NSA 20MHz HighEgde with smallest RRC setup
    TC27_CB010850_Ac_IWK12_Interworking_with_initial_BWP_SA+NSA_20MHz_HighEgde_with_smallest_RRC_setup
