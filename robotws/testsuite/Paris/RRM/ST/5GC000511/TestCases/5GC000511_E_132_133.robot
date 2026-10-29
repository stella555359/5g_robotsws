*** Settings ***
Documentation
...           AUTHOR (I&V):   Anne Dutheillet        anne.dutheillet@nokia.com
...           creation : 21/01/2022
...
...         TL tested :
...         gNB Classical 1 x ASIB, 1 x ABIO, 1 RU cmW (AEQN) eCPRI
...         UE Qualcomm
...         5G Real
...         CN Real


Variables         ../../../../resources/ST/python/custom.py
Resource          ../Resources/robot/5GC000511_E_132_133_resource_SA.robot


Force Tags        5G_RAN     CLASSICAL    STATE_ON_AIR

Suite Setup       511_E_132_133_Suite_Setup
Suite Teardown    511_E_132_133_Suite_Teardown

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


*** Test Cases ***
5GC000511_E_132_Call_Setup_after_Cell_Reconfiguration_for_online_PRACH_parameter_modification_for_sub6_preambleTransMax
    [Tags]          E_132
    5GC000511_E_132

5GC000511_E_133_Call_Setup_after_Cell_Reconfiguration_for_online_PRACH_parameter_modification_for_sub6_powerRampingStep
    [Tags]          E_133
    5GC000511_E_132



