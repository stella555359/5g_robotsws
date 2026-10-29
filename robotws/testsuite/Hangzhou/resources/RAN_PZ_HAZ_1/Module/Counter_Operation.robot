*** Settings ***
Documentation
...    Author: He winnie, Xiang Liangliang
...    Contact: winnie.he@nokia-sbell.com, liang.xiang@nokia-sbell.com
...    Common KWs use to operate the bts
...    All the bugs/new keyword needs/improvement should be raised in Jira and assign to the authors.
...    Jira link: https://jiradc.ext.net.nokia.com/projects/PZ1HAZTA/issues
...    Guidelines for user: https://confluence.ext.net.nokia.com/display/SRANPRODHZHTA/06.+Module+of+Counter+Operation
...    Examples: https://wrgitlab.int.net.nokia.com/RAN/robotws/-/tree/master/testsuite/Hangzhou/resources/RAN_PZ_HAZ_1/Module/Module_Test

Resource    ./library/_counter_operation.robot
# *** Variables ***
*** Keywords ***
Counter Operation
    [Arguments]    ${operation}
    ...    ${product_type}=gnb  #enb
    ...    ${bts_index}=${0}
    ...    ${cudu_index}=${0}
    ...    ${counter_rule}=${EMPTY}
    ...    ${interval}=5
    ...    ${timeout}=${None}
    ...    &{kwargs}
    [Documentation]     this keyword contain the classical BTS normal operation
    ...   Author: winnie he
    ...   Contact: winnie.he@nokia-sbell.com
    ...   | Input Parameters | Man. | Description |
    ...   | operation  | yes | operation can support "start_collect_counter",
    ...                        "collect_counter", "collect_counter_and_check_rule", "compare"  |
    ...   | product_type | yes | product type can support enb, gnb, vcu, vdu |
    ...   | bts_index | No | the index of the bts in tl's init.py, ${tl.gnbs[gnb_index]} |
    ...   | cudu_index | No |  the index of the bts du in tl's init.py, ${tl.gnbs[gnb_index].dus[vdu_vcu_index]} |
    ...   | counter_rule | No | counter rule string list or text file path  |
    ...   | timeout | No | Mostly you no need to change this value, most of operation have their own default time |
    ...   | kwargs | No | other parameters you want to pass to the kw |
    ${product_type}    Convert To Lower Case    ${product_type}
    ${value}    Run Keyword If    '${product_type}' in ["enb", "gnb", "vcu", "vdu"]
    ...    _counter_operation.interface    operation=${operation}
    ...    product_type=${product_type}
    ...    bts_index=${bts_index}
    ...    cudu_index=${cudu_index}
    ...    counter_rule=${counter_rule}
    ...    interval=${interval}
    ...    timeout=${timeout}
    ...    &{kwargs}
    ...    ELSE
    ...    Fail    msg=Your product_type ${product_type} no support yet. Please contact the model owner.
    [Return]    ${value}
