*** Settings ***
Documentation
...    Author: He winnie
...    Contact: winnie.he@nokia-sbell.com
...    Common KWs use to operate the bts
Library             BuiltIn
Library             Collections
Library             DateTime
Library             json
Library             OperatingSystem
Library             Process
Library             String
Library             ./counter_rule/    WITH NAME    cr
# *** Variables ***

*** Keywords ***
_counter_operation.interface
    [Arguments]    ${operation}
    ...    ${product_type}=gnb  #enb
    ...    ${bts_index}=${0}
    ...    ${cudu_index}=${0}
    ...    ${counter_rule}=${EMPTY}
    ...    ${timeout}=${None}
    ...    ${interval}=5
    ...    &{kwargs}
    Log    ${timeout} is not used
    ${opreation_list}    Create List    start_collect_counter
    ...    collect_counter
    ...    collect_counter_and_check_rule
    ...    compare
    ...    collect_counter_and_calculate
    Run Keyword If
    ...    '${operation}' not in ${opreation_list}
    ...    Fail    msg=Your operation ${operation} no support yet. Please contact the model owner.
    ${value}    Run Keyword
    ...    _counter_operation.${operation}    product_type=${product_type}
    ...    bts_index=${bts_index}
    ...    cudu_index=${cudu_index}
    ...    counterrule=${counter_rule}
    ...    interval=${interval}
    ...    &{kwargs}
    [Return]    ${value}

_counter_operation.start_collect_counter
    [Arguments]    ${product_type}=gnb  #enb
    ...    ${bts_index}=${0}
    ...    ${cudu_index}=${0}
    ...    ${counterrule}=${EMPTY}
    ...    ${timeout}=${None}
    ...    ${interval}=5
    ...    &{kwargs}
    Log    ${timeout} is not used
    cr.start_collect_counter    product_type=${product_type}
    ...    bts_index=${bts_index}
    ...    cudu_index=${cudu_index}
    ...    counterrule=${counter_rule}
    ...    interval=${interval}
    ...    &{kwargs}

_counter_operation.collect_counter
    [Arguments]    ${product_type}=gnb  #enb
    ...    ${bts_index}=${0}
    ...    ${cudu_index}=${0}
    ...    &{kwargs}
    ${value}    cr.collect_counter    alias=${product_type}_${bts_index}_${cudu_index}
    [Teardown]    cr.teardown    alias=${product_type}_${bts_index}_${cudu_index}
    [Return]    ${value}

_counter_operation.collect_counter_and_check_rule
    [Arguments]    ${product_type}=gnb  #enb
    ...    ${bts_index}=${0}
    ...    ${cudu_index}=${0}
    ...    &{kwargs}
    ${value}    cr.collect_counter_and_check_rule
    ...    alias=${product_type}_${bts_index}_${cudu_index}
    [Teardown]    cr.teardown    alias=${product_type}_${bts_index}_${cudu_index}
    [Return]    ${value}

_counter_operation.compare
    [Arguments]    ${product_type}=gnb  #enb
    ...    ${bts_index}=${0}
    ...    ${cudu_index}=${0}
    ...    &{kwargs}
    ${value}    cr.compare    alias=${product_type}_${bts_index}_${cudu_index}
    ...    before_counter_value=${kwargs}[before_counter_value]
    ...    after_counter_value=${kwargs}[after_counter_value]
    [Return]    ${value}

_counter_operation.collect_counter_and_calculate
    [Arguments]    ${product_type}=gnb  #enb
    ...    ${bts_index}=${0}
    ...    ${cudu_index}=${0}
    ...    &{kwargs}
    ${value}    cr.collect_counter_and_calculate
    ...    alias=${product_type}_${bts_index}_${cudu_index}
    [Teardown]    cr.teardown    alias=${product_type}_${bts_index}_${cudu_index}
    [Return]    ${value}