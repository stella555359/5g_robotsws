*** Settings ***
Resource    ./Resources/CB008227_common_keywords.robot
Variables    ./Resources/CB008227_Variables.py


Documentation
...   author: xiaodan.li
...   contact: xiaodan.li@nokia-sbell.com
...   squad group: SG_03
...   Feature CB008227-C

Suite Setup    Run Keywords
...    Common Suite Setup for COAM    AND
...    Common Case TestLine Setup for C    AND
...    Set APN point for sanmsungS22    AND
...    Precondition for Sansumg UE    ue_type=${ue_type}    ui_version=S21UI3.1    AND
...    Run keyword If    '${gnb_instance}'=='${gnb_id[0]}'
...    Set APN point for sanmsung until succeed    apn_name=${mdrb_apn_name}    enb_cell_value=${127}
...    ELSE    Set APN point for sanmsung22 until succeed    usedapn=${apn_muiltdrb}    enb_cell_value=${127}

Suite Teardown    Run Keywords
...    Run keyword If    '${gnb_instance}'=='${gnb_id[0]}'
...    Set APN point for sanmsung until succeed    apn_name=${dxdata2_apn_name}    enb_cell_value=${127}
...    ELSE    Set APN point for sanmsung22 until succeed    usedapn=${apn_dxdata}    enb_cell_value=${127}    AND
...    Common Suite Teardown for COAM   AND
...    Run Keyword And Ignore Error    COAM Teardown gnb connections

*** Variables ***
${golden_scf_name_gnb0}    7326_784_SCF
${golden_scf_name_gnb1}    7326_784_SCF_gnb2
${golden_scf_name_enb}    Configuration_scf_Enb.xml
${scf_path}    /opt/workspace/CRT/Master/SCF_file/
${epc_log_path}    /opt/workspace/CRT/Master/Case_Logs/
${ue_type}    ${tl.ues[0].capabilities[0]}
${mdrb_apn_name}    ${tl.ues[0].pdn[2]}
${dxdata2_apn_name}    ${tl.ues[0].pdn[0]}
${dl_throughput}    500M
${dl_port_5QI9_37611}    ${55379}
${dl_port_5QI8_37611}    ${55378}
${dl_port_5QI7_37611}    ${53376}
@{dl_ports_37611}    ${dl_port_5QI9_37611}    ${dl_port_5QI8_37611}    ${dl_port_5QI7_37611}
${dl_port_5QI9_38811}    ${55389}
${dl_port_5QI8_38811}    ${55388}
${dl_port_5QI7_38811}    ${53388}
@{dl_ports_38811}    ${dl_port_5QI9_38811}    ${dl_port_5QI8_38811}    ${dl_port_5QI7_38811}
@{gnb_list_C}    ${0}    ${1}
${file_name_C12_gnb1}    8227_C12_gNB1
${file_name_C12_gnb2}    8227_C12_gNB2
${file_name_C13_gnb1}    8227_C13_gNB1
${file_name_C13_gnb2}    8227_C13_gNB2
${log_name_C_012_1}    log_name_C_012_1.pcap
${log_name_C_012_2}    log_name_C_012_2.pcap
${log_name_C_013_1}    log_name_C_013_1.pcap
${log_name_C_013_2}    log_name_C_013_2.pcap
@{value_NSA_HO}    ${0}    ${1}    ${1}
@{ue_index_list_TL376}    ${0}    ${0}    ${0}
${gnb1_cell1_value_nNBR_37611}    ${16}
${gnb1_cell1_value_nNBR_38811}    ${20}
${NBR_PA_source_37611}    ${43}
${NBR_PA_source_38811}    ${46}
${NBR_PA_target_37611}    ${30}
${NBR_PA_target_38811}    ${18}
${gnb2_cell1_value_nNBR_37611}    ${13}
${gnb2_cell1_value_nNBR_38811}    ${0}
${3bearer_nNBR_min_37611}    ${300}
${3bearer_nNBR_min_38811}    ${200}
${3bearer_nNBR_max_37611}    ${450}
${3bearer_nNBR_max_38811}    ${300}

*** Test Cases ***
[1]CB008227_C03_B1_NBR_bearers_Exceed_Cell’s_NBR_max_amount_Limitation SA_HPA_scenario
    [Documentation]    This user scenario describes the gNB behaviour for Admission control of NBR Non GBR DRB when NBR
    ...    bearers Exceed Cell’s NBR max amount Limitation (SA) which is triggered by Initial Context Setup Request
    ...    procedure with HPA.
    [Setup]    robot_common_operations.Common Case Setup
    ###case setup
    Run keyword If    '${release}'=='SBTS24R2_ENB_0'
    ...    Online modify NIDD on gnb    gnb_index=${0}    Modify_Para_Online=${Modify_Online_Para_SA_C03_24R2}
    ...    ELSE    Online modify NIDD on gnb    gnb_index=${0}    Modify_Para_Online=${Modify_Online_Para_SA_C03}
    Adjust gNB_RU Attenuation    gnb1_cell1_value=${0}
    ###maxNumOfNbrBearers=0,actPriorityAccess=false
    Online modify para and check NBR max amount limitation    Modify_Para_Online=${Modify_Online_Para_SA_C03_1}
    ...    value1=${3}    value2=${0}    value3=${3}    value_NBR_KPI=${0.0}
    ###maxNumOfNbrBearers=1,actPriorityAccess=false
    Online modify para and check NBR max amount limitation    Modify_Para_Online=${Modify_Online_Para_SA_C03_2}
    ...    value1=${3}    value2=${1}    value3=${2}    value_NBR_KPI=${1.0}
    ###maxNumOfNbrBearers=1,actPriorityAccess=true
    Online modify para and check NBR max amount limitation    Modify_Para_Online=${Modify_Online_Para_SA_C03_3}
    ...    value1=${3}    value2=${2}    value3=${1}    value_NBR_KPI=${2.0}
    [Teardown]    run keywords
    ...    Online modify NIDD on gnb    gnb_index=${0}    Modify_Para_Online=${Modify_Online_Para_SA_C03_1}    AND
    ...    Case Teardown    AND
    ...    Run Keyword And Ignore Error    Adjust gNB_RU Attenuation

[1]CB008227_C12_B3_Not_Support_Nominal_Bit_Rate_of_nonGBR_bearers_for_Intra_frequency_Inter_gNB_handover_SA_NG_HO
    [Documentation]    This user scenario describes the gNB behaviour for not successful setup of Non GBR QoS Flow with
    ...    configured DL/UL Nominal Bit Rate in DRB profile which is triggered by Intra-frequency Inter-gNB handover
    ...    procedure (SA).
    [Setup]    robot_common_operations.Common Case Setup
    ###case setup
    Common Case TestLine Setup for CB008227 C12
    Adjust gNB_RU Attenuation    gnb1_cell1_value=${20}
    ###check source gNB NBR bearer
    Prepare to caculate PM counter    period=start
    Attach and check power UE    ue_type=${ue_type}    4G_check=False
    Check counter for C maxNumOfNbrBearers and NBR    value1=${2}    value2=${2}    value3=${0}
    ...    value_NBR_KPI=${2.0}
    check 2 NBR bearer Tput with gNB1    file_name=${file_name_C12_gnb1}    enb_cell_value=${127}
    ...    gnb1_cell1_value_nNBR=${gnb1_cell1_value_nNBR_${gnb_instance}}
    ...    NBR_PA=${NBR_PA_source_${gnb_instance}}    value_NBR_min=${150}    value_NBR_max=${165}
    ##trigger HO from gNB1 cell1 to gNB2 cell2, PA is cell1-1-23, cell2-2-13
    Prepare to caculate PM counter    period=start
    Start capture gNB log on master    filename=${log_name_C_012_1}    gNB_index=${0}
    Start capture gNB log on master    filename=${log_name_C_012_2}    gNB_index=${1}
    Run keyword If    '${gnb_instance}'=='${gnb_id[0]}'    Adjust gNB_RU Attenuation    gnb1_cell1_value=${43}    gnb2_cell1_value=${20}
    ...    ELSE    Adjust gNB_RU Attenuation    gnb1_cell1_value=${46}    gnb2_cell1_value=${0}
    sleep    5s
    Stop and download the Logs   filename=${log_name_C_012_1}    gNB_index=${0}
    Stop and download the Logs   filename=${log_name_C_012_2}    gNB_index=${1}
    ###check target gNB NBR bearer
    Check counter for C maxNumOfNbrBearers and NBR    value1=${2}    value2=${1}    value3=${1}
    ...    value_NBR_KPI=${1.0}    gnb_index=${1}
    ...    dic_path_maxNumOfNbrBearers=${counter_dic_path_C_gNB2_maxNumOfNbrBearers}
    ...    dic_path_NBR=${counter_dic_path_C_gNB2_NBR}
    check 1 NBR bearer Tput with gNB2    file_name=${file_name_C12_gnb2}    enb_cell_value=${127}
    ...    gnb2_cell1_value_nNBR=${gnb2_cell1_value_nNBR_${gnb_instance}}
    ...    3bearer_nNBR_min=${3bearer_nNBR_min_${gnb_instance}}    3bearer_nNBR_max=${3bearer_nNBR_max_${gnb_instance}}
    ...    NBR_PA=${NBR_PA_target_${gnb_instance}}
    Check counter for C about maxNumOfNbrBearers    value1=${0}    value2=${0}    value3=${0}    gnb_index=${0}
    Check counter for C NBR   value=${0.0}    gnb_index=${0}
    Check wireshark log for HO    logname1=${log_name_C_012_1}    logname2=${log_name_C_012_2}
    [Teardown]    run keywords
    ...    power_ue.UE Detach    ue_type=${ue_type}    ue_index=${0}    AND
    ...    Online modify NIDD on gnb    gnb_index=${1}    Modify_Para_Online=${Modify_Online_Para_SA_C12_recover}    AND
    ...    Case Teardown    AND
    ...    Run Keyword And Ignore Error    Adjust gNB_RU Attenuation

#[1]CB008227_C13_B6_Not_Support_Nominal_Bit_Rate_of_nonGBR_bearers_for_Inter_gNB_PSCell_change_procedure_NSA
#    [Documentation]    This user scenario describes the gNB behaviour for the successful setup of Non GBR bearer with
#    ...    configured DL/UL Nominal Bit Rate in DRB profile which is triggered by Inter-gNB PSCell change procedure (NSA).
#    [Setup]    robot_common_operations.Common Case Setup
#    ##case setup
#    Common Case TestLine Setup for CB008227 C13
#    Adjust gNB_RU Attenuation    gnb1_cell1_value=${0}    enb_cell_value=${0}
#    ###check source gNB NBR bearer
#    Wait until keyword succeeds    3X    10s    Attach and check mdrb NBR OK
#    ###trigger HO from gNB1 cell1 to gNB2 cell2, PA is cell1-1-23, cell2-2-13
#    Prepare to caculate PM counter    period=start
#    Adjust gNB_RU Attenuation    gnb1_cell1_value=${0}    enb_cell_value=${0}
#    Start capture gNB log on master    filename=${log_name_C_013_1}    gNB_index=${0}
#    Start capture gNB log on master    filename=${log_name_C_013_2}    gNB_index=${1}
#    Adjust gNB_RU Attenuation    gnb1_cell1_value=${45}    gnb2_cell1_value=${20}    enb_cell_value=${0}
#    sleep    5s
#    Stop and download the Logs   filename=${log_name_C_013_1}    gNB_index=${0}
#    Stop and download the Logs   filename=${log_name_C_013_2}    gNB_index=${1}
#    ###check target gNB NBR bearer
#    Check counter for C maxNumOfNbrBearers and NBR    value1=${2}    value2=${1}    value3=${1}    gnb_index=${1}
#    ...    value_NBR_KPI=${1.0}    counter_id_maxNumOfNbrBearers=${counter_id_C_gNB1_maxNumOfNbrBearers_NSA}
#    ...    dic_path_maxNumOfNbrBearers=${counter_dic_path_C_gNB2_maxNumOfNbrBearers_NSA}
#    ...    counter_id_NBR=${counter_id_B02_gNB1}    dic_path_NBR=${counter_dic_path_C13_gNB2}
#    check 1 NBR bearer Tput with gNB2    file_name=${file_name_C13_gnb2}    enb_cell_value=${0}    NBR_PA=${35}
#    Check counter for C about maxNumOfNbrBearers    value1=${0}
#    ...    value2=${0}    value3=${0}    gnb_index=${0}
#    ...    counter_id=${counter_id_C_gNB1_maxNumOfNbrBearers_NSA}    dic_path=${counter_dic_path_C_gNB1_maxNumOfNbrBearers_NSA}
#    Check counter for C NBR   value=${0.0}    gnb_index=${0}
#    ...    counter_id=${counter_id_B02_gNB1}    dic_path=${counter_dic_path_B02_gNB1}
#    Check counter for NSA HO
#    Check wireshark log for HO NSA    logname1=${log_name_C_013_1}    logname2=${log_name_C_013_2}
#    [Teardown]    run keywords
#    ...    power_ue.UE Detach    ue_type=${ue_type}    ue_index=${0}    AND
#    ...    Case Recover C13    AND
#    ...    Case Teardown    AND
#    ...    Run Keyword And Ignore Error    Adjust gNB_RU Attenuation

*** Keywords ***
Common Case TestLine Setup for C
    ${release}=    Get sagnb release title
    set suite variable    ${release}
    @{scf_list}    Create List    ${scf_path}${golden_scf_name_gnb0}_${release}.xml
    ${scf_gnb2}    Only Modify SCF before Perform Commission    gnb_index=${1}    scf_path=${scf_path}
    ...    golden_scf_name=${golden_scf_name_gnb1}_${release}.xml    ParamterToModify=${PARAMETERS_TO_MODIFY_GNB2_C}
    ...    ParameterToDelete=${Parameter_Delete_GNB2_C}    ListToAdd=${LIST_TO_ADD_GNB2_C}
    Append to List    ${scf_list}    ${scf_gnb2}
    Log to console    Start to modify scf files and commission, please wait...
    Multi-gNB commission    index_list=${gnb_list_C}    scf_list=${scf_list}
    Wait until keyword succeeds    20 min    20s
    ...    Check the cells status on air    bts_host=${bts_host0}   connection=gnb0
    Wait until keyword succeeds    20 min    20s
    ...    Check the cells status on air    bts_host=${bts_host1}   connection=gnb0

Common Case TestLine Setup for CB008227 C12
    Run keyword If    '${release}'=='SBTS24R2_ENB_0'
    ...    Online modify NIDD on gnb    gnb_index=${0}    Modify_Para_Online=${Modify_Online_Para_SA_C12_gnb1_24R2}
    ...    ELSE    Online modify NIDD on gnb    gnb_index=${0}    Modify_Para_Online=${Modify_Online_Para_SA_C12_gnb1}
    Run keyword If    '${release}'=='SBTS24R2_ENB_0'
    ...    Online modify NIDD on gnb    gnb_index=${1}    Modify_Para_Online=${Modify_Online_Para_SA_C12_gnb2_24R2}
    ...    ELSE    Online modify NIDD on gnb    gnb_index=${1}    Modify_Para_Online=${Modify_Online_Para_SA_C12_gnb2}

Common Case TestLine Setup for CB008227 C13
    Run keyword If    '${release}'=='SBTS24R2_ENB_0'
    ...    Online modify NIDD on gnb    gnb_index=${0}    Modify_Para_Online=${Modify_Online_Para_NSA_C13_gnb1_24R2}
    ...    ELSE    Online modify NIDD on gnb    gnb_index=${0}    Modify_Para_Online=${Modify_Online_Para_NSA_C13_gnb1}
    Online modify nsaDrbParam to dlOverF1U    gnb_index=${0}
    Run keyword If    '${release}'=='SBTS24R2_ENB_0'
    ...    Online modify NIDD on gnb    gnb_index=${1}    Modify_Para_Online=${Modify_Online_Para_NSA_C13_gnb2_24R2}
    ...    ELSE    Online modify NIDD on gnb    gnb_index=${1}    Modify_Para_Online=${Modify_Online_Para_NSA_C13_gnb2}
    Online modify nsaDrbParam to dlOverF1U    gnb_index=${1}
    #### open enb attach based B1
    Modify the enblte parameter    dist_name=MRBTS-${enb_instance}/LNBTS-${enb_instance}
    ...    parameter=actDynTrigLteNrDualConnectivity
    ...    value=true
    Modify the enblte parameter    dist_name=MRBTS-${enb_instance}/LNBTS-${enb_instance}
    ...    parameter=actB1ExtMeasNR
    ...    value=true


Case Recover C13
    Online modify NIDD on gnb    gnb_index=${0}    Modify_Para_Online=${Modify_Online_Para_NSA_C13_gnb1_recover}
    Online modify NIDD on gnb    gnb_index=${1}    Modify_Para_Online=${Modify_Online_Para_NSA_C13_gnb2_recover}
    #### recovery enb attach based B1
    Modify the enblte parameter    dist_name=MRBTS-${enb_instance}/LNBTS-${enb_instance}
    ...    parameter=actB1ExtMeasNR
    ...    value=false
    Modify the enblte parameter    dist_name=MRBTS-${enb_instance}/LNBTS-${enb_instance}
    ...    parameter=actDynTrigLteNrDualConnectivity
    ...    value=false

Check counter for C about maxNumOfNbrBearers
    [Arguments]    ${value1}    ${value2}    ${value3}    ${gnb_index}=${0}
    ...    ${counter_id}=${counter_id_C_gNB1_maxNumOfNbrBearers}    ${dic_path}=${counter_dic_path_C_gNB1_maxNumOfNbrBearers}
    ${counter_list}=    Get the PM counter
    ...    gnb_index=${gnb_index}    counter_id=${counter_id}    dic_path=${dic_path}
    Should be equal    ${counter_list[0]}    ${value1}
    Should be equal    ${counter_list[1]}    ${value2}
    Should be equal    ${counter_list[2]}    ${value3}

Check counter for C NBR
    [Arguments]    ${value}    ${gnb_index}=${0}
    ...    ${counter_id}=${counter_id_C_gNB1_NBR}    ${dic_path}=${counter_dic_path_C_gNB1_NBR}
    sleep    40s
    ${counter_list}=    Get the PM counter
    ...    gnb_index=${gnb_index}    counter_id=${counter_id}    dic_path=${dic_path}
    ${counter1_KPI}    Evaluate    ${counter_list[0]}/${counter_list[2]}
    ${counter2_KPI}    Evaluate    ${counter_list[1]}/${counter_list[2]}
    should be true    ${counter1_KPI}==${value}
    should be true    ${counter2_KPI}==${value}

Check counter for C maxNumOfNbrBearers and NBR
    [Arguments]    ${value1}    ${value2}    ${value3}    ${value_NBR_KPI}
    ...    ${gnb_index}=${0}    ${counter_id_maxNumOfNbrBearers}=${counter_id_C_gNB1_maxNumOfNbrBearers}
    ...    ${dic_path_maxNumOfNbrBearers}=${counter_dic_path_C_gNB1_maxNumOfNbrBearers}
    ...    ${counter_id_NBR}=${counter_id_C_gNB1_NBR}    ${dic_path_NBR}=${counter_dic_path_C_gNB1_NBR}
    Power UE Start DL traffic    dl_throughput=${dl_throughput}    duration=1200    dl_port=${dl_port_5QI9_${gnb_instance}}
    Power UE Start DL traffic    dl_throughput=${dl_throughput}    duration=1200    dl_port=${dl_port_5QI7_${gnb_instance}}
    Power UE Start DL traffic    dl_throughput=${dl_throughput}    duration=1200    dl_port=${dl_port_5QI8_${gnb_instance}}
    Wait until keyword succeeds    10 min    5s    Check counter for C about maxNumOfNbrBearers    value1=${value1}
    ...    value2=${value2}    value3=${value3}    gnb_index=${gnb_index}
    ...    counter_id=${counter_id_maxNumOfNbrBearers}    dic_path=${dic_path_maxNumOfNbrBearers}
    Prepare to caculate PM counter    period=end
    Wait until keyword succeeds    10 min    5s    Check counter for C NBR   value=${value_NBR_KPI}    gnb_index=${gnb_index}
    ...    counter_id=${counter_id_NBR}    dic_path=${dic_path_NBR}
    [Teardown]    Stop DL/UL traffic    ue_index_UL=${ue_index_list_TL376}
    ...    dl_ports=${dl_ports_${gnb_instance}}

Check counter for NSA HO
    Check the PM counter should be value    counter_id=${counter_id_NSA_HO}    dic_path=${dic_path_NSA_HO}
    ...    value=${value_NSA_HO}

Online modify para and check NBR max amount limitation
    [Arguments]    ${Modify_Para_Online}    ${value1}    ${value2}    ${value3}
    ...    ${value_NBR_KPI}
    Online modify NIDD on gnb    gnb_index=${0}    Modify_Para_Online=${Modify_Para_Online}
    Prepare to caculate PM counter    period=start
    Attach and check power UE    ue_type=${ue_type}
    Check counter for C maxNumOfNbrBearers and NBR    value1=${value1}    value2=${value2}
    ...    value3=${value3}    value_NBR_KPI=${value_NBR_KPI}
    [Teardown]    power_ue.UE Detach    ue_type=${ue_type}    ue_index=${0}

check 2 NBR bearer Tput with gNB1
    [Arguments]    ${file_name}    ${dl_ports}=${dl_ports_${gnb_instance}}    ${enb_cell_value}=${127}
    ...    ${NBR_PA}=${18}    ${value_NBR_min}=${250}    ${value_NBR_max}=${300}    ${ue_index_list}=${ue_index_list_TL376}
    ...    ${3bearer_nNBR_min}=${140}    ${3bearer_nNBR_max}=${210}    ${gnb1_cell1_value_nNBR}=${16}
    Adjust gNB_RU Attenuation    gnb1_cell1_value=${gnb1_cell1_value_nNBR}    enb_cell_value=${enb_cell_value}
    Start Traffic And Download the listened traffic    file_name_DL=${file_name}_DL_notNBR
    ...    dl_ports=${dl_ports}    dl_throughput=${dl_throughput}    ue_index_list=${ue_index_list}
    ...    ue_index_iperf=${ue_index_list}
    Check beare value should be true
    ...    file_name=${file_name}_DL_notNBR_${dl_port_5QI7_${gnb_instance}}.txt    value_min=${3bearer_nNBR_min}    value_max=${3bearer_nNBR_max}
    Check beare value should be true
    ...    file_name=${file_name}_DL_notNBR_${dl_port_5QI8_${gnb_instance}}.txt    value_min=${3bearer_nNBR_min}    value_max=${3bearer_nNBR_max}
    Check beare value should be true
    ...    file_name=${file_name}_DL_notNBR_${dl_port_5QI9_${gnb_instance}}.txt    value_min=${3bearer_nNBR_min}    value_max=${3bearer_nNBR_max}
    FOR    ${index}    IN RANGE    ${NBR_PA}    ${NBR_PA}+${10}
        Adjust gNB_RU Attenuation    gnb1_cell1_value=${index}    enb_cell_value=${enb_cell_value}
        Start Traffic And Download the listened traffic    file_name_DL=${file_name}_DL_NBR
        ...    dl_ports=${dl_ports}    dl_throughput=${dl_throughput}    ue_index_list=${ue_index_list}
         ...    ue_index_iperf=${ue_index_list}
        ${status_1}    Run keyword and return status    Check beare value should be true
        ...    file_name=${file_name}_DL_NBR_${dl_port_5QI7_${gnb_instance}}.txt    value_min=${value_NBR_min}    value_max=${value_NBR_max}
        ${status_2}    Run keyword and return status    Check beare value should be true
        ...    file_name=${file_name}_DL_NBR_${dl_port_5QI8_${gnb_instance}}.txt    value_min=${30}    value_max=${110}
        ${status_3}    Run keyword and return status    Check beare value should be true
        ...    file_name=${file_name}_DL_NBR_${dl_port_5QI9_${gnb_instance}}.txt    value_min=${value_NBR_min}    value_max=${value_NBR_max}
        Exit For Loop If    '${status_1}'=='True' and '${status_2}'=='True' and '${status_3}'=='True'
    END
    Should be true    '${status_1}'=='True' and '${status_2}'=='True' and '${status_3}'=='True'

check 1 NBR bearer Tput with gNB2
    [Arguments]    ${file_name}    ${dl_ports}=${dl_ports_${gnb_instance}}
    ...    ${enb_cell_value}=${127}    ${NBR_PA}=${30}    ${nGBR_min}=${100}    ${nGBR_max}=${130}
    ...    ${NBR_min}=${150}    ${NBR_max}=${160}    ${3bearer_nNBR_min}=${300}    ${3bearer_nNBR_max}=${450}
    ...    ${ue_index_list}=${ue_index_list_TL376}    ${gnb2_cell1_value_nNBR}=${13}
    Adjust gNB_RU Attenuation    gnb2_cell1_value=${gnb2_cell1_value_nNBR}    enb_cell_value=${enb_cell_value}
    Start Traffic And Download the listened traffic    file_name_DL=${file_name}_DL_notNBR
    ...    dl_ports=${dl_ports}    dl_throughput=${dl_throughput}    ue_index_list=${ue_index_list}
    ...    ue_index_iperf=${ue_index_list}
    Check beare value should be true
    ...    file_name=${file_name}_DL_notNBR_${dl_port_5QI7_${gnb_instance}}.txt    value_min=${3bearer_nNBR_min}    value_max=${3bearer_nNBR_max}
    Check beare value should be true
    ...    file_name=${file_name}_DL_notNBR_${dl_port_5QI8_${gnb_instance}}.txt    value_min=${3bearer_nNBR_min}    value_max=${3bearer_nNBR_max}
    Check beare value should be true
    ...    file_name=${file_name}_DL_notNBR_${dl_port_5QI9_${gnb_instance}}.txt    value_min=${3bearer_nNBR_min}    value_max=${3bearer_nNBR_max}
    FOR    ${index}    IN RANGE    ${NBR_PA}    ${NBR_PA}+${5}
        Adjust gNB_RU Attenuation    gnb2_cell1_value=${index}    enb_cell_value=${enb_cell_value}
        Start Traffic And Download the listened traffic    file_name_DL=${file_name}_DL_NBR
        ...    dl_ports=${dl_ports}    dl_throughput=${dl_throughput}    ue_index_list=${ue_index_list}
        ...    ue_index_iperf=${ue_index_list}
        ${status_1}    Run keyword and return status    Check beare value should be true
        ...    file_name=${file_name}_DL_NBR_${dl_port_5QI9_${gnb_instance}}.txt    value_min=${nGBR_min}    value_max=${nGBR_max}
        ${status_2}    Run keyword and return status    Check beare value should be true
        ...    file_name=${file_name}_DL_NBR_${dl_port_5QI8_${gnb_instance}}.txt    value_min=${nGBR_min}    value_max=${nGBR_max}
        ${status_3}    Run keyword and return status    Check beare value should be true
        ...    file_name=${file_name}_DL_NBR_${dl_port_5QI7_${gnb_instance}}.txt    value_min=${NBR_min}    value_max=${NBR_max}
        Exit For Loop If    '${status_1}'=='True' and '${status_2}'=='True' and '${status_3}'=='True'
    END
    Should be true    '${status_1}'=='True' and '${status_2}'=='True' and '${status_3}'=='True'

Check wireshark log for HO
    [Arguments]    ${logname1}    ${logname2}
    Check intergNB HO process on source gNB    logname=${logname1}    asik_addr=${asik_addr}
    Check intergNB HO process on target gNB    logname=${logname2}    asik_addr=${asik_addr}    asik2_addr=${asik2_addr}

Check wireshark log for HO NSA
    [Arguments]    ${logname1}    ${logname2}
    Check intergNB HO NSA process on source gNB    logname=${logname1}    asik_addr=${asik_addr}
    Check intergNB HO NSA process on target gNB    logname=${logname2}    asik_addr=${asik2_addr}

Attach and check mdrb NBR OK
    Prepare to caculate PM counter    period=start
    Attach and check power UE    ue_type=${ue_type}    4G_check=True
    Check counter for C maxNumOfNbrBearers and NBR    value1=${2}    value2=${2}    value3=${0}
    ...    value_NBR_KPI=${2.0}    counter_id_maxNumOfNbrBearers=${counter_id_C_gNB1_maxNumOfNbrBearers_NSA}
    ...    dic_path_maxNumOfNbrBearers=${counter_dic_path_C_gNB1_maxNumOfNbrBearers_NSA}
    ...    counter_id_NBR=${counter_id_B02_gNB1}    dic_path_NBR=${counter_dic_path_B02_gNB1}
    check 2 NBR bearer Tput with gNB1    file_name=${file_name_C13_gnb1}    enb_cell_value=${0}
    ...    NBR_PA=${18}    value_NBR_min=${150}    value_NBR_max=${160}