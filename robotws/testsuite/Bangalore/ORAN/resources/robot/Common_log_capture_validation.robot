*** Settings ***
Documentation   Keywords for collecting and validating egen, wireshark, sherpa, emil, BIp and tti logs

Library    taf.transport.ssh    WITH NAME    ssh
Library    taf.collectors.tshark    WITH NAME    tshark
Library    taf.collectors.core   WITH NAME   core
Library    taf.gnb.oam.coam.admin    WITH NAME    coam
Library    taf.selenium.sbts    WITH NAME    sbts
Library    OperatingSystem
Library    Process
Library    String
Library    taf.converters.sherpa    WITH NAME    sherpa
Library	   ./testsuite/Bangalore/ORAN/resources/python/Tshark_Validation.py

*** Variables ***
&{SIMPLIFIED_ALARM}     severity=${NONE}  faultId=${NONE}  faultName=${NONE}  notifier=${NONE}  number=${NONE}

*** Keywords ***
Open Connection And Log In To Host
    [Arguments]    ${host}=${uepc_default_ip}
    ...            ${login}=${uepc_default_username}
    ...            ${password}=${uepc_default_password}
    Open Connection    ${host}
    ...                timeout=70
    ...                prompt=$
    Login    ${login}
    ...      ${password}

start_tshark
    [Arguments]    ${executor}=@{EMPTY}    ${options}=@{EMPTY}    ${alias}=tshark1
    [Documentation]    this keyword used to collect tshark logs
    ...    | ${executor} : dictinory containing remote host username and password details
    ...    | ${options} : tshark command options
    
    Run Keyword If     ${executor}==""    tshark.Create Tshark Collector    name=${alias}    options=${options}
    Run Keyword If     ${executor}!=""    tshark.Create Tshark Collector    name=${alias}    options=${options}
    ...    executor=${executor}
    core.setup_collectors    names=${alias}
    core.set_suite_alias    ${alias}
    core.start_collectors    names=${alias}
    sleep    10
    
stop_tshark
    [Arguments]    ${target_directory}    ${alias}=tshark1
    [Documentation]    this keyword used to stop tshark log collection
    ...    | ${target_directory} : target directory to save collected log files
    
    core.stop_collectors    ${alias}
    sleep    10
    core.collect_collectors    names=${alias}    target_dir=${target_directory}
    sleep    30
    core.teardown_collectors    names=${alias}
    sleep    10   
    [Return]    ${target_directory}/tshark1


start_egen
    [Arguments]    ${egen_server}    ${options}
    [Documentation]    this keyword used to collect egen logs
    ...    | ${egen_server} : egen server ip
    ...    | ${options} : egen command option ex: --cores 1-8 --port 0000:03:00.1 --port 0000:03:00.0
    ...    | --capture FJTTest_2.pcap  --save-n-and-quit 50000
    
    ssh.Connect To    ${egen_server}    inbabtslabuser    BT5l@bus3rl0g1n    alias=egen
    Set Suite Variable    ${connct}    egen
    ssh.Send Command    sudo su    connection=egen
    ssh.Execute      cd /root/eGen/release    connection=egen
    Log to console   --\n ssh DONE-3\n--
    ${contents}=    ssh.Execute    /root/eGen/release/ethtool ens1f1    connection=egen
    log    ${contents}
    ssh.Execute     sudo /root/eGen/release/egen ${options}    connection=egen
    sleep    10
    
stop_egen
    [Arguments]    ${sourec_path}    ${target_directory}
    [Documentation]    this keyword used to stop egen log collection
    ...    | ${sourec_path} : source file path 
    ...    | ${target_directory} : target file path to save collected log file
    
    ssh.Download File    ${sourec_path}      ${target_directory}    connection=${connct}
    ssh.Disconnect    connection=egen

start_bip
    [Arguments]    ${FCT_BOARD_TYPE}    ${ASP_BOARD_TYPE}    ${script_path}    ${GNB_password}  
    ...    ${GNB_username}    ${GNB_ip}
    ...    ${duration}=infinite
    [Documentation]    this keyword used to collect BIP logs
    ...
    ...    | ${FCT_BOARD_TYPE} : FCT board type
    ...    | ${ASP_BOARD_TYPE} : ASP board type
    ...    save gnbMirroring.sh and gnbMirroringConfig.sh scripts under "BIP" folder
    ...    save ABIO_BIP_mirroring.sh under "shell" folder
    ...    | ${script_path} : scripts path where the gnbMirroring.sh and ABIO_BIP_mirroring.sh files are saved 
    ...    ex: if .sh files saved under /home/ute/scripts/BIP/gnbMirroring.sh
    ...                 (/home/ute/scripts/shell/ABIO_BIP_mirroring.sh) 
    ...    ${script_path} = "/home/ute/scripts"
    ...    | ${GNB_password} : GNB password
    ...    | ${GNB_username} : GNB username
    ...    | ${GNB_ip} : GNB ip
    
  
    Run Keyword If    '${FCT_BOARD_TYPE}'=='ASIK' or '${FCT_BOARD_TYPE}'=='ASIB'    Start BIP Log On ASIK ASIB
    ...    ${script_path}    ${ASP_BOARD_TYPE}    ${duration}
    Run Keyword If    '${FCT_BOARD_TYPE}'=='ASIL'    Start BIP Log On ASIL

Start BIP Log On ASIK ASIB
    [Arguments]    ${script_path}    ${GNB_password}    ${GNB_username}    ${GNB_ip}   ${ASP_BOARD_TYPE}
    ...    ${duration}=infinite 
    Clear The BIP File Dir In Gnb    ${GNB_password}    ${GNB_username}    ${GNB_ip}
    Log To Console    INFO:Start GNB BIP log On ASIK or ASIB...
    Modify File Parameter    ${SCRIPT_PATH}/BIP/gnbMirroringConfig.sh    CAPTURING_TIME_SECONDS=[0-9]+
    ...    CAPTURING_TIME_SECONDS=${duration}
    Modify File Parameter    ${SCRIPT_PATH}/BIP/gnbMirroring.sh    tcpdump_L2L1_bip    5GBipL2L1
    Modify File Parameter    ${SCRIPT_PATH}/BIP/gnbMirroringConfig.sh    NUMBER_OF_FILES=10    NUMBER_OF_FILES=2
    Modify File Parameter    ${SCRIPT_PATH}/BIP/gnbMirroringConfig.sh    FILE_SIZE_MBYTES=100    FILE_SIZE_MBYTES=50
    Modify File Parameter    ${SCRIPT_PATH}/shell/ABIO_BIP_mirroring.sh    tcpdumpL2L1    5GBipL2L1
    Modify File Parameter    ${SCRIPT_PATH}/shell/ABIO_BIP_mirroring.sh    -C 100    -C 50
    Modify File Parameter    ${SCRIPT_PATH}/shell/ABIO_BIP_mirroring.sh    -W 20    -W 2x
    Run Keyword If    '${ASP_BOARD_TYPE}'=='ABIO'    Modify BIP Script File For ABIO
    OperatingSystem.Run    sshpass -p ${GNB_password} scp ${SCRIPT_PATH}/BIP/* ${GNB_username}@${GNB_ip}:/ffs/run/config/scripts/
    OperatingSystem.Run
    ...    sshpass -p ${GNB_password} scp ${SCRIPT_PATH}/shell/ABIO_BIP_mirroring.sh ${GNB_username}@${GNB_ip}:/ffs/run/config/scripts/
    ${gnb_hostname}=    OperatingSystem.Run    sshpass -p oZPS0POrRieRtu ssh toor4nsn@192.168.255.1 hostname 2>/dev/null
    ${slot_id}=    Set Variable If    '${gnb_hostname}'=='fct-4a'    5    1
    ${exec_script}    Set Variable If    '${ASP_BOARD_TYPE}'=='ABIO'    ABIO_BIP_mirroring.sh ${slot_id}    gnbMirroring.sh
    OperatingSystem.Run    sshpass -p ${GNB_password} ssh ${GNB_username}@${GNB_ip} chmod +x /ffs/run/config/scripts/${exec_script}
    SSH.Connect To    ${GNB_ip}    ${GNB_username}    ${GNB_password}    alias=BIP_ASIK_Start
    SSH.Send Command    command=sh /ffs/run/config/scripts/${exec_script} 1>/dev/null 2>&1 &    connection=BIP_ASIK_Start
    Set Suite Variable    ${BIP_CMD}           tcpdump -i
    Wait Until Keyword Succeeds    1min    2s    Verify Process Start Success    5GBipL2L1_filtering_off    ${BIP_CMD}    BIP_ASIK_Start
    Log To Console   INFO:bip start success...

Verify Process Start Success
    [Arguments]    ${part_proc_msg}    ${process_msg}    ${connection}
    ${process}    SSH.Execute    command=ps aux|grep '${part_proc_msg}'    connection=${connection}
    ${check_status}    Run Keyword And Return Status     Should Contain    ${process_msg}    \\
    Run Keyword If    '${check_status}'=='${true}'    Should Match Regexp    ${process}    ${process_msg}
    ...    ELSE    Should Contain    ${process}    ${process_msg}

Start BIP Log On ASIL
    [Arguments]    ${script_path}    ${GNB_password}    ${GNB_username}    ${GNB_ip}   ${ASP_BOARD_TYPE}
    ...    ${duration}=infinite
    Log To Console  Copying the BIP log collection scripts to GNB
    Modify File Parameter    ${SCRIPT_PATH}/BIP/gnbMirroring.sh    tcpdump_L2L1_bip    5GBipL2L1
    Modify File Parameter    ${SCRIPT_PATH}/BIP/gnbMirroringConfig.sh    NUMBER_OF_FILES=10    NUMBER_OF_FILES=1
    Modify File Parameter    ${SCRIPT_PATH}/BIP/gnbMirroringConfig.sh    FILE_SIZE_MBYTES=100    FILE_SIZE_MBYTES=300
    OperatingSystem.Run    sshpass -p ${GNB_password} ssh ${GNB_username}@${GNB_ip} rm -rf /ffs/run/config/scripts
    OperatingSystem.Run    sshpass -p ${GNB_password} ssh ${GNB_username}@${GNB_ip} mkdir /ffs/run/config/scripts
    OperatingSystem.Run    sshpass -p ${GNB_password} scp ${SCRIPT_PATH}/BIP/* ${GNB.username}@${GNB.ip}:/ffs/run/config/scripts/
    OperatingSystem.Run    sshpass -p ${GNB_password} ssh ${GNB_username}@${GNB_ip} chmod +x /ffs/run/config/scripts/*
    SSH.Connect To    ${GNB_ip}    ${GNB_username}    ${GNB_password}    alias=BIP_ASIL_Start
    SSH.Send Command    command=sh /ffs/run/config/scripts/gnbMirroring.sh 1>/dev/null 2>&1 &    connection=BIP_ASIL_Start
    Set Suite Variable    ${BIP_CMD}           tcpdump -i
    Wait Until Keyword Succeeds    1min    2s    Verify Process Start Success    5GBipL2L1_filtering_off    ${BIP_CMD}
    ...    BIP_ASIL_Start
    Log To Console   INFO:bip start success...

Modify BIP Script File For ABIO
    ${gnb_hostname}=    OperatingSystem.Run    sshpass -p oZPS0POrRieRtu ssh toor4nsn@192.168.255.1 hostname 2>/dev/null
    ${slot_id}=    Set Variable If    '${gnb_hostname}'=='fct-4a'    5    1
    Run Keyword If     '${slot_id}'=='5'    Modify BB Slot
    
    
Clear The BIP File Dir In Gnb
    [Arguments]    ${GNB_password}    ${GNB_username}    ${GNB_ip}
    [Documentation]    This keyword is to clear bip files in gnb /ffs/run/config/scripts if exists.
    
    OperatingSystem.Run    sshpass -p ${GNB_password} ssh ${GNB_username}@${GNB.ip} rm /tmp/5GBipL2L1_filtering_off*
    
stop_bip
    [Arguments]    ${log_dir}    ${FCT_BOARD_TYPE}
    [Documentation]    this keyword used to stop bip log collection
    ...    | ${log_dir} : target directory to save collected log files
    ...    | ${FCT_BOARD_TYPE} : FCT board type
    
    Run Keyword If    '${FCT_BOARD_TYPE}'=='ASIK' or '${FCT_BOARD_TYPE}'=='ASIB'    Stop BIP Log On ASIK ASIB    ${log_dir}
    Run Keyword If    '${FCT_BOARD_TYPE}'=='ASIL'    Stop BIP Log On ASIL    ${log_dir}

Stop BIP Log On ASIK ASIB
    [Arguments]    ${log_dir}    ${GNB_ASIK_password}    ${GNB_ASIK_username}    ${GNB_ASIK_ip}
    Log To Console    INFO:Stop GNB BIP log...
    Wait Until Keyword Succeeds    6s    2s    Kill And Verify Process Stop Success    5GBipL2L1_filtering_off
    ...    ${BIP_CMD}    BIP_ASIK_Start
    Run Keyword If    '${log_dir}'!='${SUITE_LOG_DIRECTORY}' or '${log_dir}'!='${TEST_LOG_DIRECTORY}'
    ...    Create Directory    ${log_dir}
    ${bip_counts}    Copy BIP Files And Return Count    ${log_dir}    ${GNB_ASIK_password}    ${GNB_ASIK_username}
    ...    ${GNB_ASIK_ip}
    Log To Console   INFO:bip end success...
    [Return]    ${bip_counts}
    
Stop BIP Log On ASIL
    [Arguments]    ${log_dir}
    Log To Console    INFO:Stop GNB BIP log..
    Wait Until Keyword Succeeds    6s    2s    Kill And Verify Process Stop Success    5GBipL2L1_filtering_off
    ...    ${BIP_CMD}    BIP_ASIL_Start
    Log    ${SUITE_LOG_DIRECTORY}
    Log    ${TEST_LOG_DIRECTORY}
    Run Keyword If    '${log_dir}'!='${SUITE_LOG_DIRECTORY}' or '${log_dir}'!='${TEST_LOG_DIRECTORY}'    Create Directory
    ...    ${log_dir}
    ${bip_counts}    Copy BIP Files And Return Count    ${log_dir}    ${GNB_ASIK_password}    ${GNB_ASIK_username}    ${GNB_ASIK_ip}
    Log To Console   INFO:bip end success...
    [Return]    ${bip_counts}	
    

Kill And Verify Process Stop Success
    [Arguments]    ${part_proc_msg}    ${process_msg}    ${connection}
    Kill Process If Existed    ${part_proc_msg}    ${process_msg}    ${connection}
    ${process}    SSH.Execute    command=ps aux|grep '${part_proc_msg}'    connection=${connection}
    ${check_status}    Run Keyword And Return Status     Should Contain    ${process_msg}    \\
    Run Keyword If    '${check_status}'=='${true}'    Should Not Match Regexp    ${process}    ${process_msg}
    ...    ELSE    Should Not Contain    ${process}    ${process_msg}
    
Kill Process If Existed
    [Arguments]    ${part_proc_msg}    ${process_msg}    ${connection}
    ${status}    Run Keyword And Return Status    Judge Process Existed    ${part_proc_msg}    ${process_msg}    ${connection}
    Run Keyword If    '${status}'=='${true}'    SSH.Execute
    ...    command=ps aux|grep '${part_proc_msg}'|awk '{print $2}'|xargs kill -2    connection=${connection}
    

Copy BIP Files And Return Count	
    [Arguments]    ${path}    ${GNB_ASIK_password}    ${GNB_ASIK_username}    ${GNB_ASIK_ip}
    Log To Console    copy bip files to ${path}...
    Wait Until Keyword Succeeds    10 s    2 s    Verify Bip Log Exist    ${GNB_ASIK_password}    ${GNB_ASIK_username}    ${GNB_ASIK_ip}
    OperatingSystem.Run    sshpass -p oZPS0POrRieRtu scp ${GNB_ASIK_username}@${GNB_ASIK_ip}:/tmp/5GBipL2L1_filtering_off.pcap* ${path}
    ${count}    OperatingSystem.Count Items In Directory    ${path}    pattern=5GBipL2L1_filtering_off.pcap*
    [Return]    ${count}

Verify Bip Log Exist
    [Arguments]    ${GNB_ASIK_password}    ${GNB_ASIK_username}    ${GNB_ASIK_ip}
    ${rc}    ${output}=    OperatingSystem.Run And Return Rc And Output
    ...    sshpass -p ${GNB_ASIK_password} ssh ${GNB_ASIK_username}@${GNB_ASIK_ip} ls -al /tmp/5GBipL2L1_filtering_off.pcap*
    Should Be True    "${rc}"=="0"

start_sherpa
    [Arguments]     ${version}    ${source_ip}    ${dscp}    ${uplane_destination}    ${wireshark_executor}=@{EMPTY}
    [Documentation]    this keyword used to collect sherpa logs
    ...    | ${version} : FCT board type
    ...    | ${source_ip} :  source ip address
    ...    | ${dscp} : dscp value 	
    ...    | ${uplane_destination} : uplane destination address, e.g. “192.168.0.2:8081”
    ...    | ${wireshark_executor} : dictinory containing remote ip,username nd password to collect logs

    coam.setup_admin   
    sbts.enable_virtual_display
    sbts.login     https://192.168.255.129     Nemuadmin     nemuuser     version=${version}      
    Run Keyword And Ignore Error    sbts.deactivate_internal_trace   timeout=30
    sbts . Configure Logging Agent    source_ip=${source_ip}    dscp=${dscp}    uplane_destination=${uplane_destination}  timeout=30
    sleep    10
    sbts.activate_internal_trace   timeout=30
    sbts.start_l2_hi_pdcp_sherpa_trace_and_return_result       timeout=20
    sbts.start_l2_hi_rlc_sherpa_trace_and_return_result       gnb_type=Classical    timeout=20
    sbts.start_l2_lo_sherpa_trace_and_return_result      timeout=20
    sbts.start_l2_ps_sherpa_trace_and_return_result     timeout=20
    sbts.logout
    sbts.disable_virtual_display
    start_tshark    executor=${wireshark_executor}    alias=sherpa_tshark
    
stop_sherpa    
    [Arguments]     ${target_path}
    [Documentation]    this keyword used to stop sherpa logs
    ...    | ${target_path} : target directory to save collected log files

    stop_tshark    ${target_path}    alias=sherpa_tshark
    sleep    10
    sherpa.create sherpa converter
        ...    name=sherpa
        ...    file_path_pattern=${target_path}/sherpa_tshark/*.pcap
        ...    output_path=${target_path}
    sherpa.setup    sherpa
    sherpa.convert    sherpa
    sherpa.teardown    sherpa
    [return]    ${target_path}/sherpa_tshark
   
start_tti_trace
    [Arguments]     ${ASP_BOARD_TYPE}
    [Documentation]    this keyword used to collect tti_traces
    ...    | ${ASP_BOARD_TYPE} : ASP board type, makesure /opt/tools/ttiTrace/eventsCollect.sh script present.

    ${cpu_id}=    Set Variable If    "${ASP_BOARD_TYPE}"=="ABIO"    0    1
    OperatingSystem.Run    sshpass -p oZPS0POrRieRtu ssh toor4nsn@192.168.255.1 bsh 1:${cpu_id} rm -rf /var/eventsTrace/*
    ${cmd}=
    ...    Catenate
    ...    sshpass -p oZPS0POrRieRtu ssh toor4nsn@192.168.255.1 bsh 1:${cpu_id} ls -l /tmp/ 2>/dev/null|grep -e
    ... ".*ram.*L2RT20"|awk -F "node_" '{print $2}'|awk -F " " '{print $1}'
    ${ret}    ${output}=    OperatingSystem.Run And Return Rc And Output    ${cmd}
    ${container_id}=    Set Variable    ${output}
    Set Suite Variable    ${TTITRACE_START_CMD}    sh /opt/tools/ttiTrace/eventsCollect.sh
    ${ssh_connect}=    Set Variable    sshpass -p oZPS0POrRieRtu ssh toor4nsn@192.168.255.1
    ${cmd}=    Set Variable     ${ssh_connect} bsh 1:${cpu_id} lxc-attach -n ${container_id} ${TTITRACE_START_CMD}
    ${TTITRACE_HANDLE}=    Process.Start Process    ${cmd}    shell=True
    Set Suite Variable    ${TTITRACE_HANDLE}
    
stop_tti_trace
    [Arguments]     ${ASP_BOARD_TYPE}   ${target_directory}    ${script_path}
    [Documentation]    this keyword used to stop tti_trace
    ...    | ${ASP_BOARD_TYPE} : ASP board type
    ...    | ${target_path} : target directory to save collected log files
    ...    | ${script_path} : path to the folder contains decode_ttitrace_on_PC.sh file
    
    ${result}=    Process.Terminate Process    ${TTITRACE_HANDLE}
    Log To Console    INFO:TTI trace end success...
    ${cpu_id}=    Set Variable If    "${ASP_BOARD_TYPE}"=="ABIO"    0    1
    ${ssh_cmd}=    Set Variable    sshpass -p oZPS0POrRieRtu ssh toor4nsn@192.168.255.1
    ${rc}    ${output}=    OperatingSystem.Run And Return Rc And Output    ${ssh_cmd} bsh 1:${cpu_id} ps aux|grep eventsCollect.sh
    ${rc}    ${pids}=    OperatingSystem.Run And Return Rc And Output    
    ...   ${ssh_cmd} bsh 1:${cpu_id} ps aux|grep eventsCollect.sh|awk '{print $2}'
    Log    ${pids}
    @{lines}=    String.Split To Lines    ${pids}
    FOR   ${pid}    IN    @{lines}
        ${rc}    ${output}=    OperatingSystem.Run And Return Rc And Output    ${ssh_cmd} bsh 1:${cpu_id} kill -2 ${pid}
    END
    OperatingSystem.Run    ps -ef|grep eventsCollect.sh
    ${ssh_cmd}=    Set Variable    sshpass -p oZPS0POrRieRtu ssh toor4nsn@192.168.255.1
    ${rc}    ${output}=    OperatingSystem.Run And Return Rc And Output    ${ssh_cmd} bsh 1:${cpu_id} ps aux|grep eventsCollect.sh
    ${ttitrace_bin_log}=    Catenate    sshpass -p oZPS0POrRieRtu ssh toor4nsn@192.168.255.1 bsh 1:${cpu_id} ls -lrt /var/eventsTrace/
    ${rc}    ${output}=    OperatingSystem.Run And Return Rc And Output    ${ttitrace_bin_log}
    Log To Console    INFO:ttitrace log list:${output}
    OperatingSystem.Run And Return Rc And Output    sh ${script_path}/decode_ttitrace_on_PC.sh ${target_directory}
    Log To Console    INFO:finish to decode tti .bin logs to csv

Validate Wireshark
    [Arguments]    ${outputPath}    ${filter}
    [Documentation]    This keyword is to valiadte tshark logs

    ...    ${outputPath} : directory path where tshark logs are saved
    ...    ${filter} : filter condition

    ${a}=     Validate_Tshark      ${outputPath}    filter=${filter}
    log       ${a}
    [Return]    ${a}
    
Validate egen
    [Arguments]    ${outputPath}    ${filter}
    [Documentation]    This keyword is to valiadte tshark logs

    ...    ${outputPath} : directory path where tshark logs are saved
    ...    ${filter} : filter condition

    ${a}=     Validate_Tshark      ${outputPath}    filter=${filter}
    log       ${a}
    [Return]    ${a}
    
Validate Bip
    [Arguments]    ${outputPath}    ${filter}
    [Documentation]    This keyword is to valiadte tshark logs

    ...    ${outputPath} : directory path where tshark logs are saved
    ...    ${filter} : filter condition

    ${a}=     Validate_Tshark      ${outputPath}    filter=${filter}
    log       ${a}
    [Return]    ${a}
    
validate sherpacsv
    [Arguments]    ${outputcsvpath}    ${field}    {filter}
    [Documentation]    This keyword is to valiadte tshark logs
    
    sherpa_analyzer.setup reader    outputcsvpath
    ${result1}     sherpa_analyzer.get values for column    ${field}    regexfilter=None
    [return]    ${result1}
    
validate Emilcsv
    [Arguments]    ${uepc_default_ip}
    ...            ${uepc_default_username}
    ...            ${uepc_default_password}
    ...            ${emil_cygwin_traces_subdir_path}
    ...            ${file_name}=*csv
    ...            ${message}=@{EMPTY}
    ...            ${parameter}=@{EMPTY}
    ...            ${value}=@{EMPTY}
    [Documentation]    This keyword is to valiadte Emil logs

    ...    ${uepc_default_ip} : ue_pc ip
    ...    ${uepc_default_username} : ue_pc username
    ...    ${uepc_default_password} : ue_pc password
    ...    ${emil_cygwin_traces_subdir_path} : cygwin sbudir path where emil logs are saved
    ...    ${file_name} : name of emil csv file to be validated by default all files with .csv are validated
    ...    ${message} : message to be validated default ""
    ...    ${parameter} : parameter to be validated default ""
    ...    ${value} : parameter value default ""
    
    Run Keyword If     ${message}!=""    Parse Emil Csv File For Message Existing    ${message}    ${uepc_default_ip}   ${login}
    ...    ${password}    ${file_path}    ${file_name}
    Run Keyword If     ${parameter}!=""    Parse Emil Csv File For Parameter Value    ${parameter}    ${value}    ${uepc_default_ip}
    ...    ${login}    ${password}    ${file_path}    ${file_name}
    
Parse Emil Csv File For Parameter Value
    [Arguments]    ${parameter}
    ...            ${value}
    ...            ${host}
    ...            ${login}
    ...            ${password}
    ...            ${file_path}
    ...            ${file_name}=*csv
    Should Not Be Empty    ${value}    msg=parameter value not provided for validation    
    Open Connection And Log In To Host    host=${host}
    ...                                   password=${password}
    ...                                   login=${login}
    ${out_file_path}=    String.Replace String    string=${file_path}
    ...                                           search_for=\\
    ...                                           replace_with=\\\\
    ${out_file_value}=    SSHLibrary.Execute Command    
    ...    cd ${out_file_path}; grep "${parameter}" ${file_name} | awk -F"," '{print $1}' | ...    awk -F" " '{print $3}' | head -1
    Should Be Equal    ${value}    ${out_file_value}
    ...                           msg=The ${parameter} value is equal to ${out_file_value}. Expected value is ${value}!

Parse Emil Csv File For Message Existing
    [Arguments]    ${message}
    ...            ${host}
    ...            ${login}
    ...            ${password}
    ...            ${file_path}
    ...            ${file_name}=*csv
    Open Connection And Log In To Host    host=${host}
    ...                                   password=${password}
    ...                                   login=${login}
    ${out_file_path}=    String.Replace String    string=${file_path}
    ...                                           search_for=\\
    ...                                           replace_with=\\\\
    ${out_file_value}=    SSHLibrary.Execute Command    cd ${out_file_path}; grep -r "\\<${message}\\>" ${file_name}
    ${test}=    Fetch From Left    ${out_file_value}    \,${message}
    Log    ${test}
    ${timestmp}=    Fetch From Right    ${test}    csv\:1\,
    Log    ${timestmp}
    Should Not Be Empty    ${out_file_value}
    ...                    msg=The ${message} is not found in the emil file!
