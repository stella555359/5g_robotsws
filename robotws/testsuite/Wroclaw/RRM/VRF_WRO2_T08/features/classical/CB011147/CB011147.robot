*** Settings ***
Documentation
...   maintainer: Tomasz Sobania
...   contact: tomasz.sobania@nokia.com
Resource        testsuite/Wroclaw/RRM/VRF_WRO2_T08/features/classical/CB011147/resources/test_specific_keywords.robot

Force Tags      CA_VRF_WRO2

Suite Setup    CB011147 Suite Setup

Suite Teardown    Run Keywords    Testsuite Teardown Recommissioning    AND    Release 5g QXDM And Qcat License  ue_id=${0}

*** Variables ***
${ABSTRACT_LIB_CONFIG}      /home/ute/testline_configuration/7_16_UTE5GCLOUDT192/ue_config.yaml
${CELL_190}                 GNB_1_CELL_190
${CELL_196}                 GNB_1_CELL_196
${CELL_193}                 GNB_1_CELL_193
${CELL_197}                 GNB_1_CELL_197
${CELL_999}                 GNB_1_CELL_999
${UE_ALIAS}                 UE_1

*** Test Cases ***
[1]007_CB011147_A_B1_ALT6_Activation_of_A4_Inter_freq_measurements_after_RRCResume_procedure
    [Setup]    A_B1 Setup
    007_CB011147_A_B1_ALT6_Activation_of_A4_Inter_freq_measurements_after_RRCResume_procedure
    [Teardown]    A_B1 Teardown

[1]041_CB011147_A_IWK1_A4_measurements_are_activated_after_a4Retrytimer_expiry_with_A1_based_traffic_steering
    [Setup]    A_IWK1 Setup
    041_CB011147_A_IWK1_A4_measurements_are_activated_after_a4Retrytimer_expiry_with_A1_based_traffic_steering
    [Teardown]    A_IWK1 Teardown

[1]054_CB011147_A_IWK7_A2_measurement_report_for_mobility_to_trigger_inter-freq_A3_A5_configuration_while_a4SupervisionTimer_is_running
    [Setup]    A_IWK7 Setup
    054_CB011147_A_IWK7_A2_measurement_report_for_mobility_to_trigger_inter-freq_A3_A5_configuration_while_a4SupervisionTimer_is_running
    [Teardown]    A_IWK7 Teardown

[1]CB011147_A_B3_ALT2_Handling_of_a4RetryTimer_expiry_A4_inter-freq_meas_for_mobility_to_higher_prio_NR_activated
    [Setup]    A_B3 Setup
    CB011147_A_B3_ALT2_Handling_of_a4RetryTimer_expiry_A4_inter-freq_meas_for_mobility_to_higher_prio_NR_activated
    [Teardown]    A_B3 Teardown

[1]057_CB011147_A_B9_Last_Scell_release_leading_to_reactivation_of_A4_Inter_frequency_measurements_for_Scell_addition
    [Setup]    A_B9 Setup
    057_CB011147_A_B9_Last_Scell_release_leading_to_reactivation_of_A4_Inter_frequency_measurements_for_Scell_addition
    [Teardown]    A_B9 Teardown

[1]020_CB011147_A_B2_ALT2_a4RetryTimer_expiry_with_activation_of_RSRP_and_RSRQ
    [Setup]   A_B2 Setup
    020_CB011147_A_B2_ALT2_a4RetryTimer_expiry_with_activation_of_RSRP_and_RSRQ
    [Teardown]    A_B2 Teardown

[1]CB011147_A_EC2_ALT2_No_A4_config_at_a4RetryTimer_expiry_a4MeasActBlockTimer_is_running_at_a4RetryTimer_expiry
    [Setup]    A_EC2 Setup
    CB011147_A_EC2_ALT2_No_A4_config_at_a4RetryTimer_expiry_a4MeasActBlockTimer_is_running_at_a4RetryTimer_expiry
    [Teardown]    A_EC2 Teardown

[1]050_CB011147_A_IWK3_Mixing_A1-based_and_A4-based_SCell_Candidates_for_FR1_CA_SCell_Addition
    [Setup]    A_IWK3 Setup
    050_CB011147_A_IWK3_Mixing_A1-based_and_A4-based_SCell_Candidates_for_FR1_CA_SCell_Addition
    [Teardown]    A_IWK3 Teardown
