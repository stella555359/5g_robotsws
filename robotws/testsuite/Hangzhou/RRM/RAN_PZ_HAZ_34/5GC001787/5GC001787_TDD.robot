*** Settings ***
Documentation    author:Lou Shuhui
...               contact: shuhui.lou@nokia-sbell.com
...               squad group: SG_01
...               feature : 5GC001787
Suite Setup       Suite setup
Suite Teardown    Teardown Suite
Force Tags        RAN_5G  RAN_5G_TDD  STATE_SW_UPLOADED  SBTS00  SBTS22R3
...    CLOUD_5G_CLASSICAL_QC_SA_ASILL_ABINB1_2xAEQE    PY36
Resource          ../../../OAM/RAN_PZ_HAZ_34/5GC002479/Resources/5GC002479_Resouce.robot
Resource          ../../../OAM/RAN_PZ_HAZ_34/5GC002479/Resources/5GC002479_CP_Resource.robot
Resource          ../5GC001787/Resources/5GC001787_Resouce.robot


*** Test Cases ***
#[1]5GC001787_B_13_site reset KPI checking
#    [Documentation]     KPI1
#    [Tags]
#    [Setup]    SetUp Case
#    [Teardown]  Teardown case
#    TC.GC002479_HA_01_OAM_KPI_1a_Site_Reset_Outage_Duration_Single_Core
#
#[1]5GC001787_B_12_ABIN reset KPI checking
#    [Documentation]     KPI5
#    [Tags]
#    [Setup]    SetUp Case
#    [Teardown]  Teardown case
#    TC.5GC002536_HA_03_OAM_KPI_5_Capacity_Module_Reset_Outage_Duration


[1]5GC001787_D_13_TDD L3 call on UTE cloud env
    [Documentation]
    [Tags]     CRT_22R3    CRT_TRUNK    CRT_UTE
    [Setup]    SetUp Case for 1787
    [Teardown]  Teardown case for 1787
    TC.L3 call on UTE cloud env


*** Keywords ***
Suite setup
    kw.suite setup


Teardown Suite
    kw.teardown suite

SetUp Case for 1787
    Run Keyword And Ignore error   rd.delete_bts
    TestCase.Start