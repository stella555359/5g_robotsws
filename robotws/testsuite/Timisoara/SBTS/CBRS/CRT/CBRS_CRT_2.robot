*** Settings ***
Documentation    CBRS CRT suite 2 - LTE5703 (TS2.0)
...              Suite designed for common testlines CBRS_1, CBRS_5 or CBRS_6

Resource    ./../Resources/cbrs_common_keywords.robot

Resource    ./../Tests/LTE5703/CBRS_LTE5703_FeVe_01_Registration_Procedure_is_successfully_modified.robot
Resource    ./../Tests/LTE5703/CBRS_LTE5703_FeVe_02_Registration_procedure_modification_failure_with_TS_version_2_0.robot
Resource    ./../Tests/LTE5703/CBRS_LTE5703_FeVe_03_Resending_register_request_with_specified_response_data.robot
Resource    ./../Tests/LTE5703/CBRS_LTE5703_FeVe_04_Resending_register_request_without_response_data.robot
Resource    ./../Tests/LTE5703/CBRS_LTE5703_FeVe_05_Resending_register_request_with_invalid_response_data.robot
Resource    ./../Tests/LTE5703/CBRS_LTE5703_FeVe_07_CBSD_receives_different_cbrsaVersion_from_SAS.robot
Resource    ./../Tests/LTE5703/CBRS_LTE5703_FeVe_08_SpectrumInquiry_with_cbsdFrequencyGuidance_and_groupingConfig_in_SI_Response_at_startup.robot
Resource    ./../Tests/LTE5703/CBRS_LTE5703_FeVe_11_SpectrumInquiry_Procedure_Modification_with_CA_service_enabled.robot
Resource    ./../Tests/LTE5703/CBRS_LTE5703_FeVe_12_SpectrumInquiry_Procedure_Modification_with_non_success_and_RC_106_and_100.robot
Resource    ./../Tests/LTE5703/CBRS_LTE5703_FeVe_13_Grant_Procedure_with_cbsdFrequencyGuidance_and_featureDataExchange_present.robot
Resource    ./../Tests/LTE5703/CBRS_LTE5703_FeVe_21_SAS_Heartbeat_procedure_responseCode_100.robot
Resource    ./../Tests/LTE5703/CBRS_LTE5703_FeVe_22_SAS_Heartbeat_procedure_responseCode_106.robot
Resource    ./../Tests/LTE5703/CBRS_LTE5703_FeVe_24_SAS_Heartbeat_procedure_responseCode_500.robot
Resource    ./../Tests/LTE5703/CBRS_LTE5703_FeVe_25_SAS_Heartbeat_procedure_responseCode_501.robot
Resource    ./../Tests/LTE5703/CBRS_LTE5703_FeVe_28_SAS_Feature_Data_Exchange_procedure_successful.robot
Resource    ./../Tests/LTE5703/CBRS_LTE5703_FeVe_33_Grant_spectrum_reselection_caused_by_grant_termination_with_frequency_guidance.robot
Resource    ./../Tests/LTE5703/CBRS_LTE5703_FeVe_34_Grant_spectrum_reselection_failed_due_to_no_available_channel_in_frequency_guidance.robot
Resource    ./../Tests/LTE5703/CBRS_LTE5703_FeVe_40_Grant_suspension_with_valid_channel_data_in_operationParam_in_heartbeatResponse.robot
Resource    ./../Tests/LTE5703/CBRS_LTE5703_FeVe_42_Grant_suspension_with_invalid_channel_data_in_opeationParam_in_heartbeatResponse.robot
Resource    ./../Tests/LTE5703/CBRS_LTE5703_FeVe_44_Suspended_grant_is_terminated_before_transmitExpireTime_reached.robot
Resource    ./../Tests/LTE5703/CBRS_LTE5703_FeVe_45_Suspended_grant_gets_responseCode_502_before_transmitExpireTime_reached.robot
Resource    ./../Tests/LTE5703/CBRS_LTE5703_FeVe_68_SAS_Grant_Termination_Procedure_with_Response_Code_100.robot
Resource    ./../Tests/LTE5703/CBRS_LTE5703_FeVe_70_SAS_Grant_Termination_Procedure_when_responseData_contains_a_valid_waiting_interval.robot
Resource    ./../Tests/LTE5703/CBRS_LTE5703_FeVe_71_SAS_Grant_Termination_Procedure_when_responseData_contains_an_invalid_waiting_interval.robot
Resource    ./../Tests/LTE5703/CBRS_LTE5703_FeVe_74_Verify_CBSD_tries_re-registration_after_receiving_HTTP404.robot
Resource    ./../Tests/LTE5703/CBRS_LTE5703_FeVe_75_Heartbeat_negotiation_after_4532_fault_and_receiving_responseCode_501-EDA.robot
Resource    ./../Tests/LTE5703/CBRS_LTE5703_FeVe_76_Initiation_of_Relinquish_Grant_with_eutraTddConfig_conflict_between_SAS_and_eNB.robot
Resource    ./../Tests/LTE5703/CBRS_LTE5703_FeVe_77_ResponseCode_501_with_operationParam_sent_in_heartbeatResponse.robot

Resource    ./../Tests/LTE5659/CBRS_LTE5659-A_FeVe_01_Startup_Spectrum_Selection_for_cbrsFreqType_PAL_wINNFTSV_2.robot
Resource    ./../Tests/LTE5659/CBRS_LTE5659-A_FeVe_03_Startup_Spectrum_Selection_for_PAL_channel_according_to_cbrsFreqPriority.robot
Resource    ./../Tests/LTE5659/CBRS_LTE5659-A_FeVe_04_Startup_Spectrum_selection_with_all_assigned_cells_as_PAL.robot
Resource    ./../Tests/LTE5659/CBRS_LTE5659-A_FeVe_05_Runtime_Spectrum_Selection_for_cbrsFreqType_PAL_wINNFTSV_2_different_cbrsFreqPriority.robot
Resource    ./../Tests/LTE5659/CBRS_LTE5659-A_FeVe_07_Background_Query_assign_PALchannel_to_other_in_service_cell.robot

Resource    ./../Tests/CB005900/CBRS_CB005900_FeVe_01_CBRS_startup_from_site_reset.robot
Resource    ./../Tests/CB005900/CBRS_CB005900_FeVe_02_CBRS_startup_from_site_reset_when_grant_timer_not_expired.robot

Suite Setup       Run Keywords    Suite Precondition    AND    Set Software Version
Suite Teardown    Run Keywords    Suite Postcondition

Force Tags    QCP_RAN_VRF    QCD_MN_RAN    4G_TDD    CRT


*** Test Cases ***

CBRS_LTE5703_FeVe_01_Registration_Procedure_is_successfully_modified
    [Timeout]     20min
    [Setup]       Test Precondition    clean_bts=false
    [Teardown]    Test Postcondition
    [Tags]        LTE5703    SBTS00
    CBRS_LTE5703_FeVe_01_Registration_Procedure_is_successfully_modified

CBRS_LTE5703_FeVe_02_Registration_Procedure_failure_with_TS_version_2.0
    [Timeout]     25min
    [Setup]       Test Precondition    clean_bts=false
    [Teardown]    Test Postcondition
    [Tags]        LTE5703    SBTS00
    CBRS_LTE5703_FeVe_02_Registration_procedure_modification_failure_with_TS_version_2_0

CBRS_LTE5703_FeVe_03_Resending_register_request_with_specified_response_data
    [Timeout]     20min
    [Setup]       Test Precondition    clean_bts=false
    [Teardown]    Test Postcondition
    [Tags]        LTE5703    SBTS00
    CBRS_LTE5703_FeVe_03_Resending_register_request_with_specified_response_data

CBRS_LTE5703_FeVe_04_Resending_register_request_without_response_data
    [Timeout]     20min
    [Setup]       Test Precondition    clean_bts=false
    [Teardown]    Test Postcondition
    [Tags]        LTE5703    SBTS00
    CBRS_LTE5703_FeVe_04_Resending_register_request_without_response_data

CBRS_LTE5703_FeVe_05_Resending_register_request_with_invalid_response_data
    [Timeout]     20min
    [Setup]       Test Precondition    clean_bts=false
    [Teardown]    Test Postcondition
    [Tags]        LTE5703    SBTS00
    CBRS_LTE5703_FeVe_05_Resending_register_request_with_invalid_response_data

CBRS_LTE5703_FeVe_07_CBSD_receives_different_cbrsaVersion_from_SAS
    [Timeout]     20min
    [Setup]       Test Precondition    clean_bts=false
    [Teardown]    Test Postcondition
    [Tags]        LTE5703    SBTS00
    CBRS_LTE5703_FeVe_07_CBSD_receives_different_cbrsaVersion_from_SAS

CBRS_LTE5703_FeVe_08_SpectrumInquiry_with_cbsdFrequencyGuidance_and_groupingConfig_in_SI_Response_at_startup
    [Timeout]     20min
    [Setup]       Test Precondition    clean_bts=true
    [Teardown]    Test Postcondition
    [Tags]        LTE5703    SBTS00
    CBRS_LTE5703_FeVe_08_SpectrumInquiry_with_cbsdFrequencyGuidance_and_groupingConfig_in_SI_Response_at_startup

CBRS_LTE5703_FeVe_11_SpectrumInquiry_Procedure_Modification_with_CA_service_enabled
    [Timeout]     20min
    [Setup]       Test Precondition    clean_bts=true
    [Teardown]    Test Postcondition
    [Tags]        LTE5703    SBTS00
    CBRS_LTE5703_FeVe_11_SpectrumInquiry_Procedure_Modification_with_CA_service_enabled

CBRS_LTE5703_FeVe_12_SpectrumInquiry_Procedure_Modification_with_non_success_and_RC_106_and_100
    [Timeout]     25min
    [Setup]       Test Precondition    clean_bts=true
    [Teardown]    Test Postcondition
    [Tags]        LTE5703    SBTS00
    CBRS_LTE5703_FeVe_12_SpectrumInquiry_Procedure_Modification_with_non_success_and_RC_106_and_100

CBRS_LTE5703_FeVe_13_Grant_Procedure_with_cbsdFrequencyGuidance_and_featureDataExchange_present
    [Timeout]     20min     #to be optimized
    [Setup]       Test Precondition    clean_bts=false
    [Teardown]    Test Postcondition
    [Tags]        LTE5703    SBTS00
    CBRS_LTE5703_FeVe_13_Grant_Procedure_with_cbsdFrequencyGuidance_and_featureDataExchange_present

CBRS_LTE5703_FeVe_21_SAS_Heartbeat_procedure_responseCode_100
    [Timeout]     35min     #to be optimized
    [Setup]       Test Precondition    clean_bts=true
    [Teardown]    Test Postcondition
    [Tags]        LTE5703    SBTS23R4    SBTS00
    CBRS_LTE5703_FeVe_21_SAS_Heartbeat_procedure_responseCode_100

CBRS_LTE5703_FeVe_22_SAS_Heartbeat_procedure_responseCode_106
    [Timeout]     25min
    [Setup]       Test Precondition    clean_bts=true
    [Teardown]    Test Postcondition
    [Tags]        LTE5703    SBTS00
    CBRS_LTE5703_FeVe_22_SAS_Heartbeat_procedure_responseCode_106

CBRS_LTE5703_FeVe_24_SAS_Heartbeat_procedure_responseCode_500
    [Timeout]     25min
    [Setup]       Test Precondition    clean_bts=true
    [Teardown]    Test Postcondition
    [Tags]        LTE5703    SBTS23R4    SBTS00
    CBRS_LTE5703_FeVe_24_SAS_Heartbeat_procedure_responseCode_500

CBRS_LTE5703_FeVe_25_SAS_Heartbeat_procedure_responseCode_501
    [Timeout]     25min
    [Setup]       Test Precondition    clean_bts=true
    [Teardown]    Test Postcondition
    [Tags]        LTE5703     SBTS23R4    SBTS00
    CBRS_LTE5703_FeVe_25_SAS_Heartbeat_procedure_responseCode_501

CBRS_LTE5703_FeVe_28_SAS_Feature_Data_Exchange_procedure_successful
    [Timeout]     20min     #to be optimized
    [Setup]       Test Precondition    clean_bts=true
    [Teardown]    Test Postcondition
    [Tags]        LTE5703    SBTS23R4    SBTS00
    CBRS_LTE5703_FeVe_28_SAS_Feature_Data_Exchange_procedure_successful

CBRS_LTE5703_FeVe_33_Grant_spectrum_reselection_caused_by_grant_termination_with_frequency_guidance
    [Timeout]     20min     #to be optimized
    [Setup]       Test Precondition    clean_bts=false
    [Teardown]    Test Postcondition
    [Tags]        LTE5703    SBTS23R4    SBTS00
    CBRS_LTE5703_FeVe_33_Grant_spectrum_reselection_caused_by_grant_termination_with_frequency_guidance

CBRS_LTE5703_FeVe_34_Grant_spectrum_reselection_failed_due_to_no_available_channel_in_frequency_guidance
    [Timeout]     40min
    [Setup]       Test Precondition    clean_bts=false
    [Teardown]    Test Postcondition
    [Tags]        LTE5703    SBTS23R4    SBTS00
    CBRS_LTE5703_FeVe_34_Grant_spectrum_reselection_failed_due_to_no_available_channel_in_frequency_guidance

CBRS_LTE5703_FeVe_40_Grant_suspension_with_valid_channel_data_in_operationParam_in_heartbeatResponse
    [Timeout]     20min
    [Setup]       Test Precondition    clean_bts=false
    [Teardown]    Test Postcondition
    [Tags]        LTE5703    SBTS23R4    SBTS00
    CBRS_LTE5703_FeVe_40_Grant_suspension_with_valid_channel_data_in_operationParam_in_heartbeatResponse

CBRS_LTE5703_FeVe_42_Grant_suspension_with_invalid_channel_data_in_opeationParam_in_heartbeatResponse
    [Timeout]     20min
    [Setup]       Test Precondition    clean_bts=false
    [Teardown]    Test Postcondition
    [Tags]        LTE5703    SBTS23R4    SBTS00
    CBRS_LTE5703_FeVe_42_Grant_suspension_with_invalid_channel_data_in_opeationParam_in_heartbeatResponse

CBRS_LTE5703_FeVe_44_Suspended_grant_is_terminated_before_transmitExpireTime_reached
    [Timeout]     20min
    [Setup]       Test Precondition    clean_bts=false
    [Teardown]    Test Postcondition
    [Tags]        LTE5703    SBTS23R4    SBTS00
    CBRS_LTE5703_FeVe_44_Suspended_grant_is_terminated_before_transmitExpireTime_reached

CBRS_LTE5703_FeVe_45_Suspended_grant_gets_responseCode_502_before_transmitExpireTime_reached
    [Timeout]     20min
    [Setup]       Test Precondition    clean_bts=false
    [Teardown]    Test Postcondition
    [Tags]        LTE5703    SBTS23R4    SBTS00
    CBRS_LTE5703_FeVe_45_Suspended_grant_gets_responseCode_502_before_transmitExpireTime_reached

CBRS_LTE5703_FeVe_68_SAS_Grant_Termination_Procedure_with_Response_Code_100
    [Timeout]     20min
    [Setup]       Test Precondition    clean_bts=false
    [Teardown]    Test Postcondition
    [Tags]        LTE5703    SBTS23R4    SBTS00
    CBRS_LTE5703_FeVe_68_SAS_Grant_Termination_Procedure_with_Response_Code_100

CBRS_LTE5703_FeVe_70_SAS_Grant_Termination_Procedure_when_responseData_contains_a_valid_waiting_interval
    [Timeout]     20min
    [Setup]       Test Precondition    clean_bts=false
    [Teardown]    Test Postcondition
    [Tags]        LTE5703    SBTS23R4    SBTS00
    CBRS_LTE5703_FeVe_70_SAS_Grant_Termination_Procedure_when_responseData_contains_a_valid_waiting_interval

CBRS_LTE5703_FeVe_71_SAS_Grant_Termination_Procedure_when_responseData_contains_an_invalid_waiting_interval
    [Timeout]     20min
    [Setup]       Test Precondition    clean_bts=false
    [Teardown]    Test Postcondition
    [Tags]        LTE5703    SBTS23R4    SBTS00
    CBRS_LTE5703_FeVe_71_SAS_Grant_Termination_Procedure_when_responseData_contains_an_invalid_waiting_interval

CBRS_LTE5703_FeVe_74_Verify_CBSD_tries_re-registration_after_receiving_HTTP404
    [Timeout]     25min
    [Setup]       Test Precondition    clean_bts=true
    [Teardown]    Test Postcondition
    [Tags]        LTE5703    SBTS00
    CBRS_LTE5703_FeVe_74_Verify_CBSD_tries_re-registration_after_receiving_HTTP404

CBRS_LTE5703_FeVe_75_Heartbeat_negotiation_after_4532_fault_and_receiving_responseCode_501-EDA
    [Timeout]     25min     #to be optimized
    [Setup]       Test Precondition    clean_bts=true
    [Teardown]    Test Postcondition
    [Tags]        LTE5703    SBTS24R1    SBTS23R4    SBTS00
    CBRS_LTE5703_FeVe_75_Heartbeat_negotiation_after_4532_fault_and_receiving_responseCode_501-EDA

CBRS_LTE5703_FeVe_76_Initiation_of_Relinquish_Grant_with_eutraTddConfig_conflict_between_SAS_and_eNB
    [Timeout]     25min
    [Setup]       Test Precondition    clean_bts=true
    [Teardown]    Test Postcondition
    [Tags]        LTE5703    SBTS00
    CBRS_LTE5703_FeVe_76_Initiation_of_Relinquish_Grant_with_eutraTddConfig_conflict_between_SAS_and_eNB

[1][1.0] CBRS_LTE5703_FeVe_77_ResponseCode_501_with_operationParam_sent_in_heartbeatResponse-EDA
    [Timeout]     25min
    [Setup]       Test Precondition    clean_bts=false
    [Teardown]    Test Postcondition
    [Tags]        LTE5703    SBTS00
    CBRS_LTE5703_FeVe_77_ResponseCode_501_with_operationParam_sent_in_heartbeatResponse

CBRS_LTE5659-A_FeVe_01_Startup_Spectrum_Selection_for_cbrsFreqType_PAL_wINNFTSV_2
    [Timeout]     20min
    [Setup]       Test Precondition    clean_bts=true
    [Teardown]    Test Postcondition
    [Tags]        LTE5659    SBTS00
    CBRS_LTE5659-A_FeVe_01_Startup_Spectrum_Selection_for_cbrsFreqType_PAL_wINNFTSV_2

CBRS_LTE5659-A_FeVe_03_Startup_Spectrum_Selection_for_PAL_channel_according_to_cbrsFreqPriority
    [Timeout]     20min
    [Setup]       Test Precondition    clean_bts=true
    [Teardown]    Test Postcondition
    [Tags]        LTE5659    SBTS00
    CBRS_LTE5659-A_FeVe_03_Startup_Spectrum_Selection_for_PAL_channel_according_to_cbrsFreqPriority

CBRS_LTE5659-A_FeVe_04_Startup_Spectrum_selection_with_all_assigned_cells_as_PAL
    [Timeout]     20min
    [Setup]       Test Precondition    clean_bts=true
    [Teardown]    Test Postcondition
    [Tags]        LTE5659    SBTS00
    CBRS_LTE5659-A_FeVe_04_Startup_Spectrum_selection_with_all_assigned_cells_as_PAL

CBRS_LTE5659-A_FeVe_05_Runtime_Spectrum_Selection_for_cbrsFreqType_PAL_wINNFTSV_2_different_cbrsFreqPriority
    [Timeout]     20min
    [Setup]       Test Precondition    clean_bts=true
    [Teardown]    Test Postcondition
    [Tags]        LTE5659    SBTS00
    CBRS_LTE5659-A_FeVe_05_Runtime_Spectrum_Selection_for_cbrsFreqType_PAL_wINNFTSV_2_different_cbrsFreqPriority

CBRS_LTE5659-A_FeVe_07_Background_Query_assign_PALchannel_to_other_in_service_cell
    [Timeout]     30min
    [Setup]       Test Precondition    clean_bts=true
    [Teardown]    Test Postcondition
    [Tags]        LTE5659    SBTS00
    CBRS_LTE5659-A_FeVe_07_Background_Query_assign_PALchannel_to_other_in_service_cell

CBRS_CB005900_FeVe_01_CBRS_startup_from_site_reset
    [Timeout]     45min
    [Setup]       Test Precondition    clean_bts=false    #change from true 17/07/2023
    [Teardown]    Test Postcondition
    [Tags]        CB005900    SBTS00
    CBRS_CB005900_FeVe_01_CBRS_startup_from_site_reset

CBRS_CB005900_FeVe_02_CBRS_startup_from_site_reset_when_grant_timer_not_expired
    [Timeout]     45min
    [Setup]       Test Precondition    clean_bts=false    #change from true 23/06/2023
    [Teardown]    Test Postcondition
    [Tags]        CB005900    SBTS00
    CBRS_CB005900_FeVe_02_CBRS_startup_from_site_reset_when_grant_timer_not_expired
