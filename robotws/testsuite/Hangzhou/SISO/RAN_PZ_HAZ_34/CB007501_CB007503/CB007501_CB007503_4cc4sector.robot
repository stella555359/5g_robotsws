*** Settings ***
Documentation     author: Zhang Lusha
...               contact: lusha.zhang@nokia-sbell.com
...               squad group: MMW_02
Suite Setup       SISO Coam Suite Setup With Specify SCF    enb_flag=${False}    scf_suffix=_4CC_4Sector
Suite Teardown    Run Keyword And Ignore Error     SISO Coam Suite Teardown
Force Tags        5G_RAN_TDD    STATE_SW_UPLOADED
Resource    testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/robot/siso_common_case/variable/Variables_5G.robot
Resource    ${BASIC_PATH_5G}/5G_Setup_And_Teardown.robot
Resource    ${BASIC_PATH_5G}/General_SiSo_Commissioning_BTS_Template_Commissioning.robot
Resource    ${BASIC_PATH_5G}/General_SiSo_RU_lock_unlock.robot
Resource    ${BASIC_PATH_5G}/General_SiSo_Auto_BTS_site_reset.robot
Resource    testsuite/Hangzhou/SISO/RAN_PZ_HAZ_34/CB007501_CB007503/Resource/CB007501_CB007503_resource.robot

*** Variables ***
${TS_CASE_LOG_PATH}    /home/ute
${ultp}    25
${dltp}    150

*** Test Cases ***
##common keyword not PASS, asking shizhihao
# [1][1.0] Manual_SiSo_CM_Recommissioning
#     [Tags]    CRT_TRUNK
#     [Setup]    SISO Coam Test Setup
#     Manual_SiSo_CM_Recommissioning
#     [Teardown]    SISO Coam Test Teardown

#for now use old case, change to new case if common keyword PASSed
[2][2.0] Manual_SiSo_CM_Recommissioning
    [Tags]    CRT_TRUNK    CRT_23R2
    [Setup]    SISO Coam Test Setup
    General_SiSo_Commissioning_BTS_Template_Commissioning
    [Teardown]    SISO Coam Test Teardown

[2][1.0] General_SiSo_E2E_system_setup_with_data_transfer_for_configuration_feature_testing
    [Tags]    CRT_TRUNK    CRT_23R2
    [Setup]    SISO Coam Test Setup
    ${ue_index_list}    create list    ${0}
    ${cell_list}    create list    ${1}
    ${list_of_cell_ids}    Create List    2441217    2441218    2441219    2441220
    Data Transfer DL UL    ue_index=${ue_index_list}    ul_throughput=220M    dl_throughput=2G
    ...    list_of_cell_ids=${list_of_cell_ids}
    [Teardown]    SISO Coam Test Teardown

## for 23R2_MP, adapt the NO. change in case name
[1][1.0] General_SiSo_RU_lock_unlock
    [Tags]    CRT_TRUNK    CRT_23R2
    [Setup]    SISO Coam Test Setup
    General_SiSo_RU_lock_unlock    with_call=False    check_alarm=False
    [Teardown]    SISO Coam Test Teardown

[2][1.0] General_SiSo_RU_lock_unlock
    [Tags]    CRT_TRUNK    CRT_23R2
    [Setup]    SISO Coam Test Setup
    General_SiSo_RU_lock_unlock    with_call=False    check_alarm=False
    [Teardown]    SISO Coam Test Teardown

# for now use my code, change to common keyword if common keyword done
[1][1.0] Manual_SiSo_SM_BTS_Site_Reset
    [Tags]    CRT_TRUNK    CRT_23R2
    [Setup]    SISO Coam Test Setup
    General_SiSo_Auto_BTS_site_reset
    General_SiSo_Auto_BTS_site_reset
    General_SiSo_Auto_BTS_site_reset
    [Teardown]    SISO Coam Test Teardown

#General_SiSo_Cell_block_and_unblock change to General_SiSo_Cell_lock_and_unlock
[2][2.0] General_SiSo_Cell_block_and_unblock
    [Tags]    CRT_TRUNK    CRT_23R2
    [Setup]    SISO Coam Test Setup
    CB007501_CB007503_resource.General_SiSo_Cell_lock_and_unlock    with_call=False
    [Teardown]    SISO Coam Test Teardown


*** Keywords ***
General_SiSo_RU_lock_unlock
    [Documentation]
    ...    *****************
    ...    Owner_lusha.zhang@nokia-sbell.com
    ...    [TEST PURPOSE] The purpose of this test case is to verify that radio module
    ...    and OAM behaves correctly during procedure of locking and unlocking.
    ...    ******************
    [Arguments]  ${with_call}=${True}    ${check_alarm}=${True}
    ${start_time}    robot.libraries.DateTime.get current date
    Selenium Login And Disable Screen Lock
    Get X2 link shutdown waiting time
    ${ru_index_list}    Get All RU Index
    ${cell_list}    Get All Cell Id
    ${cell_num}    get length  ${cell_list}
    ${ue_num}    checkuenumber    ${tl.ues}
    log to console    ${ue_num}
    sort list    ${cell_list}
    run keyword and continue on failure    Lock all RUs and check all status    ru_index_list=${ru_index_list}
    ...    cell_list=${cell_list}    gnb_type='${gNb_CuType}'    ue_num=${ue_num}    with_call=${with_call}    check_alarm=${check_alarm}
    Close Start Up View    timeout=60
    UnLock all RUs and check all status    ru_index_list=${ru_index_list}    cell_list=${cell_list}
    ...   gnb_type='${gNb_CuType}'    start_time=${start_time}    ue_num=${ue_num}    with_call=${with_call}
    run keyword if    ${cell_num}>1 and '${gNb_CuType}'=='NSA' and ${with_call}   start traffic all cells nsa    cell_list=${cell_list}
    run keyword if    ${cell_num}>1 and '${gNb_CuType}'=='SA' and ${with_call}    start traffic all cells sa     cell_list=${cell_list}
    ...    ue_num=${ue_num}
    [Teardown]    Run Keywords    excute ru unlock    ru_index_list=${ru_index_list}    AND
    ...    Selenium Logout And Close Browser

