*** Settings ***
Library    OperatingSystem
Library    Collections
Library    taf.stc.config
Library    String
Library    BuiltIn
Library    taf.config.scf    WITH NAME    scf
Library    taf.transport.ssh    WITH NAME    csn
Library    taf.transport.ssh    WITH NAME    ssh
Library    taf.pdu       WITH NAME    pdu
Library    taf.analyzer.pcap     WITH NAME    cap
Resource    taf/rfrl/common_resources/robot/connection_alias_store.robot
Resource    taf/rfrl/common_resources/robot/coam_selenium.robot
Resource    testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/robot/coam_gnb_classical.robot
Resource    taf/rfrl/common_resources/robot/TTI_Trace.robot
Resource    testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/robot/CI_Operations/CI_interface.robot
Resource    testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/lines/MMW_SG1/0_Deprecated/gnb_board_type.robot
Resource    testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/lines/SG2/bip_common_keyword.robot

Documentation
...   author: Chen Tong
...   contact: tong.chen@nokia-sbell.com
...   squad group: SG_02

*** Variables ***
${WEBUI_OAM}    https://${tl.gnbs[0].cu.oam_http_connection_details.addr}
${WEBUI_NAME}    ${tl.gnbs[0].cu.oam_http_connection_details.username}
${WEBUI_PWD}    ${tl.gnbs[0].cu.oam_http_connection_details.password}
${CU_ADDR}    ${tl.gnbs[0].cu.oam_ssh_connection_details.addr}
${CU_NAME}    ${tl.gnbs[0].cu.oam_ssh_connection_details.username}
${CU_PWD}    ${tl.gnbs[0].cu.oam_ssh_connection_details.password}
${DU_ADDR}    ${tl.gnbs[0].dus[0].airscale.common_units[0].lmp_connection.addr}
${DU_NAME}    ${tl.gnbs[0].dus[0].airscale.common_units[0].lmp_connection.username}
${DU_PWD}    ${tl.gnbs[0].dus[0].airscale.common_units[0].lmp_connection.password}
${LONER_ADDR}    192.168.253.22
#${LONER_NAME}    root
${RU_PDU_ADDR}    ${tl.gnbs[0].dus[0].rus[0].pdu_port.pdu.addr}
@{RU_PDU_PORT}    ${tl.gnbs[0].dus[0].rus[0].pdu_port.port_no}

${asik}    ASIK Master
${abil1_loner}    ABIL Loner
${oam}    OAM
@{vms_names}

${tmp_log_dir}      ${OUTPUT DIR}
${tmp_scf_dir}      /home/ute/Downloads/SCF
${gnb_tmp_log_dir}    /tmp

${time_relative}     frame.time_relative

*** Keywords ***
Start to Capture Wireshark Log
    [Arguments]    ${listen_port}     ${log_dir}     ${filename}    ${connection}
    csn.send command    command=sudo tcpdump -n -i ${listen_port} -w ${log_dir}/${filename} &>/dev/null &    connection=${connection}
    sleep    3s

Start to Capture Wireshark Log with filter
    [Arguments]    ${listen_port}     ${log_dir}     ${filename}    ${filter}    ${connection}
    csn.send command    command=sudo tcpdump -n -i ${listen_port} -w ${log_dir}/${filename} ${filter} &>/dev/null &    connection=${connection}
#    csn.send command    command=ip netns exec radions tcpdump -n -i ${listen_port} -w ${log_dir}/${filename} ${filter} &>/dev/null &
#    ...    connection=${connection}
    sleep    3s

Start to Capture Wireshark Log from Loner
    [Arguments]    ${filename}    ${filter}=none    ${conn}=${abil1_loner}
    Connect to Capacity Unit Loner case
    Run Keyword If    ${filter} is None    Start to Capture Wireshark Log    listen_port=arb0p3     log_dir=${gnb_tmp_log_dir}
    ...                                           filename=${filename}    connection=${conn}
    ...               ELSE    Start to Capture Wireshark Log with filter    listen_port=arb0p3     log_dir=${gnb_tmp_log_dir}
    ...                                           filename=${filename}    filter=${filter}    connection=${conn}

Start to Capture Wireshark Log from RU
    [Arguments]    ${filename}    ${filter}=none    ${listen_port}=arb0p0
    Connect to RU With Allocated IP
    Run Keyword If    ${filter} is None    Start to Capture Wireshark Log    listen_port=${listen_port}     log_dir=${gnb_tmp_log_dir}
    ...                                           filename=${filename}    connection=RU
    ...               ELSE    Start to Capture Wireshark Log with filter    listen_port=${listen_port}     log_dir=${gnb_tmp_log_dir}
    ...                                           filename=${filename}    filter=${filter}    connection=RU

Read Wireshark Log
    [Arguments]    ${filename}    ${filepath}=${tmp_log_dir}    ${filter}=${None}
    cap.Read Cap    cap_file=${filepath}/${filename}
    ...             display_filter=${filter}

Check expression in Wireshark Log
    [Arguments]    ${expression}
    cap.Check Expression    condition_expression=${expression}

Stop and Download Logs from Loner
    [Arguments]    @{filenames}
    csn.execute        command=ps -ef|grep -i tcpdump     connection=${abil1_loner}
    csn.send command        command=ps -ef|grep tcpdump|grep -v grep| awk '{print $2}' |xargs kill -2     connection=${abil1_loner}
#    csn.send command        command=killall tcpdump     connection=${abil1_loner}
    FOR    ${filename}    IN    @{filenames}
        csn.download_file   remote_path=${gnb_tmp_log_dir}/${filename}    local_path=${tmp_log_dir}/${filename}   connection=${abil1_loner}
        sleep    2s
        csn.execute    command=rm ${gnb_tmp_log_dir}/${filename}    connection=${abil1_loner}
    END

Stop and Download Logs from RU
#    [Arguments]    @{filenames}
    [Arguments]    @{filenames}    ${container_id}=0x1018    ${asik_alias}=ASIK Master
    ...            ${ru_index}=${1}    ${gnb_index}=${0}
    ...            ${ru_username}=${tl.gnbs[0].dus[0].rus[${ru_index}-1].default_ssh_connection_details.username}
    ...            ${ru_password}=${tl.gnbs[0].dus[0].rus[${ru_index}-1].default_ssh_connection_details.password}
    ...            ${asik_addr}=${tl.gnbs[${gnb_index}].cu.oam_ssh_connection_details.addr}
    ...            ${asik_name}=${tl.gnbs[${gnb_index}].cu.oam_ssh_connection_details.username}
    ...            ${asik_pass}=${tl.gnbs[${gnb_index}].cu.oam_ssh_connection_details.password}
    csn.execute        command=ps -ef|grep -i tcpdump     connection=RU
    csn.send command        command=ps -ef|grep tcpdump|grep -v grep| awk '{print $2}' |xargs kill -2     connection=RU
#    csn.send command        command=killall tcpdump     connection=RU
    csn.send command        command=sudo chmod 777 ${gnb_tmp_log_dir}    connection=RU
    FOR    ${filename}    IN    @{filenames}
        csn.send command        command=sudo chmod 777 ${gnb_tmp_log_dir}/${filename}    connection=RU
#        csn.download_file   remote_path=${gnb_tmp_log_dir}/${filename}    local_path=${tmp_log_dir}/${filename}   connection=RU
#        sleep    2s
        ${connection}    csn.get_connection_by_alias    alias=${asik_alias}
        csn.execute    command=rm /ffs/run/config/toor4nsn/.ssh/known_hosts    connection=${connection}
        ${channel}    Call Method    ${connection}    invoke_shell
        Call Method    ${channel}    send    lxc-attach -n ${container_id}\n
        Sleep    1 sec
        Call Method    ${channel}    recv    ${65535}
        Call Method    ${channel}    send    scp ${ru_username}@${ru_ip_addr}:${gnb_tmp_log_dir}/${filename} /tmp\r
        Sleep    3 sec
        Call Method    ${channel}    recv    ${65535}
        Call Method    ${channel}    send    yes\r
        Sleep    3 sec
        Call Method    ${channel}    recv    ${65535}
        Call Method    ${channel}    send    ${ru_password}\r
        Sleep    3 sec
        Call Method    ${channel}    recv    ${65535}
        sleep    10s
        Run Keyword And Ignore Error    run process
        ...  sudo sshpass -p ${asik_pass} scp ${asik_name}@${asik_addr}:/tmp/node_FHNET00/tmp/${filename} ${tmp_log_dir}/${filename}   shell=yes
        csn.execute    command=rm /tmp/node_FHNET00/tmp/${filename}    connection=${connection}
        csn.execute    command=sudo rm ${gnb_tmp_log_dir}/${filename}    connection=RU
        Run Keyword And Ignore Error    OperatingSystem.Run    sudo chmod 777 ${tmp_log_dir}/${filename}
    END

Stop and Download Logs from RU for DomainNumber
    #    [Arguments]    @{filenames}
    [Arguments]    @{filenames}    ${container_id}=0x1018    ${asik_alias}=ASIK Master
    ...            ${ru_index}=${1}    ${gnb_index}=${0}
    ...            ${ru_username}=${tl.gnbs[0].dus[0].rus[${ru_index}-1].default_ssh_connection_details.username}
    ...            ${ru_password}=${tl.gnbs[0].dus[0].rus[${ru_index}-1].default_ssh_connection_details.password}
    ...            ${asik_addr}=${tl.gnbs[${gnb_index}].cu.oam_ssh_connection_details.addr}
    ...            ${asik_name}=${tl.gnbs[${gnb_index}].cu.oam_ssh_connection_details.username}
    ...            ${asik_pass}=${tl.gnbs[${gnb_index}].cu.oam_ssh_connection_details.password}
    csn.execute        command=ps -ef|grep -i tcpdump     connection=RU
    csn.send command        command=ps -ef|grep tcpdump|grep -v grep| awk '{print $2}' |xargs kill -2     connection=RU
#    csn.send command        command=killall tcpdump     connection=RU
    csn.send command        command=sudo chmod 777 ${gnb_tmp_log_dir}    connection=RU
    FOR    ${filename}    IN    @{filenames}
        csn.send command        command=sudo chmod 777 ${gnb_tmp_log_dir}/${filename}    connection=RU
#        csn.download_file   remote_path=${gnb_tmp_log_dir}/${filename}    local_path=${tmp_log_dir}/${filename}   connection=RU
#        sleep    2s
        ${connection}    csn.get_connection_by_alias    alias=${asik_alias}
        csn.execute    command=rm /ffs/run/config/toor4nsn/.ssh/known_hosts    connection=${connection}
        ${channel}    Call Method    ${connection}    invoke_shell
        Call Method    ${channel}    send    lxc-attach -n ${container_id}\n
        Sleep    1 sec
        Call Method    ${channel}    recv    ${65535}
        Call Method    ${channel}    send    scp ${ru_username}@${ru_ip_addr}:${gnb_tmp_log_dir}/${filename} /tmp\r
        Sleep    3 sec
        Call Method    ${channel}    recv    ${65535}
        Call Method    ${channel}    send    yes\r
        Sleep    3 sec
        Call Method    ${channel}    recv    ${65535}
        Call Method    ${channel}    send    ${ru_password}\r
        Sleep    3 sec
        Call Method    ${channel}    recv    ${65535}
        sleep    10s
#        Run Keyword And Ignore Error    run process
#        ...  sudo sshpass -p ${asik_pass} scp ${asik_name}@${asik_addr}:/tmp/node_FHNET00/tmp/${filename} ${tmp_log_dir}/${filename}   shell=yes
        csn.download_file   remote_path=/tmp/node_FHNET00/tmp/${filename}    local_path=${tmp_log_dir}/${filename}   connection=${connection}
        sleep    2s
        csn.execute    command=rm /tmp/node_FHNET00/tmp/${filename}    connection=${connection}
        csn.execute    command=sudo rm ${gnb_tmp_log_dir}/${filename}    connection=RU
        Run Keyword And Ignore Error    OperatingSystem.Run    sudo chmod 777 ${tmp_log_dir}/${filename}
    END
    Run keyword and ignore error    csn.Disconnect    connection=RU
    Run keyword and ignore error    csn.Disconnect    connection=${connection}
    Run keyword and ignore error    csn.Reset cache

Capture Wireshark Log for a While from Loner
    [Arguments]    ${filename}    ${time}    ${filter}=${None}
    Start to Capture Wireshark Log from Loner    filename=${filename}    filter=${filter}
    sleep    ${time}
    Stop and Download Logs from Loner     ${filename}

Capture Wireshark Log for a While from RU
    [Arguments]    ${filename}    ${time}=10s    ${filter}=${None}    ${listen_port}=arb0p0
    Start to Capture Wireshark Log from RU    filename=${filename}    filter=${filter}    listen_port=${listen_port}
    sleep    ${time}
    Stop and Download Logs from RU     ${filename}

Capture Wireshark Log for a While from RU for DomainNumber
    [Arguments]    ${filename}    ${time}=10s    ${filter}=${None}    ${listen_port}=ecpri1
    Start to Capture Wireshark Log from RU    filename=${filename}    filter=${filter}    listen_port=${listen_port}
    sleep    ${time}
    Stop and Download Logs from RU for DomainNumber     ${filename}

Get Frame Info Value from Wireshark Log
    [Arguments]    ${filename}    ${check_param}   ${condition_expression}=${None}
    Load BIP Log with Template Command    pcap_file=${tmp_log_dir}/${filename}
    ...                                   command_template=${command_template}
    pcap.filter_packets_by_expression    filter_expression=${condition_expression}
    ${value}      pcap.get_field_value_by_name    field_name=${check_param}
    [Return]    ${value}

Check Message Rate
    [Arguments]    ${filename}    ${filter}    ${min_rate}    ${max_rate}
    ${msg}=    Get Frame Info Value from Wireshark Log
    ...        filename=${filename}
    ...        check_param=${time_relative}
    ...        condition_expression=${filter}
    ${cnt}=    Get Length     ${msg}
    ${time}=    Evaluate    ${msg[-1]}-${msg[0]}
    ${rate}=    Evaluate        (${cnt}-1)/${time}
    Should Be True     ${min_rate} < ${rate} < ${max_rate}
