*** Settings ***
Documentation
...    author: Michal Halucha
...    contact: michal.halucha@nokia.com


Resource    ./resources/test_specific_keywords_cloud.robot

*** Variables ***
${ABSTRACT_LIB_CONFIG}    /home/ute/testline_configuration/7_16_UTE5GCLOUD_CLOUDT1/att.yaml

*** Test Cases ***
CB008409_A_1_CSI_IM_randomization_in_FDD_cell_with_PDL_rule_verification_feature_activation_and_deactivation
    [Setup]  Test Setup
    CB008409_A_1_CSI_IM_randomization_in_FDD_cell_with_PDL_rule_verification_feature_activation_and_deactivation
    [Teardown]    Teardown

CB008409_B_2_Enhanced_ReTransmission_when_SRB1_and_SRB2_is_being_retransmitted_with_non_VoNR_UEs
    [Setup]  Test Setup
    CB008409_B_2_Enhanced_ReTransmission_when_SRB1_and_SRB2_is_being_retransmitted_with_non_VoNR_UEs
    [Teardown]    Teardown
