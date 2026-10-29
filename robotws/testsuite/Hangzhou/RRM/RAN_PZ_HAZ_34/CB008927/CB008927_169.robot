*** Settings ***
Documentation    author: Chen Yanfen
...              Group: RAN_PZ_HAZ3_SG02
...              contact: helen.1.chen@nokia-sbell.com


Resource          testsuite/Hangzhou/RRM/RAN_PZ_HAZ_34/CB006915/resources/CB006915_common_keywords.robot
Resource          testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/robot/siso_common_case/variable/Variables_5G.robot
Resource          testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/robot/siso_common_case/cases/5G/5G_Setup_And_Teardown.robot
Resource          testsuite/Hangzhou/RRM/RAN_PZ_HAZ_34/CB007113/resources/CB007113_common_keywords.robot
Library           testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/python/throughput/nrdim_throughput/interface.py

Suite Setup       SISO Coam Suite Setup
Suite Teardown    SISO Coam Suite Teardown

*** Variables ***
${ul_throughput}    240
${dl_throughput}    1500
@{cpe_ue_index}    0
@{cell_id}    185663489
${mcs_type}    hbte
${mcs_index}   0
${if_commissioning}    False
*** Test Cases ***
[1]CB008927-S_2_check_UE_peak_throughput_with_multi_beams_in_FR1_TDD
    [Setup]    Case_Setup
    ${SCF_CB008940-Q}    Replace String    ${Golden_SCF_Path}    .xml    _CB008940-Q.xml
    Commissioning SCF And Check On Air    scf_path=${SCF_CB008940-Q}
    ${peak_dl}    ${peak_ul}    get_theoretical_throughput    scf_path=${SCF_CB008940-Q}
    ...    cell_id=1    ue_ul_layer=${2}    ue_dl_layer=${4}
    Muti_CPE_UEs_UL_DL_Traffic    ue_index=${1}    cpe_ue_index=${cpe_ue_index}
    Multi_UEs_Check_Tput    cell_ids=${cell_id}    ultarget_throughput=${peak_ul}
    ...    dltarget_throughput=${peak_dl}
    Multi CPE stop dl ul traffic    ue_index=1    cpe_ue_index=${cpe_ue_index}
    [Teardown]   Case_Teardown

[1]CB008927-P_103_check_retransmission_as_a_dynamicswitch_RAT0_with_enable_actAdaptiveReTxResMcs_with_initial_transmission_as_RAT1
    [Setup]    Case_Setup
    ${SCF_CB008940-Q}    Replace String    ${Golden_SCF_Path}    .xml    _CB008940-Q.xml
    Commissioning SCF And Check On Air    scf_path=${SCF_CB008940-Q}
    MCS_Add_Att_Value
    Muti_CPE_UEs_UL_DL_Traffic    ue_index=${1}    cpe_ue_index=${cpe_ue_index}
    ${retry_times}    set variable    3
    FOR    ${times}    IN RANGE    ${retry_times}
        log to console    check retx uesed: ${times} times
        Catch_Logs_Filter_dlFdSchedData_with_gnb_logs
        ${runStaus}    run keyword and return status    Check_Retx_Rat_Type_with_Init
        Exit For Loop If    ${runStaus}
    END
    should be true    ${runStaus}
    Multi CPE stop dl ul traffic    ue_index=1    cpe_ue_index=${cpe_ue_index}
    MCS_Recover_Att_Value
    [Teardown]    Case_Teardown_For_CB008927

*** Keywords ***
MCS_Add_Att_Value
    MCS_Setup    mcs_type=${mcs_type}    mcs_index=${mcs_index}
    FOR    ${index}    IN RANGE    ${1}    ${32}    ${2}
        hbte.Set Odd Attenuations For Output Port    attenuation=${30}    B_Odd=${False}
        ...    begin_output_port=${2}    end_output_port=${2}
        ...    begin_input_port=${index}    end_input_port=${index}
    END
    mcs_common.Teardown MCS    mcs_type=${mcs_type}    mcs_index=0    mcs_alias=MCS_${mcs_index}

MCS_Recover_Att_Value
    MCS_Setup    mcs_type=${mcs_type}    mcs_index=${mcs_index}
    FOR    ${index}    IN RANGE    ${1}    ${32}    ${2}
        hbte.Set Odd Attenuations For Output Port    attenuation=${10}    B_Odd=${False}
        ...    begin_output_port=${2}    end_output_port=${2}
        ...    begin_input_port=${index}    end_input_port=${index}
    END
    mcs_common.Teardown MCS    mcs_type=${mcs_type}    mcs_index=0    mcs_alias=MCS_${mcs_index}

Case_Teardown_For_CB008927
    Log To Console    \n *** Case teardown
    Commissioning SCF And Check On Air    scf_path=${Golden_SCF_Path}
    Run Keyword And Ignore Error    robot_common_operations.Common Case Teardown
    Run Keyword And Ignore Error    Multi CPE Call Teardown    ue_index=1    cpe_ue_index=${cpe_ue_index}
    Run Keyword And Ignore Error    MCS_Recover_Att_Value
    ssh.Connect to    hostname=${tl.test_pc.default_ssh_connection_details.addr}
    ...               username=${tl.test_pc.default_ssh_connection_details.username}
    ...               password=${tl.test_pc.default_ssh_connection_details.password}
    ...               alias=ute
    Run Keyword And Ignore Error    ssh.send command    command=rm ${tti_script_path}/BTS-11332_${gnb_ip}_*_TTI
    ...    connection=ute
    Run Keyword And Ignore Error    ssh.send command    command=rm ${new_dir}/BTS-11332_${gnb_ip}_*_TTI
    ...    connection=ute
    Run Keyword And Ignore Error    ssh.disconnect    connection=ute
