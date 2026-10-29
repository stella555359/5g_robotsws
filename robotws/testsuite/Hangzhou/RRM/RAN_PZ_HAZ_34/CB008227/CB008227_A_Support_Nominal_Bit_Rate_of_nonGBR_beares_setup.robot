*** Settings ***
Resource    ./Resources/CB008227_common_keywords.robot
Variables    ./Resources/CB008227_Variables.py


Documentation
...   author: xiaodan.li
...   contact: xiaodan.li@nokia-sbell.com
...   squad group: SG_03
...   Feature CB008227-A

Suite Setup    Run Keywords
...    Common Suite Setup for COAM    AND
...    Common Case TestLine Setup for A    AND
...    Get gnb release info    AND
...    Adjust gNB_RU Attenuation

Suite Teardown    Run Keywords
...               Common Suite Teardown for COAM   AND
...               Run Keyword And Ignore Error    COAM Teardown gnb connections

*** Variables ***
${golden_scf_name_gnb0}    7326_784_SCF
${golden_scf_name_gnb1}    7326_784_SCF_gnb2
${golden_scf_name_enb}    Configuration_scf_Enb.xml
${epc_log_path}    /opt/workspace/CRT/Master/Case_Logs/
${ue_type}    ${tl.ues[0].capabilities[0]}
${mdrb_apn_name}    ${tl.ues[0].pdn[2]}
${dxdata2_apn_name}    ${tl.ues[0].pdn[0]}
${dl_throughput}    600M
${dl_port_5QI7}    ${53385}
${dl_port_5QI9}    ${55379}
@{dl_ports}    ${dl_port_5QI7}    ${dl_port_5QI9}
${file_name_A11}    8227_A11
${file_name_E01}    8227_E01
${file_name_EA01}    8227_EA01


*** Test Cases ***
[1]CB008227_A11_B5_Online_modification_Nominal_Bit_Rate_parameters_SA_NSA
    [Documentation]    This user scenario describes the gNB behaviour for Online modification Nominal Bit Rate parameters.
    [Setup]    robot_common_operations.Common Case Setup
    Precondition for Sansumg UE    ue_type=${ue_type}    ui_version=S21UI3.1
    Set APN point for sanmsung until succeed    apn_name=${mdrb_apn_name}
    ${PA_value}    Attach and check NBR NSA    file_name=${file_name_A11}
    ${TPUT_SUM_AVE_A01}    TPUT SUM average evaluate    file_name=${file_name_A11}
    ##Add check 8227_E01
    Run keyword If    '${release}'=='SBTS24R2_ENB_0'
    ...    Online modify NIDD on gnb    gnb_index=${0}   Modify_Para_Online=${PARAMETERS_TO_ONLINE_MODIFY_GNB1_E01_24R2}
    ...    ELSE    Online modify NIDD on gnb    gnb_index=${0}   Modify_Para_Online=${PARAMETERS_TO_ONLINE_MODIFY_GNB1_E01}
    Wait until keyword succeeds    3X    10s    Check NBR bearer take effect    NBR_value_max=${160}    NBR_value_min=${150}
    ...    noGBR_value_max=${90}    noGBR_value_min=${70}    value=${PA_value}    file_name=${file_name_E01}
    ${TPUT_SUM_AVE_E01}    TPUT SUM average evaluate    file_name=${file_name_E01}
    ${rate}    Evaluate    ${TPUT_SUM_AVE_E01}/${TPUT_SUM_AVE_A01}
    Should be true    ${0.6} < ${rate} < ${0.7}
    ##Add check 8227_EA01
    Online modify NIDD on gnb    gnb_index=${0}   Modify_Para_Online=${PARAMETERS_TO_ONLINE_MODIFY_GNB1_EA01}
    Run Keyword if    '${release_info}' != '${branch}[1]'    Check slice NBR congestion NSA EA01    file_name=${file_name_EA01}    PA=${PA_value}
    [Teardown]    run keywords
    ...    Set APN point for sanmsung until succeed    apn_name=${dxdata2_apn_name}    AND
    ...    Online modify NIDD on gnb    gnb_index=${0}    Modify_Para_Online=${PARAMETERS_TO_ONLINE_RECOVER_GNB1_A11}    AND
    ...    Case Teardown    AND
    ...    Run Keyword And Ignore Error    Adjust gNB_RU Attenuation

*** Keywords ***
Common Case TestLine Setup for A
    ${release}=    Get sagnb release title
    set suite variable    ${release}
    Common Case TestLine Setup with singe BTS    gnb_index=${0}
    ...    ModifySCF_Beforecommission=True    golden_scf_name=${golden_scf_name_gnb0}_${release}.xml
    ...    scf_path=${tl_scf_dir_path}    ParamterToModify=${ParamterToModify_A}
    Wait until keyword succeeds    20 min    20s
    ...    Check the cells status on air    bts_host=${bts_host0}   connection=gnb0
    Run keyword If    '${release}'=='SBTS24R2_ENB_0'    Online modify NIDD on gnb
    ...    gnb_index=${0}    Modify_Para_Online=${PARAMETERS_TO_ONLINE_MODIFY_GNB1_A11_24R2}
    ...    ELSE    Online modify NIDD on gnb
    ...    gnb_index=${0}    Modify_Para_Online=${PARAMETERS_TO_ONLINE_MODIFY_GNB1_A11}
    Online modify nsaDrbParam to dlOverF1U    gnb_index=${0}

check NBR bearer Tput
    [Arguments]    ${file_name}    ${dl_ports}=${dl_ports}
    FOR    ${index}    IN RANGE    ${30}    ${34}
        Adjust gNB_RU Attenuation    gnb1_cell1_value=${index}    enb_cell_value=${0}
        Start Traffic And Download the listened traffic    file_name_DL=${file_name}_DL_NBR
        ...    dl_ports=${dl_ports}    dl_throughput=${dl_throughput}
        ${status_1}    Run keyword and return status    Check beare value should be true
        ...    file_name=${file_name}_DL_NBR_${dl_port_5QI7}.txt    value_min=${120}    value_max=${145}
        ${status_2}    Run keyword and return status    Check beare value should be true
        ...    file_name=${file_name}_DL_NBR_${dl_port_5QI9}.txt    value_min=${250}    value_max=${260}
        Exit For Loop If    '${status_1}'=='True' and '${status_2}'=='True'
    END
    Should be equal    ${status_1}    ${True}
    Should be equal    ${status_2}    ${True}
    [Return]    ${index}

Attach and check NBR NSA
    [Arguments]    ${file_name}    ${ue_type}=${ue_type}    ${dl_ports}=${dl_ports}
    Adjust gNB_RU Attenuation    gnb1_cell1_value=${0}    enb_cell_value=${0}
    Attach and check power UE    ue_type=${ue_type}    4G_check=True
    Adjust gNB_RU Attenuation    gnb1_cell1_value=${15}    enb_cell_value=${0}
    Start Traffic And Download the listened traffic    file_name_DL=${file_name}_DL_notNBR
    ...    dl_ports=${dl_ports}    dl_throughput=${dl_throughput}
    Check beare value should be true
    ...    file_name=${file_name}_DL_notNBR_${dl_port_5QI7}.txt    value_min=${300}    value_max=${430}
    Check beare value should be true
    ...    file_name=${file_name}_DL_notNBR_${dl_port_5QI9}.txt    value_min=${300}    value_max=${430}
    ${PA_value}    Wait until keyword succeeds    3X    10s    check NBR bearer Tput    file_name=${file_name}
    ...    dl_ports=${dl_ports}
    [Return]    ${PA_value}
    [Teardown]    power_ue.UE Detach    ue_type=${ue_type}    ue_index=${0}

Check NBR bearer take effect
    [Arguments]    ${file_name}    ${NBR_value_max}=${65}    ${NBR_value_min}=${55}    ${noGBR_value_min}=${0}
    ...     ${noGBR_value_max}=${50}    ${value}=${38}
    Adjust gNB_RU Attenuation    gnb1_cell1_value=${value}    enb_cell_value=${0}
    Attach and check power UE    ue_type=${ue_type}    4G_check=True
    Start Traffic And Download the listened traffic    file_name_DL=${file_name}_DL_NBR
    ...    dl_ports=${dl_ports}    dl_throughput=${dl_throughput}
    Check beare value should be true
    ...    file_name=${file_name}_DL_NBR_${dl_port_5QI7}.txt    value_min=${NoGBR_value_min}    value_max=${NoGBR_value_max}
    Check beare value should be true
    ...    file_name=${file_name}_DL_NBR_${dl_port_5QI9}.txt    value_min=${NBR_value_min}    value_max=${NBR_value_max}
    [Teardown]    power_ue.UE Detach    ue_type=${ue_type}    ue_index=${0}

TPUT SUM average evaluate
    [Arguments]    ${file_name}
    ${value_list}    ${average_5QI7}    check beare value    file_name=${epc_log_path}${file_name}_DL_NBR_${dl_port_5QI7}.txt
    ${value_list}    ${average_5QI9}    check beare value    file_name=${epc_log_path}${file_name}_DL_NBR_${dl_port_5QI9}.txt
    ${TPUT_SUM}    Evaluate    ${average_5QI7}+${average_5QI9}
    [Return]    ${TPUT_SUM}

Check slice NBR congestion NSA EA01
    [Arguments]    ${file_name}    ${PA}=${PA_value}

    ${average_QCI7}    ${average_QCI9}    Wait until keyword succeeds    3X    10s    Check NBR congestion NSA
    ...    file_name=${file_name}    PA=${PA}
    ...    min_5QI7=${90}    max_5QI7=${130}     min_5QI9=${90}    max_5QI9=${130}
    ${Gap1}    Evaluate    abs(${average_QCI7}-${average_QCI9})
    Should be true    ${0}<=${Gap1}<=${5}
    Check D Counter    value_1=${299}    value_Average=${1}    dl_ports=${dl_ports}

Check NBR congestion NSA
     [Arguments]    ${file_name}    ${min_5QI7}   ${min_5QI9}    ${max_5QI7}    ${max_5QI9}
    ...    ${PA}=${28}    ${PA_NBR_Max}=${${PA}+${1}}
    Attach and check power UE    ue_type=${ue_type}    4G_check=True
    FOR    ${index}    IN RANGE    ${PA}    ${PA_NBR_Max}
         Adjust gNB_RU Attenuation    gnb1_cell1_value=${index}    enb_cell_value=${0}
         Start Traffic And Download the listened traffic    file_name_DL=${file_name}
         ...    dl_ports=${dl_ports}    dl_throughput=${dl_throughput}
         ${status_1}    Run keyword and return status    Check beare value should be true
         ...    file_name=${file_name}_${dl_port_5QI7}.txt    value_min=${min_5QI7}    value_max=${max_5QI7}
         ${status_2}    Run keyword and return status    Check beare value should be true
         ...    file_name=${file_name}_${dl_port_5QI9}.txt    value_min=${min_5QI9}    value_max=${max_5QI9}
         Exit For Loop If    '${status_1}'=='True' and '${status_2}'=='True'
    END
    Should be equal    ${status_1}    ${True}
    Should be equal    ${status_2}    ${True}
    ${average_QCI7}    Check beare value should be true
    ...    file_name=${file_name}_${dl_port_5QI7}.txt    value_min=${min_5QI7}    value_max=${max_5QI7}
    ${average_QCI9}    Check beare value should be true
    ...    file_name=${file_name}_${dl_port_5QI9}.txt    value_min=${min_5QI9}    value_max=${max_5QI9}
    ${average_QCI7}    Convert To Integer    ${average_QCI7}
    ${average_QCI9}    Convert To Integer    ${average_QCI9}
    [Return]    ${average_QCI7}    ${average_QCI9}

Check D Counter
    [Arguments]    ${value_1}    ${value_Average}
    ...    ${counter_id}=${counter_id_D01_gNB1}    ${counter_dic_path}=${counter_dic_path_D01_gNB1}
    ...    ${ue_index_DL}=NULL    ${ue_index_UL}=NULL   ${dl_ports}=NULL    ${ul_ports}=NULL
    Power UE Start DL traffic    dl_throughput=${dl_throughput}    duration=1200    dl_port=${dl_port_5QI9}
    Power UE Start DL traffic    dl_throughput=${dl_throughput}    duration=1200    dl_port=${dl_port_5QI7}
    Prepare to caculate PM counter    period=start
    comment    check the NBR_congestion counter
    Prepare to caculate PM counter    period=end
    Check NBR Congetion Counter    value_1=${value_1}    value_Average=${value_Average}
    ...    counter_id=${counter_id}    counter_dic_path=${counter_dic_path}
    [Teardown]    Stop DL/UL traffic    ue_index_DL=${ue_index_DL}    ue_index_UL=${ue_index_UL}
    ...    ue_index_DL=${ue_index_list}    ue_index_UL=${ue_index_iperf}
