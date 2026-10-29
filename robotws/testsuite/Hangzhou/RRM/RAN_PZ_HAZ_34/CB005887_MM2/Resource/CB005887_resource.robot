*** Settings ***
Documentation
...    author: jiaytang
...    contact: jiayi.tang@nokia-sbell.com
...    squad group: 5G_PZ_MMW_HZ_2_SG
...    Feature 5GC001937_OTA program

Resource    testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/robot/CI_Operations/CI_interface.robot
Resource    testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/robot/coam_gnb_classical.robot
Resource    testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/robot/traffic_via_iperf.robot
Resource    testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/robot/power_ue/power_ue.robot
Resource    testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/robot/rrm_log_check.robot
Resource    testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/robot/bts/cloud/cloud_cu.robot
Resource    testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/robot/coam_siso_common.robot

Library    ute_reporting_portal
Library    testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/python/kpi_reporter.py
Library    kpi_reporter.KpiReporter    WITH NAME    KpiReporter

*** Variables ***
${tmp_lua_dir}    /home/ute/wireshark/plugins/luashark.lua
${SCF_PATH}   ${commissionings_path}/HGZ/${testline_name}/
${ue_type}    ${tl.ues[0].capabilities[1]}
${CU_addr}                    ${tl.gnbs[0].cu.oam_ssh_connection_details.addr}            
${CU_username}                ${tl.gnbs[0].cu.oam_ssh_connection_details.username}         
${CU_password}                ${tl.gnbs[0].cu.oam_ssh_connection_details.password}         

*** Keywords ***
COAM Check GNB_DU cell on air
    [Documentation]  Author:
    ...              Description: Check if GNB is in cell on air status
    Cloud DU connect to gnb coam via ssl
    Verify all cells should be onair
    [Teardown]   COAM Teardown gnb connections

Get cell numbers
    Cloud DU connect to gnb coam via ssl
    ${bts_info}   coam.get_bts_info   connection=GNB_OAM   timeout=10
    ${cell_list}   Run Keyword If   ${bts_info.has_key('requestMessage')}
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
    step2: Scf commission and wait for on-air

Restart CU
    csn.connect_to    hostname=${CU_addr}    username=${CU_username}    password=${CU_password}    alias=cu_oam
    csn.SendCommand    command=sudo reboot    connection=cu_oam
    csn.Disconnect    connection=cu_oam
        
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
    [Arguments]     ${ue_index}=${0}
    log to console      step3: Prepare UE
    power_ue.Prepare UE    ue_index=${ue_index}    ue_type=${ue_type}    

Step4: UE Attach
    [Arguments]     ${ue_index}=${0}
    log to console      Step4: UE Attach
    ${5Grach_ed_0}    power_ue.UE Attach    ue_index=${ue_index}    ue_type=${ue_type}    log_type=Aasyslog
    ...    attach_mode=5G_NSA
    power_ue.Verify attach    ue_type=${ue_type}   5Grach_ed=${5Grach_ed_0}    4G_check=False


Step5: Start traffic tcp
    [Arguments]   ${ul_throughput}=460M    ${dl_throughput}=4500M    ${protocol}=udp    ${ue_index}=${0}
    log to console      Step5: Start traffic
    power_ue.Start traffic    ue_index=${ue_index}    direction=ul    throughput=${ul_throughput}    duration=1200    ue_type=${ue_type}
    ...    iperf_type=via_command
    ...    protocol=tcp    seg_size=4350    window=2M    buffer_size=1400B    process_num=${4}
    sleep    1s          
    power_ue.Start traffic    ue_index=${ue_index}    direction=dl    throughput=${dl_throughput}    duration=1200    ue_type=${ue_type}
    ...    protocol=tcp    buffer_size=1400B    seg_size=4350    window=8M    process_num=${8}
    sleep    2s

Step5: Start traffic udp
    [Arguments]   ${ul_throughput}=400M    ${dl_throughput}=1050M    ${protocol}=udp    ${ue_index}=${0}
    log to console      Step5: Start traffic
    power_ue.Start traffic    ue_index=${ue_index}    direction=ul    throughput=${ul_throughput}    duration=1200    ue_type=${ue_type}
    ...    iperf_type=via_command
    ...    protocol=udp
    sleep    1s          
    power_ue.Start traffic    ue_index=${ue_index}    direction=dl    throughput=${dl_throughput}    duration=1200    ue_type=${ue_type}
    ...    protocol=udp    buffer_size=1280B    seg_size=1350    process_num=${4}
    sleep    2s

Step5: Start traffic UL
    [Arguments]   ${ul_throughput}=400M    ${protocol}=udp    ${ue_index}=${0}
    log to console      Step5: Start traffic
    power_ue.Start traffic    ue_index=${ue_index}    direction=ul    throughput=${ul_throughput}    duration=1200    ue_type=${ue_type}
    ...    iperf_type=via_command    process_num=${8}    seg_size=1350    window=16M    buffer_size=1400B
    ...    protocol=${protocol}
    sleep    5s

Step5: Start traffic DL
    [Arguments]   ${dl_throughput}=2500M    ${protocol}=udp    ${ue_index}=${0}
    log to console      Step5: Start traffic
    power_ue.Start traffic    ue_index=${ue_index}    direction=dl    throughput=${dl_throughput}    duration=1200    ue_type=${ue_type}
    ...    protocol=${protocol}    buffer_size=1400B    process_num=${2}    seg_size=1350    window=16M
    sleep    5s


Step7: Stop traffic
    [Arguments]     ${ue_index}=0
    log to console      Step7: Stop traffic
    power_ue.Stop traffic    direction=ul    ue_index=${ue_index}    ue_type=${ue_type}    iperf_type=via_command    
    power_ue.Stop traffic    direction=dl    ue_index=${ue_index}    ue_type=${ue_type}

Step8: UE Detach
    [Arguments]     ${ue_index}=${0}
    log to console      Step8: UE Detach
    power_ue.UE Detach    ue_index=${ue_index}    ue_type=${ue_type}

Deactivate CarrierAgg
    Du login page via webUI
    selenium_coam.set_parameter_value
    ...    dist_name=MRBTS-152/NRBTS-1
    ...    abbr=caConfigurationSupport
    ...    new_value=none
    ...    filter_param=CA configuration support
    sleep    1s
    Validate Plan
    sleep    5s
    Activate Plan
	wait until keyword succeeds    15 min    30 sec
    ...    Du Check cell on air via WebUI
	
Activate CarrierAgg
    Du login page via webUI
    selenium_coam.set_parameter_value
    ...    dist_name=MRBTS-152/NRBTS-1
    ...    abbr=caConfigurationSupport
    ...    new_value=8CCDL_4CC UL
    ...    filter_param=CA configuration support
    sleep    1s
    Validate Plan
    sleep    5s
    Activate Plan
	wait until keyword succeeds    15 min    30 sec
    ...    Du Check cell on air via WebUI
