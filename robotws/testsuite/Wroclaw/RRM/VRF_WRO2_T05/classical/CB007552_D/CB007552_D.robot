*** Settings ***
Documentation
...   author: Patryk Mielcarek, Lukasz Nartowski, Wojciech Slusarczyk
...   contact: patryk.mielcarek@nokia.com, lukasz.nartowski@nokia.com, wojciech.slusarczyk@nokia.com
...   This is the TESTSUITE file for feature CB007552-D

Library         taf.ue
Library         testsuite/Wroclaw/RRM/VRF_WRO2_T07/resources/testline_preparation.py
Library         ./resources/keywords_CB007552_D.py
Resource        testsuite/Wroclaw/RRM/VRF_WRO2_T05/classical/regression/common_keywords/common_keywords.robot
Resource        testsuite/Wroclaw/RRM/VRF_WRO2_T05/classical/5GC000900/resources/keywords.robot

*** Variables ***
${resource_path_CNI-80071}    testsuite/Wroclaw/RRM/VRF_WRO2_T05/classical/CB007552_D/resources

*** Keywords ***

[1]CB007552-5G-D_5_CB007552-D#D.5.1_Two_or_more_Ues_served_with_large_and_small_BWP_profiles_in_the_cell_simultanously
    [Documentation]    Check 7552 feature attach and tput
    test_setup_CB007552
    CB007552_D
    teardown_CB007552_D
    [Teardown]  test_teardown_CB007552

[1]CB007552-5G-D_6_CB007552-D#IWK.6.1_Successful_Intra-frequency_Intra-gNB_handover
    [Documentation]    Check 7552 feature intra gNb HO - small profiles only
    test_setup_CB007552
    CB007552_D_2
    teardown_CB007552_D_2
    [Teardown]  test_teardown_CB007552

[1]CNI_78446_B_3_RRC_connection_reestablishment_via_RRC_Setup_to_the_serving_cell_to_large_BWP
    [Documentation]    Check CNI78446 Reestablishment via RRC Setup to large profile
    Connect to Coam
    Load scf for NR    ${resource_path_CNI-80071}    CNI-80071    7_16_UTE5GCLOUDT22_CNI-80071.xml
    test_setup_CB007552
    CB007552_D_3
    teardown_CB007552_D_3
    [Teardown]  test_teardown_CB007552

[1]CNI_78446_B_1_SA_intra-gNB_Handover_after_inital_RRC_Setup_with_dedicated_config_in_initialDownlinkBWP_to_large_BWP
    [Documentation]    Check CNI78446  intra gNb HO - large profiles
    Connect to Coam
    Load scf for NR    ${resource_path_CNI-80071}    CNI-80071    7_16_UTE5GCLOUDT22_CNI-80071.xml
    test_setup_CB007552
    CB007552_D_4
    teardown_CB007552_D_4
    [Teardown]  test_teardown_CB007552
