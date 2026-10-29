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
Library     taf.rfrl.common_resources.python.SWConfig    WITH NAME    SWConfig
Library          OperatingSystem

Variables    CB008941_A_Parameters.py
*** Variables ***
${scf_file_template_path}    ${commissionings_path}/HGZ/${testline_name}
${swconfig_file_template_path}    ${commissionings_path}/HGZ/${testline_name}/CB008941/swconfig.txt
${gnb_index}    0
${TestCase_Log_Path}    /home/ute/
${Wireshark_LOG_PATH}    /home/ute/Downloads
${mrbtsId}                   ${tl.gnbs[0].instance_id}
${nrbtsId}                   ${tl.gnbs[0].global_bts_id}
#@{list_of_cell}    15368193
#@{list_of_cell}     15319041
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

Test Case setup to on air with CB008941 enable
    [Arguments]    ${scf_name}    ${scf_parameters}    ${is_pdl_checking_needed}=${False}
	Backup Swconfig
	Upload CB008941 swconfig
    COAM Create log directory
    ${output_scf_file_path}    COAM Modify scf file    scf_file_path=${scf_name}    scf_parameters_list=${scf_parameters}
	Connect to gnb coam via ssl
    COAM Commission with scf file    scf_file_path=${output_scf_file_path}    is_pdl_checking_needed=${False}
   	Wait Until Keyword Succeeds    20min    20s    Verify all cells should be onair    connection=GNB_OAM
    Run Keyword And Ignore Error    ssh.force_reconnect    connection=ASIK Master
   [Teardown]    COAM Teardown gnb connections




Prepare UE for ${ue_type}
    log to console      Prepare UE for ${ue_type}
    power_ue.Prepare UE    ue_index=${0}    ue_type=${ue_type}    reset_sol=ue_reboot
	sleep    40s

UE Attach and verify attach
    [Arguments]     ${ue_type}    ${ue_index}
    log to console      UE Attach for ${ue_type}
    ${5Grach_ed_0}    power_ue.UE Attach    ue_index=${ue_index}    ue_type=${ue_type}    log_type=Aasyslog
    power_ue.Verify attach    ue_type=${ue_type}   5Grach_ed=${5Grach_ed_0}    4G_check=False

Start traffic according to direction and protocol
    [Arguments]  ${data_send_dl}    ${ue_index}    ${data_send_ul}=60M     ${tp_direction}=both
    log to console      Start traffic
    Run keyword if    '${tp_direction}'=='ul' or '${tp_direction}'=='both'    power_ue.Start traffic    ue_index=${ue_index}
    ...    direction=ul    throughput=${data_send_ul}    duration=14000    ue_type=${ue_type}    iperf_type=via_command
    ...    protocol=${protocol}    data_amount=2M
    sleep    1s
    Run keyword if    '${tp_direction}'=='dl' or '${tp_direction}'=='both'   power_ue.Start traffic    ue_index=${ue_index}
    ...     direction=dl    throughput=${data_send_dl}    duration=1400    ue_type=${ue_type}    seg_size=${seg_size}    protocol=${protocol}
	...    process_num=${process_num}    window=32M
    sleep    20s

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
    [Arguments]    ${dltp_expected}    ${tp_direction}    ${ultp_expected}   
    log to console      Check throughput
	${cell_identify}=    Evaluate     16384*${tl.gnbs[0].instance_id}+1
    ${cell_identify}   convert to string   ${cell_identify}
    @{list_of_cell}     Create List         ${cell_identify}
    Set Suite Variable     @{list_of_cell}
	${log}    Run keyword and continue on failure    power_ue.Collect Tput
	...    ue_type=${ue_type}    duration=2m    filter=L2Lo
	Set Suite Variable     ${log}
    Run keyword if    '${tp_direction}'=='dl' or '${tp_direction}'=='both'   Run keyword and continue on failure    power_ue.Check Tput
    ...    ue_type=${ue_type}    direction=DL    log=${log}    cells=@{list_of_cell}
    ...    target_throughput=${dltp_expected}    actCarrierAggregation=${False}
    ...    target_avg_percent=1.00    min_percent=0.55
    Run keyword if    '${tp_direction}'=='ul' or '${tp_direction}'=='both'    Run keyword and continue on failure    power_ue.Check Tput
    ...    ue_type=${ue_type}    direction=UL    log=${log}    cells=@{list_of_cell}
    ...    target_throughput=${ultp_expected}    actCarrierAggregation=${False}
    ...    target_avg_percent=1.00    min_percent=0.55


Stop traffic according to direction and protocol
    [Arguments]  ${tp_direction}=both
    log to console      Stop traffic
    Run keyword if    '${tp_direction}'=='ul' or '${tp_direction}'=='both'    power_ue.Stop traffic    direction=ul
    ...    ue_index=${0}    ue_type=${ue_type}    iperf_type=via_command    protocol=tcp
    Run keyword if    '${tp_direction}'=='dl' or '${tp_direction}'=='both'      power_ue.Stop traffic    direction=dl
    ...     ue_index=${0}    ue_type=${ue_type}    protocol=tcp


UE Detach for
    [Arguments]     ${ue_type}    ${ue_index}
    log to console      UE Detach for ${ue_type}
    power_ue.UE Detach    ue_index=${0}    ue_type=${ue_type}


Start traffic and check result
    [Arguments]    ${ue_index}    ${tp_direction}    ${dltp_expected}=540  ${data_send_dl}=560M    ${data_send_ul}=70M
	...             ${ultp_expected}=50     ${sleep_time}=1m
    Start traffic according to direction and protocol  data_send_dl=${data_send_dl}    tp_direction=${tp_direction}
    ...            data_send_ul=${data_send_ul}    ue_index=${ue_index}
    AAsys log captrue    sleep_time=${sleep_time}
    Check throughput according to direction and protocol    dltp_expected=${dltp_expected}
    ...    tp_direction=${tp_direction}    ultp_expected=${ultp_expected}
    Stop traffic according to direction and protocol   tp_direction=${tp_direction}

Backup Swconfig
    [Documentation]  This Keyword Is To backup Swconfig
	[Arguments]    ${gnb_index}=${0}    ${du_index}=${0}    ${connection}=GNB_OAM    ${alias}=ASIK Master
    Wait Until Keyword Succeeds    2min    10 sec     Connect to Common Unit Master
	...    gnb_index=${gnb_index}    du_index=${du_index}    alias=${alias}
    ssh.Send_Command    cp /ffs/run/swconfig.txt /ffs/run/swconfig_origin.txt    connection=${alias}
    SWConfig.Download_Swconfig_File_From_Asik_To_Test_PC    localFilePath=${OUTPUT DIR}/swconfig.txt
    ...    asik_alias=${alias}  remoteFilePath=/ffs/run/swconfig.txt
    ssh.Disconnect    connection=${alias}

Restore swconfig to default
	[Arguments]    ${gnb_index}=${0}    ${du_index}=${0}    ${connection}=GNB_OAM    ${alias}=ASIK Master
    Wait Until Keyword Succeeds    2min    10 sec     Connect to Common Unit Master
    ...    gnb_index=${gnb_index}    du_index=${du_index}    alias=${alias}
    ssh.Send_Command    cp /ffs/run/swconfig_origin.txt /ffs/run/swconfig.txt    connection=${alias}
	ssh.Send_Command    crasign /ffs/run/swconfig.txt    connection=${alias}
	ssh.Disconnect    connection=${alias}
Upload CB008941 swconfig
    [Documentation]
    [Arguments]    ${swconfig_template_path}=${swconfig_file_template_path}
    ...    ${gnb_index}=${0}    ${du_index}=${0}    ${connection}=GNB_OAM    ${alias}=ASIK Master
    Connect to Common Unit Master    gnb_index=${gnb_index}    du_index=${du_index}    alias=${alias}
    swconf.Upload swConfig file to asik and crasign    localFilePath=${swconfig_template_path}    asik_alias=${alias}
    csn.disconnect    connection=${alias}
Check syslog contains expected value
    [Arguments]    ${filter_print}=ExtType12    ${expected_print}="actUlEcpriExtType12":true    ${log_path}=/ram/node_CPRT00/tmp/startup_cp_rt.log
	...    ${gnb_index}=${0}    ${du_index}=${0}    ${connection}=GNB_OAM    ${alias}=ASIK Master
    Log To Console    Check cprt log
    Connect to Common Unit Master    gnb_index=${gnb_index}    du_index=${du_index}    alias=${alias}
	${cmd1}   Set Variable    cat ${log_path} | grep -i ${filter_print}
	${cmd2}   Set Variable    xz --force --stdout -d ${log_path}.xz | grep -i ${filter_print}
	${result}    ssh.execute    find ${log_path}.xz   connection=${alias}
    ${result}    convert to string   ${result}
	${filter_result1}    ssh.execute    ${cmd1}    connection=${alias}
    ${filter_result2}    ssh.execute    ${cmd2}    connection=${alias}
    ${filter_result}    Set Variable     ${filter_result1}+${filter_result2}
    should contain    ${filter_result}    ${expected_print}
    [Teardown]    Run Keyword And Ignore Error    ssh.Disconnect    connection=${alias}
   
Check CB008941 enable
    Check syslog contains expected value    
	...    filter_print=ExtType12    expected_print="actUlEcpriExtType12":true   log_path=/ram/node_CPRT00/tmp/startup_cp_rt.log  
    Check syslog contains expected value    
	...    filter_print=ExtType12    expected_print="actDlEcpriExtType12":true   log_path=/ram/node_CPRT00/tmp/startup_cp_rt.log  	
    Check syslog contains expected value    
	...    filter_print=Fragmentation    expected_print= Fragmentation enabled [Ul] = 1   log_path=/ram/node_CPRT00/tmp/startup_cp_rt.log
    Check syslog contains expected value    
	...    filter_print=Fragmentation    expected_print= Fragmentation enabled [Dl] = 1   log_path=/ram/node_CPRT00/tmp/startup_cp_rt.log
Check CB008941 Disable
    Check syslog contains expected value    
	...    filter_print=ExtType12    expected_print="actUlEcpriExtType12":false   log_path=/ram/node_CPRT00/tmp/startup_cp_rt.log  
    Check syslog contains expected value    
	...    filter_print=ExtType12    expected_print="actDlEcpriExtType12":false   log_path=/ram/node_CPRT00/tmp/startup_cp_rt.log  	
    Check syslog contains expected value    
	...    filter_print=Fragmentation    expected_print= Fragmentation enabled [Ul] = 0   log_path=/ram/node_CPRT00/tmp/startup_cp_rt.log
    Check syslog contains expected value    
	...    filter_print=Fragmentation    expected_print= Fragmentation enabled [Dl] = 0   log_path=/ram/node_CPRT00/tmp/startup_cp_rt.log
