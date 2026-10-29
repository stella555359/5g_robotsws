*** Settings ***
Documentation    Cloud connections keywords.
...              Authors:    Patryk Tatarek, Jagoda Kubacka
...              Contact:    patryk.tatarek@nokia.com, jagoda.kubacka@nokia.com

Resource    taf/rfrl/cbts/utilities/init_variables.robot
Resource    taf/rfrl/cbts/robot/ssh_operations.robot

Library     taf.gnb.oam.coam.cu     WITH NAME    vcu_admin
Library     taf.gnb.oam.coam.vdu    WITH NAME    vdu_admin
Library     taf.hw.fhgw.cli         WITH NAME    issh
Library     taf.transport.ssh       WITH NAME    ssh
Library     SSHLibrary

*** Keywords ***

#################################################### Main  Keywords ####################################################

Connect to ADMIN
    [Documentation]    Description:    Connect to cloud WebEM, by default as Nemuadmin
    ...                Input:          hw_type = vCU/vDU
    ...                Output:         Proper connection object, on vCu it's alias, on vDU it's instance
    ...                Author:         patryk.tatarek@nokia.com
    [Arguments]        ${username}=${WEBEM_USERNAME}    ${password}=${WEBEM_PASSWORD}
    ...                ${alias}=admin    ${hw_type}=${NONE}    ${port}=${DEFAULT_PORT}
    ...                ${secure}=True    ${login_disabled}=False    ${custom_LMP_addr}=${NONE}
    ${ip_address}=     Set Variable If     '${hw_type}'=='vCU' and "${custom_LMP_addr}"=="${NONE}"    ${LMP_VCU_IP}
    ...                                    '${hw_type}'=='vDU' and "${custom_LMP_addr}"=="${NONE}"    ${LMP_VDU_IP}
    ...                                    not "${custom_LMP_addr}"=="${NONE}"                        ${custom_LMP_addr}
#    To be checked with TAF, if that will be fix or not, but even without it keyword works as it should
#    ${sw_version}=     Get Software Version
#    ...                username=${username}
#    ...                password=${password}
    ${connection}=     Run Keyword If    '${hw_type}'=='vCU'
    ...                vcu_admin.connect_to
    ...                host=${ip_address}
    ...                port=${port}
    ...                username=${username}
    ...                password=${password}
#    ...                cu_version=${sw_version}
    ...                alias=${alias}
    ...                secure=${secure}
    ...                login_disabled=${login_disabled}
    ...    ELSE IF     '${hw_type}'=='vDU'
    ...                vdu_admin.connect_to
    ...                host=${ip_address}
    ...                port=${port}
    ...                username=${username}
    ...                password=${password}
    ...                connection_name=${alias}
#    ...                vdu_version=${sw_version}
    ...                secure=${secure}
    ...                login_disabled=${login_disabled}
    ...    ELSE        FAIL    hw_type doesn't exist
    Log                ${hw_type} ADMIN - CONNECTED!   console=True
    [Return]           ${connection}

Connect to ADMIN via SSH
    [Documentation]    Description:    SSH connection to BTS, by default with BTS LMP IP address
    ...                Input:          hw_type = vCU/vDU
    ...                Output:         SSH connection object
    ...                Author:         jagoda.kubacka@nokia.com
    [Arguments]        ${username}=${SSH_K8S_USERNAME}    ${password}=${SSH_K8S_PASSWORD}
    ...                ${alias}=admin    ${hw_type}=${NONE}    ${port}=${DEFAULT_PORT_SSH}
    ${ip_address}=     Set Variable If    '${hw_type}'=='vCU'    ${SSH_VCU_IP}
    ...                                   '${hw_type}'=='vDU'    ${SSH_VDU_IP}
    ${connection}=     ssh.connect_to    ${ip_address}
    ...                                  ${username}
    ...                                  ${password}
    ...                                  port=${port}
    ...                                  alias=${alias}
    Log                Successfully connected with ${hw_type} via SSH
    ...                console=${TRUE}
    [Return]           ${connection}

Connect to K8s via SSH
    [Documentation]    Description:    SSH connection to K8s, by default with ${SSH_K8S_VCU_IP}/${SSH_K8S_VDU_IP}
    ...                Input:          hw_type = vCU/vDU
    ...                                id = ID of the hw_type (e.g. 2); default: Empty
    ...                Output:         SSH connection index
    ...                Author:         karol.sadowski@nokia.com
    [Arguments]        ${alias}=k8s    ${hw_type}=${NONE}    ${id}=${Empty}
    IF    '${hw_type}'!='vCU' and '${hw_type}'!='vDU'
        FAIL    hw_type doesn't exist
    END
    ${connection}=   SSHLibrary.Open Connection    host=${SSH_K8S_${hw_type}${id}_IP}    alias=${alias}
    SSHLibrary.Login    ${SSH_K8S_USERNAME}    ${SSH_K8S_PASSWORD}
    [Return]           ${connection}

Disconnect from ADMIN
    [Documentation]    Description:    Disconnect from cloud WebEM
    ...                Input:          hw_type = vCU/vDU
    ...                                connection = proper connection object
    ...                Author:         patryk.tatarek@nokia.com
    [Arguments]        ${connection}=admin    ${hw_type}=${NONE}
    Run Keyword If    '${hw_type}'=='vCU'    vcu_admin.disconnect    connection=${connection}
    ...    ELSE IF    '${hw_type}'=='vDU'    vdu_admin.disconnect    vdu_connection=${connection}
    ...    ELSE        FAIL                  hw_type doesn't exist
    Log                ${hw_type} ADMIN - DISCONNECTED!    console=True

Disconnect from ADMIN via SSH
    [Documentation]    Description:    SSH disconnection from BTS
    ...                Input:          hw_type = vCU/vDU
    ...                                connection = SSH connection object
    ...                Author:         jagoda.kubacka@nokia.com
    [Arguments]        ${connection}=admin    ${hw_type}=${NONE}
    Run Keyword If    '${hw_type}'=='vCU'    ssh.disconnect    connection=${connection}
    ...    ELSE IF    '${hw_type}'=='vDU'    ssh.disconnect    connection=${connection}
    ...    ELSE        FAIL                  hw_type doesn't exist

Disconnect from K8s via SSH
    [Documentation]    Description:    SSH connection to K8s, by default with ${SSH_K8S_VCU_IP}/${SSH_K8S_VDU_IP}
    ...                Input:          SSH connection alias or index returned from Connect to K8s via SSH KW
    ...                Author:         karol.sadowski@nokia.com
    [Arguments]        ${index_or_alias}=k8s
    SSHLibrary.Switch Connection    index_or_alias=${index_or_alias}
    SSHLibrary.Close Connection

Connect to FHGW
    [Documentation]    Description:    SSH connection to FHGW using SSH details provided in __init__.py
    ...                Output:         SSH connection object
    ...                Author:         jakub.ozierski@nokia.com
    ${conn}=     issh.Connect To    ip=${tl.gnbs[0].dus[0].fhgws[0].default_ssh_connection_details.addr}
    ...                             port=${tl.gnbs[0].dus[0].fhgws[0].default_ssh_connection_details.port}
    ...                             username=${tl.gnbs[0].dus[0].fhgws[0].default_ssh_connection_details.username}
    ...                             password=${tl.gnbs[0].dus[0].fhgws[0].default_ssh_connection_details.password}
    ...                             width=200
    [Return]     ${conn}

Get Software Version
    [Documentation]    Description:    Get active software version from vCU or vDU
    ...                Input:          hw_type = vCU/vDU
    ...                Output:         List of variables including active_software i.e. :
    ...                                vCUCNF00_0.250.26576 or vDUCNF25R1_24.300.99 | release: 25R2, 25R1, 24R2... | is_trunk: True/False
    ...                Author:         karol.sadowski@nokia.com
    [Arguments]        ${hw_type}=${NONE}
    @{output}=    Run Keyword If    '${hw_type}'=='vCU'     _Get Software Version from vCU
                  ...    ELSE IF    '${hw_type}'=='vDU'     _Get Software Version from vDU
                  ...    ELSE IF    '${hw_type}'=='FHGW'    _Get Software Version from FHGW
                  ...    ELSE        FAIL                   hw_type doesn't exist
    [Return]                @{output}

Get OCP Version for MN
    [Documentation]    Description:    Get active OCP software version from vCU or vDU cluster
    ...                Input:          hw_type = vCU/vDU
    ...                                id = ID of the hw_type (e.g. 2); default: Empty
    ...                Output:         OCP version i.e. : ocp-4.14.36-nokia.24.9.3
    ...                Author:         karol.sadowski@nokia.com
    [Arguments]        ${hw_type}=${NONE}    ${id}=${Empty}
        IF    '${hw_type}'!='vCU' and '${hw_type}'!='vDU'
            FAIL    hw_type doesn't exist
        END
        ${temp_connection}=   Connect to K8s via SSH    hw_type=${hw_type}    id=${id}    alias=temp_connection
        ${data}=    SSHLibrary.Execute Command    oc get nokiaclusters.nokia.com -o yaml    connection=${temp_connection}
        ${ocp_sw_version}=   Get Regexp Matches    ${data}    (.*nokiaRelease: )(.*)(\\n.*)    2
    [Return]                ${ocp_sw_version[0]}
    [Teardown]              Disconnect from K8s via SSH    index_or_alias=${temp_connection}

Renew Connection
    [Documentation]    Description:    Renew connection token.
    ...                Input:          username = username used in current connection
    ...                                password = password used in current connection
    ...                                connection = proper connection object
    ...                Author:         patryk.tatarek@nokia.com
    [Arguments]        ${username}=${WEBEM_USERNAME}    ${password}=${WEBEM_PASSWORD}
    ...                ${connection}=admin    ${hw_type}=${NONE}
    Run Keyword If    '${hw_type}'=='vCU'    vcu_admin.refresh_token    username=${username}    password=${password}
    ...                                                                 connection=${connection}
    ...    ELSE IF    '${hw_type}'=='vDU'    vdu_admin.refresh_token    username=${username}    password=${password}
    ...                                                                 vdu_connection=${connection}
    ...    ELSE        FAIL                  hw_type doesn't exist

Switchover vCU from Standby to Active mode
    [Documentation]    Description:    Change vCU mode from Standby to Active
    ...                Input:          connection = vCU connection
    ...                Author:         patryk.tatarek@nokia.com
    [Arguments]        ${connection}
    ${operation}=      vcu_admin.activate_cu_vnf    connection=${connection}
    Sleep    30s       reason=Waiting until switchover happens
    Wait until Keyword Succeeds    5min    10s      _Check if VNF activation has given status
    ...                                             id=${operation["id"]}    conn=${connection}
    Sleep    180s      reason=Waiting until secondary vCU is available
    Wait until Keyword Succeeds    5min    10s    Alarm Should not be Active    alarm=4592    hw_type=vCU
    ...                                           pre-connection=${connection}
    Wait until Keyword Succeeds    5min    10s    Alarm Should not be Active    alarm=4557    hw_type=vCU
    ...                                           pre-connection=${connection}
    Wait until Keyword Succeeds    5min    10s    Alarm Should not be Active    alarm=61013    hw_type=vCU
    ...                                           pre-connection=${connection}

Switchover vCU from Active to Standby mode
    [Documentation]    Description:    Change vCU mode from Active to Standby
    ...                Input:          connection = vCU connection
    ...                Author:         patryk.tatarek@nokia.com
    [Arguments]        ${connection}
    ${operation}=      vcu_admin.deactivate_cu_vnf    connection=${connection}
    Wait until Keyword Succeeds    5min    10s    _Check if VNF deactivation was a success    conn=${connection}

Forcefully Switchover vCU from Standby to Active mode
    [Documentation]    Description:    Forcefully change vCU mode from Standby to Active,
    ...                                even if the other vCU is still in Active mode.
    ...                Input:          connection = vCU connection
    ...                Author:         patryk.tatarek@nokia.com
    [Arguments]        ${connection}
    ${operation}=      vcu_admin.forcefully_activate_cu_vnf    connection=${connection}
    Sleep    60s       reason=Waiting until secondary vCU is available
    Wait until Keyword Succeeds    5min    20s      _Check if forcefully VNF activation has given status
    ...                                             id=${operation["id"]}    conn=${connection}
    Sleep    60s       reason=Waiting until secondary vCU is available

Get Operation History List
    [Documentation]    Description:    Getting all active operation history
    ...                Input:          hw_type=vCU/vDU
    ...                Output:         connections_list: the sessions list from WebEM
    ...                Author:         grzegorz.niedzwiedz@nokia.com
    [Arguments]        ${hw_type}=${NONE}
    ${connection}=     Connect to ADMIN      hw_type=${hw_type}
    ${operation}       Run Keyword If        '${hw_type}'=='vCU'    vcu_admin.get_cu_operation_history   connection=${connection}
    ...    ELSE IF    '${hw_type}'=='vDU'    vdu_admin.get_vdu_operation_history     vdu_connection=${connection}
    ...    ELSE        FAIL                  hw_type doesn't exist
    [Return]           ${operation}
    [Teardown]         Disconnect from ADMIN    connection=${connection}    hw_type=${hw_type}

Get IP Security Associations
    [Documentation]    Description:    Get IKE policy informations
    ...                Input:          hw_type=vCU/vDU
    ...                                pod = pod information
    ...                                policy_nr = policy order number
    ...                Output:         IKE policy informations
    ...                Author:         patryk.tatarek@nokia.com
    [Arguments]        ${pod}    ${policy_nr}    ${hw_type}=${NONE}
    ${temp_conn}=      Connect to ADMIN      hw_type=${hw_type}
    ${ike_info}        Run Keyword If        '${hw_type}'=='vCU'    vcu_admin.get_ip_security_associations
    ...                                                             policy_id=${policy_nr}
    ...                                                             tnl_pod_hostname=${pod}
    ...                                                             connection=${temp_conn}
    ...                ELSE IF               '${hw_type}'=='vDU'    vdu_admin.get_ip_security_associations
    ...                                                             policy_id=${policy_nr}
    ...                                                             tnl_pod_hostname=${pod}
    ...                                                             vdu_connection=${temp_conn}
    ...                ELSE                   FAIL                  hw_type doesn't exist
    [Return]           ${ike_info}
    [Teardown]         Disconnect from ADMIN    connection=${temp_conn}    hw_type=${hw_type}

Get Sessions List
    [Arguments]    ${hw_type}    ${pre-connection}=${NONE}
    ${temp_conn}=         Run Keyword If    "${pre-connection}"=="${NONE}"    Connect to ADMIN    hw_type=${hw_type}
    ...                   ELSE    Set Variable    ${pre-connection}
    ${sessions_list}=    Run Keyword If           '${hw_type}'=='vCU'    vcu_admin.get_sessions_list
    ...                                                                  connection=${temp_conn}
    ...                  ELSE IF                  '${hw_type}'=='vDU'    vdu_admin.get sessions list
    ...                                                                  vdu_connection=${temp_conn}
    ...                  ELSE                     FAIL                   hw_type doesn't exist
    [Return]             ${sessions_list}
    [Teardown]           Run Keyword If    "${pre-connection}"=="${NONE}"    Disconnect from ADMIN
    ...                  connection=${temp_conn}    hw_type=${hw_type}

Perform IP Connectivity Test on standby vCU
    [Documentation]    Description:    Perform IP Connectivity Test on standby vCU
    ...                Input:          standby_conn = connection object to standby vCU
    ...                Output:         Test result
    ...                Author:         patryk.tatarek@nokia.com
    [Arguments]        ${standby_conn}
    ${test_oper}=      vcu_admin.start_ip_reachability_test    connection=${standby_conn}
    ${result}=         Wait Until Keyword Succeeds    5min    10s    _Check if IP Connectivity Test has ended
    ...                id=${test_oper["operationId"]}    conn=${standby_conn}
    [Return]           ${result}

################################################ Supplementary Keywords ################################################

_Get Software Version from vCU
    ${temp_conn}=    Connect to ADMIN    hw_type=vCU
    ${sw_version}=    vcu_admin.Get Active Software Version    connection=${temp_conn}
    ${release}=    Get Regexp Matches    ${sw_version}    (vCUCNF)(.*)(_.*)   2
    ${release_number}=    Get Regexp Matches    ${sw_version}    (.*_)(\\d{1,4})(\\..*)   2
    IF    '${release_number[0]}'=='0'
        ${replace}=    Fetch From Left    ${sw_version}    _
        ${sw_version}=    Replace String    ${sw_version}    ${replace}    vCUCNF00
        ${is_trunk}=    Set Variable    ${True}
    ELSE
        ${is_trunk}=    Set Variable    ${False}
    END
    [Return]      ${sw_version}    ${release[0]}    ${is_trunk}
    [Teardown]    Disconnect From ADMIN    connection=${temp_conn}    hw_type=vCU

_Get Software Version from vDU
    ${temp_conn}=    Connect to ADMIN    hw_type=vDU
    ${vdu_info}=    vdu_admin.Get Vdu State Data    vdu_connection=${temp_conn}
    ${sw_version}=    Get From Dictionary    ${vdu_info}    software_version
    ${release}=    Get Regexp Matches    ${sw_version}    (vDUCNF)(.*)(_.*)   2
    ${release_number}=    Get Regexp Matches    ${sw_version}    (.*_)(\\d{1,4})(\\..*)   2
    IF    '${release_number[0]}'=='0'
        ${replace}=    Fetch From Left    ${sw_version}    _
        ${sw_version}=    Replace String    ${sw_version}    ${replace}    vDUCNF00
        ${is_trunk}=    Set Variable    ${True}
    ELSE
        ${is_trunk}=    Set Variable    ${False}
    END
    [Return]      ${sw_version}    ${release[0]}    ${is_trunk}
    [Teardown]    Disconnect From ADMIN    connection=${temp_conn}    hw_type=vDU

_Get Software Version from FHGW
    ${temp_conn}=     Connect to FHGW
    ${cmd_result}=    issh.Execute    command=cat /etc/fhgw-release    alias=${temp_conn}    check_result=False
    ${sw_version}=    Get Regexp Matches    string=${cmd_result}    pattern=release=FHGW.+
    ${sw_version}=    Set Variable     ${sw_version}[0]
    ${sw_version}=    Remove String    ${sw_version}    release=
    ${sw_version}=    Remove String    ${sw_version}    \r
    ${release}=       Get Regexp Matches    ${sw_version}    (FHGW)(.*)(_.*)    2
    [Return]          ${sw_version}    ${release}[0]
    [Teardown]        issh.Disconnect    alias=${temp_conn}

_Check if VNF activation has given status
    [Arguments]       ${id}    ${conn}    ${status}=success
    ${output}=        vcu_admin.get_activate_cu_vnf_status    operation_id=${id}    connection=${conn}
    Should Be True    "${output["status"]}"=="${status}"

_Check if VNF deactivation was a success
    [Arguments]    ${conn}
    ${vcu_vnf}=    vcu_admin.get_cu_vnf    connection=${conn}
    Should be Equal As Strings       ${vcu_vnf["activity_mode"]}    standby

_Check if forcefully VNF activation has given status
    [Arguments]       ${id}    ${conn}    ${status}=success
    ${output}=        vcu_admin.get_forcefully_activate_cu_vnf_status    operation_id=${id}    connection=${conn}
    Should Be True    "${output["status"]}"=="${status}"

_Check if IP Connectivity Test has ended
    [Arguments]    ${id}    ${conn}
    ${output}=     vcu_admin.get_ip_reachability_test_status    operation_id=${id}    connection=${conn}
    Should not be True    "${output["status"]}"=="ongoing"
    [Return]       ${output}
