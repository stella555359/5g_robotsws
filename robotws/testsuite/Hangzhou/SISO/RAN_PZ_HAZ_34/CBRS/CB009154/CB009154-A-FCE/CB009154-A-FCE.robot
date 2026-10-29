# *** Settings ***
# Suite Setup          Run Keywords    CBRS Suite Setup
# ...                  AND     Case Preparation
# Suite Teardown       CBRS Suite Teardown
# Test Setup           CBRS Test Setup
# Test Teardown        CBRS Test Teardown
# 
# Resource    Resources/CB009154-A_FCE_common_keywords.robot
# 
# Documentation
# ...    Author:wangqingqing
# ...    contact:qingqing.wang@nokia-sbell.com
# ...    squad group:SG_08
# ...    Feature CB009154
# 
# Force Tags            RAN_5G_TDD    5G_RAN_TDD    RAN_5G    5G_RAN    CRT_UTE    STATE_SW_UPLOADED    SBTS00
# ...    PY36
# ...    CLOUD_5G_CLASSICAL_SA_ASILL_ABIOL_AZQC
# 
# *** Variables ***
# 
# *** Test Cases ***
# [1]CB009154-A_FCE_Heartbeatresponse_0_featureCapabilityExchangeresponse_103
#     [Tags]    CRT_TRUNK
#     CB009154-A_FCE_Heartbeatresponse_0_featureCapabilityExchangeresponse_103
# 
# [1]CB009154-A_FCE_Heartbeatresponse_500_featureCapabilityExchangeresponse_102
#     [Tags]    CRT_TRUNK
#     CB009154-A_FCE_Heartbeatresponse_500_featureCapabilityExchangeresponse_102
# 
# [1]CB009154-A_FCE_SpectrumInquiryresponse_300_featureCapabilityExchangeresponse_101
#     [Tags]    CRT_TRUNK
#     CB009154-A_FCE_SpectrumInquiryresponse_300_featureCapabilityExchangeresponse_101
# 
# *** Keywords ***
