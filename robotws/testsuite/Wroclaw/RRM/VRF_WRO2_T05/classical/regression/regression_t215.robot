*** Settings ***
Documentation    Suite description

Library         ute_ue
Resource        testsuite/Wroclaw/RRM/VRF_WRO2_T05/classical/CB008055/CB008055-A.robot
Resource        testsuite/Wroclaw/RRM/VRF_WRO2_T05/classical/CB008055/CB008055-B.robot
Resource        testsuite/Wroclaw/RRM/VRF_WRO2_T05/classical/CB008055/CB008055-C.robot
Resource        testsuite/Wroclaw/RRM/VRF_WRO2_T05/classical/CB008055/CB008055-D.robot
Resource        testsuite/Wroclaw/RRM/VRF_WRO2_T05/classical/CB008055/CB008055-W.robot
Resource        testsuite/Wroclaw/RRM/VRF_WRO2_T05/classical/CB010741/CB010741-A.robot
Resource        testsuite/Wroclaw/RRM/VRF_WRO2_T05/classical/CB009262/CB009262-E.robot
Resource        testsuite/Wroclaw/RRM/VRF_WRO2_T05/classical/CB009262/CB009262-F.robot
Resource        testsuite/Wroclaw/RRM/VRF_WRO2_T05/classical/CB009262/CB009262-I.robot
Resource        testsuite/Wroclaw/RRM/VRF_WRO2_T05/classical/CB012559/CB012559-QC.robot
Resource        testsuite/Wroclaw/RRM/VRF_WRO2_T05/classical/CB014151/CB014151.robot
Resource        testsuite/Wroclaw/RRM/VRF_WRO2_T05/classical/CNI-130245-C/CNI-130245-C.robot
Resource        testsuite/Wroclaw/RRM/VRF_WRO2_T05/classical/CNI-131238-C/CNI-131238-C.robot
Resource        testsuite/Wroclaw/RRM/VRF_WRO2_T05/classical/regression/common_keywords/common_keywords.robot
Resource        testsuite/Wroclaw/RRM/VRF_WRO2_T05/classical/regression/common_keywords/Commissioning_preparation/PreparingTestline.robot
Resource        testsuite/Wroclaw/RRM/VRF_WRO2_T05/classical/5GC000900/resources/keywords.robot  # connect to coam kw

Force Tags      CRT    CLOUD_5G_CLASSICAL_QC_ASIML_ABIPB1_1xAVHA_1xAVQL_1xAEHC_2xAHFIB_2xAHLOA

Suite Setup     Run keywords
# ...             Prepare and check TL  AND
...             Require Ue    UE_1    capabilities=REAL_ANDROID_UE_1    AND
...             Require Ue    UE_2    capabilities=REAL_ANDROID_UE_2    AND
...             Require Ue    UE_3    capabilities=REAL_ANDROID_UE_3

Test Setup      Run keywords
...             Connect To Coam    AND
...             Run keyword and ignore error    Delete active DCAP trace for BTS  10.44.92.33    AND
...             Run Keyword and Ignore Error   Start syslog collection

Test Teardown   Run keywords
#...             Make snapshot in case of error    AND
...             Disconnect coam    AND
...             Run Keyword and Ignore Error    Detach Ue     UE_1      AND
...             Run Keyword and Ignore Error    Detach Ue     UE_2      AND
...             Run Keyword and Ignore Error    Detach Ue     UE_3      AND
...             Run keyword and ignore error    Stop syslog collection    AND
...             Verify Crash occurrence In Syslog  AND
...             Run Keyword and Ignore Error    Add scout external execution id to the reporting portal  AND
...             Sleeping cell test

*** Test Cases ***
[1]CB009262-SR-F_5GC000501_Graceful_Cell_Shutdown_with_AVHA_RU
    [1]CB009262-SR-F_5GC000501_Graceful_Cell_Shutdown_with_AVHA_RU

[1]CB009262-SR-E_5GC000545_C_Dynamic_transform_precoder_switching_successfully_in_SA_mode_with_AVHA_RU
    [1]CB009262-SR-E_5GC000545_C_Dynamic_transform_precoder_switching_successfully_in_SA_mode_with_AVHA_RU

[1]CB009262-SR-I_2CC_Carier_Aggregation_Successful_operation_of_feature_activation_and_deactivation_with_defined_CA_relation
    [1]CB009262-SR-I_2CC_Carier_Aggregation_Successful_operation_of_feature_activation_and_deactivation_with_defined_CA_relation

[1]CNI-130245-C-Config_and_block_periodic_act_of_interfreq_A4_measurement_for_mobility_to_higher_prio_NR_freq_NSA
    [1]CNI-130245-C-Config_and_block_periodic_act_of_interfreq_A4_measurement_for_mobility_to_higher_prio_NR_freq_NSA

[1]CNI-131238-C-Config_of_interfreq_A4_measurement_for_mobility_to_higher_prio_NR_freq_SA
    [1]CNI-131238-C-Config_of_interfreq_A4_measurement_for_mobility_to_higher_prio_NR_freq_SA

[1]CB008055-A#B5_Buffer_Based_SCell_Activation_and_Flow_control_for_5CC_DL_CA_with_FDD_PCell_and_4_FDD_SCells
    [1]CB008055-A#B5_Buffer_Based_SCell_Activation_and_Flow_control_for_5CC_DL_CA_with_FDD_PCell_and_4_FDD_SCells

[1]CB008055-B#B6_A4_based_NR_FR1_SCell_addition_for_6CC_DL_CA
    [1]CB008055-B#B6_A4_based_NR_FR1_SCell_addition_for_6CC_DL_CA

[1]CB008055-W#11209_5G_DL_peak_Throughput_per_UE
    [1]CB008055-W#11209_5G_DL_peak_Throughput_per_UE

[1]CB008055-C#B3_Buffer_based_SCell_activation_for_5CC_6CC_FDD_DL_CA_and_2CC_FDD_UL_CA_configuration
    [1]CB008055-C#B3_Buffer_based_SCell_activation_for_5CC_6CC_FDD_DL_CA_and_2CC_FDD_UL_CA_configuration

[1]CB008055-D#B1_A2_based_PCell_change_for_SA_call_(5CC_FDD_DL_CA)
    [1]CB008055-D#B1_A2_based_PCell_change_for_SA_call_(5CC_FDD_DL_CA)

[1]CB010741_A_B9_Ul_Buffer_Triggered_A1_And_A4_Measurement_Based_SCell_Addition
    [1]CB010741_A_B9_Ul_Buffer_Triggered_A1_And_A4_Measurement_Based_SCell_Addition

CB014151-A#B6_Multiple_candidate_SDL_SCells_(2_candidates)
    CB014151-A#B6_Multiple_candidate_SDL_SCells_(2_candidates)

CB014151-B#B5A1_SCell_release_due_to_SCell_RLQ_with_sCellExcludelistTimerFr1_disabled
    CB014151-B#B5A1_SCell_release_due_to_SCell_RLQ_with_sCellExcludelistTimerFr1_disabled

CB014151-C#B2_PSCell_Change_not_possible_(A1_triggered)
    CB014151-C#B2_PSCell_Change_not_possible_(A1_triggered)
