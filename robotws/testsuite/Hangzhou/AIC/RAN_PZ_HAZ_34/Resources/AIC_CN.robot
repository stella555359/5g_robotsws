*** Settings ***
Documentation
...    Author: Yang mengli
...    Email address: mengli.yang@nokia-sbell.com
...    Maintainer: Lou Sudi;    Lv Feng
...    Email address: sudi.lou@nokia-sbell.com;    feng.1.lv@nokia-sbell.com;
...    Common KWs related to some operation of AIC CN.
...    Please do not modify the file without notification to author
...    All the bugs/new keyword needs/improvement should be raised in Jira and assign to the Maintainer
...    Jira link: https://jiradc.ext.net.nokia.com/projects/PZ1HAZTA/issues
...    Guideline: https://confluence.ext.net.nokia.com/display/SRANPRODHZHTA/09.+AIC+Common+Resource+Supporting+Mode+Improvement



*** Variables ***

*** Keywords ***
CMAS Notification
    [Arguments]    ${amf}=&{AMF6_Han}
    ...            ${message_identifier}=4372
    ...            ${serial_number}=51
    ...            ${repetition_period}=5
    ...            ${number_of_broadcasts_requested}=${10}
    ...            ${connection}=${cbctest_alias}
    ...            ${content_idx}=${0}
    ...            ${test_amf_name}=test_amf_RRM3.py
    ...            ${testcase_name}=testcase
    ...            ${nr_of_bits_g_node_b_id}=22
    ...            ${cell_id}=2
    [Documentation]    Author: Yang Mengli
    ...                Contact: mengli.yang@nokia-sbell.com
    ...                This kw is to trigger the CMAS notification.
    ...
    ...    | Input Parameters | Man. | Description |
    ...    | ${amf} | No | Default is &{AMF6_Han} |
    ...    | ${message_identifier} | No | Default is 4372 |
    ...    | ${serial_number} | No | Default is 51 |
    ...    | ${repetition_period} | No | Default is 5 |
    ...    | ${number_of_broadcasts_requested} | No | Default is ${10} |
    ...    | ${connection} | No | Default is ${cbctest_alias} |
    ...    | ${content_idx} | No | Default is ${0} |
    ...    | ${test_amf_name} | No | Default is test_amf_RRM3.py |
    ...    | ${testcase_name} | No | Default is testcase |
    ...    | ${nr_of_bits_g_node_b_id} | No | Default is 22 |
    ...    | ${cell_id} | No | Default is 2 |
    ...
    ...    | Return Value | Description |
    ...    | No | NA |
    ...
    ...    Example
    ...    | CMAS Notification | amf=${tang_amf} |
    ...    | ...               | message_identifier=4372 |
    ...    | ...               | serial_number=51 |
    ...    | ...               | repetition_period=5 |
    ...    | ...               | number_of_broadcasts_requested=${10} |
    ...    | ...               | connection=${cbctest_alias} |
    ...    | ...               | nr_of_bits_g_node_b_id=32 |
    ...    | ...               | cell_id=1 |
    Connect to Cbctest
    #ssh.upload_file    local_path=${cbctest_path}/${test_amf_name}    remote_path=/home/cbctest    connection=${cbctest_alias}
    #ssh.upload_file    local_path=${cbctest_path}/${testcase_name}    remote_path=/home/cbctest    connection=${cbctest_alias}
    ${cmd_local}    catenate    ${cbctest_path}/${testcase_name} ${cbctest_path}/${test_amf_name}
    ...                         ${amf}[connect_hostname] ${amf}[mcc] ${amf}[mnc]
    ...                         ${amf}[tac] ${MRBTS_ID} ${nr_of_bits_g_node_b_id}
    ...                         ${message_identifier} ${serial_number} ${repetition_period}
    ...                         ${number_of_broadcasts_requested} ${cell_id}
    csn.send_command    command=${cmd_local}    connection=${connection}
    Sleep    10s
    csn.read_output    connection=${connection}

CMAS PWS Cancel
    [Arguments]    ${amf}=&{AMF6_Han}
    ...            ${message_identifier}=4372
    ...            ${serial_number}=51
    ...            ${connection}=${cbctest_alias}
    ...            ${PWS_Cancel_name}=pws_cancel_RRM3.py
    ...            ${testcase_name}=testcase
    ...            ${nr_of_bits_g_node_b_id}=22
    ...            ${cell_id}=2
    [Documentation]    Author: Yang Mengli
    ...                Contact: mengli.yang@nokia-sbell.com
    ...                This kw is to trigger the CMAS notification.
    ...
    ...    | Input Parameters | Man. | Description |
    ...    | ${amf} | No | Default is &{AMF6_Han} |
    ...    | ${message_identifier} | No | Default is 4372 |
    ...    | ${serial_number} | No | Default is 51 |
    ...    | ${connection} | No | Default is ${cbctest_alias} |
    ...    | ${PWS_Cancel_name} | No | Default is pws_cancel_RRM3.py |
    ...    | ${testcase_name} | No | Default is testcase |
    ...    | ${nr_of_bits_g_node_b_id} | No | Default is 22 |
    ...
    ...    | Return Value | Description |
    ...    | No | NA |
    ...
    ...    Example
    ...    | CMAS PWS Cancel | amf=&{AMF6_Han} |
    ...    | ...             | nr_of_bits_g_node_b_id=32 |
    ...    | ...             | cell_id=1 |
    ...    | ...             | connection=${cbctest_alias} |
    ...
    Connect to Cbctest
    #ssh.upload_file    local_path=${cbctest_path}/${PWS_Cancel_name}    remote_path=/home/cbctest    connection=${cbctest_alias}
    #ssh.upload_file    local_path=${cbctest_path}/${testcase_name}    remote_path=/home/cbctest    connection=${cbctest_alias}
    ${cmd_local}    catenate    ${cbctest_path}/${testcase_name} ${cbctest_path}/${PWS_Cancel_name}
    ...                         ${amf}[connect_hostname] ${amf}[mcc] ${amf}[mnc]
    ...                         ${amf}[tac] ${MRBTS_ID} ${nr_of_bits_g_node_b_id}
    ...                         ${message_identifier} ${serial_number} ${cell_id}
    csn.send_command    command=${cmd_local}    connection=${connection}
    Sleep    20s
    csn.read_output    connection=${connection}

Connect to Cbctest
    [Documentation]    Author: Yang Mengli
    ...                Contact: mengli.yang@nokia-sbell.com
    ...                This kw is to connect to the cbc server
    ...
    ...    | Input Parameters | Man. | Description |
    ...    | No. | NA | NA |
    ...
    ...    | Return Value | Description |
    ...    | No | NA |
    ...
    ...    Example
    ...    | Connect to Cbctest |
    ...
    csn.connect to    hostname=${cbctest_ip}
    ...               username=${cbctest_usr}
    ...               password=${cbctest_psw}
    ...               alias=${cbctest_alias}
