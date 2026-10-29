*** Settings ***


*** Variables ***


*** Keywords ***
Start BTSlog
    [Arguments]    ${name}=btslog    ${btslog_path}=/opt/btslog/btslog
    ...    ${btslog_launcher_path}=/opt/btslog/btslog_launcher    ${log_dir}=/tmp/btslog2
    [Documentation]    This keyword is to create btslog log collector on testvm.
    ...
    ...    | Input Parameters | Man. | Description |
    ...    | ${name} | No | log name. e.g. btslog |
    ...    | ${btslog_path} | No | path of the 'btslog' executable default value:"/opt/btslog/btslog" |
    ...    | ${btslog_launcher_path} | No | path of 'btslog_launcher' |
    ...    |  |  | executable default value:"/opt/btslog/btslog_launcher" |
    ...    | ${log_dir} | No | path from where to get btslog files default value: "/tmp/btslog2" |
    ...
    ...    Examples:
    ...    | Start BTSlog | log_dir=${TEST_LOG_DIRECTORY} |  |
    Run Keyword And Ignore Error    OperatingSystem.Run    pkill btslog
    ${executor_test_vm}=    Create Dictionary    host=${tl.test_pc.default_ssh_connection_details.addr}
    ...                                          user=${tl.test_pc.default_ssh_connection_details.username}
    ...                                          password=${tl.test_pc.default_ssh_connection_details.password}
    Run    rm -rf ${log_dir}/SYSLOG*.LOG
    btslog.create_btslog_collector
    ...    name=${name}
    ...    btslog_path=${btslog_path}
    ...    btslog_launcher_path=${btslog_launcher_path}
    ...    executor=${executor_test_vm}
    ...    log_dir=${log_dir}
    CORE.Setup Collectors    names=${name}
    CORE.Start Collectors    names=${name}
    btslog.Set Suite Alias    ${name}

Stop BTSlog
    [Arguments]    ${collector_name}=btslog    ${log_dir}=${TEST_LOG_DIRECTORY}
    CORE.Stop Collectors    names=${collector_name}
    CORE.Collect Collectors    names=${collector_name}    target_dir=${log_dir}
    CORE.Teardown Collectors    names=${collector_name}

Start GNB Syslog
    [Arguments]    ${log_dir}=${TEST_LOG_DIRECTORY}
    Run Keyword And Ignore Error    ute_syslog.Stop Syslog    alias=${GNB_SYSLOG.alias}
    ute_syslog.Start Syslog    file_limit=${GNB_SYSLOG.file_limit}    log_dir=${log_dir}
    ...    log_name=${GNB_SYSLOG.log_name}    ip=${GNB_SYSLOG.ip}    alias=${GNB_SYSLOG.alias}

Stop And Collect GNB Syslog
    [Arguments]    ${log_dir}=${TEST_LOG_DIRECTORY}
    Log To Console    Stop GNB Syslog...
    ute_syslog.Collect Syslog Results    alias=${GNB_SYSLOG.alias}    unzip=true    destination=${log_dir}/GNB_syslog
    ${rc}    ${output}=    OperatingSystem.Run And Return Rc And Output    ls -t ${log_dir}/GNB_syslog | head -n 1
    Log To Console    ${log_dir}/GNB_syslog/${output}
    [Return]    ${log_dir}/GNB_syslog/${output}


Start GNB BIP By Admin Method
    [Arguments]    ${mirroring_time}=600    ${interface}=L1-L2    ${destination}=Local
    [Documentation]    this keyword is used for catch gnb bip log on webem:Diagnosis -> Mirroring -> Interface Mirroring
    ...    now it doesn't support ASOE. Note: L2-PS,L2lo <-> L1,L2hi <-> L2lo,L2hi doesn't have message with L2-PS and L1,
    ...    | Input Parameters | Man. | Description |
    ...    | ${interface} | No | bip type: L1-L2/L2Hi-L2Lo,for l1bypss testine, choose L2Hi-L2Lo |
    ...    | ${destination} | No | Local/Remote |
    ...    | ${mirroring_time} | No | 0~2147483647 |
    #Run Keyword And Ignore Error    Stop Gnb BIP By Admin Method
    Run    sshpass -p oZPS0POrRieRtu ssh toor4nsn@192.168.255.1 rm -rf /tmp/CCSPacketCapture/*
    COAM.Setup Admin    timeout=120
    COAM.Interface mirroring    interface=${interface}    destination=${destination}    mirroring_time=${mirroring_time}    operation=Start
    [Teardown]    COAM.Teardown

Collect GNB BIP By Admin Method
    [Arguments]    ${log_path}=${OUTPUT_DIR}
    Run    mkdir -p ${log_path}
    Run Keyword And Ignore Error    Run    rm -rf ${log_path}/mirroring_L2L1*
    Run    sshpass -p oZPS0POrRieRtu ssh toor4nsn@192.168.255.1 ls -al /tmp/CCSPacketCapture
    Run    sshpass -p oZPS0POrRieRtu scp toor4nsn@192.168.255.1:/tmp/CCSPacketCapture/* ${log_path}
    Run    ls -1 ${log_path}
    Run    mergecap -a -w ${log_path}/5GBipL2L1_filtering_off.pcap ${log_path}/mirroring_L2L1*
    ${bip_file}=    Set Variable    ${log_path}/5GBipL2L1_filtering_off.pcap
    OperatingSystem.File Should Exist    ${bip_file}
    Log To Console    bip log:${bip_file}
    [Return]    ${bip_file}

Stop Gnb BIP By Admin Method
    [Arguments]    ${log_path}=${OUTPUT_DIR}    ${interface}=L1-L2    ${destination}=Local    ${mirroring_time}=600
    COAM.Setup Admin    timeout=120
    COAM.Interface mirroring    interface=${interface}    destination=${destination}    mirroring_time=${mirroring_time}    operation=Stop
    Collect GNB BIP By Admin Method    ${log_path}
    [Teardown]    COAM.Teardown

Start Ttitrace With Streaming Mode
    [Arguments]    ${names}=l2stream3_ttitrace
    ...    ${gnb_index}=0
    ...    ${eth_port_on_ute}=eth0
    ...    ${eth_ip_addr_on_ute}=${tl.test_pc.default_ssh_connection_details.addr}
    ...    ${localIpAddr}=${tl.gnbs[${gnb_index}].cu.oam_ssh_connection_details.addr}
    [Documentation]    This keyword is used to start ttitrace with streaming mode.
    ...    examples 1: catch all cells
    ...    Start Ttitrace With Streaming Mode
    log to console    setup admin for ttitrace...
    Run Keyword If    '${SW_BRANCH}'=='${EMPTY}'    Get Software Version
    ${executor}=  Create Dictionary
    ...  host=${localIpAddr}
    ...  user=Nemuadmin
    ...  password=nemuuser
    ...  port=443
    ...  release=${SW_BRANCH}

    TCPDUMP.create tcpdump collector
    ...  name=tcpdump_ttitrace
    ...  options=-i ${eth_port_on_ute} udp and dst ${eth_ip_addr_on_ute} and dst port 5678
    ...  sudo_password=${tl.test_pc.default_ssh_connection_details.password}
    L2STREAM3.create_sbts_l2stream_collector
    ...  name=${names}
    ...  destination_ip_addr=${eth_ip_addr_on_ute}
    ...  collector=tcpdump_ttitrace
    ...  l2_stream_configuration=${L2STREAM_COMPONENT_CONFIG}
    ...  webservice=${executor}
    ...  dscp=10
    L2STREAM3.Set Suite Alias
    ...  alias=${names}
    CORE.setup_collectors
    ...  names=${names}
    CORE.start_collectors
    ...  names=${names}
    log to console    finish admin process for ttitrace,start to catch ttitrace log...

Stop Ttitrace
    [Arguments]    ${names}=l2stream3_ttitrace    ${log_dir}=${OUTPUT_DIR}/ttitrace_streaming/
    log to console    stop catching ttitrace...
    CORE.stop_collectors
    ...  names=${names}
    CORE.collect_collectors
    ...  names=${names}    target_dir=${log_dir}
    CORE.teardown_collectors
    ...  names=${names}

Capture Convert Format Ttitrace With Streaming Mode
    [Arguments]    ${capture_time}    ${log_dir}=${TEST_LOG_DIRECTORY}/ttitrace_streaming/    ${filters}=${EMPTY}
    [Documentation]    This keyword is to capture convert format ttitrace log, it also can set filter
    Start Ttitrace With Streaming Mode
    Sleep    ${capture_time}    reason=capture ttitrace
    Stop Ttitrace    log_dir=${log_dir}
    Convert Ttitrace From Pcap To Excelcsv    ${log_dir}
    ${csv_files}    OperatingSystem.List Files In Directory    ${log_dir}    output_*.csv    ${True}
    # FOR    ${index}    ${csv_file}    IN ENUMERATE    @{csv_files}
    #     ${format_file}    Replace String    ${csv_file}    .csv    _formated.csv
    #     Format Tti In Stream Mode    ${csv_file}    ${format_file}    ${filters}
    # END
    # Log To Console    Please Find ttitrace log in ${log_dir}

Convert Ttitrace From Pcap To Excelcsv
    [Arguments]    ${log_path}=${OUTPUT_DIR}/ttitrace_streaming/    ${names}=l2stream3_ttitrace
    [Timeout]    30min
    ${file_path}=    Set Variable    ${log_path}/${names}/tcpdump_ttitrace/tcpdump_ttitrace.pcap
    OperatingSystem.Run    mkdir -p ${log_path}; cp -r "${file_path}" ${log_path}
    EVENTDECODER.Create Eventdecoder Converter
    ...    name=converter
    ...    input_file_path=${file_path}
    ...    output_file_format=excelCsv
    ...    excel_csv_options=-w
    EVENTDECODER.Convert
    ...    name=converter
    OperatingSystem.Run    mkdir -p ${log_path}
    OperatingSystem.Run    cp ${EXECDIR}/output_dl*.csv ${log_path};cp ${EXECDIR}/output_ul*.csv ${log_path}
    List Files In Directory    ${log_path}

Convert Ttitrace From Pcap To Legacycsv
    [Arguments]    ${log_dir}=${TEST_LOG_DIRECTORY}/ttitrace_streaming/    ${names}=l2stream3_ttitrace
    [Timeout]    30min
    ${file_path}=    Set Variable    ${log_dir}/${names}/tcpdump_ttitrace/tcpdump_ttitrace.pcap
    OperatingSystem.Run    mkdir -p ${log_dir}; cp -r "${file_path}" ${log_dir}
    EVENTDECODER.Create Eventdecoder Converter
    ...    name=converter
    ...    input_file_path=${file_path}
    ...    output_file_path=${log_dir}/${names}/
    ...    output_file_format=legacyCsv
    EVENTDECODER.Convert
    ...    name=converter
    OperatingSystem.Run    mkdir -p ${log_dir}
    OperatingSystem.Run    mv ${log_dir}/${names}/tcpdump_ttit/* ${log_dir}
    OperatingSystem.Run    rm -rf ${log_dir}/${names}

Save Coam SnapShot
    [Arguments]    ${log_dir}=${test_log_directory}    ${bts_host}=${SBTS_ADDR}
    ${coam_connection}    coam.Connect To    bts_host=${bts_host}
    coam.Get SnapShot    target_file_name=${log_dir}/snapShot.zip    coverage=Full    force=True    connection=${coam_connection}
    [Teardown]    coam.Teardown    ${coam_connection}