*** Settings ***
Documentation
...    author: Ming Shi
...    contact: ming.shi@nokia-sbell.com
...    squal group: SG03
...    feature: CB008246-L

Force Tags  CA_5G_RRM
...    PY36
Suite Setup    Run Keywords
...                            robot_common_operations.Common Suite Setup
...                            AND    Common Suite Setup for COAM
...                            AND    Get gnb release info
...                            AND    Common UE parameter setup

Suite Teardown     Common Suite Teardown for COAM    gnb_list=${gnb_list}

Resource    testsuite/Hangzhou/RRM/RAN_PZ_HAZ_34/CB008246/Resources/CB008246_common_keywords.robot

*** Variables ***
${log_name_L_005_1}    log_name_L_005_1.pcap
${log_name_L_006_1}    log_name_L_006_1.pcap
${log_name_L_006_2}    log_name_L_006_2.pcap
${log_name_L_010_1}    log_name_L_010_1.pcap
${expected_tput_dl}    168
${expected_tput_dl_small}    1
${expected_tput_dl_L006}    25
${Send_Tput_DL_L006}        30M
${Send_Tput_DL}        600M
${Send_Tput_DL_small}        60M
${expected_tput_ul}    1
${expected_tput_ul_X70}    60
${expected_tput_ul_X70_small}    1
${Send_Tput_UL}        200M
${Send_Tput_UL_small}        20M
${Send_Tput_UL_L006}        10M
${expected_tput_ul_L006}    1
${Send_Tput_DL_L005}        1k
${Send_Tput_UL_L005}        1k
${expected_tput_dl_L005}    0
${expected_tput_ul_L005}    0
${Send_Tput_UL_L010}        10M
${expected_tput_ul_L010}    9
${zzmdrb2_apn_name}    ${tl.ues[0].pdn[5]}
${wap2_apn_name}    ${tl.ues[0].pdn[0]}
${X70_wap2apn_location}    959 1370
${X70_mdrb2apn_location}    959 1576
${ui_version}    emui 10.1.0
${zmdrb2_apn_name}    ${tl.ues[0].pdn[6]}
@{gnb1_cell2_pa_ports}    ${att_port_3_HBTE}    ${att_port_4_HBTE}
@{gnb1_cell2_pa_origin_values}    ${0}    ${0}
@{gnb1_cell2_pa_target_values}    ${50}    ${50}

${l2stream3_ttitrace_CNI126636_DL_part}    l2stream3_ttitrace_CNI126636_DL_part
${l2stream3_ttitrace_CNI126636_UL_part}    l2stream3_ttitrace_CNI126636_UL_part
${l2stream3_ttitrace_CNI131244_DL_part}    l2stream3_ttitrace_CNI131244_DL_part
${l2stream3_ttitrace_CNI131244_UL_part}    l2stream3_ttitrace_CNI131244_UL_part

# TL348
${5Gcell1_ANT1}    ${tl.gnbs[0].dus[0].rus[0].attenuation_ports[0].port_no}
${5Gcell1_ANT2}    ${tl.gnbs[0].dus[0].rus[0].attenuation_ports[1].port_no}
${5Gcell1_ANT3}    ${tl.gnbs[0].dus[0].rus[0].attenuation_ports[2].port_no}
${5Gcell1_ANT4}    ${tl.gnbs[0].dus[0].rus[0].attenuation_ports[3].port_no}
${5Gcell2_ANT1}    ${tl.gnbs[0].dus[0].rus[1].attenuation_ports[0].port_no}
${5Gcell2_ANT2}    ${tl.gnbs[0].dus[0].rus[1].attenuation_ports[1].port_no}
${5Gcell2_ANT3}    ${tl.gnbs[0].dus[0].rus[1].attenuation_ports[2].port_no}
${5Gcell2_ANT4}    ${tl.gnbs[0].dus[0].rus[1].attenuation_ports[3].port_no}
${5Gcell3_ANT1}    ${tl.gnbs[0].dus[0].rus[2].attenuation_ports[0].port_no}
${5Gcell3_ANT2}    ${tl.gnbs[0].dus[0].rus[2].attenuation_ports[1].port_no}
${5Gcell3_ANT3}    ${tl.gnbs[0].dus[0].rus[2].attenuation_ports[2].port_no}
${5Gcell3_ANT4}    ${tl.gnbs[0].dus[0].rus[2].attenuation_ports[3].port_no}
${5Gcell4_ANT1}    ${tl.gnbs[0].dus[0].rus[3].attenuation_ports[0].port_no}
${5Gcell4_ANT2}    ${tl.gnbs[0].dus[0].rus[3].attenuation_ports[1].port_no}
${5Gcell4_ANT3}    ${tl.gnbs[0].dus[0].rus[3].attenuation_ports[2].port_no}
${5Gcell4_ANT4}    ${tl.gnbs[0].dus[0].rus[3].attenuation_ports[3].port_no}
${5Gcell5_ANT1}    ${tl.gnbs[0].dus[0].rus[4].attenuation_ports[0].port_no}
${5Gcell5_ANT2}    ${tl.gnbs[0].dus[0].rus[4].attenuation_ports[1].port_no}
${5Gcell5_ANT3}    ${tl.gnbs[0].dus[0].rus[4].attenuation_ports[2].port_no}
${5Gcell5_ANT4}    ${tl.gnbs[0].dus[0].rus[4].attenuation_ports[3].port_no}
${5Gcell6_ANT1}    ${tl.gnbs[1].dus[0].rus[0].attenuation_ports[0].port_no}
${5Gcell6_ANT2}    ${tl.gnbs[1].dus[0].rus[0].attenuation_ports[1].port_no}
${5Gcell6_ANT3}    ${tl.gnbs[1].dus[0].rus[0].attenuation_ports[2].port_no}
${5Gcell6_ANT4}    ${tl.gnbs[1].dus[0].rus[0].attenuation_ports[3].port_no}

${4Gcell1_ANT1}    ${tl.gnbs[0].dus[0].rus[0].attenuation_ports[0].port_no}
${4Gcell1_ANT2}    ${tl.gnbs[0].dus[0].rus[0].attenuation_ports[1].port_no}
${4Gcell1_ANT3}    ${tl.gnbs[0].dus[0].rus[0].attenuation_ports[2].port_no}
${4Gcell1_ANT4}    ${tl.gnbs[0].dus[0].rus[0].attenuation_ports[3].port_no}
${4Gcell2_ANT1}    ${tl.gnbs[0].dus[0].rus[1].attenuation_ports[0].port_no}
${4Gcell2_ANT2}    ${tl.gnbs[0].dus[0].rus[1].attenuation_ports[1].port_no}
${4Gcell2_ANT3}    ${tl.gnbs[0].dus[0].rus[1].attenuation_ports[2].port_no}
${4Gcell2_ANT4}    ${tl.gnbs[0].dus[0].rus[1].attenuation_ports[3].port_no}
${4Gcell3_ANT1}    ${tl.gnbs[0].dus[0].rus[2].attenuation_ports[0].port_no}
${4Gcell3_ANT2}    ${tl.gnbs[0].dus[0].rus[2].attenuation_ports[1].port_no}
${4Gcell3_ANT3}    ${tl.gnbs[0].dus[0].rus[2].attenuation_ports[2].port_no}
${4Gcell3_ANT4}    ${tl.gnbs[0].dus[0].rus[2].attenuation_ports[3].port_no}
${4Gcell4_ANT1}    ${tl.gnbs[0].dus[0].rus[3].attenuation_ports[0].port_no}
${4Gcell4_ANT2}    ${tl.gnbs[0].dus[0].rus[3].attenuation_ports[1].port_no}
${4Gcell4_ANT3}    ${tl.gnbs[0].dus[0].rus[3].attenuation_ports[2].port_no}
${4Gcell4_ANT4}    ${tl.gnbs[0].dus[0].rus[3].attenuation_ports[3].port_no}

# TL383
${5Gcells1_ANT1}    ${tl.gnbs[0].dus[0].rus[0].attenuation_ports[0].port_no}
${5Gcells1_ANT2}    ${tl.gnbs[0].dus[0].rus[0].attenuation_ports[1].port_no}
${5Gcells1_ANT3}    ${tl.gnbs[0].dus[0].rus[0].attenuation_ports[2].port_no}
${5Gcells1_ANT4}    ${tl.gnbs[0].dus[0].rus[0].attenuation_ports[3].port_no}
${5Gcells2_ANT1}    ${tl.gnbs[0].dus[0].rus[1].attenuation_ports[0].port_no}
${5Gcells2_ANT2}    ${tl.gnbs[0].dus[0].rus[1].attenuation_ports[1].port_no}
${5Gcells2_ANT3}    ${tl.gnbs[0].dus[0].rus[1].attenuation_ports[2].port_no}
${5Gcells2_ANT4}    ${tl.gnbs[0].dus[0].rus[1].attenuation_ports[3].port_no}
${5Gcells3_ANT1}    ${tl.gnbs[0].dus[0].rus[2].attenuation_ports[0].port_no}
${5Gcells3_ANT2}    ${tl.gnbs[0].dus[0].rus[2].attenuation_ports[1].port_no}
${5Gcells3_ANT3}    ${tl.gnbs[0].dus[0].rus[2].attenuation_ports[2].port_no}
${5Gcells3_ANT4}    ${tl.gnbs[0].dus[0].rus[2].attenuation_ports[3].port_no}
${5Gcells4_ANT1}    ${tl.gnbs[1].dus[0].rus[0].attenuation_ports[0].port_no}    #gnb2 cell1
${5Gcells4_ANT2}    ${tl.gnbs[1].dus[0].rus[0].attenuation_ports[1].port_no}    #gnb2 cell1
${4Gcells1_ANT1}    ${tl.gnbs[0].dus[0].rus[2].attenuation_ports[0].port_no}
${4Gcells1_ANT2}    ${tl.gnbs[0].dus[0].rus[2].attenuation_ports[1].port_no}
${4Gcells1_ANT3}    ${tl.gnbs[0].dus[0].rus[2].attenuation_ports[2].port_no}
${4Gcells1_ANT4}    ${tl.gnbs[0].dus[0].rus[2].attenuation_ports[3].port_no}

@{enb_id}    34821    38321
@{cell_id}    0    1    2    3    4    5
@{cell_id_348}    0    1    2    3    4    5    6
@{multi_gnb_PA}    ${10}     ${127}
@{multi_gnb_PA_358}    ${0}
@{multi_gnb_PA_348}    ${0}    ${50}
@{multi_gnb_PA_383}    ${0}    ${50}

${ue_type_qcom}    ${tl.ues[1].capabilities[0]}

${dxdata2_apn_name}    ${tl.ues[1].pdn[0]}
${mdrb_apn_name}    ${tl.ues[1].pdn[1]}
${mdrb1_apn_name}    ${tl.ues[1].pdn[2]}

${X80_dxdata2apn_location}    1279 1100
${X80_mdrbapn_location}    1279 1300
${X80_mdrb1apn_location}    1279 1550

${traffic_dl_port}    ${tl.ues[1].iperf_details.port}
${traffic_ul_port}    ${tl.ues[1].iperf_details.ssh_connection_details.port}

${tl_scf_dir_path}    /opt/workspace/CRT/Master/SCF_file/

${tl_scf_file_name1}    gNB1_Golden_SCF.xml
${tl_scf_file_name2}    gNB2_Golden_SCF.xml

${l2stream3_ttitrace_L005_1}    l2stream3_ttitrace_L005_1
${l2stream3_ttitrace_L005_2}    l2stream3_ttitrace_L005_2
${epc_log_paths}        /opt/workspace/CRT/Master/Case_Logs

*** Test Cases ***
[1]CB008246-L_005_high_reliability_feature_interworking_with_Power_Saving_UE
    [Documentation]    CB008246-L
    [Tags]    CB008246-L    CRT_TRUNK
    [Timeout]    4 hour
    [Setup]
    Get sagnb version for selenium
    Set Suite Variable    ${tl_gnb1_scf_${sw_version}}    ${sw_version}_gNB1_Golden_SCF.xml
#    ${rc}    ${output}=    run and return rc and output    cd /opt/workspace/Tool/;./modify_numpy_version.sh
    IF    ${enb_instance} == ${enb_id}[0]     #TL348
        Common Case TestLine Setup    ModifySCF_Beforecommission=True
        ...    golden_scf_name=${tl_gnb1_scf_${sw_version}}     scf_path=${tl_scf_dir_path}
#        ...    ParamterToModify=${PARAM_8246_gnb1_L_005_348}    ListParamterToModify=${LIST_TO_MODIFY_GNB1_L005_348}
        ...    ParamterToModify=${PARAM_8246_gnb1_L_005_348}
        ...    is_pdl_checking_needed=${True}
        paras change on BTS
        ...    paras=${CB008246_ciphering_algorithms}
        ...    delta_file_name=${epc_log_path}${CB008246_ciphering_algorithms_json_file}
        PA one cell 0 on and set other cell value 4 port for T348    cellid=${cell_id_348}[5]    set_value=${multi_gnb_PA}[0]
    ELSE IF    ${enb_instance} == ${enb_id}[1]     #TL383
        Common Case TestLine Setup    ModifySCF_Beforecommission=True
        ...    golden_scf_name=${tl_gnb1_scf_${sw_version}}     scf_path=${tl_scf_dir_path}
#        ...    ParamterToModify=${PARAM_8246_gnb1_L_005_348}    ListParamterToModify=${LIST_TO_MODIFY_GNB1_L005_348}
        ...    ParamterToModify=${PARAM_8246_gnb1_L_005_348}
        ...    is_pdl_checking_needed=${True}
        paras change on BTS
        ...    paras=${CB008246_ciphering_algorithms}
        ...    delta_file_name=${epc_log_path}${CB008246_ciphering_algorithms_json_file}
        PA one cell 0 on and set other cell value 4 port for T348    cellid=${cell_id_348}[5]    set_value=${multi_gnb_PA}[0]
    END
    robot_common_operations.Common Case Setup    allowed_faults_ids=4291
    AlarmWatchdog.add_allow_alarms    fault_id=4291
#    choice required APN on QCOM SDX80 UE    usedapn=${X80_dxdata2apn_location}    ue_index=${1}
    Comment    UE3 attach on gnb1 cell1
    Start capture gNB log on master    filename=${log_name_L_005_1}
    Power_ue.Prepare UE    ue_type=${ue_type_qcom}    ue_index=${1}
#    Start capture syslog via btslog on ute
    Attach and check power UE    ue_type=${ue_type_qcom}    ue_index=${1}    gnb_index=${0}
#    Sleep    30s
    Stop and download Logs on gNB on master    filename=${log_name_L_005_1}
    Check wireshark log for 8246_L_UE_RNTI_ID    logname=${log_name_L_005_1}
    Comment    traffic DL 600M+UL 200M
    Check wap2 5QI7 traffic DL 600M+UL 200M 8246_HR_L005_counter    tti_name=${l2stream3_ttitrace_L005_1}
    Comment    traffic DL 1kb+UL 1kb
    Check wap2 5QI7 traffic DL 1kb+UL 1kb 8246_HR_L005_counter
    Comment    traffic DL 600M+UL 200M
    Check wap2 5QI7 traffic DL 600M+UL 200M 8246_HR_L005_counter    tti_name=${l2stream3_ttitrace_L005_2}
    IF    ${sw_version}[-4:-2] < 25
        Run Keyword And Continue On Failure    CNI126636 steps executed DL part
        Run Keyword And Continue On Failure    CNI126636 steps executed UL part
    ELSE
        Run Keyword And Continue On Failure    CNI131244 Steps Executed DL Part
        Run Keyword And Continue On Failure    CNI131244 Steps Executed UL Part
    END
    [Teardown]    Run Keywords
    ...    robot_common_operations.Common Case Teardown
    ...    AND    AlarmWatchdog.remove_allow_alarms    fault_id=4291
    ...    AND    Stop DL or UL traffic    ue_index=${1}    ue_type=${ue_type_qcom}    direction=DL
    ...    AND    Stop DL or UL traffic    ue_index=${1}    ue_type=${ue_type_qcom}    direction=UL
    ...    AND    UE.UE Detach     ue_type=${ue_type_qcom}     ue_index=${1}
    ...    AND    Run Keyword And Ignore Error    Stop and download Logs on gNB on master    filename=${log_name_L_005_1}
    ...    AND    recover paras and PA values for L05
#    ...    AND    Stop capture syslog via btslog on ute
    ...    AND    Run keyword if    '${TEST STATUS}' == 'FAIL'    Run keyword and continue on failure    COAM Save snapshot
    ...    AND    Setup for Env cell on-air for 2 gnb    is_commission_for_second_gnb=False    tl_scf_file_name=${tl_gnb1_scf_${sw_version}}
#    ...    AND    get and analysis syslog
    ...    AND    Run Keyword And Ignore Error    CI_interface.Common Case Teardown

*** Keywords ***
Check wireshark log for 8246_L_UE_RNTI_ID
    [Arguments]    ${logname}
    ${UE_RNTI_ID}=    Get RNTI-ID message    logname=${logname}
    Set Suite Variable    ${SA_UE_RNTI_ID}    ${UE_RNTI_ID}

Get RNTI-ID message
    [Arguments]    ${logname}
    ${all_packets}=    cap.load_pcap_file    pcap_file=${epc_log_path}${logname}    tshark_path=${tshark_path}
    ####InitialULRRCMessageTransfer, RRC Setup Request
    ${RRC_Setup_request}=     Catenate    (f1ap.F1AP_PDU == 0 and f1ap.procedureCode == 11 and f1ap.C_RNTI)
    ${RRC_Setup_request_packets}=    cap.filter_packets_by_expression    filter_expression=${RRC_Setup_request}
    ${UE_RNTI_ID}=     cap.get_field_value_by_xpath    pdml_list=${RRC_Setup_request_packets}
    ...                                                xpath=.//f1ap.C_RNTI
    [Return]    ${UE_RNTI_ID}[0]

Check wap2 5QI7 traffic DL 600M+UL 200M 8246_HR_L005_counter
    [Arguments]    ${tti_name}
    sleep    10s
    Start Ttitrace With Admin Mode    names=${tti_name}    nr_phy_cell_ids=700
    Start only DL traffic and check tput    ue_index=${1}    cellid=${4}    ue_type=${ue_type_qcom}    gnb_index=${0}
    ...                                tput_dl_cell=${expected_tput_dl}    dl_throughput=${Send_Tput_DL}    duration=${7200}
    ...                                dl_port=${traffic_dl_port}
    Start only UL traffic and check tput    ue_index=${1}    cellid=${4}    ue_type=${ue_type_qcom}    gnb_index=${0}
    ...                                tput_ul_cell=${expected_tput_ul_X70}    ul_throughput=${Send_Tput_UL}    duration=${7200}
    ...                                ul_port=${traffic_ul_port}
    [Teardown]     Run Keywords
    ...    Stop Ttitrace With Admin Mode    names=${tti_name}      target_dir=${epc_log_paths}
    ...    AND    Prepare with PM counter time to caculate    period=start
    ...    AND    sleep    5min
    ...    AND    Check trunk counter for 8246_HR_L005_1_gNB1cell2_BWP1
    ...    AND    Stop DL or UL traffic    ue_index=${1}    ue_type=${ue_type_qcom}    direction=DL
    ...    AND    Stop DL or UL traffic    ue_index=${1}    ue_type=${ue_type_qcom}    direction=UL

Check wap2 5QI7 traffic DL 1kb+UL 1kb 8246_HR_L005_counter
    sleep    10s
    Start only DL traffic and check tput    ue_index=${1}    cellid=${4}    ue_type=${ue_type_qcom}    gnb_index=${0}
    ...                                tput_dl_cell=${expected_tput_dl_L005}    dl_throughput=${Send_Tput_DL_L005}    duration=${7200}
    ...                                dl_port=${traffic_dl_port}
    Start only UL traffic and check tput    ue_index=${1}    cellid=${4}    ue_type=${ue_type_qcom}    gnb_index=${0}
    ...                                tput_ul_cell=${expected_tput_ul_L005}    ul_throughput=${Send_Tput_UL_L005}    duration=${7200}
    ...                                ul_port=${traffic_ul_port}
    Prepare with PM counter time to caculate    period=start
    sleep    5min
    Check trunk counter for 8246_HR_L005_1_gNB1cell700_BWP3_PowerSaving
    [Teardown]     Run Keywords
    ...    Stop DL or UL traffic    ue_index=${1}    ue_type=${ue_type_qcom}    direction=DL
    ...    AND    Stop DL or UL traffic    ue_index=${1}    ue_type=${ue_type_qcom}    direction=UL

Check trunk counter for 8246_HR_L005_1_gNB1cell2_BWP1
    sleep    40s
    ${counter_value_list}    Get the all PM counter value
    ...    gnb_index=${0}    counter_id=${counter_id_L005_HR_gNB1_cell2}    dic_path=${Trunk_counter_dic_path_L005_HR_gNB1_cell2_348}
    Set suite variable    ${M55366C00001_LOWSE_HRD}                   ${counter_value_list}[0]
    Set suite variable    ${M55366C00002_LOWSE_HRD}                   ${counter_value_list}[1]
    Set suite variable    ${M55367C00001_LOWSE_HRD}                   ${counter_value_list}[2]
    Set suite variable    ${M55367C00002_LOWSE_HRD}                   ${counter_value_list}[3]
    Set suite variable    ${M55365C03007_DL_GRANT_HR_AL2_CBWP1}       ${counter_value_list}[4]
    Set suite variable    ${M55365C03008_DL_GRANT_HR_AL4_CBWP1}       ${counter_value_list}[5]
    Set suite variable    ${M55365C03002_UL_GRANT_HR_AL2_CBWP1}       ${counter_value_list}[6]
    Set suite variable    ${M55365C03003_UL_GRANT_HR_AL4_CBWP1}       ${counter_value_list}[7]
    ${M55366C00001_02_gap}=    Evaluate    (${M55366C00001_LOWSE_HRD} - ${M55366C00002_LOWSE_HRD})/${M55366C00001_LOWSE_HRD}
    Should Be True    ${M55366C00001_02_gap}<=0.011
    ${M55367C00001_02_gap}=    Evaluate    (${M55367C00001_LOWSE_HRD} - ${M55367C00002_LOWSE_HRD})/${M55367C00001_LOWSE_HRD}
    Should Be True    ${M55367C00001_02_gap}<=0.011
    ${DL_GRANT_HR_AL2_AL4_CBWP1_gap}=    Evaluate    (${M55365C03007_DL_GRANT_HR_AL2_CBWP1} + ${M55365C03008_DL_GRANT_HR_AL4_CBWP1})
    Should Be True    ${DL_GRANT_HR_AL2_AL4_CBWP1_gap} >0
    ${UL_GRANT_HR_AL2_AL4_CBWP1_gap}=    Evaluate    (${M55365C03002_UL_GRANT_HR_AL2_CBWP1} + ${M55365C03003_UL_GRANT_HR_AL4_CBWP1})
    Should Be True    ${UL_GRANT_HR_AL2_AL4_CBWP1_gap} >0

Check counter for 8246_HR_L005_1_gNB1cell2_BWP1
    sleep    40s
    ${counter_value_list}    Get the all PM counter value
    ...    gnb_index=${0}    counter_id=${counter_id_L005_HR_gNB1_cell2}    dic_path=${counter_dic_path_L005_HR_gNB1_cell2}
    Set suite variable    ${M55366C00001_LOWSE_HRD}                   ${counter_value_list}[0]
    Set suite variable    ${M55366C00002_LOWSE_HRD}                   ${counter_value_list}[1]
    Set suite variable    ${M55367C00001_LOWSE_HRD}                   ${counter_value_list}[2]
    Set suite variable    ${M55367C00002_LOWSE_HRD}                   ${counter_value_list}[3]
    Set suite variable    ${M55365C03007_DL_GRANT_HR_AL2_CBWP1}       ${counter_value_list}[4]
    Set suite variable    ${M55365C03008_DL_GRANT_HR_AL4_CBWP1}       ${counter_value_list}[5]
    Set suite variable    ${M55365C03002_UL_GRANT_HR_AL2_CBWP1}       ${counter_value_list}[6]
    Set suite variable    ${M55365C03003_UL_GRANT_HR_AL4_CBWP1}       ${counter_value_list}[7]
    ${M55366C00001_02_gap}=    Evaluate    (${M55366C00001_LOWSE_HRD} - ${M55366C00002_LOWSE_HRD})/${M55366C00001_LOWSE_HRD}
    Should Be True    ${M55366C00001_02_gap}<=0.011
    ${M55367C00001_02_gap}=    Evaluate    (${M55367C00001_LOWSE_HRD} - ${M55367C00002_LOWSE_HRD})/${M55367C00001_LOWSE_HRD}
    Should Be True    ${M55367C00001_02_gap}<=0.011
    ${DL_GRANT_HR_AL2_AL4_CBWP1_gap}=    Evaluate    (${M55365C03007_DL_GRANT_HR_AL2_CBWP1} + ${M55365C03008_DL_GRANT_HR_AL4_CBWP1})
    Should Be True    ${DL_GRANT_HR_AL2_AL4_CBWP1_gap} >0
    ${UL_GRANT_HR_AL2_AL4_CBWP1_gap}=    Evaluate    (${M55365C03002_UL_GRANT_HR_AL2_CBWP1} + ${M55365C03003_UL_GRANT_HR_AL4_CBWP1})
    Should Be True    ${UL_GRANT_HR_AL2_AL4_CBWP1_gap} >0

Check trunk counter for 8246_HR_L005_1_gNB1cell2_BWP2_PowerSaving
    sleep    40s
    ${counter_value_list}    Get the all PM counter value
    ...    gnb_index=${0}    counter_id=${counter_id_L005_HR_gNB1_cell2}    dic_path=${Trunk_counter_dic_path_L005_HR_gNB1_cell2_348}
#    Set suite variable    ${M55366C00001_LOWSE_HRD}                   ${counter_value_list}[0]
#    Set suite variable    ${M55366C00002_LOWSE_HRD}                   ${counter_value_list}[1]
#    Set suite variable    ${M55367C00001_LOWSE_HRD}                   ${counter_value_list}[2]
#    Set suite variable    ${M55367C00002_LOWSE_HRD}                   ${counter_value_list}[3]
    Set suite variable    ${M55365C06007_DL_GRANT_HR_AL2_CBWP2}       ${counter_value_list}[4]
    Set suite variable    ${M55365C06008_DL_GRANT_HR_AL4_CBWP2}       ${counter_value_list}[5]
    Set suite variable    ${M55365C06002_UL_GRANT_HR_AL2_CBWP2}       ${counter_value_list}[6]
    Set suite variable    ${M55365C06003_UL_GRANT_HR_AL4_CBWP2}       ${counter_value_list}[7]
    Comment    according to Precheck [CLOSED][L][L010]HR bler is about 0.45 with IWK_PS the Bler not need to check
#    ${M55366C00001_02_gap}=    Evaluate    (${M55366C00001_LOWSE_HRD} - ${M55366C00002_LOWSE_HRD})/${M55366C00001_LOWSE_HRD}
#    Should Be True    ${M55366C00001_02_gap}<=0.011
#    ${M55367C00001_02_gap}=    Evaluate    (${M55367C00001_LOWSE_HRD} - ${M55367C00002_LOWSE_HRD})/${M55367C00001_LOWSE_HRD}
#    Should Be True    ${M55367C00001_02_gap}<=0.011
    ${DL_GRANT_HR_AL2_AL4_CBWP2_gap}=    Evaluate    (${M55365C06007_DL_GRANT_HR_AL2_CBWP2} + ${M55365C06008_DL_GRANT_HR_AL4_CBWP2})
    Should Be True    ${DL_GRANT_HR_AL2_AL4_CBWP2_gap} >0
    ${UL_GRANT_HR_AL2_AL4_CBWP2_gap}=    Evaluate    (${M55365C06002_UL_GRANT_HR_AL2_CBWP2} + ${M55365C06003_UL_GRANT_HR_AL4_CBWP2})
    Should Be True    ${UL_GRANT_HR_AL2_AL4_CBWP2_gap} >0

Check trunk counter for 8246_HR_L005_1_gNB1cell700_BWP3_PowerSaving
    sleep    40s
    # need to check value of parameter cellBwpId, which related with Powersaving
    ${counter_value_list}    Get the all PM counter value
    ...    gnb_index=${0}    counter_id=${counter_id_L005_HR_gNB1_cell700}    dic_path=${Trunk_counter_dic_path_L005_HR_gNB1_cell700_348}
    Set suite variable    ${M55365C09006_DL_AL1_CBWP3}       ${counter_value_list}[4]
    Set suite variable    ${M55365C09007_DL_AL2_CBWP3}       ${counter_value_list}[5]
    Set suite variable    ${M55365C09008_DL_AL4_CBWP3}       ${counter_value_list}[6]
    Set suite variable    ${M55365C09009_DL_AL8_CBWP3}       ${counter_value_list}[7]
    Set suite variable    ${M55365C09001_UL_AL1_CBWP3}       ${counter_value_list}[0]
    Set suite variable    ${M55365C09002_UL_AL2_CBWP3}       ${counter_value_list}[1]
    Set suite variable    ${M55365C09003_UL_AL4_CBWP3}       ${counter_value_list}[2]
    Set suite variable    ${M55365C09004_UL_AL8_CBWP3}       ${counter_value_list}[3]
    Comment    according to Precheck [CLOSED][L][L010]HR bler is about 0.45 with IWK_PS the Bler not need to check
    ${DL_GRANT_HR_AL1_AL2_AL4_AL8_CBWP3_gap}=    Evaluate
    ...    ${M55365C09006_DL_AL1_CBWP3} + ${M55365C09007_DL_AL2_CBWP3} + ${M55365C09008_DL_AL4_CBWP3} + ${M55365C09009_DL_AL8_CBWP3}
    Should Be True    ${DL_GRANT_HR_AL1_AL2_AL4_AL8_CBWP3_gap} >0
    ${UL_GRANT_HR_AL1_AL2_AL4_AL8_CBWP3_gap}=    Evaluate
    ...    ${M55365C09001_UL_AL1_CBWP3} + ${M55365C09002_UL_AL2_CBWP3} + ${M55365C09003_UL_AL4_CBWP3} + ${M55365C09004_UL_AL8_CBWP3}
    Should Be True    ${UL_GRANT_HR_AL1_AL2_AL4_AL8_CBWP3_gap} >0

Check counter for 8246_HR_L005_1_gNB1cell2_BWP2_PowerSaving
    sleep    40s
    ${counter_value_list}    Get the all PM counter value
    ...    gnb_index=${0}    counter_id=${counter_id_L005_HR_gNB1_cell2}    dic_path=${counter_dic_path_L005_HR_gNB1_cell2}
#    Set suite variable    ${M55366C00001_LOWSE_HRD}                   ${counter_value_list}[0]
#    Set suite variable    ${M55366C00002_LOWSE_HRD}                   ${counter_value_list}[1]
#    Set suite variable    ${M55367C00001_LOWSE_HRD}                   ${counter_value_list}[2]
#    Set suite variable    ${M55367C00002_LOWSE_HRD}                   ${counter_value_list}[3]
    Set suite variable    ${M55365C06007_DL_GRANT_HR_AL2_CBWP2}       ${counter_value_list}[4]
    Set suite variable    ${M55365C06008_DL_GRANT_HR_AL4_CBWP2}       ${counter_value_list}[5]
    Set suite variable    ${M55365C06002_UL_GRANT_HR_AL2_CBWP2}       ${counter_value_list}[6]
    Set suite variable    ${M55365C06003_UL_GRANT_HR_AL4_CBWP2}       ${counter_value_list}[7]
    Comment    according to Precheck [CLOSED][L][L010]HR bler is about 0.45 with IWK_PS the Bler not need to check
#    ${M55366C00001_02_gap}=    Evaluate    (${M55366C00001_LOWSE_HRD} - ${M55366C00002_LOWSE_HRD})/${M55366C00001_LOWSE_HRD}
#    Should Be True    ${M55366C00001_02_gap}<=0.011
#    ${M55367C00001_02_gap}=    Evaluate    (${M55367C00001_LOWSE_HRD} - ${M55367C00002_LOWSE_HRD})/${M55367C00001_LOWSE_HRD}
#    Should Be True    ${M55367C00001_02_gap}<=0.011
    ${DL_GRANT_HR_AL2_AL4_CBWP2_gap}=    Evaluate    (${M55365C06007_DL_GRANT_HR_AL2_CBWP2} + ${M55365C06008_DL_GRANT_HR_AL4_CBWP2})
    Should Be True    ${DL_GRANT_HR_AL2_AL4_CBWP2_gap} >0
    ${UL_GRANT_HR_AL2_AL4_CBWP2_gap}=    Evaluate    (${M55365C06002_UL_GRANT_HR_AL2_CBWP2} + ${M55365C06003_UL_GRANT_HR_AL4_CBWP2})
    Should Be True    ${UL_GRANT_HR_AL2_AL4_CBWP2_gap} >0

Get the all PM counter value
    [Arguments]    ${counter_id}    ${dic_path}    ${gnb_index}=${0}
    ...    ${bts_host}=${tl.gnbs[${gnb_index}].cu.oam_ssh_connection_details.addr}
    ...    ${username}=${tl.gnbs[${gnb_index}].cu.oam_http_connection_details.username}
    ...    ${password}=${tl.gnbs[${gnb_index}].cu.oam_http_connection_details.password}
    ${counter_lenth}    Get Length    ${counter_id}
    ${counter_value_list}    create list
    Connect to gnb coam via ssl    bts_host=${bts_host}    username=${username}    password=${password}
    FOR    ${index}    IN RANGE    ${counter_lenth}
        ${counter_value} =    get_pm_counter_values    counter_id=${counter_id[${index}]}    connection=GNB_OAM
         ...    dic_path=${dic_path[${index}]}
        append to list    ${counter_value_list}    ${counter_value[0]}
    END
    [Return]    ${counter_value_list}

#Get all X70 pointer variable
#    Set Suite Variable    ${home}    3
#    Set Suite Variable    ${airplane}    953 1385
#    Set Suite Variable    ${close_task}    523 272
#    Set Suite Variable    ${Home_button}    3
#    Set Suite Variable    ${swipe}    500 2050 500 800
#    Set Suite Variable    ${open_iperf_location}    480 860
#    Set Suite Variable    ${iperf_button}    720 312
#    Set Suite Variable    ${iperf_space}    800 550
#    Set Suite Variable    ${brand}    qti

choice required APN on QCOM UE
    [Arguments]    ${usedapn}    ${ue_index}=${0}    ${serial_number}=${tl.ues[${ue_index}].serial_number}
    Get all X70 pointer variable
    set Qcom apn to wap2    usedapn=${usedapn}    ue_index=${ue_index}
    make airplane mode to enable    ue_index=${ue_index}
    Connect to control pc via cygwin    ue_index=${ue_index}
    #### KEYCODE_APP_SWITCH,recent APP application
    csn.send_command    command=adb -s ${serial_number} shell input keyevent 187    connection=cygwin
    #### clear all KEYCODE_APP_SWITCH,recent APP application
    FOR  ${i}    IN RANGE    ${9}
        csn.send_command    command=adb -s ${serial_number} shell input swipe 100 1300 900 1300    connection=cygwin
        sleep    1s
    END
    sleep    2s
    FOR  ${i}    IN RANGE    ${2}
        csn.send_command    command=adb -s ${serial_number} shell input tap 241 1076    connection=cygwin
        sleep   1s
    END
    csn.disconnect    connection=cygwin

set Qcom apn to wap2
    [Arguments]    ${usedapn}=${wap2apn}    ${ue_index}=${0}    ${serial_number}=${tl.ues[${ue_index}].serial_number}
    Set Suite Variable    ${apnset1}    ${usedapn}
    Connect to control pc via cygwin    ue_index=${ue_index}
    ${passed} =    Check airplane mode status on    ue_index=${ue_index}
    run keyword if    '${passed}'=='${True}'
        ...    Run Keywords    Connect to control pc via cygwin    ue_index=${ue_index}
        ...    AND    Commercial UE click AIRPLANE once    Home_button=${home}    airplane=${airplane}    ue_index=${ue_index}
        ...    close_task=${close_task}
    Connect to control pc via cygwin    ue_index=${ue_index}    alias=cygwin
    sleep   5s
    Run Keyword And Ignore Error    csn.send_command    command=adb -s ${serial_number} shell input keyevent ${Home_button}    connection=cygwin
    sleep   2s
    #### KEYCODE_APP_SWITCH,recent APP application
    csn.send_command    command=adb -s ${serial_number} shell input keyevent 187    connection=cygwin
    #### clear all KEYCODE_APP_SWITCH,recent APP application
    FOR  ${i}    IN RANGE    ${9}
        csn.send_command    command=adb -s ${serial_number} shell input swipe 100 1300 900 1300    connection=cygwin
        sleep    1s
    END
    sleep    2s
    FOR  ${i}    IN RANGE    ${2}
        csn.send_command    command=adb -s ${serial_number} shell input tap 241 1076    connection=cygwin
        sleep   1s
    END
    sleep   2s
    ####1.APN setting
    ####1.1 setting
    csn.send_command    command=adb -s ${serial_number} shell am start com.android.settings/com.android.settings.Settings$ApnSettingsActivity
    ...    connection=cygwin
    ####1.2 Network&internet
    sleep   2s
    csn.send_command    command=adb -s ${serial_number} shell input tap 447 938    connection=cygwin
    sleep   2s
    ####1.3 SIMs
    csn.send_command    command=adb -s ${serial_number} shell input tap 323 1205    connection=cygwin
    sleep   2s
    ####1.4 T-Mobile
    csn.send_command    command=adb -s ${serial_number} shell input tap 337 736    connection=cygwin
    sleep   2s
    ####1.5 swipe Access Point Names
    FOR  ${i}    IN RANGE    ${4}
        csn.send_command    command=adb -s ${serial_number} shell input swipe 500 2050 500 800    connection=cygwin
        sleep    1s
    END
    ####1.6 click Access Point Names
    csn.send_command    command=adb -s ${serial_number} shell input tap 486 1604    connection=cygwin
    sleep   2s
    ####1.6 switch Access Point Names
    csn.send_command    command=adb -s ${serial_number} shell input tap ${apnset1}    connection=cygwin
    sleep   2s
    [Teardown]    csn.disconnect    connection=cygwin

#Switch QCOM APN to muti DRB
#    [Arguments]    ${apn_name}    ${ue_index}=${0}    ${ue_type}=${ue_type1}
#    Run Keyword And Ignore Error    Attach and check power UE   ue_type=${ue_type}    ue_index=${ue_index}
#    Android UE SwitchApn    ue_index=${ue_index}    apn_name=${apn_name}    #ui_version=${ui_version}
#    run keyword and ignore error    UE.UE Detach    ue_type=${ue_type}
#
#Switch APN to muti DRB
#    [Arguments]    ${apn_name}    ${ui_version}    ${ue_index}=${0}    ${ue_type}=${ue_type1}
#    Run Keyword And Ignore Error    Attach and check power UE   ue_type=${ue_type}
#    Android UE SwitchApn    ue_index=${ue_index}    apn_name=${apn_name}    ui_version=${ui_version}
#    run keyword and ignore error    UE.UE Detach    ue_type=${ue_type}
#
#Android UE SwitchApn
#    [Documentation]
#    ...    Note: Use the keyword must be ensure that UE UI Menu is English language
#    ...    str ui_version: mobile ui version.
#    ...        e.g Magic UI 3.1.1, have tested on honor CDY-AN90 1080x2400,
#    ...            EMUI 10.1.0, have tested on huawei mate30 LIO-AN00 1176x2400.
#    ...            Qualcomm qti lahaina for arm64 ue do not have UI, so this field equal to '' or ${None}
#    ...           if mobile is mtk peturs, pass 'petrus' as ui_version.
#    [Arguments]       ${ue_index}=${0}    ${host}=${tl.ues[${ue_index}].ssh_connection_details.addr}
#    ...    ${username}=${tl.ues[${ue_index}].ssh_connection_details.username}
#    ...    ${password}=${tl.ues[${ue_index}].ssh_connection_details.password}     ${ui_version}=${None}
#    ...    ${serial_number}=${tl.ues[${ue_index}].serial_number}    ${apn_name}=mdrb    ${ue_alias}=UE_${ue_index}
#    android_mobile.setup
#    ...               ui_version=${ui_version}    host=${host}    username=${username}
#    ...               password=${password}    port=22     serial_number=${serial_number}    alias=${UE_alias}
#    run keyword and ignore error    android_mobile.switch_apn       apn_name=${apn_name}   mobile=${UE_alias}
#    android_mobile.teardown       mobile=${UE_alias}

CNI126636 steps executed DL part
    Comment    adjust PA to 0db as initial value
    IF    ${enb_instance} == ${enb_id}[0]     #TL348
        PA one cell 0 on and set other cell value 4 port for T348    cellid=${cell_id_348}[5]    set_value=${multi_gnb_PA}[0]
        Sleep    10s    reason=wait for PA adjust completely
        Start only DL traffic and check tput    ue_index=${1}    cellid=${4}    ue_type=${ue_type_qcom}    gnb_index=${0}
        ...                                tput_dl_cell=${expected_tput_dl_small}    dl_throughput=${Send_Tput_DL_small}    duration=${7200}
        ...                                dl_port=${traffic_dl_port}
        Comment    adjust PA to 50db and capture TTI
        Capture Ttitrace With Admin Mode and adjust PA and Convert format
        ...    names=${l2stream3_ttitrace_CNI126636_DL_part}    nr_phy_cell_ids=700
    ELSE IF    ${enb_instance} == ${enb_id}[1]     #TL383
        PA one cell 0 on and set other cell value 4 port for T348    cellid=${cell_id_348}[5]    set_value=${multi_gnb_PA}[0]
        Sleep    10s    reason=wait for PA adjust completely
        Start only DL traffic and check tput    ue_index=${1}    cellid=${4}    ue_type=${ue_type_qcom}    gnb_index=${0}
        ...                                tput_dl_cell=${expected_tput_dl_small}    dl_throughput=${Send_Tput_DL_small}    duration=${7200}
        ...                                dl_port=${traffic_dl_port}
        Comment    adjust PA to 50db and capture TTI
        Capture Ttitrace With Admin Mode and adjust PA and Convert format
        ...    names=${l2stream3_ttitrace_CNI126636_DL_part}    nr_phy_cell_ids=700
    END
    Comment    analysis TTI report
    check_value
    ...    file_path=${epc_log_path}/${l2stream3_ttitrace_CNI126636_DL_part}_dl.csv
    ...    rank1_file_path=${CURDIR}/Resources/CQI_to_MCS_64QAM_Low_SE_with_RANK1_DL.csv
    ...    rank2_file_path=${CURDIR}/Resources/CQI_to_MCS_64QAM_Low_SE_with_RANK2_DL.csv
    [Teardown]    Stop DL or UL traffic    ue_index=${1}    ue_type=${ue_type_qcom}    direction=DL

CNI126636 steps executed UL part
    Comment    adjust PA to 0db as initial value
    IF    ${enb_instance} == ${enb_id}[0]     #TL348
        PA one cell 0 on and set other cell value 4 port for T348    cellid=${cell_id_348}[5]    set_value=${multi_gnb_PA}[0]
        Sleep    10s    reason=wait for PA adjust completely
        Start only UL traffic and check tput    ue_index=${1}    cellid=${4}    ue_type=${ue_type_qcom}    gnb_index=${0}
        ...                                tput_ul_cell=${expected_tput_ul_X70_small}    ul_throughput=${Send_Tput_UL_small}    duration=${7200}
        ...                                ul_port=${traffic_ul_port}
        Comment    adjust PA to 50db and capture TTI
        Capture Ttitrace With Admin Mode and adjust PA and Convert format
        ...    names=${l2stream3_ttitrace_CNI126636_UL_part}    nr_phy_cell_ids=700
    ELSE IF    ${enb_instance} == ${enb_id}[1]     #TL383
        PA one cell 0 on and set other cell value 4 port for T348    cellid=${cell_id_348}[5]    set_value=${multi_gnb_PA}[0]
        Sleep    10s    reason=wait for PA adjust completely
        Start only UL traffic and check tput    ue_index=${1}    cellid=${4}    ue_type=${ue_type_qcom}    gnb_index=${0}
        ...                                tput_ul_cell=${expected_tput_ul_X70_small}    ul_throughput=${Send_Tput_UL_small}    duration=${7200}
        ...                                ul_port=${traffic_ul_port}
        Comment    adjust PA to 50db and capture TTI
        Capture Ttitrace With Admin Mode and adjust PA and Convert format
        ...    names=${l2stream3_ttitrace_CNI126636_UL_part}    nr_phy_cell_ids=700
    END
    Comment    analysis TTI report
    check_values_on_direction_ul
    ...    file_path=${epc_log_path}/${l2stream3_ttitrace_CNI126636_UL_part}_ul.csv
    ...    rnti=${SA_UE_RNTI_ID}
    ...    rank1_file_path=${CURDIR}/Resources/SINR_to_MCS_64QAM_Low_SE_with_RANK1_UL.csv
    ...    rank2_file_path=${CURDIR}/Resources/SINR_to_MCS_64QAM_Low_SE_with_RANK2_UL.csv
    ...    rank1_rank2_mcs_mapping=${CURDIR}/Resources/RANK1_to_RANK2_MCS_mapping.csv
    [Teardown]     Stop DL or UL traffic    ue_index=${1}    ue_type=${ue_type_qcom}    direction=UL

CNI131244 steps executed DL part
    Comment    adjust PA to 0db as initial value
    IF    ${enb_instance} == ${enb_id}[0]     #TL348
        PA one cell 0 on and set other cell value 4 port for T348    cellid=${cell_id_348}[5]    set_value=${multi_gnb_PA}[0]
        Sleep    10s    reason=wait for PA adjust completely
        Start only DL traffic and check tput    ue_index=${1}    cellid=${4}    ue_type=${ue_type_qcom}    gnb_index=${0}
        ...                                tput_dl_cell=${expected_tput_dl_small}    dl_throughput=${Send_Tput_DL_small}    duration=${7200}
        ...                                dl_port=${traffic_dl_port}
        Comment    adjust PA to 50db and capture TTI
        Capture Ttitrace With Admin Mode and adjust PA and Convert format
        ...    names=${l2stream3_ttitrace_CNI131244_DL_part}    nr_phy_cell_ids=700
    ELSE IF    ${enb_instance} == ${enb_id}[1]     #TL383
        PA one cell 0 on and set other cell value 4 port for T348    cellid=${cell_id_348}[5]    set_value=${multi_gnb_PA}[0]
        Sleep    10s    reason=wait for PA adjust completely
        Start only DL traffic and check tput    ue_index=${1}    cellid=${4}    ue_type=${ue_type_qcom}    gnb_index=${0}
        ...                                tput_dl_cell=${expected_tput_dl_small}    dl_throughput=${Send_Tput_DL_small}    duration=${7200}
        ...                                dl_port=${traffic_dl_port}
        Comment    adjust PA to 50db and capture TTI
        Capture Ttitrace With Admin Mode and adjust PA and Convert format
        ...    names=${l2stream3_ttitrace_CNI131244_DL_part}    nr_phy_cell_ids=700
    END
    Comment    analysis TTI report
    check_value
    ...    file_path=${epc_log_path}/${l2stream3_ttitrace_CNI131244_DL_part}_dl.csv
    ...    rank1_file_path=${CURDIR}/Resources/CQI_to_MCS_64QAM_Low_SE_with_RANK1_DL_PRB2.csv
    ...    rank2_file_path=${CURDIR}/Resources/CQI_to_MCS_64QAM_Low_SE_with_RANK2_DL_PRB2.csv
    ...    num_prb=2
    [Teardown]    Stop DL or UL traffic    ue_index=${1}    ue_type=${ue_type_qcom}    direction=DL

CNI131244 steps executed UL part
    Comment    adjust PA to 0db as initial value
    IF    ${enb_instance} == ${enb_id}[0]     #TL348
        PA one cell 0 on and set other cell value 4 port for T348    cellid=${cell_id_348}[5]    set_value=${multi_gnb_PA}[0]
        Sleep    10s    reason=wait for PA adjust completely
        Start only UL traffic and check tput    ue_index=${1}    cellid=${4}    ue_type=${ue_type_qcom}    gnb_index=${0}
        ...                                tput_ul_cell=${expected_tput_ul_X70_small}    ul_throughput=${Send_Tput_UL_small}    duration=${7200}
        ...                                ul_port=${traffic_ul_port}
        Comment    adjust PA to 50db and capture TTI
        Capture Ttitrace With Admin Mode and adjust PA and Convert format
        ...    names=${l2stream3_ttitrace_CNI131244_UL_part}    nr_phy_cell_ids=700
    ELSE IF    ${enb_instance} == ${enb_id}[1]     #TL383
        PA one cell 0 on and set other cell value 4 port for T348    cellid=${cell_id_348}[5]    set_value=${multi_gnb_PA}[0]
        Sleep    10s    reason=wait for PA adjust completely
        Start only UL traffic and check tput    ue_index=${1}    cellid=${4}    ue_type=${ue_type_qcom}    gnb_index=${0}
        ...                                tput_ul_cell=${expected_tput_ul_X70_small}    ul_throughput=${Send_Tput_UL_small}    duration=${7200}
        ...                                ul_port=${traffic_ul_port}
        Comment    adjust PA to 50db and capture TTI
        Capture Ttitrace With Admin Mode and adjust PA and Convert format
        ...    names=${l2stream3_ttitrace_CNI131244_UL_part}    nr_phy_cell_ids=700
    END
    Comment    analysis TTI report
    check_values_on_direction_ul
    ...    file_path=${epc_log_path}/${l2stream3_ttitrace_CNI131244_UL_part}_ul.csv
    ...    rnti=${SA_UE_RNTI_ID}
    ...    rank1_file_path=${CURDIR}/Resources/SINR_to_MCS_64QAM_Low_SE_with_RANK1_UL_PRB2_ABIP_CB013204_disabled.csv
    ...    rank2_file_path=${CURDIR}/Resources/SINR_to_MCS_64QAM_Low_SE_with_RANK2_UL_PRB2_ABIP_CB013204_disabled.csv
    ...    rank1_rank2_mcs_mapping=${CURDIR}/Resources/RANK1_to_RANK2_MCS_mapping.csv
    ...    num_prb=2
    [Teardown]     Stop DL or UL traffic    ue_index=${1}    ue_type=${ue_type_qcom}    direction=UL

Capture Ttitrace With Admin Mode and adjust PA and Convert format
    [Arguments]
    ...            ${names}=l2stream3_ttitrace
    ...            ${SW_BRANCH}=NULL
    ...            ${nr_phy_cell_ids}=NULL
    ...            ${gNB_index}=${0}
    ...            ${target_dir}=${epc_log_path}
    Start Ttitrace With Admin Mode    names=${names}    SW_BRANCH=${SW_BRANCH}    nr_phy_cell_ids=${nr_phy_cell_ids}    gNB_index=${gNB_index}
    IF    ${enb_instance} == ${enb_id}[0]     #TL348
        Change Attenuation value 4 port for multi PAs    cell=5Gcell${cell_id_348}[1]    value=${multi_gnb_PA_348}[1]
    ELSE IF    ${enb_instance} == ${enb_id}[1]     #TL383
        Change Attenuation value 4 port    cell=5Gcells${cell_id}[1]    value=${multi_gnb_PA_383}[1]
    END
    Sleep    5s
    Stop Ttitrace With Admin Mode    names=${names}      target_dir=${target_dir}
    Convert Ttitrace From Pcap To Excelcsv    names=${names}      target_dir=${target_dir}

PA one cell 0 on and set other cell value 4 port for T348
    [Arguments]    ${cellid}    ${set_value}=${0}    ${total_cell}=${6}
    IF    '${cellid}' == '5' or '${cellid}' == '6'
        Change Attenuation value 4 port for multi PAs    cell=5Gcell${cellid}    value=${set_value}    ip_addr=${att_ipaddr_1}
    ELSE
        Change Attenuation value 4 port for multi PAs    cell=5Gcell${cellid}    value=${set_value}    ip_addr=${att_ipaddr}
    END
    FOR  ${index}  IN RANGE   ${total_cell}
        ${cellnum} =    evaluate    ${index}+1
        IF    ('${cellid}' != '${cellnum}') and ('${cellnum}' == '5' or '${cellnum}' == '6')
            Change Attenuation value 4 port for multi PAs    cell=5Gcell${cellnum}    value=${127}    ip_addr=${att_ipaddr_1}
        ELSE IF    ('${cellid}' != '${cellnum}') and ('${cellnum}' != '5' or '${cellnum}' != '6')
            Change Attenuation value 4 port for multi PAs    cell=5Gcell${cellnum}    value=${127}    ip_addr=${att_ipaddr}
        END
    END

Change Attenuation value 4 port for multi PAs
    [Arguments]    ${cell}    ${value}    ${ip_addr}=${att_ipaddr}
    Set Programmable Attenuation Value for multi PAs    ports=${${cell}_ANT1}    value=${value}    ip_addr=${ip_addr}
    Set Programmable Attenuation Value for multi PAs    ports=${${cell}_ANT2}    value=${value}    ip_addr=${ip_addr}
    Set Programmable Attenuation Value for multi PAs    ports=${${cell}_ANT3}    value=${value}    ip_addr=${ip_addr}
    Set Programmable Attenuation Value for multi PAs    ports=${${cell}_ANT4}    value=${value}    ip_addr=${ip_addr}

Set Programmable Attenuation Value for multi PAs
    [Arguments]    ${ports}    ${value}    ${ip_addr}=${att_ipaddr}
    atten.setup_attenuator    ip_addr=${ip_addr}    port=${att_api_port}
    ...    attenuation_port_numbers=${ports}    max_attenuation=${max_attenuation_value}    vendor=${vendor}
    ...    model=${model}
    atten.set_attenuation     port=${ports}    value=${value}

PA one cell 0 on and set other cell value 4 port
    [Arguments]    ${cellid}    ${set_value}=${0}    ${total_cell}=${4}
    IF    ${cellid} == 4
        Change Attenuation value    cell=5Gcells${cellid}    value=${set_value}
    ELSE
        Change Attenuation value 4 port    cell=5Gcells${cellid}    value=${set_value}
    END
    FOR  ${index}    IN RANGE    ${total_cell}
        ${cellnum} =    evaluate    ${index}+1
        IF    '${cellid}'!='${cellnum}'
            IF    ${cellnum} == 4
                Change Attenuation value    cell=5Gcells${cellnum}    value=${127}
            ELSE
                Change Attenuation value 4 port    cell=5Gcells${cellnum}    value=${127}
            END
        END
    END
    Change Attenuation value 4 port    cell=4Gcells1    value=${127}

Change Attenuation value
    [Arguments]    ${cell}    ${value}
    Set the Attenuation Value    ports=${${cell}_ANT1}    value=${value}
    Set the Attenuation Value    ports=${${cell}_ANT2}    value=${value}
    Run Keyword If    '${cell}' == '5Gcell3'    Run Keywords
    ...    Set the Attenuation Value    ports=${${cell}_ANT3}    value=${value}
    ...    AND    Set the Attenuation Value    ports=${${cell}_ANT4}    value=${value}

Change Attenuation value 4 port
    [Arguments]    ${cell}    ${value}
    Set the Attenuation Value    ports=${${cell}_ANT1}    value=${value}
    Set the Attenuation Value    ports=${${cell}_ANT2}    value=${value}
    Set the Attenuation Value    ports=${${cell}_ANT3}    value=${value}
    Set the Attenuation Value    ports=${${cell}_ANT4}    value=${value}

Set the Attenuation Value
    [Arguments]    ${ports}    ${value}
    atten.setup_attenuator    ip_addr=${att_ipaddr}    port=${att_api_port}
    ...    attenuation_port_numbers=${ports}    max_attenuation=${max_attenuation_value}    vendor=${vendor}
    ...    model=${model}
    atten.set_attenuation     port=${ports}    value=${value}

recover paras and PA values for L05
    IF    ${enb_instance} == ${enb_id}[0]     #TL348
        Change Attenuation value 4 port for multi PAs    cell=5Gcell${cell_id_348}[1]    value=${multi_gnb_PA}[1]
    ELSE IF    ${enb_instance} == ${enb_id}[1]     #TL383
        Change Attenuation value 4 port for multi PAs    cell=5Gcell${cell_id_348}[1]    value=${multi_gnb_PA}[1]
    END