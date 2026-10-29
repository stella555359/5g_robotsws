*** Settings ***
Documentation    CBRS CRT suite BOAM_ET - TC migrated from BOAM_ET
...              Suite designed for common testlines CBRS_1, CBRS_5 or CBRS_6

Resource    ./../Resources/cbrs_common_keywords.robot

Resource    ./../Tests/LTE5659/CBRS_LTE5659-A_FeVe_10_ET_Reduced_GAA_spectrum_prefer_to_be_used_instead_of_full_PAL_for_GAA_cbsdFreqType.robot
Resource    ./../Tests/LTE3663/CBRS_LTE3663_B_FeVe_39_ET_eNB_receives_failure_registration_response_with_reason_REG_PENDING.robot
Resource    ./../Tests/LTE3663/CBRS_LTE3663_Q_FeVe_40_ET_BTS_IPv4_refuse_to_setup_connection_with_SAS_IPv6.robot
Resource    ./../Tests/LTE3663/CBRS_LTE3663_B_FeVe_41_ET_eNB_receives_failure_registration_response_with_reason_MISSING_PARAM.robot
Resource    ./../Tests/LTE3663/CBRS_LTE3663_Q_FeVe_42_ET_Secure_TLS_connection_between_BTS_and_SAS_IPv6.robot
Resource    ./../Tests/LTE4237/CBRS_LTE4237_FeVe_04_ET_Change_chBw_value_will_be_reconfigured_to_desiredchBw_again.robot
Resource    ./../Tests/CB008735/CBRS_CB008735_FeVe_12_ET_Grant_update_channelType_PAL_GAA_will_not_happen_with_TS1_2.robot
Resource    ./../Tests/CB008735/CBRS_CB008735_FeVe_13_ET_CBSD_shall_support_feature_capability_exchange_in_Relinquish.robot
Resource    ./../Tests/CB008735/CBRS_CB008735_FeVe_14_ET_cbsdFrequencyGuidance_cleared_since_WF_ENH_GROUP_HANDLING_feature_not_supported.robot
Resource    ./../Tests/CB008735/CBRS_CB008735_FeVe_15_ET_Grant_update_failed_since_relinquish_failed_106_when_SAS_not_support_WF_GRANT_UPDATE.robot
Resource    ./../Tests/CB008735/CBRS_CB008735_FeVe_16_ET_Grant_not_update_maxEirp_no_change_for_multi_cell_with_SAS_support_WF_GRANT_UPDATE.robot
Resource    ./../Tests/CB008735/CBRS_CB008735_FeVe_17_ET_Relinquish_during_grant_update_higher_maxEirp_when_SAS_not_supports_WF_GRANT_UPDATE.robot
Resource    ./../Tests/CB008735/CBRS_CB008735_FeVe_18_ET_Grant_update_when_maxEirp_exceed_FCC_limit.robot
Resource    ./../Tests/CB008735/CBRS_CB008735_FeVe_19_ET_Grant_update_failed_since_TS1_2_SAS_not_support_WF_GRANT_UPDATE.robot

Suite Setup       Run Keywords    Suite Precondition    AND    Set Software Version
Suite Teardown    Run Keywords    Suite Postcondition

Force Tags    QCP_RAN_VRF    QCD_MN_RAN    4G_TDD    CRT

*** Test Cases ***

CBRS_LTE5659-A_FeVe_10_ET_Reduced_GAA_spectrum_prefer_to_be_used_instead_of_full_PAL_for_GAA_cbsdFreqType
    [Timeout]     45min     #to be optimized
    [Setup]       Test Precondition    clean_bts=false
    [Teardown]    Test Postcondition
    [Tags]        BOAM_ET    LTE5659    SBTS00
    CBRS_LTE5659-A_FeVe_10_ET_Reduced_GAA_spectrum_prefer_to_be_used_instead_of_full_PAL_for_GAA_cbsdFreqType

CBRS_LTE3663_B_FeVe_39_ET_eNB_receives_failure_registration_response_with_reason_REG_PENDING
    [Timeout]     45min     #to be optimized
    [Setup]       Test Precondition    clean_bts=false
    [Teardown]    Test Postcondition
    [Tags]        BOAM_ET    LTE3663    SBTS00
    CBRS_LTE3663_B_FeVe_39_ET_eNB_receives_failure_registration_response_with_reason_REG_PENDING

CBRS_LTE3663_Q_FeVe_40_ET_BTS_IPv4_refuse_to_setup_connection_with_SAS_IPv6
    [Timeout]     45min     #to be optimized
    [Setup]       Test Precondition    clean_bts=false
    [Teardown]    Test Postcondition
    [Tags]        BOAM_ET    LTE3663    SBTS00
    CBRS_LTE3663_Q_FeVe_40_ET_BTS_IPv4_refuse_to_setup_connection_with_SAS_IPv6

CBRS_LTE3663_B_FeVe_41_ET_eNB_receives_failure_registration_response_with_reason_MISSING_PARAM
    [Timeout]     45min     #to be optimized
    [Setup]       Test Precondition    clean_bts=false
    [Teardown]    Test Postcondition
    [Tags]        BOAM_ET    LTE3663    SBTS00
    CBRS_LTE3663_B_FeVe_41_ET_eNB_receives_failure_registration_response_with_reason_MISSING_PARAM

CBRS_LTE3663_Q_FeVe_42_ET_Secure_TLS_connection_between_BTS_and_SAS_IPv6
    [Timeout]     45min     #to be optimized
    [Setup]       Test Precondition    clean_bts=false
    [Teardown]    Test Postcondition
    [Tags]        BOAM_ET    LTE3663
    CBRS_LTE3663_Q_FeVe_42_ET_Secure_TLS_connection_between_BTS_and_SAS_IPv6

CBRS_LTE4237_FeVe_04_ET_Change_chBw_value_will_be_reconfigured_to_desiredchBw_again
    [Timeout]     45min     #to be optimized
    [Setup]       Test Precondition    clean_bts=false
    [Teardown]    Test Postcondition
    [Tags]        BOAM_ET    LTE4237    SBTS00
    CBRS_LTE4237_FeVe_04_ET_Change_chBw_value_will_be_reconfigured_to_desiredchBw_again

CBRS_CB008735_FeVe_12_ET_Grant_update_channelType_PAL_GAA_will_not_happen_with_TS1.2
    [Timeout]     45min     #to be optimized
    [Setup]       Test Precondition    clean_bts=false
    [Teardown]    Test Postcondition
    [Tags]        BOAM_ET    CB008735    SBTS00
    CBRS_CB008735_FeVe_12_ET_Grant_update_channelType_PAL_GAA_will_not_happen_with_TS1_2

CBRS_CB008735_FeVe_13_ET_CBSD_shall_support_feature_capability_exchange_in_Relinquish
    [Timeout]     45min     #to be optimized
    [Setup]       Test Precondition    clean_bts=false
    [Teardown]    Test Postcondition
    [Tags]        BOAM_ET    CB008735    SBTS00
    CBRS_CB008735_FeVe_13_ET_CBSD_shall_support_feature_capability_exchange_in_Relinquish

CBRS_CB008735_FeVe_14_ET_cbsdFrequencyGuidance_cleared_since_WF_ENH_GROUP_HANDLING_feature_not_supported
    [Timeout]     20min
    [Setup]       Test Precondition    clean_bts=false
    [Teardown]    Test Postcondition
    [Tags]        BOAM_ET    CB008735    SBTS00
    CBRS_CB008735_FeVe_14_ET_cbsdFrequencyGuidance_cleared_since_WF_ENH_GROUP_HANDLING_feature_not_supported

CBRS_CB008735_FeVe_15_ET_Grant_update_failed_since_relinquish_failed_106_when_SAS_not_support_WF_GRANT_UPDATE
    [Timeout]     20min
    [Setup]       Test Precondition    clean_bts=false
    [Teardown]    Test Postcondition
    [Tags]        BOAM_ET    CB008735    SBTS00
    CBRS_CB008735_FeVe_15_ET_Grant_update_failed_since_relinquish_failed_106_when_SAS_not_support_WF_GRANT_UPDATE

CBRS_CB008735_FeVe_16_ET_Grant_not_update_maxEirp_no_change_for_multi_cell_with_SAS_support_WF_GRANT_UPDATE
    [Timeout]     20min
    [Setup]       Test Precondition    clean_bts=false
    [Teardown]    Test Postcondition
    [Tags]        BOAM_ET    CB008735    SBTS00
    CBRS_CB008735_FeVe_16_ET_Grant_not_update_maxEirp_no_change_for_multi_cell_with_SAS_support_WF_GRANT_UPDATE

CBRS_CB008735_FeVe_17_ET_Relinquish_during_grant_update_higher_maxEirp_when_SAS_not_supports_WF_GRANT_UPDATE
    [Timeout]     20min
    [Setup]       Test Precondition    clean_bts=false
    [Teardown]    Test Postcondition
    [Tags]        BOAM_ET    CB008735    SBTS00
    CBRS_CB008735_FeVe_17_ET_Relinquish_during_grant_update_higher_maxEirp_when_SAS_not_supports_WF_GRANT_UPDATE

CBRS_CB008735_FeVe_18_ET_Grant_update_when_maxEirp_exceed_FCC_limit
    [Timeout]     20min
    [Setup]       Test Precondition    clean_bts=false
    [Teardown]    Test Postcondition
    [Tags]        BOAM_ET    CB008735    SBTS00
    CBRS_CB008735_FeVe_18_ET_Grant_update_when_maxEirp_exceed_FCC_limit

[1][2.0] CBRS_CB009800_CBRS_CB008735_FeVe_19_ET_Grant_update_failed_since_TS1_2_SAS_not_support_WF_GRANT_UPDATE ASOF
    [Timeout]     20min
    [Setup]       Test Precondition    clean_bts=false
    [Teardown]    Test Postcondition
    [Tags]        BOAM_ET    CB008735    SBTS00
    CBRS_CB008735_FeVe_19_ET_Grant_update_failed_since_TS1_2_SAS_not_support_WF_GRANT_UPDATE
