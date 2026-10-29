*** Settings ***
Documentation    CBRS CRT suite for eCPRI AEQM configuration, introduced in CB007600 (SBTS22R3 onwards)
...              = Maintainer = CBRS Team (I_CBRS_NSP_WRO_ST_GMS@internal.nsn.com)


Resource    ./../Resources/cbrs_common_keywords.robot

Resource    ./../Tests/LTE3663/CRL26697_FeVe_02_Verify_the_behavior_of_first_heartbeat_receiving_SUSPENDED_GRANT.robot

Resource    ./../Tests/LTE3663/LTE3663_B_FeVe_03_Verify_the_CBRS_online_activation_and_de-activation_is_successful.robot
Resource    ./../Tests/LTE3663/LTE3663_Q_FeVe_11_Verify_deregistration_requested_by_SAS_is_successful.robot
Resource    ./../Tests/LTE3663/LTE3663_Q_FeVe_38_Verify_the_behavior_of_SAS_switchover_after_SAS_communication_failure.robot

Resource    ./../Tests/LTE4236-B/LTE4236_FeVe_03_Verify_the_behavior_of_both_of_cell_pMax_and_EARFCN_reconfiguration.robot
Resource    ./../Tests/LTE4236-B/LTE4236_FeVe_07_Verify_the_behavior_of_acquiring_new_grant_when_receiving_suspension_in_heartbeat_response.robot
Resource    ./../Tests/LTE4236-B/LTE4236_FeVe_11_Verify_the_behavior_of_acquiring_new_grant_when_receiving_termination_in_heartbeat_response.robot

Resource    ./../Tests/LTE5281/CBRS_LTE5281_FeVe_03_desiredPmax_is_decreased_by_an_operator_while_not_providing_service.robot

Resource    ./../Tests/LTE5703/CBRS_LTE5703_FeVe_01_Registration_Procedure_is_successfully_modified.robot
Resource    ./../Tests/LTE5703/CBRS_LTE5703_FeVe_08_SpectrumInquiry_with_cbsdFrequencyGuidance_and_groupingConfig_in_SI_Response_at_startup.robot
Resource    ./../Tests/LTE5703/CBRS_LTE5703_FeVe_13_Grant_Procedure_with_cbsdFrequencyGuidance_and_featureDataExchange_present.robot
Resource    ./../Tests/LTE5703/CBRS_LTE5703_FeVe_28_SAS_Feature_Data_Exchange_procedure_successful.robot
Resource    ./../Tests/LTE5703/CBRS_LTE5703_FeVe_43_Suspended_grant_is_released_before_transmitExpireTime_reached.robot

Resource    ./../Tests/LTE5659/CBRS_LTE5659-A_FeVe_01_Startup_Spectrum_Selection_for_cbrsFreqType_PAL_wINNFTSV_2.robot
Resource    ./../Tests/LTE5659/CBRS_LTE5659-A_FeVe_09_Grant_Procedure_modification_grantResponse_with_code_402.robot

Resource    ./../Tests/CB005900/CBRS_CB005900_FeVe_01_CBRS_startup_from_site_reset.robot
Resource    ./../Tests/CB005900/CBRS_CB005900_FeVe_02_CBRS_startup_from_site_reset_when_grant_timer_not_expired.robot

Suite Setup       Run Keywords    Suite Precondition    AND    Set Software Version
Suite Teardown    Run Keywords    Suite Postcondition

Force Tags    QCP_RAN_VRF    QCD_MN_RAN    4G_TDD    CRT


*** Test Cases ***

CRL26697_FeVe_02_Verify_the_behavior_of_first_heartbeat_receiving_SUSPENDED_GRANT
    [Timeout]     25min
    [Setup]       Test Precondition    clean_bts=false
    [Teardown]    Test Postcondition
    [Tags]        CRL26697    SBTS00
    CRL26697_FeVe_02_Verify_the_behavior_of_first_heartbeat_receiving_SUSPENDED_GRANT

LTE3663_B_FeVe_03_Verify_the_CBRS_online_activation_and_de-activation_is_successful
    [Timeout]     20min
    [Setup]       Test Precondition    clean_bts=true
    [Teardown]    Test Postcondition
    [Tags]        LTE3663    SBTS00
    LTE3663_B_FeVe_03_Verify_the_CBRS_online_activation_and_de-activation_is_successful

LTE3663_Q_FeVe_11_Verify_deregistration_requested_by_SAS_is_successful
    [Timeout]     25min
    [Setup]       Test Precondition    clean_bts=false
    [Teardown]    Test Postcondition
    [Tags]        LTE3663    SBTS00
    LTE3663_Q_FeVe_11_Verify_deregistration_requested_by_SAS_is_successful

LTE3663_Q_FeVe_38_Verify_the_behavior_of_SAS_switchover_after_SAS_communication_failure
    [Timeout]     30min
    [Setup]       Test Precondition    clean_bts=false
    [Teardown]    Test Postcondition
    [Tags]        LTE3663    SBTS00
    LTE3663_Q_FeVe_38_Verify_the_behavior_of_SAS_switchover_after_SAS_communication_failure

LTE4236_FeVe_03_Verify_the_behavior_of_both_of_cell_pMax_and_EARFCN_reconfiguration
    [Timeout]     25min
    [Setup]       Test Precondition    clean_bts=true
    [Teardown]    Test Postcondition
    [Tags]        LTE4236    SBTS00
    LTE4236_FeVe_03_Verify_the_behavior_of_both_of_cell_pMax_and_EARFCN_reconfiguration

LTE4236_FeVe_07_Verify_the_behavior_of_acquiring_new_grant_when_receiving_suspension_in_heartbeat_response
    [Timeout]     100min
    [Setup]       Test Precondition    clean_bts=true
    [Teardown]    Test Postcondition
    [Tags]        LTE4236    SBTS00
    LTE4236_FeVe_07_Verify_the_behavior_of_acquiring_new_grant_when_receiving_suspension_in_heartbeat_response

LTE4236_FeVe_11_Verify_the_behavior_of_acquiring_new_grant_when_receiving_termination_in_heartbeat_response
    [Timeout]     80min
    [Setup]       Test Precondition    clean_bts=true
    [Teardown]    Test Postcondition
    [Tags]        LTE4236    SBTS00
    LTE4236_FeVe_11_Verify_the_behavior_of_acquiring_new_grant_when_receiving_termination_in_heartbeat_response

LTE5281_FeVe_03_desiredPmax_is_decreased_by_an_operator_while_not_providing_service
    [Timeout]     35min
    [Setup]       Test Precondition    clean_bts=true
    [Teardown]    Test Postcondition
    [Tags]        LTE5281    SBTS00
    CBRS_LTE5281_FeVe_03_desiredPmax_is_decreased_by_an_operator_while_not_providing_service

LTE5703_FeVe_01_Registration_procedure_modification_is_successfully_modified
    [Timeout]     45min    #to be optimized
    [Setup]       Test Precondition    clean_bts=false
    [Teardown]    Test Postcondition
    [Tags]        LTE5703    SBTS00
    CBRS_LTE5703_FeVe_01_Registration_Procedure_is_successfully_modified

LTE5703_FeVe_08_SpectrumInquiry_with_cbsdFrequencyGuidance_and_groupingConfig_in_SI_Response_at_startup
    [Timeout]     45min    #to be optimized
    [Setup]       Test Precondition    clean_bts=true
    [Teardown]    Test Postcondition
    [Tags]        LTE5703    SBTS00
    CBRS_LTE5703_FeVe_08_SpectrumInquiry_with_cbsdFrequencyGuidance_and_groupingConfig_in_SI_Response_at_startup

LTE5703_FeVe_13_Grant_Procedure_with_cbsdFrequencyGuidance_and_featureDataExchange_present
    [Timeout]     45min    #to be optimized
    [Setup]       Test Precondition    clean_bts=false
    [Teardown]    Test Postcondition
    [Tags]        LTE5703    SBTS00
    CBRS_LTE5703_FeVe_13_Grant_Procedure_with_cbsdFrequencyGuidance_and_featureDataExchange_present

LTE5703_FeVe_28_SAS_Feature_Data_Exchange_procedure_successful
    [Timeout]     45min    #to be optimized
    [Setup]       Test Precondition    clean_bts=true
    [Teardown]    Test Postcondition
    [Tags]        LTE5703    SBTS00
    CBRS_LTE5703_FeVe_28_SAS_Feature_Data_Exchange_procedure_successful

LTE5703_FeVe_43_Suspended_grant_is_released_before_transmitExpireTime_reached
    [Timeout]     45min    #to be optimized
    [Setup]       Test Precondition    clean_bts=false
    [Teardown]    Test Postcondition
    [Tags]        LTE5703    SBTS00
    CBRS_LTE5703_FeVe_43_Suspended_grant_is_released_before_transmitExpireTime_reached

LTE5659-A_FeVe_01_Startup_Spectrum_Selection_for_cbrsFreqType_PAL_wINNFTSV_2
    [Timeout]     45min    #to be optimized
    [Setup]       Test Precondition    clean_bts=true
    [Teardown]    Test Postcondition
    [Tags]        LTE5659    SBTS00
    CBRS_LTE5659-A_FeVe_01_Startup_Spectrum_Selection_for_cbrsFreqType_PAL_wINNFTSV_2

CB005900_FeVe_01_CBRS_startup_from_site_reset
    [Timeout]     50min
    [Setup]       Test Precondition    clean_bts=true
    [Teardown]    Test Postcondition
    [Tags]        CB005900    SBTS00
    CBRS_CB005900_FeVe_01_CBRS_startup_from_site_reset

CB005900_FeVe_02_CBRS_startup_from_site_reset_when_grant_timer_not_expired
    [Timeout]     45min    #to be optimized
    [Setup]       Test Precondition    clean_bts=true
    [Teardown]    Test Postcondition
    [Tags]        CB005900    SBTS00
    CBRS_CB005900_FeVe_02_CBRS_startup_from_site_reset_when_grant_timer_not_expired
