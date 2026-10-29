*** Settings ***
Documentation
...   author: cheng xianbiao
...   contact: xianbiao.cheng@nokia-sbell.com

Library           Collections
Library           DateTime
Library           OperatingSystem
Library           Process
Library           Screenshot
Library           String
Library           yaml
Library           XML
Library           Telnet
Library           json
Library           taf.hw.rf_attenuator.attenuator       WITH NAME    att
Library           taf.ue                                WITH NAME    ute_ue
Library           taf.pdu                               WITH NAME    pdu
Library           taf.transport.ssh                     WITH NAME    tafssh
Library           taf.hw.fhgw.cli                       WITH NAME    issh
Library           taf.config.scf                        WITH NAME    scf
Library           taf.analyzer.pdml                     WITH NAME    cpdml
Library           taf.ul.parser.pcap                    WITH NAME    pcap
Library           taf.gnb.oam.commissioning             WITH NAME    commissioning
Library           taf.ul.vdu.helm                       WITH NAME    helm
Library           taf.gnb.oam.coam.cu.interface.cu      WITH NAME    cu
Library           taf.gnb.oam.coam.vdu.interface.Vdu    WITH NAME    vdu
Library           taf.selenium.gnb.oam.coam.vdu         WITH NAME    svdu
Library           taf.selenium.nms.nom                  WITH NAME    nom_selenium
Library           taf.nms.nom                           WITH NAME    nom_rest
Library           taf.cloud.cbam                        WITH NAME    cbam
Library           taf.nms.nsp.nfmp                      WITH NAME    nfmp
Library           taf.collectors.simple                 WITH NAME    simple_collect
Library           taf.collectors.core                   WITH NAME    core_collect
Library           taf.collectors.kubernetes             WITH NAME    kubelog_collect
Library           taf.collectors.docker                 WITH NAME    dockerlog
Library           taf.transport.bmc                     WITH NAME    bmc
Library           taf.nms.netact                        WITH NAME    netact
Library           taf.ul.oam.netact.cm                  WITH NAME    netact_cm
Library           taf.config.testline.info.testline_info.TestlineInfo    WITH NAME    tl_info
Library           ./py_tool/common.py
Library           ./py_tool/vdu_cli.py
Library           ./py_tool/get_csv_data.py
Library           ./py_tool/cu_config_modify.py
Library           ./py_tool/global_variables.py
Library           ./py_tool/scf_netact.py
Resource          fm.robot
Resource          cm.robot
Resource          log.robot
Resource          pm.robot
Resource          swm.robot
Resource          swm_cu_cnf.robot
Resource          ue.robot
Resource          rrm.robot
Resource          trs.robot
Resource          state.robot
Resource          selenium.robot
Resource          variables.robot
Resource          common_pre_post_condition.robot
Resource          common_setup_teardown.robot
Resource          nom.robot
Resource          fhgw.robot
Resource          cbam.robot
Resource          emil.robot
#Resource          ../../../../../../../resources/RAN_PZ_HAZ_34/robot/enb_lte.robot
Resource          x_Tower.robot
Resource          nsp.robot
Resource          cu_cnf.robot
Resource          pcmd.robot
Resource          netact.robot


#Resource          common_pre_post_condition.robot

*** Variables ***
@{IGNORED_ALARM_LIST}


*** Keyword ***
CU Login
    [Arguments]     ${gnb_index}=0   ${solution}=rest   ${alias}=${None}   ${restapi_version}=cuoam_21b
    [Documentation]  Login to CU via rest or webui.
    ...    author: fen.huang@nokia-sbell.com
    ...    modified by:        <13-Nov-2019>, <f2huang>, <Initial creation>
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
    ...   ELSE    CU Webui Login    ${gnb_index}
    [Return]   ${alias}

CU Rest Login
   [Arguments]   ${gnb_index}=0   ${alias}=${None}   ${restapi_version}=cuoam_21b
   [Documentation]  Create rest session to CU.
    ...    author: fen.huang@nokia-sbell.com
    ...    history change: <date>,<who>,<what and how>
    ...  16.9.2021, chris.l.cao@nokia-sbell.com, add to logout before login
    ...
    ...    modified by:        <26-Mar-2020>, <f2huang>, <Initial creation>
    ...    | Input Parameters | Man. | Description |
    ...    |  gnb_index  | No |  gnb index to indicate which gnb will be used  |
    ...    | restapi_version | No | if you use 'get_counter' keyword in CU trunk build, the parameter should be given 'cuoam_21b'
    ...                             other senarios should be use default value - cuoam_21b |
    ...    |  alias | No. | alias that identifies this connection, if the argument is given,
    ...                     the alias must be given to the CU Logout keyword as connection argumument. |
	...
    ...    *RETURN VALUE*
    ...    the connection alias
    ...    Example
    ...    |  CU Rest Login   |    0   |
    ${host}   set variable  ${tl.gnbs[${gnb_index}].cu.oam_http_connection_details.addr}
    run keyword and ignore error  CU Rest Logout
    #${host}   set variable if   ':' in '''${host_ip}'''   [${host_ip}]    ${host_ip}
    cu.connect to    host=${host}
    ...    port=${EMPTY}
    ...    username=${tl.gnbs[${gnb_index}].cu.oam_http_connection_details.username}
    ...    password=${tl.gnbs[${gnb_index}].cu.oam_http_connection_details.password}
    ...    cu_version=${restapi_version}
    ...    secure=${True}
    ...    alias=${alias}
    [Return]  ${alias}


CU Rest Login With Incorrect Password
   [Arguments]   ${gnb_index}=0   ${alias}=${None}   ${restapi_version}=cuoam_21b
   [Documentation]  Create rest session to CU.
    ...    author: hefeng-cookie.qu@nokia-sbell.com
    ...    #modified from KW_ CU Rest Login
    ...    modified by:        <26-Mar-2021>, <f2huang>, <Initial creation>
    ...    | Input Parameters | Man. | Description |
    ...    |  gnb_index  | No |  gnb index to indicate which gnb will be used  |
    ...    | restapi_version | No | if you use 'get_counter' keyword in CU trunk build, the parameter should be given 'cuoam_21b'
    ...                             other senarios should be use default value - cuoam_21b |
    ...    |  alias | No. | alias that identifies this connection, if the argument is given,
    ...                     the alias must be given to the CU Logout keyword as connection argumument. |
	...
    ...    *RETURN VALUE*
    ...    the connection alias
    ...    Example
    ...    |  CU Rest Login   |    0   |
    ${host}   set variable  ${tl.gnbs[${gnb_index}].cu.oam_http_connection_details.addr}
    cu.connect to    host=${host}
    ...    port=${EMPTY}
    ...    username=${tl.gnbs[${gnb_index}].cu.oam_http_connection_details.username}
    ...    password=incorrect
    ...    cu_version=${restapi_version}
    ...    secure=${True}
    ...    alias=${alias}
    [Return]  ${alias}


CU Rest Login With Special Username And Password
   [Arguments]  ${username}  ${password}  ${gnb_index}=0   ${alias}=${None}   ${restapi_version}=cuoam_21b
   [Documentation]  Create rest session to CU.
    ...    author: winnie.su@nokia-sbell.com
    ...    modified by:        <23-08-2021>, <f2huang>, <Initial creation>
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
    ...    Example
    ...    |  CU Rest Login With Special Username And Password  |    username=myuser |    username=myuser   |
    ${host}      Get vCU OAM Ip     gnb_index=${gnb_index}
    cu.connect to    host=${host}
    ...    port=${EMPTY}
    ...    username=${username}
    ...    password=${password}
    ...    cu_version=${restapi_version}
    ...    secure=${True}
    ...    alias=${alias}
    [Return]  ${alias}


CU Webui Login
    [Arguments]    ${gnb_index}
    [Documentation]  Login to CU via WebUI.
    ...    author: fen.huang@nokia-sbell.com
    ...    modified by:        <26-Mar-2020>, <f2huang>, <Initial creation>
    ...    | Input Parameters | Man. | Description |
    ...    |  gnb_index  | No |  gnb index to indicate which gnb will be used  |
    log   Login to CU webui function is not ready!     level=ERROR

CU Logout
    [Arguments]     ${solution}=rest   ${connection}=${None}
    [Documentation]  Teardown login session to CU.
    ...    author: fen.huang@nokia-sbell.com
    ...    modified by:        <22-Nov-2019>, <f2huang>, <Initial creation>
    ...    | Input Parameters | Man. | Description |
    ...    | connection | No. | the connection alias that used in CU login |

    ...    *RETURN VALUE*
    ...    None
    ...    Example
    ...    |  CU Logout |   |
    run keyword if  "${solution}"=="rest"    CU Rest Logout  ${connection}
    ...   ELSE    CU Webui Logout

CU Rest Logout
    [Arguments]  ${connection}=${None}
    [Documentation]  Teardown rest session to CU.
    ...    author: fen.huang@nokia-sbell.com
    ...    modified by:        <26-Mar-2020>, <f2huang>, <Initial creation>
    ...    | Input Parameters | Man. | Description |
    ...    | connection | No. | the connection alias that used in CU login |

    ...    *RETURN VALUE*
    ...    None
    ...    Example
    ...    |  CU Rest Logout |   |
    cu.disconnect   connection=${connection}

CU Webui Logout
      [Documentation]  Logout CU webui.
    ...    author: fen.huang@nokia-sbell.com
    ...    modified by:        <26-Mar-2020>, <f2huang>, <Initial creation>
    ...    | Input Parameters | Man. | Description |
    ...
    ...    |  CU Webui Logout   |     |
    log   Logout CU WebUI function is not ready!   level=ERROR

vDU Login
    [Arguments]  ${login_type}=rest   ${restapi_version}=cuoam_21b   ${vdu_index}=0   ${gnb_index}=0
    [Documentation]  Login to vdu via rest or webem.
    ...    author: calla.wang@nokia-sbell.com
    ...    modified by:        <13-Nov-2019>, <f2huang>, <Initial creation>
    ...    | Input Parameters | Man. | Description |
    ...    | vdu_index | Yes | the index of vdu, default value is 0 |
    ...    |  solution | Yes |  rest or webui, default value is 0 |
    ...
    ...    *RETURN VALUE*
    ...    None
    ...    Example
    ...    |  vDU Login  |     |

    run keyword if  "${login_type}"=="rest"    vDU Rest Login   ${restapi_version}  ${vdu_index}  ${gnb_index}
    ...   ELSE   vDU WebEM Login  ${vdu_index}   ${gnb_index}


vDU Rest Login
    [Arguments]  ${restapi_version}=cuoam_21b  ${vdu_index}=0  ${gnb_index}=0  ${alias}=default
    [Documentation]  login vdu webem.
    ...  history change:
    ...  author:calla.wang@nokia-sbell.com
    ...    history change: <date>,<who>,<what and how>
    ...
    ${oam_httpaddr}   set variable   ${tl.gnbs[${gnb_index}].dus[${vdu_index}].oam_http_connection_details.addr}
    ${oam_web_ip}   set variable if   ':' in '''${oam_httpaddr}'''   [${oam_httpaddr}]    ${oam_httpaddr}
    run keyword and ignore error  vDU Rest Logout   vdu_index=${vdu_index}
    ${vdu_connection}=   Run Keyword If  '${restapi_version}'=='cuoam_21b'  vdu.connect to
    ...  host=${oam_web_ip}
    ...  port=${EMPTY}
    ...  username=${tl.gnbs[${gnb_index}].dus[${vdu_index}].oam_http_connection_details.username}
    ...  password=${tl.gnbs[${gnb_index}].dus[${vdu_index}].oam_http_connection_details.password}
    ...  secure=True
    ...  connection_name=${alias}
    ...  ELSE  vdu.connect to
    ...  host=${oam_web_ip}
    ...  port=8081
    ...  username=${tl.gnbs[${gnb_index}].dus[${vdu_index}].oam_http_connection_details.username}
    ...  password=${tl.gnbs[${gnb_index}].dus[${vdu_index}].oam_http_connection_details.password}


vDU Rest Login With Special Password
    [Arguments]  ${password}=${Empty}  ${restapi_version}=cuoam_21b  ${vdu_index}=0  ${gnb_index}=0  ${alias}=default  ${username}=${EMPTY}
    [Documentation]  login vdu webem with special password
    ...  history change:
    ...  author:winnie.su@nokia-sbell.com
    ...    history change: <date>,<who>,<what and how>
    ...  8.19.2021,winnie.su@nokia-sbell.com,login vdu webEM with special password
    ...  20.10.2021,shubin.Ren@nokia-sbell.com, add username

    ${vdu_oam_http_connection_info}     Get VDU OAM Http Connection Info
    ${oam_httpaddr}   set variable   ${vdu_oam_http_connection_info["addr"]}
    ${oam_web_ip}   set variable if   ':' in '''${oam_httpaddr}'''   [${oam_httpaddr}]    ${oam_httpaddr}
    ${http_username}  Run Keyword If  "${username}"=="${EMPTY}"  set variable  ${vdu_oam_http_connection_info["username"]}
    ...  ELSE  set variable   ${username}
    ${http_password}  Run Keyword If  "${password}"=="${EMPTY}"   Set Variable  ${vdu_oam_http_connection_info["password"]}
    ...  ELSE  set variable   ${password}
    run keyword and ignore error  vDU Rest Logout   vdu_index=${vdu_index}
    sleep  30s
    ${vdu_connection}=   Run Keyword If  '${restapi_version}'=='cuoam_21b'  vdu.connect to
    ...  host=${oam_web_ip}
    ...  port=${EMPTY}
    ...  username=${http_username}
    ...  password=${http_password}
    ...  secure=True
    ...  connection_name=${alias}
    ...  ELSE  vdu.connect to
    ...  host=${oam_web_ip}
    ...  port=8081
    ...  username=${http_username}
    ...  password=${password}

vDU WebEM Login
    [Arguments]   ${vdu_index}=0   ${logout_firstly}=${False}
    [Documentation]  Login to vDU via WebEM.
    ...    author: calla.wang@nokia-sbell.com
    ...    history change: <date>,<who>,<what and how>
    ...    modified by:        <26-Mar-2020>, <f2huang>, <Initial creation>
    ...   07.9.2020,peng.lin@nokia-sbell.com, updat
    ...   11.9.2020,chris.l.cao@nokia-sbell.com, add check VDU OAM Up or Down
    ...   26.10.2021,chris.l.cao@nokia-sbell.com, add ${VDU_WEBEM_LOGIN_INSTANCE_ID} to speed case running time
    ...
    ...    | Input Parameters | Man. | Description |
    ...    |  vdu_index  | Yes | the index of vdu, default value is 0 |

    log to console   \n*** Start vDU webui login  ***

    ${vdu_oam_http_connection_info}   Get VDU OAM Http Connection Info  vdu_index=${vdu_index}
    ${oam_httpaddr}   set variable   ${vdu_oam_http_connection_info["addr"]}
    ${oam_web_ip}   set variable if   ':' in '''${oam_httpaddr}'''   [${oam_httpaddr}]    ${oam_httpaddr}
    ${vdu_oam_url}   Set Variable  https://${oam_web_ip}
    ${username}  set variable  ${vdu_oam_http_connection_info["username"]}
    ${password}  set variable  ${vdu_oam_http_connection_info["password"]}
    run keyword if  "${logout_firstly}"=="${True}"   run keyword and ignore error  vDU WebEM Logout
    wait until keyword succeeds  3x  5s
     ...   svdu.Login   url=${vdu_oam_url}    username=${username}   password=${password}   timeout=${120}

    Set Test Variable   ${VDU_WEBEM_LOGIN_INSTANCE_ID}    vDU WebEM Login is Called.


vDU Logout
    [Arguments]   ${logout_type}=rest   ${alias}=default
    [Documentation]  Teardown login session to CU.
    ...    author: fen.huang@nokia-sbell.com
    ...    modified by:        <22-Nov-2019>, <f2huang>, <Initial creation>
    ...    | Input Parameters | Man. | Description |

    ...    *RETURN VALUE*
    ...    None
    ...    Example
    ...    |  CU Logout |   |
    run keyword if  "${logout_type}"=="rest"    vDU Rest Logout   alias=${alias}
    ...   ELSE    vDU WebEM Logout

vDU Rest Logout
    [Arguments]  ${vdu_index}=0  ${alias}=default
    [Documentation]  vDU Rest Logout
    ...  history change:
    ...  author:calla.wang@nokia-sbell.com
    ...    history change: <date>,<who>,<what and how>
    ...   4.09.2020,chris.l.cao@nokia-sbell.com, add check for OAM up or down
    ...   11.9.2020,chris.l.cao@nokia-sbell.com, change to use 'Wait Until VDU OAM Up'
    ...
    vdu.disconnect  ${alias}


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
    # ${conn}=    helm.helm_master_connect    ${VDU_1_MASTER_NODE_SSH_IP}    22    ${VDU_1_TENANT_SSH_USER_NAME}    ${VDU_1_TENANT_SSH_PASSWORD}
    ${conn}=    helm.helm_master_connect
    ...  ${tl.gnbs[${gnb_index}].dus[${vdu_index}].cloud_deployment.cloud_hosting.master_node.ssh_connection_details.addr}
    ...  22
    ...  ${tl.gnbs[${gnb_index}].dus[${vdu_index}].cloud_deployment.cloud_hosting.master_node.ssh_connection_details.username}
    ...  ${tl.gnbs[${gnb_index}].dus[${vdu_index}].cloud_deployment.cloud_hosting.master_node.ssh_connection_details.password}
    [Return]   ${conn}

Connect To vDU Container
    [Arguments]  ${pod_name}    ${container_name}   ${vdu_index}=0  ${gnb_index}=0
    ${conn}=  connect_to_container
    ...  ${tl.gnbs[${gnb_index}].dus[${vdu_index}].cloud_deployment.cloud_hosting.master_node.ssh_connection_details.addr}
    ...  ${tl.gnbs[${gnb_index}].dus[${vdu_index}].cloud_deployment.cloud_hosting.master_node.ssh_connection_details.username}
    ...  ${tl.gnbs[${gnb_index}].dus[${vdu_index}].cloud_deployment.cloud_hosting.master_node.ssh_connection_details.password}
    ...  ${pod_name}
    ...  ${container_name}
    [Return]  ${conn}


Connect to FHGW
    [Arguments]   ${gnb_index}=0   ${vdu_index}=0   ${fhgw_index}=0     ${alias}=default    ${timeout}=300
    [Documentation]   Connect to FHGW
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
    ...    | Connect to FHGW |
    ...    | ${out} | issh.Execute | command=ls -l |
    ...    | ${out} | issh.Execute | command=ls -l | alias=default |
    ...    | Disconnect From FHGW |
    ...
#    ${fhgw_major_version}   Get FHGW Major Version   gnb_index=${gnb_index}   vdu_index=${vdu_index}   fhgw_index=${fhgw_index}
#    ${alias}   Run Keyword If   "${fhgw_major_version}"=="FHGW21A" or "${fhgw_major_version}"=="FHGW21B"    _Connect to FHGW_21
#     ...        gnb_index=${gnb_index}   vdu_index=${vdu_index}   fhgw_index=${fhgw_index}  alias=${alias}   timeout=${timeout}
#     ...   ELSE   _Connect to FHGW22R1
#     ...        gnb_index=${gnb_index}   vdu_index=${vdu_index}   fhgw_index=${fhgw_index}  alias=${alias}   timeout=${timeout}
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

    ${prompt}   Set Variable If   '${username}' == '_nokfhgwoperator'    \\[root@controller\\(FHGW.*\\).*\\]
    ...    \\[toor4nsn@controller\\(FHGW-\\d+\\)\\s\\S+\\][\\r\\n]+#

    issh.set_prompt     ${prompt}   alias=${alias}
    ${res}  run keyword if  '${username}' == '_nokfhgwoperator'    issh.Execute    ${password_2nd}     alias=${alias}


    [Return]  ${alias}


Connect to FHGW Gracefully
    [Arguments]   ${gnb_index}=0   ${vdu_index}=0   ${fhgw_index}=0     ${alias}=default    ${timeout}=300
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
    ...    | Connect to FHGW |
    ...    | ${out} | issh.Execute | command=ls -l |
    ...    | ${out} | issh.Execute | command=ls -l | alias=default |
    ...    | Disconnect From FHGW |
    ...
#    ${fhgw_major_version}   Get FHGW Major Version   gnb_index=${gnb_index}   vdu_index=${vdu_index}   fhgw_index=${fhgw_index}
#    ${alias}   Run Keyword If   "${fhgw_major_version}"=="FHGW21A" or "${fhgw_major_version}"=="FHGW21B"   _Connect to FHGW Gracefully FHGW_21
#     ...        gnb_index=${gnb_index}   vdu_index=${vdu_index}   fhgw_index=${fhgw_index}  alias=${alias}   timeout=${timeout}
#     ...   ELSE   _Connect to FHGW Gracefully FHGW22R1
#     ...        gnb_index=${gnb_index}   vdu_index=${vdu_index}   fhgw_index=${fhgw_index}  alias=${alias}   timeout=${timeout}

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
    ...    | Disconnect Interactive Connection |
    ...
    Connect To FHGW   gnb_index=${gnb_index}  vdu_index=${vdu_index}   fhgw_index=${fhgw_index}    alias=${alias}  timeout=${timeout}
    ${container_id}  Get Ruproxy Container ID   alias=${alias}   ru_index=${ru_index}
    issh.Set Prompt     \\[root@controller\\(FHGW.*\\).*\\]|sh-\\d\\.\\d\\$    alias=${alias}
    ${opt}  set variable  -o BatchMode=no -o UserKnownHostsFile=/dev/null -o StrictHostKeyChecking=no
    sleep   2
    ${out}    wait until keyword succeeds  5x  3s   issh.Execute    command=docker exec -it ${container_id} sh
    ...   check_result=${False}   alias=${alias}
    sleep  1

    [Return]  ${alias}


Connect to Radio Unit
    [Arguments]  ${gnb_index}=0  ${vdu_index}=0   ${fhgw_index}=0     ${alias}=default   ${ru_index}=1   ${timeout}=150
    [Documentation]    Connect to Radio Unit/connect to RU
    ...    *AUTHOR* chris.l.cao@nokia-sbell.com
    ...    history change: <date>,<who>,<what and how>
    ...   15.10.2020,chris.l.cao@nokia-sbell.com, initialization version
    ...   9.6.2021,chris.l.cao@nokia-sbell.com, change 'Connect to FHGW' to 'Connect to FHGW Gracefully'
    ...   9.12.2021,hongyuan.sun@nokia-sbell.com, change var out
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
    ...    | Disconnect Interactive Connection |
    ...
    Connect to FHGW Gracefully  gnb_index=${gnb_index}  vdu_index=${vdu_index}   fhgw_index=${fhgw_index}    alias=${alias}  timeout=${timeout}
    ${container_id}  Get Ruproxy Container ID   alias=${alias}   ru_index=${ru_index}
    #${cmd_in_docker}  set variable  cat /etc/dhcp/dhcpd.conf|grep range
    #${cmd_in_docker}   set variable  cat /var/db/dhcpd.leases|grep lease|grep -v \\#
    #${out}    issh.Execute     command=docker exec -it ${container_id} ${cmd_in_docker}    alias=${alias}
    #${ip}   Parse Ipv4 Address Only From Content   ${out}
    #String Should Be An Ip Address   ${ip}
    # ${ip}   set variable   169.254.${ru_index}.2
    ${ip}   Get Radio Unit Ip Address  ru_index=${ru_index}
    #issh.Set Prompt     \\[root@controller\\(FHGW.*\\).*\\]|root@nahka-Node\\d+:\\S*\#   alias=${alias}
    issh.Set Prompt      \\[root@controller\\(FHGW.*\\).*\\]|root@nahka-Node\\d+:\\S*\#   alias=${alias}
#    ${opt}  set variable  -o BatchMode=no -o UserKnownHostsFile=/dev/null -o StrictHostKeyChecking=no
#    ${out}   issh.Execute    command=docker exec -it ${container_id} ssh ${opt} root@${ip}    check_result=${False}   alias=${alias}
    ${opt}  set variable  -oHostKeyAlgorithms=+ssh-rsa -o StrictHostKeyChecking=no
    ${opt}  issh.Execute     command=docker exec -it ${container_id} ssh ${opt} root@${ip}   check_result=${False}   alias=${alias}
    sleep  1

    ${out}   issh.Execute    command=hostname     alias=${alias}
    ${hostname}   strip prompt  ${out}
    should be true   "${hostname}"=="nahka"

    [Return]  ${alias}


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
    [Arguments]   ${gnb_index}=0  ${vdu_index}=0  ${alias}=default
    [Documentation]   Connect To K8s Master Interactively
    ...    *AUTHOR* chris.l.cao@nokia-sbell.com
    ...    history change: <date>,<who>,<what and how>
    ...   15.10.2020,chris.l.cao@nokia-sbell.com, initialization version
    ...   31.5.2021,chris.l.cao@nokia-sbell.com, support NCS
    ...   12.8.2021,chris.l.cao@nokia-sbell.com, support OCP by adding '[core@...]'
    ...
    ...    |  Input Parameters | Man. | Description |
    ...    | gnb_index  |  no  | gnb index, default is 0 |
    ...    | vdu_index  |  no  | VDU index, default is 0 |
    ...    | alias      | no   | alias, default value is default |
    ...
    ...    *RETURN VALUE*
    ...    None.
    ...
    ...    Example
    ...    | Connect To K8s Master Interactively |
    ...    | ${out} | issh.Execute | command=ls -l |
    ...    | disconnect interactive connection  |
    ...
    ...    | ${alias} | Get Unique Id |
    ...    | Connect To K8s Master Interactively   | alias=${alias} |
    ...    | ${out} | issh.Execute | command=ls -l | alias=${alias}  |
    ...    | disconnect interactive connection     | alias=${alias} |
    ...
    ${vdu_k8s_master_ssh_connection_info}   Get K8s Admin SSH Connection Info  gnb_index=${gnb_index}   vdu_index=${vdu_index}

    ${ip}   set variable   ${vdu_k8s_master_ssh_connection_info["addr"]}
    ${username}   set variable   ${vdu_k8s_master_ssh_connection_info["username"]}
    ${password}   set variable   ${vdu_k8s_master_ssh_connection_info["password"]}

    ${prompt}  set variable    \\[cloudadmin@\\S+\\s\\S+\\]\\$|\\[root@\\S+\\s\\S+\\s+\\S+\\]\\#|\\[root@\\S+\\s\\S+\\]\\#
    ${prompt}  set variable   ${prompt}|\\[cbis-admin@\\S+\\s\\S+\\s+\\S+\\]\\$|\\[cbis-admin@\\S+\\s\\S+\\]\\$
    ${prompt}  set variable   ${prompt}|\\[core@\\S+\\s\\S+\\]\\$

    issh.Connect_To   ip=${ip}    username=${username}   password=${password}
       ...   prompt=${prompt}
       ...   alias=${alias}   width=200
       ...   timeout=150

#    issh.Connect_To   ip=${ip}    username=${username}   password=${password}
#       ...   prompt=NetworkManager-wait-online.service
#       ...   alias=${alias}   width=200
#       ...   timeout=150
#    sleep  2
#    issh.set prompt    ${prompt}   alias=${alias}
#    Send CTRL_C Interactively   alias=${alias}
#    ${out}   issh.Execute   command=hostname     alias=${alias}


Connect To K8s Master With Tenant Interactively
    [Arguments]   ${vdu_index}=0  ${alias}=default   ${gnb_index}=0
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
    ...    | disconnect interactive connection    |
    ...
    ${ip}    Set Variable   ${tl.gnbs[0].dus[${vdu_index}].cloud_deployment.cloud_hosting.master_node.ssh_connection_details.addr}
    ${username}  Set Variable  ${tl.gnbs[0].dus[${vdu_index}].cloud_deployment.cloud_hosting.master_node.ssh_connection_details.username}
    ${password}  Set Variable  ${tl.gnbs[0].dus[${vdu_index}].cloud_deployment.cloud_hosting.master_node.ssh_connection_details.password}

    ${prompt}  set variable    \\[cranuser\\d+@\\S+\\s+\\S+\\]\\$|\\[cranuser\\d+@\\S+\\s+\\S+\\s+\\S+\\]\\$

    issh.Connect_To   ip=${ip}    username=${username}   password=${password}
       ...   prompt=${prompt}
       ...   alias=${alias}   width=200


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


Connect To UTE
    [Arguments]  ${hostname}=${UTE_SSH_IP}   ${username}=${UTE_SSH_USER_NAME}   ${password}=${UTE_SSH_PASSWORD}  ${alias}=default
    [Documentation]   Connect To UTE
    ...    *AUTHOR* chris.l.cao@nokia-sbell.com
    ...    |  Input Parameters | Man. | Description |
    ...    | hostname  |  no | hostname, default value is ${UTE_SSH_IP} |
    ...    | username  |  no | username, default value is ${UTE_SSH_USER_NAME} |
    ...    | password  |  no | password, default value is ${UTE_SSH_PASSWORD} |
    ...    | alias     |  no | aliase name, default value is default |
    ...
    ...    *RETURN VALUE*
    ...    None
    ...
    ...    Example
    ...    | Connect To UTE      |
    ...    | ${out}                            | issh.Execute | command=ls -l |
    ...    | disconnect interactive connection |
    ...
    issh.connect_to   ip=${hostname}    username=${username}   password=${password}
       ...   prompt=ute@.*\\$   keyfile=/home/ute/.ssh/id_rsa
       ...   alias=${alias}   width=500



Connect To DCAP
    [Arguments]  ${alias}=default
    [Documentation]    Connect To DCAP
    ...    *AUTHOR* huilin.xu@nokia-sbell.com
    ...    |  Input Parameters | Man. | Description |
    ...    | alias  |  no | aliase name, default value is default |
    ...
    ...    *RETURN VALUE*
    ...    connection instance
    ...
    ...    Example
    ...    | Connect To DCAP          |
    ...    | ${out} | issh.Execute | command=ls -l |
    ...    | disconnect interactive connection     |
    ...
    issh.Connect_To   ip=${DCAP_IP}
      ...   username=${DCAP_USER}
      ...   password=${DCAP_PASSWORD}
      ...   prompt=\\[dcapuser@dcap20\\s\\S+\\]\\$
      ...   alias=${alias}
      ...   width=200


Disconnect Interactive Connections
    [Documentation]   Disconnect Interactive Connections, disconnect all interactive ssh connection
    ...    *AUTHOR* chris.l.cao@nokia-sbell.com
    ...    |  Input Parameters | Man. | Description |
    ...    None
    ...
    ...    *RETURN VALUE*
    ...    None.
    ...
    ...    Example
    ...    | Connect To vDU Node Interactively | pod_abbr=oamcp |
    ...    | Connect To vDU Node Interactively | pod_abbr=oamcp |  alias=alias2 |
    ...    | Disconnect Interactive Connections |
    ...
    issh.disconnect  alias=${None}


Disconnect Interactive Connection
    [Arguments]  ${alias}=default
    [Documentation]   Disconnect Interactive Connection for specifical connection identified by alias name
    ...    *AUTHOR* chris.l.cao@nokia-sbell.com
    ...    |  Input Parameters | Man. | Description |
    ...    | alias      | no   | alias, default value is default |
    ...
    ...    *RETURN VALUE*
    ...    None.
    ...
    ...    Example
    ...    | Connect To vDU Node Interactively | pod_abbr=oamcp |
    ...    | Connect To vDU Node Interactively | pod_abbr=oamcp |  alias=alias2 |
    ...    | Disconnect Interactive Connection |               |
    ...    | Disconnect Interactive Connection | alias=alias2 |
    ...
    should not be empty   ${alias}
    issh.disconnect  alias=${alias}



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


Disconnect From FHGW
    [Arguments]    ${alias}=default
    issh.disconnect   alias=${alias}



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
    ...   ${with_bash}=${False}   ${with_pipeline_command}=${EMPTY}
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
    ...    | disconnect interactive connection |
    ...
    run keyword if    "${pod_abbr}"=="${EMPTY}" and "${container}"=="nwmgmt"  Fail   Please give pod_abbr for container nwmgmt !

#    ${out}   run keyword if   "${pod_abbr}"=="${EMPTY}"    _Kubectl Exec Interactively By Container Abbreviation
#        ...      container=${container}   command=${command}   alias=${alias}   check_result=${check_result}  vdu_index=${vdu_index}
#        ...     with_bash=${with_bash}   with_pipeline_command=${with_pipeline_command}
#    ...   ELSE   _Kubectl Exec Interactively By Pod Abbreviation
#        ...      pod_abbr=${pod_abbr}   container=${container}   command=${command}  alias=${alias}  check_result=${check_result}
#        ...      vdu_index=${vdu_index}   with_bash=${with_bash}   with_pipeline_command=${with_pipeline_command}
    ${pod_abbr}   run keyword if   "${pod_abbr}"=="${EMPTY}"   Get Pod Abbreviation By Container Abbreviation   container_abbr=${container}
    ...   ELSE  Set Variable  ${pod_abbr}
    ${out}      _Kubectl Exec Interactively By Pod Abbreviation
        ...      pod_abbr=${pod_abbr}   container=${container}   command=${command}  alias=${alias}  check_result=${check_result}
        ...      vdu_index=${vdu_index}   with_bash=${with_bash}   with_pipeline_command=${with_pipeline_command}
    [Return]  ${out}



_Kubectl Exec Interactively By Pod Abbreviation
    [Arguments]  ${pod_abbr}   ${container}   ${command}   ${alias}=default   ${check_result}=${True}  ${vdu_index}=0   ${with_bash}=${False}
    ...   ${with_pipeline_command}=${EMPTY}
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
    ...    | disconnect interactive connection |
    ...
    ${container}     Get Full Container Name By Container Abbreviation  ctr_abbr=${container}   vdu_index=${vdu_index}
    ${ns}  Get vDU Namespace From TestLine   vdu_index=${vdu_index}
    ${pod_full_name}  Get Full Pod Name By Pod Abbreviation Interactively  pod_abbr=${pod_abbr}   alias=${alias}  vdu_index=${vdu_index}

    ${kubectl_cmd}   Set Variable if   "${with_bash}"=="${False}"   kubectl exec -it ${pod_full_name} -c ${container} -n ${ns} -- ${command}
    ...    kubectl exec -it ${pod_full_name} -c ${container} -n ${ns} -- bash -c "${command}"

    ${kubectl_cmd}   Set Variable if   "${with_pipeline_command}"!="${EMPTY}"    ${kubectl_cmd}${with_pipeline_command}   ${kubectl_cmd}

    ${out}   issh.Execute    command=${kubectl_cmd}   check_result=${check_result}   alias=${alias}
    ${out}   strip prompt  ${out}
    [Return]  ${out}


Ruproxy Kubectl Exec
    [Arguments]    ${command}   ${alias}=default   ${vdu_index}=0   ${fhgw_index}=0   ${ru_index}=1
    [Documentation]    Execute command inside ruproxy container
    ...    *AUTHOR* chris.l.cao@nokia-sbell.com
    ...    |  Input Parameters | Man. | Description |
    ...    | command  | yes | command, e.g, hostname, ifconfig oam3 |
    ...    | connection        | No | connection. Default value is default |
    ...    | vdu_index | No | vdu_index. Default value is 0 |
    ...    | fhgw_index | No | vdu_index. Default value is 0 |
    ...    | ru_index   | No | ru_index. Default value is 0 |
    ...
    ...    *RETURN VALUE*
    ...    Linux command execution result inside container.
    ...
    ...    Example
    ...    | Connect To FHGW |
    ...    | ${out}      | Ruproxy Kubectl Exec | command=ls -l |
    ...    | ${out}      | Ruproxy Kubectl Exec | command=ls -l | vdu_index=0 | ru_index=1 |
    ...    | ${out}      | Ruproxy Kubectl Exec | command=ls -l | vdu_index=0 | alias=default |
    ...    | Disconnect Interactive Connection |
    ...
    ${ns}   Get FHGW Namespace From Testline
    ${pod_full_name}  Get Ruproxy Full Pod Name   alias=${alias}  vdu_index=${vdu_index}   fhgw_index=${fhgw_index}  ru_index=${ru_index}
    ${container}   set variable  ruproxy-1
    ${kubectl_cmd}   Set Variable  kubectl exec -it ${pod_full_name} -c ${container} -n ${ns} -- ${command}
    ${out}   issh.Execute    command=${kubectl_cmd}   alias=${alias}
    [Return]  ${out}



====== VCU SSH Command Begin ======
     Log To Console  \n*** only used for readable ***


Connect To CU K8S Master With Admin
    [Arguments]  ${gnb_index}=0
    [Documentation]    connect to CU K8S cluster with admin permission
    ...  author:            calla.wang@nokia-sbell.com
    ...  modified by:        <06-23-2021>, <calwang>, <initial created>
    ...    history change: <date>,<who>,<what and how>
    ...    23.6.2020,calla.wang@nokia-sbell.comm, initialized version
    ...    9.7.2021,chris.l.cao@nokia-sbell.com, add support for cbis-admin user
    ...    14.7.2021,chris.l.cao@nokia-sbell.com, enhancement for root user
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

    #${prompt}  set variable   ]#|\\[cbis-admin@\\S+\\s\\S+\\s+\\S+\\]\\$
    ${prompt}  set variable   \\[root@\\S+\\s\\S+\\s+\\S+\\]\\#|\\[root@\\S+\\s\\S+\\]\\#
    ${prompt}  set variable   ${prompt}|\\[cbis-admin@\\S+\\s\\S+\\s+\\S+\\]\\$|\\[cbis-admin@\\S+\\s\\S+\\]\\$
    ${prompt}  Set Variable  ${prompt}|\\[core@\\S+\\s\\S+\\]\\$
    ${prompt}  Set Variable  ${prompt}|\\[core@\\S+\\s\\S+\\]\\$

    ${alias}=  get unique id
    issh.Connect_To
    ...   ip=${host_ip}
    ...   username=${username}
    ...   password=${password}
    ...   prompt=${prompt}
    ...   alias=${alias}
    [Return]  ${alias}


Connect To CU K8S Master With Tenant
    [Arguments]  ${gnb_index}=0
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
#    ${prompt}  set variable    \\[cranuser\\d+@\\S+\\s+\\S+\\]\\$|\\[cranuser\\d+@\\S+\\s+\\S+\\s+\\S+\\]\\$
    #${prompt}    Set Variable    \\]\\$
    ${prompt}    Set Variable   \\[cranuser\\d+@\\S+\\s+\\S+\\s+\\S+\\]\\$
    ${prompt}    Set Variable   ${prompt}|\\[cranuser\\d+@\\S+\\s+\\S+\\]\\$
    ${alias}=  get unique id
    issh.Connect_To
    ...   ip=${host_ip}
    ...   username=${username}
    ...   password=${password}
    ...   prompt=${prompt}
    ...   alias=${alias}
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
    ...
    ...    | Input Parameters | Man. | Description |
    ...    | pod_abbr | Yes. | the pod name abbreviation, do not give the full pod name. such as oamcm |
    ...    | container | Yes. | the container name abbreviation. such as oamcm |
    ...    | alias | Yes. | the alias that connected to the CU cluster. |
    ...    | gnb_index | No. | the gnb index, default value is 0. |

    ...    *RETURN VALUE*
    ...    the command output
    ...  *Example*
    ...    | ${alisa}= | Connect To CU K8S Master With Admin  |  |
    ...    | ${output}= | Connect To CU Container | oamcm | oamcm | date | ${alias} |
    ...    | Disconnect Interactive Connection | ${alias} |
    ${platform}=   Get vCU Platform Name
    run keyword if  "${platform}"=="NCS" or "${platform}"=="OCP"  _Connect To CU Container NCS And OCP
    ...    pod_abbr=${pod_abbr}   container=${container}   alias=${alias}
    ...    check_result=${check_result}  gnb_index=${gnb_index}


_Connect To CU Container NCS And OCP
    [Arguments]  ${pod_abbr}   ${container}   ${alias}=default   ${check_result}=${True}  ${gnb_index}=0
    [Documentation]  Internal KW for Connect to CU container (NCS and OCP supported)
    ...  author:            lingting.usn@nokia-sbell.com
    ...  modified by:       <08-16-2021>, <lingtsun>, <initial created>
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
    ${kubectl_cmd}   Set Variable   ${sudo_outer} kubectl exec -it ${cu_full_pod_name} -c ${cu_full_container_name} -n ${ns} -- bash
    ${old_prompt}=    issh.get_prompt    alias=${alias}
    ${out}   issh.set_prompt    \\[root@\\S+${container}\\S+\\]    alias=${alias}
    ${new_prompt}=    issh.get_prompt    alias=${alias}
    ${out}   issh.Execute    command=${kubectl_cmd}   check_result=${check_result}   alias=${alias}
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

CU SSH To CPCL
    [Arguments]    ${gnb_index}=${0}  ${vm_index}=${0}   ${alias}=default
    [Documentation]    Create ssh connection to CPCL VM.
    ...  author:             fen.huang@nokia-sbell.com
    ...  modified by:        <14-May-2020>, <f2huang>, <initial created>
    ...    | Input Parameters | Man. | Description |
    ...    |  gnb_index  | No |  Indicate which gnb/cu will be used, 0 in default |
    ...    |  vm_index   | No |  Indicate which vm will be used, 0 in default |
    ...    |  alias  | No |  connection alias  |
    ...
    ...    *RETURN VALUE*
    ...    None
    ...    Example
    ...    | CU SSH To CPCL |  1  |  0  |
   ${alias}=  _CU SSH To VM   ${gnb_index}   cpcl    ${vm_index}   alias=${alias}
   [Return]  ${alias}
#   ${hostname}=    CU Get VM Hostname    cpcl   ${vm_index}   ${gnb_index}
#   ${alias}=  CU SSH To OAM   ${gnb_index}   ${alias}
#   issh.execute    command=ssh ${hostname}.local   check_result=${False}  alias=${alias}
#   issh.set prompt   ]   alias=${alias}
#   ${output}=  issh.execute  hostname  check_result=${False}  alias=${alias}
#   ${output}=   convert to lowercase   ${output}
#   should contain   ${output}   cpcl   ssh to vm cpcl ${vm_index} failed!
#   [Return]  ${alias}

CU SSH To CPNB
    [Arguments]    ${gnb_index}=${0}  ${vm_index}=${0}   ${alias}=default
    [Documentation]    Create ssh connection to CPNB VM.
    ...  author:             fen.huang@nokia-sbell.com
    ...  modified by:        <14-May-2020>, <f2huang>, <initial created>
    ...    | Input Parameters | Man. | Description |
    ...    |  gnb_index  | No |  Indicate which gnb/cu will be used, 0 in default |
    ...    |  vm_index   | No |  Indicate which vm will be used, 0 in default |
    ...    |  alias  | No |  connection alias  |
    ...
    ...    *RETURN VALUE*
    ...    None
    ...    Example
    ...    | CU SSH To CPNB |  1  |  0  |
   ${alias}=  _CU SSH To VM   ${gnb_index}   cpnb    ${vm_index}   alias=${alias}
   [Return]  ${alias}

CU SSH To CPNRT
    [Arguments]    ${gnb_index}=${0}  ${vm_index}=${0}   ${alias}=default
    [Documentation]    Create ssh connection to CPNRT VM.
    ...  author:             fen.huang@nokia-sbell.com
    ...  modified by:        <14-May-2020>, <f2huang>, <initial created>
    ...    | Input Parameters | Man. | Description |
    ...    |  gnb_index  | No |  Indicate which gnb/cu will be used, 0 in default |
    ...    |  vm_index   | No |  Indicate which vm will be used, 0 in default |
    ...    |  alias  | No |  connection alias  |
    ...
    ...    *RETURN VALUE*
    ...    None
    ...    Example
    ...    | CU SSH To CPNRT  |  1  |  0 |
   ${alias}=  _CU SSH To VM   ${gnb_index}   cpnrt    ${vm_index}   alias=${alias}
   [Return]  ${alias}

CU SSH To CPUE
    [Arguments]    ${gnb_index}=${0}  ${vm_index}=${0}   ${alias}=default
    [Documentation]    Create ssh connection to CPUE VM.
    ...  author:             fen.huang@nokia-sbell.com
    ...  modified by:        <14-May-2020>, <f2huang>, <initial created>
    ...    | Input Parameters | Man. | Description |
    ...    |  gnb_index  | No |  Indicate which gnb/cu will be used, 0 in default |
    ...    |  vm_index   | No |  Indicate which vm will be used, 0 in default |
    ...    |  alias  | No |  connection alias  |
    ...
    ...    *RETURN VALUE*
    ...    None
    ...    Example
    ...    | CU SSH To CPUE |  1  |  0  |
   ${alias}=  _CU SSH To VM   ${gnb_index}   cpue    ${vm_index}   alias=${alias}
   [Return]  ${alias}

CU SSH To DB
    [Arguments]    ${gnb_index}=${0}  ${vm_index}=${0}   ${alias}=default
    [Documentation]    Create ssh connection to DB VM.
    ...  author:             fen.huang@nokia-sbell.com
    ...  modified by:        <14-May-2020>, <f2huang>, <initial created>
    ...    | Input Parameters | Man. | Description |
    ...    |  gnb_index  | No |  Indicate which gnb/cu will be used, 0 in default |
    ...    |  vm_index   | No |  Indicate which vm will be used, 0 in default |
    ...    |  alias  | No |  connection alias  |
    ...
    ...    *RETURN VALUE*
    ...    None
    ...    Example
    ...    | CU SSH To DB  |  1  |  0  |
   ${alias}=  _CU SSH To VM   ${gnb_index}   db    ${vm_index}   alias=${alias}
   [Return]  ${alias}

CU SSH To UPUE
    [Arguments]    ${gnb_index}=${0}  ${vm_index}=${0}   ${alias}=default
    [Documentation]    Create ssh connection to UPUE VM.
    ...  author:             fen.huang@nokia-sbell.com
    ...  modified by:        <14-May-2020>, <f2huang>, <initial created>
    ...    | Input Parameters | Man. | Description |
    ...    |  gnb_index  | No |  Indicate which gnb/cu will be used, 0 in default |
    ...    |  vm_index   | No |  Indicate which vm will be used, 0 in default |
    ...    |  alias  | No |  connection alias  |
    ...
    ...    *RETURN VALUE*
    ...    None
    ...
    ...    Example
    ...    | CU SSH To UPUE |  1  |  0 |
    ${alias}=   _CU SSH To VM   ${gnb_index}   upue    ${vm_index}   alias=${alias}
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
    issh.set prompt   ]   alias=${alias}
    ${output}=  issh.execute  hostname  check_result=${False}  alias=${alias}
    ${output}=   convert to lowercase   ${output}
    should contain   ${output}   ${vm_type}   ssh to vm ${vm_type} ${vm_index} failed!
    [Return]  ${alias}

====== VCU SSH Command End ======
     Log To Console  \n*** only used for readable ***
