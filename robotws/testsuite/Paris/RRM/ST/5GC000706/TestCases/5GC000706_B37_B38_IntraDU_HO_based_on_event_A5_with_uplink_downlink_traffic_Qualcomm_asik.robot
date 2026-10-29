*** Settings ***
Documentation
...           Description : Test Cases B37 B38 for 5GC000706
...                         <to complete>
...
...           AUTHOR (I&V):  Annie Wong         annie.wong@nokia.com
...                       :  Florence Thepot     florence.thepot@nokia.com
...                       :  Pape Diallo         pape.diallo@nokia.com
...              Last update : 01.109.20
...
...        TL :
...         gNB Classical 1 x ASIK, 1 x ABIL, 2 RUs cmW (AEQA)
...         UE Qualcomm
...         5G Real
...         CN Real


Variables       ../../../../resources/ST/python/custom.py
Resource        ../Resources/robot/5GC000706_B37_B38_IntraDU_HO_based_on_event_A5_with_uplink_downlink_traffic.robot

Force Tags           5G_RAN     STATE_ON_AIR

Suite Setup          706_B37_B38_Suite_Setup

Suite Teardown       706_B37_B38_Suite_Teardown


*** Variables ***
${ue_capability}=        REAL_ANDROID_UE
${dl_time_s}=            3000s
${dl_throughput}=        700M
${ul_time_s}=            3000s
${ul_throughput}=        200M


*** Test Case ***
[1]5GC000706_B_037_IntraDU_HO_based_on_event_A5_with_downlink_traffic
    [Tags]     QCT   DL
    5GC000706_B_37


[1]5GC000706_B_038_IntraDU_HO_based_on_event_A5_with_uplink_traffic
    [Tags]     QCT   UL
    5GC000706_B_38
