*** Settings ***
Documentation    Suite description
Resource        testsuite/Wroclaw/RRM/VRF_WRO2_T05/classical/CB007477/CB007477-L.robot
Resource        testsuite/Wroclaw/RRM/VRF_WRO2_T05/classical/CB007477/CB007477-C.robot
Resource        testsuite/Wroclaw/RRM/VRF_WRO2_T05/classical/CB009208/CB009208-J.robot
Resource        testsuite/Wroclaw/RRM/VRF_WRO2_T05/classical/CB009208/CB009208-C.robot
Resource        testsuite/Wroclaw/RRM/VRF_WRO2_T05/classical/CB010801/CB010801.robot
Resource        testsuite/Wroclaw/RRM/VRF_WRO2_T05/classical/CB014547/CB014547.robot
Resource        testsuite/Wroclaw/RRM/VRF_WRO2_T05/classical/regression/common_keywords/common_keywords.robot
Resource        testsuite/Wroclaw/RRM/VRF_WRO2_T05/classical/regression/common_keywords/Commissioning_preparation/PreparingTestline.robot
Resource        testsuite/Wroclaw/RRM/VRF_WRO2_T05/classical/5GC000900/resources/keywords.robot  # Beucause of Connect to coam kw, will
# be moved to common_keywords.robot

Force Tags      CA_5G_RRM  RAN_5G  RAN_5G_FDD  RAN_5G_FDD_MP  RAN_5G_FDD_CD  RAN_5G_FDD_MP_CUSTOMER  RAN_5G_MP  STATE_SW_UPLOADED   CRT
...             RAN_5GSC_CRT    RAN_5G_CRT    CLOUD_5G_CLASSICAL_QC_ASILL_ABIOB1_1xAVQL

Suite Setup     Run keywords
...             Prepare and check TL  AND
...             Require Ue    UE_1    capabilities=REAL_ANDROID_UE_1  AND
...             Require Ue    UE_2    capabilities=REAL_ANDROID_UE_2  AND
...             Require Ue    UE_3    capabilities=REAL_ANDROID_UE_3  AND
...             Require Ue    UE_4    capabilities=REAL_ANDROID_UE_4

Test Setup      Run Keywords
...             Connect To Coam   AND
...             Run Keyword and Ignore Error   Start syslog collection

Test Teardown   Run keywords
...             Make snapshot in case of error    AND
...             Disconnect coam    AND
...             Detach Ue  UE_1    AND
...             Detach Ue  UE_2    AND
...             Detach Ue  UE_3    AND
...             Detach Ue  UE_4    AND
...             Run Keyword and Ignore Error   Stop syslog collection  AND
...             Verify Crash occurrence In Syslog  AND
...             Run Keyword and Ignore Error    Add scout external execution id to the reporting portal  AND
...             Sleeping cell test

*** Test Cases ***

CB007477-L_Different_frame_structures_configuration_5GC001070_in_case_of_256QAM_modulation_and_80MHz_bandwidth_with_AVQL_RU
    [Tags]      SBTS00
    ...         SBTS24R1
    ...         SBTS23R4
    CB007477-L_Different_frame_structures_configuration_5GC001070_in_case_of_256QAM_modulation_and_80MHz_bandwidth_with_AVQL_RU

CB007477-L_Different_frame_structures_configuration_5GC001208_in_case_of_256QAM_modulation_and_100MHz_bandwidth_with_AVQL_RU
    [Tags]      SBTS00
    ...         SBTS24R1
    ...         SBTS23R4
    CB007477-L_Different_frame_structures_configuration_5GC001208_in_case_of_256QAM_modulation_and_100MHz_bandwidth_with_AVQL_RU

CB009208-5G_6_Enable_and_disable_of_PRACH_format_0_in_TDD_FR1
    [Tags]      SBTS00
    ...         SBTS24R1
    ...         SBTS23R4
    CB009208-5G_6_Enable_and_disable_of_PRACH_format_0_in_TDD_FR1

CB009208-5G_2_Check_best_and_second_used_DL_SRS_beams_with_2CSIRS
    [Tags]      SBTS00
    ...         SBTS24R1
    ...         SBTS23R4
    CB009208-5G_2_Check_best_and_second_used_DL_SRS_beams_with_2CSIRS

CB009208-5G_4_MU_scheduling_with_dynamic_DL_beam_tapering_selection
    [Tags]      SBTS00
    ...         SBTS24R1
    ...         SBTS23R4
    CB009208-5G_4_MU_scheduling_with_dynamic_DL_beam_tapering_selection

CB009208-5G_10_Switch to power saving BWP and switch to large BWP with UL and DL tput increasing SA
    [Tags]      SBTS00
    ...         SBTS24R1
    ...         SBTS23R4
    CB009208-5G_10_Switch to power saving BWP and switch to large BWP with UL and DL tput increasing SA

CB007477-C_5GC000524_A_FR1_TDD_2UEs_4x4_Activation_of_DL_MU-MIMO_feature
    [Tags]      SBTS00
    ...         SBTS24R1
    ...         SBTS23R4
    CB007477-C_5GC000524_A_FR1_TDD_2UEs_4x4_Activation_of_DL_MU-MIMO_feature

CB007477-C_5GC001695_A_64TRX_Beam_Refinement_ULDL_BeamSet_4_2_FrameType_1208_OpeningAngle_120
    [Tags]      SBTS00
    ...         SBTS24R1
    ...         SBTS23R4
    CB007477-C_5GC001695_A_64TRX_Beam_Refinement_ULDL_BeamSet_4_2_FrameType_1208_OpeningAngle_120

CB007477-C_5GC001695_A_64TRX_ULDL_BeamSet_5_1_FrameType_1208_OpeningAngle_120
    [Tags]      SBTS00
    ...         SBTS24R1
    ...         SBTS23R4
    CB007477-C_5GC001695_A_64TRX_ULDL_BeamSet_5_1_FrameType_1208_OpeningAngle_120

CB007477-C_5GC001086-B_Single_UE_access_network_with_UL_SU-MIMO_with_5GC001070_frame_structure
    [Tags]      SBTS00
    ...         SBTS24R1
    ...         SBTS23R4
    CB007477-C_5GC001086-B_Single_UE_access_network_with_UL_SU-MIMO_with_5GC001070_frame_structure

CB007477-C_5GC002200_F_check_DL_Tput_with_4_resources_good_condition_eCPRI
    [Tags]      SBTS00
    ...         SBTS24R1
    ...         SBTS23R4
    CB007477-C_5GC002200_F_check_DL_Tput_with_4_resources_good_condition_eCPRI

CB010801-SR-C_2CC_16DL8UL+1CC8DL8UL_100_50_30_DL_MU-MIMO_with_CA
    [Tags]      SBTS00
    CB010801-SR-C_2CC_16DL8UL+1CC8DL8UL_100_50_30_DL_MU-MIMO_with_CA

CB010801-SR-C_4CC8DL8UL_80_50_30_30_DL_MU-MIMO_with_CA
    [Tags]      SBTS00
    CB010801-SR-C_4CC8DL8UL_80_50_30_30_DL_MU-MIMO_with_CA

CB014547_SR_B1_Habrok_64TRX_AVQL_RU_Supports_up_to_250MHz_oBW_16DL8UL_with_Srs_SubbandBm_on
    CB014547_SR_B1_Habrok_64TRX_AVQL_RU_Supports_up_to_250MHz_oBW_16DL8UL_with_Srs_SubbandBm_on

CB014547_SR_B1_Habrok_64TRX_AVQL_RU_Supports_up_to_300MHz_oBW_8DL4UL_with_SRS_SubbandBm_on
    CB014547_SR_B1_Habrok_64TRX_AVQL_RU_Supports_up_to_300MHz_oBW_8DL4UL_with_SRS_SubbandBm_on
