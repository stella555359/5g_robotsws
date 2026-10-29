*** Settings ***
Documentation     author: Zhang Lusha
...               contact: lusha.zhang@nokia-sbell.com
...               squad group: MMW_02
Suite Setup       SISO Coam Suite Setup With Specify SCF    enb_flag=${False}    scf_suffix=_8CC_2Sector
Suite Teardown    Run Keyword And Ignore Error     SISO Coam Suite Teardown
Force Tags        5G_RAN_TDD    STATE_SW_UPLOADED
Resource    testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/robot/siso_common_case/variable/Variables_5G.robot
Resource    ${BASIC_PATH_5G}/5G_Setup_And_Teardown.robot
Resource    ${BASIC_PATH_5G}/General_SiSo_Commissioning_BTS_Template_Commissioning.robot
Resource    ${BASIC_PATH_5G}/General_SiSo_RF_module_reset_from_GUI.robot
Resource    testsuite/Hangzhou/SISO/RAN_PZ_HAZ_34/CB007501_CB007503/Resource/CB007501_CB007503_resource.robot


*** Variables ***
${TS_CASE_LOG_PATH}    /home/ute
${ultp}    50
${dltp}    300

*** Test Cases ***
#for now use old case, change to new case if common keyword PASSed
[1][2.0] Manual_SiSo_CM_Recommissioning
    [Tags]    CRT_TRUNK    CRT_23R2
    [Setup]    SISO Coam Test Setup
    General_SiSo_Commissioning_BTS_Template_Commissioning
    # Manual_SiSo_CM_Recommissioning
    [Teardown]    SISO Coam Test Teardown

#General_SiSo_Cell_block_and_unblock change to General_SiSo_Cell_lock_and_unlock
[1][2.0] General_SiSo_Cell_block_and_unblock
   [Tags]    CRT_TRUNK    CRT_23R2
    [Setup]    SISO Coam Test Setup
    CB007501_CB007503_resource.General_SiSo_Cell_lock_and_unlock    with_call=False
    [Teardown]    SISO Coam Test Teardown

[1][1.0] General_SiSo_E2E_system_setup_with_data_transfer_for_configuration_feature_testing
    [Tags]    CRT_TRUNK    CRT_23R2
    [Setup]    SISO Coam Test Setup
    ${ue_index_list}    create list    ${0}
    ${list_of_cell_ids}    Create List    2441217    2441218    2441219    2441220    2441221    2441222    2441223    2441224
    Data Transfer DL UL    ue_index=${ue_index_list}    ul_throughput=120M    dl_throughput=1G
    ...    list_of_cell_ids=${list_of_cell_ids}
    [Teardown]    SISO Coam Test Teardown

[1][2.0] General_SiSo_Commissioning_BTS_Template_Commissioning
    [documentation]    The purpose of this test case is to check if not commissioned gNB can
    ...    be correctly configured using BTS Template, verify Managed Object Class in WebUI
    ...    and update parameters via WebUI. bandwith is 100mhz
    [Tags]    CRT_TRUNK    CRT_23R2
    [Setup]    SISO Coam Test Setup
    General_SiSo_Commissioning_BTS_Template_Commissioning
    [Teardown]    SISO Coam Test Teardown

[1][3.0] General_SiSo_Online_Cell_Addition_Deletion
    [Documentation]     1.add and delete some cells
     ...                2.add and delete all cells in the given cellgrp
    [Tags]    CRT_TRUNK    CRT_23R2
    [Setup]    SISO Coam Test Setup
    ${addition_deletion_cell_list}    Create List    ${1}    ${2}
    Online Cell addition deletion without cellgrp
    ...    addition_deletion_cell_list=${addition_deletion_cell_list}
    ...    addition_deletion_cellgrp=0
    Online Cell addition deletion within cellgrp    addition_deletion_cellgrp=0
    [Teardown]    SISO Coam Test Teardown

[1][1.0] General_SiSo_RU_module_reset_from_GUI
    [documentation]    Reset RU from GUI
    [Tags]    CRT_TRUNK    CRT_23R2
    [Setup]    SISO Coam Test Setup
    General_SiSo_RF_module_reset_from_GUI    with_call=False
    [Teardown]    SISO Coam Test Teardown

*** Keywords ***
