*** Settings ***
Suite Setup          CB008952 Suite Level Setup
Suite Teardown       SISO Coam Suite Teardown
Test Setup           CB008952 Case Level Setup
Test Teardown        SISO Coam Test Teardown
Test Timeout         4h

Resource    testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/robot/siso_common_case/variable/Variables_5G.robot
Variables   testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/robot/siso_common_case/variable/made_variable.py
Resource    ${BASIC_PATH_5G}/5G_Setup_And_Teardown.robot
Resource    ${BASIC_PATH_5G}/General_SiSo_Initiate_RF_Statistics_diagnostic_test_withL3call.robot
Resource    ${BASIC_PATH_Common}/Manual_SiSo_SM_BTS_Block_Site.robot
Resource    ${BASIC_PATH_LTE}/Manual_SiSo_SM_LTE_RAT_reset.robot
Resource    ${BASIC_PATH_LTE}/Manual_SiSo_SM_BTS_Site_Reset.robot
Resource    ${BASIC_PATH_LTE}/Manual_SiSo_SM_LTE_Cell_block_unblock.robot
Resource    ${BASIC_PATH_LTE}/Manual_SiSo_CALL_LTE_data_call.robot
Resource    ./resource/resource.robot
#Resource    testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/lines/SG5/robot/siso/resources/siso_keywords.robot
Resource    testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/robot/siso_common_case/step_keywords/Common/basic/simple_ue.robot

Documentation
...    Author:Liu Yue
...    contact:wei.2.duan@nokia-sbell.com
...    squad group:SG_05
...    Feature CB008952_D 23R3 program

Force Tags            5G_RAN    5G_RAN_TDD    RAN_5G_TDD    RAN_5G
...    PY36

*** Variables ***
${CASE_LOG_PATH}    ${TS_CASE_LOG_PATH}
*** Test Cases ***
#TL064
[1]CB008952-D_15_General_SiSo_E2E_system_setup_with_data_transfer_for_configuration_feature_testing_with_legacy_Bbcellset
    [Tags]    SBTS00
    ${cell_list}    create list    ${2}
    Get UE From Init File and Make call with cpe 3_2    cell_list=${cell_list}    with_peak=${True}
#[1][2.0] Manual_SiSo_SM_BTS_Block_Site
#    [Tags]    SBTS00
#    Selenium Login And Disable Screen Lock
#    Manual_SiSo_SM_BTS_Block_Site
[1][2.0] Manual_SiSo_SM_LTE_RAT_reset
    [Tags]    SBTS00
    Manual_SiSo_SM_LTE_RAT_reset_with_CBRS
#[1][1.0] Manual_SiSo_SM_BTS_Site_Reset
#    [Tags]    SBTS00
#    Manual_SiSo_SM_BTS_Site_Reset
#[1][1.0] Manual_SiSo_SM_LTE Cell_block_unblock
#    [Tags]    SBTS00
#    Manual_SiSo_SM_LTE Cell_block_unblock
[1]Manual_SiSo_CALL_LTE_data_call
    [Tags]    SBTS00    1S-1CC-NR100-LTE20
    ${cell_list}    create list    ${21}
    Restart CBRS via cygwin
    Simple UE L3 Call And Throughput with cpe 3_2    cell_list=${cell_list}    scf_path=${Case_SCF_Path}    dl_tp=210    ul_tp=10
    L3 call with Check Throughput with cpe 3_2
    Manual_SiSo_SM_LTE Cell_block_unblock
[1]Manual_SiSo_CALL_NR_data_call
    [Tags]    SBTS00    2S-1CC-NR100-LTE20
    ${cell_list}    create list    ${21}
    Restart CBRS via cygwin
    Simple UE L3 Call And Throughput with cpe 3_2    cell_list=${cell_list}    scf_path=${Case_SCF_Path}    dl_tp=300    ul_tp=10
[1][1.0] Manual_SiSo_SM_LTE Cell_block_unblock
    [Tags]    SBTS00    1S-1CC-NR100-LTE20
    Manual_SiSo_SM_LTE Cell_block_unblock
[1][1.0] Manual_SiSo_SM_BTS_Site_Reset
    [Tags]    SBTS00    2S-1CC-NR100-LTE20
    Manual_SiSo_SM_BTS_Site_Reset
