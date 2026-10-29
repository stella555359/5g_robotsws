*** Settings ***
Documentation
...           Description : Test Cases A_14 for 5GC001348
...           AUTHOR (I&V):  Annie Wong         annie.wong@nokia.com
...                       :  Florence Thepot     florence.thepot@nokia.com
...                       :  Pape Diallo         pape.diallo@nokia.com
...         Last update : 11.06.21    Annie Wong
...
...         TL req :
...         gNB Classical 1 x ASIK, 1 x ABIL, 1 RU cmW (AEQA)
...         UE Qualcomm
...         5G Real
...         CN Real


Variables         ../../../../resources/ST/python/custom.py
Resource          ../Resources/robot/5GC001348_A_14_SA_Uplink_Channel_Multiplexing_ON_1_Ue_PUSCH_FDM_resource_7827.robot

#Force Tags           5G_RAN     STATE_ON_AIR
Force Tags      CA_RAN_PZ_NPS_1    QCD_MN_RAN    QCP_RAN_ST   SBTS00   SBTS22R4    SBTS22R3
#Force Tags      CA_RAN_PZ_NPS    QCD_MN_5G    QCP_5G    SBTS00   SBTS22R4    SBTS22R3

Suite Setup          7827_1348_A_14_Suite_Setup        gnb_id=${index_gnb}
Suite Teardown       7827_1348_A_14_Suite_Teardown     gnb_id=${index_gnb}


*** Variables ***
${ue_capability}=        REAL_ANDROID_UE
${ul_time_s}=            3000s
${ul_throughput}=        200M
${index_gnb}=            0
${index_ue}=             0

*** Test Case ***
[1][1.0] 5GC001348_A_014_SA_Uplink_Channel_Multiplexing_ON_1_Ue_PUSCH_FDM_Received_and_decoded_slot_format_5GC001208_PRACH_Config_TDM
    [Tags]     QCT   UL
    [Setup]    Get Scout Bts Name
    [Teardown]    Set Scout Confid Id
    5GC001348_7827_TC_A14   gnb_id=${index_gnb}    ue_id=${index_ue}
