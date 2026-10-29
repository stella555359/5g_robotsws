# *** Settings ***
# Force Tags    PY36
# Documentation
# ...    author: liujia
# ...    contact: jia-rebecca.liu@nokia-sbell.com
# ...    squad group: SG_03
# ...    feature : 5GC002200
# 
# 
# 
# Suite Setup         Run keywords
# ...    robot_common_operations.Common Suite Setup    AND
# ...    Run Keyword And Ignore Error       Common Suite Setup for COAM 2200
# 
# Suite Teardown      Run keywords
# ...    robot_common_operations.Common Suite Teardown    AND
# ...    Run Keyword And Ignore Error       Common Suite Teardown for COAM
# 
# Resource       Resources/5GC002200_coam_common_keywords.robot
# 
# 
# *** Variables ***
# ${golden_scf_Trunk}      MRBTS-10175_TL365_golden_scf.xml
# ${golden_scf_23R2}       MRBTS-10175_TL365_golden_scf_23R2.xml
# ${golden_scf_23R3}       MRBTS-10175_TL365_golden_scf_23R3.xml
# ${golden_scf_23R4}       MRBTS-10175_TL365_golden_scf.xml
# ${ASKEY_DL_PORT}             ${ue_param['data_transfer']['iperf_options']['qci'][5]}
# ${Send_Tput_DL}         1500M
# ${TL365_enbx2_dist}    MRBTS-${enb_instance}/LNBTS-${enb_instance}/LNADJGNB-1
# ${enb_cell_status}    administrativeState
# ${Expect_good_Tput}       1000
# ${ulexpect}         0
# ${Expect_compare_Tput}       10
# ${Expect_Control_Tput}        500
# ${B001_nglog}    2200_B001_nglog
# ${enbx2_TL365}    MRBTS-${tl.enbs[0].instance_id}/LNBTS-${tl.enbs[0].instance_id}/LNCEL-1
# ${att_value_TRUNK}          20
# ${TS_CASE_LOG_PATH}         ${LOG_PATH}
# ${biplog_01}       2200_E005_BIP001.pcap
# ${biplog_02}       2200_E006_BIP001.pcap
# ${LUA_SCRIPT_PATH_21A}    /opt/workspace/generated_luashark_21A/luashark.lua
# ${btslog}    SYSLOG_*
# ${ue_num}    8
# ${data_tranfer}        1Mbits/sec
# ${dltp}     50
# ${ultp}     1
# ${begin_port}        1
# ${end_port}        16
# ${get_tti_name}     ls -l | grep *.dl__all.csv |awk '{print $9}'
# ${dl_tput_multiue_365}          450M
# ${dl_tput_multiue_374}          700M
# 
# 
# ##trunk test on TL365##
# 
# *** Test Cases ***
# [1]5GC002200_B_001_cell_setup_success_with_64TRX_RU_when_feature_enable_with_4_resources_SA
#     [Documentation]
#     ...    this test case is to verify Multi UEs can attach with 4 csirs resource.
#     [Tags]      classical    CRT_TRUNK
#     [Setup]    robot_common_operations.Common Case Setup
#     test suite variable set for 2200_B_001
#     Common Case TestLine Setup    ModifySCF_Beforecommission=True    Is_Swconfig=True     Lock_ENB_Need=True
#     ...                           swconfig_file=${swconfig}    golden_scf_name=${${golden_scf_name}}
#     ...                           enb_dist_name=${ENB_cell1_dist}
#     ...                           enb_parameter=${enb_cell_admin}
#     ...                           enb_value=locked
#     Set nrcellid suit varaible    cellid=${1}
#     Set HAOJIN MCS ON Trunk     att_value=${att_value_TRUNK}
#     Prepare MultiUE with client
#     ${cpif_log_01}    attach multiUEs and capture wiresharklog    wiresharklog=${B001_nglog}
#     set test variable    ${cpif_log_01}
#     HAOJIN MCS SETUP AND SET ATT for Two UEs with different ATT     mcs_type=${mcs_type}
#     ...    att_value_UE0_1=${30}    att_value_UE0_2=${90}    att_value_UE1_1=${30}    att_value_UE1_2=${90}
#     ...    P1_out=${13}    P2_out=${14}    P3_out=${15}    P4_out=${16}
#     ...    vertical_1=${101}    horizontal_1=${45}     vertical_2=${101}    horizontal_2=${40}
#     ...    P5_out=${9}     P6_out=${10}    P7_out=${11}    P8_out=${12}
#     ...    vertical_3=${96}     horizontal_3=${-35}    vertical_4=${96}     horizontal_4=${-25}
#     Start multiUEs traffic with appserver    dl_tput_multiue=${${dl_tput_multiue}}    UE_define=2
#     Capture tti trace from Gnb logs    output_match=finished    BBMOD=1
#     Get tti trace from gnb logs tool    tti_logs_rename=gnb_logs_TTI00
#     Analysis tti file    tti_logs_rename=gnb_logs_TTI00
#     Analysis B001 ng log
#     [Teardown]    Run Keywords
#     ...    stop traffic and MCS teardown with new way    mcs_type=${mcs_type}
#     ...    AND    robot_common_operations.Common Case Teardown
#     ...    AND    Run Keyword And Ignore Error     Tests Recover
# 
# *** Keywords ***
# Tests Recover
#     Connect and Modify the parameter on enblte    dist_name=${enbx2_TL365}    parameter=${enb_cell_status}    value=unlocked
#     Run Keyword And Ignore Error    HAOJIN MCS SETUP AND SET ATT for Two UEs    mcs_type=${mcs_type}    att_value_UE0=${25}    att_value_UE1=${90}
#     ...    P1_out=${13}    P2_out=${14}    P3_out=${15}    P4_out=${16}
#     ...    vertical_1=${96}    horizontal_1=${15}     vertical_2=${96}    horizontal_2=${25}
#     ...    P5_out=${9}     P6_out=${10}    P7_out=${11}    P8_out=${12}
#     ...    vertical_3=${96}     horizontal_3=${-30}    vertical_4=${96}     horizontal_4=${-35}
#     disconect all connections
# 
# Analysis B001 ng log
#     ${all_packets}=    cap.load_pcap_file    pcap_file=${cpif_log_01}    tshark_path=${tshark_path}
#     ...    command_template=${None}
#     ${filter_expression}=    Catenate    nr-rrc.rrcReconfiguration_element &&
#     ...                                  nr-rrc.csi_MeasConfig == 1
#     ${filtered_packets}=    cap.filter_packets_by_expression    filter_expression=${filter_expression}
#     ${nrofPorts}=    cap.get_field_value_by_xpath    pdml_list=${filtered_packets}    xpath=.//nr-rrc.nrofPorts
#     should contain X times    ${nrofPorts}    3    32
#     ${cdm_Type}=    cap.get_field_value_by_xpath    pdml_list=${filtered_packets}    xpath=.//nr-rrc.cdm_Type
#     should contain    ${cdm_Type}    2
#     ${n1-n2}=    cap.get_field_value_by_xpath    pdml_list=${filtered_packets}    xpath=.//nr-rrc.n1_n2
#     should contain    ${n1-n2}    1
# 
# Analysis tti file
#     [Arguments]    ${tti_logs_rename}=${tti_logs_rename}    ${epc_log_path}=${epc_log_path}
#     log to console    analysis tti file from Case_Logs file...
#     csn.Connect to    hostname=${TestPC_addr}    username=${TestPC_username}    password=${TestPC_password}    alias=ute
#     csn.send command    command=cd ${epc_log_path}/${tti_logs_rename}/L2_trace/tti_packed/&&${get_tti_name}
#     ...                 connection=ute
#     ${tti_dl_file}=    csn.Read Output    connection=ute
#     @{tti_file_name}    String.split string    string=${tti_dl_file}    separator=\n
#     ${paired_count}    read_mumimo_rank2_paired    ${epc_log_path}${tti_logs_rename}/L2_trace/tti_packed/@{tti_file_name}[0]
#     should be true      ${paired_count} > 2
# 
# Set HAOJIN MCS ON Trunk
#     [Arguments]    ${att_value}
#     ${mcs_type}=    mcs_common.Get MCS Type
#     set suite variable      ${mcs_type}
#     HAOJIN MCS SETUP AND SET ATT for Two UEs    mcs_type=${mcs_type}    att_value_UE0=${att_value}    att_value_UE1=${att_value}
#     ...    P1_out=${13}    P2_out=${14}    P3_out=${15}    P4_out=${16}
#     ...    vertical_1=${101}    horizontal_1=${50}     vertical_2=${101}    horizontal_2=${40}
#     ...    P5_out=${9}     P6_out=${10}    P7_out=${11}    P8_out=${12}
#     ...    vertical_3=${96}     horizontal_3=${-35}    vertical_4=${96}     horizontal_4=${-25}
# 
