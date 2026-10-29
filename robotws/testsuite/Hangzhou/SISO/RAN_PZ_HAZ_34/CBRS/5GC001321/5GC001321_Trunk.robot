*** Settings ***
Suite Setup          CBRS Suite Setup
Suite Teardown       CBRS Suite Teardown
Test Setup           CBRS Test Setup
Test Teardown        CBRS Test Teardown

Variables    testsuite/Hangzhou/SISO/RAN_PZ_HAZ_34/CBRS/5GC001321/TestData/1321_variables.py
Resource    Resources/5GC001321_common_keywords.robot


Documentation
...    Author:linjiangjing & cailanwen & wangqingqing
...    contact:jiangjing.lin@nokia-sbell.com    lanwen.cai@nokia-sbell.com    qingqing.wang@nokia-sbell.com
...    squad group:SG_08
...    Feature 5GC001321

Force Tags            RAN_5G_TDD    5G_RAN_TDD    master_classicalbts_all    RAN_5G    5G_RAN    STATE_SW_UPLOADED
...    PY36
...    21A_classicalbts    SBTS00    CLOUD_5G_CLASSICAL_ASKEY_SA_ASILL_ABIOB1_AZQC    CRT_22R4    CRT_23R1

*** Variables ***

*** Test Cases ***
[1]5GC001321_A_13_Verify_the_behavior_of_CBSD_registration_failure_due_to_group_error
    [Tags]    CRT_TRUNK    CRT_22R2    CRT_22R3
    5GC001321_A_13_Verify_the_behavior_of_CBSD_registration_failure_due_to_group_error

[1]5GC001321_A_17_Verify_the_registration_with_groupID_groupType_configured_is_successful
    [Tags]    CIT_TRUNK    CDRT_22R2
    Verify_CBRS_L3_call_Samsung

[1]5GC001321_A_24_Verify_CBSD_Spectrum_Inquiry_failure_due_to_responde_code_106
    [Tags]    CRT_TRUNK    CRT_22R2    CRT_22R3    CRT_UTE
    5GC001321_A_24_Verify_CBSD_Spectrum_Inquiry_failure_due_to_responde_code_106

[1]5GC001321_A_29_Verify_GAA_channel_will_be_allocated_when_no_PAL_channel_available_but_PAL_configured
    [Tags]    CRT_TRUNK    CRT_22R2    CRT_22R3
    5GC001321_A_29_Verify_GAA_channel_will_be_allocated_when_no_PAL_channel_available_but_PAL_configured

[1]5GC001321_A_44_SyVe_09_Verify_the_behavior_of_ unsuccessful_Grant_with_GRANT_CONFLICT
    [Tags]    CRT_TRUNK    CRT_22R2    CRT_22R3
    5GC001321_A_44_SyVe_09_Verify_the_behavior_of_ unsuccessful_Grant_with_GRANT_CONFLICT

[1]5GC001321_A_46_Verify_the_grant_renew_is_successful
    [Tags]    CRT_TRUNK    CRT_22R2    CRT_22R3
    5GC001321_A_46_Verify_the_grant_renew_is_successful

[1]5GC001321_A_47_Verify_the_behavior_of_heartbeat_in_case_communication_error
    [Tags]    CRT_TRUNK    CRT_22R2    CRT_22R3
    5GC001321_A_47_Verify_the_behavior_of_heartbeat_in_case_communication_error

[1]5GC001321_A_49_Verify_the_behavior_of_heartbeat_failure_with_responsecode_106
    [Tags]    CRT_TRUNK    CRT_22R2    CRT_22R3    CRT_UTE
    5GC001321_A_49_Verify_the_behavior_of_heartbeat_failure_with_responsecode_106

[1]5GC001321_A_59_Verify_the_CBRS_online_de-activation_is_successful
    [Tags]    CRT_TRUNK    CRT_22R2    CRT_22R3
    Verify_the_CBRS_online_de-activation_is_successful

[1]5GC001321_A_62_Verify_the_AirScale_CBRS_L3_call_successfully_with_CBSD
    [Tags]    CRT_TRUNK    CRT_22R2    CRT_22R3
    Verify_CBRS_L3_call_Samsung

[1]5GC001321_A_64_Verify_the_behavior_of_gNB_CBSD_Cell_Grant_Transmission_Timer_Expiry
    [Tags]    CIT_TRUNK    CDRT_22R2    CDRT_22R3
    5GC001321_A_64_Verify_the_behavior_of_gNB_CBSD_Cell_Grant_Transmission_Timer_Expiry

[1]5GC001321_A_65_Verify_the_behavior_of_gNB_CBSD_Cell_Grant_Timer_Expiry
    [Tags]    CRT_TRUNK    CRT_22R2    CRT_22R3    CRT_UTE
    5GC001321_A_65_Verify_the_behavior_of_gNB_CBSD_Cell_Grant_Timer_Expiry

[1]5GC001321_A_66_Verify_the_behavior_of_heartbeat_Suspend_for_first_Grant_in_granted_status
    [Tags]    CIT_TRUNK    CDRT_22R2    CDRT_22R3
    5GC001321_A_66_Verify_the_behavior_of_heartbeat_Suspend_for_first_Grant_in_granted_status

[1]5GC001321_A_68_Verify_the_behavior_of_heartbeat_Suspend_for_second_Grant
    [Tags]    CRT_TRUNK    CRT_22R2    CRT_22R3
    5GC001321_A_68_Verify_the_behavior_of_heartbeat_Suspend_for_second_Grant

[1]5GC001321_A_69_Verify_the_behavior_of_heartbeat_termination_for_first_Grant
    [Tags]    CIT_TRUNK    CDRT_22R2    CDRT_22R3
    5GC001321_A_69_Verify_the_behavior_of_heartbeat_termination_for_first_Grant

[1]5GC001321_A_70_Verify_the_behavior_of_heartbeat_termination_for_second_Grant
    [Tags]    CRT_TRUNK    CRT_22R2    CRT_22R3
    5GC001321_A_70_Verify_the_behavior_of_heartbeat_termination_for_second_Grant

[1]5GC001321_A_71_Verify_the_behavior_of_CBSD_second_grant_successfully
    [Tags]    CIT_TRUNK    CDRT_22R2    CDRT_22R3
    5GC001321_A_71_Verify_the_behavior_of_CBSD_second_grant_successfully

[1]5GC001321_A_72_Verify_the_gNB_CBSD_reset_successfully
    [Tags]    CIT_TRUNK    CDRT_22R2    CDRT_22R3
    5GC001321_A_72_Verify_the_gNB_CBSD_reset_successfully

[1]5GC001321_A_73_Verify_the_behavior_of_Cell_Block_Unblock_in_authorized_status
    [Tags]    CRT_TRUNK    CRT_22R2    CRT_22R3
    5GC001321_A_73_Verify_the_behavior_of_Cell_Block_Unblock_in_authorized_status

[1]5GC001321_A_74_Verify_the_behavior_of_parameter_change_that_not_impact_existing_Grant_but_requires_object_locking
    [Tags]    CRT_TRUNK    CRT_22R2    CRT_22R3
    5GC001321_A_74_Verify_the_behavior_of_parameter_change_that_not_impact_existing_Grant_but_requires_object_locking

[1]5GC001321_A_75_Verify_the_behavior_of_RU_lock_unlock_in_authorized_status
    [Tags]    CRT_TRUNK    CRT_22R2    CRT_22R3
    5GC001321_A_75_Verify_the_behavior_of_RU_lock_unlock_in_authorized_status

[1]5GC001321_A_76_Verify_the_gNB_CBSD_reset_successfully_after_grantExpireTimer_expired
    [Tags]    CRT_TRUNK    CRT_22R2    CRT_22R3
    5GC001321_A_76_Verify_the_gNB_CBSD_reset_successfully_after_grantExpireTimer_expired

[1]5GC001321_A_79_Verify_online_modification_cbrsFreqType
    [Tags]    CRT_TRUNK    CRT_22R2    CRT_22R3    CRT_UTE
    5GC001321_A_79_Verify_online_modification_cbrsFreqType

[1]5GC001321_A_80_Verify_online_modification_desiredPmax_maxEIRP_different_as_before
    [Tags]    CRT_TRUNK    CRT_22R2    CRT_22R3
    5GC001321_A_80_Verify_online_modification_desiredPmax_maxEIRP_different_as_before

[1]5GC001321_A_81_Verify_online_modification_desiredPmax_maxEIRP_same_as_before
    [Tags]    CRT_TRUNK    CRT_22R2    CRT_22R3
    5GC001321_A_81_Verify_online_modification_desiredPmax_maxEIRP_same_as_before

[1]5GC001321_A_82_Verify_online_modification_desiredPmax_maxGrantPwrRed_antennaGain_before_granted_status
    [Tags]    CRT_TRUNK    CRT_22R2    CRT_22R3
    5GC001321_A_82_Verify_online_modification_desiredPmax_maxGrantPwrRed_antennaGain_before_granted_status

[1]5GC001321_A_83_Verify_online_modification_registration_parameters
    [Tags]    CRT_TRUNK    CRT_22R2    CRT_22R3
    5GC001321_A_83_Verify_online_modification_registration_parameters

[1]5GC001321_A_84_Verify_the_Spectrum Inquiry_after_online_modification_supportedSpectrumV2_granted_status
    [Tags]    CRT_TRUNK    CRT_22R2    CRT_22R3    CRT_UTE
    5GC001321_A_84_Verify_the_Spectrum Inquiry_after_online_modification_supportedSpectrumV2_granted_status

[1]5GC001321-E_1_Connect to SAS Mode Online Change from through Domain Proxy to through https proxy
    [Tags]    CRT_TRUNK    CRT_22R2    CRT_22R3    CRT_UTE
    5GC001321-E_1_Connect to SAS Mode Online Change from through Domain Proxy to through https proxy

[1]5GC001321-E_3_Connect to SAS Mode Online Change from through https proxy to direct connect to SAS
    [Tags]    CIT_TRUNK    CDRT_22R2
    5GC001321-E_3_Connect to SAS Mode Online Change from through https proxy to direct connect to SAS

[1]5GC001321-E_6_Connect to SAS Mode Online Change from direct connect to SAS to through Domain Proxy
    [Tags]    CIT_TRUNK    CDRT_22R2
    5GC001321-E_6_Connect to SAS Mode Online Change from direct connect to SAS to through Domain Proxy

[1]5GC001321-E_7_Support of Secondary Https Proxy_switch_successfully
    [Tags]    CRT_TRUNK    CRT_22R2    CRT_22R3    CRT_UTE
    5GC001321-E_7_Support of Secondary Https Proxy_switch_successfully

[1]5GC001321_A_39_Verify_the_behavior_of_receiving_Grant_responsecode_interference_with_usable_operationParam_contains_20Mhz_channel_and_MaxEIRP
    [Tags]    CRT_TRUNK    CRT_22R2    CRT_22R3
    5GC001321_A_39_Verify_the_behavior_of_receiving_Grant_responsecode_interference_with_usable_operationParam_contains_20Mhz_channel_and_MaxEIRP

[1]5GC001321_A_38_Verify_the_behavior_of_receiving_Grant_responsecode_interference_with_usable_operationParam_contains_20Mhz_channel_and_MaxEIRP
    [Tags]    CRT_TRUNK    CRT_22R2    CRT_22R3
    5GC001321_A_38_Verify_the_behavior_of_receiving_Grant_responsecode_interference_with_usable_operationParam_contains_20Mhz_channel_and_MaxEIRP

[1]5GC001321_C_25_Verify_the_LTE CBRS Mobility auto-configuration_ENDCDMEASCONF_update_after_NR_neighbor_freq_change
    [Tags]    CRT_TRUNK    CRT_22R2    CRT_22R3    CRT_UTE
    Verify_the_LTE CBRS Mobility auto-configuration_ENDCDMEASCONF_update_after_NR_neighbor_freq_change

[1]5GC001321_A_60_Verify_single_CBSD_deregistration_is_successful_in_multi_CBSD_configuration
    [Tags]    CRT_TRUNK    CRT_22R2    CRT_22R3
    5GC001321_A_60_Verify_single_CBSD_deregistration_is_successful_in_multi_CBSD_configuration

[1]5GC001321_A_61_Verify_online_CBRS_de-activation_is_successful_in_multi_CBSD_configuration
    [Tags]    CRT_TRUNK    CRT_22R2    CRT_22R3
    5GC001321_A_61_Verify_online_CBRS_de-activation_is_successful_in_multi_CBSD_configuration

[1]5GC001321_C_1_Verify_the_Cell Based CBRS Mobility auto-configuration_intra-gnb_inter-CBSD_HO
    [Tags]    CRT_TRUNK    CRT_22R2    CRT_22R3    CRT_UTE
    5GC001321_C_1_Verify_the_Cell Based CBRS Mobility auto-configuration_intra-gnb_inter-CBSD_HO

*** Keywords ***
