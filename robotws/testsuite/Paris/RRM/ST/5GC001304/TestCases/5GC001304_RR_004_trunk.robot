*** Settings ***
Documentation
...           AUTHOR (I&V):   Anne Dutheillet        anne.dutheillet@nokia.com
...           creation : 21/01/2022
...           update :   10/02/2022   Nadine Crasnier   file creation for trunk
...
...         TL tested :
...         gNB Classical 1 x ASIB, 1 x ABIO, 1 RU cmW (AEQN) eCPRI
...         UE Qualcomm
...         5G Real
...         CN Real


Variables         ../../../../resources/ST/python/custom.py
Resource          ../Resources/robot/5GC001304_RR_004_resource.robot


Force Tags        5G_RAN     CLASSICAL    STATE_ON_AIR

Suite Setup       1304_Suite_Setup
Suite Teardown    1304_Suite_Teardown

*** Variables ***
${gNB_id}=              0
${UE_ID}=               0
${capabilities_ms}=     REAL_ANDROID_UE
${duration_s}=                     120
${dl_throughput}=                 100M
${ul_time_s}=                     120
${ul_throughput}=                 20M
${target_D_SA}=                  1400000000
${target_U_SA}=                  285000000
${target_D_NSA}=                 1400000
${target_U_NSA}=                 285000


*** Test Cases ***
[1][1.0] 5GC001304_RR_004_Call setup with prach config index 148
    [Tags]          RR_004
    5GC001304_RR_004





