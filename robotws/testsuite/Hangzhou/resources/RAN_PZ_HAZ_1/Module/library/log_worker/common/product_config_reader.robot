*** Settings ***
Documentation
...    Author: Liu, Renhui
...    Contact: renhui-david.liu@nokia-sbell.com


*** Variables ***
${Log_Module_Default_ENB_LMP_HTTP_IP}    192.168.255.129
${Log_Module_Default_ENB_LMP_HTTP_USERNAME}    Nemuadmin
${Log_Module_Default_ENB_LMP_HTTP_PASSWORD}    nemuuser
${Log_Module_Default_ENB_OAM_HTTP_USERNAME}    Nemuadmin
${Log_Module_Default_ENB_OAM_HTTP_PASSWORD}    nemuuser
${Log_Module_Default_SSH_USERNAME}    toor4nsn
${Log_Module_Default_SSH_PASSWORD}    oZPS0POrRieRtu
${Log_Module_Default_TEST_PC_SSH_PASSWORD}     uteUTE!

*** Keywords ***
product_config.Get Test PC SSH Connection Info
    [Arguments]    ${bts_index}=${0}
    [Documentation]
    ...    Get test pc's ssh connection information
    ...
    ...    Author: Liu Renhui
    ...    Contact: renhui-david.liu@nokia-sbell.com
    ...    | Input Parameters    | Man. | Description |
    ...    | bts_index | yes | BTS index |
    ...
    ...    | Return Value | Description |
    ...    | bts_http_connection_info | a dict |
    ...
    ...    Example
    ...   | product_config.Get Test PC SSH Connection Info |
    ...
    ${test_pc}    Set Variable If    '${bts_index}' == '0'    ${tl.test_pc}    ${tl.test_pcs[${bts_index}]}

    ${addr}=    utility.check_nested_attributes    ${test_pc}    default_ssh_connection_details.addr
    ${addr_upper}=    Convert To Uppercase    ${addr}
    Should Be True   '${addr_upper}'!='NONE'

    ${username}=    utility.check_nested_attributes    ${test_pc}    default_ssh_connection_details.username
    ${username_upper}=    Convert To Uppercase    ${username}
    Should Be True   '${username_upper}'!='NONE'

    ${password}=    utility.check_nested_attributes    ${test_pc}    default_ssh_connection_details.password
    ${password_upper}=    Convert To Uppercase    ${password}
    ${password}=    Set Variable If    '${password_upper}' == 'NONE'
    ...    ${Log_Module_Default_TEST_PC_SSH_PASSWORD}    ${password}

    &{test_pc_ssh_connection_info}    create dictionary    host=${addr}
    ...    user=${username}    password=${password}
    [Return]    ${test_pc_ssh_connection_info}

################################ For Classical BTS #################################
product_config.Get BTS LMP SSH Connection Info
    [Arguments]    ${product_type}
    ...            ${bts_index}=${0}
    [Documentation]
    ...    Supported BTS products: gnb, enb
    ...
    ...    Author: Liu Renhui
    ...    Contact: renhui-david.liu@nokia-sbell.com
    ...    | Input Parameters    | Man. | Description |
    ...    | product_type | yes | gnb, enb |
    ...    | bts_index | yes | BTS index |
    ...    | port | yes | https port |
    ...
    ...    | Return Value | Description |
    ...    | bts_lmp_http_connection_info | a dict |
    ...
    ...    Example
    ...   | Get BTS LMP HTTP Connection Info |
    ...
    ${connection_info}=    Run Keyword If    '${product_type}' == 'gnb'
    ...    product_config.Get Gnb LMP SSH Connection Info    bts_index=${bts_index}
    ...    ELSE IF  '${product_type}' == 'enb'
    ...    product_config.Get Enb LMP SSH Connection Info    bts_index=${bts_index}
    [Return]    ${connection_info}

product_config.Get BTS OAM SSH Connection Info
    [Arguments]    ${product_type}
    ...            ${bts_index}=${0}
    [Documentation]
    ...    Supported BTS products: gnb, enb
    ...
    ...    Author: Liu Renhui
    ...    Contact: renhui-david.liu@nokia-sbell.com
    ...    | Input Parameters    | Man. | Description |
    ...    | product_type | yes | gnb, enb |
    ...    | bts_index | yes | BTS index |
    ...    | port | yes | https port |
    ...
    ...    | Return Value | Description |
    ...    | bts_lmp_http_connection_info | a dict |
    ...
    ...    Example
    ...   | product_config.Get BTS OAM SSH Connection Info |
    ...
    ${connection_info}=    Run Keyword If    '${product_type}' == 'gnb'
    ...    product_config.Get Gnb OAM SSH Connection Info    bts_index=${bts_index}
    ...    ELSE IF  '${product_type}' == 'enb'
    ...    product_config.Get Enb OAM SSH Connection Info    bts_index=${bts_index}
    [Return]    ${connection_info}

product_config.Get BTS LMP HTTP Connection Info
    [Arguments]    ${product_type}
    ...            ${bts_index}=${0}
    ...            ${port}=443
    [Documentation]
    ...    Supported BTS products: gnb, enb
    ...
    ...    Author: Liu Renhui
    ...    Contact: renhui-david.liu@nokia-sbell.com
    ...    | Input Parameters    | Man. | Description |
    ...    | product_type | yes | gnb, enb |
    ...    | bts_index | yes | BTS index |
    ...    | port | yes | https port |
    ...
    ...    | Return Value | Description |
    ...    | bts_lmp_http_connection_info | a dict |
    ...
    ...    Example
    ...   | Get BTS LMP HTTP Connection Info |
    ...
    ${lmp_http_connection_info}=    Run Keyword If    '${product_type}' == 'gnb'
    ...    product_config.Get Gnb LMP HTTP Connection Info    bts_index=${bts_index}
    ...    ELSE IF  '${product_type}' == 'enb'
    ...    product_config.Get Enb LMP HTTP Connection Info    bts_index=${bts_index}
    &{bts_lmp_http_connection_info}    create dictionary    &{lmp_http_connection_info}    port=${port}
    [Return]    ${bts_lmp_http_connection_info}

product_config.Get BTS OAM HTTP Connection Info
    [Arguments]    ${product_type}
    ...            ${bts_index}=${0}
    ...            ${port}=443
    [Documentation]
    ...    Supported BTS products: gnb, enb
    ...
    ...    Author: Liu Renhui
    ...    Contact: renhui-david.liu@nokia-sbell.com
    ...    | Input Parameters    | Man. | Description |
    ...    | product_type | yes | gnb, enb |
    ...    | bts_index | yes | BTS index |
    ...    | port | yes | https port |
    ...
    ...    | Return Value | Description |
    ...    | bts_lmp_http_connection_info | a dict |
    ...
    ...    Example
    ...   | Get BTS LMP HTTP Connection Info |
    ...
    ${http_connection_info}=    Run Keyword If    '${product_type}' == 'gnb'
    ...    product_config.Get Gnb OAM HTTP Connection Info    bts_index=${bts_index}
    ...    ELSE IF  '${product_type}' == 'enb'
    ...    product_config.Get Enb OAM HTTP Connection Info    bts_index=${bts_index}
    &{bts_oam_http_connection_info}    create dictionary    &{http_connection_info}    port=${port}
    [Return]    ${bts_oam_http_connection_info}

product_config.Get Gnb OAM SSH Connection Info
    [Arguments]    ${bts_index}=${0}
    [Documentation]
    ...    Get gnb's OAM SSH connection information
    ...
    ...    Author: Liu Renhui
    ...    Contact: renhui-david.liu@nokia-sbell.com
    ...    | Input Parameters    | Man. | Description |
    ...    | bts_index | yes | BTS index |
    ...
    ...    | Return Value | Description |
    ...    | bts_http_connection_info | a dict |
    ...
    ...    Example
    ...   | product_config.Get Gnb OAM SSH Connection Info |
    ...
    ${http_addr}    set variable    ${tl.gnbs[${bts_index}].cu.oam_ssh_connection_details.addr}
    ${username}     set variable    ${tl.gnbs[${bts_index}].cu.oam_ssh_connection_details.username}
    ${password}     set variable    ${tl.gnbs[${bts_index}].cu.oam_ssh_connection_details.password}
    &{connection_info}    create dictionary    host=${http_addr}
    ...    user=${username}    password=${password}
    [Return]    ${connection_info}

product_config.Get Gnb OAM HTTP Connection Info
    [Arguments]    ${bts_index}=${0}
    [Documentation]
    ...    Get gnb's LMP http connection information
    ...
    ...    Author: Liu Renhui
    ...    Contact: renhui-david.liu@nokia-sbell.com
    ...    | Input Parameters    | Man. | Description |
    ...    | bts_index | yes | BTS index |
    ...
    ...    | Return Value | Description |
    ...    | bts_http_connection_info | a dict |
    ...
    ...    Example
    ...   | Get Gnb OAM HTTP Connection Info |
    ...
    ${Testline_type}    product_config.Get Testline Type
    ${http_addr}    Run Keyword If    'AP' in '${Testline_type}'
    ...    Set Variable    10.0.1.2
    ...    ELSE    Set Variable    ${tl.gnbs[${bts_index}].cu.oam_http_connection_details.addr}
    ${username}     set variable    ${tl.gnbs[${bts_index}].cu.oam_http_connection_details.username}
    ${password}     set variable    ${tl.gnbs[${bts_index}].cu.oam_http_connection_details.password}
    &{gnb_oam_http_connection_info}    create dictionary    host=${http_addr}
    ...    username=${username}    password=${password}
    [Return]    ${gnb_oam_http_connection_info}

product_config.Get Enb OAM SSH Connection Info
    [Arguments]    ${bts_index}=${0}
    [Documentation]
    ...    Get enb's OAM SSH connection information
    ...
    ...    Author: Liu Renhui
    ...    Contact: renhui-david.liu@nokia-sbell.com
    ...    | Input Parameters    | Man. | Description |
    ...    | bts_index | yes | BTS index |
    ...
    ...    | Return Value | Description |
    ...    | enb_oam_http_connection_info | a dict |
    ...
    ...    Example
    ...   | product_config.Get Enb OAM SSH Connection Info |
    ...
    ${http_addr}=    utility.check_nested_attributes    ${tl}    enbs[${bts_index}].oam_ip.v4
    ${http_addr_upper}=    Convert To Uppercase    ${http_addr}
    Should Be True   '${http_addr_upper}'!='NONE'

    &{connection_info}    create dictionary    host=${http_addr}
    ...    user=${Log_Module_Default_SSH_USERNAME}    password=${Log_Module_Default_SSH_PASSWORD}
    [Return]    ${connection_info}

product_config.Get Enb OAM HTTP Connection Info
    [Arguments]    ${bts_index}=${0}
    [Documentation]
    ...    Get enb's LMP http connection information
    ...
    ...    Author: Liu Renhui
    ...    Contact: renhui-david.liu@nokia-sbell.com
    ...    | Input Parameters    | Man. | Description |
    ...    | bts_index | yes | BTS index |
    ...
    ...    | Return Value | Description |
    ...    | enb_oam_http_connection_info | a dict |
    ...
    ...    Example
    ...   | Get Enb OAM HTTP Connection Info |
    ...
    ${Testline_type}    product_config.Get Testline Type
    ${http_addr}=    Run Keyword If    'CUS' in '${Testline_type}'
    ...    Set Variable    10.0.1.2
    ...    ELSE    utility.check_nested_attributes    ${tl}    enbs[${bts_index}].oam_ip.v4
    ${http_addr_upper}=    Convert To Uppercase    ${http_addr}
    Should Be True   '${http_addr_upper}'!='NONE'

    ${username}    set variable    ${Log_Module_Default_ENB_OAM_HTTP_USERNAME}
    ${password}    set variable    ${Log_Module_Default_ENB_OAM_HTTP_PASSWORD}
    &{enb_oam_http_connection_info}    create dictionary    host=${http_addr}
    ...    username=${username}    password=${password}
    [Return]    ${enb_oam_http_connection_info}

product_config.Get Gnb LMP SSH Connection Info
    [Arguments]    ${bts_index}=${0}
    [Documentation]
    ...    Get gnb's LMP SSH connection information
    ...
    ...    Author: Liu Renhui
    ...    Contact: renhui-david.liu@nokia-sbell.com
    ...    | Input Parameters    | Man. | Description |
    ...    | bts_index | yes | BTS index |
    ...
    ...    | Return Value | Description |
    ...    | bts_http_connection_info | a dict |
    ...
    ...    Example
    ...   | product_config.Get Gnb LMP SSH Connection Info |
    ...
    ${addr}    set variable
    ...    ${tl.gnbs[${bts_index}].dus[0].airscale.common_units[0].lmp_connection.addr}
    ${username}    set variable    ${tl.gnbs[${bts_index}].dus[0].airscale.common_units[0].lmp_connection.username}
    ${password}    set variable    ${tl.gnbs[${bts_index}].dus[0].airscale.common_units[0].lmp_connection.password}
    &{connection_info}    create dictionary    host=${addr}
    ...    user=${username}    password=${password}
    [Return]    ${connection_info}

product_config.Get Enb LMP SSH Connection Info
    [Arguments]    ${bts_index}=${0}
    [Documentation]
    ...    Get enb's LMP SSH connection information
    ...
    ...    Author: Liu Renhui
    ...    Contact: renhui-david.liu@nokia-sbell.com
    ...    | Input Parameters    | Man. | Description |
    ...    | bts_index | yes | BTS index |
    ...
    ...    | Return Value | Description |
    ...    | bts_http_connection_info | a dict |
    ...
    ...    Example
    ...   | product_config.Get Enb LMP SSH Connection Info |
    ...
    # RRM CA
    ${addr}=    utility.check_nested_attributes    ${tl}
    ...    enbs[${bts_index}].airscale.common_units[0].lmp_connection.addr
    # OAM CA
    ${addr_upper}=    Convert To Uppercase    ${addr}
    ${addr}=    Run Keyword If    '${addr_upper}' == 'NONE'
    ...    check_nested_attributes    ${tl}    enbs[${bts_index}].system_module.common_units[0].lmp_connection.addr
    ...    ELSE    Set Variable    ${addr}
    ${addr_upper}=    Convert To Uppercase    ${addr}
    Should Be True   '${addr_upper}'!='NONE'

    &{enb_lmp_http_connection_info}    create dictionary    host=${addr}
    ...    user=${Log_Module_Default_SSH_USERNAME}    password=${Log_Module_Default_SSH_PASSWORD}
    [Return]    ${enb_lmp_http_connection_info}

product_config.Get Gnb LMP HTTP Connection Info
    [Arguments]    ${bts_index}=${0}
    [Documentation]
    ...    Get gnb's LMP http connection information
    ...
    ...    Author: Liu Renhui
    ...    Contact: renhui-david.liu@nokia-sbell.com
    ...    | Input Parameters    | Man. | Description |
    ...    | bts_index | yes | BTS index |
    ...
    ...    | Return Value | Description |
    ...    | bts_http_connection_info | a dict |
    ...
    ...    Example
    ...   | Get Gnb LMP HTTP Connection Info |
    ...
    ${http_addr}    set variable
    ...    ${tl.gnbs[${bts_index}].dus[0].airscale.common_units[0].lmp_connection.addr}
    ${username}    set variable    ${tl.gnbs[${bts_index}].cu.oam_http_connection_details.username}
    ${password}    set variable    ${tl.gnbs[${bts_index}].cu.oam_http_connection_details.password}
    &{gnb_lmp_http_connection_info}    create dictionary    host=${http_addr}
    ...    username=${username}    password=${password}
    [Return]    ${gnb_lmp_http_connection_info}

product_config.Get Enb LMP HTTP Connection Info
    [Arguments]    ${bts_index}=${0}
    [Documentation]
    ...    Get enb's LMP http connection information
    ...
    ...    Author: Liu Renhui
    ...    Contact: renhui-david.liu@nokia-sbell.com
    ...    | Input Parameters    | Man. | Description |
    ...    | bts_index | yes | BTS index |
    ...
    ...    | Return Value | Description |
    ...    | bts_http_connection_info | a dict |
    ...
    ...    Example
    ...   | Get Enb LMP HTTP Connection Info |
    ...
    # RRM CA
    ${http_addr}=    utility.check_nested_attributes    ${tl}
    ...    enbs[${bts_index}].airscale.common_units[0].lmp_connection.addr
    # OAM CA
    ${http_addr_upper}=    Convert To Uppercase    ${http_addr}
    ${http_addr}=    Run Keyword If    '${http_addr_upper}' == 'NONE'
    ...    check_nested_attributes    ${tl}    enbs[${bts_index}].system_module.common_units[0].lmp_connection.addr
    ...    ELSE    Set Variable    ${http_addr}
    ${http_addr_upper}=    Convert To Uppercase    ${http_addr}
    Should Be True   '${http_addr_upper}'!='NONE'

    ${username}    set variable    ${Log_Module_Default_ENB_LMP_HTTP_USERNAME}
    ${password}    set variable    ${Log_Module_Default_ENB_LMP_HTTP_PASSWORD}
    &{enb_lmp_http_connection_info}    create dictionary    host=${http_addr}
    ...    username=${username}    password=${password}
    [Return]    ${enb_lmp_http_connection_info}


################################ For CloudRAN #################################
product_config.Get vDU Http Connection Info
    [Arguments]    ${bts_index}=${0}
    ...            ${vdu_index}=${0}
    [Documentation]
    ...    This kw is used to fetch vDU's http connection info.
    ...
    ...    Author: Liu Renhui
    ...    Contact: renhui-david.liu@nokia-sbell.com
    ...    | Input Parameters    | Man. | Description |
    ...    | bts_index | yes |  |
    ...    | vdu_index | yes |  |
    ...
    ...    | Return Value | Description |
    ...    | vdu_info | a dict |
    ...
    ...    Example
    ...   | product_config.Get vDU Http Connection Info |
    ...
    [Return]    ${tl.gnbs[${bts_index}].dus[${vdu_index}].oam_http_connection_details}

product_config.Get vCU Http Connection Info
    [Arguments]    ${bts_index}=${0}
    [Documentation]
    ...    This kw is used to fetch vCU's http connection info.
    ...
    ...    Author: Liu Renhui
    ...    Contact: renhui-david.liu@nokia-sbell.com
    ...    | Input Parameters    | Man. | Description |
    ...    | bts_index | yes |  |
    ...
    ...    | Return Value | Description |
    ...    | vcu_info | a dict |
    ...
    ...    Example
    ...   | Prepare vCU Http Connection Info |
    ...
    [Return]    ${tl.gnbs[${bts_index}].cu.oam_http_connection_details}

product_config.Get BTS Http Connection Info
    [Arguments]    ${product_type}=vdu
    ...            ${bts_index}=${0}
    ...            ${cudu_index}=${0}
    ...            ${port}=443
    [Documentation]
    ...    Supported BTS products: vdu, vcu, classical. (classcial BTS is not ready now)
    ...
    ...    Author: Liu Renhui
    ...    Contact: renhui-david.liu@nokia-sbell.com
    ...    | Input Parameters    | Man. | Description |
    ...    | product_type | yes | classical/vcu/vdu |
    ...    | bts_index | yes | BTS index |
    ...    | cudu_index | yes | the index of cu or du |
    ...    | port | yes | https port |
    ...
    ...    | Return Value | Description |
    ...    | bts_http_connection_info | a dict |
    ...
    ...    Example
    ...   | Get BTS Http Connection Info |
    ...
    ${http_connection_info}=    Run Keyword If    '${product_type}' == 'vdu'
    ...    product_config.Get vDU Http Connection Info    bts_index=${bts_index}    vdu_index=${cudu_index}
    ...    ELSE IF  '${product_type}' == 'vcu'
    ...    product_config.Get vCU Http Connection Info    bts_index=${bts_index}

    ${http_addr}    set variable    ${http_connection_info.addr}
    ${web_ip}    set variable if    ':' in '''${http_addr}'''
    ...    [${http_addr}]    ${http_addr}
    ${username}    set variable    ${http_connection_info.username}
    # ${password}    set variable    ${http_connection_details.password}
    ${password}    set variable    Nokia@123
    &{bts_http_connection_info}    create dictionary    host=${web_ip}
    ...    username=${username}    password=${password}    port=${port}
    [Return]    ${bts_http_connection_info}

product_config.Get vDU Namespace
    [Arguments]    ${bts_index}=${0}
    ...            ${vdu_index}=${0}
    [Documentation]    this kw is used to Get vDU Namespace
    ...    Author: Liu Renhui
    ...    Contact: renhui-david.liu@nokia-sbell.com
    ...    | Input Parameters | Man. | Description |
    ...	   | bts_index | no | bts_index, default is 0 |
    ...
    [Return]    ${tl.gnbs[${bts_index}].dus[${vdu_index}].cloud_deployment.cloud_hosting.namespace}

product_config.Get vCU Namespace
    [Arguments]    ${bts_index}=0
    [Documentation]    this kw is used to Get CU/DU Namespace.
    ...    Author: Liu Renhui
    ...    Contact: renhui-david.liu@nokia-sbell.com
    ...    | Input Parameters | Man. | Description |
    ...	   | bts_index | no | bts_index, default is 0 |
    ...
    [Return]    ${tl.gnbs[${bts_index}].cloud_deployment.cloud_hosting.namespace}

product_config.Get BTS Namespace
    [Arguments]    ${product_type}=vdu
    ...            ${bts_index}=${0}
    ...            ${cudu_index}=${0}
    [Documentation]
    ...    Supported BTS products: vdu, vcu
    ...
    ...    Author: Liu Renhui
    ...    Contact: renhui-david.liu@nokia-sbell.com
    ...    | Input Parameters    | Man. | Description |
    ...    | product_type | yes | classical/vcu/vdu |
    ...    | bts_index | yes | BTS index |
    ...    | cudu_index | yes | the index of cu or du |
    ...
    ...    | Return Value | Description |
    ...    | bts_namespace |  |
    ...
    ...    Example
    ...   | product_config.Get BTS Namespace |
    ...
    ${namespace}=    Run Keyword If    '${product_type}' == 'vdu'
    ...    product_config.Get vDU Namespace    bts_index=${bts_index}    vdu_index=${cudu_index}
    ...    ELSE IF  '${product_type}' == 'vcu'
    ...    product_config.Get vCU Namespace    bts_index=${bts_index}
    [Return]    ${namespace}

product_config.Get vDU SSH Connection Info
    [Arguments]    ${bts_index}=${0}
    ...            ${vdu_index}=${0}
    [Documentation]
    ...    This kw is used to fetch vDU's SSH connection info.
    ...
    ...    Author: Liu Renhui
    ...    Contact: renhui-david.liu@nokia-sbell.com
    ...    | Input Parameters    | Man. | Description |
    ...    | bts_index | yes |  |
    ...    | vdu_index | yes |  |
    ...
    [Return]
    ...    ${tl.gnbs[${bts_index}].dus[${vdu_index}].cloud_deployment.cloud_hosting.master_node.ssh_connection_details}

product_config.Get vCU SSH Connection Info
    [Arguments]    ${bts_index}=${0}
    [Documentation]
    ...    This kw is used to fetch vCU's ssh connection info.
    ...
    ...    Author: Liu Renhui
    ...    Contact: renhui-david.liu@nokia-sbell.com
    ...    | Input Parameters    | Man. | Description |
    ...    | bts_index | yes |  |
    ...
    ...    Example
    ...   | product_config.Get vCU SSH Connection Info |
    ...
    [Return]    ${tl.gnbs[${bts_index}].cloud_deployment.cloud_hosting.master_node.ssh_connection_details}

product_config.Get BTS SSH Connection Info
    [Arguments]    ${product_type}=vdu
    ...            ${bts_index}=${0}
    ...            ${cudu_index}=${0}
    [Documentation]
    ...    Supported BTS products: vdu, vcu, classical. (classcial BTS is not ready now)
    ...
    ...    Author: Liu Renhui
    ...    Contact: renhui-david.liu@nokia-sbell.com
    ...    | Input Parameters    | Man. | Description |
    ...    | product_type | yes | classical/vcu/vdu |
    ...    | bts_index | yes | BTS index |
    ...    | cudu_index | yes | the index of cu or du |
    ...
    ...    Example
    ...   | product_config.Get BTS SSH Connection Info |
    ...
    ${con_info}=    Run Keyword If    '${product_type}' == 'vdu'
    ...    product_config.Get vDU SSH Connection Info    bts_index=${bts_index}    vdu_index=${cudu_index}
    ...    ELSE IF  '${product_type}' == 'vcu'
    ...    product_config.Get vCU SSH Connection Info    bts_index=${bts_index}

    ${http_addr}    set variable    ${con_info.addr}
    ${hostname}    set variable if    ':' in '''${http_addr}'''
    ...    [${http_addr}]    ${http_addr}
    &{bts_con_info}    create dictionary    hostname=${hostname}
    ...    username=${con_info.username}    password=${con_info.password}
    [Return]    ${bts_con_info}

product_config.Get vDU K8s Connection Info
    [Arguments]    ${bts_index}=${0}
    ...            ${vdu_index}=${0}
    [Return]
    ...    ${tl.gnbs[${bts_index}].dus[${vdu_index}].cloud_deployment.cloud_hosting.master_node.k8s_connection_details}

product_config.Get vCU K8s Connection Info
    [Arguments]    ${bts_index}=${0}
    [Return]    ${tl.gnbs[${bts_index}].cloud_deployment.cloud_hosting.master_node.k8s_connection_details}

product_config.Get BTS K8S Connection Info
    [Arguments]    ${product_type}=vdu
    ...            ${bts_index}=${0}
    ...            ${cudu_index}=${0}

    ${con_info}=    Run Keyword If    '${product_type}' == 'vdu'
    ...    product_config.Get vDU K8s Connection Info    bts_index=${bts_index}    vdu_index=${cudu_index}
    ...    ELSE IF  '${product_type}' == 'vcu'
    ...    product_config.Get vCU K8s Connection Info    bts_index=${bts_index}

    ${http_addr}    set variable    ${con_info.ip_addr}
    ${hostname}    set variable if    ':' in '''${http_addr}'''
    ...    [${http_addr}]    ${http_addr}
    &{bts_con_info}    create dictionary    hostname=${hostname}
    ...    username=${con_info.username}    password=${con_info.password}
    [Return]    ${bts_con_info}

product_config.Get Info From UTE Reservation File
    [Arguments]    ${key_list}    ${file_path}=${UTE_RESERVATION_CONTEXT_JSON}
    ${context}    OperatingSystem.Get File    ${file_path}
    &{context_dict}    json.Loads    ${context}
    ${dict}    Set Variable    ${context_dict}
    FOR    ${k}    IN    @{key_list}
        ${k_convert}    Run Keyword If    ${k.isdigit()}
        ...    Convert To Integer    ${k}
        ...    ELSE    Set Variable    ${k}
        ${dict}    Run Keyword If    ${k.isdigit()}
        ...    Set Variable    ${dict}[${k_convert}]
        ...    ELSE    Collections.Get From Dictionary    ${dict}    ${k_convert}
    END
    [Return]    ${dict}

product_config.Get Testline Type
    ${key_list}    Create List    CM_TOPOLOGY    name
    ${Testline_type}    product_config.Get Info From UTE Reservation File    key_list=${key_list}
    [Return]    ${Testline_type}
