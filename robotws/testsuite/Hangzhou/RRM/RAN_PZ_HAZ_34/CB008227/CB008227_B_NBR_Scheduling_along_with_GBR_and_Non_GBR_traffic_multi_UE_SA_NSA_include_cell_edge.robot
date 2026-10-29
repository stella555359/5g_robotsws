*** Settings ***
Resource    ./Resources/CB008227_common_keywords.robot
Variables    ./Resources/CB008227_Variables.py


Documentation
...   author: xiaodan.li
...   contact: xiaodan.li@nokia-sbell.com
...   squad group: SG_03
...   Feature CB008227-B

Suite Setup    Run Keywords
...            Common Suite Setup for COAM    AND
...            Common Case TestLine Setup for CB008227 B    AND
...            Adjust gNB_RU Attenuation for 2UEs on TL34411

Suite Teardown    Run Keywords
...               Run Keyword And Ignore Error     Common Suite Teardown for COAM    AND
...               Adjust gNB_RU Attenuation for 2UEs on TL34411

*** Variables ***
${golden_scf_name}    golden_TDD
${scf_path}    /opt/workspace/CRT/Master/SCF_file/
${dl_port_5QI9}    ${53344}
${dl_port_5QI7}    ${53345}
@{dl_ports}    ${dl_port_5QI9}    ${dl_port_5QI7}
${ul_port_5QI9}    ${53444}
${ul_port_5QI7}    ${53445}
@{ul_ports}    ${ul_port_5QI9}    ${ul_port_5QI7}
${dl_throughput}    800M
${ul_throughput}    80M
${file_name_B02_deactive}    8227_B02_deactive
${file_name_B02}    8227_B02
${file_name_B04}    8227_B04
@{ue_index_list}    ${0}    ${1}
@{ue_index_iperf}    ${-1}    ${-1}
@{allow_fault_list}    7523    7107

*** Test Cases ***
[1]CB008227_B02_B1_NBR_Scheduling_along_with_GBR_and_Non_GBR_traffic_multi_UE_SA_NSA_include_cell_edge_UL
    [Documentation]    This user scenario describes the gNB behaviour for Online modification Nominal Bit Rate parameters.
    [Setup]    robot_common_operations.Common Case Setup
    AlarmWatchdog.add_allow_alarms    fault_id=${allow_fault_list}
    AlarmWatchdog.add_allow_alarms    fault_id=8000
    Common Case TestLine Setup for CB008227 B02
    power_ue.Prepare UE     ue_type=${ue_type}
    Attach and check NBR NSA    file_name=${file_name_B02}
    [Teardown]    run keywords
    ...    Case recover for CB008227-B02    AND
    ...    Run Keyword And Ignore Error    Case Teardown    AND
    ...    Adjust gNB_RU Attenuation for 2UEs on TL34411

[1]CB008227_B04_B1_NBR_Scheduling_along_with_GBR_and_Non_GBR_traffic_multi_UE_SA_NSA_include_cell_edge
    [Documentation]    This user scenario describes the successful scheduling of NBR bearers along with GBR and non-GBR
    ...                bearers respecting each of their priorities and maximum usable resource limit.
    [Setup]    robot_common_operations.Common Case Setup
    AlarmWatchdog.add_allow_alarms    fault_id=${allow_fault_list}
    AlarmWatchdog.add_allow_alarms    fault_id=8000
    Run keyword If    '${release}'=='SBTS24R2_ENB_0'
    ...    Online modify NIDD on gnb    gnb_index=${0}    Modify_Para_Online=${Modify_Online_Para_SA_B04_24R2}
    ...    ELSE    Online modify NIDD on gnb    gnb_index=${0}    Modify_Para_Online=${Modify_Online_Para_SA_B04}
    power_ue.Prepare UE     ue_type=${ue_type}
    Attach and check NBR SA    file_name=${file_name_B04}
    [Teardown]    run keywords
    ...    Run Keyword And Ignore Error    Case Teardown    AND
    ...    Run Keyword And Ignore Error    Adjust gNB_RU Attenuation for 2UEs on TL34411


*** Keywords ***
Common Case TestLine Setup for CB008227 B02
    Run keyword If    '${release}'=='SBTS24R2_ENB_0'
    ...    Online modify NIDD on gnb    gnb_index=${0}    Modify_Para_Online=${ParamterToModify_CB008227_B02_24R2}
    ...    ELSE    Online modify NIDD on gnb    gnb_index=${0}    Modify_Para_Online=${ParamterToModify_CB008227_B02}
    Online modify nsaDrbParam to dlOverF1U    gnb_index=${0}

Common Case TestLine Setup for CB008227 B
    ${release}=    Get sagnb release title
    set suite variable    ${release}
    Common Case TestLine Setup    is_commission=True    golden_scf_name=${golden_scf_name}_${release}.xml    scf_path=${scf_path}
    Wait until keyword succeeds    20 min    20s
        ...    Check the cells status on air    bts_host=${bts_host0}   connection=gnb0

Case recover for CB008227-B02
    Online modify NIDD on gnb    gnb_index=${0}    Modify_Para_Online=${Modify_Para_AMF_Unlock}

check NBR bearer DL Tput
    [Arguments]    ${file_name}    ${ue_type}=${ue_type}
    Adjust gNB_RU Attenuation for 2UEs on TL34411    gnb1_cell1_value=${0}    enb_cell1_value=${0}
    2UEs attach and check     4G_check=True
    Wait until keyword succeeds    3X    5s    check Not Reach NBR with DL Tput    file_name=${file_name}
    Check NBR and get gap with bearer DL tput SA/NSA    file_name=${file_name}
    ...    5QI_7_min=${0}    5QI_7_max=${150}    5QI_9_min=${200}    5QI_9_max=${250}
    ...    PA_min=${40}    PA_max=${45}    Gap_min=${50}    Gap_max=${200}    enb_cell1_value=${0}
    Check NBR and get gap with bearer DL tput SA/NSA    file_name=${file_name}_edge
    ...    5QI_7_min=${0}    5QI_7_max=${30}    5QI_9_min=${100}    5QI_9_max=${250}
    ...    PA_min=${45}    PA_max=${50}    Gap_min=${70}    Gap_max=${220}    enb_cell1_value=${0}
    [Teardown]    Run keywords
    ...    power_ue.UE Detach    ue_type=${ue_type}    ue_index=${0}    AND
    ...    power_ue.UE Detach    ue_type=${ue_type}    ue_index=${1}

check Not Reach NBR with DL Tput
    [Arguments]    ${file_name}
    Start Traffic And Download the listened traffic    file_name_DL=${file_name}_DL_notNBR
    ...    dl_ports=${dl_ports}    dl_throughput=${dl_throughput}    ue_index_list=${ue_index_list}
    Check beare value should be true
    ...    file_name=${file_name}_DL_notNBR_${dl_port_5QI7}.txt    value_min=${300}    value_max=${450}
    Check beare value should be true
    ...    file_name=${file_name}_DL_notNBR_${dl_port_5QI9}.txt    value_min=${300}    value_max=${450}

check NBR bearer UL Tput
    [Arguments]    ${file_name}    ${ue_type}=${ue_type}    ${ul_ports}=${ul_ports}
    Adjust gNB_RU Attenuation for 2UEs on TL34411    gnb1_cell1_value=${0}    enb_cell1_value=${0}
    2UEs attach and check     4G_check=True
    Start Traffic And Download the listened traffic    file_name_UL=${file_name}_UL_notNBR
    ...    ul_ports=${ul_ports}    ul_throughput=${ul_throughput}    ue_index_list=${ue_index_list}
    Check beare value should be true
    ...    file_name=${file_name}_UL_notNBR_${ul_port_5QI7}.txt    value_min=${40}    value_max=${80}
    Check beare value should be true
    ...    file_name=${file_name}_UL_notNBR_${ul_port_5QI9}.txt    value_min=${40}    value_max=${80}
    Check NBR and get gap with bearer UL tput SA/NSA    file_name=${file_name}
    ...    5QI_7_min=${10}    5QI_7_max=${20}    5QI_9_min=${30}    5QI_9_max=${35}
    ...    PA_min=${32}    PA_max=${41}    Gap_min=${10}    Gap_max=${20}    enb_cell1_value=${0}
    Check NBR and get gap with bearer UL tput SA/NSA    file_name=${file_name}_edge
    ...    5QI_7_min=${1}    5QI_7_max=${5}    5QI_9_min=${10}    5QI_9_max=${15}
    ...    PA_min=${40}    PA_max=${51}    Gap_min=${5}    Gap_max=${15}    enb_cell1_value=${0}
    [Teardown]    Run keywords
    ...    power_ue.UE Detach    ue_type=${ue_type}    ue_index=${0}    AND
    ...    power_ue.UE Detach    ue_type=${ue_type}    ue_index=${1}

check NBR bearer DL Tput SA
    [Arguments]    ${file_name}    ${ue_type}=${ue_type}
    Adjust gNB_RU Attenuation for 2UEs on TL34411    gnb1_cell1_value=${0}
    Wait until keyword succeeds    3X    10s    Attach and check NBR DL OK    file_name=${file_name}
    Make a call on UE(dial +6688 on UE)    ue_index=${0}
    check voice call status    ue_index=${0}
    Check NBR and get gap with bearer DL tput SA/NSA    file_name=${file_name}
    ...    5QI_7_min=${1}    5QI_7_max=${150}    5QI_9_min=${200}    5QI_9_max=${250}
    ...    PA_min=${38}    PA_max=${42}    Gap_min=${50}    Gap_max=${200}    enb_cell1_value=${127}
    check voice call status    ue_index=${0}
    Check NBR and get gap with bearer DL tput SA/NSA    file_name=${file_name}_edge
    ...    5QI_7_min=${0}    5QI_7_max=${30}    5QI_9_min=${190}    5QI_9_max=${250}
    ...    PA_min=${43}    PA_max=${49}    Gap_min=${50}    Gap_max=${220}    enb_cell1_value=${127}
    check voice call status    ue_index=${0}
    [Teardown]    Run keywords    End a call on UE    ue_index=${0}    AND
    ...    power_ue.UE Detach    ue_type=${ue_type}    ue_index=${0}    AND
    ...    power_ue.UE Detach    ue_type=${ue_type}    ue_index=${1}

check NBR bearer UL Tput SA
    [Arguments]    ${file_name}    ${ue_type}=${ue_type}
    Adjust gNB_RU Attenuation for 2UEs on TL34411    gnb1_cell1_value=${8}
    Wait until keyword succeeds    3X    10s    Attach and check NBR UL OK    file_name=${file_name}
    Make a call on UE(dial +6688 on UE)    ue_index=${0}
    check voice call status    ue_index=${0}
    Check NBR and get gap with bearer UL tput SA/NSA    file_name=${file_name}
    ...    5QI_7_min=${5}    5QI_7_max=${18}    5QI_9_min=${30}    5QI_9_max=${35}
    ...    PA_min=${33}    PA_max=${39}    Gap_min=${12}    Gap_max=${30}    enb_cell1_value=${127}
    check voice call status    ue_index=${0}
    Check NBR and get gap with bearer UL tput SA/NSA    file_name=${file_name}_edge
    ...    5QI_7_min=${0}    5QI_7_max=${5}    5QI_9_min=${6}    5QI_9_max=${11}
    ...    PA_min=${45}    PA_max=${50}    Gap_min=${4}    Gap_max=${12}    enb_cell1_value=${127}
    check voice call status    ue_index=${0}
    [Teardown]    Run keywords    End a call on UE    ue_index=${0}    AND
    ...    power_ue.UE Detach    ue_type=${ue_type}    ue_index=${0}    AND
    ...    power_ue.UE Detach    ue_type=${ue_type}    ue_index=${1}

Check counter for B02
    sleep    40s
    ${counter_list}=    Get the PM counter
    ...    gnb_index=${0}    counter_id=${counter_id_B02_gNB1}
    ...    dic_path=${counter_dic_path_B02_gNB1}
    ${counter1_KPI}    Evaluate    ${counter_list[0]}/${counter_list[2]}
    ${counter2_KPI}    Evaluate    ${counter_list[1]}/${counter_list[2]}
    should be true    ${counter1_KPI}==1.0
    should be true    ${counter2_KPI}==1.0

Attach and check NBR SA
    [Arguments]    ${file_name}
    Wait until keyword succeeds    3X    10s    check NBR bearer DL Tput SA    file_name=${file_name}
    Wait until keyword succeeds    3X    10s    check NBR bearer UL Tput SA    file_name=${file_name}

Attach and check NBR NSA
    [Arguments]    ${file_name}
    Adjust gNB_RU Attenuation for 2UEs on TL34411    gnb1_cell1_value=${0}    enb_cell1_value=${0}
    Wait until keyword succeeds    3X    10s    Attach and check OK    4G_check=True
    Prepare to caculate PM counter    period=start
    Prepare to caculate PM counter    period=end
    Check counter for B02
    Wait until keyword succeeds    3X    10s    check NBR bearer DL Tput    file_name=${file_name}
    Wait until keyword succeeds    3X    10s    check NBR bearer UL Tput    file_name=${file_name}
    [Teardown]    Run keywords
    ...    power_ue.UE Detach    ue_type=${ue_type}    ue_index=${0}    AND
    ...    power_ue.UE Detach    ue_type=${ue_type}    ue_index=${1}

Attach and check OK
    [Arguments]    ${4G_check}=False
    power_ue.UE Detach    ue_type=${ue_type}    ue_index=${0}
    power_ue.UE Detach    ue_type=${ue_type}    ue_index=${1}
    2UEs attach and check     4G_check=${4G_check}

Attach and check NBR DL OK
    [Arguments]    ${file_name}
    Attach and check OK
    Check not NBR bearer DL tput SA    file_name=${file_name}

Attach and check NBR UL OK
    [Arguments]    ${file_name}
    Attach and check OK
    Start Traffic And Download the listened traffic    file_name_UL=${file_name}_UL_notNBR
    ...    ul_ports=${ul_ports}    ul_throughput=${ul_throughput}    ue_index_list=${ue_index_list}
    Check beare value should be true
    ...    file_name=${file_name}_UL_notNBR_${ul_port_5QI7}.txt    value_min=${45}    value_max=${90}
    Check beare value should be true
    ...    file_name=${file_name}_UL_notNBR_${ul_port_5QI9}.txt    value_min=${45}    value_max=${90}

Check not NBR bearer DL tput SA
    [Arguments]    ${file_name}
    Start Traffic And Download the listened traffic    file_name_DL=${file_name}_DL_notNBR
    ...    dl_ports=${dl_ports}    dl_throughput=${dl_throughput}    ue_index_list=${ue_index_list}
    Check beare value should be true
    ...    file_name=${file_name}_DL_notNBR_${dl_port_5QI7}.txt    value_min=${300}    value_max=${450}
    Check beare value should be true
    ...    file_name=${file_name}_DL_notNBR_${dl_port_5QI9}.txt    value_min=${300}    value_max=${450}

Check NBR and get gap with bearer DL tput SA/NSA
    [Arguments]    ${file_name}    ${5QI_7_min}=${1}    ${5QI_7_max}=${150}    ${5QI_9_min}=${200}    ${5QI_9_max}=${250}
    ...    ${PA_min}=${37}    ${PA_max}=${40}    ${Gap_min}=${50}    ${Gap_max}=${100}    ${enb_cell1_value}=${127}
    FOR    ${index}    IN RANGE    ${PA_min}    ${PA_max}
        Adjust gNB_RU Attenuation for 2UEs on TL34411    gnb1_cell1_value=${index}    enb_cell1_value=${enb_cell1_value}
        Start Traffic And Download the listened traffic    file_name_DL=${file_name}_DL_NBR
        ...    dl_ports=${dl_ports}    dl_throughput=${dl_throughput}    ue_index_list=${ue_index_list}
        ${status_1}    Run keyword and return status    Check beare value should be true
        ...    file_name=${file_name}_DL_NBR_${dl_port_5QI7}.txt    value_min=${5QI_7_min}    value_max=${5QI_7_max}
        ${status_2}    Run keyword and return status    Check beare value should be true
        ...    file_name=${file_name}_DL_NBR_${dl_port_5QI9}.txt    value_min=${5QI_9_min}    value_max=${5QI_9_max}
        Exit For Loop If    '${status_1}'=='True' and '${status_2}'=='True'
    END
    Should be equal    ${status_1}    ${True}
    Should be equal    ${status_2}    ${True}
    ${average_QCI7}    Check beare value should be true
        ...    file_name=${file_name}_DL_NBR_${dl_port_5QI7}.txt    value_min=${5QI_7_min}    value_max=${5QI_7_max}
    ${average_QCI9}    Check beare value should be true
        ...    file_name=${file_name}_DL_NBR_${dl_port_5QI9}.txt    value_min=${5QI_9_min}    value_max=${5QI_9_max}
    ${average_QCI7}    Convert To Integer    ${average_QCI7}
    ${average_QCI9}    Convert To Integer    ${average_QCI9}
    ${Gap1}    Evaluate    abs(${average_QCI9}-${average_QCI7})
    Should be true    ${Gap_min}<=${Gap1}<=${Gap_max}

Check NBR and get gap with bearer UL tput SA/NSA
    [Arguments]    ${file_name}    ${5QI_7_min}=${1}    ${5QI_7_max}=${150}    ${5QI_9_min}=${200}    ${5QI_9_max}=${250}
    ...    ${PA_min}=${37}    ${PA_max}=${40}    ${Gap_min}=${50}    ${Gap_max}=${100}    ${enb_cell1_value}=${127}
    FOR    ${index}    IN RANGE    ${PA_min}    ${PA_max}
        Adjust gNB_RU Attenuation for 2UEs on TL34411    gnb1_cell1_value=${index}    enb_cell1_value=${enb_cell1_value}
        Start Traffic And Download the listened traffic    file_name_UL=${file_name}_UL_NBR
        ...    ul_ports=${ul_ports}    ul_throughput=${ul_throughput}    ue_index_list=${ue_index_list}
        ${status_1}    Run keyword and return status    Check beare value should be true
        ...    file_name=${file_name}_UL_NBR_${ul_port_5QI7}.txt    value_min=${5QI_7_min}    value_max=${5QI_7_max}
        ${status_2}    Run keyword and return status    Check beare value should be true
        ...    file_name=${file_name}_UL_NBR_${ul_port_5QI9}.txt    value_min=${5QI_9_min}    value_max=${5QI_9_max}
        Exit For Loop If    '${status_1}'=='True' and '${status_2}'=='True'
    END
    Should be equal    ${status_1}    ${True}
    Should be equal    ${status_2}    ${True}
    ${average_QCI7}    Check beare value should be true
        ...    file_name=${file_name}_UL_NBR_${ul_port_5QI7}.txt    value_min=${5QI_7_min}    value_max=${5QI_7_max}
    ${average_QCI9}    Check beare value should be true
        ...    file_name=${file_name}_UL_NBR_${ul_port_5QI9}.txt    value_min=${5QI_9_min}    value_max=${5QI_9_max}
    ${average_QCI7}    Convert To Integer    ${average_QCI7}
    ${average_QCI9}    Convert To Integer    ${average_QCI9}
    ${Gap1}    Evaluate    abs(${average_QCI9}-${average_QCI7})
    Should be true    ${Gap_min}<=${Gap1}<=${Gap_max}