# *** Settings ***
# Documentation    author:Liu Tiffany
# ...              contact: n5liu@nokia-sbell.com
# ...                History: Do some adaption for CB006443 by LiuNing
# ...                History: Do some adaption for CB008181 by LiuNing
# ...               feature : CB008181
# Suite Setup       KW.TestSuilt.Start     Stream_Master=${KPI['Stream_Version']}
# Suite Teardown    KW.TestSuilt.Stop
# Force Tags    CRT_22R3
# Resource           ../CB008181/Resources/CB008181_KW_interface.robot
# 
# *** Test Cases ***
# [1]Gen5_OAM_KPI_1a_Site_Reset_Outage_Duration_Single_Core
#     [Documentation]     KPI1A
#     [Tags]     CDRT_22R3
#     [Setup]    SetUp Case
#     [Teardown]  Teardown case
#     TC.CB006443_HA_01_OAM_KPI_1a_Site_Reset_Outage_Duration_Single_Core
#     ...    WebUI_reset_times=${KPI['CB008181_KPI1a']['CNF_5G_18']['WebUI_reset_times_CDRT']}
#     ...    KPI1a_MAX=${KPI['CB008181_KPI1a']['CNF_5G_18']['KPI1a_MAX']}
#     ...    KPI1a_AVG=${KPI['CB008181_KPI1a']['CNF_5G_18']['KPI1a_AVG']}
# 
# [1]Gen5_OAM_KPI_61a_Site_Reset_Startup_Success_Rate
#     [Documentation]     KPI61A
#     [Tags]     CDRT_22R3
#     [Setup]     TestCase.Start
#     [Teardown]  TestCase.Stop
#     TC.CB006443_HA_03_OAM_KPI_61a_Software_Reset_Startup_Success_Rate
# 
# 
# [1]Gen5_OAM_KPI_51a_RU_Reset_Time
#     [Documentation]
#     [Tags]     CDRT_22R3
#     [Setup]    SetUp Case
#     [Teardown]  Teardown case
#     TC.CB006443_HA_03_OAM_KPI_51a_RU_Reset_Time
#     ...    RF_reset_times=${KPI['CB008181_KPI51a']['RF_reset_times_CDRT']}
#     ...    KPI51_MAX=${KPI['CB008181_KPI51a']['KPI51a_MAX']}
#     ...    KPI51_AVG=${KPI['CB008181_KPI51a']['KPI51a_AVG']}
# 
# 
# [1]Gen5_OAM_KPI_651_RU_Reset_Startup_Success_Rate
#      [Documentation]     KPI651
#     [Tags]     CDRT_22R3
#     [Setup]     SetUp Case
#     [Teardown]   Teardown case
#     TC.CB006443_HA_09_OAM_KPI_651_RU_Software_Reset_Startup_Success_Rate
# 
# 
# [1]Gen5_OAM_KPI_17_Cell_Block_Unblock_manually
#     [Documentation]    KPI17
#     [Tags]     CDRT_22R3
#     [Setup]    SetUp Case
#     [Teardown]  Run Keywords      run keyword and ignore error    Teardown case
#                ...   AND    run keyword and ignore error  DisConnect to DU by ADMIN API
#     TC.CB006443_HA_05_OAM_KPI_17_Cell_Block_Unblock_manually
# 	...    repeat_times=${KPI['CB008181_KPI17']['cell_block_times_CDRT']}
# 
# 
# [1]Gen5_OAM_KPI_3_Power_Reset_Outage_Duration_Single_Core
#     [Documentation]     KPI3
#     [Tags]     CDRT_22R3
#     [Setup]    SetUp Case
#     [Teardown]  Teardown case
#     TC.CB006443_HA_04_OAM_KPI_3_Power_Reset_Outage_Duration_Single_Core
#     ...    Power_reset_times=${KPI['CB008181_KPI3']['CNF_5G_18']['Power_reset_times_CDRT']}
#     ...     KPI3_MAX=${KPI['CB008181_KPI3']['CNF_5G_18']['KPI3_MAX']}
#     ...    KPI3_AVG=${KPI['CB008181_KPI3']['CNF_5G_18']['KPI3_AVG']}
#     ...    fail_loop_max=${KPI['CB008181_KPI3']['CNF_5G_18']['fail_loop_max']}
# 
# [1]Gen5_OAM_KPI_63_Power_Reset_Startup_Success_Rate
#    [Documentation]     KPI63
#     [Tags]     CDRT_22R3
#    [Setup]     TestCase.Start
#    [Teardown]  TestCase.Stop
#    TC.CB006443_HA_06_OAM_KPI_63_Power_Reset_Success_Rate
# 
# 
# 
# 
# 
# 
# 
# 
# 
# 
# 
