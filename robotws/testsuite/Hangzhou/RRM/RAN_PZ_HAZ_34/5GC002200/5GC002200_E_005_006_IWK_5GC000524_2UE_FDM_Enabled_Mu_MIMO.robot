# # #*** Settings ***
# # #Force Tags    PY36
# # #Documentation
# # #...    author: kk
# # #...    contact: kk.wang@nokia-sbell.com
# # #...    squad group: SG_03
# # #...    feature : 5GC002200
# # #
# # #Suite Setup    Run Keywords    Common Suite Setup for COAM
# # #
# # #Suite Teardown      Run Keyword And Ignore Error     Common Suite Teardown for COAM
# # #
# # #Resource       Resources/5GC002200_coam_common_keywords.robot
# # #Resource       Resources/HAOJIN_MCS_common_keywords.robot
# # #Resource       Resources/TOPYOUNG_MCS_common_keywords.robot
# # #Resource       Resources/btslog_collecting.robot
# # #Variables      Resources/variables.py
# # #Library        Resources/csv_analysis_mumimo.py
# # #
# # #*** Variables ***
# # #${TL365_Trunk_scf_enable2200}           TL365_Trunk_GNB_2200_Enable_E005_SA.xml
# # #${TL365_21B_scf_enable2200}           TL365_21B_GNB_2200_Enable_E005_SA.xml
# # #${TL365_22R1_scf_enable2200}           TL365_22R1_GNB_2200_Enable_E005_SA.xml
# # #${swconfig}                 /opt/workspace/SCF/2200/swconfig/2200_E/swconfig.txt
# # #${Send_Tput_DL}         1500M
# # #${TL365_enbx2_dist}    MRBTS-${enb_instance}/LNBTS-${enb_instance}/LNADJGNB-1
# # #${enb_cell_status}    administrativeState
# # #${Expect_good_Tput}       1000
# # #${ulexpect}         0
# # #${dlexpect}         10
# # #${Multi_dl_throughput}      30Mbits/sec
# # #${Expect_compare_Tput}       200Mbits/sec
# # #${Expect_Control_Tput}        500
# # #${E005_nglog_good}    2200_E005_nglog_good.pcap
# # #${enbx2_TL365}    MRBTS-${tl.enbs[0].instance_id}/LNBTS-${tl.enbs[0].instance_id}/LNCEL-1
# # #@{att_value}         5    70    90    127
# # #${TS_CASE_LOG_PATH}         ${LOG_PATH}
# # #${get_tti_name}     ls -l | grep *.dl__all.csv |awk '{print $9}'
# # #${ue_num}    2
# # #@{TL362_dl_enable}                 20    600
# # #@{TL365_dl_enable}                 20    100
# # #@{TL370_dl_enable}                 20    20
# # #
# # ###trunk test on TL365; 21A test on TL365##
# # #
# # #*** Test Cases ***
# # #[1]5GC002200_E_005_IWK_5GC000524_2UE_FDM_Enabled_Mu_MIMO_SA
# # #    [Documentation]
# # #    ...    this test case is to verify interworking MU-MIMO with 2200 enable.
# # #    ...    Add CNI74278_A_10_SA_2UE_paired_with_4CSI-RS_4x1_#2#1#1wT_2_2_4_BW_100M_1116 case check points in 21B;
# # #    ...     tmpParam9=555; UE config with 4 CSI-RS, and n1-n2 is 4X1;
# # #    ...     two UEs can paired with the right beamweight. beamset=(4+2+1)x(4+16)=140;
# # #    [Tags]      classical    CRT_21A    CRT_TRUNK    CRT_21B    CRT_22R1    CRT_22R2
# # #    [Setup]
# # #    Case variable set for 2200_E_005
# # #    Prepare testline to cell onair for SA    localFilePath=${swconfig}    tl_scf_filename=${${scf_enable2200}}
# # #    Connect and Modify the parameter on enblte    dist_name=${enbx2_TL365}    parameter=${enb_cell_status}    value=locked
# # #    Set HAOJIN MCS ON TL365    9    16    0
# # #    Set nrcellid suit varaible    cellid=${${nrcellid}}
# # #    wait until keyword succeeds    2min    10s     Start To Capture Wireshark Logs On ASIB   filename=${E005_nglog_good}
# # #    Multi-UEs attach and Data Transfer    ue_num=${ue_num}    attach_mode=${SA_attach_mode}   ue_mode=${SA_UE_MODE}
# # #    ...    nettpye=${SA_nettype}    apn_address=${SA_apn_addr}
# # #    Stop And Download Wireshark Logs On ASIB    logname=${E005_nglog_good}
# # #    Analysis E005 ng log
# # #    Check beamweight for CNI74278    beamweight_name=${${beamweight_name}}    connection=gnb    beamset_num=140
# # #    Set HAOJIN Begin_Port to End_Port ATT    9    12    40
# # #    Set HAOJIN Begin_Port to End_Port ATT    13    16    40
# # #    Capture tti trace from Gnb logs
# # #    Get tti trace from gnb logs tool
# # #    Analysis tti file
# # #    Power UE check throughput with nrcellid    cellid=${${nrcellid}}    dlexpect=${@{${Expect_dl_enable}}[0]}
# # #    MCS teardown    mcs_alias=${${mcs_alias}}
# # #    [Teardown]    Run Keyword And Ignore Error     Tests Recover
# # #
# # #*** Keywords ***
# # #Tests Recover
# # #    Run Keyword And Ignore Error    Multi UE Detach And Stop Traffic
# # #    Connect and Modify the parameter on enblte    dist_name=${enbx2_TL365}    parameter=${enb_cell_status}    value=unlocked
# # #    MCS teardown    mcs_alias=${${mcs_alias}}
# # #    disconect all connections
# # #
# # #
# # #Analysis tti file
# # #    [Arguments]    ${tti_logs_rename}=${tti_logs_rename}    ${epc_log_path}=${epc_log_path}
# # #    log to console    analysis tti file from Case_Logs file...
# # #    csn.Connect to    hostname=${TestPC_addr}    username=${TestPC_username}    password=${TestPC_password}    alias=ute
# # #    csn.send command    command=cd ${epc_log_path}/${tti_logs_rename}/tti_packed/fsp-1a-L2RT20_ttiTrace/&&${get_tti_name}
# # #    ...                 connection=ute
# # #    ${tti_dl_file}=    csn.Read Output    connection=ute
# # #    @{tti_file_name}    String.split string    string=${tti_dl_file}    separator=\n
# # #    ${paired_count}    read_mumimo_rank2_paired    ${epc_log_path}${tti_logs_rename}/tti_packed/fsp-1a-L2RT20_ttiTrace/@{tti_file_name}[0]
# # #    should be true      ${paired_count} > 2
# # #
# # #Analysis E005 ng log
# # #    ${all_packets}=    cap.load_pcap_file    pcap_file=${epc_log_path}${E005_nglog_good}    tshark_path=${tshark_path}
# # #    ...    command_template=${None}
# # #    ${filter_expression}=    Catenate    f1ap.procedureCode == 5
# # #    ${filtered_packets}=    cap.filter_packets_by_expression    filter_expression=${filter_expression}
# # #    ${nrofPorts}=    cap.get_field_value_by_xpath    pdml_list=${filtered_packets}    xpath=.//nr-rrc.nrofPorts
# # #    should contain X times    ${nrofPorts}    3    8
# # #    ${cdm_Type}=    cap.get_field_value_by_xpath    pdml_list=${filtered_packets}    xpath=.//nr-rrc.cdm_Type
# # #    should contain    ${cdm_Type}    2
# # #    ${n1-n2}=    cap.get_field_value_by_xpath    pdml_list=${filtered_packets}    xpath=.//nr-rrc.n1_n2
# # #    should contain    ${n1-n2}    2
# # #
# # #Set HAOJIN MCS ON TL365
# # #    [Arguments]    ${begin_port}    ${end_port}    ${att_value}
# # #    HAOJIN MCS Prepare    ip=${haojin_ip_365}
# # #    Set HAOJIN horizontal and vertical Phases by output_port    begin_output_port=${9}    end_output_port=${10}    input_group_id=${0}
# # #    ...    vertical_angle=${96}    horizontal_angle=${-35}    vertical_distance=${2.1}    horizontal_distance=${0.5}    mcs_alias=HJ
# # #    sleep  3s
# # #    Set HAOJIN horizontal and vertical Phases by output_port    begin_output_port=${11}    end_output_port=${12}    input_group_id=${0}
# # #    ...    vertical_angle=${96}    horizontal_angle=${-25}    vertical_distance=${2.1}    horizontal_distance=${0.5}    mcs_alias=HJ
# # #    sleep  3s
# # #    Set HAOJIN horizontal and vertical Phases by output_port    begin_output_port=${13}    end_output_port=${14}    input_group_id=${0}
# # #    ...    vertical_angle=${101}    horizontal_angle=${50}    vertical_distance=${2.1}    horizontal_distance=${0.5}    mcs_alias=HJ
# # #    sleep  3s
# # #    Set HAOJIN horizontal and vertical Phases by output_port    begin_output_port=${15}    end_output_port=${16}    input_group_id=${0}
# # #    ...    vertical_angle=${101}    horizontal_angle=${40}    vertical_distance=${2.1}    horizontal_distance=${0.5}    mcs_alias=HJ
# # #    sleep  3s
# # #    Set HAOJIN Begin_Port to End_Port ATT    begin_port=${begin_port}    end_port=${end_port}    att_value=${att_value}
