*** Settings ***
Documentation    Regression CA.
...              ATTENTION! READ BEFORE EXECUTING UTE SINGLE RUN:
...              MAKE SURE KW "LOAD SCF FOR NR" IS NOT COMMENTED! IF SO, RUN TEST THAT COMMISSIONS SCF BEFORE IT.
...              Note: if CA is not established, consider lowering thresholds for A1 events.

Library         ute_ue
Library         ta5g_delta     WITH NAME  delta
Library         ta5g_enb       WITH NAME  initial
Resource        testsuite/Wroclaw/RRM/VRF_WRO2_T05/classical/regression/common_keywords/common_keywords.robot
Resource        testsuite/Wroclaw/RRM/VRF_WRO2_T05/classical/regression/common_keywords/Commissioning_preparation/PreparingTestline.robot
Resource        testsuite/Wroclaw/RRM/resources/preconditions.robot
Resource        testsuite/Wroclaw/RRM/VRF_WRO2_T05/classical/5GC000900/resources/keywords.robot
Resource        testsuite/Wroclaw/RRM/VRF_WRO2_T05/classical/5GC001390/5GC001390-L.robot
Resource        testsuite/Wroclaw/RRM/VRF_WRO2_T05/classical/5GC002329/5GC002329.robot
Resource        testsuite/Wroclaw/RRM/VRF_WRO2_T05/classical/5GC002640/5GC002640-AA.robot
Resource        testsuite/Wroclaw/RRM/VRF_WRO2_T05/classical/5GC002640/5GC002640-AC.robot
Resource        testsuite/Wroclaw/RRM/VRF_WRO2_T05/classical/5GC002640/5GC002640-E.robot
Resource        testsuite/Wroclaw/RRM/VRF_WRO2_T05/classical/5GC002640/5GC002640-F.robot
Resource        testsuite/Wroclaw/RRM/VRF_WRO2_T05/classical/5GC002640/5GC002640-H.robot
Resource        testsuite/Wroclaw/RRM/VRF_WRO2_T05/classical/CB008531/CB008531.robot
Resource        testsuite/Wroclaw/RRM/VRF_WRO2_T05/classical/CB007873/CB007873.robot
Resource        testsuite/Wroclaw/RRM/VRF_WRO2_T05/classical/CB008533/CB008533-A.robot
Resource        testsuite/Wroclaw/RRM/VRF_WRO2_T05/classical/CB008533/CB008533-C.robot
Resource        testsuite/Wroclaw/RRM/VRF_WRO2_T05/classical/CB008140/CB008140-CD.robot
Resource        testsuite/Wroclaw/RRM/VRF_WRO2_T05/classical/CB008140/CB008140-CB.robot
Resource        testsuite/Wroclaw/RRM/VRF_WRO2_T05/classical/CB008140/CB008140-CF.robot
Resource        testsuite/Wroclaw/RRM/VRF_WRO2_T05/classical/CB008140/CB008140-FA.robot
Resource        testsuite/Wroclaw/RRM/VRF_WRO2_T05/classical/CB008140/CB008140-JA.robot
Resource        testsuite/Wroclaw/RRM/VRF_WRO2_T05/classical/CB008140/CB008140-JD.robot
Resource        testsuite/Wroclaw/RRM/VRF_WRO2_T05/classical/CB008140/CB008140-JF.robot
Resource        testsuite/Wroclaw/RRM/VRF_WRO2_T05/classical/CB008140/CB008140-JE.robot
Resource        testsuite/Wroclaw/RRM/VRF_WRO2_T05/classical/CB008950/CB008950-D.robot
Resource        testsuite/Wroclaw/RRM/VRF_WRO2_T05/classical/CB009103/CB009103-B.robot
Resource        testsuite/Wroclaw/RRM/VRF_WRO2_T05/classical/CB009103/CB009103-E.robot
Resource        testsuite/Wroclaw/RRM/VRF_WRO2_T05/classical/CB009103/CB009103-G.robot
Resource        testsuite/Wroclaw/RRM/VRF_WRO2_T05/classical/CB012559/CB012559-QC.robot

Force Tags      CA_5G_RRM  RAN_5G  RAN_5G_FDD  RAN_5G_FDD_MP  RAN_5G_FDD_CD  RAN_5G_FDD_MP_CUSTOMER  RAN_5G_MP  RAN_5G_MP_CUSTOMER
...             RAN_5G_CUSTOMER  RAN_5GSC_CRT  CLOUD_5G_CLASSICAL_ASIK_ABIL_FULLRACK_TMO_5  STATE_SW_UPLOADED

Suite Setup     Run keywords
# ...             Prepare and check TL   AND
...             Require Ue    UE_1    capabilities=REAL_ANDROID_UE_SA_SAMSUNG1  AND
...             Require Ue    UE_2    capabilities=REAL_ANDROID_UE_SA_SAMSUNG2  AND
...             Require Ue    UE_3    capabilities=REAL_ANDROID_UE_SA_SAMSUNG3  AND
...             Require Ue    UE_4    capabilities=REAL_ANDROID_UE_SA_QUALCOMM  AND
...             Setup attenuators   AND
...             Set initial attenuation    AND
...             initial.get_scfc_file    output_filepath=${OUTPUT_DIR}/initial_commissioning.xml

Test Setup      Run Keyword
...             Connect to Coam

Test Teardown   Run Keywords
...             Sleeping cell test    AND
# ...             Make snapshot in case of error    AND
...             Run keyword and ignore error    Delete active DCAP trace for BTS  10.44.76.47  AND
...             Disconnect coam      AND
...             Run Keyword and Ignore Error    Add scout external execution id to the reporting portal  AND
...             Run keyword and ignore error    Stop syslog collection  AND
...             Run keyword and ignore error    Detach Ue     UE_1      AND
...             Run keyword and ignore error    Detach Ue     UE_2      AND
...             Run keyword and ignore error    Detach Ue     UE_3      AND
...             Run keyword and ignore error    Detach Ue     UE_4

*** Test Cases ***
# [1]5GC001390_L_02_Inter-band_FDD_-_Inter-band_FDD_-_FR1_TDD_CA_for_SA_UE
#     [Tags]   CRT
#     ...      SBTS24R2
#     ...      SBTS24R1
#     ...      SBTS23R4
#     [1]5GC001390_L_02_Inter-band_FDD_-_Inter-band_FDD_-_FR1_TDD_CA_for_SA_UE

# [1]5GC002329_AD_UE_configured_with_both_TDD-FDD_FR1_CA_and_DRX_in_SA_mode_with_VoNR
#     [Tags]   CRT
#     ...      SBTS23R4
#     [1]5GC002329_AD_UE_configured_with_both_TDD-FDD_FR1_CA_and_DRX_in_SA_mode_with_VoNR

# [1]5GC002329_AE_Single_UE_full_mobility_support_for_UE_which_has_TDD_FR1_and_FDD_CA_configured_for_SA_call_(incoming_UE)
#     [Tags]   CRT
#     ...      SBTS23R4
#     [1]5GC002329_AE_Single_UE_full_mobility_support_for_UE_which_has_TDD_FR1_and_FDD_CA_configured_for_SA_call_incoming_UE

# [1]CB008531-5G-D_03_InterFrequencyInterGnb_PCell-HO_different_target_gNB_neighbors
#     [Tags]   CRT
#     ...      SBTS23R4
#     [1]CB008531-5G-D_03_InterFrequencyInterGnb_PCell-HO_different_target_gNB_neighbors

# [1]CB007873_5G_I_02_Inter-band_FDD_-_FR1_TDD_DL_CA_for_NSA_UE
#     [Tags]   CRT
#     ...      SBTS23R4
#    [1]CB007873_5G_I_02_Inter-band_FDD_-_FR1_TDD_DL_CA_for_NSA_UE

# [1] CA blind addition, beamforming, no beam refinement, pCSI reporting
#     [Tags]   CRT
#     [1]5GC002640-AA_09_#B4.A3.2 UE call 3CC[F+T+T] CA blind addition, beamforming, no beam refinement, pCSI reporting

# [1][1.0] 5GC002640-AC_03_#B2 [F+F+T] A1 based Scell Addition, Intra-gNB inter-freq HO
#     [Tags]   CRT
#     ...      SBTS23R4
#     [1][1.0] 5GC002640-AC_03_#B2 [F+F+T] A1 based Scell Addition, Intra-gNB inter-freq HO

# [1][1.0] A2-SCell triggered SCell realese. Different thresholds
#     [Tags]   CRT
#     ...      SBTS23R4
#     [1]5GC002640-AC_06_#B3.1 [F+F+T] A2-SCell triggered SCell realese. Different thresholds

# [1][1.0] 5GC002640-H_32_#B2 SCell change based on A1-PCell measurement for SA UE from 3CC F+F+F CA to 3CC F+T+T CA
#     [Tags]   CRT
#     ...      SBTS23R4
#     [1][1.0] 5GC002640-H_32_#B2 SCell change based on A1-PCell measurement for SA UE from 3CC F+F+F CA to 3CC F+T+T CA

# [1]5GC002640-E_21_#B2.1 [F+F+T] UE call 3CC CA with intra-L2RT inter-core architecture, ABIL
#     [Tags]   CRT
#     ...      SBTS24R1
#     ...      SBTS23R4
#     [1]5GC002640-E_21_#B2.1 [F+F+T] UE call 3CC CA with intra-L2RT inter-core architecture, ABIL

# [1][1.0] 5GC002640-F_26_#B1.3 [F+F+T] Single UE call 3CC CA interworking with DSSp3
#     [Tags]   CRT
#     ...      SBTS23R4
#     [1][1.0] 5GC002640-F_26_#B1.3 [F+F+T] Single UE call 3CC CA interworking with DSSp3

# [1][16]_CB008533-A#_B11-1_Single_UE_Call_A1-PCell_Measurement_based_SCell_Addition_mobility_interfrequency_HO_from_2CC_to_3CC_to_4CC_to_2CC_CA
#     [Tags]   CRT
#     ...      SBTS23R4
#     [1][16]_CB008533-A#_B11-1_Single_UE_Call_A1-PCell_Measurement_based_SCell_Addition_mobility_interfrequency_HO_from_2CC_to_3CC_to_4CC_to_2CC_CA

# [1]5GC002640-H_30_#B1.1 SCell change based on A1-PCell measurement for SA UE from 3CC F+T+T CA with FDD PCell to 2CC F+F CA
#     [Tags]   CRT
#     ...      SBTS00
#     ...      SBTS24R2
#     ...      SBTS24R1
#     ...      SBTS23R4
#     [1]5GC002640-H_30_#B1.1 SCell change based on A1-PCell measurement for SA UE from 3CC F+T+T CA with FDD PCell to 2CC F+F CA

[1][6]_CB008533-A#B5-1_Single_UE_FDD_+_FR1_TDD_4CC_DL_CA_2F+2T_interworking_with_DSS_PCell_(with_DSS)+FDD_SCell_(non_DSS)+TDD_SCell+TDD_SCell
    [Tags]   CRT
    ...      SBTS00
    ...      SBTS24R2
    ...      SBTS24R1
    ...      SBTS23R4
    [1][6]_CB008533-A#B5-1_Single_UE_FDD_+_FR1_TDD_4CC_DL_CA_2F+2T_interworking_with_DSS_PCell_(with_DSS)+FDD_SCell_(non_DSS)+TDD_SCell+TDD_SCell

[1][1.0] CB008533-C#B2A Single UE Call - pCSI reporting configuration for 4CC 2F+ 2T DL CA with common PUCCH resource ID
    [Tags]   CRT
    ...      SBTS00
    ...      SBTS24R2
    ...      SBTS23R4
    [1][1.0] CB008533-C#B2A Single UE Call - pCSI reporting configuration for 4CC 2F+ 2T DL CA with common PUCCH resource ID

[1]CB012559-QC_05_TF_A1ScellAddition_BufferScellActivation_A2ScellRealese
    [1]CB012559-QC_05_TF_A1ScellAddition_BufferScellActivation_A2ScellRealese

[1]CB008533-A#_B11-1x_Single_UE_Call_A1-PCell_Measurement_based_SCell_Addition_mobility_interGNB_HO_via_Xn_link
    [Tags]   CRT
    ...      SBTS00
    ...      SBTS24R2
    ...      SBTS24R1
    ...      SBTS23R4
    [1]CB008533-A#_B11-1x_Single_UE_Call_A1-PCell_Measurement_based_SCell_Addition_mobility_interGNB_HO_via_Xn_link

[1]CB008140-CD#B1A1_[F+F+T+T]_Event_A2_measurement_based_triggered_inter-gNB_CA_Partial_SCell_release_SA_4CC_CA
    [Tags]   CRT
    ...      SBTS00
    ...      SBTS24R2
    ...      SBTS24R1
    ...      SBTS23R4
    [1]CB008140-CD#B1A1_[F+F+T+T]_Event_A2_measurement_based_triggered_inter-gNB_CA_Partial_SCell_release_SA_4CC_CA

[1]CB008140-CB#B1_[F+F+T]_Successful_addition_of_a_new_DRB_in_the_ext-gNB_after_the_setup_of_a_new_PDU
    [Tags]   CRT
    ...      SBTS00
    ...      SBTS24R2
    ...      SBTS24R1
    ...      SBTS23R4
    [1]CB008140-CB#B1_[F+F+T]_Successful_addition_of_a_new_DRB_in_the_ext-gNB_after_the_setup_of_a_new_PDU

# [1]CB008140-CF#B2A2_[F+F+T+T]_SCell_re-activation_for_inter-gNB_4CC_DL_CA_due_to_recovery_of_Xp-U_link_to_available
#     [Tags]   CRT
#     ...      SBTS00
#     ...      SBTS24R2
#     ...      SBTS24R1
#     ...      SBTS23R4
#     [1]CB008140-CF#B2A2_[F+F+T+T]_SCell_re-activation_for_inter-gNB_4CC_DL_CA_due_to_recovery_of_Xp-U_state_to_available

[1]CB008140-FA#B1A10_[F+F+F+T]_Partial_SCell_addition_success_for_one_SA_more_than_one_SCell_candidate_to_be_added
    [Tags]   CRT
    ...      SBTS00
    ...      SBTS24R2
    ...      SBTS24R1
    ...      SBTS23R4
    [1]CB008140-FA#B1A10_[F+F+F+T]_Partial_SCell_addition_success_for_one_SA_more_than_one_SCell_candidate_to_be_added

[1]CB009103-B_PMO_B1_Counter_update_for_stepwise_ext-SCell_add_failure_A1_and_A4_with_configured_intra-SCells
    [1]CB009103-B_PMO_B1_Counter_update_for_stepwise_ext-SCell_add_failure_A1_and_A4_with_configured_intra-SCells

# [1]CB009103_E_B4_Deactivate_Ext_SCell_Directly_If_Very_Large_Delay_Is_Detected_No_Impact_On_DL_UL_SCell
#     [1]CB009103_E_B4_Deactivate_Ext_SCell_Directly_If_Very_Large_Delay_Is_Detected_No_Impact_On_DL_UL_SCell

[1]USCB009103-G_B4_6CC_CA_is_supported_with_mixed_intra-SCell(s)_and_ext-SCell(s)
    [1]USCB009103-G_B4_6CC_CA_is_supported_with_mixed_intra-SCell(s)_and_ext-SCell(s)

[1]CB008140-JA#B1A3_NG-C_link_locked_with_4UEs_with_2CC&3CC
    [Tags]   CRT
    ...      SBTS00
    ...      SBTS23R4
    [1]CB008140-JA#B1A3_NG-C_link_locked_with_4UEs_with_2CC&3CC

# [1]CB008140-AB#B3_Unsuccessful_XP_setup_procedure_for_the_inter-gNB_CA_BTS_startup_scenario
#     [Tags]   CRT
#     ...      SBTS00
#     ...      SBTS23R4
#     [1]CB008140-AB#B3_Unsuccessful_XP_setup_procedure_for_the_inter-gNB_CA_BTS_startup_scenario

# [1]CB008140-JD#B3_Xn-_link_used_for_inter-gNB_CA_locked_by_operator
#     [Tags]   CRT
#     ...      SBTS00
#     ...      SBTS23R4
#     [1]CB008140-JD#B3_Xn-_link_used_for_inter-gNB_CA_locked_by_operator

# [1]CB008140-JD#B4_Unlock_of_Xn-C_link
#     [Tags]   CRT
#     ...      SBTS00
#     ...      SBTS23R4
#     [1]CB008140-JD#B4_Unlock_of_Xn-C_link

[1]CB008140-JF#PM1_for_measuring_RLC_PDUs_Volume_sent_over_CA_Procedure_2a
    [Tags]   CRT
    ...      SBTS00
    ...      SBTS23R4
    [1]CB008140-JF#PM1_for_measuring_RLC_PDUs_Volume_sent_over_CA_Procedure_2a
