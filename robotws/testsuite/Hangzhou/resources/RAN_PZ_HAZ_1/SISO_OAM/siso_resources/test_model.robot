*** Settings ***
Documentation
...    Author:    Wu Amy;Zhou Qiang;Ding Lisa
...    Maintainer:    Wu Amy;Zhou Qiang;Ding Lisa

Library    Collections
Library    OperatingSystem
Library    String


*** Variables ***
${gve_team}=    SISO_CRT

*** Keywords ***

Create BTSCONFIG Dictionary
    ${BTS_CONFIG}    Create Dictionary    FR=&{EMPTY}    FSM=&{EMPTY}    EC=&{EMPTY}    HOST_IP=&{EMPTY}
    Set Suite Variable    ${BTS_CONFIG}
    ${site_count}    Get Length    ${tl.test_pcs}
    ${status}    Run Keyword And Return Status    Get Length    ${tl.gnbs}
    ${gnbs_count}    Run Keyword If    ${status}    Get Length    ${tl.gnbs}
    ...    ELSE    Set Variable    ${0}
    FOR    ${index}    IN RANGE    ${site_count}
        ${node_id}    Evaluate    ${index}+1
        ${host_ip}    Set Variable    ${tl.test_pcs[${index}].default_ssh_connection_details.addr}
        ${index2}    Run Keyword If    ${index} < ${gnbs_count}    Set Variable    ${index}
        ...    ELSE    Evaluate    ${index}-${gnbs_count}
        Run Keyword If    ${index} < ${gnbs_count}    Run Keywords    Create SM_GNB Dictionary    ${index2}    ${node_id}
        ...    AND    Create RU_GNB Dictionary    ${index2}
        ...    AND    Create EC_GNB Dictionary    ${index2}
        ...    ELSE    Run Keywords    Create SM_ENB Dictionary    ${index2}    ${node_id}
        ...    AND    Create RU_ENB Dictionary    ${index2}
        ...    AND    Create EC_ENB Dictionary    ${index2}
        Set To Dictionary    ${BTS_CONFIG['HOST_IP']}    TL${node_id}=${host_ip}
    END
    ${status}    Run Keyword And Return Status    Variable Should Exist    ${FHS_INFO}
#    ${FHS_INFO}    Run Keyword If    ${status}     Evaluate    ${FHS_INFO}
    Run Keyword If    ${status}    Set To Dictionary    ${BTS_CONFIG}    FHS=${FHS_INFO}
    ${match}    ${conf_root_path}    Should Match Regexp     ${CURDIR}    (.*)/testsuite
    ${conf_path}=    Run Keyword And Return Status    Should Contain    ${CONFIGURATION}    \.
    ${SITE}    ${testline}=   Run Keyword If    ${conf_path}    Split String     ${CONFIGURATION}    .
    ${testline_name}    Get Variable Value    ${testline_name}    null
    ${TL_NAME}    Set Variable If    "${testline_name}"=="null" or "${testline_name}"=="${EMPTY}"
    ...    ${testline}    ${testline_name}
    ${git_node_status}    Run Keyword And Return Status    OperatingSystem.Directory Should Exist
    ...    ${conf_root_path}/commissionings/HGZ/${TL_NAME}/node1
    ${gerrit_node_status}    Run Keyword And Return Status    OperatingSystem.Directory Should Exist
    ...    /home/ute/testline_configuration/${TL_NAME}/node1
    ${config_path}    Set Variable If    ${git_node_status}    ${conf_root_path}/commissionings/HGZ/${TL_NAME}/
    ...    ${gerrit_node_status}    /home/ute/testline_configuration/${TL_NAME}
    Set Suite Variable    ${CONFIG_PATH}
    Set Suite Variable    ${TL_NAME}
    Log Dictionary    ${BTS_CONFIG}

Create SM_GNB Dictionary
    [Arguments]      ${index}    ${node_id}
    ${sm_serial_number}=    Set Variable    ${tl.gnbs[${index}].dus[0].airscale.common_units[0].serial_number}
    ${sm_pdu_addr}=    Set Variable    ${tl.gnbs[${index}].dus[0].airscale.common_units[0].pdu_port.pdu.addr}
    ${sm_pdu_model}=    Set Variable    ${tl.gnbs[${index}].dus[0].airscale.common_units[0].pdu_port.pdu.vendor}
    ${sm_pdu_port}=    Set Variable    ${tl.gnbs[${index}].dus[0].airscale.common_units[0].pdu_port.port_no}
    ${pdu_dict}=    Create Dictionary    port=${sm_pdu_port}    type=${sm_pdu_model}    ip_addr=${sm_pdu_addr}
    ${tl_pdu_dict}=    Create Dictionary   pdu=${pdu_dict}    node=TL${node_id}
    Set To Dictionary    ${BTS_CONFIG['FSM']}    ${sm_serial_number}=${tl_pdu_dict}

Create SM_ENB Dictionary
    [Arguments]      ${index}    ${node_id}
    ${status}    Run Keyword And Return Status    Should Not Be Equal    ${tl.enbs[${index}].airscale}    ${None}
    ${module}    Set Variable If    "${status}"=="True"     airscale    system_module
    ${sm_serial_number}=    Set Variable    ${tl.enbs[${index}].${module}.common_units[0].serial_number}
    ${sm_pdu_addr}=    Set Variable    ${tl.enbs[${index}].${module}.common_units[0].pdu_port.pdu.addr}
    ${sm_pdu_model}=    Set Variable    ${tl.enbs[${index}].${module}.common_units[0].pdu_port.pdu.vendor}
    ${sm_pdu_port}=    Set Variable    ${tl.enbs[${index}].${module}.common_units[0].pdu_port.port_no}
    ${pdu_dict}=    Create Dictionary    port=${sm_pdu_port}    type=${sm_pdu_model}    ip_addr=${sm_pdu_addr}
    ${tl_pdu_dict}=    Create Dictionary   pdu=${pdu_dict}    node=TL${node_id}
    Set To Dictionary    ${BTS_CONFIG['FSM']}    ${sm_serial_number}=${tl_pdu_dict}

Create RU_GNB Dictionary
    [Arguments]      ${index}
    ${list_lenght}=    Get Length    ${tl.gnbs[${index}].dus[0].rus}
    ${tl_ru_dict}=    Create Dictionary    &{EMPTY}
    FOR    ${ru}    IN RANGE    ${list_lenght}
        ${ru_serial_number}=    Set Variable    ${tl.gnbs[${index}].dus[0].rus[${ru}].serial_number}
        ${ru_pdu_addr}=    Set Variable    ${tl.gnbs[${index}].dus[0].rus[${ru}].pdu_port.pdu.addr}
        ${ru_pdu_model}=    Set Variable    ${tl.gnbs[${index}].dus[0].rus[${ru}].pdu_port.pdu.vendor}
        ${ru_pdu_port}=    Set Variable    ${tl.gnbs[${index}].dus[0].rus[${ru}].pdu_port.port_no}
        ${pdu_dict}=    Create Dictionary    port=${ru_pdu_port}    type=${ru_pdu_model}    ip_addr=${ru_pdu_addr}
        ${tl_pdu_dict}=    Create Dictionary   pdu=${pdu_dict}
        ${ru_list}    Get Dictionary Keys    ${BTS_CONFIG['FR']}
        Run Keyword If    "${ru_serial_number}" not in "${ru_list}"
        ...    Set To Dictionary    ${BTS_CONFIG['FR']}    ${ru_serial_number}=${tl_pdu_dict}
    END

Create RU_ENB Dictionary
    [Arguments]      ${index}
    ${list_lenght}=    Get Length    ${tl.enbs[${index}].rms}
    ${tl_ru_dict}=    Create Dictionary    &{EMPTY}
    FOR    ${ru}    IN RANGE    ${list_lenght}
        ${ru_serial_number}=    Set Variable    ${tl.enbs[${index}].rms[${ru}].serial_number}
        ${ru_pdu_addr}=    Set Variable    ${tl.enbs[${index}].rms[${ru}].pdu_port.pdu.addr}
        ${ru_pdu_model}=    Set Variable    ${tl.enbs[${index}].rms[${ru}].pdu_port.pdu.vendor}
        ${ru_pdu_port}=    Set Variable    ${tl.enbs[${index}].rms[${ru}].pdu_port.port_no}
        ${pdu_dict}=    Create Dictionary    port=${ru_pdu_port}    type=${ru_pdu_model}    ip_addr=${ru_pdu_addr}
        ${tl_pdu_dict}=    Create Dictionary   pdu=${pdu_dict}
        ${ru_list}    Get Dictionary Keys    ${BTS_CONFIG['FR']}
        Run Keyword If    "${ru_serial_number}" not in "${ru_list}"
        ...    Set To Dictionary    ${BTS_CONFIG['FR']}    ${ru_serial_number}=${tl_pdu_dict}
    END

Create EC_GNB Dictionary
    [Arguments]      ${index}
    ${ec_serial_number}=    Set Variable     ${tl.gnbs[${index}].dus[0].airscale.common_units[0].capacity_units}
    ${list_lenght}=    Get Length    ${tl.gnbs[${index}].dus[0].airscale.common_units[0].capacity_units}
    ${tl_ec_dict}=    Create Dictionary    &{EMPTY}
    FOR    ${ec}    IN RANGE    ${list_lenght}
        ${ec_serial_number}=    Set Variable
        ...   ${tl.gnbs[${index}].dus[0].airscale.common_units[0].capacity_units[${ec}].serial_number}
        ${ec_pdu_addr}=    Set Variable
        ...   ${tl.gnbs[${index}].dus[0].airscale.common_units[0].capacity_units[${ec}].pdu_port.pdu.addr}
        ${ec_pdu_model}=    Set Variable
        ...   ${tl.gnbs[${index}].dus[0].airscale.common_units[0].capacity_units[${ec}].pdu_port.pdu.vendor}
        ${ec_pdu_port}=    Set Variable
        ...   ${tl.gnbs[${index}].dus[0].airscale.common_units[0].capacity_units[${ec}].pdu_port.port_no}
        ${pdu_dict}=    Create Dictionary    port=${ec_pdu_port}    type=${ec_pdu_model}    ip_addr=${ec_pdu_addr}
        ${tl_pdu_dict}=    Create Dictionary   pdu=${pdu_dict}
        Set To Dictionary    ${BTS_CONFIG['EC']}    ${ec_serial_number}=${tl_pdu_dict}
    END

Create EC_ENB Dictionary
    [Arguments]      ${index}
    ${status}    Run Keyword And Return Status    Should Not Be Equal    ${tl.enbs[${index}].airscale}    ${None}
    ${module}    Set Variable If    "${status}"=="True"     airscale    system_module
    ${ec_serial_number}=    Set Variable     ${tl.enbs[${index}].${module}.common_units[0].capacity_units}
    ${list_lenght}=    Get Length    ${tl.enbs[${index}].${module}.common_units[0].capacity_units}
    ${tl_ec_dict}=    Create Dictionary    &{EMPTY}
    FOR    ${ec}    IN RANGE    ${list_lenght}
        ${ec_serial_number}=    Set Variable
        ...    ${tl.enbs[${index}].${module}.common_units[0].capacity_units[${ec}].serial_number}
        ${ec_pdu_addr}=    Set Variable
        ...    ${tl.enbs[${index}].${module}.common_units[0].capacity_units[${ec}].pdu_port.pdu.addr}
        ${ec_pdu_model}=    Set Variable
        ...    ${tl.enbs[${index}].${module}.common_units[0].capacity_units[${ec}].pdu_port.pdu.vendor}
        ${ec_pdu_port}=    Set Variable
        ...    ${tl.enbs[${index}].${module}.common_units[0].capacity_units[${ec}].pdu_port.port_no}
        ${pdu_dict}=    Create Dictionary    port=${ec_pdu_port}    type=${ec_pdu_model}    ip_addr=${ec_pdu_addr}
        ${tl_pdu_dict}=    Create Dictionary   pdu=${pdu_dict}
        Set To Dictionary    ${BTS_CONFIG['EC']}    ${ec_serial_number}=${tl_pdu_dict}
    END
