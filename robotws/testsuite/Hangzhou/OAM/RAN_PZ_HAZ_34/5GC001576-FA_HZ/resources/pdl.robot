*** Settings ***
Documentation
...    Author: zhiyuan.ma@nokia.com
...    Maintainer: zhiyuan.ma@nokia.com
...    Team in charge: I_NJ_MMW_SYVE@internal.nsn.com

Library    Collections
Library    taf.sbts.oam.coam.admin  WITH NAME  coam
Resource    testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/robot/coam_gnb_classical.robot


*** Variables ***
${MAX_WAIT_TIME_COAM_CONFIGURED}    15 min
@{BTS_PROCEDURAL_STATES}            Configured    OnAir   IntegratedToRan
${ALIAS}=   cOAM
${tl_name}         ${tl.gnbs[0].instance_id}
${bts_id}          ${tl.gnbs[0].global_bts_id}
${scf_path}           ${CURDIR}/../../../../../../commissionings/HGZ/7_5_UTE5G401T701/
${scf_path_Jenkins}           ${CURDIR}/../../../../../../commissionings/HGZ/${testline_name}/
${scf_trunk}     SCF_711_trunk.xml
${scf_21B}      SCF_711_21B.xml

*** Keywords ***
Setup DU Admin
    [Arguments]  ${host}  ${port}=443  ${alias}=${ALIAS}
    Connect to gnb coam via ssl  bts_host=${host}   connection=${alias}

Teardown DU Admin
    [Arguments]  ${alias}=${ALIAS}
    coam.Teardown  connection=${alias}

Check DU Not Modifiable PDL
    [Arguments]    ${abbreviation}
    ...            ${object}
    ...            ${value}
    ${response}=  Change Parameter Value    parameter=${abbreviation}
    ...                                     dist_name=${object}
    ...                                     value=${value}
    Should Match Regexp  ${response}  parameter cannot be updated
    Should Contain  ${response}  ${abbreviation}

Check DU Modifiable PDL
    [Arguments]     ${abbreviation}
    ...             ${object}
    ...             ${incorrect_value}=${EMPTY}
    ...             ${correct_value}=${EMPTY}
    ...             ${del_flag}=${False}
    ...             ${del_parameter}=${EMPTY}
    Run Keyword If  "${incorrect_value}" != "${EMPTY}"
    ...     Change Parameter And Check Validation Rule  abbreviation=${abbreviation}
    ...                                                 object=${object}
    ...                                                 expected_result=Fail
    ...                                                 value=${incorrect_value}
    Run Keyword If  "${correct_value}" != "${EMPTY}"
    ...     Change Parameter And Check Validation Rule  abbreviation=${abbreviation}
    ...                                                 object=${object}
    ...                                                 expected_result=Pass
    ...                                                 value=${correct_value}
    ...                                                 del_parameter=${del_parameter}
    ...                                                 del_flag=${del_flag}

Change Parameter And Check Validation Rule
    [Arguments]     ${abbreviation}
    ...             ${object}
    ...             ${expected_result}
    ...             ${value}=${EMPTY}
    ...             ${del_flag}=${False}
    ...             ${del_parameter}=${EMPTY}
    ${response}=  Change Parameter Value    parameter=${abbreviation}
    ...                                     dist_name=${object}
    ...                                     value=${value}
    ...                                     del_parameter=${del_parameter}
    ...                                     del_flag=${del_flag}
    Check PDL Rule  rule=${abbreviation}
    ...             response=${response}
    ...             expected_result=${expected_result}

Change Parameter Value
    [Arguments]    ${parameter}=${EMPTY}
    ...            ${dist_name}=${EMPTY}
    ...            ${value}=${EMPTY}
    ...            ${del_parameter}=${EMPTY}
    ...            ${del_flag}=${False}
    ${del_result}=    Run keyword If    ${del_flag}    Delete object    dist_name=${dist_name}    parameter=${del_parameter}    connection=${ALIAS}
    ${result}=  Run keyword And Ignore Error  Perform Parameter Recommissioning     dist_name=${dist_name}
    ...                                                                             parameter=${parameter}
    ...                                                                             value=${value}
    ...                                                                             operation=update
    ...                                                                             skip_relation_errors=${False}
    ...                                                                             timeout=300
    ...                                                                             connection=${ALIAS}
    ${response}=  Convert To String  ${result}
    [Return]  ${response}

Check PDL Rule
    [Arguments]    ${rule}
    ...            ${response}
    ...            ${expected_result}
    Run Keyword If  "${expected_result}"=="Pass"
    ...     Run Keywords
    ...         Should Not Contain  ${response}  pdlValidationResult\': {u\'status\': u\'FAIL\  AND
    ...         Should Not Contain  ${response}  ${rule}
    Run Keyword If  "${expected_result}"=="Fail"
    ...     Run keywords
    ...         Should Match Regexp  ${response}  FAIL  AND
    ...         Should Contain  ${response}  ${rule}

Perform Parameter Recommissioning
    [Arguments]     ${dist_name}
    ...             ${parameter}
    ...             ${value}
    ...             ${operation}
    ...             ${skip_relation_errors}=${TRUE}
    ...             ${timeout}=300
    ...             ${connection}=${ALIAS}
    coam.Perform Parameter Recommissioning
    ...     dist_name=${dist_name}
    ...     parameter=${parameter}
    ...     value=${value}
    ...     operation=${operation}
    ...     skip_parameter_relation_errors=${skip_relation_errors}
    ...     timeout=${timeout}
    ...     connection=${connection}
    Wait Until Keyword Succeeds  ${MAX_WAIT_TIME_COAM_CONFIGURED}  30s
    ...     Verify DU Procedural State
    ...         alias=${alias}
    ...         proceduralStates=${BTS_PROCEDURAL_STATES}

Verify DU Procedural State
    [Arguments]  ${proceduralStates}  ${timeout}=30  ${alias}=${ALIAS}
    ${bts_status}=  coam.Get BTS Statuses  timeout=${timeout}  connection=${alias}
    List Should Contain Value  ${proceduralStates}  ${bts_status['proceduralState']}
    Should Be Equal  ${bts_status['blockingState']}  Unblocked  ignore_case=true

Delete object
    [Arguments]    ${dist_name}    ${parameter}    ${connection}=${ALIAS}
    ${status}=       coam.Perform Parameter Recommissioning    dist_name=${dist_name}
    ...                                                          parameter=${parameter}
    ...                                                          operation=delete
    ...                                                          value=${EMPTY}
    ...                                                          skip_parameter_relation_errors=${True}
    ...                                                          should_activate=${False}
    ...                                                          connection=${ALIAS}
    [Return]  ${status}

Save CU scf
    [Arguments]    ${host}=${CU_ip}
    selenium_cu.enable_virtual_display
    selenium_cu.login    url=https://${host}    browser=Firefox
    selenium_cu.choose_plan    plan_name=CURRENT_PLAN
    ${cu_scf_path}    selenium_cu.save_cu_configuration
    set global variable    ${cu_scf_path}
    log to console  ${cu_scf_path}
    [Return]   ${cu_scf_path}
    [Teardown]  Run Keyword And Ignore error    selenium_cu.logout

Import 711 DU Scf
    [Arguments]    ${bts_host}=${host_du}    ${connection}=GNB_CON
    Connect to gnb coam via ssl    bts_host=${bts_host}    username=${host_name}    password=${host_pass}    connection=${connection}
    ${version}    coam.get_sw_version     connection=${connection}
    ${version_list}    split string    ${version}    _
    ${if_common_load}     run keyword and return status    should contain    ${version_list[0]}    5G22R2
    ${scf1}    set variable if    ${if_common_load}    ${scf_path}${scf_trunk}
    ...    ${scf_path}${scf_21B}
    set suite variable    ${scf1}
    BuiltIn.Log    \n Input default SCF \n    console=yes
    run keyword and ignore error    COAM Commission with scf file    scf_file_path=${scf1}    connection=${connection}
    wait until keyword succeeds    15min    10 sec    COAM Check GNB cell on air    connection=${connection}
    coam.teardown    connection=${connection}

All Case Suite Setup
    [Arguments]
#    CI_interface.Common Suite Setup
#    Import 711 DU Scf

Import 701 DU Scf
    [Arguments]    ${bts_host}=${host_du}    ${connection}=GNB_CON
    Connect to gnb coam via ssl    bts_host=${bts_host}    username=${host_name}    password=${host_pass}    connection=${connection}
    ${version}    coam.get_sw_version     connection=${connection}
    ${version_list}    split string    ${version}    _
    ${if_common_load}     run keyword and return status    should contain    ${version_list[0]}    5G22R2
    ${scf1}    set variable if    ${if_common_load}   ${scf_path_Jenkins}${scf_trunk}
    ...    ${scf_path_Jenkins}${scf_21B}
    set suite variable    ${scf1}
    BuiltIn.Log    \n Input default SCF \n    console=yes
    run keyword and ignore error    COAM Commission with scf file    scf_file_path=${scf1}    connection=${connection}
    wait until keyword succeeds    15min    10 sec    COAM Check GNB cell on air    connection=${connection}
    coam.teardown    connection=${connection}


