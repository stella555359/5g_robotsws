*** Settings ***
Resource    ./Resources/CB008227_common_keywords.robot
Variables    ./Resources/CB008227_Variables.py


Documentation
...   author: xiaodan.li
...   contact: xiaodan.li@nokia-sbell.com
...   squad group: SG_03
...   Feature CB008227-D

Suite Setup    Run Keywords
...    Common Suite Setup for COAM
...    AND    Get gnb release info
...    AND    get_release_check_result    release_year_diff=25    release_num_diff=1
...    AND    Common Case TestLine Setup for D

Suite Teardown    Run Keywords
...               Common Suite Teardown for COAM   AND
...               Run Keyword And Ignore Error    COAM Teardown gnb connections

*** Variables ***
${golden_scf_name_34411}    golden_TDD
${golden_scf_name_37611}    7326_784_SCF
${scf_path}    /opt/workspace/CRT/Master/SCF_file/
${dl_port_5QI9}    ${55379}
${dl_port_5QI8}    ${55378}
${dl_port_5QI7}    ${53385}
@{dl_ports}    ${dl_port_5QI9}    ${dl_port_5QI8}    ${dl_port_5QI7}
${ul_port_5QI9}    ${53444}
${ul_port_5QI7}    ${53445}
@{ul_ports}    ${ul_port_5QI9}    ${ul_port_5QI7}
${dl_throughput}    500M
${ul_throughput}    80M
${file_name_D01}    8227_D01_DL_not_congestion_50
${file_name_D01_1}    8227_D01_DL_congestion_50_1
${file_name_D01_2}    8227_D01_DL_congestion_50_2
${file_name_D01_3}    8227_D01_DL_not_congestion_90
${file_name_D01_4}    8227_D01_DL_congestion_0
${file_name_D01_5}    8227_D01_DL_recovery_not_congestion_90
${file_name_D02}    8227_D02_UL_not_congestion_90
${file1_name_D02_1}    8227_D02_UL_not_congestion_90_1
${file1_name_D02_2}    8227_D02_UL_congestion_0_2
${file1_name_D02_3}    8227_D02_UL_not_congestion_90_2
@{ue_index_list}    ${0}    ${1}
@{ue_index_iperf}    ${-1}    ${-1}
@{ue_index_list_TL376}    ${0}    ${0}    ${0}
@{allow_fault_list}    7523    7107

*** Test Cases ***
[1]CB008227_D01_B1_PDSCH_NBR_congestion_detection_and_handling_NSA
    [Documentation]    This user scenario describes the gNB behavior related to NBR bearers congestion detection
    ...                and congestion handling.
    [Setup]    robot_common_operations.Common Case Setup
    Run keyword If    '${release}'=='SBTS24R2_ENB_0'
    ...    Online modify NIDD on gnb    gnb_index=${0}    Modify_Para_Online=${Modify_Para_Online_D01_24R2}
    ...    Delete_Para_Online=${ParameterToDelete_D01}
    ...    ELSE    Online modify NIDD on gnb    gnb_index=${0}    Modify_Para_Online=${Modify_Para_Online_D01}
    ...    Delete_Para_Online=${ParameterToDelete_D01}
    Precondition for Sansumg UE    ue_type=${ue_type}    ui_version=S21UI3.1
    Set APN point for sanmsung until succeed    apn_name=${mdrb_apn_name}
    #### maxNbrTrafficLimit=50, PA=28, has QCI9 NBR to congestion status
    Wait until keyword succeeds    3X    10s    Check 1 NBR enter to congestion status
    #### maxNbrTrafficLimit=50, PA=33, has NBR QCI9 and QCI7 all change to congestion status
    comment    ******Check 2 NBR enter to congestion status with maxNbrTrafficLimit=50*********
    Wait until keyword succeeds    3X    10s    Check 2 NBR enter to congestion status    PA=${59}
    ...    min_5QI7=${40}    min_5QI8=${40}    min_5QI9=${40}
    ...    max_5QI7=${100}    max_5QI8=${100}    max_5QI9=${100}    counter_value=${598}
    ### maxNbrTrafficLimit=90, PA=22, has no NBR to congestion status
    Run Keyword if    '${release_info}' == '${branch}[1]'
    ...    Online modify NIDD on gnb    gnb_index=${0}    Modify_Para_Online=${Modify_Para_Online_D01_1}
    ...    ELSE    Online modify NIDD on gnb    gnb_index=${0}    Modify_Para_Online=${Modify_Para_Online_D01_and_DA}
    ${index}    Check has no NBR enter to congestion status    PA=${30}    PA_NBR_Max=${35}
    ...    min_5QI7=${150}    min_5QI8=${150}    min_5QI9=${10}
    ...    max_5QI7=${160}    max_5QI8=${160}    max_5QI9=${60}
    ...    Gap1_min=${0}    Gap2_min=${90}    Gap3_min=${90}    Gap1_max=${10}    Gap2_max=${140}    Gap3_max=${140}
    ...    counter_value=${0}
    #### maxNbrTrafficLimit=0, PA=22, has NBR QCI9 and QCI7 all change to congestion status
    Online modify NIDD on gnb    gnb_index=${0}    Modify_Para_Online=${Modify_Para_Online_D01_2}
    Wait until keyword succeeds    3X    10s    Check 2 NBR enter to congestion status    PA=${index}
    ...    min_5QI7=${100}    min_5QI8=${100}    min_5QI9=${100}
    ...    max_5QI7=${145}    max_5QI8=${145}    max_5QI9=${145}    Gap=${10}
    #### maxNbrTrafficLimit=90, PA=22, has non-gBR recovery to NBR
    Online modify NIDD on gnb    gnb_index=${0}    Modify_Para_Online=${Modify_Para_Online_D01_1}
    Check has no NBR enter to congestion status    PA=${index}    min_5QI7=${150}    min_5QI8=${150}    min_5QI9=${10}
    ...    max_5QI7=${160}    max_5QI8=${160}    max_5QI9=${60}
    ...    Gap1_min=${0}    Gap2_min=${90}    Gap3_min=${90}    Gap1_max=${10}    Gap2_max=${140}    Gap3_max=${140}
    ### maxNbrTrafficLimit=10, PA=22, has NBR to pdcch congestion status
    Run Keyword if    '${release_info}' != '${branch}[1]'    Run keywords
    ...    Online modify NIDD on gnb    gnb_index=${0}    Modify_Para_Online=${Modify_Para_Online_DA}    AND
    ...    Check DA Counter for DL    value_1=${10}    ue_index_UL=${ue_index_list_TL376}    dl_ports=${dl_ports}
    [Teardown]    run keywords
    ...    Set APN point for sanmsung until succeed    apn_name=${dxdata2_apn_name}    AND
    ...    Online modify NIDD on gnb    gnb_index=${0}    Modify_Para_Online=${Modify_Para_Online_D01_Restore}    AND
    ...    Case Teardown    AND
    ...    Adjust gNB_RU Attenuation

[1]CB008227_D02_B1_PUSCH_NBR_congestion_detection_and_handling_NSA
    [Documentation]    This user scenario describes the gNB behavior related to NBR bearers congestion detection
    ...                and congestion handling.
    [Setup]    robot_common_operations.Common Case Setup
    AlarmWatchdog.add_allow_alarms    fault_id=${allow_fault_list}
    AlarmWatchdog.add_allow_alarms    fault_id=8000
    Run keyword If    '${release}'=='SBTS24R2_ENB_0'
    ...    Online modify parmeters    gnb_index=${0}    parameters_to_update=${Modify_Para_Online_D02_24R2}
    ...    ELSE    Online modify parmeters    gnb_index=${0}    parameters_to_update=${Modify_Para_Online_D02}
    power_ue.Prepare UE     ue_type=${ue_type}
    Attach and check NBR UL congestion NSA
    [Teardown]    run keywords
    ...    Online modify parmeters    gnb_index=${0}    parameters_to_update=${Modify_Para_Online_D02_Restore}    AND
    ...    Run Keyword And Ignore Error    Case Teardown    AND
    ...    Adjust gNB_RU Attenuation for 2UEs on TL34411

*** Keywords ***
Common Case TestLine Setup for D
    ${release}=    Get sagnb release title
    set suite variable    ${release}
    Run keyword If    '${release}'=='SBTS24R2_ENB_0'
    ...    Common Case TestLine Setup    golden_scf_name=${golden_scf_name_${gnb_instance}}_${release}.xml
    ...    scf_path=${scf_path}    ModifySCF_Beforecommission=True    ParamterToModify=${PARAMETERS_TO_MODIFY_GNB1_D_24R2}
    ...    ELSE    Common Case TestLine Setup    golden_scf_name=${golden_scf_name_${gnb_instance}}_${release}.xml
    ...    scf_path=${scf_path}    ModifySCF_Beforecommission=True    ParamterToModify=${PARAMETERS_TO_MODIFY_GNB1_D}
    Wait until keyword succeeds    20 min    20s
        ...    Check the cells status on air    bts_host=${bts_host0}   connection=gnb0
    Online modify nsaDrbParam to dlOverF1U    gnb_index=${0}    Delete_Para_Online=${PARAMETERS_TO_DELETE_GNB1_nsaDrbParam_D}
    ...    Add_Para_Online=${PARAMETERS_TO_ONLINE_ADD_GNB1_nsaDrbParam_D}

Check NBR congestion NSA
     [Arguments]    ${file_name}    ${min_5QI7}    ${min_5QI8}    ${min_5QI9}    ${max_5QI7}    ${max_5QI8}    ${max_5QI9}
    ...    ${PA}=${28}    ${PA_NBR_Max}=${${PA}+${1}}    ${ue_index_list}=${ue_index_list_TL376}
    FOR    ${index}    IN RANGE    ${PA}    ${PA_NBR_Max}
         Adjust gNB_RU Attenuation    gnb1_cell1_value=${index}    enb_cell_value=${0}
         Start Traffic And Download the listened traffic    file_name_DL=${file_name}
         ...    dl_ports=${dl_ports}    dl_throughput=${dl_throughput}    ue_index_list=${ue_index_list}
         ...    ue_index_iperf=${ue_index_list}
         ${status_1}    Run keyword and return status    Check beare value should be true
         ...    file_name=${file_name}_${dl_port_5QI7}.txt    value_min=${min_5QI7}    value_max=${max_5QI7}
         ${status_2}    Run keyword and return status    Check beare value should be true
         ...    file_name=${file_name}_${dl_port_5QI8}.txt    value_min=${min_5QI8}    value_max=${max_5QI8}
         ${status_3}    Run keyword and return status    Check beare value should be true
         ...    file_name=${file_name}_${dl_port_5QI9}.txt    value_min=${min_5QI9}    value_max=${max_5QI9}
         Exit For Loop If    '${status_1}'=='True' and '${status_2}'=='True' and '${status_3}'=='True'
    END
    Should be equal    ${status_1}    ${True}
    Should be equal    ${status_2}    ${True}
    Should be equal    ${status_3}    ${True}
    ${average_QCI7}    Check beare value should be true
    ...    file_name=${file_name}_${dl_port_5QI7}.txt    value_min=${min_5QI7}    value_max=${max_5QI7}
    ${average_QCI8}    Check beare value should be true
    ...    file_name=${file_name}_${dl_port_5QI8}.txt    value_min=${min_5QI8}    value_max=${max_5QI8}
    ${average_QCI9}    Check beare value should be true
    ...    file_name=${file_name}_${dl_port_5QI9}.txt    value_min=${min_5QI9}    value_max=${max_5QI9}
    ${average_QCI7}    Convert To Integer    ${average_QCI7}
    ${average_QCI8}    Convert To Integer    ${average_QCI8}
    ${average_QCI9}    Convert To Integer    ${average_QCI9}
    [Return]    ${average_QCI7}    ${average_QCI8}    ${average_QCI9}    ${index}

Attach and check NBR NSA
    [Arguments]    ${file_name_UL}=NULL    ${ul_ports}=NULL    ${ul_throughput}=NULL
    Adjust gNB_RU Attenuation for 2UEs on TL34411    gnb1_cell1_value=${0}    enb_cell1_value=${0}
    2UEs attach and check    4G_check=True
    Start Traffic And Download the listened traffic    file_name_UL=${file_name_UL}
    ...    ul_ports=${ul_ports}    ul_throughput=${ul_throughput}    ue_index_list=${ue_index_list}
    Check beare value should be true
    ...    file_name=${file_name_UL}_${ul_port_5QI7}.txt    value_min=${40}    value_max=${60}
    Check beare value should be true
    ...    file_name=${file_name_UL}_${ul_port_5QI9}.txt    value_min=${40}    value_max=${60}

check NBR UL bearer Tput
    [Arguments]
    ...    ${file_name1}=NULL    ${ul_ports}=NULL    ${ul_throughput}=NULL
    ...    ${PA_NBR}=NULL    ${PA_NBR_Max}=${${PA_NBR}+${5}}
    ...    ${min_5QI7_UL}=NULL    ${min_5QI9_UL}=NULL    ${max_5QI7_UL}=NULL    ${max_5QI9_UL}=NULL
    FOR    ${index}    IN RANGE    ${PA_NBR}    ${PA_NBR_Max}
         Adjust gNB_RU Attenuation for 2UEs on TL34411    gnb1_cell1_value=${index}    enb_cell1_value=${0}
         Start Traffic And Download the listened traffic    file_name_UL=${file_name1}
         ...    ul_ports=${ul_ports}    ul_throughput=${ul_throughput}    ue_index_list=${ue_index_list}
         ${status_1}    Run keyword and return status    Check beare value should be true
         ...    file_name=${file_name1}_${ul_port_5QI7}.txt    value_min=${min_5QI7_UL}    value_max=${max_5QI7_UL}
         ${status_2}    Run keyword and return status    Check beare value should be true
         ...    file_name=${file_name1}_${ul_port_5QI9}.txt    value_min=${min_5QI9_UL}    value_max=${max_5QI9_UL}
         Exit For Loop If    '${status_1}'=='True' and '${status_2}'=='True'
    END
    Should be equal    ${status_1}    ${True}
    Should be equal    ${status_2}    ${True}
    ${average_QCI7}    Check beare value should be true
         ...    file_name=${file_name1}_${ul_port_5QI7}.txt    value_min=${min_5QI7_UL}    value_max=${max_5QI7_UL}
    ${average_QCI9}    Check beare value should be true
         ...    file_name=${file_name1}_${ul_port_5QI9}.txt    value_min=${min_5QI9_UL}    value_max=${max_5QI9_UL}
    ${average_QCI7}    Convert To Integer    ${average_QCI7}
    ${average_QCI9}    Convert To Integer    ${average_QCI9}
    [Return]    ${average_QCI7}    ${average_QCI9}    ${index}

Check Beare And return status
    [Arguments]    ${file_name}    ${value_min}    ${value_max}
    ${Status}    Run keyword and return status    Check beare value should be true
    ...    file_name=${file_name}    value_min=${value_min}    value_max=${value_max}
    [Return]    ${Status}

Check D Counter
    [Arguments]    ${value_1}    ${value_Average}
    ...    ${counter_id}=${counter_id_D01_gNB1}    ${counter_dic_path}=${counter_dic_path_D01_gNB1}
    ...    ${ue_index_DL}=NULL    ${ue_index_UL}=NULL   ${dl_ports}=NULL    ${ul_ports}=NULL
    Power UE Start DL traffic    dl_throughput=${dl_throughput}    duration=1200    dl_port=${dl_port_5QI9}
    Power UE Start DL traffic    dl_throughput=${dl_throughput}    duration=1200    dl_port=${dl_port_5QI7}
    Power UE Start DL traffic    dl_throughput=${dl_throughput}    duration=1200    dl_port=${dl_port_5QI8}
    Prepare to caculate PM counter    period=start
    comment    check the NBR_congestion counter
    Prepare to caculate PM counter    period=end
    Check NBR Congetion Counter    value_1=${value_1}    value_Average=${value_Average}
    ...    counter_id=${counter_id}    counter_dic_path=${counter_dic_path}
    [Teardown]    Stop DL/UL traffic    ue_index_DL=${ue_index_DL}    ue_index_UL=${ue_index_UL}
    ...    dl_ports=${dl_ports}    ul_ports=${ul_ports}

Check DA Counter for DL
    [Arguments]    ${value_1}
    ...    ${counter_id}=${counter_id_D01_gNB1}    ${counter_dic_path}=${counter_dic_path_D01_gNB1}
    ...    ${ue_index_DL}=NULL    ${ue_index_UL}=NULL   ${dl_ports}=NULL    ${ul_ports}=NULL
    Power UE Start DL traffic    dl_throughput=${dl_throughput}    duration=1200    dl_port=${dl_port_5QI9}
    Power UE Start DL traffic    dl_throughput=${dl_throughput}    duration=1200    dl_port=${dl_port_5QI7}
    Power UE Start DL traffic    dl_throughput=${dl_throughput}    duration=1200    dl_port=${dl_port_5QI8}
    Prepare to caculate PM counter    period=start
    comment    check the NBR_congestion counter
    Prepare to caculate PM counter    period=end
    Sleep    40s
    ${counter_list}=    Get the PM counter
    ...    gnb_index=${0}    counter_id=${counter_id}    dic_path=${counter_dic_path}
    Should be True    ${counter_list[0]}>=${value_1}
    [Teardown]    Stop DL/UL traffic    ue_index_DL=${ue_index_DL}    ue_index_UL=${ue_index_UL}
    ...    dl_ports=${dl_ports}    ul_ports=${ul_ports}

Attach and check NBR UL congestion NSA
    ${average_QCI7}    ${average_QCI9}    ${index}    Wait until keyword succeeds    3X    10s    Attach and check NBR NSA
    ...    file_name_UL=${file_name_D02}
    ...    ul_ports=${ul_ports}    ul_throughput=${ul_throughput}
    comment    check NBR UL bearer Tput
    ${average_QCI7_1}    ${average_QCI9_1}    ${index}    Run Keyword if    '${check_result}'=='True'
    ...    Wait until keyword succeeds    3X    10s    check NBR UL bearer Tput
    ...    file_name1=${file1_name_D02_1}    ul_ports=${ul_ports}    ul_throughput=${ul_throughput}
    ...    PA_NBR=${35}    PA_NBR_Max=${40}    min_5QI7_UL=${18}    min_5QI9_UL=${28}    max_5QI7_UL=${22}    max_5QI9_UL=${35}
    ...    ELSE    Wait until keyword succeeds    3X    10s    check NBR UL bearer Tput
    ...    file_name1=${file1_name_D02_1}    ul_ports=${ul_ports}    ul_throughput=${ul_throughput}
    ...    PA_NBR=${35}    PA_NBR_Max=${40}    min_5QI7_UL=${18}    min_5QI9_UL=${30}    max_5QI7_UL=${22}    max_5QI9_UL=${35}
    ${Gap1}    Evaluate    abs(${average_QCI9_1}-${average_QCI7_1})
    Should be true    ${5}<=${Gap1}<=${15}
    comment    modify maxNbrTrafficLimit=0, check NBR congestion
    Online modify parmeters    gnb_index=${0}    parameters_to_update=${Modify_Para_Online_D01_2}
    ${average_QCI7_2}    ${average_QCI9_2}    ${index}    Run Keyword if    '${check_result}'=='True'
    ...    Wait until keyword succeeds    3X    10s    check NBR UL bearer Tput
    ...    file_name1=${file1_name_D02_2}    ul_ports=${ul_ports}
    ...    ul_throughput=${ul_throughput}    PA_NBR=${index}    PA_NBR_Max=${${index}+${1}}
    ...    min_5QI7_UL=${20}    min_5QI9_UL=${20}    max_5QI7_UL=${29}    max_5QI9_UL=${29}
    ...    ELSE    Wait until keyword succeeds    3X    10s    check NBR UL bearer Tput
    ...    file_name1=${file1_name_D02_2}    ul_ports=${ul_ports}
    ...    ul_throughput=${ul_throughput}    PA_NBR=${index}    PA_NBR_Max=${${index}+${1}}
    ...    min_5QI7_UL=${22}    min_5QI9_UL=${24}    max_5QI7_UL=${30}    max_5QI9_UL=${30}
    ${Gap2}    Evaluate    abs(${average_QCI9_2}-${average_QCI7_2})
    Should be true    ${0}<=${Gap2}<=${8}
    should be true    ${average_QCI7_2}>${average_QCI7_1}
    should be true    ${average_QCI9_2}<${average_QCI9_1}
    Check counter for D02    value_1=${299}    value_Average=${0}
    comment    modify maxNbrTrafficLimit=90, check NBR not congestion
    Run Keyword if    '${release_info}' == '${branch}[1]'
    ...    Online modify parmeters    gnb_index=${0}    parameters_to_update=${Modify_Para_Online_D01_1}
    ...    ELSE    Online modify parmeters    gnb_index=${0}    parameters_to_update=${Modify_Para_Online_D02_and_DA}
    ${average_QCI7_3}    ${average_QCI9_3}    ${index}    Run Keyword if    '${check_result}'=='True'
    ...    Wait until keyword succeeds    3X    10s    check NBR UL bearer Tput
    ...    file_name1=${file1_name_D02_3}    ul_ports=${ul_ports}
    ...    ul_throughput=${ul_throughput}    PA_NBR=${index}    PA_NBR_Max=${${index}+${1}}
    ...    min_5QI7_UL=${15}    min_5QI9_UL=${28}    max_5QI7_UL=${24}    max_5QI9_UL=${35}
    ...    ELSE    Wait until keyword succeeds    3X    10s    check NBR UL bearer Tput
    ...    file_name1=${file1_name_D02_3}    ul_ports=${ul_ports}
    ...    ul_throughput=${ul_throughput}    PA_NBR=${index}    PA_NBR_Max=${${index}+${1}}
    ...    min_5QI7_UL=${18}    min_5QI9_UL=${30}    max_5QI7_UL=${24}    max_5QI9_UL=${35}
    ${Gap3}    Evaluate    abs(${average_QCI9_3}-${average_QCI7_3})
    Should be true    ${5}<=${Gap3}<=${15}
    should be true    ${average_QCI7_3}<${average_QCI7_2}
    should be true    ${average_QCI9_3}>${average_QCI9_2}
    Check counter for D02    value_1=${0}    value_Average=${0}
    comment    modify maxNbrTrafficLimit=10, check pdcch NBR congestion
    Run Keyword if    '${release_info}' != '${branch}[1]'    Run keywords
    ...    Online modify parmeters    gnb_index=${0}    parameters_to_update=${Modify_Para_Online_DA}
    ...    AND    Check counter for DA    value_1=${10}
    [Teardown]    Run keywords
    ...    Stop DL/UL traffic    ue_index_DL=${ue_index_list}    ul_ports=${ul_ports}    AND
    ...    power_ue.UE Detach    ue_type=${ue_type}    ue_index=${0}    AND
    ...    power_ue.UE Detach    ue_type=${ue_type}    ue_index=${1}

Check counter for D02
    [Arguments]    ${value_1}    ${value_Average}
    ...    ${counter_id}=${counter_id_D02_gNB1}    ${counter_dic_path}=${counter_dic_path_D02_gNB1}
    Power UE Start UL traffic    ul_throughput=${ul_throughput}    duration=1200    ul_port=${ul_port_5QI9}    ue_index=${0}
    Power UE Start UL traffic    ul_throughput=${ul_throughput}    duration=1200    ul_port=${ul_port_5QI7}    ue_index=${1}
    Prepare to caculate PM counter    period=start
    comment    check the NBR_congestion counter
    Prepare to caculate PM counter    period=end
    Check NBR Congetion Counter    value_1=${value_1}
    ...    value_Average=${value_Average}    counter_id=${counter_id}    counter_dic_path=${counter_dic_path}
    [Teardown]    Stop DL/UL traffic    ue_index_DL=${ue_index_list}    ul_ports=${ul_ports}

Check counter for DA
    [Arguments]    ${value_1}
    ...    ${counter_id}=${counter_id_D02_gNB1}    ${counter_dic_path}=${counter_dic_path_D02_gNB1}
    Power UE Start UL traffic    ul_throughput=${ul_throughput}    duration=1200    ul_port=${ul_port_5QI9}    ue_index=${0}
    Power UE Start UL traffic    ul_throughput=${ul_throughput}    duration=1200    ul_port=${ul_port_5QI7}    ue_index=${1}
    Prepare to caculate PM counter    period=start
    comment    check the NBR_congestion counter
    Prepare to caculate PM counter    period=end
    sleep    40s
    ${counter_list}=    Get the PM counter
    ...    gnb_index=${0}    counter_id=${counter_id}    dic_path=${counter_dic_path}
    Should be True    ${counter_list[0]}>=${value_1}
    [Teardown]    Stop DL/UL traffic    ue_index_DL=${ue_index_list}    ul_ports=${ul_ports}

Check has no NBR enter to congestion status
    [Arguments]    ${PA}=${26}    ${PA_NBR_Max}=${${PA}+${1}}    ${min_5QI7}=${200}    ${min_5QI8}=${200}    ${min_5QI9}=${130}
    ...    ${max_5QI7}=${220}    ${max_5QI8}=${220}    ${max_5QI9}=${160}
    ...    ${Gap1_min}=${0}    ${Gap2_min}=${40}    ${Gap3_min}=${40}
    ...    ${Gap1_max}=${10}    ${Gap2_max}=${60}    ${Gap3_max}=${60}    ${counter_value}=NULL
    ${average_QCI7}    ${average_QCI8}    ${average_QCI9}    ${index}
    ...    Wait until keyword succeeds    3X    10s    Check NBR congestion NSA
    ...    file_name=${file_name_D01}    PA=${PA}    PA_NBR_Max=${PA_NBR_Max}    min_5QI7=${min_5QI7}    max_5QI7=${max_5QI7}
    ...    min_5QI8=${min_5QI8}    max_5QI8=${max_5QI8}    min_5QI9=${min_5QI9}    max_5QI9=${max_5QI9}
    ${Gap1}    Evaluate    abs(${average_QCI7}-${average_QCI8})
    Should be true    ${Gap1_min}<=${Gap1}<=${Gap1_max}
    Should be true    ${Gap2_min}<=${average_QCI7}-${average_QCI9}<=${Gap2_max}
    Should be true    ${Gap3_min}<=${average_QCI8}-${average_QCI9}<=${Gap3_max}
    Run keyword If    '${counter_value}'!='NULL'    Check D Counter
    ...    value_1=${counter_value}    value_Average=${0}    ue_index_UL=${ue_index_list_TL376}    dl_ports=${dl_ports}
    [Return]    ${index}

Check 1 NBR enter to congestion status
    power_ue.UE Detach    ue_type=${ue_type}    ue_index=${0}
    Adjust gNB_RU Attenuation    gnb1_cell1_value=${0}    enb_cell_value=${0}
    Attach and check power UE    ue_type=${ue_type}    4G_check=True
    #### maxNbrTrafficLimit=50, PA=26, has no NBR to congestion status
#    comment    *************Check has no NBR enter to congestion status with maxNbrTrafficLimit=50**************
#    ${index}    Check has no NBR enter to congestion status    PA=${44}    PA_NBR_Max=${48}
#    ...    min_5QI7=${150}    min_5QI8=${150}    min_5QI9=${80}
#    ...    max_5QI7=${160}    max_5QI8=${160}    max_5QI9=${145}
#    ...    Gap1_min=${0}    Gap2_min=${10}    Gap3_min=${10}    Gap1_max=${10}    Gap2_max=${70}    Gap3_max=${70}
    comment    *************Check 1 NBR enter to congestion and counter correct with maxNbrTrafficLimit=50**************
    FOR    ${index_i}    IN RANGE    ${42}    ${50}
        ${status}    Run keyword and return status    Check 1 NBR enter to congestion and counter correct    PA=${index_i}
        Exit For Loop If    '${status}'=='True'
    END
    Should be equal    ${status}    ${True}

Check 1 NBR enter to congestion and counter correct
    [Arguments]    ${PA}
    ${average_QCI7}    ${average_QCI8}    ${average_QCI9}    ${index}
    ...    Check NBR congestion NSA
    ...    file_name=${file_name_D01_1}    PA=${PA}    PA_NBR_Max=${${PA}+${1}}
    ...    min_5QI7=${50}    max_5QI7=${140}     min_5QI8=${140}    max_5QI8=${160}    min_5QI9=${50}    max_5QI9=${140}
    ${Gap1}    Evaluate    abs(${average_QCI7}-${average_QCI9})
    Should be true    ${0}<=${Gap1}<=${40}
    Should be true    ${10}<=${average_QCI8}-${average_QCI7}<=${100}
    Should be true    ${10}<=${average_QCI8}-${average_QCI9}<=${100}
    Check D Counter
    ...    value_1=${298}    value_Average=${0.9}    ue_index_UL=${ue_index_list_TL376}    dl_ports=${dl_ports}

Check 2 NBR enter to congestion status
    [Arguments]        ${PA}=${34}    ${PA_NBR_Max}=${${PA}+${3}}    ${min_5QI7}=${80}    ${min_5QI8}=${80}    ${min_5QI9}=${80}
    ...    ${max_5QI7}=${100}    ${max_5QI8}=${100}    ${max_5QI9}=${100}    ${Gap}=${5}    ${counter_value}=NULL
    ${average_QCI7}    ${average_QCI8}    ${average_QCI9}    ${index}
    ...    Check NBR congestion NSA
    ...    file_name=${file_name_D01_2}    PA=${PA}    PA_NBR_Max=${PA_NBR_Max}
    ...    min_5QI7=${min_5QI7}    max_5QI7=${max_5QI7}     min_5QI8=${min_5QI8}
    ...    max_5QI8=${max_5QI8}    min_5QI9=${min_5QI9}    max_5QI9=${max_5QI9}
    ${Gap1}    Evaluate    abs(${average_QCI8}-${average_QCI9})
    ${Gap2}    Evaluate    abs(${average_QCI7}-${average_QCI9})
    ${Gap3}    Evaluate    abs(${average_QCI7}-${average_QCI8})
    Should be true    ${0}<=${Gap1}<=${Gap}
    Should be true    ${0}<=${Gap2}<=${Gap}
    Should be true    ${0}<=${Gap3}<=${Gap}
    Run keyword If    '${counter_value}'!='NULL'    Check D Counter
    ...    value_1=${counter_value}    value_Average=${1.9}    ue_index_UL=${ue_index_list_TL376}    dl_ports=${dl_ports}
