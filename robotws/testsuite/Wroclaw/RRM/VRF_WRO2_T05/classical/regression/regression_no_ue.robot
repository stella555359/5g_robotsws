*** Settings ***
Documentation    Suite description

Library         ute_ue
Resource        testsuite/Wroclaw/RRM/VRF_WRO2_T05/classical/regression/common_keywords/common_keywords.robot
Resource        testsuite/Wroclaw/RRM/resources/preconditions.robot
Resource        testsuite/Wroclaw/RRM/VRF_WRO2_T05/classical/5GC000900/resources/keywords.robot
Resource        testsuite/Wroclaw/RRM/VRF_WRO2_T05/classical/5GC000900/5GC000900-A.robot
Resource        testsuite/Wroclaw/RRM/VRF_WRO2_T05/classical/5GC000900/5GC000900-B.robot
Resource        testsuite/Wroclaw/RRM/VRF_WRO2_T05/classical/5GC002060/5GC002060.robot
Resource        testsuite/Wroclaw/RRM/VRF_WRO2_T05/classical/5GC001348/5GC001348-B.robot
Resource        testsuite/Wroclaw/RRM/VRF_WRO2_T05/classical/5GC002534/5GC002534-A.robot
Resource        testsuite/Wroclaw/RRM/VRF_WRO2_T05/classical/5GC002534/5GC002534-B.robot
Resource        testsuite/Wroclaw/RRM/VRF_WRO2_T05/classical/5GC002060/resources/5GC002060keysFDD.robot
Resource        testsuite/Wroclaw/RRM/VRF_WRO2_T05/classical/5GC002015/5GC002015-C.robot
Resource        testsuite/Wroclaw/RRM/VRF_WRO2_T05/classical/CB008662/CB008662-AD.robot
Resource        testsuite/Wroclaw/RRM/VRF_WRO2_T05/classical/5GC002015/resources/keywords_2015.robot
Resource        testsuite/Wroclaw/RRM/VRF_WRO2_T05/classical/CB010659/CB010659.robot
Resource        testsuite/Wroclaw/RRM/VRF_WRO2_T05/classical/regression/common_keywords/Commissioning_preparation/PreparingTestline.robot

Force Tags      CA_5G_RRM  RAN_5G  RAN_5G_FDD  RAN_5G_FDD_MP  RAN_5G_FDD_CD  RAN_5G_FDD_MP_CUSTOMER  RAN_5G_MP  STATE_SW_UPLOADED   CRT
...             RAN_5G_CRT    RAN_5GSC_CRT
...             CLOUD_5G_CLASSICAL_QC_ASIKL_ABILB1_3xAHLOA_ENB



Suite Setup     Run keywords
...             Prepare and check TL   AND
...             Setup attenuators   AND
...             Set initial attenuation

Test Setup      Run keywords
...             Require Ue    UE_1    capabilities=REAL_ANDROID_UE_NSA  AND
...             Require Ue    UE_2    capabilities=REAL_ANDROID_UE_SA  AND
...             Run Keyword and Ignore Error   Start syslog collection  AND
...             Connect to Coam   AND
...             Get SCF   AND
...             Set global variable bts id    AND
...             Get number of cells and set ID

Test Teardown   Run Keywords
...             Sleeping cell test    AND
...             keywords.Collect Snapshot  AND
...             Detach UEs Used By Test   AND
...             Run Keyword and Ignore Error   Stop syslog collection  AND
...             Verify Crash occurrence In Syslog   AND
...             Run Keyword and Ignore Error    Add scout external execution id to the reporting portal  AND
...             Disconnect coam

*** Test Cases ***
[1]5GC002015_C_26_5GC002015_C_TC_26_SA_Classical_attach_Bidir_traffic_with_2_DMRS_15Mhz_64QAM_2_2_MIMO_with_PDSCH_at_SSB_Slots
    [Tags]   SBTS00
    ...      SBTS23R4
    [1]5GC002015_C_26_5GC002015_C_TC_26_SA_Classical_attach_Bidir_traffic_with_2_DMRS_15Mhz_64QAM_2_2_MIMO_with_PDSCH_at_SSB_Slots

# [1]5GC001348_B_23_5GC001348_B_NSA_Uplink_Channel_Multeplixing_Activated_DSS_ON_1_Ue_Check_CQI_In_PUCCH_CSI_Report_Cell_BW_15M
#     [Tags]   SBTS23R4
#     [1]5GC001348_B_23_5GC001348_B_NSA_Uplink_Channel_Multeplixing_Activated_DSS_ON_1_Ue_Check_CQI_In_PUCCH_CSI_Report_Cell_BW_15M

# [1]5GC001348_B_NSA_Uplink_Channel_Multeplixing_Activated_DSS_OFF_1_Ue_Check_CQI_In_PUCCH_CSI_Report_Cell_BW_15M
#     [Tags]   SBTS23R4
#     [1]5GC001348_B_NSA_Uplink_Channel_Multeplixing_Activated_DSS_OFF_1_Ue_Check_CQI_In_PUCCH_CSI_Report_Cell_BW_15M

# [1]5GC001348_B_9_5GC001348_B_NSA_Uplink_Channel_Multeplixing_Activated_1_Ue_PUCCH_Check_Ack_Nack_Cell_BW_20M
#     [Tags]   SBTS23R4
#     [1]5GC001348_B_9_5GC001348_B_NSA_Uplink_Channel_Multeplixing_Activated_1_Ue_PUCCH_Check_Ack_Nack_Cell_BW_20M

# [1]5GC002534-B_38_PDSCH traffic at SSB slot in DSS case with PRB blanking. SA. chBW=20MHz
#     [Tags]   SBTS23R4
#     [1]5GC002534-B_38_PDSCH traffic at SSB slot in DSS case with PRB blanking. SA. chBW=20MHz

[1]CB008662-AD_1_Basic_algoritm_without_change_of_modulation_order_in_ABIL_DL_256QAM
    [Tags]   SBTS00
    ...      SBTS24R2
    ...      SBTS24R1
    ...      SBTS23R4
    [1]CB008662-AD_1_Basic_algoritm_without_change_of_modulation_order_in_ABIL_DL_256QAM

# [1][1.0] TC[1]_CB010659-A_B1_Enabling_adaptive_retransmission_in_UL_on_ABIL_Activation_Deactivation_FDD_64qam_SA
#     [Tags]    SBTS23R4
#     [1][1.0] TC[1]_CB010659-A_B1_Enabling_adaptive_retransmission_in_UL_on_ABIL_Activation_Deactivation_FDD_64qam_SA

# [1]TC[4]_CB010659-A_B1_Enabling_adaptive_retransmission_in_UL_on_ABIL_Activation_Deactivation_TDD_256qam_SA
#     [Tags]    SBTS23R4
#     [1]TC[4]_CB010659-A_B1_Enabling_adaptive_retransmission_in_UL_on_ABIL_Activation_Deactivation_TDD_256qam_SA

[1]TC[7]_CB010659-A_B2_Interworking_with_Adaptive_UL_BLER_for_spectral_efficiency_improvement_TDD_256qam_SA_CutOffMcs
    [Tags]    SBTS00
    ...       SBTS23R4
    [1]TC[7]_CB010659-A_B2_Interworking_with_Adaptive_UL_BLER_for_spectral_efficiency_improvement_TDD_256qam_SA_CutOffMcs

[1]TC[9]_CB010659-A_B3_Interworking_with_CB009198_DFT-s-OFDM_for_PUSCH-FR1_TDD_ABIL_TDD_64qam_NSA_CutOffMcs
    [Tags]    SBTS00
    ...       SBTS23R4
    [1]TC[9]_CB010659-A_B3_Interworking_with_CB009198_DFT-s-OFDM_for_PUSCH-FR1_TDD_ABIL_TDD_64qam_NSA_CutOffMcs

[1][2.0] TC[10]_CB010659-A_B4_Interworking_with_CB006137_Inter_band_FDD+TDD_FR1_UL_CA_2CCs_FDD_256qam_SA
    [Tags]   SBTS00
    ...      SBTS24R2
    ...      SBTS23R4
    [1][2.0] TC[10]_CB010659-A_B4_Interworking_with_CB006137_Inter_band_FDD+TDD_FR1_UL_CA_2CCs_FDD_256qam_SA
