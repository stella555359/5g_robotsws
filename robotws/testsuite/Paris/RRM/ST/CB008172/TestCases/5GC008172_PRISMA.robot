*** Settings ***
Documentation
...     Test Suite Purpose:


Variables         ../../../../resources/ST/python/custom.py
Resource          ../Resources/robot/5GC008172_res.robot


Force Tags           5G_RAN     STATE_ON_AIR

Suite Setup       My_Suite01_Setup
Suite Teardown    My_Suite01_Teardown


*** Variables ***
${swconfig_8172_metric_based}=           swconfig_8172_metric_based.txt
${swconfig_8172_round_robin}=            swconfig_8172_round_robin.txt
${source_gnb}=               0
${dl_time_s}=                60s
${dl_throughput}=            150M
${ul_time_s}=                60s
${ul_throughput}=            50M
# only for Prisma UE
${TC01_prisma_sce}=      CV66_NSA_Att_Det_IPERF_4UE.sce
${TC02_prisma_sce}=      CV66_NSA_Att_Det_IPERF_multiUE_blabla.sce
${scenario_prisma_file_name}
@{UE_LIST}              1   2   3   4


*** Test Cases ***
[1][1.0] CB008172_001_FeatureActivation_3S_8DL_4UL_SpatialStreamPoolingON_RoundRobin_MU_MiMO_FD_BF_100Mhz_SemiStatic_3_7
    [Setup]    Get Scout Bts Name
    [Tags]     Prisma   CV66   TC1
    set suite variable    ${scenario_prisma_file_name}    ${TC01_prisma_sce}
    #TC_01_SCENARIO_ACT_8172
    #TC_02_SCENARIO_DEACT_8172
    TC_tempo
    [Teardown]    Set Scout Confid Id
