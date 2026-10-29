*** Settings ***
Documentation
...    Author: He winnie
...    Contact: winnie.he@nokia-sbell.com
...    Common KWs use to operate the bts
...    All the bugs/new keyword needs/improvement should be raised in Jira and assign to the authors.
...    Jira link: https://jiradc.ext.net.nokia.com/projects/PZ1HAZTA/issues
...    Guidelines for user: https://confluence.ext.net.nokia.com/display/SRANPRODHZHTA/06.+Module+of+Counter+Operation
...    Examples: https://wrgitlab.int.net.nokia.com/RAN/robotws/-/tree/master/testsuite/Hangzhou/resources/RAN_PZ_HAZ_1/Module/Module_Test

Resource    ./library/_kpi_operation.robot
# *** Variables ***

*** Keywords ***
KPI Operation
    [Arguments]    ${operation}
    ...    ${product_type}=gnb  #enb
    ...    ${bts_index}=${0}
    ...    ${du_index}=${0}
    ...    ${timeout}=${None}
    ...    &{kwargs}
    [Documentation]     this keyword contain the KPI report operation
    ...   Author: winnie he
    ...   Contact: winnie.he@nokia-sbell.com
    ...   | Input Parameters | Man. | Description |
    ...   | operation  | yes | operation can support "start_kpi_collection",
    ...                        "add_kpi_collection", "finish_kpi_collection",
    ...                        "kpi_report_generate", benchmark_report_generate  |
    ...   | product_type | yes | product type can support enb, gnb, vcu, vdu |
    ...   | bts_index | No | the index of the bts in tl's init.py, ${tl.gnbs[gnb_index]} |
    ...   | du_index | No |  the index of the bts du in tl's init.py, ${tl.gnbs[gnb_index].dus[vdu_vcu_index]} |
    ...   | offset_time | No | counter rule string list or text file path  |
    ...   | timeout | No | Mostly you no need to change this value, most of operation have their own default time |
    ...   | kwargs | No | other parameters you want to pass to the kw |
    Log     ${timeout} is not used
    ${product_type}    Convert To Lower Case    ${product_type}
    ${value}    Run Keyword If    '${product_type}' not in ["enb", "gnb", "vcu", "vdu"]
    ...    Fail    msg=Your product type ${product_type} no support yet.
    ${support_operation}     Create List
    ...    start_kpi_collection
    ...    add_kpi_collection
    ...    finish_kpi_collection
    ...    kpi_report_generate
    ...    benchmark_report_generate
    ...    start_kpi_collection_scout
    ...    finish_kpi_collection_scout
    ...    generate_comparator_report_scout
    Run Keyword If    '${operation}' not in ${support_operation}
    ...    Fail    msg=Your operation ${operation} no support yet. Please contact the model owner.
    ${value}    Run Keyword    _kpi_operation.interface
    ...    operation=${operation}
    ...    product_type=${product_type}
    ...    bts_index=${bts_index}
    ...    du_index=${du_index}
    ...    &{kwargs}
    [Return]    ${value}
