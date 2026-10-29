*** Settings ***
Documentation    Suite prepared for CBRS Stabi tests execution
...              = Maintainer =
...              CBRS Team (I_CBRS_NSP_WRO_ST_GMS@internal.nsn.com)

Resource    ./../Resources/cbrs_common_keywords.robot

Resource    ./../Tests/LTE3663/CRL26697_FeVe_02_Verify_the_behavior_of_first_heartbeat_receiving_SUSPENDED_GRANT.robot
Resource    ./../Tests/LTE3663/LTE3663_A_FeVe_06_Verify_the_behavior_of_CBSD_registration_failure_with_Blacklisted_CBSD.robot
Resource    ./../Tests/LTE3663/LTE3663_A_FeVe_33_Verify_the_CBSD_cell_parameter_change_is_successful.robot
Resource    ./../Tests/LTE3663/LTE3663_B_FeVe_03_Verify_the_CBRS_online_activation_and_de-activation_is_successful.robot
Resource    ./../Tests/LTE3663/LTE3663_Q_FeVe_11_Verify_deregistration_requested_by_SAS_is_successful.robot
Resource    ./../Tests/LTE3663/LTE3663_Q_FeVe_38_Verify_the_behavior_of_SAS_switchover_after_SAS_communication_failure.robot
Resource    ./../Tests/LTE3974/LTE3974_FeVe_05_16_Verify_the_CBRS_enhanced_measurement_is_triggered_by_grant_termination.robot
Resource    ./../Tests/LTE3974/CBRS_LTE3974_FeVe_13_Verify_CBRS_Pre-Tx_measurement_is_triggered_if_all_grants_of_one_CBSD_are_suspended.robot
Resource    ./../Tests/LTE4236-B/LTE4236_FeVe_03_Verify_the_behavior_of_both_of_cell_pMax_and_EARFCN_reconfiguration.robot
Resource    ./../Tests/LTE4236-B/LTE4236_FeVe_07_Verify_the_behavior_of_acquiring_new_grant_when_receiving_suspension_in_heartbeat_response.robot
Resource    ./../Tests/LTE4236-B/LTE4236_FeVe_11_Verify_the_behavior_of_acquiring_new_grant_when_receiving_termination_in_heartbeat_response.robot
Resource    ./../Tests/LTE4679-B/CBRS_LTE4679-B_FeVe_01_Mobility_auto_reconfiguration_for_BTS_level.robot
Resource    ./../Tests/LTE5281/CBRS_LTE5281_FeVe_03_desiredPmax_is_decreased_by_an_operator_while_not_providing_service.robot
Resource    ./../Tests/LTE5703/CBRS_LTE5703_FeVe_01_Registration_Procedure_is_successfully_modified.robot
Resource    ./../Tests/LTE5703/CBRS_LTE5703_FeVe_08_SpectrumInquiry_with_cbsdFrequencyGuidance_and_groupingConfig_in_SI_Response_at_startup.robot
Resource    ./../Tests/LTE5703/CBRS_LTE5703_FeVe_13_Grant_Procedure_with_cbsdFrequencyGuidance_and_featureDataExchange_present.robot
Resource    ./../Tests/LTE5703/CBRS_LTE5703_FeVe_28_SAS_Feature_Data_Exchange_procedure_successful.robot
Resource    ./../Tests/LTE5703/CBRS_LTE5703_FeVe_43_Suspended_grant_is_released_before_transmitExpireTime_reached.robot
Resource    ./../Tests/LTE5659/CBRS_LTE5659-A_FeVe_01_Startup_Spectrum_Selection_for_cbrsFreqType_PAL_wINNFTSV_2.robot
Resource    ./../Tests/LTE5659/CBRS_LTE5659-A_FeVe_07_Background_Query_assign_PALchannel_to_other_in_service_cell.robot

Suite Setup       Run Keywords    Suite Precondition    AND    Set Software Version
Suite Teardown    Run Keywords    Suite Postcondition

Force Tags    CLOUD_RF_AIL_B4_3628_2CL1_T4_M_98_AZQC_CBRS_1    #Testlines for Stabi
...           SBTS23R2    SBTS23R1    CDRT    CRT    RAN_4G_TDD    RAN_4G_TDD_MP    ## Branch indicator; Test Phase indicator; Scope indicator
...           QCP_RAN_VRF    QCD_MN_RAN  ## QC project; QC domain for reporting

*** Test Cases ***
CBRS_LTE5703_FeVe_01_Registration_Procedure_is_successfully_modified
    [Setup]       Test Precondition    clean_bts=false
    [Teardown]    Test Postcondition
    [Tags]        LTE5703
    CBRS_LTE5703_FeVe_01_Registration_Procedure_is_successfully_modified

CBRS_LTE5703_FeVe_08_SpectrumInquiry_with_cbsdFrequencyGuidance_and_groupingConfig_in_SI_Response_at_startup
    [Setup]       Test Precondition    clean_bts=true
    [Teardown]    Test Postcondition
    [Tags]        LTE5703
    CBRS_LTE5703_FeVe_08_SpectrumInquiry_with_cbsdFrequencyGuidance_and_groupingConfig_in_SI_Response_at_startup

CBRS_LTE5703_FeVe_13_Grant_Procedure_with_cbsdFrequencyGuidance_and_featureDataExchange_present
    [Setup]       Test Precondition    clean_bts=false
    [Teardown]    Test Postcondition
    [Tags]        LTE5703
    CBRS_LTE5703_FeVe_13_Grant_Procedure_with_cbsdFrequencyGuidance_and_featureDataExchange_present

CBRS_LTE5703_FeVe_28_SAS_Feature_Data_Exchange_procedure_successful
    [Setup]       Test Precondition    clean_bts=true
    [Teardown]    Test Postcondition
    [Tags]        LTE5703
    CBRS_LTE5703_FeVe_28_SAS_Feature_Data_Exchange_procedure_successful

CBRS_LTE5703_FeVe_43_Suspended_grant_is_released_before_transmitExpireTime_reached
    [Setup]       Test Precondition    clean_bts=false
    [Teardown]    Test Postcondition
    [Tags]        LTE5703
    CBRS_LTE5703_FeVe_43_Suspended_grant_is_released_before_transmitExpireTime_reached

CRL26697_FeVe_02_Verify_the_behavior_of_first_heartbeat_receiving_SUSPENDED_GRANT
    [Setup]       Test Precondition    clean_bts=false
    [Teardown]    Test Postcondition
    [Tags]        CRL26697
    CRL26697_FeVe_02_Verify_the_behavior_of_first_heartbeat_receiving_SUSPENDED_GRANT

LTE3663_A_FeVe_06_Verify_the_behavior_of_CBSD_registration_failure_with_Blacklisted_CBSD
    [Setup]       Test Precondition    clean_bts=false
    [Teardown]    Test Postcondition
    [Tags]        LTE3663
    LTE3663_A_FeVe_06_Verify_the_behavior_of_CBSD_registration_failure_with_Blacklisted_CBSD

LTE3663_A_FeVe_33_Verify_the_CBSD_cell_parameter_change_is_successful
    [Setup]       Test Precondition    clean_bts=false
    [Teardown]    Test Postcondition
    [Tags]        LTE3663
    LTE3663_A_FeVe_33_Verify_the_CBSD_cell_parameter_change_is_successful

LTE3663_B_FeVe_03_Verify_the_CBRS_online_activation_and_de-activation_is_successful
    [Setup]       Test Precondition    clean_bts=false
    [Teardown]    Test Postcondition
    [Tags]        LTE3663
    LTE3663_B_FeVe_03_Verify_the_CBRS_online_activation_and_de-activation_is_successful

LTE3663_Q_FeVe_11_Verify_deregistration_requested_by_SAS_is_successful
    [Setup]       Test Precondition    clean_bts=false
    [Teardown]    Test Postcondition
    [Tags]        LTE3663
    LTE3663_Q_FeVe_11_Verify_deregistration_requested_by_SAS_is_successful

LTE3663_Q_FeVe_38_Verify_the_behavior_of_SAS_switchover_after_SAS_communication_failure
    [Setup]       Test Precondition    clean_bts=false
    [Teardown]    Test Postcondition
    [Tags]        LTE3663
    LTE3663_Q_FeVe_38_Verify_the_behavior_of_SAS_switchover_after_SAS_communication_failure

LTE3974_FeVe_05_16_Verify_the_CBRS_enhanced_measurement_is_triggered_by_grant_termination
    [Setup]       Test Precondition    clean_bts=false
    [Teardown]    Test Postcondition
    [Tags]        LTE3974
    LTE3974_FeVe_05_16_Verify_the_CBRS_enhanced_measurement_is_triggered_by_grant_termination

CBRS_LTE3974_FeVe_13_Verify_CBRS_Pre-Tx_measurement_is_triggered_if_all_grants_of_one_CBSD_are_suspended
    [Setup]       Test Precondition    clean_bts=false
    [Teardown]    Test Postcondition
    [Tags]        LTE3974
    CBRS_LTE3974_FeVe_13_Verify_CBRS_Pre-Tx_measurement_is_triggered_if_all_grants_of_one_CBSD_are_suspended

LTE4236_FeVe_03_Verify_the_behavior_of_both_of_cell_pMax_and_EARFCN_reconfiguration
    [Setup]       Test Precondition    clean_bts=true
    [Teardown]    Test Postcondition
    [Tags]        LTE4236
    LTE4236_FeVe_03_Verify_the_behavior_of_both_of_cell_pMax_and_EARFCN_reconfiguration

LTE4236_FeVe_07_Verify_the_behavior_of_acquiring_new_grant_when_receiving_suspension_in_heartbeat_response
    [Setup]       Test Precondition    clean_bts=true
    [Teardown]    Test Postcondition
    [Tags]        LTE4236
    LTE4236_FeVe_07_Verify_the_behavior_of_acquiring_new_grant_when_receiving_suspension_in_heartbeat_response

LTE4236_FeVe_11_Verify_the_behavior_of_acquiring_new_grant_when_receiving_termination_in_heartbeat_response
    [Setup]       Test Precondition    clean_bts=false
    [Teardown]    Test Postcondition
    [Tags]        LTE4236
    LTE4236_FeVe_11_Verify_the_behavior_of_acquiring_new_grant_when_receiving_termination_in_heartbeat_response

CBRS_LTE4679-B_FeVe_01_Mobility_auto_reconfiguration_for_BTS_level
    [Setup]       Test Precondition    clean_bts=false
    [Teardown]    Test Postcondition
    [Tags]        LTE4679
    CBRS_LTE4679-B_FeVe_01_Mobility_auto_reconfiguration_for_BTS_level

CBRS_LTE5281_FeVe_03_desiredPmax_is_decreased_by_an_operator_while_not_providing_service
    [Setup]       Test Precondition    clean_bts=true
    [Teardown]    Test Postcondition
    [Tags]        LTE5281
    CBRS_LTE5281_FeVe_03_desiredPmax_is_decreased_by_an_operator_while_not_providing_service

CBRS_LTE5659-A_FeVe_01_Startup_Spectrum_Selection_for_cbrsFreqType_PAL_wINNFTSV_2
    [Setup]       Test Precondition    clean_bts=true
    [Teardown]    Test Postcondition
    [Tags]        LTE5659
    CBRS_LTE5659-A_FeVe_01_Startup_Spectrum_Selection_for_cbrsFreqType_PAL_wINNFTSV_2

CBRS_LTE5659-A_FeVe_07_Background_Query_assign_PALchannel_to_other_in_service_cell
    [Setup]       Test Precondition    clean_bts=true
    [Teardown]    Test Postcondition
    [Tags]        LTE5659
    CBRS_LTE5659-A_FeVe_07_Background_Query_assign_PALchannel_to_other_in_service_cell
