#*** Settings ***
#Force Tags    PY36
#Documentation     author: qingqing zhang
#...                 contact: qingqing.zhang@nokia-sbell.com
#...                 squad group: SG_03
#...                 feature : CB008140-MB
#
#Resource    ./../Resources/CB008140_common_keywords_multiUE.robot
#Variables    ./Resources/CB008140_M_variables.py
#
#
##Suite Setup    Run Keywords
##...            Run Keyword And Ignore Error    Common Suite Setup for COAM    AND
##...            robot_common_operations.Common Suite Setup    AND
##...            SCF Commission with gnb1 and gnb4    AND
##...            Enable DSS configuration
##
##
##Suite Teardown    Run Keywords
##...               robot_common_operations.Common Suite Teardown    AND
##...               Run Keyword And Ignore Error    Common Suite Teardown for COAM   AND
##...               Run Keyword And Ignore Error    COAM Teardown gnb connections
#
#
#*** Variables ***
#${gnb_path}    /tmp/
#${golden_scf_name_gnb0}    Configuration_scf_GNB1_CB008140.xml
#${golden_scf_name_gnb1}    Configuration_scf_GNB2_CB008140.xml
#${filename_MA001_UE1_gnb0}    log_name_MA_001_gNB1.pcap
#${filename_MA001_UE1_gnb3}    log_name_MA_001_gNB4.pcap
##${filename_MA001_UE2_gnb0}    log_name_MA_001_gNB1.pcap
##${filename_MA001_UE2_gnb3}    log_name_MA_001_gNB4.pcap
#@{filename_MA001}    filename_MA001_UE1_gnb
#${epc_log_path}    /opt/workspace/CRT/Master/Case_Logs/
#@{gnb_ips}    ${bts_host0}    ${bts_host1}
#@{ue_list}    ${0}    ${1}    ${2}
#@{ue_mode_list}    SA    SA    NSA
#@{gnb_list}    ${0}    ${3}
#${Send_Tput_DL}    1000
#${expected_tput_dl_UE}    20
#${expected_tput_dl_F}    390
#${band_all}    2:25:41:66
#${band_66}    66
#@{scell_index_list}    ${2}
#@{extgnb_index_list}    ${3}
#*** Test Cases ***
#[1]CB008140-5G-MA_001_Simultaneous_support_of_inter-gNB_CA_and DSS_AP_in_one_DU
#    [Documentation]    This user scenario intends to verify that whether inter-gNB CA would work normally in case DSS is
#    ...    enabled in the same gNB.
#    [Tags]     classical    CRT_TRUNK
#   [Setup]    robot_common_operations.Common Case Setup
#    MultiUE.Prepare UE    ue_list=@{ue_list}
#    #add NRREL
#    Modify Parameters for Cases   gnb_index=${0}    Add_Mo_Online=${PARAMETERS_TO_ADD_MO_GNB1_MA001}
#    ...    Modify_Para_Online=${PARAMETERS_TO_ONLINE_MODIFY_GNB1_MA001}
#    ##UE1 attach gnb1 cell1 which not DSS cell
#    Adjust gNB_RU Attenuation    gnb1_cell1_value=${0}
#    UE attach and check attach succussful    filename=filename_MA001_UE1_gnb    ue_index=${ue_list}[0]    pcell_index=${1}
#    ...    scell_index=${2}
#    Check UEContextModificationResponse has physcellid on PrimegNB    logname=${filename_MA001_UE1_gnb0}
#    ...    pcell_index=${1}    scell_index_list=${scell_index_list}
#    ...    Primegnb_index=${0}    extgnb_index_list=${extgnb_index_list}
#    ##UE2 attach gnb1 cell2 which DSS cell
#    Adjust gNB_RU Attenuation    gnb1_cell1_value=${20}    gnb1_cell2_value=${0}
#    MultiUE.band restriction    band=${band_66}    ue_index=${ue_list}[1]
#    MultiUE.Attach    ue_index=${ue_list}[1]
#    ###UE3 attach enb cell2 which DSS cell
#    power_ue.Prepare UE    ue_type=${tl.ues[2].capabilities[-1]}    ue_index=${ue_list}[2]
#    ...    detach_request=${True}    power_reset=true    get_spark_license=False
#    Adjust gNB_RU Attenuation    gnb1_cell1_value=${20}    gnb1_cell2_value=${0}
#    MultiUE.Change Network
#    MultiUE.Attach    ue_index=${ue_list}[2]
#    Adjust gNB_RU Attenuation    gnb1_cell1_value=${0}    gnb1_cell2_value=${0}    gnb4_cell2_value=${0}
#    FOR    ${ue_index}    ${ue_mode}    IN ZIP    ${ue_list}    ${ue_mode_list}
#        MultiUE.Start DL Traffic    ue_index=${ue_index}    throughput_for_DL=${Send_Tput_DL}    duration=1200
#        ...    iperf_port=${5${ue_index}387}    ue_mode=${ue_mode}
#        ...    iperf_port=${5${ue_index}387}    ue_mode=${ue_mode}
#        MultiUE._CheckUEThoughput    ue_index=${ue_index}    target_throughput=${expected_tput_dl_UE}
#    END
#    Check 2CC DLUL tput     tput_dl_pcell=${expected_tput_dl_F}    tput_dl_scell=${expected_tput_dl_F}
#    ...    scellid=31    pcellid=1    gnb_prime=${0}    gnb_external=${3}    ue_type=${tl.ues[0].capabilities[0]}
##    MultiUE._CheckUEThoughput    ue_index=${ue_list}[1]    target_throughput=${expected_tput_dl_UE}
##    MultiUE._CheckUEThoughput    ue_index=${ue_list}[2]    target_throughput=${expected_tput_dl_UE}
#    FOR    ${ue_index}    IN ZIP    ${ue_list}
#        MultiUE.Stop DLUL traffic    ue_index=${ue_index}    iperf_port=${5${ue_index}387}
#    END
#    [Teardown]    run keywords
#    ...    Case Teardown    filename=${filename_MA001}    AND
#    ...    Run Keyword And Ignore Error    Adjust gNB_RU Attenuation
#
#
#*** Keywords ***
#SCF Commission with gnb1 and gnb4
#    Common Case TestLine Setup with singe BTS    gnb_index=${0}    ModifySCF_Beforecommission=True
#    ...    golden_scf_name=${tl_scf_filename_gnb0}
#    Common Case TestLine Setup with singe BTS    gnb_index=${3}    ModifySCF_Beforecommission=True
#    ...    golden_scf_name=${tl_scf_filename_gnb3}
#
#Enable DSS configuration
#     Modify Parameters for Cases   gnb_index=${0}    Modify_Para_Online=${PARAMETERS_TO_ONLINE_MODIFY_GNB1_DSS}
#     Modify Parameters for Cases   gnb_index=${3}    Modify_Para_Online=${PARAMETERS_TO_ONLINE_MODIFY_GNB4_DSS}
#
#UE attach and check attach succussful
#    [Arguments]    ${filename}=filename_MA001_UE1_gnb    ${ue_index}=${0}    ${prignb_index}=${0}    ${pcell_index}=${1}
#    ...    ${extgnb_index}=${3}    ${scell_index}=${1}
#    Start capture multi gNB log    filename=${filename}    gnb_list=@{gnb_list}
#    MultiUE.Attach    ue_index=${0}
#    Stop capture multi gNB log    filename=${filename}   gnb_list=@{gnb_list}
#    [Teardown]    Stop capture multi gNB log    filename=${filename}   gnb_list=@{gnb_list}
#
#
#MultiUE._CheckUEThoughput
#    [Arguments]    ${duration}=1200     ${check_tput_on_ue}=false    ${ue_index}=${7}    ${target_throughput}=1000
#    ...    ${direction}=dl
#    ${tput_log}    power_ue.Collect Tput
#    ...    ue_type=${tl.ues[${ue_index}].capabilities[-1]}
#    ...    duration=${duration}
#    ...    ue_index=${ue_index}
#    ...    ue_alias=UE_${ue_index}
#    ${output}=   Power_ue.Check Tput
#    ...    ue_type=${tl.ues[${ue_index}].capabilities[-1]}    log=${tput_log}   direction=${direction}
#    ...    cells=UE_${ue_index}
#    ...    target_throughput=${target_throughput}
##    ...    target_avg_percent=${target_avg_percent}
##    ...    min_percent=${UECFG['${ue_index}']['target_min_percent']}
#    ...    ue_index=${ue_index}
#    ${result}=    Convert To String    ${output}
#    Should Not Contain    ${result}    False
