# *** Settings ***
# Suite Setup          CB009154-A ET CBRS Suite Setup
# Suite Teardown       CBRS Suite Teardown
# Test Setup           CBRS Test Setup
# Test Teardown        CBRS Test Teardown
# 
# 
# Resource    Resources/CB009154_A_ET_common_keywords.robot
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
# [1]CB009154-A_5_REG_TS20_No_SasfeatureCapabilityList_Trigger_Deregister_Then_Reg_In_TS12
#     [Tags]    CRT_TRUNK
#     CB009154-A_5_REG_TS20_No_SasfeatureCapabilityList_Trigger_Deregister_Then_Reg_In_TS12
# 
# [1]CB009154-A_9_REG_CbrsaVersion_Mismatch_Retry_Registration_TS20
#     [Tags]    CRT_TRUNK
#     CB009154-A_9_REG_CbrsaVersion_Mismatch_Retry_Registration_TS20
# 
# [1]CB009154-A_76_HB_With_OperationParam_Is_Diffenent_ChannelType_Support_WF_GRANT_UPDATE
#     [Tags]    CRT_TRUNK
#     CB009154-A_76_HB_With_OperationParam_Is_Diffenent_ChannelType_Support_WF_GRANT_UPDATE
# 
# [1]CB009154-A_78_HB_With_OperationParam_Is_Diffenent_ChannelType_No_WF_GRANT_UPDATE
#     [Tags]    CRT_TRUNK
#     CB009154-A_78_HB_With_OperationParam_Is_Diffenent_ChannelType_No_WF_GRANT_UPDATE
# 
# [1]CB009154-A_73_HB_With_OperationParam_Is_Notchange_MaxEirp_Support_WF_GRANT_UPDATE
#     [Tags]    CRT_TRUNK
#     CB009154-A_73_HB_With_OperationParam_Is_Notchange_MaxEirp_Support_WF_GRANT_UPDATE
# 
# [1]CB009154-A_74_HB_With_OperationParam_Is_Unusable_MaxEirp_Support_WF_GRANT_UPDATE
#     [Tags]    CRT_TRUNK
#     CB009154-A_74_HB_With_OperationParam_Is_Unusable_MaxEirp_Support_WF_GRANT_UPDATE
# 
# [1]CB009154-A_90_Grant_update_failed_responseCode_Grant_Conflict_401_TS20
#     [Tags]    CRT_TRUNK
#     CB009154-A_90_Grant_update_failed_responseCode_Grant_Conflict_401_TS20
# 
# [1]CB009154-A_91_HB_With_Second_Grant_RC401_No_WF_GRANT_UPDATE_TS20
#     [Tags]    CRT_TRUNK
#     CB009154-A_91_HB_With_Second_Grant_RC401_No_WF_GRANT_UPDATE_TS20
# 
# [1]CB009154-A_95_Grant_Update_Failed_Since_Relinquish_Failed_With_106_When_Sas_Not_Support_WF_GRANT_UPDATE
#     [Tags]    CRT_TRUNK
#     CB009154-A_95_Grant_Update_Failed_Since_Relinquish_Failed_With_106_When_Sas_Not_Support_WF_GRANT_UPDATE
# 
# [1]CB009154-A_104_Grant_Update_When_Maxeirp_Exceed_FCC_Limit
#     [Tags]    CRT_TRUNK
#     CB009154-A_104_Grant_Update_When_Maxeirp_Exceed_FCC_Limit
# 
# [1]CB009154-A_97_Grant_Update_MaxEirp_Higher_Together_With_Heartbeat_500
#     [Tags]    CRT_TRUNK
#     CB009154-A_97_Grant_Update_MaxEirp_Higher_Together_With_Heartbeat_500
# 
# [1]CB009154-A_65_2_20Mhz_Cells_With_5M_Boundary_With_CbsdFrequencyGuidance_Update_Can_Be_OnAir
#     [Tags]    CRT_TRUNK
#     CB009154-A_65_2_20Mhz_Cells_With_5M_Boundary_With_CbsdFrequencyGuidance_Update_Can_Be_OnAir