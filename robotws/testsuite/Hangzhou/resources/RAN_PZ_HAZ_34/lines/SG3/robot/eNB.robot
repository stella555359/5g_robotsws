*** Settings ***
Documentation
...    author: Zhang Yayun
...    contact: yayun.zhang@nokia-sbell.com
...    squad group: SG_03


Library    testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/lines/SG3/gnb_operations.py

Resource    testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/robot/enb_lte.robot
Resource    testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/robot/coam_gnb_classical.robot

*** Variables ***
${ENB_ADDRESS}    ${tl.enbs[0].airscale.common_units[0].lmp_connection.addr}
${asik_username}    ${tl.enbs[0].airscale.common_units[0].lmp_connection.username}
${asik_password}    ${tl.enbs[0].airscale.common_units[0].lmp_connection.password}
${enb_para}    administrativeState

*** Keywords ***
Connect and commission enb
    [Arguments]    ${enb_scf_file_name}    ${connection}=enb     ${enb_index}=${0}
    Connect to eNB via ssl    connection=${connection}     enb_index=${enb_index}
    COAM Commission with scf file    scf_file_path=${tl_scf_dir_path}${enb_scf_file_name}    timeout=800    is_pdl_checking_needed=${False}
    ...    connection=${connection}
    [Teardown]    coam.teardown    connection=${connection}

Modify the enblte parameter
    [Arguments]    ${dist_name}    ${parameter}     ${value}    ${enb_index}=${0}
    Connect to eNB via ssl    enb_index=${enb_index}
    enblte.perform_parameter_recommissioning       dist_name=${dist_name}
    ...                                            parameter=${parameter}
    ...                                            operation=update
    ...                                            value=${value}
    ...                                            connection=enblte
    enblte.teardown    connection=enblte


wait the eNB onair
    [Arguments]    ${enb_alias}=enblte    ${timeout}=10 min    ${enb_index}=${0}
    Wait until enb cell on air status    enb_alias=${enb_alias}    timeout=${timeout}    enb_index=${enb_index}

paras change on LTE
    [Arguments]    ${paras}    ${delta_file_name}    ${enb_index}=${0}    ${skip_parameter_relation_errors}=False
    ...    ${connection}=enblte
    paras_convert_to_json_file    data=${paras}    json_path=${delta_file_name}
    recommission with delta file on LTE    delta_file_name=${delta_file_name}    enb_index=${enb_index}
    ...    skip_parameter_relation_errors=${skip_parameter_relation_errors}    connection=${connection}

recommission with delta file on LTE
    [Arguments]
    ...    ${delta_file_name}
    ...    ${enb_index}=${0}
    ...    ${skip_parameter_relation_errors}=False
    ...    ${connection}=enblte
    Connect to eNB via ssl    enb_index=${enb_index}
    enblte.perform_delta_recommissioning    delta_file=${delta_file_name}    timeout=${300}
    ...    skip_parameter_relation_errors=${skip_parameter_relation_errors}    connection=${connection}
    sleep    5
    [Teardown]  Run keyword and ignore error    enblte.teardown    connection=enblte

COAM eNB Reset site via api
    [Arguments]   ${enb_index}=${0}    ${is_need_check_cell_onair}=True    ${wait_for_reconnection}=True
    Connect to eNB via ssl    enb_index=${enb_index}
    coam.reset_site    wait_for_reconnection=${wait_for_reconnection}    connection=enblte
    enblte.teardown    connection=enblte
    Run Keyword If    ${is_need_check_cell_onair}==True    run keyword
    ...    Wait Until Keyword Succeeds    15min    30sec    wait the eNB onair    enb_alias=enblte    enb_index=${enb_index}
    [Teardown]    Run keyword and ignore error    enblte.teardown    connection=enblte
