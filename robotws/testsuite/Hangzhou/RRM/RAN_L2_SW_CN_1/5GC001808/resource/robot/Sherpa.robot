*** Settings ***
Documentation     This file implements Sherpa keywords with in particular:
...               Support to configure Sherpa traces on gNB
...               Support to collect traces via UDP traces on WTS
...               Support to manage Sherpa installed on debian container via docker
...               About docker
...               docker usage is useful for running test on not debian VMs
...               In this case Sherpa can be installed and run in a container
...               thanks to docker
...               Author: Davide Bacchiega
...               contact: davide.bacchiega@nokia.com
...               Creation Date: 18-Nov-2019
...               Modified Date: 10-Jan-2020
...               Last Modified by: davide.bacchiega@nokia.com
Library           OperatingSystem
Library           DateTime
Library           String
Library           Process
Library           taf.transport.ssh    WITH NAME    csn
Library           ../python/SherpaCsvReader.py
Library           ../python/StringTool.py

*** Variables ***
${UDP_TRACER}     udptracer
${L2RT_NODEID}    4682    # ipv4: 4666; ipv6: 4682
${L2HI_NODEID}    5946    # ipv6: 5946; ipv4: 57354
${DCAP_SHERPA_FILE_DIR}    /sharedvolume/udptracer/_data
${SHERPA_LOG_DIR}    /home/ute/Sherpa_logs    # Sherpa logs dir on Sherpa Sever
${LOCAL_LOG_DIR}    /home/ute/sherpa_pcaps    # Local Sherpa logs dir on UTE VM which is running cases

*** Keywords ***
Configure gNb for sherpa traces
    [Documentation]    Configures the gNb TRSW icom gateway for Sherpa traces
    #################################################################################################
    #    sherpa traces activation and capture keywords
    #################################################################################################
    ssh.connect to    hostname=${DU_HOST}    username=${DU_USER}    password=${DU_PWD}    alias=gNB_ASIK
    csn.execute    command=/opt/trs/bin/trs-vppctl icom 630_mode enable    connection=gNB_ASIK
    csn.execute    command=/opt/trs/bin/trs-vppctl icom classical_mode enable    connection=gNB_ASIK
    ${cmd} =    Catenate    /opt/trs/bin/trs-vppctl icom set_stream_conf src_ip    ${GNB_MPLANE_IP} dst_ip ${UDP_RECEIVER_WTS_IP}    
    ...    dscp 32 dst_port ${TRACE_DESTINATION_PORT}
    csn.execute    command=${cmd}    connection=gNB_ASIK
    BuiltIn.Log    \n Execute command: "${cmd}" on gNB    console=yes
    ${output} =    csn.execute    command=/opt/trs/bin/trs-vppctl icom classical_mode status    connection=gNB_ASIK
    Should Contain    ${output}    [ENABLED]
    BuiltIn.Log    Configure gNB for Sherpa tarces is OK    console=yes

Set Sherpa traces on gNB
    [Arguments]    ${set_type}    ${pciList}="[]"
    [Documentation]    activates Sherpa traces on gnb L2
    ...    PS, LO, HI can be tuned separately
    ssh.connect to    hostname=${DU_HOST}    username=${DU_USER}    password=${DU_PWD}    alias=Du_Conn
    Set Sherpa for L2SW    l2ps    ${set_type}    Du_Conn    ${pciList}
    Set Sherpa for L2SW    l2lo    ${set_type}    Du_Conn    ${pciList}
    Set Sherpa for L2SW    l2hiRlc    ${set_type}    Du_Conn    ${pciList}
    Set Sherpa for L2SW    l2hiPdcp    ${set_type}    Du_Conn    ${pciList}

Set Sherpa for L2SW
    [Arguments]    ${sw_type}    ${set_type}    ${conn}    ${pciList}="[]"
    ${nodeId}    Set Variable If    '${sw_type}' == 'l2ps' or \ '${sw_type}' == 'l2lo'    ${L2RT_NODEID}    ${L2HI_NODEID}
    ${cmd2}    Set Trace curl command    ${pciList}    nodeId=${nodeId}    upSw=${sw_type}    traceType=sherpa    cmd_type=${set_type}
    ${output} =    csn.execute    command=${cmd2}    connection=${conn}
    Should Contain    ${output}    HTTP/1.1 200 OK

Set Component traces on gNB
    [Arguments]    ${set_type}
    [Documentation]    activates Sherpa traces on gnb L2
    ...    PS, LO, HI can be tuned separately
    ssh.connect to    hostname=${DU_HOST}    username=${DU_USER}    password=${DU_PWD}    alias=Du_Conn
    Set Component Trace for L2SW    l2ps    ${set_type}    Du_Conn
    Set Component Trace for L2SW    l2lo    ${set_type}    Du_Conn
    Set Component Trace for L2SW    l2hiRlc    ${set_type}    Du_Conn
    Set Component Trace for L2SW    l2hiPdcp    ${set_type}    Du_Conn

Set Component Trace for L2SW
    [Arguments]    ${sw_type}    ${set_type}    ${conn}
    ${nodeId}    Set Variable If    '${sw_type}' == 'l2ps' or \ '${sw_type}' == 'l2lo'    ${L2RT_NODEID}    ${L2HI_NODEID}
    ${cmd1}    Set Trace curl command    nodeId=${nodeId}    upSw=${sw_type}    traceType=component    cmd_type=${set_type}
    ${output} =    csn.execute    command=${cmd1}    connection=${conn}
    Should Contain    ${output}    HTTP/1.1 200 OK

Set Trace curl command
    [Arguments]    ${pciList}="[]"    ${nodeId}=None    ${upSw}=None    ${traceType}=None    ${cmd_type}=None
    ${base_cmd} =    Set Variable    curl -i -H "Content-Type: application/json" -X POST -d '
    ${cmd_key} =    Set Variable    {"key":{"nodeId":${nodeId}, "upSw":"${upSw}", "traceType":"${tracetype}"},
    ${cmd_start} =    Set Variable    "data":{"state":"start", "eqId":268959744, "pciList":${pciList}}}'
    ${cmd_stop} =    Set Variable    "data":{"state":"stop", "eqId":268959744, "pciList":${pciList}}}'
    ${result_start}    Catenate    ${base_cmd} ${cmd_key} ${cmd_start} http://127.0.0.1:8008/troubleshooting/l2Stream
    ${result_stop}    Catenate    ${base_cmd} ${cmd_key} ${cmd_stop} http://127.0.0.1:8008/troubleshooting/l2Stream
    ${result} =    Set Variable If    '${cmd_type}' == 'start'    ${result_start}    ${result_stop}
    #################################################################################################
    #    Checking content in cvs sherpa generated files
    #################################################################################################
    [Return]    ${result}

Get values from one column in csv file
    [Arguments]    ${file}    ${ColumnName}
    SherpaCsvReader.setup_reader    ${file}
    ${result}    SherpaCsvReader.get all values column    ${ColumnName}
    BuiltIn.log    ${result}
    [Return]    ${result}

Verify Message presence in csv File
    [Arguments]    ${CsvName}    ${ColumnName}    ${MSGID}
    [Documentation]    verifies the presence of a given message in a cvs file issued from sherpa traces
    ...    returns True if found, False if not
    ${found} =    Set Variable    False
    @{my_dir} =    OperatingSystem.List Directory    ${TMP_PATH}/Sherpa_logs
    FOR    ${dir}    IN    @{my_dir}
    ${found} =    Loop on files    ${dir}    ${CsvName}    ${ColumnName}    ${MSGID}
    Exit For Loop If    "${found}"=="True"
    Should be equal    "${found}"    "True"
    [Return]    ${found}

Loop on files
    [Arguments]    ${my_dir}    ${CsvName}    ${ColumnName}    ${MSGID}
    ${found} =    Set Variable    False
    @{my_sub_dir} =    OperatingSystem.List Directory    ${TMP_PATH}/Sherpa_logs/${my_dir}
    FOR    ${file}    IN    @{my_sub_dir}
    BuiltIn.Log    File is:\n ${file}    console=yes
    ${found}    Run Keyword if    "${file}"==${CsvName}    Check Values In File    ${TMP_PATH}/Sherpa_logs/${my_dir}/${file}    ${ColumnName}    
    ...    ${MSGID}
    ...    ELSE    Set Variable    False
    Exit For Loop If    "${found}"=="True"
    [Return]    ${found}

Check Values In File
    [Arguments]    ${file}    ${ColumnName}    ${MSGID}
    [Documentation]    verifies the presence of a given set of values in a cvs file issued from sherpa traces
    ...    returns True if all of them are found, False if not
    SherpaCsvReader.setup reader    ${file}
    ${result}    SherpaCsvReader.check all values for column    ${ColumnName}    ${MSGID}
    #################################################################################################
    #    Docker container management keywords
    #################################################################################################
    [Return]    ${result}

List Docker images
    [Arguments]    ${conn}
    [Documentation]    lists available docker images on a VM
    ...    About docker
    ...    docker usage is useful for running test on not debian VMs
    ...    In this case Sherpa can be installed and run in a container
    ...    thanks to docker
    ${output} =    csn.execute    command=docker images    connection=${conn}
    BuiltIn.Log    ${output}
    @{lines} =    Split To Lines    ${output}
    ${lines_nr} =    Get Length    ${lines}
    BuiltIn.Log    \nfound ${lines_nr} lines!    console=yes
    Comment    ${lines}    Set Variable    @{lines}
    ${result}    Run Keyword If    ${lines_nr}>${1}    Get Docker Images Names    @{lines}
    ...    ELSE    Create List
    [Return]    ${result}

List Running Containers
    [Arguments]    ${conn}
    [Documentation]    lists running docker containers on a VM
    ${output} =    csn.execute    command=docker ps -a | grep Up    connection=${conn}
    BuiltIn.Log    ${output}
    @{lines} =    Split To Lines    ${output}
    ${lines_nr} =    Get Length    ${lines}
    BuiltIn.Log    \nfound ${lines_nr} lines!    console=yes
    ${result}    Run Keyword If    ${lines_nr}>${0}    Get Docker Running Containers Names    ${lines}
    ...    ELSE    Create List
    [Return]    ${result}

List All Containers
    [Arguments]    ${conn}
    [Documentation]    lists running docker containers on a VM
    ${output} =    csn.execute    command=docker ps -a    connection=${conn}
    @{lines} =    Split To Lines    ${output}
    ${lines_nr} =    Get Length    ${lines}
    ${result}    Run Keyword If    ${lines_nr}>${1}    Get Docker Running Containers Names    ${lines}
    ...    ELSE    Create List
    [Return]    ${result}

Get Docker Images Names
    [Arguments]    @{lines_list}
    @{result_list} =    Create List
    ${curr_line}    Set Variable    ${EMPTY}
    FOR    ${curr_line}    IN    @{lines_list}
        @{image} =    Split String    ${curr_line}
        Run Keyword If    '@{image}[0]'!='REPOSITORY'    Append To List    ${result_list}    @{image}[0]
        BuiltIn.Log    \nFound repositories: \n ${result_list}    console=yes
    END
    [Return]    ${result_list}

Get Docker Running Containers Names
    [Arguments]    ${lines_list}
    @{result_list} =    Create List
    FOR    ${curr_line}    IN    @{lines_list}
        @{image} =    Split String    ${curr_line}
        ${last_element} =    Get From List    ${image}    -1
        @{to_add} =    Create List    @{image}[0]    ${last_element}
        Run Keyword If    '@{image}[0]'!='CONTAINER'    Append To List    ${result_list}    @{to_add}
    END
    [Return]    ${result_list}

Run Sherpa
    [Arguments]    ${conn}    ${output_path}    ${pcap_file}    ${duration}=None    ${prefix}=None    ${macro_period}=None    ${filter_IP}=None
    [Documentation]    runs Sherpa on a given pcap file with options
    ...    output_path: output dir path
    ...    duration: duration in seconds (optional)
    ...    prefix: prefix for generated csv files names (optional)
    ...    is_macro: macro mode activated (optional)
    ...    macro_period: stat period in ms - MUST BE >= 50 and 10 multiple - (optional)
    ...    macro_period: typical default value is 1000
    ...    filter_IP: IP filter to reduce output size from the pcap (optional)
    ...    Returns the return code of the command
    ssh.connect to    hostname=${SHERPA_SERVER}    username=${SHERPA_USER}    password=${SHERPA_PWD}    alias=${conn}
    BuiltIn.Log    ${prefix}    console=yes
    ${sherpa_dir} =    Set Variable    /opt/Nokia/Sherpa_5G_18
    ${sherpa_base_command} =    Set Variable    Sherpa.run --outputdir ${output_path}
    ${duration_opt} =    Set Variable if    '${duration}'!='None'    -d ${duration}    ${EMPTY}
    ${filter_IP_opt} =    Set Variable if    '${filter_IP}'!='None'    -f ${filter_IP}    ${EMPTY}
    ${optional_prefix_csv} =    Set Variable if    '${prefix}'!='None'    -p ${prefix}    ${EMPTY}
    ${optional_macro} =    Set Variable if    '${macro_period}'!='None'    -M ${macro_period}    ${EMPTY}
    ${raw_sherpa_command} =    Catenate    ${sherpa_base_command}    ${duration_opt}    ${optional_prefix_csv}    ${optional_macro}    
    ...    ${filter_IP_opt}    ${pcap_file}
    # Removes not single spaces in string
    ${sherpa_command} =    Replace String Using Regexp    ${raw_sherpa_command}    \\s{2,}    ${SPACE}
    BuiltIn.Log    ${sherpa_command}
    ${output} =    ssh.execute    /opt/Nokia/Sherpa_5G_18/${sherpa_command}    connection=Sherpa_Conn
    BuiltIn.Log    \nRunning command:\n/opt/Nokia/Sherpa_5G_18/${sherpa_command}    console=yes
    BuiltIn.Log    \nSherpa output:\n ${output}    console=yes

Start UDP Tracer Container
    Comment    Get UDP Tracer Container Status
    ssh.connect to    hostname=${DCAP_SERVER}    username=${DCAP_USER}    password=${DCAP_PWD}    alias=DCAP_Conn
    csn.execute    command=docker start \ ${UDP_TRACER}    connection=DCAP_Conn
    BuiltIn.Log    Start UDP Tracer Container is OK    console=yes

Stop UDP Tracer Container
    Comment    Get UDP Tracer Container Status
    ssh.connect to    hostname=${DCAP_SERVER}    username=${DCAP_USER}    password=${DCAP_PWD}    alias=DCAP_Conn
    csn.execute    command=docker stop ${UDP_TRACER}    connection=DCAP_Conn
    BuiltIn.Log    Stop UDP Tracer Container is OK    console=yes

Get UDP Tracer Container Status
    ssh.connect to    hostname=${DCAP_SERVER}    username=${DCAP_USER}    password=${DCAP_PWD}    alias=DCAP_Conn
    ${running_containers}    List Running Containers    DCAP_Conn
    ${all_containers}    List All Containers    DCAP_Conn
    ${udp_is_running}    Set Variable    False
    FOR    ${container}    IN    @{running_containers}
        ${udp_is_running}    Set Variable If    '${container}' == '${UDP_TRACER}'    True    False
        Run Keyword If    '${container}' == '${UDP_TRACER}'    Exit For Loop
    END
    ${udp_is_created}    Set Variable    False
    FOR    ${container}    IN    @{all_containers}
        ${udp_is_created}    Set Variable If    '${container}' == '${UDP_TRACER}'    True    False
        Run Keyword If    '${container}' == '${UDP_TRACER}'    Exit For Loop
    END

Upload sherpa logs to Sherpa Server
    ssh.connect to    hostname=${DCAP_SERVER}    username=${DCAP_USER}    password=${DCAP_PWD}    alias=DCAP_Conn
    ssh.connect to    hostname=${SHERPA_SERVER}    username=${SHERPA_USER}    password=${SHERPA_PWD}    alias=Sherpa_Conn
    ${date}    DateTime.Get Current Date    result_format=%Y%m%d
    @{time}    Get Time    hour min sec
    ${current_time}    Set Variable    ${time}[0]${time}[1]${time}[2]
    ${timestamp}    Set Variable    ${date}T${current_time}
    ${sherpa_files_dir}    Set Variable    ${SHERPA_LOG_DIR}/${timestamp}
    ${tgz_file_name}    Set Variable    ${timestamp}.tgz
    ${output}    csn.execute    cd ${DCAP_SHERPA_FILE_DIR}; find *.pcap -not -empty | xargs tar czvf ${timestamp}.tgz    connection=DCAP_Conn
    ${output}    csn.download file    remote_path=${DCAP_SHERPA_FILE_DIR}/${tgz_file_name}    local_path=${LOCAL_LOG_DIR}/${tgz_file_name}    
    ...    connection=DCAP_Conn
    ${output}    csn.upload file    local_path=${LOCAL_LOG_DIR}/${tgz_file_name}    remote_path=${SHERPA_LOG_DIR}/${tgz_file_name}    
    ...    connection=Sherpa_Conn
    ${output}    csn.execute    mkdir ${sherpa_files_dir}    connection=Sherpa_Conn
    ${output}    csn.execute    tar xzvf ${SHERPA_LOG_DIR}/${tgz_file_name} -C ${sherpa_files_dir}    connection=Sherpa_Conn
    BuiltIn.Log    Upload sherpa logs to Sherpa Server    console=yes
    [Return]    ${sherpa_files_dir}

Convert pcap to csv files and download from Sherpa Server
    [Arguments]    ${sherpa_files_dir}
    ssh.connect to    hostname=${SHERPA_SERVER}    username=${SHERPA_USER}    password=${SHERPA_PWD}    alias=Sherpa_Conn
    ${ls_output}    csn.execute    cd ${sherpa_files_dir};ls *.pcap    connection=Sherpa_Conn
    ${pcap_name}    ${last} =    Split String From Right    ${ls_output}    .    1
    Run Sherpa    Sherpa_Conn    ${sherpa_files_dir}    ${sherpa_files_dir}/${ls_output}    500    ${pcap_name}
    ${output}    csn.execute    cd ${sherpa_files_dir}; ls ${pcap_name}*.csv    connection=Sherpa_Conn
    ${output}    csn.execute    cd ${sherpa_files_dir}; tar czvf ${pcap_name}.tgz ${pcap_name}*.csv    connection=Sherpa_Conn
    ${output}    csn.download_file    ${sherpa_files_dir}/${pcap_name}.tgz    ${LOCAL_LOG_DIR}/${pcap_name}.tgz    connection=Sherpa_Conn
    ${output}    Run    cd ${LOCAL_LOG_DIR}; mkdir ${pcap_name}
    ${output}    Run    cd ${LOCAL_LOG_DIR}; tar xzvf ${pcap_name}.tgz -C ${pcap_name}
    BuiltIn.Log    \n Convert pcap to csv files and download from Sherpa Server successfully \n    console=yes
    [Return]    ${pcap_name}

Clear Sherpa files on DCAP Server
    ssh.connect to    hostname=${DCAP_SERVER}    username=${DCAP_USER}    password=${DCAP_PWD}    alias=DCAP_Conn
    ${output}    csn.execute    rm -rf ${DCAP_SHERPA_FILE_DIR}/*    connection=DCAP_Conn
    BuiltIn.Log    Clear Sherpa files on DCAP Server is OK    console=yes

Create dir for Sherpa logs on local VM
    ${output}    List Directory    /home/ute
    Run Keyword Unless    'sherpa_pcaps' in ${output}    Create Directory    ${LOCAL_LOG_DIR}
