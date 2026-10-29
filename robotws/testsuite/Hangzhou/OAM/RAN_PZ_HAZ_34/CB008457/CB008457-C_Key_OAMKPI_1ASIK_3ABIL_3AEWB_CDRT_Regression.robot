# *** Settings ***
# Documentation    author:Liu Tiffany
# ...              contact: n5liu@nokia-sbell.com
# ...                History: Do some adaption for CB006443 by LiuNing
# ...                History: Do some adaption for CB008181 by LiuNing
# ...               feature : CB008457
# Suite Setup       KW.TestSuilt.Start     Stream_Master=${KPI['Stream_Version']}
# ...    Original_Stream_list=${KPI['CB008457_IA']['OriginalStream']}
# Suite Teardown    KW.TestSuilt.Stop
# Force Tags     CRT_22R4
# Resource           ../CB008457/Resources/CB008457_KW_interface.robot
# 
# *** Test Cases ***
# 
# [1]Gen4_OAM_KPI_1a_Site_Reset_Outage_Duration_Single_Core
#     [Documentation]     KPI1A
#     [Tags]     CDRT_22R4
#     [Setup]    SetUp Case
#     [Teardown]  Teardown case
#     TC.CB006443_HA_01_OAM_KPI_1a_Site_Reset_Outage_Duration_Single_Core
#     ...    WebUI_reset_times=${KPI['CB008457_KPI1a']['CNF_5G_3']['WebUI_reset_times']}
#     ...    KPI1a_MAX=${KPI['CB008457_KPI1a']['CNF_5G_3']['KPI1a_MAX']}
#     ...    KPI1a_AVG=${KPI['CB008457_KPI1a']['CNF_5G_3']['KPI1a_AVG']}
# 
# [1]Gen4_OAM_KPI_3_Power_Reset_Outage_Duration_Single_Core
#     [Documentation]     KPI3
#     [Tags]     CDRT_22R4
#     [Setup]    SetUp Case
#     [Teardown]  Teardown case
#     TC.CB006443_HA_04_OAM_KPI_3_Power_Reset_Outage_Duration_Single_Core
#     ...    Power_reset_times=${KPI['CB008457_KPI3']['CNF_5G_3']['Power_reset_times']}
#     ...     KPI3_MAX=${KPI['CB008457_KPI3']['CNF_5G_3']['KPI3_MAX']}
#     ...    KPI3_AVG=${KPI['CB008457_KPI3']['CNF_5G_3']['KPI3_AVG']}
# 
# [1]Gen4_OAM_KPI_51a_RU_Reset_Time
#     [Documentation]    KPI51a
#     [Tags]     CDRT_22R4
#     [Setup]    SetUp Case
#     [Teardown]  Teardown case
#     TC.CB006443_HA_03_OAM_KPI_51a_RU_Reset_Time
#     ...    RF_reset_times=${KPI['CB008457_KPI51a']['RF_reset_times']}
#     ...    KPI51_MAX=${KPI['CB008457_KPI51a']['KPI51a_MAX']}
#     ...    KPI51_AVG=${KPI['CB008457_KPI51a']['KPI51a_AVG']}
# 
# [1]Gen4_OAM_KPI_17_Cell_Block_Unblock_manually
#     [Documentation]    KPI17
#     [Tags]     CDRT_22R4
#     [Setup]    SetUp Case
#     [Teardown]  Run Keywords      run keyword and ignore error    Teardown case
#                ...   AND    run keyword and ignore error  DisConnect to DU by ADMIN API
#     TC.CB006443_HA_05_OAM_KPI_17_Cell_Block_Unblock_manually
# 	...    repeat_times=${KPI['CB008457_KPI17']['cell_block_times']}
# 
# 
