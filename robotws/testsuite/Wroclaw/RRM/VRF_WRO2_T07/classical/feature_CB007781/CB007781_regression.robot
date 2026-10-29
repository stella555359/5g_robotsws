*** Settings ***
Documentation   CIT regression TCs for CB007781 shall be added here for fully automated regression testing.

#Force Tags    CA_5G_RRM   STATE_SW_UPLOADED   RAN_5G   RAN_5G_FDD   RAN_5G_FDD_MP   RAN_5G_MP
#...           PY36
#...           SBTS00__WITH__CLOUD_5G_CLASSICAL_SA_4xANDROID_ASIK_ABIL_3xAHLOA_ENB

Library          taf.ue
Library          testsuite/Wroclaw/RRM/VRF_WRO2_T07/resources/testline_preparation.py
Library          testsuite/Wroclaw/RRM/VRF_WRO2_T07/classical/feature_CB007781/A/resources/keywords_7781.py

Suite Setup       prepare_testline

Suite Teardown    keywords_7781.suite_teardown

Test Teardown     keywords_7781.TC_teardown


*** Test Cases ***
CB007781_5G_A_1_Dynamic_Transform_Precoder_Switching_SA_UE_DCI_0_1_5MHz_UDP
    [Documentation]    This TC checks whether transform is correctly switched on.
    TC_CB007781_5G_A_1_Dynamic_Transform_Precoder_Switching_SA_UE_DCI_0_1_5MHz_UDP


CB007781_5G_A_2_Dynamic_Transform_Precoder_Switching_NSA_UE_DCI_0_1_ 20MHz_SRB3_TCP_Open_Loop_MIMO
    [Documentation]    This TC checks whether transform is correctly switched on.
    TC_CB007781_5G_A_2_Dynamic_Transform_Precoder_Switching_NSA_UE_DCI_0_1_20MHz_SRB3_TCP_Open_Loop_MIMO


CB007781_5G_A_3_Transform_Precoder_activation_16QAM_DMRS_Active_NSA_UE
    [Documentation]    This TC checks whether transform is correctly switched on.
    TC_CB007781_5G_A_3_Transform_Precoder_activation_16QAM_DMRS_Active_NSA_UE
