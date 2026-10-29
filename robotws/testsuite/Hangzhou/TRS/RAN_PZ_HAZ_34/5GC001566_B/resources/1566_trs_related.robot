*** Settings ***
Documentation
...  author: Kaijia Chen
...  contact: kaijia.chen@nokia.com

Library     taf.sbts.oam.coam.admin      WITH NAME    coam
Library     XML   use_lxml=True
Library     String
Library     OperatingSystem
Library     Collections
Library     taf.transport.ssh       WITH NAME   ssh
Library     coam_bts_operations.py
Library     routes.py


*** Variables ***
@{emptyT}
${scf_file}                    ./current_scf.xml
${scf_bck_file}                    ./current_bck_scf.xml

#IPV6 variables
${DEST_IPV6}                   3000::55:55:0
${GATE_IPV6}                   3000::17:17:254
${DIRECT_DST_IPV6}             3000::17:17:1
${SRC_IPV6}                    3000::66:66:0
${DST_PRE_LENGHT_IPV6}         112
${IPRTV6_ID}                   16
${IPV6_FLAG}                   -6
${ipV6OrderNumber}             25
${ipV6SrcIpPrefixLength}       128
${ipV6WrongSrcIpPrefixLength}    129
${IPV6_ROUTE_PARAM}            staticIpv6Routes

#IPV4 variables
${DEST_IPV4}                   14.14.14.0
${GATE_IPV4}                   17.17.17.254
${DIRECT_DST_IPV4}             17.17.17.1
${DST_PRE_LENGHT_IPV4}         25
${IPV4_FLAG}                   -4
${SRC_IPV4}                    13.13.13.0
${IPRTV4_ID}                   14
${ipV4OrderNumber}             26
${ipV4SrcIpPrefixLength}       32
${ipV4WrongSrcIpPrefixLength}    133
${IPV4_ROUTE_PARAM}            staticRoutes

${IPV4_DIRECT_ERR_MSG1}     IPRT-1.staticRoutes-1.gateway
${IPV4_DIRECT_ERR_MSG2}     17.17.17.1*IPADDRESSV4.localIpAddr*severity*Error
${IPV6_DIRECT_ERR_MSG1}     IPRTV6-1.staticIpv6Routes-1.gatewayIpv6Addr
${IPV6_DIRECT_ERR_MSG2}     3000::17:17:1*IPADDRESSV6.localIpAddr*severity*Error

${ERR_MSG_POL_WITHOUT_ROUTES}    /TNLSVC-1/TNL-1/IPNO-1/IPRT-14 does not exists
${ERR_MSG_POL}    external RTPOL.routingPolicies.routingTableDN
${ERR_MSG_POLV6_WITH_ROUTESV4}    IPRTV6.distname
${ERR_MSG_POLV4_WITH_ROUTESV6}    IPRT.distname

${gNB_STATE}                   Configured
@{gNB_VALIDESTATES}            {Configured,OnAir}
${MAX_TIME_RESTE}              2400

${V4_IP1}                      17.17.17.1
${V4_NET1}                     17.17.17.0/${V4_PRE}
${V4_IP2}                      19.19.19.1
${V4_NET2}                     19.19.19.0/${V4_PRE}
${V4_PRE}                      24

${V6_IP1}                      3000::17:17:1
${V6_NET1}                     3000::17:17:0/${V6_PRE}
${V6_IP2}                      3000::19:19:1
${V6_NET2}                     3000::19:19:0/${V6_PRE}
${V6_PRE}                      112

${IPIFID}                      17
${IPRT}                        /TNLSVC-1/TNL-1/IPNO-1/IPRT

*** Keywords ***
Create IF
    ${conn}=            Connect to admin
    ${l_mrbts_id}=        get_mrbts_id    ${conn}
    Set Suite Variable      ${G_MRBTS}    MRBTS-${l_mrbts_id}
    log to console      MRBTS:${G_MRBTS}
    ${dict1}=           create dictionary                       parameterName=interfaceDN
    ...     value=${G_MRBTS}/TNLSVC-1/TNL-1/ETHSVC-1/ETHIF-1    operation=update
    ${IF_PARAMS}=       create list     ${dict1}
    log to console      \n Create IPIF-${IPIFID} with params :${IF_PARAMS}
    ${comm_status}=     coam.perform_object_recommissioning
    ...          dist_name=${G_MRBTS}/TNLSVC-1/TNL-1/IPNO-1/IPIF-${IPIFID}
    ...          parameter=${IF_PARAMS}
    ...          operation=create
    ...          skip_parameter_relation_errors=True
    ...          connection=${conn}

    [Teardown]          Teardown connection     ${conn}

Update IPADDRESS
    [Arguments]        ${ipaddr}    ${prefix}   ${ipid}    ${oper}
    ${conn}=            Connect to admin
    ${dict1}=           create dictionary   parameterName=ipAddressAllocationMethod
    ...     value=MANUAL        operation=update
    ${dict2}=           create dictionary   parameterName=localIpAddr
    ...     value=${ipaddr}     operation=update
    ${dict3}=           create dictionary   parameterName=localIpPrefixLength
    ...     value=${prefix}     operation=update
    ${IP_PARAMS3}=      create list    ${dict1}    ${dict2}    ${dict3}
    log to console      \n ${oper} ${ipid} with params : ${IP_PARAMS3}

    ${comm_status}=     coam.perform_object_recommissioning
    ...         dist_name=${G_MRBTS}/TNLSVC-1/TNL-1/IPNO-1/IPIF-${IPIFID}/${ipid}
    ...          parameter=${IP_PARAMS3}
    ...          operation=${oper}
    ...          skip_parameter_relation_errors=True
    ...          connection=${conn}
    [Teardown]          Teardown connection  ${conn}

Check IPV4 Route Exist
    Check Route     DU_OAM_IP=${DU_OAM_IP}   ip_flag=${IPV4_FLAG}    dst_ip=${DEST_IPV4}
    ...             gateway=${GATE_IPV4}    table=${IPRTV4_ID}

Check IPV6 Route Exist
    Check Route     DU_OAM_IP=${DU_OAM_IP}  ip_flag=${IPV6_FLAG}    dst_ip=${DEST_IPV6}    gateway=${GATE_IPV6}
    ...     table=${IPRTV6_ID}

Create IPV6 Routes Table
    Operate Routes Table    V6-${IPRTV6_ID}     create

Create IPV4 Routes Table
    Operate Routes Table    -${IPRTV4_ID}       create

Delete IPV6 Routes Table
    Operate Routes Table    V6-${IPRTV6_ID}     delete

Delete IPV4 Routes Table
    Operate Routes Table    -${IPRTV4_ID}       delete

Operate Routes Table
    [Arguments]        ${iprt_ID}   ${operation}

    ${conn}=            Connect to admin
    log to console      \n ${operation} route:${G_MRBTS}${IPRT}${iprt_ID}
    ${comm_status}=     coam.perform_object_recommissioning
    ...          dist_name=${G_MRBTS}${IPRT}${iprt_ID}
    ...          parameter=${emptyT}
    ...          operation=${operation}
    ...          skip_parameter_relation_errors=${True}
    ...          connection=${conn}
    [Teardown]          Teardown connection     ${conn}

Connect to admin
    [Arguments]  ${ip_address}=${DU_OAM_IP}      ${alias}=cOAM_admin
    ...          ${username}=${DU_OAM_WEBUI_USER}  ${password}=${DU_OAM_WEBUI_PASSWORD}

    ${connection}=  coam_bts_operations.create_connection  ip_address=${ip_address}
    ...                                                    alias=${alias}
    ...                                                    username=${username}
    ...                                                    password=${password}
    [Return]  ${connection}

Connect to ASOD
    [Arguments]  ${ip_address}=${DU_OAM_IP}         ${alias}=cOAM_toor4nsn
    ...          ${user}=${DU_OAM_SSH_USERNAME}     ${password}=${DU_OAM_SSH_PASSWORD}
    ${connection}=  ssh.Connect to  ${ip_address}
    ...                             ${user}
    ...                             ${password}
    ...                             alias=${alias}
    [Return]    ${connection}

Add IPV6 Route Via Parameters
    [Documentation]   Add static  route via parameters
    [Arguments]    ${p_name}    ${destIpAddr}   ${destinationIpPrefixLength}   ${gateway}   ${dn}
    ${conn}=            Connect to admin
    ${param_value}=     params_for_route_ipv6      destIpAddr=${destIpAddr}
    ...         destinationIpPrefixLength=${destinationIpPrefixLength}  gateway=${gateway}
    Log To Console      \n Add route with params : ${destIpAddr} ${destinationIpPrefixLength} ${gateway} ${dn}
    change_parameter_on_bts    dist_name=${dn}
    ...                        param_name=${p_name}
    ...                        param_value=${param_value}
    ...                        connection=${conn}
    [Teardown]    Teardown connection    ${conn}

Add Static IPV4 Route Via Parameters
    Add IPV4 Route Via Parameters   p_name=${IPV4_ROUTE_PARAM}     destIpAddr=${DEST_IPV4}
    ...         destinationIpPrefixLength=${DST_PRE_LENGHT_IPV4}
    ...         gateway=${GATE_IPV4}   dn=${G_MRBTS}${IPRT}-${IPRTV4_ID}

Add Static IPV6 Route Via Parameters
    Add IPV6 Route Via Parameters   p_name=${IPV6_ROUTE_PARAM}    destIpAddr=${DEST_IPV6}
    ...              destinationIpPrefixLength=${DST_PRE_LENGHT_IPV6}
    ...              gateway=${GATE_IPV6}    dn=${G_MRBTS}${IPRT}V6-${IPRTV6_ID}

Add IPV4 Route Via Parameters
    [Documentation]   Add static  route via parameters
    [Arguments]    ${p_name}    ${destIpAddr}   ${destinationIpPrefixLength}   ${gateway}   ${dn}
    ${conn}=            Connect to admin
    ${param_value}=     params_for_route  destIpAddr=${destIpAddr}
    ...                 destinationIpPrefixLength=${destinationIpPrefixLength}     gateway=${gateway}
    Log To Console      Add route with params : ${destIpAddr} ${destinationIpPrefixLength} ${gateway} ${dn}
    change_parameter_on_bts    dist_name=${dn}
    ...                        param_name=${p_name}
    ...                        param_value=${param_value}
    ...                        connection=${conn}
    [Teardown]      Teardown connection     ${conn}

Login and Send Command
    [Documentation]   Login gNB and execute commands on gNB
    [Arguments]    ${commands}
    ${connection}=      Connect to ASOD
    ${result}=          ssh.execute         command=${commands}         connection=${connection}
    ${stdout}=          ssh.Read Output     connection=${connection}
    ${stderr}=          ssh.Read Error      connection=${connection}
    [Teardown]          ssh.Disconnect      connection=${connection}
    [return]    ${result}

Check Rule
    [Documentation]   Login gNB and check Rules on gNB
    [Arguments]    ${DU_OAM_IP}   ${ip_flag}      ${src_ip}   ${table}=main
    #log to console          table:${table}
    ${rTable}=              getRTable                   ${table}
    ${result}=              Login and Send Command      ip ${ip_flag} rule list table ${rTable}
    #log to console         cmd : ip ${ip_flag} rule list table ${rTable}
    log to console          \n  checking rule : ${result}
    Should Match Regexp     ${result}   .*from.*${src_ip}.*lookup.*${rTable}
    [return]                ${result}

Check Route
    [Documentation]    Login gNB and check Route on gNB
    [Arguments]    ${DU_OAM_IP}    ${ip_flag}    ${dst_ip}    ${gateway}    ${table}=main
    ${rTable}=              getRTable       ${table}
    ${result}=              Login and Send Command          ip ${ip_flag} route list table ${rTable}
    Log To Console          \n checking route on table 1${table}: ${result}
    Should Match Regexp     ${result}   ${dst_ip}.*via.*${gateway} dev.*
    [return]                ${result}

Add IPV4 Routing Policies
    [Documentation]   Add Policies via parameters
    Add Policies        routingTableID=-${IPRTV4_ID}      orderNumber=${ipV4OrderNumber}
    ...                 srcIpAddress=${SRC_IPV4}          srcIpPrefixLength=${ipV4SrcIpPrefixLength}

Delete IPV4 Routing Policies
    [Documentation]   delete Policies via parameters
    Delete Policies     routingTableDN=${G_MRBTS}${IPRT}-${IPRTV4_ID}      orderNumber=${ipV4OrderNumber}
    ...                 srcIpAddress=${SRC_IPV4}        srcIpPrefixLength=${ipV4SrcIpPrefixLength}

Add Policies
    [Documentation]   Add Routing Policy via parameters
    [Arguments]    ${routingTableID}    ${orderNumber}    ${srcIpAddress}    ${srcIpPrefixLength}
    ${conn}=                        Connect to admin
    @{rtpolicyparams}=              Get RoutingPolicies Params      ${conn}
    @{formatedrtpolicyparams}=      get_format_rtpol                ${rtpolicyparams}       ${emptyT}
    Log To Console   Add Policies in Table:${routingTableID} :${orderNumber} :${srcIpAddress} :${srcIpPrefixLength}
    @{newrtpolicyparams}=  add_RTPOL     ${formatedrtpolicyparams}
    ...                      orderNumber=${orderNumber}
    ...                      srcIpPrefixLength=${srcIpPrefixLength}
    ...                      routingTableDN=${G_MRBTS}${IPRT}${routingTableID}
    ...                      srcIpAddress=${srcIpAddress}
    ...                      userLabel=auto tests

    ${result}=  change_parameter_on_bts  dist_name=${G_MRBTS}/TNLSVC-1/TNL-1/IPNO-1/RTPOL-1
    ...                      param_name=routingPolicies
    ...                      param_value=${newrtpolicyparams}
    ...                      skip_parameter_relation_errors=True
    ...                      connection=${conn}
    log to console          result: ${result}
    [return]    ${result}
    [Teardown]      Teardown connection     ${conn}

Get RoutingPolicies Params
    [Arguments]    ${conn}
    @{MOs}    coam.get_managed_objects    class_name=RTPOL_A
    ...                      connection=${conn}
    FOR    ${mo}   IN   @{MOs}
        &{current_policy}=    coam.get_parameters    dist_name=${mo['distName']}
        ...         pattern=routingPolicies     connection=${conn}
    END

    [return]    @{current_policy['routingPolicies']}

Check RoutingPolicies IPV4 added
    Check Rule      DU_OAM_IP=${DU_OAM_IP}      ip_flag=${IPV4_FLAG}
    ...             src_ip=${SRC_IPV4}     table=${IPRTV4_ID}

Delete Policies
    [Documentation]   remove route policy via parameters
    [Arguments]    ${routingTableDN}    ${orderNumber}      ${srcIpAddress}     ${srcIpPrefixLength}
    ${conn}=                        Connect to admin
    @{rtpolicyparams}=              Get RoutingPolicies Params  ${conn}
    @{formatedrtpolicyparams}=      get_format_rtpol            ${rtpolicyparams}   ${emptyT}
    Log To Console                  deleting rt policies with params : rtDN:${routingTableDN}
    Log To Console                  orderNumer:${orderNumber} src:${srcIpAddress} prefix:${srcIpPrefixLength}
    @{newrtpolicyparams}=  del_RTPOL    ${formatedrtpolicyparams}
    ...                      orderNumber=${orderNumber}
    ...                      srcIpPrefixLength=${srcIpPrefixLength}
    ...                      routingTableDN=${routingTableDN}
    ...                      srcIpAddress=${srcIpAddress}
    ...                      userLabel=auto tests
    ${resultat}=    change_parameter_on_bts  dist_name=${G_MRBTS}/TNLSVC-1/TNL-1/IPNO-1/RTPOL-1
    ...                      param_name=routingPolicies
    ...                      param_value=${newrtpolicyparams}
    ...                      connection=${conn}
    Log To Console           ${resultat}
    [Teardown]      Teardown connection     ${conn}

Check SCF ERROR
    [Arguments]    ${errorMsg}=AdminApiProcedureFailureException
    [Documentation]   test
    ${conn}=                                    Connect to admin
    coam_bts_operations.get_current_scf_file    connection=${conn}
    Log to console                              Checking errors in SCF config with error msg:${errorMsg}
    run keyword and expect error                AdminApiProcedureFailureException*${errorMsg}*
    ...                                         run keyword
    ...                                         coam.validate_scf           scf_file=${scf_file}
    ...                                         connection=${conn}
    [Teardown]      Teardown connection     ${conn}

Check SCF Error Policies Without RTable
    Check SCF ERROR     ${ERR_MSG_POL_WITHOUT_ROUTES}

gNB Reset Site
    [Arguments]    ${timeout}=1800
    ${conn}=                        Connect to admin
    log to console                  \n Start reseting gNB...!
    ${reset_status}=                coam.reset_site       timeout=${timeout}      connection=${conn}
    wait until keyword succeeds     ${MAX_TIME_RESTE}       15s     Check GNB State
    log to console                  \n Finish reseting gNB!
    [Teardown]                      Teardown connection     ${conn}

Check GNB State
    ${conn}=                        Connect to admin
    log to console                  \n   checking gNB!
    ${bts_status}=                  coam.get_bts_statuses                    connection=${conn}
    Log To Console                  BTS procedural state is now: ${bts_status["proceduralState"]}
    ${flagStatus}=               coam_bts_operations.checkBtsStatus      ${bts_status["proceduralState"]}
    Should Be True              ${flagStatus}
    Run Keyword If  ${flagStatus}   Log To Console   \n BTS procedural state is now::${bts_status["proceduralState"]}
    [Teardown]                      Teardown connection                 ${conn}

BackupSCF
    [Documentation]   Backup conf before start tests
    ${conn}=    Connect to admin
    coam_bts_operations.backup_scf_file    connection=${conn}
    [Teardown]      Teardown connection     ${conn}

RestoreSCF
    [Documentation]   restore conf after start tests
    ${conn}=    Connect to admin
    coam_bts_operations.restore_scf_file    connection=${conn}
    [Teardown]      Teardown connection     ${conn}

Tests_suite_setup
    Log To Console                  \n Start Tests suite needed configuration
    Run Keyword And Ignore Error    _Init_Global_Variable
    BackupSCF
    run keyword and ignore error    Create IF
    run keyword and ignore error    Create V4IP1
    run keyword and ignore error    Create V4IP2
    run keyword and ignore error    Create V6IP1
    run keyword and ignore error    Create V6IP2


Tests_suite_Teardown
    Log To Console                  \n Start Tests suite clean configurations created by 1566 testing...
    RestoreSCF

_Init_Global_Variable
     ${result}   ${DU_OAM_IP}   Run Keyword And Ignore Error
    ...   Set Variable   ${tl.gnbs[0].dus[0].f1_m_ip_addr}
    Set Suite Variable   ${DU_OAM_IP}

    ${result}  ${DU_OAM_SSH_USERNAME}    Run Keyword And Ignore Error
    ...   Set Variable  ${tl.gnbs[0].dus[0].airscale.common_units[0].lmp_connection.username}
    Set Suite Variable   ${DU_OAM_SSH_USERNAME}

    ${result}  ${DU_OAM_SSH_PASSWORD}    Run Keyword And Ignore Error
    ...   Set Variable  ${tl.gnbs[0].dus[0].airscale.common_units[0].lmp_connection.password}
    Set Suite Variable   ${DU_OAM_SSH_PASSWORD}

    ${result}  ${DU_OAM_WEBUI_URL}        Run Keyword And Ignore Error
    ...   Set Variable  https://${tl.gnbs[0].dus[0].f1_m_ip_addr}/
    Set Suite Variable   ${DU_OAM_WEBUI_URL}

    ${result}  ${DU_OAM_WEBUI_USER}      Run Keyword And Ignore Error
    ...   Set Variable  ${tl.gnbs[0].cu.oam_http_connection_details.username}
    Set Suite Variable   ${DU_OAM_WEBUI_USER}

    ${result}  ${DU_OAM_WEBUI_PASSWORD}   Run Keyword And Ignore Error
    ...   Set Variable  ${tl.gnbs[0].cu.oam_http_connection_details.password}
    Set Suite Variable   ${DU_OAM_WEBUI_PASSWORD}

    ${result}  ${UTE_ADDRESS}       Run Keyword And Ignore Error
    ...   Set Variable    ${tl.test_pc.default_ssh_connection_details.addr}
    Set Suite Variable   ${UTE_ADDRESS}

    ${result}  ${UTE_USERNAME}       Run Keyword And Ignore Error
    ...   Set Variable    ${tl.test_pc.default_ssh_connection_details.username}
    Set Suite Variable   ${UTE_USERNAME}

    ${result}  ${UTE_PASSWORD}        Run Keyword And Ignore Error
    ...   Set Variable  ${tl.test_pc.default_ssh_connection_details.password}
    Set Suite Variable   ${UTE_PASSWORD}

    ${result}  ${LMP_IP}        Run Keyword And Ignore Error
    ...   Set Variable  ${tl.gnbs[0].dus[0].airscale.common_units[0].lmp_connection.addr}
    Set Suite Variable   ${LMP_IP}

    ${BOOLEAN_TRUE}  Convert To Boolean  True
    Set Suite Variable   ${BOOLEAN_TRUE}

    ${BOOLEAN_FALSE}  Convert To Boolean  False
    Set Suite Variable   ${BOOLEAN_FALSE}

    ${result}   ${TRANS_PARA}   Run Keyword And Ignore Error    Set Variable  ${tl._trans_para}
    Set Suite Variable   ${TRANS_PARA}


Create V4IP1
    Update IPADDRESS    ${V4_IP1}   ${V4_PRE}   IPADDRESSV4-7   create

Create V4IP2
    Update IPADDRESS    ${V4_IP2}   ${V4_PRE}   IPADDRESSV4-13  create

Create V6IP1
    Update IPADDRESS    ${V6_IP1}   ${V6_PRE}   IPADDRESSV6-7   create

Create V6IP2
    Update IPADDRESS    ${V6_IP2}   ${V6_PRE}   IPADDRESSV6-13  create

