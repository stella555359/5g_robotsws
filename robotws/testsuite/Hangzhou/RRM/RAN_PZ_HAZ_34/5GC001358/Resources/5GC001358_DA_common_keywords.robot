*** Settings ***
Documentation
...    author: Wang xiaocui
...    contact: xiaocui.Wang@nokia-sbell.com
...    squad group: 5G_PZ_MMW_HZ_3_SG
...    Feature 5GC001358-DA program



Resource    testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/robot/coam_gnb_classical.robot
Resource    testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/robot/power_ue/power_ue.robot
Resource    testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/robot/CI_Operations/CI_interface.robot
Resource    testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/robot/rrm_log_check.robot
Resource    testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/robot/android_common_keyword.robot
Resource    testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/robot/siso_common_case/step_keywords/5G/basic/pre_analysis.robot
Library          taf.sbts.oam.coam.admin   WITH NAME    coam
Library          taf.transport.ssh    WITH NAME    csn
Library    taf.analyzer.pcap     WITH NAME    cap
Library          OperatingSystem

Variables    5GC001358_DA_parameters.py
*** Variables ***
${scf_file_template_path}    ${commissionings_path}/HGZ/${testline_name}
${gnb_index}    0
${TestCase_Log_Path}    /home/ute/
${Wireshark_LOG_PATH}    /home/ute/Downloads
${mrbtsId}                   ${tl.gnbs[0].instance_id}
${nrbtsId}                   ${tl.gnbs[0].global_bts_id}
@{list_of_cell}    15368193
*** Keywords ***
Get cell numbers
    Conect to DU COAM
    ${bts_info}   coam.get_bts_info   connection=COAM   timeout=10
    ${cell_list}   Run Keyword If   ${bts_info.has_key('requestMessage')}
    ...   Set Variable   ${bts_info['requestMessage']['cells']['nr']}
    ...   ELSE   Set Variable   ${bts_info['cells']['nr']}
    ${cell_numbers}    get length    ${cell_list}
    ${sample_times}=    Evaluate    ${cell_numbers}*10
    Log To Console    current env cell number is ${cell_numbers}
    Log To Console    current env sample times is ${sample_times}
    set suite variable       ${cell_numbers}
    set suite variable       ${sample_times}

COAM Check GNB_DU cell on air
    [Documentation]  Author:
    ...              Description: Check if GNB is in cell on air status
    [Arguments]    ${connection}=COAM
    Conect to DU COAM
    COAM Check All Cells Onair
    [Teardown]   admin_cli.teardown    connection=${connection}

CaseTeardown
    [Arguments]       ${connection}=COAM
    Log To Console    \n *** Case teardown
    Run Keyword And Ignore Error    admin_cli.teardown    connection=${connection}
    Run Keyword And Ignore Error    Teardown the Aasyslog save progress
	Run Keyword And Ignore Error    CI_interface.Common Case Teardown

Get Stream
    Connect to gnb coam via ssl
    ${Active_SW_version}    Get Active SW Version
    ${stream}    get stream from version    ${Active_SW_version}
    set suite variable      ${stream}
    [Return]       ${stream}

Test Case setup to on air
    [Arguments]    ${scf_name}    ${scf_parameters}    ${is_pdl_checking_needed}=${False}
    COAM Create log directory
    ${output_scf_file_path}    COAM Modify scf file    scf_file_path=${scf_name}    scf_parameters_list=${scf_parameters}
	Connect to gnb coam via ssl
    COAM Commission with scf file    scf_file_path=${output_scf_file_path}    is_pdl_checking_needed=${False}    timeout=600s
   	Wait Until Keyword Succeeds    20min    20s    Verify all cells should be onair    connection=GNB_OAM
    Run Keyword And Ignore Error    ssh.force_reconnect    connection=ASIK Master
   [Teardown]    COAM Teardown gnb connections


Get ul and dl peak and ave throughput from syslog
    [Documentation]    Get ul and dl peak and ave throughput and return result.
    ...    :param aasys_start_flag: for short time captrue use default, for long time call use ${False}, EG:${true}/${False}
    [Arguments]    ${gnb_index}=0    ${du_index}=0    ${aasys_start_flag}=${true}
    ${cell_number}    Get cell numbers in gnb    gnb_index=${gnb_index}    du_index=${du_index}
    run keyword if    '${aasys_start_flag}'=='${true}'    AAsys log captrue    gnb_index=${gnb_index}    du_index=${du_index}
    ${cell_id}    Get nrcellid from aasys log    gnb_index=${gnb_index}    du_index=${du_index}
    ${dl_traffic_data}    ${ul_traffic_data}    Get traffic data from aasys log    gnb_index=${gnb_index}    du_index=${du_index}
    ${dl_peak_tp}    ${dl_average_tp}    ${dl_minimum_tp}    Calculate Throughput and retrun result in gnb    data=${dl_traffic_data}
    ...    cell_numbers=${cell_number}
    ${ul_peak_tp}    ${ul_average_tp}    ${ul_minimum_tp}    Calculate Throughput and retrun result in gnb    data=${ul_traffic_data}
    ...    cell_numbers=${cell_number}
    [Return]    ${dl_peak_tp}    ${dl_average_tp}    ${dl_minimum_tp}    ${ul_peak_tp}    ${ul_average_tp}    ${ul_minimum_tp}

Prepare UE for ${ue_type}
    log to console      Prepare UE for ${ue_type}
    power_ue.Prepare UE    ue_index=${0}    ue_type=${ue_type}    reset_sol=ue_reboot
	sleep    40s

UE Attach for ${ue_type}
    log to console      UE Attach for ${ue_type}
    ${5Grach_ed_0}    power_ue.UE Attach    ue_index=${0}    ue_type=${ue_type}    log_type=Aasyslog
    power_ue.Verify attach    ue_type=${ue_type}   5Grach_ed=${5Grach_ed_0}    4G_check=False

Start traffic according to direction and protocol
    [Arguments]  ${data_send_dl}    ${data_send_ul}=60M     ${tp_direction}=both
    log to console      Start traffic
    Run keyword if    '${tp_direction}'=='ul' or '${tp_direction}'=='both'    power_ue.Start traffic    ue_index=${0}
    ...    direction=ul    throughput=${data_send_ul}    duration=1400    ue_type=${ue_type}    iperf_type=via_command
    ...    protocol=${protocol}    data_amount=2M
    sleep    1s
    Run keyword if    '${tp_direction}'=='dl' or '${tp_direction}'=='both'   power_ue.Start traffic    ue_index=${0}
    ...     direction=dl    throughput=${data_send_dl}    duration=1400    ue_type=${ue_type}    seg_size=${seg_size}    protocol=${protocol}
	...    process_num=${process_num}    window=32M
    sleep    5s

Start traffic according to direction and protocol for Stability
    [Arguments]  ${data_send_dl}    ${duration_time}   ${data_send_ul}=60M     ${tp_direction}=both
    log to console      Start traffic
    Run keyword if    '${tp_direction}'=='ul' or '${tp_direction}'=='both'    power_ue.Start traffic    ue_index=${0}
    ...    direction=ul    throughput=${data_send_ul}    duration=${duration_time}    ue_type=${ue_type}    iperf_type=via_command
    ...    protocol=${protocol}    data_amount=2M
    sleep    1s
    Run keyword if    '${tp_direction}'=='dl' or '${tp_direction}'=='both'   power_ue.Start traffic    ue_index=${0}
    ...     direction=dl    throughput=${data_send_dl}    duration=${duration_time}
    ...     ue_type=${ue_type}    seg_size=${seg_size}    protocol=${protocol}
	...    process_num=${process_num}    window=32M
    sleep    20s

Check throughput according to direction and protocol
    [Arguments]    ${dltp_expected}    ${ultp_expected}=58    ${tp_direction}=both
    ...    ${call_duration}=2m     ${target_avg_percent}=0.98      ${min_percent}=0.55
    log to console      Check throughput
	${log}    Run keyword and continue on failure    power_ue.Collect Tput
	...    ue_type=${ue_type}    duration=${call_duration}    filter=L2Lo
	Set Suite Variable     ${log}
    Run keyword if    '${tp_direction}'=='dl'    Run keyword and continue on failure    power_ue.Check Tput
    ...    ue_type=${ue_type}    direction=DL    log=${log}    cells=@{list_of_cell}
    ...    target_throughput=${dltp_expected}    actCarrierAggregation=${False}
    ...    target_avg_percent=${target_avg_percent}    min_percent=${min_percent}
    Run keyword if    '${tp_direction}'=='ul'    Run keyword and continue on failure    power_ue.Check Tput
    ...    ue_type=${ue_type}    direction=UL    log=${log}    cells=@{list_of_cell}
    ...    target_throughput=${ultp_expected}    actCarrierAggregation=${False}
    ...    target_avg_percent=${target_avg_percent}    min_percent=${min_percent}



Stop traffic according to direction and protocol
    [Arguments]  ${tp_direction}=both
    log to console      Stop traffic
    Run keyword if    '${tp_direction}'=='ul' or '${tp_direction}'=='both'    power_ue.Stop traffic    direction=ul
    ...    ue_index=${0}    ue_type=${ue_type}    iperf_type=via_command    protocol=tcp
    Run keyword if    '${tp_direction}'=='dl' or '${tp_direction}'=='both'      power_ue.Stop traffic    direction=dl
    ...     ue_index=${0}    ue_type=${ue_type}    protocol=tcp


UE Detach for ${ue_type}
    log to console      UE Detach for ${ue_type}
    power_ue.UE Detach    ue_index=${0}    ue_type=${ue_type}


Start traffic and check result
    [Arguments]    ${dltp_expected}=540  ${data_send_dl}=560M    ${data_send_ul}=70M
	...             ${ultp_expected}=50    ${tp_direction}=both    ${sleep_time}=1m
	...             ${call_duration}=2m     ${target_avg_percent}=0.98      ${min_percent}=0.55
    Start traffic according to direction and protocol  data_send_dl=${data_send_dl}    tp_direction=${tp_direction}
    ...            data_send_ul=${data_send_ul}
    AAsys log captrue    sleep_time=${sleep_time}
    Run keyword and continue on failure    Check throughput according to direction and protocol    dltp_expected=${dltp_expected}
    ...    tp_direction=${tp_direction}    ultp_expected=${ultp_expected}
    ...    call_duration=${call_duration}      target_avg_percent=${target_avg_percent}    min_percent=${min_percent}
    Stop traffic according to direction and protocol   tp_direction=${tp_direction}

Change prachConfigurationIndex value
    [Arguments]    ${target_value}
    Connect to gnb coam via ssl
    coam.perform_parameter_recommissioning      dist_name=MRBTS-${mrbtsId}/NRBTS-${mrbtsId}/NRCELL-1
    ...                                         parameter=prachConfigurationIndex
    ...                                         operation=update
    ...                                         value=${target_value}
    ...                                         skip_parameter_relation_errors=${False}
    ...                                         timeout=700
    ...                                         should_activate=True
    ...                                         connection=GNB_OAM
    [Teardown]    COAM Teardown gnb connections

#Wireshark log
Stop and Download Log
    Log    \n Download log     console=yes
    [Arguments]    ${filename}    ${connection}=RealEnb
    csn.send command    command=killall tcpdump    connection=${connection}
    sleep    2s
    csn.download_file    remote_path=/tmp/${filename}    local_path=${Wireshark_LOG_PATH}/${filename}
    ...    connection=${connection}
    sleep    2s
    #csn.execute    command=rm /tmp/${filename}    connection=${connection}
    Csn.Disconnect	connection=${connection}

Start to Capture X2 Log
    [Arguments]    ${filename}    ${connection}=RealEnb
    Connect to eNB    alias=${connection}
    csn.send command    command=killall tcpdump    connection=${connection}
    sleep    2s
    csn.send command    command=tcpdump -n -i br1 -w /tmp/${filename} &>/dev/null &
    ...    connection=${connection}
    sleep    5s

check prachConfigurationIndex value on X2 log
    Log    \n check prachConfigurationIndex value on X2 log     console=yes
    [Arguments]    ${filename}    ${exp_value}
    cap.Read Cap    cap_file=${Wireshark_LOG_PATH}/${filename}    display_filter=x2ap
    ${res_value}    cap.Get Element Value    element_expression=nr-rrc.prach_ConfigurationIndex
    ...    condition_expression=x2ap.X2AP_PDU == 1    default_value=${True}
    Should be equal    ${res_value}[0]    ${exp_value}
#    ${status}    ${value} =    run keyword and ignore error    cap.Check Expression
#    ...    condition_expression=x2ap.X2AP_PDU == 1 && nr-rrc.prach_ConfigurationIndex == ${exp_value}
#    should be equal    '${status}'    'PASS'

Get nrCellIdentity for specific cell
    [Documentation]    Author: Liu Zheng
    [Arguments]    ${cell_id}    ${connection}=GNB_OAM
    ${nrCellIdentity}   Get SCF single Value from current xml file
    ...   parameter=nrCellIdentity   list_name=${None}   dist_name=NRBTS-${tl.gnbs[0].global_bts_id}/NRCELL-${cell_id}   p_index=${0}
    ...   alias=GNB_OAM    config_type=configurationAndRuntimeObjects
    [Return]    ${nrCellIdentity}
