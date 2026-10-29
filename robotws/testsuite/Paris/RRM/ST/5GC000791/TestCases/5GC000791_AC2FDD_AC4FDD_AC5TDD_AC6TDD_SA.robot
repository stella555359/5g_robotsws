*** Settings ***
Documentation
...           AUTHOR (I&V):   Anne Dutheillet        anne.dutheillet@nokia.com
...           AUTHOR (I&V):   Nadine Crasnier        nadine.crasnier@nokia.com
...           creation : 03/06/2021
...           update : 25/06/2021
...
...         TL tested :
...         gNB Classical 1 x ASIB, 1 x ABIO, 1 RU cmW (AEQN) eCPRI
...         UE Qualcomm
...         5G Real
...         CN Real


Variables         ../../../../resources/ST/python/custom.py
Resource          ../Resources/robot/5GC000791_AC2FDD_AC4FDD_AC5TDD_AC6TDD_resource_SA.robot


Force Tags      5G_RAN     CLASSICAL    STATE_ON_AIR

Suite Setup       791_AC2FDD_AC4FDD_AC5TDD_AC6TDD_Suite_Setup     gnb_index=${gNB_id}
Suite Teardown    791_AC2FDD_AC4FDD_AC5TDD_AC6TDD_Suite_Teardown

*** Variables ***
${gNB_id}=              0
${capabilities_ms}=     REAL_ANDROID_UE
${UE_ID}=               0
${dl_throughput}=         600M
${ul_throughput}=         150M


*** Test Cases ***
[1]5GC000791_AC_2_FDD_PM_counters_distribution_of_scheduled_grants_UL_GRANT_AL8_CBWP1_M55335C03004
    [Tags]          QCT     UL
    5GC000791_TC_AC2_FDD

[1]5GC000791_AC_4_FDD_PM_counters_distribution_of_scheduled_grants_DL_GRANT_AL8_CBWP1_M55335C03009
    [Tags]          QCT     DL
    5GC000791_TC_AC4_FDD

[1]5GC000791_AC_05_Number_of_slots_with_Uplink_grant_capability_in_Cell_BWP-1_M55335C05003
    [Tags]          QCT     UL
    5GC000791_TC_AC5_TDD

[1]5GC000791_AC_06_Number_of_slots_with_Downlink_grant_capability_in_Cell_BWP-1_M55335C05004
    [Tags]          QCT     DL
    5GC000791_TC_AC6_TDD


