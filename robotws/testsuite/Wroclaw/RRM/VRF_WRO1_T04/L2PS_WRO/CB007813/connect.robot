*** Settings ***

Documentation     Keywords for connection handling

Library    taf.sbts.oam.coam.admin            WITH NAME    admin
Library    taf.gnb.oam.coam.cu                WITH NAME    coam_cu
Library    taf.transport.ssh                  WITH NAME    ssh
Library    gnb.py                      WITH NAME    gnb_lib
Library    String
Library    OperatingSystem

Library    Collections
Library    DateTime
Library    XML
Library    taf.hw.pdu                                               WITH NAME    pdu
Library    taf.config.testline.info.testline_info.TestlineInfo   WITH NAME    testline_info

*** Variables ***
${P_admin_console}              ${False}    # debug output to console for setup oam http connections

*** Keywords ***
Setup OAM session
    [Documentation]    :Author: Soenke Kullberg
    ...    setup session to OAM (COAM/CloudCOAM)
    ...
    ...    :param gnb_id:      Id of gnb                       [0.. ]  default=0
    ...    :param component: (default=DU, options : DU/CU) If oam type is cloud coam for vRAN 1.0
    ...          the DU component is commissioned by default
    ...
    ...    :returns alias:     alias for http connection to OAM
    [Arguments]     ${gnb_id}=${0}  ${du_id}=${0}  ${component}=DU
    ${oam_alias}=    Set variable    gnb-${gnb_id}-${component}-OAM-local-session
    ${node_type}=    Get Node Deployment Type    node_id=${gnb_id}
    ${du_host_ip}=   gnb_lib.Get GNB DU Host IP   ${tl.gnbs[${gnb_id}].dus[${du_id}]}
    Run keyword if   '${node_type}'=='classical'
    ...    PR555292 WA coam admin connection  ip=${tl.gnbs[${gnb_id}].cu.oam_http_connection_details.addr}    oam_alias=${oam_alias}
    ...    ELSE    Fail    Unsupported Node Type ${node_type}
    [Return]    ${oam_alias}

Teardown OAM session
    [Documentation]    :Author: Vasileios Papoutsis
    ...    Teardown session to OAM (COAM/CloudCOAM)
    ...
    ...    :param connection:      Name or the alias for the connection to OAM that was setup using keyword "Setup OAM session"
    ...    :param gnb_id:      Id of gnb                       [0.. ]  default=0
    ...    :param component: (default=DU, options : DU/CU) If oam type is cloud coam for vRAN 1.0
    ...          the DU component is commissioned by default
    [Arguments]    ${connection}=${None}    ${gnb_id}=${0}    ${component}=DU
    ${connection}=    Set Variable If    '${connection}'=='${None}'    gnb-${gnb_id}-${component}-OAM-local-session    ${connection}
    ${node_type}=    Get Node Deployment Type         node_id=${gnb_id}
    Run keyword if   '${node_type}'=='classical'    admin.teardown    connection=${connection}
    ...    ELSE    Fail    Unsupported Node Type ${node_type}

PR555292 WA coam admin connection
    [Documentation]    [PRIVATE]
    ...    check this pronto once a week
    ...    https://pronto.int.net.nokia.com/pronto/problemReport.html?prid=PR555292
    ...    ip:                      ip of destination node
    ...    oam_alias:               alias name for the connection
    ...    admin_api_log_path:      directory path to store admin api logs
    [Arguments]    ${ip}    ${oam_alias}    ${admin_api_log_path}=${OUTPUT DIR}/admin_logs
    Create directory    ${admin_api_log_path}
    BuiltIn.Log         Try to establish OAM admin connection 3 times   console=${P_admin_console}
    Wait until keyword succeeds    3 min    30 sec
    ...     admin.connect_to    bts_host=${ip}  name=${oam_alias}   admin_api_log_dir=${admin_api_log_path}

Get Node Deployment Type
    [Documentation]    :Author: Jing Liang
    ...    The keyword accepts the gnb number as an argument and returns
    ...    the type of the BTS (aic, classical)
    ...    *Note:* supports classical and AiC vran2.0
    ...
    ...    :param node_type: type of node, either gnb or enb (default=gnb)
    ...    :param node_id:   Id/Number of node               (default=0)
    ...    :return: type of BTS    (classical|aic)
    ...
    [Arguments]     ${node_id}=0  ${node_type}=gnb
    ${bts_type}     Set Variable If
    ...    '${tl.${node_type}s[${node_id}].__class__.__name__}'=='ClassicalBts'                                                         classical
    ...    '${tl.${node_type}s[${node_id}].__class__.__name__}'=='RealEnb'                                                              classical
    ...    '${tl.${node_type}s[${node_id}].__class__.__name__}' and '${tl.${node_type}s[${node_id}].dus[0].__class__.__name__}'=='VDU'  aic
    [Return]  ${bts_type}
