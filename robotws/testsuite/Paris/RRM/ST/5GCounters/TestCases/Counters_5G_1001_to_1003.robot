*** Settings ***
Documentation
...           Description :  Test Cases for 5G Counters Downlink PDSCH
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

#Force Tags      CA_RAN_PZ_NPS    QCD_MN_RAN    QCP_RAN_ST   SBTS00   SBTS22R4    SBTS22R3

Suite Setup          5GCounters_Suite_Setup        gnb_id=${index_gnb}
Suite Teardown       5GCounters_Suite_Teardown     gnb_id=${index_gnb}


*** Variables ***
${ue_capability}=        REAL_ANDROID_UE
${dl_time_s}=            3000s
${dl_throughput}=        600M
${index_gnb}=            0
${index_ue}=             0

*** Test Case ***
[1][1.0] Counters_5G_1001_M55301C01000_PDSCH_RANK2_64TBL_MCS_00
    [Setup]    Get Scout Bts Name
    [Teardown]    Run Keywords    Set Scout Confid Id     Share Scout Config Id
    5GCounters_TC_Check_PI_vs_l1l2   counter=M55301C01000   gnb_id=${index_gnb}    ue_id=${index_ue}

[1][1.0] Counters_5G_1002_M55301C01001_PDSCH_RANK2_64TBL_MCS_01
    [Setup]    Get Scout Bts Name
    #[Teardown]    Set Scout Confid Id
    Set Tags      ${shared_config_id}
    5GCounters_TC_Check_PI_vs_l1l2   counter=M55301C01001   gnb_id=${index_gnb}    ue_id=${index_ue}

[1][1.0] Counters_5G_1003_M55301C01002_PDSCH_RANK2_64TBL_MCS_02
    [Setup]    Get Scout Bts Name
    #[Teardown]    Set Scout Confid Id
    Set Tags      ${shared_config_id}
    5GCounters_TC_Check_PI_vs_l1l2   counter=M55301C01002   gnb_id=${index_gnb}    ue_id=${index_ue}
