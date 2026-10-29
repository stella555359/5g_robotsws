*** Settings ***
Documentation    author:Liu Tiffany
...               contact: tiffany.liu@nokia-sbell.com
...               squad group: SG_01
...               feature : 5GC002479
Suite Setup       Suite setup for 2479
Suite Teardown    Teardown Suite

Resource          Resources/5GC002479_Resouce.robot
#CASE_INPUT_5GC002479	=	{
#    '5GC002479':{'LoopTimeout':'90',},
#    '5GC002479_IA_15':{'UpdateByYAFT':'true',},
#}
*** Test Cases ***
#TEST
#    log to console    ${BTSMOD}
#    log to console    ${4G_WEBUI_IP}
#    log to console    ${5G_WEBUI_IP}
#    log to console   ${BTSMOD}
##    Check BTS Onair
##    ${version_Target}    COAM_Admin.GetActiveSoftwareVersion    bts_host=${4G_WEBUI_IP}
#    #${version_Target}    ${version_Original}    Get gNB SW version
#    ${version_Target}    COAM_Admin.GetActiveSoftwareVersion    bts_host=${5G_WEBUI_IP}
#    ${Intermediate_gnb_package}   Select PreReleased gnb package    version_target=${version_Target}
#[1]5GC002479_HA_01_OAM_KPI_1a_Site_Reset_Outage_Duration_Single_Core
[1]OAM_KPI_1a_Site_Reset_Outage_Duration_Single_Core_ASIL
    [Documentation]     KPI1A
    [Tags]     CRT_22R2   CRT_22R3
    [Setup]    SetUp Case
    [Teardown]  Teardown case
    TC.5GC002479_HA_01_OAM_KPI_1a_Site_Reset_Outage_Duration_Single_Core
    log to console     start l3 call
    ${cell_id_list}    create list    ${1}
    Get UE From Init File and Make call    cell_list=${cell_id_list}    duration=300    dl_tp=500M   ul_tp=40M
    ...    dl_exp=500    ul_exp=40

#[1]5GC002479_HA_03_OAM_KPI_61a_Software_Reset_Startup_Success_Rate
[1]OAM_KPI_61a_Software_Reset_Startup_Success_Rate_ASIL
    [Documentation]     KPI61A
    [Tags]      CRT_22R2   CRT_22R3
    [Setup]    SetUp Case
    [Teardown]  Teardown case
#    TC.5GC002479_HA_03_OAM_KPI_61a_Software_Reset_Startup_Success_Rate
    log    ${PREV TEST STATUS}
    Pass Execution If    '${PREV TEST STATUS}' == 'PASS'    Checkpoints already covered in PREV TEST

#[1]5GC002479_HA_03_OAM_KPI_61a_Software_Reset_Startup_Success_Rate
#    [Documentation]     KPI61A
#    [Tags]      CRT_22R2   CRT_22R3
#    [Setup]     TestCase.Start
#    [Teardown]  TestCase.Stop
#    TC.5GC002479_HA_03_OAM_KPI_61a_Software_Reset_Startup_Success_Rate

#[1]5GC002479_HA_04_OAM_KPI_3_Power_Reset_Outage_Duration_Single_Core
[1]OAM_KPI_3_Power_Reset_Outage_Duration_Single_Core_ASIL
    [Documentation]     KPI3
    [Tags]     CIT_TRUNK     CIT_22R4    CDRT_22R2    CDRT_22R3    CIT_22R1   CDRT_22R1  CIT_22R2    CIT_22R3
    [Setup]    SetUp Case
    [Teardown]  Teardown case
    TC.5GC002479_HA_04_OAM_KPI_3_Power_Reset_Outage_Duration_Single_Core
    ${cell_id_list}    create list    ${1}
    Get UE From Init File and Make call    cell_list=${cell_id_list}    duration=300    dl_tp=500M   ul_tp=40M
    ...    dl_exp=500    ul_exp=40

#[1]5GC002479_HA_06_OAM_KPI_63_Power_Reset_Success_Rate
[1]OAM_KPI_63_Power_Reset_Success_Rate_ASIL
    [Documentation]     KPI63
    [Tags]      CRT_22R2   CRT_22R3
    [Setup]    SetUp Case
    [Teardown]  Teardown case
#    TC.5GC002479_HA_06_OAM_KPI_63_Power_Reset_Success_Rate
    log    ${PREV TEST STATUS}
    Pass Execution If    '${PREV TEST STATUS}' == 'PASS'    Checkpoints already covered in PREV TEST

#[1]5GC002479_HA_06_OAM_KPI_63_Power_Reset_Success_Rate
#    [Documentation]     KPI63
#    [Tags]      CRT_22R2   CRT_22R3
#    [Setup]     TestCase.Start
#    [Teardown]  TestCase.Stop
#    TC.5GC002479_HA_06_OAM_KPI_63_Power_Reset_Success_Rate

#[1]5GC002479_HA_08_OAM_KPI_51_RU_Reset_Time
[1]OAM_KPI_51_RU_Reset_Time_ASIL
    [Documentation]     This case is to verify OAM KPI51, RU reset time is less than 3min
    [Tags]     CRT_22R2   CRT_22R3
    [Setup]    SetUp Case
    [Teardown]  Teardown case
    TC.5GC002479_HA_08_OAM_KPI_51_RU_Reset_Time
    ${cell_id_list}    create list    ${1}
    Get UE From Init File and Make call    cell_list=${cell_id_list}    duration=300    dl_tp=500M   ul_tp=40M
    ...    dl_exp=500    ul_exp=40

#[1]5GC002479_HA_09_OAM_KPI_651_RU_Software_Reset_Startup_Success_Rate
[1]OAM_KPI_651_RU_Software_Reset_Startup_Success_Rate_ASIL
     [Documentation]     KPI651
    [Tags]      CRT_22R2   CRT_22R3
    [Setup]    SetUp Case
    [Teardown]  Teardown case
#    TC.5GC002479_HA_09_OAM_KPI_651_RU_Software_Reset_Startup_Success_Rate
    log    ${PREV TEST STATUS}
    Pass Execution If    '${PREV TEST STATUS}' == 'PASS'    Checkpoints already covered in PREV TEST

#[1]5GC002479_HA_09_OAM_KPI_651_RU_Software_Reset_Startup_Success_Rate
#     [Documentation]     KPI651
#    [Tags]      CRT_22R2   CRT_22R3
#    [Setup]     TestCase.Start
#    [Teardown]  TestCase.Stop
#    TC.5GC002479_HA_09_OAM_KPI_651_RU_Software_Reset_Startup_Success_Rate

[1]5GC002479_IA_15_OAM_KPI_4_SWM_SW_Upgrade_Time_Intra_Release_Single_Core
    [Documentation]     KPI4
    [Tags]     CIT_21A
    [Setup]    SetUp Case
    [Teardown]  Teardown case for KPI4
    TC.5GC002479_IA_15_OAM_KPI_4_SWM_SW_Upgrade_Time_Intra_Release_Single_Core

[1]5GC002479_IA_18_OAM_KPI_64_SWM_SW_Upgrade_Success_Rate_Intra_Release
    [Documentation]     KPI64
    [Tags]      CIT_21A
    [Setup]     TestCase.Start
    [Teardown]  TestCase.Stop
    TC.5GC002479_IA_18_OAM_KPI_64_SWM_SW_Upgrade_Success_Rate_Intra_Release
*** Keywords ***
Suite setup for 2479
    kw.suite setup for 2479

Teardown Suite
    kw.teardown suite
