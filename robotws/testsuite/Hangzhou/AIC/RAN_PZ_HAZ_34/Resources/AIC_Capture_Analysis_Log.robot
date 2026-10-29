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

Library           ../Resources/python/emil.py    WITH NAME    emil

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
    ...    | pod_prefix | yes | set pod prefix, such as: po-cran1 |
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
    ${bip_pod}    set variable    ${pod_prefix}-${pod_name}-0
    ${bip_container}    set variable    ${container_prefix}-${container_name}
    Set Test Variable    ${alias_issh}    vdu_master_issh
    Connect To K8s Master In vDU    gnb_index=${gnb_index}
    ...    vdu_index=${vdu_index}    alias=${alias_issh}
    ${port_cmd}=    Catenate  kubectl exec -it ${bip_pod} -c ${bip_container} -n ${ns}
    ...     -- bash -c "dpdk-cli show port table | grep ${port_name}"
    ${bip_port_id_tmp}    issh.Execute    command=${port_cmd}
    ...                                 alias=${alias_issh}
    ${bip_port_id}    Get Regexp Matches  ${bip_port_id_tmp}   (\\d).*BIP  1
    ${port_id}    Set Variable  ${bip_port_id[0]}
    ${bip_cmd}=    Catenate  kubectl exec -it  ${bip_pod} -n ${ns}
    ...     -c ${bip_container} -- bash
    ...     -c 'dpdk-cli pdump port ${port_id} path /tmp/dpdkdump > /tmp/dpdkdump/start_bip.log 2>&1'
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
    ...    | pod_prefix | yes | set pod prefix, such as: po-cran1 |
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
    Stop Bip Log    alias=${alias_issh}
    ${remote_log_dir}=     bip.download_bip_log_to_master    pod_name=${pod_name}
    ...                                                  namespace=${ns}
    ...                                                  container_name=${container_name}
    ...                                                  tmp_log_dir=/tmp/bip/
    ...                                                  pod_prefix=${pod_prefix}
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
    ${tshark_version}=    set variable    ${lst}[0]
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


Stop Wireshark Log In vDU
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
    ...    | Stop Wireshark Log In vDU | gnb_index=${0} | vdu_index=${0} |
    ...    | ...                       | container_name=cprt | pod_name=cprt |
    ...
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
    ${conn}=    basic.master_connect    hostname=${hostname}
    ...                           username=${username}
    ...                           password=${password}
    ...                           alias=${alias}
    Set Test Variable    ${conn}
    wireshark.stop_wireshark_forced    conn=${alias}    timeout=${timeout}
    [Teardown]    run keyword and ignore error    basic.master_close    alias=${alias}

Stop Wireshark Log In vCU
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
    ${filtered_packets}    Run    tshark -r ${input_file} -Y "${filter_expression}"
    ${rehexp}    Set Variable
    ...    ((2((5[0-5])|([0-4]\\d)))|([0-1]?\\d{1,2}))(\\.((2((5[0-5])|([0-4]\\d)))|([0-1]?\\d{1,2}))){3}
    ${match}    Get Regexp Matches    ${filtered_packets}    ${rehexp}
    Should Not Be Empty    ${match}
    [Return]    ${filtered_packets}

#---------------------K8S--------------------------------------------------------------------------
Collect And Download K8s Log
    [Arguments]    ${ip}=${VCU_HOSTNAME}    ${username}=${VCU_USERNAME}   ${password}=${VCU_PASSWORD}
    ...            ${gnb_index}=${0}    ${vdu_index}=${0}    ${namespace}=cran1    ${container_name}=l2rt
    ...            ${pod_name}=l2rt    ${timeout}=${10}    ${duration}=${3m}    ${tmp_log_dir}=/tmp/
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
    ${local_file_path}=    basic.create_a_file    ${TEST_LOG_DIRECTORY}/k8s    ${container_name}.log
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
    @{files}    List Files In Directory    ${dcap_local_file_path}    *.zip
    ${tti_archive}    set variable    ${dcap_local_file_path}/${files}[0]
    basic.vm_connect    ${PC_HOST}    ${PC_USER}    ${PC_PASSWORD}    alias=VM
    download_decode_tool    ${ENB_BUILD}    ${dcap_local_file_path}    VM
    ${tti_csv_file_paths}    decode_tti_tool
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

Save Local Snapshot In vDU
    [Arguments]    ${local_snapshot_location}=vdu_snapshot    ${vdu_index}=${0}
    [Documentation]    Save Local Snapshot
    ...    Author: Yang Mengli
    ...    Contact: mengli.yang@nokia-sbell.com
    ...    |  Input Parameters | Man. | Description |
    ...    | local_snapshot_location | No | local_snapshot_location  |
    ...
    ...    | Return Value | Description |
    ...    | ${Snapshot_path} | return to path of local snapshot |
    ...
    ...    Example
    ...    | Save Local Snapshot In vDU | local_snapshot_location=snapshot |
    ...
    log to console    Save Local Snapshot...
    vDU Login By Rest    vdu_index=${vdu_index}
    ${Snapshot_path}    basic.create_a_directory    log_path=${TEST_LOG_DIRECTORY}
    ...                 directory_name=${local_snapshot_location}
    ${a}    vdu.Get_Local_Snapshot    ${Snapshot_path}
    [Return]    ${Snapshot_path}
    [Teardown]    vDU Logout By Rest


Save Local Snapshot In vDU With Judge
    [Arguments]    ${local_snapshot_location}=vdu_snapshot    ${vdu_index}=${0}
    [Documentation]    Save Local Snapshot
    ...    Author: Yang Mengli
    ...    Contact: mengli.yang@nokia-sbell.com
    ...    |  Input Parameters | Man. | Description |
    ...    | local_snapshot_location | No | local_snapshot_location  |
    ...
    ...    | Return Value | Description |
    ...    | ${Snapshot_path} | return to path of local snapshot |
    ...
    ...    Example
    ...    | Save Local Snapshot In vDU | local_snapshot_location=snapshot |
    ...
    log to console    Save Local Snapshot...
    vDU Login By Rest    vdu_index=${vdu_index}
    ${Snapshot_path}    basic.create_a_directory    log_path=${TEST_LOG_DIRECTORY}
    ...                 directory_name=${local_snapshot_location}
    ${status}    vdu.check_snapshot_status
    Run Keyword If    '${status}'=='idle'    vdu.Get_Local_Snapshot    directory=${Snapshot_path}
    ...                                                                compressed_or_not=false
    ...    ELSE IF    '${status}'=='local-ongoing'    Save Local Ongoing Snapshot In vDU    file_path=${Snapshot_path}
    [Return]    ${Snapshot_path}
    [Teardown]    vDU Logout By Rest


Save Local Ongoing Snapshot In vDU
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
    ${information}    vdu.get_snapshot_operations_information
    FOR    ${info}    IN    @{information}
        ${operation_id}     Set Variable    ${info['operation_id']}
        vdu.check_local_snapshot_status_and_save_it    directory=${file_path}
        ...                                        operation_id=${operation_id}
        ...                                        use_m2m=False
        ...                                        operation_timeout=600
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
