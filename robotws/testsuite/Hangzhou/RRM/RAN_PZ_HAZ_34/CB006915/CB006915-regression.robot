*** Settings ***
Documentation     author: Chen Helen
...               contact: helen.1.chen@nokia-sbell.com
...               squad group: MMW_02
Suite Setup       SISO Coam Suite Setup
Suite Teardown    SISO Coam Suite Teardown

Resource    testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/robot/siso_common_case/variable/Variables_5G.robot
Resource    ${BASIC_PATH_5G}/5G_Setup_And_Teardown.robot
Resource    testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/robot/siso_common_case/step_keywords/5G/cell_addition_deletion_online.robot
Resource          ./resources/CB006915_common_keywords.robot

*** Variables ***
${ul_2ues_tput_IWK_CB010388}    240
${dl_2ues_tput_IWK_CB010388}    1400
${ul_tput_IWK_CB010388}    120
${dl_tput_IWK_CB010388}    700
${ul_2ues_throughput}    220
${dl_2ues_throughput}    1400
${ul_throughput}    120
${dl_throughput}    700
${if_commissioning}    False
@{cpe_cell92_ues_index}    0    1

*** Test Cases ***
[1][1.0]CB006915-SR-N_6_check_cells_TP_with_Cell_addition_BF
    [Documentation]
    [Tags]
    [Setup]    Case_Setup
    ${SCF_CB008940-Q}    Replace String    ${Golden_SCF_Path}    .xml    _CB008940-Q.xml
    Commissioning SCF And Check On Air    scf_path=${SCF_CB008940-Q}
    Muti_CPE_UEs_UL_DL_Traffic    ue_index=${1}    cpe_ue_index=${cpe_ue_index}
    Catch_Logs_with_gnb_logs
    Get_and_Unzip_Tti_Log
    Check_ZAB_Value
    Multi_UEs_Check_Tput    cell_ids=${2mimocell_ids}    ultarget_throughput=${ul_2ues_throughput}
    ...    dltarget_throughput=${dl_2ues_throughput}
    Multi_UEs_Check_Tput    cell_ids=${cell_id}    ultarget_throughput=${ul_throughput}
    ...    dltarget_throughput=${dl_throughput}
    Multi CPE stop dl ul traffic    ue_index=1    cpe_ue_index=${cpe_cell92_ues_index}
    Online Cell addition deletion
    sleep    2min
    CPE detach    ue_index=${cpe_cell92_ues_index}[0]
    CPE detach    ue_index=${cpe_cell92_ues_index}[1]
    CPE attach and verify    ue_index=${cpe_cell92_ues_index}[0]    pci=${pci}[0]
    CPE attach and verify    ue_index=${cpe_cell92_ues_index}[1]    pci=${pci}[1]
    sleep   5s
    CPE start dl ul traffic    ue_index=${cpe_cell92_ues_index}[0]    dl_tp=${dl_tp}    ul_tp=${ul_tp}
    CPE start dl ul traffic    ue_index=${cpe_cell92_ues_index}[1]    dl_tp=${dl_tp}    ul_tp=${ul_tp}
    Multi_UEs_Check_Tput    cell_ids=${2mimocell_ids}    ultarget_throughput=${ul_2ues_throughput}
    ...    dltarget_throughput=${dl_2ues_throughput}
    Multi_UEs_Check_Tput    cell_ids=${cell_id}    ultarget_throughput=${ul_throughput}
    ...    dltarget_throughput=${dl_throughput}
    Multi CPE stop dl ul traffic    ue_index=1    cpe_ue_index=${cpe_ue_index}
    [Teardown]    Case_Teardown

[1][1.0]CB006915-SR-N_7_check_UE_status_after_cell_addition_and_deletion_BF
    [Documentation]
    [Tags]
    [Setup]    Case_Setup
    Log To Console    \n *** test result as first case
    [Teardown]    Case_Teardown

[1][1.0]CB006915-SR-N_5_check_gNB_status_with_Cell_addition_BF
    [Documentation]
    [Tags]
    [Setup]    Case_Setup
    Log To Console    \n *** test result as first case
    [Teardown]    Case_Teardown

[1][1.0]CB006915-SR-N_12_check_gNB_status_with_IWK_CB010388-A
    [Documentation]
    [Tags]
    [Setup]    Case_Setup
    Log To Console    \n *** test result as first case
    [Teardown]    Case_Teardown

[1][1.0]CB006915-SR-N_13_check_each_cell_TP_with_IWK_CB010388-A
    [Documentation]
    [Tags]
    [Setup]    Case_Setup
    Log To Console    \n *** test result as first case
    [Teardown]    Case_Teardown

[1][1.0]CB006915-SR-N_14_check_PRB_pooling_functionality_with_IWK_CB010388-A
    [Documentation]
    [Tags]
    [Setup]    Case_Setup
    Log To Console    \n *** test result as first case
    [Teardown]    Case_Teardown
