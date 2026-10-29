*** Settings ***
Documentation
...    author: ChenXu
...    contact: xu.2.chen@nokia-sbell.com
...    squad group: 5G_PZ_MMW_HZ_5_SG
...    Feature CB007539_CB008386 8CCDL2CCUL

Resource    testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/robot/CI_Operations/CI_interface.robot
Resource    testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/robot/coam_gnb_classical.robot
Resource    testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/robot/traffic_via_iperf.robot
Resource    testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/robot/power_ue/power_ue.robot
Resource    testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/robot/rrm_log_check.robot
Resource    testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/robot/bts/cloud/cloud_cu.robot
Library    ute_reporting_portal
Library    testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/python/kpi_reporter.py
Library    kpi_reporter.KpiReporter    WITH NAME    KpiReporter



*** Variables ***
${tmp_lua_dir}    /home/ute/wireshark/plugins/luashark.lua
${SCF_PATH}   ${commissionings_path}/HGZ/${testline_name}/
${ue_type}    ${tl.ues[0].capabilities[1]}
${CU_addr}                    ${tl.gnbs[0].cu.oam_ssh_connection_details.addr}             # oam ip
${CU_username}                ${tl.gnbs[0].cu.oam_ssh_connection_details.username}         # robot
${CU_password}                ${tl.gnbs[0].cu.oam_ssh_connection_details.password}         # rastre1

*** Keywords ***
Get Average Value
    [Documentation]     Get average number and print
    [Arguments]       ${all_tp}

	${length}    Evaluate    len(${all_tp})

	FOR  ${var}  IN RANGE    0    ${length}
		${x}=	Get From List	${all_tp}	${var}

		${x2}=   Run keyword if   ${length}==1   set variable  ${x}
		...  ELSE         Get From List   ${x}	0

		${value} =	Get From Dictionary    ${x2}    average
		Log to console   \n The average result is ${value}
	END


COAM Check GNB_DU cell on air
    [Documentation]  Author:
    ...              Description: Check if GNB is in cell on air status
    Cloud DU connect to gnb coam via ssl
    Verify all cells should be onair
    [Teardown]   COAM Teardown gnb connections

Get cell numbers
    Cloud DU connect to gnb coam via ssl
    ${bts_info}   coam.get_bts_info   connection=GNB_OAM   timeout=10
    #${cell_list}   Set Variable   ${bts_info['cells']['nr']}
    ${Check_Status}    Run Keyword And Return Status   Dictionary Should Contain Key    ${bts_info}    requestMessage
    ${cell_list}   Run Keyword If   '${Check_Status}' == 'True'
    ...   Set Variable   ${bts_info['requestMessage']['cells']['nr']}
    ...   ELSE   Set Variable   ${bts_info['cells']['nr']}

    ${cell_numbers}    get length    ${cell_list}
    ${sample_times}=    Evaluate    ${cell_numbers}*10
    Log To Console    current env cell number is ${cell_numbers}
    Log To Console    current env sample times is ${sample_times}
    set suite variable       ${cell_numbers}
    set suite variable       ${sample_times}

Common Setup
    Run keyword and continue on failure    Wait Until Keyword Succeeds    15min    20s    step1: Check all cells status
    #step2: Scf commission and wait for on-air



step1: Check all cells status
    log to console      step1: Check all cells status
    COAM Check GNB_DU cell on air

step2: Scf commission and wait for on-air
    log to console      Scf commission and wait for on-air
    Du scf commission and wait for on-air     scf_name=${du_scf_name}

Du scf commission and wait for on-air
    [Arguments]   ${scf_name}   ${connection}=GNB_OAM
    Cloud DU connect to gnb coam via ssl    connection=${connection}
    COAM Commission with scf file    scf_file_path=${SCF_PATH}/${scf_name}    timeout=${600}    is_pdl_checking_needed=${False}
    COAM Teardown gnb connections
    #sleep    1s
    #Restart CU
    sleep    3min
    Wait Until Keyword Succeeds    15min    20s    COAM Check GNB_DU cell on air
    Get cell numbers
    [Teardown]    COAM Teardown gnb connections

step3: Prepare UE
    log to console      step3: Prepare UE
    #power_ue.Prepare UE    ue_index=${0}    ue_type=${ue_type}    ui_version=S20UI2.1
    power_ue.Prepare UE    ue_index=${0}    ue_type=${ue_type}

Step4: UE Attach
    log to console      Step4: UE Attach
    ${5Grach_ed_0}    power_ue.UE Attach    ue_index=${0}    ue_type=${ue_type}    log_type=Aasyslog
    power_ue.Verify attach    ue_type=${ue_type}   5Grach_ed=${5Grach_ed_0}    4G_check=False
    #Preparation and execution for Commercial UE Attach    ue_index=${0}
    #Log    click Airplane mode switch to disable its function so that make UE attach

Step5: Start traffic
    [Arguments]   ${ul_throughput}=280M    ${dl_throughput}=800M    ${protocol}=udp
    log to console      Step5: Start traffic
    power_ue.Start traffic    ue_index=${0}    direction=ul    throughput=${ul_throughput}    duration=1800    ue_type=${ue_type}
  	...    iperf_type=via_command
    ...    protocol=${protocol}
    sleep    1s          
    power_ue.Start traffic    ue_index=${0}    direction=dl    throughput=${dl_throughput}    duration=1800    ue_type=${ue_type}
  	...    protocol=${protocol}    buffer_size=1400B    process_num=${3}    seg_size=1350    window=16M
    sleep    2s

Step5: Start traffic TCP ULDL
    TL127 Start UL TCP traffic and check the TP on Commercial    process_num=16
	sleep    5s
	TL127 Start DL TCP traffic and check the TP on EPC    process_num=5
    sleep    5s

Step6: Check throughput
    [Arguments]    ${traffic_time}=90s    
    log to console      Step6: Check throughput
    ${cell_number}    Get cell numbers in gnb
    AAsys log captrue    stop_aasys_flag=${False}
    sleep      ${traffic_time}
    ${cell_id}    Get nrcellid from aasys log    
    ${dl_traffic_data}    ${ul_traffic_data}    Get traffic data from aasys log
    ${dl_peak_tp}    ${dl_average_tp}    ${dl_minimum_tp}    Calculate Throughput and retrun result in gnb    data=${dl_traffic_data}
    ...    cell_numbers=${cell_number}
    ${ul_peak_tp}    ${ul_average_tp}    ${ul_minimum_tp}    Calculate Throughput and retrun result in gnb    data=${ul_traffic_data}
    ...    cell_numbers=${cell_number}
    [Return]    ${dl_peak_tp}    ${dl_average_tp}    ${dl_minimum_tp}    ${ul_peak_tp}    ${ul_average_tp}    ${ul_minimum_tp}

Step6: Check throughput trunk
    [Arguments]    ${traffic_time}=90s    
    log to console      Step6: Check throughput
    ${cell_number}    Get cell numbers in gnb
    AAsys log captrue    stop_aasys_flag=${False}
    sleep      ${traffic_time}
    ${cell_id}    Get nrcellid from aasys log    
    ${dl_traffic_data}    ${ul_traffic_data}    Get traffic data from aasys log for TRUNK
    ${dl_peak_tp}    ${dl_average_tp}    ${dl_minimum_tp}    Calculate Throughput and retrun result in gnb    data=${dl_traffic_data}
    ...    cell_numbers=${cell_number}
    ${ul_peak_tp}    ${ul_average_tp}    ${ul_minimum_tp}    Calculate Throughput and retrun result in gnb    data=${ul_traffic_data}
    ...    cell_numbers=${cell_number}
    [Return]    ${dl_peak_tp}    ${dl_average_tp}    ${dl_minimum_tp}    ${ul_peak_tp}    ${ul_average_tp}    ${ul_minimum_tp}
 
Step7: Stop traffic
    log to console      Step7: Stop traffic
    power_ue.Stop traffic    direction=ul    ue_index=${0}    ue_type=${ue_type}    iperf_type=via_command    
    power_ue.Stop traffic    direction=dl    ue_index=${0}    ue_type=${ue_type}

Step8: UE Detach
    log to console      Step8: UE Detach
    power_ue.UE Detach    ue_index=${0}    ue_type=${ue_type}

Common Capture BIP log and download
    [Arguments]    ${duration}=5s    ${log_path}=${logPath}
    Connect to Common Unit Master
    Precondition for bip capture with gnbMirroring scripts
    Bip Capture with gnbMirroring scripts
    sleep    ${duration}
    ${list_log_path_local}    Stop BIP capture on ASIK if needed and download BIP Logs to testPC    log_path=${log_path}
    set test variable    ${bip_log_path}    ${list_log_path_local}[0]
    ssh.Disconnect    connection=ASIK Master
    [Return]    ${bip_log_path}
	
BIP log Check
    log to console      BIP log Check
    ${log_path}    BIP log capture and download
    ...    save_time_interval=2    filter=ether[0x18:2]==0x133 or ether[0x18:2]==0x249 or ether[0x18:2]==0x135
    ${msc_and_beam_id}    Get ul dl mcs and beam id    log_path=${log_path}    sample=5

Case_Teardown_AEUD
    [Arguments]    ${connection}=GNB_OAM    
    Log To Console    \n *** Case teardown
    Run Keyword And Ignore Error    Step7: Stop traffic
    Run Keyword And Ignore Error    Step8: UE Detach
    Run Keyword And Ignore Error    COAM Teardown gnb connections    connection=${connection}
    Run Keyword And Ignore Error    Teardown the Aasyslog save progress 
    Run Keyword And Ignore Error    Stop BIP Capture On ASOD
	  Run Keyword And Ignore Error    CI_interface.Common Case Teardown
    
DL TPUT Upload
    [Arguments]     ${exp_dl}    ${dl_avg}    ${dl_max}    ${dl_min}
    ...    ${protocol}    ${deviation}=10%    ${logs_dir}=${None}
        Run Keyword And Ignore Error    KpiReporter.add_dl_throughput_into_report_list    exp_dl=${exp_dl}
        ...                                               dl_avg=${dl_avg}
        ...                                               dl_max=${dl_max}
        ...                                               dl_min=${dl_min}
        Run Keyword And Ignore Error    KpiReporter.report_tput_kpi    protocol=${protocol}    deviation=${deviation}    logs_dir=${logs_dir}

UL TPUT Upload
    [Arguments]     ${exp_ul}    ${ul_avg}    ${ul_max}    ${ul_min}
    ...    ${protocol}    ${deviation}=10%    ${logs_dir}=${None}
        Run Keyword And Ignore Error    KpiReporter.add_ul_throughput_into_report_list    exp_ul=${exp_ul}
        ...                                               ul_avg=${ul_avg}
        ...                                               ul_max=${ul_max}
        ...                                               ul_min=${ul_min}
        Run Keyword And Ignore Error    KpiReporter.report_tput_kpi    protocol=${protocol}    deviation=${deviation}    logs_dir=${logs_dir}

BOTH TPUT Upload
    [Arguments]     ${exp_dl}    ${dl_avg}    ${dl_max}    ${dl_min}    ${exp_ul}    ${ul_avg}    ${ul_max}    ${ul_min}
    ...    ${protocol}    ${deviation}=10%    ${logs_dir}=${None}
        Run Keyword And Ignore Error    KpiReporter.add_dl_throughput_into_report_list    exp_dl=${exp_dl}
        ...                                               dl_avg=${dl_avg}
        ...                                               dl_max=${dl_max}
        ...                                               dl_min=${dl_min}
        Run Keyword And Ignore Error    KpiReporter.add_ul_throughput_into_report_list    exp_ul=${exp_ul}
        ...                                               ul_avg=${ul_avg}
        ...                                               ul_max=${ul_max}
        ...                                               ul_min=${ul_min}
        Run Keyword And Ignore Error    KpiReporter.report_tput_kpi    protocol=${protocol}    deviation=${deviation}    logs_dir=${logs_dir}
