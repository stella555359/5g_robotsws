*** Settings ***
Documentation
...    Author: He winnie
...    Contact: winnie.he@nokia-sbell.com
...    Common KWs use to operate the bts
...    All the bugs/new keyword needs/improvement should be raised in Jira and assign to the authors.
...    Jira link: https://jiradc.ext.net.nokia.com/projects/PZ1HAZTA/issues
...    Guidelines for user: https://confluence.ext.net.nokia.com/display/SRANPRODHZHTA/06.+Module+of+Counter+Operation
...    Examples: https://wrgitlab.int.net.nokia.com/RAN/robotws/-/tree/master/testsuite/Hangzhou/resources/RAN_PZ_HAZ_1/Module/Module_Test

Library             ./library/at_operation/    WITH NAME    at


*** Keywords ***
AT Operation
    [Arguments]    ${operation}
    ...    ${ue_index}=0
    ...    ${timeout}=${None}
    ...    &{kwargs}
    [Documentation]     this keyword contain the classical BTS normal operation
    ...   Author: winnie he
    ...   Contact: winnie.he@nokia-sbell.com
    ...   | Input Parameters | Man. | Description |
    ...   | operation  | yes | operation can support "start_collect_counter",
    ...                        "collect_counter", "collect_counter_and_check_rule", "compare"]  |
    ...   | product_type | yes | product type can support enb, gnb, vcu, vdu |
    ...   | bts_index | No | the index of the bts in tl's init.py, ${tl.gnbs[gnb_index]} |
    ...   | cudu_index | No |  the index of the bts du in tl's init.py, ${tl.gnbs[gnb_index].dus[vdu_vcu_index]} |
    ...   | counter_rule | No | counter rule string list or text file path  |
    ...   | timeout | No | Mostly you no need to change this value, most of operation have their own default time |
    ...   | kwargs | No | other parameters you want to pass to the kw |
    Log To Console    ${timeout}
    at.Setup    ue_index=${ue_index}
    ${support_operation}     Create List
    ...    attach
    ...    detach
    ...    reboot
    ...    start_traffic
    ...    stop_traffic
    ...    start_call
    ...    stop_call
    ...    exec_at_command
    ...    get
    ...    set
    Run Keyword If    '${operation}' not in ${support_operation}
    ...    Fail    msg=Your operation ${operation} no support yet. Please contact the model owner.
    ${value}    Run Keyword    at.${operation}
    ...    alias=at_operation_${ue_index}
    ...    &{kwargs}
    [Return]    ${value}
    [Teardown]    at.teardown    at_operation_${ue_index}
