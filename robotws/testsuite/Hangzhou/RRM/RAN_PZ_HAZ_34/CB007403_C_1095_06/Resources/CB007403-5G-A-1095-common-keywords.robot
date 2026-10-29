*** Settings ***
Documentation
...               author: Na Li
...               contact: na.li@nokia-sbell.com
...               squad group: MMW_SG_04

Resource            testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/robot/coam_gnb_classical.robot
Library           taf.config.scf    WITH NAME    cscf

*** Variables ***
${MRBTS_ID}               ${tl.gnbs[0].instance_id}
${NRBTS_ID}               ${tl.gnbs[0].global_bts_id}
${MRBTS_ID2}               ${tl.gnbs[1].instance_id}
${NRBTS_ID2}               ${tl.gnbs[1].global_bts_id}
${TEST_PC_IP}             ${tl.test_pc.default_ssh_connection_details.addr}
${TEST_PC_USERNAME}       ${tl.test_pc.default_ssh_connection_details.username}
${TEST_PC_PASSWORD}       ${tl.test_pc.default_ssh_connection_details.password}
${target}                 ${OUTPUT_DIR}/btslog.log
${E500_SCRIPTS_BASE}      ${CURDIR}/E500_scripts
${LOG_PATH}               ${OUTPUT_DIR}
${DU_IP}                    ${tl.gnbs[0].dus[0].f1_m_ip_addr}
${WEBEM_USERNAME}           ${tl.gnbs[0].cu.oam_http_connection_details.username}
${WEBEM_PASSWORD}           ${tl.gnbs[0].cu.oam_http_connection_details.password}
${scf_file_path}            ${output_dir}
${ROOT_USERNAME}          toor4nsn
${ROOT_PASSWORD}          oZPS0POrRieRtu
${gNB2_ip}                ${tl.gnbs[1].dus[0].f1_m_ip_addr}

*** Keywords ***
Get Version
    [Arguments]     ${conn}=cOAM_admin
    Log To Console    Get Version
    Connect to gnb coam via ssl    connection=${conn}    bts_host=${DU_IP}
    ${version}    coam.get_sw_version    connection=${conn}
    ${version_list}    split string    ${version}    _
    ${versiontitle}    set variable    ${version_list[0]}
    [Return]    ${versiontitle}
    [Teardown]    coam.Teardown  connection=${conn}

Get Version gnb2
    [Arguments]     ${conn}=cOAM_admin1
    Log To Console    Get Version
    Connect to gnb coam via ssl  connection=${conn}    bts_host=${gNB2_ip}
    ${version}    coam.get_sw_version    connection=${conn}
    ${version_list}    split string    ${version}    _
    ${versiontitle}    set variable    ${version_list[0]}
    [Return]    ${versiontitle}
    [Teardown]    coam.Teardown  connection=${conn}

Disconnect from DU
    [Arguments]    ${alias}=cOAM_admin
    coam.teardown     connection=${alias}

COAM Commission with scf file ignore error
    [Arguments]  ${scf_file_path}=${CURDIR}/../../../../../../commissionings/HGZ/${testline_name}/1095_SCF_Trunk_gNB1.xml
    ...    ${connection}=GNB_OAM    ${timeout}=300    ${is_pdl_checking_needed}=${True}
    &{result}    coam.perform_commissioning    scf_file=${scf_file_path}
    ...    timeout=${timeout}    skip_parameter_relation_errors=${True}    connection=${connection}

ADMIN Check onair
    [Arguments]        ${admin_alias}=${LOGGING_ADMIN_ALIAS}
    ${dict_info}=   coam.Get Bts Info    connection=${admin_alias}
    ${state}=    Get From Dictionary    dictionary=${dict_info['status']}    key=proceduralState
    Should be equal    ${state}    OnAir

ADMIN Wait Until BTS OnAir
    [Arguments]    ${timeout}=15 min
    ...            ${interval}=30 sec
    ...            ${alias}=cOAM_admin
    Wait Until Keyword Succeeds    ${timeout}
    ...                            ${interval}
    ...                            ADMIN Check onair
    ...                            admin_alias=${alias}

Adjust Enb
    [Arguments]    ${index}=${3}    ${alias}=enblte    ${dist_name}=MRBTS-${tl.enbs[0].global_bts_id}/LNBTS-${tl.enbs[0].global_bts_id}/LNCEL-1
    ...    ${parameter}=defaultLnRelGnbCellId
    Connect and Modify the parameter on enblte  ${dist_name}    ${parameter}     ${index}

Check wireshark log data contain messages
    [Arguments]    ${message}     ${txt_filename}=attach_message.txt     ${connection}=ute
    csn.Send Command  command=cat ${LOG_PATH}/${txt_filename} | grep ${message}    connection=${connection}
    ${data}    csn.Read Output    connection=${connection}
    ${data}    strip_string    ${data}
    should not be empty    ${data}
    log to console    data:${data}

ssh connect to DU
    [Arguments]  ${ip_address}=${tl.gnbs[0].dus[0].f1_m_ip_addr}  ${alias}=cOAM_toor4nsn
    ...    ${ROOT_USERNAME}=toor4nsn    ${ROOT_PASSWORD}=oZPS0POrRieRtu
    ${connection}=  ssh.Connect to  ${ip_address}
    ...                             ${ROOT_USERNAME}
    ...                             ${ROOT_PASSWORD}
    ...                             alias=${alias}
    [Return]  ${connection}

start BBMOD tcpdump log
    [Arguments]   ${pcap}=enb_tcpdump_2.pcap    ${interface}=any
    ...    ${ip_address}=${tl.gnbs[0].dus[0].f1_m_ip_addr}  ${alias}=cOAM_toor4nsn
    ${connection}    ssh connect to DU    ip_address=${ip_address}  alias=${alias}
    ssh.send command    command=ps -ef |grep tcpdump |grep -v grep |grep ${interface} |awk '{print $2}' |xargs kill -2    connection=${connection}
    sleep    2s
    ssh.send command                    command=cd /ram && ls -l | grep CPRT | cut -d "_" -f 2|cut -d " " -f 1|head -1
    ...                                 connection=${connection}
    ${readOutput}=         ssh.readOutput    connection=${connection}
    ssh.send command
    ...    command=cd /ram && lxc-attach -n ${readOutput.split("\n")[0]} && nohup tcpdump -i any -w ${pcap} &>/dev/null &
    ...                                 connection=${connection}
    [Teardown]  ssh.disconnect          connection=${connection}

Stop 1416 trace capturing
    [Arguments]        ${log_prefix}=enb_tcpdump_2.pcap    ${alias}=ASIK Slave    ${retry_time}=10
    ...    ${ip_address}=${tl.gnbs[0].dus[0].f1_m_ip_addr}
    ${connection_alias}    ssh connect to DU    ip_address=${ip_address}  alias=${alias}
    FOR    ${i}    IN RANGE    ${retry_time}
        ssh.execute    ps -ef | grep tcpdump | grep -v grep | grep ${log_prefix} | awk '{print $2}' | xargs kill -2
        ...    connection=${connection_alias}
        ${is_trace_capture_stopped}    run keyword and return status    wait until keyword succeeds    5s    200ms
        ...    Trace capturing process should be stopped    log_prefix=${log_prefix}    connection_alias=${connection_alias}
        exit for loop if    ${is_trace_capture_stopped}==${True}
    END
    should be true    ${is_trace_capture_stopped}
    ssh.download_file                   remote_path=/ram/${log_prefix}
    ...                                 local_path=${LOG_PATH}/${log_prefix}
    ...                                 connection=${connection_alias}
    [Teardown]  ssh.disconnect          connection=${connection_alias}

1095 Download Viavi Log
    [Documentation]
    [Arguments]  ${logs_path}    ${connect}=Control_PC
    log to console    ${logs_path}
    ssh.Connect to    hostname=${E500_IP}    username=${E500_USER}    password=${E500_PW}    alias=${connect}
    ${new_path}    set variable    /cygdrive/c/Users/nokia5G/Documents/CSV/${logs_path}[1]
    ssh.send command    command=mkdir ${new_path}    connection=${connect}
    ssh.send command    command=cd '${logs_path}[0]';scp *.csv ${new_path}     connection=${connect}
    sleep    40s
    ${buffer}=         ssh.readOutput    connection=${connect}
    5GC000573_common_keyword.Copy Viavi Log    logs_path=${new_path}
    ssh.send command    command=rm -rf ${new_path}    connection=${connect}
    ${ute_path}    set variable    ${output_dir}/${logs_path}[1]
    [Return]  ${ute_path}
    [Teardown]    Run Keyword And Ignore error    ssh.disconnect    connection=${connect}
