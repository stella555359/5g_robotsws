*** Settings ***
Documentation    author: Deng xueqin
...              Group: HGZ_SG7
...              contact: xueqin.deng@nokia-sbell.com
...              Description

Resource    testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/robot/container_log_capturing.robot
Resource    testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/robot/coam_siso_common.robot
Resource    testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/robot/coam_gnb_classical.robot

*** Variables ***
#${ru_ip_addr}=    ${tl.gnbs[0].dus[0].rus[0].default_ssh_connection_details.addr}
${ru_default_username}=    ${tl.gnbs[0].dus[0].rus[0].default_ssh_connection_details.username}
${ru_default_password}=    ${tl.gnbs[0].dus[0].rus[0].default_ssh_connection_details.password}
${ru_config_path}=    /ffs/run/config
${filename}=    FRIps.txt

*** Keywords ***
Verify MPlane L2 QoS Priority
    [Documentation]    Author: Deng xueqin
    ...                Description: Verify MPlane L2 QoS Priority
    [Arguments]    ${pcap_file}
    ${filtered_packets}=    Load pcap with filter    pcap_file=${pcap_file}    filter_expression=${filter_expression}
    ${vlan_priority}=    Get field value    packets=${filtered_packets}    field_name=${field_name}
    should contain    ${vlan_priority}    2

Delete Log Dir
    [Documentation]    Author: Deng xueqin
    ...                Description: Delete the download log dir
    [Arguments]    ${log_dir}
    Run Keyword And Ignore Error    run    command=rm -rf ${log_dir}

Collect RF Tcpdump Logs To TestPC
    [Documentation]    Author: Deng xueqin
    ...                Description: Capture tcpdump on RU after feature 1834 opened and download log to testpc
    [Arguments]  ${log_name}=ru_tcpdump.pcap    ${ru_index}=1    ${du_alias}=DU    ${container_id}=0x1018
    ...    ${container_alias}=Container    ${fhnet_host_ip}=192.168.255.254    ${ru_alias}=RU
    ...    ${ru_username}=${ru_default_username}    ${ru_password}=${ru_default_password}
    Wait Until Keyword Succeeds    5min    30s    coam_gnb_classical.Cloud DU connect to gnb coam via ssl
    ${ru_ip_addr}    Get RU IP from config file
    csn.send_command    command=rm /user/toor4nsn/.ssh/known_hosts    connection=${du_alias}
    Connect To RU Via FHNET Container    ru_ip_addr=${ru_ip_addr}
    ...                                  container_id=${container_id}
    ...                                  container_alias=${container_alias}
    ...                                  ru_alias=${ru_alias}
    ...                                  asik_alias=${du_alias}
    ...                                  fhnet_host_ip=${fhnet_host_ip}
    ...                                  ru_username=${ru_username}
    ...                                  ru_password=${ru_password}
    csn.execute    command=sudo /usr/sbin/tcpdump -c 2000 -i any -w /ram/${log_name}    connection=${ru_alias}
    csn.send_command    command=rm /user/toor4nsn/.ssh/known_hosts    connection=${container_alias}
    ${log_du_path}    set variable    /tmp/node_${container_id}/tmp/${log_name}
    csn.Send Command
    ...        command=scp -o StrictHostKeyChecking\=no ${ru_username}@${ru_ip_addr}:/ram/${log_name} /tmp/${log_name}
    ...        get_pty=True
    ...        connection=${container_alias}
    ${scp_output} =    Run Keyword And Ignore Error
    ...                csn.read output until    match=password:    timeout=10    connection=${container_alias}
    Log    ${scp_output}
    run keyword if    '${scp_output[0]}' == 'PASS'
    ...              csn.write input    data=${ru_password}\n    connection=${container_alias}
    sleep    10s
    csn.download file
    ...    remote_path=${log_du_path}
    ...    local_path=/tmp/${log_name}
    ...    connection=${du_alias}
    ${ru_log_path}    set variable    /tmp/${log_name}
    [Return]    ${ru_log_path}    
    [Teardown]  Run Keywords   Run Keyword And Ignore Error   csn.disconnect   connection=${ru_alias}    AND
    ...                        Run Keyword And Ignore Error   csn.disconnect   connection=${container_alias}    AND
    ...                        Run Keyword And Ignore Error   csn.disconnect   connection=${du_alias}    AND
    ...                        Run Keyword And Ignore Error   coam.teardown    connection=GNB_OAM

Connect to ASIK via ssh
    [Arguments]    ${alias}=ASIK
    csn.connect to    hostname=${tl.gnbs[0].dus[0].airscale.common_units[0].lmp_connection.addr}
    ...               username=${tl.gnbs[0].dus[0].airscale.common_units[0].lmp_connection.username}
    ...               password=${tl.gnbs[0].dus[0].airscale.common_units[0].lmp_connection.password}
    ...               alias=${alias}

Get RU IP from config file
    csn.download_file   local_path=/tmp/${filename}    remote_path=${ru_config_path}/${filename}    connection=DU
    ${output}=    run    cat /tmp/${filename}
    @{ret}=    String.split string    string=${output}    separator=;
    ${ru_ip_addr}    set variable    ${ret}[2]
    [Return]    ${ru_ip_addr}
