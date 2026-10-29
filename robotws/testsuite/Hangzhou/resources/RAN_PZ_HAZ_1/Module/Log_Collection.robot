*** Settings ***
Documentation
...    Author: Liu, Renhui, Xiang, Liang
...    Email address: renhui-david.liu@nokia-sbell.com   liang.xiang@nokia-sbell.com
...    Maintainer: Xiang, Liang
...    The Log Module's common keywords. It is used to collect various types of logs from various BTS products.
...    All the bugs/new keyword needs/improvement should be raised in Jira and assign to the Maintainer.
...    Jira link: https://jiradc.ext.net.nokia.com/projects/PZ1HAZTA/issues
...    Guidelines for user: https://confluence.ext.net.nokia.com/display/SRANPRODHZHTA/05.+Module+of+Log+Collection
...    Examples: https://wrgitlab.int.net.nokia.com/RAN/robotws/-/tree/master/testsuite/Hangzhou/resources/RAN_PZ_HAZ_1/Module/Module_Test


Resource    library/_cloud_log_manager.robot
Resource    library/_classical_log_manager.robot
Resource    library/_common_log_manager.robot

*** Variables ***
${SITE_TYPE_Cloud}         _CloudRAN
${SITE_TYPE_Classical}     _ClassicalBTS

*** Keywords ***
Log Collection
    [Arguments]    ${operation}
    ...            ${log_type}
    ...            ${product_type}
    ...            ${bts_index}=${0}
    ...            ${cudu_index}=${0}
    ...            ${dict_argument}=${None}
    ...            ${timeout}=${300}
    [Documentation]
    ...    *Usage:*
    ...        - This keyword is used to collect various types of logs from various BTS products.
    ...        - For CloudRAN:
    ...        -     Available for vdu and vcu: wireshark, syslog and snapshot
    ...        -     Only availabe for vdu: bip and tti
    ...        -     Automatically-stop log types: syslog, snapshot, tss(troubleshooting scripts)
    ...    *Author:*
    ...        - renhui-david.liu@nokia-sbell.com
    ...    *Args:*
    ...    | Input Parameters | Man. | Description |
    ...    | operation | Yes | start, stop_and_download, download |
    ...    | log_type | Yes | bip, wireshark, tti, syslog, snapshot, cell_trace, etc. |
    ...    | product_type | Yes | vdu, vcu, gnb, enb |
    ...    | bts_index | Yes | The list index from tl.cu[]  |
    ...    | cudu_index | Yes | the index of cu, du or classical bts  |
    ...    | dict_argument | No | { dcap_server: {host: x, username: x, password: x, port: x}, argument: {} } |
    ...    |               |    | For bip from gnb: { dcap_server: {}, argument: {bip_options: x} } |
    ...    |               |    | For wireshark from gnb/enb: { dcap_server: {}, argument: {wireshark_options: x} } |
    ...    | timeout | No  |    |
    ...    *Example:*
    ...        - Log Collection    start    syslog    product_type=vdu    bts_index=${0}    cudu_index=${0}
    ...        - Log Collection    start    wireshark_cp    product_type=vdu    bts_index=${0}    cudu_index=${0}
    ...
    ${product_type}=    Convert To Lowercase    ${product_type}
    ${SITE_TYPE}    Set Variable If    '${product_type}' == 'vdu' or '${product_type}' == 'vcu'    ${SITE_TYPE_Cloud}
    ...    '${product_type}' == 'gnb' or '${product_type}' == 'enb'    ${SITE_TYPE_Classical}
    Run Keyword    ${SITE_TYPE}.validate_product_indices    ${product_type}    ${bts_index}    ${cudu_index}
    _CommonBTS.Create Log Directory For Log Module
    ${result}    Run Keyword If    '+' in '${log_type}' or '${log_type}' == 'collection_profile'
    ...    ${SITE_TYPE}.${operation}_collection_profile_log
    ...    ${log_type}
    ...    bts_index=${bts_index}
    ...    product_type=${product_type}
    ...    cudu_index=${cudu_index}
    ...    dict_argument=${dict_argument}
    ...    timeout=${timeout}
    ...    ELSE    Run Keyword
    ...    ${SITE_TYPE}.${operation}_${log_type}_log
    ...    ${log_type}
    ...    bts_index=${bts_index}
    ...    product_type=${product_type}
    ...    cudu_index=${cudu_index}
    ...    dict_argument=${dict_argument}
    ...    timeout=${timeout}

    [Return]    ${result}
