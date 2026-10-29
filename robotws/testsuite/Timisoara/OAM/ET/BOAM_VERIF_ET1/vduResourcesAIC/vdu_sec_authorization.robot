*** Settings ***
Documentation
...   author: xianbiao.cheng@nokia-sbell.com
...   contact: xianbiao.cheng@nokia-sbell.com
...   vdu_sec_authorization.robot




*** Variables ***



*** Keywords ***
VDU Rest Login With Special Username And Password
    [Arguments]  ${user}  ${password}  ${restapi_version}=cuoam_21b  ${vdu_index}=0  ${gnb_index}=0  ${alias}=default
    [Documentation]    VDU Rest Login With Special Username And Password
    ...    *AUTHOR* gang.ni@nokia-sbell.com
    ...    | Input Parameters | Man. | Description |
    ...    | user  |  yes  | username |
    ...    | password | yes | password |
    ...    | restapi_version | no | default=cuoam_21b |
    ...    | vdu_index |  no  | VDU index, default is 0 |
    ...    | gnb_index |  no  | default=0 |
    ...    | alias |  no  | default |
    ...
    ...    *RETURN VALUE*
    ...    None
    ...
    ...    Example
    ...    | VDU Rest Login With Special Username And Password | user=BTSApplication | password=${appAdmin_password} |
    ...

    ${vdu_oam_http_connection_info}     Get VDU OAM Http Connection Info
    ${oam_httpaddr}   set variable   ${vdu_oam_http_connection_info["addr"]}
    ${oam_web_ip}   set variable if   ':' in '''${oam_httpaddr}'''   [${oam_httpaddr}]    ${oam_httpaddr}
    ${http_username}  set variable  ${user}

    run keyword and ignore error  vDU Rest Logout   vdu_index=${vdu_index}
    sleep  30s
    ${vdu_connection}=   Run Keyword If  '${restapi_version}'=='cuoam_21b'  vdu.connect to
    ...  host=${oam_web_ip}
    ...  port=${EMPTY}
    ...  username=${http_username}
    ...  password=${password}
    ...  secure=True
    ...  connection_name=${alias}
    ...  ELSE  vdu.connect to
    ...  host=${oam_web_ip}
    ...  port=8081
    ...  username=${http_username}
    ...  password=${password}

