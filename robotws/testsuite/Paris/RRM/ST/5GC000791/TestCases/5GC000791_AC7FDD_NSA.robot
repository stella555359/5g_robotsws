*** Settings ***
Documentation
...           AUTHOR (I&V):   Anne Dutheillet        anne.dutheillet@nokia.com
...           AUTHOR (I&V):   Nadine Crasnier        nadine.crasnier@nokia.com
...           creation : 03/06/2021
...
...         TL tested :
...         gNB Classical 1 x ASIB, 1 x ABIO, 1 RU cmW (AEQN) eCPRI
...         UE Qualcomm
...         5G Real
...         CN Real


Variables         ../../../../resources/ST/python/custom.py
Resource          ../Resources/robot/5GC000791_AC7FDD_resource_NSA.robot


Force Tags        5G_RAN     CLASSICAL    STATE_ON_AIR

Suite Setup       791_AC_7_FDD_Suite_Setup
Suite Teardown    791_AC_7_FDD_Suite_Teardown

*** Variables ***
${gNB_id}=              0
${capabilities_ms}=     REAL_ANDROID_UE


*** Test Cases ***
[1]5GC000791_AC_7_FDD_PM_counters_DL_SLT_1_SYMB_ALLOC_CBWP1_M55335C05006
    [Tags]          QCT     UL
    5GC000791_TC_AC7_FDD_NSA


