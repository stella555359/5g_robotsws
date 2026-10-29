*** Settings ***
Documentation
...   author: xianbiao.cheng@nokia-sbell.com
...   contact: xianbiao.cheng@nokia-sbell.com
...   vdu_sec_authorization.robot




*** Keywords ***
VDU Rest Login With Special Username And Password
    [Arguments]  ${user}=${EMPTY}   ${password}=${EMPTY}   ${restapi_version}=cuoam_22r4  ${vdu_index}=0  ${gnb_index}=0  ${sleep}=15s
    ...    ${alias}=default  ${need_all_info}=${False}
    [Documentation]    VDU Rest Login With Special Username And Password
    ...    *AUTHOR* gang.ni@nokia-sbell.com
    ...   *History Change*
    ...   | date | who | what and how |
    ...  2022.7.27, calwang@nokia-sbell.com, update restapi_version default value to cuoam_22r4; add restapi version autodetection
    ...                           based on vDU SW release stream, if 0.300, the latest restapi version will be selected,
    ...                           otherwise the previous version will be selected. |
    ...  2023.8.29,chris.l.cao@nokia-sbell.com, support multiple vcu, vdu login
    ...
    ...    | Input Parameters | Man. | Description |
    ...    | user  |  no  | username, default is ${EMPTY}, it means it's Nemuadmin |
    ...    | password | no | password,default is ${EMPTY}, it means it's Nokia@123 |
    ...    | restapi_version | no | default=cuoam_21b |
    ...    | vdu_index |  no  | VDU index, default is 0 |
    ...    | gnb_index |  no  | vcu index, default=0 |
    ...    | sleep |  no  |  default=30s  |
    ...    | alias |  no  | default |
    ...
    ...    *RETURN VALUE*
    ...    None
    ...
    ...    Example
    ...    | VDU Rest Login With Special Username And Password | user=BTSApplication | password=Abud!2345 |
    ...
    ${alias}   VDU Get Alias   gnb_index=${gnb_index}  vdu_index=${vdu_index}   alias=${alias}
    ${vdu_oam_http_connection_info}     Get VDU OAM Http Connection Info
    ${oam_httpaddr}   set variable   ${vdu_oam_http_connection_info["addr"]}
    ${oam_web_ip}   set variable if   ':' in '''${oam_httpaddr}'''   [${oam_httpaddr}]    ${oam_httpaddr}
    ${http_username}  Set Variable If  "${user}"=="${EMPTY}"   ${vdu_oam_http_connection_info["username"]}   ${user}
    ${password}  Set Variable If  "${password}"=="${EMPTY}"    ${vdu_oam_http_connection_info["password"]}   ${password}

    run keyword and ignore error  vDU Rest Logout   alias=${alias}  vdu_index=${vdu_index}  gnb_index=${gnb_index}

    ${status}    ${restapi_version}   Run Keyword And Ignore Error   _Get VDU Rest Api Version   gnb_index=${gnb_index}  vdu_index=${vdu_index}
    ${restapi_version}   Set Variable If    '${status}'=='FAIL'    ${VDU_REST_TAF_LIB_SUPPORTED_VERSION[-1]}     ${restapi_version}

    vdu.connect to
    ...  host=${oam_web_ip}
    ...  port=${EMPTY}
    ...  username=${http_username}
    ...  password=${password}
    ...  vdu_version=${restapi_version}
    ...  secure=True
    ...  connection_name=${alias}
    ...  need_all_info=${need_all_info}

    Sleep  ${sleep}
    [Return]  ${alias}