# @Time    : 2022/2/15 15:24
# @Author  : Jian.1.Chen
# @Email   : jian.1.chen@nokia-sbell.com
# @File    : csvanalyzer.robot
# @Software: PyCharm
*** Settings ***
Documentation    This is common csv analyzer keyword
...    Include Keywords:
...    Verify Special Item Value Exist
...    Get Special Item Value List With Precondition
Library     ../python/csvanalyzer.py

*** Keywords ***
Verify Special Item Value Exist
    [Documentation]    jian.1.chen@nokia-sbell.com
    [Arguments]    ${file_path}    ${item}    ${item_value}
    ${special_item_value_list}    get_the_special_item_value    ${file_path}    ${item}
    List Should Contain Value    ${special_item_value_list}    ${item_value}

Verify Special Item Value Exist for more values
    [Documentation]    jin.2.zhang@nokia-sbell.com
    [Arguments]    ${file_path}    ${item}    ${item_value}     ${first_value}
    ${special_item_value_list}    get_the_special_item_value    ${file_path}    ${item}
    #List Should Contain Value    ${special_item_value_list}    ${item_value}
    ${status}  Run Keyword And Return Status  List Should Contain Value    ${special_item_value_list}    ${item_value}
    run keyword if  not ${status}  Should Contain Any  ${special_item_value_list}[0]    ${item_value}  ${first_value}


Get Special Item Value List With Precondition
    [Documentation]    jian.1.chen@nokia-sbell.com
    [Arguments]    ${file_path}    ${item}    ${precondition}
    ${special_item_value_list}    get_the_special_item_value_with_preconditon    ${file_path}    ${item}
    ...    ${precondition}
    [Return]    ${special_item_value_list}
