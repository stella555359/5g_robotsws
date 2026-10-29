# *** Settings ***
# Documentation
# ...    Author: Lu Ming
# ...    Contact: ming.lun@nokia-sbell.com
# ...    squad SG_01
# ...    Feature 5GC001473-A-G-H in 5G20B program
# 
# Force Tags       
# ...    PY36
# 
# Suite Setup         Setup suite
# Suite Teardown      Teardown Suite
# Resource          Resource/5GC001473_Resources.robot
# 
# *** Variables ***
# 
# 
# *** Test Cases ***
# [1]Cell_Setup_With_Configed_BandWidth
#     [Documentation]  5GC001473-A The purpose of this case is to test NSA cell on air with bandwidth 90M with CPRI AZQG RU
#     [Tags]    CDRT_20B    CRT_21A
#     [Setup]    Setup case
#     [Teardown]  Teardown case
#     TC.Cell_Setup_With_Configed_BandWidth
# 
# #[1]Cell_Setup_With_Configed_BandWidth_SA
# #    [Documentation]  5GC001473-A The purpose of this case is to test SA cell on air with bandwidth 90M with CPRI AZQG RU
# #    [Tags]    TA
# #    [Setup]    Setup case
# #    [Teardown]  Teardown case
# #    TC.Cell_Setup_With_Configed_BandWidth_SA
# 
# [1]L3_Call_Setup_With_Configed_BandWidth
#     [Documentation]  5GC001473-A The purpose of this case is to test SA L3CALL to bandwidth 90M SA cell with CPRI AZQG RU
#     [Tags]    CRT_21A    CRT_TRUNK   CDRT_20B
#     [Setup]    Setup case
#     [Teardown]  Teardown case
#     TC.L3_Call_Setup_With_Configed_BandWidth
# 
# [1]UL_and_DL_LA_data_traffic_QAM64_2x2MIMO_SA
#     [Documentation]  5GC001473-G The purpose of this case is to test SA 2x2 64qam data traffic of 90M bandwidth SA cell
#     ...              with CPRI AZQG RU
#     [Tags]    CRT_21A   CRT_20B
#     [Setup]    Setup case
#     [Teardown]  Teardown case
#     TC.UL_and_DL_LA_data_traffic_QAM64_2x2MIMO_SA
# 
# [1]UL_and_DL_LA_Peak_QAM256_2x2MIMO_SA
#     [Documentation]  5GC001473-H The purpose of this case is to test SA 2x2 256qam peak data traffic of  90M bandwidth
#     ...              SA cell with CPRI AZQG RU
#     [Tags]    CRT_21A   CRT_20B
#     [Setup]    Setup case
#     [Teardown]  Teardown case
#     TC.UL_and_DL_LA_Peak_QAM256_2x2MIMO_SA
# 
# [1]UL_and_DL_LA_data_traffic_QAM256_4x4MIMO_SA
#     [Documentation]  5GC001473-H The purpose of this case is to test SA dl 4layer 256qam data traffic of 90M bandwidth
#     ...              SA cell with CPRI AZQG RU
#     [Tags]    CRT_21A   CRT_20B
#     [Setup]    Setup case
#     [Teardown]  Teardown case
#     TC.UL_and_DL_LA_data_traffic_QAM256_4x4MIMO_SA
# 
# 
# 
