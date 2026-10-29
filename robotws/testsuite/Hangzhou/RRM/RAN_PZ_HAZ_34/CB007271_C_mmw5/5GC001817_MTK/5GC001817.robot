# *** Settings ***
# Force Tags    PY36     RAN_5G_FDD    SBTS00     CRT_TRUNK      CRT_22R3
# 
# Documentation    1817 
# ...              Author: 
# ...              Contact: 
# 
# 
# Resource    testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/robot/power_ue/power_ue.robot
# Resource    testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/robot/Commercial_mobile_phone_adb_common_keywords.robot
# Resource    testsuite/Hangzhou/RRM/RAN_PZ_HAZ_34/5GC000496_C/Resources/L3Call.robot
# Resource    testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/robot/coam_gnb_classical.robot
# Library    testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/robot/siso_common_case/lib/frame_structure_and_throughput.py
# Library    taf.transport.ssh    WITH NAME    csn
# 
# 
# Resource    testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/robot/robot_common_operations/interface.robot
# 
# Suite Setup    Run Keywords     Setup Suite for 7271
# ...    AND     robot_common_operations.Common Suite Setup
# 
# 
# Suite Teardown   robot_common_operations.Common Suite Teardown
# Test Setup       robot_common_operations.Common Case Setup
# Test Teardown    robot_common_operations.Common Case Teardown
# 
# 
# *** Variables ***
# #${SHERPA_LOG_PATH}          /home/ute/sherpa_log/
# #${ASIK_IP}                  ${tl.gnbs[0].cu.oam_ssh_connection_details.addr}
# #${WEBUI_IP}                 ${tl.gnbs[0].cu.oam_http_connection_details.addr}
# #${WEBUI_USERNAME}           ${tl.gnbs[0].cu.oam_http_connection_details.username}
# #${WEBUI_PASSWORD}           ${tl.gnbs[0].cu.oam_http_connection_details.password}
# #${WEBUI_URL}                https://${tl.gnbs[0].cu.oam_http_connection_details.addr}
# #${PA1_INFO}                 ${tl.attenuators[0]}
# #${ALIAS_ASIK}               asik
# #${ALIAS_ASIK_SLAVE}         asik_slave
# #${SWCONFIG_DEFAULT_FILE_PATH}       ${CURDIR}/Configuration/swconfig_base.txt
# #${ue_type}       samsung
# #${scf}     ${CURDIR}/Configuration/scf_DU1910_22R3_base.xml
# #${delta_file_c05}         ${CURDIR}/Configuration/scf_DU1910_delta_c05_23R2.json
# #${delta_file_c05_new}         ${CURDIR}/Configuration/scf_DU1910_delta_22R3_c05.json
# 
# #${ue_index}   2
# #${ue_index}   1
# #
# #${TS_LOG_PATH_BASE}    ${output_dir}
# #
# #${DL_port}    $45132
# #
# #*** Test Cases ***
# #[1]CB007271_5G_C_5GC001817_A_05_Aperiodic_CSI_handling_DRX_and_MG_disabled_with_data_transmission_in_FDD_SA_mode
# #    #[Setup]    Setup case for MTK
# #    [Tags]     a05    CRT_22R4  
# #    Wait Until Keyword Succeeds    5min    30s    power_ue.Prepare UE    ue_type=samsung   ue_index=${ue_index}
# #    #run keyword and ignore error        power_ue.UE Attach    ue_type=samsung   ue_index=${ue_index}
# #    #KW.Verify Attach
# #    ${5Grach_ed_0}    power_ue.UE Attach    ue_index=${ue_index}    ue_type=${ue_type}    log_type=Aasyslog
# #    power_ue.Verify attach    ue_type=${ue_type}   5Grach_ed=${5Grach_ed_0}    4G_check=False    ue_index=${ue_index}
# #    
# #    #Start UL UDP traffic via iperf command     time=600   traffic=20M    ue_index=${ue_index}
# #    #Start DL UDP traffic via iperf command    time=600    process_num=1   traffic=20M    ue_index=${ue_index}  DL_port=${DL_port}
# #    power_ue.Start traffic    ue_index=${ue_index}    direction=ul    throughput=20M    duration=600    ue_type=${ue_type}
# #  	...    iperf_type=via_command
# #    ...    protocol=udp
# #    sleep    1s
# #    power_ue.Start traffic    ue_index=${ue_index}    direction=dl    throughput=20M    duration=1800    ue_type=${ue_type}
# #  	...    protocol=udp    buffer_size=1400B    process_num=${1}    seg_size=1350    window=16M
# #    sleep    2s
# #
# #   # sleep    40s
# #   #Check Throughtput   duration=100
# #    ${log}    power_ue.Collect Tput    ue_type=${ue_type}    duration=4m    filter=L2Lo   ue_index=${ue_index}
# #    ${list_of_cell_ids}    Create List    179519490
# #    ${all_tp}    power_ue.Check Bi Tput    ue_type=${ue_type}    log=${log}    cells=${list_of_cell_ids}   ue_index=${ue_index}
# #    ...    ultarget_throughput=0.5    dltarget_throughput=0.5    actCarrierAggregation=${True}    min_percent=0
# #
# #    Collect DCAP
# #    run keyword and continue on failure    DCAP.Extract_out_Log_Files   tracer=udptracer
# #    run keyword and continue on failure    DCAP.Decode_Sherpa_Logs
# #    run keyword and continue on failure    KW.Verify_Sherpa_Logs  
# #    [Teardown]    UE teardown
# #
# #
# #[1]CB007271_5G_C_5GC001817_C_07_Aperiodic_CSI_handling_DL_data_load_changed_from_high_to_low_then_to_high_again
# #    #[Setup]    Setup case for MTK
# #    [Tags]     c07    
# #
# #    sleep   5s
# #    
# #    @{list}=  Create list   0x5900D4=2   0x580385=1 
# #    Preparation with swconfig modification   swconfig_modify=${list}   is_called_in_test_case_level=${True}
# #    #BtsLog.StartBTSlogCollection
# #
# #    Wait Until Keyword Succeeds    5min   30s    power_ue.Prepare UE    ue_type=samsung   ue_index=${ue_index}
# #    #run keyword and ignore error    power_ue.UE Attach    ue_type=samsung    ue_index=${ue_index}
# #    #KW.Verify Attach
# #    ${5Grach_ed_0}    power_ue.UE Attach    ue_index=${ue_index}    ue_type=${ue_type}    log_type=Aasyslog
# #    power_ue.Verify attach    ue_type=${ue_type}   5Grach_ed=${5Grach_ed_0}    4G_check=False    ue_index=${ue_index}
# #
# #    #Start DL UDP traffic via iperf command   time=1600    process_num=1   traffic=2M   ue_index=${ue_index}
# #    power_ue.Start traffic    ue_index=${ue_index}    direction=dl    throughput=2M    duration=1600    ue_type=${ue_type}
# #  	...    protocol=udp    buffer_size=1400B    process_num=${1}    seg_size=1350    window=16M
# #    sleep    2s
# #    #sleep    40s
# #    #Check DL Throughtput    duration=100
# #    ${log}    power_ue.Collect Tput    ue_type=${ue_type}    duration=20m    filter=L2Lo    ue_index=${ue_index}
# #    ${list_of_cell_ids}    Create List    179519490
# #    ${all_tp}    power_ue.Check Tput    ue_type=${ue_type}    direction=DL    log=${log}    cells=${list_of_cell_ids}
# #    ...    target_throughput=0.5    actCarrierAggregation=${True}    min_percent=0
# #
# #    @{traces}    create list   L2Ps_Sherpa
# #    run keyword and continue on failure    DCAP.Start_Collect_Trace   traces=${traces}
# #    sleep   3s
# #    run keyword and continue on failure    KW.Adjust PA     value=${CASE_INPUT_5GC001817['5GC001817_C_07']['PA_Value_1']}   
# #    sleep   3s
# #    run keyword and continue on failure    KW.Adjust PA     value=${CASE_INPUT_5GC001817['5GC001817_A_05']['PA_Value_1']}
# #    sleep   3s
# #    run keyword and continue on failure    KW.Adjust PA     value=${CASE_INPUT_5GC001817['5GC001817_C_07']['PA_Value_1']}
# #    sleep   3s
# #    run keyword and continue on failure    KW.Adjust PA     value=${CASE_INPUT_5GC001817['5GC001817_A_05']['PA_Value_1']}
# #    sleep   3s
# #    #run keyword and continue on failure    DCAP.Stop_Collect_Trace_and_Get_Result
# #    run keyword and continue on failure     Stop_Collect_Trace_and_Get_Result_test
# #    run keyword and continue on failure    DCAP.Extract_out_Log_Files   tracer=udptracer
# #    run keyword and continue on failure    DCAP.Decode_Sherpa_Logs
# #    run keyword and continue on failure    KW.Verify_Sherpa_Logs_add_UCIonly_check
# #    [Teardown]    UE teardown
# #    
# #[1]CB007271_5G_C_5GC001817_C_05_Aperiodic_CSI_handling_dynamic_betaoffset_enabled
# #    #[Setup]    Setup case for MTK
# #    [Tags]     c05    CRT_22R4   
# #    
# #    sleep   5s 
# #    @{list}=  Create list   0x5900D4=2   0x580385=0 
# #    Preparation with swconfig modification   swconfig_modify=${list}   is_called_in_test_case_level=${True}
# #
# #    ${result}    ${release}    Run Keyword And Ignore Error
# #    ...    Wait Until Keyword Succeeds    1 min    2 sec    gnb_classical_hangzhou.Get sw build version
# #    ${release_sbts}    Replace String    string=${release}    search_for=5G    replace_with=SBTS
# #    Run keyword If  '${release_sbts}'=='SBTS23R2'
# #    ...    SCF delta recommission       delta_file=${delta_file_c05}
# #    ...    ELSE       SCF delta recommission       delta_file=${delta_file_c05_new}
# #
# #    #SCF delta recommission       delta_file=${delta_file_c05}
# #
# #    Wait Until Keyword Succeeds    5min    30s    power_ue.Prepare UE    ue_type=samsung   ue_index=${ue_index}
# #    #run keyword and ignore error     power_ue.UE Attach    ue_type=samsung   ue_index=${ue_index}
# #    #KW.Verify Attach
# #    ${5Grach_ed_0}    power_ue.UE Attach    ue_index=${ue_index}    ue_type=${ue_type}    log_type=Aasyslog
# #    power_ue.Verify attach    ue_type=${ue_type}   5Grach_ed=${5Grach_ed_0}    4G_check=False    ue_index=${ue_index}
# #
# #    #Start UL UDP traffic via iperf command    time=1800    traffic=2M   ue_index=${ue_index}
# #    #Start DL UDP traffic via iperf command    time=1800    process_num=1   traffic=2M    ue_index=${ue_index}    DL_port=${DL_port}
# #    #sleep    40s
# #
# #    power_ue.Start traffic    ue_index=${ue_index}    direction=ul    throughput=2M    duration=1800    ue_type=${ue_type}
# #  	...    iperf_type=via_command
# #    ...    protocol=udp
# #    sleep    1s
# #    power_ue.Start traffic    ue_index=${ue_index}    direction=dl    throughput=2M    duration=1800    ue_type=${ue_type}
# #  	...    protocol=udp    buffer_size=1400B    process_num=${1}    seg_size=1350    window=16M
# #    sleep    2s
# #
# #    #Check Throughtput   duration=100  ul_target=0.5   dl_target=0.5
# #    ${log}    power_ue.Collect Tput    ue_type=${ue_type}    duration=4m    filter=L2Lo   ue_index=${ue_index}
# #    ${list_of_cell_ids}    Create List    179519490
# #    ${all_tp}    power_ue.Check Bi Tput    ue_type=${ue_type}    log=${log}    cells=${list_of_cell_ids}   ue_index=${ue_index}
# #    ...    ultarget_throughput=0.5    dltarget_throughput=0.5    actCarrierAggregation=${True}   min_percent=0
# #
# #
# #    Run Keyword And Continue On Failure    Conn.ConnectWithTimeout  alias=${ALIAS_ASIK}
# #
# #    Run Keyword And Continue On Failure    Wireshark.StartCaptureLogFromContainer   nodename=CPIF    filename=CPIF_1817_CA05.pcap
# #    sleep   5s
# #    run keyword and continue on failure    KW.Adjust PA     value=${CASE_INPUT_5GC001817['5GC001817_C_05']['PA_Value_1']}
# #    sleep   5s
# #    run keyword and continue on failure    KW.Adjust PA     value=${CASE_INPUT_5GC001817['5GC001817_A_05']['PA_Value_1']}
# #    sleep   5s
# #    run keyword and continue on failure    KW.Adjust PA     value=${CASE_INPUT_5GC001817['5GC001817_C_05']['PA_Value_2']}
# #    sleep   5s
# #    run keyword and continue on failure    KW.Adjust PA     value=${CASE_INPUT_5GC001817['5GC001817_C_05']['PA_Value_3']}
# #    sleep   5s
# #    Run Keyword And Continue On Failure    Wireshark.StopCapturinglogFromContainer    nodename=CPIF
# #    Run Keyword And Continue On Failure    DownloadLogToUTEFromContainer   filename=CPIF_1817_CA05.pcap    nodename=CPIF
# #    #Run Keyword And Continue On Failure    wireshark.DownloadLogToUTEFromContainer   filename=CPIF_1817_CA05.pcap    nodename=CPIF
# #    Conn.Disconnect  alias=${ALIAS_ASIK}
# #    #Check Throughtput   duration=30    ul_target=0.00000001   dl_target=0.00000001
# #    @{traces}    create list   L2Ps_Sherpa
# #    run keyword and continue on failure    DCAP.Start_Collect_Trace   traces=${traces}
# #    sleep   10s
# #    #run keyword and continue on failure    DCAP.Stop_Collect_Trace_and_Get_Result
# #    run keyword and continue on failure     Stop_Collect_Trace_and_Get_Result_test
# #    run keyword and continue on failure    KW.Adjust PA     value=${CASE_INPUT_5GC001817['5GC001817_A_05']['PA_Value_1']}
# #    sleep   5s
# #    run keyword and continue on failure    DCAP.Extract_out_Log_Files   tracer=udptracer
# #    run keyword and continue on failure    DCAP.Decode_Sherpa_Logs
# #    run keyword and continue on failure    KW.Verify_Sherpa_Logs     ACSI_NOK_percent=0.99
# #    
# #    Wireshark.ReadLog    filename=CPIF_1817_CA05.pcap    filter=f1ap.procedureCode == 8 && nr-rrc.transformPrecoder == 0
# #    Run Keyword And Continue On Failure    Wireshark.CheckExpression   expression=f1ap.procedureCode == 8 && nr-rrc.transformPrecoder == 0
# #    #BtsLog.StartBTSlogCollection
# #    sleep    2s
# #    [Teardown]    UE teardown    
# #
# #[1]CB007271_5G_C_5GC001817_D_03_Aperiodic_CSI_handling_SA_UE_peak_throughput_and_latency_with_RSRP_-85_dBm
# #    #[Setup]    Setup case for MTK
# #    [Tags]     d03    CRT_22R4   test
# #    @{list}=  Create list   0x5900D4=2   0x580385=1 
# #    Preparation with swconfig modification   swconfig_modify=${list}   is_called_in_test_case_level=${True}
# #
# #    #BtsLog.StartBTSlogCollection
# #
# #    Wait Until Keyword Succeeds    5min    30s    power_ue.Prepare UE    ue_type=samsung   ue_index=${ue_index}
# #    #run keyword and ignore error    power_ue.UE Attach    ue_type=samsung    ue_index=${ue_index}
# #    #KW.Verify Attach
# #    ${5Grach_ed_0}    power_ue.UE Attach    ue_index=${ue_index}    ue_type=${ue_type}    log_type=Aasyslog
# #    power_ue.Verify attach    ue_type=${ue_type}   5Grach_ed=${5Grach_ed_0}    4G_check=False    ue_index=${ue_index}
# #
# #    #Start UL UDP traffic via iperf command    time=1800    traffic=105M    ue_index=${ue_index}
# #    #Start DL UDP traffic via iperf command   time=1800    process_num=1   traffic=210M     ue_index=${ue_index}   DL_port=${DL_port}
# #    #sleep    60s
# #
# #    power_ue.Start traffic    ue_index=${ue_index}    direction=ul    throughput=60M    duration=1800    ue_type=${ue_type}
# #  	...    iperf_type=via_command
# #    ...    protocol=udp
# #    sleep    1s
# #    power_ue.Start traffic    ue_index=${ue_index}    direction=dl    throughput=90M    duration=1800    ue_type=${ue_type}
# #  	...    protocol=udp    buffer_size=1400B    process_num=${1}    seg_size=1350    window=16M
# #    sleep    2s
# #
# #    #Check Throughtput   duration=100    ul_target=50   dl_target=80
# #    ${log}    power_ue.Collect Tput    ue_type=${ue_type}    duration=4m    filter=L2Lo   ue_index=${ue_index}
# #    ${list_of_cell_ids}    Create List    179519490
# #    ${all_tp}    power_ue.Check Bi Tput    ue_type=${ue_type}    log=${log}    cells=${list_of_cell_ids}   ue_index=${ue_index}
# #    ...    ultarget_throughput=5    dltarget_throughput=20    actCarrierAggregation=${True}   min_percent=0
# #
# #    @{traces}    create list   L2Ps_Sherpa
# #    run keyword and continue on failure    DCAP.Start_Collect_Trace   traces=${traces}
# #    sleep   3s
# #    #run keyword and continue on failure    DCAP.Stop_Collect_Trace_and_Get_Result
# #    run keyword and continue on failure     Stop_Collect_Trace_and_Get_Result_test
# #    run keyword and continue on failure    DCAP.Extract_out_Log_Files   tracer=udptracer
# #    run keyword and continue on failure    DCAP.Decode_Sherpa_Logs
# #    run keyword and continue on failure    KW.Verify_Sherpa_Logs 
# #    [Teardown]    UE teardown
# #
# #
# *** Keywords ***
# Stop_Collect_Trace_and_Get_Result_test
#     [Arguments]   ${timeout}=10min
#     [Documentation]  Stop tracing, delete to traces to save server space, then remove the bts from the dcapserver.
#     ...     return: path of downloaded trace file in zip format, and the content in the zip file.
#     Log to console   Stop collecting dcap log.
#     rd.stop_trace
#     sleep    ${timeout}
#     ${trace_file_path}    rd.get_results
#     ${trace_result_content}    rd.get_result_file_contents
#     ${PATHONLY}   ${SNAPSHOTNAME}   Split String From Right    string=${trace_file_path}   separator=/     max_split=1
#     ${PATHONLY}   ${SNAPSHOTNAMEContent}   Split String From Right    string=${trace_result_content}   separator=/     max_split=1
#     run    mv ${trace_file_path} ${LOG_PATH}/.
#     run    mv ${trace_result_content} ${LOG_PATH}/.
#     set test variable   ${trace_file_path}    ${LOG_PATH}/${SNAPSHOTNAME}
#     set test variable   ${trace_result_content}    ${LOG_PATH}/${SNAPSHOTNAMEContent}
#     rd.delete_trace
#     rd.delete_bts
#     [Return]  ${trace_file_path}  ${trace_result_content}
# 
# Setup case for MTK
# #    TestCase.Start
#     log to console     Case Start
# 
# Setup Suite for 7271
#     Import Variables       ${CURDIR}/Configuration/TLConfiguration.py
#     set suite variable     ${dcap_ip}    ${CASE_INPUT_5GC001817['5GC001817']['dcap_server_ip']}
#     set suite variable     ${dcap_port}    ${CASE_INPUT_5GC001817['5GC001817']['dcap_server_port']}
#     set suite variable     ${5GRU1_PA_Ports}       ${CASE_INPUT_5GC001817['5GC001817']['5GRU1_PA_Ports']}
# 
#     ${result}    Get NRCellIdentity And Cell Index Mapping    connection=GNB_OAM
#     ${list_of_cell_ids}     Create List    ${result[2]} 
#     set suite variable    ${first_cell_to_check}    ${list_of_cell_ids}
# 
#     run keyword and continue on failure    KW.Adjust PA     value=${CASE_INPUT_5GC001817['5GC001817_A_05']['PA_Value_1']}
#     SCF commission     SCF=${scf}
#  
# UE setup
#     power_ue.Prepare UE    ue_type=samsung
# 
# Get NRCellIdentity And Cell Index Mapping
#     [Documentation]   Auther:stella.lin@nokia-sbell.com
#     ...               ${result} : e.g. {1: {'nrCellIdentity': 1249, 'cell_group_id': 0, 'physicalCellId': 60},
#     ...                                 2: {'nrCellIdentity': 1250, 'cell_group_id': 1, 'physicalCellId': 61}}
#     ...               Return ${nrCellIdentity_mapping}: e.g. {1:1249,2:1250}
#     [Arguments]    ${connection}=GNB_OAM
#     Connect to gnb coam via ssl    connection=${connection}
#     ${result}    get_relation_mapping_between_cell_index_and_other_ids    connection_alias=${connection}
#     ${keys}     Get Dictionary Keys    ${result}
#     ${nrCellIdentity_mapping}    Create Dictionary
#     FOR   ${key}   IN    @{keys}
#         ${item}    Set Variable    &{result}[${key}]
#         Set To Dictionary    ${nrCellIdentity_mapping}     ${key}   ${item['nrCellIdentity']}
#     END
#     [Return]    ${nrCellIdentity_mapping}
#     [Teardown]    coam.teardown    connection=${connection}
# 
# KW.Verify Attach
#     [Arguments]   ${alias}=ASIK MASTER   ${connection}=GNB_OAM
# 	Connect to Common Unit Master   alias=${alias}
#    
#     ${attach_log}    set variable    /tmp/5Grach.txt
#     ${local_dir}    set variable    ${output_dir}/${TEST NAME}
#     run keyword and ignore error    run keywords    Create directory    ${local_dir}    AND
#         ...    csn.download file    remote_path=${attach_log}    local_path=${local_dir}/5Grach.txt   connection=${alias} 
#     
#     connect to gnb coam via ssl     connection=${connection} 
#     ${cell_id}    wait until keyword succeeds   1min    5s    get_ue_attached_cell_id_from_log    log_path=${attach_log}
#         ...    alias=${alias}    connection=${connection}
#     run keyword and ignore error    csn.Execute    rm ${attach_log}   connection=${alias}
# 	
# KW.PA_Adjust Attenuation Ports Value acording config
#     [Arguments]    ${ports}    ${value}    ${attenuator}   ${logging_message}=Adjusting PA values
#     log to console    ${logging_message}
#     PA_.setup_attenuator    attenuator=${attenuator}
#     ${length}    Get Length    ${ports}
#     :for    ${i}    IN RANGE    ${length}
#     \  log to console    PA ports ${ports[${i}]} to ${value[${i}]} 
#     \  PA_.set_attenuation     port=${ports[${i}]}    value=${value[${i}]}
#     \  PA_.read_attenuation    port=${ports[${i}]}
# 
# KW.Adjust PA 
#     [Arguments]   ${value}=${CASE_INPUT_5GC001817['5GC001817_A_05']['PA_Value_1']}
#     KW.PA_Adjust Attenuation Ports Value acording config    ports=${5GRU1_PA_Ports}
#     ...    value=${value}   attenuator=${PA1_INFO}
#     ...    logging_message=Setting PA values 
# 
# UE teardown
#     run keyword and ignore error   Stop DL traffic and check the TP on EPC   ue_index=${ue_index}
#     run keyword and ignore error   Stop UL traffic and check the TP on EPC   ue_index=${ue_index}    iperf_type=via_command
#     run keyword and ignore error   power_ue.UE Detach    ue_type=samsung   ue_index=${ue_index}
#     #run keyword and Ignore error    BtsLog.StopBTSlogandGetlog
#     Run Keyword And Ignore Error    run    command=ps xafu |grep node|grep -v grep|awk '{print $2}' | xargs kill -9
#     Run Keyword And Ignore Error    run    command=killall firefox
#     Run Keyword And Ignore Error    run    command=killall geckodriver
#     Conn.ResetCache
# 
# Start DL UDP traffic via iperf command
#     [Arguments]    ${ue_index}=${0}    ${DL_port}=${tl.ues[${ue_index}].iperf_details.port}    ${time}=10
#     ...            ${interval}=1    ${traffic}=10.00M    ${buffer_size}=1024B
#     ...            ${process_num}=${1}
#     Get Commercial UE IP    ue_index=${ue_index}
#     wait until keyword succeeds    1 min    10 sec    Connect to EPC APP    ue_index=${ue_index}   
#     sleep   2s
#     csn.execute    command=ps -ef|grep iperf|grep -v grep|grep ${DL_port}| awk '{print $2}' |xargs kill -9    connection=EPCAPP
#     csn.send_command
#     ...    command=iperf -c ${UE_IP} -u -t ${time} -i ${interval} -p ${DL_port} -P ${process_num} -f m -b ${traffic} -l ${buffer_size} -T 64&
#     ...    connection=EPCAPP
#     log to console    .....UE_${ue_index} udp dl iperf start....
# 
# Check Throughtput 
#     [Arguments]        ${duration}=60    ${ul_target}=0.5   ${dl_target}=0.5      ${min_percent}=0
#     ${tput_log}    power_ue.Collect Tput    ue_type=${ue_type}    duration=${duration}     filter=L2Lo
#     run keyword and continue on failure     power_ue.Check Tput    ue_type=${ue_type}    direction=DL   log=${tput_log}
#     ...    cells=${first_cell_to_check}    target_throughput=${dl_target}         min_percent=${min_percent}
#     run keyword and continue on failure     power_ue.Check Tput    ue_type=${ue_type}    direction=UL   log=${tput_log}
#     ...    cells=${first_cell_to_check}    target_throughput=${ul_target}    min_percent=${min_percent}
# 
# Check DL Throughtput
#     [Arguments]        ${duration}=60    ${ul_target}=0.5   ${dl_target}=0.5      ${min_percent}=0
#     ${tput_log}    power_ue.Collect Tput    ue_type=${ue_type}    duration=${duration}     filter=L2Lo
#     run keyword and continue on failure     power_ue.Check Tput    ue_type=${ue_type}    direction=DL   log=${tput_log}
#     ...    cells=${first_cell_to_check}    target_throughput=${dl_target}       min_percent=${min_percent}
# 
# Collect DCAP
#     @{traces}    create list   L2Ps_Sherpa
#     run keyword and continue on failure    DCAP.Start_Collect_Trace   traces=${traces}
#     sleep   10s
#     #run keyword and continue on failure    DCAP.Stop_Collect_Trace_and_Get_Result
#     run keyword and continue on failure     Stop_Collect_Trace_and_Get_Result_test
# 
# KW.Verify_Sherpa_Logs
#     [Arguments]     ${ACSI_NOK_percent}=0.03 
#     [Documentation]  verify each checkpoint for sherpa.
#     FOR    ${item}    IN     @{folders_for_decoded_sherpa_logs}
#         KW.Check_Sherpa_log_ACSI    csv_filepath=${item}       ACSI_NOK_percent=${ACSI_NOK_percent}
#     END
# 
# KW.Check_Sherpa_log_ACSI
#     [Arguments]   ${csv_filepath}  ${acsi_mismatch_min}=-3    ${acsi_mismatch_max}=3    ${ACSI_NOK_percent}=0.07
#     ${num_of_ACSI_request}    run    command=cd ${csv_filepath} ; cat Sherpa_l1l2Trace.csv | grep "bitMapACSI=1" -c
#     Log to console   A-CSI request ${num_of_ACSI_request} times
#     Should Be True   0<${num_of_ACSI_request}
#     ${cmd1}   Set Variable    Sherpa_l1l2Trace.csv | grep "numOfUciCsiPart2Bits" | grep -v "numOfUciCsiPart2Bits=0" >ACSI.txt
#     ${cmd3}   Set Variable    ACSI.txt | grep "cqi" >ACSI_cqi.txt
#     ${all_numOfUciCsiPart2Bits}    run    command=cd ${csv_filepath} ; cat ${cmd1}
#     ${generate_ACSI_cqi}    run    command=cd ${csv_filepath} ; cat ${cmd3}
#     ${num_of_ACSI_report}    run    command=cd ${csv_filepath} ; cat ACSI.txt | grep "cqi" -c
#     ${num_of_psDTX}    run    command=cd ${csv_filepath}; cat ACSI_cqi.txt | grep "dtx=DTX" -c
#     ${num_of_part1DTX}    run    command=cd ${csv_filepath} ; cat ACSI_cqi.txt | grep "dtxCsiPart1=DTX" -c
#     ${num_of_part2DTX}    run    command=cd ${csv_filepath} ; cat ACSI_cqi.txt | grep "dtxCsiPart2=DTX" -c
#     ${num_of_part1CRCNOK}    run    command=cd ${csv_filepath} ; cat ACSI_cqi.txt | grep "csiPart1CrcCheck=1" -c
#     ${num_of_part2CRCNOK}    run    command=cd ${csv_filepath} ; cat ACSI_cqi.txt | grep "csiPart2CrcCheck=1" -c
#     ${cmd2}   Set Variable    ACSI_cqi.txt | grep -E "dtx=DTX\|dtxCsiPart1=DTX\|dtxCsiPart2=DTX\|csiPart1CrcCheck=1\|csiPart2CrcCheck=1" -c
#     ${num_of_allDTXCRCNOK}    run    command=cd ${csv_filepath} ; cat ${cmd2}
#     Should Be True  ${acsi_mismatch_min}< ${num_of_ACSI_request}-${num_of_ACSI_report} < ${acsi_mismatch_max}
#     Should Be True  ${num_of_allDTXCRCNOK}/${num_of_ACSI_report} < ${ACSI_NOK_percent}
# 
# KW.Check_Sherpa_log_UCIonly
#     [Arguments]   ${csv_filepath}
#     ${cmd3}   Set Variable    Sherpa_l1l2Trace.csv | grep "bitMapACSI=1" | grep "ulSchInd=0" -c
#     ${num_of_ucionly_true}  run    command=cd ${csv_filepath} ; cat ${cmd3}
#     Log to console   ucionly true ${num_of_ucionly_true} times
#     Should Be True  ${num_of_ucionly_true} >=1
#     
# KW.Verify_Sherpa_Logs_add_UCIonly_check
#     [Documentation]  verify each checkpoint for sherpa.
#     FOR    ${item}    IN     @{folders_for_decoded_sherpa_logs}
#         KW.Check_Sherpa_log_ACSI    csv_filepath=${item}
#         #KW.Check_Sherpa_log_UCIonly   csv_filepath=${item}
#     END
# 
# BtsLog.StopBTSlogandGetlog
#     core.stop_collectors      names=btslog
#     core.teardown_collectors      names=btslog
#     ${filename}    set variable    ${TEST NAME.replace(" ", "_").replace("(", "").replace(")", "").replace("[", "").replace("]", "")}
#     run    command=cd /tmp/btslog2 ; ls -al ; cat SYSLOG_*.LOG > SYSLOG_combine.LOG
#     run    command=cd /tmp/btslog2 ; tar zcvf /tmp/${filename}_SYSLOG.tgz SYSLOG_combine.LOG
#     run    command=cp /tmp/${filename}_SYSLOG.tgz ${LOG_PATH}/.
#     [Return]    ${LOG_PATH}/${filename}_SYSLOG.tgz
# 
# Preparation with swconfig modification 
#     [Documentation]  Author: Ding Binmei
#     ...              Description: Do modification for swconfig file and scf file.
#     ...              ${swconfig_modify}: Can be a list for the modified R&D parameters, example input with python format:
#     ...                                 ['0x580002=0', '0x580121=0']
#     ...              ${SWCONFIG_DEFAULT_FILE_PATH}: refers to the template swconfig file path in test pc,
#     ...                                             should be defined before calling this keyword
#     [Arguments]    ${swconfig_modify}=${None}   ${swconfig_template_path}=${SWCONFIG_DEFAULT_FILE_PATH}   
#     ...            ${is_called_in_test_case_level}=${False}
#     ...            ${gnb_index}=${0}    ${du_index}=${0}    ${connection}=GNB_OAM    ${alias}=ASIK Master
#     COAM Create log directory    is_set_to_test_case_level=${is_called_in_test_case_level}
#     Connect to Common Unit Master    gnb_index=${gnb_index}    du_index=${du_index}    alias=${alias}
#     ${local_log_file_folder}    set variable if  ${is_called_in_test_case_level}==${True}    ${TS_CASE_LOG_PATH}    ${SUITE_LOG_PATH}
#     ${default_swconfig_file_path}    Copy file    source=${swconfig_template_path}    destination=${local_log_file_folder}/swconfig.txt
#     Run keyword if    ${swconfig_modify}!=${None}
#     ...    Run keywords    Log to console    Swconfig file modification is needed.    AND
#     ...    swconf.Modify swConfig file    parametersList=${swconfig_modify}    filePath=${default_swconfig_file_path}
#     swconf.Upload swConfig file to asik and crasign    localFilePath=${default_swconfig_file_path}    asik_alias=${alias}
#     csn.disconnect    connection=${alias}
# 
# DownloadLogToUTEFromContainer
#     [Arguments]    ${filename}    ${nodename}    ${localpath}=${LOG_PATH}    ${gnbip}=${ASIK_IP}
#     ${isPrimaryCoreInLeftSubrack}    gNB.IsPrimaryCoreInLeftSubrack
#     DP.setup    gnbip=${gnbip}    isPrimaryCoreInLeftSubrack=${isPrimaryCoreInLeftSubrack}
#     DP.download_file_from_container     filename=${filename}    nodename=${nodename}    localpath=${localpath}
#     [Return]    ${localpath}/${filename}
# 
# SCF commission
#     [Arguments]    ${SCF}
#     coam_gnb_classical.Connect to gnb coam via ssl
#     ${result}    coam_gnb_classical.COAM Commission with scf file    scf_file_path=${SCF}
#     ...    is_pdl_checking_needed=${True}    timeout=900
#     wait until keyword succeeds    1200      5    coam_gnb_classical.COAM Check GNB cell on air
#     [Teardown]    Run keyword and ignore error    Run keywords    csn.disconnect    connection=ASIK Master    AND
#     ...    coam_gnb_classical.COAM Teardown gnb connections    connection=GNB_OAM
# 
# SCF delta recommission
#     [Arguments]    ${delta_file}
#     coam_gnb_classical.Connect to gnb coam via ssl
#     run keyword and ignore error     csn.disconnect    connection=ASIK Master
#     coam.perform_delta_recommissioning    delta_file=${delta_file}
#     ...                                   skip_parameter_relation_errors=${true}
#     ...                                   should_activate=${true}
#     ...                                   timeout=${600}
#     ...                                   connection=GNB_OAM
#     wait until keyword succeeds    1200      5    coam_gnb_classical.COAM Check GNB cell on air
#     [Teardown]    Run keyword and ignore error    Run keywords    csn.disconnect    connection=ASIK Master    AND
#     ...    coam_gnb_classical.COAM Teardown gnb connections    connection=GNB_OAM
# 
