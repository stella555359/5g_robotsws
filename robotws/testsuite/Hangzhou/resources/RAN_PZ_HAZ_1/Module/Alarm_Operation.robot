*** Settings ***
Documentation
...    Author: Xiang Liangliang(Cloud BTS Part)
...            Li Amaand(Classical BTS Part)
...    Email address: liang.xiang@nokia-sbell.com; amaand.li@nokia-sbell.com;
...    Maintainer: Xiang Liangliang;    Li Amaand
...    Common KWs for alarm related operation.
...    All the bugs/new keyword needs/improvement should be raised in Jira and assign to the Maintainer
...    Jira link: https://jiradc.ext.net.nokia.com/projects/PZ1HAZTA/issues
...    Guideline: https://confluence.ext.net.nokia.com/display/SRANPRODHZHTA/07.+Module+of+Alarm+Operation

Resource    ./library/_Cloud_Alarm_Operation.robot
Resource    ./library/_Classical_Alarm_Operation.robot





*** Keywords ***
Alarm Operation
    [Arguments]  ${operation}
    ...          ${product_type}
    ...          ${bts_index}=${0}
    ...          ${cudu_index}=${0}
    ...          ${expected_alarms}=${None}
    ...          ${ignored_alarms}=${None}
    ...          ${critical_alarms}=${None}
    ...          ${timeout}=${300}
    [Documentation]  Alarm Operation
    ...    Author: Xiang Liangliang, Li Amaand
    ...    liang.xiang@nokia-sbell.com; amaand.li@nokia-sbell.com;
    ...   | Input Parameters | Man. | Description |
    ...   | operation  | Yes |  operation type |
    ...   |            |     | get_active_alarms, get_alarms_history, get_alarms |
    ...   |            |     | check_active_alarms |
    ...   |            |     | start_watch_alarms, get_watched_alarms, stop_watch_alarms |
    ...   |            |     | alarm_analysis |
    ...   | product_type | Yes |  Parameter Operation on vcu or vdu or gnb or enb|
    ...   | bts_index | NO |  gnb index in testline configurtion file. Default is 0. |
    ...   | cudu_index | NO | cu or vdu index in testline configurtion file. Default is 0. |
    ...   | expected_alarms | NO | Expected alarm information to be detected, data type: list |
    ...   | ignored_alarms | NO | Allowed alarm information, data type: list or xx.py |
    ...   | critical_alarms | NO | Disallowed alarm information, critical, major, minor, data type: list|
    ...   | timeout | NO | Timeout  default is 300s. |
    ...
    ...    Example
    ...    | Alarm Operation | get_active_alarms | vdu | 0 | 0 |
    ...    | ${expected_alarms} | ${ignored_alarms} | ${critical_alarms} | ${timeout} |
    ...

    @{product_type_list}   create list   vdu   vcu   gnb   enb
    Should Contain   ${product_type_list}   ${product_type}
    ${out}    Run Keyword If    '${product_type}' in ["enb", "gnb"]
    ...    Classical Alarm Operation
    ...    operation=${operation}
    ...    product_type=${product_type}
    ...    bts_index=${bts_index}
    ...    expected_alarms=${expected_alarms}
    ...    ignored_alarms=${ignored_alarms}
    ...    critical_alarms=${critical_alarms}
    ...    timeout=${timeout}
    ...    ELSE IF   '${product_type}' in ["vdu", "vcu"]
    ...    Cloud Alarm Operation
    ...    operation=${operation}
    ...    product_type=${product_type}
    ...    bts_index=${bts_index}
    ...    cudu_index=${cudu_index}
    ...    expected_alarms=${expected_alarms}
    ...    ignored_alarms=${ignored_alarms}
    ...    critical_alarms=${critical_alarms}
    ...    timeout=${timeout}
    [Return]  ${out}

