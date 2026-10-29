*** Settings ***
Documentation     author: Charlotte Wu
...               contact: charlotte.wu@nokia.com
Suite Setup       SISO Coam Suite Setup
Suite Teardown    SISO Coam Suite Teardown

Resource    testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/robot/siso_common_case/variable/Variables_5G.robot
Resource    ${BASIC_PATH_5G}/5G_Setup_And_Teardown.robot
Resource          ./resources/CB014474_A_common_keywords.robot
Resource          testsuite/Hangzhou/RRM/RAN_PZ_HAZ_34/CB013945/resources/CB013945_common_keywords.robot

*** Variables ***
${iperf_port_list}    ${tl.ues[0].iperf_details.ports}
${ul_2ues_throughput}    0
${dl_2ues_throughput}    2800
${dl_2ues_throughput_bler}    2200
${if_commissioning}    False
${dl_ue_throughput}    1500Mbits/sec
@{m90_cell10_ues_index}    0    1
@{nrcell_id}    607027204
${cell_index}    10
@{diff_dl_throughput}    1200    500
${diff_dl_2ues_throughput}    1700
@{spark_ue_list}    5
${spark_ul_tp}    10Mbits/sec
${spark_dl_tp}    10Mbits/sec
${ul_2ues_tput_80M}    300
${dl_2ues_tput_80M}    2200
${apn}    dxdata1
${single_cpe_ue_index}    0
${MTP_ue_index}    9
${MTP_ul_tp}     10
${MTP_dl_tp}    400

*** Test Cases ***
[1]CB014474-SR-A_1_Switching 2 MU-MIMO paired users to dynamically RAT0 as init-TX tansmission with 100MHz BW
    [Documentation]
    [Tags]
    [Setup]    TL2025_Case_Setup
    ${SCF_CB014474-A}    Replace String    ${Golden_SCF_Path}    .xml    _CB014474-A.xml
    Commissioning SCF And Check On Air    scf_path=${SCF_CB014474-A}
    Multi M90 Dyn UE L3 Call and Start Traffic   dl_tput=${dl_ue_throughput}
    ...    ue_index=${m90_cell10_ues_index[0]}    iperf_port=${iperf_port_list[0]}
    Multi M90 Dyn UE L3 Call and Start Traffic   dl_tput=${dl_ue_throughput}
    ...    ue_index=${m90_cell10_ues_index[1]}    iperf_port=${iperf_port_list[1]}
    Retry Check UEs Pair With Rat0    check_type=init-Tx    cell_index=${cell_index}
    Check DL Throught From Asslog    dl_list=${nrcell_id}    dl_tp=${dl_2ues_throughput}
    [Teardown]    Run Keywords
    ...    Multi M90 UE Stop traffic and detach with UEindex    ue_index=${m90_cell10_ues_index[0]}    iperf_port=${iperf_port_list[0]}
    ...    AND    Multi M90 UE Stop traffic and detach with UEindex    ue_index=${m90_cell10_ues_index[1]}    iperf_port=${iperf_port_list[1]}
    ...    AND    TL2025Case_Teardown

[1]CB014474-SR-A_66_Switching 2 MU-MIMO paired users to dynamically RAT0 as re-TX tansmission with 4 dedicated BWPs
    [Documentation]
    [Tags]
    [Setup]    TL2025_Case_Setup
    ${SCF_CB014474-A}    Replace String    ${Golden_SCF_Path}    .xml    _CB014474-A.xml
    Commissioning SCF And Check On Air    scf_path=${SCF_CB014474-A}
    Multi M90 Dyn UE L3 Call and Start Traffic    dl_tput=${dl_ue_throughput}
    ...    ue_index=${m90_cell10_ues_index[0]}    iperf_port=${iperf_port_list[0]}
    Multi M90 Dyn UE L3 Call and Start Traffic    dl_tput=${dl_ue_throughput}
    ...    ue_index=${m90_cell10_ues_index[1]}    iperf_port=${iperf_port_list[1]}
    Topyoung_MCS_Add_Att_Value
    Retry Check UEs Pair With Rat0    check_type=re-Tx    cell_index=${cell_index}
    Check DL Throught From Asslog    dl_list=${nrcell_id}    dl_tp=${dl_2ues_throughput_bler}
    [Teardown]    Run Keywords
    ...    Multi M90 UE Stop traffic and detach with UEindex    ue_index=${m90_cell10_ues_index[0]}    iperf_port=${iperf_port_list[0]}
    ...    AND    Multi M90 UE Stop traffic and detach with UEindex    ue_index=${m90_cell10_ues_index[1]}    iperf_port=${iperf_port_list[1]}
    ...    AND    Topyoung_MCS_Recover_Att_Value
    ...    AND    TL2025Case_Teardown