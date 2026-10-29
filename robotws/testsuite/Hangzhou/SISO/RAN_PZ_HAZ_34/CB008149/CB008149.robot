*** Settings ***
Suite Setup          SISO Coam Suite Setup
Suite Teardown       SISO Coam Suite Teardown
Test Setup           #SISO Coam Test Setup
Test Teardown        #SISO Coam Test Teardown
Test Timeout         90 min

Resource             testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/robot/siso_common_case/variable/Variables_5G.robot
Resource             ${BASIC_PATH_5G}/5G_Setup_And_Teardown.robot
Resource             testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/robot/siso_common_case/lib/step_keywords.robot

#Library             testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/robot/siso_common_case/lib/get_case_variables.py
#Variables           TestData/case_variables.yml

Documentation
...    Author: Liu Yue
...    Contact: yue.2.liu@nokia-sbell.com
...    squad group:SG_05
...    Feature CB008952 in SBTS23R3 program with configuration block 23R3_N_CB008952_5 and 23R3_N_CB008952_6

Force Tags     RAN_5G     RAN_5G_TDD    STATE_SW_UPLOADED    SBTS00    PY36    master_classicalbts_all

*** Variables ***

*** Test Cases ***
[1]CB008149-SR-A_01_Manual_SiSo_CM_Recommissioning
    [Tags]    3S-1CC-16D4U-8D8U-8D4U_50M_CB008149-C-8834-3    CRT_23R3    CRT_TRUNK
    [Setup]    SISO Coam Test Setup
    log to console    recommissioning completed; NEXT TO BE UPDATED
    [Teardown]    SISO Coam Test Teardown

[1]CB008149-SR-A_04_General_SiSo_Cell_block_and_unblock
    [Tags]    3S-1CC-16D8U_100M_CB008149-A-8834-1    CRT_23R3    CRT_TRUNK
    [Setup]    SISO Coam Test Setup
    log to console    recommissioning completed; NEXT TO BE UPDATED
    [Teardown]    SISO Coam Test Teardown

[1]CB008149-SR-B_02_General_SiSo_E2E_system_setup_with_data_transfer_conducted_25Gelink
    [Tags]    3S-1CC-16D4U_80M_CB008149-B-8834-2    CRT_23R3    CRT_TRUNK
    [Setup]    SISO Coam Test Setup
    log to console    recommissioning completed; NEXT TO BE UPDATED
    [Teardown]    SISO Coam Test Teardown

[1]CB008149-SR-C_03_Manual_SiSo_SM_BTS_Block_Site_16DL8UL_16DL4UL_8DL8UL
    [Tags]    3S-1CC-16D8U-16D4U-8D8U_50M_CB008149-C-8834-3    CRT_23R3    CRT_TRUNK
    [Setup]    SISO Coam Test Setup
    log to console    recommissioning completed; NEXT TO BE UPDATED
    [Teardown]    SISO Coam Test Teardown

#
#[1]CB008149-SR-A_02_Manual_SiSo_SM_BTS_Site_Reset
#    [Tags]    3S-1CC-16D8U_100M_CB008149-A-8834-1    CRT_23R3    CRT_TRUNK
#    [Setup]    SISO Coam Test Setup
#    log to console    recommissioning completed; NEXT TO BE UPDATED
#    [Teardown]    SISO Coam Test Teardown
#
#[1]CB008149-SR-A_03_General_SiSo_E2E_system_setup_with_data_transfer_conducted_25Gelink
#    [Tags]    3S-1CC-16D8U_100M_CB008149-A-8834-1    CRT_23R3    CRT_TRUNK
#    [Setup]    SISO Coam Test Setup
#    log to console    recommissioning completed; NEXT TO BE UPDATED
#    [Teardown]    SISO Coam Test Teardown
#
#[1]CB008149-SR-A_06_General_SiSo_E2E_system_setup_with_data_transfer_conducted_10Gelink
#    [Tags]    3S-1CC-16D8U_100M_CB008149-A-8834-1    CRT_23R3    CRT_TRUNK
#    [Setup]    SISO Coam Test Setup
#    log to console    recommissioning completed; NEXT TO BE UPDATED
#    [Teardown]    SISO Coam Test Teardown
#
#[1]CB008149-SR-B_01_General_SiSo_Commissioning_BTS_Template_Commissioning
#    [Tags]    3S-1CC-16D4U_80M_CB008149-B-8834-2    CRT_23R3    CRT_TRUNK
#    [Setup]    SISO Coam Test Setup
#    log to console    recommissioning completed; NEXT TO BE UPDATED
#    [Teardown]    SISO Coam Test Teardown
#
#[1]CB008149-SR-B_04_OAM_KPI_61a_SiSo_Auto_BTS_site_reset
#    [Tags]    3S-1CC-16D4U_80M_CB008149-B-8834-2    CRT_23R3    CRT_TRUNK
#    [Setup]    SISO Coam Test Setup
#    log to console    recommissioning completed; NEXT TO BE UPDATED
#    [Teardown]    SISO Coam Test Teardown
#
#[1]CB008149-SR-B_05_OAM_KPI_651_SiSo_Auto_RF_reset_success_rate_from_WebUI_with_L3Call
#    [Tags]    3S-1CC-16D4U_80M_CB008149-B-8834-2    CRT_23R3    CRT_TRUNK
#    [Setup]    SISO Coam Test Setup
#    log to console    recommissioning completed; NEXT TO BE UPDATED
#    [Teardown]    SISO Coam Test Teardown
#
#[1]CB008149-SR-B_06_General_SiSo_Online_Cell_Addition_Deletion
#    [Tags]    3S-1CC-16D4U_80M_CB008149-B-8834-2    CRT_23R3    CRT_TRUNK
#    [Setup]    SISO Coam Test Setup
#    log to console    recommissioning completed; NEXT TO BE UPDATED
#    [Teardown]    SISO Coam Test Teardown
#
#[1]CB008149-SR-C_01_General_SiSo_Commissioning_BTS_Template_Commissioning
#    [Tags]    3S-1CC-16D4U-8D8U-8D4U_50M_CB008149-C-8834-3    CRT_23R3    CRT_TRUNK
#    [Setup]    SISO Coam Test Setup
#    log to console    recommissioning completed; NEXT TO BE UPDATED
#    [Teardown]    SISO Coam Test Teardown
#
#[1]CB008149-SR-C_02_General_SiSo_E2E_system_setup_with_data_transfer_conducted_25Gelink_16DL8UL_16DL4UL_8DL8UL
#    [Tags]    3S-1CC-16D8U-16D4U-8D8U_50M_CB008149-C-8834-3    CRT_23R3    CRT_TRUNK
#    [Setup]    SISO Coam Test Setup
#    log to console    recommissioning completed; NEXT TO BE UPDATED
#    [Teardown]    SISO Coam Test Teardown
#
#[1]CB008149-SR-C_06_General_SiSo_Collect_RFSW_logs_from_RU_into_BTS_Snapshot
#    [Tags]    3S-1CC-16D8U-16D4U-8D8U_80M_CB008149-C-8834-2    CRT_23R3    CRT_TRUNK
#    [Setup]    SISO Coam Test Setup
#    log to console    recommissioning completed; NEXT TO BE UPDATED
#    [Teardown]    SISO Coam Test Teardown
#
#
##[1]CB008952-B_B5_05_General_SiSo_E2E_system_setup_with_data_transfer_for_configuration_feature_testing_with_legacy_Bbcellset
##    [Tags]    3S-4CC-8D4U_CB008952_5    CRT_23R3    CRT_TRUNK
##    [Setup]    SISO Coam Test Setup
##    ${cell_list}    Create List    ${11}
##    Get UE From Init File and Make call    cell_list=${cell_list}    with_peak=${False}
##    [Teardown]    SISO Coam Test Teardown
##
##[1]CB008952-B_B6_05_General_SiSo_E2E_system_setup_with_data_transfer_for_configuration_feature_testing_with_legacy_Bbcellset
##    [Tags]    3S-4CC-4D4U_CB008952_6    CRT_23R3    CRT_TRUNK
##    [Setup]    SISO Coam Test Setup
##    ${cell_list}    Create List    ${11}
##    Get UE From Init File and Make call    cell_list=${cell_list}    with_peak=${False}
##    [Teardown]    SISO Coam Test Teardown

*** Keywords ***
