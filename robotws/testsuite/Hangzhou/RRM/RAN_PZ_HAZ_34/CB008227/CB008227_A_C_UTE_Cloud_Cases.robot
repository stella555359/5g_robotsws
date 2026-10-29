*** Settings ***
Documentation     author: yifan hu
...                 contact: yifan.hu@nokia-sbell.com
...                 squad group: SG_03
...                 feature : CB007326

Force Tags    5G_SISO    RAN_5G    RAN_5G_TDD
...    PY36
...    CRT_UTE    STATE_SW_UPLOADED    CLOUD_5G_CLASSICAL_ANDROID_ASIKL_ABILB1_AWHHI_ENB    SBTS00    5G_RAN_TDD

Resource    ./Resources/CB008227_common_keywords.robot
Variables    ./Resources/CB008227_Variables_TL356.py


Suite Setup    Run Keywords
...    robot_common_operations.Common Suite Setup    AND
...    CI_interface.Common Suite Setup    AND
...    Pre Condition    AND
...    Common Case TestLine Setup for A    AND
...    Adjust gNB_RU Attenuation TL356    AND
...    Get gnb release info

Suite Teardown    Run Keywords
...               robot_common_operations.Common Suite Teardown    AND
...               Adjust gNB_RU Attenuation TL356    gnb1_cell1_value=${0}    enb_cell_value=${0}    AND
...               Run Keyword If Any Tests Failed
...               Run Keyword And Ignore Error    Common Suite Teardown for COAM   AND
...               Run Keyword And Ignore Error    COAM Teardown gnb connections

*** Variables ***
${golden_scf_name_gnb0}    Full_Configuration_SCF_1881_886_7657
${ue_type}    ${tl.ues[0].capabilities[0]}
${mdrb_apn_name}    ${tl.ues[0].pdn[2]}
${dxdata2_apn_name}    ${tl.ues[0].pdn[0]}
${dl_throughput}    500M
${dl_port_5QI7}    ${53356}
${dl_port_5QI8}    ${55568}
${dl_port_5QI9}    ${55569}
@{dl_ports}    ${dl_port_5QI7}    ${dl_port_5QI9}
@{dl_ports_C}    ${dl_port_5QI7}    ${dl_port_5QI8}    ${dl_port_5QI9}
${file_name_A11}    8227_A11
${file_name_E01}    8227_E01
${file_name_EA01}    8227_EA01
@{ue_index_list_TL356}    ${0}    ${0}    ${0}
${file_name_D01}    8227_D01_DL_not_congestion_50
${file_name_D01_1}    8227_D01_DL_congestion_50_1
${file_name_D01_2}    8227_D01_DL_congestion_50_2
${file_name_D01_3}    8227_D01_DL_not_congestion_90
${file_name_D01_4}    8227_D01_DL_congestion_0
${file_name_D01_5}    8227_D01_DL_recovery_not_congestion_90

*** Test Cases ***
[1]CB008227_A11_B5_Online_modification_Nominal_Bit_Rate_parameters_SA_NSA
    [Documentation]    This user scenario describes the gNB behaviour for Online modification Nominal Bit Rate parameters.
    [Setup]
    robot_common_operations.Common Case Setup    allowed_faults_ids=7107,7523,4681
    AlarmWatchdog.add_allow_alarms    fault_id=${allow_fault_list}
    Precondition for Sansumg UE    ue_type=${ue_type}    ui_version=S21UI3.1
    Andriod UE adb reboot    ue_index=${0}
    Set APN point for sanmsungS22 TL356
    Adjust gNB_RU Attenuation TL356    gnb1_cell1_value=${0}    enb_cell_value=${0}
    Set APN point for sanmsung until succeed     usedapn=${apn_muiltdrb}    location_apn=${location_apn}
    ${PA_value}    Wait until keyword succeeds    3X    10s    Attach and check NBR NSA    file_name=${file_name_A11}
    ${TPUT_SUM_AVE_A01}    TPUT SUM average evaluate    file_name=${file_name_A11}
    #Add check 8227_E01
#    Online modify NIDD on gnb    gnb_index=${0}   Modify_Para_Online=${PARAMETERS_TO_ONLINE_MODIFY_GNB1_E01}
    Online modify parmeters    gnb_index=${0}    parameters_to_update=${PARAMETERS_TO_ONLINE_MODIFY_GNB1_E01}    skip_parameter_relation_errors=False
    Wait until keyword succeeds    3X    10s    Check NBR bearer take effect    NBR_value_max=${160}    NBR_value_min=${150}
    ...    noGBR_value_max=${100}    noGBR_value_min=${70}    value=${PA_value}    file_name=${file_name_E01}
    ${TPUT_SUM_AVE_E01}    TPUT SUM average evaluate    file_name=${file_name_E01}
    ${rate}    Evaluate    ${TPUT_SUM_AVE_E01}/${TPUT_SUM_AVE_A01}
    Should be true    ${0.588} < ${rate} < ${0.7}
    ##Add check 8227_EA01
#    Online modify NIDD on gnb    gnb_index=${0}   Modify_Para_Online=${PARAMETERS_TO_ONLINE_MODIFY_GNB1_EA01}
    Online modify parmeters    gnb_index=${0}    parameters_to_update=${PARAMETERS_TO_ONLINE_MODIFY_GNB1_EA01}    skip_parameter_relation_errors=False
    Check slice NBR congestion NSA EA01    file_name=${file_name_EA01}    PA=${PA_value}
    [Teardown]    run keywords
    ...    Set APN point for sanmsung until succeed     usedapn=${apn_wap2}    location_apn=${location_apn}    AND
    ...    Online modify NIDD on gnb    gnb_index=${0}    Modify_Para_Online=${PARAMETERS_TO_ONLINE_RECOVER_GNB1_A11}    AND
    ...    Case Teardown    AND
    ...    Adjust gNB_RU Attenuation TL356

#[1]CB008227_D01_B1_PDSCH_NBR_congestion_detection_and_handling_NSA
#    [Documentation]    This user scenario describes the gNB behavior related to NBR bearers congestion detection
#    ...                and congestion handling.
#    [Setup]
#    robot_common_operations.Common Case Setup    allowed_faults_ids=7107,7523,4681
#    AlarmWatchdog.add_allow_alarms    fault_id=${allow_fault_list}
#    Online modify NIDD on gnb    gnb_index=${0}    Modify_Para_Online=${Modify_Para_Online_D01}
#    ...    Delete_Para_Online=${ParameterToDelete_D01}
#    Precondition for Sansumg UE    ue_type=${ue_type}    ui_version=S21UI3.1
#    Set APN point for sanmsungS22 TL356
#    Adjust gNB_RU Attenuation TL356    gnb1_cell1_value=${0}    enb_cell_value=${0}
#    Set APN point for sanmsung until succeed     usedapn=${apn_muiltdrb}    location_apn=${location_apn}
#    #### maxNbrTrafficLimit=50, PA=28, has QCI9 NBR to congestion status
#    Wait until keyword succeeds    3X    10s    Check 1 NBR enter to congestion status
#    ### maxNbrTrafficLimit=50, PA=34, has NBR QCI9 and QCI7 all change to congestion status
#    Wait until keyword succeeds    3X    10s    Check 2 NBR enter to congestion status    PA=${40}
#    ...    min_5QI7=${50}    min_5QI8=${50}    min_5QI9=${50}
#    ...    max_5QI7=${90}    max_5QI8=${90}    max_5QI9=${90}
#    ### maxNbrTrafficLimit=90, PA=28, has no NBR to congestion status
#    Run Keyword if    '${release_info}' == '${branch}[1]'
#    ...    Online modify NIDD on gnb    gnb_index=${0}    Modify_Para_Online=${Modify_Para_Online_D01_1}
#    ...    ELSE    Online modify NIDD on gnb    gnb_index=${0}    Modify_Para_Online=${Modify_Para_Online_D01_and_DA}
#    ${index}    Check has no NBR enter to congestion status    PA=${30}    PA_NBR_Max=${34}
#    ...    min_5QI7=${150}    min_5QI8=${150}    min_5QI9=${40}
#    ...    max_5QI7=${160}    max_5QI8=${160}    max_5QI9=${100}
#    ...    Gap1_min=${0}    Gap2_min=${60}    Gap3_min=${60}    Gap1_max=${10}    Gap2_max=${120}    Gap3_max=${120}
#    ...    counter_value=${0}
#    #### maxNbrTrafficLimit=0, PA=28, has NBR QCI9 and QCI7 all change to congestion status
#    Online modify NIDD on gnb    gnb_index=${0}    Modify_Para_Online=${Modify_Para_Online_D01_2}
#    Wait until keyword succeeds    3X    10s    Check 2 NBR enter to congestion status    PA=${index}
#    ...    min_5QI7=${110}    min_5QI8=${110}    min_5QI9=${110}
#    ...    max_5QI7=${135}    max_5QI8=${135}    max_5QI9=${135}    Gap=${10}
#    #### maxNbrTrafficLimit=90, PA=28, has non-gBR recovery to NBR
#    Online modify NIDD on gnb    gnb_index=${0}    Modify_Para_Online=${Modify_Para_Online_D01_1}
#    Check has no NBR enter to congestion status    PA=${index}
#    ...    min_5QI7=${150}    min_5QI8=${150}    min_5QI9=${40}
#    ...    max_5QI7=${160}    max_5QI8=${160}    max_5QI9=${100}
#    ...    Gap1_min=${0}    Gap2_min=${60}    Gap3_min=${60}    Gap1_max=${10}    Gap2_max=${120}    Gap3_max=${120}
#    ### maxNbrTrafficLimit=10, PA=28, has NBR to pdcch congestion status
#    Run Keyword if    '${release_info}' != '${branch}[1]'    Run keywords
#    ...    Online modify NIDD on gnb    gnb_index=${0}    Modify_Para_Online=${Modify_Para_Online_DA}    AND
#    ...    Wait until keyword succeeds    3X    10s
#    ...    Check DA Counter for DL    value_1=${10}    ue_index_UL=${ue_index_list_TL356}    dl_ports=${dl_ports_C}
#    ...    PA=${index}
#    [Teardown]    run keywords
#    ...    Set APN point for sanmsung until succeed     usedapn=${apn_wap2}    location_apn=${location_apn}    AND
#    ...    Online modify NIDD on gnb    gnb_index=${0}    Modify_Para_Online=${Modify_Para_Online_D01_Restore}    AND
#    ...    Case Teardown    AND
#    ...    Adjust gNB_RU Attenuation TL356
#
#[1]CB008227_C03_B1_NBR_bearers_Exceed_Cell’s_NBR_max_amount_Limitation SA_HPA_scenario
#    [Documentation]    This user scenario describes the gNB behaviour for Admission control of NBR Non GBR DRB when NBR
#    ...    bearers Exceed Cell’s NBR max amount Limitation (SA) which is triggered by Initial Context Setup Request
#    ...    procedure with HPA.
#    [Setup]
#    robot_common_operations.Common Case Setup    allowed_faults_ids=7107,7523,4681
#    AlarmWatchdog.add_allow_alarms    fault_id=${allow_fault_list}
#    ##case setup
#    Online modify NIDD on gnb    gnb_index=${0}    Modify_Para_Online=${Modify_Online_Para_SA_C03}
#    Precondition for Sansumg UE    ue_type=${ue_type}    ui_version=S21UI3.1
#    Set APN point for sanmsungS22 TL356
#    Adjust gNB_RU Attenuation TL356    gnb1_cell1_value=${0}
#    Set APN point for sanmsung until succeed     usedapn=${apn_muiltdrb}    location_apn=${location_apn}
#    ##maxNumOfNbrBearers=0,actPriorityAccess=false
#    Online modify para and check NBR max amount limitation    Modify_Para_Online=${Modify_Online_Para_SA_C03_1}
#    ...    value1=${3}    value2=${0}    value3=${3}    value_NBR_KPI=${0.0}
#    ##maxNumOfNbrBearers=1,actPriorityAccess=false
#    Online modify para and check NBR max amount limitation    Modify_Para_Online=${Modify_Online_Para_SA_C03_2}
#    ...    value1=${3}    value2=${1}    value3=${2}    value_NBR_KPI=${1.0}
#    ###maxNumOfNbrBearers=1,actPriorityAccess=true
#    Online modify para and check NBR max amount limitation    Modify_Para_Online=${Modify_Online_Para_SA_C03_3}
#    ...    value1=${3}    value2=${2}    value3=${1}    value_NBR_KPI=${2.0}
#    [Teardown]    run keywords
#    ...    Set APN point for sanmsung until succeed     usedapn=${apn_wap2}    location_apn=${location_apn}    AND
#    ...    Online modify NIDD on gnb    gnb_index=${0}    Modify_Para_Online=${Modify_Online_Para_SA_C03_1}    AND
#    ...    Case Teardown    AND
#    ...    Adjust gNB_RU Attenuation TL356

*** Keywords ***
Common Case TestLine Setup for A
    ${release_info}    Get sagnb release title
    Common Case TestLine Setup with singe BTS    gnb_index=${0}
    ...    ModifySCF_Beforecommission=True    golden_scf_name=${golden_scf_name_gnb0}_${release_info}.xml
    ...    scf_path=${tl_scf_dir_path}    ParamterToModify=${ParamterToModify_A}
    Wait until keyword succeeds    20 min    20s
    ...    Check the cells status on air    bts_host=${bts_host0}   connection=gnb0
    Online modify NIDD on gnb
    ...    gnb_index=${0}    Modify_Para_Online=${PARAMETERS_TO_ONLINE_MODIFY_GNB1_A11}
    Online modify nsaDrbParam to dlOverF1U    gnb_index=${0}

check NBR bearer Tput
    [Arguments]    ${file_name}    ${dl_ports}=${dl_ports}
    FOR    ${index}    IN RANGE    ${27}    ${36}
        Adjust gNB_RU Attenuation TL356    gnb1_cell1_value=${index}    enb_cell_value=${0}
        Comment    sleep 20 keep traffic stability
        Sleep    10s
        Start Traffic And Download the listened traffic    file_name_DL=${file_name}_DL_NBR
        ...    dl_ports=${dl_ports}    dl_throughput=${dl_throughput}
        ${status_1}    Run keyword and return status    Check beare value should be true
        ...    file_name=${file_name}_DL_NBR_${dl_port_5QI7}.txt    value_min=${110}    value_max=${135}
        ${status_2}    Run keyword and return status    Check beare value should be true
        ...    file_name=${file_name}_DL_NBR_${dl_port_5QI9}.txt    value_min=${250}    value_max=${260}
        Exit For Loop If    '${status_1}'=='True' and '${status_2}'=='True'
    END
    Should be equal    ${status_1}    ${True}
    Should be equal    ${status_2}    ${True}
    [Return]    ${index}

Attach and check NBR NSA
    [Arguments]    ${file_name}    ${ue_type}=${ue_type}    ${dl_ports}=${dl_ports}
    Adjust gNB_RU Attenuation TL356    gnb1_cell1_value=${0}    enb_cell_value=${0}
    Attach and check power UE    ue_type=${ue_type}    4G_check=True
    Adjust gNB_RU Attenuation TL356    gnb1_cell1_value=${20}    enb_cell_value=${0}
    Start Traffic And Download the listened traffic    file_name_DL=${file_name}_DL_notNBR
    ...    dl_ports=${dl_ports}    dl_throughput=${dl_throughput}
    Comment    sleep 20 keep traffic stability
    Sleep    20s
    Check beare value should be true
    ...    file_name=${file_name}_DL_notNBR_${dl_port_5QI7}.txt    value_min=${250}    value_max=${320}
    Check beare value should be true
    ...    file_name=${file_name}_DL_notNBR_${dl_port_5QI9}.txt    value_min=${250}    value_max=${320}
    ${PA_value}    Wait until keyword succeeds    3X    10s    check NBR bearer Tput    file_name=${file_name}
    ...    dl_ports=${dl_ports}
    [Return]    ${PA_value}
    [Teardown]    power_ue.UE Detach    ue_type=${ue_type}    ue_index=${0}

Check NBR bearer take effect
    [Arguments]    ${file_name}    ${NBR_value_max}=${65}    ${NBR_value_min}=${55}    ${noGBR_value_min}=${0}
    ...     ${noGBR_value_max}=${50}    ${value}=${38}
    Adjust gNB_RU Attenuation TL356    gnb1_cell1_value=${value}    enb_cell_value=${0}
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
    ...    min_5QI7=${70}    max_5QI7=${110}     min_5QI9=${70}    max_5QI9=${110}
    ${Gap1}    Evaluate    abs(${average_QCI7}-${average_QCI9})
    Should be true    ${0}<=${Gap1}<=${5}
    Wait until keyword succeeds    3X    10s    Check D Counter    value_1=${299}    value_min=${0.966666667}    value_max=${1.034}
    ...    dl_ports=${dl_ports}    ue_index_UL=${ue_index_list}

Check NBR congestion NSA
     [Arguments]    ${file_name}    ${min_5QI7}   ${min_5QI9}    ${max_5QI7}    ${max_5QI9}
    ...    ${PA}=${28}    ${PA_NBR_Max}=${${PA}+${10}}
    Comment    this ${PA} value maybe not trigger NBR congestion, so ${PA_NBR_Max}=${${PA}+${10}}
    Attach and check power UE    ue_type=${ue_type}    4G_check=True
    FOR    ${index}    IN RANGE    ${PA}    ${PA_NBR_Max}
         Adjust gNB_RU Attenuation TL356    gnb1_cell1_value=${index}    enb_cell_value=${0}
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
    [Arguments]    ${value_1}    ${value_Average}=${1}    ${value_min}=${0.966666667}    ${value_max}=${1.034}
    ...    ${counter_id}=${counter_id_D01_gNB1}    ${counter_dic_path}=${counter_dic_path_D01_gNB1}
    ...    ${ue_index_DL}=NULL    ${ue_index_UL}=NULL    ${dl_ports}=NULL    ${ul_ports}=NULL
    Power UE Start DL traffic    dl_throughput=${dl_throughput}    duration=1200    dl_port=${dl_port_5QI9}
    Power UE Start DL traffic    dl_throughput=${dl_throughput}    duration=1200    dl_port=${dl_port_5QI7}
    Prepare to caculate PM counter    period=start
    comment    check the NBR_congestion counter
    Prepare to caculate PM counter    period=end
    ###20250627    set a special keyword to check ER01 counter
    Check NBR Congetion Counter for A11B05_EA01    value_1=${value_1}    value_Average=${value_Average}    value_min=${value_min}
    ...    value_max=${value_max}    counter_id=${counter_id}    counter_dic_path=${counter_dic_path}
    [Teardown]    Stop DL/UL traffic    ue_index_DL=${ue_index_DL}    ue_index_UL=${ue_index_UL}
    ...    dl_ports=${dl_ports}    ul_ports=${ul_ports}

Check D Counter 3port
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

Online modify para and check NBR max amount limitation
    [Arguments]    ${Modify_Para_Online}    ${value1}    ${value2}    ${value3}
    ...    ${value_NBR_KPI}
    Online modify NIDD on gnb    gnb_index=${0}    Modify_Para_Online=${Modify_Para_Online}
    Prepare to caculate PM counter    period=start
    Attach and check power UE    ue_type=${ue_type}
    Check counter for C maxNumOfNbrBearers and NBR    value1=${value1}    value2=${value2}
    ...    value3=${value3}    value_NBR_KPI=${value_NBR_KPI}
    [Teardown]    power_ue.UE Detach    ue_type=${ue_type}    ue_index=${0}

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
    Power UE Start DL traffic    dl_throughput=${dl_throughput}    duration=2400    dl_port=${dl_port_5QI9}
    Power UE Start DL traffic    dl_throughput=${dl_throughput}    duration=2400    dl_port=${dl_port_5QI7}
    Power UE Start DL traffic    dl_throughput=${dl_throughput}    duration=2400    dl_port=${dl_port_5QI8}
    Wait until keyword succeeds    10 min    5s    Check counter for C about maxNumOfNbrBearers    value1=${value1}
    ...    value2=${value2}    value3=${value3}    gnb_index=${gnb_index}
    ...    counter_id=${counter_id_maxNumOfNbrBearers}    dic_path=${dic_path_maxNumOfNbrBearers}
    Prepare to caculate PM counter    period=end
    Wait until keyword succeeds    10 min    5s    Check counter for C NBR   value=${value_NBR_KPI}    gnb_index=${gnb_index}
    ...    counter_id=${counter_id_NBR}    dic_path=${dic_path_NBR}
    [Teardown]    Stop DL/UL traffic    ue_index_UL=${ue_index_list_TL356}
    ...    dl_ports=${dl_ports_C}

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
    ...    Wait until keyword succeeds    3X    10s    Check NBR congestion NSA D
    ...    file_name=${file_name_D01}    PA=${PA}    PA_NBR_Max=${PA_NBR_Max}    min_5QI7=${min_5QI7}    max_5QI7=${max_5QI7}
    ...    min_5QI8=${min_5QI8}    max_5QI8=${max_5QI8}    min_5QI9=${min_5QI9}    max_5QI9=${max_5QI9}
    ${Gap1}    Evaluate    abs(${average_QCI7}-${average_QCI8})
    Should be true    ${Gap1_min}<=${Gap1}<=${Gap1_max}
    Should be true    ${Gap2_min}<=${average_QCI7}-${average_QCI9}<=${Gap2_max}
    Should be true    ${Gap3_min}<=${average_QCI8}-${average_QCI9}<=${Gap3_max}
    Run keyword If    '${counter_value}'!='NULL'    Check D Counter 3port
    ...    value_1=${counter_value}    value_Average=${0}    ue_index_UL=${ue_index_list_TL356}    dl_ports=${dl_ports_C}
    [Return]    ${index}

Check 1 NBR enter to congestion status
    power_ue.UE Detach    ue_type=${ue_type}    ue_index=${0}
    Adjust gNB_RU Attenuation TL356    gnb1_cell1_value=${0}    enb_cell_value=${0}
    Attach and check power UE    ue_type=${ue_type}    4G_check=True
    #### maxNbrTrafficLimit=50, PA=29, has no NBR to congestion status
    Check has no NBR enter to congestion status    PA=${28}    PA_NBR_Max=${32}
    ...    min_5QI7=${150}    min_5QI8=${150}    min_5QI9=${90}
    ...    max_5QI7=${160}    max_5QI8=${160}    max_5QI9=${140}
    ...    Gap1_min=${0}    Gap2_min=${15}    Gap3_min=${15}    Gap1_max=${10}    Gap2_max=${80}    Gap3_max=${80}
    ${average_QCI7}    ${average_QCI8}    ${average_QCI9}    ${index}
    ...    Check NBR congestion NSA D
    ...    file_name=${file_name_D01_1}    PA=${33}    PA_NBR_Max=${39}
    ...    min_5QI7=${150}    max_5QI7=${160}     min_5QI8=${50}    max_5QI8=${80}    min_5QI9=${50}    max_5QI9=${80}
    ${Gap1}    Evaluate    abs(${average_QCI8}-${average_QCI9})
    Should be true    ${0}<=${Gap1}<=${25}
    Should be true    ${50}<=${average_QCI7}-${average_QCI8}<=${100}
    Should be true    ${50}<=${average_QCI7}-${average_QCI9}<=${100}
    Check D Counter 3port    value_1=${298}    value_Average=${0.9}    ue_index_UL=${ue_index_list_TL356}    dl_ports=${dl_ports_C}

Check 2 NBR enter to congestion status
    [Arguments]        ${PA}=${34}    ${min_5QI7}=${80}    ${min_5QI8}=${80}    ${min_5QI9}=${80}
    ...    ${max_5QI7}=${100}    ${max_5QI8}=${100}    ${max_5QI9}=${100}    ${Gap}=${5}
    ${average_QCI7}    ${average_QCI8}    ${average_QCI9}    ${index}
    ...    Check NBR congestion NSA D
    ...    file_name=${file_name_D01_2}    PA=${PA}
    ...    min_5QI7=${min_5QI7}    max_5QI7=${max_5QI7}     min_5QI8=${min_5QI8}
    ...    max_5QI8=${max_5QI8}    min_5QI9=${min_5QI9}    max_5QI9=${max_5QI9}
    ${Gap1}    Evaluate    abs(${average_QCI8}-${average_QCI9})
    ${Gap2}    Evaluate    abs(${average_QCI7}-${average_QCI9})
    ${Gap3}    Evaluate    abs(${average_QCI7}-${average_QCI8})
    Should be true    ${0}<=${Gap1}<=${Gap}
    Should be true    ${0}<=${Gap2}<=${Gap}
    Should be true    ${0}<=${Gap3}<=${Gap}
    Check D Counter 3port    value_1=${598}    value_Average=${1.9}    ue_index_UL=${ue_index_list_TL356}    dl_ports=${dl_ports_C}

Check NBR congestion NSA D
     [Arguments]    ${file_name}    ${min_5QI7}    ${min_5QI8}    ${min_5QI9}    ${max_5QI7}    ${max_5QI8}    ${max_5QI9}
    ...    ${PA}=${28}    ${PA_NBR_Max}=${${PA}+${1}}    ${ue_index_list}=${ue_index_list_TL356}
    FOR    ${index}    IN RANGE    ${PA}    ${PA_NBR_Max}
         Adjust gNB_RU Attenuation TL356    gnb1_cell1_value=${index}    enb_cell_value=${0}
         Start Traffic And Download the listened traffic    file_name_DL=${file_name}
         ...    dl_ports=${dl_ports_C}    dl_throughput=${dl_throughput}    ue_index_list=${ue_index_list}
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

Check DA Counter for DL
    [Arguments]    ${value_1}    ${PA}=${34}
    ...    ${counter_id}=${counter_id_D01_gNB1}    ${counter_dic_path}=${counter_dic_path_D01_gNB1}
    ...    ${ue_index_DL}=NULL    ${ue_index_UL}=NULL   ${dl_ports}=NULL    ${ul_ports}=NULL
    Power UE Start DL traffic    dl_throughput=${dl_throughput}    duration=1200    dl_port=${dl_port_5QI9}
    Power UE Start DL traffic    dl_throughput=${dl_throughput}    duration=1200    dl_port=${dl_port_5QI7}
    Power UE Start DL traffic    dl_throughput=${dl_throughput}    duration=1200    dl_port=${dl_port_5QI8}
    FOR    ${index}    IN RANGE    ${PA}    ${${PA}+${5}}
        Adjust gNB_RU Attenuation TL356    gnb1_cell1_value=${index}    enb_cell_value=${0}
        Prepare to caculate PM counter    period=start
        comment    check the NBR_congestion counter
        Prepare to caculate PM counter    period=end
        Sleep    40s
        ${counter_list}=    Get the PM counter
        ...    gnb_index=${0}    counter_id=${counter_id}    dic_path=${counter_dic_path}
        Exit For Loop If    ${counter_list[0]}>=${value_1}
    END
    [Teardown]    Stop DL/UL traffic    ue_index_DL=${ue_index_DL}    ue_index_UL=${ue_index_UL}
    ...    dl_ports=${dl_ports}    ul_ports=${ul_ports}

Set APN point for sanmsung until succeed
    [Arguments]    ${usedapn}=${apn_muiltdrb}    ${location_apn}=${location_apn}
    ${result}    Run keyword and return status    Wait until keyword succeeds    3X    10s
    ...    set apn with special method    usedapn=${usedapn}    location_apn=${location_apn}
    Run keyword If    '${result}'=='False'    Run keywords    Before test reset QCOM use adb command    ue_index=${ue_index}
    ...    AND    set apn with special method    usedapn=${usedapn}    location_apn=${location_apn}
    ...    ELSE    Log To Console    ***No need reboot UE***
    Log To Console    ***Set APN OK***