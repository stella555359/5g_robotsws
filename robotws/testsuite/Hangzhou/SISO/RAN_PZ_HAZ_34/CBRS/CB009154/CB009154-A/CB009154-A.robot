# *** Settings ***
# Suite Setup          Run Keywords    CBRS Suite Setup
# ...                  AND     Case Preparation
# Suite Teardown       CBRS Suite Teardown
# Test Setup           CBRS Test Setup
# Test Teardown        CBRS Test Teardown
# 
# Resource    Resources/CB009154-A_common_keywords.robot
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
# 
# *** Variables ***
# 
# *** Test Cases ***
# [1]CB009154-A_17_Verify_the_behavior_of_heartbeat_with_MaxEIRP_ChannelType_different_GRANT_UPDATE_supported_TS2.0
#     [Tags]    CRT_TRUNK    CRT_23R1
#     CB009154-A_17_Verify_the_behavior_of_heartbeat_with_MaxEIRP_ChannelType_different_GRANT_UPDATE_supported_TS2.0
# 
# [1]CB009154-A_20_Verify_the_behavior_of_heartbeat_with_MaxEIRP_ChannelType_different_GRANT_UPDATE_unsupported_TS2.0
#     [Tags]    CRT_TRUNK    CRT_23R1
#     CB009154-A_20_Verify_the_behavior_of_heartbeat_with_MaxEIRP_ChannelType_different_GRANT_UPDATE_unsupported_TS2.0
# 
# [1]CB009154-A_21_Verify_the_behavior_of_CBSD_with_online_modifying_cbrsaGroupIdIcg_or_cbrasGroupIdCcg_TS2.0
#     [Tags]    CRT_TRUNK    CRT_23R1
#     CB009154-A_21_Verify_the_behavior_of_CBSD_with_online_modifying_cbrsaGroupIdIcg_or_cbrasGroupIdCcg_TS2.0
# 
# [1]CB009154-A_26_Verify_the_behavior_of_heartbeat_with_maxEirp_different_between_operationParam_and_grant_when_WF_GRANT_UPDATE_supported_TS1.2
#     [Tags]    CRT_TRUNK    CRT_23R1
#     CB009154-A_26_Verify_the_behavior_of_heartbeat_with_maxEirp_different_between_operationParam_and_grant_when_WF_GRANT_UPDATE_supported_TS1.2
# 
# [1]CB009154-A_29_Verify_the_behavior_of_heartbeat_with_maxEirp_different_between_operationParam_and_grant_when_WF_GRANT_UPDATE_unsupported_TS1.2
#     [Tags]    CRT_TRUNK    CRT_23R1
#     CB009154-A_29_Verify_the_behavior_of_heartbeat_with_maxEirp_different_between_operationParam_and_grant_when_WF_GRANT_UPDATE_unsupported_TS1.2
# 
# [1]CB009154-A_13_Verify_the_behavior_of_Heartbeat_failure_with_responseCode_500_TS2.0
#     [Tags]    CRT_TRUNK    CRT_23R1
#     CB009154-A_13_Verify_the_behavior_of_Heartbeat_failure_with_responseCode_500_TS2.0
# 
# [1]CB009154-A_22_Verify_the_behavior_of_CBSD_with_online_modifying_phyCellId_or_signalEcgi_related_parameters_TS2.0
#     [Tags]    CRT_TRUNK    CRT_23R1
#     CB009154-A_22_Verify_the_behavior_of_CBSD_with_online_modifying_phyCellId_or_signalEcgi_related_parameters_TS2.0
# 
# [1]CB009154-A_27_gNB CBSD Cell Activation - TS version 2.0_1NR_concurrency_SBTS
#     [Tags]    CRT_TRUNK    CRT_23R1
#     CB009154-A_27_gNB CBSD Cell Activation - TS version 2.0_1NR_concurrency_SBTS
# 
# *** Keywords ***
