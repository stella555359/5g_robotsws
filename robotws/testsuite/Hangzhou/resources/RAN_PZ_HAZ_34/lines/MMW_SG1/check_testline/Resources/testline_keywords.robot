*** Settings ***

Documentation
...          author:Wang Yixiang
...          contact:
...          description: testline check onair, if not onair,will commission.

Library       ./mytestline.py
Resource      ./../../common_resources.robot


*** Keywords ***
Testline check suite setup
    COAM Create log directory    is_set_to_test_case_level=${False}

Create connection and directory
    [Documentation]    Author: Wang Yixiang
    COAM Create log directory    is_set_to_test_case_level=${True}
    Connect to gnb coam via ssl
    Connect to eNB via ssl    connection=enblte

Get testline info
    [Documentation]    Author: Wang Yixiang
    [Arguments]    ${tl_name}   ${exec_path}
    ${tl}   import_testline_variable    tl_name=${tl_name}   exec_path=${exec_path}
    set test variable    ${tl}

Case teardown for testline
    [Documentation]    Author: Wang Yixiang
    [Arguments]    ${auto_running}=${False}
    run keyword if    '${auto_running}'=='${False}'    coam_gnb_classical.COAM Teardown gnb connections
    run keyword if    '${auto_running}'=='${False}'    Enblte close down    connection=enblte

Commission of LTE and NR
    [Documentation]    Author: Wang Yixiang
    [Arguments]    ${nr_default_scf_file}    ${enb_default_scf_file}=${None}
    ${is_enb_status_check_needed}     set variable if    '${enb_default_scf_file}'=='${None}'    ${False}    ${True}
    ${is_x2_check_from_enb_needed}    set variable if    '${enb_default_scf_file}'=='${None}'    ${False}    ${True}

    run keyword if    '${enb_default_scf_file}'!='${None}'    Commission on LTE
    ...    enb_default_scf_file=${enb_default_scf_file}
    ...    is_pdl_checking_needed=${False}

    _Sub classical suite setup    scf_template_path=${nr_default_scf_file}
    ...    is_enb_status_check_needed=${is_enb_status_check_needed}
    ...    is_x2_check_from_enb_needed=${is_x2_check_from_enb_needed}

Check if robot process running
    [Arguments]   ${ute_host}=${tl.test_pc.default_ssh_connection_details.addr}
    ...   ${ute_user}=${tl.test_pc.default_ssh_connection_details.username}
    ...   ${ute_password}=${tl.test_pc.default_ssh_connection_details.password}
    csn.Connect to   hostname=${ute_host}    username=${ute_user}    password=${ute_password}
    ...    alias=utehost
    ${robot_pid}    csn.execute    command=ps -ef|grep robot | grep -v grep | tail -n 1|awk '{print $2}'   connection=utehost
    ${auto_running}    run keyword and return status    should not be empty      ${robot_pid}
    [Return]   ${auto_running}
    [Teardown]   csn.Disconnect     connection=utehost
