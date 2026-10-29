# @Time    : 2025/8/4 16:38
# @Author  : Jian.1.Chen
# @Email   : jian.1.chen@nokia-sbell.com
# @File    : counter.robot
# @Software: PyCharm
*** Settings ***
Documentation    This is common robot keywords template
Resource    ../internal_resource.robot

*** Keywords ***
Get Recent Multi Counters Value
    [Documentation]    Author: jian.1.chen@nokia-sbell.com
    ...    Init Define: 2024/09/27 20:13
    [Arguments]    ${counters}
    ${counter_values}    Create Dictionary
    ${counter_names}    Get Dictionary Keys    ${counters}
    FOR    ${counter_name}    IN    @{counter_names}
        ${values}    Get Dictionary Values    ${counters['${counter_name}']}
        Set To Dictionary    ${counter_values}    ${counter_name}=${values[-1]}
    END
    [Return]    ${counter_values}
