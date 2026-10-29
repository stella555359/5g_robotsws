*** Settings ***
Documentation
...           AUTHOR (I&V):   Anne Dutheillet        anne.dutheillet@nokia.com
...           creation : 03/02/2022
...
...         TL tested :
...         gNB Classical 1 x ASIB, 1 x ABIO, 1 RU cmW (AEQN) eCPRI
...         UE Qualcomm
...         5G Real
...         CN Real


Variables         ../../../../resources/ST/python/custom.py
Resource          ../Resources/robot/5GC001301_AA_3_resource_SA.robot


Force Tags        5G_RAN     CLASSICAL    STATE_ON_AIR

Suite Setup       1301_Suite_Setup
Suite Teardown    1301_Suite_Teardown

*** Variables ***
${gNB_id}=              0
${UE_ID}=               0
${capabilities_ms}=     REAL_ANDROID_UE
${duration_s}=                     120
${dl_throughput}=                 100M
${ul_time_s}=                     120
${ul_throughput}=                 20M
${target_D}=                     1400000000
${target_U}=                     285000000


*** Test Cases **
5GC001301_AA_3_Call setup with frame structure 1208 prach config index 190 - NSA
    [Tags]          AA_3
    5GC001301_AA_3





