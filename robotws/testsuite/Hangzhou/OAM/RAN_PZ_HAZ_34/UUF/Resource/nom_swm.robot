*** Settings ***
Documentation     author: Sherry Zhang
...         contact: sherry.1.zhang@nokia-sbell.com
...         Upgrade and Rollback UUF case.

Library   BuiltIn
Library   XML   True
Library   String
Library   DateTime
Library   Collections
Library   OperatingSystem
Library     taf.nms.nom         WITH NAME   nom
Library     taf.transport.ssh   WITH NAME   csn
Resource    testsuite/Hangzhou/OAM/RAN_PZ_HAZ_34/UUF/Resource/common.robot

*** Variables ***

*** Keywords ***
Integrade Bts Site to Nom
    [Arguments]   ${bts_id}
    log to console    Start to integrate ne
    ${integrate_dict}    nom.integrate_ne    plan_name=tl-${bts_id}-integration-plan    timeout=60
    FOR   ${integrate_status}   IN   @{integrate_dict}
       ${operation_id}    Get From Dictionary    ${integrate_status}    operation_id
       ${status}    Get From Dictionary    ${integrate_status}    status
       Exit for loop if    '${status}'=='finished'
    END
    log to console    Integrade Bts Site to Nom ${status}
    [Return]   ${operation_id}

Deintegrade Bts Site to Nom
    [Arguments]   ${bts_id}
    log to console    Start to deintegrate ne
    ${deintegrate_dict}    nom.deintegrate_ne    plan_name=tl-${bts_id}-deintegration-plan    timeout=20
    FOR   ${deintegrate_status}   IN   @{deintegrate_dict}
       ${operation_id}    Get From Dictionary    ${deintegrate_status}    operation_id
       ${status}    Get From Dictionary    ${deintegrate_status}    status
       Exit for loop if    '${status}'=='finished'
    END
    log to console    Deintegrade Bts Site to Nom ${status}
    [Return]   ${operation_id}

Get Nom Uri and Password
    [Arguments]   ${nom_nodeip}
    ${apigw_url}   set variable    ${nom_global_configuration['${nom_nodeip}']['apigw_url']}
    ${user_mgmt_url}   set variable    ${nom_global_configuration['${nom_nodeip}']['mgnt_url']}
    ${openapi_password}   set variable    ${nom_global_configuration['${nom_nodeip}']['openapi_password']}
    ${client_id}    Generate Random String
    [Return]    ${apigw_url}    ${user_mgmt_url}    ${openapi_password}    ${client_id}

Nom Login
    [Arguments]    ${apigw_url}    ${user_mgmt_url}    ${password}    ${client_id}
    ${nom_rf_secret}   nom.register_the_client
    ...   client_id=${client_id}
    ...   username=${nom_username}
    ...   password=${password}
    ...   apigw_uri=${apigw_url}
    nom.connect_to
    ...   user_mgmt_uri=${user_mgmt_url}
    ...   apigw_uri=${apigw_url}
    ...   client_id=${client_id}
    ...   client_secret=${nom_rf_secret}
    ...   port=443
    ...   username=${nom_username}
    ...   password=${password}
    ...   nom_version=nom_v1
    ...   secure=${True}

Nom Logout
    [Arguments]    ${apigw_url}    ${password}    ${client_id}
    nom.delete_the_client
    ...   client_id=${client_id}
    ...   username=${nom_username}
    ...   password=${password}
    ...   apigw_uri=${apigw_url}

Trigger SW Operation from Nom
    [Arguments]   ${operation}    ${nom_nodeip}   ${bts_id}    ${version}
    ${wait_time}    run keyword if  ${passive_not_target} and '${operation}'!='rollback'    set variable    60 min
    ...    ELSE    run keyword if    '${operation}'=='rollback'    set variable    1 min
    ...    ELSE    set variable    10 min
    ${apigw_url}    ${user_mgmt_url}    ${password}    ${client_id}    Get Nom Uri and Password    ${nom_nodeip}
    ${login_status}    run keyword and return status    Nom Login    ${apigw_url}    ${user_mgmt_url}    ${password}    ${client_id}
    run keyword if  not ${login_status}    run keywords
    ...    run keyword and ignore error    Nom Logout    ${apigw_url}    ${password}    ${client_id}
    ...    AND    Nom Login    ${apigw_url}    ${user_mgmt_url}    ${password}    ${client_id}
    log to console    Start Nom SWM ${operation}
    ${BTS_NAME}     Create List    MRBTS-${bts_id}
    ${operation_status}    run keyword if  '${operation}'=='provision'
    ...    nom.provision_sw    ${BTS_NAME}    ${version}    timeout=10    run_async=${True}
    ...    ELSE IF    '${operation}'=='rollback'    nom.rollback_sw    ${BTS_NAME}    timeout=540
    Wait Until Keyword Succeeds   ${wait_time}   20 s    Expect nom operation status finished    ${operation_status}    ${operation}
    [Teardown]   run keyword and ignore error    Nom Logout    ${apigw_url}    ${password}    ${client_id}

Get operation status with operation id
    [Arguments]    ${operation_id_dict}
    ${operation_id}    Get From Dictionary    ${operation_id_dict}    operation_id
    ${operation_ids}    create list    ${operation_id}
    ${status}   ${status1}    run keyword and ignore error    nom.get_operation_status    ${operation_ids}
    [Return]    ${status1}

Expect nom operation status finished
    [Arguments]    ${operation_status}    ${operation}==provision
    ${operation_status}    run keyword if  '${operation}'=='provision'    Get operation status with operation id    ${operation_status}
    ...    ELSE     set variable    ${operation_status}
    ${status_list}    create list
    FOR  ${item}  IN   @{operation_status}
        ${operation_status}    Get From Dictionary    ${item}    status
        ${operation_status}    convert to lowercase    ${operation_status}
        append to list    ${status_list}    ${operation_status}
        should not contain    ${operation_status}    fail
    END
    list should contain value    ${status_list}    finished
