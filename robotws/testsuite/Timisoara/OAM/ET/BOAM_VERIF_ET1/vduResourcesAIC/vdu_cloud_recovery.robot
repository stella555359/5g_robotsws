*** Settings ***
Documentation
...   author: xianbiao.cheng@nokia-sbell.com
...   contact: xianbiao.cheng@nokia-sbell.com
...   vdu_cloud_recovery.robot
...




*** Variables ***



*** Keywords ***
VDU Restart Container
    [Arguments]  ${pod_abbr}   ${container}    ${vdu_index}=0
    [Teardown]  Run Keyword And Ignore Error  Disconnect Interactive Connection   alias=${alias}
    [Documentation]    VDU Restart Container
    ...    *AUTHOR* chris.l.cao@nokia-sbell.com
    ...    | Input Parameters | Man. | Description |
    ...    | pod_abbr     | yes | pod abbreviation, e.g, oamcp, up |
    ...    | container    | yes | container, e.g, oamfh, l2hi |
    ...    | vdu_index    | no | vdu_index, default value is 0 |
    ...
    ...    *RETURN VALUE*
    ...    None
    ...
    ...    Example
    ...   | VDU Restart Container| pod_abbr=oam | container=oamfh |
    ...
    ${alias}   Get Unique Id
    Connect To VDU Node Interactively   pod_abbr=${pod_abbr}   vdu_index=${vdu_index}   alias=${alias}

    ${ns}   Get VDU Namespace From TestLine    vdu_index=${vdu_index}
    ${container_id}   Get Container ID From Docker Ps Command By POD Abbreviation Interactively    ns=${ns}
    ...     pod_abbr=${pod_abbr}    container=${container}    alias=${alias}
    ${cmd}   Set Variable  docker restart ${container_id}
    issh.Execute    ${cmd}   alias=${alias}
    Sleep   10


FHGW Restart Ruproxy
    [Arguments]      ${alias}=default   ${vdu_index}=0   ${fhgw_index}=0   ${ru_index}=1
    [Documentation]    FHGW Restart Ruproxy
    ...    *AUTHOR* chris.l.cao@nokia-sbell.com
    ...    |  Input Parameters | Man. | Description |
    ...    | command  | yes | command, e.g, hostname, ifconfig oam3 |
    ...    | connection        | No | connection. Default value is default |
    ...    | vdu_index | No | vdu_index. Default value is 0 |
    ...    | fhgw_index | No | vdu_index. Default value is 0 |
    ...    | ru_index   | No | ru_index. Default value is 0 |
    ...
    ...    *RETURN VALUE*
    ...    output of command 'docker restart <docker_id>'
    ...
    ...    Example
    ...    | Connect To FHGW |
    ...    | FHGW Restart Ruproxy |
    ...    | Disconnect Interactive Connection |
    ...
    ${pod_full_name}  Get Ruproxy Full Pod Name      alias=${alias}  vdu_index=${vdu_index}   fhgw_index=${fhgw_index}  ru_index=${ru_index}
    ${out}   issh.Execute    command=docker ps|grep ${pod_full_name}|grep -v POD|awk '{print $1}'  alias=${alias}
    ${docker_id}  Parse Hex Number Only From Content   content=${out}
    Log To Console  ruproxy(ru_index:${ru_index}):${docker_id}
    ${out}   issh.Execute    command=docker restart ${docker_id}   alias=${alias}
    [Return]  ${out}


Restart FHGW Services
    [Teardown]   run keyword and ignore error   disconnect interactive connection  alias=${alias}
    [Documentation]  Restart FHGW Services
    ...    *AUTHOR* chris.l.cao@nokia-sbell.com
    ...    |  Input Parameters | Man. | Description |
    ...    None
    ...
    ...    *RETURN VALUE*
    ...    None
    ...
    ...    Example
    ...    | Restart FHGW Services |
    ...
    ${alias}  get unique id
    Connect to FHGW Gracefully  alias=${alias}
    ${out}   issh.Execute   command=systemctl restart sriov   check_result=${False}    alias=${alias}
    ${out}   issh.Execute   command=systemctl stop switch-manager cpri-switch-config-translator   check_result=${False}    alias=${alias}
    ${out}   issh.Execute   command=systemctl start switch-manager cpri-switch-config-translator   check_result=${False}    alias=${alias}
    [Return]  ${out}
