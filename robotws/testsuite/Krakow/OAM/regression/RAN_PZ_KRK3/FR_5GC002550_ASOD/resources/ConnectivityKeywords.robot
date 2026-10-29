*** Settings ***
Library     OperatingSystem
Library     taf.transport.ssh    WITH NAME    trs_ssh
Library     taf.gnb.oam.coam.cu     WITH NAME    cu

*** Variables ***
${CONNECT_ALIAS}=   asik

*** Keywords ***
Connect Ssh To Asix
    [Documentation]
    ...  Establish connection with ASIx via SSH
    trs_ssh.Connect To
    ...    hostname=${tl.gnbs[0].du.airscale.common_units[0].lmp_connection.addr}
    ...    username=${tl.gnbs[0].du.airscale.common_units[0].lmp_connection.username}
    ...    password=${tl.gnbs[0].du.airscale.common_units[0].lmp_connection.password}
    ...    alias=${CONNECT_ALIAS}

Disconnect Ssh From Asix
    [Documentation]
    ...  Break connection with ASIx via SSH
    trs_ssh.Disconnect      connection=${CONNECT_ALIAS}

Connect Ssh To GNB
    [Documentation]
    ...  Establish connection with GNB via SSH
    trs_ssh.Connect To
    ...    hostname=${GNB_SSH_ADDR}
    ...    username=${GNB_SSH_USERNAME}
    ...    password=${GNB_SSH_PASSWORD}
    ...    alias=${CONNECT_ALIAS}

Switch Active Partition
    [Documentation]
    ...    SSH To ASIX and Execute Switch Active Partition 
    ${partition_info}=   Check Current Active Partition
    ${wanted_partition}=    Set Variable If
    ...    ${partition_info}==1    2
    ...    ${partition_info}==2    1
    Connect Ssh To GNB
    ${new_partition}=    Catenate    uboot_env set active_partition=${wanted_partition}
    trs_ssh.execute    ${new_partition}    connection=${CONNECT_ALIAS}
    trs_ssh.execute    reboot    connection=${CONNECT_ALIAS}
    Wait For GNB Down And Up
    [Return]    ${wanted_partition}
    [Teardown]    trs_ssh.disconnect    connection=${CONNECT_ALIAS}

Wait For GNB Down And Up
    [Documentation]
    ...    Make Mplane IP Is Not Pingable First And Then Pingable
    [Arguments]    ${bts_host}=${GNB_HTTP_ADDR}
    Wait Until Keyword Succeeds    300    10    Check GNB Not Pingable    bts_host=${bts_host}
    Wait Until Keyword Succeeds    900    10    Check GNB Pingable    bts_host=${bts_host}

Check GNB Pingable
    [Arguments]    ${bts_host}=${GNB_HTTP_ADDR}
    ${output}=   Run    ping -c 1 -W 10 ${bts_host}
    Should Contain    ${output}    1 packets transmitted, 1 received

Check GNB Not Pingable
    [Arguments]    ${bts_host}=${GNB_HTTP_ADDR}
    ${output}=   Run    ping -c 1 -W 10 ${bts_host}
    Should Contain    ${output}    1 packets transmitted, 0 received

Check Current Active Partition
    Connect Ssh To GNB
    ${active_partition}=   trs_ssh.execute    uboot_env get active_partition    connection=${CONNECT_ALIAS}
    ${partition_id}=   Fetch From Right    ${active_partition}    =
    ${partition_id}=   Fetch From Left    ${partition_id}    \r
    [Return]    ${partition_id}
    [Teardown]    trs_ssh.disconnect    connection=${CONNECT_ALIAS}

CU Login
    [Arguments]     ${gnb_index}=0   ${solution}=rest   ${alias}=${None}
    [Documentation]  Login to CU via rest or webui.
    ...    | Input Parameters | Man. | Description |
    ...    |  gnb_index  | No |  gnb index to indicate which gnb will be used  |
    ...    |  solution | No |  rest or webui, rest in default |
    ...    |  alias | No. | alias that identifies this connection, if the argument is given,
    ...                     the alias must be given to the CU Logout keyword as connection argumument. |
    ...    *RETURN VALUE*
    ...    the restapi connection alias
    ...    Example
    ...    |  CU Login  |     |
    ${alias}=   run keyword if  "${solution}"=="rest"    CU Rest Login   ${gnb_index}  ${alias}
    ...   ELSE    CU Webui Login    ${gnb_index}
    [Return]   ${alias}

CU Rest Login
   [Arguments]   ${gnb_index}=0   ${alias}=${None}
   [Documentation]  Create rest session to CU.
    ...    | Input Parameters | Man. | Description |
    ...    |  gnb_index  | No |  gnb index to indicate which gnb will be used  |
    ...    |  alias | No. | alias that identifies this connection, if the argument is given,
    ...                     the alias must be given to the CU Logout keyword as connection argumument. |
    ...
    ...    *RETURN VALUE*
    ...    the connection alias
    ...    Example
    ...    |  CU Rest Login   |    0   |
    ${host_ip}   set variable  ${tl.gnbs[${gnb_index}].cu.oam_http_connection_details.addr}
    ${host}   set variable if   ':' in '''${host_ip}'''   [${host_ip}]    ${host_ip}
    cu.connect to    host=${host}
    ...    port=${EMPTY}
    ...    username=${tl.gnbs[${gnb_index}].cu.oam_http_connection_details.username}
    ...    password=${tl.gnbs[${gnb_index}].cu.oam_http_connection_details.password}
    ...    cu_version=cuoam_19b
    ...    secure=${True}
    ...    alias=${alias}
    [Return]  ${alias}

CU Webui Login
    [Arguments]    ${gnb_index}
    [Documentation]  Login to CU via WebUI.
    ...    | Input Parameters | Man. | Description |
    ...    |  gnb_index  | No |  gnb index to indicate which gnb will be used  |
    log   Login to CU webui function is not ready!     level=ERROR

CU Logout
    [Arguments]     ${solution}=rest   ${connection}=${None}
    [Documentation]  Teardown login session to CU.
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
    ...    | Input Parameters | Man. | Description |
    ...    | connection | No. | the connection alias that used in CU login |
    ...    *RETURN VALUE*
    ...    None
    ...    Example
    ...    |  CU Rest Logout |   |
    cu.disconnect   connection=${connection}

CU Webui Logout
      [Documentation]  Logout CU webui.
    ...    | Input Parameters | Man. | Description |
    ...    |  CU Webui Logout   |     |
    log   Logout CU WebUI function is not ready!   level=ERROR

CU SSH To OAM
    [Arguments]    ${gnb_index}=${0}    ${alias}=default
    [Documentation]    Connect to cloud CU OAM VM. addr, username, password are from testline_configuration.
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
    issh.set prompt   ]   alias=${alias}
    ${output}=  issh.execute  hostname  check_result=${False}  alias=${alias}
    ${output}=  Convert to lowercase  ${output}
    should contain   ${output}   oam   ssh to oam vm failed!
    [Return]   ${alias}

_CU SSH To OAM With Username Serviceuser
    [Arguments]    ${gnb_index}=${0}    ${alias}=default
    [Documentation]    Connect to OAM VM with account serviceuser.
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