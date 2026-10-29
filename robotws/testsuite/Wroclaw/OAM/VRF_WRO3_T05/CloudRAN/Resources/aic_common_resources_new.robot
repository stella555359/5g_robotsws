*** Settings ***
Documentation
...   author: cheng xianbiao
...   contact: xianbiao.cheng@nokia-sbell.com

Library           taf.hw.fhgw.cli                       WITH NAME    issh
Library           ../Tests/HA/utils.py





*** Keyword ***
CU Login
    [Arguments]     ${gnb_index}=0   ${solution}=rest   ${alias}=${None}   ${restapi_version}=cuoam_21b
    [Documentation]  Login to CU via rest or webui.
    ...    author: fen.huang@nokia-sbell.com
    ...    modified by:        <13-Nov-2019>, <f2huang>, <Initial creation>
    ...    <18-Jan-2022>, <r3li>, <support webem>
    ...    | Input Parameters | Man. | Description |
    ...    |  gnb_index  | No |  gnb index to indicate which gnb will be used  |
    ...    |  solution | No |  rest or webui, rest in default |
    ...    |  alias | No. | alias that identifies this connection, if the argument is given,
    ...                     the alias must be given to the CU Logout keyword as connection argumument. |

    ...    *RETURN VALUE*
    ...    the restapi connection alias
    ...    Example
    ...    |  CU Login  |     |
    ${alias}=   run keyword if  "${solution}"=="rest"    CU Rest Login   ${gnb_index}  ${alias}   ${restapi_version}
    ...   ELSE    CU WebEM Login    ${gnb_index}
    [Return]   ${alias}


CU Rest Login
   [Arguments]   ${gnb_index}=0   ${alias}=${None}   ${restapi_version}=cuoam_22r4  ${delay}=${EMPTY}
   ...  ${is_default_password}=${False}
   [Documentation]  Create rest session to CU.
    ...    author: fen.huang@nokia-sbell.com
    ...    history change: <date>,<who>,<what and how>
    ...  16.9.2021, chris.l.cao@nokia-sbell.com, add to logout before login
    ...  11.1.2022, chris.l.cao@nokia-sbell.com, add parameter delay
    ...  1.8.2022,  rui.3.li@nokia-sbell.com, update restapi_version default value to cuoam_22r4; add restapi version autodetection
    ...                           based on CU SW release stream, if 0.250, the latest restapi version will be selected,
    ...                           otherwise the previous version will be selected.
    ...  3.8.2022, chris.l.cao@nokia-sbell.com, add 'VCU Api Version'
    ...  10.11.2022, rui.3.li@nokia-sbell.com, support call keyword after reinstall in case, rather than agent
    ...  1.7.2023, chris.l.cao@nokia-sbell.com, add 'VCU Get Alias' to support multip VCU operation
    ...  21.8.2023, rui.3.li@nokia-sbell.com, adapt keyword for ipv6
    ...    | Input Parameters | Man. | Description |
    ...    |  gnb_index  | No |  gnb index to indicate which gnb will be used  |
    ...    | restapi_version | No | if you use 'get_counter' keyword in CU trunk build, the parameter should be given 'cuoam_21b'
    ...                             other senarios should be use default value - cuoam_21b |
    ...    |  alias | No. | alias that identifies this connection, if the argument is given,
    ...                     the alias must be given to the CU Logout keyword as connection argumument. |
    ...    |  delay | No |  delay, default is ${EMPTY}  |
    ...    |  is_default_password | No | is use default password 'nemuuser', default False use 'Nokia@123' |
	...
    ...    *RETURN VALUE*
    ...    the connection alias
    ...    Example
    ...    | CU Rest Login   |
    ...    | CU Rest Login   |  delay=3  |
    ...    | ${alias}        | CU Rest Login | gnb_index=1 |
    ...
    ${alias}   VCU Get Alias   gnb_index=${gnb_index}   alias=${alias}
    ${host}   Set Variable   ${tl.gnbs[${gnb_index}].cu.oam_http_connection_details.addr}

    run keyword and ignore error  CU Rest Logout   connection=${alias}   gnb_index=${gnb_index}
    ${host}   set variable if   ':' in '''${host}'''   [${host}]    ${host}
    ${status}  ${restapi_version}  Run Keyword And Ignore Error   VCU Api Version  gnb_index=${gnb_index}
    ${restapi_version}   Set Variable If    '${status}'=='FAIL'    ${VCU_REST_TAF_LIB_SUPPORTED_VERSION[-1]}     ${restapi_version}
    ${index}     Get Index From List     ${VCU_REST_TAF_LIB_SUPPORTED_VERSION}     ${restapi_version}
    ${password}    Set Variable If    ${index}>=${3}    Nokia@123
    ...    ${tl.gnbs[${gnb_index}].cu.oam_http_connection_details.password}
    ${password}    Set Variable If    '${is_default_password}'=='${True}'    nemuuser    ${password}
    cu.connect to    host=${host}
    ...    port=${tl.gnbs[${gnb_index}].cu.oam_http_connection_details.port}
    ...    username=${tl.gnbs[${gnb_index}].cu.oam_http_connection_details.username}
    ...    password=${password}
    ...    cu_version=${restapi_version}
    ...    secure=${True}
    ...    alias=${alias}
    ...    timeout=10


    Run Keyword If  "${delay}"!="${EMPTY}"  Sleep   ${delay}

    [Return]  ${alias}


VCU Get Alias
    [Arguments]  ${gnb_index}=0   ${alias}=${None}
    [Documentation]  VCU Get Alias
    ...    author: chris.l.cao@nokia-sbell.com
    ...    history change: <date>,<who>,<what and how>
    ...   1.7.2023, chris.l.cao@nokia-sbell.com, support multiple VCU operation
    ...
    ...    | Input Parameters | Man. | Description |
    ...    |  gnb_index  | No |  gnb index to indicate which gnb will be used  |
    ...    |  alias | No. | alias that identifies this connection |
	...
    ...    *RETURN VALUE*
    ...    the connection alias
    ...
    ...    Example
    ...    | ${alias} | VCU Get Alias   |  gnb_index=0   |
    ...
    Return From Keyword If   "${alias}"!="${None}"      ${alias}
    ${alias}   Set Variable If   ${gnb_index}==0   ${None}   vcu_connection_${gnb_index}
    [Return]  ${alias}


VDU Get Alias
    [Arguments]  ${gnb_index}=0   ${vdu_index}=0   ${alias}=default
    [Documentation]  VDU Get Alias
    ...    author: chris.l.cao@nokia-sbell.com
    ...    history change: <date>,<who>,<what and how>
    ...   1.7.2023, chris.l.cao@nokia-sbell.com, support multip VDU operation
    ...
    ...    | Input Parameters | Man. | Description |
    ...    |  gnb_index  | No |  gnb index to indicate which gnb will be used  |
    ...    |  vdu_index  | No |  gnb index to indicate which vdu will be used  |
    ...    |  alias | No. | alias that identifies this connection |

	...
    ...    *RETURN VALUE*
    ...    the connection alias
    ...
    ...    Example
    ...    | ${alias} | VCU Get Alias   |  gnb_index=0   |
    ...
    Return From Keyword If   "${alias}"!="default"      ${alias}
    ${alias}   Set Variable If   ${gnb_index}==0 and ${vdu_index}==0   default   vdu_connection_${gnb_index}_${vdu_index}
    [Return]  ${alias}


VCU Api Version
    [Arguments]  ${gnb_index}=0
    ${current_build_version}    Get Running vCU Build Number   gnb_index=${gnb_index}
    ${sw_steam}=    Evaluate    '.'.join(${current_build_version.split('.')[:2]})
    ${restapi_version}     Set Variable   ${VCU_RESTAPI_TAF_VERSION_SW_STREAM_MAPPING['${sw_steam}']}
    [Return]  ${restapi_version}


CU Rest Login With Special Username And Password
   [Arguments]  ${username}=Nemuadmin  ${password}=nemuuser  ${gnb_index}=0   ${alias}=${None}   ${restapi_version}=cuoam_21b
   [Documentation]  CU Rest Login With Special Username And Password
    ...    author: winnie.su@nokia-sbell.com
    ...  history change:
    ...  8.19.2021,f2huang@nokia-sbell.com
    ...  11.2.2022,chris.l.cao@nokia-sbell.com, give default value for username, password
    ...  17.12.2022,huilin.xu@nokia-sbell.com, add steps of getting restapi_version

    ...    | Input Parameters | Man. | Description |
    ...    | username | Yes |  new username  |
    ...    | password | Yes |  new password  |
    ...    |  gnb_index  | No |  gnb index to indicate which gnb will be used  |
    ...    | restapi_version | No | if you use 'get_counter' keyword in CU trunk build, the parameter should be given 'cuoam_21b'
    ...                             other senarios should be use default value - cuoam_21b |
    ...    |  alias | No. | alias that identifies this connection, if the argument is given,
    ...                     the alias must be given to the CU Logout keyword as connection argumument. |
	...
    ...    *RETURN VALUE*
    ...    the connection alias
    ...
    ...    Example
    ...    |  CU Rest Login With Special Username And Password  |    username=myuser       | password=mypassword |
    ...    |  CU Rest Login With Special Username And Password  |    password=mypassword   |
    ...
    ${host}      Get vCU OAM Ip     gnb_index=${gnb_index}
    ${status}  ${restapi_version}  Run Keyword And Ignore Error   VCU Api Version  gnb_index=${gnb_index}
    ${restapi_version}   Set Variable If    '${status}'=='FAIL'    ${VCU_REST_TAF_LIB_SUPPORTED_VERSION[-1]}     ${restapi_version}
    cu.connect to    host=${host}
    ...    port=${EMPTY}
    ...    username=${username}
    ...    password=${password}
    ...    cu_version=${restapi_version}
    ...    secure=${True}
    ...    alias=${alias}
    ...    timeout=10
    [Return]  ${alias}


CU WebEM Login
    [Arguments]    ${gnb_index}=0   ${logout_firstly}=${False}
    [Documentation]  Login to CU via WebUI.
    ...    author: fen.huang@nokia-sbell.com
    ...    modified by:        <26-Mar-2020>, <f2huang>, <Initial creation>
    ...    <18-Jan-2022>,<r3li>,<Realize the function>
    ...    | Input Parameters | Man. | Description |
    ...    |  gnb_index  | No |  gnb index to indicate which gnb will be used  |
    ...    |  logout_firstly | No | is need to logout after login |
    ...    Example
    ...    | CU WebEM Login | 0 | ${False} |
    ...    | CU WebEM Logout |
    ${http_info}   get_vcu_oam_http_connection_info    ${gnb_index}
    ${oam_httpaddr}   set variable   ${http_info["addr"]}
    ${oam_web_ip}   set variable if   ':' in '''${oam_httpaddr}'''   [${oam_httpaddr}]    ${oam_httpaddr}
    ${cu_oam_url}   Set Variable  https://${oam_web_ip}
    ${username}  set variable  ${http_info["username"]}
    ${password}  set variable  ${http_info["password"]}
    run keyword if  "${logout_firstly}"=="${True}"   run keyword and ignore error  CU WebEM Logout
    wait until keyword succeeds  3x  10s
     ...   scu.Login   url=${cu_oam_url}    username=${username}   password=${password}   timeout=${120}
    Set Test Variable   ${CU_WEBEM_LOGIN_INSTANCE_ID}    cu WebEM Login is Called.


CU Logout
    [Arguments]     ${solution}=rest   ${connection}=${None}
    [Documentation]  Teardown login session to CU.
    ...    author: fen.huang@nokia-sbell.com
    ...    modified by:        <22-Nov-2019>, <f2huang>, <Initial creation>
    ...    <18-Jan-2022>, <r3li>, <support webem>
    ...    | Input Parameters | Man. | Description |
    ...    | solution   | No | login style |
    ...    | connection | No. | the connection alias that used in CU login |

    ...    *RETURN VALUE*
    ...    None
    ...    Example
    ...    |  CU Logout |   |
    run keyword if  "${solution}"=="rest"    CU Rest Logout  ${connection}
    ...   ELSE    CU WebEM Logout


CU Rest Logout
    [Arguments]  ${connection}=${None}  ${gnb_index}=0
    [Documentation]  Teardown rest session to CU.
    ...    author: fen.huang@nokia-sbell.com
    ...    history change: <date>,<who>,<what and how>
    ...  1.7.2023, chris.l.cao@nokia-sbell.com, add 'gnb_index' to support multip VCU operation

    ...    | Input Parameters | Man. | Description |
    ...    | connection | No. | the connection alias that used in CU login |

    ...    *RETURN VALUE*
    ...    None
    ...    Example
    ...    |  CU Rest Logout |   |
    ${alias}   VCU Get Alias   gnb_index=${gnb_index}   alias=${connection}
    cu.disconnect   connection=${alias}  timeout=10


CU WebEM Logout
      [Documentation]  Logout CU webEM.
    ...    author: fen.huang@nokia-sbell.com
    ...    modified by:        <26-Mar-2020>, <f2huang>, <Initial creation>
    ...    <18-Jan-2022>, <r3li>, <Realize the function>
    ...    | Input Parameters | Man. | Description |
    ...
    ...    | CU WebEM Login | 0 | ${False} |
    ...    | CU WebEM Logout |
    ${r}   Run Keyword And Return Status   Variable Should Exist   ${CU_WEBEM_LOGIN_INSTANCE_ID}
    Return From Keyword If  "${r}"=="${False}"
    Return From Keyword If  "${CU_WEBEM_LOGIN_INSTANCE_ID}"=="${None}"

    log to console   \n*** cu Webui Logout ***
    scu.Logout
    Set Test Variable   ${CU_WEBEM_LOGIN_INSTANCE_ID}    ${None}


vDU Login
    [Arguments]  ${login_type}=rest   ${restapi_version}=cuoam_22r4   ${vdu_index}=0   ${gnb_index}=0   ${vdu_version}=coam22r2
    [Documentation]  Login to vdu via rest or webem.
    ...   *Author*: calla.wang@nokia-sbell.com
    ...   *History Change*
    ...   | date | who | what and how |
    ...   | 2019-11-13 | f2huang |  |
    ...   | 2022-1-27 | r3li | add variable ${vdu_version} |
    ...   | 2022-4-6 | hongysun | update documentation |
    ...   | 2023-9-5 | chenwei | update ${vdu_version} |
    ...   *Arguments Description*
    ...   | Input Parameters | Man. | Description |
    ...   | login_type | No | login type, rest or webui, default is rest |
    ...   | restapi_version | No | restapi_version, Current possibilities: [`cuoam_19b`, `cuoam_21b`, 'cuoam_22r2', 'cuoam_22r4'].
    ...                            Defaults to newest implemented release - cuoam_22r4 |
    ...   | vdu_index | No | the index of vdu, default value is 0 |
    ...   | gnb_index | No | the index of gnb, default value is 0 |
    ...   | vdu_version | No | vdu version |
    ...   *Return*
    ...   None
    ...   *Example*
    ...   | vDU Login | rest | cuoam_21b | 0 | 0 | 5G22R2 |
    run keyword if  "${login_type}"=="rest"    Rest Login on vDU   ${restapi_version}  ${vdu_index}  ${gnb_index}
    ...   ELSE   vDU WebEM Login  ${vdu_index}   ${gnb_index}   ${vdu_version}


Rest Login on vDU
    [Arguments]  ${vdu_index}=0  ${gnb_index}=0  ${alias}=default  ${delay}=${EMPTY}
    ...          ${username}=${EMPTY}   ${password}=${Empty}
    [Documentation]  login vdu webem by restful api.
    ...   *Author*: calla.wang@nokia-sbell.com
    ...   *History Change*
    ...   | date | who | what and how |
    ...   | 2022-3-31 | r3li | Update documentation |
    ...   | 2022-7-27 | calwang | update restapi_version default value to cuoam_22r4; add restapi version autodetection
    ...                           based on vDU SW release stream, if 0.300, the latest restapi version will be selected,
    ...                           otherwise the previous version will be selected. |
    ...   | 2022-8-1 | r3li | code enhance |
    ...   | 2022-8-3 | chris.l.cao | add '_Get VDU Rest Api Version' |
    ...   | 2022-10-21 | calla | adding two parameters - username and passowrd to support
    ...                          users can rest login to vdu by special username and password. |
    ...   | 2023-7-1 | chris.l.cao | add gnb_index while calling 'vDU Session Logout'
    ...
    ...   *Arguments Description*
    ...   | Input Parameters | Man. | Description |
    ...   | restapi_version | No | restapi_version, Current possibilities: [`cuoam_19b`, `cuoam_21b`, 'cuoam_22r2', 'cuoam_22r4',
    ...                            'cuoam_23r1']. Defaults to newest implemented release - cuoam_23r1 |
    ...   | vdu_index | No | the index of vdu, default value is 0 |
    ...   | gnb_index | No | the index of gnb, default value is 0 |
    ...   | alias | No | connect name |
    ...   | delay | No | whether is there need sleep, default is ${EMPTY} means not sleep |
    ...   | username | No | vdu webem username, default is EMPTY. If not given, the username will be get from testline configuration |
    ...   | passwork | No | vdu webem password, default is EMPTY. If not given, password is 'Nokia@123' from 23r1 release,
    ...                     'nemuuser' in those older releases than 23r1 |
    ...   *Return*
    ...   None
    ...   *Example*
    ...   | Rest Login on vDU | cuoam_21b | 0 | 0 | default | ${EMPTY} |
    ...   | Rest Login on vDU | cuoam_19b | 0 | 0 | default | 10s |
    ...
    ${alias}   VDU Get Alias   gnb_index=${gnb_index}  vdu_index=${vdu_index}   alias=${alias}
    run keyword and ignore error  vDU Session Logout
    ...    alias=${alias}
    ...    vdu_index=${vdu_index}
    ...    gnb_index=${gnb_index}
    ${vdu_oam_http_connection_info}     Get VDU OAM Http Connection Info    ${gnb_index}  ${vdu_index}
    ${oam_httpaddr}   set variable   ${vdu_oam_http_connection_info["addr"]}
    ${oam_web_ip}   set variable if   ':' in '''${oam_httpaddr}'''   [${oam_httpaddr}]    ${oam_httpaddr}
    ${http_username}  Run Keyword If  "${username}"=="${EMPTY}"  set variable  ${vdu_oam_http_connection_info["username"]}
    ...  ELSE  set variable   ${username}
    ${http_password}  Run Keyword If  "${password}"=="${EMPTY}"   Set Variable  ${vdu_oam_http_connection_info["password"]}
    ...  ELSE  set variable   ${password}
    vdu.connect to
    ...  host=${oam_web_ip}
    ...  port=${EMPTY}
    ...  username=${http_username}
    ...  password=${http_password}
    ...  vdu_version=${vdu_oam_http_connection_info["restapi_version"]}
    ...  secure=True
    ...  connection_name=${alias}
    ...  timeout=10
    Run Keyword If  "${delay}"!="${EMPTY}"  Sleep   ${delay}
    [Return]  ${alias}


vDU Rest Login With Special Password
    [Arguments]  ${password}=${Empty}  ${restapi_version}=cuoam_22r4  ${vdu_index}=0  ${gnb_index}=0
    ...  ${alias}=default  ${username}=${EMPTY}   ${waiting_time}=15s
    [Documentation]  login vdu webem with special password
    ...  history change:
    ...  author:winnie.su@nokia-sbell.com
    ...    history change: <date>,<who>,<what and how>
    ...  8.19.2021,winnie.su@nokia-sbell.com,login vdu webEM with special password
    ...  20.10.2021,shubin.Ren@nokia-sbell.com, add username
    ...  24.04.2023,hongping.rao@nokia-sbell.com, add waiting time
    ...  29.08.2023,chris.l.cao@nokia-sbell.com, change to call 'VDU Rest Login With Special Username And Password'
    ...
    VDU Rest Login With Special Username And Password  user=${username}   password=${password}   restapi_version=${restapi_version}
     ...    vdu_index=${vdu_index}   gnb_index=${gnb_index}   sleep=${waiting_time}   alias=${alias}    need_all_info=${False}


vDU WebEM Login
    [Arguments]   ${vdu_index}=0   ${logout_firstly}=${False}   ${version}=coam22r2
    [Documentation]  Login to vDU via WebEM.
    ...    author: calla.wang@nokia-sbell.com
    ...    history change: <date>,<who>,<what and how>
    ...    modified by:        <26-Mar-2020>, <f2huang>, <Initial creation>
    ...   07.9.2020,peng.lin@nokia-sbell.com, updat
    ...   11.9.2020,chris.l.cao@nokia-sbell.com, add check VDU OAM Up or Down
    ...   26.10.2021,chris.l.cao@nokia-sbell.com, add ${VDU_WEBEM_LOGIN_INSTANCE_ID} to speed case running time
    ...   27.1.2022,rui.3.li@nokia-sbell.com, add variable ${version}
    ...   25.8.2023,chris.l.cao@nokia-sbell.com, change version to coam22r2
    ...
    ...    | Input Parameters | Man. | Description |
    ...    |  vdu_index  | Yes | the index of vdu, default value is 0 |
    ...    | logout_firstly | No | is logout firstly, default is False |
    ...    | version | No | vdu version,default is 5G22R2 |

    log to console   \n*** Start vDU webui login  ***

    ${vdu_oam_http_connection_info}   Get VDU OAM Http Connection Info  vdu_index=${vdu_index}
    ${oam_httpaddr}   set variable   ${vdu_oam_http_connection_info["addr"]}
    ${oam_web_ip}   set variable if   ':' in '''${oam_httpaddr}'''   [${oam_httpaddr}]    ${oam_httpaddr}
    ${vdu_oam_url}   Set Variable  https://${oam_web_ip}
    ${username}  set variable  ${vdu_oam_http_connection_info["username"]}
    ${password}  set variable  ${vdu_oam_http_connection_info["password"]}
    run keyword if  "${logout_firstly}"=="${True}"   run keyword and ignore error  vDU WebEM Logout
    wait until keyword succeeds  3x  5s
     ...   svdu.Login   url=${vdu_oam_url}    username=${username}   password=${password}   timeout=${120}   version=${version}

    Set Test Variable   ${VDU_WEBEM_LOGIN_INSTANCE_ID}    vDU WebEM Login is Called.


vDU Logout
    [Arguments]   ${logout_type}=rest   ${alias}=default
    [Documentation]  Teardown login session to CU
    ...   *Author*: fen.huang@nokia-sbell.com
    ...   *History Change*
    ...   | date | who | what and how |
    ...   | 2019-11-22 | f2huang | initial creation |
    ...   | 2022-4-6 | hongysun | update documentation |
    ...   *Arguments Description*
    ...   | Input Parameters | Man. | Description |
    ...   | logout_type | Yes | default is rest |
    ...   | alias | No | default is default |
    ...   *Return*
    ...   None
    ...   *Example*
    ...   | vDU Logout |
    run keyword if  "${logout_type}"=="rest"    vDU Session Logout   alias=${alias}
    ...   ELSE    vDU WebEM Logout

vDU Session Logout
    [Arguments]  ${vdu_index}=0  ${alias}=default    ${gnb_index}=0
    [Documentation]  vDU Session Logout
    ...  *Author*:calla.wang@nokia-sbell.com
    ...  *History Change*:
    ...  | date | who | what or how |
    ...  | 2020-09-04 | chris.l.cao@nokia-sbell.com | add check for OAM up or down |
    ...  | 2020-09-11 | chris.l.cao@nokia-sbell.com | change to use 'Wait Until VDU OAM Up' |
    ...  | 2022-3-31 | r3li                        | update documentation |
    ...  | 2023-7-1  | chris.l.cao@nokia-sbell.com | add 'gnb_index' to support multip VCU operation |
    ...  | 2023-7-25  | chris.l.cao@nokia-sbell.com | add timeout to vdu.disconnect |
    ...
    ...  *Argument Decription*
    ...  | Input Parameters | Man. | Description |
    ...  | gnb_index | No | gnb index, default is 0 |
    ...  | vdu_index | No | vdu index, default is 0 |
    ...  | alias | No | The alias of connect vdu with rest api |
    ...
    ...  *Return*
    ...
    ...  *Example*
    ...  | Rest Login on vDU |
    ...  | vDU Session Logout |
    ...
    ${alias}   VDU Get Alias   gnb_index=${gnb_index}  vdu_index=${vdu_index}  alias=${alias}
    vdu.disconnect  vdu_connection=${alias}   timeout=10


vDU WebEM Logout
      [Documentation]  Logout vDU webui.
    ...    author: calla.wang@nokia-sbell.com
    ...    history change: <date>,<who>,<what and how>
    ...    modified by:        <26-Mar-2020>, <f2huang>, <Initial creation>
    ...   11.9.2020,chris.l.cao@nokia-sbell.com, change to use 'Wait Until VDU OAM Up'
    ...   26.10.2021,chris.l.cao@nokia-sbell.com, add ${VDU_WEBEM_LOGIN_INSTANCE_ID} to speed case running time
    ...
    ...    | Input Parameters | Man. | Description |
    ...
    ...    |  CU Webui Logout   |     |
    ${r}   Run Keyword And Return Status   Variable Should Exist   ${VDU_WEBEM_LOGIN_INSTANCE_ID}
    Return From Keyword If  "${r}"=="${False}"
    Return From Keyword If  "${VDU_WEBEM_LOGIN_INSTANCE_ID}"=="${None}"

    log to console   \n*** VDU Webui Logout ***
    svdu.Logout

    Set Test Variable   ${VDU_WEBEM_LOGIN_INSTANCE_ID}    ${None}



aic Connect to FHGW
    [Arguments]   ${alias}=default    ${timeout}=300
    [Documentation]   aic Connect to FHGW
    ...    *AUTHOR* chris.l.cao@nokia-sbell.com
    ...    history change: <date>,<who>,<what and how>
    ...   11.10.2021,chris.l.cao@nokia-sbell.com, change to call 'Connect to FHGW Gracefully' to support both FHGW_21 and FHGW22R1
    ...   13.10.2021,chris.l.cao@nokia-sbell.com, cancel call to 'Connect to FHGW Gracefully', support both FHGW_21 and FHGW22R1.
    ...        Note: this KW is different with `Connect to FHGW Gracefully`, because other KWs/cases will handle output of executing result!!!
    ...        So this KW can't be optimized to call `Connect to FHGW Gracefully` directly!!!
    ...
    ...    |  Input Parameters | Man. | Description |
    ...    | gnb_index        |  no | gnb_index, default value is 0 |
    ...    | vdu_index        |  no | vdu_index, default value is 0 |
    ...    | fhgw_index       |  no | fhgw_index, default value is 0 |
    ...    | alias            | No | alias name, default value is default |
    ...    | timeout          | No | timeout, default value is 300 seconds |
    ...
    ...    *RETURN VALUE*
    ...    connection instance to FHGW
    ...
    ...    Example
    ...    | aic Connect to FHGW |
    ...    | ${out} | issh.Execute | command=ls -l |
    ...    | ${out} | issh.Execute | command=ls -l | alias=default |
    ...    | Close Interactive Connection |
    ...
    ${fhgw_account_info}   Get FHGW Account Info
    ${ip}   set variable  ${fhgw_account_info["addr"]}
    ${username}   set variable  ${fhgw_account_info["admin_user_name"]}
    ${password}   set variable  ${fhgw_account_info["admin_user_password_plain"]}
    ${password_2nd}   set variable  ${fhgw_account_info["admin_user_fallback_password_plain"]}

    ${alias}   run keyword if  '${username}'!='_nokfhgwoperator'
    ...   issh.connect_to    ip=${ip}   port=22    username=${username}   password=${password}    timeout=${timeout}
    ...   alias=${alias}   width=200
    ...   ELSE   issh.connect_to    ip=${ip}   port=22    username=${username}   password=${password}    prompt=assword:   timeout=${timeout}
    ...   alias=${alias}   width=200

    ${prompt}   Set Variable If   '${username}' == '_nokfhgwoperator' or '${username}' == 'root'    \\[root@controller\\(FHGW.*\\).*\\]
    ...    \\[toor4nsn@controller\\(FHGW-\\d+\\)\\s\\S+\\][\\r\\n]+#

    issh.set_prompt     ${prompt}   alias=${alias}
    ${res}  run keyword if  '${username}' == '_nokfhgwoperator'    issh.Execute    ${password_2nd}     alias=${alias}


    [Return]  ${alias}


Connect to FHGW Gracefully
    [Arguments]   ${alias}=default    ${timeout}=300
    [Documentation]   Connect to FHGW
    ...    *AUTHOR* chris.l.cao@nokia-sbell.com
    ...    history change: <date>,<who>,<what and how>
    ...   11.10.2021,chris.l.cao@nokia-sbell.com, support both FHGW_21 and FHGW22R1
    ...
    ...    |  Input Parameters | Man. | Description |
    ...    | gnb_index        |  no | gnb_index, default value is 0 |
    ...    | vdu_index        |  no | vdu_index, default value is 0 |
    ...    | fhgw_index       |  no | fhgw_index, default value is 0 |
    ...    | alias            | No | alias name, default value is default |
    ...    | timeout          | No | timeout, default value is 300 seconds |
    ...
    ...    *RETURN VALUE*
    ...    connection instance to FHGW
    ...
    ...    Example
    ...    | ${alias} | Get Unique ID |
    ...    | Connect to FHGW | alias=${alias} |
    ...    | ${out} | issh.Execute | command=ls -l | alias=${alias} |
    ...    | Close Interactive Connection | alias=${alias} |
    ...
    ${fhgw_account_info}   Get FHGW Account Info
    ${ip}   set variable  ${fhgw_account_info["addr"]}
    ${username}   set variable  ${fhgw_account_info["admin_user_name"]}
    ${password}   set variable  ${fhgw_account_info["admin_user_password_plain"]}
    ${password_2nd}   set variable  ${fhgw_account_info["admin_user_fallback_password_plain"]}

    ${alias}   run keyword if  '${username}'!='_nokfhgwoperator'
    ...   issh.connect_to    ip=${ip}   port=22    username=${username}   password=${password}    timeout=${timeout}
    ...   alias=${alias}   width=200
    ...   ELSE   issh.connect_to    ip=${ip}   port=22    username=${username}   password=${password}    prompt=assword:   timeout=${timeout}
    ...   alias=${alias}   width=200
    #issh.set_prompt     \\[root@controller\\(FHGW.*\\).*\\]    alias=${alias}

    ${prompt}   Set Variable If   '${username}' == '_nokfhgwoperator'    \\[root@controller\\(FHGW-\\d+\\)\\s\\S+\\][\\r\\n]+#
    ...    \\[toor4nsn@controller\\(FHGW-\\d+\\)\\s\\S+\\][\\r\\n]+#

    issh.set_prompt     ${prompt}   alias=${alias}
    ${res}  run keyword if  '${username}' == '_nokfhgwoperator'    issh.Execute    ${password_2nd}     alias=${alias}
    [Return]  ${alias}



Connect to FHGW With Root
    [Arguments]   ${alias}=default    ${timeout}=300
    [Teardown]  Run Keyword And Ignore Error   issh.set_prompt     ${prompt}   alias=${alias}
    [Documentation]   Connect to FHGW With Root
    ...    Firstly connect with admin, then login to root with su.
    ...    *AUTHOR* chris.l.cao@nokia-sbell.com
    ...    *history change*:
    ...    | date | who | what and how |
    ...    | 11.10.2021 |chris.l.cao@nokia-sbell.com | support both FHGW_21 and FHGW22R1 |
    ...    | 3.9.2022 | rui.3.li@nokia-sbell.com | add description and recover admin user connect. |
    ...
    ...    *Arguments Description*
    ...    |  Input Parameters | Man. | Description |
    ...    | gnb_index        |  no | gnb_index, default value is 0 |
    ...    | vdu_index        |  no | vdu_index, default value is 0 |
    ...    | fhgw_index       |  no | fhgw_index, default value is 0 |
    ...    | alias            | No | alias name, default value is default |
    ...    | timeout          | No | timeout, default value is 300 seconds |
    ...
    ...    *RETURN VALUE*
    ...    connection instance to FHGW
    ...
    ...    Example
    ...    | Connect to FHGW With Root |
    ...    | ${out} | issh.Execute | command=ls -l |
    ...    | ${out} | issh.Execute | command=ls -l | alias=default |
    ...    | Close Interactive Connection |
    ...
    ${fhgw_account_info}   Get FHGW Account Info
    ${ip}   set variable  ${fhgw_account_info["addr"]}
    ${username}   set variable  ${fhgw_account_info["admin_user_name"]}
    ${password}   set variable  ${fhgw_account_info["admin_user_password_plain"]}
    ${password_2nd}   set variable  ${fhgw_account_info["admin_user_fallback_password_plain"]}

    run keyword if  '${username}'!='_nokfhgwoperator'
    ...   issh.connect_to    ip=${ip}   port=22    username=${username}   password=${password}    timeout=${timeout}
    ...   alias=${alias}   width=200
    ...   ELSE   issh.connect_to    ip=${ip}   port=22    username=${username}   password=${password}    prompt=assword:   timeout=${timeout}
    ...   alias=${alias}   width=200
    #issh.set_prompt     \\[root@controller\\(FHGW.*\\).*\\]    alias=${alias}

    ${prompt}   Set Variable If   '${username}' == '_nokfhgwoperator'    \\[root@controller\\(FHGW-\\d+\\)\\s\\S+\\][\\r\\n]+#
    ...    \\[toor4nsn@controller\\(FHGW-\\d+\\)\\s\\S+\\][\\r\\n]+#|\\[root@controller\\(FHGW-\\d+\\)\\s\\S+\\][\\r\\n]+#

    issh.set_prompt     ${prompt}   alias=${alias}
    ${res}  run keyword if  '${username}' == '_nokfhgwoperator'    issh.Execute    ${password_2nd}     alias=${alias}

    issh.set_prompt     ${prompt}|assword:\\s   alias=${alias}
    ${out}   issh.Execute   command=su -     check_result=${False}   alias=${alias}
    ${out}   Run Keyword If   "assword:" in """${out}"""
       ...   issh.Execute   command=${fhgw_account_info["root_password_plain"]}   check_result=${False}   alias=${alias}

    [Return]  ${alias}


Connect to RUPROXY
    [Arguments]  ${gnb_index}=0  ${vdu_index}=0   ${fhgw_index}=0     ${alias}=default   ${ru_index}=1   ${timeout}=150
    [Documentation]   Connect to RUPROXY
    ...    *AUTHOR* chris.l.cao@nokia-sbell.com
    ...    |  Input Parameters | Man. | Description |
    ...    |  gnb_index        |  no | gnb_index, default value is 0 |
    ...    | vdu_index        |  no | vdu_index, default value is 0 |
    ...    | fhgw_index       |  no | fhgw_index, default value is 0 |
    ...    | alias            | No | alias name, default value is default |
    ...    | ru_index         | No | ru_index, default value is 1, it's value of 'x' of 'radio-x' returned from command 'nokiacli radio list' |
    ...    | timeout          | No | timeout, default value is 300 seconds |
    ...
    ...    *RETURN VALUE*
    ...    connection instance to RU
    ...
    ...    Example
    ...    | Connect to RUPROXY |
    ...    | ${out} | issh.Execute | command=hostname |
    ...    | ${out} | issh.Execute | command=hostname | alias=default |
    ...    | ${out} | issh.Execute | command=hostname | alias=default |
    ...    | ${out} | issh.Execute | command=hostname | alias=default | check_result=${False} |
    ...    | Close Interactive Connection |
    ...
#    aic Connect To FHGW   gnb_index=${gnb_index}  vdu_index=${vdu_index}   fhgw_index=${fhgw_index}    alias=${alias}  timeout=${timeout}
    Connect to FHGW Gracefully  gnb_index=${gnb_index}  vdu_index=${vdu_index}   fhgw_index=${fhgw_index}    alias=${alias}  timeout=${timeout}
    ${container_id}  Get Ruproxy Container ID   alias=${alias}   ru_index=${ru_index}
#    issh.Set Prompt     \\[root@controller\\(FHGW.*\\).*\\]|sh-\\d\\.\\d\\$    alias=${alias}
    ${old_prompt}   issh.Get Prompt   alias=${alias}
    issh.Set Prompt    ${old_prompt}|sh-\\d\\.\\d\\$    alias=${alias}
    ${opt}  set variable  -o BatchMode=no -o UserKnownHostsFile=/dev/null -o StrictHostKeyChecking=no
    sleep   2
    ${out}    wait until keyword succeeds  5x  3s   issh.Execute    command=docker exec -it ${container_id} sh
    ...   check_result=${False}   alias=${alias}
    sleep  1

    [Return]  ${alias}


Connect To Rannic
    [Arguments]  ${conn_info}  ${timeout}=60
    [Documentation]   Connect To Rannic
    ...    *AUTHOR* chris.l.cao@nokia-sbell.com
    ...    |  Input Parameters | Man. | Description |
    ...    | conn_info   | no | conn_info, it is from result of 'Enable Rannic Ssh Access' which includes ssh connection formation to rannic |
    ...    | timeout      | No | timeout, default value is 60 seconds |
    ...
    ...    *RETURN VALUE*
    ...    alias  e.g, d09e7e96aa644ff980c431c401fa43e5
    ...
    ...    Example
    ...   | ${conn_info} | ${delta_plan_result} | Enable Rannic Ssh Access |
    ...   | ${alias}     |  Connect To Rannic | ${conn_info} |
    ...   | ${out}       | issh.Execute | command=ls -l /tmp | alias=${alias} |
    ...   | issh.Disconnect | alias=${alias} |
    ...   | VDU Online Restore Parameters | ${delta_plan_result}
    ...
    ${alias}  Get Unique Id
    ${prompt}  Set Variable   [a-z]-rinline\\d[a-z]:~\\$|\\S+-nic-\\d:~\\$
    issh.Connect_To   ip=${conn_info["oam_ip"]}    username=${conn_info["username"]}   password=${conn_info["password"]}  port=${conn_info["port"]}
       ...   prompt=${prompt}  timeout=${timeout}
       ...   alias=${alias}   width=200
    [Return]  ${alias}


Disconnect From Rannic
    [Arguments]  ${conn_info}
    [Documentation]   Connect To Rannic
    ...    *AUTHOR* chris.l.cao@nokia-sbell.com
    ...    |  Input Parameters | Man. | Description |
    ...    |  conn_info   | no | conn_info, return from Connect To Rannic, please see example |
    ...
    ...    *RETURN VALUE*
    ...   None
    ...
    ...    Example
    ...   | ${alias} | ${conn_info} | Connect To Rannic  |
    ...   | ${out}   | issh.Execute | command=ls -l /tmp | alias=${alias} |
    ...   | Disconnect From Rannic  | conn_info=${conn_info} |
    ...
    ${alias}   Set Variable   ${conn_info["alias"]}
    ${online_change_parameters_dict}   Set Variable   ${conn_info["online_change_parameters_dict"]}
    Run Keyword And Ignore Error  issh.Disconnect   alias=${alias}
    VDU Online Restore Parameters   ${online_change_parameters_dict}


Connect To RU
    [Arguments]  ${gnb_index}=0  ${vdu_index}=0  ${ru_index}=1   ${timeout}=60
    [Documentation]   Connect To RU
    ...    *AUTHOR* chris.l.cao@nokia-sbell.com
    ...  Change History
    ...  24.1.2024 chris.l.cao@nokia-sbell.com, new KW
    ...
    ...    |  Input Parameters | Man. | Description |
    ...    | gnb_index   | no | gnb_index, default value is 0 |
    ...    | vdu_index    | no | vdu_index, default value is 0 |
    ...    | ru_index | no | ru_index, it starts from 1, default value is 1 |
    ...    | timeout      | No | timeout, default value is 60 seconds |
    ...
    ...    *RETURN VALUE*
    ...    {'alias': 'ea866f62404e40fe8ca54f57f0bb858d',
    ...     'conn_info': {'dist_name': 'MRBTS-369371/EQM-1/APEQM-1/RMOD-1',
    ...                   'oam_ip': '10.69.13.194',
    ...                   'password': 'bobuWrUHk7Xq7WPpY9ZcjEi8zNdX3plZ+/y420RZ7W4=',
    ...                   'port': 51201,
    ...                   'username': 'serviceuser'},
    ...     'delta_plan_result': {'need_update': False,
    ...                           'origin_para_value_dict': {'MRBTS-369371/MNL-1/MNLENT-1/SECADM-1': {'actSshToRU': 'true',
    ...                                                                                               'passwdHistoryLength': '0'}},
    ...                           'updated_para_value_dict': {'MRBTS-369371/MNL-1/MNLENT-1/SECADM-1': {'actSshToRU': 'true',
    ...                                                                                                'passwdHistoryLength': '0'}}}}
    ...
    ...    Example
    ...   | ${handle}    | Connect To RU |   |
    ...   | ${alias}     | Set Variable  | ${handle["alias"]} |
    ...   | ${delta_plan_result} | Set Variable  | ${handle["delta_plan_result"]} |
    ...   | ${out}               | issh.Execute | command=ls -l /tmp | alias=${alias} |
    ...   | issh.Disconnect      | alias=${alias} |
    ...   | VDU Online Restore Parameters | ${delta_plan_result} |
    ...
    ...   | ${handle}    | Connect To RU |  ru_index=2 |
    ...   | ${alias}     | Set Variable  | ${handle["alias"]} |
    ...   | ${delta_plan_result} | Set Variable  | ${handle["delta_plan_result"]} |
    ...   | ${out}       | issh.Execute | command=ls -l /tmp | alias=${alias} |
    ...   | issh.Disconnect | alias=${alias} |
    ...   | VDU Online Restore Parameters | ${delta_plan_result}
    ...
    ${conn_info}   ${delta_plan_result}  Enable RU Ssh Access   gnb_index=${gnb_index}  vdu_index=${vdu_index}  ru_index=${ru_index}
    ${alias}  Get Unique Id
    ${prompt_serviceuser}  Set Variable   serviceuser@\\S+:~[#\\$]|serviceuser@\\S+\\s+\\S+
    ${prompt_root}  Set Variable   root@\\S+:~[#\\$]
    issh.Connect_To   ip=${conn_info["oam_ip"]}    username=${conn_info["username"]}   password=${conn_info["password"]}  port=${conn_info["port"]}
       ...   prompt=${prompt_serviceuser}|${prompt_root}  timeout=${timeout}
       ...   alias=${alias}   width=200
    ${handle}   Create Dictionary   alias=${alias}  conn_info=${conn_info}    delta_plan_result=${delta_plan_result}
    [Return]  ${handle}


Connect to Radio Unit
    [Arguments]  ${gnb_index}=0  ${vdu_index}=0   ${fhgw_index}=0     ${alias}=default   ${ru_index}=1   ${timeout}=150
    [Teardown]   Run Keyword If  "${connected_flag}"=="0"
    ...  Run Keyword And Ignore Error  Close Interactive Connection   alias=${alias}
    [Documentation]    Connect to Radio Unit/connect to RU
    ...    *AUTHOR* chris.l.cao@nokia-sbell.com
    ...    history change: <date>,<who>,<what and how>
    ...   15.10.2020,chris.l.cao@nokia-sbell.com, initialization version
    ...   9.6.2021,chris.l.cao@nokia-sbell.com, change 'Connect to FHGW' to 'Connect to FHGW Gracefully'
    ...   9.12.2021,hongyuan.sun@nokia-sbell.com, change var out
    ...   4.1.2023,chris.l.cao@nokia-sbell.com, disconnect ssh session if fails to connect RU
    ...
    ...    |  Input Parameters | Man. | Description |
    ...    |  gnb_index        |  no | gnb_index, default value is 0 |
    ...    | vdu_index        |  no | vdu_index, default value is 0 |
    ...    | fhgw_index       |  no | fhgw_index, default value is 0 |
    ...    | alias            | No | alias name, default value is default |
    ...    | ru_index         | No | ru_index, default value is 1, it's value of 'x' of 'radio-x' returned from command 'nokiacli radio list' |
    ...    | timeout          | No | timeout, default value is 300 seconds |
    ...
    ...    *RETURN VALUE*
    ...    connection instance to RU
    ...
    ...    Example
    ...    | Connect to Radio Unit |
    ...    | ${out} | issh.Execute | command=hostname |
    ...    | ${out} | issh.Execute | command=hostname | alias=default |
    ...    | ${out} | issh.Execute | command=hostname | alias=default | ru_index=1 |
    ...    | ${out} | issh.Execute | command=hostname | alias=default | ru_index=1 | check_result=${False} |
    ...    | Close Interactive Connection |
    ...
    ${connected_flag}  Set Variable   0
    Connect to FHGW Gracefully  gnb_index=${gnb_index}  vdu_index=${vdu_index}   fhgw_index=${fhgw_index}    alias=${alias}  timeout=${timeout}
    ${container_id}  Get Ruproxy Container ID   alias=${alias}   ru_index=${ru_index}
    #${cmd_in_docker}  set variable  cat /etc/dhcp/dhcpd.conf|grep range
    #${cmd_in_docker}   set variable  cat /var/db/dhcpd.leases|grep lease|grep -v \\#
    #${out}    issh.Execute     command=docker exec -it ${container_id} ${cmd_in_docker}    alias=${alias}
    ${ip}   Get Radio Unit Ip Address  ru_index=${ru_index}

    ${old_prompt}  issh.get_prompt  alias=${alias}
    issh.Set Prompt      ${old_prompt}|root@nahka-Node\\d+:\\S*\#   alias=${alias}

    ${opt}  set variable  -o BatchMode=no -o UserKnownHostsFile=/dev/null -o StrictHostKeyChecking=no
    ${opt}  Set Variable  ${opt} -oHostKeyAlgorithms=+ssh-rsa -oPubkeyAcceptedKeyTypes=+ssh-rsa
    ${opt}  issh.Execute     command=docker exec -it ${container_id} ssh ${opt} root@${ip}   check_result=${False}   alias=${alias}
    sleep  1

    ${out}   issh.Execute    command=hostname     alias=${alias}
    ${hostname}   strip prompt  ${out}
    should be true   "${hostname}"=="nahka"
    ${connected_flag}  Set Variable   1

    [Return]  ${alias}


====== VDU SSH Command Begin ======
     Log To Console  \n*** only used for readable ***

Connect To K8s Master
    [Arguments]   ${vdu_index}=0  ${alias}=default
    [Documentation]    Connect To K8s Master
    ...    *AUTHOR* chris.l.cao@nokia-sbell.com
    ...    |  Input Parameters | Man. | Description |
    ...    | vdu_index  |  no | VDU index, default is 0 |
    ...    | alias      | no | alias, default value is default |
    ...
    ...    *RETURN VALUE*
    ...    None.
    ...
    ...    Example
    ...    | Connect To K8s master |
    ...    | ${out}      | Kubectl Exec |  pod_abbr=oamcp  | container=oamfh | command=ls -l |
    ...    | ${out}      | Kubectl Exec |  pod_abbr=oamcp  | container=oamfh | command=ls -l | vdu_index=0 |
    ...    | ${out}      | Kubectl Exec |  pod_abbr=up     | container=l1hi  | command=ls -l /tmp |        |
    ...    | ${out}      | tafssh.Execute | command=kubectl get pod -o wide |           |
    ...    | ${out}      | tafssh.Execute | command=kubectl get pod -o wide -n mynamespace |
    ...    | ${out}      | tafssh.Execute | command=kubectl get namespace |
    ...    | Disconnect From K8s Master   |
    ...
    ...    | Connect To K8s master | alias=myalias |
    ...    | ${out}      | Kubectl Exec |  pod_abbr=oamcp  | container=oamfh | command=ls -l | connection=myalias |
    ...    | ${out}      | tafssh.Execute | command=kubectl get pod -o wide | connection=myalias |
    ...    | ${out}      | tafssh.Execute | command=kubectl describe pod    | connection=myalias |
    ...    | Disconnect From K8s Master   | connection=myalias |
    ...
    tafssh.Connect_To
    ...   hostname=${tl.gnbs[0].dus[${vdu_index}].cloud_deployment.cloud_hosting.master_node.k8s_connection_details.ip_addr}
    ...  username=${tl.gnbs[0].dus[${vdu_index}].cloud_deployment.cloud_hosting.master_node.k8s_connection_details.username}
    ...  password=${tl.gnbs[0].dus[${vdu_index}].cloud_deployment.cloud_hosting.master_node.k8s_connection_details.password}
    ...  alias=${alias}


Connect To K8s Master With Tenant
    [Arguments]   ${vdu_index}=0  ${alias}=default
    [Documentation]    Connect To K8s Master With Tenant
    ...    *AUTHOR* chris.l.cao@nokia-sbell.com
    ...    |  Input Parameters | Man. | Description |
    ...    | vdu_index  |  no | VDU index, default is 0 |
    ...    | alias      | no | alias, default value is default |
    ...
    ...    *RETURN VALUE*
    ...    None.
    ...
    ...    Example
    ...    | Connect To K8s Master With Tenant |
    ...    | ${out}      | tafssh.Execute | command=kubectl get pod -o wide |           |
    ...    | ${out}      | tafssh.Execute | command=kubectl get pod -o wide -n mynamespace |
    ...    | ${out}      | tafssh.Execute | command=kubectl get namespace |
    ...
    tafssh.Connect_To
    ...   hostname=${tl.gnbs[0].dus[${vdu_index}].cloud_deployment.cloud_hosting.master_node.ssh_connection_details.addr}
    ...  username=${tl.gnbs[0].dus[${vdu_index}].cloud_deployment.cloud_hosting.master_node.ssh_connection_details.username}
    ...  password=${tl.gnbs[0].dus[${vdu_index}].cloud_deployment.cloud_hosting.master_node.ssh_connection_details.password}
    ...  alias=${alias}


Connect To K8s Master Interactively
    [Arguments]   ${gnb_index}=0  ${vdu_index}=0  ${timeout}=150  ${alias}=default
    [Documentation]   Connect To K8s Master Interactively
    ...    *AUTHOR* chris.l.cao@nokia-sbell.com
    ...    *History Change*
     ...   | date | who | what and how |
    ...    | 15.10.2020 | chris.l.cao@nokia-sbell.com | initialization version |
    ...    | 31.5.2021 | chris.l.cao@nokia-sbell.com | support NCS |
    ...    | 12.8.2021 | chris.l.cao@nokia-sbell.com | support OCP by adding '[core@...]' |
    ...    | 7.3.2022 | hongyuan.sun@nokia-sbell.com | add parameter timeout |
    ...    | 13.4.2022| hongyuan.sun@nokia-sbell.com | add return alias |
    ...    *Arguments Description*
    ...    | Input Parameters | Man. | Description |
    ...    | gnb_index  |  no  | gnb index, default is 0 |
    ...    | vdu_index  |  no  | VDU index, default is 0 |
    ...    | alias      | no   | alias, default value is default |
    ...
    ...    *RETURN VALUE*
    ...    None.
    ...
    ...    *Example*
    ...    | Connect To K8s Master Interactively |
    ...    | ${out} | issh.Execute | command=ls -l |
    ...    | Close Interactive Connection  |
    ...
    ...    | ${alias} | Get Unique Id |
    ...    | Connect To K8s Master Interactively   | alias=${alias} |
    ...    | ${out} | issh.Execute | command=ls -l | alias=${alias}  |
    ...    | Close Interactive Connection     | alias=${alias} |
    ...
    ${vdu_k8s_master_ssh_connection_info}   Get K8s Admin SSH Connection Info  gnb_index=${gnb_index}   vdu_index=${vdu_index}

    ${ip}   set variable   ${vdu_k8s_master_ssh_connection_info["addr"]}
    ${username}   set variable   ${vdu_k8s_master_ssh_connection_info["username"]}
    ${password}   set variable   ${vdu_k8s_master_ssh_connection_info["password"]}

#    ${prompt}  set variable    \\[cloudadmin@\\S+\\s\\S+\\]\\$|\\[root@\\S+\\s\\S+\\s+\\S+\\]\\#|\\[root@\\S+\\s\\S+\\]\\#
#    ${prompt}  set variable   ${prompt}|\\[cbis-admin@\\S+\\s\\S+\\s+\\S+\\]\\$|\\[cbis-admin@\\S+\\s\\S+\\]\\$
#    ${prompt}  set variable   ${prompt}|\\[core@\\S+\\s\\S+\\]\\$

    #${prompt}  set variable    \\[root@\\S+\\s\\S+\\s+\\S+\\]\\#|\\[root@\\S+\\s\\S+\\]\\#
#    ${prompt}  set variable   \\[core@\\S+\\s\\S+\\]\\$\\s
    ${prompt}   Set Variable   ${VDU_OE_SERVER_PROMPT}|${VDU_CONTAINER_PROMPT}|${VDU_CONTAINER_PROMPT_ROOT}|\\[${username}@.*\\]\\$

    issh.Connect_To   ip=${ip}    username=${username}   password=${password}
       ...   prompt=${prompt}
       ...   alias=${alias}   width=200
       ...   timeout=${timeout}
    [Return]  ${alias}


Connect To K8s Master With Tenant Interactively
    [Arguments]   ${vdu_index}=0  ${alias}=default
    [Documentation]    Connect To K8s Master With Tenant Interactively
    ...    *AUTHOR* chris.l.cao@nokia-sbell.com
    ...    history change: <date>,<who>,<what and how>
    ...   15.10.2020,chris.l.cao@nokia-sbell.com, initialization version
    ...   31.5.2021,chris.l.cao@nokia-sbell.com, support NCS
    ...
    ...    |  Input Parameters | Man. | Description |
    ...    | vdu_index  |  no | VDU index, default is 0 |
    ...    | gnb_index  |  no | gnb index, default is 0 |
    ...    | alias      | no | alias, default value is default |
    ...
    ...    *RETURN VALUE*
    ...    None.
    ...
    ...    Example
    ...    | Connect To K8s Master With Tenant Interactively |
    ...    | ${out}      | issh.Execute | command=kubectl get pod -o wide |
    ...    | Close Interactive Connection    |
    ...
    ...    | ${alias} | Get Unique Id |
    ...    | Connect To K8s Master With Tenant Interactively |  alias=${alias} |
    ...    | ${out}      | issh.Execute | command=kubectl get pod -o wide |  alias=${alias} |
    ...    | Close Interactive Connection  | alias=${alias} |
    ...
    ${ip}    Set Variable   ${tl.gnbs[0].dus[${vdu_index}].cloud_deployment.cloud_hosting.master_node.ssh_connection_details.addr}
    ${username}  Set Variable  ${tl.gnbs[0].dus[${vdu_index}].cloud_deployment.cloud_hosting.master_node.ssh_connection_details.username}
    ${password}  Set Variable  ${tl.gnbs[0].dus[${vdu_index}].cloud_deployment.cloud_hosting.master_node.ssh_connection_details.password}

#    ${prompt}  set variable    \\[cranuser\\d+@\\S+\\s+\\S+\\]\\$|\\[cranuser\\d+@\\S+\\s+\\S+\\s+\\S+\\]\\$
    ${prompt}  set variable   ${VDU_OE_SERVER_PROMPT_TENANT}|${VDU_CONTAINER_PROMPT}|${VDU_CONTAINER_PROMPT_ROOT}
    ${prompt}  Set Variable  ${prompt}|\\[core@\\S+\\s\\S+\\]\\$
    issh.Connect_To   ip=${ip}    username=${username}   password=${password}
       ...   prompt=${prompt}
       ...   alias=${alias}   width=200
    [Return]   ${alias}


Connect To VDU Container Interactively
    [Arguments]  ${pod_abbr}=${EMPTY}  ${ctr_abbr}=${EMPTY}  ${alias}=defaul|t  ${gnb_index}=0  ${vdu_index}=0  ${pod_index}=0
    [Documentation]  Connect To VDU Container Interactively
    ...   *Author*: chris.l.cao@nokia-sbell.com
    ...   *History Change*
    ...   | date | who | what and how |
    ...   | 2022-2-12 | chris.l.cao | initial creation |
    ...   | 2022-4-6 | hongysun | update documentation |
    ...   | 2022-4-24 | hongysun | add pod_index parameter |
    ...
    ...   *Arguments Description*
    ...   | Input Parameters | Man. | Description |
    ...   | pod_abbr | No. | the pod name abbreviation, do not give the full pod name. such as oamcm |
    ...   | ctr_abbr | Yes. | the container name abbreviation. such as oamagent, oamcm |
    ...   | alias | No. | the alias that connected to the container. |
    ...   | gnb_index | No. | the gnb index, default value is 0. |
    ...   | vdu_index | No. | the vdu index, default value is 0. |
    ...   | pod_index | No. | default is 0, e.g: if up-1, pod_index=1 |
    ...
    ...   *Return*
    ...   None
    ...
    ...   *Example*
    ...   | Connect To VDU Container Interactively | ctr_abbr=oamagent |
    ...   | ${out} | issh.Execute | command=date |
    ...   | Close Interactive Connection  |
    ...
    ...   | ${alias} | Get Unique Id |
    ...   | Connect To VDU Container Interactively | ctr_abbr=oamagent | alias=${alias} |
    ...   | ${out} | issh.Execute | command=date | alias=${alias} |
    ...   | Close Interactive Connection | alias=${alias} |
    ...
    ...   | ${alias} | Get Unique Id |
    ...   | Connect To VDU Container Interactively | pod_abbr=oamext | ctr_abbr=nwmgmt | alias=${alias} |
    ...   | ${out} | issh.Execute_Bare | command=y\r | alias=${alias} |
    ...   | Close Interactive Connection | alias=${alias} |
    ...
    Wait Until Keyword Succeeds   15x   3   _Connect To VDU Container Interactively Once
       ...  pod_abbr=${pod_abbr}  ctr_abbr=${ctr_abbr}  alias=${alias}  gnb_index=${gnb_index}  vdu_index=${vdu_index}
       ...  pod_index=${pod_index}


_Connect To VDU Container Interactively Once
    [Arguments]  ${pod_abbr}=${EMPTY}  ${ctr_abbr}=${EMPTY}  ${gnb_index}=0  ${vdu_index}=0  ${pod_index}=0  ${alias}=default
    [Teardown]  Run Keyword And Ignore Error   Run Keyword If
    ...  "${login_container_flag}"=="0"  Close Interactive Connection  alias=${alias}
    [Documentation]  _Connect To VDU Container Interactively Once
    ...  history change:
    ...  author:chris.l.cao@nokia-sbell.com
    ...   12.2.2022,chris.l.cao@nokia-sbell.com, initilization
    ...
    ...    | Input Parameters | Man. | Description |
    ...    | pod_abbr | No. | the pod name abbreviation, do not give the full pod name. such as oamcm |
    ...    | ctr_abbr | Yes. | the container name abbreviation. such as oamagent, oamcm |
    ...    | alias   | No. | the alias that connected to the container. |
    ...    | gnb_index | No. | the gnb index, default value is 0. |
    ...    | vdu_index | No. | the vdu index, default value is 0. |
    ...
    ...    *RETURN VALUE*
    ...    None
    ...
    ${login_container_flag}   Set Variable   0

    Connect To K8s Master Interactively     alias=${alias}   gnb_index=${gnb_index}  vdu_index=${vdu_index}

    ${ns}   get_vdu_namespace_from_testline     gnb_index=${gnb_index}  vdu_index=${vdu_index}
    ${pod_abbr}   Run Keyword If   "${pod_abbr}"=="${EMPTY}"   Get Pod Abbreviation By Container Abbreviation   container_abbr=${ctr_abbr}
    ...   ELSE  Set Variable  ${pod_abbr}

    ${container_full_name}     Get Full Container Name By Container Abbreviation  ctr_abbr=${ctr_abbr}   vdu_index=${vdu_index}
    ${pod_full_name}  Get Full Pod Name By Pod Abbreviation Interactively   pod_abbr=${pod_abbr}   alias=${alias}
          ...  gnb_index=${gnb_index}  vdu_index=${vdu_index}  pod_index=${pod_index}

    ${kubectl_cmd}   Set Variable    kubectl exec -it ${pod_full_name} -c ${container_full_name} -n ${ns} -- bash
    ${out}   issh.Execute    command=${kubectl_cmd}   check_result=${False}   alias=${alias}

#    ${container_in_UP_pod}  Create List     l2hi
#    ${prompt}  Set Variable If   "${ctr_abbr}" in ${container_in_UP_pod}   ${VDU_CONTAINER_PROMPT_ROOT}    ${VDU_CONTAINER_PROMPT}
    ${prompt}  Set Variable   ${VDU_CONTAINER_PROMPT}
    Should Match Regexp   ${out}   ${prompt}
    Sleep  0.5
    ${login_container_flag}   Set Variable   1


Connect To VDU Container With Tenant Interactively
    [Arguments]  ${pod_abbr}=${EMPTY}   ${ctr_abbr}=${EMPTY}   ${alias}=default    ${gnb_index}=0   ${vdu_index}=0
    [Documentation]  Connect To VDU Container With Tenant Interactively
    ...  history change:
    ...  author:chris.l.cao@nokia-sbell.com
    ...   28.2.2022,chris.l.cao@nokia-sbell.com, initilization
    ...
    ...    | Input Parameters | Man. | Description |
    ...    | pod_abbr | No. | the pod name abbreviation, do not give the full pod name. such as oamcm |
    ...    | ctr_abbr | Yes. | the container name abbreviation. such as oamagent, oamcm |
    ...    | alias   | No. | the alias that connected to the container. |
    ...    | gnb_index | No. | the gnb index, default value is 0. |
    ...    | vdu_index | No. | the vdu index, default value is 0. |
    ...
    ...    *RETURN VALUE*
    ...    None
    ...
    ...    Example
    ...    | Connect To VDU Container With Tenant Interactively | ctr_abbr=oamagent |
    ...    | ${out} | issh.Execute | command=date |
    ...    | Close Interactive Connection  |
    ...
    ...    | ${alias} | Get Unique Id |
    ...    | Connect To VDU Container With Tenant Interactively | ctr_abbr=oamagent | alias=${alias} |
    ...    | ${out} | issh.Execute | command=date | alias=${alias}  |
    ...    | Close Interactive Connection    | alias=${alias} |
    ...
    ...    | ${alias} | Get Unique Id |
    ...    | Connect To VDU Container With Tenant Interactively | pod_abbr=oamext | ctr_abbr=nwmgmt | alias=${alias} |
    ...    | ${out} | issh.Execute_Bare | command=y\r | alias=${alias}  |
    ...    | Close Interactive Connection    | alias=${alias} |
    ...
    Wait Until Keyword Succeeds   15x   3   _Connect To VDU Container With Tenant Interactively Once
       ...   pod_abbr=${pod_abbr}   ctr_abbr=${ctr_abbr}   alias=${alias}    gnb_index=${gnb_index}   vdu_index=${vdu_index}


_Connect To VDU Container With Tenant Interactively Once
    [Arguments]  ${pod_abbr}=${EMPTY}   ${ctr_abbr}=${EMPTY}   ${alias}=default    ${gnb_index}=0   ${vdu_index}=0
    [Teardown]  Run Keyword And Ignore Error  Run Keyword If   "${login_container_flag}"=="0"
    ...  Close Interactive Connection    alias=${alias}
    [Documentation]  _Connect To VDU Container With Tenant Interactively Once
    ...  history change:
    ...  author:chris.l.cao@nokia-sbell.com
    ...   12.2.2022,chris.l.cao@nokia-sbell.com, initilization
    ...   17.7.2022,chris.l.cao@nokia-sbell.com, change to '${login_container_flag}   Set Variable If   "${r}"=="PASS"   1   0'
    ...
    ...    | Input Parameters | Man. | Description |
    ...    | pod_abbr | No. | the pod name abbreviation, do not give the full pod name. such as oamcm |
    ...    | ctr_abbr | Yes. | the container name abbreviation. such as oamagent, oamcm |
    ...    | alias   | No. | the alias that connected to the container. |
    ...    | gnb_index | No. | the gnb index, default value is 0. |
    ...    | vdu_index | No. | the vdu index, default value is 0. |
    ...
    ...    *RETURN VALUE*
    ...    None
    ...
    ${login_container_flag}   Set Variable   0

    Connect To K8s Master With Tenant Interactively     alias=${alias}   gnb_index=${gnb_index}  vdu_index=${vdu_index}

    ${ns}   get_vdu_namespace_from_testline     gnb_index=${gnb_index}  vdu_index=${vdu_index}
    ${pod_abbr}   Run Keyword If   "${pod_abbr}"=="${EMPTY}"   Get Pod Abbreviation By Container Abbreviation   container_abbr=${ctr_abbr}
    ...   ELSE  Set Variable  ${pod_abbr}

#    ${container_full_name}     Get Full Container Name By Container Abbreviation  ctr_abbr=${ctr_abbr}   vdu_index=${vdu_index}
    ${container_prefix}   Run Keyword If  "${ctr_abbr}"=="nwmgmt"   Get Container Name Prefix  vdu_index=${vdu_index}
    ${container_full_name}   Run Keyword If  "${ctr_abbr}"=="nwmgmt"
       ...   Set Variable   ${container_prefix}${ctr_abbr}
       ...   ELSE   Get Full Container Name By Container Abbreviation  ctr_abbr=${ctr_abbr}   vdu_index=${vdu_index}
    ${pod_full_name}  Get Full Pod Name By Pod Abbreviation Interactively   pod_abbr=${pod_abbr}   alias=${alias}
          ...  gnb_index=${gnb_index}   vdu_index=${vdu_index}

    ${kubectl_cmd}   Set Variable    kubectl exec -it ${pod_full_name} -c ${container_full_name} -n ${ns} -- bash
    ${out}   issh.Execute    command=${kubectl_cmd}   check_result=${False}   alias=${alias}

#    ${container_in_UP_pod}  Create List   l2hi
#    ${prompt}  Set Variable If   "${ctr_abbr}" in ${container_in_UP_pod}   ${VDU_CONTAINER_PROMPT_ROOT}    ${VDU_CONTAINER_PROMPT}
    ${prompt}  Set Variable   ${VDU_CONTAINER_PROMPT}|${VDU_CONTAINER_PROMPT_ROOT}
    ${r}  ${out2}  Run Keyword And Ignore Error   Should Match Regexp   ${out}   ${prompt}

    Sleep  0.5
    ${login_container_flag}   Set Variable If   "${r}"=="PASS"   1   0
    Run Keyword If    "${r}"!="PASS"   Fail


Connect To vDU Node
    [Arguments]  ${pod_abbr}=${EMPTY}   ${container_abbr}=${EMPTY}   ${vdu_index}=0  ${master_alias}=MASTER  ${node_alias}=NODE
    [Documentation]    start collect tcpdump in vdu container
    ...    *AUTHOR* calla.wang@nokia-sbell.com
    ...    history change: <date>,<who>,<what and how>
    ...    28.5.2020,calla.wang@nokia-sbell.com,
    ...    26.4.2022,chris.l.cao@nokia-sbell.com, add container_abbr parameter
    ...
    ...    | Input Parameters | Man. | Description |
    ...    | pod_abbr        |  no | pod abbreviation, e.g, oam, cprt, up |
    ...    | container_abbr |  no | container abbreviation, e.g, oam, oamfh, cprt, l1hi |
    ...
    ...    *RETURN VALUE*
    ...    the connection alias of the node.
    ...
    ...    Example
    ...  | Connect To VDU Node  |  container_abbr=oamfh |
    ...  | Connect To VDU Node  |  container_abbr=oam |
    ...  | Connect To VDU Node  |  pod_abbr=oam |
    ...  | Connect To VDU Node  |  pod_abbr=cprt |
    ...
    run keyword if  "${pod_abbr}"=="${EMPTY}" and "${container_abbr}"=="nwmgmt"  Fail  Can't use nwmgmt container, must use pod_abbr!
    run keyword if  "${pod_abbr}"=="${EMPTY}" and "${container_abbr}"=="${EMPTY}"  Fail  pod_abbr or container_abbr must be given!
    run keyword if  "${pod_abbr}"!="${EMPTY}" and "${container_abbr}"!="${EMPTY}"  Fail  pod_abbr and container_abbr can't be used at the same time!
    ${pod_abbr}  run keyword if  "${pod_abbr}"=="${EMPTY}"  Get Pod Abbreviation By Container Abbreviation    container_abbr=${container_abbr}
    ...   ELSE   set variable   ${pod_abbr}

    Connect To K8s Master  ${vdu_index}  alias=${master_alias}
    ${node_ip}=  Get Work Node Ip By Pod Abbreviation  pod_abbr=${pod_abbr}   connection=${master_alias}  vdu_index=${vdu_index}
    tafssh.connect_to
    ...  hostname=${node_ip}
    ...  username=${tl.gnbs[0].dus[${vdu_index}].cloud_deployment.cloud_hosting.master_node.k8s_connection_details.username}
    ...  password=${tl.gnbs[0].dus[${vdu_index}].cloud_deployment.cloud_hosting.master_node.k8s_connection_details.password}
    ...  proxy=${master_alias}
    ...  alias=${node_alias}
    [Return]  ${node_alias}


Connect To vDU Node Interactively
    [Arguments]   ${pod_abbr}=${EMPTY}   ${container_abbr}=${EMPTY}  ${vdu_index}=0  ${alias}=default
    [Documentation]   Connect To vDU Node Interactively
    ...    *AUTHOR* chris.l.cao@nokia-sbell.com
    ...    |  Input Parameters | Man. | Description |
    ...    | pod_abbr        |  no | pod abbreviation, e.g, oam, cprt, up |
    ...    | container_abbr |  no | container abbreviation, e.g, oam, oamfh, cprt, l1hi |
    ...    | vdu_index  |  no  | VDU index, default is 0 |
    ...    | alias      | no   | alias, default value is default |
    ...
    ...    *RETURN VALUE*
    ...    None.
    ...
    ...    Example
    ...    | Connect To vDU Node Interactively | pod_abbr=oamcp |
    ...    | ${ns} | Get vDU Namespace From TestLine  |
    ...    | ${container_id} | Get Container ID From Docker Ps Command By POD Abbreviation Interactively | ns=${ns} |
    ...    |  ... | pod_abbr=oamcp | container=oamfh | alias=default |
    ...    | ${out} | Docker Exec By Container ID Interactively | container_id=${container_id} | command=ifconfig | alias=default |
    ...
    run keyword if  "${pod_abbr}"=="${EMPTY}" and "${container_abbr}"=="nwmgmt"  Fail  Can't use nwmgmt container, must use pod_abbr!
    run keyword if  "${pod_abbr}"=="${EMPTY}" and "${container_abbr}"=="${EMPTY}"  Fail  pod_abbr or container_abbr must be given!
    run keyword if  "${pod_abbr}"!="${EMPTY}" and "${container_abbr}"!="${EMPTY}"  Fail  pod_abbr and container_abbr can't be used at the same time!
    ${pod_abbr}  run keyword if  "${pod_abbr}"=="${EMPTY}"  Get Pod Abbreviation By Container Abbreviation    container_abbr=${container_abbr}
    ...   ELSE   set variable   ${pod_abbr}

    ${ip}    set variable   ${tl.gnbs[0].dus[${vdu_index}].cloud_deployment.cloud_hosting.master_node.k8s_connection_details.ip_addr}
    ${username}  set variable  ${tl.gnbs[0].dus[${vdu_index}].cloud_deployment.cloud_hosting.master_node.k8s_connection_details.username}
    ${password}  set variable  ${tl.gnbs[0].dus[${vdu_index}].cloud_deployment.cloud_hosting.master_node.k8s_connection_details.password}

    #issh.connect_to   ip=${ip}    username=${username}   password=${password}
    #   ...   prompt=\\[cloudadmin@controller-\\d+\\s+\\S+\\]\\$|\\[cloudadmin@compute-\\d+\\s+\\S+\\]\\$
    #   ...   alias=${alias}   width=200
    connect to k8s master interactively     vdu_index=${vdu_index}   alias=${alias}

    #${master_node_hostname}  Get Host Name   alias=${alias}

    #${work_node_ip}    Get Work Node Ip By Pod Abbreviation Interactively   pod_abbr=${pod_abbr}   alias=${alias}   vdu_index=${vdu_index}
    #${ssh_command}  Set Variable  ssh -o BatchMode=yes -o UserKnownHostsFile=/dev/null -o StrictHostKeyChecking=no ${work_node_ip}
    #issh.Execute  command=${ssh_command}   alias=${alias}
    #${work_node_hostname}  Get Host Name   alias=${alias}

    #${out}  Run Keyword If  "${master_node_hostname}"=="${work_node_hostname}"   issh.Execute  command=exit   alias=${alias}
    [Return]  ${alias}


Disconnect From K8s Master
    [Arguments]   ${connection}=default
    [Documentation]    Disconnect From K8s Master
    ...    *AUTHOR* chris.l.cao@nokia-sbell.com
    ...    |  Input Parameters | Man. | Description |
    ...    | alias      | no | alias, default value is default |
    ...
    ...    *RETURN VALUE*
    ...    None.
    ...
    ...    Example
    ...    | Connect To K8s master |
    ...    | ${out}      | Kubectl Exec |  pod_abbr=oamcp  | container=oamfh | command=ls -l |
    ...    | ${out}      | Kubectl Exec |  pod_abbr=oamcp  | container=oamfh | command=ls -l | vdu_index=0 |
    ...    | Disconnect From K8s Master |
    ...
    tafssh.Disconnect   connection=${connection}


Kubectl Exec
    [Arguments]  ${pod_abbr}=${EMPTY}   ${container}=${EMPTY}   ${command}=${EMPTY}   ${connection}=default   ${vdu_index}=0
    [Documentation]    Kubectl exec
    ...    *AUTHOR* chris.l.cao@nokia-sbell.com
    ...    |  Input Parameters | Man. | Description |
    ...    | pod       |  Yes | pod name, eg, oamcp, uprt |
    ...    | container | Yes | container name, e.g. oam, oamfh, nwmgmt, cprt, rcpsdl, l2rt, l2hi, l1hi |
    ...    | command  | yes | command, e.g, hostname, ifconfig oam3 |
    ...    | connection        | No | connection. Default value is default |
    ...    | vdu_index | No | vdu_index. Default value is 0 |
    ...
    ...    *RETURN VALUE*
    ...    Linux command execution result inside container.
    ...
    ...    Example
    ...    | Connect To K8s master |
    ...    | ${out}      | Kubectl Exec | container=oamfh | command=ls -l |
    ...    | ${out}      | Kubectl Exec | pod_abbr=oam | container=oamfh | command=ls -l |
    ...    | Disconnect From K8s Master   |
    ...
    run keyword if    "${pod_abbr}"=="${EMPTY}" and "${container}"=="nwmgmt"  Fail   Please give pod_abbr for container nwmgmt !

#    ${out}   run keyword if   "${pod_abbr}"=="${EMPTY}"    _Kubectl Exec By Container Abbreviation
#    ...   container=${container}   command=${command}   connection=${connection}   vdu_index=${vdu_index}
#    ...   ELSE   _Kubectl Exec By Pod Abbreviation
#    ...   pod_abbr=${pod_abbr}   container=${container}   command=${command}   connection=${connection}   vdu_index=${vdu_index}
    ${pod_abbr}   run keyword if   "${pod_abbr}"=="${EMPTY}"  Get Pod Abbreviation By Container Abbreviation   container_abbr=${container}
    ...   ELSE  Set Variable  ${pod_abbr}

    ${out}     _Kubectl Exec By Pod Abbreviation
    ...   pod_abbr=${pod_abbr}   container=${container}   command=${command}   connection=${connection}   vdu_index=${vdu_index}

    [Return]  ${out}


_Kubectl Exec By Pod Abbreviation
    [Arguments]  ${pod_abbr}=${EMPTY}   ${container}=${EMPTY}   ${command}=${EMPTY}   ${connection}=default   ${vdu_index}=0
    [Documentation]    Kubectl exec
    ...    *AUTHOR* chris.l.cao@nokia-sbell.com
    ...    |  Input Parameters | Man. | Description |
    ...    | pod       |  Yes | pod name, eg, oamcp, uprt |
    ...    | container | Yes | container name, e.g. oam, oamfh, nwmgmt, cprt, rcpsdl, l2rt, l2hi, l1hi |
    ...    | command  | yes | command, e.g, hostname, ifconfig oam3 |
    ...    | connection        | No | connection. Default value is default |
    ...    | vdu_index | No | vdu_index. Default value is 0 |
    ...
    ...    *RETURN VALUE*
    ...    Linux command execution result inside container.
    ...
    ...    Example
    ...    | Connect To K8s master |
    ...    | ${out}      | Kubectl Exec |  pod_abbr=oamcp  | container=oamfh | command=ls -l |
    ...    | ${out}      | Kubectl Exec |  pod_abbr=oamcp  | container=oamfh | command=ls -l | vdu_index=0 |
    ...    | ${out}      | Kubectl Exec |  pod_abbr=oamcp  | container=oamfh | command=ls -l | vdu_index=0 | connection=myalias |
    ...    | Disconnect From K8s Master   |
    ...

    ${container}     Get Full Container Name By Container Abbreviation  ctr_abbr=${container}   vdu_index=${vdu_index}
    ${ns}  Get vDU Namespace From TestLine   vdu_index=${vdu_index}
    ${pod_full_name}  Get Full Pod Name By Pod Abbreviation   pod_abbr=${pod_abbr}    connection=${connection}  vdu_index=${vdu_index}
    ${kubectl_cmd}   Set Variable  kubectl exec -it ${pod_full_name} -c ${container} -n ${ns} -- ${command}
    ${out}   tafssh.Execute    command=${kubectl_cmd}   connection=${connection}
    [Return]  ${out}


Kubectl Exec Interactively
    [Arguments]  ${pod_abbr}=${EMPTY}   ${container}=${EMPTY}   ${command}=${EMPTY}   ${alias}=default   ${check_result}=${True}  ${vdu_index}=0
    ...   ${with_bash}=${False}   ${with_pipeline_command}=${EMPTY}   ${pod_index}=0
    [Documentation]    Kubectl exec Interactively
    ...    *AUTHOR* chris.l.cao@nokia-sbell.com
    ...   3.8.2021,chris.l.cao@nokia-sbell.com, add parameter with_bash
    ...   15.10.2021,chris.l.cao@nokia-sbell.com, add parameter with_pipeline_command
    ...
    ...    |  Input Parameters | Man. | Description |
    ...    | pod_abbr  |  Yes | pod abbreviation name, eg, oamcp, uprt |
    ...    | container | Yes | container name, e.g. oam, oamfh, nwmgmt, cprt, rcpsdl, l2rt, l2hi, l1hi |
    ...    | command  | yes | command, e.g, hostname, ifconfig oam3 |
    ...    | alias        | No | alias. Default value is default |
    ...    | vdu_index | No | vdu_index. Default value is 0 |
    ...
    ...    *RETURN VALUE*
    ...    Linux command execution result inside container.
    ...
    ...    Example
    ...    | connect to k8s master with tenant interactively |
    ...    | ${out}      | Kubectl Exec Interactively |  container=oamfh | command=ls -l |
    ...    | ${out}      | Kubectl Exec Interactively |  container=cprt | command=ls -l |
    ...    | ${out}      | Kubectl Exec Interactively | pod_abbr=oam | container=oamfh | command=ls -l |
    ...    | Close Interactive Connection |
    ...
    run keyword if    "${pod_abbr}"=="${EMPTY}" and "${container}"=="nwmgmt"  Fail   Please give pod_abbr for container nwmgmt !

    ${pod_abbr}   run keyword if   "${pod_abbr}"=="${EMPTY}"   Get Pod Abbreviation By Container Abbreviation   container_abbr=${container}
    ...   ELSE  Set Variable  ${pod_abbr}
    ${out}      _Kubectl Exec Interactively By Pod Abbreviation
        ...      pod_abbr=${pod_abbr}   container=${container}   command=${command}  alias=${alias}  check_result=${check_result}
        ...      vdu_index=${vdu_index}   with_bash=${with_bash}   with_pipeline_command=${with_pipeline_command}
        ...      pod_index=${pod_index}
    [Return]  ${out}



_Kubectl Exec Interactively By Pod Abbreviation
    [Arguments]  ${pod_abbr}   ${container}   ${command}   ${alias}=default   ${vdu_index}=0   ${with_bash}=${False}
    ...   ${with_pipeline_command}=${EMPTY}   ${pod_index}=0
    [Documentation]    Kubectl exec Interactively
    ...    *AUTHOR* chris.l.cao@nokia-sbell.com
    ...    history change: <date>,<who>,<what and how>
    ...   3.8.2021,chris.l.cao@nokia-sbell.com, add parameter with_bash
    ...
    ...    |  Input Parameters | Man. | Description |
    ...    | pod_abbr  |  Yes | pod abbreviation name, eg, oamcp, uprt |
    ...    | container | Yes | container name, e.g. oam, oamfh, nwmgmt, cprt, rcpsdl, l2rt, l2hi, l1hi |
    ...    | command  | yes | command, e.g, hostname, ifconfig oam3 |
    ...    | alias        | No | alias. Default value is default |
    ...    | vdu_index | No | vdu_index. Default value is 0 |
    ...
    ...    *RETURN VALUE*
    ...    Linux command execution result inside container.
    ...
    ...    Example
    ...    | connect to k8s master with tenant interactively |
    ...    | ${out}      | Kubectl Exec Interactively |  pod_abbr=oamcp  | container=oamfh | command=ls -l |
    ...    | ${out}      | Kubectl Exec Interactively |  pod_abbr=oamcp  | container=oamfh | command=ls -l | vdu_index=0 |
    ...    | ${out}      | Kubectl Exec Interactively |  pod_abbr=oamcp  | container=oamfh | command=ls -l | vdu_index=0 | alias=myalias |
    ...    | Close Interactive Connection |
    ...
    ${container}     Get Full Container Name By Container Abbreviation  ctr_abbr=${container}   vdu_index=${vdu_index}
    ${ns}  Get vDU Namespace From TestLine   vdu_index=${vdu_index}
    ${pod_full_name}  Get Full Pod Name By Pod Abbreviation Interactively  pod_abbr=${pod_abbr}   alias=${alias}
    ...  vdu_index=${vdu_index}   pod_index=${pod_index}

    ${kubectl_cmd}   Set Variable if   "${with_bash}"=="${False}"   kubectl exec -it ${pod_full_name} -c ${container} -n ${ns} -- ${command}
    ...    kubectl exec -it ${pod_full_name} -c ${container} -n ${ns} -- bash -c "${command}"

    ${kubectl_cmd}   Set Variable if   "${with_pipeline_command}"!="${EMPTY}"    ${kubectl_cmd}${with_pipeline_command}   ${kubectl_cmd}

    ${out}   issh.Execute    command=${kubectl_cmd}   check_result=False   alias=${alias}
    ${out}   strip prompt  ${out}
    [Return]  ${out}


====== VDU SSH Command End ======
Connect To UTE
    [Arguments]  ${hostname}=${UTE_SSH_IP}   ${username}=${UTE_SSH_USER_NAME}   ${password}=${UTE_SSH_PASSWORD}  ${alias}=default
    ...   ${keyfile}=/home/ute/.ssh/id_rsa
    [Documentation]   Connect To UTE
    ...    *AUTHOR* chris.l.cao@nokia-sbell.com
    ...  Change History
    ...  20.2.2024 chris.l.cao@nokia-sbell.com, add prompt for root user, support both keyfile and password to login
    ...
    ...    |  Input Parameters | Man. | Description |
    ...    | hostname  |  no | hostname, default value is ${UTE_SSH_IP} |
    ...    | username  |  no | username, default value is ${UTE_SSH_USER_NAME} |
    ...    | password  |  no | password, default value is ${UTE_SSH_PASSWORD} |
    ...    | keyfile   |  no | keyfile, when it's empty, it will use password to login, default value is /home/ute/.ssh/id_rsa |
    ...    | alias     |  no | aliase name, default value is default |
    ...
    ...    *RETURN VALUE*
    ...    None
    ...
    ...    Example
    ...    | Connect To UTE |
    ...    | Connect To UTE | password=abc | keyfile=${EMPTY} |
    ...    | ${out}         | issh.Execute | command=ls -l |
    ...    | Close Interactive Connection |
    ...
    ${prompt}  Set Variable   ${username}@.*\\$|root@.*\\#
    issh.connect_to   ip=${hostname}    username=${username}   password=${password}
              ...   prompt=${prompt}   keyfile=${keyfile}   alias=${alias}   width=500

    [Return]  ${alias}


Connect To UTE Locally
    [Arguments]    ${username}=${UTE_SSH_USER_NAME}   ${password}=${UTE_SSH_PASSWORD}   ${alias}=default
    [Documentation]   Connect To UTE Locally
    ...    *AUTHOR* chris.l.cao@nokia-sbell.com
    ...    |  Input Parameters | Man. | Description |
    ...    | username  |  no | username, default value is ${UTE_SSH_USER_NAME} |
    ...    | password  |  no | password, default value is ${UTE_SSH_PASSWORD} |
    ...    | alias     |  no | aliase name, default value is default |
    ...
    ...    *RETURN VALUE*
    ...    None
    ...
    ...    Example
    ...    | Connect To UTE Locally     |
    ...    | ${out}                     | issh.Execute | command=ls -l |
    ...    | Close Interactive Connection |
    ...
    Connect To UTE    hostname=127.0.0.1   username=${username}   password=${password}  alias=${alias}


Connect To DCAP
    [Arguments]  ${alias}=default
    [Documentation]    Connect To DCAP(Commercial)
    ...    *AUTHOR* huilin.xu@nokia-sbell.com
    ...    history change: <date>,<who>,<what and how>
    ...    23.11.2022,chris.l.cao@nokia-sbell.comm, update KW example
    ...    26.7.2022,rui.3.li@nokia-sbell.comm, optimize keyword
    ...    |  Input Parameters | Man. | Description |
    ...    | alias  |  no | aliase name, default value is default |
    ...
    ...    *RETURN VALUE*
    ...    connection instance
    ...
    ...    Example
    ...    | ${alias} | Get Unique Id |
    ...    | Connect To DCAP  | alias=${alias}   |
    ...    | ${out} | issh.Execute | command=ls -l |
    ...    | Close Interactive Connection  | alias=${alias}   |
    ...
    issh.Connect_To   ip=${DCAP_IP}
      ...   username=${DCAP_USER}
      ...   password=${DCAP_PASSWORD}
      ...   prompt=\\[dcapuser@dcap20\\s\\S+\\]\\$|bash-\\d\\.\\d\\$\\s|\\[dcapuser@\\S+\\d+\\s\\S\\s*\\S*\\]$
      ...   alias=${alias}
      ...   width=200


Connect To DCAP TLS
    [Arguments]  ${alias}=default
    [Documentation]    Connect To DCAP TLS(Commercial)
    ...    *AUTHOR* huilin.xu@nokia-sbell.com
    ...    history change: <date>,<who>,<what and how>
    ...    23.11.2022,chris.l.cao@nokia-sbell.comm, update KW example
    ...
    ...    |  Input Parameters | Man. | Description |
    ...    | alias  |  no | aliase name, default value is default |
    ...
    ...    *RETURN VALUE*
    ...    connection instance
    ...
    ...    Example
    ...    | ${alias} | Get Unique Id |
    ...    | Connect To DCAP TLS  | alias=${alias}   |
    ...    | ${out} | issh.Execute | command=ls -l |
    ...    | Close Interactive Connection  | alias=${alias}   |
    ...
    issh.Connect_To   ip=${DCAP_IP_TLS}
      ...   username=${DCAP_USERNAME_TLS}
      ...   password=${DCAP_PASSWORD_TLS}
      ...   prompt=\\[dcapuser@dcap\\S+\\s\\S+\\]\\$|bash-\\d\\.\\d\\$\\s
      ...   alias=${alias}
      ...   width=200


Connect To Sherpa Server
    [Arguments]  ${connection}=default  ${info_index}=0
    [Documentation]    Connect To Sherpa Server
    ...    *AUTHOR* hongyuan.sun@nokia-sbell.com
    ...    |  Input Parameters | Man. | Description |
    ...    |  alias  |  no  | aliase name, default value is default |
    ...    |  info_index  |  no  | select Sherpa Server info |
    ...
    ...    *RETURN VALUE*
    ...    connection instance
    ...
    ...    Example
    ...    | Connect To Sherpa Server          |
    ...    | ${out} | tafssh.Execute | command=dir  | connection=default |
    ...    | Disconnect From K8s Master   | connection=default |

    ${Sherpa_info}  get_all_Sherpa_server
    ${hostname}  set variable  ${Sherpa_info[${info_index}]["hostname"]}
    ${username}  set variable  ${Sherpa_info[${info_index}]["username"]}
    ${password}  set variable  ${Sherpa_info[${info_index}]["password"]}
    tafssh.connect to
    ...   hostname=${hostname}
    ...   username=${username}
    ...   password=${password}
    ...   alias=${connection}


Disconnect From FHGW
    [Arguments]    ${alias}=default
    issh.disconnect   alias=${alias}


vDU Cluster Login With Admin
    [Arguments]  ${vdu_index}=0  ${gnb_index}=0
    # ${conn}=  helm.helm_master_connect  ${VDU_1_MASTER_NODE_SSH_IP}  22  ${VDU_1_MASTER_NODE_SSH_USER_NAME}  ${VDU_1_MASTER_NODE_SSH_PASSWORD}
    ${conn}=  helm.helm_master_connect
    ...  ${tl.gnbs[${gnb_index}].dus[${vdu_index}].cloud_deployment.cloud_hosting.master_node.k8s_connection_details.ip_addr}
    ...  ${tl.gnbs[${gnb_index}].dus[${vdu_index}].cloud_deployment.cloud_hosting.master_node.k8s_connection_details.port}
    ...  ${tl.gnbs[${gnb_index}].dus[${vdu_index}].cloud_deployment.cloud_hosting.master_node.k8s_connection_details.username}
    ...  ${tl.gnbs[${gnb_index}].dus[${vdu_index}].cloud_deployment.cloud_hosting.master_node.k8s_connection_details.password}
    [Return]   ${conn}

vDU Cluster Login With Tenant
    [Arguments]  ${vdu_index}=0  ${gnb_index}=0
    [Documentation]   Connect to vdu cluster with tenant
    ...    author: lingting.sun@nokia-sbell.com
    ...    modified by:  lingting.sun@nokia-sbell.com  <08-04-2022>, <lingtsun>, <add the doc accroding to code rule>
    ...    | Input Parameters | Man. | Description |
    ...    | gnb_index  | no |  gnb index  |
    ...    | vdu_index  | no |  vdu index  |
    ...    *RETURN VALUE*
    ...    connection session
    ...
    ...    Example
    ...    |  vDU Cluster Login With Tenant |
    # ${conn}=    helm.helm_master_connect    ${VDU_1_MASTER_NODE_SSH_IP}    22    ${VDU_1_TENANT_SSH_USER_NAME}    ${VDU_1_TENANT_SSH_PASSWORD}
    ${conn}=    helm.helm_master_connect
    ...  ${tl.gnbs[${gnb_index}].dus[${vdu_index}].cloud_deployment.cloud_hosting.master_node.ssh_connection_details.addr}
    ...  22
    ...  ${tl.gnbs[${gnb_index}].dus[${vdu_index}].cloud_deployment.cloud_hosting.master_node.ssh_connection_details.username}
    ...  ${tl.gnbs[${gnb_index}].dus[${vdu_index}].cloud_deployment.cloud_hosting.master_node.ssh_connection_details.password}
    [Return]   ${conn}


====== VCU SSH Command Begin ======
     Log To Console  \n*** only used for readable ***


Connect To CU K8S Master With Admin
    [Arguments]  ${gnb_index}=0  ${timeout}=150  ${width}=${None}
    [Documentation]    connect to CU K8S cluster with admin permission
    ...  author:            calla.wang@nokia-sbell.com
    ...  modified by:        <06-23-2021>, <calwang>, <initial created>
    ...    history change: <date>,<who>,<what and how>
    ...    23.6.2020,calla.wang@nokia-sbell.comm, initialized version
    ...    9.7.2021,chris.l.cao@nokia-sbell.com, add support for cbis-admin user
    ...    14.7.2021,chris.l.cao@nokia-sbell.com, enhancement for root user
    ...    7.3.2022,hongyuan.sun@nokia-sbell.com, add parameter timeout
    ...    22.3.2022,hongyuan.sun@nokia-sbell.com, add support for cranuser user
    ...    18.2.2023,chris.l.cao@nokia-sbell.com, remove cbis-admin prompt
    ...
    ...    | Input Parameters | Man. | Description |
    ...    | gnb_index | No. | the gnb index, default value is 0. |

    ...    *RETURN VALUE*
    ...    the connection alias used to execute command later.
    ...
    ...    Example
    ...    |  Connect To CU K8S Master With Admin  |
    ...
    ${host_ip}=  Set Variable  ${tl.gnbs[${gnb_index}].cloud_deployment.cloud_hosting.master_node.k8s_connection_details.ip_addr}
    ${username}=  Set Variable   ${tl.gnbs[${gnb_index}].cloud_deployment.cloud_hosting.master_node.k8s_connection_details.username}
    ${password}=  Set Variable  ${tl.gnbs[${gnb_index}].cloud_deployment.cloud_hosting.master_node.k8s_connection_details.password}

    ${prompt}  set variable   \\[root@\\S+\\s\\S+\\s+\\S+\\]\\#|\\[root@\\S+\\s\\S+\\]\\#
    ${prompt}  Set Variable  ${prompt}|\\[core@\\S+\\s\\S+\\]\\$
    ${prompt}  Set Variable  ${prompt}|\\[cranuser\\d+@\\S+\\s\\S+\\]\\$

    ${alias}=  get unique id
    issh.Connect_To
    ...   ip=${host_ip}
    ...   username=${username}
    ...   password=${password}
    ...   prompt=${prompt}
    ...   timeout=${timeout}
    ...   alias=${alias}
    ...   width=${width}
    [Return]  ${alias}


Connect To CU K8S Master With Tenant
    [Arguments]  ${gnb_index}=0   ${width}=${None}   ${timeout}=300
    [Documentation]    connect to CU K8S cluster with tenant permission
    ...  author:            calla.wang@nokia-sbell.com
    ...  modified by:        <06-23-2021>, <calwang>, <initial created>
    ...    history change: 29.9.2021,chris.l.cao@nokia-sbell.com, set more strict prompt
    ...
    ...    | Input Parameters | Man. | Description |
    ...    | gnb_index | No. | the gnb index, default value is 0. |

    ...    *RETURN VALUE*
    ...    the connection alias used to execute command later.
    ...    Example
    ...    |  Connect To CU K8S Master With Admin  |    |
    ${host_ip}=  Set Variable  ${tl.gnbs[${gnb_index}].cloud_deployment.cloud_hosting.master_node.ssh_connection_details.addr}
    ${username}=  Set Variable   ${tl.gnbs[${gnb_index}].cloud_deployment.cloud_hosting.master_node.ssh_connection_details.username}
    ${password}=  Set Variable  ${tl.gnbs[${gnb_index}].cloud_deployment.cloud_hosting.master_node.ssh_connection_details.password}

#    ${prompt}    Set Variable   \\[cranuser\\d+@\\S+\\s+\\S+\\s+\\S+\\]\\$
#    ${prompt}    Set Variable   ${prompt}|\\[cranuser\\d+@\\S+\\s+\\S+\\]\\$
    ${prompt}  set variable   ${VCU_OE_SERVER_PROMPT_TENANT}|${VCU_CONTAINER_PROMPT}|\\[${username}@.*\\]\\$

    ${alias}=  utils.get unique id
    issh.Connect_To
    ...   ip=${host_ip}
    ...   username=${username}
    ...   password=${password}
    ...   prompt=${prompt}
    ...   width=${width}
    ...   alias=${alias}
    ...   timeout=${timeout}
    [Return]  ${alias}


Connect To VCU Container With Tenant Interactively
    [Arguments]  ${pod_abbr}=${EMPTY}   ${ctr_abbr}=${EMPTY}     ${gnb_index}=0
    [Documentation]  Connect To VCU Container With Tenant Interactively
    ...  history change:
    ...  author:chris.l.cao@nokia-sbell.com
    ...   14.4.2022,chris.l.cao@nokia-sbell.com, initilization
    ...
    ...    | Input Parameters | Man. | Description |
    ...    | pod_abbr | No. | the pod name abbreviation, do not give the full pod name. such as oamcm |
    ...    | ctr_abbr | Yes. | the container name abbreviation. such as oamagent, oamcm |
    ...    | gnb_index | No. | the gnb index, default value is 0. |
    ...
    ...    *RETURN VALUE*
    ...     the alias that connected to the container
    ...
    ...    Example
    ...    | ${alias} | Connect To VCU Container With Tenant Interactively | ctr_abbr=oamagent |
    ...    | ${out} | issh.Execute | command=date | alias=${alias} |
    ...    | Close Interactive Connection  | alias=${alias} |
    ...
    ...    | ${alias} | Connect To VCU Container With Tenant Interactively | pod_abbr=oamext | ctr_abbr=nwmgmt |
    ...    | ${out} | issh.Execute_Bare | command=date | alias=${alias}  |
    ...    | ${out} | issh.Execute_Bare | command=\r | alias=${alias}  |
    ...    | Close Interactive Connection    | alias=${alias} |
    ...
    ${alias}  Wait Until Keyword Succeeds   20x   3   _Connect To VCU Container With Tenant Interactively Once
       ...   pod_abbr=${pod_abbr}   ctr_abbr=${ctr_abbr}     gnb_index=${gnb_index}
    [Return]  ${alias}


_Connect To VCU Container With Tenant Interactively Once
    [Arguments]  ${pod_abbr}=${EMPTY}   ${ctr_abbr}=${EMPTY}    ${gnb_index}=0
    [Teardown]  Run Keyword And Ignore Error    Run Keyword If   "${login_container_flag}"=="0"
    ...  Close Interactive Connection  alias=${alias}
    [Documentation]  _Connect To VCU Container With Tenant Interactively Once
    ...  history change:
    ...  author:chris.l.cao@nokia-sbell.com
    ...   14.4.2022,chris.l.cao@nokia-sbell.com, initilization
    ...
    ...    | Input Parameters | Man. | Description |
    ...    | pod_abbr | No. | the pod name abbreviation, do not give the full pod name. such as oamcm |
    ...    | ctr_abbr | Yes. | the container name abbreviation. such as oamagent, oamcm |
    ...    | gnb_index | No. | the gnb index, default value is 0. |
    ...
    ...    *RETURN VALUE*
    ...    the alias that connected to the container
    ...
    ${login_container_flag}   Set Variable   0

    ${alias}    Connect To CU K8S Master With Tenant   gnb_index=${gnb_index}

    ${ns}   Get CU Namespace From Testline     gnb_index=${gnb_index}

    ${pod_abbr}   Run Keyword If   "${pod_abbr}"=="${EMPTY}"  Get Pod Abbreviation By Container Abbreviation For CU   container_abbr=${ctr_abbr}
    ...   ELSE  Set Variable  ${pod_abbr}

    ${container_full_name}     Get CU Full Container Name By Container Abbreviation   ctr_abbr=${ctr_abbr}
    ${pod_full_name}  Get CU Full Pod Name By Pod Abbreviation   pod_abbr=${pod_abbr}   alias=${alias}   gnb_index=${gnb_index}

    ${kubectl_cmd}   Set Variable    kubectl exec -it ${pod_full_name} -c ${container_full_name} -n ${ns} -- bash
    ${out}   issh.Execute    command=${kubectl_cmd}   check_result=${False}   alias=${alias}

    Should Match Regexp   ${out}   ${VCU_CONTAINER_PROMPT}
    Sleep  0.5
    ${login_container_flag}   Set Variable   1
    [Return]  ${alias}


Connect To CU Node
    [Arguments]  ${pod_abbr}=oamcm   ${gnb_index}=0
    [Documentation]    connect to CU node which the pod located.
    ...  author:            calla.wang@nokia-sbell.com
    ...  modified by:        <06-23-2021>, <calwang>, <initial created>
    ...    history change: 14.7.2021,chris.l.cao@nokia-sbell.com, add support to cbis-admin user
    ...
    ...    | Input Parameters | Man. | Description |
    ...    | pod_abbr | Yes. | the pod name abbreviation, do not give the full pod name. |
    ...    | gnb_index | No. | the gnb index, default value is 0. |

    ...    *RETURN VALUE*
    ...    the cluster connection alias used to execute command later.
    ...    Example
    ...    |  Connect To CU Node  | oamcm |
    ${master_conn_alias}=   Connect To CU K8S Master With Admin  ${gnb_index}
    ${master_node_hostname}  Get Host Name   alias=${master_conn_alias}
    ${pod_located_node}=   Get CU Pod Located Node  ${pod_abbr}  ${master_conn_alias}  ${gnb_index}
    ${ssh_command}  Set Variable  ssh -o StrictHostKeyChecking=no ${pod_located_node}

    ${old_prompt}   issh.Get Prompt   alias=${master_conn_alias}
    ${new_prompt}  set variable   ${old_prompt}|assword:
    issh.Set Prompt   ${new_prompt}  alias=${master_conn_alias}

    ${out}   issh.Execute  command=${ssh_command}  check_result=${False}  alias=${master_conn_alias}

    issh.Set Prompt   ${old_prompt}  alias=${master_conn_alias}

    run keyword if   "assword:" in """${out}"""   issh.Execute
    ...   command=${tl.gnbs[${gnb_index}].cloud_deployment.cloud_hosting.master_node.k8s_connection_details.password}
    ...   check_result=${False}  alias=${master_conn_alias}

    ${pod_node_hostname}  Get Host Name   alias=${master_conn_alias}
    ${out}  Run Keyword If  "${master_node_hostname}"=="${pod_node_hostname}"   issh.Execute  command=exit   alias=${master_conn_alias}
    [Return]  ${master_conn_alias}


Connect To CU Container
    [Arguments]  ${pod_abbr}   ${container}   ${alias}=default   ${check_result}=${True}  ${gnb_index}=0
    [Documentation]  Connect to CU container
    ...  author:            lingting.usn@nokia-sbell.com
    ...  modified by:       <08-16-2021>, <lingtsun>, <initial created>
    ...    history change: <date>,<who>,<what and how>
    ...   27.6.2023,chris.l.cao@nokia-sbell.com, remove 'Get vCU Platform Name' to solove testline config compatibility problem
    ...
    ...    | Input Parameters | Man. | Description |
    ...    | pod_abbr | Yes. | the pod name abbreviation, do not give the full pod name. such as oamcm |
    ...    | container | Yes. | the container name abbreviation. such as oamcm |
    ...    | alias | Yes. | the alias that connected to the CU cluster. |
    ...    | gnb_index | No. | the gnb index, default value is 0. |
    ...
    ...    *RETURN VALUE*
    ...    the command output
    ...  *Example*
    ...    | ${alisa}= | Connect To CU K8S Master With Admin  |  |
    ...    | ${output}= | Connect To CU Container | oamcm | oamcm | date | ${alias} |
    ...    | Close Interactive Connection | ${alias} |
    ...
#    ${platform}=   Get vCU Platform Name
#    run keyword if  "${platform}"=="NCS" or "${platform}"=="OCP"  _Connect To CU Container NCS And OCP
#    ...    pod_abbr=${pod_abbr}   container=${container}   alias=${alias}
#    ...    check_result=${check_result}  gnb_index=${gnb_index}
    _Connect To CU Container NCS And OCP
    ...    pod_abbr=${pod_abbr}   container=${container}   alias=${alias}
    ...    check_result=${check_result}  gnb_index=${gnb_index}


vCU Cluster helm Login With Tenant
    [Arguments]  ${gnb_index}=0
     [Documentation]    helm connect to CU cluster with tenant permission
    ...  author:            luofei.tu@nokia-sbell.com
    ...  modified by:        <07-12-2021>, <luofei.tu>, <initial created>
    ...    | Input Parameters | Man. | Description |
    ...    | gnb_index | No. | the gnb index, default value is 0. |

    ...    *RETURN VALUE*
    ...    the connection alias used to execute command later.
    ...    Example
    ...    |  vCU Cluster helm Login With Tenant  |    |
    ${conn}=    helm.helm_master_connect
    ...  ${tl.gnbs[${gnb_index}].cloud_deployment.cloud_hosting.master_node.ssh_connection_details.addr}
    ...  22
    ...  ${tl.gnbs[${gnb_index}].cloud_deployment.cloud_hosting.master_node.ssh_connection_details.username}
    ...  ${tl.gnbs[${gnb_index}].cloud_deployment.cloud_hosting.master_node.ssh_connection_details.password}
    [Return]   ${conn}


CU Kubectl Exec
    [Arguments]  ${pod_abbr}=${EMPTY}    ${container}=${EMPTY}    ${command}=${EMPTY}
       ...   ${alias}=default   ${gnb_index}=0
    [Documentation]  execute kubectl exec command in CU cluster
    ...  author:            calla.wang@nokia-sbell.com
    ...  modified by:       <06-23-2021>, <calwang>, <initial created>
    ...    26.7.2021,chris.l.cao@nokia-sbell.com, add sudo for cbis-admin user
    ...    28.1.2022,chris.l.cao@nokia-sbell.com, add support without pod_abbr parameter
    ...    12.1.2023, rui.3.li@nokia-sbell.com, execute cmd in container.
    ...    6.2.2023, rui.3.li@nokia-sbell.com, exit in teardown.
    ...    16.2.2023, rui.3.li@nokia-sbell.com, increase judgment on exit in teardown
    ...
    ...    | Input Parameters | Man. | Description |
    ...    | pod_abbr | Yes. | the pod name abbreviation, do not give the full pod name. |
    ...    | container | Yes. | the container name abbreviation. |
    ...    | command | Yes. | the command need to be executed. |
    ...    | alias | Yes. | the alias that connected to the CU cluster. |
    ...    | gnb_index | No. | the gnb index, default value is 0. |

    ...    *RETURN VALUE*
    ...    the command output
    ...
    ...  *Example*
    ...    | ${alias}  | Connect To CU K8S Master With Admin  |  |
    ...    | ${output} | CU Kubectl Exec | container=oamcm    | command=date | alias=${alias} |
    ...    | ${output} | CU Kubectl Exec | container=oamagent | command=date | alias=${alias} |
    ...    | ${output} | CU Kubectl Exec | pod_abbr=oamext | container=nwmgmt | command=ls | alias=${alias} |
    ...    | Close Interactive Connection | ${alias} |
    ...
    ${sudo_outer}  Get VCU Sudo For Current User   alias=${alias}
    ${old_prompt}    issh.get_prompt  alias=${alias}
    Connect To CU Container   ${pod_abbr}    container=${container}   alias=${alias}   gnb_index=${gnb_index}   check_result=${False}
    ${out}   issh.Execute    command=${command}   check_result=${False}   alias=${alias}
    ${out}   strip prompt  ${out}
    sleep   0.5
    ${command_test_result}    issh.Execute    command=kubectl   check_result=${False}   alias=${alias}
    [Return]  ${out}
    [Teardown]    Run Keyword If   """command not found""" in """${command_test_result}"""   Run Keywords   issh.set_prompt
    ...   ${old_prompt}    alias=${alias}  AND
    ...   issh.Execute   command=exit   check_result=${False}   alias=${alias}


Get Pod Abbreviation By Container Abbreviation For CU
    [Arguments]    ${container_abbr}
    [Documentation]   Get Pod Abbreviation By Container Abbreviation For CU
    ...    *AUTHOR* chris.l.cao@nokia-sbell.com
    ...    history change: <date>,<who>,<what and how>
    ...   28.1.2022,chris.l.cao@nokia-sbell.com, initialization
    ...
    ...    |  Input Parameters | Man. | Description |
    ...    | container_abbr    |  No | container_abbr, eg, oamfh, l1hi |
    ...
    ...    *RETURN VALUE*
    ...   CU pod abbreviation, e.g, oamext, cpif, upue.
    ...
    ...    Example
    ...    | ${pod_abbr} | Get Pod Abbreviation By Container Abbreviation For CU | container_abbr=oamagent |
    ...
    ${container_prefix}  Get CU Container Name Prefix
    ${start_with_prefix}   set variable  ${container_abbr.startswith("${container_prefix}")}
    ${container_abbr}  run keyword if   "${start_with_prefix}"=="${True}"   set variable  ${container_abbr.replace("${container_prefix}","")}
        ...   ELSE   set variable    ${container_abbr}

    ${vcu_pods_and_abbreviated_containers_mapping}    get_vcu_pods_and_abbreviated_containers_mapping
    ${pod_keys}   Evaluate    list(${vcu_pods_and_abbreviated_containers_mapping})

    ${pod_abbr}   set variable   ${EMPTY}
    :FOR   ${pod}  IN   @{pod_keys}
    \    ${containers_list}    set variable    ${vcu_pods_and_abbreviated_containers_mapping["${pod}"]}
    \    ${number}   Collections.Count Values In List   ${containers_list}    ${container_abbr}
    \    run keyword if   ${number}>=2   Fail   There are two container whose names are same !
    \    Return From keyword if   ${number}==1   ${pod}

    [Return]  ${pod_abbr}


_Connect To CU Container NCS And OCP
    [Arguments]  ${pod_abbr}   ${container}   ${alias}=default   ${check_result}=${True}  ${gnb_index}=0
    [Documentation]  Internal KW for Connect to CU container (NCS and OCP supported)
    ...  author:            lingting.usn@nokia-sbell.com
    ...  modified by:       <08-16-2021>, <lingtsun>, <initial created>
	...  modified by:       <03-10-2022>, <lijuwang>, <update>
	...  modified by:       <02-09-2023>, <r3li>, <update>
    ...
    ...    | Input Parameters | Man. | Description |
    ...    | pod_abbr | Yes. | the pod name abbreviation, do not give the full pod name. such as oamcm |
    ...    | container | Yes. | the container name abbreviation. such as oamcm |
    ...    | alias | Yes. | the alias that connected to the CU cluster. |
    ...    | gnb_index | No. | the gnb index, default value is 0. |

    ...    *RETURN VALUE*
    ...    the command output
    ${ns}   Get CU Namespace From Testline  ${gnb_index}
    ${cu_full_container_name}  Get CU Full Container Name By Container Abbreviation  ${container}
    ${cu_full_pod_name}=  Get CU Full Pod Name By Pod Abbreviation  ${pod_abbr}  ${alias}  ${gnb_index}
    ${sudo_outer}  Get VCU Sudo For Current User   alias=${alias}
#    ${kubectl_cmd}   Set Variable   ${sudo_outer} kubectl exec -it ${cu_full_pod_name} -c ctr-${ns}-${cu_full_container_name} -n ${ns} -- bash
    ${kubectl_cmd}   Set Variable   ${sudo_outer} kubectl exec -it ${cu_full_pod_name} -c ctr-${cu_full_container_name} -n ${ns} -- bash
    ${old_prompt}=    issh.get_prompt    alias=${alias}
	${out}   issh.set_prompt   ${old_prompt}|bash-\\d\\.\\d\\$\\s    alias=${alias}
    ${new_prompt}=    issh.get_prompt    alias=${alias}
    ${out}   wait until keyword succeeds  3x  10s  issh.Execute    command=${kubectl_cmd}   check_result=${check_result}
    ...   alias=${alias}
    [Return]  ${out}


CU SSH To OAM
    [Arguments]    ${gnb_index}=${0}    ${alias}=default
    [Documentation]    Connect to cloud CU OAM VM. addr, username, password are from testline_configuration.
    ...  author:             fen.huang@nokia-sbell.com
    ...  modified by:        <15-May-2020>, <f2huang>, <initial created>
    ...    | Input Parameters | Man. | Description |
    ...    |  gnb_index  | No |  gnb index to indicate which gnb will be used |
    ...    |  alias  | No |  connection alias  |
    ...
    ...    *RETURN VALUE*
    ...    None
    ...    Example
    ...    | CU SSH To OAM  |    |
    ${gnbs}    tl_info.get_cloudbts_gnbs    ${tl}
    ${count_of_gnb}=  get length   ${gnbs}
    Run Keyword If    ${count_of_gnb}>=1 and "${gnbs[${gnb_index}].cu.oam_ssh_connection_details.username}"=="serviceuser"
    ...     _CU SSH To OAM With Username Serviceuser   ${gnb_index}    ${alias}
    ...     ELSE IF  ${gnbs}   issh.Connect to      ip=${gnbs[${gnb_index}].cu.oam_ssh_connection_details.addr}
    ...                                             username=${gnbs[${gnb_index}].cu.oam_ssh_connection_details.username}
    ...                                             password=${gnbs[${gnb_index}].cu.oam_ssh_connection_details.password}
    ...                                             prompt=$
    ...                                             timeout=20
    ...                                             alias=${alias}
    ...      ELSE    Fail    There is no CloudBts in testline.
    issh.set prompt   \[\w+@[A-Za-z0-9-:\/]+\]   alias=${alias}
    ${output}=  issh.execute  hostname  check_result=${False}  alias=${alias}
    ${output}=  Convert to lowercase  ${output}
    should contain   ${output}   oam   ssh to oam vm failed!
    [Return]   ${alias}

_CU SSH To OAM With Username Serviceuser
    [Arguments]    ${gnb_index}=${0}    ${alias}=default
    [Documentation]    Connect to OAM VM with account serviceuser.
    ...  author:             fen.huang@nokia-sbell.com
    ...  modified by:        <15-May-2020>, <f2huang>, <initial created>
    ...    | Input Parameters | Man. | Description |
    ...    |  gnb_index  | No |  gnb index to indicate which gnb will be used |
    ...    |  alias  | No |  connection alias  |
    ...    *RETURN VALUE*
    ...    None
    ...    Example
    ...    | _CU SSH To OAM With Username Serviceuser  |  ${0}  |  oam  |
    ${gnbs}    tl_info.get_cloudbts_gnbs    ${tl}
    issh.Connect to    ip=${gnbs[${gnb_index}].cu.oam_ssh_connection_details.addr}
    ...                port=22
    ...                username=${gnbs[${gnb_index}].cu.oam_ssh_connection_details.username}
    ...                password=${gnbs[${gnb_index}].cu.oam_ssh_connection_details.password}
    ...                prompt=>
    ...                timeout=60
    ...                alias=${alias}
    issh.set prompt   assword:    alias=${alias}
    issh.Execute  command=set user username toor4nsn   check_result=${False}  alias=${alias}
    issh.set prompt   \\#   alias=${alias}
    issh.Execute   command=oZPS0POrRieRtu  check_result=${False}  alias=${alias}

    issh.set prompt   >      alias=${alias}
    issh.Execute  command=fsclish   check_result=${False}  alias=${alias}
    issh.Execute  command=set user-management configuration account fallback-deny no   check_result=${False}  alias=${alias}
    issh.set prompt   \\[root@.+-(oam|OAM)-\\d+:.+\\]       alias=${alias}
    issh.Execute  command=exit  check_result=${False}   alias=${alias}

CU SSH To CPIF
    [Arguments]    ${gnb_index}=${0}  ${vm_index}=${0}   ${alias}=default
    [Documentation]    Create ssh connection to CPIF VM.
    ...  author:             fen.huang@nokia-sbell.com
    ...  modified by:        <20-May-2020>, <f2huang>, <initial created>
    ...    | Input Parameters | Man. | Description |
    ...    |  gnb_index  | No |  Indicate which gnb/cu will be used, 0 in default |
    ...    |  vm_index   | No |  Indicate which vm will be used, 0 in default |
    ...    |  alias  | No |  connection alias  |
    ...
    ...    *RETURN VALUE*
    ...    None
    ...    Example
    ...    | CU SSH To CPIF |  1  |  0  |
    ${alias}=  _CU SSH To VM   ${gnb_index}   cpif    ${vm_index}   alias=${alias}
    [Return]  ${alias}

_CU SSH To VM
    [Arguments]    ${gnb_index}  ${vm_type}  ${vm_index}   ${alias}=default
    [Documentation]    Create ssh connection to UPUE VM.
    ...  author:             fen.huang@nokia-sbell.com
    ...  modified by:        <14-May-2020>, <f2huang>, <initial created>
    ...    | Input Parameters | Man. | Description |
    ...    |  gnb_index  | Yes |  Indicate which gnb/cu will be used, 0 in default |
    ...    |  vm_type    | Yes |  vm type, can be cpif,cpcl,cpnb,cpnrt,cpue,db and upue |
    ...    |  vm_index   | Yes |  Indicate which vm will be used, 0 in default |
    ...    |  alias  | No |  connection alias  |
    ...
    ...    *RETURN VALUE*
    ...    None
    ...
    ...    Example
    ...    | _CU SSH To VM |  0  |  cpif  |   0  |
    ${alias}=   CU SSH To OAM   ${gnb_index}   alias=${alias}
    ${gnbs}    tl_info.get_cloudbts_gnbs    ${tl}
    ${hostname} =    Set Variable     ${vm_type}-${vm_index}.local
    issh.execute    command=ssh ${hostname}   check_result=${False}  alias=${alias}
   # issh.set prompt   ]   alias=${alias}

    issh.set prompt   \\[root@\\S+:\\S+\\]   alias=${alias}
    ${output}=  issh.execute  hostname  check_result=${False}  alias=${alias}
    ${output}=   convert to lowercase   ${output}
    should contain   ${output}   ${vm_type}   ssh to vm ${vm_type} ${vm_index} failed!
    [Return]  ${alias}

====== VCU SSH Command End ======
     Log To Console  \n*** only used for readable ***


Close Interactive Connection
    [Arguments]  ${alias}=default
    [Documentation]   Close Interactive Connection for specifical connection identified by alias name
    ...   *Author*:chris.l.cao@nokia-sbell.com
    ...   *History Change*:
    ...   | date | who | what and how |
    ...   | 2022-02-15 | chris.l.cao@nokia-sbell.com | add WA for https://jiradc.ext.net.nokia.com/browse/RCP-2176
    ...                                          When this jira is solved, this WA can be removed. |
    ...   | 2022-03-31 | r3li | update documentation |
    ...   *Argument Description*
    ...   | Input Parameters | Man. | Description |
    ...   | alias | No | alias, default value is default |
    ...
    ...    *RETURN VALUE*
    ...    None.
    ...
    ...    Example
    ...    | Connect To K8s Master Interactively |
    ...    | ${out} | issh.Execute | command=pwd |
    ...    | Close Interactive Connection |
    ...
    ...    | Connect To K8s Master Interactively | alias=alias2 |
    ...    | ${out} | issh.Execute | command=pwd | alias=alias2 |
    ...    | Close Interactive Connection | alias=alias2 |
    ...
    should not be empty   ${alias}

    Run Keyword And Ignore Error   _Exit Container If Necessary   alias=${alias}
    issh.disconnect  alias=${alias}


_Exit Container If Necessary
    [Arguments]  ${alias}
    [Documentation]   _Exit Container If Necessary
    ...    *Author*:chris.l.cao@nokia-sbell.com
    ...    *History Change*:
    ...    | date | who | what and how |
    ...    | 15.2.2022 |chris.l.cao@nokia-sbell.com | initialization WA for https://jiradc.ext.net.nokia.com/browse/RCP-2176 |
    ...    | 8.6.2022 |lingting.sun@nokia-sbell.com | Ootimiztion that return from kw if get prompt failed |
    ...    *Argument Decription*
    ...    | Input Parameters | Man. | Description |
    ...    | alias | yes | alias, default value is default |
    ...    *RETURN VALUE*
    ...    None.
    ...
    ${r}  ${cur_prompt}=    Run Keyword And Ignore Error   issh.get_prompt   alias=${alias}
    Return From Keyword If    '${r}'=='FAIL'
    ${expr_vdu_admin}    Set Variable   "${cur_prompt}"!="${VDU_OE_SERVER_PROMPT}|${VDU_CONTAINER_PROMPT}|${VDU_CONTAINER_PROMPT_ROOT}"
    ${expr_vdu_tenant}   Set Variable   "${cur_prompt}"!="${VDU_OE_SERVER_PROMPT_TENANT}|${VDU_CONTAINER_PROMPT}|${VDU_CONTAINER_PROMPT_ROOT}"
    ${expr_vcu_tenant}   Set Variable   "${cur_prompt}"!="${VCU_OE_SERVER_PROMPT_TENANT}|${VCU_CONTAINER_PROMPT}"
    Return From Keyword If   ${expr_vdu_admin} and ${expr_vdu_tenant} and ${expr_vcu_tenant}
    ${out}    issh.Execute   command=ls  check_result=${False}  alias=${alias}
    ${match}  Get Regexp Matches  ${out}   ${VDU_CONTAINER_PROMPT}|${VDU_CONTAINER_PROMPT_ROOT}|${VCU_CONTAINER_PROMPT}

    ${out}    Run Keyword If   ${match.__len__()}>0    issh.Execute   command=exit  check_result=${False}  alias=${alias}


Get VDU OAM Http Connection Info
    [Arguments]    ${gnb_index}=0     ${vdu_index}=0
    [Documentation]  Get vDU OAM Http Connection Info
     ...   *author*: chris.l.cao@nokia-sbell.com
     ...   *history change*:
     ...   | date | who | what and how |
     ...   | 11.12.2021 | chris.l.cao@nokia-sbell.com | convert robot KW to python KW |
     ...   | 13.9.2022 | rui.3li@nokia-sbell.com | add version judgment |
     ...   | 21.10.2022 | calla | adding restapi_version in the return value |
     ...
     ...    | Input Parameters | Man. | Description |
     ...	| gnb_index | no | gnb_index, default is 0 |
     ...	| vdu_index | no | vdu_index, default is 0 |
     ...
     ...    *RETURN VALUE*
     ...    Dictionary of OAM connection information defined in __init__.py,
     ...           dictionary keys are addr, username, password and port.
     ...    example: {'addr': '1.1.1.1', 'username': 'Nemuadmin', 'password': 'nemuuser', 'port': '443'}
     ...
     ...    Example
     ...    | ${vdu_oam_http_connection_info} | Get vDU OAM Http Connection Info |
     ...    | ${vdu_oam_http_connection_info} | Get vDU OAM Http Connection Info | vdu_index=1 |
     ...
    ${status}  ${restapi_version}  Run Keyword And Ignore Error   _Get VDU Rest Api Version  gnb_index=${gnb_index}
    ${restapi_version}   Set Variable If    '${status}'=='FAIL'    ${VDU_REST_TAF_LIB_SUPPORTED_VERSION[-1]}     ${restapi_version}
    ${addr}    Set Variable    ${tl.gnbs[${gnb_index}].dus[${vdu_index}].oam_http_connection_details.addr}
    ${username}    Set Variable    ${tl.gnbs[${gnb_index}].dus[${vdu_index}].oam_http_connection_details.username}
    ${index}     Get Index From List     ${VDU_REST_TAF_LIB_SUPPORTED_VERSION}     ${restapi_version}
    ${password}    Set Variable If    ${index}>=${4}     Nokia@123
    ...    ${tl.gnbs[${gnb_index}].dus[${vdu_index}].oam_http_connection_details.password}
    ${result}    Create dictionary    addr=${addr}    username=${username}    password=${password}   port=443
    ...  restapi_version=${restapi_version}
    [Return]    ${result}


Get Vcu Oam Http Connection Info
    [Arguments]    ${gnb_index}=0
    [Documentation]  Get VCU OAM Http Connection Info
     ...   *author*: chris.l.cao@nokia-sbell.com
     ...   *history change*:
     ...   | date | who | what and how |
     ...   | 11.12.2021 | chris.l.cao@nokia-sbell.com | convert robot KW to python KW |
     ...   | 13.9.2022 | rui.3li@nokia-sbell.com | add version judgment |
     ...
     ...   | Input Parameters | Man. | Description |
     ...   | gnb_index | no | gnb_index, default is 0 |
     ...
     ...    *RETURN VALUE*
     ...    Dictionary of OAM connection information defined in __init__.py,
     ...    dictionary keys are addr, username, password and port.
     ...    example: {'addr': '1.1.1.1', 'username': 'Nemuadmin', 'password': 'nemuuser', 'port': 8081}
     ...
     ...    Example
     ...    | ${vcu_oam_http_connection_info} | Get VCU OAM Http Connection Info |
     ...    | ${vcu_oam_http_connection_info} | Get VCU OAM Http Connection Info | gnb_index=1 |
     ...
    ${status}  ${restapi_version}  Run Keyword And Ignore Error   VCU Api Version  gnb_index=${gnb_index}
    ${restapi_version}   Set Variable If    '${status}'=='FAIL'    ${VCU_REST_TAF_LIB_SUPPORTED_VERSION[-1]}     ${restapi_version}
    ${addr}    Set Variable    ${tl.gnbs[${gnb_index}].cu.oam_http_connection_details.addr}
    ${username}    Set Variable    ${tl.gnbs[${gnb_index}].cu.oam_http_connection_details.username}
    ${index}     Get Index From List     ${VCU_REST_TAF_LIB_SUPPORTED_VERSION}     ${restapi_version}
    ${password}    Set Variable If    ${index}>=${3}    Nokia@123
    ...    ${tl.gnbs[${gnb_index}].cu.oam_http_connection_details.password}
    ${port}    Set Variable    ${tl.gnbs[${gnb_index}].cu.oam_http_connection_details.port}
    ${result}    Create dictionary    addr=${addr}    username=${username}    password=${password}   port=443
    [Return]    ${result}

Connect To vDU Container
    [Arguments]  ${pod_name}    ${container_name}   ${vdu_index}=0  ${gnb_index}=0
    ${conn}=  vdu_cli.connect_to_container
    ...  ${tl.gnbs[${gnb_index}].dus[${vdu_index}].cloud_deployment.cloud_hosting.master_node.ssh_connection_details.addr}
    ...  ${tl.gnbs[${gnb_index}].dus[${vdu_index}].cloud_deployment.cloud_hosting.master_node.ssh_connection_details.username}
    ...  ${tl.gnbs[${gnb_index}].dus[${vdu_index}].cloud_deployment.cloud_hosting.master_node.ssh_connection_details.password}
    ...  ${pod_name}
    ...  ${container_name}
    [Return]  ${conn}


Connect To BMC
    [Arguments]  ${address}    ${username}    ${password}    ${interface}    ${port}=443    ${name}=None
    [Documentation]  Connect To BMC
    ...  author: tingting.xiao@nokia-sbell.com
    ...  history change: <date>,<who>,<what and how>
    ...  02.11.2023, tingting.xiao@nokia-sbell.com, initialization
    ...
    ...    |  Input Parameters | Man. | Description |
    ...    | address    | yes | BMC interface ip address ie. 127.0.0.1 |
    ...    | port      | no | Port number, Default is 443 |
    ...    | username   | yes | BMC endpoint username |
    ...    | password    | yes | BMC endpoint password for username |
    ...    | name   | no | Name of alias for returned connection. If not provided, this connection becomes default. |
    ...    | interface     | yes | Version of BMC interface (default is AirFrame Redfish RM17),
    ...    Supported versions: ‘redfish_rm_17’, ‘redfish_oe_19’, ‘redfish_oe_20’, ‘redfish_oe_22’ |
    ...
    ...   Example
    ...  | ${connection}  | Connect To BMC |
    ...  | Disconnect from BMC | connection=${connection} |
    ${connection}   bmc.connect_to
    ...    address=${address}
    ...    username=${username}
    ...    password=${password}
    ...    interface=${interface}
    ...    port=${port}
    ...    name=${name}
    [Return]  ${connection}

Disconnect from BMC
    [Arguments]  ${connection}
    [Documentation]  Disconnect from BMC
    ...  author: tingting.xiao@nokia-sbell.com
    ...  history change: <date>,<who>,<what and how>
    ...  02.11.2023, tingting.xiao@nokia-sbell.com, initialization
    ...    | Input Parameters | Man. | Description |
    ...    | connection   | yes | BmcConnection object or if used, string name alias |
    ...   Example
    ...  | ${connection}  | Connect To BMC |
    ...  | Disconnect from BMC | connection=${connection} |
    bmc.disconnect    connection=${connection}


Trigger Specific Pod Abnormal By Patch Error Image
    [Arguments]   ${image_path}   ${full_pod_name}   ${conn}=${EMPTY}
    [Documentation]  Trigger pod abnormal by patch error image, for both vcu and vdu
     ...   *author*:lingting.sun@nokia-sbell.com
     ...   *history change*:
     ...   | date | who | what and how |
     ...   | 1.30.2024 | lingting.sun@nokia-sbell.com | initial created |
     ...
     ...   | Input Parameters | Man. | Description |
     ...   | image_path | no | the path of image param in pod json file, such as /spec/containers/0/image |
     ...   | full_pod_name | no | the full name of pod, such as po po-cran1-oampm-0 |
     ...    *RETURN VALUE*

     ...    Example
     ...    | ${conn}| Connect To CU K8S Master With Tenant |
     ...    | ${full_pod_name} | Get CU Full Pod Name By Pod Abbreviation | pod_abbr=oampm | alias = ${conn} }
     ...    |  ${po_prefix}  ${container_prefix} |  _Set CU Pod And Container Name Prefix |
     ...    | ${image_path} | Get Image Path From Pod Info| ${full_pod_name}  | ${container_prefix}oampm | conn=${conn} |
     ...    | Trigger Specific Pod Abnormal By Patch Error Image | ${image_path} | ${full_pod_name} | conn=${conn} |
     ...
    ${exec_command}   catenate  SEPARATOR=  kubectl patch pods ${full_pod_name} --type=
    ...  'json' -p='[{"op": "replace", "path": "${image_path}","value": "test"}]'
    log to console  ${exec_command}
    ${output}  issh.Execute  command=${exec_command}  alias=${conn}  check_result=${False}
    Should Contain    ${output}    patched


Get Image Path From Pod Info
    [Arguments]   ${full_pod_name}   ${full_container_name}  ${conn}=${EMPTY}
    [Documentation]  Get imaage path from pod json file: kubectl get XXX -o json , for both vcu and vdu
     ...   *author*:lingting.sun@nokia-sbell.com
     ...   *history change*:
     ...   | date | who | what and how |
     ...   | 1.30.2024 | lingting.sun@nokia-sbell.com | initial created |
     ...
     ...   | Input Parameters | Man. | Description |
     ...   | full_pod_name | no | the full name of pod, such as po po-cran1-oampm-0 |
     ...   | full_container_name | no | the full name of contianer, such as ctr po-cran1-oampm|
     ...   | conn | Yes|  SSH session of connection, default is ${EMPTY}|
     ...    *RETURN VALUE*
     ...   image_path, /spec/containers/0/image

     ...    Example
     ...    | ${conn}| Connect To CU K8S Master With Tenant |
     ...    | ${full_pod_name} | Get CU Full Pod Name By Pod Abbreviation | pod_abbr=oampm | alias = ${conn} }
     ...    |  ${po_prefix}  ${container_prefix} |  _Set CU Pod And Container Name Prefix |
     ...    | ${image_path} | Get Image Path From Pod Info| ${full_pod_name}  | ${container_prefix}oampm | conn=${conn} |
     ...
    ${exec_command}=  Set Variable   kubectl get po ${full_pod_name} -o json
    ${output}   issh.Execute  command=${exec_command}  alias=${conn}  check_result=${False}
    ${output}   Strip Prompt  ${output}
    ${image_path}   find_container_image_path    json_data=${output}
    ...  target_value=${full_container_name}
    [Return]   ${image_path}

Process Variable
    [Arguments]    ${variable}
    ${contains_r}    Run Keyword and Return Status  Should Contain  ${variable}    \r
    IF    ${contains_r}
      ${value}    Split And Remove First Line    ${variable}
    ELSE
      Return From Keyword    ${variable}
    END

    [Return]    ${value}[0]

Split And Remove First Line
    [Arguments]    ${text}
    ${lines}=    Split To Lines    ${text}
    Remove From List    ${lines}    0
    [Return]    ${lines}
