*** Settings ***
Documentation     author: Chen Helen
...               contact: helen.1.chen@nokia-sbell.com
...               squad group: MMW_02
Suite Setup       SISO Coam Suite Setup
Suite Teardown    SISO Coam Suite Teardown

Resource    testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/robot/siso_common_case/variable/Variables_5G.robot
Resource    ${BASIC_PATH_5G}/5G_Setup_And_Teardown.robot
Resource    ../CB006915/resources/CB006915_common_keywords.robot
Resource    ./Resource/CB008940_common_keywords.robot

*** Variables ***
${ul_2ues_tput}    240
${dl_2ues_tput}    1400
${ul_tput}    120
${dl_tput}    700
${if_commissioning}    False
@{cpe_cell92_ues_index}    0    1

*** Test Cases ***
[1][1.0]CB008940-SR-Q_36_check new cell ZAB privilege with Cell addition with ZAB privilege BF
    [Setup]    Case_Setup
    ${SCF_CB008940-Q}    Replace String    ${Golden_SCF_Path}    .xml    _CB008940-Q.xml
    Commissioning SCF And Check On Air    scf_path=${SCF_CB008940-Q}
    #Log to console     \n***Start DL and UL traffic***
    #Muti_CPE_UEs_UL_DL_Traffic    ue_index=${1}    cpe_ue_index=${cpe_ue_index}
    #Log to console     \n***check ZAB and Mumimo paired and PM counter***
    #Catch_Logs_with_gnb_logs
    #Check_ZAB_Value
    #Check_2UE_Mumimo_Paired
    #Check_DL_Pool_Counter
    #Check_UL_Pool_Counter
    #Multi CPE stop dl ul traffic    ue_index=1    cpe_ue_index=${cpe_cell92_ues_index}
    #Log to console     \n***Cell addition deletion***
    Online Cell addition deletion
    sleep    120s
    #CPE detach    ue_index=${cpe_cell92_ues_index}[0]
    #CPE detach    ue_index=${cpe_cell92_ues_index}[1]
    #CPE attach and verify    ue_index=${cpe_cell92_ues_index}[0]    pci=${pci}[0]
    #CPE attach and verify    ue_index=${cpe_cell92_ues_index}[1]    pci=${pci}[1]
    #sleep   5s
    #CPE start dl ul traffic    ue_index=${cpe_cell92_ues_index}[0]    dl_tp=${dl_tp}    ul_tp=${ul_tp}
    #CPE start dl ul traffic    ue_index=${cpe_cell92_ues_index}[1]    dl_tp=${dl_tp}    ul_tp=${ul_tp}
    #Log to console     \n***Check Tput***
    #Multi_UEs_Check_Tput    cell_ids=${2mimocell_ids}    ultarget_throughput=${ul_2ues_tput}
    #...    dltarget_throughput=${dl_2ues_tput}
    #Multi_UEs_Check_Tput    cell_ids=${cell_id}    ultarget_throughput=${ul_tput}
    #...    dltarget_throughput=${dl_tput}
    #Multi CPE stop dl ul traffic    ue_index=1    cpe_ue_index=${cpe_ue_index}
    [Teardown]    Case_Teardown

[1][1.0]CB008940-SR-Q_34_check cells TP with Cell addition with ZAB privilege BF
    [Setup]    Case_Setup
    Log To Console    \n *** test result as first case
    [Teardown]    Case_Teardown

