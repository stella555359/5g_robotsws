*** Settings ***
Documentation       attach script
Library    String
Library    DateTime
Library    Collections
Library    OperatingSystem
Library    ../../../ORAN/resources/python/ta_ultracaller/
Library    taf.collectors.tcpdump    WITH NAME    tcpdump
Library    taf.collectors.tshark    WITH NAME    tshark
Library    taf.collectors.core    WITH NAME    core1
#Library	   Tshark_Validation.py
Library    SSHLibrary
Library    SeleniumLibrary
Library    taf.selenium.gnb.oam.coam.classical    WITH NAME    seleLib
Library    taf.gnb.oam.coam.admin    WITH NAME    CoamAdmin
Library    taf.transport.ssh  WITH NAME  SSH
Library    taf.sw.dcap.rd   WITH NAME   rd
Library    Telnet
#Library    hran_extract

*** Variables ***
${VM_IP}    10.68.126.85
${VM_usn}    ute
${VM_pwd}    BT5l@bus3rl0g1n
${LOG_PATH}=    ${OUTPUT_DIR}
@{capabilities}    Legacy_1
@{UE_alias}=  UE1
@{timeout}=    50
${dt_name_dl}=    iperf_dl_test_1
${dl_name}=    iperf_dl_test_1
@{deviation_dl}=    40
@{throughput_dl}=    160
@{direction_dl}=      dl
@{call_type}=    TCP
${DURATION}    100s
${i}    0
&{BTS_INFO}    host=${BTS_M_plane_ip}	port=${port}
${BTS_M_plane_ip}    10.68.126.113
${DCAP_host}    10.58.239.215
@{gnb_custom_filters}    condor5gSyslog     cp_5g
@{bts_custom_filter}    ipCapture
@{collection_timing}    Immediate       TraceEnd
${Default_DCAP_duration}    10
${dcap_log_timeout}    1200
${port}    443      	# Port value for DCAP connection
${secure}    True    	# Secure value for DCAP connection
${rd_version}    dcapv3   	# DCAP version
${dcapusr}    utfuser
${dcappwd}    utfadmin!
${out}    ${OUTPUT_DIR}
${filter}    ngap
@{list}   InitialContextSetupRequest  InitialContextSetupResponse  PDUSessionResourceSetupRequest   PDUSessionResourceSetupResponse


*** Keywords ***
Attach_UE
    [Arguments]  ${dependent_cells}=${None}
    Get TcpdumpLogs from Remote machine
    Prepare UE    UE_alias=${UE_alias}     capabilities=${capabilities}    timeout=${timeout}
    Attach ue and run throughput    ${UE_alias}    call_type=${call_type}   direction=${direction_dl}  throughput=${throughput_dl}
    ...  deviation=${deviation_dl}   timeout=${timeout}
    Stop tcpdump collector      /home/ute/rfrl_script/pcap
    Start wireshark pcap File Conversion To Text        /home/ute/rfrl_script/      pcap/tcpdump/   trial   ${filter}
    Builtin.Log     ${dependent_cells}

Attach_UE_old
    Get TcpdumpLogs from Dcap
    Prepare UE    UE_alias=${UE_alias}     capabilities=${capabilities}    timeout=${timeout}
    Attach ue and run throughput    ${UE_alias}    call_type=${call_type}   direction=${direction_dl}  throughput=${throughput_dl}
    ...   deviation=${deviation_dl}   timeout=${timeout}
    Dcap Stop Trace and Get results SA    DCAPlog
	Convert PCAP and validate

Prepare UE
    [Arguments]     ${UE_alias}     ${capabilities}    ${timeout}
    ${a}=     ta_ultracaller.Require UE   ue_alias=${UE_alias}   capabilities=${capabilities}
    log	  ${a}
    Builtin.Log     ${timeout}

Attach ue and run throughput
    [Arguments]     ${UE_alias}    ${call_type}    ${direction}    ${throughput}    ${deviation}    ${timeout}
    ta_ultracaller.Detach UE     ue_alias=${UE_alias}
    ta_ultracaller.Attach UE     ue_alias=${UE_alias}
    Sleep     40
    Log To Console    UE Attach Successful
    ta_ultracaller.start_datatransfer  ${UE_alias}  ${call_type}  direction=${direction}
    ta_ultracaller.await_data_transfer_finish    ${UE_alias}    ${direction}    ${timeout}
    Log To Console    UE Data Transfer Successful
    ta_ultracaller.Detach UE     ue_alias=${UE_alias}
    sleep    20
    ${tput}    Run Keyword And Ignore Error       ta_ultracaller.calculate_thrughtput    ue_alias=${UE_alias}
    ...    direction=${direction}   thrughtput=${throughput}    deviation=${deviation}

Get TcpdumpLogs from Dcap
    [Documentation]    this keyword is used to capture wireshark log in Dcap
    Create dcap session
	log to console    Starting Ipcapture in DCAP
	Dcap Start Trace SA


Create dcap session
    [Documentation]    Establish DCAP session
    rd.connect_to     host=${DCAP_host}     port=${port}    username=${dcapusr}    password=${dcappwd}
    ...     rd_version=${rd_version}    secure=${secure}


Dcap Start Trace SA
    [Documentation]     Start DCAP logs with custom filter
    Log to console      \nStarting DCAP trace
#    ${output}       rd.start_trace  duration=${Default_DCAP_duration}     bts=${BTS_INFO}    gnb_custom_profile=@{gnb_custom_filters}
    ${output}       rd.start_trace  duration=${Default_DCAP_duration}     bts=${BTS_INFO}
    ...     bts_custom_profile=@{bts_custom_filter}		collection_timing=@{collection_timing}
    Sleep       120      reason=Wait for DCAP start
    ${START_TRACE_ID}      Get from Dictionary    ${output}    tracer_id
    Set Suite Variable  ${START_TRACE_ID}
    LOG      DCAP log collection has been started in the gNB

Dcap Stop Trace and Get results SA
    [Arguments]    ${testcase_name}
    [Documentation]     Stops DCAP and collect logs
    rd.stop_trace    trace_id=${START_TRACE_ID}    timeout=100
    LOG to console    DCAP logging stopped
    create directory         ${out}/${testcase_name}
    rd.get_results    result_id=${START_TRACE_ID}    target_dir=${out}/${testcase_name}/DCAP_logs    timeout=${dcap_log_timeout}

SSH_connection
    [Arguments]    ${IP}    ${username}    ${pwd}
    SSHLibrary.Open Connection    ${IP}    port=22
    SSHLibrary.Login    ${username}    ${pwd}

SSH_teardown
    sshlibrary.close connection

Convert PCAP and validate
    Convert wireshark pcap File To Text    DCAPlog    ${filter}
	ZIP_Rename_Delete_DCAPLOG

Convert wireshark pcap File To Text
	[Arguments]    ${testcase_name}    ${filter}
	[Documentation]        Convert Wireshark logs collected from DCAP
	${path1}     Set Variable        ${out}/${testcase_name}/
    ${source_paths}    Set Variable        ${path1}Extracted/
    create directory         ${source_paths}
	${date}    Get Current Date    result_format=%Y%m%d
    ${files}    OperatingSystem.List Files In Directory    ${path1}
    FOR    ${zip}    IN    @{files}
        #log to console    uncomment below line and hran extract lib
        hran_extract.unzip        ${path1}${zip}        path_to_unpacked=${source_paths}
	END
	${files}    OperatingSystem.List Directories In Directory    ${source_paths}
	${filename}    Set Variable    ${files}[0]
	${it}=    OperatingSystem.List Directory    ${source_paths}${filename}
	FOR    ${out_index}    IN    @{it}
        Run keyword And Ignore Error    Start wireshark pcap File Conversion To Text    source_path=${source_paths}${filename}
        ...     source_file=${out_index}    testcase_name=${testcase_name}    filter=${filter}
    END


Start wireshark pcap File Conversion To Text
    [Arguments]    ${source_path}     ${source_file}    ${testcase_name}    ${filter}
	SSH_connection    ${VM_IP}    ${VM_usn}    ${VM_pwd}
    SSHLibrary.write    cd /home/ute
    ${command}=    set variable    tshark -r ${source_path}/${source_file}/*.pcap -Y "${filter}" > ${source_path}/${source_file}/tcpdump.txt
    SSHLibrary.write    ${command}
    sleep    30s
    ${filepath}    set variable    ${source_path}/${source_file}/tcpdump.txt
    ${file}=    OperatingSystem.Get file    ${filepath}
    SSH_teardown
	validate wireshark logs    ${file}    InitialContextSetupRequest    0
	validate wireshark logs    ${file}    InitialContextSetupResponse    0
    validate wireshark logs    ${file}    PDUSessionResourceSetupRequest    0
	validate wireshark logs    ${file}    PDUSessionResourceSetupResponse    0
    Builtin.Log     ${testcase_name}

Get TcpdumpLogs from Remote machine
    [Documentation]    this keyword is used to capture wireshark log in wireshark PC
    log to console    \n--Starting Wireshark Logs--
    ${executor_oam_vm}=  Create Dictionary
    ...  host=10.68.126.113
    ...  user=toor4nsn
    ...  password=oZPS0POrRieRtu
    tcpdump.create_tcpdump_collector
    ...    name=tcpdump
    ...    options=-i br0.902
    ...    executor=${executor_oam_vm}
    core1.setup_collectors    names=tcpdump
    core1.set_suite_alias    tcpdump
    core1.start_collectors    names=tcpdump
    core1.start_collectors    names=tcpdump

Stop tcpdump collector
    [Arguments]     ${output_dir}
    core1.stop_collectors    names=tcpdump
    core1.collect_collectors    names=tcpdump       target_dir=${output_dir}
    core1.teardown_collectors    names=tcpdump


validate wireshark logs
    [Documentation]    this keyword is used to validate wireshark logs
    [Arguments]    ${log1}    ${message}    ${content}
    @{log}    Split to lines    ${log1}
    FOR    ${a}    IN    @{log}
         ${status}    run keyword and return status    should contain    ${a}    ${message}
         run keyword if    '''${status}'''=='''True''' and '''${content}'''=='''0'''    exit for loop
         ${status}    run keyword if    '''${status}'''=='''True'''    For loop for wireshark validation    ${a}    ${content}
         ${status}    run keyword if    '''${status}'''=='''True'''    exit for loop
    END
    Run Keyword if    '''${status}'''=='''True'''    Log to console    ${message} message is found in wireshark log
    ...    ELSE    Log to console     ${message} message is not found in wireshark log
    Run Keyword if    '''${status}'''!='''True'''    fail


For loop for wireshark validation
    [Arguments]    ${log}    ${message}
    ${list_length}    Get Length    ${message}
    FOR    ${a}    IN    @{message}
        ${status}    run keyword and return status    should contain    ${log}    ${a}
        ${count}    run keyword if    '''${status}'''=='''True'''     Evaluate    ${count} + 1
        run keyword if    '''${count}'''=='''${list_length}'''    exit for loop
    END
    [Return]    ${status}


ZIP_Rename_Delete_DCAPLOG
    [Documentation]    This keyword is used to Zip,rename,delete previous collected PCAP log from DCAP
    SSH_connection    ${VM_IP}    ${VM_usn}    ${VM_pwd}
	SSHLibrary.write    cd ${out}/DCAPlog
	${current_datetime}=    Get Time    epoch
	${filename}    set variable    ${current_datetime}.zip
	SSHLibrary.write    zip -r ${out}/${filename} ./*
	sleep    1min
	SSHLibrary.write    rm -r ${out}/DCAPlog
	sleep    1min
	SSH_teardown