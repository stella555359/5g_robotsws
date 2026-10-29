*** Settings ***
Documentation    Auther:liyu.li@nokia-sbell.com
...              feature CB008423 AWHQE keyword

Resource    testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/lines/SG6/Resources.robot
Resource    ../../common/BIP.robot
Resource    taf/rfrl/common_resources/robot/coam_selenium.robot
Resource    taf/rfrl/common_resources/robot/connection_alias_store.robot
Resource    testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/robot/coam_gnb_classical.robot
Resource    testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/robot/coam_siso_common.robot
Resource    testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/robot/traffic_via_iperf.robot
Resource    testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/robot/container_log_capturing.robot
Resource    testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/robot/check_android_ue_l3_call_process.robot
Resource    testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/robot/BIP_trace/BIP_trace_collector.robot
Resource    testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/robot/power_ue/power_ue.robot
Library    taf.analyzer.pcap    WITH NAME    pcap
Resource    testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/robot/CI_Operations/CI_interface.robot


*** Variables ***
${MRBTS_ID}    ${tl.gnbs[0].instance_id}
${NRBTS_ID}    ${tl.gnbs[0].global_bts_id}
${SCF_path}    /home/ute/SCF
${SCF_0ms}    Configuration_Classical_gNB_100M_1116_0ms.xml


*** Keywords ***
8423 Common Suite Setup
    Common_setup_and_teardown.Common Suite Setup    is_commission=False
    ...                                             scf_name=Configuration_Classical_gNB_100M_1116_0ms.xml

8423 Common Suite Teardown
    Connect to gnb coam via ssl    connection=GNB_OAM   gnb_index=${0}
    COAM Commission with scf file    scf_file_path=/home/ute/SCF/SCF_SBTS00_2S-1CC-2D-2U.xml
    ...                              connection=GNB_OAM0
    ...                              timeout=900
    ...                              is_pdl_checking_needed=${True}
    [Teardown]    Run Keyword And Ignore Error    COAM Teardown gnb connections    connection=${connection}

8423 Common Case Setup
    [Arguments]    ${framestructure}=${None}    ${scf_name}=${None}    ${is_commission}=True
#    ${stream_version}    gnb_classical_hangzhou.Get program version based on stream version
    ${stream_version}    Common_setup_and_teardown.Get Active SW Version Based On Stream Version
    ${scf_file_path}    Set Variable    ${SCF_path}/${stream_version}_${SCF_0ms}
    ${update_scf_with_2197}    Generate Commission File With Chbw Framestructure Dynamic Pdcch    framestructure=${framestructure}
    ...                                                                                           scf_file_path=${scf_file_path}
    ${scf_name}    Set Variable    ${update_scf_with_2197.split('/')[-1]}
    Common_setup_and_teardown.Common Case Setup    is_commission=True
    ...                                            scf_name=${scf_name}
    ...                                            is_commission=${is_commission}

8423 Common Case Teardown
    [Arguments]    ${connection}=GNB_OAM
    Connect to gnb coam via ssl    connection=${connection}    gnb_index=${0}
    Run Keyword And Continue On Failure    Unexpect Alarm Should Not Exist   allowed_faults=${ALLOWED_FAULT}    connection=${connection}
    Common_setup_and_teardown.Common Case Teardown    is_save_snapshot=False    connection=${connection}

8423 Common case procedure
    [Documentation]    Auther:liyu.li@nokia-sbell.com
    [Arguments]    ${mode}=SA    ${coam_connection}=GNB_OAM
    ...             ${target_avg_percent}=0.9
    ...             ${min_DL_percent}=0.85    ${min_UL_percent}=0.85
    ...             ${dl_data_transfer}=600M    ${ul_data_transfer}=30M
    ...             ${dl_tput}=560M    ${ul_tput}=23M
    ...             ${gnb_index}=0    ${ue_index}=0    ${du_index}=0
    ...             ${duration}=240    ${ignore_time}=1min
    ...             ${ue_iperf_path}=/data/local/tmp/iperf
    ...             ${prachconfigind_exp}=156
    ${attach_info}    Start UE Attach With MTK    wireshark_log_prefix=attach
    ...                                           sleep_interval=60 sec
    ...                                           coam_connection=${coam_connection}
    ...                                           gnb_index=${gnb_index}
    ...                                           mode=${mode}
    log to console    ${attach_info}

    ${prachconfigind}    Get PrachConfiInd form RRCsetup    cpif_log_path=${attach_info['cpif_log_path']}
    ${prachconfigind_act}    Set Variable    ${prachconfigind[0]}
    Run Keyword And Continue On Failure     Should Be Equal    ${prachconfigind_act}
    ...                                                        ${prachconfigind_exp}
    ...                                                        msg=PrachConfigurationIndex abnormal.


    Start Bip Capture    gnb_index=${gnb_index}    is_capture_right_bbmod=${False}
    Start L3 Call Data Transfer    ul_data_transfer=${ul_data_transfer}
    ...                            dl_data_transfer=${dl_data_transfer}
    ...                            duration=${duration}
    ...                            need_get_ue_ip=${True}
    ...                            cpif_log_path=${attach_info['cpif_log_path']}
    ...                            ue_iperf_path=${ue_iperf_path}
    ...                            is_multi_pdu=${True}
    Sleep   2sec
    ${bip_log_list}    Stop Bip Capture   log_prefix=bip    gnb_index=${gnb_index}    is_capture_right_bbmod=${False}
    ...                                   asib_interface=eths3
    ${direction_component_list}   Create List    UL_L2LO    DL_L2LO
    Sleep    10sec
    ${expect_ul_tput}   Evaluate    float(${ul_tput.split('M')[0]})
    ${expect_dl_tput}   Evaluate    float(${dl_tput.split('M')[0]})
    Run Keyword And Continue On Failure    Check Tput With Power UE
    ...     cellid=${attach_info['attach_cell_index']}
    ...     direction_component_list=${direction_component_list}
    ...     expect_ul_tput=${expect_ul_tput}
    ...     expect_dl_tput=${expect_dl_tput}
    ...     target_avg_percent=${target_avg_percent}
    ...     duration=120
    ...     is_ulbler_calcu=${False}
    Check 2538 in BIP   bip_log_path=${bip_log_list[0]}
    [Teardown]    Run Keywords    Run Keyword And Ignore Error    Do UE Detach    ue_index=${0}    AND
    ...                           Run Keyword And Ignore Error    Stop BIP capture on ASIK if needed and download BIP Logs to testPC
    ...                                                           connection=ASIK Master
    ...                                                           log_prefix=bip
    ...                                                           asib_interface=eths3

Get PrachConfiInd form RRCsetup
    [Documentation]    Auther:liyu.li@nokia-sbell.com
    [Arguments]    ${cpif_log_path}    ${message_filter_expression}=nr-rrc.rrcSetup_element    ${alias}=parser
    Convert CPIF Pcap To Pdml    file_path=${cpif_log_path}    filter=${message_filter_expression}
    ${prachconfigind}    pcap.get_field_value_by_xpath    xpath=.//nr-rrc.prach_ConfigurationIndex
    ...    pcap_parser=${alias}
    [Return]    ${prachconfigind}

Check 2538 in BIP
    [Documentation]    Auther:liyu.li@nokia-sbell.com
    [Arguments]    ${bip_log_path}    ${alias}=parser
    Convert Bip Pcap To Pdml    file_path=${bip_log_path}    filter=dldata_ssblocksendreq    alias=${alias}
    ${ssblocksfn}    pcap.get_field_value_by_name    field_name=DlData_SsBlockSendReq.SsBlockSendReq.sfn
    ...                                              pcap_parser=${alias}

    ${pdschsfn}    Set Variable    ${ssblocksfn[0]}
    ${filter_expression}    Catenate    DlData_PdschSendReq.PdschSendReq.sfn == ${ssblocksfn[0]} && DlData_PdschSendReq.PdschSendReq.slot == 0

    Convert Bip Pcap To Pdml    file_path=${bip_log_path}    filter=${filter_expression}    alias=${alias}
    ${pdschsfn_to_check}    pcap.get_field_value_by_name    field_name=DlData_PdschSendReq.PdschSendReq.sfn
    ...                                                     pcap_parser=${alias}
    Should Not Be Empty    ${pdschsfn_to_check}

8423 VoNR procedure
    [Documentation]    Auther:liyu.li@nokia-sbell.com
    [Arguments]    ${gnb_index}=0
    ...             ${mode}=SA
    ...             ${coam_connection}=GNB_OAM
    ...             ${ue_index}=0
    ...             ${du_index}=0
    ${attach_info}    Start UE Attach With MTK    wireshark_log_prefix=attach
    ...                                           sleep_interval=60 sec
    ...                                           coam_connection=${coam_connection}
    ...                                           gnb_index=${gnb_index}
    ...                                           mode=${mode}
    ...                                           ue_index=${ue_index}
    log to console    ${attach_info}
    CPIF Capture    gnb_index=${gnb_index}    du_index=${du_index}
    Make Vonr Call    ue_index=${ue_index}
    Sleep    30sec
    Hang Up Vonr Call    ue_index=${ue_index}
    Sleep    30sec
    ${wireshark_log_path_on_testPC}    Stop CPIF Capture
    Check VoNR Call Success    log_path=${wireshark_log_path_on_testPC}
    [Teardown]    Run Keyword And Ignore Error    Do UE Detach    ue_index=${ue_index}

CPIF Capture
    [Documentation]    Auther:liyu.li@nokia-sbell.com
    [Arguments]    ${wireshark_log_prefix}=call
    ...             ${connection}=ASIK Master
    ...             ${gnb_index}=0
    ...             ${du_index}=0
    ...             ${coam_connection}=GNB_OAM
    ...             ${wireshark_capture_interface}=-i any '((sctp) and ((port 38472) or (port 38412)or (port 38462)or (port 36422)))' -s 0
    Run Keyword And Continue On Failure    Start CP-IF Log Collection    tcpdump_collector_name=${wireshark_log_prefix}
    ...                                                                  asik_connection_alias=${connection}
    ...                                                                  gnb_index=${gnb_index}
    ...                                                                  du_index=${du_index}
    ...                                                                  options=${wireshark_capture_interface}

Stop CPIF Capture
    [Documentation]    Auther:liyu.li@nokia-sbell.com
    [Arguments]    ${wireshark_log_prefix}=call
    ...             ${log_dir_ute}=${TS_CASE_LOG_PATH}
    ${wireshark_log_path_on_testPC}    Run Keyword And Continue On Failure    Stop tcpdump log collection
    ...    tcpdump_collector_name=${wireshark_log_prefix}    target_dir=${log_dir_ute}
    [Return]     ${wireshark_log_path_on_testPC}
    [Teardown]    Run Keywords    Run Keyword And Ignore Error    core.stop_collectors    names=${wireshark_log_prefix}    AND
    ...                            Run Keyword And Ignore Error    core.teardown_collectors    names=${wireshark_log_prefix}

Modify PrachConfigInd
    [Documentation]    Author:liyu.li@nokia-sbell.com
    [Arguments]    ${cell_index}=1    ${connection}=GNB_OAM    ${gnb_index}=0    ${timeout}=300
    ...             ${PrachConfigInd}=156
    ${dist_name}    Set Variable    MRBTS-${MRBTS_ID}/NRBTS-${NRBTS_ID}/NRCELL-${cell_index}
    ${param}    Create Dictionary    dist_name=${dist_name}    parameter=prachConfigurationIndex    value=${PrachConfigInd}
    @{params_need_to_modify}    Create List    ${param}
    Common_keywords.Update Params Via RestApi    params_need_to_modify=${params_need_to_modify}
