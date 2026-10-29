*** Settings ***
Documentation
...           Description :  Test Cases for 5G Counters CB012535
...           AUTHOR (I&V):  Yvan Maurin       yvan.maurin@nokia.com
...                       :  Youssef Leulmi    youssef.leulmi@nokia.com
...         Last update : 28.06.2023    Y. Maurin
...
...         TL req :
...         gNB Classical 1 x ASIK, 1 x ABIL, 1 RU cmW (AEQA)
...         UE Qualcomm
...         5G Real
...         CN Real


Variables         ../../../../resources/ST/python/custom.py
Resource          ../Resources/robot/5GCounters_SA_Uplink_Channel_Multiplexing_ON_1_Ue_PUSCH_FDM_resource_7827.robot

Suite Setup          5GCounters_Suite_Setup_youssef        gnb_id=${index_gnb}   direction=UL
Suite Teardown       5GCounters_Suite_Teardown     gnb_id=${index_gnb}


*** Variables ***
${ue_capability}=        REAL_ANDROID_UE
${dl_time_s}=            3000s
${ul_throughput}=        200M
${index_gnb}=            0
${index_ue}=             0
${M55308C00133}=             0


*** Test Case ***
[1][1.0] CB012535_SR_Counters_5G_M55308C00123_PUSCH_TRNS_FIRST_UL_SLOT
    [Setup]    Get Scout Bts Name
    [Teardown]    Run Keywords    Set Scout Confid Id    Share Scout Config Id
    #all trans sur firts slots
    5GCounters_TC_Check_PI_vs_l1l2   counter=M55308C00123   gnb_id=${index_gnb}    ue_id=${index_ue}

[1][1.0] CB012535_SR_Counters_5G_M55308C00124_PUSCH_TRNS_SECOND_UL_SLOT
    Set Tags    ${shared_config_id}
    5GCounters_TC_Check_PI_vs_l1l2   counter=M55308C00124   gnb_id=${index_gnb}    ue_id=${index_ue}

[1][1.0] CB012535_SR_Counters_5G_M55308C00125_PUSCH_TRNS_F_FIRST_UL_SLOT
    Set Tags    ${shared_config_id}
    5GCounters_TC_Check_PI_vs_l1l2   counter=M55308C00125   gnb_id=${index_gnb}    ue_id=${index_ue}

[1][1.0] CB012535_SR_Counters_5G_M55308C00126_PUSCH_TRNS_F_SECOND_UL_SLOT
    Set Tags    ${shared_config_id}
    5GCounters_TC_Check_PI_vs_l1l2   counter=M55308C00126   gnb_id=${index_gnb}    ue_id=${index_ue}

[1][1.0] CB012535_SR_Counters_5G_M55308C00135_AVG_MCS_PUSCH_256QAM_FRST_SLOT
    Set Tags    ${shared_config_id}
    5GCounters_TC_Check_PI_vs_l1l2   counter=M55308C00135   gnb_id=${index_gnb}    ue_id=${index_ue}

[1][1.0] CB012535_SR_Counters_5G_M55308C00136_AVG_MCS_PUSCH_256QAM_SCND_SLOT
    Set Tags    ${shared_config_id}
    5GCounters_TC_Check_PI_vs_l1l2   counter=M55308C00136   gnb_id=${index_gnb}    ue_id=${index_ue}




