*** Settings ***
Documentation    author: Chen Yanfen
...              Group: RAN_PZ_HAZ3_SG02
...              contact: helen.1.chen@nokia-sbell.com


Resource          testsuite/Hangzhou/RRM/RAN_PZ_HAZ_34/CB006915/resources/CB006915_common_keywords.robot
Resource          testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/robot/siso_common_case/variable/Variables_5G.robot
Resource          testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/robot/siso_common_case/cases/5G/5G_Setup_And_Teardown.robot
Resource          testsuite/Hangzhou/RRM/RAN_PZ_HAZ_34/CB013945/resources/CB013945_common_keywords.robot

Suite Setup       SISO Coam Suite Setup
Suite Teardown    SISO Coam Suite Teardown

*** Variables ***
${ul_expect_mumimo_tput}    400
${dl_expect_mumimo_tput}    2800
@{cpe_ue_index}    0    1
@{cell_id}    185663489
${if_commissioning}    False
@{ue_list}    6
@{swconfig_parameter}    0x420062 = 1
@{swconfig_delete_parameter}    0x420062
${ul_expect_tput}    220
${dl_expect_tput}    1200
*** Test Cases ***
[1]CB013945-SR-A_7_check 2 dynamical UE best suited paired status in PDSCH slot with multiple dedicated BWP
    [Setup]    Case_Setup
    ${SCF_CB008940-Q}    Replace String    ${Golden_SCF_Path}    .xml    _CB008940-Q.xml
    Commissioning SCF And Check On Air    scf_path=${SCF_CB008940-Q}
    Muti_CPE_UEs_UL_DL_Traffic    ue_index=${1}    cpe_ue_index=${cpe_ue_index}
    Catch_Logs_with_gnb_logs
    Multi_UEs_Check_Tput    cell_ids=${cell_id}    ultarget_throughput=${ul_expect_mumimo_tput}
    ...    dltarget_throughput=${dl_expect_mumimo_tput}
    Check_2UEs_DL_Mumimo_Paired
    Check_Dynamic_Switch_to_RAT0
    Multi CPE stop dl ul traffic    ue_index=1    cpe_ue_index=${cpe_ue_index}
    Check_Start_Prb_Randomization    ue_index=1    cpe_ue_index=${cpe_ue_index}    dl_tp=${1200}
    [Teardown]    Case_Teardown

[1]CB013945-SR-W_30_check VoNR RAT1 MOS and PLR curves based TDL-C with coding gain IWK DLMUMIMO
    [Setup]    Case_Setup
    ${SCF_CB008940-Q}    Replace String    ${Golden_SCF_Path}    .xml    _CB008940-Q.xml
    Commissioning SCF And Check On Air    scf_path=${SCF_CB008940-Q}
    Spark_MultiUE Prepare    ue_list=${ue_list}
    Spark_MultiUE Attach    ue_list=${ue_list}
    #Perform and Check Vonr Call    mo_ueindex=5
    Perform and Check Vonr Call    mo_ueindex=6
    Muti_CPE_UEs_UL_DL_Traffic    ue_index=${1}    cpe_ue_index=${cpe_ue_index}
    Multi_UEs_Check_Tput    cell_ids=${cell_id}    ultarget_throughput=${ul_expect_mumimo_tput}
    ...    dltarget_throughput=${dl_expect_mumimo_tput}
    [Teardown]    Case_Teardown

[1]CB013945-SR-B_22_check VoNR Ues HARQ retransmission improved with 3 non-GBR dynamic UEs and 2 VoNR legacy UE with DlVoNRPowerBoost
    [Setup]    Case_Setup
    ${SCF_CB008940-Q}    Replace String    ${Golden_SCF_Path}    .xml    _CB008940-Q.xml
    Commissioning SCF And Check On Air    scf_path=${SCF_CB008940-Q}
    Spark_MultiUE Prepare    ue_list=${ue_list}
    Spark_MultiUE Attach    ue_list=${ue_list}
    #Perform and Check Vonr Call    mo_ueindex=5
    Perform and Check Vonr Call    mo_ueindex=6
    Muti_CPE_UEs_UL_DL_Traffic    ue_index=${1}    cpe_ue_index=${cpe_ue_index}
    Multi_UEs_Check_Tput    cell_ids=${cell_id}    ultarget_throughput=${ul_expect_mumimo_tput}
    ...    dltarget_throughput=${dl_expect_mumimo_tput}
    [Teardown]    Case_Teardown

[1]CB013945-SR-B_46_check arificical load PM counters with actEmfTestMode enable and PRB pooling
    [Setup]    Case_Setup
    ${SCF_CB008940-Q}    Replace String    ${Golden_SCF_Path}    .xml    _CB008940-Q.xml
    Commissioning SCF And Check On Air    scf_path=${SCF_CB008940-Q}
    [Teardown]    Case_Teardown

[1]CB013945-SR-B_65_check full board Tput throughput after CB013945 enable IWK CB013199
    [Setup]    Case_Setup
    Modify_Swconfig_And_Crasign    swconfig_modify=${swconfig_parameter}    localFilePath=/home/ute/
    ${SCF_CB008940-Q}    Replace String    ${Golden_SCF_Path}    .xml    _CB008940-Q.xml
    Commissioning SCF And Check On Air    scf_path=${SCF_CB008940-Q}
    Single CPE DL Traffic    ue_index=1
    Single CPE DL Traffic    ue_index=3
    Single CPE DL Traffic    ue_index=4
    ${cell_id_0}    create list    ${185663489}
    Single CPE verify dl throughput    ue_index=1    dl_exp=${dl_expect_tput}    cells=${cell_id_0}
    ${cell_id_1}    create list    ${185663490}
    Single CPE verify dl throughput    ue_index=1    dl_exp=${dl_expect_tput}    cells=${cell_id_1}
    ${cell_id_2}    create list    ${185663491}
    Single CPE verify dl throughput    ue_index=1    dl_exp=${dl_expect_tput}    cells=${cell_id_2}
    Delete_Swconfig_Paramter_And_Crasign    swconfig_modify=${swconfig_delete_parameter}    localFilePath=/home/ute/
    [Teardown]    Case_Teardown