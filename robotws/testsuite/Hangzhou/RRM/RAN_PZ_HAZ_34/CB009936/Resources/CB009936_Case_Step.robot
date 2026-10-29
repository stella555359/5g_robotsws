*** Settings ***
Documentation    Author:jia-rebecca.liu@nokia-sbell.com


Resource         ./CB009936_Common_Keywords.robot






*** Keywords ***
#####--------------------------------CB008830_test_step---------------------------------#####
attach_capture_wireshark_bip_and_return_tupt
    [Arguments]    ${wiresharklog}    ${dl_throughput}    ${biplog_file_name}    ${dl_expect_tput}
#    dingli_UE_attach_WA
    ${wiresharklog_attach}    ${upd_info}    UE attach and capture wiresharklog    wiresharklog=${wiresharklog}
    Start MUE dltraffic with appserver    ue_addr=${upd_info}[Param][IP]     dl_port=${DL_PORT_dingli}    dl_throughput=${dl_throughput}
    sleep    30s
    Collect Interface Mirroring Bip Collector from WEBUI    target_dir=${epc_log_path}    times=5s
    ...                                                     target_file_name=${biplog_file_name}
    ${tput_value}     check_dingli_UE0_tput_aasyslog    expect_tput=${dl_expect_tput}
    ${biplog_file}    Get Bip Log Via Interface Mirroring Collector to UTE    target_dir=${epc_log_path}
    ...                                                                       target_file_name=${biplog_file_name}
    [Return]     ${wiresharklog_attach}    ${tput_value}    ${biplog_file}[0]


MTK_attach_and_capture_wireshark_start_uldl_traffic
    [Arguments]    ${wiresharklog1}   ${wiresharklog2}    ${MTK_DL_traffic}    ${MTK_UL_traffic}
    ...            ${gNB_index}=${0}
    ${wiresharklog_attach}    MTK UE attach and capture wiresharklog    wiresharklog=${wiresharklog1}
    Start capture gNB log on master    filename=${wiresharklog2}   gNB_index=${gNB_index}
    Start DL and UL traffic for MTK80    get_ip_from_wireshark=${wiresharklog1}
    ...                                  dl_data_transfer=${MTK_DL_traffic}
    ...                                  ul_throughput=${MTK_UL_traffic}
    Start capture gNB log on master    filename=${wiresharklog2}   gNB_index=${gNB_index}
    ${DL_tput_1}    ${UL_tput_1}    Check ul_dl_tput for MTK80 and return    duration=60
    ${wiresharklog_tput}    Stop and download the wiresharklog from master    filename=${wiresharklog2}    gNB_index=${gNB_index}
    [Return]    ${wiresharklog_attach}    ${DL_tput_1}    ${UL_tput_1}    ${wiresharklog_tput}

MTK_start_VC_and_capture_wireshark
    [Arguments]     ${wiresharklog3}     ${ue_index}=${8}    ${gNB_index}=${0}
    Start capture wireshark log on master     filename=${wiresharklog3}    gNB_index=${gNB_index}
    log to console    \n start vonr call \n
    Make Vonr Call With Command    ue_index=${ue_index}
    sleep    5s
    ${DL_tput_2}    ${UL_tput_2}    Check ul_dl_tput for MTK80 and return    duration=60
    ${CB008830_C1001_vonr}    Stop and download the wiresharklog from master    filename=${wiresharklog3}    gNB_index=${gNB_index}
    Check VONR setup from wireshark log    file_path=${CB008830_C1001_vonr}
    [Return]    ${CB008830_C1001_vonr}    ${DL_tput_2}    ${UL_tput_2}

MTK_hangup_VC_and_capture_wireshark
    [Arguments]     ${wiresharklog4}    ${ue_index}=${8}    ${gNB_index}=${0}
    Start capture wireshark log on master     filename=${wiresharklog4}    gNB_index=${gNB_index}
    log to console    \n stop vonr call \n
    Hang Up Vonr Call With Command        ue_index=${ue_index}
    ${DL_tput_3}    ${UL_tput_3}    Check ul_dl_tput for MTK80 and return    duration=60
    [Teardown]    Stop and download the wiresharklog from master    filename=${wiresharklog4}    gNB_index=${gNB_index}
    [Return]      ${cpif_log_path}    ${DL_tput_3}    ${UL_tput_3}


check_point_CB008830_C1001
    [Arguments]    ${wiresharklog_01}    ${wiresharklog_03}    ${wiresharklog_04}
    ####--attch_log_check ue support type2--####
    check dmrs_supported from wireshark    file_path=${wiresharklog_01}
    ####--start_vonr_check type1--####
    ${no_type2_exist}    run keyword and return status    check dmrs_type from wireshark    file_path=${wiresharklog_03}
    Should Be True      '${no_type2_exist}' == 'False'
    ####--hangup_check change to type2--####
    check dmrs_type from wireshark    file_path=${wiresharklog_04}


MultiUE0_attach_and_capture_wireshark_start_uldl_traffic
    [Arguments]    ${wiresharklog1}   ${wiresharklog2}    ${dingli_dl_traffic}    ${dingli_ul_traffic}
    ...            ${gNB_index}=${0}
    ${wiresharklog_attach}    UE attach and capture wiresharklog    wiresharklog=${wiresharklog1}
    Start capture gNB log on master    filename=${wiresharklog2}   gNB_index=${gNB_index}
    Start MUE dltraffic with appserver      ue_addr=${upd_info}[Param][IP]     dl_port=${DL_PORT_dingli}    dl_throughput=${dingli_dl_traffic}
    Start dingli_UE UL Data Transfer    ul_throughput=${dingli_ul_traffic}
    ${DL_tput_1}    ${UL_tput_1}    Check ul_dl_tput for dingli_UE and return    duration=60
    ${wiresharklog_tput}    Stop and download the wiresharklog from master    filename=${wiresharklog2}    gNB_index=${gNB_index}
    [Return]    ${wiresharklog_attach}    ${DL_tput_1}    ${UL_tput_1}    ${wiresharklog_tput}

dingliUE_start_vonr_and_capture_wireshark
    [Arguments]     ${wiresharklog3}    ${gNB_index}=${0}
    Start capture wireshark log on master     filename=${wiresharklog3}    gNB_index=${gNB_index}
    log to console    \n start vonr call \n
#    Make Vonr Call With Command    ue_index=${ue_index}
    start dingli_UE Voice_Call    ue=${uegroup}[0]    call_number=6688    longcall=${True}
    sleep    5s
    ${DL_tput_2}    ${UL_tput_2}    Check ul_dl_tput for dingli_UE and return    duration=60
    ${CB008830_C1001_vonr}    Stop and download the wiresharklog from master    filename=${wiresharklog3}    gNB_index=${gNB_index}
    Check VONR setup from wireshark log    file_path=${CB008830_C1001_vonr}
    [Return]    ${CB008830_C1001_vonr}    ${DL_tput_2}    ${UL_tput_2}

dingliUE_hangup_vonr_and_capture_wireshark
    [Arguments]     ${wiresharklog4}      ${gNB_index}=${0}
    Start capture wireshark log on master     filename=${wiresharklog4}    gNB_index=${gNB_index}
    log to console    \n stop vonr call \n
    stop dingli_UE Voice_Call    ue=${uegroup}[0]
    ${DL_tput_3}    ${UL_tput_3}    Check ul_dl_tput for dingli_UE and return    duration=60
    [Teardown]    Stop and download the wiresharklog from master    filename=${wiresharklog4}    gNB_index=${gNB_index}
    [Return]      ${cpif_log_path}    ${DL_tput_3}    ${UL_tput_3}

MCS set ATT only with MCS_type
    [Arguments]    ${att_value_hbte}=${55}    ${att_value_hj}=${40}
    Run keyword if    '${mcs_type}'=='hbte'    HBTE SET Four Output Ports With Different Values    mcs_type=${mcs_type}
    ...                                        att_value1=${att_value_hbte}   att_value2=${att_value_hbte}
    ...                                                  first_beam_begin_output_port=${1}     first_beam_end_output_port=${2}
    ...                                                  second_beam_begin_output_port=${3}    second_beam_end_output_port=${4}
    Run keyword if    '${mcs_type}'=='haojin'     HAOJIN MCS SETUP AND SET ATT for Two UEs with different ATT    mcs_type=${mcs_type}
    ...    att_value_UE0_1=${att_value_hj}    att_value_UE0_2=${att_value_hj}
    ...    att_value_UE1_1=${90}    att_value_UE1_2=${90}
    ...    P1_out=${13}    P2_out=${14}    vertical_1=${96}    horizontal_1=${5}
    ...    P3_out=${15}    P4_out=${16}    vertical_2=${96}    horizontal_2=${15}
    ...    P5_out=${9}     P6_out=${10}    vertical_3=${96}    horizontal_3=${-5}
    ...    P7_out=${11}    P8_out=${12}    vertical_4=${96}    horizontal_4=${-15}


