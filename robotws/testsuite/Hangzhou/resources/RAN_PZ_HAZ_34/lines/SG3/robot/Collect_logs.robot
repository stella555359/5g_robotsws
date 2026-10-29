*** Settings ***
Documentation
...    author: liujia
...    contact:jia-rebecca.liu@nokia-sbell.com
...    squad group: SG_03

Resource          taf/rfrl/common_resources/robot/TTI_Trace.robot
Resource          testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/robot/coam_gnb_classical.robot
Resource          testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/robot/BIP_trace/BIP_trace_collector.robot
Resource          testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/robot/robot_common_operations/interface.robot
Library           OperatingSystem
Library           taf.collectors.l1l2bip        WITH NAME      l1l2bip
Library           taf.collectors.tcpdump        WITH NAME      tcpdump
Library           taf.collectors.core           WITH NAME      core
Library           taf.collectors.l2stream3      WITH NAME      L2STREAM3
Library           taf.converters.eventdecoder   WITH NAME      EVENTDECODER
Library           testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/lines/SG3/gnb_logs_tool_upgrade.py

*** Variables ***
${gNB_master_log}    /ffs/run/config/toor4nsn
${epc_log_path}        /opt/workspace/CRT/Master/Case_Logs
${TS_LOG_PATH_BASE}         /opt/workspace/CRT/Master/Case_Logs/
${gnb_path}    /tmp/
#${fct_addr}    ${tl.gnbs[0].dus[0].airscale.common_units[0].capacity_units[0].addr}
${asik_slave}    asik_slave
${fct_addr}    192.168.253.17
${gnb_logs_tool_path}    /opt/workspace/tti_script/gnb_logs
${output_match}    Done
${tti_logs_rename}    gnb_logs_TTI
${BBMOD}              1
${TestPC_addr}                  ${tl.test_pc.default_ssh_connection_details.addr}
${TestPC_username}              ${tl.test_pc.default_ssh_connection_details.username}
${TestPC_password}              ${tl.test_pc.default_ssh_connection_details.password}

*** Keywords ***
##capture gnb logs ##
Start capture gNB log on master
    [Arguments]    ${filename}    ${gNB_index}=${0}    ${interface}=any
    wait until keyword succeeds    1min   10s    Connect gNB    gNB_index=${gNB_index}
    sleep    3s
    csn.send command    command=tcpdump -i ${interface} -p sctp -w ${gnb_path}${filename}    connection=gNB${gNB_index}
	sleep    3s
    [Teardown]    csn.disconnect    connection=gNB${gNB_index}

Stop and download the Logs
    [Arguments]    ${filename}    ${gNB_index}=${0}
    wait until keyword succeeds    1min   10s    Connect gNB    gNB_index=${gNB_index}
    csn.send command    command=killall tcpdump     connection=gNB${gNB_index}
    sleep    3
    csn.download_file   remote_path=${gnb_path}${filename}   local_path=${epc_log_path}${filename}   connection=gNB${gNB_index}
    sleep    3
    [Teardown]    csn.disconnect    connection=gNB${gNB_index}

Stop and download Logs on gNB on master
    [Arguments]    ${filename}    ${gNB_index}=${0}
    wait until keyword succeeds    1min   10s    Stop and download the Logs    filename=${filename}    gNB_index=${gNB_index}

Capture tti trace from Gnb logs
    [Arguments]  ${tti_script_path}=${gnb_logs_tool_path}    ${gnb_ip}=${asik_addr}    ${BBMOD}=${BBMOD}
    ...    ${output_match}=${output_match}    ${time}=2
    log to console  start capture tti trace...
    csn.Connect to    hostname=${TestPC_addr}    username=${TestPC_username}    password=${TestPC_password}    alias=ute
    csn.send command    command=cd ${tti_script_path}&&rm *.zip   connection=ute
    csn.Execute    command=cd ${tti_script_path}&&sudo ./gnb_logs ${gnb_ip} -c${BBMOD} -o l2ps ${time}    connection=ute
    sleep    3
    Log    ${output_match}

Get tti trace from gnb logs tool
    [Arguments]  ${tti_script_path}=${gnb_logs_tool_path}    ${gnb_ip}=${asik_addr}    ${epc_log_path}=${epc_log_path}
    ...    ${tti_logs_rename}=${tti_logs_rename}
    log to console    get tti trace to Case_Logs file...
    csn.Connect to    hostname=${TestPC_addr}    username=${TestPC_username}    password=${TestPC_password}    alias=ute
    csn.send command    command=cd ${tti_script_path}&&ls -l | grep ${gnb_ip} |awk '{print $9}'  connection=ute
    ${tti_logs_zip}=    csn.Read Output    connection=ute
    ${len}    Get Length    ${tti_logs_zip}
    should be true    ${len} > 0
    @{tti_logs_file}    String.split string    string=${tti_logs_zip}    separator=.zip
    csn.send command    command=cd ${tti_script_path}&&unzip ${tti_logs_file}[0].zip&&rm ${tti_logs_file}[0].zip    connection=ute
    sleep    3s
    csn.send command    command=cd ${tti_script_path}&&mv ${tti_script_path}/${tti_logs_file}[0] ${epc_log_path}${tti_logs_rename}
    ...    connection=ute

Start capture gNB log on slave
    [Arguments]    ${filename}    ${gNB_index}=${0}    ${interface}=any
    Connect gNB    gNB_index=${gNB_index}
    Connect to ASIK slave    gNB_index=${gNB_index}
    csn.send command    command=tcpdump -i ${interface} sctp -w ./${filename}   connection=${asik_slave}

Stop and download the Logs on slave
    [Arguments]    ${filename}    ${gNB_index}=${0}
    Connect gNB    gNB_index=${gNB_index}
    Connect to ASIK slave    gNB_index=${gNB_index}
    csn.send command    command=killall tcpdump     connection=${asik_slave}
    sleep    3s
    csn.send command    command=cp ./${filename} ${gNB_master_log}/${filename}    connection=${asik_slave}
    sleep    10s
    csn.download_file   remote_path=${gNB_master_log}/${filename}   local_path=${epc_log_path}${filename}   connection=gNB${gNB_index}
    sleep    3s

Start Capture Wireshark Logs on ASIK
    [Arguments]     ${filename}    ${interface}=any    ${gNB_index}=${0}
    Connect gNB    gNB_index=${gNB_index}
    csn.send command    command=bsh 0:1 tcpdump -i ${interface} sctp -w ${gnb_path}${filename}    connection=gNB${gNB_index}
    sleep    3s
    [Teardown]    csn.disconnect    connection=gNB${gNB_index}

Stop Capture Wireshark Logs on ASIK
    [Arguments]    ${filename}    ${gNB_index}=${0}
    Connect gNB    gNB_index=${gNB_index}
    csn.send command    command=bsh 0:1 killall tcpdump    connection=gNB${gNB_index}
    sleep    3s
    csn.send command    command=bsh 0:1 cp ${gnb_path}${filename} ${gNB_master_log}/${filename}    connection=gNB${gNB_index}
    sleep    10s
    csn.download_file   remote_path=${gNB_master_log}/${filename}   local_path=${epc_log_path}${filename}
    ...    connection=gNB${gNB_index}
    sleep    3s
    [Teardown]    csn.disconnect    connection=gNB${gNB_index}
##capture enb logs ##
Start to collect the log on eNB
    [Arguments]    ${log_name}    ${eNB_index}=${0}    ${interface}=any
    wait until keyword succeeds    2 min    10 sec    Connect eNB    eNB_index=${eNB_index}
    sleep    3s
    csn.send command    command=tcpdump -i ${interface} sctp -w /tmp/${log_name}   connection=ENB${eNB_index}
    sleep    3s
    [Teardown]    csn.disconnect    connection=ENB${eNB_index}

Stop and download Logs on eNB
    [Arguments]     ${log_name}    ${eNB_index}=${0}    ${epc_log_path}=${epc_log_path}
    wait until keyword succeeds    2 min    10 sec    Connect eNB    eNB_index=${eNB_index}
    sleep    10
    csn.send command    command=killall tcpdump     connection=ENB${eNB_index}
    sleep    5
    csn.download_file   remote_path=/tmp/${log_name}   local_path=${epc_log_path}${log_name}   connection=ENB${eNB_index}
    [Teardown]    csn.disconnect    connection=ENB${eNB_index}

Connect eNB
    [Arguments]    ${eNB_index}
    csn.Connect to    hostname=${tl.enbs[${eNB_index}].airscale.common_units[0].lmp_connection.addr}
    ...    username=${tl.enbs[${eNB_index}].airscale.common_units[0].lmp_connection.username}
    ...    password=${tl.enbs[${eNB_index}].airscale.common_units[0].lmp_connection.password}    alias=ENB${eNB_index}

Connect gNB
    [Arguments]    ${gNB_index}
    csn.Connect to    hostname=${tl.gnbs[${gNB_index}].dus[0].airscale.common_units[0].lmp_connection.addr}
    ...    username=${tl.gnbs[${gNB_index}].dus[0].airscale.common_units[0].lmp_connection.username}
    ...    password=${tl.gnbs[${gNB_index}].dus[0].airscale.common_units[0].lmp_connection.password}
    ...    alias=gNB${gNB_index}

Connect to ASIK slave
    [Arguments]    ${gNB_index}=${0}    ${asik_slave}=${asik_slave}
    csn.Connect to    hostname=${fct_addr}
    ...               username=${tl.gnbs[${gNB_index}].dus[0].airscale.common_units[0].lmp_connection.username}
    ...               password=${tl.gnbs[${gNB_index}].dus[0].airscale.common_units[0].lmp_connection.password}
    ...    alias=${asik_slave}    proxy=gNB${gNB_index}

Start Capture CP-IF logs from Container
    [Documentation]
    ...                create tcpdump log collection on ASIK slave/ASIB master.
    ...                options: (optional) tcpdump options (except for “-w”), default: empty string
    ...                stop tcpdump can use:Stop tcpdump log collection
    ...                parma: ${container_name} if ${container_name}=${None}, it will capture the log without access into any container.
    [Arguments]      ${tcpdump_collector_name}=cpif_tcpdump    ${asik_connection_alias}=ASIK Master
    ...              ${options}=-i any -p sctp -s 0    ${gnb_index}=${0}    ${du_index}=${0}    ${container_name}=CPIF
    ${asib_flag}    If ASIB card used    gnb_index=${gnb_index}    du_index=${du_index}    alias=${asik_connection_alias}
    ${is_left_enabled}    If GNB In Left Side Of AMIA    connection=${asik_connection_alias}
    ${local_node_id}    Set Variable If   ${is_left_enabled}    0x1011     0x2011
    ${is_feature_1948_enabled}    Is Feature 1948 Enabled    connection_alias=${asik_connection_alias}    local_node_id=${local_node_id}
    &{master_config}   create dictionary
    ...    host=${tl.gnbs[${gnb_index}].dus[${du_index}].f1_m_ip_addr}
    ...    user=${tl.gnbs[${gnb_index}].dus[${du_index}].airscale.common_units[0].lmp_connection.username}
    ...    password=${tl.gnbs[${gnb_index}].dus[${du_index}].airscale.common_units[0].lmp_connection.password}
    ${slave_host_ip}    Set Variable If    ${is_left_enabled}    192.168.253.17     192.168.253.33
    &{slave_config}  create dictionary
    ...    host=${slave_host_ip}
    ...    user=${tl.gnbs[${gnb_index}].dus[${du_index}].airscale.common_units[0].lmp_connection.username}
    ...    password=${tl.gnbs[${gnb_index}].dus[${du_index}].airscale.common_units[0].lmp_connection.password}
    ...    proxy=${master_config}
    ${executor_oam_vm}    Set Variable If
    ...    ${asib_flag}    ${master_config}
    ...    '${asib_flag}'=='${False}' and '${is_feature_1948_enabled}'=='${True}'    ${slave_config}
    ...    '${asib_flag}'=='${False}' and '${is_feature_1948_enabled}'=='${False}'    ${master_config}
    tcpdump.create_tcpdump_collector    name=${tcpdump_collector_name}
    ...                                 options=${options}
    ...                                 executor=${executor_oam_vm}
    ...                                 container=${container_name}
    tcpdump.Set Suite Alias    ${tcpdump_collector_name}
    core.setup_collectors    names=${tcpdump_collector_name}
    core.start_collectors    names=${tcpdump_collector_name}

Stop CP-IF log Collection
    [Documentation]
    ...                stop tcpdump log collection and return log path
    [Arguments]      ${tcpdump_collector_name}=cpif_tcpdump    ${target_dir}=${epc_log_path}
    ${cpif_log_path}    Stop and download cpiflog via collector    collector_name=${tcpdump_collector_name}    pattern=*.pcap
    ...     target_dir=${target_dir}
    Set Test Variable    ${cpif_log_path}
    [Return]     ${cpif_log_path}

Stop and download cpiflog via collector
    [Documentation]
    ...                keyword is used to collect the log files to default path
    [Arguments]      ${collector_name}    ${pattern}=*    ${target_dir}=${TS_CASE_LOG_PATH}
    core.stop_collectors        names=${collector_name}
    core.collect_collectors   names=${collector_name}    target_dir=${target_dir}
    core.teardown_collectors    names=${collector_name}
    @{log_file}   List Files In Directory    path=${target_dir}${/}${collector_name}    pattern=${pattern}
    ${list_len}    get length    ${log_file}
    Should be true    ${list_len}==1
    ${full_log_path}    set variable    ${target_dir}${/}${collector_name}${/}${log_file}[0]
    [Return]     ${full_log_path}

BIPlog precondition and capture with scripts
    [Arguments]    ${script_path}    ${capturing_time_seconds}=3    ${gnb_index}=${0}
    Connect to Classical Common Unit Master gnb    gnb_index=${gnb_index}
    Precondition for bip capture with gnbMirroring scripts    script_path=${script_path}
    Capture BIP with gnbMirroring scripts FILE     gnb_index=${gnb_index}    capturing_time_seconds=${capturing_time_seconds}

Capture BIP with gnbMirroring scripts FILE
    [Arguments]    ${gnb_index}=${0}    ${connection}=ASIK Master    ${gnb_mirroring}=gnbMirroring.sh
    ...            ${capturing_time_seconds}=infinite
    Connect to Classical Common Unit Master gnb    gnb_index=${gnb_index}
    ${cmd_local}    catenate    sh /ffs/run/config/scripts/${gnb_mirroring} --capturing_time_seconds=${capturing_time_seconds}
    csn.send_command    command=${cmd_local}    connection=${connection}

###------------capture log with gnb_logs---------###
Capture Logs With gNB_logs_exe File
    [Documentation]    Auther: liujia
    [Arguments]    ${bbmod_slots}=1
    ...            ${duration}=2
    ...            ${gnb_logs_script_path}=/opt/workspace/gnb_logs
    ...            ${gnb_index}=0
    ...            ${du_index}=0
    ...            ${log_type}=BIP
    log to console    --- check gnb_logs tool version and upgrade---
    upgrade gnb logs tool on VM    tool_download_path=/opt/workspace/
    log to console    --- start gnb_logs collection---
    ${log_type_to_command_mapping}    Create Dictionary    TTI=T    BIP=b   m=m
    ${gnb_ip}    Set Variable    ${tl.gnbs[${gnb_index}].dus[${du_index}].f1_m_ip_addr}
    ssh.Connect to    hostname=${tl.test_pc.default_ssh_connection_details.addr}
    ...               username=${tl.test_pc.default_ssh_connection_details.username}
    ...               password=${tl.test_pc.default_ssh_connection_details.password}
    ...               alias=ute
    ssh.send command    command=cd ${gnb_logs_script_path}&&rm *${log_type}.zip   connection=ute
    ${start_capture_command}     Catenate    ./gnb_logs ${gnb_ip} -c${bbmod_slots} -${log_type_to_command_mapping['${log_type}']} ${duration}
    ${output}    ssh.Execute    command=cd ${gnb_logs_script_path}&&./${start_capture_command}   connection=ute
    [Teardown]    Run Keyword And Ignore Error    ssh.disconnect    connection=ute


Get Captured BIP File from UTE
    [Documentation]    Auther: liujia
    [Arguments]    ${gnb_logs_script_path}=/opt/workspace/gnb_logs
    ...            ${target_dir}=${epc_log_path}
    ...            ${gnb_index}=0
    ...            ${du_index}=0
    ...            ${log_type}=BIP
    ...            ${target_file_name}=L2L1_Bip
    ${timestamp}    robot.libraries.DateTime.Get current date    result_format=%Y%m%d%H%M%S
    ${all_bip_file_list}   Create List
    log to console    --- start to Download bip result to specific folder ---
    ${gnb_ip}    Set Variable    ${tl.gnbs[${gnb_index}].dus[${du_index}].f1_m_ip_addr}
    @{bip_files}    List Files In Directory	${gnb_logs_script_path}	   BTS-*_${gnb_ip}_*_${log_type}.zip
    Copy Files    ${gnb_logs_script_path}/BTS-*_${gnb_ip}_*.zip    ${target_dir}
    ${bip_file}    Set Variable    ${bip_files[0]}
    ${file_name}    Set Variable    ${bip_file.split('.zip')[0]}
    Run    unzip ${target_dir}/${bip_file} -d ${target_dir}
    ${specific_bip_file}    List Files In Directory    ${target_dir}/${file_name}/bip
    ...                                                *Bip*.pcap*
    ...                                                absolute=${True}
    ${all_bip_file_list}     Combine Lists     ${specific_bip_file}    ${all_bip_file_list}
    ${bipfile_num}=    get length    ${all_bip_file_list}
    FOR    ${index}    IN RANGE    ${bipfile_num}
        ${next_index}    Evaluate    ${index}+1
        Run Keyword If    '${index}'=='0'    OperatingSystem.Run   command=cd ${target_dir}/${file_name};touch test_${index}.pcap
        OperatingSystem.Run
        ...    command=cd ${target_dir}/${file_name};mergecap -w test_${next_index}.pcap test_${index}.pcap ${all_bip_file_list[${index}]}
    END
    log to console    all captured bip file list : ${all_bip_file_list}
    ${status}    Run Keyword And Return Status
    ...    OperatingSystem.Run   command=cd ${target_dir}${file_name};cp test_${next_index}.pcap ${target_file_name}.pcap
    Run Keyword If    ${status}    OperatingSystem.Run   command=cd ${target_dir}${file_name};rm test_*.pcap
    ${full_log_path}    Create List    ${target_dir}${/}${file_name}${/}${target_file_name}.pcap
    [Return]     ${full_log_path}
    [Teardown]    Run Keyword And Ignore Error    Run    rm ${gnb_logs_script_path}/gNB_${gnb_ip}_*_${log_type}.zip



Get Specific Direction TTItrace File from UTE
    [Documentation]    Auther: liujia
    [Arguments]    ${gnb_logs_script_path}=/home/ute/gnb_logs
    ...            ${target_dir}=${TS_CASE_LOG_PATH}
    ...            ${direction}=ul
    ...            ${gnb_index}=0
    ...            ${du_index}=0
    ...            ${log_type}=TTI
    ${timestamp}    robot.libraries.DateTime.Get current date    result_format=%Y%m%d%H%M%S
    ${specific_ttitrace_file_list}    Create List
    log to console    --- start to Download tti trace result to specific folder ---
    ${gnb_ip}    Set Variable    ${tl.gnbs[${gnb_index}].dus[${du_index}].f1_m_ip_addr}
    @{ttitrace_files}    List Files In Directory	${gnb_logs_script_path}	   gNB_${gnb_ip}_*_${log_type}.zip
    Copy Files    ${gnb_logs_script_path}/gNB_${gnb_ip}_*.zip    ${target_dir}
    ${all_fsp_files}    Create List
    FOR    ${ttitrace_file}    IN    @{ttitrace_files}
        ${file_name}    Set Variable    ${ttitrace_file.split('.zip')[0]}
        Run    unzip ${target_dir}/${ttitrace_file} -d ${target_dir}
        ${fsp_file}    List Directories In Directory	${target_dir}/${file_name}/tti_packed/
        ...                                             fsp-*_ttiTrace
        ...                                             absolute=${True}
        ${all_fsp_files}    Combine Lists     ${fsp_file}    ${all_fsp_files}
    END
    FOR    ${fsp_file}    IN    @{all_fsp_files}
        ${specific_ttitrace_file}    List Files In Directory	${fsp_file}
        ...                                                     *.${direction}__all.csv
        ...                                                     absolute=${True}
        ${specific_ttitrace_file_list}    Combine Lists     ${specific_ttitrace_file}    ${specific_ttitrace_file_list}
    END
    log to console    specific ttitrace file list : ${specific_ttitrace_file_list}
    [Return]    ${specific_ttitrace_file_list}
    [Teardown]    Run Keyword And Ignore Error    Run    rm ${gnb_logs_script_path}/gNB_${gnb_ip}_*_${log_type}.zip


###-----collect BIPlog from webui------###
Collect Interface Mirroring Bip Collector from WEBUI
    [Documentation]
    ...                :param target_file_name: (str) – name of collector
    ...                :param interface: (str) – L1-L2 or L2Hi-L2Lo
    ...                :param destination : (str) – Local or Remote
    ...                :param webservice: (dict) – Configuration of collector/host: base url IP/user: username, defaults to “Nemuadmin”
    ...                                            password: password, defaults to “nemuuser”/port: port, default 443
    ...                :param nr_phy_cell_ids: str) (nr_phy_cell_ids Union(list,) – (Optional) list of physical cell ids.
    ...                          If given ensure cell is on air before running the setup. If not given it will check nr_cell_dns
    ...                          like: 50,51, (Select max 8 cells), if nr_phy_cell_ids set as "None", means collect the logs of all cells.
    [Arguments]    ${target_dir}=${epc_log_path}    ${target_file_name}=l1l2bip_log
    ...            ${nr_phy_cell_ids}=None
    ...            ${gnb_index}=0
    ...            ${timeout}=600
    ...            ${interface}=L1-L2
    ...            ${destination}=Local
    ...            ${host_ip}=${tl.gnbs[${gnb_index}].cu.oam_ssh_connection_details.addr}
    ...            ${username}=${tl.gnbs[${gnb_index}].cu.oam_http_connection_details.username}
    ...            ${password}=${tl.gnbs[${gnb_index}].cu.oam_http_connection_details.password}
    ...            ${times}=1s
    ${webservice}=  Create Dictionary    host=${host_ip}
    ...                                  user=${username}
    ...                                  password=${password}
    ...                                  port=443
    l1l2bip.create_interface_mirroring_l1l2bip_collector    name=${target_file_name}
    ...                                                     webservice=${webservice}
    ...                                                     interface=${interface}
    ...                                                     destination=${destination}
    ...                                                     nr_phy_cell_ids=${nr_phy_cell_ids}
    ...                                                     target_file_name=${target_file_name}
    ...                                                     timeout=${timeout}
    core.setup_collectors    names=${target_file_name}
    core.start_collectors    names=${target_file_name}
    sleep    ${times}
    core.stop_collectors        names=${target_file_name}
    core.collect_collectors   names=${target_file_name}    target_dir=${target_dir}
    core.teardown_collectors    names=${target_file_name}
    l1l2bip.set_suite_alias    ${target_file_name}

Get Bip Log Via Interface Mirroring Collector to UTE
    [Documentation]
    ...                keyword is used to collect the log files to default path
    [Arguments]      ${target_file_name}=l1l2bip_log    ${pattern}=*.pcap    ${target_dir}=${epc_log_path}
    @{log_file}   List Files In Directory    path=${target_dir}${target_file_name}    pattern=${pattern}
    Sort List    ${log_file}
    FOR  ${log}  IN  @{log_file}
        ${index}    Get Index From List    ${log_file}    ${log}
        ${next_index}    Evaluate    ${index}+1
        Run Keyword If    '${index}'=='0'    OperatingSystem.Run   command=cd ${target_dir}${target_file_name};touch test_${index}.pcap
        OperatingSystem.Run   command=cd ${target_dir}${target_file_name};mergecap -w test_${next_index}.pcap test_${index}.pcap ${log}
    END
    ${status}    Run Keyword And Return Status
    ...    OperatingSystem.Run   command=cd ${target_dir}${/}${target_file_name};cp test_${next_index}.pcap ${target_file_name}.pcap
    Run Keyword If    ${status}    OperatingSystem.Run   command=cd ${target_dir}${target_file_name};rm test*.pcap
    Run Keyword If    ${status}    OperatingSystem.Run   command=cd ${target_dir}${target_file_name};rm BTS*.pcap
    ${full_log_path}    Create List    ${target_dir}${target_file_name}${/}${target_file_name}.pcap
    [Return]    ${full_log_path}
    [Teardown]    Stop Bip Log Via Interface Mirroring Collector from WEBUI    target_file_name=${target_file_name}

Stop Bip Log Via Interface Mirroring Collector from WEBUI
    [Documentation]
    ...                keyword is used to stop collect bip log
    [Arguments]      ${target_file_name}=l1l2bip_log
    core.stop_collectors        names=${target_file_name}
    core.teardown_collectors    names=${target_file_name}

Start Interface Mirroring Bip Collector
    [Documentation]    :param target_file_name: (str)  name of collector
    ...                :param interface: (str)  L1-L2 or L2Hi-L2Lo
    ...                :param destination : (str)  Local or Remote
    ...                :param webservice: (dict)  Configuration of collector/host: base url IP/user: username, defaults to “Nemuadmin”
    ...                                            password: password, defaults to “nemuuser”/port: port, default 443
    ...                :param nr_phy_cell_ids: str) (nr_phy_cell_ids Union(list,)  (Optional) list of physical cell ids.
    ...                          If given ensure cell is on air before running the setup. If not given it will check nr_cell_dns
    ...                          like: 50,51
    [Arguments]    ${target_file_name}=l1l2bip_log
    ...            ${nr_phy_cell_ids}=${None}
    ...            ${gnb_index}=0
    ...            ${timeout}=900
    ...            ${interface}=L1-L2
    ...            ${destination}=Local
    ...            ${host_ip}=${tl.gnbs[${gnb_index}].cu.oam_ssh_connection_details.addr}
    ...            ${username}=${tl.gnbs[${gnb_index}].cu.oam_http_connection_details.username}
    ...            ${password}=${tl.gnbs[${gnb_index}].cu.oam_http_connection_details.password}
    ${webservice}=  Create Dictionary    host=${host_ip}
    ...                                  user=${username}
    ...                                  password=${password}
    ...                                  port=443
    l1l2bip.create_interface_mirroring_l1l2bip_collector    name=${target_file_name}
    ...                                                     webservice=${webservice}
    ...                                                     interface=${interface}
    ...                                                     destination=${destination}
    ...                                                     nr_phy_cell_ids=${nr_phy_cell_ids}
    ...                                                     target_file_name=${target_file_name}
    ...                                                     timeout=${timeout}
    core.setup_collectors    names=${target_file_name}
    core.start_collectors    names=${target_file_name}
    l1l2bip.set_suite_alias    ${target_file_name}


Stop and collect Bip Log Via Interface Mirroring Collector from WEBUI
    [Documentation]
    ...                keyword is used to stop collect bip log
    [Arguments]      ${target_dir}=${epc_log_path}    ${target_file_name}=l1l2bip_log    ${pattern}=*.pcap
    l1l2bip.stop_collectors        names=${target_file_name}
    l1l2bip.collect_collectors     names=${target_file_name}    target_dir=${target_dir}
    l1l2bip.teardown_collectors    names=${target_file_name}
    ${full_log_path}     Get Bip Log Via Interface Mirroring Collector to UTE      target_file_name=${target_file_name}
    ...                                                                            pattern=${pattern}
    ...                                                                            target_dir=${target_dir}
    [Return]    ${full_log_path}


#####****capture ttitrace with admin****####
Capture Ttitrace With Admin Mode and Convert format
    [Documentation]    Auther: liujia
    [Arguments]    ${capture_time}=5s
    ...            ${names}=l2stream3_ttitrace
    ...            ${SW_BRANCH}=NULL
    ...            ${nr_phy_cell_ids}=NULL
    ...            ${gNB_index}=${0}
    ...            ${target_dir}=${epc_log_path}
    ...            ${l2_profileId}=0
    ...            ${l2_profileName}=Default
    Start Ttitrace With Admin Mode    names=${names}    SW_BRANCH=${SW_BRANCH}    nr_phy_cell_ids=${nr_phy_cell_ids}    gNB_index=${gNB_index}
    ...                               l2_profileId=${l2_profileId}    l2_profileName=${l2_profileName}
    Sleep    ${capture_time}    reason=capture ttitrace
    Stop Ttitrace With Admin Mode    names=${names}      target_dir=${target_dir}
    Convert Ttitrace From Pcap To Excelcsv    names=${names}      target_dir=${target_dir}



Start Ttitrace With Admin Mode
    [Arguments]    ${names}=l2stream3_ttitrace
    ...            ${host_ip}=${tl.gnbs[${gnb_index}].cu.oam_ssh_connection_details.addr}
    ...            ${username}=${tl.gnbs[${gnb_index}].cu.oam_http_connection_details.username}
    ...            ${password}=${tl.gnbs[${gnb_index}].cu.oam_http_connection_details.password}
    ...            ${SW_BRANCH}=NULL
    ...            ${port_num}=eth0
    ...            ${gnb_ip}=${host_ip}
    ...            ${ute_ip}=${tl.test_pc.default_ssh_connection_details.addr}
    ...            ${nr_phy_cell_ids}=NULL
    ...            ${gNB_index}=${0}
    ...            ${l2_profileId}=0
    ...            ${l2_profileName}=Default
    [Documentation]      Auther: liujia
    ...    This keyword is used to start ttitrace with streaming mode.
    ...    examples 1: catch all cells
    ...    Start Ttitrace With Streaming Mode
    log to console    setup admin for ttitrace...
    Run Keyword If    '${SW_BRANCH}'=='NULL'    Get Sw_Branch Version    gNB_index=${gNB_index}
    ${webserver}=  Create Dictionary    host=${host_ip}
    ...                                user=${username}
    ...                                password=${password}
    ...                                port=443
    ...                                release=${SW_BRANCH}
    Run Keyword If    "${nr_phy_cell_ids}"=="NULL"    Get PhysCellId Of GNB    gNB_index=${gNB_index}
    ${l2_profile_filter}=    Create Dictionary    profileId=${l2_profileId}
    ...                                           profileName=${l2_profileName}
    @{l2_profile_filter_list}=    Create List    ${l2_profile_filter}
    ${l2_stream_configuration}=    Create Dictionary
    ...    nr_phy_cell_ids=${nr_phy_cell_ids}
    ...    up_sw=L2Ps
    ...    trace_type=Component
    ...    profile_filter_list=${l2_profile_filter_list}
    @{l2_stream_configurations}=  Create List  ${l2_stream_configuration}
    tcpdump.create tcpdump collector
    ...    name=tcpdump_ttitrace
    ...    options=-i ${port_num} udp and src ${gnb_ip} and dst ${ute_ip} and dst port 5678
    ...    sudo_password=ute
    L2STREAM3.create_sbts_l2stream_collector
    ...    name=${names}
    ...    destination_ip_addr=${ute_ip}
    ...    source_ip_addr=${gnb_ip}
    ...    collector=tcpdump_ttitrace
    ...    l2_stream_configuration=${l2_stream_configurations}
    ...    webservice=${webserver}
    ...    dscp=10
    L2STREAM3.Set Suite Alias
    ...    alias=${names}
    core.setup_collectors
    ...    names=${names}
    core.start_collectors
    ...    names=${names}
    log to console    finish admin process for ttitrace,start to catch ttitrace log...

Stop Ttitrace With Admin Mode
    [Documentation]    Auther: liujia
    [Arguments]    ${names}=l2stream3_ttitrace      ${target_dir}=${epc_log_path}
    log to console    stop catching ttitrace...
    core.stop_collectors
    ...  names=${names}
    core.collect_collectors
    ...  names=${names}        target_dir=${target_dir}
    core.teardown_collectors
    ...  names=${names}

Start Ttitrace on other ute With Admin Mode
    [Arguments]    ${names}=l2stream3_ttitrace
    ...            ${host_ip}=${tl.gnbs[${gnb_index}].cu.oam_ssh_connection_details.addr}
    ...            ${username}=${tl.gnbs[${gnb_index}].cu.oam_http_connection_details.username}
    ...            ${password}=${tl.gnbs[${gnb_index}].cu.oam_http_connection_details.password}
    ...            ${SW_BRANCH}=NULL
    ...            ${port_num}=eth0
    ...            ${gnb_ip}=${host_ip}
    ...            ${ute_ip}=${tl.test_pc.default_ssh_connection_details.addr}
    ...            ${ute_user}=${tl.test_pc.default_ssh_connection_details.username}
    ...            ${ute_password}=${tl.test_pc.default_ssh_connection_details.password}
    ...            ${nr_phy_cell_ids}=NULL
    ...            ${gNB_index}=${0}
    [Documentation]      Auther: liujia
    ...    This keyword is used to start ttitrace with streaming mode.
    ...    examples 1: catch all cells
    ...    Start Ttitrace With Streaming Mode
    log to console    setup admin for ttitrace...
    Run Keyword If    '${SW_BRANCH}'=='NULL'    Get Sw_Branch Version    gNB_index=${gNB_index}
    ${webserver}=  Create Dictionary    host=${host_ip}
    ...                                user=${username}
    ...                                password=${password}
    ...                                port=443
    ...                                release=${SW_BRANCH}
    Run Keyword If    "${nr_phy_cell_ids}"=="NULL"    Get PhysCellId Of GNB    gNB_index=${gNB_index}
    ${l2_stream_configuration}=    Create Dictionary
    ...    nr_phy_cell_ids=${nr_phy_cell_ids}
    ...    up_sw=L2Ps
    ...    trace_type=Component
    @{l2_stream_configurations}=  Create List  ${l2_stream_configuration}
    tcpdump.create tcpdump collector
    ...    name=tcpdump_ttitrace
    ...    options=-i ${port_num} udp and src ${gnb_ip} and dst ${ute_ip} and dst port 5678
    ...    user=${ute_user}
    ...    password=${ute_password}
    L2STREAM3.create_sbts_l2stream_collector
    ...    name=${names}
    ...    destination_ip_addr=${ute_ip}
    ...    source_ip_addr=${gnb_ip}
    ...    collector=tcpdump_ttitrace
    ...    l2_stream_configuration=${l2_stream_configurations}
    ...    webservice=${webserver}
    ...    dscp=10
    L2STREAM3.Set Suite Alias
    ...    alias=${names}
    core.setup_collectors
    ...    names=${names}
    core.start_collectors
    ...    names=${names}
    log to console    finish admin process for ttitrace,start to catch ttitrace log...

Get PhysCellId Of GNB
    [Documentation]    Auther: liujia
    ...      This keyword to get radio protocol type from current scfc file
    [Arguments]    ${gNB_index}=${0}
    ${coam_connection}    COAM.Connect To    bts_host=${tl.gnbs[${gNB_index}].dus[0].airscale.common_units[0].lmp_connection.addr}
    ${cells_info}=    COAM.get_cell_list    connection=${coam_connection}
    ${cell_num}=    Get Length    ${cells_info['cells']['nr']}
    ${pci}=    Create List
    FOR    ${cell_id}    IN RANGE    ${cell_num}
        Append To List    ${pci}    ${cells_info['cells']['nr'][${cell_id}]['physicalCellId']}
    END
    Set Suite Variable    ${NR_PHY_CELL_IDS}    ${pci}
    [Return]    ${NR_PHY_CELL_IDS}
    [Teardown]    COAM.Teardown    ${coam_connection}

Get Sw_Branch Version
    [Documentation]    Auther: liujia
    [Arguments]    ${gNB_index}=${0}
    ${coam_connection}    coam.Connect To    bts_host=${tl.gnbs[${gNB_index}].dus[0].airscale.common_units[0].lmp_connection.addr}
    ${software_info_1}=    coam.Get Sw Version    connection=${coam_connection}
    Set Suite Variable    ${SOFTWARE_INFO}    ${software_info_1}
    Log    Software Version: ${SOFTWARE_INFO}    console=${True}
    @{sw_list}=    String.Split String    ${SOFTWARE_INFO}    _
    Set Suite Variable    ${SW_BRANCH}    ${sw_list[0]}
    [Teardown]    coam.Teardown    ${coam_connection}

Convert Ttitrace From Pcap To Excelcsv
    [Documentation]    Auther: liujia
    [Arguments]     ${names}=l2stream3_ttitrace    ${target_dir}=${epc_log_path}
    ${log_path}=    Set Variable    ${target_dir}/${names}
    ${file_path}=    Set Variable    ${log_path}/tcpdump_ttitrace/tcpdump_ttitrace.pcap
    OperatingSystem.Run    mkdir -p ${log_path}; cp -r "${file_path}" ${log_path}
    EVENTDECODER.Create Eventdecoder Converter
    ...    name=converter
    ...    input_file_path=${file_path}
    ...    output_file_path=${log_path}
    ...    output_file_format=excelCsv
    ...    excel_csv_options=-w
    EVENTDECODER.Convert
    ...    name=converter

###-----collect IP traffic capture with coam------###
Start IP Traffic Capturing
    [Documentation]
    ...  Author:xiaodan.li@nokia-sbell.com
    ...  Keyword for start capturing with inputed parameters
    ...  measurement_point:     NE_Terminated = CapturePoint A, Transport_Interface = CapturePoint B
    ...  uplane_capturing:      False or True
    ...  password:              Any user's password without special signs or "${EMPTY}"
    ...  timeout:               Time to wait for correct action of keyword
    [Arguments]    ${measurement_point}=NE_Terminated  ${uplane_capturing}=True  ${password}=${EMPTY}  ${connection}=gnb
    Log to console  Start IP traffic capturing...
    coam.start ip capture file     measurement_point=${measurement_point}
    ...                             uplane_capturing=${uplane_capturing}
    ...                             password=${password}
    ...                             connection=${connection}
    ...                             timeout=120

Stop IP Traffic Capturing
    [Documentation]
    ...  Author:xiaodan.li@nokia-sbell.com
    [Arguments]  ${connection}=gnb
    Log to console    Stop IP traffic capturing...
    coam.stop ip capture file    connection=${connection}

Download File With Captured Traffic
    [Documentation]
    ...  Author:xiaodan.li@nokia-sbell.com
    ...  Keyword for generate and download captured traffic
    ...  target_file_name:      filename with extension: .pcap.gz (without password) or .pcap.gz.enc (with password)
    [Arguments]    ${IP_Traffic_filename}    ${connection}=gnb
    Log to console    Download file with captured traffic...
    coam.generate ip capture file    connection=${connection}
    coam.download ip capture file    target_file_name=${epc_log_path}${IP_Traffic_filename}
    ...                               connection=${connection}
    ...                               timeout=120
    [Return]    ${IP_Traffic_filename}

IP Traffic Capturing And Download File
    [Documentation]
    ...  Author:xiaodan.li@nokia-sbell.com
    [Arguments]    ${IP_Traffic_filename}    ${gnb_index}=${0}    ${measurement_point}=NE_Terminated
    ...    ${uplane_capturing}=True    ${password}=${EMPTY}    ${capture_time}=120    ${w_unzip}=True    ${epc_log_path}=${epc_log_path}
    Connect to gnb coam via ssl    connection=gNB${gnb_index}    gnb_index=${gnb_index}
    Start IP Traffic Capturing
    ...                        measurement_point=${measurement_point}
    ...                        uplane_capturing=${uplane_capturing}
    ...                        password=${password}
    ...                        connection=gNB${gnb_index}
    Log  IP Traffic Capturing started. Duration: ${capture_time} [second].  console=True
    Sleep    ${capture_time}  reason= Time to capture traffic.
    Stop IP Traffic Capturing    connection=gNB${gnb_index}
    Download File With Captured Traffic
    ...                                     target_file_name=${IP_Traffic_filename}
    ...                                     connection=gNB${gnb_index}
    Log  File ${IP_Traffic_filename} downloaded.  console=True
    Run Keyword if    '${w_unzip}' == 'True'    Run    gunzip -f ${epc_log_path}/${IP_Traffic_filename}
    [Teardown]  Run keywords    run keyword and ignore error    Stop IP Traffic Capturing    connection=gNB${gnb_index}    AND
    ...                         run keyword and ignore error    csn.disconnect    connection=gNB${gNB_index}

Connect And Start IP Traffic Capturing
    [Documentation]
    ...  Author:xiaodan.li@nokia-sbell.com
    [Arguments]    ${gnb_index}=${0}    ${measurement_point}=NE_Terminated    ${uplane_capturing}=True    ${password}=${EMPTY}
    Connect to gnb coam via ssl    connection=gNB${gnb_index}    gnb_index=${gnb_index}
    Start IP Traffic Capturing
    ...                        measurement_point=${measurement_point}
    ...                        uplane_capturing=${uplane_capturing}
    ...                        password=${password}
    ...                        connection=gNB${gnb_index}

Stop IP Traffic Capturing and Download File
    [Documentation]
    ...  Author:xiaodan.li@nokia-sbell.com
    [Arguments]   ${IP_Traffic_filename}    ${gnb_index}=${0}    ${w_unzip}=True    ${epc_log_path}=${epc_log_path}
    Stop IP Traffic Capturing    connection=gNB${gnb_index}
    Download File With Captured Traffic
    ...                                     IP_Traffic_filename=${IP_Traffic_filename}
    ...                                     connection=gNB${gnb_index}
    Log  File ${IP_Traffic_filename} downloaded.  console=True
    Run Keyword if    '${w_unzip}' == 'True'    Run    gunzip -f ${epc_log_path}/${IP_Traffic_filename}
    [Teardown]  Run keywords    run keyword and ignore error    Stop IP Traffic Capturing    connection=gNB${gnb_index}    AND
    ...                         run keyword and ignore error    csn.disconnect    connection=gNB${gNB_index}

upgrade gnb logs tool on VM
    [Documentation]     Author: ming.shi@nokia-sbell.com
    [Arguments]    ${tool_download_path}
#    ${rc}    ${output}=    run and return rc and output
#    ...    command=cd ${tool_download_path};git clone https://gitlabe1.ext.net.nokia.com/p5li/gnb_logs-tool.git
#    should be equal as integers    ${rc}    0
#    should contain    ${output}    Resolving deltas: 100%
#    ${rc}    ${output}=    run and return rc and output
#    ...    command=cd ${tool_download_path}/gnb_logs-tool;unzip gnb_logs.zip
#    should be equal as integers    ${rc}    0
#    should contain    ${output}    gnb_logs.exe
#    should contain    ${output}    readme.txt
    ${rc}=    run and return rc
    ...    command=chmod 777 ${tool_download_path}/gnb_logs/*
    should be equal as integers    ${rc}    0
    ${rc}    ${output}=    run and return rc and output
    ...    command=cd ${tool_download_path}/gnb_logs/;./gnb_logs -v
#    should be equal as integers    ${rc}    1
    ${result}=    run keyword and return status    should contain    ${output}    Please upgrade by
    ${rc}    ${output}=    run keyword if    ${result}    run and return rc and output
    ...    command=cd ${tool_download_path}/gnb_logs/;yes "y" | ./gnb_logs -v
    comment    return code 3: No such process due to "Press <Enter> to exit"
    run keyword if    ${result}    run keywords
    ...    should be equal as integers    ${rc}    3
    ...    AND    should contain    ${output}    Upgrade done!
    ...    AND    log    gnb_logs tool upgrade done and success!
    ...    AND    log to console    gnb_logs tool upgrade done and success!
    ...    ELSE    run keywords
    ...    log    gnb_logs tool is latest version now!
    ...    AND    log to console    gnb_logs tool is latest version now!

    ${rc}=    run and return rc
    ...    command=chmod 777 ${tool_download_path}/gnb_logs/*
    should be equal as integers    ${rc}    0
#    log to console    gnb_logs tool clone success
#    log    gnb_logs tool clone success

to capture logs via gnb_logs tool
    [Documentation]     Author: ming.shi@nokia-sbell.com
    [Arguments]    ${option}    ${tool_download_path}    ${tool_path}=${tool_download_path}/gnb_logs
    ...    ${gnb_index}=${0}    ${gnb_ip}=${tl.gnbs[${gnb_index}].cu.oam_ssh_connection_details.addr}
    ${rm_old_logs_command}    catenate    cd ${tool_path};rm -rf BTS-${tl.gnbs[${gnb_index}].global_bts_id}_${gnb_ip}_*
    ${rc}=    run and return rc    command=${rm_old_logs_command}
    should be equal as integers    ${rc}    0
    ${start_capture_command}    Catenate
    ...    cd ${tool_path};./gnb_logs ${gnb_ip} ${option}
    ${rc}    ${output}=    run and return rc and output    command=${start_capture_command}
    should be equal as integers    ${rc}    0
    should contain    ${output}    Tool finished running.
    log   logs collected
    log to console    logs collected

put btslog_ini file to ute
    [Documentation]    Author: ming.shi@nokia-sbell.com
    [Arguments]    ${server_ip}    ${server_username}    ${server_password}    ${btslog_ini_path}=/home/vrf4_sg3/
    ...    ${filename}=btslog.ini    ${ute_btslog_path}=/home/ute/btslog2/
    wait until keyword succeeds    1min   10s
    ...    csn.Connect to    hostname=${server_ip}    username=${server_username}    password=${server_password}    alias=server
    csn.download_file   remote_path=${btslog_ini_path}${filename}   local_path=${ute_btslog_path}${filename}   connection=server
    sleep    3
    [Teardown]    csn.disconnect    connection=server
