*** Settings ***
Documentation
...    Author: Xiang Liangliang
...    Contact: liang.xiang@nokia-sbell.com
...    Common KW use to Fault1900 Trigger And Clear
...    All the bugs/new keyword needs/improvement should be raised in Jira and assign to the authors.
...    Jira link: https://jiradc.ext.net.nokia.com/projects/PZ1HAZTA/issues
...    Guidelines for user:
...    Examples: https://wrgitlab.int.net.nokia.com/RAN/robotws/-/tree/master/testsuite/Hangzhou/resources/RAN_PZ_HAZ_1/CERTA_Module

Resource    ./library/fault1900_trigger_and_clear/_Fault1900_trigger_clear.robot



*** Keywords ***
Fault 1900 Trigger And Clear
    [Arguments]  ${product_type}
    ...          ${bts_index}=${0}
    ...          ${cudu_index}=${0}
    ...          ${cell_distname_id}=${None}
    ...          ${timeout}=${300}
    ...          &{kwargs}
    Log To Console    ${bts_index}
    Run Keyword if    '${product_type}' == 'gnb'  Fault1900_Trigger_And_Clear_gnb
    ...    product_type=${product_type}
    ...    bts_index=${0}
    ...    cudu_index=${cudu_index}
    ...    cell_distname_id=${cell_distname_id}
    ...    timeout=${timeout}
    ...    kwargs=${kwargs}
    ...    ELSE IF    '${product_type}'  in  ['enb','vdu','vcu']
    ...    log to console    the product type is not supported yet or invalid


