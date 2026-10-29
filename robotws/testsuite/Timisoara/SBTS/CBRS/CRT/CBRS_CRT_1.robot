*** Settings ***
Documentation    CBRS CRT suite 1 - legacy features and robustness
...              Suite designed for common testlines CBRS_1, CBRS_5 or CBRS_6

Resource    ./../Resources/cbrs_common_keywords.robot

Resource    ./../Tests/CRL29619/CBRS_CRL29619_FeVe_01_Check_SNI_message_extension_with_direct_connection.robot
Resource    ./../Tests/CRL29619/CBRS_CRL29619_FeVe_02_Check_SNI_extension_while_connected_to_SAS_via_HTTPS_Proxy.robot

Resource    ./../Tests/LTE4237/CBRS_LTE4237_FeVe_01_Cell_bandwidth_maxGrantChBwRed_desiredPmax_change_procedure.robot
Resource    ./../Tests/LTE4237/CBRS_LTE4237_FeVe_02_Cell_behaviour_with_active_querySasServerPeriod.robot
Resource    ./../Tests/LTE4237/CBRS_LTE4237_FeVe_03_CA_continue_channels_space_configuration_change.robot

Resource    ./../Tests/LTE5281/CBRS_LTE5281_FeVe_01_desiredPmax_is_increased_by_an_operator.robot
Resource    ./../Tests/LTE5281/CBRS_LTE5281_FeVe_03_desiredPmax_is_decreased_by_an_operator_while_not_providing_service.robot
Resource    ./../Tests/LTE5281/CBRS_LTE5281_FeVe_06_pMax_is_changed_by_an_operator_while_providing_service.robot
Resource    ./../Tests/LTE5281/CBRS_LTE5281_FeVe_07_antennaGain_is_changed_by_an_operator.robot

Resource    ./../Tests/Robustness/CBRS_Robustness_04_grantResponse_not_received_periodically.robot

Resource    ./../Tests/LTE3663/CRL26683_FeVe_01_Verify_the_behavior_of_CBRS_activation.robot

Resource    ./../Tests/LTE3663/CRL26697_FeVe_02_Verify_the_behavior_of_first_heartbeat_receiving_SUSPENDED_GRANT.robot

Resource    ./../Tests/LTE3663/LTE3663_B_FeVe_03_Verify_the_CBRS_online_activation_and_de-activation_is_successful.robot
Resource    ./../Tests/LTE3663/LTE3663_Q_FeVe_08_Verify_https_proxy_switch_is_successful_in_case_connection_to_proxy_fails.robot
Resource    ./../Tests/LTE3663/LTE3663_Q_FeVe_11_Verify_deregistration_requested_by_SAS_is_successful.robot
Resource    ./../Tests/LTE3663/LTE3663_Q_FeVe_38_Verify_the_behavior_of_SAS_switchover_after_SAS_communication_failure.robot

Resource    ./../Tests/LTE3974/CBRS_LTE3974_FeVe_07_Verify_if_enhanced_measurement_is_triggered_after_measurement_timer_expires.robot
Resource    ./../Tests/LTE3974/CBRS_LTE3974_FeVe_13_Verify_CBRS_Pre-Tx_measurement_is_triggered_if_all_grants_of_one_CBSD_are_suspended.robot

Resource    ./../Tests/LTE4236-B/LTE4236_FeVe_03_Verify_the_behavior_of_both_of_cell_pMax_and_EARFCN_reconfiguration.robot
Resource    ./../Tests/LTE4236-B/LTE4236_FeVe_07_Verify_the_behavior_of_acquiring_new_grant_when_receiving_suspension_in_heartbeat_response.robot
Resource    ./../Tests/LTE4236-B/LTE4236_FeVe_11_Verify_the_behavior_of_acquiring_new_grant_when_receiving_termination_in_heartbeat_response.robot
Resource    ./../Tests/LTE4236-B/CBRS_LTE4236_FeVe_20_New_grant_request_after_suspend_501_in_heartbeat_for_PAL_channel_with_HTTPS_proxy_enabled.robot
Resource    ./../Tests/LTE4236-B/LTE4236_FeVe_21_Verify_bandwidth_continuity_and_adaptation_after_grant_suspension_when_CA_is_enabled.robot

Resource    ./../Tests/LTE4679-B/CBRS_LTE4679-B_FeVe_01_Mobility_auto_reconfiguration_for_BTS_level.robot

Resource    ./../Tests/CB008735/CBRS_CB008735_FeVe_01_Grant_Update_Procedure_maxEirp.robot
Resource    ./../Tests/CB008735/CBRS_CB008735_FeVe_03_Grant_Update_Procedure_channelType.robot
Resource    ./../Tests/CB008735/CBRS_CB008735_FeVe_04_Grant_Update_Procedure_maxEirp_and_channelType.robot
Resource    ./../Tests/CB008735/CBRS_CB008735_FeVe_06_CBSD_keeps_grant_on_cell_lock.robot
Resource    ./../Tests/CB008735/CBRS_CB008735_FeVe_09_cbrsFreqPriority_Change_LTE.robot
Resource    ./../Tests/CB008735/CBRS_CB008735_FeVe_10_SAS_Feature_Capability_Exchange_Procedure.robot

Suite Setup       Run Keywords    Suite Precondition    AND    Set Software Version
Suite Teardown    Run Keywords    Suite Postcondition

Force Tags    QCP_RAN_VRF    QCD_MN_RAN    4G_TDD    CRT


*** Test Cases ***

CBRS_CRL29619_FeVe_01_Check_SNI_message_extension_with_direct_connection
    [Timeout]     25min
    [Setup]       Test Precondition    clean_bts=false
    [Teardown]    Test Postcondition
    [Tags]        CRL29619    SNI    SBTS00
    CBRS_CRL29619_FeVe_01_Check_SNI_message_extension_with_direct_connection

CBRS_CRL29619_FeVe_02_Check_SNI_extension_while_connected_to_SAS_via_HTTPS_Proxy
    [Timeout]      25min
    [Setup]        Test Precondition    clean_bts=true
    [Teardown]     Test Postcondition
    [Tags]         CRL29619    SNI    SBTS00
    CBRS_CRL29619_FeVe_02_Check_SNI_extension_while_connected_to_SAS_via_HTTPS_Proxy

CBRS_LTE4237_FeVe_01_Cell_bandwidth_maxGrantChBwRed_desiredPmax_change_procedure
    [Timeout]     35min
    [Setup]       Test Precondition    clean_bts=false
    [Teardown]    Test Postcondition
    [Tags]        LTE4237    SBTS00
    CBRS_LTE4237_FeVe_01_Cell_bandwidth_maxGrantChBwRed_desiredPmax_change_procedure

CBRS_LTE4237_FeVe_02_Cell_behaviour_with_active_querySasServerPeriod
    [Timeout]     40min
    [Setup]       Test Precondition    clean_bts=true
    [Teardown]    Test Postcondition
    [Tags]        LTE4237    SBTS24R1    SBTS00
    CBRS_LTE4237_FeVe_02_Cell_behaviour_with_active_querySasServerPeriod

CBRS_LTE4237_FeVe_03_CA_continue_channels_space_configuration_change
    [Timeout]     35min
    [Setup]       Test Precondition    clean_bts=true
    [Teardown]    Test Postcondition
    [Tags]        LTE4237    SBTS00
    CBRS_LTE4237_FeVe_03_CA_continue_channels_space_configuration_change

CBRS_LTE5281_FeVe_01_desiredPmax_is_increased_by_an_operator
    [Timeout]     25min
    [Setup]       Test Precondition    clean_bts=false
    [Teardown]    Test Postcondition
    [Tags]        LTE5281    SBTS00
    CBRS_LTE5281_FeVe_01_desiredPmax_is_increased_by_an_operator

CBRS_LTE5281_FeVe_03_desiredPmax_is_decreased_by_an_operator_while_not_providing_service
    [Timeout]     25min
    [Setup]       Test Precondition    clean_bts=true
    [Teardown]    Test Postcondition
    [Tags]        LTE5281    SBTS00
    CBRS_LTE5281_FeVe_03_desiredPmax_is_decreased_by_an_operator_while_not_providing_service

CBRS_LTE5281_FeVe_06_pMax_is_changed_by_an_operator_while_providing_service
    [Timeout]     25min
    [Setup]       Test Precondition    clean_bts=true
    [Teardown]    Test Postcondition
    [Tags]        LTE5281    SBTS00
    CBRS_LTE5281_FeVe_06_pMax_is_changed_by_an_operator_while_providing_service

CBRS_LTE5281_FeVe_07_antennaGain_is_changed_by_an_operator
    [Timeout]     45min
    [Setup]       Test Precondition    clean_bts=true
    [Teardown]    Test Postcondition
    [Tags]        LTE5281    SBTS00
    CBRS_LTE5281_FeVe_07_antennaGain_is_changed_by_an_operator

CRL26683_FeVe_01_Verify_the_behavior_of_CBRS_activation
    [Timeout]     20min
    [Setup]       Test Precondition    clean_bts=false
    [Teardown]    Test Postcondition
    [Tags]        CRL26683    SBTS00
    CRL26683_FeVe_01_Verify_the_behavior_of_CBRS_activation

CRL26697_FeVe_02_Verify_the_behavior_of_first_heartbeat_receiving_SUSPENDED_GRANT
    [Timeout]     20min
    [Setup]       Test Precondition    clean_bts=false
    [Teardown]    Test Postcondition
    [Tags]        CRL26697    SBTS00
    CRL26697_FeVe_02_Verify_the_behavior_of_first_heartbeat_receiving_SUSPENDED_GRANT

LTE3663_B_FeVe_03_Verify_the_CBRS_online_activation_and_de-activation_is_successful
    [Timeout]     20min
    [Setup]       Test Precondition    clean_bts=false
    [Teardown]    Test Postcondition
    [Tags]        LTE3663    SBTS00
    LTE3663_B_FeVe_03_Verify_the_CBRS_online_activation_and_de-activation_is_successful

CRL23748_FeVe_08_Verify_https_proxy_switch_is_successful_in_case_connection_to_proxy_fails
    [Timeout]     20min
    [Setup]       Test Precondition    clean_bts=false
    [Teardown]    Test Postcondition
    [Tags]        CRL23748    SBTS00
    LTE3663_Q_FeVe_08_Verify_https_proxy_switch_is_successful_in_case_connection_to_proxy_fails

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

CBRS_LTE3974_FeVe_07_Verify_if_enhanced_measurement_is_triggered_after_measurement_timer_expires
    [Timeout]     35min
    [Setup]       Test Precondition    clean_bts=false
    [Teardown]    Test Postcondition
    [Tags]        LTE3974    SBTS00
    CBRS_LTE3974_FeVe_07_Verify_if_enhanced_measurement_is_triggered_after_measurement_timer_expires

LTE3974_FeVe_13_Verify_CBRS_Pre-Tx_measurement_is_triggered_if_all_grants_of_one_CBSD_are_suspended
    [Timeout]     45min
    [Setup]       Test Precondition    clean_bts=false
    [Teardown]    Test Postcondition
    [Tags]        LTE3974    SBTS00
    CBRS_LTE3974_FeVe_13_Verify_CBRS_Pre-Tx_measurement_is_triggered_if_all_grants_of_one_CBSD_are_suspended

LTE4236_FeVe_03_Verify_the_behavior_of_both_of_cell_pMax_and_EARFCN_reconfiguration
    [Timeout]     25min
    [Setup]       Test Precondition    clean_bts=true
    [Teardown]    Test Postcondition
    [Tags]        LTE4236    SBTS00
    LTE4236_FeVe_03_Verify_the_behavior_of_both_of_cell_pMax_and_EARFCN_reconfiguration

LTE4236_FeVe_07_Verify_the_behavior_of_acquiring_new_grant_when_receiving_suspension_in_heartbeat_response
    [Timeout]     80min
    [Setup]       Test Precondition    clean_bts=true
    [Teardown]    Test Postcondition
    [Tags]        LTE4236    SBTS00
    LTE4236_FeVe_07_Verify_the_behavior_of_acquiring_new_grant_when_receiving_suspension_in_heartbeat_response

LTE4236_FeVe_11_Verify_the_behavior_of_acquiring_new_grant_when_receiving_termination_in_heartbeat_response
    [Timeout]     45min
    [Setup]       Test Precondition    clean_bts=true
    [Teardown]    Test Postcondition
    [Tags]        LTE4236    SBTS00
    LTE4236_FeVe_11_Verify_the_behavior_of_acquiring_new_grant_when_receiving_termination_in_heartbeat_response

CBRS_LTE4236_FeVe_20_New_grant_request_after_suspend_501_in_heartbeat_for_PAL_channel_with_HTTPS_proxy_enabled
    [Timeout]     60min
    [Setup]       Test Precondition    clean_bts=true
    [Teardown]    Test Postcondition
    [Tags]        LTE4236    SBTS00
    CBRS_LTE4236_FeVe_20_New_grant_request_after_suspend_501_in_heartbeat_for_PAL_channel_with_HTTPS_proxy_enabled

LTE4236_FeVe_21_Verify_bandwidth_continuity_and_adaptation_after_grant_suspension_when_CA_is_enabled
    [Timeout]     45min
    [Setup]       Test Precondition    clean_bts=true
    [Teardown]    Test Postcondition
    [Tags]        LTE4236    SBTS24R1    SBTS23R4    SBTS00
    LTE4236_FeVe_21_Verify_bandwidth_continuity_and_adaptation_after_grant_suspension_when_CA_is_enabled

LTE4679-B_Local_mobility_auto-configuration
    [Timeout]     25min
    [Setup]       Test Precondition    clean_bts=false
    [Teardown]    Test Postcondition
    [Tags]        LTE4679    SBTS00
    CBRS_LTE4679-B_FeVe_01_Mobility_auto_reconfiguration_for_BTS_level

CBRS_Robustness_04_grantResponse_not_received_periodically
    [Timeout]     70min
    [Setup]       Test Precondition    clean_bts=true
    [Teardown]    Test Postcondition
    [Tags]        Robustness    SBTS24R1    SBTS23R4    SBTS00
    CBRS_Robustness_04_grantResponse_not_received_periodically

CBRS_CB008735_FeVe_01_Grant_Update_Procedure_maxEirp
    [Timeout]     25min
    [Setup]       Test Precondition    clean_bts=false    #change from true 17/07/2023
    [Teardown]    Test Postcondition
    [Tags]        CB008735    SBTS00
    CBRS_CB008735_FeVe_01_Grant_Update_Procedure_maxEirp

CBRS_CB008735_FeVe_03_Grant_Update_Procedure_channelType
    [Timeout]     20min
    [Setup]       Test Precondition    clean_bts=false
    [Teardown]    Test Postcondition
    [Tags]        CB008735    SBTS00
    CBRS_CB008735_FeVe_03_Grant_Update_Procedure_channelType

CBRS_CB008735_FeVe_04_Grant_Update_Procedure_maxEirp_and_channelType
    [Timeout]     20min
    [Setup]       Test Precondition    clean_bts=false
    [Teardown]    Test Postcondition
    [Tags]        CB008735    SBTS00
    CBRS_CB008735_FeVe_04_Grant_Update_Procedure_maxEirp_and_channelType

CBRS_CB008735_FeVe_06_CBSD_keeps_grant_on_cell_lock
    [Timeout]     35min
    [Setup]       Test Precondition    clean_bts=false
    [Teardown]    Test Postcondition
    [Tags]        CB008735    SBTS00
    CBRS_CB008735_FeVe_06_CBSD_keeps_grant_on_cell_lock

CBRS_CB008735_FeVe_10_SAS_Feature_Capability_Exchange_Procedure
    [Timeout]     20min
    [Setup]       Test Precondition    clean_bts=false
    [Teardown]    Test Postcondition
    [Tags]        CB008735    SBTS00
    CBRS_CB008735_FeVe_10_SAS_Feature_Capability_Exchange_Procedure

CBRS_CB008735_FeVe_09_cbrsFreqPriority_Change_LTE
    [Timeout]     20min
    [Setup]       Test Precondition    clean_bts=false
    [Teardown]    Test Postcondition
    [Tags]        CB008735    SBTS00
    CBRS_CB008735_FeVe_09_cbrsFreqPriority_Change_LTE
