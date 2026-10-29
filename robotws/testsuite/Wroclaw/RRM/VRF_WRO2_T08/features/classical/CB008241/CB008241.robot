*** Settings ***
Documentation
...    author: Rafal Kaczmarski
...    contact: rafal.kaczmarski@nokia.com

Resource        testsuite/Wroclaw/RRM/VRF_WRO2_T08/resources/testline_preparation/testline_preparation.robot
Resource        testsuite/Wroclaw/RRM/VRF_WRO2_T08/features/classical/CB008241/resources/test_specific_keywords.robot
Library         testsuite/Wroclaw/RRM/VRF_WRO2_T08/features/classical/CB008241/resources/test_specific_keywords.py
Library         testsuite/Wroclaw/RRM/VRF_WRO2_T08/resources/utility/anr_knife.py
Variables       testsuite/Wroclaw/RRM/VRF_WRO2_T08/features/classical/CB008241/resources/test_specific_keywords.py


Force Tags      CA_VRF_WRO2

Suite Setup    ANR Knife
Test Teardown   Test Teardown

*** Test Cases ***
[1]CB008241_A_B2 - inter-gNB HO by CGI report - with XN configured
    [Setup]  Test Setup
    CB008241_A_B2_Inter-gNB_HO_By_CGI_Report_With_XN_Configured

[1]CB008241_A_B4 - inter-gNB HO by CGI report - add NRADJNRCELL and NRREL to NPF
    [Setup]  Test Setup
    CB008241_A_B4_Inter-gNB_HO_By_CGI_Report_Add_NRADJNRCELL_And_NRREL_To_NPF

[1]CB008241_A_B3 - inter-gNB HO by CGI report - dedicated DRX profile setup
    [Setup]  Test Setup
    CB008241_A_B3_Inter-gNB_HO_By_CGI_Report-Dedicated_DRX_Profile_Setup

[1]CB008241_B_B5 - inter-gNB HO by CGI report - actSaUeBasedInterFreqAnrNr=true real-time modification
    [Setup]  Test Setup    anr_activation_flag_off=${TRUE}
    CB008241_B_B5_Inter-gNB_HO_By_CGI_Report-actSaUeBasedInterFreqAnrNr=true_Real-Time_Modification

[1]CB008241_B_B6 - actAutoNrNbRemoval=true
    [Setup]    Test Setup    require_ue=${FALSE}    objects_removal=${TRUE}
    CB008241_B_B6_actAutoNrNbRemoval=true

[1]CB008241_B_B6 - idleTimeForNrNbRemoval value real-time modification
    [Setup]    Test Setup    objects_removal=${TRUE}
    CB008241_B_B6_idleTimeForNrNbRemoval_Value_Real-Time_Modification

[1]CB008241_B_B7 - inter-gNB HO by CGI report - no XN configured
    [Setup]  Test Setup    objects_removal=${TRUE}    unblock_cells=${TRUE}
    CB008241_B_B7_Inter-gNB_HO_By_CGI_Report-No_XN_Configured
