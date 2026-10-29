*** Settings ***
Documentation    author:Liu Yanfang
...               contact: yanfang.liu@nokia-sbell.com or jeffrey.shi@nokia-sbell.com
...               squad group: SG_05
...               feature : 5GC002479
Suite Setup       Suite setup for 2479
Suite Teardown    Teardown Suite
Force Tags
...    PY36
Resource          Resources/5GC002479_ASIL_Resouce.robot
Resource    testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/robot/siso_common_case/variable/Variables_5G.robot
Resource    ${BASIC_PATH_5G}/5G_Setup_And_Teardown.robot
Resource    testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/robot/robot_common_operations/interface.robot
Resource    testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/robot/siso_common_case/step_keywords/5G/recommissioning_and_make_throughput.robot

#CASE_INPUT_5GC002479   =   {
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

[1][2.0] 5GC002479-HI_01_OAM_KPI_Site_Reset_#1a_#61a_Max_Configuration
    [Documentation]     KPI1A AND KPI61A
    [Tags]     CRT_TRUNK   CRT_22R1   CRT_22R2   CRT_22R3   CRT_22R4
    [Setup]    SetUp Case
    [Teardown]  Teardown case
    TC.5GC002479-HI_01_OAM_KPI_Site_Reset_#1a_#61a_Max_Configuration
    log to console    prepare to l3 call
    L3 call Precondition
    ${ue_index_list}    create list    ${0}
    ${cell_list}    create list    ${1}
    Connect to gnb coam via ssl    connection=${connection}   gnb_index=0
    ${cell_and_peak_info}    generate peak information     cell_list=${cell_list}    duration=300    l3_avg_rate=0.5    l3_min_rate=0.1
    L3 call with Check Throughput    ue_index_list=${ue_index_list}    cell_list=${cell_list}    duration=300
    ...    loop_times=1    cell_and_peak_info=${cell_and_peak_info}
    Run keyword and ignore error    COAM Teardown gnb connections

[1][2.0] 5GC002479-HI_02_OAM_KPI_Power_Reset_#3_#63_Max_Configuration
    [Documentation]     KPI3 AND KPI63
    [Tags]     CRT_TRUNK   CRT_22R1   CRT_22R2   CRT_22R3   CRT_22R4
    [Setup]    SetUp Case
    [Teardown]  Teardown case
    TC.5GC002479-HI_02_OAM_KPI_Power_Reset_#3_#63_Max_Configuration

[1][2.0] 5GC002479-HI_03_OAM_KPI_RU_Reset_#51_#651_Max_Configuration
    [Documentation]     KPI51 AND KPI651
    [Tags]     CRT_TRUNK   CRT_22R1   CRT_22R2   CRT_22R3   CRT_22R4
    [Setup]    SetUp Case
    [Teardown]  Teardown case
    TC.5GC002479-HI_03_OAM_KPI_RU_Reset_#51_#651_Max_Configuration
    L3 call Precondition
    ${ue_index_list}    create list    ${0}
    ${cell_list}    create list    ${1}
    Connect to gnb coam via ssl    connection=${connection}   gnb_index=0
    ${cell_and_peak_info}    generate peak information     cell_list=${cell_list}    duration=300    l3_avg_rate=0.5    l3_min_rate=0.1
    L3 call with Check Throughput    ue_index_list=${ue_index_list}    cell_list=${cell_list}    duration=300
    ...    loop_times=1    cell_and_peak_info=${cell_and_peak_info}
    Run keyword and ignore error    COAM Teardown gnb connections

*** Keywords ***
Suite setup for 2479
    robot_common_operations.Common Suite Setup
    kw.suite setup for 2479

Teardown Suite
    robot_common_operations.Common Suite Teardown
    kw.teardown suite
    Run Keyword And Ignore Error    process.Terminate All Processes    kill=True

L3 call Precondition
    #SISO Coam Suite Setup
    #SISO Coam Test Setup
    set suite variable    ${connection}    GNB_OAM
    Connect to gnb coam via ssl    connection=${connection}   gnb_index=0
    ${Active_SW_version}    Get Active SW Version    connection=${connection}
    set suite variable      ${Active_SW_version}
    ${Golden_SCF_Path}    Get Golden SCF Path    gnb_index=0
    set suite variable    ${Case_SCF_Path}    ${Golden_SCF_Path}
    Generate suite log path
    set suite variable      ${SAVE LOG DIRECTORY}    ${SUITE_LOG_PATH}
    Run keyword and ignore error    COAM Teardown gnb connections
