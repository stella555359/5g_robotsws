*** Settings ***
Documentation
...           Description : Test Cases B33 B34 for 5GC000706
...
...           AUTHOR (I&V):  Annie Wong         annie.wong@nokia.com
...                       : Florence Thepot     florence.thepot@nokia.com
...                       : Pape Diallo         pape.diallo@nokia.com
...              Last update : 30.09.20
...
...        TL :
...         gNB Classical 1 x ASIK, 1 x ABIL, 2 RUs cmW (AEQA)
...         UE Qualcomm
...         5G Real
...         CN Real


Variables       ../../../../resources/ST/python/custom.py
Resource        ../Resources/robot/5GC000706_B33_B34_IntraDU_HO_based_on_event_A3_with_uplink_downlink_traffic.robot


Force Tags           5G_RAN     STATE_ON_AIR

Suite Setup          706_B33_B34_Suite_Setup

Suite Teardown       706_B33_B34_Suite_Teardown


*** Variables ***
${ue_capability}=        REAL_ANDROID_UE
${dl_time_s}=            3000s
${dl_throughput}=        700M
${ul_time_s}=            3000s
${ul_throughput}=        200M


*** Test Case ***
[1]5GC000706_B_033_IntraDU_HO_based_on_event_A3_with_downlink_traffic
    [Tags]     QCT   DL
    5GC000706_B_33


[1]5GC000706_B_034_IntraDU_HO_based_on_event_A3_with_uplink_traffic
    [Tags]     QCT   UL
    5GC000706_B_34
