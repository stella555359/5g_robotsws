# *** Settings ***
# Suite Setup          CBRS Suite Setup    UTECloud=${True}
# Suite Teardown       CBRS Suite Teardown
# Test Setup    Run keywords    CBRS Test Setup    AND    CBRS Get BTS Info
# Test Teardown        CBRS Test Teardown
# 
# 
# Resource    Resources/5GC001321_ET_common_keywords.robot
# Resource    Resources/CB009154_A_ET_common_keywords.robot
# Resource    Resources/CB008498-ET_common_keywords.robot
# 
# 
# 
# Documentation
# ...    Author:wangqingqing
# ...    contact:qingqing.wang@nokia-sbell.com
# ...    squad group:SG_08
# ...    Feature 5GC001321
# 
# Force Tags    SBTS00    CRT_23R1
# ...   PY36    CRT_TRUNK    CRT_UTE    SBTS00    RAN_5G    RAN_5G_TDD    CLOUD_5G_CLASSICAL_SA_ASIKL_ABILB1_AZQC    STATE_SW_UPLOADED
# 
# *** Variables ***
# 
# *** Test Cases ***
# #[1]5GC001321-A-B7_9_NRCBSD_Registration_failed_when_receive_response_code_with_unknown_or_since_the_SasCommunicationGuardTimer_expired
# #    5GC001321-A-B7_9_NRCBSD_Registration_failed_when_receive_response_code_with_unknown_or_since_the_SasCommunicationGuardTimer_expired
# 
# [1]5GC001321-A-B7_7_NRCBSD_Registration_failed_since_the_responseCode_is_106_which_bring_valid_interval_in_responseData
#     5GC001321-A-B7_7_NRCBSD_Registration_failed_since_the_responseCode_is_106_which_bring_valid_interval_in_responseData
# 
# #[1]5GC001321-A-B9_4_NRCBSD_received_spectrum_inquiry_response_with_response_code_105_or_not_received_spectrum_inquiry_response
# #    5GC001321-A-B9_4_NRCBSD_received_spectrum_inquiry_response_with_response_code_105_or_not_received_spectrum_inquiry_response
# 
# [1]5GC001321-A-B10_1_Ternimate_grant_when_grant_time_expires_due_to_SAS_does_not_renew_the_timer
#     5GC001321-A-B10_1_Ternimate_grant_when_grant_time_expires_due_to_SAS_does_not_renew_the_timer
# 
# [1]5GC001321-A-B12_14_NRCBSD_received_first_grant_response_with_response_code_401_no_response_data
#     5GC001321-A-B12_14_NRCBSD_received_first_grant_response_with_response_code_401_no_response_data
# 
# #[1]5GC001321-A-B12_20_NRCBSD_no_available_frequency_channels
# #    5GC001321-A-B12_20_NRCBSD_no_available_frequency_channels
# 
# #[1]5GC001321-A-B12_17_NRCBSD_support_grant_request_with_SAS_config_no_GAA_but_bts_config_cbrsFreqType_to_GAA
# #    5GC001321-A-B12_17_NRCBSD_support_grant_request_with_SAS_config_no_GAA_but_bts_config_cbrsFreqType_to_GAA
# 
# #[1]5GC001321-A-B12_15_NRCBSD_received_grant_response_with_response_code_404
# #    5GC001321-A-B12_15_NRCBSD_received_grant_response_with_response_code_404
# 
# #[1]5GC001321-A-B12_23_NRCBSD_20MHz_desiredPmax_exceeds_FCC_limitation_range_maxGrantPwrRed
# #    5GC001321-A-B12_23_NRCBSD_20MHz_desiredPmax_exceeds_FCC_limitation_range_maxGrantPwrRed
# 
# #[1]5GC001321-A-B13_6_CBSD_will_grant_GAA_channel_when_heartbeatResponse_501_with_valid_operationParam_not_contain_PAL_channel_and_cbrsFreqType_PAL
# #    5GC001321-A-B13_6_CBSD_will_grant_GAA_channel_when_heartbeatResponse_501_with_valid_operationParam_not_contain_PAL_
# ...channel_and_cbrsFreqType_PAL
# 
# [1]5GC001321-A-B13_1_CBSD_will_grant_channel_immediately_when_first_heartbeatResponse_501_with_valid_operationParam
#     5GC001321-A-B13_1_CBSD_will_grant_channel_immediately_when_first_heartbeatResponse_501_with_valid_operationParam
# 
# [1]5GC001321-A-B13_9_gNB_resume_work_normally_once_current_suspend_grant_recover
#     5GC001321-A-B13_9_gNB_resume_work_normally_once_current_suspend_grant_recover
# 
# #[1]5GC001321-A-B13_3_CBSD_will_grant_channel_consider_channelType_when_heartbeatResponse_501_with_valid_operationParam_and_cbrsFreqType_PAL
# #    5GC001321-A-B13_3_CBSD_will_grant_channel_consider_channelType_when_heartbeatResponse_501_with_valid_operationParam_and_cbrsFreqType_PAL
# 
# [1]5GC001321-A-B15_7_Relinquish_process_is_retriggered_due_to_relinquishResponse_with_106_with_valid_interval
#     5GC001321-A-B15_7_Relinquish_process_is_retriggered_due_to_relinquishResponse_with_106_with_valid_interval
# 
# [1]5GC001321-A-B16_7_NRCBSD_deRegistration_failed_since_the_responseCode_is_106_which_bring_valid_interval_in_responseData
#     5GC001321-A-B16_7_NRCBSD_deRegistration_failed_since_the_responseCode_is_106_which_bring_valid_interval_in_responseData
# 
# [1]5GC001321-A-B18_09_NRCBSD_grant_with_responseCode_9190_and_backoffInterval_is_populated_via_Domain_Proxy
#     5GC001321-A-B18_09_NRCBSD_grant_with_responseCode_9190_and_backoffInterval_is_populated_via_Domain_Proxy
# 
# [1]5GC001321-A-B18_08_NRCBSD_spectrumInquiry_with_responseCode_9191_via_Domain_Proxy
#     5GC001321-A-B18_08_NRCBSD_spectrumInquiry_with_responseCode_9191_via_Domain_Proxy
# 
# #[1]5GC001321-A-B18_02_NRCBSD_Registration_with_responseCode_9192_via_Domain_Proxy
# #    5GC001321-A-B18_02_NRCBSD_Registration_with_responseCode_9192_via_Domain_Proxy
# 
# #[1]5GC001321-A-B19_3_CBSD_background_hunt_to_get_more_better_channel_with_matched_channelType_cbrsFreqType_configured_PAL
# #    5GC001321-A-B19_3_CBSD_background_hunt_to_get_more_better_channel_with_matched_channelType_cbrsFreqType_configured_PAL
# 
# #[1]5GC001321-A-B19_1_CBSD_background_hunt_to_get_more_better_channel_with_satify_maxEirp
# #    5GC001321-A-B19_1_CBSD_background_hunt_to_get_more_better_channel_with_satify_maxEirp
# 
# [1]5GC001321-A-B19_4_CBSD_background_hunt_to_get_more_better_channel_with_higher_priority_for_channelType_than_maxEirp
#     5GC001321-A-B19_4_CBSD_background_hunt_to_get_more_better_channel_with_higher_priority_for_channelType_than_maxEirp
# 
# [1]5GC001321-A-B21_3_CBSD_trigger_first_heartbeat_process_directly_after_gNB_reset_when_grant_in_granted_state
#     5GC001321-A-B21_3_CBSD_trigger_first_heartbeat_process_directly_after_gNB_reset_when_grant_in_granted_state
# 
# [1]5GC001321-A-B23_5_NRCBSD_received_heartbeat_response_with_response_code_502_and_code_100_101_102_103_104_106
#     5GC001321-A-B23_5_NRCBSD_received_heartbeat_response_with_response_code_502_and_code_100_101_102_103_104_106
# 
# [1]5GC001321-A-B20_1_Grant_relinquished_directly_if_current_pMax_more_than_desiredpMax_after_update_desiredpMax_smaller
#     5GC001321-A-B20_1_Grant_relinquished_directly_if_current_pMax_more_than_desiredpMax_after_update_desiredpMax_smaller
# 
# [1]5GC001321-A-B20_18_CBSD_will_try_to_background_hunting_more_better_channel_after_update_QuerySasServerPeriod_from_zero_to_non_zero
#     5GC001321-A-B20_18_CBSD_will_try_to_background_hunting_more_better_channel_after_update_QuerySasServerPeriod_from_zero_to_non_zero
# 
# #[1]5GC001321-A-B20_11_Get_more_better_channel_after_update_cbrsFreqType
# #    5GC001321-A-B20_11_Get_more_better_channel_after_update_cbrsFreqType
# 
# ######################################################################CB009154-A###################################################################
# 
# #[1]CB009154-A_5_REG_TS20_No_SasfeatureCapabilityList_Trigger_Deregister_Then_Reg_In_TS12
# #    [Tags]    CRT_TRUNK
# #    CB009154-A_5_REG_TS20_No_SasfeatureCapabilityList_Trigger_Deregister_Then_Reg_In_TS12
# 
# #[1]CB009154-A_9_REG_CbrsaVersion_Mismatch_Retry_Registration_TS20
# #    [Tags]    CRT_TRUNK
# #    CB009154-A_9_REG_CbrsaVersion_Mismatch_Retry_Registration_TS20
# 
# [1]CB009154-A_76_HB_With_OperationParam_Is_Diffenent_ChannelType_Support_WF_GRANT_UPDATE
#     [Tags]    CRT_TRUNK
#     Commission SCF According btsname    btsName=${bts_info['name']}    config_id=9154
#     CB009154-A_76_HB_With_OperationParam_Is_Diffenent_ChannelType_Support_WF_GRANT_UPDATE
# 
# [1]CB009154-A_78_HB_With_OperationParam_Is_Diffenent_ChannelType_No_WF_GRANT_UPDATE
#     [Tags]    CRT_TRUNK
#     Commission SCF According btsname    btsName=${bts_info['name']}    config_id=9154
#     CB009154-A_78_HB_With_OperationParam_Is_Diffenent_ChannelType_No_WF_GRANT_UPDATE
# 
# [1]CB009154-A_73_HB_With_OperationParam_Is_Notchange_MaxEirp_Support_WF_GRANT_UPDATE
#     [Tags]    CRT_TRUNK
#     Commission SCF According btsname    btsName=${bts_info['name']}    config_id=9154
#     CB009154-A_73_HB_With_OperationParam_Is_Notchange_MaxEirp_Support_WF_GRANT_UPDATE
# 
# [1]CB009154-A_74_HB_With_OperationParam_Is_Unusable_MaxEirp_Support_WF_GRANT_UPDATE
#     [Tags]    CRT_TRUNK
#     Commission SCF According btsname    btsName=${bts_info['name']}    config_id=9154
#     CB009154-A_74_HB_With_OperationParam_Is_Unusable_MaxEirp_Support_WF_GRANT_UPDATE
# 
# #[1]CB009154-A_90_Grant_update_failed_responseCode_Grant_Conflict_401_TS20
# #    [Tags]    CRT_TRUNK
# #    CB009154-A_90_Grant_update_failed_responseCode_Grant_Conflict_401_TS20
# 
# [1]CB009154-A_91_HB_With_Second_Grant_RC401_No_WF_GRANT_UPDATE_TS20
#     [Tags]    CRT_TRUNK
#     Commission SCF According btsname    btsName=${bts_info['name']}    config_id=9154
#     CB009154-A_91_HB_With_Second_Grant_RC401_No_WF_GRANT_UPDATE_TS20
# 
# [1]CB009154-A_95_Grant_Update_Failed_Since_Relinquish_Failed_With_106_When_Sas_Not_Support_WF_GRANT_UPDATE
#     [Tags]    CRT_TRUNK
#     Commission SCF According btsname    btsName=${bts_info['name']}    config_id=9154
#     CB009154-A_95_Grant_Update_Failed_Since_Relinquish_Failed_With_106_When_Sas_Not_Support_WF_GRANT_UPDATE
# 
# #[1]CB009154-A_104_Grant_Update_When_Maxeirp_Exceed_FCC_Limit
# #    [Tags]    CRT_TRUNK
# #    CB009154-A_104_Grant_Update_When_Maxeirp_Exceed_FCC_Limit
# 
# #[1]CB009154-A_97_Grant_Update_MaxEirp_Higher_Together_With_Heartbeat_500
# #    [Tags]    CRT_TRUNK
# #    CB009154-A_97_Grant_Update_MaxEirp_Higher_Together_With_Heartbeat_500
# 
# [1]CB009154-A_65_2_20Mhz_Cells_With_5M_Boundary_With_CbsdFrequencyGuidance_Update_Can_Be_OnAir
#     [Tags]    CRT_TRUNK
#     Commission SCF According btsname    btsName=${bts_info['name']}    config_id=9154
#     CB009154-A_65_2_20Mhz_Cells_With_5M_Boundary_With_CbsdFrequencyGuidance_Update_Can_Be_OnAir
# 
# ######################################################################CB008498###################################################################
# 
# #[1]CB008498_02_disableCA_low_priority_cell_preempt_best_channel_when_two_cells_activated
# #    Commission SCF According btsname    btsName=${bts_info['name']}    config_id=8498_disCA_2CC
# #    CB008498_02_disableCA_low_priority_cell_preempt_best_channel_when_two_cells_activated
# 
# [1]CB008498_39_disableCA_low_priority_cell_preempt_best_channel_when_new_channel_added
#     Commission SCF According btsname    btsName=${bts_info['name']}    config_id=8498_disCA_2CC
#     CB008498_39_disableCA_low_priority_cell_preempt_best_channel_when_new_channel_added
# 
# #[1]CB008498_36_disableCA_low_priority_cell_preempt_best_channel_when_used_channel_removed
# #    Commission SCF According btsname    btsName=${bts_info['name']}    config_id=8498_disCA_2CC
# #    CB008498_36_disableCA_low_priority_cell_preempt_best_channel_when_used_channel_removed
# 
# #[1]CB008498_05_disableCA_high_priority_cell_preempt_best_channel_when_one_cell_activated
# #    Commission SCF According btsname    btsName=${bts_info['name']}    config_id=8498_disCA_2CC
# #    CB008498_05_disableCA_high_priority_cell_preempt_best_channel_when_one_cell_activated
# 
# #[1]CB008498_11_disableCA_high_priority_cell_not_preempt_best_channel_when_background_hunting
# #    Commission SCF According btsname    btsName=${bts_info['name']}    config_id=8498_disCA_2CC
# #    CB008498_11_disableCA_high_priority_cell_not_preempt_best_channel_when_background_hunting
# 
# #[1]CB008498_70_second_grant_abort_relinquish102
# #    Commission SCF According btsname    btsName=${bts_info['name']}    config_id=8498_disCA_2CC
# #    CB008498_70_second_grant_abort_relinquish102
# 
# [1]CB008498_77_heartbeat501_second_grant_no_available_channel
#     Commission SCF According btsname    btsName=${bts_info['name']}    config_id=8498_disCA_2CC
#     CB008498_77_heartbeat501_second_grant_no_available_channel
# 
# #[1]CB008498_68_second_grant_abort_heartbeat105
# #    Commission SCF According btsname    btsName=${bts_info['name']}    config_id=8498_disCA_2CC
# #    CB008498_68_second_grant_abort_heartbeat105
# 
# #[1]CB008498_64_second_grant_abort_grant100
# #    Commission SCF According btsname    btsName=${bts_info['name']}    config_id=8498_disCA_2CC
# #    CB008498_64_second_grant_abort_grant100
# 
# #[1]CB008498_55_pal_gaa_out_of_110mhz_range
# #    Commission SCF According btsname    btsName=${bts_info['name']}    config_id=8498_disCA_2CC
# #    CB008498_55_pal_gaa_out_of_110mhz_range
# 
# [1]CB008498_44_enableCA_high_priority_cell_not_preempt_best_channel_when_cbrsfreqpriority_increased
#     Commission SCF According btsname    btsName=${bts_info['name']}    config_id=8498_CA_2CC
#     CB008498_44_enableCA_high_priority_cell_not_preempt_best_channel_when_cbrsfreqpriority_increased
# 
# [1]CB008498_45_enableCA_low_priority_cell_preempt_best_channel_when_desiredpmax_increased
#     Commission SCF According btsname    btsName=${bts_info['name']}    config_id=8498_CA_2CC
#     CB008498_45_enableCA_low_priority_cell_preempt_best_channel_when_desiredpmax_increased
# 
# [1]CB008498_27_enableCA_high_priority_cell_not_preempt_best_channel_when_heartbeat50X_received
#     Commission SCF According btsname    btsName=${bts_info['name']}    config_id=8498_CA_2CC
#     CB008498_27_enableCA_high_priority_cell_not_preempt_best_channel_when_heartbeat50X_received
# 
# [1]CB008498_28_enableCA_high_priority_cell_preempt_best_channel_when_ca_disabled_to_enable
#     Commission SCF According btsname    btsName=${bts_info['name']}    config_id=8498_CA_2CC
#     CB008498_28_enableCA_high_priority_cell_preempt_best_channel_when_ca_disabled_to_enable
# 
# [1]CB008498_25_enableCA_low_priority_cell_preempt_best_channel_when_background_hunting
#     Commission SCF According btsname    btsName=${bts_info['name']}    config_id=8498_CA_2CC
#     CB008498_25_enableCA_low_priority_cell_preempt_best_channel_when_background_hunting
# 
# [1]CB008498_19_enableCA_high_priority_cell_not_preempt_best_channel_when_one_cell_activated
#     Commission SCF According btsname    btsName=${bts_info['name']}    config_id=8498_CA_2CC
#     CB008498_19_enableCA_high_priority_cell_not_preempt_best_channel_when_one_cell_activated
# 
# ######################################################################5GC001321-E#######################################
# ...############################
# 
# [1]5GC001321-E-B3_19_DP_switchover_is_triggered_by_fault6832_due_to_registrationResponse_timeout
#     [Tags]    CRT_TRUNK
#     5GC001321-E-B3_19_DP_switchover_is_triggered_by_fault6832_due_to_registrationResponse_timeout
# 
# [1]5GC001321-E-B3_5_DP_switchover_is_triggered_when_non_first_heartbeatResponse_with_91930000_and_long_transmitTimer
#     [Tags]    CRT_TRUNK
#     5GC001321-E-B3_5_DP_switchover_is_triggered_when_non_first_heartbeatResponse_with_91930000_and_long_transmitTimer
# 
# [1]5GC001321-E-B5_1_CBSD_trigger_deregistration_procedure_after_change_primary_DP_URI_which_is_servingDomainProxy
#     [Tags]    CRT_TRUNK
#     5GC001321-E-B5_1_CBSD_trigger_deregistration_procedure_after_change_primary_DP_URI_which_is_servingDomainProxy
