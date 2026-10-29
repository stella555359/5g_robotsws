*** Settings ***
Documentation
...    author: Rafal Kaczmarski, Lukasz Klosinski
...    contact: rafal.kaczmarski@nokia.com, lukasz.klosinski@nokia.com

Resource    ./resources/test_specific_keywords.robot
Resource    testsuite/Wroclaw/RRM/VRF_WRO2_T08/resources/testline_preparation/testline_preparation.robot
Library     testsuite/Wroclaw/RRM/VRF_WRO2_T08/resources/utility/anr_knife.py

Force Tags      CA_VRF_WRO2
Suite Setup    ANR Knife

*** Variables ***
${ABSTRACT_LIB_CONFIG}   /home/ute/testline_configuration/7_16_UTE5GCLOUDT302/ue_config.yaml
${CELL_1_ALIAS}            GNB_1_CELL_1
${CELL_2_ALIAS}            GNB_1_CELL_2
${CELL_3_ALIAS}            GNB_2_CELL_1
${CELL_4_ALIAS}            GNB_2_CELL_2

*** Test Cases ***
[1]5GC001296-D_007_C_B2_Automatic_Neighbor_Removal_online_enable_and_change_of_removal_time
    [Setup]    Test Setup    d_tc07=${TRUE}    require_ue=${TRUE}    disable_removal=${TRUE}
    [1]5GC001296-D_007_C_B2_Automatic_Neighbor_Removal_online_enable_and_change_of_removal_time
    [Teardown]    Test Teardown

[1]5GC001296-D_001_B_B1_Successful_Intra_Frequency_Inter_Du_PCI_Resolution_And_Neighbour_Addition_Without_SRB3
    [Setup]    Test Setup    d_tc01=${TRUE}    require_ue=${TRUE}    syslog=${TRUE}
    [1]5GC001296-D_001_B_B1_Successful_Intra_Frequency_Inter_Du_PCI_Resolution_And_Neighbour_Addition_Without_SRB3
    [Teardown]    Test Teardown

[1]5GC001296-D_008_D_EC1_NSA_Measurement_report_handling_when_ANR_profile_not_configured
    [Setup]  Test Setup    d_tc08=${TRUE}    require_ue=${TRUE}    syslog=${TRUE}
    [1]5GC001296-D_008_D_EC1_NSA_Measurement_report_handling_when_ANR_profile_not_configured
    [Teardown]  Test Teardown
