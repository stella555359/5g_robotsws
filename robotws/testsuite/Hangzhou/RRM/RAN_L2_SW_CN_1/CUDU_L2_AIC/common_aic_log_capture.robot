*** Settings ***

*** Keywords ***
Collect UTE SosReport
    [Arguments]    ${log_dir}
    ${result}    Execute Egate Command    sim_log_set flush
    ${command}    Catenate    sed -i \'s@LOG_DIR_ON_DEVICE=.*@LOG_DIR_ON_DEVICE="/tmp/sosreport"@g\'
    ...    ${wts_dir}/sosReport.cfg
    OperatingSystem.Run    ${command}
    OperatingSystem.Run    cd ${log_dir}/ && ${wts_dir}/sosReport.sh -nr -c -s > /dev/null 2>\&1
    OperatingSystem.Run    ls ${log_dir}/SosReport*.tgz

Save Egate Log
    [Arguments]    ${log_path}=${SUITE_LOG_DIRECTORY}
    [Documentation]    This keyword is to copy egate console log from /opt/iphy/latest/egate_console.log to ${log_path}
    ...    after execute 'sim_log_set flush'
    ute_wtssim.Execute Egate Command    sim_log_set flush
    OperatingSystem.Copy Files    /opt/iphy/latest/egate_console.log*    ${log_path}

Start TTiTrace Log
    [Arguments]    ${cell_id_list}=All    ${ttitrace_log}=/tmp/ttitrace.pcap
    [Documentation]    This keyword is to start ttitrace log
    ...
    ...    | Input Parameters | Man. | Description |
    ...    | ${cell_id_list} | YES | it's a list. @{cell_id_list} | 1 | 2 | |
    ...    | ${ttitrace_log} | NO | log saved path and the file name |
    ...
    ...    Examples:
    ...    | ${cell_id_list} | Create List | 1 |
    ...    | Start TTiTrace Log | ${cell_id_list} |  |
    Set Route For Capture Ttitrace Log
    _VDU Update User Plane Trace Configuration    10.0.12.1    55900
    ${nr_cell_dn_list}    VDU Get NRCELL Dist_Name From Cell Status    ${cell_id_list}
    ${trace_id}    _VDU Start Uplane Trace    L2Ps    ${nr_cell_dn_list}
    Run Keyword and Ignore Error    Run    sudo rm -rf /tmp/ttitrace*
    ${result}    Process.Start Process    sudo tcpdump -v -ni eth9 port 55900 -C 100 -W 10 -w ${ttitrace_log}    shell=True
    Log To Console    -->Start to capture ttitrace log ...
    [Return]    ${trace_id}

Stop TTiTrace Log
    [Arguments]    ${trace_id}
    Log To Console    -->Stop to capture ttitrace log ...
    ${output}    Run    ps -ef|grep ttitrace
    ${output}    Run    sudo ps aux|grep 'tcpdump -v -ni eth9 port 55900'|awk '{print $2}'|xargs sudo kill -2
    Sleep    1s    reason=wait ttitrace killed successful
    ${output}    Run    ps -ef|grep ttitrace
    VDU Stop Uplane Trace    ${trace_id}

Decode TTiTrace Log
    [Arguments]    ${ttitrace_log}=/tmp/ttitrace.pcap    ${csv_dir}=${TEST_LOG_DIRECTORY}
    Log To Console    -->Start to decode ttitrace log ...
    Set Test Variable    ${decoder_tool_name}    vDUCNF00_${VDU_SW_VERSION}_tti-dec.deb
    Set Test Variable    ${ttiTrace_Dir}    /home/ute/${VDU_SW_VERSION}
    ${passed}    Run Keyword And Return Status    File Should Exist    ${ttiTrace_Dir}/${decoder_tool_name}
    Run Keyword Unless    ${passed}    Download TtiTrace Decode Tool
    ${tti_dec_bin_dir}    Set Variable    /opt/tti-dec/tti-dec-bin
    ${rc}    ${output}    Run and Return RC and Output   sudo cp ${ttitrace_log}0 ${ttitrace_log}
    Should Be Equal As Integers    ${rc}    0    msg=${output}
    ${rc}    ${output}    Run and Return RC and Output   cd ${tti_dec_bin_dir} && python3 TtiTraceDecoder.py ${ttitrace_log} excelCsv
    Should Be Equal As Integers    ${rc}    0    msg=${output}
    ${output}    Run    cp ${tti_dec_bin_dir}/ttiTrace_*.csv ${csv_dir}
    ${ret}    Run    ls -lrt ${csv_dir} |grep ttiTrace

Download TtiTrace Decode Tool
    ${tool_base_repo}    Set Variable    https://artifactory-espoo1.int.net.nokia.com/artifactory/mnp5g-central-public-local/System_Release/
    ${sw_version}    Set Variable If    '${BRANCH}'=='Trunk'    vDUCNF00/vDUCNF00_${VDU_SW_VERSION}
    ${tool_url}=    Set Variable    ${tool_base_repo}${sw_version}/${decoder_tool_name}
    ${rc}    ${output}    Run and Return RC and Output    wget --no-check-certificate ${tool_url} -P ${ttiTrace_Dir}
    Should Contain    ${output}     200 OK     msg=Download decode tool failed
    ${rc}    ${output}    Run and Return RC and Output    cd ${ttiTrace_Dir} && chmod +x ${decoder_tool_name}
    ${rc}    ${output}    Run and Return RC and Output    pip install -U numpy pandas
    Should Be Equal As Integers    ${rc}    0    msg=${output}
    ${rc}    ${output}    Run and Return RC and Output    cd ${ttiTrace_Dir} && sudo dpkg -i ${decoder_tool_name}
    Should Be Equal As Integers    ${rc}    0    msg=${output}

Get F1uplane IP
    ssh.Connect To    hostname=${VCU_K8S_INFO.ip}    username=${VCU_K8S_INFO.username}
    ...    password=${VCU_K8S_INFO.password}    alias=sshvcu
    ${common_cmd}    Set Variable    kubectl exec -it ute-${namespace}-upue-0 -c ctr-${namespace}-nwmgmt -n ${namespace}
    ${cmd}    Set Variable    ${common_cmd} -- ip addr show f1u |grep -Po '\\d+.\\d+.\\d+.\\d+'/24 | tr -d \r\n
    ${ret}    ssh.Execute    command=${cmd}    connection=sshvcu
    ${f1u_ip}    Get Regexp Matches    ${ret}    (\\d+.\\d+.\\d+.\\d+)
    [Return]    ${f1u_ip[0]}

Set Route For Capture Ttitrace Log
    ssh.Connect To    hostname=${VDU_K8S_INFO.ip}    username=${VDU_K8S_INFO.username}
    ...    password=${VDU_K8S_INFO.password}    alias=sshdu
    ${flu_ip}    Get F1uplane IP
    ${common_cmd}    Set Variable    kubectl exec -it ute-${namespace}-up-0 -c ctr-${namespace}-l2rt -n ${namespace}
    ${cmd}    Set Variable    ${common_cmd} -- ip route add 10.0.12.1/32 dev f1uplane via ${flu_ip}
    ${ret}    ssh.Execute    command=${cmd}    connection=sshdu
    ${ret}    ssh.Execute    command=${common_cmd} -- route | grep 10.0.12.1    connection=sshdu
    Should Contain    ${ret}    10.0.12.1
    [Teardown]    SSH.Disconnect    connection=sshdu

Start BIP Log
    [Arguments]    ${bip_type}
    [Documentation]    This keyword is to capture BIP log
    ...
    ...    | Input Parameters | Man. | Description |
    ...    | bip_type | YES |  L1BIPRT / L2BIPRT /L1BIPL1/L2BIPHI |
    ...
    ...    Examples:
    ...    | Start BIP Log | L1BIPRT |  |
    ${container_type}    Set Variable If
    ...    '${bip_type}'=='L1BIPRT' or '${bip_type}'=='L2BIPRT'    l2rt
    ...    '${bip_type}'=='L1BIPL1'    l1hi
    ...    '${bip_type}'=='L2BIPHI'    l2hi
    ${port}    Set Variable If
    ...    '${bip_type}'=='L1BIPRT' or '${bip_type}'=='L1BIPL1' or '${bip_type}'=='L2BIPHI'    0
    ...    '${bip_type}'=='L2BIPRT'    1
    Set Test Variable    ${container_type}
    ${bip_log_name}    Set Variable If
    ...    '${bip_type}'=='L1BIPRT'    l1biprt.pcap
    ...    '${bip_type}'=='L2BIPRT'    l2biprt.pcap
    ...    '${bip_type}'=='L1BIPL1'    l1bipl1.pcap
    ...    '${bip_type}'=='L2BIPHI'    l2biphi.pcap
    Set Test Variable    ${bip_log_name}
    SSH.Connect To    hostname=${VDU_K8S_INFO.ip}    username=${VDU_K8S_INFO.username}
    ...    password=${VDU_K8S_INFO.password}    alias=sshdu
    ${rm_cmd}    Catenate    SEPARATOR=${SPACE}    kubectl exec -it ute-${NAMESPACE}-up-0 -c ctr-${NAMESPACE}-${container_type} -n ${NAMESPACE}
    ...     -- rm -rf /tmp/dpdkdump/${bip_log_name}
    SSH.Send Command     command=${rm_cmd}     connection=sshdu
    ${cmd}    Catenate    SEPARATOR=${SPACE}    kubectl exec -it ute-${NAMESPACE}-up-0 -c ctr-${NAMESPACE}-${container_type} -n ${NAMESPACE}
    ...     -- dpdk-cli pdump port ${port} path /tmp/dpdkdump/
    SSH.Send Command     command=${cmd}     connection=sshdu
    Sleep    1s    msg=wait for start bip log successfull
    [Teardown]    SSH.Disconnect    connection=sshdu

Start Vran40 BIP Log
    [Arguments]    ${bip_type}
    [Documentation]    This keyword is to capture BIP log
    ...
    ...    | Input Parameters | Man. | Description |
    ...    | bip_type | YES |  L1BIPRT / L2BIPRT /L1BIPL1/L2BIPHI |
    ...
    ...    Examples:
    ...    | Start BIP Log | L1BIPRT |  |
    ${container_type}    Set Variable If
    ...    '${bip_type}'=='L1BIPRT' or '${bip_type}'=='L2BIPRT'    l2rt
    ...    '${bip_type}'=='L1BIPL1'    l1hi
    ...    '${bip_type}'=='L2BIPHI'    l2hi
    ${port}    Set Variable If
    ...    '${bip_type}'=='L1BIPRT' or '${bip_type}'=='L1BIPL1' or '${bip_type}'=='L2BIPHI'    0
    ...    '${bip_type}'=='L2BIPRT'    1
    Set Test Variable    ${container_type}
    ${bip_log_name}    Set Variable If
    ...    '${bip_type}'=='L1BIPRT'    l1up.pcap
    ...    '${bip_type}'=='L2BIPRT'    l2biprt.pcap
    ...    '${bip_type}'=='L1BIPL1'    l1bipl1.pcap
    ...    '${bip_type}'=='L2BIPHI'    l2biphi.pcap
    Set Test Variable    ${bip_log_name}
    SSH.Connect To    hostname=${VDU_K8S_INFO.ip}    username=${VDU_K8S_INFO.username}
    ...    password=${VDU_K8S_INFO.password}    alias=sshdu
    ${rm_cmd}    Catenate    SEPARATOR=${SPACE}    oc exec -it ute-${NAMESPACE}-l2rt-0 -c ctr-${NAMESPACE}-${container_type} -n ${NAMESPACE}
    ...     -- rm -rf /tmp/dpdkdump/${bip_log_name}
    SSH.Send Command     command=${rm_cmd}     connection=sshdu
    ${cmd}    Catenate    SEPARATOR=${SPACE}    oc exec -it ute-${NAMESPACE}-l2rt-0 -c ctr-${NAMESPACE}-${container_type} -n ${NAMESPACE}
    ...     -- hal-cli pdump port ${port} path /tmp/dpdkdump/
    SSH.Send Command     command=${cmd}     connection=sshdu
    Sleep    1s    msg=wait for start bip log successfull
    [Teardown]    SSH.Disconnect    connection=sshdu

Stop Vran40 BIP Log
    [Arguments]    ${bip_type}    ${save_log}=${TEST_LOG_DIRECTORY}
    SSH.Connect To    hostname=${VDU_K8S_INFO.ip}    username=${VDU_K8S_INFO.username}
    ...    password=${VDU_K8S_INFO.password}    alias=sshdu
    Log To Console    Stop ${bip_type} bip log
    ${cmd}    Catenate    SEPARATOR=${SPACE}    oc exec -it ute-${NAMESPACE}-l2rt-0 -c ctr-${NAMESPACE}-${container_type} -n ${NAMESPACE}
    ...    -- bash -c "ps -eo "pid,comm" | grep dpdk-pdump | xargs -n 1 kill -2"
    SSH.Send Command    command=${cmd}    connection=sshdu
    Sleep    1s    msg=wait for stop bip log successfull
    Log To Console    Copy ${bip_type} bip log to vDU and then copy from vdu to Local VM
    ${cp_cmd}    Catenate    SEPARATOR=    oc cp -c ctr-${NAMESPACE}-${container_type} ${NAMESPACE}/ute-${NAMESPACE}-l2rt-0:
    ...    tmp/dpdkdump/${bip_log_name} /tmp/${bip_log_name}
    SSH.Send Command    command=${cp_cmd}    connection=sshdu    timeout=10s
    ${passed}    Run Keyword And Return Status    Directory Should Not Exist    ${save_log}
    Run Keyword If    ${passed}    Create Directory    ${save_log}
    Wait Until Keyword Succeeds    20s    5s    _copy_bip_log_to_local    ${bip_log_name}    ${save_log}
    [Teardown]    SSH.Disconnect    connection=sshdu

Stop BIP Log
    [Arguments]    ${bip_type}    ${save_log}=${TEST_LOG_DIRECTORY}
    SSH.Connect To    hostname=${VDU_K8S_INFO.ip}    username=${VDU_K8S_INFO.username}
    ...    password=${VDU_K8S_INFO.password}    alias=sshdu
    Log To Console    Stop ${bip_type} bip log
    ${cmd}    Catenate    SEPARATOR=${SPACE}    kubectl exec -it ute-${NAMESPACE}-up-0 -c ctr-${NAMESPACE}-${container_type} -n ${NAMESPACE}
    ...    -- bash -c "ps -eo "pid,comm" | grep dpdk-pdump | xargs -n 1 kill -2"
    SSH.Send Command    command=${cmd}    connection=sshdu
    Sleep    1s    msg=wait for stop bip log successfull
    Log To Console    Copy ${bip_type} bip log to vDU and then copy from vdu to Local VM
    ${cp_cmd}    Catenate    SEPARATOR=    kubectl cp -c ctr-${NAMESPACE}-${container_type} ${NAMESPACE}/ute-${NAMESPACE}-up-0:
    ...    tmp/dpdkdump/${bip_log_name} /tmp/${bip_log_name}
    SSH.Send Command    command=${cp_cmd}    connection=sshdu    timeout=10s
    ${passed}    Run Keyword And Return Status    Directory Should Not Exist    ${save_log}
    Run Keyword If    ${passed}    Create Directory    ${save_log}
    Wait Until Keyword Succeeds    20s    5s    _copy_bip_log_to_local    ${bip_log_name}    ${save_log}
    [Teardown]    SSH.Disconnect    connection=sshdu

_copy_bip_log_to_local
    [Arguments]    ${log_name}    ${save_log}=${TEST_LOG_DIRECTORY}
    ${cmd}    Catenate    SEPARATOR=${SPACE}    sshpass -p ${VDU_K8S_INFO.password} scp ${VDU_K8S_INFO.username}@${VDU_K8S_INFO.ip}:/tmp/${log_name}
    ...     ${save_log}/${log_name}
    ${rc}    ${output}    Run and Return RC and Output    ${cmd}
    Should Be Equal As Integers    ${rc}    0    msg=${output}
