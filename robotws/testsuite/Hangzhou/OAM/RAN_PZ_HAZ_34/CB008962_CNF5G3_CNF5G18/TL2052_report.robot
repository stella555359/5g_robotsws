# *** Settings ***
# Documentation    author:Liu Tiffany
# ...              contact: n5liu@nokia-sbell.com
# ...                History: Do some adaption for CB006443 by LiuNing
# ...                History: Do some adaption for CB008181 by LiuNing
# ...               feature : CB008181
# Suite Setup       KW.TestSuilt.Start     Stream_Master=${KPI_8962['Stream_Version']}
# ...    Original_Stream_list=${KPI_8962['CB008962_IA']['OriginalStream']}
# Suite Teardown    KW.TestSuilt.Stop
# Force Tags        CRT_22R3
# Resource            ../CB006443/Resources/All_KW_Interface.robot
# 
# *** Variables ***
# ${REFERENCE_CONFIGURATION_ID}    CNF_5G_3
# 
# *** Test Cases ***
# [1]Gen4_OAM_KPI_1a_Site_Reset_Outage_Duration_Single_Core
#     [Documentation]     KPI1A
#     [Tags]     CDRT_TRUNK
#     [Setup]    SetUp Case
#     [Teardown]  Teardown case
#     TC.CB006443_HA_01_OAM_KPI_1a_Site_Reset_Outage_Duration_Single_Core
#     ...    WebUI_reset_times=${30}
#     ...    KPI1a_MAX=${KPI_8962['CB008962_KPI1a']['CNF_5G_3']['KPI1a_MAX']}
#     ...    KPI1a_AVG=${KPI_8962['CB008962_KPI1a']['CNF_5G_3']['KPI1a_AVG']}
# 
# [1]Gen4_OAM_KPI_3_Power_Reset_Outage_Duration_Single_Core
#     [Documentation]
#     [Tags]     CDRT_TRUNK
#     [Setup]    SetUp Case
#     [Teardown]  Teardown case
#     TC.CB006443_HA_04_OAM_KPI_3_Power_Reset_Outage_Duration_Single_Core
#     ...    Power_reset_times=${30}
#     ...     KPI3_MAX=${KPI_8962['CB008962_KPI3']['CNF_5G_3']['KPI3_MAX']}
#     ...    KPI3_AVG=${KPI_8962['CB008962_KPI3']['CNF_5G_3']['KPI3_AVG']}
#     ...    fail_loop_max=${KPI_8962['CB008962_KPI3']['CNF_5G_3']['fail_loop_max']}
# 
# [1]Gen4_OAM_KPI_51a_RU_Reset_Time
#     [Documentation]
#     [Tags]     CDRT_TRUNK
#     [Setup]    SetUp Case
#     [Teardown]  Teardown case
#     TC.CB006443_HA_03_OAM_KPI_51a_RU_Reset_Time
#     ...    RF_reset_times=${30}
#     ...    KPI51_MAX=${KPI_8962['CB008962_KPI51a']['KPI51a_MAX']}
#     ...    KPI51_AVG=${KPI_8962['CB008962_KPI51a']['KPI51a_AVG']}
# 
# [1]Gen4_OAM_KPI_17_Cell_Block_Unblock_manually
#     [Documentation]
#     [Tags]     CDRT_TRUNK
#     [Setup]    SetUp Case
#     [Teardown]  Run Keywords      run keyword and ignore error    Teardown case
#                ...   AND    run keyword and ignore error  DisConnect to DU by ADMIN API
#     TC.CB006443_HA_05_OAM_KPI_17_Cell_Block_Unblock_manually
# 	...    repeat_times=${30}
# 
# [1]20_OAM_KPI_16_cell_lock_unlock
#    [Setup]    SetUp Case
#    [Teardown]  Teardown case
#     RUN KEYWORD AND CONTINUE ON FAILURE
#     ...    TC.OAM_KPI_16_Cell_lock_Unlock
#     ...    KPI16a=${KPI_8962['KPI16']['KPI16a']}
#     ...    KPI16b=${KPI_8962['KPI16']['KPI16b']}
#     #...    repeat_times=${KPI_8962['KPI16']['test_loops']}
#     ...    repeat_times=${30}
# 
# [1]OAM_KPI_12_Commission_with_Site_Reset
#    [Documentation]    KPI12
#    [Setup]    SetUp Case
#    [Teardown]  Teardown case
#    TC.OAM_KPI_12_Commission_with_Site_Reset
#     ...    WebUI_reset_times=${30}
#     ...    min_duration=1
#     ...    max_duration=10
#     ...    Snapshot=${True}
#     #...    WebUI_reset_times=${KPI_8962['KPI12']['CNF_5G_18']['test_loops']}
#     ...    fail_loops=${KPI_8962['KPI12']['CNF_5G_18']['fail_loops']}
#     ...    KPI12_MAX=${KPI_8962['KPI12']['CNF_5G_18']['KPI12_MAX']}
#     ...    KPI12_AVG=${KPI_8962['KPI12']['CNF_5G_18']['KPI12_AVG']}
# 
# [1]CB006443_HA_06_OAM_KPI_5_Capacity_Module_Reset_Outage_Duration
#    [Setup]    SetUp Case
#    [Teardown]  Teardown case
#     RUN KEYWORD AND CONTINUE ON FAILURE
#     ...    TC.CB006443_HA_06_OAM_KPI_5_Capacity_Module_Reset_Outage_Duration
#     ...    KPI5_MAX=${CASE_INPUT_CB006443['CB006443_HA_KPI5']['KPI5_MAX']}
#     #...    repeat_times=${CASE_INPUT_CB006443['CB006443_HA_KPI5']['BBMOD_reset_times']}
#     ...    fail_loop_max=${CASE_INPUT_CB006443['CB006443_HA_KPI5']['fail_loop_max']}
#     ...    repeat_times=${30}
# 
# 
# [1]CB006443_HA_04_OAM_KPI_54a_RU_cold_Reset_Time
#      [Documentation]
#      [Tags]     CB006443
#      [Setup]    SetUp Case
#      [Teardown]  Teardown case
#      TC.CB006443_HA_04_OAM_KPI_54a_RU_cold_Reset_Time
#      ...    KPI54A_MAX=${CASE_INPUT_CB006443['CB006443_KPI54A']['KPI54A_MAX']}
#      #...    repeat_times=${CASE_INPUT_CB006443['CB006443_KPI54A']['ru_reset_times']}
#      ...    fail_loop_max=${CASE_INPUT_CB006443['CB006443_KPI54A']['fail_loop_max']}
#      ...    repeat_times=${30}
# 
# 
# 
# 
# 
# 
# 
# 
