*** Settings ***
Documentation
...           Description : Test Cases B31 B40 J242 J243 J246 J247 for 5GC000706
...
...
...           AUTHOR (I&V):  Annie Wong         annie.wong@nokia.com
...                       : Florence Thepot     florence.thepot@nokia.com
...                       : Pape Diallo         pape.diallo@nokia.com
...              Last update : 03.02.21
...
...        TL :
...         gNB Classical 1 x ASIK, 1 x ABIL, 2 RUs cmW (AEQA)
...         UE Qualcomm
...         5G Real
...         CN Real


Variables         ../../../../resources/ST/python/custom.py
Resource          ../Resources/robot/5GC000706_B31_B40_J242_J243_J246_J247_MeasA3.robot

Force Tags           5G_RAN     STATE_ON_AIR

Suite Setup          706_B31_B40_J242_J243_J246_J247_Suite_Setup

Suite Teardown       706_B31_B40_J242_J243_J246_J247_Suite_Teardown


*** Variables ***
${ue_capability}=        REAL_ANDROID_UE
${ul_time_s}=            3000s
${ul_throughput}=        200M

*** Test Case ***
[1]5GC000706_B_031_IntraDU_HO_based_on_event_A3_contention_based_RACH_procedure
    [Tags]     QCT
    5GC000706_B_31


[1]5GC000706_B_040_Check_counter_TOT_INTER_FREQ_HO_DECISION_A3_PI_M55147C00024
    [Tags]     QCT
    5GC000706_B_40


[1]5GC000706_J_242_Check_counter_ATT_IF_INTRA_DU_HO_SA_PLMN_PI_M55145C00321
    [Tags]     QCT
    5GC000706_J_242


[1]5GC000706_J_243_Check_counter_SUCC_IF_INTRA_DU_HO_SA_PLMN_PI_M55145C00322
    [Tags]     QCT
    5GC000706_J_243


[1]5GC000706_J_246_Check_counter_ATT_IF_GNB_INTRA_DU_HO_SLICE_PI_M55149C00550
    [Tags]     QCT
    5GC000706_J_246


[1]5GC000706_J_247_Check_counter_SUCC_IF_GNB_INTRA_DU_HO_SLICE_PI_M55149C00551
    [Tags]     QCT
    5GC000706_J_247
