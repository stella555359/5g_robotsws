*** Settings ***
Documentation
...   author: xianbiao.cheng@nokia-sbell.com
...   contact: xianbiao.cheng@nokia-sbell.com
...   cu_trs_conn.robot
...   cu connection related KW.




*** Variables ***



*** Keywords ***
Get VCU Sudo For Current User
    [Arguments]  ${alias}=default
    [Documentation]   Get VCU Sudo For Current User
    ...    *AUTHOR* chris.l.cao@nokia-sbell.com
    ...    |  Input Parameters | Man. | Description |
    ...    | alias | no | alias, default value is default  |
    ...
    ...    *RETURN VALUE*
    ...   if current login name is cbis-admin, return sudo. if current login name is root, return ${EMPTY}, otherwise return ${EMPTY}
    ...
    ...    Example
    ...    | ${sudo} | Get VCU Sudo For Current User | alias=myalias |
    ...
    ${current_user_name}   Get Current User Name Interactively   alias=${alias}
    ${sudo}   set variable if   "${current_user_name}"=="cbis-admin"   sudo
        ...   "${current_user_name}"=="root"   ${EMPTY}
        ...   ${EMPTY}
    [Return]   ${sudo}


Get PID For Container In VCU
    [Arguments]  ${pod_abbr}  ${ctr_abbr}   ${alias}=${EMPTY}   ${gnb_index}=0
    [Teardown]  Run Keyword If   "${alias}"=="${EMPTY}"  Run Keyword And Ignore Error   Disconnect Interactive Connection   alias=${real_alias}
    [Documentation]   Get PID For Container In VCU
    ...    *AUTHOR* chris.l.cao@nokia-sbell.com
    ...    history change: 14.7.2022,lingting.sun@nokia-sbell.com, adaption for multi gnb
    ...    |  Input Parameters | Man. | Description |
    ...    | ns              | Yes | namespace |
    ...    | pod_abbr  | yes | pod abbr |
    ...    | ctr_abbr  | yes | container abbr |
    ...    | alias   | no | alias, default value is default |
    ...
    ...    *RETURN VALUE*
    ...    get container id for OCP
    ...
    ...    Example
    ...    | ${alias} |  Connect To CU Node |
    ...    | ${pid} | Get PID For Container In VCU  | ctr_abbr=l2hicu | alias=${alias} |
    ...    | Disconnect Interactive Connection | alias=${alias} |
    ...
    ${real_alias}   Run Keyword If   "${alias}"=="${EMPTY}"   Connect To CU Node  pod_abbr=${pod_abbr}  gnb_index=${gnb_index}
       ...    ELSE   Set Variable   ${alias}
    ${container_id}   Get CU Container ID   pod_abbr=${pod_abbr}  ctr_abbr=${ctr_abbr}  alias=${real_alias}  gnb_index=${gnb_index}
    ${ssh_command}   Set Variable   sudo crictl inspect --output yaml ${container_id}| grep 'pid:'|awk -F ':' '{print $2}'
    ${out}  issh.Execute  command=${ssh_command}  alias=${real_alias}
    ${out}  Strip Prompt  ${out}

    ${pid}   Set Variable  ${out.strip()}
    [Return]  ${pid}


Get Container Pid via Appointed Pod in VCU
    [Arguments]   ${container_abbr}   ${pod_abbr}   ${gnb_index}=0
    [Documentation]   Get Container Pid via Appointed Pod in VCU
    ...    *AUTHOR* r.3.li@nokia-sbell.com

    ...    |  Input Parameters | Man. | Description |
    ...    | pod_abbr  | yes | pod abbr |
    ...    | container_abbr  | yes | container abbr |
    ...    | gnb_index   | no | gnb index |
    ...
    ...    *RETURN VALUE*
    ...    get container id for OCP
    ...
    ...    Example
    ...    | ${pid} | Get Container Pid via Appointed Pod in VCU  | l2hicu | cpif | 0 |
    ...
    ${full_container_name}   Get CU Full Container Name By Container Abbreviation  ctr_abbr=${container_abbr}  gnb_index=${gnb_index}
    ${alias}  Connect To CU K8S Master With Tenant   gnb_index=${gnb_index}
    ${full_pod_name}   Get CU Full Pod Name By Pod Abbreviation    pod_abbr=${pod_abbr}   gnb_index=${gnb_index}
    ...   alias=${alias}
    ${ns}  Get CU Namespace From Testline  gnb_index=${gnb_index}
    ${file_name}   get unique id
    ${remote_file_path}   Set Variable   /tmp/${file_name}.json
    ${local_file}   get a file   ${file_name}
    ${cmd}  Set Variable   kubectl get pod ${full_pod_name} -o jsonpath='{.status.containerStatuses[*]}' -n ${ns} >${remote_file_path}
    ${out}   issh.Execute   command=${cmd}    alias=${alias}
    issh.download_file   ${remote_file_path}   ${local_file}    alias=${alias}
    ${container_id}    get_container_id_from_info    ${local_file}    ${full_container_name}

    ${real_alias}   Connect To CU Node  pod_abbr=${pod_abbr}  gnb_index=${gnb_index}
    ${ssh_command}   Set Variable   sudo crictl inspect --output yaml ${container_id}| grep 'pid:'|awk -F ':' '{print $2}'
    ${out}  issh.Execute  command=${ssh_command}  alias=${real_alias}  check_result=${False}
    ${out}  Strip Prompt  ${out}

    ${pid}   Set Variable  ${out.strip()}
    [Return]  ${pid}
    [Teardown]   Run Keywords   issh.Execute   command=rm -rf ${remote_file_path}    alias=${alias}   AND
    ...   issh.disconnect   alias=${alias}   AND   issh.disconnect   alias=${real_alias}
