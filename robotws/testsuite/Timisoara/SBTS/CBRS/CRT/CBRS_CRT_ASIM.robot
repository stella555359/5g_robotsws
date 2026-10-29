*** Settings ***
Documentation    CBRS CRT suite ASIM - legacy features and robustness
...              = Maintainer = CBRS Team (I_CBRS_NSP_WRO_ST_GMS@internal.nsn.com)

Resource    ./../Resources/cbrs_common_keywords.robot

Resource    ./../Tests/CB005900/CBRS_CB005900_FeVe_01_CBRS_startup_from_site_reset.robot
Resource    ./../Tests/CRL29619/CBRS_CRL29619_FeVe_01_Check_SNI_message_extension_with_direct_connection.robot
Resource    ./../Tests/LTE3663/LTE3663_Q_FeVe_38_Verify_the_behavior_of_SAS_switchover_after_SAS_communication_failure.robot
Resource    ./../Tests/LTE3663/LTE3663_B_FeVe_03_Verify_the_CBRS_online_activation_and_de-activation_is_successful.robot
Resource    ./../Tests/LTE3974/CBRS_LTE3974_FeVe_07_Verify_if_enhanced_measurement_is_triggered_after_measurement_timer_expires.robot
Resource    ./../Tests/LTE4236-B/LTE4236_FeVe_07_Verify_the_behavior_of_acquiring_new_grant_when_receiving_suspension_in_heartbeat_response.robot
Resource    ./../Tests/LTE5281/CBRS_LTE5281_FeVe_01_desiredPmax_is_increased_by_an_operator.robot
Resource    ./../Tests/LTE4236-B/LTE4236_FeVe_11_Verify_the_behavior_of_acquiring_new_grant_when_receiving_termination_in_heartbeat_response.robot
Resource    ./../Tests/LTE4237/CBRS_LTE4237_FeVe_01_Cell_bandwidth_maxGrantChBwRed_desiredPmax_change_procedure.robot
Resource    ./../Tests/LTE5659/CBRS_LTE5659-A_FeVe_01_Startup_Spectrum_Selection_for_cbrsFreqType_PAL_wINNFTSV_2.robot
Resource    ./../Tests/LTE5659/CBRS_LTE5659-A_FeVe_07_Background_Query_assign_PALchannel_to_other_in_service_cell.robot
Resource    ./../Tests/LTE5703/CBRS_LTE5703_FeVe_01_Registration_Procedure_is_successfully_modified.robot
Resource    ./../Tests/LTE5703/CBRS_LTE5703_FeVe_12_SpectrumInquiry_Procedure_Modification_with_non_success_and_RC_106_and_100.robot
Resource    ./../Tests/LTE5703/CBRS_LTE5703_FeVe_33_Grant_spectrum_reselection_caused_by_grant_termination_with_frequency_guidance.robot
Resource    ./../Tests/LTE5703/CBRS_LTE5703_FeVe_75_Heartbeat_negotiation_after_4532_fault_and_receiving_responseCode_501-EDA.robot

Suite Setup       Run Keywords    Suite Precondition    AND    Set Software Version
Suite Teardown    Run Keywords    Suite Postcondition

Force Tags    QCP_RAN_VRF    QCD_MN_RAN    4G_TDD    CRT


*** Test Cases ***

CBRS_CB007425_CB005900-SR_FeVe_01_CBRS_startup_from_Site_Reset
    [Timeout]     38min
    [Setup]       Test Precondition    clean_bts=false
    [Teardown]    Test Postcondition
    [Tags]        CB005900    SBTS24R1    SBTS00
    CBRS_CB005900_FeVe_01_CBRS_startup_from_site_reset

CBRS_CB007425_CRL29619_FeVe_01_Check_SNI_message_extension_with_direct_connection
    [Timeout]     20min
    [Setup]       Test Precondition    clean_bts=true
    [Teardown]    Test Postcondition
    [Tags]        LTE3663    SBTS00
    CBRS_CRL29619_FeVe_01_Check_SNI_message_extension_with_direct_connection

LTE3663_B_FeVe_03_Verify_the_CBRS_online_activation_and_de-activation_is_successful
    [Timeout]     20min
    [Setup]       Test Precondition    clean_bts=true
    [Teardown]    Test Postcondition
    [Tags]        LTE3663    SBTS00
    LTE3663_B_FeVe_03_Verify_the_CBRS_online_activation_and_de-activation_is_successful

CBRS_CB007425_LTE3663_Q_FeVe_38_Verify_the_behavior_of_SAS_switchover_after_SAS_communication_failure_in_single_CBSD_maximum_configuration
    [Timeout]     26min
    [Setup]       Test Precondition    clean_bts=true
    [Teardown]    Test Postcondition
    [Tags]        LTE3663    SBTS00
    LTE3663_Q_FeVe_38_Verify_the_behavior_of_SAS_switchover_after_SAS_communication_failure

CBRS_CB007425_LTE3974_FeVe_07_Verify_the_CBRS_enhanced_measurement_is_triggered_by_grant_suspension_after_the_measurement_timer_expires
    [Timeout]     33min
    [Setup]       Test Precondition    clean_bts=true
    [Teardown]    Test Postcondition
    [Tags]        LTE3974    SBTS00
    CBRS_LTE3974_FeVe_07_Verify_if_enhanced_measurement_is_triggered_after_measurement_timer_expires

CBRS_CB007425_LTE4236_FeVe_07_Verify_the_behavior_of_acquiring_new_grant_when_receiving_suspension_in_heartbeat_response
    [Timeout]     75min
    [Setup]       Test Precondition    clean_bts=true
    [Teardown]    Test Postcondition
    [Tags]        LTE4236    SBTS00
    LTE4236_FeVe_07_Verify_the_behavior_of_acquiring_new_grant_when_receiving_suspension_in_heartbeat_response

CBRS_CB007425_LTE4236_FeVe_11_Verify_the_behavior_of_acquiring_new_grant_when_receiving_termination_in_heartbeat_response
    [Timeout]     33min
    [Setup]       Test Precondition    clean_bts=true
    [Teardown]    Test Postcondition
    [Tags]        LTE4236    SBTS00
    LTE4236_FeVe_11_Verify_the_behavior_of_acquiring_new_grant_when_receiving_termination_in_heartbeat_response

CBRS_CB007425_LTE4237_FeVe_01_Cell_bandwidth_maxGrantChBwRed_desiredPmax_change_procedure
    [Timeout]     33min
    [Setup]       Test Precondition    clean_bts=true
    [Teardown]    Test Postcondition
    [Tags]        LTE5621    SBTS00
    CBRS_LTE4237_FeVe_01_Cell_bandwidth_maxGrantChBwRed_desiredPmax_change_procedure

CBRS_CB007425_LTE5281_FeVe_01_desiredPmax_is_increased_by_an_operator
    [Timeout]     20min
    [Setup]       Test Precondition    clean_bts=true
    [Teardown]    Test Postcondition
    [Tags]        LTE5281    SBTS00
    CBRS_LTE5281_FeVe_01_desiredPmax_is_increased_by_an_operator

CBRS_CB007425_LTE5659-A_FeVe_01_Startup_Spectrum_Selection_for_cbrsFreqType_PAL_wINNFTSV_2
    [Timeout]     20min
    [Setup]       Test Precondition    clean_bts=true
    [Teardown]    Test Postcondition
    [Tags]        LTE5659    SBTS00
    CBRS_LTE5659-A_FeVe_01_Startup_Spectrum_Selection_for_cbrsFreqType_PAL_wINNFTSV_2

CBRS_CB007425_LTE5659-A_FeVe_07_Background_Query_assign_PALchannel_to_other_in_service_cell
    [Timeout]     24min
    [Setup]       Test Precondition    clean_bts=true
    [Teardown]    Test Postcondition
    [Tags]        LTE5659    SBTS00
    CBRS_LTE5659-A_FeVe_07_Background_Query_assign_PALchannel_to_other_in_service_cell

CBRS_CB007425_LTE5703_FeVe_01_Registration_Procedure_is_successfully_modified
    [Timeout]     25min
    [Setup]       Test Precondition    clean_bts=true
    [Teardown]    Test Postcondition
    [Tags]        LTE5703    SBTS00
    CBRS_LTE5703_FeVe_01_Registration_Procedure_is_successfully_modified

CBRS_CB007425_LTE5703_FeVe_12_SpectrumInquiry_Procedure_Modification_with_non_success_and_RC_106_and_100
    [Timeout]     25min
    [Setup]       Test Precondition    clean_bts=true
    [Teardown]    Test Postcondition
    [Tags]        LTE5703    SBTS00
    CBRS_LTE5703_FeVe_12_SpectrumInquiry_Procedure_Modification_with_non_success_and_RC_106_and_100

CBRS_CB007425_LTE5703_FeVe_33_Grant_spectrum_reselection_caused_by_grant_termination_with_frequency_guidance
    [Timeout]     25min
    [Setup]       Test Precondition    clean_bts=true
    [Teardown]    Test Postcondition
    [Tags]        LTE5703    SBTS00
    CBRS_LTE5703_FeVe_33_Grant_spectrum_reselection_caused_by_grant_termination_with_frequency_guidance

CBRS_CB007425_LTE5703_FeVe_75_Heartbeat_negotiation_after_4532_fault_and_receiving_responseCode_501-EDA
    [Timeout]     25min
    [Setup]       Test Precondition    clean_bts=false    #change from true 17/07/2023
    [Teardown]    Test Postcondition
    [Tags]        LTE5703    SBTS00
    CBRS_LTE5703_FeVe_75_Heartbeat_negotiation_after_4532_fault_and_receiving_responseCode_501-EDA
