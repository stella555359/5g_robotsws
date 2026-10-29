*** Settings ***
Documentation
...    author: shenrao
...    contact: shengrong.rao@nokia-sbell.com
...    squad group: 5G_PZ_MMW_HZ_3_SG
...    Feature 5GC001937_OTA program
...    modify by LiuNing at 2021.5.27

#Library    taf.sbts.oam.coam.admin   WITH NAME   admin_cli
Library    testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/python/kpi_reporter.py
Library    kpi_reporter.KpiReporter    WITH NAME    KpiReporter
Library    ute_reporting_portal
Resource    testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/robot/coam_gnb_classical.robot
Resource    testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/robot/traffic_via_iperf.robot
Resource    testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/robot/power_ue/power_ue.robot
Resource    testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/robot/rrm_log_check.robot
Resource    testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/robot/bts/cloud/cloud_cu.robot
Resource    testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/robot/CI_Operations/CI_interface.robot
Resource    ./5GC001937_KW_for_TL915.robot

*** Variables ***
${CU_addr}                    ${tl.gnbs[0].cu.oam_ssh_connection_details.addr}             # oam ip
${CU_username}                ${tl.gnbs[0].cu.oam_ssh_connection_details.username}         # robot
${CU_password}                ${tl.gnbs[0].cu.oam_ssh_connection_details.password}         # rastre1
${TestCase_Log_Path}    /home/ute/
${luashark_path}    /opt/luashark/luashark.lua
${gnb_index}    0
${ue_type}    ${tl.ues[0].capabilities[1]}
${data_amount}    2M
${process_num_TCP}    3
${seg_size}    1350
${window}    24M
${seg_size1}    1350
${server_window1}    16M
${window1}    12M
${process_num}    1


*** Keywords ***
step1:scf commission and wait for on-air
    [Arguments]   ${scf_name}   ${connection}=COAM
    log to console    step1:scf commission and wait for on-air
    #Conect to CU by ssh and reset cu
    Conect to DU COAM
    coam.perform_commissioning
    ...   scf_file=${SCF_TEMPLATE_PATH}/${scf_name}
    ...   skip_parameter_relation_errors=${true}
    ...   should_activate=${true}
    ...   timeout=${600}
    ...   connection=${connection}
	CU Commission
	sleep    60s
    Wait Until Keyword Succeeds    20min    20s    COAM Check All GNB Cells Onair
    Get cell numbers

step2:Prepare UE
    log to console    step2:Prepare UE
    power_ue.Prepare UE    ue_index=${0}    ue_type=${ue_type}

step3:UE Attach
    log to console    step3:UE Attach
    ${5Grach_ed_0}    power_ue.UE Attach    ue_index=${0}    ue_type=${ue_type}    log_type=Aasyslog
    power_ue.Verify attach    ue_type=${ue_type}   5Grach_ed=${5Grach_ed_0}    4G_check=False


step4:start traffic
    log to console    step4:start traffic
    [Arguments]   ${process_num}=2    ${protocol}=udp    ${tp_direction}=both
    ...    ${ul_throughput}=120M    ${dl_throughput}=2100M    ${duration}=1800
    Run keyword if    '${tp_direction}'=='dl' or '${tp_direction}'=='both'   power_ue.Start traffic    ue_index=${0}
    ...     direction=dl    throughput=${dl_throughput}   duration=${duration}    ue_type=${ue_type}    protocol=${protocol}
	...     buffer_size=1400B    process_num=${process_num}    seg_size=${seg_size}    window=${window}
    sleep    3s
    Run keyword if    '${tp_direction}'=='ul' or '${tp_direction}'=='both'    power_ue.Start traffic    ue_index=${0}
    ...    direction=ul    throughput=${ul_throughput}    duration=${duration}    ue_type=${ue_type}    iperf_type=via_command
    ...    protocol=${protocol}    data_amount=${data_amount}


    sleep    20s

step45:start traffic
    log to console    step45:start traffic
    [Arguments]    ${protocol}=udp    ${tp_direction}=both
    ...    ${ul_throughput}=120M    ${dl_throughput}=2100M    ${duration}=1800
    Run keyword if    '${tp_direction}'=='dl' or '${tp_direction}'=='both'   Start traffic_S21_TL915    ue_index=${0}
    ...     direction=dl    throughput=${dl_throughput}   duration=${duration}    ue_type=${ue_type}    protocol=${protocol}
	...     buffer_size=1400B    process_num=${process_num_TCP}    seg_size=${seg_size1}    server_window=${server_window1}
	...     window=${window1}
    sleep    3s
    Run keyword if    '${tp_direction}'=='ul' or '${tp_direction}'=='both'    Start traffic_S21_TL915    ue_index=${0}
    ...    direction=ul    throughput=${ul_throughput}    duration=${duration}    ue_type=${ue_type}    iperf_type=via_command
    ...    protocol=${protocol}    data_amount=${data_amount}

    sleep    20s

step5:bip get and return result
    log to console    step5:bip get and return result
    [Arguments]    ${gnb_index}=0    ${du_index}=0    ${timeout}=15m    ${save_time_interval}=1    ${sample}=30
    ...    ${filter}=ether[0x18:2]==0x133 or ether[0x18:2]==0x249 or ether[0x18:2]==0x135 or ether[0x18:2]==0x24d
    Precondition For ASOD Bip Capture
    Start BIP Capture On ASOD    save_time_interval=${save_time_interval}
    ...    filter=${filter}    timeout=${timeout}
    sleep    3s
    ${longtime_mcs}    Create List
    FOR    ${i}    IN RANGE    200
        log to console  ${i}
        ${status}    ${log_path}    Run Keyword And Ignore Error    Download ASOD BIP Logs To TestPC    sample=${sample}
        Run keyword if    "${log_path}"=="IOError: [Errno 2] No such file" and "${status}"=="FAIL"    Exit For Loop
        ${status}    ${msc_and_beam_id}    Run Keyword And Ignore Error    pdml check    log_path=${log_path}    sample=1
        run keyword if    '${status}'=='PASS'    Append To List    ${longtime_mcs}    ${msc_and_beam_id}
        ...    ELSE    Continue For Loop
    END
    [Return]    ${longtime_mcs}

step7:stop traffic
    [Arguments]  ${tp_direction}=both    ${protocol}=udp
    log to console    Stop traffic
    Run keyword if    '${tp_direction}'=='ul' or '${tp_direction}'=='both'    power_ue.Stop traffic    direction=ul
    ...    ue_index=${0}    ue_type=${ue_type}    iperf_type=via_command    protocol=${protocol}
    Run keyword if    '${tp_direction}'=='dl' or '${tp_direction}'=='both'    power_ue.Stop traffic    direction=dl
    ...     ue_index=${0}    ue_type=${ue_type}    protocol=${protocol}

step8:UE Detach
    log to console    step5:UE Detach
    power_ue.UE Detach    ue_index=${0}    ue_type=${ue_type}

COAM Check All GNB Cells Onair
    [Documentation]  Author:
    ...              Description: Check if GNB is in cell on air status
    Cloud DU connect to gnb coam via ssl
    COAM Check GNB cell on air
    [Teardown]   COAM Teardown gnb connections

KPI Report
    [Arguments]    ${protocol}=udp    ${tp_direction}=both    ${deviation}=5%    ${exp_ul}=220 Mbits/sec
	...    ${exp_dl}=1950 Mbits/sec    ${dl_avg}=0 Mbits/sec    ${dl_max}=0 Mbits/sec
	...    ${dl_min}=0 Mbits/sec     ${ul_avg}=0 Mbits/sec     ${ul_max}=0 Mbits/sec     ${ul_min}=0 Mbits/sec
    log to console    KPI Report
    Run keyword if    '${tp_direction}'=='dl' or '${tp_direction}'=='both'    Run Keyword And Ignore Error
     ...    KpiReporter.add_dl_throughput_into_report_list    exp_dl=${exp_dl}
     ...                                                      dl_avg=${dl_avg}
     ...                                                      dl_max=${dl_max}
     ...                                                      dl_min=${dl_min}
    Run keyword if    '${tp_direction}'=='ul' or '${tp_direction}'=='both'    Run Keyword And Ignore Error
     ...    KpiReporter.add_ul_throughput_into_report_list    exp_ul=${exp_ul}
     ...                                                      ul_avg=${ul_avg}
     ...                                                      ul_max=${ul_max}
     ...                                                      ul_min=${ul_min}
    Run Keyword And Ignore Error    KpiReporter.report_tput_kpi    protocol=${protocol}    deviation=${deviation}

CaseTeardown
    [Arguments]    ${connection}=COAM
    Log To Console    \n *** Case teardown
    Run Keyword And Ignore Error    coam.teardown    connection=${connection}
    Run Keyword And Ignore Error    Teardown the Aasyslog save progress
    Run Keyword And Ignore Error    Stop BIP Capture On ASOD
	Run Keyword And Ignore Error    CI_interface.Common Case Teardown

CU Commission
	CU Rest Login    gnb_index=${gnb_index}
	CU Full Commission    path_of_commission_file=${SCF_Template_path_CU}   plan_name=CU_SCF    gnb_index=${gnb_index}

Conect to DU COAM
    [Arguments]    ${connection}=COAM
    coam.connect to   bts_host=${tl.gnbs[0].dus[0].f1_m_ip_addr}
                  ...      username=${WEBUI_USER}
                  ...      password=${WEBUI_PASSWORD}
                  ...      name=${connection}

Get cell numbers
    Conect to DU COAM
    ${bts_info}   coam.get_bts_info   connection=COAM   timeout=10
    ${Check_Status}    Run Keyword And Return Status   Dictionary Should Contain Key    ${bts_info}    requestMessage
    ${cell_list}   Run Keyword If   '${Check_Status}' == 'True'
    ...   Set Variable   ${bts_info['requestMessage']['cells']['nr']}
    ...   ELSE   Set Variable   ${bts_info['cells']['nr']}
    ${cell_numbers}    get length    ${cell_list}
    ${sample_times}=    Evaluate    ${cell_numbers}*10
    Log To Console    current env cell number is ${cell_numbers}
    Log To Console    current env sample times is ${sample_times}
    set suite variable    ${cell_numbers}
    set suite variable    ${sample_times}

Get ul and dl peak and ave throughput and return result
    [Documentation]    Get ul and dl peak and ave throughput and return result.
    ...    :param aasys_start_flag: for short time captrue use default, for long time call use ${False}, EG:${true}/${False}
    [Arguments]    ${gnb_index}=0    ${du_index}=0    ${aasys_start_flag}=${true}
    ${cell_number}    Get cell numbers in gnb    gnb_index=${gnb_index}    du_index=${du_index}
    run keyword if    '${aasys_start_flag}'=='${true}'    AAsys log captrue    gnb_index=${gnb_index}    du_index=${du_index}
    ${cell_id}    Get nrcellid from aasys log    gnb_index=${gnb_index}    du_index=${du_index}
    ${dl_traffic_data}    ${ul_traffic_data}    Get traffic data from aasys log for TRUNK    gnb_index=${gnb_index}    du_index=${du_index}
    ${dl_peak_tp}    ${dl_average_tp}    ${dl_minimum_tp}    Calculate Throughput and retrun result in gnb    data=${dl_traffic_data}
    ...    cell_numbers=${cell_number}
    ${ul_peak_tp}    ${ul_average_tp}    ${ul_minimum_tp}    Calculate Throughput and retrun result in gnb    data=${ul_traffic_data}
    ...    cell_numbers=${cell_number}
    [Return]    ${dl_peak_tp}    ${dl_average_tp}    ${dl_minimum_tp}    ${ul_peak_tp}    ${ul_average_tp}    ${ul_minimum_tp}

pdml check
    [Arguments]    ${log_path}=/home/ute/shushu/asod_bip_2020_0716_0801_21.pcap0    ${sample}=1
    ${ave_value_list}    Create List
    ${length}=    get length    ${log_path}
    FOR    ${i}    IN RANGE    0    ${length}    ${sample}
        ${status}    ${ave_value}=    Run Keyword And Ignore Error
        ...    Get ul dl mcs beamid bler value from output pdml files    file_path=${log_path[${i}]}    luashark_path=${luashark_path}
        run keyword if    '${status}'=='PASS' and '${ave_value}'!='${EMPTY}'    Append To List    ${ave_value_list}    ${ave_value}
    END
    [Teardown]    Run Keyword And Ignore Error    Remove big log files    filename=${log_path}
    [Return]    ${ave_value_list}

Create parameters for test suite
    ${var_status}    ${ci_var_dict}    run keyword and ignore error    CI_commssion._Set Variables For Test
    ...    gnb_index=${0}   du_index=${0}    common_unit_index=${0}
    #Set Suite Variable    ${SCF_TEMPLATE_PATH}    ${CURDIR}/../../../../commissionings/HGZ/&{ci_var_dict}[testline]/5GC001937
    Set Suite Variable    ${SCF_TEMPLATE_PATH}    ${commissionings_path}/HGZ/${testline_name}/5GC001937
    Set Suite Variable    ${SCF_Template_path_CU}    ${SCF_TEMPLATE_PATH}/CU_${ci_var_dict}[stream]_SCF.xml
    Set Suite Variable    ${du_4cc_scf_name}    DU_${ci_var_dict}[stream]_4CC_AEWD.xml
    Set Suite Variable    ${du_8cc_scf_name}    DU_${ci_var_dict}[stream]_8CC_AEWD.xml


Suite Precondition
    #${ci_var_dict}    run keyword and continue on failure    CI_interface.Common Suite Setup
    Create parameters for test suite

Check if do recommission
    [Arguments]    ${expected_cell_numbers}    ${scf_name}
    Get cell numbers
	run keyword if    '${cell_numbers}'!='${expected_cell_numbers}'      step1:scf commission and wait for on-air
	...    scf_name=${scf_name}
