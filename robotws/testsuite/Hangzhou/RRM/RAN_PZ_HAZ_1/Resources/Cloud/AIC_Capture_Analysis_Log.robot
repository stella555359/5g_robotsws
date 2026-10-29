*** Settings ***
Documentation
...    Author: Yang mengli
...    Email address: mengli.yang@nokia-sbell.com
...    Maintainer: Yang mengli;    Liu Renhui
...    Email address: mengli.yang@nokia-sbell.com;    renhui-david.liu@nokia-sbell.com;
...    Common KWs related to collect and analysis log for AIC.
...    All the bugs/new keyword needs/improvement should be raised in Jira and assign to the Maintainer.
...    Jira link: https://jiradc.ext.net.nokia.com/projects/PZ1HAZTA/issues
...    Guideline: https://confluence.ext.net.nokia.com/display/SRANPRODHZHTA/09.+AIC+Common+Resource+Supporting+Mode+Improvement

Library           ../Common/python/emil.py    WITH NAME    emil

*** Variables ***
@{vdu_tti_profile}    L2Ps_Component
${emil_host}   10.0.92.239
${emil_user}   yongkun.zhang
${emil_password}   Btstest@123
${emil_tool_path}  /cygdrive/c/Program Files/Emil
${emil_tool_win_path}  C:\\\\Program Files\\\\Emil
${emil_log_dir}  /cygdrive/c/emil_logs
${emil_log_win_dir}  C:\\\\emil_logs


*** Keywords ***
#---------------------BIP--------------------------------------------------------------------------
Start Bip Log
    [Arguments]    ${gnb_index}=${0}    ${vdu_index}=${0}    ${container_name}=l2rt    ${pod_name}=l2rt
    ...            ${pod_prefix}=po-cran1    ${container_prefix}=ctr-cran1    ${port_name}=l1up    ${timeout}=${10}
    [Documentation]    This kw is used to Start Bip Log
    ...    Author: Yang Mengli, Liu Renhui
    ...    Contact: mengli.yang@nokia-sbell.com, renhui-david.liu@nokia-sbell.com
    ...    | Input Parameters | Man. | Description |
    ...    | gnb_index | yes | The list index from tl.cu[], it will use the index of gnb |
    ...    | vdu_index | yes | The list index from tl.dus[], it will use the index of VDU |
    ...    | container_name | yes | set container name by the parameter  |
    ...    | pod_name | yes | set pod name by the parameter |
    ...    | pod_prefix | no | set pod prefix, such as: po-cran1 |
    ...    | container_prefix | yes | set container prefix, such as: ctr-cran1 |
    ...    | timeout | yes | set timeout time for execute command |
    ...
    ...    | Return Value | Description |
    ...    | None | NA |
    ...
    ...    Example
    ...    | Start Bip Log | gnb_index=${0} | vdu_index=${0} | container_name=l1hi |
    ...    | ...           | pod_name=up | pod_prefix==po-cran1 | container_prefix=ctr-cran1 |
    ...
    Log To Console    ${timeout}
    Log To Console    ${gnb_index}
    Log To Console    ${vdu_index}
    ${vdu_k8s_master_ssh_connection_info}    Get vDU K8s Master SSH Connection Info    gnb_index=${gnb_index}
    ...                                                                         vdu_index=${vdu_index}
    ${ip}    set variable    ${vdu_k8s_master_ssh_connection_info["addr"]}
    ${username}    set variable    ${vdu_k8s_master_ssh_connection_info["username"]}
    ${password}    set variable    ${vdu_k8s_master_ssh_connection_info["password"]}
    ${conn}    basic.master_connect    hostname=${ip}
    ...                           username=${username}
    ...                           password=${password}
    ...                           alias=vdu_master
    Set Test Variable    ${conn}
    ${ns}    Get vDU Namespace From Config File
    Set Test Variable    ${ns}
    ${bip_container}    set variable    ${container_prefix}-${container_name}
    Set Test Variable    ${alias_issh}    vdu_master_issh
    Connect To K8s Master In vDU    gnb_index=${gnb_index}
    ...    vdu_index=${vdu_index}    alias=${alias_issh}
    ${is_dpdkcli_supported}=    Run Keyword And Return Status    Should Contain Any  ${VDU_VERSION}
    ...    vDUCNF23R1  vDUCNF23R2  vDUCNF23R3
    ${log_capture_tool}=    Run Keyword If    ${is_dpdkcli_supported}
    ...     Set Variable     dpdk-cli
    ...     ELSE
    ...     Set Variable     hal-cli
    ${pod_prefix}   k8s.get_pod_name_prefix   connection=vdu_master     namespace=${ns}
    ${bip_pod}    set variable    ${pod_prefix}${ns}-${pod_name}-0
    ${port_cmd}=    Catenate  kubectl exec -it ${bip_pod} -c ${bip_container} -n ${ns}
    ...     -- bash -c "${log_capture_tool} show port table | grep ${port_name}"
    ${bip_port_id_tmp}    issh.Execute    command=${port_cmd}
    ...                                 alias=${alias_issh}
    ${bip_port_id_output}    Get Regexp Matches  ${bip_port_id_tmp}   (\\d).*BIP
    ${bip_port_output}    split_string    ${bip_port_id_output[0]}    ${SPACE}${SPACE}${SPACE}
    ${bip_port_id}    Set Variable    ${bip_port_output}[0]
    ${port_length}    get length   ${bip_port_id}
    ${port_id}=    Get Substring    ${bip_port_id}    ${${port_length}-1}    ${port_length}
    ${bip_cmd}=    Catenate  kubectl exec -it  ${bip_pod} -n ${ns}
    ...     -c ${bip_container} -- bash
    ...     -c '${log_capture_tool} pdump port ${port_id} path /tmp/dpdkdump > /tmp/dpdkdump/start_bip.log 2>&1'
    issh.Execute_bare
    ...     command=${bip_cmd}
    ...     alias=${alias_issh}
    Send ENTER Interactively   alias=${alias_issh}

Stop Bip Log And Download To K8s Master
    [Arguments]    ${gnb_index}=${0}    ${vdu_index}=${0}    ${container_name}=l2rt    ${pod_name}=l2rt
    ...            ${pod_prefix}=po-cran1    ${container_prefix}=ctr-cran1    ${timeout}=${10}
    [Documentation]    This kw is used to Stop Bip Log And Download To K8s Master
    ...    Author: Yang Mengli, Liu Renhui
    ...    Contact: mengli.yang@nokia-sbell.com, renhui-david.liu@nokia-sbell.com
    ...    | Input Parameters | Man. | Description |
    ...    | gnb_index | yes | The list index from tl.cu[], it will use the index of gnb |
    ...    | vdu_index | yes | The list index from tl.dus[], it will use the index of VDU |
    ...    | vcontainer_name | yes | set container name by the parameter  |
    ...    | pod_name | yes |set pod name by the parameter |
    ...    | pod_prefix | no | set pod prefix, such as: po-cran1 |
    ...    | container_prefix | yes |set container prefix, such as: ctr-cran1 |
    ...    | timeout | yes | set timeout time for execute command |
    ...
    ...    | Return Value | Description |
    ...    | None | NA |
    ...
    ...    Example
    ...    | Stop Bip Log And Download To K8s Master | gnb_index=${0} | vdu_index=${0} | container_name=l1hi |
    ...    | ...                                     | pod_name=up | pod_prefix==po-cran1 | container_prefix=ctr-cran1 |
    ...
    Log To Console    ${pod_prefix}
    Log To Console    ${gnb_index}
    Log To Console    ${vdu_index}
    Stop Bip Log    alias=${alias_issh}
    ${remote_log_dir}=     bip.download_bip_log_to_master    pod_name=${pod_name}
    ...                                                  namespace=${ns}
    ...                                                  container_name=${container_name}
    ...                                                  tmp_log_dir=/tmp/bip/
    ...                                                  container_prefix=${container_prefix}
    ...                                                  conn=vdu_master
    ...                                                  timeout=${timeout}
    ${bip_local_dir}=    Join Path    ${TEST_LOG_DIRECTORY}    bip
    ${bip_local_file_path}=    Join Path    ${bip_local_dir}    ${container_name}.pcap
    Set Test Variable    ${bip_local_file_path}
    issh.Download File    remote_path=/tmp/bip/tmp-bip.pcap
    ...    local_path=${bip_local_file_path}    alias=${alias_issh}
    issh.Download File    remote_path=/tmp/bip/start_bip.log
    ...    local_path=${bip_local_dir}/start_bip.log    alias=${alias_issh}
    [Return]    ${bip_local_file_path}
    [Teardown]    RUN KEYWORDS    run keyword and ignore error    basic.master_close    alias=vdu_master    AND
    ...                           run keyword and ignore error    issh.disconnect    alias=${alias_issh}

Stop Bip Log
    [Arguments]  ${alias}=default
    [Documentation]    This kw is used to stop bip log.
    ...    Contact: renhui-david.liu@nokia-sbell.com
    ...    | Input Parameters | Man. | Description |
    ...    | alias | yes |  |
    ...
    ...    | Return Value | Description |
    ...    | None | NA |
    ...
    ...    Example
    ...    | Stop Bip Log | alias=default |
    ...
    ${output}   Send CTRL_C Interactively     ${alias}
    [Return]  ${output}

Send ENTER Interactively
    [Arguments]  ${alias}=default
    [Documentation]    This kw is used to send ENTER key within current active ssh connection.
    ...    It should be used via issh library.
    ...    Contact: renhui-david.liu@nokia-sbell.com
    ...
    ...    | Input Parameters | Man. | Description |
    ...    | alias | yes | alias name |
    ...
    ...    Example
    ...    | Send ENTER Interactively | alias=default |
    ${enter}    Evaluate    chr(int(13))
    ${output}   issh.Execute_Bare   command=${enter}     alias=${alias}
    Sleep    1.3s
    [Return]  ${output}

Send CTRL_C Interactively
    [Arguments]  ${alias}=default
    [Documentation]    This kw is used to send CTRL+C to interrupt current running command
    ...    within current active ssh connection. It should be used via issh library.
    ...    Contact: renhui-david.liu@nokia-sbell.com
    ...    | Input Parameters | Man. | Description |
    ...    | alias | yes |  |
    ...
    ...    | Return Value | Description |
    ...    | None | NA |
    ...
    ...    Example
    ...    | Send CTRL_C Interactively | alias=default |
    ...
    ${crtl_c}    Evaluate    chr(int(3))
    ${output}   issh.Execute_Bare   command=${crtl_c}     alias=${alias}
    Sleep    3s
    [Return]  ${output}

Prepare MCShark Files
    [Arguments]
    [Documentation]    This kw is used to Prepare MCShark Files for decode bip log
    ...    Author: Yang Mengli
    ...    Contact: mengli.yang@nokia-sbell.com
    ...    | Input Parameters | Man. | Description |
    ...    | None | NA |
    ...
    ...    | Return Value | Description |
    ...    | None | NA |
    ...
    ...    Example
    ...    | Prepare MCShark Files |
    ...
    ${split_vdu_version}=    split_string    ${VDU_VERSION}    _
    ${vdu_version_pro}    split_string    ${split_vdu_version}[1]    .
    ${vdu_version}=   Run Keyword If    '${vdu_version_pro[0]}'=='0'
    ...               set variable    vDUCNF00_${split_vdu_version}[1]
    ...       ELSE    set variable    ${VDU_VERSION}
    ${cmd}=    Catenate    wget -r -np -nH ${MCSHARK_TOOL_LINK}/${vdu_version}/ -P /home/ute/
    ${mcshark_path}=    Catenate   /home/ute/artifactory/wslte5g_plugins-local/MCShark/${vdu_version}/mcshark-*buster.so

    OperatingSystem.Run    command=cd /home/ute/
    OperatingSystem.Run    command=${cmd}
    ${output}    OperatingSystem.Run    command=tshark -v |grep TShark
    ${lst}    Get Regexp Matches    ${output}    v(\\d{1,3}\.\\d{1,3})\.\\d{1,3}   1
    ${tshark_version}=    set variable    @{lst}[0]
    ${path}=    set variable    /usr/lib/x86_64-linux-gnu/wireshark/plugins/${tshark_version}/epan
    ${is_exist}=    Run Keyword And Return Status    Directory Should Exist    ${path}
    Run Keyword If    not ${is_exist}
    ...         OperatingSystem.Run    command=sudo mkdir -p ${path}
    OperatingSystem.Run    command=sudo rm -rf ${path}/mcshark-*buster.so
    OperatingSystem.Run    command=sudo cp ${mcshark_path} ${path}

Convert BIP To CSV By MCShark
    [Arguments]    ${local_file_path}    ${output_file}    ${filter}     ${csv_title}    ${branch}=22R3
    [Documentation]    This kw is used to Convert BIP To CSV By MCShark
    ...    Author: Yang Mengli
    ...    Contact: mengli.yang@nokia-sbell.com
    ...    | Input Parameters | Man. | Description |
    ...    | bip_file | yes | bip file name which is colleted |
    ...    | output_file | yes | the path of csv file is stored |
    ...    | filter | yes | What is used to filter messages |
    ...    | csv_title_list | yes | csv file list |
    ...
    ...    | Return Value | Description |
    ...    | None | NA |
    ...
    ...    Example
    ...    | Convert BIP To CSV By MCShark | ${TEST_LOG_DIRECTORY}/csv_${name}.csv | ${filter} | ${csv_title_list} |
    ...
    Log To Console    ${branch}
    Log To Console    ${gnb_index}
    Log To Console    ${vdu_index}
    Log To Console    ${gnb_index}
    Log To Console    ${gnb_index}
    Log To Console    ${container_name}
    Log To Console    ${protocol}
    Log To Console    ${gnb_index}
    Log To Console    ${vdu_index}
    Log To Console    ${log_name}
    Prepare MCShark Files
    ${cmd}=    Catenate    tshark -r ${local_file_path} -Y '${filter}' -T fields -e _ws.col.No. ${csv_title}
    ...     -E header=y -E separator=, -E quote=d -E occurrence=a > ${output_file}
    OperatingSystem.Run    ${cmd}

Check Bip Log
    [Arguments]    ${file_path}=${TEST_LOG_DIRECTORY}/bip/csv_${name}.csv
    ...            ${value_column_list}=3gpp.slot    ${expected_list}=1
    [Documentation]    This kw is used to check bip log by get value from multiple column
    ...    Author: Yang Mengli
    ...    Contact: mengli.yang@nokia-sbell.com
    ...    | Input Parameters | Man. | Description |
    ...    | file_path | yes | bip file path which is colleted |
    ...    | value_column_list | yes | it define expected value column list |
    ...    | expected_list | yes | it define expected value list |
    ...
    ...    | Return Value | Description |
    ...    | ${result_line}   ${result_value} | it will return result line and result value|
    ...
    ...    Example
    ...    | Convert BIP To CSV By MCShark | ${TEST_LOG_DIRECTORY}/csv_${name}.csv | ${filter} | ${csv_title_list} |
    ...
    ${result_line}   ${result_value} =    bip.get_value_with_multiple_column_filter    file_path=${file_path}
    ...                                          value_column_list=${value_column_list}
    ...                                          expected_list=${expected_list}
    [Return]    ${result_line}   ${result_value}
#---------------------wireshark--------------------------------------------------------------------------

Start Wireshark Log
    [Arguments]    ${gnb_index}=${0}    ${vdu_index}=${0}    ${namespace}=cran1    ${container_name}=cprt
    ...            ${pod_name}=cprt    ${timeout}=${10}    ${protocol}=sctp    ${interface}=any
    [Documentation]    This kw is used to Start wireshark Log in VDU
    ...    Author: Yang Mengli
    ...    Contact: mengli.yang@nokia-sbell.com
    ...    | Input Parameters | Man. | Description |
    ...    | gnb_index | yes | The list index from tl.cu[], it will use the index of gnb |
    ...    | vdu_index | yes | The list index from tl.dus[], it will use the index of VDU |
    ...    | vcontainer_name | yes | set container name by the parameter  |
    ...    | pod_name | yes | set pod name by the parameter |
    ...    | timeout | yes | set timeout time for execute command |
    ...    | protocol | yes | set correct protocol for message |
    ...    | interface | yes | set interface you need to collect log |
    ...
    ...    | Return Value | Description |
    ...    | None | NA |
    ...
    ...    Example
    ...    | Start Wireshark Log | gnb_index=${0} | vdu_index=${0} | namespace=cran1 | container_name=cprt |
    ...    | ...                 | pod_name=cprt | timeout=${10} | protocol=sctp | interface=any |
    ...
    ${vdu_k8s_master_ssh_connection_info}    Get vDU K8s Master SSH Connection Info    gnb_index=${gnb_index}
    ...                                                                         vdu_index=${vdu_index}
    ${ip}    set variable    ${vdu_k8s_master_ssh_connection_info["addr"]}
    ${username}    set variable    ${vdu_k8s_master_ssh_connection_info["username"]}
    ${password}    set variable    ${vdu_k8s_master_ssh_connection_info["password"]}
    ${conn}=    basic.master_connect    hostname=${ip}
    ...                           username=${username}
    ...                           password=${password}
    Set Test Variable    ${conn}
    wireshark.start_wireshark_log    pod_name=${pod_name}
    ...                      namespace=${namespace}
    ...                      container_name=${container_name}
    ...                      conn=${conn}
    ...                      timeout=${timeout}
    ...                      protocol=${protocol}
    ...                      interface=${interface}

Start Wireshark Log In vDU
    [Arguments]    ${gnb_index}=${0}    ${vdu_index}=${0}    ${container_name}=nwmgmt    ${pod_name}=cprt
    ...            ${timeout}=${10}    ${protocol}=sctp    ${interface}=any    ${hostname}=${VDU_HOSTNAME}
    ...            ${username}=${VDU_USERNAME}    ${password}=${VDU_PASSWORD}    ${namespace}=${VDU_NAMESPACE}
    ...            ${alias}=vdu_master
    [Documentation]    This kw is used to Start wireshark Log in VDU
    ...    Author: Yang Mengli
    ...    Contact: mengli.yang@nokia-sbell.com
    ...    | Input Parameters | Man. | Description |
    ...    | gnb_index | yes | The list index from tl.cu[], it will use the index of gnb |
    ...    | vdu_index | yes | The list index from tl.dus[], it will use the index of VDU |
    ...    | vcontainer_name | yes | set container name by the parameter  |
    ...    | pod_name | yes | set pod name by the parameter |
    ...    | timeout | yes | set timeout time for execute command |
    ...    | protocol | yes | set correct protocol for message |
    ...    | interface | yes | set interface you need to collect log |
    ...
    ...    | Return Value | Description |
    ...    | None | NA |
    ...
    ...    Example
    ...    | Start Wireshark Log In vDU | gnb_index=${0} | vdu_index=${0} | namespace=cran1 | container_name=cprt |
    ...    | ...                        | pod_name=cprt | timeout=${10} | protocol=sctp | interface=any |
    ...
    Log To Console    ${gnb_index}
    Log To Console    ${vdu_index}
#    ${ns}    Get vDU Namespace From Config File
#    Set Test Variable    ${ns}
    ${conn}=    basic.master_connect    hostname=${hostname}
    ...                           username=${username}
    ...                           password=${password}
    ...                           alias=${alias}
    Set Test Variable    ${conn}
    wireshark.start_wireshark_log    pod_name=${pod_name}
    ...                      namespace=${namespace}
    ...                      container_name=${container_name}
    ...                      conn=${alias}
    ...                      timeout=${timeout}
    ...                      protocol=${protocol}
    ...                      interface=${interface}


Start Wireshark Log In vCU
    [Arguments]    ${gnb_index}=${0}    ${container_name}=nwmgmt    ${pod_name}=cpif
    ...            ${timeout}=${10}    ${protocol}=sctp    ${interface}=any    ${alias}=vcu_master
    ...            ${hostname}=${VCU_HOSTNAME}    ${username}=${VCU_USERNAME}    ${password}=${VCU_PASSWORD}
    ...            ${namespace}=${VCU_NAMESPACE}
    [Documentation]    This kw is used to Start wireshark Log in VDU
    ...    Author: Yang Mengli
    ...    Contact: mengli.yang@nokia-sbell.com
    ...    | Input Parameters | Man. | Description |
    ...    | gnb_index | no | The list index from tl.cu[], it will use the index of gnb |
    ...    | vdu_index | no | The list index from tl.dus[], it will use the index of VDU |
    ...    | vcontainer_name | no | set container name by the parameter  |
    ...    | pod_name | no | set pod name by the parameter |
    ...    | timeout | no | set timeout time for execute command |
    ...    | protocol | yes | set correct protocol for message |
    ...    | interface | yes | set interface you need to collect log |
    ...
    ...    | Return Value | Description |
    ...    | None | NA |
    ...
    ...    Example
    ...    | Start Wireshark Log In vCU |  gnb_index=${0} | vdu_index=${0} | namespace=cran1 | container_name=cpif |
    ...    | ...                        | pod_name=cpif | timeout=${10} | protocol=sctp | interface=any |
    ...
    Log To Console    ${gnb_index}
    ${conn}=    basic.master_connect    hostname=${hostname}
    ...                           username=${username}
    ...                           password=${password}
    ...                           alias=${alias}
    Set Test Variable    ${conn}
    wireshark.start_wireshark_log    pod_name=${pod_name}
    ...                      namespace=${namespace}
    ...                      container_name=${container_name}
    ...                      conn=${alias}
    ...                      timeout=${timeout}
    ...                      protocol=${protocol}
    ...                      interface=${interface}

Start Wireshark Log With Non Root In vCU
    [Arguments]    ${gnb_index}=${0}    ${container_name}=cpif    ${pod_name}=cpif
    ...            ${timeout}=${10}    ${protocol}=sctp    ${interface}=any    ${alias}=vcu_master
    ...            ${hostname}=${VCU_HOSTNAME}    ${username}=${VCU_USERNAME}    ${password}=${VCU_PASSWORD}
    ...            ${namespace}=${VCU_NAMESPACE}
    [Documentation]    This kw is used to Start wireshark Log in VDU
    ...    Author: Yang Mengli
    ...    Contact: mengli.yang@nokia-sbell.com
    ...    | Input Parameters | Man. | Description |
    ...    | gnb_index | no | The list index from tl.cu[], it will use the index of gnb |
    ...    | vdu_index | no | The list index from tl.dus[], it will use the index of VDU |
    ...    | vcontainer_name | no | set container name by the parameter  |
    ...    | pod_name | no | set pod name by the parameter |
    ...    | timeout | no | set timeout time for execute command |
    ...    | protocol | yes | set correct protocol for message |
    ...    | interface | yes | set interface you need to collect log |
    ...
    ...    | Return Value | Description |
    ...    | None | NA |
    ...
    ...    Example
    ...    | Start Wireshark Log In vCU |  gnb_index=${0} | vdu_index=${0} | namespace=cran1 | container_name=cpif |
    ...    | ...                        | pod_name=cpif | timeout=${10} | protocol=sctp | interface=any |
    ...
    Log To Console    ${gnb_index}
    Log To Console    ${container_name}
    Log To Console    ${protocol}
    ${conn}=    basic.master_connect    hostname=${hostname}
    ...                           username=${username}
    ...                           password=${password}
    ...                           alias=${alias}
    Set Test Variable    ${conn}
    wireshark.start_wireshark_log_for_vcu    namespace=${namespace}
    ...                      pod_name=${pod_name}
    ...                      conn=${alias}
    ...                      ip=${hostname}
    ...                      cranuser_password=${password}
    ...                      timeout=${timeout}
    ...                      interface=${interface}

Start Wireshak Log For eNB
    ${ip}=         Set Variable  ${tl.test_pcs[0].default_ssh_connection_details.addr}
    ${username}    Set Variable  ${tl.test_pcs[0].default_ssh_connection_details.username}
    ${password}    Set Variable  ${tl.test_pcs[0].default_ssh_connection_details.password}
    ${conn}    basic.master_connect    hostname=${ip}
    ...                           username=${username}
    ...                           password=${password}
    Set Test Variable    ${conn}
    wireshark.start_enb_wireshark_log   conn=${conn}

Stop Wireshak Log For eNB
    ${ip}=         Set Variable  ${tl.test_pcs[0].default_ssh_connection_details.addr}
    ${username}    Set Variable  ${tl.test_pcs[0].default_ssh_connection_details.username}
    ${password}    Set Variable  ${tl.test_pcs[0].default_ssh_connection_details.password}
    ${conn}    basic.master_connect    hostname=${ip}
    ...                           username=${username}
    ...                           password=${password}
    Set Test Variable    ${conn}
    wireshark.stop_enb_wireshark_log   conn=${conn}

Stop And Download Wireshak Log For eNB
    [Arguments]    ${wireshark_name}=s1x2
    Stop Wireshak Log For eNB
    ${remote_log_dir}=    set variable  /ffs/fs1/config/toor4nsn/s1x2.pcap
    ${local_dir}=    Join Path    ${TEST_LOG_DIRECTORY}    enb_wireshark
    ${local_file_path}=    basic.create_a_file    ${TEST_LOG_DIRECTORY}/enb-Wireshark
    ...                                           ${wireshark_name}.pcap
    Set Test Variable    ${local_file_path}
    tafssh.Download File    remote_path=${remote_log_dir}    local_path=${local_file_path}    connection=${conn}
    [Return]    ${local_file_path}

Stop Wireshark Log And Download To K8s Master In vDU
    [Arguments]    ${gnb_index}=${0}    ${vdu_index}=${0}    ${container_name}=nwmgmt
    ...            ${pod_name}=cprt    ${timeout}=${10}    ${log_name}=wireshark
    ...            ${hostname}=${VDU_HOSTNAME}    ${username}=${VDU_USERNAME}
    ...            ${password}=${VDU_PASSWORD}    ${namespace}=${VDU_NAMESPACE}
    ...            ${alias}=vdu_master    ${copy_way}=cat
    [Documentation]    This kw is used to Stop Wireshark Log And Download To K8s Master In vDU
    ...    Author: Yang Mengli
    ...    Contact: mengli.yang@nokia-sbell.com
    ...    | Input Parameters | Man. | Description |
    ...    | gnb_index | yes | The list index from tl.cu[], it will use the index of gnb |
    ...    | vdu_index | yes | The list index from tl.dus[], it will use the index of VDU |
    ...    | vcontainer_name | yes | set container name by the parameter  |
    ...    | pod_name | yes | set pod name by the parameter |
    ...    | timeout | yes | set timeout time for execute command |
    ...
    ...    | Return Value | Description |
    ...    | None | NA |
    ...
    ...    Example
    ...    | Stop Wireshark Log And Download To K8s Master In vDU | gnb_index=${0} | vdu_index=${0} |
    ...    | ...                                                  | container_name=cprt | pod_name=cprt |
    ...
    Log To Console    ${gnb_index}
    Log To Console    ${vdu_index}
    Log To Console    ${log_name}
    ${conn}=    basic.master_connect    hostname=${hostname}
    ...                           username=${username}
    ...                           password=${password}
    ...                           alias=${alias}
    Set Test Variable    ${conn}
    wireshark.stop_wireshark    pod_name=${pod_name}    namespace=${namespace}
    ...                             container_name=${container_name}    conn=${alias}    timeout=${timeout}
    ${remote_log_dir}=     wireshark.download_wireshark_log_to_master    pod_name=${pod_name}
    ...                                                                  namespace=${namespace}
    ...                                                                  container_name=${container_name}
    ...                                                                  tmp_log_dir=/tmp/
    ...                                                                  copy_way=${copy_way}
    ...                                                                  conn=${alias}
    ...                                                                  timeout=${timeout}
    ${timestamp}=    DateTime.Get Current Date    result_format=%Y%m%d%H%M%S
    ${local_file_path}=    basic.create_a_file    ${TEST_LOG_DIRECTORY}/vDU-Wireshark
    ...                                           ${hostname}_${namespace}_${timestamp}.pcap
    Set Test Variable    ${local_file_path}
    tafssh.Download File    remote_path=${remote_log_dir}    local_path=${local_file_path}    connection=${alias}
    [Return]    ${local_file_path}
    [Teardown]    RUN KEYWORDS    run keyword and ignore error    basic.master_close    alias=${alias}    AND
    ...                           run keyword and ignore error    issh.disconnect    alias=${alias}


Stop Wireshark Log From vDU
    [Arguments]    ${gnb_index}=${0}    ${vdu_index}=${0}    ${container_name}=cprt
    ...            ${pod_name}=cprt    ${timeout}=${10}    ${log_name}=wireshark
    [Documentation]    This kw is used to Stop Wireshark Log And Download To K8s Master In vDU
    ...    Author: Yang Mengli
    ...    Contact: mengli.yang@nokia-sbell.com
    ...    | Input Parameters | Man. | Description |
    ...    | gnb_index | yes | The list index from tl.cu[], it will use the index of gnb |
    ...    | vdu_index | yes | The list index from tl.dus[], it will use the index of VDU |
    ...    | vcontainer_name | yes | set container name by the parameter  |
    ...    | pod_name | yes | set pod name by the parameter |
    ...    | timeout | yes | set timeout time for execute command |
    ...
    ...    | Return Value | Description |
    ...    | None | NA |
    ...
    ...    Example
    ...    | Stop Wireshark Log From vDU | gnb_index=${0} | vdu_index=${0} |
    ...    | ...                       | container_name=cprt | pod_name=cprt |
    ...
    Log To Console    ${gnb_index}
    Log To Console    ${vdu_index}
    Log To Console    ${log_name}
    Log To Console    ${gnb_index}
    Log To Console    ${gnb_index}
    Log To Console    ${log_name}
    ${conn}=    basic.master_connect    hostname=${VDU_HOSTNAME}
    ...                           username=${VDU_USERNAME}
    ...                           password=${VDU_PASSWORD}
    ...                           alias=vdu_master
    wireshark.stop_wireshark_log    pod_name=${pod_name}    namespace=${VDU_NAMESPACE}
    ...                             container_name=${container_name}    conn=vdu_master    timeout=${timeout}
    [Teardown]    run keyword and ignore error    basic.master_close    alias=vdu_master

Stop Wireshark Log With Non Root And Download To K8s Master In vCU
    [Arguments]    ${gnb_index}=${0}    ${container_name}=cpif    ${alias}=vcu_master
    ...            ${pod_name}=cpif    ${timeout}=${10}    ${log_name}=wireshark    ${alias}=vcu_master
    ...            ${hostname}=${VCU_HOSTNAME}    ${username}=${VCU_USERNAME}    ${password}=${VCU_PASSWORD}
    ...            ${namespace}=${VCU_NAMESPACE}
    [Documentation]    This kw is used to Stop Wireshark Log And Download To K8s Master In vCU
    ...    Author: Yang Mengli
    ...    Contact: mengli.yang@nokia-sbell.com
    ...    | Input Parameters | Man. | Description |
    ...    | gnb_index | yes | The list index from tl.cu[], it will use the index of gnb |
    ...    | vdu_index | yes | The list index from tl.dus[], it will use the index of VDU |
    ...    | vcontainer_name | yes | set container name by the parameter  |
    ...    | pod_name | yes | set pod name by the parameter |
    ...    | timeout | yes | set timeout time for execute command |
    ...
    ...    | Return Value | Description |
    ...    | None | NA |
    ...
    ...    Example
    ...    | Stop Wireshark Log And Download To K8s Master In vCU | gnb_index=${0} | vdu_index=${0} |
    ...    | ...                                                  | container_name=cprt | pod_name=cprt |
    ...
    Log To Console    ${gnb_index}
    ${conn}=    basic.master_connect    hostname=${hostname}
    ...                           username=${username}
    ...                           password=${password}
    ...                           alias=${alias}
    Set Test Variable    ${conn}
    wireshark.stop_wireshark_forced    conn=${alias}    timeout=${timeout}
    ${remote_log_dir}=     wireshark.download_wireshark_log_to_master    pod_name=${pod_name}
    ...                                                                  namespace=${namespace}
    ...                                                                  container_name=${container_name}
    ...                                                                  tmp_log_dir=/tmp/
    ...                                                                  conn=${alias}
    ...                                                                  timeout=${timeout}
    ${local_file_path}=    basic.create_a_file    ${TEST_LOG_DIRECTORY}/Wireshark    ${container_name}_${log_name}.pcap
    Set Test Variable    ${local_file_path}
    tafssh.Download File    remote_path=${remote_log_dir}    local_path=${local_file_path}    connection=${alias}
    [Return]    ${local_file_path}
    [Teardown]    RUN KEYWORDS    run keyword and ignore error    basic.master_close    alias=${alias}    AND
    ...                           run keyword and ignore error    issh.disconnect    alias=cu_master

Stop Wireshark Log And Download To K8s Master In vCU
    [Arguments]    ${gnb_index}=${0}    ${container_name}=nwmgmt    ${alias}=vcu_master
    ...            ${pod_name}=cpif    ${timeout}=${10}    ${log_name}=wireshark
    ...            ${hostname}=${VCU_HOSTNAME}    ${username}=${VCU_USERNAME}
    ...            ${password}=${VCU_PASSWORD}    ${namespace}=${VCU_NAMESPACE}
    ...            ${copy_way}=cat
    [Documentation]    This kw is used to Stop Wireshark Log And Download To K8s Master In vCU
    ...    Author: Liu Renhui
    ...    Contact: renhui-david.liu@nokia-sbell.com
    ...    | Input Parameters | Man. | Description |
    ...    | gnb_index | yes | The list index from tl.cu[], it will use the index of gnb |
    ...    | vdu_index | yes | The list index from tl.dus[], it will use the index of VDU |
    ...    | vcontainer_name | yes | set container name by the parameter  |
    ...    | pod_name | yes | set pod name by the parameter |
    ...    | copy_way | no | available options: cat or gzip |
    ...
    ...    | Return Value | Description |
    ...    | None | NA |
    ...
    ...    Example
    ...    | Stop Wireshark Log And Download To K8s Master In vCU | gnb_index=${0} | vdu_index=${0} |
    ...    | ...                                                  | container_name=nwmgmt | pod_name=cprt |
    ...
    Log To Console    ${gnb_index}
    Log To Console    ${log_name}
    ${conn}=    basic.master_connect    hostname=${hostname}
    ...                           username=${username}
    ...                           password=${password}
    ...                           alias=${alias}
    Set Test Variable    ${conn}
    wireshark.stop_wireshark    pod_name=${pod_name}    namespace=${namespace}
    ...                             container_name=${container_name}    conn=${alias}    timeout=${timeout}
    ${remote_log_dir}=     wireshark.download_wireshark_log_to_master    pod_name=${pod_name}
    ...                                                                  namespace=${namespace}
    ...                                                                  container_name=${container_name}
    ...                                                                  tmp_log_dir=/tmp/
    ...                                                                  copy_way=${copy_way}
    ...                                                                  conn=${alias}
    ...                                                                  timeout=${timeout}
    ${timestamp}=    DateTime.Get Current Date    result_format=%Y%m%d%H%M%S
    ${local_file_path}=    basic.create_a_file    ${TEST_LOG_DIRECTORY}/Wireshark
    ...                                           ${hostname}_${namespace}_${timestamp}.pcap
    Set Test Variable    ${local_file_path}
    tafssh.Download File    remote_path=${remote_log_dir}    local_path=${local_file_path}    connection=${alias}
    [Return]    ${local_file_path}
    [Teardown]    RUN KEYWORDS    run keyword and ignore error    basic.master_close    alias=${alias}    AND
    ...                           run keyword and ignore error    issh.disconnect    alias=cu_master

Stop Wireshark In vCU
    [Arguments]    ${gnb_index}=${0}    ${container_name}=nwmgmt    ${alias}=vcu_master
    ...            ${pod_name}=cpif    ${timeout}=${10}    ${log_name}=wireshark    ${alias}=vcu_master
    ...            ${hostname}=${VCU_HOSTNAME}    ${username}=${VCU_USERNAME}    ${password}=${VCU_PASSWORD}
    ...            ${namespace}=${VCU_NAMESPACE}
    [Documentation]    This kw is used to Stop Wireshark Log And Download To K8s Master In vCU
    ...    Author: Liu Renhui
    ...    Contact: renhui-david.liu@nokia-sbell.com
    ...    | Input Parameters | Man. | Description |
    ...    | gnb_index | yes | The list index from tl.cu[], it will use the index of gnb |
    ...    | vdu_index | yes | The list index from tl.dus[], it will use the index of VDU |
    ...    | vcontainer_name | yes | set container name by the parameter  |
    ...    | pod_name | yes | set pod name by the parameter |
    ...    | timeout | yes | set timeout time for execute command |
    ...
    ...    | Return Value | Description |
    ...    | None | NA |
    ...
    ...    Example
    ...
    Log To Console    ${gnb_index}
    Log To Console    ${log_name}
    Log To Console    ${gnb_index}
    Log To Console    ${container_name}
    ${conn}=    basic.master_connect    hostname=${hostname}
    ...                           username=${username}
    ...                           password=${password}
    ...                           alias=${alias}
    Set Test Variable    ${conn}
    wireshark.stop_wireshark    pod_name=${pod_name}    namespace=${namespace}
    ...                             container_name=${container_name}    conn=${alias}    timeout=${timeout}
    [Teardown]    run keyword and ignore error    basic.master_close    alias=${alias}

Stop Wireshark With Non Root Log In vCU
    [Arguments]    ${gnb_index}=${0}    ${container_name}=cpif    ${alias}=vcu_master
    ...            ${pod_name}=cpif    ${timeout}=${10}    ${log_name}=wireshark    ${alias}=vcu_master
    ...            ${hostname}=${VCU_HOSTNAME}    ${username}=${VCU_USERNAME}    ${password}=${VCU_PASSWORD}
    ...            ${namespace}=${VCU_NAMESPACE}
    [Documentation]    This kw is used to Stop Wireshark Log And Download To K8s Master In vCU
    ...    Author: Yang Mengli
    ...    Contact: mengli.yang@nokia-sbell.com
    ...    | Input Parameters | Man. | Description |
    ...    | gnb_index | yes | The list index from tl.cu[], it will use the index of gnb |
    ...    | vdu_index | yes | The list index from tl.dus[], it will use the index of VDU |
    ...    | vcontainer_name | yes | set container name by the parameter  |
    ...    | pod_name | yes | set pod name by the parameter |
    ...    | timeout | yes | set timeout time for execute command |
    ...
    ...    | Return Value | Description |
    ...    | None | NA |
    ...
    ...    Example
    ...    | Stop Wireshark Log And Download To K8s Master In vCU | gnb_index=${0} | vdu_index=${0} |
    ...    | ...                                                  | container_name=cprt | pod_name=cprt |
    ...
    Log To Console    ${pod_name}
    Log To Console    ${log_name}
    Log To Console    ${namespace}
    Log To Console    ${gnb_index}
    Log To Console    ${container_name}
    ${conn}=    basic.master_connect    hostname=${hostname}
    ...                           username=${username}
    ...                           password=${password}
    ...                           alias=${alias}
    Set Test Variable    ${conn}
    wireshark.stop_wireshark_forced    conn=${alias}    timeout=${timeout}
    [Teardown]    run keyword and ignore error    basic.master_close    alias=${alias}

Stop Wireshark Log From vCU
    [Arguments]    ${gnb_index}=${0}    ${container_name}=cpif    ${alias}=vcu_master
    ...            ${pod_name}=cpif    ${timeout}=${10}    ${log_name}=wireshark    ${alias}=vcu_master
    ...            ${hostname}=${VCU_HOSTNAME}    ${username}=${VCU_USERNAME}    ${password}=${VCU_PASSWORD}
    ...            ${namespace}=${VCU_NAMESPACE}
    [Documentation]    This kw is used to Stop Wireshark Log And Download To K8s Master In vCU
    ...    Author: Yang Mengli
    ...    Contact: mengli.yang@nokia-sbell.com
    ...    | Input Parameters | Man. | Description |
    ...    | gnb_index | yes | The list index from tl.cu[], it will use the index of gnb |
    ...    | vdu_index | yes | The list index from tl.dus[], it will use the index of VDU |
    ...    | vcontainer_name | yes | set container name by the parameter  |
    ...    | pod_name | yes | set pod name by the parameter |
    ...    | timeout | yes | set timeout time for execute command |
    ...
    ...    | Return Value | Description |
    ...    | None | NA |
    ...
    ...    Example
    ...    | Stop Wireshark Log From vCU | gnb_index=${0} | vdu_index=${0} |
    ...    | ...                                                  | container_name=cprt | pod_name=cprt |
    ...
    Log To Console    ${gnb_index}
    Log To Console    ${log_name}
    ${conn}=    basic.master_connect    hostname=${hostname}
    ...                           username=${username}
    ...                           password=${password}
    ...                           alias=${alias}
    Set Test Variable    ${conn}
    wireshark.stop_wireshark_log    pod_name=${pod_name}    namespace=${namespace}
    ...                             container_name=${container_name}    conn=${alias}    timeout=${timeout}
    [Teardown]    run keyword and ignore error    basic.master_close    alias=${alias}

Analysis Wireshark Log
    [Arguments]    ${input_file}=${capture_file_path}    ${filter_expression}=esp.sequence == 115
    ...    ${append_cmd}=${None}
    # -T pdml
    [Documentation]    This kw is used to Parse Pcap by expression
    ...    Author: Yang Mengli
    ...    Contact: mengli.yang@nokia-sbell.com
    ...    | Input Parameters | Man. | Description |
    ...    | input_file | yes | wireshark is saved path |
    ...    | filter_expression | yes | What is used to filter messages  |
    ...
    ...    | Return Value | Description |
    ...    | None | NA |
    ...
    ...    Example
    ...    | Parse Pcap by expression | input_file=${capture_file_path} | filter_expression=esp.sequence == 115 |
    ...
    ${append_cmd}    Run Keyword If    '${append_cmd}'!='${None}'   Set Variable    ${append_cmd}
    ...    ELSE    Set Variable    ${EMPTY}
    ${filtered_packets}    Run    tshark -r ${input_file} -Y "${filter_expression}" ${append_cmd}
    ${rehexp}    Set Variable
    ...    ((2((5[0-5])|([0-4]\\d)))|([0-1]?\\d{1,2}))(\\.((2((5[0-5])|([0-4]\\d)))|([0-1]?\\d{1,2}))){3}
    ${match}    Get Regexp Matches    ${filtered_packets}    ${rehexp}
    Should Not Be Empty    ${match}
    [Return]    ${filtered_packets}

#---------------------K8S--------------------------------------------------------------------------
Collect And Download K8s Log
    [Arguments]    ${ip}=${VCU_HOSTNAME}    ${username}=${VCU_USERNAME}   ${password}=${VCU_PASSWORD}
    ...            ${gnb_index}=${0}    ${vdu_index}=${0}    ${namespace}=cran1    ${container_name}=l2rt
    ...            ${pod_name}=l2rt    ${timeout}=${10}    ${duration}=${3m}   ${tmp_log_dir}=/tmp/
    [Documentation]    This kw is used to Collect And Download K8s Log
    ...    Author: Yang Mengli
    ...    Contact: mengli.yang@nokia-sbell.com
    ...    | Input Parameters | Man. | Description |
    ...    | gnb_index | yes | The list index from tl.cu[], it will use the index of gnb |
    ...    | vdu_index | yes | The list index from tl.dus[], it will use the index of VDU |
    ...    | namespace | yes | set namespace |
    ...    | vcontainer_name | yes | set container name by the parameter  |
    ...    | pod_name | yes | set pod name by the parameter |
    ...    | timeout | yes | set timeout time for execute command |
    ...
    ...    | Return Value | Description |
    ...    | ${local_file_path} | return the path of log file  |
    ...
    ...    Example
    ...    | Collect And Download K8s Log | gnb_index=${0} | vdu_index=${0} | namespace=cran1 | container_name=l1hi |
    ...    | ...                          | pod_name=up | timeout=${10} |
    ...
    Log To Console    ${gnb_index}
    Log To Console    ${vdu_index}
    ${conn}    basic.master_connect    hostname=${ip}
    ...                           username=${username}
    ...                           password=${password}
    ...                           alias=master
    Set Test Variable    ${conn}
    ${remote_log_dir}=     k8s.collect_k8s_log    pod_name=${pod_name}
    ...                                                  namespace=${namespace}
    ...                                                  container_name=${container_name}
    ...                                                  tmp_log_dir=${tmp_log_dir}
    ...                                                  conn=master
    ...                                                  timeout=${timeout}
    ...                                                  duration=${duration}
    ${timestamp}=    DateTime.Get Current Date    result_format=%Y%m%d%H%M%S
    ${local_file_path}=    basic.create_a_file    ${TEST_LOG_DIRECTORY}/k8s
    ...                                          ${container_name}_${timestamp}.log
    Set Test Variable    ${local_file_path}
    Set Test Variable    ${remote_log_dir}
    [Return]    ${local_file_path}    ${remote_log_dir}
    [Teardown]    Run keyword and ignore error    basic.master_close    alias=master

Collect And Download K8s Log In vDU
    [Arguments]    ${hostname}=${VDU_HOSTNAME}     ${username}=${VDU_USERNAME}    ${password}=${VDU_PASSWORD}
    ...            ${gnb_index}=${0}    ${vdu_index}=${0}    ${container_name}=l2rt    ${pod_name}=l2rt
    ...          ${timeout}=${10}    ${duration}=60s    ${tmp_log_dir}=/tmp
    [Documentation]    This kw is used to Collect And Download K8s Log In vDU
    ...    Author: Yang Mengli
    ...    Contact: mengli.yang@nokia-sbell.com
    ...    | Input Parameters | Man. | Description |
    ...    | gnb_index | yes | The list index from tl.cu[], it will use the index of gnb |
    ...    | vdu_index | yes | The list index from tl.dus[], it will use the index of VDU |
    ...    | vcontainer_name | yes | set container name by the parameter  |
    ...    | pod_name | yes | set pod name by the parameter |
    ...    | timeout | yes | set timeout time for execute command |
    ...
    ...    | Return Value | Description |
    ...    | ${local_file_path} | return the path of log file  |
    ...
    ...    Example
    ...    | Collect And Download K8s Log In vDU | gnb_index=${0} | vdu_index=${0} | container_name=l1hi |
    ...    | ...                          | pod_name=up | timeout=${10} |
    ...
    ${ns}    Get vDU Namespace From Config File
    Set Test Variable    ${ns}
    ${local_file_path}    ${remote_log_dir}=     Collect And Download K8s Log
    ...                                                  ip=${hostname}
    ...                                                  username=${username}
    ...                                                  password=${password}
    ...                                                  pod_name=${pod_name}
    ...                                                  namespace=${ns}
    ...                                                  container_name=${container_name}
    ...                                                  tmp_log_dir=${tmp_log_dir}
    ...                                                  timeout=${timeout}
    ...                                                  duration=${duration}
    Set Test Variable    ${local_file_path}
    Connect To K8s Master In vDU    gnb_index=${gnb_index}
    ...                                    vdu_index=${vdu_index}
    ...                                    alias=default
    issh.Download File    remote_path=${remote_log_dir}    local_path=${local_file_path}   alias=default
    [Return]    ${local_file_path}
    [Teardown]    Run keyword and ignore error    issh.disconnect    alias=default

Collect And Download K8s Log In vCU
    [Arguments]     ${hostname}=${VCU_HOSTNAME}     ${username}=${VCU_USERNAME}    ${password}=${VCU_PASSWORD}
    ...             ${gnb_index}=${0}    ${vdu_index}=${0}    ${container_name}=cpif    ${pod_name}=cpif
    ...             ${timeout}=${10}    ${duration}=60s    ${tmp_log_dir}=/tmp
    [Documentation]    This kw is used to Collect And Download K8s Log In vCU
    ...    Author: Yang Mengli
    ...    Contact: mengli.yang@nokia-sbell.com
    ...    | Input Parameters | Man. | Description |
    ...    | gnb_index | yes | The list index from tl.cu[], it will use the index of gnb |
    ...    | vdu_index | yes | The list index from tl.dus[], it will use the index of VDU |
    ...    | vcontainer_name | yes | set container name by the parameter  |
    ...    | pod_name | yes | set pod name by the parameter |
    ...    | timeout | yes | set timeout time for execute command |
    ...
    ...    | Return Value | Description |
    ...    | ${local_file_path} | return the path of log file  |
    ...
    ...    Example
    ...    | Collect And Download K8s Log In vCU | gnb_index=${0} | vdu_index=${0} | container_name=l1hi |
    ...    | ...                          | pod_name=up | timeout=${10} |
    ...
    Log To Console    ${vdu_index}
    ${ns}   Get vCU Namespace From Config File    gnb_index=${gnb_index}
    Set Test Variable    ${ns}
    ${local_file_path}    ${remote_log_dir}=     Collect And Download K8s Log
    ...                                                  ip=${hostname}
    ...                                                  username=${username}
    ...                                                  password=${password}
    ...                                                  pod_name=${pod_name}
    ...                                                  namespace=${ns}
    ...                                                  container_name=${container_name}
    ...                                                  tmp_log_dir=${tmp_log_dir}
    ...                                                  timeout=${timeout}
    ...                                                  duration=${duration}
    Set Test Variable    ${local_file_path}
    ${alias}    basic.master_connect    hostname=${hostname}
    ...                           username=${username}
    ...                           password=${password}
    ...                           alias=master
    Set Test Variable    ${alias}
    tafssh.Download File    remote_path=${remote_log_dir}    local_path=${local_file_path}   connection=${alias}
    [Return]    ${local_file_path}
    [Teardown]    Run keyword and ignore error    basic.master_close    alias=${alias}

Check K8s Log
    [Arguments]    ${local_file_path}    ${k8slog_prints}    ${filter}=drx
    [Documentation]    this kw is used to analysis k8s log
    ...    Author: Yang Mengli
    ...    Contact: mengli.yang@nokia-sbell.com
    ...    | Input Parameters | Man. | Description |
    ...    | k8slog_prints | list some message which you need to check |
    ...    | k8slog_name | set bts log name |
    ...    | filter | What is used to filter messages |
    ...
    ...    | Return Value | Description |
    ...    | ${output} | some context you filtered out |
    ...
    ...    Example
    ...    | Check K8s Log | ${local_file_path} | k8slog_prints=${k8slog_prints} | filter=drx |
    ...
    Log    Checking K8S log   console=True
    ${output}    OperatingSystem.Run    command=cat ${local_file_path} | grep -a "${filter}" | grep -av grep
    Should Not Be Empty    ${output}
    FOR    ${print}    IN    @{k8slog_prints}
         should contain    ${output}    ${print}
    END
    [Return]    ${output}

Prepare BTS In DCAP
    [Arguments]    ${dcap_info}
    ...            ${bts_http_connection_info}
    [Documentation]
    ...    This kw is used to connect to DCAP server and assure the BTS integrated in the DCAP.
    ...    Supported BTS products: vdu, vcu, classical. (classcial BTS is not ready now)
    ...
    ...    Author: Liu Renhui
    ...    Contact: renhui-david.liu@nokia-sbell.com
    ...    | Input Parameters    | Man. | Description |
    ...    | dcap_info | yes | a dict, its keys are host, port, username, password, rd_version, secure, alias |
    ...    | bts_http_connection_info | yes |  |
    ...
    ...    Example
    ...   | Prepare BTS In DCAP |
    ...
    log to console    \nPreparing BTS In DCAP
    Connect To DCAP    &{dcap_info}
    Make Sure BTS Integrated In DCAP    ${bts_http_connection_info}

Start To Collect Log By DCAP
    [Arguments]    ${dcap_info}
    ...            ${log_type}
    ...            ${product_type}=vdu
    ...            ${gnb_index}=${0}
    ...            ${cudu_index}=${0}
    ...            &{trace_info}
    [Documentation]
    ...    This kw is for general use. It can capture various Log from different BTS products.
    ...    Supported various logs: tti, emil, troubleshooting scripts, etc.
    ...    Supported BTS products: vdu, vcu, classical. (classcial BTS is not ready now)
    ...
    ...    Author: Liu Renhui
    ...    Contact: renhui-david.liu@nokia-sbell.com
    ...    | Input Parameters    | Man. | Description |
    ...    | dcap_info | yes | a dict, its keys are host, port, username, password, rd_version, secure and alias |
    ...    | product_type | yes | classical/vcu/vdu |
    ...    | gnb_index | yes | BTS index |
    ...    | cudu_index | yes | the index of cu or du |
    ...    | trace_info | yes | other required parameters for the DCAP trace |
    ...
    ...    | Return Value | Description |
    ...    | trace_id | dcap trace ID |
    ...
    ...    Example
    ...   | Start To Collect Log By DCAP |
    ...
    ${bts_http_con_info}=    Get BTS Http Connection Info    product_type=${product_type}
    ...    gnb_index=${gnb_index}    cudu_index=${cudu_index}
    Prepare BTS In DCAP    ${dcap_info}    ${bts_http_con_info}
    log to console    \nStarting trace by DCAP
    ${trace_id}=    Run Keyword If    '${log_type}'=='tssVdu'
    ...     Start Trace In DCAP    ${bts_http_con_info}    bts_Id=${bts_http_con_info.host}    &{trace_info}
    ...     ELSE
    ...     Start Trace In DCAP    ${bts_http_con_info}    &{trace_info}
    [Return]    ${trace_id}

Extract tss log from trace file
    [Arguments]    ${archive}
    ...            ${directory}
    ...            ${ru_index}=${1}
    ...            ${postfix}=${None}
    ...            ${substring}=SCRIPT_RESULT
    [Documentation]   this kw is used to extract troubleshooting scripts log from the DCAP trace file.
    ...    Author: Liu Renhui
    ...    | Input Parameters | Man. | Description |
    ...    | archive | yes | the zip file path |
    ...    | directory | yes | the directory to put the unzipped file|
    ...    | ru_index | yes | the ru index in the log filename |
    ...    | postfix | yes | the postfix of log name |
    ...    | substring | yes | this substring that the log filename contains |
    ...
    ...    | Return Value | Description |
    ...    | log_file_paths | required file paths |
    ...
    ${filters}=    create list
    &{dict1}=    Create Dictionary    substring=snapshot    postfix=.zip
    &{dict2}=    Create Dictionary    substring=RU_${ru_index}    postfix=.zip
    &{dict3}=    Create Dictionary    substring=${substring}    postfix=${postfix}
    Append To List    ${filters}    ${dict1}    ${dict2}    ${dict3}
    ${log_file_paths}=    Extract log from nested zip trace file    ${archive}    ${directory}    ${filters}

    ${filters_2}=    create list
    &{dict_extra}=    Create Dictionary    substring=RU_logs    postfix=.zip
    Append To List    ${filters_2}    ${dict1}    ${dict_extra}    ${dict2}    ${dict3}
    ${length}=    Get Length    ${log_file_paths}
    ${log_file_paths}=    Run Keyword If    '${length}' == '0'
    ...    Extract log from nested zip trace file    ${archive}    ${directory}    ${filters_2}
    ...    ELSE    Set Variable    ${log_file_paths}
    [Return]  ${log_file_paths}

Start TTI Log In vDU
    [Arguments]    ${host}    ${port}=443    ${username}=dcapuser
    ...            ${password}=dcapadmin!    ${rd_version}=dcapv3
    ...            ${secure}=${True}         ${alias}=dcap
    ...            ${gnb_index}=${0}         ${vdu_index}=${0}
    ...            ${vdu_custom_profiles}=${vdu_tti_profile}
    [Documentation]   this kw is used to Start TTI Log In vDU.
    ...     Author: Yang Mengli, Liu Renhui
    ...     Contact: mengli.yang@nokia-sbell.com, renhui-david.liu@nokia-sbell.com
    ...    | Input Parameters    | Man. | Description |
    ...    | host | yes | dcap server ip address  |
    ...    | port | yes | dcap server port  |
    ...    | username | no | user name to log in dcap server  |
    ...    | password | no | password to log in dcap server  |
    ...    | rd_version | no | dcap api version  |
    ...    | secure | no | true for https, false for http |
    ...    | alias | no | the instance alias |
    ...    | gnb_index | yes | The list index from tl.cu[], it will use the index of gnb |
    ...    | vdu_index | yes | The list index from tl.dus[], it will use the index of vDU |
    ...    | vdu_custom_profiles | no | specify what kind of tti logs that dcap captures from vDU |
    ...
    ...    | Return Value | Description |
    ...    | vdu_web_ip | vdu webem ip |
    ...
    ...    Example
    ...   | Start TTI Log In vDU |
    ...
    ${oam_httpaddr}    set variable
    ...    ${tl.gnbs[${gnb_index}].dus[${vdu_index}].oam_http_connection_details.addr}
    ${vdu_web_ip}    set variable if    ':' in '''${oam_httpaddr}'''
    ...    [${oam_httpaddr}]    ${oam_httpaddr}
    &{vdu_info}=    create dictionary    host=${vdu_web_ip}
    ...    port=443    username=Nemuadmin    password=Nokia@123
    log to console    \nStarting to connect to the DCAP server
    Connect To DCAP    host=${host}    port=${port}
    ...    username=${username}    password=${password}
    ...    rd_version=${rd_version}    secure=${secure}
    ...    alias=${alias}
    Make Sure BTS Integrated In DCAP    ${vdu_info}
    log to console    \nstarting trace
    ${trace_id}    Start Trace In DCAP    ${vdu_info}    tag=start_trace
    ...    vdu_custom_profile=${vdu_custom_profiles}
    ...    force=${True}    vcu_trace_profile=None
    ...    vdu_trace_profile=None    enb_trace_profile=None
    ...    bts_trace_profile=None    wait_for_activation=${False}
    ...    timeout=${400}
    [Return]    ${vdu_web_ip}

Stop TTI Log In vDU
    [Arguments]   ${vdu_web_ip}
    [Documentation]   this kw is used to Stop And download TTI Log In vDU
    ...     Author: Yang Mengli, Liu Renhui
    ...     Contact: mengli.yang@nokia-sbell.com, renhui-david.liu@nokia-sbell.com
    ...    | Input Parameters | Man. | Description |
    ...    | vdu_web_ip | no | vdu webem ip  |
    ...
    ...    | Return Value | Description |
    ...    | dcap_local_file_path | NA |
    ...
    ...    Example
    ...   | Stop TTI Log In vDU |
    ...
    [Timeout]    20 min
    log to console    \nstopping trace
    Stop Trace In DCAP    ${vdu_web_ip}
    log to console    \nDownloading logs
    ${dcap_local_file_path}    Download Trace File    ${vdu_web_ip}
    [Return]    ${dcap_local_file_path}

Stop And Decode TTI Log In vDU
    [Arguments]   ${vdu_web_ip}    ${is_combine_dl_ul}=${True}
    [Documentation]   this kw is used to Stop And Decode TTI Log In vDU
    ...     Author: Yang Mengli, Liu Renhui
    ...     Contact: mengli.yang@nokia-sbell.com, renhui-david.liu@nokia-sbell.com
    ...    | Input Parameters | Man. | Description |
    ...    | vdu_web_ip | no | vdu webem ip  |
    ...    | is_combine_dl_ul | no | True:  combined DL and UL events  |
    ...                            | False: separate dl and ul *.csv   |
    ...
    ...    | Return Value | Description |
    ...    | tti_csv_file_paths | tti csv file paths |
    ...
    ...    Example
    ...   | Stop And Decode TTI Log In vDU |
    ...
    ${dcap_local_file_path}    Stop TTI Log In vDU    ${vdu_web_ip}
    @{files}    OperatingSystem.List Files In Directory    ${dcap_local_file_path}    *.zip
    ${tti_archive}    set variable    ${dcap_local_file_path}/@{files}[0]
    basic.vm_connect    ${PC_HOST}    ${PC_USER}    ${PC_PASSWORD}    alias=VM
    ${tti_csv_file_paths}    decode_tti
    ...    ${ENB_BUILD}    ${dcap_local_file_path}    ${tti_archive}
    ...    ${is_combine_dl_ul}    VM
    [Return]    ${tti_csv_file_paths}
    [Teardown]  Run Keyword And Ignore Error   basic.vm_close    alias=VM

#---------------------snapshot--------------------------------------------------------------------------
Save Local Snapshot In vCU
    [Arguments]     ${gnb_index}=0    ${local_snapshot_location}=vcu_snapshot
    [Documentation]    this kw is used to Gets local snapshot in vcu
    ...    Author: Yang Mengli
    ...    Contact: mengli.yang@nokia-sbell.com
    ...    |  Input Parameters | Man. | Description |
    ...    |  gnb_index  | No |  gnb index to indicate which gnb will be used  |
    ...
    ...    *RETURN VALUE*
    ...    NA
    ...    Example
    ...    |  CU Save Snapshot  |   |
    Log To Console   \n*** Start to save snapshot ***
    Login To vCU By Rest    gnb_index=${gnb_index}
    ${Snapshot_path}    basic.create_a_directory    log_path=${TEST_LOG_DIRECTORY}
    ...                 directory_name=${local_snapshot_location}
    cu.Get_Local_Snapshot  ${Snapshot_path}
    [Return]  ${Snapshot_path}
    [Teardown]  Run Keyword And Ignore Error   Logout To vCU By Rest

Save Local Snapshot In vCU With Judge
    [Arguments]     ${gnb_index}=0    ${local_snapshot_location}=vcu_snapshot
    [Documentation]    this kw is used to Gets local snapshot in vcu
    ...    Author: Yang Mengli
    ...    Contact: mengli.yang@nokia-sbell.com
    ...    |  Input Parameters | Man. | Description |
    ...    |  gnb_index  | No |  gnb index to indicate which gnb will be used  |
    ...
    ...    *RETURN VALUE*
    ...    NA
    ...    Example
    ...    |  CU Save Snapshot  |   |
    Log To Console   \n*** Start to save snapshot ***
    Login To vCU By Rest    gnb_index=${gnb_index}
    ${Snapshot_path}    basic.create_a_directory    log_path=${TEST_LOG_DIRECTORY}
    ...                 directory_name=${local_snapshot_location}
    ${status}    cu.check_snapshot_status
    Run Keyword If    '${status}'=='idle'    cu.Get_Local_Snapshot    ${Snapshot_path}
    ...    ELSE IF    '${status}'=='local-ongoing'    Save Local Ongoing Snapshot In vCU    file_path=${Snapshot_path}
    [Return]    ${Snapshot_path}
    [Teardown]    Run Keyword And Ignore Error    Logout To vCU By Rest


##this kw already deprecated,please use new keyword "Save Local Snapshot In vDU With Judge"
#Save Local Snapshot In vDU
#    [Arguments]    ${local_snapshot_location}=vdu_snapshot    ${vdu_index}=${0}
#    [Documentation]    Save Local Snapshot
#    ...    Author: Yang Mengli
#    ...    Contact: mengli.yang@nokia-sbell.com
#    ...    |  Input Parameters | Man. | Description |
#    ...    | local_snapshot_location | No | local_snapshot_location  |
#    ...
#    ...    | Return Value | Description |
#    ...    | ${Snapshot_path} | return to path of local snapshot |
#    ...
#    ...    Example
#    ...    | Save Local Snapshot In vDU | local_snapshot_location=snapshot |
#    ...
#    log to console    Save Local Snapshot...
#    vDU Login By Rest    vdu_index=${vdu_index}
#    ${Snapshot_path}    basic.create_a_directory    log_path=${TEST_LOG_DIRECTORY}
#    ...                 directory_name=${local_snapshot_location}
#    ${a}    vdu.Get_Local_Snapshot    ${Snapshot_path}
#    [Return]    ${Snapshot_path}
#    [Teardown]    vDU Logout By Rest


Save Local Snapshot In vDU With Judge
    [Arguments]    ${local_snapshot_location}=vdu_snapshot    ${vdu_index}=${0}      ${use_m2m}=${False}
    ...            ${compressed_or_not}=${False}   ${filter_regx}=${None}   ${alias}=VDU_connect
    [Documentation]    Save Local Snapshot
    ...    Author: Yang Menglinokia-sbell.com
    ...    Contact: mengli.yang@ation | No | local_snapshot_location  |
    ...    |  Input Parameters | Man. | Description |
    ...    | local_snapshot_location | No | local_snapshot_location  |
    ...    |  gnb_index  | No |  gnb index to indicate which gnb will be used  |
    ...    | use_m2m | No | m2m feature activation flag.If set to False, internal API will be used instead of M2M |
    ...    | compressed_or_not | No | if it is assigned to True, compressed all the files to one zip file. |
    ...    | filter_regx | No | snapshot filter regular expression, default is None. |
    ...    | alias | yes | define alias of connect to vDU |


    ...    | Return Value | Description |
    ...    | ${Snapshot_path} | return to path of local snapshot |
    ...
    ...    Example
    ...    | Save Local Snapshot In vDU | local_snapshot_location=snapshot |
    ...
    log to console    Save Local Snapshot...
    vDU Login By Rest    vdu_index=${vdu_index}    alias=${alias}
    ${Snapshot_path}    basic.create_a_directory    log_path=${TEST_LOG_DIRECTORY}
    ...                 directory_name=${local_snapshot_location}
    ${status}    vdu.check_snapshot_status     vdu_connection=${alias}
    Run Keyword If    '${status}'=='idle'    vdu.Get_Local_Snapshot    directory=${Snapshot_path}
    ...                                                                vdu_connection=${alias}
    ...                                                                compressed_or_not=${compressed_or_not}
    ...                                                                use_m2m=${use_m2m}
    ...                                                                filter_regx=${filter_regx}
    ...    ELSE IF    '${status}'=='local-ongoing'    Save Local Ongoing Snapshot In vDU    file_path=${Snapshot_path}
    ...    use_m2m=${use_m2m}    vdu_connection=${alias}
    [Return]    ${Snapshot_path}
    [Teardown]    vDU Logout By Rest   vdu_index=${vdu_index}    alias=${alias}


Save Local Ongoing Snapshot In vDU
    [Arguments]   ${file_path}=${Snapshot_path}         ${use_m2m}=${False}   ${vdu_connection}=VDU_connect
    [Documentation]    Save Local Ongoing Snapshot In vDU
    ...    Author: Yang Mengli
    ...    Contact: mengli.yang@nokia-sbell.com
    ...    |  Input Parameters | Man. | Description |
    ...    | file_path | No | local_snapshot_location  |
    ...
    ...    | Return Value | Description |
    ...    | None | NA |
    ...
    ...    Example
    ...    | Save Local Ongoing Snapshot In vDU | file_path=${Snapshot_path} |
    ...
    ${information}    vdu.get_snapshot_operations_information    vdu_connection=${vdu_connection}
    FOR    ${info}    IN    @{information}
        ${operation_id}     Set Variable    ${info['operation_id']}
        vdu.check_local_snapshot_status_and_save_it    directory=${file_path}
        ...                                        operation_id=${operation_id}
        ...                                        use_m2m=${use_m2m}
        ...                                        operation_timeout=600
        ...                                        vdu_connection=${vdu_connection}
        ...                                        compressed_or_not=False
    END

Save Local Ongoing Snapshot In vCU
    [Arguments]   ${file_path}=${Snapshot_path}
    [Documentation]    Save Local Ongoing Snapshot In vDU
    ...    Author: Yang Mengli
    ...    Contact: mengli.yang@nokia-sbell.com
    ...    |  Input Parameters | Man. | Description |
    ...    | file_path | No | local_snapshot_location  |
    ...
    ...    | Return Value | Description |
    ...    | None | NA |
    ...
    ...    Example
    ...    | Save Local Ongoing Snapshot In vDU | file_path=${Snapshot_path} |
    ...
    ${information}    cu.get_snapshot_operations_information
    FOR    ${info}    IN    @{information}
        ${operation_id}    Set Variable    ${info['operation_id']}
        cu.get_local_snapshot_by_id                   directory=${file_path}
        ...                                           operation_id=${operation_id}
        ...                                           operation_timeout=600
        ...                                           use_m2m=False
    END

Check File Exist In Snapshot Log
    [Arguments]    ${snapshot_path}=${snapshot_path}    ${ne}=vDU    ${filter}=RU    ${file_name}=RU_logs.zip
    [Documentation]    Check Snapshot Log for vdu and vcu
    ...    Author: Yang Mengli
    ...    Contact: mengli.yang@nokia-sbell.com
    ...    | Input Parameters | Man. | Description |
    ...    | snapshot_path | No | provide snapshot log path |
    ...    | ne | No | which ne you need to check |
    ...    | filter | No | which filter you need to check |
    ...    | file_name | No | which file you need to check |
    ...
    ...    | Return Value | Description |
    ...    | None | NA |
    ...
    ...    Example
    ...    | Check File Exist In Snapshot Log | snapshot_path=${snapshot_path} |
    ...                                       | ne=vCU | filter=RU | file_name=RU_logs.zip |
    ...
    log to console    Check Snapshot Log
    Run Keyword If    '${ne}'=='vCU'    OperatingSystem.Run
    ...                                   unzip ${snapshot_path}/*.zip -d ${snapshot_path}/vcu_snapshot/
    ...                 ELSE IF    '${ne}'=='vDU'    OperatingSystem.Run
    ...                                   unzip ${snapshot_path}/*.zip -d ${snapshot_path}/vdu_snapshot/
    ${snapshot_path}    Run Keyword If    '${ne}'=='vDU'    Set Variable  ${snapshot_path}/vdu_snapshot
    ...                 ELSE IF    '${ne}'=='vCU'    Set Variable    ${snapshot_path}/vcu_snapshot
	${filecontents}     Grep file           ${snapshot_path}/snapshot_file_list.txt            ${filter}
    Should contain      ${filecontents}     ${file_name}       ignore_case=True

Collect Syslog In Cu
    [Arguments]     ${hostname}=${VCU_HOSTNAME}     ${username}=${VCU_USERNAME}    ${password}=${VCU_PASSWORD}
    ...             ${namespace}=${VCU_NAMESPACE}    ${alias}=vcu_maste    ${gnb_index}=${0}    ${vdu_index}=${0}
    ...             ${timeout}=${10}    ${duration}=300s    ${tmp_log_dir}=${TEST_LOG_DIRECTORY}
    ...             ${syslog_name}=cu_syslog.txt
    [Documentation]    This kw is used to Collect syslog from cu only.
    ...    Author: Lv Shijiu
    ...    Contact: shijiu.lv@nokia-sbell.com
    ...    | Input Parameters | Man. | Description |
    ...    | gnb_index | yes | The list index from tl.cu[], it will use the index of gnb |
    ...    | vdu_index | yes | The list index from tl.dus[], it will use the index of VDU |
    ...    | timeout | optional | set timeout time for execute command |
    ...    | Return Value | Description |
    ...    | ${local_file_path} | return the path of log file  |
    ...
    ...    Example
    ...    | Collect syslog | gnb_index=${0} | vdu_index=${0} | timeout=${10}
    ...
    Log To Console    ${gnb_index}
    Log To Console    ${vdu_index}
    Log To Console    ${tmp_log_dir}
    Log To Console   \n*** Start to collect vcu syslogs to local  ***
    ${conn}=    basic.master_connect    hostname=${hostname}
    ...                                 username=${username}
    ...                                 password=${password}
    ...                                 alias=${alias}
    Set Test Variable    ${conn}
    ${syslog_log_path}=    basic.create_a_directory    log_path=${TEST_LOG_DIRECTORY}    directory_name=syslog
    ${syslog_local_file_path}     k8s.collect_sys_log    namespace=${namespace}
    ...                                           tmp_log_dir=${syslog_log_path}
    ...                                           syslog_name=${syslog_name}
    ...                                           conn=${conn}
    ...                                           timeout=${timeout}
    ...                                           duration=${duration}
    Set Test Variable    ${syslog_local_file_path}
    Log To Console   \n*** Vcu syslogs collected to local..${syslog_local_file_path}  ***
    [Return]    ${syslog_local_file_path}
    [Teardown]    Run Keyword And Ignore Error    basic.master_close    alias=vcu_master


Collect Syslog In Du
    [Arguments]     ${hostname}=${VDU_HOSTNAME}     ${username}=${VDU_USERNAME}    ${password}=${VDU_PASSWORD}
    ...             ${namespace}=${VDU_NAMESPACE}    ${alias}=vdu_maste    ${gnb_index}=${0}
    ...             ${vdu_index}=${0}    ${timeout}=${10}    ${duration}=300s    ${tmp_log_dir}=${TEST_LOG_DIRECTORY}
    ...             ${syslog_name}=vdu_syslog.txt
    [Documentation]    This kw is used to Collect syslog from du only.
    ...    Author: Lv Shijiu
    ...    Contact: shijiu.lv@nokia-sbell.com
    ...    | Input Parameters | Man. | Description |
    ...    | gnb_index | yes | The list index from tl.cu[], it will use the index of gnb |
    ...    | vdu_index | yes | The list index from tl.dus[], it will use the index of VDU |
    ...    | timeout | optional | set timeout time for execute command |
    ...    | Return Value | Description |
    ...    | ${local_file_path} | return the path of log file  |
    ...
    ...    Example
    ...    | Collect syslog | gnb_index=${0} | vdu_index=${0} | timeout=${10} |
    ...
    Log To Console    ${gnb_index}
    Log To Console    ${vdu_index}
    Log To Console    ${tmp_log_dir}
    Log To Console   \n*** Start to collect vdu syslogs to local  ***
    ${conn}=    basic.master_connect    hostname=${hostname}
    ...                                 username=${username}
    ...                                 password=${password}
    ...                                 alias=${alias}
    Set Test Variable    ${conn}
    ${syslog_log_path}=    basic.create_a_directory    log_path=${TEST_LOG_DIRECTORY}    directory_name=syslog
    ${syslog_local_file_path}     k8s.collect_sys_log    namespace=${namespace}
    ...                                           tmp_log_dir=${syslog_log_path}
    ...                                           syslog_name=${syslog_name}
    ...                                           conn=${conn}
    ...                                           timeout=${timeout}
    ...                                           duration=${duration}
    Set Test Variable    ${syslog_local_file_path}
    Log To Console   \n*** Vdu syslogs collected to local..${syslog_local_file_path}  ***
    [Return]    ${syslog_local_file_path}
    [Teardown]    Run Keyword And Ignore Error    basic.master_close    alias=vdu_master


Remove Syslog In Cu
    [Arguments]    ${hostname}=${VCU_HOSTNAME}     ${username}=${VCU_USERNAME}    ${password}=${VCU_PASSWORD}
    ...            ${namespace}=${VCU_NAMESPACE}    ${alias}=vcu_master
    ...            ${gnb_index}=${0}    ${vdu_index}=${0}    ${timeout}=${10}    ${duration}=60s
    [Documentation]    This kw is used to remove syslogs from cu only.
    ...    Author: Lv Shijiu
    ...    Contact: shijiu.lv@nokia-sbell.com
    ...    | Input Parameters | Man. | Description |
    ...    | gnb_index | yes | The list index from tl.cu[], it will use the index of gnb |
    ...    | vdu_index | yes | The list index from tl.dus[], it will use the index of VDU |
    ...    | timeout | optional | set timeout time for execute command |
    ...    | Return Value | Non |
    ...
    ...    Example
    ...    | remove syslog | gnb_index=${0} | vdu_index=${0} | timeout=${10} |
    ...
    Log To Console    ${gnb_index}
    Log To Console    ${vdu_index}
    Log To Console   \n*** Start to clear vcu syslogs...  ***
    ${conn}=    basic.master_connect    hostname=${hostname}
    ...                                 username=${username}
    ...                                 password=${password}
    ...                                 alias=${alias}
    Set Test Variable    ${conn}
    k8s.remove_sys_log    namespace=${namespace}
    ...                   conn=${conn}
    ...                   timeout=${timeout}
    ...                   duration=${duration}
    [Teardown]    Run Keyword And Ignore Error    basic.master_close    alias=vcu_master

Remove Syslog In Du
    [Arguments]    ${hostname}=${VDU_HOSTNAME}     ${username}=${VDU_USERNAME}    ${password}=${VDU_PASSWORD}
    ...            ${namespace}=${VDU_NAMESPACE}    ${alias}=vdu_master
    ...            ${gnb_index}=${0}    ${vdu_index}=${0}    ${timeout}=${10}    ${duration}=60s
    [Documentation]    This kw is used to remove syslogs in du only.
    ...    Author: Lv Shijiu
    ...    Contact: shijiu.lv@nokia-sbell.com
    ...    | Input Parameters | Man. | Description |
    ...    | gnb_index | yes | The list index from tl.cu[], it will use the index of gnb |
    ...    | vdu_index | yes | The list index from tl.dus[], it will use the index of VDU |
    ...    | timeout | optional | set timeout time for execute command |
    ...    | Return Value | Non |
    ...
    ...    Example
    ...    | remove syslog | gnb_index=${0} | vdu_index=${0} | timeout=${10}
    ...
    Log To Console    ${gnb_index}
    Log To Console    ${vdu_index}
    Log To Console    ${vdu_index}
    Log To Console    ${gnb_index}
    Log To Console   \n*** Start to clear vdu syslogs...  ***
    ${conn}=    basic.master_connect    hostname=${hostname}
    ...                                 username=${username}
    ...                                 password=${password}
    ...                                 alias=${alias}
    Set Test Variable    ${conn}
    k8s.remove_sys_log    namespace=${namespace}
    ...                   conn=${conn}
    ...                   timeout=${timeout}
    ...                   duration=${duration}
    [Teardown]    Run Keyword And Ignore Error    basic.master_close    alias=vdu_master

Collect and Download Startup or Journal log
    [Arguments]    ${hostname}=${VDU_HOSTNAME}     ${username}=${VDU_USERNAME}    ${password}=${VDU_PASSWORD}
    ...            ${alias}=collect_vdu_log    ${cnf_type}=vdu    ${namespace}=${VDU_NAMESPACE}
    ...            ${log_type_input}=startup,journal
    [Documentation]    This kw is used to collect and download container log
    ...    Author: Sudi Lou
    ...    Contact: sudi.lou@nokia-sbell.com
    ...    | Input Parameters | Man. | Description |
    ...    | cnf_type | yes | vdu or vcu |
    ...    | namespace | yes | Tenant namespace which pod created in |
    ...    | log_type_input | yes |  Collect vDU/vCU specified log type or multi log types,
    ...                              startup and journal log type are supported now|
    ...
    ...    | Return Value | Description |
    ...    | ${local_file_path} | return the path of log file  |
    ...
    ...    Example
    ...    | Collect and Download Container log | hostname=xxx | username=xxx | password=xxx | alias=collect_vdu_log |
    ...    | ...                                | cnf_type=vdu | namespace=cran1 | log_type_input=startup |
    ...    | Collect and Download Container log | hostname=xxx | username=xxx | password=xxx | alias=collect_vcu_log |
    ...    | ...                                | cnf_type=vcu | namespace=cran1 | log_type_input=journal |
    ...    | Collect and Download Container log | hostname=xxx | username=xxx | password=xxx | alias=collect_vdu_log |
    ...    | ...                                | cnf_type=vdu | namespace=cran1 | log_type_input=startup,journal |
    ...
    log to console    Collect log file in ${cnf_type} server
    ${conn}    basic.master_connect    hostname=${hostname}
    ...                                username=${username}
    ...                                password=${password}
    ...                                alias=${alias}
    ${logs_dir}    ${log_compress_file}=     k8s.collect_startup_or_journal_log    cnf_type=${cnf_type}
    ...                                     namespace=${namespace}    log_type_input=${log_type_input}    conn=${conn}

    log to console    Download log file from ${cnf_type} to ute
    ${local_file_path}=    basic.create_a_file    ${TEST_LOG_DIRECTORY}/container_log    ${log_compress_file}
    csn.Download File    remote_path=${logs_dir}/${log_compress_file}    local_path=${local_file_path}
    ...                  connection=${conn}

    log to console    Verify log file size
    ${local_file_size}   basic.verify_local_file_size    local_path=${local_file_path}
    ${remote_file_size}   basic.verify_remote_file_size   hostname=${hostname}    username=${username}
    ...                                                   password=${password}
    ...                                                   remote_path=${logs_dir}/${log_compress_file}
    ${ratio}   evaluate   ${local_file_size}/${remote_file_size}
    should be true    ${ratio}>0.9    download log file to ute failed

    log to console    Remove log file in ${cnf_type} server
    csn.Execute    command=cd ${logs_dir} && rm -rf ${log_compress_file}
    ...            connection=${conn}
    [Return]    ${local_file_path}
    [Teardown]    Run Keyword And Ignore Error    basic.master_close    alias=${alias}


Delete Troubleshooting Script Runner Operation
  [Arguments]    ${operation_id}   ${vdu_connection}=vdu_con
  [Documentation]  Delete Troubleshooting Script Runner Operation
    ...    Author: gcao
    ...    Contact: ge.cao@nokia-sbell.com
    ...    | operation_id | yes | operation unique ID |
    ...    | vdu_connection | yes | define alias of connect to vDU |
    ...
    ...    | Return Value | Description |
    ...    | None | NA |
    ...
    ...    Example
    ...    | Delete Troubleshooting Script Runner Operation | operation_id=1700018656120930578 |
    ...
  vdu.delete_script_runner_operation   operation_id=${operation_id}   vdu_connection=${vdu_connection}


Get Troubleshooting Script Runner Operation
    [Arguments]    ${operation_id}   ${vdu_connection}=vdu_con
    [Documentation]  Get Troubleshooting Script Runner Operation
    ...    Author: gcao
    ...    Contact: ge.cao@nokia-sbell.com
    ...    | operation_id | yes | operation unique ID |
    ...    | vdu_connection | yes | define alias of connect to vDU |
    ...
    ...    | Return Value | Description |
    ...    | None | NA |
    ...
    ...    Example
    ...    | Get Troubleshooting Script Runner Operation | operation_id=1700018656120930578 |
    ...
    ${res_operation}   vdu.get_script_runner_operation   operation_id=${operation_id}   vdu_connection=${vdu_connection}
    log to console   ${res_operation['status']}
    [Return]    ${res_operation['status']}


Launch Troubleshooting Script By M2M
    [Arguments]   ${fixed_param_and_values_list}   ${script_name}=RU_Common_capture_IQ_data
    ...           ${vdu_conn}=vdu_conn
    [Documentation]    Launch Troubleshooting Script By M2M
    ...    Author: gcao
    ...    Contact: ge.cao@nokia-sbell.com
    ...    | fixed_param_and_values_list | yes | list of fixed param names and values|
    ...    | script_name | yes | "RU_Common_capture_IQ_data" or "RU_Common_capture_L1low_data"
    ...     or "RU_Common_capture_register_dump" |
    ...    | vdu_conn | yes | define alias of connect to vDU|
    ...
    ...    | Return Value | Description |
    ...    | ${res} | dict of operation_id, status, error_message, new_file_generated |
    ...
    ...    Example
    ...    | Launch Troubleshooting Script By M2M | script_name=RU_Common_capture_IQ_data |
    ...
    ${res}   vdu.launch_troubleshooting_script    script_name=${script_name}
    ...                                  fixed_param_and_values_list=${fixed_param_and_values_list}
    ...                                  vdu_connection=${vdu_conn}
    [Return]    ${res}


Parse Trobshooting Log For VDU
    [Arguments]  ${snapshot_path}   ${filter_pattern}=.*?SCRIPT_RESULT.*?    ${ru_index}=${1}
    ...          ${vdu_snapshot_path}=vdu_snapshot
    [Documentation]  Parse Trobshooting Log For VDU
    ...    Author: gcao
    ...    Contact: ge.cao@nokia-sbell.com
    ...    | snapshot_path | yes | snapshot log files path |
    ...    | filter_pattern | yes | a regular expression pattern |
    ...    | ru_index | yes | ru index|
    ...    | vdu_snapshot_path | yes | ru log saved folder|
    ...
    ...    | Return Value | Description |
    ...    | ${match_file_name_list} | return match files name list |
    ...
    ...    Example
    ...    | Parse Trobshooting Log For VDU |
    ...     snapshot_path=/results/M2M_Test_1102_20231116065815/[1]Test_Get_Script_Log_20231116065820/vdu_snapshot/ |
    ...
     basic.create_a_directory    ${snapshot_path}    ${vdu_snapshot_path}
     OperatingSystem.Run
     ...   unzip ${snapshot_path}/RU_${ru_index}.zip -d ${snapshot_path}/${vdu_snapshot_path}/RU_${ru_index}
     ${match_file_name_list}   basic.get_match_files    dir_file=${snapshot_path}/${vdu_snapshot_path}/RU_${ru_index}
     ...                                               filter_pattern=${filter_pattern}
     [Return]    ${match_file_name_list}

# activate l1 iq data configuration
Activate IQ Data Configuration
     [Arguments]  ${ru_iq_data_parameters_list}=${None}   ${dl_nr_subcell_list}=${None}   ${ul_nr_subcell_list}=${None}
     ...  ${vdu_index}=${0}   ${gnb_index}=${0}   ${alias}=vdu_con   ${capture_on_event}=${True}
     ...  ${capture_on_event_from_l1_hi_and_l1_low}=${False}   ${capture_frame_offset}=${0}  ${buffer_cycle}=1024_FRAMES
     [Documentation]  Activate IQ Data Configuration
     ...    Author: gcao
     ...    Contact: ge.cao@nokia-sbell.com
     ...    | ru_iq_data_parameters_list | no | RU specific parameters for IQ data capture, Default is None. or e.g.
     ...      [{'nr_cell_id': 0,
     ...        'target_rmod': 'MRBTS-10950/EQM_R-1/APEQM_R-1/RMOD_R-1',
     ...        'array_elements_polarization': [{'polarization': 'MINUS_45',
     ...        'array_elements': [0],
     ...        'antenna': 'ANT1'}],
     ...        'capture_activity_timer': 1}] |
     ...    | dl_nr_subcell_list | no | List of NR dl subcell identifiers. Default is None.
     ...        :param int nr_cell_id: NR cell instance ID.
     ...        :param int sub_cell_id: NR subcell identifier.
     ...         e.g. [{'nr_cell_id': 0, 'sub_cell_id': 0}]|
     ...    | ul_nr_subcell_list | no | List of NR ul subcell identifiers. Default is None.
     ...        :param int nr_cell_id: NR cell instance ID.
     ...        :param int sub_cell_id: NR subcell identifier.
     ...        e.g. [{'nr_cell_id': 0, 'sub_cell_id': 0}] |
     ...    | alias | no | define alias of connect to vDU |
     ...    | capture_on_event | no | Flag enabling capture on event mode. Default is False. |
     ...    | capture_on_event_from_l1_hi_and_l1_low | no | Flag enabling capture on event from L1Hi(RAN NIC) and L1Low(RU).
     ...      Default is False. |
     ...    | ccapture_frame_offset | no | Capture frame offset. Default is 0. |
     ...    | buffer_cycle | no | Buffer cycle.Allowed value is 2_FRAMES, 4_FRAMES, 8_FRAMES, 16_FRAMES, 32_FRAMES,
     ...      64_FRAMES, 128_FRAMES, 256_FRAMES, 512_FRAMES, 1024_FRAMES.Default is None. |
     ...
     ...    | Return Value | Description |
     ...    | ${operation_id} | operation id |
     ...
     ...    Example
     ...    | Activate IQ Data Configuration | dl_nr_subcell_list=[{'nr_cell_id': 0, 'sub_cell_id': 0}] |
     ...
     Log To Console    ${vdu_index}
     Log To Console    ${gnb_index}
     ${operation_id}   vdu.activate_l1_iq_data_configuration   capture_on_event=${capture_on_event}
     ...   capture_on_event_from_l1_hi_and_l1_low=${capture_on_event_from_l1_hi_and_l1_low}
     ...   dl_nr_subcell_list=${dl_nr_subcell_list}   ul_nr_subcell_list=${ul_nr_subcell_list}
     ...   ru_iq_data_parameters_list=${ru_iq_data_parameters_list}    capture_frame_offset=${capture_frame_offset}
     ...   buffer_cycle=${buffer_cycle}   reason=NOT_SET    vdu_connection=${alias}
     [Return]    ${operation_id}

Get Operation Status of Activating IQ Data Configuration
    [Arguments]   ${operation_id}   ${alias}=vdu_con
    [Documentation]  Get Operation Status of Activating IQ Data Configuration
    ...    Author: gcao
    ...    Contact: ge.cao@nokia-sbell.com
    ...    | operation_id | yes | operation unique ID |
    ...    | alias | no | define alias of connect to vDU |
    ...
    ...    | Return Value | Description |
    ...    | ${res} | dict of operation_id, status, error_message, file_id |
    ...
    ...    Example
    ...    | Get Operation Status of Activating IQ Data Configuration | operation_id=1700018656120930578 |
    ...
    ${res}  vdu.get_operation_status_of_activating_l1_iq_data_configuration
    ...   operation_id=${operation_id}   vdu_connection=${alias}
    [Return]    ${res}

Delete Operation of Activating IQ Data Configuration
    [Arguments]   ${operation_id}   ${alias}=vdu_con
    [Documentation]  Delete Operation of Activating IQ Data Configuration
    ...    Author: gcao
    ...    Contact: ge.cao@nokia-sbell.com
    ...    | operation_id | yes | operation unique ID |
    ...    | alias | no | define alias of connect to vDU |
    ...
    ...    | Return Value | Description |
    ...    | None | NA |
    ...
    ...    Example
    ...    | Delete Operation of Activating IQ Data Configuration | operation_id=1700018656120930578 |
    ...
    vdu.delete_operation_of_activating_l1_iq_data_configuration   operation_id=${operation_id}
    ...                                                                                     vdu_connection=${alias}

# deactivate l1 iq data configuration
Deactivate IQ Data Configuration
    [Arguments]   ${alias}=vdu_con
    [Documentation]  Deactivate IQ Data Configuration
    ...    Author: gcao
    ...    Contact: ge.cao@nokia-sbell.com
    ...    | alias | no | define alias of connect to vDU |
    ...
    ...    | Return Value | Description |
    ...    | None | NA |
    ...
    ...    Example
    ...    | Deactivate IQ Data Configuration | alias=vdu_con |
    ...
    ${deactivate_operation_id}   vdu.deactivate_l1_iq_data_configuration   vdu_connection=${alias}
    [Return]    ${deactivate_operation_id}

Get Operation Status of Deactivating IQ Data Configuration
    [Arguments]   ${operation_id}   ${alias}=vdu_con
    [Documentation]  Get Operation Status of Deactivating IQ Data Configuration
    ...    Author: gcao
    ...    Contact: ge.cao@nokia-sbell.com
    ...    | operation_id | yes | operation unique ID |
    ...    | alias | no | define alias of connect to vDU |
    ...
    ...    | Return Value | Description |
    ...    | ${res} | dict of operation_id, status, error_message, file_id |
    ...
    ...    Example
    ...    | Get Operation Status of Deactivating IQ Data Configuration | operation_id=1700018656120930578 |
    ...
    ${res}   vdu.get_operation_status_of_deactivating_l1_iq_data_configuration    operation_id=${operation_id}
    ...                                                                           vdu_connection=${alias}
    [Return]    ${res}

Delete Operation of Deactivating IQ Data Configuration
    [Arguments]   ${operation_id}   ${alias}=vdu_con
    [Documentation]  Delete Operation of Deactivating IQ Data Configuration
    ...    Author: gcao
    ...    Contact: ge.cao@nokia-sbell.com
    ...    | operation_id | yes | operation unique ID |
    ...    | alias | no | define alias of connect to vDU |
    ...
    ...    | Return Value | Description |
    ...    | None | NA |
    ...
    ...    Example
    ...    | Delete Operation of Deactivating IQ Data Configuration | operation_id=1700018656120930578 |
    ...
    vdu.delete_operation_of_deactivating_l1_iq_data_configuration   operation_id=${operation_id}
    ...                                                             vdu_connection=${alias}

# collect l1 iq data
Collect IQ Data
    [Arguments]   ${alias}=vdu_con   ${capture_mode}=ScheduleSynchronousStopOfOngoingContinuousCapture
    [Documentation]  Collect IQ Data
    ...    Author: gcao
    ...    Contact: ge.cao@nokia-sbell.com
    ...    | alias | yes | define alias of connect to vDU |
    ...    | capture_mode | no | Enable to store backward or onward IQ sample Capture.
    ...      Allowed value is ScheduleSynchronousStopOfOngoingContinuousCapture or StartNewScheduledCapture. |
    ...
    ...    | Return Value | Description |
    ...    | ${collect_iq_data_operation_id} | operation id |
    ...
    ...    Example
    ...    | Collect IQ Data | capture_mode=ScheduleSynchronousStopOfOngoingContinuousCapture |
    ...
    ${collect_iq_data_operation_id}   vdu.collect_l1_iq_data  sfn=${0}   slot=${0}
    ...   capture_mode=${capture_mode}   vdu_connection=${alias}
    [Return]    ${collect_iq_data_operation_id}

Get Operation status of IQ Data Collection
    [Arguments]   ${operation_id}   ${alias}=vdu_con
    [Documentation]  Get Operation status of IQ Data Collection
    ...    Author: gcao
    ...    Contact: ge.cao@nokia-sbell.com
    ...    | operation_id | yes | operation unique ID |
    ...    | alias | no | define alias of connect to vDU |
    ...
    ...    | Return Value | Description |
    ...    | ${res} | dict of operation_id, status, error_message, file_id |
    ...
    ...    Example
    ...    | Get Operation status of IQ Data Collection | operation_id=1700018656120930578 |
    ...
    ${res_collect}   vdu.get_operation_status_of_l1_iq_data_collection   operation_id=${operation_id}   vdu_connection=${alias}
    [Return]    ${res_collect}

Get IQ Data File
    [Arguments]  ${operation_id}   ${file_id}   ${alias}=vdu_con   ${local_path}=/home/ute/l1_iq_data
    ...          ${local_filename}=l1_iq_data_file.tgz
    [Documentation]  Get IQ Data File
    ...    Author: gcao
    ...    Contact: ge.cao@nokia-sbell.com
    ...    | operation_id | yes | operation unique ID |
    ...    | file_id | yes |
    ...      IQ capture unit file ID which can be fetched by keyword `get_operation_status_of_l1_iq_data_collection` |
    ...    | alias | no| define alias of connect to vDU |
    ...    | local_path | no | local directory path which used to store the collected file |
    ...    | local_filename | no | local IQ data file name |
    ...
    ...    | Return Value | Description |
    ...    | ${local_l1_iq_file} | local IQ data file path |
    ...
    ...    Example
    ...    | Get IQ Data File | operation_id=1700018656120930578|
    ...
    ${local_l1_iq_file}   vdu.get_l1_iq_data_file   operation_id=${operation_id}   file_id=${file_id}
    ...                    local_path=${local_path}    local_filename=${local_filename}  vdu_connection=${alias}

Delete Operation of IQ Data Collection
    [Arguments]  ${operation_id}   ${alias}=vdu_con
    [Documentation]  Delete Operation of IQ Data Collection
    ...    Author: gcao
    ...    Contact: ge.cao@nokia-sbell.com
    ...    | operation_id | yes | operation unique ID |
    ...    | alias | no | define alias of connect to vDU |
    ...
    ...    | Return Value | Description |
    ...    | None | NA |
    ...
    ...    Example
    ...    | Delete Operation of IQ Data Collection | operation_id=1700018656120930578 |
    ...
    vdu.delete_operation_of_l1_iq_data_collection   operation_id=${operation_id}   vdu_connection=${alias}

Get Troubleshooting Scripts Information
    [Arguments]    ${owner_module}=${None}   ${script_name}=${None}   ${vdu_connection}=vdu_con
    [Documentation]  Get Troubleshooting Scripts Information
    ...    Author: gcao
    ...    Contact: ge.cao@nokia-sbell.com
    ...    | owner_module | no | If not provided, all scripts will be provided. Available value is RMOD,default is None|
    ...    | script_name | no | If not provided, all scripts will be provided. Default is None. |
    ...    | vdu_connection | yes | define alias of connect to vDU |
    ...
    ...    | Return Value | Description |
    ...    | None | NA |
    ...
    ...    Example
    ...    | Get Troubleshooting Scripts Information | vdu_connection=vdu_con |
    ...
    ${res}   vdu.get_troubleshooting_scripts_information   owner_module=${owner_module}   script_name=${script_name}
    ...      vdu_connection=${vdu_connection}
    log to console   ${res}
    [Return]    ${res}


Start Ip Traffic Capture In vCU
    [Arguments]    ${capture_type}=pod    ${measurement_point}=NE_Terminated    ${plane_type}=uplane
    ...            ${pod_names}=po-cran14-upue-0      ${timeout}=60    ${connection}=ip_traffic_capture_vcu
    [Documentation]    Author: Yang Mengli
    ...                Contact: mengli.yang@nokia-sbell.com
    ...                This kw is used to This keyword is to capture ip traffic.
    ...
    ...    | Input Parameters | Man. | Description |
    ...    | ${capture_type } | No | Type of ip traffic capture area, one of [all, plane, pod] |
    ...    | ${plane_type } | No | list format: Type of ip traffic capture plane provided when captureType = plane. allowed value
    ...    |  is [ uplane, cplane, mplane, others ], default is None.  |
    ...    | ${measurement_point} | No | Type of ip traffic capture area, allowed value is [ NE_Terminated, Transport_Interface ] |
    ...    | ${pod_names} | No | list format: List of podNames provided when captureType = pod, default is None. |
    ...    | ${timeout} | No | (optional) Timeout for the operation, defaults to 60 |
    ...    | ${connection } | No | (optional) Unique identifier for a certain connections or CUConnection instance returned by connect_to |
    ...
    ...    | Return Value | Description |
    ...    | No | NA |
    ...
    ...    Example
    ...    | Start Ip Traffic Capture In vCU |
    Run Keyword And Ignore Error    Logout To vCU By Rest    connection=${connection}
    Login To vCU By Rest    alias=${connection}
    cu.start_ip_traffic_capture    capture_type=${capture_type}    measurement_point=${measurement_point}
    ...                                   plane_type=${plane_type}    pod_names=${pod_names}
    ...                                   timeout=${timeout}    connection=${connection}
    Log to console    Start Ip Traffic Capture In vCU
    [Teardown]    Logout To vCU By Rest    connection=${connection}

Start Ip Traffic Capture In vDU
    [Arguments]    ${vdu_index}=0    ${capture_type}=pod    ${measurement_point}=NE_Terminated
    ...            ${plane_type}=C-Plane    ${pod_names}=po-cran1-cprt-0      ${timeout}=60
    ...            ${connection}=ip_traffic_capture_vdu
    [Documentation]    Author: Yang Mengli
    ...                Contact: mengli.yang@nokia-sbell.com
    ...                This kw is used to This keyword is to capture ip traffic.
    ...
    ...    | Input Parameters | Man. | Description |
    ...    | ${capture_type } | No | Type of ip traffic capture area, one of [all, plane, pod] |
    ...    | ${plane_type } | No | list format: Type of ip traffic capture plane provided when captureType = plane. allowed value
    ...    |  is [ uplane, cplane, mplane, others ], default is None.  |
    ...    | ${measurement_point} | No | Type of ip traffic capture area, allowed value is [ NE_Terminated, Transport_Interface ] |
    ...    | ${pod_names} | No | list format: List of podNames provided when captureType = pod, default is None.|
    ...    | ${timeout} | No | (optional) Timeout for the operation, defaults to 60 |
    ...    | ${connection } | No | (optional) Unique identifier for a certain connections or CUConnection instance returned by connect_to |
    ...
    ...    | Return Value | Description |
    ...    | No | NA |
    ...
    ...    Example
    ...    | Start Ip Traffic Capture In vDU |
    vDU Login By Rest    vdu_index=${vdu_index}    alias=${connection}
    vdu.start_ip_traffic_capture    capture_type=${capture_type}    measurement_point=${measurement_point}
    ...                                   plane_type=${plane_type}    pod_names=${pod_names}
    ...                                   timeout=${timeout}    vdu_connection=${connection}
    Log to console    Start Ip Traffic Capture In vDU
    [Teardown]    vDU Logout By Rest   alias=${connection}

Stop Ip Traffic Capture In vCU
    [Arguments]    ${pod_name}=po-cran14-upue-0    ${timeout}=60    ${connection}=ip_traffic_capture_vcu
    [Documentation]    Author: Yang Mengli
    ...                Contact: mengli.yang@nokia-sbell.com
    ...                This keyword will stop, generate and download ip traffic from webem.
    ...
    ...    | Input Parameters | Man. | Description |
    ...    | ${timeout} | No | (optional) Timeout for the operation, defaults to 60 |
    ...    | ${connection } | No | (optional) Unique identifier for a certain connections or CUConnection instance returned by connect_to |
    ...
    ...    | Return Value | Description |
    ...    | No | NA |
    ...
    ...    Example
    ...    | Stop Ip Traffic Capture |
    Login To vCU By Rest    alias=${connection}
    cu.stop_ip_traffic_capture    timeout=${timeout}    connection=${connection}
    Sleep              10    reason=Wait until ip traffic capture is completed
    cu.generate_ip_traffic_capture_files    credentials=     timeout=${timeout}    connection=${connection}
    Sleep              10    reason=Wait until ip traffic files are generated
    ${info}=           cu.get_ip_traffic_capture_status    connection=${connection}
    ${all_pods_status}=    Set Variable        ${info['pod_status']}
    ${length}=             Get Length    ${all_pods_status}
    ${pod_name_str}=       Convert to String    ${pod_name}
    FOR    ${l}    IN RANGE    ${length}
        ${pod_info}=             Get From List    ${all_pods_status}    ${l}
        ${pod_info_str}=         Convert to String    ${pod_info}
        ${status}=               Run Keyword and Return Status    Should Contain    ${pod_info_str}    ${pod_name_str}
        ${correct_file_name}=    Set Variable If    "${status}"=="True"    ${pod_info['file_name']}
        Exit For Loop If        "${status}"=="True"
    END
    ${upload_info}=    cu.activated_file_upload_operation    timeout=${timeout}    connection=${connection}
    Should Be True    "${upload_info['status']}"=="success"
    ${pcap_path}=    cu.upload_ip_traffic_capture_file    operation_id=${upload_info['operation_id']}
    ...              file_name=${correct_file_name}    local_path=${OUTPUT DIR}
    ...              timeout=${timeout}    connection=${connection}
    [Return]         ${pcap_path}
    [Teardown]       Run Keywords    Run Keyword and Ignore Error    cu.delete_file_upload_operation
    ...                              connection=${connection}
    ...    AND       Logout To vCU By Rest    connection=${connection}

Stop Ip Traffic Capture In vDU
    [Arguments]        ${pod_name}=po-cran1-cprt-0    ${timeout}=60    ${connection}=ip_traffic_capture_vdu
    vDU Login By Rest    vdu_index=0    alias=${connection}
    vdu.stop_ip_traffic_capture    timeout=${timeout}    vdu_connection=${connection}
    Sleep              30    reason=Wait until ip traffic capture is completed
    vdu.generate_ip_traffic_capture_files    credentials=     timeout=${timeout}    vdu_connection=${connection}
    Sleep              30    reason=Wait until ip traffic files are generated
    ${info}=           vdu.get_ip_traffic_capture_status    vdu_connection=${connection}
    ${all_pods_status}=    Set Variable        ${info['pod_status']}
    ${length}=             Get Length    ${all_pods_status}
    ${pod_name_str}=       Convert to String    ${pod_name}
    FOR    ${l}    IN RANGE    ${length}
        ${pod_info}=             Get From List    ${all_pods_status}    ${l}
        ${pod_info_str}=         Convert to String    ${pod_info}
        ${status}=               Run Keyword and Return Status    Should Contain    ${pod_info_str}    ${pod_name_str}
        ${correct_file_name}=    Set Variable If    "${status}"=="True"    ${pod_info['file_name']}
        Exit For Loop If        "${status}"=="True"
    END
    ${upload_info}=    vdu.activated_file_upload_operation    timeout=${timeout}    vdu_connection=${connection}
    Should Be True    "${upload_info['status']}"=="success"
    ${pcap_path}=    vdu.upload_ip_traffic_capture_file    operation_id=${upload_info['operation_id']}
    ...              file_name=${correct_file_name}    local_path=${OUTPUT DIR}
    ...              timeout=${timeout}    vdu_connection=${connection}
    [Return]         ${pcap_path}
    [Teardown]       Run Keywords    Run Keyword and Ignore Error    vdu.delete_file_upload_operation
    ...                              operation_id=${upload_info['operation_id']}    vdu_connection=${connection}
    ...    AND       vDU Logout By Rest   alias=${connection}
