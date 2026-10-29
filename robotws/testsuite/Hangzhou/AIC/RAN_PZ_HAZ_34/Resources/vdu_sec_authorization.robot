*** Settings ***
Documentation
...   author: xianbiao.cheng@nokia-sbell.com
...   contact: xianbiao.cheng@nokia-sbell.com
...   vdu_sec_authorization.robot




*** Variables ***
#@{VDU_REST_TAF_LIB_SUPPORTED_VERSION}   cuoam_19b   cuoam_21b  cuoam_22r2  cuoam_22r4
#&{VDU_RESTAPI_TAF_VERSION_SW_STREAM_MAPPING}   16.300=cuoam_22r4  15.300=cuoam_22r2  0.300=${VDU_REST_TAF_LIB_SUPPORTED_VERSION[-1]}



*** Keywords ***
VDU Rest Login With Special Username And Password
    [Arguments]  ${user}  ${password}  ${restapi_version}=cuoam_22r4  ${vdu_index}=0  ${gnb_index}=0  ${sleep}=30s
    ...    ${alias}=default  ${need_all_info}=${False}
    [Documentation]    VDU Rest Login With Special Username And Password
    ...    *AUTHOR* gang.ni@nokia-sbell.com
    ...   *History Change*
    ...   | date | who | what and how |
    ...   | 2022-7-27 | calwang | update restapi_version default value to cuoam_22r4; add restapi version autodetection
    ...                           based on vDU SW release stream, if 0.300, the latest restapi version will be selected,
    ...                           otherwise the previous version will be selected. |
    ...    | Input Parameters | Man. | Description |
    ...    | user  |  yes  | username |
    ...    | password | yes | password |
    ...    | restapi_version | no | default=cuoam_21b |
    ...    | vdu_index |  no  | VDU index, default is 0 |
    ...    | gnb_index |  no  | default=0 |
    ...    | sleep |  no  |  default=30s  |
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
    sleep  ${sleep}
#    ${current_build_version}    Get Running Build Number
#    ${sw_steam}=    evaluate    '.'.join(${current_build_version.split('.')[:2]})
#    ${restapi_version}   set variable   ${VDU_RESTAPI_TAF_VERSION_SW_STREAM_MAPPING['${sw_steam}']}
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
#    ${vdu_connection}=   Run Keyword If  '${restapi_version}'=='cuoam_21b'  vdu.connect to
#    ...  host=${oam_web_ip}
#    ...  port=${EMPTY}
#    ...  username=${http_username}
#    ...  password=${password}
#    ...  secure=True
#    ...  connection_name=${alias}
#    ...  need_all_info=${need_all_info}
#    ...  ELSE  vdu.connect to
#    ...  host=${oam_web_ip}
#    ...  port=8081
#    ...  username=${http_username}
#    ...  password=${password}
#    ...  need_all_info=${need_all_info}

