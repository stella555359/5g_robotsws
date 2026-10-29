# *** Settings ***
# Documentation    author:Zhang Xuewen
# ...              contact: xuewen.zhang@nokia-sbell.com
# ...                History: Do some adaption for CB008681
# ...               feature : CB008681
# Suite Setup       KW.TestSuilt.Start
# Suite Teardown    KW.TestSuilt.Stop
# Force Tags        CRT_22R4
# Resource           Resources/OMKPI_KW_interface.robot
# 
# *** Test Cases ***
# ###############################The below is just for CB008681 regression############################################
# [1]CB008681-SR-C-13-Manual_Site_reset_downtime_KPI#1a
#     [Documentation]     KPI1A
#     [Tags]     CDRT_22R4
#     [Setup]    SetUp Case
#     [Teardown]  Teardown case
#     ${gNBMode}    gNB.CheckgNBCoreMode
#     ${KPI1a_MAX}=    Set Variable if   "${gNBMode}"=="Dualcore"   ${KPI['CB008457_KPI1a']['CNF_5G_11']['KPI1a_MAX']}
#     ...    ${KPI['CB008457_KPI1a']['CNF_5G_25']['KPI1a_MAX']}
#     ${KPI1a_AVG}=    Set Variable if   "${gNBMode}"=="Dualcore"   ${KPI['CB008457_KPI1a']['CNF_5G_11']['KPI1a_AVG']}
#     ...    ${KPI['CB008457_KPI1a']['CNF_5G_25']['KPI1a_AVG']}
#     ${RMOD_name_list}=   DU_WebEM.Get RMOD NAME
#     ${KPI1a_AVG}=    Set Variable If    "AHFII" in ${RMOD_name_list} or "AZQF" in ${RMOD_name_list}
#     ...       ${KPI['CB008457_KPI1a']['CNF_5G_25']['KPI1a_AVG']}    ${KPI1a_AVG}
#     ${KPI1a_MAX}=    Set Variable If    "AHFII" in ${RMOD_name_list} or "AZQF" in ${RMOD_name_list}
#     ...       ${KPI['CB008457_KPI1a']['CNF_5G_25']['KPI1a_MAX']}    ${KPI1a_MAX}
#     TC.OAM_KPI_1a_Site_Reset_Outage_Duration_Single_Core
#     ...    WebUI_reset_times=${KPI['CB008457_KPI1a']['WebUI_reset_times']}
#     ...    KPI1a_MAX=${KPI1a_MAX}
#     ...    KPI1a_AVG=${KPI1a_AVG}
# 
# [1]CB008681-SR-C-05-Power_on_startup_availability_KPI#3
#     [Documentation]     KPI3
#     [Tags]     CDRT_22R4
#     [Setup]    SetUp Case
#     [Teardown]  Teardown case
#     gNB.CheckgNBCoreMode
#     ${gNBMode}    gNB.CheckgNBCoreMode
#     ${KPI3_MAX}=    Set Variable if   "${gNBMode}"=="Dualcore"   ${KPI['CB008457_KPI3']['CNF_5G_11']['KPI3_MAX']}
#     ...    ${KPI['CB008457_KPI3']['CNF_5G_25']['KPI3_MAX']}
#     ${KPI3_AVG}=    Set Variable if   "${gNBMode}"=="Dualcore"   ${KPI['CB008457_KPI3']['CNF_5G_11']['KPI3_AVG']}
#     ...    ${KPI['CB008457_KPI3']['CNF_5G_25']['KPI3_AVG']}
#     TC.OAM_KPI_3_Power_Reset_Outage_Duration_Single_Core
#     ...    Power_reset_times=${KPI['CB008457_KPI3']['Power_reset_times']}
#     ...    KPI3_MAX=${KPI3_MAX}
#     ...    KPI3_AVG=${KPI3_AVG}
#     ...    fail_loop_max=${KPI['CB008457_KPI3']['fail_loop_max']}
# 
# [1]CB008681-SR-C-08-Manual_5GRAT_reset_downtime_KPI#10
#     [Documentation]    KPI10
#     [Tags]     CDRT_22R4
#     [Setup]    SetUp Case
#     [Teardown]  Teardown case
#     TC.OAM_KPI_10_5G_RAT_reset
#     ...    repeat_times=${KPI['CB008457_KPI10']['5GRAT_reset_times']}
#     ...    KPI10=${KPI['CB008457_KPI10']['KPI10']}
#     ...    DualCoreExtend=${KPI['CB008457_KPI10']['DualCoreExtend']}
#     ...    NSAExtend=${KPI['CB008457_KPI10']['NSAExtend']}
# 
# 
# [1]CB008681-SR-C-07-Manual_capacity_module_reset_downtime_KPI#5
#     [Documentation]    KPI5
#     [Tags]     CDRT_22R4
#     [Setup]    SetUp Case
#     [Teardown]  Teardown case
#     TC.OAM_KPI_5_Capacity_Module_Reset_Outage_Duration
#     ...    KPI5_MAX=${KPI['CB008457_KPI5']['KPI5_MAX']}
#     ...    repeat_times=${KPI['CB008457_KPI5']['BBMOD_reset_times']}
#     ...    fail_loop_max=${KPI['CB008457_KPI5']['fail_loop_max']}
# 
# [1]CB008681-SR-C-09-Manual_lock_unlock_cell_downtime_KPI#16a_KPI#16b
#     [Documentation]     KPI16
#     [Tags]     CDRT_22R4
#     [Setup]    SetUp Case
#     [Teardown]  Teardown case
#     TC.OAM_KPI_16_Cell_Lock_Unclock
#     ...    KPI16a=${KPI['CB008457_KPI16a']['KPI16a_MAX']}
#     ...    KPI16b=${KPI['CB008457_KPI16b']['KPI16b_MAX']}
#     ...    repeat_times=${KPI['CB008457_KPI16a']['lock_cell_times']}
#     ...    fail_times=${KPI['CB008457_KPI16a']['fail_times']}
# 
# [1]CB008681-SR-C-10-Manual_block_unblock_cell_downtime_KPI#17a_KPI#17b
#     [Documentation]    KPI17
#     [Tags]     CDRT_22R4
#     [Setup]    SetUp Case
#     [Teardown]  Run Keywords      run keyword and ignore error    Teardown case
#                ...   AND    run keyword and ignore error  DisConnect to DU by ADMIN API
#     TC.OAM_KPI_17_Cell_Block_Unblock_manually
# 	...    KPI17a=${KPI['CB008457_KPI17a']['KPI17a_MAX']}
#     ...    KPI17b=${KPI['CB008457_KPI17b']['KPI17b_MAX']}
#     ...    repeat_times=${KPI['CB008457_KPI17a']['cell_block_times']}
# 
# [1]CB008681-SR-C-12-Manual_RU_reset_downtime_KPI#51a
#     [Documentation]    KPI51a
#     [Tags]     CDRT_22R4
#     [Setup]    SetUp Case
#     [Teardown]  Teardown case
#     TC.OAM_KPI_51a_RU_Reset_Time
#     ...    RF_reset_times=${KPI['CB008457_KPI51']['ru_reset_times']}
#     ...    KPI51_MAX=${KPI['CB008457_KPI51']['KPI51_MAX']}
#     ...    KPI51_AVG=${KPI['CB008457_KPI51']['KPI51_AVG']}
# 
# [1]CB008681-SR-C-11-RU_power_on_reset_cold_startup_downtime_KPI#54a
#     [Documentation]    KPI54a
#     [Tags]     CDRT_22R4
#     [Setup]    SetUp Case
#     [Teardown]  Teardown case
#     TC.OAM_KPI_54a_RU_cold_Reset_Time
#     ...    KPI54A_MAX=${KPI['CB008457_KPI54']['KPI54A_MAX']}
#     ...    repeat_times=${KPI['CB008457_KPI54']['ru_reset_times']}
#     ...    fail_loop_max=${KPI['CB008457_KPI54']['fail_loop_max']}
# 
# *** Keywords ***
