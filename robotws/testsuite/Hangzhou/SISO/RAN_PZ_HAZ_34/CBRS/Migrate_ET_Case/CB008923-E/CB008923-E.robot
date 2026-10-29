# *** Settings ***
# Suite Setup          Run Keywords     CBRS Suite Setup  AND  Case Preparation for CB008923-E
# #Suite Setup          CBRS Suite Setup
# Suite Teardown       CBRS Suite Teardown
# Test Setup           CBRS Test Setup
# Test Teardown        CBRS Test Teardown
# 
# Resource    ./Resources/CB008923-E-ET_common_keywords.robot
# Resource    testsuite/Hangzhou/SISO/RAN_PZ_HAZ_34/CBRS/resources/cbrs_common_keywords.robot
# 
# 
# Documentation
# ...    Author:Gao melinda
# ...    contact:melinda.gao@nokia-sbell.com
# ...    squad group:SG_08
# ...    Feature CB008923-E CBRS ET
# 
# Force Tags    SBTS00    CRT_TRUNK    CRT_23R1    CRT_23R2
# ...   PY36
# 
# *** Variables ***
# 
# *** Test Cases ***
# [1]CB008923-E_49_CBSD_TS20_supportGrantUpdate_desiredPmax_reach_maxEirp_more_channelType_same
#     CB008923-E_49_CBSD_TS20_supportGrantUpdate_desiredPmax_reach_maxEirp_more_channelType_same
# 
# [1]CB008923-E_74_CBSD_TS20_HB_modify_cbrsaGroupParam_trigger_re-registration
#     CB008923-E_74_CBSD_TS20_HB_modify_cbrsaGroupParam_trigger_re-registration
# 
# [1]CB008923-E_54_CBSD_TS20_supportGrantUpdate_GRANT_RC401
#     CB008923-E_54_CBSD_TS20_supportGrantUpdate_GRANT_RC401
# 
# [1]CB008923-E_63_CBSD_TS20_notSupportGrantUpdate_desiredPmax_not_reach_maxEirp_different_channelType_different
#     CB008923-E_63_CBSD_TS20_notSupportGrantUpdate_desiredPmax_not_reach_maxEirp_different_channelType_different
# 
# #[1]CB008923-E_16_CBSD_TS20_SI_RC300_featureCapabilityExchange
# #    CB008923-E_16_CBSD_TS20_SI_RC300_featureCapabilityExchange
# 
# [1]CB008923-E_24_CBSD_TS20_supportEnhGroupHandling_cbrsaVersion_mismatch_HB_trigger_re-registration
#     CB008923-E_24_CBSD_TS20_supportEnhGroupHandling_cbrsaVersion_mismatch_HB_trigger_re-registration
# 
# [1]CB008923-E_03_SAS-CBSD_TS2.0_new_parameter_through_domainProxy
#     CB008923-E_03_SAS-CBSD_TS2.0_new_parameter_through_domainProxy
# 
# [1]CB008923-E_04_CBSD_TS20_RC100_REG_trigger_TS12_re-registration
#     CB008923-E_04_CBSD_TS20_RC100_REG_trigger_TS12_re-registration
# 
# [1]CB008923-E_10_CBSD_TS20_RC100_HB_trigger_TS12_re-registration
#     CB008923-E_10_CBSD_TS20_RC100_HB_trigger_TS12_re-registration
# 
# #[1]CB008923-E_19_CBSD_TS20_HB_invalidRC400_featureCapabilityExchange
# #    CB008923-E_19_CBSD_TS20_HB_invalidRC400_featureCapabilityExchange
# 
# [1]CB008923-E_07_CBSD_TS20_HTTPSC404_SI_trigger_TS12_re-registration
#     CB008923-E_07_CBSD_TS20_HTTPSC404_SI_trigger_TS12_re-registration
# 
# [1]CB008923-E_42_CBSD_TS20_cbsdFrequencyGuidance_match_operationParam
#     CB008923-E_42_CBSD_TS20_cbsdFrequencyGuidance_match_operationParam
# 
# [1]CB008923-E_40_CBSD_TS20_cbsdFrequencyGuidance_match_supportedSpectrumV2_and_match_desiredChBw
#     CB008923-E_40_CBSD_TS20_cbsdFrequencyGuidance_match_supportedSpectrumV2_and_match_desiredChBw
# 
# [1]CB008923-E_38_CBSD_TS20_cbsdFrequencyGuidance_mismatch_supportedSpectrumV2
#     CB008923-E_38_CBSD_TS20_cbsdFrequencyGuidance_mismatch_supportedSpectrumV2
# 
# #[1]CB008923-E_31_CBSD_TS20_notSupportEnhGroupHandling_cbrsaVersion_mismatch_GRANT_not_trigger_re-registration
# #    CB008923-E_31_CBSD_TS20_notSupportEnhGroupHandling_cbrsaVersion_mismatch_GRANT_not_trigger_re-registration
# #
# #[1]CB008923-E_33_CBSD_TS20_notSupportEnhGroupHandling_eutraTddConfig_mismatch_HB_not_trigger_re-registration
# #    CB008923-E_33_CBSD_TS20_notSupportEnhGroupHandling_eutraTddConfig_mismatch_HB_not_trigger_re-registration
# 
# [1]CB008923-E_096_CBSD_FeatureCapabilityExchange_Check_after_SI_HB_error_code
#     CB008923-E_096_CBSD_FeatureCapabilityExchange_Check_after_SI_HB_error_code
# 
# [1]CB008923-E_104_CBSD_TS20_notSupportEnhGroupHandling_cbrsaVersion_eutraTddConfig_mismatch_GRANT_HB
#     CB008923-E_104_CBSD_TS20_notSupportEnhGroupHandling_cbrsaVersion_eutraTddConfig_mismatch_GRANT_HB
# *** Keywords ***
